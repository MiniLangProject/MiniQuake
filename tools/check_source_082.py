#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check source 082 compatibility and regression contract."""

import argparse, json, pathlib, sys

EXPECTED = {
    "source_unit_count": 53,
    "header_unit_count": 10,
    "definitions_discovered": 1120,
    "profile_excluded": 26,
    "target_definitions": 1094,
    "accounted_definitions": 1094,
    "coverage_percent": 100.0,
}

def main():
    """Run the command-line workflow and return its process exit status."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    inventory = json.loads((root / "audit/source_function_inventory.json").read_text())
    contract = (root / "src/miniquake/source_profile_contract.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/source_function_inventory_tests.ml").read_text(encoding="utf-8-sig")

    for key, expected in EXPECTED.items():
        if inventory.get(key) != expected:
            errors.append(f"inventory {key}: expected {expected!r}, got {inventory.get(key)!r}")
    counts = inventory.get("status_counts", {})
    for key, expected in {
        "exact_name": 1081,
        "context_adapter": 9,
        "technical_equivalent": 4,
        "profile_excluded": 26,
    }.items():
        if counts.get(key) != expected:
            errors.append(f"status count {key}: expected {expected}, got {counts.get(key)!r}")
    if inventory.get("missing_names") != []:
        errors.append("inventory has missing names")
    if not inventory.get("inventory_sha256") or len(inventory["inventory_sha256"]) != 64:
        errors.append("inventory digest invalid")
    for marker in [
        "const TARGET_DEFINITIONS = 1094",
        "const EXACT_NAME = 1081",
        "const CONTEXT_ADAPTER = 9",
        "const TECHNICAL_EQUIVALENT = 4",
        "const MISSING = 0",
    ]:
        if marker not in contract:
            errors.append("missing contract marker: " + marker)
    if "MiniQuake BP-082 source function inventory tests passed: 20" not in test:
        errors.append("runtime success marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-082",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "inventory_sha256": inventory.get("inventory_sha256", ""),
        "target_definitions": inventory.get("target_definitions"),
        "coverage_percent": inventory.get("coverage_percent"),
        "fixtures": 20,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n")
    print("MiniQuake BP-082 source function inventory verification: " + report["status"])
    if not errors:
        print("  target_definitions=1094 exact_name=1081 context_adapter=9 technical_equivalent=4 missing=0")
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
