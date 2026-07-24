#!/usr/bin/env python3
"""Exercise two simultaneous MiniQuake clients through independent UDP paths.

The original datagram driver intentionally treats a new source port from the
same IP as a crashed client reconnect.  This matrix therefore binds its two
proxy paths to distinct loopback IPs, exactly as two LAN hosts would appear to
GLQuake, while retaining deterministic local execution.

Retail data is supplied by the caller and is never copied into the repository.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import time
from typing import BinaryIO, Callable

from network_impairment_matrix import (
    DatagramImpairmentProxy,
    read_text,
    terminate,
    wait_for_output,
    write_server_command,
)


def write_report(path: Path | None, report: dict[str, object]) -> None:
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def wait_for_proxy(
    proxy: DatagramImpairmentProxy,
    predicate: Callable[[dict[str, object]], bool],
    timeout: float,
    description: str,
) -> dict[str, object]:
    deadline = time.monotonic() + timeout
    snapshot = proxy.snapshot()
    while time.monotonic() < deadline:
        snapshot = proxy.snapshot()
        if predicate(snapshot):
            return snapshot
        time.sleep(0.025)
    raise RuntimeError(f"{description}\n{json.dumps(snapshot, indent=2)}")


def launch_named_client(
    executable: Path,
    base_args: list[str],
    endpoint: str,
    name: str,
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
            "+name",
            name,
            "+connect",
            endpoint,
            "+forward",
        ],
        stdout=output,
        stderr=subprocess.STDOUT,
        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )


def status_suffix(
    server: subprocess.Popen[bytes],
    output: Path,
    active: int,
    names: tuple[str, ...],
    timeout: float,
) -> str:
    before = read_text(output)
    offset = len(before)
    write_server_command(server, "status")
    deadline = time.monotonic() + timeout
    suffix = ""
    while time.monotonic() < deadline:
        whole = read_text(output)
        suffix = whole[offset:]
        if f"players: {active} active" in suffix and all(name in suffix for name in names):
            return suffix
        if server.poll() is not None:
            break
        time.sleep(0.025)
    raise RuntimeError(
        f"server status did not prove {active} simultaneous clients {names}\n{suffix}"
    )


def sequenced_count(
    snapshot: dict[str, object],
    table: str,
    direction: str,
    kind: str,
) -> int:
    rows = snapshot.get(table)
    if not isinstance(rows, list):
        return 0
    return sum(
        int(row.get("count", 0))
        for row in rows
        if isinstance(row, dict)
        and row.get("direction") == direction
        and row.get("kind") == kind
    )


def exact_drop_count(
    proxy: DatagramImpairmentProxy,
    direction: str,
    kind: str,
) -> int:
    return proxy.count("dropped", direction, kind)


def validate_impairment_evidence(
    proxy: DatagramImpairmentProxy,
    label: str,
) -> dict[str, object]:
    snapshot = proxy.snapshot()
    if exact_drop_count(proxy, "s2c", "data") != 1:
        raise RuntimeError(f"{label}: first server DATA was not dropped exactly once")
    if exact_drop_count(proxy, "c2s", "ack") != 1:
        raise RuntimeError(f"{label}: first client ACK was not dropped exactly once")
    if proxy.count("seen", "s2c", "data", 0) < 3:
        raise RuntimeError(f"{label}: sequence-0 DATA retransmission was not observed")
    if not snapshot.get("reorder_complete"):
        raise RuntimeError(f"{label}: unreliable packet reorder did not complete")
    reordered = snapshot.get("reordered_pairs")
    if not isinstance(reordered, list) or len(reordered) != 1:
        raise RuntimeError(f"{label}: expected exactly one reordered pair")
    shaping = snapshot.get("shaped")
    if not isinstance(shaping, dict):
        raise RuntimeError(f"{label}: shaping counters unavailable")
    for direction in ("c2s", "s2c"):
        row = shaping.get(direction)
        if (
            not isinstance(row, dict)
            or int(row.get("packets", 0)) <= 0
            or int(row.get("bytes", 0)) <= 0
            or int(row.get("delayed_packets", 0)) <= 0
            or float(row.get("maximum_scheduled_delay_ms", 0.0)) <= 0.0
        ):
            raise RuntimeError(f"{label}: bandwidth shaper was not exercised in {direction}")
    return snapshot


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--exe", type=Path, default=Path("build/MiniQuake.exe"))
    parser.add_argument("--basedir", type=Path, required=True)
    parser.add_argument("--game", default="id1")
    parser.add_argument("--map", default="start")
    parser.add_argument("--change-map", default="e1m1")
    parser.add_argument("--port", type=int, default=28000, help="first proxy port")
    parser.add_argument("--server-port", type=int, help="real dedicated-server port")
    parser.add_argument("--client-a-address", default="127.0.0.2")
    parser.add_argument("--client-b-address", default="127.0.0.3")
    parser.add_argument("--bandwidth-bytes-per-second", type=int, default=32768)
    parser.add_argument("--message-timeout", type=float, default=8.0)
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    executable = args.exe.resolve()
    basedir = args.basedir.resolve()
    proxy_a_port = args.port
    proxy_b_port = args.port + 1
    server_port = args.server_port if args.server_port is not None else args.port + 2
    output_path = None if args.output is None else args.output.resolve()
    if not executable.is_file():
        raise SystemExit(f"MiniQuake executable not found: {executable}")
    if not (basedir / args.game).is_dir():
        raise SystemExit(f"retail game directory not found: {basedir / args.game}")
    ports = (proxy_a_port, proxy_b_port, server_port)
    if any(port < 1 or port > 65535 for port in ports) or len(set(ports)) != len(ports):
        raise SystemExit("proxy/server ports must be distinct and in 1..65535")
    if args.client_a_address == args.client_b_address:
        raise SystemExit("clients require distinct proxy source addresses")
    if args.bandwidth_bytes_per_second < 4096:
        raise SystemExit("bandwidth limit must be at least 4096 bytes/second")
    if args.message_timeout < 5.0:
        raise SystemExit("message timeout must allow retransmission, reorder and shaping")

    base_args = ["-basedir", str(basedir)]
    if args.game.lower() != "id1":
        base_args += ["-game", args.game]
    names = ("mq_impair_a", "mq_impair_b")
    endpoints = (
        f"{args.client_a_address}:{proxy_a_port}",
        f"{args.client_b_address}:{proxy_b_port}",
    )
    proxy_a = DatagramImpairmentProxy(
        proxy_a_port,
        server_port,
        listen_address=args.client_a_address,
        label="client-a",
        reorder_direction="c2s",
        bandwidth_bytes_per_second=args.bandwidth_bytes_per_second,
    )
    proxy_b = DatagramImpairmentProxy(
        proxy_b_port,
        server_port,
        listen_address=args.client_b_address,
        label="client-b",
        reorder_direction="s2c",
        bandwidth_bytes_per_second=args.bandwidth_bytes_per_second,
    )
    proxy_a.start()
    proxy_b.start()

    server: subprocess.Popen[bytes] | None = None
    client_a: subprocess.Popen[bytes] | None = None
    client_b: subprocess.Popen[bytes] | None = None
    replacement_a: subprocess.Popen[bytes] | None = None
    report: dict[str, object] = {
        "schema": 1,
        "status": "running",
        "matrix": (
            "two simultaneous MiniQuake clients <-> independent deterministic "
            "UDP impairment paths <-> MiniQuake dedicated server"
        ),
        "protocol": 15,
        "game": args.game,
        "initial_map": args.map,
        "change_map": args.change_map,
    }
    with tempfile.TemporaryDirectory(prefix="miniquake-multiclient-") as temporary:
        temp = Path(temporary)
        server_out = temp / "server.out"
        client_a_out = temp / "client-a.out"
        client_b_out = temp / "client-b.out"
        replacement_a_out = temp / "replacement-a.out"
        try:
            with server_out.open("wb") as output:
                server = subprocess.Popen(
                    [
                        str(executable),
                        *base_args,
                        "-dedicated",
                        "4",
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
                lambda text: (
                    f"UDP listening on port {server_port}" in text
                    and f"map {args.map}:" in text
                ),
                args.timeout,
                "dedicated server did not become ready",
            )

            # Accept A completely before beginning B.  GLQuake exposes one
            # pending accept slot, while both resulting clients then remain
            # active concurrently for the rest of the matrix.
            with client_a_out.open("wb") as output:
                client_a = launch_named_client(
                    executable,
                    base_args,
                    endpoints[0],
                    names[0],
                    output,
                    args.message_timeout,
                )
            wait_for_output(
                client_a,
                client_a_out,
                lambda text: (
                    f"connected to {endpoints[0]}" in text
                    and "SERVER (protocol 15)" in text
                ),
                args.timeout,
                "client A did not complete Protocol-15 signon",
            )
            wait_for_output(
                server,
                server_out,
                lambda text: text.count("entered the game") >= 1,
                args.timeout,
                "server did not spawn client A",
            )

            with client_b_out.open("wb") as output:
                client_b = launch_named_client(
                    executable,
                    base_args,
                    endpoints[1],
                    names[1],
                    output,
                    args.message_timeout,
                )
            wait_for_output(
                client_b,
                client_b_out,
                lambda text: (
                    f"connected to {endpoints[1]}" in text
                    and "SERVER (protocol 15)" in text
                ),
                args.timeout,
                "client B did not complete Protocol-15 signon",
            )
            wait_for_output(
                server,
                server_out,
                lambda text: text.count("entered the game") >= 2,
                args.timeout,
                "server did not spawn both client processes",
            )
            status_suffix(server, server_out, 2, names, args.timeout)

            wait_for_proxy(
                proxy_a,
                lambda snapshot: bool(snapshot.get("reorder_complete")),
                args.timeout,
                "client A did not produce a reorderable unreliable pair",
            )
            wait_for_proxy(
                proxy_b,
                lambda snapshot: bool(snapshot.get("reorder_complete")),
                args.timeout,
                "client B did not produce a reorderable unreliable pair",
            )
            initial_a = validate_impairment_evidence(proxy_a, "client A")
            initial_b = validate_impairment_evidence(proxy_b, "client B")

            # Both channel sequence spaces must independently start at zero.
            # Each has its own loss/retransmit evidence despite overlapping
            # wire sequence numbers.
            if proxy_a.count("seen", "s2c", "data", 0) < 3:
                raise RuntimeError("client A did not retain an independent sequence zero")
            if proxy_b.count("seen", "s2c", "data", 0) < 3:
                raise RuntimeError("client B did not retain an independent sequence zero")

            write_server_command(server, f"changelevel {args.change_map}")
            wait_for_output(
                server,
                server_out,
                lambda text: f"map {args.change_map}:" in text,
                args.timeout,
                "server did not execute connected changelevel",
            )
            wait_for_output(
                client_a,
                client_a_out,
                lambda text: text.count("SERVER (protocol 15)") >= 2,
                args.timeout,
                "client A did not re-sign-on after changelevel",
            )
            wait_for_output(
                client_b,
                client_b_out,
                lambda text: text.count("SERVER (protocol 15)") >= 2,
                args.timeout,
                "client B did not re-sign-on after changelevel",
            )
            status_suffix(server, server_out, 2, names, args.timeout)

            if client_a.poll() is not None or client_b.poll() is not None:
                raise RuntimeError("a simultaneous client exited before the outage phase")
            client_b_before_outage = proxy_b.count(
                "forwarded", "c2s", "unreliable"
            )
            proxy_a.set_blackhole(True)
            wait_for_output(
                client_a,
                client_a_out,
                lambda text: "Server connection timed out." in text,
                args.timeout,
                "client A did not time out during its isolated outage",
            )
            time.sleep(args.message_timeout + 0.75)
            status_suffix(server, server_out, 1, (names[1],), args.timeout)
            if client_b.poll() is not None:
                raise RuntimeError("client B exited while only client A was blackholed")
            if "Server connection timed out." in read_text(client_b_out):
                raise RuntimeError("client B timed out during client A's isolated outage")
            wait_for_proxy(
                proxy_b,
                lambda snapshot: (
                    sequenced_count(snapshot, "forwarded", "c2s", "unreliable")
                    >= client_b_before_outage + 4
                ),
                args.timeout,
                "client B stopped making sequenced movement progress during A outage",
            )
            client_b_after_outage = proxy_b.count(
                "forwarded", "c2s", "unreliable"
            )

            terminate(client_a)
            client_a = None
            proxy_a.set_blackhole(False)
            entered_before_replacement = read_text(server_out).count("entered the game")
            with replacement_a_out.open("wb") as output:
                replacement_a = launch_named_client(
                    executable,
                    base_args,
                    endpoints[0],
                    "mq_impair_a2",
                    output,
                    args.message_timeout,
                )
            wait_for_output(
                replacement_a,
                replacement_a_out,
                lambda text: (
                    f"connected to {endpoints[0]}" in text
                    and "SERVER (protocol 15)" in text
                ),
                args.timeout,
                "replacement client A did not complete Protocol-15 signon",
            )
            wait_for_output(
                server,
                server_out,
                lambda text: (
                    text.count("entered the game") >= entered_before_replacement + 1
                ),
                args.timeout,
                "server did not spawn replacement client A",
            )
            status_suffix(
                server,
                server_out,
                2,
                ("mq_impair_a2", names[1]),
                args.timeout,
            )
            if client_b.poll() is not None or "Server connection timed out." in read_text(client_b_out):
                raise RuntimeError("client B did not survive client A reconnect")

            final_a = proxy_a.snapshot()
            final_b = proxy_b.snapshot()
            errors = list(final_a.get("errors", [])) + list(final_b.get("errors", []))
            if errors:
                raise RuntimeError(f"UDP proxy errors: {errors}")
            report.update(
                {
                    "status": "passed",
                    "summary": {
                        "simultaneous_clients": 2,
                        "simultaneously_active_before_changelevel": True,
                        "independent_data_drops": 2,
                        "independent_ack_drops": 2,
                        "independent_sequence_zero_retransmits": True,
                        "unreliable_reorder_pairs": 2,
                        "bandwidth_limits_exercised": 2,
                        "movement_progress_exercised": True,
                        "both_clients_resigned_after_changelevel": True,
                        "isolated_timeout": True,
                        "other_client_survived_and_progressed": True,
                        "reconnect_after_timeout": True,
                    },
                    "server": {
                        "port": server_port,
                        "maximum_clients": 4,
                    },
                    "clients": [
                        {
                            "id": "a",
                            "name": names[0],
                            "replacement_name": "mq_impair_a2",
                            "proxy_address": args.client_a_address,
                            "proxy_port": proxy_a_port,
                            "reorder_direction": "c2s",
                            "initial_evidence": initial_a,
                            "final_evidence": final_a,
                            "timed_out": True,
                            "reconnected": True,
                        },
                        {
                            "id": "b",
                            "name": names[1],
                            "proxy_address": args.client_b_address,
                            "proxy_port": proxy_b_port,
                            "reorder_direction": "s2c",
                            "initial_evidence": initial_b,
                            "final_evidence": final_b,
                            "unreliable_progress_during_a_outage": (
                                client_b_after_outage - client_b_before_outage
                            ),
                            "survived_a_timeout_and_reconnect": True,
                        },
                    ],
                    "bandwidth_bytes_per_second_per_direction": (
                        args.bandwidth_bytes_per_second
                    ),
                }
            )
            write_report(output_path, report)
            print(json.dumps(report, indent=2))
        except Exception as exc:
            report.update(
                {
                    "status": "failed",
                    "error": str(exc),
                    "proxy_a": proxy_a.snapshot(),
                    "proxy_b": proxy_b.snapshot(),
                    "diagnostics": {
                        "server_tail": read_text(server_out)[-12000:],
                        "client_a_tail": read_text(client_a_out)[-12000:],
                        "client_b_tail": read_text(client_b_out)[-12000:],
                        "replacement_a_tail": read_text(replacement_a_out)[-12000:],
                    },
                }
            )
            write_report(output_path, report)
            raise RuntimeError(
                f"{exc}\n{json.dumps(report, indent=2)}"
            ) from exc
        finally:
            terminate(replacement_a)
            terminate(client_b)
            terminate(client_a)
            terminate(server)
            proxy_b.close()
            proxy_a.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
