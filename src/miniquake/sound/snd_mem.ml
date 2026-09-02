/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.snd_mem.
*/
package miniquake.sound.snd_mem

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.filesystem as qfs
import miniquake.array_util as arrays

// Logical MiniLang counterpart of WinQuake/snd_mem.c.  Cache ownership is
// represented by object reachability; the observable sample metadata and
// resampling rules remain the original ones.

struct SoundCache
  /// Stores the length value in `miniquake.sound.snd_mem.SoundCache`.
  length
  /// Stores the loop start value in `miniquake.sound.snd_mem.SoundCache`.
  loopStart
  /// Stores the speed value in `miniquake.sound.snd_mem.SoundCache`.
  speed
  /// Stores the width value in `miniquake.sound.snd_mem.SoundCache`.
  width
  /// Stores the stereo value in `miniquake.sound.snd_mem.SoundCache`.
  stereo
  /// Stores the data value in `miniquake.sound.snd_mem.SoundCache`.
  data
end struct

// Group the fields that describe one sound descriptor.
struct SoundDescriptor
  /// Stores the name value in `miniquake.sound.snd_mem.SoundDescriptor`.
  name
  /// Stores the cache value in `miniquake.sound.snd_mem.SoundDescriptor`.
  cache
end struct

// Group the fields that describe one chunk cursor.
struct ChunkCursor
  /// Stores the data value in `miniquake.sound.snd_mem.ChunkCursor`.
  data
  /// Stores the end offset value in `miniquake.sound.snd_mem.ChunkCursor`.
  endOffset
  /// Stores the iff data value in `miniquake.sound.snd_mem.ChunkCursor`.
  iffData
  /// Stores the position value in `miniquake.sound.snd_mem.ChunkCursor`.
  position
  /// Stores the last chunk value in `miniquake.sound.snd_mem.ChunkCursor`.
  lastChunk
  /// Stores the chunk length value in `miniquake.sound.snd_mem.ChunkCursor`.
  chunkLength
end struct

/// Implements the `emptyWaveInfo` operation for `miniquake.sound.snd_mem` (empty wave info).
function emptyWaveInfo()
  return t.WaveInfo(0, 0, 0, 0, 0, 0, 0)
end function

/// Apply the Quake-compatible s alloc behavior.
/// @param size Size of the requested data or resource.
function S_Alloc(size)
  if size < 0 then return error(2450, "S_Alloc: negative size") end if
  return bytes(size)
end function

/// Create and initialize descriptor.
/// @param name Stable name that identifies the requested object or option.
function createDescriptor(name)
  return SoundDescriptor(name, void)
end function

/// Create and initialize cursor.
/// @param data Input data consumed by the operation.
/// @param length Length of the requested data in units appropriate to the operation.
function createCursor(data, length)
  if data is void then data = bytes() end if
  if length < 0 then length = 0 end if
  if length > len(data) then length = len(data) end if
  return ChunkCursor(data, length, 0, 0, 0, 0)
end function

/// Return little short.
/// @param cursor The cursor input consumed by `GetLittleShort`.
function GetLittleShort(cursor)
  if cursor.position < 0 or cursor.position + 2 > cursor.endOffset then
    return error(2451, "GetLittleShort: read past WAVE data")
  end if
  value = bio.u16(cursor.data, cursor.position)
  cursor.position = cursor.position + 2
  if value >= 0x8000 then value = value - 0x10000 end if
  return value
end function

/// Return little long.
/// @param cursor The cursor input consumed by `GetLittleLong`.
function GetLittleLong(cursor)
  if cursor.position < 0 or cursor.position + 4 > cursor.endOffset then
    return error(2452, "GetLittleLong: read past WAVE data")
  end if
  value = bio.u32(cursor.data, cursor.position)
  cursor.position = cursor.position + 4
  if value >= 0x80000000 then value = value - 0x100000000 end if
  return value
end function

/// Implements the `chunkNameAt` operation for `miniquake.sound.snd_mem` (chunk name at).
/// @param cursor The cursor input consumed by `chunkNameAt`.
/// @param offset Zero-based offset of the requested data.
function chunkNameAt(cursor, offset)
  if offset < 0 or offset + 4 > cursor.endOffset then return "" end if
  return bio.fourCC(cursor.data, offset)
end function

/// Return next chunk.
/// @param cursor The cursor input consumed by `FindNextChunk`.
/// @param name Stable name that identifies the requested object or option.
function FindNextChunk(cursor, name)
  while true
    cursor.position = cursor.lastChunk
    if cursor.position < 0 or cursor.position >= cursor.endOffset then
      cursor.position = -1
      return -1
    end if
    if cursor.position + 8 > cursor.endOffset then
      cursor.position = -1
      return -1
    end if

    chunkStart = cursor.position
    cursor.position = cursor.position + 4
    chunkLength = GetLittleLong(cursor)
    if chunkLength is error or chunkLength < 0 then
      cursor.position = -1
      return -1
    end if
    cursor.chunkLength = chunkLength
    cursor.position = chunkStart
    nextChunk = chunkStart + 8 + ((chunkLength + 1) & -2)
    if nextChunk <= chunkStart then
      cursor.position = -1
      return -1
    end if
    cursor.lastChunk = nextChunk
    if chunkNameAt(cursor, chunkStart) == name then return chunkStart end if
  end while
end function

/// Return chunk.
/// @param cursor The cursor input consumed by `FindChunk`.
/// @param name Stable name that identifies the requested object or option.
function FindChunk(cursor, name)
  cursor.lastChunk = cursor.iffData
  return FindNextChunk(cursor, name)
end function

/// Implements the `DumpChunks` operation for `miniquake.sound.snd_mem` (dump chunks).
/// @param cursor The cursor input consumed by `DumpChunks`.
function DumpChunks(cursor)
  result = arrays.createArrayBuilder(8)
  cursor.position = cursor.iffData
  while cursor.position >= 0 and cursor.position + 8 <= cursor.endOffset
    start = cursor.position
    name = chunkNameAt(cursor, start)
    cursor.position = start + 4
    size = GetLittleLong(cursor)
    if size is error or size < 0 then break end if
    arrays.pushArrayBuilder(result, [start, name, size])
    cursor.position = start + 8 + ((size + 1) & -2)
  end while
  return arrays.finishArrayBuilder(result)
end function

/// Return wavinfo.
/// @param name Stable name that identifies the requested object or option.
/// @param wav The wav input consumed by `GetWavinfo`.
/// @param wavLength Length of the requested data in units appropriate to the operation.
function GetWavinfo(name, wav, wavLength)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  info = emptyWaveInfo()
  if wav is void then return info end if
  cursor = createCursor(wav, wavLength)

  riff = FindChunk(cursor, "RIFF")
  if riff < 0 or riff + 12 > cursor.endOffset or chunkNameAt(cursor, riff + 8) != "WAVE" then
    return info
  end if

  cursor.iffData = riff + 12
  formatChunk = FindChunk(cursor, "fmt ")
  if formatChunk < 0 or formatChunk + 24 > cursor.endOffset then return info end if
  cursor.position = formatChunk + 8
  format = GetLittleShort(cursor)
  if format is error or format != 1 then return info end if
  channels = GetLittleShort(cursor)
  rate = GetLittleLong(cursor)
  if channels is error or rate is error then return info end if
  cursor.position = cursor.position + 6
  widthBits = GetLittleShort(cursor)
  if widthBits is error then return info end if
  width = widthBits / 8
  if width <= 0 then return info end if

  loopStart = -1
  markedSamples = 0
  cueChunk = FindChunk(cursor, "cue ")
  if cueChunk >= 0 and cueChunk + 36 <= cursor.endOffset then
    cursor.position = cueChunk + 32
    loopStartValue = GetLittleLong(cursor)
    if loopStartValue is not error then loopStart = loopStartValue end if
    listChunk = FindNextChunk(cursor, "LIST")
    if listChunk >= 0 and listChunk + 32 <= cursor.endOffset and chunkNameAt(cursor, listChunk + 28) == "mark" then
      cursor.position = listChunk + 24
      loopLength = GetLittleLong(cursor)
      if loopLength is not error then markedSamples = loopStart + loopLength end if
    end if
  end if

  dataChunk = FindChunk(cursor, "data")
  if dataChunk < 0 or dataChunk + 8 > cursor.endOffset then return info end if
  cursor.position = dataChunk + 4
  dataLength = GetLittleLong(cursor)
  if dataLength is error or dataLength < 0 then return info end if
  dataOffset = cursor.position
  if dataOffset + dataLength > cursor.endOffset then return info end if

  samples = dataLength / width
  if markedSamples > 0 then
    if samples < markedSamples then return error(2453, "Sound " + name + " has a bad loop length") end if
    samples = markedSamples
  end if
  return t.WaveInfo(rate, width, channels, samples, loopStart, dataOffset, dataLength)
end function

/// Implements the `soundF32` operation for `miniquake.sound.snd_mem` (sound f32).
/// @param value Value consumed by `soundF32`.
function soundF32(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Implements the `ResampleSfx` operation for `miniquake.sound.snd_mem` (resample sfx).
/// @param cache The cache input consumed by `ResampleSfx`.
/// @param inRate The in rate input consumed by `ResampleSfx`.
/// @param inWidth The in width input consumed by `ResampleSfx`.
/// @param source Source value or collection to read.
/// @param targetRate The target rate input consumed by `ResampleSfx`.
/// @param loadAs8Bit The load as8 bit input consumed by `ResampleSfx`.
function ResampleSfx(cache, inRate, inWidth, source, targetRate, loadAs8Bit)
  if cache is void then return error(2454, "ResampleSfx: null cache") end if
  if inRate <= 0 or targetRate <= 0 then return error(2455, "ResampleSfx: invalid sample rate") end if
  if inWidth != 1 and inWidth != 2 then return error(2456, "ResampleSfx: invalid source width") end if

  sourceLength = cache.length
  if sourceLength < 0 then return error(2463, "ResampleSfx: negative source length") end if
  requiredBytes = sourceLength * inWidth
  if requiredBytes > len(source) then return error(2464, "ResampleSfx: source data is truncated") end if

  // snd_mem.c stores stepscale as float. Keep both the division and the
  // fixed-point step at that binary32 boundary so long resamples cannot drift.
  stepScale = soundF32((inRate * 1.0) / targetRate)
  outCount = native.trunc(soundF32(sourceLength / stepScale))
  if outCount < 0 then outCount = 0 end if
  if cache.loopStart != -1 then
    cache.loopStart = native.trunc(soundF32(cache.loopStart / stepScale))
  end if
  cache.length = outCount
  cache.speed = targetRate
  if loadAs8Bit then cache.width = 1 else cache.width = inWidth end if
  cache.stereo = 0
  cache.data = S_Alloc(outCount * cache.width)

  if stepScale == 1.0 and inWidth == 1 and cache.width == 1 then
    index = 0
    while index < outCount
      cache.data[index] = (source[index] - 128) & 255
      index = index + 1
    end while
    return cache
  end if

  sampleFraction = 0
  fractionStep = native.trunc(soundF32(stepScale * 256.0))
  index = 0
  while index < outCount
    sourceSample = sampleFraction >> 8
    sampleFraction = sampleFraction + fractionStep
    if sourceSample < 0 then sourceSample = 0 end if
    if sourceSample >= sourceLength then sourceSample = sourceLength - 1 end if
    if sourceSample < 0 then sourceSample = 0 end if
    sample = 0
    if inWidth == 2 then
      sample = bio.i16(source, sourceSample * 2)
    else
      sample = (source[sourceSample] - 128) << 8
    end if
    if cache.width == 2 then
      bio.putI16(cache.data, index * 2, sample)
    else
      cache.data[index] = (sample >> 8) & 255
    end if
    index = index + 1
  end while
  return cache
end function

/// Apply the Quake-compatible s load sound data behavior.
/// @param name Stable name that identifies the requested object or option.
/// @param data Input data consumed by the operation.
/// @param targetRate The target rate input consumed by `S_LoadSoundData`.
/// @param loadAs8Bit The load as8 bit input consumed by `S_LoadSoundData`.
function S_LoadSoundData(name, data, targetRate, loadAs8Bit)
  info = GetWavinfo(name, data, len(data))
  if info is error then return info end if
  if info.rate <= 0 or info.width <= 0 then return error(2457, "Couldn't load sound/" + name) end if
  if info.channels != 1 then return error(2458, name + " is a stereo sample") end if
  if info.width != 1 and info.width != 2 then return error(2461, name + " has an unsupported sample width") end if
  if info.loopStart < -1 or info.loopStart >= info.samples then
    return error(2462, "Sound " + name + " has an invalid loop start")
  end if
  sourceBytes = info.samples * info.width
  if info.dataOffset + sourceBytes > len(data) then return error(2459, name + ": sample data outside WAVE") end if
  source = slice(data, info.dataOffset, sourceBytes)
  cache = SoundCache(info.samples, info.loopStart, info.rate, info.width, info.channels, bytes())
  return ResampleSfx(cache, cache.speed, cache.width, source, targetRate, loadAs8Bit)
end function

/// Return sound path derived from the active module state.
/// @param name Stable name that identifies the requested object or option.
function soundPath(name)
  nameBytes = bytes(name)
  if len(nameBytes) >= 6 and decode(slice(nameBytes, 0, 6)) == "sound/" then return name end if
  return "sound/" + name
end function

/// Apply the Quake-compatible s load sound behavior.
/// @param filesystem The filesystem input consumed by `S_LoadSound`.
/// @param descriptor The descriptor input consumed by `S_LoadSound`.
/// @param targetRate The target rate input consumed by `S_LoadSound`.
/// @param loadAs8Bit The load as8 bit input consumed by `S_LoadSound`.
function S_LoadSound(filesystem, descriptor, targetRate, loadAs8Bit)
  if descriptor is void then return error(2460, "S_LoadSound: null sfx") end if
  if descriptor.cache is not void then return descriptor.cache end if
  source = try(qfs.readFile(filesystem, soundPath(descriptor.name)))
  if source is error then return source end if
  cache = S_LoadSoundData(descriptor.name, source, targetRate, loadAs8Bit)
  if cache is error then return cache end if
  descriptor.cache = cache
  return cache
end function

/// Implements the `toSoundEffect` operation for `miniquake.sound.snd_mem` (to sound effect).
/// @param descriptor The descriptor input consumed by `toSoundEffect`.
function toSoundEffect(descriptor)
  if descriptor is void or descriptor.cache is void then return void end if
  cache = descriptor.cache
  return t.SoundEffect(descriptor.name, cache.data, cache.speed, cache.width, 1, cache.loopStart)
end function
