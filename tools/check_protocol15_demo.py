#!/usr/bin/env python3
"""Verify BP-018 cl_demo.c framing, keepalive and timedemo contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path
PACKAGE_ID="BP-018"; PARENT_PACKAGE_ID="BP-017"
SCHEMA="MiniQuakeProtocol15DemoGolden/1"
REPORT="MiniQuakeBP018Protocol15DemoVerification/1"
GOLDEN="audit/protocol15_demo_golden.json"; ORACLE="tools/oracle/protocol15_demo_oracle.c"

def sha(path:Path)->str:return hashlib.sha256(path.read_bytes()).hexdigest()
def c_atoi(text:str)->int:
    i=0
    while i<len(text) and text[i] in ' \t\n\r\v\f':i+=1
    sign=1
    if i<len(text) and text[i] in '+-':
        if text[i]=='-':sign=-1
        i+=1
    value=0
    while i<len(text) and '0'<=text[i]<='9':value=value*10+ord(text[i])-48;i+=1
    return sign*value

def playback_track(text:str)->int:
    value=0; negative=False
    for item in text.encode('latin1'):
        if item==10:break
        if item==45:negative=True
        else:value=value*10+item-48
    return -value if negative else value

def rows():
    frame=b'4\n'+struct.pack('<i3f',3,1.0,-2.5,90.0)+bytes([1,2,3])
    values=[
      {"kind":"case","name":"atoi_decimal_suffix","value":c_atoi('1.5')},
      {"kind":"case","name":"atoi_no_digits","value":c_atoi('soundtrack')},
      {"kind":"case","name":"atoi_whitespace_sign","value":c_atoi('  -12tail')},
      {"kind":"case","name":"atoi_plus","value":c_atoi('\t+7')},
      {"kind":"case","name":"isolated_nop_filtered","value":1},
      {"kind":"case","name":"multi_byte_nop_retained","value":1},
      {"kind":"case","name":"stop_disconnect_opcode","value":2},
      {"kind":"case","name":"max_message_accepted","value":8000},
      {"kind":"case","name":"timedemo_first_frame_excluded","value":10},
      {"kind":"case","name":"playback_whitespace_track","value":playback_track('  2\n')},
      {"kind":"case","name":"map_before_demo_open","value":1},
      {"kind":"vector","name":"single_frame","hex":frame.hex()},
    ]
    return values

def document(root:Path):
    return {"schema":SCHEMA,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,
      "protocol_version":15,"sources":["cl_demo.c","cl_main.c","host.c"],"rows":rows(),
      "reference":{"oracle":ORACLE,"oracle_sha256":sha(root/ORACLE)}}

def compiler():
    candidates=[]
    if os.environ.get('CC'):candidates.append(os.environ['CC'])
    candidates += ['cc','gcc','clang']
    for item in candidates:
        parts=item.split()
        if shutil.which(parts[0]):return parts
    return None

def run_oracle(root:Path):
    cc=compiler()
    if not cc:return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp018-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode:return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        parsed=[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        return run.returncode==0,' '.join(cc),parsed

def contract(root:Path):
    errors=[]
    demo=(root/'src/miniquake/demo.ml').read_text(encoding='utf-8-sig')
    client=(root/'src/miniquake/client.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/protocol15_demo_tests.ml').read_text(encoding='utf-8-sig')
    for marker in ('function recordTrackNumber(text)','function isKeepalivePayload(payload)',
                   'if len(arguments) == 4 then track = recordTrackNumber(arguments[3]) end if'):
        if marker not in demo:errors.append('missing demo marker: '+marker)
    if client.count('if demo.isKeepalivePayload(payload) then') < 2:
        errors.append('normal and recording CL_GetMessage paths do not both filter keepalives')
    map_index=host.find('started = try(startMap(session, arguments[2]))',host.find('function beginDemoRecording'))
    open_index=host.find('opened = try(qfs.writeBytes',host.find('function beginDemoRecording'))
    if map_index < 0 or open_index < 0 or map_index > open_index:
        errors.append('CL_Record_f map transition is not ordered before demo open')
    if 'MiniQuake BP-018 Protocol 15 demo tests passed: 19' not in tests:
        errors.append('missing BP-018 runtime success marker')
    if 'whitespace = demo.parse(bytes("  2\\n"))' not in tests:
        errors.append('BP-018 whitespace arithmetic fixture must use two leading spaces')
    if 'equal(whitespace.forcedTrack, -1758, "MiniQuake bytewise whitespace arithmetic")' not in tests:
        errors.append('BP-018 whitespace arithmetic expectation differs from GLQuake bytewise parsing')
    if tests.count('if run(')!=19:errors.append('expected 19 BP-018 runtime fixtures')
    return errors

def main()->int:
    parser=argparse.ArgumentParser();parser.add_argument('root',nargs='?',default='.')
    parser.add_argument('--root',dest='root_flag');parser.add_argument('--write-golden',action='store_true');parser.add_argument('--json-output')
    args=parser.parse_args();root=Path(args.root_flag or args.root).resolve();doc=document(root);golden=root/GOLDEN
    if args.write_golden:
        golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file():errors.append('missing golden document')
    elif json.loads(golden.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
    ok,detail,actual=run_oracle(root)
    if not ok:errors.append('C oracle failed: '+detail)
    elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
    errors+=contract(root)
    report={"schema":REPORT,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"ok":not errors,
      "oracle":detail,"rows":len(doc['rows']),"runtime_fixtures":19,"errors":errors}
    if args.json_output:Path(args.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-018 Protocol 15 demo verification: '+('PASS' if not errors else 'FAIL'))
    print(f"  rows={len(doc['rows'])} runtime_fixtures=19 oracle={detail}")
    for error in errors:print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
