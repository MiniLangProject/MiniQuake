#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from pathlib import Path

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default=''); args=ap.parse_args()
    root=Path(args.root).resolve(); errors=[]
    def read(rel): return (root/rel).read_text(encoding='utf-8')
    arrayutil=read('src/miniquake/array_util.ml'); client=read('src/miniquake/client.ml'); particles=read('src/miniquake/particles.ml')
    diag=read('src/miniquake/compat_diagnostics.ml'); host=read('src/miniquake/host.ml')
    required_inline={'src/miniquake/mathlib.ml':['DotProduct'], 'src/miniquake/protocol15_freeze.ml':['fingerprintValue'], 'src/miniquake/statusbar.ml':['Sbar_ColorForMap']}
    found=[]
    for rel,names in required_inline.items():
        source=read(rel)
        for name in names:
            if not re.search(rf'(?m)^function inline {re.escape(name)}\s*\(',source): errors.append(rel+' missing inline '+name)
            else: found.append([rel,name])
    actual=[]
    for p in sorted((root/'src').rglob('*.ml')):
        source=p.read_text(encoding='utf-8')
        for m in re.finditer(r'(?m)^function inline\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(',source): actual.append([p.relative_to(root).as_posix(),m.group(1)])
    missing_required = [item for item in found if item not in actual]
    if missing_required: errors.append('required inline subset missing: '+repr(missing_required))
    for marker,label in [('return array(count, value)','exact array allocation'),('createArrayBuilder','array builder'),('finishArrayBuilder','array builder finish')]:
        if marker not in arrayutil: errors.append(label+' marker missing')
    relink=re.search(r'(?ms)^function CL_RelinkEntities\b.*?^end function$',client)
    if not relink or 'createArrayBuilder' not in relink.group(0) or 'visibleEntities = visibleEntities + [' in relink.group(0): errors.append('visible entity builder contract missing')
    draw=re.search(r'(?ms)^function R_DrawParticles\b.*?^end function$',particles)
    if not draw or 'commandBuffer = array(' not in draw.group(0) or 'aliveBuffer = array(' not in draw.group(0): errors.append('particle preallocation missing')
    if 'if session.diagnosticContextPath != "" then' not in diag or 'session.frameTrace = session.frameTrace + [stage]' not in diag: errors.append('diagnostic trace guard missing')
    if 'if session.diagnosticContextPath != "" then session.frameTrace = [] end if' not in host: errors.append('host frameTrace guard missing')
    report={'schema':'MiniQuakeOPT001CR3Static/1','status':'PASS' if not errors else 'FAIL','errors':errors,'inline_functions':len(actual),'inline_set':actual,'required_inline_subset':found}
    if args.json: Path(args.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake OPT-001CR3 inline/array hotpath verification: '+report['status'])
    print('  inline_functions='+str(len(actual)))
    for e in errors: print('  error: '+e)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
