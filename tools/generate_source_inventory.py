#!/usr/bin/env python3
"""Generate the source-guided WinQuake/GLQuake 1.09 function inventory.

The extractor intentionally follows the formatting of the released id source:
translation-unit functions start in column zero, comments are removed while
newlines are preserved, and positive QUAKE2-only regions are excluded from the
compat_109 profile. Static helpers are included because black-port closure must
account for behavior, not only public symbols.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Iterable

SOURCE_UNITS = [
    "cd_win.c", "chase.c", "cl_demo.c", "cl_input.c", "cl_main.c",
    "cl_parse.c", "cl_tent.c", "cmd.c", "common.c", "conproc.c",
    "console.c", "crc.c", "cvar.c", "gl_draw.c", "gl_mesh.c",
    "gl_model.c", "gl_refrag.c", "gl_rlight.c", "gl_rmain.c",
    "gl_rmisc.c", "gl_rsurf.c", "gl_screen.c", "gl_test.c",
    "gl_vidnt.c", "gl_warp.c", "host.c", "host_cmd.c", "in_win.c",
    "keys.c", "mathlib.c", "menu.c", "net_dgrm.c", "net_loop.c",
    "net_main.c", "net_wins.c", "pr_cmds.c", "pr_edict.c",
    "pr_exec.c", "r_part.c", "sbar.c", "snd_dma.c", "snd_mem.c",
    "snd_mix.c", "snd_win.c", "sv_main.c", "sv_move.c", "sv_phys.c",
    "sv_user.c", "sys_win.c", "view.c", "wad.c", "world.c", "zone.c",
]

HEADER_UNITS = [
    "bspfile.h", "modelgen.h", "spritegn.h", "protocol.h", "pr_comp.h",
    "progdefs.h", "progs.h", "quakedef.h", "anorms.h+anorm_dots.h",
    "gl_warp_sin.h",
]

CONTEXT_ADAPTERS = {
    "Cvar_FindVar", "Cvar_VariableValue", "Cvar_VariableString",
    "Cvar_CompleteVariable", "Cvar_Set", "Cvar_SetValue",
    "Cvar_RegisterVariable", "Cvar_Command", "Cvar_WriteVariables",
}

TECHNICAL_EQUIVALENTS = {
    "CDAudio_Eject", "CDAudio_CloseDoor", "CDAudio_GetAudioDiskInfo",
    "CDAudio_MessageHandler",
}

FUNCTION_RE = re.compile(
    r"(?ms)^"
    r"(?:(?:static|extern|inline|__inline)\s+)*"
    r"(?:"
    r"[A-Za-z_][A-Za-z0-9_]*(?:\s+|\s*\*\s*)"
    r"|\([^;\n{}]*\)\s*"
    r")+?"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*"
    r"\(([^;{}]*?)\)\s*\{"
)

ML_FUNCTION_RE = re.compile(
    r"(?m)^\s*(?:static\s+)?function(?:\s+inline)?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\("
)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def strip_comments_preserve_lines(text: str) -> str:
    def block(match: re.Match[str]) -> str:
        return "\n" * match.group(0).count("\n")
    text = re.sub(r"/\*.*?\*/", block, text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def quake2_positive_lines(text: str) -> set[int]:
    """Return source lines active only when QUAKE2 is positively defined.

    This is deliberately a narrow evaluator for the released source's simple
    #ifdef/#ifndef/#if defined structure. It is not a general C preprocessor.
    """

    stack: list[tuple[bool, bool]] = []
    result: set[int] = set()

    for number, raw in enumerate(text.splitlines(), 1):
        line = raw.strip()
        if line.startswith("#ifdef"):
            macro = line[len("#ifdef"):].strip().split()[0]
            stack.append((macro == "QUAKE2", macro == "QUAKE2"))
        elif line.startswith("#ifndef"):
            macro = line[len("#ifndef"):].strip().split()[0]
            stack.append((macro == "QUAKE2", False))
        elif line.startswith("#if") and not line.startswith("#ifdef") and not line.startswith("#ifndef"):
            expression = line[len("#if"):].strip()
            mentions = "QUAKE2" in expression
            negated = bool(re.search(
                r"!\s*(?:defined\s*\(\s*QUAKE2\s*\)|defined\s+QUAKE2|QUAKE2)",
                expression,
            ))
            stack.append((mentions, mentions and not negated))
        elif line.startswith("#elif") and stack:
            inherited_mentions, _ = stack.pop()
            expression = line[len("#elif"):].strip()
            mentions_here = "QUAKE2" in expression
            negated = bool(re.search(
                r"!\s*(?:defined\s*\(\s*QUAKE2\s*\)|defined\s+QUAKE2|QUAKE2)",
                expression,
            ))
            stack.append((
                inherited_mentions or mentions_here,
                mentions_here and not negated,
            ))
        elif line.startswith("#else") and stack:
            mentions, state = stack.pop()
            stack.append((mentions, not state if mentions else state))
        elif line.startswith("#endif") and stack:
            stack.pop()

        if any(mentions and positive for mentions, positive in stack):
            result.add(number)

    return result


def ml_functions(root: Path) -> dict[str, list[str]]:
    result: dict[str, list[str]] = defaultdict(list)
    for path in sorted(root.rglob("*.ml")):
        relative = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        for match in ML_FUNCTION_RE.finditer(text):
            result[match.group(1)].append(relative)
    return dict(result)


def source_definitions(root: Path) -> list[dict[str, object]]:
    definitions: list[dict[str, object]] = []
    for unit in SOURCE_UNITS:
        path = root / unit
        if not path.is_file():
            raise FileNotFoundError(f"required original source unit missing: {path}")
        raw = path.read_text(encoding="latin-1", errors="replace")
        stripped = strip_comments_preserve_lines(raw)
        quake2_lines = quake2_positive_lines(raw)
        for match in FUNCTION_RE.finditer(stripped):
            name = match.group(1)
            line = stripped.count("\n", 0, match.start()) + 1
            definitions.append({
                "source": unit,
                "line": line,
                "name": name,
                "profile_excluded": line in quake2_lines,
                "signature_sha256": sha256_bytes(
                    (name + "(" + " ".join(match.group(2).split()) + ")").encode("utf-8")
                ),
            })
    return definitions


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--original-root", required=True, type=Path)
    parser.add_argument("--miniquake-root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    original_root = args.original_root.resolve()
    miniquake_root = args.miniquake_root.resolve()
    functions = ml_functions(miniquake_root)
    definitions = source_definitions(original_root)

    counts: Counter[str] = Counter()
    entries: list[dict[str, object]] = []
    by_source: Counter[str] = Counter()

    for definition in definitions:
        name = str(definition["name"])
        excluded = bool(definition["profile_excluded"])
        targets = sorted(functions.get(name, []))

        if excluded:
            status = "profile_excluded"
            reason = "positive QUAKE2-only source region; compat_109 builds with QUAKE2 undefined"
        elif name in CONTEXT_ADAPTERS:
            status = "context_adapter"
            reason = "original global context is passed explicitly by MiniQuake"
        elif name in TECHNICAL_EQUIVALENTS:
            status = "technical_equivalent"
            reason = "physical MCI mechanics are represented by the observable OGG/backend state transition"
        elif targets:
            status = "exact_name"
            reason = "original function name exists in the MiniLang source tree"
        else:
            status = "missing"
            reason = "no exact-name function or approved adapter classification"

        item = dict(definition)
        item["status"] = status
        item["reason"] = reason
        item["minilang_targets"] = targets
        entries.append(item)
        counts[status] += 1
        by_source[str(definition["source"])] += 1

    target_definitions = len(definitions) - counts["profile_excluded"]
    accounted = (
        counts["exact_name"]
        + counts["context_adapter"]
        + counts["technical_equivalent"]
    )

    document = {
        "schema_version": 1,
        "compatibility_profile": "compat_109",
        "original_root_label": "OriginalQuakeSourceCode.zip",
        "source_unit_count": len(SOURCE_UNITS),
        "header_unit_count": len(HEADER_UNITS),
        "source_units": SOURCE_UNITS,
        "header_units": HEADER_UNITS,
        "definitions_discovered": len(definitions),
        "profile_excluded": counts["profile_excluded"],
        "target_definitions": target_definitions,
        "accounted_definitions": accounted,
        "coverage_percent": round((accounted * 100.0 / target_definitions), 6) if target_definitions else 100.0,
        "status_counts": dict(sorted(counts.items())),
        "context_adapter_names": sorted(CONTEXT_ADAPTERS),
        "technical_equivalent_names": sorted(TECHNICAL_EQUIVALENTS),
        "missing_names": sorted({
            str(entry["name"]) for entry in entries if entry["status"] == "missing"
        }),
        "definitions_per_source": dict(sorted(by_source.items())),
        "entries": entries,
    }

    canonical = json.dumps(document, sort_keys=True, separators=(",", ":")).encode("utf-8")
    document["inventory_sha256"] = sha256_bytes(canonical)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(document, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    print("MiniQuake source function inventory")
    print(f"  source_units={document['source_unit_count']}")
    print(f"  definitions_discovered={document['definitions_discovered']}")
    print(f"  profile_excluded={document['profile_excluded']}")
    print(f"  target_definitions={document['target_definitions']}")
    print(f"  exact_name={counts['exact_name']}")
    print(f"  context_adapter={counts['context_adapter']}")
    print(f"  technical_equivalent={counts['technical_equivalent']}")
    print(f"  missing={counts['missing']}")
    print(f"  coverage={document['coverage_percent']:.6f}%")
    print(f"  inventory_sha256={document['inventory_sha256']}")
    return 0 if counts["missing"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
