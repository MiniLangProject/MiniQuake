package miniquake.pak

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

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

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function

function find(archive, name)
  wanted = bio.lower(name)
  for each item in archive.files
    if bio.lower(item.name) == wanted then return item end if
  end for
  return void
end function

function readFile(archive, name)
  item = find(archive, name)
  if item is void then return error(1505, "PACK file not found: " + name) end if
  return slice(archive.data, item.offset, item.length)
end function

function hasFile(archive, name)
  return find(archive, name) is not void
end function
