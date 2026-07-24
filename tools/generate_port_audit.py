#!/usr/bin/env python3
"""Generate the source-by-source GLQuake coverage report from the pinned tree."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import sys
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake" / "WinQuake"
PROJECT = REFERENCE / "WinQuake.dsp"
LOCK_PATH = ROOT / "reference" / "quake.lock.json"
JSON_PATH = ROOT / "audit" / "PORT_COVERAGE.json"
MARKDOWN_PATH = ROOT / "ORIGINAL_FILE_COVERAGE.md"
INVENTORY_TOOL = ROOT / "tools" / "generate_port_inventory.py"
ROW = re.compile(
    r"^\|\s*`(?P<name>[^`]+)`\s*\|\s*(?P<status>[^|]+?)\s*\|"
    r"\s*(?P<target>.*?)\s*\|$"
)
ALLOWED = {
    "PORTIERT",
    "TEILPORTIERT",
    "PLATTFORMBRÜCKE",
    "OFFEN",
    "NICHT ZIELRELEVANT",
}
STATUS_ORDER = [
    "PORTIERT",
    "TEILPORTIERT",
    "PLATTFORMBRÜCKE",
    "OFFEN",
    "NICHT ZIELRELEVANT",
]
SOURCE_BLOCK = re.compile(
    r"# Begin Source File\s+(?P<body>.*?)# End Source File", re.DOTALL
)
SOURCE_PATH = re.compile(r"^SOURCE=\.\\(?P<path>.+?)\s*$", re.MULTILINE)
INCLUDE = re.compile(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]', re.MULTILINE)
GL_CONFIGURATION = "winquake - Win32 GL Release"
SCOPE_EXCLUDED_HEADERS = {
    "d_iface.h": "reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad",
    "dosisms.h": "reine DOS-/Software-Renderer-Schnittstelle; GLQuake-Zielpfad",
    "net_ser.h": "Serial-/Modem-Netzwerk ist ausgeschlossen",
    "net_vcr.h": "VCR-Netzwerk ist ausgeschlossen",
    "net_wipx.h": "IPX ist ausgeschlossen",
    "r_local.h": "reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad",
    "r_shared.h": "reine Software-Renderer-Schnittstelle; GLQuake-Zielpfad",
}
SCOPE_EXCLUDED_SOURCES = {
    "net_vcr.c": "VCR-Netzwerk ist laut Zieldefinition ausgeschlossen",
    "net_wipx.c": "IPX ist laut Zieldefinition ausgeschlossen",
}
TARGET_OVERRIDES = {
    "anorm_dots.h": (
        "TEILPORTIERT",
        "render/alias_normals.ml enthält die GLQuake-Shadingtabellen; "
        "byte-/indexgenaue Abnahme bleibt erforderlich",
    ),
    "anorms.h": (
        "TEILPORTIERT",
        "render/alias_normals.ml enthält die GLQuake-Aliasnormalen; "
        "tabellengenaue Abnahme bleibt erforderlich",
    ),
    "r_part.c": (
        "TEILPORTIERT",
        "particles.ml, render/particles.ml; im GL-Release gemeinsam genutzter "
        "Partikelpfad, kein ausgeschlossener Software-Renderer",
    ),
}


def fail(message: str) -> "NoReturn":
    raise SystemExit(f"port audit generation failed: {message}")


def load_inventory() -> dict[str, object]:
    spec = importlib.util.spec_from_file_location(
        "miniquake_port_inventory_for_file_audit", INVENTORY_TOOL
    )
    if spec is None or spec.loader is None:
        fail(f"cannot import {INVENTORY_TOOL}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.build_report()


def markdown_seed() -> dict[str, tuple[str, str]]:
    if not MARKDOWN_PATH.is_file():
        fail(f"missing seed report: {MARKDOWN_PATH}")
    result: dict[str, tuple[str, str]] = {}
    for line in MARKDOWN_PATH.read_text(encoding="utf-8").splitlines():
        match = ROW.match(line)
        if not match:
            continue
        name = match.group("name")
        status = match.group("status").strip()
        target = match.group("target").strip()
        if status not in ALLOWED:
            continue
        result[name.casefold()] = (status, target)
    return result


def json_seed() -> dict[str, tuple[str, str]]:
    if not JSON_PATH.is_file():
        return {}
    payload = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    return {
        entry["original"].casefold(): (entry["status"], entry["miniquake"])
        for entry in payload["entries"]
    }


def excluded_dependency(path: Path) -> str | None:
    relative = path.relative_to(REFERENCE).as_posix()
    folded = relative.casefold()
    if folded.startswith("dxsdk/"):
        return "mitgelieferter DirectX-SDK-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads"
    if folded.startswith("scitech/"):
        return "mitgelieferter SciTech-MGL-Header; nicht Teil des OpenGL-/Windows-x64-Zielpfads"
    if folded == "gas2masm/gas2masm.c":
        return "historisches Assembler-Konvertierungswerkzeug; nicht Teil der Engine-Laufzeit"
    return None


def gl_release_scope() -> tuple[set[str], set[str]]:
    """Return selected C files and transitively included local headers."""
    project_text = PROJECT.read_text(encoding="latin-1")
    selected: set[str] = set()
    marker = f'!ELSEIF  "$(CFG)" == "{GL_CONFIGURATION}"'
    for match in SOURCE_BLOCK.finditer(project_text):
        body = match.group("body")
        source_match = SOURCE_PATH.search(body)
        if source_match is None:
            continue
        name = Path(source_match.group("path")).name.casefold()
        if not name.endswith(".c"):
            continue
        if marker in body:
            configuration_body = body.split(marker, 1)[1].split("!ENDIF", 1)[0]
            if "# PROP Exclude_From_Build 1" in configuration_body:
                continue
        selected.add(name)

    local_headers = {
        path.name.casefold(): path
        for path in REFERENCE.iterdir()
        if path.is_file() and path.suffix.casefold() == ".h"
    }
    queue = [REFERENCE / name for name in selected]
    headers: set[str] = set()
    seen: set[str] = set()
    while queue:
        path = queue.pop()
        key = path.name.casefold()
        if key in seen or not path.is_file():
            continue
        seen.add(key)
        for include in INCLUDE.findall(path.read_text(encoding="latin-1")):
            included_name = Path(include).name.casefold()
            included = local_headers.get(included_name)
            if included is not None and included_name not in headers:
                headers.add(included_name)
                queue.append(included)
    return selected, headers


def build_report() -> dict[str, object]:
    if not REFERENCE.is_dir():
        fail("reference/quake submodule is absent; run `git submodule update --init`")
    lock = json.loads(LOCK_PATH.read_text(encoding="utf-8"))
    inventory = load_inventory()
    unit_by_path: dict[str, dict[str, object]] = {}
    for unit in inventory["units"]:
        for original in unit["original_files"]:
            key = original["path"].casefold()
            if key in unit_by_path:
                fail(f"duplicate logical-unit mapping for {original['path']}")
            unit_by_path[key] = unit
    gl_sources, gl_headers = gl_release_scope()
    source_files = sorted(
        (
            path
            for path in REFERENCE.rglob("*")
            if path.is_file() and path.suffix.lower() in {".c", ".h"}
        ),
        key=lambda path: path.relative_to(REFERENCE).as_posix().casefold(),
    )
    names = [path.name.casefold() for path in source_files]
    duplicates = sorted(name for name, count in Counter(names).items() if count > 1)
    if duplicates:
        fail("duplicate source basenames are unsupported: " + ", ".join(duplicates))

    entries: list[dict[str, str]] = []
    for path in source_files:
        relative = path.relative_to(REFERENCE).as_posix()
        excluded = excluded_dependency(path)
        folded_name = path.name.casefold()
        if excluded is not None:
            status, target = "NICHT ZIELRELEVANT", excluded
        elif folded_name in SCOPE_EXCLUDED_SOURCES:
            status, target = (
                "NICHT ZIELRELEVANT",
                SCOPE_EXCLUDED_SOURCES[folded_name],
            )
        elif folded_name in SCOPE_EXCLUDED_HEADERS:
            status, target = (
                "NICHT ZIELRELEVANT",
                SCOPE_EXCLUDED_HEADERS[folded_name],
            )
        elif path.suffix.casefold() == ".c" and folded_name not in gl_sources:
            status, target = (
                "NICHT ZIELRELEVANT",
                "von der Win32-GL-Release-Konfiguration nicht gebaut",
            )
        elif path.suffix.casefold() == ".h" and folded_name not in gl_headers:
            status, target = (
                "NICHT ZIELRELEVANT",
                "vom Win32-GL-Release-Ziel nicht transitiv eingebunden",
            )
        else:
            unit = unit_by_path.get(relative.casefold())
            if unit is None:
                fail(f"no logical-unit mapping for pinned target file {relative}")
            if unit["scope"] != "target":
                status = "NICHT ZIELRELEVANT"
                target = str(unit["note"])
            else:
                modules = ", ".join(
                    module["path"] for module in unit["minilang_modules"]
                )
                if not modules:
                    fail(f"target logical unit without MiniLang counterpart: {relative}")
                if str(unit["accounting_status"]).startswith("native-bridge"):
                    status = "PLATTFORMBRÜCKE"
                    target = (
                        f"logische Einheit {unit['unit']}: {modules}; "
                        "OS-/ABI-Anteil liegt in der nativen Windows-Brücke"
                    )
                else:
                    status = "PORTIERT"
                    target = f"logische Einheit {unit['unit']}: {modules}"
                    if unit["unit"] == "cd_audio":
                        target += (
                            "; physische CD-/MCI-Steuerung ist ausgeschlossen "
                            "und durch OGG-Streaming ersetzt"
                        )
        if status not in ALLOWED or not target:
            fail(f"invalid classification for {relative}")
        entries.append(
            {
                "path": relative,
                "original": path.name,
                "status": status,
                "miniquake": target,
            }
        )

    counts = Counter(entry["status"] for entry in entries)
    return {
        "schema": 2,
        "source": {
            "repository": lock["repository"],
            "commit": lock["commit"],
            "tree": lock["tree"],
            "root": "WinQuake",
            "manifest_sha256": lock["source_scope"]["manifest_sha256"],
        },
        "files": len(entries),
        "counts": {status: counts.get(status, 0) for status in STATUS_ORDER},
        "logical_coverage": {
            "target_units": inventory["summary"]["target_units"],
            "target_units_with_minilang_counterpart": inventory["summary"][
                "target_units_with_minilang_counterpart"
            ],
            "target_c_function_definitions": inventory["summary"][
                "target_c_function_definitions"
            ],
            "target_c_function_definitions_located": inventory["summary"][
                "target_c_function_definitions_located"
            ],
            "target_assembly_exports": inventory["summary"][
                "target_assembly_exports"
            ],
            "target_assembly_exports_located": inventory["summary"][
                "target_assembly_exports_located"
            ],
        },
        "entries": entries,
    }


def render_markdown(report: dict[str, object]) -> str:
    counts = report["counts"]
    source = report["source"]
    logical = report["logical_coverage"]
    lines = [
        "# Originaldatei-Abdeckung",
        "",
        "Diese maschinenunterstützte Liste umfasst jede C-/Headerdatei des "
        "gepinnten offiziellen `WinQuake`-Baums. `PORTIERT` bedeutet hier, "
        "dass die Datei in einer vollständig zugeordneten logischen C/H-Einheit "
        "mit bestehendem MiniLang-Pendant liegt. Das ist kein eigenständiger "
        "End-to-End-Paritätsnachweis.",
        "",
        f"Referenz: `{source['commit']}` (`{source['tree']}`), "
        f"{report['files']} Dateien.",
        "",
        "## Zusammenfassung",
        "",
        f"- Ziel-C/H-Einheiten mit MiniLang-Pendant: "
        f"**{logical['target_units_with_minilang_counterpart']}/"
        f"{logical['target_units']}**",
        f"- Ziel-C-Funktionsdefinitionen mit Codeort: "
        f"**{logical['target_c_function_definitions_located']}/"
        f"{logical['target_c_function_definitions']}**",
        f"- Ziel-Assemblerexporte mit Codeort: "
        f"**{logical['target_assembly_exports_located']}/"
        f"{logical['target_assembly_exports']}**",
        "- Strikte Funktionsparität steht getrennt in "
        "`audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md`.",
        "",
        "Dateiklassifikation des vollständigen gepinnten Baums:",
        "",
    ]
    for status in STATUS_ORDER:
        lines.append(f"- **{status}:** {counts[status]} Dateien")
    lines.extend(
        [
            "",
            "## Dateien",
            "",
            "| Pfad | Originaldatei | Status | MiniQuake / Begründung |",
            "|---|---|---|---|",
        ]
    )
    for entry in report["entries"]:
        target = entry["miniquake"].replace("|", "\\|")
        lines.append(
            f"| `{entry['path']}` | `{entry['original']}` | "
            f"{entry['status']} | {target} |"
        )
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="update the tracked JSON and Markdown reports",
    )
    args = parser.parse_args()
    report = build_report()
    json_text = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    markdown_text = render_markdown(report)

    if args.write:
        JSON_PATH.write_text(json_text, encoding="utf-8")
        MARKDOWN_PATH.write_text(markdown_text, encoding="utf-8")
        print(f"wrote {len(report['entries'])} pinned-source classifications")
        return 0

    mismatches = []
    if not JSON_PATH.is_file() or JSON_PATH.read_text(encoding="utf-8") != json_text:
        mismatches.append(JSON_PATH.relative_to(ROOT).as_posix())
    if (
        not MARKDOWN_PATH.is_file()
        or MARKDOWN_PATH.read_text(encoding="utf-8") != markdown_text
    ):
        mismatches.append(MARKDOWN_PATH.relative_to(ROOT).as_posix())
    if mismatches:
        fail("generated reports are stale: " + ", ".join(mismatches))
    print(f"port audit verified: {len(report['entries'])} pinned source files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
