/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.client_state.
*/
package miniquake.client_state

import miniquake.types as t
import miniquake.constants as c

// Create the zero-initialized state for stats.
function zeroStats(count)
  return array(count, 0)
end function

// Create and initialize the module state.
function create()
  return t.ClientState(c.PROTOCOL_VERSION, 0.0, 0, t.Vec3(0.0, 0.0, 0.0), [], zeroStats(32), [])
end function

// Update module state for the requested operation.
function clear(state)
  state.time = 0.0
  state.viewEntity = 0
  state.viewAngles = t.Vec3(0.0, 0.0, 0.0)
  state.entities = []
  state.stats = zeroStats(32)
  state.messages = []
  return state
end function

// Add state for queue event.
function queueEvent(state, event)
  state.messages = state.messages + [event]
end function
