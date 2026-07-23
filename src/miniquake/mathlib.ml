package miniquake.mathlib

import miniquake.types as t
import miniquake.native as native

const PI = 3.141592653589793
const RAD_TO_DEG = 57.29577951308232
const DEG_TO_RAD = 0.017453292519943295

function vec3(x, y, z)
  return t.Vec3(x, y, z)
end function

function copy(value)
  return t.Vec3(value.x, value.y, value.z)
end function

function add(a, b)
  return t.Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end function

function subtract(a, b)
  return t.Vec3(a.x - b.x, a.y - b.y, a.z - b.z)
end function

function scale(value, scalar)
  return t.Vec3(value.x * scalar, value.y * scalar, value.z * scalar)
end function

function multiplyAdd(a, scalar, b)
  return t.Vec3(a.x + scalar * b.x, a.y + scalar * b.y, a.z + scalar * b.z)
end function

function dot(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end function

function cross(a, b)
  return t.Vec3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  )
end function

function lengthSquared(value)
  return dot(value, value)
end function

function length(value)
  return native.sqrt(lengthSquared(value))
end function

function normalize(value)
  magnitude = length(value)
  if magnitude == 0.0 then return t.Vec3(0.0, 0.0, 0.0) end if
  return scale(value, 1.0 / magnitude)
end function

function greatestCommonDivisor(a, b)
  if a < 0 then a = -a end if
  if b < 0 then b = -b end if
  while b != 0
    next = a % b
    a = b
    b = next
  end while
  return a
end function

function angleMod(angle)
  result = angle % 360.0
  if result < 0.0 then result = result + 360.0 end if
  return result
end function

function angleVectors(angles)
  pitch = angles.x * DEG_TO_RAD
  yaw = angles.y * DEG_TO_RAD
  roll = angles.z * DEG_TO_RAD
  sp = native.sin(pitch)
  cp = native.cos(pitch)
  sy = native.sin(yaw)
  cy = native.cos(yaw)
  sr = native.sin(roll)
  cr = native.cos(roll)
  forward = t.Vec3(cp * cy, cp * sy, -sp)
  right = t.Vec3((-sr * sp * cy) + (-cr * -sy), (-sr * sp * sy) + (-cr * cy), -sr * cp)
  up = t.Vec3((cr * sp * cy) + (-sr * -sy), (cr * sp * sy) + (-sr * cy), cr * cp)
  return [forward, right, up]
end function

function clamp(value, minimum, maximum)
  if value < minimum then return minimum end if
  if value > maximum then return maximum end if
  return value
end function

function sqrt(value)
  return native.sqrt(value)
end function

function atan2(y, x)
  return native.atan2(y, x)
end function

function sin(value)
  return native.sin(value)
end function

function cos(value)
  return native.cos(value)
end function

// Quake mathlib.c compatibility helpers.  Vec3 values replace C vec3_t
// arrays; return values replace C out-parameters.
function projectPointOnPlane(point, normal)
  denominator = dot(normal, normal)
  if denominator == 0.0 then return copy(point) end if
  inverse = 1.0 / denominator
  distance = dot(normal, point) * inverse
  scaledNormal = scale(normal, inverse)
  return subtract(point, scale(scaledNormal, distance))
end function

function perpendicularVector(source)
  // The original routine assumes source is normalized and chooses the
  // least-aligned axial vector before projecting it onto source's plane.
  absX = source.x
  if absX < 0.0 then absX = -absX end if
  absY = source.y
  if absY < 0.0 then absY = -absY end if
  absZ = source.z
  if absZ < 0.0 then absZ = -absZ end if

  axis = t.Vec3(1.0, 0.0, 0.0)
  smallest = absX
  if absY < smallest then
    smallest = absY
    axis = t.Vec3(0.0, 1.0, 0.0)
  end if
  if absZ < smallest then axis = t.Vec3(0.0, 0.0, 1.0) end if
  return normalize(projectPointOnPlane(axis, source))
end function

function rotatePointAroundVector(direction, point, degrees)
  // Rodrigues' formula is algebraically equivalent to Quake's
  // m*zrot*transpose(m) construction for the normalized direction vectors
  // used by the renderer.
  axis = copy(direction)
  axisLength = length(axis)
  if axisLength == 0.0 then return copy(point) end if
  if axisLength != 1.0 then axis = scale(axis, 1.0 / axisLength) end if

  radians = degrees * DEG_TO_RAD
  cosine = native.cos(radians)
  sine = native.sin(radians)
  along = dot(axis, point) * (1.0 - cosine)
  return add(
    add(scale(point, cosine), scale(cross(axis, point), sine)),
    scale(axis, along),
  )
end function

function boxOnPlaneSide(emins, emaxs, plane)
  // Preserve the exact BOX_ON_PLANE_SIDE axial fast path, including its
  // equality behavior.
  if plane.type == 0 then
    if plane.dist <= emins.x then return 1 end if
    if plane.dist >= emaxs.x then return 2 end if
    return 3
  end if
  if plane.type == 1 then
    if plane.dist <= emins.y then return 1 end if
    if plane.dist >= emaxs.y then return 2 end if
    return 3
  end if
  if plane.type == 2 then
    if plane.dist <= emins.z then return 1 end if
    if plane.dist >= emaxs.z then return 2 end if
    return 3
  end if

  // General case from BoxOnPlaneSide.  Selecting the two support corners
  // directly is equivalent to the original eight signbits switch cases and
  // also works for parsed BSP planes that do not store signbits explicitly.
  farX = 0.0
  nearX = 0.0
  farY = 0.0
  nearY = 0.0
  farZ = 0.0
  nearZ = 0.0
  if plane.normal.x < 0.0 then
    farX = emins.x
    nearX = emaxs.x
  else
    farX = emaxs.x
    nearX = emins.x
  end if
  if plane.normal.y < 0.0 then
    farY = emins.y
    nearY = emaxs.y
  else
    farY = emaxs.y
    nearY = emins.y
  end if
  if plane.normal.z < 0.0 then
    farZ = emins.z
    nearZ = emaxs.z
  else
    farZ = emaxs.z
    nearZ = emins.z
  end if

  distance1 = plane.normal.x * farX + plane.normal.y * farY + plane.normal.z * farZ
  distance2 = plane.normal.x * nearX + plane.normal.y * nearY + plane.normal.z * nearZ
  sides = 0
  if distance1 >= plane.dist then sides = 1 end if
  if distance2 < plane.dist then sides = sides | 2 end if
  return sides
end function

// Original public spellings retained for symbol-by-symbol parity.
function ProjectPointOnPlane(point, normal)
  return projectPointOnPlane(point, normal)
end function

function PerpendicularVector(source)
  return perpendicularVector(source)
end function

function RotatePointAroundVector(direction, point, degrees)
  return rotatePointAroundVector(direction, point, degrees)
end function

function BoxOnPlaneSide(emins, emaxs, plane)
  return boxOnPlaneSide(emins, emaxs, plane)
end function

