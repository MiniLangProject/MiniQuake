#!/usr/bin/env python3
"""Direct pinned-source differential for all active WinQuake/sbar.c bodies."""

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
REFERENCE_FIXTURE = ROOT / "reference" / "fixtures" / "sbar" / "mq_sbar_fixture.c"
MINILANG_FIXTURE = ROOT / "tests" / "sbar_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "sbar_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"
PARITY_ORACLE = ROOT / "tools" / "parity_oracle.py"


def json_lines(output: bytes) -> bytes:
    lines = [
        line
        for line in output.decode("utf-8", errors="strict").splitlines()
        if line.startswith("{")
    ]
    return ("\n".join(lines) + "\n").encode("utf-8")


def validate_manifest(trace: Path) -> None:
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if payload.get("reference_execution") != "direct-pinned-source-build":
        raise RuntimeError("sbar manifest has a non-strict execution model")
    events = [
        json.loads(line)
        for line in trace.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != payload["events"]:
        raise RuntimeError(
            f"sbar manifest expects {payload['events']} events, got {len(events)}"
        )
    observed_functions = {event["function"] for event in events}
    observed_scenes = {event["scene"] for event in events}
    claims = {
        claim["name"]
        for claim in payload["functions"]
        if claim["classification"] == "reference-differential"
    }
    if len(claims) != 24 or claims != observed_functions:
        raise RuntimeError(
            f"expected exact 24-body sbar inventory, got "
            f"{len(claims)} claims and {len(observed_functions)} observed"
        )
    for claim in payload["functions"]:
        expected = [
            item.split(":", 1)[1]
            for item in claim["evidence"]
            if item.startswith("reference-differential:")
        ]
        if not expected or not all(scene in observed_scenes for scene in expected):
            raise RuntimeError(
                f"unobserved sbar.c compiled-body evidence: {claim['name']}"
            )
    print("sbar manifest validated: 24/24 active original bodies")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "build" / "parity" / "sbar",
    )
    args = parser.parse_args()
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)

    run([sys.executable, str(VERIFY_REFERENCE)])
    temporary_root = Path(tempfile.mkdtemp(prefix="glquake-sbar-fixture-"))
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
            name="sbar",
            source="sbar.c",
            fixture=REFERENCE_FIXTURE,
            macro="MINIQUAKE_SBAR_FIXTURE",
            link_libraries=[],
        )
        miniquake_executable = compile_miniquake(
            output,
            name="sbar",
            source=MINILANG_FIXTURE,
        )
        reference_trace = output / "glquake_sbar_trace.jsonl"
        miniquake_trace = output / "miniquake_sbar_trace.jsonl"
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
    print(f"sbar differential passed: {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"sbar differential failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
