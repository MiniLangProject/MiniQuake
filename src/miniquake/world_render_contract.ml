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
const FINGERPRINT = 0x846a74de
const NEAR_CLIP = 4
const FAR_CLIP = 4096
const LIGHTMAP_WIDTH = 128
const LIGHTMAP_HEIGHT = 128
const MAX_LIGHTMAPS = 64
const MAX_VISIBLE_ENTITIES = 256
const BACKFACE_EPSILON_MILLI = 10
const STAGE_WORLD = 1
const STAGE_ENTITIES = 2
const STAGE_DLIGHTS = 3
const STAGE_PARTICLES = 4
const STAGE_VIEWMODEL = 5
const STAGE_WATER = 6
const STAGE_POLYBLEND = 7

// Return the stable compatibility-contract status string.
function inline status()
  return STATUS
end function

// Return the stable compatibility-contract fingerprint.
function inline fingerprint()
  return FINGERPRINT
end function

// Provide stage order behavior for the active subsystem.
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

// Return constants for the active module state.
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
