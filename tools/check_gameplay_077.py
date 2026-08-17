#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check gameplay 077 compatibility and regression contract."""

import argparse, json, pathlib, sys

def function_slice(text,name):
    """Extract one complete MiniLang function body from source text."""
    start=text.find('function '+name+'(')
    if start<0: return ''
    end=text.find('\nend function',start)
    return text[start:end+13] if end>=0 else text[start:]

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    golden=json.loads((root/'audit/gameplay_screen_golden.json').read_text())
    test=(root/'tests/gameplay_screen_tests.ml').read_text(encoding='utf-8-sig')
    screen=(root/'src/miniquake/screen.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    for marker in ['MiniQuake BP-077 screen/loading tests passed: 23','function testScreenshotHistoricalError()','function testTileClearHistoricalWidth()']:
        if marker not in test: errors.append('test missing: '+marker)
    for marker in ['function SCR_ScreenshotFailure()',"SCR_ScreenShot_f: Couldn't create a PCX file",'while index <= 99','realtime - scr_disabled_time > 60.0']:
        if marker not in screen: errors.append('screen missing: '+marker)
    for fn in ['transitionMap','Host_Reconnect_f']:
        part=function_slice(host,fn)
        stop=part.find('mixer.stopAll')
        plaque=part.find('screen.SCR_BeginLoadingPlaque')
        if stop<0 or plaque<0 or stop>plaque: errors.append(fn+': audio stop is not before loading-plaque gate')
    expected={'fixtures':23,'center_line_chars':40,'screenshot_slots':100,'loading_timeout_seconds':60,'normal_overlay_stages':11,'loading_stops_audio_before_gate':True}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'golden {k}: expected {v}, got {golden.get(k)!r}')
    report={'schema_version':1,'package':'BP-077','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':23,'loading_sound_order':'before_connection_gate'}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-077 screen/loading verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
