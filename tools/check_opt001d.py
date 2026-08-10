from __future__ import annotations
import argparse,json,re,sys
from pathlib import Path

def main():
 p=argparse.ArgumentParser(); p.add_argument('--root',default='.'); p.add_argument('--json'); a=p.parse_args(); root=Path(a.root).resolve(); errors=[]
 audit_path=root/'audit'/'opt001d_60fps_renderer_audio.json'
 if not audit_path.exists(): errors.append('missing OPT-001D audit')
 else:
  d=json.loads(audit_path.read_text(encoding='utf-8'))
  if d.get('revision')!='OPT-001D': errors.append('wrong revision')
  if d.get('goal',{}).get('minimum_render_fps')!=60: errors.append('60 FPS target not bound')
  if d.get('transformations',{}).get('inline_functions_added',0)<3: errors.append('insufficient safe inline candidates')
 src='\n'.join(x.read_text(encoding='utf-8') for x in (root/'src').rglob('*.ml'))
 if 'GLQuake' in src: errors.append('production source still contains GLQuake title')
 if not (root/'TEST_OPT-001D.ps1').exists(): errors.append('missing test runner')
 if 'Test-OPT001D60FpsGate' not in (root/'TEST_OPT-001D.ps1').read_text(encoding='utf-8'): errors.append('missing 60 FPS runtime gate')
 result={'schema':'MiniQuakeOPT001DCheck/1','status':'PASS' if not errors else 'FAIL','errors':errors}
 if a.json: Path(a.json).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print('MiniQuake OPT-001D verification: '+result['status'])
 for e in errors: print('ERROR: '+e)
 return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
