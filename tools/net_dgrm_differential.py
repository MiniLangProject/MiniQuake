#!/usr/bin/env python3
"""Pinned WinQuake/net_dgrm.c differential, including isolated DEBUG fatals."""

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
    "NET_Ban_f",
    "Datagram_SendMessage",
    "SendMessageNext",
    "ReSendMessage",
    "Datagram_CanSendMessage",
    "Datagram_CanSendUnreliableMessage",
    "Datagram_SendUnreliableMessage",
    "Datagram_GetMessage",
    "PrintStats",
    "NET_Stats_f",
    "Test_Poll",
    "Test_f",
    "Test2_Poll",
    "Test2_f",
    "Datagram_Init",
    "Datagram_Shutdown",
    "Datagram_Close",
    "Datagram_Listen",
    "_Datagram_CheckNewConnections",
    "Datagram_CheckNewConnections",
    "_Datagram_SearchForHosts",
    "Datagram_SearchForHosts",
    "_Datagram_Connect",
    "Datagram_Connect",
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
    compiler, linker, _ = tools
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
            PINNED_COMMIT,
        ]
    )
    run(
        [
            "git",
            "-C",
            str(worktree),
            "apply",
            str(ROOT / "reference/patches/net_dgrm_pinned_oracle.patch"),
        ]
    )
    source = output / "net_dgrm_pinned.obj"
    driver = output / "net_dgrm_pinned_driver.obj"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/GS-",
        "/Zl",
        "/O2",
        "/Gy",
        "/DDEBUG",
        "/DMINIQUAKE_PINNED_ORACLE",
        f"/I{ROOT / 'reference/harness'}",
    ]
    run(common + [f"/Fo{source}", str(worktree / "WinQuake/net_dgrm.c")])
    run(common + [f"/Fo{driver}", str(ROOT / "reference/harness/net_dgrm_pinned_driver.c")])
    dll = output / "net_dgrm_oracle.dll"
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
            f"/def:{ROOT / 'reference/harness/net_dgrm_oracle.def'}",
            f"/out:{dll}",
            str(source),
            str(driver),
            str(ROOT / "native/build/msvcrt.lib"),
            str(ROOT / "native/build/ws2_32.lib"),
        ]
    )
    return dll


def oracle(dll: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll))
    function = library.net_dgrm_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler: Path, output: Path, destination: Path) -> Path:
    executable = output / "net_dgrm_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests/net_dgrm_differential_fixture.ml"),
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


def events(path: Path) -> list[dict[str, object]]:
    return [
        json.loads(line)
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]


def fatals(dll: Path, executable: Path) -> None:
    cases = [
        ("Datagram_SendMessage:empty", 0, "--error-send-empty"),
        ("Datagram_SendMessage:large", 1, "--error-send-large"),
        ("Datagram_SendMessage:busy", 2, "--error-send-busy"),
        ("Datagram_SendUnreliableMessage:empty", 3, "--error-unreliable-empty"),
        ("Datagram_SendUnreliableMessage:large", 4, "--error-unreliable-large"),
    ]
    for name, mode, argument in cases:
        code = (
            "import ctypes; "
            f"d=ctypes.WinDLL(r'{dll}'); "
            "d.net_dgrm_error_case.argtypes=[ctypes.c_int]; "
            f"d.net_dgrm_error_case({mode})"
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
            f"net_dgrm {name} fatal differential: PASS "
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
        default=ROOT / "build/net_dgrm_differential",
    )
    parser.add_argument("--oracle-only", action="store_true")
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)
    reference_path = output / "reference.jsonl"
    dll = build(output)
    oracle(dll, reference_path)
    if args.oracle_only:
        print(reference_path.read_text(encoding="utf-8"), end="")
        return 0

    minilang_path = output / "minilang.jsonl"
    executable = candidate(args.compiler.resolve(), output, minilang_path)
    reference_events = events(reference_path)
    candidate_events = events(minilang_path)
    if reference_events != candidate_events:
        for index in range(max(len(reference_events), len(candidate_events))):
            left = reference_events[index] if index < len(reference_events) else None
            right = candidate_events[index] if index < len(candidate_events) else None
            if left != right:
                raise RuntimeError(
                    f"net_dgrm event {index} mismatch:\n"
                    f"reference={left!r}\nminilang={right!r}"
                )
    covered = {event["function"] for event in reference_events}
    missing = [name for name in FUNCTIONS if name not in covered]
    if missing:
        raise RuntimeError(f"net_dgrm target bodies without events: {missing}")
    fatals(dll, executable)
    print(
        f"net_dgrm pinned differential: PASS "
        f"({len(reference_events)} events, {len(covered)}/{len(FUNCTIONS)} bodies)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
