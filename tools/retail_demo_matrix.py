#!/usr/bin/env python3
"""Replay every retail Quake demo through MiniQuake's Protocol-15 client.

The caller supplies locally installed game data. Demo entries are extracted
only into a TemporaryDirectory and are never copied into the repository.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import struct
import subprocess
import tempfile


def pack_entries(path: Path) -> list[tuple[str, bytes]]:
    data = path.read_bytes()
    if len(data) < 12 or data[:4] != b"PACK":
        raise RuntimeError(f"not a Quake PAK: {path}")
    directory_offset, directory_size = struct.unpack_from("<ii", data, 4)
    if directory_offset < 0 or directory_size < 0 or directory_size % 64:
        raise RuntimeError(f"invalid PAK directory: {path}")
    if directory_offset + directory_size > len(data):
        raise RuntimeError(f"truncated PAK directory: {path}")

    entries: list[tuple[str, bytes]] = []
    for position in range(directory_offset, directory_offset + directory_size, 64):
        raw_name = data[position : position + 56].split(b"\0", 1)[0]
        name = raw_name.decode("ascii", errors="strict").replace("\\", "/").lower()
        offset, size = struct.unpack_from("<ii", data, position + 56)
        if offset < 0 or size < 0 or offset + size > len(data):
            raise RuntimeError(f"invalid entry {name!r} in {path}")
        if name.endswith(".dem"):
            entries.append((name, data[offset : offset + size]))
    return entries


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--timeout", type=float, default=30.0)
    args = parser.parse_args()

    executable = args.exe.resolve()
    game_dir = (args.basedir.resolve() / args.game)
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    if not game_dir.is_dir():
        raise SystemExit(f"retail game directory not found: {game_dir}")

    # Later PAKs override earlier ones in Quake's search path.
    demos: dict[str, bytes] = {}
    for pak_path in sorted(game_dir.glob("pak*.pak")):
        for name, payload in pack_entries(pak_path):
            demos[name] = payload
    for demo_path in sorted(game_dir.glob("*.dem")):
        demos[demo_path.name.lower()] = demo_path.read_bytes()
    if not demos:
        raise SystemExit(f"no retail demos found in {game_dir}")

    results: list[dict[str, object]] = []
    with tempfile.TemporaryDirectory(prefix="miniquake-demos-") as temporary:
        target_dir = Path(temporary)
        for name, payload in sorted(demos.items()):
            target = target_dir / Path(name).name
            target.write_bytes(payload)
            completed = subprocess.run(
                [str(executable), "--demo-verify", str(target)],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                timeout=args.timeout,
                check=False,
            )
            passed = completed.returncode == 0 and "OK   parsed " in completed.stdout
            results.append(
                {
                    "name": name,
                    "bytes": len(payload),
                    "passed": passed,
                }
            )
            if not passed:
                raise RuntimeError(
                    f"demo replay failed for {name} (exit {completed.returncode})\n"
                    + completed.stdout
                )

    print(
        json.dumps(
            {
                "status": "passed",
                "game": args.game,
                "demos": results,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
