package miniquake.format.mdl

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function parseVertex(data, offset)
  if offset < 0 or offset + 4 > len(data) then return error(1800, "MDL vertex outside file") end if
  return t.MdlVertex(data[offset], data[offset + 1], data[offset + 2], data[offset + 3])
end function

function parseSingleFrame(data, offset, numVertices)
  size = 24 + numVertices * 4
  if offset < 0 or offset + size > len(data) then return error(1801, "MDL frame outside file") end if
  mins = parseVertex(data, offset)
  maxs = parseVertex(data, offset + 4)
  name = bio.fixedString(data, offset + 8, 16)
  vertices = arrayutil.makeEmptyArray(numVertices)
  i = 0
  while i < numVertices
    vertices[i] = parseVertex(data, offset + 24 + i * 4)
    i = i + 1
  end while
  return [t.MdlFrame(name, mins, maxs, vertices), offset + size]
end function

function parseSkin(data, offset, skinBytes)
  if offset + 4 > len(data) then return error(1802, "MDL skin type outside file") end if
  group = bio.i32(data, offset)
  offset = offset + 4
  if group == 0 then
    if offset + skinBytes > len(data) then return error(1803, "MDL skin outside file") end if
    return [t.MdlSkin(false, [], [slice(data, offset, skinBytes)]), offset + skinBytes]
  end if
  if offset + 4 > len(data) then return error(1804, "MDL skin group outside file") end if
  count = bio.i32(data, offset)
  offset = offset + 4
  if count <= 0 then return error(1805, "invalid MDL skin group") end if
  intervals = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    if offset + 4 > len(data) then return error(1806, "MDL skin interval outside file") end if
    intervals[i] = bio.f32(data, offset)
    offset = offset + 4
    i = i + 1
  end while
  images = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    if offset + skinBytes > len(data) then return error(1807, "MDL grouped skin outside file") end if
    images[i] = slice(data, offset, skinBytes)
    offset = offset + skinBytes
    i = i + 1
  end while
  return [t.MdlSkin(true, intervals, images), offset]
end function

function parseFrameSet(data, offset, numVertices)
  if offset + 4 > len(data) then return error(1808, "MDL frame type outside file") end if
  group = bio.i32(data, offset)
  offset = offset + 4
  if group == 0 then
    parsed = parseSingleFrame(data, offset, numVertices)
    return [t.MdlFrameSet(false, [], [parsed[0]]), parsed[1]]
  end if
  if offset + 12 > len(data) then return error(1809, "MDL frame group outside file") end if
  count = bio.i32(data, offset)
  offset = offset + 12
  if count <= 0 then return error(1810, "invalid MDL frame group") end if
  intervals = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    if offset + 4 > len(data) then return error(1811, "MDL frame interval outside file") end if
    intervals[i] = bio.f32(data, offset)
    offset = offset + 4
    i = i + 1
  end while
  frames = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    parsed = parseSingleFrame(data, offset, numVertices)
    frames[i] = parsed[0]
    offset = parsed[1]
    i = i + 1
  end while
  return [t.MdlFrameSet(true, intervals, frames), offset]
end function

function parse(data, filename)
  if len(data) < 84 then return error(1812, filename + ": MDL header is truncated") end if
  if bio.fourCC(data, 0) != "IDPO" then return error(1813, filename + ": not an IDPO model") end if
  version = bio.i32(data, 4)
  if version != c.MDL_VERSION then return error(1814, filename + ": unsupported MDL version " + version) end if
  scale = t.Vec3(bio.f32(data, 8), bio.f32(data, 12), bio.f32(data, 16))
  scaleOrigin = t.Vec3(bio.f32(data, 20), bio.f32(data, 24), bio.f32(data, 28))
  boundingRadius = bio.f32(data, 32)
  eyePosition = t.Vec3(bio.f32(data, 36), bio.f32(data, 40), bio.f32(data, 44))
  numSkins = bio.i32(data, 48)
  skinWidth = bio.i32(data, 52)
  skinHeight = bio.i32(data, 56)
  numVertices = bio.i32(data, 60)
  numTriangles = bio.i32(data, 64)
  numFrames = bio.i32(data, 68)
  syncType = bio.i32(data, 72)
  flags = bio.i32(data, 76)
  modelSize = bio.f32(data, 80)
  if numSkins < 0 or skinWidth <= 0 or skinHeight <= 0 or numVertices < 0 or numTriangles < 0 or numFrames < 0 then
    return error(1815, filename + ": invalid MDL counts")
  end if

  offset = 84
  skinBytes = skinWidth * skinHeight
  skins = arrayutil.makeEmptyArray(numSkins)
  i = 0
  while i < numSkins
    parsedSkin = parseSkin(data, offset, skinBytes)
    skins[i] = parsedSkin[0]
    offset = parsedSkin[1]
    i = i + 1
  end while

  texCoords = arrayutil.makeEmptyArray(numVertices)
  i = 0
  while i < numVertices
    if offset + 12 > len(data) then return error(1816, "MDL texture coordinates outside file") end if
    texCoords[i] = t.MdlTexCoord(bio.i32(data, offset), bio.i32(data, offset + 4), bio.i32(data, offset + 8))
    offset = offset + 12
    i = i + 1
  end while

  triangles = arrayutil.makeEmptyArray(numTriangles)
  i = 0
  while i < numTriangles
    if offset + 16 > len(data) then return error(1817, "MDL triangle outside file") end if
    triangles[i] = t.MdlTriangle(bio.i32(data, offset), bio.i32(data, offset + 4), bio.i32(data, offset + 8), bio.i32(data, offset + 12))
    offset = offset + 16
    i = i + 1
  end while

  frames = arrayutil.makeEmptyArray(numFrames)
  i = 0
  while i < numFrames
    parsedFrame = parseFrameSet(data, offset, numVertices)
    frames[i] = parsedFrame[0]
    offset = parsedFrame[1]
    i = i + 1
  end while

  return t.MdlModel(filename, data, version, scale, scaleOrigin, boundingRadius, eyePosition, numSkins, skinWidth, skinHeight, numVertices, numTriangles, numFrames, syncType, flags, modelSize, skins, texCoords, triangles, frames)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
