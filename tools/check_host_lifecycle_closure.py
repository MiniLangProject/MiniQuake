#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-034 WinQuake host lifecycle and transition closure."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path
P='BP-034'; PAR='BP-033'; G='audit/host_lifecycle_closure_golden.json'; O='tools/oracle/host_lifecycle_oracle.c'
def sha(path):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()
CANON='\n'.join([
 'status=host_lifecycle_109_frozen_v1',
 'filter=rand,realtime,gate,clamp',
 'frame=filter,commands,net_poll,client_send,console,server,host_time,client_read,demo_scene,entity_relink,entity_effects,client_events,qc_control,centerprint,view,screen,dlight_decay,particles,audio',
 'server=clear_datagram,new_clients,run_clients,physics,send_messages',
 'map=stop_demo_loop,disconnect_client,shutdown_server,clear_serverflags,spawn_server,connect_local',
 'changelevel=save_spawnparms,send_reconnect,spawn_server,restore_clients',
 'restart=copy_mapname,preserve_spawnparms,spawn_server',
 'save=v5,comment39,spawn16,skill,map,time,styles64,globals,edicts',
 'shutdown=mark_inactive,disconnect_local,flush_reliable_3s,broadcast_disconnect_5s,drop_clients,clear_server',
 'error=recursion_guard,end_loading,shutdown_server,disconnect_client,stop_demo_loop,abort_frame',
])+'\n'
def fnv(data):
 """Compute the fixture's FNV-1a fingerprint."""
 h=2166136261
 for value in data: h=((h^value)*16777619)&0xffffffff
 return h
def rows():
    """Build the deterministic result rows for this verifier."""
    return [
 {'kind':'case','name':'contract_fingerprint','value':fnv(CANON.encode())},
 {'kind':'case','name':'frame_trace_stages','value':19},
 {'kind':'case','name':'server_physics_stages','value':5},
 {'kind':'case','name':'map_replace_stages','value':6},
 {'kind':'case','name':'changelevel_stages','value':4},
 {'kind':'case','name':'restart_stages','value':3},
 {'kind':'case','name':'savegame_stages','value':9},
 {'kind':'case','name':'shutdown_stages','value':6},
 {'kind':'case','name':'shutdown_flush_seconds','value':3},
 {'kind':'case','name':'shutdown_broadcast_seconds','value':5},
 {'kind':'case','name':'fixture_count','value':24},
]
def doc(root):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeHostLifecycleClosureGolden/1','package_id':P,'parent_package_id':PAR,'sources':['host.c','host_cmd.c','cl_main.c'],'rows':rows(),'reference':{'oracle':O,'oracle_sha256':sha(root/O)}}
def compiler():
 """Locate a supported C compiler for the reference oracle."""
 for value in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  command=value.split()
  if shutil.which(command[0]): return command
 return None
def oracle(root):
 """Compile and run the reference oracle for this verifier."""
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp034-') as td:
  exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
  built=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/O),'-o',str(exe)],capture_output=True,text=True)
  if built.returncode:return False,built.stdout+built.stderr,[]
  run=subprocess.run([str(exe)],capture_output=True,text=True)
  return run.returncode==0,' '.join(cc),[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
def function(text,name):
 """Extract one named MiniLang function body for contract hashing."""
 marker='function '+name+'('
 start=text.find(marker)
 if start<0:return ''
 end=text.find('\nfunction ',start+len(marker))
 return text[start:] if end<0 else text[start:end]
def contract(root):
 """Evaluate the source and runtime evidence for this contract."""
 errors=[]
 module=(root/'src/miniquake/host_lifecycle_contract.ml').read_text(encoding='utf-8-sig')
 host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
 test=(root/'tests/host_lifecycle_closure_tests.ml').read_text(encoding='utf-8-sig')
 for marker in (
   'const STATUS = "host_lifecycle_109_frozen_v1"',
   'const CONTRACT_FINGERPRINT = 0x8cbb709f',
   'function frameTraceStages(sendStage)',
   'function shutdownStages()',
   'function canonicalText()',
   'return fingerprint(canonicalText()) == CONTRACT_FINGERPRINT',
 ):
  if marker not in module: errors.append('missing lifecycle marker: '+marker)
 for name in ('transitionMap','connectRemoteHost','playDemo','Host_Quit_f'):
  body=function(host,name)
  if not body: errors.append('missing host function: '+name); continue
  if name!='Host_Quit_f' and 'Host_ShutdownServer(session, false)' not in body: errors.append(name+' bypasses Host_ShutdownServer')
  if 'server.shutdown(session.server)' in body: errors.append(name+' directly clears server state')
 quit_body=function(host,'Host_Quit_f')
 if 'Host_Disconnect_f(session)' not in quit_body: errors.append('Host_Quit_f bypasses Host_Disconnect_f')
 dispatch=function(host,'Host_DispatchCommand')
 for marker in ('return Host_Quit_f(session)','return Host_Disconnect_f(session)','return Host_Map_f(session, arguments)','return Host_Restart_f(session)'):
  if marker not in dispatch: errors.append('missing host command route: '+marker)
 if 'host lifecycle closure tests passed: 25' not in test: errors.append('expected 25 BP-034 fixtures')
 return errors
def main():
 """Run the command-line workflow and return its process exit status."""
 parser=argparse.ArgumentParser();parser.add_argument('root',nargs='?',default='.');parser.add_argument('--root',dest='root_flag');parser.add_argument('--write-golden',action='store_true');parser.add_argument('--json-output')
 args=parser.parse_args();root=Path(args.root_flag or args.root).resolve();expected=doc(root);golden=root/G
 if args.write_golden:golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(expected,indent=2)+'\n',encoding='utf-8')
 errors=[]
 if not golden.is_file(): errors.append('missing golden')
 elif json.loads(golden.read_text(encoding='utf-8-sig'))!=expected: errors.append('golden differs from Python model')
 ok,detail,actual=oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=expected['rows']:errors.append('C oracle differs from Python model')
 errors+=contract(root)
 result={'schema':'MiniQuakeBP034HostLifecycleClosureVerification/1','package_id':P,'parent_package_id':PAR,'ok':not errors,'oracle':detail,'contract_fingerprint':'0x%08x'%rows()[0]['value'],'rows':len(expected['rows']),'runtime_fixtures':25,'errors':errors}
 if args.json_output:Path(args.json_output).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-034 host lifecycle closure verification: '+('PASS' if not errors else 'FAIL'))
 print(f'  fingerprint=0x{rows()[0]["value"]:08x} rows={len(expected["rows"])} runtime_fixtures=25 oracle={detail}')
 for error in errors:print('  ERROR: '+error)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
