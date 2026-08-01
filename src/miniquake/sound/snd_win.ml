package miniquake.sound.snd_win

import miniquake.native as native
import miniquake.array_util as arrays

const SIS_SUCCESS = 0
const SIS_FAILURE = 1
const SIS_NOTAVAIL = 2

const WAV_BUFFERS = 64
const WAV_MASK = 0x3f
const WAV_BUFFER_SIZE = 0x0400
const SECONDARY_BUFFER_SIZE = 0x10000

struct WaveHeader
  index
  bufferOffset
  bufferLength
  prepared
  queued
  done
  generation
end struct

struct WindowsSoundState
  simulated
  sampleRate
  channels
  sampleBits
  sample16
  dmaSamples
  dmaPosition
  buffer
  headers
  blocked
  firstTime
  wavOnly
  directInitialized
  waveInitialized
  preferredDirect
  preferredWave
  directAttempted
  waveAttempted
  forcedDirectStatus
  sent
  completed
  nativeCompleted
  submittedBytes
  completedBytes
  underruns
  overruns
  shutdownCount
  resetCount
end struct

function createHeaders()
  builder = arrays.createArrayBuilder(WAV_BUFFERS)
  index = 0
  while index < WAV_BUFFERS
    arrays.pushArrayBuilder(builder, WaveHeader(index, index * WAV_BUFFER_SIZE, WAV_BUFFER_SIZE, false, false, false, 0))
    index = index + 1
  end while
  return arrays.finishArrayBuilder(builder)
end function

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

function hasArgument(arguments, wanted)
  if arguments is void then return false end if
  for each argument in arguments
    if argument == wanted then return true end if
  end for
  return false
end function

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

function completeHeaders(state, count)
  completedNow = 0
  while completedNow < count and completeOneHeader(state)
    completedNow = completedNow + 1
  end while
  return completedNow
end function

function refreshNativeHeaders(state)
  if state.simulated or not state.waveInitialized then return 0 end if
  nativeCompleted = native.audioCompleted()
  delta = nativeCompleted - state.nativeCompleted
  if delta < 0 then delta = 0 end if
  state.nativeCompleted = nativeCompleted
  return completeHeaders(state, delta)
end function

function queuedHeaders(state)
  refreshNativeHeaders(state)
  queued = state.sent - state.completed
  if queued < 0 then queued = 0 end if
  return queued
end function

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

function S_UnblockSound(state)
  if state.waveInitialized then state.blocked = state.blocked - 1 end if
  return state.blocked
end function

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

function SNDDMA_InitDirect(state)
  state.directAttempted = true
  state.directInitialized = false
  // The defined x64 target deliberately exposes waveOut only.  Returning the
  // original tri-state lets SNDDMA_Init preserve DirectSound fallback rules.
  if state.forcedDirectStatus == SIS_NOTAVAIL then return SIS_NOTAVAIL end if
  return SIS_FAILURE
end function

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

function nextHeader(state)
  return state.headers[state.sent & WAV_MASK]
end function

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

function SNDDMA_Shutdown(state)
  FreeSound(state)
  state.shutdownCount = state.shutdownCount + 1
  return true
end function
