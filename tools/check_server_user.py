#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check server user compatibility and regression contract."""

from __future__ import annotations
import argparse,hashlib,json,os,shutil,struct,subprocess,tempfile
from pathlib import Path
PACKAGE='BP-029';PARENT='BP-028';GOLDEN='audit/server_user_golden.json';ORACLE='tools/oracle/server_user_oracle.c'
def sha(p):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fbits(v):
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I',struct.pack('<f',v))[0]
def rows():
 """Build the deterministic result rows for this verifier."""
 vals=[('status_casefold',1),('status_prefix',1),('name_casefold',1),('say_team_prefix',1),('map_not_whitelisted',0),('privileged_allowed_source',1),('privileged_arbitrary_source',2),('waterjump_equal_time_kept',1),('waterjump_later_cleared',1),('frame_lower_bits',fbits(0.0)),('frame_upper_bits',fbits(0.1)),('ping_quarter_bits',fbits(.25)),('ping_tenth_bits',fbits(5.0-struct.unpack('<f',struct.pack('<f',4.9))[0])),('air_accel_cap_bits',fbits(30.0)),('ideal_pitch_scale_bits',fbits(.8)),('max_forward',6),('move_command_bytes',16),('fixture_count',18),('strict_quake1',1)]
 return [{'kind':'case','name':n,'value':v} for n,v in vals]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeServerUserGolden/1','package_id':PACKAGE,'parent_package_id':PARENT,'sources':['sv_user.c','client.h','protocol.h'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
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
 with tempfile.TemporaryDirectory(prefix='mq-bp029-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(c+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True);return r.returncode==0,' '.join(c),[json.loads(z) for z in r.stdout.splitlines() if z.strip()]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 e=[];s=(root/'src/miniquake/sv_user.ml').read_text(encoding='utf-8-sig');t=(root/'tests/server_user_parity_tests.ml').read_text(encoding='utf-8-sig')
 for m in ('function quakeFloat(value)','ping = quakeFloat(state.server.time - clientTime)','if svuAllowedCommand(text) then','if clientValue.privileged then','function SV_RunClients'):
  if m not in s:e.append('missing sv_user marker: '+m)
 fn=s[s.index('function svuExecuteString'):s.index('// SV_ReadClientMessage',s.index('function svuExecuteString'))]
 if fn.index('if svuAllowedCommand')>fn.index('if clientValue.privileged'):e.append('privileged command priority differs from sv_user.c')
 if 'runtime.executeStringCommand(state.server, clientValue, text, player)\n    return true' not in fn:
  e.append('allowed src_client dispatch is not normalized to accepted command semantics')
 if 'expectedPingBits = native.floatBits(5.0 - decodedClientTime)' not in t:
  e.append('double-minus-decoded-float ping fixture is missing')
 if t.count('if parityRun(')!=18 or 'server user tests passed: 18' not in t:e.append('expected 18 BP-029 user fixtures')
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
 report={'schema':'MiniQuakeBP029ServerUserVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':18,'errors':errors}
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-029 server user verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures=18 oracle={detail}')
 for x in errors:print('  ERROR: '+x)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
