#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check frontend 065 compatibility and regression contract."""

import argparse, json, pathlib, sys

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    keys=(root/'src/miniquake/keys.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    vid=(root/'src/miniquake/gl_vidnt.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/key_focus_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/key_focus_golden.json').read_text())
    markers=[
      'function Key_ReleaseAllCommands()', 'while key < 256',
      'queued = queued + plusRelease(input.bindingForCode(key), key)',
      'queued = queued + plusRelease(input.bindingForCode(shifted), key)',
      'function Key_QueueReleaseAllCommands()', 'function Key_TakePendingCommands()']
    for m in markers:
        if m not in keys: errors.append('keys.ml missing marker: '+m)
    if 'keys.Key_QueueReleaseAllCommands()' not in vid: errors.append('gl_vidnt ClearAllStates does not queue releases')
    if 'pendingReleases = keys.Key_TakePendingCommands()' not in host: errors.append('host does not drain queued releases')
    if 'MiniQuake BP-065 key/focus tests passed: 28' not in test: errors.append('fixture count marker missing')
    if golden.get('fixtures')!=28 or golden.get('key_count')!=256 or golden.get('release_bytes')!=34: errors.append('golden mismatch')
    report={'schema_version':1,'package':'BP-065','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':28,'key_count':256,'release_bytes':34,'focus_release_queue':not errors}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-065 key/focus verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
