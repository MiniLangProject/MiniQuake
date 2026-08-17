#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Lexically validate MiniLang (), [] delimiter balance.

This is intentionally lightweight and runs before the Windows compiler.  It
ignores line comments, nested-looking block comments, string contents and
escaped quotes.  Its purpose is to catch delivery-time truncation/typos such
as ``rectangle[3)`` before a user starts the long OPT harness.
"""
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, asdict
from pathlib import Path

OPEN_TO_CLOSE = {"(": ")", "[": "]"}
CLOSE_TO_OPEN = {v: k for k, v in OPEN_TO_CLOSE.items()}
EXCLUDED_PARTS = {"build", ".git", "__pycache__", ".pytest_cache"}


@dataclass
class Issue:
    path: str
    line: int
    column: int
    message: str


def scan_text(path: Path, text: str, root: Path) -> list[Issue]:
    """Scan MiniLang text for balanced delimiters outside strings and comments."""
    issues: list[Issue] = []
    stack: list[tuple[str, int, int]] = []
    state = "normal"
    block_depth = 0
    line = 1
    column = 1
    i = 0
    rel = path.relative_to(root).as_posix()

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if state == "line_comment":
            if ch == "\n":
                state = "normal"
            # position update below
        elif state == "block_comment":
            if ch == "/" and nxt == "*":
                block_depth += 1
                i += 1
                column += 1
            elif ch == "*" and nxt == "/":
                block_depth -= 1
                i += 1
                column += 1
                if block_depth <= 0:
                    state = "normal"
        elif state == "string":
            if ch == "\\":
                # Skip the escaped code unit.  Newline escapes are source text,
                # not literal newlines, so ordinary position accounting applies.
                if i + 1 < len(text):
                    i += 1
                    column += 1
            elif ch == '"':
                state = "normal"
        else:
            if ch == "/" and nxt == "/":
                state = "line_comment"
                i += 1
                column += 1
            elif ch == "/" and nxt == "*":
                state = "block_comment"
                block_depth = 1
                i += 1
                column += 1
            elif ch == '"':
                state = "string"
            elif ch in OPEN_TO_CLOSE:
                stack.append((ch, line, column))
            elif ch in CLOSE_TO_OPEN:
                if not stack:
                    issues.append(Issue(rel, line, column, f"unexpected closing delimiter {ch!r}"))
                else:
                    opener, open_line, open_col = stack[-1]
                    expected = OPEN_TO_CLOSE[opener]
                    if ch != expected:
                        issues.append(Issue(
                            rel,
                            line,
                            column,
                            f"mismatched delimiter: {opener!r} opened at {open_line}:{open_col}, expected {expected!r}, got {ch!r}",
                        ))
                        # Recover by dropping the opener so one typo does not
                        # generate a cascade of duplicate messages.
                        stack.pop()
                    else:
                        stack.pop()

        if ch == "\n":
            line += 1
            column = 1
        else:
            column += 1
        i += 1

    if state == "string":
        issues.append(Issue(rel, line, column, "unterminated string literal"))
    if state == "block_comment":
        issues.append(Issue(rel, line, column, "unterminated block comment"))
    for opener, open_line, open_col in stack:
        issues.append(Issue(
            rel,
            open_line,
            open_col,
            f"unclosed delimiter {opener!r}; expected {OPEN_TO_CLOSE[opener]!r}",
        ))
    return issues


def source_files(root: Path) -> list[Path]:
    """Return the maintained source files in deterministic order."""
    files: list[Path] = []
    for path in root.rglob("*.ml"):
        rel = path.relative_to(root)
        if any(part in EXCLUDED_PARTS for part in rel.parts):
            continue
        files.append(path)
    return sorted(files, key=lambda p: p.relative_to(root).as_posix().lower())


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    args = parser.parse_args()
    root = Path(args.root).resolve()

    issues: list[Issue] = []
    files = source_files(root)
    for path in files:
        rel = path.relative_to(root).as_posix()
        raw = path.read_bytes()
        if raw.startswith(b"\xef\xbb\xbf"):
            issues.append(Issue(
                rel,
                1,
                1,
                "UTF-8 BOM is not permitted in MiniLang source; the compiler treats U+FEFF as an unknown character",
            ))
            raw = raw[3:]
        elif raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
            issues.append(Issue(rel, 1, 1, "UTF-16 BOM is not permitted; MiniLang source must be UTF-8 without BOM"))
            continue
        try:
            text = raw.decode("utf-8", errors="strict")
        except UnicodeDecodeError as exc:
            issues.append(Issue(rel, 1, 1, f"source is not valid UTF-8: {exc}"))
            continue
        issues.extend(scan_text(path, text, root))

    report = {
        "schema": "MiniQuakeMiniLangDelimiterCheck/2",
        "status": "PASS" if not issues else "FAIL",
        "files_checked": len(files),
        "issues": [asdict(issue) for issue in issues],
    }
    if args.json:
        out = Path(args.json)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print("MiniQuake MiniLang delimiter verification")
    print(f"  files_checked={len(files)}")
    for issue in issues:
        print(f"  FAIL {issue.path}:{issue.line}:{issue.column}: {issue.message}")
    print(f"MiniQuake MiniLang delimiter verification: {report['status']}")
    return 0 if not issues else 1


if __name__ == "__main__":
    raise SystemExit(main())
