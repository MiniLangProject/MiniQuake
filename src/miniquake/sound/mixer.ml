/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.mixer.
*/
package miniquake.sound.mixer

import miniquake.types as t
import miniquake.audio as audio
import miniquake.filesystem as qfs
import miniquake.sound.wav as wav
import miniquake.sound.snd_mem as sndmem
import miniquake.byteio as bio
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as soundWorld
import miniquake.array_util as arrays
import miniquake.common as common

// WinQuake reserves 128 software channels.  The former 32-channel limit could
// evict looping/static sounds very quickly on a populated retail map.
const MIX_FRAMES = 512
const MUSIC_DECODE_FRAMES = 4096
const MIN_QUEUED_BUFFERS = 3
const MAX_QUEUED_BUFFERS = 7
const MAX_CHANNELS = 128
const AMBIENT_WATER_ENTITY = -1001
const AMBIENT_WIND_ENTITY = -1002
const STATIC_CHANNEL = -32768
const MAX_DYNAMIC_CHANNELS = 8
const STATIC_FIRST = 12

randomSeed = 1

// S_PaintChannels owns fixed paint/volume buffers in the original engine.
// Keep equivalent reusable storage so a real-time 44.1-kHz stream does not
// allocate several large arrays for every 512-sample block.
paintAccumulatorScratch = array(MIX_FRAMES * 2, 0)
paintLeftVolumeScratch = array(MAX_CHANNELS, 0)
paintRightVolumeScratch = array(MAX_CHANNELS, 0)
paintSurvivorScratch = array(MAX_CHANNELS, void)
paintStaticEffectScratch = array(MAX_CHANNELS, void)
paintStaticRepresentativeScratch = array(MAX_CHANNELS, 0)
paintOutputScratch = bytes(MIX_FRAMES * 4)

// Create and initialize the module state.
function create(filesystem, sampleRate)
  if sampleRate <= 0 then sampleRate = 22050 end if
  return t.SoundMixer(
    audio.create(),
    filesystem,
    [],
    [],
    sampleRate,
    0.7,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0),
    -1,
    false,
    0,
    0,
    void,
    1.0,
    0,
    0,
    0,
    345,
    543,
  )
end function

// Initialize state for open.
function open(mixer)
  opened = audio.open(mixer.audioState, mixer.sampleRate, 2, 2)
  if opened is error then
    mixer.enabled = false
    return opened
  end if
  mixer.enabled = true
  mixer.underruns = 0
  mixer.submittedBuffers = 0
  return opened
end function

// Finalize state for stop all.
function stopAll(mixer)
  if mixer is void then return false end if
  mixer.channels = []
  mixer.staticAllocations = 0
  // The original clears the shared DMA buffer.  Our waveOut bridge copies
  // submitted blocks, so resetting it is the equivalent observable action.
  if mixer.audioState.opened then audio.reset(mixer.audioState) end if
  return true
end function

// S_BlockSound/S_UnblockSound production counterpart.  waveOutReset flushes
// all queued headers on the first nesting level; no painting/submission takes
// place until the matching final unblock.
function block(mixer)
  if mixer is void or not mixer.audioState.opened then return 0 end if
  mixer.blockDepth = mixer.blockDepth + 1
  if mixer.blockDepth == 1 then
    audio.reset(mixer.audioState)
    mixer.submittedBuffers = 0
  end if
  return mixer.blockDepth
end function

// Provide unblock behavior for the active subsystem.
function unblock(mixer)
  if mixer is void or not mixer.audioState.opened then return 0 end if
  if mixer.blockDepth > 0 then mixer.blockDepth = mixer.blockDepth - 1 end if
  return mixer.blockDepth
end function

// Provide block depth behavior for the active subsystem.
function blockDepth(mixer)
  if mixer is void then return 0 end if
  return mixer.blockDepth
end function

// Finalize state for stop music.
function stopMusic(mixer)
  if mixer is void then return false end if
  if mixer.music is not void then native.oggClose() end if
  mixer.music = void
  return true
end function

// Provide pause music behavior for the active subsystem.
function pauseMusic(mixer)
  if mixer.music is void or not mixer.music.playing then return false end if
  mixer.music.paused = true
  return true
end function

// Provide resume music behavior for the active subsystem.
function resumeMusic(mixer)
  if mixer.music is void or not mixer.music.playing then return false end if
  mixer.music.paused = false
  return true
end function

// Play music through the active media subsystem.
function playMusic(mixer, track, looping)
  if mixer is void or not mixer.enabled then return false end if
  if track < 1 or track > 99 then return error(2410, "invalid music track " + track) end if
  if mixer.music is not void and mixer.music.number == track and mixer.music.playing then
    mixer.music.looping = looping
    mixer.music.paused = false
    return true
  end if
  stopMusic(mixer)
  source = bytes()
  sourcePath = qfs.musicTrackPath(mixer.filesystem, track)
  opened = 0
  if sourcePath != "" then opened = native.oggOpenFile(sourcePath)
  else
    source = qfs.readMusicTrack(mixer.filesystem, track)
    if source is error then return source end if
    opened = native.oggOpen(source, len(source))
  end if
  if opened == 0 then return error(2411, "invalid Ogg Vorbis track " + track) end if
  rate = native.oggRate()
  channels = native.oggChannels()
  frames = native.oggFrames()
  if rate < 1 or channels < 1 or channels > 2 or frames < 1 or frames > 0x10000000 then
    native.oggClose()
    return error(2412, "unsupported Ogg Vorbis track " + track)
  end if
  probe = bytes(MUSIC_DECODE_FRAMES * channels * 2)
  decoded = native.oggDecode(probe, MUSIC_DECODE_FRAMES)
  if decoded < 1 or native.oggSeekStart() == 0 then
    native.oggClose()
    return error(2413, "Ogg Vorbis decode failed for track " + track)
  end if
  // A packed fallback keeps its compressed source alive while stb_vorbis owns
  // the memory view. Loose Steam/rerelease tracks are owned by the native OGG
  // bridge so they do not become another long-lived MiniLang heap object. PCM
  // is decoded in small blocks by mixMusic; decoding an entire retail track
  // here allocated 50-100 MiB and stalled the signon/map change.
  mixer.music = t.MusicTrack(track, source, bytes(), rate, channels, frames, 0, looping, true, false, 0, 0)
  return true
end function

// Read and validate music chunk.
function decodeMusicChunk(track, restart)
  if restart then
    if native.oggSeekStart() == 0 then return false end if
    track.sampleBase = 0
  else
    track.sampleBase = track.sampleBase + track.sampleFrames
  end if
  pcmSize = MUSIC_DECODE_FRAMES * track.channels * 2
  pcm = track.samples
  if len(pcm) != pcmSize then pcm = bytes(pcmSize) end if
  decoded = native.oggDecode(pcm, MUSIC_DECODE_FRAMES)
  if decoded < 1 then
    track.sampleFrames = 0
    return false
  end if
  track.samples = pcm
  track.sampleFrames = decoded
  return true
end function

// Release state for close.
function close(mixer)
  stopMusic(mixer)
  stopAll(mixer)
  audio.close(mixer.audioState)
  mixer.blockDepth = 0
  mixer.enabled = false
  mixer.underruns = 0
  mixer.submittedBuffers = 0
  return true
end function

// Return effect index derived from the active module state.
function effectIndex(mixer, name)
  index = 0
  while index < len(mixer.effects)
    if mixer.effects[index].name == name then return index end if
    index = index + 1
  end while
  return -1
end function

// Convert data for convert to mono16.
function convertToMono16(info, source, targetRate)
  outputSamples = native.trunc(info.samples * targetRate / info.rate)
  if outputSamples < 1 then outputSamples = 1 end if
  result = bytes(outputSamples * 2)
  index = 0
  while index < outputSamples
    sourceIndex = native.trunc(index * info.rate / targetRate)
    if sourceIndex < 0 then sourceIndex = 0 end if
    if sourceIndex >= info.samples then sourceIndex = info.samples - 1 end if
    sample = wav.sampleAt(info, source, sourceIndex, 0)
    if info.channels > 1 then sample = native.trunc((sample + wav.sampleAt(info, source, sourceIndex, 1)) / 2) end if
    if info.width == 1 then sample = sample << 8 end if
    bio.putI16(result, index * 2, sample)
    index = index + 1
  end while
  return result
end function

// Read and validate effect.
function loadEffect(mixer, name)
  existing = effectIndex(mixer, name)
  if existing >= 0 then return mixer.effects[existing] end if
  path = name
  dataName = bytes(path)
  if len(dataName) < 6 or decode(slice(dataName, 0, 6)) != "sound/" then path = "sound/" + path end if
  source = try(qfs.readFile(mixer.filesystem, path))
  if source is error then return source end if
  cache = try(sndmem.S_LoadSoundData(name, source, mixer.sampleRate, false))
  if cache is error then return cache end if
  effect = t.SoundEffect(name, cache.data, cache.speed, cache.width, 1, cache.loopStart)
  mixer.effects = mixer.effects + [effect]
  return effect
end function

// Preload and register the the requested value asset.
function precache(mixer, names)
  if mixer is void or not mixer.enabled then return [0, 0] end if
  loaded = 0
  failed = 0
  nameCount = len(names)
  index = 0
  while index < nameCount
    name = names[index]
    if name != "" then
      result = try(loadEffect(mixer, name))
      if result is error then failed = failed + 1 else loaded = loaded + 1 end if
    end if
    index = index + 1
  end while
  return [loaded, failed]
end function

// Return channel.
function findChannel(mixer, entityNumber, channelNumber)
  for each channel in mixer.channels
    if channel.entityNumber == entityNumber and channel.channelNumber == channelNumber then return channel end if
  end for
  return void
end function

// Report whether is dynamic channel.
function isDynamicChannel(channel)
  if channel.entityNumber == AMBIENT_WATER_ENTITY or channel.entityNumber == AMBIENT_WIND_ENTITY then return false end if
  if channel.channelNumber == STATIC_CHANNEL then return false end if
  return true
end function

// Return dynamic channel count derived from the active module state.
function dynamicChannelCount(mixer)
  count = 0
  for each channel in mixer.channels
    if isDynamicChannel(channel) then count = count + 1 end if
  end for
  return count
end function

// Release state for remove channel at.
function removeChannelAt(mixer, victim)
  if victim < 0 or victim >= len(mixer.channels) then return false end if
  builder = arrays.createArrayBuilder(len(mixer.channels) - 1)
  channelCount = len(mixer.channels)
  index = 0
  while index < channelCount
    if index != victim then arrays.pushArrayBuilder(builder, mixer.channels[index]) end if
    index = index + 1
  end while
  mixer.channels = arrays.finishArrayBuilder(builder)
  return true
end function

// SND_PickChannel scans the fixed eight dynamic slots in order.  A matching
// non-zero entity channel wins immediately; otherwise the sound with the
// shortest remaining life is replaced, while a listener sound is protected
// from a non-listener replacement.
function pickDynamicChannel(mixer, newEntityNumber, newChannelNumber)
  currentDynamicCount = dynamicChannelCount(mixer)
  victim = -1
  shortest = 0x7fffffff
  channelCount = len(mixer.channels)
  index = 0
  while index < channelCount
    channel = mixer.channels[index]
    eligible = isDynamicChannel(channel)
    if eligible then
      if newChannelNumber != 0 and channel.entityNumber == newEntityNumber and (channel.channelNumber == newChannelNumber or newChannelNumber == -1) then
        return index
      end if
      if channel.entityNumber == mixer.listenerEntity and newEntityNumber != mixer.listenerEntity then eligible = false end if
    end if
    if eligible then
      remaining = 0
      if channel.effect is not void then remaining = channel.endTime - mixer.paintedTime end if
      if remaining < shortest then
        shortest = remaining
        victim = index
      end if
    end if
    index = index + 1
  end while
  if currentDynamicCount < MAX_DYNAMIC_CHANNELS then return -1 end if
  return victim
end function

// Release or consume state for discard oldest channel.
function discardOldestChannel(mixer, newEntityNumber)
  victim = pickDynamicChannel(mixer, newEntityNumber, 0)
  if victim < 0 then return false end if
  return removeChannelAt(mixer, victim)
end function

// Return next random for the active module state.
function nextRandom()
  global randomSeed
  // MiniQuake's Win32 build uses the Microsoft C runtime rand sequence.
  randomSeed = (randomSeed * 214013 + 2531011) & 0xffffffff
  return (randomSeed >> 16) & 0x7fff
end function

// Update module state for random seed.
function setRandomSeed(seed)
  global randomSeed
  randomSeed = seed & 0xffffffff
  return randomSeed
end function

// Provide mixer f32 behavior for the active subsystem.
function mixerF32(value)
  return native.bitsFloat(native.floatBits(value))
end function

// Initialize state for start sound.
function startSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
  if not mixer.enabled then return false end if
  dynamicBefore = dynamicChannelCount(mixer)
  victim = pickDynamicChannel(mixer, entityNumber, channelNumber)
  // A matching non-zero entity channel always replaces its existing slot,
  // even while fewer than eight dynamic channels are active. When full, the
  // same result represents the shortest-lived eligible victim.
  if victim >= 0 then
    removeChannelAt(mixer, victim)
  else if dynamicBefore >= MAX_DYNAMIC_CHANNELS then
    return false
  end if
  candidate = t.MixerChannel(
    entityNumber,
    channelNumber,
    void,
    math.copy(origin),
    mixerF32(volume),
    mixerF32(attenuation),
    0,
    false,
    true,
    0,
  )
  volumes = channelVolumes(mixer, candidate)
  // S_StartSound clears its selected target before this test and does not
  // load/cache a source that is completely inaudible at the listener.
  if volumes[0] == 0 and volumes[1] == 0 then return false end if
  effect = try(loadEffect(mixer, name))
  if effect is error then return false end if
  loopValue = effect.loopStart >= 0
  candidate.effect = effect
  candidate.looping = loopValue
  total = len(effect.samples) / effect.width
  candidate.endTime = mixer.paintedTime + total

  // Starting the same SFX twice in one frame at position zero gets a small
  // random offset so it does not merely become louder.
  for each channel in mixer.channels
    if isDynamicChannel(channel) and channel.effect == effect and channel.sample == 0 then
      range = native.trunc(0.1 * mixer.sampleRate)
      if range < 1 then range = 1 end if
      skip = nextRandom() % range
      if skip >= total then skip = total - 1 end if
      if skip < 0 then skip = 0 end if
      candidate.sample = skip
      candidate.endTime = candidate.endTime - skip
      break
    end if
  end for
  mixer.channels = mixer.channels + [candidate]
  return true
end function

// Provide static sound behavior for the active subsystem.
function staticSound(mixer, name, origin, volume, attenuation)
  if mixer is void or not mixer.enabled or STATIC_FIRST + mixer.staticAllocations >= MAX_CHANNELS then return false end if
  // S_StaticSound consumes its fixed slot before loading/checking loopability.
  mixer.staticAllocations = mixer.staticAllocations + 1
  effect = try(loadEffect(mixer, name))
  if effect is error then return false end if
  if effect.loopStart < 0 then return false end if
  mixer.channels = mixer.channels + [t.MixerChannel(
    0,
    STATIC_CHANNEL,
    effect,
    math.copy(origin),
    volume,
    attenuation / 64.0,
    0,
    true,
    true,
    mixer.paintedTime + len(effect.samples) / effect.width,
  )]
  return true
end function

// Provide local sound behavior for the active subsystem.
function localSound(mixer, name)
  if mixer is void or not mixer.enabled then return false end if
  entityNumber = mixer.listenerEntity
  if entityNumber <= 0 then entityNumber = -1 end if
  return startSound(mixer, entityNumber, -1, name, mixer.listenerOrigin, 1.0, 0.0)
end function

// Report whether extension.
function hasExtension(name)
  source = bytes(name)
  for each value in source
    if value == 46 then return true end if
  end for
  return false
end function

// Play the requested value through the active media subsystem.
function play(mixer, arguments)
  if mixer is void or not mixer.enabled then return 0 end if
  played = 0
  index = 1
  while index < len(arguments)
    name = arguments[index]
    if not hasExtension(name) then name = name + ".wav" end if
    if startSound(mixer, mixer.playHash, 0, name, mixer.listenerOrigin, 1.0, 1.0) then played = played + 1 end if
    mixer.playHash = mixer.playHash + 1
    index = index + 1
  end while
  return played
end function

// Play vol through the active media subsystem.
function playVol(mixer, arguments)
  if mixer is void or not mixer.enabled then return 0 end if
  played = 0
  index = 1
  while index < len(arguments)
    name = arguments[index]
    if not hasExtension(name) then name = name + ".wav" end if
    volumeText = ""
    if index + 1 < len(arguments) then volumeText = arguments[index + 1] end if
    volume = common.atof(volumeText)
    if startSound(mixer, mixer.playVolumeHash, 0, name, mixer.listenerOrigin, volume, 1.0) then played = played + 1 end if
    mixer.playVolumeHash = mixer.playVolumeHash + 1
    index = index + 2
  end while
  return played
end function

// Provide sound list behavior for the active subsystem.
function soundList(mixer)
  entries = arrays.createArrayBuilder(len(mixer.effects))
  total = 0
  for each effect in mixer.effects
    size = len(effect.samples)
    total = total + size
    arrays.pushArrayBuilder(entries, [effect.loopStart >= 0, effect.width * 8, size, effect.name])
  end for
  return [arrays.finishArrayBuilder(entries), total]
end function

// Provide sound info behavior for the active subsystem.
function soundInfo(mixer)
  if mixer is void or not mixer.enabled or not mixer.audioState.opened then return [["status", "sound system not started"]] end if
  sampleMask = audio.capacity(mixer.audioState) * MIX_FRAMES * mixer.audioState.channels - 1
  result = [
    ["stereo", mixer.audioState.channels - 1],
    ["samples", audio.capacity(mixer.audioState) * MIX_FRAMES * mixer.audioState.channels],
    ["samplepos", audio.position(mixer.audioState, sampleMask)],
    ["samplebits", mixer.audioState.width * 8],
    ["submission_chunk", 1],
    ["speed", mixer.audioState.rate],
    ["queued", audio.queued(mixer.audioState)],
    ["submitted", audio.submitted(mixer.audioState)],
    ["completed", audio.completed(mixer.audioState)],
    ["underruns", audio.underruns(mixer.audioState)],
    ["block_depth", mixer.blockDepth],
    ["total_channels", len(mixer.channels)],
  ]
  if mixer.music is not void then
    result = result + [
      ["music_track", mixer.music.number],
      ["music_position", mixer.music.position],
      ["music_playing", mixer.music.playing],
      ["music_paused", mixer.music.paused],
      ["music_volume", mixer.musicVolume],
    ]
  end if
  return result
end function

// Provide music info behavior for the active subsystem.
function musicInfo(mixer)
  if mixer is void or not mixer.enabled then return [["status", "sound system not started"]] end if
  if mixer.music is void then return [["status", "no music track loaded"]] end if
  return [
    ["track", mixer.music.number],
    ["source_rate", mixer.music.rate],
    ["source_channels", mixer.music.channels],
    ["source_frames", mixer.music.frames],
    ["position", mixer.music.position],
    ["playing", mixer.music.playing],
    ["paused", mixer.music.paused],
    ["volume", mixer.musicVolume],
    ["decoded_block_frames", mixer.music.sampleFrames],
  ]
end function

// Finalize state for stop sound.
function stopSound(mixer, entityNumber, channelNumber)
  builder = arrays.createArrayBuilder(len(mixer.channels))
  stopped = 0
  dynamicIndex = 0
  for each channel in mixer.channels
    // Preserve snd_dma.c's 1.09 loop bound: indices 0..7 include the four
    // reserved ambient slots, so only the first four dynamic slots can match.
    eligible = isDynamicChannel(channel) and dynamicIndex < 4
    if stopped == 0 and eligible and channel.entityNumber == entityNumber and channel.channelNumber == channelNumber then
      stopped = stopped + 1
    else
      arrays.pushArrayBuilder(builder, channel)
    end if
    if isDynamicChannel(channel) then dynamicIndex = dynamicIndex + 1 end if
  end for
  mixer.channels = arrays.finishArrayBuilder(builder)
  return stopped
end function

// Update module state for listener entity.
function setListenerEntity(mixer, entityNumber)
  mixer.listenerEntity = entityNumber
  return entityNumber
end function

// Update module state for listener.
function updateListener(mixer, origin, forward, right)
  // snd_dma.c stores these in three persistent vec3_t arrays. Updating their
  // components avoids replacing three heap-backed Vec3 objects every frame.
  mixer.listenerOrigin.x = origin.x
  mixer.listenerOrigin.y = origin.y
  mixer.listenerOrigin.z = origin.z
  mixer.listenerForward.x = forward.x
  mixer.listenerForward.y = forward.y
  mixer.listenerForward.z = forward.z
  mixer.listenerRight.x = right.x
  mixer.listenerRight.y = right.y
  mixer.listenerRight.z = right.z
  return true
end function

// Update module state for entity origins.
function updateEntityOrigins(mixer, entities)
  if mixer is void then return 0 end if
  updated = 0
  for each channel in mixer.channels
    entityNumber = channel.entityNumber
    if entityNumber > 0 and entityNumber != mixer.listenerEntity and entityNumber < len(entities) then
      entity = entities[entityNumber]
      if entity is not void then
        channel.origin.x = entity.origin.x
        channel.origin.y = entity.origin.y
        channel.origin.z = entity.origin.z
        updated = updated + 1
      end if
    end if
  end for
  return updated
end function

// Ensure sufficient storage or state for ambient channel.
function ensureAmbientChannel(mixer, entityNumber, channelNumber, name)
  channel = findChannel(mixer, entityNumber, channelNumber)
  if channel is not void then return channel end if
  effect = try(loadEffect(mixer, name))
  if effect is error then return void end if
  if len(mixer.channels) >= MAX_CHANNELS then discardOldestChannel(mixer, entityNumber) end if
  channel = t.MixerChannel(
    entityNumber,
    channelNumber,
    effect,
    math.copy(mixer.listenerOrigin),
    0.0,
    0.0,
    0,
    true,
    true,
    mixer.paintedTime + len(effect.samples) / effect.width,
  )
  mixer.channels = mixer.channels + [channel]
  return channel
end function

// Provide fade ambient channel behavior for the active subsystem.
function fadeAmbientChannel(channel, target, step, origin)
  if channel is void then return false end if
  channel.origin.x = origin.x
  channel.origin.y = origin.y
  channel.origin.z = origin.z
  channel.active = true
  if channel.volume < target then
    channel.volume = channel.volume + step
    if channel.volume > target then channel.volume = target end if
  else if channel.volume > target then
    channel.volume = channel.volume - step
    if channel.volume < target then channel.volume = target end if
  end if
  return true
end function

// Provide ambient target behavior for the active subsystem.
function ambientTarget(levelByte, ambientLevel)
  scaled = levelByte * ambientLevel
  if scaled < 8.0 then return 0.0 end if
  return math.clamp(scaled / 255.0, 0.0, 1.0)
end function

// S_UpdateAmbientSounds: BSP leaves contain four ambient bytes.  Stock Quake
// uses slot 0 for water and slot 1 for wind and fades them at ambient_fade.
function updateAmbient(mixer, map, origin, frameTime, ambientLevel, ambientFade)
  if mixer is void or not mixer.enabled or map is void then return false end if
  waterTarget = 0.0
  windTarget = 0.0
  leafIndex = soundWorld.leafForPoint(map, origin)
  if leafIndex > 0 and leafIndex < len(map.leafs) then
    ambient = map.leafs[leafIndex].ambient
    if len(ambient) >= 2 then
      waterTarget = ambientTarget(ambient[0], ambientLevel)
      windTarget = ambientTarget(ambient[1], ambientLevel)
    end if
  end if

  step = frameTime * ambientFade / 255.0
  if step < 0.0 then step = 0.0 end if
  water = findChannel(mixer, AMBIENT_WATER_ENTITY, 1)
  wind = findChannel(mixer, AMBIENT_WIND_ENTITY, 2)
  if waterTarget > 0.0 and water is void then water = ensureAmbientChannel(mixer, AMBIENT_WATER_ENTITY, 1, "ambience/water1.wav") end if
  if windTarget > 0.0 and wind is void then wind = ensureAmbientChannel(mixer, AMBIENT_WIND_ENTITY, 2, "ambience/wind2.wav") end if
  fadeAmbientChannel(water, waterTarget, step, origin)
  fadeAmbientChannel(wind, windTarget, step, origin)
  return true
end function

// Return a validated clamp sample value.
function clampSample(value)
  if value > 32767 then return 32767 end if
  if value < -32768 then return -32768 end if
  return native.trunc(value)
end function

// Calculate one channel's stereo volumes into reusable parallel arrays.
function channelVolumesInto(mixer, channel, leftValues, rightValues, index)
  master = native.trunc(mixerF32(mixerF32(channel.volume) * 255.0))
  // Sounds emitted by the view entity (weapon and menu sounds) are never
  // spatialized in WinQuake; they play equally in both speakers.
  if channel.entityNumber == mixer.listenerEntity then
    leftValues[index] = master
    rightValues[index] = master
    return true
  end if

  // Scalar math preserves the SND_Spatialize formula without allocating the
  // old delta and normalized-direction Vec3 pair for every active channel.
  deltaX = channel.origin.x - mixer.listenerOrigin.x
  deltaY = channel.origin.y - mixer.listenerOrigin.y
  deltaZ = channel.origin.z - mixer.listenerOrigin.z
  distance = mixerF32(native.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ))
  spatial = mixerF32(1.0 - mixerF32(mixerF32(distance * channel.attenuation) / 1000.0))
  if channel.attenuation <= 0.0 then spatial = 1.0 end if
  spatial = mixerF32(math.clamp(spatial, 0.0, 1.0))
  pan = 0.0
  if distance > 0.0 then
    inverseDistance = mixerF32(1.0 / distance)
    directionX = deltaX * inverseDistance
    directionY = deltaY * inverseDistance
    directionZ = deltaZ * inverseDistance
    pan = mixerF32(math.clamp(
      directionX * mixer.listenerRight.x + directionY * mixer.listenerRight.y + directionZ * mixer.listenerRight.z,
      -1.0,
      1.0,
    ))
  end if
  left = native.trunc(mixerF32(mixerF32(master * spatial) * mixerF32(1.0 - pan)))
  right = native.trunc(mixerF32(mixerF32(master * spatial) * mixerF32(1.0 + pan)))
  if left < 0 then left = 0 end if
  if right < 0 then right = 0 end if
  leftValues[index] = left
  rightValues[index] = right
  return true
end function

// Provide channel volumes behavior for the active subsystem.
function channelVolumes(mixer, channel)
  global paintLeftVolumeScratch, paintRightVolumeScratch
  channelVolumesInto(mixer, channel, paintLeftVolumeScratch, paintRightVolumeScratch, 0)
  return [paintLeftVolumeScratch[0], paintRightVolumeScratch[0]]
end function

// Mix a channel using scalar stereo volumes.
function mixChannelWithStereoVolumes(mixer, channel, accumulator, frameCount, leftVolumeValue, rightVolumeValue)
  if not channel.active or channel.effect is void then return false end if
  totalSamples = len(channel.effect.samples) / channel.effect.width
  if totalSamples <= 0 then channel.active = false; return false end if

  if channel.endTime <= 0 then channel.endTime = mixer.paintedTime + totalSamples - channel.sample end if
  localTime = mixer.paintedTime
  blockEnd = mixer.paintedTime + frameCount
  // Width and stereo volume are invariant for the whole channel paint.  Keep
  // the two inner sample loops branch-free; this is the dominant sound hot
  // path and preserves the exact 8-bit scale-table and 16-bit shift results.
  width = channel.effect.width
  left8 = leftVolumeValue
  right8 = rightVolumeValue
  if left8 > 255 then left8 = 255 end if
  if right8 > 255 then right8 = 255 end if
  left8Scale = (left8 >> 3) * 8
  right8Scale = (right8 >> 3) * 8
  while localTime < blockEnd and channel.active
    count = blockEnd - localTime
    if channel.endTime < blockEnd then count = channel.endTime - localTime end if
    if count < 0 then count = 0 end if

    // SND_PaintChannelFrom{8,16} always starts at paintbuffer[0], including
    // a loop restart inside the same 512-frame paint block.  This oddity is
    // audible and is deliberately preserved.
    frame = 0
    if width == 1 then
      while frame < count
        sample8 = channel.effect.samples[channel.sample + frame]
        if sample8 >= 128 then sample8 = sample8 - 256 end if
        accumulator[frame * 2] = accumulator[frame * 2] + sample8 * left8Scale
        accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + sample8 * right8Scale
        frame = frame + 1
      end while
    else
      while frame < count
        // The cache loader already validates the complete 16-bit sample
        // range. Decode directly here so the real-time inner loop does not
        // call byteio's generic type/range validator for every PCM sample.
        sampleOffset = (channel.sample + frame) * 2
        sample = channel.effect.samples[sampleOffset] | (channel.effect.samples[sampleOffset + 1] << 8)
        if sample >= 0x8000 then sample = sample - 0x10000 end if
        accumulator[frame * 2] = accumulator[frame * 2] + ((sample * leftVolumeValue) >> 8)
        accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + ((sample * rightVolumeValue) >> 8)
        frame = frame + 1
      end while
    end if
    channel.sample = channel.sample + count
    localTime = localTime + count

    if localTime >= channel.endTime then
      if channel.effect.loopStart >= 0 and channel.effect.loopStart < totalSamples then
        channel.sample = channel.effect.loopStart
        channel.endTime = localTime + totalSamples - channel.sample
      else if channel.looping then
        channel.sample = 0
        channel.endTime = localTime + totalSamples
      else
        channel.active = false
      end if
    end if
  end while
  return channel.active
end function

// Mix channel with volumes into the active audio buffer.
function mixChannelWithVolumes(mixer, channel, accumulator, frameCount, volumes)
  return mixChannelWithStereoVolumes(mixer, channel, accumulator, frameCount, volumes[0], volumes[1])
end function

// Mix channel into the active audio buffer.
function mixChannel(mixer, channel, accumulator, frameCount)
  return mixChannelWithVolumes(mixer, channel, accumulator, frameCount, channelVolumes(mixer, channel))
end function

// Mix into a caller-owned PCM buffer using persistent paint scratch storage.
function mixIntoOutput(mixer, frameCount, output)
  global paintAccumulatorScratch, paintLeftVolumeScratch, paintRightVolumeScratch, paintSurvivorScratch
  global paintStaticEffectScratch, paintStaticRepresentativeScratch
  if frameCount <= 0 then return output end if
  // Accumulate all channels at full precision and clamp only once.  Clamping
  // the output buffer after every channel made the result depend on channel
  // order and could crush effects when several torches/doors overlapped.
  accumulatorCount = frameCount * 2
  if len(paintAccumulatorScratch) < accumulatorCount then paintAccumulatorScratch = array(accumulatorCount, 0) end if
  accumulator = paintAccumulatorScratch
  sampleIndex = 0
  while sampleIndex < accumulatorCount
    accumulator[sampleIndex] = 0
    sampleIndex = sampleIndex + 1
  end while
  channelCount = len(mixer.channels)
  if len(paintLeftVolumeScratch) < channelCount then
    paintLeftVolumeScratch = array(channelCount, 0)
    paintRightVolumeScratch = array(channelCount, 0)
    paintSurvivorScratch = array(channelCount, void)
    paintStaticEffectScratch = array(channelCount, void)
    paintStaticRepresentativeScratch = array(channelCount, 0)
  end if
  channelIndex = 0
  staticEffectCount = 0
  while channelIndex < channelCount
    channel = mixer.channels[channelIndex]
    channelVolumesInto(mixer, channel, paintLeftVolumeScratch, paintRightVolumeScratch, channelIndex)
    if channel.channelNumber == STATIC_CHANNEL and channel.effect is not void then
      // Static channels are phase-locked by effect.  The original linear scan
      // over all earlier channels becomes quadratic with many torches.  Track
      // only the first active representative of each distinct effect, which
      // selects the same channel and preserves the exact accumulation order.
      representative = -1
      effectIndex = 0
      while effectIndex < staticEffectCount and representative < 0
        if paintStaticEffectScratch[effectIndex] == channel.effect then
          representative = paintStaticRepresentativeScratch[effectIndex]
        end if
        effectIndex = effectIndex + 1
      end while
      if representative >= 0 then
        paintLeftVolumeScratch[representative] = paintLeftVolumeScratch[representative] + paintLeftVolumeScratch[channelIndex]
        paintRightVolumeScratch[representative] = paintRightVolumeScratch[representative] + paintRightVolumeScratch[channelIndex]
        paintLeftVolumeScratch[channelIndex] = 0
        paintRightVolumeScratch[channelIndex] = 0
      else if channel.active then
        paintStaticEffectScratch[staticEffectCount] = channel.effect
        paintStaticRepresentativeScratch[staticEffectCount] = channelIndex
        staticEffectCount = staticEffectCount + 1
      end if
    end if
    channelIndex = channelIndex + 1
  end while

  survivorCount = 0
  removed = false
  channelIndex = 0
  while channelIndex < channelCount
    channel = mixer.channels[channelIndex]
    leftVolume = paintLeftVolumeScratch[channelIndex]
    rightVolume = paintRightVolumeScratch[channelIndex]
    survives = channel.active and leftVolume == 0 and rightVolume == 0
    if not survives then
      survives = mixChannelWithStereoVolumes(mixer, channel, accumulator, frameCount, leftVolume, rightVolume)
    end if
    if survives then
      paintSurvivorScratch[survivorCount] = channel
      survivorCount = survivorCount + 1
    else
      removed = true
    end if
    channelIndex = channelIndex + 1
  end while
  // Most paint blocks do not end a channel. Keep the existing channel array
  // in that common case and allocate a compact replacement only on an actual
  // sound completion, matching the fixed-slot behavior of snd_mix.c.
  if removed then
    survivors = arrays.makeEmptyArray(survivorCount)
    survivorIndex = 0
    while survivorIndex < survivorCount
      survivors[survivorIndex] = paintSurvivorScratch[survivorIndex]
      survivorIndex = survivorIndex + 1
    end while
    mixer.channels = survivors
  end if
  mixer.paintedTime = mixer.paintedTime + frameCount

  // S_TransferPaintBuffer applies the archived volume cvar once after all
  // sound channels have accumulated into the paint buffer.
  transferVolume = native.trunc(mixer.masterVolume * 256.0)
  sampleIndex = 0
  while sampleIndex < accumulatorCount
    accumulator[sampleIndex] = (accumulator[sampleIndex] * transferVolume) >> 8
    sampleIndex = sampleIndex + 1
  end while
  mixMusic(mixer, accumulator, frameCount)

  if len(output) < frameCount * 4 then output = bytes(frameCount * 4) end if
  frame = 0
  while frame < frameCount
    // Flatten clamp and little-endian transfer into the hot loop. The output
    // size was checked above, so byteio's per-sample range validation would be
    // redundant for all 1,024 writes in a normal stereo paint block.
    leftSample = accumulator[frame * 2]
    if leftSample > 32767 then leftSample = 32767
    else if leftSample < -32768 then leftSample = -32768
    else leftSample = native.trunc(leftSample)
    end if
    rightSample = accumulator[frame * 2 + 1]
    if rightSample > 32767 then rightSample = 32767
    else if rightSample < -32768 then rightSample = -32768
    else rightSample = native.trunc(rightSample)
    end if
    outputOffset = frame * 4
    output[outputOffset] = leftSample & 255
    output[outputOffset + 1] = (leftSample >> 8) & 255
    output[outputOffset + 2] = rightSample & 255
    output[outputOffset + 3] = (rightSample >> 8) & 255
    frame = frame + 1
  end while
  return output
end function

// Mix the requested value into the active audio buffer.
function mix(mixer, frameCount)
  if frameCount <= 0 then return bytes() end if
  return mixIntoOutput(mixer, frameCount, bytes(frameCount * 4))
end function

// Paint one backend block into the reusable submission buffer. audioSubmit
// copies the samples synchronously into its fixed waveOut header ring.
function mixForSubmit(mixer, frameCount)
  global paintOutputScratch
  required = frameCount * 4
  if len(paintOutputScratch) != required then paintOutputScratch = bytes(required) end if
  return mixIntoOutput(mixer, frameCount, paintOutputScratch)
end function

// Mix music into the active audio buffer.
function mixMusic(mixer, accumulator, frameCount)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  track = mixer.music
  if track is void or not track.playing or track.paused or mixer.musicVolume <= 0.0 then return false end if
  frame = 0
  while frame < frameCount and track.playing
    sourceFrame = native.trunc(track.position * track.rate / mixer.sampleRate)
    if sourceFrame >= track.frames then
      if track.looping then
        track.position = 0
        sourceFrame = 0
        if not decodeMusicChunk(track, true) then track.playing = false; break end if
      else
        track.playing = false
        break
      end if
    end if
    if track.sampleFrames == 0 then
      if not decodeMusicChunk(track, track.sampleBase != 0) then track.playing = false; break end if
    end if
    while sourceFrame >= track.sampleBase + track.sampleFrames and track.playing
      if not decodeMusicChunk(track, false) then
        if track.looping then
          track.position = 0
          sourceFrame = 0
          if not decodeMusicChunk(track, true) then track.playing = false end if
        else
          track.playing = false
        end if
      end if
    end while
    if not track.playing then break end if
    chunkFrame = sourceFrame - track.sampleBase
    left = 0
    right = 0
    if track.channels == 1 then
      sampleOffset = chunkFrame * 2
      left = track.samples[sampleOffset] | (track.samples[sampleOffset + 1] << 8)
      if left >= 0x8000 then left = left - 0x10000 end if
      right = left
    else
      sampleOffset = chunkFrame * 4
      left = track.samples[sampleOffset] | (track.samples[sampleOffset + 1] << 8)
      right = track.samples[sampleOffset + 2] | (track.samples[sampleOffset + 3] << 8)
      if left >= 0x8000 then left = left - 0x10000 end if
      if right >= 0x8000 then right = right - 0x10000 end if
    end if
    accumulator[frame * 2] = accumulator[frame * 2] + left * mixer.musicVolume
    accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + right * mixer.musicVolume
    track.position = track.position + 1
    frame = frame + 1
  end while
  return track.playing
end function

// Provide desired queued buffers behavior for the active subsystem.
function desiredQueuedBuffers(mixer, frameTime, mixAhead)
  if mixAhead < 0.0 then mixAhead = 0.0 end if
  if frameTime < 0.0 then frameTime = 0.0 end if
  bufferSeconds = MIX_FRAMES * 1.0 / mixer.sampleRate
  // _snd_mixahead is the sole MiniQuake paint horizon.  Host frame time must
  // not silently add multiple 512-frame blocks to the observable latency.
  wantedSeconds = mixAhead
  target = native.trunc(wantedSeconds / bufferSeconds)
  if target * bufferSeconds < wantedSeconds then target = target + 1 end if
  if target < MIN_QUEUED_BUFFERS then target = MIN_QUEUED_BUFFERS end if
  if target > MAX_QUEUED_BUFFERS then target = MAX_QUEUED_BUFFERS end if
  return target
end function

// Update module state for the requested operation.
function update(mixer, frameTime, mixAhead)
  if not mixer.enabled or blockDepth(mixer) > 0 then return 0 end if
  queuedBefore = audio.queued(mixer.audioState)
  if mixer.submittedBuffers > 0 and queuedBefore == 0 then
    mixer.underruns = mixer.underruns + 1
  end if

  target = desiredQueuedBuffers(mixer, frameTime, mixAhead)
  submitted = 0
  while audio.queued(mixer.audioState) < target
    data = mixForSubmit(mixer, MIX_FRAMES)
    if not audio.submit(mixer.audioState, data) then break end if
    submitted = submitted + 1
    mixer.submittedBuffers = mixer.submittedBuffers + 1
  end while
  return submitted
end function
