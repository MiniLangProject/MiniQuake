#!/usr/bin/env python3
"""Direct pinned-source differential for all active WinQuake/gl_draw.c bodies."""

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
    ROOT / "reference" / "fixtures" / "gl_draw" / "mq_gl_draw_fixture.c"
)
MINILANG_FIXTURE = ROOT / "tests" / "gl_draw_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "gl_draw_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"
FATAL_MODES = (
    "transpic-coordinates",
    "scrap-full",
    "upload-too-big",
    "upload8-size",
)
PREEXISTING_STRICT = {"GL_Bind", "Draw_TileClear"}


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
        raise RuntimeError("gl_draw manifest has a non-strict execution model")
    events = [
        json.loads(line)
        for line in trace.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != payload["events"]:
        raise RuntimeError(
            f"gl_draw manifest expects {payload['events']} events, got {len(events)}"
        )
    observed = {event["function"] for event in events}
    scenes = {event["scene"] for event in events}
    claims = {
        claim["name"]
        for claim in payload["functions"]
        if claim["classification"] == "reference-differential"
    }
    if claims & PREEXISTING_STRICT:
        raise RuntimeError("gl_draw manifest duplicates pre-existing strict claims")
    if set(payload["preexisting_strict_functions"]) != PREEXISTING_STRICT:
        raise RuntimeError("gl_draw pre-existing strict integration is incomplete")
    if len(claims) != 31 or len(observed) != 33:
        raise RuntimeError(
            f"expected 31 new and 33 total gl_draw bodies, got "
            f"{len(claims)} new and {len(observed)} observed"
        )
    if claims | PREEXISTING_STRICT != observed:
        raise RuntimeError("gl_draw event/function inventory is not exact")
    for claim in payload["functions"]:
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
                f"unobserved gl_draw.c compiled-body evidence: {claim['name']}"
            )
    print("gl_draw manifest validated: 31 new + 2 pre-existing strict functions")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "gl_draw",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-gl-draw-fixture-"))
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
            name="gl_draw",
            source="gl_draw.c",
            fixture=REFERENCE_FIXTURE,
            macro="MINIQUAKE_GL_DRAW_FIXTURE",
            link_libraries=[],
        )
        miniquake_executable = compile_miniquake(
            output,
            name="gl_draw",
            source=MINILANG_FIXTURE,
        )
        reference_trace = output / "glquake_gl_draw_trace.jsonl"
        miniquake_trace = output / "miniquake_gl_draw_trace.jsonl"
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
    print(f"gl_draw differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"gl_draw differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
