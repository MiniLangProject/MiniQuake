#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Validate the BP-060..064R6 cross-process evidence wrapper contract."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path


@dataclass
class Report:
    """Collect the machine-readable outcome of one verification run."""
    schema_version: int = 1
    check: str = "bp060064r6_network_evidence_process_contract"
    passed: bool = False
    details: dict[str, object] = field(default_factory=dict)
    errors: list[str] = field(default_factory=list)


def validate_text(text: str) -> Report:
    """Validate text and return its contract findings."""
    errors: list[str] = []
    required = (
        '$DeliveryRevision = "BP-060-064R6"',
        "function Start-BackgroundCapturedProcess",
        "System.Diagnostics.ProcessStartInfo",
        "$StartInfo.UseShellExecute = $false",
        "$StartInfo.RedirectStandardOutput = $true",
        "$StartInfo.RedirectStandardError = $true",
        "$Process.StandardOutput.ReadToEndAsync()",
        "$Process.StandardError.ReadToEndAsync()",
        "$Process.WaitForExit($TimeoutMilliseconds)",
        "$Process.WaitForExit()",
        "$Process.Refresh()",
        "$Code = [int]$Process.ExitCode",
        "INFRA_FAILURE:",
        "server_exit_code = $ServerCode",
        "client_exit_code = $ClientCode",
        "server_pass_marker = [bool]$ServerPassed",
        "client_pass_marker = [bool]$ClientPassed",
        "bp060-064r6-network-pair-{0}.json",
        "MiniQuake BP-060-064R6 acceptance test: PASS",
    )
    for marker in required:
        if marker not in text:
            errors.append(f"missing R6 process-lifecycle marker: {marker}")

    forbidden_patterns = {
        "R6 evidence server still uses Start-Process": r"Start-Process\s+-FilePath\s+\$EvidenceExe",
        "R6 still reads nullable Start-Process server ExitCode": r"\$ServerCode\s*=\s*\$Server\.ExitCode",
        "R6 still emits the blank-server R5 failure path": r"server=\$ServerCode client=\$ClientCode.*\$Server\.ExitCode",
    }
    for label, pattern in forbidden_patterns.items():
        if re.search(pattern, text, flags=re.I | re.S):
            errors.append(label)

    timed = text.find("$Process.WaitForExit($TimeoutMilliseconds)")
    final = text.find("$Process.WaitForExit()", timed + 1)
    refresh = text.find("$Process.Refresh()", final + 1)
    exit_code = text.find("$Code = [int]$Process.ExitCode", refresh + 1)
    if min(timed, final, refresh, exit_code) < 0 or not (timed < final < refresh < exit_code):
        errors.append("process completion sequence must be timed wait -> final wait -> refresh -> typed ExitCode")

    details = {
        "process_api": "System.Diagnostics.Process",
        "redirected_streams": 2,
        "asynchronous_drain": True,
        "completion_sequence": ["WaitForExit(timeout)", "WaitForExit()", "Refresh()", "ExitCode"],
        "pair_json": True,
        "start_process_removed_from_evidence_server": not bool(re.search(r"Start-Process\s+-FilePath\s+\$EvidenceExe", text, re.I)),
    }
    return Report(passed=not errors, details=details, errors=errors)


def self_test() -> int:
    """Exercise the tool with synthetic fixtures and verify its invariants."""
    good = "\n".join((
        '$DeliveryRevision = "BP-060-064R6"',
        "function Start-BackgroundCapturedProcess",
        "System.Diagnostics.ProcessStartInfo",
        "$StartInfo.UseShellExecute = $false",
        "$StartInfo.RedirectStandardOutput = $true",
        "$StartInfo.RedirectStandardError = $true",
        "$Process.StandardOutput.ReadToEndAsync()",
        "$Process.StandardError.ReadToEndAsync()",
        "$Process.WaitForExit($TimeoutMilliseconds)",
        "$Process.WaitForExit()",
        "$Process.Refresh()",
        "$Code = [int]$Process.ExitCode",
        "INFRA_FAILURE:",
        "server_exit_code = $ServerCode",
        "client_exit_code = $ClientCode",
        "server_pass_marker = [bool]$ServerPassed",
        "client_pass_marker = [bool]$ClientPassed",
        "bp060-064r6-network-pair-{0}.json",
        "MiniQuake BP-060-064R6 acceptance test: PASS",
    ))
    bad = good.replace("System.Diagnostics.ProcessStartInfo", "Start-Process -FilePath $EvidenceExe") + "\n$ServerCode = $Server.ExitCode"
    if not validate_text(good).passed or validate_text(bad).passed:
        print("MiniQuake BP-060-064R6 network-evidence wrapper self-test: FAIL")
        return 1
    print("MiniQuake BP-060-064R6 network-evidence wrapper self-test: PASS")
    return 0


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root_pos", nargs="?")
    parser.add_argument("--root", dest="root_opt")
    parser.add_argument("--json-output")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    root = Path(args.root_opt or args.root_pos or ".").resolve()
    path = root / "scripts" / "TEST_BP-060-064R6.ps1"
    try:
        text = path.read_text(encoding="utf-8-sig")
    except OSError as exc:
        report = Report(errors=[f"cannot read {path}: {exc}"])
    else:
        report = validate_text(text)
    if args.json_output:
        output = Path(args.json_output)
        if not output.is_absolute():
            output = root / output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(asdict(report), indent=2) + "\n", encoding="utf-8")
    print(f"MiniQuake BP-060-064R6 network-evidence process verification: {'PASS' if report.passed else 'FAIL'}")
    for error in report.errors:
        print(f"  error: {error}")
    return 0 if report.passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
