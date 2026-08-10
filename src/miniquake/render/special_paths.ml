/*
Copyright (C) 2026 MiniQuake contributors

Source-guided MiniQuake 1.09 special rendering paths.  This module keeps the
mirror, z-trick, envmap and time-refresh equations in one compiler-friendly
place so the integrated renderer and isolated differential fixtures use the
same Binary32 boundaries.
*/

package miniquake.render.special_paths

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.render.gl11 as gl

const MIRROR_TEXTURE_PREFIX = "window02_1"
const ENVMAP_SIZE = 256
const ENVMAP_FACES = 6
const TIMEREFRESH_STEPS = 128

function f32(value)
  return native.bitsFloat(native.floatBits(value))
end function

function mirrorTextureName(name)
  source = bytes(name)
  prefix = bytes(MIRROR_TEXTURE_PREFIX)
  if len(source) < len(prefix) then return false end if
  index = 0
  while index < len(prefix)
    if source[index] != prefix[index] then return false end if
    index = index + 1
  end while
  return true
end function

function findMirrorTexture(textures)
  index = 0
  while index < len(textures)
    texture = textures[index]
    if texture is not void and mirrorTextureName(texture.name) then return index end if
    index = index + 1
  end while
  return -1
end function

function mirrorDistance(point, normal, distance)
  return f32(math.dot(point, normal) - distance)
end function

function reflectPoint(point, normal, distance)
  scalar = f32(-2.0 * mirrorDistance(point, normal, distance))
  return t.Vec3(
    f32(point.x + scalar * normal.x),
    f32(point.y + scalar * normal.y),
    f32(point.z + scalar * normal.z),
  )
end function

function reflectVector(direction, normal)
  scalar = f32(-2.0 * f32(math.dot(direction, normal)))
  return t.Vec3(
    f32(direction.x + scalar * normal.x),
    f32(direction.y + scalar * normal.y),
    f32(direction.z + scalar * normal.z),
  )
end function

function directionAngles(direction, sourceRoll)
  horizontal = f32(native.sqrt(f32(direction.x * direction.x + direction.y * direction.y)))
  pitch = f32(-native.atan2(direction.z, horizontal) * math.RAD_TO_DEG)
  yaw = f32(native.atan2(direction.y, direction.x) * math.RAD_TO_DEG)
  if direction.y == 0.0 and direction.x < 0.0 then yaw = 180.0 end if
  return t.Vec3(pitch, yaw, f32(-sourceRoll))
end function

function reflectView(origin, angles, plane)
  if plane is void then return error(5000, "R_Mirror: missing mirror plane") end if
  vectors = math.angleVectors(angles)
  reflectedOrigin = reflectPoint(origin, plane.normal, plane.dist)
  reflectedForward = reflectVector(vectors[0], plane.normal)
  reflectedAngles = directionAngles(reflectedForward, angles.z)
  return [reflectedOrigin, reflectedAngles, reflectedForward]
end function

function mirrorProjectionScale(plane)
  if plane is void then return t.Vec3(1.0, 1.0, 1.0) end if
  if plane.normal.z != 0.0 then return t.Vec3(1.0, -1.0, 1.0) end if
  return t.Vec3(-1.0, 1.0, 1.0)
end function

// Return [clearMask, depthMin, depthMax, depthFunction, nextTrickFrame].
function clearPlan(mirrorAlpha, clearColor, zTrick, trickFrame)
  mask = gl.GL_DEPTH_BUFFER_BIT
  if clearColor then mask = mask | gl.GL_COLOR_BUFFER_BIT end if
  if mirrorAlpha != 1.0 then
    return [mask, 0.0, 0.5, gl.GL_LEQUAL, trickFrame]
  end if
  if zTrick then
    colorMask = 0
    if clearColor then colorMask = gl.GL_COLOR_BUFFER_BIT end if
    nextFrame = trickFrame + 1
    if (nextFrame & 1) != 0 then
      return [colorMask, 0.0, f32(0.49999), gl.GL_LEQUAL, nextFrame]
    end if
    return [colorMask, 1.0, 0.5, gl.GL_GEQUAL, nextFrame]
  end if
  return [mask, 0.0, 1.0, gl.GL_LEQUAL, trickFrame]
end function

function envmapDirections()
  return [
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 90.0, 0.0),
    t.Vec3(0.0, 180.0, 0.0),
    t.Vec3(0.0, 270.0, 0.0),
    t.Vec3(-90.0, 0.0, 0.0),
    t.Vec3(90.0, 0.0, 0.0),
  ]
end function

function envmapByteCount()
  return ENVMAP_SIZE * ENVMAP_SIZE * 4
end function

function envmapFileName(index)
  return "env" + index + ".rgb"
end function

function timeRefreshYaw(index)
  return f32(f32(index * 1.0 / TIMEREFRESH_STEPS) * 360.0)
end function

function timeRefreshResult(seconds)
  value = f32(seconds)
  if value <= 0.0 then return error(5001, "R_TimeRefresh_f: non-positive duration") end if
  return [value, f32(TIMEREFRESH_STEPS / value)]
end function

function timeRefreshAngles(sourceAngles)
  result = []
  index = 0
  while index < TIMEREFRESH_STEPS
    result = result + [t.Vec3(sourceAngles.x, timeRefreshYaw(index), sourceAngles.z)]
    index = index + 1
  end while
  return result
end function


function specialRenderStageOrder()
  return [
    "clear",
    "world",
    "entities",
    "particles",
    "viewmodel",
    "water",
    "mirror_scene",
    "mirror_entities",
    "mirror_overlay",
    "polyblend",
    "ui",
    "capture_before_swap",
  ]
end function
