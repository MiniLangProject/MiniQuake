#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check audio 059 compatibility and regression contract."""

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
    contract = (root / 'src/miniquake/audio_contract.ml').read_text(encoding="utf-8")
    cd = (root / 'src/miniquake/sound/cd_audio.ml').read_text(encoding="utf-8")
    build = (root / 'src/miniquake/build_info.ml').read_text(encoding="utf-8")
    main_src = (root / 'src/main.ml').read_text(encoding="utf-8")
    evidence = (root / 'tests/audio_retail_evidence.ml').read_text(encoding="utf-8")
    test = (root / 'tests/audio_closure_tests.ml').read_text(encoding="utf-8")
    golden = json.loads((root / 'audit/audio_closure_golden.json').read_text(encoding="utf-8"))
    if 'const STATUS = "audio_109_frozen_v1"' not in contract: errors.append('audio contract status differs')
    if 'const FINGERPRINT = 0xdcf7a002' not in contract: errors.append('audio contract fingerprint differs')
    if 'const RETAIL_EVIDENCE_SOUNDS = 2' not in contract: errors.append('audio retail evidence count differs')
    if 'import miniquake.common as common' not in cd: errors.append('CD command parser does not import Quake atoi')
    if 'track = common.atoi(trackText)' not in cd: errors.append('CD play does not use Quake atoi')
    if 'value = common.atoi(arguments[index + 1])' not in cd: errors.append('CD remap does not use Quake atoi')
    if 'common.fixedFloat(volume)' not in cd: errors.append('CD info does not preserve original six-decimal %f formatting')
    if 'native.floatText(state.volume)' in cd: errors.append('CD info still uses compact %.9g formatting')
    if 'const AUDIO_STATUS = "audio_109_frozen_v1"' not in build: errors.append('build info missing audio status')
    if 'const AUDIO_FINGERPRINT = 0xdcf7a002' not in build: errors.append('build info missing audio fingerprint')
    if 'buildInfo.AUDIO_STATUS' not in main_src: errors.append('version output missing audio status')
    if 'MiniQuake BP-059 retail audio evidence: PASS' not in evidence: errors.append('retail evidence pass marker differs')
    if 'cache.stereo + 1' not in evidence: errors.append('retail evidence does not derive channel count from sfxcache stereo semantics')
    if 'cache.channels' in evidence: errors.append('retail evidence references a nonexistent SoundCache.channels member')
    if 'MiniQuake BP-059 audio closure tests passed: 24' not in test: errors.append('BP-059 pass marker differs')
    if 'bp059Equal(len(bp059Contract.constants()), 17' not in test: errors.append('BP-059 contract vector assertion differs')
    if test.count("bp059Run(") != 25: errors.append('BP-059 test does not contain 24 fixture calls')
    if golden.get("fixtures") != 24: errors.append('BP-059 golden fixture count differs')
    if golden.get("info_volume") != "1.000000": errors.append('BP-059 golden CD info volume formatting differs')
    details = {"root": str(root), "fixtures": 24, "golden": str(root / 'audit/audio_closure_golden.json'), "error_count": len(errors)}
    if errors:
        emit(a.json_output, 'bp059_audio_closure', False, details, errors)
        print('MiniQuake BP-059 audio closure verification: FAIL')
        for error in errors: print("  " + error)
        return 1
    emit(a.json_output, 'bp059_audio_closure', True, details, [])
    print('MiniQuake BP-059 audio closure verification: PASS')
    print('  status=audio_109_frozen_v1 fingerprint=0xdcf7a002 fixtures=24 retail_sounds=2')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
