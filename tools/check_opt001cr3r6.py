#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, re
from pathlib import Path

REV='OPT-001CR3R8'
PARENT='OPT-001CR3R7'
STATUS='opt001cr3r8_performance_audio_ui_candidate_v1'
FINGERPRINT='0x1c001c10'

def function_block(text: str, name: str) -> str:
    m=re.search(rf"(?ms)^function(?:\s+inline)?\s+{re.escape(name)}\b.*?^end function$", text)
    return m.group(0) if m else ""

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default=''); args=ap.parse_args()
    root=Path(args.root).resolve(); errors=[]
    def text(rel): return (root/rel).read_text(encoding='utf-8')
    main_src=text('src/main.ml'); vid=text('src/miniquake/gl_vidnt.ml'); world=text('src/miniquake/render/world.ml')
    bi=text('src/miniquake/build_info.ml'); allocation=text('tests/opt001c_contract_tests.ml')
    hot=text('tests/opt001cr3_hotpath_tests.ml'); runner=text('TEST_'+REV+'.ps1')
    vid_test=text('tests/gl_vidnt_parity_tests.ml')

    for forbidden in ('function opt001cr3r5HasArgument', 'function opt001cr3r5ApplyDefaultWindow', 'args = opt001cr3r5ApplyDefaultWindow(args)'):
        if forbidden in main_src: errors.append('main retains broken R5 argument mutation: '+forbidden)
    for marker in (
        'function VID_WindowedRequested(arguments)', 'function VID_FullscreenRequested(arguments)',
        'VID_WindowedRequested(arguments) or not VID_FullscreenRequested(arguments)',
        'common.hasParm(arguments, "-fullscreen")', 'common.hasParm(arguments, "-mode")',
    ):
        if marker not in vid: errors.append('video default missing marker: '+marker)
    for marker in (
        'common.create([])', 'default startup is windowed',
        'explicit fullscreen override', '"-fullscreen", "-width", "800"',
    ):
        if marker not in vid_test: errors.append('video fixture missing marker: '+marker)

    expected=[
        f'const OPTIMIZATION_STATUS = "{STATUS}"', f'const OPTIMIZATION_FINGERPRINT = {FINGERPRINT}',
        f'const OPTIMIZATION_PARENT = "{PARENT}"', f'const OPTIMIZATION_DELIVERY_REVISION = "{REV}"',
        'const OPT001C_STATUS = "opt001c_frame_allocation_candidate_v1"',
        'const OPT001C_FINGERPRINT = 0x1c001c03', 'const OPT001C_PARENT = "OPT-001B"',
    ]
    for marker in expected:
        if marker not in bi: errors.append('build_info missing marker: '+marker)
    for marker in ('buildInfo.OPT001C_STATUS', 'buildInfo.OPT001C_FINGERPRINT', 'buildInfo.OPT001C_PARENT'):
        if marker not in allocation: errors.append('allocation fixture missing frozen identity: '+marker)

    for marker in ('function R_ResetWorldCompatibility()', 'if rCompatRenderer == renderer then R_ResetWorldCompatibility() end if',
                   'rCompatTextureChains = []', 'rCompatSurfaceWarpPolys = []', 'lightmaps = bytes()', 'currentTextureFrame = 0'):
        if marker not in world: errors.append('world reset missing marker: '+marker)

    for marker in (f'opt001cr3r8Passed = 0', f'function opt001cr3r8Check(condition, label)',
                   f'buildInfo.OPTIMIZATION_DELIVERY_REVISION == "{REV}"', 'default video mode is windowed',
                   'explicit fullscreen override'):
        if marker not in hot: errors.append('hotpath/window fixture missing marker: '+marker)
    if re.search(r'(?m)^function\s+(check|equal|require)\s*\(',hot): errors.append('generic global test helper remains')

    for marker in (f'$DeliveryRevision = "{REV}"', f'$DeliveryParent = "{PARENT}"',
                   'output_mode=python_binary_passthrough_named_build_binding',
                   f'MiniQuake {REV} acceptance test: PASS',
                   'incremental-performance.log" -AllowFailure'):
        if marker not in runner: errors.append('runner missing marker: '+marker)

    # Catch the exact R5 grammar error class in all MiniLang sources: a block
    # if line must contain the `then` keyword. Inline/block comments are ignored.
    block_if_issues=[]
    for path in sorted((root/'src').rglob('*.ml'))+sorted((root/'tests').rglob('*.ml')):
        lines=path.read_text(encoding='utf-8').splitlines()
        for index,line in enumerate(lines):
            code=line.split('//',1)[0].strip()
            if not code.startswith('if ') or ' then' in code:
                continue
            combined=code
            look=index+1
            # MiniLang permits a condition to continue after `or`, `and`,
            # operators and opening delimiters. Stop before the first body
            # statement; a valid multiline condition must encounter `then`.
            while look < len(lines) and look <= index + 8:
                nxt=lines[look].split('//',1)[0].strip()
                if not nxt:
                    look += 1
                    continue
                combined += ' ' + nxt
                if ' then' in combined:
                    break
                previous=lines[look-1].split('//',1)[0].rstrip()
                if not (previous.endswith(' or') or previous.endswith(' and') or
                        previous.endswith('(') or previous.endswith(',') or
                        previous.endswith('+') or previous.endswith('-') or
                        previous.endswith('*') or previous.endswith('/') or
                        previous.endswith('%') or previous.endswith('&') or
                        previous.endswith('|') or previous.endswith('^')):
                    break
                look += 1
            if ' then' not in combined:
                block_if_issues.append(f'{path.relative_to(root)}:{index+1}: block if missing then')
    errors.extend(block_if_issues)

    report={'schema':'MiniQuakeOPT001CR3R8DownstreamStatic/1','status':'PASS' if not errors else 'FAIL','errors':errors,
            'default_video_mode':'windowed','explicit_fullscreen':True,'renderer_reset':True,
            'frozen_opt001c_identity':True,'block_if_issues':len(block_if_issues)}
    if args.json: Path(args.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake '+REV+' window/transition verification: '+report['status'])
    for e in errors: print('  error: '+e)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
