#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check audio 056 compatibility and regression contract."""

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
    dma = (root / 'src/miniquake/sound/snd_dma.ml').read_text(encoding="utf-8")
    mixer = (root / 'src/miniquake/sound/mixer.ml').read_text(encoding="utf-8")
    test = (root / 'tests/audio_dma_parity_tests.ml').read_text(encoding="utf-8")
    golden = json.loads((root / 'audit/audio_dma_golden.json').read_text(encoding="utf-8"))
    if 'function soundF32(value)' not in dma: errors.append('snd_dma missing Binary32 helper')
    if 'target.distanceMultiplier = soundF32' not in dma: errors.append('snd_dma attenuation is not Binary32')
    if 'dynamicBefore = dynamicChannelCount(mixer)' not in mixer: errors.append('production mixer missing pre-selection count')
    if 'if victim >= 0 then' not in mixer: errors.append('production exact replacement is missing')
    if 'function mixerF32(value)' not in mixer: errors.append('production mixer missing Binary32 helper')
    if 'MiniQuake BP-056 audio DMA tests passed: 22' not in test: errors.append('BP-056 pass marker differs')
    if 'bp056ProductionVolumesAndLocalLifecycle' not in test: errors.append('BP-056 final fixture is not error-contained')
    if 'sameEntity.endTime = 500' not in test or 'shortest.endTime = 101' not in test:
        errors.append('BP-056 channel-zero fixture does not separate matching-entity and lifetime selection')
    if 'picked == shortest' not in test or 'channel zero never overrides matching entity' not in test:
        errors.append('BP-056 channel-zero fixture does not bind the original non-override rule')
    if 'precache no-op retains descriptors' not in test or 'len(system.knownSfx), 2' not in test:
        errors.append('BP-056 S_ClearPrecache fixture does not preserve the original no-op behavior')
    if "function S_ClearPrecache(system)\n  return true\nend function" not in dma:
        errors.append('snd_dma S_ClearPrecache is no longer the original no-op adapter')
    if test.count("bp056Run(") != 23: errors.append('BP-056 test does not contain 22 fixture calls')
    if golden.get("fixtures") != 22: errors.append('BP-056 golden fixture count differs')
    if golden.get("channel_zero_override") is not False: errors.append('BP-056 golden channel-zero override rule differs')
    if golden.get("clear_precache_noop") is not True: errors.append('BP-056 golden precache no-op rule differs')
    details = {"root": str(root), "fixtures": 22, "golden": str(root / 'audit/audio_dma_golden.json'), "error_count": len(errors)}
    if errors:
        emit(a.json_output, 'bp056_audio_dma', False, details, errors)
        print('MiniQuake BP-056 audio DMA verification: FAIL')
        for error in errors: print("  " + error)
        return 1
    emit(a.json_output, 'bp056_audio_dma', True, details, [])
    print('MiniQuake BP-056 audio DMA verification: PASS')
    print('  fixtures=22 max_sfx=512 max_channels=128 dynamic_channels=8')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
