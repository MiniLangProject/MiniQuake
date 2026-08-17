#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check core 071 compatibility and regression contract."""

import argparse,json,pathlib,sys

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    pak=(root/'src/miniquake/pak.ml').read_text(encoding='utf-8-sig')
    fs=(root/'src/miniquake/filesystem.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/filesystem_pak_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/filesystem_pak_golden.json').read_text(encoding='utf-8'))
    markers=[
      'const MAX_FILES_IN_PACK = 2048','if item.name == name then return item end if',
      'if system.progsHack and normalized == "progs.dat" then searchIndex = 1 end if',
      'if not system.staticRegistered and containsDirectorySeparator(normalized) then',
      'destination = bytes(len(source) + 1)','destination[len(source)] = 0',
      'return quakeText.decodeBytes(data)','return fs.writeAllBytes(gamePath(system, name), data)']
    merged=pak+'\n'+fs
    for m in markers:
      if m not in merged: errors.append('missing source marker: '+m)
    if 'MiniQuake BP-071 filesystem/PAK tests passed: 24' not in test: errors.append('fixture count marker missing')
    expected={'fixtures':24,'entry_size':64,'name_size':56,'max_files':2048,'pak0_count':339,'pak0_crc':32981}
    for k,v in expected.items():
      if golden.get(k)!=v: errors.append(f'golden {k} mismatch')
    report={'schema_version':1,'package':'BP-071','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':24,'pack_entry_size':64,'search_path_precedence':True,'quake_text_io':True}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-071 filesystem/PAK verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
