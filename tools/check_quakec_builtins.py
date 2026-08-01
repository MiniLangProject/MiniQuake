#!/usr/bin/env python3
"""Verify BP-023 QuakeC builtin-table and formatting contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, re, shutil, struct, subprocess, tempfile
from pathlib import Path

PACKAGE_ID='BP-023'; PARENT_PACKAGE_ID='BP-022'
SCHEMA='MiniQuakeQuakeCBuiltinGolden/1'; REPORT='MiniQuakeBP023QuakeCBuiltinVerification/1'
GOLDEN='audit/quakec_builtin_golden.json'; ORACLE='tools/oracle/quakec_builtin_oracle.c'

def sha(path: Path) -> str: return hashlib.sha256(path.read_bytes()).hexdigest()
def f32(value: float) -> float: return struct.unpack('<f', struct.pack('<f', value))[0]
def fbits(value: float) -> int: return struct.unpack('<I', struct.pack('<f', f32(value)))[0]
def c_one(value: float) -> str:
    value=f32(value)
    if value == int(value): return str(int(value))
    return f'{value:5.1f}'

def rows():
    seed=(1*214013+2531011)&0xffffffff; rv=(seed>>16)&0x7fff
    return [
      {'kind':'case','name':'builtin_count','value':79},
      {'kind':'case','name':'fixme_slot_5','value':1},
      {'kind':'case','name':'fixme_slot_66','value':1},
      {'kind':'case','name':'ftos_integer','value':c_one(-12.0)},
      {'kind':'case','name':'ftos_positive_tie','value':c_one(1.25)},
      {'kind':'case','name':'ftos_negative_tie','value':c_one(-1.25)},
      {'kind':'case','name':'ftos_binary32_below_tie','value':c_one(2.35)},
      {'kind':'case','name':'ftos_negative_zero','value':c_one(-0.04)},
      {'kind':'case','name':'vtos','value':"'"+' '.join(f'{f32(v):5.1f}' for v in (1.25,-1.25,-0.04))+"'"},
      {'kind':'case','name':'msvc_rand_first','value':rv},
      {'kind':'case','name':'msvc_rand_float_bits','value':fbits(f32(rv)/f32(32767.0))},
      {'kind':'case','name':'changelevel_one_shot','value':1},
      {'kind':'case','name':'temporary_string_shared','value':1},
    ]

def document(root: Path):
    return {'schema':SCHEMA,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,
            'sources':['pr_cmds.c','progs.h'],'rows':rows(),
            'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}

def compiler():
    values=([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']
    for value in values:
        parts=value.split()
        if shutil.which(parts[0]): return parts
    return None

def run_oracle(root: Path):
    cc=compiler()
    if not cc: return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp023-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode: return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        actual=[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        return run.returncode==0,' '.join(cc),actual

def builtin_items(text: str):
    marker='table = [' if 'table = [' in text else 'machine.builtins = ['
    block=text.split(marker,1)[1].split(']',1)[0]
    return [item.strip() for item in block.split(',') if item.strip()]

def contract(root: Path):
    errors=[]
    source=(root/'src/miniquake/quakec/builtins.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/quakec_builtin_tests.ml').read_text(encoding='utf-8-sig')
    items=builtin_items(source)
    if len(items)!=79: errors.append(f'expected 79 stock builtins, got {len(items)}')
    for index in (0,5,33,39,42,50,60,61,62,63,64,65,66,71):
        if index>=len(items) or items[index] != 'fixme': errors.append(f'expected PF_Fixme at stock slot {index}')
    for marker in ('function roundHalfEvenPositive(value)','native.floatBits(value) & 0x80000000','function findBuiltin(machine)','rawString != 0','function changeLevelBuiltin(machine)','if ctx.changeLevel == ""','function returnTemporaryString(machine, text)','function builtinNames()','function builtinContractFingerprint()'):
        if marker not in source: errors.append('missing builtin marker: '+marker)
    if tests.count('if run(')!=22 or 'MiniQuake BP-023 QuakeC builtin tests passed: 22' not in tests:
        errors.append('expected 22 BP-023 fixtures')
    return errors

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('root',nargs='?',default='.'); ap.add_argument('--root',dest='root_flag'); ap.add_argument('--write-golden',action='store_true'); ap.add_argument('--json-output'); a=ap.parse_args()
    root=Path(a.root_flag or a.root).resolve(); doc=document(root); golden=root/GOLDEN
    if a.write_golden:
        golden.parent.mkdir(parents=True,exist_ok=True); golden.write_text(json.dumps(doc,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file(): errors.append('missing golden')
    elif json.loads(golden.read_text(encoding='utf-8-sig')) != doc: errors.append('golden differs from Python model')
    ok,detail,actual=run_oracle(root)
    if not ok: errors.append('C oracle failed: '+detail)
    elif actual and actual != doc['rows']: errors.append('C oracle differs from Python model')
    errors += contract(root)
    report={'schema':REPORT,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':22,'errors':errors}
    if a.json_output: Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-023 QuakeC builtin verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(doc["rows"])} runtime_fixtures=22 builtin_slots=79 oracle={detail}')
    for error in errors: print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
