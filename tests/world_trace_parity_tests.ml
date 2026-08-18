/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-025 source-guided world.c trace-coordinate and box-hull boundary fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.world_hull as hull
import miniquake.world_bsp as bspworld
import miniquake.world as worldPort
import miniquake.server as server
import miniquake.edict as edict

struct TraceTestMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9250, name + ": expected true") end if
  return true
end function

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9251, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > 0.0001 then return error(9252, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Exercise assert vec as part of this deterministic regression fixture.
function assertVec(actual, expected, name)
  assertNear(actual.x, expected.x, name + ".x")
  assertNear(actual.y, expected.y, name + ".y")
  assertNear(actual.z, expected.z, name + ".z")
end function

// Create and initialize trace map.
function makeTraceMap()
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  worldNode = t.BspNode(0, -1, -2, t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 256.0), 0, 0)
  brushNode = t.BspNode(0, -2, -1, t.Vec3(-64.0, -64.0, -64.0), t.Vec3(64.0, 64.0, 64.0), 0, 0)
  emptyLeaf = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 256.0), 0, 0, bytes(4))
  solidLeaf = t.BspLeaf(c.CONTENTS_SOLID, -1, t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 256.0), 0, 0, bytes(4))
  worldModel = t.BspModel(t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 256.0), t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 1, 0, 0)
  brushModel = t.BspModel(t.Vec3(-64.0, -64.0, -64.0), t.Vec3(64.0, 64.0, 64.0), t.Vec3(0.0, 0.0, 0.0), [1, 1, 1, 1], 0, 0, 0)
  // Hull 0 is built from drawing nodes, so brushNode child0 must resolve to
  // CONTENTS_SOLID and child1 to CONTENTS_EMPTY. The explicit clipnodes below
  // retain the same orientation for hulls 1 and 2.
  // Local x >= 0 is solid; local x < 0 is empty.
  clips = [
    t.BspClipNode(0, c.CONTENTS_EMPTY, c.CONTENTS_EMPTY),
    t.BspClipNode(0, c.CONTENTS_SOLID, c.CONTENTS_EMPTY),
  ]
  return TraceTestMap([worldModel, brushModel], [worldNode, brushNode], clips, [plane], [emptyLeaf, solidLeaf])
end function

// Create and initialize entity.
function makeEntity(number, origin, solid, model)
  item = edict.create(number)
  item.origin = origin
  item.mins = t.Vec3(0.0, 0.0, 0.0)
  item.maxs = t.Vec3(0.0, 0.0, 0.0)
  item.solid = solid
  item.moveType = c.MOVETYPE_PUSH
  item.model = model
  item.modelIndex = number + 1
  return item
end function

// Verify max plane is empty against the expected Quake behavior.
function testMaxPlaneIsEmpty()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  assertEqual(hull.truePointContents(box, t.Vec3(1.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "max plane contents")
  return true
end function

// Verify min plane is solid against the expected Quake behavior.
function testMinPlaneIsSolid()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  assertEqual(hull.truePointContents(box, t.Vec3(-1.0, 0.0, 0.0)), c.CONTENTS_SOLID, "min plane contents")
  return true
end function

// Verify parallel max plane clear against the expected Quake behavior.
function testParallelMaxPlaneClear()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  finish = t.Vec3(1.0, -3.0, 0.0)
  trace = hull.traceLine(box, t.Vec3(1.0, -2.0, 0.0), finish)
  assertNear(trace.fraction, 1.0, "parallel max fraction")
  assertVec(trace.endPosition, finish, "parallel max end")
  return true
end function

// Verify start solid escape against the expected Quake behavior.
function testStartSolidEscape()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  finish = t.Vec3(2.0, 0.0, 0.0)
  trace = hull.traceLine(box, t.Vec3(0.0, 0.0, 0.0), finish)
  assertTrue(trace.startSolid, "start-solid flag")
  assertNear(trace.fraction, 1.0, "start-solid escape fraction")
  assertVec(trace.endPosition, finish, "start-solid escape end")
  return true
end function

// Verify translated brush clear end against the expected Quake behavior.
function testTranslatedBrushClearEnd()
  map = makeTraceMap()
  finish = t.Vec3(70.0, 4.0, 3.0)
  trace = bspworld.traceBrushModel(map, 1, t.Vec3(100.0, 0.0, 0.0), t.Vec3(80.0, 4.0, 3.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), finish)
  assertNear(trace.fraction, 1.0, "translated clear fraction")
  assertVec(trace.endPosition, finish, "translated clear world end")
  return true
end function

// Verify translated brush hit end against the expected Quake behavior.
function testTranslatedBrushHitEnd()
  map = makeTraceMap()
  assertEqual(bspworld.precacheCollisionHulls(map), 3, "precache world hull count")
  pointHull = bspworld.createModelHull(map, 1, 0)
  repeatedPointHull = bspworld.createModelHull(map, 1, 0)
  playerHull = bspworld.createModelHull(map, 1, 1)
  repeatedPlayerHull = bspworld.createModelHull(map, 1, 1)
  assertEqual(nativeRawValue(repeatedPointHull), nativeRawValue(pointHull), "cached submodel point hull identity")
  assertEqual(nativeRawValue(repeatedPlayerHull), nativeRawValue(playerHull), "cached submodel player hull identity")

  // Caching changes object lifetime only; collision coordinates remain exact.
  trace = bspworld.traceBrushModel(map, 1, t.Vec3(100.0, 0.0, 0.0), t.Vec3(80.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(120.0, 0.0, 0.0))
  assertTrue(trace.fraction > 0.49 and trace.fraction < 0.51, "translated hit fraction")
  assertTrue(trace.endPosition.x > 99.9 and trace.endPosition.x < 100.0, "translated hit world end")
  return true
end function

// Verify public clip clear end against the expected Quake behavior.
function testPublicClipClearEnd()
  map = makeTraceMap()
  game = server.create(1)
  game.worldModel = map
  game.edicts = [
    makeEntity(0, t.Vec3(0.0, 0.0, 0.0), c.SOLID_BSP, "*0"),
    makeEntity(1, t.Vec3(100.0, 0.0, 0.0), c.SOLID_BSP, "*1"),
  ]
  state = worldPort.SV_ClearWorld(game, map)
  finish = t.Vec3(70.0, 2.0, 1.0)
  trace = worldPort.SV_ClipMoveToEntity(state, 1, t.Vec3(80.0, 2.0, 1.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), finish)
  assertNear(trace.fraction, 1.0, "public clear fraction")
  assertVec(trace.endPosition, finish, "public clear world end")
  assertEqual(trace.entity, 0, "public clear entity")
  return true
end function

// Verify move bounds expansion against the expected Quake behavior.
function testMoveBoundsExpansion()
  value = worldPort.SV_MoveBounds(t.Vec3(4.0, 5.0, 6.0), t.Vec3(-1.0, -2.0, -3.0), t.Vec3(1.0, 2.0, 3.0), t.Vec3(-4.0, 8.0, 2.0))
  assertVec(value[0], t.Vec3(-6.0, 2.0, -2.0), "move bounds mins")
  assertVec(value[1], t.Vec3(6.0, 11.0, 10.0), "move bounds maxs")
  return true
end function

// Verify clear trace keeps finish object values against the expected Quake behavior.
function testClearTraceKeepsFinishObjectValues()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  finish = t.Vec3(4.0, 5.0, 6.0)
  trace = hull.traceLine(box, t.Vec3(3.0, 5.0, 6.0), finish)
  assertVec(trace.endPosition, finish, "clear exact finish")
  return true
end function

// Verify impact plane distance against the expected Quake behavior.
function testImpactPlaneDistance()
  box = hull.createBoxHull(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  trace = hull.traceLine(box, t.Vec3(-3.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertTrue(trace.fraction > 0.65 and trace.fraction < 0.67, "entry fraction")
  assertNear(trace.plane.normal.x, -1.0, "entry normal")
  assertNear(trace.plane.dist, 1.0, "entry plane distance")
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(name, fn)
  result = try(fn())
  if result is error then print "FAIL: " + name + ": " + result.message; return false end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed = 0
  if run("max plane empty", testMaxPlaneIsEmpty) then passed = passed + 1 else return 1 end if
  if run("min plane solid", testMinPlaneIsSolid) then passed = passed + 1 else return 1 end if
  if run("parallel maximum plane", testParallelMaxPlaneClear) then passed = passed + 1 else return 1 end if
  if run("start-solid escape", testStartSolidEscape) then passed = passed + 1 else return 1 end if
  if run("translated brush clear", testTranslatedBrushClearEnd) then passed = passed + 1 else return 1 end if
  if run("translated brush hit", testTranslatedBrushHitEnd) then passed = passed + 1 else return 1 end if
  if run("public clip clear", testPublicClipClearEnd) then passed = passed + 1 else return 1 end if
  if run("move bounds", testMoveBoundsExpansion) then passed = passed + 1 else return 1 end if
  if run("clear finish", testClearTraceKeepsFinishObjectValues) then passed = passed + 1 else return 1 end if
  if run("impact plane", testImpactPlaneDistance) then passed = passed + 1 else return 1 end if
  print "MiniQuake BP-025 world trace tests passed: " + passed
  return 0
end function
