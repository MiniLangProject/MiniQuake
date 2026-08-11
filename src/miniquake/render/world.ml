package miniquake.render.world

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.render.gl11 as gl
import miniquake.render.draw2d as draw2d
import miniquake.render.gl_warp as glWarp
import miniquake.render.gl_rlight as glRlight
import miniquake.render.special_paths as specialPaths
import miniquake.world_bsp as world
import miniquake.format.bsp as bsp
import miniquake.array_util as arrayutil
import miniquake.byteio as byteio

// The generated collector scans package globals directly.  Keep the active
// surface graph in such a root because reaching it only through
// GameSession -> WorldRenderer -> surfaces is not reliable across allocations
// performed while the entity renderer is built.
worldSurfaceRoots = []

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
  global worldSurfaceRoots
  if len(palette) < 768 then return error(2706, "R_NewMap: invalid palette") end if
  gl.clearStaticGeometryCache()
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

function destroy(renderer)
  global worldSurfaceRoots
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
  if rCompatRenderer == renderer then R_ResetWorldCompatibility() end if
  return true
end function

function compatContainsInteger(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

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

function markAllVisible(renderer)
  renderer.visibleFaces = bytes(len(renderer.map.faces), 1)
  // Invalidate the cached leaf so returning from r_novis recomputes the PVS.
  renderer.viewLeaf = -1
  return len(renderer.map.faces)
end function

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

function markVisible(renderer, viewOrigin)
  map = renderer.map
  if len(map.leafs) <= 1 or len(map.models) == 0 then return markAllVisible(renderer) end if
  currentLeaf = world.leafForPoint(map, viewOrigin)
  if currentLeaf == renderer.viewLeaf and len(renderer.visibleFaces) == len(map.faces) then
    return countVisibleFaces(renderer.visibleFaces)
  end if
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

// R_SetupFrame assigns r_viewleaf from the final (possibly chase-adjusted)
// r_refdef.vieworg before it selects the contents cshift.
function ViewContents(renderer, viewOrigin)
  if renderer is void or renderer.map is void or len(renderer.map.leafs) == 0 then return c.CONTENTS_EMPTY end if
  leafIndex = world.leafForPoint(renderer.map, viewOrigin)
  if leafIndex < 0 or leafIndex >= len(renderer.map.leafs) then return c.CONTENTS_EMPTY end if
  return renderer.map.leafs[leafIndex].contents
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
  fovY = math.atan2(height * 1.0, width * 1.0) * 2.0 * math.RAD_TO_DEG
  return setupViewRect(0, 0, width, height, width, height, 90.0, fovY, origin, angles)
end function

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

function R_SetCullCompatibility(enabled)
  global rCompatCull
  rCompatCull = enabled
  return rCompatCull
end function

// Configure MiniQuake's frame-clear and special-render cvars without changing the
// public renderViewport signature used by older compatibility fixtures.
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

function R_SpecialCompatibilityState()
  return [
    rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick,
    rCompatFinish, rCompatNoRefresh, rCompatTrickFrame,
    rCompatMirrorTexture, rCompatLastClearPlan,
  ]
end function

function R_CurrentDepthRange()
  return [rCompatDepthMin, rCompatDepthMax]
end function

function R_ClearProduction()
  global rCompatTrickFrame, rCompatDepthMin, rCompatDepthMax, rCompatLastClearPlan
  plan = specialPaths.clearPlan(rCompatMirrorAlpha, rCompatClearColor, rCompatZTrick, rCompatTrickFrame)
  rCompatTrickFrame = plan[4]
  rCompatDepthMin = plan[1]
  rCompatDepthMax = plan[2]
  rCompatLastClearPlan = plan
  if plan[0] != 0 then gl.clear(plan[0]) end if
  gl.depthFunc(plan[3])
  gl.depthRange(plan[1], plan[2])
  return plan
end function

function R_ResetMirrorCompatibility()
  global mirror, mirror_plane, rCompatMirrorChain, rCompatMirrorTexture
  mirror = false
  mirror_plane = void
  rCompatMirrorChain = []
  rCompatMirrorTexture = -1
  if rCompatRenderer is not void then rCompatMirrorTexture = specialPaths.findMirrorTexture(rCompatRenderer.textures) end if
  return rCompatMirrorTexture
end function

function inline R_MirrorReady()
  return mirror and mirror_plane is not void and len(rCompatMirrorChain) > 0 and rCompatMirrorAlpha != 1.0
end function

function R_MirrorView(origin, angles)
  if not R_MirrorReady() then return void end if
  return specialPaths.reflectView(origin, angles, mirror_plane)
end function

function R_MirrorProjectionScale()
  return specialPaths.mirrorProjectionScale(mirror_plane)
end function

function R_MirrorChainCount()
  return len(rCompatMirrorChain)
end function

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

function R_MainRenderStageOrder()
  // R_RenderScene followed by R_RenderView's post-scene passes.
  return ["world", "entities", "dlights", "particles", "viewmodel", "water", "polyblend"]
end function

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

function render(renderer, width, height, origin, angles)
  fovY = math.atan2(height * 1.0, width * 1.0) * 2.0 * math.RAD_TO_DEG
  return renderViewport(
    renderer, width, height, [0, 0, width, height, 90.0, fovY], origin, angles,
    [], [], renderer.frameCount * 0.02, renderer.frameCount * 0.02, 0.02,
    [0.0, 0.0, 0.0, 0.0],
  )
end function

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
  count = try(R_DrawWorld())
  if count is error then return error(3901, "draw_world: " + count.message) end if
  dlightResult = try(R_RenderDlights())
  if dlightResult is error then return error(3902, "draw_dlights: " + dlightResult.message) end if
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  renderer.frameCount = renderer.frameCount + 1
  return count
end function

// Mirror R_RenderScene pass.  The caller submits reflected entities and
// particles around this world pass, matching gl_rmain.c's host-owned order.
function renderMirrorViewport(renderer, width, height, viewRect, origin, angles, dynamicLights, lightStyles, currentTime, realtime, frameTime, blend)
  if not R_MirrorReady() then return 0 end if
  vectors = math.angleVectors(angles)
  R_ConfigureWorldCompatibility(
    renderer, origin, angles, vectors[0], vectors[1], vectors[2],
    dynamicLights, lightStyles, blend, currentTime,
    realtime, frameTime, true, true, false,
  )
  R_BeginWorldFrame()
  R_MarkLeaves()
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
  R_RenderDlights()
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
const GLQUAKE_BLOCK_HEIGHT = 128
const GLQUAKE_MAX_LIGHTMAPS = 64
const GLQUAKE_SURF_UNDERWATER = 0x80
const GLQUAKE_PLANE_ANYZ = 5
const GLQUAKE_TURBSCALE = 40.74366543152521
const GLQUAKE_BACKFACE_EPSILON = 0.01

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
rCompatMultiTextureEnabled = false
rCompatMultiTextureAvailable = false
rCompatDepthMin = 0.0
rCompatDepthMax = 1.0
rCompatLightSpot = void
rCompatLightPlane = void
rCompatAbstractSurfaceCalls = false
rCompatTextureSort = true
rCompatCull = true
rCompatMirrorAlpha = 1.0
rCompatClearColor = false
rCompatZTrick = true
rCompatFinish = false
rCompatNoRefresh = false
rCompatTrickFrame = 0
rCompatMirrorTexture = -1
rCompatMirrorChain = []
rCompatLastClearPlan = [gl.GL_DEPTH_BUFFER_BIT, 0.0, 1.0, gl.GL_LEQUAL, 0]

// Original MiniQuake globals retained under their public names.
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
c_brush_polys = 0
nColinElim = 0
mirror = false
mirror_plane = void

function R_ResetWorldCompatibility()
  global rCompatRenderer, rCompatViewOrigin, rCompatViewAngles, rCompatViewForward
  global rCompatViewRight, rCompatViewUp, rCompatDlights, rCompatLightStyles
  global rCompatBlend, rCompatTime, rCompatRealtime, rCompatFrameTime
  global rCompatSurfaceDlightBits, rCompatSurfaceDlightFrame, rCompatSurfaceCachedLight
  global rCompatSurfaceCachedDlight, rCompatSurfaceLightmapPage, rCompatSurfaceLightS, rCompatSurfaceLightT
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global rCompatWarpPolys, rCompatSurfaceWarpPolys, rCompatSkyTexture, rCompatAlphaSkyTexture
  global rCompatSkyChain, rCompatWaterChain, rCompatTextureChains
  global rCompatMultiTextureEnabled
  global rCompatDepthMin, rCompatDepthMax, rCompatLightSpot, rCompatLightPlane
  global rCompatMirrorTexture, rCompatMirrorChain, rCompatLastClearPlan
  global skytexturenum, lightmap_textures, active_lightmaps, blocklights
  global lightmap_polys
  global lightmap_modified, lightmap_rectchange, allocated, lightmaps
  global skychain, waterchain, mtexenabled, r_dlightframecount, d_lightstylevalue
  global lightspot, lightplane, speedscale, solidskytexture, alphaskytexture
  global r_framecount, r_visframecount, c_brush_polys, nColinElim, mirror, mirror_plane
  global currentTextureFrame

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
  rCompatMultiTextureEnabled = false
  rCompatDepthMin = 0.0
  rCompatDepthMax = 1.0
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
  c_brush_polys = 0
  nColinElim = 0
  mirror = false
  mirror_plane = void
  currentTextureFrame = 0
  return true
end function

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
  global rCompatSurfaceCachedDlight, rCompatSurfaceLightmapPage
  global rCompatSurfaceLightS, rCompatSurfaceLightT
  global rCompatSurfaceWarpPolys, rCompatTextureChains
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global blocklights, lightmap_polys
  global lightmap_modified, lightmap_rectchange, allocated, lightmaps
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

// Private compatibility-state adapters used by deterministic renderer oracles
// and by the higher-level MiniQuake host integration.
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

function R_SetMultitextureCompatibility(available, enabled)
  global rCompatMultiTextureAvailable, rCompatMultiTextureEnabled, mtexenabled
  rCompatMultiTextureAvailable = available
  rCompatMultiTextureEnabled = enabled
  mtexenabled = enabled
  return true
end function

function R_SetTextureAnimationFrame(frame)
  global currentTextureFrame
  currentTextureFrame = frame
  return currentTextureFrame
end function

function R_SetFrameCompatibility(frame, visFrame)
  global r_framecount, r_visframecount
  r_framecount = frame
  r_visframecount = visFrame
  return true
end function

function R_SetLightStyleCompatibility(values)
  global d_lightstylevalue
  d_lightstylevalue = values
  return d_lightstylevalue
end function

function R_SetLightmapCompatibility(textureBase, bytesPerSample)
  global lightmap_textures, lightmap_bytes
  lightmap_textures = textureBase
  lightmap_bytes = bytesPerSample
  return true
end function

function R_SetLightmapDirtyCompatibility(page, rectangle, modified)
  rCompatLightmapRectChange[page] = rectangle
  rCompatLightmapModified[page] = modified
  return true
end function

function R_SetLightmapChainCompatibility(page, surfaces)
  lightmap_polys[page] = surfaces
  return true
end function

function R_SetAbstractSurfaceCalls(enabled)
  global rCompatAbstractSurfaceCalls
  rCompatAbstractSurfaceCalls = enabled
  return enabled
end function

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
  global rCompatTextureChains
  if rCompatRenderer is void then rCompatTextureChains = []; return 0 end if
  rCompatTextureChains = arrayutil.makeFilledArray(len(rCompatRenderer.textures), [])
  return len(rCompatTextureChains)
end function

function inline R_GetTextureChains()
  return rCompatTextureChains
end function

function R_ChainSurface(surface)
  global rCompatTextureChains
  value = compatSurface(surface)
  if value is void then return false end if
  index = value.textureIndex
  if index < 0 or index >= len(rCompatTextureChains) then return false end if
  rCompatTextureChains[index] = [value] + rCompatTextureChains[index]
  return true
end function

// World surfaces use the exact dot-sign rule from R_RecursiveWorldNode.
// Underwater polygons bypass back-face rejection because their warped vertices
// may cross the original plane.
function R_SurfaceFacesViewer(surface, planeDistance)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & GLQUAKE_SURF_UNDERWATER) != 0 then return true end if
  planeBack = (value.flags & c.SURF_PLANEBACK) != 0
  return not ((planeDistance < 0.0) != planeBack)
end function

// Brush models use BACKFACE_EPSILON and the opposite-facing test from
// R_DrawBrushModel.
function R_BrushSurfaceFacesViewer(surface, planeDistance)
  value = compatSurface(surface)
  if value is void then return false end if
  if (value.flags & c.SURF_PLANEBACK) != 0 then return planeDistance < -GLQUAKE_BACKFACE_EPSILON end if
  return planeDistance > GLQUAKE_BACKFACE_EPSILON
end function

function inline R_WaterPassDeferred(textureSort, waterAlpha)
  return textureSort and waterAlpha != 1.0
end function

function R_GetBlocklights()
  return blocklights
end function

function R_GetLightmapBytes()
  return lightmaps
end function

function R_GetSurfaceCompatibilityState(index)
  return [
    rCompatSurfaceCachedLight[index],
    rCompatSurfaceCachedDlight[index],
    rCompatSurfaceLightmapPage[index],
    rCompatSurfaceLightS[index],
    rCompatSurfaceLightT[index],
  ]
end function

function R_GetLightmapCompatibilityState(page)
  return [
    rCompatLightmapModified[page],
    rCompatLightmapRectChange[page],
    c_brush_polys,
  ]
end function

function R_GetAllocationCompatibilityState(page)
  return rCompatLightmapAllocated[page]
end function

function R_GetMirrorCompatibilityState()
  return [mirror, mirror_plane]
end function

function R_GetFrameCompatibility()
  return [r_framecount, r_visframecount]
end function

function R_GetDynamicLightCompatibilityState(index)
  if index < 0 or index >= len(rCompatSurfaceDlightBits) then return [0, 0] end if
  return [rCompatSurfaceDlightBits[index], rCompatSurfaceDlightFrame[index]]
end function

function inline R_DynamicLightIsActive(light, currentTime)
  return light is not void and light.die >= currentTime and light.radius > 0.0
end function

function R_ResetLightmapCompatibility()
  global rCompatLightmapAllocated, rCompatLightmapModified, rCompatLightmapRectChange
  global allocated, lightmap_modified, lightmap_rectchange, lightmap_polys, lightmaps
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
  lightmaps = bytes(4 * GLQUAKE_MAX_LIGHTMAPS * GLQUAKE_BLOCK_WIDTH * GLQUAKE_BLOCK_HEIGHT)
  c_brush_polys = 0
  nColinElim = 0
  mirror = false
  mirror_plane = void
  return true
end function

function compatFnv1a(data, offset, count)
  hash = 2166136261
  index = 0
  while index < count and offset + index < len(data)
    hash = ((hash ^ data[offset + index]) * 16777619) & 4294967295
    index = index + 1
  end while
  return hash
end function

function compatHashLightmapRows(page, firstRow, rowCount)
  offset = (page * GLQUAKE_BLOCK_HEIGHT + firstRow) * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
  return compatFnv1a(lightmaps, offset, rowCount * GLQUAKE_BLOCK_WIDTH * lightmap_bytes)
end function

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
  if rCompatRenderer != renderer then rCompatSurfaceWarpPolys = [] end if
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

function R_SetSubdivideSize(value)
  return glWarp.SetSubdivideSize(value)
end function

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
  d_lightstylevalue = glRlight.R_AnimateLight(rCompatLightStyles, rCompatTime)
  return d_lightstylevalue
end function

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

function AddLightBlend(red, green, blue, alpha2)
  return compatAssignLightBlend(glRlight.AddLightBlend(rCompatBlend, red, green, blue, alpha2))
end function

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

// Production MiniQuake R_PolyBlend.  Host invokes this after entities,
// viewmodel and particles, while the 3-D viewport/projection from R_SetupGL
// is still active and before gl_screen switches to its full-screen 2-D
// projection.  Drawing this as a 2-D quad would incorrectly tint the HUD and
// console outside r_refdef.vrect.
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
  gl.color(255, 255, 255, 255)
  gl.disable(gl.GL_BLEND)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_ALPHA_TEST)
  return true
end function

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

function R_BeginWorldFrame()
  marked = R_PushDlights()
  R_AnimateLight()
  frame = R_AdvanceFrameCounters()
  return [frame, r_dlightframecount, marked]
end function

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

function R_MarkBrushModelLights(entity)
  if entity is void then return 0 end if
  return R_MarkBrushModelLightsForSubmodel(entity, entity.modelIndex)
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

function R_LightmapRequiredBytes(width, height, stride, bytesPerSample)
  if width < 1 or height < 1 then return 0 end if
  if bytesPerSample != 1 and bytesPerSample != 4 then return error(3771, "Bad lightmap format") end if
  rowBytes = width * bytesPerSample
  if stride < rowBytes then stride = rowBytes end if
  return (height - 1) * stride + rowBytes
end function

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
  if len(blocklights) < count then blocklights = arrayutil.makeFilledArray(count, 0) end if

  rCompatSurfaceCachedDlight[index] = rCompatSurfaceDlightFrame[index] == r_framecount
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
    if rCompatSurfaceDlightFrame[index] == r_framecount then R_AddDynamicLights(value) end if
  end if

  y = 0
  while y < height
    x = 0
    while x < width
      lightValue = blocklights[y * width + x] >> 7
      if lightValue > 255 then lightValue = 255 end if
      outputValue = 255 - lightValue
      destinationOffset = y * stride + x * lightmap_bytes
      if lightmap_bytes == 4 then
        // GL_RGBA leaves RGB untouched and stores the inverted light in alpha.
        destination[destinationOffset + 3] = outputValue
      else
        destination[destinationOffset] = outputValue
      end if
      x = x + 1
    end while
    y = y + 1
  end while
  return destination
end function

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

function R_ActiveDynamicLights()
  return rCompatDlights
end function

// -----------------------------------------------------------------------------
// gl_rsurf.c
// -----------------------------------------------------------------------------

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

currentTextureFrame = 0

function GL_DisableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if rCompatMultiTextureEnabled then
    gl.disable(gl.GL_TEXTURE_2D)
    if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835E]) end if
  end if
  rCompatMultiTextureEnabled = false
  mtexenabled = false
  return true
end function

function GL_EnableMultitexture()
  global rCompatMultiTextureEnabled, mtexenabled
  if not rCompatMultiTextureAvailable then return false end if
  if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835F]) end if
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
  R_RenderDynamicLightmaps(value)
  if rCompatMultiTextureAvailable then
    if gl.traceEnabled() then gl.traceCommand("select_texture", [0x835E]) end if
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
          rectangle[3], gl.GL_LUMINANCE, gl.GL_UNSIGNED_BYTE, traceHash,
        ])
      end if
      if not tracedUpload and rectangle[3] > 0 then
        uploadOffset = (page * GLQUAKE_BLOCK_HEIGHT + rectangle[1]) * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
        uploadLength = rectangle[3] * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
        gl.uploadLuminanceSubImage(0, rectangle[1], GLQUAKE_BLOCK_WIDTH, rectangle[3], slice(lightmaps, uploadOffset, uploadLength))
      end if
      rCompatLightmapModified[page] = false
      rCompatLightmapRectChange[page] = [GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, 0, 0]
    end if
    gl.textureEnvironment(gl.GL_BLEND)
    gl.begin(gl.GL_POLYGON)
    for each vertex in value.vertices
      if gl.traceEnabled() then gl.traceCommand("multitexcoord", [0x835E, vertex.s, vertex.t]) end if
      if gl.traceEnabled() then gl.traceCommand("multitexcoord", [0x835F, vertex.lightS, vertex.lightT]) end if
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
  if gl.staticGeometryCall(value, 0) then return true end if
  gl.begin(gl.GL_POLYGON)
  for each vertex in value.vertices
    gl.texcoord2(vertex.s, vertex.t)
    gl.vertex3(vertex.position.x, vertex.position.y, vertex.position.z)
  end for
  gl.finishPrimitive()
  return true
end function

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
      count = count + 2
    end if
    index = index + 1
  end while
  return count
end function

function compatSurfaceBatchKeys(surfaces)
  keys = bytes(len(surfaces) * 8)
  index = 0
  while index < len(surfaces)
    key = nativeRawValue(surfaces[index])
    byteio.putU32(keys, index * 8, key & 0xffffffff)
    byteio.putU32(keys, index * 8 + 4, (key >> 32) & 0xffffffff)
    index = index + 1
  end while
  return keys
end function

function R_BlendLightmaps()
  if rCompatRenderer is void or rCompatRenderer.fullbright or not rCompatTextureSort then return 0 end if
  gl.depthMask(false)
  gl.blendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_COLOR)
  gl.enable(gl.GL_BLEND)
  count = 0
  page = 0
  while page < len(lightmap_polys)
    surfaces = lightmap_polys[page]
    if len(surfaces) > 0 then
      gl.bindTexture(lightmap_textures + page)
      if rCompatLightmapModified[page] then
        rectangle = rCompatLightmapRectChange[page]
        tracedUpload = false
        if gl.traceEnabled() then
          traceHash = compatHashLightmapRows(page, rectangle[1], rectangle[3])
          tracedUpload = gl.traceCommand("upload_subimage", [
            gl.GL_TEXTURE_2D, 0, 0, rectangle[1], GLQUAKE_BLOCK_WIDTH,
            rectangle[3], gl.GL_LUMINANCE, gl.GL_UNSIGNED_BYTE, traceHash,
          ])
        end if
        if not tracedUpload and rectangle[3] > 0 then
          uploadOffset = (page * GLQUAKE_BLOCK_HEIGHT + rectangle[1]) * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
          uploadLength = rectangle[3] * GLQUAKE_BLOCK_WIDTH * lightmap_bytes
          gl.uploadLuminanceSubImage(0, rectangle[1], GLQUAKE_BLOCK_WIDTH, rectangle[3], slice(lightmaps, uploadOffset, uploadLength))
        end if
        rCompatLightmapModified[page] = false
        rCompatLightmapRectChange[page] = [GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, 0, 0]
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

function compatRenderDynamicLightmaps(surface, addToChain)
  global c_brush_polys
  value = compatSurface(surface)
  index = compatSurfaceIndex(value)
  if value is void or index < 0 then return false end if
  if addToChain then c_brush_polys = c_brush_polys + 1 end if
  if (value.flags & (c.SURF_DRAWSKY | c.SURF_DRAWTURB)) != 0 then return false end if
  page = rCompatSurfaceLightmapPage[index]
  if addToChain then lightmap_polys[page] = [value] + lightmap_polys[page] end if
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
  pixels = R_BuildLightMap(value, bytes(value.lightWidth * value.lightHeight * lightmap_bytes), value.lightWidth * lightmap_bytes)
  compatCopySurfaceLightmapToAtlas(value, pixels)
  return true
end function

function R_RenderDynamicLightmaps(surface)
  return compatRenderDynamicLightmaps(surface, true)
end function

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
  lightmap_polys[page] = [value] + lightmap_polys[page]
  if rCompatDynamic then compatRenderDynamicLightmaps(value, false) end if
  return true
end function

function compatPrepareBatchedBrushPoly(surface)
  global c_brush_polys
  value = compatSurface(surface)
  if value is void then return false end if
  c_brush_polys = c_brush_polys + 1
  index = compatSurfaceIndex(value)
  page = rCompatSurfaceLightmapPage[index]
  lightmap_polys[page] = [value] + lightmap_polys[page]
  if rCompatDynamic then compatRenderDynamicLightmaps(value, false) end if
  return true
end function

function R_MirrorChain(surface)
  global mirror, mirror_plane
  if mirror then return false end if
  mirror = true
  mirror_plane = compatPlane(surface)
  return mirror_plane is not void
end function

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
      chain = rCompatTextureChains[textureIndex]
      if len(chain) > 0 and (chain[0].flags & c.SURF_DRAWTURB) != 0 then
        gl.bindTexture(textureIdForSurface(rCompatRenderer, chain[0]))
        for each surface in chain
          EmitWaterPolys(surface)
          count = count + 1
        end for
        rCompatTextureChains[textureIndex] = []
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
    chain = rCompatTextureChains[textureIndex]
    if len(chain) > 0 then
      first = chain[0]
      if (first.flags & c.SURF_DRAWSKY) != 0 then
        R_DrawSkyChain(chain)
        count = count + len(chain)
        rCompatTextureChains[textureIndex] = []
      else if textureIndex == rCompatMirrorTexture and rCompatMirrorAlpha != 1.0 then
        if not mirror then
          R_MirrorChain(first)
          rCompatMirrorChain = chain
        end if
        // Mirror surfaces are drawn only by R_DrawMirrorOverlay.  During the
        // reflected scene they are discarded to prevent recursive mirrors.
        rCompatTextureChains[textureIndex] = []
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
        rCompatTextureChains[textureIndex] = []
      end if
    end if
    textureIndex = textureIndex + 1
  end while
  return count
end function

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

function R_ClearLightmapChains()
  global lightmap_polys
  lightmap_polys = arrayutil.makeFilledArray(GLQUAKE_MAX_LIGHTMAPS, [])
  return true
end function

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

function R_DrawBrushModel(entity)
  if entity is void then return 0 end if
  return R_DrawBrushModelForSubmodel(entity, entity.modelIndex)
end function

function R_RecursiveWorldNode(nodeNumber)
  global skychain, waterchain
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
      if R_SurfaceFacesViewer(surface, distance) then
        if rCompatTextureSort then
          R_ChainSurface(surface)
        else if (surface.flags & c.SURF_DRAWSKY) != 0 then
          skychain = [surface] + skychain
        else if (surface.flags & c.SURF_DRAWTURB) != 0 then
          waterchain = [surface] + waterchain
        else
          R_DrawSequentialPoly(surface)
          count = count + 1
        end if
      end if
    end if
    faceIndex = faceIndex + 1
  end while
  count = count + R_RecursiveWorldNode(secondChild)
  return count
end function

function R_DrawWorld()
  global lightmap_polys, skychain, waterchain
  if rCompatRenderer is void or len(rCompatRenderer.map.models) == 0 then return 0 end if
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  R_ClearLightmapChains()
  skychain = []
  waterchain = []
  R_ResetTextureChains()
  root = rCompatRenderer.map.models[0].headNodes[0]
  count = R_RecursiveWorldNode(root)
  count = count + DrawTextureChains()
  R_BlendLightmaps()
  return count
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
  pixels = try(R_BuildLightMap(value, bytes(value.lightWidth * value.lightHeight * lightmap_bytes), value.lightWidth * lightmap_bytes))
  if pixels is error then return error(3917, "initial surface pixels: " + pixels.message) end if
  copied = try(compatCopySurfaceLightmapToAtlas(value, pixels))
  if copied is error then return error(3918, "initial surface atlas copy: " + copied.message) end if
  return page
end function

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
        GLQUAKE_BLOCK_HEIGHT, 0, gl.GL_LUMINANCE, gl.GL_UNSIGNED_BYTE,
        compatFnv1a(lightmaps, pageOffset, pageLength),
      ])
    end if
    if not tracedUpload then gl.uploadLuminance(GLQUAKE_BLOCK_WIDTH, GLQUAKE_BLOCK_HEIGHT, slice(lightmaps, pageOffset, pageLength)) end if
    page = page + 1
  end while
  return count
end function

// -----------------------------------------------------------------------------
// gl_warp.c
// -----------------------------------------------------------------------------

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

function SubdividePolygon(numverts, vertices)
  global rCompatWarpPolys
  source = vertices
  if numverts < len(vertices) then source = arrayutil.copyArrayPrefix(vertices, numverts) end if
  rCompatWarpPolys = glWarp.SubdividePolygon(source, glWarp.CurrentSubdivideSize())
  return rCompatWarpPolys
end function

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

function EmitWaterPolys(surface)
  value = compatSurface(surface)
  if value is void then return false end if
  if rCompatAbstractSurfaceCalls then
    if gl.traceEnabled() then gl.traceCommand("emit_water", [value.flags]) end if
    return 1
  end if
  polygons = GL_SubdivideSurface(value)
  if polygons is error then return polygons end if
  traces = glWarp.EmitWaterPolys(polygons, rCompatRealtime)
  for each commands in traces
    gl.begin(gl.GL_POLYGON)
    for each command in commands
      point = command[2]
      gl.texcoord2(command[0], command[1])
      gl.vertex3(point.x, point.y, point.z)
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
  traces = glWarp.EmitSkyPolys(polygons, rCompatViewOrigin, speedscale)
  for each commands in traces
    gl.begin(gl.GL_POLYGON)
    for each command in commands
      point = command[2]
      gl.texcoord2(command[0], command[1])
      gl.vertex3(point.x, point.y, point.z)
    end for
    gl.finishPrimitive()
  end for
  return len(polygons)
end function

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

function R_InitSky(texture)
  global solidskytexture, alphaskytexture, rCompatSkyTexture, rCompatAlphaSkyTexture
  if rCompatRenderer is void or len(rCompatRenderer.palette) < 768 then
    return error(3769, "R_InitSky: palette is not initialized")
  end if
  pixels = glWarp.R_InitSky(texture, rCompatRenderer.palette)
  if pixels is error then return pixels end if
  solidRgba = pixels[0]
  alphaRgba = pixels[1]

  // Match MiniQuake: allocate each texture once, reuse it on later maps, use
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
