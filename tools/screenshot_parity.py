#!/usr/bin/env python3
"""Capture identical timedemo frames in GLQuake 1.09 and MiniQuake.

Retail PAKs are hard-linked into ignored build directories so neither the
original installation nor proprietary data in the repository is modified.
Both engines execute the same timedemo and the same wait/screenshot script.
The resulting TGA files are compared with the project's SSIM oracle.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import parity_oracle  # noqa: E402


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def link_or_copy(source: Path, destination: Path) -> str:
    if destination.exists():
        if destination.stat().st_size != source.stat().st_size:
            destination.unlink()
        else:
            return "existing"
    try:
        os.link(source, destination)
        return "hardlink"
    except OSError:
        shutil.copy2(source, destination)
        return "copy"


def prepare_basedir(
    destination: Path,
    retail_basedir: Path,
    capture_frames: list[int],
    texture_mode: str | None,
    extra_commands: list[str],
) -> dict[str, Any]:
    game = destination / "id1"
    game.mkdir(parents=True, exist_ok=True)
    pak_modes: dict[str, str] = {}
    for name in ("pak0.pak", "pak1.pak"):
        source = retail_basedir / "id1" / name
        if not source.is_file():
            raise FileNotFoundError(f"retail PAK not found: {source}")
        pak_modes[name] = link_or_copy(source, game / name)

    commands = [
        "viewsize 100",
        "fov 90",
        "crosshair 0",
        "r_drawviewmodel 1",
        # Normalize simulation-dependent effects (particles, dlights and
        # model animation) independently of each executable's render speed.
        "host_framerate 0.05",
        # Screenshot itself emits "Wrote quakeXX.tga" after a capture.  Hide
        # transient notify text so later frames remain comparable as well.
        "con_notifytime 0",
    ]
    if texture_mode:
        commands.append(f"gl_texturemode {texture_mode}")
    commands.extend(extra_commands)
    previous = 0
    for frame in capture_frames:
        commands.extend("wait" for _ in range(frame - previous))
        commands.append("screenshot")
        previous = frame
    commands.append("quit")
    (game / "mqcapture.cfg").write_text(
        "\n".join(commands) + "\n", encoding="ascii", newline="\n"
    )
    return {"pak_materialization": pak_modes, "script_commands": len(commands)}


def startup_info() -> subprocess.STARTUPINFO | None:
    if not hasattr(subprocess, "STARTUPINFO"):
        return None
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    return info


def stop_process(process: subprocess.Popen[bytes]) -> bool:
    if process.poll() is not None:
        return False
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=3)
    return True


def run_capture(
    label: str,
    executable: Path,
    basedir: Path,
    demo: str,
    width: int,
    height: int,
    gamma: float,
    expected_images: int,
    timeout: float,
) -> dict[str, Any]:
    game = basedir / "id1"
    for old in game.glob("quake*.tga"):
        old.unlink()
    stdout_path = basedir / f"{label}.stdout.log"
    stderr_path = basedir / f"{label}.stderr.log"
    command = [
        str(executable),
        "-basedir",
        str(basedir),
        "-window",
        "-width",
        str(width),
        "-height",
        str(height),
        "-gamma",
        str(gamma),
        "-nosound",
        "-nojoy",
        "-noipx",
        "+timedemo",
        demo,
        "+exec",
        "mqcapture.cfg",
    ]
    if label == "miniquake":
        command[1:1] = ["-maxframes", "1000000"]

    started = time.monotonic()
    with stdout_path.open("wb") as stdout, stderr_path.open("wb") as stderr:
        process = subprocess.Popen(
            command,
            cwd=basedir,
            stdin=subprocess.DEVNULL,
            stdout=stdout,
            stderr=stderr,
            startupinfo=startup_info(),
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
        deadline = time.monotonic() + timeout
        capture_seen_at: float | None = None
        while time.monotonic() < deadline and process.poll() is None:
            image_count = len(list(game.glob("quake*.tga")))
            if image_count >= expected_images:
                if capture_seen_at is None:
                    capture_seen_at = time.monotonic()
                elif time.monotonic() - capture_seen_at >= 2.0:
                    break
            time.sleep(0.05)
        terminated_after_capture = stop_process(process)
    elapsed = time.monotonic() - started
    images = sorted(game.glob("quake*.tga"))
    output = (
        stdout_path.read_text(encoding="utf-8", errors="replace")
        + stderr_path.read_text(encoding="utf-8", errors="replace")
    )
    return {
        "label": label,
        "command": command,
        "exit_code": process.returncode,
        "terminated_after_capture": terminated_after_capture,
        "elapsed_seconds": round(elapsed, 6),
        "images": [str(path) for path in images],
        "expected_images": expected_images,
        "capture_complete": len(images) == expected_images,
        "output": output,
    }


def image_metadata(path: Path) -> dict[str, Any]:
    from PIL import Image

    with Image.open(path) as image:
        return {
            "path": str(path),
            "sha256": file_sha256(path),
            "width": image.width,
            "height": image.height,
            "mode": image.mode,
        }


def compare_pairs(
    reference_images: list[Path],
    candidate_images: list[Path],
    capture_frames: list[int],
    minimum_ssim: float,
) -> list[dict[str, Any]]:
    comparisons: list[dict[str, Any]] = []
    for frame, reference, candidate in zip(
        capture_frames, reference_images, candidate_images
    ):
        entry: dict[str, Any] = {
            "timedemo_host_frame": frame,
            "reference": image_metadata(reference),
            "candidate": image_metadata(candidate),
        }
        try:
            score, maximum = parity_oracle.global_ssim(reference, candidate)
            entry.update(
                {
                    "ssim": score,
                    "maximum_rgb_difference": maximum,
                    "passed": score >= minimum_ssim,
                }
            )
        except parity_oracle.Difference as exc:
            entry.update({"passed": False, "error": str(exc)})
        comparisons.append(entry)
    return comparisons


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mini-exe", type=Path, default=ROOT / "build" / "MiniQuake.exe"
    )
    parser.add_argument("--glquake-exe", type=Path, required=True)
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--demo", default="demo1")
    parser.add_argument("--frames", type=int, nargs="+", default=[16, 32, 48])
    parser.add_argument("--width", type=int, default=640)
    parser.add_argument("--height", type=int, default=480)
    parser.add_argument("--gamma", type=float, default=1.0)
    parser.add_argument("--texture-mode")
    parser.add_argument(
        "--command",
        action="append",
        default=[],
        help="additional console command applied identically to both engines",
    )
    parser.add_argument("--minimum-ssim", type=float, default=0.99)
    parser.add_argument("--timeout", type=float, default=60.0)
    parser.add_argument(
        "--output", type=Path, default=ROOT / "build" / "screenshot_parity"
    )
    args = parser.parse_args()

    mini = args.mini_exe.resolve()
    glquake = args.glquake_exe.resolve()
    retail = args.basedir.resolve()
    output = args.output.resolve()
    frames = sorted(set(args.frames))
    if not mini.is_file() or not glquake.is_file():
        raise SystemExit("both MiniQuake and GLQuake executables are required")
    if any(frame <= 0 for frame in frames):
        raise SystemExit("capture frames must be positive")
    if not 0.0 <= args.minimum_ssim <= 1.0:
        raise SystemExit("minimum SSIM must be between zero and one")

    gl_basedir = output / "glquake"
    mini_basedir = output / "miniquake"
    gl_preparation = prepare_basedir(
        gl_basedir, retail, frames, args.texture_mode, args.command
    )
    mini_preparation = prepare_basedir(
        mini_basedir, retail, frames, args.texture_mode, args.command
    )

    gl_run = run_capture(
        "glquake",
        glquake,
        gl_basedir,
        args.demo,
        args.width,
        args.height,
        args.gamma,
        len(frames),
        args.timeout,
    )
    mini_run = run_capture(
        "miniquake",
        mini,
        mini_basedir,
        args.demo,
        args.width,
        args.height,
        args.gamma,
        len(frames),
        args.timeout,
    )
    reference_images = [Path(path) for path in gl_run["images"]]
    candidate_images = [Path(path) for path in mini_run["images"]]
    comparisons = compare_pairs(
        reference_images, candidate_images, frames, args.minimum_ssim
    )
    complete = gl_run["capture_complete"] and mini_run["capture_complete"]
    passed = complete and len(comparisons) == len(frames) and all(
        comparison["passed"] for comparison in comparisons
    )
    result = {
        "status": "passed" if passed else "failed",
        "target": "GLQuake 1.09 screenshot parity",
        "minimum_ssim": args.minimum_ssim,
        "resolution": [args.width, args.height],
        "gamma": args.gamma,
        "texture_mode": args.texture_mode or "GL_LINEAR_MIPMAP_NEAREST",
        "extra_commands": args.command,
        "demo": args.demo,
        "capture_frames": frames,
        "executables": {
            "glquake": {"path": str(glquake), "sha256": file_sha256(glquake)},
            "miniquake": {"path": str(mini), "sha256": file_sha256(mini)},
        },
        "retail_data_committed": False,
        "preparation": {
            "glquake": gl_preparation,
            "miniquake": mini_preparation,
        },
        "runs": {"glquake": gl_run, "miniquake": mini_run},
        "comparisons": comparisons,
    }
    output.mkdir(parents=True, exist_ok=True)
    report = output / "report.json"
    report.write_text(
        json.dumps(result, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))
    print(f"report: {report}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
