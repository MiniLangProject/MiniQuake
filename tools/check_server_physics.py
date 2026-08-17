#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check server physics compatibility and regression contract."""

from __future__ import annotations
import argparse,hashlib,json,os,shutil,struct,subprocess,tempfile
from pathlib import Path
PACKAGE='BP-028';PARENT='BP-027';GOLDEN='audit/server_physics_golden.json';ORACLE='tools/oracle/server_physics_oracle.c'
RUNTIME_FIXTURES=22
def sha(p):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fbits(v):
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I',struct.pack('<f',v))[0]
def rows():
 """Build the deterministic result rows for this verifier."""
 vals=[('stop_epsilon_bits',fbits(.1)),('step_size_bits',fbits(18.0)),('max_clip_planes',5),('fly_bumps',4),('push_overbounce_bits',fbits(1.0)),('bounce_overbounce_bits',fbits(1.5)),('default_gravity_bits',fbits(1.0)),('corpse_x_bits',fbits(0.0)),('corpse_y_bits',fbits(0.0)),('corpse_z_bits',fbits(-24.0)),('movetype_follow_allowed',0),('movetype_bouncemissile_allowed',0),('q2_dispatch_enabled',0),('touch_is_strict_overlap',0),('pusher_relink_required',1),('noclip_relink_required',1),('fixture_count',18),('strict_quake1',1)]
 return [{'kind':'case','name':n,'value':v} for n,v in vals]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeServerPhysicsGolden/1','package_id':PACKAGE,'parent_package_id':PARENT,'sources':['sv_phys.c','server.h','world.h'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
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
 with tempfile.TemporaryDirectory(prefix='mq-bp028-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(c+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True);return r.returncode==0,' '.join(c),[json.loads(z) for z in r.stdout.splitlines() if z.strip()]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 e=[];s=(root/'src/miniquake/physics.ml').read_text(encoding='utf-8-sig');t=(root/'tests/server_physics_parity_tests.ml').read_text(encoding='utf-8-sig');old=(root/'tests/sv_phys_port_tests.ml').read_text(encoding='utf-8-sig')
 for m in ('function strictQuake109()','function collapsePusherCorpseBounds(mins)','collision.linkEntity(server, pusherIndex, false)','collision.linkEntity(server, entityIndex, true)','function SV_Physics_NonClientEntity(server, entityIndex, frameTime, gravity, maxVelocity)'):
  if m not in s:e.append('missing physics marker: '+m)
 dispatch=s[s.index('function SV_Physics_NonClientEntity'):s.index('function SV_Physics(server,',s.index('function SV_Physics_NonClientEntity'))]
 for forbidden in ('MOVETYPE_FOLLOW_COMPAT','MOVETYPE_BOUNCEMISSILE_COMPAT','SV_Physics_Step_Quake2'):
  if forbidden in dispatch:e.append('strict dispatch still references '+forbidden)
 pusher=s[s.index('function SV_PushMove'):s.index('// QUAKE2 kept',s.index('function SV_PushMove'))]
 if 'collision.entityAbsMin(server, pusherIndex)' not in pusher or 'collapsePusherCorpseBounds' not in pusher:e.append('pusher bounds/corpse contract missing')
 if t.count('if parityRun(')!=RUNTIME_FIXTURES or f'server physics tests passed: {RUNTIME_FIXTURES}' not in t:e.append(f'expected {RUNTIME_FIXTURES} BP-028 fixtures')
 if 'testStrictQuakeOneDispatch' not in old:e.append('legacy sv_phys regression still expects QUAKE2 auto-dispatch')
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
 report={'schema':'MiniQuakeBP028ServerPhysicsVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':RUNTIME_FIXTURES,'errors':errors}
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-028 server physics verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures={RUNTIME_FIXTURES} oracle={detail}')
 for x in errors:print('  ERROR: '+x)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
