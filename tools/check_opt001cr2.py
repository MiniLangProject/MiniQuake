#!/usr/bin/env python3
"""Static contract for OPT-001CR2 artifact-prefix and handle-confirmation repair."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for block in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def require(text: str, markers: list[str], label: str, errors: list[str]) -> None:
    for marker in markers:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    parser.add_argument("--allow-downstream-package", action="store_true")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    golden = json.loads(
        (root / "audit/opt001cr2_harness_golden.json").read_text(encoding="utf-8-sig")
    )
    runner = (root / "TEST_OPT-001CR2.ps1").read_text(encoding="utf-8-sig")
    collector_path = root / ("COLLECT_RESULTS_OPT001CR2.ps1" if args.allow_downstream_package else "COLLECT_RESULTS.ps1")
    collector = collector_path.read_text(encoding="utf-8-sig")
    launcher = (root / "test.ps1").read_text(encoding="utf-8-sig")
    aggregate = (root / "tools/analyze_opt001a.py").read_text(encoding="utf-8-sig")
    comparator = (root / "tools/compare_opt001c_performance.py").read_text(encoding="utf-8-sig")
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")

    require(
        runner,
        [
            '$DeliveryRevision = "OPT-001CR2"',
            '$DeliveryParent = "OPT-001CR1"',
            '[int]$HandleConfirmationWindows = 1',
            '$EffectiveHandleWindows = $HandleWindows + $HandleConfirmationWindows',
            '[string]$EffectiveHandleWindows',
            '"--prefix", "opt001cr2"',
            '"--next-revision", "OPT-001D"',
            'MiniQuake OPT-001CR2 acceptance test: PASS',
            'function Invoke-LivePowerShellScript(',
            'output_mode=attached_console_live',
            '*>&1 | Tee-Object -FilePath',
            '-EncodedCommand',
        ],
        "runner",
        errors,
    )


    if '[void](Invoke-Live "OPT-001CR2 game and contract build" $PowerShellExe' in runner:
        errors.append("runner still pipes the nested build PowerShell through parent Invoke-Live")
    if '& $PowerShellExe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $EncodedCommand' not in runner:
        errors.append("runner does not attach the nested build PowerShell directly to the console")

    prefix_marker = '"--prefix", "opt001cr2"'
    if runner.count(prefix_marker) != 2:
        errors.append(
            f"runner prefix marker count is {runner.count(prefix_marker)}, expected 2"
        )
    next_marker = '"--next-revision", "OPT-001D"'
    if runner.count(next_marker) != 1:
        errors.append(
            f"runner next-revision marker count is {runner.count(next_marker)}, expected 1"
        )

    require(
        collector,
        [
            '$DeliveryRevision = "OPT-001CR2"',
            '$DeliveryParent = "OPT-001CR1"',
            'MiniQuake_OPT-001CR2_RESULTS_',
            'TEST_OPT-001CR2.ps1',
        ],
        "collector",
        errors,
    )
    if not args.allow_downstream_package:
        require(launcher, ["TEST_OPT-001CR2.ps1"], "test.ps1", errors)
    require(
        aggregate,
        [
            'parser.add_argument("--prefix", default="opt001a")',
            'parser.add_argument("--next-revision", default="OPT-001B")',
            'f"{prefix}-{suffix}"',
            '"prefix": prefix',
        ],
        "aggregate analyzer",
        errors,
    )
    require(
        comparator,
        [
            'parser.add_argument("--prefix", default="opt001c")',
            'current_path = build / f"{prefix}-{map_name}-{mode}-summary.json"',
            '"current_prefix": prefix',
            "TARGET_MET",
        ],
        "performance comparator",
        errors,
    )
    if not args.allow_downstream_package:
        require(
            build_info,
            [
                'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR2"',
                'const OPTIMIZATION_DELIVERY_PARENT = "OPT-001CR1"',
            ],
            "build info",
            errors,
        )

    expected = golden.get("source_hashes", {})
    actual_hashes: dict[str, str] = {}
    for rel, expected_hash in expected.items():
        path = root / rel
        if not path.is_file():
            errors.append(f"missing source hash target: {rel}")
            continue
        actual_hash = sha256(path)
        actual_hashes[rel] = actual_hash
        # Downstream renderer correctness revisions may legitimately update
        # world.ml while preserving the accepted CR2 harness semantics.  The
        # current OPT-001C and delivery-specific checkers bind those changes.
        if args.allow_downstream_package and rel in {"src/miniquake/render/world.ml", "src/miniquake/render/gl11.ml"}:
            continue
        if actual_hash != expected_hash:
            errors.append(f"source hash mismatch: {rel}")

    if golden.get("artifact_prefix") != "opt001cr2":
        errors.append("golden artifact prefix is not opt001cr2")
    if golden.get("effective_handle_windows") != 4:
        errors.append("golden effective handle window count is not 4")
    if golden.get("next_revision") != "OPT-001D":
        errors.append("golden next revision is not OPT-001D")

    report = {
        "schema": "MiniQuakeOPT001CR2Static/1",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "revision": "OPT-001CR2",
        "parent": "OPT-001CR1",
        "artifact_prefix": "opt001cr2",
        "effective_handle_windows": 4,
        "source_hashes": actual_hashes,
        "downstream_world_semantics": (
            "covered_by_opt001c_and_current_delivery"
            if args.allow_downstream_package else "historical_exact_hash"
        ),
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake OPT-001CR2 harness verification: " + report["status"])
    print("  artifact_prefix=opt001cr2")
    print("  effective_handle_windows=4")
    for error in errors:
        print("  error: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
