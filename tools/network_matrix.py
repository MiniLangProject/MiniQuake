#!/usr/bin/env python3
"""Run the local MiniQuake UDP listen/dedicated acceptance path.

Retail data is supplied by the caller and is never copied into the repository.
The test covers LAN broadcast discovery and a separate Protocol-15 client
process connecting and reconnecting through the original
connectionless/datagram stack.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import time


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def wait_for_server(process: subprocess.Popen[bytes], output: Path, port: int, timeout: float) -> str:
    deadline = time.monotonic() + timeout
    text = ""
    while time.monotonic() < deadline:
        text = read_text(output)
        if f"UDP listening on port {port}" in text and "map " in text:
            return text
        if process.poll() is not None:
            break
        time.sleep(0.05)
    raise RuntimeError(f"dedicated server did not become ready\n{text}")


def wait_for_output(
    process: subprocess.Popen[bytes],
    output: Path,
    required: tuple[str, ...],
    timeout: float,
    description: str,
) -> str:
    deadline = time.monotonic() + timeout
    text = ""
    while time.monotonic() < deadline:
        text = read_text(output)
        if all(item in text for item in required):
            return text
        if process.poll() is not None:
            break
        time.sleep(0.05)
    missing = [item for item in required if item not in text]
    raise RuntimeError(f"{description}; missing {missing}\n{text}")


def run_checked(command: list[str], timeout: float) -> subprocess.CompletedProcess[str]:
    completed = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(
            f"command exited {completed.returncode}: {' '.join(command)}\n{completed.stdout}"
        )
    return completed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--map", default="start")
    parser.add_argument("--port", type=int, default=27015)
    parser.add_argument("--client-frames", type=int, default=120)
    parser.add_argument("--timeout", type=float, default=10.0)
    args = parser.parse_args()

    executable = args.exe.resolve()
    basedir = args.basedir.resolve()
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    game_dir = basedir / args.game
    if not game_dir.is_dir():
        raise SystemExit(f"retail game directory not found: {game_dir}")
    if not 1 <= args.port <= 65535:
        raise SystemExit("port must be in 1..65535")

    base_args = ["-basedir", str(basedir)]
    if args.game.lower() != "id1":
        base_args += ["-game", args.game]

    creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    with tempfile.TemporaryDirectory(prefix="miniquake-network-") as temporary:
        temp = Path(temporary)
        server_out = temp / "server.out"
        server_err = temp / "server.err"
        first_client_out = temp / "first-client.out"
        first_client: subprocess.Popen[bytes] | None = None
        with server_out.open("wb") as stdout, server_err.open("wb") as stderr:
            server = subprocess.Popen(
                [
                    str(executable),
                    *base_args,
                    "-dedicated",
                    "-port",
                    str(args.port),
                    "-maxframes",
                    "2000000000",
                    "+map",
                    args.map,
                ],
                stdout=stdout,
                stderr=stderr,
                creationflags=creation_flags,
            )
        try:
            wait_for_server(server, server_out, args.port, args.timeout)
            discovery = run_checked(
                [
                    str(executable),
                    *base_args,
                    "-headless",
                    "-port",
                    str(args.port),
                    "-maxframes",
                    "1",
                    "+slist",
                ],
                args.timeout,
            )
            if args.map not in discovery.stdout or "No Quake servers found." in discovery.stdout:
                raise RuntimeError(f"LAN discovery did not find the server\n{discovery.stdout}")

            endpoint = f"127.0.0.1:{args.port}"
            with first_client_out.open("wb") as stdout:
                first_client = subprocess.Popen(
                    [
                        str(executable),
                        *base_args,
                        "-headless",
                        "-maxframes",
                        "2000000000",
                        "+connect",
                        endpoint,
                    ],
                    stdout=stdout,
                    stderr=subprocess.STDOUT,
                    creationflags=creation_flags,
                )
            first_text = wait_for_output(
                first_client,
                first_client_out,
                (
                    f"connected to {endpoint}",
                    "SERVER (protocol 15)",
                ),
                args.timeout,
                "first client did not complete Protocol-15 signon",
            )
            wait_for_output(
                server,
                server_out,
                ("entered the game",),
                args.timeout,
                "dedicated server did not spawn the first client",
            )

            # Simulate a crashed client: TerminateProcess bypasses the normal
            # CLC_DISCONNECT/Host_Shutdown path and leaves the server-side
            # qsocket alive.  A second process therefore exercises the
            # net_dgrm.c same-address/new-source-port replacement path.
            first_client.terminate()
            first_client.wait(timeout=2)

            second = run_checked(
                [
                    str(executable),
                    *base_args,
                    "-headless",
                    "-maxframes",
                    str(args.client_frames),
                    "+connect",
                    endpoint,
                ],
                args.timeout,
            )
            required = (f"connected to {endpoint}", "SERVER (protocol 15)")
            missing = [item for item in required if item not in second.stdout]
            if missing:
                raise RuntimeError(
                    "replacement client did not complete Protocol-15 signon; "
                    f"missing {missing}\nfirst client:\n{first_text}\n"
                    f"replacement client:\n{second.stdout}"
                )
            time.sleep(0.2)
            server_text = read_text(server_out) + read_text(server_err)
            if server_text.count("entered the game") < 2:
                raise RuntimeError(
                    "dedicated server did not spawn both client processes\n"
                    f"{server_text}\nfirst client:\n{first_text}\n"
                    f"replacement client:\n{second.stdout}"
                )
            if "Error occured:" in server_text or "WSA error" in server_text:
                raise RuntimeError(f"server logged a transport error\n{server_text}")
        finally:
            if first_client is not None and first_client.poll() is None:
                first_client.terminate()
                try:
                    first_client.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    first_client.kill()
                    first_client.wait(timeout=2)
            if server.poll() is None:
                server.terminate()
                try:
                    server.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    server.kill()
                    server.wait(timeout=2)

    print(
        json.dumps(
            {
                "status": "passed",
                "matrix": "MiniQuake client <-> MiniQuake dedicated server",
                "protocol": 15,
                "map": args.map,
                "game": args.game,
                "port": args.port,
                "lan_discovery": True,
                "reconnect": True,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
