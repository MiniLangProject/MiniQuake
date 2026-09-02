/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang pendant for WinQuake/wad.c and wad.h.  The C globals are represented
by the WadArchive returned from W_LoadWadFile and passed to lookup functions.
*/
package miniquake.wad

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import miniquake.protocol_text as quakeText
import std.fs as fs

/// Defines the cmp none value used by `miniquake.wad`.
const CMP_NONE = 0
/// Defines the cmp lzss value used by `miniquake.wad`.
const CMP_LZSS = 1

/// Defines the typ none value used by `miniquake.wad`.
const TYP_NONE = 0
/// Defines the typ label value used by `miniquake.wad`.
const TYP_LABEL = 1
/// Defines the typ lumpy value used by `miniquake.wad`.
const TYP_LUMPY = 64
/// Defines the typ palette value used by `miniquake.wad`.
const TYP_PALETTE = 64
/// Defines the typ qtex value used by `miniquake.wad`.
const TYP_QTEX = 65
/// Defines the typ qpic value used by `miniquake.wad`.
const TYP_QPIC = 66
/// Defines the typ sound value used by `miniquake.wad`.
const TYP_SOUND = 67
/// Defines the typ miptex value used by `miniquake.wad`.
const TYP_MIPTEX = 68

/// Defines the wad name length value used by `miniquake.wad`.
const WAD_NAME_LENGTH = 16
/// Defines the wad lumpinfo size value used by `miniquake.wad`.
const WAD_LUMPINFO_SIZE = 32

/// W_CleanupName lowercases only ASCII A-Z, stops at the first NUL, truncates
/// at 16 bytes, and NUL-pads the rest.  Returning the fixed buffer preserves
/// the exact lumpinfo_t name representation and is safe for in-place callers.
/// @param input The input input consumed by `W_CleanupName`.
function W_CleanupName(input)
  source = input
  if input is not bytes then
    source = quakeText.encodeBytes(input)
    if source is error then return source end if
  end if
  output = bytes(WAD_NAME_LENGTH)
  index = 0
  while index < WAD_NAME_LENGTH and index < len(source)
    value = source[index]
    if value == 0 then break end if
    if value >= 65 and value <= 90 then value = value + 32 end if
    output[index] = value
    index = index + 1
  end while
  return output
end function

/// Implements the `cleanupNameText` operation for `miniquake.wad` (cleanup name text).
/// @param input The input input consumed by `cleanupNameText`.
function cleanupNameText(input)
  cleaned = W_CleanupName(input)
  length = 0
  while length < WAD_NAME_LENGTH and cleaned[length] != 0
    length = length + 1
  end while
  return quakeText.decodeBytes(slice(cleaned, 0, length))
end function

/// SwapPic performs the two LittleLong conversions from the original.  The
/// supported Windows x64 build is little-endian, but writing the decoded values
/// back makes the operation explicit and keeps the observable in-place API.
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
function SwapPic(data, offset)
  if typeof(data) != "bytes" then return error(1557, "qpic buffer must be bytes") end if
  if offset < 0 or offset + 8 > len(data) then return error(1557, "WAD picture header is truncated") end if
  width = bio.i32(data, offset)
  height = bio.i32(data, offset + 4)
  bio.putI32(data, offset, width)
  bio.putI32(data, offset + 4, height)
  return [width, height]
end function

/// Data-oriented counterpart used when gfx.wad came from a Quake search path
/// (most retail installs keep it inside pak0.pak).
/// @param data Input data consumed by the operation.
/// @param filename Path of the file to process.
function W_LoadWadData(data, filename)
  if typeof(data) != "bytes" then return error(1550, filename + ": WAD data must be bytes") end if
  if len(data) < 12 then return error(1550, filename + ": WAD header is truncated") end if
  if bio.fourCC(data, 0) != "WAD2" then return error(1551, filename + ": expected WAD2") end if

  count = bio.i32(data, 4)
  directoryOffset = bio.i32(data, 8)
  if count < 0 or directoryOffset < 0 then
    return error(1552, filename + ": invalid WAD directory")
  end if
  directorySize = count * WAD_LUMPINFO_SIZE
  if directorySize < 0 or directoryOffset > len(data) or directorySize > len(data) - directoryOffset then
    return error(1552, filename + ": invalid WAD directory")
  end if

  lumps = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    offset = directoryOffset + index * WAD_LUMPINFO_SIZE
    filePosition = bio.i32(data, offset)
    diskSize = bio.i32(data, offset + 4)
    size = bio.i32(data, offset + 8)
    type = bio.u8(data, offset + 12)
    compression = bio.u8(data, offset + 13)
    name = cleanupNameText(slice(data, offset + 16, WAD_NAME_LENGTH))

    if filePosition < 0 or diskSize < 0 or size < 0 or filePosition > len(data) or diskSize > len(data) - filePosition then
      return error(1553, filename + ": invalid WAD lump " + name)
    end if
    if type == TYP_QPIC then
      if diskSize < 8 then return error(1557, filename + ": WAD picture header is truncated: " + name) end if
      SwapPic(data, filePosition)
    end if

    lumps[index] = t.WadLump(filePosition, diskSize, size, type, compression, name)
    index = index + 1
  end while
  return t.WadArchive(filename, data, lumps, count)
end function

/// Mirror Quake's W_LoadWadFile routine and its observable state changes.
/// @param filename Path of the file to process.
function W_LoadWadFile(filename)
  data = fs.readAllBytes(filename)
  return W_LoadWadData(data, filename)
end function

/// Mirror Quake's W_GetLumpinfo routine and its observable state changes.
/// @param archive The archive input consumed by `W_GetLumpinfo`.
/// @param name Stable name that identifies the requested object or option.
function W_GetLumpinfo(archive, name)
  wanted = cleanupNameText(name)
  for each lump in archive.lumps
    if lump.name == wanted then return lump end if
  end for
  return error(1554, "W_GetLumpinfo: " + name + " not found")
end function

/// C returns an untyped pointer.  MiniLang exposes the exact on-disk byte range
/// instead; like the original this does not reject compressed lumps.
/// @param archive The archive input consumed by `W_GetLumpName`.
/// @param name Stable name that identifies the requested object or option.
function W_GetLumpName(archive, name)
  lump = W_GetLumpinfo(archive, name)
  return slice(archive.data, lump.filePosition, lump.diskSize)
end function

/// Mirror Quake's W_GetLumpNum routine and its observable state changes.
/// @param archive The archive input consumed by `W_GetLumpNum`.
/// @param number The number input consumed by `W_GetLumpNum`.
function W_GetLumpNum(archive, number)
  // wad.c accidentally accepts num == wad_numlumps and then dereferences one
  // directory entry past the table.  That undefined access cannot be a useful
  // compatibility contract, so the memory-safe pendant rejects it.
  if number < 0 or number >= archive.numLumps then
    return error(1558, "W_GetLumpNum: bad number: " + number)
  end if
  lump = archive.lumps[number]
  return slice(archive.data, lump.filePosition, lump.diskSize)
end function

/// Existing idiomatic API retained for callers already ported to MiniLang.
/// @param data Input data consumed by the operation.
/// @param filename Path of the file to process.
function parse(data, filename)
  return W_LoadWadData(data, filename)
end function

/// Implements the `load` operation for `miniquake.wad` (load).
/// @param filename Path of the file to process.
function load(filename)
  return W_LoadWadFile(filename)
end function

/// Implements the `find` operation for `miniquake.wad` (find).
/// @param archive The archive input consumed by `find`.
/// @param name Stable name that identifies the requested object or option.
function find(archive, name)
  wanted = cleanupNameText(name)
  for each lump in archive.lumps
    if lump.name == wanted then return lump end if
  end for
  return void
end function

/// Read and validate lump.
/// @param archive The archive input consumed by `readLump`.
/// @param name Stable name that identifies the requested object or option.
function readLump(archive, name)
  lump = W_GetLumpinfo(archive, name)
  if lump.compression != CMP_NONE then return error(1555, "compressed WAD lumps are unsupported") end if
  return slice(archive.data, lump.filePosition, lump.diskSize)
end function

/// Implements the `pictureDimensions` operation for `miniquake.wad` (picture dimensions).
/// @param archive The archive input consumed by `pictureDimensions`.
/// @param name Stable name that identifies the requested object or option.
function pictureDimensions(archive, name)
  lump = W_GetLumpinfo(archive, name)
  if lump.diskSize < 8 then return error(1557, "WAD picture header is truncated") end if
  return [bio.i32(archive.data, lump.filePosition), bio.i32(archive.data, lump.filePosition + 4)]
end function
