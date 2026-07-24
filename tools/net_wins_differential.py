#!/usr/bin/env python3
"""Pinned WinQuake/net_wins.c differential with deterministic Winsock stubs."""

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
PIN = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
FUNCTIONS = [
    "BlockingHook",
    "WINS_GetLocalAddress",
    "WINS_Init",
    "WINS_Shutdown",
    "WINS_Listen",
    "WINS_OpenSocket",
    "WINS_CloseSocket",
    "PartialIPAddress",
    "WINS_Connect",
    "WINS_CheckNewConnections",
    "WINS_Read",
    "WINS_MakeSocketBroadcastCapable",
    "WINS_Broadcast",
    "WINS_Write",
    "WINS_AddrToString",
    "WINS_StringToAddr",
    "WINS_GetSocketAddr",
    "WINS_GetNameFromAddr",
    "WINS_GetAddrFromName",
    "WINS_AddrCompare",
    "WINS_GetSocketPort",
    "WINS_SetSocketPort",
]


def bridge():
    path = ROOT / "native/build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout or ""


def build(output: Path) -> Path:
    tools = bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, librarian = tools
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(ROOT / "reference/quake"),
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
            str(ROOT / "reference/quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PIN,
        ]
    )
    run(
        [
            "git",
            "-C",
            str(worktree),
            "apply",
            str(ROOT / "reference/patches/net_wins_pinned_oracle.patch"),
        ]
    )
    source = output / "net_wins_pinned.obj"
    driver = output / "net_wins_pinned_driver.obj"
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
        f"/I{ROOT / 'reference/harness'}",
    ]
    run(common + [f"/Fo{source}", str(worktree / "WinQuake/net_wins.c")])
    run(common + [f"/Fo{driver}", str(ROOT / "reference/harness/net_wins_pinned_driver.c")])
    extra_msvcrt = output / "net_wins_msvcrt_extra.lib"
    run(
        [
            librarian,
            "/nologo",
            "/machine:x64",
            f"/def:{ROOT / 'reference/harness/net_wins_msvcrt_extra.def'}",
            f"/out:{extra_msvcrt}",
        ]
    )
    dll = output / "net_wins_oracle.dll"
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
            f"/def:{ROOT / 'reference/harness/net_wins_oracle.def'}",
            f"/out:{dll}",
            str(source),
            str(driver),
            str(ROOT / "native/build/msvcrt.lib"),
            str(extra_msvcrt),
        ]
    )
    return dll


def oracle(dll: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll))
    function = library.net_wins_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler: Path, output: Path, destination: Path) -> Path:
    executable = output / "net_wins_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests/net_wins_differential_fixture.ml"),
            str(executable),
            "-I",
            str(ROOT),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "100",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(run([str(executable)], True), encoding="utf-8", newline="\n")
    return executable


def read_events(path: Path) -> list[dict[str, object]]:
    return [
        json.loads(line)
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def fatal_processes(dll: Path, executable: Path) -> None:
    cases = [
        ("WINS_Listen", 0, "--error-listen"),
        ("WINS_Broadcast", 1, "--error-broadcast"),
        ("WINS_Init", 2, "--error-ip"),
        ("WINS_OpenSocket", 3, "--error-bind"),
    ]
    for name, mode, argument in cases:
        code = (
            "import ctypes; "
            f"d=ctypes.WinDLL(r'{dll}'); "
            "d.net_wins_error_case.argtypes=[ctypes.c_int]; "
            f"d.net_wins_error_case({mode})"
        )
        reference = subprocess.run(
            [sys.executable, "-c", code],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        mini = subprocess.run(
            [str(executable), argument],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if reference.returncode == 0 or mini.returncode != 42:
            raise RuntimeError(
                f"{name} fatal mismatch: reference={reference.returncode}, "
                f"minilang={mini.returncode}"
            )
        print(
            f"net_wins {name} fatal differential: PASS "
            f"(reference={reference.returncode}, minilang=42)"
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy/mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build/net_wins_differential",
    )
    parser.add_argument("--oracle-only", action="store_true")
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)
    reference = output / "reference.jsonl"
    dll = build(output)
    oracle(dll, reference)
    if args.oracle_only:
        print(reference.read_text(encoding="utf-8"), end="")
        return 0

    minilang = output / "minilang.jsonl"
    executable = candidate(args.compiler.resolve(), output, minilang)
    left_events = read_events(reference)
    right_events = read_events(minilang)
    if left_events != right_events:
        for index in range(max(len(left_events), len(right_events))):
            left = left_events[index] if index < len(left_events) else None
            right = right_events[index] if index < len(right_events) else None
            if left != right:
                raise RuntimeError(
                    f"net_wins event {index} mismatch:\n"
                    f"reference={left!r}\nminilang={right!r}"
                )
    covered = {event["function"] for event in left_events}
    missing = [name for name in FUNCTIONS if name not in covered]
    if missing:
        raise RuntimeError(f"net_wins target bodies without events: {missing}")
    fatal_processes(dll, executable)
    print(
        f"net_wins pinned differential: PASS "
        f"({len(left_events)} events, {len(covered)}/{len(FUNCTIONS)} bodies)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
