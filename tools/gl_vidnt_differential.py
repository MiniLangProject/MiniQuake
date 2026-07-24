#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/gl_vidnt.c."""

from __future__ import annotations

import argparse
import ctypes
import os
from pathlib import Path
import sys

import conproc_differential as base


ROOT = Path(__file__).resolve().parents[1]
PATCH = ROOT / "reference" / "patches" / "gl_vidnt_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "gl_vidnt_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "gl_vidnt_oracle.def"
FIXTURE = ROOT / "tests" / "gl_vidnt_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "gl_vidnt_differential_manifest.json"


def build_oracle(output: Path) -> Path:
    tools = base.load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, librarian = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    if not msvcrt.exists():
        raise RuntimeError(
            "native/build/msvcrt.lib is missing; run native/build_bridge.py first"
        )
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
    source_obj = output / "gl_vidnt_pinned.obj"
    driver_obj = output / "gl_vidnt_pinned_driver.obj"
    dll = output / "gl_vidnt_oracle.dll"
    msvcrt_extra_def = output / "msvcrt_extra.def"
    msvcrt_extra_lib = output / "msvcrt_extra.lib"
    msvcrt_extra_def.write_text(
        "LIBRARY msvcrt.dll\nEXPORTS\n"
        "  strstr\n  _strnicmp\n  strncmp\n  strncpy\n  strcmp\n",
        encoding="ascii",
    )
    base.run(
        [
            librarian, "/machine:x64", f"/def:{msvcrt_extra_def}",
            f"/out:{msvcrt_extra_lib}",
        ]
    )
    ucrt_def = output / "ucrtbase.def"
    ucrt_lib = output / "ucrtbase.lib"
    ucrt_def.write_text(
        "LIBRARY ucrtbase.dll\nEXPORTS\n  __stdio_common_vsprintf\n",
        encoding="ascii",
    )
    base.run(
        [
            librarian, "/machine:x64", f"/def:{ucrt_def}",
            f"/out:{ucrt_lib}",
        ]
    )
    compiler_path = Path(compiler)
    msvc_include = compiler_path.parents[3] / "include"
    kits_root = Path(
        os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")
    ) / "Windows Kits" / "10" / "Include"
    sdk_versions = sorted(path for path in kits_root.glob("*") if path.is_dir())
    if not msvc_include.is_dir() or not sdk_versions:
        raise RuntimeError("MSVC and Windows SDK headers are required")
    sdk_include = sdk_versions[-1]
    flags = [
        compiler, "/nologo", "/c", "/W4", "/wd4100", "/wd4101",
        "/wd4189", "/wd4244", "/wd4706", "/GS-", "/Zl", "/fp:precise",
        "/O2", "/Gy", "/DGLQUAKE", f"/I{STUB_INCLUDE}",
        f"/I{worktree / 'WinQuake'}", f"/I{msvc_include}",
        f"/I{sdk_include / 'ucrt'}", f"/I{sdk_include / 'shared'}",
        f"/I{sdk_include / 'um'}",
    ]
    base.run(
        flags
        + [
            "/DMINIQUAKE_PINNED_ORACLE", f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "gl_vidnt.c"),
        ]
    )
    base.run(flags + [f"/Fo{driver_obj}", str(DRIVER)])
    base.run(
        [
            linker, "/dll", "/noentry", "/machine:x64", "/nodefaultlib",
            "/dynamicbase", "/nxcompat", "/opt:ref", f"/def:{DEFINITION}",
            f"/out:{dll}", str(source_obj), str(driver_obj), str(msvcrt),
            str(msvcrt_extra_lib), str(ucrt_lib),
        ]
    )
    return dll


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    function = library.gl_vidnt_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    try:
        size = function(buffer, len(buffer))
    except OSError:
        partial = bytes(buffer).split(b"\0", 1)[0]
        if partial:
            destination.write_bytes(partial)
            print(partial.decode("utf-8", errors="replace"))
        raise
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
        default=ROOT / "build" / "gl_vidnt_differential",
    )
    parser.add_argument(
        "--reference-only",
        action="store_true",
        help="Build and run only the pinned C oracle.",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    base.FIXTURE = FIXTURE
    base.MANIFEST = MANIFEST
    base.verify_reference()
    run_oracle(build_oracle(args.output), reference)
    if args.reference_only:
        print("gl_vidnt reference oracle: PASS")
        return 0
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
    print("gl_vidnt differential: PASS (46 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
