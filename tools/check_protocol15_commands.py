#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Validate BP-011 Protocol-15 signon, command-stream and entity-update parity.

The checked-in golden vectors are independently reproduced by a pure Python
model and, when a C compiler is available, by the standalone source-guided C
oracle in tools/oracle/protocol15_commands_oracle.c.
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
import sys
import tempfile
from dataclasses import asdict, dataclass, field
from pathlib import Path

PACKAGE_ID = "BP-011"
GOLDEN = "audit/protocol15_commands_golden.json"
ORACLE = "tools/oracle/protocol15_commands_oracle.c"
EXPECTED_EVENTS = [
    "svc_nop", "svc_disconnect", "svc_updatestat", "svc_version", "svc_setview",
    "svc_sound", "svc_time", "svc_print", "svc_stufftext", "svc_setangle",
    "svc_serverinfo", "svc_lightstyle", "svc_updatename", "svc_updatefrags",
    "svc_clientdata", "svc_stopsound", "svc_updatecolors", "svc_particle",
    "svc_damage", "svc_spawnstatic", "svc_spawnbaseline", "svc_temp_entity",
    "svc_setpause", "svc_signonnum", "svc_centerprint", "svc_killedmonster",
    "svc_foundsecret", "svc_spawnstaticsound", "svc_intermission", "svc_finale",
    "svc_cdtrack", "svc_sellscreen", "svc_cutscene", "fast_update",
]

SVC = {
    "nop": 1, "disconnect": 2, "updatestat": 3, "version": 4, "setview": 5,
    "sound": 6, "time": 7, "print": 8, "stufftext": 9, "setangle": 10,
    "serverinfo": 11, "lightstyle": 12, "updatename": 13, "updatefrags": 14,
    "clientdata": 15, "stopsound": 16, "updatecolors": 17, "particle": 18,
    "damage": 19, "spawnstatic": 20, "spawnbaseline": 22, "temp_entity": 23,
    "setpause": 24, "signonnum": 25, "centerprint": 26, "killedmonster": 27,
    "foundsecret": 28, "spawnstaticsound": 29, "intermission": 30, "finale": 31,
    "cdtrack": 32, "sellscreen": 33, "cutscene": 34,
}
CLC = {"nop": 1, "disconnect": 2, "move": 3, "stringcmd": 4}
U_MOREBITS, U_ORIGIN1, U_ORIGIN2, U_ORIGIN3 = 1, 2, 4, 8
U_ANGLE2, U_NOLERP, U_FRAME, U_SIGNAL = 16, 32, 64, 128
U_ANGLE1, U_ANGLE3, U_MODEL, U_COLORMAP = 256, 512, 1024, 2048
U_SKIN, U_EFFECTS, U_LONGENTITY = 4096, 8192, 16384
SU_WEAPON = 16384
MOVETYPE_STEP = 4


@dataclass
class Check:
    """Represent one check discovered by the source verifier."""
    name: str
    passed: bool
    details: dict[str, object] = field(default_factory=dict)
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


@dataclass
class Report:
    """Collect the machine-readable outcome of one verification run."""
    package_id: str
    root: str
    passed: bool
    checks: list[Check]


class Writer:
    """Encode one bounded Protocol 15 message for differential checks."""
    def __init__(self) -> None:
        """Initialize the helper with its immutable verification inputs."""
        self.data = bytearray()

    def byte(self, value: int | float | bool) -> None:
        """Compute the reference byte value for a deterministic fixture."""
        self.data.append(int(value) & 0xFF)

    char = byte

    def short(self, value: int | float) -> None:
        """Compute the reference short value for a deterministic fixture."""
        self.data += struct.pack("<H", int(value) & 0xFFFF)

    def long(self, value: int) -> None:
        """Compute the reference long value for a deterministic fixture."""
        self.data += struct.pack("<I", int(value) & 0xFFFFFFFF)

    def float(self, value: int | float) -> None:
        """Decode the fixture's IEEE-754 binary32 scalar value."""
        self.data += struct.pack("<f", float(value))

    def string(self, value: str) -> None:
        """Compute the reference string value for a deterministic fixture."""
        self.data += value.encode("latin-1") + b"\0"

    def coord(self, value: int | float) -> None:
        """Compute the reference coord value for a deterministic fixture."""
        rounded = struct.unpack("<f", struct.pack("<f", float(value)))[0]
        self.short(int(rounded * 8.0))

    def angle(self, value: int | float) -> None:
        """Compute the reference angle value for a deterministic fixture."""
        rounded = struct.unpack("<f", struct.pack("<f", float(value)))[0]
        encoded = int((int(rounded) * 256) / 360) & 255
        self.byte(encoded)

    def string_command(self, text: str) -> None:
        """Compute the reference string command value for a deterministic fixture."""
        self.byte(CLC["stringcmd"])
        self.string(text)

    def vector(self, name: str) -> dict[str, object]:
        """Package one encoded protocol message as a deterministic vector row."""
        return {"name": name, "bytes": self.data.hex(), "length": len(self.data)}


def baseline_state() -> dict[str, object]:
    """Build the deterministic baseline state fixture used by this verifier."""
    return {
        "model": 1, "frame": 2, "colormap": 3, "skin": 4, "effects": 5,
        "origin": (10.0, 20.0, 30.0), "angles": (0.0, 45.0, 90.0),
    }


def update_bits(entity: int, baseline: dict[str, object], current: dict[str, object], movetype: int) -> int:
    """Encode bits using the Protocol 15 layout."""
    bits = 0
    origins = current["origin"]
    base_origins = baseline["origin"]
    assert isinstance(origins, tuple) and isinstance(base_origins, tuple)
    for axis in range(3):
        miss = origins[axis] - base_origins[axis]
        if miss < -0.1 or miss > 0.1:
            bits |= U_ORIGIN1 << axis
    angles = current["angles"]
    base_angles = baseline["angles"]
    assert isinstance(angles, tuple) and isinstance(base_angles, tuple)
    if angles[0] != base_angles[0]: bits |= U_ANGLE1
    if angles[1] != base_angles[1]: bits |= U_ANGLE2
    if angles[2] != base_angles[2]: bits |= U_ANGLE3
    if movetype == MOVETYPE_STEP: bits |= U_NOLERP
    if baseline["colormap"] != current["colormap"]: bits |= U_COLORMAP
    if baseline["skin"] != current["skin"]: bits |= U_SKIN
    if baseline["frame"] != current["frame"]: bits |= U_FRAME
    if baseline["effects"] != current["effects"]: bits |= U_EFFECTS
    if baseline["model"] != current["model"]: bits |= U_MODEL
    if entity >= 256: bits |= U_LONGENTITY
    if bits >= 256: bits |= U_MOREBITS
    return bits


def write_fast_update(w: Writer, entity: int, baseline: dict[str, object], current: dict[str, object], movetype: int) -> int:
    """Encode and write fast update to the fixture buffer."""
    bits = update_bits(entity, baseline, current, movetype)
    w.byte(bits | U_SIGNAL)
    if bits & U_MOREBITS: w.byte(bits >> 8)
    if bits & U_LONGENTITY: w.short(entity)
    else: w.byte(entity)
    if bits & U_MODEL: w.byte(int(current["model"]))
    if bits & U_FRAME: w.byte(int(current["frame"]))
    if bits & U_COLORMAP: w.byte(int(current["colormap"]))
    if bits & U_SKIN: w.byte(int(current["skin"]))
    if bits & U_EFFECTS: w.byte(int(current["effects"]))
    origin = current["origin"]; angles = current["angles"]
    assert isinstance(origin, tuple) and isinstance(angles, tuple)
    if bits & U_ORIGIN1: w.coord(origin[0])
    if bits & U_ANGLE1: w.angle(angles[0])
    if bits & U_ORIGIN2: w.coord(origin[1])
    if bits & U_ANGLE2: w.angle(angles[1])
    if bits & U_ORIGIN3: w.coord(origin[2])
    if bits & U_ANGLE3: w.angle(angles[2])
    return bits


def write_baseline(w: Writer) -> None:
    """Encode and write baseline to the fixture buffer."""
    w.byte(1); w.byte(2); w.byte(0); w.byte(0)
    w.coord(1.0); w.angle(0.0)
    w.coord(2.0); w.angle(90.0)
    w.coord(3.0); w.angle(180.0)


def write_svc_catalog(w: Writer) -> None:
    """Encode and write svc catalog to the fixture buffer."""
    w.byte(SVC["nop"])
    w.byte(SVC["disconnect"])
    w.byte(SVC["updatestat"]); w.byte(2); w.long(123456)
    w.byte(SVC["version"]); w.long(15)
    w.byte(SVC["setview"]); w.short(1)
    w.byte(SVC["sound"]); w.byte(0); w.short(17); w.byte(1); w.coord(1); w.coord(2); w.coord(3)
    w.byte(SVC["time"]); w.float(12.5)
    w.byte(SVC["print"]); w.string("print\n")
    w.byte(SVC["stufftext"]); w.string("echo fixture\n")
    w.byte(SVC["setangle"]); w.angle(10); w.angle(90); w.angle(-45)
    w.byte(SVC["serverinfo"]); w.long(15); w.byte(1); w.byte(0); w.string("start")
    w.string("maps/start.bsp"); w.string("progs/player.mdl"); w.string("")
    w.string("misc/menu1.wav"); w.string("")
    w.byte(SVC["lightstyle"]); w.byte(0); w.string("m")
    w.byte(SVC["updatename"]); w.byte(0); w.string("Ranger")
    w.byte(SVC["updatefrags"]); w.byte(0); w.short(7)
    w.byte(SVC["clientdata"]); w.short(SU_WEAPON); w.long(0x12345678); w.byte(2)
    w.short(100); w.byte(10); w.byte(11); w.byte(12); w.byte(13); w.byte(14); w.byte(1)
    w.byte(SVC["stopsound"]); w.short(17)
    w.byte(SVC["updatecolors"]); w.byte(0); w.byte(0x4D)
    w.byte(SVC["particle"]); w.coord(1); w.coord(2); w.coord(3); w.char(1); w.char(-2); w.char(3); w.byte(4); w.byte(5)
    w.byte(SVC["damage"]); w.byte(1); w.byte(2); w.coord(4); w.coord(5); w.coord(6)
    w.byte(SVC["spawnstatic"]); write_baseline(w)
    w.byte(SVC["spawnbaseline"]); w.short(2); write_baseline(w)
    w.byte(SVC["temp_entity"]); w.byte(0); w.coord(7); w.coord(8); w.coord(9)
    w.byte(SVC["setpause"]); w.byte(1)
    w.byte(SVC["signonnum"]); w.byte(1)
    w.byte(SVC["centerprint"]); w.string("center")
    w.byte(SVC["killedmonster"])
    w.byte(SVC["foundsecret"])
    w.byte(SVC["spawnstaticsound"]); w.coord(1); w.coord(2); w.coord(3); w.byte(1); w.byte(255); w.byte(64)
    w.byte(SVC["intermission"])
    w.byte(SVC["finale"]); w.string("finale")
    w.byte(SVC["cdtrack"]); w.byte(3); w.byte(3)
    w.byte(SVC["sellscreen"])
    w.byte(SVC["cutscene"]); w.string("cutscene")
    base = baseline_state(); write_fast_update(w, 1, base, base, 0)


def python_vectors() -> list[dict[str, object]]:
    """Build the deterministic python vectors fixture used by this verifier."""
    out: list[dict[str, object]] = []
    for stage in range(1, 5):
        w = Writer()
        if stage == 1: w.string_command("prespawn")
        elif stage == 2:
            w.string_command('name "Ranger"\n')
            w.string_command("color 4 13\n")
            w.string_command("spawn 1 2 3")
        elif stage == 3: w.string_command("begin")
        out.append(w.vector(f"signon_reply_{stage}"))

    w = Writer()
    for stage in (1, 2, 3): w.byte(SVC["signonnum"]); w.byte(stage)
    out.append(w.vector("server_signon_markers_1_2_3"))

    w = Writer(); w.byte(CLC["nop"]); w.byte(CLC["move"]); w.float(12.5)
    w.angle(12.75); w.angle(180.0); w.angle(-90.9)
    w.short(int(200.75)); w.short(int(-123.9)); w.short(int(32768.9)); w.byte(3); w.byte(7)
    w.string_command('name "Ranger"\n'); out.append(w.vector("clc_compound_stream"))
    w = Writer(); w.byte(CLC["disconnect"]); out.append(w.vector("clc_disconnect"))
    w = Writer(); w.byte(255); out.append(w.vector("clc_signed_eom"))

    base = baseline_state()
    w = Writer(); write_fast_update(w, 1, base, dict(base), 0); out.append(w.vector("fast_update_unchanged_short"))
    current = dict(base); current["effects"] = 6
    w = Writer(); write_fast_update(w, 1, base, current, 0); out.append(w.vector("fast_update_effects_changed"))
    w = Writer(); write_fast_update(w, 1, base, dict(base), MOVETYPE_STEP); out.append(w.vector("fast_update_step_only"))
    current = dict(base)
    current.update({
        "model": 9, "frame": 8, "colormap": 6, "skin": 7, "effects": 10,
        "origin": (11.25, 18.75, 31.5), "angles": (12.0, 90.0, -45.0),
    })
    w = Writer(); write_fast_update(w, 7, base, current, MOVETYPE_STEP); out.append(w.vector("fast_update_full_short"))
    w = Writer(); write_fast_update(w, 300, base, current, MOVETYPE_STEP); out.append(w.vector("fast_update_full_long"))
    w = Writer(); write_svc_catalog(w); out.append(w.vector("svc_catalog_stream"))
    return out


def parse_oracle(text: str) -> list[dict[str, object]]:
    """Parse oracle into its normalized representation."""
    return [json.loads(line) for line in text.splitlines() if line.strip()]


def sha256(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compilers() -> list[list[str]]:
    """Return all supported C compiler commands available to the verifier."""
    result: list[list[str]] = []
    if os.environ.get("CC", "").strip(): result.append(os.environ["CC"].split())
    for name in ("cc", "gcc", "clang", "cl"):
        found = shutil.which(name)
        if found: result.append([found])
    unique: list[list[str]] = []
    seen: set[tuple[str, ...]] = set()
    for item in result:
        key = tuple(item)
        if key not in seen: seen.add(key); unique.append(item)
    return unique


def check_document(root: Path) -> Check:
    """Validate document and return its contract findings."""
    errors: list[str] = []
    path = root / GOLDEN
    if not path.is_file(): return Check("golden_document", False, errors=[f"missing {GOLDEN}"])
    doc = json.loads(path.read_text(encoding="utf-8"))
    expected = python_vectors()
    if doc.get("schema") != "MiniQuakeProtocol15CommandsGolden/1": errors.append("unexpected schema")
    if doc.get("package") != PACKAGE_ID: errors.append(f"golden package is {doc.get('package')!r}")
    if doc.get("vectors") != expected: errors.append("golden vectors differ from independent Python model")
    if doc.get("svc_event_order") != EXPECTED_EVENTS: errors.append("SVC event order differs")
    oracle = root / ORACLE
    if doc.get("reference", {}).get("oracle_sha256") != sha256(oracle): errors.append("oracle SHA-256 differs")
    return Check("golden_document", not errors, {"vectors": len(expected), "svc_events": len(EXPECTED_EVENTS)}, errors)


def check_c_oracle(root: Path, required: bool) -> Check:
    """Validate c oracle and return its contract findings."""
    source = root / ORACLE
    errors: list[str] = []; warnings: list[str] = []
    expected = python_vectors()
    candidates = compilers()
    if not candidates:
        message = "no C compiler found; independent Python model still validated the vectors"
        (errors if required else warnings).append(message)
        return Check("c_oracle", not errors, {"compiled": False, "required": required}, errors, warnings)
    last = ""
    for command in candidates:
        with tempfile.TemporaryDirectory(prefix="mq-bp011-oracle-") as td:
            exe = Path(td) / ("oracle.exe" if os.name == "nt" else "oracle")
            if Path(command[0]).name.lower() in {"cl", "cl.exe"}:
                compile_cmd = command + ["/nologo", "/W4", "/WX", "/O2", str(source), f"/Fe:{exe}"]
            else:
                compile_cmd = command + ["-std=c11", "-Wall", "-Wextra", "-Werror", "-O2", str(source), "-o", str(exe)]
            built = subprocess.run(compile_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=False)
            last = built.stdout.strip()
            if built.returncode != 0 or not exe.is_file(): continue
            run = subprocess.run([str(exe)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, check=False)
            last = run.stdout.strip()
            if run.returncode != 0: continue
            try: observed = parse_oracle(run.stdout)
            except Exception as exc: last = str(exc); continue
            if observed != expected: errors.append("compiled C oracle differs from Python model")
            return Check("c_oracle", not errors, {"compiled": True, "compiler": command[0], "vectors": len(observed)}, errors, warnings)
    message = "all discovered C compilers failed: " + last
    (errors if required else warnings).append(message)
    return Check("c_oracle", not errors, {"compiled": False, "required": required}, errors, warnings)


def parse_constants(path: Path) -> dict[str, int]:
    """Parse constants into its normalized representation."""
    values: dict[str, int] = {}
    pattern = re.compile(r"^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(-?(?:0x[0-9A-Fa-f]+|[0-9]+))\s*$")
    for line in path.read_text(encoding="utf-8").splitlines():
        match = pattern.match(line)
        if match: values[match.group(1)] = int(match.group(2), 0)
    return values


def check_constants(root: Path) -> Check:
    """Validate constants and return its contract findings."""
    expected: dict[str, int] = {"PROTOCOL_VERSION": 15, "SIGNON_SERVERINFO": 1, "SIGNON_PRESPAWN": 2, "SIGNON_SPAWN": 3, "SIGNON_ACTIVE": 4}
    expected.update({"CLC_" + name.upper(): value for name, value in CLC.items()})
    expected.update({"SVC_" + name.upper(): value for name, value in SVC.items()})
    expected.update({
        "U_MOREBITS": U_MOREBITS, "U_ORIGIN1": U_ORIGIN1, "U_ORIGIN2": U_ORIGIN2,
        "U_ORIGIN3": U_ORIGIN3, "U_ANGLE2": U_ANGLE2, "U_NOLERP": U_NOLERP,
        "U_FRAME": U_FRAME, "U_SIGNAL": U_SIGNAL, "U_ANGLE1": U_ANGLE1,
        "U_ANGLE3": U_ANGLE3, "U_MODEL": U_MODEL, "U_COLORMAP": U_COLORMAP,
        "U_SKIN": U_SKIN, "U_EFFECTS": U_EFFECTS, "U_LONGENTITY": U_LONGENTITY,
    })
    values = parse_constants(root / "src/miniquake/constants.ml")
    errors = [f"{name}: expected {wanted}, found {values.get(name)}" for name, wanted in expected.items() if values.get(name) != wanted]
    return Check("protocol_constants", not errors, {"constants_checked": len(expected)}, errors)


def check_source_contract(root: Path) -> Check:
    """Validate source contract and return its contract findings."""
    errors: list[str] = []
    files = {
        "signon": (root / "src/miniquake/protocol_signon.ml").read_text(encoding="utf-8"),
        "update": (root / "src/miniquake/protocol_update.ml").read_text(encoding="utf-8"),
        "client": (root / "src/miniquake/client.ml").read_text(encoding="utf-8"),
        "server": (root / "src/miniquake/server.ml").read_text(encoding="utf-8"),
        "parser": (root / "src/miniquake/client_protocol.ml").read_text(encoding="utf-8"),
        "types": (root / "src/miniquake/types.ml").read_text(encoding="utf-8"),
        "tests": (root / "tests/protocol15_command_tests.ml").read_text(encoding="utf-8"),
    }
    markers = {
        "stage-one prespawn": ("signon", 'writeStringCommand(buffer, "prespawn")'),
        "stage-two name": ("signon", 'writeStringCommand(buffer, "name \\""'),
        "stage-three begin": ("signon", 'writeStringCommand(buffer, "begin")'),
        "baseline effects field": ("types", "struct EntityBaseline\n  modelIndex\n  frame\n  colormap\n  skin\n  effects"),
        "effects delta": ("update", "baseline.effects != effects"),
        "long entity": ("update", "entityNumber >= 256"),
        "MoreBits": ("update", "if bits >= 256 then bits = bits | c.U_MOREBITS"),
        "shared server writer": ("server", "return protocolUpdate.writeFastUpdateBits("),
        "signed CLC parser": ("server", "command = msg.readChar(reader)"),
        "CLC EOM": ("server", "if command == -1 then return true"),
        "no explicit stage four": ("server", "Host_Begin_f only marks the server-side client spawned"),
        "first update promotion": ("client", "if client.signon == c.SIGNON_SPAWN then"),
        "full SVC parser": ("parser", 'else if command == c.SVC_CUTSCENE then'),
        "test count": ("tests", "Protocol 15 command tests passed: 14"),
    }
    for label, (key, marker) in markers.items():
        # Declaration documentation is intentionally allowed between struct
        # members. Strip only explicit MiniDoc lines for layout-sensitive
        # markers; behavioral markers continue to inspect the original text.
        source_text = files[key]
        if label == "baseline effects field":
            source_text = re.sub(r"(?m)^[ \t]*///[^\n]*(?:\n|$)", "", source_text)
        if marker not in source_text: errors.append(f"missing {label}: {marker}")
    # No producer may write an explicit signon stage four packet.
    bad_pattern = re.compile(r"writeByte\([^\n]+SVC_SIGNONNUM[\s\S]{0,180}?writeByte\([^\n]+SIGNON_ACTIVE")
    for key in ("server", "client", "update", "signon"):
        if bad_pattern.search(files[key]): errors.append(f"{key} writes explicit svc_signonnum 4")
    test_hex = files["tests"]
    missing = [item["name"] for item in python_vectors() if item["bytes"] not in test_hex]
    if missing: errors.append("MiniLang tests omit vector bytes: " + ", ".join(missing))
    missing_events = [name for name in EXPECTED_EVENTS if name not in test_hex]
    if missing_events: errors.append("MiniLang tests omit event names: " + ", ".join(missing_events))
    return Check("minilang_command_contract", not errors, {"vectors_referenced": len(python_vectors()) - len(missing), "svc_events_referenced": len(EXPECTED_EVENTS) - len(missing_events)}, errors)


def run(root: Path, require_c: bool) -> Report:
    """Run run and capture its deterministic result."""
    checks = [check_document(root), check_c_oracle(root, require_c), check_constants(root), check_source_contract(root)]
    return Report(PACKAGE_ID, str(root), all(item.passed for item in checks), checks)


def print_report(report: Report) -> None:
    """Emit report in the requested report format."""
    print(f"MiniQuake {report.package_id} Protocol 15 command verification")
    for check in report.checks:
        print(f"  [{'PASS' if check.passed else 'FAIL'}] {check.name}")
        for warning in check.warnings: print(f"         warning: {warning}")
        for error in check.errors: print(f"         error: {error}")
        if check.details: print("         " + ", ".join(f"{key}={value}" for key, value in check.details.items()))
    print(f"MiniQuake {report.package_id} Protocol 15 command verification: {'PASS' if report.passed else 'FAIL'}")


def self_test() -> int:
    """Exercise the tool with synthetic fixtures and verify its invariants."""
    vectors = python_vectors()
    assert len(vectors) == 14
    by_name = {item["name"]: item for item in vectors}
    assert by_name["signon_reply_1"]["bytes"] == "04707265737061776e00"
    assert by_name["signon_reply_4"]["bytes"] == ""
    assert by_name["fast_update_effects_changed"]["bytes"] == "81200106"
    assert by_name["fast_update_full_long"]["bytes"] == "ff7f2c01090806070a5a0008960040fc00e0"
    assert by_name["svc_catalog_stream"]["length"] == 268
    print("MiniQuake BP-011 Protocol 15 command checker self-test: PASS")
    return 0


def main(argv: list[str] | None = None) -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--json-output")
    parser.add_argument("--require-c-oracle", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args(argv)
    if args.self_test: return self_test()
    root = Path(args.root).resolve()
    if not root.is_dir(): print(f"error: source root does not exist: {root}", file=sys.stderr); return 2
    report = run(root, args.require_c_oracle)
    if not args.quiet: print_report(report)
    if args.json_output:
        output = Path(args.json_output)
        if not output.is_absolute(): output = root / output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(asdict(report), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0 if report.passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
