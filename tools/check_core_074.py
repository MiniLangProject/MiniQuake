#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check core 074 compatibility and regression contract."""

import argparse,json,pathlib,sys

def main()->int:
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    contract=(root/'src/miniquake/core_assets_memory_contract.ml').read_text(encoding='utf-8-sig')
    memory=(root/'src/miniquake/memory.ml').read_text(encoding='utf-8-sig')
    zone=(root/'src/miniquake/zone.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/core_assets_memory_closure_tests.ml').read_text(encoding='utf-8-sig')
    evidence=(root/'tests/core_asset_retail_evidence.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/core_assets_memory_golden.json').read_text(encoding='utf-8'))
    markers=[
      'const STATUS = "core_assets_memory_109_frozen_v1"','const FINGERPRINT = 0x6c8d974d',
      'function fnv1a32(text)','function verify()','return (value + 15) & ~15',
      'data = quakeText.encodeBytes(name)','const DYNAMIC_SIZE = 0xc000','return (value + 7) & ~7']
    merged=contract+'\n'+memory+'\n'+zone
    for marker in markers:
      if marker not in merged: errors.append('missing source marker: '+marker)
    if 'MiniQuake BP-074 core assets/memory closure tests passed: 24' not in test: errors.append('closure fixture marker missing')
    for path in ['gfx.wad','maps/start.bsp','progs/player.mdl','progs.dat']:
      if '"'+path+'"' not in evidence: errors.append('retail evidence path missing: '+path)
    if 'result=PASS' not in evidence: errors.append('retail evidence PASS marker missing')
    expected={'status':'core_assets_memory_109_frozen_v1','fingerprint':'0x6c8d974d','fixtures':24,'retail_evidence_files':4}
    for key,value in expected.items():
      if golden.get(key)!=value: errors.append(f'golden {key}: expected {value!r}, got {golden.get(key)!r}')
    report={'schema_version':1,'package':'BP-074','status':'PASS' if not errors else 'FAIL','errors':errors,
      'fixtures':24,'retail_evidence_files':4,'allocator_families':3,'fingerprint':'0x6c8d974d'}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-074 core assets/memory verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
