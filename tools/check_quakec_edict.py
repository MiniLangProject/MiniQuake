#!/usr/bin/env python3
"""Verify BP-022 ED_* allocation, parsing and serialization contracts."""
from __future__ import annotations
import argparse,hashlib,json,os,shutil,subprocess,tempfile
from pathlib import Path
PACKAGE_ID='BP-022';PARENT_PACKAGE_ID='BP-021';SCHEMA='MiniQuakeQuakeCEdictGolden/1';REPORT='MiniQuakeBP022QuakeCEdictVerification/1';GOLDEN='audit/quakec_edict_golden.json';ORACLE='tools/oracle/quakec_edict_oracle.c'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rows():return [
 {'kind':'case','name':'type_size_void','value':1},{'kind':'case','name':'type_size_vector','value':3},{'kind':'case','name':'type_size_pointer','value':1},
 {'kind':'case','name':'reuse_early_free_time','value':1},{'kind':'case','name':'reuse_recent_old_slot','value':1},{'kind':'case','name':'reuse_exact_half_second','value':0},
 {'kind':'case','name':'angle_hack_pitch','value':0},{'kind':'case','name':'angle_hack_yaw','value':90},{'kind':'case','name':'light_alias','value':1},
 {'kind':'case','name':'unknown_key_continues','value':1},{'kind':'case','name':'save_global_type_count','value':3},{'kind':'text','name':'negative_zero_fixed','value':'-0.000000'}]
def document(root):return {'schema':SCHEMA,'package_id':PACKAGE_ID,'parent_package_id':PARENT_PACKAGE_ID,'sources':['pr_edict.c','progs.h','world.c'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def compiler():
 for v in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  p=v.split()
  if shutil.which(p[0]):return p
 return None
def run_oracle(root):
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp022-') as td:
  exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle');b=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(exe)],capture_output=True,text=True);return r.returncode==0,' '.join(cc),[json.loads(x) for x in r.stdout.splitlines() if x.strip()]
def contract(root, allow_downstream_package=False):
 errors=[]
 e=(root/'src/miniquake/quakec/edict.ml').read_text(encoding='utf-8-sig')
 b=(root/'src/miniquake/format/bsp.ml').read_text(encoding='utf-8-sig')
 s=(root/'src/miniquake/savegame.ml').read_text(encoding='utf-8-sig')
 t=(root/'tests/quakec_edict_tests.ml').read_text(encoding='utf-8-sig')
 n=(root/'src/miniquake/native.ml').read_text(encoding='utf-8-sig')
 common=(root/'src/miniquake/common.ml').read_text(encoding='utf-8-sig')
 tc=(root/'native/miniquake_text.c').read_text(encoding='utf-8-sig')
 td=(root/'native/miniquake_text.def').read_text(encoding='utf-8-sig')
 for m in (
  'if valueType == c.EV_VOID then return 1 end if',
  'function diagnostic(machine, text)',
  "is not a field",
  "is not a global",
  'function fixedSixDecimalsWord(rawWord)',
  'function voidValueString()',
  'return protocolText.decodeBytes(bytes([118, 111, 105, 100]))',
  'function voidValueString()',
  'return protocolText.decodeBytes(bytes([118, 111, 105, 100]))',
  'function appendQuotedPair(prefix, name, value)',
  'if typeof(prefix) != "string" then return error(2610, "QuakeC serialization received a non-string prefix") end if',
  'if typeof(name) != "string" then return error(2611, "QuakeC serialization received a non-string field name") end if',
  'if typeof(value) != "string" then return error(2615, "QuakeC serialization received a non-string field value") end if',
  'function serializeDefinitions(machine, words, definitions, firstIndex, globalsOnly)',
  'function definitionSerializedLength(machine, words, definition)',
  'if globalsOnly then return true end if',
  'function writeDefinitionBytes(machine, words, definition, output, cursor)',
  'output = bytes(total, 0)',
  'nameData = try(protocolText.encodeBytes(definition.name))',
  'valueData = try(protocolText.encodeBytes(serialized))',
  'copyBytes(output, cursor, nameData, 0, len(nameData))',
  'copyBytes(output, cursor, valueData, 0, len(valueData))',
  'decoded = try(protocolText.decodeBytes(output))',
  'return serializeDefinitions(machine, machine.edicts[entityIndex], machine.program.fieldDefs, 1, false)',
  'return serializeDefinitions(machine, machine.globals, machine.program.globalDefs, 0, true)',
  'source = protocolText.encodeBytes(text)',
  r'return "Bad edict number\n"',
 ):
  if m not in e+s:errors.append('missing edict marker: '+m)
 if allow_downstream_package:
  downstream_markers = (
   (e, 'return native.f32ToFixed6(rawWord & 0xffffffff)'),
   (common, 'function cAtof(text)'),
   (common, 'return native.bitsFloat(native.f32FromText(text))'),
   (e, 'vm.setGlobalFloat(machine, definition.offset, common.cAtof(value))'),
   (e, 'vm.setEntityFloat(machine, entityIndex, definition.offset, common.cAtof(actualValue))'),
   (b, 'values[valueCount] = common.cAtof(decode(slice(source, start, i - start)))'),
   (s, 'return [common.cAtof(line[0]), line[1]]'),
   (n, 'extern function f32ToFixed6Raw(bits as u32, output as bytes, capacity as u32)'),
   (n, 'symbol "mqt_f32_to_fixed6"'),
   (n, 'function f32ToFixed6(bits)'),
   (tc, 'mqt_f32_to_fixed6'),
   (tc, 'mq_crt_proc("sprintf")'),
   (tc, '"%.6f"'),
   (td, 'mqt_f32_to_fixed6'),
  )
  for source, marker in downstream_markers:
   if marker not in source: errors.append('missing downstream fixed-six marker: '+marker)
  if 'scaled = native.trunc(magnitude * 1000000.0 + 0.5)' in e:
   errors.append('legacy overflow-prone fixed-six formatter remains in edict.ml')
 else:
  for marker in (
   'negative = (rawWord & 0x80000000) != 0',
   'value = native.bitsFloat(rawWord)',
   'magnitude = value',
  ):
   if marker not in e: errors.append('missing historical fixed-six marker: '+marker)
 for m in ('source = protocolText.encodeBytes(text)','protocolText.decodeBytes(output)','return protocolText.decodeBytes(slice(data, lump.offset, lump.length))'):
  if m not in b:errors.append('missing BSP byte-text marker: '+m)
 if 'native.bitsFloat(0x80000000)' not in t or 'negative zero raw formatter' not in t:errors.append('negative-zero fixture is not constructed from its raw QuakeC word')
 if allow_downstream_package:
  for marker in ('C atof negative zero word','global epair negative zero','edict epair negative zero','vector x negative zero','vector z negative zero'):
   if marker not in t: errors.append('signed-zero parse fixture missing: '+marker)
 if 'float value string' not in t or 'vector value string' not in t or 'void value string' not in t:errors.append('ED_Write value-string isolation fixtures are missing')
 if 'void value rejected before concatenation' not in t:errors.append('typed append rejection fixture is missing')
 if 'quoted pair cumulative append' not in t:errors.append('cumulative quoted-pair regression fixture is missing')
 if 'ED_Write returned " + typeof(actual)' not in t or 'savegame ED_Write returned " + typeof(saved)' not in t:errors.append('ED_Write result type boundaries are missing')
 if 'ED_Write exact Quake bytes' not in t or 'savegame ED_Write exact Quake bytes' not in t or 'bytes([0xe9])' not in t:errors.append('ED_Write Quake-byte fixture is missing')
 if 'ED_WriteGlobals preserves zero saveglobals' not in t or 'savegame preserves zero saveglobals' not in t:errors.append('zero-valued DEF_SAVEGLOBAL regression fixture is missing')
 if 'zeroExpected = zeroExpected +' not in t or r'\"globalstr\" \"\"' not in t or r'\"globalent\" \"0\"' not in t:errors.append('zero saveglobal exact-output fixture is incomplete')
 if 'function appendEdictDefinition(' in e:errors.append('ED_Write still uses the growing-string definition helper')
 if 'return appendQuotedPair(text, definition.name, serialized)' in e:errors.append('ED_Write still appends to a growing string')
 if 'qcedict.appendQuotedPair(text, definition.name, serialized)' in s:errors.append('savegame writer still duplicates the growing-string serializer')
 if 'return qcedict.serializeDefinitions(machine, words, definitions, firstIndex, globalsOnly)' not in s:errors.append('savegame writer does not delegate to the shared byte serializer')
 if t.count('if run(')!=22 or 'MiniQuake BP-022 QuakeC edict tests passed: 22' not in t:errors.append('expected 22 BP-022 fixtures')
 return errors

def main():
 ap=argparse.ArgumentParser()
 ap.add_argument('root',nargs='?',default='.')
 ap.add_argument('--root',dest='root_flag')
 ap.add_argument('--write-golden',action='store_true')
 ap.add_argument('--json-output')
 ap.add_argument('--allow-downstream-package',action='store_true')
 a=ap.parse_args()
 root=Path(a.root_flag or a.root).resolve();doc=document(root);g=root/GOLDEN
 if a.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
 errors=[]
 if not g.is_file():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
 ok,detail,actual=run_oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
 errors+=contract(root,a.allow_downstream_package)
 formatter='native_msvcrt_percent_f' if a.allow_downstream_package else 'historical_raw_word_formatter'
 report={
  'schema':REPORT,
  'package_id':PACKAGE_ID,
  'parent_package_id':PARENT_PACKAGE_ID,
  'downstream_package':a.allow_downstream_package,
  'fixed_six_formatter':formatter,
  'float_parser':'native_strtod_f32' if a.allow_downstream_package else 'historical_toNumber_or_atof',
  'preserves_signed_zero':a.allow_downstream_package,
  'ok':not errors,
  'oracle':detail,
  'rows':len(doc['rows']),
  'runtime_fixtures':22,
  'errors':errors,
 }
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-022 QuakeC edict verification: '+('PASS' if not errors else 'FAIL'))
 print(f'  rows={len(doc["rows"])} runtime_fixtures=22 oracle={detail}')
 print(f'  downstream_package={str(a.allow_downstream_package).lower()} fixed_six_formatter={formatter} float_parser={report["float_parser"]}')
 for e in errors:print('  ERROR: '+e)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
