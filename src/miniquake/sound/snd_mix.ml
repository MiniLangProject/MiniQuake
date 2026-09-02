/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.snd_mix.
*/
package miniquake.sound.snd_mix

import miniquake.sound.snd_mem as sndmem
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.types as t
import miniquake.array_util as arrays

/// Defines the paintbuffer size value used by `miniquake.sound.snd_mix`.
const PAINTBUFFER_SIZE = 512
/// Defines the max channels value used by `miniquake.sound.snd_mix`.
const MAX_CHANNELS = 128

// Track storage and runtime state for one DMA sound buffer.
struct DmaSoundBuffer
  /// Stores the game alive value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  gameAlive
  /// Stores the sound alive value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  soundAlive
  /// Stores the split buffer value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  splitBuffer
  /// Stores the channels value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  channels
  /// Stores the samples value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  samples
  /// Stores the submission chunk value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  submissionChunk
  /// Stores the sample position value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  samplePosition
  /// Stores the sample bits value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  sampleBits
  /// Stores the speed value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  speed
  /// Stores the buffer value in `miniquake.sound.snd_mix.DmaSoundBuffer`.
  buffer
end struct

// Track storage and runtime state for one sound channel.
struct SoundChannel
  /// Stores the sfx value in `miniquake.sound.snd_mix.SoundChannel`.
  sfx
  /// Stores the left volume value in `miniquake.sound.snd_mix.SoundChannel`.
  leftVolume
  /// Stores the right volume value in `miniquake.sound.snd_mix.SoundChannel`.
  rightVolume
  /// Stores the end time value in `miniquake.sound.snd_mix.SoundChannel`.
  endTime
  /// Stores the position value in `miniquake.sound.snd_mix.SoundChannel`.
  position
  /// Stores the looping value in `miniquake.sound.snd_mix.SoundChannel`.
  looping
  /// Stores the entity number value in `miniquake.sound.snd_mix.SoundChannel`.
  entityNumber
  /// Stores the entity channel value in `miniquake.sound.snd_mix.SoundChannel`.
  entityChannel
  /// Stores the origin value in `miniquake.sound.snd_mix.SoundChannel`.
  origin
  /// Stores the distance multiplier value in `miniquake.sound.snd_mix.SoundChannel`.
  distanceMultiplier
  /// Stores the master volume value in `miniquake.sound.snd_mix.SoundChannel`.
  masterVolume
end struct

// Track mutable mix state across subsystem calls.
struct MixState
  /// Stores the dma value in `miniquake.sound.snd_mix.MixState`.
  dma
  /// Stores the channels value in `miniquake.sound.snd_mix.MixState`.
  channels
  /// Stores the total channels value in `miniquake.sound.snd_mix.MixState`.
  totalChannels
  /// Stores the sound time value in `miniquake.sound.snd_mix.MixState`.
  soundTime
  /// Stores the painted time value in `miniquake.sound.snd_mix.MixState`.
  paintedTime
  /// Stores the volume value in `miniquake.sound.snd_mix.MixState`.
  volume
  /// Stores the paint buffer value in `miniquake.sound.snd_mix.MixState`.
  paintBuffer
  /// Stores the scale table value in `miniquake.sound.snd_mix.MixState`.
  scaleTable
  /// Stores the linear source value in `miniquake.sound.snd_mix.MixState`.
  linearSource
  /// Stores the linear count value in `miniquake.sound.snd_mix.MixState`.
  linearCount
  /// Stores the linear output value in `miniquake.sound.snd_mix.MixState`.
  linearOutput
  /// Stores the transfer volume value in `miniquake.sound.snd_mix.MixState`.
  transferVolume
end struct

/// Create and initialize dma.
/// @param speed The speed input consumed by `createDma`.
/// @param sampleBits The sample bits input consumed by `createDma`.
/// @param channels Number of interleaved audio channels.
/// @param samples The samples input consumed by `createDma`.
function createDma(speed, sampleBits, channels, samples)
  if speed <= 0 then speed = 22050 end if
  if sampleBits != 8 and sampleBits != 16 then sampleBits = 16 end if
  if channels != 1 and channels != 2 then channels = 2 end if
  if samples <= 0 then samples = 32768 end if
  return DmaSoundBuffer(
    true,
    true,
    false,
    channels,
    samples,
    1,
    0,
    sampleBits,
    speed,
    bytes(samples * sampleBits / 8),
  )
end function

// Create and initialize channel.
function createChannel()
  return SoundChannel(
    void,
    0,
    0,
    0,
    0,
    -1,
    0,
    0,
    t.Vec3(0.0, 0.0, 0.0),
    0.0,
    0,
  )
end function

/// Update module state for channel.
/// @param channel The channel input consumed by `resetChannel`.
function resetChannel(channel)
  channel.sfx = void
  channel.leftVolume = 0
  channel.rightVolume = 0
  channel.endTime = 0
  channel.position = 0
  channel.looping = -1
  channel.entityNumber = 0
  channel.entityChannel = 0
  channel.origin = t.Vec3(0.0, 0.0, 0.0)
  channel.distanceMultiplier = 0.0
  channel.masterVolume = 0
  return channel
end function

/// Creates state for `miniquake.sound.snd_mix`.
/// @param dma The dma input consumed by `createState`.
function createState(dma)
  channelBuilder = arrays.createArrayBuilder(MAX_CHANNELS)
  index = 0
  while index < MAX_CHANNELS
    arrays.pushArrayBuilder(channelBuilder, createChannel())
    index = index + 1
  end while
  state = MixState(
    dma,
    arrays.finishArrayBuilder(channelBuilder),
    12,
    0,
    0,
    0.7,
    arrays.makeFilledArray(PAINTBUFFER_SIZE * 2, 0),
    arrays.makeFilledArray(32 * 256, 0),
    0,
    0,
    0,
    0,
  )
  SND_InitScaletable(state)
  return state
end function

/// Return signed byte derived from the active module state.
/// @param value Value consumed by `signedByte`.
function signedByte(value)
  value = value & 255
  if value >= 128 then return value - 256 end if
  return value
end function

/// Implements the `soundI32` operation for `miniquake.sound.snd_mix` (sound i32).
/// @param value Value consumed by `soundI32`.
function soundI32(value)
  result = value & 0xffffffff
  if result >= 0x80000000 then result = result - 0x100000000 end if
  return result
end function

/// Clamps 16 for `miniquake.sound.snd_mix`.
/// @param value Value consumed by `clamp16`.
function clamp16(value)
  if value > 32767 then return 32767 end if
  if value < -32768 then return -32768 end if
  return native.trunc(value)
end function

/// Mirror Quake's SND_InitScaletable routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `SND_InitScaletable`.
function SND_InitScaletable(state)
  row = 0
  while row < 32
    value = 0
    while value < 256
      state.scaleTable[row * 256 + value] = signedByte(value) * row * 8
      value = value + 1
    end while
    row = row + 1
  end while
  return state.scaleTable
end function

/// Mirror Quake's Snd_WriteLinearBlastStereo16 routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `Snd_WriteLinearBlastStereo16`.
function Snd_WriteLinearBlastStereo16(state)
  index = 0
  while index < state.linearCount
    sample = state.paintBuffer[state.linearSource + index]
    value = soundI32(sample * state.transferVolume) >> 8
    bio.putI16(state.dma.buffer, (state.linearOutput + index) * 2, clamp16(value))
    index = index + 1
  end while
  return state.linearCount
end function

/// Apply the Quake-compatible s transfer stereo16 behavior.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `S_TransferStereo16`.
/// @param endTime Time value used by the operation.
function S_TransferStereo16(state, endTime)
  state.transferVolume = native.trunc(state.volume * 256.0)
  state.linearSource = 0
  localPaintedTime = state.paintedTime
  writtenFrames = 0

  while localPaintedTime < endTime
    ringFrames = state.dma.samples >> 1
    localPosition = localPaintedTime & (ringFrames - 1)
    state.linearOutput = localPosition << 1
    linearFrames = ringFrames - localPosition
    if localPaintedTime + linearFrames > endTime then linearFrames = endTime - localPaintedTime end if
    state.linearCount = linearFrames << 1
    Snd_WriteLinearBlastStereo16(state)
    state.linearSource = state.linearSource + state.linearCount
    localPaintedTime = localPaintedTime + linearFrames
    writtenFrames = writtenFrames + linearFrames
  end while
  return writtenFrames
end function

/// Apply the Quake-compatible s transfer paint buffer behavior.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `S_TransferPaintBuffer`.
/// @param endTime Time value used by the operation.
function S_TransferPaintBuffer(state, endTime)
  if state.dma.sampleBits == 16 and state.dma.channels == 2 then
    return S_TransferStereo16(state, endTime)
  end if

  sourceIndex = 0
  count = (endTime - state.paintedTime) * state.dma.channels
  outputMask = state.dma.samples - 1
  outputIndex = (state.paintedTime * state.dma.channels) & outputMask
  step = 3 - state.dma.channels
  transferVolume = native.trunc(state.volume * 256.0)
  written = 0
  while written < count
    value = soundI32(state.paintBuffer[sourceIndex] * transferVolume) >> 8
    value = clamp16(value)
    if state.dma.sampleBits == 16 then
      bio.putI16(state.dma.buffer, outputIndex * 2, value)
    else
      state.dma.buffer[outputIndex] = ((value >> 8) + 128) & 255
    end if
    sourceIndex = sourceIndex + step
    outputIndex = (outputIndex + 1) & outputMask
    written = written + 1
  end while
  return written
end function

/// Mirror Quake's SND_PaintChannelFrom8 routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `SND_PaintChannelFrom8`.
/// @param channel The channel input consumed by `SND_PaintChannelFrom8`.
/// @param cache The cache input consumed by `SND_PaintChannelFrom8`.
/// @param count Number of entries or units to process.
function SND_PaintChannelFrom8(state, channel, cache, count)
  if channel.leftVolume > 255 then channel.leftVolume = 255 end if
  if channel.rightVolume > 255 then channel.rightVolume = 255 end if
  leftRow = (channel.leftVolume >> 3) * 256
  rightRow = (channel.rightVolume >> 3) * 256
  index = 0
  while index < count
    source = cache.data[channel.position + index]
    state.paintBuffer[index * 2] = soundI32(state.paintBuffer[index * 2] + state.scaleTable[leftRow + source])
    state.paintBuffer[index * 2 + 1] = soundI32(state.paintBuffer[index * 2 + 1] + state.scaleTable[rightRow + source])
    index = index + 1
  end while
  channel.position = channel.position + count
  return count
end function

/// Mirror Quake's SND_PaintChannelFrom16 routine and its observable state changes.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `SND_PaintChannelFrom16`.
/// @param channel The channel input consumed by `SND_PaintChannelFrom16`.
/// @param cache The cache input consumed by `SND_PaintChannelFrom16`.
/// @param count Number of entries or units to process.
function SND_PaintChannelFrom16(state, channel, cache, count)
  index = 0
  while index < count
    sample = bio.i16(cache.data, (channel.position + index) * 2)
    left = soundI32(sample * channel.leftVolume) >> 8
    right = soundI32(sample * channel.rightVolume) >> 8
    state.paintBuffer[index * 2] = soundI32(state.paintBuffer[index * 2] + left)
    state.paintBuffer[index * 2 + 1] = soundI32(state.paintBuffer[index * 2 + 1] + right)
    index = index + 1
  end while
  channel.position = channel.position + count
  return count
end function

/// Update module state for paint buffer.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `clearPaintBuffer`.
/// @param frameCount Number of entries or units to process.
function clearPaintBuffer(state, frameCount)
  index = 0
  while index < frameCount * 2
    state.paintBuffer[index] = 0
    index = index + 1
  end while
end function

/// Apply the Quake-compatible s paint channels behavior.
/// @param state Mutable `miniquake.sound.snd_mix` state used by `S_PaintChannels`.
/// @param endTime Time value used by the operation.
function S_PaintChannels(state, endTime)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if endTime < state.paintedTime then return error(2470, "S_PaintChannels: end before painted time") end if
  while state.paintedTime < endTime
    blockEnd = endTime
    if blockEnd - state.paintedTime > PAINTBUFFER_SIZE then blockEnd = state.paintedTime + PAINTBUFFER_SIZE end if
    clearPaintBuffer(state, blockEnd - state.paintedTime)

    channelIndex = 0
    while channelIndex < state.totalChannels and channelIndex < len(state.channels)
      channel = state.channels[channelIndex]
      if channel.sfx is not void and (channel.leftVolume != 0 or channel.rightVolume != 0) then
        cache = channel.sfx.cache
        if cache is not void then
          localTime = state.paintedTime
          while localTime < blockEnd and channel.sfx is not void
            count = blockEnd - localTime
            if channel.endTime < blockEnd then count = channel.endTime - localTime else count = blockEnd - localTime end if
            if count > 0 then
              if cache.width == 1 then
                SND_PaintChannelFrom8(state, channel, cache, count)
              else
                SND_PaintChannelFrom16(state, channel, cache, count)
              end if
              localTime = localTime + count
            end if

            if localTime >= channel.endTime then
              if cache.loopStart >= 0 then
                channel.position = cache.loopStart
                channel.endTime = localTime + cache.length - channel.position
              else
                channel.sfx = void
              end if
            end if
          end while
        end if
      end if
      channelIndex = channelIndex + 1
    end while

    S_TransferPaintBuffer(state, blockEnd)
    state.paintedTime = blockEnd
  end while
  return state.paintedTime
end function
