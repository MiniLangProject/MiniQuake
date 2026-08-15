/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-056: snd_dma.c channel, spatialization and production handoff parity.
*/
import miniquake.sound.snd_dma as bp056Dma
import miniquake.sound.snd_mem as bp056Mem
import miniquake.sound.snd_mix as bp056Mix
import miniquake.sound.mixer as bp056Mixer
import miniquake.types as bp056Types
import miniquake.byteio as bp056Bio
import miniquake.native as bp056Native

// Assert exact equality and report both values on failure.
function bp056Equal(actual, expected, name)
  if actual != expected then return error(5600, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp056Yes(value, name)
  if not value then return error(5601, name + ": expected true") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp056Run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Exercise the cache test scenario and verify its expected result.
function bp056Cache(values, loopStart)
  data = bytes(len(values) * 2)
  index = 0
  while index < len(values)
    bp056Bio.putI16(data, index * 2, values[index])
    index = index + 1
  end while
  return bp056Mem.SoundCache(len(values), loopStart, 22050, 2, 0, data)
end function
// Exercise the descriptor test scenario and verify its expected result.
function bp056Descriptor(name, length)
  values = []
  index = 0
  while index < length
    values = values + [100 + index]
    index = index + 1
  end while
  return bp056Mem.SoundDescriptor(name, bp056Cache(values, -1))
end function
// Exercise the system test scenario and verify its expected result.
function bp056System()
  system = bp056Dma.create(void, 22050)
  system.initialized = true
  system.started = true
  system.fakeDma = true
  system.dmaOpened = true
  system.listenerEntity = 1
  system.listenerOrigin = bp056Types.Vec3(0.0, 0.0, 0.0)
  system.listenerRight = bp056Types.Vec3(0.0, -1.0, 0.0)
  system.mixState.paintedTime = 100
  return system
end function
// Exercise the effect test scenario and verify its expected result.
function bp056Effect(name, length)
  data = bytes(length * 2)
  index = 0
  while index < length
    bp056Bio.putI16(data, index * 2, index + 1)
    index = index + 1
  end while
  return bp056Types.SoundEffect(name, data, 22050, 2, 1, -1)
end function
// Exercise the mixer channel test scenario and verify its expected result.
function bp056MixerChannel(entity, channel, effect, sample)
  return bp056Types.MixerChannel(entity, channel, effect, bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.0, sample, false, true, len(effect.samples) / effect.width)
end function

// Return constants for the active module state.
function bp056Constants()
  bp056Equal(bp056Dma.MAX_SFX, 512, "MAX_SFX")
  bp056Equal(bp056Dma.MAX_CHANNELS, 128, "MAX_CHANNELS")
  bp056Equal(bp056Dma.MAX_DYNAMIC_CHANNELS, 8, "dynamic channels")
  bp056Equal(bp056Dma.NUM_AMBIENTS, 4, "ambient channels")
  return true
end function
// Exercise the override test scenario and verify its expected result.
function bp056Override()
  system = bp056System()
  descriptor = bp056Descriptor("override.wav", 16)
  channel = system.mixState.channels[bp056Dma.DYNAMIC_FIRST + 2]
  channel.sfx = descriptor
  channel.entityNumber = 42
  channel.entityChannel = 2
  picked = bp056Dma.SND_PickChannel(system, 42, 2)
  bp056Yes(picked == channel, "matching channel")
  bp056Yes(picked.sfx is void, "matching channel cleared")
  return true
end function
// Exercise the minus one override test scenario and verify its expected result.
function bp056MinusOneOverride()
  system = bp056System()
  channel = system.mixState.channels[bp056Dma.DYNAMIC_FIRST + 3]
  channel.sfx = bp056Descriptor("minus.wav", 16)
  channel.entityNumber = 77
  channel.entityChannel = 4
  picked = bp056Dma.SND_PickChannel(system, 77, -1)
  bp056Yes(picked == channel, "minus-one override")
  return true
end function
// Exercise the channel zero test scenario and verify its expected result.
function bp056ChannelZero()
  system = bp056System()
  descriptor = bp056Descriptor("zero.wav", 16)
  sameEntity = system.mixState.channels[bp056Dma.DYNAMIC_FIRST]
  sameEntity.sfx = descriptor
  sameEntity.entityNumber = 9
  sameEntity.entityChannel = 0
  sameEntity.endTime = 500

  shortest = system.mixState.channels[bp056Dma.DYNAMIC_FIRST + 1]
  shortest.sfx = descriptor
  shortest.entityNumber = 10
  shortest.entityChannel = 1
  shortest.endTime = 101

  index = bp056Dma.DYNAMIC_FIRST + 2
  while index < bp056Dma.DYNAMIC_FIRST + bp056Dma.MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    channel.sfx = descriptor
    channel.entityNumber = 100 + index
    channel.entityChannel = 1
    channel.endTime = 200 + index
    index = index + 1
  end while

  picked = bp056Dma.SND_PickChannel(system, 9, 0)
  bp056Yes(picked == shortest, "channel zero uses lifetime selection")
  bp056Yes(sameEntity.sfx == descriptor, "channel zero never overrides matching entity")
  bp056Yes(picked.sfx is void, "lifetime victim cleared")
  return true
end function
// Exercise the listener protected test scenario and verify its expected result.
function bp056ListenerProtected()
  system = bp056System()
  descriptor = bp056Descriptor("protected.wav", 16)
  index = bp056Dma.DYNAMIC_FIRST
  while index < bp056Dma.DYNAMIC_FIRST + bp056Dma.MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    channel.sfx = descriptor
    channel.entityNumber = 100 + index
    channel.entityChannel = 1
    channel.endTime = 200 + index
    index = index + 1
  end while
  listener = system.mixState.channels[bp056Dma.DYNAMIC_FIRST]
  listener.entityNumber = 1
  listener.endTime = 100
  picked = bp056Dma.SND_PickChannel(system, 999, 1)
  bp056Yes(picked != listener, "listener protected")
  return true
end function
// Exercise the view entity volume test scenario and verify its expected result.
function bp056ViewEntityVolume()
  system = bp056System()
  channel = bp056Mix.createChannel()
  channel.entityNumber = 1
  channel.masterVolume = 211
  result = bp056Dma.SND_Spatialize(system, channel)
  bp056Equal(result[0], 211, "view left")
  bp056Equal(result[1], 211, "view right")
  return true
end function
// Exercise the stereo right test scenario and verify its expected result.
function bp056StereoRight()
  system = bp056System()
  channel = bp056Mix.createChannel()
  channel.entityNumber = 2
  channel.masterVolume = 255
  channel.distanceMultiplier = bp056Dma.soundF32(1.0 / 1000.0)
  channel.origin = bp056Types.Vec3(0.0, -100.0, 0.0)
  result = bp056Dma.SND_Spatialize(system, channel)
  bp056Equal(result[0], 0, "right source left")
  bp056Equal(result[1], 459, "right source right")
  return true
end function
// Exercise the stereo left test scenario and verify its expected result.
function bp056StereoLeft()
  system = bp056System()
  channel = bp056Mix.createChannel()
  channel.entityNumber = 2
  channel.masterVolume = 255
  channel.distanceMultiplier = bp056Dma.soundF32(1.0 / 1000.0)
  channel.origin = bp056Types.Vec3(0.0, 100.0, 0.0)
  result = bp056Dma.SND_Spatialize(system, channel)
  bp056Equal(result[0], 459, "left source left")
  bp056Equal(result[1], 0, "left source right")
  return true
end function
// Exercise the mono test scenario and verify its expected result.
function bp056Mono()
  system = bp056System()
  system.mixState.dma.channels = 1
  channel = bp056Mix.createChannel()
  channel.entityNumber = 2
  channel.masterVolume = 200
  channel.distanceMultiplier = bp056Dma.soundF32(1.0 / 1000.0)
  channel.origin = bp056Types.Vec3(0.0, 100.0, 0.0)
  result = bp056Dma.SND_Spatialize(system, channel)
  bp056Equal(result[0], 180, "mono left")
  bp056Equal(result[1], 180, "mono right")
  return true
end function
// Exercise the distance cutoff test scenario and verify its expected result.
function bp056DistanceCutoff()
  system = bp056System()
  channel = bp056Mix.createChannel()
  channel.entityNumber = 2
  channel.masterVolume = 255
  channel.distanceMultiplier = bp056Dma.soundF32(1.0 / 1000.0)
  channel.origin = bp056Types.Vec3(1000.0, 0.0, 0.0)
  result = bp056Dma.SND_Spatialize(system, channel)
  bp056Equal(result[0], 0, "cutoff left")
  bp056Equal(result[1], 0, "cutoff right")
  return true
end function
// Exercise the distance word test scenario and verify its expected result.
function bp056DistanceWord()
  value = bp056Dma.soundF32(1.0 / 1000.0)
  bp056Equal(bp056Native.floatBits(value), 0x3a83126f, "distance multiplier word")
  return true
end function
// Initialize state for master.
function bp056StartMaster()
  system = bp056System()
  descriptor = bp056Descriptor("half.wav", 16)
  result = bp056Dma.S_StartSound(system, 2, 1, descriptor, bp056Types.Vec3(0.0,0.0,0.0), 0.5, 1.0)
  bp056Yes(result, "start half volume")
  channel = system.mixState.channels[bp056Dma.DYNAMIC_FIRST]
  bp056Equal(channel.masterVolume, 127, "half master")
  return true
end function
// Initialize state for distance word.
function bp056StartDistanceWord()
  system = bp056System()
  descriptor = bp056Descriptor("distance.wav", 16)
  bp056Dma.S_StartSound(system, 2, 1, descriptor, bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.75)
  channel = system.mixState.channels[bp056Dma.DYNAMIC_FIRST]
  bp056Equal(bp056Native.floatBits(channel.distanceMultiplier), 0x3a449ba6, "0.75 distance word")
  return true
end function
// Exercise the duplicate offset test scenario and verify its expected result.
function bp056DuplicateOffset()
  system = bp056System()
  descriptor = bp056Descriptor("duplicate.wav", 128)
  bp056Dma.S_StartSound(system, 2, 0, descriptor, bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.0)
  bp056Dma.S_StartSound(system, 3, 0, descriptor, bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.0)
  bp056Equal(system.mixState.channels[bp056Dma.DYNAMIC_FIRST + 1].position, 41, "MSVC duplicate skip")
  return true
end function
// Finalize state for quirk.
function bp056StopQuirk()
  system = bp056System()
  descriptor = bp056Descriptor("stop.wav", 16)
  channel = system.mixState.channels[4]
  channel.sfx = descriptor
  channel.entityNumber = 12
  channel.entityChannel = 2
  bp056Yes(bp056Dma.S_StopSound(system, 12, 2), "first-eight stop")
  channel = system.mixState.channels[12]
  channel.sfx = descriptor
  channel.entityNumber = 99
  channel.entityChannel = 2
  bp056Equal(bp056Dma.S_StopSound(system, 99, 2), false, "outside first eight")
  return true
end function
// Exercise the ambient off on test scenario and verify its expected result.
function bp056AmbientOffOn()
  system = bp056System()
  bp056Equal(bp056Dma.S_AmbientOff(system), false, "ambient off")
  bp056Equal(system.ambientEnabled, false, "ambient disabled")
  bp056Equal(bp056Dma.S_AmbientOn(system), true, "ambient on")
  return true
end function
// Exercise the ambient fade test scenario and verify its expected result.
function bp056AmbientFade()
  system = bp056System()
  descriptor = bp056Descriptor("ambient.wav", 16)
  system.ambientSfx[0] = descriptor
  bp056Dma.S_UpdateAmbientSounds(system, [255,0,0,0], 0.1)
  bp056Yes(system.mixState.channels[0].masterVolume > 0, "ambient fade raised")
  bp056Yes(system.mixState.channels[0].sfx == descriptor, "ambient source")
  return true
end function
// Exercise the soundtime test scenario and verify its expected result.
function bp056Soundtime()
  system = bp056System()
  system.mixState.dma.samples = 16
  system.mixState.dma.channels = 2
  first = bp056Dma.GetSoundtime(system, 14)
  second = bp056Dma.GetSoundtime(system, 2)
  bp056Equal(first, 7, "soundtime first")
  bp056Equal(second, 9, "soundtime wrapped")
  return true
end function
// Update module state for ahead.
function bp056UpdateAhead()
  system = bp056System()
  system.mixState.dma.speed = 1000
  system.mixState.dma.samples = 4096
  system.mixState.dma.channels = 2
  system.mixAhead = 0.1
  result = bp056Dma.S_Update_(system, 0)
  bp056Equal(result, 100, "mixahead end")
  return true
end function
// Exercise the production replacement test scenario and verify its expected result.
function bp056ProductionReplacement()
  state = bp056Mixer.create(void, 22050)
  state.enabled = true
  state.listenerEntity = 1
  effect = bp056Effect("replace.wav", 16)
  state.effects = [effect]
  state.channels = [bp056MixerChannel(42, 2, effect, 3)]
  bp056Yes(bp056Mixer.startSound(state, 42, 2, "replace.wav", bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.0), "production replace")
  bp056Equal(bp056Mixer.dynamicChannelCount(state), 1, "one replacement slot")
  bp056Equal(state.channels[0].sample, 0, "replacement restarted")
  return true
end function
// Exercise the production capacity test scenario and verify its expected result.
function bp056ProductionCapacity()
  state = bp056Mixer.create(void, 22050)
  state.enabled = true
  effect = bp056Effect("capacity.wav", 32)
  state.effects = [effect]
  index = 0
  while index < bp056Mixer.MAX_DYNAMIC_CHANNELS
    state.channels = state.channels + [bp056MixerChannel(100 + index, 1, effect, index)]
    index = index + 1
  end while
  bp056Yes(bp056Mixer.startSound(state, 999, 1, "capacity.wav", bp056Types.Vec3(0.0,0.0,0.0), 1.0, 0.0), "capacity replace")
  bp056Equal(bp056Mixer.dynamicChannelCount(state), 8, "capacity remains eight")
  return true
end function
// Exercise the production volumes and local lifecycle test scenario and verify its expected result.
function bp056ProductionVolumesAndLocalLifecycle()
  state = bp056Mixer.create(void, 22050)
  state.listenerEntity = 1
  state.listenerOrigin = bp056Types.Vec3(0.0,0.0,0.0)
  state.listenerRight = bp056Types.Vec3(0.0,-1.0,0.0)
  effect = bp056Effect("volumes.wav", 4)
  channel = bp056Types.MixerChannel(2,1,effect,bp056Types.Vec3(0.0,-100.0,0.0),1.0,1.0,0,false,true,4)
  values = bp056Mixer.channelVolumes(state, channel)
  bp056Equal(values[0], 0, "production pan left")
  bp056Equal(values[1], 459, "production pan right")

  system = bp056System()
  descriptor = bp056Descriptor("misc/menu1.wav", 16)
  system.knownSfx = [descriptor]
  bp056Yes(bp056Dma.S_LocalSound(system, "misc/menu1.wav"), "local sound")
  first = bp056Descriptor("a.wav", 1)
  second = bp056Descriptor("b.wav", 1)
  system.knownSfx = [first, second]
  bp056Dma.S_ClearPrecache(system)
  bp056Equal(len(system.knownSfx), 2, "precache no-op retains descriptors")
  bp056Yes(system.knownSfx[0].cache is not void, "precache no-op retains first cache")
  bp056Yes(system.knownSfx[1].cache is not void, "precache no-op retains second cache")
  return true
end function

passed = 0
if bp056Run(1, "sound constants", bp056Constants) then passed = passed + 1 end if
if bp056Run(2, "matching channel override", bp056Override) then passed = passed + 1 end if
if bp056Run(3, "minus-one override", bp056MinusOneOverride) then passed = passed + 1 end if
if bp056Run(4, "channel zero selection", bp056ChannelZero) then passed = passed + 1 end if
if bp056Run(5, "listener protection", bp056ListenerProtected) then passed = passed + 1 end if
if bp056Run(6, "view-entity full volume", bp056ViewEntityVolume) then passed = passed + 1 end if
if bp056Run(7, "stereo right", bp056StereoRight) then passed = passed + 1 end if
if bp056Run(8, "stereo left", bp056StereoLeft) then passed = passed + 1 end if
if bp056Run(9, "mono spatialization", bp056Mono) then passed = passed + 1 end if
if bp056Run(10, "distance cutoff", bp056DistanceCutoff) then passed = passed + 1 end if
if bp056Run(11, "Binary32 distance word", bp056DistanceWord) then passed = passed + 1 end if
if bp056Run(12, "start master volume", bp056StartMaster) then passed = passed + 1 end if
if bp056Run(13, "start distance word", bp056StartDistanceWord) then passed = passed + 1 end if
if bp056Run(14, "duplicate offset", bp056DuplicateOffset) then passed = passed + 1 end if
if bp056Run(15, "stop-sound quirk", bp056StopQuirk) then passed = passed + 1 end if
if bp056Run(16, "ambient off/on", bp056AmbientOffOn) then passed = passed + 1 end if
if bp056Run(17, "ambient fade", bp056AmbientFade) then passed = passed + 1 end if
if bp056Run(18, "soundtime wrap", bp056Soundtime) then passed = passed + 1 end if
if bp056Run(19, "mixahead update", bp056UpdateAhead) then passed = passed + 1 end if
if bp056Run(20, "production exact replacement", bp056ProductionReplacement) then passed = passed + 1 end if
if bp056Run(21, "production capacity", bp056ProductionCapacity) then passed = passed + 1 end if
if bp056Run(22, "production Binary32 volumes and local lifecycle", bp056ProductionVolumesAndLocalLifecycle) then passed = passed + 1 end if
if passed != 22 then print "MiniQuake BP-056 audio DMA tests failed: " + passed + "/22"; error(5699, "BP-056 audio DMA") end if
print "MiniQuake BP-056 audio DMA tests passed: 22"
