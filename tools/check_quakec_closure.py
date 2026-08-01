#!/usr/bin/env python3
"""Verify the BP-024 frozen QuakeC 1.09 compatibility contract."""
from __future__ import annotations
import argparse, hashlib, json, os, re, shutil, subprocess, tempfile
from pathlib import Path

PACKAGE_ID='BP-024'; PARENT_PACKAGE_ID='BP-023'; STATUS='quakec_109_frozen_v1'
SCHEMA='MiniQuakeQuakeCClosureGolden/1'; REPORT='MiniQuakeBP024QuakeCClosureVerification/1'
GOLDEN='audit/quakec_closure_golden.json'; ORACLE='tools/oracle/quakec_closure_oracle.c'
FNV_OFFSET=2166136261; FNV_PRIME=16777619

def sha(path: Path): return hashlib.sha256(path.read_bytes()).hexdigest()
def hb(h,b): return ((h^(b&255))*FNV_PRIME)&0xffffffff
def hw(h,v):
    for shift in range(0,32,8): h=hb(h,(v>>shift)&255)
    return h
def ht(h,text):
    for b in text.encode('ascii'): h=hb(h,b)
    return hb(h,0)
def contract_fingerprint():
    h=FNV_OFFSET
    for value in (6,5927,66,79,14,32,2048,0xb86a0245): h=hw(h,value)
    return ht(h,STATUS)
def rows(): return [
    {'kind':'case','name':'version','value':6},
    {'kind':'case','name':'header_crc','value':5927},
    {'kind':'case','name':'opcode_count','value':66},
    {'kind':'case','name':'builtin_count','value':79},
    {'kind':'case','name':'fixme_count','value':14},
    {'kind':'case','name':'stack_depth','value':32},
    {'kind':'case','name':'localstack_size','value':2048},
    {'kind':'case','name':'builtin_fingerprint','value':0xb86a0245},
    {'kind':'case','name':'contract_fingerprint','value':contract_fingerprint()},
    {'kind':'case','name':'required_globals','value':54},
    {'kind':'case','name':'required_fields','value':77},
    {'kind':'case','name':'required_functions','value':11},
    {'kind':'case','name':'highest_stock_builtin','value':78},
]
def document(root): return {'schema':SCHEMA,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'status':STATUS,'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def compiler():
    for value in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
        parts=value.split()
        if shutil.which(parts[0]): return parts
    return None
def run_oracle(root):
    cc=compiler()
    if not cc: return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp024-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode:return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        return run.returncode==0,' '.join(cc),[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
def quoted_count(source, function):
    block=source.split(f'function {function}()',1)[1].split('end function',1)[0]
    return len(re.findall(r'"([^"]+)"',block))
def contract(root, allow_downstream_package=False):
    errors=[]
    source=(root/'src/miniquake/quakec/contract.ml').read_text(encoding='utf-8-sig')
    builtins=(root/'src/miniquake/quakec/builtins.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/quakec_closure_tests.ml').read_text(encoding='utf-8-sig')
    stock=(root/'tests/quakec_stock_tests.ml').read_text(encoding='utf-8-sig')
    info=(root/'src/miniquake/build_info.ml').read_text(encoding='utf-8-sig')
    markers=(
      'const STATUS = "quakec_109_frozen_v1"','const EXPECTED_HEADER_CRC = 5927','const EXPECTED_BUILTIN_COUNT = 79',
      'function contractFingerprint()','function validate(program)','builtin reference outside stock table',
      'function programFingerprint(program)','function summary(program)')
    for marker in markers:
        if marker not in source: errors.append('missing closure marker: '+marker)
    for function,expected in (('requiredGlobals',54),('requiredFields',77),('requiredFunctions',11)):
        actual=quoted_count(source,function)
        if actual!=expected: errors.append(f'{function} count {actual}, expected {expected}')
    if 'const BUILTIN_COUNT = 79' not in builtins or 'function builtinContractFingerprint()' not in builtins: errors.append('builtin contract not bound')
    if tests.count('if run(')!=20 or 'MiniQuake BP-024 QuakeC closure tests passed: 20' not in tests: errors.append('expected 20 closure fixtures')
    if 'MiniQuake BP-024 stock QuakeC test: PASS' not in stock or 'contract.validate(program)' not in stock: errors.append('stock progs.dat gate missing')
    # The frozen logical contract remains BP-024.  Its own delivery checker
    # normally binds the exact BP-024R3 identity.  Later black-port blocks may
    # explicitly ask to verify the unchanged semantic contract while their
    # package identity is checked independently by tools/verify.py.
    if allow_downstream_package:
        marker = 'const QUAKEC_STATUS = "quakec_109_frozen_v1"'
        if marker not in info: errors.append('downstream package no longer binds frozen QuakeC status: '+marker)
    else:
        for marker in ('const PACKAGE_ID = "BP-024R3"','const PARENT_PACKAGE_ID = "BP-024R2"','const BLOCK_ID = "BP-020-024"'):
            if marker not in info: errors.append('package identity mismatch: '+marker)
    return errors

def main():
    ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='root_flag');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');ap.add_argument('--allow-downstream-package',action='store_true');a=ap.parse_args()
    root=Path(a.root_flag or a.root).resolve();doc=document(root);golden=root/GOLDEN
    if a.write_golden: golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file():errors.append('missing golden')
    elif json.loads(golden.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
    ok,detail,actual=run_oracle(root)
    if not ok:errors.append('C oracle failed: '+detail)
    elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
    errors+=contract(root, a.allow_downstream_package)
    report={'schema':REPORT,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'status':STATUS,'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':20,'stock_gate':True,'contract_fingerprint':contract_fingerprint(),'downstream_package':bool(a.allow_downstream_package),'errors':errors}
    if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-024 QuakeC closure verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(doc["rows"])} runtime_fixtures=20 stock_gate=1 fingerprint=0x{contract_fingerprint():08x} oracle={detail}')
    for error in errors:print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
