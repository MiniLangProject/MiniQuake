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
const MIN_QUEUED_BUFFERS = 3
const MAX_QUEUED_BUFFERS = 7
const MAX_CHANNELS = 128
const AMBIENT_WATER_ENTITY = -1001
const AMBIENT_WIND_ENTITY = -1002
const STATIC_CHANNEL = -32768
const MAX_DYNAMIC_CHANNELS = 8
const STATIC_FIRST = 12

randomSeed = 1

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

function unblock(mixer)
  if mixer is void or not mixer.audioState.opened then return 0 end if
  mixer.blockDepth = mixer.blockDepth - 1
  return mixer.blockDepth
end function

function blockDepth(mixer)
  if mixer is void then return 0 end if
  return mixer.blockDepth
end function

function stopMusic(mixer)
  if mixer is void then return false end if
  mixer.music = void
  return true
end function

function pauseMusic(mixer)
  if mixer.music is void or not mixer.music.playing then return false end if
  mixer.music.paused = true
  return true
end function

function resumeMusic(mixer)
  if mixer.music is void or not mixer.music.playing then return false end if
  mixer.music.paused = false
  return true
end function

function playMusic(mixer, track, looping)
  if mixer is void or not mixer.enabled then return false end if
  if track < 1 or track > 99 then return error(2410, "invalid music track " + track) end if
  if mixer.music is not void and mixer.music.number == track and mixer.music.playing then
    mixer.music.looping = looping
    mixer.music.paused = false
    return true
  end if
  source = qfs.readMusicTrack(mixer.filesystem, track)
  if source is error then return source end if
  if native.oggOpen(source, len(source)) == 0 then return error(2411, "invalid Ogg Vorbis track " + track) end if
  rate = native.oggRate()
  channels = native.oggChannels()
  frames = native.oggFrames()
  if rate < 1 or channels < 1 or channels > 2 or frames < 1 or frames > 0x10000000 then
    native.oggClose()
    return error(2412, "unsupported Ogg Vorbis track " + track)
  end if
  pcm = bytes(frames * channels * 2)
  decoded = native.oggDecode(pcm, frames)
  native.oggClose()
  if decoded < 1 then return error(2413, "Ogg Vorbis decode failed for track " + track) end if
  if decoded < frames then pcm = slice(pcm, 0, decoded * channels * 2) end if
  mixer.music = t.MusicTrack(track, pcm, rate, channels, decoded, 0, looping, true, false)
  return true
end function

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

function effectIndex(mixer, name)
  index = 0
  while index < len(mixer.effects)
    if mixer.effects[index].name == name then return index end if
    index = index + 1
  end while
  return -1
end function

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

function findChannel(mixer, entityNumber, channelNumber)
  for each channel in mixer.channels
    if channel.entityNumber == entityNumber and channel.channelNumber == channelNumber then return channel end if
  end for
  return void
end function

function isDynamicChannel(channel)
  if channel.entityNumber == AMBIENT_WATER_ENTITY or channel.entityNumber == AMBIENT_WIND_ENTITY then return false end if
  if channel.channelNumber == STATIC_CHANNEL then return false end if
  return true
end function

function dynamicChannelCount(mixer)
  count = 0
  for each channel in mixer.channels
    if isDynamicChannel(channel) then count = count + 1 end if
  end for
  return count
end function

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

function discardOldestChannel(mixer, newEntityNumber)
  victim = pickDynamicChannel(mixer, newEntityNumber, 0)
  if victim < 0 then return false end if
  return removeChannelAt(mixer, victim)
end function

function nextRandom()
  global randomSeed
  // MiniQuake's Win32 build uses the Microsoft C runtime rand sequence.
  randomSeed = (randomSeed * 214013 + 2531011) & 0xffffffff
  return (randomSeed >> 16) & 0x7fff
end function

function setRandomSeed(seed)
  global randomSeed
  randomSeed = seed & 0xffffffff
  return randomSeed
end function

function mixerF32(value)
  return native.bitsFloat(native.floatBits(value))
end function

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

function localSound(mixer, name)
  if mixer is void or not mixer.enabled then return false end if
  entityNumber = mixer.listenerEntity
  if entityNumber <= 0 then entityNumber = -1 end if
  return startSound(mixer, entityNumber, -1, name, mixer.listenerOrigin, 1.0, 0.0)
end function

function hasExtension(name)
  source = bytes(name)
  for each value in source
    if value == 46 then return true end if
  end for
  return false
end function

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

function soundInfo(mixer)
  if mixer is void or not mixer.enabled or not mixer.audioState.opened then return [["status", "sound system not started"]] end if
  sampleMask = audio.capacity(mixer.audioState) * MIX_FRAMES * mixer.audioState.channels - 1
  return [
    ["stereo", mixer.audioState.channels - 1],
    ["samples", audio.capacity(mixer.audioState) * MIX_FRAMES * mixer.audioState.channels],
    ["samplepos", audio.position(mixer.audioState, sampleMask)],
    ["samplebits", mixer.audioState.width * 8],
    ["submission_chunk", 1],
    ["speed", mixer.audioState.rate],
    ["queued", audio.queued(mixer.audioState)],
    ["total_channels", len(mixer.channels)],
  ]
end function

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

function setListenerEntity(mixer, entityNumber)
  mixer.listenerEntity = entityNumber
  return entityNumber
end function

function updateListener(mixer, origin, forward, right)
  mixer.listenerOrigin = math.copy(origin)
  mixer.listenerForward = math.copy(forward)
  mixer.listenerRight = math.copy(right)
  return true
end function

function updateEntityOrigins(mixer, entities)
  if mixer is void then return 0 end if
  updated = 0
  for each channel in mixer.channels
    entityNumber = channel.entityNumber
    if entityNumber > 0 and entityNumber != mixer.listenerEntity and entityNumber < len(entities) then
      entity = entities[entityNumber]
      if entity is not void then
        channel.origin = math.copy(entity.origin)
        updated = updated + 1
      end if
    end if
  end for
  return updated
end function

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

function fadeAmbientChannel(channel, target, step, origin)
  if channel is void then return false end if
  channel.origin = math.copy(origin)
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

function clampSample(value)
  if value > 32767 then return 32767 end if
  if value < -32768 then return -32768 end if
  return native.trunc(value)
end function

function channelVolumes(mixer, channel)
  master = native.trunc(mixerF32(mixerF32(channel.volume) * 255.0))
  // Sounds emitted by the view entity (weapon and menu sounds) are never
  // spatialized in WinQuake; they play equally in both speakers.
  if channel.entityNumber == mixer.listenerEntity then
    return [master, master]
  end if

  delta = math.subtract(channel.origin, mixer.listenerOrigin)
  distance = mixerF32(math.length(delta))
  spatial = mixerF32(1.0 - mixerF32(mixerF32(distance * channel.attenuation) / 1000.0))
  if channel.attenuation <= 0.0 then spatial = 1.0 end if
  spatial = mixerF32(math.clamp(spatial, 0.0, 1.0))
  pan = 0.0
  if distance > 0.0 then
    direction = math.scale(delta, mixerF32(1.0 / distance))
    pan = mixerF32(math.clamp(math.dot(direction, mixer.listenerRight), -1.0, 1.0))
  end if
  left = native.trunc(mixerF32(mixerF32(master * spatial) * mixerF32(1.0 - pan)))
  right = native.trunc(mixerF32(mixerF32(master * spatial) * mixerF32(1.0 + pan)))
  if left < 0 then left = 0 end if
  if right < 0 then right = 0 end if
  return [left, right]
end function

function mixChannelWithVolumes(mixer, channel, accumulator, frameCount, volumes)
  if not channel.active or channel.effect is void then return false end if
  totalSamples = len(channel.effect.samples) / channel.effect.width
  if totalSamples <= 0 then channel.active = false; return false end if

  if channel.endTime <= 0 then channel.endTime = mixer.paintedTime + totalSamples - channel.sample end if
  localTime = mixer.paintedTime
  blockEnd = mixer.paintedTime + frameCount
  while localTime < blockEnd and channel.active
    count = blockEnd - localTime
    if channel.endTime < blockEnd then count = channel.endTime - localTime end if
    if count < 0 then count = 0 end if

    // SND_PaintChannelFrom{8,16} always starts at paintbuffer[0], including
    // a loop restart inside the same 512-frame paint block.  This oddity is
    // audible and is deliberately preserved.
    frame = 0
    while frame < count
      if channel.effect.width == 1 then
        sample8 = channel.effect.samples[channel.sample + frame]
        if sample8 >= 128 then sample8 = sample8 - 256 end if
        leftVolume = volumes[0]
        rightVolume = volumes[1]
        if leftVolume > 255 then leftVolume = 255 end if
        if rightVolume > 255 then rightVolume = 255 end if
        accumulator[frame * 2] = accumulator[frame * 2] + sample8 * (leftVolume >> 3) * 8
        accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + sample8 * (rightVolume >> 3) * 8
      else
        sample = bio.i16(channel.effect.samples, (channel.sample + frame) * 2)
        accumulator[frame * 2] = accumulator[frame * 2] + ((sample * volumes[0]) >> 8)
        accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + ((sample * volumes[1]) >> 8)
      end if
      frame = frame + 1
    end while
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

function mixChannel(mixer, channel, accumulator, frameCount)
  return mixChannelWithVolumes(mixer, channel, accumulator, frameCount, channelVolumes(mixer, channel))
end function

function mix(mixer, frameCount)
  if frameCount <= 0 then return bytes() end if

  // Accumulate all channels at full precision and clamp only once.  Clamping
  // the output buffer after every channel made the result depend on channel
  // order and could crush effects when several torches/doors overlapped.
  accumulatorCount = frameCount * 2
  accumulator = arrays.makeFilledArray(accumulatorCount, 0)
  channelCount = len(mixer.channels)
  volumeOverrides = arrays.makeFilledArray(channelCount, void)
  channelIndex = 0
  while channelIndex < channelCount
    channel = mixer.channels[channelIndex]
    volumes = channelVolumes(mixer, channel)
    if channel.channelNumber == STATIC_CHANNEL and channel.effect is not void then
      prior = 0
      combined = false
      while prior < channelIndex and not combined
        priorChannel = mixer.channels[prior]
        if priorChannel.channelNumber == STATIC_CHANNEL and priorChannel.effect == channel.effect and priorChannel.active then
          volumeOverrides[prior][0] = volumeOverrides[prior][0] + volumes[0]
          volumeOverrides[prior][1] = volumeOverrides[prior][1] + volumes[1]
          volumes = [0, 0]
          combined = true
        end if
        prior = prior + 1
      end while
    end if
    volumeOverrides[channelIndex] = volumes
    channelIndex = channelIndex + 1
  end while

  alive = arrays.createArrayBuilder(channelCount)
  channelIndex = 0
  while channelIndex < channelCount
    channel = mixer.channels[channelIndex]
    volumes = volumeOverrides[channelIndex]
    if channel.active and volumes[0] == 0 and volumes[1] == 0 then
      arrays.pushArrayBuilder(alive, channel)
    else if mixChannelWithVolumes(mixer, channel, accumulator, frameCount, volumes) then
      arrays.pushArrayBuilder(alive, channel)
    end if
    channelIndex = channelIndex + 1
  end while
  mixer.channels = arrays.finishArrayBuilder(alive)
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

  output = bytes(frameCount * 4)
  frame = 0
  while frame < frameCount
    bio.putI16(output, frame * 4, clampSample(accumulator[frame * 2]))
    bio.putI16(output, frame * 4 + 2, clampSample(accumulator[frame * 2 + 1]))
    frame = frame + 1
  end while
  return output
end function

function mixMusic(mixer, accumulator, frameCount)
  track = mixer.music
  if track is void or not track.playing or track.paused or mixer.musicVolume <= 0.0 then return false end if
  frame = 0
  while frame < frameCount and track.playing
    sourceFrame = native.trunc(track.position * track.rate / mixer.sampleRate)
    if sourceFrame >= track.frames then
      if track.looping then
        track.position = 0
        sourceFrame = 0
      else
        track.playing = false
        break
      end if
    end if
    left = 0
    right = 0
    if track.channels == 1 then
      left = bio.i16(track.samples, sourceFrame * 2)
      right = left
    else
      left = bio.i16(track.samples, sourceFrame * 4)
      right = bio.i16(track.samples, sourceFrame * 4 + 2)
    end if
    accumulator[frame * 2] = accumulator[frame * 2] + left * mixer.musicVolume
    accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + right * mixer.musicVolume
    track.position = track.position + 1
    frame = frame + 1
  end while
  return track.playing
end function

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

function update(mixer, frameTime, mixAhead)
  if not mixer.enabled or blockDepth(mixer) > 0 then return 0 end if
  queuedBefore = audio.queued(mixer.audioState)
  if mixer.submittedBuffers > 0 and queuedBefore == 0 then
    mixer.underruns = mixer.underruns + 1
  end if

  target = desiredQueuedBuffers(mixer, frameTime, mixAhead)
  submitted = 0
  while audio.queued(mixer.audioState) < target
    data = mix(mixer, MIX_FRAMES)
    if not audio.submit(mixer.audioState, data) then break end if
    submitted = submitted + 1
    mixer.submittedBuffers = mixer.submittedBuffers + 1
  end while
  return submitted
end function
