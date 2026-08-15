#!/usr/bin/env python3
"""Self-contained integrity and source-hygiene verifier for MiniQuake.

Historical subsystem semantics are checked by the source-guided component
checkers invoked from build.ps1.  This verifier owns current delivery
integrity, identity, import/entrypoint hygiene, native bridge identity,
external-reference policy and the BP-090--BP-094 source contracts.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

MANIFEST = "SOURCE_MANIFEST.sha256"

EXCLUDED_DIRS = {
    ".git", "build", "build_perf", "__pycache__", ".pytest_cache",
    "text_build",
}
FORBIDDEN_SUFFIXES = {
    ".pak", ".bsp", ".mdl", ".spr", ".wad", ".dem", ".sav", ".lmp",
    ".pcx", ".tga", ".ogg", ".wav", ".lit", ".vis",
}
FORBIDDEN_NAMES = {
    "progs.dat", "gfx.wad", "palette.lmp", "colormap.lmp",
    "glquake.exe", "opengl32.dll", "originalquakesourcecode.zip",
}

_LEGACY_REQUIRED_PATHS = {
    "TEST_OPT-001D.ps1", "docs/archive/changelog/CHANGELOG_OPT-001D.md",
    "docs/archive/releases/OPT-001D_TESTING.md", "docs/archive/releases/OPT-001D_CHANGELOG.md",
    "docs/archive/releases/OPT-001D_RESULT_ANALYSIS.md", "docs/archive/releases/OPT-001D_HOTFIX_REPORT.json",
    "audit/opt001d_audio_transition_hotpath.json", "tools/check_opt001d.py",
    "tools/analyze_opt001d_audio.py", "patches/OPT-001D.diff",
    "TEST_OPT-001CR3R6.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR3R6.md",
    "docs/archive/releases/OPT-001CR3R6_TESTING.md", "docs/archive/releases/OPT-001CR3R6_CHANGELOG.md",
    "docs/archive/releases/OPT-001CR3R6_RESULT_ANALYSIS.md", "docs/archive/releases/OPT-001CR3R6_HOTFIX_REPORT.json",
    "audit/opt001cr3r6_windowed_transition.json", "tools/check_opt001cr3r6.py",
    "patches/OPT-001CR3R6.diff",
    "TEST_OPT-001CR3R2.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR3R2.md",
    "docs/archive/releases/OPT-001CR3R2_TESTING.md", "docs/archive/releases/OPT-001CR3R2_CHANGELOG.md",
    "docs/archive/releases/OPT-001CR3R2_RESULT_ANALYSIS.md", "docs/archive/releases/OPT-001CR3R2_HOTFIX_REPORT.json",
    "tools/run_process_live.py", "audit/opt001cr3r2_live_exitcode.json",
    "patches/OPT-001CR3R2.diff",
    "TEST_OPT-001CR3R1.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR3R1.md",
    "docs/archive/releases/OPT-001CR3R1_TESTING.md", "docs/archive/releases/OPT-001CR3R1_CHANGELOG.md",
    "docs/archive/releases/OPT-001CR3R1_RESULT_ANALYSIS.md", "docs/archive/releases/OPT-001CR3R1_HOTFIX_REPORT.json",
    "audit/opt001cr3r1_compiler_safe_inline.json", "patches/OPT-001CR3R1.diff",
    "TEST_OPT-001CR3.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR3.md",
    "docs/archive/releases/OPT-001CR3_TESTING.md", "docs/archive/releases/OPT-001CR3_CHANGELOG.md",
    "docs/archive/releases/OPT-001CR3_DELIVERY_REPORT.json", "patches/OPT-001CR3.diff",
    "tests/opt001cr3_hotpath_tests.ml", "tools/check_opt001cr3.py",
    "tools/compare_opt001cr3_performance.py", "audit/opt001cr3_inline_array_hotpath.json",
    "audit/opt001cr2_accepted_baseline.json",
    "TEST_OPT-001CR2.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR2.md",
    "docs/archive/releases/OPT-001CR2_TESTING.md", "docs/archive/releases/OPT-001CR2_RESULT_ANALYSIS.md",
    "docs/archive/releases/OPT-001CR2_HOTFIX_REPORT.json", "docs/archive/releases/OPT-001CR2_DELIVERY_REPORT.json",
    "patches/OPT-001CR2.diff", "tools/check_opt001cr2.py",
    "audit/opt001cr2_harness_golden.json",
    "TEST_OPT-001CR1.ps1", "docs/archive/changelog/CHANGELOG_OPT-001CR1.md",
    "docs/archive/releases/OPT-001CR1_TESTING.md", "docs/archive/releases/OPT-001CR1_RESULT_ANALYSIS.md",
    "docs/archive/releases/OPT-001CR1_HOTFIX_REPORT.json", "docs/archive/releases/OPT-001CR1_DELIVERY_REPORT.json",
    "patches/OPT-001CR1.diff", "tools/check_opt001cr1.py",
    "tools/check_minilang_delimiters.py", "audit/opt001cr1_syntax_golden.json",
    "TEST_OPT-001C.ps1", "docs/archive/changelog/CHANGELOG_OPT-001C.md",
    "docs/archive/releases/OPT-001C_TESTING.md", "docs/archive/releases/OPT-001C_ALLOCATION_CONTRACT.md",
    "docs/archive/releases/OPT-001C_DELIVERY_REPORT.json", "patches/OPT-001C.diff",
    "tests/opt001c_contract_tests.ml", "tools/check_opt001c.py",
    "tools/compare_opt001c_performance.py",
    "audit/opt001c_allocation_golden.json", "audit/opt001b_performance_baseline.json",
    "TEST_OPT-001B.ps1", "docs/archive/changelog/CHANGELOG_OPT-001B.md",
    "docs/archive/releases/OPT-001B_TESTING.md", "docs/archive/releases/OPT-001B_CORRECTNESS_CONTRACT.md",
    "docs/archive/releases/OPT-001B_DELIVERY_REPORT.json", "patches/OPT-001B.diff",
    "tests/opt001b_contract_tests.ml", "tools/check_opt001b.py",
    "audit/opt001b_correctness_golden.json",
    "TEST_OPT-001A.ps1", "docs/archive/changelog/CHANGELOG_OPT-001A.md",
    "docs/archive/releases/OPT-001A_TESTING.md", "docs/archive/releases/OPT-001A_BASELINE_CONTRACT.md",
    "docs/archive/releases/OPT-001A_DELIVERY_REPORT.json", "patches/OPT-001A.diff",
    "src/miniquake/optimization_baseline.ml", "tests/opt001a_contract_tests.ml",
    "tools/check_opt001a.py", "tools/analyze_opt001a.py",
    "audit/opt001a_baseline_golden.json",
    "COPYING", "README.md", "build.ps1", "COLLECT_RESULTS.ps1", "test.ps1",
    "TEST_BP-090-094.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094.md",
    "TEST_BP-090-094R15.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R15.md",
    "docs/archive/releases/BP-090-094R15_TESTING.md", "docs/archive/releases/BP-090-094R15_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R15_HOTFIX_REPORT.json", "patches/BP-094R15.diff",
    "TEST_BP-090-094R14.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R14.md",
    "docs/archive/releases/BP-090-094R14_TESTING.md", "docs/archive/releases/BP-090-094R14_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R14_HOTFIX_REPORT.json", "patches/BP-094R14.diff",
    "TEST_BP-090-094R13.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R13.md",
    "docs/archive/releases/BP-090-094R13_TESTING.md", "docs/archive/releases/BP-090-094R13_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R13_HOTFIX_REPORT.json", "patches/BP-094R13.diff",
    "TEST_BP-090-094R12.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R12.md",
    "docs/archive/releases/BP-090-094R12_TESTING.md", "docs/archive/releases/BP-090-094R12_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R12_HOTFIX_REPORT.json", "patches/BP-094R12.diff",
    "TEST_BP-090-094R11.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R11.md",
    "docs/archive/releases/BP-090-094R11_TESTING.md", "docs/archive/releases/BP-090-094R11_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R11_HOTFIX_REPORT.json", "patches/BP-094R11.diff",
    "TEST_BP-090-094R10.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R10.md",
    "docs/archive/releases/BP-090-094R10_TESTING.md", "docs/archive/releases/BP-090-094R10_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R10_HOTFIX_REPORT.json", "patches/BP-094R10.diff",
    "TEST_BP-090-094R9.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R9.md",
    "docs/archive/releases/BP-090-094R9_TESTING.md", "docs/archive/releases/BP-090-094R9_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R9_HOTFIX_REPORT.json", "patches/BP-094R9.diff",
    "TEST_BP-090-094R8.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R8.md",
    "docs/archive/releases/BP-090-094R8_TESTING.md", "docs/archive/releases/BP-090-094R8_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R8_HOTFIX_REPORT.json", "docs/archive/releases/BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.md",
    "docs/archive/releases/BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.json", "patches/BP-094R8.diff",
    "TEST_BP-090-094R7.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R7.md",
    "docs/archive/releases/BP-090-094R7_TESTING.md", "docs/archive/releases/BP-090-094R7_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R7_HOTFIX_REPORT.json", "patches/BP-094R7.diff",
    "TEST_BP-090-094R6.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R6.md",
    "docs/archive/releases/BP-090-094R6_TESTING.md", "docs/archive/releases/BP-090-094R6_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R6_HOTFIX_REPORT.json", "patches/BP-094R6.diff",
    "TEST_BP-090-094R5.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R5.md",
    "docs/archive/releases/BP-090-094R5_TESTING.md", "docs/archive/releases/BP-090-094R5_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R5_HOTFIX_REPORT.json", "patches/BP-094R5.diff",
    "TEST_BP-090-094R4.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R4.md",
    "docs/archive/releases/BP-090-094R4_TESTING.md", "docs/archive/releases/BP-090-094R4_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R4_HOTFIX_REPORT.json", "patches/BP-094R4.diff",
    "TEST_BP-090-094R3.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R3.md",
    "docs/archive/releases/BP-090-094R3_TESTING.md", "docs/archive/releases/BP-090-094R3_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R3_HOTFIX_REPORT.json", "patches/BP-094R3.diff",
    "TEST_BP-090-094R2.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R2.md",
    "docs/archive/releases/BP-090-094R2_TESTING.md", "docs/archive/releases/BP-090-094R2_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R2_HOTFIX_REPORT.json", "patches/BP-094R2.diff",
    "TEST_BP-090-094R1.ps1", "docs/archive/changelog/CHANGELOG_BP-090-094R1.md",
    "docs/archive/releases/BP-090-094R1_TESTING.md", "docs/archive/releases/BP-090-094R1_RESULT_ANALYSIS.md",
    "docs/archive/releases/BP-090-094R1_HOTFIX_REPORT.json", "patches/BP-094R1.diff",
    "BLOCK_LEDGER.json",
    "PORT_LEDGER.json", "docs/status/PORT_STATUS.md", MANIFEST,
    "docs/archive/releases/BP-090-094_TESTING.md", "docs/archive/releases/BP-085-089R8_ACCEPTANCE_ANALYSIS.md",
    "src/main.ml", "src/miniquake/build_info.ml", "src/miniquake/host.ml",
    "src/miniquake/external_reference_contract.ml",
    "tests/original_reference_provenance_tests.ml",
    "tests/original_server_interop_tests.ml",
    "tests/original_client_interop_tests.ml",
    "tests/original_visual_reference_tests.ml",
    "tests/external_compat_closure_tests.ml",
    "tools/prepare_original_reference.py", "tools/compare_original_reference.py",
    "tools/check_external_090.py", "tools/check_external_091.py",
    "tools/check_external_092.py", "tools/check_external_093.py",
    "tools/check_external_094.py",
    "audit/original_reference_golden.json",
    "audit/original_server_interop_golden.json",
    "audit/original_client_interop_golden.json",
    "audit/original_client_port_routing_golden.json",
    "audit/original_visual_reference_golden.json",
    "audit/external_compat_closure_golden.json",
    "native/miniquake_native.dll", "native/miniquake_native.def",
    "native/miniquake_text.dll", "native/miniquake_text.def",
    "patches/BP-090.diff", "patches/BP-091.diff", "patches/BP-092.diff",
    "patches/BP-093.diff", "patches/BP-094.diff",
}

# Historical root-level PowerShell entry points now live together in scripts/.
# Keep the legacy inventory readable while resolving those entries canonically.
_LEGACY_REQUIRED_PATHS = {
    f"scripts/{path}"
    if path.endswith(".ps1") and path != "build.ps1" and "/" not in path
    else path
    for path in _LEGACY_REQUIRED_PATHS
}

CURRENT_REQUIRED_PATHS = {
    ".gitignore", "COPYING", "LICENSES/Apache-2.0.txt", "README.md",
    "docs/CHANGELOG.md", "docs/archive/README.md",
    "docs/native/README.md", "docs/status/PORT_STATUS.md",
    "SOURCE_MANIFEST.sha256", "build.ps1", "scripts/test.ps1",
    "src/main.ml", "src/miniquake/build_info.ml",
    "native/build_bridge.py", "native/build_text_bridge.py",
    "native/miniquake_native.c", "native/miniquake_native.h",
    "native/miniquake_native.def", "native/miniquake_native.dll",
    "native/miniquake_text.c", "native/miniquake_text.def",
    "native/miniquake_text.dll", "native/miniquake_d3d9.c",
    "native/miniquake_d3d9.h", "native/miniquake_vulkan.c",
    "native/miniquake_vulkan.h", "native/miniquake_vulkan_shaders.h",
    "native/shaders/miniquake_vulkan.vert",
    "native/shaders/miniquake_vulkan.frag",
    "native/shaders/miniquake_vulkan.vert.spv",
    "native/shaders/miniquake_vulkan.frag.spv",
    "third_party/stb/stb_vorbis.c",
    "third_party/Vulkan-Headers/MINIQUAKE-VENDOR.txt",
    "third_party/Vulkan-Headers/LICENSE.md",
    "tools/check_minilang_delimiters.py",
    "tools/check_source_documentation.py",
    "tools/apply_source_documentation.py", "tools/embed_spirv.py",
}

NATIVE_BRIDGES = {
    "native/miniquake_native.dll": ("native/miniquake_native.def", 178),
    "native/miniquake_text.dll": ("native/miniquake_text.def", 12),
}


@dataclass
class Check:
    name: str
    passed: bool
    details: dict[str, object]
    errors: list[str]


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for block in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def package_files(root: Path) -> list[Path]:
    """Return deliverable files while excluding generated build/report trees."""
    result: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(root)
        if any(part in EXCLUDED_DIRS for part in rel.parts):
            continue
        if rel.as_posix() == MANIFEST:
            continue
        if rel.parts[:2] in (("native", "build"), ("native", "text_build")):
            continue
        result.append(path)
    return sorted(result, key=lambda p: p.relative_to(root).as_posix().lower())


def refresh_manifest(root: Path) -> int:
    """Atomically bind the manifest to the current deliverable file set."""
    entries = [
        f"{sha256(path)} *{path.relative_to(root).as_posix()}\n"
        for path in package_files(root)
    ]
    destination = root / MANIFEST
    temporary = destination.with_suffix(destination.suffix + ".tmp")
    temporary.write_text("".join(entries), encoding="utf-8", newline="\n")
    temporary.replace(destination)
    return len(entries)


def parse_manifest(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        if not raw.strip():
            continue
        match = re.fullmatch(r"([0-9a-fA-F]{64})\s+\*?(.+)", raw)
        if not match:
            raise ValueError(f"invalid manifest line {number}: {raw!r}")
        rel = match.group(2).replace("\\", "/")
        if rel in values:
            raise ValueError(f"duplicate manifest path: {rel}")
        values[rel] = match.group(1).lower()
    return values


def check_required(root: Path) -> Check:
    """Require the current engine, renderer, licensing and verification surface."""
    missing = sorted(rel for rel in CURRENT_REQUIRED_PATHS if not (root / rel).is_file())
    return Check(
        "required_paths", not missing,
        {"required": len(CURRENT_REQUIRED_PATHS)},
        [f"missing: {path}" for path in missing],
    )


def check_manifest(root: Path) -> Check:
    errors: list[str] = []
    try:
        listed = parse_manifest(root / MANIFEST)
    except Exception as exc:
        return Check("source_manifest", False, {}, [str(exc)])
    actual = {p.relative_to(root).as_posix(): p for p in package_files(root)}
    for rel in sorted(set(actual) - set(listed)):
        errors.append(f"file is not listed in manifest: {rel}")
    for rel in sorted(set(listed) - set(actual)):
        errors.append(f"manifest path is missing: {rel}")
    for rel in sorted(set(actual) & set(listed)):
        if sha256(actual[rel]) != listed[rel]:
            errors.append(f"hash mismatch: {rel}")
    return Check(
        "source_manifest", not errors,
        {"listed_files": len(listed), "actual_files": len(actual), "manifest_sha256": sha256(root / MANIFEST)},
        errors,
    )


def marker_errors(text: str, markers: list[str], label: str) -> list[str]:
    return [f"{label} missing marker: {m}" for m in markers if m not in text]


def check_identity(root: Path) -> Check:
    """Read package identity from the authoritative MiniLang build-info unit."""
    errors: list[str] = []
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    values: dict[str, str] = {}
    for name in (
        "PACKAGE_ID", "PARENT_PACKAGE_ID", "BLOCK_ID",
        "BLOCK_PARENT_PACKAGE_ID", "OPTIMIZATION_STATUS",
        "OPTIMIZATION_PARENT", "OPTIMIZATION_DELIVERY_REVISION",
        "OPTIMIZATION_DELIVERY_PARENT",
    ):
        match = re.search(rf'^const {name} = "([^"]+)"$', build_info, re.M)
        if match:
            values[name] = match.group(1)
        else:
            errors.append(f"build_info missing string constant: {name}")
    return Check(
        "package_identity", not errors,
        {"package_id": values.get("PACKAGE_ID", ""),
         "parent_package_id": values.get("PARENT_PACKAGE_ID", ""),
         "block_id": values.get("BLOCK_ID", ""),
         "delivery_revision": values.get("OPTIMIZATION_DELIVERY_REVISION", "")},
        errors,
    )


def check_r8_visual_parity(root: Path) -> Check:
    errors: list[str] = []
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    world = (root / "src/miniquake/render/world.ml").read_text(encoding="utf-8-sig")
    entities = (root / "src/miniquake/render/entities.ml").read_text(encoding="utf-8-sig")
    test = (root / "scripts" / "TEST_BP-090-094R8.ps1").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.md").read_text(encoding="utf-8-sig")
    required = [
        ('"-gamma", "1"', main, "main startup gamma"),
        ("gl.clearColor(1.0, 0.0, 0.0, 0.0)", world, "GL clear colour"),
        ("function R_DrawBrushModelForSubmodel(entity, submodelIndex)", world, "canonical brush helper"),
        ("currentTextureFrame = entity.frame", world, "brush alternate animation"),
        ("R_ClearLightmapChains()", world, "per-model lightmap chain reset"),
        ("gl.blendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_COLOR)", world, "LUMINANCE blend"),
        ("worldRenderer.R_DrawBrushModelForSubmodel(entity, submodelIndex)", entities, "brush handoff"),
        ("MiniQuake BP-090-094R8 acceptance test: PASS", test, "R8 runner"),
        ("brush_lightmap_inversion=confirmed", analysis, "diagnostic evidence"),
    ]
    for value, text, label in required:
        if value not in text:
            errors.append(f"{label} missing marker: {value}")
    brush_match = re.search(r"(?ms)^function drawBrush\b.*?^end function$", entities)
    if brush_match and "gl.GL_SRC_COLOR" in brush_match.group(0):
        errors.append("simplified brush path still uses GL_SRC_COLOR")
    viewport_match = re.search(r"(?ms)^function renderViewport\b.*?^end function$", world)
    if viewport_match and "gl.clearColor(0.0, 0.0, 0.0" in viewport_match.group(0):
        errors.append("renderViewport still overrides clear colour with black")
    return Check(
        "bp090094r8_visual_parity_contract", not errors,
        {
            "startup_gamma": 1,
            "clear_color": "1,0,0,0",
            "brush_path": "canonical_R_DrawBrushModelForSubmodel",
            "brush_lightmap_blend": "GL_ZERO/GL_ONE_MINUS_SRC_COLOR",
            "texture_frame": "entity.frame",
        },
        errors,
    )


def check_r9_network_provenance(root: Path) -> Check:
    errors: list[str] = []
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    contract = (root / "src/miniquake/external_reference_contract.ml").read_text(encoding="utf-8-sig")
    fixture = (root / "tests/original_server_interop_tests.ml").read_text(encoding="utf-8-sig")
    runner = (root / "scripts" / "TEST_BP-090-094R12.ps1").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/original_server_interop_golden.json").read_text(encoding="utf-8-sig"))
    required = [
        ("function originalInteropClientNetworkProvenance(", host, "host provenance helper"),
        ("originalServerInteropNetworkProvenance(", contract, "contract provenance helper"),
        ("original-server interop completed signon without target UDP provenance", host, "fallback rejection"),
        ("network_provenance=target_udp", host, "runtime provenance marker"),
        ("target UDP provenance", fixture, "runtime fixture"),
        ("local fallback rejected", fixture, "fallback fixture"),
        ("$HasTargetUdpProvenance", runner, "PowerShell provenance gate"),
        ("transport=udp", runner, "UDP transport gate"),
        ("local_server_active=false", runner, "local server rejection"),
        ("local_authoritative=false", runner, "local authoritative rejection"),
        ("demo_playback=false", runner, "demo fallback rejection"),
    ]
    for marker, text, label in required:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")
    expected = {
        "network_provenance_required": True,
        "required_transport": "udp",
        "local_fallback_rejected": True,
        "demo_fallback_rejected": True,
        "remote_address_must_match_target": True,
        "normalized_pair_evidence": "target_udp_signon4",
    }
    for key, value in expected.items():
        if golden.get(key) != value:
            errors.append(f"golden {key}={golden.get(key)!r}, expected {value!r}")
    return Check(
        "bp090094r9_network_provenance_contract", not errors,
        {"network_provenance": "target_udp", "local_fallback_rejected": True, "fixtures": 20},
        errors,
    )



def check_r10_original_server_readiness(root: Path) -> Check:
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R12.ps1").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R10_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R10_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads((root / "docs/archive/releases/BP-090-094R10_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig"))
    required = [
        ("[int]$OriginalServerReadyTimeoutMs = 180000", runner, "readiness timeout parameter"),
        ("function Wait-OriginalServerControlReady(", runner, "readiness probe helper"),
        ("function Read-QuakeCString(", runner, "control response string parser"),
        ("function Get-AvailableLoopbackUdpPort(", runner, "loopback port selection"),
        ("CCREQ_SERVER_INFO", runner, "Protocol-3 request contract"),
        ("CCREP_SERVER_INFO", runner, "Protocol-3 response contract"),
        ("protocol3_server_info_response", runner, "readiness evidence marker"),
        ("$Remote.Port -ne $Port", runner, "exact response port validation"),
        ("$Response[4] -ne 0x83", runner, "server-info command validation"),
        ("$Protocol -ne 3", runner, "control protocol validation"),
        ("Wait-OriginalServerControlReady -Handle $OriginalServer", runner, "probe before full client"),
        ("bp090-094r12-original-server-{0}-readiness.json", runner, "readiness report path"),
        ("INFRA_FAILURE: original GLQuake server", runner, "timeout classification"),
        ("Get-NetUDPEndpoint", runner, "timeout endpoint diagnostics"),
        ("OriginalServerReadyTimeoutMs 180000", testing, "testing command"),
        ("Cold-Start-/Readiness-Lücke", analysis, "result analysis classification"),
    ]
    for marker, text, label in required:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")
    pair_start = runner.find("function Run-OriginalServerMiniClientPair(")
    pair_end = runner.find("function Run-MiniServerOriginalClientPair(", pair_start)
    if pair_start < 0 or pair_end < 0:
        errors.append("could not isolate Run-OriginalServerMiniClientPair")
    else:
        body = runner[pair_start:pair_end]
        ready_at = body.find("Wait-OriginalServerControlReady -Handle $OriginalServer")
        client_at = body.find("Invoke-LiveProcess -Executable $GameExe")
        if ready_at < 0 or client_at < 0 or ready_at > client_at:
            errors.append("full MiniQuake client may be launched before original-server readiness is established")
    expected = {
        "delivery_revision": "BP-090-094R10",
        "delivery_parent": "BP-090-094R9",
        "classification": "external original-server interop cold-start/readiness race",
        "changed_engine_code": False,
        "changed_native_code": False,
        "network_provenance_contract_preserved": True,
    }
    for key, value in expected.items():
        if hotfix.get(key) != value:
            errors.append(f"hotfix {key}={hotfix.get(key)!r}, expected {value!r}")
    fix = hotfix.get("fix", {})
    if fix.get("readiness_evidence") != "protocol3_server_info_response":
        errors.append("hotfix readiness evidence is not protocol3_server_info_response")
    if fix.get("default_timeout_ms") != 180000:
        errors.append("hotfix default readiness timeout is not 180000 ms")
    if fix.get("client_launch_after_readiness_only") is not True:
        errors.append("hotfix does not require client launch after readiness")
    return Check(
        "bp090094r10_original_server_readiness_contract", not errors,
        {
            "readiness_evidence": "CCREP_SERVER_INFO",
            "default_timeout_ms": 180000,
            "exact_endpoint": "127.0.0.1:<selected-port>",
            "cold_start_safe": True,
            "engine_code_changed": False,
        },
        errors,
    )



def check_r11_original_reference_handoff(root: Path) -> Check:
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R12.ps1").read_text(encoding="utf-8-sig")
    prepare = (root / "tools/prepare_original_reference.py").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R11_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R11_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads(
        (root / "docs/archive/releases/BP-090-094R11_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig")
    )

    required = [
        ("function Resolve-OriginalReferenceInput()", runner, "early source resolver"),
        (
            "Resolve-OriginalReferenceInput\n[void](Relaunch-ElevatedForInteropIfNeeded)",
            runner,
            "resolution before elevation",
        ),
        ("Downloads\\OriginalQuakeSourceCode.zip", runner, "Downloads fallback"),
        ("Test-PathInsideProject", runner, "project-boundary rejection"),
        ("MINIQUAKE_ORIGINAL_SOURCE", runner, "archive environment handoff"),
        ("MINIQUAKE_ORIGINAL_EXE", runner, "executable environment handoff"),
        (
            "bp090-094r12-original-reference-input.json",
            runner,
            "source argument report",
        ),
        ("$SelectorCount -ne 1", runner, "exactly-one selector check"),
        (
            '-Name "verified original GLQuake reference"',
            runner,
            "named live-process call",
        ),
        (
            "-Arguments $PrepareArguments",
            runner,
            "explicit prepare argument array",
        ),
        (
            "add_mutually_exclusive_group(required=False)",
            prepare,
            "Python optional CLI group",
        ),
        (
            "MINIQUAKE_ORIGINAL_SOURCE",
            prepare,
            "Python archive environment fallback",
        ),
        (
            "MINIQUAKE_ORIGINAL_EXE",
            prepare,
            "Python executable environment fallback",
        ),
        ("source_selector", prepare, "Python selector report"),
        ("OriginalQuakeSourceCode.zip", testing, "testing source path"),
        ("Quellselektor", analysis, "result analysis"),
    ]
    for marker, text, label in required:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")

    resolve_at = runner.find(
        "Resolve-OriginalReferenceInput\n[void](Relaunch-ElevatedForInteropIfNeeded)"
    )
    build_at = runner.find("starting single cumulative build and unit-test suite")
    if resolve_at < 0:
        errors.append("original reference is not resolved immediately before elevation")
    if build_at >= 0 and resolve_at > build_at:
        errors.append("original reference resolution occurs after the long build")

    prepare_stage = runner.find("$OriginalStage =")
    if prepare_stage >= 0:
        late_region = runner[prepare_stage:]
        if "Join-Path $Root 'OriginalQuakeSourceCode.zip'" in late_region:
            errors.append("late post-build project-root source fallback is still present")

    expected = {
        "delivery_revision": "BP-090-094R11",
        "delivery_parent": "BP-090-094R10",
        "classification": "external original-reference source-selector handoff",
        "changed_engine_code": False,
        "changed_native_code": False,
        "r10_readiness_preserved": True,
    }
    for key, value in expected.items():
        if hotfix.get(key) != value:
            errors.append(f"hotfix {key}={hotfix.get(key)!r}, expected {value!r}")

    fix = hotfix.get("fix", {})
    for key in (
        "resolution_before_elevation",
        "explicit_parameter_forwarding",
        "environment_fallback",
        "downloads_fallback",
        "project_internal_reference_rejected",
        "exactly_one_selector_required",
    ):
        if fix.get(key) is not True:
            errors.append(f"hotfix fix.{key} is not true")

    return Check(
        "bp090094r11_original_reference_handoff",
        not errors,
        {
            "resolution_before_elevation": True,
            "cli_selectors": 2,
            "environment_fallbacks": 2,
            "downloads_fallback": True,
            "project_internal_reference_rejected": True,
            "argument_report": "bp090-094r12-original-reference-input.json",
            "engine_code_changed": False,
        },
        errors,
    )


def check_r12_persistent_original_connect(root: Path) -> Check:
    errors: list[str] = []
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    client = (root / "src/miniquake/client.ml").read_text(encoding="utf-8-sig")
    net_main = (root / "src/miniquake/net_main.ml").read_text(encoding="utf-8-sig")
    net_loop = (root / "src/miniquake/net_loop.ml").read_text(encoding="utf-8-sig")
    runner = (root / "scripts" / "TEST_BP-090-094R12.ps1").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R12_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R12_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads((root / "docs/archive/releases/BP-090-094R12_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig"))

    required = [
        ("function connectRemotePersistent(", net_loop, "persistent UDP connector"),
        ("resendMilliseconds", net_loop, "resend interval"),
        ("request=\" + hex(request)", net_loop, "raw request diagnostic"),
        ("accepted=true control_port=", net_loop, "accept diagnostic"),
        ("UDP persistent connect timed out:", net_loop, "timeout diagnostic"),
        ("function Datagram_ConnectPersistent(", net_loop, "public persistent datagram path"),
        ("function NET_ConnectInterop(", net_main, "NET interop path"),
        ("function CL_EstablishInteropConnection(", client, "client interop establishment"),
        ("function connectHostInterop(", client, "client interop wrapper"),
        ("function connectRemoteHostInterop(", host, "host strict interop path"),
        ("connectRemoteHostInterop(session, targetHost, 20000, 500)", host, "strict persistent call"),
        ("original-server interop completed signon without target UDP provenance", host, "provenance rejection retained"),
        ("return host.runOriginalInteropClient([", main, "interop command"),
        ("persistent_control_socket = $true", runner, "process report marker"),
        ("connect_resend_ms = 500", runner, "process resend report"),
        ("MiniQuake Protocol-3 persistent connect", testing, "testing diagnostic"),
        ("two-second duplicate window", analysis, "original duplicate-window rationale"),
    ]
    for marker, text, label in required:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")

    start = main.find("function runOriginalInteropClientCommand(")
    end = main.find("function runUdpSmoke(", start)
    if start < 0 or end < 0:
        errors.append("could not isolate runOriginalInteropClientCommand")
    else:
        body = main[start:end]
        if '"+connect"' in body:
            errors.append("strict original interop still queues startup +connect")

    if hotfix.get("delivery_revision") != "BP-090-094R12":
        errors.append("hotfix delivery revision mismatch")
    if hotfix.get("parent_delivery") != "BP-090-094R11":
        errors.append("hotfix parent delivery mismatch")
    if hotfix.get("normal_network_semantics_changed") is not False:
        errors.append("hotfix must preserve normal network semantics")
    if hotfix.get("native_bridges_changed") is not False:
        errors.append("hotfix must not claim native bridge changes")

    return Check(
        "bp090094r12_persistent_original_connect_contract",
        not errors,
        {
            "persistent_control_socket": True,
            "connect_timeout_ms": 20000,
            "resend_ms": 500,
            "startup_connect_fallback": False,
            "raw_packet_diagnostics": True,
        },
        errors,
    )



def check_r13_pre_fallback_readiness_guard(root: Path) -> Check:
    errors: list[str] = []
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    net_loop = (root / "src/miniquake/net_loop.ml").read_text(encoding="utf-8-sig")
    runner = (root / "scripts" / "TEST_BP-090-094R13.ps1").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R13_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R13_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads((root / "docs/archive/releases/BP-090-094R13_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig"))

    required = [
        ('"-original-interop-target", arguments[2] + ":" + port', main, "private pre-fallback target option"),
        ('originalInteropTarget = common.parmValue(session.arguments, "-original-interop-target", "")', host, "Host_Init target read"),
        ('MiniQuake original interop pre-fallback connect', host, "pre-fallback diagnostic"),
        ('connectRemoteHostInterop(session, originalInteropTarget, 20000, 500)', host, "pre-fallback persistent connect"),
        ('if not session.client.connected then', host, "single-handshake reuse"),
        ('UDP control request was partially sent:', net_loop, "strict send length"),
        ('udpSocket.bindAddress', net_loop, "actual local bind diagnostic"),
        ('protocol3_server_info_response_with_open_guard', runner, "open readiness guard evidence"),
        ('guard_socket_open_during_signon', runner, "guard lifetime report"),
        ("guard_close_order = 'after_original_process_stop'", runner, "guard close order"),
        ('original GLQuake readiness guard {0} closed after server stop', runner, "guard close diagnostic"),
        ('TEST_BP-090-094R13.ps1', testing, "testing command"),
        ('pre-fallback', analysis.lower(), "analysis rationale"),
    ]
    for marker, source, label in required:
        if marker not in source:
            errors.append(f"{label} missing marker: {marker}")

    # The private target must appear before the normal standalone fallback.
    target_pos = host.find('originalInteropTarget = common.parmValue')
    fallback_pos = host.find('fallbackMap = session.startMap')
    if target_pos < 0 or fallback_pos < 0 or target_pos >= fallback_pos:
        errors.append("original interop target is not handled before standalone fallback")

    # The readiness socket must not be unconditionally closed inside the
    # readiness helper anymore.
    wait_start = runner.find('function Wait-OriginalServerControlReady(')
    wait_end = runner.find('function Stop-OriginalServer(', wait_start)
    if wait_start < 0 or wait_end < 0:
        errors.append("could not isolate readiness helper")
    else:
        body = runner[wait_start:wait_end]
        if 'if ($null -ne $Udp) { try { $Udp.Close() } catch { } }' in body:
            errors.append("readiness helper still unconditionally closes guard socket")
        if '$KeepGuardOpen = $true' not in body:
            errors.append("readiness helper does not retain successful guard socket")

    if hotfix.get("delivery_revision") != "BP-090-094R13":
        errors.append("hotfix delivery revision mismatch")
    if hotfix.get("parent_delivery") != "BP-090-094R12":
        errors.append("hotfix parent delivery mismatch")
    if hotfix.get("normal_game_start_changed") is not False:
        errors.append("hotfix must preserve normal game start semantics")
    if hotfix.get("native_bridges_changed") is not False:
        errors.append("hotfix must not claim native bridge changes")

    return Check(
        "bp090094r13_pre_fallback_readiness_guard_contract",
        not errors,
        {
            "pre_fallback_connect": True,
            "single_persistent_handshake": True,
            "readiness_guard_open_during_signon": True,
            "guard_close_order": "after_original_process_stop",
            "strict_connect_request_bytes": 12,
        },
        errors,
    )


def check_r14_original_capture_ensemble(root: Path) -> Check:
    errors=[]
    runner=(root/'scripts'/'TEST_BP-090-094R14.ps1').read_text(encoding='utf-8-sig')
    comparator=(root/'tools/compare_original_reference.py').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/original_visual_reference_golden.json').read_text(encoding='utf-8-sig'))
    testing=(root/'docs/archive/releases/BP-090-094R14_TESTING.md').read_text(encoding='utf-8-sig')
    analysis=(root/'docs/archive/releases/BP-090-094R14_RESULT_ANALYSIS.md').read_text(encoding='utf-8-sig')
    hotfix=json.loads((root/'docs/archive/releases/BP-090-094R14_HOTFIX_REPORT.json').read_text(encoding='utf-8-sig'))
    for marker in ['function Get-OriginalTgaState(','function Wait-OriginalTgaComplete(','validated_tga_size_hash_stability','expected_tga_bytes','stable_polls',"'--original-alt',$OriginalB", "'--min-reference-ssim','0.98'",'bounded_dual_reference_ensemble',"reference_aggregation='minimum_ssim'",'original_reference_ssim','MiniQuake BP-090-094R14 acceptance test: PASS']:
        if marker not in runner: errors.append('R14 runner missing marker: '+marker)
    if 'if ($OriginalHashA -ne $OriginalHashB) { throw' in runner: errors.append('R14 runner still rejects non-identical original captures before measuring similarity')
    for marker in ['--original-alt','--min-reference-ssim','default=0.98','"schema_version":3','"reference_aggregation":"minimum_ssim"','reference_consistency','ssim_min','ssim_mean','expected exactly']:
        if marker.replace(' ','') not in comparator.replace(' ',''): errors.append('R14 comparator missing marker: '+marker)
    expected={'comparison_schema_version':3,'requires_original_ab_determinism':False,'capture_completion':'validated_tga_size_hash_stability','minimum_reference_ssim':0.98,'reference_consistency_mode':'exact_or_dual_reference_ssim','candidate_reference_aggregation':'minimum_ssim','original_reference_runs':2}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'R14 golden {k}={golden.get(k)!r}, expected {v!r}')
    for marker,source,label in [('complete stable TGA',analysis,'result analysis'),('--min-reference-ssim 0.98',testing,'testing guide'),('TEST_BP-090-094R14.ps1',testing,'testing command')]:
        if marker.lower() not in source.lower(): errors.append(f'{label} missing marker: {marker}')
    if hotfix.get('delivery_revision')!='BP-090-094R14': errors.append('R14 hotfix delivery revision mismatch')
    if hotfix.get('parent_delivery')!='BP-090-094R13': errors.append('R14 hotfix parent delivery mismatch')
    if hotfix.get('engine_sources_changed') is not False: errors.append('R14 hotfix must not claim engine source changes')
    if hotfix.get('native_bridges_changed') is not False: errors.append('R14 hotfix must not claim native bridge changes')
    return Check('bp090094r14_original_capture_ensemble_contract',not errors,{'capture_completion':'validated_tga_size_hash_stability','original_runs':2,'minimum_reference_ssim':0.98,'candidate_reference_aggregation':'minimum_ssim','minimum_candidate_ssim':0.95},errors)

def check_r15_visual_timestep_parity(root: Path) -> Check:
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R15.ps1").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/original_visual_reference_golden.json").read_text(encoding="utf-8-sig"))
    testing = (root / "docs/archive/releases/BP-090-094R15_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R15_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads((root / "docs/archive/releases/BP-090-094R15_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig"))

    config_match = re.search(r"(?ms)^function Write-OriginalVisualConfig\b.*?^}\s*$", runner)
    config = config_match.group(0) if config_match else ""
    if not config:
        errors.append("R15 runner is missing Write-OriginalVisualConfig")
    for marker in ["'host_framerate 0.02'", "('timedemo ' + $Demo)"]:
        if marker not in config:
            errors.append("R15 visual config missing marker: " + marker)
    if config and config.find("'host_framerate 0.02'") > config.find("('timedemo ' + $Demo)"):
        errors.append("R15 host_framerate must be set before timedemo")

    for marker in [
        "simulation_timestep='fixed_host_framerate'",
        "original_host_framerate=0.02",
        "miniquake_frame_step=0.02",
        "simulation_timestep='fixed_0.02_seconds'",
        "MiniQuake BP-090-094R15 acceptance test: PASS",
    ]:
        if marker not in runner:
            errors.append("R15 runner missing marker: " + marker)

    if "frame(session, 0.02)" not in host:
        errors.append("MiniQuake evidence path no longer contains the fixed 0.02-second frame step")

    expected = {
        "simulation_timestep": "fixed_0.02_seconds",
        "original_host_framerate": 0.02,
        "miniquake_frame_step": 0.02,
        "minimum_ssim": 0.95,
        "minimum_reference_ssim": 0.98,
        "candidate_reference_aggregation": "minimum_ssim",
        "normalization": "none",
        "r14_demo3_best_frame_before_fix": 255,
        "r14_demo3_best_ssim_before_fix": 0.871158394398681,
        "r14_demo3_diagnosis": "time_dependent_view_damage_kick_and_cshift_decay_used_different_frame_steps",
    }
    for key, value in expected.items():
        if golden.get(key) != value:
            errors.append(f"R15 golden {key}={golden.get(key)!r}, expected {value!r}")

    for marker in [
        "Host_FilterTime", "V_CalcViewRoll", "V_UpdatePalette",
        "vier Pixel", "host_framerate 0.02", "keine Änderung unter `src/` oder `native/`",
    ]:
        if marker.lower() not in analysis.lower():
            errors.append("R15 analysis missing marker: " + marker)
    for marker in ["TEST_BP-090-094R15.ps1", "host_framerate 0.02", "SSIM"]:
        if marker.lower() not in testing.lower():
            errors.append("R15 testing guide missing marker: " + marker)

    if hotfix.get("delivery_revision") != "BP-090-094R15":
        errors.append("R15 hotfix delivery revision mismatch")
    if hotfix.get("parent_delivery") != "BP-090-094R14":
        errors.append("R15 hotfix parent delivery mismatch")
    if hotfix.get("engine_sources_changed") is not False:
        errors.append("R15 hotfix must not claim engine source changes")
    if hotfix.get("native_bridges_changed") is not False:
        errors.append("R15 hotfix must not claim native bridge changes")
    if hotfix.get("threshold_changed") is not False:
        errors.append("R15 hotfix must not relax visual thresholds")

    return Check(
        "bp090094r15_visual_timestep_parity_contract",
        not errors,
        {
            "simulation_timestep": "fixed_0.02_seconds",
            "original_host_framerate": 0.02,
            "miniquake_frame_step": 0.02,
            "minimum_reference_ssim": 0.98,
            "minimum_candidate_ssim": 0.95,
            "normalization": "none",
        },
        errors,
    )


def check_no_game_data(root: Path) -> Check:
    errors: list[str] = []
    scanned = 0
    for path in package_files(root):
        scanned += 1
        name = path.name.lower()
        if name in FORBIDDEN_NAMES or path.suffix.lower() in FORBIDDEN_SUFFIXES:
            errors.append(f"forbidden game/reference data: {path.relative_to(root).as_posix()}")
    return Check("no_quake_or_original_binary_data", not errors, {"files_scanned": scanned}, errors)


def def_exports(path: Path) -> list[str]:
    exports: list[str] = []
    in_exports = False
    for raw in path.read_text(encoding="utf-8-sig").splitlines():
        line = raw.split(";", 1)[0].strip()
        if not line:
            continue
        if line.upper() == "EXPORTS":
            in_exports = True
            continue
        if in_exports:
            exports.append(line.split()[0])
    return exports


def pe_machine(path: Path) -> int:
    data = path.read_bytes()
    if len(data) < 0x40 or data[:2] != b"MZ":
        raise ValueError("not MZ")
    offset = int.from_bytes(data[0x3C:0x40], "little")
    if data[offset:offset + 4] != b"PE\0\0":
        raise ValueError("not PE")
    return int.from_bytes(data[offset + 4:offset + 6], "little")



PACKAGE_RE = re.compile(r"(?m)^\s*package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$")
MAIN_RE = re.compile(r"(?m)^\s*function\s+main\s*\(\s*args\s*\)")
FUNCTION_RE = re.compile(
    r"(?m)^\s*(?:static\s+)?function(?:\s+inline)?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]*)\)"
)


def strip_minilang_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", lambda match: "\n" * match.group(0).count("\n"), text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def check_current_entry_helper_namespace(root: Path) -> Check:
    relative = "tests/opt001cr3_hotpath_tests.ml"
    path = root / relative
    clean = strip_minilang_comments(path.read_text(encoding="utf-8"))
    functions = [match.group(1) for match in FUNCTION_RE.finditer(clean)]
    errors: list[str] = []
    helpers = [name for name in functions if name != "main"]
    for name in helpers:
        if not name.startswith("opt001d"):
            errors.append(f"{relative}: global helper '{name}' is not namespaced with prefix 'opt001d'")
    if "main" not in functions:
        errors.append(f"{relative}: main(args) is missing")
    for generic in ("check", "equal", "require", "passed", "failed"):
        if re.search(rf"(?m)^\s*(?:function\s+)?{re.escape(generic)}\b", clean):
            errors.append(f"{relative}: generic entry-level name remains: {generic}")
    return Check("current_entry_helper_namespace", not errors, {
        "entry": relative,
        "helpers_checked": len(helpers),
        "required_prefix": "opt001d",
        "generic_names": 0 if not errors else len(errors),
    }, errors)


def check_minilang_entry_function_shadow_arity(root: Path) -> Check:
    """Reject global entry helpers that change an imported internal call's arity."""
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
        clean = strip_minilang_comments(path.read_text(encoding="utf-8", errors="replace"))
        clean_by_file[path] = clean
        package_match = PACKAGE_RE.search(clean)
        if package_match:
            package_to_path[package_match.group(1)] = path
        imports: list[str] = []
        for match in import_pattern.finditer(clean):
            _quoted, module = match.groups()
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
    entries = [
        path for path in test_files
        if MAIN_RE.search(clean_by_file[path]) and not PACKAGE_RE.search(clean_by_file[path])
    ]
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

def check_native(root: Path) -> Check:
    """Validate checked-in x64 bridge binaries against their current DEF files."""
    errors: list[str] = []
    details: dict[str, object] = {}
    for rel, (def_rel, minimum_exports) in NATIVE_BRIDGES.items():
        path = root / rel
        try:
            actual_hash = sha256(path)
            exports = def_exports(root / def_rel)
            machine = pe_machine(path)
        except Exception as exc:
            errors.append(f"{rel}: {exc}")
            continue
        if len(exports) < minimum_exports:
            errors.append(f"{def_rel}: exports {len(exports)} < required {minimum_exports}")
        if len(exports) != len(set(exports)):
            errors.append(f"{def_rel}: duplicate export names")
        if machine != 0x8664:
            errors.append(f"{rel}: PE machine 0x{machine:04x} != 0x8664")
        details[rel] = {"sha256": actual_hash, "exports": len(exports), "machine": f"0x{machine:04x}"}
    return Check("native_bridges", not errors, details, errors)


def ml_files(root: Path) -> list[Path]:
    """Return production and test MiniLang source files."""
    return sorted([*root.glob("src/**/*.ml"), *root.glob("tests/**/*.ml")])


def check_minilang(root: Path) -> Check:
    errors: list[str] = []
    package_by_name: dict[str, Path] = {}
    main_files = 0
    imports = 0
    package_re = re.compile(r"^\s*package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$", re.M)
    import_re = re.compile(r"^\s*import\s+([A-Za-z_][A-Za-z0-9_.]*|\"[^\"]+\")(?:\s+as\s+[A-Za-z_][A-Za-z0-9_]*)?\s*$", re.M)
    for path in ml_files(root):
        text = path.read_text(encoding="utf-8-sig")
        package = package_re.search(text)
        if package:
            name = package.group(1)
            if name in package_by_name and package_by_name[name] != path:
                errors.append(f"duplicate package {name}: {package_by_name[name].relative_to(root)} and {path.relative_to(root)}")
            package_by_name[name] = path
        if re.search(r"^\s*function\s+main\s*\(\s*args\s*\)", text, re.M):
            main_files += 1
            if package:
                errors.append(f"main(args) must be global, but file has package: {path.relative_to(root)}")
        imports += len(import_re.findall(text))
    for path in ml_files(root):
        text = path.read_text(encoding="utf-8-sig")
        for token in import_re.findall(text):
            if token.startswith('"'):
                candidate = (path.parent / token.strip('"')).resolve()
                if not candidate.is_file():
                    errors.append(f"missing quoted import in {path.relative_to(root)}: {token}")
            elif token not in package_by_name and not token.startswith("std."):
                errors.append(f"unknown package import in {path.relative_to(root)}: {token}")
    return Check(
        "minilang_packages_and_entries", not errors,
        {"ml_files": len(ml_files(root)), "packages": len(package_by_name), "main_entry_files": main_files, "imports": imports},
        errors,
    )


def check_external_contract(root: Path) -> Check:
    errors: list[str] = []
    contract = (root / "src/miniquake/external_reference_contract.ml").read_text(encoding="utf-8-sig")
    test = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "scripts" / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    prepare = (root / "tools/prepare_original_reference.py").read_text(encoding="utf-8-sig")
    comparator = (root / "tools/compare_original_reference.py").read_text(encoding="utf-8-sig")
    errors += marker_errors(contract, [
        'const ORIGINAL_GLQUAKE_SHA256 = "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588"',
        "const ORIGINAL_GLQUAKE_BYTES = 435712", "const ORIGINAL_GLQUAKE_PE_MACHINE = 0x014c",
        "const ORIGINAL_CAPTURE_MIN_SSIM = 0.95", "const ORIGINAL_CAPTURE_SEARCH_RADIUS = 2",
        '["demo1", 256]', '["demo2", 256]', '["demo3", 256]',
        'const COMPAT_FINAL_STATUS = "compat_109_final_candidate_v1"', "const COMPAT_FINAL_FINGERPRINT = 0xe04a7727",
    ], "external contract")
    errors += marker_errors(prepare, ["EXPECTED_SIZE = 435_712", "EXPECTED_MACHINE = 0x014C", '"legacy_opengl32_staged": False'], "reference stager")
    errors += marker_errors(comparator, ['"normalization": "none"', '"alignment": "temporal_candidate_selection_only"', "default=0.95"], "visual comparator")
    errors += marker_errors(test, [
        "Run-OriginalServerMiniClientPair", "Run-MiniServerOriginalClientPair", "Run-OriginalVisualCapture",
        "two deterministic pairs in each Protocol-15 direction", "original GLQuake deterministic capture",
        "--render-demo-evidence", "min_ssim=0.95",
    ], "acceptance runner")
    errors += marker_errors(collector, [
        "bp090-094-original-reference", "original_reference_binary_in_result_archive=$false",
        "quake_game_data_in_result_archive=$false",
    ], "collector")
    return Check(
        "external_reference_contract", not errors,
        {"reference_sha256": "04862c...d588", "minimum_ssim": 0.95, "interop_directions": 2, "visual_scenarios": 3},
        errors,
    )



def check_named_build_parameter_binding(root: Path) -> Check:
    errors: list[str] = []
    current = (root / "scripts" / "TEST_OPT-001D.ps1").read_text(encoding="utf-8-sig")
    errors += marker_errors(current, [
        'function Invoke-LiveBuild(', '"-File", $ScriptPath',
        '"-Compiler", $Compiler', '"-StdLib", $StdLib',
        '"-Configuration", "Release"', '"-NoRunTests"', '"-SkipPreflight"',
        'output_mode=python_binary_passthrough_named_build_binding',
    ], "current runner")
    for forbidden in ('$BuildArguments =', '@BuildArguments', '-EncodedCommand', 'Invoke-LivePowerShellScript'):
        if forbidden in current:
            errors.append(f"current runner retains unsafe parameter binding marker: {forbidden}")
    # Ensure the named tokens occur in the actual subprocess argument list, not only in comments.
    build_fn = re.search(r'(?ms)^function Invoke-LiveBuild\b.*?^}', current)
    block = build_fn.group(0) if build_fn else ""
    sequence = ['"-File", $ScriptPath', '"-Compiler", $Compiler', '"-StdLib", $StdLib', '"-Configuration", "Release"']
    positions = [block.find(item) for item in sequence]
    if not block or any(pos < 0 for pos in positions) or positions != sorted(positions):
        errors.append("Invoke-LiveBuild does not pass ordered named build parameters")
    return Check(
        "named_build_parameter_binding", not errors,
        {
            "mode": "powershell_file_named_arguments",
            "encoded_command": False,
            "array_splat": False,
            "configuration": "Release",
        },
        errors,
    )

def check_live_output(root: Path) -> Check:
    errors: list[str] = []
    historical_test = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    current_test = (root / "scripts" / "TEST_OPT-001D.ps1").read_text(encoding="utf-8-sig")
    live_runner = (root / "tools/run_process_live.py").read_text(encoding="utf-8-sig")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    for label, script_text in (("historical test", historical_test), ("current test", current_test), ("build", build)):
        if "PYTHONUNBUFFERED" not in script_text:
            errors.append(f"{label} script does not force unbuffered Python")
    if "@(& $Executable @Arguments 2>&1)" in historical_test:
        errors.append("historical acceptance runner reintroduced full-process output buffering")
    required = [
        "tools\\run_process_live.py", "output_mode=python_binary_passthrough_named_build_binding",
        "Invoke-ExternalProcessLive", "dependent tests skipped because build failed",
        "Show-LogTail", "Get-Content -LiteralPath $LogPath -Tail",
    ]
    errors += marker_errors(current_test, required, "current runner")
    if "Tee-Object" in current_test:
        errors.append("current runner reintroduced a PowerShell Tee-Object pipeline")
    errors += marker_errors(live_runner, [
        "subprocess.Popen(", "stderr=subprocess.STDOUT", "text=False",
        "os.read(fd, 4096)", "stream_mode=binary_passthrough",
        "except BaseException:", "child_exit_code=", "--status-json", "write_status(",
    ], "live process runner")
    errors += marker_errors(current_test, [
        "2>&1 | Out-Host", '$SavedErrorActionPreference = $ErrorActionPreference',
        '$ErrorActionPreference = "Continue"', '$StatusPath = $LogPath + ".status.json"',
        "$PackageVerifyCode -is [array]",
    ], "scalar live runner")
    if re.search(r"(?m)^\s*& \$PythonExe @RunnerArguments\s*$", current_test):
        errors.append("current runner leaks native stdout into the function return stream")
    return Check(
        "live_output", not errors,
        {"python_unbuffered": True, "current_build_output_mode": "python_binary_passthrough_named_build_binding", "dependent_test_barrier": True},
        errors,
    )



def check_powershell_elseif_syntax(root: Path) -> Check:
    """Reject the common PowerShell parser error `else if (...)`.

    PowerShell uses the single keyword `elseif`; unlike C-like languages,
    `else if` without a statement block after `else` is a parse error.
    """
    errors: list[str] = []
    scripts = sorted(
        [*root.rglob("*.ps1"), *root.rglob("*.psm1")],
        key=lambda path: path.relative_to(root).as_posix().lower(),
    )
    pattern = re.compile(r"\belse\s+if\s*\(", re.IGNORECASE)
    for path in scripts:
        rel = path.relative_to(root).as_posix()
        source = path.read_text(encoding="utf-8-sig", errors="replace")
        for line_number, line in enumerate(source.splitlines(), 1):
            # Ignore full-line comments.  The package scripts do not use this
            # phrase inside here-strings, so a source-level check is deliberate.
            if line.lstrip().startswith("#"):
                continue
            if pattern.search(line):
                errors.append(
                    f"{rel}:{line_number}: invalid PowerShell `else if`; use `elseif`"
                )
    current = root / "scripts" / "TEST_OPT-001D.ps1"
    if current.is_file():
        source = current.read_text(encoding="utf-8-sig", errors="replace")
        if "} elseif ($AllowFailure) {" not in source:
            errors.append(
                "TEST_OPT-001D.ps1 is missing the validated AllowFailure elseif branch"
            )
    return Check(
        "powershell_elseif_syntax",
        not errors,
        {"scripts_checked": len(scripts), "invalid_else_if": len(errors)},
        errors,
    )


def check_powershell_interpolation_safety(root: Path) -> Check:
    """Reject the `$Variable:` parser trap inside expandable strings.

    Scope/provider-qualified forms such as `$env:NAME` remain valid. Braced
    interpolation (`${Variable}:`) is the required form before a literal colon.
    """
    errors: list[str] = []
    allowed_qualifiers = {
        "env", "global", "local", "private", "script", "using",
        "variable", "function", "alias",
    }
    pattern = re.compile(r"(?<!`)\$([A-Za-z_][A-Za-z0-9_]*)\:")
    files = sorted(root.rglob("*.ps1"))
    matches = 0
    for path in files:
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8-sig")
        for line_number, line in enumerate(text.splitlines(), 1):
            for match in pattern.finditer(line):
                name = match.group(1)
                if name.lower() in allowed_qualifiers:
                    continue
                matches += 1
                errors.append(
                    f"{rel}:{line_number}: ambiguous ${name}: interpolation; "
                    f"use ${{{name}}}: before a literal colon"
                )
    runner = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    if '${Scenario}: $OriginalHashA vs $OriginalHashB' not in runner:
        errors.append("R7 runner does not contain the braced Scenario interpolation")
    if '$Scenario: $OriginalHashA vs $OriginalHashB' in runner:
        errors.append("R7 runner still contains the invalid unbraced Scenario interpolation")
    return Check(
        "powershell_variable_colon_interpolation",
        not errors,
        {"scripts_checked": len(files), "ambiguous_interpolations": matches},
        errors,
    )

def check_verifier_cli_compatibility(root: Path) -> Check:
    """Bind the canonical build call and the backward-compatible CLI alias."""
    errors: list[str] = []
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    verifier = (root / "tools/verify.py").read_text(encoding="utf-8-sig")
    docs = (root / "docs/archive/releases/BP-090-094R7_TESTING.md").read_text(encoding="utf-8-sig")
    canonical = "& $PythonExe @PythonPrefixArgs $Verifier --root $Root"
    legacy_build = "& $PythonExe @PythonPrefixArgs $Verifier $Root"
    if canonical not in build:
        errors.append("build.ps1 does not use the canonical verifier --root option")
    if legacy_build in build:
        errors.append("build.ps1 still passes the verifier root as an unlabelled positional argument")
    parser_patterns = [
        (r'^\s*parser\.add_argument\("legacy_root", nargs="\?"\)\s*$', 'legacy positional root argument'),
        (r'^\s*parser\.add_argument\("--root", default=""\)\s*$', 'canonical --root argument'),
        (r'^\s*root_value = args\.root or args\.legacy_root or "\."\s*$', 'root precedence'),
        (r'^\s*if args\.root and args\.legacy_root:\s*$', 'ambiguous dual-root rejection'),
    ]
    for pattern, label in parser_patterns:
        if re.search(pattern, verifier, re.M) is None:
            errors.append(f"verifier CLI compatibility marker missing: {label}")
    if "python .\\tools\\verify.py --root ." not in docs:
        errors.append("R7 testing guide lacks the canonical verifier example")
    if "python .\\tools\\verify.py ." not in docs:
        errors.append("R7 testing guide lacks the historical positional compatibility example")
    return Check(
        "verifier_cli_compatibility",
        not errors,
        {"canonical_form": "--root", "legacy_positional_root": True},
        errors,
    )


def check_original_glquake_runtime_safety(root: Path) -> Check:
    """Bind the modern-driver-safe launch and evidence policy for GLQUAKE.EXE."""
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    historical_analysis = (root / "docs/archive/releases/BP-090-094R4_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    current_analysis = (root / "docs/archive/releases/BP-090-094R7_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    try:
        server_golden = json.loads((root / "audit/original_server_interop_golden.json").read_text(encoding="utf-8-sig"))
        client_golden = json.loads((root / "audit/original_client_interop_golden.json").read_text(encoding="utf-8-sig"))
        visual_golden = json.loads((root / "audit/original_visual_reference_golden.json").read_text(encoding="utf-8-sig"))
    except Exception as exc:
        return Check("original_glquake_runtime_safety", False, {}, [f"invalid golden file: {exc}"])

    required = [
        "'-listen', '4'",
        "'-window', '-width', '640', '-height', '480'",
        "'-heapsize', '32768'",
        "starting original GLQuake loopback-only listen server",
        "without -condebug",
        "miniquake_protocol3_retry_and_protocol15_signon4",
        "process_alive_after_signon",
        "miniquake_server_protocol15_summary",
        "process_alive_at_completed_signon",
        "original_tga_screenshot",
        "screenshot_produced = $true",
        "condebug_enabled = $false",
        'original_condebug_enabled = $false',
        'original_evidence_mode = "protocol_summaries_and_screenshot_files"',
        'original_network_scope = "loopback_only"',
        'original_bind_address = "127.0.0.1"',
        'original_visual_network = "disabled"',
        'unattended_firewall_prompt_expected = $false',
        "'-ip', '127.0.0.1'",
        "'-noudp', '-noipx'",
    ]
    errors += marker_errors(runner, required, "R7 runner")
    if "'-condebug'" in runner:
        errors.append("R7 runner passes the unsafe -condebug flag to GLQUAKE.EXE")
    for stale in ["qconsole.log", "Server spawned\\.", "Connection accepted", "CL_SignonReply:\\\\s*4"]:
        if stale in runner:
            errors.append("R6 evidence still depends on unsafe qconsole logging: " + stale)
    if "'-dedicated', '4'" in runner:
        errors.append("R7 runner reintroduced GLQUAKE.EXE dedicated mode")

    expected_server = {
        "original_server_process_mode": "listen",
        "requires_video_context": True,
        "dedicated_glquake_map_load_supported": False,
        "server_start_timeout_ms": 30000,
        "condebug_enabled": False,
        "readiness_evidence": "miniquake_protocol3_retry_and_protocol15_signon4",
        "remote_connection_evidence": "miniquake_signon4_summary",
        "qconsole_required": False,
        "legacy_debug_log_buffer_bytes": 1024,
        "observed_modern_extensions_line_bytes": 2580,
        "network_scope": "loopback_only",
        "bind_address": "127.0.0.1",
        "firewall_prompt_expected": False,
    }
    for key, value in expected_server.items():
        if server_golden.get(key) != value:
            errors.append(f"server golden {key}={server_golden.get(key)!r}, expected {value!r}")
    for golden, label, expected in [
        (client_golden, "client", {
            "condebug_enabled": False,
            "qconsole_required": False,
            "evidence_source": "miniquake_server_protocol15_summary",
            "network_scope": "loopback_only",
            "bind_address": "127.0.0.1",
            "firewall_prompt_expected": False,
        }),
        (visual_golden, "visual", {
            "condebug_enabled": False,
            "qconsole_required": False,
            "evidence_source": "original_tga_screenshot",
            "network_scope": "disabled",
            "udp_disabled": True,
            "firewall_prompt_expected": False,
        }),
    ]:
        for key, value in expected.items():
            if golden.get(key) != value:
                errors.append(f"{label} golden {key}={golden.get(key)!r}, expected {value!r}")

    errors += marker_errors(historical_analysis, [
        "Con_DebugLog",
        "1024-byte",
        "vsprintf",
        "2580 bytes",
        "0xC0000005",
        "not a Protocol-3, Protocol-15 or MiniQuake gameplay failure",
    ], "R4 historical analysis")
    errors += marker_errors(current_analysis, [
        "Windows Defender Firewall",
        "INADDR_ANY",
        "127.0.0.1",
        "-noudp -noipx",
        "unattended",
    ], "R7 analysis")
    return Check(
        "original_glquake_runtime_safety",
        not errors,
        {
            "process_mode": "listen",
            "video_context_required": True,
            "condebug_enabled": False,
            "qconsole_required": False,
            "server_readiness": "protocol3_server_info_then_target_udp_protocol15_signon4",
            "network_scope": "loopback_only",
            "bind_address": "127.0.0.1",
            "visual_network": "disabled",
            "firewall_prompt_expected": False,
        },
        errors,
    )


def check_original_loopback_isolation(root: Path) -> Check:
    """Require unattended original-binary tests to stay on loopback only."""
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")
    required_runner = [
        "'-ip', '127.0.0.1', '-port'",
        "'-ip', '127.0.0.1',",
        "'-noudp', '-noipx'",
        "network_scope = 'loopback_only'",
        "bind_address = '127.0.0.1'",
        "firewall_prompt_expected = $false",
        'original_network_scope = "loopback_only"',
        'original_visual_network = "disabled"',
        'unattended_firewall_prompt_expected = $false',
    ]
    errors += marker_errors(runner, required_runner, "R7 loopback harness")
    required_main = [
        '"-ip", "127.0.0.1",\n    "-port"',
        '"-headless",\n    "-nosound",\n    "-ip", "127.0.0.1"',
    ]
    errors += marker_errors(main, required_main, "R7 MiniQuake interop CLI")
    # Original visual evidence must not initialize UDP at all.
    visual_start = runner.find("function Run-OriginalVisualCapture")
    visual_end = runner.find("New-Item -ItemType Directory", visual_start)
    visual = runner[visual_start:visual_end] if visual_start >= 0 and visual_end > visual_start else ""
    if "'-noudp'" not in visual:
        errors.append("original visual harness does not disable UDP")
    # Original interop processes must never bind INADDR_ANY through a missing -ip.
    if "'-listen', '4'" in runner and "'-ip', '127.0.0.1'" not in runner:
        errors.append("original listen server lacks loopback-only -ip binding")
    return Check(
        "original_loopback_isolation", not errors,
        {
            "original_server_bind": "127.0.0.1",
            "original_client_bind": "127.0.0.1",
            "miniquake_server_bind": "127.0.0.1",
            "miniquake_client_bind": "127.0.0.1",
            "visual_udp": "disabled",
            "unattended_firewall_prompt_expected": False,
        },
        errors,
    )

def check_temporary_loopback_firewall_rules(root: Path) -> Check:
    """Require exact-program, loopback-only, temporary firewall authorization."""
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R7_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R7_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    hotfix = json.loads((root / "docs/archive/releases/BP-090-094R7_HOTFIX_REPORT.json").read_text(encoding="utf-8-sig"))
    required = [
        "function Test-IsAdministrator()",
        "function Relaunch-ElevatedForInteropIfNeeded()",
        "function Install-TemporaryLoopbackFirewallRules()",
        "function Remove-TemporaryLoopbackFirewallRules()",
        "New-NetFirewallRule",
        "Remove-NetFirewallRule",
        "-Program $Spec.program",
        "-Protocol UDP",
        "-LocalAddress '127.0.0.1'",
        "-RemoteAddress '127.0.0.1'",
        "temporary loopback firewall rules",
        "exact_program_loopback_udp",
        "Remove-TemporaryLoopbackFirewallRules",
        "Start-Process -FilePath $PowerShellExe",
        "-Verb RunAs",
    ]
    errors += marker_errors(runner, required, "R7 firewall harness")
    for forbidden in [
        "Set-NetFirewallProfile",
        "Disable-NetFirewallRule",
        "netsh advfirewall set",
        "-LocalAddress 'Any'",
        "-RemoteAddress 'Any'",
    ]:
        if forbidden in runner:
            errors.append(f"R7 firewall harness contains forbidden broad operation: {forbidden}")
    # The privilege check must occur before build/transcript work so UAC is
    # requested immediately instead of after a long unattended compile.
    relaunch = runner.find("[void](Relaunch-ElevatedForInteropIfNeeded)")
    build_dir = runner.find("New-Item -ItemType Directory -Force -Path $Build")
    if relaunch < 0 or build_dir < 0 or relaunch > build_dir:
        errors.append("administrator relaunch is not performed before build/transcript setup")
    install = runner.find("Install-TemporaryLoopbackFirewallRules")
    interop = runner.find("if (-not $SkipOriginalInterop)", install + 1)
    if install < 0 or interop < 0 or install > interop:
        errors.append("temporary rules are not installed before original interop")
    finally_pos = runner.find("} finally {")
    cleanup_after = runner.find("Remove-TemporaryLoopbackFirewallRules", finally_pos)
    if finally_pos < 0 or cleanup_after < 0:
        errors.append("temporary firewall rules are not removed from finally")
    errors += marker_errors(testing, [
        "administrator", "UAC", "temporary", "127.0.0.1", "automatically removed",
    ], "R7 testing")
    errors += marker_errors(analysis, [
        "45000 ms", "ready.json", "Windows Defender Firewall", "loopback", "temporary rules",
    ], "R7 analysis")
    expected = {
        "temporary_rules": True,
        "rule_scope": "exact_program_udp_loopback_only",
        "rule_count": 4,
        "automatic_cleanup": True,
        "auto_elevation_before_build": True,
        "engine_code_changed": False,
        "native_code_changed": False,
    }
    for key, value in expected.items():
        if hotfix.get(key) != value:
            errors.append(f"R7 hotfix {key}={hotfix.get(key)!r}, expected {value!r}")
    return Check(
        "temporary_loopback_firewall_rules",
        not errors,
        {
            "rules": 4,
            "programs": 2,
            "directions": 2,
            "protocol": "UDP",
            "local_address": "127.0.0.1",
            "remote_address": "127.0.0.1",
            "auto_elevation_before_build": True,
            "automatic_cleanup": True,
        },
        errors,
    )



def check_original_client_port_routing(root: Path) -> Check:
    """Bind the original Quake console tokenizer and net_hostport routing fix."""
    errors: list[str] = []
    runner = (root / "scripts" / "TEST_BP-090-094R7.ps1").read_text(encoding="utf-8-sig")
    testing = (root / "docs/archive/releases/BP-090-094R7_TESTING.md").read_text(encoding="utf-8-sig")
    analysis = (root / "docs/archive/releases/BP-090-094R7_RESULT_ANALYSIS.md").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/original_client_port_routing_golden.json").read_text(encoding="utf-8-sig"))
    required = [
        "COM_Parse, where ':' is a",
        "Host_Connect_f consumes only Cmd_Argv(1)",
        "'connect 127.0.0.1'",
        "'-ip', '127.0.0.1', '-port', [string]$Port",
        "original_command_parser = 'COM_Parse_colon_punctuation'",
        "connect_token = '127.0.0.1'",
        "remote_port_source = '-port'",
        "starting original GLQuake client",
        "process_alive_at_failure",
        "summary_exists",
    ]
    errors += marker_errors(runner, required, "R7 original-client port harness")
    if "connect 127.0.0.1:" in runner:
        errors.append("R7 harness still embeds a port in the original Quake console connect token")
    if "'-port', [string]$Port" not in runner:
        errors.append("R7 harness does not route the selected UDP port through original NET_Init -port")
    errors += marker_errors(testing, [
        "connect 127.0.0.1", "-port", "COM_Parse", "Host_Connect_f", "Cmd_Argv(1)",
    ], "R7 testing")
    errors += marker_errors(analysis, [
        "connect 127.0.0.1:42773", "26000", "COM_Parse", "Host_Connect_f", "Cmd_Argv(1)",
    ], "R7 analysis")
    expected = {
        "schema_version": 1,
        "status": "original_client_port_routing_v1",
        "delivery_revision": "BP-090-094R7",
        "command_tokenizer": "Cmd_TokenizeString_COM_Parse",
        "colon_is_punctuation": True,
        "host_connect_argument": "Cmd_Argv(1)",
        "connect_token": "127.0.0.1",
        "remote_port_source": "-port_to_net_hostport",
        "default_port_without_fix": 26000,
    }
    for key, value in expected.items():
        if golden.get(key) != value:
            errors.append(f"port-routing golden {key}={golden.get(key)!r}, expected {value!r}")
    return Check(
        "original_client_port_routing",
        not errors,
        {
            "command_token": "127.0.0.1",
            "port_source": "-port/net_hostport",
            "default_without_fix": 26000,
            "colon_console_token": "forbidden",
            "failure_process_report": True,
        },
        errors,
    )

def check_inherited_contract_lineage(root: Path) -> Check:
    errors: list[str] = []
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    collector = (root / "scripts" / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    errors += marker_errors(collector, [
        "MiniQuakeProtocol15ServerDataTests.exe",
        "BP-012_PROTOCOL15_SERVERDATA_AUDIT.md",
        "protocol15_serverdata_golden.json",
    ], "collector")
    errors += marker_errors(build, [
        r'tools\check_source_084.py',
        r'tools\check_compat_085.py',
        r'tools\check_compat_086.py',
        r'tools\check_compat_087.py',
        r'tools\check_compat_088.py',
        r'tools\check_compat_089.py',
        '--allow-downstream-package',
    ], "build")
    scripts = [root / "tools/check_source_084.py"] + [
        root / f"tools/check_compat_0{step}.py" for step in range(85, 90)
    ]
    for script in scripts:
        text = script.read_text(encoding="utf-8-sig")
        if "--allow-downstream-package" not in text:
            errors.append(f"{script.relative_to(root)} lacks downstream-package mode")
    return Check(
        "inherited_contract_lineage",
        not errors,
        {"downstream_checkers": len(scripts), "historical_collector_markers": 3},
        errors,
    )

def check_external_checkers(root: Path) -> Check:
    errors: list[str] = []
    reports: dict[str, object] = {}
    for step in range(90, 95):
        script = root / f"tools/check_external_0{step}.py"
        out = root / "build" / f"verify-external-{step}.json"
        out.parent.mkdir(exist_ok=True)
        proc = subprocess.run([sys.executable, str(script), "--root", str(root), "--json", str(out)], text=True, capture_output=True)
        if proc.returncode != 0:
            errors.append(f"BP-{step:03d} checker failed: {(proc.stdout + proc.stderr).strip()}")
        elif out.is_file():
            reports[f"BP-{step:03d}"] = json.loads(out.read_text(encoding="utf-8-sig"))
    return Check("external_component_checkers", not errors, {"checkers": len(reports)}, errors)


def check_opt001b(root: Path) -> Check:
    out = root / "build" / "verify-opt001b.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(root / "tools/check_opt001b.py"), "--root", str(root), "--json", str(out), "--allow-downstream-package"],
        capture_output=True, text=True,
    )
    errors: list[str] = []
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    details: dict[str, object] = {"return_code": proc.returncode}
    if out.is_file():
        try:
            report = json.loads(out.read_text(encoding="utf-8-sig"))
            details["status"] = report.get("status", "")
        except Exception as exc:
            errors.append(f"invalid OPT-001B report: {exc}")
    return Check("opt001b_contract", not errors, details, errors)


def check_minilang_utf8_no_bom(root: Path) -> Check:
    errors: list[str] = []
    checked = 0
    bom_files: list[str] = []
    invalid_utf8: list[str] = []
    for path in sorted(root.rglob("*.ml"), key=lambda p: p.relative_to(root).as_posix().lower()):
        if not path.is_file():
            continue
        rel = path.relative_to(root)
        if any(part in EXCLUDED_DIRS for part in rel.parts):
            continue
        checked += 1
        raw = path.read_bytes()
        rel_text = rel.as_posix()
        if raw.startswith(b"\xef\xbb\xbf"):
            bom_files.append(rel_text)
            errors.append(f"UTF-8 BOM is not accepted by the MiniLang compiler: {rel_text}")
        try:
            raw.decode("utf-8")
        except UnicodeDecodeError as exc:
            invalid_utf8.append(rel_text)
            errors.append(f"invalid UTF-8 MiniLang source {rel_text}: {exc}")
    return Check(
        "minilang_utf8_no_bom",
        not errors,
        {"files_checked": checked, "bom_files": len(bom_files), "invalid_utf8_files": len(invalid_utf8)},
        errors,
    )


def check_minilang_delimiters(root: Path) -> Check:
    out = root / "build" / "verify-minilang-delimiters.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(root / "tools/check_minilang_delimiters.py"),
         "--root", str(root), "--json", str(out)],
        capture_output=True, text=True,
    )
    errors: list[str] = []
    details: dict[str, object] = {"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report = json.loads(out.read_text(encoding="utf-8-sig"))
            details["files_checked"] = report.get("files_checked", 0)
            details["issues"] = len(report.get("issues", []))
        except Exception as exc:
            errors.append(f"invalid delimiter report: {exc}")
    return Check("minilang_delimiter_balance", not errors, details, errors)


def check_source_documentation(root: Path) -> Check:
    """Run the licence-aware production header and function-comment audit."""
    script = root / "tools/check_source_documentation.py"
    process = subprocess.run(
        [sys.executable, str(script), "--root", str(root)],
        capture_output=True,
        text=True,
    )
    output = (process.stdout + process.stderr).strip()
    errors = [] if process.returncode == 0 else [output]
    details: dict[str, object] = {"return_code": process.returncode}
    match = re.search(r"production functions documented:\s*(\d+)/(\d+)", output)
    if match:
        details["documented_functions"] = int(match.group(1))
        details["production_functions"] = int(match.group(2))
    return Check("source_documentation", not errors, details, errors)


def check_embedded_vulkan_shaders(root: Path) -> Check:
    """Rebuild the embedded SPIR-V header and require byte-identical output."""
    output = root / "build" / "verify-vulkan-shaders.h"
    output.parent.mkdir(parents=True, exist_ok=True)
    process = subprocess.run(
        [
            sys.executable, str(root / "tools/embed_spirv.py"),
            "--vertex", str(root / "native/shaders/miniquake_vulkan.vert.spv"),
            "--fragment", str(root / "native/shaders/miniquake_vulkan.frag.spv"),
            "--output", str(output),
        ],
        capture_output=True,
        text=True,
    )
    checked_in = root / "native/miniquake_vulkan_shaders.h"
    errors: list[str] = []
    if process.returncode != 0:
        errors.append((process.stdout + process.stderr).strip())
    elif output.read_bytes() != checked_in.read_bytes():
        errors.append("native/miniquake_vulkan_shaders.h is stale; regenerate it with tools/embed_spirv.py")
    return Check(
        "embedded_vulkan_shaders", not errors,
        {"return_code": process.returncode, "header_sha256": sha256(checked_in)},
        errors,
    )


def check_opt001cr1(root: Path) -> Check:
    out = root / "build" / "verify-opt001cr1.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(root / "tools/check_opt001cr1.py"),
         "--root", str(root), "--json", str(out)],
        capture_output=True, text=True,
    )
    errors: list[str] = []
    details: dict[str, object] = {"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report = json.loads(out.read_text(encoding="utf-8-sig"))
            details["status"] = report.get("status", "")
            details["trace_hash_assignments"] = report.get("trace_hash_assignments", 0)
            details["delimiter_return_code"] = report.get("delimiter_return_code", -1)
        except Exception as exc:
            errors.append(f"invalid OPT-001CR1 report: {exc}")
    return Check("opt001cr1_syntax_hotfix", not errors, details, errors)


def check_opt001cr2(root: Path) -> Check:
    out = root / "build" / "verify-opt001cr2.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(root / "tools/check_opt001cr2.py"),
         "--root", str(root), "--json", str(out), "--allow-downstream-package"],
        capture_output=True, text=True,
    )
    errors: list[str] = []
    details: dict[str, object] = {"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report = json.loads(out.read_text(encoding="utf-8-sig"))
            details["status"] = report.get("status", "")
            details["artifact_prefix"] = report.get("artifact_prefix", "")
            details["effective_handle_windows"] = report.get("effective_handle_windows", 0)
        except Exception as exc:
            errors.append(f"invalid OPT-001CR2 report: {exc}")
    return Check("opt001cr2_harness_hotfix", not errors, details, errors)


def check_opt001c(root: Path) -> Check:
    out = root / "build" / "verify-opt001c.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [sys.executable, str(root / "tools/check_opt001c.py"), "--root", str(root), "--json", str(out), "--allow-downstream-package"],
        capture_output=True, text=True,
    )
    errors: list[str] = []
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    details: dict[str, object] = {"return_code": proc.returncode}
    if out.is_file():
        try:
            report = json.loads(out.read_text(encoding="utf-8-sig"))
            details["status"] = report.get("status", "")
            details["gl11_guarded_trace_calls"] = report.get("checks", {}).get("gl11_guarded_trace_calls", 0)
            details["world_guarded_trace_calls"] = report.get("checks", {}).get("world_guarded_trace_calls", 0)
        except Exception as exc:
            errors.append(f"invalid OPT-001C report: {exc}")
    return Check("opt001c_contract", not errors, details, errors)




def check_opt001d(root: Path) -> Check:
    out = root / "build" / "verify-opt001d.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run([sys.executable, str(root / "tools/check_opt001d.py"), "--root", str(root), "--json", str(out)], capture_output=True, text=True)
    errors=[]; details={"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report=json.loads(out.read_text(encoding="utf-8")); details["status"]=report.get("status",""); details["audio_mixahead"]=report.get("audio_mixahead",0); details["pvs_cache"]=report.get("pvs_cache",False)
        except Exception as exc: errors.append(f"invalid OPT-001D report: {exc}")
    return Check("opt001d_performance_audio_ui", not errors, details, errors)

def check_opt001cr3r6(root: Path) -> Check:
    out = root / "build" / "verify-opt001cr3r6.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run([sys.executable, str(root / "tools/check_opt001cr3r6.py"), "--root", str(root), "--json", str(out)], capture_output=True, text=True)
    errors=[]
    details={"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report=json.loads(out.read_text(encoding="utf-8")); details["status"]=report.get("status",""); details["default_video_mode"]=report.get("default_video_mode",""); details["renderer_reset"]=report.get("renderer_reset",False)
        except Exception as exc: errors.append(f"invalid OPT-001CR3R6 report: {exc}")
    return Check("opt001cr3r6_windowed_transition", not errors, details, errors)


def check_opt001cr3(root: Path) -> Check:
    out = root / "build" / "verify-opt001cr3.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run([sys.executable, str(root / "tools/check_opt001cr3.py"), "--root", str(root), "--json", str(out)], capture_output=True, text=True)
    errors=[]
    details={"return_code": proc.returncode}
    if proc.returncode != 0:
        errors.append((proc.stdout + "\n" + proc.stderr).strip())
    if out.is_file():
        try:
            report=json.loads(out.read_text(encoding="utf-8-sig")); details["status"]=report.get("status",""); details["inline_functions"]=report.get("inline_functions",0)
        except Exception as exc: errors.append(f"invalid OPT-001CR3 report: {exc}")
    return Check("opt001cr3_inline_array_hotpaths", not errors, details, errors)

def main() -> int:
    """Run the current integrity checks and optionally write a JSON report."""
    parser = argparse.ArgumentParser()
    parser.add_argument("legacy_root", nargs="?")
    parser.add_argument("--root", default="")
    parser.add_argument("--json", default="")
    parser.add_argument(
        "--refresh-manifest",
        action="store_true",
        help="atomically regenerate SOURCE_MANIFEST.sha256 before verification",
    )
    args = parser.parse_args()
    if args.root and args.legacy_root:
        parser.error("specify the project root either positionally or with --root, not both")
    root_value = args.root or args.legacy_root or "."
    root = Path(root_value).resolve()
    if args.refresh_manifest:
        count = refresh_manifest(root)
        print(f"Refreshed {MANIFEST}: {count} files")
    checks = [
        check_required(root),
        check_manifest(root),
        check_identity(root),
        check_minilang_utf8_no_bom(root),
        check_minilang_entry_function_shadow_arity(root),
        check_minilang_delimiters(root),
        check_source_documentation(root),
        check_embedded_vulkan_shaders(root),
        check_no_game_data(root),
        check_native(root),
        check_minilang(root),
        check_external_contract(root),
        check_live_output(root),
        check_named_build_parameter_binding(root),
        check_powershell_elseif_syntax(root),
        check_powershell_interpolation_safety(root),
        check_verifier_cli_compatibility(root),
    ]
    passed = all(check.passed for check in checks)
    identity = next(check for check in checks if check.name == "package_identity")
    print("MiniQuake source verification")
    for check in checks:
        print(f"  [{'PASS' if check.passed else 'FAIL'}] {check.name}")
        for key, value in check.details.items():
            print(f"         {key}={value}")
        for error in check.errors:
            print(f"         error: {error}")
    print(f"MiniQuake source verification: {'PASS' if passed else 'FAIL'}")
    package_id = str(identity.details.get("package_id", ""))
    parent_package_id = str(identity.details.get("parent_package_id", ""))
    block_id = str(identity.details.get("block_id", ""))
    delivery_revision = str(identity.details.get("delivery_revision", ""))
    report = {
        "schema_version": 1,
        "package_id": package_id,
        "parent_package_id": parent_package_id,
        "block_id": block_id,
        "delivery_revision": delivery_revision,
        "status": "PASS" if passed else "FAIL",
        "checks": [asdict(check) for check in checks],
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
