#!/usr/bin/env python3
"""Strict pinned WinQuake/zone.c differential and fatal-process matrix."""
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
PIN = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"


def bridge():
    path = ROOT / "native/build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command, capture=False):
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout or ""


def build(output):
    compiler, linker, _ = bridge().find_msvc_tools()
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(ROOT / "reference/quake"),
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
            str(ROOT / "reference/quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PIN,
        ]
    )
    run(
        [
            "git",
            "-C",
            str(worktree),
            "apply",
            str(ROOT / "reference/patches/zone_pinned_oracle.patch"),
        ]
    )
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/GS-",
        "/Zl",
        "/fp:precise",
        "/O2",
        "/Gy",
        f"/I{ROOT / 'reference/harness'}",
    ]
    source = output / "zone.obj"
    driver = output / "zone_driver.obj"
    run(
        common
        + [
            "/DMINIQUAKE_PINNED_ORACLE",
            f"/Fo{source}",
            str(worktree / "WinQuake/zone.c"),
        ]
    )
    run(
        common
        + [
            f"/Fo{driver}",
            str(ROOT / "reference/harness/zone_pinned_driver.c"),
        ]
    )
    dll = output / "zone_oracle.dll"
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/opt:ref",
            f"/def:{ROOT / 'reference/harness/zone_oracle.def'}",
            f"/out:{dll}",
            str(source),
            str(driver),
            str(ROOT / "native/build/msvcrt.lib"),
            str(ROOT / "native/build/kernel32.lib"),
        ]
    )
    return dll


def oracle(dll, destination):
    library = ctypes.WinDLL(str(dll))
    function = library.zone_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler, output, destination):
    executable = output / "zone_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests/zone_differential_fixture.ml"),
            str(executable),
            "-I",
            str(ROOT),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "100",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(run([str(executable)], True), encoding="utf-8", newline="\n")
    return executable


def fatal_processes(dll, executable):
    cases = [
        ("Z_Free:null", "--error-z-free"),
        ("Z_TagMalloc:zero-tag", "--error-z-tag"),
        ("Z_CheckHeap:broken-link", "--error-z-check"),
        ("Hunk_Check:sentinel", "--error-hunk-check"),
        ("Hunk_AllocName:negative", "--error-hunk-alloc"),
        ("Hunk_FreeToLowMark:range", "--error-low-mark"),
        ("Hunk_FreeToHighMark:range", "--error-high-mark"),
        ("Hunk_HighAllocName:negative", "--error-high-alloc"),
        ("Cache_UnlinkLRU:null-link", "--error-cache-unlink"),
        ("Cache_MakeLRU:active-link", "--error-cache-make"),
        ("Cache_TryAlloc:oversize", "--error-cache-try"),
        ("Cache_Free:unallocated", "--error-cache-free"),
        ("Cache_Alloc:duplicate", "--error-cache-duplicate"),
        ("Cache_Alloc:zero-size", "--error-cache-size"),
        ("Memory_Init:missing-zone-size", "--error-memory-zone"),
        ("Z_Malloc:exhaustion", "--error-z-malloc"),
        ("Hunk_AllocName:exhaustion", "--error-hunk-overflow"),
        ("Z_Free:bad-zone-id", "--error-z-id"),
    ]
    for mode, (name, argument) in enumerate(cases):
        code = (
            "import ctypes; "
            f"d=ctypes.WinDLL(r'{dll}'); "
            "d.zone_error_case.argtypes=[ctypes.c_int]; "
            f"d.zone_error_case({mode})"
        )
        reference = subprocess.run(
            [sys.executable, "-c", code],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=10,
        )
        minilang = subprocess.run(
            [str(executable), argument],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=10,
        )
        if reference.returncode == 0 or minilang.returncode != 42:
            raise RuntimeError(
                f"{name} fatal mismatch: reference={reference.returncode}, "
                f"minilang={minilang.returncode}"
            )
    print(
        "zone fatal differential: PASS "
        f"({len(cases)} isolated process cases, minilang=42)"
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy/mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build/zone_differential",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)

    reference = output / "reference.jsonl"
    minilang = output / "minilang.jsonl"
    dll = build(output)
    oracle(dll, reference)
    executable = candidate(args.compiler.resolve(), output, minilang)

    manifest = json.loads(
        (ROOT / "audit/zone_differential_manifest.json").read_text(encoding="utf-8")
    )
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"event count mismatch: reference={len(events)}, "
            f"manifest={manifest['events']}"
        )
    observed = {event["function"] for event in events}
    expected = {item["name"] for item in manifest["functions"]}
    if observed != expected:
        raise RuntimeError(
            f"strict function mismatch: missing={sorted(expected - observed)}, "
            f"extra={sorted(observed - expected)}"
        )

    run(
        [
            sys.executable,
            str(ROOT / "tools/parity_oracle.py"),
            "compare-traces",
            str(reference),
            str(minilang),
            "--epsilon",
            "1e-5",
        ]
    )
    fatal_processes(dll, executable)
    print("zone differential: PASS (32 events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
