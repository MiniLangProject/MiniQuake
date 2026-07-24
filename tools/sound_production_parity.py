#!/usr/bin/env python3
"""Compile and run the host-facing MiniQuake sound production-path fixtures."""

from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
    )
    args = parser.parse_args()
    compiler = args.compiler.resolve()
    if not compiler.is_file():
        raise SystemExit(f"MiniLang compiler not found: {compiler}")

    output = ROOT / "build" / "sound_production_parity"
    output.mkdir(parents=True, exist_ok=True)
    executable = output / "sound_production_parity_tests.exe"
    bridge = ROOT / "native" / "miniquake_native.dll"
    if bridge.is_file():
        shutil.copy2(bridge, output / bridge.name)
    subprocess.run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests" / "sound_production_parity_tests.ml"),
            str(executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "50",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ],
        cwd=ROOT,
        check=True,
    )
    subprocess.run([str(executable)], cwd=output, check=True)
    print("sound production parity: PASS (5 groups)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
