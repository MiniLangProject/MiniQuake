package miniquake.wad

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function parse(data, filename)
  if len(data) < 12 then return error(1550, filename + ": WAD header is truncated") end if
  magic = bio.fourCC(data, 0)
  if magic != "WAD2" then return error(1551, filename + ": expected WAD2") end if
  count = bio.i32(data, 4)
  directoryOffset = bio.i32(data, 8)
  if count < 0 or directoryOffset < 0 or directoryOffset + count * 32 > len(data) then
    return error(1552, filename + ": invalid WAD directory")
  end if
  lumps = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = directoryOffset + i * 32
    filePosition = bio.i32(data, offset)
    diskSize = bio.i32(data, offset + 4)
    size = bio.i32(data, offset + 8)
    type = bio.u8(data, offset + 12)
    compression = bio.u8(data, offset + 13)
    name = bio.fixedString(data, offset + 16, 16)
    if filePosition < 0 or diskSize < 0 or filePosition + diskSize > len(data) then
      return error(1553, filename + ": invalid WAD lump " + name)
    end if
    lumps[i] = t.WadLump(filePosition, diskSize, size, type, compression, name)
    i = i + 1
  end while
  return t.WadArchive(filename, data, lumps, count)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function

function find(archive, name)
  wanted = bio.lower(name)
  for each lump in archive.lumps
    if bio.lower(lump.name) == wanted then return lump end if
  end for
  return void
end function

function readLump(archive, name)
  lump = find(archive, name)
  if lump is void then return error(1554, "WAD lump not found: " + name) end if
  if lump.compression != 0 then return error(1555, "compressed WAD lumps are unsupported") end if
  return slice(archive.data, lump.filePosition, lump.diskSize)
end function

function pictureDimensions(archive, name)
  lump = find(archive, name)
  if lump is void then return error(1556, "WAD picture not found: " + name) end if
  if lump.diskSize < 8 then return error(1557, "WAD picture header is truncated") end if
  return [bio.i32(archive.data, lump.filePosition), bio.i32(archive.data, lump.filePosition + 4)]
end function
