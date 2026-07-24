#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/keys.c."""

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
REFERENCE = ROOT / "reference" / "quake"
PATCH = ROOT / "reference" / "patches" / "keys_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "keys_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "keys_oracle.def"
FIXTURE = ROOT / "tests" / "keys_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "keys_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"


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


def verify_reference() -> None:
    run([sys.executable, str(VERIFY_REFERENCE), "--quiet"])


def build_oracle(output: Path) -> Path:
    tools = load_build_bridge().find_msvc_tools()
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
                str(REFERENCE),
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
            str(REFERENCE),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "keys_pinned.obj"
    driver_obj = output / "keys_pinned_driver.obj"
    dll = output / "keys_oracle.dll"
    base = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/wd4100",
        "/wd4244",
        "/wd4706",
        "/GS-",
        "/Zl",
        "/fp:precise",
        "/O2",
        "/Gy",
        f"/I{STUB_INCLUDE}",
    ]
    run(
        base
        + [
            "/DMINIQUAKE_PINNED_ORACLE",
            f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "keys.c"),
        ]
    )
    run(base + [f"/Fo{driver_obj}", str(DRIVER)])
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
    function = library.keys_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"oracle returned invalid byte count {size}")
    destination.write_bytes(buffer.raw[:size])


def build_and_run_minilang(
    compiler: Path, output: Path, destination: Path
) -> None:
    executable = output / "keys_minilang.exe"
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
        raise RuntimeError(
            f"manifest functions lack events: {sorted(expected - observed)}"
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
        default=ROOT / "build" / "keys_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    verify_reference()
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
            "1e-5",
        ]
    )
    verify_reference()
    print("keys differential: PASS (12 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
