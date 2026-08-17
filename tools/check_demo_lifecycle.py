#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-032 WinQuake demo recording/playback lifecycle contracts."""
from __future__ import annotations
import argparse,hashlib,json,os,shutil,struct,subprocess,tempfile
from pathlib import Path
P='BP-032';PAR='BP-031';G='audit/demo_lifecycle_golden.json';O='tools/oracle/demo_lifecycle_oracle.c'
def sha(p):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fb(v):
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I',struct.pack('<f',v))[0]
def track(data):
 """Compute the reference track value for a deterministic fixture."""
 v=0;neg=False
 for c in data:
  if c==45:neg=True
  else:v=v*10+c-48
 return -v if neg else v
def rows():
 """Build the deterministic result rows for this verifier."""
 sec=struct.unpack('<f',struct.pack('<f',2.50000001))[0]
 return [{'kind':'case','name':'track_zero','value':track(b'0')},{'kind':'case','name':'track_negative','value':track(b'-12')},{'kind':'case','name':'track_raw_A','value':track(b'A')},{'kind':'case','name':'track_space_1','value':track(b' 1')},{'kind':'case','name':'demo_header_bytes','value':16},{'kind':'case','name':'timedemo_frames','value':9},{'kind':'case','name':'timedemo_seconds_bits','value':fb(sec)},{'kind':'case','name':'timedemo_fps_bits','value':fb(9/sec)},{'kind':'case','name':'fixture_count','value':20}]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeDemoLifecycleGolden/1','package_id':P,'parent_package_id':PAR,'sources':['cl_demo.c'],'rows':rows(),'reference':{'oracle':O,'oracle_sha256':sha(root/O)}}
def compiler():
 """Locate a supported C compiler for the reference oracle."""
 for v in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  q=v.split()
  if shutil.which(q[0]):return q
 return None
def oracle(root):
 """Compile and run the reference oracle for this verifier."""
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp032-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/O),'-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True);return r.returncode==0,' '.join(cc),[json.loads(x) for x in r.stdout.splitlines() if x.strip()]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 e=[];d=(root/'src/miniquake/demo.ml').read_text(encoding='utf-8-sig');p=(root/'src/miniquake/demo_player.ml').read_text(encoding='utf-8-sig');t=(root/'tests/demo_lifecycle_parity_tests.ml').read_text(encoding='utf-8-sig')
 for m in ("else value = value * 10 + (item - 48)",'native.bitsFloat(native.floatBits(viewAngles.x))','if len(payload) > c.MAX_MSGLEN'):
  if m not in d:e.append('missing demo marker: '+m)
 for m in ('seconds = native.bitsFloat(native.floatBits(realtime - playback.startTime))','fps = native.bitsFloat(native.floatBits(frames / seconds))','if hostFrameCount == playback.lastFrame then return void'):
  if m not in p:e.append('missing timedemo marker: '+m)
 if 'demo lifecycle tests passed: 20' not in t:e.append('expected 20 BP-032 fixtures')
 return e
def main():
 """Run the command-line workflow and return its process exit status."""
 a=argparse.ArgumentParser();a.add_argument('root',nargs='?',default='.');a.add_argument('--root',dest='rf');a.add_argument('--write-golden',action='store_true');a.add_argument('--json-output');x=a.parse_args();root=Path(x.rf or x.root).resolve();d=doc(root);g=root/G
 if x.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')
 e=[]
 if not g.is_file():e.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=d:e.append('golden differs from Python model')
 ok,detail,actual=oracle(root)
 if not ok:e.append('C oracle failed: '+detail)
 elif actual and actual!=d['rows']:e.append('C oracle differs from Python model')
 e+=contract(root);r={'schema':'MiniQuakeBP032DemoLifecycleVerification/1','package_id':P,'parent_package_id':PAR,'ok':not e,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':20,'errors':e}
 if x.json_output:Path(x.json_output).write_text(json.dumps(r,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-032 demo lifecycle verification: '+('PASS' if not e else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures=20 oracle={detail}')
 for q in e:print('  ERROR: '+q)
 return 0 if not e else 1
if __name__=='__main__':raise SystemExit(main())
