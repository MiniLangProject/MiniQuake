#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-031 WinQuake command buffer, alias and cvar contracts.

The strict mode reproduces the historical BP-031 source audit.  Later packages
may use --allow-downstream-package after the accepted fixed-six formatter was
moved to the caller-owned native MSVCRT text bridge.  Runtime and golden
semantics stay unchanged; only the implementation boundary differs.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path

PACKAGE = "BP-031"
PARENT = "BP-030"
GOLDEN = "audit/command_cvar_golden.json"
ORACLE = "tools/oracle/command_cvar_oracle.c"
REPORT_SCHEMA = "MiniQuakeBP031CommandCvarVerification/1"


def sha(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fbits(value: float) -> int:
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack("<I", struct.pack("<f", value))[0]


def rows() -> list[dict[str, object]]:
    """Build the deterministic result rows for this verifier."""
    return [
        {"kind": "case", "name": "stored_value_bits", "value": fbits(0.100000001)},
        {"kind": "case", "name": "setvalue_1_25", "value": "1.250000"},
        {"kind": "case", "name": "setvalue_negative_zero", "value": "-0.000000"},
        {"kind": "case", "name": "command_buffer_size", "value": 8192},
        {"kind": "case", "name": "max_alias_name", "value": 32},
        {"kind": "case", "name": "max_args", "value": 80},
        {"kind": "case", "name": "fixture_count", "value": 20},
    ]


def document(root: Path) -> dict[str, object]:
    """Render the canonical evidence document for this verifier."""
    return {
        "schema": "MiniQuakeCommandCvarGolden/1",
        "package_id": PACKAGE,
        "parent_package_id": PARENT,
        "sources": ["cmd.c", "cvar.c"],
        "rows": rows(),
        "reference": {"oracle": ORACLE, "oracle_sha256": sha(root / ORACLE)},
    }


def compiler() -> list[str] | None:
    """Locate a supported C compiler for the reference oracle."""
    candidates = ([os.environ["CC"]] if os.environ.get("CC") else []) + ["cc", "gcc", "clang"]
    for value in candidates:
        parts = value.split()
        if shutil.which(parts[0]):
            return parts
    return None


def run_oracle(root: Path) -> tuple[bool, str, list[dict[str, object]]]:
    """Run oracle and capture its deterministic result."""
    cc = compiler()
    if not cc:
        return True, "not available", []
    with tempfile.TemporaryDirectory(prefix="mq-bp031-") as temp_dir:
        executable = Path(temp_dir) / ("oracle.exe" if os.name == "nt" else "oracle")
        build = subprocess.run(
            cc + [
                "-std=c11", "-Wall", "-Wextra", "-Werror", "-O2",
                str(root / ORACLE), "-o", str(executable),
            ],
            capture_output=True,
            text=True,
        )
        if build.returncode:
            return False, build.stdout + build.stderr, []
        run = subprocess.run([str(executable)], capture_output=True, text=True)
        actual = [json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        return run.returncode == 0, " ".join(cc), actual


def contract(root: Path, allow_downstream_package: bool = False) -> list[str]:
    """Evaluate the source and runtime evidence for this contract."""
    errors: list[str] = []
    cvar = (root / "src/miniquake/cvar.ml").read_text(encoding="utf-8-sig")
    command = (root / "src/miniquake/cmd.ml").read_text(encoding="utf-8-sig")
    host = (root / "src/miniquake/host.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/command_cvar_lifecycle_tests.ml").read_text(encoding="utf-8-sig")
    native = (root / "src/miniquake/native.ml").read_text(encoding="utf-8-sig")
    text_c = (root / "native/miniquake_text.c").read_text(encoding="utf-8-sig")
    text_def = (root / "native/miniquake_text.def").read_text(encoding="utf-8-sig")

    for marker in (
        "return native.bitsFloat(native.floatBits(common.atof(text)))",
        "function fixedSixValue(value)",
        "function command(registry, arguments)",
    ):
        if marker not in cvar:
            errors.append("missing cvar marker: " + marker)

    if allow_downstream_package:
        downstream_markers = (
            (cvar, "return native.fixedSixText(value)"),
            (native, "extern function f32ToFixed6Raw(bits as u32, output as bytes, capacity as u32)"),
            (native, 'symbol "mqt_f32_to_fixed6"'),
            (native, "function f32ToFixed6(bits)"),
            (native, "function fixedSixText(value)"),
            (text_c, "mqt_f32_to_fixed6"),
            (text_c, 'mq_crt_proc("sprintf")'),
            (text_c, '"%.6f"'),
            (text_def, "mqt_f32_to_fixed6"),
            (test, '"4097.000000"'),
            (test, '"-4097.000000"'),
            (test, 'native.bitsFloat(0x80000000)'),
        )
        for source, marker in downstream_markers:
            if marker not in source:
                errors.append("missing downstream fixed-six marker: " + marker)
        for legacy in (
            "negative = (raw & 0x80000000) != 0",
            "scaled = native.trunc(magnitude * 1000000.0 + 0.5)",
        ):
            if legacy in cvar:
                errors.append("legacy overflow-prone cvar formatter remains: " + legacy)
    else:
        for marker in (
            "negative = (raw & 0x80000000) != 0",
            "rounded = native.bitsFloat(raw)",
            "scaled = native.trunc(magnitude * 1000000.0 + 0.5)",
        ):
            if marker not in cvar:
                errors.append("missing historical cvar fixed-six marker: " + marker)

    for marker in (
        "const MAX_ALIAS_NAME = 32",
        "const MAX_ARGS = 80",
        "const COMMAND_BUFFER_SIZE = 8192",
        "if len(bytes(system.text)) + len(bytes(text)) >= COMMAND_BUFFER_SIZE",
    ):
        if marker not in command:
            errors.append("missing command marker: " + marker)

    if "result = cvar.command(session.cvars, arguments)" not in host:
        errors.append("host does not use shared Cvar_Command adapter")
    if "command/cvar lifecycle tests passed: 20" not in test:
        errors.append("expected 20 BP-031 fixtures")
    return errors


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--root", dest="root_flag")
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--json-output")
    parser.add_argument("--allow-downstream-package", action="store_true")
    args = parser.parse_args()

    root = Path(args.root_flag or args.root).resolve()
    expected = document(root)
    golden = root / GOLDEN
    if args.write_golden:
        golden.parent.mkdir(parents=True, exist_ok=True)
        golden.write_text(json.dumps(expected, indent=2) + "\n", encoding="utf-8")

    errors: list[str] = []
    if not golden.is_file():
        errors.append("missing golden")
    elif json.loads(golden.read_text(encoding="utf-8-sig")) != expected:
        errors.append("golden differs from Python model")

    oracle_ok, oracle_detail, actual = run_oracle(root)
    if not oracle_ok:
        errors.append("C oracle failed: " + oracle_detail)
    elif actual and actual != expected["rows"]:
        errors.append("C oracle differs from Python model")

    errors += contract(root, args.allow_downstream_package)
    formatter = "native_msvcrt_percent_f" if args.allow_downstream_package else "historical_raw_word_formatter"
    report = {
        "schema": REPORT_SCHEMA,
        "package_id": PACKAGE,
        "parent_package_id": PARENT,
        "downstream_package": args.allow_downstream_package,
        "fixed_six_formatter": formatter,
        "ok": not errors,
        "oracle": oracle_detail,
        "rows": len(expected["rows"]),
        "runtime_fixtures": 20,
        "errors": errors,
    }
    if args.json_output:
        Path(args.json_output).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print("MiniQuake BP-031 command/cvar verification: " + ("PASS" if not errors else "FAIL"))
    print(f"  rows={len(expected['rows'])} runtime_fixtures=20 oracle={oracle_detail}")
    print(
        "  downstream_package="
        + str(args.allow_downstream_package).lower()
        + " fixed_six_formatter="
        + formatter
    )
    for error in errors:
        print("  ERROR: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
