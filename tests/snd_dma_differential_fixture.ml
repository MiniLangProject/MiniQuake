/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/snd_dma_differential_fixture.ml.
*/
import miniquake.sound.snd_dma as sound
import miniquake.sound.snd_mem as sndmem
import miniquake.sound.snd_mix as mix
import miniquake.types as t
import miniquake.native as native

// Exercise int bool as part of this deterministic regression fixture.
function intBool(value)
  if value then return 1 end if
  return 0
end function

// Return text checksum derived from the active module state.
function textChecksum(text)
  data = bytes(text)
  result = 0
  index = 0
  while index < len(data)
    result = result + (index + 1) * data[index]
    index = index + 1
  end while
  return result
end function

// Return registration checksum derived from the active module state.
function registrationChecksum(names)
  result = 0
  index = 0
  while index < len(names)
    result = result + (index + 1) * textChecksum(names[index])
    index = index + 1
  end while
  return result
end function

// Add the requested value to the destination state.
function emit(name, caseName, i0, i1, i2, i3, f0, f1, f2, f3)
  print "{\"function\":\"" + name + "\",\"case\":\"" + caseName +
    "\",\"i0\":" + i0 + ",\"i1\":" + i1 +
    ",\"i2\":" + i2 + ",\"i3\":" + i3 +
    ",\"f0\":" + native.floatText(f0) + ",\"f1\":" + native.floatText(f1) +
    ",\"f2\":" + native.floatText(f2) + ",\"f3\":" + native.floatText(f3) + "}"
end function

// Exercise descriptor as part of this deterministic regression fixture.
function descriptor(name, length, loopStart, width)
  return sndmem.SoundDescriptor(
    name,
    sndmem.SoundCache(length, loopStart, 22050, width, 0, bytes(length * width)),
  )
end function

// Exercise base system as part of this deterministic regression fixture.
function baseSystem()
  system = sound.create(void, 22050)
  system.initialized = true
  system.started = true
  system.fakeDma = true
  system.dmaOpened = true
  system.listenerEntity = 1
  system.mixState.paintedTime = 100
  return system
end function

// Report whether active pair count holds for the active state.
function activePairCount(system)
  result = 0
  if system.mixState.channels[4].sfx is not void then result = result + 1 end if
  if system.mixState.channels[5].sfx is not void then result = result + 1 end if
  return result
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  system = baseSystem()
  system.mixState.channels[0].masterVolume = 5
  sound.S_AmbientOff(system)
  sound.S_UpdateAmbientSounds(system, [255, 0, 0, 0], 0.1)
  emit("S_AmbientOff", "disabled", system.mixState.channels[0].masterVolume,
    intBool(system.mixState.channels[0].sfx is not void), 0, 0, 0, 0, 0, 0)
  sound.S_AmbientOn(system)
  ambient = sound.S_FindName(system, "ambient.wav")
  system.ambientSfx[0] = ambient
  sound.S_UpdateAmbientSounds(system, [255, 0, 0, 0], 0.1)
  emit("S_AmbientOn", "enabled", system.mixState.channels[0].masterVolume,
    intBool(system.mixState.channels[0].sfx == ambient), 0, 0, 0, 0, 0, 0)

  system = baseSystem()
  info = sound.S_SoundInfo_f(system)
  infoChecksum = textChecksum("%5d stereo\n")
  infoChecksum = infoChecksum + textChecksum("%5d samples\n")
  infoChecksum = infoChecksum + textChecksum("%5d samplepos\n")
  infoChecksum = infoChecksum + textChecksum("%5d samplebits\n")
  infoChecksum = infoChecksum + textChecksum("%5d submission_chunk\n")
  infoChecksum = infoChecksum + textChecksum("%5d speed\n")
  infoChecksum = infoChecksum + textChecksum("0x%x dma buffer\n")
  infoChecksum = infoChecksum + textChecksum("%5d total_channels\n")
  emit("S_SoundInfo_f", "started", len(info), infoChecksum, 0, 0, 0, 0, 0, 0)
  system.started = false
  stoppedInfo = sound.S_SoundInfo_f(system)
  emit("S_SoundInfo_f", "stopped", len(stoppedInfo),
    textChecksum("sound system not started\n"), 0, 0, 0, 0, 0, 0)

  system = sound.create(void, 22050)
  firstStartup = sound.S_Startup(system)
  system.initialized = true
  system.fakeDma = true
  secondStartup = sound.S_Startup(system)
  emit("S_Startup", "gates", 0, 0, intBool(secondStartup), 0, 0, 0, 0, 0)

  system = sound.create(void, 11025)
  sound.S_Init(system, ["-simsound"], 4 * 1024 * 1024)
  emit("S_Init", "simsound", 5, 11, system.mixState.dma.speed,
    system.mixState.dma.samples, intBool(system.loadAs8Bit),
    system.mixState.dma.sampleBits, 1, system.mixState.totalChannels)
  emit("S_Init", "registrations", len(system.registeredCommands),
    len(system.registeredCvars), registrationChecksum(system.registeredCommands),
    registrationChecksum(system.registeredCvars), 0, 0, 0, 0)
  system = sound.create(void, 22050)
  sound.S_Init(system, ["-nosound"], 16 * 1024 * 1024)
  emit("S_Init", "nosound", intBool(system.initialized), intBool(system.started),
    len(system.registeredCommands), len(system.registeredCvars), 0, 0, 0, 0)

  system = baseSystem()
  sound.S_Shutdown(system)
  emit("S_Shutdown", "hardware", intBool(system.started), intBool(not system.started),
    intBool(not system.dmaOpened), intBool(system.mixState.dma.gameAlive), 0, 0, 0, 0)

  system = baseSystem()
  first = sound.S_FindName(system, "one.wav")
  second = sound.S_FindName(system, "one.wav")
  emit("S_FindName", "identity", len(system.knownSfx), intBool(first == second),
    textChecksum(first.name), 0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("touch.wav", 10, -1, 1)
  system.knownSfx = [first]
  touched = sound.S_TouchSound(system, "touch.wav")
  emit("S_TouchSound", "resident", intBool(touched), len(system.knownSfx), 0, 0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("pre.wav", 1000, 0, 2)
  system.knownSfx = [first]
  second = sound.S_PrecacheSound(system, "pre.wav")
  emit("S_PrecacheSound", "resident", intBool(second == first), len(system.knownSfx),
    first.cache.length, intBool(first.cache is not void), 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("pick.wav", 100, 0, 2)
  index = sound.DYNAMIC_FIRST
  while index < sound.DYNAMIC_FIRST + sound.MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    channel.sfx = first
    channel.entityNumber = 100 + index
    channel.entityChannel = 2
    channel.endTime = 200 + index
    index = index + 1
  end while
  system.mixState.channels[sound.DYNAMIC_FIRST].entityNumber = 1
  system.mixState.channels[sound.DYNAMIC_FIRST].endTime = 101
  picked = sound.SND_PickChannel(system, 999, 2)
  pickedIndex = 0
  while system.mixState.channels[pickedIndex] != picked
    pickedIndex = pickedIndex + 1
  end while
  emit("SND_PickChannel", "protect-listener", pickedIndex,
    intBool(picked.sfx is void), picked.entityNumber, picked.endTime, 0, 0, 0, 0)
  system = baseSystem()
  first = descriptor("override.wav", 100, 0, 2)
  channel = system.mixState.channels[6]
  channel.sfx = first
  channel.entityNumber = 42
  channel.entityChannel = 2
  picked = sound.SND_PickChannel(system, 42, 2)
  emit("SND_PickChannel", "entity-override", 6, intBool(picked.sfx is void),
    picked.entityNumber, picked.entityChannel, 0, 0, 0, 0)

  system = baseSystem()
  channel = system.mixState.channels[4]
  channel.origin = t.Vec3(0, -500, 0)
  channel.distanceMultiplier = 0.001
  channel.masterVolume = 255
  channel.entityNumber = 2
  sound.SND_Spatialize(system, channel)
  emit("SND_Spatialize", "stereo", channel.leftVolume, channel.rightVolume, 0, 0, 0, 0, 0, 0)
  channel.masterVolume = 201
  channel.entityNumber = 1
  sound.SND_Spatialize(system, channel)
  emit("SND_Spatialize", "listener", channel.leftVolume, channel.rightVolume,
    0, 0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("start.wav", 1000, -1, 2)
  sound.S_StartSound(system, 2, 3, first, t.Vec3(0, 0, 0), 0.5, 1)
  channel = system.mixState.channels[4]
  emit("S_StartSound", "dynamic", intBool(channel.sfx == first), channel.masterVolume,
    channel.endTime, channel.position, channel.distanceMultiplier, 0, 0, 0)
  system = baseSystem()
  first = descriptor("duplicate.wav", 1000, -1, 2)
  sound.S_StartSound(system, 2, 1, first, t.Vec3(0, 0, 0), 1, 1)
  sound.S_StartSound(system, 3, 1, first, t.Vec3(0, 0, 0), 1, 1)
  emit("S_StartSound", "duplicate-offset", system.mixState.channels[5].position,
    system.mixState.channels[5].endTime, system.mixState.channels[4].position,
    system.mixState.channels[4].endTime, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("stop.wav", 10, -1, 2)
  channel = system.mixState.channels[3]
  channel.sfx = first
  channel.entityNumber = 7
  channel.entityChannel = 9
  sound.S_StopSound(system, 7, 9)
  emit("S_StopSound", "first-eight-quirk", intBool(channel.sfx is void),
    channel.endTime, 0, 0, 0, 0, 0, 0)

  system = baseSystem()
  system.mixState.channels[20].sfx = descriptor("all.wav", 10, -1, 2)
  sound.S_StopAllSounds(system, false)
  emit("S_StopAllSounds", "noclear", system.mixState.totalChannels,
    intBool(system.mixState.channels[20].sfx is void), system.mixState.dma.buffer[0],
    0, 0, 0, 0, 0)

  system = baseSystem()
  system.mixState.dma.buffer[0] = 77
  system.mixState.channels[4].sfx = descriptor("allc.wav", 10, -1, 2)
  sound.S_StopAllSoundsC(system)
  emit("S_StopAllSoundsC", "clear", system.mixState.totalChannels,
    intBool(system.mixState.channels[4].sfx is void), system.mixState.dma.buffer[0],
    0, 0, 0, 0, 0)

  system = baseSystem()
  system.mixState.dma.sampleBits = 8
  system.mixState.dma.samples = 8
  index = 0
  while index < 20
    system.mixState.dma.buffer[index] = 17
    index = index + 1
  end while
  sound.S_ClearBuffer(system)
  emit("S_ClearBuffer", "eight-bit-size", system.mixState.dma.buffer[0],
    system.mixState.dma.buffer[7], system.mixState.dma.buffer[8],
    system.mixState.dma.buffer[19], 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("static.wav", 500, 20, 2)
  sound.S_StaticSound(system, first, t.Vec3(100, 0, 0), 200, 64)
  channel = system.mixState.channels[12]
  emit("S_StaticSound", "looped", system.mixState.totalChannels,
    intBool(channel.sfx == first), channel.masterVolume, channel.endTime,
    channel.distanceMultiplier, 0, 0, 0)
  system = baseSystem()
  first = descriptor("oneshot.wav", 500, -1, 2)
  result = sound.S_StaticSound(system, first, t.Vec3(0, 0, 0), 200, 64)
  emit("S_StaticSound", "not-looped", system.mixState.totalChannels,
    intBool(system.mixState.channels[12].sfx is void), intBool(not result), 0,
    0, 0, 0, 0)

  system = baseSystem()
  first = sound.S_FindName(system, "water.wav")
  system.ambientSfx[0] = first
  system.mixState.channels[0].masterVolume = 5
  sound.S_UpdateAmbientSounds(system, [255, 0, 0, 0], 0.1)
  channel = system.mixState.channels[0]
  emit("S_UpdateAmbientSounds", "fade", channel.masterVolume, channel.leftVolume,
    channel.rightVolume, intBool(channel.sfx == first), 0, 0, 0, 0)
  channel.masterVolume = 33
  channel.sfx = first
  sound.S_UpdateAmbientSounds(system, void, 0.1)
  emit("S_UpdateAmbientSounds", "no-world", channel.masterVolume,
    intBool(channel.sfx == first), 0, 0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("torch.wav", 500, 0, 2)
  system.mixState.totalChannels = 14
  system.mixState.channels[12].sfx = first
  system.mixState.channels[12].origin = t.Vec3(100, 0, 0)
  system.mixState.channels[12].masterVolume = 100
  system.mixState.channels[12].distanceMultiplier = 0.001
  system.mixState.channels[13].sfx = first
  system.mixState.channels[13].origin = t.Vec3(100, 0, 0)
  system.mixState.channels[13].masterVolume = 100
  system.mixState.channels[13].distanceMultiplier = 0.001
  system.mixAhead = 0
  sound.S_Update(system, t.Vec3(0, 0, 0), t.Vec3(1, 0, 0),
    t.Vec3(0, -1, 0), t.Vec3(0, 0, 1), [0, 0, 0, 0], 0.1, 200)
  emit("S_Update", "combine", system.mixState.channels[12].leftVolume,
    system.mixState.channels[13].leftVolume, system.paintCalls,
    system.lastPaintTime, system.listenerForward.x, system.listenerRight.y, 0, 0)

  system = baseSystem()
  system.oldSamplePosition = 200
  firstTime = sound.GetSoundtime(system, 30000)
  secondTime = sound.GetSoundtime(system, 100)
  emit("GetSoundtime", "wrap", firstTime, secondTime, 0, 0, 0, 0, 0, 0)

  system = baseSystem()
  system.oldSamplePosition = 100
  system.completedBuffers = 1
  system.mixState.paintedTime = 0
  system.mixAhead = 0
  sound.S_Update_(system, 400)
  emit("S_Update_", "mix", system.mixState.soundTime, system.mixState.paintedTime,
    system.paintCalls, system.submitCalls, 0, 0, 0, 0)

  system = baseSystem()
  system.oldSamplePosition = 400
  system.completedBuffers = 1
  system.mixState.paintedTime = 0
  system.mixAhead = 0
  sound.S_ExtraUpdate(system, 400)
  emit("S_ExtraUpdate", "windows", system.accumulateCalls, system.paintCalls,
    system.submitCalls, system.mixState.paintedTime, 0, 0, 0, 0)
  system = baseSystem()
  system.noExtraUpdate = true
  sound.S_ExtraUpdate(system, 400)
  emit("S_ExtraUpdate", "disabled", system.accumulateCalls, system.paintCalls,
    system.submitCalls, system.mixState.paintedTime, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("beep.wav", 1000, -1, 2)
  second = descriptor("other.wav", 1000, -1, 2)
  system.knownSfx = [first, second]
  sound.S_Play(system, ["beep", "other.wav"])
  emit("S_Play", "extension", len(system.knownSfx), activePairCount(system),
    system.mixState.channels[4].entityNumber, system.mixState.channels[5].entityNumber,
    textChecksum(system.knownSfx[0].name), textChecksum(system.knownSfx[1].name), 0, 0)
  system = baseSystem()
  system.playHash = 347
  system.noSound = true
  sound.S_Play(system, ["missing"])
  system.noSound = false
  first = descriptor("after.wav", 1000, -1, 2)
  system.knownSfx = [first]
  sound.S_Play(system, ["after"])
  emit("S_Play", "null-hash", system.mixState.channels[4].entityNumber,
    intBool(system.mixState.channels[4].sfx == first), len(system.knownSfx),
    0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("beep.wav", 1000, -1, 2)
  system.knownSfx = [first]
  sound.S_PlayVol(system, ["beep", "0.5"])
  emit("S_PlayVol", "volume", len(system.knownSfx),
    system.mixState.channels[4].masterVolume, system.mixState.channels[4].entityNumber,
    intBool(system.mixState.channels[4].sfx == first), 0, 0, 0, 0)
  system = baseSystem()
  system.playVolumeHash = 544
  first = descriptor("beep.wav", 1000, -1, 2)
  system.knownSfx = [first]
  sound.S_PlayVol(system, ["beep"])
  second = descriptor("after.wav", 1000, -1, 2)
  system.knownSfx = system.knownSfx + [second]
  sound.S_PlayVol(system, ["after", "1"])
  emit("S_PlayVol", "dangling-volume",
    intBool(system.mixState.channels[4].sfx == second),
    system.mixState.channels[4].entityNumber,
    system.mixState.channels[4].masterVolume, len(system.knownSfx), 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("listed.wav", 10, 0, 2)
  system.knownSfx = [first]
  listResult = sound.S_SoundList(system)
  listChecksum = textChecksum("L")
  listChecksum = listChecksum + textChecksum("(%2db) %6i : %s\n")
  listChecksum = listChecksum + textChecksum("Total resident: %i\n")
  emit("S_SoundList", "resident", len(listResult[0]), 3, listChecksum, 0, 0, 0, 0, 0)

  system = baseSystem()
  first = descriptor("local.wav", 10, -1, 2)
  system.knownSfx = [first]
  sound.S_LocalSound(system, "local.wav")
  emit("S_LocalSound", "listener", system.mixState.channels[4].entityNumber,
    system.mixState.channels[4].entityChannel, system.mixState.channels[4].masterVolume,
    intBool(system.mixState.channels[4].sfx == first), 0, 0, 0, 0)

  system = baseSystem()
  before = len(system.knownSfx)
  sound.S_ClearPrecache(system)
  emit("S_ClearPrecache", "noop", len(system.knownSfx), before, 0, 0, 0, 0, 0, 0)
  sound.S_BeginPrecaching(system)
  emit("S_BeginPrecaching", "noop", len(system.knownSfx), before, 0, 0, 0, 0, 0, 0)
  sound.S_EndPrecaching(system)
  emit("S_EndPrecaching", "noop", len(system.knownSfx), before, 0, 0, 0, 0, 0, 0)
  return 0
end function
