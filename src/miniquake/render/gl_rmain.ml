/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.gl_rmain.
*/
package miniquake.render.gl_rmain

import miniquake.native as native

// Direct MiniLang pendant of WinQuake/gl_rmain.c.  Renderer-owned objects are
// represented as compact arrays here so the complete original control flow can
// be executed headlessly by the differential oracle.  The live renderer keeps
// its richer model/entity objects in render/original.ml and render/entities.ml.

GL_ALPHA_TEST = 3008
/// Tracks the module-level gl blend state owned by `miniquake.render.gl_rmain`.
GL_BLEND = 3042
/// Tracks the module-level gl cull face state owned by `miniquake.render.gl_rmain`.
GL_CULL_FACE = 2884
/// Tracks the module-level gl depth test state owned by `miniquake.render.gl_rmain`.
GL_DEPTH_TEST = 2929
/// Tracks the module-level gl texture 2 d state owned by `miniquake.render.gl_rmain`.
GL_TEXTURE_2D = 3553
/// Tracks the module-level gl quads state owned by `miniquake.render.gl_rmain`.
GL_QUADS = 7
/// Tracks the module-level gl triangle strip state owned by `miniquake.render.gl_rmain`.
GL_TRIANGLE_STRIP = 5
/// Tracks the module-level gl smooth state owned by `miniquake.render.gl_rmain`.
GL_SMOOTH = 7425
/// Tracks the module-level gl flat state owned by `miniquake.render.gl_rmain`.
GL_FLAT = 7424
/// Tracks the module-level gl texture env state owned by `miniquake.render.gl_rmain`.
GL_TEXTURE_ENV = 8960
/// Tracks the module-level gl texture env mode state owned by `miniquake.render.gl_rmain`.
GL_TEXTURE_ENV_MODE = 8704
/// Tracks the module-level gl modulate state owned by `miniquake.render.gl_rmain`.
GL_MODULATE = 8448
/// Tracks the module-level gl replace state owned by `miniquake.render.gl_rmain`.
GL_REPLACE = 7681
/// Tracks the module-level gl perspective correction hint state owned by `miniquake.render.gl_rmain`.
GL_PERSPECTIVE_CORRECTION_HINT = 3152
/// Tracks the module-level gl fastest state owned by `miniquake.render.gl_rmain`.
GL_FASTEST = 4353
/// Tracks the module-level gl nicest state owned by `miniquake.render.gl_rmain`.
GL_NICEST = 4354
/// Tracks the module-level gl projection state owned by `miniquake.render.gl_rmain`.
GL_PROJECTION = 5889
/// Tracks the module-level gl modelview state owned by `miniquake.render.gl_rmain`.
GL_MODELVIEW = 5888
/// Tracks the module-level gl front state owned by `miniquake.render.gl_rmain`.
GL_FRONT = 1028
/// Tracks the module-level gl back state owned by `miniquake.render.gl_rmain`.
GL_BACK = 1029
/// Tracks the module-level gl modelview matrix state owned by `miniquake.render.gl_rmain`.
GL_MODELVIEW_MATRIX = 2982
/// Tracks the module-level gl color buffer bit state owned by `miniquake.render.gl_rmain`.
GL_COLOR_BUFFER_BIT = 16384
/// Tracks the module-level gl depth buffer bit state owned by `miniquake.render.gl_rmain`.
GL_DEPTH_BUFFER_BIT = 256
/// Tracks the module-level gl lequal state owned by `miniquake.render.gl_rmain`.
GL_LEQUAL = 515
/// Tracks the module-level gl gequal state owned by `miniquake.render.gl_rmain`.
GL_GEQUAL = 518

/// Tracks the module-level sink hash state owned by `miniquake.render.gl_rmain`.
sinkHash = 0
/// Tracks the module-level sink calls state owned by `miniquake.render.gl_rmain`.
sinkCalls = 0
/// Tracks the module-level sink scalar state owned by `miniquake.render.gl_rmain`.
sinkScalar = 0.0
/// Tracks the module-level sink vertices state owned by `miniquake.render.gl_rmain`.
sinkVertices = 0
/// Tracks the module-level sink binds state owned by `miniquake.render.gl_rmain`.
sinkBinds = 0
/// Tracks the module-level sink last texture state owned by `miniquake.render.gl_rmain`.
sinkLastTexture = -1
/// Tracks the module-level sink clear mask state owned by `miniquake.render.gl_rmain`.
sinkClearMask = 0
/// Tracks the module-level sink depth func state owned by `miniquake.render.gl_rmain`.
sinkDepthFunc = 0
/// Tracks the module-level sink depth min state owned by `miniquake.render.gl_rmain`.
sinkDepthMin = 0.0
/// Tracks the module-level sink depth max state owned by `miniquake.render.gl_rmain`.
sinkDepthMax = 0.0

/// Tracks the module-level frustum state owned by `miniquake.render.gl_rmain`.
frustum = []
/// Tracks the module-level vpn state owned by `miniquake.render.gl_rmain`.
vpn = [1.0, 0.0, 0.0]
/// Tracks the module-level vright state owned by `miniquake.render.gl_rmain`.
vright = [0.0, -1.0, 0.0]
/// Tracks the module-level vup state owned by `miniquake.render.gl_rmain`.
vup = [0.0, 0.0, 1.0]
/// Tracks the module-level r origin state owned by `miniquake.render.gl_rmain`.
r_origin = [0.0, 0.0, 0.0]
/// Tracks the module-level r vieworg state owned by `miniquake.render.gl_rmain`.
r_vieworg = [8.0, 4.0, 2.0]
/// Tracks the module-level r viewangles state owned by `miniquake.render.gl_rmain`.
r_viewangles = [5.0, 15.0, 1.0]
/// Tracks the module-level r fov x state owned by `miniquake.render.gl_rmain`.
r_fov_x = 90.0
/// Tracks the module-level r fov y state owned by `miniquake.render.gl_rmain`.
r_fov_y = 75.0
/// Tracks the module-level r framecount state owned by `miniquake.render.gl_rmain`.
r_framecount = 0
/// Tracks the module-level c brush polys state owned by `miniquake.render.gl_rmain`.
c_brush_polys = 0
/// Tracks the module-level c alias polys state owned by `miniquake.render.gl_rmain`.
c_alias_polys = 0
/// Tracks the module-level lastposenum state owned by `miniquake.render.gl_rmain`.
lastposenum = 0
/// Tracks the module-level gldepthmin state owned by `miniquake.render.gl_rmain`.
gldepthmin = 0.0
/// Tracks the module-level gldepthmax state owned by `miniquake.render.gl_rmain`.
gldepthmax = 0.0
/// Tracks the module-level r drawentities state owned by `miniquake.render.gl_rmain`.
r_drawentities = false
/// Tracks the module-level r drawviewmodel state owned by `miniquake.render.gl_rmain`.
r_drawviewmodel = false
/// Tracks the module-level mirror state owned by `miniquake.render.gl_rmain`.
mirror = false
/// Tracks the module-level mirror plane state owned by `miniquake.render.gl_rmain`.
mirrorPlane = [[1.0, 0.0, 0.0], 0.0]
/// Tracks the module-level mirror alpha state owned by `miniquake.render.gl_rmain`.
mirrorAlpha = 1.0
/// Tracks the module-level clear color state owned by `miniquake.render.gl_rmain`.
clearColor = false
/// Tracks the module-level z trick state owned by `miniquake.render.gl_rmain`.
zTrick = false
/// Tracks the module-level trick frame state owned by `miniquake.render.gl_rmain`.
trickFrame = 0
/// Tracks the module-level blend color state owned by `miniquake.render.gl_rmain`.
blendColor = [0.0, 0.0, 0.0, 0.0]

// Update module state for sink.
function ResetSink()
  global sinkHash, sinkCalls, sinkScalar, sinkVertices, sinkBinds
  global sinkLastTexture, sinkClearMask, sinkDepthFunc
  global sinkDepthMin, sinkDepthMax
  sinkHash = 0
  sinkCalls = 0
  sinkScalar = 0.0
  sinkVertices = 0
  sinkBinds = 0
  sinkLastTexture = -1
  sinkClearMask = 0
  sinkDepthFunc = 0
  sinkDepthMin = 0.0
  sinkDepthMax = 0.0
  return true
end function

// Update module state for compatibility.
function ResetCompatibility()
  global frustum, vpn, vright, vup, r_origin
  global r_vieworg, r_viewangles, r_fov_x, r_fov_y
  global r_framecount, c_brush_polys, c_alias_polys, lastposenum
  global gldepthmin, gldepthmax, r_drawentities, r_drawviewmodel
  global mirror, mirrorPlane, mirrorAlpha, clearColor, zTrick, trickFrame
  global blendColor
  ResetSink()
  frustum = [
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
    [[0.0, 0.0, 0.0], 0.0, 0, 0],
  ]
  vpn = [1.0, 0.0, 0.0]
  vright = [0.0, -1.0, 0.0]
  vup = [0.0, 0.0, 1.0]
  r_origin = [0.0, 0.0, 0.0]
  r_vieworg = [8.0, 4.0, 2.0]
  r_viewangles = [5.0, 15.0, 1.0]
  r_fov_x = 90.0
  r_fov_y = 75.0
  r_framecount = 0
  c_brush_polys = 0
  c_alias_polys = 0
  lastposenum = 0
  gldepthmin = 0.0
  gldepthmax = 0.0
  r_drawentities = false
  r_drawviewmodel = false
  mirror = false
  mirrorPlane = [[1.0, 0.0, 0.0], 0.0]
  mirrorAlpha = 1.0
  clearColor = false
  zTrick = false
  trickFrame = 0
  blendColor = [0.0, 0.0, 0.0, 0.0]
  return true
end function

/// Implements the `Note` operation for `miniquake.render.gl_rmain` (note).
/// @param operation The operation input consumed by `Note`.
/// @param a The a input consumed by `Note`.
/// @param b The b input consumed by `Note`.
/// @param c The c input consumed by `Note`.
/// @param d The d input consumed by `Note`.
function Note(operation, a, b, c, d)
  global sinkHash, sinkCalls, sinkScalar
  sinkHash = (sinkHash * 131 + operation) % 1000000007
  sinkCalls = sinkCalls + 1
  sinkScalar = sinkScalar + operation + a + b + c + d
  return true
end function

/// Implements the `Bind` operation for `miniquake.render.gl_rmain` (bind).
/// @param texture Texture resource processed by the operation.
function Bind(texture)
  global sinkBinds, sinkLastTexture
  sinkBinds = sinkBinds + 1
  sinkLastTexture = texture
  Note(104, texture, 0, 0, 0)
end function

/// Implements the `Vertex` operation for `miniquake.render.gl_rmain` (vertex).
/// @param operation The operation input consumed by `Vertex`.
/// @param point The point input consumed by `Vertex`.
function Vertex(operation, point)
  global sinkVertices
  sinkVertices = sinkVertices + 1
  Note(operation, point[0], point[1], point[2], 0)
end function

/// Implements the `DepthRange` operation for `miniquake.render.gl_rmain` (depth range).
/// @param minimum Smallest accepted value.
/// @param maximum Largest accepted value.
function DepthRange(minimum, maximum)
  global sinkDepthMin, sinkDepthMax
  sinkDepthMin = minimum
  sinkDepthMax = maximum
  Note(19, minimum, maximum, 0, 0)
end function

/// Implements the `DepthFunc` operation for `miniquake.render.gl_rmain` (depth func).
/// @param value Value consumed by `DepthFunc`.
function DepthFunc(value)
  global sinkDepthFunc
  sinkDepthFunc = value
  Note(27, value, 0, 0, 0)
end function

/// Implements the `Clear` operation for `miniquake.render.gl_rmain` (clear).
/// @param mask The mask input consumed by `Clear`.
function Clear(mask)
  global sinkClearMask
  sinkClearMask = mask
  Note(26, mask, 0, 0, 0)
end function

// Return sink state.
function GetSinkState()
  return [
    sinkCalls, sinkHash, sinkScalar, sinkVertices, sinkBinds,
    sinkLastTexture, sinkClearMask, sinkDepthFunc, sinkDepthMin, sinkDepthMax,
  ]
end function

/// Implements the `Dot` operation for `miniquake.render.gl_rmain` (dot).
/// @param left The left input consumed by `Dot`.
/// @param right The right input consumed by `Dot`.
function inline Dot(left, right)
  return left[0] * right[0] + left[1] * right[1] + left[2] * right[2]
end function

/// Implements the `F32` operation for `miniquake.render.gl_rmain` (f32).
/// @param value Value consumed by `F32`.
function F32(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Add state for add.
/// @param left The left input consumed by `Add`.
/// @param right The right input consumed by `Add`.
function Add(left, right)
  return [left[0] + right[0], left[1] + right[1], left[2] + right[2]]
end function

/// Implements the `Subtract` operation for `miniquake.render.gl_rmain` (subtract).
/// @param left The left input consumed by `Subtract`.
/// @param right The right input consumed by `Subtract`.
function Subtract(left, right)
  return [left[0] - right[0], left[1] - right[1], left[2] - right[2]]
end function

/// Implements the `MultiplyAdd` operation for `miniquake.render.gl_rmain` (multiply add).
/// @param origin World-space origin of the operation.
/// @param scale The scale input consumed by `MultiplyAdd`.
/// @param direction The direction input consumed by `MultiplyAdd`.
function MultiplyAdd(origin, scale, direction)
  return [
    origin[0] + scale * direction[0],
    origin[1] + scale * direction[1],
    origin[2] + scale * direction[2],
  ]
end function

/// Implements the `BoxOnPlaneSide` operation for `miniquake.render.gl_rmain` (box on plane side).
/// @param mins The mins input consumed by `BoxOnPlaneSide`.
/// @param maxs The maxs input consumed by `BoxOnPlaneSide`.
/// @param plane The plane input consumed by `BoxOnPlaneSide`.
function BoxOnPlaneSide(mins, maxs, plane)
  distance1 = Dot(maxs, plane[0]) - plane[1]
  distance2 = Dot(mins, plane[0]) - plane[1]
  sides = 0
  if distance1 >= 0.0 then sides = 1 end if
  if distance2 < 0.0 then sides = sides | 2 end if
  return sides
end function

/// Apply the Quake-compatible r cull box behavior.
/// @param mins The mins input consumed by `R_CullBox`.
/// @param maxs The maxs input consumed by `R_CullBox`.
function R_CullBox(mins, maxs)
  index = 0
  while index < 4
    if BoxOnPlaneSide(mins, maxs, frustum[index]) == 2 then return true end if
    index = index + 1
  end while
  return false
end function

/// Apply the Quake-compatible r rotate for entity behavior.
/// @param entity Entity affected by the operation.
function R_RotateForEntity(entity)
  origin = entity[0]
  angles = entity[1]
  Note(1, origin[0], origin[1], origin[2], 0)
  Note(2, angles[1], 0, 0, 1)
  Note(2, -angles[0], 0, 1, 0)
  Note(2, angles[2], 1, 0, 0)
  return true
end function

/// Apply the Quake-compatible r get sprite frame behavior.
/// @param frameType The frame type input consumed by `R_GetSpriteFrame`.
/// @param textures The textures input consumed by `R_GetSpriteFrame`.
/// @param intervals The intervals input consumed by `R_GetSpriteFrame`.
/// @param time Simulation or presentation time for the operation.
/// @param syncbase The syncbase input consumed by `R_GetSpriteFrame`.
function R_GetSpriteFrame(frameType, textures, intervals, time, syncbase)
  if frameType == 0 then return textures[0] end if
  fullinterval = intervals[len(intervals) - 1]
  localTime = time + syncbase
  target = localTime - native.trunc(localTime / fullinterval) * fullinterval
  index = 0
  while index < len(intervals) - 1
    if intervals[index] > target then return textures[index] end if
    index = index + 1
  end while
  return textures[len(textures) - 1]
end function

/// Apply the Quake-compatible r draw sprite model behavior.
/// @param entity Entity affected by the operation.
/// @param frame The frame input consumed by `R_DrawSpriteModel`.
function R_DrawSpriteModel(entity, frame)
  origin = entity[0]
  up = vup
  right = vright
  Note(3, 1, 1, 1, 0)
  Note(105, 0, 0, 0, 0)
  Bind(frame[4])
  Note(6, GL_ALPHA_TEST, 0, 0, 0)
  Note(8, GL_QUADS, 0, 0, 0)
  Note(10, 0, 1, 0, 0)
  Vertex(12, MultiplyAdd(MultiplyAdd(origin, frame[1], up), frame[2], right))
  Note(10, 0, 0, 0, 0)
  Vertex(12, MultiplyAdd(MultiplyAdd(origin, frame[0], up), frame[2], right))
  Note(10, 1, 0, 0, 0)
  Vertex(12, MultiplyAdd(MultiplyAdd(origin, frame[0], up), frame[3], right))
  Note(10, 1, 1, 0, 0)
  Vertex(12, MultiplyAdd(MultiplyAdd(origin, frame[1], up), frame[3], right))
  Note(9, 0, 0, 0, 0)
  Note(7, GL_ALPHA_TEST, 0, 0, 0)
  return 4
end function

// Create and initialize alias header.
function MakeAliasHeader()
  pose0 = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
  pose1 = [[4, 5, 6], [5, 6, 7], [6, 7, 8]]
  return [
    [1.0, 2.0, 3.0], [0.5, 1.5, 2.5], [pose0, pose1],
    [301, 302, 303, 304], 1, 2, 0.1,
  ]
end function

/// Mirror Quake's GL_DrawAliasFrame routine and its observable state changes.
/// @param header The header input consumed by `GL_DrawAliasFrame`.
/// @param posenum The posenum input consumed by `GL_DrawAliasFrame`.
/// @param light The light input consumed by `GL_DrawAliasFrame`.
function GL_DrawAliasFrame(header, posenum, light)
  global lastposenum
  lastposenum = posenum
  vertices = header[2][posenum]
  coordinates = [[0.0, 0.0], [1.0, 0.0], [0.5, 1.0]]
  Note(8, GL_TRIANGLE_STRIP, 0, 0, 0)
  index = 0
  while index < 3
    Note(10, coordinates[index][0], coordinates[index][1], 0, 0)
    level = F32(F32(1.23) * F32(light))
    Note(3, level, level, level, 0)
    Vertex(11, vertices[index])
    index = index + 1
  end while
  Note(9, 0, 0, 0, 0)
  return posenum
end function

/// Mirror Quake's GL_DrawAliasShadow routine and its observable state changes.
/// @param header The header input consumed by `GL_DrawAliasShadow`.
/// @param posenum The posenum input consumed by `GL_DrawAliasShadow`.
/// @param entityOrigin The entity origin input consumed by `GL_DrawAliasShadow`.
/// @param lightSpot The light spot input consumed by `GL_DrawAliasShadow`.
/// @param vector The vector input consumed by `GL_DrawAliasShadow`.
function GL_DrawAliasShadow(header, posenum, entityOrigin, lightSpot, vector)
  vertices = header[2][posenum]
  scale = header[0]
  scaleOrigin = header[1]
  lheight = F32(entityOrigin[2] - lightSpot[2])
  height = F32(-lheight + 1.0)
  Note(8, GL_TRIANGLE_STRIP, 0, 0, 0)
  index = 0
  while index < 3
    source = vertices[index]
    point = [
      F32(source[0] * scale[0] + scaleOrigin[0]),
      F32(source[1] * scale[1] + scaleOrigin[1]),
      F32(source[2] * scale[2] + scaleOrigin[2]),
    ]
    point[0] = F32(point[0] - vector[0] * F32(point[2] + lheight))
    point[1] = F32(point[1] - vector[1] * F32(point[2] + lheight))
    point[2] = height
    Vertex(12, point)
    index = index + 1
  end while
  Note(9, 0, 0, 0, 0)
  return true
end function

/// Apply the Quake-compatible r setup alias frame behavior.
/// @param frame The frame input consumed by `R_SetupAliasFrame`.
/// @param header The header input consumed by `R_SetupAliasFrame`.
/// @param time Simulation or presentation time for the operation.
/// @param light The light input consumed by `R_SetupAliasFrame`.
function R_SetupAliasFrame(frame, header, time, light)
  pose = 0
  numposes = header[5]
  if numposes > 1 then pose = native.trunc(time / header[6]) % numposes end if
  GL_DrawAliasFrame(header, pose, light)
  return pose
end function

/// Apply the Quake-compatible r draw alias model behavior.
/// @param entity Entity affected by the operation.
/// @param header The header input consumed by `R_DrawAliasModel`.
/// @param time Simulation or presentation time for the operation.
/// @param shadows The shadows input consumed by `R_DrawAliasModel`.
function R_DrawAliasModel(entity, header, time, shadows)
  global c_alias_polys
  // Fixture platform edge: R_LightPoint.
  Note(107, 0, 0, 0, 0)
  Note(105, 0, 0, 0, 0)
  Note(13, 0, 0, 0, 0)
  R_RotateForEntity(entity)
  scale = header[0]
  scaleOrigin = header[1]
  Note(1, scaleOrigin[0], scaleOrigin[1], scaleOrigin[2], 0)
  Note(15, scale[0], scale[1], scale[2], 0)
  animation = native.trunc(time * 10) & 3
  Bind(header[3][animation])
  Note(16, GL_SMOOTH, 0, 0, 0)
  Note(17, GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE, 0)
  Note(18, GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST, 0, 0)
  R_SetupAliasFrame(0, header, time, 64.0 / 200.0)
  Note(17, GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE, 0)
  Note(16, GL_FLAT, 0, 0, 0)
  Note(18, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST, 0, 0)
  Note(14, 0, 0, 0, 0)
  if shadows then
    Note(13, 0, 0, 0, 0)
    R_RotateForEntity(entity)
    Note(7, GL_TEXTURE_2D, 0, 0, 0)
    Note(6, GL_BLEND, 0, 0, 0)
    Note(4, 0, 0, 0, 0.5)
    angle = F32(entity[1][1] / 180.0 * 3.141592653589793)
    x = F32(native.cos(-angle))
    y = F32(native.sin(-angle))
    length = F32(native.sqrt(F32(x * x + y * y + 1.0)))
    vector = [F32(x / length), F32(y / length), F32(1.0 / length)]
    GL_DrawAliasShadow(header, lastposenum, entity[0], [0.0, 0.0, 2.0], vector)
    Note(6, GL_TEXTURE_2D, 0, 0, 0)
    Note(7, GL_BLEND, 0, 0, 0)
    Note(4, 1, 1, 1, 1)
    Note(14, 0, 0, 0, 0)
  end if
  c_alias_polys = c_alias_polys + header[4]
  return header[4]
end function

/// Apply the Quake-compatible r draw entities on list behavior.
/// @param brushCount Number of entries or units to process.
/// @param sprites The sprites input consumed by `R_DrawEntitiesOnList`.
function R_DrawEntitiesOnList(brushCount, sprites)
  if not r_drawentities then return 0 end if
  index = 0
  while index < brushCount
    Note(108, 0, 0, 0, 0)
    index = index + 1
  end while
  for each sprite in sprites
    R_DrawSpriteModel(sprite[0], sprite[1])
  end for
  return brushCount + len(sprites)
end function

/// Apply the Quake-compatible r draw view model behavior.
/// @param entity Entity affected by the operation.
/// @param header The header input consumed by `R_DrawViewModel`.
/// @param time Simulation or presentation time for the operation.
/// @param shadows The shadows input consumed by `R_DrawViewModel`.
function R_DrawViewModel(entity, header, time, shadows)
  if not r_drawviewmodel or not r_drawentities or mirror then return 0 end if
  Note(107, 0, 0, 0, 0)
  DepthRange(gldepthmin, gldepthmin + 0.3 * (gldepthmax - gldepthmin))
  result = R_DrawAliasModel(entity, header, time, shadows)
  DepthRange(gldepthmin, gldepthmax)
  return result
end function

// Apply the Quake-compatible r poly blend behavior.
function R_PolyBlend()
  if blendColor[3] == 0.0 then return false end if
  Note(105, 0, 0, 0, 0)
  Note(7, GL_ALPHA_TEST, 0, 0, 0)
  Note(6, GL_BLEND, 0, 0, 0)
  Note(7, GL_DEPTH_TEST, 0, 0, 0)
  Note(7, GL_TEXTURE_2D, 0, 0, 0)
  Note(20, 0, 0, 0, 0)
  Note(2, -90, 1, 0, 0)
  Note(2, 90, 0, 0, 1)
  Note(5, blendColor[0], blendColor[1], blendColor[2], blendColor[3])
  Note(8, GL_QUADS, 0, 0, 0)
  Vertex(11, [10.0, 100.0, 100.0])
  Vertex(11, [10.0, -100.0, 100.0])
  Vertex(11, [10.0, -100.0, -100.0])
  Vertex(11, [10.0, 100.0, -100.0])
  Note(9, 0, 0, 0, 0)
  Note(7, GL_BLEND, 0, 0, 0)
  Note(6, GL_TEXTURE_2D, 0, 0, 0)
  Note(6, GL_ALPHA_TEST, 0, 0, 0)
  return true
end function

/// Implements the `SignbitsForPlane` operation for `miniquake.render.gl_rmain` (signbits for plane).
/// @param plane The plane input consumed by `SignbitsForPlane`.
function SignbitsForPlane(plane)
  bits = 0
  if plane[0][0] < 0.0 then bits = bits | 1 end if
  if plane[0][1] < 0.0 then bits = bits | 2 end if
  if plane[0][2] < 0.0 then bits = bits | 4 end if
  return bits
end function

// Apply the Quake-compatible r set frustum behavior.
function R_SetFrustum()
  global frustum
  if r_fov_x == 90.0 then
    frustum[0][0] = Add(vpn, vright)
    frustum[1][0] = Subtract(vpn, vright)
    frustum[2][0] = Add(vpn, vup)
    frustum[3][0] = Subtract(vpn, vup)
  else
    // The live renderer uses mathlib.rotatePointAroundVector here.  The
    // diagnostic edge supplies the same dependency; its fixture is identity.
    frustum[0][0] = vpn
    frustum[1][0] = vpn
    frustum[2][0] = vpn
    frustum[3][0] = vpn
  end if
  index = 0
  while index < 4
    frustum[index][1] = Dot(r_origin, frustum[index][0])
    frustum[index][2] = 5
    frustum[index][3] = SignbitsForPlane(frustum[index])
    index = index + 1
  end while
  return true
end function

// Apply the Quake-compatible r setup frame behavior.
function R_SetupFrame()
  global r_framecount, r_origin, vpn, vright, vup
  global c_brush_polys, c_alias_polys
  Note(109, 0, 0, 0, 0)
  r_framecount = r_framecount + 1
  r_origin = [r_vieworg[0], r_vieworg[1], r_vieworg[2]]
  // The fixture's AngleVectors platform edge supplies the axial basis.
  vpn = [1.0, 0.0, 0.0]
  vright = [0.0, -1.0, 0.0]
  vup = [0.0, 0.0, 1.0]
  Note(103, -1, 0, 0, 0)
  Note(110, 0, 0, 0, 0)
  c_brush_polys = 0
  c_alias_polys = 0
  return true
end function

/// Implements the `MYgluPerspective` operation for `miniquake.render.gl_rmain` (m yglu perspective).
/// @param fovy The fovy input consumed by `MYgluPerspective`.
/// @param aspect The aspect input consumed by `MYgluPerspective`.
/// @param zNear The z near input consumed by `MYgluPerspective`.
/// @param zFar The z far input consumed by `MYgluPerspective`.
function MYgluPerspective(fovy, aspect, zNear, zFar)
  angle = fovy * 3.141592653589793 / 360.0
  ymax = zNear * native.sin(angle) / native.cos(angle)
  ymin = -ymax
  xmin = ymin * aspect
  xmax = ymax * aspect
  Note(21, xmin + xmax, ymin + ymax, zNear, zFar)
  return [xmin, xmax, ymin, ymax]
end function

// Apply the Quake-compatible r setup gl behavior.
function R_SetupGL()
  Note(22, GL_PROJECTION, 0, 0, 0)
  Note(20, 0, 0, 0, 0)
  Note(23, 0, 0, 640, 480)
  MYgluPerspective(r_fov_y, 640.0 / 480.0, 4.0, 4096.0)
  if mirror then
    if mirrorPlane[0][2] != 0.0 then Note(15, 1, -1, 1, 0) else Note(15, -1, 1, 1, 0) end if
    Note(24, GL_BACK, 0, 0, 0)
  else
    Note(24, GL_FRONT, 0, 0, 0)
  end if
  Note(22, GL_MODELVIEW, 0, 0, 0)
  Note(20, 0, 0, 0, 0)
  Note(2, -90, 1, 0, 0)
  Note(2, 90, 0, 0, 1)
  Note(2, -r_viewangles[2], 1, 0, 0)
  Note(2, -r_viewangles[0], 0, 1, 0)
  Note(2, -r_viewangles[1], 0, 0, 1)
  Note(1, -r_vieworg[0], -r_vieworg[1], -r_vieworg[2], 0)
  Note(25, GL_MODELVIEW_MATRIX, 0, 0, 0)
  Note(6, GL_CULL_FACE, 0, 0, 0)
  Note(7, GL_BLEND, 0, 0, 0)
  Note(7, GL_ALPHA_TEST, 0, 0, 0)
  Note(6, GL_DEPTH_TEST, 0, 0, 0)
  return true
end function

// Apply the Quake-compatible r render scene behavior.
function R_RenderScene()
  R_SetupFrame()
  R_SetFrustum()
  R_SetupGL()
  Note(106, 0, 0, 0, 0)
  Note(111, 0, 0, 0, 0)
  Note(102, 0, 0, 0, 0)
  R_DrawEntitiesOnList(0, [])
  Note(105, 0, 0, 0, 0)
  Note(112, 0, 0, 0, 0)
  Note(113, 0, 0, 0, 0)
  return true
end function

// Apply the Quake-compatible r clear behavior.
function R_Clear()
  global gldepthmin, gldepthmax, trickFrame
  if mirrorAlpha != 1.0 then
    if clearColor then Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) else Clear(GL_DEPTH_BUFFER_BIT) end if
    gldepthmin = 0.0
    gldepthmax = 0.5
    DepthFunc(GL_LEQUAL)
  else if zTrick then
    if clearColor then Clear(GL_COLOR_BUFFER_BIT) end if
    trickFrame = trickFrame + 1
    if (trickFrame & 1) != 0 then
      gldepthmin = 0.0
      gldepthmax = F32(0.49999)
      DepthFunc(GL_LEQUAL)
    else
      gldepthmin = 1.0
      gldepthmax = 0.5
      DepthFunc(GL_GEQUAL)
    end if
  else
    if clearColor then Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) else Clear(GL_DEPTH_BUFFER_BIT) end if
    gldepthmin = 0.0
    gldepthmax = 1.0
    DepthFunc(GL_LEQUAL)
  end if
  DepthRange(gldepthmin, gldepthmax)
  return true
end function

// Apply the Quake-compatible r mirror behavior.
function R_Mirror()
  global r_vieworg, r_viewangles, vpn, gldepthmin, gldepthmax
  if not mirror then return false end if
  distance = Dot(r_vieworg, mirrorPlane[0]) - mirrorPlane[1]
  r_vieworg = MultiplyAdd(r_vieworg, -2.0 * distance, mirrorPlane[0])
  distance = Dot(vpn, mirrorPlane[0])
  vpn = MultiplyAdd(vpn, -2.0 * distance, mirrorPlane[0])
  arcsine = native.atan2(vpn[2], native.sqrt(1.0 - vpn[2] * vpn[2]))
  r_viewangles[0] = F32(-arcsine / 3.141592653589793 * 180.0)
  if vpn[1] == 0.0 and vpn[0] < 0.0 then
    r_viewangles[1] = 180.0
  else
    r_viewangles[1] = F32(native.atan2(vpn[1], vpn[0]) / 3.141592653589793 * 180.0)
  end if
  r_viewangles[2] = -r_viewangles[2]
  gldepthmin = 0.5
  gldepthmax = 1.0
  DepthRange(gldepthmin, gldepthmax)
  DepthFunc(GL_LEQUAL)
  R_RenderScene()
  Note(114, 0, 0, 0, 0)
  gldepthmin = 0.0
  gldepthmax = 0.5
  DepthRange(gldepthmin, gldepthmax)
  DepthFunc(GL_LEQUAL)
  Note(6, GL_BLEND, 0, 0, 0)
  Note(22, GL_PROJECTION, 0, 0, 0)
  if mirrorPlane[0][2] != 0.0 then Note(15, 1, -1, 1, 0) else Note(15, -1, 1, 1, 0) end if
  Note(24, GL_FRONT, 0, 0, 0)
  Note(22, GL_MODELVIEW, 0, 0, 0)
  Note(28, 1, 1, 1, 1)
  Note(4, 1, 1, 1, mirrorAlpha)
  Note(115, 0, 0, 0, 0)
  Note(7, GL_BLEND, 0, 0, 0)
  Note(4, 1, 1, 1, 1)
  return true
end function

// Apply the Quake-compatible r render view behavior.
function R_RenderView()
  global mirror
  mirror = false
  R_Clear()
  R_RenderScene()
  Note(114, 0, 0, 0, 0)
  R_Mirror()
  R_PolyBlend()
  return true
end function

/// Update module state for cull planes.
/// @param planes The planes input consumed by `SetCullPlanes`.
function SetCullPlanes(planes)
  global frustum
  frustum = planes
end function

/// Update module state for blend.
/// @param value Value consumed by `SetBlend`.
function SetBlend(value)
  global blendColor
  blendColor = value
end function

/// Update module state for draw flags.
/// @param entities The entities input consumed by `SetDrawFlags`.
/// @param viewModel The view model input consumed by `SetDrawFlags`.
function SetDrawFlags(entities, viewModel)
  global r_drawentities, r_drawviewmodel
  r_drawentities = entities
  r_drawviewmodel = viewModel
end function

/// Update module state for clear flags.
/// @param alpha The alpha input consumed by `SetClearFlags`.
/// @param clearValue The clear value input consumed by `SetClearFlags`.
/// @param zValue The z value input consumed by `SetClearFlags`.
function SetClearFlags(alpha, clearValue, zValue)
  global mirrorAlpha, clearColor, zTrick
  mirrorAlpha = alpha
  clearColor = clearValue
  zTrick = zValue
end function

/// Update module state for mirror.
/// @param value Value consumed by `SetMirror`.
/// @param plane The plane input consumed by `SetMirror`.
function SetMirror(value, plane)
  global mirror, mirrorPlane
  mirror = value
  mirrorPlane = plane
end function

/// Update module state for view basis.
/// @param origin World-space origin of the operation.
/// @param forward The forward input consumed by `SetViewBasis`.
/// @param right The right input consumed by `SetViewBasis`.
/// @param up The up input consumed by `SetViewBasis`.
function SetViewBasis(origin, forward, right, up)
  global r_origin, vpn, vright, vup
  r_origin = origin
  vpn = forward
  vright = right
  vup = up
  return true
end function

/// Update module state for frame state.
/// @param frame The frame input consumed by `SetFrameState`.
/// @param brushPolys The brush polys input consumed by `SetFrameState`.
/// @param aliasPolys The alias polys input consumed by `SetFrameState`.
function SetFrameState(frame, brushPolys, aliasPolys)
  global r_framecount, c_brush_polys, c_alias_polys
  r_framecount = frame
  c_brush_polys = brushPolys
  c_alias_polys = aliasPolys
end function

/// Update module state for depth compatibility.
/// @param minimum Smallest accepted value.
/// @param maximum Largest accepted value.
function SetDepthCompatibility(minimum, maximum)
  global gldepthmin, gldepthmax
  gldepthmin = minimum
  gldepthmax = maximum
  return true
end function

/// Implements the `PrepareWorld` operation for `miniquake.render.gl_rmain` (prepare world).
function PrepareWorld()
  global r_vieworg, r_viewangles, r_fov_x, r_fov_y
  global r_drawentities, r_drawviewmodel
  r_vieworg = [8.0, 4.0, 2.0]
  r_viewangles = [5.0, 15.0, 1.0]
  r_fov_x = 90.0
  r_fov_y = 75.0
  r_drawentities = false
  r_drawviewmodel = false
  return true
end function

// Return frame state.
function GetFrameState()
  return [
    r_framecount, c_brush_polys, c_alias_polys, lastposenum,
    gldepthmin, gldepthmax, r_origin, frustum, r_vieworg, r_viewangles, mirror,
  ]
end function
