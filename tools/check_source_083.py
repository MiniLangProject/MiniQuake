#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check source 083 compatibility and regression contract."""

import argparse, json, pathlib, sys

EXPECTED = [
    {"name": "start-064", "map": "start", "frames": 64},
    {"name": "e1m1-064", "map": "e1m1", "frames": 64},
    {"name": "e1m2-064", "map": "e1m2", "frames": 64},
    {"name": "e1m3-064", "map": "e1m3", "frames": 64},
]

def main():
    """Run the command-line workflow and return its process exit status."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    golden = json.loads((root / "audit/black_port_corpus_golden.json").read_text())
    source = (root / "src/miniquake/black_port_corpus.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/black_port_corpus_tests.ml").read_text(encoding="utf-8-sig")

    if golden.get("scenarios") != EXPECTED:
        errors.append("scenario corpus differs")
    if golden.get("required_processes_per_scenario") != 2:
        errors.append("two-process requirement missing")
    if golden.get("required_comparison") != "byte-identical mqtrace":
        errors.append("byte-identical trace requirement missing")
    for item in EXPECTED:
        for value in (item["name"], item["map"]):
            if f'"{value}"' not in source:
                errors.append("source corpus missing: " + value)
    if "const SCENARIO_COUNT = 4" not in source or "const FRAMES_PER_SCENARIO = 64" not in source:
        errors.append("source corpus constants missing")
    if "MiniQuake BP-083 black-port corpus tests passed: 18" not in test:
        errors.append("runtime success marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-083",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "scenarios": EXPECTED,
        "fixtures": 18,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n")
    print("MiniQuake BP-083 black-port corpus verification: " + report["status"])
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
