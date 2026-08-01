#!/usr/bin/env python3
import argparse
import json
import pathlib
import re
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []

    common = (root / "src/miniquake/common.ml").read_text(encoding="utf-8-sig")
    byteio = (root / "src/miniquake/byteio.ml").read_text(encoding="utf-8-sig")
    crc = (root / "src/miniquake/crc.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/common_asset_parity_tests.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/common_crc_golden.json").read_text(encoding="utf-8"))

    markers = [
        "function quakeFloat(value)",
        "function quakeInt32(value)",
        "data = quakeText.encodeBytes(text)",
        'if count < 2 then return "?model?" end if',
        "while index > 0 and data[index] != 47",
        "return quakeText.decodeBytes(slice(data, offset, length))",
        "function CRC_Block(data, offset, count)",
        "function LongNoSwap(value)",
        "return quakeInt32(value)",
        "function FloatNoSwap(value)",
        "return quakeFloat(value)",
        "function cAtof(text)",
        "return native.bitsFloat(native.f32FromText(text))",
    ]
    merged = common + "\n" + byteio + "\n" + crc
    for marker in markers:
        if marker not in merged:
            errors.append("missing source marker: " + marker)

    # The C-style endian entrypoints live in miniquake.common.  BP-070R1
    # accidentally called nonexistent uppercase members on miniquake.byteio,
    # which the older source-only checker did not notice.
    expected_calls = [
        "common.ShortSwap(",
        "common.LongSwap(",
        "common.ShortNoSwap(",
        "common.LongNoSwap(",
        "common.FloatNoSwap(",
    ]
    for call in expected_calls:
        if call not in test:
            errors.append("missing common endian fixture call: " + call)

    forbidden_calls = re.findall(
        r"\bbio\.(?:ShortSwap|LongSwap|ShortNoSwap|LongNoSwap|FloatSwap|FloatNoSwap)\s*\(",
        test,
    )
    if forbidden_calls:
        errors.append("fixture calls nonexistent uppercase miniquake.byteio members")

    if "common.cAtof(\"-0.000000\")" not in test or "C atof signed zero" not in test:
        errors.append("C atof signed-zero fixture is missing")
    if "MiniQuake BP-070 common core tests passed: 24" not in test:
        errors.append("fixture count marker missing")
    if golden.get("fixtures") != 24 or golden.get("crc_123456789") != "0x29b1":
        errors.append("golden mismatch")
    if golden.get("text_abi") != "quake_latin1_cstring_v1":
        errors.append("text ABI mismatch")

    report = {
        "schema_version": 2,
        "package": "BP-070",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "fixtures": 24,
        "crc_vectors": 2,
        "binary32_boundaries": 5,
        "c_atof_signed_zero": True,
        "quake_byte_strings": True,
        "common_endian_entrypoints": True,
        "resolved_package_member_calls": len(expected_calls),
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake BP-070 common/CRC verification: " + report["status"])
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
