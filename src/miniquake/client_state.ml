/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.client_state.
*/
package miniquake.client_state

import miniquake.types as t
import miniquake.constants as c

/// Create the zero-initialized state for stats.
/// @param count Number of entries or units to process.
function zeroStats(count)
  return array(count, 0)
end function

/// Implements the `create` operation for `miniquake.client_state` (create).
function create()
  return t.ClientState(c.PROTOCOL_VERSION, 0.0, 0, t.Vec3(0.0, 0.0, 0.0), [], zeroStats(32), [])
end function

/// Implements the `clear` operation for `miniquake.client_state` (clear).
/// @param state Mutable `miniquake.client_state` state used by `clear`.
function clear(state)
  state.time = 0.0
  state.viewEntity = 0
  state.viewAngles = t.Vec3(0.0, 0.0, 0.0)
  state.entities = []
  state.stats = zeroStats(32)
  state.messages = []
  return state
end function

/// Add state for queue event.
/// @param state Mutable `miniquake.client_state` state used by `queueEvent`.
/// @param event Runtime event to process.
function queueEvent(state, event)
  state.messages = state.messages + [event]
end function
