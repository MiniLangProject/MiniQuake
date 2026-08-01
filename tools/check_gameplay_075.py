#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    golden=json.loads((root/'audit/gameplay_math_chase_golden.json').read_text())
    test=(root/'tests/gameplay_math_chase_tests.ml').read_text(encoding='utf-8-sig')
    chase=(root/'src/miniquake/chase.ml').read_text(encoding='utf-8-sig')
    math=(root/'src/miniquake/mathlib.ml').read_text(encoding='utf-8-sig')
    required=[
        (test,'MiniQuake BP-075 math/chase tests passed: 22'),
        (test,'function testChasePreservesYawRoll()'),
        (chase,'const CHASE_BACK_DEFAULT = 100.0'),
        (chase,'farDestination = math.VectorMA(viewOrigin, 4096.0, forward)'),
        (chase,'adjustedAngles.x = -math.atan2(stopDelta.z, distance) * math.RAD_TO_DEG'),
        (math,'quantized = native.trunc(angle * (65536.0 / 360.0)) & 65535'),
    ]
    for text,marker in required:
        if marker not in text: errors.append('missing source marker: '+marker)
    expected={'fixtures':22,'angle_units':65536,'trace_distance':4096,'chase_back':100,'chase_up':16,'chase_right':0}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'golden {k}: expected {v}, got {golden.get(k)!r}')
    report={'schema_version':1,'package':'BP-075','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':22}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-075 math/chase verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
