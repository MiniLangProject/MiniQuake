#!/usr/bin/env python3
"""Conservative structural checks for MiniQuake's MiniLang source tree.

This is not a replacement for mlc_win64.exe.  It catches the mistakes that are
most expensive in a large mechanical port: package/path mismatches, unresolved
local imports, compile-unit-wide import-alias conflicts, duplicate top-level
declarations, undefined package-qualified symbols, entry-point/package
function-name shadowing, unterminated
strings/comments/brackets, missing `then`, and unbalanced block terminators.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys


# Keep this set in sync with MiniLangCompilerPy/mlc/minilang_parser.py.  These
# tokens are not valid identifiers, including after `import ... as`.
MINILANG_KEYWORDS = {
    "print", "if", "then", "else", "end", "while", "loop", "true",
    "false", "and", "or", "not", "function", "return", "global",
    "const", "for", "to", "each", "in", "break", "continue", "switch",
    "case", "default", "struct", "enum", "are", "namespace", "import",
    "as", "package", "extern", "from", "returns", "symbol", "out",
    "static", "inline", "void", "is",
}


@dataclass
class Diagnostic:
    path: Path
    line: int
    message: str

    def __str__(self) -> str:
        return f"{self.path}:{self.line}: {self.message}"


def strip_comments(text: str) -> tuple[str, list[Diagnostic]]:
    out: list[str] = []
    errors: list[Diagnostic] = []
    i = 0
    line = 1
    in_string = False
    in_block = False
    escaped = False
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""
        if ch == "\n":
            line += 1
        if in_block:
            if ch == "*" and nxt == "/":
                out.extend("  ")
                i += 2
                in_block = False
            else:
                out.append("\n" if ch == "\n" else " ")
                i += 1
            continue
        if in_string:
            out.append(ch)
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
            i += 1
            continue
        if ch == "/" and nxt == "*":
            out.extend("  ")
            i += 2
            in_block = True
            continue
        if ch == "/" and nxt == "/":
            while i < len(text) and text[i] != "\n":
                out.append(" ")
                i += 1
            continue
        if ch == '"':
            in_string = True
        out.append(ch)
        i += 1
    if in_string:
        errors.append(Diagnostic(Path("<memory>"), line, "unterminated string"))
    if in_block:
        errors.append(Diagnostic(Path("<memory>"), line, "unterminated block comment"))
    return "".join(out), errors


def mask_strings(line: str) -> str:
    output: list[str] = []
    in_string = False
    escaped = False
    for ch in line:
        if in_string:
            output.append(" ")
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
        else:
            if ch == '"':
                in_string = True
                output.append(" ")
            else:
                output.append(ch)
    return "".join(output)


def lint_file(path: Path, source_root: Path) -> list[Diagnostic]:
    text = path.read_text(encoding="utf-8")
    clean, preliminary = strip_comments(text)
    diagnostics = [Diagnostic(path, d.line, d.message) for d in preliminary]
    lines = clean.splitlines()

    # Bracket balance outside strings.
    stack: list[tuple[str, int]] = []
    matching = {")": "(", "]": "["}
    for number, raw in enumerate(lines, 1):
        line = mask_strings(raw)
        for ch in line:
            if ch in "([":
                stack.append((ch, number))
            elif ch in ")]":
                if not stack or stack[-1][0] != matching[ch]:
                    diagnostics.append(Diagnostic(path, number, f"unmatched {ch}"))
                else:
                    stack.pop()
    for ch, number in stack:
        diagnostics.append(Diagnostic(path, number, f"unclosed {ch}"))

    meaningful = [(n, raw.strip()) for n, raw in enumerate(lines, 1) if raw.strip()]
    package = None
    if meaningful and meaningful[0][1].startswith("package "):
        package = meaningful[0][1][len("package "):].strip()
        relative = path.relative_to(source_root).with_suffix("")
        expected = ".".join(relative.parts)
        if package != expected:
            diagnostics.append(Diagnostic(path, meaningful[0][0], f"package {package!r} does not match {expected!r}"))
    elif path != source_root / "main.ml" and source_root in path.parents:
        diagnostics.append(Diagnostic(path, meaningful[0][0] if meaningful else 1, "module has no leading package declaration"))

    # Imports that belong to the project must resolve under the source root.
    for number, raw in meaningful:
        match = re.match(
            r'import\s+([A-Za-z_][A-Za-z0-9_.]*)(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?\s*$',
            raw,
        )
        if match:
            module = match.group(1)
            alias = match.group(2)
            if alias in MINILANG_KEYWORDS:
                diagnostics.append(Diagnostic(path, number, f"import alias {alias!r} is a reserved MiniLang keyword"))
            if module.startswith("miniquake."):
                target = source_root.joinpath(*module.split(".")).with_suffix(".ml")
                if not target.exists():
                    diagnostics.append(Diagnostic(path, number, f"unresolved import {module} ({target})"))

    # Block balance. All project functions use one definition header per line.
    block_stack: list[tuple[str, int]] = []
    open_patterns = [
        ("function", re.compile(r"^function\b")),
        ("struct", re.compile(r"^(?:extern\s+)?struct\b")),
        ("enum", re.compile(r"^enum\b")),
        ("namespace", re.compile(r"^namespace\b")),
        ("switch", re.compile(r"^switch\b")),
        ("case", re.compile(r"^case\b")),
        ("while", re.compile(r"^while\b")),
        ("loop", re.compile(r"^loop\b")),
        ("for", re.compile(r"^for(?:\s+each)?\b")),
        ("if", re.compile(r"^if\b")),
    ]
    close_re = re.compile(r"\bend\s+(function|struct|enum|namespace|switch|case|while|loop|for|if)\b")
    for number, raw in meaningful:
        masked = mask_strings(raw)
        stripped = masked.strip()
        if stripped.startswith("extern function "):
            continue

        # Missing then on if/else-if headers, including inline blocks.
        if (re.match(r"^if\b", stripped) or re.match(r"^else\s+if\b", stripped)) and not re.search(r"\bthen\b", stripped):
            diagnostics.append(Diagnostic(path, number, "if/else-if is missing then"))

        closes = close_re.findall(stripped)
        # A same-line opener/closer is a valid inline block and does not touch the stack.
        same_line_types = set(closes)
        for close_type in closes:
            # An inline opener may precede the close on the same line.
            inline_open = False
            if close_type == "if" and re.match(r"^(?:else\s+)?if\b", stripped):
                inline_open = True
            elif close_type == "function" and re.match(r"^function\b", stripped):
                inline_open = True
            if inline_open:
                continue
            if not block_stack:
                diagnostics.append(Diagnostic(path, number, f"end {close_type} without opener"))
            else:
                opened, opened_line = block_stack.pop()
                if opened != close_type:
                    diagnostics.append(Diagnostic(path, number, f"end {close_type} closes {opened} opened at line {opened_line}"))

        # else-if continues the current if; `while` in a loop...while trailer is
        # not used in the current source tree.
        if stripped.startswith("else if") or stripped.startswith("end "):
            continue
        for block_type, pattern in open_patterns:
            if pattern.match(stripped):
                if block_type in same_line_types:
                    break
                block_stack.append((block_type, number))
                break

    for block_type, number in block_stack:
        diagnostics.append(Diagnostic(path, number, f"unclosed {block_type} block"))

    # A few high-value lexical hazards from the documented tokenizer.
    string_token = re.compile(r'"(?:[^"\\]|\\.)*"')
    for number, raw in meaningful:
        strings = list(string_token.finditer(raw))
        for previous, current in zip(strings, strings[1:]):
            if raw[previous.end():current.start()].strip() == "":
                diagnostics.append(
                    Diagnostic(
                        path,
                        number,
                        'adjacent string literals are invalid; escape embedded quotes as \\"',
                    )
                )
                break
        masked = mask_strings(raw)
        if re.search(r"[A-Za-z0-9_\]\)]-[0-9]", masked):
            diagnostics.append(Diagnostic(path, number, "write spaces around subtraction; MiniLang may tokenize -number as a literal"))

    return diagnostics



@dataclass
class ImportInfo:
    module: str
    alias: str
    line: int


def imports_for_file(path: Path) -> list[ImportInfo]:
    text = path.read_text(encoding="utf-8")
    clean, _ = strip_comments(text)
    masked = mask_all_strings(clean)
    result: list[ImportInfo] = []
    for match in re.finditer(
        r"(?m)^import\s+([A-Za-z_][A-Za-z0-9_.]*)(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?\s*$",
        masked,
    ):
        module = match.group(1)
        alias = match.group(2) or module.rsplit(".", 1)[-1]
        line = masked.count("\n", 0, match.start()) + 1
        result.append(ImportInfo(module, alias, line))
    return result


def lint_compile_unit_aliases(files: list[Path], source_root: Path) -> list[Diagnostic]:
    """Mirror the self-hosted compiler's compile-unit-wide alias table.

    Imports are flattened before native code generation.  Therefore an alias
    used in two transitively imported modules must refer to the same package
    throughout one entrypoint's complete import closure.
    """
    diagnostics: list[Diagnostic] = []
    import_cache = {path: imports_for_file(path) for path in files}

    package_to_path: dict[str, Path] = {}
    path_to_package: dict[Path, str] = {}
    for path in sorted(source_root.rglob("*.ml")):
        if path == source_root / "main.ml":
            continue
        text = path.read_text(encoding="utf-8")
        clean, _ = strip_comments(text)
        match = re.search(r"(?m)^package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$", clean)
        if match:
            package = match.group(1)
            package_to_path[package] = path
            path_to_package[path] = package

    function_declarations: dict[Path, dict[str, tuple[int, int]]] = {}
    for path in files:
        text = path.read_text(encoding="utf-8")
        clean, _ = strip_comments(text)
        masked = mask_all_strings(clean)
        declarations: dict[str, tuple[int, int]] = {}
        for match in re.finditer(
            r"(?m)^(?:extern\s+)?function(?:\s+inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            masked,
        ):
            opening = masked.find("(", match.start(), match.end())
            parsed = parenthesized_arity(masked, opening)
            if parsed is None:
                continue
            line = masked.count("\n", 0, match.start()) + 1
            declarations[match.group(1)] = (parsed[0], line)
        function_declarations[path] = declarations

    # Duplicate imports and duplicate top-level function declarations are
    # local file errors, independent of which entrypoint reaches the file.
    for path in files:
        seen_imports: dict[tuple[str, str], int] = {}
        for item in import_cache[path]:
            key = (item.module, item.alias)
            if key in seen_imports:
                diagnostics.append(
                    Diagnostic(
                        path,
                        item.line,
                        f"duplicate import {item.module} as {item.alias!r} "
                        f"(first at line {seen_imports[key]})",
                    )
                )
            else:
                seen_imports[key] = item.line

        text = path.read_text(encoding="utf-8")
        clean, _ = strip_comments(text)
        masked = mask_all_strings(clean)
        declarations: dict[str, int] = {}
        for match in re.finditer(
            r"(?m)^(?:extern\s+)?function(?:\s+inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            masked,
        ):
            name = match.group(1)
            line = masked.count("\n", 0, match.start()) + 1
            previous = declarations.get(name)
            if previous is not None:
                diagnostics.append(
                    Diagnostic(path, line, f"duplicate top-level function {name} (first at line {previous})")
                )
            else:
                declarations[name] = line

    entries = [source_root / "main.ml"] + sorted(path for path in files if (source_root not in path.parents and path != source_root / "main.ml"))
    emitted: set[tuple[Path, int, str]] = set()
    for entry in entries:
        aliases: dict[str, tuple[str, Path, int]] = {}
        pending = [entry]
        visited: set[Path] = set()
        while pending:
            path = pending.pop()
            if path in visited:
                continue
            visited.add(path)
            for item in import_cache.get(path, []):
                previous = aliases.get(item.alias)
                if previous is not None and previous[0] != item.module:
                    first_module, first_path, first_line = previous
                    message = (
                        f"compile unit {entry.name}: import alias {item.alias!r} refers to both "
                        f"{first_module} ({first_path.relative_to(entry.parents[1] if entry.parent.name == 'tests' else source_root.parent)}:{first_line}) "
                        f"and {item.module}"
                    )
                    key = (path, item.line, message)
                    if key not in emitted:
                        diagnostics.append(Diagnostic(path, item.line, message))
                        emitted.add(key)
                else:
                    aliases[item.alias] = (item.module, path, item.line)

                target = package_to_path.get(item.module)
                if target is not None and target not in visited:
                    pending.append(target)

        # The self-hosted compiler currently flattens the complete import
        # closure before its arity pass.  An entry-file helper whose simple
        # name is also used by an imported package can therefore capture an
        # unqualified call from that package.  This produced the real-world
        # validateRuntime(options, messages) -> validateRuntime(arguments)
        # mismatch.  Keep entry helper names unique until the compiler's
        # resolver guarantees package-local preference in this pass.
        entry_declarations = function_declarations.get(entry, {})
        for imported_path in sorted(visited - {entry}):
            imported_package = path_to_package.get(imported_path)
            if imported_package is None:
                continue
            for name, (imported_arity, imported_line) in function_declarations.get(imported_path, {}).items():
                entry_declaration = entry_declarations.get(name)
                if entry_declaration is None:
                    continue
                entry_arity, entry_line = entry_declaration
                message = (
                    f"compile unit {entry.name}: entry function {name}/{entry_arity} shadows "
                    f"imported {imported_package}.{name}/{imported_arity}; use a unique entry-helper name"
                )
                key = (entry, entry_line, message)
                if key not in emitted:
                    diagnostics.append(Diagnostic(entry, entry_line, message))
                    emitted.add(key)

    return diagnostics


@dataclass
class ModuleInfo:
    path: Path
    package: str
    imports: dict[str, str]
    functions: dict[str, int]
    structs: dict[str, int]
    exports: set[str]


def mask_all_strings(text: str) -> str:
    output: list[str] = []
    in_string = False
    escaped = False
    for ch in text:
        if in_string:
            output.append("\n" if ch == "\n" else " ")
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
        else:
            if ch == '"':
                in_string = True
                # Preserve one non-whitespace marker so a string literal still
                # counts as an argument while its commas/brackets stay masked.
                output.append("s")
            else:
                output.append(ch)
    return "".join(output)


def parenthesized_arity(masked: str, opening: int) -> tuple[int, int] | None:
    """Return (argument_count, closing_offset) for a call/header."""
    if opening >= len(masked) or masked[opening] != "(":
        return None
    depth = 1
    bracket_depth = 0
    count = 0
    has_argument = False
    index = opening + 1
    while index < len(masked):
        ch = masked[index]
        if ch == "(":
            depth += 1
            has_argument = True
        elif ch == ")":
            depth -= 1
            if depth == 0:
                if has_argument:
                    count += 1
                return count, index
        elif ch == "[":
            bracket_depth += 1
            has_argument = True
        elif ch == "]":
            bracket_depth -= 1
        elif ch == "," and depth == 1 and bracket_depth == 0:
            if has_argument:
                count += 1
            has_argument = False
        elif not ch.isspace():
            has_argument = True
        index += 1
    return None


def build_module_index(files: list[Path], source_root: Path) -> tuple[dict[str, ModuleInfo], list[Diagnostic]]:
    modules: dict[str, ModuleInfo] = {}
    diagnostics: list[Diagnostic] = []
    for path in files:
        if source_root not in path.parents and path != source_root / "main.ml":
            continue
        text = path.read_text(encoding="utf-8")
        clean, _ = strip_comments(text)
        masked = mask_all_strings(clean)
        package_match = re.search(r"(?m)^package\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$", masked)
        package = package_match.group(1) if package_match else ""
        if path == source_root / "main.ml":
            package = "<entry>"

        imports: dict[str, str] = {}
        for match in re.finditer(
            r"(?m)^import\s+([A-Za-z_][A-Za-z0-9_.]*)(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?\s*$",
            masked,
        ):
            module = match.group(1)
            alias = match.group(2) or module.rsplit(".", 1)[-1]
            previous = imports.get(alias)
            if previous is not None and previous != module:
                line = masked.count("\n", 0, match.start()) + 1
                diagnostics.append(Diagnostic(path, line, f"import alias {alias!r} names both {previous} and {module}"))
            imports[alias] = module

        functions: dict[str, int] = {}
        header_re = re.compile(
            r"(?m)^(?:extern\s+)?function(?:\s+inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\s*\("
        )
        for match in header_re.finditer(masked):
            name = match.group(1)
            opening = masked.find("(", match.start(), match.end())
            parsed = parenthesized_arity(masked, opening)
            if parsed is None:
                continue
            arity, _ = parsed
            if name in functions:
                line = masked.count("\n", 0, match.start()) + 1
                diagnostics.append(Diagnostic(path, line, f"duplicate top-level function {name}"))
            functions[name] = arity

        structs: dict[str, int] = {}
        lines = masked.splitlines()
        index = 0
        while index < len(lines):
            match = re.match(r"^(?:extern\s+)?struct\s+([A-Za-z_][A-Za-z0-9_]*)\s*$", lines[index])
            if not match:
                index += 1
                continue
            name = match.group(1)
            fields = 0
            index += 1
            nested_depth = 0
            while index < len(lines):
                stripped = lines[index].strip()
                if re.match(r"^(?:static\s+)?function\b", stripped):
                    nested_depth += 1
                if stripped == "end function" and nested_depth > 0:
                    nested_depth -= 1
                elif stripped == "end struct" and nested_depth == 0:
                    break
                elif nested_depth == 0 and re.match(r"^[A-Za-z_][A-Za-z0-9_]*(?:\s+as\s+[A-Za-z_][A-Za-z0-9_]*)?$", stripped):
                    fields += 1
                index += 1
            if name in structs:
                diagnostics.append(Diagnostic(path, index + 1, f"duplicate top-level struct {name}"))
            structs[name] = fields
            index += 1

        const_names: dict[str, int] = {}
        for const_match in re.finditer(r"(?m)^const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", masked):
            const_name = const_match.group(1)
            const_line = masked.count("\n", 0, const_match.start()) + 1
            if const_name in const_names:
                diagnostics.append(
                    Diagnostic(path, const_line, f"duplicate top-level const {const_name} (first at line {const_names[const_name]})")
                )
            else:
                const_names[const_name] = const_line

        enum_names = {
            match.group(1)
            for match in re.finditer(r"(?m)^enum\s+([A-Za-z_][A-Za-z0-9_]*)\b", masked)
        }
        namespace_names = {
            match.group(1)
            for match in re.finditer(r"(?m)^namespace\s+([A-Za-z_][A-Za-z0-9_]*)\b", masked)
        }
        # Project source consistently indents function bodies.  A column-zero
        # assignment is therefore a package global/module initializer.
        global_names = {
            match.group(1)
            for match in re.finditer(r"(?m)^([A-Za-z_][A-Za-z0-9_]*)\s*=", masked)
        }
        exports = set(functions) | set(structs) | set(const_names) | enum_names | namespace_names | global_names

        if package in modules:
            diagnostics.append(Diagnostic(path, 1, f"duplicate package declaration {package}"))
        modules[package] = ModuleInfo(path, package, imports, functions, structs, exports)
    return modules, diagnostics


def lint_qualified_import_members(files: list[Path], source_root: Path) -> list[Diagnostic]:
    """Validate every ``alias.symbol`` rooted at a project import.

    The compiler resolves package aliases at compile time.  If the requested
    member is absent, some backend paths report the alias itself as an
    undefined variable (for example ``c.MAX_DLIGHTS`` -> ``Undefined variable
    'c'``).  Checking functions alone therefore misses constants and package
    globals; this pass covers all exported declaration kinds.
    """
    modules, diagnostics = build_module_index(files, source_root)
    path_to_module = {module.path: module for module in modules.values()}

    for path in files:
        module = path_to_module.get(path)
        text = path.read_text(encoding="utf-8")
        clean, _ = strip_comments(text)
        masked = mask_all_strings(clean)
        if module is None:
            imports: dict[str, str] = {}
            for match in re.finditer(
                r"(?m)^import\s+([A-Za-z_][A-Za-z0-9_.]*)(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?\s*$",
                masked,
            ):
                target = match.group(1)
                imports[match.group(2) or target.rsplit(".", 1)[-1]] = target
        else:
            imports = module.imports

        for alias, target_name in imports.items():
            if not target_name.startswith("miniquake."):
                continue
            target = modules.get(target_name)
            if target is None:
                continue
            # Do not mistake ``object.alias.member`` for a package-qualified
            # access.  The alias must start a name chain.
            use_re = re.compile(
                r"(?<![A-Za-z0-9_.])" + re.escape(alias) + r"\.([A-Za-z_][A-Za-z0-9_]*)"
            )
            for match in use_re.finditer(masked):
                line = masked.count("\n", 0, match.start()) + 1
                line_start = masked.rfind("\n", 0, match.start()) + 1
                line_end = masked.find("\n", match.start())
                if line_end < 0:
                    line_end = len(masked)
                source_line = masked[line_start:line_end].strip()
                if source_line.startswith("import "):
                    continue
                member = match.group(1)
                if member not in target.exports:
                    diagnostics.append(
                        Diagnostic(path, line, f"undefined imported symbol {target_name}.{member}")
                    )
    return diagnostics


def lint_direct_arities(files: list[Path], source_root: Path) -> list[Diagnostic]:
    modules, diagnostics = build_module_index(files, source_root)
    function_defs: dict[str, int] = {}
    struct_defs: dict[str, int] = {}
    path_to_module: dict[Path, ModuleInfo] = {}
    for module in modules.values():
        path_to_module[module.path] = module
        for name, arity in module.functions.items():
            function_defs[f"{module.package}.{name}"] = arity
        for name, arity in module.structs.items():
            struct_defs[f"{module.package}.{name}"] = arity

    call_re = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*)\s*\(")
    for path in files:
        module = path_to_module.get(path)
        if module is None:
            # Tests are entry-like but can use imported module aliases.
            text = path.read_text(encoding="utf-8")
            clean, _ = strip_comments(text)
            masked = mask_all_strings(clean)
            imports: dict[str, str] = {}
            for match in re.finditer(
                r"(?m)^import\s+([A-Za-z_][A-Za-z0-9_.]*)(?:\s+as\s+([A-Za-z_][A-Za-z0-9_]*))?\s*$", masked,
            ):
                target = match.group(1)
                imports[match.group(2) or target.rsplit(".", 1)[-1]] = target
            local_functions: dict[str, int] = {}
            for match in re.finditer(r"(?m)^function(?:\s+inline)?\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", masked):
                opening = masked.find("(", match.start(), match.end())
                parsed = parenthesized_arity(masked, opening)
                if parsed is not None:
                    local_functions[match.group(1)] = parsed[0]
            module = ModuleInfo(path, "<entry>", imports, local_functions, {}, set(local_functions))
        else:
            text = path.read_text(encoding="utf-8")
            clean, _ = strip_comments(text)
            masked = mask_all_strings(clean)

        for match in call_re.finditer(masked):
            name = match.group(1)
            line_start = masked.rfind("\n", 0, match.start()) + 1
            prefix = masked[line_start:match.start()]
            if re.search(r"(?:extern\s+)?function(?:\s+inline)?\s*$", prefix):
                continue
            if re.search(r"(?:extern\s+)?struct\s*$", prefix):
                continue
            opening = masked.find("(", match.start(), match.end())
            parsed = parenthesized_arity(masked, opening)
            if parsed is None:
                continue
            actual, _ = parsed
            expected: int | None = None
            qualified = ""
            parts = name.split(".")
            if len(parts) == 1:
                if name in module.functions:
                    expected = module.functions[name]
                    qualified = f"{module.package}.{name}"
                else:
                    candidate = f"{module.package}.{name}"
                    if candidate in struct_defs:
                        expected = struct_defs[candidate]
                        qualified = candidate
            else:
                target_module = module.imports.get(parts[0])
                if target_module is not None:
                    candidate = target_module + "." + ".".join(parts[1:])
                    if candidate in function_defs:
                        expected = function_defs[candidate]
                        qualified = candidate
                    elif candidate in struct_defs:
                        expected = struct_defs[candidate]
                        qualified = candidate
                    elif target_module.startswith("miniquake.") and target_module in modules:
                        line = masked.count("\n", 0, match.start()) + 1
                        diagnostics.append(
                            Diagnostic(path, line, f"undefined imported symbol {candidate}")
                        )
                else:
                    candidate = name
                    if candidate in function_defs:
                        expected = function_defs[candidate]
                        qualified = candidate
                    elif candidate in struct_defs:
                        expected = struct_defs[candidate]
                        qualified = candidate
            if expected is not None and actual != expected:
                line = masked.count("\n", 0, match.start()) + 1
                diagnostics.append(
                    Diagnostic(path, line, f"direct call {qualified} expects {expected} argument(s), got {actual}")
                )
    return diagnostics

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = Path(args.root).resolve()
    source_root = root / "src"
    files = sorted(source_root.rglob("*.ml")) + sorted((root / "tests").rglob("*.ml"))
    diagnostics: list[Diagnostic] = []
    for path in files:
        diagnostics.extend(lint_file(path, source_root))
    diagnostics.extend(lint_compile_unit_aliases(files, source_root))
    diagnostics.extend(lint_qualified_import_members(files, source_root))
    diagnostics.extend(lint_direct_arities(files, source_root))
    if diagnostics:
        for diagnostic in diagnostics:
            print(diagnostic)
        print(f"{len(diagnostics)} structural diagnostic(s)", file=sys.stderr)
        return 1
    print(f"MiniLang structural lint passed: {len(files)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
