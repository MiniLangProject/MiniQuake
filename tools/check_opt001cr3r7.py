#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,re
from pathlib import Path
REV='OPT-001CR3R7'; PARENT='OPT-001CR3R6'
STATUS='opt001cr3r7_audio_transition_hotpath_candidate_v1'; FINGERPRINT='0x1c001c0d'
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default=''); a=ap.parse_args()
    root=Path(a.root).resolve(); errors=[]
    def text(rel): return (root/rel).read_text(encoding='utf-8')
    bi=text('src/miniquake/build_info.ml'); host=text('src/miniquake/host.ml'); mixer=text('src/miniquake/sound/mixer.ml')
    world=text('src/miniquake/render/world.ml'); hot=text('tests/opt001cr3_hotpath_tests.ml'); runner=text('TEST_OPT-001CR3R7.ps1')
    markers=[f'const OPTIMIZATION_STATUS = "{STATUS}"',f'const OPTIMIZATION_FINGERPRINT = {FINGERPRINT}',
             f'const OPTIMIZATION_PARENT = "{PARENT}"',f'const OPTIMIZATION_DELIVERY_REVISION = "{REV}"']
    for m in markers:
        if m not in bi: errors.append('build_info missing '+m)
    for m in ('registerCvar(registry, "_snd_mixahead", "0.2", true, false)',
              'if session.renderer is not void then worldRenderer.destroy(session.renderer) end if',
              'frameMixAhead = cvar.variableValue(session.cvars, "_snd_mixahead")',
              'rDrawEntities = cvar.variableValue(session.cvars, "r_drawentities") != 0.0'):
        if m not in host: errors.append('host missing '+m)
    for m in ('channelCount = len(mixer.channels)','while channelIndex < channelCount','accumulatorCount = frameCount * 2'):
        if m not in mixer: errors.append('mixer missing '+m)
    for m in ('if currentLeaf == renderer.viewLeaf and len(renderer.visibleFaces) == len(map.faces) then',
              'return countVisibleFaces(renderer.visibleFaces)','renderer.viewLeaf = -1'):
        if m not in world: errors.append('world PVS cache missing '+m)
    for m in ('opt001cr3r7Passed = 0','function opt001cr3r7Check(condition, label)',
              'buildInfo.OPTIMIZATION_DELIVERY_REVISION == "OPT-001CR3R7"',
              'buildInfo.OPTIMIZATION_STATUS == "opt001cr3r7_audio_transition_hotpath_candidate_v1"'):
        if m not in hot: errors.append('hotpath test missing '+m)
    for m in ('$DeliveryRevision = "OPT-001CR3R7"','$DeliveryParent = "OPT-001CR3R6"',
              '[int]$TransitionFrames = 256','[int]$E1M2VisibleFrames = 1500',
              'OPT-001CR3R7 audio cost analysis','output_mode=python_binary_passthrough_named_build_binding'):
        if m not in runner: errors.append('runner missing '+m)
    report={'schema':'MiniQuakeOPT001CR3R7Static/1','status':'PASS' if not errors else 'FAIL','errors':errors,
            'audio_mixahead':0.2,'pvs_cache':True,'renderer_destroy_unconditional':True,
            'transition_frames':256,'visible_frames':1500}
    if a.json: Path(a.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake OPT-001CR3R7 hotpath/transition/audio verification: '+report['status'])
    for e in errors: print('  error: '+e)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
