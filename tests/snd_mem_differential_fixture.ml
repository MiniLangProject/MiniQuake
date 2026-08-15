/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/snd_mem_differential_fixture.ml.
*/
import miniquake.byteio as bio
import miniquake.filesystem as qfs
import miniquake.sound.snd_mem as memoryPort

// Create and initialize wave.
function makeWave()
  data = bytes(48)
  bio.copyInto(data, 0, bytes("RIFF"), 0, 4)
  bio.putU32(data, 4, 40)
  bio.copyInto(data, 8, bytes("WAVE"), 0, 4)
  bio.copyInto(data, 12, bytes("fmt "), 0, 4)
  bio.putU32(data, 16, 16)
  bio.putU16(data, 20, 1)
  bio.putU16(data, 22, 1)
  bio.putU32(data, 24, 11025)
  bio.putU32(data, 28, 11025)
  bio.putU16(data, 32, 1)
  bio.putU16(data, 34, 8)
  bio.copyInto(data, 36, bytes("data"), 0, 4)
  bio.putU32(data, 40, 4)
  data[44] = 128
  data[45] = 129
  data[46] = 130
  data[47] = 131
  return data
end function

// Exercise cache event as part of this deterministic regression fixture.
function cacheEvent(functionName, caseName, cache, cached)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"length\":" + cache.length + ",\"loopstart\":" + cache.loopStart +
    ",\"speed\":" + cache.speed + ",\"width\":" + cache.width +
    ",\"stereo\":" + cache.stereo + ",\"values\":[" +
    cache.data[0] + "," + cache.data[1] + "," + cache.data[2] + "," +
    cache.data[3] + "," + cache.data[4] + "," + cache.data[5] + "," +
    cache.data[6] + "," + cache.data[7] + "],\"cached\":" + cached + "}"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  wave = makeWave()
  cursor = memoryPort.createCursor(wave, len(wave))
  cursor.position = 20
  shortValue = memoryPort.GetLittleShort(cursor)
  print "{\"function\":\"GetLittleShort\",\"case\":\"format\",\"value\":" +
    shortValue + ",\"position\":" + cursor.position + "}"
  cursor.position = 24
  longValue = memoryPort.GetLittleLong(cursor)
  print "{\"function\":\"GetLittleLong\",\"case\":\"rate\",\"value\":" +
    longValue + ",\"position\":" + cursor.position + "}"

  cursor.iffData = 12
  cursor.lastChunk = 12
  nextOffset = memoryPort.FindNextChunk(cursor, "data")
  print "{\"function\":\"FindNextChunk\",\"case\":\"data\",\"offset\":" +
    nextOffset + ",\"length\":" + cursor.chunkLength + "}"
  foundOffset = memoryPort.FindChunk(cursor, "fmt ")
  print "{\"function\":\"FindChunk\",\"case\":\"fmt\",\"offset\":" +
    foundOffset + ",\"length\":" + cursor.chunkLength + "}"
  chunks = memoryPort.DumpChunks(cursor)
  print "{\"function\":\"DumpChunks\",\"case\":\"two\",\"count\":" + len(chunks) + "}"

  info = memoryPort.GetWavinfo("test.wav", wave, len(wave))
  print "{\"function\":\"GetWavinfo\",\"case\":\"pcm\",\"values\":[" +
    info.rate + "," + info.width + "," + info.channels + "," +
    info.loopStart + "," + info.samples + "," + info.dataOffset + "]}"

  cache = memoryPort.SoundCache(4, -1, 11025, 1, 1, bytes())
  resampled = memoryPort.ResampleSfx(
    cache,
    11025,
    1,
    slice(wave, 44, 4),
    22050,
    false,
  )
  cacheEvent("ResampleSfx", "double-rate", resampled, 0)

  filesystem = qfs.initialize(args[0], "id1")
  filesystem.staticRegistered = true
  descriptor = memoryPort.createDescriptor("test.wav")
  loaded = memoryPort.S_LoadSound(filesystem, descriptor, 22050, false)
  loadedAgain = memoryPort.S_LoadSound(filesystem, descriptor, 22050, false)
  cached = 0
  if loadedAgain == loaded then cached = 1 end if
  cacheEvent("S_LoadSound", "file-cache", loaded, cached)
  return 0
end function
