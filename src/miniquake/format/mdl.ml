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

function Mod_FloodFillSkin(skin, skinWidth, skinHeight)
  if skinWidth <= 0 or skinHeight <= 0 or len(skin) < skinWidth * skinHeight then return skin end if
  fillColor = skin[0]
  filledColor = 0
  if fillColor == filledColor or fillColor == 255 then return skin end if

  fifoX = arrayutil.makeFilledArray(4096, 0)
  fifoY = arrayutil.makeFilledArray(4096, 0)
  input = 1
  output = 0
  fifoX[0] = 0
  fifoY[0] = 0
  while output != input
    x = fifoX[output]
    y = fifoY[output]
    output = (output + 1) & 4095
    fillDestination = filledColor

    if x > 0 then
      adjacent = x - 1 + skinWidth * y
      if skin[adjacent] == fillColor then
        skin[adjacent] = 255
        fifoX[input] = x - 1
        fifoY[input] = y
        input = (input + 1) & 4095
      else
        if skin[adjacent] != 255 then fillDestination = skin[adjacent] end if
      end if
    end if
    if x < skinWidth - 1 then
      adjacent = x + 1 + skinWidth * y
      if skin[adjacent] == fillColor then
        skin[adjacent] = 255
        fifoX[input] = x + 1
        fifoY[input] = y
        input = (input + 1) & 4095
      else
        if skin[adjacent] != 255 then fillDestination = skin[adjacent] end if
      end if
    end if
    if y > 0 then
      adjacent = x + skinWidth * (y - 1)
      if skin[adjacent] == fillColor then
        skin[adjacent] = 255
        fifoX[input] = x
        fifoY[input] = y - 1
        input = (input + 1) & 4095
      else
        if skin[adjacent] != 255 then fillDestination = skin[adjacent] end if
      end if
    end if
    if y < skinHeight - 1 then
      adjacent = x + skinWidth * (y + 1)
      if skin[adjacent] == fillColor then
        skin[adjacent] = 255
        fifoX[input] = x
        fifoY[input] = y + 1
        input = (input + 1) & 4095
      else
        if skin[adjacent] != 255 then fillDestination = skin[adjacent] end if
      end if
    end if
    skin[x + skinWidth * y] = fillDestination
  end while
  return skin
end function

function parseSkin(data, offset, skinWidth, skinHeight)
  skinBytes = skinWidth * skinHeight
  if offset + 4 > len(data) then return error(1802, "MDL skin type outside file") end if
  group = bio.i32(data, offset)
  offset = offset + 4
  if group == c.ALIAS_SKIN_SINGLE then
    if offset + skinBytes > len(data) then return error(1803, "MDL skin outside file") end if
    image = slice(data, offset, skinBytes)
    Mod_FloodFillSkin(image, skinWidth, skinHeight)
    return [t.MdlSkin(false, [], [image]), offset + skinBytes]
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
    Mod_FloodFillSkin(images[i], skinWidth, skinHeight)
    offset = offset + skinBytes
    i = i + 1
  end while
  return [t.MdlSkin(true, intervals, images), offset]
end function

function Mod_LoadAliasFrame(data, offset, numVertices)
  return parseSingleFrame(data, offset, numVertices)
end function

function Mod_LoadAliasGroup(data, offset, numVertices)
  if offset + 12 > len(data) then return error(1818, "MDL frame group outside file") end if
  count = bio.i32(data, offset)
  if count <= 0 then return error(1810, "invalid MDL frame group") end if
  cursor = offset + 12
  intervals = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    if cursor + 4 > len(data) then return error(1811, "MDL frame interval outside file") end if
    intervals[index] = bio.f32(data, cursor)
    cursor = cursor + 4
    index = index + 1
  end while
  frames = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    parsed = Mod_LoadAliasFrame(data, cursor, numVertices)
    if parsed is error then return parsed end if
    frames[index] = parsed[0]
    cursor = parsed[1]
    index = index + 1
  end while
  return [t.MdlFrameSet(true, intervals, frames), cursor]
end function

function parseFrameSet(data, offset, numVertices)
  if offset + 4 > len(data) then return error(1808, "MDL frame type outside file") end if
  group = bio.i32(data, offset)
  offset = offset + 4
  if group == c.ALIAS_SINGLE then
    parsed = Mod_LoadAliasFrame(data, offset, numVertices)
    if parsed is error then return parsed end if
    return [t.MdlFrameSet(false, [], [parsed[0]]), parsed[1]]
  end if
  return Mod_LoadAliasGroup(data, offset, numVertices)
end function

function Mod_LoadAllSkins(data, offset, numSkins, skinWidth, skinHeight)
  skins = arrayutil.makeEmptyArray(numSkins)
  index = 0
  while index < numSkins
    parsed = parseSkin(data, offset, skinWidth, skinHeight)
    if parsed is error then return parsed end if
    skins[index] = parsed[0]
    offset = parsed[1]
    index = index + 1
  end while
  return [skins, offset]
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
  if numSkins < 1 or numSkins > c.MAX_SKINS then return error(1815, "Mod_LoadAliasModel: Invalid # of skins: " + numSkins) end if
  if skinWidth <= 0 or skinHeight <= 0 then return error(1815, filename + ": invalid MDL skin dimensions") end if
  if skinHeight > c.MAX_LBM_HEIGHT then return error(1815, "model " + filename + " has a skin taller than " + c.MAX_LBM_HEIGHT) end if
  if numVertices <= 0 then return error(1815, "model " + filename + " has no vertices") end if
  if numVertices > c.MAX_ALIAS_VERTS then return error(1815, "model " + filename + " has too many vertices") end if
  if numTriangles <= 0 or numTriangles > c.MAX_ALIAS_TRIS then return error(1815, "model " + filename + " has invalid triangle count") end if
  if numFrames < 1 then
    return error(1815, filename + ": invalid MDL counts")
  end if

  offset = 84
  parsedSkins = Mod_LoadAllSkins(data, offset, numSkins, skinWidth, skinHeight)
  if parsedSkins is error then return parsedSkins end if
  skins = parsedSkins[0]
  offset = parsedSkins[1]

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
    triangle = t.MdlTriangle(bio.i32(data, offset), bio.i32(data, offset + 4), bio.i32(data, offset + 8), bio.i32(data, offset + 12))
    if triangle.vertex0 < 0 or triangle.vertex0 >= numVertices or triangle.vertex1 < 0 or triangle.vertex1 >= numVertices or triangle.vertex2 < 0 or triangle.vertex2 >= numVertices then
      return error(1819, filename + ": MDL triangle vertex outside model")
    end if
    triangles[i] = triangle
    offset = offset + 16
    i = i + 1
  end while

  frames = arrayutil.makeEmptyArray(numFrames)
  poseCount = 0
  i = 0
  while i < numFrames
    parsedFrame = parseFrameSet(data, offset, numVertices)
    if parsedFrame is error then return parsedFrame end if
    frames[i] = parsedFrame[0]
    poseCount = poseCount + len(frames[i].frames)
    if poseCount > c.MAX_ALIAS_FRAMES then return error(1820, filename + ": too many alias poses") end if
    offset = parsedFrame[1]
    i = i + 1
  end while

  return t.MdlModel(filename, data, version, scale, scaleOrigin, boundingRadius, eyePosition, numSkins, skinWidth, skinHeight, numVertices, numTriangles, numFrames, syncType, flags, modelSize * c.ALIAS_BASE_SIZE_RATIO, skins, texCoords, triangles, frames)
end function

function Mod_LoadAliasModel(data, filename)
  return parse(data, filename)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
