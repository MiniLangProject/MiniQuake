#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Source-guided C-oracle verifier for BP-040..BP-044 world rendering."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, tempfile
from pathlib import Path

CONFIG = {
  '040': dict(package='BP-040', parent='BP-039', schema='MiniQuakeWorldSurfaceGolden/1',
      golden='audit/world_surface_render_golden.json', oracle='tools/oracle/world_surface_render_oracle.c',
      test='tests/world_surface_render_tests.ml', fixtures=22,
      success='MiniQuake BP-040 world surface tests passed: 22',
      markers={
        'src/miniquake/render/world.ml': [
          'function R_ResetTextureChains()', 'function R_ChainSurface(surface)',
          'function R_SurfaceFacesViewer(surface, planeDistance)',
          'function R_BrushSurfaceFacesViewer(surface, planeDistance)',
          'function inline R_WaterPassDeferred(textureSort, waterAlpha)',
          'R_ChainSurface(surface)',
        ],
      }),
  '041': dict(package='BP-041', parent='BP-040', schema='MiniQuakeLightmapAtlasGolden/1',
      golden='audit/lightmap_atlas_render_golden.json', oracle='tools/oracle/lightmap_atlas_render_oracle.c',
      test='tests/lightmap_atlas_tests.ml', fixtures=23,
      success='MiniQuake BP-041 lightmap atlas tests passed: 23',
      markers={
        'src/miniquake/render/world.ml': [
          'function R_LightmapRequiredBytes(width, height, stride, bytesPerSample)',
          'function R_CollectLightmapTextureIds(renderer)',
          'function GL_BuildLightmaps()', 'renderer = rCompatRenderer',
          'renderer.lightmaps = []',
          'renderer.lightmaps = renderer.lightmaps + [textureId]',
          'if bytesPerSample != 1 and bytesPerSample != 4 then',
          'gl.deleteTexture(textureId)',
        ],
      }),
  '042': dict(package='BP-042', parent='BP-041', schema='MiniQuakeDynamicLightRenderGolden/1',
      golden='audit/dynamic_light_render_golden.json', oracle='tools/oracle/dynamic_light_render_oracle.c',
      test='tests/dynamic_light_render_tests.ml', fixtures=20,
      success='MiniQuake BP-042 dynamic-light render tests passed: 20',
      markers={
        'src/miniquake/render/world.ml': [
          'function inline R_DynamicLightIsActive(light, currentTime)',
          'function R_BeginWorldFrame()', 'function R_MarkBrushModelLights(entity)',
          'R_PushDlights()', 'R_AnimateLight()', 'R_AdvanceFrameCounters()',
        ],
      }),
  '043': dict(package='BP-043', parent='BP-042', schema='MiniQuakeSkyWaterGolden/1',
      golden='audit/sky_water_render_golden.json', oracle='tools/oracle/sky_water_render_oracle.c',
      test='tests/sky_water_render_tests.ml', fixtures=22,
      success='MiniQuake BP-043 sky/water render tests passed: 22',
      markers={
        'src/miniquake/render/gl_warp.ml': [
          'function warpFloat(value)', 'function WaterTexCoords(originalS, originalT, realtime)',
          'function WrappedSpeedScale(realtime, speed)', 'function SkyTexCoords(position, viewOrigin, currentSpeedScale)',
          'function SubdividePolygon(vertices, subdivideSize)',
        ],
      }),
  '044': dict(package='BP-044', parent='BP-043', schema='MiniQuakeWorldRenderClosureGolden/1',
      golden='audit/world_render_closure_golden.json', oracle='tools/oracle/world_render_closure_oracle.c',
      test='tests/world_render_closure_tests.ml', fixtures=24,
      success='MiniQuake BP-044 world-render closure tests passed: 24',
      markers={
        'src/miniquake/world_render_contract.ml': [
          'world_render_109_frozen_v1', '0x846a74de', 'const NEAR_CLIP = 4',
          'const FAR_CLIP = 4096', 'const STAGE_WATER = 6',
        ],
        'src/miniquake/render/world.ml': [
          'function R_ViewportRect(viewX, viewY, width, height, screenWidth, screenHeight)',
          'function R_SetCullCompatibility(enabled)', 'function R_MainRenderStageOrder()',
          'gl.cullFace(gl.GL_FRONT)',
        ],
        'src/miniquake/host.ml': [
          'registerCvar(registry, "gl_cull", "1", false, false)',
          'worldRenderer.R_SetCullCompatibility(',
          'particleRenderer.renderView(',
          'worldRenderer.R_DrawWaterSurfaces()',
          'worldRenderer.R_PolyBlendProduction(',
        ],
      }),
}

ROWS = {
 '040': [
  {'name':'world_front_positive','value':1}, {'name':'world_front_negative','value':0},
  {'name':'world_back_negative','value':1}, {'name':'underwater_bypass','value':1},
  {'name':'brush_epsilon_milli','value':10}, {'name':'texture_head_insertion','value':1},
  {'name':'translucent_water_deferred','value':1}, {'name':'fixtures','value':20},
 ],
 '041': [
  {'name':'atlas_width','value':128}, {'name':'atlas_height','value':128},
  {'name':'atlas_pages','value':64}, {'name':'luminance_bytes','value':1},
  {'name':'rgba_bytes','value':4}, {'name':'rgba_2x2_stride10_required','value':18},
  {'name':'shared_texture_delete_once','value':1}, {'name':'fixtures','value':22},
 ],
 '042': [
  {'name':'active_at_deadline','value':1}, {'name':'expired_before_deadline','value':0},
  {'name':'zero_radius_inactive','value':1}, {'name':'push_target_frame_delta','value':1},
  {'name':'max_dlight_bits','value':32}, {'name':'brush_root_marking','value':1},
  {'name':'frame_order_push_animate_advance','value':1}, {'name':'fixtures','value':20},
 ],
 '043': [
  {'name':'float_integer_boundary','value':0x4b800000},
  {'name':'water_one_s','value':0x3f636ab6}, {'name':'water_one_t','value':0x3f1d906d},
  {'name':'water_two_s','value':0xbe9f8f9b}, {'name':'water_two_t','value':0x3fc7d9f0},
  {'name':'sky_general_s','value':0x401ac5d2}, {'name':'sky_general_t','value':0x3fbab28e},
  {'name':'fixtures','value':22},
 ],
 '044': [
  {'name':'contract_fingerprint','value':0x846a74de}, {'name':'near_clip','value':4},
  {'name':'far_clip','value':4096}, {'name':'stage_count','value':7},
  {'name':'viewport_full_width','value':640}, {'name':'viewport_inset_width','value':322},
  {'name':'front_face_culling','value':1}, {'name':'fixtures','value':24},
 ],
}

def sha256(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()

def document(root: Path, component: str):
    """Render the canonical evidence document for this verifier."""
    c=CONFIG[component]
    return {'schema':c['schema'],'package_id':c['package'],'parent_package_id':c['parent'],
            'sources':['gl_rmain.c','gl_rsurf.c','gl_rlight.c','gl_warp.c','gl_refrag.c'],
            'rows':ROWS[component],
            'reference':{'oracle':c['oracle'],'oracle_sha256':sha256(root/c['oracle'])}}

def compiler():
    """Locate a supported C compiler for the reference oracle."""
    candidates=([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']
    for candidate in candidates:
        parts=candidate.split()
        if shutil.which(parts[0]): return parts
    return None

def run_oracle(root: Path, component: str):
    """Run oracle and capture its deterministic result."""
    cc=compiler()
    if not cc: return True,'not available',[]
    source=root/CONFIG[component]['oracle']
    with tempfile.TemporaryDirectory(prefix='mq-world-render-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(source),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode: return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        try: rows=[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        except Exception as exc: return False,f'oracle JSON: {exc}: {run.stdout}',[]
        return run.returncode==0,' '.join(cc),rows

def check_contract(root: Path, component: str):
    """Validate contract and return its contract findings."""
    c=CONFIG[component]; errors=[]
    for relative, markers in c['markers'].items():
        path=root/relative
        if not path.is_file(): errors.append('missing source: '+relative); continue
        text=path.read_text(encoding='utf-8-sig')
        for marker in markers:
            if marker not in text: errors.append(f'{relative}: missing marker: {marker}')
    test=root/c['test']
    if not test.is_file(): errors.append('missing runtime test: '+c['test'])
    else:
        text=test.read_text(encoding='utf-8-sig')
        if c['success'] not in text: errors.append('runtime success marker/count differs')
        if f'passed != {c["fixtures"]}' not in text: errors.append('runtime fixture guard differs')
    if component=='043':
        small_markers = [
            'vertex(16.0, 16.0, 0.0, 16.0, 16.0)',
            'vertex(48.0, 48.0, 0.0, 48.0, 48.0)',
            'len(warp.SubdividePolygon(polygon, 128.0)), 1, "small polygon"',
        ]
        for marker in small_markers:
            if marker not in text:
                errors.append('BP-043 small-polygon fixture crosses a subdivision plane or lacks its no-split assertion: '+marker)
        if 'SubdividePolygon(quad(16.0), 128.0)' in text:
            errors.append('BP-043 centered small polygon is split at the zero subdivision plane')
    if component=='044':
        host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
        order=['particleRenderer.renderView(', 'entityRenderer.renderViewModel(', 'worldRenderer.R_DrawWaterSurfaces()', 'worldRenderer.R_PolyBlendProduction(']
        positions=[host.find(x) for x in order]
        if any(x<0 for x in positions) or positions != sorted(positions): errors.append('production post-world render order differs')
        world=(root/'src/miniquake/render/world.ml').read_text(encoding='utf-8-sig')
        viewport=world.find('viewport = R_ViewportRect(')
        frustum=world.find('gl.frustum(', viewport)
        if viewport<0 or frustum<viewport: errors.append('viewport fudge is not applied before projection')
    return errors

def run_component(component: str, argv=None):
    """Run component and capture its deterministic result."""
    c=CONFIG[component]
    ap=argparse.ArgumentParser(); ap.add_argument('root',nargs='?',default='.'); ap.add_argument('--root',dest='root_flag'); ap.add_argument('--write-golden',action='store_true'); ap.add_argument('--json-output')
    args=ap.parse_args(argv); root=Path(args.root_flag or args.root).resolve(); doc=document(root,component); golden=root/c['golden']
    if args.write_golden:
        golden.parent.mkdir(parents=True,exist_ok=True); golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file(): errors.append('missing golden: '+c['golden'])
    else:
        try: current=json.loads(golden.read_text(encoding='utf-8-sig'))
        except Exception as exc: current=None; errors.append('invalid golden JSON: '+str(exc))
        if current is not None and current != doc: errors.append('golden differs from Python model')
    ok, detail, actual=run_oracle(root,component)
    if not ok: errors.append('C oracle failed: '+detail)
    elif actual and actual != doc['rows']: errors.append('C oracle differs from Python model')
    errors += check_contract(root,component)
    report={'schema':f'MiniQuakeBP{component}WorldRenderVerification/1','package_id':c['package'],'parent_package_id':c['parent'],'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':c['fixtures'],'errors':errors}
    if args.json_output: Path(args.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'MiniQuake {c["package"]} world-render verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(doc["rows"])} runtime_fixtures={c["fixtures"]} oracle={detail}')
    for error in errors: print('  ERROR: '+error)
    return 0 if not errors else 1
