package miniquake.audio

import miniquake.types as t
import miniquake.native as native

function create()
  return t.AudioState(false, 0, 0, 0)
end function

function open(state, rate, channels, width)
  if native.audioOpen(rate, channels, width * 8) == 0 then return error(2400, "waveOutOpen failed") end if
  state.opened = true
  state.rate = rate
  state.channels = channels
  state.width = width
  return state
end function

function submit(state, data)
  if not state.opened then return error(2401, "audio device is not open") end if
  return native.audioSubmit(data, len(data)) != 0
end function

function queued(state)
  if not state.opened then return 0 end if
  return native.audioQueued()
end function

function reset(state)
  if not state.opened then return false end if
  return native.audioReset() != 0
end function

function position(state, sampleMask)
  if not state.opened then return 0 end if
  return native.audioPosition(sampleMask)
end function

function submitted(state)
  if not state.opened then return 0 end if
  return native.audioSubmitted()
end function

function completed(state)
  if not state.opened then return 0 end if
  return native.audioCompleted()
end function

function underruns(state)
  return native.audioUnderruns()
end function

function headerState(state, index)
  if not state.opened then return 0 end if
  return native.audioHeaderState(index)
end function

function capacity(state)
  if not state.opened then return 0 end if
  return native.audioCapacity()
end function

function close(state)
  if state.opened then native.audioClose() end if
  state.opened = false
end function
