#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/net_loop.c."""

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
PATCH = ROOT / "reference" / "patches" / "net_loop_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "net_loop_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "net_loop_oracle.def"
FIXTURE = ROOT / "tests" / "net_loop_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "net_loop_differential_manifest.json"


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
    source_obj = output / "net_loop_pinned.obj"
    driver_obj = output / "net_loop_pinned_driver.obj"
    dll = output / "net_loop_oracle.dll"
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
            str(worktree / "WinQuake" / "net_loop.c"),
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
    library.Loop_Init.argtypes = []
    library.Loop_Init.restype = ctypes.c_int
    library.Loop_Shutdown.argtypes = []
    library.Loop_Listen.argtypes = [ctypes.c_int]
    library.Loop_SearchForHosts.argtypes = [ctypes.c_int]
    library.Loop_Connect.argtypes = [ctypes.c_char_p]
    library.Loop_Connect.restype = ctypes.c_void_p
    library.Loop_CheckNewConnections.argtypes = []
    library.Loop_CheckNewConnections.restype = ctypes.c_void_p
    library.IntAlign.argtypes = [ctypes.c_int]
    library.IntAlign.restype = ctypes.c_int
    library.Loop_GetMessage.argtypes = [ctypes.c_void_p]
    library.Loop_GetMessage.restype = ctypes.c_int
    library.Loop_SendMessage.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    library.Loop_SendMessage.restype = ctypes.c_int
    library.Loop_SendUnreliableMessage.argtypes = [
        ctypes.c_void_p,
        ctypes.c_void_p,
    ]
    library.Loop_SendUnreliableMessage.restype = ctypes.c_int
    library.Loop_CanSendMessage.argtypes = [ctypes.c_void_p]
    library.Loop_CanSendMessage.restype = ctypes.c_int
    library.Loop_CanSendUnreliableMessage.argtypes = [ctypes.c_void_p]
    library.Loop_CanSendUnreliableMessage.restype = ctypes.c_int
    library.Loop_Close.argtypes = [ctypes.c_void_p]
    library.loop_fixture_reset.argtypes = []
    library.loop_set_dedicated.argtypes = [ctypes.c_int]
    for name in ("loop_host_name", "loop_host_map", "loop_host_cname"):
        function = getattr(library, name)
        function.argtypes = []
        function.restype = ctypes.c_char_p
    for name in (
        "loop_host_users",
        "loop_host_maxusers",
        "loop_host_driver",
        "loop_net_message_size",
    ):
        function = getattr(library, name)
        function.argtypes = []
        function.restype = ctypes.c_int
    library.loop_fixture_message.argtypes = [
        ctypes.c_ubyte,
        ctypes.c_ubyte,
        ctypes.c_ubyte,
    ]
    library.loop_fixture_message.restype = ctypes.c_void_p
    library.loop_socket_can_send.argtypes = [ctypes.c_void_p]
    library.loop_socket_can_send.restype = ctypes.c_int
    library.loop_socket_receive_length.argtypes = [ctypes.c_void_p]
    library.loop_socket_receive_length.restype = ctypes.c_int
    library.loop_socket_has_peer.argtypes = [ctypes.c_void_p]
    library.loop_socket_has_peer.restype = ctypes.c_int
    library.loop_net_message_byte.argtypes = [ctypes.c_int]
    library.loop_net_message_byte.restype = ctypes.c_int


def text(value: bytes) -> str:
    return value.decode("ascii")


def message_event(
    library: ctypes.WinDLL,
    case: str,
    result: int,
    client: int,
) -> dict[str, object]:
    return {
        "function": "Loop_GetMessage",
        "case": case,
        "result": result,
        "size": library.loop_net_message_size(),
        "values": [library.loop_net_message_byte(index) for index in range(3)],
        **(
            {"peerCanSend": library.loop_socket_can_send(client)}
            if case == "reliable"
            else {}
        ),
    }


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []
    library.loop_fixture_reset()
    library.loop_set_dedicated(0)
    normal = library.Loop_Init()
    library.loop_set_dedicated(1)
    dedicated = library.Loop_Init()
    library.loop_set_dedicated(0)
    events.append(
        {"function": "Loop_Init", "case": "modes", "values": [normal, dedicated]}
    )
    library.Loop_Shutdown()
    events.append({"function": "Loop_Shutdown", "case": "noop", "called": 1})
    library.Loop_Listen(1)
    events.append({"function": "Loop_Listen", "case": "noop", "same": 1})
    library.Loop_SearchForHosts(1)
    events.append(
        {
            "function": "Loop_SearchForHosts",
            "case": "active",
            "count": 1,
            "name": text(library.loop_host_name()),
            "map": text(library.loop_host_map()),
            "users": library.loop_host_users(),
            "maxusers": library.loop_host_maxusers(),
            "driver": library.loop_host_driver(),
            "cname": text(library.loop_host_cname()),
        }
    )
    wrong = library.Loop_Connect(b"localhost")
    client = library.Loop_Connect(b"local")
    events.append(
        {
            "function": "Loop_Connect",
            "case": "local",
            "wrong": 0 if wrong else 1,
            "client": 1 if client else 0,
            "canSend": library.loop_socket_can_send(client),
        }
    )
    server = library.Loop_CheckNewConnections()
    events.append(
        {
            "function": "Loop_CheckNewConnections",
            "case": "pending",
            "server": 1 if server else 0,
            "canSend": library.loop_socket_can_send(server),
        }
    )
    events.append(
        {
            "function": "IntAlign",
            "case": "boundaries",
            "values": [library.IntAlign(value) for value in (1, 5, 8)],
        }
    )
    data = library.loop_fixture_message(1, 2, 3)
    sent = library.Loop_SendMessage(client, data)
    events.append(
        {
            "function": "Loop_SendMessage",
            "case": "reliable",
            "result": sent,
            "canSend": library.loop_socket_can_send(client),
            "queued": 1 if library.loop_socket_receive_length(server) else 0,
        }
    )
    received = library.Loop_GetMessage(server)
    events.append(message_event(library, "reliable", received, client))
    unreliable = library.Loop_SendUnreliableMessage(client, data)
    events.append(
        {
            "function": "Loop_SendUnreliableMessage",
            "case": "unreliable",
            "result": unreliable,
            "queued": 1 if library.loop_socket_receive_length(server) else 0,
        }
    )
    received_unreliable = library.Loop_GetMessage(server)
    events.append(message_event(library, "unreliable", received_unreliable, client))
    events.append(
        {
            "function": "Loop_CanSendMessage",
            "case": "ready",
            "value": library.Loop_CanSendMessage(client),
        }
    )
    events.append(
        {
            "function": "Loop_CanSendUnreliableMessage",
            "case": "always",
            "value": library.Loop_CanSendUnreliableMessage(client),
        }
    )
    library.Loop_Close(client)
    events.append(
        {
            "function": "Loop_Close",
            "case": "client",
            "closed": 1,
            "peerCleared": 0 if library.loop_socket_has_peer(server) else 1,
            "canSend": library.loop_socket_can_send(client),
        }
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "net_loop_minilang.exe"
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
        default=ROOT / "build" / "net_loop_differential",
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
    print("net_loop differential: PASS (14 JSONL events, exact)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
