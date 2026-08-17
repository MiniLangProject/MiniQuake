#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    golden=json.loads((root/'audit/gameplay_statusbar_golden.json').read_text())
    test=(root/'tests/gameplay_statusbar_tests.ml').read_text(encoding='utf-8-sig')
    sbar=(root/'src/miniquake/statusbar.ml').read_text(encoding='utf-8-sig')
    for marker in ['MiniQuake BP-078 statusbar/scoreboard tests passed: 23','function testSortStableTie()','function testFaceHealthBands()']:
        if marker not in test: errors.append('test missing: '+marker)
    for marker in ['const SBAR_HEIGHT = 24','function Sbar_SortFrags(scores)','return mapColor + 8','function Sbar_IntermissionOverlay()']:
        if marker not in sbar: errors.append('statusbar missing: '+marker)
    expected={'fixtures':23,'statusbar_height':24,'statusbar_width':320,'max_scoreboard':16,'palette_offset':8,'health_faces':5,'normal_weapons':7}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'golden {k}: expected {v}, got {golden.get(k)!r}')
    report={'schema_version':1,'package':'BP-078','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':23}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-078 statusbar/scoreboard verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
