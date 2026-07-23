#!/usr/bin/env python3
"""Lexical-scope preflight for MiniQuake's MiniLang sources.

The MiniLang compiler creates a local at its first assignment in the current
lexical block.  Therefore a value first assigned independently inside the two
branches of an ``if`` is not visible after ``end if``.  This checker mirrors
that rule closely enough to catch branch/loop/case-local values that escape
their declaring block before the much more expensive native code-generation
pass starts.

It deliberately reports only unresolved reads of names that are assigned
somewhere in the same function.  That keeps the check conservative: package
functions, imports, builtins, struct constructors and enum values are left to
the real compiler's normal name resolver.
"""
from __future__ import annotations

import argparse
import importlib.util
from pathlib import Path
import sys
from types import ModuleType
from typing import Any, Iterable


def load_parser(compiler_root: Path) -> ModuleType:
    candidates = [
        compiler_root / "mlc" / "minilang_parser.py",
        compiler_root / "minilang_parser.py",
    ]
    for candidate in candidates:
        if not candidate.is_file():
            continue
        spec = importlib.util.spec_from_file_location("miniquake_minilang_parser", candidate)
        if spec is None or spec.loader is None:
            continue
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        return module
    expected = " or ".join(str(path) for path in candidates)
    raise SystemExit(f"MiniLang parser not found; expected {expected}")


def line_for(source: str, position: int | None) -> int:
    if position is None:
        return 1
    return source.count("\n", 0, max(0, int(position))) + 1


def expression_reads(ml: ModuleType, expression: Any) -> list[tuple[str, int | None]]:
    if expression is None:
        return []
    if isinstance(expression, ml.Var):
        return [(expression.name, getattr(expression, "pos", None))]
    if isinstance(expression, ml.ArrayLit):
        reads: list[tuple[str, int | None]] = []
        for item in expression.items:
            reads.extend(expression_reads(ml, item))
        return reads
    if isinstance(expression, ml.Unary):
        return expression_reads(ml, expression.right)
    if isinstance(expression, ml.Bin):
        return expression_reads(ml, expression.left) + expression_reads(ml, expression.right)
    if isinstance(expression, ml.IsType):
        return expression_reads(ml, expression.expr)
    if isinstance(expression, ml.Call):
        reads = expression_reads(ml, expression.callee)
        for argument in expression.args:
            reads.extend(expression_reads(ml, argument))
        return reads
    if isinstance(expression, ml.Index):
        return expression_reads(ml, expression.target) + expression_reads(ml, expression.index)
    if isinstance(expression, ml.Member):
        return expression_reads(ml, expression.target)
    return []


def assigned_names(ml: ModuleType, statements: Iterable[Any]) -> set[str]:
    result: set[str] = set()
    for statement in statements:
        if isinstance(statement, (ml.Assign, ml.ConstDecl)):
            result.add(statement.name)
        elif isinstance(statement, ml.If):
            result.update(assigned_names(ml, statement.then_body))
            for _condition, body in statement.elifs:
                result.update(assigned_names(ml, body))
            result.update(assigned_names(ml, statement.else_body))
        elif isinstance(statement, (ml.While, ml.DoWhile)):
            result.update(assigned_names(ml, statement.body))
        elif isinstance(statement, (ml.For, ml.ForEach)):
            result.add(statement.var)
            result.update(assigned_names(ml, statement.body))
        elif isinstance(statement, ml.Switch):
            for case in statement.cases:
                result.update(assigned_names(ml, case.body))
            result.update(assigned_names(ml, statement.default_body))
        elif isinstance(statement, ml.FunctionDef):
            result.add(statement.name)
    return result


class ScopeStack:
    def __init__(self, initial: Iterable[str]) -> None:
        self.scopes: list[set[str]] = [set(initial)]

    def visible(self, name: str) -> bool:
        return any(name in scope for scope in reversed(self.scopes))

    def write(self, name: str) -> None:
        # MiniLang writes target the nearest visible local.  Only when no
        # binding exists does the assignment introduce a local in this block.
        if not self.visible(name):
            self.scopes[-1].add(name)

    def push(self, initial: Iterable[str] = ()) -> None:
        self.scopes.append(set(initial))

    def pop(self) -> None:
        self.scopes.pop()

    def visible_names(self) -> set[str]:
        result: set[str] = set()
        for scope in self.scopes:
            result.update(scope)
        return result


def analyse_function(
    ml: ModuleType,
    source: str,
    function: Any,
    captured: Iterable[str] = (),
) -> list[tuple[int, str, str]]:
    assigned = assigned_names(ml, function.body)
    scopes = ScopeStack(set(function.params) | set(captured))
    diagnostics: list[tuple[int, str, str]] = []

    def read(expression: Any) -> None:
        for name, position in expression_reads(ml, expression):
            if name in assigned and not scopes.visible(name):
                diagnostics.append(
                    (
                        line_for(source, position),
                        function.name,
                        f"local {name!r} is read outside the lexical block that first assigns it",
                    )
                )

    def analyse_block(statements: Iterable[Any]) -> None:
        for statement in statements:
            if isinstance(statement, (ml.Assign, ml.ConstDecl)):
                read(statement.expr)
                scopes.write(statement.name)
            elif isinstance(statement, ml.SetMember):
                read(statement.obj)
                read(statement.expr)
            elif isinstance(statement, ml.SetIndex):
                read(statement.target)
                read(statement.index)
                read(statement.expr)
            elif isinstance(statement, (ml.ExprStmt, ml.Print)):
                read(statement.expr)
            elif isinstance(statement, ml.Return):
                read(statement.expr)
            elif isinstance(statement, ml.If):
                read(statement.cond)
                scopes.push()
                analyse_block(statement.then_body)
                scopes.pop()
                for condition, body in statement.elifs:
                    read(condition)
                    scopes.push()
                    analyse_block(body)
                    scopes.pop()
                scopes.push()
                analyse_block(statement.else_body)
                scopes.pop()
            elif isinstance(statement, ml.While):
                read(statement.cond)
                scopes.push()
                analyse_block(statement.body)
                scopes.pop()
            elif isinstance(statement, ml.DoWhile):
                scopes.push()
                analyse_block(statement.body)
                read(statement.cond)
                scopes.pop()
            elif isinstance(statement, ml.For):
                read(statement.start)
                read(statement.end)
                scopes.push([statement.var])
                analyse_block(statement.body)
                scopes.pop()
            elif isinstance(statement, ml.ForEach):
                read(statement.iterable)
                scopes.push([statement.var])
                analyse_block(statement.body)
                scopes.pop()
            elif isinstance(statement, ml.Switch):
                read(statement.expr)
                for case in statement.cases:
                    for value in case.values:
                        read(value)
                    read(case.range_start)
                    read(case.range_end)
                    scopes.push()
                    analyse_block(case.body)
                    scopes.pop()
                scopes.push()
                analyse_block(statement.default_body)
                scopes.pop()
            elif isinstance(statement, ml.FunctionDef):
                scopes.write(statement.name)
                diagnostics.extend(
                    analyse_function(ml, source, statement, scopes.visible_names())
                )
            elif isinstance(statement, ml.GlobalDecl):
                # A global declaration makes the name visible throughout the
                # function from this statement onward.
                for name in statement.names:
                    scopes.scopes[0].add(name)
            elif isinstance(statement, (ml.Break, ml.Continue)):
                continue

    analyse_block(function.body)
    return diagnostics


def functions_in(ml: ModuleType, statements: Iterable[Any]) -> Iterable[Any]:
    for statement in statements:
        if isinstance(statement, ml.FunctionDef):
            yield statement
        elif isinstance(statement, ml.StructDef):
            yield from statement.methods
        elif isinstance(statement, ml.NamespaceDef):
            yield from functions_in(ml, statement.body)


def main() -> int:
    argument_parser = argparse.ArgumentParser()
    argument_parser.add_argument("root", type=Path)
    argument_parser.add_argument("--compiler-root", type=Path, required=True)
    arguments = argument_parser.parse_args()

    root = arguments.root.resolve()
    parser_module = load_parser(arguments.compiler_root.resolve())
    files = sorted((root / "src").rglob("*.ml")) + sorted((root / "tests").rglob("*.ml"))
    diagnostics: list[str] = []

    for path in files:
        source = path.read_text(encoding="utf-8")
        try:
            program = parser_module.Parser(
                parser_module.tokenize(source), source, str(path)
            ).parse_program()
        except Exception as exc:
            diagnostics.append(f"{path}: parser preflight failed: {exc}")
            continue
        for function in functions_in(parser_module, program):
            for line, function_name, message in analyse_function(
                parser_module, source, function
            ):
                diagnostics.append(f"{path}:{line}: function {function_name}: {message}")

    if diagnostics:
        for diagnostic in diagnostics:
            print(diagnostic)
        print(f"{len(diagnostics)} lexical-scope diagnostic(s)", file=sys.stderr)
        return 1

    print(f"MiniLang lexical-scope lint passed: {len(files)} files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
