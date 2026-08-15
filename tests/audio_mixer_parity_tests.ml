/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-057: snd_mix.c 32-bit paintbuffer and PCM transfer parity.
*/
import miniquake.sound.snd_mix as bp057Mix
import miniquake.sound.snd_mem as bp057Mem
import miniquake.byteio as bp057Bio

// Assert exact equality and report both values on failure.
function bp057Equal(actual, expected, name)
  if actual != expected then return error(5700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp057Yes(value, name)
  if not value then return error(5701, name + ": expected true") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp057Run(number, name, fn)
  print "[" + number + "/22] " + name
  value = try(fn())
  if value is error then print "FAIL: " + value.message; return false end if
  return true
end function
// Exercise the cache16 test scenario and verify its expected result.
function bp057Cache16(values, loopStart)
  data = bytes(len(values) * 2)
  index = 0
  while index < len(values)
    bp057Bio.putI16(data, index * 2, values[index])
    index = index + 1
  end while
  return bp057Mem.SoundCache(len(values), loopStart, 22050, 2, 0, data)
end function
// Exercise the descriptor test scenario and verify its expected result.
function bp057Descriptor(values, loopStart)
  descriptor = bp057Mem.createDescriptor("fixture.wav")
  descriptor.cache = bp057Cache16(values, loopStart)
  return descriptor
end function

// Return constants for the active module state.
function bp057Constants()
  bp057Equal(bp057Mix.PAINTBUFFER_SIZE, 512, "paintbuffer")
  bp057Equal(bp057Mix.MAX_CHANNELS, 128, "channels")
  return true
end function
// Exercise the signed byte test scenario and verify its expected result.
function bp057SignedByte()
  bp057Equal(bp057Mix.signedByte(0), 0, "signed zero")
  bp057Equal(bp057Mix.signedByte(128), -128, "signed 128")
  bp057Equal(bp057Mix.signedByte(255), -1, "signed 255")
  return true
end function
// Exercise the i32 test scenario and verify its expected result.
function bp057I32()
  bp057Equal(bp057Mix.soundI32(0xffffffff), -1, "i32 minus one")
  bp057Equal(bp057Mix.soundI32(0x80000000), -2147483648, "i32 minimum")
  bp057Equal(bp057Mix.soundI32(0x100000001), 1, "i32 wrap")
  return true
end function
// Return a validated clamp value.
function bp057Clamp()
  bp057Equal(bp057Mix.clamp16(40000), 32767, "positive clamp")
  bp057Equal(bp057Mix.clamp16(-40000), -32768, "negative clamp")
  bp057Equal(bp057Mix.clamp16(123), 123, "inside clamp")
  return true
end function
// Exercise the scale table test scenario and verify its expected result.
function bp057ScaleTable()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  bp057Equal(state.scaleTable[31 * 256 + 255], -248, "scale -1")
  bp057Equal(state.scaleTable[16 * 256 + 128], -16384, "scale -128")
  bp057Equal(state.scaleTable[1 * 256 + 1], 8, "scale one")
  return true
end function
// Exercise the linear clamp test scenario and verify its expected result.
function bp057LinearClamp()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.paintBuffer[0] = 40000; state.paintBuffer[1] = -40000
  state.linearSource = 0; state.linearCount = 2; state.linearOutput = 0; state.transferVolume = 256
  bp057Mix.Snd_WriteLinearBlastStereo16(state)
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), 32767, "linear positive")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 2), -32768, "linear negative")
  return true
end function
// Exercise the linear overflow test scenario and verify its expected result.
function bp057LinearOverflow()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.paintBuffer[0] = 0x7fffffff
  state.linearSource = 0; state.linearCount = 1; state.linearOutput = 0; state.transferVolume = 256
  bp057Mix.Snd_WriteLinearBlastStereo16(state)
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), -1, "32-bit transfer wrap")
  return true
end function
// Exercise the stereo transfer test scenario and verify its expected result.
function bp057StereoTransfer()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.volume = 1.0
  state.paintBuffer[0] = 1000; state.paintBuffer[1] = -1000
  state.paintBuffer[2] = 2000; state.paintBuffer[3] = -2000
  bp057Equal(bp057Mix.S_TransferStereo16(state, 2), 2, "stereo frames")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), 1000, "stereo left 0")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 6), -2000, "stereo right 1")
  return true
end function
// Exercise the stereo ring wrap test scenario and verify its expected result.
function bp057StereoRingWrap()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.volume = 1.0; state.paintedTime = 3
  state.paintBuffer[0] = 10; state.paintBuffer[1] = 20
  state.paintBuffer[2] = 30; state.paintBuffer[3] = 40
  bp057Mix.S_TransferStereo16(state, 5)
  bp057Equal(bp057Bio.i16(state.dma.buffer, 12), 10, "ring frame three left")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), 30, "ring frame zero left")
  return true
end function
// Exercise the mono8 test scenario and verify its expected result.
function bp057Mono8()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 8, 1, 8))
  state.volume = 1.0; state.paintBuffer[0] = 256; state.paintBuffer[2] = -256
  bp057Equal(bp057Mix.S_TransferPaintBuffer(state, 2), 2, "mono bytes")
  bp057Equal(state.dma.buffer[0], 129, "mono positive")
  bp057Equal(state.dma.buffer[1], 127, "mono negative")
  return true
end function
// Exercise the mono16 test scenario and verify its expected result.
function bp057Mono16()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 1, 8))
  state.volume = 1.0; state.paintBuffer[0] = 1000; state.paintBuffer[2] = -1000
  bp057Mix.S_TransferPaintBuffer(state, 2)
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), 1000, "mono16 first")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 2), -1000, "mono16 second")
  return true
end function
// Exercise the paint8 test scenario and verify its expected result.
function bp057Paint8()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  channel = state.channels[0]; channel.leftVolume = 255; channel.rightVolume = 128
  cache = bp057Mem.SoundCache(3, -1, 22050, 1, 0, bytes([0,128,255]))
  bp057Mix.SND_PaintChannelFrom8(state, channel, cache, 3)
  bp057Equal(state.paintBuffer[0], 0, "paint8 zero")
  bp057Equal(state.paintBuffer[2], -31744, "paint8 negative full")
  bp057Equal(state.paintBuffer[5], -128, "paint8 right minus one")
  return true
end function
// Exercise the paint16 test scenario and verify its expected result.
function bp057Paint16()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  channel = state.channels[0]; channel.leftVolume = 128; channel.rightVolume = 64
  cache = bp057Cache16([1000,-2000,3000], -1)
  bp057Mix.SND_PaintChannelFrom16(state, channel, cache, 3)
  bp057Equal(state.paintBuffer[0], 500, "paint16 left first")
  bp057Equal(state.paintBuffer[1], 250, "paint16 right first")
  bp057Equal(state.paintBuffer[2], -1000, "paint16 left second")
  return true
end function
// Exercise the paint16 overflow test scenario and verify its expected result.
function bp057Paint16Overflow()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  channel = state.channels[0]; channel.leftVolume = 131072; channel.rightVolume = 0
  cache = bp057Cache16([32767], -1)
  bp057Mix.SND_PaintChannelFrom16(state, channel, cache, 1)
  bp057Equal(state.paintBuffer[0], -512, "paint multiplication wraps")
  return true
end function
// Update module state for buffer.
function bp057ClearBuffer()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.paintBuffer[0] = 9; state.paintBuffer[3] = 7; state.paintBuffer[4] = 5
  bp057Mix.clearPaintBuffer(state, 2)
  bp057Equal(state.paintBuffer[0], 0, "clear first")
  bp057Equal(state.paintBuffer[3], 0, "clear fourth")
  bp057Equal(state.paintBuffer[4], 5, "clear boundary")
  return true
end function
// Exercise the paint channels test scenario and verify its expected result.
function bp057PaintChannels()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  state.volume = 1.0; state.totalChannels = 1
  descriptor = bp057Descriptor([1000,-1000,2000,-2000], -1)
  channel = state.channels[0]; channel.sfx = descriptor; channel.leftVolume = 255; channel.rightVolume = 255; channel.endTime = 4
  bp057Equal(bp057Mix.S_PaintChannels(state, 4), 4, "painted time")
  bp057Yes(channel.sfx is void, "finite channel ends")
  bp057Equal(bp057Bio.i16(state.dma.buffer, 0), 996, "paint output")
  return true
end function
// Exercise the loop restart test scenario and verify its expected result.
function bp057LoopRestart()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 16))
  state.volume = 1.0; state.totalChannels = 1
  descriptor = bp057Descriptor([100,200,300,400], 2)
  channel = state.channels[0]; channel.sfx = descriptor; channel.leftVolume = 255; channel.rightVolume = 255; channel.endTime = 4
  bp057Mix.S_PaintChannels(state, 6)
  bp057Equal(channel.position, 2, "loop restarted at boundary")
  bp057Yes(channel.sfx is not void, "loop remains active")
  return true
end function
// Finalize state for before painted.
function bp057EndBeforePainted()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8)); state.paintedTime = 5
  result = try(bp057Mix.S_PaintChannels(state, 4))
  bp057Yes(result is error, "end before painted")
  return true
end function
// Exercise the chunk boundary test scenario and verify its expected result.
function bp057ChunkBoundary()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 2048)); state.volume = 1.0
  bp057Equal(bp057Mix.S_PaintChannels(state, 513), 513, "two paint blocks")
  return true
end function
// Exercise the dma defaults test scenario and verify its expected result.
function bp057DmaDefaults()
  dma = bp057Mix.createDma(0, 7, 3, 0)
  bp057Equal(dma.speed, 22050, "default rate")
  bp057Equal(dma.sampleBits, 16, "default bits")
  bp057Equal(dma.channels, 2, "default channels")
  return true
end function
// Exercise the channel reset test scenario and verify its expected result.
function bp057ChannelReset()
  channel = bp057Mix.createChannel(); channel.leftVolume = 10; channel.sfx = bp057Descriptor([1], -1)
  bp057Mix.resetChannel(channel)
  bp057Equal(channel.leftVolume, 0, "reset volume")
  bp057Yes(channel.sfx is void, "reset source")
  return true
end function
// Exercise the scale clamp and volume test scenario and verify its expected result.
function bp057ScaleClampAndVolume()
  state = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8))
  channel = state.channels[0]; channel.leftVolume = 999; channel.rightVolume = 999
  cache = bp057Mem.SoundCache(1, -1, 22050, 1, 0, bytes([129]))
  bp057Mix.SND_PaintChannelFrom8(state, channel, cache, 1)
  bp057Equal(channel.leftVolume, 255, "8-bit left clamp")
  bp057Equal(channel.rightVolume, 255, "8-bit right clamp")

  volumeState = bp057Mix.createState(bp057Mix.createDma(22050, 16, 2, 8)); volumeState.volume = 0.5
  volumeState.paintBuffer[0] = 1000; volumeState.paintBuffer[1] = -1000
  bp057Mix.S_TransferStereo16(volumeState, 1)
  bp057Equal(bp057Bio.i16(volumeState.dma.buffer, 0), 500, "master half left")
  bp057Equal(bp057Bio.i16(volumeState.dma.buffer, 2), -500, "master half right")
  return true
end function

passed = 0
if bp057Run(1,"mixer constants",bp057Constants) then passed=passed+1 end if
if bp057Run(2,"signed byte",bp057SignedByte) then passed=passed+1 end if
if bp057Run(3,"signed 32-bit wrapping",bp057I32) then passed=passed+1 end if
if bp057Run(4,"16-bit clamp",bp057Clamp) then passed=passed+1 end if
if bp057Run(5,"8-bit scale table",bp057ScaleTable) then passed=passed+1 end if
if bp057Run(6,"linear clamp",bp057LinearClamp) then passed=passed+1 end if
if bp057Run(7,"linear i32 overflow",bp057LinearOverflow) then passed=passed+1 end if
if bp057Run(8,"stereo transfer",bp057StereoTransfer) then passed=passed+1 end if
if bp057Run(9,"stereo ring wrap",bp057StereoRingWrap) then passed=passed+1 end if
if bp057Run(10,"mono 8-bit transfer",bp057Mono8) then passed=passed+1 end if
if bp057Run(11,"mono 16-bit transfer",bp057Mono16) then passed=passed+1 end if
if bp057Run(12,"8-bit channel paint",bp057Paint8) then passed=passed+1 end if
if bp057Run(13,"16-bit channel paint",bp057Paint16) then passed=passed+1 end if
if bp057Run(14,"16-bit multiply wrap",bp057Paint16Overflow) then passed=passed+1 end if
if bp057Run(15,"paintbuffer clear",bp057ClearBuffer) then passed=passed+1 end if
if bp057Run(16,"finite channel paint",bp057PaintChannels) then passed=passed+1 end if
if bp057Run(17,"loop restart",bp057LoopRestart) then passed=passed+1 end if
if bp057Run(18,"end-before-painted error",bp057EndBeforePainted) then passed=passed+1 end if
if bp057Run(19,"512-frame chunk boundary",bp057ChunkBoundary) then passed=passed+1 end if
if bp057Run(20,"DMA defaults",bp057DmaDefaults) then passed=passed+1 end if
if bp057Run(21,"channel reset",bp057ChannelReset) then passed=passed+1 end if
if bp057Run(22,"volume and 8-bit clamp",bp057ScaleClampAndVolume) then passed=passed+1 end if
if passed != 22 then print "MiniQuake BP-057 audio mixer tests failed: " + passed + "/22"; error(5799,"BP-057 audio mixer") end if
print "MiniQuake BP-057 audio mixer tests passed: 22"
