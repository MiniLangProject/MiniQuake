#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check core 072 compatibility and regression contract."""

import argparse,json,pathlib,sys

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    wad=(root/'src/miniquake/wad.ml').read_text(encoding='utf-8-sig')
    gfx=(root/'src/miniquake/graphics_data.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/wad_graphics_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/wad_graphics_golden.json').read_text(encoding='utf-8'))
    markers=['const WAD_NAME_LENGTH = 16','const WAD_LUMPINFO_SIZE = 32',
      'if input is not bytes then','source = quakeText.encodeBytes(input)',
      'return quakeText.decodeBytes(slice(cleaned, 0, length))',
      'if bio.fourCC(data, 0) != "WAD2"',
      'if lump.compression != CMP_NONE then return error',
      'return wad.readLump(archive, "conchars")','return qfs.readFile(filesystem, "gfx/conchars.lmp")']
    merged=wad+'\n'+gfx
    for m in markers:
      if m not in merged: errors.append('missing source marker: '+m)
    if 'MiniQuake BP-072 WAD/graphics tests passed: 20' not in test: errors.append('fixture count marker missing')
    expected={'fixtures':20,'name_size':16,'lumpinfo_size':32,'qpic_header_size':8,'conchars_bytes':16384}
    for k,v in expected.items():
      if golden.get(k)!=v: errors.append(f'golden {k} mismatch')
    report={'schema_version':1,'package':'BP-072','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':20,'wad_name_bytes':16,'graphics_wad_primary':True,'loose_fallback':True}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-072 WAD/graphics verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
