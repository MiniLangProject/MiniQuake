#!/usr/bin/env python3
"""BP-012R1 Protocol 15 server-data golden-vector verifier.

The Python model is intentionally independent of the MiniLang implementation.
When a C compiler is available, a compact source-derived oracle is built and
its byte streams are compared with the bound golden document as a second
implementation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from typing import Any

PACKAGE_ID = "BP-012R1"
PARENT_PACKAGE_ID = "BP-012"
GOLDEN_SCHEMA = "MiniQuakeProtocol15ServerDataGolden/1"
REPORT_SCHEMA = "MiniQuakeProtocol15ServerDataReport/1"

SVC = {
    "setview": 5,
    "sound": 6,
    "print": 8,
    "setangle": 10,
    "serverinfo": 11,
    "clientdata": 15,
    "damage": 19,
    "spawnbaseline": 22,
    "signonnum": 25,
    "cdtrack": 32,
}
PROTOCOL_VERSION = 15
GAME_COOP = 0
GAME_DEATHMATCH = 1
SND_VOLUME = 1
SND_ATTENUATION = 2
SU_VIEWHEIGHT = 1
SU_IDEALPITCH = 2
SU_PUNCH1 = 4
SU_VELOCITY1 = 32
SU_ITEMS = 512
SU_ONGROUND = 1024
SU_INWATER = 2048
SU_WEAPONFRAME = 4096
SU_ARMOR = 8192
SU_WEAPON = 16384
FL_ONGROUND = 512

PLAN_SEND_UNRELIABLE = 1
PLAN_SEND_NOP = 2
PLAN_WAIT_SIGNON = 4
PLAN_RELIABLE_PHASE = 8
RELIABLE_NONE = 0
RELIABLE_DROP_OVERFLOW = 1
RELIABLE_WAIT = 2
RELIABLE_DROP_ASAP = 3
RELIABLE_SEND = 4


@dataclass
class Check:
    name: str
    passed: bool
    details: dict[str, Any] = field(default_factory=dict)
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


class Writer:
    def __init__(self) -> None:
        self.data = bytearray()

    def byte(self, value: int | float | bool) -> None:
        self.data.append(int(value) & 0xFF)

    char = byte

    def short(self, value: int | float) -> None:
        self.data += struct.pack("<H", int(value) & 0xFFFF)

    def long(self, value: int | float) -> None:
        self.data += struct.pack("<I", int(value) & 0xFFFFFFFF)

    def float32(self, value: int | float) -> float:
        return struct.unpack("<f", struct.pack("<f", float(value)))[0]

    def string(self, value: str) -> None:
        self.data += value.encode("latin-1") + b"\0"

    def coord(self, value: int | float) -> None:
        self.short(int(self.float32(value) * 8.0))

    def angle(self, value: int | float) -> None:
        rounded = self.float32(value)
        self.byte(int((int(rounded) * 256) / 360) & 0xFF)

    def vector(self, name: str) -> dict[str, Any]:
        return {"name": name, "bytes": self.data.hex(), "length": len(self.data)}


def write_precache_list(w: Writer, values: list[str]) -> None:
    for value in values[1:]:
        if not value:
            break
        w.string(value)
    w.byte(0)


def write_serverinfo(
    w: Writer,
    crc: int,
    maxclients: int,
    game_type: int,
    level: str,
    models: list[str],
    sounds: list[str],
    cdtrack: int,
    viewentity: int,
) -> None:
    w.byte(SVC["print"])
    w.string(chr(2) + "\nVERSION 1.09 SERVER (" + str(int(crc)) + " CRC)")
    w.byte(SVC["serverinfo"])
    w.long(PROTOCOL_VERSION)
    w.byte(maxclients)
    w.byte(game_type)
    w.string(level)
    write_precache_list(w, models)
    write_precache_list(w, sounds)
    w.byte(SVC["cdtrack"])
    w.byte(cdtrack)
    w.byte(cdtrack)
    w.byte(SVC["setview"])
    w.short(viewentity)
    w.byte(SVC["signonnum"])
    w.byte(1)


def write_sound(
    w: Writer,
    entity: int,
    channel: int,
    sound: int,
    volume: int,
    attenuation: float,
    center: tuple[float, float, float],
) -> None:
    channel = int(channel)
    volume = int(volume)
    attenuation = w.float32(attenuation)
    mask = 0
    if volume != 255:
        mask |= SND_VOLUME
    if attenuation != 1.0:
        mask |= SND_ATTENUATION
    w.byte(SVC["sound"])
    w.byte(mask)
    if mask & SND_VOLUME:
        w.byte(volume)
    if mask & SND_ATTENUATION:
        w.byte(attenuation * 64.0)
    w.short((entity << 3) | int(channel))
    w.byte(sound)
    for value in center:
        w.coord(value)


def write_baseline(
    w: Writer,
    entity: int,
    model: int,
    frame: int,
    colormap: int,
    skin: int,
    origin: tuple[float, float, float],
    angles: tuple[float, float, float],
) -> None:
    w.byte(SVC["spawnbaseline"])
    w.short(entity)
    w.byte(model)
    w.byte(frame)
    w.byte(colormap)
    w.byte(skin)
    for axis in range(3):
        w.coord(origin[axis])
        w.angle(angles[axis])


def clientdata_bits(data: dict[str, Any]) -> int:
    bits = SU_ITEMS | SU_WEAPON
    if data["view_height"] != 22:
        bits |= SU_VIEWHEIGHT
    if data["ideal_pitch"] != 0.0:
        bits |= SU_IDEALPITCH
    if int(data["flags"]) & FL_ONGROUND:
        bits |= SU_ONGROUND
    if int(data["water_level"]) >= 2:
        bits |= SU_INWATER
    for axis in range(3):
        if data["punch"][axis] != 0.0:
            bits |= SU_PUNCH1 << axis
        if data["velocity"][axis] != 0.0:
            bits |= SU_VELOCITY1 << axis
    if data["weapon_frame"] != 0.0:
        bits |= SU_WEAPONFRAME
    if data["armor"] != 0.0:
        bits |= SU_ARMOR
    return bits


def write_clientdata(w: Writer, data: dict[str, Any]) -> int:
    bits = clientdata_bits(data)
    w.byte(SVC["clientdata"])
    w.short(bits)
    if bits & SU_VIEWHEIGHT:
        w.char(data["view_height"])
    if bits & SU_IDEALPITCH:
        w.char(data["ideal_pitch"])
    for axis in range(3):
        if bits & (SU_PUNCH1 << axis):
            w.char(data["punch"][axis])
        if bits & (SU_VELOCITY1 << axis):
            w.char(data["velocity"][axis] / 16.0)
    w.long(data["items"])
    if bits & SU_WEAPONFRAME:
        w.byte(data["weapon_frame"])
    if bits & SU_ARMOR:
        w.byte(data["armor"])
    w.byte(data["weapon_model"])
    w.short(data["health"])
    for key in ("current_ammo", "shells", "nails", "rockets", "cells"):
        w.byte(data[key])
    if data["standard_quake"]:
        w.byte(data["active_weapon"])
    else:
        active = int(data["active_weapon"])
        for bit in range(32):
            if active & (1 << bit):
                w.byte(bit)
                break
    return bits


def default_clientdata() -> dict[str, Any]:
    return {
        "view_height": 22,
        "ideal_pitch": 0.0,
        "punch": (0.0, 0.0, 0.0),
        "velocity": (0.0, 0.0, 0.0),
        "flags": 0,
        "water_level": 0,
        "weapon_frame": 0.0,
        "armor": 0.0,
        "weapon_model": 2,
        "health": 100,
        "current_ammo": 10,
        "shells": 11,
        "nails": 12,
        "rockets": 13,
        "cells": 14,
        "items": 0x12345678,
        "active_weapon": 1,
        "standard_quake": True,
    }


def python_vectors() -> list[dict[str, Any]]:
    vectors: list[dict[str, Any]] = []

    w = Writer()
    write_serverinfo(
        w, 5927, 1, GAME_COOP, "The Slipgate Complex",
        ["", "maps/e1m1.bsp", "progs/player.mdl", "", "ignored.mdl"],
        ["", "misc/menu1.wav", "", "ignored.wav"], 2, 1,
    )
    vectors.append(w.vector("serverinfo_coop"))

    w = Writer()
    write_serverinfo(
        w, 12345, 4, GAME_DEATHMATCH, "Place of Two Deaths",
        ["", "maps/dm1.bsp", ""], ["", ""], 0, 4,
    )
    vectors.append(w.vector("serverinfo_deathmatch"))

    w = Writer(); write_sound(w, 3, 2.9, 5, 255.9, 1.0000000298023224, (10.0, -20.0, 30.0))
    vectors.append(w.vector("sound_default"))
    w = Writer(); write_sound(w, 300, 7, 255, 128, 0.5, (-12.25, 0.125, 4095.875))
    vectors.append(w.vector("sound_custom"))
    w = Writer(); write_sound(w, 3, 2, 5, 255, 1.00000001, (10.0, -20.0, 30.0))
    vectors.append(w.vector("sound_float_parameter_rounding"))

    data = {
        "view_height": 22.0, "ideal_pitch": 0.0,
        "punch": (0.0, 0.0, 0.0), "velocity": (0.0, 0.0, 0.0),
        "flags": 0, "water_level": 0, "weapon_frame": 0.0, "armor": 0.0,
        "weapon_model": 3, "health": 100, "current_ammo": 40,
        "shells": 25, "nails": 50, "rockets": 5, "cells": 100,
        "items": 0x12345678, "active_weapon": 2, "standard_quake": True,
    }
    w = Writer(); bits = write_clientdata(w, data)
    vector = w.vector("clientdata_minimal"); vector["bits"] = bits; vectors.append(vector)

    data = dict(data)
    data.update({
        "view_height": 30.0, "ideal_pitch": -5.0,
        "punch": (1.0, -2.0, 3.0), "velocity": (16.0, -32.0, 48.0),
        "flags": FL_ONGROUND, "water_level": 2,
        "weapon_frame": 300.0, "armor": -1.0, "weapon_model": 257,
        "health": -20, "current_ammo": 300, "shells": -1,
        "nails": 256, "rockets": 511, "cells": 128,
        "items": 0xF1234567, "active_weapon": 260,
    })
    w = Writer(); bits = write_clientdata(w, data)
    vector = w.vector("clientdata_full_standard"); vector["bits"] = bits; vectors.append(vector)

    data = {
        "view_height": 22.0, "ideal_pitch": 0.0,
        "punch": (0.0, 0.0, 0.0), "velocity": (0.0, 0.0, 0.0),
        "flags": 0, "water_level": 0, "weapon_frame": 0.0, "armor": 0.0,
        "weapon_model": 4, "health": 80, "current_ammo": 12,
        "shells": 13, "nails": 14, "rockets": 15, "cells": 16,
        "items": 0x00800001, "active_weapon": 1 << 7, "standard_quake": False,
    }
    w = Writer(); bits = write_clientdata(w, data)
    vector = w.vector("clientdata_missionpack"); vector["bits"] = bits; vectors.append(vector)

    data = dict(data); data["active_weapon"] = 0
    w = Writer(); bits = write_clientdata(w, data)
    vector = w.vector("clientdata_missionpack_zero"); vector["bits"] = bits; vectors.append(vector)

    w = Writer(); write_baseline(w, 0, 1, 2, 0, 4, (-12.25, 0.125, 4095.875), (90.75, -90.9, 359.9))
    vectors.append(w.vector("baseline_world"))
    w = Writer(); write_baseline(w, 1, 2, 3, 1, 5, (10.0, 20.0, 30.0), (0.0, 45.0, 90.0))
    vectors.append(w.vector("baseline_player"))
    return vectors


def initial_delivery_plan(spawned: bool, send_signon: bool, elapsed: float) -> int:
    if spawned:
        return PLAN_SEND_UNRELIABLE | PLAN_RELIABLE_PHASE
    if not send_signon:
        if elapsed > 5.0:
            return PLAN_SEND_NOP
        return PLAN_WAIT_SIGNON
    return PLAN_RELIABLE_PHASE


def reliable_delivery_plan(overflowed: bool, size: int, drop_asap: bool, can_send: bool) -> int:
    if overflowed:
        return RELIABLE_DROP_OVERFLOW
    if size <= 0 and not drop_asap:
        return RELIABLE_NONE
    if not can_send:
        return RELIABLE_WAIT
    if drop_asap:
        return RELIABLE_DROP_ASAP
    return RELIABLE_SEND


def initial_cases() -> list[dict[str, Any]]:
    rows = [
        ("spawned", True, False, 0.0),
        ("spawned_signon_flag", True, True, 9.0),
        ("signon_requested", False, True, 0.0),
        ("wait_before_five", False, False, 4.999),
        ("wait_at_five", False, False, 5.0),
        ("nop_after_five", False, False, 5.001),
    ]
    return [
        {"name": name, "spawned": spawned, "send_signon": signon, "elapsed": elapsed,
         "plan": initial_delivery_plan(spawned, signon, elapsed)}
        for name, spawned, signon, elapsed in rows
    ]


def reliable_cases() -> list[dict[str, Any]]:
    rows = [
        ("overflow", True, 1, False, True),
        ("empty", False, 0, False, False),
        ("blocked_message", False, 1, False, False),
        ("blocked_dropasap", False, 0, True, False),
        ("dropasap_empty", False, 0, True, True),
        ("dropasap_message", False, 4, True, True),
        ("send_one", False, 1, False, True),
        ("send_full", False, 8192, False, True),
    ]
    return [
        {"name": name, "overflowed": overflowed, "message_size": size,
         "drop_asap": drop_asap, "can_send": can_send,
         "plan": reliable_delivery_plan(overflowed, size, drop_asap, can_send)}
        for name, overflowed, size, drop_asap, can_send in rows
    ]


def datagram_cases() -> list[dict[str, Any]]:
    rows = [
        ("empty_source", 8, 0, 16),
        ("strictly_below", 8, 7, 16),
        ("equal_rejected", 8, 8, 16),
        ("above_rejected", 9, 8, 16),
        ("empty_equal_rejected", 16, 0, 16),
    ]
    return [
        {"name": name, "destination_size": dest, "source_size": source, "max_size": max_size,
         "append": dest + source < max_size}
        for name, dest, source, max_size in rows
    ]


def encoded_update_size(bits: int) -> int:
    count = 1
    if bits & 1:  # U_MOREBITS
        count += 1
    count += 2 if bits & 16384 else 1  # U_LONGENTITY
    for field in (1024, 64, 2048, 4096, 8192):
        if bits & field: count += 1
    for field in (2, 4, 8):
        if bits & field: count += 2
    for field in (256, 16, 512):
        if bits & field: count += 1
    return count


def can_write_fast_update(remaining: int, bits: int) -> bool:
    return remaining >= 16 and encoded_update_size(bits) <= remaining


def fast_update_cases() -> list[dict[str, Any]]:
    full_short = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 256 | 512 | 1024 | 2048 | 4096 | 8192
    full_long = full_short | 16384
    rows = [
        ("remaining_15_unchanged", 15, 0),
        ("remaining_16_unchanged", 16, 0),
        ("remaining_16_full_short", 16, full_short),
        ("remaining_17_full_short", 17, full_short),
        ("remaining_17_full_long", 17, full_long),
        ("remaining_18_full_long", 18, full_long),
    ]
    return [
        {"name": name, "remaining": remaining, "bits": bits,
         "encoded_size": encoded_update_size(bits),
         "can_write": can_write_fast_update(remaining, bits)}
        for name, remaining, bits in rows
    ]


def constants() -> dict[str, int]:
    return {
        "PROTOCOL_VERSION": PROTOCOL_VERSION,
        "SVC_PRINT": SVC["print"],
        "SVC_SERVERINFO": SVC["serverinfo"],
        "SVC_CDTRACK": SVC["cdtrack"],
        "SVC_SETVIEW": SVC["setview"],
        "SVC_SIGNONNUM": SVC["signonnum"],
        "SVC_SOUND": SVC["sound"],
        "SVC_SPAWNBASELINE": SVC["spawnbaseline"],
        "SVC_CLIENTDATA": SVC["clientdata"],
        "SND_VOLUME": SND_VOLUME,
        "SND_ATTENUATION": SND_ATTENUATION,
        "SU_VIEWHEIGHT": SU_VIEWHEIGHT,
        "SU_IDEALPITCH": SU_IDEALPITCH,
        "SU_ITEMS": SU_ITEMS,
        "SU_ONGROUND": SU_ONGROUND,
        "SU_INWATER": SU_INWATER,
        "SU_WEAPONFRAME": SU_WEAPONFRAME,
        "SU_ARMOR": SU_ARMOR,
        "SU_WEAPON": SU_WEAPON,
        "PLAN_SEND_UNRELIABLE": PLAN_SEND_UNRELIABLE,
        "PLAN_SEND_NOP": PLAN_SEND_NOP,
        "PLAN_WAIT_SIGNON": PLAN_WAIT_SIGNON,
        "PLAN_RELIABLE_PHASE": PLAN_RELIABLE_PHASE,
        "RELIABLE_NONE": RELIABLE_NONE,
        "RELIABLE_DROP_OVERFLOW": RELIABLE_DROP_OVERFLOW,
        "RELIABLE_WAIT": RELIABLE_WAIT,
        "RELIABLE_DROP_ASAP": RELIABLE_DROP_ASAP,
        "RELIABLE_SEND": RELIABLE_SEND,
    }


def make_golden() -> dict[str, Any]:
    return {
        "schema": GOLDEN_SCHEMA,
        "package": PACKAGE_ID,
        "parent_package": PARENT_PACKAGE_ID,
        "source_reference": "WinQuake 1.09 sv_main.c/common.c/protocol.h",
        "vectors": python_vectors(),
        "initial_delivery_cases": initial_cases(),
        "reliable_delivery_cases": reliable_cases(),
        "datagram_cases": datagram_cases(),
        "fast_update_cases": fast_update_cases(),
        "constants": constants(),
    }


def compiler_candidates() -> list[list[str]]:
    values: list[list[str]] = []
    for name in ("cc", "gcc", "clang"):
        path = shutil.which(name)
        if path:
            values.append([path])
    return values


def parse_oracle(stdout: str) -> dict[str, Any]:
    vectors: list[dict[str, Any]] = []
    initial: list[dict[str, Any]] = []
    reliable: list[dict[str, Any]] = []
    datagram: list[dict[str, Any]] = []
    fast_update: list[dict[str, Any]] = []
    for raw in stdout.splitlines():
        if not raw.strip():
            continue
        row = json.loads(raw)
        kind = row.pop("kind")
        if kind == "vector": vectors.append(row)
        elif kind == "initial": initial.append(row)
        elif kind == "reliable": reliable.append(row)
        elif kind == "datagram": datagram.append(row)
        elif kind == "fast_update": fast_update.append(row)
        else: raise ValueError(f"unknown C-oracle row kind: {kind!r}")
    return {
        "vectors": vectors,
        "initial_delivery_cases": initial,
        "reliable_delivery_cases": reliable,
        "datagram_cases": datagram,
        "fast_update_cases": fast_update,
    }


def run_c_oracle(root: Path, require: bool) -> tuple[dict[str, Any] | None, list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    source = root / "tools" / "oracle" / "protocol15_serverdata_oracle.c"
    candidates = compiler_candidates()
    if not candidates:
        message = "no C compiler found; source-derived C oracle was not executed"
        if require: errors.append(message)
        else: warnings.append(message)
        return None, errors, warnings
    with tempfile.TemporaryDirectory(prefix="mq-bp012-oracle-") as temp:
        exe = Path(temp) / ("oracle.exe" if os.name == "nt" else "oracle")
        command = candidates[0] + ["-std=c11", "-Wall", "-Wextra", "-Werror", "-O2", str(source), "-o", str(exe)]
        compiled = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if compiled.returncode != 0:
            errors.append("C oracle compilation failed: " + compiled.stdout.strip())
            return None, errors, warnings
        executed = subprocess.run([str(exe)], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if executed.returncode != 0:
            errors.append("C oracle execution failed: " + executed.stdout.strip())
            return None, errors, warnings
        try:
            return parse_oracle(executed.stdout), errors, warnings
        except Exception as exc:
            errors.append(f"cannot parse C oracle output: {exc}")
            return None, errors, warnings


def compare(name: str, actual: Any, expected: Any, errors: list[str]) -> None:
    if actual != expected:
        errors.append(f"{name} differs")


def function_body(text: str, name: str) -> str:
    marker = f"function {name}("
    start = text.find(marker)
    if start < 0:
        return ""
    end = text.find("\nend function", start)
    if end < 0:
        return ""
    return text[start:end + len("\nend function")]


def parse_minilang_constants(path: Path) -> dict[str, int]:
    import re
    values: dict[str, int] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = re.match(r"\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(-?(?:0x[0-9A-Fa-f]+|[0-9]+))\s*$", line)
        if not match:
            continue
        raw = match.group(2)
        values[match.group(1)] = int(raw, 16) if raw.lower().startswith("0x") else int(raw)
    return values


def check_document(root: Path) -> Check:
    golden_path = root / "audit" / "protocol15_serverdata_golden.json"
    errors: list[str] = []
    details: dict[str, Any] = {}
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
        expected = make_golden()
        compare("golden schema", golden.get("schema"), GOLDEN_SCHEMA, errors)
        compare("package", golden.get("package"), PACKAGE_ID, errors)
        compare("parent package", golden.get("parent_package"), PARENT_PACKAGE_ID, errors)
        compare("Python vectors", golden.get("vectors"), expected["vectors"], errors)
        compare("initial delivery cases", golden.get("initial_delivery_cases"), expected["initial_delivery_cases"], errors)
        compare("reliable delivery cases", golden.get("reliable_delivery_cases"), expected["reliable_delivery_cases"], errors)
        compare("datagram cases", golden.get("datagram_cases"), expected["datagram_cases"], errors)
        compare("fast-update cases", golden.get("fast_update_cases"), expected["fast_update_cases"], errors)
        compare("constants", golden.get("constants"), expected["constants"], errors)
        details = {
            "vector_count": len(expected["vectors"]),
            "initial_delivery_case_count": len(expected["initial_delivery_cases"]),
            "reliable_delivery_case_count": len(expected["reliable_delivery_cases"]),
            "datagram_case_count": len(expected["datagram_cases"]),
            "fast_update_case_count": len(expected["fast_update_cases"]),
            "constant_count": len(expected["constants"]),
            "golden_sha256": hashlib.sha256(golden_path.read_bytes()).hexdigest(),
        }
    except Exception as exc:
        errors.append(f"cannot validate golden document: {exc}")
    return Check("golden_document", not errors, details, errors)


def check_c_oracle(root: Path, require: bool) -> Check:
    expected = make_golden()
    oracle, errors, warnings = run_c_oracle(root, require)
    details: dict[str, Any] = {"executed": oracle is not None}
    if oracle is not None:
        compare("C vectors", oracle.get("vectors"), expected["vectors"], errors)
        compare("C initial delivery cases", oracle.get("initial_delivery_cases"), expected["initial_delivery_cases"], errors)
        compare("C reliable delivery cases", oracle.get("reliable_delivery_cases"), expected["reliable_delivery_cases"], errors)
        compare("C datagram cases", oracle.get("datagram_cases"), expected["datagram_cases"], errors)
        compare("C fast-update cases", oracle.get("fast_update_cases"), expected["fast_update_cases"], errors)
        source = root / "tools" / "oracle" / "protocol15_serverdata_oracle.c"
        details["source_sha256"] = hashlib.sha256(source.read_bytes()).hexdigest()
    return Check("source_derived_c_oracle", not errors, details, errors, warnings)


def check_source_contract(root: Path) -> Check:
    errors: list[str] = []
    details: dict[str, Any] = {}
    try:
        paths = {
            "writer": root / "src/miniquake/protocol_serverdata.ml",
            "update": root / "src/miniquake/protocol_update.ml",
            "types": root / "src/miniquake/types.ml",
            "server": root / "src/miniquake/server.ml",
            "svmain": root / "src/miniquake/sv_main.ml",
            "host": root / "src/miniquake/host.ml",
            "physics": root / "src/miniquake/physics.ml",
            "builtins": root / "src/miniquake/quakec/builtins.ml",
            "tests": root / "tests/protocol15_serverdata_tests.ml",
            "build": root / "build.ps1",
            "acceptance": root / "TEST_BP-012R1.ps1",
            "collector": root / "COLLECT_RESULTS.ps1",
        }
        files = {key: path.read_text(encoding="utf-8-sig") for key, path in paths.items()}

        markers = {
            "writer": (
                "function writeServerInfo(", "function writeSound(", "function writeBaseline(",
                "function writeClientData(", "function appendDatagramIfFits(",
                "if destination.curSize + source.curSize >= destination.maxSize then return false end if",
                "function initialDeliveryPlan(", "function reliableDeliveryPlan(",
                "roundedAttenuation = transients.cFloat(attenuation)",
                "return transients.soundFieldMask(volume, attenuation)",
            ),
            "update": (
                "function encodedSize(bits)", "function canWrite(buffer, bits)",
                "if remaining < 16 then return false end if", "return encodedSize(bits) <= remaining",
                "function writeFastUpdateBits(",
            ),
            "types": (
                "struct ProtocolClientData\n  viewHeight\n  idealPitch\n  punch\n  velocity",
                "struct ServerClient", "  lastMessage\n  dropAsap\nend struct",
                "struct GameServer", "  standardQuake\n  randomSeed",
            ),
            "server": (
                "import miniquake.protocol_serverdata as serverData",
                "sz.allocOverflowing(c.MAX_MSGLEN)",
                "serverData.writeServerInfo(", "serverData.writeSound(",
                "channel = native.trunc(event[1])",
                "attenuation = transients.cFloat(event[4])",
                "serverData.writeClientData(", "serverData.appendDatagramIfFits(",
                "protocolUpdate.canWrite(buffer, bits)", "function sendClientMessagesAt(",
                'items2Offset = vm.fieldOffset(server.machine, "items2")',
                "native.trunc(server.serverFlags) << 28",
                "previous = server.edicts",
                "clientValue.message.overflowed", "clientValue.dropAsap",
                "function playerProtocolFlags(player)",
                "flags = playerProtocolFlags(player)",
                "playerProtocolFlags(player), player.waterLevel",
            ),
            "svmain": (
                "import miniquake.protocol_serverdata as serverData",
                "import miniquake.quakec.vm as vm",
                "serverData.writeServerInfo(", "serverData.writeSound(",
                "channelValue = native.trunc(channel)",
                "attenuationValue = transients.cFloat(attenuation)",
                "serverData.writeClientData(", "serverData.appendDatagramIfFits(",
                "serverData.initialDeliveryPlan(", "serverData.reliableDeliveryPlan(",
                'items2Offset = vm.fieldOffset(state.server.machine, "items2")',
                "native.trunc(state.server.serverFlags) << 28",
                "protocolUpdate.canWrite(buffer, bits)",
                "fallbackFlags = runtime.playerProtocolFlags(player)",
                'svmQcFloat(state, entityIndex, "flags", fallbackFlags)',
            ),
            "host": ("gameServer.standardQuake = arguments.standardQuake",),
            "physics": ("[[entityIndex, 0, sample, 255, 1.0]]",),
            "builtins": ("[[entityIndex, channel, sample, volumeByte, attenuation]]",),
            "build": (
                "check_protocol15_serverdata.py", "MiniQuakeProtocol15ServerDataTests.exe",
                "protocol15-serverdata-tests", "protocol15_serverdata=",
            ),
            "acceptance": (
                '$PackageId = "BP-012R1"', '$ParentPackageId = "BP-012"',
                "check_protocol15_serverdata.py", "bp012r1-protocol15-serverdata.json",
                "MiniQuakeProtocol15ServerDataTests.exe", "acceptance test: PASS",
            ),
            "collector": (
                "MiniQuakeProtocol15ServerDataTests.exe",
                "BP-012_PROTOCOL15_SERVERDATA_AUDIT.md", "protocol15_serverdata_golden.json",
            ),
        }
        for key, required in markers.items():
            for marker in required:
                if marker not in files[key]:
                    errors.append(f"{paths[key].relative_to(root).as_posix()} is missing source-contract marker: {marker}")

        # The historical BP-012 path copied the previous baseline directly.
        # Later native-GC hardening roots both the baseline and the returned
        # QuakeEdict in named locals before heap writes.  Both spellings retain
        # the same Protocol-15 baseline semantics; require one complete form.
        direct_baseline_copy = "result[index].baseline = previous[index].baseline"
        rooted_baseline_copy = (
            "previousBaseline = previous[index].baseline" in files["server"]
            and "synchronized.baseline = previousBaseline" in files["server"]
            and "result[index] = synchronized" in files["server"]
        )
        stable_baseline_mirror = (
            "function ensureSynchronizedBaseline(item, entityIndex)" in files["server"]
            and "item = ensureSynchronizedEdict(server, entityIndex)" in files["server"]
            and "ensureSynchronizedBaseline(item, entityIndex)" in files["server"]
            and "server.edicts[index] = synchronized" in files["server"]
            and "result = arrayutil.makeEmptyArray(server.numEdicts)" not in files["server"]
        )
        if (
            direct_baseline_copy not in files["server"]
            and not rooted_baseline_copy
            and not stable_baseline_mirror
        ):
            errors.append(
                "src/miniquake/server.ml is missing direct, rooted-copy or stable in-place baseline preservation"
            )

        client_body = function_body(files["writer"], "writeClientData")
        if not client_body:
            errors.append("protocol_serverdata.writeClientData is missing")
        else:
            if "while bit < 32" not in client_body or "return [bits, buffer.curSize - start]" not in client_body:
                errors.append("mission-pack active-weapon loop is incomplete")
            mission_else = client_body[client_body.find("else\n    active ="):]
            if "msg.writeByte(buffer, 0)" in mission_else:
                errors.append("mission-pack zero active weapon must emit no fallback byte")

        integrated_clientdata_body = function_body(files["server"], "writeClientDataForClient")
        if "serverData.writeClientData(buffer, protocolClientData(server, client, player))" not in integrated_clientdata_body:
            errors.append("integrated clientdata path does not use the shared Protocol-15 writer")

        ground_adapter_body = function_body(files["server"], "playerProtocolFlags")
        for marker in (
            "native.trunc(player.flags) & ~c.FL_ONGROUND",
            "if player.onGround then return baseFlags | c.FL_ONGROUND end if",
            "return baseFlags",
        ):
            if marker not in ground_adapter_body:
                errors.append(f"PlayerState ground adapter is missing: {marker}")
        protocol_clientdata_body = function_body(files["server"], "protocolClientData")
        if "flags = playerProtocolFlags(player)" not in protocol_clientdata_body:
            errors.append("integrated no-QC clientdata fallback does not mirror PlayerState.onGround")
        if 'qcFloat(server.machine, entityIndex, "flags", playerProtocolFlags(player))' not in protocol_clientdata_body:
            errors.append("QuakeC clientdata fallback does not retain the PlayerState ground adapter")

        svmain_clientdata_body = function_body(files["svmain"], "SV_WriteClientdataToMessage")
        if "serverData.writeClientData(buffer, data)" not in svmain_clientdata_body:
            errors.append("sv_main clientdata path does not use the shared Protocol-15 writer")

        baseline_body = function_body(files["server"], "protocolBaseline")
        if 'modelIndexValue = modelIndex(server, item.model)' not in baseline_body:
            errors.append("integrated baseline does not resolve non-client models through SV_ModelIndex semantics")
        if "native.trunc(item.frame), colormapValue, native.trunc(item.skin), 0," not in baseline_body:
            errors.append("integrated baseline does not preserve zero-initialized baseline.effects")

        fixture_numbers = __import__("re").findall(r'runTest\("(\d\d)"', files["tests"])
        if fixture_numbers != [f"{index:02d}" for index in range(1, 18)]:
            errors.append(f"BP-012R1 fixture numbering differs: {fixture_numbers!r}")
        if 'print "  [" + number + "/17] " + name' not in files["tests"]:
            errors.append("BP-012R1 MiniLang progress denominator is not 17")
        if "MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17" not in files["tests"]:
            errors.append("BP-012R1 MiniLang success marker is missing")
        expected = make_golden()
        missing_hex = [item["name"] for item in expected["vectors"] if item["bytes"] not in files["tests"]]
        if missing_hex:
            errors.append("MiniLang tests omit golden vector bytes: " + ", ".join(missing_hex))

        constants = parse_minilang_constants(root / "src/miniquake/constants.ml")
        writer_constants = parse_minilang_constants(paths["writer"])
        merged = {**constants, **writer_constants}
        expected_constants = expected["constants"]
        mismatched = [
            f"{name}: expected {value}, found {merged.get(name)}"
            for name, value in expected_constants.items() if merged.get(name) != value
        ]
        errors.extend(mismatched)

        details = {
            "minilang_fixtures": len(fixture_numbers),
            "golden_vectors_referenced": len(expected["vectors"]) - len(missing_hex),
            "constants_checked": len(expected_constants),
            "production_modules": 8,
            "player_ground_adapter": True,
        }
    except Exception as exc:
        errors.append(f"cannot validate MiniLang server-data source contract: {exc}")
    return Check("minilang_serverdata_contract", not errors, details, errors)


def verify(root: Path, require_c_oracle: bool) -> dict[str, Any]:
    checks = [check_document(root), check_c_oracle(root, require_c_oracle), check_source_contract(root)]
    return {
        "schema": REPORT_SCHEMA,
        "package_id": PACKAGE_ID,
        "parent_package_id": PARENT_PACKAGE_ID,
        "root": str(root),
        "passed": all(check.passed for check in checks),
        "checks": [
            {
                "name": check.name,
                "passed": check.passed,
                "details": check.details,
                "errors": check.errors,
                "warnings": check.warnings,
            }
            for check in checks
        ],
    }


def self_test() -> int:
    golden = make_golden()
    assert len(golden["vectors"]) == 11
    by_name = {item["name"]: item for item in golden["vectors"]}
    assert by_name["serverinfo_coop"]["length"] == 118
    assert by_name["clientdata_missionpack_zero"]["length"] == 15
    assert by_name["baseline_player"]["bytes"] == "16010002030105500000a00020f00040"
    assert golden["datagram_cases"][2]["append"] is False
    assert golden["fast_update_cases"][4]["encoded_size"] == 18
    assert golden["initial_delivery_cases"][0]["plan"] == 9
    assert golden["reliable_delivery_cases"][-1]["plan"] == RELIABLE_SEND
    print("MiniQuake BP-012R1 Protocol 15 server-data checker self-test: PASS")
    return 0


def print_report(report: dict[str, Any]) -> None:
    print(f"MiniQuake {PACKAGE_ID} Protocol 15 server-data verification")
    for check in report["checks"]:
        print(f"  [{'PASS' if check['passed'] else 'FAIL'}] {check['name']}")
        for warning in check["warnings"]:
            print("         warning: " + warning)
        for error in check["errors"]:
            print("         error: " + error)
        if check["details"]:
            print("         " + ", ".join(f"{key}={value}" for key, value in check["details"].items()))
    print(f"MiniQuake {PACKAGE_ID} Protocol 15 server-data verification: {'PASS' if report['passed'] else 'FAIL'}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root_arg", nargs="?", type=Path)
    parser.add_argument("--root", dest="root_option", type=Path)
    parser.add_argument("--json-output", "--json-out", dest="json_output", type=Path)
    parser.add_argument("--require-c-oracle", action="store_true")
    parser.add_argument("--write-golden", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    selected = args.root_option or args.root_arg or Path(__file__).resolve().parents[1]
    root = selected.resolve()
    if not root.is_dir():
        print(f"error: source root does not exist: {root}", file=sys.stderr)
        return 2
    golden_path = root / "audit" / "protocol15_serverdata_golden.json"
    if args.write_golden:
        golden_path.parent.mkdir(parents=True, exist_ok=True)
        golden_path.write_text(json.dumps(make_golden(), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
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
