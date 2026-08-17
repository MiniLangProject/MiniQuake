#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the bp045 alias model checker compatibility and regression contract."""

from __future__ import annotations
import argparse, json, pathlib, re

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json-out','--json-output',dest='json_out'); ns=ap.parse_args()
    root=pathlib.Path(ns.root).resolve(); errors=[]
    alias=(root/'src/miniquake/render/alias_mesh.ml').read_text(encoding='utf-8-sig')
    entities=(root/'src/miniquake/render/entities.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/alias_model_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/alias_model_render_golden.json').read_text())
    markers=['function aliasShadowProjection(entityOriginZ, lightSpotZ)','function GL_DrawAliasShadowAtOrigin(header, posenum, entityOriginZ)','row = shadeDotRow(yaw)']
    for m in markers:
        if m not in alias: errors.append('alias mesh missing marker: '+m)
    for m in ['worldRenderer.GL_DisableMultitexture()','aliasMesh.GL_DrawAliasRayShadowSample(source, frame, entity']:
        if m not in entities: errors.append('entity renderer missing marker: '+m)
    if tests.count('if bp045Run(')!=22: errors.append('BP-045 fixture count differs from 22')
    rows=golden.get('rows',[])
    vals={r.get('name'):r.get('value') for r in rows if isinstance(r,dict)}
    if vals.get('fixtures')!=22: errors.append('golden fixture count differs')
    if vals.get('shadedot_quant')!=16: errors.append('shade quant differs')
    report={'schema_version':1,'component':'BP-045','passed':not errors,'fixtures':22,'errors':errors}
    text=json.dumps(report,indent=2)+'\n'
    if ns.json_out: pathlib.Path(ns.json_out).write_text(text)
    print(text,end='')
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
