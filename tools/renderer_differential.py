#!/usr/bin/env python3
"""Build and compare the deterministic GLQuake/MiniQuake renderer fixture."""

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
PATCHES = [
    ROOT / "reference" / "patches" / "renderer_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_warp_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_rlight_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_rsurf_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_refrag_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_rmisc_trace_fixture.patch",
    ROOT / "reference" / "patches" / "renderer_rmain_trace_fixture.patch",
]
FIXTURE_ROOT = ROOT / "reference" / "fixtures" / "renderer"
MANIFEST = ROOT / "audit" / "renderer_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"
MINILANG_COMPILER = ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py"


def run(command: list[str], *, cwd: Path = ROOT, capture: bool = False) -> bytes:
    print("+", subprocess.list2cmdline(command))
    result = subprocess.run(
        command,
        cwd=cwd,
        check=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if capture else b""


def newest_directory(pattern: str) -> Path:
    matches = sorted(Path().glob(pattern))
    if not matches:
        raise RuntimeError(f"required toolchain directory not found: {pattern}")
    return matches[-1]


def find_toolchain() -> tuple[Path, Path, Path, str]:
    program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
    program_files_x86 = Path(
        os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")
    )
    msvc_candidates = sorted(
        program_files.glob(
            "Microsoft Visual Studio/*/*/VC/Tools/MSVC/*/bin/Hostx64/x86/cl.exe"
        )
    )
    if not msvc_candidates:
        raise RuntimeError("MSVC x86 compiler was not found")
    compiler = msvc_candidates[-1]
    msvc_root = compiler.parents[3]
    sdk_root = program_files_x86 / "Windows Kits" / "10"
    sdk_versions = sorted(
        path.name
        for path in (sdk_root / "Include").glob("10.*")
        if (sdk_root / "Lib" / path.name / "ucrt" / "x86").is_dir()
    )
    if not sdk_versions:
        raise RuntimeError("Windows SDK x86 libraries were not found")
    return compiler, msvc_root, sdk_root, sdk_versions[-1]


def compile_reference(
    worktree: Path,
    output: Path,
    *,
    name: str,
    source: str,
    fixture: Path,
    macro: str,
    compiler_defines: list[str] | None = None,
    link_libraries: list[str] | None = None,
) -> Path:
    compiler, msvc_root, sdk_root, sdk_version = find_toolchain()
    object_dir = output / f"reference-{name}-objects"
    object_dir.mkdir(parents=True, exist_ok=True)
    executable = output / f"glquake_renderer_{name}_trace.exe"
    command = [
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
            f"/D{macro}",
            f"/I{FIXTURE_ROOT}",
            f"/I{worktree / 'WinQuake'}",
            f"/I{msvc_root / 'include'}",
            f"/I{sdk_root / 'Include' / sdk_version / 'ucrt'}",
            f"/I{sdk_root / 'Include' / sdk_version / 'shared'}",
            f"/I{sdk_root / 'Include' / sdk_version / 'um'}",
            str(worktree / "WinQuake" / source),
            str(fixture),
            f"/Fe{executable}",
            f"/Fo{object_dir}\\",
            "/link",
            "/machine:x86",
            "/subsystem:console",
            f"/libpath:{msvc_root / 'lib' / 'x86'}",
            f"/libpath:{sdk_root / 'Lib' / sdk_version / 'ucrt' / 'x86'}",
            f"/libpath:{sdk_root / 'Lib' / sdk_version / 'um' / 'x86'}",
        ]
    libraries = ["opengl32.lib"] if link_libraries is None else link_libraries
    command[command.index("/link") + 3:command.index("/link") + 3] = libraries
    for definition in compiler_defines or []:
        command.insert(8, f"/D{definition}")
    run(command)
    return executable


def compile_miniquake(output: Path, *, name: str, source: Path) -> Path:
    if not MINILANG_COMPILER.is_file():
        raise RuntimeError(f"MiniLang compiler not found: {MINILANG_COMPILER}")
    native_dll = ROOT / "build" / "miniquake_native.dll"
    if not native_dll.is_file():
        raise RuntimeError(f"native bridge not found: {native_dll}")
    shutil.copy2(native_dll, output / native_dll.name)
    executable = output / f"miniquake_renderer_{name}_trace.exe"
    run(
        [
            sys.executable,
            str(MINILANG_COMPILER),
            str(source),
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


def compare_fixture(
    worktree: Path,
    output: Path,
    *,
    name: str,
    reference_source: str,
    reference_fixture: Path,
    macro: str,
    minilang_source: Path,
    epsilon: str,
) -> tuple[Path, Path]:
    reference_executable = compile_reference(
        worktree,
        output,
        name=name,
        source=reference_source,
        fixture=reference_fixture,
        macro=macro,
    )
    miniquake_executable = compile_miniquake(
        output, name=name, source=minilang_source
    )
    reference_trace = output / f"glquake_renderer_{name}_trace.jsonl"
    miniquake_trace = output / f"miniquake_renderer_{name}_trace.jsonl"
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
            epsilon,
        ]
    )
    return reference_trace, miniquake_trace


def validate_manifest(reference_traces: dict[str, Path]) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest.get("command") != "python tools/renderer_differential.py":
        raise RuntimeError("fixture manifest has a stale reproduction command")
    missing: list[str] = []
    differential_count = 0
    for unit in manifest["units"]:
        unit_name = unit["unit"]
        trace = reference_traces.get(unit_name)
        if trace is None:
            missing.append(f"{unit_name}: no reference trace")
            continue
        events = [
            json.loads(line)
            for line in trace.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        if len(events) != unit["events"]:
            missing.append(
                f'{unit_name}: expected {unit["events"]} events, observed {len(events)}'
            )
        observed_scenes = {event["scene"] for event in events}
        observed_functions = {
            event["function"] for event in events if "function" in event
        }
        for input_name in unit["inputs"]:
            if not (ROOT / input_name).is_file():
                missing.append(f"{unit_name}: missing input {input_name}")
        for function in unit.get("functions", []):
            if function.get("classification") != "reference-differential":
                continue
            differential_count += 1
            if not isinstance(function.get("source_definitions"), int):
                missing.append(
                    f'{unit_name}:{function["name"]}: missing source_definitions'
                )
            fixtures = [
                item.split(":", 1)[1]
                for item in function["evidence"]
                if item.startswith("reference-differential:")
            ]
            if not fixtures or not all(
                fixture in observed_scenes for fixture in fixtures
            ):
                missing.append(
                    f'{unit_name}:{function["name"]} -> {fixtures}'
                )
            if observed_functions and function["name"] not in observed_functions:
                missing.append(
                    f'{unit_name}:{function["name"]}: function tag not observed'
                )
    if missing:
        raise RuntimeError(
            "fixture manifest has unobserved compiled-body evidence: "
            + "; ".join(missing)
        )
    print(
        "fixture manifest validated:",
        differential_count,
        "original functions",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "renderer",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-renderer-fixture-"))
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
        for patch in PATCHES:
            run(["git", "-C", str(worktree), "apply", str(patch)])
        traces = [
            compare_fixture(
                worktree,
                output,
                name="draw",
                reference_source="gl_draw.c",
                reference_fixture=worktree
                / "WinQuake"
                / "mq_renderer_trace_fixture.c",
                macro="MINIQUAKE_RENDERER_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_trace_fixture.ml",
                epsilon="0",
            ),
            compare_fixture(
                worktree,
                output,
                name="warp",
                reference_source="gl_warp.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_warp_fixture.c",
                macro="MINIQUAKE_RENDERER_WARP_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_warp_trace_fixture.ml",
                epsilon="0.00001",
            ),
            compare_fixture(
                worktree,
                output,
                name="rlight",
                reference_source="gl_rlight.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_rlight_fixture.c",
                macro="MINIQUAKE_RENDERER_RLIGHT_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_rlight_trace_fixture.ml",
                epsilon="0.00001",
            ),
            compare_fixture(
                worktree,
                output,
                name="rsurf",
                reference_source="gl_rsurf.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_rsurf_fixture.c",
                macro="MINIQUAKE_RENDERER_RSURF_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_rsurf_trace_fixture.ml",
                epsilon="0.00001",
            ),
            compare_fixture(
                worktree,
                output,
                name="refrag",
                reference_source="gl_refrag.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_refrag_fixture.c",
                macro="MINIQUAKE_RENDERER_REFRAG_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_refrag_trace_fixture.ml",
                epsilon="0.00001",
            ),
            compare_fixture(
                worktree,
                output,
                name="rmisc",
                reference_source="gl_rmisc.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_rmisc_fixture.c",
                macro="MINIQUAKE_RENDERER_RMISC_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_rmisc_trace_fixture.ml",
                epsilon="0.00001",
            ),
            compare_fixture(
                worktree,
                output,
                name="rmain",
                reference_source="gl_rmain.c",
                reference_fixture=FIXTURE_ROOT / "mq_gl_rmain_fixture.c",
                macro="MINIQUAKE_RENDERER_RMAIN_TRACE_FIXTURE",
                minilang_source=ROOT / "tests" / "renderer_rmain_trace_fixture.ml",
                epsilon="0.00001",
            ),
        ]
        validate_manifest(
            {
                "gl_draw": traces[0][0],
                "gl_warp": traces[1][0],
                "gl_rlight": traces[2][0],
                "gl_rsurf": traces[3][0],
                "gl_refrag": traces[4][0],
                "gl_rmisc": traces[5][0],
                "gl_rmain": traces[6][0],
            }
        )
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
    print(f"renderer differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"renderer differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
