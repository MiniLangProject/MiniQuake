#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    golden=json.loads((root/'audit/gameplay_view_golden.json').read_text())
    test=(root/'tests/gameplay_view_tests.ml').read_text(encoding='utf-8-sig')
    view=(root/'src/miniquake/view.ml').read_text(encoding='utf-8-sig')
    for marker in [
        'MiniQuake BP-076 view/palette tests passed: 22',
        'function testRefdefNudge()',
        'function testIntermissionRefdef()',
    ]:
        if marker not in test: errors.append('test missing: '+marker)
    for marker in [
        'const NUM_CSHIFTS = 4',
        'while index < 256',
        'player.origin.x + 0.03125',
        'if bob > 4.0 then bob = 4.0 end if',
        'if bob < -7.0 then bob = -7.0 end if',
        'values[index] = common.cAtoi(arguments[index + 1])',
    ]:
        if marker not in view: errors.append('view missing: '+marker)
    expected={'fixtures':22,'gamma_entries':256,'cshift_count':4,'bob_max':4,'bob_min':-7,'view_nudge':0.03125}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'golden {k}: expected {v}, got {golden.get(k)!r}')
    report={'schema_version':1,'package':'BP-076','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':22}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-076 view/palette verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
