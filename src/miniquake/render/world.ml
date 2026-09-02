/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.world.
*/
package miniquake.render.world

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.render.gl11 as gl
import miniquake.render.enhanced as enhanced
import miniquake.optimization_baseline as optBaseline
import miniquake.render.draw2d as draw2d
import miniquake.render.gl_warp as glWarp
import miniquake.render.gl_rlight as glRlight
import miniquake.render.ray_shadow as rayShadow
import miniquake.render.special_paths as specialPaths
import miniquake.render.colored_lightmaps as coloredLightmaps
import miniquake.world_bsp as world
import miniquake.format.bsp as bsp
import miniquake.array_util as arrayutil
import miniquake.byteio as byteio

// The generated collector scans package globals directly.  Keep the active
// surface graph in such a root because reaching it only through
// GameSession -> WorldRenderer -> surfaces is not reliable across allocations
// performed while the entity renderer is built.
worldSurfaceRoots = []
/// Tracks the module-level clear static cache on create state owned by `miniquake.render.world`.
clearStaticCacheOnCreate = true
/// Tracks the module-level visible face count renderer state owned by `miniquake.render.world`.
visibleFaceCountRenderer = void
/// Tracks the module-level visible face count leaf state owned by `miniquake.render.world`.
visibleFaceCountLeaf = -2
/// Tracks the module-level visible face count value state owned by `miniquake.render.world`.
visibleFaceCountValue = 0
// R_RecursiveWorldNode must not visit BSP branches which contain no PVS
// surfaces.  GLQuake stores this as node->visframe; MiniQuake keeps the same
// derived state in a renderer-local byte mask so an unchanged view leaf does
// not force a complete BSP walk on every displayed frame.
rCompatVisibleNodeRenderer = void
/// Tracks the module-level r compat visible nodes state owned by `miniquake.render.world`.
rCompatVisibleNodes = bytes()

/// Starts s with for `miniquake.render.world`.
/// @param text Text to parse or process.
/// @param prefix The prefix input consumed by `startsWith`.
function startsWith(text, prefix)
  textBytes = bytes(text)
  prefixBytes = bytes(prefix)
  if len(prefixBytes) > len(textBytes) then return false end if
  index = 0
  while index < len(prefixBytes)
    if textBytes[index] != prefixBytes[index] then return false end if
    index = index + 1
  end while
  return true
end function

/// Implements the `floorValue` operation for `miniquake.render.world` (floor value).
/// @param value Value consumed by `floorValue`.
function floorValue(value)
  truncated = native.trunc(value)
  if truncated > value then truncated = truncated - 1 end if
  return truncated
end function

/// Return ceil value derived from the active module state.
/// @param value Value consumed by `ceilValue`.
function ceilValue(value)
  truncated = native.trunc(value)
  if truncated < value then truncated = truncated + 1 end if
  return truncated
end function

/// Implements the `faceVertex` operation for `miniquake.render.world` (face vertex).
/// @param map The map input consumed by `faceVertex`.
/// @param face The face input consumed by `faceVertex`.
/// @param edgeNumber The edge number input consumed by `faceVertex`.
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

/// Implements the `indexedToRgba` operation for `miniquake.render.world` (indexed to rgba).
/// @param indexed The indexed input consumed by `indexedToRgba`.
/// @param palette The palette input consumed by `indexedToRgba`.
/// @param transparent The transparent input consumed by `indexedToRgba`.
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

/// Implements the `missingTexturePixels` operation for `miniquake.render.world` (missing texture pixels).
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

/// Upload pixels to the active renderer.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param rgba The rgba input consumed by `uploadPixels`.
/// @param nearest The nearest input consumed by `uploadPixels`.
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

/// Implements the `textureFlags` operation for `miniquake.render.world` (texture flags).
/// @param textureName Name that identifies the requested value or resource.
/// @param faceSide The face side input consumed by `textureFlags`.
function textureFlags(textureName, faceSide)
  flags = 0
  if faceSide != 0 then flags = flags | c.SURF_PLANEBACK end if
  if startsWith(textureName, "sky") then flags = flags | c.SURF_DRAWSKY | c.SURF_DRAWTILED end if
  if startsWith(textureName, "*") then flags = flags | c.SURF_DRAWTURB | c.SURF_DRAWTILED end if
  return flags
end function

/// Create and initialize underwater flags.
/// @param map The map input consumed by `buildUnderwaterFlags`.
function buildUnderwaterFlags(map)
  flags = bytes(len(map.faces), 0)
  leafIndex = 0
  while leafIndex < len(map.leafs)
    leaf = map.leafs[leafIndex]
    if leaf.contents != c.CONTENTS_EMPTY then
      mark = 0
      while mark < leaf.numMarkSurfaces
        markIndex = leaf.firstMarkSurface + mark
        if markIndex >= 0 and markIndex < len(map.markSurfaces) then
          faceIndex = map.markSurfaces[markIndex]
          if faceIndex >= 0 and faceIndex < len(flags) then flags[faceIndex] = 1 end if
        end if
        mark = mark + 1
      end while
    end if
    leafIndex = leafIndex + 1
  end while
  return flags
end function

/// Create and initialize surface.
/// @param map The map input consumed by `buildSurface`.
/// @param faceIndex Zero-based index of the requested entry.
/// @param underwaterFlags The underwater flags input consumed by `buildSurface`.
function buildSurface(map, faceIndex, underwaterFlags)
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
  // Keep the temporary edge loop homogeneous.  A heterogeneous
  // [Vec3, float, float] array forced boxed floats to share storage with
  // structs; on large retail BSPs the MiniLang backend could subsequently
  // recover the Vec3 tag for one of those float slots.  Texture coordinates
  // are cheap to recompute once the surface bounds are known.
  positions = arrayutil.makeEmptyArray(face.numEdges)
  edgeNumber = 0
  while edgeNumber < face.numEdges
    position = faceVertex(map, face, edgeNumber)
    rawS = position.x * info.s[0] + position.y * info.s[1] + position.z * info.s[2] + info.s[3]
    rawT = position.x * info.t[0] + position.y * info.t[1] + position.z * info.t[2] + info.t[3]
    if rawS < minimumS then minimumS = rawS end if
    if rawS > maximumS then maximumS = rawS end if
    if rawT < minimumT then minimumT = rawT end if
    if rawT > maximumT then maximumT = rawT end if
    positions[edgeNumber] = math.copy(position)
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
    position = positions[vertexNumber]
    rawS = position.x * info.s[0] + position.y * info.s[1] + position.z * info.s[2] + info.s[3]
    rawT = position.x * info.t[0] + position.y * info.t[1] + position.z * info.t[2] + info.t[3]
    textureS = rawS / textureWidth
    textureT = rawT / textureHeight
    lightS = (rawS - textureMinS + 8.0) / (lightWidth * 16.0)
    lightT = (rawT - textureMinT + 8.0) / (lightHeight * 16.0)
    // Construct first and assign boxed coordinates through rooted locals.  A
    // five-argument constructor containing both a struct reference and boxed
    // floats can lose one argument when allocation happens while evaluating
    // the remaining arguments in the current backend.
    renderVertex = t.RenderVertex(position, 0.0, 0.0, 0.0, 0.0)
    renderVertex.s = textureS
    renderVertex.t = textureT
    renderVertex.lightS = lightS
    renderVertex.lightT = lightT
    vertices[vertexNumber] = renderVertex
    vertexNumber = vertexNumber + 1
  end while

  flags = textureFlags(textureName, face.side)
  if (info.flags & c.TEX_SPECIAL) != 0 then flags = flags | c.SURF_DRAWTILED end if
  if faceIndex < len(underwaterFlags) and underwaterFlags[faceIndex] != 0 then flags = flags | c.SURF_UNDERWATER end if
  // Allocate the container before attaching its heap-backed vectors and
  // vertex array.  This mirrors the rooted construction used by QuakeEdict:
  // evaluating several heap arguments around a struct allocation can lose an
  // earlier argument in the current MiniLang shadow-stack backend.
  surface = t.RenderSurface(0, 0, void, void, 0, 0, 0, 0, void, 0)
  surface.faceIndex = faceIndex
  surface.textureIndex = textureIndex
  surface.textureMins = t.Vec3(textureMinS, textureMinT, 0.0)
  surface.extents = t.Vec3(extentS, extentT, 0.0)
  surface.lightWidth = lightWidth
  surface.lightHeight = lightHeight
  surface.lightOffset = face.lightOffset
  surface.flags = flags
  surface.vertices = vertices
  surface.lightmapId = 0
  return surface
end function

/// Create and initialize lightmap.
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `buildLightmap`.
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

/// Implements the `create` operation for `miniquake.render.world` (create).
/// @param map The map input consumed by `create`.
/// @param palette The palette input consumed by `create`.
function create(map, palette)
  global worldSurfaceRoots
  if len(palette) < 768 then return error(2706, "R_NewMap: invalid palette") end if
  if clearStaticCacheOnCreate then gl.clearStaticGeometryCache() end if
  textures = arrayutil.makeEmptyArray(len(map.textures))
  textureIndex = 0
  while textureIndex < len(map.textures)
    sourceTexture = map.textures[textureIndex]
    // makeEmptyArray already contains void.  Reassigning void through an
    // array index is invalid under strict MiniLang void handling and caused
    // e1m2 to abort for an intentionally empty BSP texture slot.
    if sourceTexture is not void then
      transparent = startsWith(sourceTexture.name, "{")
      textures[textureIndex] = t.RenderTexture(sourceTexture.name, sourceTexture.width, sourceTexture.height, 0, sourceTexture.pixels, transparent)
    end if
    textureIndex = textureIndex + 1
  end while
  underwaterFlags = buildUnderwaterFlags(map)
  surfaces = arrayutil.makeEmptyArray(len(map.faces))
  worldSurfaceRoots = surfaces
  faceIndex = 0
  while faceIndex < len(map.faces)
    builtSurface = buildSurface(map, faceIndex, underwaterFlags)
    if builtSurface is error then return builtSurface end if
    checkVertex = 0
    while checkVertex < len(builtSurface.vertices)
      if typeof(builtSurface.vertices[checkVertex]) != "struct" then
        return error(3929, "buildSurface " + faceIndex + " vertex " + checkVertex + " is " + typeof(builtSurface.vertices[checkVertex]))
      end if
      checkVertex = checkVertex + 1
    end while
    surfaces[faceIndex] = builtSurface
    faceIndex = faceIndex + 1
  end while
  visible = bytes(len(map.faces), 1)
  renderer = t.WorldRenderer(void, void, void, void, void, false, 0, false, false, -1, void, 0, 1.0)
  renderer.map = map
  renderer.palette = palette
  renderer.textures = textures
  renderer.surfaces = surfaces
  renderer.lightmaps = []
  renderer.uploaded = false
  renderer.noTextureId = 0
  renderer.fullbright = false
  renderer.wireframe = false
  renderer.viewLeaf = -1
  renderer.visibleFaces = visible
  renderer.frameCount = 0
  renderer.waterAlpha = 1.0
  return renderer
end function

/// Create and initialize external.
/// @param map The map input consumed by `createExternal`.
/// @param palette The palette input consumed by `createExternal`.
function createExternal(map, palette)
  global worldSurfaceRoots, clearStaticCacheOnCreate
  // External BSP pickups use the same surface builder but do not replace the
  // active world's collector root. EntityRenderer keeps their surface arrays
  // in its own direct package root until the level is destroyed.
  activeWorldRoots = worldSurfaceRoots
  previousClear = clearStaticCacheOnCreate
  clearStaticCacheOnCreate = false
  renderer = create(map, palette)
  clearStaticCacheOnCreate = previousClear
  worldSurfaceRoots = activeWorldRoots
  return renderer
end function

/// Upload the requested value to the active renderer.
/// @param renderer Renderer instance or backend used for drawing.
function upload(renderer)
  if renderer.uploaded then return renderer end if
  draw2d.Draw_SetPalette(renderer.palette)
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
        texture.glId = draw2d.GL_LoadTexture(
          texture.name,
          texture.width,
          texture.height,
          texture.pixels,
          true,
          texture.transparent,
        )
      end if
    end if
    index = index + 1
  end while

  zero = t.Vec3(0.0, 0.0, 0.0)
  configured = try(R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0, true, true, false,
  ))
  if configured is error then return error(3904, "upload_configure: " + configured.message) end if
  lightmapsBuilt = try(GL_BuildLightmaps())
  if lightmapsBuilt is error then return error(3905, "upload_lightmaps: " + lightmapsBuilt.message) end if
  staticGeometryBuilt = try(precacheStaticGeometry(renderer))
  if staticGeometryBuilt is error then return error(3932, "upload_static_geometry: " + staticGeometryBuilt.message) end if
  index = 0
  while index < len(renderer.textures)
    texture = renderer.textures[index]
    if texture is not void and startsWith(texture.name, "sky") then
      skyInitialized = try(R_InitSky(texture))
      if skyInitialized is error then return error(3906, "upload_sky: " + skyInitialized.message) end if
    end if
    index = index + 1
  end while
  renderer.uploaded = true
  return renderer
end function

/// External BSP models such as maps/b_bh25.bsp are independent brush models,
/// not *n submodels of the active world. GLQuake includes all of them in
/// GL_BuildLightmaps. Keep their uploads independent from the world's shared
/// atlas so loading one cannot replace the active world's compatibility state.
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `buildStandaloneLightmap`.
function buildStandaloneLightmap(renderer, surface)
  // Build dependent state in order so later fields reference fully initialized data.
  if (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | c.SURF_DRAWTILED)) != 0 then return 0 end if
  count = surface.lightWidth * surface.lightHeight
  if count <= 0 then return 0 end if
  accumulated = arrayutil.makeFilledArray(count, 0)
  fullbright = renderer.fullbright or len(renderer.map.lighting) == 0 or surface.lightOffset < 0
  if fullbright then
    index = 0
    while index < count
      accumulated[index] = 255 * 256
      index = index + 1
    end while
  else
    face = renderer.map.faces[surface.faceIndex]
    mapNumber = 0
    while mapNumber < len(face.styles) and mapNumber < 4 and face.styles[mapNumber] != 255
      sourceOffset = surface.lightOffset + mapNumber * count
      index = 0
      while index < count and sourceOffset + index < len(renderer.map.lighting)
        accumulated[index] = accumulated[index] + renderer.map.lighting[sourceOffset + index] * 256
        index = index + 1
      end while
      mapNumber = mapNumber + 1
    end while
  end if
  pixels = bytes(count)
  index = 0
  while index < count
    lightValue = accumulated[index] >> 7
    if lightValue > 255 then lightValue = 255 end if
    pixels[index] = 255 - lightValue
    index = index + 1
  end while
  textureId = gl.generateTexture()
  gl.bindTexture(textureId)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
  gl.uploadLuminance(surface.lightWidth, surface.lightHeight, pixels)
  return textureId
end function

/// Upload standalone brush to the active renderer.
/// @param renderer Renderer instance or backend used for drawing.
function uploadStandaloneBrush(renderer)
  if renderer.uploaded then return renderer end if
  draw2d.Draw_SetPalette(renderer.palette)
  renderer.noTextureId = uploadPixels(16, 16, missingTexturePixels(), true)
  index = 0
  while index < len(renderer.textures)
    texture = renderer.textures[index]
    if texture is not void and texture.width > 0 and texture.height > 0 and len(texture.pixels) >= texture.width * texture.height then
      uploaded = try(draw2d.GL_LoadTexture(
        renderer.map.filename + ":" + texture.name,
        texture.width,
        texture.height,
        texture.pixels,
        true,
        texture.transparent,
      ))
      if uploaded is error then return uploaded end if
      texture.glId = uploaded
    end if
    index = index + 1
  end while
  renderer.lightmaps = []
  index = 0
  while index < len(renderer.surfaces)
    textureId = try(buildStandaloneLightmap(renderer, renderer.surfaces[index]))
    if textureId is error then return textureId end if
    renderer.surfaces[index].lightmapId = textureId
    if textureId != 0 then renderer.lightmaps = renderer.lightmaps + [textureId] end if
    index = index + 1
  end while
  renderer.uploaded = true
  return renderer
end function

/// Implements the `standaloneTextureId` operation for `miniquake.render.world` (standalone texture id).
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `standaloneTextureId`.
/// @param currentTime Time value used by the operation.
/// @param alternate The alternate input consumed by `standaloneTextureId`.
function standaloneTextureId(renderer, surface, currentTime, alternate)
  if surface.textureIndex >= 0 and surface.textureIndex < len(renderer.textures) then
    texture = renderer.textures[surface.textureIndex]
    if texture is not void then
      target = bsp.textureAnimationIndex(renderer.map.textures, surface.textureIndex, currentTime, alternate)
      if not (target is error) and target >= 0 and target < len(renderer.textures) then
        animated = renderer.textures[target]
        if animated is not void and animated.glId != 0 then return animated.glId end if
      end if
      if texture.glId != 0 then return texture.glId end if
    end if
  end if
  return renderer.noTextureId
end function

/// Return standalone model origin derived from the active module state.
/// @param viewOrigin The view origin input consumed by `standaloneModelOrigin`.
/// @param entity Entity affected by the operation.
function standaloneModelOrigin(viewOrigin, entity)
  result = math.subtract(viewOrigin, entity.origin)
  if entity.angles.x == 0.0 and entity.angles.y == 0.0 and entity.angles.z == 0.0 then return result end if
  vectors = math.angleVectors(entity.angles)
  return t.Vec3(
    math.dot(result, vectors[0]),
    -math.dot(result, vectors[1]),
    math.dot(result, vectors[2]),
  )
end function

/// Implements the `standaloneSurfaceFacesViewer` operation for `miniquake.render.world` (standalone surface faces viewer).
/// @param surface The surface input consumed by `standaloneSurfaceFacesViewer`.
/// @param distance The distance input consumed by `standaloneSurfaceFacesViewer`.
function standaloneSurfaceFacesViewer(surface, distance)
  if (surface.flags & c.SURF_PLANEBACK) != 0 then return distance < -GLQUAKE_BACKFACE_EPSILON end if
  return distance > GLQUAKE_BACKFACE_EPSILON
end function

/// Render standalone base.
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `drawStandaloneBase`.
/// @param currentTime Time value used by the operation.
/// @param alternate The alternate input consumed by `drawStandaloneBase`.
function drawStandaloneBase(renderer, surface, currentTime, alternate)
  if len(surface.vertices) < 3 then return false end if
  gl.bindTexture(standaloneTextureId(renderer, surface, currentTime, alternate))
  transparent = false
  if surface.textureIndex >= 0 and surface.textureIndex < len(renderer.textures) and renderer.textures[surface.textureIndex] is not void then
    transparent = renderer.textures[surface.textureIndex].transparent
  end if
  if transparent then gl.enable(gl.GL_ALPHA_TEST); gl.alphaFunc(gl.GL_GREATER, 0.5) end if
  gl.color(255, 255, 255, 255)
  gl.begin(gl.GL_POLYGON)
  for each vertex in surface.vertices
    gl.texcoord2(vertex.s, vertex.t)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  if transparent then gl.disable(gl.GL_ALPHA_TEST) end if
  return true
end function

/// Render standalone light.
/// @param surface The surface input consumed by `drawStandaloneLight`.
function drawStandaloneLight(surface)
  if surface.lightmapId == 0 or len(surface.vertices) < 3 then return false end if
  gl.bindTexture(surface.lightmapId)
  gl.begin(gl.GL_POLYGON)
  for each vertex in surface.vertices
    gl.texcoord2(vertex.lightS, vertex.lightT)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

/// Render standalone brush.
/// @param renderer Renderer instance or backend used for drawing.
/// @param entity Entity affected by the operation.
/// @param viewOrigin The view origin input consumed by `drawStandaloneBrush`.
/// @param currentTime Time value used by the operation.
function drawStandaloneBrush(renderer, entity, viewOrigin, currentTime)
  if renderer is void or entity is void or viewOrigin is void or len(renderer.map.models) == 0 then return 0 end if
  uploaded = try(uploadStandaloneBrush(renderer))
  if uploaded is error then return uploaded end if
  GL_DisableMultitexture()
  model = renderer.map.models[0]
  modelOrigin = standaloneModelOrigin(viewOrigin, entity)
  visibleCount = 0
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  faceIndex = model.firstFace
  lastFace = faceIndex + model.numFaces
  while faceIndex < lastFace and faceIndex < len(renderer.surfaces)
    if faceIndex >= 0 then
      surface = renderer.surfaces[faceIndex]
      face = renderer.map.faces[surface.faceIndex]
      if face.planeIndex >= 0 and face.planeIndex < len(renderer.map.planes) then
        plane = renderer.map.planes[face.planeIndex]
        distance = math.dot(modelOrigin, plane.normal) - plane.dist
        if standaloneSurfaceFacesViewer(surface, distance) then
          drawStandaloneBase(renderer, surface, currentTime, entity.frame != 0)
          visibleCount = visibleCount + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  if visibleCount > 0 and not renderer.fullbright then
    gl.depthMask(false)
    gl.enable(gl.GL_BLEND)
    gl.blendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_COLOR)
    // Repeat the cheap plane test instead of allocating a visible-surface
    // array for every pickup on every frame.
    faceIndex = model.firstFace
    while faceIndex < lastFace and faceIndex < len(renderer.surfaces)
      if faceIndex >= 0 then
        surface = renderer.surfaces[faceIndex]
        face = renderer.map.faces[surface.faceIndex]
        if face.planeIndex >= 0 and face.planeIndex < len(renderer.map.planes) then
          plane = renderer.map.planes[face.planeIndex]
          distance = math.dot(modelOrigin, plane.normal) - plane.dist
          if standaloneSurfaceFacesViewer(surface, distance) then drawStandaloneLight(surface) end if
        end if
      end if
      faceIndex = faceIndex + 1
    end while
    gl.disable(gl.GL_BLEND)
    // R_BlendLightmaps restores GLQuake's conventional alpha blend factors
    // after its multiplicative lightmap pass. External BSP pickups use an
    // independent lightmap path, but subsequent dlight/polyblend rendering
    // shares the same fixed-function state and requires the same restoration.
    gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
    gl.depthMask(true)
  end if
  gl.popMatrix()
  return visibleCount
end function

/// Draw only the base polygons of an external BSP entity for the additive
/// per-pixel light pass.  The caller owns blend/depth/shader state.
/// @param renderer Renderer instance or backend used for drawing.
/// @param entity Entity affected by the operation.
/// @param viewOrigin The view origin input consumed by `drawStandaloneBrushEnhanced`.
/// @param currentTime Time value used by the operation.
function drawStandaloneBrushEnhanced(renderer, entity, viewOrigin, currentTime)
  if renderer is void or entity is void or viewOrigin is void or len(renderer.map.models) == 0 then return 0 end if
  uploaded = try(uploadStandaloneBrush(renderer))
  if uploaded is error then return uploaded end if
  model = renderer.map.models[0]
  modelOrigin = standaloneModelOrigin(viewOrigin, entity)
  visibleCount = 0
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  faceIndex = model.firstFace
  lastFace = faceIndex + model.numFaces
  while faceIndex < lastFace and faceIndex < len(renderer.surfaces)
    if faceIndex >= 0 then
      surface = renderer.surfaces[faceIndex]
      face = renderer.map.faces[surface.faceIndex]
      if face.planeIndex >= 0 and face.planeIndex < len(renderer.map.planes) then
        plane = renderer.map.planes[face.planeIndex]
        distance = math.dot(modelOrigin, plane.normal) - plane.dist
        if standaloneSurfaceFacesViewer(surface, distance) and (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB)) == 0 then
          drawStandaloneBase(renderer, surface, currentTime, entity.frame != 0)
          visibleCount = visibleCount + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  gl.popMatrix()
  return visibleCount
end function

/// Ray-project every polygon of an external BSP object onto the first visible
/// main-world receiver. The legacy floor/contact parameters remain in the ABI;
/// receiver selection now comes exclusively from the configured BSP ray caster.
/// @param renderer Renderer instance or backend used for drawing.
/// @param entity Entity affected by the operation.
/// @param floorWorldZ The floor world z input consumed by `drawStandaloneBrushShadow`.
/// @param offsetX The offset x input consumed by `drawStandaloneBrushShadow`.
/// @param offsetY The offset y input consumed by `drawStandaloneBrushShadow`.
/// @param contactOnly The contact only input consumed by `drawStandaloneBrushShadow`.
/// @param pointLightActive The point light active input consumed by `drawStandaloneBrushShadow`.
/// @param lightX The light x input consumed by `drawStandaloneBrushShadow`.
/// @param lightY The light y input consumed by `drawStandaloneBrushShadow`.
/// @param lightZ The light z input consumed by `drawStandaloneBrushShadow`.
function drawStandaloneBrushShadow(renderer, entity, floorWorldZ, offsetX, offsetY, contactOnly, pointLightActive, lightX, lightY, lightZ)
  if renderer is void or entity is void or len(renderer.map.models) == 0 or not rayShadow.isReady() then return 0 end if
  // Project each convex source face, then triangulate only receiver-compatible
  // fans so one bad ray cannot pull the remaining polygon through a corner.
  model = renderer.map.models[0]
  rayShadow.beginProjectionSample(offsetX, offsetY)
  drawn = 0
  gl.pushMatrix()
  faceIndex = model.firstFace
  lastFace = faceIndex + model.numFaces
  while faceIndex < lastFace and faceIndex < len(renderer.surfaces)
    if faceIndex >= 0 then
      surface = renderer.surfaces[faceIndex]
      if surface is not void and len(surface.vertices) >= 3 then
        rayShadow.beginPrimitive()
        rayShadow.projectBrushVertices(surface.vertices)
        valid = true
        vertexIndex = 0
        for each vertex in surface.vertices
          if not rayShadow.projectedPointValid(vertexIndex) then valid = false end if
          vertexIndex = vertexIndex + 1
        end for
        gl.begin(gl.GL_TRIANGLES)
        triangleIndex = 1
        while valid and triangleIndex + 1 < len(surface.vertices)
          if rayShadow.receiverTriangleCompatible(0, triangleIndex, triangleIndex + 1) then
            gl.vertex3(rayShadow.projectedPointX(0), rayShadow.projectedPointY(0), rayShadow.projectedPointZ(0))
            gl.vertex3(rayShadow.projectedPointX(triangleIndex), rayShadow.projectedPointY(triangleIndex), rayShadow.projectedPointZ(triangleIndex))
            gl.vertex3(rayShadow.projectedPointX(triangleIndex + 1), rayShadow.projectedPointY(triangleIndex + 1), rayShadow.projectedPointZ(triangleIndex + 1))
            drawn = drawn + 1
          end if
          triangleIndex = triangleIndex + 1
        end while
        gl.finishPrimitive()
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  gl.popMatrix()
  return drawn
end function

/// Release resources owned by standalone brush.
/// @param renderer Renderer instance or backend used for drawing.
function destroyStandaloneBrush(renderer)
  if renderer is void then return false end if
  if renderer.noTextureId != 0 then gl.deleteTexture(renderer.noTextureId); renderer.noTextureId = 0 end if
  for each texture in renderer.textures
    if texture is not void and texture.glId != 0 then gl.deleteTexture(texture.glId); texture.glId = 0 end if
  end for
  for each textureId in renderer.lightmaps
    if textureId != 0 then gl.deleteTexture(textureId) end if
  end for
  renderer.lightmaps = []
  for each surface in renderer.surfaces
    surface.lightmapId = 0
  end for
  renderer.uploaded = false
  return true
end function

/// Implements the `destroy` operation for `miniquake.render.world` (destroy).
/// @param renderer Renderer instance or backend used for drawing.
function destroy(renderer)
  global worldSurfaceRoots, visibleFaceCountRenderer, visibleFaceCountLeaf, visibleFaceCountValue
  if renderer is void then return false end if
  gl.clearStaticGeometryCache()
  if renderer.noTextureId != 0 then gl.deleteTexture(renderer.noTextureId); renderer.noTextureId = 0 end if
  for each texture in renderer.textures
    if texture is not void and texture.glId != 0 then gl.deleteTexture(texture.glId); texture.glId = 0 end if
  end for
  // Atlas pages are shared by many surfaces. Delete each OpenGL texture once,
  // not once per surface.
  for each textureId in R_CollectLightmapTextureIds(renderer)
    gl.deleteTexture(textureId)
  end for
  renderer.lightmaps = []
  for each surface in renderer.surfaces
    surface.lightmapId = 0
  end for
  renderer.uploaded = false
  worldSurfaceRoots = []
  if visibleFaceCountRenderer == renderer then
    visibleFaceCountRenderer = void
    visibleFaceCountLeaf = -2
    visibleFaceCountValue = 0
  end if
  if rCompatRenderer == renderer then R_ResetWorldCompatibility() end if
  return true
end function

/// Implements the `compatContainsInteger` operation for `miniquake.render.world` (compat contains integer).
/// @param values The values input consumed by `compatContainsInteger`.
/// @param wanted The wanted input consumed by `compatContainsInteger`.
function compatContainsInteger(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

/// Apply the Quake-compatible r collect lightmap texture ids behavior.
/// @param renderer Renderer instance or backend used for drawing.
function R_CollectLightmapTextureIds(renderer)
  if renderer is void then return [] end if
  result = []
  for each textureId in renderer.lightmaps
    if textureId != 0 and not compatContainsInteger(result, textureId) then result = result + [textureId] end if
  end for
  for each surface in renderer.surfaces
    if surface.lightmapId != 0 and not compatContainsInteger(result, surface.lightmapId) then result = result + [surface.lightmapId] end if
  end for
  return result
end function

/// Report whether mark all visible holds for the active state.
/// @param renderer Renderer instance or backend used for drawing.
function markAllVisible(renderer)
  global visibleFaceCountRenderer, visibleFaceCountLeaf, visibleFaceCountValue
  global rCompatVisibleNodeRenderer, rCompatVisibleNodes
  renderer.visibleFaces = bytes(len(renderer.map.faces), 1)
  rCompatVisibleNodeRenderer = renderer
  rCompatVisibleNodes = bytes(len(renderer.map.nodes), 1)
  // Invalidate the cached leaf so returning from r_novis recomputes the PVS.
  renderer.viewLeaf = -1
  visibleFaceCountRenderer = renderer
  visibleFaceCountLeaf = -1
  visibleFaceCountValue = len(renderer.map.faces)
  return visibleFaceCountValue
end function

/// Mark the exact node path to each PVS-visible leaf.  GLQuake propagates
/// node->visframe from visible leaves rather than from faces: a leaf with no
/// marksurfaces may still contain efrags/static entities and must keep every
/// ancestor visible.  The temporary value two guards malformed cyclic data.
/// @param map The map input consumed by `markVisibleNodeSubtree`.
/// @param visibility The visibility input consumed by `markVisibleNodeSubtree`.
/// @param currentLeaf The current leaf input consumed by `markVisibleNodeSubtree`.
/// @param rowBytes Byte data consumed by the operation.
/// @param visibleNodes The visible nodes input consumed by `markVisibleNodeSubtree`.
/// @param nodeNumber The node number input consumed by `markVisibleNodeSubtree`.
function markVisibleNodeSubtree(map, visibility, currentLeaf, rowBytes, visibleNodes, nodeNumber)
  if nodeNumber < 0 then
    leafIndex = -1 - nodeNumber
    if leafIndex < 0 or leafIndex >= len(map.leafs) then return false end if
    if leafIndex == currentLeaf then return true end if
    bitIndex = leafIndex - 1
    if bitIndex < 0 or bitIndex >= rowBytes * 8 then return false end if
    return (visibility[bitIndex >> 3] & (1 << (bitIndex & 7))) != 0
  end if
  if nodeNumber >= len(map.nodes) then return false end if
  if visibleNodes[nodeNumber] == 2 then return false end if
  visibleNodes[nodeNumber] = 2
  node = map.nodes[nodeNumber]
  visible = markVisibleNodeSubtree(map, visibility, currentLeaf, rowBytes, visibleNodes, node.child0)
  if markVisibleNodeSubtree(map, visibility, currentLeaf, rowBytes, visibleNodes, node.child1) then visible = true end if
  if visible then visibleNodes[nodeNumber] = 1 else visibleNodes[nodeNumber] = 0 end if
  return visible
end function

/// Rebuild the GLQuake-compatible node visibility mask only when the PVS face
/// mask changes.  This moves the complete tree scan from every render frame to
/// the much rarer event of entering a different BSP leaf.
/// @param renderer Renderer instance or backend used for drawing.
function rebuildVisibleNodes(renderer)
  global rCompatVisibleNodeRenderer, rCompatVisibleNodes
  if renderer is void or renderer.map is void then return false end if
  nodeCount = len(renderer.map.nodes)
  if len(rCompatVisibleNodes) != nodeCount then
    rCompatVisibleNodes = bytes(nodeCount, 0)
  else
    index = 0
    while index < nodeCount
      rCompatVisibleNodes[index] = 0
      index = index + 1
    end while
  end if
  rCompatVisibleNodeRenderer = renderer
  if nodeCount == 0 or len(renderer.map.models) == 0 or len(renderer.map.models[0].headNodes) == 0 then return true end if
  if renderer.viewLeaf < 0 then
    index = 0
    while index < nodeCount
      rCompatVisibleNodes[index] = 1
      index = index + 1
    end while
    return true
  end if
  visibility = world.leafPvs(renderer.map, renderer.viewLeaf)
  rowBytes = (renderer.map.models[0].visibleLeafs + 7) >> 3
  markVisibleNodeSubtree(
    renderer.map, visibility, renderer.viewLeaf, rowBytes,
    rCompatVisibleNodes, renderer.map.models[0].headNodes[0],
  )
  return true
end function

/// Report whether count visible faces holds for the active state.
/// @param visibleFaces The visible faces input consumed by `countVisibleFaces`.
function countVisibleFaces(visibleFaces)
  count = 0
  index = 0
  faceCount = len(visibleFaces)
  while index < faceCount
    if visibleFaces[index] != 0 then count = count + 1 end if
    index = index + 1
  end while
  return count
end function

/// Report whether mark visible holds for the active state.
/// @param renderer Renderer instance or backend used for drawing.
/// @param viewOrigin The view origin input consumed by `markVisible`.
function markVisible(renderer, viewOrigin)
  global visibleFaceCountRenderer, visibleFaceCountLeaf, visibleFaceCountValue
  global rCompatVisibleNodeRenderer, rCompatVisibleNodes
  map = renderer.map
  if len(map.leafs) <= 1 or len(map.models) == 0 then return markAllVisible(renderer) end if
  currentLeaf = world.leafForPoint(map, viewOrigin)
  if currentLeaf == renderer.viewLeaf and len(renderer.visibleFaces) == len(map.faces) then
    if rCompatVisibleNodeRenderer != renderer or len(rCompatVisibleNodes) != len(map.nodes) then rebuildVisibleNodes(renderer) end if
    if visibleFaceCountRenderer == renderer and visibleFaceCountLeaf == currentLeaf then return visibleFaceCountValue end if
    visibleFaceCountRenderer = renderer
    visibleFaceCountLeaf = currentLeaf
    visibleFaceCountValue = countVisibleFaces(renderer.visibleFaces)
    return visibleFaceCountValue
  end if
  renderer.viewLeaf = currentLeaf
  // Entering a new BSP leaf used to allocate a complete face mask in a live
  // gameplay frame.  Reuse and clear the existing fixed-size buffer so rapid
  // movement through portals cannot create allocator/collector pressure.
  visibleFaces = renderer.visibleFaces
  if len(visibleFaces) != len(map.faces) then
    visibleFaces = bytes(len(map.faces), 0)
  else
    faceIndex = 0
    while faceIndex < len(visibleFaces)
      visibleFaces[faceIndex] = 0
      faceIndex = faceIndex + 1
    end while
  end if
  rowBytes = (map.models[0].visibleLeafs + 7) >> 3
  // SV_SpawnServer expands every PVS row while the loading plaque is active.
  // Reuse that immutable row instead of decompressing on the first frame in
  // each newly entered leaf.
  visibility = world.leafPvs(map, currentLeaf)

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
  rebuildVisibleNodes(renderer)
  visibleFaceCountRenderer = renderer
  visibleFaceCountLeaf = currentLeaf
  visibleFaceCountValue = count
  return count
end function

/// R_SetupFrame assigns r_viewleaf from the final (possibly chase-adjusted)
/// r_refdef.vieworg before it selects the contents cshift.
/// @param renderer Renderer instance or backend used for drawing.
/// @param viewOrigin The view origin input consumed by `ViewContents`.
function ViewContents(renderer, viewOrigin)
  if renderer is void or renderer.map is void or len(renderer.map.leafs) == 0 then return c.CONTENTS_EMPTY end if
  leafIndex = world.leafForPoint(renderer.map, viewOrigin)
  if leafIndex < 0 or leafIndex >= len(renderer.map.leafs) then return c.CONTENTS_EMPTY end if
  return renderer.map.leafs[leafIndex].contents
end function

/// Implements the `textureIdForSurface` operation for `miniquake.render.world` (texture id for surface).
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `textureIdForSurface`.
function textureIdForSurface(renderer, surface)
  if surface.textureIndex >= 0 and surface.textureIndex < len(renderer.textures) then
    texture = renderer.textures[surface.textureIndex]
    if texture is not void then
      // The surface already carries the canonical BSP texture index. Calling
      // R_TextureAnimation(texture) here searched the complete renderer texture
      // array to rediscover that index for every visible polygon. Resolve the
      // animation directly; this is behavior-identical and makes the batched
      // one-pass path linear in visible surfaces.
      target = bsp.textureAnimationIndex(
        renderer.map.textures,
        surface.textureIndex,
        rCompatTime,
        currentTextureFrame != 0,
      )
      if not (target is error) and target >= 0 and target < len(renderer.textures) then
        animated = renderer.textures[target]
        if animated is not void and animated.glId != 0 then return animated.glId end if
      end if
      if texture.glId != 0 then return texture.glId end if
    end if
  end if
  return renderer.noTextureId
end function

/// Render base surface.
/// @param renderer Renderer instance or backend used for drawing.
/// @param surface The surface input consumed by `drawBaseSurface`.
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

/// Render light surface.
/// @param surface The surface input consumed by `drawLightSurface`.
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

/// Update module state for up view.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function setupView(width, height, origin, angles)
  if width <= 0 then width = 1 end if
  if height <= 0 then height = 1 end if
  fovY = math.atan2(height * 1.0, width * 1.0) * 2.0 * math.RAD_TO_DEG
  return setupViewRect(0, 0, width, height, width, height, 90.0, fovY, origin, angles)
end function

/// Apply the Quake-compatible r viewport rect behavior.
/// @param viewX The view x input consumed by `R_ViewportRect`.
/// @param viewY The view y input consumed by `R_ViewportRect`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param screenWidth The screen width input consumed by `R_ViewportRect`.
/// @param screenHeight The screen height input consumed by `R_ViewportRect`.
function R_ViewportRect(viewX, viewY, width, height, screenWidth, screenHeight)
  if width <= 0 then width = 1 end if
  if height <= 0 then height = 1 end if
  x = viewX
  x2 = viewX + width
  y = screenHeight - viewY
  y2 = screenHeight - viewY - height
  // MiniQuake expands fractional view rectangles by one pixel at the open
  // borders. With MiniQuake's one-to-one framebuffer scale these are the
  // exact integer branches from R_SetupGL.
  if x > 0 then x = x - 1 end if
  if x2 < screenWidth then x2 = x2 + 1 end if
  if y2 < 0 then y2 = y2 - 1 end if
  if y < screenHeight then y = y + 1 end if
  return [x, y2, x2 - x, y - y2]
end function

/// Apply the Quake-compatible r set cull compatibility behavior.
/// @param enabled Whether the optional behavior is enabled.
function R_SetCullCompatibility(enabled)
  global rCompatCull
  rCompatCull = enabled
  return rCompatCull
end function

/// Configure MiniQuake's frame-clear and special-render cvars without changing the
/// public renderViewport signature used by older compatibility fixtures.
/// @param mirrorAlpha The mirror alpha input consumed by `R_ConfigureSpecialCompatibility`.
/// @param clearColor The clear color input consumed by `R_ConfigureSpecialCompatibility`.
/// @param zTrick The z trick input consumed by `R_ConfigureSpecialCompatibility`.
/// @param finishBeforeRender The finish before render input consumed by `R_ConfigureSpecialCompatibility`.
/// @param noRefresh The no refresh input consumed by `R_ConfigureSpecialCompatibility`.
function R_ConfigureSpecialCompatibility(mirrorAlpha, clearColor, zTrick, finishBeforeRender, noRefresh)
  global rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick
  global rCompatFinish, rCompatNoRefresh
  rCompatMirrorAlpha = native.bitsFloat(native.floatBits(mirrorAlpha))
  rCompatClearColor = clearColor
  rCompatZTrick = zTrick
  rCompatFinish = finishBeforeRender
  rCompatNoRefresh = noRefresh
  return [rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick, rCompatFinish, rCompatNoRefresh]
end function

// Apply the Quake-compatible r special compatibility state behavior.
function R_SpecialCompatibilityState()
  return [
    rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick,
    rCompatFinish, rCompatNoRefresh, rCompatTrickFrame,
    rCompatMirrorTexture, rCompatLastClearPlan,
  ]
end function

// Apply the Quake-compatible r current depth range behavior.
function R_CurrentDepthRange()
  return [rCompatDepthMin, rCompatDepthMax]
end function

// Mirror Quake's R_CurrentDepthMinimum routine and its observable state changes.
function R_CurrentDepthMinimum()
  return rCompatDepthMin
end function

// Mirror Quake's R_CurrentDepthMaximum routine and its observable state changes.
function R_CurrentDepthMaximum()
  return rCompatDepthMax
end function

// Return the depth comparison selected by R_ClearProduction for this frame.
// gl_ztrick reverses the depth range every other frame and therefore requires
// every later overlay (lighting, shadows and the view model) to retain GEQUAL
// on those frames instead of silently restoring the usual LEQUAL mode.
function R_CurrentDepthFunction()
  return rCompatDepthFunc
end function

// Apply the Quake-compatible r current view origin behavior.
function R_CurrentViewOrigin()
  return rCompatViewOrigin
end function

// Return the active main BSP map used by entity shadow-ray projection.
function R_CurrentWorldMap()
  if rCompatRenderer is void then return void end if
  return rCompatRenderer.map
end function

// Return the active render-surface graph used by arbitrary BSP shadow rays.
function R_CurrentWorldSurfaces()
  if rCompatRenderer is void then return [] end if
  return rCompatRenderer.surfaces
end function

// Apply the Quake-compatible r clear production behavior.
function R_ClearProduction()
  global rCompatTrickFrame, rCompatDepthMin, rCompatDepthMax, rCompatDepthFunc, rCompatLastClearPlan
  plan = specialPaths.clearPlan(rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick, rCompatTrickFrame)
  rCompatTrickFrame = plan[4]
  rCompatDepthMin = plan[1]
  rCompatDepthMax = plan[2]
  rCompatDepthFunc = plan[3]
  rCompatLastClearPlan = plan
  if plan[0] != 0 then gl.clear(plan[0]) end if
  gl.depthFunc(plan[3])
  gl.depthRange(plan[1], plan[2])
  return plan
end function

// Apply the Quake-compatible r reset mirror compatibility behavior.
function R_ResetMirrorCompatibility()
  global mirror, mirror_plane, rCompatMirrorChain, rCompatMirrorTexture
  mirror = false
  mirror_plane = void
  rCompatMirrorChain = []
  rCompatMirrorTexture = -1
  if rCompatRenderer is not void then rCompatMirrorTexture = specialPaths.findMirrorTexture(rCompatRenderer.textures) end if
  return rCompatMirrorTexture
end function

// Apply the Quake-compatible r mirror ready behavior.
function inline R_MirrorReady()
  return mirror and mirror_plane is not void and len(rCompatMirrorChain) > 0 and rCompatMirrorAlpha != 1.0
end function

/// Apply the Quake-compatible r mirror view behavior.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function R_MirrorView(origin, angles)
  if not R_MirrorReady() then return void end if
  return specialPaths.reflectView(origin, angles, mirror_plane)
end function

// Apply the Quake-compatible r mirror projection scale behavior.
function R_MirrorProjectionScale()
  return specialPaths.mirrorProjectionScale(mirror_plane)
end function

// Apply the Quake-compatible r mirror chain count behavior.
function R_MirrorChainCount()
  return len(rCompatMirrorChain)
end function

/// Apply the Quake-compatible r draw mirror overlay behavior.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param viewRect The view rect input consumed by `R_DrawMirrorOverlay`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function R_DrawMirrorOverlay(width, height, viewRect, origin, angles)
  global mirror, rCompatMirrorChain
  if not R_MirrorReady() then return 0 end if
  gl.depthRange(0.0, 0.5)
  gl.depthFunc(gl.GL_LEQUAL)
  setupViewRect(viewRect[0], viewRect[1], viewRect[2], viewRect[3], width, height, viewRect[4], viewRect[5], origin, angles)
  gl.enable(gl.GL_BLEND)
  gl.matrixMode(gl.GL_PROJECTION)
  // The original renderer still has the reflected projection matrix here and
  // applies the same sign scale a second time, cancelling the reflection for
  // the mirror-surface overlay. setupViewRect rebuilt the base projection
  // explicitly, so applying another scale here would mirror the overlay a
  // second time. Keep the restored base projection and switch culling only.
  gl.cullFace(gl.GL_FRONT)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.colorFloat(1.0, 1.0, 1.0, rCompatMirrorAlpha)
  count = 0
  for each surface in rCompatMirrorChain
    R_RenderBrushPoly(surface)
    count = count + 1
  end for
  rCompatMirrorChain = []
  gl.disable(gl.GL_BLEND)
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  mirror = false
  return count
end function

// Apply the Quake-compatible r main render stage order behavior.
function R_MainRenderStageOrder()
  // R_RenderScene followed by R_RenderView's post-scene passes.
  return ["world", "entities", "dlights", "particles", "viewmodel", "water", "polyblend"]
end function

/// Update module state for up view rect.
/// @param viewX The view x input consumed by `setupViewRect`.
/// @param viewY The view y input consumed by `setupViewRect`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param screenWidth The screen width input consumed by `setupViewRect`.
/// @param screenHeight The screen height input consumed by `setupViewRect`.
/// @param fovX The fov x input consumed by `setupViewRect`.
/// @param fovY The fov y input consumed by `setupViewRect`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function setupViewRect(viewX, viewY, width, height, screenWidth, screenHeight, fovX, fovY, origin, angles)
  if width <= 0 then width = 1 end if
  if height <= 0 then height = 1 end if
  nearValue = 4.0
  halfX = fovX * math.DEG_TO_RAD * 0.5
  halfY = fovY * math.DEG_TO_RAD * 0.5
  horizontal = nearValue * math.sin(halfX) / math.cos(halfX)
  vertical = nearValue * math.sin(halfY) / math.cos(halfY)
  viewport = R_ViewportRect(viewX, viewY, width, height, screenWidth, screenHeight)
  gl.viewport(viewport[0], viewport[1], viewport[2], viewport[3])
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  // MiniQuake 1.09 R_SetupGL uses zNear 4 and zFar 4096.  Keep this exact:
  // the ratio is observable through depth precision and polygon rejection.
  gl.frustum(-horizontal, horizontal, -vertical, vertical, nearValue, 4096.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.rotate(-90.0, 1.0, 0.0, 0.0)
  gl.rotate(90.0, 0.0, 0.0, 1.0)
  gl.rotate(-angles.z, 1.0, 0.0, 0.0)
  gl.rotate(-angles.x, 0.0, 1.0, 0.0)
  gl.rotate(-angles.y, 0.0, 0.0, 1.0)
  gl.translate(-origin.x, -origin.y, -origin.z)
end function

/// Implements the `render` operation for `miniquake.render.world` (render).
/// @param renderer Renderer instance or backend used for drawing.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function render(renderer, width, height, origin, angles)
  fovY = math.atan2(height * 1.0, width * 1.0) * 2.0 * math.RAD_TO_DEG
  return renderViewport(
    renderer, width, height, [0, 0, width, height, 90.0, fovY], origin, angles,
    [], [], renderer.frameCount * 0.02, renderer.frameCount * 0.02, 0.02,
    [0.0, 0.0, 0.0, 0.0],
  )
end function

/// Render viewport.
/// @param renderer Renderer instance or backend used for drawing.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param viewRect The view rect input consumed by `renderViewport`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
/// @param dynamicLights The dynamic lights input consumed by `renderViewport`.
/// @param lightStyles The light styles input consumed by `renderViewport`.
/// @param currentTime Time value used by the operation.
/// @param realtime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param blend The blend input consumed by `renderViewport`.
function renderViewport(renderer, width, height, viewRect, origin, angles, dynamicLights, lightStyles, currentTime, realtime, frameTime, blend)
  if not renderer.uploaded then
    uploadResult = try(upload(renderer))
    if uploadResult is error then return error(3903, "upload_world: " + uploadResult.message) end if
  end if
  if rCompatNoRefresh then return 0 end if
  if rCompatFinish then gl.finish() end if
  vectors = try(math.angleVectors(angles))
  if vectors is error then return error(3896, "view_vectors: " + vectors.message) end if
  configured = try(R_ConfigureWorldCompatibility(
    renderer, origin, angles, vectors[0], vectors[1], vectors[2],
    dynamicLights, lightStyles, blend, currentTime,
    realtime, frameTime, true, true, false,
  ))
  if configured is error then return error(3897, "configure_world: " + configured.message) end if
  R_ResetMirrorCompatibility()
  // V_RenderView pushes non-flashblend dlights before R_SetupFrame advances
  // r_framecount. R_BeginWorldFrame preserves that observable ordering.
  began = try(R_BeginWorldFrame())
  if began is error then return error(3898, "begin_world: " + began.message) end if
  marked = try(R_MarkLeaves())
  if marked is error then return error(3899, "mark_leaves: " + marked.message) end if
  gl.viewport(0, 0, width, height)
  // GL_Init in MiniQuake fixes the diagnostic clear colour to opaque red.
  // Do not silently replace it with black before gl_clear is evaluated: the
  // unused status-bar strip is observable in raw framebuffer evidence.
  gl.clearColor(1.0, 0.0, 0.0, 0.0)
  R_ClearProduction()
  gl.enable(gl.GL_DEPTH_TEST)
  gl.cullFace(gl.GL_FRONT)
  if rCompatCull then gl.enable(gl.GL_CULL_FACE) else gl.disable(gl.GL_CULL_FACE) end if
  gl.disable(gl.GL_BLEND)
  gl.disable(gl.GL_ALPHA_TEST)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  if renderer.wireframe then gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE) end if
  setupResult = try(setupViewRect(viewRect[0], viewRect[1], viewRect[2], viewRect[3], width, height, viewRect[4], viewRect[5], origin, angles))
  if setupResult is error then return error(3900, "setup_view: " + setupResult.message) end if
  enhanced.beginFrame(dynamicLights, currentTime, origin)
  count = try(R_DrawWorld())
  if count is error then return error(3901, "draw_world: " + count.message) end if
  dlightResult = try(R_DrawEnhancedWorldLighting())
  if not enhanced.isEnabled() then dlightResult = try(R_RenderDlights()) end if
  if dlightResult is error then return error(3902, "draw_dlights: " + dlightResult.message) end if
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  renderer.frameCount = renderer.frameCount + 1
  return count
end function

/// Mirror R_RenderScene pass.  The caller submits reflected entities and
/// particles around this world pass, matching gl_rmain.c's host-owned order.
/// @param renderer Renderer instance or backend used for drawing.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param viewRect The view rect input consumed by `renderMirrorViewport`.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
/// @param dynamicLights The dynamic lights input consumed by `renderMirrorViewport`.
/// @param lightStyles The light styles input consumed by `renderMirrorViewport`.
/// @param currentTime Time value used by the operation.
/// @param realtime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param blend The blend input consumed by `renderMirrorViewport`.
function renderMirrorViewport(renderer, width, height, viewRect, origin, angles, dynamicLights, lightStyles, currentTime, realtime, frameTime, blend)
  global rCompatDepthMin, rCompatDepthMax, rCompatDepthFunc
  if not R_MirrorReady() then return 0 end if
  vectors = math.angleVectors(angles)
  R_ConfigureWorldCompatibility(
    renderer, origin, angles, vectors[0], vectors[1], vectors[2],
    dynamicLights, lightStyles, blend, currentTime,
    realtime, frameTime, true, true, false,
  )
  R_BeginWorldFrame()
  R_MarkLeaves()
  rCompatDepthMin = 0.5
  rCompatDepthMax = 1.0
  rCompatDepthFunc = gl.GL_LEQUAL
  gl.depthRange(0.5, 1.0)
  gl.depthFunc(gl.GL_LEQUAL)
  gl.enable(gl.GL_DEPTH_TEST)
  if rCompatCull then gl.enable(gl.GL_CULL_FACE) else gl.disable(gl.GL_CULL_FACE) end if
  gl.disable(gl.GL_BLEND)
  gl.disable(gl.GL_ALPHA_TEST)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  setupViewRect(viewRect[0], viewRect[1], viewRect[2], viewRect[3], width, height, viewRect[4], viewRect[5], origin, angles)
  gl.matrixMode(gl.GL_PROJECTION)
  scale = specialPaths.mirrorProjectionScale(mirror_plane)
  gl.scale(scale.x, scale.y, scale.z)
  gl.cullFace(gl.GL_BACK)
  gl.matrixMode(gl.GL_MODELVIEW)
  count = R_DrawWorld()
  enhanced.beginFrame(dynamicLights, currentTime, origin)
  if enhanced.isEnabled() then R_DrawEnhancedWorldLighting() else R_RenderDlights() end if
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  return count
end function

// =============================================================================
// Canonical MiniQuake 1.09 renderer surface/light/warp entry points.
//
// The C renderer stores the active world, view vectors, light styles and
// dynamic lights in translation-unit globals. MiniLang keeps the same state
// explicitly in package globals and refreshes it from Host_Frame through
// R_ConfigureWorldCompatibility. Lightmaps retain MiniQuake's 128x128 atlas,
// allocation and dirty-rectangle semantics; surface-local arrays below replace
// only C pointer fields, not observable allocation or upload behavior.
// =============================================================================

const GLQUAKE_BLOCK_WIDTH = 128
/// Defines the glquake block height value used by `miniquake.render.world`.
const GLQUAKE_BLOCK_HEIGHT = 128
/// Defines the glquake max lightmaps value used by `miniquake.render.world`.
const GLQUAKE_MAX_LIGHTMAPS = 64
/// Defines the glquake surf underwater value used by `miniquake.render.world`.
const GLQUAKE_SURF_UNDERWATER = 0x80
/// Defines the glquake plane anyz value used by `miniquake.render.world`.
const GLQUAKE_PLANE_ANYZ = 5
/// Defines the glquake turbscale value used by `miniquake.render.world`.
const GLQUAKE_TURBSCALE = 40.74366543152521
/// Defines the glquake backface epsilon value used by `miniquake.render.world`.
const GLQUAKE_BACKFACE_EPSILON = 0.01

/// Tracks the module-level r compat renderer state owned by `miniquake.render.world`.
rCompatRenderer = void
/// Tracks the module-level r compat view origin state owned by `miniquake.render.world`.
rCompatViewOrigin = void
/// Tracks the module-level r compat view angles state owned by `miniquake.render.world`.
rCompatViewAngles = void
/// Tracks the module-level r compat view forward state owned by `miniquake.render.world`.
rCompatViewForward = void
/// Tracks the module-level r compat view right state owned by `miniquake.render.world`.
rCompatViewRight = void
/// Tracks the module-level r compat view up state owned by `miniquake.render.world`.
rCompatViewUp = void
/// Tracks the module-level r compat dlights state owned by `miniquake.render.world`.
rCompatDlights = []
/// Tracks the module-level r compat light styles state owned by `miniquake.render.world`.
rCompatLightStyles = []
/// Tracks the module-level r compat blend state owned by `miniquake.render.world`.
rCompatBlend = [0.0, 0.0, 0.0, 0.0]
/// Tracks the module-level r compat time state owned by `miniquake.render.world`.
rCompatTime = 0.0
/// Tracks the module-level r compat realtime state owned by `miniquake.render.world`.
rCompatRealtime = 0.0
/// Tracks the module-level r compat frame time state owned by `miniquake.render.world`.
rCompatFrameTime = 0.0
/// Tracks the module-level r compat flash blend state owned by `miniquake.render.world`.
rCompatFlashBlend = true
/// Tracks the module-level r compat dynamic state owned by `miniquake.render.world`.
rCompatDynamic = true
/// Tracks the module-level r compat no vis state owned by `miniquake.render.world`.
rCompatNoVis = false
/// Tracks the module-level r compat surface dlight bits state owned by `miniquake.render.world`.
rCompatSurfaceDlightBits = []
/// Tracks the module-level r compat enhanced texture builders state owned by `miniquake.render.world`.
rCompatEnhancedTextureBuilders = []
/// Tracks the module-level r compat enhanced batch keys state owned by `miniquake.render.world`.
rCompatEnhancedBatchKeys = bytes()
/// Tracks the module-level r compat surface dlight frame state owned by `miniquake.render.world`.
rCompatSurfaceDlightFrame = []
/// Tracks the module-level r compat surface cached light state owned by `miniquake.render.world`.
rCompatSurfaceCachedLight = []
/// Tracks the module-level r compat surface cached dlight state owned by `miniquake.render.world`.
rCompatSurfaceCachedDlight = []
/// Tracks the module-level r compat surface lightmap page state owned by `miniquake.render.world`.
rCompatSurfaceLightmapPage = []
/// Tracks the module-level r compat surface light s state owned by `miniquake.render.world`.
rCompatSurfaceLightS = []
/// Tracks the module-level r compat surface light t state owned by `miniquake.render.world`.
rCompatSurfaceLightT = []
/// Tracks the module-level r compat lightmap allocated state owned by `miniquake.render.world`.
rCompatLightmapAllocated = []
/// Tracks the module-level r compat lightmap modified state owned by `miniquake.render.world`.
rCompatLightmapModified = []
/// Tracks the module-level r compat lightmap rect change state owned by `miniquake.render.world`.
rCompatLightmapRectChange = []
/// Tracks the module-level r compat warp polys state owned by `miniquake.render.world`.
rCompatWarpPolys = []
/// Tracks the module-level r compat surface warp polys state owned by `miniquake.render.world`.
rCompatSurfaceWarpPolys = []
/// Tracks the module-level r compat sky texture state owned by `miniquake.render.world`.
rCompatSkyTexture = 0
/// Tracks the module-level r compat alpha sky texture state owned by `miniquake.render.world`.
rCompatAlphaSkyTexture = 0
/// Tracks the module-level r compat sky chain state owned by `miniquake.render.world`.
rCompatSkyChain = []
/// Tracks the module-level r compat water chain state owned by `miniquake.render.world`.
rCompatWaterChain = []
/// Tracks the module-level r compat texture chains state owned by `miniquake.render.world`.
rCompatTextureChains = []
/// Tracks the module-level r compat texture chain builders state owned by `miniquake.render.world`.
rCompatTextureChainBuilders = []
/// Tracks the module-level r compat multi texture enabled state owned by `miniquake.render.world`.
rCompatMultiTextureEnabled = false
/// Tracks the module-level r compat multi texture available state owned by `miniquake.render.world`.
rCompatMultiTextureAvailable = false
/// Tracks the module-level r compat use multitexture state owned by `miniquake.render.world`.
rCompatUseMultitexture = false
/// Tracks the module-level r compat depth min state owned by `miniquake.render.world`.
rCompatDepthMin = 0.0
/// Tracks the module-level r compat depth max state owned by `miniquake.render.world`.
rCompatDepthMax = 1.0
/// Tracks the module-level r compat depth func state owned by `miniquake.render.world`.
rCompatDepthFunc = gl.GL_LEQUAL
/// Tracks the module-level r compat light spot state owned by `miniquake.render.world`.
rCompatLightSpot = void
/// Tracks the module-level r compat light plane state owned by `miniquake.render.world`.
rCompatLightPlane = void
/// Tracks the module-level r compat abstract surface calls state owned by `miniquake.render.world`.
rCompatAbstractSurfaceCalls = false
/// Tracks the module-level r compat texture sort state owned by `miniquake.render.world`.
rCompatTextureSort = true
/// Tracks the module-level r compat cull state owned by `miniquake.render.world`.
rCompatCull = true
/// Tracks the module-level r compat mirror alpha state owned by `miniquake.render.world`.
rCompatMirrorAlpha = 1.0
/// Tracks the module-level r compat clear color state owned by `miniquake.render.world`.
rCompatClearColor = false
/// Tracks the module-level r compat z trick state owned by `miniquake.render.world`.
rCompatZTrick = true
/// Tracks the module-level r compat finish state owned by `miniquake.render.world`.
rCompatFinish = false
/// Tracks the module-level r compat no refresh state owned by `miniquake.render.world`.
rCompatNoRefresh = false
/// Tracks the module-level r compat trick frame state owned by `miniquake.render.world`.
rCompatTrickFrame = 0
/// Tracks the module-level r compat mirror texture state owned by `miniquake.render.world`.
rCompatMirrorTexture = -1
/// Tracks the module-level r compat mirror chain state owned by `miniquake.render.world`.
rCompatMirrorChain = []
/// Tracks the module-level r compat last clear plan state owned by `miniquake.render.world`.
rCompatLastClearPlan = [gl.GL_DEPTH_BUFFER_BIT, 0.0, 1.0, gl.GL_LEQUAL, 0]

// Original MiniQuake globals retained under their public names.
skytexturenum = -1
/// Tracks the module-level lightmap bytes state owned by `miniquake.render.world`.
lightmap_bytes = 1
/// Tracks the module-level lightmap textures state owned by `miniquake.render.world`.
lightmap_textures = 0
/// Tracks the module-level active lightmaps state owned by `miniquake.render.world`.
active_lightmaps = 0
/// Tracks the module-level blocklights state owned by `miniquake.render.world`.
blocklights = []
/// Tracks the module-level lightmap polys state owned by `miniquake.render.world`.
lightmap_polys = []
/// Tracks the module-level lightmap modified state owned by `miniquake.render.world`.
lightmap_modified = []
/// Tracks the module-level lightmap rectchange state owned by `miniquake.render.world`.
lightmap_rectchange = []
/// Tracks the module-level allocated state owned by `miniquake.render.world`.
allocated = []
/// Tracks the module-level lightmaps state owned by `miniquake.render.world`.
lightmaps = bytes()
/// Tracks the module-level r compat lightmap scratch state owned by `miniquake.render.world`.
rCompatLightmapScratch = bytes()
/// Tracks the module-level r compat colored lighting state owned by `miniquake.render.world`.
rCompatColoredLighting = void
/// Tracks the module-level colored lightmaps requested state owned by `miniquake.render.world`.
coloredLightmapsRequested = false
/// Tracks the module-level skychain state owned by `miniquake.render.world`.
skychain = []
/// Tracks the module-level waterchain state owned by `miniquake.render.world`.
waterchain = []
/// Tracks the module-level r compat lightmap builders state owned by `miniquake.render.world`.
rCompatLightmapBuilders = []
/// Tracks the module-level r compat sequential surfaces state owned by `miniquake.render.world`.
rCompatSequentialSurfaces = []
/// Tracks the module-level r compat sequential builder state owned by `miniquake.render.world`.
rCompatSequentialBuilder = void
/// Tracks the module-level r compat collect sequential state owned by `miniquake.render.world`.
rCompatCollectSequential = false
/// Tracks the module-level r compat mtex record faces state owned by `miniquake.render.world`.
rCompatMtexRecordFaces = []
/// Tracks the module-level r compat mtex records state owned by `miniquake.render.world`.
rCompatMtexRecords = bytes()
/// Tracks the module-level r compat mtex record count state owned by `miniquake.render.world`.
rCompatMtexRecordCount = 0
/// Tracks the module-level r compat mtex record stamp state owned by `miniquake.render.world`.
rCompatMtexRecordStamp = -1
/// Tracks the module-level r compat mtex texture ids state owned by `miniquake.render.world`.
rCompatMtexTextureIds = []
/// Tracks the module-level r compat mtex texture checked state owned by `miniquake.render.world`.
rCompatMtexTextureChecked = []
/// Tracks the module-level r compat surface batch keys state owned by `miniquake.render.world`.
rCompatSurfaceBatchKeys = bytes()
/// Tracks the module-level mtexenabled state owned by `miniquake.render.world`.
mtexenabled = false
/// Tracks the module-level r dlightframecount state owned by `miniquake.render.world`.
r_dlightframecount = 0
/// Tracks the module-level d lightstylevalue state owned by `miniquake.render.world`.
d_lightstylevalue = []
/// Tracks the module-level lightspot state owned by `miniquake.render.world`.
lightspot = void
/// Tracks the module-level lightplane state owned by `miniquake.render.world`.
lightplane = void
/// Tracks the module-level speedscale state owned by `miniquake.render.world`.
speedscale = 0.0
/// Tracks the module-level solidskytexture state owned by `miniquake.render.world`.
solidskytexture = 0
/// Tracks the module-level alphaskytexture state owned by `miniquake.render.world`.
alphaskytexture = 0
/// Tracks the module-level r framecount state owned by `miniquake.render.world`.
r_framecount = 0
/// Tracks the module-level r visframecount state owned by `miniquake.render.world`.
r_visframecount = 0
/// Tracks the module-level c brush polys state owned by `miniquake.render.world`.
c_brush_polys = 0
/// Tracks the module-level n colin elim state owned by `miniquake.render.world`.
nColinElim = 0
/// Tracks the module-level mirror state owned by `miniquake.render.world`.
mirror = false
/// Tracks the module-level mirror plane state owned by `miniquake.render.world`.
mirror_plane = void

// Apply the Quake-compatible r reset world compatibility behavior.
function R_ResetWorldCompatibility()
  global rCompatRenderer, rCompatViewOrigin, rCompatViewAngles, rCompatViewForward
  global rCompatViewRight, rCompatViewUp, rCompatDlights, rCompatLightStyles
  global rCompatBlend, rCompatTime, rCompatRealtime, rCompatFrameTime
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame, rCompatSurfaceCachedLight
  global rCompatSurfaceCachedDlight, rCompatSurfaceLightmapPage, rCompatSurfaceLightS, rCompatSurfaceLightT
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global rCompatWarpPolys, rCompatSurfaceWarpPolys, rCompatSkyTexture, rCompatAlphaSkyTexture
  global rCompatSkyChain, rCompatWaterChain, rCompatTextureChains, rCompatTextureChainBuilders
  global rCompatMultiTextureEnabled, rCompatUseMultitexture
  global rCompatDepthMin, rCompatDepthMax, rCompatDepthFunc, rCompatLightSpot, rCompatLightPlane
  global rCompatMirrorTexture, rCompatMirrorChain, rCompatLastClearPlan
  global skytexturenum, lightmap_textures, active_lightmaps, blocklights
  global lightmap_polys, rCompatLightmapBuilders
  global lightmap_modified, lightmap_rectchange, allocated, lightmaps, rCompatLightmapScratch
  global skychain, waterchain, mtexenabled, r_dlightframecount, d_lightstylevalue
  global lightspot, lightplane, speedscale, solidskytexture, alphaskytexture
  global r_framecount, r_visframecount, c_brush_polys, nColinElim, mirror, mirror_plane
  global currentTextureFrame, rCompatMtexRecordFaces, rCompatMtexRecords, rCompatMtexRecordCount, rCompatMtexRecordStamp, rCompatMtexTextureIds, rCompatMtexTextureChecked, rCompatSurfaceBatchKeys
  global rCompatVisibleNodeRenderer, rCompatVisibleNodes, rCompatColoredLighting

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
  rCompatSurfaceDlightBits = []
  rCompatSurfaceDlightFrame = []
  rCompatSurfaceCachedLight = []
  rCompatSurfaceCachedDlight = []
  rCompatSurfaceLightmapPage = []
  rCompatSurfaceLightS = []
  rCompatSurfaceLightT = []
  rCompatLightmapAllocated = []
  rCompatLightmapModified = []
  rCompatLightmapRectChange = []
  rCompatWarpPolys = []
  rCompatSurfaceWarpPolys = []
  rCompatSkyTexture = 0
  rCompatAlphaSkyTexture = 0
  rCompatSkyChain = []
  rCompatWaterChain = []
  rCompatTextureChains = []
  rCompatTextureChainBuilders = []
  rCompatMultiTextureEnabled = false
  rCompatUseMultitexture = false
  rCompatDepthMin = 0.0
  rCompatDepthMax = 1.0
  rCompatDepthFunc = gl.GL_LEQUAL
  rCompatLightSpot = void
  rCompatLightPlane = void
  rCompatMirrorTexture = -1
  rCompatMirrorChain = []
  rCompatLastClearPlan = [gl.GL_DEPTH_BUFFER_BIT, 0.0, 1.0, gl.GL_LEQUAL, 0]

  skytexturenum = -1
  lightmap_textures = 0
  active_lightmaps = 0
  blocklights = []
  lightmap_polys = []
  rCompatLightmapBuilders = []
  lightmap_modified = []
  lightmap_rectchange = []
  allocated = []
  lightmaps = bytes()
  rCompatLightmapScratch = bytes()
  rCompatColoredLighting = void
  skychain = []
  waterchain = []
  rCompatMtexRecordFaces = []
  rCompatMtexRecords = bytes()
  rCompatMtexRecordCount = 0
  rCompatMtexRecordStamp = -1
  rCompatMtexTextureIds = []
  rCompatMtexTextureChecked = []
  rCompatSurfaceBatchKeys = bytes()
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
  c_brush_polys = 0
  nColinElim = 0
  mirror = false
  mirror_plane = void
  currentTextureFrame = 0
  rCompatVisibleNodeRenderer = void
  rCompatVisibleNodes = bytes()
  return true
end function

// Return compat zero vector derived from the active module state.
function compatZeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `compatEmptyPlane` operation for `miniquake.render.world` (compat empty plane).
function compatEmptyPlane()
  return t.Plane(compatZeroVector(), 0.0, GLQUAKE_PLANE_ANYZ, 0)
end function

/// Implements the `compatAbs` operation for `miniquake.render.world` (compat abs).
/// @param value Value consumed by `compatAbs`.
function inline compatAbs(value)
  if value < 0.0 then return -value end if
  return value
end function

/// Return compat ensure array size derived from the active module state.
/// @param values The values input consumed by `compatEnsureArraySize`.
/// @param count Number of entries or units to process.
/// @param fillValue The fill value input consumed by `compatEnsureArraySize`.
function compatEnsureArraySize(values, count, fillValue)
  if len(values) == count then return values end if
  return arrayutil.makeFilledArray(count, fillValue)
end function

/// Implements the `compatFreshLightmapAllocation` operation for `miniquake.render.world` (compat fresh lightmap allocation).
function compatFreshLightmapAllocation()
  pages = arrayutil.makeEmptyArray(GLQUAKE_MAX_LIGHTMAPS)
  index = 0
  while index < GLQUAKE_MAX_LIGHTMAPS
    pages[index] = arrayutil.makeFilledArray(GLQUAKE_BLOCK_WIDTH, 0)
    index = index + 1
  end while
  return pages
end function

// Return compat ensure world state derived from the active module state.
function compatEnsureWorldState()
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame, rCompatSurfaceCachedLight
  global rCompatSurfaceCachedDlight, rCompatSurfaceLightmapPage
  global rCompatSurfaceLightS, rCompatSurfaceLightT
  global rCompatSurfaceWarpPolys, rCompatTextureChains, rCompatTextureChainBuilders
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global blocklights, lightmap_polys, rCompatLightmapBuilders
  global lightmap_modified, lightmap_rectchange, allocated, lightmaps, rCompatLightmapScratch
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
    rCompatSurfaceCachedDlight = arrayutil.makeFilledArray(count, false)
    rCompatSurfaceLightmapPage = arrayutil.makeFilledArray(count, 0)
    rCompatSurfaceLightS = arrayutil.makeFilledArray(count, 0)
    rCompatSurfaceLightT = arrayutil.makeFilledArray(count, 0)
  end if
  if len(rCompatSurfaceWarpPolys) != count then rCompatSurfaceWarpPolys = arrayutil.makeEmptyArray(count) end if
  if len(rCompatTextureChains) != len(rCompatRenderer.textures) then rCompatTextureChains = arrayutil.makeFilledArray(len(rCompatRenderer.textures), []) end if
  if len(rCompatTextureChainBuilders) != len(rCompatRenderer.textures) then rCompatTextureChainBuilders = arrayutil.makeFilledArray(len(rCompatRenderer.textures), false) end if
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
  // R_ClearLightmapChains owns the once-per-render-pass reset. Reinitializing
  // this array from R_BuildLightMap would erase surfaces already collected for
  // blending whenever a 10 Hz animated lightstyle changes.
  if len(lightmap_polys) != GLQUAKE_MAX_LIGHTMAPS then lightmap_polys = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, []) end if
  if len(rCompatLightmapBuilders) != GLQUAKE_MAX_LIGHTMAPS then rCompatLightmapBuilders = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, false) end if
  if len(lightmaps) != GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * 4 then
    lightmaps = bytes(GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * 4)
  end if
  if len(rCompatLightmapScratch) != 18 * 18 * 4 then rCompatLightmapScratch = bytes(18 * 18 * 4) end if
  return true
end function

/// Private compatibility-state adapters used by deterministic renderer oracles
/// and by the higher-level MiniQuake host integration.
/// @param index Zero-based index of the requested entry.
/// @param bitsValue The bits value input consumed by `R_SetSurfaceCompatibilityState`.
/// @param dlightFrame The dlight frame input consumed by `R_SetSurfaceCompatibilityState`.
/// @param cachedValues The cached values input consumed by `R_SetSurfaceCompatibilityState`.
/// @param cachedDlight The cached dlight input consumed by `R_SetSurfaceCompatibilityState`.
/// @param page The page input consumed by `R_SetSurfaceCompatibilityState`.
/// @param lightS The light s input consumed by `R_SetSurfaceCompatibilityState`.
/// @param lightT The light t input consumed by `R_SetSurfaceCompatibilityState`.
function R_SetSurfaceCompatibilityState(index, bitsValue, dlightFrame, cachedValues, cachedDlight, page, lightS, lightT)
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame, rCompatSurfaceCachedLight
  global rCompatSurfaceCachedDlight, rCompatSurfaceLightmapPage
  global rCompatSurfaceLightS, rCompatSurfaceLightT
  compatEnsureWorldState()
  if index < 0 or index >= len(rCompatSurfaceDlightBits) then return false end if
  rCompatSurfaceDlightBits[index] = bitsValue
  rCompatSurfaceDlightFrame[index] = dlightFrame
  rCompatSurfaceCachedLight[index] = cachedValues
  rCompatSurfaceCachedDlight[index] = cachedDlight
  rCompatSurfaceLightmapPage[index] = page
  rCompatSurfaceLightS[index] = lightS
  rCompatSurfaceLightT[index] = lightT
  return true
end function

/// Apply the Quake-compatible r set multitexture compatibility behavior.
/// @param available The available input consumed by `R_SetMultitextureCompatibility`.
/// @param enabled Whether the optional behavior is enabled.
function R_SetMultitextureCompatibility(available, enabled)
  global rCompatMultiTextureAvailable, rCompatMultiTextureEnabled, rCompatUseMultitexture, rCompatTextureSort, mtexenabled
  rCompatMultiTextureAvailable = available
  rCompatMultiTextureEnabled = enabled
  rCompatUseMultitexture = false
  // Start in the compatible two-pass mode; R_AnimateLight selects the one-pass
  // path once the current renderer state is available.
  rCompatTextureSort = true
  mtexenabled = enabled
  return true
end function

/// Apply the Quake-compatible r set texture animation frame behavior.
/// @param frame The frame input consumed by `R_SetTextureAnimationFrame`.
function R_SetTextureAnimationFrame(frame)
  global currentTextureFrame
  currentTextureFrame = frame
  return currentTextureFrame
end function

/// Apply the Quake-compatible r set frame compatibility behavior.
/// @param frame The frame input consumed by `R_SetFrameCompatibility`.
/// @param visFrame The vis frame input consumed by `R_SetFrameCompatibility`.
function R_SetFrameCompatibility(frame, visFrame)
  global r_framecount, r_visframecount
  r_framecount = frame
  r_visframecount = visFrame
  return true
end function

/// Apply the Quake-compatible r set light style compatibility behavior.
/// @param values The values input consumed by `R_SetLightStyleCompatibility`.
function R_SetLightStyleCompatibility(values)
  global d_lightstylevalue
  d_lightstylevalue = values
  return d_lightstylevalue
end function

/// Apply the Quake-compatible r set lightmap compatibility behavior.
/// @param textureBase The texture base input consumed by `R_SetLightmapCompatibility`.
/// @param bytesPerSample The bytes per sample input consumed by `R_SetLightmapCompatibility`.
function R_SetLightmapCompatibility(textureBase, bytesPerSample)
  global lightmap_textures, lightmap_bytes
  lightmap_textures = textureBase
  lightmap_bytes = bytesPerSample
  return true
end function

/// Apply the Quake-compatible r set lightmap dirty compatibility behavior.
/// @param page The page input consumed by `R_SetLightmapDirtyCompatibility`.
/// @param rectangle The rectangle input consumed by `R_SetLightmapDirtyCompatibility`.
/// @param modified The modified input consumed by `R_SetLightmapDirtyCompatibility`.
function R_SetLightmapDirtyCompatibility(page, rectangle, modified)
  rCompatLightmapRectChange[page] = rectangle
  rCompatLightmapModified[page] = modified
  return true
end function

/// Reset a dirty rectangle in place. Animated lightstyles hit this path often,
/// so retaining the four-slot record avoids one heap object per atlas upload.
/// @param page The page input consumed by `compatResetLightmapRectangle`.
function compatResetLightmapRectangle(page)
  rectangle = rCompatLightmapRectChange[page]
  rectangle[0] = GLQUAKE_BLOCK_WIDTH
  rectangle[1] = GLQUAKE_BLOCK_HEIGHT
  rectangle[2] = 0
  rectangle[3] = 0
  return rectangle
end function

/// Apply the Quake-compatible r set lightmap chain compatibility behavior.
/// @param page The page input consumed by `R_SetLightmapChainCompatibility`.
/// @param surfaces The surfaces input consumed by `R_SetLightmapChainCompatibility`.
function R_SetLightmapChainCompatibility(page, surfaces)
  rCompatLightmapBuilders[page] = false
  lightmap_polys[page] = surfaces
  return true
end function

/// Implements the `compatAddLightmapPoly` operation for `miniquake.render.world` (compat add lightmap poly).
/// @param page The page input consumed by `compatAddLightmapPoly`.
/// @param value Value consumed by `compatAddLightmapPoly`.
function compatAddLightmapPoly(page, value)
  global rCompatLightmapBuilders, lightmap_polys
  builder = rCompatLightmapBuilders[page]
  if builder is bool then
    existing = lightmap_polys[page]
    capacity = len(existing) + 32
    builder = arrayutil.createArrayBuilder(capacity)
    index = len(existing) - 1
    while index >= 0
      arrayutil.pushArrayBuilder(builder, existing[index])
      index = index - 1
    end while
    lightmap_polys[page] = []
    rCompatLightmapBuilders[page] = builder
  end if
  arrayutil.pushArrayBuilder(builder, value)
  return true
end function

/// Implements the `compatFinishLightmapChain` operation for `miniquake.render.world` (compat finish lightmap chain).
/// @param page The page input consumed by `compatFinishLightmapChain`.
function compatFinishLightmapChain(page)
  global rCompatLightmapBuilders, lightmap_polys
  builder = rCompatLightmapBuilders[page]
  if builder is bool then return lightmap_polys[page] end if
  cached = lightmap_polys[page]
  if len(cached) == builder.count then return cached end if
  result = arrayutil.makeEmptyArray(builder.count)
  index = 0
  while index < builder.count
    result[index] = builder.values[builder.count - 1 - index]
    index = index + 1
  end while
  lightmap_polys[page] = result
  // Keep the geometrically grown backing array. R_ClearLightmapChains resets
  // only its logical count, so animated lightmaps no longer allocate a fresh
  // builder on every rendered frame.
  return result
end function

/// Apply the Quake-compatible r set abstract surface calls behavior.
/// @param enabled Whether the optional behavior is enabled.
function R_SetAbstractSurfaceCalls(enabled)
  global rCompatAbstractSurfaceCalls
  rCompatAbstractSurfaceCalls = enabled
  return enabled
end function

/// Apply the Quake-compatible r set surface chain compatibility behavior.
/// @param textureSort The texture sort input consumed by `R_SetSurfaceChainCompatibility`.
/// @param skySurfaces The sky surfaces input consumed by `R_SetSurfaceChainCompatibility`.
/// @param waterSurfaces The water surfaces input consumed by `R_SetSurfaceChainCompatibility`.
function R_SetSurfaceChainCompatibility(textureSort, skySurfaces, waterSurfaces)
  global rCompatTextureSort, skychain, waterchain
  rCompatTextureSort = textureSort
  skychain = skySurfaces
  waterchain = waterSurfaces
  R_ResetTextureChains()
  return true
end function

// gl_rsurf.c stores one linked surface chain on every texture. Arrays preserve
// the same head-insertion order without exposing C pointers.
function R_ResetTextureChains()
  global rCompatTextureChains, rCompatTextureChainBuilders
  if rCompatRenderer is void then rCompatTextureChains = []; rCompatTextureChainBuilders = []; return 0 end if
  textureCount = len(rCompatRenderer.textures)
  if len(rCompatTextureChains) != textureCount then rCompatTextureChains = arrayutil.makeFilledArray(textureCount, []) end if
  if len(rCompatTextureChainBuilders) != textureCount then rCompatTextureChainBuilders = arrayutil.makeFilledArray(textureCount, false) end if
  index = 0
  while index < textureCount
    rCompatTextureChains[index] = []
    builder = rCompatTextureChainBuilders[index]
    if builder is not bool then builder.count = 0 end if
    index = index + 1
  end while
  return len(rCompatTextureChains)
end function

// Apply the Quake-compatible r get texture chains behavior.
function R_GetTextureChains()
  global rCompatTextureChains, rCompatTextureChainBuilders
  index = 0
  while index < len(rCompatTextureChains)
    builder = rCompatTextureChainBuilders[index]
    if builder is not bool then
      count = builder.count
      chain = arrayutil.makeEmptyArray(count)
      chainIndex = 0
      while chainIndex < count
        chain[chainIndex] = builder.values[count - 1 - chainIndex]
        chainIndex = chainIndex + 1
      end while
      rCompatTextureChains[index] = chain
    end if
    index = index + 1
  end while
  return rCompatTextureChains
end function

/// Apply the Quake-compatible r chain surface behavior.
/// @param surface The surface input consumed by `R_ChainSurface`.
function R_ChainSurface(surface)
  global rCompatTextureChains, rCompatTextureChainBuilders
  value = compatSurface(surface)
  if value is void then return false end if
  index = value.textureIndex
  if index < 0 or index >= len(rCompatTextureChains) then return false end if
  builder = rCompatTextureChainBuilders[index]
  if builder is bool then
    builder = arrayutil.createArrayBuilder(32)
    rCompatTextureChainBuilders[index] = builder
  end if
  arrayutil.pushArrayBuilder(builder, value)
  return true
end function

/// Resolve one texture chain in GLQuake head-insertion order. Production keeps
/// a reusable tail-appending builder to avoid allocating/copying an array for
/// every visible world polygon; only the consumed chain is materialized.
/// @param index Zero-based index of the requested entry.
function compatFinishTextureChain(index)
  global rCompatTextureChains, rCompatTextureChainBuilders
  if index < 0 or index >= len(rCompatTextureChains) then return [] end if
  builder = rCompatTextureChainBuilders[index]
  if builder is bool then return rCompatTextureChains[index] end if
  count = builder.count
  cached = rCompatTextureChains[index]
  if len(cached) == count then return cached end if
  chain = arrayutil.makeEmptyArray(count)
  chainIndex = 0
  while chainIndex < count
    chain[chainIndex] = builder.values[count - 1 - chainIndex]
    chainIndex = chainIndex + 1
  end while
  rCompatTextureChains[index] = chain
  return chain
end function

/// Clear one consumed texture chain without discarding its reusable capacity.
/// @param index Zero-based index of the requested entry.
function compatClearTextureChain(index)
  global rCompatTextureChains, rCompatTextureChainBuilders
  if index < 0 or index >= len(rCompatTextureChains) then return false end if
  rCompatTextureChains[index] = []
  builder = rCompatTextureChainBuilders[index]
  if builder is not bool then builder.count = 0 end if
  return true
end function

/// World surfaces use the exact dot-sign rule from R_RecursiveWorldNode.
/// Underwater polygons bypass back-face rejection because their warped vertices
/// may cross the original plane.
/// @param surface The surface input consumed by `R_SurfaceFacesViewer`.
/// @param planeDistance The plane distance input consumed by `R_SurfaceFacesViewer`.
function R_SurfaceFacesViewer(surface, planeDistance)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & GLQUAKE_SURF_UNDERWATER) != 0 then return true end if
  planeBack = (value.flags & c.SURF_PLANEBACK) != 0
  return not ((planeDistance < 0.0) != planeBack)
end function

/// Brush models use BACKFACE_EPSILON and the opposite-facing test from
/// R_DrawBrushModel.
/// @param surface The surface input consumed by `R_BrushSurfaceFacesViewer`.
/// @param planeDistance The plane distance input consumed by `R_BrushSurfaceFacesViewer`.
function R_BrushSurfaceFacesViewer(surface, planeDistance)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & c.SURF_PLANEBACK) != 0 then return planeDistance < -GLQUAKE_BACKFACE_EPSILON end if
  return planeDistance > GLQUAKE_BACKFACE_EPSILON
end function

/// Apply the Quake-compatible r water pass deferred behavior.
/// @param textureSort The texture sort input consumed by `R_WaterPassDeferred`.
/// @param waterAlpha The water alpha input consumed by `R_WaterPassDeferred`.
function inline R_WaterPassDeferred(textureSort, waterAlpha)
  return textureSort and waterAlpha != 1.0
end function

// Apply the Quake-compatible r get blocklights behavior.
function R_GetBlocklights()
  return blocklights
end function

// Apply the Quake-compatible r get lightmap bytes behavior.
function R_GetLightmapBytes()
  return lightmaps
end function

/// Apply the Quake-compatible r get surface compatibility state behavior.
/// @param index Zero-based index of the requested entry.
function R_GetSurfaceCompatibilityState(index)
  return [
    rCompatSurfaceCachedLight[index],
    rCompatSurfaceCachedDlight[index],
    rCompatSurfaceLightmapPage[index],
    rCompatSurfaceLightS[index],
    rCompatSurfaceLightT[index],
  ]
end function

/// Apply the Quake-compatible r get lightmap compatibility state behavior.
/// @param page The page input consumed by `R_GetLightmapCompatibilityState`.
function R_GetLightmapCompatibilityState(page)
  surfaces = compatFinishLightmapChain(page)
  return [
    rCompatLightmapModified[page],
    rCompatLightmapRectChange[page],
    c_brush_polys,
    len(surfaces),
  ]
end function

/// Apply the Quake-compatible r get allocation compatibility state behavior.
/// @param page The page input consumed by `R_GetAllocationCompatibilityState`.
function R_GetAllocationCompatibilityState(page)
  return rCompatLightmapAllocated[page]
end function

// Apply the Quake-compatible r get mirror compatibility state behavior.
function R_GetMirrorCompatibilityState()
  return [mirror, mirror_plane]
end function

// Apply the Quake-compatible r get frame compatibility behavior.
function R_GetFrameCompatibility()
  return [r_framecount, r_visframecount]
end function

/// Apply the Quake-compatible r get dynamic light compatibility state behavior.
/// @param index Zero-based index of the requested entry.
function R_GetDynamicLightCompatibilityState(index)
  if index < 0 or index >= len(rCompatSurfaceDlightBits) then return [0, 0] end if
  return [rCompatSurfaceDlightBits[index], rCompatSurfaceDlightFrame[index]]
end function

/// Apply the Quake-compatible r dynamic light is active behavior.
/// @param light The light input consumed by `R_DynamicLightIsActive`.
/// @param currentTime Time value used by the operation.
function inline R_DynamicLightIsActive(light, currentTime)
  return light is not void and light.die >= currentTime and light.radius > 0.0
end function

// Apply the Quake-compatible r reset lightmap compatibility behavior.
function R_ResetLightmapCompatibility()
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global allocated, lightmap_modified, lightmap_rectchange, lightmap_polys, lightmaps, rCompatLightmapBuilders
  global c_brush_polys, nColinElim, mirror, mirror_plane
  rCompatLightmapAllocated = compatFreshLightmapAllocation()
  rCompatLightmapModified = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, false)
  rCompatLightmapRectChange = arrayutil.makeEmptyArray(GLQUAKE_MAX_LIGHTMAPS)
  index = 0
  while index < GLQUAKE_MAX_LIGHTMAPS
    rCompatLightmapRectChange[index] = [GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, 0, 0]
    index = index + 1
  end while
  allocated = rCompatLightmapAllocated
  lightmap_modified = rCompatLightmapModified
  lightmap_rectchange = rCompatLightmapRectChange
  lightmap_polys = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, [])
  rCompatLightmapBuilders = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, false)
  lightmaps = bytes(4 * GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT)
  c_brush_polys = 0
  nColinElim = 0
  mirror = false
  mirror_plane = void
  return true
end function

/// Implements the `compatFnv1a` operation for `miniquake.render.world` (compat fnv1a).
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
function compatFnv1a(data, offset, count)
  hash = 2166136261
  index = 0
  while index < count and offset + index < len(data)
    hash = ((hash ^ data[offset + index]) * 16777619) & 4294967295
    index = index + 1
  end while
  return hash
end function

/// Implements the `compatHashLightmapRows` operation for `miniquake.render.world` (compat hash lightmap rows).
/// @param page The page input consumed by `compatHashLightmapRows`.
/// @param firstRow The first row input consumed by `compatHashLightmapRows`.
/// @param rowCount Number of entries or units to process.
function compatHashLightmapRows(page, firstRow, rowCount)
  offset = (page * GLQUAKE_BLOCK_HEIGHT + firstRow) * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
  return compatFnv1a(lightmaps, offset, rowCount * GLQUAKE_BLOCK_WIDTH * lightmap_bytes)
end function

// Return the active atlas transfer format without changing compatibility
// traces for ordinary grayscale BSP light data.
function compatLightmapFormat()
  if rCompatColoredLighting is bytes then return gl.GL_RGBA end if
  return gl.GL_LUMINANCE
end function

/// Transfer one dirty atlas rectangle using the format selected at map load.
/// @param page The page input consumed by `compatUploadLightmapSubImage`.
/// @param rectangle The rectangle input consumed by `compatUploadLightmapSubImage`.
function compatUploadLightmapSubImage(page, rectangle)
  if rectangle[3] <= 0 then return false end if
  uploadOffset = (page * GLQUAKE_BLOCK_HEIGHT + rectangle[1]) * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
  uploadLength = rectangle[3] * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
  pixels = slice(lightmaps, uploadOffset, uploadLength)
  if rCompatColoredLighting is bytes then
    gl.uploadRgbaSubImage(0, rectangle[1], GLQUAKE_BLOCK_WIDTH, rectangle[3], pixels)
  else
    gl.uploadLuminanceSubImage(0, rectangle[1], GLQUAKE_BLOCK_WIDTH, rectangle[3], pixels)
  end if
  return true
end function

/// Implements the `compatCopySurfaceLightmapToAtlas` operation for `miniquake.render.world` (compat copy surface lightmap to atlas).
/// @param surface The surface input consumed by `compatCopySurfaceLightmapToAtlas`.
/// @param pixels The pixels input consumed by `compatCopySurfaceLightmapToAtlas`.
function compatCopySurfaceLightmapToAtlas(surface, pixels)
  index = compatSurfaceIndex(surface)
  if index < 0 then return false end if
  page = rCompatSurfaceLightmapPage[index]
  lightS = rCompatSurfaceLightS[index]
  lightT = rCompatSurfaceLightT[index]
  row = 0
  while row < surface.lightHeight
    column = 0
    while column < surface.lightWidth
      destination = ((page * GLQUAKE_BLOCK_HEIGHT + lightT + row) * GLQUAKE_BLOCK_WIDTH + lightS + column) * lightmap_bytes
      source = (row * surface.lightWidth + column) * lightmap_bytes
      byteIndex = 0
      while byteIndex < lightmap_bytes
        lightmaps[destination + byteIndex] = pixels[source + byteIndex]
        byteIndex = byteIndex + 1
      end while
      column = column + 1
    end while
    row = row + 1
  end while
  return true
end function

/// Apply the Quake-compatible r configure world compatibility behavior.
/// @param renderer Renderer instance or backend used for drawing.
/// @param viewOrigin The view origin input consumed by `R_ConfigureWorldCompatibility`.
/// @param viewAngles The view angles input consumed by `R_ConfigureWorldCompatibility`.
/// @param viewForward The view forward input consumed by `R_ConfigureWorldCompatibility`.
/// @param viewRight The view right input consumed by `R_ConfigureWorldCompatibility`.
/// @param viewUp The view up input consumed by `R_ConfigureWorldCompatibility`.
/// @param dynamicLights The dynamic lights input consumed by `R_ConfigureWorldCompatibility`.
/// @param lightStyles The light styles input consumed by `R_ConfigureWorldCompatibility`.
/// @param blend The blend input consumed by `R_ConfigureWorldCompatibility`.
/// @param currentTime Time value used by the operation.
/// @param realtime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param flashBlend The flash blend input consumed by `R_ConfigureWorldCompatibility`.
/// @param dynamicEnabled The dynamic enabled input consumed by `R_ConfigureWorldCompatibility`.
/// @param noVis The no vis input consumed by `R_ConfigureWorldCompatibility`.
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
  global rCompatFlashBlend, rCompatDynamic, rCompatNoVis, rCompatSurfaceWarpPolys
  global rCompatColoredLighting
  if rCompatRenderer != renderer then rCompatSurfaceWarpPolys = [] end if
  rCompatRenderer = renderer
  rCompatColoredLighting = void
  if coloredLightmapsRequested and renderer is not void then
    rCompatColoredLighting = coloredLightmaps.forMap(renderer.map)
  end if
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

/// Select whether optional QLIT sidecars may replace the scalar lightmap
/// samples when the next world atlas is built. The Classic renderer calls this
/// with false, preserving byte-for-byte GLQuake lightmap behavior.
/// @param enabled Whether the optional behavior is enabled.
function R_ConfigureColoredLightmaps(enabled)
  global coloredLightmapsRequested
  coloredLightmapsRequested = enabled
  return coloredLightmapsRequested
end function

/// Configure the optional renderer extension.  This never mutates Quake world
/// state: an unavailable backend simply leaves the exact Classic path active.
/// @param requestedEnabled The requested enabled input consumed by `R_ConfigureEnhancedLighting`.
/// @param requestedShadows The requested shadows input consumed by `R_ConfigureEnhancedLighting`.
/// @param shadowQuality The shadow quality input consumed by `R_ConfigureEnhancedLighting`.
function R_ConfigureEnhancedLighting(requestedEnabled, requestedShadows, shadowQuality)
  return enhanced.configure(requestedEnabled, requestedShadows, shadowQuality)
end function

// Ensure one persistent surface builder per BSP texture for the enhanced
// additive pass.  Reusing these builders avoids per-frame chain allocations.
function compatEnsureEnhancedBuilders()
  global rCompatEnhancedTextureBuilders, rCompatEnhancedBatchKeys
  if rCompatRenderer is void then return false end if
  textureCount = len(rCompatRenderer.textures)
  if textureCount < 1 then textureCount = 1 end if
  if len(rCompatEnhancedTextureBuilders) != textureCount then
    rCompatEnhancedTextureBuilders = arrayutil.makeEmptyArray(textureCount)
    index = 0
    while index < textureCount
      rCompatEnhancedTextureBuilders[index] = arrayutil.createArrayBuilder(32)
      index = index + 1
    end while
  end if
  requiredBytes = len(rCompatRenderer.surfaces) * 8
  if len(rCompatEnhancedBatchKeys) < requiredBytes then rCompatEnhancedBatchKeys = bytes(requiredBytes) end if
  return true
end function

/// Pack the populated prefix of a surface builder into the reusable native-key
/// buffer used by the static geometry batch bridge.
/// @param values The values input consumed by `compatEnhancedBatchKeys`.
/// @param count Number of entries or units to process.
function compatEnhancedBatchKeys(values, count)
  global rCompatEnhancedBatchKeys
  index = 0
  while index < count
    key = nativeRawValue(values[index])
    byteio.putU32(rCompatEnhancedBatchKeys, index * 8, key & 0xffffffff)
    byteio.putU32(rCompatEnhancedBatchKeys, index * 8 + 4, (key >> 32) & 0xffffffff)
    index = index + 1
  end while
  return rCompatEnhancedBatchKeys
end function

// Render an additive, per-pixel dynamic-light layer over the already complete
// classic base/lightmap world.  Static lightmaps remain untouched; therefore
// disabling this pass produces byte-for-byte Classic draw ordering again.
function R_DrawEnhancedWorldLighting()
  if rCompatRenderer is void or not enhanced.hasActiveLights() then return 0 end if
  // Rebuild texture-local visible chains, then submit each chain through the
  // existing static geometry cache under one additive shader state.
  compatEnsureEnhancedBuilders()
  builderIndex = 0
  while builderIndex < len(rCompatEnhancedTextureBuilders)
    rCompatEnhancedTextureBuilders[builderIndex].count = 0
    builderIndex = builderIndex + 1
  end while

  faceIndex = 0
  while faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex < len(rCompatRenderer.visibleFaces) and rCompatRenderer.visibleFaces[faceIndex] != 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      if surface is not void and (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | GLQUAKE_SURF_UNDERWATER)) == 0 then
        plane = compatPlane(surface)
        if plane is not void then
          distance = compatPlaneDistance(plane, rCompatViewOrigin)
          if R_SurfaceFacesViewer(surface, distance) then
            textureIndex = surface.textureIndex
            if textureIndex < 0 or textureIndex >= len(rCompatEnhancedTextureBuilders) then textureIndex = 0 end if
            arrayutil.pushArrayBuilder(rCompatEnhancedTextureBuilders[textureIndex], surface)
          end if
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while

  GL_DisableMultitexture()
  gl.enable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_ONE, gl.GL_ONE)
  gl.depthMask(false)
  gl.depthFunc(R_CurrentDepthFunction())
  enhanced.beginOverlay()
  drawn = 0
  builderIndex = 0
  while builderIndex < len(rCompatEnhancedTextureBuilders)
    builder = rCompatEnhancedTextureBuilders[builderIndex]
    if builder.count > 0 then
      first = builder.values[0]
      gl.bindTexture(textureIdForSurface(rCompatRenderer, first))
      keys = compatEnhancedBatchKeys(builder.values, builder.count)
      batched = gl.staticGeometryCallBatchCount(keys, builder.count, 0)
      if not batched then
        item = 0
        while item < builder.count
          DrawGLPoly(builder.values[item])
          item = item + 1
        end while
      end if
      drawn = drawn + builder.count
    end if
    builderIndex = builderIndex + 1
  end while
  enhanced.endOverlay()
  gl.depthMask(true)
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.color(255, 255, 255, 255)
  return drawn
end function

/// Apply the Quake-compatible r set subdivide size behavior.
/// @param value Value consumed by `R_SetSubdivideSize`.
function R_SetSubdivideSize(value)
  return glWarp.SetSubdivideSize(value)
end function

/// Return compat surface index derived from the active module state.
/// @param surface The surface input consumed by `compatSurfaceIndex`.
function compatSurfaceIndex(surface)
  if rCompatRenderer is void then return -1 end if
  if typeof(surface) == "int" and surface >= 0 and surface < len(rCompatRenderer.surfaces) then return surface end if
  if surface is void then return -1 end if
  // RenderSurface.faceIndex is assigned from the canonical BSP face index in
  // buildSurface, and renderer.surfaces is built in that exact order.  The old
  // compatibility fallback scanned and structurally compared every surface on
  // every lookup, making world rendering quadratic on retail maps.
  index = surface.faceIndex
  if index >= 0 and index < len(rCompatRenderer.surfaces) then return index end if
  return -1
end function

/// Implements the `compatSurface` operation for `miniquake.render.world` (compat surface).
/// @param surface The surface input consumed by `compatSurface`.
function compatSurface(surface)
  if rCompatRenderer is void then return void end if
  if typeof(surface) == "int" then
    if surface < 0 or surface >= len(rCompatRenderer.surfaces) then return void end if
    return rCompatRenderer.surfaces[surface]
  end if
  return surface
end function

/// Implements the `compatFace` operation for `miniquake.render.world` (compat face).
/// @param surface The surface input consumed by `compatFace`.
function compatFace(surface)
  value = compatSurface(surface)
  if value is void then return void end if
  if value.faceIndex < 0 or value.faceIndex >= len(rCompatRenderer.map.faces) then return void end if
  return rCompatRenderer.map.faces[value.faceIndex]
end function

/// Implements the `compatPlane` operation for `miniquake.render.world` (compat plane).
/// @param surface The surface input consumed by `compatPlane`.
function compatPlane(surface)
  face = compatFace(surface)
  if face is void then return void end if
  if face.planeIndex < 0 or face.planeIndex >= len(rCompatRenderer.map.planes) then return void end if
  return rCompatRenderer.map.planes[face.planeIndex]
end function

/// Implements the `compatTexInfo` operation for `miniquake.render.world` (compat tex info).
/// @param surface The surface input consumed by `compatTexInfo`.
function compatTexInfo(surface)
  face = compatFace(surface)
  if face is void then return void end if
  if face.texInfo < 0 or face.texInfo >= len(rCompatRenderer.map.texInfo) then return void end if
  return rCompatRenderer.map.texInfo[face.texInfo]
end function

/// Implements the `compatPlaneDistance` operation for `miniquake.render.world` (compat plane distance).
/// @param plane The plane input consumed by `compatPlaneDistance`.
/// @param point The point input consumed by `compatPlaneDistance`.
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
  global d_lightstylevalue, rCompatUseMultitexture, rCompatTextureSort
  compatEnsureWorldState()
  d_lightstylevalue = glRlight.R_AnimateLightInto(rCompatLightStyles, rCompatTime, d_lightstylevalue)
  // GLQuake's one-pass multitexture equation preserves every animated
  // lightmap frame without the second full-screen world pass. Systems without
  // multitexture retain the original sorted two-pass fallback below.
  rCompatUseMultitexture = rCompatMultiTextureAvailable and rCompatRenderer is not void and not rCompatRenderer.fullbright
  rCompatTextureSort = not rCompatUseMultitexture
  return d_lightstylevalue
end function

/// Implements the `compatAssignLightBlend` operation for `miniquake.render.world` (compat assign light blend).
/// @param updated The updated input consumed by `compatAssignLightBlend`.
function compatAssignLightBlend(updated)
  global rCompatBlend
  if rCompatBlend is void or len(rCompatBlend) < 4 then rCompatBlend = [0.0, 0.0, 0.0, 0.0] end if
  index = 0
  while index < 4
    rCompatBlend[index] = updated[index]
    index = index + 1
  end while
  return rCompatBlend
end function

/// Add state for add light blend.
/// @param red The red input consumed by `AddLightBlend`.
/// @param green The green input consumed by `AddLightBlend`.
/// @param blue The blue input consumed by `AddLightBlend`.
/// @param alpha2 The alpha2 input consumed by `AddLightBlend`.
function AddLightBlend(red, green, blue, alpha2)
  return compatAssignLightBlend(glRlight.AddLightBlend(rCompatBlend, red, green, blue, alpha2))
end function

/// Apply the Quake-compatible r render dlight behavior.
/// @param light The light input consumed by `R_RenderDlight`.
function R_RenderDlight(light)
  global rCompatBlend
  trace = glRlight.R_RenderDlight(
    light,
    rCompatTime,
    rCompatViewOrigin,
    rCompatViewForward,
    rCompatViewRight,
    rCompatViewUp,
    rCompatBlend,
  )
  if not trace[0] then return false end if
  compatAssignLightBlend(trace[1])
  vertices = trace[2]
  if len(vertices) == 0 then return true end if
  gl.begin(gl.GL_TRIANGLE_FAN)
  gl.color(51, 26, 0, 255)
  center = vertices[0]
  gl.vertex3(center.x, center.y, center.z)
  gl.color(0, 0, 0, 255)
  index = 1
  while index < len(vertices)
    point = vertices[index]
    gl.vertex3(point.x, point.y, point.z)
    index = index + 1
  end while
  gl.finishPrimitive()
  return true
end function

// Apply the Quake-compatible r render dlights behavior.
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

/// Production MiniQuake R_PolyBlend.  Host invokes this after entities,
/// viewmodel and particles, while the 3-D viewport/projection from R_SetupGL
/// is still active and before gl_screen switches to its full-screen 2-D
/// projection.  Drawing this as a 2-D quad would incorrectly tint the HUD and
/// console outside r_refdef.vrect.
/// @param blend The blend input consumed by `R_PolyBlendProduction`.
/// @param enabled Whether the optional behavior is enabled.
function R_PolyBlendProduction(blend, enabled)
  if not enabled or blend is void or len(blend) < 4 or blend[3] == 0.0 then return false end if
  GL_DisableMultitexture()
  gl.disable(gl.GL_ALPHA_TEST)
  gl.enable(gl.GL_BLEND)
  gl.disable(gl.GL_DEPTH_TEST)
  gl.disable(gl.GL_TEXTURE_2D)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.rotate(-90.0, 1.0, 0.0, 0.0)
  gl.rotate(90.0, 0.0, 0.0, 1.0)
  gl.colorFloat(blend[0], blend[1], blend[2], blend[3])
  gl.begin(gl.GL_QUADS)
  gl.vertex3(10.0, 100.0, 100.0)
  gl.vertex3(10.0, -100.0, 100.0)
  gl.vertex3(10.0, -100.0, -100.0)
  gl.vertex3(10.0, 100.0, -100.0)
  gl.finishPrimitive()
  // The original renderer rebuilt most of this state at the next R_SetupGL,
  // but Direct3D/Vulkan translate immediate commands into deferred batches.
  // Establish a complete compatibility fence here so a persistent powerup
  // cshift (especially Quad Damage) cannot bleed into the next entity-shadow
  // batch while a frame is submitted or presented asynchronously.
  gl.color(255, 255, 255, 255)
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_ALPHA_TEST)
  gl.enable(gl.GL_DEPTH_TEST)
  gl.depthMask(true)
  gl.depthFunc(R_CurrentDepthFunction())
  gl.textureEnvironment(gl.GL_REPLACE)
  return true
end function

/// Apply the Quake-compatible r mark lights behavior.
/// @param light The light input consumed by `R_MarkLights`.
/// @param bit The bit input consumed by `R_MarkLights`.
/// @param nodeNumber The node number input consumed by `R_MarkLights`.
function R_MarkLights(light, bit, nodeNumber)
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame
  if rCompatRenderer is void or light is void or nodeNumber < 0 then return 0 end if
  return glRlight.R_MarkLights(
    rCompatRenderer.map,
    rCompatSurfaceDlightBits,
    rCompatSurfaceDlightFrame,
    r_dlightframecount,
    light,
    bit,
    nodeNumber,
  )
end function

// Apply the Quake-compatible r push dlights behavior.
function R_PushDlights()
  global r_dlightframecount
  if rCompatFlashBlend or not rCompatDynamic or rCompatRenderer is void then return 0 end if
  compatEnsureWorldState()
  r_dlightframecount = r_framecount + 1
  if len(rCompatRenderer.map.models) == 0 then return 0 end if
  root = rCompatRenderer.map.models[0].headNodes[0]
  return glRlight.R_PushDlights(
    rCompatRenderer.map,
    rCompatSurfaceDlightBits,
    rCompatSurfaceDlightFrame,
    r_dlightframecount,
    rCompatDlights,
    rCompatTime,
    root,
  )
end function

// Apply the Quake-compatible r begin world frame behavior.
function R_BeginWorldFrame()
  marked = R_PushDlights()
  R_AnimateLight()
  frame = R_AdvanceFrameCounters()
  return [frame, r_dlightframecount, marked]
end function

/// Apply the Quake-compatible r mark brush model lights for submodel behavior.
/// @param entity Entity affected by the operation.
/// @param submodelIndex Zero-based index of the requested entry.
function R_MarkBrushModelLightsForSubmodel(entity, submodelIndex)
  if rCompatRenderer is void or entity is void or rCompatFlashBlend or not rCompatDynamic then return 0 end if
  if submodelIndex < 1 or submodelIndex >= len(rCompatRenderer.map.models) then return 0 end if
  model = rCompatRenderer.map.models[submodelIndex]
  // firstFace == 0 denotes the world/non-instanced model in WinQuake.
  if model.firstFace == 0 or len(model.headNodes) == 0 then return 0 end if
  root = model.headNodes[0]
  marked = 0
  index = 0
  while index < len(rCompatDlights) and index < c.MAX_DLIGHTS
    light = rCompatDlights[index]
    if R_DynamicLightIsActive(light, rCompatTime) then marked = marked + R_MarkLights(light, 1 << index, root) end if
    index = index + 1
  end while
  return marked
end function

/// Apply the Quake-compatible r mark brush model lights behavior.
/// @param entity Entity affected by the operation.
function R_MarkBrushModelLights(entity)
  if entity is void then return 0 end if
  return R_MarkBrushModelLightsForSubmodel(entity, entity.modelIndex)
end function

/// Apply the Quake-compatible r add dynamic lights behavior.
/// @param surface The surface input consumed by `R_AddDynamicLights`.
function R_AddDynamicLights(surface)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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
              addition = native.trunc((radius - distance) * 256.0)
              destination = sampleT * smax + sampleS
              if rCompatColoredLighting is bytes then
                destination = destination * 3
                blocklights[destination] = blocklights[destination] + addition
                blocklights[destination + 1] = blocklights[destination + 1] + addition
                blocklights[destination + 2] = blocklights[destination + 2] + addition
              else
                blocklights[destination] = blocklights[destination] + addition
              end if
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

/// Apply the Quake-compatible r lightmap required bytes behavior.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param stride The stride input consumed by `R_LightmapRequiredBytes`.
/// @param bytesPerSample The bytes per sample input consumed by `R_LightmapRequiredBytes`.
function R_LightmapRequiredBytes(width, height, stride, bytesPerSample)
  if width < 1 or height < 1 then return 0 end if
  if bytesPerSample != 1 and bytesPerSample != 4 then return error(3771, "Bad lightmap format") end if
  rowBytes = width * bytesPerSample
  if stride < rowBytes then stride = rowBytes end if
  return (height - 1) * stride + rowBytes
end function

/// Apply the Quake-compatible r build light map behavior.
/// @param surface The surface input consumed by `R_BuildLightMap`.
/// @param destination Destination value or collection to update.
/// @param stride The stride input consumed by `R_BuildLightMap`.
function R_BuildLightMap(surface, destination, stride)
  global blocklights, rCompatSurfaceCachedLight, rCompatSurfaceCachedDlight
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 then return error(3760, "R_BuildLightMap: bad surface") end if
  compatEnsureWorldState()
  width = value.lightWidth
  height = value.lightHeight
  count = width * height
  if count < 1 then return bytes() end if
  required = R_LightmapRequiredBytes(width, height, stride, lightmap_bytes)
  if required is error then return required end if
  rowBytes = width * lightmap_bytes
  if stride < rowBytes then stride = rowBytes end if
  if destination is void then destination = bytes(required) end if
  if destination is not bytes then return error(3761, "R_BuildLightMap: destination must be bytes") end if
  if len(destination) < required then return error(3762, "R_BuildLightMap: destination is too small") end if
  colored = rCompatColoredLighting is bytes and len(rCompatColoredLighting) >= len(rCompatRenderer.map.lighting) * 3
  accumulationCount = count
  if colored then accumulationCount = count * 3 end if
  if len(blocklights) < accumulationCount then blocklights = arrayutil.makeFilledArray(accumulationCount, 0) end if

  rCompatSurfaceCachedDlight[index] = rCompatSurfaceDlightFrame[index] == r_framecount
  fullbright = rCompatRenderer.fullbright
  if fullbright or len(rCompatRenderer.map.lighting) == 0 or value.lightOffset < 0 then
    sample = 0
    while sample < accumulationCount
      blocklights[sample] = 255 * 256
      sample = sample + 1
    end while
  else
    sample = 0
    while sample < accumulationCount
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
        if colored then
          coloredSource = (sourceOffset + sample) * 3
          coloredDestination = sample * 3
          blocklights[coloredDestination] = blocklights[coloredDestination] + rCompatColoredLighting[coloredSource] * scaleValue
          blocklights[coloredDestination + 1] = blocklights[coloredDestination + 1] + rCompatColoredLighting[coloredSource + 1] * scaleValue
          blocklights[coloredDestination + 2] = blocklights[coloredDestination + 2] + rCompatColoredLighting[coloredSource + 2] * scaleValue
        else
          blocklights[sample] = blocklights[sample] + rCompatRenderer.map.lighting[sourceOffset + sample] * scaleValue
        end if
        sample = sample + 1
      end while
      mapNumber = mapNumber + 1
    end while
    if rCompatSurfaceDlightFrame[index] == r_framecount then R_AddDynamicLights(value) end if
  end if

  y = 0
  while y < height
    x = 0
    while x < width
      destinationOffset = y * stride + x * lightmap_bytes
      if colored then
        coloredSource = (y * width + x) * 3
        channel = 0
        while channel < 3
          lightValue = blocklights[coloredSource + channel] >> 7
          if lightValue > 255 then lightValue = 255 end if
          destination[destinationOffset + channel] = 255 - lightValue
          channel = channel + 1
        end while
        destination[destinationOffset + 3] = 255
      else if lightmap_bytes == 4 then
        // GL_RGBA leaves RGB untouched and stores the inverted light in alpha.
        lightValue = blocklights[y * width + x] >> 7
        if lightValue > 255 then lightValue = 255 end if
        outputValue = 255 - lightValue
        destination[destinationOffset + 3] = outputValue
      else
        lightValue = blocklights[y * width + x] >> 7
        if lightValue > 255 then lightValue = 255 end if
        outputValue = 255 - lightValue
        destination[destinationOffset] = outputValue
      end if
      x = x + 1
    end while
    y = y + 1
  end while
  return destination
end function

/// Implements the `RecursiveLightPoint` operation for `miniquake.render.world` (recursive light point).
/// @param nodeNumber The node number input consumed by `RecursiveLightPoint`.
/// @param start The start input consumed by `RecursiveLightPoint`.
/// @param finish The finish input consumed by `RecursiveLightPoint`.
function RecursiveLightPoint(nodeNumber, start, finish)
  global lightspot, lightplane, rCompatLightSpot, rCompatLightPlane
  if rCompatRenderer is void then return -1 end if
  result = glRlight.RecursiveLightPoint(
    rCompatRenderer.map,
    rCompatRenderer.surfaces,
    d_lightstylevalue,
    nodeNumber,
    start,
    finish,
  )
  if result[1] is not void then
    lightspot = result[1]
    lightplane = result[2]
    rCompatLightSpot = lightspot
    rCompatLightPlane = lightplane
  end if
  return result[0]
end function

/// Apply the Quake-compatible r light point behavior.
/// @param point The point input consumed by `R_LightPoint`.
function R_LightPoint(point)
  global lightspot, lightplane, rCompatLightSpot, rCompatLightPlane
  if rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 255 end if
  result = glRlight.R_LightPointValue(
    rCompatRenderer.map,
    rCompatRenderer.surfaces,
    d_lightstylevalue,
    rCompatRenderer.map.models[0].headNodes[0],
    point,
  )
  if glRlight.FastLightHit() then
    if lightspot is void then lightspot = t.Vec3(0.0, 0.0, 0.0) end if
    spot = lightspot
    spot.x = point.x
    spot.y = point.y
    spot.z = glRlight.FastLightSpotZ()
    lightspot = spot
    lightplane = glRlight.FastLightPlane()
    rCompatLightSpot = lightspot
    rCompatLightPlane = lightplane
  end if
  return result
end function

// Report whether the most recent vertical light/receiver trace actually hit
// a world surface.  lightspot intentionally retains its storage object for
// allocation-free alias lighting, so callers must not infer validity merely
// from that object's non-void state.
function R_LightPointHit()
  return glRlight.FastLightHit()
end function

// Apply the Quake-compatible r active dynamic lights behavior.
function R_ActiveDynamicLights()
  return rCompatDlights
end function

/// -----------------------------------------------------------------------------
/// gl_rsurf.c
/// -----------------------------------------------------------------------------
/// @param base The base input consumed by `R_TextureAnimation`.

function R_TextureAnimation(base)
  if base is void or rCompatRenderer is void then return base end if
  index = 0
  while index < len(rCompatRenderer.textures)
    if rCompatRenderer.textures[index] == base then
      target = bsp.textureAnimationIndex(
        rCompatRenderer.map.textures,
        index,
        rCompatTime,
        currentTextureFrame != 0,
      )
      if target is error then return target end if
      if target >= 0 and target < len(rCompatRenderer.textures) then return rCompatRenderer.textures[target] end if
      return base
    end if
    index = index + 1
  end while
  return base
end function

/// Tracks the module-level current texture frame state owned by `miniquake.render.world`.
currentTextureFrame = 0

// Mirror Quake's GL_DisableMultitexture routine and its observable state changes.
function GL_DisableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if rCompatMultiTextureEnabled then
    if not gl.traceEnabled() then gl.activeTexture(1) end if
    gl.disable(gl.GL_TEXTURE_2D)
    if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835E]) end if
    if not gl.traceEnabled() then gl.activeTexture(0) end if
  end if
  rCompatMultiTextureEnabled = false
  mtexenabled = false
  return true
end function

// Mirror Quake's GL_EnableMultitexture routine and its observable state changes.
function GL_EnableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if not rCompatMultiTextureAvailable then return false end if
  if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835F]) end if
  if not gl.traceEnabled() then gl.activeTexture(1) end if
  gl.enable(gl.GL_TEXTURE_2D)
  rCompatMultiTextureEnabled = true
  mtexenabled = true
  return true
end function

/// Apply the Quake-compatible r draw sequential poly behavior.
/// @param surface The surface input consumed by `R_DrawSequentialPoly`.
function R_DrawSequentialPoly(surface)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global rCompatSequentialSurfaces, rCompatSequentialBuilder
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & c.SURF_DRAWSKY) != 0 then return R_DrawSkyChain([value]) end if
  if (value.flags & c.SURF_DRAWTURB) != 0 then return EmitWaterPolys(value) end if
  if rCompatCollectSequential then
    arrayutil.pushArrayBuilder(rCompatSequentialBuilder, value)
    return true
  end if
  R_RenderDynamicLightmaps(value)
  if rCompatUseMultitexture then
    if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835E]) end if
    if not gl.traceEnabled() then gl.activeTexture(0) end if
    gl.bindTexture(textureIdForSurface(rCompatRenderer, value))
    gl.textureEnvironment(gl.GL_REPLACE)
    GL_EnableMultitexture()
    gl.bindTexture(value.lightmapId)
    index = compatSurfaceIndex(value)
    if index >= 0 and rCompatLightmapModified[rCompatSurfaceLightmapPage[index]] then
      page = rCompatSurfaceLightmapPage[index]
      rectangle = rCompatLightmapRectChange[page]
      tracedUpload = false
      if gl.traceEnabled() then
        traceHash = compatHashLightmapRows(page, rectangle[1], rectangle[3])
        tracedUpload = gl.traceCommand("upload_subimage", [
          gl.GL_TEXTURE_2D, 0, 0, rectangle[1], GLQUAKE_BLOCK_WIDTH,
          rectangle[3], compatLightmapFormat(), gl.GL_UNSIGNED_BYTE, traceHash,
        ])
      end if
      if not tracedUpload then compatUploadLightmapSubImage(page, rectangle) end if
      rCompatLightmapModified[page] = false
      compatResetLightmapRectangle(page)
    end if
    gl.textureEnvironment(gl.GL_BLEND)
    gl.begin(gl.GL_POLYGON)
    for each vertex in value.vertices
      if gl.traceEnabled() then
        gl.traceCommand("multitexcoord", [0x835E, vertex.s, vertex.t])
        gl.traceCommand("multitexcoord", [0x835F, vertex.lightS, vertex.lightT])
      else
        gl.multiTexCoord2(0, vertex.s, vertex.t)
        gl.multiTexCoord2(1, vertex.lightS, vertex.lightT)
      end if
      gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
    end for
    gl.finishPrimitive()
  else
    gl.bindTexture(textureIdForSurface(rCompatRenderer, value))
    DrawGLPoly(value)
    gl.bindTexture(value.lightmapId)
    gl.enable(gl.GL_BLEND)
    if not gl.staticGeometryCall(value, 1) then
      gl.begin(gl.GL_POLYGON)
      for each vertex in value.vertices
        gl.texcoord2(vertex.lightS, vertex.lightT)
        gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
      end for
      gl.finishPrimitive()
    end if
    gl.disable(gl.GL_BLEND)
  end if
  return true
end function

/// Render glwater poly.
/// @param poly The poly input consumed by `DrawGLWaterPoly`.
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

/// Render glwater poly lightmap.
/// @param poly The poly input consumed by `DrawGLWaterPolyLightmap`.
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

/// Render glpoly.
/// @param poly The poly input consumed by `DrawGLPoly`.
function DrawGLPoly(poly)
  value = compatSurface(poly)
  if value is void or len(value.vertices) < 3 then return false end if
  if gl.staticGeometryCall(value, 0) then return true end if
  gl.begin(gl.GL_POLYGON)
  for each vertex in value.vertices
    gl.texcoord2(vertex.s, vertex.t)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

/// Preload and register the static geometry asset.
/// @param renderer Renderer instance or backend used for drawing.
function precacheStaticGeometry(renderer)
  if renderer is void or gl.traceEnabled() then return 0 end if
  count = 0
  index = 0
  while index < len(renderer.surfaces)
    surface = renderer.surfaces[index]
    if surface is not void and len(surface.vertices) >= 3 and (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | GLQUAKE_SURF_UNDERWATER)) == 0 then
      prepared = gl.staticGeometryPrepare(surface, 0)
      // Cache exhaustion or a driver allocation failure must never make an
      // otherwise valid BSP unloadable. Remaining surfaces stay on the
      // immediate-mode fallback path used before this startup optimization.
      if prepared < 0 then return count end if
      if prepared == 0 then
        gl.begin(gl.GL_POLYGON)
        for each vertex in surface.vertices
          gl.texcoord2(vertex.s, vertex.t)
          gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
        end for
        gl.finishPrimitive()
      end if

      prepared = gl.staticGeometryPrepare(surface, 1)
      if prepared < 0 then return count end if
      if prepared == 0 then
        gl.begin(gl.GL_POLYGON)
        for each vertex in surface.vertices
          gl.texcoord2(vertex.lightS, vertex.lightT)
          gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
        end for
        gl.finishPrimitive()
      end if

      if gl.multitextureAvailable() then
        prepared = gl.staticGeometryPrepare(surface, 2)
        if prepared < 0 then return count end if
        if prepared == 0 then
          gl.begin(gl.GL_POLYGON)
          for each vertex in surface.vertices
            gl.multiTexCoord2(0, vertex.s, vertex.t)
            gl.multiTexCoord2(1, vertex.lightS, vertex.lightT)
            gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
          end for
          gl.finishPrimitive()
        end if
      end if
      count = count + 3
    end if
    index = index + 1
  end while
  return count
end function

/// Implements the `compatSurfaceBatchKeys` operation for `miniquake.render.world` (compat surface batch keys).
/// @param surfaces The surfaces input consumed by `compatSurfaceBatchKeys`.
function compatSurfaceBatchKeys(surfaces)
  global rCompatSurfaceBatchKeys
  required = len(surfaces) * 8
  if len(rCompatSurfaceBatchKeys) != required then rCompatSurfaceBatchKeys = bytes(required) end if
  keys = rCompatSurfaceBatchKeys
  index = 0
  while index < len(surfaces)
    key = nativeRawValue(surfaces[index])
    byteio.putU32(keys, index * 8, key & 0xffffffff)
    byteio.putU32(keys, index * 8 + 4, (key >> 32) & 0xffffffff)
    index = index + 1
  end while
  return keys
end function

/// Implements the `compatMultitextureRecords` operation for `miniquake.render.world` (compat multitexture records).
/// @param surfaces The surfaces input consumed by `compatMultitextureRecords`.
/// @param surfaceCount Number of entries or units to process.
function compatMultitextureRecords(surfaces, surfaceCount)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global rCompatMtexRecordFaces, rCompatMtexRecords, rCompatMtexRecordCount, rCompatMtexRecordStamp, rCompatMtexTextureIds, rCompatMtexTextureChecked
  capacity = len(rCompatRenderer.surfaces)
  if capacity < surfaceCount then capacity = surfaceCount end if
  if len(rCompatMtexRecordFaces) < capacity then rCompatMtexRecordFaces = arrayutil.makeFilledArray(capacity, -1) end if
  if len(rCompatMtexRecords) < capacity * 16 then rCompatMtexRecords = bytes(capacity * 16) end if
  alternate = 0
  if currentTextureFrame != 0 then alternate = 1 end if
  stamp = floorValue(rCompatTime * 10.0) * 2 + alternate
  sameSurfaces = not gl.traceEnabled() and rCompatMtexRecordCount == surfaceCount
  index = 0
  while sameSurfaces and index < surfaceCount
    if rCompatMtexRecordFaces[index] != surfaces[index].faceIndex then sameSurfaces = false end if
    index = index + 1
  end while
  if sameSurfaces and stamp == rCompatMtexRecordStamp then return rCompatMtexRecords end if

  if sameSurfaces and len(rCompatMtexTextureIds) == len(rCompatRenderer.textures) then
    textureCount = len(rCompatRenderer.textures)
    if len(rCompatMtexTextureChecked) != textureCount then rCompatMtexTextureChecked = arrayutil.makeFilledArray(textureCount, false) end if
    checked = rCompatMtexTextureChecked
    textureIndex = 0
    while textureIndex < textureCount
      checked[textureIndex] = false
      textureIndex = textureIndex + 1
    end while
    changed = false
    index = 0
    while index < surfaceCount
      surface = surfaces[index]
      textureIndex = surface.textureIndex
      if textureIndex >= 0 and textureIndex < len(checked) and not checked[textureIndex] then
        checked[textureIndex] = true
        textureId = textureIdForSurface(rCompatRenderer, surface)
        if rCompatMtexTextureIds[textureIndex] != textureId then
          rCompatMtexTextureIds[textureIndex] = textureId
          changed = true
        end if
      end if
      index = index + 1
    end while
    if changed then
      index = 0
      while index < surfaceCount
        textureIndex = surfaces[index].textureIndex
        textureId = rCompatRenderer.noTextureId
        if textureIndex >= 0 and textureIndex < len(rCompatMtexTextureIds) then textureId = rCompatMtexTextureIds[textureIndex] end if
        byteio.putU32(rCompatMtexRecords, index * 16 + 8, textureId)
        index = index + 1
      end while
    end if
    rCompatMtexRecordCount = surfaceCount
    rCompatMtexRecordStamp = stamp
    return rCompatMtexRecords
  end if

  records = rCompatMtexRecords
  faces = rCompatMtexRecordFaces
  textureIds = rCompatMtexTextureIds
  if len(textureIds) != len(rCompatRenderer.textures) then textureIds = arrayutil.makeFilledArray(len(rCompatRenderer.textures), -1) end if
  index = 0
  while index < surfaceCount
    surface = surfaces[index]
    faces[index] = surface.faceIndex
    key = nativeRawValue(surface)
    offset = index * 16
    byteio.putU32(records, offset, key & 0xffffffff)
    byteio.putU32(records, offset + 4, (key >> 32) & 0xffffffff)
    textureId = textureIdForSurface(rCompatRenderer, surface)
    byteio.putU32(records, offset + 8, textureId)
    byteio.putU32(records, offset + 12, surface.lightmapId)
    if surface.textureIndex >= 0 and surface.textureIndex < len(textureIds) then textureIds[surface.textureIndex] = textureId end if
    index = index + 1
  end while
  rCompatMtexRecordFaces = faces
  rCompatMtexRecords = records
  rCompatMtexRecordCount = surfaceCount
  rCompatMtexRecordStamp = stamp
  rCompatMtexTextureIds = textureIds
  return records
end function

/// Apply the Quake-compatible r draw multitexture batch behavior.
/// @param surfaces The surfaces input consumed by `R_DrawMultitextureBatch`.
/// @param surfaceCount Number of entries or units to process.
function R_DrawMultitextureBatch(surfaces, surfaceCount)
  if surfaceCount <= 0 then return 0 end if
  surfaceIndex = 0
  while surfaceIndex < surfaceCount
    surface = surfaces[surfaceIndex]
    compatRenderDynamicLightmaps(surface, false)
    surfaceIndex = surfaceIndex + 1
  end while
  optBaseline.checkpoint("mtex_lightmaps")

  // Accumulate the complete dirty rectangle before uploading. Uploading as
  // soon as each surface changed caused the same atlas page to be sliced and
  // transferred hundreds of times on a single animated-light frame.
  if not gl.traceEnabled() then gl.activeTexture(1) end if
  page = 0
  while page < active_lightmaps
    if rCompatLightmapModified[page] then
      rectangle = rCompatLightmapRectChange[page]
      gl.bindTexture(lightmap_textures + page)
      compatUploadLightmapSubImage(page, rectangle)
      rCompatLightmapModified[page] = false
      compatResetLightmapRectangle(page)
    end if
    page = page + 1
  end while
  optBaseline.checkpoint("mtex_uploads")

  if not gl.traceEnabled() then gl.activeTexture(0) end if
  gl.textureEnvironment(gl.GL_REPLACE)
  GL_EnableMultitexture()
  useWorldProgram = not gl.traceEnabled() and gl.worldProgramAvailable()
  if useWorldProgram then
    gl.worldProgramEnable(true)
  else
    gl.textureEnvironment(gl.GL_COMBINE)
    gl.textureEnvironmentParameter(gl.GL_COMBINE_RGB, gl.GL_MODULATE)
    gl.textureEnvironmentParameter(gl.GL_SOURCE0_RGB, gl.GL_PREVIOUS)
    gl.textureEnvironmentParameter(gl.GL_OPERAND0_RGB, gl.GL_SRC_COLOR)
    gl.textureEnvironmentParameter(gl.GL_SOURCE1_RGB, gl.GL_TEXTURE)
    gl.textureEnvironmentParameter(gl.GL_OPERAND1_RGB, gl.GL_ONE_MINUS_SRC_COLOR)
  end if
  optBaseline.checkpoint("mtex_setup")

  records = compatMultitextureRecords(surfaces, surfaceCount)
  optBaseline.checkpoint("mtex_records")
  batched = gl.staticGeometryCallMultitextureBatchCount(records, surfaceCount)
  optBaseline.checkpoint("mtex_native")
  if useWorldProgram then gl.worldProgramEnable(false) end if
  GL_DisableMultitexture()
  if batched then return surfaceCount end if
  surfaceIndex = 0
  while surfaceIndex < surfaceCount
    R_DrawSequentialPoly(surfaces[surfaceIndex])
    surfaceIndex = surfaceIndex + 1
  end while
  return surfaceCount
end function

// Apply the Quake-compatible r blend lightmaps behavior.
function R_BlendLightmaps()
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if rCompatRenderer is void or rCompatRenderer.fullbright or not rCompatTextureSort or rCompatUseMultitexture then return 0 end if
  gl.depthMask(false)
  gl.blendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_COLOR)
  gl.enable(gl.GL_BLEND)
  count = 0
  page = 0
  while page < len(lightmap_polys)
    surfaces = compatFinishLightmapChain(page)
    if len(surfaces) > 0 then
      gl.bindTexture(lightmap_textures + page)
      if rCompatLightmapModified[page] then
        rectangle = rCompatLightmapRectChange[page]
        tracedUpload = false
        if gl.traceEnabled() then
          traceHash = compatHashLightmapRows(page, rectangle[1], rectangle[3])
          tracedUpload = gl.traceCommand("upload_subimage", [
            gl.GL_TEXTURE_2D, 0, 0, rectangle[1], GLQUAKE_BLOCK_WIDTH,
            rectangle[3], compatLightmapFormat(), gl.GL_UNSIGNED_BYTE, traceHash,
          ])
        end if
        if not tracedUpload then compatUploadLightmapSubImage(page, rectangle) end if
        rCompatLightmapModified[page] = false
        compatResetLightmapRectangle(page)
      end if
      batchable = len(surfaces) > 1
      if batchable then
        for each surface in surfaces
          if (surface.flags & GLQUAKE_SURF_UNDERWATER) != 0 then batchable = false end if
        end for
      end if
      batched = false
      if batchable and not gl.traceEnabled() then
        batched = gl.staticGeometryCallBatch(compatSurfaceBatchKeys(surfaces), 1)
      end if
      if not batched then
        for each surface in surfaces
          if (surface.flags & GLQUAKE_SURF_UNDERWATER) != 0 then
            DrawGLWaterPolyLightmap(surface)
          else
            if not gl.staticGeometryCall(surface, 1) then
              gl.begin(gl.GL_POLYGON)
              for each vertex in surface.vertices
                gl.texcoord2(vertex.lightS, vertex.lightT)
                gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
              end for
              gl.finishPrimitive()
            end if
          end if
        end for
      end if
      count = count + len(surfaces)
    end if
    page = page + 1
  end while
  gl.disable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.depthMask(true)
  return count
end function

/// Implements the `compatRenderDynamicLightmaps` operation for `miniquake.render.world` (compat render dynamic lightmaps).
/// @param surface The surface input consumed by `compatRenderDynamicLightmaps`.
/// @param addToChain The add to chain input consumed by `compatRenderDynamicLightmaps`.
function compatRenderDynamicLightmaps(surface, addToChain)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global c_brush_polys
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 then return false end if
  if addToChain then c_brush_polys = c_brush_polys + 1 end if
  if (value.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB)) != 0 then return false end if
  page = rCompatSurfaceLightmapPage[index]
  if addToChain then compatAddLightmapPoly(page, value) end if
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
  if rCompatSurfaceDlightFrame[index] == r_framecount or rCompatSurfaceCachedDlight[index] then changed = true end if
  if not changed then return false end if
  if not rCompatDynamic then return false end if
  rCompatLightmapModified[page] = true
  rectangle = rCompatLightmapRectChange[page]
  lightS = rCompatSurfaceLightS[index]
  lightT = rCompatSurfaceLightT[index]
  if lightT < rectangle[1] then
    if rectangle[3] != 0 then rectangle[3] = rectangle[3] + rectangle[1] - lightT end if
    rectangle[1] = lightT
  end if
  if lightS < rectangle[0] then
    if rectangle[2] != 0 then rectangle[2] = rectangle[2] + rectangle[0] - lightS end if
    rectangle[0] = lightS
  end if
  if rectangle[2] + rectangle[0] < lightS + value.lightWidth then rectangle[2] = lightS - rectangle[0] + value.lightWidth end if
  if rectangle[3] + rectangle[1] < lightT + value.lightHeight then rectangle[3] = lightT - rectangle[1] + value.lightHeight end if
  pixels = R_BuildLightMap(value, rCompatLightmapScratch, value.lightWidth * lightmap_bytes)
  compatCopySurfaceLightmapToAtlas(value, pixels)
  return true
end function

/// Apply the Quake-compatible r render dynamic lightmaps behavior.
/// @param surface The surface input consumed by `R_RenderDynamicLightmaps`.
function R_RenderDynamicLightmaps(surface)
  return compatRenderDynamicLightmaps(surface, true)
end function

/// Apply the Quake-compatible r render brush poly behavior.
/// @param surface The surface input consumed by `R_RenderBrushPoly`.
function R_RenderBrushPoly(surface)
  global c_brush_polys
  value = compatSurface(surface)
  if value is void then return false end if
  c_brush_polys = c_brush_polys + 1
  if (value.flags & c.SURF_DRAWSKY) != 0 then return EmitBothSkyLayers(value) end if
  if (value.flags & c.SURF_DRAWTURB) != 0 then
    gl.bindTexture(textureIdForSurface(rCompatRenderer, value))
    return EmitWaterPolys(value)
  end if
  gl.bindTexture(textureIdForSurface(rCompatRenderer, value))
  if (value.flags & GLQUAKE_SURF_UNDERWATER) != 0 then DrawGLWaterPoly(value) else DrawGLPoly(value) end if
  index = compatSurfaceIndex(value)
  page = rCompatSurfaceLightmapPage[index]
  compatAddLightmapPoly(page, value)
  if rCompatDynamic then compatRenderDynamicLightmaps(value, false) end if
  return true
end function

/// Implements the `compatPrepareBatchedBrushPoly` operation for `miniquake.render.world` (compat prepare batched brush poly).
/// @param surface The surface input consumed by `compatPrepareBatchedBrushPoly`.
function compatPrepareBatchedBrushPoly(surface)
  global c_brush_polys
  value = compatSurface(surface)
  if value is void then return false end if
  c_brush_polys = c_brush_polys + 1
  index = compatSurfaceIndex(value)
  page = rCompatSurfaceLightmapPage[index]
  compatAddLightmapPoly(page, value)
  if rCompatDynamic then compatRenderDynamicLightmaps(value, false) end if
  return true
end function

/// Apply the Quake-compatible r mirror chain behavior.
/// @param surface The surface input consumed by `R_MirrorChain`.
function R_MirrorChain(surface)
  global mirror, mirror_plane
  if mirror then return false end if
  mirror = true
  mirror_plane = compatPlane(surface)
  return mirror_plane is not void
end function

// Apply the Quake-compatible r draw water surfaces behavior.
function R_DrawWaterSurfaces()
  global waterchain, rCompatTextureChains
  if rCompatRenderer is void then return 0 end if
  alpha = rCompatRenderer.waterAlpha
  if alpha < 0.0 then alpha = 0.0 end if
  if alpha > 1.0 then alpha = 1.0 end if
  // Sorted opaque water was already emitted by DrawTextureChains.
  if rCompatTextureSort and alpha == 1.0 then return 0 end if

  // The world matrix is stable in this compatibility layer; the trace hash is
  // the FNV-1a value of MiniQuake's identity fixture matrix.
  if gl.traceEnabled() then gl.traceCommand("load_matrix", [2358302629]) end if
  if alpha < 1.0 then
    gl.enable(gl.GL_BLEND)
    gl.colorFloat(1.0, 1.0, 1.0, alpha)
    gl.textureEnvironment(gl.GL_MODULATE)
  end if

  count = 0
  if not rCompatTextureSort then
    for each surface in waterchain
      gl.bindTexture(textureIdForSurface(rCompatRenderer, surface))
      EmitWaterPolys(surface)
      count = count + 1
    end for
    waterchain = []
  else
    textureIndex = 0
    while textureIndex < len(rCompatTextureChains)
      chain = compatFinishTextureChain(textureIndex)
      if len(chain) > 0 and (chain[0].flags & c.SURF_DRAWTURB) != 0 then
        gl.bindTexture(textureIdForSurface(rCompatRenderer, chain[0]))
        for each surface in chain
          EmitWaterPolys(surface)
          count = count + 1
        end for
        compatClearTextureChain(textureIndex)
      end if
      textureIndex = textureIndex + 1
    end while
  end if

  if alpha < 1.0 then
    gl.textureEnvironment(gl.GL_REPLACE)
    gl.colorFloat(1.0, 1.0, 1.0, 1.0)
    gl.disable(gl.GL_BLEND)
  end if
  return count
end function

// Render texture chains.
function DrawTextureChains()
  global skychain, rCompatTextureChains
  if rCompatRenderer is void then return 0 end if
  if not rCompatTextureSort then
    GL_DisableMultitexture()
    count = 0
    if len(skychain) > 0 then
      R_DrawSkyChain(skychain)
      count = len(skychain)
      skychain = []
    end if
    return count
  end if

  count = 0
  textureIndex = 0
  while textureIndex < len(rCompatTextureChains)
    chain = compatFinishTextureChain(textureIndex)
    if len(chain) > 0 then
      first = chain[0]
      if (first.flags & c.SURF_DRAWSKY) != 0 then
        R_DrawSkyChain(chain)
        count = count + len(chain)
        compatClearTextureChain(textureIndex)
      else if textureIndex == rCompatMirrorTexture and rCompatMirrorAlpha != 1.0 then
        if not mirror then
          R_MirrorChain(first)
          rCompatMirrorChain = chain
        end if
        // Mirror surfaces are drawn only by R_DrawMirrorOverlay.  During the
        // reflected scene they are discarded to prevent recursive mirrors.
        compatClearTextureChain(textureIndex)
      else if (first.flags & c.SURF_DRAWTURB) != 0 and R_WaterPassDeferred(true, rCompatRenderer.waterAlpha) then
        // Keep this chain for R_DrawWaterSurfaces.
      else
        batchable = len(chain) > 1
        if batchable then
          for each surface in chain
            if (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | GLQUAKE_SURF_UNDERWATER)) != 0 then batchable = false end if
          end for
        end if
        batched = false
        if batchable and not gl.traceEnabled() then
          gl.bindTexture(textureIdForSurface(rCompatRenderer, first))
          batched = gl.staticGeometryCallBatch(compatSurfaceBatchKeys(chain), 0)
        end if
        if batched then
          for each surface in chain
            compatPrepareBatchedBrushPoly(surface)
          end for
          count = count + len(chain)
        else
          for each surface in chain
            R_RenderBrushPoly(surface)
            count = count + 1
          end for
        end if
        compatClearTextureChain(textureIndex)
      end if
    end if
    textureIndex = textureIndex + 1
  end while
  return count
end function

/// Return compat brush model origin derived from the active module state.
/// @param entity Entity affected by the operation.
function compatBrushModelOrigin(entity)
  result = math.subtract(rCompatViewOrigin, entity.origin)
  if entity.angles.x == 0.0 and entity.angles.y == 0.0 and entity.angles.z == 0.0 then return result end if
  vectors = math.angleVectors(entity.angles)
  temporary = result
  return t.Vec3(
    math.dot(temporary, vectors[0]),
    -math.dot(temporary, vectors[1]),
    math.dot(temporary, vectors[2]),
  )
end function

// Apply the Quake-compatible r clear lightmap chains behavior.
function R_ClearLightmapChains()
  global lightmap_polys, rCompatLightmapBuilders
  if len(lightmap_polys) != GLQUAKE_MAX_LIGHTMAPS then lightmap_polys = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, []) end if
  if len(rCompatLightmapBuilders) != GLQUAKE_MAX_LIGHTMAPS then rCompatLightmapBuilders = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, false) end if
  page = 0
  while page < GLQUAKE_MAX_LIGHTMAPS
    lightmap_polys[page] = []
    builder = rCompatLightmapBuilders[page]
    if builder is not bool then builder.count = 0 end if
    page = page + 1
  end while
  return true
end function

/// Apply the Quake-compatible r draw brush model for submodel behavior.
/// @param entity Entity affected by the operation.
/// @param submodelIndex Zero-based index of the requested entry.
function R_DrawBrushModelForSubmodel(entity, submodelIndex)
  global currentTextureFrame
  if rCompatRenderer is void or entity is void then return 0 end if
  if submodelIndex < 1 or submodelIndex >= len(rCompatRenderer.map.models) then return 0 end if
  submodel = rCompatRenderer.map.models[submodelIndex]
  modelOrigin = compatBrushModelOrigin(entity)
  previousTextureFrame = currentTextureFrame
  currentTextureFrame = entity.frame
  // MiniQuake clears the per-model lightmap chains before every bmodel.  Sharing
  // the world chains here redraws unrelated surfaces and makes the inverted
  // LUMINANCE pass observable as a large bright/dark rectangle.
  R_ClearLightmapChains()
  R_MarkBrushModelLightsForSubmodel(entity, submodelIndex)
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  // R_DrawBrushModel negates pitch before and after R_RotateForEntity in the
  // original MiniQuake source, so the observable brush-model rotation is +pitch.
  gl.rotate(entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  faceIndex = submodel.firstFace
  lastFace = faceIndex + submodel.numFaces
  count = 0
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      plane = compatPlane(surface)
      if plane is not void then
        distance = math.dot(modelOrigin, plane.normal) - plane.dist
        if R_BrushSurfaceFacesViewer(surface, distance) then
          if rCompatTextureSort then R_RenderBrushPoly(surface) else R_DrawSequentialPoly(surface) end if
          count = count + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  // R_BlendLightmaps uses GL_ZERO / GL_ONE_MINUS_SRC_COLOR for GL_LUMINANCE,
  // matching the inverted bytes produced by R_BuildLightMap.
  R_BlendLightmaps()
  gl.popMatrix()
  currentTextureFrame = previousTextureFrame
  return count
end function

/// Draw only the textured faces of one inline BSP model for the enhanced
/// additive pass; classic lightmap chains and dynamic-light marks are not
/// touched by this second draw.
/// @param entity Entity affected by the operation.
/// @param submodelIndex Zero-based index of the requested entry.
function R_DrawBrushModelEnhancedForSubmodel(entity, submodelIndex)
  global currentTextureFrame
  if rCompatRenderer is void or entity is void then return 0 end if
  if submodelIndex < 1 or submodelIndex >= len(rCompatRenderer.map.models) then return 0 end if
  submodel = rCompatRenderer.map.models[submodelIndex]
  modelOrigin = compatBrushModelOrigin(entity)
  previousTextureFrame = currentTextureFrame
  currentTextureFrame = entity.frame
  gl.pushMatrix()
  gl.translate(entity.origin.x, entity.origin.y, entity.origin.z)
  gl.rotate(entity.angles.y, 0.0, 0.0, 1.0)
  gl.rotate(entity.angles.x, 0.0, 1.0, 0.0)
  gl.rotate(entity.angles.z, 1.0, 0.0, 0.0)
  faceIndex = submodel.firstFace
  lastFace = faceIndex + submodel.numFaces
  count = 0
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      plane = compatPlane(surface)
      if plane is not void then
        distance = math.dot(modelOrigin, plane.normal) - plane.dist
        if R_BrushSurfaceFacesViewer(surface, distance) and (surface.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB | GLQUAKE_SURF_UNDERWATER)) == 0 then
          gl.bindTexture(textureIdForSurface(rCompatRenderer, surface))
          DrawGLPoly(surface)
          count = count + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  gl.popMatrix()
  currentTextureFrame = previousTextureFrame
  return count
end function

/// Ray-project an inline BSP object's complete silhouette onto arbitrary world
/// polygons. Each fan triangle is emitted only when all three rays reach a
/// compatible receiver, preventing interpolation through a BSP corner.
/// @param entity Entity affected by the operation.
/// @param submodelIndex Zero-based index of the requested entry.
/// @param floorWorldZ The floor world z input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param offsetX The offset x input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param offsetY The offset y input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param contactOnly The contact only input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param pointLightActive The point light active input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param lightX The light x input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param lightY The light y input consumed by `R_DrawBrushModelShadowForSubmodel`.
/// @param lightZ The light z input consumed by `R_DrawBrushModelShadowForSubmodel`.
function R_DrawBrushModelShadowForSubmodel(entity, submodelIndex, floorWorldZ, offsetX, offsetY, contactOnly, pointLightActive, lightX, lightY, lightZ)
  if rCompatRenderer is void or entity is void then return 0 end if
  if submodelIndex < 1 or submodelIndex >= len(rCompatRenderer.map.models) then return 0 end if
  if not rayShadow.isReady() then return 0 end if
  // Reuse the active world ray context but isolate vertex indexes per face;
  // inline BSP polygons do not share the external model's vertex numbering.
  submodel = rCompatRenderer.map.models[submodelIndex]
  rayShadow.beginProjectionSample(offsetX, offsetY)
  gl.pushMatrix()
  faceIndex = submodel.firstFace
  lastFace = faceIndex + submodel.numFaces
  count = 0
  while faceIndex < lastFace and faceIndex < len(rCompatRenderer.surfaces)
    if faceIndex >= 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      if surface is not void and len(surface.vertices) >= 3 then
        rayShadow.beginPrimitive()
        rayShadow.projectBrushVertices(surface.vertices)
        valid = true
        vertexIndex = 0
        for each vertex in surface.vertices
          if not rayShadow.projectedPointValid(vertexIndex) then valid = false end if
          vertexIndex = vertexIndex + 1
        end for
        gl.begin(gl.GL_TRIANGLES)
        triangleIndex = 1
        while valid and triangleIndex + 1 < len(surface.vertices)
          if rayShadow.receiverTriangleCompatible(0, triangleIndex, triangleIndex + 1) then
            gl.vertex3(rayShadow.projectedPointX(0), rayShadow.projectedPointY(0), rayShadow.projectedPointZ(0))
            gl.vertex3(rayShadow.projectedPointX(triangleIndex), rayShadow.projectedPointY(triangleIndex), rayShadow.projectedPointZ(triangleIndex))
            gl.vertex3(rayShadow.projectedPointX(triangleIndex + 1), rayShadow.projectedPointY(triangleIndex + 1), rayShadow.projectedPointZ(triangleIndex + 1))
            count = count + 1
          end if
          triangleIndex = triangleIndex + 1
        end while
        gl.finishPrimitive()
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  gl.popMatrix()
  return count
end function

/// Apply the Quake-compatible r draw brush model behavior.
/// @param entity Entity affected by the operation.
function R_DrawBrushModel(entity)
  if entity is void then return 0 end if
  return R_DrawBrushModelForSubmodel(entity, entity.modelIndex)
end function

/// Traverse one visible BSP subtree with frame-stable collection sizes.  The
/// public wrapper computes these values once; recursive calls no longer repeat
/// array-length and visible-mask identity checks at every node and surface.
/// @param nodeNumber The node number input consumed by `compatRecursiveWorldNode`.
/// @param nodeCount Number of entries or units to process.
/// @param surfaceCount Number of entries or units to process.
/// @param visibleFaceCount Number of entries or units to process.
/// @param useVisibleMask The use visible mask input consumed by `compatRecursiveWorldNode`.
function compatRecursiveWorldNode(nodeNumber, nodeCount, surfaceCount, visibleFaceCount, useVisibleMask)
  global skychain, waterchain, rCompatTextureChainBuilders, rCompatSequentialBuilder
  if nodeNumber < 0 or nodeNumber >= nodeCount then return 0 end if
  // GLQuake checks node->visframe before plane work and recursion.  The mask
  // is absent only in direct differential fixtures which intentionally call
  // this routine without first executing R_MarkLeaves.
  if useVisibleMask and rCompatVisibleNodes[nodeNumber] == 0 then return 0 end if
  node = rCompatRenderer.map.nodes[nodeNumber]
  plane = rCompatRenderer.map.planes[node.planeIndex]
  distance = 0.0
  if plane.type == 0 then distance = rCompatViewOrigin.x - plane.dist
  else if plane.type == 1 then distance = rCompatViewOrigin.y - plane.dist
  else if plane.type == 2 then distance = rCompatViewOrigin.z - plane.dist
  else distance = rCompatViewOrigin.x * plane.normal.x + rCompatViewOrigin.y * plane.normal.y + rCompatViewOrigin.z * plane.normal.z - plane.dist
  end if
  side = 0
  if distance < 0.0 then side = 1 end if
  firstChild = node.child0
  secondChild = node.child1
  if side == 1 then firstChild = node.child1; secondChild = node.child0 end if
  count = compatRecursiveWorldNode(firstChild, nodeCount, surfaceCount, visibleFaceCount, useVisibleMask)
  faceIndex = node.firstFace
  lastFace = faceIndex + node.numFaces
  while faceIndex < lastFace and faceIndex < surfaceCount
    if faceIndex >= 0 and faceIndex < visibleFaceCount and rCompatRenderer.visibleFaces[faceIndex] != 0 then
      surface = rCompatRenderer.surfaces[faceIndex]
      facesViewer = (surface.flags & GLQUAKE_SURF_UNDERWATER) != 0
      if not facesViewer then facesViewer = not ((distance < 0.0) != ((surface.flags & c.SURF_PLANEBACK) != 0)) end if
      if facesViewer then
        if rCompatTextureSort then
          textureIndex = surface.textureIndex
          if textureIndex >= 0 and textureIndex < len(rCompatTextureChainBuilders) then
            builder = rCompatTextureChainBuilders[textureIndex]
            if builder is bool then
              builder = arrayutil.createArrayBuilder(32)
              rCompatTextureChainBuilders[textureIndex] = builder
            end if
            arrayutil.pushArrayBuilder(builder, surface)
          end if
        else if (surface.flags & c.SURF_DRAWSKY) != 0 then
          skychain = [surface] + skychain
        else if (surface.flags & c.SURF_DRAWTURB) != 0 then
          waterchain = [surface] + waterchain
        else if rCompatCollectSequential then
          arrayutil.pushArrayBuilder(rCompatSequentialBuilder, surface)
          count = count + 1
        else
          R_DrawSequentialPoly(surface)
          count = count + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  count = count + compatRecursiveWorldNode(secondChild, nodeCount, surfaceCount, visibleFaceCount, useVisibleMask)
  return count
end function

/// Apply the Quake-compatible r recursive world node behavior.
/// @param nodeNumber The node number input consumed by `R_RecursiveWorldNode`.
function R_RecursiveWorldNode(nodeNumber)
  if rCompatRenderer is void then return 0 end if
  nodeCount = len(rCompatRenderer.map.nodes)
  surfaceCount = len(rCompatRenderer.surfaces)
  visibleFaceCount = len(rCompatRenderer.visibleFaces)
  useVisibleMask = rCompatVisibleNodeRenderer == rCompatRenderer and len(rCompatVisibleNodes) == nodeCount
  return compatRecursiveWorldNode(nodeNumber, nodeCount, surfaceCount, visibleFaceCount, useVisibleMask)
end function

// Apply the Quake-compatible r draw world behavior.
function R_DrawWorld()
  global lightmap_polys, skychain, waterchain, rCompatSequentialSurfaces, rCompatSequentialBuilder, rCompatCollectSequential
  if rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 0 end if
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  R_ClearLightmapChains()
  skychain = []
  waterchain = []
  rCompatSequentialSurfaces = []
  rCompatCollectSequential = rCompatUseMultitexture and not rCompatTextureSort
  if rCompatCollectSequential then
    sequentialBuilder = rCompatSequentialBuilder
    if sequentialBuilder is void then
      sequentialBuilder = arrayutil.createArrayBuilder(512)
      rCompatSequentialBuilder = sequentialBuilder
    end if
    sequentialBuilder.count = 0
  end if
  R_ResetTextureChains()
  optBaseline.checkpoint("world_clear")
  root = rCompatRenderer.map.models[0].headNodes[0]
  count = R_RecursiveWorldNode(root)
  optBaseline.checkpoint("world_recursive")
  collectedSequential = rCompatCollectSequential
  rCompatCollectSequential = false
  if collectedSequential then
    rCompatSequentialSurfaces = rCompatSequentialBuilder.values
    R_DrawMultitextureBatch(rCompatSequentialBuilder.values, rCompatSequentialBuilder.count)
  end if
  optBaseline.checkpoint("world_multitexture")
  count = count + DrawTextureChains()
  optBaseline.checkpoint("world_chains")
  R_BlendLightmaps()
  optBaseline.checkpoint("world_lightmaps")
  return count
end function

// Apply the Quake-compatible r mark leaves behavior.
function R_MarkLeaves()
  global r_visframecount
  if rCompatRenderer is void then return 0 end if
  r_visframecount = r_visframecount + 1
  if rCompatNoVis then return markAllVisible(rCompatRenderer) end if
  return markVisible(rCompatRenderer, rCompatViewOrigin)
end function

/// Create and initialize block.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param xOut The x out input consumed by `AllocBlock`.
/// @param yOut The y out input consumed by `AllocBlock`.
function AllocBlock(width, height, xOut, yOut)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global rCompatLightmapAllocated, allocated, active_lightmaps
  compatEnsureWorldState()
  textureNumber = 0
  while textureNumber < GLQUAKE_MAX_LIGHTMAPS
    best = GLQUAKE_BLOCK_HEIGHT
    bestX = -1
    bestY = 0
    x = 0
    while x < GLQUAKE_BLOCK_WIDTH - width
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

/// Create and initialize surface display list.
/// @param surface The surface input consumed by `BuildSurfaceDisplayList`.
function BuildSurfaceDisplayList(surface)
  global nColinElim
  value = compatSurface(surface)
  if value is void then return error(3764, "BuildSurfaceDisplayList: bad surface") end if
  // buildSurface reconstructed the exact edge loop and both texture coordinate
  // sets at model-load time. Remove strictly collinear points as MiniQuake does.
  if (value.flags & GLQUAKE_SURF_UNDERWATER) != 0 or len(value.vertices) < 3 then return value end if
  output = arrayutil.createArrayBuilder(len(value.vertices))
  count = len(value.vertices)
  index = 0
  while index < count
    previous = value.vertices[(index + count - 1) % count]
    current = value.vertices[index]
    next = value.vertices[(index + 1) % count]
    // Avoid allocating four short-lived Vec3 objects for every vertex. Apart
    // from being needlessly expensive during map upload, those nested
    // temporaries could be collected before their member reads by the current
    // MiniLang backend. Scalar normalization is byte-for-byte equivalent to
    // VectorSubtract followed by VectorNormalize, including the zero vector.
    previousPosition = previous.position
    currentPosition = current.position
    nextPosition = next.position
    direction1X = currentPosition.x - previousPosition.x
    direction1Y = currentPosition.y - previousPosition.y
    direction1Z = currentPosition.z - previousPosition.z
    direction2X = nextPosition.x - previousPosition.x
    direction2Y = nextPosition.y - previousPosition.y
    direction2Z = nextPosition.z - previousPosition.z
    length1 = native.sqrt(direction1X * direction1X + direction1Y * direction1Y + direction1Z * direction1Z)
    if length1 != 0.0 then
      inverseLength1 = 1.0 / length1
      direction1X = direction1X * inverseLength1
      direction1Y = direction1Y * inverseLength1
      direction1Z = direction1Z * inverseLength1
    end if
    length2 = native.sqrt(direction2X * direction2X + direction2Y * direction2Y + direction2Z * direction2Z)
    if length2 != 0.0 then
      inverseLength2 = 1.0 / length2
      direction2X = direction2X * inverseLength2
      direction2Y = direction2Y * inverseLength2
      direction2Z = direction2Z * inverseLength2
    end if
    collinear = compatAbs(direction1X - direction2X) <= 0.001 and compatAbs(direction1Y - direction2Y) <= 0.001 and compatAbs(direction1Z - direction2Z) <= 0.001
    if not collinear then
      arrayutil.pushArrayBuilder(output, current)
    else
      nColinElim = nColinElim + 1
    end if
    index = index + 1
  end while
  vertices = arrayutil.finishArrayBuilder(output)
  if len(vertices) >= 3 then value.vertices = vertices end if
  return value
end function

/// Mirror Quake's GL_CreateSurfaceLightmap routine and its observable state changes.
/// @param surface The surface input consumed by `GL_CreateSurfaceLightmap`.
function GL_CreateSurfaceLightmap(surface)
  value = compatSurface(surface)
  if value is void then return error(3765, "GL_CreateSurfaceLightmap: bad surface") end if
  if (value.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB)) != 0 then return 0 end if
  index = compatSurfaceIndex(value)
  xOut = [0]
  yOut = [0]
  page = AllocBlock(value.lightWidth, value.lightHeight, xOut, yOut)
  if page is error then return page end if
  if page is void then return error(3919, "lightmap page is void") end if
  rCompatSurfaceLightmapPage[index] = page
  rCompatSurfaceLightS[index] = xOut[0]
  rCompatSurfaceLightT[index] = yOut[0]
  textureName = lightmap_textures + page
  value.lightmapId = textureName
  // buildSurface already stored the exact surface-local light coordinates:
  //   localS = (rawS - textureMinS + 8) / (lightWidth * 16)
  // Convert that numerator into the shared 128x128 atlas directly.  Repeating
  // the BSP dot products here both wasted time and exposed thousands of nested
  // position-member reads during the allocation-heavy first-frame upload.
  blockX = xOut[0]
  blockY = yOut[0]
  if blockX is void then return error(3913, "atlas block x is void") end if
  if blockY is void then return error(3914, "atlas block y is void") end if
  if value.lightWidth is void then return error(3915, "atlas light width is void") end if
  if value.lightHeight is void then return error(3916, "atlas light height is void") end if
  vertexIndex = 0
  while vertexIndex < len(value.vertices)
    vertex = value.vertices[vertexIndex]
    localS = vertex.lightS
    localT = vertex.lightT
    if localS is void then return error(3911, "atlas vertex " + vertexIndex + " has void lightS") end if
    if localT is void then return error(3912, "atlas vertex " + vertexIndex + " has void lightT") end if
    localSType = typeof(localS)
    localTType = typeof(localT)
    widthType = typeof(value.lightWidth)
    heightType = typeof(value.lightHeight)
    if localSType != "int" and localSType != "float" then return error(3925, "atlas vertex " + vertexIndex + " lightS type " + localSType) end if
    if localTType != "int" and localTType != "float" then return error(3926, "atlas vertex " + vertexIndex + " lightT type " + localTType) end if
    if widthType != "int" and widthType != "float" then return error(3927, "atlas light width type " + widthType) end if
    if heightType != "int" and heightType != "float" then return error(3928, "atlas light height type " + heightType) end if
    scaledS = localS * value.lightWidth
    if scaledS is void then return error(3921, "atlas vertex " + vertexIndex + " scaled S is void") end if
    atlasS = scaledS + blockX
    scaledT = localT * value.lightHeight
    if scaledT is void then return error(3923, "atlas vertex " + vertexIndex + " scaled T is void") end if
    atlasT = scaledT + blockY
    vertex.lightS = atlasS / GLQUAKE_BLOCK_WIDTH
    vertex.lightT = atlasT / GLQUAKE_BLOCK_HEIGHT
    vertexIndex = vertexIndex + 1
  end while
  pixels = try(R_BuildLightMap(value, rCompatLightmapScratch, value.lightWidth * lightmap_bytes))
  if pixels is error then return error(3917, "initial surface pixels: " + pixels.message) end if
  copied = try(compatCopySurfaceLightmapToAtlas(value, pixels))
  if copied is error then return error(3918, "initial surface atlas copy: " + copied.message) end if
  return page
end function

// Mirror Quake's GL_BuildLightmaps routine and its observable state changes.
function GL_BuildLightmaps()
  global r_framecount, lightmap_bytes, active_lightmaps, lightmap_textures
  if rCompatRenderer is void then return 0 end if
  // A dotted assignment whose root is a package global is parsed by the
  // MiniLang frontend as a qualified global binding.  Keep a local reference
  // to the renderer before mutating its fields; the object identity is
  // unchanged and the operation remains the WorldRenderer member write used
  // by the original GL_BuildLightmaps lifecycle.
  renderer = rCompatRenderer
  R_ResetLightmapCompatibility()
  renderer.lightmaps = []
  r_framecount = 1
  lightmap_bytes = 1
  if rCompatColoredLighting is bytes then lightmap_bytes = 4 end if
  active_lightmaps = 0
  if lightmap_textures == 0 then lightmap_textures = gl.reserveTextureNames(GLQUAKE_MAX_LIGHTMAPS) end if
  count = 0
  index = 0
  while index < len(renderer.surfaces)
    surface = renderer.surfaces[index]
    created = try(GL_CreateSurfaceLightmap(surface))
    if created is error then return error(3907, "create_surface_lightmap " + index + ": " + created.message) end if
    // buildSurface has already reconstructed the render polygon.  Do not
    // allocate and replace thousands of vertex arrays while the complete BSP
    // graph is live: that path can invalidate later nested arrays in the
    // current MiniLang runtime.  Retaining redundant collinear points is
    // raster-equivalent and BuildSurfaceDisplayList remains available to the
    // compatibility oracle as the exact gl_model.c operation.
    count = count + 1
    index = index + 1
  end while
  page = 0
  while page < active_lightmaps
    textureId = lightmap_textures + page
    renderer.lightmaps = renderer.lightmaps + [textureId]
    gl.bindTexture(textureId)
    gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
    gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
    pageOffset = page * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * lightmap_bytes
    pageLength = GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT * lightmap_bytes
    tracedUpload = false
    if gl.traceEnabled() then
      tracedUpload = gl.traceCommand("upload_lightmap", [
        gl.GL_TEXTURE_2D, 0, lightmap_bytes, GLQUAKE_BLOCK_WIDTH,
        GLQUAKE_BLOCK_HEIGHT, 0, compatLightmapFormat(), gl.GL_UNSIGNED_BYTE,
        compatFnv1a(lightmaps, pageOffset, pageLength),
      ])
    end if
    if not tracedUpload then
      pagePixels = slice(lightmaps, pageOffset, pageLength)
      if rCompatColoredLighting is bytes then gl.uploadRgba(GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, pagePixels)
      else gl.uploadLuminance(GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, pagePixels)
      end if
    end if
    page = page + 1
  end while
  return count
end function

/// -----------------------------------------------------------------------------
/// gl_warp.c
/// -----------------------------------------------------------------------------
/// @param numverts The numverts input consumed by `BoundPoly`.
/// @param vertices The vertices input consumed by `BoundPoly`.
/// @param minimums The minimums input consumed by `BoundPoly`.
/// @param maximums The maximums input consumed by `BoundPoly`.

function BoundPoly(numverts, vertices, minimums, maximums)
  source = vertices
  if numverts < len(vertices) then source = arrayutil.copyArrayPrefix(vertices, numverts) end if
  bounds = glWarp.BoundPoly(source)
  sourceMinimums = bounds[0]
  sourceMaximums = bounds[1]
  if minimums is void then minimums = t.Vec3(0.0, 0.0, 0.0) end if
  if maximums is void then maximums = t.Vec3(0.0, 0.0, 0.0) end if
  minimums.x = sourceMinimums.x
  minimums.y = sourceMinimums.y
  minimums.z = sourceMinimums.z
  maximums.x = sourceMaximums.x
  maximums.y = sourceMaximums.y
  maximums.z = sourceMaximums.z
  return [minimums, maximums]
end function

/// Implements the `SubdividePolygon` operation for `miniquake.render.world` (subdivide polygon).
/// @param numverts The numverts input consumed by `SubdividePolygon`.
/// @param vertices The vertices input consumed by `SubdividePolygon`.
function SubdividePolygon(numverts, vertices)
  global rCompatWarpPolys
  source = vertices
  if numverts < len(vertices) then source = arrayutil.copyArrayPrefix(vertices, numverts) end if
  rCompatWarpPolys = glWarp.SubdividePolygon(source, glWarp.CurrentSubdivideSize())
  return rCompatWarpPolys
end function

/// Mirror Quake's GL_SubdivideSurface routine and its observable state changes.
/// @param surface The surface input consumed by `GL_SubdivideSurface`.
function GL_SubdivideSurface(surface)
  global rCompatSurfaceWarpPolys
  value = compatSurface(surface)
  if value is void then return error(3767, "GL_SubdivideSurface: bad surface") end if
  info = compatTexInfo(value)
  if info is void then return error(3770, "GL_SubdivideSurface: bad texinfo") end if
  surfaceIndex = compatSurfaceIndex(value)
  if surfaceIndex >= 0 and surfaceIndex < len(rCompatSurfaceWarpPolys) and rCompatSurfaceWarpPolys[surfaceIndex] is not void then
    return rCompatSurfaceWarpPolys[surfaceIndex]
  end if
  polygons = glWarp.GL_SubdivideSurface(value.vertices, info.s, info.t, glWarp.CurrentSubdivideSize())
  if polygons is error then return polygons end if
  if surfaceIndex >= 0 and surfaceIndex < len(rCompatSurfaceWarpPolys) then rCompatSurfaceWarpPolys[surfaceIndex] = polygons end if
  return polygons
end function

/// Add water polys to the destination state.
/// @param surface The surface input consumed by `EmitWaterPolys`.
function EmitWaterPolys(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  if rCompatAbstractSurfaceCalls then
    if gl.traceEnabled() then gl.traceCommand("emit_water", [value.flags]) end if
    return 1
  end if
  polygons = GL_SubdivideSurface(value)
  if polygons is error then return polygons end if
  for each polygon in polygons
    gl.begin(gl.GL_POLYGON)
    for each vertex in polygon
      point = vertex.position
      originalS = glWarp.warpFloat(vertex.s)
      originalT = glWarp.warpFloat(vertex.t)
      sIndex = native.trunc((originalT * 0.125 + rCompatRealtime) * GLQUAKE_TURBSCALE) & 255
      tIndex = native.trunc((originalS * 0.125 + rCompatRealtime) * GLQUAKE_TURBSCALE) & 255
      textureS = glWarp.warpFloat((originalS + glWarp.turbsin[sIndex]) / 64.0)
      textureT = glWarp.warpFloat((originalT + glWarp.turbsin[tIndex]) / 64.0)
      if enhanced.isEnabled() then
        // Interpolate the same canonical sine table in Enhanced mode. Keep the
        // scalar path allocation-free because water vertices are rebuilt every
        // rendered frame.
        sPhase = glWarp.warpFloat((originalT * 0.125 + rCompatRealtime) * GLQUAKE_TURBSCALE)
        tPhase = glWarp.warpFloat((originalS * 0.125 + rCompatRealtime) * GLQUAKE_TURBSCALE)
        textureS = glWarp.warpFloat((originalS + glWarp.InterpolatedTurb(sPhase)) / 64.0)
        textureT = glWarp.warpFloat((originalT + glWarp.InterpolatedTurb(tPhase)) / 64.0)
      end if
      gl.texcoord2(textureS, textureT)
      gl.vertex3(point.x, point.y, point.z)
    end for
    gl.finishPrimitive()
  end for
  return len(polygons)
end function

/// Add sky polys to the destination state.
/// @param surface The surface input consumed by `EmitSkyPolys`.
function EmitSkyPolys(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  polygons = GL_SubdivideSurface(value)
  if polygons is error then return polygons end if
  for each polygon in polygons
    gl.begin(gl.GL_POLYGON)
    for each vertex in polygon
      point = vertex.position
      directionX = glWarp.warpFloat(point.x - rCompatViewOrigin.x)
      directionY = glWarp.warpFloat(point.y - rCompatViewOrigin.y)
      directionZ = glWarp.warpFloat(point.z - rCompatViewOrigin.z)
      directionZ = glWarp.warpFloat(directionZ * 3.0)
      directionLength = glWarp.warpFloat(native.sqrt(directionX * directionX + directionY * directionY + directionZ * directionZ))
      textureS = 0.0
      textureT = 0.0
      if directionLength != 0.0 then
        directionScale = glWarp.warpFloat(378.0 / directionLength)
        directionX = glWarp.warpFloat(directionX * directionScale)
        directionY = glWarp.warpFloat(directionY * directionScale)
        textureS = glWarp.warpFloat((glWarp.warpFloat(speedscale) + directionX) / 128.0)
        textureT = glWarp.warpFloat((glWarp.warpFloat(speedscale) + directionY) / 128.0)
      end if
      gl.texcoord2(textureS, textureT)
      gl.vertex3(point.x, point.y, point.z)
    end for
    gl.finishPrimitive()
  end for
  return len(polygons)
end function

/// Add both sky layers to the destination state.
/// @param surface The surface input consumed by `EmitBothSkyLayers`.
function EmitBothSkyLayers(surface)
  global speedscale
  value = compatSurface(surface)
  if value is void then return false end if
  if rCompatAbstractSurfaceCalls then
    if gl.traceEnabled() then gl.traceCommand("emit_both_sky", [value.flags]) end if
    return 1
  end if
  GL_DisableMultitexture()
  if solidskytexture != 0 then gl.bindTexture(solidskytexture) end if
  speedscale = glWarp.WrappedSpeedScale(rCompatRealtime, 8.0)
  first = EmitSkyPolys(surface)
  gl.enable(gl.GL_BLEND)
  if alphaskytexture != 0 then gl.bindTexture(alphaskytexture) end if
  speedscale = glWarp.WrappedSpeedScale(rCompatRealtime, 16.0)
  second = EmitSkyPolys(surface)
  gl.disable(gl.GL_BLEND)
  return first + second
end function

/// Apply the Quake-compatible r draw sky chain behavior.
/// @param chain The chain input consumed by `R_DrawSkyChain`.
function R_DrawSkyChain(chain)
  global speedscale
  if chain is void then return 0 end if
  if t.concreteTypeNameMatches(chain, "RenderSurface", "miniquake.types.RenderSurface") then chain = [chain] end if
  if rCompatAbstractSurfaceCalls then
    if gl.traceEnabled() then gl.traceCommand("draw_sky_chain", [len(chain)]) end if
    return len(chain)
  end if
  GL_DisableMultitexture()
  count = 0
  if solidskytexture != 0 then gl.bindTexture(solidskytexture) end if
  speedscale = glWarp.WrappedSpeedScale(rCompatRealtime, 8.0)
  for each surface in chain
    EmitSkyPolys(surface)
    count = count + 1
  end for
  gl.enable(gl.GL_BLEND)
  if alphaskytexture != 0 then gl.bindTexture(alphaskytexture) end if
  speedscale = glWarp.WrappedSpeedScale(rCompatRealtime, 16.0)
  for each surface in chain
    EmitSkyPolys(surface)
  end for
  gl.disable(gl.GL_BLEND)
  return count
end function

/// Apply the Quake-compatible r init sky behavior.
/// @param texture Texture resource processed by the operation.
function R_InitSky(texture)
  global solidskytexture, alphaskytexture, rCompatSkyTexture, rCompatAlphaSkyTexture
  if rCompatRenderer is void or len(rCompatRenderer.palette) < 768 then
    return error(3769, "R_InitSky: palette is not initialized")
  end if
  pixels = glWarp.R_InitSky(texture, rCompatRenderer.palette)
  if pixels is error then return pixels end if
  solidRgba = pixels[0]
  alphaRgba = pixels[1]
  solidPrepared = draw2d.GL_UpscaleTextureRgba(solidRgba, 128, 128)
  if solidPrepared is error then return solidPrepared end if
  alphaPrepared = draw2d.GL_UpscaleTextureRgba(alphaRgba, 128, 128)
  if alphaPrepared is error then return alphaPrepared end if

  // Match MiniQuake: allocate each texture once, reuse it on later maps, use
  // internal formats 3/4, and force linear filtering for both sky layers.
  if solidskytexture == 0 then solidskytexture = gl.generateTexture() end if
  gl.bindTexture(solidskytexture)
  native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 3, solidPrepared[1], solidPrepared[2], 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, solidPrepared[0])
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)

  if alphaskytexture == 0 then alphaskytexture = gl.generateTexture() end if
  gl.bindTexture(alphaskytexture)
  native.glTexImage2D(gl.GL_TEXTURE_2D, 0, 4, alphaPrepared[1], alphaPrepared[2], 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, alphaPrepared[0])
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

/// Apply the Quake-compatible r reset light styles behavior.
/// @param value Value consumed by `R_ResetLightStyles`.
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
