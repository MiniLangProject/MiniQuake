/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Production-path sound parity tests.  These exercise sound/mixer.ml, the module
used by host.ml, rather than only the canonical snd_dma/snd_mix pendants.
*/
import miniquake.sound.mixer as mixer
import miniquake.sound.snd_mem as sndmem
import miniquake.types as t
import miniquake.byteio as bio
import miniquake.gl_vidnt as video

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9580, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9581, name + ": expected true") end if
  return true
end function

// Create and initialize effect.
function makeEffect(name, values, loopStart)
  data = bytes(len(values) * 2)
  index = 0
  while index < len(values)
    bio.putI16(data, index * 2, values[index])
    index = index + 1
  end while
  return t.SoundEffect(name, data, 22050, 2, 1, loopStart)
end function

// Create and initialize channel.
function makeChannel(entityNumber, channelNumber, effect, sample, volume)
  return t.MixerChannel(
    entityNumber,
    channelNumber,
    effect,
    t.Vec3(0.0, 0.0, 0.0),
    volume,
    0.0,
    sample,
    effect.loopStart >= 0,
    true,
    len(effect.samples) / effect.width,
  )
end function

// Return dynamic count derived from the active module state.
function dynamicCount(state)
  count = 0
  for each channel in state.channels
    if mixer.isDynamicChannel(channel) then count = count + 1 end if
  end for
  return count
end function

// Verify channel selection and duplicate offset against the expected Quake behavior.
function testChannelSelectionAndDuplicateOffset()
  state = mixer.create(void, 22050)
  state.enabled = true
  state.listenerEntity = 1
  effect = makeEffect("long.wav", [100, 200, 300, 400, 500, 600, 700, 800], -1)
  state.effects = [effect]

  index = 0
  while index < mixer.MAX_DYNAMIC_CHANNELS
    entityNumber = 100 + index
    if index == 0 then entityNumber = state.listenerEntity end if
    state.channels = state.channels + [makeChannel(entityNumber, 1, effect, index, 1.0)]
    index = index + 1
  end while
  // The listener slot has the shortest remaining life but is protected.
  assertEqual(mixer.startSound(state, 999, 1, "long.wav", t.Vec3(0.0, 0.0, 0.0), 1.0, 1.0), true, "replace non-listener")
  assertEqual(dynamicCount(state), mixer.MAX_DYNAMIC_CHANNELS, "fixed dynamic capacity")
  assertTrue(mixer.findChannel(state, state.listenerEntity, 1) is not void, "listener channel protected")

  // entchannel -1 replaces one matching slot, not every sound of the entity.
  state.channels = [
    makeChannel(42, 0, effect, 2, 1.0),
    makeChannel(42, 0, effect, 3, 1.0),
    makeChannel(43, 0, effect, 4, 1.0),
    makeChannel(44, 0, effect, 5, 1.0),
    makeChannel(45, 0, effect, 5, 1.0),
    makeChannel(46, 0, effect, 5, 1.0),
    makeChannel(47, 0, effect, 5, 1.0),
    makeChannel(48, 0, effect, 5, 1.0),
  ]
  assertEqual(mixer.startSound(state, 42, -1, "long.wav", t.Vec3(0.0, 0.0, 0.0), 1.0, 1.0), true, "entchannel minus one")
  owned = 0
  for each channel in state.channels
    if channel.entityNumber == 42 then owned = owned + 1 end if
  end for
  assertEqual(owned, 2, "single matching slot replaced")

  duplicate = mixer.create(void, 22050)
  duplicate.enabled = true
  duplicate.listenerEntity = 1
  duplicateEffect = makeEffect("duplicate.wav", [
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
  ], -1)
  duplicate.effects = [duplicateEffect]
  mixer.setRandomSeed(1)
  assertEqual(mixer.startSound(duplicate, 2, 0, "duplicate.wav", t.Vec3(0.0, 0.0, 0.0), 1.0, 1.0), true, "first duplicate")
  assertEqual(mixer.startSound(duplicate, 3, 0, "duplicate.wav", t.Vec3(0.0, 0.0, 0.0), 1.0, 1.0), true, "second duplicate")
  assertEqual(duplicate.channels[0].sample, 0, "first duplicate starts at zero")
  assertEqual(duplicate.channels[1].sample, 41, "MSVC rand duplicate offset")

  inaudible = mixer.create(void, 22050)
  inaudible.enabled = true
  assertEqual(mixer.startSound(
    inaudible,
    2,
    1,
    "never-load.wav",
    t.Vec3(100000.0, 0.0, 0.0),
    1.0,
    1.0
  ), false, "inaudible sound rejected")
  assertEqual(len(inaudible.effects), 0, "inaudible sound not loaded")
  return true
end function

// Verify static combine and stop quirk against the expected Quake behavior.
function testStaticCombineAndStopQuirk()
  state = mixer.create(void, 22050)
  state.enabled = true
  state.masterVolume = 1.0
  effect = makeEffect("static.wav", [200, 200, 200], 0)
  // 0.004 * 255 truncates to one. Combining first produces
  // (200 * 2) >> 8 == 1; mixing separately would produce zero.
  first = makeChannel(0, mixer.STATIC_CHANNEL, effect, 0, 0.004)
  second = makeChannel(0, mixer.STATIC_CHANNEL, effect, 0, 0.004)
  state.channels = [first, second]
  output = mixer.mix(state, 1)
  assertEqual(bio.i16(output, 0), 1, "static channels combined before 16-bit shift")
  assertEqual(first.sample, 1, "combined primary advances")
  assertEqual(second.sample, 0, "combined secondary remains phase-locked")

  dynamic = mixer.create(void, 22050)
  dynamic.enabled = true
  index = 0
  while index < 5
    dynamic.channels = dynamic.channels + [makeChannel(10 + index, 2, effect, 0, 1.0)]
    index = index + 1
  end while
  assertEqual(mixer.stopSound(dynamic, 14, 2), 0, "fifth dynamic outside original stop loop")
  assertEqual(mixer.stopSound(dynamic, 12, 2), 1, "first four dynamic stop range")
  return true
end function

// Verify loop boundary pcm and queue timing against the expected Quake behavior.
function testLoopBoundaryPcmAndQueueTiming()
  state = mixer.create(void, 22050)
  state.enabled = true
  state.masterVolume = 1.0
  state.listenerEntity = 1
  effect = makeEffect("loop.wav", [100, 200, 300, 400], 2)
  state.channels = [makeChannel(1, 1, effect, 0, 256.0 / 255.0)]
  output = mixer.mix(state, 6)
  assertEqual(bio.i16(output, 0), 400, "loop cue accumulates at paintbuffer zero")
  assertEqual(bio.i16(output, 4), 600, "loop cue second accumulated sample")
  assertEqual(bio.i16(output, 8), 300, "loop pre-boundary third sample")
  assertEqual(bio.i16(output, 12), 400, "loop pre-boundary fourth sample")
  assertEqual(bio.i16(output, 16), 0, "loop cue tail remains clear")
  assertEqual(bio.i16(output, 20), 0, "loop cue final tail remains clear")
  assertEqual(state.channels[0].sample, 2, "loop position after in-block restart")

  assertEqual(mixer.desiredQueuedBuffers(state, 0.0, 0.1), 5, "0.1 second mixahead")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.2, 0.1), 5, "frame time does not extend mixahead")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.0, 0.0), mixer.MIN_QUEUED_BUFFERS, "minimum queue")

  inaudible = mixer.create(void, 22050)
  inaudible.enabled = true
  inaudible.masterVolume = 1.0
  finite = makeEffect("finite.wav", [1000, 2000], -1)
  finiteChannel = makeChannel(2, 1, finite, 0, 1.0)
  finiteChannel.attenuation = 1.0
  finiteChannel.origin = t.Vec3(5000.0, 0.0, 0.0)
  inaudible.channels = [finiteChannel]
  silent = mixer.mix(inaudible, 1)
  assertEqual(bio.i16(silent, 0), 0, "inaudible channel is not painted")
  assertEqual(finiteChannel.sample, 0, "inaudible channel sample remains fixed")
  finiteChannel.origin = t.Vec3(0.0, 0.0, 0.0)
  audible = mixer.mix(inaudible, 1)
  assertEqual(bio.i16(audible, 0), 996, "channel resumes from start until absolute end")
  assertEqual(len(inaudible.channels), 0, "absolute channel end expires")

  clipped = mixer.create(void, 22050)
  clipped.enabled = true
  clipped.masterVolume = 1.0
  clipped.listenerEntity = 1
  clippedEffect = makeEffect("clip.wav", [32767, -32768], -1)
  clipped.channels = [makeChannel(1, 1, clippedEffect, 0, 2.0)]
  clippedOutput = mixer.mix(clipped, 2)
  assertEqual(bio.i16(clippedOutput, 0), 32767, "flattened PCM transfer clamps positive")
  assertEqual(bio.i16(clippedOutput, 4), -32768, "flattened PCM transfer clamps negative")

  music = mixer.create(void, 22050)
  music.enabled = true
  music.masterVolume = 1.0
  music.musicVolume = 1.0
  musicSamples = bytes(8)
  bio.putI16(musicSamples, 0, 1000)
  bio.putI16(musicSamples, 2, -2000)
  bio.putI16(musicSamples, 4, -3000)
  bio.putI16(musicSamples, 6, 4000)
  music.music = t.MusicTrack(2, bytes(), musicSamples, 22050, 2, 2, 0, false, true, false, 0, 2)
  musicOutput = mixer.mix(music, 2)
  assertEqual(bio.i16(musicOutput, 0), 1000, "flattened music decode reads stereo left")
  assertEqual(bio.i16(musicOutput, 2), -2000, "flattened music decode reads stereo right")
  assertEqual(bio.i16(musicOutput, 4), -3000, "flattened music decode preserves signed left")
  assertEqual(bio.i16(musicOutput, 6), 4000, "flattened music decode preserves signed right")
  return true
end function

// Verify focus block nesting against the expected Quake behavior.
function testFocusBlockNesting()
  state = mixer.create(void, 22050)
  state.enabled = true
  // Deterministic lifecycle exercise: audioReset is permitted to report no
  // physical device; the production block state must still nest exactly.
  state.audioState.opened = true
  assertEqual(mixer.block(state), 1, "first production block")
  assertEqual(mixer.block(state), 2, "nested production block")
  assertEqual(mixer.update(state, 0.016, 0.1), 0, "blocked production update")
  assertEqual(mixer.unblock(state), 1, "nested production unblock")
  assertEqual(mixer.unblock(state), 0, "final production unblock")
  assertEqual(mixer.unblock(state), 0, "unbalanced production unblock clamps at zero")
  videoState = video.createVideoState()
  video.VID_UseState(videoState)
  video.VID_SetSoundMixer(state)
  video.AppActivate(false, false)
  assertEqual(mixer.blockDepth(state), 1, "focus loss blocks production mixer")
  video.AppActivate(true, false)
  assertEqual(mixer.blockDepth(state), 0, "focus restore unblocks production mixer")
  state.audioState.opened = false

  commands = mixer.create(void, 22050)
  commands.enabled = true
  commands.listenerEntity = 1
  talk = makeEffect("misc/talk.wav", [100, 200, 300], -1)
  commands.effects = [talk]
  assertEqual(mixer.play(commands, ["play", "misc/talk"]), 1, "play command adds wav extension")
  assertEqual(commands.playHash, 346, "play command entity hash")
  listing = mixer.soundList(commands)
  assertEqual(len(listing[0]), 1, "soundlist resident entry")
  assertEqual(listing[1], 6, "soundlist resident bytes")
  return true
end function

// Verify malformed wave boundaries against the expected Quake behavior.
function testMalformedWaveBoundaries()
  truncated = bytes("RIFF")
  info = sndmem.GetWavinfo("truncated.wav", truncated, len(truncated))
  assertEqual(info.rate, 0, "truncated RIFF rejected")

  invalid = bytes(48)
  bio.copyInto(invalid, 0, bytes("RIFF"), 0, 4)
  bio.putU32(invalid, 4, 40)
  bio.copyInto(invalid, 8, bytes("WAVE"), 0, 4)
  bio.copyInto(invalid, 12, bytes("fmt "), 0, 4)
  bio.putU32(invalid, 16, 16)
  bio.putU16(invalid, 20, 3)
  bio.putU16(invalid, 22, 1)
  bio.putU32(invalid, 24, 11025)
  bio.putU16(invalid, 34, 16)
  bio.copyInto(invalid, 36, bytes("data"), 0, 4)
  bio.putU32(invalid, 40, 4)
  invalidResult = try(sndmem.S_LoadSoundData("float.wav", invalid, 22050, false))
  assertTrue(invalidResult is error, "non-PCM WAV rejected")

  overflow = bytes(48)
  bio.copyInto(overflow, 0, bytes("RIFF"), 0, 4)
  bio.putU32(overflow, 4, 40)
  bio.copyInto(overflow, 8, bytes("WAVE"), 0, 4)
  bio.copyInto(overflow, 12, bytes("fmt "), 0, 4)
  bio.putU32(overflow, 16, 16)
  bio.putU16(overflow, 20, 1)
  bio.putU16(overflow, 22, 1)
  bio.putU32(overflow, 24, 11025)
  bio.putU16(overflow, 34, 16)
  bio.copyInto(overflow, 36, bytes("data"), 0, 4)
  bio.putU32(overflow, 40, 0x7fffffff)
  overflowResult = try(sndmem.S_LoadSoundData("overflow.wav", overflow, 22050, false))
  assertTrue(overflowResult is error, "oversized data chunk rejected")
  return true
end function

// Verify spatial vector reuse against the expected Quake behavior.
function testSpatialVectorReuse()
  state = mixer.create(void, 22050)
  listenerOriginRaw = nativeRawValue(state.listenerOrigin)
  listenerForwardRaw = nativeRawValue(state.listenerForward)
  listenerRightRaw = nativeRawValue(state.listenerRight)
  mixer.updateListener(
    state,
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(0.0, 1.0, 0.0),
    t.Vec3(-1.0, 0.0, 0.0),
  )
  assertEqual(nativeRawValue(state.listenerOrigin), listenerOriginRaw, "listener origin storage reused")
  assertEqual(nativeRawValue(state.listenerForward), listenerForwardRaw, "listener forward storage reused")
  assertEqual(nativeRawValue(state.listenerRight), listenerRightRaw, "listener right storage reused")
  assertEqual(state.listenerOrigin.z, 3.0, "listener origin updated")

  effect = makeEffect("spatial.wav", [1, 2, 3], -1)
  channel = makeChannel(1, 1, effect, 0, 1.0)
  state.channels = [channel]
  entity = t.ClientEntityState(1, 1, 0, 0, 0, 0, t.Vec3(7.0, 8.0, 9.0), t.Vec3(0.0, 0.0, 0.0), 0.0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), false, void, 0.0)
  entities = [void, entity]
  channelOriginRaw = nativeRawValue(channel.origin)
  state.listenerEntity = 2
  mixer.updateEntityOrigins(state, entities)
  assertEqual(nativeRawValue(channel.origin), channelOriginRaw, "channel origin storage reused")
  assertEqual(channel.origin.y, 8.0, "channel origin updated")
  return true
end function

// Verify realtime paint storage reuse against the expected Quake behavior.
function testRealtimePaintStorageReuse()
  state = mixer.create(void, 22050)
  state.enabled = true
  state.masterVolume = 1.0
  state.listenerEntity = 1
  effect = makeEffect("resident-loop.wav", [100, 200, 300, 400], 0)
  state.channels = [makeChannel(1, 1, effect, 0, 1.0)]
  channelsRaw = nativeRawValue(state.channels)
  first = mixer.mixForSubmit(state, mixer.MIX_FRAMES)
  firstRaw = nativeRawValue(first)
  assertEqual(nativeRawValue(state.channels), channelsRaw, "resident channel array reused")
  second = mixer.mixForSubmit(state, mixer.MIX_FRAMES)
  assertEqual(nativeRawValue(second), firstRaw, "backend paint output reused")
  assertEqual(nativeRawValue(state.channels), channelsRaw, "resident channel array remains reused")
  assertEqual(bio.i16(second, 0), bio.i16(first, 0), "reused output retains PCM parity")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/7] production channel selection/duplicate offset"
  testChannelSelectionAndDuplicateOffset()
  print "[2/7] production static combine/stop quirk"
  testStaticCombineAndStopQuirk()
  print "[3/7] production loop PCM/queue timing"
  testLoopBoundaryPcmAndQueueTiming()
  print "[4/7] production focus block nesting"
  testFocusBlockNesting()
  print "[5/7] malformed WAV boundaries"
  testMalformedWaveBoundaries()
  print "[6/7] spatial vector storage reuse"
  testSpatialVectorReuse()
  print "[7/7] real-time paint storage reuse"
  testRealtimePaintStorageReuse()
  print "MiniQuake production sound parity tests passed: 7"
  return 0
end function
