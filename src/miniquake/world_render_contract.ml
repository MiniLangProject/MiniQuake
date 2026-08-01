package miniquake.world_render_contract

// BP-044: the authoritative GLQuake 1.09 world-render contract.  Modern
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

function status()
  return STATUS
end function

function fingerprint()
  return FINGERPRINT
end function

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
