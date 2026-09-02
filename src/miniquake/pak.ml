/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.pak.
*/
package miniquake.pak

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.crc as crc
import miniquake.array_util as arrayutil
import std.fs as fs

/// Defines the max files in pack value used by `miniquake.pak`.
const MAX_FILES_IN_PACK = 2048
/// Defines the pak0 count value used by `miniquake.pak`.
const PAK0_COUNT = 339
/// Defines the pak0 crc value used by `miniquake.pak`.
const PAK0_CRC = 32981

/// Implements the `parse` operation for `miniquake.pak` (parse).
/// @param data Input data consumed by the operation.
/// @param filename Path of the file to process.
function parse(data, filename)
  if len(data) < 12 then return error(1500, filename + ": PACK header is truncated") end if
  if bio.fourCC(data, 0) != "PACK" then return error(1501, filename + ": not a PACK archive") end if
  directoryOffset = bio.i32(data, 4)
  directoryLength = bio.i32(data, 8)
  if directoryOffset < 0 or directoryLength < 0 or directoryLength % 64 != 0 then
    return error(1502, filename + ": invalid PACK directory")
  end if
  if directoryOffset + directoryLength > len(data) then return error(1503, filename + ": PACK directory outside file") end if
  count = directoryLength / 64
  if count > MAX_FILES_IN_PACK then return error(1506, filename + ": too many files in PACK archive") end if
  files = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = directoryOffset + i * 64
    name = bio.fixedString(data, offset, 56)
    fileOffset = bio.i32(data, offset + 56)
    fileLength = bio.i32(data, offset + 60)
    if fileOffset < 0 or fileLength < 0 or fileOffset + fileLength > len(data) then
      return error(1504, filename + ": invalid PACK entry " + name)
    end if
    files[i] = t.PackFile(name, fileOffset, fileLength)
    i = i + 1
  end while
  return t.PackArchive(filename, data, files, count)
end function

/// Implements the `load` operation for `miniquake.pak` (load).
/// @param filename Path of the file to process.
function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function

/// Implements the `find` operation for `miniquake.pak` (find).
/// @param archive The archive input consumed by `find`.
/// @param name Stable name that identifies the requested object or option.
function find(archive, name)
  for each item in archive.files
    if item.name == name then return item end if
  end for
  return void
end function

/// Read and validate file.
/// @param archive The archive input consumed by `readFile`.
/// @param name Stable name that identifies the requested object or option.
function readFile(archive, name)
  item = find(archive, name)
  if item is void then return error(1505, "PACK file not found: " + name) end if
  return slice(archive.data, item.offset, item.length)
end function

/// Report whether file.
/// @param archive The archive input consumed by `hasFile`.
/// @param name Stable name that identifies the requested object or option.
function hasFile(archive, name)
  return find(archive, name) is not void
end function

/// Implements the `directoryRange` operation for `miniquake.pak` (directory range).
/// @param archive The archive input consumed by `directoryRange`.
function directoryRange(archive)
  if len(archive.data) < 12 then return error(1507, archive.filename + ": PACK header is truncated") end if
  return [bio.i32(archive.data, 4), bio.i32(archive.data, 8)]
end function

/// Return directory crc derived from the active module state.
/// @param archive The archive input consumed by `directoryCrc`.
function directoryCrc(archive)
  range = directoryRange(archive)
  return crc.block(archive.data, range[0], range[1])
end function

/// Report whether is original pak0 directory.
/// @param archive The archive input consumed by `isOriginalPak0Directory`.
function isOriginalPak0Directory(archive)
  return archive.numFiles == PAK0_COUNT and directoryCrc(archive) == PAK0_CRC
end function
