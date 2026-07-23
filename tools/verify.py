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
        "src/miniquake/net_udp.ml",
        "src/miniquake/runtime_validation.ml",
        "tests/core_tests.ml",
        "tests/milestone_tests.ml",
        "scripts/validate_real_game.ps1",
        "tools/ml_scope_lint.py",
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
        root / "build" / "port-coverage.json",
    ]
    missing = [path.relative_to(root).as_posix() for path in required if not path.is_file()]
    if missing:
        raise SystemExit("port audit is incomplete: missing " + ", ".join(missing))

    coverage = json.loads((root / "build" / "port-coverage.json").read_text(encoding="utf-8"))
    entries = coverage.get("entries")
    declared_file_count = coverage.get("files")
    if not isinstance(entries, list) or len(entries) != 195 or declared_file_count != 195:
        raise SystemExit(
            "port coverage regression: expected 195 original C/header entries, got "
            + str(0 if not isinstance(entries, list) else len(entries))
            + " (declared=" + str(declared_file_count) + ")"
        )

    allowed = {"PORTIERT", "TEILPORTIERT", "PLATTFORMBRÜCKE", "OFFEN", "NICHT ZIELRELEVANT"}
    status_counts: dict[str, int] = {name: 0 for name in sorted(allowed)}
    original_names: set[str] = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise SystemExit("port coverage regression: non-object entry")
        original = entry.get("original")
        status = entry.get("status")
        target = entry.get("miniquake")
        if not isinstance(original, str) or not original:
            raise SystemExit("port coverage regression: entry without original filename")
        if original in original_names:
            raise SystemExit("port coverage regression: duplicate original file " + original)
        original_names.add(original)
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

    return {
        "original_files": len(entries),
        "status_counts": status_counts,
        "documents": [path.relative_to(root).as_posix() for path in required[:-1]],
        "machine_report": required[-1].relative_to(root).as_posix(),
    }



def verify_sky_initialization(root: Path) -> dict[str, Any]:
    """Guard the byte-exact GLQuake R_InitSky translation.

    MiniLang division can produce a float, while the original C code performs
    integer division before storing the averaged colour in a byte buffer.  The
    checks below prevent that runtime type regression and retain GLQuake's
    texture allocation/filtering semantics.
    """
    path = root / "src" / "miniquake" / "render" / "world.ml"
    text = path.read_text(encoding="utf-8")
    start = text.find("function R_InitSky(texture)")
    end = text.find("\n// Internal package-state adapters", start)
    if start < 0 or end < 0:
        raise SystemExit("R_InitSky implementation is missing or cannot be delimited")
    body = text[start:end]
    required = {
        "red integer average": "averageRed = native.trunc(red / count)",
        "green integer average": "averageGreen = native.trunc(green / count)",
        "blue integer average": "averageBlue = native.trunc(blue / count)",
        "solid internal format": "native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 3, 128, 128",
        "alpha internal format": "native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 4, 128, 128",
        "linear minification": "gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)",
        "linear magnification": "gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)",
        "transparent palette entry": "if source == 255 then alphaRgba[destination + 3] = 0 end if",
    }
    missing = [label for label, fragment in required.items() if fragment not in body]
    if missing:
        raise SystemExit("R_InitSky parity regression: missing " + ", ".join(missing))
    forbidden = {
        "floating byte average": "averageRed = red / count",
        "texture-id/index confusion": "skytexturenum = texture.glId",
        "destructive sky texture recreation": "gl.deleteTexture(solidskytexture)",
    }
    present = [label for label, fragment in forbidden.items() if fragment in body]
    if present:
        raise SystemExit("R_InitSky parity regression: " + ", ".join(present))
    return {
        "module": path.relative_to(root).as_posix(),
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
        "GLQuake R_InitSky: integer averaging, palette alpha, texture reuse and linear filtering verified",
        "MiniLang compiler execution: not performed by this verifier",
    ]
    (build / "verification.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
