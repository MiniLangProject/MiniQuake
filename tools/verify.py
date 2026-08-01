#!/usr/bin/env python3
"""Self-contained verifier for MiniQuake BP-089 / BP-085-089R8.

Historical semantic component checkers are executed by build.ps1. This verifier
owns current package integrity, imports, native bridge identity, delivery
scripts, game-data exclusion and the source-guided black-port closure.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path, PurePosixPath

PACKAGE_ID = "BP-089"
PARENT_PACKAGE_ID = "BP-088"
BLOCK_ID = "BP-085-089"
BLOCK_PARENT_PACKAGE_ID = "BP-080-084R2"
DELIVERY_REVISION = "BP-085-089R8"
DELIVERY_PARENT = "BP-085-089R7"
MANIFEST = "SOURCE_MANIFEST.sha256"

EXCLUDED_DIRS = {".git", "build", "__pycache__", ".pytest_cache"}
FORBIDDEN_SUFFIXES = {
    ".pak", ".bsp", ".mdl", ".spr", ".wad", ".dem", ".sav", ".lmp",
    ".pcx", ".tga", ".ogg", ".wav", ".lit", ".vis",
}
FORBIDDEN_NAMES = {"progs.dat", "gfx.wad", "palette.lmp", "colormap.lmp"}

REQUIRED_PATHS = {
    "COPYING", "README.md", "build.ps1", "COLLECT_RESULTS.ps1", "test.ps1",
    "TEST_BP-080-084.ps1", "TEST_BP-080-084R1.ps1", "TEST_BP-080-084R2.ps1",
    "CHANGELOG_BP-080-084R1.md", "CHANGELOG_BP-080-084R2.md",
    "docs/BP-080-084R1_TESTING.md",
    "docs/BP-080-084R1_RESULT_ANALYSIS.md",
    "docs/BP-080-084R1_HOTFIX_REPORT.json",
    "docs/BP-080-084R1_BLOCK_LEDGER.json",
    "docs/BP-080-084R2_TESTING.md",
    "docs/BP-080-084R2_RESULT_ANALYSIS.md",
    "docs/BP-080-084R2_HOTFIX_REPORT.json",
    "docs/BP-080-084R2_BLOCK_LEDGER.json",
    "BLOCK_LEDGER.json", "PORT_LEDGER.json",
    "PORT_STATUS.md", MANIFEST,
    "src/main.ml", "src/miniquake/build_info.ml",
    "src/miniquake/cvar.ml", "src/miniquake/sound/cd_audio.ml",
    "src/miniquake/source_profile_contract.ml",
    "src/miniquake/black_port_corpus.ml",
    "src/miniquake/black_port_source_contract.ml",
    "tests/cvar_source_surface_tests.ml",
    "tests/cd_audio_source_surface_tests.ml",
    "tests/source_function_inventory_tests.ml",
    "tests/black_port_corpus_tests.ml",
    "tests/black_port_source_closure_tests.ml",
    "audit/cvar_source_surface_golden.json",
    "audit/cd_audio_source_surface_golden.json",
    "audit/source_function_inventory.json",
    "audit/black_port_corpus_golden.json",
    "audit/black_port_source_closure_golden.json",
    "tools/generate_source_inventory.py",
    "tools/check_source_080.py", "tools/check_source_081.py",
    "tools/check_source_082.py", "tools/check_source_083.py",
    "tools/check_source_084.py",
    "native/miniquake_native.dll", "native/miniquake_native.def",
    "native/miniquake_text.dll", "native/miniquake_text.def",
    "patches/BP-080.diff", "patches/BP-081.diff", "patches/BP-082.diff",
    "patches/BP-083.diff", "patches/BP-084.diff",
    "patches/BP-084R1.diff", "patches/BP-084R2.diff",
    "TEST_BP-085-089.ps1", "CHANGELOG_BP-085-089.md",
    "docs/BP-085-089_TESTING.md", "docs/BP-080-084R2_ACCEPTANCE_ANALYSIS.md",
    "docs/BP-085-089_BLOCK_LEDGER.json",
    "TEST_BP-085-089R1.ps1", "CHANGELOG_BP-085-089R1.md",
    "docs/BP-085-089R1_TESTING.md", "docs/BP-085-089R1_RESULT_ANALYSIS.md",
    "docs/BP-085-089R1_HOTFIX_REPORT.json", "docs/BP-085-089R1_BLOCK_LEDGER.json",
    "TEST_BP-085-089R8.ps1", "CHANGELOG_BP-085-089R8.md",
    "docs/BP-085-089R8_TESTING.md", "docs/BP-085-089R8_RESULT_ANALYSIS.md",
    "docs/BP-085-089R8_HOTFIX_REPORT.json", "docs/BP-085-089R8_BLOCK_LEDGER.json",
    "TEST_BP-085-089R7.ps1", "CHANGELOG_BP-085-089R7.md",
    "docs/BP-085-089R7_TESTING.md", "docs/BP-085-089R7_RESULT_ANALYSIS.md",
    "docs/BP-085-089R7_HOTFIX_REPORT.json", "docs/BP-085-089R7_BLOCK_LEDGER.json",
    "TEST_BP-085-089R5.ps1", "CHANGELOG_BP-085-089R5.md",
    "docs/BP-085-089R5_TESTING.md", "docs/BP-085-089R5_RESULT_ANALYSIS.md",
    "docs/BP-085-089R5_HOTFIX_REPORT.json", "docs/BP-085-089R5_BLOCK_LEDGER.json",
    "TEST_BP-085-089R4.ps1", "CHANGELOG_BP-085-089R4.md",
    "docs/BP-085-089R4_TESTING.md", "docs/BP-085-089R4_RESULT_ANALYSIS.md",
    "docs/BP-085-089R4_HOTFIX_REPORT.json", "docs/BP-085-089R4_BLOCK_LEDGER.json",
    "TEST_BP-085-089R3.ps1", "CHANGELOG_BP-085-089R3.md",
    "docs/BP-085-089R3_TESTING.md", "docs/BP-085-089R3_RESULT_ANALYSIS.md",
    "docs/BP-085-089R3_HOTFIX_REPORT.json", "docs/BP-085-089R3_BLOCK_LEDGER.json",
    "TEST_BP-085-089R2.ps1", "CHANGELOG_BP-085-089R2.md",
    "docs/BP-085-089R2_TESTING.md", "docs/BP-085-089R2_RESULT_ANALYSIS.md",
    "docs/BP-085-089R2_HOTFIX_REPORT.json", "docs/BP-085-089R2_BLOCK_LEDGER.json",
    "src/miniquake/server.ml", "src/miniquake/types.ml",
    "tests/compat_trace_tests.ml",
    "src/miniquake/game_profile.ml", "src/miniquake/mod_compat.ml",
    "src/miniquake/artifact_compat.ml", "src/miniquake/common.ml",
    "src/miniquake/format/bsp.ml", "src/miniquake/savegame_runtime.ml",
    "src/miniquake/stability_contract.ml",
    "src/miniquake/compatibility_matrix.ml",
    "tests/game_profile_compat_tests.ml", "tests/mod_runtime_compat_tests.ml",
    "tests/artifact_compat_tests.ml", "tests/stability_contract_tests.ml",
    "tests/compatibility_release_closure_tests.ml", "tests/artifact_retail_evidence.ml",
    "audit/game_profile_golden.json", "audit/mod_runtime_golden.json",
    "audit/artifact_compat_golden.json", "audit/savegame_v5_golden.json",
    "audit/savegame_fixed6_golden.json", "audit/stability_golden.json",
    "audit/compat_release_golden.json",
    "tools/check_compat_085.py", "tools/check_compat_086.py",
    "tools/check_compat_087.py", "tools/check_compat_088.py", "tools/check_compat_089.py",
    "tools/check_savegame_v5.py", "tools/oracle/savegame_v5_oracle.c",
    "tools/oracle/savegame_fixed6_oracle.c", "native/miniquake_text.c", "native/README.md",
    "tools/check_command_cvar.py", "tools/oracle/command_cvar_oracle.c",
    "audit/command_cvar_golden.json", "tests/command_cvar_lifecycle_tests.ml",
    "patches/BP-085.diff", "patches/BP-086.diff", "patches/BP-087.diff",
    "patches/BP-088.diff", "patches/BP-089.diff", "patches/BP-089R1.diff", "patches/BP-089R2.diff",
    "patches/BP-089R3.diff", "patches/BP-089R4.diff", "patches/BP-089R5.diff", "patches/BP-089R6.diff",
    "patches/BP-089R7.diff", "patches/BP-089R8.diff",
}

EXPECTED_NATIVE = {
    "native/miniquake_native.dll": (
        "3e7a6f09aa4836875b243530908b309f3245ffc267ecef06b2adbc33b02c0588",
        160,
        "native/miniquake_native.def",
    ),
    "native/miniquake_text.dll": (
        "3e6ea2aa37ca58bdfd821a1b9278d6411a90143c3b0c48b8f96bfa10a0c6bd7c",
        12,
        "native/miniquake_text.def",
    ),
}


@dataclass
class Check:
    name: str
    passed: bool
    details: dict
    errors: list[str]


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def all_package_files(root: Path) -> list[Path]:
    result: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(root)
        if any(part in EXCLUDED_DIRS for part in relative.parts):
            continue
        if relative.as_posix() == MANIFEST:
            continue
        if relative.parts[:2] in (("native", "build"), ("native", "text_build")):
            continue
        result.append(path)
    return sorted(result, key=lambda item: item.relative_to(root).as_posix().lower())


def check_required(root: Path) -> Check:
    missing = sorted(path for path in REQUIRED_PATHS if not (root / path).is_file())
    return Check("required_paths", not missing, {"required": len(REQUIRED_PATHS)}, [f"missing: {x}" for x in missing])


def parse_manifest(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        if not raw.strip():
            continue
        match = re.fullmatch(r"([0-9a-fA-F]{64})\s+\*?(.+)", raw)
        if not match:
            raise ValueError(f"invalid manifest line {number}: {raw!r}")
        relative = match.group(2).replace("\\", "/")
        if relative in values:
            raise ValueError(f"duplicate manifest path: {relative}")
        values[relative] = match.group(1).lower()
    return values


def check_manifest(root: Path) -> Check:
    errors: list[str] = []
    try:
        listed = parse_manifest(root / MANIFEST)
    except Exception as exc:
        return Check("source_manifest", False, {}, [str(exc)])
    actual_paths = [path.relative_to(root).as_posix() for path in all_package_files(root)]
    actual = set(actual_paths)
    expected = set(listed)
    for path in sorted(actual - expected):
        errors.append(f"file is not listed in manifest: {path}")
    for path in sorted(expected - actual):
        errors.append(f"manifest path is missing: {path}")
    for relative in sorted(actual & expected):
        found = digest(root / relative)
        if found != listed[relative]:
            errors.append(f"hash mismatch: {relative}")
    details = {
        "listed_files": len(listed),
        "actual_files": len(actual),
        "manifest_sha256": digest(root / MANIFEST),
    }
    return Check("source_manifest", not errors, details, errors)


def check_identity(root: Path) -> Check:
    errors: list[str] = []
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    test = (root / "TEST_BP-085-089R8.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    launcher = (root / "test.ps1").read_text(encoding="utf-8-sig")
    markers = {
        "build_info": [
            'const PACKAGE_ID = "BP-089"', 'const PARENT_PACKAGE_ID = "BP-088"',
            'const BLOCK_ID = "BP-085-089"',
            'const BLOCK_PARENT_PACKAGE_ID = "BP-080-084R2"',
            'const GAME_PROFILE_STATUS = "game_profile_109_frozen_v1"',
            'const MOD_RUNTIME_STATUS = "mod_runtime_109_frozen_v1"',
            'const ARTIFACT_COMPAT_STATUS = "artifact_compat_109_frozen_v1"',
            'const STABILITY_STATUS = "stability_109_frozen_v1"',
            'const COMPAT_RELEASE_STATUS = "compat_109_release_candidate_v1"',
            'const COMPAT_RELEASE_FINGERPRINT = 0x29b72a98',
        ],
        "main": [
            "Game profile status:", "Mod runtime status:",
            "Artifact compatibility status:", "Stability status:",
            "Compatibility release status:", "Port status: BP-089",
        ],
        "build": [
            '$PackageId = "BP-089"', '$ParentPackageId = "BP-088"',
            '$BlockId = "BP-085-089"', '$CompatReleaseStatus = "compat_109_release_candidate_v1"',
            "MiniQuakeCompatibilityReleaseTests.exe", "MiniQuakeArtifactRetailEvidence.exe",
        ],
        "test": [
            '$PackageId = "BP-089"', '$BlockId = "BP-085-089"',
            '$DeliveryRevision = "BP-085-089R8"',
            '$DeliveryParent = "BP-085-089R7"',
            "MiniQuake BP-085-089R8 acceptance test: PASS",
            "retail demo/save artifact evidence A", "5000-frame host soak",
        ],
        "collector": [
            '$PackageId = "BP-089"', '$BlockId = "BP-085-089"',
            '$DeliveryRevision = "BP-085-089R8"',
            '$DeliveryParent = "BP-085-089R7"',
            "MiniQuake_BP-085-089R8_RESULTS_",
            "MiniQuakeArtifactRetailEvidence.exe",
        ],
        "launcher": ["TEST_BP-085-089R8.ps1"],
    }
    texts = {
        "build_info": build_info, "main": main, "build": build,
        "test": test, "collector": collector, "launcher": launcher,
    }
    for label, wanted in markers.items():
        for marker in wanted:
            if marker not in texts[label]:
                errors.append(f"{label} missing marker: {marker}")
    return Check("package_identity", not errors, {
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "block_id": BLOCK_ID,
        "block_parent_package_id": BLOCK_PARENT_PACKAGE_ID,
    }, errors)


PACKAGE_RE = re.compile(r"(?m)^\s*package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$")
MAIN_RE = re.compile(r"(?m)^\s*function\s+main\s*\(")
IMPORT_RE = re.compile(
    r'(?m)^\s*import\s+(?:"([^"]+)"|([A-Za-z_][A-Za-z0-9_.]*))'
    r'(?:\s+as\s+[A-Za-z_][A-Za-z0-9_]*)?\s*$'
)


def check_minilang_imports(root: Path) -> Check:
    errors: list[str] = []
    package_to_path: dict[str, str] = {}
    ml_files = sorted((root / "src").rglob("*.ml")) + sorted((root / "tests").rglob("*.ml"))
    for path in ml_files:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        match = PACKAGE_RE.search(text)
        if not match:
            # Entry files and many legacy tests intentionally live in the
            # global package. They remain valid MiniLang sources and still
            # participate in import validation below.
            continue
        package = match.group(1)
        previous = package_to_path.get(package)
        relative = path.relative_to(root).as_posix()
        if previous and previous != relative:
            errors.append(f"duplicate package {package}: {previous}, {relative}")
        package_to_path[package] = relative

    imports_checked = 0
    for path in ml_files:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        for match in IMPORT_RE.finditer(text):
            imports_checked += 1
            quoted, module = match.groups()
            if module:
                if module.startswith("std."):
                    continue
                if module not in package_to_path:
                    errors.append(f"{path.relative_to(root).as_posix()}: unresolved import {module}")
            else:
                candidate = (path.parent / quoted).resolve()
                if not candidate.is_file():
                    candidate = (root / "src" / quoted).resolve()
                if not candidate.is_file():
                    errors.append(f"{path.relative_to(root).as_posix()}: unresolved file import {quoted}")
    return Check("minilang_packages_imports", not errors, {
        "ml_files": len(ml_files),
        "declared_packages": len(package_to_path),
        "imports_checked": imports_checked,
    }, errors)



def check_minilang_main_scope(root: Path) -> Check:
    """Reject MiniLang entrypoints declared inside a package.

    The native compiler requires main(args) to live in the global top-level
    scope.  Package modules may be imported by an entry file, but an entry file
    itself must not declare a package when it owns main(args).
    """
    errors: list[str] = []
    entry_files: list[str] = []
    packaged_entries: list[str] = []
    required_entries = {
        "tests/cvar_source_surface_tests.ml",
        "tests/cd_audio_source_surface_tests.ml",
        "tests/source_function_inventory_tests.ml",
        "tests/black_port_corpus_tests.ml",
        "tests/black_port_source_closure_tests.ml",
        "tests/game_profile_compat_tests.ml",
        "tests/mod_runtime_compat_tests.ml",
        "tests/artifact_compat_tests.ml",
        "tests/stability_contract_tests.ml",
        "tests/compatibility_release_closure_tests.ml",
        "tests/artifact_retail_evidence.ml",
    }
    seen_required: set[str] = set()
    ml_files = sorted((root / "src").rglob("*.ml")) + sorted((root / "tests").rglob("*.ml"))
    for path in ml_files:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        if not MAIN_RE.search(text):
            continue
        relative = path.relative_to(root).as_posix()
        entry_files.append(relative)
        if relative in required_entries:
            seen_required.add(relative)
        package = PACKAGE_RE.search(text)
        if package:
            packaged_entries.append(relative)
            errors.append(
                f"{relative}: main(args) is declared in package {package.group(1)}; "
                "MiniLang requires a global top-level entrypoint"
            )
    for relative in sorted(required_entries - seen_required):
        errors.append(f"{relative}: required main(args) entrypoint is missing")
    return Check("minilang_main_entry_scope", not errors, {
        "entry_files": len(entry_files),
        "required_current_entries": len(seen_required),
        "packaged_entries": len(packaged_entries),
    }, errors)


FUNCTION_RE = re.compile(
    r"(?m)^\s*(?:static\s+)?function(?:\s+inline)?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)"
)


def strip_minilang_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", lambda match: "\n" * match.group(0).count("\n"), text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def check_minilang_entry_helper_namespace(root: Path) -> Check:
    """Require block-local prefixes for helpers in the five global entry files.

    MiniLang merges a global entry file and its imported package closure. Generic
    helper names in the entry can therefore shadow unqualified package-internal
    calls. BP-080..084 use explicit per-step prefixes to keep their global main
    entrypoints collision-free.
    """
    required = {
        "tests/cvar_source_surface_tests.ml": "bp080",
        "tests/cd_audio_source_surface_tests.ml": "bp081",
        "tests/source_function_inventory_tests.ml": "bp082",
        "tests/black_port_corpus_tests.ml": "bp083",
        "tests/black_port_source_closure_tests.ml": "bp084",
        "tests/game_profile_compat_tests.ml": "bp085",
        "tests/mod_runtime_compat_tests.ml": "bp086",
        "tests/artifact_compat_tests.ml": "bp087",
        "tests/stability_contract_tests.ml": "bp088",
        "tests/compatibility_release_closure_tests.ml": "bp089",
        "tests/artifact_retail_evidence.ml": "bp087",
    }
    errors: list[str] = []
    helpers_checked = 0
    for relative, prefix in required.items():
        path = root / relative
        clean = strip_minilang_comments(path.read_text(encoding="utf-8-sig", errors="replace"))
        functions = [match.group(1) for match in FUNCTION_RE.finditer(clean)]
        if "main" not in functions:
            errors.append(f"{relative}: main(args) is missing")
        for name in functions:
            if name == "main":
                continue
            helpers_checked += 1
            if not name.startswith(prefix):
                errors.append(
                    f"{relative}: global helper '{name}' is not namespaced with prefix '{prefix}'"
                )
    return Check("minilang_entry_helper_namespace", not errors, {
        "entry_files": len(required),
        "helpers_checked": helpers_checked,
        "generic_helpers": len(errors),
    }, errors)


def check_minilang_entry_function_shadow_arity(root: Path) -> Check:
    """Reject package-free entry helpers that change an imported internal call.

    The native compiler merges the entry and complete import closure. A global
    entry helper can then be selected for an unqualified call inside an imported
    package. The observed R1 failure was check/2 shadowing miniquake.zone.check/1.
    """
    errors: list[str] = []
    src_files = sorted((root / "src").rglob("*.ml"))
    test_files = sorted((root / "tests").rglob("*.ml"))
    all_files = src_files + test_files

    package_to_path: dict[str, Path] = {}
    imports_by_file: dict[Path, list[str]] = {}
    functions_by_file: dict[Path, dict[str, int]] = {}
    internal_calls_by_file: dict[Path, set[str]] = {}
    clean_by_file: dict[Path, str] = {}

    import_pattern = re.compile(
        r'(?m)^\s*import\s+(?:"([^"]+)"|([A-Za-z_][A-Za-z0-9_.]*))'
        r'(?:\s+as\s+[A-Za-z_][A-Za-z0-9_]*)?\s*$'
    )
    for path in all_files:
        clean = strip_minilang_comments(path.read_text(encoding="utf-8-sig", errors="replace"))
        clean_by_file[path] = clean
        package_match = PACKAGE_RE.search(clean)
        if package_match:
            package_to_path[package_match.group(1)] = path
        imports: list[str] = []
        for match in import_pattern.finditer(clean):
            quoted, module = match.groups()
            if module:
                imports.append(module)
        imports_by_file[path] = imports
        functions: dict[str, int] = {}
        for match in FUNCTION_RE.finditer(clean):
            args = [item for item in match.group(2).split(",") if item.strip()]
            functions[match.group(1)] = len(args)
        functions_by_file[path] = functions

    for path, functions in functions_by_file.items():
        clean = clean_by_file[path]
        calls: set[str] = set()
        for name in functions:
            call_pattern = re.compile(r"(?<![A-Za-z0-9_.])" + re.escape(name) + r"\s*\(")
            definition_pattern = re.compile(
                r"^\s*(?:static\s+)?function(?:\s+inline)?\s+" + re.escape(name) + r"\s*\("
            )
            for line in clean.splitlines():
                if definition_pattern.search(line):
                    continue
                if call_pattern.search(line):
                    calls.add(name)
                    break
        internal_calls_by_file[path] = calls

    entries = [path for path in test_files if MAIN_RE.search(clean_by_file[path]) and not PACKAGE_RE.search(clean_by_file[path])]
    main_file = root / "src/main.ml"
    if main_file.is_file():
        entries.append(main_file)

    bindings_checked = 0
    largest_closure = 0
    for entry in entries:
        closure: set[Path] = set()
        pending = [entry]
        while pending:
            current = pending.pop()
            if current in closure:
                continue
            closure.add(current)
            for package_name in imports_by_file.get(current, []):
                imported = package_to_path.get(package_name)
                if imported is not None and imported not in closure:
                    pending.append(imported)
        largest_closure = max(largest_closure, len(closure))

        for entry_name, entry_arity in functions_by_file.get(entry, {}).items():
            if entry_name == "main":
                continue
            for imported in closure:
                if imported == entry:
                    continue
                imported_functions = functions_by_file.get(imported, {})
                if entry_name not in imported_functions:
                    continue
                if entry_name not in internal_calls_by_file.get(imported, set()):
                    continue
                bindings_checked += 1
                imported_arity = imported_functions[entry_name]
                if entry_arity != imported_arity:
                    package_match = PACKAGE_RE.search(clean_by_file[imported])
                    imported_name = package_match.group(1) if package_match else imported.relative_to(root).as_posix()
                    errors.append(
                        f"{entry.relative_to(root).as_posix()}: entry function '{entry_name}'/{entry_arity} "
                        f"shadows internally called {imported_name}.{entry_name}/{imported_arity}"
                    )

    return Check("minilang_entry_function_shadow_arity", not errors, {
        "entrypoints_checked": len(entries),
        "project_packages": len(package_to_path),
        "shadow_bindings_checked": bindings_checked,
        "arity_conflicts": len(errors),
        "largest_import_closure": largest_closure,
    }, errors)


def check_current_test_global_bindings(root: Path) -> Check:
    """Require explicit MiniLang global declarations in current fixtures."""
    errors: list[str] = []
    tests = {
        "tests/game_profile_compat_tests.ml": "bp085Check",
        "tests/mod_runtime_compat_tests.ml": "bp086Check",
        "tests/artifact_compat_tests.ml": "bp087Check",
        "tests/stability_contract_tests.ml": "bp088Check",
        "tests/compatibility_release_closure_tests.ml": "bp089Check",
    }
    checked = 0
    for relative, helper in tests.items():
        text = (root / relative).read_text(encoding="utf-8-sig", errors="replace")
        checked += 1
        if "passed = 0" not in text or "failed = 0" not in text:
            errors.append(f"{relative}: missing top-level fixture counters")
        helper_pattern = re.compile(
            rf"function\s+{re.escape(helper)}\s*\([^)]*\)\s*\n\s*global\s+passed\s*,\s*failed",
            re.MULTILINE,
        )
        main_pattern = re.compile(
            r"function\s+main\s*\(args\)\s*\n\s*global\s+passed\s*,\s*failed",
            re.MULTILINE,
        )
        if not helper_pattern.search(text):
            errors.append(f"{relative}: {helper} does not declare global passed, failed")
        if not main_pattern.search(text):
            errors.append(f"{relative}: main(args) does not declare global passed, failed")
    return Check(
        "current_test_global_bindings",
        not errors,
        {"tests_checked": checked, "global_counter_bindings": checked * 2},
        errors,
    )

def check_artifact_roundtrip_hotfix(root: Path) -> Check:
    """Bind the BP-087 sequential, exact Quake-v5 roundtrip correction."""
    errors: list[str] = []
    artifact = (root / "src/miniquake/artifact_compat.ml").read_text(encoding="utf-8-sig")
    runtime = (root / "src/miniquake/savegame_runtime.ml").read_text(encoding="utf-8-sig")
    savegame = (root / "src/miniquake/savegame.ml").read_text(encoding="utf-8-sig")
    common = (root / "src/miniquake/common.ml").read_text(encoding="utf-8-sig")
    bsp = (root / "src/miniquake/format/bsp.ml").read_text(encoding="utf-8-sig")
    qcedict = (root / "src/miniquake/quakec/edict.ml").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    evidence = (root / "tests/artifact_retail_evidence.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/artifact_compat_golden.json").read_text(encoding="utf-8-sig"))

    markers = {
        "artifact": [
            "function saveSemanticDifference(left, right)",
            "function firstByteDifference(left, right)",
        ],
        "runtime": [
            "function synchronizeLoadedServer(server)",
            "savedCount = server.numEdicts",
            "serverRuntime.syncLoadedQuakeCEdicts(server, savedCount)",
            "collision.linkEntity(server, index, false)",
        ],
        "savegame": [
            "server.mapName = saved.mapName",
            "return [common.cAtof(line[0]), line[1]]",
        ],
        "common": [
            "function cAtof(text)",
            "return native.bitsFloat(native.f32FromText(text))",
        ],
        "bsp": [
            "values[valueCount] = common.cAtof(decode(slice(source, start, i - start)))",
        ],
        "qcedict": [
            "vm.setGlobalFloat(machine, definition.offset, common.cAtof(value))",
            "vm.setEntityFloat(machine, entityIndex, definition.offset, common.cAtof(actualValue))",
        ],
        "host": [
            "import miniquake.savegame_runtime as saveRuntime",
            "saveRuntime.synchronizeLoadedServer(session.server)",
        ],
        "evidence": [
            'cleanA = try(bp087Shutdown(sessionA, "source"))',
            'cleanB = try(bp087Shutdown(sessionB, "target"))',
            'cleanC = try(bp087Shutdown(sessionC, "stability"))',
            "exactFirstPass = artifacts.bytesEqual(saveA, saveB)",
            "save byte roundtrip mismatch at offset",
            "stableExact = artifacts.bytesEqual(saveB, saveC)",
            "save_float_parse=-0.000000:",
            "diagnostics.u32Hex(signedZeroBits)",
            "C atof did not preserve negative zero",
        ],
    }
    texts = {
        "artifact": artifact,
        "runtime": runtime,
        "savegame": savegame,
        "common": common,
        "bsp": bsp,
        "qcedict": qcedict,
        "host": host,
        "evidence": evidence,
    }
    for label, wanted in markers.items():
        for marker in wanted:
            if marker not in texts[label]:
                errors.append(f"{label} missing marker: {marker}")

    load_start = host.find("function loadGame(")
    load_end = host.find("function setPlayerFlag(", load_start)
    load_body = host[load_start:load_end] if load_start >= 0 and load_end > load_start else ""
    if "server.syncQuakeCEdicts(session.server)" in load_body:
        errors.append("loadGame still recomputes and trims the saved edict high-water mark")

    order = [
        evidence.find('cleanA = try(bp087Shutdown(sessionA, "source"))'),
        evidence.find("sessionB = host.create("),
        evidence.find('cleanB = try(bp087Shutdown(sessionB, "target"))'),
        evidence.find("sessionC = host.create("),
        evidence.find('cleanC = try(bp087Shutdown(sessionC, "stability"))'),
    ]
    if min(order) < 0 or order != sorted(order):
        errors.append("retail save evidence does not use strictly sequential Host sessions")


    current_test = (root / "TEST_BP-085-089R8.ps1").read_text(encoding="utf-8-sig")
    if "first_pass_exact=true" not in current_test:
        errors.append("acceptance script does not require exact A/B save roundtrip")
    collector = (root / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    for marker in [
        "src\\miniquake\\savegame.ml",
        "src\\miniquake\\savegame_runtime.ml",
        "src\\miniquake\\host.ml",
        "src\\miniquake\\common.ml",
        "src\\miniquake\\format\\bsp.ml",
        "tools\\check_savegame_v5.py",
        "audit\\savegame_v5_golden.json",
        "patches\\BP-089R5.diff",
        "patches\\BP-089R6.diff",
        "patches\\BP-089R8.diff",
    ]:
        if marker not in collector:
            errors.append(f"collector missing save hotfix marker: {marker}")

    expected_golden = {
        "evidence_revision": "sequential_exact_fixed6_signedzero_v3",
        "semantic_boundary": "parsed_save_domain",
        "requires_exact_roundtrip": True,
        "requires_stable_reserialize": True,
        "preserves_edict_high_water": True,
        "live_vm_hashes_are_diagnostic": True,
        "simultaneous_host_sessions": False,
        "preserves_signed_zero": True,
        "float_parser": "msvcrt_strtod_f32",
    }
    for key, value in expected_golden.items():
        if golden.get(key) != value:
            errors.append(f"artifact golden {key} differs: {golden.get(key)!r}")

    fixed_golden = json.loads((root / "audit/savegame_fixed6_golden.json").read_text(encoding="utf-8-sig"))
    native_module = (root / "src/miniquake/native.ml").read_text(encoding="utf-8-sig")
    edict = (root / "src/miniquake/quakec/edict.ml").read_text(encoding="utf-8-sig")
    cvar = (root / "src/miniquake/cvar.ml").read_text(encoding="utf-8-sig")
    text_bridge = (root / "native/miniquake_text.c").read_text(encoding="utf-8-sig")
    text_def = (root / "native/miniquake_text.def").read_text(encoding="utf-8-sig")
    if golden.get("fixed_six_formatter") != "msvcrt_percent_f":
        errors.append("artifact golden fixed_six_formatter differs")
    if golden.get("fixed_six_large_positive") != "4097.000000" or golden.get("fixed_six_large_negative") != "-4097.000000":
        errors.append("artifact golden fixed-six 4097 values differ")
    if golden.get("text_bridge_export") != "mqt_f32_to_fixed6":
        errors.append("artifact golden text bridge export differs")
    if fixed_golden.get("formatter") != "msvcrt_percent_f" or fixed_golden.get("format") != "%.6f" or len(fixed_golden.get("cases", [])) != 8:
        errors.append("fixed-six golden corpus differs")
    required_fixed_markers = [
        (native_module, 'symbol "mqt_f32_to_fixed6"'),
        (native_module, "function fixedSixText(value)"),
        (edict, "return native.f32ToFixed6(rawWord & 0xffffffff)"),
        (cvar, "return native.fixedSixText(value)"),
        (text_bridge, "mqt_f32_to_fixed6"),
        (text_bridge, 'mq_crt_proc("sprintf")'),
        (text_bridge, '"%.6f"'),
        (text_def, "mqt_f32_to_fixed6"),
        (evidence, "save_float_format=4097:"),
    ]
    for text_value, marker in required_fixed_markers:
        if marker not in text_value:
            errors.append(f"fixed-six marker missing: {marker}")
    if "scaled = native.trunc(magnitude * 1000000.0 + 0.5)" in edict or "scaled = native.trunc(magnitude * 1000000.0 + 0.5)" in cvar:
        errors.append("legacy overflow-prone fixed-six formatter remains")
    if r"save_float_format=4097:4097\.000000 negative:-4097\.000000" not in current_test:
        errors.append("acceptance script does not require fixed-six 4097 evidence")
    if r"save_float_parse=-0\.000000:80000000" not in current_test:
        errors.append("acceptance script does not require signed-zero parse evidence")

    return Check(
        "artifact_save_roundtrip_hotfix",
        not errors,
        {
            "evidence_revision": golden.get("evidence_revision"),
            "semantic_boundary": golden.get("semantic_boundary"),
            "exact_roundtrip": golden.get("requires_exact_roundtrip"),
            "preserves_edict_high_water": golden.get("preserves_edict_high_water"),
            "sequential_host_sessions": golden.get("simultaneous_host_sessions") is False,
            "fixed_six_formatter": golden.get("fixed_six_formatter"),
            "fixed_six_cases": len(fixed_golden.get("cases", [])),
            "text_bridge_export": golden.get("text_bridge_export"),
            "preserves_signed_zero": golden.get("preserves_signed_zero"),
            "float_parser": golden.get("float_parser"),
        },
        errors,
    )



def check_quakec_edict_lineage(root: Path) -> Check:
    errors: list[str] = []
    checker = root / "tools/check_quakec_edict.py"
    report_path = root / "build/verify-quakec-edict-downstream.json"
    report_path.parent.mkdir(exist_ok=True)
    downstream = subprocess.run(
        [
            sys.executable,
            str(checker),
            "--root", str(root),
            "--allow-downstream-package",
            "--json-output", str(report_path),
        ],
        text=True,
        capture_output=True,
    )
    if downstream.returncode != 0:
        errors.append("downstream BP-022 checker failed: " + (downstream.stdout + downstream.stderr).strip())
    strict = subprocess.run(
        [sys.executable, str(checker), "--root", str(root)],
        text=True,
        capture_output=True,
    )
    if strict.returncode == 0:
        errors.append("historical BP-022 checker unexpectedly accepted the downstream formatter")
    report: dict[str, object] = {}
    if report_path.is_file():
        report = json.loads(report_path.read_text(encoding="utf-8-sig"))
        if report.get("downstream_package") is not True:
            errors.append("BP-022 downstream report does not identify downstream mode")
        if report.get("fixed_six_formatter") != "native_msvcrt_percent_f":
            errors.append("BP-022 downstream report has the wrong fixed-six formatter")
        if report.get("runtime_fixtures") != 22:
            errors.append("BP-022 runtime fixture count differs")
    else:
        errors.append("BP-022 downstream report was not created")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    wanted = "$QuakeCEdictChecker --root $Root --allow-downstream-package"
    if wanted not in build:
        errors.append("build.ps1 does not select the BP-022 downstream checker mode")
    return Check(
        "quakec_edict_downstream_lineage",
        not errors,
        {
            "downstream_passed": downstream.returncode == 0,
            "historical_rejected": strict.returncode != 0,
            "fixed_six_formatter": report.get("fixed_six_formatter"),
            "runtime_fixtures": report.get("runtime_fixtures"),
        },
        errors,
    )

def check_command_cvar_lineage(root: Path) -> Check:
    errors: list[str] = []
    checker = root / "tools/check_command_cvar.py"
    report_path = root / "build/verify-command-cvar-downstream.json"
    report_path.parent.mkdir(exist_ok=True)
    downstream = subprocess.run(
        [
            sys.executable,
            str(checker),
            "--root", str(root),
            "--allow-downstream-package",
            "--json-output", str(report_path),
        ],
        text=True,
        capture_output=True,
    )
    if downstream.returncode != 0:
        errors.append("downstream BP-031 checker failed: " + (downstream.stdout + downstream.stderr).strip())
    strict = subprocess.run(
        [sys.executable, str(checker), "--root", str(root)],
        text=True,
        capture_output=True,
    )
    if strict.returncode == 0:
        errors.append("historical BP-031 checker unexpectedly accepted the downstream formatter")
    report: dict[str, object] = {}
    if report_path.is_file():
        report = json.loads(report_path.read_text(encoding="utf-8-sig"))
        if report.get("downstream_package") is not True:
            errors.append("BP-031 downstream report does not identify downstream mode")
        if report.get("fixed_six_formatter") != "native_msvcrt_percent_f":
            errors.append("BP-031 downstream report has the wrong fixed-six formatter")
        if report.get("runtime_fixtures") != 20:
            errors.append("BP-031 runtime fixture count differs")
    else:
        errors.append("BP-031 downstream report was not created")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    if r'$Checker.Path -eq "tools\check_command_cvar.py"' not in build:
        errors.append("build.ps1 does not identify the BP-031 checker for downstream mode")
    if '$CheckerArguments += "--allow-downstream-package"' not in build:
        errors.append("build.ps1 does not select the BP-031 downstream checker mode")
    return Check(
        "command_cvar_downstream_lineage",
        not errors,
        {
            "downstream_passed": downstream.returncode == 0,
            "historical_rejected": strict.returncode != 0,
            "fixed_six_formatter": report.get("fixed_six_formatter"),
            "runtime_fixtures": report.get("runtime_fixtures"),
        },
        errors,
    )



def check_savegame_v5_lineage(root: Path) -> Check:
    errors: list[str] = []
    checker = root / "tools/check_savegame_v5.py"
    report_path = root / "build/verify-savegame-v5-downstream.json"
    report_path.parent.mkdir(exist_ok=True)
    downstream = subprocess.run(
        [
            sys.executable,
            str(checker),
            "--root", str(root),
            "--allow-downstream-package",
            "--json-output", str(report_path),
        ],
        text=True,
        capture_output=True,
    )
    if downstream.returncode != 0:
        errors.append("downstream BP-033 checker failed: " + (downstream.stdout + downstream.stderr).strip())
    strict = subprocess.run(
        [sys.executable, str(checker), "--root", str(root)],
        text=True,
        capture_output=True,
    )
    if strict.returncode == 0:
        errors.append("historical BP-033 checker unexpectedly accepted the downstream C-atof parser")
    report: dict[str, object] = {}
    if report_path.is_file():
        report = json.loads(report_path.read_text(encoding="utf-8-sig"))
        if report.get("downstream_package") is not True:
            errors.append("BP-033 downstream report does not identify downstream mode")
        if report.get("float_parser") != "native_strtod_f32":
            errors.append("BP-033 downstream report has the wrong float parser")
        if report.get("preserves_signed_zero") is not True:
            errors.append("BP-033 downstream report does not preserve signed zero")
        if report.get("runtime_fixtures") != 24:
            errors.append("BP-033 runtime fixture count differs")
    else:
        errors.append("BP-033 downstream report was not created")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    if r'$Checker.Path -eq "tools\check_savegame_v5.py"' not in build:
        errors.append("build.ps1 does not identify the BP-033 checker for downstream mode")
    if '$CheckerArguments += "--allow-downstream-package"' not in build:
        errors.append("build.ps1 does not select downstream checker mode")
    return Check(
        "savegame_v5_downstream_lineage",
        not errors,
        {
            "downstream_passed": downstream.returncode == 0,
            "historical_rejected": strict.returncode != 0,
            "float_parser": report.get("float_parser"),
            "preserves_signed_zero": report.get("preserves_signed_zero"),
            "runtime_fixtures": report.get("runtime_fixtures"),
        },
        errors,
    )

def check_quakec_sync_gc_roots(root: Path) -> Check:
    """Bind the R7 stable in-place QuakeC-to-server/player mirror."""
    errors: list[str] = []
    server = (root / "src/miniquake/server.ml").read_text(encoding="utf-8-sig")
    types = (root / "src/miniquake/types.ml").read_text(encoding="utf-8-sig")
    save_runtime = (root / "src/miniquake/savegame_runtime.ml").read_text(encoding="utf-8-sig")
    diagnostics = (root / "tests/compat_trace_tests.ml").read_text(encoding="utf-8-sig")
    test = (root / "TEST_BP-085-089R8.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")

    type_markers = [
        "function isEntityBaselineValue(value)",
        '"miniquake.types.EntityBaseline"',
        "function isQuakeEdictValue(value)",
        '"miniquake.types.QuakeEdict"',
    ]
    for marker in type_markers:
        if marker not in types:
            errors.append(f"stable mirror type marker missing: {marker}")

    server_markers = [
        "function requireSynchronizedVector(value, entityIndex, fieldName)",
        "function synchronizedVectorTarget(value, entityIndex, fieldName, x, y, z)",
        "function setSynchronizedVector(value, entityIndex, fieldName, x, y, z)",
        "function syncQcVectorInto(machine, entityIndex, fieldName, target, x, y, z)",
        "function resizeSynchronizedEdictArray(server, requiredCount)",
        "function ensureSynchronizedBaseline(item, entityIndex)",
        "function ensureSynchronizedEdict(server, entityIndex)",
        "function syncQuakeCEdictRange(server, count)",
        "function syncLoadedQuakeCEdicts(server, savedCount)",
        "result = synchronizedVectorTarget(target, entityIndex, fieldName, x, y, z)",
        "item = ensureSynchronizedEdict(server, entityIndex)",
        "server.edicts[index] = synchronized",
        "count = runtime.numEdicts",
        "return syncQuakeCEdictRange(server, count)",
        "return syncQuakeCEdictRange(server, savedCount)",
        "player.origin = origin",
        "player.viewHeight = vm.entityFloat(machine, entityIndex, viewOffset + 2)",
    ]
    for marker in server_markers:
        if marker not in server:
            errors.append(f"stable mirror server marker missing: {marker}")

    forbidden = [
        "result = arrayutil.makeEmptyArray(server.numEdicts)",
        "result[index] = syncQuakeCEdict(server, index)",
        'item.origin = qcVector(machine, entityIndex, "origin",',
        'player.origin = qcVector(server.machine, entityIndex, "origin",',
        "highest = server.maxClients",
    ]
    for marker in forbidden:
        if marker in server:
            errors.append(f"allocation-sensitive mirror pattern remains: {marker}")

    if "serverRuntime.syncLoadedQuakeCEdicts(server, savedCount)" not in save_runtime:
        errors.append("savegame runtime does not restore the explicit edict high-water mark through the stable mirror")

    diagnostic_markers = [
        "function bp001TestSynchronizedEdictGcRoots()",
        "entityCount = 227",
        "runtime.numEdicts = entityCount",
        "gc_set_limit(256)",
        "while pass < 80",
        "stableEdictRaw = nativeRawValue(stableEdict)",
        'assertEqual(nativeRawValue(item), stableEdictRaw, "stable QuakeEdict identity")',
        'assertEqual(nativeRawValue(item.origin), stableOriginRaw, "stable origin identity")',
        'assertEqual(item.origin.x, 77.25 + pass, "stable origin refresh")',
        'assertEqual(synchronizedCount, entityCount, "freed tail keeps high-water mark")',
        'assertEqual(len(game.edicts), entityCount, "freed tail keeps stable array length")',
        "gc_set_limit(1048576)",
    ]
    for marker in diagnostic_markers:
        if marker not in diagnostics:
            errors.append(f"stable mirror diagnostic marker missing: {marker}")

    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    if r'Invoke-MiniLangCompile -InputFile (Join-Path $Root "tests\compat_trace_tests.ml")' not in build:
        errors.append("build.ps1 does not compile the diagnostics regression")
    if '-Label "BP-001R3 diagnostics regression tests"' not in build:
        errors.append("build.ps1 does not execute the diagnostics regression")
    if "single cumulative build and unit-test suite" not in test:
        errors.append("R7 acceptance script does not run the cumulative diagnostics-bearing build")
    for marker in [
        "TEST_BP-085-089R8.ps1",
        "docs\\BP-085-089R8_RESULT_ANALYSIS.md",
        "patches\\BP-089R8.diff",
    ]:
        if marker not in collector:
            errors.append(f"collector missing R7 marker: {marker}")

    return Check(
        "quakec_stable_edict_mirror",
        not errors,
        {
            "mirrored_edicts": 227,
            "forced_sync_passes": 80,
            "periodic_gc_limit": 256,
            "stable_identity_checks": 4,
            "preserves_high_water_mark": True,
            "public_diagnostics_tests": 10,
        },
        errors,
    )


def check_listen_soak_highwater(root: Path) -> Check:
    """Bind the R8 listen-server entity high-water stability correction."""
    errors: list[str] = []
    stability = (root / "src/miniquake/stability_contract.ml").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    tests = (root / "tests/stability_contract_tests.ml").read_text(encoding="utf-8-sig")
    checker = (root / "tools/check_compat_088.py").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/stability_golden.json").read_text(encoding="utf-8-sig"))
    acceptance = (root / "TEST_BP-085-089R8.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")

    stability_markers = [
        "function clientEntityLimit(serverBefore, serverAfter, entitiesBefore)",
        "staticOffset = entitiesBefore - serverBefore",
        "function clientEntityHighWaterStable(serverBefore, serverAfter, entitiesBefore, entitiesAfter)",
        "entitiesStable = clientEntityHighWaterStable(before[4], after[4], before[5], after[5])",
        "function longChecks(before, after)",
        "after[4] <= before[4]",
        "const FINGERPRINT = 0xd0e3c03f",
    ]
    for marker in stability_markers:
        if marker not in stability:
            errors.append(f"stability contract missing R8 marker: {marker}")

    host_markers = [
        "import miniquake.stability_contract as stability",
        "return stability.longStable(before, after)",
        "client entity high-water limit=",
        "stability gates: heap=",
    ]
    for marker in host_markers:
        if marker not in host:
            errors.append(f"host soak missing R8 marker: {marker}")

    test_markers = [
        "[15/20] client entity high-water catch-up",
        "stability.clientEntityLimit(67, 67, 66) == 67",
        "[16/20] topology growth rejected",
        "not stability.longStable(catchupBefore, serverGrowth)",
    ]
    for marker in test_markers:
        if marker not in tests:
            errors.append(f"stability fixture missing R8 marker: {marker}")

    if golden.get("client_entity_policy") != "server_high_water_plus_existing_static_offset":
        errors.append("R8 client entity policy differs")
    cases = golden.get("client_entity_cases")
    if not isinstance(cases, list) or len(cases) != 5:
        errors.append("R8 client entity golden corpus differs")
    else:
        observed = next((case for case in cases if case.get("name") == "r7_listen_catch_up"), None)
        if observed != {
            "name": "r7_listen_catch_up",
            "server_before": 67,
            "server_after": 67,
            "entities_before": 66,
            "entities_after": 67,
            "expected_limit": 67,
            "stable": True,
        }:
            errors.append("R7 observed listen catch-up golden differs")

    if "r7_observed_case_passes" not in checker:
        errors.append("BP-088 checker does not bind the observed R7 case")
    if '$DeliveryRevision = "BP-085-089R8"' not in acceptance or "5000-frame listen-server resource soak" not in acceptance:
        errors.append("R8 acceptance script does not run the listen-server soak")
    for marker in [
        "TEST_BP-085-089R8.ps1",
        r"docs\BP-085-089R8_RESULT_ANALYSIS.md",
        r"patches\BP-089R8.diff",
    ]:
        if marker not in collector:
            errors.append(f"collector missing R8 marker: {marker}")

    return Check(
        "listen_soak_entity_highwater",
        not errors,
        {
            "policy": golden.get("client_entity_policy"),
            "observed_server_highwater": 67,
            "observed_client_before": 66,
            "observed_client_after": 67,
            "observed_limit": 67,
            "leak_sensitive_limits_unchanged": True,
        },
        errors,
    )


def check_native(root: Path) -> Check:
    errors: list[str] = []
    details: dict[str, object] = {}
    for relative, (expected_hash, expected_count, def_relative) in EXPECTED_NATIVE.items():
        path = root / relative
        found = digest(path)
        if found != expected_hash:
            errors.append(f"native hash mismatch: {relative}")
        exports = []
        in_exports = False
        for raw in (root / def_relative).read_text(encoding="ascii", errors="replace").splitlines():
            line = raw.strip()
            if line.upper() == "EXPORTS":
                in_exports = True
                continue
            if in_exports and line and not line.startswith(";"):
                exports.append(line.split()[0])
        if len(exports) != expected_count:
            errors.append(f"{def_relative}: expected {expected_count} exports, got {len(exports)}")
        data = path.read_bytes()
        if data[:2] != b"MZ":
            errors.append(f"{relative}: not a PE image")
        details[relative] = {"sha256": found, "def_exports": len(exports), "bytes": len(data)}
    return Check("native_bridges", not errors, details, errors)


def check_no_game_data(root: Path) -> Check:
    errors: list[str] = []
    scanned = 0
    for path in all_package_files(root):
        scanned += 1
        relative = path.relative_to(root)
        name = path.name.lower()
        if name in FORBIDDEN_NAMES or path.suffix.lower() in FORBIDDEN_SUFFIXES:
            # Documentation images are not part of this delivery; any matching
            # binary-looking source-tree file is therefore suspicious.
            errors.append(f"forbidden Quake game-data-shaped file: {relative.as_posix()}")
        if any(part.lower() in {"id1", "hipnotic", "rogue"} for part in relative.parts):
            errors.append(f"forbidden Quake game-directory path: {relative.as_posix()}")
    return Check("no_quake_game_data", not errors, {"files_scanned": scanned}, errors)


def check_powershell(root: Path) -> Check:
    errors: list[str] = []
    current_names = [
        "build.ps1",
        "TEST_BP-085-089R8.ps1",
        "COLLECT_RESULTS.ps1",
        "test.ps1",
    ]
    scripts = [root / name for name in current_names]
    comma_pattern = re.compile(r",\s*(?:\r?\n\s*)?\)")
    for path in scripts:
        text = path.read_text(encoding="utf-8-sig", errors="replace")
        if comma_pattern.search(text):
            errors.append(f"{path.name}: comma immediately before closing parenthesis")
        if re.search(r"\$\w+\s*=\s*@\(\s*&\s+", text):
            errors.append(f"{path.name}: fully buffered child-process output")
    current_test = (root / "TEST_BP-085-089R8.ps1").read_text(encoding="utf-8-sig")
    if "Invoke-LiveProcess" not in current_test or "$Writer.Flush()" not in current_test:
        errors.append("current acceptance script does not stream and flush output")
    return Check("powershell_delivery", not errors, {"scripts_checked": len(scripts)}, errors)


def check_source_contract(root: Path) -> Check:
    errors: list[str] = []
    reports: dict[str, object] = {}
    for number in range(80, 85):
        script = root / "tools" / f"check_source_{number:03d}.py"
        report = root / "build" / f"verify-source-{number:03d}.json"
        report.parent.mkdir(exist_ok=True)
        command = [sys.executable, str(script), "--root", str(root), "--json", str(report)]
        if number == 84:
            command.append("--allow-downstream-package")
        process = subprocess.run(
            command,
            text=True,
            capture_output=True,
        )
        if process.returncode != 0:
            errors.append(f"{script.name} failed: {process.stdout}{process.stderr}".strip())
        if report.is_file():
            reports[f"BP-{number:03d}"] = json.loads(report.read_text())
    inventory = json.loads((root / "audit/source_function_inventory.json").read_text())
    if inventory.get("missing_names") != []:
        errors.append("source inventory contains unclassified functions")
    if inventory.get("target_definitions") != 1094:
        errors.append("source inventory target definition count differs")
    return Check("black_port_source_contract", not errors, {
        "reports": reports,
        "target_definitions": inventory.get("target_definitions"),
        "coverage_percent": inventory.get("coverage_percent"),
        "inventory_sha256": inventory.get("inventory_sha256"),
    }, errors)


def check_compatibility_contracts(root: Path) -> Check:
    errors: list[str] = []
    reports: dict[str, object] = {}
    for number in range(85, 90):
        script = root / "tools" / f"check_compat_{number:03d}.py"
        report = root / "build" / f"verify-compat-{number:03d}.json"
        report.parent.mkdir(exist_ok=True)
        process = subprocess.run(
            [sys.executable, str(script), "--root", str(root), "--json", str(report)],
            text=True,
            capture_output=True,
        )
        if process.returncode != 0:
            errors.append(f"{script.name} failed: {process.stdout}{process.stderr}".strip())
        if report.is_file():
            reports[f"BP-{number:03d}"] = json.loads(report.read_text())
    matrix = json.loads((root / "audit/compat_release_golden.json").read_text())
    if matrix.get("status") != "compat_109_release_candidate_v1":
        errors.append("compatibility release status differs")
    if matrix.get("pending_external_gates") != ["original_binary_interop", "external_glquake_visual_reference"]:
        errors.append("pending external gate list differs")
    accepted = matrix.get("accepted_contracts")
    if not isinstance(accepted, list) or len(accepted) != 18:
        errors.append("accepted compatibility contract list differs")
    required_contracts = {
        "protocol15_frozen_v1", "quakec_109_frozen_v1",
        "world_physics_109_frozen_v1", "host_lifecycle_109_frozen_v1",
        "client_render_109_frozen_v1", "world_render_109_frozen_v1",
        "model_ui_render_109_frozen_v1", "render_special_109_frozen_v1",
        "audio_109_frozen_v1", "network_platform_109_frozen_v1",
        "frontend_109_frozen_v1", "core_assets_memory_109_frozen_v1",
        "gameplay_presentation_109_frozen_v1", "black_port_source_109_frozen_v1",
        "game_profile_109_frozen_v1", "mod_runtime_109_frozen_v1",
        "artifact_compat_109_frozen_v1", "stability_109_frozen_v1",
    }
    if set(accepted or []) != required_contracts:
        errors.append("accepted compatibility contract contents differ")
    return Check("compatibility_release_contract", not errors, {
        "reports": reports,
        "accepted_contracts": accepted,
        "pending_external_gates": matrix.get("pending_external_gates"),
        "fingerprint": matrix.get("fingerprint"),
    }, errors)

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--json", default="")
    args = parser.parse_args()
    root = Path(args.root).resolve()

    checks = [
        check_required(root),
        check_manifest(root),
        check_identity(root),
        check_minilang_imports(root),
        check_minilang_main_scope(root),
        check_minilang_entry_helper_namespace(root),
        check_minilang_entry_function_shadow_arity(root),
        check_current_test_global_bindings(root),
        check_artifact_roundtrip_hotfix(root),
        check_quakec_edict_lineage(root),
        check_command_cvar_lineage(root),
        check_savegame_v5_lineage(root),
        check_quakec_sync_gc_roots(root),
        check_listen_soak_highwater(root),
        check_native(root),
        check_no_game_data(root),
        check_powershell(root),
        check_source_contract(root),
        check_compatibility_contracts(root),
    ]
    passed = all(check.passed for check in checks)
    for check in checks:
        label = "PASS" if check.passed else "FAIL"
        print(f"  [{label}] {check.name}")
        for key, value in check.details.items():
            if key != "reports":
                print(f"         {key}={value}")
        for error in check.errors:
            print(f"         error: {error}")
    print(f"MiniQuake BP-085-089R8 verification: {'PASS' if passed else 'FAIL'}")

    document = {
        "schema_version": 1,
        "package_id": PACKAGE_ID,
        "delivery_revision": DELIVERY_REVISION,
        "root": str(root),
        "passed": passed,
        "checks": [asdict(check) for check in checks],
    }
    if args.json:
        Path(args.json).write_text(json.dumps(document, indent=2) + "\n")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
