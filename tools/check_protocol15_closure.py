#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the cumulative BP-015..BP-019 Protocol 15 closure and freeze."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

PACKAGE_ID = "BP-019"
PARENT_PACKAGE_ID = "BP-018"
BLOCK_ID = "BP-015-019"
BLOCK_PARENT = "BP-014R1"
SCHEMA = "MiniQuakeProtocol15ClosureGolden/1"
REPORT = "MiniQuakeBP019Protocol15ClosureVerification/1"
GOLDEN = "audit/protocol15_closure_golden.json"
FREEZE = "audit/protocol15_freeze.json"
ORACLE = "tools/oracle/protocol15_closure_oracle.c"
STATUS = "protocol15_frozen_v1"
RUNTIME_FIXTURES = 15

DOWNSTREAM_MUTABLE_FILES = {"src/miniquake/demo.ml"}

AUTHORITATIVE_FILES = [
    "src/miniquake/constants.ml",
    "src/miniquake/sizebuf.ml",
    "src/miniquake/message.ml",
    "src/miniquake/protocol_text.ml",
    "src/miniquake/protocol_write.ml",
    "src/miniquake/protocol_signon.ml",
    "src/miniquake/protocol_delivery.ml",
    "src/miniquake/protocol_update.ml",
    "src/miniquake/protocol_serverdata.ml",
    "src/miniquake/protocol_events.ml",
    "src/miniquake/protocol_transients.ml",
    "src/miniquake/protocol15_freeze.ml",
    "src/miniquake/client_protocol.ml",
    "src/miniquake/net_datagram.ml",
    "src/miniquake/demo.ml",
]

COMPONENT_CHECKERS = [
    ("BP-010R1", "tools/check_protocol15_vectors.py"),
    ("BP-011", "tools/check_protocol15_commands.py"),
    ("BP-012R1", "tools/check_protocol15_serverdata.py"),
    ("BP-013", "tools/check_protocol15_events.py"),
    ("BP-014R1", "tools/check_protocol15_runtime_events.py"),
    ("BP-015", "tools/check_protocol15_signon.py"),
    ("BP-016", "tools/check_protocol15_delivery.py"),
    ("BP-017", "tools/check_protocol15_datagram.py"),
    ("BP-018", "tools/check_protocol15_demo.py"),
]


def sha(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def values() -> dict[str, list[int]]:
    """Build the deterministic values consumed by this verifier."""
    return {
        "svc": list(range(1, 21)) + list(range(22, 35)),
        "clc": list(range(1, 5)),
        "update": [1 << i for i in range(15)],
        "client": [1, 2, 4, 8, 16, 32, 64, 128, 512, 1024, 2048, 4096, 8192, 16384],
        "sound": [1, 2, 4],
        "temp": list(range(14)),
    }


def fingerprint() -> int:
    """Compute the contract fingerprint from its canonical fixture values."""
    groups = values()
    sequence = [15, 0x535643, *groups["svc"], 0x434C43, *groups["clc"],
                0x55424954, *groups["update"], 0x53554249, *groups["client"],
                0x534E44, *groups["sound"], 0x5445, *groups["temp"]]
    result = 2166136261
    for value in sequence:
        result = ((result ^ (value & 0xFFFFFFFF)) * 16777619) & 0xFFFFFFFF
    return result


def rows() -> list[dict[str, object]]:
    """Build the deterministic result rows for this verifier."""
    groups = values()
    pairs = [
        ("protocol_version", 15),
        ("svc_valid_count", len(groups["svc"])),
        ("svc_reserved_command", 21),
        ("clc_valid_count", len(groups["clc"])),
        ("fast_update_mask", sum(groups["update"])),
        ("client_data_mask", sum(groups["client"])),
        ("sound_mask", sum(groups["sound"])),
        ("temporary_entity_count", len(groups["temp"])),
        ("protocol_fingerprint", fingerprint()),
        ("max_msglen", 8000),
        ("max_datagram", 1024),
        ("max_edicts", 600),
        ("net_maxmessage", 8192),
    ]
    return [{"kind": "case", "name": name, "value": value} for name, value in pairs]


def document(root: Path) -> dict[str, object]:
    """Render the canonical evidence document for this verifier."""
    return {
        "schema": SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "block_id": BLOCK_ID,
        "block_parent_package_id": BLOCK_PARENT,
        "protocol_status": STATUS,
        "protocol_version": 15,
        "sources": ["protocol.h", "common.c", "cl_main.c", "cl_parse.c", "cl_demo.c",
                    "sv_main.c", "sv_user.c", "net_dgrm.c"],
        "rows": rows(),
        "reference": {"oracle": ORACLE, "oracle_sha256": sha(root / ORACLE)},
    }


def freeze_document(root: Path) -> dict[str, object]:
    """Build the deterministic freeze document fixture used by this verifier."""
    return {
        "schema": "MiniQuakeProtocol15Freeze/1",
        "block_id": BLOCK_ID,
        "package_id": PACKAGE_ID,
        "protocol_status": STATUS,
        "protocol_version": 15,
        "protocol_fingerprint": fingerprint(),
        "coverage": {
            "valid_svc_commands": 33,
            "valid_clc_commands": 4,
            "temporary_entity_types": 14,
            "component_checkers": len(COMPONENT_CHECKERS),
            "runtime_fixtures_bp015_019": 12 + 14 + 18 + 19 + RUNTIME_FIXTURES,
        },
        "authoritative_files": [
            {"path": relative, "sha256": sha(root / relative)}
            for relative in AUTHORITATIVE_FILES
        ],
    }


def compiler() -> list[str] | None:
    """Locate a supported C compiler for the reference oracle."""
    candidates: list[str] = []
    if os.environ.get("CC"):
        candidates.append(os.environ["CC"])
    candidates += ["cc", "gcc", "clang"]
    for candidate in candidates:
        parts = candidate.split()
        if shutil.which(parts[0]):
            return parts
    return None


def run_oracle(root: Path) -> tuple[bool, str, list[dict[str, object]]]:
    """Run oracle and capture its deterministic result."""
    cc = compiler()
    if not cc:
        return True, "not available", []
    with tempfile.TemporaryDirectory(prefix="mq-bp019-") as directory:
        executable = Path(directory) / ("oracle.exe" if os.name == "nt" else "oracle")
        build = subprocess.run(
            cc + ["-std=c11", "-Wall", "-Wextra", "-Werror", "-O2",
                  str(root / ORACLE), "-o", str(executable)],
            capture_output=True,
            text=True,
        )
        if build.returncode:
            return False, build.stdout + build.stderr, []
        run = subprocess.run([str(executable)], capture_output=True, text=True)
        parsed = [json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        return run.returncode == 0, " ".join(cc), parsed


def run_components(root: Path) -> tuple[list[dict[str, object]], list[str]]:
    """Run components and capture its deterministic result."""
    outcomes: list[dict[str, object]] = []
    errors: list[str] = []
    for package, relative in COMPONENT_CHECKERS:
        path = root / relative
        if not path.is_file():
            errors.append(f"missing component checker: {relative}")
            outcomes.append({"package": package, "checker": relative, "status": "MISSING"})
            continue
        # BP-010R1 and BP-011 predate the shared --root flag and accept
        # the source root as their positional argument.  All later checkers
        # accept both forms.  Keeping this compatibility table makes the
        # cumulative closure checker reusable without rewriting historical
        # component tools.
        if relative in (
            "tools/check_protocol15_vectors.py",
            "tools/check_protocol15_commands.py",
        ):
            command = [os.sys.executable, str(path), str(root)]
        else:
            command = [os.sys.executable, str(path), "--root", str(root)]
        run = subprocess.run(
            command,
            capture_output=True,
            text=True,
        )
        status = "PASS" if run.returncode == 0 else "FAIL"
        outcomes.append({
            "package": package,
            "checker": relative,
            "status": status,
            "exit_code": run.returncode,
            "output_sha256": hashlib.sha256((run.stdout + run.stderr).encode("utf-8")).hexdigest(),
        })
        if run.returncode != 0:
            errors.append(f"component checker failed: {package} {relative}")
    return outcomes, errors


def contract(root: Path) -> list[str]:
    """Evaluate the source and runtime evidence for this contract."""
    errors: list[str] = []
    module = (root / "src/miniquake/protocol15_freeze.ml").read_text(encoding="utf-8-sig")
    tests = (root / "tests/protocol15_closure_tests.ml").read_text(encoding="utf-8-sig")
    build = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    main = (root / "src/main.ml").read_text(encoding="utf-8-sig")

    markers = [
        'const STATUS = "protocol15_frozen_v1"',
        "const SVC_VALID_COUNT = 33",
        "const CLC_VALID_COUNT = 4",
        "const FAST_UPDATE_MASK = 0x7fff",
        "const CLIENT_DATA_MASK = 0x7eff",
        "const TEMP_ENTITY_COUNT = 14",
        "const FINGERPRINT = 0x0cf1e12a",
        "function protocolFingerprint()",
        "function coverageSummary()",
    ]
    for marker in markers:
        if marker not in module:
            errors.append("freeze module is missing: " + marker)
    if "MiniQuake BP-019 Protocol 15 closure tests passed: 15" not in tests:
        errors.append("closure runtime success marker is missing")
    if tests.count("if run(") != RUNTIME_FIXTURES:
        errors.append(f"expected {RUNTIME_FIXTURES} closure runtime fixtures")
    for marker in ("buildClosureMessage", "transferReliable", "datagram-demo-parser closure"):
        if marker not in tests:
            errors.append("cross-layer closure fixture is missing: " + marker)
    # The Protocol 15 closure is intentionally reusable by later packages.
    # Later blocks may change package lineage or shared source hashes while the
    # frozen wire fingerprint and the Protocol-specific fixtures remain fixed.
    if 'const PROTOCOL_STATUS = "protocol15_frozen_v1"' not in build:
        errors.append("current build no longer advertises protocol15_frozen_v1")
    for marker in ("buildInfo.PROTOCOL_STATUS", "buildInfo.BLOCK_ID"):
        if marker not in main:
            errors.append("version output is missing: " + marker)
    return errors


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--root", dest="root_flag")
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--write-freeze", action="store_true")
    parser.add_argument("--skip-components", action="store_true")
    parser.add_argument("--json-output")
    parser.add_argument("--require-c-oracle", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    root = Path(args.root_flag or args.root).resolve()

    if args.self_test:
        expected = 0x0CF1E12A
        ok = fingerprint() == expected and len(values()["svc"]) == 33
        print("MiniQuake BP-019 Protocol 15 closure checker self-test: " + ("PASS" if ok else "FAIL"))
        return 0 if ok else 1

    expected_golden = document(root)
    expected_freeze = freeze_document(root)
    golden_path = root / GOLDEN
    freeze_path = root / FREEZE
    if args.write_golden:
        golden_path.parent.mkdir(parents=True, exist_ok=True)
        golden_path.write_text(json.dumps(expected_golden, indent=2) + "\n", encoding="utf-8")
    if args.write_freeze:
        freeze_path.parent.mkdir(parents=True, exist_ok=True)
        freeze_path.write_text(json.dumps(expected_freeze, indent=2) + "\n", encoding="utf-8")

    errors: list[str] = []
    if not golden_path.is_file():
        errors.append("missing closure golden document")
    elif json.loads(golden_path.read_text(encoding="utf-8-sig")) != expected_golden:
        errors.append("closure golden differs from Python model")
    if not freeze_path.is_file():
        errors.append("missing Protocol 15 freeze document")
    else:
        stored_freeze = json.loads(freeze_path.read_text(encoding="utf-8-sig"))
        if stored_freeze != expected_freeze:
            # Later compatibility blocks may refine a shared source module while
            # preserving the frozen wire contract.  Only explicitly named shared
            # files are allowed to differ, and all Protocol component checkers,
            # Golden vectors and the fixed fingerprint are still rerun below.
            build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
            downstream = f'const PACKAGE_ID = "{PACKAGE_ID}"' not in build_info
            stored_meta = {key: stored_freeze.get(key) for key in (
                "schema", "block_id", "package_id", "protocol_status",
                "protocol_version", "protocol_fingerprint", "coverage",
            )}
            expected_meta = {key: expected_freeze.get(key) for key in stored_meta}
            stored_hashes = {
                item.get("path"): item.get("sha256")
                for item in stored_freeze.get("authoritative_files", [])
                if isinstance(item, dict)
            }
            expected_hashes = {
                item.get("path"): item.get("sha256")
                for item in expected_freeze.get("authoritative_files", [])
                if isinstance(item, dict)
            }
            unexpected = [
                path for path in AUTHORITATIVE_FILES
                if path not in DOWNSTREAM_MUTABLE_FILES
                and stored_hashes.get(path) != expected_hashes.get(path)
            ]
            if not downstream or stored_meta != expected_meta or unexpected:
                errors.append(
                    "Protocol 15 freeze hashes differ from authoritative sources"
                    + (f"; unexpected={unexpected}" if unexpected else "")
                )

    oracle_ok, oracle_detail, actual = run_oracle(root)
    if not oracle_ok:
        errors.append("C oracle failed: " + oracle_detail)
    elif args.require_c_oracle and not actual:
        errors.append("C oracle was required but no C compiler is available")
    elif actual and actual != expected_golden["rows"]:
        errors.append("C oracle differs from Python model")

    components: list[dict[str, object]] = []
    if not args.skip_components:
        components, component_errors = run_components(root)
        errors += component_errors
    errors += contract(root)

    report = {
        "schema": REPORT,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "block_id": BLOCK_ID,
        "protocol_status": STATUS,
        "ok": not errors,
        "oracle": oracle_detail,
        "rows": len(expected_golden["rows"]),
        "runtime_fixtures": RUNTIME_FIXTURES,
        "component_checkers": components,
        "authoritative_files": len(AUTHORITATIVE_FILES),
        "protocol_fingerprint": fingerprint(),
        "errors": errors,
    }
    if args.json_output:
        Path(args.json_output).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("MiniQuake BP-019 Protocol 15 closure verification: " + ("PASS" if not errors else "FAIL"))
    print(f"  rows={len(expected_golden['rows'])} runtime_fixtures={RUNTIME_FIXTURES} "
          f"components={len(components)} fingerprint=0x{fingerprint():08x} oracle={oracle_detail}")
    for error in errors:
        print("  ERROR: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
