/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail diagnostic for the stock QuakeC monster-death collision transition.
*/
import miniquake.host as host
import miniquake.server as server
import miniquake.server_collision as collision
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op
import miniquake.types as t

// Print the collision fields that determine whether a dead monster blocks.
function printState(game, entityIndex, label)
  machine = game.machine
  mins = server.qcVector(machine, entityIndex, "mins", t.Vec3(0.0, 0.0, 0.0))
  maxs = server.qcVector(machine, entityIndex, "maxs", t.Vec3(0.0, 0.0, 0.0))
  print label +
    " health=" + server.qcFloat(machine, entityIndex, "health", 0.0) +
    " deadflag=" + server.qcFloat(machine, entityIndex, "deadflag", 0.0) +
    " solid=" + server.qcFloat(machine, entityIndex, "solid", 0.0) +
    " flags=" + server.qcFloat(machine, entityIndex, "flags", 0.0) +
    " movetype=" + server.qcFloat(machine, entityIndex, "movetype", 0.0) +
    " th_die=" + server.qcWord(machine, entityIndex, "th_die", 0) +
    " think=" + server.qcWord(machine, entityIndex, "think", 0) +
    " nextthink=" + server.qcFloat(machine, entityIndex, "nextthink", 0.0) +
    " frame=" + server.qcFloat(machine, entityIndex, "frame", 0.0) +
    " mins=" + mins.x + "," + mins.y + "," + mins.z +
    " maxs=" + maxs.x + "," + maxs.y + "," + maxs.z
  return true
end function

// Kill one stock e1m1 soldier and trace the player hull through his corpse.
function main(args)
  if len(args) < 1 then print "usage: probe BASE"; return 2 end if
  session = host.create([
    "-basedir", args[0], "-game", "id1", "-nosound", "-noinput",
    "-window", "-width", "640", "-height", "480", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then print initialized.message; return 1 end if
  machine = session.server.machine
  entityIndex = 88
  origin = t.Vec3(session.player.origin.x, session.player.origin.y + 128.0, session.player.origin.z)
  server.setQcEntityVector(session.server, entityIndex, "origin", origin)
  collision.linkEntity(session.server, entityIndex, false)
  printState(session.server, entityIndex, "alive")

  damage = vm.functionIndex(machine, "T_Damage")
  vm.setWord(machine, op.OFS_PARM0, entityIndex)
  vm.setWord(machine, op.OFS_PARM1, 1)
  vm.setWord(machine, op.OFS_PARM2, 1)
  // Forty damage kills the 30-health soldier without entering the gib path.
  vm.setGlobalFloat(machine, op.OFS_PARM3, 40.0)
  killed = try(vm.execute(machine, damage))
  if killed is error then print killed.message; host.shutdown(session); return 3 end if
  print "T_Damage function=" + damage
  printState(session.server, entityIndex, "dead")
  finish = t.Vec3(session.player.origin.x, session.player.origin.y + 256.0, session.player.origin.z)
  immediateTrace = collision.move(
    session.server, session.player.origin, session.player.mins, session.player.maxs,
    finish, 0, 1,
  )
  print "immediate trace fraction=" + immediateTrace.fraction + " entity=" + immediateTrace.entity + " startsolid=" + immediateTrace.startSolid

  frameIndex = 0
  while frameIndex < 20
    frameResult = try(host.frame(session, 0.05))
    if frameResult is error then print frameResult.message; host.shutdown(session); return 5 end if
    if frameIndex == 0 or frameIndex == 4 or frameIndex == 9 or frameIndex == 19 then
      printState(session.server, entityIndex, "after_" + (frameIndex + 1))
    end if
    frameIndex = frameIndex + 1
  end while

  trace = collision.move(
    session.server, session.player.origin, session.player.mins, session.player.maxs,
    finish, 0, 1,
  )
  print "trace fraction=" + trace.fraction + " entity=" + trace.entity + " startsolid=" + trace.startSolid
  host.shutdown(session)
  if immediateTrace.entity == entityIndex and immediateTrace.fraction < 1.0 then return 6 end if
  if trace.entity == entityIndex and trace.fraction < 1.0 then return 4 end if
  return 0
end function
