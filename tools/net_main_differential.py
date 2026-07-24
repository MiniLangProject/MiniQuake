#!/usr/bin/env python3
"""Pinned WinQuake/net_main.c differential, including isolated fatal paths."""

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
FUNCTIONS = [
    "SetNetTime",
    "NET_NewQSocket",
    "NET_FreeQSocket",
    "NET_Listen_f",
    "MaxPlayers_f",
    "NET_Port_f",
    "PrintSlistHeader",
    "PrintSlist",
    "PrintSlistTrailer",
    "NET_Slist_f",
    "Slist_Send",
    "Slist_Poll",
    "NET_Connect",
    "NET_CheckNewConnections",
    "NET_Close",
    "NET_GetMessage",
    "NET_SendMessage",
    "NET_SendUnreliableMessage",
    "NET_CanSendMessage",
    "NET_SendToAll",
    "NET_Init",
    "NET_Shutdown",
    "NET_Poll",
    "SchedulePollProcedure",
]


def load_build_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("miniquake_build_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout or ""


def build_oracle(output: Path) -> Path:
    tools = load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
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
    run(
        [
            "git",
            "-C",
            str(worktree),
            "apply",
            str(ROOT / "reference/patches/net_main_pinned_oracle.patch"),
        ]
    )
    source = output / "net_main_pinned.obj"
    driver = output / "net_main_pinned_driver.obj"
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
    run(
        common
        + [
            f"/Fo{source}",
            str(worktree / "WinQuake/net_main.c"),
        ]
    )
    run(
        common
        + [
            f"/Fo{driver}",
            str(ROOT / "reference/harness/net_main_pinned_driver.c"),
        ]
    )
    dll = output / "net_main_oracle.dll"
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
            f"/def:{ROOT / 'reference/harness/net_main_oracle.def'}",
            f"/out:{dll}",
            str(source),
            str(driver),
            str(ROOT / "native/build/msvcrt.lib"),
        ]
    )
    return dll


def oracle(dll: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll))
    function = library.net_main_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler: Path, output: Path, destination: Path) -> Path:
    executable = output / "net_main_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests/net_main_differential_fixture.ml"),
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
    destination.write_text(run([str(executable)], capture=True), encoding="utf-8", newline="\n")
    return executable


def read_events(path: Path) -> list[dict[str, object]]:
    return [
        json.loads(line)
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def fatal_processes(dll: Path, executable: Path) -> None:
    cases = [
        ("NET_FreeQSocket", 0, "--error-free-socket"),
        ("NET_Init", 1, "--error-missing-port"),
    ]
    for name, mode, argument in cases:
        code = (
            "import ctypes; "
            f"d=ctypes.WinDLL(r'{dll}'); "
            "d.net_main_error_case.argtypes=[ctypes.c_int]; "
            f"d.net_main_error_case({mode})"
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
                f"{name} fatal process mismatch: "
                f"reference={reference.returncode}, minilang={mini.returncode}"
            )
        print(
            f"net_main {name} fatal differential: PASS "
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
        default=ROOT / "build/net_main_differential",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)

    reference_path = output / "reference.jsonl"
    minilang_path = output / "minilang.jsonl"
    dll = build_oracle(output)
    oracle(dll, reference_path)
    executable = candidate(args.compiler.resolve(), output, minilang_path)

    reference_events = read_events(reference_path)
    minilang_events = read_events(minilang_path)
    if reference_events != minilang_events:
        limit = max(len(reference_events), len(minilang_events))
        for index in range(limit):
            left = reference_events[index] if index < len(reference_events) else None
            right = minilang_events[index] if index < len(minilang_events) else None
            if left != right:
                raise RuntimeError(
                    f"net_main event {index} mismatch:\n"
                    f"reference={left!r}\nminilang={right!r}"
                )
        raise RuntimeError("net_main event stream mismatch")

    covered = {event["function"] for event in reference_events}
    missing = [name for name in FUNCTIONS if name not in covered]
    if missing:
        raise RuntimeError(f"net_main target bodies without events: {missing}")
    fatal_processes(dll, executable)
    print(
        f"net_main pinned differential: PASS "
        f"({len(reference_events)} events, {len(covered)}/{len(FUNCTIONS)} bodies)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
