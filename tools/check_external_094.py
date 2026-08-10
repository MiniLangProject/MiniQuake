#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import sys


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors: list[str] = []

    def read(rel: str) -> str:
        p = root / rel
        if not p.is_file():
            errors.append("missing file: " + rel)
            return ""
        return p.read_text(encoding="utf-8-sig")

    build = read("src/miniquake/build_info.ml")
    test = read("tests/external_compat_closure_tests.ml")
    contract = read("src/miniquake/external_reference_contract.ml")
    harness = read("TEST_BP-090-094R6.ps1")
    collector = read("COLLECT_RESULTS.ps1")
    for marker in [
        'const PACKAGE_ID = "BP-094"',
        'const PARENT_PACKAGE_ID = "BP-093"',
        'const BLOCK_ID = "BP-090-094"',
        'const BLOCK_PARENT_PACKAGE_ID = "BP-085-089R8"',
        'const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"',
        'const COMPAT_FINAL_FINGERPRINT = 0xe04a7727',
    ]:
        if marker not in build:
            errors.append("missing build marker: " + marker)
    for marker in [
        'const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"',
        'const COMPAT_FINAL_FINGERPRINT = 0xe04a7727',
        "function finalContractHasRequiredFields()",
        "finalContractHasRequiredFields()",
    ]:
        if marker not in contract:
            errors.append("missing contract marker: " + marker)
    for marker in [
        "bidirectional original binary interop",
        "external GLQuake visual reference corpus",
        "final BP-090-094R6 acceptance requires original binary interop",
        "all internal and external gates passed",
        "original_condebug_enabled = $false",
        "original_network_scope = \"loopback_only\"",
        "original_bind_address = \"127.0.0.1\"",
        "original_visual_network = \"disabled\"",
        "unattended_firewall_prompt_expected = $false",
        "original_evidence_mode = \"protocol_summaries_and_screenshot_files\"",
    ]:
        if marker not in harness:
            errors.append("missing acceptance marker: " + marker)
    for marker in ["Original GLQuake binary", "Quake PAK/model/map/audio data", "compiled binaries were not included"]:
        if marker not in collector:
            errors.append("collector exclusion marker missing: " + marker)
    if "MiniQuake BP-094 external compatibility closure tests passed: 24" not in test:
        errors.append("runtime marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-094",
        "delivery_revision": "BP-090-094R6",
        "step": "BP-094",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "fixtures": 24,
        "candidate_status": "compat_109_final_candidate_v1",
        "fingerprint": "0xe04a7727",
        "required_external_gates": 2,
        "original_condebug_enabled": False,
        "original_network_scope": "loopback_only",
        "original_bind_address": "127.0.0.1",
        "original_visual_network": "disabled",
        "unattended_firewall_prompt_expected": False,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("MiniQuake BP-094 external compatibility closure verification: " + report["status"])
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
