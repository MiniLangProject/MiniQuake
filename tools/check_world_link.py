#!/usr/bin/env python3
from __future__ import annotations
import argparse,hashlib,json,os,shutil,subprocess,tempfile
from pathlib import Path
PACKAGE='BP-026';PARENT='BP-025';GOLDEN='audit/world_link_golden.json';ORACLE='tools/oracle/world_link_oracle.c'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rows():
 vals=[('normal_min_x',8),('normal_min_y',17),('normal_min_z',26),('normal_max_x',15),('normal_max_y',26),('normal_max_z',37),('item_min_x',-6),('item_min_y',3),('item_min_z',27),('item_max_x',29),('item_max_y',40),('item_max_z',36),('inclusive_overlap',1),('separated_overlap',0),('fixture_count',15)]
 return [{'kind':'case','name':n,'value':v} for n,v in vals]
def doc(root):return {'schema':'MiniQuakeWorldLinkGolden/1','package_id':PACKAGE,'parent_package_id':PARENT,'sources':['world.c','world.h'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def cc():
 for x in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  a=x.split()
  if shutil.which(a[0]):return a
 return None
def run_oracle(root):
 c=cc()
 if not c:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp026-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(c+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True);return r.returncode==0,' '.join(c),[json.loads(x) for x in r.stdout.splitlines() if x.strip()]
def contract(root):
 e=[];s=(root/'src/miniquake/server_collision.ml').read_text(encoding='utf-8-sig');w=(root/'src/miniquake/world.ml').read_text(encoding='utf-8-sig');t=(root/'tests/world_link_collision_tests.ml').read_text(encoding='utf-8-sig')
 for m in ('function computedEntityBounds(server, entityIndex)','function updateEntityBounds(server, entityIndex)','function linkEntity(server, entityIndex, touchTriggerLinks)','if trace.startSolid then return 0 end if','linkEntity(server, entityIndex, true)'):
  if m not in s:e.append('missing collision marker: '+m)
 if 'best.entity = 0 else best.entity = -1' not in s or 'trace.entity = 0 else trace.entity = -1' not in w:e.append('clear traces still identify the world')
 if t.count('if run(')!=16 or 'world link/collision tests passed: 16' not in t:e.append('expected 16 BP-026 fixtures')
 return e
def main():
 a=argparse.ArgumentParser();a.add_argument('root',nargs='?',default='.');a.add_argument('--root',dest='rf');a.add_argument('--write-golden',action='store_true');a.add_argument('--json-output');x=a.parse_args();root=Path(x.rf or x.root).resolve();d=doc(root);g=root/GOLDEN
 if x.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(d,indent=2)+'\n')
 errors=[]
 if not g.exists():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=d:errors.append('golden differs from model')
 ok,detail,actual=run_oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and actual!=d['rows']:errors.append('C oracle differs from model')
 errors+=contract(root);report={'schema':'MiniQuakeBP026WorldLinkVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':16,'errors':errors}
 if x.json_output:Path(x.json_output).write_text(json.dumps(report,indent=2)+'\n')
 print('MiniQuake BP-026 world link/collision verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures=16 oracle={detail}')
 for z in errors:print('  ERROR: '+z)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
