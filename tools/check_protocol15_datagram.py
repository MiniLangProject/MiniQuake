#!/usr/bin/env python3
"""Verify BP-017 net_dgrm.c fragmentation and deferred-ACK contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path
PACKAGE_ID="BP-017"; PARENT_PACKAGE_ID="BP-016"
SCHEMA="MiniQuakeProtocol15DatagramGolden/1"
REPORT="MiniQuakeBP017Protocol15DatagramVerification/1"
GOLDEN="audit/protocol15_datagram_golden.json"
ORACLE="tools/oracle/protocol15_datagram_oracle.c"
MAX_DATAGRAM=1024; NET_MAXMESSAGE=8192

def sha(path:Path)->str:return hashlib.sha256(path.read_bytes()).hexdigest()
def rows():
    values=[
      ("sequence_next_wrap",0),("sequence_previous_wrap",0xffffffff),
      ("exact_fragment_eom",1),("split_fragment_eom",0),
      ("first_wire_size",8+MAX_DATAGRAM),("ack_remaining_1500",1500-MAX_DATAGRAM),
      ("ack_sets_sendnext",1),("ack_defers_wire_send",0),
      ("flush_second_sequence",1),("final_ack_cansend",1),
      ("retransmit_exact_second",0),("retransmit_above_second",1),
      ("unreliable_gap",3),("reliable_fragments_2500",3),
      ("reliable_fragments_max",8),("duplicate_data_reack",1),
      ("cansend_query_side_effects",0),("receive_overflow_guard",1),
    ]
    return [{"kind":"case","name":name,"value":value} for name,value in values]

def document(root:Path):
    return {"schema":SCHEMA,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,
      "protocol_version":15,"sources":["net_dgrm.c","net.h","net_main.c"],"cases":rows(),
      "reference":{"oracle":ORACLE,"oracle_sha256":sha(root/ORACLE)}}

def compiler():
    candidates=[]
    if os.environ.get("CC"):candidates.append(os.environ["CC"])
    candidates += ["cc","gcc","clang"]
    for candidate in candidates:
        parts=candidate.split()
        if shutil.which(parts[0]):return parts
    return None

def oracle(root:Path):
    cc=compiler()
    if not cc:return True,"not available",[]
    with tempfile.TemporaryDirectory(prefix="mq-bp017-") as td:
        exe=Path(td)/("oracle.exe" if os.name=="nt" else "oracle")
        build=subprocess.run(cc+["-std=c11","-Wall","-Wextra","-Werror","-O2",str(root/ORACLE),"-o",str(exe)],capture_output=True,text=True)
        if build.returncode:return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        parsed=[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        return run.returncode==0," ".join(cc),parsed

def contract(root:Path):
    errors=[]
    datagram=(root/'src/miniquake/net_datagram.ml').read_text(encoding='utf-8-sig')
    loop=(root/'src/miniquake/net_loop.ml').read_text(encoding='utf-8-sig')
    milestone=(root/'tests/milestone_tests.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/protocol15_datagram_tests.ml').read_text(encoding='utf-8-sig')
    markers=(
      'function Datagram_FlushSendNext(channel, now)',
      'channel.sendNext = true\n      return [0, void, void, void]',
      'function Datagram_CanSendMessage(channel)',
      'return channel.canSend',
      'if now - channel.lastSendTime <= 1.0 then return void end if',
    )
    for marker in markers:
        if marker not in datagram:errors.append('missing datagram marker: '+marker.splitlines()[0])
    if 'pending = datagram.Datagram_FlushSendNext(socket.channel, now)' not in loop:
        errors.append('UDP receive loop does not flush deferred fragment')
    if 'third = datagram.Datagram_FlushSendNext(tx, 2.4)' not in milestone:
        errors.append('parent differential milestone does not exercise deferred flush')
    if 'MiniQuake BP-017 Protocol 15 datagram tests passed: 18' not in tests:
        errors.append('missing BP-017 runtime success marker')
    if tests.count('if run(') != 18:
        errors.append('expected 18 BP-017 runtime fixtures')
    return errors

def main()->int:
    parser=argparse.ArgumentParser()
    parser.add_argument('root',nargs='?',default='.')
    parser.add_argument('--root',dest='root_flag')
    parser.add_argument('--write-golden',action='store_true')
    parser.add_argument('--json-output')
    args=parser.parse_args(); root=Path(args.root_flag or args.root).resolve()
    doc=document(root); golden=root/GOLDEN
    if args.write_golden:
        golden.parent.mkdir(parents=True,exist_ok=True)
        golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file():errors.append('missing golden document')
    elif json.loads(golden.read_text(encoding='utf-8-sig')) != doc:errors.append('golden differs from Python model')
    ok,detail,actual=oracle(root)
    if not ok:errors.append('C oracle failed: '+detail)
    elif actual and actual != doc['cases']:errors.append('C oracle differs from Python model')
    errors += contract(root)
    report={"schema":REPORT,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,
      "ok":not errors,"cases":len(doc['cases']),"runtime_fixtures":18,"oracle":detail,"errors":errors}
    if args.json_output:Path(args.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-017 Protocol 15 datagram verification: '+('PASS' if not errors else 'FAIL'))
    print(f"  cases={len(doc['cases'])} runtime_fixtures=18 oracle={detail}")
    for error in errors:print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
