/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-028 source-guided sv_phys.c strict WinQuake parity fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.physics as physics
import miniquake.server as server
import miniquake.cvar as cvar
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op
import miniquake.quakec.edict as qcEdict
import miniquake.server_collision as collision

struct PhysicsTestMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Assert exact equality and report both values on failure.
function physAssertEqual(actual, expected, name)
  if actual != expected then return error(9950, name) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function physAssertTrue(value, name)
  if value != true then return error(9951, name + ": expected true") end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function physAssertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.0001 then return error(9952, name) end if
  return true
end function

// Create and initialize physics map.
function makePhysicsMap(backContents)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -2, -1, t.Vec3(-128.0, -128.0, -128.0), t.Vec3(128.0, 128.0, 128.0), 0, 0)
  backLeaf = t.BspLeaf(backContents, -1, t.Vec3(-128.0, -128.0, -128.0), t.Vec3(0.0, 128.0, 128.0), 0, 0, bytes(4))
  frontLeaf = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(0.0, -128.0, -128.0), t.Vec3(128.0, 128.0, 128.0), 0, 0, bytes(4))
  model = t.BspModel(
    t.Vec3(-128.0, -128.0, -128.0),
    t.Vec3(128.0, 128.0, 128.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  clipNode = t.BspClipNode(0, c.CONTENTS_EMPTY, backContents)
  return PhysicsTestMap([model], [node], [clipNode], [plane], [backLeaf, frontLeaf])
end function

// Apply server-physics field definitions semantics.
function physicsFieldDefinitions()
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
    // Extended entvars used by the QUAKE2-conditioned MiniQuake branches.
    t.QuakeCDef(c.EV_VECTOR, 48, 0, "basevelocity"),
    t.QuakeCDef(c.EV_FLOAT, 51, 0, "speed"),
    t.QuakeCDef(c.EV_VECTOR, 52, 0, "absmin"),
    t.QuakeCDef(c.EV_VECTOR, 55, 0, "absmax"),
  ]
end function

// Build deterministic test data for unused builtin.
function fixtureUnusedBuiltin(machine)
  return true
end function

// Test-only builtin used by remove_touch_fixture to model remove(self).
function fixtureFreeSelfBuiltin(machine)
  return qcEdict.free(machine, vm.word(machine, c.QC_GLOBAL_SELF))
end function

// Create and initialize physics fixture.
function makePhysicsFixture(entityCount)
  statements = [
    // blocked(): capture entity 2's origin before SV_PushMove rolls it back.
    t.QuakeCStatement(op.OP_LOAD_V, 50, 51, 60),
    t.QuakeCStatement(op.OP_RETURN, 60, 0, 0),
    // think(): counter += 1.
    t.QuakeCStatement(op.OP_ADD_F, 70, 71, 70),
    t.QuakeCStatement(op.OP_RETURN, 70, 0, 0),
    // pickup_touch(): other.health += 10.
    t.QuakeCStatement(op.OP_LOAD_F, c.QC_GLOBAL_OTHER, 72, 73),
    t.QuakeCStatement(op.OP_ADD_F, 73, 74, 73),
    t.QuakeCStatement(op.OP_ADDRESS, c.QC_GLOBAL_OTHER, 72, 75),
    t.QuakeCStatement(op.OP_STOREP_F, 73, 75, 0),
    t.QuakeCStatement(op.OP_RETURN, 73, 0, 0),
    // remove_touch(): remove(self).
    t.QuakeCStatement(op.OP_CALL0, 76, 0, 0),
    t.QuakeCStatement(op.OP_RETURN, 0, 0, 0),
  ]
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  blocked = t.QuakeCFunction(0, 0, 0, 0, "blocked_fixture", "sv_phys_fixture.qc", 0, [])
  think = t.QuakeCFunction(2, 0, 0, 0, "think_fixture", "sv_phys_fixture.qc", 0, [])
  pickupTouch = t.QuakeCFunction(4, 0, 0, 0, "pickup_touch_fixture", "sv_phys_fixture.qc", 0, [])
  removeTouch = t.QuakeCFunction(9, 0, 0, 0, "remove_touch_fixture", "sv_phys_fixture.qc", 0, [])
  removeBuiltin = t.QuakeCFunction(-1, 0, 0, 0, "remove_fixture_builtin", "sv_phys_fixture.qc", 0, [])
  globalDefinitions = [
    t.QuakeCDef(c.EV_FLOAT, 80, 0, "force_retouch"),
  ]
  program = t.QuakeCProgram(
    "sv_phys_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    statements,
    globalDefinitions,
    physicsFieldDefinitions(),
    [dummy, blocked, think, pickupTouch, removeTouch, removeBuiltin],
    bytes(1),
    vm.zeroArray(96),
    58,
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
  game.worldModel = makePhysicsMap(c.CONTENTS_SOLID)
  game.time = 10.0
  game.active = true
  vm.setWord(machine, 50, 2)
  vm.setWord(machine, 51, 1)
  vm.setGlobalFloat(machine, 70, 0.0)
  vm.setGlobalFloat(machine, 71, 1.0)
  vm.setWord(machine, 72, 44)
  vm.setGlobalFloat(machine, 74, 10.0)
  vm.setWord(machine, 76, 5)
  machine.builtins = [fixtureUnusedBuiltin, fixtureFreeSelfBuiltin]
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

// Verify velocity gravity and think against the expected Quake behavior.
function testVelocityGravityAndThink()
  game = makePhysicsFixture(3)
  machine = game.machine
  vm.setEntityVector(machine, 1, 1, t.Vec3(native.bitsFloat(0x7fc00000), 2.0, 3.0))
  vm.setEntityVector(machine, 1, 4, t.Vec3(native.bitsFloat(0x7f800000), 5000.0, -5000.0))
  bounded = physics.SV_CheckVelocity(game, 1, 2000.0)
  physAssertNear(bounded.x, 0.0, "NaN velocity repair")
  physAssertNear(bounded.y, 2000.0, "positive maxvelocity")
  physAssertNear(bounded.z, -2000.0, "negative maxvelocity")
  repairedOrigin = vm.entityVector(machine, 1, 1)
  physAssertNear(repairedOrigin.x, 0.0, "NaN origin repair")

  vm.setEntityVector(machine, 1, 4, t.Vec3(0.0, 0.0, 100.0))
  vm.setEntityFloat(machine, 1, 28, 0.5)
  gravityVelocity = physics.SV_AddGravity(game, 1, 800.0, 0.1)
  physAssertNear(gravityVelocity.z, 60.0, "per-entity gravity")

  vm.setEntityFloat(machine, 1, 23, 10.05)
  vm.setEntityField(machine, 1, 24, 2)
  physAssertTrue(physics.SV_RunThink(game, 1, 0.1), "think entity survives")
  physAssertNear(vm.globalFloat(machine, 70), 1.0, "think executed once")
  physAssertNear(vm.globalFloat(machine, c.QC_GLOBAL_TIME), 10.05, "think execution time")
  physAssertEqual(vm.word(machine, c.QC_GLOBAL_SELF), 1, "think self")
  physAssertEqual(vm.word(machine, c.QC_GLOBAL_OTHER), 0, "think other is world")
  physAssertNear(vm.entityFloat(machine, 1, 23), 0.0, "nextthink cleared")
  vm.setEntityFloat(machine, 1, 23, 10.08)
  vm.setEntityField(machine, 1, 24, 0)
  missingThink = try(physics.SV_RunThink(game, 1, 0.1))
  physAssertTrue(missingThink is error, "due NULL think follows PR_ExecuteProgram error path")
  physAssertNear(vm.entityFloat(machine, 1, 23), 0.0, "NULL think still clears nextthink")
  return true
end function

// Verify clip and pusher rollback order against the expected Quake behavior.
function testClipAndPusherRollbackOrder()
  clipped = physics.ClipVelocity(t.Vec3(100.0, -25.0, -50.0), t.Vec3(0.0, 0.0, 1.0), 1.0)
  physAssertEqual(clipped[1], 1, "floor blocked bit")
  physAssertNear(clipped[0].z, 0.0, "floor clip")
  wall = physics.ClipVelocity(t.Vec3(-10.0, 4.0, 0.0), t.Vec3(1.0, 0.0, 0.0), 1.0)
  physAssertEqual(wall[1], 2, "wall blocked bit")

  game = makePhysicsFixture(5)
  machine = game.machine
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-4.0, -4.0, -1.0), t.Vec3(4.0, 4.0, 0.0), c.MOVETYPE_PUSH, c.SOLID_BSP)
  vm.setEntityVector(machine, 1, 4, t.Vec3(10.0, 0.0, 0.0))
  vm.setEntityField(machine, 1, 26, 1)
  // Entity 2 is carried successfully and must remain moved during blocked().
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 3.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  vm.setEntityFloat(machine, 2, 21, c.FL_ONGROUND)
  vm.setEntityField(machine, 2, 22, 1)
  // Entity 3 starts inside the pusher's destination; entity 4 prevents escape.
  setPhysicsBox(machine, 3, t.Vec3(15.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  setPhysicsBox(machine, 4, t.Vec3(19.0, 0.0, 0.0), t.Vec3(-2.0, -2.0, -1.0), t.Vec3(2.0, 2.0, 1.0), c.MOVETYPE_NONE, c.SOLID_BBOX)

  pushResult = physics.SV_PushMove(game, 1, 0.5)
  physAssertEqual(pushResult, false, "pusher blocked")
  physAssertNear(vm.globalFloat(machine, 60), 15.0, "blocked callback sees carried entity before rollback")
  physAssertNear(vm.entityVector(machine, 2, 1).x, 10.0, "carried entity rolled back after callback")
  physAssertNear(vm.entityVector(machine, 1, 1).x, 10.0, "pusher origin rolled back")
  physAssertNear(vm.entityFloat(machine, 1, 27), 0.0, "pusher local time rolled back")
  return true
end function

// Verify water and toss against the expected Quake behavior.
function testWaterAndToss()
  game = makePhysicsFixture(3)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_WATER)
  setPhysicsBox(machine, 1, t.Vec3(-8.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  vm.setEntityFloat(machine, 1, 30, c.CONTENTS_EMPTY)
  physics.SV_CheckWaterTransition(game, 1)
  physAssertEqual(native.trunc(vm.entityFloat(machine, 1, 30)), c.CONTENTS_WATER, "water entry type")
  physAssertEqual(len(machine.context.soundEvents), 1, "water entry sound")
  physAssertEqual(machine.context.soundEvents[0][2], "misc/h2ohit1.wav", "water sound sample")

  game.worldModel = makePhysicsMap(c.CONTENTS_SOLID)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX)
  vm.setEntityVector(machine, 2, 4, t.Vec3(-20.0, 0.0, 0.0))
  vm.setEntityFloat(machine, 2, 30, c.CONTENTS_EMPTY)
  physics.SV_Physics_Toss(game, 2, 1.0, 0.0, 2000.0)
  physAssertTrue(vm.entityVector(machine, 2, 1).x >= 0.0, "toss clips against world")
  physAssertNear(vm.entityVector(machine, 2, 4).x, 0.0, "toss impact clips velocity")
  return true
end function

// Verify strict quake one dispatch against the expected Quake behavior.
function testStrictQuakeOneDispatch()
  // The pinned WinQuake/MiniQuake 1.09 build is compiled without QUAKE2.
  // Merely exposing extended fields must not activate currents, conveyors,
  // MOVETYPE_FOLLOW or MOVETYPE_BOUNCEMISSILE.
  game = makePhysicsFixture(5)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_CURRENT_DOWN)
  setPhysicsBox(machine, 1, t.Vec3(-8.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_WALK, c.SOLID_BBOX)
  vm.setEntityVector(machine, 1, 31, t.Vec3(0.0, 0.0, 1.0))
  vm.setEntityVector(machine, 1, 48, t.Vec3(1.0, 2.0, 3.0))
  physics.SV_CheckWater(game, 1)
  physAssertEqual(native.trunc(vm.entityFloat(machine, 1, 29)), 3, "current waterlevel")
  physAssertEqual(native.trunc(vm.entityFloat(machine, 1, 30)), c.CONTENTS_WATER, "current normalizes watertype")
  currentBase = vm.entityVector(machine, 1, 48)
  physAssertNear(currentBase.x, 1.0, "strict Q1 preserves base x")
  physAssertNear(currentBase.y, 2.0, "strict Q1 preserves base y")
  physAssertNear(currentBase.z, 3.0, "strict Q1 ignores Q2 current")

  game = makePhysicsFixture(5)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine, 2, t.Vec3(0.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), 12, c.SOLID_NOT)
  vm.setEntityField(machine, 2, 45, 3)
  vm.setEntityVector(machine, 2, 34, t.Vec3(1.0, 2.0, 3.0))
  vm.setEntityVector(machine, 3, 1, t.Vec3(20.0, 30.0, 40.0))
  followResult = try(physics.SV_Physics(game, 0.1, 800.0, 2000.0))
  physAssertTrue(followResult is error, "MOVETYPE_FOLLOW rejected by Quake 1")

  game = makePhysicsFixture(4)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), 11, c.SOLID_BBOX)
  bounceMissileResult = try(physics.SV_Physics(game, 0.1, 800.0, 2000.0))
  physAssertTrue(bounceMissileResult is error, "MOVETYPE_BOUNCEMISSILE rejected by Quake 1")
  return true
end function

// Verify force retouch against the expected Quake behavior.
function testForceRetouch()
  game = makePhysicsFixture(4)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine, 1, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0), c.MOVETYPE_NONE, c.SOLID_TRIGGER)
  vm.setEntityField(machine, 1, 25, 2)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_NONE, c.SOLID_BBOX)
  vm.setGlobalFloat(machine, 80, 1.0)
  physics.SV_Physics(game, 0.1, 800.0, 2000.0)
  physAssertNear(vm.globalFloat(machine, 70), 1.0, "force_retouch relinks stationary entity")
  physAssertNear(vm.globalFloat(machine, 80), 0.0, "force_retouch decremented after frame")
  return true
end function

// Verify client touch mutation survives frame sync against the expected Quake behavior.
function testClientTouchMutationSurvivesFrameSync()
  game = makePhysicsFixture(4)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  game.active = true
  game.clients[0].active = true
  game.clients[0].spawned = true

  player = physics.createPlayer(t.Vec3(10.0, 0.0, 32.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 25.0
  setPhysicsBox(machine, 1, player.origin, player.mins, player.maxs, c.MOVETYPE_WALK, c.SOLID_SLIDEBOX)
  vm.setEntityFloat(machine, 1, 44, 25.0)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 32.0), t.Vec3(-32.0, -32.0, -32.0), t.Vec3(32.0, 32.0, 32.0), c.MOVETYPE_NONE, c.SOLID_TRIGGER)
  vm.setEntityField(machine, 2, 25, 3)
  collision.linkEntity(game, 2, false)

  registry = cvar.createRegistry()
  server.frameMode(game, player, 0.01, registry, true)
  physAssertNear(vm.entityFloat(machine, 1, 44), 35.0, "pickup touch health remains authoritative")
  physAssertNear(player.health, 35.0, "pickup touch health reaches PlayerState")
  return true
end function

// Verify stationary client still touches triggers against the expected Quake behavior.
function testStationaryClientStillTouchesTriggers()
  game = makePhysicsFixture(4)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)
  game.active = true
  game.clients[0].active = true
  game.clients[0].spawned = true

  player = physics.createPlayer(t.Vec3(10.0, 0.0, 32.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 25.0
  player.moveType = c.MOVETYPE_NONE
  setPhysicsBox(machine, 1, player.origin, player.mins, player.maxs, c.MOVETYPE_NONE, c.SOLID_SLIDEBOX)
  vm.setEntityFloat(machine, 1, 44, 25.0)
  setPhysicsBox(machine, 2, t.Vec3(10.0, 0.0, 32.0), t.Vec3(-32.0, -32.0, -32.0), t.Vec3(32.0, 32.0, 32.0), c.MOVETYPE_NONE, c.SOLID_TRIGGER)
  vm.setEntityField(machine, 2, 25, 3)
  collision.linkEntity(game, 2, false)

  server.frameMode(game, player, 0.01, cvar.createRegistry(), true)
  physAssertNear(player.health, 35.0, "MOVETYPE_NONE client remains linked to triggers")
  return true
end function

// Verify fly move stops when impact removes self against the expected Quake behavior.
function testFlyMoveStopsWhenImpactRemovesSelf()
  game = makePhysicsFixture(3)
  machine = game.machine
  game.worldModel = makePhysicsMap(c.CONTENTS_SOLID)
  setPhysicsBox(
    machine, 2, t.Vec3(10.0, 0.0, 0.0), t.Vec3(-1.0, -1.0, -1.0),
    t.Vec3(1.0, 1.0, 1.0), c.MOVETYPE_TOSS, c.SOLID_BBOX,
  )
  vm.setEntityVector(machine, 2, 4, t.Vec3(-20.0, 0.0, 0.0))
  vm.setEntityField(machine, 2, 25, 4)

  result = physics.SV_FlyMove(game, 2, 1.0)
  physAssertTrue(machine.edictFree[2], "impact callback frees moving entity")
  // ED_Free clears origin. A stale PlayerState write used to restore the
  // impact point after the callback returned.
  physAssertNear(vm.entityVector(machine, 2, 1).x, 0.0, "freed origin remains cleared")
  physAssertEqual(result[0], 2, "wall impact flags survive early stop")
  return true
end function

// Verify multiplayer uses independent player states against the expected Quake behavior.
function testMultiplayerUsesIndependentPlayerStates()
  game = makePhysicsFixture(4)
  machine = game.machine
  game.active = false
  server.resizeClients(game, 2)
  game.active = true
  game.worldModel = makePhysicsMap(c.CONTENTS_EMPTY)

  first = game.clients[0]
  second = game.clients[1]
  first.active = true
  first.spawned = true
  second.active = true
  second.spawned = true
  first.playerState.origin = t.Vec3(10.0, 0.0, 32.0)
  first.playerState.health = 11.0
  first.playerState.moveType = c.MOVETYPE_NONE
  second.playerState.origin = t.Vec3(20.0, 0.0, 32.0)
  second.playerState.health = 22.0
  second.playerState.moveType = c.MOVETYPE_NONE
  setPhysicsBox(machine, 1, first.playerState.origin, first.playerState.mins, first.playerState.maxs, c.MOVETYPE_NONE, c.SOLID_SLIDEBOX)
  setPhysicsBox(machine, 2, second.playerState.origin, second.playerState.mins, second.playerState.maxs, c.MOVETYPE_NONE, c.SOLID_SLIDEBOX)
  vm.setEntityFloat(machine, 1, 44, 11.0)
  vm.setEntityFloat(machine, 2, 44, 22.0)

  hostPlayer = physics.createPlayer(t.Vec3(99.0, 0.0, 32.0), t.Vec3(0.0, 0.0, 0.0))
  hostPlayer.health = 99.0
  registry = cvar.createRegistry()
  server.frameMode(game, hostPlayer, 0.01, registry, true)

  physAssertNear(vm.entityVector(machine, 1, 1).x, 10.0, "first client keeps own origin")
  physAssertNear(vm.entityVector(machine, 2, 1).x, 20.0, "second client keeps own origin")
  physAssertNear(vm.entityFloat(machine, 1, 44), 11.0, "first client keeps own health")
  physAssertNear(vm.entityFloat(machine, 2, 44), 22.0, "second client keeps own health")
  physAssertNear(hostPlayer.origin.x, 99.0, "remote clients do not overwrite host mirror")
  return true
end function

// Execute one named test case and record its pass/fail result.
function parityRun(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify clip floor only against the expected Quake behavior.
function testClipFloorOnly()
  result=physics.ClipVelocity(t.Vec3(4.0,5.0,-6.0),t.Vec3(0.0,0.0,1.0),1.0)
  physAssertEqual(result[1],1,"floor blocked");physAssertNear(result[0].z,0.0,"floor z")
  player=physics.createPlayer(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  physAssertEqual(player.groundEntity,0,"fresh player ground entity is world")
  player.groundEntity=7;player.flags=player.flags|c.FL_ONGROUND;player.onGround=true
  physics.clearGround(player)
  physAssertEqual(player.groundEntity,7,"clearing ground retains valid edict")
  physAssertEqual(player.flags&c.FL_ONGROUND,0,"clearing ground removes flag")
  return true
end function
// Verify clip wall only against the expected Quake behavior.
function testClipWallOnly()
  result=physics.ClipVelocity(t.Vec3(-6.0,5.0,4.0),t.Vec3(1.0,0.0,0.0),1.0)
  physAssertEqual(result[1],2,"wall blocked");physAssertNear(result[0].x,0.0,"wall x")
  return true
end function
// Verify stop epsilon against the expected Quake behavior.
function testStopEpsilon()
  result=physics.ClipVelocity(t.Vec3(0.05,-0.05,0.0),t.Vec3(0.0,0.0,1.0),1.0)
  physAssertNear(result[0].x,0.0,"epsilon x");physAssertNear(result[0].y,0.0,"epsilon y")
  return true
end function
// Verify strict overlap true against the expected Quake behavior.
function testStrictOverlapTrue()
  physAssertTrue(physics.physicsStrictOverlap(t.Vec3(0.0,0.0,0.0),t.Vec3(2.0,2.0,2.0),t.Vec3(1.0,1.0,1.0),t.Vec3(3.0,3.0,3.0)),"strict overlap")
  return true
end function
// Verify strict overlap touch false against the expected Quake behavior.
function testStrictOverlapTouchFalse()
  physAssertEqual(physics.physicsStrictOverlap(t.Vec3(0.0,0.0,0.0),t.Vec3(1.0,1.0,1.0),t.Vec3(1.0,0.0,0.0),t.Vec3(2.0,1.0,1.0)),false,"touch is not overlap")
  return true
end function
// Verify default gravity against the expected Quake behavior.
function testDefaultGravity()
  game=makePhysicsFixture(3);machine=game.machine;setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.MOVETYPE_TOSS,c.SOLID_BBOX)
  vm.setEntityVector(machine,2,4,t.Vec3(0.0,0.0,100.0));vm.setEntityFloat(machine,2,28,0.0)
  physics.SV_AddGravity(game,2,800.0,0.1);physAssertNear(vm.entityVector(machine,2,4).z,20.0,"default gravity")
  return true
end function
// Verify custom gravity against the expected Quake behavior.
function testCustomGravity()
  game=makePhysicsFixture(3);machine=game.machine;setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.MOVETYPE_TOSS,c.SOLID_BBOX)
  vm.setEntityVector(machine,2,4,t.Vec3(0.0,0.0,100.0));vm.setEntityFloat(machine,2,28,0.5)
  physics.SV_AddGravity(game,2,800.0,0.1);physAssertNear(vm.entityVector(machine,2,4).z,60.0,"custom gravity")
  return true
end function
// Verify noclip relink against the expected Quake behavior.
function testNoclipRelink()
  game=makePhysicsFixture(3);machine=game.machine;game.worldModel=makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.MOVETYPE_NOCLIP,c.SOLID_BBOX)
  vm.setEntityVector(machine,2,4,t.Vec3(10.0,0.0,0.0));collision.linkEntity(game,2,false)
  physics.SV_Physics_Noclip(game,2,0.5);physAssertNear(vm.entityVector(machine,2,1).x,15.0,"noclip origin");physAssertNear(vm.entityVector(machine,2,52).x,13.0,"noclip linked absmin")
  return true
end function
// Verify push entity relink against the expected Quake behavior.
function testPushEntityRelink()
  game=makePhysicsFixture(3);machine=game.machine;game.worldModel=makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.MOVETYPE_TOSS,c.SOLID_BBOX);collision.linkEntity(game,2,false)
  physics.SV_PushEntity(game,2,t.Vec3(3.0,0.0,0.0));physAssertNear(vm.entityVector(machine,2,1).x,13.0,"push origin");physAssertNear(vm.entityVector(machine,2,52).x,11.0,"push linked absmin")
  return true
end function
// Verify stationary pusher time against the expected Quake behavior.
function testStationaryPusherTime()
  game=makePhysicsFixture(3);machine=game.machine;setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.MOVETYPE_PUSH,c.SOLID_BSP)
  vm.setEntityFloat(machine,2,27,2.0);physics.SV_PushMove(game,2,0.25);physAssertNear(vm.entityFloat(machine,2,27),2.25,"stationary ltime")
  return true
end function
// Verify strict compatibility marker against the expected Quake behavior.
function testStrictCompatibilityMarker()
  physAssertTrue(physics.strictQuake109(),"strict Quake 1 marker")
  return true
end function
// Verify corpse collapse keeps z against the expected Quake behavior.
function testCorpseCollapseKeepsZ()
  // Directly verify the stock assignment shape used by the blocked-pusher path.
  mins=t.Vec3(-8.0,-8.0,-24.0);collapsed=physics.collapsePusherCorpseBounds(mins)
  physAssertNear(collapsed.x,0.0,"corpse x");physAssertNear(collapsed.y,0.0,"corpse y");physAssertNear(collapsed.z,-24.0,"corpse z")
  return true
end function
// Verify pusher uses expanded bounds against the expected Quake behavior.
function testPusherUsesExpandedBounds()
  game=makePhysicsFixture(3);machine=game.machine;game.worldModel=makePhysicsMap(c.CONTENTS_EMPTY)
  setPhysicsBox(machine,2,t.Vec3(10.0,0.0,0.0),t.Vec3(-4.0,-4.0,-1.0),t.Vec3(4.0,4.0,0.0),c.MOVETYPE_PUSH,c.SOLID_BSP);collision.linkEntity(game,2,false)
  before=collision.entityAbsMin(game,2);vm.setEntityVector(machine,2,4,t.Vec3(10.0,0.0,0.0));physics.SV_PushMove(game,2,0.5)
  after=collision.entityAbsMin(game,2);physAssertNear(after.x,before.x+5.0,"expanded pusher bounds move")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed=0
  if parityRun(1,"velocity/gravity/think",testVelocityGravityAndThink) then passed=passed+1 end if
  if parityRun(2,"clip and pusher rollback",testClipAndPusherRollbackOrder) then passed=passed+1 end if
  if parityRun(3,"water transition and toss",testWaterAndToss) then passed=passed+1 end if
  if parityRun(4,"strict Quake 1 dispatch",testStrictQuakeOneDispatch) then passed=passed+1 end if
  if parityRun(5,"force retouch",testForceRetouch) then passed=passed+1 end if
  if parityRun(6,"clip floor",testClipFloorOnly) then passed=passed+1 end if
  if parityRun(7,"clip wall",testClipWallOnly) then passed=passed+1 end if
  if parityRun(8,"stop epsilon",testStopEpsilon) then passed=passed+1 end if
  if parityRun(9,"strict overlap",testStrictOverlapTrue) then passed=passed+1 end if
  if parityRun(10,"touching boxes are not strict overlap",testStrictOverlapTouchFalse) then passed=passed+1 end if
  if parityRun(11,"default gravity",testDefaultGravity) then passed=passed+1 end if
  if parityRun(12,"custom gravity",testCustomGravity) then passed=passed+1 end if
  if parityRun(13,"noclip relinks",testNoclipRelink) then passed=passed+1 end if
  if parityRun(14,"push entity relinks",testPushEntityRelink) then passed=passed+1 end if
  if parityRun(15,"stationary pusher time",testStationaryPusherTime) then passed=passed+1 end if
  if parityRun(16,"strict compatibility marker",testStrictCompatibilityMarker) then passed=passed+1 end if
  if parityRun(17,"corpse collapse keeps z",testCorpseCollapseKeepsZ) then passed=passed+1 end if
  if parityRun(18,"pusher expanded bounds",testPusherUsesExpandedBounds) then passed=passed+1 end if
  if parityRun(19,"client touch mutation survives frame sync",testClientTouchMutationSurvivesFrameSync) then passed=passed+1 end if
  if parityRun(20,"stationary client relinks triggers",testStationaryClientStillTouchesTriggers) then passed=passed+1 end if
  if parityRun(21,"fly move stops after remove(self)",testFlyMoveStopsWhenImpactRemovesSelf) then passed=passed+1 end if
  if parityRun(22,"multiplayer player states stay independent",testMultiplayerUsesIndependentPlayerStates) then passed=passed+1 end if
  if passed!=22 then return 1 end if
  print "MiniQuake BP-028 server physics tests passed: 22"
  return 0
end function
