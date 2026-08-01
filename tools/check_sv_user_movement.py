#!/usr/bin/env python3
from __future__ import annotations
import argparse,hashlib,json,math,os,shutil,subprocess,tempfile
from pathlib import Path
PACKAGE='BP-028';PARENT='BP-027';GOLDEN='audit/sv_user_movement_golden.json';ORACLE='tools/oracle/sv_user_movement_oracle.c'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rows():
 vals=[('pitch60_forward_x',50.0),('nonwalk_upmove',25.0),('walk_vertical',0.0),('teleport_backmove',0.0),('maxspeed',320.0),('air_cap',30.0),('idle_water_sink',-42.0),('forward_water',70.0),('ideal_pitch',-0.8),('read_angle_128',-180.0),('punch_x',2.7),('punch_y',3.6),('fixture_count',16.0)]
 return [{'kind':'case','name':n,'value':v} for n,v in vals]
def doc(root):return {'schema':'MiniQuakeSvUserMovementGolden/1','package_id':PACKAGE,'parent_package_id':PARENT,'sources':['sv_user.c','sv_phys.c'],'rows':rows(),'reference':{'oracle':ORACLE,'oracle_sha256':sha(root/ORACLE)}}
def cc():
 for x in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
  a=x.split()
  if shutil.which(a[0]):return a
 return None
def oracle(root):
 c=cc()
 if not c:return True,'not available',[]
 with tempfile.TemporaryDirectory(prefix='mq-bp028-') as td:
  e=Path(td)/('o.exe' if os.name=='nt' else 'o');b=subprocess.run(c+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-lm','-o',str(e)],capture_output=True,text=True)
  if b.returncode:return False,b.stdout+b.stderr,[]
  r=subprocess.run([str(e)],capture_output=True,text=True)
  return r.returncode==0,' '.join(c),[json.loads(z) for z in r.stdout.splitlines() if z.strip()]
def same(a,b):
 if len(a)!=len(b):return False
 for x,y in zip(a,b):
  if x['kind']!=y['kind'] or x['name']!=y['name'] or abs(float(x['value'])-float(y['value']))>1e-5:return False
 return True
def contract(root):
 e=[];s=(root/'src/miniquake/physics.ml').read_text(encoding='utf-8-sig');t=(root/'tests/sv_user_movement_parity_tests.ml').read_text(encoding='utf-8-sig')
 if 'movementAngles = math.copy(player.renderAngles)' not in s:e.append('full ent angles are not passed to AngleVectors')
 if 'movementAngles = t.Vec3(0.0, player.renderAngles.y, 0.0)' in s:e.append('yaw-only movement basis remains')
 if 'if player.moveType != c.MOVETYPE_WALK then wishVelocity.z = command.upMove else wishVelocity.z = 0.0 end if' not in s:e.append('walk/nonwalk vertical override differs from sv_user.c')
 if 'server.time < player.teleportTime and forwardMove < 0.0' not in s:e.append('teleporter backward gate missing')
 if t.count('if run(')!=16 or 'sv_user movement tests passed: ' not in t:e.append('expected 16 BP-028 fixtures')
 if 'near(value.viewAngles.y, -180.0, "move angle y signed char")' not in t:
  e.append('MSG_ReadAngle signed-char boundary fixture is missing')
 for m in ('noclip pitch projection','walk pitch projection','air acceleration cap','read client move'):
  if m not in t:e.append('missing fixture: '+m)
 return e
def main():
 a=argparse.ArgumentParser();a.add_argument('root',nargs='?',default='.');a.add_argument('--root',dest='rf');a.add_argument('--write-golden',action='store_true');a.add_argument('--json-output');x=a.parse_args();root=Path(x.rf or x.root).resolve();d=doc(root);g=root/GOLDEN
 if x.write_golden:g.parent.mkdir(parents=True,exist_ok=True);g.write_text(json.dumps(d,indent=2)+'\n')
 errors=[]
 if not g.exists():errors.append('missing golden')
 elif json.loads(g.read_text(encoding='utf-8-sig'))!=d:errors.append('golden differs from model')
 ok,detail,actual=oracle(root)
 if not ok:errors.append('C oracle failed: '+detail)
 elif actual and not same(actual,d['rows']):errors.append('C oracle differs from model')
 errors+=contract(root);r={'schema':'MiniQuakeBP028SvUserMovementVerification/1','package_id':PACKAGE,'parent_package_id':PARENT,'ok':not errors,'oracle':detail,'rows':len(d['rows']),'runtime_fixtures':16,'errors':errors}
 if x.json_output:Path(x.json_output).write_text(json.dumps(r,indent=2)+'\n')
 print('MiniQuake BP-028 sv_user movement verification: '+('PASS' if not errors else 'FAIL'));print(f'  rows={len(d["rows"])} runtime_fixtures=16 oracle={detail}')
 for z in errors:print('  ERROR: '+z)
 return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
