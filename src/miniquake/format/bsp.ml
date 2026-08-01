package miniquake.format.bsp

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import miniquake.protocol_text as protocolText
import miniquake.native as native
import miniquake.common as common
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
    // Mod_LoadSubmodels deliberately spreads both sides by one unit.
    mins = t.Vec3(bio.f32(data, offset) - 1.0, bio.f32(data, offset + 4) - 1.0, bio.f32(data, offset + 8) - 1.0)
    maxs = t.Vec3(bio.f32(data, offset + 12) + 1.0, bio.f32(data, offset + 16) + 1.0, bio.f32(data, offset + 20) + 1.0)
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
      // makeEmptyArray already contains void in every slot.  Reassigning void
      // through an index is rejected by the MiniLang runtime; a negative BSP
      // miptex offset intentionally leaves this slot empty.
      i = i
    else
      offset = lump.offset + relative
      if offset + 40 > lump.offset + lump.length then return error(1715, "BSP texture header outside lump") end if
      name = bio.fixedString(data, offset, 16)
      width = bio.i32(data, offset + 16)
      height = bio.i32(data, offset + 20)
      mipOffsets = [bio.i32(data, offset + 24), bio.i32(data, offset + 28), bio.i32(data, offset + 32), bio.i32(data, offset + 36)]
      if width <= 0 or height <= 0 then return error(1724, "Texture " + name + " has invalid dimensions") end if
      if (width & 15) != 0 or (height & 15) != 0 then return error(1725, "Texture " + name + " is not 16 aligned") end if
      levelWidth = width
      levelHeight = height
      level = 0
      while level < 4
        levelSize = levelWidth * levelHeight
        if mipOffsets[level] < 40 or offset + mipOffsets[level] + levelSize > lump.offset + lump.length then
          return error(1726, "Texture " + name + " mip level outside lump")
        end if
        if levelWidth > 1 then levelWidth = levelWidth / 2 end if
        if levelHeight > 1 then levelHeight = levelHeight / 2 end if
        level = level + 1
      end while
      pixels = slice(data, offset + mipOffsets[0], width * height)
      result[i] = t.BspTexture(name, width, height, mipOffsets, pixels)
    end if
    i = i + 1
  end while
  return result
end function

function tokenizeEntities(text)
  source = protocolText.encodeBytes(text)
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
        // COM_Parse leaves backslash pairs in quoted entity text and
        // ED_NewString performs the conversion afterwards: \n becomes a
        // newline, while every other pair becomes one literal backslash.
        // A backslash does not escape a quote in the original parser.
        if source[scan] == 92 and scan + 1 < len(source) and source[scan + 1] != 34 then scan = scan + 1 end if
        count = count + 1
        scan = scan + 1
      end while
      output = bytes(count)
      inputIndex = start
      outputIndex = 0
      while inputIndex < scan
        if source[inputIndex] == 92 and inputIndex + 1 < scan then
          inputIndex = inputIndex + 1
          if source[inputIndex] == 110 then output[outputIndex] = 10 else output[outputIndex] = 92 end if
        else
          output[outputIndex] = source[inputIndex]
        end if
        outputIndex = outputIndex + 1
        inputIndex = inputIndex + 1
      end while
      i = scan
      if i < len(source) and source[i] == 34 then i = i + 1 end if
      arrayutil.pushArrayBuilder(tokenBuilder, protocolText.decodeBytes(output))
    else
      start = i
      while i < len(source) and source[i] > 32 and source[i] != 123 and source[i] != 125
        i = i + 1
      end while
      arrayutil.pushArrayBuilder(tokenBuilder, protocolText.decodeBytes(slice(source, start, i - start)))
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
      values[valueCount] = common.cAtof(decode(slice(source, start, i - start)))
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

function Mod_DecompressVis(data, offset, numLeafs)
  rowBytes = (numLeafs + 7) >> 3
  if offset < 0 then return bytes(rowBytes, 255) end if
  return decompressVisibility(data, offset, rowBytes)
end function

function exactPrefix(text, prefix)
  source = bytes(text)
  wanted = bytes(prefix)
  if len(wanted) > len(source) then return false end if
  index = 0
  while index < len(wanted)
    if source[index] != wanted[index] then return false end if
    index = index + 1
  end while
  return true
end function

function sameAnimationName(left, right)
  leftBytes = bytes(left)
  rightBytes = bytes(right)
  if len(leftBytes) != len(rightBytes) or len(leftBytes) < 2 then return false end if
  index = 2
  while index < len(leftBytes)
    if leftBytes[index] != rightBytes[index] then return false end if
    index = index + 1
  end while
  return true
end function

function animationSlot(name)
  source = bytes(name)
  if len(source) < 2 or source[0] != 43 then return error(1727, "Bad animating texture " + name) end if
  value = source[1]
  if value >= 97 and value <= 122 then value = value - 32 end if
  if value >= 48 and value <= 57 then return [0, value - 48] end if
  if value >= 65 and value <= 74 then return [1, value - 65] end if
  return error(1727, "Bad animating texture " + name)
end function

function emptyAnimationTable(count)
  result = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    // anim_total, anim_min, anim_max, anim_next, alternate_anims
    result[index] = [0, 0, 0, -1, -1]
    index = index + 1
  end while
  return result
end function

// The pointer links of texture_t are represented as stable texture indices.
function sequenceTextureAnimations(textures)
  table = emptyAnimationTable(len(textures))
  index = 0
  while index < len(textures)
    texture = textures[index]
    if texture is void or not exactPrefix(texture.name, "+") or table[index][3] >= 0 then index = index + 1; continue end if
    regular = arrayutil.makeFilledArray(10, -1)
    alternate = arrayutil.makeFilledArray(10, -1)
    max = 0
    alternateMax = 0

    scan = index
    while scan < len(textures)
      candidate = textures[scan]
      if candidate is not void and exactPrefix(candidate.name, "+") and sameAnimationName(candidate.name, texture.name) then
        slot = animationSlot(candidate.name)
        if slot is error then return slot end if
        if slot[0] == 0 then
          regular[slot[1]] = scan
          if slot[1] + 1 > max then max = slot[1] + 1 end if
        else
          alternate[slot[1]] = scan
          if slot[1] + 1 > alternateMax then alternateMax = slot[1] + 1 end if
        end if
      end if
      scan = scan + 1
    end while

    frame = 0
    while frame < max
      textureIndex = regular[frame]
      if textureIndex < 0 then return error(1728, "Missing frame " + frame + " of " + texture.name) end if
      table[textureIndex] = [max * 2, frame * 2, (frame + 1) * 2, regular[(frame + 1) % max], -1]
      if alternateMax > 0 then table[textureIndex][4] = alternate[0] end if
      frame = frame + 1
    end while
    frame = 0
    while frame < alternateMax
      textureIndex = alternate[frame]
      if textureIndex < 0 then return error(1729, "Missing frame " + frame + " of " + texture.name) end if
      table[textureIndex] = [alternateMax * 2, frame * 2, (frame + 1) * 2, alternate[(frame + 1) % alternateMax], -1]
      if max > 0 then table[textureIndex][4] = regular[0] end if
      frame = frame + 1
    end while
    index = index + 1
  end while
  return table
end function

function textureAnimationIndex(textures, baseIndex, time, alternate)
  if baseIndex < 0 or baseIndex >= len(textures) or textures[baseIndex] is void then return baseIndex end if
  table = sequenceTextureAnimations(textures)
  if table is error then return table end if
  current = baseIndex
  if alternate and table[current][4] >= 0 then current = table[current][4] end if
  total = table[current][0]
  if total == 0 then return current end if
  relative = native.trunc(time * 10.0) % total
  traversed = 0
  while relative < table[current][1] or relative >= table[current][2]
    current = table[current][3]
    traversed = traversed + 1
    if current < 0 or current >= len(table) or traversed > 100 then return error(1730, "R_TextureAnimation: broken cycle") end if
  end while
  return current
end function

function floorValue(value)
  result = native.trunc(value)
  if result > value then result = result - 1 end if
  return result
end function

function ceilValue(value)
  result = native.trunc(value)
  if result < value then result = result + 1 end if
  return result
end function

function surfaceVertex(map, face, edgeNumber)
  surfEdgeIndex = face.firstEdge + edgeNumber
  if surfEdgeIndex < 0 or surfEdgeIndex >= len(map.surfEdges) then return error(1731, "CalcSurfaceExtents: bad surfedge") end if
  signedEdge = map.surfEdges[surfEdgeIndex]
  edgeIndex = signedEdge
  if edgeIndex < 0 then edgeIndex = -edgeIndex end if
  if edgeIndex < 0 or edgeIndex >= len(map.edges) then return error(1732, "CalcSurfaceExtents: bad edge") end if
  edge = map.edges[edgeIndex]
  vertexIndex = edge.vertex0
  if signedEdge < 0 then vertexIndex = edge.vertex1 end if
  if vertexIndex < 0 or vertexIndex >= len(map.vertices) then return error(1733, "CalcSurfaceExtents: bad vertex") end if
  return map.vertices[vertexIndex].position
end function

function CalcSurfaceExtents(map, faceIndex)
  if faceIndex < 0 or faceIndex >= len(map.faces) then return error(1734, "CalcSurfaceExtents: bad surface") end if
  face = map.faces[faceIndex]
  if face.texInfo < 0 or face.texInfo >= len(map.texInfo) then return error(1735, "CalcSurfaceExtents: bad texinfo") end if
  tex = map.texInfo[face.texInfo]
  minimums = [999999.0, 999999.0]
  maximums = [-99999.0, -99999.0]
  edge = 0
  while edge < face.numEdges
    vertex = surfaceVertex(map, face, edge)
    if vertex is error then return vertex end if
    s = vertex.x * tex.s[0] + vertex.y * tex.s[1] + vertex.z * tex.s[2] + tex.s[3]
    tv = vertex.x * tex.t[0] + vertex.y * tex.t[1] + vertex.z * tex.t[2] + tex.t[3]
    if s < minimums[0] then minimums[0] = s end if
    if s > maximums[0] then maximums[0] = s end if
    if tv < minimums[1] then minimums[1] = tv end if
    if tv > maximums[1] then maximums[1] = tv end if
    edge = edge + 1
  end while
  textureMins = [0, 0]
  extents = [0, 0]
  axis = 0
  while axis < 2
    blockMin = floorValue(minimums[axis] / 16.0)
    blockMax = ceilValue(maximums[axis] / 16.0)
    textureMins[axis] = blockMin * 16
    extents[axis] = (blockMax - blockMin) * 16
    if (tex.flags & c.TEX_SPECIAL) == 0 and extents[axis] > 512 then return error(1736, "Bad surface extents") end if
    axis = axis + 1
  end while
  return [textureMins, extents]
end function

function texInfoMipAdjust(info)
  lengthS = native.sqrt(info.s[0] * info.s[0] + info.s[1] * info.s[1] + info.s[2] * info.s[2])
  lengthT = native.sqrt(info.t[0] * info.t[0] + info.t[1] * info.t[1] + info.t[2] * info.t[2])
  average = (lengthS + lengthT) / 2.0
  if average < 0.32 then return 4 end if
  if average < 0.49 then return 3 end if
  if average < 0.99 then return 2 end if
  return 1
end function

function planeSignBits(plane)
  bits = 0
  if plane.normal.x < 0.0 then bits = bits | 1 end if
  if plane.normal.y < 0.0 then bits = bits | 2 end if
  if plane.normal.z < 0.0 then bits = bits | 4 end if
  return bits
end function

function Mod_SetParent(map)
  nodeParents = arrayutil.makeFilledArray(len(map.nodes), -1)
  leafParents = arrayutil.makeFilledArray(len(map.leafs), -1)
  if len(map.nodes) == 0 then return [nodeParents, leafParents] end if
  pendingNodes = arrayutil.makeFilledArray(len(map.nodes), 0)
  pendingParents = arrayutil.makeFilledArray(len(map.nodes), -1)
  visited = bytes(len(map.nodes))
  top = 1
  while top > 0
    top = top - 1
    nodeIndex = pendingNodes[top]
    parentIndex = pendingParents[top]
    if nodeIndex < 0 or nodeIndex >= len(map.nodes) then return error(1737, "Mod_SetParent: bad node") end if
    if visited[nodeIndex] != 0 then return error(1754, "Mod_SetParent: cyclic node graph") end if
    visited[nodeIndex] = 1
    nodeParents[nodeIndex] = parentIndex
    node = map.nodes[nodeIndex]
    children = [node.child0, node.child1]
    for each child in children
      if child >= 0 then
        if top >= len(pendingNodes) then return error(1754, "Mod_SetParent: cyclic node graph") end if
        pendingNodes[top] = child
        pendingParents[top] = nodeIndex
        top = top + 1
      else
        leafIndex = -1 - child
        if leafIndex < 0 or leafIndex >= len(map.leafs) then return error(1738, "Mod_SetParent: bad leaf") end if
        leafParents[leafIndex] = nodeIndex
      end if
    end for
  end while
  return [nodeParents, leafParents]
end function

function faceUnderwater(map, faceIndex)
  leafIndex = 0
  while leafIndex < len(map.leafs)
    leaf = map.leafs[leafIndex]
    if leaf.contents != c.CONTENTS_EMPTY then
      mark = 0
      while mark < leaf.numMarkSurfaces
        markIndex = leaf.firstMarkSurface + mark
        if markIndex >= 0 and markIndex < len(map.markSurfaces) and map.markSurfaces[markIndex] == faceIndex then return true end if
        mark = mark + 1
      end while
    end if
    leafIndex = leafIndex + 1
  end while
  return false
end function

function validateBrushModel(map)
  if len(map.models) == 0 then return error(1748, "Mod_LoadBrushModel: no submodels") end if
  animations = sequenceTextureAnimations(map.textures)
  if animations is error then return animations end if
  index = 0
  while index < len(map.edges)
    edge = map.edges[index]
    if edge.vertex0 < 0 or edge.vertex0 >= len(map.vertices) or edge.vertex1 < 0 or edge.vertex1 >= len(map.vertices) then
      return error(1739, "Mod_LoadEdges: bad vertex number")
    end if
    index = index + 1
  end while
  index = 0
  while index < len(map.texInfo)
    info = map.texInfo[index]
    if len(map.textures) > 0 and (info.textureIndex < 0 or info.textureIndex >= len(map.textures)) then
      return error(1740, "miptex >= loadmodel->numtextures")
    end if
    texInfoMipAdjust(info)
    index = index + 1
  end while
  index = 0
  while index < len(map.faces)
    face = map.faces[index]
    if face.planeIndex < 0 or face.planeIndex >= len(map.planes) then return error(1741, "Mod_LoadFaces: bad plane") end if
    if face.texInfo < 0 or face.texInfo >= len(map.texInfo) then return error(1742, "Mod_LoadFaces: bad texinfo") end if
    extents = CalcSurfaceExtents(map, index)
    if extents is error then return extents end if
    index = index + 1
  end while
  index = 0
  while index < len(map.markSurfaces)
    if map.markSurfaces[index] < 0 or map.markSurfaces[index] >= len(map.faces) then return error(1743, "Mod_ParseMarksurfaces: bad surface number") end if
    index = index + 1
  end while
  index = 0
  while index < len(map.nodes)
    node = map.nodes[index]
    if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return error(1744, "Mod_LoadNodes: bad plane") end if
    children = [node.child0, node.child1]
    for each child in children
      if child >= len(map.nodes) then return error(1745, "Mod_LoadNodes: bad child") end if
      if child < 0 and (-1 - child < 0 or -1 - child >= len(map.leafs)) then return error(1746, "Mod_LoadNodes: bad leaf") end if
    end for
    index = index + 1
  end while
  index = 0
  while index < len(map.clipNodes)
    if map.clipNodes[index].planeIndex < 0 or map.clipNodes[index].planeIndex >= len(map.planes) then return error(1747, "Mod_LoadClipnodes: bad plane") end if
    index = index + 1
  end while
  index = 0
  while index < len(map.leafs)
    leaf = map.leafs[index]
    if leaf.firstMarkSurface < 0 or leaf.numMarkSurfaces < 0 or leaf.firstMarkSurface + leaf.numMarkSurfaces > len(map.markSurfaces) then
      return error(1749, "Mod_LoadLeafs: bad marksurface range")
    end if
    if leaf.visibilityOffset >= len(map.visibility) then return error(1750, "Mod_LoadLeafs: bad visibility offset") end if
    index = index + 1
  end while
  index = 0
  while index < len(map.models)
    model = map.models[index]
    if model.firstFace < 0 or model.numFaces < 0 or model.firstFace + model.numFaces > len(map.faces) then
      return error(1751, "Mod_LoadSubmodels: bad face range")
    end if
    if model.headNodes[0] < 0 or model.headNodes[0] >= len(map.nodes) then return error(1752, "Mod_LoadSubmodels: bad draw headnode") end if
    hull = 1
    while hull < 4
      if model.headNodes[hull] >= len(map.clipNodes) then return error(1753, "Mod_LoadSubmodels: bad clip headnode") end if
      hull = hull + 1
    end while
    index = index + 1
  end while
  parents = Mod_SetParent(map)
  if parents is error then return parents end if
  return true
end function

// Logical equivalents of the original per-lump loaders.  Their storage
// outputs are immutable arrays rather than hunk pointer ranges.
function Mod_LoadTextures(data, lump)
  textures = parseTextures(data, lump)
  if textures is error then return textures end if
  animation = sequenceTextureAnimations(textures)
  if animation is error then return animation end if
  return textures
end function

function Mod_LoadLighting(data, lump)
  return slice(data, lump.offset, lump.length)
end function

function Mod_LoadVisibility(data, lump)
  return slice(data, lump.offset, lump.length)
end function

function Mod_LoadEntities(data, lump)
  if lump.length == 0 then return "" end if
  return protocolText.decodeBytes(slice(data, lump.offset, lump.length))
end function

function Mod_LoadVertexes(data, lump)
  return parseVertices(data, lump)
end function

function Mod_LoadSubmodels(data, lump)
  return parseModels(data, lump)
end function

function Mod_LoadEdges(data, lump)
  return parseEdges(data, lump)
end function

function Mod_LoadTexinfo(data, lump)
  return parseTexInfo(data, lump)
end function

function Mod_LoadFaces(data, lump)
  return parseFaces(data, lump)
end function

function Mod_LoadNodes(data, lump)
  return parseNodes(data, lump)
end function

function Mod_LoadLeafs(data, lump)
  return parseLeafs(data, lump)
end function

function Mod_LoadClipnodes(data, lump)
  return parseClipNodes(data, lump)
end function

function Mod_LoadMarksurfaces(data, lump)
  return parseMarkSurfaces(data, lump)
end function

function Mod_LoadSurfedges(data, lump)
  return parseSurfEdges(data, lump)
end function

function Mod_LoadPlanes(data, lump)
  return parsePlanes(data, lump)
end function

function parse(data, filename)
  if len(data) < 4 then return error(1722, filename + ": BSP file is truncated") end if
  version = bio.i32(data, 0)
  if version != c.BSP_VERSION then return error(1723, filename + ": unsupported BSP version " + version) end if
  lumps = parseLumps(data)
  if lumps is error then return lumps end if
  entityLump = lumps[c.LUMP_ENTITIES]
  entityText = Mod_LoadEntities(data, entityLump)
  if entityText is error then return entityText end if
  entities = parseEntities(entityText)
  if entities is error then return entities end if
  planes = Mod_LoadPlanes(data, lumps[c.LUMP_PLANES])
  if planes is error then return planes end if
  textures = Mod_LoadTextures(data, lumps[c.LUMP_TEXTURES])
  if textures is error then return textures end if
  vertices = Mod_LoadVertexes(data, lumps[c.LUMP_VERTEXES])
  if vertices is error then return vertices end if
  visibility = Mod_LoadVisibility(data, lumps[c.LUMP_VISIBILITY])
  if visibility is error then return visibility end if
  nodes = Mod_LoadNodes(data, lumps[c.LUMP_NODES])
  if nodes is error then return nodes end if
  texInfo = Mod_LoadTexinfo(data, lumps[c.LUMP_TEXINFO])
  if texInfo is error then return texInfo end if
  faces = Mod_LoadFaces(data, lumps[c.LUMP_FACES])
  if faces is error then return faces end if
  lighting = Mod_LoadLighting(data, lumps[c.LUMP_LIGHTING])
  if lighting is error then return lighting end if
  clipNodes = Mod_LoadClipnodes(data, lumps[c.LUMP_CLIPNODES])
  if clipNodes is error then return clipNodes end if
  leafs = Mod_LoadLeafs(data, lumps[c.LUMP_LEAFS])
  if leafs is error then return leafs end if
  markSurfaces = Mod_LoadMarksurfaces(data, lumps[c.LUMP_MARKSURFACES])
  if markSurfaces is error then return markSurfaces end if
  edges = Mod_LoadEdges(data, lumps[c.LUMP_EDGES])
  if edges is error then return edges end if
  surfEdges = Mod_LoadSurfedges(data, lumps[c.LUMP_SURFEDGES])
  if surfEdges is error then return surfEdges end if
  models = Mod_LoadSubmodels(data, lumps[c.LUMP_MODELS])
  if models is error then return models end if
  map = t.BspMap(filename, data, version, lumps, entityText, entities, planes, textures, vertices, visibility, nodes, texInfo, faces, lighting, clipNodes, leafs, markSurfaces, edges, surfEdges, models)
  valid = validateBrushModel(map)
  if valid is error then return valid end if
  return map
end function

function Mod_LoadBrushModel(data, filename)
  return parse(data, filename)
end function

function load(filename)
  data = fs.readAllBytes(filename)
  return parse(data, filename)
end function
