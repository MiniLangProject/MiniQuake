#!/usr/bin/env python3
"""Verify that MiniQuake's alias normal tables are verbatim GLQuake data."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake" / "WinQuake"
MINILANG = ROOT / "src" / "miniquake" / "render" / "alias_normals.ml"
DECIMAL = re.compile(r"(?<![\w.])-?\d+\.\d+")


def decimals(text: str) -> list[float]:
    return [float(value) for value in DECIMAL.findall(text)]


def require_equal(name: str, expected: list[float], actual: list[float]) -> None:
    if len(expected) != len(actual):
        raise RuntimeError(
            f"{name}: expected {len(expected)} values, observed {len(actual)}"
        )
    mismatches = [
        index
        for index, (left, right) in enumerate(zip(expected, actual))
        if left != right
    ]
    if mismatches:
        index = mismatches[0]
        raise RuntimeError(
            f"{name}: first mismatch at {index}: "
            f"{expected[index]} != {actual[index]}"
        )


def main() -> int:
    source = MINILANG.read_text(encoding="utf-8")
    normals_text, dots_text = source.split("shadeDots = [", 1)
    normals_text = normals_text.split("normals = [", 1)[1]

    normals = decimals((REFERENCE / "anorms.h").read_text(encoding="utf-8"))
    dots = decimals((REFERENCE / "anorm_dots.h").read_text(encoding="utf-8"))
    mini_normals = decimals(normals_text)
    mini_dots = decimals(dots_text)

    require_equal("anorms.h", normals, mini_normals)
    require_equal("anorm_dots.h", dots, mini_dots)
    if len(normals) != 162 * 3:
        raise RuntimeError(f"anorms.h: expected 162 vectors, got {len(normals) // 3}")
    if len(dots) != 16 * 256:
        raise RuntimeError(
            f"anorm_dots.h: expected 16x256 values, got {len(dots)}"
        )
    print("alias tables passed: 162 normals, 16x256 shade-dot values, exact")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
