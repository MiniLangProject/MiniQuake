#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Compare OPT-001C frame baselines with the accepted OPT-001B baseline."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from statistics import mean
from typing import Any

MAPS = ("e1m1", "e1m2")
MODES = ("headless", "render")
FIELDS = ("total_ms", "median_ms", "p95_ms", "p99_ms", "max_ms")


def load_json(path: Path) -> dict[str, Any]:
    """Load and decode one UTF-8 JSON document."""
    return json.loads(path.read_text(encoding="utf-8-sig"))


def percentage_improvement(old: float, new: float) -> float:
    """Compute the percentage improvement from baseline to candidate."""
    if old <= 0:
        return 0.0
    return (old - new) * 100.0 / old


def ratio(old: float, new: float) -> float:
    """Compute a guarded candidate-to-baseline ratio."""
    if new <= 0:
        return 0.0
    return old / new


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", required=True)
    parser.add_argument("--build", required=True)
    parser.add_argument("--json", required=True)
    parser.add_argument("--markdown", required=True)
    parser.add_argument("--prefix", default="opt001c")
    args = parser.parse_args()

    baseline_path = Path(args.baseline).resolve()
    build = Path(args.build).resolve()
    output_json = Path(args.json).resolve()
    output_markdown = Path(args.markdown).resolve()
    prefix = args.prefix.strip()
    if not prefix:
        parser.error("--prefix must not be empty")
    baseline = load_json(baseline_path)
    targets = baseline["targets"]
    regression_limit = float(targets["regression_limit_percent"])

    errors: list[str] = []
    comparisons: dict[str, dict[str, Any]] = {}
    regression_reasons: list[str] = []
    render_median_improvements: list[float] = []
    render_p99_improvements: list[float] = []
    render_throughput_ratios: list[float] = []

    for map_name in MAPS:
        comparisons[map_name] = {}
        for mode in MODES:
            current_path = build / f"{prefix}-{map_name}-{mode}-summary.json"
            if not current_path.is_file():
                errors.append(f"missing current summary: {current_path}")
                continue
            current = load_json(current_path)
            reference = baseline["maps"][map_name][mode]
            entry: dict[str, Any] = {
                "baseline_file": baseline_path.name,
                "current_file": current_path.name,
                "baseline": {field: reference[field] for field in FIELDS},
                "current": {field: current[field] for field in FIELDS},
                "improvement_percent": {},
            }
            for field in FIELDS:
                improvement = percentage_improvement(float(reference[field]), float(current[field]))
                entry["improvement_percent"][field] = improvement
                if field in ("median_ms", "p99_ms") and improvement < -regression_limit:
                    regression_reasons.append(
                        f"{map_name}/{mode}/{field} regressed by {-improvement:.3f}% "
                        f"({reference[field]} -> {current[field]})"
                    )
            throughput = ratio(float(reference["total_ms"]), float(current["total_ms"]))
            entry["throughput_ratio"] = throughput
            entry["frames"] = int(current.get("frames", 0))
            comparisons[map_name][mode] = entry
            if mode == "render":
                render_median_improvements.append(entry["improvement_percent"]["median_ms"])
                render_p99_improvements.append(entry["improvement_percent"]["p99_ms"])
                render_throughput_ratios.append(throughput)

    classification = "REGRESSION"
    aggregate: dict[str, float] = {}
    if not errors and len(render_median_improvements) == len(MAPS):
        aggregate = {
            "render_median_improvement_percent": mean(render_median_improvements),
            "render_p99_improvement_percent": mean(render_p99_improvements),
            "render_throughput_ratio": mean(render_throughput_ratios),
        }
        median_target = float(targets["median_improvement_percent"])
        throughput_target = float(targets["throughput_ratio"])
        p99_target = float(targets["p99_improvement_percent"])
        target_met = (
            (
                aggregate["render_median_improvement_percent"] >= median_target
                or aggregate["render_throughput_ratio"] >= throughput_target
            )
            and aggregate["render_p99_improvement_percent"] >= p99_target
        )
        if regression_reasons:
            classification = "REGRESSION"
        elif target_met:
            classification = "TARGET_MET"
        elif (
            aggregate["render_median_improvement_percent"] > 2.0
            or aggregate["render_p99_improvement_percent"] > 2.0
            or aggregate["render_throughput_ratio"] > 1.02
        ):
            classification = "IMPROVED_BELOW_TARGET"
        else:
            classification = "NO_REGRESSION_BELOW_TARGET"

    status = "PASS"
    if errors or regression_reasons:
        status = "FAIL"
    report = {
        "schema": "MiniQuakeOPT001CPerformanceComparison/1",
        "status": status,
        "classification": classification,
        "current_prefix": prefix,
        "baseline_revision": baseline.get("source_revision"),
        "baseline_archive": baseline.get("source_result_archive"),
        "baseline_archive_sha256": baseline.get("source_result_sha256"),
        "targets": targets,
        "aggregate": aggregate,
        "comparisons": comparisons,
        "regression_reasons": regression_reasons,
        "errors": errors,
    }
    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# MiniQuake OPT-001C – Performancevergleich",
        "",
        f"- Status: **{status}**",
        f"- Klassifikation: **{classification}**",
        f"- Current artifact prefix: `{prefix}`",
        f"- Baseline: `{baseline.get('source_revision')}` / `{baseline.get('source_result_archive')}`",
        "",
        "| Map | Modus | Median alt → neu | Median Δ | P99 alt → neu | P99 Δ | Durchsatzfaktor |",
        "|---|---|---:|---:|---:|---:|---:|",
    ]
    for map_name in MAPS:
        for mode in MODES:
            entry = comparisons.get(map_name, {}).get(mode)
            if not entry:
                continue
            b = entry["baseline"]
            c = entry["current"]
            imp = entry["improvement_percent"]
            lines.append(
                f"| `{map_name}` | `{mode}` | {b['median_ms']} → {c['median_ms']} ms | "
                f"{imp['median_ms']:.3f}% | {b['p99_ms']} → {c['p99_ms']} ms | "
                f"{imp['p99_ms']:.3f}% | {entry['throughput_ratio']:.4f}× |"
            )
    if aggregate:
        lines += [
            "",
            "## Aggregierte Renderwerte",
            "",
            f"- Median-Verbesserung: **{aggregate['render_median_improvement_percent']:.3f}%**",
            f"- P99-Verbesserung: **{aggregate['render_p99_improvement_percent']:.3f}%**",
            f"- Durchsatzfaktor: **{aggregate['render_throughput_ratio']:.4f}×**",
        ]
    if regression_reasons:
        lines += ["", "## Regressionen", ""] + [f"- {reason}" for reason in regression_reasons]
    if errors:
        lines += ["", "## Fehler", ""] + [f"- {error}" for error in errors]
    output_markdown.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("MiniQuake OPT-001C performance comparison: " + classification)
    print(f"  current_prefix={prefix}")
    if aggregate:
        print(
            "  render_median_improvement_percent="
            f"{aggregate['render_median_improvement_percent']:.3f}"
        )
        print(
            "  render_p99_improvement_percent="
            f"{aggregate['render_p99_improvement_percent']:.3f}"
        )
        print(f"  render_throughput_ratio={aggregate['render_throughput_ratio']:.4f}")
    for reason in regression_reasons:
        print("  regression: " + reason)
    for error in errors:
        print("  error: " + error)
    return 0 if status == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
