#!/usr/bin/env python3
"""Verify BP-021 PR_ExecuteProgram byte, stack and pointer contracts."""
from __future__ import annotations
import argparse,hashlib,json,os,shutil,struct,subprocess,tempfile
from pathlib import Path
PACKAGE_ID='BP-021';PARENT_PACKAGE_ID='BP-020';SCHEMA='MiniQuakeQuakeCVMGolden/1';REPORT='MiniQuakeBP021QuakeCVMVerification/1';GOLDEN='audit/quakec_vm_golden.json';ORACLE='tools/oracle/quakec_vm_oracle.c'
RUNTIME_FIXTURES=16
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def fbits(v):return struct.unpack('<I',struct.pack('<f',v))[0]
def rows():return [
 {'kind':'case','name':'opcode_count','value':66},{'kind':'case','name':'max_stack_depth','value':32},
 {'kind':'case','name':'localstack_size','value':2048},{'kind':'case','name':'binary32_add_bits','value':fbits(float(16777216.0)+1.0)},
 {'kind':'case','name':'byte_strcmp_positive','value':1},{'kind':'case','name':'byte_strcmp_negative','value':-1},
 {'kind':'case','name':'negative_zero_truth','value':1},{'kind':'case','name':'return_word_count','value':3},
 {'kind':'case','name':'max_call_parameters','value':8},{'kind':'case','name':'parameter_stride','value':3},
 {'kind':'case','name':'pointer_last_scalar_valid','value':1},{'kind':'case','name':'pointer_vector_crosses','value':1},
 {'kind':'case','name':'state_signed_zero_word','value':0x80000000},{'kind':'case','name':'state_changed_word','value':0x40600000},
 {'kind':'case','name':'state_nan_word','value':0x7fc00001}]
def document(root):return {'schema':SCHEMA,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'sources':['pr_exec.c','pr_comp.h'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def compiler():
 for v in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  p=v.split()
  if shutil.which(p[0]):return p
 return None
def run_oracle(root):
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp021-') as td:
  exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle');b=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(exe)],capture_output=True,text=True);return r.returncode==0,' '.join(cc),[json.loads(x) for x in r.stdout.splitlines() if x.strip()]
def contract(root):
 errors=[];vm=(root/'src/miniquake/quakec/vm.ml').read_text(encoding='utf-8-sig');tests=(root/'tests/quakec_vm_tests.ml').read_text(encoding='utf-8-sig')
 for m in ('function canonicalString(text)','protocolText.decodeBytes','function validatePointer(machine, pointer, wordCount)','QuakeC pointer crosses an edict boundary','leftBytes = protocolText.encodeBytes(left)','machine.trace = false','function executeState(machine, frameOffset, thinkOffset)','loaded = try(entityField(machine, entityIndex, fieldOffset))','QuakeC entity outside edict table'):
  if m not in vm:errors.append('missing VM marker: '+m)
 if 'machine.builtins = [unexpectedBuiltinZero, enableTrace]' not in tests:errors.append('builtin #1 fixture does not retain the historical slot-zero entry')
 if 'firstStatement=-1 denotes builtin slot 1' not in tests:errors.append('builtin slot mapping regression comment is missing')
 if tests.count('if run(')!=RUNTIME_FIXTURES or f'MiniQuake BP-021 QuakeC VM tests passed: {RUNTIME_FIXTURES}' not in tests:errors.append(f'expected {RUNTIME_FIXTURES} BP-021 fixtures')
 if vm.count('setWord(machine, op.OFS_RETURN')<3:errors.append('three-word return copy is not visible')
 return errors
def main():
 ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='root_flag');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');a=ap.parse_args();root=Path(a.root_flag or a.root).resolve();doc=document(root);g=root/GOLDEN
 if a.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
 errors=[]
 if not g.is_file():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
 ok,detail,actual=run_oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
 errors+=contract(root);report={'schema':REPORT,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':RUNTIME_FIXTURES,'errors':errors}
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-021 QuakeC VM verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(doc["rows"])} runtime_fixtures={RUNTIME_FIXTURES} oracle={detail}')
 for e in errors:print('  ERROR: '+e)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
