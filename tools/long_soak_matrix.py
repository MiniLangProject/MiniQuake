#!/usr/bin/env python3
"""Run reproducible 100,000-frame resource soaks with local retail data.

The executable performs fixed-timestep frames in-process so dedicated testing
does not spend 83 real minutes waiting for sys_ticrate.  This orchestrator
parses its phase-normalized resource snapshots and writes only aggregate
measurements; retail files are neither extracted nor copied.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import subprocess
import sys


MODE_RE = re.compile(
    r"^  mode=(?P<mode>\S+) target=(?P<target>\S+) frames=(?P<frames>\d+)$"
)
RESOURCE_RE = re.compile(
    r"^  (?P<name>[^:]+): (?P<before>\d+) -> (?P<after>\d+) "
    r"\(max (?P<maximum>\d+)\)$"
)
DEMO_RE = re.compile(r"^  demo cycles=(?P<cycles>\d+) messages=(?P<messages>\d+)$")


def parse_output(output: str) -> dict[str, object]:
    identity: dict[str, object] | None = None
    resources: dict[str, dict[str, int]] = {}
    demo_cycles = 0
    demo_messages = 0
    result = ""
    for line in output.splitlines():
        matched = MODE_RE.match(line)
        if matched:
            identity = {
                "mode": matched.group("mode"),
                "target": matched.group("target"),
                "frames": int(matched.group("frames")),
            }
            continue
        matched = RESOURCE_RE.match(line)
        if matched:
            resources[matched.group("name")] = {
                "before": int(matched.group("before")),
                "after": int(matched.group("after")),
                "maximum": int(matched.group("maximum")),
            }
            continue
        matched = DEMO_RE.match(line)
        if matched:
            demo_cycles = int(matched.group("cycles"))
            demo_messages = int(matched.group("messages"))
            continue
        if line.startswith("  result="):
            result = line.split("=", 1)[1]
    if identity is None or result not in {"PASS", "FAIL"}:
        raise RuntimeError("MiniQuake output did not contain a complete long-soak report")
    identity.update(
        {
            "status": result.lower(),
            "resources": resources,
            "demo_cycles": demo_cycles,
            "demo_messages": demo_messages,
        }
    )
    return identity


def run_mode(
    executable: Path,
    basedir: Path,
    game: str,
    mode: str,
    target: str,
    frames: int,
    port: int,
    timeout: float,
) -> dict[str, object]:
    command = [
        str(executable),
        "--long-soak",
        mode,
        str(basedir),
        target,
        str(frames),
        "-game",
        game,
    ]
    if mode != "demo":
        command.extend(["-port", str(port)])
    completed = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    try:
        report = parse_output(completed.stdout)
    except RuntimeError as error:
        raise RuntimeError(
            f"{mode} soak emitted an invalid report (exit {completed.returncode}): "
            f"{error}\n{completed.stdout}"
        ) from error
    if completed.returncode != 0 or report["status"] != "pass":
        raise RuntimeError(
            f"{mode} soak failed (exit {completed.returncode})\n{completed.stdout}"
        )
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--map", default="e1m1")
    parser.add_argument("--demo", default="demo1")
    parser.add_argument("--frames", type=int, default=100_000)
    parser.add_argument("--port", type=int, default=28_210)
    parser.add_argument("--timeout", type=float, default=1800.0)
    parser.add_argument(
        "--modes",
        nargs="+",
        choices=("listen", "dedicated", "demo"),
        default=("listen", "dedicated", "demo"),
        help="run only the selected modes, in canonical matrix order",
    )
    parser.add_argument(
        "--report", type=Path, default=Path("build/long_soak_matrix.json")
    )
    args = parser.parse_args()

    executable = args.exe.resolve()
    basedir = args.basedir.resolve()
    game_dir = basedir / args.game
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    if not game_dir.is_dir():
        raise SystemExit(f"retail game directory not found: {game_dir}")
    if args.frames < 1:
        raise SystemExit("--frames must be positive")
    if args.port < 1 or args.port > 65533:
        raise SystemExit("--port must be between 1 and 65533")

    selected_modes = set(args.modes)
    modes = tuple(
        entry
        for entry in (
        ("listen", args.map, args.port),
        ("dedicated", args.map, args.port + 1),
        ("demo", args.demo, 0),
        )
        if entry[0] in selected_modes
    )
    results: list[dict[str, object]] = []

    def write_report(status: str, failure: str = "") -> dict[str, object]:
        report = {
            "schema": 1,
            "status": status,
            "game": args.game,
            "map": args.map,
            "demo": args.demo,
            "frames_per_mode": args.frames,
            "requested_modes": [mode for mode, _target, _port in modes],
            "retail_data_committed": False,
            "notes": [
                "Snapshots are taken after forced GC at phase-equivalent boundaries.",
                "Headless listen/dedicated/demo modes intentionally disable waveOut; "
                "audio queue and channel counts must remain zero.",
                "Win32 process handles and MiniLang heap, Edict/entity, QSocket, "
                "protocol queue, UDP endpoint, particle, and temp-entity counts are measured.",
            ],
            "modes": results,
        }
        if failure:
            report["failure"] = failure
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        return report

    write_report("running")
    for mode, target, port in modes:
        print(f"[long-soak] {mode}: {args.frames} frames", flush=True)
        try:
            results.append(
                run_mode(
                    executable,
                    basedir,
                    args.game,
                    mode,
                    target,
                    args.frames,
                    port,
                    args.timeout,
                )
            )
        except (RuntimeError, subprocess.TimeoutExpired) as error:
            write_report("failed", str(error))
            raise
        write_report("running")

    report = write_report("passed")
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.TimeoutExpired as error:
        print(f"long soak timed out after {error.timeout} seconds", file=sys.stderr)
        raise SystemExit(2) from error
    except RuntimeError as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(2) from error
