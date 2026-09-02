/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.snd_dma.
*/
package miniquake.sound.snd_dma

import miniquake.sound.snd_mem as sndmem
import miniquake.sound.snd_mix as sndmix
import miniquake.types as t
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.array_util as arrays
import miniquake.common as common

/// Defines the max sfx value used by `miniquake.sound.snd_dma`.
const MAX_SFX = 512
/// Defines the max channels value used by `miniquake.sound.snd_dma`.
const MAX_CHANNELS = 128
/// Defines the max dynamic channels value used by `miniquake.sound.snd_dma`.
const MAX_DYNAMIC_CHANNELS = 8
/// Defines the num ambients value used by `miniquake.sound.snd_dma`.
const NUM_AMBIENTS = 4
/// Defines the dynamic first value used by `miniquake.sound.snd_dma`.
const DYNAMIC_FIRST = NUM_AMBIENTS
/// Defines the static first value used by `miniquake.sound.snd_dma`.
const STATIC_FIRST = NUM_AMBIENTS + MAX_DYNAMIC_CHANNELS
/// Defines the sound nominal clip distance value used by `miniquake.sound.snd_dma`.
const SOUND_NOMINAL_CLIP_DISTANCE = 1000.0
/// Defines the default sound packet volume value used by `miniquake.sound.snd_dma`.
const DEFAULT_SOUND_PACKET_VOLUME = 255
/// Defines the default sound packet attenuation value used by `miniquake.sound.snd_dma`.
const DEFAULT_SOUND_PACKET_ATTENUATION = 1.0

// Own the coordinated data required by the sound system.
struct SoundSystem
  /// Stores the filesystem value in `miniquake.sound.snd_dma.SoundSystem`.
  filesystem
  /// Stores the mix state value in `miniquake.sound.snd_dma.SoundSystem`.
  mixState
  /// Stores the initialized value in `miniquake.sound.snd_dma.SoundSystem`.
  initialized
  /// Stores the started value in `miniquake.sound.snd_dma.SoundSystem`.
  started
  /// Stores the blocked value in `miniquake.sound.snd_dma.SoundSystem`.
  blocked
  /// Stores the ambient enabled value in `miniquake.sound.snd_dma.SoundSystem`.
  ambientEnabled
  /// Stores the fake dma value in `miniquake.sound.snd_dma.SoundSystem`.
  fakeDma
  /// Stores the dma opened value in `miniquake.sound.snd_dma.SoundSystem`.
  dmaOpened
  /// Stores the fake dma updates value in `miniquake.sound.snd_dma.SoundSystem`.
  fakeDmaUpdates
  /// Stores the no sound value in `miniquake.sound.snd_dma.SoundSystem`.
  noSound
  /// Stores the precache enabled value in `miniquake.sound.snd_dma.SoundSystem`.
  precacheEnabled
  /// Stores the load as8 bit value in `miniquake.sound.snd_dma.SoundSystem`.
  loadAs8Bit
  /// Stores the ambient level value in `miniquake.sound.snd_dma.SoundSystem`.
  ambientLevel
  /// Stores the ambient fade value in `miniquake.sound.snd_dma.SoundSystem`.
  ambientFade
  /// Stores the no extra update value in `miniquake.sound.snd_dma.SoundSystem`.
  noExtraUpdate
  /// Stores the show value in `miniquake.sound.snd_dma.SoundSystem`.
  show
  /// Stores the mix ahead value in `miniquake.sound.snd_dma.SoundSystem`.
  mixAhead
  /// Stores the desired speed value in `miniquake.sound.snd_dma.SoundSystem`.
  desiredSpeed
  /// Stores the desired bits value in `miniquake.sound.snd_dma.SoundSystem`.
  desiredBits
  /// Stores the known sfx value in `miniquake.sound.snd_dma.SoundSystem`.
  knownSfx
  /// Stores the ambient sfx value in `miniquake.sound.snd_dma.SoundSystem`.
  ambientSfx
  /// Stores the listener origin value in `miniquake.sound.snd_dma.SoundSystem`.
  listenerOrigin
  /// Stores the listener forward value in `miniquake.sound.snd_dma.SoundSystem`.
  listenerForward
  /// Stores the listener right value in `miniquake.sound.snd_dma.SoundSystem`.
  listenerRight
  /// Stores the listener up value in `miniquake.sound.snd_dma.SoundSystem`.
  listenerUp
  /// Stores the listener entity value in `miniquake.sound.snd_dma.SoundSystem`.
  listenerEntity
  /// Stores the old sample position value in `miniquake.sound.snd_dma.SoundSystem`.
  oldSamplePosition
  /// Stores the completed buffers value in `miniquake.sound.snd_dma.SoundSystem`.
  completedBuffers
  /// Stores the random seed value in `miniquake.sound.snd_dma.SoundSystem`.
  randomSeed
  /// Stores the play hash value in `miniquake.sound.snd_dma.SoundSystem`.
  playHash
  /// Stores the play volume hash value in `miniquake.sound.snd_dma.SoundSystem`.
  playVolumeHash
  /// Stores the submit calls value in `miniquake.sound.snd_dma.SoundSystem`.
  submitCalls
  /// Stores the paint calls value in `miniquake.sound.snd_dma.SoundSystem`.
  paintCalls
  /// Stores the last paint time value in `miniquake.sound.snd_dma.SoundSystem`.
  lastPaintTime
  /// Stores the accumulate calls value in `miniquake.sound.snd_dma.SoundSystem`.
  accumulateCalls
  /// Stores the registered commands value in `miniquake.sound.snd_dma.SoundSystem`.
  registeredCommands
  /// Stores the registered cvars value in `miniquake.sound.snd_dma.SoundSystem`.
  registeredCvars
end struct

/// Implements the `create` operation for `miniquake.sound.snd_dma` (create).
/// @param filesystem The filesystem input consumed by `create`.
/// @param sampleRate The sample rate input consumed by `create`.
function create(filesystem, sampleRate)
  dma = sndmix.createDma(sampleRate, 16, 2, 32768)
  return SoundSystem(
    filesystem,
    sndmix.createState(dma),
    false,
    false,
    0,
    true,
    false,
    false,
    15,
    false,
    true,
    false,
    0.3,
    100.0,
    false,
    false,
    0.1,
    11025,
    16,
    [],
    [void, void, void, void],
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    1,
    0,
    0,
    1,
    345,
    543,
    0,
    0,
    0,
    0,
    [],
    [],
  )
end function

/// sound.h platform-facing API.  The native DLL owns waveOut handles; the
/// portable sound core only controls its lifetime and supplies PCM blocks.
/// @param system The system input consumed by `SNDDMA_Init`.
function SNDDMA_Init(system)
  if system.fakeDma then
    system.dmaOpened = true
    return true
  end if
  dma = system.mixState.dma
  system.dmaOpened = native.audioOpen(dma.speed, dma.channels, dma.sampleBits) != 0
  return system.dmaOpened
end function

/// Mirror Quake's SNDDMA_GetDMAPos routine and its observable state changes.
/// @param system The system input consumed by `SNDDMA_GetDMAPos`.
function inline SNDDMA_GetDMAPos(system)
  return system.mixState.dma.samplePosition
end function

/// Mirror Quake's SNDDMA_Submit routine and its observable state changes.
/// @param system The system input consumed by `SNDDMA_Submit`.
function SNDDMA_Submit(system)
  system.submitCalls = system.submitCalls + 1
  if system.fakeDma then return true end if
  if not system.dmaOpened then return false end if
  dma = system.mixState.dma
  return native.audioSubmit(dma.buffer, len(dma.buffer)) != 0
end function

/// Mirror Quake's SNDDMA_Shutdown routine and its observable state changes.
/// @param system The system input consumed by `SNDDMA_Shutdown`.
function SNDDMA_Shutdown(system)
  if system.dmaOpened and not system.fakeDma then native.audioClose() end if
  system.dmaOpened = false
  return true
end function

/// Apply the Quake-compatible s init paint channels behavior.
/// @param system The system input consumed by `S_InitPaintChannels`.
function S_InitPaintChannels(system)
  sndmix.clearPaintBuffer(system.mixState, sndmix.PAINTBUFFER_SIZE)
  return sndmix.SND_InitScaletable(system.mixState)
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

/// Apply the Quake-compatible s ambient off behavior.
/// @param system The system input consumed by `S_AmbientOff`.
function S_AmbientOff(system)
  system.ambientEnabled = false
  return false
end function

/// Apply the Quake-compatible s ambient on behavior.
/// @param system The system input consumed by `S_AmbientOn`.
function S_AmbientOn(system)
  system.ambientEnabled = true
  return true
end function

/// Apply the Quake-compatible s sound info f behavior.
/// @param system The system input consumed by `S_SoundInfo_f`.
function S_SoundInfo_f(system)
  if not system.started or system.mixState.dma is void then return ["sound system not started"] end if
  dma = system.mixState.dma
  return [
    ["stereo", dma.channels - 1],
    ["samples", dma.samples],
    ["samplepos", dma.samplePosition],
    ["samplebits", dma.sampleBits],
    ["submission_chunk", dma.submissionChunk],
    ["speed", dma.speed],
    ["buffer_bytes", len(dma.buffer)],
    ["total_channels", system.mixState.totalChannels],
  ]
end function

/// Apply the Quake-compatible s startup behavior.
/// @param system The system input consumed by `S_Startup`.
function S_Startup(system)
  if not system.initialized then return false end if
  if not SNDDMA_Init(system) then
    system.started = false
    return false
  end if
  system.started = true
  system.mixState.dma.gameAlive = true
  system.mixState.dma.soundAlive = true
  return true
end function

/// Apply the Quake-compatible s init behavior.
/// @param system The system input consumed by `S_Init`.
/// @param arguments Command-line arguments to inspect or execute.
/// @param memorySize Size of the requested data or resource.
function S_Init(system, arguments, memorySize)
  if hasArgument(arguments, "-nosound") then
    system.noSound = true
    return false
  end if
  if hasArgument(arguments, "-simsound") then system.fakeDma = true end if
  system.registeredCommands = ["play", "playvol", "stopsound", "soundlist", "soundinfo"]
  system.registeredCvars = [
    "nosound",
    "volume",
    "precache",
    "loadas8bit",
    "bgmvolume",
    "bgmbuffer",
    "ambient_level",
    "ambient_fade",
    "snd_noextraupdate",
    "snd_show",
    "_snd_mixahead",
  ]
  if memorySize > 0 and memorySize < 0x800000 then system.loadAs8Bit = true end if
  system.initialized = true
  S_Startup(system)
  sndmix.SND_InitScaletable(system.mixState)
  if system.fakeDma then
    dma = system.mixState.dma
    dma.splitBuffer = false
    dma.sampleBits = 16
    dma.speed = 22050
    dma.channels = 2
    dma.samples = 32768
    dma.samplePosition = 0
    dma.soundAlive = true
    dma.gameAlive = true
    dma.submissionChunk = 1
    dma.buffer = bytes(1 << 16)
  end if
  system.ambientSfx[0] = S_FindName(system, "ambience/water1.wav")
  system.ambientSfx[1] = S_FindName(system, "ambience/wind2.wav")
  S_StopAllSounds(system, true)
  return true
end function

/// Apply the Quake-compatible s shutdown behavior.
/// @param system The system input consumed by `S_Shutdown`.
function S_Shutdown(system)
  if not system.started then return false end if
  system.mixState.dma.gameAlive = false
  system.started = false
  SNDDMA_Shutdown(system)
  return true
end function

/// Apply the Quake-compatible s find name behavior.
/// @param system The system input consumed by `S_FindName`.
/// @param name Stable name that identifies the requested object or option.
function S_FindName(system, name)
  if name is void then return error(2480, "S_FindName: NULL") end if
  if len(bytes(name)) >= 64 then return error(2481, "Sound name too long: " + name) end if
  for each descriptor in system.knownSfx
    if descriptor.name == name then return descriptor end if
  end for
  if len(system.knownSfx) >= MAX_SFX then return error(2482, "S_FindName: out of sfx_t") end if
  descriptor = sndmem.createDescriptor(name)
  system.knownSfx = system.knownSfx + [descriptor]
  return descriptor
end function

/// Apply the Quake-compatible s touch sound behavior.
/// @param system The system input consumed by `S_TouchSound`.
/// @param name Stable name that identifies the requested object or option.
function S_TouchSound(system, name)
  if not system.started then return false end if
  descriptor = S_FindName(system, name)
  if descriptor is error then return descriptor end if
  return descriptor.cache is not void
end function

/// Apply the Quake-compatible s precache sound behavior.
/// @param system The system input consumed by `S_PrecacheSound`.
/// @param name Stable name that identifies the requested object or option.
function S_PrecacheSound(system, name)
  if not system.started or system.noSound then return void end if
  descriptor = S_FindName(system, name)
  if descriptor is error then return descriptor end if
  if system.precacheEnabled and descriptor.cache is void and system.filesystem is not void then
    result = try(sndmem.S_LoadSound(system.filesystem, descriptor, system.mixState.dma.speed, system.loadAs8Bit))
    if result is error then descriptor.cache = void end if
  end if
  return descriptor
end function

/// Mirror Quake's SND_PickChannel routine and its observable state changes.
/// @param system The system input consumed by `SND_PickChannel`.
/// @param entityNumber The entity number input consumed by `SND_PickChannel`.
/// @param entityChannel The entity channel input consumed by `SND_PickChannel`.
function SND_PickChannel(system, entityNumber, entityChannel)
  firstToDie = -1
  lifeLeft = 0x7fffffff
  index = DYNAMIC_FIRST
  while index < DYNAMIC_FIRST + MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    if entityChannel != 0 and channel.entityNumber == entityNumber and (channel.entityChannel == entityChannel or entityChannel == -1) then
      firstToDie = index
      break
    end if
    if channel.entityNumber != system.listenerEntity or entityNumber == system.listenerEntity or channel.sfx is void then
      remaining = channel.endTime - system.mixState.paintedTime
      if remaining < lifeLeft then
        lifeLeft = remaining
        firstToDie = index
      end if
    end if
    index = index + 1
  end while
  if firstToDie < 0 then return void end if
  target = system.mixState.channels[firstToDie]
  target.sfx = void
  return target
end function

/// Implements the `soundF32` operation for `miniquake.sound.snd_dma` (sound f32).
/// @param value Value consumed by `soundF32`.
function soundF32(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Mirror Quake's SND_Spatialize routine and its observable state changes.
/// @param system The system input consumed by `SND_Spatialize`.
/// @param channel The channel input consumed by `SND_Spatialize`.
function SND_Spatialize(system, channel)
  if channel.entityNumber == system.listenerEntity then
    channel.leftVolume = channel.masterVolume
    channel.rightVolume = channel.masterVolume
    return [channel.leftVolume, channel.rightVolume]
  end if

  source = math.subtract(channel.origin, system.listenerOrigin)
  distance = soundF32(math.length(source))
  if distance > 0.0 then source = math.scale(source, soundF32(1.0 / distance)) end if
  distance = soundF32(distance * channel.distanceMultiplier)
  dot = soundF32(math.dot(system.listenerRight, source))
  rightScale = 1.0
  leftScale = 1.0
  if system.mixState.dma.channels == 1 then
    rightScale = 1.0
    leftScale = 1.0
  else
    rightScale = 1.0 + dot
    leftScale = 1.0 - dot
  end if

  rightValue = soundF32(soundF32(channel.masterVolume * soundF32(1.0 - distance)) * rightScale)
  channel.rightVolume = native.trunc(rightValue)
  if channel.rightVolume < 0 then channel.rightVolume = 0 end if
  leftValue = soundF32(soundF32(channel.masterVolume * soundF32(1.0 - distance)) * leftScale)
  channel.leftVolume = native.trunc(leftValue)
  if channel.leftVolume < 0 then channel.leftVolume = 0 end if
  return [channel.leftVolume, channel.rightVolume]
end function

/// Return next random for the active module state.
/// @param system The system input consumed by `nextRandom`.
function nextRandom(system)
  // WinQuake/MiniQuake uses the Microsoft C runtime rand() sequence.
  system.randomSeed = (system.randomSeed * 214013 + 2531011) & 0xffffffff
  return (system.randomSeed >> 16) & 0x7fff
end function

/// Apply the Quake-compatible s start sound behavior.
/// @param system The system input consumed by `S_StartSound`.
/// @param entityNumber The entity number input consumed by `S_StartSound`.
/// @param entityChannel The entity channel input consumed by `S_StartSound`.
/// @param descriptor The descriptor input consumed by `S_StartSound`.
/// @param origin World-space origin of the operation.
/// @param volume The volume input consumed by `S_StartSound`.
/// @param attenuation The attenuation input consumed by `S_StartSound`.
function S_StartSound(system, entityNumber, entityChannel, descriptor, origin, volume, attenuation)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if not system.started or descriptor is void or system.noSound then return false end if
  target = SND_PickChannel(system, entityNumber, entityChannel)
  if target is void then return false end if

  sndmix.resetChannel(target)
  target.origin = math.copy(origin)
  target.distanceMultiplier = soundF32(soundF32(attenuation) / SOUND_NOMINAL_CLIP_DISTANCE)
  target.masterVolume = native.trunc(soundF32(soundF32(volume) * 255.0))
  target.entityNumber = entityNumber
  target.entityChannel = entityChannel
  SND_Spatialize(system, target)
  if target.leftVolume == 0 and target.rightVolume == 0 then return false end if

  cache = descriptor.cache
  if cache is void and system.filesystem is not void then
    cache = try(sndmem.S_LoadSound(system.filesystem, descriptor, system.mixState.dma.speed, system.loadAs8Bit))
  end if
  if cache is void or cache is error then return false end if

  target.sfx = descriptor
  target.position = 0
  target.endTime = system.mixState.paintedTime + cache.length

  index = DYNAMIC_FIRST
  while index < DYNAMIC_FIRST + MAX_DYNAMIC_CHANNELS
    check = system.mixState.channels[index]
    if check != target and check.sfx == descriptor and check.position == 0 then
      range = native.trunc(0.1 * system.mixState.dma.speed)
      if range < 1 then range = 1 end if
      skip = nextRandom(system) % range
      if skip >= target.endTime then skip = target.endTime - 1 end if
      if skip < 0 then skip = 0 end if
      target.position = target.position + skip
      target.endTime = target.endTime - skip
      break
    end if
    index = index + 1
  end while
  return true
end function

/// Apply the Quake-compatible s stop sound behavior.
/// @param system The system input consumed by `S_StopSound`.
/// @param entityNumber The entity number input consumed by `S_StopSound`.
/// @param entityChannel The entity channel input consumed by `S_StopSound`.
function S_StopSound(system, entityNumber, entityChannel)
  // Preserve the original 1.09 loop bounds, including its first-eight-slots
  // quirk rather than silently widening this to every channel.
  index = 0
  while index < MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    if channel.entityNumber == entityNumber and channel.entityChannel == entityChannel then
      channel.endTime = 0
      channel.sfx = void
      return true
    end if
    index = index + 1
  end while
  return false
end function

/// Apply the Quake-compatible s clear buffer behavior.
/// @param system The system input consumed by `S_ClearBuffer`.
function S_ClearBuffer(system)
  if not system.started or system.mixState.dma is void then return false end if
  clearValue = 0
  if system.mixState.dma.sampleBits == 8 then clearValue = 0x80 end if
  byteCount = system.mixState.dma.samples * system.mixState.dma.sampleBits / 8
  if byteCount > len(system.mixState.dma.buffer) then byteCount = len(system.mixState.dma.buffer) end if
  index = 0
  while index < byteCount
    system.mixState.dma.buffer[index] = clearValue
    index = index + 1
  end while
  return true
end function

/// Apply the Quake-compatible s stop all sounds behavior.
/// @param system The system input consumed by `S_StopAllSounds`.
/// @param clear The clear input consumed by `S_StopAllSounds`.
function S_StopAllSounds(system, clear)
  if not system.started then return false end if
  system.mixState.totalChannels = STATIC_FIRST
  index = 0
  while index < MAX_CHANNELS
    sndmix.resetChannel(system.mixState.channels[index])
    index = index + 1
  end while
  if clear then S_ClearBuffer(system) end if
  return true
end function

/// Apply the Quake-compatible s stop all sounds c behavior.
/// @param system The system input consumed by `S_StopAllSoundsC`.
function S_StopAllSoundsC(system)
  return S_StopAllSounds(system, true)
end function

/// Apply the Quake-compatible s static sound behavior.
/// @param system The system input consumed by `S_StaticSound`.
/// @param descriptor The descriptor input consumed by `S_StaticSound`.
/// @param origin World-space origin of the operation.
/// @param volume The volume input consumed by `S_StaticSound`.
/// @param attenuation The attenuation input consumed by `S_StaticSound`.
function S_StaticSound(system, descriptor, origin, volume, attenuation)
  if descriptor is void then return false end if
  if system.mixState.totalChannels >= MAX_CHANNELS then return false end if
  channel = system.mixState.channels[system.mixState.totalChannels]
  system.mixState.totalChannels = system.mixState.totalChannels + 1

  cache = descriptor.cache
  if cache is void and system.filesystem is not void then
    cache = try(sndmem.S_LoadSound(system.filesystem, descriptor, system.mixState.dma.speed, system.loadAs8Bit))
  end if
  if cache is void or cache is error or cache.loopStart == -1 then return false end if
  sndmix.resetChannel(channel)
  channel.sfx = descriptor
  channel.origin = math.copy(origin)
  channel.masterVolume = native.trunc(volume)
  channel.distanceMultiplier = (attenuation / 64.0) / SOUND_NOMINAL_CLIP_DISTANCE
  channel.endTime = system.mixState.paintedTime + cache.length
  SND_Spatialize(system, channel)
  return true
end function

/// Apply the Quake-compatible s update ambient sounds behavior.
/// @param system The system input consumed by `S_UpdateAmbientSounds`.
/// @param ambientLevels The ambient levels input consumed by `S_UpdateAmbientSounds`.
/// @param frameTime Time value used by the operation.
function S_UpdateAmbientSounds(system, ambientLevels, frameTime)
  if not system.ambientEnabled then return false end if
  // With no world model the original returns without disturbing the
  // previously mixed ambient channels.  An empty level array represents the
  // separate "no leaf" case and does clear them.
  if ambientLevels is void then return false end if
  if len(ambientLevels) == 0 or system.ambientLevel == 0.0 then
    index = 0
    while index < NUM_AMBIENTS
      system.mixState.channels[index].sfx = void
      index = index + 1
    end while
    return false
  end if

  index = 0
  while index < NUM_AMBIENTS
    channel = system.mixState.channels[index]
    channel.sfx = system.ambientSfx[index]
    level = 0
    if index < len(ambientLevels) then level = ambientLevels[index] end if
    target = system.ambientLevel * level
    if target < 8.0 then target = 0.0 end if
    if channel.masterVolume < target then
      channel.masterVolume = native.trunc(channel.masterVolume + frameTime * system.ambientFade)
      if channel.masterVolume > target then channel.masterVolume = native.trunc(target) end if
    else if channel.masterVolume > target then
      channel.masterVolume = native.trunc(channel.masterVolume - frameTime * system.ambientFade)
      if channel.masterVolume < target then channel.masterVolume = native.trunc(target) end if
    end if
    channel.leftVolume = channel.masterVolume
    channel.rightVolume = channel.masterVolume
    index = index + 1
  end while
  return true
end function

/// Implements the `combineStaticChannels` operation for `miniquake.sound.snd_dma` (combine static channels).
/// @param system The system input consumed by `combineStaticChannels`.
function combineStaticChannels(system)
  index = STATIC_FIRST
  while index < system.mixState.totalChannels
    channel = system.mixState.channels[index]
    if channel.sfx is not void and (channel.leftVolume != 0 or channel.rightVolume != 0) then
      prior = STATIC_FIRST
      while prior < index
        combine = system.mixState.channels[prior]
        if combine.sfx == channel.sfx then
          combine.leftVolume = combine.leftVolume + channel.leftVolume
          combine.rightVolume = combine.rightVolume + channel.rightVolume
          channel.leftVolume = 0
          channel.rightVolume = 0
          prior = index
        end if
        prior = prior + 1
      end while
    end if
    index = index + 1
  end while
end function

/// Return soundtime.
/// @param system The system input consumed by `GetSoundtime`.
/// @param samplePosition The sample position input consumed by `GetSoundtime`.
function GetSoundtime(system, samplePosition)
  dma = system.mixState.dma
  fullSamples = dma.samples / dma.channels
  dma.samplePosition = samplePosition
  if samplePosition < system.oldSamplePosition then
    system.completedBuffers = system.completedBuffers + 1
    if system.mixState.paintedTime > 0x40000000 then
      system.completedBuffers = 0
      system.mixState.paintedTime = fullSamples
      S_StopAllSounds(system, true)
    end if
  end if
  system.oldSamplePosition = samplePosition
  system.mixState.soundTime = system.completedBuffers * fullSamples + samplePosition / dma.channels
  return system.mixState.soundTime
end function

/// Apply the Quake-compatible s update behavior.
/// @param system The system input consumed by `S_Update_`.
/// @param samplePosition The sample position input consumed by `S_Update_`.
function S_Update_(system, samplePosition)
  if not system.started or system.blocked > 0 then return 0 end if
  GetSoundtime(system, samplePosition)
  if system.mixState.paintedTime < system.mixState.soundTime then
    system.mixState.paintedTime = system.mixState.soundTime
  end if
  endTime = system.mixState.soundTime + native.trunc(system.mixAhead * system.mixState.dma.speed)
  samples = system.mixState.dma.samples >> (system.mixState.dma.channels - 1)
  if endTime - system.mixState.soundTime > samples then endTime = system.mixState.soundTime + samples end if
  sndmix.S_PaintChannels(system.mixState, endTime)
  system.paintCalls = system.paintCalls + 1
  system.lastPaintTime = endTime
  if system.dmaOpened then SNDDMA_Submit(system) end if
  return endTime
end function

/// Apply the Quake-compatible s update behavior.
/// @param system The system input consumed by `S_Update`.
/// @param origin World-space origin of the operation.
/// @param forward The forward input consumed by `S_Update`.
/// @param right The right input consumed by `S_Update`.
/// @param up The up input consumed by `S_Update`.
/// @param ambientLevels The ambient levels input consumed by `S_Update`.
/// @param frameTime Time value used by the operation.
/// @param samplePosition The sample position input consumed by `S_Update`.
function S_Update(system, origin, forward, right, up, ambientLevels, frameTime, samplePosition)
  if not system.started or system.blocked > 0 then return false end if
  system.listenerOrigin = math.copy(origin)
  system.listenerForward = math.copy(forward)
  system.listenerRight = math.copy(right)
  system.listenerUp = math.copy(up)
  S_UpdateAmbientSounds(system, ambientLevels, frameTime)
  index = DYNAMIC_FIRST
  while index < system.mixState.totalChannels
    channel = system.mixState.channels[index]
    if channel.sfx is not void then SND_Spatialize(system, channel) end if
    index = index + 1
  end while
  combineStaticChannels(system)
  S_Update_(system, samplePosition)
  return true
end function

/// Apply the Quake-compatible s extra update behavior.
/// @param system The system input consumed by `S_ExtraUpdate`.
/// @param samplePosition The sample position input consumed by `S_ExtraUpdate`.
function S_ExtraUpdate(system, samplePosition)
  // WinQuake accumulates pending mouse input before honoring
  // snd_noextraupdate.
  system.accumulateCalls = system.accumulateCalls + 1
  if system.noExtraUpdate then return 0 end if
  return S_Update_(system, samplePosition)
end function

/// Report whether extension.
/// @param name Stable name that identifies the requested object or option.
function hasExtension(name)
  data = bytes(name)
  index = 0
  while index < len(data)
    if data[index] == 46 then return true end if
    index = index + 1
  end while
  return false
end function

/// Apply the Quake-compatible s play behavior.
/// @param system The system input consumed by `S_Play`.
/// @param arguments Command-line arguments to inspect or execute.
function S_Play(system, arguments)
  played = 0
  for each argument in arguments
    name = argument
    if not hasExtension(name) then name = name + ".wav" end if
    descriptor = S_PrecacheSound(system, name)
    if descriptor is not void and descriptor is not error then
      if S_StartSound(system, system.playHash, 0, descriptor, system.listenerOrigin, 1.0, 1.0) then played = played + 1 end if
    end if
    // The original post-increments the static hash at the call site even
    // when precaching returned NULL.
    system.playHash = system.playHash + 1
  end for
  return played
end function

/// Apply the Quake-compatible s play vol behavior.
/// @param system The system input consumed by `S_PlayVol`.
/// @param arguments Command-line arguments to inspect or execute.
function S_PlayVol(system, arguments)
  played = 0
  index = 0
  while index < len(arguments)
    name = arguments[index]
    if not hasExtension(name) then name = name + ".wav" end if
    volumeText = ""
    if index + 1 < len(arguments) then volumeText = arguments[index + 1] end if
    volume = common.atof(volumeText)
    descriptor = S_PrecacheSound(system, name)
    if descriptor is not void and descriptor is not error then
      if S_StartSound(system, system.playVolumeHash, 0, descriptor, system.listenerOrigin, volume, 1.0) then played = played + 1 end if
    end if
    system.playVolumeHash = system.playVolumeHash + 1
    index = index + 2
  end while
  return played
end function

/// Apply the Quake-compatible s sound list behavior.
/// @param system The system input consumed by `S_SoundList`.
function S_SoundList(system)
  entries = arrays.createArrayBuilder(len(system.knownSfx))
  total = 0
  for each descriptor in system.knownSfx
    cache = descriptor.cache
    if cache is not void then
      size = cache.length * cache.width * (cache.stereo + 1)
      total = total + size
      arrays.pushArrayBuilder(entries, [cache.loopStart >= 0, cache.width * 8, size, descriptor.name])
    end if
  end for
  return [arrays.finishArrayBuilder(entries), total]
end function

/// Apply the Quake-compatible s local sound behavior.
/// @param system The system input consumed by `S_LocalSound`.
/// @param sound The sound input consumed by `S_LocalSound`.
function S_LocalSound(system, sound)
  if system.noSound or not system.started then return false end if
  descriptor = S_PrecacheSound(system, sound)
  if descriptor is void or descriptor is error then return false end if
  return S_StartSound(system, system.listenerEntity, -1, descriptor, t.Vec3(0.0, 0.0, 0.0), 1.0, 1.0)
end function

/// Apply the Quake-compatible s clear precache behavior.
/// @param system The system input consumed by `S_ClearPrecache`.
function S_ClearPrecache(system)
  return true
end function

/// Apply the Quake-compatible s begin precaching behavior.
/// @param system The system input consumed by `S_BeginPrecaching`.
function S_BeginPrecaching(system)
  return true
end function

/// Apply the Quake-compatible s end precaching behavior.
/// @param system The system input consumed by `S_EndPrecaching`.
function S_EndPrecaching(system)
  return true
end function
