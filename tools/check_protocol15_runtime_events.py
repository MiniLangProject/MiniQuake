#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-014R1 Protocol-15 temp-entity, dynamic-sound and beam-view parity.

The Python model is independent from the MiniLang implementation. When a C
compiler is available, the bundled source-guided C oracle is built with strict
warnings and must produce exactly the same vectors and semantic cases.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path
from typing import Any

PACKAGE_ID = "BP-014R1"
PARENT_PACKAGE_ID = "BP-014"
SCHEMA = "MiniQuakeProtocol15RuntimeEventsGolden/1"
REPORT_SCHEMA = "MiniQuakeBP014R1Protocol15RuntimeEventsVerification/1"
CASE_GROUPS = ("temp_kind", "temp_size", "sound_scalar", "timing", "delivery")


def sha256_file(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def f32(value: float | int) -> float:
    """Round a value through the IEEE-754 binary32 representation."""
    return struct.unpack("<f", struct.pack("<f", float(value)))[0]


def f32_bits(value: float | int) -> int:
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack("<I", struct.pack("<f", f32(value)))[0]


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


def write_position(output: bytearray, value: tuple[float, float, float]) -> None:
    """Encode and write position to the fixture buffer."""
    for coordinate in value:
        write_coord(output, coordinate)


def vector(name: str, output: bytes | bytearray) -> dict[str, Any]:
    """Package one encoded protocol message as a deterministic vector row."""
    raw = bytes(output)
    return {"kind": "vector", "name": name, "bytes": raw.hex(), "length": len(raw)}


def write_temp_point(type_value: int, origin: tuple[float, float, float]) -> bytearray:
    """Encode and write temp point to the fixture buffer."""
    output = bytearray((23, byte(type_value)))
    write_position(output, origin)
    return output


def write_temp_beam(
    type_value: int,
    entity: int,
    start: tuple[float, float, float],
    end: tuple[float, float, float],
) -> bytearray:
    """Encode and write temp beam to the fixture buffer."""
    output = bytearray((23, byte(type_value)))
    output.extend(short_bytes(entity))
    write_position(output, start)
    write_position(output, end)
    return output


def write_temp_explosion2(
    origin: tuple[float, float, float], color_start: int, color_length: int
) -> bytearray:
    """Encode and write temp explosion2 to the fixture buffer."""
    output = bytearray((23, 12))
    write_position(output, origin)
    output.extend((byte(color_start), byte(color_length)))
    return output


def pack_sound_channel(entity: int, channel: int) -> int:
    """Encode sound channel using the Protocol 15 layout."""
    return (int(entity) << 3) | (int(channel) & 7)


def write_stop_sound(entity: int, channel: int) -> bytearray:
    """Encode and write stop sound to the fixture buffer."""
    return bytearray((16,)) + bytearray(short_bytes(pack_sound_channel(entity, channel)))


def sound_field_mask(volume: int, attenuation: float) -> int:
    """Build the deterministic sound field mask fixture used by this verifier."""
    result = 0
    if int(volume) != 255:
        result |= 1
    if f32(attenuation) != 1.0:
        result |= 2
    return result


def write_dynamic_sound(
    entity: int,
    channel: int,
    sound: int,
    volume: int,
    attenuation: float,
    origin: tuple[float, float, float],
) -> bytearray:
    """Encode and write dynamic sound to the fixture buffer."""
    attenuation = f32(attenuation)
    mask = sound_field_mask(volume, attenuation)
    output = bytearray((6, mask))
    if mask & 1:
        output.append(byte(volume))
    if mask & 2:
        output.append(byte(int(c_float_product(attenuation, 64.0))))
    output.extend(short_bytes(pack_sound_channel(entity, channel)))
    output.append(byte(sound))
    write_position(output, origin)
    return output


def temp_kind(type_value: int) -> int:
    """Build the deterministic temp kind fixture used by this verifier."""
    if type_value in (0, 1, 2, 3, 4, 7, 8, 10, 11):
        return 1
    if type_value in (5, 6, 9, 13):
        return 2
    if type_value == 12:
        return 3
    return 0


def temp_size(type_value: int) -> int:
    """Build the deterministic temp size fixture used by this verifier."""
    return {1: 8, 2: 16, 3: 10}.get(temp_kind(type_value), 0)


def reliable_plan(overflowed: bool, message_size: int, drop_asap: bool, can_send: bool) -> int:
    """Build the deterministic reliable plan fixture used by this verifier."""
    if overflowed:
        return 1
    if message_size <= 0 and not drop_asap:
        return 0
    if not can_send:
        return 2
    if drop_asap:
        return 3
    return 4


def expected_model() -> dict[str, Any]:
    """Build the deterministic expected model fixture used by this verifier."""
    origin_a = (10.0, -20.0, 30.0)
    origin_b = (-12.25, 0.125, 4095.875)
    rounded_default = f32(1.00000001)
    vectors = [
        vector("temp_point_spike", write_temp_point(0, origin_a)),
        vector("temp_point_wrapped", write_temp_point(11, origin_b)),
        vector("temp_beam_lightning", write_temp_beam(5, 300, origin_a, origin_b)),
        vector("temp_beam_wrapped", write_temp_beam(13, -1, origin_b, origin_a)),
        vector("temp_explosion2", write_temp_explosion2(origin_a, 0x12, 0x34)),
        vector("stop_sound", write_stop_sound(300, 7)),
        vector("dynamic_sound_default", write_dynamic_sound(300, 2, 5, 255, 1.0, origin_a)),
        vector("dynamic_sound_options", write_dynamic_sound(1, 7, 300, 128, 0.5, origin_b)),
        vector("dynamic_sound_rounded_default", write_dynamic_sound(3, 2, 5, 255, rounded_default, origin_a)),
        vector("reconnect", bytearray((9,)) + bytearray(b"reconnect\n\0")),
    ]
    temp_kind_cases = [{"name": f"type_{value}", "value": temp_kind(value)} for value in range(14)]
    temp_size_cases = [{"name": f"type_{value}", "value": temp_size(value)} for value in range(14)]
    center_sum = f32(f32(-1.5) + f32(2.25))
    center_x = f32(f32(-12.25) + 0.5 * center_sum)
    beam_end = f32(1.0 + 0.2)
    dlight_die = f32(1.0 + 0.5)
    cases = {
        "temp_kind": temp_kind_cases,
        "temp_size": temp_size_cases,
        "sound_scalar": [
            {"name": "qc_channel_2_9", "value": int(f32(2.9))},
            {"name": "qc_volume_half", "value": int(c_float_product(0.5, 255.0))},
            {"name": "rounded_default_mask", "value": sound_field_mask(255, rounded_default)},
            {"name": "client_volume_bits", "value": f32_bits(128 / 255.0)},
            {"name": "client_attenuation_bits", "value": f32_bits(32 / 64.0)},
            {"name": "static_volume_bits", "value": f32_bits(127 / 255.0)},
            {"name": "static_attenuation_bits", "value": f32_bits(80.0)},
            {"name": "center_x_bits", "value": f32_bits(center_x)},
            {"name": "packed_300_7", "value": pack_sound_channel(300, 7)},
        ],
        "timing": [
            {"name": "beam_end_bits", "value": f32_bits(beam_end)},
            {"name": "dlight_die_bits", "value": f32_bits(dlight_die)},
            {"name": "beam_alive_equal", "value": int(beam_end >= float(beam_end))},
            {"name": "beam_expired_after", "value": int(beam_end < float(beam_end) + 0.0001)},
        ],
        "delivery": [
            {"name": "dynamic_exact_margin", "value": 1},
            {"name": "dynamic_above_margin", "value": 0},
            {"name": "keepalive_equal", "value": 4},
            {"name": "keepalive_above", "value": 2},
            {"name": "overflow_precedes_drop", "value": reliable_plan(True, 1, True, True)},
            {"name": "drop_waits_blocked", "value": reliable_plan(False, 0, True, False)},
            {"name": "drop_when_sendable", "value": reliable_plan(False, 0, True, True)},
            {"name": "max_beams", "value": 24},
        ],
    }
    return {"vectors": vectors, "cases": cases}


def complete_golden(root: Path) -> dict[str, Any]:
    """Build the deterministic complete golden fixture used by this verifier."""
    model = expected_model()
    oracle = root / "tools" / "oracle" / "protocol15_runtime_events_oracle.c"
    return {
        "schema": SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "protocol_version": 15,
        "sources": ["cl_tent.c", "cl_parse.c", "sv_main.c", "host.c", "pr_cmds.c", "protocol.h"],
        "vectors": model["vectors"],
        "cases": model["cases"],
        "constants": {
            "SVC_SOUND": 6,
            "SVC_STUFFTEXT": 9,
            "SVC_STOPSOUND": 16,
            "SVC_TEMP_ENTITY": 23,
            "MAX_DATAGRAM": 1024,
            "MAX_BEAMS": 24,
            "MAX_EDICTS": 600,
        },
        "reference": {
            "oracle": "tools/oracle/protocol15_runtime_events_oracle.c",
            "oracle_sha256": sha256_file(oracle) if oracle.is_file() else "",
        },
        "notes": [
            "CL_ParseBeam replaces the same entity before searching the first free or strictly expired slot.",
            "The retained fixed-slot beam state remains separate from the CL_UpdateTEnts active view; expired slots stay reusable but are not rendered.",
            "Beam and dynamic-light expiry fields are IEEE-754 binary32 even though cl.time is double.",
            "CL_ParseStartSoundPacket converts optional attenuation and mixer volume to binary32.",
            "SV_StartSound accepts MAX_DATAGRAM-16 exactly and drops only larger cursize values.",
            "SV_ConnectClient resets the sticky reliable-message overflow bit through memset semantics.",
            "Keepalive NOPs use elapsed > 5, not elapsed >= 5, and reliable overflow precedes dropasap.",
        ],
    }


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
        "transients": "src/miniquake/protocol_transients.ml",
        "serverdata": "src/miniquake/protocol_serverdata.ml",
        "client": "src/miniquake/client_protocol.ml",
        "effects": "src/miniquake/client_effects.ml",
        "tent": "src/miniquake/temp_entities.ml",
        "server": "src/miniquake/server.ml",
        "svmain": "src/miniquake/sv_main.ml",
        "builtins": "src/miniquake/quakec/builtins.ml",
        "tests": "tests/protocol15_runtime_event_tests.ml",
        "build": "build.ps1",
        "acceptance": "scripts/TEST_BP-014R1.ps1",
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
        "transients": [
            "package miniquake.protocol_transients",
            "function writePoint",
            "function writeBeam",
            "function writeExplosion2",
            "function writeStopSound",
            "function writeReconnect",
            "function dynamicSoundWireSize",
            "buffer.curSize <= c.MAX_DATAGRAM - 16",
            "function updateCompactBeamListResult",
            "same entity owns its previous slot",
            "while slot < MAX_BEAMS",
            "return [normalized, false, -1]",
            "function beamEndTime",
            "function activeCompactBeamList",
            "function dynamicLightDieTime",
            "function clientSoundVolume",
            "function clientSoundAttenuation",
            "return cFloat(native.trunc(volumeByte) / 255.0)",
        ],
        "serverdata": [
            "import miniquake.protocol_transients as transients",
            "transients.soundFieldMask",
            "transients.soundAttenuationByte",
            "transients.packSoundChannel",
        ],
        "client": [
            "import miniquake.protocol_transients as transients",
            "transients.clientSoundAttenuation",
            "transients.soundEntity(channel)",
        ],
        "effects": [
            "transients.updateCompactBeamList",
            "transients.activeCompactBeamList",
            "function retainTemporarySlots",
            "currentTemporary = retainTemporarySlots(currentTemporary)",
            "transients.clientSoundVolume",
            "transients.staticSoundVolume",
        ],
        "tent": [
            "kind = transients.tempKind(type)",
            "transients.beamEndTime(currentTime)",
            "transients.dynamicLightDieTime(currentTime)",
            "transients.beamAlive(beam.endTime, currentTime)",
        ],
        "server": [
            "function resetClientMessageForConnect",
            "clientValue.message.allowOverflow = true",
            "clientValue.message.overflowed = false",
            "resetClientMessageForConnect(selected)",
            "transients.canWriteDynamicSound(server.datagram)",
            "transients.soundCenter(item.origin, item.mins, item.maxs)",
            "transients.writeReconnect(buffer)",
        ],
        "svmain": [
            "transients.soundCenter(item.origin, item.mins, item.maxs)",
            "transients.writeReconnect(buffer)",
            "clientValue.lastMessage = state.realtime",
        ],
        "builtins": [
            "transients.quakeCSoundChannel",
            "transients.quakeCSoundVolumeByte",
            "transients.quakeCSoundAttenuation",
        ],
        "tests": [
            "MiniQuake BP-014R1 Protocol 15 runtime-event tests passed: 28",
            "/28]",
            "expired same entity retains original slot",
            "sticky overflow reset",
            "keepalive equality waits",
            "static volume mixer normalization",
            "expired beam absent from active view",
            "expired beam slot retained",
        ],
        "build": [
            "MiniQuakeProtocol15RuntimeEventTests.exe",
            "check_protocol15_runtime_events.py",
            "protocol15_runtime_events=",
        ],
        "acceptance": [
            "check_protocol15_runtime_events.py",
            "bp014r1-protocol15-runtime-events.json",
            "MiniQuakeProtocol15RuntimeEventTests.exe",
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

    transients_text = texts.get("transients", "")
    static_volume_body = function_body(transients_text, "staticSoundVolume")
    if "return cFloat(native.trunc(volumeByte) / 255.0)" not in static_volume_body:
        errors.append("protocol_transients.ml:staticSoundVolume must normalize the byte for MixerChannel.volume")
    compact_update_body = function_body(transients_text, "updateCompactBeamListResult")
    if "if item[0].entity == value.entity then" not in compact_update_body:
        errors.append("protocol_transients.ml:updateCompactBeamListResult lost same-entity slot priority")

    active_view_body = function_body(transients_text, "activeCompactBeamList")
    if "normalizeCompactBeamList(beams)" not in active_view_body or "beamAlive(item[1], currentTime)" not in active_view_body:
        errors.append("protocol_transients.ml:activeCompactBeamList must filter normalized retained state with beamAlive")
    effects_text = texts.get("effects", "")
    retain_body = function_body(effects_text, "retainTemporarySlots")
    prune_body = function_body(effects_text, "pruneTemporary")
    process_body = function_body(effects_text, "process")
    if "transients.normalizeCompactBeamList(currentTemporary)" not in retain_body:
        errors.append("client_effects.ml:retainTemporarySlots no longer preserves the compact fixed-slot state")
    if "transients.activeCompactBeamList(currentTemporary, currentTime)" not in prune_body:
        errors.append("client_effects.ml:pruneTemporary no longer exposes only the active CL_UpdateTEnts view")
    if "currentTemporary = retainTemporarySlots(currentTemporary)" not in process_body:
        errors.append("client_effects.ml:process must retain expired slots instead of pruning the stored beam state")
    if "currentTemporary = pruneTemporary(currentTemporary, currentTime)" in process_body:
        errors.append("client_effects.ml:process still destroys expired slot ownership through pruneTemporary")

    # The production adapters must call shared helpers rather than rebuilding
    # temporary-entity or sound payloads by hand.
    for key, function, forbidden in (
        ("serverdata", "writeSound", "(entityValue << 3)"),
        ("effects", "processTemporary", "currentTime + 0.2"),
        ("tent", "parseType", "type == c.TE_LIGHTNING1"),
        ("server", "acceptLocal", "sz.clear(selected.message)"),
    ):
        body = function_body(texts.get(key, ""), function)
        if not body:
            errors.append(f"cannot find function {function} in {paths[key]}")
        elif forbidden in body:
            errors.append(f"{paths[key]}:{function} retains forbidden duplicate/unsafe logic: {forbidden}")

    tests_text = texts.get("tests", "")
    if 'assertEqual(second[2], 0, "expired first beam slot reused")' not in tests_text:
        errors.append("BP-014 expired beam fixture must reuse slot zero for a different entity")
    if 'assertEqual(second[0][0][0].entity, 7, "reused slot stores new entity")' not in tests_text:
        errors.append("BP-014 expired beam fixture does not verify replacement payload ownership")

    fixture_numbers = [int(value) for value in re.findall(r'runTest\("(\d+)"', texts.get("tests", ""))]
    if fixture_numbers != list(range(1, 29)):
        errors.append(f"fixture numbering differs: {fixture_numbers!r}")

    model = expected_model()
    details = {
        "golden_vectors": len(model["vectors"]),
        "golden_cases": sum(len(values) for values in model["cases"].values()),
        "minilang_fixtures": len(fixture_numbers),
        "temporary_entity_types": 14,
        "beam_slots": 24,
        "production_modules": 7,
        "beam_state_view_separation": True,
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
    source = root / "tools" / "oracle" / "protocol15_runtime_events_oracle.c"
    with tempfile.TemporaryDirectory(prefix="bp014r1-runtime-events-") as temp:
        executable = Path(temp) / ("oracle.exe" if os.name == "nt" else "oracle")
        compiled = subprocess.run(
            [compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-O2", str(source), "-o", str(executable)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=60,
            check=False,
        )
        if compiled.returncode != 0:
            return None, compiled.stdout
        executed = subprocess.run(
            [str(executable)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=30,
            check=False,
        )
        if executed.returncode != 0:
            return None, executed.stdout
        try:
            return parse_oracle(executed.stdout), executed.stdout
        except (KeyError, json.JSONDecodeError) as exc:
            return None, f"cannot parse C oracle output: {exc}\n{executed.stdout}"


def verify(root: Path, require_c_oracle: bool = False) -> dict[str, Any]:
    """Evaluate all source, golden and oracle evidence for this verifier."""
    checks: list[dict[str, Any]] = []
    model = expected_model()

    golden_errors: list[str] = []
    golden_path = root / "audit" / "protocol15_runtime_events_golden.json"
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8"))
        if golden.get("schema") != SCHEMA:
            golden_errors.append("golden schema differs")
        if golden.get("package_id") != PACKAGE_ID or golden.get("parent_package_id") != PARENT_PACKAGE_ID:
            golden_errors.append("golden package lineage differs")
        if {"vectors": golden.get("vectors"), "cases": golden.get("cases")} != model:
            golden_errors.append("golden vectors/cases differ from independent Python model")
        reference = golden.get("reference") if isinstance(golden.get("reference"), dict) else {}
        oracle = root / "tools" / "oracle" / "protocol15_runtime_events_oracle.c"
        if reference.get("oracle_sha256") != sha256_file(oracle):
            golden_errors.append("golden oracle SHA-256 differs")
    except (OSError, json.JSONDecodeError) as exc:
        golden_errors.append(f"cannot read golden document: {exc}")
    checks.append({
        "name": "python_golden_model",
        "passed": not golden_errors,
        "details": {"vectors": len(model["vectors"]), "cases": sum(len(v) for v in model["cases"].values())},
        "errors": golden_errors,
        "warnings": [],
    })

    compilers = find_compilers()
    oracle_errors: list[str] = []
    oracle_warnings: list[str] = []
    results: list[dict[str, Any]] = []
    for compiler in compilers:
        result, output = compile_oracle(root, compiler)
        if result is None:
            oracle_errors.append(f"{compiler}: C oracle failed: {output.strip()}")
        else:
            results.append(result)
            if result != model:
                oracle_errors.append(f"{compiler}: C oracle differs from Python model")
    if not compilers:
        message = "no C compiler found; Python model and bundled C source remain available"
        if require_c_oracle:
            oracle_errors.append(message)
        else:
            oracle_warnings.append(message)
    if len(results) > 1 and any(result != results[0] for result in results[1:]):
        oracle_errors.append("C compiler outputs differ")
    checks.append({
        "name": "c_oracle",
        "passed": not oracle_errors,
        "details": {
            "compilers": [Path(value).name for value in compilers],
            "vectors": len(model["vectors"]),
            "compiler_outputs_byte_identical": len(results) < 2 or all(value == results[0] for value in results),
        },
        "errors": oracle_errors,
        "warnings": oracle_warnings,
    })

    source_errors, source_details = source_contract(root)
    checks.append({
        "name": "minilang_protocol15_runtime_event_contract",
        "passed": not source_errors,
        "details": source_details,
        "errors": source_errors,
        "warnings": [],
    })

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
    print("MiniQuake BP-014R1 Protocol 15 runtime-event verification")
    for check in report["checks"]:
        print(f"  [{'PASS' if check['passed'] else 'FAIL'}] {check['name']}")
        for warning in check["warnings"]:
            print(f"         warning: {warning}")
        for error in check["errors"]:
            print(f"         error: {error}")
        if check["details"]:
            print("         " + ", ".join(f"{key}={value}" for key, value in check["details"].items()))
    print("MiniQuake BP-014R1 Protocol 15 runtime-event verification: " + ("PASS" if report["passed"] else "FAIL"))


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
        assert len(model["vectors"]) == 10
        assert model["vectors"][0]["bytes"] == "1700500060fff000"
        assert model["vectors"][7]["bytes"] == "060380200f002c9eff0100ff7f"
        assert model["vectors"][9]["bytes"] == "097265636f6e6e6563740a00"
        assert len(model["cases"]["temp_kind"]) == 14
        assert model["cases"]["delivery"][2]["value"] == 4
        print("MiniQuake BP-014R1 Protocol 15 runtime-event checker self-test: PASS")
        return 0

    root = (args.root or args.root_arg or Path(__file__).resolve().parents[1]).resolve()
    if args.write_golden:
        path = root / "audit" / "protocol15_runtime_events_golden.json"
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
