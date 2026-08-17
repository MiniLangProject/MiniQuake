/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regressions for solid client collision and QuakeC telefrag triggers.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.mathlib as math
import miniquake.physics as physics
import miniquake.player_move as movement
import miniquake.server as server
import miniquake.server_collision as collision
import miniquake.quakec.vm as vm
import miniquake.types as t

// Shut down the retail session and identify the violated collision invariant.
function fail(session, message)
  if session is not void then host.shutdown(session) end if
  print "MiniQuake player collision/telefrag retail test: FAIL"
  print "  " + message
  return 1
end function

// Publish one PlayerState origin to its QuakeC edict and area link.
function placePlayer(session, clientValue, player, origin)
  player.origin = math.copy(origin)
  player.oldOrigin = math.copy(origin)
  player.velocity = t.Vec3(0.0, 0.0, 0.0)
  player.moveType = c.MOVETYPE_WALK
  player.health = 100.0
  server.syncPlayerToQuakeC(session.server, clientValue, player)
  collision.linkEntity(session.server, clientValue.edictIndex, false)
  return true
end function

// Exercise stock progs.dat spawn_tdeath through the production force_retouch path.
function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakePlayerCollisionTelefragRetailTests.exe BASE [GAME]"
    return 2
  end if
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  session = host.create([
    "-basedir", args[0], "-game", game, "-listen", "2", "-headless", "-nosound", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, initialized.message) end if

  first = session.server.clients[0]
  second = session.server.clients[1]
  if not first.active or not first.spawned then return fail(session, "listen client did not spawn") end if
  second.active = true
  second.spawned = false
  second.name = "telefrag target"
  second.playerState = movement.create(math.copy(session.player.origin), math.copy(session.player.viewAngles))
  spawnBytes = try(server.writeSpawn(session.server, second, second.playerState))
  if spawnBytes is error then return fail(session, "second client spawn: " + spawnBytes.message) end if
  server.writeBegin(second)

  // Keep both hulls at one valid player origin. A regular move must see the
  // other SOLID_SLIDEBOX before QuakeC resolves the deliberate overlap.
  overlap = math.copy(session.player.origin)
  placePlayer(session, first, session.player, overlap)
  placePlayer(session, second, second.playerState, overlap)
  trace = collision.move(
    session.server, overlap, session.player.mins, session.player.maxs,
    math.add(overlap, t.Vec3(64.0, 0.0, 0.0)), c.MOVE_NORMAL, first.edictIndex,
  )
  if not trace.startSolid or trace.entity != second.edictIndex then
    return fail(session, "overlapping client hull was absent from SV_Move")
  end if

  // id1 spawn_tdeath takes the destination vector and its protected owner.
  // Populate the VM parameter registers exactly as its QuakeC caller does.
  vm.setVector(session.server.machine, 4, overlap)
  vm.setWord(session.server.machine, 7, first.edictIndex)
  spawned = try(server.executeQcFunction(session.server, "spawn_tdeath", first.edictIndex, 0))
  if spawned is error then
    for each line in session.server.machine.context.consoleLines
      print "  QC: " + line
    end for
    return fail(session, "spawn_tdeath: " + spawned.message)
  end if
  if not spawned then return fail(session, "retail progs.dat has no spawn_tdeath") end if
  forceOffset = vm.globalOffset(session.server.machine, "force_retouch")
  if forceOffset < 0 or vm.globalFloat(session.server.machine, forceOffset) <= 0.0 then
    return fail(session, "spawn_tdeath did not request force_retouch")
  end if

  frameResult = try(host.frame(session, 0.02))
  if frameResult is error then return fail(session, frameResult.message) end if
  victimHealth = server.qcFloat(session.server.machine, second.edictIndex, "health", 100.0)
  if victimHealth > 0.0 then return fail(session, "overlapped client survived teledeath: health=" + victimHealth) end if

  // Let the 0.2-second teledeath helpers expire, then reproduce an ordinary
  // full player overlap with no active teleport protection. The movement
  // recovery must separate the hulls instead of leaving both clients wedged.
  settle = 0
  while settle < 15
    settled = try(host.frame(session, 0.02))
    if settled is error then return fail(session, settled.message) end if
    settle = settle + 1
  end while
  overlap = math.copy(session.player.origin)
  session.player.teleportTime = 0.0
  second.playerState.teleportTime = 0.0
  placePlayer(session, first, session.player, overlap)
  placePlayer(session, second, second.playerState, overlap)
  session.player.oldOrigin = math.copy(overlap)
  server.setQcEntityFloat(session.server, second.edictIndex, "takedamage", 2.0)
  recovered = physics.checkStuck(
    session.player, session.server.worldModel, session.server, first.edictIndex,
  )
  if not recovered then return fail(session, "full client overlap was not recovered") end if
  if collision.testEntityPosition(session.server, first.edictIndex) >= 0 then
    return fail(session, "recovered client remains inside another solid actor")
  end if

  // The recovery is keyed to SOLID_SLIDEBOX, not to client slot numbers, so
  // the identical full-overlap case must also escape a live monster hull.
  placePlayer(session, first, session.player, overlap)
  placePlayer(session, second, second.playerState, overlap)
  server.setQcEntityFloat(session.server, second.edictIndex, "flags", c.FL_MONSTER)
  collision.linkEntity(session.server, second.edictIndex, false)
  session.player.oldOrigin = math.copy(overlap)
  recovered = physics.checkStuck(
    session.player, session.server.worldModel, session.server, first.edictIndex,
  )
  if not recovered then return fail(session, "full monster overlap was not recovered") end if
  if collision.testEntityPosition(session.server, first.edictIndex) >= 0 then
    return fail(session, "recovered client remains inside the monster hull")
  end if

  host.shutdown(session)
  print "MiniQuake player collision/telefrag retail test: PASS"
  return 0
end function
