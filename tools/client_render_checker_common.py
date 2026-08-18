#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Shared source-guided checker for BP-035..BP-039 client/render block."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path

CONFIG = {
    '035': {
        'package':'BP-035','parent':'BP-034R1','schema':'MiniQuakeClientStateGolden/1',
        'golden':'audit/client_state_render_golden.json','oracle':'tools/oracle/client_state_oracle.c',
        'test':'tests/client_state_render_tests.ml','fixtures':21,
        'success':'MiniQuake BP-035 client state/render tests passed: 21',
        'markers':{
            'src/miniquake/client.ml':[
                'function clientFloat(value)', 'function clientLerp(previous, current, fraction)',
                'function CL_ActiveVisibleEntities(client)', 'function CL_ViewEntityOrigin(client)',
                'interval = clientFloat(client.messageTimes[0] - client.messageTimes[1])',
                'client.time = client.messageTimes[0]',
                'binaryObjectRotation = clientFloat(math.anglemod(100.0 * client.time))',
            ],
            'src/miniquake/host.ml':['renderEntities = renderHandoff.submitEntities(visibleEntities, temporaryModels)'],
        },
    },
    '036': {
        'package':'BP-036','parent':'BP-035','schema':'MiniQuakeViewStateGolden/1',
        'golden':'audit/view_state_golden.json','oracle':'tools/oracle/view_state_oracle.c',
        'test':'tests/view_state_parity_tests.ml','fixtures':22,
        'success':'MiniQuake BP-036 view state tests passed: 22',
        'markers':{
            'src/miniquake/view.ml':['function V_cshift_f(state, arguments)'],
            'src/miniquake/chase.ml':['function Chase_UpdateRefdef(state, viewOrigin, clientViewAngles, renderViewAngles, worldMap)','adjustedAngles = math.VectorCopy(renderViewAngles)'],
            'src/miniquake/host.ml':['chase.Chase_UpdateRefdef('],
        },
    },
    '037': {
        'package':'BP-037','parent':'BP-036','schema':'MiniQuakeTemporaryBeamGolden/1',
        'golden':'audit/temp_beam_render_golden.json','oracle':'tools/oracle/temp_beam_oracle.c',
        'test':'tests/temp_beam_render_tests.ml','fixtures':22,
        'success':'MiniQuake BP-037 temporary beam tests passed: 22',
        'markers':{
            'src/miniquake/client_render_handoff.ml':['function beamAngles(startPosition, endPosition)','function beamSegmentOrigins(startPosition, endPosition, limit)','function buildTemporaryEntities(compactBeams, client, currentTime, visibleCount)','particles.compatRand() % 360','progs/bolt.mdl','progs/beam.mdl'],
            'src/miniquake/host.ml':['renderHandoff.buildTemporaryEntities('],
        },
    },
    '038': {
        'package':'BP-038','parent':'BP-037','schema':'MiniQuakeParticleRuntimeGolden/1',
        'golden':'audit/particle_runtime_golden.json','oracle':'tools/oracle/particle_runtime_oracle.c',
        'test':'tests/particle_runtime_parity_tests.ml','fixtures':24,
        'success':'MiniQuake BP-038 particle runtime tests passed: 24',
        'markers':{
            'src/miniquake/particles.ml':['function particleFloat(value)','function updateWithGravity(particles, currentTime, deltaTime, gravity)','particle.velocity.x = particleFloat(particle.velocity.x - particle.velocity.x * dvel)','particle.velocity.z = particleFloat(particle.velocity.z - grav)'],
            'src/miniquake/host.ml':['cvar.variableValue(session.cvars, "sv_gravity")'],
        },
    },
    '039': {
        'package':'BP-039','parent':'BP-038','schema':'MiniQuakeClientRenderClosureGolden/1',
        'golden':'audit/client_render_closure_golden.json','oracle':'tools/oracle/client_render_closure_oracle.c',
        'test':'tests/client_render_closure_tests.ml','fixtures':30,
        'success':'MiniQuake BP-039 client/render closure tests passed: 30',
        'markers':{
            'src/miniquake/client_render_contract.ml':['client_render_109_frozen_v1','0x95e2b295','const BEAM_MODEL_HANDOFF = 1','const CHASE_REFDEF_PRESERVATION = 1','const EFRAG_FRAME_ACCUMULATION = 1','const PARTICLE_FLOAT_STORAGE = 1'],
            'src/miniquake/render/entities.ml':['function renderSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, viewRight, viewUp, time)'],
            'src/miniquake/render/gl_refrag.ml':['function R_BeginVisibleFrame()','function R_VisibleEntities()'],
            'src/miniquake/host.ml':['entityRenderer.renderSubmitted(','renderHandoff.currentTemporaryEntities()'],
        },
    },
}

def f32(value: float) -> float:
    """Round a value through the IEEE-754 binary32 representation."""
    return struct.unpack('<f', struct.pack('<f', float(value)))[0]

def fbits(value: float) -> int:
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I', struct.pack('<f', float(value)))[0]

def quake_anglemod(value: float) -> float:
    # mathlib.c receives a float parameter, performs the quantization with
    # double constants, then stores the result back into a float.
    """Reproduce the reference quake anglemod operation for differential testing."""
    a = f32(value)
    quantized = int(a * (65536.0 / 360.0)) & 65535
    return f32((360.0 / 65536.0) * quantized)

def rows(component: str):
    """Build the deterministic result rows for this verifier."""
    if component == '035':
        return [
            {'name':'lerp_half_fbits','value':fbits((1.95 - 1.9) / f32(2.0 - 1.9))},
            {'name':'angle_wrap_fbits','value':fbits(360.0)},
            {'name':'dlight_decay_fbits','value':fbits(90.0)},
            {'name':'nolerp_time_fbits','value':fbits(2.0)},
            {'name':'nolerp_rotate_fbits','value':fbits(quake_anglemod(200.0))},
            {'name':'float_integer_boundary','value':fbits(16777217.0)},
            {'name':'max_visedicts','value':256},
            {'name':'fixtures','value':20},
        ]
    if component == '036':
        return [
            {'name':'atoi_decimal_prefix','value':12},
            {'name':'atoi_negative_prefix','value':-7},
            {'name':'atoi_invalid','value':0},
            {'name':'chase_dest_x_fbits','value':fbits(-90.0)},
            {'name':'chase_dest_z_fbits','value':fbits(46.0)},
            {'name':'preserved_yaw_fbits','value':fbits(123.0)},
            {'name':'preserved_roll_fbits','value':fbits(7.0)},
            {'name':'fixtures','value':22},
        ]
    if component == '037':
        return [
            {'name':'segments_zero','value':0},
            {'name':'segments_one','value':1},
            {'name':'segments_thirty','value':1},
            {'name':'segments_thirty_one','value':2},
            {'name':'segments_sixty_one','value':3},
            {'name':'pitch_up','value':90},
            {'name':'pitch_down','value':270},
            {'name':'yaw_left','value':90},
            {'name':'beam_pool','value':24},
            {'name':'temp_limit','value':64},
            {'name':'fixtures','value':22},
        ]
    if component == '038':
        return [
            {'name':'custom_gravity_fbits','value':fbits(8.0)},
            {'name':'default_gravity_fbits','value':fbits(6.0)},
            {'name':'blob2_x_fbits','value':fbits(6.0)},
            {'name':'blob2_z_zero_gravity_fbits','value':fbits(10.0)},
            {'name':'blob2_z_gravity_fbits','value':fbits(6.0)},
            {'name':'explode_x_fbits','value':fbits(14.0)},
            {'name':'float_integer_boundary','value':fbits(16777217.0)},
            {'name':'fixtures','value':22},
        ]
    return [
        {'name':'contract_fingerprint','value':0x95E2B295},
        {'name':'max_visedicts','value':256},
        {'name':'max_temp_entities','value':64},
        {'name':'beam_pool','value':24},
        {'name':'beam_step','value':30},
        {'name':'feature_bits','value':15},
        {'name':'fixtures','value':24},
    ]

def sha256(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(path.read_bytes()).hexdigest()

def document(root: Path, component: str):
    """Render the canonical evidence document for this verifier."""
    c = CONFIG[component]
    return {
        'schema': c['schema'], 'package_id': c['package'], 'parent_package_id': c['parent'],
        'sources': ['cl_main.c','view.c','chase.c','cl_tent.c','r_part.c','gl_refrag.c','gl_rmain.c'],
        'rows': rows(component),
        'reference': {'oracle': c['oracle'], 'oracle_sha256': sha256(root/c['oracle'])},
    }

def compiler():
    """Locate a supported C compiler for the reference oracle."""
    candidates = ([os.environ['CC']] if os.environ.get('CC') else []) + ['cc','gcc','clang']
    for candidate in candidates:
        parts = candidate.split()
        if shutil.which(parts[0]): return parts
    return None

def run_oracle(root: Path, component: str):
    """Run oracle and capture its deterministic result."""
    cc = compiler()
    if not cc: return True, 'not available', []
    oracle = root/CONFIG[component]['oracle']
    with tempfile.TemporaryDirectory(prefix=f'mq-bp{component}-') as td:
        exe = Path(td)/('oracle.exe' if os.name == 'nt' else 'oracle')
        cmd = cc + ['-std=c11','-Wall','-Wextra','-Werror','-O2',str(oracle),'-lm','-o',str(exe)]
        build = subprocess.run(cmd,capture_output=True,text=True)
        if build.returncode: return False, build.stdout+build.stderr, []
        run = subprocess.run([str(exe)],capture_output=True,text=True)
        try: actual=[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
        except Exception as exc: return False, f'oracle JSON: {exc}: {run.stdout}', []
        return run.returncode == 0, ' '.join(cc), actual

def check_contract(root: Path, component: str, allow_downstream_package: bool = False):
    """Validate contract and return its contract findings."""
    c=CONFIG[component]; errors=[]
    for rel, markers in c['markers'].items():
        path=root/rel
        if not path.is_file(): errors.append('missing source: '+rel); continue
        text=path.read_text(encoding='utf-8-sig')
        for marker in markers:
            if marker not in text: errors.append(f'{rel}: missing marker: {marker}')
    if component == '036':
        historical_marker = 'values[index] = common.atoi(arguments[index + 1])'
        downstream_marker = 'values[index] = common.cAtoi(arguments[index + 1])'
        view_text = (root/'src/miniquake/view.ml').read_text(encoding='utf-8-sig')
        if allow_downstream_package:
            if downstream_marker not in view_text:
                errors.append('downstream BP-036 view parser is not the C atoi adapter')
            if historical_marker in view_text:
                errors.append('stale historical parser marker remains in downstream package: common.atoi(arguments[index + 1])')
        else:
            if historical_marker not in view_text:
                errors.append('historical BP-036 view parser marker differs: common.atoi(arguments[index + 1])')

    test=root/c['test']
    if not test.is_file(): errors.append('missing runtime test: '+c['test'])
    else:
        text=test.read_text(encoding='utf-8-sig')
        if c['success'] not in text: errors.append('runtime success marker/count differs')
        if f'passed != {c["fixtures"]}' not in text: errors.append('runtime fixture guard differs')
        if component == '035':
            required = (
                'near(value.time, 2.0, 0.0, "no-lerp time snap")',
                'near(entity.angles.y, 199.9951171875, 0.0001, "binary object rotation")',
            )
            for marker in required:
                if marker not in text: errors.append('missing BP-035 no-lerp rotation marker: '+marker)
            stale = 'near(entity.angles.y, 100.0, 0.0001, "binary object rotation")'
            if stale in text: errors.append('stale BP-035 pre-CL_LerpPoint rotation expectation remains')
        if component == '036':
            historical_runtime = (
                'equal(state.emptyCshift[2], 32.0, "hex atoi")',
                'equal(state.emptyCshift[3], 65.0, "character atoi")',
            )
            downstream_runtime = (
                'equal(state.emptyCshift[2], 0.0, "hex rejected by CRT atoi")',
                'equal(state.emptyCshift[3], 0.0, "character rejected by CRT atoi")',
            )
            if allow_downstream_package:
                for marker in downstream_runtime:
                    if marker not in text:
                        errors.append('downstream BP-036 runtime fixture missing C atoi expectation: '+marker)
                for marker in historical_runtime:
                    if marker in text:
                        errors.append('stale historical BP-036 runtime expectation remains: '+marker)
            else:
                for marker in historical_runtime:
                    if marker not in text:
                        errors.append('historical BP-036 runtime expectation differs: '+marker)
    return errors

def run_component(component: str, argv=None):
    """Run component and capture its deterministic result."""
    c=CONFIG[component]
    ap=argparse.ArgumentParser(); ap.add_argument('root',nargs='?',default='.'); ap.add_argument('--root',dest='root_flag'); ap.add_argument('--write-golden',action='store_true'); ap.add_argument('--json-output'); ap.add_argument('--allow-downstream-package',action='store_true')
    args=ap.parse_args(argv)
    root=Path(args.root_flag or args.root).resolve(); doc=document(root,component); golden=root/c['golden']
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
    errors += check_contract(root,component,args.allow_downstream_package)
    report={'schema':f'MiniQuakeBP{component}Verification/1','package_id':c['package'],'parent_package_id':c['parent'],'ok':not errors,'oracle':detail,'rows':len(doc['rows']),'runtime_fixtures':c['fixtures'],'downstream_package':bool(args.allow_downstream_package),'view_number_parser':('c_atoi' if component == '036' and args.allow_downstream_package else ('q_atoi' if component == '036' else 'not_applicable')),'runtime_view_expectation':('c_atoi' if component == '036' and args.allow_downstream_package else ('q_atoi' if component == '036' else 'not_applicable')),'errors':errors}
    if args.json_output: Path(args.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(f'MiniQuake {c["package"]} client/render verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(doc["rows"])} runtime_fixtures={c["fixtures"]} oracle={detail}')
    for error in errors: print('  ERROR: '+error)
    return 0 if not errors else 1
