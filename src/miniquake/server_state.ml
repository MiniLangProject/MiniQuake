/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.server_state.
*/
package miniquake.server_state

import miniquake.types as t
import miniquake.sizebuf as sz

// Create and initialize the module state.
function create(maxClients)
  clients = array(maxClients, void)
  return t.ServerState(false, 0.0, "", clients, [], sz.allocOverflowing(8192))
end function

// Allocate and initialize the requested value.
function spawn(state, mapName)
  state.active = true
  state.time = 1.0
  state.mapName = mapName
  state.entities = []
  sz.clear(state.reliableDatagram)
  return state
end function

// Release state for shutdown.
function shutdown(state)
  state.active = false
  state.mapName = ""
  state.entities = []
  sz.clear(state.reliableDatagram)
end function

// Advance the requested value by one processing step.
function frame(state, deltaTime)
  if state.active then state.time = state.time + deltaTime end if
  return state.time
end function
