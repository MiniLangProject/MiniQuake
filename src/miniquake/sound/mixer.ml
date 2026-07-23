package miniquake.sound.mixer

import miniquake.types as t
import miniquake.audio as audio
import miniquake.filesystem as qfs
import miniquake.sound.wav as wav
import miniquake.byteio as bio
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as soundWorld
import miniquake.array_util as arrays

// WinQuake reserves 128 software channels.  The former 32-channel limit could
// evict looping/static sounds very quickly on a populated retail map.
const MIX_FRAMES = 512
const MIN_QUEUED_BUFFERS = 3
const MAX_QUEUED_BUFFERS = 7
const MAX_CHANNELS = 128
const AMBIENT_WATER_ENTITY = -1001
const AMBIENT_WIND_ENTITY = -1002

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
  )
end function

function open(mixer)
  opened = audio.open(mixer.audioState, mixer.sampleRate, 2, 2)
  mixer.enabled = true
  mixer.underruns = 0
  mixer.submittedBuffers = 0
  return opened
end function

function stopAll(mixer)
  if mixer is void then return false end if
  mixer.channels = []
  return true
end function

function close(mixer)
  stopAll(mixer)
  audio.close(mixer.audioState)
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
  source = qfs.readFile(mixer.filesystem, path)
  info = wav.parse(source, path)
  pcm = convertToMono16(info, source, mixer.sampleRate)
  loopStart = -1
  if info.loopStart >= 0 then loopStart = native.trunc(info.loopStart * mixer.sampleRate / info.rate) end if
  effect = t.SoundEffect(name, pcm, mixer.sampleRate, 2, 1, loopStart)
  mixer.effects = mixer.effects + [effect]
  return effect
end function

function precache(mixer, names)
  if mixer is void or not mixer.enabled then return [0, 0] end if
  loaded = 0
  failed = 0
  index = 0
  while index < len(names)
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

// SND_PickChannel semantics: entchannel -1 overrides all sounds owned by the
// entity, entchannel 0 never overrides, and a positive channel replaces only
// the matching entity/channel pair.
function removeChannel(mixer, entityNumber, channelNumber)
  builder = arrays.createArrayBuilder(len(mixer.channels))
  for each channel in mixer.channels
    replace = false
    if channel.entityNumber == entityNumber then
      if channelNumber == -1 then
        replace = true
      else if channelNumber != 0 and channel.channelNumber == channelNumber then
        replace = true
      end if
    end if
    if not replace then arrays.pushArrayBuilder(builder, channel) end if
  end for
  mixer.channels = arrays.finishArrayBuilder(builder)
end function

function discardOldestChannel(mixer)
  if len(mixer.channels) == 0 then return false end if
  victim = 0
  index = 0
  while index < len(mixer.channels)
    // Prefer replacing a non-looping, non-listener channel.
    channel = mixer.channels[index]
    if not channel.looping and channel.entityNumber != mixer.listenerEntity then victim = index; break end if
    index = index + 1
  end while
  builder = arrays.createArrayBuilder(len(mixer.channels) - 1)
  index = 0
  while index < len(mixer.channels)
    if index != victim then arrays.pushArrayBuilder(builder, mixer.channels[index]) end if
    index = index + 1
  end while
  mixer.channels = arrays.finishArrayBuilder(builder)
  return true
end function

function startSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
  if not mixer.enabled then return false end if
  effect = loadEffect(mixer, name)
  removeChannel(mixer, entityNumber, channelNumber)
  if len(mixer.channels) >= MAX_CHANNELS then discardOldestChannel(mixer) end if
  loopValue = effect.loopStart >= 0
  mixer.channels = mixer.channels + [t.MixerChannel(
    entityNumber,
    channelNumber,
    effect,
    math.copy(origin),
    math.clamp(volume, 0.0, 1.0),
    attenuation,
    0,
    loopValue,
    true,
  )]
  return true
end function

function staticSound(mixer, name, origin, volume, attenuation)
  return startSound(mixer, 0, 0, name, origin, volume, attenuation)
end function

function localSound(mixer, name)
  if mixer is void or not mixer.enabled then return false end if
  entityNumber = mixer.listenerEntity
  if entityNumber <= 0 then entityNumber = -1 end if
  return startSound(mixer, entityNumber, -1, name, mixer.listenerOrigin, 1.0, 0.0)
end function

function stopSound(mixer, entityNumber, channelNumber)
  builder = arrays.createArrayBuilder(len(mixer.channels))
  stopped = 0
  for each channel in mixer.channels
    if channel.entityNumber == entityNumber and (channelNumber == 0 or channel.channelNumber == channelNumber) then
      stopped = stopped + 1
    else
      arrays.pushArrayBuilder(builder, channel)
    end if
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
  if len(mixer.channels) >= MAX_CHANNELS then discardOldestChannel(mixer) end if
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
  // Sounds emitted by the view entity (weapon and menu sounds) are never
  // spatialized in WinQuake; they play equally in both speakers.
  if channel.entityNumber == mixer.listenerEntity then
    volume = channel.volume * mixer.masterVolume
    return [volume, volume]
  end if

  delta = math.subtract(channel.origin, mixer.listenerOrigin)
  distance = math.length(delta)
  spatial = 1.0 - distance * channel.attenuation / 1000.0
  if channel.attenuation <= 0.0 then spatial = 1.0 end if
  spatial = math.clamp(spatial, 0.0, 1.0)
  pan = 0.0
  if distance > 0.0 then pan = math.clamp(math.dot(math.scale(delta, 1.0 / distance), mixer.listenerRight), -1.0, 1.0) end if
  volume = channel.volume * mixer.masterVolume * spatial
  return [volume * (1.0 - pan), volume * (1.0 + pan)]
end function

function mixChannel(mixer, channel, accumulator, frameCount)
  if not channel.active or channel.effect is void then return false end if
  volumes = channelVolumes(mixer, channel)
  totalSamples = len(channel.effect.samples) >> 1
  if totalSamples <= 0 then channel.active = false; return false end if

  frame = 0
  while frame < frameCount and channel.active
    if channel.sample >= totalSamples then
      if channel.effect.loopStart >= 0 then
        channel.sample = channel.effect.loopStart
      else if channel.looping then
        channel.sample = 0
      else
        channel.active = false
        break
      end if
    end if

    sample = bio.i16(channel.effect.samples, channel.sample * 2)
    accumulator[frame * 2] = accumulator[frame * 2] + sample * volumes[0]
    accumulator[frame * 2 + 1] = accumulator[frame * 2 + 1] + sample * volumes[1]
    channel.sample = channel.sample + 1
    frame = frame + 1
  end while
  return channel.active
end function

function mix(mixer, frameCount)
  if frameCount <= 0 then return bytes() end if

  // Accumulate all channels at full precision and clamp only once.  Clamping
  // the output buffer after every channel made the result depend on channel
  // order and could crush effects when several torches/doors overlapped.
  accumulator = arrays.makeFilledArray(frameCount * 2, 0)
  alive = arrays.createArrayBuilder(len(mixer.channels))
  for each channel in mixer.channels
    if mixChannel(mixer, channel, accumulator, frameCount) then
      arrays.pushArrayBuilder(alive, channel)
    end if
  end for
  mixer.channels = arrays.finishArrayBuilder(alive)

  output = bytes(frameCount * 4)
  frame = 0
  while frame < frameCount
    bio.putI16(output, frame * 4, clampSample(accumulator[frame * 2]))
    bio.putI16(output, frame * 4 + 2, clampSample(accumulator[frame * 2 + 1]))
    frame = frame + 1
  end while
  return output
end function

function desiredQueuedBuffers(mixer, frameTime, mixAhead)
  if mixAhead < 0.0 then mixAhead = 0.0 end if
  if frameTime < 0.0 then frameTime = 0.0 end if
  bufferSeconds = MIX_FRAMES * 1.0 / mixer.sampleRate
  wantedSeconds = mixAhead + frameTime * 2.0
  target = native.trunc(wantedSeconds / bufferSeconds)
  if target * bufferSeconds < wantedSeconds then target = target + 1 end if
  if target < MIN_QUEUED_BUFFERS then target = MIN_QUEUED_BUFFERS end if
  if target > MAX_QUEUED_BUFFERS then target = MAX_QUEUED_BUFFERS end if
  return target
end function

function update(mixer, frameTime, mixAhead)
  if not mixer.enabled then return 0 end if
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
