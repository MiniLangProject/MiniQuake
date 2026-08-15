#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Embed MiniQuake's checked-in Vulkan SPIR-V modules as C uint32 arrays."""

from __future__ import annotations

import argparse
from pathlib import Path
import struct


def words(path: Path) -> list[int]:
    """Read one word-aligned little-endian SPIR-V module."""
    data = path.read_bytes()
    if len(data) % 4:
        raise SystemExit(f"SPIR-V byte count is not word aligned: {path}")
    return list(struct.unpack(f"<{len(data) // 4}I", data))


def array(name: str, values: list[int]) -> str:
    """Format one immutable C uint32 array from SPIR-V words."""
    lines = [f"static const mq_u32 {name}[] = {{"]
    for offset in range(0, len(values), 8):
        chunk = ", ".join(f"0x{value:08x}u" for value in values[offset:offset + 8])
        lines.append(f"    {chunk},")
    lines.append("};")
    return "\n".join(lines)


def main() -> int:
    """Embed the selected vertex and fragment modules in a guarded C header."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--vertex", type=Path, required=True)
    parser.add_argument("--fragment", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    text = "\n".join([
        "/*",
        " * Copyright (c) 1996-1997 Id Software, Inc.",
        " * Copyright (c) 2026 Nils Kopal",
        " * SPDX-License-Identifier: GPL-2.0-or-later",
        " *",
        " * Generated SPIR-V bytecode embedded by tools/embed_spirv.py.",
        " */",
        "#ifndef MINIQUAKE_VULKAN_SHADERS_H",
        "#define MINIQUAKE_VULKAN_SHADERS_H",
        "",
        array("mq_vulkan_vertex_spirv", words(args.vertex)),
        "",
        array("mq_vulkan_fragment_spirv", words(args.fragment)),
        "",
        "#endif",
        "",
    ])
    args.output.write_text(text, encoding="ascii", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
