/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.server_state.
*/
package miniquake.server_state

import miniquake.types as t
import miniquake.sizebuf as sz

/// Implements the `create` operation for `miniquake.server_state` (create).
/// @param maxClients The max clients input consumed by `create`.
function create(maxClients)
  clients = array(maxClients, void)
  return t.ServerState(false, 0.0, "", clients, [], sz.allocOverflowing(8192))
end function

/// Implements the `spawn` operation for `miniquake.server_state` (spawn).
/// @param state Mutable `miniquake.server_state` state used by `spawn`.
/// @param mapName Name of the map to load or inspect.
function spawn(state, mapName)
  state.active = true
  state.time = 1.0
  state.mapName = mapName
  state.entities = []
  sz.clear(state.reliableDatagram)
  return state
end function

/// Implements the `shutdown` operation for `miniquake.server_state` (shutdown).
/// @param state Mutable `miniquake.server_state` state used by `shutdown`.
function shutdown(state)
  state.active = false
  state.mapName = ""
  state.entities = []
  sz.clear(state.reliableDatagram)
end function

/// Implements the `frame` operation for `miniquake.server_state` (frame).
/// @param state Mutable `miniquake.server_state` state used by `frame`.
/// @param deltaTime Time value used by the operation.
function frame(state, deltaTime)
  if state.active then state.time = state.time + deltaTime end if
  return state.time
end function
