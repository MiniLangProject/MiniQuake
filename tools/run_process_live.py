#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Run one child process with immediate binary-safe console and log forwarding.

The child stream is never decoded by this helper.  This avoids Windows code-page
mismatches (for example PowerShell/OEM output being decoded as cp1252) and keeps
all console output live.  A status JSON is always attempted, including for
streaming failures.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import traceback
from typing import BinaryIO

RUNNER_FAILURE = 125
START_FAILURE = 127


def _status_payload(
    exit_code: int,
    command: list[str],
    started: bool,
    error: str = "",
) -> dict[str, object]:
    """Build the serializable status record for a supervised process."""
    return {
        "schema": "MiniQuakeLiveProcessStatus/2",
        "exit_code": int(exit_code),
        "started": bool(started),
        "command": command,
        "error": error,
        "stream_mode": "binary_passthrough",
    }


def write_status(
    path: Path | None,
    exit_code: int,
    command: list[str],
    started: bool,
    error: str = "",
) -> None:
    """Atomically persist the supervised process status as JSON."""
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = _status_payload(exit_code, command, started, error)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    os.replace(tmp, path)


def emit_bytes(data: bytes, log: BinaryIO | None = None) -> None:
    """Forward bytes immediately without a decode/re-encode round trip."""
    if not data:
        return
    stream = getattr(sys.stdout, "buffer", None)
    if stream is not None:
        stream.write(data)
        stream.flush()
    else:  # pragma: no cover - only for unusual embedded Python hosts
        sys.stdout.write(data.decode("utf-8", errors="backslashreplace"))
        sys.stdout.flush()
    if log is not None:
        log.write(data)
        log.flush()


def emit_ascii(text: str, log: BinaryIO | None = None) -> None:
    """Forward one child-output chunk through the ASCII console stream."""
    emit_bytes(text.encode("ascii", errors="backslashreplace"), log)


def terminate_process(process: subprocess.Popen[bytes] | None) -> None:
    """Terminate a child process tree and preserve its final status."""
    if process is None or process.poll() is not None:
        return
    try:
        process.terminate()
        process.wait(timeout=5)
    except Exception:
        try:
            process.kill()
            process.wait(timeout=5)
        except Exception:
            pass


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--log", required=True)
    parser.add_argument("--cwd", default="")
    parser.add_argument("--status-json", default="")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()

    command = list(args.command)
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        parser.error("missing command after --")

    log_path = Path(args.log)
    status_path = Path(args.status_json) if args.status_json else None
    log_path.parent.mkdir(parents=True, exist_ok=True)

    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    # Child Python tools use UTF-8 and replace unencodable characters rather
    # than terminating a long acceptance run.
    env.setdefault("PYTHONIOENCODING", "utf-8:backslashreplace")

    process: subprocess.Popen[bytes] | None = None
    started = False
    with log_path.open("wb", buffering=0) as log:
        emit_ascii("MiniQuake live child-process log\n", log)
        emit_ascii("stream_mode=binary_passthrough\n", log)
        emit_ascii("command=" + repr(command) + "\n", log)
        try:
            process = subprocess.Popen(
                command,
                cwd=args.cwd or None,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=False,
                bufsize=0,
            )
            started = True
            if process.stdout is None:
                raise RuntimeError("child stdout pipe was not created")

            # os.read returns as soon as bytes are available.  It therefore
            # preserves live progress even when a child does not flush full
            # text lines yet.
            fd = process.stdout.fileno()
            while True:
                chunk = os.read(fd, 4096)
                if not chunk:
                    break
                emit_bytes(chunk, log)

            process.stdout.close()
            code = int(process.wait())
            emit_ascii(f"\nchild_exit_code={code}\n", log)
            write_status(status_path, code, command, True)
            return code
        except KeyboardInterrupt:
            terminate_process(process)
            detail = "live runner interrupted by user"
            emit_ascii("\nERROR: " + detail + "\n", log)
            try:
                write_status(status_path, 130, command, started, detail)
            except Exception:
                pass
            return 130
        except BaseException:
            terminate_process(process)
            detail = traceback.format_exc()
            # Keep the console diagnostic ASCII-safe even when the parent is
            # Windows PowerShell 5.1 using an OEM/ANSI code page.
            emit_ascii("\nERROR: MiniQuake live runner failure\n" + detail + "\n", log)
            failure_code = START_FAILURE if not started else RUNNER_FAILURE
            try:
                write_status(status_path, failure_code, command, started, detail)
            except Exception as status_exc:
                emit_ascii(
                    "ERROR: could not write live-runner status: " + repr(status_exc) + "\n",
                    log,
                )
            return failure_code
        finally:
            if process is not None and process.stdout is not None:
                try:
                    process.stdout.close()
                except Exception:
                    pass


if __name__ == "__main__":
    raise SystemExit(main())
