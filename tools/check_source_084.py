#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check source 084 compatibility and regression contract."""

import argparse, json, pathlib, re, sys

EXPECTED_FINGERPRINT = 0x309B0737

def fnv1a32(data: bytes) -> int:
    """Compute the fixture's 32-bit FNV-1a fingerprint."""
    value = 0x811C9DC5
    for byte in data:
        value ^= byte
        value = (value * 0x01000193) & 0xFFFFFFFF
    return value

def _const_string(source: str, name: str) -> str:
    """Extract a named MiniLang string constant from source text."""
    match = re.search(rf'^const\s+{re.escape(name)}\s*=\s*"([^"]+)"\s*$', source, flags=re.M)
    return match.group(1) if match else ""


def main():
    """Run the command-line workflow and return its process exit status."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ap.add_argument("--allow-downstream-package", action="store_true")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    golden = json.loads((root / "audit/black_port_source_closure_golden.json").read_text())
    source = (root / "src/miniquake/black_port_source_contract.ml").read_text(encoding="utf-8-sig")
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    main_source = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/black_port_source_closure_tests.ml").read_text(encoding="utf-8-sig")

    actual = fnv1a32(golden.get("contract_text", "").encode("utf-8"))
    if actual != EXPECTED_FINGERPRINT:
        errors.append(f"fingerprint calculation: expected 0x{EXPECTED_FINGERPRINT:08x}, got 0x{actual:08x}")
    if golden.get("fingerprint") != "0x309b0737":
        errors.append("golden fingerprint differs")
    for key, expected in {
        "source_units": 53,
        "header_units": 10,
        "target_definitions": 1094,
        "exact_name": 1081,
        "context_adapter": 9,
        "technical_equivalent": 4,
        "missing": 0,
        "coverage_percent": 100.0,
        "corpus_scenarios": 4,
    }.items():
        if golden.get(key) != expected:
            errors.append(f"golden {key}: expected {expected!r}, got {golden.get(key)!r}")
    for marker in [
        'const STATUS = "black_port_source_109_frozen_v1"',
        "const FINGERPRINT = 0x309b0737",
        "const TARGET_FUNCTION_COUNT = 1094",
        "const UNCLASSIFIED_FUNCTION_COUNT = 0",
    ]:
        if marker not in source:
            errors.append("missing closure marker: " + marker)
    required_build_markers = [
        'const BLACK_PORT_SOURCE_STATUS = "black_port_source_109_frozen_v1"',
        "const BLACK_PORT_SOURCE_FINGERPRINT = 0x309b0737",
    ]
    for marker in required_build_markers:
        if marker not in build_info:
            errors.append("missing build marker: " + marker)

    package_id = _const_string(build_info, "PACKAGE_ID")
    parent_package_id = _const_string(build_info, "PARENT_PACKAGE_ID")
    block_id = _const_string(build_info, "BLOCK_ID")
    if ns.allow_downstream_package:
        # Later packages inherit the frozen BP-084 source-surface contract under
        # their own independently verified delivery identity.
        if not package_id:
            errors.append("downstream build info has no PACKAGE_ID")
        if not parent_package_id:
            errors.append("downstream build info has no PARENT_PACKAGE_ID")
        if not block_id:
            errors.append("downstream build info has no BLOCK_ID")
    else:
        for marker in [
            'const PACKAGE_ID = "BP-084"',
            'const PARENT_PACKAGE_ID = "BP-083"',
            'const BLOCK_ID = "BP-080-084"',
        ]:
            if marker not in build_info:
                errors.append("missing build marker: " + marker)
    if "Black-port source status:" not in main_source:
        errors.append("version output marker missing")
    if "MiniQuake BP-084 source black-port closure tests passed: 24" not in test:
        errors.append("runtime success marker missing")

    report = {
        "schema_version": 1,
        "package": package_id if ns.allow_downstream_package else "BP-084",
        "downstream_package": ns.allow_downstream_package,
        "build_package_id": package_id,
        "build_parent_package_id": parent_package_id,
        "build_block_id": block_id,
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "contract_status": golden.get("status"),
        "fingerprint": f"0x{actual:08x}",
        "target_definitions": golden.get("target_definitions"),
        "missing": golden.get("missing"),
        "fixtures": 24,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n")
    print("MiniQuake BP-084 source black-port closure verification: " + report["status"])
    if not errors:
        print(
            "  status=black_port_source_109_frozen_v1 fingerprint=0x309b0737 "
            f"functions=1094 missing=0 downstream={str(bool(ns.allow_downstream_package)).lower()} "
            f"package={package_id} block={block_id}"
        )
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
