#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/snd_mem.c."""

from __future__ import annotations

import argparse
import ctypes
import importlib.util
import json
from pathlib import Path
import shutil
import struct
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
PATCH = ROOT / "reference" / "patches" / "snd_mem_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "snd_mem_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "snd_mem_oracle.def"
FIXTURE = ROOT / "tests" / "snd_mem_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "snd_mem_differential_manifest.json"


class WaveInfo(ctypes.Structure):
    _fields_ = [
        ("rate", ctypes.c_int),
        ("width", ctypes.c_int),
        ("channels", ctypes.c_int),
        ("loopstart", ctypes.c_int),
        ("samples", ctypes.c_int),
        ("dataofs", ctypes.c_int),
    ]


class SoundCache(ctypes.Structure):
    _fields_ = [
        ("length", ctypes.c_int),
        ("loopstart", ctypes.c_int),
        ("speed", ctypes.c_int),
        ("width", ctypes.c_int),
        ("stereo", ctypes.c_int),
        ("data", ctypes.c_ubyte * 512),
    ]


def wave_bytes() -> bytes:
    data = bytearray(48)
    struct.pack_into("<4sI4s", data, 0, b"RIFF", 40, b"WAVE")
    struct.pack_into(
        "<4sIHHIIHH",
        data,
        12,
        b"fmt ",
        16,
        1,
        1,
        11025,
        11025,
        1,
        8,
    )
    struct.pack_into("<4sI4B", data, 36, b"data", 4, 128, 129, 130, 131)
    return bytes(data)


def load_build_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("miniquake_build_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, cwd: Path = ROOT, capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if result.stdout is not None else ""


def build_oracle(output: Path) -> Path:
    tools = load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    if not msvcrt.exists():
        raise RuntimeError(
            "native/build/msvcrt.lib is missing; run native/build_bridge.py first"
        )
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(ROOT / "reference" / "quake"),
                "worktree",
                "remove",
                "--force",
                str(worktree),
            ]
        )
    run(
        [
            "git",
            "-C",
            str(ROOT / "reference" / "quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "snd_mem_pinned.obj"
    driver_obj = output / "snd_mem_pinned_driver.obj"
    dll = output / "snd_mem_oracle.dll"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/GS-",
        "/Zl",
        "/fp:precise",
        "/O2",
        "/Gy",
        "/DMINIQUAKE_PINNED_ORACLE",
        f"/I{STUB_INCLUDE}",
    ]
    run(
        common
        + [
            f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "snd_mem.c"),
        ]
    )
    run(common + [f"/Fo{driver_obj}", str(DRIVER)])
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/dynamicbase",
            "/nxcompat",
            "/opt:ref",
            f"/def:{DEFINITION}",
            f"/out:{dll}",
            str(source_obj),
            str(driver_obj),
            str(msvcrt),
        ]
    )
    return dll


def configure(library: ctypes.WinDLL) -> None:
    library.snd_mem_fixture_reset.argtypes = []
    library.snd_mem_wave.argtypes = []
    library.snd_mem_wave.restype = ctypes.POINTER(ctypes.c_ubyte)
    library.snd_mem_set_cursor.argtypes = [ctypes.c_int]
    library.snd_mem_cursor_offset.argtypes = []
    library.snd_mem_cursor_offset.restype = ctypes.c_int
    library.snd_mem_set_chunks.argtypes = [ctypes.c_int, ctypes.c_int]
    library.snd_mem_chunk_offset.argtypes = []
    library.snd_mem_chunk_offset.restype = ctypes.c_int
    library.snd_mem_chunk_length.argtypes = []
    library.snd_mem_chunk_length.restype = ctypes.c_int
    library.snd_mem_dump_count.argtypes = []
    library.snd_mem_dump_count.restype = ctypes.c_int
    library.GetLittleShort.argtypes = []
    library.GetLittleShort.restype = ctypes.c_short
    library.GetLittleLong.argtypes = []
    library.GetLittleLong.restype = ctypes.c_int
    library.FindNextChunk.argtypes = [ctypes.c_char_p]
    library.FindChunk.argtypes = [ctypes.c_char_p]
    library.GetWavinfo.argtypes = [
        ctypes.c_char_p,
        ctypes.POINTER(ctypes.c_ubyte),
        ctypes.c_int,
    ]
    library.GetWavinfo.restype = WaveInfo
    library.snd_mem_resample.argtypes = []
    library.snd_mem_resample.restype = ctypes.POINTER(SoundCache)
    library.snd_mem_load.argtypes = []
    library.snd_mem_load.restype = ctypes.POINTER(SoundCache)
    library.snd_mem_load_again.argtypes = []
    library.snd_mem_load_again.restype = ctypes.POINTER(SoundCache)


def cache_event(
    function: str,
    case: str,
    cache: SoundCache,
    cached: int,
) -> dict[str, object]:
    return {
        "function": function,
        "case": case,
        "length": cache.length,
        "loopstart": cache.loopstart,
        "speed": cache.speed,
        "width": cache.width,
        "stereo": cache.stereo,
        "values": [cache.data[index] for index in range(8)],
        "cached": cached,
    }


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    library.snd_mem_fixture_reset()
    events: list[dict[str, object]] = []
    library.snd_mem_set_cursor(20)
    events.append(
        {
            "function": "GetLittleShort",
            "case": "format",
            "value": library.GetLittleShort(),
            "position": library.snd_mem_cursor_offset(),
        }
    )
    library.snd_mem_set_cursor(24)
    events.append(
        {
            "function": "GetLittleLong",
            "case": "rate",
            "value": library.GetLittleLong(),
            "position": library.snd_mem_cursor_offset(),
        }
    )
    library.snd_mem_set_chunks(12, 12)
    library.FindNextChunk(b"data")
    events.append(
        {
            "function": "FindNextChunk",
            "case": "data",
            "offset": library.snd_mem_chunk_offset(),
            "length": library.snd_mem_chunk_length(),
        }
    )
    library.snd_mem_set_chunks(12, 12)
    library.FindChunk(b"fmt ")
    events.append(
        {
            "function": "FindChunk",
            "case": "fmt",
            "offset": library.snd_mem_chunk_offset(),
            "length": library.snd_mem_chunk_length(),
        }
    )
    library.snd_mem_set_chunks(12, 12)
    events.append(
        {
            "function": "DumpChunks",
            "case": "two",
            "count": library.snd_mem_dump_count(),
        }
    )
    wave = library.snd_mem_wave()
    info = library.GetWavinfo(b"test.wav", wave, 48)
    events.append(
        {
            "function": "GetWavinfo",
            "case": "pcm",
            "values": [
                info.rate,
                info.width,
                info.channels,
                info.loopstart,
                info.samples,
                info.dataofs,
            ],
        }
    )
    resampled = library.snd_mem_resample().contents
    events.append(cache_event("ResampleSfx", "double-rate", resampled, 0))
    loaded_pointer = library.snd_mem_load()
    loaded_again = library.snd_mem_load_again()
    events.append(
        cache_event(
            "S_LoadSound",
            "file-cache",
            loaded_pointer.contents,
            1 if ctypes.addressof(loaded_pointer.contents)
            == ctypes.addressof(loaded_again.contents)
            else 0,
        )
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "snd_mem_minilang.exe"
    basedir = output / "game"
    sound_dir = basedir / "id1" / "sound"
    sound_dir.mkdir(parents=True, exist_ok=True)
    (sound_dir / "test.wav").write_bytes(wave_bytes())
    shutil.copy2(
        ROOT / "native" / "miniquake_native.dll",
        output / "miniquake_native.dll",
    )
    run(
        [
            sys.executable,
            str(compiler),
            str(FIXTURE),
            str(executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "40",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(
        run([str(executable), str(basedir)], capture=True),
        encoding="utf-8",
        newline="\n",
    )


def validate_manifest(reference: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"manifest expects {manifest['events']} events, observed {len(events)}"
        )
    observed = {event["function"] for event in events}
    expected = {
        item["name"]
        for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    if expected - observed:
        raise RuntimeError(f"manifest functions lack events: {sorted(expected - observed)}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build" / "snd_mem_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    run_oracle(build_oracle(args.output), reference)
    build_and_run_minilang(args.compiler.resolve(), args.output, candidate)
    validate_manifest(reference)
    run(
        [
            sys.executable,
            str(ROOT / "tools" / "parity_oracle.py"),
            "compare-traces",
            str(reference),
            str(candidate),
            "--epsilon",
            "1e-5",
        ]
    )
    print("snd_mem differential: PASS (8 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
