#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/wad.c."""

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
PATCH = ROOT / "reference" / "patches" / "wad_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "wad_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "wad_oracle.def"
FIXTURE = ROOT / "tests" / "wad_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "wad_differential_manifest.json"


class LumpInfo(ctypes.Structure):
    _fields_ = [
        ("filepos", ctypes.c_int),
        ("disksize", ctypes.c_int),
        ("size", ctypes.c_int),
        ("type", ctypes.c_byte),
        ("compression", ctypes.c_byte),
        ("pad1", ctypes.c_byte),
        ("pad2", ctypes.c_byte),
        ("name", ctypes.c_char * 16),
    ]


class QPic(ctypes.Structure):
    _fields_ = [
        ("width", ctypes.c_int),
        ("height", ctypes.c_int),
        ("data", ctypes.c_ubyte * 4),
    ]


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


def fixture_bytes() -> bytes:
    data = bytearray(128)
    struct.pack_into("<4sii", data, 0, b"WAD2", 2, 64)
    data[16:20] = bytes((1, 2, 3, 4))
    struct.pack_into("<ii", data, 24, 320, 200)
    struct.pack_into(
        "<iiiBBBB16s",
        data,
        64,
        16,
        4,
        4,
        64,
        0,
        0,
        0,
        b"FiRsT\0",
    )
    struct.pack_into(
        "<iiiBBBB16s",
        data,
        96,
        24,
        8,
        8,
        66,
        0,
        0,
        0,
        b"PiCtUrE\0",
    )
    return bytes(data)


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
    source_obj = output / "wad_pinned.obj"
    driver_obj = output / "wad_pinned_driver.obj"
    dll = output / "wad_oracle.dll"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/GS-",
        "/Zl",
        "/O2",
        "/Gy",
        "/DMINIQUAKE_PINNED_ORACLE",
        f"/I{STUB_INCLUDE}",
    ]
    run(
        common
        + [
            f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "wad.c"),
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
    library.W_CleanupName.argtypes = [ctypes.c_char_p, ctypes.c_void_p]
    library.W_LoadWadFile.argtypes = [ctypes.c_char_p]
    library.W_GetLumpinfo.argtypes = [ctypes.c_char_p]
    library.W_GetLumpinfo.restype = ctypes.POINTER(LumpInfo)
    library.W_GetLumpName.argtypes = [ctypes.c_char_p]
    library.W_GetLumpName.restype = ctypes.c_void_p
    library.W_GetLumpNum.argtypes = [ctypes.c_int]
    library.W_GetLumpNum.restype = ctypes.c_void_p
    library.SwapPic.argtypes = [ctypes.POINTER(QPic)]
    library.wad_set_fixture_data.argtypes = [ctypes.c_void_p]


def clean_name(raw: bytes) -> str:
    return raw.split(b"\0", 1)[0].decode("ascii")


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []
    output = ctypes.create_string_buffer(16)
    library.W_CleanupName(b"MiXeD_NAME_123456789", output)
    events.append(
        {
            "function": "W_CleanupName",
            "case": "mixed",
            "values": list(output.raw),
        }
    )

    raw = fixture_bytes()
    fixture = ctypes.create_string_buffer(raw, len(raw))
    library.wad_set_fixture_data(fixture)
    library.W_LoadWadFile(b"fixture.wad")
    count = ctypes.c_int.in_dll(library, "wad_numlumps").value
    lumps_pointer = ctypes.POINTER(LumpInfo).in_dll(library, "wad_lumps")
    events.append(
        {
            "function": "W_LoadWadFile",
            "case": "fixture",
            "count": count,
            "first": clean_name(bytes(lumps_pointer[0].name)),
            "second": clean_name(bytes(lumps_pointer[1].name)),
        }
    )

    info = library.W_GetLumpinfo(b"FIRST").contents
    events.append(
        {
            "function": "W_GetLumpinfo",
            "case": "first",
            "filepos": info.filepos,
            "disksize": info.disksize,
            "size": info.size,
            "type": info.type,
            "name": clean_name(bytes(info.name)),
        }
    )
    first = ctypes.string_at(library.W_GetLumpName(b"FiRsT"), 4)
    events.append(
        {"function": "W_GetLumpName", "case": "first", "values": list(first)}
    )
    picture = ctypes.string_at(library.W_GetLumpNum(1), 8)
    events.append(
        {"function": "W_GetLumpNum", "case": "picture", "values": list(picture)}
    )
    qpic = QPic(64, 32, (ctypes.c_ubyte * 4)())
    library.SwapPic(ctypes.byref(qpic))
    events.append(
        {
            "function": "SwapPic",
            "case": "header",
            "width": qpic.width,
            "height": qpic.height,
        }
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "wad_minilang.exe"
    fixture_path = output / "fixture.wad"
    fixture_path.write_bytes(fixture_bytes())
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
            "30",
        ]
    )
    destination.write_text(
        run([str(executable), str(fixture_path)], capture=True),
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
        default=ROOT / "build" / "wad_differential",
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
            "0",
        ]
    )
    print("wad differential: PASS (6 JSONL events, exact)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
