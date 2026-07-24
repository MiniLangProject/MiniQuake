#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/in_win.c."""

from __future__ import annotations

import argparse
import ctypes
from pathlib import Path
import sys

import conproc_differential as base


ROOT = Path(__file__).resolve().parents[1]
PATCH = ROOT / "reference" / "patches" / "in_win_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "in_win_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "in_win_oracle.def"
FIXTURE = ROOT / "tests" / "in_win_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "in_win_differential_manifest.json"


def build_oracle(output: Path) -> Path:
    tools = base.load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    worktree = output / "pinned_quake"
    if worktree.exists():
        base.run(
            [
                "git", "-C", str(base.REFERENCE), "worktree", "remove",
                "--force", str(worktree),
            ]
        )
    base.run(
        [
            "git", "-C", str(base.REFERENCE), "worktree", "add", "--detach",
            str(worktree), base.PINNED_COMMIT,
        ]
    )
    base.run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "in_win_pinned.obj"
    driver_obj = output / "in_win_pinned_driver.obj"
    dll = output / "in_win_oracle.dll"
    flags = [
        compiler, "/nologo", "/c", "/W4", "/wd4100", "/wd4101",
        "/wd4244", "/wd4311", "/wd4302", "/wd4152", "/GS-", "/Zl",
        "/fp:precise", "/O2", "/Gy", f"/I{STUB_INCLUDE}",
    ]
    base.run(
        flags
        + [
            "/DMINIQUAKE_PINNED_ORACLE", f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "in_win.c"),
        ]
    )
    base.run(flags + [f"/Fo{driver_obj}", str(DRIVER)])
    base.run(
        [
            linker, "/dll", "/noentry", "/machine:x64", "/nodefaultlib",
            "/dynamicbase", "/nxcompat", "/opt:ref", f"/def:{DEFINITION}",
            f"/out:{dll}", str(source_obj), str(driver_obj), str(msvcrt),
        ]
    )
    return dll


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    function = library.in_win_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"oracle returned invalid byte count {size}")
    destination.write_bytes(buffer.raw[:size])


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
        default=ROOT / "build" / "in_win_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    base.FIXTURE = FIXTURE
    base.MANIFEST = MANIFEST
    base.verify_reference()
    run_oracle(build_oracle(args.output), reference)
    base.build_and_run_minilang(args.compiler.resolve(), args.output, candidate)
    base.validate_manifest(reference)
    base.run(
        [
            sys.executable, str(ROOT / "tools" / "parity_oracle.py"),
            "compare-traces", str(reference), str(candidate),
            "--epsilon", "1e-5",
        ]
    )
    base.verify_reference()
    print("in_win differential: PASS (28 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
