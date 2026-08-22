#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Audit source/test headers and MiniLang function documentation.

The checker deliberately does not prescribe one licence for every file.  A
large part of MiniQuake is a source-guided Quake port and must retain its GPL
provenance; project-original support code may use Apache-2.0.  Every checked
file must therefore state exactly one SPDX licence identifier and the current
MiniQuake copyright holder, while derived files must also retain id Software's
copyright notice.
"""

from __future__ import annotations

import argparse
import ast
from dataclasses import dataclass
from pathlib import Path
import re


COPYRIGHT = "Copyright (c) 2026 Nils Kopal"
SPDX_RE = re.compile(r"SPDX-License-Identifier:\s*([^\s*]+)")
ML_FUNCTION_RE = re.compile(
    r"(?m)^(?:static\s+)?function(?:\s+inline)?\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\("
)
ML_STRUCT_RE = re.compile(
    r"(?m)^struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*$"
)
DERIVED_MARKERS = (
    "Copyright (C) 1996-1997 Id Software, Inc.",
    "Copyright (c) 1996-1997 Id Software, Inc.",
)
DERIVED_HINT_RE = re.compile(
    r"(?i)\b(?:winquake|glquake|quake 1\.09|id software|source-guided|"
    r"mini(?:lang|quake) (?:port|pendant|counterpart))\b"
)
ALLOWED_LICENSES = {"GPL-2.0-or-later", "Apache-2.0"}
C_FUNCTION_RE = re.compile(
    r"(?m)^(?:static\s+)?(?:MQ_EXPORT\s+)?"
    r"[A-Za-z_][A-Za-z0-9_\s*]*?\s+([A-Za-z_][A-Za-z0-9_]*)\s*"
    r"\([^;{}]*\)\s*\{"
)
C_TYPE_RE = re.compile(
    r"(?m)^typedef\s+(struct|enum|union)"
    r"(?:\s+([A-Za-z_][A-Za-z0-9_]*))?\s*\{"
)
SHADER_FUNCTION_RE = re.compile(
    r"(?m)^[ \t]*(?:void|float|vec[234]|mat[234])\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\([^;{}]*\)\s*\{"
)
POWERSHELL_FUNCTION_RE = re.compile(
    r"(?im)^\s*function\s+([A-Za-z_][A-Za-z0-9_-]*)\b"
)
MAINTAINED_POWERSHELL = (
    "build.ps1",
    "scripts/test.ps1",
    "scripts/validate_real_game.ps1",
)


@dataclass(frozen=True)
class Finding:
    """Represent one finding discovered by the source verifier."""
    path: Path
    line: int
    message: str


def source_files(root: Path) -> list[Path]:
    """Return all hand-maintained source and test files in stable order."""
    files = list((root / "src").rglob("*.ml"))
    files.extend((root / "tests").rglob("*.ml"))
    native = root / "native"
    for suffix in ("*.c", "*.h", "*.py", "*.def"):
        files.extend(
            path for path in native.rglob(suffix)
            if not any(
                part == "build" or part.endswith("_build")
                for part in path.relative_to(native).parts
            )
        )
    files.extend((native / "shaders").glob("*.vert"))
    files.extend((native / "shaders").glob("*.frag"))
    files.extend((root / "tools").glob("*.py"))
    files.extend(root / relative for relative in MAINTAINED_POWERSHELL)
    return sorted({path for path in files if path.is_file()})


def header_text(text: str, suffix: str = "") -> str:
    """Return the leading comment region used for licence classification."""
    if suffix in {".py", ".ps1"}:
        lines = text.splitlines(keepends=True)
        header: list[str] = []
        for index, line in enumerate(lines):
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or (index == 0 and stripped.startswith("#!")):
                header.append(line)
                continue
            break
        return "".join(header)
    package = text.find("\npackage ")
    include = text.find("\n#include ")
    candidates = [offset for offset in (package, include) if offset >= 0]
    limit = min(candidates) if candidates else min(len(text), 2048)
    return text[:limit]


def preceding_comment(lines: list[str], index: int, *, hash_comments: bool = False) -> bool:
    """Report whether a declaration has an immediately preceding comment."""
    cursor = index - 1
    while cursor >= 0 and not lines[cursor].strip():
        cursor -= 1
    if cursor < 0:
        return False
    previous = lines[cursor].strip()
    return (
        previous.startswith("//")
        or (hash_comments and previous.startswith("#"))
        or previous.endswith(("*/", "#>"))
    )


def c_type_name(text: str, match: re.Match[str]) -> str:
    """Resolve a tagged or anonymous C aggregate's typedef name."""
    if match.group(2):
        return match.group(2)
    cursor = match.end() - 1
    depth = 0
    while cursor < len(text):
        if text[cursor] == "{":
            depth += 1
        elif text[cursor] == "}":
            depth -= 1
            if depth == 0:
                alias = re.match(r"\s*([A-Za-z_][A-Za-z0-9_]*)", text[cursor + 1 :])
                return alias.group(1) if alias else match.group(1)
        cursor += 1
    return match.group(1)


def complex_function_findings(
    text: str, relative: Path
) -> tuple[list[Finding], int, int]:
    """Return findings and internal-comment coverage for complex ML routines."""
    lines = text.splitlines()
    findings: list[Finding] = []
    complex_count = 0
    documented_count = 0
    index = 0
    while index < len(lines):
        match = re.match(
            r"^(?:static\s+)?function(?:\s+inline)?\s+"
            r"([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            lines[index],
        )
        if match is None:
            index += 1
            continue
        end = index + 1
        while end < len(lines) and lines[end].strip() != "end function":
            end += 1
        body = lines[index + 1 : end]
        logical_lines = sum(bool(line.strip()) for line in body)
        decisions = sum(
            len(
                re.findall(
                    r"\b(?:if|while|for|select|case)\b",
                    re.sub(r'"(?:[^"\\]|\\.)*"', '""', line),
                )
            )
            for line in body
            if not line.strip().startswith(("//", "/*", "*"))
        )
        complex_body = (
            logical_lines >= 100
            or (logical_lines >= 60 and decisions >= 3)
            or (logical_lines >= 35 and decisions >= 12)
        )
        internal_comment = any(
            line.strip().startswith(("//", "/*", "*")) for line in body
        )
        if complex_body:
            complex_count += 1
            documented_count += int(internal_comment)
        if complex_body and not internal_comment:
            findings.append(
                Finding(
                    relative,
                    index + 1,
                    f"complex function {match.group(1)} lacks an internal roadmap comment",
                )
            )
        index = end + 1
    return findings, complex_count, documented_count


def audit_file(
    path: Path, root: Path
) -> tuple[list[Finding], int, int, int, int, int, int]:
    """Audit one file and return function, type and roadmap coverage counters."""
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    header = header_text(text, path.suffix.lower())
    findings: list[Finding] = []
    relative = path.relative_to(root)

    licences = SPDX_RE.findall(header)
    if len(licences) != 1:
        findings.append(Finding(relative, 1, "expected exactly one SPDX licence identifier"))
    elif licences[0] not in ALLOWED_LICENSES:
        findings.append(Finding(relative, 1, f"unsupported production licence {licences[0]!r}"))

    if COPYRIGHT not in header:
        findings.append(Finding(relative, 1, f"missing {COPYRIGHT!r}"))

    derived = any(marker in header for marker in DERIVED_MARKERS)
    if path.suffix == ".ml" and "src" in relative.parts and licences != ["GPL-2.0-or-later"]:
        findings.append(Finding(relative, 1, "all MiniLang engine source must remain GPL-2.0-or-later"))
    if path.suffix == ".ml" and "src" in relative.parts and not derived:
        findings.append(Finding(relative, 1, "MiniLang engine source must retain id Software provenance"))
    if path.suffix == ".ml" and "tests" in relative.parts and licences != ["GPL-2.0-or-later"]:
        findings.append(Finding(relative, 1, "the MiniLang parity test suite must remain GPL-2.0-or-later"))
    if derived and licences != ["GPL-2.0-or-later"]:
        findings.append(Finding(relative, 1, "id-derived source must remain GPL-2.0-or-later"))
    if licences == ["Apache-2.0"] and DERIVED_HINT_RE.search(header):
        findings.append(Finding(relative, 1, "source description suggests Quake derivation but declares Apache-2.0"))
    if path.suffix == ".ps1" and licences and licences != ["Apache-2.0"]:
        findings.append(Finding(relative, 1, "maintained PowerShell tooling must use Apache-2.0"))

    documented = 0
    declarations: list[object] = []
    documented_declarations = 0
    complex_count = 0
    complex_documented = 0
    if path.suffix == ".ml":
        functions = list(ML_FUNCTION_RE.finditer(text))
        declarations = list(ML_STRUCT_RE.finditer(text))
        complex_findings, complex_count, complex_documented = complex_function_findings(
            text, relative
        )
        findings.extend(complex_findings)
    elif path.suffix in {".c", ".h"}:
        functions = list(C_FUNCTION_RE.finditer(text))
        declarations = list(C_TYPE_RE.finditer(text))
    elif path.suffix in {".vert", ".frag"}:
        functions = list(SHADER_FUNCTION_RE.finditer(text))
    elif path.suffix == ".ps1":
        functions = list(POWERSHELL_FUNCTION_RE.finditer(text))
    else:
        functions = []
    if functions:
        lines = text.splitlines()
        for match in functions:
            line = text.count("\n", 0, match.start()) + 1
            if preceding_comment(
                lines, line - 1, hash_comments=path.suffix in {".py", ".ps1"}
            ):
                documented += 1
            else:
                findings.append(Finding(relative, line, f"function {match.group(1)} lacks a preceding comment"))
    if path.suffix == ".py":
        try:
            tree = ast.parse(text)
        except SyntaxError as exc:
            findings.append(Finding(relative, exc.lineno or 1, f"invalid Python syntax: {exc.msg}"))
        else:
            python_functions = [
                node for node in ast.walk(tree)
                if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
            ]
            functions = python_functions
            documented = sum(ast.get_docstring(node) is not None for node in python_functions)
            for node in python_functions:
                if ast.get_docstring(node) is None:
                    findings.append(Finding(relative, node.lineno, f"function {node.name} lacks a docstring"))
            python_classes = [node for node in ast.walk(tree) if isinstance(node, ast.ClassDef)]
            declarations = python_classes
            documented_declarations = sum(
                ast.get_docstring(node) is not None for node in python_classes
            )
            for node in python_classes:
                if ast.get_docstring(node) is None:
                    findings.append(
                        Finding(relative, node.lineno, f"class {node.name} lacks a docstring")
                    )
    else:
        lines = text.splitlines()
        for declaration in declarations:
            line = text.count("\n", 0, declaration.start()) + 1
            if preceding_comment(
                lines, line - 1, hash_comments=path.suffix in {".py", ".ps1"}
            ):
                documented_declarations += 1
            else:
                if path.suffix in {".c", ".h"}:
                    name = c_type_name(text, declaration)
                else:
                    name = next(
                        (group for group in declaration.groups()[::-1] if group),
                        "declaration",
                    )
                findings.append(
                    Finding(relative, line, f"type declaration {name} lacks a preceding comment")
                )
    return (
        findings,
        len(functions),
        documented,
        len(declarations),
        documented_declarations,
        complex_count,
        complex_documented,
    )


def main() -> int:
    """Run the audit and print deterministic, CI-friendly coverage output."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--report-all", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()

    findings: list[Finding] = []
    function_count = 0
    documented_count = 0
    declaration_count = 0
    documented_declaration_count = 0
    complex_count = 0
    complex_documented = 0
    files = source_files(root)
    for path in files:
        (
            current,
            current_functions,
            current_documented,
            current_declarations,
            current_documented_declarations,
            current_complex,
            current_complex_documented,
        ) = audit_file(path, root)
        findings.extend(current)
        function_count += current_functions
        documented_count += current_documented
        declaration_count += current_declarations
        documented_declaration_count += current_documented_declarations
        complex_count += current_complex
        complex_documented += current_complex_documented

    print(f"audited source and test files: {len(files)}")
    print(f"source and test functions documented: {documented_count}/{function_count}")
    print(
        "source and test type declarations documented: "
        f"{documented_declaration_count}/{declaration_count}"
    )
    print(
        "complex MiniLang functions with internal comments: "
        f"{complex_documented}/{complex_count}"
    )
    print(f"findings: {len(findings)}")
    if findings:
        shown = findings if args.report_all else findings[:100]
        for finding in shown:
            print(f"{finding.path.as_posix()}:{finding.line}: {finding.message}")
        if len(shown) != len(findings):
            print(f"... {len(findings) - len(shown)} further finding(s); use --report-all")
        return 1
    print("source documentation audit: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
