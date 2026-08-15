/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-075: mathlib.c and chase.c gameplay/presentation parity.
*/
import miniquake.mathlib as math
import miniquake.chase as chase
import miniquake.types as t
import miniquake.cvar as cvar
import miniquake.native as native

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(10750, name + ": expected true") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(10751, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(10752, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify anglemod wrap against the expected Quake behavior.
function testAnglemodWrap()
  near(math.anglemod(450.0), 90.0, 0.000001, "anglemod wrap")
  return true
end function

// Verify anglemod negative against the expected Quake behavior.
function testAnglemodNegative()
  near(math.anglemod(-1.0), 359.000244140625, 0.000001, "anglemod negative")
  return true
end function

// Verify angle vectors forward against the expected Quake behavior.
function testAngleVectorsForward()
  values = math.AngleVectors(t.Vec3(0.0, 90.0, 0.0))
  near(values[0].x, 0.0, 0.00001, "forward x")
  near(values[0].y, 1.0, 0.00001, "forward y")
  return true
end function

// Verify angle vectors right against the expected Quake behavior.
function testAngleVectorsRight()
  values = math.AngleVectors(t.Vec3(0.0, 0.0, 0.0))
  near(values[1].x, 0.0, 0.00001, "right x")
  near(values[1].y, -1.0, 0.00001, "right y")
  return true
end function

// Verify vector normalize against the expected Quake behavior.
function testVectorNormalize()
  value = t.Vec3(3.0, 4.0, 0.0)
  near(math.VectorNormalize(value), 5.0, 0.00001, "length")
  near(value.x, 0.6, 0.00001, "normalized x")
  near(value.y, 0.8, 0.00001, "normalized y")
  return true
end function

// Verify project plane against the expected Quake behavior.
function testProjectPlane()
  result = math.ProjectPointOnPlane(t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.0, 0.0, 1.0))
  near(result.z, 0.0, 0.00001, "projected z")
  return true
end function

// Verify perpendicular against the expected Quake behavior.
function testPerpendicular()
  result = math.PerpendicularVector(t.Vec3(0.0, 0.0, 1.0))
  near(math.DotProduct(result, t.Vec3(0.0, 0.0, 1.0)), 0.0, 0.00001, "perpendicular dot")
  near(math.Length(result), 1.0, 0.00001, "perpendicular length")
  return true
end function

// Verify rotate point against the expected Quake behavior.
function testRotatePoint()
  result = math.RotatePointAroundVector(t.Vec3(0.0, 0.0, 1.0), t.Vec3(1.0, 0.0, 0.0), 90.0)
  near(result.x, 0.0, 0.0001, "rotated x")
  near(result.y, 1.0, 0.0001, "rotated y")
  return true
end function

// Verify floor div mod against the expected Quake behavior.
function testFloorDivMod()
  result = math.FloorDivMod(-7.0, 3.0)
  equal(result[0], -3, "quotient")
  equal(result[1], 2, "remainder")
  return true
end function

// Verify gcd against the expected Quake behavior.
function testGcd()
  equal(math.GreatestCommonDivisor(462, 1071), 21, "gcd")
  return true
end function

// Verify log2 against the expected Quake behavior.
function testLog2()
  equal(math.Q_log2(1025), 10, "qlog2")
  return true
end function

// Verify chase defaults against the expected Quake behavior.
function testChaseDefaults()
  state = chase.create()
  equal(state.active, false, "active")
  near(state.back, 100.0, 0.0, "back")
  near(state.up, 16.0, 0.0, "up")
  near(state.right, 0.0, 0.0, "right")
  return true
end function

// Verify chase registration against the expected Quake behavior.
function testChaseRegistration()
  registry = cvar.createRegistry()
  chase.Chase_Init(registry)
  equal(len(registry.variables), 4, "registered cvars")
  return true
end function

// Verify chase sync against the expected Quake behavior.
function testChaseSync()
  registry = cvar.createRegistry()
  state = chase.Chase_Init(registry)
  cvar.set(registry, "chase_back", "64")
  cvar.set(registry, "chase_up", "20")
  cvar.set(registry, "chase_right", "8")
  cvar.set(registry, "chase_active", "1")
  chase.syncCvars(state, registry)
  near(state.back, 64.0, 0.0, "sync back")
  near(state.up, 20.0, 0.0, "sync up")
  near(state.right, 8.0, 0.0, "sync right")
  yes(state.active, "sync active")
  return true
end function

// Verify chase reset noop against the expected Quake behavior.
function testChaseResetNoop()
  state = chase.create()
  result = chase.Chase_Reset(state)
  yes(result == state, "reset identity")
  return true
end function

// Verify trace line clear against the expected Quake behavior.
function testTraceLineClear()
  result = chase.TraceLine(void, t.Vec3(1.0, 2.0, 3.0), t.Vec3(4.0, 5.0, 6.0))
  near(result.x, 4.0, 0.0, "trace x")
  near(result.y, 5.0, 0.0, "trace y")
  near(result.z, 6.0, 0.0, "trace z")
  return true
end function

// Verify chase destination against the expected Quake behavior.
function testChaseDestination()
  state = chase.create()
  result = chase.Chase_UpdateRefdef(
    state,
    t.Vec3(10.0, 20.0, 30.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 45.0, 12.0),
    void,
  )
  near(result[0].x, -90.0, 0.00001, "destination x")
  near(result[0].y, 20.0, 0.00001, "destination y")
  near(result[0].z, 46.0, 0.00001, "destination z")
  return true
end function

// Verify chase right offset against the expected Quake behavior.
function testChaseRightOffset()
  state = chase.create()
  state.right = 10.0
  result = chase.Chase_Update(state, t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 0.0, 0.0), void)
  near(result[0].y, 30.0, 0.00001, "right offset")
  return true
end function

// Verify chase preserves yaw roll against the expected Quake behavior.
function testChasePreservesYawRoll()
  state = chase.create()
  result = chase.Chase_UpdateRefdef(
    state,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(12.0, 123.0, 7.0),
    void,
  )
  near(result[1].y, 123.0, 0.0, "yaw")
  near(result[1].z, 7.0, 0.0, "roll")
  return true
end function

// Verify chase pitch clear against the expected Quake behavior.
function testChasePitchClear()
  state = chase.create()
  result = chase.Chase_Update(state, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), void)
  near(result[1].x, 0.0, 0.00001, "pitch")
  return true
end function

// Verify chase impact against the expected Quake behavior.
function testChaseImpact()
  state = chase.create()
  result = chase.Chase_Update(state, t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.0, 0.0, 0.0), void)
  near(result[3].x, 4097.0, 0.00001, "impact x")
  near(result[3].y, 2.0, 0.00001, "impact y")
  near(result[3].z, 3.0, 0.00001, "impact z")
  return true
end function

// Verify chase convenience against the expected Quake behavior.
function testChaseConvenience()
  state = chase.create()
  result = chase.update(state, t.Vec3(5.0, 6.0, 7.0), t.Vec3(0.0, 0.0, 0.0))
  near(result.x, -95.0, 0.00001, "convenience x")
  near(result.z, 23.0, 0.00001, "convenience z")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed = 0
  if run(1, "anglemod wrap", testAnglemodWrap) then passed = passed + 1 end if
  if run(2, "anglemod negative", testAnglemodNegative) then passed = passed + 1 end if
  if run(3, "AngleVectors forward", testAngleVectorsForward) then passed = passed + 1 end if
  if run(4, "AngleVectors right", testAngleVectorsRight) then passed = passed + 1 end if
  if run(5, "VectorNormalize", testVectorNormalize) then passed = passed + 1 end if
  if run(6, "ProjectPointOnPlane", testProjectPlane) then passed = passed + 1 end if
  if run(7, "PerpendicularVector", testPerpendicular) then passed = passed + 1 end if
  if run(8, "RotatePointAroundVector", testRotatePoint) then passed = passed + 1 end if
  if run(9, "FloorDivMod", testFloorDivMod) then passed = passed + 1 end if
  if run(10, "GreatestCommonDivisor", testGcd) then passed = passed + 1 end if
  if run(11, "Q_log2", testLog2) then passed = passed + 1 end if
  if run(12, "chase defaults", testChaseDefaults) then passed = passed + 1 end if
  if run(13, "chase registration", testChaseRegistration) then passed = passed + 1 end if
  if run(14, "chase cvar sync", testChaseSync) then passed = passed + 1 end if
  if run(15, "chase reset", testChaseResetNoop) then passed = passed + 1 end if
  if run(16, "clear trace", testTraceLineClear) then passed = passed + 1 end if
  if run(17, "chase destination", testChaseDestination) then passed = passed + 1 end if
  if run(18, "chase right offset", testChaseRightOffset) then passed = passed + 1 end if
  if run(19, "chase preserves yaw roll", testChasePreservesYawRoll) then passed = passed + 1 end if
  if run(20, "chase pitch", testChasePitchClear) then passed = passed + 1 end if
  if run(21, "chase impact", testChaseImpact) then passed = passed + 1 end if
  if run(22, "chase convenience", testChaseConvenience) then passed = passed + 1 end if
  if passed != 22 then print "MiniQuake BP-075 math/chase tests failed: " + passed + "/22"; return 1 end if
  print "MiniQuake BP-075 math/chase tests passed: 22"
  return 0
end function
