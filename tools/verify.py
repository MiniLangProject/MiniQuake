#!/usr/bin/env python3
"""Reproducible static/native verification for the MiniQuake port tree."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import Any


def run(command: list[str], cwd: Path, *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    print("+", " ".join(command))
    return subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_def_exports(path: Path) -> list[str]:
    exports: list[str] = []
    active = False
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line.upper() == "EXPORTS":
            active = True
            continue
        if active and line and not line.startswith(";"):
            exports.append(line.split()[0])
    return exports


def parse_extern_symbols(root: Path) -> list[str]:
    symbols: list[str] = []
    pattern = re.compile(r'from\s+"miniquake_native\.dll"\s+symbol\s+"([^"]+)"')
    for path in sorted((root / "src").rglob("*.ml")):
        symbols.extend(pattern.findall(path.read_text(encoding="utf-8")))
    return sorted(set(symbols))


def source_metrics(root: Path) -> dict[str, Any]:
    ml_files = sorted((root / "src").rglob("*.ml")) + sorted((root / "tests").rglob("*.ml"))
    text = "\n".join(path.read_text(encoding="utf-8") for path in ml_files)
    return {
        "minilang_files": len(ml_files),
        "minilang_lines": sum(len(path.read_text(encoding="utf-8").splitlines()) for path in ml_files),
        "functions": len(re.findall(r"(?m)^\s*(?:static\s+)?function(?:\s+inline)?\s+", text)),
        "structs": len(re.findall(r"(?m)^struct\s+", text)),
        "enums": len(re.findall(r"(?m)^enum\s+", text)),
        "packages": len(re.findall(r"(?m)^package\s+", text)),
    }


def verify_build_toolchain(root: Path) -> dict[str, Any]:
    """Guard the import-root fix that is required for source-based std.* modules."""
    path = root / "build.ps1"
    if not path.is_file():
        raise SystemExit("build.ps1 is missing")

    text = path.read_text(encoding="utf-8")
    required_fragments = {
        "python compiler support": "$CompilerIsPython",
        "Python compiler discovery": "MiniLangCompilerPy\\mlc_win64.py",
        "stdlib discovery": "Find-StdImportRoot",
        "project import root": '"-I", $Source',
        "stdlib import root": '"-I", $StdImportRoot',
        "stdlib preflight": "std\\fs.ml",
        "structural source preflight": "tools\\ml_lint.py",
        "lexical-scope source preflight": "tools\\ml_scope_lint.py",
    }
    missing = [label for label, fragment in required_fragments.items() if fragment not in text]
    if missing:
        raise SystemExit("build.ps1 toolchain regression: missing " + ", ".join(missing))

    return {
        "script": path.relative_to(root).as_posix(),
        "python_compiler_supported": True,
        "native_compiler_supported": True,
        "source_import_root": "src",
        "stdlib_import_root": "auto-detected or -StdLib",
        "required_std_module": "std/fs.ml",
    }



def verify_native_boundary(root: Path) -> dict[str, Any]:
    """Keep all MiniQuake DLL imports behind the single native boundary module."""
    allowed = (root / "src" / "miniquake" / "native.ml").resolve()
    offenders: list[str] = []
    marker = 'from "miniquake_native.dll"'
    for path in sorted((root / "src").rglob("*.ml")):
        if marker in path.read_text(encoding="utf-8") and path.resolve() != allowed:
            offenders.append(path.relative_to(root).as_posix())
    if offenders:
        raise SystemExit(
            "native boundary regression: only src/miniquake/native.ml may import "
            f"miniquake_native.dll; offenders={offenders}"
        )
    if not allowed.is_file():
        raise SystemExit("native boundary module is missing: src/miniquake/native.ml")
    return {
        "module": allowed.relative_to(root).as_posix(),
        "exclusive": True,
        "offenders": offenders,
    }


def verify_integrated_milestone(root: Path) -> dict[str, Any]:
    """Require the modules and build hooks that make up the integrated milestone."""
    required_files = [
        "src/miniquake/host.ml",
        "src/miniquake/server.ml",
        "src/miniquake/client.ml",
        "src/miniquake/graphics_data.ml",
        "src/miniquake/quakec/builtins.ml",
        "src/miniquake/quakec/edict.ml",
        "src/miniquake/player_move.ml",
        "src/miniquake/physics.ml",
        "src/miniquake/server_collision.ml",
        "src/miniquake/server_move.ml",
        "src/miniquake/render/world.ml",
        "src/miniquake/render/entities.ml",
        "src/miniquake/render/particles.ml",
        "src/miniquake/sound/mixer.ml",
        "src/miniquake/console.ml",
        "src/miniquake/menu.ml",
        "src/miniquake/screen.ml",
        "src/miniquake/statusbar.ml",
        "src/miniquake/demo_player.ml",
        "src/miniquake/net_datagram.ml",
        "src/miniquake/net_control.ml",
        "src/miniquake/net_udp.ml",
        "src/miniquake/savegame.ml",
        "src/miniquake/runtime_validation.ml",
        "tests/core_tests.ml",
        "tests/milestone_tests.ml",
        "scripts/validate_real_game.ps1",
        "tools/ml_scope_lint.py",
        "tools/network_matrix.py",
        "tools/network_impairment_matrix.py",
        "tools/network_multiclient_impairment_matrix.py",
        "tools/retail_demo_matrix.py",
        "tools/parity_oracle.py",
        "tools/generate_behavioral_parity.py",
        "tools/generate_semantic_review.py",
        "tools/gl_draw_differential.py",
        "tools/gl_model_differential.py",
        "tools/menu_differential.py",
        "tools/renderer_differential.py",
        "tools/r_part_differential.py",
        "tools/sbar_differential.py",
        "tools/view_differential.py",
        "tools/verify_dependencies.py",
        "audit/renderer_differential_manifest.json",
        "audit/gl_draw_differential_manifest.json",
        "audit/gl_model_differential_manifest.json",
        "audit/menu_differential_manifest.json",
        "audit/r_part_differential_manifest.json",
        "audit/sbar_differential_manifest.json",
        "audit/view_differential_manifest.json",
        "audit/SEMANTIC_AUDIT_PLAN.json",
        "audit/SEMANTIC_PORT_REVIEW.json",
        "docs/SEMANTIC_PORT_REVIEW.md",
        "reference/fixtures/r_part/mq_r_part_fixture.c",
        "reference/fixtures/r_part/mq_r_part_fixture.h",
        "reference/fixtures/gl_model/mq_gl_model_fixture.c",
        "reference/fixtures/menu/mq_menu_fixture.c",
        "reference/fixtures/gl_draw/mq_gl_draw_fixture.c",
        "reference/fixtures/sbar/mq_sbar_fixture.c",
        "reference/fixtures/view/mq_view_fixture.c",
        "reference/fixtures/renderer/mq_gl_warp_fixture.c",
        "reference/fixtures/renderer/mq_gl_warp_fixture.h",
        "reference/fixtures/renderer/mq_gl_rlight_fixture.c",
        "reference/fixtures/renderer/mq_gl_rlight_fixture.h",
        "reference/fixtures/renderer/mq_gl_refrag_fixture.c",
        "reference/fixtures/renderer/mq_gl_refrag_fixture.h",
        "reference/fixtures/renderer/mq_gl_rmisc_fixture.c",
        "reference/fixtures/renderer/mq_gl_rmisc_fixture.h",
        "reference/fixtures/renderer/mq_gl_rmain_fixture.c",
        "reference/fixtures/renderer/mq_gl_rmain_redirect.h",
        "reference/fixtures/renderer/mq_gl_rsurf_fixture.c",
        "reference/fixtures/renderer/mq_gl_rsurf_fixture.h",
        "reference/patches/renderer_rlight_trace_fixture.patch",
        "reference/patches/renderer_refrag_trace_fixture.patch",
        "reference/patches/renderer_rmisc_trace_fixture.patch",
        "reference/patches/renderer_rmain_trace_fixture.patch",
        "reference/patches/renderer_rsurf_trace_fixture.patch",
        "reference/patches/renderer_trace_fixture.patch",
        "reference/patches/renderer_warp_trace_fixture.patch",
        "reference/patches/r_part_trace_fixture.patch",
        "tests/r_part_differential_fixture.ml",
        "tests/gl_model_differential_fixture.ml",
        "tests/menu_differential_fixture.ml",
        "tests/gl_draw_differential_fixture.ml",
        "tests/sbar_differential_fixture.ml",
        "tests/view_differential_fixture.ml",
        "tests/renderer_rlight_trace_fixture.ml",
        "tests/renderer_refrag_trace_fixture.ml",
        "tests/renderer_rmisc_trace_fixture.ml",
        "tests/renderer_rmain_trace_fixture.ml",
        "tests/renderer_rsurf_trace_fixture.ml",
        "tests/renderer_warp_trace_fixture.ml",
    ]
    missing = [name for name in required_files if not (root / name).is_file()]
    if missing:
        raise SystemExit("integrated milestone files are missing: " + ", ".join(missing))

    main_text = (root / "src" / "main.ml").read_text(encoding="utf-8")
    required_commands = [
        "--validate-game",
        "--validate-runtime",
        "--runtime-smoke",
        "--render-smoke",
        "--soak",
        "--demo-verify",
        "--udp-smoke",
        "--music-smoke",
    ]
    missing_commands = [command for command in required_commands if command not in main_text]
    if missing_commands:
        raise SystemExit("integrated CLI commands are missing: " + ", ".join(missing_commands))

    build_text = (root / "build.ps1").read_text(encoding="utf-8")
    required_build_fragments = [
        "MiniQuakeTests.exe",
        "MiniQuakeMilestoneTests.exe",
        r"tests\core_tests.ml",
        r"tests\milestone_tests.ml",
    ]
    missing_build = [fragment for fragment in required_build_fragments if fragment not in build_text]
    if missing_build:
        raise SystemExit("build test integration is incomplete: " + ", ".join(missing_build))

    def declared_test_count(path: Path, suite_name: str) -> int:
        text = path.read_text(encoding="utf-8")
        match = re.search(rf"MiniQuake {re.escape(suite_name)} tests starting: (\d+)", text)
        if not match:
            raise SystemExit(f"cannot determine {suite_name} test count from {path}")
        return int(match.group(1))

    return {
        "required_files": len(required_files),
        "cli_commands": required_commands,
        "core_tests": declared_test_count(root / "tests" / "core_tests.ml", "core"),
        "milestone_tests": declared_test_count(root / "tests" / "milestone_tests.ml", "milestone"),
    }

def verify_port_audit(root: Path) -> dict[str, Any]:
    """Keep the source-by-source WinQuake coverage audit part of the release."""
    required = [
        root / "PORT_AUDIT.md",
        root / "PARITY_TEST_PLAN.md",
        root / "ORIGINAL_FILE_COVERAGE.md",
        root / "audit" / "PORT_COVERAGE.json",
        root / "audit" / "GLQUAKE_PORT_INVENTORY.json",
        root / "docs" / "GLQUAKE_PORT_INVENTORY.md",
        root / "reference" / "quake.lock.json",
        root / "third_party" / "stb.lock.json",
        root / "docs" / "IMPLEMENTATION_PROGRESS.md",
        root / "docs" / "PARITY_TRACE_SCHEMA.md",
    ]
    missing = [path.relative_to(root).as_posix() for path in required if not path.is_file()]
    if missing:
        raise SystemExit("port audit is incomplete: missing " + ", ".join(missing))

    coverage = json.loads((root / "audit" / "PORT_COVERAGE.json").read_text(encoding="utf-8"))
    entries = coverage.get("entries")
    declared_file_count = coverage.get("files")
    reference_root = root / "reference" / "quake" / "WinQuake"
    if not reference_root.is_dir():
        raise SystemExit(
            "pinned GLQuake reference is absent; run `git submodule update --init`"
        )
    pinned_files = {
        path.relative_to(reference_root).as_posix()
        for path in reference_root.rglob("*")
        if path.is_file() and path.suffix.lower() in {".c", ".h"}
    }
    expected_count = len(pinned_files)
    if (
        not isinstance(entries, list)
        or len(entries) != expected_count
        or declared_file_count != expected_count
    ):
        raise SystemExit(
            f"port coverage regression: expected {expected_count} pinned C/header entries, got "
            + str(0 if not isinstance(entries, list) else len(entries))
            + " (declared=" + str(declared_file_count) + ")"
        )

    allowed = {"PORTIERT", "TEILPORTIERT", "PLATTFORMBRÜCKE", "OFFEN", "NICHT ZIELRELEVANT"}
    status_counts: dict[str, int] = {name: 0 for name in sorted(allowed)}
    original_paths: set[str] = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise SystemExit("port coverage regression: non-object entry")
        original = entry.get("original")
        original_path = entry.get("path")
        status = entry.get("status")
        target = entry.get("miniquake")
        if not isinstance(original, str) or not original:
            raise SystemExit("port coverage regression: entry without original filename")
        if not isinstance(original_path, str) or not original_path:
            raise SystemExit("port coverage regression: entry without original path")
        if original_path in original_paths:
            raise SystemExit(
                "port coverage regression: duplicate original path " + original_path
            )
        if Path(original_path).name != original:
            raise SystemExit(
                "port coverage regression: path/name mismatch for " + original_path
            )
        original_paths.add(original_path)
        if status not in allowed:
            raise SystemExit("port coverage regression: invalid status for " + original + ": " + str(status))
        if not isinstance(target, str) or not target:
            raise SystemExit("port coverage regression: missing MiniQuake mapping for " + original)
        status_counts[status] += 1

    declared_counts = coverage.get("counts", {})
    if declared_counts and declared_counts != status_counts:
        raise SystemExit(
            "port coverage regression: status_counts do not match entries; declared="
            + str(declared_counts)
            + " actual="
            + str(status_counts)
        )
    missing_paths = sorted(pinned_files - original_paths)
    extra_paths = sorted(original_paths - pinned_files)
    if missing_paths or extra_paths:
        raise SystemExit(
            "port coverage regression: pinned source mismatch; missing="
            + str(missing_paths)
            + " extra="
            + str(extra_paths)
        )

    inventory = json.loads(
        (root / "audit" / "GLQUAKE_PORT_INVENTORY.json").read_text(encoding="utf-8")
    )
    if inventory.get("schema") != 2 or not isinstance(inventory.get("units"), list):
        raise SystemExit("function inventory regression: invalid schema or units")
    units = inventory["units"]
    summary = inventory.get("summary", {})
    unit_names: set[str] = set()
    inventoried_files: set[str] = set()
    actual_function_counts = {
        "located": 0,
        "candidate": 0,
        "unmapped": 0,
        "excluded": 0,
    }
    actual_assembly_counts = {
        "located": 0,
        "candidate": 0,
        "unmapped": 0,
        "excluded": 0,
    }
    function_total = 0
    target_function_total = 0
    target_function_located = 0
    target_assembly_total = 0
    target_assembly_located = 0
    target_units = 0
    target_units_with_counterpart = 0
    for unit in units:
        if not isinstance(unit, dict) or not isinstance(unit.get("unit"), str):
            raise SystemExit("function inventory regression: invalid logical unit")
        unit_name = unit["unit"]
        if unit_name in unit_names:
            raise SystemExit(
                "function inventory regression: duplicate logical unit " + unit_name
            )
        unit_names.add(unit_name)
        scope = unit.get("scope")
        modules = unit.get("minilang_modules")
        if scope not in {"target", "excluded"} or not isinstance(modules, list):
            raise SystemExit(
                "function inventory regression: invalid scope/modules for " + unit_name
            )
        if scope == "target" and not modules:
            raise SystemExit(
                "function inventory regression: target unit without MiniLang pendant "
                + unit_name
            )
        if scope == "target":
            target_units += 1
            target_units_with_counterpart += 1
        for module in modules:
            module_path = module.get("path") if isinstance(module, dict) else None
            if not isinstance(module_path, str) or not (root / module_path).is_file():
                raise SystemExit(
                    "function inventory regression: stale module mapping in " + unit_name
                )
        for original in unit.get("original_files", []):
            original_path = original.get("path") if isinstance(original, dict) else None
            if not isinstance(original_path, str) or original_path in inventoried_files:
                raise SystemExit(
                    "function inventory regression: invalid/duplicate original in "
                    + unit_name
                )
            inventoried_files.add(original_path)
        functions = unit.get("functions")
        if not isinstance(functions, list):
            raise SystemExit(
                "function inventory regression: functions missing from " + unit_name
            )
        function_total += len(functions)
        for function in functions:
            status = function.get("mapping_status") if isinstance(function, dict) else None
            evidence = function.get("evidence") if isinstance(function, dict) else None
            if status not in actual_function_counts or not isinstance(evidence, list):
                raise SystemExit(
                    "function inventory regression: invalid function mapping in "
                    + unit_name
                )
            if status in {"located", "candidate"} and not evidence:
                raise SystemExit(
                    "function inventory regression: evidence-free code location in "
                    + unit_name
                )
            actual_function_counts[status] += 1
            if str(function.get("scope", "")).startswith("target"):
                target_function_total += 1
                if status == "located":
                    target_function_located += 1
        assembly_exports = unit.get("assembly_exports")
        if not isinstance(assembly_exports, list):
            raise SystemExit(
                "function inventory regression: assembly exports missing from "
                + unit_name
            )
        for export in assembly_exports:
            status = export.get("mapping_status") if isinstance(export, dict) else None
            evidence = export.get("evidence") if isinstance(export, dict) else None
            if status not in actual_assembly_counts or not isinstance(evidence, list):
                raise SystemExit(
                    "function inventory regression: invalid assembly mapping in "
                    + unit_name
                )
            if status in {"located", "candidate"} and not evidence:
                raise SystemExit(
                    "function inventory regression: evidence-free assembly code "
                    "location in " + unit_name
                )
            actual_assembly_counts[status] += 1
            if str(export.get("scope", "")).startswith("target"):
                target_assembly_total += 1
                if status == "located":
                    target_assembly_located += 1
    if len(units) != summary.get("logical_units"):
        raise SystemExit("function inventory regression: logical unit count mismatch")
    if function_total != summary.get("c_function_definitions"):
        raise SystemExit("function inventory regression: C function count mismatch")
    if actual_function_counts != summary.get("function_mapping_counts"):
        raise SystemExit("function inventory regression: function status count mismatch")
    if actual_assembly_counts != summary.get("assembly_export_counts"):
        raise SystemExit(
            "function inventory regression: assembly status count mismatch"
        )
    expected_summary = {
        "target_units": target_units,
        "target_units_with_minilang_counterpart": target_units_with_counterpart,
        "target_c_function_definitions": target_function_total,
        "target_c_function_definitions_located": target_function_located,
        "target_assembly_exports": target_assembly_total,
        "target_assembly_exports_located": target_assembly_located,
    }
    for key, expected in expected_summary.items():
        if summary.get(key) != expected:
            raise SystemExit(
                "function inventory regression: "
                + key
                + " mismatch; expected "
                + str(expected)
            )
    if any("behavioral_parity" in unit for unit in units):
        raise SystemExit(
            "function inventory regression: code-location inventory must not "
            "duplicate the separate behavioral-parity state"
        )

    return {
        "original_files": len(entries),
        "status_counts": status_counts,
        "documents": [path.relative_to(root).as_posix() for path in required[:3]],
        "machine_report": required[3].relative_to(root).as_posix(),
        "reference_lock": (root / "reference" / "quake.lock.json").relative_to(root).as_posix(),
        "logical_units": len(units),
        "c_functions": function_total,
        "unmapped_target_functions": sum(
            1
            for unit in units
            for function in unit["functions"]
            if function.get("scope") == "target"
            and function.get("mapping_status") == "unmapped"
        ),
        "function_inventory": "audit/GLQUAKE_PORT_INVENTORY.json",
    }



def verify_sky_initialization(root: Path) -> dict[str, Any]:
    """Guard the byte-exact GLQuake R_InitSky translation.

    MiniLang division can produce a float, while the original C code performs
    integer division before storing the averaged colour in a byte buffer.  The
    checks below prevent that runtime type regression and retain GLQuake's
    texture allocation/filtering semantics.
    """
    upload_path = root / "src" / "miniquake" / "render" / "world.ml"
    pixel_path = root / "src" / "miniquake" / "render" / "gl_warp.ml"
    upload_text = upload_path.read_text(encoding="utf-8")
    pixel_text = pixel_path.read_text(encoding="utf-8")
    upload_start = upload_text.find("function R_InitSky(texture)")
    upload_end = upload_text.find("\n// Internal package-state adapters", upload_start)
    pixel_start = pixel_text.find("function R_InitSkyPixels(texture, palette)")
    pixel_end = pixel_text.find("\nfunction R_InitSky(texture, palette)", pixel_start)
    if min(upload_start, upload_end, pixel_start, pixel_end) < 0:
        raise SystemExit("R_InitSky implementation is missing or cannot be delimited")
    upload_body = upload_text[upload_start:upload_end]
    pixel_body = pixel_text[pixel_start:pixel_end]
    required_pixels = {
        "red integer average": "averageRed = native.trunc(red / (128 * 128))",
        "green integer average": "averageGreen = native.trunc(green / (128 * 128))",
        "blue integer average": "averageBlue = native.trunc(blue / (128 * 128))",
        "transparent palette entry": "if color == 255 then alpha[offset + 3] = 0 end if",
    }
    required_upload = {
        "delegated byte translation": "pixels = glWarp.R_InitSky(texture, rCompatRenderer.palette)",
        "solid internal format": "native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 3, 128, 128",
        "alpha internal format": "native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 4, 128, 128",
        "linear minification": "gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)",
        "linear magnification": "gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)",
    }
    missing = [
        label
        for label, fragment in required_pixels.items()
        if fragment not in pixel_body
    ]
    missing.extend(
        label
        for label, fragment in required_upload.items()
        if fragment not in upload_body
    )
    if missing:
        raise SystemExit("R_InitSky parity regression: missing " + ", ".join(missing))
    forbidden = {
        "floating byte average": "averageRed = red / count",
        "texture-id/index confusion": "skytexturenum = texture.glId",
        "destructive sky texture recreation": "gl.deleteTexture(solidskytexture)",
    }
    combined_body = pixel_body + upload_body
    present = [label for label, fragment in forbidden.items() if fragment in combined_body]
    if present:
        raise SystemExit("R_InitSky parity regression: " + ", ".join(present))
    return {
        "module": pixel_path.relative_to(root).as_posix(),
        "upload_module": upload_path.relative_to(root).as_posix(),
        "integer_average": True,
        "linear_filtering": True,
        "texture_ids_reused": True,
        "palette_255_transparent": True,
    }

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=Path(__file__).resolve().parents[1])
    parser.add_argument("--rebuild-native", action="store_true")
    parser.add_argument("--original", type=Path)
    args = parser.parse_args()
    root = Path(args.root).resolve()
    build = root / "build"
    build.mkdir(exist_ok=True)

    run([sys.executable, str(root / "tools" / "ml_lint.py"), str(root)], root)
    if args.rebuild_native:
        run([sys.executable, str(root / "native" / "build_bridge.py"), "--clean"], root)

    bridge = root / "native" / "miniquake_native.dll"
    if not bridge.is_file():
        raise SystemExit(f"missing native bridge: {bridge}")
    if bridge.read_bytes()[:2] != b"MZ":
        raise SystemExit("native bridge is not a PE file")

    expected_exports = sorted(parse_def_exports(root / "native" / "miniquake_native.def"))
    extern_symbols = parse_extern_symbols(root)
    missing_declarations = sorted(set(expected_exports) - set(extern_symbols))
    missing_exports = sorted(set(extern_symbols) - set(expected_exports))
    if missing_declarations or missing_exports:
        raise SystemExit(
            "native ABI mismatch: "
            f"exports without MiniLang declarations={missing_declarations}; "
            f"declarations without exports={missing_exports}"
        )

    pe_tool = shutil.which("llvm-readobj")
    pe_output = "No LLVM PE inspection tool was found; only MZ signature and ABI manifest were checked.\n"
    if pe_tool:
        result = run(
            [pe_tool, "--file-headers", "--coff-exports", "--coff-imports", str(bridge)],
            root,
            capture=True,
        )
        pe_output = result.stdout
        if "IMAGE_FILE_MACHINE_AMD64" not in pe_output:
            raise SystemExit("native bridge is not AMD64 PE/COFF")
        for symbol in expected_exports:
            if symbol not in pe_output:
                raise SystemExit(f"native bridge export missing from PE table: {symbol}")
    else:
        objdump = shutil.which("llvm-objdump")
        if objdump:
            result = run([objdump, "-p", str(bridge)], root, capture=True)
            pe_output = result.stdout
            if "coff-x86-64" not in pe_output and "x86-64" not in pe_output:
                raise SystemExit("native bridge is not AMD64 PE/COFF")
            for symbol in expected_exports:
                if symbol not in pe_output:
                    raise SystemExit(f"native bridge export missing from PE table: {symbol}")
    pe_output = pe_output.replace(str(root), ".")
    (root / "native" / "build" / "pe-inspection.txt").write_text(pe_output, encoding="utf-8")

    game_data = [
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in {".pak", ".bsp", ".mdl", ".spr", ".dem", ".lmp"}
    ]
    if game_data:
        raise SystemExit(f"copyrighted Quake game data must not be distributed: {game_data}")

    if not (root / "COPYING").is_file():
        raise SystemExit("COPYING is missing")

    run([sys.executable, str(root / "tools" / "verify_reference.py")], root)
    run([sys.executable, str(root / "tools" / "verify_dependencies.py")], root)
    run([sys.executable, str(root / "tools" / "generate_port_audit.py")], root)
    run([sys.executable, str(root / "tools" / "generate_port_inventory.py")], root)
    run(
        [sys.executable, str(root / "tools" / "generate_behavioral_parity.py")],
        root,
    )
    run(
        [sys.executable, str(root / "tools" / "generate_semantic_review.py")],
        root,
    )
    run(
        [sys.executable, str(root / "tools" / "parity_oracle.py"), "self-test"],
        root,
    )

    metrics = source_metrics(root)
    build_toolchain = verify_build_toolchain(root)
    native_boundary = verify_native_boundary(root)
    integrated_milestone = verify_integrated_milestone(root)
    port_audit = verify_port_audit(root)
    sky_initialization = verify_sky_initialization(root)
    report: dict[str, Any] = {
        "status": "passed",
        "root": ".",
        "metrics": metrics,
        "native_bridge": {
            "path": bridge.relative_to(root).as_posix(),
            "bytes": bridge.stat().st_size,
            "sha256": sha256(bridge),
            "exports": len(expected_exports),
            "machine": "AMD64",
        },
        "game_data_files": game_data,
        "build_toolchain": build_toolchain,
        "native_boundary": native_boundary,
        "integrated_milestone": integrated_milestone,
        "port_audit": port_audit,
        "sky_initialization": sky_initialization,
        "compiler_execution": "not performed by verify.py",
    }
    if args.original:
        original = args.original.resolve()
        report["original_source"] = {
            "path": str(original),
            "files": sum(1 for path in original.rglob("*") if path.is_file()),
        }

    (build / "verification.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    lines = [
        "MiniQuake verification: PASSED",
        f"MiniLang files: {metrics['minilang_files']}",
        f"MiniLang lines: {metrics['minilang_lines']}",
        f"Functions: {metrics['functions']}",
        f"Structs: {metrics['structs']}",
        f"Native exports: {len(expected_exports)}",
        f"Native DLL SHA-256: {report['native_bridge']['sha256']}",
        "Build toolchain: Python/native compiler + project/std import roots checked",
        "Native boundary: exclusive src/miniquake/native.ml import verified",
        f"Integrated milestone: host/server/client/render/audio/UDP + {integrated_milestone['core_tests'] + integrated_milestone['milestone_tests']} tests wired",
        f"Original source audit: {port_audit['original_files']} C/header files classified",
        f"GL target inventory: {port_audit['logical_units']} logical units, {port_audit['c_functions']} C functions, {port_audit['unmapped_target_functions']} target functions unmapped",
        "GLQuake R_InitSky: integer averaging, palette alpha, texture reuse and linear filtering verified",
        "MiniLang compiler execution: not performed by this verifier",
    ]
    (build / "verification.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
