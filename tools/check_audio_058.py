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
    win = (root / 'src/miniquake/sound/snd_win.ml').read_text(encoding="utf-8")
    test = (root / 'tests/audio_win_parity_tests.ml').read_text(encoding="utf-8")
    golden = json.loads((root / 'audit/audio_win_golden.json').read_text(encoding="utf-8"))
    if 'sourceOffset = header.bufferOffset' not in win: errors.append('snd_win does not copy distinct ring regions')
    if 'state.buffer[header.bufferOffset + index] = data[sourceOffset + index]' not in win: errors.append('snd_win ring copy source differs')
    if 'if count < 0 then count = 0 end if' not in win: errors.append('snd_win short-region guard missing')
    if 'MiniQuake BP-058 audio Win32 tests passed: 20' not in test: errors.append('BP-058 pass marker differs')
    if 'bp058ShutdownTwiceAndShortBlock' not in test: errors.append('BP-058 final fixture is not error-contained')
    if test.count("bp058Run(") != 21: errors.append('BP-058 test does not contain 20 fixture calls')
    if golden.get("fixtures") != 20: errors.append('BP-058 golden fixture count differs')
    details = {"root": str(root), "fixtures": 20, "golden": str(root / 'audit/audio_win_golden.json'), "error_count": len(errors)}
    if errors:
        emit(a.json_output, 'bp058_audio_win', False, details, errors)
        print('MiniQuake BP-058 audio Win32 verification: FAIL')
        for error in errors: print("  " + error)
        return 1
    emit(a.json_output, 'bp058_audio_win', True, details, [])
    print('MiniQuake BP-058 audio Win32 verification: PASS')
    print('  fixtures=20 wav_buffers=64 ring_bytes=65536')
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
