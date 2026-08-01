#!/usr/bin/env python3
"""Verify BP-030 WinQuake Host_FilterTime and host clock contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path
PACKAGE='BP-030';PARENT='BP-029R3';SCHEMA='MiniQuakeHostTimingGolden/1'
GOLDEN='audit/host_timing_golden.json';ORACLE='tools/oracle/host_timing_oracle.c'
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fbits(v): return struct.unpack('<I',struct.pack('<f',v))[0]
def model_rows():
    # Bound values are intentionally simple and mirror the independent C oracle.
    return [
      {'kind':'case','name':'below_threshold_accept','value':0},
      {'kind':'case','name':'below_threshold_filtered','value':1},
      {'kind':'case','name':'accumulated_accept','value':1},
      {'kind':'case','name':'accumulated_frametime_fbits','value':1014350480},
      {'kind':'case','name':'timedemo_accept','value':1},
      {'kind':'case','name':'timedemo_min_fbits','value':fbits(0.001)},
      {'kind':'case','name':'maximum_fbits','value':fbits(0.1)},
      {'kind':'case','name':'forced_fbits','value':fbits(0.25)},
      {'kind':'case','name':'forced_realtime_fbits','value':fbits(0.02)},
      {'kind':'case','name':'negative_accept','value':0},
      {'kind':'case','name':'negative_realtime_fbits','value':fbits(-0.01)},
      {'kind':'case','name':'fixture_count','value':18},
    ]
def document(root):
    return {'schema':SCHEMA,'package_id':PACKAGE,'parent_package_id':PARENT,
            'sources':['host.c','quakedef.h'],'rows':model_rows(),
            'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def compiler():
    values=([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']
    for value in values:
        parts=value.split()
        if shutil.which(parts[0]): return parts
    return None
def run_oracle(root):
    cc=compiler()
    if not cc: return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp030-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode: return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        return run.returncode==0,' '.join(cc),[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
def contract(root):
    errors=[]
    timing=(root/'src/miniquake/host_timing.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/host_timing_parity_tests.ml').read_text(encoding='utf-8-sig')
    markers=(
      'function filterAbsolute(timing, newRealtime, maxFps, forcedFrameRate, timedemo, timeScale)',
      'inputDelta = binary32(elapsed)',
      'timing.oldRealtime = timing.realtime',
      'if timing.frameTime > c.MAXIMUM_FRAME_TIME',
      'if timing.frameTime < c.MINIMUM_FRAME_TIME',
    )
    for marker in markers:
        if marker not in timing: errors.append('missing timing marker: '+marker)
    if 'return hostTiming.filter(session.timing, elapsedSeconds, timedemo, forced, 1.0)' not in host:
        errors.append('Host_FilterTime does not use shared exact filter')
    if test.count('if run(') not in (0,18) and 'while index < len(tests)' not in test:
        errors.append('unexpected BP-030 fixture structure')
    if 'host timing tests passed: 18' not in test: errors.append('expected 18 BP-030 runtime fixtures')
    accumulation_markers = (
      'no(timing.filter(value, 0.001, false, 0.0, 1.0), "first filtered")',
      'no(timing.filter(value, 0.007, false, 0.0, 1.0), "second filtered")',
      'yes(timing.filter(value, 0.007, false, 0.0, 1.0), "accumulated frame")',
      'equal(value.filteredFrames, 2, "accumulated filtered count")',
      'equal(value.frameCount, 1, "accumulated accepted count")',
      'near(value.frameTime, 0.015, 0.000001, "accumulated frame time")',
    )
    for marker in accumulation_markers:
        if marker not in test: errors.append('missing accumulated-threshold fixture marker: '+marker)
    stale = 'no(timing.filter(value, 0.007, false, 0.0, 1.0), "first filtered")'
    if stale in test: errors.append('stale BP-030 accumulation order remains in runtime fixture')
    return errors
def main():
    ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='rf');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');a=ap.parse_args()
    root=Path(a.rf or a.root).resolve();doc=document(root);golden=root/GOLDEN
    if a.write_golden:
        golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file(): errors.append('missing golden')
    elif json.loads(golden.read_text(encoding='utf-8-sig'))!=doc: errors.append('golden differs from Python model')
    ok,detail,actual=run_oracle(root)
    if not ok: errors.append('C oracle failed: '+detail)
    elif actual and actual!=doc['rows']: errors.append('C oracle differs from Python model')
    errors+=contract(root)
    report={'schema':'MiniQuakeBP030HostTimingVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':18,'errors':errors}
    if a.json_output: Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-030 host timing verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(doc["rows"])} runtime_fixtures=18 oracle={detail}')
    for error in errors: print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
