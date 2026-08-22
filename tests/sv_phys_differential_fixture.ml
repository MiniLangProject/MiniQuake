/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang side of the pinned sv_phys.c differential fixture.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.physics as physics
import miniquake.server as server
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op

// Group the deterministic physics diff map fields used by this test fixture.
struct PhysicsDiffMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Create and initialize physics map.
function makePhysicsMap(backContents)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -2, -1, t.Vec3(-128.0, -128.0, -128.0), t.Vec3(128.0, 128.0, 128.0), 0, 0)
  backLeaf = t.BspLeaf(backContents, -1, t.Vec3(-128.0, -128.0, -128.0), t.Vec3(0.0, 128.0, 128.0), 0, 0, bytes(4))
  frontLeaf = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(0.0, -128.0, -128.0), t.Vec3(128.0, 128.0, 128.0), 0, 0, bytes(4))
  model = t.BspModel(t.Vec3(-128.0, -128.0, -128.0), t.Vec3(128.0, 128.0, 128.0), t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 1, 0, 0)
  return PhysicsDiffMap([model], [node], [t.BspClipNode(0, c.CONTENTS_EMPTY, backContents)], [plane], [backLeaf, frontLeaf])
end function

// Apply server-physics fields semantics.
function physicsFields()
  return [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_VECTOR, 1, 0, "origin"),
    t.QuakeCDef(c.EV_VECTOR, 4, 0, "velocity"),
    t.QuakeCDef(c.EV_VECTOR, 7, 0, "angles"),
    t.QuakeCDef(c.EV_VECTOR, 10, 0, "avelocity"),
    t.QuakeCDef(c.EV_VECTOR, 13, 0, "mins"),
    t.QuakeCDef(c.EV_VECTOR, 16, 0, "maxs"),
    t.QuakeCDef(c.EV_FLOAT, 19, 0, "movetype"),
    t.QuakeCDef(c.EV_FLOAT, 20, 0, "solid"),
    t.QuakeCDef(c.EV_FLOAT, 21, 0, "flags"),
    t.QuakeCDef(c.EV_ENTITY, 22, 0, "groundentity"),
    t.QuakeCDef(c.EV_FLOAT, 23, 0, "nextthink"),
    t.QuakeCDef(c.EV_FUNCTION, 24, 0, "think"),
    t.QuakeCDef(c.EV_FUNCTION, 25, 0, "touch"),
    t.QuakeCDef(c.EV_FUNCTION, 26, 0, "blocked"),
    t.QuakeCDef(c.EV_FLOAT, 27, 0, "ltime"),
    t.QuakeCDef(c.EV_FLOAT, 28, 0, "gravity"),
    t.QuakeCDef(c.EV_FLOAT, 29, 0, "waterlevel"),
    t.QuakeCDef(c.EV_FLOAT, 30, 0, "watertype"),
    t.QuakeCDef(c.EV_VECTOR, 31, 0, "view_ofs"),
    t.QuakeCDef(c.EV_VECTOR, 34, 0, "v_angle"),
    t.QuakeCDef(c.EV_VECTOR, 37, 0, "oldorigin"),
    t.QuakeCDef(c.EV_FLOAT, 40, 0, "teleport_time"),
    t.QuakeCDef(c.EV_VECTOR, 41, 0, "movedir"),
    t.QuakeCDef(c.EV_FLOAT, 44, 0, "health"),
    t.QuakeCDef(c.EV_ENTITY, 45, 0, "aiment"),
    t.QuakeCDef(c.EV_STRING, 46, 0, "classname"),
    t.QuakeCDef(c.EV_STRING, 47, 0, "model"),
  ]
end function

// Create and initialize physics fixture.
function makePhysicsFixture(entityCount)
  statements = [
    t.QuakeCStatement(op.OP_LOAD_V, 50, 51, 60),
    t.QuakeCStatement(op.OP_RETURN, 60, 0, 0),
    t.QuakeCStatement(op.OP_ADD_F, 70, 71, 70),
    t.QuakeCStatement(op.OP_RETURN, 70, 0, 0),
  ]
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  blocked = t.QuakeCFunction(0, 0, 0, 0, "blocked_fixture", "sv_phys_fixture.qc", 0, [])
  think = t.QuakeCFunction(2, 0, 0, 0, "think_fixture", "sv_phys_fixture.qc", 0, [])
  program = t.QuakeCProgram("sv_phys_fixture.dat", bytes(), c.PROG_VERSION, 0, statements, [], physicsFields(), [dummy, blocked, think], bytes(1), vm.zeroArray(96), 48)
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
  game.worldModel = makePhysicsMap(c.CONTENTS_SOLID)
  game.time = 10.0
  game.active = true
  vm.setWord(machine, 50, 2)
  vm.setWord(machine, 51, 1)
  vm.setGlobalFloat(machine, 70, 0.0)
  vm.setGlobalFloat(machine, 71, 1.0)
  return game
end function

// Update module state for physics box.
function setPhysicsBox(machine, entityIndex, origin, mins, maxs, moveType, solid)
  vm.setEntityVector(machine, entityIndex, 1, origin)
  vm.setEntityVector(machine, entityIndex, 4, t.Vec3(0.0, 0.0, 0.0))
  vm.setEntityVector(machine, entityIndex, 13, mins)
  vm.setEntityVector(machine, entityIndex, 16, maxs)
  vm.setEntityFloat(machine, entityIndex, 19, moveType)
  vm.setEntityFloat(machine, entityIndex, 20, solid)
end function

// Add values to the destination state.
function emitValues(name, caseName, result, origin, velocity, flags, water, waterType, localTime, think, touch, sound, blocked)
  print "{" +
    "\"function\":\"" + name + "\",\"case\":\"" + caseName + "\"," +
    "\"result\":" + result + "," +
    "\"x\":" + native.floatText(origin.x) + "," +
    "\"y\":" + native.floatText(origin.y) + "," +
    "\"z\":" + native.floatText(origin.z) + "," +
    "\"vx\":" + native.floatText(velocity.x) + "," +
    "\"vy\":" + native.floatText(velocity.y) + "," +
    "\"vz\":" + native.floatText(velocity.z) + "," +
    "\"flags\":" + flags + "," +
    "\"water\":" + native.floatText(water) + "," +
    "\"watertype\":" + native.floatText(waterType) + "," +
    "\"ltime\":" + native.floatText(localTime) + "," +
    "\"think\":" + think + ",\"touch\":" + touch + "," +
    "\"sound\":" + sound + ",\"blocked\":" + blocked + "}"
end function

// Add entity to the destination state.
function emitEntity(name, caseName, result, game, index, think, touch, blocked)
  machine = game.machine
  emitValues(
    name, caseName, result,
    vm.entityVector(machine, index, 1),
    vm.entityVector(machine, index, 4),
    native.trunc(vm.entityFloat(machine, index, 21)),
    vm.entityFloat(machine, index, 29),
    vm.entityFloat(machine, index, 30),
    vm.entityFloat(machine, index, 27),
    think, touch, len(machine.context.soundEvents), blocked,
  )
end function

// Exercise fresh as part of this deterministic regression fixture.
function fresh()
  return makePhysicsFixture(8)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  game = fresh()
  physics.SV_CheckAllEnts(game)
  emitEntity("SV_CheckAllEnts", "valid", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityVector(machine, 1, 1, t.Vec3(native.bitsFloat(0x7fc00000), 2.0, 3.0))
  vm.setEntityVector(machine, 1, 4, t.Vec3(native.bitsFloat(0x7fc00000), 5000.0, -5000.0))
  physics.SV_CheckVelocity(game, 1, 2000.0)
  emitEntity("SV_CheckVelocity", "nan_clamp", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityFloat(machine, 1, 23, 10.05)
  vm.setEntityField(machine, 1, 24, 2)
  result = physics.SV_RunThink(game, 1, 0.1)
  emitEntity("SV_RunThink", "due", 1, game, 1, native.trunc(vm.globalFloat(machine, 70)), 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityField(machine, 1, 25, 2)
  vm.setEntityFloat(machine, 1, 20, c.SOLID_BBOX)
  vm.setEntityField(machine, 2, 25, 2)
  vm.setEntityFloat(machine, 2, 20, c.SOLID_BBOX)
  physics.SV_Impact(game, 1, 2)
  emitEntity("SV_Impact", "bidirectional", 1, game, 1, 0, native.trunc(vm.globalFloat(machine, 70)), 0)

  clipped = physics.ClipVelocity(t.Vec3(100.0, -25.0, -50.0), t.Vec3(0.0, 0.0, 1.0), 1.0)
  emitValues("ClipVelocity", "floor", clipped[1], t.Vec3(0.0, 0.0, 0.0), clipped[0], 0, 0.0, 0.0, 0.0, 0, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_FLY, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 4, t.Vec3(-20.0, 5.0, 0.0))
  flyResult = physics.SV_FlyMove(game, 1, 1.0)
  emitEntity("SV_FlyMove", "wall_plane", flyResult[0], game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityVector(machine, 1, 4, t.Vec3(0.0, 0.0, 100.0))
  vm.setEntityFloat(machine, 1, 28, 0.5)
  physics.SV_AddGravity(game, 1, 800.0, 0.1)
  emitEntity("SV_AddGravity", "entity_scale", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  pushTrace = physics.SV_PushEntity(game, 1, t.Vec3(-20.0, 0.0, 0.0))
  emitEntity("SV_PushEntity", "wall", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-4.0, -4.0, -1.0), t.Vec3(4.0, 4.0, 0.0), c.MOVETYPE_PUSH, c.SOLID_BSP)
  vm.setEntityVector(machine, 1, 4, t.Vec3(10.0, 0.0, 0.0))
  vm.setEntityField(machine, 1, 26, 1)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 3.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  vm.setEntityFloat(machine, 2, 21, c.FL_ONGROUND)
  vm.setEntityField(machine, 2, 22, 1)
  setPhysicsBox(machine, 3, t.Vec3(15.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  setPhysicsBox(machine, 4, t.Vec3(19.0, 0.0, 0.0), t.Vec3(-2.0, -2.0, -1.0), t.Vec3(2.0, 2.0, 1.0), c.MOVETYPE_NONE, c.SOLID_BBOX)
  pushResult = physics.SV_PushMove(game, 1, 0.5)
  emitEntity("SV_PushMove", "blocked_rollback", 1, game, 1, 0, 0, 1)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_PUSH, c.SOLID_BSP)
  vm.setEntityFloat(machine, 1, 27, 2.0)
  vm.setEntityFloat(machine, 1, 23, 2.1)
  vm.setEntityField(machine, 1, 24, 2)
  physics.SV_Physics_Pusher(game, 1, 0.25)
  emitEntity("SV_Physics_Pusher", "think_boundary", 1, game, 1, native.trunc(vm.globalFloat(machine, 70)), 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityVector(machine, 1, 1, t.Vec3(4.0, 0.0, 0.0))
  physics.SV_CheckStuck(game, 1)
  emitEntity("SV_CheckStuck", "valid", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_WATER)
  setPhysicsBox(machine, 1, t.Vec3(-8.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 31, t.Vec3(0.0, 0.0, 22.0))
  result = physics.SV_CheckWater(game, 1)
  emitEntity("SV_CheckWater", "submerged", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityVector(machine, 1, 4, t.Vec3(-100.0, 50.0, 0.0))
  vm.setEntityVector(machine, 1, 34, t.Vec3(0.0, 180.0, 0.0))
  wallTrace = t.Trace(false, false, true, false, 0.0, t.Vec3(0.0, 0.0, 0.0), t.Plane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0, 0), 0)
  physics.SV_WallFriction(game, 1, wallTrace)
  emitEntity("SV_WallFriction", "facing", 1, game, 1, 0, 0, 0)

  game = fresh()
  result = physics.SV_TryUnstick(game, 1, t.Vec3(20.0, 0.0, 0.0))
  emitEntity("SV_TryUnstick", "axial", result, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_WALK, c.SOLID_BBOX)
  vm.setEntityFloat(machine, 1, 21, c.FL_ONGROUND)
  vm.setEntityVector(machine, 1, 4, t.Vec3(10.0, 0.0, 0.0))
  physics.SV_WalkMove(game, 1, 0.1)
  emitEntity("SV_WalkMove", "unblocked", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_NOCLIP, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 4, t.Vec3(10.0, 0.0, 0.0))
  physics.SV_Physics_Client(game, 1, 0.1, 800.0, 2000.0)
  emitEntity("SV_Physics_Client", "noclip", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityFloat(machine, 1, 23, 10.05)
  vm.setEntityField(machine, 1, 24, 2)
  physics.SV_Physics_None(game, 1, 0.1)
  emitEntity("SV_Physics_None", "think", 1, game, 1, native.trunc(vm.globalFloat(machine, 70)), 0, 0)

  game = fresh()
  machine = game.machine
  vm.setEntityVector(machine, 1, 4, t.Vec3(10.0, 0.0, 0.0))
  vm.setEntityVector(machine, 1, 10, t.Vec3(0.0, 20.0, 0.0))
  physics.SV_Physics_Noclip(game, 1, 0.1)
  emitEntity("SV_Physics_Noclip", "linear_angular", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_WATER)
  vm.setEntityVector(machine, 1, 1, t.Vec3(-8.0, 0.0, 0.0))
  vm.setEntityFloat(machine, 1, 30, c.CONTENTS_EMPTY)
  physics.SV_CheckWaterTransition(game, 1)
  emitEntity("SV_CheckWaterTransition", "enter", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_FLY, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 4, t.Vec3(-20.0, 0.0, 0.0))
  physics.SV_Physics_Toss(game, 1, 1.0, 800.0, 2000.0)
  emitEntity("SV_Physics_Toss", "wall", 1, game, 1, 0, 0, 0)

  game = fresh()
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_STEP, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 4, t.Vec3(0.0, 0.0, -100.0))
  physics.SV_Physics_Step(game, 1, 0.1, 800.0, 2000.0)
  emitEntity("SV_Physics_Step", "freefall", 1, game, 1, 0, 0, 0)

  game = fresh()
  game.machine.context.edicts.numEdicts = 1
  physics.SV_Physics(game, 0.1, 800.0, 2000.0)
  emitEntity("SV_Physics", "world_frame", 1, game, 0, 0, 0, 0)
  return 0
end function
