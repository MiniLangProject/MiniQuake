/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.world_physics_contract.
*/
package miniquake.world_physics_contract

/// Defines the status value used by `miniquake.world_physics_contract`.
const STATUS = "world_physics_109_frozen_v1"
/// Defines the parent protocol status value used by `miniquake.world_physics_contract`.
const PARENT_PROTOCOL_STATUS = "protocol15_frozen_v1"
/// Defines the parent quakec status value used by `miniquake.world_physics_contract`.
const PARENT_QUAKEC_STATUS = "quakec_109_frozen_v1"
/// Defines the contract fingerprint value used by `miniquake.world_physics_contract`.
const CONTRACT_FINGERPRINT = 0x2235d77c
/// Defines the box hull nodes value used by `miniquake.world_physics_contract`.
const BOX_HULL_NODES = 6
/// Defines the normal link expansion value used by `miniquake.world_physics_contract`.
const NORMAL_LINK_EXPANSION = 1
/// Defines the item link expansion value used by `miniquake.world_physics_contract`.
const ITEM_LINK_EXPANSION = 15
/// Defines the monster step size value used by `miniquake.world_physics_contract`.
const MONSTER_STEP_SIZE = 18
/// Defines the max clip planes value used by `miniquake.world_physics_contract`.
const MAX_CLIP_PLANES = 5
/// Defines the fly move bumps value used by `miniquake.world_physics_contract`.
const FLY_MOVE_BUMPS = 4
/// Defines the client max speed value used by `miniquake.world_physics_contract`.
const CLIENT_MAX_SPEED = 320
/// Defines the air acceleration cap value used by `miniquake.world_physics_contract`.
const AIR_ACCELERATION_CAP = 30
/// Defines the ideal pitch forward samples value used by `miniquake.world_physics_contract`.
const IDEAL_PITCH_FORWARD_SAMPLES = 6
/// Defines the production dispatch value used by `miniquake.world_physics_contract`.
const PRODUCTION_DISPATCH = "shared_nonclient"
/// Defines the force retouch order value used by `miniquake.world_physics_contract`.
const FORCE_RETOUCH_ORDER = "ordered"

/// Returns whether `miniquake.world_physics_contract` can onical text.
function canonicalText()
  return "world_physics_109_frozen_v1|hull_nodes=6|link_expand=1|item_expand=15|move_step=18|clip_planes=5|fly_bumps=4|stop_epsilon=0.1|client_maxspeed=320|air_cap=30|idealpitch_forward=6|production_dispatch=shared_nonclient|force_retouch=ordered|protocol=protocol15_frozen_v1|quakec=quakec_109_frozen_v1"
end function

/// Implements the `fnv1aText` operation for `miniquake.world_physics_contract` (fnv1a text).
/// @param text Text to parse or process.
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

/// Computes d fingerprint for `miniquake.world_physics_contract`.
function computedFingerprint()
  return fnv1aText(canonicalText())
end function

// Return component names derived from the active module state.
function componentNames()
  return ["world_hull", "world_link", "server_move", "server_physics", "server_user"]
end function

/// Implements the `validate` operation for `miniquake.world_physics_contract` (validate).
function validate()
  if computedFingerprint() != CONTRACT_FINGERPRINT then return false end if
  if len(componentNames()) != 5 then return false end if
  return true
end function
