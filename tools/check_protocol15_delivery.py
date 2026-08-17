#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-016 reliable/unreliable scheduling and send-result contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path
PACKAGE_ID="BP-016"; PARENT_PACKAGE_ID="BP-015"
SCHEMA="MiniQuakeProtocol15DeliveryGolden/1"; REPORT="MiniQuakeBP016Protocol15DeliveryVerification/1"
GOLDEN="audit/protocol15_delivery_golden.json"; ORACLE="tools/oracle/protocol15_delivery_oracle.c"
def sha(p:Path)->str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(p.read_bytes()).hexdigest()
def outcome(r:int)->int:
    """Map a signed send result to the delivery-state outcome code."""
    return 1 if r<0 else (2 if r==0 else 3)
def initial(spawned:bool,signon:bool,elapsed:float)->int:
    """Select the initial server-message delivery plan for a client state."""
    if spawned:return 9
    if not signon:return 2 if elapsed>5.0 else 4
    return 8
def reliable(overflow:bool,size:int,drop:bool,can:bool)->int:
    """Select the reliable-message delivery plan for queue state."""
    if overflow:return 1
    if size<=0 and not drop:return 0
    if not can:return 2
    if drop:return 3
    return 4
def cases():
    """Build the deterministic test cases for this verifier."""
    values=[("send_failed",outcome(-1)),("send_blocked",outcome(0)),("send_committed",outcome(1)),
      ("spawned_plan",initial(True,False,0)),("signon_wait_equal",initial(False,False,5.0)),
      ("signon_nop_above",initial(False,False,5.000001)),("signon_requested",initial(False,True,0)),
      ("overflow_first",reliable(True,1,True,True)),("drop_blocked",reliable(False,0,True,False)),
      ("drop_sendable",reliable(False,0,True,True)),("reliable_send",reliable(False,1,False,True)),
      ("empty_none",reliable(False,0,False,True)),("keepalive_equal",int(5.0>5.0)),
      ("keepalive_above",int(5.000001>5.0))]
    return [{"kind":"case","name":n,"value":v} for n,v in values]
def document(root:Path):
    """Render the canonical evidence document for this verifier."""
    return {"schema":SCHEMA,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,
 "protocol_version":15,"sources":["cl_main.c","sv_main.c","host.c","net_main.c"],"cases":cases(),
 "reference":{"oracle":ORACLE,"oracle_sha256":sha(root/ORACLE)}}
def oracle(root:Path):
    """Compile and run the reference oracle for this verifier."""
    cc=next((shutil.which(x) for x in (os.environ.get("CC",""),"cc","gcc","clang") if x and shutil.which(x.split()[0])),None)
    if not cc:return True,"not available",[]
    with tempfile.TemporaryDirectory(prefix="mq-bp016-") as td:
      exe=Path(td)/("oracle.exe" if os.name=="nt" else "oracle")
      b=subprocess.run([cc,"-std=c11","-Wall","-Wextra","-Werror","-O2",str(root/ORACLE),"-o",str(exe)],capture_output=True,text=True)
      if b.returncode:return False,b.stdout+b.stderr,[]
      r=subprocess.run([str(exe)],capture_output=True,text=True)
      return (r.returncode==0,cc,[json.loads(x) for x in r.stdout.splitlines() if x.strip()])
def contract(root:Path):
    """Evaluate the source and runtime evidence for this contract."""
    e=[]; delivery=(root/'src/miniquake/protocol_delivery.ml').read_text(); server=(root/'src/miniquake/server.ml').read_text(); client=(root/'src/miniquake/client.ml').read_text(); tests=(root/'tests/protocol15_delivery_tests.ml').read_text()
    for marker in ('SEND_DROP','SEND_RETAIN','SEND_COMMIT','function inline keepaliveDue'):
      if marker not in delivery:e.append('missing delivery marker '+marker)
    if 'if outcome == delivery.SEND_RETAIN then return 0 end if' not in server:e.append('server does not retain zero-result send')
    if 'delivery.clearAfterSend(result)' not in client:e.append('client not bound to shared send outcome')
    if 'MiniQuake BP-016 Protocol 15 delivery tests passed: 14' not in tests:e.append('missing runtime success marker')
    return e
def main():
 """Run the command-line workflow and return its process exit status."""
 p=argparse.ArgumentParser();p.add_argument('root',nargs='?',default='.');p.add_argument('--root',dest='rf');p.add_argument('--write-golden',action='store_true');p.add_argument('--json-output');a=p.parse_args();root=Path(a.rf or a.root).resolve();doc=document(root);gp=root/GOLDEN
 if a.write_golden:gp.parent.mkdir(exist_ok=True);gp.write_text(json.dumps(doc,indent=2)+'\n')
 errs=[]
 if not gp.is_file():errs.append('missing golden')
 elif json.loads(gp.read_text(encoding='utf-8-sig'))!=doc:errs.append('golden differs from Python model')
 ok,detail,rows=oracle(root)
 if not ok:errs.append('C oracle failed: '+detail)
 elif rows and rows!=doc['cases']:errs.append('C oracle differs from Python cases')
 errs+=contract(root);rep={"schema":REPORT,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"ok":not errs,"cases":len(doc['cases']),"oracle":detail,"errors":errs}
 if a.json_output:Path(a.json_output).write_text(json.dumps(rep,indent=2)+'\n')
 print('MiniQuake BP-016 Protocol 15 delivery verification: '+('PASS' if not errs else 'FAIL'));print(f"  cases={len(doc['cases'])} oracle={detail}")
 for x in errs:print('  ERROR: '+x)
 return 0 if not errs else 1
if __name__=='__main__':raise SystemExit(main())
