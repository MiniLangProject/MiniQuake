#!/usr/bin/env python3
"""Generate the strict, function-level GLQuake behavioral-parity report.

Code-location coverage and behavioral proof are deliberately separate.  This
tool only counts evidence classifications that execute the pinned original
implementation or demonstrate direct, bidirectional compatibility with it.
Focused, Core, Milestone, Retail-smoke, and MiniQuake-only tests remain useful
regressions but do not increase the strict parity percentage.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
INVENTORY_TOOL = ROOT / "tools" / "generate_port_inventory.py"
SEMANTIC_REVIEW_TOOL = ROOT / "tools" / "generate_semantic_review.py"
JSON_PATH = ROOT / "audit" / "BEHAVIORAL_PARITY.json"
MARKDOWN_PATH = ROOT / "docs" / "BEHAVIORAL_PARITY.md"
MANIFEST_PATTERN = "*_differential_manifest.json"

COUNTED_CLASSIFICATIONS = {
    "reference-differential",
    "bidirectional-glquake-compatibility",
    "reference-artifact-byte-exact",
}
COUNTED_EXECUTION_MODELS = {
    "reference-differential": {
        "direct-pinned-source-build",
        "patched-pinned-source-worktree",
    },
    "bidirectional-glquake-compatibility": {
        "glquake-process-interop",
    },
    "reference-artifact-byte-exact": {
        "original-artifact",
    },
}


def fail(message: str) -> "NoReturn":
    raise SystemExit(f"behavioral parity generation failed: {message}")


def load_inventory() -> dict[str, Any]:
    spec = importlib.util.spec_from_file_location(
        "miniquake_port_inventory", INVENTORY_TOOL
    )
    if spec is None or spec.loader is None:
        fail(f"cannot import {INVENTORY_TOOL}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.build_report()


def load_semantic_reviews() -> tuple[dict[str, Any], set[str]]:
    spec = importlib.util.spec_from_file_location(
        "miniquake_semantic_review", SEMANTIC_REVIEW_TOOL
    )
    if spec is None or spec.loader is None:
        fail(f"cannot import {SEMANTIC_REVIEW_TOOL}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    report = module.build_report(require_complete=False)
    passing = {
        record["unit"]
        for record in report["reviews"]
        if record.get("status") == "pass"
    }
    return report, passing


def manifest_units(payload: dict[str, Any], path: Path) -> list[dict[str, Any]]:
    if isinstance(payload.get("units"), list):
        return payload["units"]
    if isinstance(payload.get("unit"), str) and isinstance(
        payload.get("functions"), list
    ):
        return [
            {
                "unit": payload["unit"],
                "reference_source": payload.get("reference_source")
                or payload.get("reference", {}).get("source"),
                "functions": payload["functions"],
                "events": payload.get("events"),
                "epsilon": payload.get("epsilon"),
            }
        ]
    # Legacy single-unit manifests used a subsystem-specific schema and did
    # not repeat the unit.  Accept the filename convention while requiring an
    # explicit function list.
    if isinstance(payload.get("functions"), list):
        stem = path.name.removesuffix("_differential_manifest.json")
        return [
            {
                "unit": stem,
                "reference_source": payload.get("reference", {}).get("source"),
                "functions": payload["functions"],
                "events": payload.get("events"),
                "epsilon": payload.get("epsilon"),
            }
        ]
    fail(f"{path.relative_to(ROOT)} has no units/functions")


def command_for(payload: dict[str, Any]) -> str | list[str] | None:
    command = payload.get("command")
    if command is not None:
        return command
    verification = payload.get("verification")
    if isinstance(verification, dict):
        return verification.get("command")
    return None


def run_manifest_command(command: str | list[str], path: Path) -> None:
    if isinstance(command, str):
        # Manifests contain repository-owned, reviewed commands.  Use the
        # platform shell so `python ...` remains portable to the documented
        # PowerShell workflow.
        result = subprocess.run(command, cwd=ROOT, shell=True, check=False)
    elif isinstance(command, list) and all(
        isinstance(part, str) for part in command
    ):
        result = subprocess.run(command, cwd=ROOT, shell=False, check=False)
    else:
        fail(f"{path.relative_to(ROOT)} has an invalid command")
    if result.returncode != 0:
        fail(
            f"{path.relative_to(ROOT)} verification command failed with "
            f"exit code {result.returncode}"
        )


def build_report(*, run_evidence: bool) -> dict[str, Any]:
    inventory = load_inventory()
    semantic_report, semantically_reviewed_units = load_semantic_reviews()
    target_definitions: Counter[tuple[str, str]] = Counter()
    source_locations: dict[tuple[str, str], list[str]] = defaultdict(list)
    for unit in inventory["units"]:
        for function in unit["functions"]:
            if not function["scope"].startswith("target"):
                continue
            key = (unit["unit"], function["name"])
            target_definitions[key] += 1
            source_locations[key].append(
                f"{function['source']}:{function['line']}"
            )

    manifests = sorted((ROOT / "audit").glob(MANIFEST_PATTERN))
    claims: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    manifest_records: list[dict[str, Any]] = []
    commands_run: set[str] = set()
    for path in manifests:
        payload = json.loads(path.read_text(encoding="utf-8"))
        command = command_for(payload)
        if run_evidence:
            if command is None:
                fail(
                    f"{path.relative_to(ROOT)} lacks a reproducible verification "
                    "command"
                )
            command_key = json.dumps(command, sort_keys=True)
            if command_key not in commands_run:
                run_manifest_command(command, path)
                commands_run.add(command_key)

        counted = 0
        declared = 0
        for unit_record in manifest_units(payload, path):
            unit = unit_record.get("unit")
            functions = unit_record.get("functions")
            reference_execution = unit_record.get(
                "reference_execution",
                payload.get("reference_execution", "unspecified"),
            )
            if not isinstance(unit, str) or not isinstance(functions, list):
                fail(f"{path.relative_to(ROOT)} has an invalid unit record")
            for claim in functions:
                if not isinstance(claim, dict) or not isinstance(
                    claim.get("name"), str
                ):
                    fail(f"{path.relative_to(ROOT)} has an invalid function claim")
                definitions = claim.get("source_definitions", 1)
                if not isinstance(definitions, int) or definitions < 1:
                    fail(
                        f"{path.relative_to(ROOT)} has invalid source_definitions "
                        f"for {unit}:{claim.get('name')}"
                    )
                classification = claim.get("classification", "unclassified")
                key = (unit, claim["name"])
                if isinstance(classification, str) and classification.startswith(
                    "excluded-"
                ):
                    continue
                if key not in target_definitions:
                    fail(
                        f"{path.relative_to(ROOT)} claims unknown target "
                        f"{unit}:{claim['name']}"
                    )
                declared += definitions
                record = {
                    "manifest": path.relative_to(ROOT).as_posix(),
                    "classification": classification,
                    "reference_execution": reference_execution,
                    "source_definitions": definitions,
                    "evidence": claim.get("evidence", []),
                }
                claims[key].append(record)
                if (
                    classification in COUNTED_CLASSIFICATIONS
                    and reference_execution
                    in COUNTED_EXECUTION_MODELS[classification]
                    and unit in semantically_reviewed_units
                ):
                    counted += definitions
        manifest_records.append(
            {
                "path": path.relative_to(ROOT).as_posix(),
                "command": command,
                "declared_target_definitions": declared,
                "counted_claim_definitions": counted,
            }
        )

    proven_definitions = 0
    evidenced_but_not_strict = 0
    function_records: list[dict[str, Any]] = []
    for key in sorted(target_definitions):
        total = target_definitions[key]
        key_claims = claims.get(key, [])
        strict_claimed = sum(
            claim["source_definitions"]
            for claim in key_claims
            if claim["classification"] in COUNTED_CLASSIFICATIONS
            and claim["reference_execution"]
            in COUNTED_EXECUTION_MODELS[claim["classification"]]
            and key[0] in semantically_reviewed_units
        )
        strict = min(total, strict_claimed)
        if strict_claimed > total:
            fail(
                f"evidence overclaims {key[0]}:{key[1]}: "
                f"{strict_claimed} definitions for {total} target definitions"
            )
        non_strict = sum(
            claim["source_definitions"]
            for claim in key_claims
            if not (
                claim["classification"] in COUNTED_CLASSIFICATIONS
                and claim["reference_execution"]
                in COUNTED_EXECUTION_MODELS[claim["classification"]]
                and key[0] in semantically_reviewed_units
            )
        )
        proven_definitions += strict
        evidenced_but_not_strict += min(total - strict, non_strict)
        function_records.append(
            {
                "unit": key[0],
                "name": key[1],
                "target_definitions": total,
                "strictly_proven_definitions": strict,
                "source_locations": source_locations[key],
                "claims": key_claims,
            }
        )

    target_total = sum(target_definitions.values())
    percentage = (
        (100.0 * proven_definitions / target_total) if target_total else 100.0
    )
    return {
        "schema": "miniquake.behavioral-parity.v1",
        "reference": inventory["source"],
        "policy": {
            "counted_classifications": sorted(COUNTED_CLASSIFICATIONS),
            "required_execution_models": {
                key: sorted(value)
                for key, value in COUNTED_EXECUTION_MODELS.items()
            },
            "not_counted": (
                "MiniQuake-only focused/core/milestone/retail/soak evidence "
                "does not establish strict GLQuake behavioral parity."
            ),
            "semantic_review_gate": (
                "A differential/compatibility claim is counted only after its "
                "logical unit has a passing hash-bound semantic source review."
            ),
        },
        "semantic_review": {
            "report": "audit/SEMANTIC_PORT_REVIEW.json",
            "passing_units": len(semantically_reviewed_units),
            "target_units": semantic_report["summary"]["target_units"],
        },
        "summary": {
            "target_function_definitions": target_total,
            "strictly_proven_definitions": proven_definitions,
            "evidenced_but_not_strict_definitions": evidenced_but_not_strict,
            "unproven_definitions": target_total - proven_definitions,
            "strict_parity_percent": round(percentage, 6),
            "manifests": len(manifests),
            "commands_executed": len(commands_run),
        },
        "manifests": manifest_records,
        "functions": function_records,
    }


def render_markdown(report: dict[str, Any]) -> str:
    summary = report["summary"]
    lines = [
        "# Nachgewiesene GLQuake-Verhaltensparität",
        "",
        "Dieser Bericht zählt nur ausgeführte Original-C-Differentiale, "
        "bidirektionale GLQuake-Interoperabilität oder byte-exakte "
        "Originalartefakt-Kompatibilität. MiniQuake-only Tests erhöhen die "
        "strikte Quote nicht. Seit dem Vollreview-Gate zählt ein solcher "
        "Beleg außerdem erst nach bestandenem, hashgebundenem semantischem "
        "Review der gesamten logischen Einheit.",
        "",
        "## Zusammenfassung",
        "",
        f"- Zieldefinitionen: **{summary['target_function_definitions']}**",
        f"- Strikt nachgewiesen: **{summary['strictly_proven_definitions']}**",
        f"- Noch nicht strikt nachgewiesen: **{summary['unproven_definitions']}**",
        f"- Strikte Paritätsquote: **{summary['strict_parity_percent']:.6f} %**",
        f"- Belegmanifeste: **{summary['manifests']}**",
        f"- Semantisch vollständig reauditiert: "
        f"**{report['semantic_review']['passing_units']}/"
        f"{report['semantic_review']['target_units']} Einheiten**",
        "",
        "Die Quote bezieht sich auf die zielrelevanten C-Funktionsdefinitionen. "
        "Sie behauptet nicht automatisch eine vollständige historische "
        "Prozess-Interop, Screenshotgleichheit oder Langzeitabnahme; diese "
        "End-to-End-Gates werden separat geführt.",
        "",
        "## Belegmanifeste",
        "",
        "| Manifest | Reproduzierbarer Befehl | Gezählt |",
        "|---|---|---:|",
    ]
    for manifest in report["manifests"]:
        command = manifest["command"]
        if isinstance(command, list):
            command_text = " ".join(command)
        else:
            command_text = command or "—"
        command_text = command_text.replace("|", "\\|")
        lines.append(
            f"| `{manifest['path']}` | `{command_text}` | "
            f"{manifest['counted_claim_definitions']} |"
        )

    missing = [
        item
        for item in report["functions"]
        if item["strictly_proven_definitions"] < item["target_definitions"]
    ]
    lines.extend(
        [
            "",
            "## Noch nicht vollständig strikt bewiesene Funktionen",
            "",
            "| Einheit | Funktion | Bewiesen/Ziel |",
            "|---|---|---:|",
        ]
    )
    for item in missing:
        lines.append(
            f"| `{item['unit']}` | `{item['name']}` | "
            f"{item['strictly_proven_definitions']}/"
            f"{item['target_definitions']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="update the JSON and Markdown reports",
    )
    parser.add_argument(
        "--run-evidence",
        action="store_true",
        help="execute every manifest's reproducible verification command first",
    )
    args = parser.parse_args()
    report = build_report(run_evidence=args.run_evidence)
    json_text = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    markdown_text = render_markdown(report)

    if args.write:
        JSON_PATH.parent.mkdir(parents=True, exist_ok=True)
        MARKDOWN_PATH.parent.mkdir(parents=True, exist_ok=True)
        JSON_PATH.write_text(json_text, encoding="utf-8")
        MARKDOWN_PATH.write_text(markdown_text, encoding="utf-8")
        print(
            "wrote behavioral parity report: "
            f"{report['summary']['strictly_proven_definitions']}/"
            f"{report['summary']['target_function_definitions']} definitions"
        )
        return 0

    stale = []
    if not JSON_PATH.is_file() or JSON_PATH.read_text(encoding="utf-8") != json_text:
        stale.append(JSON_PATH.relative_to(ROOT).as_posix())
    if (
        not MARKDOWN_PATH.is_file()
        or MARKDOWN_PATH.read_text(encoding="utf-8") != markdown_text
    ):
        stale.append(MARKDOWN_PATH.relative_to(ROOT).as_posix())
    if stale:
        fail("generated artifacts are stale: " + ", ".join(stale))
    print(
        "behavioral parity report verified: "
        f"{report['summary']['strictly_proven_definitions']}/"
        f"{report['summary']['target_function_definitions']} definitions"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
