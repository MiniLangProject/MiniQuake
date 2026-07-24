#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/gl_model.c."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from renderer_differential import compile_miniquake, compile_reference, run


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake"
REFERENCE_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
REFERENCE_FIXTURE = (
    ROOT / "reference" / "fixtures" / "gl_model" / "mq_gl_model_fixture.c"
)
MINILANG_FIXTURE = ROOT / "tests" / "gl_model_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "gl_model_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"
FATAL_MODES = (
    "bsp-version",
    "mdl-vertices",
    "sprite-interval",
    "lump-size",
)


def json_lines(output: bytes) -> bytes:
    lines = [
        line
        for line in output.decode("utf-8", errors="strict").splitlines()
        if line.startswith("{")
    ]
    return ("\n".join(lines) + "\n").encode("utf-8")


def validate_fatal_processes(reference: Path, candidate: Path) -> dict[str, object]:
    cases: dict[str, object] = {}
    for mode in FATAL_MODES:
        original = subprocess.run(
            [str(reference), "--fatal", mode],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        miniquake = subprocess.run(
            [str(candidate), "--fatal", mode],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if original.returncode != 86 or miniquake.returncode != 86:
            raise RuntimeError(
                f"fatal case {mode}: expected exit 86, got "
                f"reference={original.returncode}, MiniQuake={miniquake.returncode}"
            )
        cases[mode] = {
            "reference_exit": original.returncode,
            "miniquake_exit": miniquake.returncode,
        }
    return cases


def validate_manifest(trace: Path, fatal_cases: dict[str, object]) -> None:
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if payload.get("reference_execution") != "direct-pinned-source-build":
        raise RuntimeError("gl_model manifest has a non-strict execution model")
    events = [
        json.loads(line)
        for line in trace.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != payload["events"]:
        raise RuntimeError(
            f"gl_model manifest expects {payload['events']} events, got {len(events)}"
        )
    observed = {event["function"] for event in events}
    scenes = {event["scene"] for event in events}
    counted = 0
    for claim in payload["functions"]:
        if claim["classification"] != "reference-differential":
            continue
        counted += claim.get("source_definitions", 1)
        expected_scenes = [
            item.split(":", 1)[1]
            for item in claim["evidence"]
            if item.startswith("reference-differential:")
        ]
        expected_fatal = [
            item.split(":", 1)[1]
            for item in claim["evidence"]
            if item.startswith("reference-fatal:")
        ]
        if (
            claim["name"] not in observed
            or not expected_scenes
            or not all(scene in scenes for scene in expected_scenes)
            or not all(mode in fatal_cases for mode in expected_fatal)
        ):
            raise RuntimeError(
                f"unobserved gl_model.c compiled-body evidence: {claim['name']}"
            )
    if counted != 39:
        raise RuntimeError(f"expected 39 active gl_model definitions, got {counted}")
    print("gl_model manifest validated: 39 original functions")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "gl_model",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-gl-model-fixture-"))
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
        reference_executable = compile_reference(
            worktree,
            output,
            name="gl_model",
            source="gl_model.c",
            fixture=REFERENCE_FIXTURE,
            macro="MINIQUAKE_GL_MODEL_TRACE_FIXTURE",
        )
        miniquake_executable = compile_miniquake(
            output,
            name="gl_model",
            source=MINILANG_FIXTURE,
        )
        reference_trace = output / "glquake_gl_model_trace.jsonl"
        miniquake_trace = output / "miniquake_gl_model_trace.jsonl"
        reference_trace.write_bytes(
            json_lines(run([str(reference_executable)], capture=True))
        )
        miniquake_trace.write_bytes(
            json_lines(run([str(miniquake_executable)], capture=True))
        )
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
        fatal_cases = validate_fatal_processes(
            reference_executable, miniquake_executable
        )
        (output / "fatal_processes.json").write_text(
            json.dumps(fatal_cases, indent=2) + "\n",
            encoding="utf-8",
        )
        validate_manifest(reference_trace, fatal_cases)
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
    print(f"gl_model differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"gl_model differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
