#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/crc.c."""

from __future__ import annotations

import argparse
import ctypes
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
PATCH = ROOT / "reference" / "patches" / "crc_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DEFINITION = ROOT / "reference" / "harness" / "crc_oracle.def"
FIXTURE = ROOT / "tests" / "crc_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "crc_differential_manifest.json"


def load_build_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("miniquake_build_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, cwd: Path = ROOT, capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if result.stdout is not None else ""


def build_oracle(output: Path) -> Path:
    tools = load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(ROOT / "reference" / "quake"),
                "worktree",
                "remove",
                "--force",
                str(worktree),
            ]
        )
    run(
        [
            "git",
            "-C",
            str(ROOT / "reference" / "quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "crc_pinned.obj"
    dll = output / "crc_oracle.dll"
    run(
        [
            compiler,
            "/nologo",
            "/c",
            "/W4",
            "/GS-",
            "/Zl",
            "/O2",
            "/Gy",
            "/DMINIQUAKE_PINNED_ORACLE",
            f"/I{STUB_INCLUDE}",
            f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "crc.c"),
        ]
    )
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/dynamicbase",
            "/nxcompat",
            "/opt:ref",
            f"/def:{DEFINITION}",
            f"/out:{dll}",
            str(source_obj),
        ]
    )
    return dll


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    library.CRC_Init.argtypes = [ctypes.POINTER(ctypes.c_ushort)]
    library.CRC_ProcessByte.argtypes = [
        ctypes.POINTER(ctypes.c_ushort),
        ctypes.c_ubyte,
    ]
    library.CRC_Value.argtypes = [ctypes.c_ushort]
    library.CRC_Value.restype = ctypes.c_ushort
    value = ctypes.c_ushort()
    library.CRC_Init(ctypes.byref(value))
    events: list[dict[str, object]] = [
        {"function": "CRC_Init", "case": "initial", "value": value.value}
    ]
    values: list[int] = []
    for byte in b"Quake":
        library.CRC_ProcessByte(ctypes.byref(value), byte)
        values.append(value.value)
    events.append(
        {"function": "CRC_ProcessByte", "case": "quake", "values": values}
    )
    events.append(
        {
            "function": "CRC_Value",
            "case": "quake",
            "value": library.CRC_Value(value.value),
        }
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "crc_minilang.exe"
    shutil.copy2(
        ROOT / "native" / "miniquake_native.dll",
        output / "miniquake_native.dll",
    )
    run(
        [
            sys.executable,
            str(compiler),
            str(FIXTURE),
            str(executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "20",
        ]
    )
    destination.write_text(
        run([str(executable)], capture=True),
        encoding="utf-8",
        newline="\n",
    )


def validate_manifest(reference: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"manifest expects {manifest['events']} events, observed {len(events)}"
        )
    observed = {event["function"] for event in events}
    expected = {
        item["name"]
        for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    if expected - observed:
        raise RuntimeError(f"manifest functions lack events: {sorted(expected - observed)}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build" / "crc_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    run_oracle(build_oracle(args.output), reference)
    build_and_run_minilang(args.compiler.resolve(), args.output, candidate)
    validate_manifest(reference)
    run(
        [
            sys.executable,
            str(ROOT / "tools" / "parity_oracle.py"),
            "compare-traces",
            str(reference),
            str(candidate),
            "--epsilon",
            "0",
        ]
    )
    print("crc differential: PASS (3 JSONL events, exact)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
