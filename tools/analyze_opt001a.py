#!/usr/bin/env python3
"""Aggregate MiniQuake optimization baseline artifacts for any delivery prefix."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

MAPS = ("e1m1", "e1m2")
MODES = ("headless", "render")


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for block in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def artifact(build: Path, prefix: str, suffix: str) -> Path:
    return build / f"{prefix}-{suffix}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--build", required=True)
    parser.add_argument("--json", required=True)
    parser.add_argument("--markdown", required=True)
    parser.add_argument("--prefix", default="opt001a")
    parser.add_argument("--next-revision", default="OPT-001B")
    args = parser.parse_args()

    build = Path(args.build).resolve()
    prefix = args.prefix.strip()
    if not prefix:
        parser.error("--prefix must not be empty")

    errors: list[str] = []
    maps: dict[str, Any] = {}

    for map_name in MAPS:
        entry: dict[str, Any] = {}
        parse_path = artifact(build, prefix, f"{map_name}-map-parse.json")
        if not parse_path.is_file():
            errors.append(f"missing map parse report: {parse_path.name}")
        else:
            entry["parse"] = load_json(parse_path)

        trace_a = artifact(build, prefix, f"{map_name}-trace-a.mqtrace")
        trace_b = artifact(build, prefix, f"{map_name}-trace-b.mqtrace")
        if not trace_a.is_file() or not trace_b.is_file():
            errors.append(f"missing trace pair for {map_name}")
        else:
            hash_a = sha256(trace_a)
            hash_b = sha256(trace_b)
            entry["trace"] = {
                "sha256_a": hash_a,
                "sha256_b": hash_b,
                "byte_identical": hash_a == hash_b,
            }
            if hash_a != hash_b:
                errors.append(f"trace pair differs for {map_name}")

        for mode in MODES:
            summary_path = artifact(build, prefix, f"{map_name}-{mode}-summary.json")
            if not summary_path.is_file():
                errors.append(f"missing frame baseline: {summary_path.name}")
            else:
                entry[mode] = load_json(summary_path)
        maps[map_name] = entry

    plateau_path = artifact(build, prefix, "listen-handle-plateau-summary.json")
    plateau: dict[str, Any] = {}
    if not plateau_path.is_file():
        errors.append("missing listen-server handle plateau summary")
    else:
        plateau = load_json(plateau_path)
    classification = str(plateau.get("classification", "UNKNOWN"))
    if classification not in {"STABLE", "PLATEAU"}:
        errors.append(f"handle classification is {classification}")

    comparisons: dict[str, Any] = {}
    if all(
        map_name in maps
        and "headless" in maps[map_name]
        and "render" in maps[map_name]
        for map_name in MAPS
    ):
        for mode in MODES:
            e1m1 = maps["e1m1"][mode]
            e1m2 = maps["e1m2"][mode]
            comparisons[mode] = {
                "e1m1_median_ms": e1m1.get("median_ms"),
                "e1m2_median_ms": e1m2.get("median_ms"),
                "e1m1_p99_ms": e1m1.get("p99_ms"),
                "e1m2_p99_ms": e1m2.get("p99_ms"),
            }

    status = "PASS" if not errors else "FAIL"
    report = {
        "schema": "MiniQuakeOptimizationBaselineSummary/2",
        "status": status,
        "prefix": prefix,
        "errors": errors,
        "handle_classification": classification,
        "maps": maps,
        "comparisons": comparisons,
        "next_revision": args.next_revision,
    }
    Path(args.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# MiniQuake optimization baseline",
        "",
        f"- Status: **{status}**",
        f"- Artifact prefix: `{prefix}`",
        f"- Handle classification: **{classification}**",
        "",
        "## Map matrix",
        "",
        "| Map | Faces | Leafs | Marksurfaces | Trace A/B | Headless Median/P99 | Render Median/P99 |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    for map_name in MAPS:
        entry = maps.get(map_name, {})
        parse = entry.get("parse", {})
        trace = entry.get("trace", {})
        headless = entry.get("headless", {})
        render = entry.get("render", {})
        lines.append(
            f"| {map_name} | {parse.get('faces', '?')} | {parse.get('leafs', '?')} | "
            f"{parse.get('mark_surfaces', '?')} | {'PASS' if trace.get('byte_identical') else 'FAIL'} | "
            f"{headless.get('median_ms', '?')}/{headless.get('p99_ms', '?')} ms | "
            f"{render.get('median_ms', '?')}/{render.get('p99_ms', '?')} ms |"
        )
    lines += [
        "",
        "## Handle timeline",
        "",
        f"- Sequence: `{plateau.get('handle_sequence', 'unknown')}`",
        f"- Non-handle resources stable: `{plateau.get('non_handle_stable', 'unknown')}`",
        f"- Classification: **{classification}**",
        "",
        "## Errors",
        "",
    ]
    lines.extend(f"- {error}" for error in errors) if errors else lines.append("- None.")
    lines += ["", "## Next revision", "", f"`{args.next_revision}`", ""]
    Path(args.markdown).write_text("\n".join(lines), encoding="utf-8")

    print("MiniQuake optimization aggregate analysis")
    print(f"  prefix={prefix}")
    print(f"  handle_classification={classification}")
    for map_name in MAPS:
        entry = maps.get(map_name, {})
        for mode in MODES:
            summary = entry.get(mode, {})
            if summary:
                print(
                    f"  {map_name}_{mode}: median={summary.get('median_ms')} "
                    f"p95={summary.get('p95_ms')} p99={summary.get('p99_ms')} "
                    f"max={summary.get('max_ms')}"
                )
    print(f"  result={status}")
    return 0 if status == "PASS" else 2


if __name__ == "__main__":
    raise SystemExit(main())
