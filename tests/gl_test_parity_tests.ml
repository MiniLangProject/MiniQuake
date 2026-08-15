/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused gl_test.c reflection, puff geometry and lifetime fixtures.
*/
import miniquake.types as t
import miniquake.render.gl_test as testRenderer

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9750, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.00001 then return error(9751, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Verify init and hit plane against the expected Quake behavior.
function testInitAndHitPlane()
  state = testRenderer.createState()
  testRenderer.Test_UseState(state)
  state.puffs[0].length = 3.0
  testRenderer.Test_Init()
  assertNear(state.puffs[0].length, 0.0, "Test_Init clears puffs")
  state.hitPlaneOverride = t.Plane(t.Vec3(0.0, 0.0, 1.0), 12.0, 2, 0)
  plane = testRenderer.HitPlane(t.Vec3(0.0, 0.0, 4.0), t.Vec3(0.0, 0.0, -4.0))
  assertNear(plane.normal.z, 1.0, "HitPlane override normal")
  assertNear(plane.dist, 12.0, "HitPlane override distance")
  return true
end function

// Verify spawn reflection against the expected Quake behavior.
function testSpawnReflection()
  state = testRenderer.createState()
  testRenderer.Test_UseState(state)
  state.viewOrigin = t.Vec3(0.0, 0.0, 10.0)
  state.hitPlaneOverride = t.Plane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2, 0)
  slot = testRenderer.Test_Spawn(t.Vec3(0.0, 0.0, 0.0))
  assertEqual(slot, 0, "first free puff slot")
  puff = state.puffs[0]
  assertNear(puff.length, 8.0, "spawn length")
  assertNear(puff.reflect.x, 0.0, "reflection x")
  assertNear(puff.reflect.y, 0.0, "reflection y")
  assertNear(puff.reflect.z, 1.0, "reflection z")
  assertNear(puff.normal.z, 1.0, "stored plane normal")
  return true
end function

// Verify draw geometry and decay against the expected Quake behavior.
function testDrawGeometryAndDecay()
  state = testRenderer.createState()
  testRenderer.Test_UseState(state)
  state.frameTime = 0.25
  puff = state.puffs[0]
  puff.origin = t.Vec3(1.0, 2.0, 3.0)
  puff.normal = t.Vec3(0.0, 0.0, 1.0)
  puff.up = t.Vec3(1.0, 0.0, 0.0)
  puff.right = t.Vec3(0.0, 1.0, 0.0)
  puff.reflect = t.Vec3(0.0, 0.0, 1.0)
  puff.length = 8.0
  trace = testRenderer.DrawPuff(puff)
  assertEqual(trace[0], "puff", "draw trace type")
  assertEqual(len(trace[1]), 12, "three quad sides")
  assertEqual(len(trace[2]), 3, "triangle cap")
  assertNear(trace[1][0][0], 1.0, "first quad x")
  assertNear(trace[1][0][1], 4.0, "first quad y")
  assertNear(trace[1][0][2], 3.0, "first quad z")
  assertNear(puff.length, 7.5, "host frametime decay")
  return true
end function

// Verify draw active only against the expected Quake behavior.
function testDrawActiveOnly()
  state = testRenderer.createState()
  testRenderer.Test_UseState(state)
  state.frameTime = 0.5
  state.puffs[2].origin = t.Vec3(0.0, 0.0, 0.0)
  state.puffs[2].up = t.Vec3(1.0, 0.0, 0.0)
  state.puffs[2].right = t.Vec3(0.0, 1.0, 0.0)
  state.puffs[2].reflect = t.Vec3(0.0, 0.0, 1.0)
  state.puffs[2].length = 2.0
  commands = testRenderer.Test_Draw()
  assertEqual(len(commands), 1, "only active puff drawn")
  assertNear(state.puffs[2].length, 1.0, "active puff decayed")
  assertEqual(len(testRenderer.Test_CommandTrace()), 1, "draw trace retained")
  return true
end function

// Verify capacity against the expected Quake behavior.
function testCapacity()
  state = testRenderer.createState()
  testRenderer.Test_UseState(state)
  state.viewOrigin = t.Vec3(0.0, 0.0, 10.0)
  state.hitPlaneOverride = t.Plane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2, 0)
  index = 0
  while index < testRenderer.MAX_PUFFS
    state.puffs[index].length = 1.0
    index = index + 1
  end while
  assertEqual(testRenderer.Test_Spawn(t.Vec3(0.0, 0.0, 0.0)), false, "full puff pool rejects spawn")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  testInitAndHitPlane()
  testSpawnReflection()
  testDrawGeometryAndDecay()
  testDrawActiveOnly()
  testCapacity()
  print "gl_test parity tests: 5/5 passed"
  return 0
end function
