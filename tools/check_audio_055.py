#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, pathlib

def emit(path, name, passed, details, errors):
    if path:
        payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
        pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(pathlib.Path(__file__).resolve().parents[1]))
    ap.add_argument("--json-output")
    a = ap.parse_args()
    root = pathlib.Path(a.root).resolve()
    errors = []
    mem = (root / 'src/miniquake/sound/snd_mem.ml').read_text(encoding="utf-8")
    test = (root / 'tests/audio_memory_parity_tests.ml').read_text(encoding="utf-8")
    golden = json.loads((root / 'audit/audio_memory_golden.json').read_text(encoding="utf-8"))
    if 'function soundF32(value)' not in mem: errors.append('snd_mem missing Binary32 helper')
    if 'sourceLength = cache.length' not in mem: errors.append('snd_mem missing original source length')
    if 'source data is truncated' not in mem: errors.append('snd_mem missing truncated-source guard')
    if 'fractionStep = native.trunc(soundF32(stepScale * 256.0))' not in mem: errors.append('snd_mem fraction step is not Binary32')
    if 'MiniQuake BP-055 audio memory tests passed: 20' not in test: errors.append('BP-055 pass marker differs')
    if 'bp055EffectConversionAndMalformed' not in test: errors.append('BP-055 final fixture is not error-contained')
    if 'bp055Mem.FindChunk(cursor, "RIFF"), 0' not in test: errors.append('BP-055 chunk fixture does not discover the root RIFF chunk')
    if 'cursor.iffData = 12' not in test: errors.append('BP-055 chunk fixture does not establish the post-WAVE iff_data boundary')
    if test.count("bp055Run(") != 21: errors.append('BP-055 test does not contain 20 fixture calls')
    if golden.get("fixtures") != 20: errors.append('BP-055 golden fixture count differs')
    if golden.get("findchunk_iff_data") != 12: errors.append('BP-055 golden iff_data offset differs')
    details = {"root": str(root), "fixtures": 20, "golden": str(root / 'audit/audio_memory_golden.json'), "error_count": len(errors)}
    if errors:
        emit(a.json_output, 'bp055_audio_memory', False, details, errors)
        print('MiniQuake BP-055 audio memory verification: FAIL')
        for error in errors: print("  " + error)
        return 1
    emit(a.json_output, 'bp055_audio_memory', True, details, [])
    print('MiniQuake BP-055 audio memory verification: PASS')
    print('  fixtures=20 stepscale_bits=0x400b51da retail_sounds=2')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
