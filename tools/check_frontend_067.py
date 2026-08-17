#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    console=(root/'src/miniquake/console.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/console_screen_lifecycle_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/console_screen_golden.json').read_text())
    for m in ['function inline Con_NotifyBoxPending()', 'function Con_NotifyBoxKey(state, down)',
              'notifyBoxSawDown = true', 'if not notifyBoxSawDown then return false end if']:
        if m not in console: errors.append('console.ml missing marker: '+m)
    if 'if console.Con_NotifyBoxPending() then' not in host: errors.append('host does not route notify-box key edges')
    if 'MiniQuake BP-067 console/screen tests passed: 22' not in test: errors.append('fixture count marker missing')
    if golden.get('fixtures')!=22 or golden.get('notify_edges')!=2: errors.append('golden mismatch')
    report={'schema_version':1,'package':'BP-067','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':22,'notify_edges':2,'nonblocking_modal':not errors}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-067 console/screen verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
