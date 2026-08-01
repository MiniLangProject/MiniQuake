/* BP-055: snd_mem.c WAVE parsing and Binary32 resampling parity. */
import miniquake.sound.snd_mem as bp055Mem
import miniquake.byteio as bp055Bio
import miniquake.native as bp055Native

function bp055Equal(actual, expected, name)
  if actual != expected then return error(5500, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp055Yes(value, name)
  if not value then return error(5501, name + ": expected true") end if
  return true
end function
function bp055Run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function bp055Wave8(channels)
  data = bytes(48)
  bp055Bio.copyInto(data, 0, bytes("RIFF"), 0, 4)
  bp055Bio.putU32(data, 4, 40)
  bp055Bio.copyInto(data, 8, bytes("WAVE"), 0, 4)
  bp055Bio.copyInto(data, 12, bytes("fmt "), 0, 4)
  bp055Bio.putU32(data, 16, 16)
  bp055Bio.putU16(data, 20, 1)
  bp055Bio.putU16(data, 22, channels)
  bp055Bio.putU32(data, 24, 11025)
  bp055Bio.putU32(data, 28, 11025 * channels)
  bp055Bio.putU16(data, 32, channels)
  bp055Bio.putU16(data, 34, 8)
  bp055Bio.copyInto(data, 36, bytes("data"), 0, 4)
  bp055Bio.putU32(data, 40, 4)
  data[44] = 128
  data[45] = 129
  data[46] = 130
  data[47] = 131
  return data
end function

function bp055Source16(values)
  data = bytes(len(values) * 2)
  index = 0
  while index < len(values)
    bp055Bio.putI16(data, index * 2, values[index])
    index = index + 1
  end while
  return data
end function

function bp055Riff()
  info = bp055Mem.GetWavinfo("fixture.wav", bp055Wave8(1), 48)
  bp055Equal(info.rate, 11025, "rate")
  bp055Equal(info.width, 1, "width")
  bp055Equal(info.channels, 1, "channels")
  bp055Equal(info.samples, 4, "samples")
  bp055Equal(info.dataOffset, 44, "data offset")
  return true
end function
function bp055LittleShort()
  data = bytes(2); data[0] = 0x34; data[1] = 0x12
  cursor = bp055Mem.createCursor(data, 2)
  bp055Equal(bp055Mem.GetLittleShort(cursor), 0x1234, "little short")
  return true
end function
function bp055LittleLong()
  data = bytes(4); data[0] = 0x78; data[1] = 0x56; data[2] = 0x34; data[3] = 0x12
  cursor = bp055Mem.createCursor(data, 4)
  bp055Equal(bp055Mem.GetLittleLong(cursor), 0x12345678, "little long")
  return true
end function
function bp055FindChunks()
  wave = bp055Wave8(1)
  cursor = bp055Mem.createCursor(wave, len(wave))
  bp055Equal(bp055Mem.FindChunk(cursor, "RIFF"), 0, "RIFF offset")
  cursor.iffData = 12
  bp055Equal(bp055Mem.FindChunk(cursor, "fmt "), 12, "fmt offset")
  bp055Equal(bp055Mem.FindChunk(cursor, "data"), 36, "data offset")
  return true
end function
function bp055StereoRejected()
  result = try(bp055Mem.S_LoadSoundData("stereo.wav", bp055Wave8(2), 11025, false))
  bp055Yes(result is error, "stereo rejected")
  return true
end function
function bp055Identity8()
  cache = bp055Mem.SoundCache(4, -1, 11025, 1, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 11025, 1, bytes([128,129,130,131]), 11025, false)
  bp055Equal(result.length, 4, "identity length")
  bp055Equal(result.data[0], 0, "identity 0")
  bp055Equal(result.data[3], 3, "identity 3")
  return true
end function
function bp055DoubleRate()
  cache = bp055Mem.SoundCache(4, -1, 11025, 1, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 11025, 1, bytes([128,129,130,131]), 22050, false)
  bp055Equal(result.length, 8, "double length")
  bp055Equal(result.data[0], 0, "double first")
  bp055Equal(result.data[2], 1, "double second pair")
  bp055Equal(result.data[7], 3, "double final")
  return true
end function
function bp055HalfRate()
  cache = bp055Mem.SoundCache(4, -1, 22050, 1, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 22050, 1, bytes([128,129,130,131]), 11025, false)
  bp055Equal(result.length, 2, "half length")
  bp055Equal(result.data[0], 0, "half first")
  bp055Equal(result.data[1], 2, "half second")
  return true
end function
function bp055SixteenBit()
  cache = bp055Mem.SoundCache(5, -1, 48000, 2, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 48000, 2, bp055Source16([0,1000,-1000,32767,-32768]), 22050, false)
  bp055Equal(result.length, 2, "16-bit length")
  bp055Equal(bp055Bio.i16(result.data, 0), 0, "16-bit first")
  bp055Equal(bp055Bio.i16(result.data, 2), -1000, "16-bit second")
  return true
end function
function bp055LoadAs8()
  cache = bp055Mem.SoundCache(5, 2, 22050, 2, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 22050, 2, bp055Source16([0,1000,-1000,32767,-32768]), 44100, true)
  bp055Equal(result.width, 1, "8-bit output width")
  bp055Equal(result.length, 10, "8-bit output length")
  bp055Equal(result.loopStart, 4, "8-bit loop scale")
  bp055Equal(result.data[6], 127, "8-bit positive clip word")
  return true
end function
function bp055LoopScale()
  cache = bp055Mem.SoundCache(8, 4, 11025, 1, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 11025, 1, bytes([128,129,130,131,132,133,134,135]), 22050, false)
  bp055Equal(result.loopStart, 8, "loop scale")
  return true
end function
function bp055Binary32Step()
  value = bp055Mem.soundF32(48000.0 / 22050.0)
  bp055Equal(bp055Native.floatBits(value), 0x400b51da, "stepscale word")
  return true
end function
function bp055Binary32Count()
  source = bytes(100, 128)
  cache = bp055Mem.SoundCache(100, -1, 48000, 1, 1, bytes())
  result = bp055Mem.ResampleSfx(cache, 48000, 1, source, 22050, false)
  bp055Equal(result.length, 45, "binary32 count")
  return true
end function
function bp055Truncated()
  cache = bp055Mem.SoundCache(4, -1, 11025, 2, 1, bytes())
  result = try(bp055Mem.ResampleSfx(cache, 11025, 2, bytes(6), 11025, false))
  bp055Yes(result is error, "truncated source")
  return true
end function
function bp055NegativeLength()
  cache = bp055Mem.SoundCache(-1, -1, 11025, 1, 1, bytes())
  result = try(bp055Mem.ResampleSfx(cache, 11025, 1, bytes(), 11025, false))
  bp055Yes(result is error, "negative length")
  return true
end function
function bp055InvalidRate()
  cache = bp055Mem.SoundCache(1, -1, 11025, 1, 1, bytes())
  result = try(bp055Mem.ResampleSfx(cache, 0, 1, bytes([128]), 11025, false))
  bp055Yes(result is error, "invalid rate")
  return true
end function
function bp055InvalidWidth()
  cache = bp055Mem.SoundCache(1, -1, 11025, 3, 1, bytes())
  result = try(bp055Mem.ResampleSfx(cache, 11025, 3, bytes(3), 11025, false))
  bp055Yes(result is error, "invalid width")
  return true
end function
function bp055DescriptorCache()
  descriptor = bp055Mem.createDescriptor("cached.wav")
  descriptor.cache = bp055Mem.SoundCache(1, -1, 11025, 1, 1, bytes([0]))
  bp055Yes(bp055Mem.S_LoadSound(void, descriptor, 11025, false) == descriptor.cache, "cache identity")
  return true
end function
function bp055SoundPath()
  bp055Equal(bp055Mem.soundPath("misc/menu1.wav"), "sound/misc/menu1.wav", "sound prefix")
  bp055Equal(bp055Mem.soundPath("sound/misc/menu1.wav"), "sound/misc/menu1.wav", "existing prefix")
  return true
end function
function bp055EffectConversionAndMalformed()
  descriptor = bp055Mem.createDescriptor("effect.wav")
  descriptor.cache = bp055Mem.SoundCache(2, 1, 22050, 2, 1, bp055Source16([123,-456]))
  effect = bp055Mem.toSoundEffect(descriptor)
  bp055Equal(effect.name, "effect.wav", "effect name")
  bp055Equal(effect.loopStart, 1, "effect loop")
  bp055Equal(bp055Bio.i16(effect.samples, 2), -456, "effect payload")

  info = bp055Mem.GetWavinfo("broken.wav", bytes("RIFF"), 4)
  bp055Equal(info.rate, 0, "malformed rate")
  return true
end function

passed = 0
if bp055Run(1, "RIFF PCM metadata", bp055Riff) then passed = passed + 1 end if
if bp055Run(2, "little short", bp055LittleShort) then passed = passed + 1 end if
if bp055Run(3, "little long", bp055LittleLong) then passed = passed + 1 end if
if bp055Run(4, "chunk search", bp055FindChunks) then passed = passed + 1 end if
if bp055Run(5, "stereo rejection", bp055StereoRejected) then passed = passed + 1 end if
if bp055Run(6, "identity 8-bit", bp055Identity8) then passed = passed + 1 end if
if bp055Run(7, "double-rate resample", bp055DoubleRate) then passed = passed + 1 end if
if bp055Run(8, "half-rate resample", bp055HalfRate) then passed = passed + 1 end if
if bp055Run(9, "16-bit resample", bp055SixteenBit) then passed = passed + 1 end if
if bp055Run(10, "load-as-8-bit", bp055LoadAs8) then passed = passed + 1 end if
if bp055Run(11, "loop scaling", bp055LoopScale) then passed = passed + 1 end if
if bp055Run(12, "Binary32 stepscale", bp055Binary32Step) then passed = passed + 1 end if
if bp055Run(13, "Binary32 outcount", bp055Binary32Count) then passed = passed + 1 end if
if bp055Run(14, "truncated source", bp055Truncated) then passed = passed + 1 end if
if bp055Run(15, "negative length", bp055NegativeLength) then passed = passed + 1 end if
if bp055Run(16, "invalid rate", bp055InvalidRate) then passed = passed + 1 end if
if bp055Run(17, "invalid width", bp055InvalidWidth) then passed = passed + 1 end if
if bp055Run(18, "descriptor cache", bp055DescriptorCache) then passed = passed + 1 end if
if bp055Run(19, "sound path", bp055SoundPath) then passed = passed + 1 end if
if bp055Run(20, "effect conversion and malformed RIFF", bp055EffectConversionAndMalformed) then passed = passed + 1 end if
if passed != 20 then print "MiniQuake BP-055 audio memory tests failed: " + passed + "/20"; error(5599, "BP-055 audio memory") end if
print "MiniQuake BP-055 audio memory tests passed: 20"
