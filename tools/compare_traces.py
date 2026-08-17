#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Compare two MiniQuake compatibility traces and report the first divergence.

The tool uses only the Python standard library.  Exit status is 0 for byte-
identical traces, 1 for a deterministic mismatch, and 2 for invalid input.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True)
class TraceInfo:
    name: str
    bytes: int
    lines: int
    sha256: str


@dataclass(frozen=True)
class FieldDifference:
    field: str
    left: str | None
    right: str | None


@dataclass(frozen=True)
class LineDifference:
    line_index: int
    kind: str
    frame: int | None
    left_prefix: str | None
    right_prefix: str | None
    fields: list[FieldDifference]
    left_line: str | None
    right_line: str | None


def sha256_bytes(data: bytes) -> str:
    """Compute the SHA-256 digest of the supplied bytes."""
    return hashlib.sha256(data).hexdigest()


def trace_info(path: Path, data: bytes, lines: list[str]) -> TraceInfo:
    """Read trace metadata and normalized frame records from one file."""
    return TraceInfo(path.name, len(data), len(lines), sha256_bytes(data))


def parse_fields(line: str) -> tuple[str, dict[str, str]]:
    """Parse fields into its normalized representation."""
    parts = line.split("|")
    fields: dict[str, str] = {}
    for part in parts[1:]:
        if "=" in part:
            key, value = part.split("=", 1)
            fields[key] = value
    return parts[0] if parts else "", fields


def frame_number(prefix: str) -> int | None:
    """Compute the reference frame number value for a deterministic fixture."""
    if not prefix.startswith("frame="):
        return None
    try:
        return int(prefix[6:])
    except ValueError:
        return None


def first_difference(left_lines: list[str], right_lines: list[str]) -> LineDifference | None:
    """Return difference from the normalized evidence."""
    count = max(len(left_lines), len(right_lines))
    for index in range(count):
        left_line = left_lines[index] if index < len(left_lines) else None
        right_line = right_lines[index] if index < len(right_lines) else None
        if left_line == right_line:
            continue
        if left_line is None or right_line is None:
            prefix = left_line if left_line is not None else right_line or ""
            parsed_prefix, _ = parse_fields(prefix)
            return LineDifference(
                index,
                "line_count",
                frame_number(parsed_prefix),
                parse_fields(left_line)[0] if left_line is not None else None,
                parse_fields(right_line)[0] if right_line is not None else None,
                [],
                left_line,
                right_line,
            )
        left_prefix, left_fields = parse_fields(left_line)
        right_prefix, right_fields = parse_fields(right_line)
        differences = [
            FieldDifference(key, left_fields.get(key), right_fields.get(key))
            for key in sorted(set(left_fields) | set(right_fields))
            if left_fields.get(key) != right_fields.get(key)
        ]
        kind = "frame" if left_prefix.startswith("frame=") or right_prefix.startswith("frame=") else "header"
        frame = frame_number(left_prefix)
        if frame is None:
            frame = frame_number(right_prefix)
        return LineDifference(
            index,
            kind,
            frame,
            left_prefix,
            right_prefix,
            differences,
            left_line if not differences else None,
            right_line if not differences else None,
        )
    return None


def comparison(left_path: Path, right_path: Path) -> dict[str, object]:
    """Compare comparison and report the first mismatch."""
    left_data = left_path.read_bytes()
    right_data = right_path.read_bytes()
    # MiniQuake emits UTF-8/ASCII with LF. splitlines() also tolerates a final LF.
    left_lines = left_data.decode("utf-8-sig").splitlines()
    right_lines = right_data.decode("utf-8-sig").splitlines()
    difference = first_difference(left_lines, right_lines)
    return {
        "schema_version": 1,
        "equal": left_data == right_data,
        "left": asdict(trace_info(left_path, left_data, left_lines)),
        "right": asdict(trace_info(right_path, right_data, right_lines)),
        "first_difference": asdict(difference) if difference is not None else None,
    }


def print_human(report: dict[str, object]) -> None:
    """Emit human in the requested report format."""
    left = report["left"]
    right = report["right"]
    assert isinstance(left, dict) and isinstance(right, dict)
    if report["equal"]:
        print(
            "MiniQuake traces are byte-identical: "
            f"sha256={left['sha256']} bytes={left['bytes']} lines={left['lines']}"
        )
        return
    print("MiniQuake traces differ.")
    print(f"  left:  {left['name']} sha256={left['sha256']} bytes={left['bytes']} lines={left['lines']}")
    print(f"  right: {right['name']} sha256={right['sha256']} bytes={right['bytes']} lines={right['lines']}")
    difference = report["first_difference"]
    if not isinstance(difference, dict):
        return
    frame = difference.get("frame")
    frame_text = "" if frame is None else f" frame={frame}"
    print(f"  first difference: line={difference['line_index']} kind={difference['kind']}{frame_text}")
    fields = difference.get("fields")
    if isinstance(fields, list):
        for item in fields:
            if isinstance(item, dict):
                print(f"    {item['field']}: left={item['left']!r} right={item['right']!r}")


def self_test() -> None:
    """Exercise the tool with synthetic fixtures and verify its invariants."""
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        a = root / "a.mqtrace"
        b = root / "b.mqtrace"
        header = "MiniQuakeCompatTrace|schema=1|package=TEST\n"
        a.write_text(header + "frame=0|accepted=1|player_angles=00000000,00000000,00000000|state_hash=aaaa\n", encoding="utf-8", newline="\n")
        b.write_text(header + "frame=0|accepted=1|player_angles=bf800000,00000000,00000000|state_hash=bbbb\n", encoding="utf-8", newline="\n")
        report = comparison(a, b)
        assert report["equal"] is False
        difference = report["first_difference"]
        assert isinstance(difference, dict)
        assert difference["line_index"] == 1
        assert difference["frame"] == 0
        fields = {item["field"] for item in difference["fields"]}
        assert fields == {"player_angles", "state_hash"}
        b.write_bytes(a.read_bytes())
        equal = comparison(a, b)
        assert equal["equal"] is True
        assert equal["first_difference"] is None
    print("MiniQuake trace comparator self-test: PASS")


def main(argv: list[str] | None = None) -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("left", nargs="?", help="first .mqtrace file")
    parser.add_argument("right", nargs="?", help="second .mqtrace file")
    parser.add_argument("--json-output", help="write a machine-readable comparison report")
    parser.add_argument("--quiet", action="store_true", help="suppress human-readable output")
    parser.add_argument("--self-test", action="store_true", help="run built-in parser/comparison fixtures")
    args = parser.parse_args(argv)

    if args.self_test:
        try:
            self_test()
            return 0
        except Exception as exc:  # pragma: no cover - only used as delivery smoke test
            print(f"trace comparator self-test failed: {exc}", file=sys.stderr)
            return 2

    if not args.left or not args.right:
        parser.error("left and right traces are required unless --self-test is used")
    left = Path(args.left)
    right = Path(args.right)
    if not left.is_file() or not right.is_file():
        print("error: both trace paths must exist and be files", file=sys.stderr)
        return 2
    try:
        report = comparison(left, right)
    except (OSError, UnicodeError) as exc:
        print(f"error: cannot compare traces: {exc}", file=sys.stderr)
        return 2

    if args.json_output:
        output = Path(args.json_output)
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n")
    if not args.quiet:
        print_human(report)
    return 0 if report["equal"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
