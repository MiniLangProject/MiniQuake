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

/// Defines the pi value used by `miniquake.mathlib`.
const PI = 3.14159265358979323846
/// Defines the rad to deg value used by `miniquake.mathlib`.
const RAD_TO_DEG = 57.29577951308232
/// Defines the deg to rad value used by `miniquake.mathlib`.
const DEG_TO_RAD = 0.017453292519943295
/// Defines the nan mask value used by `miniquake.mathlib`.
const NAN_MASK = 0x7f800000

/// Implements the `vec3` operation for `miniquake.mathlib` (vec3).
/// @param x The x input consumed by `vec3`.
/// @param y The y input consumed by `vec3`.
/// @param z The z input consumed by `vec3`.
function vec3(x, y, z)
  return t.Vec3(x, y, z)
end function

// Return vec3 origin derived from the active module state.
function vec3Origin()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// mathlib.h macro counterparts.
/// @param a The a input consumed by `DotProduct`.
/// @param b The b input consumed by `DotProduct`.
function inline DotProduct(a, b)
  return a.x * b.x + a.y * b.y + a.z * b.z
end function

/// Implements the `VectorSubtract` operation for `miniquake.mathlib` (vector subtract).
/// @param a The a input consumed by `VectorSubtract`.
/// @param b The b input consumed by `VectorSubtract`.
function VectorSubtract(a, b)
  return t.Vec3(a.x - b.x, a.y - b.y, a.z - b.z)
end function

/// Implements the `VectorAdd` operation for `miniquake.mathlib` (vector add).
/// @param a The a input consumed by `VectorAdd`.
/// @param b The b input consumed by `VectorAdd`.
function VectorAdd(a, b)
  return t.Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end function

/// Implements the `VectorCopy` operation for `miniquake.mathlib` (vector copy).
/// @param value Value consumed by `VectorCopy`.
function VectorCopy(value)
  return t.Vec3(value.x, value.y, value.z)
end function

/// Report whether is nan.
/// @param value Value consumed by `IS_NAN`.
function IS_NAN(value)
  return (native.floatBits(value) & NAN_MASK) == NAN_MASK
end function

/// Existing MiniQuake convenience spellings preserve value semantics.
/// @param value Value consumed by `copy`.
function copy(value)
  return VectorCopy(value)
end function

/// Add state for add.
/// @param a The a input consumed by `add`.
/// @param b The b input consumed by `add`.
function add(a, b)
  return VectorAdd(a, b)
end function

/// Implements the `subtract` operation for `miniquake.mathlib` (subtract).
/// @param a The a input consumed by `subtract`.
/// @param b The b input consumed by `subtract`.
function subtract(a, b)
  return VectorSubtract(a, b)
end function

/// Implements the `scale` operation for `miniquake.mathlib` (scale).
/// @param value Value consumed by `scale`.
/// @param scalar The scalar input consumed by `scale`.
function scale(value, scalar)
  return VectorScale(value, scalar)
end function

/// Implements the `multiplyAdd` operation for `miniquake.mathlib` (multiply add).
/// @param a The a input consumed by `multiplyAdd`.
/// @param scalar The scalar input consumed by `multiplyAdd`.
/// @param b The b input consumed by `multiplyAdd`.
function multiplyAdd(a, scalar, b)
  return VectorMA(a, scalar, b)
end function

/// Implements the `dot` operation for `miniquake.mathlib` (dot).
/// @param a The a input consumed by `dot`.
/// @param b The b input consumed by `dot`.
function dot(a, b)
  return DotProduct(a, b)
end function

/// Implements the `cross` operation for `miniquake.mathlib` (cross).
/// @param a The a input consumed by `cross`.
/// @param b The b input consumed by `cross`.
function cross(a, b)
  return CrossProduct(a, b)
end function

/// Return length squared for the active module state.
/// @param value Value consumed by `lengthSquared`.
function lengthSquared(value)
  return DotProduct(value, value)
end function

/// Return length derived from the active module state.
/// @param value Value consumed by `length`.
function length(value)
  return Length(value)
end function

/// Convert the requested value into its canonical representation.
/// @param value Value consumed by `normalize`.
function normalize(value)
  result = VectorCopy(value)
  VectorNormalize(result)
  return result
end function

/// Return a validated clamp value.
/// @param value Value consumed by `clamp`.
/// @param minimum Smallest accepted value.
/// @param maximum Largest accepted value.
function clamp(value, minimum, maximum)
  if value < minimum then return minimum end if
  if value > maximum then return maximum end if
  return value
end function

/// Implements the `sqrt` operation for `miniquake.mathlib` (sqrt).
/// @param value Value consumed by `sqrt`.
function sqrt(value)
  return native.sqrt(value)
end function

/// Implements the `atan2` operation for `miniquake.mathlib` (atan2).
/// @param y The y input consumed by `atan2`.
/// @param x The x input consumed by `atan2`.
function atan2(y, x)
  return native.atan2(y, x)
end function

/// Implements the `sin` operation for `miniquake.mathlib` (sin).
/// @param value Value consumed by `sin`.
function sin(value)
  return native.sin(value)
end function

/// Implements the `cos` operation for `miniquake.mathlib` (cos).
/// @param value Value consumed by `cos`.
function cos(value)
  return native.cos(value)
end function

/// Implements the `ProjectPointOnPlane` operation for `miniquake.mathlib` (project point on plane).
/// @param point The point input consumed by `ProjectPointOnPlane`.
/// @param normal The normal input consumed by `ProjectPointOnPlane`.
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

/// Implements the `projectPointOnPlane` operation for `miniquake.mathlib` (project point on plane).
/// @param point The point input consumed by `projectPointOnPlane`.
/// @param normal The normal input consumed by `projectPointOnPlane`.
function projectPointOnPlane(point, normal)
  return ProjectPointOnPlane(point, normal)
end function

/// Return perpendicular vector derived from the active module state.
/// @param source Source value or collection to read.
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

/// Return perpendicular vector derived from the active module state.
/// @param source Source value or collection to read.
function perpendicularVector(source)
  return PerpendicularVector(source)
end function

/// Apply the Quake-compatible r concat rotations behavior.
/// @param first The first input consumed by `R_ConcatRotations`.
/// @param second The second input consumed by `R_ConcatRotations`.
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

/// Return rotate point around vector derived from the active module state.
/// @param direction The direction input consumed by `RotatePointAroundVector`.
/// @param point The point input consumed by `RotatePointAroundVector`.
/// @param degrees The degrees input consumed by `RotatePointAroundVector`.
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

/// Return rotate point around vector derived from the active module state.
/// @param direction The direction input consumed by `rotatePointAroundVector`.
/// @param point The point input consumed by `rotatePointAroundVector`.
/// @param degrees The degrees input consumed by `rotatePointAroundVector`.
function rotatePointAroundVector(direction, point, degrees)
  return RotatePointAroundVector(direction, point, degrees)
end function

/// Implements the `anglemod` operation for `miniquake.mathlib` (anglemod).
/// @param angle The angle input consumed by `anglemod`.
function anglemod(angle)
  quantized = native.trunc(angle * (65536.0 / 360.0)) & 65535
  return (360.0 / 65536.0) * quantized
end function

/// Implements the `angleMod` operation for `miniquake.mathlib` (angle mod).
/// @param angle The angle input consumed by `angleMod`.
function angleMod(angle)
  return anglemod(angle)
end function

// Mirror Quake's BOPS_Error routine and its observable state changes.
function BOPS_Error()
  return error(2500, "BoxOnPlaneSide: Bad signbits")
end function

/// Implements the `BoxOnPlaneSide` operation for `miniquake.mathlib` (box on plane side).
/// @param emins The emins input consumed by `BoxOnPlaneSide`.
/// @param emaxs The emaxs input consumed by `BoxOnPlaneSide`.
/// @param plane The plane input consumed by `BoxOnPlaneSide`.
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

/// Mirror Quake's BOX_ON_PLANE_SIDE routine and its observable state changes.
/// @param emins The emins input consumed by `BOX_ON_PLANE_SIDE`.
/// @param emaxs The emaxs input consumed by `BOX_ON_PLANE_SIDE`.
/// @param plane The plane input consumed by `BOX_ON_PLANE_SIDE`.
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

/// Implements the `boxOnPlaneSide` operation for `miniquake.mathlib` (box on plane side).
/// @param emins The emins input consumed by `boxOnPlaneSide`.
/// @param emaxs The emaxs input consumed by `boxOnPlaneSide`.
/// @param plane The plane input consumed by `boxOnPlaneSide`.
function boxOnPlaneSide(emins, emaxs, plane)
  return BOX_ON_PLANE_SIDE(emins, emaxs, plane)
end function

/// Implements the `AngleVectors` operation for `miniquake.mathlib` (angle vectors).
/// @param angles Orientation angles used by the operation.
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

/// Implements the `angleVectors` operation for `miniquake.mathlib` (angle vectors).
/// @param angles Orientation angles used by the operation.
function angleVectors(angles)
  return AngleVectors(angles)
end function

/// Implements the `VectorCompare` operation for `miniquake.mathlib` (vector compare).
/// @param first The first input consumed by `VectorCompare`.
/// @param second The second input consumed by `VectorCompare`.
function VectorCompare(first, second)
  if first.x != second.x then return 0 end if
  if first.y != second.y then return 0 end if
  if first.z != second.z then return 0 end if
  return 1
end function

/// Implements the `VectorMA` operation for `miniquake.mathlib` (vector ma).
/// @param first The first input consumed by `VectorMA`.
/// @param scalar The scalar input consumed by `VectorMA`.
/// @param second The second input consumed by `VectorMA`.
function VectorMA(first, scalar, second)
  // MiniLang struct construction allocates.  Read both source vectors before
  // that allocation so a GC triggered while building the Vec3 cannot leave a
  // stale argument object live only in an unevaluated field expression.
  x = first.x + scalar * second.x
  y = first.y + scalar * second.y
  z = first.z + scalar * second.z
  return t.Vec3(x, y, z)
end function

/// Implements the `_DotProduct` operation for `miniquake.mathlib` (dot product).
/// @param first The first input consumed by `_DotProduct`.
/// @param second The second input consumed by `_DotProduct`.
function _DotProduct(first, second)
  return DotProduct(first, second)
end function

/// Implements the `_VectorSubtract` operation for `miniquake.mathlib` (vector subtract).
/// @param first The first input consumed by `_VectorSubtract`.
/// @param second The second input consumed by `_VectorSubtract`.
function _VectorSubtract(first, second)
  return VectorSubtract(first, second)
end function

/// Implements the `_VectorAdd` operation for `miniquake.mathlib` (vector add).
/// @param first The first input consumed by `_VectorAdd`.
/// @param second The second input consumed by `_VectorAdd`.
function _VectorAdd(first, second)
  return VectorAdd(first, second)
end function

/// Implements the `_VectorCopy` operation for `miniquake.mathlib` (vector copy).
/// @param value Value consumed by `_VectorCopy`.
function _VectorCopy(value)
  return VectorCopy(value)
end function

/// Implements the `CrossProduct` operation for `miniquake.mathlib` (cross product).
/// @param first The first input consumed by `CrossProduct`.
/// @param second The second input consumed by `CrossProduct`.
function CrossProduct(first, second)
  return t.Vec3(
    first.y * second.z - first.z * second.y,
    first.z * second.x - first.x * second.z,
    first.x * second.y - first.y * second.x,
  )
end function

/// Return length derived from the active module state.
/// @param value Value consumed by `Length`.
function Length(value)
  magnitude = value.x * value.x + value.y * value.y + value.z * value.z
  return native.sqrt(magnitude)
end function

/// Implements the `VectorNormalize` operation for `miniquake.mathlib` (vector normalize).
/// @param value Value consumed by `VectorNormalize`.
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

/// Implements the `VectorInverse` operation for `miniquake.mathlib` (vector inverse).
/// @param value Value consumed by `VectorInverse`.
function VectorInverse(value)
  value.x = -value.x
  value.y = -value.y
  value.z = -value.z
  return value
end function

/// Implements the `VectorScale` operation for `miniquake.mathlib` (vector scale).
/// @param value Value consumed by `VectorScale`.
/// @param scalar The scalar input consumed by `VectorScale`.
function VectorScale(value, scalar)
  return t.Vec3(value.x * scalar, value.y * scalar, value.z * scalar)
end function

/// Provide the Quake-compatible log2 entry point.
/// @param value Value consumed by `Q_log2`.
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

/// Apply the Quake-compatible r concat transforms behavior.
/// @param first The first input consumed by `R_ConcatTransforms`.
/// @param second The second input consumed by `R_ConcatTransforms`.
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

/// Implements the `FloorDivMod` operation for `miniquake.mathlib` (floor div mod).
/// @param numerator The numerator input consumed by `FloorDivMod`.
/// @param denominator The denominator input consumed by `FloorDivMod`.
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

/// Implements the `GreatestCommonDivisor` operation for `miniquake.mathlib` (greatest common divisor).
/// @param first The first input consumed by `GreatestCommonDivisor`.
/// @param second The second input consumed by `GreatestCommonDivisor`.
function GreatestCommonDivisor(first, second)
  if first > second then
    if second == 0 then return first end if
    return GreatestCommonDivisor(second, first % second)
  end if
  if first == 0 then return second end if
  return GreatestCommonDivisor(first, second % first)
end function

/// Implements the `greatestCommonDivisor` operation for `miniquake.mathlib` (greatest common divisor).
/// @param first The first input consumed by `greatestCommonDivisor`.
/// @param second The second input consumed by `greatestCommonDivisor`.
function greatestCommonDivisor(first, second)
  return GreatestCommonDivisor(first, second)
end function

/// Implements the `Invert24To16` operation for `miniquake.mathlib` (invert24 to16).
/// @param value Value consumed by `Invert24To16`.
function Invert24To16(value)
  if value < 256 then return -1 end if
  return native.trunc((65536.0 * 16777216.0 / value) + 0.5)
end function
