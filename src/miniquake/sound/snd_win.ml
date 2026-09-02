/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.snd_win.
*/
package miniquake.sound.snd_win

import miniquake.native as native
import miniquake.array_util as arrays

/// Defines the sis success value used by `miniquake.sound.snd_win`.
const SIS_SUCCESS = 0
/// Defines the sis failure value used by `miniquake.sound.snd_win`.
const SIS_FAILURE = 1
/// Defines the sis notavail value used by `miniquake.sound.snd_win`.
const SIS_NOTAVAIL = 2

/// Defines the wav buffers value used by `miniquake.sound.snd_win`.
const WAV_BUFFERS = 64
/// Defines the wav mask value used by `miniquake.sound.snd_win`.
const WAV_MASK = 0x3f
/// Defines the wav buffer size value used by `miniquake.sound.snd_win`.
const WAV_BUFFER_SIZE = 0x0400
/// Defines the secondary buffer size value used by `miniquake.sound.snd_win`.
const SECONDARY_BUFFER_SIZE = 0x10000

// Group the fields that describe one wave header.
struct WaveHeader
  /// Stores the index value in `miniquake.sound.snd_win.WaveHeader`.
  index
  /// Stores the buffer offset value in `miniquake.sound.snd_win.WaveHeader`.
  bufferOffset
  /// Stores the buffer length value in `miniquake.sound.snd_win.WaveHeader`.
  bufferLength
  /// Stores the prepared value in `miniquake.sound.snd_win.WaveHeader`.
  prepared
  /// Stores the queued value in `miniquake.sound.snd_win.WaveHeader`.
  queued
  /// Stores the done value in `miniquake.sound.snd_win.WaveHeader`.
  done
  /// Stores the generation value in `miniquake.sound.snd_win.WaveHeader`.
  generation
end struct

// Track mutable windows sound state across subsystem calls.
struct WindowsSoundState
  /// Stores the simulated value in `miniquake.sound.snd_win.WindowsSoundState`.
  simulated
  /// Stores the sample rate value in `miniquake.sound.snd_win.WindowsSoundState`.
  sampleRate
  /// Stores the channels value in `miniquake.sound.snd_win.WindowsSoundState`.
  channels
  /// Stores the sample bits value in `miniquake.sound.snd_win.WindowsSoundState`.
  sampleBits
  /// Stores the sample16 value in `miniquake.sound.snd_win.WindowsSoundState`.
  sample16
  /// Stores the dma samples value in `miniquake.sound.snd_win.WindowsSoundState`.
  dmaSamples
  /// Stores the dma position value in `miniquake.sound.snd_win.WindowsSoundState`.
  dmaPosition
  /// Stores the buffer value in `miniquake.sound.snd_win.WindowsSoundState`.
  buffer
  /// Stores the headers value in `miniquake.sound.snd_win.WindowsSoundState`.
  headers
  /// Stores the blocked value in `miniquake.sound.snd_win.WindowsSoundState`.
  blocked
  /// Stores the first time value in `miniquake.sound.snd_win.WindowsSoundState`.
  firstTime
  /// Stores the wav only value in `miniquake.sound.snd_win.WindowsSoundState`.
  wavOnly
  /// Stores the direct initialized value in `miniquake.sound.snd_win.WindowsSoundState`.
  directInitialized
  /// Stores the wave initialized value in `miniquake.sound.snd_win.WindowsSoundState`.
  waveInitialized
  /// Stores the preferred direct value in `miniquake.sound.snd_win.WindowsSoundState`.
  preferredDirect
  /// Stores the preferred wave value in `miniquake.sound.snd_win.WindowsSoundState`.
  preferredWave
  /// Stores the direct attempted value in `miniquake.sound.snd_win.WindowsSoundState`.
  directAttempted
  /// Stores the wave attempted value in `miniquake.sound.snd_win.WindowsSoundState`.
  waveAttempted
  /// Stores the forced direct status value in `miniquake.sound.snd_win.WindowsSoundState`.
  forcedDirectStatus
  /// Stores the sent value in `miniquake.sound.snd_win.WindowsSoundState`.
  sent
  /// Stores the completed value in `miniquake.sound.snd_win.WindowsSoundState`.
  completed
  /// Stores the native completed value in `miniquake.sound.snd_win.WindowsSoundState`.
  nativeCompleted
  /// Stores the submitted bytes value in `miniquake.sound.snd_win.WindowsSoundState`.
  submittedBytes
  /// Stores the completed bytes value in `miniquake.sound.snd_win.WindowsSoundState`.
  completedBytes
  /// Stores the underruns value in `miniquake.sound.snd_win.WindowsSoundState`.
  underruns
  /// Stores the overruns value in `miniquake.sound.snd_win.WindowsSoundState`.
  overruns
  /// Stores the shutdown count value in `miniquake.sound.snd_win.WindowsSoundState`.
  shutdownCount
  /// Stores the reset count value in `miniquake.sound.snd_win.WindowsSoundState`.
  resetCount
end struct

// Create and initialize headers.
function createHeaders()
  builder = arrays.createArrayBuilder(WAV_BUFFERS)
  index = 0
  while index < WAV_BUFFERS
    arrays.pushArrayBuilder(builder, WaveHeader(index, index * WAV_BUFFER_SIZE, WAV_BUFFER_SIZE, false, false, false, 0))
    index = index + 1
  end while
  return arrays.finishArrayBuilder(builder)
end function

/// Implements the `create` operation for `miniquake.sound.snd_win` (create).
/// @param simulated The simulated input consumed by `create`.
/// @param sampleRate The sample rate input consumed by `create`.
function create(simulated, sampleRate)
  if sampleRate <= 0 then sampleRate = 11025 end if
  return WindowsSoundState(
    simulated,
    sampleRate,
    2,
    16,
    1,
    SECONDARY_BUFFER_SIZE / 2,
    0,
    bytes(SECONDARY_BUFFER_SIZE),
    createHeaders(),
    0,
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    SIS_FAILURE,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  )
end function

/// Report whether argument.
/// @param arguments Command-line arguments to inspect or execute.
/// @param wanted The wanted input consumed by `hasArgument`.
function hasArgument(arguments, wanted)
  if arguments is void then return false end if
  for each argument in arguments
    if argument == wanted then return true end if
  end for
  return false
end function

/// Implements the `prepareHeaders` operation for `miniquake.sound.snd_win` (prepare headers).
/// @param state Mutable `miniquake.sound.snd_win` state used by `prepareHeaders`.
function prepareHeaders(state)
  index = 0
  while index < len(state.headers)
    header = state.headers[index]
    header.bufferLength = WAV_BUFFER_SIZE
    header.prepared = true
    header.queued = false
    header.done = false
    header.generation = 0
    index = index + 1
  end while
end function

/// Implements the `unprepareHeaders` operation for `miniquake.sound.snd_win` (unprepare headers).
/// @param state Mutable `miniquake.sound.snd_win` state used by `unprepareHeaders`.
function unprepareHeaders(state)
  index = 0
  while index < len(state.headers)
    header = state.headers[index]
    header.prepared = false
    header.queued = false
    header.done = false
    index = index + 1
  end while
end function

/// Handle one header and update the associated state.
/// @param state Mutable `miniquake.sound.snd_win` state used by `completeOneHeader`.
function completeOneHeader(state)
  if state.completed >= state.sent then return false end if
  header = state.headers[state.completed & WAV_MASK]
  if header.queued then
    header.queued = false
    header.done = true
    state.completedBytes = state.completedBytes + header.bufferLength
  end if
  state.completed = state.completed + 1
  return true
end function

/// Handle headers and update the associated state.
/// @param state Mutable `miniquake.sound.snd_win` state used by `completeHeaders`.
/// @param count Number of entries or units to process.
function completeHeaders(state, count)
  completedNow = 0
  while completedNow < count and completeOneHeader(state)
    completedNow = completedNow + 1
  end while
  return completedNow
end function

/// Implements the `refreshNativeHeaders` operation for `miniquake.sound.snd_win` (refresh native headers).
/// @param state Mutable `miniquake.sound.snd_win` state used by `refreshNativeHeaders`.
function refreshNativeHeaders(state)
  if state.simulated or not state.waveInitialized then return 0 end if
  nativeCompleted = native.audioCompleted()
  delta = nativeCompleted - state.nativeCompleted
  if delta < 0 then delta = 0 end if
  state.nativeCompleted = nativeCompleted
  return completeHeaders(state, delta)
end function

/// Add state for queued headers.
/// @param state Mutable `miniquake.sound.snd_win` state used by `queuedHeaders`.
function queuedHeaders(state)
  refreshNativeHeaders(state)
  queued = state.sent - state.completed
  if queued < 0 then queued = 0 end if
  return queued
end function

/// Apply the Quake-compatible s block sound behavior.
/// @param state Mutable `miniquake.sound.snd_win` state used by `S_BlockSound`.
function S_BlockSound(state)
  if not state.waveInitialized then return state.blocked end if
  state.blocked = state.blocked + 1
  if state.blocked == 1 then
    state.resetCount = state.resetCount + 1
    if state.simulated then
      completeHeaders(state, state.sent - state.completed)
    else
      native.audioReset()
      refreshNativeHeaders(state)
    end if
  end if
  return state.blocked
end function

/// Apply the Quake-compatible s unblock sound behavior.
/// @param state Mutable `miniquake.sound.snd_win` state used by `S_UnblockSound`.
function S_UnblockSound(state)
  if state.waveInitialized then state.blocked = state.blocked - 1 end if
  return state.blocked
end function

/// Release state for free sound.
/// @param state Mutable `miniquake.sound.snd_win` state used by `FreeSound`.
function FreeSound(state)
  if state.waveInitialized and not state.simulated then
    refreshNativeHeaders(state)
    native.audioClose()
  end if
  unprepareHeaders(state)
  state.directInitialized = false
  state.waveInitialized = false
  state.dmaPosition = 0
  state.blocked = 0
  return true
end function

/// Mirror Quake's SNDDMA_InitDirect routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_InitDirect`.
function SNDDMA_InitDirect(state)
  state.directAttempted = true
  state.directInitialized = false
  // The defined x64 target deliberately exposes waveOut only.  Returning the
  // original tri-state lets SNDDMA_Init preserve DirectSound fallback rules.
  if state.forcedDirectStatus == SIS_NOTAVAIL then return SIS_NOTAVAIL end if
  return SIS_FAILURE
end function

/// Mirror Quake's SNDDMA_InitWav routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_InitWav`.
function SNDDMA_InitWav(state)
  state.waveAttempted = true
  opened = true
  if not state.simulated then
    opened = native.audioOpen(state.sampleRate, state.channels, state.sampleBits) != 0
  end if
  if not opened then
    state.waveInitialized = false
    return false
  end if

  state.sample16 = state.sampleBits / 8 - 1
  state.dmaSamples = SECONDARY_BUFFER_SIZE / (state.sampleBits / 8)
  state.dmaPosition = 0
  state.sent = 0
  state.completed = 0
  state.nativeCompleted = 0
  state.submittedBytes = 0
  state.completedBytes = 0
  state.underruns = 0
  state.overruns = 0
  state.buffer = bytes(SECONDARY_BUFFER_SIZE)
  prepareHeaders(state)
  state.waveInitialized = true
  return true
end function

/// Mirror Quake's SNDDMA_Init routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Init`.
/// @param arguments Command-line arguments to inspect or execute.
function SNDDMA_Init(state, arguments)
  if hasArgument(arguments, "-nosound") then return 0 end if
  if hasArgument(arguments, "-wavonly") then state.wavOnly = true end if
  state.directInitialized = false
  state.waveInitialized = false
  state.directAttempted = false
  state.waveAttempted = false
  status = SIS_FAILURE

  if not state.wavOnly and (state.firstTime or state.preferredDirect) then
    status = SNDDMA_InitDirect(state)
    if status == SIS_SUCCESS then
      state.directInitialized = true
      state.preferredDirect = true
    else
      state.preferredDirect = false
    end if
  end if

  if not state.directInitialized and status != SIS_NOTAVAIL then
    if state.firstTime or state.preferredWave then
      state.preferredWave = SNDDMA_InitWav(state)
    end if
  end if
  state.firstTime = false
  if not state.directInitialized and not state.waveInitialized then return 0 end if
  return 1
end function

/// Mirror Quake's SNDDMA_GetDMAPos routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_GetDMAPos`.
function SNDDMA_GetDMAPos(state)
  if not state.waveInitialized and not state.directInitialized then return 0 end if
  if state.simulated then
    state.dmaPosition = ((state.sent * WAV_BUFFER_SIZE) >> state.sample16) & (state.dmaSamples - 1)
  else
    state.dmaPosition = native.audioPosition(state.dmaSamples - 1)
    refreshNativeHeaders(state)
  end if
  return state.dmaPosition
end function

/// Return next header for the active module state.
/// @param state Mutable `miniquake.sound.snd_win` state used by `nextHeader`.
function nextHeader(state)
  return state.headers[state.sent & WAV_MASK]
end function

/// Transfer data for copy submission.
/// @param state Mutable `miniquake.sound.snd_win` state used by `copySubmission`.
/// @param data Input data consumed by the operation.
/// @param header The header input consumed by `copySubmission`.
function copySubmission(state, data, header)
  sourceOffset = 0
  // The original waveOut headers point at distinct 1024-byte regions of the
  // circular DMA buffer. Accept a single convenience block too, but when a
  // full ring is supplied copy the region owned by this exact header.
  if len(data) >= header.bufferOffset + WAV_BUFFER_SIZE then
    sourceOffset = header.bufferOffset
  end if
  count = len(data) - sourceOffset
  if count > WAV_BUFFER_SIZE then count = WAV_BUFFER_SIZE end if
  if count < 0 then count = 0 end if
  index = 0
  while index < count
    state.buffer[header.bufferOffset + index] = data[sourceOffset + index]
    index = index + 1
  end while
  header.bufferLength = count
  return count
end function

/// Mirror Quake's SNDDMA_Submit routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Submit`.
/// @param data Input data consumed by the operation.
function SNDDMA_Submit(state, data)
  if not state.waveInitialized or state.blocked > 0 then return false end if
  refreshNativeHeaders(state)
  if state.sent > 0 and state.completed == state.sent then state.underruns = state.underruns + 1 end if
  targetQueued = 4 << state.sample16
  submitted = false
  while state.sent - state.completed < targetQueued
    header = nextHeader(state)
    if header.queued and not header.done then
      state.overruns = state.overruns + 1
      return submitted
    end if

    count = copySubmission(state, data, header)
    if count <= 0 then return submitted end if
    if not state.simulated then
      nativeResult = native.audioSubmit(slice(data, 0, count), count)
      if nativeResult == 0 then
        state.overruns = state.overruns + 1
        return submitted
      end if
    end if
    header.prepared = true
    header.queued = true
    header.done = false
    header.generation = header.generation + 1
    state.sent = state.sent + 1
    state.submittedBytes = state.submittedBytes + count
    submitted = true
  end while
  return submitted
end function

/// Mirror Quake's SNDDMA_Shutdown routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Shutdown`.
function SNDDMA_Shutdown(state)
  FreeSound(state)
  state.shutdownCount = state.shutdownCount + 1
  return true
end function
