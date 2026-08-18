#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-013 Protocol-15 static/event/scoreboard/drop parity.

The Python model is intentionally independent from the MiniLang implementation.
When a C compiler is available, the bundled C oracle is compiled with strict
warnings and its complete output must match the Python model and checked-in
golden document byte for byte.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

PACKAGE_ID = "BP-013"
PARENT_PACKAGE_ID = "BP-012R1"
SCHEMA = "MiniQuakeProtocol15EventsGolden/1"
REPORT_SCHEMA = "MiniQuakeBP013Protocol15EventsVerification/1"
CASE_GROUPS = ("particle_count", "datagram_gate", "frag_compare", "stored_frag", "player_color")


def f32(value: float | int) -> float:
    """Round a value through the IEEE-754 binary32 representation."""
    return struct.unpack("<f", struct.pack("<f", float(value)))[0]


def c_float_product(left: float | int, right: float | int) -> float:
    """Reproduce the reference c float product operation for differential testing."""
    return f32(f32(left) * f32(right))


def byte(value: float | int) -> int:
    """Compute the reference byte value for a deterministic fixture."""
    return int(value) & 0xFF


def short_bytes(value: float | int) -> bytes:
    """Compute the reference short bytes value for a deterministic fixture."""
    return struct.pack("<H", int(value) & 0xFFFF)


def write_coord(output: bytearray, value: float | int) -> None:
    """Encode and write coord to the fixture buffer."""
    output.extend(short_bytes(int(c_float_product(value, 8.0))))


def write_angle(output: bytearray, value: float | int) -> None:
    """Encode and write angle to the fixture buffer."""
    rounded = f32(value)
    output.append((int((int(rounded) * 256) / 360)) & 0xFF)


def vector(name: str, output: bytes | bytearray) -> dict[str, Any]:
    """Package one encoded protocol message as a deterministic vector row."""
    raw = bytes(output)
    return {"kind": "vector", "name": name, "bytes": raw.hex(), "length": len(raw)}


def write_spawn_static(
    model: int,
    frame: int,
    colormap: int,
    skin: int,
    origin: tuple[float, float, float],
    angles: tuple[float, float, float],
) -> bytearray:
    """Encode and write spawn static to the fixture buffer."""
    output = bytearray((20, byte(model), byte(frame), byte(colormap), byte(skin)))
    for coordinate, angle in zip(origin, angles):
        write_coord(output, coordinate)
        write_angle(output, angle)
    return output


def write_static_sound(
    origin: tuple[float, float, float], sound: int, volume: float, attenuation: float
) -> bytearray:
    """Encode and write static sound to the fixture buffer."""
    output = bytearray((29,))
    for coordinate in origin:
        write_coord(output, coordinate)
    output.extend(
        (
            byte(sound),
            byte(int(c_float_product(volume, 255.0))),
            byte(int(c_float_product(attenuation, 64.0))),
        )
    )
    return output


def direction_byte(value: float) -> int:
    """Compute the reference direction byte value for a deterministic fixture."""
    encoded = int(c_float_product(value, 16.0))
    return max(-128, min(127, encoded))


def write_particle(
    origin: tuple[float, float, float],
    direction: tuple[float, float, float],
    color: int,
    count: int,
) -> bytearray:
    """Encode and write particle to the fixture buffer."""
    output = bytearray((18,))
    for coordinate in origin:
        write_coord(output, coordinate)
    output.extend(byte(direction_byte(component)) for component in direction)
    output.extend((byte(count), byte(color)))
    return output


def quake_c_string(value: bytes) -> bytearray:
    """Reproduce the reference quake c string operation for differential testing."""
    return bytearray(value.split(b"\0", 1)[0]) + bytearray((0,))


def write_name(index: int, value: bytes) -> bytearray:
    """Encode and write name to the fixture buffer."""
    return bytearray((13, byte(index))) + quake_c_string(value)


def write_frags(index: int, value: float | int) -> bytearray:
    """Encode and write frags to the fixture buffer."""
    return bytearray((14, byte(index))) + bytearray(short_bytes(value))


def write_colors(index: int, value: int) -> bytearray:
    """Encode and write colors to the fixture buffer."""
    return bytearray((17, byte(index), byte(value)))


def color_component(value: int) -> int:
    """Compute the reference color component value for a deterministic fixture."""
    result = int(value) & 15
    return min(result, 13)


def expected_model() -> dict[str, Any]:
    """Build the deterministic expected model fixture used by this verifier."""
    origin_a = (-12.25, 0.125, 4095.875)
    angles_a = (90.75, -90.9, 359.9)
    origin_b = (10.0, -20.0, 30.0)
    angles_b = (0.0, 45.0, 90.0)
    long_name = b"12345678901234\xe9X"[:15]

    vectors = [
        vector("static_entity_basic", write_spawn_static(1, 2, 3, 4, origin_a, angles_a)),
        vector("static_entity_wrapped", write_spawn_static(300, -1, 257, 511, origin_b, angles_b)),
        vector("static_sound_basic", write_static_sound(origin_b, 5, 0.5, 1.25)),
        vector("static_sound_wrapped", write_static_sound(origin_a, 300, 1.25, 4.5)),
        vector("particle_basic", write_particle(origin_b, (1.0, -2.0, 0.0625), 7, 20)),
        vector("particle_clamped", write_particle(origin_a, (100.0, -100.0, -7.999), 300, 255)),
        vector("update_name_ascii", write_name(2, b"Ranger")),
        vector("update_name_latin1", write_name(1, b"Jos\xe9")),
        vector("update_name_truncated", write_name(0, long_name)),
        vector("update_frags_negative", write_frags(3, -123)),
        vector("update_frags_wrapped", write_frags(255, 40000)),
        vector("update_colors", write_colors(4, 0xDE)),
        vector("score_reset", write_name(5, b"") + write_frags(5, 0) + write_colors(5, 0)),
        vector("score_triplet", write_name(1, b"Player") + write_frags(1, 42) + write_colors(1, 0x4D)),
        vector("graceful_disconnect_pending", bytearray((8,)) + quake_c_string(b"bye\n") + bytearray((2,))),
    ]
    cases = {
        "particle_count": [
            {"name": "zero", "value": 0},
            {"name": "normal", "value": 254},
            {"name": "explosion", "value": 1024},
        ],
        "datagram_gate": [
            {"name": "exact_margin", "value": 1},
            {"name": "above_margin", "value": 0},
        ],
        "frag_compare": [
            {"name": "equal", "value": 0},
            {"name": "fractional", "value": 1},
            {"name": "int_float_rounding", "value": 0},
        ],
        "stored_frag": [
            {"name": "positive_fraction", "value": 42},
            {"name": "negative_fraction", "value": -42},
        ],
        "player_color": [
            {"name": "normal", "value": color_component(4) * 16 + color_component(13)},
            {"name": "clamped", "value": color_component(14) * 16 + color_component(15)},
            {"name": "negative_mask", "value": color_component(-1) * 16 + color_component(-2)},
        ],
    }
    return {"vectors": vectors, "cases": cases}


def complete_golden(root: Path) -> dict[str, Any]:
    """Build the deterministic complete golden fixture used by this verifier."""
    model = expected_model()
    oracle = root / "tools" / "oracle" / "protocol15_events_oracle.c"
    return {
        "schema": SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "protocol_version": 15,
        "sources": [
            "sv_main.c",
            "host.c",
            "host_cmd.c",
            "pr_cmds.c",
            "cl_parse.c",
            "r_part.c",
            "protocol.h",
        ],
        "vectors": model["vectors"],
        "cases": model["cases"],
        "constants": {
            "SVC_DISCONNECT": 2,
            "SVC_PRINT": 8,
            "SVC_UPDATENAME": 13,
            "SVC_UPDATEFRAGS": 14,
            "SVC_UPDATECOLORS": 17,
            "SVC_PARTICLE": 18,
            "SVC_SPAWNSTATIC": 20,
            "SVC_SPAWNSTATICSOUND": 29,
            "MAX_DATAGRAM": 1024,
            "MAX_PLAYER_NAME_BYTES": 15,
        },
        "reference": {
            "oracle": "tools/oracle/protocol15_events_oracle.c",
            "oracle_sha256": sha256_file(oracle) if oracle.is_file() else "",
        },
        "notes": [
            "PF_ambientsound performs no volume or attenuation clamping.",
            "R_ParseParticleEffect expands wire count 255 to 1024.",
            "SV_StartParticle accepts MAX_DATAGRAM-16 exactly and rejects only larger cursize values.",
            "client_t.old_frags is converted to float for comparison, then current frags is truncated back to int for storage.",
            "SV_DropClient appends svc_disconnect to already queued reliable bytes before closing a sendable graceful connection.",
        ],
    }


def sha256_file(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    import hashlib

    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def parse_oracle(output: str) -> dict[str, Any]:
    """Parse oracle into its normalized representation."""
    rows = [json.loads(line) for line in output.splitlines() if line.strip()]
    vectors = [row for row in rows if row.get("kind") == "vector"]
    cases: dict[str, list[dict[str, Any]]] = {}
    for group in CASE_GROUPS:
        cases[group] = [
            {"name": row["name"], "value": row["value"]}
            for row in rows
            if row.get("kind") == "case" and row.get("group") == group
        ]
    return {"vectors": vectors, "cases": cases}


def function_body(text: str, name: str) -> str:
    """Extract one complete MiniLang function body from source text."""
    pattern = re.compile(rf"(?ms)^function\s+{re.escape(name)}\s*\([^\n]*\)\s*\n(.*?)^end function\s*$")
    match = pattern.search(text)
    return match.group(1) if match else ""


def source_contract(root: Path) -> tuple[list[str], dict[str, Any]]:
    """Build the deterministic source contract fixture used by this verifier."""
    errors: list[str] = []
    paths = {
        "events": "src/miniquake/protocol_events.ml",
        "text": "src/miniquake/protocol_text.ml",
        "server": "src/miniquake/server.ml",
        "svmain": "src/miniquake/sv_main.ml",
        "builtins": "src/miniquake/quakec/builtins.ml",
        "client": "src/miniquake/client_protocol.ml",
        "tests": "tests/protocol15_event_tests.ml",
        "build": "build.ps1",
        "build_info": "src/miniquake/build_info.ml",
    }
    texts: dict[str, str] = {}
    for key, relative in paths.items():
        path = root / relative
        if not path.is_file():
            errors.append(f"missing {relative}")
            texts[key] = ""
        else:
            texts[key] = path.read_text(encoding="utf-8-sig")

    required = {
        "events": [
            "package miniquake.protocol_events",
            "function writeSpawnStatic",
            "function writeStaticSound",
            "function writeParticle",
            "function writeUpdateName",
            "function writeUpdateFrags",
            "function writeUpdateColors",
            "function writeScoreReset",
            "function writeDisconnect",
            "function truncatePlayerName",
            "if value == 255 then return 1024 end if",
            "buffer.curSize <= c.MAX_DATAGRAM - 16",
            "return cFloat(oldFrags) != cFloat(currentFrags)",
            "return native.trunc(cFloat(currentFrags))",
        ],
        "text": ["function truncate(text, maximum)", "slice(encoded, 0, maximum)"],
        "server": [
            "import miniquake.protocol_events as protocolEvents",
            "protocolEvents.writeSpawnStatic(",
            "protocolEvents.writeStaticSound(",
            "protocolEvents.writeParticle(",
            "protocolEvents.writeUpdateName(",
            "protocolEvents.writeUpdateFrags(",
            "protocolEvents.writeUpdateColors(",
            "protocolEvents.writeScoreReset(",
            "protocolEvents.truncatePlayerName(",
            "protocolEvents.writeScoreState(buffer, index, scoreName, other.oldFrags, other.colors)",
            "protocolEvents.writeDisconnect(client.message)",
            "netmain.NET_SendMessage(client.socket, client.message)",
            "client.oldFrags = -999999",
        ],
        "svmain": [
            "import miniquake.protocol_events as protocolEvents",
            "protocolEvents.writeParticle(",
            "protocolEvents.writeUpdateFrags(",
            "protocolEvents.writeScoreReset(",
            "protocolEvents.writeDisconnect(clientValue.message)",
            "netmain.NET_SendMessage(clientValue.socket, clientValue.message)",
            "clientValue.oldFrags = -999999",
        ],
        "builtins": [
            "import miniquake.protocol_events as protocolEvents",
            "protocolEvents.writeSpawnStatic(",
            "protocolEvents.writeStaticSound(",
        ],
        "client": ["protocolEvents.particleCount(msg.readByte(reader))"],
        "tests": [
            "MiniQuake BP-013 Protocol 15 event tests passed: 22",
            "/22]",
            "Host_Spawn_f uses client.old_frags",
            "pending reliable precedes disconnect",
            "fractional value rebroadcasts",
        ],
        "build": [
            'MiniQuakeProtocol15EventTests.exe',
            'check_protocol15_events.py',
            'protocol15_events=',
        ],
        # Component checkers validate their protocol implementation, not the
        # identity of the cumulative package that happens to contain it.
        # Final package lineage is enforced by tools/verify.py and BP-019.
        "build_info": [
            'const COMPATIBILITY_PROFILE = "compat_109"',
            'const NATIVE_TEXT_ABI = "caller_owned_bytes_v1"',
            'const PROTOCOL_TEXT_ABI = "quake_latin1_cstring_v1"',
        ],
    }
    for key, markers in required.items():
        for marker in markers:
            if marker not in texts.get(key, ""):
                errors.append(f"{paths[key]} missing marker: {marker}")

    # Guard the original function boundaries against duplicated manual payloads.
    for key, function, forbidden in (
        ("server", "writeQueuedParticle", "msg.writeByte"),
        ("svmain", "SV_StartParticle", "msg.writeByte"),
        ("builtins", "writeStaticBaseline", "msg.writeByte"),
        ("builtins", "ambientSoundBuiltin", "msg.writeByte"),
    ):
        body = function_body(texts.get(key, ""), function)
        if not body:
            errors.append(f"cannot find function {function} in {paths[key]}")
        elif forbidden in body:
            errors.append(f"{paths[key]}:{function} duplicates manual wire writes")

    for forbidden in (
        "math.clamp(ambient[2]",
        "math.clamp(ambient[3]",
        "math.clamp(parmFloat(machine, 2)",
        "math.clamp(parmFloat(machine, 3)",
    ):
        if forbidden in texts.get("server", "") or forbidden in texts.get("builtins", ""):
            errors.append(f"ambient sound remains clamped: {forbidden}")

    test_text = texts.get("tests", "")
    if not re.search(r'events\.writeParticle\(\s*buffer,\s*t\.Vec3\(10\.0, -20\.0, 30\.0\),\s*t\.Vec3\(1\.0, -2\.0, 0\.0625\),\s*20,\s*7,\s*\)', test_text):
        errors.append("BP-013 particle_basic fixture does not pass count before color to writeParticle")
    if not re.search(r'events\.writeParticle\(\s*buffer,\s*t\.Vec3\(-12\.25, 0\.125, 4095\.875\),\s*t\.Vec3\(100\.0, -100\.0, -7\.999\),\s*255,\s*300,\s*\)', test_text):
        errors.append("BP-013 particle_clamped fixture does not pass count before color to writeParticle")

    fixture_numbers = [int(value) for value in re.findall(r'runTest\("(\d+)"', texts.get("tests", ""))]
    if fixture_numbers != list(range(1, 23)):
        errors.append(f"fixture numbering differs: {fixture_numbers!r}")

    details = {
        "golden_vectors": len(expected_model()["vectors"]),
        "golden_cases": sum(len(values) for values in expected_model()["cases"].values()),
        "minilang_fixtures": len(fixture_numbers),
        "production_modules": 5,
        "shared_writer_families": 8,
    }
    return errors, details


def find_compilers() -> list[str]:
    """Locate compilers from the available inputs."""
    result: list[str] = []
    for candidate in ("gcc", "clang", "cc"):
        path = shutil.which(candidate)
        if path and path not in result:
            result.append(path)
    return result


def compile_oracle(root: Path, compiler: str) -> tuple[dict[str, Any] | None, str]:
    """Compile and execute the C reference oracle with one compiler."""
    source = root / "tools" / "oracle" / "protocol15_events_oracle.c"
    with tempfile.TemporaryDirectory(prefix="bp013-events-") as temp:
        executable = Path(temp) / ("oracle.exe" if os.name == "nt" else "oracle")
        compile_result = subprocess.run(
            [compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-O2", str(source), "-o", str(executable)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=60,
            check=False,
        )
        if compile_result.returncode != 0:
            return None, compile_result.stdout
        run_result = subprocess.run(
            [str(executable)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=30,
            check=False,
        )
        if run_result.returncode != 0:
            return None, run_result.stdout
        try:
            return parse_oracle(run_result.stdout), run_result.stdout
        except (KeyError, json.JSONDecodeError) as exc:
            return None, f"cannot parse C oracle output: {exc}\n{run_result.stdout}"


def verify(root: Path, require_c_oracle: bool = False) -> dict[str, Any]:
    """Evaluate all source, golden and oracle evidence for this verifier."""
    checks: list[dict[str, Any]] = []
    model = expected_model()

    golden_errors: list[str] = []
    golden_path = root / "audit" / "protocol15_events_golden.json"
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8"))
        if golden.get("schema") != SCHEMA:
            golden_errors.append("golden schema differs")
        if golden.get("package_id") != PACKAGE_ID or golden.get("parent_package_id") != PARENT_PACKAGE_ID:
            golden_errors.append("golden package lineage differs")
        if {"vectors": golden.get("vectors"), "cases": golden.get("cases")} != model:
            golden_errors.append("golden vectors/cases differ from independent Python model")
        reference = golden.get("reference") if isinstance(golden.get("reference"), dict) else {}
        oracle_path = root / "tools" / "oracle" / "protocol15_events_oracle.c"
        if reference.get("oracle_sha256") != sha256_file(oracle_path):
            golden_errors.append("golden oracle SHA-256 differs")
    except (OSError, json.JSONDecodeError) as exc:
        golden_errors.append(f"cannot read golden document: {exc}")
    checks.append(
        {
            "name": "python_golden_model",
            "passed": not golden_errors,
            "details": {
                "vectors": len(model["vectors"]),
                "cases": sum(len(values) for values in model["cases"].values()),
            },
            "errors": golden_errors,
            "warnings": [],
        }
    )

    compilers = find_compilers()
    oracle_errors: list[str] = []
    oracle_warnings: list[str] = []
    compiler_outputs: dict[str, str] = {}
    oracle_results: list[dict[str, Any]] = []
    for compiler in compilers:
        result, output = compile_oracle(root, compiler)
        compiler_outputs[Path(compiler).name] = output
        if result is None:
            oracle_errors.append(f"{compiler}: C oracle failed: {output.strip()}")
        else:
            oracle_results.append(result)
            if result != model:
                oracle_errors.append(f"{compiler}: C oracle differs from Python model")
    if not compilers:
        message = "no C compiler found; Python model and bundled C source remain available"
        if require_c_oracle:
            oracle_errors.append(message)
        else:
            oracle_warnings.append(message)
    if len(oracle_results) > 1 and any(result != oracle_results[0] for result in oracle_results[1:]):
        oracle_errors.append("C compiler outputs differ")
    checks.append(
        {
            "name": "c_oracle",
            "passed": not oracle_errors,
            "details": {
                "compilers": [Path(path).name for path in compilers],
                "vectors": len(model["vectors"]),
                "compiler_outputs_byte_identical": len(oracle_results) < 2 or all(result == oracle_results[0] for result in oracle_results),
            },
            "errors": oracle_errors,
            "warnings": oracle_warnings,
        }
    )

    source_errors, source_details = source_contract(root)
    checks.append(
        {
            "name": "minilang_protocol15_event_contract",
            "passed": not source_errors,
            "details": source_details,
            "errors": source_errors,
            "warnings": [],
        }
    )

    return {
        "schema": REPORT_SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "root": str(root),
        "passed": all(check["passed"] for check in checks),
        "checks": checks,
    }


def print_report(report: dict[str, Any]) -> None:
    """Emit report in the requested report format."""
    print("MiniQuake BP-013 Protocol 15 event verification")
    for check in report["checks"]:
        print(f"  [{'PASS' if check['passed'] else 'FAIL'}] {check['name']}")
        for warning in check["warnings"]:
            print(f"         warning: {warning}")
        for error in check["errors"]:
            print(f"         error: {error}")
        if check["details"]:
            print("         " + ", ".join(f"{key}={value}" for key, value in check["details"].items()))
    print("MiniQuake BP-013 Protocol 15 event verification: " + ("PASS" if report["passed"] else "FAIL"))


def main(argv: list[str] | None = None) -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root_arg", nargs="?", type=Path)
    parser.add_argument("--root", type=Path)
    parser.add_argument("--json-output", "--json-out", type=Path)
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--require-c-oracle", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)

    if args.self_test:
        model = expected_model()
        assert len(model["vectors"]) == 15
        assert model["vectors"][5]["bytes"] == "129eff0100ff7f7f8081ff2c"
        assert model["vectors"][14]["bytes"] == "086279650a0002"
        assert model["cases"]["frag_compare"][2]["value"] == 0
        print("MiniQuake BP-013 Protocol 15 event checker self-test: PASS")
        return 0

    root = (args.root or args.root_arg or Path(__file__).resolve().parents[1]).resolve()
    if args.write_golden:
        path = root / "audit" / "protocol15_events_golden.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(complete_golden(root), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    report = verify(root, args.require_c_oracle)
    if args.json_output:
        output = args.json_output
        if not output.is_absolute():
            output = root / output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if not args.quiet:
        print_report(report)
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
