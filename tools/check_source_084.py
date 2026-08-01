#!/usr/bin/env python3
import argparse, json, pathlib, sys

EXPECTED_FINGERPRINT = 0x309B0737

def fnv1a32(data: bytes) -> int:
    value = 0x811C9DC5
    for byte in data:
        value ^= byte
        value = (value * 0x01000193) & 0xFFFFFFFF
    return value

def main():
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
    if ns.allow_downstream_package:
        required_build_markers += ['const PACKAGE_ID = "BP-089"', 'const BLOCK_ID = "BP-085-089"']
    else:
        required_build_markers += ['const PACKAGE_ID = "BP-084"', 'const BLOCK_ID = "BP-080-084"']
    for marker in required_build_markers:
        if marker not in build_info:
            errors.append("missing build marker: " + marker)
    if "Black-port source status:" not in main_source:
        errors.append("version output marker missing")
    if "MiniQuake BP-084 source black-port closure tests passed: 24" not in test:
        errors.append("runtime success marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-089" if ns.allow_downstream_package else "BP-084",
        "downstream_package": ns.allow_downstream_package,
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
        print("  status=black_port_source_109_frozen_v1 fingerprint=0x309b0737 functions=1094 missing=0")
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
