/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused snd_dma.c, snd_mem.c, snd_mix.c, and sound.h parity fixtures.
*/

import miniquake.sound.snd_mem as sndmem
import miniquake.sound.snd_mix as sndmix
import miniquake.sound.snd_dma as snddma
import miniquake.byteio as bio
import miniquake.types as t

function assertEqual(actual, expected, name)
  if actual != expected then return error(9400, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9401, name + ": expected true") end if
  return true
end function

function assertNear(actual, expected, epsilon, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > epsilon then return error(9402, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function makeLoopedWave()
  data = bytes(122)
  bio.copyInto(data, 0, bytes("RIFF"), 0, 4)
  bio.putU32(data, 4, 114)
  bio.copyInto(data, 8, bytes("WAVE"), 0, 4)
  bio.copyInto(data, 12, bytes("fmt "), 0, 4)
  bio.putU32(data, 16, 16)
  bio.putU16(data, 20, 1)
  bio.putU16(data, 22, 1)
  bio.putU32(data, 24, 11025)
  bio.putU32(data, 28, 11025)
  bio.putU16(data, 32, 1)
  bio.putU16(data, 34, 8)
  bio.copyInto(data, 36, bytes("cue "), 0, 4)
  bio.putU32(data, 40, 28)
  bio.putI32(data, 68, 2)
  bio.copyInto(data, 72, bytes("LIST"), 0, 4)
  bio.putU32(data, 76, 24)
  bio.putI32(data, 96, 4)
  bio.copyInto(data, 100, bytes("mark"), 0, 4)
  bio.copyInto(data, 104, bytes("data"), 0, 4)
  bio.putU32(data, 108, 10)
  index = 0
  while index < 10
    data[112 + index] = 128 + index
    index = index + 1
  end while
  return data
end function

function makeCache16(values, loopStart)
  data = bytes(len(values) * 2)
  index = 0
  while index < len(values)
    bio.putI16(data, index * 2, values[index])
    index = index + 1
  end while
  return sndmem.SoundCache(len(values), loopStart, 22050, 2, 0, data)
end function

function descriptorWithCache(name, cache)
  descriptor = sndmem.createDescriptor(name)
  descriptor.cache = cache
  return descriptor
end function

function testWaveChunksAndResample()
  wave = makeLoopedWave()
  cursor = sndmem.createCursor(wave, len(wave))
  assertEqual(sndmem.FindChunk(cursor, "RIFF"), 0, "FindChunk RIFF")
  cursor.iffData = 12
  assertEqual(sndmem.FindChunk(cursor, "fmt "), 12, "FindChunk fmt")
  assertEqual(sndmem.FindNextChunk(cursor, "data"), 104, "FindNextChunk data")
  cursor.position = 20
  assertEqual(sndmem.GetLittleShort(cursor), 1, "GetLittleShort PCM")
  cursor.position = 24
  assertEqual(sndmem.GetLittleLong(cursor), 11025, "GetLittleLong rate")
  chunks = sndmem.DumpChunks(cursor)
  assertEqual(len(chunks), 4, "DumpChunks count")

  info = sndmem.GetWavinfo("loop.wav", wave, len(wave))
  assertEqual(info.rate, 11025, "GetWavinfo rate")
  assertEqual(info.width, 1, "GetWavinfo width")
  assertEqual(info.channels, 1, "GetWavinfo channels")
  assertEqual(info.loopStart, 2, "GetWavinfo cue")
  assertEqual(info.samples, 6, "GetWavinfo marked loop length")
  assertEqual(info.dataOffset, 112, "GetWavinfo data offset")

  cache = sndmem.S_LoadSoundData("loop.wav", wave, 22050, false)
  assertEqual(cache.length, 12, "ResampleSfx output length")
  assertEqual(cache.loopStart, 4, "ResampleSfx loop scaling")
  assertEqual(cache.width, 1, "ResampleSfx width")
  assertEqual(cache.data[0], 0, "ResampleSfx signed eight-bit zero")
  assertEqual(cache.data[2], 1, "ResampleSfx fixed-point source step")
  allocation = sndmem.S_Alloc(17)
  assertEqual(len(allocation), 17, "S_Alloc")
  return true
end function

function testSixteenBitPaintAndLoop()
  dma = sndmix.createDma(22050, 16, 2, 2048)
  state = sndmix.createState(dma)
  state.volume = 1.0
  cache = makeCache16([1000, -1000, 32767, -32768], -1)
  descriptor = descriptorWithCache("pcm16", cache)
  channel = state.channels[0]
  channel.sfx = descriptor
  channel.leftVolume = 255
  channel.rightVolume = 255
  channel.endTime = 4
  state.totalChannels = 1
  assertEqual(sndmix.S_PaintChannels(state, 4), 4, "S_PaintChannels end")
  assertEqual(bio.i16(dma.buffer, 0), 996, "PCM positive one-LSB fixture")
  assertEqual(bio.i16(dma.buffer, 4), -997, "PCM negative one-LSB fixture")
  assertEqual(bio.i16(dma.buffer, 8), 32639, "PCM positive clamp-free fixture")
  assertEqual(bio.i16(dma.buffer, 12), -32640, "PCM negative clamp-free fixture")
  assertTrue(channel.sfx is void, "non-looping channel stops")

  loopDma = sndmix.createDma(22050, 16, 2, 2048)
  loopState = sndmix.createState(loopDma)
  loopState.volume = 1.0
  loopCache = makeCache16([100, 200, 300, 400], 2)
  loopDescriptor = descriptorWithCache("loop16", loopCache)
  loopChannel = loopState.channels[0]
  loopChannel.sfx = loopDescriptor
  loopChannel.leftVolume = 256
  loopChannel.rightVolume = 256
  loopChannel.endTime = 4
  loopState.totalChannels = 1
  sndmix.S_PaintChannels(loopState, 6)
  // GLQuake restarts a cue inside the same paint block at paintbuffer[0].
  // Preserve that observable 1.09 quirk instead of offsetting by localTime.
  assertEqual(bio.i16(loopDma.buffer, 0), 400, "loop cue overwrites from paintbuffer zero")
  assertEqual(bio.i16(loopDma.buffer, 4), 600, "loop cue second accumulated sample")
  assertEqual(bio.i16(loopDma.buffer, 12), 400, "loop sample three")
  assertEqual(bio.i16(loopDma.buffer, 16), 0, "loop cue tail remains clear")
  assertEqual(bio.i16(loopDma.buffer, 20), 0, "loop cue tail continuation remains clear")
  assertEqual(loopChannel.position, 2, "loop position after boundary")
  return true
end function

function testPaintBlocksAndFormats()
  values = []
  index = 0
  while index < 513
    values = values + [256]
    index = index + 1
  end while
  dma = sndmix.createDma(22050, 16, 2, 4096)
  state = sndmix.createState(dma)
  state.volume = 1.0
  cache = makeCache16(values, -1)
  descriptor = descriptorWithCache("block513", cache)
  channel = state.channels[0]
  channel.sfx = descriptor
  channel.leftVolume = 255
  channel.rightVolume = 255
  channel.endTime = 513
  state.totalChannels = 1
  sndmix.S_PaintChannels(state, 513)
  assertEqual(state.paintedTime, 513, "512-sample block boundary time")
  assertEqual(channel.position, 513, "512-sample block boundary position")
  assertEqual(bio.i16(dma.buffer, 512 * 4), 255, "sample after 512 boundary")

  monoDma = sndmix.createDma(11025, 8, 1, 8)
  monoState = sndmix.createState(monoDma)
  monoState.volume = 1.0
  monoState.paintBuffer[0] = 32767
  monoState.paintBuffer[2] = -32768
  assertEqual(sndmix.S_TransferPaintBuffer(monoState, 2), 2, "8-bit mono transfer count")
  assertEqual(monoDma.buffer[0], 255, "8-bit positive transfer")
  assertEqual(monoDma.buffer[1], 0, "8-bit negative transfer")

  scaleState = sndmix.createState(sndmix.createDma(11025, 16, 2, 32))
  signedCache = sndmem.SoundCache(1, -1, 11025, 1, 0, bytes([255]))
  scaleDescriptor = descriptorWithCache("signed8", signedCache)
  scaleChannel = scaleState.channels[0]
  scaleChannel.sfx = scaleDescriptor
  scaleChannel.leftVolume = 255
  scaleChannel.rightVolume = 255
  sndmix.SND_PaintChannelFrom8(scaleState, scaleChannel, signedCache, 1)
  assertEqual(scaleState.paintBuffer[0], -248, "SND_InitScaletable signed sample")
  return true
end function

function testChannelControlAndSpatialization()
  system = snddma.create(void, 22050)
  assertEqual(snddma.S_Init(system, ["-simsound"], 0x1000000), true, "S_Init")
  assertEqual(system.fakeDma, true, "S_Init -simsound")
  system.listenerEntity = 1
  cache = makeCache16([100, 200, 300, 400], 0)
  descriptor = descriptorWithCache("control.wav", cache)

  index = snddma.DYNAMIC_FIRST
  while index < snddma.DYNAMIC_FIRST + snddma.MAX_DYNAMIC_CHANNELS
    channel = system.mixState.channels[index]
    channel.sfx = descriptor
    channel.entityNumber = 100 + index
    channel.entityChannel = 1
    channel.endTime = 20 + index
    index = index + 1
  end while
  protected = system.mixState.channels[snddma.DYNAMIC_FIRST]
  protected.entityNumber = 1
  protected.endTime = 1
  picked = snddma.SND_PickChannel(system, 999, 1)
  assertTrue(picked != protected, "SND_PickChannel protects listener sound")

  override = system.mixState.channels[snddma.DYNAMIC_FIRST + 3]
  override.sfx = descriptor
  override.entityNumber = 42
  override.entityChannel = 2
  pickedOverride = snddma.SND_PickChannel(system, 42, 2)
  assertEqual(pickedOverride.entityNumber, 42, "SND_PickChannel entity override")
  assertTrue(pickedOverride.sfx is void, "SND_PickChannel clears victim")

  spatial = sndmix.createChannel()
  spatial.entityNumber = 2
  spatial.origin = t.Vec3(0.0, -500.0, 0.0)
  spatial.distanceMultiplier = 0.001
  spatial.masterVolume = 255
  volumes = snddma.SND_Spatialize(system, spatial)
  assertEqual(volumes[0], 0, "SND_Spatialize hard left attenuation")
  assertEqual(volumes[1], 255, "SND_Spatialize hard right")

  local = sndmix.createChannel()
  local.entityNumber = 1
  local.masterVolume = 201
  localVolumes = snddma.SND_Spatialize(system, local)
  assertEqual(localVolumes[0], 201, "view entity left full volume")
  assertEqual(localVolumes[1], 201, "view entity right full volume")

  snddma.S_StopAllSounds(system, true)
  assertEqual(snddma.S_StartSound(system, 1, 1, descriptor, t.Vec3(9000.0, 0.0, 0.0), 1.0, 1.0), true, "S_StartSound view entity")
  assertEqual(snddma.S_StopSound(system, 1, 1), true, "S_StopSound original first-eight range")
  assertEqual(snddma.S_StaticSound(system, descriptor, t.Vec3(0.0, 0.0, 0.0), 255.0, 64.0), true, "S_StaticSound loop cue")
  assertEqual(system.mixState.totalChannels, snddma.STATIC_FIRST + 1, "static channel count")
  return true
end function

function testAmbientTimingAndCommands()
  system = snddma.create(void, 22050)
  snddma.S_Init(system, ["-simsound"], 0x1000000)
  assertEqual(snddma.SNDDMA_Init(system), true, "SNDDMA_Init fake bridge")
  assertEqual(snddma.SNDDMA_GetDMAPos(system), 0, "SNDDMA_GetDMAPos")
  assertEqual(snddma.SNDDMA_Submit(system), true, "SNDDMA_Submit fake bridge")
  assertEqual(len(snddma.S_InitPaintChannels(system)), 32 * 256, "S_InitPaintChannels")
  cache = makeCache16([100, 200, 300, 400], 0)
  descriptor = descriptorWithCache("beep.wav", cache)
  system.ambientSfx[0] = descriptor
  assertEqual(snddma.S_UpdateAmbientSounds(system, [255, 0, 0, 0], 0.1), true, "S_UpdateAmbientSounds")
  assertEqual(system.mixState.channels[0].masterVolume, 10, "ambient fade step")
  snddma.S_AmbientOff(system)
  assertEqual(snddma.S_UpdateAmbientSounds(system, [255, 0, 0, 0], 1.0), false, "S_AmbientOff")
  snddma.S_AmbientOn(system)

  system.knownSfx = [descriptor]
  system.listenerEntity = 1
  assertEqual(snddma.S_Play(system, ["beep"]), 1, "S_Play extension and event")
  snddma.S_StopAllSoundsC(system)
  assertEqual(snddma.S_PlayVol(system, ["beep", "0.5"]), 1, "S_PlayVol")
  listResult = snddma.S_SoundList(system)
  assertEqual(len(listResult[0]), 1, "S_SoundList resident count")
  assertEqual(listResult[1], 8, "S_SoundList resident bytes")
  assertEqual(snddma.S_LocalSound(system, "beep.wav"), true, "S_LocalSound")
  assertEqual(snddma.S_TouchSound(system, "beep.wav"), true, "S_TouchSound")
  assertTrue(snddma.S_PrecacheSound(system, "beep.wav") == descriptor, "S_PrecacheSound identity")
  assertTrue(snddma.S_FindName(system, "beep.wav") == descriptor, "S_FindName identity")
  assertEqual(snddma.S_ClearPrecache(system), true, "S_ClearPrecache")
  assertEqual(snddma.S_BeginPrecaching(system), true, "S_BeginPrecaching")
  assertEqual(snddma.S_EndPrecaching(system), true, "S_EndPrecaching")

  info = snddma.S_SoundInfo_f(system)
  assertEqual(len(info), 8, "S_SoundInfo_f fields")
  assertEqual(snddma.GetSoundtime(system, 30000), 15000, "GetSoundtime current buffer")
  assertEqual(snddma.GetSoundtime(system, 100), 16434, "GetSoundtime wrapped buffer")
  system.mixAhead = 0.0
  system.mixState.paintedTime = system.mixState.soundTime
  assertEqual(snddma.S_Update_(system, 100), system.mixState.soundTime, "S_Update_ zero mixahead")
  assertEqual(snddma.S_ExtraUpdate(system, 100), system.mixState.soundTime, "S_ExtraUpdate")
  system.noExtraUpdate = true
  assertEqual(snddma.S_ExtraUpdate(system, 100), 0, "snd_noextraupdate")

  system.mixState.dma.sampleBits = 8
  system.mixState.dma.buffer[0] = 0
  snddma.S_ClearBuffer(system)
  assertEqual(system.mixState.dma.buffer[0], 128, "S_ClearBuffer unsigned silence")
  snddma.S_StopAllSounds(system, false)
  updateResult = snddma.S_Update(
    system,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    [0, 0, 0, 0],
    0.016,
    100,
  )
  assertEqual(updateResult, true, "S_Update")
  assertEqual(snddma.S_Shutdown(system), true, "S_Shutdown")
  assertEqual(system.dmaOpened, false, "SNDDMA_Shutdown through S_Shutdown")
  assertEqual(snddma.S_Startup(system), true, "S_Startup")
  assertEqual(snddma.SNDDMA_Shutdown(system), true, "SNDDMA_Shutdown")
  return true
end function

function main(args)
  print "[1/5] WAVE chunks/resampling"
  testWaveChunksAndResample()
  print "[2/5] 16-bit paint/loop cues"
  testSixteenBitPaintAndLoop()
  print "[3/5] 512-block and DMA formats"
  testPaintBlocksAndFormats()
  print "[4/5] channel control/spatialization"
  testChannelControlAndSpatialization()
  print "[5/5] ambient/timing/commands"
  testAmbientTimingAndCommands()
  print "MiniQuake sound-core compatibility tests passed: 5"
  return 0
end function
