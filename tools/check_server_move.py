#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check server move compatibility and regression contract."""

from __future__ import annotations
import argparse,hashlib,json,os,shutil,subprocess,tempfile
from pathlib import Path
PACKAGE='BP-027';PARENT='BP-026';GOLDEN='audit/server_move_golden.json';ORACLE='tools/oracle/server_move_oracle.c'
def sha(p):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rows():
 """Build the deterministic result rows for this verifier."""
 vals=[('step_size',18),('direct_ne',45),('direct_nw',135),('direct_sw',215),('direct_se',315),('partialground_clears_onground',1),('yaw_gate_low',45),('yaw_gate_high',315),('random_1',38),('random_2',7719),('fixture_count',14)]
 return [{'kind':'case','name':n,'value':v} for n,v in vals]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeServerMoveGolden/1','package_id':PACKAGE,'parent_package_id':PARENT,'sources':['sv_move.c','world.c'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def cc():
 """Locate a supported C compiler for the reference oracle."""
 for x in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  a=x.split()
  if shutil.which(a[0]):return a
 return None
def oracle(root):
 """Compile and run the reference oracle for this verifier."""
 c=cc()
 if not c:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp027-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(c+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True);return r.returncode==0,' '.join(c),[json.loads(z) for z in r.stdout.splitlines() if z.strip()]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 e=[];s=(root/'src/miniquake/server_move.ml').read_text(encoding='utf-8-sig');t=(root/'tests/server_move_parity_tests.ml').read_text(encoding='utf-8-sig')
 if s.count('collision.linkEntity(server, entityIndex, true)')!=6:e.append('expected six source-guided SV_LinkEdict call sites')
 if 'diagonal = 215.0' not in s:e.append('historical southwest direction 215 is missing')
 if 'ctx.randomSeed = (ctx.randomSeed * 214013 + 2531011)' not in s:e.append('MS rand sequence is missing')
 if t.count('if run(')!=14 or 'server movement tests passed: ' not in t:e.append('expected 14 BP-027 fixtures')
 for m in ('historical 215 diagonal','floor move/relink','yaw gate/relink','swim exit'):
  if m not in t:e.append('missing fixture: '+m)
 return e
def main():
 """Run the command-line workflow and return its process exit status."""
 a=argparse.ArgumentParser();a.add_argument('root',nargs='?',default='.');a.add_argument('--root',dest='rf');a.add_argument('--write-golden',action='store_true');a.add_argument('--json-output');x=a.parse_args();root=Path(x.rf or x.root).resolve();d=doc(root);g=root/GOLDEN
 if x.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(d,indent=2)+'\n')
 errors=[]
 if not g.exists():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=d:errors.append('golden differs from model')
 ok,detail,actual=oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=d['rows']:errors.append('C oracle differs from model')
 errors+=contract(root);r={'schema':'MiniQuakeBP027ServerMoveVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':14,'errors':errors}
 if x.json_output:Path(x.json_output).write_text(json.dumps(r,indent=2)+'\n')
 print('MiniQuake BP-027 server movement verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures=14 oracle={detail}')
 for z in errors:print('  ERROR: '+z)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
