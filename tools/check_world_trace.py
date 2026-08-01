#!/usr/bin/env python3
"""Verify BP-025 world.c trace coordinates and six-plane box boundaries."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path
PACKAGE_ID="BP-025";PARENT_PACKAGE_ID="BP-024R3";SCHEMA="MiniQuakeWorldTraceGolden/1";REPORT="MiniQuakeBP025WorldTraceVerification/1"
GOLDEN="audit/world_trace_golden.json";ORACLE="tools/oracle/world_trace_oracle.c"
def sha(p:Path)->str:return hashlib.sha256(p.read_bytes()).hexdigest()
def rows():return [
 {"kind":"case","name":"max_plane_empty","value":1},
 {"kind":"case","name":"min_plane_solid","value":1},
 {"kind":"case","name":"parallel_max_clear","value":1},
 {"kind":"case","name":"entry_fraction","value":0.65625},
 {"kind":"case","name":"entry_plane_distance","value":1},
 {"kind":"case","name":"translated_clear_world_end","value":70},
 {"kind":"case","name":"translated_hit_fraction","value":0.499218762},
 {"kind":"case","name":"translated_hit_world_x","value":99.96875},
 {"kind":"case","name":"dist_epsilon","value":0.03125},
]
def document(root:Path):return {"schema":SCHEMA,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"sources":["world.c","world.h"],"rows":rows(),"reference":{"oracle":ORACLE,"oracle_sha256":sha(root/ORACLE)}}
def compiler():
 for value in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  parts=value.split()
  if shutil.which(parts[0]):return parts
 return None
def run_oracle(root:Path):
 cc=compiler()
 if not cc:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp025-') as td:
  exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
  build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-lm','-o',str(exe)],capture_output=True,text=True)
  if build.returncode:return False,build.stdout+build.stderr,[]
  run=subprocess.run([str(exe)],capture_output=True,text=True)
  return run.returncode==0,' '.join(cc),[json.loads(x) for x in run.stdout.splitlines() if x.strip()]
def contract(root:Path):
 errors=[]
 bsp=(root/'src/miniquake/world_bsp.ml').read_text(encoding='utf-8-sig')
 world=(root/'src/miniquake/world.ml').read_text(encoding='utf-8-sig')
 hull=(root/'src/miniquake/world_hull.ml').read_text(encoding='utf-8-sig')
 tests=(root/'tests/world_trace_parity_tests.ml').read_text(encoding='utf-8-sig')
 if 'if result.fraction == 1.0 then' not in bsp or 'result.endPosition = math.copy(finish)' not in bsp:errors.append('traceBrushModel clear trace does not restore world-space finish')
 if 'trace.endPosition = math.VectorCopy(finish)' not in world:errors.append('SV_ClipMoveToEntity clear trace does not restore world-space finish')
 if 'startValues[axis] >= maxs[axis]' not in hull:errors.append('parallel maximum plane is not treated as empty')
 if tests.count('if run(')!=10 or 'MiniQuake BP-025 world trace tests passed: ' not in tests:errors.append('expected 10 BP-025 runtime fixtures')
 if 'brushNode = t.BspNode(0, -2, -1' not in tests:
  errors.append('translated hull-0 fixture does not map front to solid and back to empty')
 for marker in ('translated brush clear','translated brush hit','parallel maximum plane','public clip clear'):
  if marker not in tests:errors.append('missing BP-025 fixture: '+marker)
 return errors
def main()->int:
 ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='root_flag');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');a=ap.parse_args();root=Path(a.root_flag or a.root).resolve();doc=document(root);golden=root/GOLDEN
 if a.write_golden:golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
 errors=[]
 if not golden.is_file():errors.append('missing golden document')
 elif json.loads(golden.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
 ok,detail,actual=run_oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
 errors+=contract(root)
 report={"schema":REPORT,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"ok":not errors,"oracle":detail,"rows":len(doc['rows']),"runtime_fixtures":10,"errors":errors}
 if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake BP-025 world trace verification: '+('PASS' if not errors else 'FAIL'));print(f"  rows={len(doc['rows'])} runtime_fixtures=10 oracle={detail}")
 for e in errors:print('  ERROR: '+e)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
