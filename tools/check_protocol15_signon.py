#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-015 Protocol-15 signon queue and byte contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path

PACKAGE_ID = "BP-015"
PARENT_PACKAGE_ID = "BP-014R1"
GOLDEN = "audit/protocol15_signon_golden.json"
ORACLE = "tools/oracle/protocol15_signon_oracle.c"
SCHEMA = "MiniQuakeProtocol15SignonGolden/1"
REPORT_SCHEMA = "MiniQuakeBP015Protocol15SignonVerification/1"

def sha(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()

def cmd(text: bytes) -> bytes:
    """Encode one client string command with its Protocol 15 opcode and terminator."""
    return bytes((4,)) + text + b"\0"

def expected_vectors() -> list[dict[str, object]]:
    """Build the deterministic expected vectors consumed by this verifier."""
    rows = [
        ("client_stage_1", cmd(b"prespawn")),
        ("client_stage_2_unmasked_high", cmd(b'name "Ranger"\n') + cmd(b"color 31 13\n") + cmd(b"spawn 1 2 3")),
        ("client_stage_3", cmd(b"begin")),
        ("client_stage_4", b""),
        ("server_signon_markers_1_2_3", bytes((25,1,25,2,25,3))),
        ("server_prespawn_append", bytes((20,25,2))),
    ]
    return [{"kind":"vector","name":name,"bytes":data.hex(),"length":len(data)} for name,data in rows]

def expected_document(root: Path) -> dict[str, object]:
    """Build the deterministic expected document fixture used by this verifier."""
    return {
        "schema": SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "protocol_version": 15,
        "sources": ["cl_main.c", "cl_parse.c", "host_cmd.c", "sv_main.c", "protocol.h"],
        "vectors": expected_vectors(),
        "cases": [
            {"name":"client_reply_queued_until_sendcmd","value":1},
            {"name":"server_prespawn_queued_until_reliable_phase","value":1},
            {"name":"server_spawn_clears_embedded_message","value":1},
            {"name":"server_begin_has_no_wire_stage_four","value":1},
            {"name":"first_fast_update_promotes_three_to_four","value":1},
            {"name":"blocked_reliable_retains_signon_queue","value":1},
        ],
        "reference": {"oracle": ORACLE, "oracle_sha256": sha(root / ORACLE)},
    }

def parse_oracle(text: str) -> list[dict[str, object]]:
    """Parse oracle into its normalized representation."""
    return [json.loads(line) for line in text.splitlines() if line.strip()]

def compiler() -> str | None:
    """Locate a supported C compiler for the reference oracle."""
    for value in (os.environ.get("CC", ""), "cc", "gcc", "clang"):
        if not value: continue
        found = shutil.which(value.split()[0])
        if found: return found
    return None

def run_oracle(root: Path) -> tuple[bool, str, list[dict[str, object]]]:
    """Run oracle and capture its deterministic result."""
    cc = compiler()
    if not cc: return True, "not available", []
    with tempfile.TemporaryDirectory(prefix="mq-bp015-") as td:
        exe = Path(td) / ("oracle.exe" if os.name == "nt" else "oracle")
        command = [cc, "-std=c11", "-Wall", "-Wextra", "-Werror", "-O2", str(root / ORACLE), "-o", str(exe)]
        built = subprocess.run(command, text=True, capture_output=True)
        if built.returncode: return False, built.stdout + built.stderr, []
        ran = subprocess.run([str(exe)], text=True, capture_output=True)
        if ran.returncode: return False, ran.stdout + ran.stderr, []
        return True, cc, parse_oracle(ran.stdout)

def source_contract(root: Path) -> list[str]:
    """Build the deterministic source contract fixture used by this verifier."""
    errors: list[str] = []
    signon = (root / "src/miniquake/protocol_signon.ml").read_text(encoding="utf-8")
    client = (root / "src/miniquake/client.ml").read_text(encoding="utf-8")
    server = (root / "src/miniquake/server.ml").read_text(encoding="utf-8")
    tests = (root / "tests/protocol15_signon_e2e_tests.ml").read_text(encoding="utf-8")
    required = {
        "unmasked high color argument": "(colorValue >> 4)",
        "queued prespawn": "client.sendSignon = true",
        "spawn embedded message": "buffer = client.message",
        "success marker": "MiniQuake BP-015 Protocol 15 signon tests passed: 12",
    }
    texts = [signon, server, server, tests]
    for (name, marker), text in zip(required.items(), texts):
        if marker not in text: errors.append(f"missing {name}: {marker}")
    reply_start = client.find("function CL_SignonReply(client)")
    reply_end = client.find("function applyEvent(client, item)", reply_start)
    reply = client[reply_start:reply_end] if reply_start >= 0 and reply_end > reply_start else ""
    if "protocolSignon.writeClientReply(" not in reply or "return true" not in reply:
        errors.append("CL_SignonReply no longer queues the client reply")
    if 'entity.baseline = [0, 0, 0, 0, baselineOrigin, baselineAngles, 0]' not in tests:
        errors.append("BP-015 fast-update fixture must use the canonical ClientEntityState baseline array")
    if 'serverBaseline = t.EntityBaseline(' not in tests or 'update.writeFastUpdate(packet, 1, serverBaseline,' not in tests:
        errors.append("BP-015 fast-update fixture must keep the server baseline struct separate from the client baseline array")
    if "return sendReliable(client) >= 0" in client: errors.append("CL_SignonReply still sends from parser")
    if "return sendBuffer(client, buffer)" in server[server.find("function writeSignonStage2"):server.find("function placeClient")]:
        errors.append("Host_PreSpawn_f still performs immediate transport")
    return errors

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--root", dest="root_flag")
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--json-output")
    args = parser.parse_args()
    root = Path(args.root_flag or args.root).resolve()
    document = expected_document(root)
    golden_path = root / GOLDEN
    if args.write_golden:
        golden_path.parent.mkdir(parents=True, exist_ok=True)
        golden_path.write_text(json.dumps(document, indent=2) + "\n", encoding="utf-8")
    errors: list[str] = []
    if not golden_path.is_file(): errors.append(f"missing {GOLDEN}")
    else:
        actual = json.loads(golden_path.read_text(encoding="utf-8-sig"))
        if actual != document: errors.append("golden document differs from independent Python model")
    ok, oracle_detail, oracle_rows = run_oracle(root)
    if not ok: errors.append("C oracle failed: " + oracle_detail)
    elif oracle_rows and oracle_rows != document["vectors"]: errors.append("C oracle differs from Python vectors")
    errors.extend(source_contract(root))
    report = {
        "schema": REPORT_SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "ok": not errors,
        "vectors": len(document["vectors"]),
        "cases": len(document["cases"]),
        "oracle": oracle_detail,
        "errors": errors,
    }
    if args.json_output:
        Path(args.json_output).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"MiniQuake BP-015 Protocol 15 signon verification: {'PASS' if not errors else 'FAIL'}")
    print(f"  vectors={report['vectors']} cases={report['cases']} oracle={oracle_detail}")
    for error in errors: print("  ERROR: " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    raise SystemExit(main())
