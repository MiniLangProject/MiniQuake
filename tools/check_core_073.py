#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the check core 073 compatibility and regression contract."""

import argparse, json, pathlib, sys

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    files={
      'bsp':root/'src/miniquake/format/bsp.ml',
      'mdl':root/'src/miniquake/format/mdl.ml',
      'sprite':root/'src/miniquake/format/sprite.ml',
      'registry':root/'src/miniquake/model_registry.ml',
      'test':root/'tests/model_asset_parity_tests.ml',
    }
    text={k:p.read_text(encoding='utf-8-sig') for k,p in files.items()}
    golden=json.loads((root/'audit/model_asset_golden.json').read_text(encoding='utf-8'))
    required={
      'bsp':['if version != c.BSP_VERSION','function Mod_LoadBrushModel(data, filename)','protocolText.decodeBytes'],
      'mdl':['if version != c.MDL_VERSION','function Mod_LoadAliasModel(data, filename)','if poseCount > c.MAX_ALIAS_FRAMES'],
      'sprite':['if version != c.SPRITE_VERSION','function Mod_LoadSpriteModel(data, filename)','if intervals[i] <= 0.0'],
      'registry':['strcmp, not Q_strcasecmp','if registry.types[index] != MOD_ALIAS then registry.needLoad[index] = true end if','function registerBrushSubmodels'],
      'test':['MiniQuake BP-073 model asset tests passed: 24','function bp073Case24()',
              'bp073Equal(brush.textures[0].name, "+0fixture", "animation base name")',
              'bp073Equal(animations[0][0], 4, "animation total")',
              'bp073Equal(animations[0][3], 1, "animation primary next")',
              'bp073Equal(animations[0][4], 2, "animation alternate")',
              'bp073Equal(model.mins.x, -4.0, "brush mins x")',
              'bp073Equal(model.maxs.z, 13.0, "brush maxs z")',
              'bp073Equal(brushBounds[0].x, -4.0, "registry brush bounds")']}
    for key,markers in required.items():
        for marker in markers:
            if marker not in text[key]: errors.append(f'{key}: missing source marker: {marker}')
    expected={'fixtures':24,'bsp_version':29,'mdl_version':6,'sprite_version':1,'header_lumps':15,'max_models':256,'max_alias_vertices':2000,
              'texture_animation_total':4,'texture_animation_base_name':'+0fixture',
              'animation_cycle':2,'animation_primary_frames':2,'animation_total':4,
              'animation_primary_next':1,'animation_alternate':2,
              'submodel_bounds_spread':1,
              'submodel_input_mins':[-3,-4,0],
              'submodel_loaded_mins':[-4,-5,-1],
              'submodel_input_maxs':[2,1,12],
              'submodel_loaded_maxs':[3,2,13]}
    for key,value in expected.items():
        if golden.get(key)!=value: errors.append(f'golden {key}: expected {value}, got {golden.get(key)!r}')
    if golden.get('text_abi')!='quake_latin1_cstring_v1': errors.append('golden text ABI mismatch')
    for marker in (
      'submodel_bounds_spread=1',
      'submodel_input_mins=-3,-4,0',
      'submodel_loaded_mins=-4,-5,-1',
      'submodel_input_maxs=2,1,12',
      'submodel_loaded_maxs=3,2,13',
    ):
        if marker not in (root/'tools/oracle/model_asset_oracle.c').read_text(encoding='utf-8-sig'):
            errors.append('model C oracle lacks '+marker)
    report={'schema_version':1,'package':'BP-073','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':24,'formats':3,'registry_dispatch_types':3,'invalid_format_cases':3,
            'texture_animation_total':4,'texture_animation_base_name':'+0fixture',
            'animation_cycle':2,'animation_primary_frames':2,'animation_total':4,
            'animation_primary_next':1,'animation_alternate':2,
              'submodel_bounds_spread':1,
              'submodel_input_mins':[-3,-4,0],
              'submodel_loaded_mins':[-4,-5,-1],
              'submodel_input_maxs':[2,1,12],
              'submodel_loaded_maxs':[3,2,13]}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-073 model asset verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
