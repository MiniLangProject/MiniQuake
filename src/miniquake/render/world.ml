package miniquake.render.world

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.render.gl11 as gl
import miniquake.world_bsp as world
import miniquake.format.bsp as bsp
import miniquake.array_util as arrayutil

function startsWith(text, prefix)
  textBytes = bytes(text)
  prefixBytes = bytes(prefix)
  if len(prefixBytes) > len(textBytes) then return false end if
  index = 0
  while index < len(prefixBytes)
    left = textBytes[index]
    right = prefixBytes[index]
    if left >= 65 and left <= 90 then left = left + 32 end if
    if right >= 65 and right <= 90 then right = right + 32 end if
    if left != right then return false end if
    index = index + 1
  end while
  return true
end function

function floorValue(value)
  truncated = native.trunc(value)
  if truncated > value then truncated = truncated - 1 end if
  return truncated
end function

function ceilValue(value)
  truncated = native.trunc(value)
  if truncated < value then truncated = truncated + 1 end if
  return truncated
end function

function faceVertex(map, face, edgeNumber)
  surfEdgeIndex = face.firstEdge + edgeNumber
  if surfEdgeIndex < 0 or surfEdgeIndex >= len(map.surfEdges) then return error(2700, "R_BuildSurface: bad surfedge") end if
  signedEdge = map.surfEdges[surfEdgeIndex]
  edgeIndex = signedEdge
  if edgeIndex < 0 then edgeIndex = -edgeIndex end if
  if edgeIndex < 0 or edgeIndex >= len(map.edges) then return error(2701, "R_BuildSurface: bad edge") end if
  edge = map.edges[edgeIndex]
  vertexIndex = edge.vertex0
  if signedEdge < 0 then vertexIndex = edge.vertex1 end if
  if vertexIndex < 0 or vertexIndex >= len(map.vertices) then return error(2702, "R_BuildSurface: bad vertex") end if
  return map.vertices[vertexIndex].position
end function

function indexedToRgba(indexed, palette, transparent)
  if len(palette) < 768 then return error(2703, "palette.lmp is truncated") end if
  output = bytes(len(indexed) * 4)
  index = 0
  while index < len(indexed)
    color = indexed[index]
    output[index * 4] = palette[color * 3]
    output[index * 4 + 1] = palette[color * 3 + 1]
    output[index * 4 + 2] = palette[color * 3 + 2]
    alpha = 255
    if transparent and color == 255 then alpha = 0 end if
    output[index * 4 + 3] = alpha
    index = index + 1
  end while
  return output
end function

function missingTexturePixels()
  output = bytes(16 * 16 * 4)
  y = 0
  while y < 16
    x = 0
    while x < 16
      bright = ((x >> 2) ^ (y >> 2)) & 1
      offset = (y * 16 + x) * 4
      if bright == 1 then
        output[offset] = 255
        output[offset + 1] = 0
        output[offset + 2] = 255
      else
        output[offset] = 32
        output[offset + 1] = 0
        output[offset + 2] = 32
      end if
      output[offset + 3] = 255
      x = x + 1
    end while
    y = y + 1
  end while
  return output
end function

function uploadPixels(width, height, rgba, nearest)
  textureId = gl.generateTexture()
  gl.bindTexture(textureId)
  filter = gl.GL_LINEAR
  if nearest then filter = gl.GL_NEAREST end if
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, filter)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, filter)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
  gl.uploadRgba(width, height, rgba)
  return textureId
end function

function textureFlags(textureName, faceSide)
  flags = 0
  if faceSide != 0 then flags = flags | c.SURF_PLANEBACK end if
  if startsWith(textureName, "sky") then flags = flags | c.SURF_DRAWSKY | c.SURF_DRAWTILED end if
  if startsWith(textureName, "*") then flags = flags | c.SURF_DRAWTURB | c.SURF_DRAWTILED end if
  return flags
end function

function buildSurface(map, faceIndex)
  if faceIndex < 0 or faceIndex >= len(map.faces) then return error(2704, "R_BuildSurface: bad face") end if
  face = map.faces[faceIndex]
  if face.texInfo < 0 or face.texInfo >= len(map.texInfo) then return error(2705, "R_BuildSurface: bad texinfo") end if
  info = map.texInfo[face.texInfo]
  textureIndex = info.textureIndex
  textureName = ""
  textureWidth = 16
  textureHeight = 16
  if textureIndex >= 0 and textureIndex < len(map.textures) and map.textures[textureIndex] is not void then
    textureName = map.textures[textureIndex].name
    if map.textures[textureIndex].width > 0 then textureWidth = map.textures[textureIndex].width end if
    if map.textures[textureIndex].height > 0 then textureHeight = map.textures[textureIndex].height end if
  end if

  minimumS = 99999999.0
  minimumT = 99999999.0
  maximumS = -99999999.0
  maximumT = -99999999.0
  rawVertices = arrayutil.makeEmptyArray(face.numEdges)
  edgeNumber = 0
  while edgeNumber < face.numEdges
    position = faceVertex(map, face, edgeNumber)
    rawS = position.x * info.s[0] + position.y * info.s[1] + position.z * info.s[2] + info.s[3]
    rawT = position.x * info.t[0] + position.y * info.t[1] + position.z * info.t[2] + info.t[3]
    if rawS < minimumS then minimumS = rawS end if
    if rawS > maximumS then maximumS = rawS end if
    if rawT < minimumT then minimumT = rawT end if
    if rawT > maximumT then maximumT = rawT end if
    rawVertices[edgeNumber] = [position, rawS, rawT]
    edgeNumber = edgeNumber + 1
  end while

  minimumBlockS = floorValue(minimumS / 16.0)
  minimumBlockT = floorValue(minimumT / 16.0)
  maximumBlockS = ceilValue(maximumS / 16.0)
  maximumBlockT = ceilValue(maximumT / 16.0)
  textureMinS = minimumBlockS * 16
  textureMinT = minimumBlockT * 16
  extentS = (maximumBlockS - minimumBlockS) * 16
  extentT = (maximumBlockT - minimumBlockT) * 16
  lightWidth = extentS / 16 + 1
  lightHeight = extentT / 16 + 1
  if lightWidth < 1 then lightWidth = 1 end if
  if lightHeight < 1 then lightHeight = 1 end if

  vertices = arrayutil.makeEmptyArray(face.numEdges)
  vertexNumber = 0
  while vertexNumber < face.numEdges
    raw = rawVertices[vertexNumber]
    position = raw[0]
    rawS = raw[1]
    rawT = raw[2]
    textureS = rawS / textureWidth
    textureT = rawT / textureHeight
    lightS = (rawS - textureMinS + 8.0) / (lightWidth * 16.0)
    lightT = (rawT - textureMinT + 8.0) / (lightHeight * 16.0)
    vertices[vertexNumber] = t.RenderVertex(math.copy(position), textureS, textureT, lightS, lightT)
    vertexNumber = vertexNumber + 1
  end while

  flags = textureFlags(textureName, face.side)
  if (info.flags & c.TEX_SPECIAL) != 0 then flags = flags | c.SURF_DRAWTILED end if
  return t.RenderSurface(
    faceIndex,
    textureIndex,
    t.Vec3(textureMinS, textureMinT, 0.0),
    t.Vec3(extentS, extentT, 0.0),
    lightWidth,
    lightHeight,
    face.lightOffset,
    flags,
    vertices,
    0,
  )
end function

function buildLightmap(renderer, surface)
  if surface.lightOffset < 0 then return 0 end if
  if (surface.flags & c.SURF_DRAWTILED) != 0 then return 0 end if
  count = surface.lightWidth * surface.lightHeight
  if count <= 0 then return 0 end if
  if surface.lightOffset + count > len(renderer.map.lighting) then return 0 end if
  pixels = bytes(count * 4)
  index = 0
  while index < count
    value = renderer.map.lighting[surface.lightOffset + index]
    offset = index * 4
    pixels[offset] = value
    pixels[offset + 1] = value
    pixels[offset + 2] = value
    pixels[offset + 3] = 255
    index = index + 1
  end while
  textureId = gl.generateTexture()
  gl.bindTexture(textureId)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
  gl.uploadRgba(surface.lightWidth, surface.lightHeight, pixels)
  return textureId
end function

function create(map, palette)
  if len(palette) < 768 then return error(2706, "R_NewMap: invalid palette") end if
  textures = arrayutil.makeEmptyArray(len(map.textures))
  textureIndex = 0
  while textureIndex < len(map.textures)
    sourceTexture = map.textures[textureIndex]
    if sourceTexture is void then
      textures[textureIndex] = void
    else
      transparent = startsWith(sourceTexture.name, "{")
      textures[textureIndex] = t.RenderTexture(sourceTexture.name, sourceTexture.width, sourceTexture.height, 0, sourceTexture.pixels, transparent)
    end if
    textureIndex = textureIndex + 1
  end while
  surfaces = arrayutil.makeEmptyArray(len(map.faces))
  faceIndex = 0
  while faceIndex < len(map.faces)
    surfaces[faceIndex] = buildSurface(map, faceIndex)
    faceIndex = faceIndex + 1
  end while
  visible = bytes(len(map.faces), 1)
  return t.WorldRenderer(map, palette, textures, surfaces, [], false, 0, false, false, 0, visible, 0, 1.0)
end function

function upload(renderer)
  if renderer.uploaded then return renderer end if
  renderer.noTextureId = uploadPixels(16, 16, missingTexturePixels(), true)
  index = 0
  while index < len(renderer.textures)
    texture = renderer.textures[index]
    if texture is not void and texture.width > 0 and texture.height > 0 and len(texture.pixels) >= texture.width * texture.height then
      // gl_model.c does not pass sky textures through GL_LoadTexture; the two
      // scrolling layers are created exclusively by R_InitSky.
      if startsWith(texture.name, "sky") then
        texture.glId = 0
      else
        rgba = indexedToRgba(texture.pixels, renderer.palette, texture.transparent)
        texture.glId = uploadPixels(texture.width, texture.height, rgba, true)
      end if
    end if
    index = index + 1
  end while

  zero = t.Vec3(0.0, 0.0, 0.0)
  R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0, true, true, false,
  )
  GL_BuildLightmaps()
  index = 0
  while index < len(renderer.textures)
    texture = renderer.textures[index]
    if texture is not void and startsWith(texture.name, "sky") then R_InitSky(texture) end if
    index = index + 1
  end while
  renderer.uploaded = true
  return renderer
end function

function destroy(renderer)
  if renderer is void then return false end if
  if renderer.noTextureId != 0 then gl.deleteTexture(renderer.noTextureId); renderer.noTextureId = 0 end if
  for each texture in renderer.textures
    if texture is not void and texture.glId != 0 then gl.deleteTexture(texture.glId); texture.glId = 0 end if
  end for
  for each surface in renderer.surfaces
    if surface.lightmapId != 0 then gl.deleteTexture(surface.lightmapId); surface.lightmapId = 0 end if
  end for
  renderer.uploaded = false
  return true
end function

function markAllVisible(renderer)
  renderer.visibleFaces = bytes(len(renderer.map.faces), 1)
  return len(renderer.map.faces)
end function

function markVisible(renderer, viewOrigin)
  map = renderer.map
  if len(map.leafs) <= 1 or len(map.models) == 0 then return markAllVisible(renderer) end if
  currentLeaf = world.leafForPoint(map, viewOrigin)
  renderer.viewLeaf = currentLeaf
  visibleFaces = bytes(len(map.faces), 0)
  rowBytes = (map.models[0].visibleLeafs + 7) >> 3
  visibility = bytes(rowBytes, 255)
  if currentLeaf >= 0 and currentLeaf < len(map.leafs) then
    offset = map.leafs[currentLeaf].visibilityOffset
    if offset >= 0 and rowBytes > 0 then visibility = bsp.decompressVisibility(map.visibility, offset, rowBytes) end if
  end if

  count = 0
  leafIndex = 1
  while leafIndex < len(map.leafs)
    visible = false
    bitIndex = leafIndex - 1
    if bitIndex < rowBytes * 8 then visible = (visibility[bitIndex >> 3] & (1 << (bitIndex & 7))) != 0 end if
    if leafIndex == currentLeaf then visible = true end if
    if visible then
      leaf = map.leafs[leafIndex]
      mark = 0
      while mark < leaf.numMarkSurfaces
        markIndex = leaf.firstMarkSurface + mark
        if markIndex >= 0 and markIndex < len(map.markSurfaces) then
          faceIndex = map.markSurfaces[markIndex]
          if faceIndex >= 0 and faceIndex < len(visibleFaces) and visibleFaces[faceIndex] == 0 then visibleFaces[faceIndex] = 1; count = count + 1 end if
        end if
        mark = mark + 1
      end while
    end if
    leafIndex = leafIndex + 1
  end while
  renderer.visibleFaces = visibleFaces
  return count
end function

function textureIdForSurface(renderer, surface)
  if surface.textureIndex >= 0 and surface.textureIndex < len(renderer.textures) then
    texture = renderer.textures[surface.textureIndex]
    if texture is not void then
      animated = R_TextureAnimation(texture)
      if animated is not void and animated.glId != 0 then return animated.glId end if
    end if
  end if
  return renderer.noTextureId
end function

function drawBaseSurface(renderer, surface)
  if len(surface.vertices) < 3 then return end if
  gl.bindTexture(textureIdForSurface(renderer, surface))
  transparent = false
  if surface.textureIndex >= 0 and surface.textureIndex < len(renderer.textures) and renderer.textures[surface.textureIndex] is not void then transparent = renderer.textures[surface.textureIndex].transparent end if
  if transparent then gl.enable(gl.GL_ALPHA_TEST); gl.alphaFunc(gl.GL_GREATER, 0.5) end if
  gl.color(255, 255, 255, 255)
  gl.begin(gl.GL_POLYGON)
  for each vertex in surface.vertices
    gl.texcoord2(vertex.s, vertex.t)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  if transparent then gl.disable(gl.GL_ALPHA_TEST) end if
end function

function drawLightSurface(surface)
  if surface.lightmapId == 0 or len(surface.vertices) < 3 then return end if
  gl.bindTexture(surface.lightmapId)
  gl.begin(gl.GL_POLYGON)
  for each vertex in surface.vertices
    gl.texcoord2(vertex.lightS, vertex.lightT)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
end function

function setupView(width, height, origin, angles)
  if width <= 0 then width = 1 end if
  if height <= 0 then height = 1 end if
  aspect = width * 1.0 / height
  nearValue = 4.0
  gl.viewport(0, 0, width, height)
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  gl.frustum(-nearValue, nearValue, -nearValue / aspect, nearValue / aspect, nearValue, 8192.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.rotate(-90.0, 1.0, 0.0, 0.0)
  gl.rotate(90.0, 0.0, 0.0, 1.0)
  gl.rotate(-angles.z, 1.0, 0.0, 0.0)
  gl.rotate(-angles.x, 0.0, 1.0, 0.0)
  gl.rotate(-angles.y, 0.0, 0.0, 1.0)
  gl.translate(-origin.x, -origin.y, -origin.z)
end function

function render(renderer, width, height, origin, angles)
  if not renderer.uploaded then upload(renderer) end if
  vectors = math.angleVectors(angles)
  R_ConfigureWorldCompatibility(
    renderer, origin, angles, vectors[0], vectors[1], vectors[2],
    [], [], [0.0, 0.0, 0.0, 0.0], renderer.frameCount * 0.02,
    renderer.frameCount * 0.02, 0.02, true, true, false,
  )
  R_AdvanceFrameCounters()
  R_AnimateLight()
  R_MarkLeaves()
  gl.viewport(0, 0, width, height)
  gl.clearColor(0.0, 0.0, 0.0, 1.0)
  gl.clear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT)
  gl.enable(gl.GL_DEPTH_TEST)
  gl.depthFunc(gl.GL_LEQUAL)
  gl.disable(gl.GL_CULL_FACE)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  if renderer.wireframe then gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE) end if
  setupView(width, height, origin, angles)
  R_PushDlights()
  count = R_DrawWorld()
  if not renderer.fullbright and not renderer.wireframe then R_BlendLightmaps() end if
  R_DrawWaterSurfaces()
  R_RenderDlights()
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  renderer.frameCount = renderer.frameCount + 1
  return count
end function

// =============================================================================
// Canonical GLQuake 1.09 renderer surface/light/warp entry points.
//
// The C renderer stores the active world, view vectors, light styles and
// dynamic lights in translation-unit globals.  MiniLang keeps the same state
// explicitly in package globals and refreshes it from Host_Frame through
// R_ConfigureWorldCompatibility.  Lightmaps remain one OpenGL texture per
// surface rather than a pointer-addressed 128x128 atlas; this is a technical
// storage adaptation only and the light contribution equations are the
// original GLQuake equations.
// =============================================================================

const GLQUAKE_BLOCK_WIDTH = 128
const GLQUAKE_BLOCK_HEIGHT = 128
const GLQUAKE_MAX_LIGHTMAPS = 64
const GLQUAKE_SURF_UNDERWATER = 0x80
const GLQUAKE_PLANE_ANYZ = 5
const GLQUAKE_TURBSCALE = 40.74366543152521

rCompatRenderer = void
rCompatViewOrigin = void
rCompatViewAngles = void
rCompatViewForward = void
rCompatViewRight = void
rCompatViewUp = void
rCompatDlights = []
rCompatLightStyles = []
rCompatBlend = [0.0, 0.0, 0.0, 0.0]
rCompatTime = 0.0
rCompatRealtime = 0.0
rCompatFrameTime = 0.0
rCompatFlashBlend = true
rCompatDynamic = true
rCompatNoVis = false
rCompatSurfaceDlightBits = []
rCompatSurfaceDlightFrame = []
rCompatSurfaceCachedLight = []
rCompatLightmapAllocated = []
rCompatLightmapModified = []
rCompatLightmapRectChange = []
rCompatWarpPolys = []
rCompatSkyTexture = 0
rCompatAlphaSkyTexture = 0
rCompatSkyChain = []
rCompatWaterChain = []
rCompatMultiTextureEnabled = false
rCompatMultiTextureAvailable = false
rCompatDepthMin = 0.0
rCompatDepthMax = 1.0
rCompatLightSpot = void
rCompatLightPlane = void

// Original GLQuake globals retained under their public names.
skytexturenum = -1
lightmap_bytes = 1
lightmap_textures = 0
active_lightmaps = 0
blocklights = []
lightmap_polys = []
lightmap_modified = []
lightmap_rectchange = []
allocated = []
lightmaps = bytes()
skychain = []
waterchain = []
mtexenabled = false
r_dlightframecount = 0
d_lightstylevalue = []
lightspot = void
lightplane = void
speedscale = 0.0
solidskytexture = 0
alphaskytexture = 0
r_framecount = 0
r_visframecount = 0

function compatZeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

function compatEmptyPlane()
  return t.Plane(compatZeroVector(), 0.0, GLQUAKE_PLANE_ANYZ, 0)
end function

function compatAbs(value)
  if value < 0.0 then return -value end if
  return value
end function

function compatEnsureArraySize(values, count, fillValue)
  if len(values) == count then return values end if
  return arrayutil.makeFilledArray(count, fillValue)
end function

function compatFreshLightmapAllocation()
  pages = arrayutil.makeEmptyArray(GLQUAKE_MAX_LIGHTMAPS)
  index = 0
  while index < GLQUAKE_MAX_LIGHTMAPS
    pages[index] = arrayutil.makeFilledArray(GLQUAKE_BLOCK_WIDTH, 0)
    index = index + 1
  end while
  return pages
end function

function compatEnsureWorldState()
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame, rCompatSurfaceCachedLight
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global blocklights, lightmap_polys, lightmap_modified, lightmap_rectchange, allocated, lightmaps
  global d_lightstylevalue
  if rCompatRenderer is void then return false end if
  count = len(rCompatRenderer.surfaces)
  if len(rCompatSurfaceDlightBits) != count then
    rCompatSurfaceDlightBits = arrayutil.makeFilledArray(count, 0)
    rCompatSurfaceDlightFrame = arrayutil.makeFilledArray(count, 0)
    rCompatSurfaceCachedLight = arrayutil.makeEmptyArray(count)
    index = 0
    while index < count
      rCompatSurfaceCachedLight[index] = [0, 0, 0, 0]
      index = index + 1
    end while
  end if
  if len(rCompatLightmapAllocated) != GLQUAKE_MAX_LIGHTMAPS then
    rCompatLightmapAllocated = compatFreshLightmapAllocation()
    rCompatLightmapModified = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, false)
    rCompatLightmapRectChange = arrayutil.makeEmptyArray(GLQUAKE_MAX_LIGHTMAPS)
    index = 0
    while index < GLQUAKE_MAX_LIGHTMAPS
      rCompatLightmapRectChange[index] = [GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, 0, 0]
      index = index + 1
    end while
  end if
  if len(d_lightstylevalue) != c.MAX_LIGHTSTYLES then d_lightstylevalue = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, 256) end if
  if len(blocklights) != 18 * 18 then blocklights = arrayutil.makeFilledArray(18 * 18, 0) end if
  allocated = rCompatLightmapAllocated
  lightmap_modified = rCompatLightmapModified
  lightmap_rectchange = rCompatLightmapRectChange
  lightmap_polys = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, [])
  if len(lightmaps) != GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * 4 then
    lightmaps = bytes(GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * 4)
  end if
  return true
end function

function R_ConfigureWorldCompatibility(
  renderer,
  viewOrigin,
  viewAngles,
  viewForward,
  viewRight,
  viewUp,
  dynamicLights,
  lightStyles,
  blend,
  currentTime,
  realtime,
  frameTime,
  flashBlend,
  dynamicEnabled,
  noVis,
)
  global rCompatRenderer, rCompatViewOrigin, rCompatViewAngles, rCompatViewForward
  global rCompatViewRight, rCompatViewUp, rCompatDlights, rCompatLightStyles
  global rCompatBlend, rCompatTime, rCompatRealtime, rCompatFrameTime
  global rCompatFlashBlend, rCompatDynamic, rCompatNoVis
  rCompatRenderer = renderer
  rCompatViewOrigin = viewOrigin
  rCompatViewAngles = viewAngles
  rCompatViewForward = viewForward
  rCompatViewRight = viewRight
  rCompatViewUp = viewUp
  rCompatDlights = dynamicLights
  rCompatLightStyles = lightStyles
  rCompatBlend = blend
  rCompatTime = currentTime
  rCompatRealtime = realtime
  rCompatFrameTime = frameTime
  rCompatFlashBlend = flashBlend
  rCompatDynamic = dynamicEnabled
  rCompatNoVis = noVis
  compatEnsureWorldState()
  return true
end function

function compatSurfaceIndex(surface)
  if rCompatRenderer is void then return -1 end if
  index = 0
  while index < len(rCompatRenderer.surfaces)
    if rCompatRenderer.surfaces[index] == surface then return index end if
    index = index + 1
  end while
  if typeof(surface) == "int" and surface >= 0 and surface < len(rCompatRenderer.surfaces) then return surface end if
  return -1
end function

function compatSurface(surface)
  if rCompatRenderer is void then return void end if
  if typeof(surface) == "int" then
    if surface < 0 or surface >= len(rCompatRenderer.surfaces) then return void end if
    return rCompatRenderer.surfaces[surface]
  end if
  return surface
end function

function compatFace(surface)
  value = compatSurface(surface)
  if value is void then return void end if
  if value.faceIndex < 0 or value.faceIndex >= len(rCompatRenderer.map.faces) then return void end if
  return rCompatRenderer.map.faces[value.faceIndex]
end function

function compatPlane(surface)
  face = compatFace(surface)
  if face is void then return void end if
  if face.planeIndex < 0 or face.planeIndex >= len(rCompatRenderer.map.planes) then return void end if
  return rCompatRenderer.map.planes[face.planeIndex]
end function

function compatTexInfo(surface)
  face = compatFace(surface)
  if face is void then return void end if
  if face.texInfo < 0 or face.texInfo >= len(rCompatRenderer.map.texInfo) then return void end if
  return rCompatRenderer.map.texInfo[face.texInfo]
end function

function compatPlaneDistance(plane, point)
  if plane.type == 0 then return point.x - plane.dist end if
  if plane.type == 1 then return point.y - plane.dist end if
  if plane.type == 2 then return point.z - plane.dist end if
  return math.dot(point, plane.normal) - plane.dist
end function

// -----------------------------------------------------------------------------
// gl_rlight.c
// -----------------------------------------------------------------------------

function R_AnimateLight()
  global d_lightstylevalue
  compatEnsureWorldState()
  tick = native.trunc(rCompatTime * 10.0)
  index = 0
  while index < c.MAX_LIGHTSTYLES
    style = ""
    if index < len(rCompatLightStyles) then style = rCompatLightStyles[index] end if
    data = bytes(style)
    if len(data) == 0 then
      d_lightstylevalue[index] = 256
    else
      character = data[tick % len(data)] - 97
      d_lightstylevalue[index] = character * 22
    end if
    index = index + 1
  end while
  return d_lightstylevalue
end function

function AddLightBlend(red, green, blue, alpha2)
  global rCompatBlend
  if len(rCompatBlend) < 4 then rCompatBlend = [0.0, 0.0, 0.0, 0.0] end if
  alpha = rCompatBlend[3] + alpha2 * (1.0 - rCompatBlend[3])
  rCompatBlend[3] = alpha
  if alpha <= 0.0 then return rCompatBlend end if
  fraction = alpha2 / alpha
  // Preserve the WinQuake 1.09 source quirk exactly: the red channel uses
  // the previous green channel as its accumulator.
  rCompatBlend[0] = rCompatBlend[1] * (1.0 - fraction) + red * fraction
  rCompatBlend[1] = rCompatBlend[1] * (1.0 - fraction) + green * fraction
  rCompatBlend[2] = rCompatBlend[2] * (1.0 - fraction) + blue * fraction
  return rCompatBlend
end function

function R_RenderDlight(light)
  if light is void or light.radius <= 0.0 or light.die < rCompatTime then return false end if
  radius = light.radius * 0.35
  delta = math.subtract(light.origin, rCompatViewOrigin)
  if math.length(delta) < radius then
    AddLightBlend(1.0, 0.5, 0.0, light.radius * 0.0003)
    return true
  end if
  center = math.subtract(light.origin, math.scale(rCompatViewForward, radius))
  gl.begin(gl.GL_TRIANGLE_FAN)
  gl.color(51, 26, 0, 255)
  gl.vertex3(center.x, center.y, center.z)
  gl.color(0, 0, 0, 255)
  index = 16
  while index >= 0
    angle = index / 16.0 * 3.141592653589793 * 2.0
    point = math.add(
      light.origin,
      math.add(
        math.scale(rCompatViewRight, math.cos(angle) * radius),
        math.scale(rCompatViewUp, math.sin(angle) * radius),
      ),
    )
    gl.vertex3(point.x, point.y, point.z)
    index = index - 1
  end while
  gl.finishPrimitive()
  return true
end function

function R_RenderDlights()
  global r_dlightframecount
  if not rCompatFlashBlend then return 0 end if
  r_dlightframecount = r_framecount + 1
  gl.depthMask(false)
  gl.disable(gl.GL_TEXTURE_2D)
  gl.shadeModel(gl.GL_SMOOTH)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_ONE, gl.GL_ONE)
  count = 0
  index = 0
  while index < len(rCompatDlights) and index < c.MAX_DLIGHTS
    light = rCompatDlights[index]
    if light is not void and light.die >= rCompatTime and light.radius > 0.0 then
      if R_RenderDlight(light) then count = count + 1 end if
    end if
    index = index + 1
  end while
  gl.color(255, 255, 255, 255)
  gl.disable(gl.GL_BLEND)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.depthMask(true)
  return count
end function

function R_MarkLights(light, bit, nodeNumber)
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame
  if rCompatRenderer is void or light is void or nodeNumber < 0 then return 0 end if
  if nodeNumber >= len(rCompatRenderer.map.nodes) then return 0 end if
  node = rCompatRenderer.map.nodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(rCompatRenderer.map.planes) then return 0 end if
  plane = rCompatRenderer.map.planes[node.planeIndex]
  distance = compatPlaneDistance(plane, light.origin)
  if distance > light.radius then return R_MarkLights(light, bit, node.child0) end if
  if distance < -light.radius then return R_MarkLights(light, bit, node.child1) end if
  marked = 0
  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < len(rCompatSurfaceDlightBits)
    if faceIndex >= 0 then
      if rCompatSurfaceDlightFrame[faceIndex] != r_dlightframecount then
        rCompatSurfaceDlightBits[faceIndex] = 0
        rCompatSurfaceDlightFrame[faceIndex] = r_dlightframecount
      end if
      rCompatSurfaceDlightBits[faceIndex] = rCompatSurfaceDlightBits[faceIndex] | bit
      marked = marked + 1
    end if
    faceIndex = faceIndex + 1
  end while
  marked = marked + R_MarkLights(light, bit, node.child0)
  marked = marked + R_MarkLights(light, bit, node.child1)
  return marked
end function

function R_PushDlights()
  global r_dlightframecount
  if rCompatFlashBlend or not rCompatDynamic or rCompatRenderer is void then return 0 end if
  compatEnsureWorldState()
  r_dlightframecount = r_framecount + 1
  if len(rCompatRenderer.map.models) == 0 then return 0 end if
  root = rCompatRenderer.map.models[0].headNodes[0]
  count = 0
  index = 0
  while index < len(rCompatDlights) and index < c.MAX_DLIGHTS
    light = rCompatDlights[index]
    if light is not void and light.die >= rCompatTime and light.radius > 0.0 then
      count = count + R_MarkLights(light, 1 << index, root)
    end if
    index = index + 1
  end while
  return count
end function

function R_AddDynamicLights(surface)
  global blocklights
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 then return blocklights end if
  face = compatFace(value)
  plane = compatPlane(value)
  info = compatTexInfo(value)
  if face is void or plane is void or info is void then return blocklights end if
  smax = value.lightWidth
  tmax = value.lightHeight
  bitsValue = rCompatSurfaceDlightBits[index]
  lightNumber = 0
  while lightNumber < len(rCompatDlights) and lightNumber < c.MAX_DLIGHTS
    if (bitsValue & (1 << lightNumber)) != 0 then
      light = rCompatDlights[lightNumber]
      radius = light.radius
      planeDistance = math.dot(light.origin, plane.normal) - plane.dist
      radius = radius - compatAbs(planeDistance)
      minimum = light.minLight
      if radius >= minimum then
        minimum = radius - minimum
        impact = math.subtract(light.origin, math.scale(plane.normal, planeDistance))
        localS = math.dot(impact, t.Vec3(info.s[0], info.s[1], info.s[2])) + info.s[3] - value.textureMins.x
        localT = math.dot(impact, t.Vec3(info.t[0], info.t[1], info.t[2])) + info.t[3] - value.textureMins.y
        sampleT = 0
        while sampleT < tmax
          td = native.trunc(localT - sampleT * 16)
          if td < 0 then td = -td end if
          sampleS = 0
          while sampleS < smax
            sd = native.trunc(localS - sampleS * 16)
            if sd < 0 then sd = -sd end if
            distance = td + (sd >> 1)
            if sd > td then distance = sd + (td >> 1) end if
            if distance < minimum then
              blocklights[sampleT * smax + sampleS] = blocklights[sampleT * smax + sampleS] + native.trunc((radius - distance) * 256.0)
            end if
            sampleS = sampleS + 1
          end while
          sampleT = sampleT + 1
        end while
      end if
    end if
    lightNumber = lightNumber + 1
  end while
  return blocklights
end function

function R_BuildLightMap(surface, destination, stride)
  global blocklights, rCompatSurfaceCachedLight
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 then return error(3760, "R_BuildLightMap: bad surface") end if
  compatEnsureWorldState()
  width = value.lightWidth
  height = value.lightHeight
  count = width * height
  if count < 1 then return bytes() end if
  if destination is void then destination = bytes(count) end if
  if destination is not bytes then return error(3761, "R_BuildLightMap: destination must be bytes") end if
  if stride < width then stride = width end if
  required = (height - 1) * stride + width
  if len(destination) < required then return error(3762, "R_BuildLightMap: destination is too small") end if
  if len(blocklights) < count then blocklights = arrayutil.makeFilledArray(count, 0) end if

  fullbright = rCompatRenderer.fullbright
  if fullbright or len(rCompatRenderer.map.lighting) == 0 or value.lightOffset < 0 then
    sample = 0
    while sample < count
      blocklights[sample] = 255 * 256
      sample = sample + 1
    end while
  else
    sample = 0
    while sample < count
      blocklights[sample] = 0
      sample = sample + 1
    end while
    face = compatFace(value)
    mapNumber = 0
    while mapNumber < len(face.styles) and mapNumber < 4 and face.styles[mapNumber] != 255
      style = face.styles[mapNumber]
      scaleValue = 256
      if style >= 0 and style < len(d_lightstylevalue) then scaleValue = d_lightstylevalue[style] end if
      rCompatSurfaceCachedLight[index][mapNumber] = scaleValue
      sourceOffset = value.lightOffset + mapNumber * count
      sample = 0
      while sample < count and sourceOffset + sample < len(rCompatRenderer.map.lighting)
        blocklights[sample] = blocklights[sample] + rCompatRenderer.map.lighting[sourceOffset + sample] * scaleValue
        sample = sample + 1
      end while
      mapNumber = mapNumber + 1
    end while
    if rCompatSurfaceDlightFrame[index] == r_dlightframecount then R_AddDynamicLights(value) end if
  end if

  y = 0
  while y < height
    x = 0
    while x < width
      lightValue = blocklights[y * width + x] >> 7
      if lightValue > 255 then lightValue = 255 end if
      destination[y * stride + x] = 255 - lightValue
      x = x + 1
    end while
    y = y + 1
  end while
  return destination
end function

function RecursiveLightPoint(nodeNumber, start, finish)
  global lightspot, lightplane, rCompatLightSpot, rCompatLightPlane
  if rCompatRenderer is void or nodeNumber < 0 then return -1 end if
  if nodeNumber >= len(rCompatRenderer.map.nodes) then return -1 end if
  node = rCompatRenderer.map.nodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(rCompatRenderer.map.planes) then return -1 end if
  plane = rCompatRenderer.map.planes[node.planeIndex]
  front = compatPlaneDistance(plane, start)
  back = compatPlaneDistance(plane, finish)
  side = 0
  if front < 0.0 then side = 1 end if
  if (back < 0.0 and side == 1) or (back >= 0.0 and side == 0) then
    childNumber = node.child0
    if side == 1 then childNumber = node.child1 end if
    return RecursiveLightPoint(childNumber, start, finish)
  end if
  fraction = front / (front - back)
  middle = math.add(start, math.scale(math.subtract(finish, start), fraction))
  childNumber = node.child0
  if side == 1 then childNumber = node.child1 end if
  result = RecursiveLightPoint(childNumber, start, middle)
  if result >= 0 then return result end if
  if (back < 0.0 and side == 1) or (back >= 0.0 and side == 0) then return -1 end if

  lightspot = math.copy(middle)
  lightplane = plane
  rCompatLightSpot = lightspot
  rCompatLightPlane = lightplane
  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      if (surface.flags & c.SURF_DRAWTILED) == 0 then
        info = compatTexInfo(surface)
        coordinateS = native.trunc(math.dot(middle, t.Vec3(info.s[0], info.s[1], info.s[2])) + info.s[3])
        coordinateT = native.trunc(math.dot(middle, t.Vec3(info.t[0], info.t[1], info.t[2])) + info.t[3])
        if coordinateS >= surface.textureMins.x and coordinateT >= surface.textureMins.y then
          ds = coordinateS - surface.textureMins.x
          dt = coordinateT - surface.textureMins.y
          if ds <= surface.extents.x and dt <= surface.extents.y then
            if surface.lightOffset < 0 or len(rCompatRenderer.map.lighting) == 0 then return 0 end if
            ds = native.trunc(ds) >> 4
            dt = native.trunc(dt) >> 4
            width = surface.lightWidth
            size = surface.lightWidth * surface.lightHeight
            offset = surface.lightOffset + dt * width + ds
            total = 0
            face = compatFace(surface)
            mapNumber = 0
            while mapNumber < len(face.styles) and mapNumber < 4 and face.styles[mapNumber] != 255
              style = face.styles[mapNumber]
              scaleValue = 256
              if style >= 0 and style < len(d_lightstylevalue) then scaleValue = d_lightstylevalue[style] end if
              if offset + mapNumber * size < len(rCompatRenderer.map.lighting) then
                total = total + rCompatRenderer.map.lighting[offset + mapNumber * size] * scaleValue
              end if
              mapNumber = mapNumber + 1
            end while
            return total >> 8
          end if
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  otherChild = node.child1
  if side == 1 then otherChild = node.child0 end if
  return RecursiveLightPoint(otherChild, middle, finish)
end function

function R_LightPoint(point)
  if rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 255 end if
  if len(rCompatRenderer.map.lighting) == 0 then return 255 end if
  finish = t.Vec3(point.x, point.y, point.z - 2048.0)
  value = RecursiveLightPoint(rCompatRenderer.map.models[0].headNodes[0], point, finish)
  if value < 0 then value = 0 end if
  return value
end function

// -----------------------------------------------------------------------------
// gl_rsurf.c
// -----------------------------------------------------------------------------

function R_TextureAnimation(base)
  if base is void or rCompatRenderer is void then return base end if
  name = base.name
  data = bytes(name)
  if len(data) < 2 or data[0] != 43 then return base end if
  alternate = false
  if currentTextureFrame != 0 then alternate = true end if
  target = native.trunc(rCompatTime * 10.0) % 10
  targetCharacter = 48 + target
  if alternate then targetCharacter = 65 + target end if
  prefix = slice(data, 2, len(data) - 2)
  index = 0
  while index < len(rCompatRenderer.textures)
    texture = rCompatRenderer.textures[index]
    if texture is not void then
      candidate = bytes(texture.name)
      if len(candidate) == len(data) and candidate[0] == 43 and candidate[1] == targetCharacter then
        matches = true
        byteIndex = 0
        while byteIndex < len(prefix)
          if candidate[byteIndex + 2] != prefix[byteIndex] then matches = false; break end if
          byteIndex = byteIndex + 1
        end while
        if matches then return texture end if
      end if
    end if
    index = index + 1
  end while
  return base
end function

currentTextureFrame = 0

function GL_DisableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if rCompatMultiTextureEnabled then gl.disable(gl.GL_TEXTURE_2D) end if
  rCompatMultiTextureEnabled = false
  mtexenabled = false
  return true
end function

function GL_EnableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if not rCompatMultiTextureAvailable then return false end if
  gl.enable(gl.GL_TEXTURE_2D)
  rCompatMultiTextureEnabled = true
  mtexenabled = true
  return true
end function

function R_DrawSequentialPoly(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & c.SURF_DRAWSKY) != 0 then return R_DrawSkyChain([value]) end if
  if (value.flags & c.SURF_DRAWTURB) != 0 then return EmitWaterPolys(value) end if
  drawBaseSurface(rCompatRenderer, value)
  if not rCompatRenderer.fullbright then
    gl.enable(gl.GL_BLEND)
    gl.blendFunc(gl.GL_ZERO, gl.GL_SRC_COLOR)
    gl.depthMask(false)
    drawLightSurface(value)
    gl.depthMask(true)
    gl.disable(gl.GL_BLEND)
  end if
  return true
end function

function DrawGLWaterPoly(poly)
  value = compatSurface(poly)
  if value is void or len(value.vertices) < 3 then return false end if
  GL_DisableMultitexture()
  gl.begin(gl.GL_TRIANGLE_FAN)
  for each vertex in value.vertices
    gl.texcoord2(vertex.s, vertex.t)
    warpedX = vertex.position.x + 8.0 * math.sin(vertex.position.y * 0.05 + rCompatRealtime) * math.sin(vertex.position.z * 0.05 + rCompatRealtime)
    warpedY = vertex.position.y + 8.0 * math.sin(vertex.position.x * 0.05 + rCompatRealtime) * math.sin(vertex.position.z * 0.05 + rCompatRealtime)
    gl.vertex3(warpedX, warpedY, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

function DrawGLWaterPolyLightmap(poly)
  value = compatSurface(poly)
  if value is void or len(value.vertices) < 3 then return false end if
  GL_DisableMultitexture()
  gl.begin(gl.GL_TRIANGLE_FAN)
  for each vertex in value.vertices
    gl.texcoord2(vertex.lightS, vertex.lightT)
    warpedX = vertex.position.x + 8.0 * math.sin(vertex.position.y * 0.05 + rCompatRealtime) * math.sin(vertex.position.z * 0.05 + rCompatRealtime)
    warpedY = vertex.position.y + 8.0 * math.sin(vertex.position.x * 0.05 + rCompatRealtime) * math.sin(vertex.position.z * 0.05 + rCompatRealtime)
    gl.vertex3(warpedX, warpedY, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

function DrawGLPoly(poly)
  value = compatSurface(poly)
  if value is void or len(value.vertices) < 3 then return false end if
  gl.begin(gl.GL_POLYGON)
  for each vertex in value.vertices
    gl.texcoord2(vertex.s, vertex.t)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

function R_BlendLightmaps()
  if rCompatRenderer is void or rCompatRenderer.fullbright then return 0 end if
  gl.depthMask(false)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_ZERO, gl.GL_SRC_COLOR)
  count = 0
  index = 0
  while index < len(rCompatRenderer.surfaces)
    if index < len(rCompatRenderer.visibleFaces) and rCompatRenderer.visibleFaces[index] != 0 then
      surface = rCompatRenderer.surfaces[index]
      if (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | c.SURF_DRAWTILED)) == 0 then
        drawLightSurface(surface)
        count = count + 1
      end if
    end if
    index = index + 1
  end while
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.depthMask(true)
  return count
end function

function R_RenderDynamicLightmaps(surface)
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 or value.lightmapId == 0 then return false end if
  face = compatFace(value)
  changed = false
  mapNumber = 0
  while mapNumber < len(face.styles) and mapNumber < 4 and face.styles[mapNumber] != 255
    style = face.styles[mapNumber]
    current = 256
    if style >= 0 and style < len(d_lightstylevalue) then current = d_lightstylevalue[style] end if
    if rCompatSurfaceCachedLight[index][mapNumber] != current then changed = true end if
    mapNumber = mapNumber + 1
  end while
  if rCompatSurfaceDlightFrame[index] == r_dlightframecount then changed = true end if
  if not changed then return false end if
  pixels = R_BuildLightMap(value, bytes(value.lightWidth * value.lightHeight), value.lightWidth)
  gl.bindTexture(value.lightmapId)
  gl.uploadLuminance(value.lightWidth, value.lightHeight, pixels)
  return true
end function

function R_RenderBrushPoly(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & c.SURF_DRAWSKY) != 0 then return R_DrawSkyChain([value]) end if
  if (value.flags & c.SURF_DRAWTURB) != 0 then
    gl.bindTexture(textureIdForSurface(rCompatRenderer, value))
    return EmitWaterPolys(value)
  end if
  drawBaseSurface(rCompatRenderer, value)
  if rCompatDynamic then R_RenderDynamicLightmaps(value) end if
  return true
end function

function R_MirrorChain(surface)
  global rCompatSkyChain
  // Mirrors are encoded as a texture chain in GLQuake. Keep the chain intact
  // for R_Mirror in the higher-level renderer.
  rCompatSkyChain = rCompatSkyChain + [surface]
  return len(rCompatSkyChain)
end function

function R_DrawWaterSurfaces()
  if rCompatRenderer is void then return 0 end if
  alpha = rCompatRenderer.waterAlpha
  if alpha < 0.0 then alpha = 0.0 end if
  if alpha > 1.0 then alpha = 1.0 end if
  if alpha < 1.0 then
    gl.enable(gl.GL_BLEND)
    gl.color(255, 255, 255, native.trunc(alpha * 255.0))
  end if
  count = 0
  index = 0
  while index < len(rCompatRenderer.surfaces)
    if index < len(rCompatRenderer.visibleFaces) and rCompatRenderer.visibleFaces[index] != 0 then
      surface = rCompatRenderer.surfaces[index]
      if (surface.flags & c.SURF_DRAWTURB) != 0 then
        gl.bindTexture(textureIdForSurface(rCompatRenderer, surface))
        EmitWaterPolys(surface)
        count = count + 1
      end if
    end if
    index = index + 1
  end while
  if alpha < 1.0 then gl.color(255, 255, 255, 255); gl.disable(gl.GL_BLEND) end if
  return count
end function

function DrawTextureChains()
  if rCompatRenderer is void then return 0 end if
  count = 0
  index = 0
  while index < len(rCompatRenderer.surfaces)
    if index < len(rCompatRenderer.visibleFaces) and rCompatRenderer.visibleFaces[index] != 0 then
      surface = rCompatRenderer.surfaces[index]
      if (surface.flags & c.SURF_DRAWTURB) == 0 then
        R_RenderBrushPoly(surface)
        count = count + 1
      end if
    end if
    index = index + 1
  end while
  return count
end function

function R_DrawBrushModel(entity)
  if rCompatRenderer is void or entity is void then return 0 end if
  modelName = ""
  if entity.modelIndex >= 0 and entity.modelIndex < len(rCompatRenderer.map.models) then modelName = "*" + entity.modelIndex end if
  submodelIndex = entity.modelIndex
  if submodelIndex < 1 or submodelIndex >= len(rCompatRenderer.map.models) then return 0 end if
  submodel = rCompatRenderer.map.models[submodelIndex]
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(-entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  faceIndex = submodel.firstFace
  lastFace = faceIndex + submodel.numFaces
  count = 0
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 then R_RenderBrushPoly(rCompatRenderer.surfaces[faceIndex]); count = count + 1 end if
    faceIndex = faceIndex + 1
  end while
  if not rCompatRenderer.fullbright then R_BlendLightmaps() end if
  gl.popMatrix()
  return count
end function

function R_RecursiveWorldNode(nodeNumber)
  if rCompatRenderer is void or nodeNumber < 0 then return 0 end if
  if nodeNumber >= len(rCompatRenderer.map.nodes) then return 0 end if
  node = rCompatRenderer.map.nodes[nodeNumber]
  plane = rCompatRenderer.map.planes[node.planeIndex]
  distance = compatPlaneDistance(plane, rCompatViewOrigin)
  side = 0
  if distance < 0.0 then side = 1 end if
  firstChild = node.child0
  secondChild = node.child1
  if side == 1 then firstChild = node.child1; secondChild = node.child0 end if
  count = R_RecursiveWorldNode(firstChild)
  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 and faceIndex < len(rCompatRenderer.visibleFaces) and rCompatRenderer.visibleFaces[faceIndex] != 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      if (surface.flags & c.SURF_DRAWTURB) == 0 then R_RenderBrushPoly(surface); count = count + 1 end if
    end if
    faceIndex = faceIndex + 1
  end while
  count = count + R_RecursiveWorldNode(secondChild)
  return count
end function

function R_DrawWorld()
  if rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 0 end if
  root = rCompatRenderer.map.models[0].headNodes[0]
  return R_RecursiveWorldNode(root)
end function

function R_MarkLeaves()
  global r_visframecount
  if rCompatRenderer is void then return 0 end if
  r_visframecount = r_visframecount + 1
  if rCompatNoVis then return markAllVisible(rCompatRenderer) end if
  return markVisible(rCompatRenderer, rCompatViewOrigin)
end function

function AllocBlock(width, height, xOut, yOut)
  global rCompatLightmapAllocated, allocated, active_lightmaps
  compatEnsureWorldState()
  textureNumber = 0
  while textureNumber < GLQUAKE_MAX_LIGHTMAPS
    best = GLQUAKE_BLOCK_HEIGHT
    bestX = -1
    bestY = 0
    x = 0
    while x <= GLQUAKE_BLOCK_WIDTH - width
      best2 = 0
      column = 0
      while column < width
        value = rCompatLightmapAllocated[textureNumber][x + column]
        if value >= best then break end if
        if value > best2 then best2 = value end if
        column = column + 1
      end while
      if column == width then bestX = x; bestY = best2; best = best2 end if
      x = x + 1
    end while
    if bestX >= 0 and bestY + height <= GLQUAKE_BLOCK_HEIGHT then
      column = 0
      while column < width
        rCompatLightmapAllocated[textureNumber][bestX + column] = bestY + height
        column = column + 1
      end while
      allocated = rCompatLightmapAllocated
      if xOut is array and len(xOut) > 0 then xOut[0] = bestX end if
      if yOut is array and len(yOut) > 0 then yOut[0] = bestY end if
      if textureNumber + 1 > active_lightmaps then active_lightmaps = textureNumber + 1 end if
      return textureNumber
    end if
    textureNumber = textureNumber + 1
  end while
  return error(3763, "AllocBlock: full")
end function

function BuildSurfaceDisplayList(surface)
  value = compatSurface(surface)
  if value is void then return error(3764, "BuildSurfaceDisplayList: bad surface") end if
  // buildSurface reconstructed the exact edge loop and both texture coordinate
  // sets at model-load time. Remove strictly collinear points as GLQuake does.
  if (value.flags & GLQUAKE_SURF_UNDERWATER) != 0 or len(value.vertices) < 3 then return value end if
  output = arrayutil.createArrayBuilder(len(value.vertices))
  count = len(value.vertices)
  index = 0
  while index < count
    previous = value.vertices[(index + count - 1) % count]
    current = value.vertices[index]
    next = value.vertices[(index + 1) % count]
    direction1 = math.normalize(math.subtract(current.position, previous.position))
    direction2 = math.normalize(math.subtract(next.position, previous.position))
    collinear = compatAbs(direction1.x - direction2.x) <= 0.001 and compatAbs(direction1.y - direction2.y) <= 0.001 and compatAbs(direction1.z - direction2.z) <= 0.001
    if not collinear then arrayutil.pushArrayBuilder(output, current) end if
    index = index + 1
  end while
  vertices = arrayutil.finishArrayBuilder(output)
  if len(vertices) >= 3 then value.vertices = vertices end if
  return value
end function

function GL_CreateSurfaceLightmap(surface)
  value = compatSurface(surface)
  if value is void then return error(3765, "GL_CreateSurfaceLightmap: bad surface") end if
  if (value.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB)) != 0 then return 0 end if
  pixels = R_BuildLightMap(value, bytes(value.lightWidth * value.lightHeight), value.lightWidth)
  if value.lightmapId != 0 then gl.deleteTexture(value.lightmapId) end if
  value.lightmapId = gl.generateTexture()
  gl.bindTexture(value.lightmapId)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
  gl.uploadLuminance(value.lightWidth, value.lightHeight, pixels)
  return value.lightmapId
end function

function GL_BuildLightmaps()
  global r_framecount, lightmap_bytes, active_lightmaps
  if rCompatRenderer is void then return 0 end if
  compatEnsureWorldState()
  r_framecount = 1
  lightmap_bytes = 1
  active_lightmaps = 0
  count = 0
  index = 0
  while index < len(rCompatRenderer.surfaces)
    surface = rCompatRenderer.surfaces[index]
    GL_CreateSurfaceLightmap(surface)
    if (surface.flags & (c.SURF_DRAWTURB | c.SURF_DRAWSKY)) == 0 then BuildSurfaceDisplayList(surface) end if
    count = count + 1
    index = index + 1
  end while
  return count
end function

// -----------------------------------------------------------------------------
// gl_warp.c
// -----------------------------------------------------------------------------

function compatVertexAt(vertices, index)
  value = vertices[index]
  if typeName(value) == "RenderVertex" then return value.position end if
  if typeName(value) == "Vec3" then return value end if
  if value is array and len(value) >= 3 then return t.Vec3(value[0], value[1], value[2]) end if
  return compatZeroVector()
end function

function BoundPoly(numverts, vertices, minimums, maximums)
  if minimums is void then minimums = t.Vec3(9999.0, 9999.0, 9999.0) end if
  if maximums is void then maximums = t.Vec3(-9999.0, -9999.0, -9999.0) end if
  index = 0
  while index < numverts and index < len(vertices)
    vertex = compatVertexAt(vertices, index)
    if vertex.x < minimums.x then minimums.x = vertex.x end if
    if vertex.y < minimums.y then minimums.y = vertex.y end if
    if vertex.z < minimums.z then minimums.z = vertex.z end if
    if vertex.x > maximums.x then maximums.x = vertex.x end if
    if vertex.y > maximums.y then maximums.y = vertex.y end if
    if vertex.z > maximums.z then maximums.z = vertex.z end if
    index = index + 1
  end while
  return [minimums, maximums]
end function

function compatInterpolateRenderVertex(first, second, fraction)
  position = math.add(first.position, math.scale(math.subtract(second.position, first.position), fraction))
  return t.RenderVertex(
    position,
    first.s + (second.s - first.s) * fraction,
    first.t + (second.t - first.t) * fraction,
    first.lightS + (second.lightS - first.lightS) * fraction,
    first.lightT + (second.lightT - first.lightT) * fraction,
  )
end function

function compatSubdivide(vertices, output, size)
  if len(vertices) > 60 then return error(3766, "SubdividePolygon: numverts > 60") end if
  minimums = t.Vec3(9999.0, 9999.0, 9999.0)
  maximums = t.Vec3(-9999.0, -9999.0, -9999.0)
  BoundPoly(len(vertices), vertices, minimums, maximums)
  axis = 0
  while axis < 3
    minimum = minimums.x
    maximum = maximums.x
    if axis == 1 then minimum = minimums.y; maximum = maximums.y end if
    if axis == 2 then minimum = minimums.z; maximum = maximums.z end if
    middle = (minimum + maximum) * 0.5
    middle = size * floorValue(middle / size + 0.5)
    if maximum - middle >= 8.0 and middle - minimum >= 8.0 then
      distances = arrayutil.makeEmptyArray(len(vertices) + 1)
      index = 0
      while index < len(vertices)
        point = vertices[index].position
        coordinate = point.x
        if axis == 1 then coordinate = point.y end if
        if axis == 2 then coordinate = point.z end if
        distances[index] = coordinate - middle
        index = index + 1
      end while
      distances[len(vertices)] = distances[0]
      fronts = arrayutil.createArrayBuilder(len(vertices) + 4)
      backs = arrayutil.createArrayBuilder(len(vertices) + 4)
      index = 0
      while index < len(vertices)
        current = vertices[index]
        next = vertices[(index + 1) % len(vertices)]
        distance = distances[index]
        nextDistance = distances[index + 1]
        if distance >= 0.0 then arrayutil.pushArrayBuilder(fronts, current) end if
        if distance <= 0.0 then arrayutil.pushArrayBuilder(backs, current) end if
        if (distance > 0.0 and nextDistance < 0.0) or (distance < 0.0 and nextDistance > 0.0) then
          fraction = distance / (distance - nextDistance)
          split = compatInterpolateRenderVertex(current, next, fraction)
          arrayutil.pushArrayBuilder(fronts, split)
          arrayutil.pushArrayBuilder(backs, split)
        end if
        index = index + 1
      end while
      frontValues = arrayutil.finishArrayBuilder(fronts)
      backValues = arrayutil.finishArrayBuilder(backs)
      compatSubdivide(frontValues, output, size)
      compatSubdivide(backValues, output, size)
      return true
    end if
    axis = axis + 1
  end while
  arrayutil.pushArrayBuilder(output, vertices)
  return true
end function

function SubdividePolygon(numverts, vertices)
  global rCompatWarpPolys
  source = vertices
  if numverts < len(vertices) then source = arrayutil.copyArrayPrefix(vertices, numverts) end if
  builder = arrayutil.createArrayBuilder(8)
  result = compatSubdivide(source, builder, 128.0)
  if result is error then return result end if
  rCompatWarpPolys = arrayutil.finishArrayBuilder(builder)
  return rCompatWarpPolys
end function

function GL_SubdivideSurface(surface)
  value = compatSurface(surface)
  if value is void then return error(3767, "GL_SubdivideSurface: bad surface") end if
  return SubdividePolygon(len(value.vertices), value.vertices)
end function

function compatTurbulence(value)
  return math.sin(value) * 8.0
end function

function EmitWaterPolys(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  polygons = GL_SubdivideSurface(value)
  if polygons is error then return polygons end if
  for each vertices in polygons
    gl.begin(gl.GL_POLYGON)
    for each vertex in vertices
      originalS = vertex.s * 64.0
      originalT = vertex.t * 64.0
      warpedS = (originalS + compatTurbulence((originalT * 0.125 + rCompatRealtime) * 2.0 * 3.141592653589793 / 256.0)) / 64.0
      warpedT = (originalT + compatTurbulence((originalS * 0.125 + rCompatRealtime) * 2.0 * 3.141592653589793 / 256.0)) / 64.0
      gl.texcoord2(warpedS, warpedT)
      gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
    end for
    gl.finishPrimitive()
  end for
  return len(polygons)
end function

function EmitSkyPolys(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  polygons = GL_SubdivideSurface(value)
  if polygons is error then return polygons end if
  for each vertices in polygons
    gl.begin(gl.GL_POLYGON)
    for each vertex in vertices
      direction = math.subtract(vertex.position, rCompatViewOrigin)
      direction.z = direction.z * 3.0
      lengthValue = math.length(direction)
      if lengthValue < 0.0001 then lengthValue = 1.0 end if
      scaleValue = 378.0 / lengthValue
      sValue = (speedscale + direction.x * scaleValue) / 128.0
      tValue = (speedscale + direction.y * scaleValue) / 128.0
      gl.texcoord2(sValue, tValue)
      gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
    end for
    gl.finishPrimitive()
  end for
  return len(polygons)
end function

function EmitBothSkyLayers(surface)
  global speedscale
  GL_DisableMultitexture()
  if solidskytexture != 0 then gl.bindTexture(solidskytexture) end if
  speedscale = rCompatRealtime * 8.0
  speedscale = speedscale - (native.trunc(speedscale) & -128)
  first = EmitSkyPolys(surface)
  gl.enable(gl.GL_BLEND)
  if alphaskytexture != 0 then gl.bindTexture(alphaskytexture) end if
  speedscale = rCompatRealtime * 16.0
  speedscale = speedscale - (native.trunc(speedscale) & -128)
  second = EmitSkyPolys(surface)
  gl.disable(gl.GL_BLEND)
  return first + second
end function

function R_DrawSkyChain(chain)
  global speedscale
  if chain is void then return 0 end if
  if typeName(chain) == "RenderSurface" then chain = [chain] end if
  GL_DisableMultitexture()
  count = 0
  if solidskytexture != 0 then gl.bindTexture(solidskytexture) end if
  speedscale = rCompatRealtime * 8.0
  speedscale = speedscale - (native.trunc(speedscale) & -128)
  for each surface in chain
    EmitSkyPolys(surface)
    count = count + 1
  end for
  gl.enable(gl.GL_BLEND)
  if alphaskytexture != 0 then gl.bindTexture(alphaskytexture) end if
  speedscale = rCompatRealtime * 16.0
  speedscale = speedscale - (native.trunc(speedscale) & -128)
  for each surface in chain
    EmitSkyPolys(surface)
  end for
  gl.disable(gl.GL_BLEND)
  return count
end function

function R_InitSky(texture)
  global solidskytexture, alphaskytexture, rCompatSkyTexture, rCompatAlphaSkyTexture
  if texture is void or texture.width < 256 or texture.height < 128 or len(texture.pixels) < texture.width * texture.height then
    return error(3768, "R_InitSky: invalid sky texture")
  end if
  if rCompatRenderer is void or len(rCompatRenderer.palette) < 768 then
    return error(3769, "R_InitSky: palette is not initialized")
  end if

  // gl_warp.c:R_InitSky uses a 128x128 RGBA buffer for each half of the
  // 256x128 source texture.  Keep the conversion byte-exact, including the
  // transparent palette entry 255 from d_8to24table.
  solidRgba = bytes(128 * 128 * 4)
  alphaRgba = bytes(128 * 128 * 4)
  red = 0
  green = 0
  blue = 0
  count = 0
  y = 0
  while y < 128
    x = 0
    while x < 128
      source = texture.pixels[y * 256 + x + 128]
      destination = (y * 128 + x) * 4
      solidRgba[destination] = rCompatRenderer.palette[source * 3]
      solidRgba[destination + 1] = rCompatRenderer.palette[source * 3 + 1]
      solidRgba[destination + 2] = rCompatRenderer.palette[source * 3 + 2]
      solidRgba[destination + 3] = 255
      if source == 255 then solidRgba[destination + 3] = 0 end if
      red = red + solidRgba[destination]
      green = green + solidRgba[destination + 1]
      blue = blue + solidRgba[destination + 2]
      count = count + 1
      x = x + 1
    end while
    y = y + 1
  end while

  // C performs integer division here. MiniLang '/' may produce a float when
  // the quotient is not exact, so explicitly reproduce C's truncation before
  // assigning the result to a byte buffer.
  averageRed = native.trunc(red / count)
  averageGreen = native.trunc(green / count)
  averageBlue = native.trunc(blue / count)

  y = 0
  while y < 128
    x = 0
    while x < 128
      source = texture.pixels[y * 256 + x]
      destination = (y * 128 + x) * 4
      if source == 0 then
        alphaRgba[destination] = averageRed
        alphaRgba[destination + 1] = averageGreen
        alphaRgba[destination + 2] = averageBlue
        alphaRgba[destination + 3] = 0
      else
        alphaRgba[destination] = rCompatRenderer.palette[source * 3]
        alphaRgba[destination + 1] = rCompatRenderer.palette[source * 3 + 1]
        alphaRgba[destination + 2] = rCompatRenderer.palette[source * 3 + 2]
        alphaRgba[destination + 3] = 255
        if source == 255 then alphaRgba[destination + 3] = 0 end if
      end if
      x = x + 1
    end while
    y = y + 1
  end while

  // Match GLQuake: allocate each texture once, reuse it on later maps, use
  // internal formats 3/4, and force linear filtering for both sky layers.
  if solidskytexture == 0 then solidskytexture = gl.generateTexture() end if
  gl.bindTexture(solidskytexture)
  native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 3, 128, 128, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, solidRgba)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)

  if alphaskytexture == 0 then alphaskytexture = gl.generateTexture() end if
  gl.bindTexture(alphaskytexture)
  native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 4, 128, 128, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, alphaRgba)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)

  rCompatSkyTexture = solidskytexture
  rCompatAlphaSkyTexture = alphaskytexture
  return [solidskytexture, alphaskytexture]
end function

// Internal package-state adapters used by gl_rmain.c/gl_rmisc.c compatibility.
function R_AdvanceFrameCounters()
  global r_framecount
  r_framecount = r_framecount + 1
  return r_framecount
end function

function R_ResetLightStyles(value)
  global d_lightstylevalue
  if len(d_lightstylevalue) != c.MAX_LIGHTSTYLES then d_lightstylevalue = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, value) end if
  index = 0
  while index < len(d_lightstylevalue)
    d_lightstylevalue[index] = value
    index = index + 1
  end while
  return d_lightstylevalue
end function
