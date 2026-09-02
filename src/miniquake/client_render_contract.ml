/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen source-guided client/view/effect/render hand-off contract.
*/
package miniquake.client_render_contract

import miniquake.constants as c

/// Defines the contract status value used by `miniquake.client_render_contract`.
const CONTRACT_STATUS = "client_render_109_frozen_v1"
/// Defines the contract fingerprint value used by `miniquake.client_render_contract`.
const CONTRACT_FINGERPRINT = 0x95e2b295
/// Defines the beam segment length value used by `miniquake.client_render_contract`.
const BEAM_SEGMENT_LENGTH = 30
/// Defines the beam pool size value used by `miniquake.client_render_contract`.
const BEAM_POOL_SIZE = 24
/// Defines the view cshift components value used by `miniquake.client_render_contract`.
const VIEW_CSHIFT_COMPONENTS = 4
/// Defines the beam model handoff value used by `miniquake.client_render_contract`.
const BEAM_MODEL_HANDOFF = 1
/// Defines the chase refdef preservation value used by `miniquake.client_render_contract`.
const CHASE_REFDEF_PRESERVATION = 1
/// Defines the efrag frame accumulation value used by `miniquake.client_render_contract`.
const EFRAG_FRAME_ACCUMULATION = 1
/// Defines the particle float storage value used by `miniquake.client_render_contract`.
const PARTICLE_FLOAT_STORAGE = 1

/// Returns the compatibility status reported by `miniquake.client_render_contract`.
function inline status()
  return CONTRACT_STATUS
end function

/// Returns the compatibility fingerprint for `miniquake.client_render_contract`.
function inline fingerprint()
  return CONTRACT_FINGERPRINT
end function

// Report whether max visible entities holds for the active state.
function maxVisibleEntities()
  return c.MAX_VISEDICTS
end function

// Return max temporary entities for the active module state.
function maxTemporaryEntities()
  return c.MAX_TEMP_ENTITIES
end function
