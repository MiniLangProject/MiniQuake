#!/usr/bin/env python3
"""Run pinned-source format/header ABI checks for MiniQuake's core units."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_COMPILER = ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py"
FIXTURE = ROOT / "tests" / "core_format_abi_tests.ml"


def run(command: list[str]) -> None:
    subprocess.run(command, cwd=ROOT, check=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, default=DEFAULT_COMPILER)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build" / "core_format_abi_semantic.exe",
    )
    args = parser.parse_args()

    run([sys.executable, str(ROOT / "tools" / "verify_reference.py")])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    run(
        [
            sys.executable,
            str(args.compiler.resolve()),
            str(FIXTURE),
            str(args.output.resolve()),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(args.compiler.resolve().parent),
            "--keep-going",
            "--max-errors",
            "80",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    run([str(args.output.resolve())])
    print(
        "core format/header semantic checks: PASS "
        "(BSP29, MDL6, SPR1, progs v6, protocol 15)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
