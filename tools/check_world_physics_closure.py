#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the frozen BP-025..BP-029 WinQuake world/physics contract.

The historical checker keeps an exact-source mode for the original BP-029
package. Later black-port packages may explicitly request downstream mode.
Downstream mode still binds every immutable world/physics source byte-for-byte,
masks only narrowly documented cross-layer changes in server.ml, and binds the
accepted stable QuakeC-to-server mirror functions by their own exact section
hashes.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

PACKAGE = "BP-029"
PARENT = "BP-028"
STATUS = "world_physics_109_frozen_v1"
FINGERPRINT = 0x2235D77C
GOLDEN = "audit/world_physics_closure_golden.json"
CHECKERS = [
    "tools/check_world_hull.py",
    "tools/check_world_link.py",
    "tools/check_world_trace.py",
    "tools/check_server_move.py",
    "tools/check_server_physics.py",
    "tools/check_sv_user_movement.py",
    "tools/check_server_user.py",
]
AUTHORITATIVE_FILES = [
    "src/miniquake/world_hull.ml",
    "src/miniquake/world.ml",
    "src/miniquake/world_bsp.ml",
    "src/miniquake/server_collision.ml",
    "src/miniquake/server_move.ml",
    "src/miniquake/physics.ml",
    "src/miniquake/sv_user.ml",
    "src/miniquake/server.ml",
    "src/miniquake/world_physics_contract.ml",
]
MUTABLE_DOWNSTREAM_FILE = "src/miniquake/server.ml"
DOWNSTREAM_SERVER_ALLOWED_IMPORT = "import miniquake.host_command_numbers as hostNumbers"
DOWNSTREAM_SERVER_HOST_COMMAND_FUNCTIONS = (
    "Host_Color_f",
    "Host_Kick_f",
    "Host_Give_f",
)
DOWNSTREAM_SERVER_GC_ROOT_FUNCTIONS = (
    "requireSynchronizedVector",
    "synchronizedVectorTarget",
    "setSynchronizedVector",
    "syncQcVectorInto",
    "syncQcVectorIntoAt",
    "syncEstablishedQcVectorIntoAt",
    "resizeSynchronizedEdictArray",
    "ensureSynchronizedBaseline",
    "ensureSynchronizedEdict",
    "syncQuakeCEdict",
    "recomputeEdictCount",
    "syncQuakeCEdictRange",
    "syncQuakeCEdicts",
    "syncLoadedQuakeCEdicts",
    "syncQuakeCSnapshotEdictAt",
    "syncQuakeCSnapshotEdicts",
    "syncPlayerToQuakeC",
    "syncPlayerFromQuakeC",
)
DOWNSTREAM_SERVER_ALLOWED_FUNCTIONS = (
    *DOWNSTREAM_SERVER_HOST_COMMAND_FUNCTIONS,
    *DOWNSTREAM_SERVER_GC_ROOT_FUNCTIONS,
)
# SHA-256 of the current accepted server.ml after masking the separately
# section-bound host-command and stable QuakeC-mirror functions above.  The
# remaining bytes include the later regression-tested player-state, projectile,
# collision and telefrag fixes that superseded the historical BP-029 snapshot.
# Each synchronized-vector helper is bound separately so compiler-safe removal
# of redundant post-construction validation cannot weaken the remaining mask.
DOWNSTREAM_SERVER_PROTECTED_SHA256 = (
    "cbe0fb083e1ee809e6f8177f0d742aaf0317ebae00866202ba1678d540474570"
)
SERVER_SECTION_HASHES = {
    "runWorldPhysicsWithRetouch": "5b082bf6147659c213fe46e84679d44a73f11dcd2aac070ef51eaf66dd0ecc8b",
    "runNonClientPhysicsWithRetouch": "66825dd6c657984ef061f25b3942dd6092640f459d59a75d39576b0423843beb",
    "frameMode": "3b020b4e4e2ed693d3c2f628cc83f035ca15e951147cbee6d792daeb72622709",
}
SERVER_GC_ROOT_SECTION_HASHES = {
    "requireSynchronizedVector": "ec5668c4a4f343926434df4f9f256fcc4658ce668df851bc24248d98f57d5145",
    "synchronizedVectorTarget": "ad6d06242d93a70f749d1bd4fe713d4b503f33fde1b13239d863d6230f1dc734",
    "setSynchronizedVector": "2224733cf08b38279f043cbb565ff2ff8c0da73199ec77dac61479393e69bea0",
    "syncQcVectorInto": "539b24aabd4d4329ae5b6ba911250c0402a73867db06be6e2021c66081b44a2e",
    "syncQcVectorIntoAt": "dccd20c403b6b6de5cecec71613df9fa14e253eac0ac909af056de672ce50775",
    "syncEstablishedQcVectorIntoAt": "822bf200b5e3da8039ad437d4d119fe01ef3640b9eadeba5246ae6f3f7527dde",
    "resizeSynchronizedEdictArray": "feffb4ecf5ae81d17ec447f5c2e0d8535e566406518c5ea91172aa05346dd795",
    "ensureSynchronizedBaseline": "4373f3023d269bd09c9e4af1461b8c3046aeb4a6da501f4b47c0f39d801bbe92",
    "ensureSynchronizedEdict": "021e99d057bb0d8065985edbc3135f94c32ef3cde31672dd0f96c5c96fdd2562",
    "syncQuakeCEdict": "e284ddf91cee35f98352528f9985a544ef55d56ec907fffff166de05736117e2",
    "recomputeEdictCount": "c76b03b6df1ad59e54b32dd623a71854c23b11cd85556d6f630401e71502ae7e",
    "syncQuakeCEdictRange": "68c2a956d1b1a40bb97a69b5b54896591cb034a8bca8ad552225caca755ebde8",
    "syncQuakeCEdicts": "20487d24c832a3806d321883ccaccf5f7a7a3a20a892777009d5c2abe8759edc",
    "syncLoadedQuakeCEdicts": "dd64b00262cbab549e47098747ad2e6af8e61bd1985b49b7d59f54af724b3de7",
    "syncQuakeCSnapshotEdictAt": "0378875877db9959e14d529939e2e38a4a73b94bae8e07aeed4832fae9d0316a",
    "syncQuakeCSnapshotEdicts": "11d5c682650dfd92209c2a82c39ec3befd6a77d857c22633fb59be505b8d2842",
    "syncPlayerToQuakeC": "4ef4bfc0a9023055caee8af2d8345c230d84764d34f06e15215c45a53f78dad0",
    "syncPlayerFromQuakeC": "5ab8e9e2863d17f8399b18665a5ed8b08041ab0181a2597cf0db0272ee30d010",
}
PROTECTED_SERVER_SECTION_HASHES = {
    **SERVER_SECTION_HASHES,
    **SERVER_GC_ROOT_SECTION_HASHES,
}
DOWNSTREAM_SERVER_SECTION_SHA256 = SERVER_SECTION_HASHES
DOWNSTREAM_MODE = "historical_files_plus_server_sections"
CANONICAL = (
    "world_physics_109_frozen_v1|hull_nodes=6|link_expand=1|item_expand=15|"
    "move_step=18|clip_planes=5|fly_bumps=4|stop_epsilon=0.1|"
    "client_maxspeed=320|air_cap=30|idealpitch_forward=6|"
    "production_dispatch=shared_nonclient|force_retouch=ordered|"
    "protocol=protocol15_frozen_v1|quakec=quakec_109_frozen_v1"
)


def fnv(text: str) -> int:
    """Compute the fixture's FNV-1a fingerprint."""
    value = 2166136261
    for byte in text.encode("utf-8"):
        value = ((value ^ byte) * 16777619) & 0xFFFFFFFF
    return value


def sha(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _read(path: Path) -> str:
    """Read read from its caller-supplied source."""
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n")


def _const_string(source: str, name: str) -> str:
    """Extract a named MiniLang string constant from source text."""
    match = re.search(rf'^const\s+{re.escape(name)}\s*=\s*"([^"]*)"\s*$', source, re.M)
    return match.group(1) if match else ""


def _mask_downstream_server(source: str) -> tuple[str, list[str]]:
    """Remove only the documented BP-079 host-command deltas.

    Everything else in server.ml remains part of the frozen world/physics
    evidence. The GC-rooted mirror functions are masked here only because they
    are bound separately by SERVER_GC_ROOT_SECTION_HASHES. Missing or duplicate
    masks are treated as verification errors.
    """
    errors: list[str] = []
    normalized = source.replace("\r\n", "\n")
    import_pattern = re.compile(
        rf"^{re.escape(DOWNSTREAM_SERVER_ALLOWED_IMPORT)}\n", re.M
    )
    import_matches = len(import_pattern.findall(normalized))
    if import_matches > 1:
        errors.append("downstream server contains duplicate host-command import")
    normalized = import_pattern.sub("", normalized)

    for name in DOWNSTREAM_SERVER_ALLOWED_FUNCTIONS:
        pattern = re.compile(
            rf"(?ms)^function\s+{re.escape(name)}\([^\n]*\)\n.*?^end function\n?"
        )
        matches = list(pattern.finditer(normalized))
        if len(matches) != 1:
            errors.append(
                f"downstream server expected exactly one {name} function, got {len(matches)}"
            )
            continue
        normalized = pattern.sub(
            f"function {name}(<downstream-host-command-body>)\nend function\n",
            normalized,
            count=1,
        )
    return normalized, errors


def _protected_server_hash(root: Path) -> tuple[str, list[str]]:
    """Compute the accepted hash over protected server functions."""
    normalized, errors = _mask_downstream_server(_read(root / MUTABLE_DOWNSTREAM_FILE))
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest(), errors


def _function_hashes(source: str) -> tuple[dict[str, str], list[str]]:
    """Compute normalized hashes for the selected MiniLang functions."""
    values: dict[str, str] = {}
    errors: list[str] = []
    for name in PROTECTED_SERVER_SECTION_HASHES:
        pattern = re.compile(
            rf"(?ms)^function\s+{re.escape(name)}\([^\n]*\)\n.*?^end function\n?"
        )
        matches = list(pattern.finditer(source))
        if len(matches) != 1:
            errors.append(f"expected exactly one protected server function {name}, got {len(matches)}")
            continue
        values[name] = hashlib.sha256(matches[0].group(0).encode("utf-8")).hexdigest()
    return values, errors


def doc(root: Path) -> dict[str, object]:
    """Render the canonical evidence document for this verifier."""
    return {
        "schema": "MiniQuakeWorldPhysicsClosureGolden/1",
        "package_id": PACKAGE,
        "parent_package_id": PARENT,
        "status": STATUS,
        "fingerprint": FINGERPRINT,
        "canonical": CANONICAL,
        "components": ["BP-025", "BP-026", "BP-027", "BP-028", "BP-029"],
        "authoritative_files": {name: sha(root / name) for name in AUTHORITATIVE_FILES},
        "runtime_fixtures": 20,
    }


def _verify_downstream_golden(root: Path, golden: dict[str, object]) -> tuple[list[str], dict[str, object]]:
    """Validate downstream golden and return its contract findings."""
    errors: list[str] = []
    expected_metadata = {
        "schema": "MiniQuakeWorldPhysicsClosureGolden/1",
        "package_id": PACKAGE,
        "parent_package_id": PARENT,
        "status": STATUS,
        "fingerprint": FINGERPRINT,
        "canonical": CANONICAL,
        "components": ["BP-025", "BP-026", "BP-027", "BP-028", "BP-029"],
        "runtime_fixtures": 20,
    }
    for key, expected in expected_metadata.items():
        if golden.get(key) != expected:
            errors.append(f"downstream world/physics golden metadata differs: {key}")

    recorded = golden.get("authoritative_files")
    if not isinstance(recorded, dict):
        errors.append("downstream world/physics golden has no authoritative_files object")
        recorded = {}

    exact_files = 0
    for name in AUTHORITATIVE_FILES:
        if name == MUTABLE_DOWNSTREAM_FILE:
            continue
        expected_hash = recorded.get(name)
        actual_hash = sha(root / name)
        if expected_hash != actual_hash:
            errors.append(f"frozen world/physics source changed: {name}")
        else:
            exact_files += 1

    server_source = _read(root / MUTABLE_DOWNSTREAM_FILE)
    server_hash, server_errors = _protected_server_hash(root)
    errors.extend(server_errors)
    section_hashes, section_errors = _function_hashes(server_source)
    errors.extend(section_errors)
    for name, expected_hash in PROTECTED_SERVER_SECTION_HASHES.items():
        if section_hashes.get(name) != expected_hash:
            category = "world/physics" if name in SERVER_SECTION_HASHES else "GC-rooted QuakeC mirror"
            errors.append(
                f"frozen {category} server function changed: {name}: "
                f"expected {expected_hash}, got {section_hashes.get(name, '')}"
            )
    if server_hash != DOWNSTREAM_SERVER_PROTECTED_SHA256:
        errors.append(
            "server.ml changed outside the documented BP-079 host-command and R7 stable-mirror regions: "
            f"expected {DOWNSTREAM_SERVER_PROTECTED_SHA256}, got {server_hash}"
        )

    build = _read(root / "src/miniquake/build_info.ml")
    if f'const WORLD_PHYSICS_STATUS = "{STATUS}"' not in build:
        errors.append("downstream package no longer binds frozen world/physics status")
    package_id = _const_string(build, "PACKAGE_ID")
    parent_id = _const_string(build, "PARENT_PACKAGE_ID")
    block_id = _const_string(build, "BLOCK_ID")
    if not package_id or not parent_id or not block_id:
        errors.append("downstream build identity is incomplete")

    details = {
        "exact_authoritative_files": exact_files,
        "mutable_authoritative_file": MUTABLE_DOWNSTREAM_FILE,
        "allowed_server_functions": list(DOWNSTREAM_SERVER_ALLOWED_FUNCTIONS),
        "host_command_functions": list(DOWNSTREAM_SERVER_HOST_COMMAND_FUNCTIONS),
        "gc_root_functions": list(DOWNSTREAM_SERVER_GC_ROOT_FUNCTIONS),
        "server_protected_sha256": server_hash,
        "server_section_sha256": section_hashes,
        "server_gc_root_section_sha256": {
            name: section_hashes.get(name, "") for name in SERVER_GC_ROOT_SECTION_HASHES
        },
        "build_package_id": package_id,
        "build_parent_package_id": parent_id,
        "build_block_id": block_id,
    }
    return errors, details


def contract(root: Path) -> list[str]:
    """Evaluate the source and runtime evidence for this contract."""
    errors: list[str] = []
    module = _read(root / "src/miniquake/world_physics_contract.ml")
    test = _read(root / "tests/world_physics_closure_tests.ml")
    if fnv(CANONICAL) != FINGERPRINT:
        errors.append("Python contract fingerprint changed")
    for marker in (
        f'const STATUS = "{STATUS}"',
        f"const CONTRACT_FINGERPRINT = 0x{FINGERPRINT:08x}",
        CANONICAL,
    ):
        if marker not in module:
            errors.append("missing closure marker: " + marker[:80])
    if test.count("if run(") != 20 or "world/physics closure tests passed: 20" not in test:
        errors.append("expected 20 closure fixtures")

    physics = _read(root / "src/miniquake/physics.ml")
    server = _read(root / "src/miniquake/server.ml")
    for marker in (
        "function SV_Physics_NonClientEntity",
        "function SV_ForceRetouchValue",
        "function SV_ForceRetouchEntity",
        "function SV_FinishForceRetouch",
    ):
        if marker not in physics:
            errors.append("missing production physics marker: " + marker)

    frame_start = server.index("function frameMode")
    frame_end = server.index("function frame(", frame_start)
    frame = server[frame_start:frame_end]
    world_start = server.index("function runWorldPhysicsWithRetouch")
    world_end = server.index("function runNonClientPhysicsWithRetouch", world_start)
    world = server[world_start:world_end]
    nonclient_start = world_end
    nonclient_end = server.index("function runNonClientPhysics(", nonclient_start)
    nonclients = server[nonclient_start:nonclient_end]

    if "physics.SV_Physics_NonClientEntity" not in world:
        errors.append("production world loop does not use shared physics dispatch")
    if "physics.SV_Physics_NonClientEntity" not in nonclients:
        errors.append("production non-client loop does not use shared physics dispatch")
    if "moveQcEntity(server" in nonclients:
        errors.append("production non-client loop still uses simplified moveQcEntity")
    client_marker = "physics.SV_ForceRetouchEntity(server, clientValue.edictIndex, forceRetouch)"
    if frame.index("runWorldPhysicsWithRetouch") > frame.index(client_marker):
        errors.append("world edict is not processed before client physics slots")
    if client_marker not in frame:
        errors.append("client force_retouch ordering missing")
    if "physics.SV_FinishForceRetouch(server, forceRetouch)" not in frame:
        errors.append("force_retouch decrement missing from integrated frame")
    return errors


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--root", dest="root_flag")
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--json-output")
    parser.add_argument(
        "--allow-downstream-package",
        action="store_true",
        help="verify the frozen BP-029 contract inside a later package identity",
    )
    args = parser.parse_args()
    root = Path(args.root_flag or args.root).resolve()
    current = doc(root)
    golden_path = root / GOLDEN
    if args.write_golden:
        golden_path.parent.mkdir(parents=True, exist_ok=True)
        golden_path.write_text(json.dumps(current, indent=2) + "\n", encoding="utf-8")

    errors: list[str] = []
    downstream_details: dict[str, object] = {}
    if not golden_path.is_file():
        errors.append("missing closure golden")
    else:
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
        if args.allow_downstream_package:
            downstream_errors, downstream_details = _verify_downstream_golden(root, golden)
            errors.extend(downstream_errors)
        elif golden != current:
            errors.append("closure golden differs from authoritative sources")

    component: list[dict[str, object]] = []
    for relative in CHECKERS:
        completed = subprocess.run(
            [sys.executable, str(root / relative), str(root)],
            capture_output=True,
            text=True,
            check=False,
        )
        component.append({"checker": relative, "exit_code": completed.returncode})
        if completed.returncode:
            errors.append(relative + " failed: " + (completed.stdout + completed.stderr).strip())
    errors.extend(contract(root))

    report = {
        "schema": "MiniQuakeBP029WorldPhysicsClosureVerification/2",
        "package_id": PACKAGE,
        "parent_package_id": PARENT,
        "status": STATUS,
        "fingerprint": f"0x{FINGERPRINT:08x}",
        "ok": not errors,
        "components": component,
        "runtime_fixtures": 20,
        "downstream_package": bool(args.allow_downstream_package),
        "downstream_mode": DOWNSTREAM_MODE if args.allow_downstream_package else "strict_historical_whole_file",
        "downstream": downstream_details,
        "details": {
            "server_section_hashes": downstream_details.get("server_section_sha256", {}),
            "server_protected_sha256": downstream_details.get("server_protected_sha256", ""),
            "authoritative_mode": DOWNSTREAM_MODE if args.allow_downstream_package else "strict_historical_whole_file",
        },
        "errors": errors,
    }
    if args.json_output:
        Path(args.json_output).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("MiniQuake BP-029 world/physics closure verification: " + ("PASS" if not errors else "FAIL"))
    print(
        f"  components={len(CHECKERS)} runtime_fixtures=20 "
        f"fingerprint=0x{FINGERPRINT:08x} "
        f"downstream={str(bool(args.allow_downstream_package)).lower()}"
    )
    if args.allow_downstream_package and downstream_details:
        print(
            "  authoritative_mode=" + DOWNSTREAM_MODE
            + " protected_server_sha256="
            + str(downstream_details.get("server_protected_sha256", ""))
            + " package="
            + str(downstream_details.get("build_package_id", ""))
            + " block="
            + str(downstream_details.get("build_block_id", ""))
        )
    for error in errors:
        print("  ERROR: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
