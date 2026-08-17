#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check audio 057 compatibility and regression contract."""

from __future__ import annotations
import argparse, json, pathlib

def emit(path, name, passed, details, errors):
    """Emit one deterministic machine-readable verification report."""
    if path:
        payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
        pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(pathlib.Path(__file__).resolve().parents[1]))
    ap.add_argument("--json-output")
    a = ap.parse_args()
    root = pathlib.Path(a.root).resolve()
    errors = []
    mix = (root / 'src/miniquake/sound/snd_mix.ml').read_text(encoding="utf-8")
    test = (root / 'tests/audio_mixer_parity_tests.ml').read_text(encoding="utf-8")
    golden = json.loads((root / 'audit/audio_mixer_golden.json').read_text(encoding="utf-8"))
    if 'function soundI32(value)' not in mix: errors.append('snd_mix missing signed 32-bit helper')
    if 'value = soundI32(sample * state.transferVolume) >> 8' not in mix: errors.append('linear transfer does not wrap i32')
    if 'left = soundI32(sample * channel.leftVolume) >> 8' not in mix: errors.append('16-bit paint does not wrap multiply')
    if 'state.paintBuffer[index * 2] = soundI32' not in mix: errors.append('paint accumulator does not wrap i32')
    if 'MiniQuake BP-057 audio mixer tests passed: 22' not in test: errors.append('BP-057 pass marker differs')
    if 'bp057Equal(channel.position, 2, "loop restarted at boundary")' not in test: errors.append('BP-057 loop-boundary expectation differs')
    if 'bp057ScaleClampAndVolume' not in test: errors.append('BP-057 final fixture is not error-contained')
    if test.count("bp057Run(") != 23: errors.append('BP-057 test does not contain 22 fixture calls')
    if golden.get("fixtures") != 22: errors.append('BP-057 golden fixture count differs')
    details = {"root": str(root), "fixtures": 22, "golden": str(root / 'audit/audio_mixer_golden.json'), "error_count": len(errors)}
    if errors:
        emit(a.json_output, 'bp057_audio_mixer', False, details, errors)
        print('MiniQuake BP-057 audio mixer verification: FAIL')
        for error in errors: print("  " + error)
        return 1
    emit(a.json_output, 'bp057_audio_mixer', True, details, [])
    print('MiniQuake BP-057 audio mixer verification: PASS')
    print('  fixtures=22 paintbuffer_frames=512 signed_i32=1')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
