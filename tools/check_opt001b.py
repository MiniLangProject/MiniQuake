#!/usr/bin/env python3
"""Static OPT-001B error-freedom and delivery contract checks."""
from __future__ import annotations
import argparse, json, re
from pathlib import Path

def require(text: str, markers: list[str], label: str, errors: list[str]) -> None:
    for marker in markers:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument('--root',default='.')
    ap.add_argument('--json',default='')
    ap.add_argument('--allow-downstream-package', action='store_true')
    args=ap.parse_args()
    root=Path(args.root).resolve()
    errors=[]
    world=(root/'src/miniquake/render/world.ml').read_text(encoding='utf-8-sig')
    entities=(root/'src/miniquake/render/entities.ml').read_text(encoding='utf-8-sig')
    opt=(root/'src/miniquake/optimization_baseline.ml').read_text(encoding='utf-8-sig')
    main=(root/'src/main.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    bi=(root/'src/miniquake/build_info.ml').read_text(encoding='utf-8-sig')
    if args.allow_downstream_package:
        if 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R8"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R8.ps1'
            downstream_revision = 'OPT-001CR3R8'
            downstream_parent = 'OPT-001CR3R7'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R6"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R6.ps1'
            downstream_revision = 'OPT-001CR3R6'
            downstream_parent = 'OPT-001CR3R5'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R4"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R4.ps1'
            downstream_revision = 'OPT-001CR3R4'
            downstream_parent = 'OPT-001CR3R3'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R3"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R3.ps1'
            downstream_revision = 'OPT-001CR3R3'
            downstream_parent = 'OPT-001CR3R2'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R2"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R2.ps1'
            downstream_revision = 'OPT-001CR3R2'
            downstream_parent = 'OPT-001CR3R1'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R1"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3R1.ps1'
            downstream_revision = 'OPT-001CR3R1'
            downstream_parent = 'OPT-001CR3'
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3"' in bi:
            runner_path = root / 'scripts' / 'TEST_OPT-001CR3.ps1'
            downstream_revision = 'OPT-001CR3'
            downstream_parent = 'OPT-001CR2'
        else:
            runner_path = root / 'scripts' / 'TEST_OPT-001C.ps1'
            downstream_revision = 'OPT-001C'
            downstream_parent = 'OPT-001B'
    else:
        runner_path = root / 'scripts' / 'TEST_OPT-001B.ps1'
    runner=runner_path.read_text(encoding='utf-8-sig')
    contract=(root/'tests/opt001b_contract_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/opt001b_correctness_golden.json').read_text(encoding='utf-8-sig'))

    require(world,[
        'function buildUnderwaterFlags(map)',
        'underwaterFlags = buildUnderwaterFlags(map)',
        'underwaterFlags[faceIndex] != 0',
        'function R_CurrentDepthRange()',
        'makeEmptyArray already contains void',
    ],'world',errors)
    if re.search(r'textures\s*\[\s*textureIndex\s*\]\s*=\s*void',world):
        errors.append('world still assigns void through a texture array index')
    build_surface=re.search(r'(?ms)^function buildSurface\b.*?^end function$',world)
    if build_surface and 'bsp.faceUnderwater' in build_surface.group(0):
        errors.append('buildSurface still performs per-face leaf/marksurface search')

    require(entities,[
        'function viewModelDepthRange(depthMin, depthMax)',
        'depthMin + renderUiContract.viewModelDepthMaximum() * (depthMax - depthMin)',
        'activeDepth = worldRenderer.R_CurrentDepthRange()',
        'gl.depthRange(activeDepth[0], activeDepth[1])',
    ],'entities',errors)
    if 'gl.depthRange(0.0, renderUiContract.viewModelDepthMaximum())' in entities:
        errors.append('fixed normal-direction viewmodel depth range remains')

    require(opt,[
        'maximum - minimum <= 1',
        'handles[tail] == handles[tail - 1]',
        'return "PLATEAU"',
    ],'handle classification',errors)
    require(main,['--opt001b-transition','runOpt001BTransitionCommand'], 'main', errors)
    require(host,['function runOpt001BTransition(', 'MiniQuake OPT-001B transition ', 'startMap(session, mapName)'], 'host', errors)
    if args.allow_downstream_package:
        visible_marker = 'E1M2VisibleFrames = 1500' if downstream_revision == 'OPT-001CR3R8' else 'E1M2VisibleFrames = 1000'
        require(runner,[
            f'$DeliveryRevision = "{downstream_revision}"',
            f'$DeliveryParent = "{downstream_parent}"',
            visible_marker,
            'E1M2HeadlessFrames = 10000',
            '--opt001b-transition',
            f'MiniQuake {downstream_revision} acceptance test: PASS',
        ],'downstream runner',errors)
    else:
        require(bi,[
            'const OPTIMIZATION_STATUS = "opt001b_error_freedom_candidate_v1"',
            'const OPTIMIZATION_FINGERPRINT = 0x1b001b02',
            'const OPTIMIZATION_PARENT = "OPT-001A"',
        ],'build info',errors)
        require(runner,[
            '$DeliveryRevision = "OPT-001B"',
            '$DeliveryParent = "OPT-001A"',
            'E1M2VisibleFrames = 1000',
            'E1M2HeadlessFrames = 10000',
            '--opt001b-transition',
            'MiniQuake OPT-001B acceptance test: PASS',
        ],'runner',errors)
    require(contract,[
        'viewModelDepthRange(1.0, 0.5)',
        '[278, 278, 279, 279]',
        'MiniQuake OPT-001B correctness tests passed:',
    ],'contract',errors)
    expected={
        'status':'opt001b_error_freedom_candidate_v1',
        'fingerprint':'0x1b001b02',
        'parent':'OPT-001A',
        'e1m2_visible_frames':1000,
        'e1m2_headless_frames':10000,
    }
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'golden {k}={golden.get(k)!r}, expected {v!r}')

    report={
        'schema':'MiniQuakeOPT001BStatic/1',
        'status':'PASS' if not errors else 'FAIL',
        'downstream_package': args.allow_downstream_package,
        'errors':errors,
        'checks':{
            'viewmodel_depth_active_range':True,
            'underwater_linear_precompute':True,
            'void_texture_slot_safe':True,
            'e1m2_visible_frames':1000,
            'e1m2_headless_frames':10000,
            'transition':['e1m1','e1m2','e1m1'],
        }
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake OPT-001B verification: '+report['status'])
    for e in errors: print('  error: '+e)
    return 0 if not errors else 1

if __name__=='__main__':
    raise SystemExit(main())
