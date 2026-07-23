package miniquake.format.bsp

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import std.fs as fs

function parseLumps(data)
  if len(data) < 4 + c.HEADER_LUMPS * 8 then return error(1700, "BSP header is truncated") end if
  lumps = arrayutil.makeEmptyArray(c.HEADER_LUMPS)
  i = 0
  while i < c.HEADER_LUMPS
    offset = bio.i32(data, 4 + i * 8)
    length = bio.i32(data, 8 + i * 8)
    if offset < 0 or length < 0 or offset + length > len(data) then return error(1701, "BSP lump outside file") end if
    lumps[i] = t.Lump(offset, length)
    i = i + 1
  end while
  return lumps
end function

function parsePlanes(data, lump)
  if lump.length % 20 != 0 then return error(1702, "invalid BSP plane lump") end if
  count = lump.length / 20
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 20
    normal = t.Vec3(bio.f32(data, offset), bio.f32(data, offset + 4), bio.f32(data, offset + 8))
    result[i] = t.BspPlane(normal, bio.f32(data, offset + 12), bio.i32(data, offset + 16))
    i = i + 1
  end while
  return result
end function

function parseVertices(data, lump)
  if lump.length % 12 != 0 then return error(1703, "invalid BSP vertex lump") end if
  count = lump.length / 12
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 12
    result[i] = t.BspVertex(t.Vec3(bio.f32(data, offset), bio.f32(data, offset + 4), bio.f32(data, offset + 8)))
    i = i + 1
  end while
  return result
end function

function parseEdges(data, lump)
  if lump.length % 4 != 0 then return error(1704, "invalid BSP edge lump") end if
  count = lump.length / 4
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 4
    result[i] = t.BspEdge(bio.u16(data, offset), bio.u16(data, offset + 2))
    i = i + 1
  end while
  return result
end function

function parseSurfEdges(data, lump)
  if lump.length % 4 != 0 then return error(1705, "invalid BSP surfedge lump") end if
  count = lump.length / 4
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    result[i] = bio.i32(data, lump.offset + i * 4)
    i = i + 1
  end while
  return result
end function

function parseNodes(data, lump)
  if lump.length % 24 != 0 then return error(1706, "invalid BSP node lump") end if
  count = lump.length / 24
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 24
    mins = t.Vec3(bio.i16(data, offset + 8), bio.i16(data, offset + 10), bio.i16(data, offset + 12))
    maxs = t.Vec3(bio.i16(data, offset + 14), bio.i16(data, offset + 16), bio.i16(data, offset + 18))
    result[i] = t.BspNode(
      bio.i32(data, offset),
      bio.i16(data, offset + 4),
      bio.i16(data, offset + 6),
      mins,
      maxs,
      bio.u16(data, offset + 20),
      bio.u16(data, offset + 22),
    )
    i = i + 1
  end while
  return result
end function

function parseClipNodes(data, lump)
  if lump.length % 8 != 0 then return error(1707, "invalid BSP clipnode lump") end if
  count = lump.length / 8
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 8
    result[i] = t.BspClipNode(bio.i32(data, offset), bio.i16(data, offset + 4), bio.i16(data, offset + 6))
    i = i + 1
  end while
  return result
end function

function parseTexInfo(data, lump)
  if lump.length % 40 != 0 then return error(1708, "invalid BSP texinfo lump") end if
  count = lump.length / 40
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 40
    s = [bio.f32(data, offset), bio.f32(data, offset + 4), bio.f32(data, offset + 8), bio.f32(data, offset + 12)]
    tv = [bio.f32(data, offset + 16), bio.f32(data, offset + 20), bio.f32(data, offset + 24), bio.f32(data, offset + 28)]
    result[i] = t.BspTexInfo(s, tv, bio.i32(data, offset + 32), bio.i32(data, offset + 36))
    i = i + 1
  end while
  return result
end function

function parseFaces(data, lump)
  if lump.length % 20 != 0 then return error(1709, "invalid BSP face lump") end if
  count = lump.length / 20
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 20
    styles = slice(data, offset + 12, 4)
    result[i] = t.BspFace(
      bio.u16(data, offset),
      bio.i16(data, offset + 2),
      bio.i32(data, offset + 4),
      bio.u16(data, offset + 8),
      bio.u16(data, offset + 10),
      styles,
      bio.i32(data, offset + 16),
    )
    i = i + 1
  end while
  return result
end function

function parseLeafs(data, lump)
  if lump.length % 28 != 0 then return error(1710, "invalid BSP leaf lump") end if
  count = lump.length / 28
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 28
    mins = t.Vec3(bio.i16(data, offset + 8), bio.i16(data, offset + 10), bio.i16(data, offset + 12))
    maxs = t.Vec3(bio.i16(data, offset + 14), bio.i16(data, offset + 16), bio.i16(data, offset + 18))
    result[i] = t.BspLeaf(
      bio.i32(data, offset),
      bio.i32(data, offset + 4),
      mins,
      maxs,
      bio.u16(data, offset + 20),
      bio.u16(data, offset + 22),
      slice(data, offset + 24, 4),
    )
    i = i + 1
  end while
  return result
end function

function parseMarkSurfaces(data, lump)
  if lump.length % 2 != 0 then return error(1711, "invalid BSP marksurface lump") end if
  count = lump.length / 2
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    result[i] = bio.u16(data, lump.offset + i * 2)
    i = i + 1
  end while
  return result
end function

function parseModels(data, lump)
  if lump.length % 64 != 0 then return error(1712, "invalid BSP model lump") end if
  count = lump.length / 64
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    offset = lump.offset + i * 64
    mins = t.Vec3(bio.f32(data, offset), bio.f32(data, offset + 4), bio.f32(data, offset + 8))
    maxs = t.Vec3(bio.f32(data, offset + 12), bio.f32(data, offset + 16), bio.f32(data, offset + 20))
    origin = t.Vec3(bio.f32(data, offset + 24), bio.f32(data, offset + 28), bio.f32(data, offset + 32))
    headNodes = [bio.i32(data, offset + 36), bio.i32(data, offset + 40), bio.i32(data, offset + 44), bio.i32(data, offset + 48)]
    result[i] = t.BspModel(mins, maxs, origin, headNodes, bio.i32(data, offset + 52), bio.i32(data, offset + 56), bio.i32(data, offset + 60))
    i = i + 1
  end while
  return result
end function

function parseTextures(data, lump)
  if lump.length == 0 then return [] end if
  if lump.length < 4 then return error(1713, "invalid BSP texture lump") end if
  count = bio.i32(data, lump.offset)
  if count < 0 or 4 + count * 4 > lump.length then return error(1714, "invalid BSP texture table") end if
  result = arrayutil.makeEmptyArray(count)
  i = 0
  while i < count
    relative = bio.i32(data, lump.offset + 4 + i * 4)
    if relative < 0 then
      result[i] = void
    else
      offset = lump.offset + relative
      if offset + 40 > lump.offset + lump.length then return error(1715, "BSP texture header outside lump") end if
      name = bio.fixedString(data, offset, 16)
      width = bio.i32(data, offset + 16)
      height = bio.i32(data, offset + 20)
      mipOffsets = [bio.i32(data, offset + 24), bio.i32(data, offset + 28), bio.i32(data, offset + 32), bio.i32(data, offset + 36)]
      pixels = bytes()
      if width > 0 and height > 0 and mipOffsets[0] >= 40 and offset + mipOffsets[0] + width * height <= lump.offset + lump.length then
        pixels = slice(data, offset + mipOffsets[0], width * height)
      end if
      result[i] = t.BspTexture(name, width, height, mipOffsets, pixels)
    end if
    i = i + 1
  end while
  return result
end function

function tokenizeEntities(text)
  source = bytes(text)
  tokenBuilder = arrayutil.createArrayBuilder(64)
  i = 0
  while i < len(source)
    while i < len(source) and source[i] <= 32
      i = i + 1
    end while
    if i >= len(source) then break end if
    if source[i] == 47 and i + 1 < len(source) and source[i + 1] == 47 then
      i = i + 2
      while i < len(source) and source[i] != 10
        i = i + 1
      end while
      continue
    end if
    if source[i] == 123 then arrayutil.pushArrayBuilder(tokenBuilder, "{"); i = i + 1; continue end if
    if source[i] == 125 then arrayutil.pushArrayBuilder(tokenBuilder, "}"); i = i + 1; continue end if
    if source[i] == 34 then
      i = i + 1
      start = i
      scan = i
      count = 0
      while scan < len(source) and source[scan] != 34
        if source[scan] == 92 and scan + 1 < len(source) then scan = scan + 1 end if
        count = count + 1
        scan = scan + 1
      end while
      output = bytes(count)
      inputIndex = start
      outputIndex = 0
      while inputIndex < scan
        if source[inputIndex] == 92 and inputIndex + 1 < scan then inputIndex = inputIndex + 1 end if
        output[outputIndex] = source[inputIndex]
        outputIndex = outputIndex + 1
        inputIndex = inputIndex + 1
      end while
      i = scan
      if i < len(source) and source[i] == 34 then i = i + 1 end if
      arrayutil.pushArrayBuilder(tokenBuilder, decode(output))
    else
      start = i
      while i < len(source) and source[i] > 32 and source[i] != 123 and source[i] != 125
        i = i + 1
      end while
      arrayutil.pushArrayBuilder(tokenBuilder, decode(slice(source, start, i - start)))
    end if
  end while
  return arrayutil.finishArrayBuilder(tokenBuilder)
end function

function parseEntities(text)
  tokens = tokenizeEntities(text)
  entityBuilder = arrayutil.createArrayBuilder(64)
  i = 0
  while i < len(tokens)
    if tokens[i] != "{" then return error(1716, "entity data expected {") end if
    i = i + 1
    pairBuilder = arrayutil.createArrayBuilder(16)
    while i < len(tokens) and tokens[i] != "}"
      if i + 1 >= len(tokens) then return error(1717, "truncated entity key/value") end if
      arrayutil.pushArrayBuilder(pairBuilder, t.EntityPair(tokens[i], tokens[i + 1]))
      i = i + 2
    end while
    if i >= len(tokens) then return error(1718, "entity data expected }") end if
    i = i + 1
    arrayutil.pushArrayBuilder(entityBuilder, t.Entity(arrayutil.finishArrayBuilder(pairBuilder)))
  end while
  return arrayutil.finishArrayBuilder(entityBuilder)
end function

function entityValue(entity, key)
  for each pair in entity.pairs
    if pair.key == key then return pair.value end if
  end for
  return ""
end function

function parseVector(text)
  source = bytes(text)
  values = [0.0, 0.0, 0.0]
  valueCount = 0
  i = 0
  while i < len(source) and valueCount < 3
    while i < len(source) and source[i] <= 32
      i = i + 1
    end while
    start = i
    while i < len(source) and source[i] > 32
      i = i + 1
    end while
    if i > start then
      value = toNumber(decode(slice(source, start, i - start)))
      if value is void then value = 0.0 end if
      values[valueCount] = value
      valueCount = valueCount + 1
    end if
  end while
  return t.Vec3(values[0], values[1], values[2])
end function

function entityVector(entity, key)
  return parseVector(entityValue(entity, key))
end function

function decompressVisibility(data, offset, rowBytes)
  if rowBytes is not int then return error(1719, "PVS row size must be an integer, got " + typeof(rowBytes)) end if
  if rowBytes < 0 then return error(1719, "negative PVS row size") end if
  output = bytes(rowBytes)
  inputOffset = offset
  outputOffset = 0
  while outputOffset < rowBytes
    if inputOffset < 0 or inputOffset >= len(data) then return error(1720, "PVS stream is truncated") end if
    value = data[inputOffset]
    inputOffset = inputOffset + 1
    if value != 0 then
      output[outputOffset] = value
      outputOffset = outputOffset + 1
    else
      if inputOffset >= len(data) then return error(1721, "PVS zero run is truncated") end if
      count = data[inputOffset]
      inputOffset = inputOffset + 1
      while count > 0 and outputOffset < rowBytes
        output[outputOffset] = 0
        outputOffset = outputOffset + 1
        count = count - 1
      end while
    end if
  end while
  return output
end function

function parse(data, filename)
  if len(data) < 4 then return error(1722, filename + ": BSP file is truncated") end if
  version = bio.i32(data, 0)
  if version != c.BSP_VERSION then return error(1723, filename + ": unsupported BSP version " + version) end if
  lumps = parseLumps(data)
  entityLump = lumps[c.LUMP_ENTITIES]
  entityText = decode(slice(data, entityLump.offset, entityLump.length))
  entities = parseEntities(entityText)
  planes = parsePlanes(data, lumps[c.LUMP_PLANES])
  textures = parseTextures(data, lumps[c.LUMP_TEXTURES])
  vertices = parseVertices(data, lumps[c.LUMP_VERTEXES])
  visibility = slice(data, lumps[c.LUMP_VISIBILITY].offset, lumps[c.LUMP_VISIBILITY].length)
  nodes = parseNodes(data, lumps[c.LUMP_NODES])
  texInfo = parseTexInfo(data, lumps[c.LUMP_TEXINFO])
  faces = parseFaces(data, lumps[c.LUMP_FACES])
  lighting = slice(data, lumps[c.LUMP_LIGHTING].offset, lumps[c.LUMP_LIGHTING].length)
  clipNodes = parseClipNodes(data, lumps[c.LUMP_CLIPNODES])
  leafs = parseLeafs(data, lumps[c.LUMP_LEAFS])
  markSurfaces = parseMarkSurfaces(data, lumps[c.LUMP_MARKSURFACES])
  edges = parseEdges(data, lumps[c.LUMP_EDGES])
  surfEdges = parseSurfEdges(data, lumps[c.LUMP_SURFEDGES])
  models = parseModels(data, lumps[c.LUMP_MODELS])
  return t.BspMap(filename, data, version, lumps, entityText, entities, planes, textures, vertices, visibility, nodes, texInfo, faces, lighting, clipNodes, leafs, markSurfaces, edges, surfEdges, models)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
