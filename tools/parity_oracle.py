#!/usr/bin/env python3
"""Compare MiniQuake artifacts with the pinned GLQuake parity oracle."""

from __future__ import annotations

import argparse
import json
import math
import struct
import subprocess
import sys
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"


class Difference(AssertionError):
    pass


def load_json_lines(path: Path) -> list[Any]:
    values: list[Any] = []
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            values.append(json.loads(line))
        except json.JSONDecodeError as exc:
            raise Difference(f"{path}:{number}: invalid JSON: {exc}") from exc
    return values


def compare_value(
    expected: Any,
    actual: Any,
    *,
    path: str,
    epsilon: float,
    ignored_fields: set[str],
) -> None:
    field_name = path.rsplit(".", 1)[-1]
    if field_name in ignored_fields:
        return
    if isinstance(expected, bool) or isinstance(actual, bool):
        if expected is not actual:
            raise Difference(f"{path}: expected {expected!r}, got {actual!r}")
        return
    if isinstance(expected, (int, float)) and isinstance(actual, (int, float)):
        if not math.isfinite(float(expected)) or not math.isfinite(float(actual)):
            if expected != actual:
                raise Difference(f"{path}: expected {expected!r}, got {actual!r}")
            return
        if abs(float(expected) - float(actual)) > epsilon:
            raise Difference(
                f"{path}: expected {expected!r}, got {actual!r} "
                f"(difference exceeds {epsilon})"
            )
        return
    if isinstance(expected, dict) and isinstance(actual, dict):
        expected_keys = set(expected) - ignored_fields
        actual_keys = set(actual) - ignored_fields
        if expected_keys != actual_keys:
            raise Difference(
                f"{path}: key mismatch; missing={sorted(expected_keys - actual_keys)}, "
                f"extra={sorted(actual_keys - expected_keys)}"
            )
        for key in sorted(expected_keys):
            compare_value(
                expected[key],
                actual[key],
                path=f"{path}.{key}",
                epsilon=epsilon,
                ignored_fields=ignored_fields,
            )
        return
    if isinstance(expected, list) and isinstance(actual, list):
        if len(expected) != len(actual):
            raise Difference(
                f"{path}: expected {len(expected)} items, got {len(actual)}"
            )
        for index, (expected_item, actual_item) in enumerate(zip(expected, actual)):
            compare_value(
                expected_item,
                actual_item,
                path=f"{path}[{index}]",
                epsilon=epsilon,
                ignored_fields=ignored_fields,
            )
        return
    if type(expected) is not type(actual) or expected != actual:
        raise Difference(f"{path}: expected {expected!r}, got {actual!r}")


def compare_traces(
    reference: Path,
    candidate: Path,
    epsilon: float,
    ignored_fields: set[str],
) -> dict[str, Any]:
    expected = load_json_lines(reference)
    actual = load_json_lines(candidate)
    compare_value(
        expected,
        actual,
        path="trace",
        epsilon=epsilon,
        ignored_fields=ignored_fields,
    )
    return {"events": len(expected), "epsilon": epsilon}


@dataclass(frozen=True)
class WaveData:
    channels: int
    rate: int
    width: int
    frames: int
    samples: tuple[int, ...]


def read_wave(path: Path) -> WaveData:
    with wave.open(str(path), "rb") as source:
        channels = source.getnchannels()
        rate = source.getframerate()
        width = source.getsampwidth()
        frames = source.getnframes()
        compression = source.getcomptype()
        payload = source.readframes(frames)
    if compression != "NONE":
        raise Difference(f"{path}: compressed WAVE data is unsupported")
    if width == 1:
        samples = tuple(value - 128 for value in payload)
    elif width == 2:
        samples = struct.unpack(f"<{len(payload) // 2}h", payload)
    else:
        raise Difference(f"{path}: only 8- and 16-bit PCM are supported")
    return WaveData(channels, rate, width, frames, tuple(samples))


def compare_waves(
    reference: Path,
    candidate: Path,
    max_lsb: int,
    frame_slack: int,
) -> dict[str, Any]:
    expected = read_wave(reference)
    actual = read_wave(candidate)
    expected_format = (expected.channels, expected.rate, expected.width)
    actual_format = (actual.channels, actual.rate, actual.width)
    if expected_format != actual_format:
        raise Difference(
            f"wave format mismatch: expected {expected_format}, got {actual_format}"
        )
    if abs(expected.frames - actual.frames) > frame_slack:
        raise Difference(
            f"wave length mismatch: expected {expected.frames} frames, "
            f"got {actual.frames}; slack is {frame_slack}"
        )
    compared = min(len(expected.samples), len(actual.samples))
    largest = 0
    largest_index = -1
    for index in range(compared):
        difference = abs(expected.samples[index] - actual.samples[index])
        if difference > largest:
            largest = difference
            largest_index = index
    if largest > max_lsb:
        raise Difference(
            f"PCM mismatch at sample {largest_index}: maximum difference {largest}, "
            f"allowed {max_lsb}"
        )
    return {
        "channels": expected.channels,
        "rate": expected.rate,
        "frames_compared": compared // expected.channels,
        "maximum_lsb_difference": largest,
    }


def global_ssim(reference: Path, candidate: Path) -> float:
    try:
        from PIL import Image, ImageChops
    except ImportError as exc:
        raise Difference(
            "image comparison requires Pillow (`python -m pip install Pillow`)"
        ) from exc
    with Image.open(reference) as reference_image:
        expected = reference_image.convert("RGB")
    with Image.open(candidate) as candidate_image:
        actual = candidate_image.convert("RGB")
    if expected.size != actual.size:
        raise Difference(
            f"image size mismatch: expected {expected.size}, got {actual.size}"
        )
    # Use luminance for the platform-tolerant structural score, but require the
    # same dimensions and separately report the RGB extrema.
    expected_luma = list(expected.convert("L").getdata())
    actual_luma = list(actual.convert("L").getdata())
    count = len(expected_luma)
    mean_expected = sum(expected_luma) / count
    mean_actual = sum(actual_luma) / count
    variance_expected = sum(
        (value - mean_expected) ** 2 for value in expected_luma
    ) / count
    variance_actual = sum(
        (value - mean_actual) ** 2 for value in actual_luma
    ) / count
    covariance = sum(
        (left - mean_expected) * (right - mean_actual)
        for left, right in zip(expected_luma, actual_luma)
    ) / count
    c1 = (0.01 * 255.0) ** 2
    c2 = (0.03 * 255.0) ** 2
    score = (
        (2.0 * mean_expected * mean_actual + c1) * (2.0 * covariance + c2)
    ) / (
        (mean_expected**2 + mean_actual**2 + c1)
        * (variance_expected + variance_actual + c2)
    )
    extrema = ImageChops.difference(expected, actual).getextrema()
    maximum_rgb_difference = max(channel[1] for channel in extrema)
    return score, maximum_rgb_difference


def compare_images(
    reference: Path, candidate: Path, minimum_ssim: float
) -> dict[str, Any]:
    score, maximum = global_ssim(reference, candidate)
    if score < minimum_ssim:
        raise Difference(
            f"image SSIM is {score:.6f}, required minimum is {minimum_ssim:.6f}"
        )
    return {"ssim": score, "maximum_rgb_difference": maximum}


def verify_reference() -> None:
    result = subprocess.run([sys.executable, str(VERIFY_REFERENCE)], check=False)
    if result.returncode != 0:
        raise Difference("pinned GLQuake reference verification failed")


def write_test_wave(path: Path, values: list[int]) -> None:
    with wave.open(str(path), "wb") as destination:
        destination.setnchannels(1)
        destination.setsampwidth(2)
        destination.setframerate(11025)
        destination.writeframes(struct.pack(f"<{len(values)}h", *values))


def self_test() -> dict[str, Any]:
    with tempfile.TemporaryDirectory(prefix="miniquake-parity-") as directory:
        root = Path(directory)
        left_trace = root / "left.jsonl"
        right_trace = root / "right.jsonl"
        left_trace.write_text(
            '{"kind":"frame","frame":1,"origin":[1.0,2.0,3.0]}\n',
            encoding="utf-8",
        )
        right_trace.write_text(
            '{"kind":"frame","frame":1,"origin":[1.000001,2.0,3.0]}\n',
            encoding="utf-8",
        )
        trace = compare_traces(left_trace, right_trace, 1e-5, set())
        left_wave = root / "left.wav"
        right_wave = root / "right.wav"
        write_test_wave(left_wave, [0, 100, -100, 3276])
        write_test_wave(right_wave, [1, 99, -99, 3275])
        audio = compare_waves(left_wave, right_wave, 1, 512)
    return {"trace": trace, "audio": audio}


def print_result(kind: str, result: dict[str, Any]) -> None:
    print(json.dumps({"status": "passed", "kind": kind, **result}, indent=2))


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("verify-reference")
    subparsers.add_parser("self-test")

    trace_parser = subparsers.add_parser("compare-traces")
    trace_parser.add_argument("reference", type=Path)
    trace_parser.add_argument("candidate", type=Path)
    trace_parser.add_argument("--epsilon", type=float, default=1e-5)
    trace_parser.add_argument("--ignore-field", action="append", default=[])

    wave_parser = subparsers.add_parser("compare-wav")
    wave_parser.add_argument("reference", type=Path)
    wave_parser.add_argument("candidate", type=Path)
    wave_parser.add_argument("--max-lsb", type=int, default=1)
    wave_parser.add_argument("--frame-slack", type=int, default=512)

    image_parser = subparsers.add_parser("compare-images")
    image_parser.add_argument("reference", type=Path)
    image_parser.add_argument("candidate", type=Path)
    image_parser.add_argument("--minimum-ssim", type=float, default=0.99)

    args = parser.parse_args()
    try:
        if args.command == "verify-reference":
            verify_reference()
            print_result("reference", {})
        elif args.command == "self-test":
            print_result("self-test", self_test())
        elif args.command == "compare-traces":
            print_result(
                "trace",
                compare_traces(
                    args.reference,
                    args.candidate,
                    args.epsilon,
                    set(args.ignore_field),
                ),
            )
        elif args.command == "compare-wav":
            print_result(
                "audio",
                compare_waves(
                    args.reference,
                    args.candidate,
                    args.max_lsb,
                    args.frame_slack,
                ),
            )
        elif args.command == "compare-images":
            print_result(
                "image",
                compare_images(
                    args.reference, args.candidate, args.minimum_ssim
                ),
            )
        else:
            parser.error("unknown command")
    except (Difference, OSError, ValueError) as exc:
        print(f"parity comparison failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
