/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused world.c/world.h AreaNode, linking, trigger and collision fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.world as worldPort
import miniquake.server as server
import miniquake.edict as edict

struct TestMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9900, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9901, name + ": expected true") end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.00001 then return error(9902, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Exercise assert vec as part of this deterministic regression fixture.
function assertVec(value, x, y, z, name)
  assertNear(value.x, x, name + ".x")
  assertNear(value.y, y, name + ".y")
  assertNear(value.z, z, name + ".z")
end function

// Create and initialize map.
function makeMap()
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -2, -1, t.Vec3(-100.0, -100.0, -100.0), t.Vec3(100.0, 100.0, 100.0), 0, 0)
  brushNode = t.BspNode(0, -1, -2, t.Vec3(-8.0, -8.0, -8.0), t.Vec3(8.0, 8.0, 8.0), 0, 0)
  solidLeaf = t.BspLeaf(c.CONTENTS_SOLID, -1, t.Vec3(-100.0, -100.0, -100.0), t.Vec3(0.0, 100.0, 100.0), 0, 0, bytes(4))
  emptyLeaf = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(0.0, -100.0, -100.0), t.Vec3(100.0, 100.0, 100.0), 0, 0, bytes(4))
  worldModel = t.BspModel(
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  brushModel = t.BspModel(
    t.Vec3(-8.0, -8.0, -8.0),
    t.Vec3(8.0, 8.0, 8.0),
    t.Vec3(0.0, 0.0, 0.0),
    [1, 1, 1, 1],
    0,
    0,
    0,
  )
  // Hull 0: negative x is solid. Submodel hull 1: positive local x is solid.
  clipNodes = [
    t.BspClipNode(0, c.CONTENTS_EMPTY, c.CONTENTS_SOLID),
    t.BspClipNode(0, c.CONTENTS_SOLID, c.CONTENTS_EMPTY),
  ]
  return TestMap([worldModel, brushModel], [node, brushNode], clipNodes, [plane], [solidLeaf, emptyLeaf])
end function

// Create and initialize entity.
function makeEntity(number, origin, mins, maxs, solid)
  item = edict.create(number)
  item.origin = origin
  item.mins = mins
  item.maxs = maxs
  item.solid = solid
  return item
end function

// Create and initialize fixture.
function makeFixture()
  map = makeMap()
  game = server.create(1)
  game.worldModel = map
  game.time = 3.5

  worldEntity = makeEntity(0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), c.SOLID_BSP)
  worldEntity.moveType = c.MOVETYPE_PUSH
  worldEntity.model = "*0"
  worldEntity.modelIndex = 1

  mover = makeEntity(1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.SOLID_BBOX)
  mover.modelIndex = 1
  trigger = makeEntity(2, t.Vec3(15.0, 0.0, 0.0), t.Vec3(-5.0, -5.0, -5.0), t.Vec3(5.0, 5.0, 5.0), c.SOLID_TRIGGER)
  blocker = makeEntity(3, t.Vec3(30.0, 0.0, 0.0), t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0), c.SOLID_BBOX)
  item = makeEntity(4, t.Vec3(70.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), c.SOLID_BBOX)
  item.flags = c.FL_ITEM
  door = makeEntity(5, t.Vec3(45.0, 0.0, 0.0), t.Vec3(-5.0, -2.0, -3.0), t.Vec3(5.0, 2.0, 3.0), c.SOLID_BSP)
  door.moveType = c.MOVETYPE_PUSH
  door.model = "*1"
  door.modelIndex = 2
  stuck = makeEntity(6, t.Vec3(-10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.SOLID_BBOX)
  monster = makeEntity(7, t.Vec3(20.0, 20.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.SOLID_BBOX)
  monster.flags = c.FL_MONSTER
  game.edicts = [worldEntity, mover, trigger, blocker, item, door, stuck, monster]
  state = worldPort.SV_ClearWorld(game, map)
  return [game, map, state]
end function

// Verify box hull and contents against the expected Quake behavior.
function testBoxHullAndContents()
  hull = worldPort.SV_InitBoxHull()
  assertEqual(worldPort.SV_HullPointContents(hull, 0, t.Vec3(0.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "init zero box boundary")
  hull = worldPort.SV_HullForBox(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  assertEqual(worldPort.SV_HullPointContents(hull, 0, t.Vec3(0.0, 0.0, 0.0)), c.CONTENTS_SOLID, "box point inside")
  assertEqual(worldPort.SV_HullPointContents(hull, 0, t.Vec3(3.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "box point outside")

  plane = t.Plane(t.Vec3(1.0, 0.0, 0.0), 3.0, 0, 0)
  assertEqual(worldPort.SV_BoxOnPlaneSide(t.Vec3(4.0, -1.0, -1.0), t.Vec3(5.0, 1.0, 1.0), plane), 1, "box plane front")
  assertEqual(worldPort.SV_BoxOnPlaneSide(t.Vec3(1.0, -1.0, -1.0), t.Vec3(2.0, 1.0, 1.0), plane), 2, "box plane back")

  fixture = makeFixture()
  state = fixture[2]
  assertEqual(worldPort.SV_TruePointContents(state, t.Vec3(-5.0, 0.0, 0.0)), c.CONTENTS_SOLID, "drawing hull leaf conversion solid")
  assertEqual(worldPort.SV_PointContents(state, t.Vec3(5.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "drawing hull leaf conversion empty")
  return true
end function

// Verify area tree links and pvs against the expected Quake behavior.
function testAreaTreeLinksAndPvs()
  fixture = makeFixture()
  game = fixture[0]
  state = fixture[2]
  assertEqual(len(state.nodes), 31, "AREA_DEPTH node count")
  assertEqual(state.nodes[state.root].axis, 1, "equal XY chooses Y axis")

  worldPort.World_SetTouchEnabled(state, 2, true)
  worldPort.SV_LinkEdict(state, 2, false)
  worldPort.SV_LinkEdict(state, 1, true)
  assertEqual(len(state.touchEvents), 1, "trigger touch count")
  assertEqual(state.touchEvents[0][0], 2, "trigger is self")
  assertEqual(state.touchEvents[0][1], 1, "mover is other")
  assertNear(state.touchEvents[0][2], 3.5, "trigger time")
  assertEqual(len(state.leafNums[1]), 1, "PVS touched leaf count")
  assertEqual(state.leafNums[1][0], 0, "PVS leaf number excludes solid leaf")

  worldPort.SV_LinkEdict(state, 4, false)
  assertVec(state.absMins[4], 55.0, -15.0, 0.0, "FL_ITEM expanded mins")
  assertVec(state.absMaxs[4], 85.0, 15.0, 0.0, "FL_ITEM expanded maxs")

  game.edicts[5].angles = t.Vec3(0.0, 90.0, 0.0)
  worldPort.SV_LinkEdict(state, 5, false)
  assertVec(state.absMins[5], 39.0, -6.0, -6.0, "rotated BSP mins")
  assertVec(state.absMaxs[5], 51.0, 6.0, 6.0, "rotated BSP maxs")

  assertTrue(worldPort.SV_UnlinkEdict(state, 4), "unlink linked entity")
  assertEqual(state.linkedNode[4], -1, "unlink node marker")
  assertEqual(worldPort.SV_UnlinkEdict(state, 4), false, "unlink idempotent")
  return true
end function

// Verify entity hull and rotation against the expected Quake behavior.
function testEntityHullAndRotation()
  fixture = makeFixture()
  game = fixture[0]
  state = fixture[2]
  selected = worldPort.SV_HullForEntity(state, 3, t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  assertVec(selected[0].mins, -3.0, -3.0, -3.0, "bbox Minkowski mins")
  assertVec(selected[0].maxs, 3.0, 3.0, 3.0, "bbox Minkowski maxs")
  assertVec(selected[1], 30.0, 0.0, 0.0, "bbox hull offset")
  trace = worldPort.SV_ClipMoveToEntity(state, 3, t.Vec3(20.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), t.Vec3(40.0, 0.0, 0.0))
  assertEqual(trace.entity, 3, "clip box entity")
  assertTrue(trace.fraction > 0.3 and trace.fraction < 0.4, "clip box fraction")

  game.edicts[5].angles = t.Vec3(0.0, 90.0, 0.0)
  rotated = worldPort.SV_ClipMoveToEntity(state, 5, t.Vec3(45.0, -20.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(45.0, 20.0, 0.0))
  assertEqual(rotated.entity, 5, "rotated brush entity")
  assertTrue(rotated.fraction > 0.4 and rotated.fraction < 0.6, "rotated brush fraction")
  assertTrue(worldAbsolute(rotated.plane.normal.y) > 0.9, "rotated brush plane")
  return true
end function

// Exercise world absolute as part of this deterministic regression fixture.
function worldAbsolute(value)
  if value < 0.0 then return -value end if
  return value
end function

// Exercise link move fixture as part of this deterministic regression fixture.
function linkMoveFixture(state, game)
  worldPort.SV_LinkEdict(state, 1, false)
  worldPort.SV_LinkEdict(state, 3, false)
  game.edicts[5].angles = t.Vec3(0.0, 0.0, 0.0)
  worldPort.SV_LinkEdict(state, 5, false)
  worldPort.SV_LinkEdict(state, 6, false)
end function

// Verify move and filters against the expected Quake behavior.
function testMoveAndFilters()
  fixture = makeFixture()
  game = fixture[0]
  state = fixture[2]
  linkMoveFixture(state, game)
  bounds = worldPort.SV_MoveBounds(
    t.Vec3(10.0, 5.0, 0.0),
    t.Vec3(-1.0, -2.0, -3.0),
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(20.0, -5.0, 4.0),
  )
  assertVec(bounds[0], 8.0, -8.0, -4.0, "SV_MoveBounds mins")
  assertVec(bounds[1], 22.0, 8.0, 8.0, "SV_MoveBounds maxs")

  trace = worldPort.SV_Move(state, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(60.0, 0.0, 0.0), c.MOVE_NORMAL, 1)
  assertEqual(trace.entity, 3, "SV_Move nearest bbox")
  assertTrue(trace.fraction < 0.5, "SV_Move bbox fraction")

  noMonsters = worldPort.SV_Move(state, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(60.0, 0.0, 0.0), c.MOVE_NOMONSTERS, 1)
  assertEqual(noMonsters.entity, 5, "MOVE_NOMONSTERS retains BSP door")

  game.edicts[3].keyValues = [t.EntityPair("owner", "1")]
  ownerFiltered = worldPort.SV_Move(state, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(60.0, 0.0, 0.0), c.MOVE_NORMAL, 1)
  assertEqual(ownerFiltered.entity, 5, "owner filter")

  assertEqual(worldPort.SV_TestEntityPosition(state, 6), 0, "entity in world solid")
  assertEqual(worldPort.SV_TestEntityPosition(state, 1), -1, "entity in open space")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/4] box hull/point contents"
  result = try(testBoxHullAndContents())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[2/4] area links/PVS/triggers"
  result = try(testAreaTreeLinksAndPvs())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[3/4] entity hulls/rotated BSP"
  result = try(testEntityHullAndRotation())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[4/4] SV_Move filters/doors"
  result = try(testMoveAndFilters())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "MiniQuake world.c compatibility tests passed: 4"
  return 0
end function
