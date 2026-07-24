#!/usr/bin/env python3
"""Build and compare the deterministic pinned view.c/MiniLang fixture."""

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
REFERENCE_FIXTURE = ROOT / "reference" / "fixtures" / "view" / "mq_view_fixture.c"
MINILANG_FIXTURE = ROOT / "tests" / "view_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "view_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"


def validate_manifest(trace: Path) -> None:
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if payload.get("reference_execution") != "direct-pinned-source-build":
        raise RuntimeError("view manifest has a non-strict execution model")
    events = [
        json.loads(line)
        for line in trace.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != payload["events"]:
        raise RuntimeError(
            f"view manifest expects {payload['events']} events, got {len(events)}"
        )
    scenes = {event["scene"] for event in events}
    functions = {event["function"] for event in events}
    counted = 0
    for claim in payload["functions"]:
        if claim["classification"] != "reference-differential":
            continue
        counted += 1
        expected = [
            item.split(":", 1)[1]
            for item in claim["evidence"]
            if item.startswith("reference-differential:")
        ]
        if claim["name"] not in functions or not all(
            scene in scenes for scene in expected
        ):
            raise RuntimeError(
                f"unobserved view.c compiled-body evidence: {claim['name']}"
            )
    print(f"view manifest validated: {counted} original functions")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "view",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-view-fixture-"))
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
            name="view",
            source="view.c",
            fixture=REFERENCE_FIXTURE,
            macro="MINIQUAKE_VIEW_TRACE_FIXTURE",
        )
        miniquake_executable = compile_miniquake(
            output,
            name="view",
            source=MINILANG_FIXTURE,
        )
        reference_trace = output / "glquake_view_trace.jsonl"
        miniquake_trace = output / "miniquake_view_trace.jsonl"
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
    print(f"view differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"view differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
