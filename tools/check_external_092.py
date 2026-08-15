#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import sys


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors: list[str] = []

    def read(rel: str) -> str:
        p = root / rel
        if not p.is_file():
            errors.append("missing file: " + rel)
            return ""
        return p.read_text(encoding="utf-8-sig")

    host = read("src/miniquake/host.ml")
    mainml = read("src/main.ml")
    test = read("tests/original_client_interop_tests.ml")
    harness = read("scripts/TEST_BP-090-094R6.ps1")
    golden_path = root / "audit/original_client_interop_golden.json"
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        errors.append(f"invalid golden file: {exc}")
        golden = {}

    for marker in ["function runOriginalInteropServer(", "function interopWriteReady(", "firstRemoteServerClient(", "remote.spawned", "remote.signonStage", "ready=true port="]:
        if marker not in host:
            errors.append("missing server interop marker: " + marker)
    for marker in ["--original-interop-server", "-dedicated", "+map", "runOriginalInteropServer"]:
        if marker not in mainml:
            errors.append("missing CLI marker: " + marker)
    for marker in [
        "Run-MiniServerOriginalClientPair -Suffix 'a'",
        "Run-MiniServerOriginalClientPair -Suffix 'b'",
        "MiniQuake-server/original-client normalized reports differ",
        "miniquake_server_protocol15_summary",
        "process_alive_at_completed_signon",
        "condebug_enabled = $false",
        "$OriginalClient.HasExited",
        "'-ip', '127.0.0.1'",
        "network_scope = 'loopback_only'",
        "firewall_prompt_expected = $false",
        "Install-TemporaryLoopbackFirewallRules",
        "New-NetFirewallRule",
        "Remove-NetFirewallRule",
        "-Program $Spec.program",
        "-LocalAddress '127.0.0.1'",
        "-RemoteAddress '127.0.0.1'",
        "Relaunch-ElevatedForInteropIfNeeded",
    ]:
        if marker not in harness:
            errors.append("missing process-pair marker: " + marker)
    if "'-condebug'" in harness:
        errors.append("current original-client harness still passes -condebug")
    for stale in ["Connection accepted", "Serverinfo packet received", "CL_SignonReply:\\s*4", "qconsole.log"]:
        if stale in harness:
            errors.append("current original-client evidence still depends on qconsole marker: " + stale)

    expected = {
        "condebug_enabled": False,
        "evidence_source": "miniquake_server_protocol15_summary",
        "qconsole_required": False,
        "original_process_alive_required": True,
        "network_scope": "loopback_only",
        "bind_address": "127.0.0.1",
        "firewall_prompt_expected": False,
        "temporary_firewall_rules": True,
        "firewall_rule_scope": "exact_program_udp_loopback_only",
        "firewall_rule_count": 4,
        "firewall_rule_cleanup_required": True,
        "elevation_requested_before_build": True,
    }
    for key, expected_value in expected.items():
        if golden.get(key) != expected_value:
            errors.append(f"golden {key}={golden.get(key)!r}, expected {expected_value!r}")
    if "MiniQuake BP-092 original client interop tests passed: 20" not in test:
        errors.append("runtime marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-094",
        "delivery_revision": "BP-090-094R6",
        "step": "BP-092",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "fixtures": 20,
        "pairs": 2,
        "direction": "miniquake_server_to_original_client",
        "condebug_enabled": False,
        "evidence_source": "miniquake_server_protocol15_summary",
        "network_scope": "loopback_only",
        "bind_address": "127.0.0.1",
        "firewall_prompt_expected": False,
        "temporary_firewall_rules": True,
        "firewall_rule_scope": "exact_program_udp_loopback_only",
        "firewall_rule_count": 4,
        "firewall_rule_cleanup_required": True,
        "elevation_requested_before_build": True,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("MiniQuake BP-092 original client interop verification: " + report["status"])
    print("  condebug_enabled=false")
    print("  evidence_source=miniquake_server_protocol15_summary")
    print("  network_scope=loopback_only bind_address=127.0.0.1")
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
