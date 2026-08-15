/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused sv_move.c monster-step, chase-direction and MoveToGoal fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.server as server
import miniquake.server_move as movePort
import miniquake.quakec.vm as vm

struct MoveTestMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Assert exact equality and report both values on failure.
function moveAssertEqual(actual, expected, name)
  if actual != expected then return error(9960, name) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function moveAssertTrue(value, name)
  if value != true then return error(9961, name) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function moveAssertNear(actual, expected, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > 0.05 then return error(9962, name) end if
  return true
end function

// Create and initialize move map.
function makeMoveMap(backContents, frontContents)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -2, -1, t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 256.0), 0, 0)
  backLeaf = t.BspLeaf(backContents, -1, t.Vec3(-256.0, -256.0, -256.0), t.Vec3(256.0, 256.0, 0.0), 0, 0, bytes(4))
  frontLeaf = t.BspLeaf(frontContents, -1, t.Vec3(-256.0, -256.0, 0.0), t.Vec3(256.0, 256.0, 256.0), 0, 0, bytes(4))
  model = t.BspModel(
    t.Vec3(-256.0, -256.0, -256.0),
    t.Vec3(256.0, 256.0, 256.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  clipNode = t.BspClipNode(0, frontContents, backContents)
  return MoveTestMap([model], [node], [clipNode], [plane], [backLeaf, frontLeaf])
end function

// Transfer data for field definitions.
function moveFieldDefinitions()
  return [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_VECTOR, 1, 0, "origin"),
    t.QuakeCDef(c.EV_VECTOR, 4, 0, "angles"),
    t.QuakeCDef(c.EV_VECTOR, 7, 0, "mins"),
    t.QuakeCDef(c.EV_VECTOR, 10, 0, "maxs"),
    t.QuakeCDef(c.EV_FLOAT, 13, 0, "movetype"),
    t.QuakeCDef(c.EV_FLOAT, 14, 0, "solid"),
    t.QuakeCDef(c.EV_FLOAT, 15, 0, "flags"),
    t.QuakeCDef(c.EV_ENTITY, 16, 0, "groundentity"),
    t.QuakeCDef(c.EV_ENTITY, 17, 0, "enemy"),
    t.QuakeCDef(c.EV_ENTITY, 18, 0, "goalentity"),
    t.QuakeCDef(c.EV_FLOAT, 19, 0, "ideal_yaw"),
    t.QuakeCDef(c.EV_FLOAT, 20, 0, "yaw_speed"),
    t.QuakeCDef(c.EV_STRING, 21, 0, "model"),
  ]
end function

// Create and initialize move fixture.
function makeMoveFixture(entityCount, map)
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "sv_move_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    [],
    moveFieldDefinitions(),
    [dummy],
    bytes(1),
    vm.zeroArray(64),
    24,
  )
  machine = vm.create(program, entityCount)
  game = server.create(1)
  runtime = server.createEdictRuntime(entityCount, entityCount - 1)
  contextValue = server.createQuakeCContext(game, void, void, void, runtime)
  vm.setContext(machine, contextValue)
  machine.edictFree = runtime.freeFlags
  index = 0
  while index < entityCount
    runtime.freeFlags[index] = false
    index = index + 1
  end while
  game.machine = machine
  game.worldModel = map
  game.active = true
  contextValue.randomSeed = 0
  return game
end function

// Update module state for move entity.
function setMoveEntity(machine, index, origin, flags)
  vm.setEntityVector(machine, index, 1, origin)
  vm.setEntityVector(machine, index, 4, t.Vec3(0.0, 0.0, 0.0))
  vm.setEntityVector(machine, index, 7, t.Vec3(-1.0, -1.0, -2.0))
  vm.setEntityVector(machine, index, 10, t.Vec3(1.0, 1.0, 2.0))
  vm.setEntityFloat(machine, index, 13, c.MOVETYPE_STEP)
  vm.setEntityFloat(machine, index, 14, c.SOLID_SLIDEBOX)
  vm.setEntityFloat(machine, index, 15, flags)
  vm.setEntityFloat(machine, index, 20, 360.0)
end function

// Verify bottom and monster step against the expected Quake behavior.
function testBottomAndMonsterStep()
  game = makeMoveFixture(4, makeMoveMap(c.CONTENTS_SOLID, c.CONTENTS_EMPTY))
  machine = game.machine
  setMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  moveAssertTrue(movePort.SV_CheckBottom(game, 1), "flat floor bottom")
  moveAssertTrue(movePort.SV_movestep(game, 1, t.Vec3(12.0, 0.0, 0.0), true), "flat floor monster step")
  moveAssertNear(vm.entityVector(machine, 1, 1).x, 12.0, "step x")
  moveAssertNear(vm.entityVector(machine, 1, 1).z, 2.0, "step remains on ground")
  moveAssertEqual(vm.entityField(machine, 1, 16), 0, "ground entity world")

  // A partially supported monster is allowed to move into a fall and has its
  // stale FL_ONGROUND bit cleared.
  game.worldModel = makeMoveMap(c.CONTENTS_EMPTY, c.CONTENTS_EMPTY)
  vm.setEntityFloat(machine, 1, 15, c.FL_ONGROUND | c.FL_PARTIALGROUND)
  moveAssertTrue(movePort.SV_movestep(game, 1, t.Vec3(5.0, 0.0, 0.0), false), "partial ground may fall")
  flags = native.trunc(vm.entityFloat(machine, 1, 15))
  moveAssertEqual(flags & c.FL_ONGROUND, 0, "fall clears onground")
  moveAssertEqual(movePort.SV_CheckBottom(game, 1), false, "empty map bottom")
  movePort.SV_FixCheckBottom(game, 1)
  flags = native.trunc(vm.entityFloat(machine, 1, 15))
  moveAssertTrue((flags & c.FL_PARTIALGROUND) != 0, "fix bottom sets partial ground")
  return true
end function

// Verify fly swim and yaw gate against the expected Quake behavior.
function testFlySwimAndYawGate()
  game = makeMoveFixture(4, makeMoveMap(c.CONTENTS_SOLID, c.CONTENTS_EMPTY))
  machine = game.machine
  setMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 100.0), c.FL_FLY)
  setMoveEntity(machine, 2, t.Vec3(30.0, 0.0, 0.0), c.FL_ONGROUND)
  vm.setEntityField(machine, 1, 17, 2)
  moveAssertTrue(movePort.SV_movestep(game, 1, t.Vec3(5.0, 0.0, 0.0), false), "fly pursuit step")
  moveAssertNear(vm.entityVector(machine, 1, 1).z, 92.0, "fly closes vertical gap")

  game.worldModel = makeMoveMap(c.CONTENTS_WATER, c.CONTENTS_EMPTY)
  setMoveEntity(machine, 1, t.Vec3(0.0, 0.0, -10.0), c.FL_SWIM)
  vm.setEntityField(machine, 1, 17, 0)
  moveAssertEqual(movePort.SV_movestep(game, 1, t.Vec3(0.0, 0.0, 20.0), false), false, "swimmer may not leave water")
  moveAssertNear(vm.entityVector(machine, 1, 1).z, -10.0, "rejected swim origin")

  game.worldModel = makeMoveMap(c.CONTENTS_SOLID, c.CONTENTS_EMPTY)
  setMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  vm.setEntityVector(machine, 1, 4, t.Vec3(0.0, 180.0, 0.0))
  vm.setEntityFloat(machine, 1, 20, 20.0)
  // SV_StepDirection returns true for a physically possible step, but restores
  // the origin when PF_changeyaw has not turned far enough.
  moveAssertTrue(movePort.SV_StepDirection(game, 1, 90.0, 10.0), "yaw-gated step result")
  moveAssertNear(vm.entityVector(machine, 1, 1).x, 0.0, "yaw gate restores x")
  moveAssertNear(vm.entityVector(machine, 1, 1).y, 0.0, "yaw gate restores y")
  moveAssertNear(vm.entityVector(machine, 1, 4).y, 160.0, "change yaw speed limit")
  return true
end function

// Verify chase close and move to goal against the expected Quake behavior.
function testChaseCloseAndMoveToGoal()
  game = makeMoveFixture(4, makeMoveMap(c.CONTENTS_SOLID, c.CONTENTS_EMPTY))
  machine = game.machine
  setMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  setMoveEntity(machine, 2, t.Vec3(40.0, 40.0, 2.0), c.FL_ONGROUND)
  vm.setEntityFloat(machine, 1, 19, 0.0)
  moveAssertTrue(movePort.SV_NewChaseDir(game, 1, 2, 10.0), "diagonal chase")
  moveAssertNear(vm.entityFloat(machine, 1, 19), 45.0, "direct diagonal yaw")
  moveAssertTrue(vm.entityVector(machine, 1, 1).x > 7.0, "diagonal x progress")
  moveAssertTrue(vm.entityVector(machine, 1, 1).y > 7.0, "diagonal y progress")

  moveAssertEqual(movePort.SV_CloseEnough(game, 1, 2, 1.0), false, "distant goal")
  vm.setEntityVector(machine, 2, 1, t.Vec3(12.0, 12.0, 2.0))
  moveAssertTrue(movePort.SV_CloseEnough(game, 1, 2, 4.0), "near goal")

  vm.setEntityVector(machine, 1, 1, t.Vec3(0.0, 0.0, 2.0))
  vm.setEntityVector(machine, 2, 1, t.Vec3(60.0, 0.0, 2.0))
  vm.setEntityField(machine, 1, 18, 2)
  vm.setEntityField(machine, 1, 17, 0)
  vm.setEntityFloat(machine, 1, 19, 0.0)
  machine.context.randomSeed = 0
  moveAssertTrue(movePort.SV_MoveToGoal(game, 1, 8.0), "move to goal")
  moveAssertTrue(vm.entityVector(machine, 1, 1).x > 7.0, "move to goal progress")

  vm.setEntityFloat(machine, 1, 15, 0.0)
  moveAssertEqual(movePort.SV_MoveToGoal(game, 1, 8.0), false, "airborne monster cannot chase")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/3] bottom and monster step"
  result = try(testBottomAndMonsterStep())
  if result is error then print "bottom/step failed"; return 1 end if
  print "[2/3] fly, swim and yaw gate"
  result = try(testFlySwimAndYawGate())
  if result is error then print "fly/swim/yaw failed"; return 1 end if
  print "[3/3] chase direction and MoveToGoal"
  result = try(testChaseCloseAndMoveToGoal())
  if result is error then print "chase/goal failed"; return 1 end if
  print "SV_MOVE PORT TESTS PASSED (3/3)"
  return 0
end function
