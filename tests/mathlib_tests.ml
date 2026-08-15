/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused mathlib.c/mathlib.h behavioral fixtures.
*/
import miniquake.mathlib as math
import miniquake.types as t
import miniquake.native as native

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9600, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9601, name + ": expected true") end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.00001 then return error(9602, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Exercise assert vec as part of this deterministic regression fixture.
function assertVec(value, x, y, z, name)
  assertNear(value.x, x, name + ".x")
  assertNear(value.y, y, name + ".y")
  assertNear(value.z, z, name + ".z")
end function

// Verify vector macros and functions against the expected Quake behavior.
function testVectorMacrosAndFunctions()
  first = t.Vec3(1.0, 2.0, 3.0)
  second = t.Vec3(4.0, 5.0, 6.0)
  assertEqual(math.DotProduct(first, second), 32.0, "DotProduct macro")
  assertEqual(math._DotProduct(first, second), 32.0, "_DotProduct")
  assertVec(math.VectorAdd(first, second), 5.0, 7.0, 9.0, "VectorAdd")
  assertVec(math._VectorAdd(first, second), 5.0, 7.0, 9.0, "_VectorAdd")
  assertVec(math.VectorSubtract(second, first), 3.0, 3.0, 3.0, "VectorSubtract")
  assertVec(math._VectorSubtract(second, first), 3.0, 3.0, 3.0, "_VectorSubtract")
  assertVec(math.VectorCopy(first), 1.0, 2.0, 3.0, "VectorCopy")
  assertVec(math._VectorCopy(second), 4.0, 5.0, 6.0, "_VectorCopy")
  assertVec(math.VectorMA(first, 2.0, second), 9.0, 12.0, 15.0, "VectorMA")
  assertVec(math.CrossProduct(first, second), -3.0, 6.0, -3.0, "CrossProduct")
  assertEqual(math.VectorCompare(first, t.Vec3(1.0, 2.0, 3.0)), 1, "VectorCompare equal")
  assertEqual(math.VectorCompare(first, t.Vec3(1.0, 2.0, 3.000001)), 0, "VectorCompare exact")
  assertNear(math.Length(t.Vec3(3.0, 4.0, 0.0)), 5.0, "Length")

  normalized = t.Vec3(3.0, 4.0, 0.0)
  assertNear(math.VectorNormalize(normalized), 5.0, "VectorNormalize return length")
  assertVec(normalized, 0.6, 0.8, 0.0, "VectorNormalize mutation")
  zero = t.Vec3(0.0, 0.0, 0.0)
  assertEqual(math.VectorNormalize(zero), 0.0, "VectorNormalize zero")
  inverse = t.Vec3(1.0, -2.0, 3.0)
  math.VectorInverse(inverse)
  assertVec(inverse, -1.0, 2.0, -3.0, "VectorInverse")
  assertVec(math.VectorScale(first, -2.0), -2.0, -4.0, -6.0, "VectorScale")
  assertVec(math.vec3Origin(), 0.0, 0.0, 0.0, "vec3_origin")

  assertEqual(math.IS_NAN(1.0), false, "IS_NAN finite")
  assertEqual(math.IS_NAN(native.bitsFloat(0x7f800000)), true, "IS_NAN infinity macro quirk")
  assertEqual(math.IS_NAN(native.bitsFloat(0x7fc00000)), true, "IS_NAN NaN")
  return true
end function

// Verify projection and rotation against the expected Quake behavior.
function testProjectionAndRotation()
  projected = math.ProjectPointOnPlane(t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.0, 0.0, 1.0))
  assertVec(projected, 1.0, 2.0, 0.0, "ProjectPointOnPlane unit")
  nonUnit = math.ProjectPointOnPlane(t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.0, 0.0, 2.0))
  assertVec(nonUnit, 1.0, 2.0, 2.25, "ProjectPointOnPlane original double inverse")
  perpendicular = math.PerpendicularVector(t.Vec3(0.0, 0.0, 1.0))
  assertVec(perpendicular, 1.0, 0.0, 0.0, "PerpendicularVector")
  rotated = math.RotatePointAroundVector(t.Vec3(0.0, 0.0, 1.0), t.Vec3(1.0, 0.0, 0.0), 90.0)
  assertVec(rotated, 0.0, 1.0, 0.0, "RotatePointAroundVector")
  return true
end function

// Verify angles against the expected Quake behavior.
function testAngles()
  assertNear(math.anglemod(450.0), 90.0, "anglemod positive")
  assertNear(math.anglemod(360.0), 0.0, "anglemod wrap")
  assertNear(math.anglemod(-1.0), 359.000244140625, "anglemod negative quantization")
  vectors = math.AngleVectors(t.Vec3(0.0, 90.0, 0.0))
  assertVec(vectors[0], 0.0, 1.0, 0.0, "AngleVectors forward")
  assertVec(vectors[1], 1.0, 0.0, 0.0, "AngleVectors right")
  assertVec(vectors[2], 0.0, 0.0, 1.0, "AngleVectors up")
  return true
end function

// Verify box on plane side against the expected Quake behavior.
function testBoxOnPlaneSide()
  minimums = t.Vec3(-3.0, -2.0, -1.0)
  maximums = t.Vec3(5.0, 7.0, 11.0)
  expected = [3, 3, 3, 3, 2, 2, 2, 2]
  signBits = 0
  while signBits < 8
    nx = 0.25
    ny = 0.5
    nz = 1.0
    if (signBits & 1) != 0 then nx = -nx end if
    if (signBits & 2) != 0 then ny = -ny end if
    if (signBits & 4) != 0 then nz = -nz end if
    plane = t.Plane(t.Vec3(nx, ny, nz), 6.0, 3, signBits)
    assertEqual(math.BoxOnPlaneSide(minimums, maximums, plane), expected[signBits], "BoxOnPlaneSide signbits " + signBits)
    signBits = signBits + 1
  end while

  axial = t.Plane(t.Vec3(1.0, 0.0, 0.0), -3.0, 0, 0)
  assertEqual(math.BOX_ON_PLANE_SIDE(minimums, maximums, axial), 1, "BOX macro minimum equality")
  axial.dist = 5.0
  assertEqual(math.BOX_ON_PLANE_SIDE(minimums, maximums, axial), 2, "BOX macro maximum equality")
  axial.dist = 0.0
  assertEqual(math.BOX_ON_PLANE_SIDE(minimums, maximums, axial), 3, "BOX macro crossing")
  invalid = t.Plane(t.Vec3(1.0, 1.0, 1.0), 0.0, 3, 8)
  invalidResult = try(math.BoxOnPlaneSide(minimums, maximums, invalid))
  assertTrue(invalidResult is error, "BOPS_Error invalid signbits")
  directError = try(math.BOPS_Error())
  assertTrue(directError is error, "BOPS_Error direct")
  return true
end function

// Verify matrices against the expected Quake behavior.
function testMatrices()
  first = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
  identity = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
  rotation = math.R_ConcatRotations(first, identity)
  assertNear(rotation[0][2], 3.0, "R_ConcatRotations row zero")
  assertNear(rotation[2][1], 8.0, "R_ConcatRotations row two")

  transform1 = [[2.0, 0.0, 0.0, 10.0], [0.0, 3.0, 0.0, 20.0], [0.0, 0.0, 4.0, 30.0]]
  transform2 = [[1.0, 0.0, 0.0, 1.0], [0.0, 1.0, 0.0, 2.0], [0.0, 0.0, 1.0, 3.0]]
  combined = math.R_ConcatTransforms(transform1, transform2)
  assertNear(combined[0][0], 2.0, "R_ConcatTransforms scale x")
  assertNear(combined[1][1], 3.0, "R_ConcatTransforms scale y")
  assertNear(combined[2][2], 4.0, "R_ConcatTransforms scale z")
  assertNear(combined[0][3], 12.0, "R_ConcatTransforms translation x")
  assertNear(combined[1][3], 26.0, "R_ConcatTransforms translation y")
  assertNear(combined[2][3], 42.0, "R_ConcatTransforms translation z")
  return true
end function

// Verify integer helpers against the expected Quake behavior.
function testIntegerHelpers()
  result = math.FloorDivMod(7.0, 3.0)
  assertEqual(result[0], 2, "FloorDivMod positive quotient")
  assertEqual(result[1], 1, "FloorDivMod positive remainder")
  negative = math.FloorDivMod(-7.0, 3.0)
  assertEqual(negative[0], -3, "FloorDivMod negative quotient")
  assertEqual(negative[1], 2, "FloorDivMod negative remainder")
  exact = math.FloorDivMod(-6.0, 3.0)
  assertEqual(exact[0], -2, "FloorDivMod exact quotient")
  assertEqual(exact[1], 0, "FloorDivMod exact remainder")
  badDenominator = try(math.FloorDivMod(1.0, 0.0))
  assertTrue(badDenominator is error, "FloorDivMod denominator error")

  assertEqual(math.GreatestCommonDivisor(54, 24), 6, "GreatestCommonDivisor")
  assertEqual(math.GreatestCommonDivisor(0, 24), 24, "GreatestCommonDivisor zero")
  assertEqual(math.Q_log2(0), 0, "Q_log2 zero")
  assertEqual(math.Q_log2(1), 0, "Q_log2 one")
  assertEqual(math.Q_log2(2), 1, "Q_log2 two")
  assertEqual(math.Q_log2(1024), 10, "Q_log2 power")
  negativeLog = try(math.Q_log2(-1))
  assertTrue(negativeLog is error, "Q_log2 negative guard")
  assertEqual(math.Invert24To16(255), -1, "Invert24To16 underflow")
  assertEqual(math.Invert24To16(0x01000000), 65536, "Invert24To16 unity")
  assertEqual(math.Invert24To16(0x00800000), 131072, "Invert24To16 double")
  assertEqual(math.Invert24To16(0x00c00000), 87381, "Invert24To16 rounding")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/6] vector functions/macros"
  testVectorMacrosAndFunctions()
  print "[2/6] projection/rotation"
  testProjectionAndRotation()
  print "[3/6] angle semantics"
  testAngles()
  print "[4/6] plane-side semantics"
  testBoxOnPlaneSide()
  print "[5/6] matrix concatenation"
  testMatrices()
  print "[6/6] integer helpers"
  testIntegerHelpers()
  print "MiniQuake mathlib compatibility tests passed: 6"
  return 0
end function
