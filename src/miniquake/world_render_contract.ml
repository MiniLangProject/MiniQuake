/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.world_render_contract.
*/
package miniquake.world_render_contract

// BP-044: the authoritative MiniQuake 1.09 world-render contract.  Modern
// backends may consume the same render handoff, but compatibility mode keeps
// these observable constants and pass ordering fixed.
const STATUS = "world_render_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.world_render_contract`.
const FINGERPRINT = 0x846a74de
/// Defines the near clip value used by `miniquake.world_render_contract`.
const NEAR_CLIP = 4
/// Defines the far clip value used by `miniquake.world_render_contract`.
const FAR_CLIP = 4096
/// Defines the lightmap width value used by `miniquake.world_render_contract`.
const LIGHTMAP_WIDTH = 128
/// Defines the lightmap height value used by `miniquake.world_render_contract`.
const LIGHTMAP_HEIGHT = 128
/// Defines the max lightmaps value used by `miniquake.world_render_contract`.
const MAX_LIGHTMAPS = 64
/// Defines the max visible entities value used by `miniquake.world_render_contract`.
const MAX_VISIBLE_ENTITIES = 256
/// Defines the backface epsilon milli value used by `miniquake.world_render_contract`.
const BACKFACE_EPSILON_MILLI = 10
/// Defines the stage world value used by `miniquake.world_render_contract`.
const STAGE_WORLD = 1
/// Defines the stage entities value used by `miniquake.world_render_contract`.
const STAGE_ENTITIES = 2
/// Defines the stage dlights value used by `miniquake.world_render_contract`.
const STAGE_DLIGHTS = 3
/// Defines the stage particles value used by `miniquake.world_render_contract`.
const STAGE_PARTICLES = 4
/// Defines the stage viewmodel value used by `miniquake.world_render_contract`.
const STAGE_VIEWMODEL = 5
/// Defines the stage water value used by `miniquake.world_render_contract`.
const STAGE_WATER = 6
/// Defines the stage polyblend value used by `miniquake.world_render_contract`.
const STAGE_POLYBLEND = 7

/// Returns the compatibility status reported by `miniquake.world_render_contract`.
function inline status()
  return STATUS
end function

/// Returns the compatibility fingerprint for `miniquake.world_render_contract`.
function inline fingerprint()
  return FINGERPRINT
end function

/// Implements the `stageOrder` operation for `miniquake.world_render_contract` (stage order).
function stageOrder()
  return [
    STAGE_WORLD,
    STAGE_ENTITIES,
    STAGE_DLIGHTS,
    STAGE_PARTICLES,
    STAGE_VIEWMODEL,
    STAGE_WATER,
    STAGE_POLYBLEND,
  ]
end function

/// Returns the compatibility constants exposed by `miniquake.world_render_contract`.
function constants()
  return [
    NEAR_CLIP,
    FAR_CLIP,
    LIGHTMAP_WIDTH,
    LIGHTMAP_HEIGHT,
    MAX_LIGHTMAPS,
    MAX_VISIBLE_ENTITIES,
    BACKFACE_EPSILON_MILLI,
  ]
end function
