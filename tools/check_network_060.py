#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check network 060 compatibility and regression contract."""

import argparse, json, pathlib, sys

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root', default='.'); ap.add_argument('--json', default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    loop=(root/'src/miniquake/net_loop.ml').read_text(encoding='utf-8-sig')
    main=(root/'src/miniquake/net_main.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/network_main_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/network_main_golden.json').read_text())
    for marker in ['function resolveDatagramTarget(state, host, defaultPort)',
                   'function Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)',
                   'return _Datagram_ConnectPort(state, host, timeoutMilliseconds, 26000)']:
        if marker not in loop: errors.append('net_loop missing marker: '+marker)
    if 'Datagram_ConnectPort(state, target, timeoutMilliseconds, net_hostport)' not in main:
        errors.append('NET_Connect does not pass active net_hostport')
    if 'MiniQuake BP-060 network main tests passed: 20' not in test: errors.append('fixture count marker missing')
    if golden.get('fixtures') != 20 or golden.get('default_port') != 26000: errors.append('golden mismatch')
    report={'schema_version':1,'package':'BP-060','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':20,'default_port':26000,'active_port_forwarded':not errors}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-060 network main verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
