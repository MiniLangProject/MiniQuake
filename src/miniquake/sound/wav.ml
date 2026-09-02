/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sound.wav.
*/
package miniquake.sound.wav

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.native as native
import std.fs as fs

/// Implements the `parse` operation for `miniquake.sound.wav` (parse).
/// @param data Input data consumed by the operation.
/// @param filename Path of the file to process.
function parse(data, filename)
  if len(data) < 12 or bio.fourCC(data, 0) != "RIFF" or bio.fourCC(data, 8) != "WAVE" then
    return error(1950, filename + ": not a RIFF/WAVE file")
  end if
  formatTag = 0
  channels = 0
  rate = 0
  width = 0
  dataOffset = -1
  dataLength = 0
  loopStart = -1
  loopLength = -1
  offset = 12
  while offset + 8 <= len(data)
    chunkName = bio.fourCC(data, offset)
    chunkLength = bio.u32(data, offset + 4)
    chunkData = offset + 8
    if chunkData + chunkLength > len(data) then return error(1951, filename + ": WAVE chunk outside file") end if
    if chunkName == "fmt " then
      if chunkLength < 16 then return error(1952, filename + ": short WAVE fmt chunk") end if
      formatTag = bio.u16(data, chunkData)
      channels = bio.u16(data, chunkData + 2)
      rate = bio.u32(data, chunkData + 4)
      width = bio.u16(data, chunkData + 14) / 8
    else if chunkName == "data" then
      dataOffset = chunkData
      dataLength = chunkLength
    else if chunkName == "cue " and chunkLength >= 28 then
      loopStart = bio.i32(data, chunkData + 24)
    else if chunkName == "LIST" and chunkLength >= 24 and offset + 32 <= len(data) then
      // WinQuake accepts Cool Edit's LIST/mark extension: the integer at
      // chunk+24 is the number of samples in the loop.
      if bio.fourCC(data, offset + 28) == "mark" then loopLength = bio.i32(data, offset + 24) end if
    end if
    offset = chunkData + chunkLength
    if offset % 2 != 0 then offset = offset + 1 end if
  end while
  if formatTag != 1 then return error(1953, filename + ": only PCM WAVE is supported") end if
  if channels != 1 and channels != 2 then return error(1954, filename + ": unsupported WAVE channel count") end if
  if width != 1 and width != 2 then return error(1955, filename + ": unsupported WAVE sample width") end if
  if dataOffset < 0 then return error(1956, filename + ": missing WAVE data chunk") end if
  samples = dataLength / (width * channels)
  if loopStart >= 0 then
    if loopStart >= samples then return error(1958, filename + ": WAVE loop starts outside sample data") end if
    if loopLength > 0 then
      loopEnd = loopStart + loopLength
      if loopEnd > samples then return error(1959, filename + ": WAVE loop length exceeds sample data") end if
      // Match GetWavinfo: data after the marked loop is not part of the sound.
      samples = loopEnd
    end if
  end if
  return t.WaveInfo(rate, width, channels, samples, loopStart, dataOffset, dataLength)
end function

/// Implements the `load` operation for `miniquake.sound.wav` (load).
/// @param filename Path of the file to process.
function load(filename)
  data = fs.readAllBytes(filename)
  return [parse(data, filename), data]
end function

/// Build deterministic test data for at.
/// @param info The info input consumed by `sampleAt`.
/// @param data Input data consumed by the operation.
/// @param sampleIndex Zero-based index of the requested entry.
/// @param channel The channel input consumed by `sampleAt`.
function sampleAt(info, data, sampleIndex, channel)
  frameOffset = info.dataOffset + sampleIndex * info.width * info.channels + channel * info.width
  if info.width == 1 then return data[frameOffset] - 128 end if
  return bio.i16(data, frameOffset)
end function

/// Implements the `resample` operation for `miniquake.sound.wav` (resample).
/// @param info The info input consumed by `resample`.
/// @param data Input data consumed by the operation.
/// @param targetRate The target rate input consumed by `resample`.
/// @param force8Bit The force8 bit input consumed by `resample`.
function resample(info, data, targetRate, force8Bit)
  if targetRate <= 0 then return error(1957, "invalid resample rate") end if
  outSamples = native.trunc(info.samples * targetRate / info.rate)
  if outSamples < 0 then outSamples = 0 end if
  outWidth = info.width
  if force8Bit then outWidth = 1 end if
  output = bytes(outSamples * outWidth)
  i = 0
  while i < outSamples
    sourceIndex = native.trunc(i * info.rate / targetRate)
    if sourceIndex >= info.samples then sourceIndex = info.samples - 1 end if
    sample = sampleAt(info, data, sourceIndex, 0)
    if outWidth == 1 then
      if info.width == 2 then sample = sample >> 8 end if
      output[i] = sample & 255
    else
      if info.width == 1 then sample = sample << 8 end if
      bio.putI16(output, i * 2, sample)
    end if
    i = i + 1
  end while
  return output
end function
