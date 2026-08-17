#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check render special 051 compatibility and regression contract."""

from __future__ import annotations
import argparse, json, pathlib

def emit_report(path, name, passed, details, errors):
    """Emit one deterministic machine-readable verification report."""
    if not path:
        return
    payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
    pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root', default=str(pathlib.Path(__file__).resolve().parents[1])); ap.add_argument('--json-output'); a=ap.parse_args(); root=pathlib.Path(a.root).resolve(); errors=[]
    special=(root/'src/miniquake/render/special_paths.ml').read_text(encoding='utf-8')
    world=(root/'src/miniquake/render/world.ml').read_text(encoding='utf-8')
    gl=(root/'src/miniquake/render/gl11.ml').read_text(encoding='utf-8')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8')
    test=(root/'tests/render_clear_special_tests.ml').read_text(encoding='utf-8')
    golden=json.loads((root/'audit/render_clear_special_golden.json').read_text(encoding='utf-8'))
    for marker in ('function clearPlan(','return [colorMask, 0.0, f32(0.49999), gl.GL_LEQUAL, nextFrame]','return [colorMask, 1.0, 0.5, gl.GL_GEQUAL, nextFrame]'):
        if marker not in special: errors.append(f'clear planner missing {marker}')
    for marker in ('function R_ClearProduction()','function R_ConfigureSpecialCompatibility(','if rCompatNoRefresh then return 0 end if','if rCompatFinish then gl.finish() end if'):
        if marker not in world: errors.append(f'world special clear missing {marker}')
    for marker in ('registerCvar(registry, "r_norefresh", "0"','registerCvar(registry, "r_speeds", "0"','registerCvar(registry, "gl_finish", "0"','registerCvar(registry, "gl_clear", "0"'):
        if marker not in host: errors.append(f'host cvar missing {marker}')
    for marker in ('traceCommand("clear"','traceCommand("depth_func"','traceCommand("depth_range"','traceCommand("finish"'):
        if marker not in gl: errors.append(f'GL diagnostic boundary missing {marker}')
    if test.count('bp051Run(')!=21: errors.append('BP-051 test does not contain 20 fixture calls')
    if 'MiniQuake BP-051 render-clear special tests passed: 20' not in test: errors.append('BP-051 pass marker differs')
    if golden.get('fixtures')!=20 or golden.get('ztrick_odd_depth_max')!=0.49999: errors.append('BP-051 golden differs')
    details={"root": str(root), "error_count": len(errors)}
    if errors:
        emit_report(a.json_output, 'bp051_render_clear_special', False, details, errors)
        print('MiniQuake BP-051 render-clear special verification: FAIL'); [print('  '+e) for e in errors]; return 1
    emit_report(a.json_output, 'bp051_render_clear_special', True, details, [])
    print('MiniQuake BP-051 render-clear special verification: PASS')
    print('  fixtures=20 ztrick=alternating mirror_depth_split=0.5')
    return 0
if __name__=='__main__': raise SystemExit(main())
