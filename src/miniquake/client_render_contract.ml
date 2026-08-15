/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen source-guided client/view/effect/render hand-off contract.
*/
package miniquake.client_render_contract

import miniquake.constants as c

const CONTRACT_STATUS = "client_render_109_frozen_v1"
const CONTRACT_FINGERPRINT = 0x95e2b295
const BEAM_SEGMENT_LENGTH = 30
const BEAM_POOL_SIZE = 24
const VIEW_CSHIFT_COMPONENTS = 4
const BEAM_MODEL_HANDOFF = 1
const CHASE_REFDEF_PRESERVATION = 1
const EFRAG_FRAME_ACCUMULATION = 1
const PARTICLE_FLOAT_STORAGE = 1

// Return the stable compatibility-contract status string.
function inline status()
  return CONTRACT_STATUS
end function

// Return the stable compatibility-contract fingerprint.
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
