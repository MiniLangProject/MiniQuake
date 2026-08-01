#!/usr/bin/env python3
"""Detect MiniQuake runtime-test failures even when an executable exits with 0.

Several historical MiniLang test entrypoints printed ``FAIL:`` and a failed
summary after a caught error, then reached the end of the program and returned
0.  The acceptance harness must therefore treat the textual result contract as
part of the process status.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

FAILURE_PATTERNS: tuple[re.Pattern[str], ...] = (
    re.compile(r"^\s*FAIL:\s+.*$", re.IGNORECASE | re.MULTILINE),
    re.compile(
        r"^\s*MiniQuake\b.*\btests failed:\s*\d+/\d+\s*$",
        re.IGNORECASE | re.MULTILINE,
    ),
    re.compile(
        r"^\s*BP-\d+.*\btests failed:\s*\d+/\d+\s*$",
        re.IGNORECASE | re.MULTILINE,
    ),
)


def first_failure_marker(text: str) -> str:
    """Return the earliest recognized failure marker or an empty string."""
    matches: list[re.Match[str]] = []
    for pattern in FAILURE_PATTERNS:
        match = pattern.search(text)
        if match is not None:
            matches.append(match)
    if not matches:
        return ""
    earliest = min(matches, key=lambda item: item.start())
    return earliest.group(0).strip()


def self_test() -> None:
    clean = "[1/2] alpha\n[2/2] beta\nMiniQuake tests passed: 2\n"
    assert first_failure_marker(clean) == ""
    assert first_failure_marker("  FAIL: boom\n") == "FAIL: boom"
    assert (
        first_failure_marker("MiniQuake BP-018 Protocol 15 demo tests failed: 18/19\n")
        == "MiniQuake BP-018 Protocol 15 demo tests failed: 18/19"
    )
    assert (
        first_failure_marker("BP-043 sky/water tests failed: 21/22\n")
        == "BP-043 sky/water tests failed: 21/22"
    )
    # The earliest marker is reported, so diagnostics point at the first
    # observable failure rather than a later aggregate summary.
    text = "FAIL: first\nMiniQuake tests failed: 0/1\n"
    assert first_failure_marker(text) == "FAIL: first"


def read_text(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-16", "utf-8", "cp1252"):
        try:
            return data.decode(encoding)
        except UnicodeError:
            continue
    return data.decode("utf-8", errors="replace")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("paths", nargs="*", type=Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--json-output", type=Path)
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)

    if args.self_test:
        self_test()
        if not args.quiet:
            print("MiniQuake runtime-test log checker self-test: PASS")

    results: list[dict[str, object]] = []
    failed = False
    for path in args.paths:
        if not path.is_file():
            marker = f"log file does not exist: {path}"
            results.append({"path": str(path), "ok": False, "failure_marker": marker})
            failed = True
            if not args.quiet:
                print(f"FAIL: {marker}")
            continue
        marker = first_failure_marker(read_text(path))
        ok = marker == ""
        results.append({"path": str(path), "ok": ok, "failure_marker": marker})
        failed = failed or not ok
        if not args.quiet:
            print(f"{path}: {'PASS' if ok else 'FAIL'}")
            if marker:
                print(f"  marker={marker}")

    if args.json_output is not None:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(
            json.dumps(
                {
                    "schema": "MiniQuakeRuntimeTestLogCheck/1",
                    "ok": not failed,
                    "files": results,
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
