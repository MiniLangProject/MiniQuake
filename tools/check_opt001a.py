#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Static OPT-001A source and delivery contract checks."""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

def require(text: str, markers: list[str], label: str, errors: list[str]) -> None:
    """Require require and record a clear failure otherwise."""
    for marker in markers:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    main_ml = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    host_ml = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    diag_ml = (root / "src/miniquake/compat_diagnostics.ml").read_text(encoding="utf-8-sig")
    opt_ml = (root / "src/miniquake/optimization_baseline.ml").read_text(encoding="utf-8-sig")
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    test_ps1 = (root / "scripts" / "TEST_OPT-001A.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "scripts" / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    contract = (root / "tests/opt001a_contract_tests.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/opt001a_baseline_golden.json").read_text(encoding="utf-8-sig"))
    if golden.get("fingerprint") != "0x1a001a01":
        errors.append("OPT-001A golden fingerprint mismatch")
    if golden.get("handle_windows", 0) < 3:
        errors.append("OPT-001A golden requires fewer than three handle windows")

    require(main_ml, [
        "--opt001a-map-parse",
        "--opt001a-frame-baseline",
        "--opt001a-handle-plateau",
        "Optimization status:",
    ], "main", errors)
    require(host_ml, [
        "function opt001aMapParse(",
        "function runOpt001AFrameBaseline(",
        "function runOpt001AHandlePlateau(",
        "plateau_progress=",
        "process_handles=",
    ], "host", errors)
    require(diag_ml, [
        "import miniquake.optimization_baseline as optBaseline",
        "optBaseline.beginFrame()",
        "optBaseline.checkpoint(stage)",
        "optBaseline.completeFrame()",
    ], "compat diagnostics", errors)
    require(opt_ml, [
        'return "PLATEAU"',
        'return "LEAK"',
        'return "RESOURCE_GROWTH"',
        "median_ms",
        "p95_ms",
        "p99_ms",
        "stage_totals",
    ], "optimization baseline", errors)
    require(build_info, [
        'const OPTIMIZATION_STATUS = "opt001a_baseline_candidate_v1"',
        "const OPTIMIZATION_FINGERPRINT = 0x1a001a01",
        'const OPTIMIZATION_PARENT = "BP-090-094R15"',
    ], "build info", errors)
    require(test_ps1, [
        '$DeliveryRevision = "OPT-001A"',
        "MiniQuake OPT-001A acceptance test: PASS",
        "--opt001a-map-parse",
        "--opt001a-frame-baseline",
        "--opt001a-handle-plateau",
        "HandleWindows",
        "BenchmarkFrames",
        "ContinueIndependentTests",
    ], "OPT runner", errors)
    require(collector, [
        '$DeliveryRevision = "OPT-001A"',
        "MiniQuake_OPT-001A_RESULTS_",
        "opt001a",
    ], "collector", errors)
    require(contract, [
        '== "STABLE"',
        '== "PLATEAU"',
        '== "LEAK"',
        '== "RESOURCE_GROWTH"',
        "MiniQuake OPT-001A contract tests passed:",
    ], "contract tests", errors)

    entities = (root / "src/miniquake/render/entities.ml").read_text(encoding="utf-8-sig")
    if "gl.depthRange(0.0, renderUiContract.viewModelDepthMaximum())" not in entities or "gl.depthRange(0.0, 1.0)" not in entities:
        errors.append("OPT-001A must retain the pre-fix fixed viewmodel depth-range baseline")
    world = (root / "src/miniquake/render/world.ml").read_text(encoding="utf-8-sig")
    if "faceUnderwater" not in world:
        errors.append("OPT-001A must retain the pre-fix underwater-face baseline")
    if not re.search(r"profileEnabled\s*=\s*false", opt_ml):
        errors.append("optimization profiling is not disabled by default")

    report = {
        "schema": "MiniQuakeOPT001AStatic/1",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "checks": {
            "diagnostic_only": True,
            "handle_windows_minimum": 3,
            "frame_percentiles": ["median", "p95", "p99", "max"],
            "maps": ["e1m1", "e1m2"],
        },
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake OPT-001A verification: " + report["status"])
    if errors:
        for err in errors:
            print("  error: " + err)
        return 1
    print("  diagnostic_only=true")
    print("  handle_windows>=3")
    print("  maps=e1m1,e1m2")
    print("  percentiles=median,p95,p99,max")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
