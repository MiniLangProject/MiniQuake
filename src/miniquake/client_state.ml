package miniquake.client_state

import miniquake.types as t
import miniquake.constants as c

function zeroStats(count)
  return array(count, 0)
end function

function create()
  return t.ClientState(c.PROTOCOL_VERSION, 0.0, 0, t.Vec3(0.0, 0.0, 0.0), [], zeroStats(32), [])
end function

function clear(state)
  state.time = 0.0
  state.viewEntity = 0
  state.viewAngles = t.Vec3(0.0, 0.0, 0.0)
  state.entities = []
  state.stats = zeroStats(32)
  state.messages = []
  return state
end function

function queueEvent(state, event)
  state.messages = state.messages + [event]
end function
