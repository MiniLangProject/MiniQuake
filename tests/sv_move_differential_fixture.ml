/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang side of reference/harness/sv_move_oracle.c.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.server as server
import miniquake.server_move as movePort
import miniquake.quakec.vm as vm

// Group the deterministic move differential map fields used by this test fixture.
struct MoveDifferentialMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Exercise differential move map as part of this deterministic regression fixture.
function differentialMoveMap(backContents, frontContents)
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
  return MoveDifferentialMap(
    [model],
    [node],
    [t.BspClipNode(0, frontContents, backContents)],
    [plane],
    [backLeaf, frontLeaf],
  )
end function

// Exercise differential move fields as part of this deterministic regression fixture.
function differentialMoveFields()
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

// Exercise differential move fixture as part of this deterministic regression fixture.
function differentialMoveFixture(map)
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "sv_move_differential.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    [],
    differentialMoveFields(),
    [dummy],
    bytes(1),
    vm.zeroArray(64),
    24,
  )
  machine = vm.create(program, 4)
  game = server.create(1)
  runtime = server.createEdictRuntime(4, 3)
  contextValue = server.createQuakeCContext(game, void, void, void, runtime)
  vm.setContext(machine, contextValue)
  machine.edictFree = runtime.freeFlags
  index = 0
  while index < 4
    runtime.freeFlags[index] = false
    index = index + 1
  end while
  game.machine = machine
  game.worldModel = map
  game.active = true
  contextValue.randomSeed = 0
  return game
end function

// Exercise differential set move entity as part of this deterministic regression fixture.
function differentialSetMoveEntity(machine, index, origin, flags)
  vm.setEntityVector(machine, index, 1, origin)
  vm.setEntityVector(machine, index, 4, t.Vec3(0.0, 0.0, 0.0))
  vm.setEntityVector(machine, index, 7, t.Vec3(-1.0, -1.0, -2.0))
  vm.setEntityVector(machine, index, 10, t.Vec3(1.0, 1.0, 2.0))
  vm.setEntityFloat(machine, index, 13, c.MOVETYPE_STEP)
  vm.setEntityFloat(machine, index, 14, c.SOLID_SLIDEBOX)
  vm.setEntityFloat(machine, index, 15, flags)
  vm.setEntityFloat(machine, index, 16, 0)
  vm.setEntityField(machine, index, 17, 0)
  vm.setEntityField(machine, index, 18, 0)
  vm.setEntityFloat(machine, index, 19, 0.0)
  vm.setEntityFloat(machine, index, 20, 360.0)
end function

// Return differential move number derived from the active module state.
function differentialMoveNumber(value)
  return native.floatText(value)
end function

// Exercise differential move result as part of this deterministic regression fixture.
function differentialMoveResult(value)
  if value then return 1 end if
  return 0
end function

// Add move to the destination state.
function emitMove(machine, functionName, caseName, result, entityIndex)
  origin = vm.entityVector(machine, entityIndex, 1)
  angles = vm.entityVector(machine, entityIndex, 4)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName + "\",\"result\":" +
    differentialMoveResult(result) + ",\"x\":" + differentialMoveNumber(origin.x) +
    ",\"y\":" + differentialMoveNumber(origin.y) + ",\"z\":" + differentialMoveNumber(origin.z) +
    ",\"yaw\":" + differentialMoveNumber(angles.y) +
    ",\"ideal\":" + differentialMoveNumber(vm.entityFloat(machine, entityIndex, 19)) +
    ",\"flags\":" + native.trunc(vm.entityFloat(machine, entityIndex, 15)) +
    ",\"ground\":" + vm.entityField(machine, entityIndex, 16) + "}"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  floorMap = differentialMoveMap(c.CONTENTS_SOLID, c.CONTENTS_EMPTY)
  emptyMap = differentialMoveMap(c.CONTENTS_EMPTY, c.CONTENTS_EMPTY)
  waterMap = differentialMoveMap(c.CONTENTS_WATER, c.CONTENTS_EMPTY)
  game = differentialMoveFixture(floorMap)
  machine = game.machine

  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  emitMove(machine, "SV_CheckBottom", "floor", movePort.SV_CheckBottom(game, 1), 1)
  game.worldModel = emptyMap
  emitMove(machine, "SV_CheckBottom", "gap", movePort.SV_CheckBottom(game, 1), 1)

  game.worldModel = floorMap
  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  emitMove(machine, "SV_movestep", "floor", movePort.SV_movestep(game, 1, t.Vec3(12.0, 0.0, 0.0), true), 1)
  game.worldModel = emptyMap
  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND | c.FL_PARTIALGROUND)
  emitMove(machine, "SV_movestep", "partial_fall", movePort.SV_movestep(game, 1, t.Vec3(5.0, 0.0, 0.0), false), 1)
  game.worldModel = floorMap
  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 100.0), c.FL_FLY)
  differentialSetMoveEntity(machine, 2, t.Vec3(30.0, 0.0, 0.0), c.FL_ONGROUND)
  vm.setEntityField(machine, 1, 17, 2)
  emitMove(machine, "SV_movestep", "fly", movePort.SV_movestep(game, 1, t.Vec3(5.0, 0.0, 0.0), false), 1)
  game.worldModel = waterMap
  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, -10.0), c.FL_SWIM)
  emitMove(machine, "SV_movestep", "swim_exit", movePort.SV_movestep(game, 1, t.Vec3(0.0, 0.0, 20.0), false), 1)

  game.worldModel = floorMap
  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  vm.setEntityVector(machine, 1, 4, t.Vec3(0.0, 180.0, 0.0))
  vm.setEntityFloat(machine, 1, 20, 20.0)
  emitMove(machine, "SV_StepDirection", "yaw_gate", movePort.SV_StepDirection(game, 1, 90.0, 10.0), 1)

  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  movePort.SV_FixCheckBottom(game, 1)
  emitMove(machine, "SV_FixCheckBottom", "set_partial", true, 1)

  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  differentialSetMoveEntity(machine, 2, t.Vec3(40.0, 40.0, 2.0), c.FL_ONGROUND)
  machine.context.randomSeed = 0
  emitMove(machine, "SV_NewChaseDir", "diagonal", movePort.SV_NewChaseDir(game, 1, 2, 10.0), 1)
  emitMove(machine, "SV_CloseEnough", "distant", movePort.SV_CloseEnough(game, 1, 2, 1.0), 1)
  vm.setEntityVector(machine, 2, 1, t.Vec3(12.0, 12.0, 2.0))
  emitMove(machine, "SV_CloseEnough", "near", movePort.SV_CloseEnough(game, 1, 2, 4.0), 1)

  differentialSetMoveEntity(machine, 1, t.Vec3(0.0, 0.0, 2.0), c.FL_ONGROUND)
  differentialSetMoveEntity(machine, 2, t.Vec3(60.0, 0.0, 2.0), c.FL_ONGROUND)
  vm.setEntityField(machine, 1, 18, 2)
  machine.context.randomSeed = 0
  emitMove(machine, "SV_MoveToGoal", "direct", movePort.SV_MoveToGoal(game, 1, 8.0), 1)
  vm.setEntityFloat(machine, 1, 15, 0.0)
  emitMove(machine, "SV_MoveToGoal", "airborne", movePort.SV_MoveToGoal(game, 1, 8.0), 1)
  return 0
end function
