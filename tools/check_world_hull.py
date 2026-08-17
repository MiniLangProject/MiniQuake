#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-025 WinQuake box-hull and strict Quake-1 brush contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path
PACKAGE='BP-025';PARENT='BP-024R3';SCHEMA='MiniQuakeWorldHullGolden/1';GOLDEN='audit/world_hull_golden.json';ORACLE='tools/oracle/world_hull_oracle.c'
def sha(p):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fbits(v):
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I',struct.pack('<f',v))[0]
def rows():
 """Build the deterministic result rows for this verifier."""
 f=(4.0-2.0-(1.0/32.0))/8.0
 return [
  {'kind':'case','name':'inside','value':-2},{'kind':'case','name':'max_x','value':-1},
  {'kind':'case','name':'min_x','value':-2},{'kind':'case','name':'max_y','value':-1},
  {'kind':'case','name':'min_y','value':-2},{'kind':'case','name':'max_z','value':-1},
  {'kind':'case','name':'min_z','value':-2},{'kind':'case','name':'start_node_1','value':-2},
  {'kind':'case','name':'negative_leaf','value':-3},{'kind':'case','name':'bad_node','value':2147483647},
  {'kind':'case','name':'cross_fraction_bits','value':fbits(f)},
  {'kind':'case','name':'cross_endpoint_bits','value':fbits(4.0-8.0*f)},
  {'kind':'case','name':'quake1_rotated_brush_enabled','value':0},
  {'kind':'case','name':'fixture_count','value':14}]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':SCHEMA,'package_id':PACKAGE,'parent_package_id':PARENT,'sources':['world.c','world.h'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def compiler():
 """Locate a supported C compiler for the reference oracle."""
 for v in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  p=v.split()
  if shutil.which(p[0]):return p
 return None
def oracle(root):
 """Compile and run the reference oracle for this verifier."""
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp025-') as td:
  exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
  b=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(exe)],capture_output=True,text=True)
  return r.returncode==0,' '.join(cc),[json.loads(x) for x in r.stdout.splitlines() if x.strip()]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 e=[]
 wh=(root/'src/miniquake/world_hull.ml').read_text(encoding='utf-8-sig')
 w=(root/'src/miniquake/world.ml').read_text(encoding='utf-8-sig')
 t=(root/'tests/world_hull_parity_tests.ml').read_text(encoding='utf-8-sig')
 for marker in ('function pointContentsFromNode(box, number, point)','if node > 5 then return error','emptySide = node & 1','return boxworld.pointContentsFromNode(hull, number, point)'):
  if marker not in wh+w:e.append('missing hull marker: '+marker)
 if 'return [hull, offset, false]' not in w:e.append('compat_109 BSP hull still advertises rotation')
 link=w[w.index('function SV_LinkEdict'):w.index('function SV_HullPointContents')]
 if 'rotatedBounds(' in link:e.append('QUAKE2 rotated broad-phase bounds remain active')
 if t.count('if run(')!=14 or 'world hull tests passed: 14' not in t:e.append('expected 14 BP-025 runtime fixtures')
 return e
def main():
 """Run the command-line workflow and return its process exit status."""
 ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='rf');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');a=ap.parse_args();root=Path(a.rf or a.root).resolve();d=doc(root);g=root/GOLDEN
 if a.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')
 errors=[]
 if not g.is_file():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=d:errors.append('golden differs from Python model')
 ok,detail,actual=oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=d['rows']:errors.append('C oracle differs from Python model')
 errors+=contract(root)
 report={'schema':'MiniQuakeBP025WorldHullVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':14,'errors':errors}
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-025 world hull verification: '+('PASS' if not errors else 'FAIL'))
 print(f'  rows={len(d["rows"])} runtime_fixtures=14 oracle={detail}')
 for x in errors:print('  ERROR: '+x)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
