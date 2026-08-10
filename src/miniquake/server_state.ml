package miniquake.server_state

import miniquake.types as t
import miniquake.sizebuf as sz

function create(maxClients)
  clients = array(maxClients, void)
  return t.ServerState(false, 0.0, "", clients, [], sz.allocOverflowing(8192))
end function

function spawn(state, mapName)
  state.active = true
  state.time = 1.0
  state.mapName = mapName
  state.entities = []
  sz.clear(state.reliableDatagram)
  return state
end function

function shutdown(state)
  state.active = false
  state.mapName = ""
  state.entities = []
  sz.clear(state.reliableDatagram)
end function

function frame(state, deltaTime)
  if state.active then state.time = state.time + deltaTime end if
  return state.time
end function
