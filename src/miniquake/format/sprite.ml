package miniquake.format.sprite

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function parseSingleFrame(data, offset)
  if offset + 16 > len(data) then return error(1850, "sprite frame header outside file") end if
  originX = bio.i32(data, offset)
  originY = bio.i32(data, offset + 4)
  width = bio.i32(data, offset + 8)
  height = bio.i32(data, offset + 12)
  if width < 0 or height < 0 or offset + 16 + width * height > len(data) then return error(1851, "sprite frame pixels outside file") end if
  frame = t.SpriteFrame(originX, originY, width, height, slice(data, offset + 16, width * height))
  return [frame, offset + 16 + width * height]
end function

function parseFrameSet(data, offset)
  if offset + 4 > len(data) then return error(1852, "sprite frame type outside file") end if
  group = bio.i32(data, offset)
  offset = offset + 4
  if group == 0 then
    parsed = parseSingleFrame(data, offset)
    return [t.SpriteFrameSet(false, [], [parsed[0]]), parsed[1]]
  end if
  if offset + 4 > len(data) then return error(1853, "sprite group outside file") end if
  count = bio.i32(data, offset)
  offset = offset + 4
  if count <= 0 then return error(1854, "invalid sprite group count") end if
  intervals = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    if offset + 4 > len(data) then return error(1855, "sprite interval outside file") end if
    intervals[i] = bio.f32(data, offset)
    offset = offset + 4
    i = i + 1
  end while
  frames = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    parsed = parseSingleFrame(data, offset)
    frames[i] = parsed[0]
    offset = parsed[1]
    i = i + 1
  end while
  return [t.SpriteFrameSet(true, intervals, frames), offset]
end function

function parse(data, filename)
  if len(data) < 36 then return error(1856, filename + ": sprite header is truncated") end if
  if bio.fourCC(data, 0) != "IDSP" then return error(1857, filename + ": not an IDSP sprite") end if
  version = bio.i32(data, 4)
  if version != c.SPRITE_VERSION then return error(1858, filename + ": unsupported sprite version " + version) end if
  type = bio.i32(data, 8)
  boundingRadius = bio.f32(data, 12)
  width = bio.i32(data, 16)
  height = bio.i32(data, 20)
  numFrames = bio.i32(data, 24)
  beamLength = bio.f32(data, 28)
  syncType = bio.i32(data, 32)
  if numFrames < 0 then return error(1859, "invalid sprite frame count") end if
  frames = arrayutil.makeEmptyArray(numFrames)
  offset = 36
  i = 0
  while i < numFrames
    parsed = parseFrameSet(data, offset)
    frames[i] = parsed[0]
    offset = parsed[1]
    i = i + 1
  end while
  return t.SpriteModel(filename, data, version, type, boundingRadius, width, height, numFrames, beamLength, syncType, frames)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
