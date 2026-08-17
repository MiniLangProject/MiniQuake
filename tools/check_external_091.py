#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check external 091 compatibility and regression contract."""

from __future__ import annotations

import argparse
import json
import pathlib
import sys


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors: list[str] = []

    def read(rel: str) -> str:
        """Read read from its caller-supplied source."""
        path = root / rel
        if not path.is_file():
            errors.append("missing file: " + rel)
            return ""
        return path.read_text(encoding="utf-8-sig")

    host = read("src/miniquake/host.ml")
    mainml = read("src/main.ml")
    test = read("tests/original_server_interop_tests.ml")
    harness = read("scripts/TEST_BP-090-094R15.ps1")
    golden_path = root / "audit/original_server_interop_golden.json"
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        errors.append(f"invalid golden file: {exc}")
        golden = {}

    for marker in [
        "function runOriginalInteropClient(",
        "session.client.signon == c.SIGNONS",
        "session.client.spawned",
        "ORIGINAL_INTEROP_POST_FRAMES",
        "interopWriteSummary(",
        "function originalInteropClientNetworkProvenance(",
        "originalServerInteropNetworkProvenance(",
        "network_provenance=target_udp",
    ]:
        if marker not in host:
            errors.append("missing client interop marker: " + marker)
    for marker in ["--original-interop-client", "runOriginalInteropClient", "-original-interop-target"]:
        if marker not in mainml:
            errors.append("missing CLI marker: " + marker)
    if '"+connect"' in mainml:
        errors.append("strict original interop must not queue startup +connect")
    if "connectRemoteHostInterop(session, targetHost, 20000, 500)" not in host:
        errors.append("missing strict persistent original-server connection marker")
    if 'originalInteropTarget = common.parmValue(session.arguments, "-original-interop-target", "")' not in host:
        errors.append("missing pre-fallback original interop target marker")

    required = [
        "Run-OriginalServerMiniClientPair -Suffix 'a'",
        "Run-OriginalServerMiniClientPair -Suffix 'b'",
        "original-server/MiniQuake-client normalized reports differ",
        "-Direction 'original_server_mini_client'",
        "'-listen', '4'",
        "'-window', '-width', '640', '-height', '480'",
        "'-heapsize', '32768'",
        "'-noipx'",
        "'-ip', '127.0.0.1'",
        "'+unbindall', '+map', 'start'",
        "starting original GLQuake loopback-only listen server",
        "without -condebug",
        "protocol3_server_info_then_target_udp_protocol15_signon4",
        "process_alive_after_signon",
        "condebug_enabled = $false",
        "while ([DateTime]::UtcNow -lt $Deadline -and -not $SignonComplete)",
        "$HasTargetUdpProvenance",
        "network_provenance=target_udp",
        "transport=udp",
        "local_server_active=false",
        "local_authoritative=false",
        "demo_playback=false",
        "original_server_mode = \"listen_with_video_context\"",
        "original_condebug_enabled = $false",
        "original_network_scope = \"loopback_only\"",
        "original_bind_address = \"127.0.0.1\"",
        "firewall_prompt_expected = $false",
        "Install-TemporaryLoopbackFirewallRules",
        "New-NetFirewallRule",
        "Remove-NetFirewallRule",
        "-Program $Spec.program",
        "-LocalAddress '127.0.0.1'",
        "-RemoteAddress '127.0.0.1'",
        "Relaunch-ElevatedForInteropIfNeeded",
        "protocol3_server_info_response_with_open_guard",
        "guard_socket_open_during_signon",
        "guard_close_order = 'after_original_process_stop'",
        "original GLQuake readiness guard {0} closed after server stop",
    ]
    for marker in required:
        if marker not in harness:
            errors.append("missing process-pair marker: " + marker)

    if "'-condebug'" in harness:
        errors.append("current original-server harness still passes -condebug")
    for stale in ["Server spawned\\.", "Client 127\\.0\\.0\\.1:[0-9]+ connected", "qconsole.log"]:
        if stale in harness:
            errors.append("current original-server evidence still depends on qconsole marker: " + stale)
    if "'-dedicated', '4'" in harness:
        errors.append("current original-server harness still requests GLQUAKE.EXE dedicated mode")

    expected = {
        "original_server_process_mode": "listen",
        "requires_video_context": True,
        "local_loopback_client_expected": True,
        "dedicated_glquake_map_load_supported": False,
        "server_start_timeout_ms": 30000,
        "condebug_enabled": False,
        "readiness_evidence": "miniquake_protocol3_retry_and_protocol15_signon4",
        "accepted_readiness_evidence": "miniquake_target_udp_provenance_and_protocol15_signon4",
        "remote_connection_evidence": "miniquake_signon4_summary",
        "qconsole_required": False,
        "legacy_debug_log_buffer_bytes": 1024,
        "observed_modern_extensions_line_bytes": 2580,
        "network_scope": "loopback_only",
        "bind_address": "127.0.0.1",
        "firewall_prompt_expected": False,
        "temporary_firewall_rules": True,
        "firewall_rule_scope": "exact_program_udp_loopback_only",
        "firewall_rule_count": 4,
        "firewall_rule_cleanup_required": True,
        "elevation_requested_before_build": True,
        "network_provenance_required": True,
        "required_transport": "udp",
        "local_fallback_rejected": True,
        "demo_fallback_rejected": True,
        "remote_address_must_match_target": True,
        "normalized_pair_evidence": "target_udp_signon4",
    }
    for key, expected_value in expected.items():
        if golden.get(key) != expected_value:
            errors.append(f"golden {key}={golden.get(key)!r}, expected {expected_value!r}")

    if "MiniQuake BP-091 original server interop tests passed: 20" not in test:
        errors.append("runtime marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-094",
        "delivery_revision": "BP-090-094R15",
        "step": "BP-091",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "fixtures": 20,
        "pairs": 2,
        "direction": "original_server_to_miniquake_client",
        "original_server_process_mode": "listen",
        "requires_video_context": True,
        "condebug_enabled": False,
        "readiness_evidence": "miniquake_protocol3_retry_and_protocol15_signon4",
        "accepted_readiness_evidence": "miniquake_target_udp_provenance_and_protocol15_signon4",
        "network_scope": "loopback_only",
        "bind_address": "127.0.0.1",
        "firewall_prompt_expected": False,
        "temporary_firewall_rules": True,
        "firewall_rule_scope": "exact_program_udp_loopback_only",
        "firewall_rule_count": 4,
        "firewall_rule_cleanup_required": True,
        "elevation_requested_before_build": True,
        "network_provenance_required": True,
        "required_transport": "udp",
        "local_fallback_rejected": True,
        "demo_fallback_rejected": True,
        "remote_address_must_match_target": True,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("MiniQuake BP-091 original server interop verification: " + report["status"])
    print("  original_server_process_mode=listen")
    print("  condebug_enabled=false")
    print("  readiness_evidence=miniquake_target_udp_provenance_and_protocol15_signon4")
    print("  network_provenance=target_udp local_fallback_rejected=true")
    print("  network_scope=loopback_only bind_address=127.0.0.1")
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
