#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Validate MiniQuake UI matrix captures and build per-scene contact sheets."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageDraw


SCENES = (
    "hud",
    "menu-main",
    "menu-options",
    "menu-video",
    "menu-help",
    "console",
    "intermission",
    "finale",
)


def ui_scale(width: int, height: int) -> int:
    """Compute the integral virtual-console scale for one resolution."""
    value = int(min(width / 640.0, height / 480.0) + 0.5)
    if value == 1 and width >= 960 and height >= 600:
        value = 2
    return max(1, min(4, value))


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("prefix", type=Path)
    parser.add_argument("--cell-width", type=int, default=384)
    parser.add_argument("--cell-height", type=int, default=240)
    parser.add_argument("--columns", type=int, default=5)
    args = parser.parse_args()

    prefix = args.prefix
    summary_path = Path(f"{prefix}-summary.json")
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    modes = summary.get("modes", [])
    errors: list[str] = []
    sheets: list[str] = []

    if summary.get("result") != "PASS":
        errors.append("engine matrix summary did not pass")
    if summary.get("captures") != len(modes) * len(SCENES):
        errors.append("matrix capture count does not match modes x scenes")

    columns = max(1, args.columns)
    rows = (len(modes) + columns - 1) // columns
    label_height = 24
    for scene in SCENES:
        sheet = Image.new(
            "RGB",
            (columns * args.cell_width, rows * (args.cell_height + label_height)),
            (20, 20, 20),
        )
        draw = ImageDraw.Draw(sheet)
        for index, mode in enumerate(modes):
            width = int(mode["width"])
            height = int(mode["height"])
            image_path = Path(f"{prefix}-{width}x{height}-{scene}.tga")
            if not image_path.exists():
                errors.append(f"missing {image_path}")
                continue
            with Image.open(image_path) as source:
                if source.size != (width, height):
                    errors.append(
                        f"{image_path} is {source.size[0]}x{source.size[1]}, expected {width}x{height}"
                    )
                thumbnail = source.convert("RGB")
                thumbnail.thumbnail((args.cell_width, args.cell_height), Image.Resampling.LANCZOS)
                x = (index % columns) * args.cell_width
                y = (index // columns) * (args.cell_height + label_height)
                x += (args.cell_width - thumbnail.width) // 2
                y += (args.cell_height - thumbnail.height) // 2
                sheet.paste(thumbnail, (x, y))
            label_x = (index % columns) * args.cell_width + 6
            label_y = (index // columns) * (args.cell_height + label_height) + args.cell_height + 5
            draw.text(
                (label_x, label_y),
                f"{width}x{height}  UI {ui_scale(width, height)}x",
                fill=(240, 240, 240),
            )
        sheet_path = Path(f"{prefix}-contact-{scene}.png")
        sheet.save(sheet_path)
        sheets.append(str(sheet_path))

    report = {
        "schema": "MiniQuakeUIResolutionMatrixReport/1",
        "resolutions": len(modes),
        "scenes": len(SCENES),
        "captures": len(modes) * len(SCENES),
        "contact_sheets": sheets,
        "errors": errors,
        "result": "PASS" if not errors else "FAIL",
    }
    report_path = Path(f"{prefix}-report.json")
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
