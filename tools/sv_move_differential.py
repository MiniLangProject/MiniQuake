#!/usr/bin/env python3
"""Build and compare the pinned GLQuake and MiniLang sv_move fixtures."""

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
DRIVER = ROOT / "reference" / "harness" / "sv_move_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "sv_move_oracle.def"
STUB_INCLUDE = ROOT / "reference" / "harness"
PATCH = ROOT / "reference" / "patches" / "sv_move_pinned_oracle.patch"
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
FIXTURE = ROOT / "tests" / "sv_move_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "sv_move_differential_manifest.json"


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
    bridge = load_build_bridge()
    tools = bridge.find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    if not msvcrt.exists():
        raise RuntimeError(
            "native/build/msvcrt.lib is missing; run native/build_bridge.py first"
        )
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
    pinned_source = worktree / "WinQuake" / "sv_move.c"
    source_obj = output / "sv_move_pinned.obj"
    driver_obj = output / "sv_move_pinned_driver.obj"
    dll = output / "sv_move_oracle.dll"
    run(
        [
            compiler,
            "/nologo",
            "/c",
            "/W4",
            "/GS-",
            "/Zl",
            "/fp:precise",
            "/O2",
            "/Gy",
            "/DMINIQUAKE_PINNED_ORACLE",
            f"/I{STUB_INCLUDE}",
            f"/Fo{source_obj}",
            str(pinned_source),
        ]
    )
    run(
        [
            compiler,
            "/nologo",
            "/c",
            "/W4",
            "/GS-",
            "/Zl",
            "/fp:precise",
            "/O2",
            "/Gy",
            f"/I{STUB_INCLUDE}",
            f"/Fo{driver_obj}",
            str(DRIVER),
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
            str(driver_obj),
            str(msvcrt),
        ]
    )
    return dll


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    function = library.sv_move_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"oracle returned invalid byte count {size}")
    destination.write_bytes(buffer.raw[:size])


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "sv_move_minilang.exe"
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
            "50",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    text = run([str(executable)], capture=True)
    destination.write_text(text, encoding="utf-8", newline="\n")


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
    differential = {
        item["name"]
        for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    observed = {event["function"] for event in events}
    missing = differential - observed
    if missing:
        raise RuntimeError(
            f"manifest differential functions lack events: {sorted(missing)}"
        )


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
        default=ROOT / "build" / "sv_move_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    dll = build_oracle(args.output)
    run_oracle(dll, reference)
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
            "1e-5",
        ]
    )
    events = sum(
        1 for line in reference.read_text(encoding="utf-8").splitlines() if line
    )
    print(f"sv_move differential: PASS ({events} JSONL events, epsilon=1e-5)")
    print(f"reference={reference}")
    print(f"candidate={candidate}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
