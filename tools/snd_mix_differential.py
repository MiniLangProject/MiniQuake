#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/snd_mix.c."""

from __future__ import annotations

import argparse
import ctypes
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
REFERENCE = ROOT / "reference" / "quake"
PATCH = ROOT / "reference" / "patches" / "snd_mix_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "snd_mix_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "snd_mix_oracle.def"
FIXTURE = ROOT / "tests" / "snd_mix_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "snd_mix_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"


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


def verify_reference() -> None:
    run([sys.executable, str(VERIFY_REFERENCE), "--quiet"])


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
                str(REFERENCE),
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
            str(REFERENCE),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])

    source_obj = output / "snd_mix_pinned.obj"
    driver_obj = output / "snd_mix_pinned_driver.obj"
    dll = output / "snd_mix_oracle.dll"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/wd4101",
        "/wd4244",
        "/wd4706",
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
            str(worktree / "WinQuake" / "snd_mix.c"),
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
    library.mix_reset.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int]
    library.mix_set_paint.argtypes = [
        ctypes.c_int,
        ctypes.c_int,
        ctypes.c_int,
    ]
    library.mix_dma_i16.argtypes = [ctypes.c_int]
    library.mix_dma_i16.restype = ctypes.c_int
    library.mix_dma_u8.argtypes = [ctypes.c_int]
    library.mix_dma_u8.restype = ctypes.c_int
    library.mix_setup_blast.argtypes = []
    library.mix_scale_value.argtypes = [ctypes.c_int, ctypes.c_int]
    library.mix_scale_value.restype = ctypes.c_int
    library.mix_paint8.argtypes = []
    library.mix_paint8.restype = ctypes.c_int
    library.mix_paint16.argtypes = []
    library.mix_paint16.restype = ctypes.c_int
    library.mix_setup_channels.argtypes = []
    library.mix_channel_active.argtypes = []
    library.mix_channel_active.restype = ctypes.c_int
    library.mix_painted_time.argtypes = []
    library.mix_painted_time.restype = ctypes.c_int
    library.mix_paint_value.argtypes = [ctypes.c_int]
    library.mix_paint_value.restype = ctypes.c_int
    library.Snd_WriteLinearBlastStereo16.argtypes = []
    library.S_TransferStereo16.argtypes = [ctypes.c_int]
    library.S_TransferPaintBuffer.argtypes = [ctypes.c_int]
    library.S_PaintChannels.argtypes = [ctypes.c_int]
    library.SND_InitScaletable.argtypes = []


def dma_i16(library: ctypes.WinDLL, count: int) -> list[int]:
    return [library.mix_dma_i16(index) for index in range(count)]


def paint_values(library: ctypes.WinDLL, count: int) -> list[int]:
    return [library.mix_paint_value(index) for index in range(count)]


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []

    library.mix_reset(16, 2, 8)
    library.SND_InitScaletable()
    events.append(
        {
            "function": "SND_InitScaletable",
            "case": "values",
            "values": [
                library.mix_scale_value(31, 255),
                library.mix_scale_value(16, 128),
                library.mix_scale_value(1, 1),
            ],
        }
    )

    library.mix_reset(16, 2, 8)
    library.mix_setup_blast()
    library.Snd_WriteLinearBlastStereo16()
    events.append(
        {
            "function": "Snd_WriteLinearBlastStereo16",
            "case": "clamp",
            "values": dma_i16(library, 4),
        }
    )

    library.mix_reset(16, 2, 8)
    library.mix_set_paint(0, 1000, -1000)
    library.mix_set_paint(1, 2000, -2000)
    library.S_TransferStereo16(2)
    events.append(
        {
            "function": "S_TransferStereo16",
            "case": "two",
            "written": 2,
            "values": dma_i16(library, 4),
        }
    )

    library.mix_reset(8, 1, 8)
    library.mix_set_paint(0, 256, 0)
    library.mix_set_paint(1, -256, 0)
    library.S_TransferPaintBuffer(2)
    events.append(
        {
            "function": "S_TransferPaintBuffer",
            "case": "mono8",
            "written": 2,
            "values": [library.mix_dma_u8(index) for index in range(2)],
        }
    )

    library.mix_reset(16, 2, 8)
    position8 = library.mix_paint8()
    events.append(
        {
            "function": "SND_PaintChannelFrom8",
            "case": "three",
            "position": position8,
            "values": paint_values(library, 6),
        }
    )

    library.mix_reset(16, 2, 8)
    position16 = library.mix_paint16()
    events.append(
        {
            "function": "SND_PaintChannelFrom16",
            "case": "three",
            "position": position16,
            "values": paint_values(library, 6),
        }
    )

    library.mix_reset(16, 2, 8)
    library.mix_setup_channels()
    library.S_PaintChannels(4)
    events.append(
        {
            "function": "S_PaintChannels",
            "case": "one-channel",
            "painted": library.mix_painted_time(),
            "active": library.mix_channel_active(),
            "values": dma_i16(library, 4),
        }
    )

    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(
    compiler: Path, output: Path, destination: Path
) -> None:
    executable = output / "snd_mix_minilang.exe"
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
        run([str(executable)], capture=True),
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
        raise RuntimeError(
            f"manifest functions lack events: {sorted(expected - observed)}"
        )


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
        default=ROOT / "build" / "snd_mix_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    verify_reference()
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
            "1",
        ]
    )
    verify_reference()
    print("snd_mix differential: PASS (7 JSONL events, epsilon=1 PCM LSB)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
