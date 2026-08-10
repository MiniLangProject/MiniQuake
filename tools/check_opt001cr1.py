#!/usr/bin/env python3
"""Source contract for OPT-001CR1 delivery syntax repair."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    golden = json.loads((root / "audit/opt001cr1_syntax_golden.json").read_text(encoding="utf-8-sig"))
    world_path = root / golden["source"]
    world = world_path.read_text(encoding="utf-8-sig")

    trace_assignment = "traceHash = compatHashLightmapRows(page, rectangle[1], rectangle[3])"
    assignment_count = world.count(trace_assignment)
    if assignment_count != int(golden["required_trace_hash_assignments"]):
        errors.append(
            f"trace hash assignment count is {assignment_count}, expected {golden['required_trace_hash_assignments']}"
        )
    for fragment in golden["forbidden_fragments"]:
        if fragment in world:
            errors.append(f"forbidden malformed source fragment remains: {fragment}")

    delimiter_json = root / "build/check-minilang-delimiters.json"
    delimiter_json.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [
            sys.executable,
            str(root / "tools/check_minilang_delimiters.py"),
            "--root",
            str(root),
            "--json",
            str(delimiter_json),
        ],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())

    report = {
        "schema": "MiniQuakeOPT001CR1StaticCheck/1",
        "status": "PASS" if not errors else "FAIL",
        "revision": golden["revision"],
        "parent": golden["parent"],
        "classification": golden["classification"],
        "trace_hash_assignments": assignment_count,
        "delimiter_return_code": proc.returncode,
        "errors": errors,
    }
    if args.json:
        out = Path(args.json)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print("MiniQuake OPT-001CR1 syntax verification")
    print(f"  trace_hash_assignments={assignment_count}")
    print(f"  delimiter_return_code={proc.returncode}")
    for error in errors:
        print(f"  error: {error}")
    print(f"MiniQuake OPT-001CR1 syntax verification: {report['status']}")
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
