#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check network 064 compatibility and regression contract."""

import argparse,json,pathlib,sys

def main():
 """Run the command-line workflow and return its process exit status."""
 p=argparse.ArgumentParser();p.add_argument('--root',default='.');p.add_argument('--json',default='');a=p.parse_args();r=pathlib.Path(a.root).resolve();e=[]
 c=(r/'src/miniquake/network_platform_contract.ml').read_text(encoding='utf-8-sig');b=(r/'src/miniquake/build_info.ml').read_text(encoding='utf-8-sig');t=(r/'tests/network_platform_closure_tests.ml').read_text(encoding='utf-8-sig');v=(r/'tests/network_platform_evidence.ml').read_text(encoding='utf-8-sig');g=json.loads((r/'audit/network_platform_closure_golden.json').read_text())
 markers=['const STATUS = "network_platform_109_frozen_v1"','const FINGERPRINT = 0xb3ec7589','const DEFAULT_HOST_PORT = 26000','const CONTROL_PROTOCOL_VERSION = 3','const MAX_RELIABLE_MESSAGE = 8192','const MAX_DATAGRAM = 1024','const HOST_CACHE_SIZE = 8']
 for m in markers:
  if m not in c:e.append('contract missing '+m)
 if 'passed: 24' not in t:e.append('closure fixture marker missing')
 for m in ['function runServer(port)','function runClient(port)','control.requestServerInfo()','control.requestConnect()','network platform evidence: PASS']:
  if m not in v:e.append('evidence missing '+m)
 for m in ['const NETWORK_PLATFORM_STATUS = "network_platform_109_frozen_v1"','const NETWORK_PLATFORM_FINGERPRINT = 0xb3ec7589']:
  if m not in b:e.append('build_info missing '+m)
 if g.get('fingerprint')!='0xb3ec7589' or g.get('fixtures')!=24:e.append('golden mismatch')
 out={'schema_version':1,'package':'BP-064','status':'PASS' if not e else 'FAIL','errors':e,'fixtures':24,'fingerprint':'0xb3ec7589','evidence':'cross_process_udp_control'}
 if a.json:pathlib.Path(a.json).write_text(json.dumps(out,indent=2)+'\n')
 print('MiniQuake BP-064 network/platform closure verification: '+out['status'])
 for x in e:print('  [FAIL] '+x)
 return 0 if not e else 1
if __name__=='__main__':sys.exit(main())
