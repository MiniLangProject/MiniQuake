#!/usr/bin/env python3
"""Exercise MiniQuake's UDP reliability through a deterministic lossy proxy.

Retail data is supplied by the caller and is never copied into the repository.
The proxy understands only the original Quake datagram header and CCREP_ACCEPT
port field.  It deliberately drops the first server DATA packet and the first
client ACK, then proves retransmission, connected changelevel, timeout cleanup,
and a fresh connection after the induced outage.
"""

from __future__ import annotations

import argparse
from collections import Counter
import heapq
import json
from pathlib import Path
import select
import socket
import struct
import subprocess
import tempfile
import threading
import time
from typing import BinaryIO


NETFLAG_LENGTH_MASK = 0x0000FFFF
NETFLAG_DATA = 0x00010000
NETFLAG_ACK = 0x00020000
NETFLAG_NAK = 0x00040000
NETFLAG_EOM = 0x00080000
NETFLAG_UNRELIABLE = 0x00100000
NETFLAG_CTL = 0x80000000
CCREQ_CONNECT = 0x01
CCREP_ACCEPT = 0x81


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def wait_for_output(
    process: subprocess.Popen[bytes],
    output: Path,
    predicate,
    timeout: float,
    description: str,
) -> str:
    deadline = time.monotonic() + timeout
    text = ""
    while time.monotonic() < deadline:
        text = read_text(output)
        if predicate(text):
            return text
        if process.poll() is not None:
            break
        time.sleep(0.025)
    raise RuntimeError(f"{description}\n{text}")


def control_command(packet: bytes) -> int | None:
    if len(packet) < 5:
        return None
    encoded = struct.unpack("!I", packet[:4])[0]
    if (encoded & ~NETFLAG_LENGTH_MASK) != NETFLAG_CTL:
        return None
    if (encoded & NETFLAG_LENGTH_MASK) != len(packet):
        return None
    return packet[4]


def sequenced_header(packet: bytes) -> tuple[int, int] | None:
    if len(packet) < 8:
        return None
    encoded, sequence = struct.unpack("!II", packet[:8])
    flags = encoded & ~NETFLAG_LENGTH_MASK
    if flags & NETFLAG_CTL or (encoded & NETFLAG_LENGTH_MASK) != len(packet):
        return None
    return flags, sequence


def packet_kind(flags: int) -> str:
    if flags & NETFLAG_DATA:
        return "data"
    if flags & NETFLAG_ACK:
        return "ack"
    if flags & NETFLAG_NAK:
        return "nak"
    if flags & NETFLAG_UNRELIABLE:
        return "unreliable"
    return "other"


class DatagramImpairmentProxy:
    """One Quake client path with deterministic loss, reorder and shaping.

    Each instance owns one UDP source endpoint.  Multiple instances can
    therefore model independent LAN clients without merging their original
    Protocol-15 sequence spaces.
    """

    def __init__(
        self,
        listen_port: int,
        server_port: int,
        *,
        listen_address: str = "127.0.0.1",
        server_address: str = "127.0.0.1",
        label: str = "client",
        drop_first_server_data: bool = True,
        drop_first_client_ack: bool = True,
        reorder_direction: str | None = None,
        bandwidth_bytes_per_second: int = 0,
    ) -> None:
        if reorder_direction not in (None, "c2s", "s2c"):
            raise ValueError("reorder_direction must be c2s, s2c, or None")
        if bandwidth_bytes_per_second < 0:
            raise ValueError("bandwidth_bytes_per_second must not be negative")
        self.server_control = (server_address, server_port)
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.bind((listen_address, listen_port))
        self.socket.setblocking(False)
        self.listen_address = listen_address
        self.listen_port = self.socket.getsockname()[1]
        self.label = label
        self.server_game: tuple[str, int] | None = None
        self.client: tuple[str, int] | None = None
        self.blackhole_connected = False
        self.stop_event = threading.Event()
        self.thread = threading.Thread(
            target=self._run,
            name=f"quake-udp-impairment-{label}",
            daemon=True,
        )
        self.lock = threading.Lock()
        self.seen: Counter[tuple[str, str, int]] = Counter()
        self.forwarded: Counter[tuple[str, str, int]] = Counter()
        self.dropped: Counter[tuple[str, str, int]] = Counter()
        self.drop_first_server_data = drop_first_server_data
        self.drop_first_client_ack = drop_first_client_ack
        self.reorder_direction = reorder_direction
        self.reorder_complete = reorder_direction is None
        self.held_for_reorder: (
            tuple[bytes, tuple[str, int], tuple[str, str, int]] | None
        ) = None
        self.reordered_pairs: list[dict[str, object]] = []
        self.bandwidth_bytes_per_second = bandwidth_bytes_per_second
        self.pending: list[
            tuple[
                float,
                int,
                bytes,
                tuple[str, int],
                tuple[str, str, int],
            ]
        ] = []
        self.pending_serial = 0
        self.next_transmit_time = {"c2s": 0.0, "s2c": 0.0}
        self.shaped_packets: Counter[str] = Counter()
        self.shaped_bytes: Counter[str] = Counter()
        self.delayed_packets: Counter[str] = Counter()
        self.maximum_scheduled_delay: dict[str, float] = {"c2s": 0.0, "s2c": 0.0}
        self.first_shaped_at: dict[str, float] = {}
        self.last_shaped_at: dict[str, float] = {}
        self.errors: list[str] = []

    def start(self) -> None:
        self.thread.start()

    def close(self) -> None:
        self.stop_event.set()
        self.thread.join(timeout=2)
        self.socket.close()

    def set_blackhole(self, enabled: bool) -> None:
        with self.lock:
            self.blackhole_connected = enabled

    def snapshot(self) -> dict[str, object]:
        def expand(values: Counter[tuple[str, str, int]]) -> list[dict[str, object]]:
            rows: list[dict[str, object]] = []
            unreliable_totals: Counter[str] = Counter()
            for key, count in sorted(values.items()):
                if key[1] == "unreliable":
                    unreliable_totals[key[0]] += count
                else:
                    rows.append(
                        {"direction": key[0], "kind": key[1], "sequence": key[2], "count": count}
                    )
            rows += [
                {"direction": direction, "kind": "unreliable", "sequence": "*", "count": count}
                for direction, count in sorted(unreliable_totals.items())
            ]
            return rows

        with self.lock:
            return {
                "label": self.label,
                "listen_address": self.listen_address,
                "listen_port": self.listen_port,
                "seen": expand(self.seen),
                "forwarded": expand(self.forwarded),
                "dropped": expand(self.dropped),
                "server_game_port": None if self.server_game is None else self.server_game[1],
                "bandwidth_bytes_per_second": self.bandwidth_bytes_per_second,
                "shaped": {
                    direction: {
                        "packets": self.shaped_packets[direction],
                        "bytes": self.shaped_bytes[direction],
                        "delayed_packets": self.delayed_packets[direction],
                        "maximum_scheduled_delay_ms": round(
                            self.maximum_scheduled_delay[direction] * 1000.0, 3
                        ),
                        "minimum_serialization_seconds": (
                            0.0
                            if self.bandwidth_bytes_per_second <= 0
                            else round(
                                self.shaped_bytes[direction]
                                / self.bandwidth_bytes_per_second,
                                6,
                            )
                        ),
                        "first_delivery": self.first_shaped_at.get(direction),
                        "last_delivery": self.last_shaped_at.get(direction),
                    }
                    for direction in ("c2s", "s2c")
                },
                "reordered_pairs": list(self.reordered_pairs),
                "reorder_complete": self.reorder_complete,
                "errors": list(self.errors),
            }

    def count(self, table: str, direction: str, kind: str, sequence: int | None = None) -> int:
        values = getattr(self, table)
        with self.lock:
            return sum(
                count
                for (item_direction, item_kind, item_sequence), count in values.items()
                if item_direction == direction
                and item_kind == kind
                and (sequence is None or item_sequence == sequence)
            )

    def _record(self, table: Counter[tuple[str, str, int]], key: tuple[str, str, int]) -> None:
        with self.lock:
            table[key] += 1

    def _emit(self, packet: bytes, destination: tuple[str, int], key: tuple[str, str, int]) -> None:
        self.socket.sendto(packet, destination)
        self._record(self.forwarded, key)
        direction = key[0]
        if (
            self.bandwidth_bytes_per_second > 0
            and key[1] in ("data", "ack", "nak", "unreliable", "other")
        ):
            now = time.monotonic()
            with self.lock:
                self.shaped_packets[direction] += 1
                self.shaped_bytes[direction] += len(packet)
                if direction not in self.first_shaped_at:
                    self.first_shaped_at[direction] = now
                self.last_shaped_at[direction] = now

    def _forward(
        self,
        packet: bytes,
        destination: tuple[str, int],
        key: tuple[str, str, int],
    ) -> None:
        kind = key[1]
        if (
            self.bandwidth_bytes_per_second <= 0
            or kind not in ("data", "ack", "nak", "unreliable", "other")
        ):
            self._emit(packet, destination, key)
            return
        direction = key[0]
        now = time.monotonic()
        start = max(now, self.next_transmit_time[direction])
        delivery = start + len(packet) / self.bandwidth_bytes_per_second
        self.next_transmit_time[direction] = delivery
        delay = delivery - now
        with self.lock:
            self.delayed_packets[direction] += 1
            if delay > self.maximum_scheduled_delay[direction]:
                self.maximum_scheduled_delay[direction] = delay
        self.pending_serial += 1
        heapq.heappush(
            self.pending,
            (delivery, self.pending_serial, packet, destination, key),
        )

    def _forward_connected(
        self,
        packet: bytes,
        destination: tuple[str, int],
        key: tuple[str, str, int],
    ) -> None:
        if (
            not self.reorder_complete
            and key[0] == self.reorder_direction
            and key[1] == "unreliable"
        ):
            if self.held_for_reorder is None:
                self.held_for_reorder = (packet, destination, key)
                return
            held_packet, held_destination, held_key = self.held_for_reorder
            self.held_for_reorder = None
            self.reorder_complete = True
            with self.lock:
                self.reordered_pairs.append(
                    {
                        "direction": key[0],
                        "first_sequence": held_key[2],
                        "second_sequence": key[2],
                        "forwarded_order": [key[2], held_key[2]],
                    }
                )
            # Queue the newer packet first.  The receiver must accept it and
            # discard the deliberately late older unreliable datagram.
            self._forward(packet, destination, key)
            self._forward(held_packet, held_destination, held_key)
            return
        self._forward(packet, destination, key)

    def _deliver_due(self) -> None:
        now = time.monotonic()
        while self.pending and self.pending[0][0] <= now:
            _, _, packet, destination, key = heapq.heappop(self.pending)
            with self.lock:
                blackhole = self.blackhole_connected
            if blackhole:
                self._record(self.dropped, key)
            else:
                self._emit(packet, destination, key)

    def _client_packet(self, packet: bytes, source: tuple[str, int]) -> None:
        command = control_command(packet)
        if command == CCREQ_CONNECT:
            self.client = source
            self._forward(packet, self.server_control, ("c2s", "control-connect", 0))
            return
        if self.server_game is None:
            return
        header = sequenced_header(packet)
        if header is None:
            self._forward(packet, self.server_game, ("c2s", "control", 0))
            return
        flags, sequence = header
        kind = packet_kind(flags)
        key = ("c2s", kind, sequence)
        self._record(self.seen, key)
        with self.lock:
            blackhole = self.blackhole_connected
            should_drop = kind == "ack" and self.drop_first_client_ack
            if should_drop:
                self.drop_first_client_ack = False
        if blackhole or should_drop:
            self._record(self.dropped, key)
            return
        self._forward_connected(packet, self.server_game, key)

    def _server_packet(self, packet: bytes, source: tuple[str, int]) -> None:
        if self.client is None:
            return
        command = control_command(packet)
        if command == CCREP_ACCEPT and len(packet) >= 9:
            game_port = struct.unpack("<I", packet[5:9])[0]
            self.server_game = ("127.0.0.1", game_port)
            rewritten = bytearray(packet)
            rewritten[5:9] = struct.pack("<I", self.listen_port)
            self._forward(bytes(rewritten), self.client, ("s2c", "control-accept", 0))
            return
        header = sequenced_header(packet)
        if header is None:
            self._forward(packet, self.client, ("s2c", "control", 0))
            return
        flags, sequence = header
        kind = packet_kind(flags)
        key = ("s2c", kind, sequence)
        self._record(self.seen, key)
        with self.lock:
            blackhole = self.blackhole_connected
            should_drop = kind == "data" and self.drop_first_server_data
            if should_drop:
                self.drop_first_server_data = False
        if blackhole or should_drop:
            self._record(self.dropped, key)
            return
        self._forward_connected(packet, self.client, key)

    def _run(self) -> None:
        while not self.stop_event.is_set():
            try:
                self._deliver_due()
                timeout = 0.025
                if self.pending:
                    timeout = min(timeout, max(0.0, self.pending[0][0] - time.monotonic()))
                readable, _, _ = select.select([self.socket], [], [], timeout)
                if not readable:
                    continue
                packet, source = self.socket.recvfrom(65535)
                if source == self.server_control or source == self.server_game:
                    self._server_packet(packet, source)
                else:
                    self._client_packet(packet, source)
                self._deliver_due()
            except OSError as exc:
                if not self.stop_event.is_set():
                    with self.lock:
                        self.errors.append(str(exc))
                return
            except Exception as exc:  # keep diagnostics available to the caller
                with self.lock:
                    self.errors.append(repr(exc))
                return


def write_server_command(process: subprocess.Popen[bytes], command: str) -> None:
    if process.stdin is None:
        raise RuntimeError("dedicated server stdin is not connected")
    process.stdin.write((command + "\n").encode("ascii"))
    process.stdin.flush()


def terminate(process: subprocess.Popen[bytes] | None) -> None:
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=2)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=2)


def launch_client(
    executable: Path,
    base_args: list[str],
    endpoint: str,
    output: BinaryIO,
    message_timeout: float,
) -> subprocess.Popen[bytes]:
    return subprocess.Popen(
        [
            str(executable),
            *base_args,
            "-headless",
            "-maxframes",
            "2000000000",
            "+net_messagetimeout",
            str(message_timeout),
            "+connect",
            endpoint,
        ],
        stdout=output,
        stderr=subprocess.STDOUT,
        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--map", default="start")
    parser.add_argument("--change-map", default="e1m1")
    parser.add_argument("--port", type=int, default=27996, help="client-facing proxy UDP port")
    parser.add_argument("--server-port", type=int, help="real dedicated-server UDP port")
    parser.add_argument("--message-timeout", type=float, default=4.0)
    parser.add_argument("--timeout", type=float, default=15.0)
    args = parser.parse_args()

    executable = args.exe.resolve()
    basedir = args.basedir.resolve()
    server_port = args.server_port if args.server_port is not None else args.port + 1
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    if not (basedir / args.game).is_dir():
        raise SystemExit(f"retail game directory not found: {basedir / args.game}")
    if not 1 <= args.port <= 65535 or not 1 <= server_port <= 65535:
        raise SystemExit("ports must be in 1..65535")
    if args.port == server_port:
        raise SystemExit("proxy and server ports must differ")
    if args.message_timeout <= 2.5:
        raise SystemExit("message timeout must exceed the two deliberate one-second retransmit windows")

    base_args = ["-basedir", str(basedir)]
    if args.game.lower() != "id1":
        base_args += ["-game", args.game]
    endpoint = f"127.0.0.1:{args.port}"
    proxy = DatagramImpairmentProxy(args.port, server_port)
    proxy.start()

    server: subprocess.Popen[bytes] | None = None
    first_client: subprocess.Popen[bytes] | None = None
    second_client: subprocess.Popen[bytes] | None = None
    with tempfile.TemporaryDirectory(prefix="miniquake-impairment-") as temporary:
        temp = Path(temporary)
        server_out = temp / "server.out"
        first_out = temp / "first-client.out"
        second_out = temp / "second-client.out"
        try:
            with server_out.open("wb") as output:
                server = subprocess.Popen(
                    [
                        str(executable),
                        *base_args,
                        "-dedicated",
                        "-port",
                        str(server_port),
                        "-maxframes",
                        "2000000000",
                        "+net_messagetimeout",
                        str(args.message_timeout),
                        "+map",
                        args.map,
                    ],
                    stdin=subprocess.PIPE,
                    stdout=output,
                    stderr=subprocess.STDOUT,
                    creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
                )
            wait_for_output(
                server,
                server_out,
                lambda text: f"UDP listening on port {server_port}" in text and f"map {args.map}:" in text,
                args.timeout,
                "dedicated server did not become ready",
            )

            with first_out.open("wb") as output:
                first_client = launch_client(
                    executable, base_args, endpoint, output, args.message_timeout
                )
            wait_for_output(
                first_client,
                first_out,
                lambda text: f"connected to {endpoint}" in text and "SERVER (protocol 15)" in text,
                args.timeout,
                "loss-impaired client did not complete Protocol-15 signon",
            )
            wait_for_output(
                server,
                server_out,
                lambda text: text.count("entered the game") >= 1,
                args.timeout,
                "dedicated server did not spawn the impaired client",
            )
            if proxy.count("dropped", "s2c", "data") != 1:
                raise RuntimeError(f"server DATA drop was not exercised\n{proxy.snapshot()}")
            if proxy.count("dropped", "c2s", "ack") != 1:
                raise RuntimeError(f"client ACK drop was not exercised\n{proxy.snapshot()}")
            if proxy.count("seen", "s2c", "data", 0) < 3:
                raise RuntimeError(f"lost DATA/ACK did not cause duplicate sequence-0 retransmits\n{proxy.snapshot()}")

            write_server_command(server, f"changelevel {args.change_map}")
            wait_for_output(
                server,
                server_out,
                lambda text: f"map {args.change_map}:" in text,
                args.timeout,
                "redirected dedicated-server command did not execute changelevel",
            )
            wait_for_output(
                first_client,
                first_out,
                lambda text: text.count("SERVER (protocol 15)") >= 2,
                args.timeout,
                "connected client did not re-sign-on after changelevel",
            )
            proxy.set_blackhole(True)
            wait_for_output(
                first_client,
                first_out,
                lambda text: "Server connection timed out." in text,
                args.timeout,
                "client did not time out during the deterministic outage",
            )
            # The server checks the same net_messagetimeout independently.
            time.sleep(max(args.message_timeout + 0.5, 0.75))
            write_server_command(server, "status")
            wait_for_output(
                server,
                server_out,
                lambda text: "players: 0 active" in text,
                args.timeout,
                "server did not drop the timed-out client",
            )

            proxy.set_blackhole(False)
            terminate(first_client)
            first_client = None
            with second_out.open("wb") as output:
                second_client = launch_client(
                    executable, base_args, endpoint, output, args.message_timeout
                )
            wait_for_output(
                second_client,
                second_out,
                lambda text: f"connected to {endpoint}" in text and "SERVER (protocol 15)" in text,
                args.timeout,
                "replacement client did not connect after outage cleanup",
            )
            wait_for_output(
                server,
                server_out,
                lambda text: text.count("entered the game") >= 2,
                args.timeout,
                "dedicated server did not spawn replacement client",
            )

            snapshot = proxy.snapshot()
            if snapshot["errors"]:
                raise RuntimeError(f"UDP proxy failed\n{snapshot}")
            print(
                json.dumps(
                    {
                        "status": "passed",
                        "matrix": "MiniQuake client <-> deterministic UDP impairment proxy <-> MiniQuake dedicated server",
                        "protocol": 15,
                        "game": args.game,
                        "initial_map": args.map,
                        "change_map": args.change_map,
                        "proxy_port": args.port,
                        "server_port": server_port,
                        "dropped_first_server_data": True,
                        "dropped_first_client_ack": True,
                        "server_sequence_zero_transmissions": proxy.count("seen", "s2c", "data", 0),
                        "connected_changelevel": True,
                        "client_timeout": True,
                        "server_timeout_cleanup": True,
                        "reconnect_after_outage": True,
                        "dropped_connected_packets": sum(
                            item["count"] for item in snapshot["dropped"]
                        ),
                        "proxy_errors": snapshot["errors"],
                    },
                    indent=2,
                )
            )
        except Exception as exc:
            raise RuntimeError(
                f"{exc}\nproxy:\n{json.dumps(proxy.snapshot(), indent=2)}"
                f"\nserver:\n{read_text(server_out)}"
                f"\nfirst client:\n{read_text(first_out)}"
                f"\nsecond client:\n{read_text(second_out)}"
            ) from exc
        finally:
            terminate(second_client)
            terminate(first_client)
            terminate(server)
            proxy.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
