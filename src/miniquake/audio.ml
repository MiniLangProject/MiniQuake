/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.audio.
*/
package miniquake.audio

import miniquake.types as t
import miniquake.native as native

// Create and initialize the module state.
function create()
  return t.AudioState(false, 0, 0, 0)
end function

// Initialize state for open.
function open(state, rate, channels, width)
  if native.audioOpen(rate, channels, width * 8) == 0 then return error(2400, "waveOutOpen failed") end if
  state.opened = true
  state.rate = rate
  state.channels = channels
  state.width = width
  return state
end function

// Submit state for submit.
function submit(state, data)
  if not state.opened then return error(2401, "audio device is not open") end if
  return native.audioSubmit(data, len(data)) != 0
end function

// Add state for queued.
function queued(state)
  if not state.opened then return 0 end if
  return native.audioQueued()
end function

// Update module state for the requested operation.
function reset(state)
  if not state.opened then return false end if
  return native.audioReset() != 0
end function

// Return the current backend playback position.
function position(state, sampleMask)
  if not state.opened then return 0 end if
  return native.audioPosition(sampleMask)
end function

// Return the number of buffers submitted to the backend.
function submitted(state)
  if not state.opened then return 0 end if
  return native.audioSubmitted()
end function

// Return completed for the active module state.
function completed(state)
  if not state.opened then return 0 end if
  return native.audioCompleted()
end function

// Return underruns for the active module state.
function underruns(state)
  return native.audioUnderruns()
end function

// Return header state derived from the active module state.
function headerState(state, index)
  if not state.opened then return 0 end if
  return native.audioHeaderState(index)
end function

// Return the backend queue capacity.
function capacity(state)
  if not state.opened then return 0 end if
  return native.audioCapacity()
end function

// Release state for close.
function close(state)
  if state.opened then native.audioClose() end if
  state.opened = false
end function
