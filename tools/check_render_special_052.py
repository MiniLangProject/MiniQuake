#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check render special 052 compatibility and regression contract."""

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
    rmisc=(root/'src/miniquake/render/gl_rmisc.ml').read_text(encoding='utf-8')
    test=(root/'tests/envmap_timerefresh_tests.ml').read_text(encoding='utf-8')
    golden=json.loads((root/'audit/envmap_timerefresh_golden.json').read_text(encoding='utf-8'))
    for marker in ('const ENVMAP_SIZE = 256','const ENVMAP_FACES = 6','const TIMEREFRESH_STEPS = 128','function envmapDirections()','function timeRefreshYaw(','function timeRefreshResult('):
        if marker not in special: errors.append(f'special path missing {marker}')
    for marker in ('function R_Envmap_f()','rmiscRenderViews = 6','function R_TimeRefresh_f()','rmiscRenderViews = 128'):
        if marker not in rmisc: errors.append(f'gl_rmisc missing {marker}')
    if test.count('bp052Run(')!=21: errors.append('BP-052 test does not contain 20 fixture calls')
    if 'MiniQuake BP-052 envmap/timerefresh tests passed: 20' not in test: errors.append('BP-052 pass marker differs')
    expected={'fixtures':20,'envmap_size':256,'envmap_faces':6,'envmap_bytes':262144,'timerefresh_steps':128}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'BP-052 golden {k} differs')
    details={"root": str(root), "error_count": len(errors)}
    if errors:
        emit_report(a.json_output, 'bp052_envmap_timerefresh', False, details, errors)
        print('MiniQuake BP-052 envmap/timerefresh verification: FAIL'); [print('  '+e) for e in errors]; return 1
    emit_report(a.json_output, 'bp052_envmap_timerefresh', True, details, [])
    print('MiniQuake BP-052 envmap/timerefresh verification: PASS')
    print('  fixtures=20 envmap_faces=6 timerefresh_steps=128')
    return 0
if __name__=='__main__': raise SystemExit(main())
