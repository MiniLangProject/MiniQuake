/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.mathlib.
*/
package miniquake.mathlib

import miniquake.types as t
import miniquake.native as native
import std.math as smath

const PI = 3.14159265358979323846
const RAD_TO_DEG = 57.29577951308232
const DEG_TO_RAD = 0.017453292519943295
const NAN_MASK = 0x7f800000

// Provide vec3 behavior for the active subsystem.
function vec3(x, y, z)
  return t.Vec3(x, y, z)
end function

// Return vec3 origin derived from the active module state.
function vec3Origin()
  return t.Vec3(0.0, 0.0, 0.0)
end function

// mathlib.h macro counterparts.
function inline DotProduct(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end function

// Provide vector subtract behavior for the active subsystem.
function VectorSubtract(a, b)
  return t.Vec3(a.x - b.x, a.y - b.y, a.z - b.z)
end function

// Provide vector add behavior for the active subsystem.
function VectorAdd(a, b)
  return t.Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end function

// Provide vector copy behavior for the active subsystem.
function VectorCopy(value)
  return t.Vec3(value.x, value.y, value.z)
end function

// Report whether is nan.
function IS_NAN(value)
  return (native.floatBits(value) & NAN_MASK) == NAN_MASK
end function

// Existing MiniQuake convenience spellings preserve value semantics.
function copy(value)
  return VectorCopy(value)
end function

// Add state for add.
function add(a, b)
  return VectorAdd(a, b)
end function

// Provide subtract behavior for the active subsystem.
function subtract(a, b)
  return VectorSubtract(a, b)
end function

// Provide scale behavior for the active subsystem.
function scale(value, scalar)
  return VectorScale(value, scalar)
end function

// Provide multiply add behavior for the active subsystem.
function multiplyAdd(a, scalar, b)
  return VectorMA(a, scalar, b)
end function

// Provide dot behavior for the active subsystem.
function dot(a, b)
  return DotProduct(a, b)
end function

// Provide cross behavior for the active subsystem.
function cross(a, b)
  return CrossProduct(a, b)
end function

// Return length squared for the active module state.
function lengthSquared(value)
  return DotProduct(value, value)
end function

// Return length derived from the active module state.
function length(value)
  return Length(value)
end function

// Convert the requested value into its canonical representation.
function normalize(value)
  result = VectorCopy(value)
  VectorNormalize(result)
  return result
end function

// Return a validated clamp value.
function clamp(value, minimum, maximum)
  if value < minimum then return minimum end if
  if value > maximum then return maximum end if
  return value
end function

// Provide sqrt behavior for the active subsystem.
function sqrt(value)
  return native.sqrt(value)
end function

// Provide atan2 behavior for the active subsystem.
function atan2(y, x)
  return native.atan2(y, x)
end function

// Provide sin behavior for the active subsystem.
function sin(value)
  return native.sin(value)
end function

// Provide cos behavior for the active subsystem.
function cos(value)
  return native.cos(value)
end function

// Provide project point on plane behavior for the active subsystem.
function ProjectPointOnPlane(point, normal)
  inverseDenominator = 1.0 / DotProduct(normal, normal)
  distance = DotProduct(normal, point) * inverseDenominator
  normalized = t.Vec3(
    normal.x * inverseDenominator,
    normal.y * inverseDenominator,
    normal.z * inverseDenominator,
  )
  return t.Vec3(
    point.x - distance * normalized.x,
    point.y - distance * normalized.y,
    point.z - distance * normalized.z,
  )
end function

// Provide project point on plane behavior for the active subsystem.
function projectPointOnPlane(point, normal)
  return ProjectPointOnPlane(point, normal)
end function

// Return perpendicular vector derived from the active module state.
function PerpendicularVector(source)
  position = 0
  minimumElement = 1.0
  sourceValues = [source.x, source.y, source.z]
  index = 0
  while index < 3
    magnitude = sourceValues[index]
    if magnitude < 0.0 then magnitude = -magnitude end if
    if magnitude < minimumElement then
      position = index
      minimumElement = magnitude
    end if
    index = index + 1
  end while
  temporary = t.Vec3(0.0, 0.0, 0.0)
  if position == 0 then temporary.x = 1.0 end if
  if position == 1 then temporary.y = 1.0 end if
  if position == 2 then temporary.z = 1.0 end if
  result = ProjectPointOnPlane(temporary, source)
  VectorNormalize(result)
  return result
end function

// Return perpendicular vector derived from the active module state.
function perpendicularVector(source)
  return PerpendicularVector(source)
end function

// Apply the Quake-compatible r concat rotations behavior.
function R_ConcatRotations(first, second)
  return [
    [
      first[0][0] * second[0][0] + first[0][1] * second[1][0] + first[0][2] * second[2][0],
      first[0][0] * second[0][1] + first[0][1] * second[1][1] + first[0][2] * second[2][1],
      first[0][0] * second[0][2] + first[0][1] * second[1][2] + first[0][2] * second[2][2],
    ],
    [
      first[1][0] * second[0][0] + first[1][1] * second[1][0] + first[1][2] * second[2][0],
      first[1][0] * second[0][1] + first[1][1] * second[1][1] + first[1][2] * second[2][1],
      first[1][0] * second[0][2] + first[1][1] * second[1][2] + first[1][2] * second[2][2],
    ],
    [
      first[2][0] * second[0][0] + first[2][1] * second[1][0] + first[2][2] * second[2][0],
      first[2][0] * second[0][1] + first[2][1] * second[1][1] + first[2][2] * second[2][1],
      first[2][0] * second[0][2] + first[2][1] * second[1][2] + first[2][2] * second[2][2],
    ],
  ]
end function

// Return rotate point around vector derived from the active module state.
function RotatePointAroundVector(direction, point, degrees)
  forward = VectorCopy(direction)
  right = PerpendicularVector(direction)
  up = CrossProduct(right, forward)
  matrix = [
    [right.x, up.x, forward.x],
    [right.y, up.y, forward.y],
    [right.z, up.z, forward.z],
  ]
  inverse = [
    [matrix[0][0], matrix[1][0], matrix[2][0]],
    [matrix[0][1], matrix[1][1], matrix[2][1]],
    [matrix[0][2], matrix[1][2], matrix[2][2]],
  ]
  radians = degrees * PI / 180.0
  sine = native.sin(radians)
  cosine = native.cos(radians)
  zRotation = [
    [cosine, sine, 0.0],
    [-sine, cosine, 0.0],
    [0.0, 0.0, 1.0],
  ]
  temporary = R_ConcatRotations(matrix, zRotation)
  rotation = R_ConcatRotations(temporary, inverse)
  return t.Vec3(
    rotation[0][0] * point.x + rotation[0][1] * point.y + rotation[0][2] * point.z,
    rotation[1][0] * point.x + rotation[1][1] * point.y + rotation[1][2] * point.z,
    rotation[2][0] * point.x + rotation[2][1] * point.y + rotation[2][2] * point.z,
  )
end function

// Return rotate point around vector derived from the active module state.
function rotatePointAroundVector(direction, point, degrees)
  return RotatePointAroundVector(direction, point, degrees)
end function

// Provide anglemod behavior for the active subsystem.
function anglemod(angle)
  quantized = native.trunc(angle * (65536.0 / 360.0)) & 65535
  return (360.0 / 65536.0) * quantized
end function

// Provide angle mod behavior for the active subsystem.
function angleMod(angle)
  return anglemod(angle)
end function

// Mirror Quake's BOPS_Error routine and its observable state changes.
function BOPS_Error()
  return error(2500, "BoxOnPlaneSide: Bad signbits")
end function

// Provide box on plane side behavior for the active subsystem.
function BoxOnPlaneSide(emins, emaxs, plane)
  distance1 = 0.0
  distance2 = 0.0
  signBits = plane.signBits
  if signBits == 0 then
    distance1 = plane.normal.x * emaxs.x + plane.normal.y * emaxs.y + plane.normal.z * emaxs.z
    distance2 = plane.normal.x * emins.x + plane.normal.y * emins.y + plane.normal.z * emins.z
  else if signBits == 1 then
    distance1 = plane.normal.x * emins.x + plane.normal.y * emaxs.y + plane.normal.z * emaxs.z
    distance2 = plane.normal.x * emaxs.x + plane.normal.y * emins.y + plane.normal.z * emins.z
  else if signBits == 2 then
    distance1 = plane.normal.x * emaxs.x + plane.normal.y * emins.y + plane.normal.z * emaxs.z
    distance2 = plane.normal.x * emins.x + plane.normal.y * emaxs.y + plane.normal.z * emins.z
  else if signBits == 3 then
    distance1 = plane.normal.x * emins.x + plane.normal.y * emins.y + plane.normal.z * emaxs.z
    distance2 = plane.normal.x * emaxs.x + plane.normal.y * emaxs.y + plane.normal.z * emins.z
  else if signBits == 4 then
    distance1 = plane.normal.x * emaxs.x + plane.normal.y * emaxs.y + plane.normal.z * emins.z
    distance2 = plane.normal.x * emins.x + plane.normal.y * emins.y + plane.normal.z * emaxs.z
  else if signBits == 5 then
    distance1 = plane.normal.x * emins.x + plane.normal.y * emaxs.y + plane.normal.z * emins.z
    distance2 = plane.normal.x * emaxs.x + plane.normal.y * emins.y + plane.normal.z * emaxs.z
  else if signBits == 6 then
    distance1 = plane.normal.x * emaxs.x + plane.normal.y * emins.y + plane.normal.z * emins.z
    distance2 = plane.normal.x * emins.x + plane.normal.y * emaxs.y + plane.normal.z * emaxs.z
  else if signBits == 7 then
    distance1 = plane.normal.x * emins.x + plane.normal.y * emins.y + plane.normal.z * emins.z
    distance2 = plane.normal.x * emaxs.x + plane.normal.y * emaxs.y + plane.normal.z * emaxs.z
  else
    return BOPS_Error()
  end if

  sides = 0
  if distance1 >= plane.dist then sides = 1 end if
  if distance2 < plane.dist then sides = sides | 2 end if
  return sides
end function

// Mirror Quake's BOX_ON_PLANE_SIDE routine and its observable state changes.
function BOX_ON_PLANE_SIDE(emins, emaxs, plane)
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
  return BoxOnPlaneSide(emins, emaxs, plane)
end function

// Provide box on plane side behavior for the active subsystem.
function boxOnPlaneSide(emins, emaxs, plane)
  return BOX_ON_PLANE_SIDE(emins, emaxs, plane)
end function

// Provide angle vectors behavior for the active subsystem.
function AngleVectors(angles)
  yawAngle = angles.y * (PI * 2.0 / 360.0)
  yawSine = native.sin(yawAngle)
  yawCosine = native.cos(yawAngle)
  pitchAngle = angles.x * (PI * 2.0 / 360.0)
  pitchSine = native.sin(pitchAngle)
  pitchCosine = native.cos(pitchAngle)
  rollAngle = angles.z * (PI * 2.0 / 360.0)
  rollSine = native.sin(rollAngle)
  rollCosine = native.cos(rollAngle)

  // Allocate the result container before its three heap-backed Vec3 values.
  // Returning [forward, right, up] directly can trigger collection while the
  // array literal is being populated after a large level load, leaving an
  // earlier vector live only in an unevaluated array element.
  vectors = [void, void, void]
  vectors[0] = t.Vec3(pitchCosine * yawCosine, pitchCosine * yawSine, -pitchSine)
  vectors[1] = t.Vec3(
    -rollSine * pitchSine * yawCosine + -rollCosine * -yawSine,
    -rollSine * pitchSine * yawSine + -rollCosine * yawCosine,
    -rollSine * pitchCosine,
  )
  vectors[2] = t.Vec3(
    rollCosine * pitchSine * yawCosine + -rollSine * -yawSine,
    rollCosine * pitchSine * yawSine + -rollSine * yawCosine,
    rollCosine * pitchCosine,
  )
  return vectors
end function

// Provide angle vectors behavior for the active subsystem.
function angleVectors(angles)
  return AngleVectors(angles)
end function

// Provide vector compare behavior for the active subsystem.
function VectorCompare(first, second)
  if first.x != second.x then return 0 end if
  if first.y != second.y then return 0 end if
  if first.z != second.z then return 0 end if
  return 1
end function

// Provide vector ma behavior for the active subsystem.
function VectorMA(first, scalar, second)
  // MiniLang struct construction allocates.  Read both source vectors before
  // that allocation so a GC triggered while building the Vec3 cannot leave a
  // stale argument object live only in an unevaluated field expression.
  x = first.x + scalar * second.x
  y = first.y + scalar * second.y
  z = first.z + scalar * second.z
  return t.Vec3(x, y, z)
end function

// Provide dot product behavior for the active subsystem.
function _DotProduct(first, second)
  return DotProduct(first, second)
end function

// Provide vector subtract behavior for the active subsystem.
function _VectorSubtract(first, second)
  return VectorSubtract(first, second)
end function

// Provide vector add behavior for the active subsystem.
function _VectorAdd(first, second)
  return VectorAdd(first, second)
end function

// Provide vector copy behavior for the active subsystem.
function _VectorCopy(value)
  return VectorCopy(value)
end function

// Provide cross product behavior for the active subsystem.
function CrossProduct(first, second)
  return t.Vec3(
    first.y * second.z - first.z * second.y,
    first.z * second.x - first.x * second.z,
    first.x * second.y - first.y * second.x,
  )
end function

// Return length derived from the active module state.
function Length(value)
  magnitude = value.x * value.x + value.y * value.y + value.z * value.z
  return native.sqrt(magnitude)
end function

// Provide vector normalize behavior for the active subsystem.
function VectorNormalize(value)
  magnitude = native.sqrt(value.x * value.x + value.y * value.y + value.z * value.z)
  if magnitude != 0.0 then
    inverseMagnitude = 1.0 / magnitude
    value.x = value.x * inverseMagnitude
    value.y = value.y * inverseMagnitude
    value.z = value.z * inverseMagnitude
  end if
  return magnitude
end function

// Provide vector inverse behavior for the active subsystem.
function VectorInverse(value)
  value.x = -value.x
  value.y = -value.y
  value.z = -value.z
  return value
end function

// Provide vector scale behavior for the active subsystem.
function VectorScale(value, scalar)
  return t.Vec3(value.x * scalar, value.y * scalar, value.z * scalar)
end function

// Provide the Quake-compatible log2 entry point.
function Q_log2(value)
  if value < 0 then return error(2501, "Q_log2: negative value") end if
  answer = 0
  shifted = value >> 1
  while shifted != 0
    answer = answer + 1
    shifted = shifted >> 1
  end while
  return answer
end function

// Apply the Quake-compatible r concat transforms behavior.
function R_ConcatTransforms(first, second)
  return [
    [
      first[0][0] * second[0][0] + first[0][1] * second[1][0] + first[0][2] * second[2][0],
      first[0][0] * second[0][1] + first[0][1] * second[1][1] + first[0][2] * second[2][1],
      first[0][0] * second[0][2] + first[0][1] * second[1][2] + first[0][2] * second[2][2],
      first[0][0] * second[0][3] + first[0][1] * second[1][3] + first[0][2] * second[2][3] + first[0][3],
    ],
    [
      first[1][0] * second[0][0] + first[1][1] * second[1][0] + first[1][2] * second[2][0],
      first[1][0] * second[0][1] + first[1][1] * second[1][1] + first[1][2] * second[2][1],
      first[1][0] * second[0][2] + first[1][1] * second[1][2] + first[1][2] * second[2][2],
      first[1][0] * second[0][3] + first[1][1] * second[1][3] + first[1][2] * second[2][3] + first[1][3],
    ],
    [
      first[2][0] * second[0][0] + first[2][1] * second[1][0] + first[2][2] * second[2][0],
      first[2][0] * second[0][1] + first[2][1] * second[1][1] + first[2][2] * second[2][1],
      first[2][0] * second[0][2] + first[2][1] * second[1][2] + first[2][2] * second[2][2],
      first[2][0] * second[0][3] + first[2][1] * second[1][3] + first[2][2] * second[2][3] + first[2][3],
    ],
  ]
end function

// Provide floor div mod behavior for the active subsystem.
function FloorDivMod(numerator, denominator)
  if denominator <= 0.0 then return error(2502, "FloorDivMod: bad denominator " + denominator) end if
  quotient = 0
  remainder = 0
  if numerator >= 0.0 then
    x = smath.floor(numerator / denominator)
    quotient = native.trunc(x)
    remainder = native.trunc(smath.floor(numerator - x * denominator))
  else
    x = smath.floor(-numerator / denominator)
    quotient = -native.trunc(x)
    remainder = native.trunc(smath.floor(-numerator - x * denominator))
    if remainder != 0 then
      quotient = quotient - 1
      remainder = native.trunc(denominator) - remainder
    end if
  end if
  return [quotient, remainder]
end function

// Provide greatest common divisor behavior for the active subsystem.
function GreatestCommonDivisor(first, second)
  if first > second then
    if second == 0 then return first end if
    return GreatestCommonDivisor(second, first % second)
  end if
  if first == 0 then return second end if
  return GreatestCommonDivisor(first, second % first)
end function

// Provide greatest common divisor behavior for the active subsystem.
function greatestCommonDivisor(first, second)
  return GreatestCommonDivisor(first, second)
end function

// Provide invert24 to16 behavior for the active subsystem.
function Invert24To16(value)
  if value < 256 then return -1 end if
  return native.trunc((65536.0 * 16777216.0 / value) + 0.5)
end function
