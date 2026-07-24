#!/usr/bin/env python3
"""Run a bounded, headless MiniQuake smoke test for every installed retail map.

Only PAK directory records and the BSP entity lumps are read by this tool.
Retail payloads are never extracted or copied into the repository.  BSPs
without a player start are reported as non-level model assets; every playable
level is launched through MiniQuake's integrated host.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import re
import struct
import subprocess
import time


BSP_HEADER_SIZE = 4 + 15 * 8
PLAYER_START = re.compile(
    rb'"classname"\s+"(?:info_player_start|info_player_deathmatch)"',
    re.IGNORECASE,
)


@dataclass(frozen=True)
class Entry:
    container: Path
    offset: int
    size: int
    loose: bool = False

    def read_prefix(self, size: int) -> bytes:
        with self.container.open("rb") as stream:
            if not self.loose:
                stream.seek(self.offset)
            return stream.read(min(size, self.size))

    def read_range(self, offset: int, size: int) -> bytes:
        if offset < 0 or size < 0 or offset + size > self.size:
            raise RuntimeError(
                f"entry range {offset}+{size} exceeds {self.size} bytes in "
                f"{self.container}"
            )
        with self.container.open("rb") as stream:
            stream.seek((0 if self.loose else self.offset) + offset)
            data = stream.read(size)
        if len(data) != size:
            raise RuntimeError(f"truncated data in {self.container}")
        return data


def pak_sort_key(path: Path) -> tuple[int, str]:
    match = re.fullmatch(r"pak(\d+)\.pak", path.name, re.IGNORECASE)
    return (int(match.group(1)) if match else 2**31 - 1, path.name.lower())


def pak_entries(path: Path) -> dict[str, Entry]:
    file_size = path.stat().st_size
    with path.open("rb") as stream:
        header = stream.read(12)
        if len(header) != 12 or header[:4] != b"PACK":
            raise RuntimeError(f"not a Quake PAK: {path}")
        directory_offset, directory_size = struct.unpack_from("<ii", header, 4)
        if (
            directory_offset < 0
            or directory_size < 0
            or directory_size % 64
            or directory_offset + directory_size > file_size
        ):
            raise RuntimeError(f"invalid PAK directory: {path}")
        stream.seek(directory_offset)
        directory = stream.read(directory_size)
    if len(directory) != directory_size:
        raise RuntimeError(f"truncated PAK directory: {path}")

    entries: dict[str, Entry] = {}
    for position in range(0, directory_size, 64):
        record = directory[position : position + 64]
        raw_name = record[:56].split(b"\0", 1)[0]
        name = raw_name.decode("ascii", errors="strict").replace("\\", "/").lower()
        offset, size = struct.unpack_from("<ii", record, 56)
        if offset < 0 or size < 0 or offset + size > file_size:
            raise RuntimeError(f"invalid entry {name!r} in {path}")
        entries[name] = Entry(path, offset, size)
    return entries


def game_entries(game_dir: Path) -> tuple[dict[str, Entry], list[str]]:
    entries: dict[str, Entry] = {}
    pak_names: list[str] = []

    # Quake mounts sequential PAKs with the highest numbered archive taking
    # precedence. Assignment in ascending order reproduces that lookup result.
    for pak_path in sorted(game_dir.glob("pak*.pak"), key=pak_sort_key):
        entries.update(pak_entries(pak_path))
        pak_names.append(pak_path.name)

    # Loose files override archives.
    loose_maps = game_dir / "maps"
    if loose_maps.is_dir():
        for path in sorted(loose_maps.glob("*.bsp")):
            entries[f"maps/{path.name.lower()}"] = Entry(
                path, 0, path.stat().st_size, loose=True
            )
    return entries, pak_names


def bsp_has_player_start(entry: Entry) -> bool:
    header = entry.read_prefix(BSP_HEADER_SIZE)
    if len(header) < BSP_HEADER_SIZE:
        raise RuntimeError(f"truncated BSP header in {entry.container}")
    version = struct.unpack_from("<i", header, 0)[0]
    if version != 29:
        raise RuntimeError(f"unsupported BSP version {version} in {entry.container}")
    entity_offset, entity_size = struct.unpack_from("<ii", header, 4)
    entities = entry.read_range(entity_offset, entity_size)
    return PLAYER_START.search(entities) is not None


def smoke_map(
    executable: Path,
    basedir: Path,
    game: str,
    map_name: str,
    frames: int,
    timeout: float,
) -> dict[str, object]:
    command = [
        str(executable),
        "--runtime-smoke",
        str(basedir),
        map_name,
        str(frames),
        "-game",
        game,
    ]
    started = time.monotonic()
    try:
        completed = subprocess.run(
            command,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
        elapsed = time.monotonic() - started
        passed = (
            completed.returncode == 0
            and "MiniQuake runtime smoke: PASS" in completed.stdout
            and "signon=4" in completed.stdout
        )
        result: dict[str, object] = {
            "map": map_name,
            "passed": passed,
            "returncode": completed.returncode,
            "seconds": round(elapsed, 3),
        }
        if not passed:
            result["output"] = completed.stdout
        return result
    except subprocess.TimeoutExpired as error:
        output = error.stdout or ""
        if isinstance(output, bytes):
            output = output.decode(errors="replace")
        return {
            "map": map_name,
            "passed": False,
            "returncode": None,
            "seconds": round(time.monotonic() - started, 3),
            "output": output,
            "error": f"timeout after {timeout:g} seconds",
        }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument(
        "--games", nargs="+", default=["id1", "hipnotic", "rogue"]
    )
    parser.add_argument("--frames", type=int, default=12)
    parser.add_argument("--timeout", type=float, default=60.0)
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--resume",
        action="store_true",
        help="reuse passing entries from --output and retry only failed maps",
    )
    args = parser.parse_args()

    executable = args.exe.resolve()
    basedir = args.basedir.resolve()
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    if not basedir.is_dir():
        raise SystemExit(f"retail basedir not found: {basedir}")
    if args.frames < 1:
        raise SystemExit("--frames must be positive")

    resumed: dict[tuple[str, str], dict[str, object]] = {}
    if args.resume:
        if args.output is None or not args.output.is_file():
            raise SystemExit("--resume requires an existing --output report")
        previous = json.loads(args.output.read_text(encoding="utf-8"))
        if Path(previous.get("executable", "")).resolve() != executable:
            raise SystemExit("resume report was produced by a different executable")
        if Path(previous.get("basedir", "")).resolve() != basedir:
            raise SystemExit("resume report used a different retail basedir")
        if previous.get("frames_per_map") != args.frames:
            raise SystemExit("resume report used a different frame count")
        for old_game in previous.get("games", []):
            game_name = old_game.get("game")
            for old_result in old_game.get("results", []):
                if old_result.get("passed"):
                    resumed[(game_name, old_result.get("map"))] = old_result

    games: list[dict[str, object]] = []
    total_bsp = 0
    total_levels = 0
    total_passed = 0
    for game in args.games:
        game_dir = basedir / game
        if not game_dir.is_dir():
            raise SystemExit(f"retail game directory not found: {game_dir}")
        entries, pak_names = game_entries(game_dir)
        maps = {
            Path(name).stem: entry
            for name, entry in entries.items()
            if name.startswith("maps/") and name.endswith(".bsp")
        }
        if not maps:
            raise SystemExit(f"no BSPs found in {game_dir}")

        playable: list[str] = []
        non_level_assets: list[dict[str, str]] = []
        for map_name, entry in sorted(maps.items()):
            if bsp_has_player_start(entry):
                playable.append(map_name)
            else:
                non_level_assets.append(
                    {
                        "map": map_name,
                        "reason": "BSP contains no player start",
                    }
                )

        print(
            f"{game}: {len(maps)} BSPs, {len(playable)} playable levels, "
            f"{len(non_level_assets)} non-level BSP assets",
            flush=True,
        )
        results: list[dict[str, object]] = []
        for index, map_name in enumerate(playable, 1):
            old_result = resumed.get((game, map_name))
            if old_result is not None:
                result = dict(old_result)
                result["reused"] = True
            else:
                result = smoke_map(
                    executable, basedir, game, map_name, args.frames, args.timeout
                )
            results.append(result)
            state = "PASS" if result["passed"] else "FAIL"
            suffix = ", reused" if result.get("reused") else ""
            print(
                f"  [{index:02d}/{len(playable):02d}] {state} "
                f"{map_name} ({result['seconds']}s{suffix})",
                flush=True,
            )

        passed = sum(bool(result["passed"]) for result in results)
        total_bsp += len(maps)
        total_levels += len(playable)
        total_passed += passed
        games.append(
            {
                "game": game,
                "pak_files": pak_names,
                "bsp_count": len(maps),
                "playable_level_count": len(playable),
                "non_level_asset_count": len(non_level_assets),
                "non_level_assets": non_level_assets,
                "passed": passed,
                "failed": len(results) - passed,
                "results": results,
            }
        )

    report = {
        "status": "passed" if total_passed == total_levels else "failed",
        "executable": str(executable),
        "basedir": str(basedir),
        "frames_per_map": args.frames,
        "summary": {
            "games": len(games),
            "bsp_count": total_bsp,
            "playable_level_count": total_levels,
            "non_level_asset_count": total_bsp - total_levels,
            "passed": total_passed,
            "failed": total_levels - total_passed,
        },
        "games": games,
    }
    encoded = json.dumps(report, indent=2) + "\n"
    if args.output:
        output = args.output.resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(encoded, encoding="utf-8")
        print(f"report: {output}")
    print(
        f"summary: {total_passed}/{total_levels} playable levels passed; "
        f"{total_bsp - total_levels} non-level BSP assets classified"
    )
    return 0 if report["status"] == "passed" else 2


if __name__ == "__main__":
    raise SystemExit(main())
