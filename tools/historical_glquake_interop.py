#!/usr/bin/env python3
"""Exercise MiniQuake against a caller-supplied historical GLQuake binary.

Retail executables and game data stay outside the repository.  The GLQuake
client direction uses a transparent UDP relay so the original connectionless
and sequenced NetQuake packets can be reported without modifying either
engine.  The relay rewrites only the port in CCREP_ACCEPT; packet payloads are
otherwise forwarded unchanged.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import select
import socket
import struct
import subprocess
import tempfile
import threading
import time
from typing import Any


NETFLAG_LENGTH_MASK = 0x0000FFFF
NETFLAG_CTL = 0x80000000
CCREP_ACCEPT = 0x81


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def exit_code(value: int | None) -> dict[str, Any] | None:
    if value is None:
        return None
    unsigned = value & 0xFFFFFFFF
    signed = unsigned if unsigned < 0x80000000 else unsigned - 0x100000000
    return {"signed": signed, "unsigned": unsigned, "hex": f"0x{unsigned:08X}"}


def startup_info() -> subprocess.STARTUPINFO | None:
    if not hasattr(subprocess, "STARTUPINFO"):
        return None
    info = subprocess.STARTUPINFO()
    info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    info.wShowWindow = 0
    return info


def start_logged(
    command: list[str],
    cwd: Path,
    stdout_path: Path,
    stderr_path: Path,
) -> tuple[subprocess.Popen[bytes], Any, Any]:
    stdout = stdout_path.open("wb")
    stderr = stderr_path.open("wb")
    process = subprocess.Popen(
        command,
        cwd=cwd,
        stdin=None,
        stdout=stdout,
        stderr=stderr,
        startupinfo=startup_info(),
        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    return process, stdout, stderr


def stop_process(process: subprocess.Popen[bytes] | None) -> None:
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=3)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=3)


def reserve_port() -> int:
    probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        probe.bind(("0.0.0.0", 0))
        return int(probe.getsockname()[1])
    finally:
        probe.close()


def packet_description(direction: str, data: bytes, remote: tuple[str, int]) -> dict[str, Any]:
    result: dict[str, Any] = {
        "direction": direction,
        "remote": f"{remote[0]}:{remote[1]}",
        "bytes": len(data),
        "hex_prefix": data[:64].hex().upper(),
    }
    if len(data) < 4:
        return result
    length_flags = struct.unpack(">I", data[:4])[0]
    result["declared_length"] = length_flags & NETFLAG_LENGTH_MASK
    result["flags"] = f"0x{length_flags & ~NETFLAG_LENGTH_MASK:08X}"
    if length_flags & NETFLAG_CTL:
        if len(data) >= 5:
            result["control_command"] = f"0x{data[4]:02X}"
    elif len(data) >= 8:
        result["sequence"] = struct.unpack(">I", data[4:8])[0]
    return result


class DatagramRelay:
    """Transparent two-port relay for the NetQuake connection handshake."""

    def __init__(self, server_port: int, control_port: int, game_port: int) -> None:
        self.server_port = server_port
        self.control_port = control_port
        self.game_port = game_port
        self.control_front = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.control_front.bind(("0.0.0.0", control_port))
        self.game_front = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.game_front.bind(("0.0.0.0", game_port))
        self.backend = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.backend.bind(("127.0.0.1", 0))
        self.client: tuple[str, int] | None = None
        self.server_game_port: int | None = None
        self.trace: list[dict[str, Any]] = []
        self.failure: str | None = None
        self.stopping = threading.Event()
        self.thread = threading.Thread(target=self._run, name="netquake-relay", daemon=True)

    @property
    def backend_port(self) -> int:
        return int(self.backend.getsockname()[1])

    def start(self) -> None:
        self.thread.start()

    def stop(self) -> None:
        self.stopping.set()
        self.thread.join(timeout=2)
        self.control_front.close()
        self.game_front.close()
        self.backend.close()

    def _record(self, direction: str, data: bytes, remote: tuple[str, int]) -> None:
        entry = packet_description(direction, data, remote)
        entry["at_seconds"] = round(time.monotonic(), 6)
        self.trace.append(entry)

    def _run(self) -> None:
        try:
            while not self.stopping.is_set():
                readable, _, _ = select.select(
                    [self.control_front, self.game_front, self.backend], [], [], 0.05
                )
                for source in readable:
                    data, remote = source.recvfrom(65535)
                    if source is self.control_front:
                        self.client = remote
                        self._record("glquake->relay-control", data, remote)
                        self.backend.sendto(data, ("127.0.0.1", self.server_port))
                    elif source is self.game_front:
                        self.client = remote
                        self._record("glquake->relay-game", data, remote)
                        if self.server_game_port is not None:
                            self.backend.sendto(data, ("127.0.0.1", self.server_game_port))
                    else:
                        self._record("miniquake->relay", data, remote)
                        if self.client is None:
                            continue
                        if remote[1] == self.server_port:
                            outgoing = data
                            if len(data) >= 9 and data[4] == CCREP_ACCEPT:
                                self.server_game_port = struct.unpack("<I", data[5:9])[0]
                                outgoing = data[:5] + struct.pack("<I", self.game_port) + data[9:]
                                self.trace[-1]["accepted_server_port"] = self.server_game_port
                                self.trace[-1]["advertised_relay_port"] = self.game_port
                            self.control_front.sendto(outgoing, self.client)
                        elif self.server_game_port is not None and remote[1] == self.server_game_port:
                            self.game_front.sendto(data, self.client)
        except OSError as error:
            if not self.stopping.is_set():
                self.failure = str(error)


def wait_for_text(
    process: subprocess.Popen[bytes],
    output: Path,
    needle: str,
    timeout: float,
) -> bool:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if needle in read_text(output):
            return True
        if process.poll() is not None:
            return False
        time.sleep(0.05)
    return needle in read_text(output)


def mini_base_arguments(basedir: Path, game: str) -> list[str]:
    arguments = ["-basedir", str(basedir)]
    if game.lower() != "id1":
        arguments += ["-game", game]
    return arguments


def glquake_client_to_miniquake(
    mini: Path,
    glquake: Path,
    basedir: Path,
    game: str,
    map_name: str,
    server_port: int,
    control_port: int,
    game_port: int,
    timeout: float,
    output: Path,
) -> dict[str, Any]:
    server_out = output / "mini-server.out"
    server_err = output / "mini-server.err"
    gl_out = output / "glquake-client.out"
    gl_err = output / "glquake-client.err"
    server: subprocess.Popen[bytes] | None = None
    client: subprocess.Popen[bytes] | None = None
    handles: list[Any] = []
    relay: DatagramRelay | None = None
    try:
        server, stdout, stderr = start_logged(
            [
                str(mini),
                *mini_base_arguments(basedir, game),
                "-dedicated",
                "4",
                "-port",
                str(server_port),
                "-maxframes",
                "2000000000",
                "+map",
                map_name,
            ],
            output,
            server_out,
            server_err,
        )
        handles += [stdout, stderr]
        ready = wait_for_text(server, server_out, f"UDP listening on port {server_port}", timeout)
        if not ready:
            return {
                "status": "failed",
                "reason": "MiniQuake dedicated server did not become ready",
                "server_exit": exit_code(server.poll()),
                "server_output": read_text(server_out) + read_text(server_err),
            }

        relay = DatagramRelay(server_port, control_port, game_port)
        relay.start()
        client, stdout, stderr = start_logged(
            [
                str(glquake),
                "-window",
                "-width",
                "640",
                "-height",
                "480",
                "-nosound",
                "-nojoy",
                "-noipx",
                # The 1997 WinSock driver binds client sockets to one concrete
                # adapter address.  On multi-homed modern Windows, an explicit
                # loopback bind is required for a same-machine acceptance run;
                # otherwise replies can be classified as the client's own LAN
                # broadcast and CCREQ_CONNECT is never emitted.
                "-ip",
                "127.0.0.1",
                "-port",
                str(control_port),
                "+name",
                "glqinterop",
                "+connect",
                "127.0.0.1",
            ],
            basedir,
            gl_out,
            gl_err,
        )
        handles += [stdout, stderr]
        entered = wait_for_text(server, server_out, "entered the game", timeout)
        server_text = read_text(server_out) + read_text(server_err)
        return {
            "status": "passed" if entered else "failed",
            "reason": "" if entered else "historical client did not enter the game",
            "protocol": 15,
            "server_port": server_port,
            "relay_control_port": control_port,
            "relay_game_port": game_port,
            "relay_backend_port": relay.backend_port,
            "client_exit": exit_code(client.poll()),
            "server_exit": exit_code(server.poll()),
            "relay_failure": relay.failure,
            "packet_trace": relay.trace,
            "server_output": server_text,
            "client_output": read_text(gl_out) + read_text(gl_err),
        }
    finally:
        stop_process(client)
        stop_process(server)
        if relay is not None:
            relay.stop()
        for handle in handles:
            handle.close()


def miniquake_client_to_glquake(
    mini: Path,
    glquake: Path,
    basedir: Path,
    game: str,
    map_name: str,
    port: int,
    timeout: float,
    output: Path,
) -> dict[str, Any]:
    gl_out = output / "glquake-server.out"
    gl_err = output / "glquake-server.err"
    mini_out = output / "mini-client.out"
    mini_err = output / "mini-client.err"
    server: subprocess.Popen[bytes] | None = None
    client: subprocess.Popen[bytes] | None = None
    handles: list[Any] = []
    try:
        game_arguments = [] if game.lower() == "id1" else ["-game", game]
        server, stdout, stderr = start_logged(
            [
                str(glquake),
                "-dedicated",
                "4",
                "-noipx",
                "-port",
                str(port),
                *game_arguments,
                "+map",
                map_name,
            ],
            basedir,
            gl_out,
            gl_err,
        )
        handles += [stdout, stderr]
        wait_for_text(server, gl_out, "Quake Initialized", min(timeout, 5.0))
        client, stdout, stderr = start_logged(
            [
                str(mini),
                *mini_base_arguments(basedir, game),
                "-headless",
                "-maxframes",
                "2000000000",
                "+connect",
                f"127.0.0.1:{port}",
            ],
            output,
            mini_out,
            mini_err,
        )
        handles += [stdout, stderr]
        endpoint = f"127.0.0.1:{port}"
        connected = wait_for_text(client, mini_out, f"connected to {endpoint}", timeout)
        accepted = connected and wait_for_text(
            client, mini_out, "SERVER (protocol 15)", min(timeout, 5.0)
        )
        server_code = server.poll()
        if accepted:
            status = "passed"
            reason = ""
        elif server_code not in (None, 0):
            status = "blocked"
            reason = "historical GLQuake server crashed before interoperability could complete"
        else:
            status = "failed"
            reason = "MiniQuake client did not complete Protocol-15 signon"
        return {
            "status": status,
            "reason": reason,
            "protocol": 15,
            "port": port,
            "server_exit": exit_code(server_code),
            "client_exit": exit_code(client.poll()),
            "server_output": read_text(gl_out) + read_text(gl_err),
            "client_output": read_text(mini_out) + read_text(mini_err),
        }
    finally:
        stop_process(client)
        stop_process(server)
        for handle in handles:
            handle.close()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mini-exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--glquake-exe", type=Path, required=True)
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--map", default="start")
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--gl-server-port", type=int, default=0)
    parser.add_argument("--mini-server-port", type=int, default=0)
    parser.add_argument("--relay-control-port", type=int, default=0)
    parser.add_argument("--relay-game-port", type=int, default=0)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    mini = args.mini_exe.resolve()
    glquake = args.glquake_exe.resolve()
    basedir = args.basedir.resolve()
    for label, path in (
        ("MiniQuake executable", mini),
        ("GLQuake executable", glquake),
        ("retail basedir", basedir),
    ):
        if not path.exists():
            raise SystemExit(f"{label} not found: {path}")
    if not (basedir / args.game).is_dir():
        raise SystemExit(f"retail game directory not found: {basedir / args.game}")

    gl_server_port = args.gl_server_port or reserve_port()
    mini_server_port = args.mini_server_port or reserve_port()
    relay_control_port = args.relay_control_port or reserve_port()
    relay_game_port = args.relay_game_port or reserve_port()
    ports = [gl_server_port, mini_server_port, relay_control_port, relay_game_port]
    if len(set(ports)) != len(ports):
        raise SystemExit("all four UDP ports must be distinct")

    temporary: tempfile.TemporaryDirectory[str] | None = None
    if args.output is None:
        temporary = tempfile.TemporaryDirectory(prefix="historical-glquake-interop-")
        output = Path(temporary.name)
    else:
        output = args.output.resolve()
        output.mkdir(parents=True, exist_ok=True)

    try:
        result = {
            "target": "GLQuake 1.09 / NetQuake protocol 15",
            "glquake": {
                "path": str(glquake),
                "sha256": file_sha256(glquake),
            },
            "miniquake": {
                "path": str(mini),
                "sha256": file_sha256(mini),
            },
            "game": args.game,
            "map": args.map,
            "directions": {
                "glquake_client_to_miniquake_server": glquake_client_to_miniquake(
                    mini,
                    glquake,
                    basedir,
                    args.game,
                    args.map,
                    mini_server_port,
                    relay_control_port,
                    relay_game_port,
                    args.timeout,
                    output,
                ),
                "miniquake_client_to_glquake_server": miniquake_client_to_glquake(
                    mini,
                    glquake,
                    basedir,
                    args.game,
                    args.map,
                    gl_server_port,
                    args.timeout,
                    output,
                ),
            },
        }
        print(json.dumps(result, indent=2))
        statuses = [entry["status"] for entry in result["directions"].values()]
        return 0 if statuses == ["passed", "passed"] else 1
    finally:
        if temporary is not None:
            temporary.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
