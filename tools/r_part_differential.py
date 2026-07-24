#!/usr/bin/env python3
"""Build and compare the deterministic pinned r_part.c/MiniLang fixture."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake"
REFERENCE_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
PATCH = ROOT / "reference" / "patches" / "r_part_trace_fixture.patch"
FIXTURE_ROOT = ROOT / "reference" / "fixtures" / "r_part"
REFERENCE_FIXTURE = FIXTURE_ROOT / "mq_r_part_fixture.c"
MINILANG_FIXTURE = ROOT / "tests" / "r_part_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "r_part_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"
MINILANG_COMPILER = ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py"


def run(command: list[str], *, capture: bool = False) -> bytes:
    print("+", subprocess.list2cmdline(command))
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if capture else b""


def find_toolchain() -> tuple[Path, Path, Path, str]:
    program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
    program_files_x86 = Path(
        os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")
    )
    compilers = sorted(
        program_files.glob(
            "Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x86/cl.exe"
        )
    )
    if not compilers:
        raise RuntimeError("MSVC x86 compiler was not found")
    compiler = compilers[-1]
    msvc_root = compiler.parents[3]
    sdk_root = program_files_x86 / "Windows Kits" / "10"
    versions = sorted(
        path.name
        for path in (sdk_root / "Include").glob("10.*")
        if (sdk_root / "Lib" / path.name / "ucrt" / "x86").is_dir()
    )
    if not versions:
        raise RuntimeError("Windows SDK x86 libraries were not found")
    return compiler, msvc_root, sdk_root, versions[-1]


def compile_reference(worktree: Path, output: Path) -> Path:
    compiler, msvc_root, sdk_root, sdk_version = find_toolchain()
    objects = output / "reference-objects"
    objects.mkdir(parents=True, exist_ok=True)
    executable = output / "glquake_r_part_trace.exe"
    run(
        [
            str(compiler),
            "/nologo",
            "/TC",
            "/O2",
            "/fp:precise",
            "/W4",
            "/wd4101",
            "/wd4244",
            "/wd4305",
            "/DGLQUAKE",
            "/DMINIQUAKE_R_PART_TRACE_FIXTURE",
            f"/I{FIXTURE_ROOT}",
            f"/I{msvc_root / 'include'}",
            f"/I{sdk_root / 'Include' / sdk_version / 'ucrt'}",
            str(worktree / "WinQuake" / "r_part.c"),
            str(REFERENCE_FIXTURE),
            f"/Fe{executable}",
            f"/Fo{objects}\\",
            "/link",
            "/machine:x86",
            "/subsystem:console",
            f"/libpath:{msvc_root / 'lib' / 'x86'}",
            f"/libpath:{sdk_root / 'Lib' / sdk_version / 'ucrt' / 'x86'}",
            f"/libpath:{sdk_root / 'Lib' / sdk_version / 'um' / 'x86'}",
        ]
    )
    return executable


def compile_miniquake(output: Path) -> Path:
    if not MINILANG_COMPILER.is_file():
        raise RuntimeError(f"MiniLang compiler not found: {MINILANG_COMPILER}")
    native_dll = ROOT / "build" / "miniquake_native.dll"
    if not native_dll.is_file():
        raise RuntimeError(f"native bridge not found: {native_dll}")
    shutil.copy2(native_dll, output / native_dll.name)
    executable = output / "miniquake_r_part_trace.exe"
    run(
        [
            sys.executable,
            str(MINILANG_COMPILER),
            str(MINILANG_FIXTURE),
            str(executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(MINILANG_COMPILER.parent),
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
    return executable


def validate_manifest(trace: Path) -> None:
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if payload.get("reference_execution") != "patched-pinned-source-worktree":
        raise RuntimeError("r_part manifest has a non-strict execution model")
    events = [
        json.loads(line)
        for line in trace.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != payload["events"]:
        raise RuntimeError(
            f"r_part manifest expects {payload['events']} events, got {len(events)}"
        )
    scenes = {event["scene"] for event in events}
    functions = {event["function"] for event in events}
    counted = 0
    for claim in payload["functions"]:
        if claim["classification"] != "reference-differential":
            continue
        counted += 1
        expected = [
            evidence.split(":", 1)[1]
            for evidence in claim["evidence"]
            if evidence.startswith("reference-differential:")
        ]
        if claim["name"] not in functions or not all(
            scene in scenes for scene in expected
        ):
            raise RuntimeError(
                f"unobserved r_part compiled-body evidence: {claim['name']}"
            )
    print(f"r_part manifest validated: {counted} original functions")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "r_part",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-r-part-fixture-"))
    worktree = temporary_root / "reference"
    try:
        run(
            [
                "git",
                "-C",
                str(REFERENCE),
                "worktree",
                "add",
                "--detach",
                str(worktree),
                REFERENCE_COMMIT,
            ]
        )
        run(["git", "-C", str(worktree), "apply", str(PATCH)])
        reference_executable = compile_reference(worktree, output)
        miniquake_executable = compile_miniquake(output)
        reference_trace = output / "glquake_r_part_trace.jsonl"
        miniquake_trace = output / "miniquake_r_part_trace.jsonl"
        reference_trace.write_bytes(run([str(reference_executable)], capture=True))
        miniquake_trace.write_bytes(run([str(miniquake_executable)], capture=True))
        run(
            [
                sys.executable,
                str(PARITY_ORACLE),
                "compare-traces",
                str(reference_trace),
                str(miniquake_trace),
                "--epsilon",
                "0.00001",
            ]
        )
        validate_manifest(reference_trace)
    finally:
        if worktree.exists():
            subprocess.run(
                [
                    "git",
                    "-C",
                    str(REFERENCE),
                    "worktree",
                    "remove",
                    "--force",
                    str(worktree),
                ],
                cwd=ROOT,
                check=False,
            )
        shutil.rmtree(temporary_root, ignore_errors=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    print(f"r_part differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"r_part differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
