#!/usr/bin/env python3
"""Validate agent semantic reviews for every GLQuake target logical unit.

This is an audit of review completeness, not a replacement for differential
tests or end-to-end parity gates.  A passing record states that an agent
inspected all target functions and the behavior groups listed in the record.
The generator cross-checks file/module identities against the pinned inventory
and rejects reviews with open findings or incomplete evidence.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path
from typing import Any, NoReturn


ROOT = Path(__file__).resolve().parents[1]
INVENTORY_PATH = ROOT / "audit" / "GLQUAKE_PORT_INVENTORY.json"
PLAN_PATH = ROOT / "audit" / "SEMANTIC_AUDIT_PLAN.json"
REVIEWS_DIR = ROOT / "audit" / "semantic_reviews"
JSON_PATH = ROOT / "audit" / "SEMANTIC_PORT_REVIEW.json"
MARKDOWN_PATH = ROOT / "docs" / "SEMANTIC_PORT_REVIEW.md"
SCHEMA = "miniquake.semantic-port-review.v1"
REFERENCE_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
ALLOWED_FEATURE_STATUSES = {
    "parity",
    "documented-platform-bridge",
    "documented-exclusion",
}


def fail(message: str) -> NoReturn:
    raise SystemExit(f"semantic review generation failed: {message}")


def string_list(value: Any, field: str, path: Path, *, nonempty: bool) -> list[str]:
    if not isinstance(value, list) or not all(
        isinstance(item, str) and item.strip() for item in value
    ):
        fail(f"{path.relative_to(ROOT)} has invalid {field}")
    if nonempty and not value:
        fail(f"{path.relative_to(ROOT)} has empty {field}")
    return value


def hash_map(value: Any, field: str, path: Path) -> dict[str, str]:
    if not isinstance(value, dict):
        fail(f"{path.relative_to(ROOT)} has invalid {field}")
    result: dict[str, str] = {}
    for key, digest in value.items():
        if (
            not isinstance(key, str)
            or not key
            or not isinstance(digest, str)
            or len(digest) != 64
            or any(character not in "0123456789abcdef" for character in digest)
        ):
            fail(f"{path.relative_to(ROOT)} has invalid {field} entry")
        result[key] = digest
    return result


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def inventory_units() -> dict[str, dict[str, Any]]:
    if not INVENTORY_PATH.is_file():
        fail("missing audit/GLQUAKE_PORT_INVENTORY.json")
    payload = json.loads(INVENTORY_PATH.read_text(encoding="utf-8"))
    result: dict[str, dict[str, Any]] = {}
    for unit in payload.get("units", []):
        if unit.get("scope") != "target":
            continue
        name = unit.get("unit")
        if not isinstance(name, str) or name in result:
            fail("inventory contains an invalid or duplicate target unit")
        result[name] = unit
    if not result:
        fail("inventory contains no target logical units")
    return result


def validate_plan(inventory: dict[str, dict[str, Any]]) -> dict[str, Any]:
    if not PLAN_PATH.is_file():
        fail("missing audit/SEMANTIC_AUDIT_PLAN.json")
    payload = json.loads(PLAN_PATH.read_text(encoding="utf-8"))
    if payload.get("schema") != "miniquake.semantic-audit-plan.v1":
        fail("semantic audit plan has wrong schema")
    if payload.get("reference_commit") != REFERENCE_COMMIT:
        fail("semantic audit plan has wrong reference commit")
    assignments: dict[str, dict[str, Any]] = {}
    seen_waves: set[int] = set()
    for wave in payload.get("waves", []):
        number = wave.get("wave")
        if not isinstance(number, int) or number < 1 or number in seen_waves:
            fail("semantic audit plan has invalid or duplicate wave")
        seen_waves.add(number)
        if wave.get("status") not in {"queued", "running", "complete"}:
            fail(f"semantic audit wave {number} has invalid status")
        for assignment in wave.get("assignments", []):
            agent = assignment.get("agent")
            units = assignment.get("units")
            if not isinstance(agent, str) or not agent.strip():
                fail(f"semantic audit wave {number} has assignment without agent")
            if not isinstance(units, list) or not units:
                fail(f"semantic audit assignment {agent} has no units")
            for unit in units:
                if unit not in inventory:
                    fail(f"semantic audit plan assigns unknown unit {unit!r}")
                if unit in assignments:
                    fail(
                        f"semantic audit plan assigns {unit} twice "
                        f"({assignments[unit]['agent']} and {agent})"
                    )
                assignments[unit] = {
                    "wave": number,
                    "agent": agent,
                    "wave_status": wave["status"],
                }
    missing = sorted(set(inventory) - set(assignments))
    if missing:
        fail("semantic audit plan omits target units: " + ", ".join(missing))
    return {
        "path": PLAN_PATH.relative_to(ROOT).as_posix(),
        "waves": len(seen_waves),
        "assignments": assignments,
    }


def validate_review(
    path: Path, payload: dict[str, Any], inventory: dict[str, dict[str, Any]]
) -> dict[str, Any]:
    if payload.get("schema") != SCHEMA:
        fail(f"{path.relative_to(ROOT)} has wrong schema")
    unit_name = payload.get("unit")
    if unit_name not in inventory:
        fail(f"{path.relative_to(ROOT)} names unknown target unit {unit_name!r}")
    if path.stem != unit_name:
        fail(f"{path.relative_to(ROOT)} filename must be {unit_name}.json")
    if payload.get("reference_commit") != REFERENCE_COMMIT:
        fail(f"{path.relative_to(ROOT)} has wrong reference commit")
    reviewer = payload.get("reviewer")
    if not isinstance(reviewer, str) or not reviewer.strip():
        fail(f"{path.relative_to(ROOT)} lacks a reviewer")
    if payload.get("function_review_scope") != "all-target-functions":
        fail(f"{path.relative_to(ROOT)} does not review all target functions")

    expected_originals = sorted(
        item["path"] for item in inventory[unit_name]["original_files"]
    )
    expected_modules = sorted(
        item["path"] for item in inventory[unit_name]["minilang_modules"]
    )
    originals = sorted(
        string_list(payload.get("original_files"), "original_files", path, nonempty=True)
    )
    modules = sorted(
        string_list(
            payload.get("minilang_modules"),
            "minilang_modules",
            path,
            nonempty=True,
        )
    )
    if originals != expected_originals:
        fail(
            f"{path.relative_to(ROOT)} original_files differ from pinned inventory"
        )
    if modules != expected_modules:
        fail(
            f"{path.relative_to(ROOT)} minilang_modules differ from current inventory"
        )
    expected_original_hashes = {
        item["path"]: item["sha256"]
        for item in inventory[unit_name]["original_files"]
    }
    expected_module_hashes = {
        item["path"]: item["sha256"]
        for item in inventory[unit_name]["minilang_modules"]
    }
    current_original_hashes = {
        relative: file_sha256(ROOT / "reference" / "quake" / "WinQuake" / relative)
        for relative in expected_originals
    }
    current_module_hashes = {
        relative: file_sha256(ROOT / relative) for relative in expected_modules
    }
    if expected_original_hashes != current_original_hashes:
        fail(f"{path.relative_to(ROOT)} pinned inventory original hashes are stale")
    if expected_module_hashes != current_module_hashes:
        fail(f"{path.relative_to(ROOT)} port inventory MiniLang hashes are stale")
    if hash_map(payload.get("original_sha256"), "original_sha256", path) != (
        expected_original_hashes
    ):
        fail(f"{path.relative_to(ROOT)} original source hashes are stale")
    if hash_map(payload.get("minilang_sha256"), "minilang_sha256", path) != (
        expected_module_hashes
    ):
        fail(f"{path.relative_to(ROOT)} MiniLang source hashes are stale")

    features = payload.get("features")
    if not isinstance(features, list) or not features:
        fail(f"{path.relative_to(ROOT)} has no reviewed behavior features")
    feature_names: set[str] = set()
    feature_statuses: Counter[str] = Counter()
    for index, feature in enumerate(features):
        if not isinstance(feature, dict):
            fail(f"{path.relative_to(ROOT)} feature {index} is not an object")
        name = feature.get("name")
        if not isinstance(name, str) or not name.strip() or name in feature_names:
            fail(f"{path.relative_to(ROOT)} feature {index} has invalid/duplicate name")
        feature_names.add(name)
        status = feature.get("status")
        if status not in ALLOWED_FEATURE_STATUSES:
            fail(f"{path.relative_to(ROOT)} feature {name!r} has invalid status")
        feature_statuses[status] += 1
        string_list(feature.get("original"), f"feature {name} original", path, nonempty=True)
        string_list(feature.get("minilang"), f"feature {name} minilang", path, nonempty=True)
        string_list(feature.get("evidence"), f"feature {name} evidence", path, nonempty=True)

    commands = string_list(payload.get("commands"), "commands", path, nonempty=True)
    findings = string_list(
        payload.get("open_findings"), "open_findings", path, nonempty=False
    )
    limitations = string_list(
        payload.get("limitations"), "limitations", path, nonempty=False
    )
    counts = inventory[unit_name]["function_counts"]
    target_functions = sum(
        int(value) for key, value in counts.items() if key != "excluded"
    )
    assembly_counts = inventory[unit_name]["assembly_export_counts"]
    target_assembly = sum(
        int(value) for key, value in assembly_counts.items() if key != "excluded"
    )
    return {
        "unit": unit_name,
        "reviewer": reviewer,
        "status": "pass" if not findings else "open",
        "target_functions_reviewed": target_functions if not findings else 0,
        "target_assembly_exports_reviewed": target_assembly if not findings else 0,
        "features": len(features),
        "feature_statuses": dict(sorted(feature_statuses.items())),
        "commands": commands,
        "open_findings": findings,
        "limitations": limitations,
        "record": path.relative_to(ROOT).as_posix(),
    }


def build_report(*, require_complete: bool) -> dict[str, Any]:
    inventory = inventory_units()
    plan = validate_plan(inventory)
    records: dict[str, dict[str, Any]] = {}
    for path in sorted(REVIEWS_DIR.glob("*.json")):
        payload = json.loads(path.read_text(encoding="utf-8"))
        record = validate_review(path, payload, inventory)
        if record["unit"] in records:
            fail(f"duplicate review for {record['unit']}")
        records[record["unit"]] = record

    missing = sorted(set(inventory) - set(records))
    open_units = sorted(
        name for name, record in records.items() if record["status"] != "pass"
    )
    if require_complete and (missing or open_units):
        details = []
        if missing:
            details.append("missing: " + ", ".join(missing))
        if open_units:
            details.append("open: " + ", ".join(open_units))
        fail("; ".join(details))

    target_functions = sum(
        int(unit["function_counts"].get(key, 0))
        for unit in inventory.values()
        for key in ("located", "candidate", "unmapped")
    )
    target_assembly = sum(
        int(unit["assembly_export_counts"].get(key, 0))
        for unit in inventory.values()
        for key in ("located", "candidate", "unmapped")
    )
    passing = [record for record in records.values() if record["status"] == "pass"]
    reviewed_functions = sum(
        record["target_functions_reviewed"] for record in passing
    )
    reviewed_assembly = sum(
        record["target_assembly_exports_reviewed"] for record in passing
    )
    return {
        "schema": "miniquake.semantic-port-review-report.v1",
        "reference_commit": REFERENCE_COMMIT,
        "policy": (
            "Manual agent branch/feature review completeness. This supplements "
            "but does not replace differential and end-to-end parity evidence."
        ),
        "plan": {
            "path": plan["path"],
            "waves": plan["waves"],
            "assigned_units": len(plan["assignments"]),
        },
        "summary": {
            "target_units": len(inventory),
            "reviewed_units": len(passing),
            "unit_review_percent": round(100.0 * len(passing) / len(inventory), 6),
            "target_function_definitions": target_functions,
            "reviewed_function_definitions": reviewed_functions,
            "function_review_percent": round(
                100.0 * reviewed_functions / target_functions, 6
            )
            if target_functions
            else 100.0,
            "target_assembly_exports": target_assembly,
            "reviewed_assembly_exports": reviewed_assembly,
            "missing_units": len(missing),
            "open_units": len(open_units),
        },
        "missing_units": missing,
        "open_units": open_units,
        "reviews": [records[name] for name in sorted(records)],
    }


def render_markdown(report: dict[str, Any]) -> str:
    summary = report["summary"]
    lines = [
        "# Semantic GLQuake port review",
        "",
        "This report tracks agent source reviews of complete logical units. It is "
        "separate from name mapping, differential fixtures, and end-to-end gates.",
        "",
        "## Summary",
        "",
        f"- Reviewed logical units: **{summary['reviewed_units']}/{summary['target_units']} "
        f"({summary['unit_review_percent']:.6f} %)**",
        f"- Functions inside passing unit reviews: "
        f"**{summary['reviewed_function_definitions']}/"
        f"{summary['target_function_definitions']} "
        f"({summary['function_review_percent']:.6f} %)**",
        f"- Assembly exports inside passing unit reviews: "
        f"**{summary['reviewed_assembly_exports']}/"
        f"{summary['target_assembly_exports']}**",
        f"- Missing unit reviews: **{summary['missing_units']}**",
        f"- Reviews with open findings: **{summary['open_units']}**",
        "",
        "A passing review is an inspection record, not by itself behavioral proof. "
        "The strict differential and process-wide gates remain independently required.",
        "",
        "## Units",
        "",
        "| Unit | Status | Reviewer | Features | Limitations |",
        "|---|---|---|---:|---:|",
    ]
    by_name = {record["unit"]: record for record in report["reviews"]}
    for name in sorted(set(by_name) | set(report["missing_units"])):
        record = by_name.get(name)
        if record is None:
            lines.append(f"| `{name}` | missing | — | 0 | 0 |")
        else:
            lines.append(
                f"| `{name}` | {record['status']} | {record['reviewer']} | "
                f"{record['features']} | {len(record['limitations'])} |"
            )
    if report["open_units"]:
        lines.extend(["", "## Open findings", ""])
        for name in report["open_units"]:
            record = by_name[name]
            for finding in record["open_findings"]:
                lines.append(f"- `{name}`: {finding}")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--require-complete",
        action="store_true",
        help="fail unless all target units have passing reviews",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="validate existing generated files without rewriting them",
    )
    args = parser.parse_args()
    report = build_report(require_complete=args.require_complete)
    rendered_json = json.dumps(report, indent=2, sort_keys=False) + "\n"
    rendered_markdown = render_markdown(report)
    if args.check:
        if not JSON_PATH.is_file() or JSON_PATH.read_text(encoding="utf-8") != rendered_json:
            fail(f"{JSON_PATH.relative_to(ROOT)} is stale")
        if (
            not MARKDOWN_PATH.is_file()
            or MARKDOWN_PATH.read_text(encoding="utf-8") != rendered_markdown
        ):
            fail(f"{MARKDOWN_PATH.relative_to(ROOT)} is stale")
    else:
        JSON_PATH.write_text(rendered_json, encoding="utf-8", newline="\n")
        MARKDOWN_PATH.write_text(rendered_markdown, encoding="utf-8", newline="\n")
    print(
        "semantic review: "
        f"{report['summary']['reviewed_units']}/"
        f"{report['summary']['target_units']} units, "
        f"{report['summary']['reviewed_function_definitions']}/"
        f"{report['summary']['target_function_definitions']} functions"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
