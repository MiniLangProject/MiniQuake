#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    src=(root/'src/miniquake/input.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    vid=(root/'src/miniquake/gl_vidnt.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/input_device_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/input_device_golden.json').read_text())
    for m in ['function IN_ClearDeviceStates()', 'if mouseActive then',
              'if filterEnabled then\n    filteredX = (mouseX + oldMouseX) * 0.5']:
        if m not in src: errors.append('input.ml missing marker: '+m)
    if 'if filterEnabled and mouseFilterReady then' in src: errors.append('first filtered sample still bypasses averaging')
    if 'input.IN_ClearDeviceStates()' not in host: errors.append('host focus path does not use device-only clear')
    if 'input.IN_ClearDeviceStates()' not in vid: errors.append('video clear path does not use device-only clear')
    if 'MiniQuake BP-066 input device tests passed: 22' not in test: errors.append('fixture count marker missing')
    if golden.get('fixtures')!=22 or golden.get('joystick_axes')!=6: errors.append('golden mismatch')
    report={'schema_version':1,'package':'BP-066','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':22,'first_filtered':golden.get('first_filtered'),'device_only_clear':not errors}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-066 input device verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
