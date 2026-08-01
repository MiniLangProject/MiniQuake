#!/usr/bin/env python3
"""Compare two uncompressed 24-bit TGA framebuffer captures.

The default report is descriptive.  --require-exact makes any byte difference
fatal; --min-ssim accepts visually equivalent captures once an external
GLQuake reference corpus is available.
"""
from __future__ import annotations
import argparse, hashlib, json, math, pathlib, tempfile
from dataclasses import dataclass

@dataclass(frozen=True)
class Image:
    width: int
    height: int
    rgb: bytes


def load_tga(path: pathlib.Path) -> Image:
    data = path.read_bytes()
    if len(data) < 18 or data[2] != 2 or data[16] != 24:
        raise ValueError(f"{path}: expected uncompressed 24-bit TGA")
    ident = data[0]
    width = data[12] | (data[13] << 8)
    height = data[14] | (data[15] << 8)
    offset = 18 + ident
    expected = width * height * 3
    if width < 1 or height < 1 or len(data) != offset + expected:
        raise ValueError(f"{path}: malformed TGA dimensions or byte count")
    bgr = data[offset:]
    rgb = bytearray(expected)
    for index in range(0, expected, 3):
        rgb[index] = bgr[index + 2]
        rgb[index + 1] = bgr[index + 1]
        rgb[index + 2] = bgr[index]
    return Image(width, height, bytes(rgb))


def luminance(rgb: bytes) -> list[float]:
    return [
        0.2126 * rgb[i] + 0.7152 * rgb[i + 1] + 0.0722 * rgb[i + 2]
        for i in range(0, len(rgb), 3)
    ]


def global_ssim(left: bytes, right: bytes) -> float:
    a = luminance(left)
    b = luminance(right)
    n = len(a)
    if n == 0:
        return 1.0
    mean_a = sum(a) / n
    mean_b = sum(b) / n
    if n == 1:
        var_a = var_b = cov = 0.0
    else:
        var_a = sum((x - mean_a) ** 2 for x in a) / (n - 1)
        var_b = sum((x - mean_b) ** 2 for x in b) / (n - 1)
        cov = sum((a[i] - mean_a) * (b[i] - mean_b) for i in range(n)) / (n - 1)
    c1 = (0.01 * 255.0) ** 2
    c2 = (0.03 * 255.0) ** 2
    denominator = (mean_a * mean_a + mean_b * mean_b + c1) * (var_a + var_b + c2)
    if denominator == 0.0:
        return 1.0
    return ((2.0 * mean_a * mean_b + c1) * (2.0 * cov + c2)) / denominator


def compare(left_path: pathlib.Path, right_path: pathlib.Path) -> dict[str, object]:
    left = load_tga(left_path)
    right = load_tga(right_path)
    if (left.width, left.height) != (right.width, right.height):
        return {
            "ok": False, "same_dimensions": False,
            "left_dimensions": [left.width, left.height],
            "right_dimensions": [right.width, right.height],
        }
    differences = [abs(a - b) for a, b in zip(left.rgb, right.rgb)]
    different_bytes = sum(value != 0 for value in differences)
    mae = sum(differences) / len(differences) if differences else 0.0
    mse = sum(value * value for value in differences) / len(differences) if differences else 0.0
    psnr = None if mse == 0.0 else 10.0 * math.log10((255.0 * 255.0) / mse)
    ssim = global_ssim(left.rgb, right.rgb)
    exact = left.rgb == right.rgb
    return {
        "ok": True,
        "same_dimensions": True,
        "dimensions": [left.width, left.height],
        "exact": exact,
        "different_channel_bytes": different_bytes,
        "mae": mae,
        "mse": mse,
        "psnr": psnr,
        "ssim": ssim,
        "left_sha256": hashlib.sha256(left_path.read_bytes()).hexdigest(),
        "right_sha256": hashlib.sha256(right_path.read_bytes()).hexdigest(),
    }


def make_tga(path: pathlib.Path, rgb: bytes, width: int, height: int) -> None:
    header = bytearray(18)
    header[2] = 2
    header[12] = width & 255
    header[13] = width >> 8
    header[14] = height & 255
    header[15] = height >> 8
    header[16] = 24
    bgr = bytearray()
    for i in range(0, len(rgb), 3):
        bgr.extend((rgb[i + 2], rgb[i + 1], rgb[i]))
    path.write_bytes(header + bgr)


def self_test() -> None:
    with tempfile.TemporaryDirectory() as directory:
        root = pathlib.Path(directory)
        a = root / "a.tga"; b = root / "b.tga"; c = root / "c.tga"
        make_tga(a, bytes([0, 0, 0, 255, 0, 0]), 2, 1)
        make_tga(b, bytes([0, 0, 0, 255, 0, 0]), 2, 1)
        make_tga(c, bytes([0, 0, 0, 254, 0, 0]), 2, 1)
        exact = compare(a, b); changed = compare(a, c)
        assert exact["exact"] is True and exact["ssim"] == 1.0
        assert changed["exact"] is False and changed["different_channel_bytes"] == 1
    print("MiniQuake render evidence comparator self-test: PASS")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("left", nargs="?")
    parser.add_argument("right", nargs="?")
    parser.add_argument("--json-out", "--json-output", dest="json_out")
    parser.add_argument("--require-exact", action="store_true")
    parser.add_argument("--min-ssim", type=float, default=0.0)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test(); return 0
    if not args.left or not args.right:
        parser.error("left and right TGA paths are required")
    report = compare(pathlib.Path(args.left), pathlib.Path(args.right))
    exact = bool(report.get("exact", False))
    ssim = float(report.get("ssim", 0.0)) if report.get("same_dimensions") else 0.0
    accepted = bool(report.get("ok")) and (not args.require_exact or exact) and ssim >= args.min_ssim
    report["accepted"] = accepted
    report["require_exact"] = args.require_exact
    report["minimum_ssim"] = args.min_ssim
    text = json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n"
    print(text, end="")
    if args.json_out:
        pathlib.Path(args.json_out).write_text(text, encoding="utf-8")
    return 0 if accepted else 1

if __name__ == "__main__":
    raise SystemExit(main())
