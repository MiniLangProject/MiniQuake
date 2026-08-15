/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.world_physics_contract.
*/
package miniquake.world_physics_contract

const STATUS = "world_physics_109_frozen_v1"
const PARENT_PROTOCOL_STATUS = "protocol15_frozen_v1"
const PARENT_QUAKEC_STATUS = "quakec_109_frozen_v1"
const CONTRACT_FINGERPRINT = 0x2235d77c
const BOX_HULL_NODES = 6
const NORMAL_LINK_EXPANSION = 1
const ITEM_LINK_EXPANSION = 15
const MONSTER_STEP_SIZE = 18
const MAX_CLIP_PLANES = 5
const FLY_MOVE_BUMPS = 4
const CLIENT_MAX_SPEED = 320
const AIR_ACCELERATION_CAP = 30
const IDEAL_PITCH_FORWARD_SAMPLES = 6
const PRODUCTION_DISPATCH = "shared_nonclient"
const FORCE_RETOUCH_ORDER = "ordered"

// Report whether canonical text.
function canonicalText()
  return "world_physics_109_frozen_v1|hull_nodes=6|link_expand=1|item_expand=15|move_step=18|clip_planes=5|fly_bumps=4|stop_epsilon=0.1|client_maxspeed=320|air_cap=30|idealpitch_forward=6|production_dispatch=shared_nonclient|force_retouch=ordered|protocol=protocol15_frozen_v1|quakec=quakec_109_frozen_v1"
end function

// Provide fnv1a text behavior for the active subsystem.
function fnv1aText(text)
  state = 2166136261
  source = bytes(text)
  index = 0
  while index < len(source)
    state = ((state ^ source[index]) * 16777619) & 0xffffffff
    index = index + 1
  end while
  return state
end function

// Provide computed fingerprint behavior for the active subsystem.
function computedFingerprint()
  return fnv1aText(canonicalText())
end function

// Return component names derived from the active module state.
function componentNames()
  return ["world_hull", "world_link", "server_move", "server_physics", "server_user"]
end function

// Validate the requested value and report any incompatibility.
function validate()
  if computedFingerprint() != CONTRACT_FINGERPRINT then return false end if
  if len(componentNames()) != 5 then return false end if
  return true
end function
