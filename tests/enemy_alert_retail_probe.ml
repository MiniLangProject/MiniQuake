/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail diagnostic for the first monster-awareness transition.
*/
import miniquake.host as host
import miniquake.server as server
import miniquake.server_collision as collision
import miniquake.platform.win32 as win
import miniquake.optimization_baseline as baseline
import miniquake.constants as c
import miniquake.quakec.vm as vm

// Measure the first real QuakeC transition from idle monster to acquired enemy.
function main(args)
  if len(args) < 1 then print "usage: probe BASE"; return 2 end if
  session = host.create([
    "-basedir", args[0], "-game", "id1", "-noautosaveconfig",
    "-window", "-width", "1280", "-height", "720", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then print initialized.message; return 1 end if
  machine = session.server.machine
  count = machine.context.edicts.numEdicts
  index = 1
  while index < count
    name = server.qcString(machine, index, "classname", "")
    if len(bytes(name)) >= 8 and decode(slice(bytes(name), 0, 8)) == "monster_" then
      origin = server.qcVector(machine, index, "origin", session.player.origin)
      print "monster " + index + " " + name + " origin=" + origin.x + "," + origin.y + "," + origin.z + " enemy=" + server.qcWord(machine, index, "enemy", 0) + " think=" + server.qcFloat(machine, index, "nextthink", 0.0)
    end if
    index = index + 1
  end while
  print "player origin=" + session.player.origin.x + "," + session.player.origin.y + "," + session.player.origin.z

  // Soldier 88 is the first ordinary e1m1 guard. Move him onto the clear
  // spawn corridor while preserving the player's normal camera/PVS.
  target = server.qcVector(machine, 88, "origin", session.player.origin)
  target.x = session.player.origin.x
  target.y = session.player.origin.y + 128.0
  target.z = session.player.origin.z
  server.setQcEntityVector(session.server, 88, "origin", target)
  collision.linkEntity(session.server, 88, false)
  session.player.viewAngles.x = 0.0
  session.player.viewAngles.y = 90.0
  session.player.viewAngles.z = 0.0
  session.client.command.viewAngles.x = 0.0
  session.client.command.viewAngles.y = 90.0
  session.client.command.viewAngles.z = 0.0
  // FindTarget normally sets enemy immediately before calling FoundTarget.
  // Invoke that same stock QuakeC transition deterministically so the probe
  // does not depend on the rotating checkclient slot or random think offsets.
  server.setQcEntityWord(session.server, 88, "enemy", 1)
  vm.setWord(machine, c.QC_GLOBAL_SELF, 88)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, session.server.time)
  foundTarget = vm.functionIndex(machine, "FoundTarget")
  transitionStarted = win.ticks()
  transitionResult = try(vm.execute(machine, foundTarget))
  transitionFinished = win.ticks()
  if transitionResult is error then print transitionResult.message; host.shutdown(session); return 4 end if
  print "FoundTarget ms=" + (transitionFinished - transitionStarted) + " function=" + foundTarget
  gc_collect()

  previousEnemy = server.qcWord(machine, 88, "enemy", 0)
  frameIndex = 0
  alertedFrame = -1
  if previousEnemy != 0 then alertedFrame = 0 end if
  baseline.configure(60)
  while frameIndex < 60
    started = win.ticks()
    result = try(host.frame(session, 0.02))
    finished = win.ticks()
    if result is error then print result.message; host.shutdown(session); return 1 end if
    currentEnemy = server.qcWord(machine, 88, "enemy", 0)
    duration = finished - started
    if duration >= 10 or currentEnemy != previousEnemy then
      print "frame=" + frameIndex + " ms=" + duration + " enemy=" + previousEnemy + "->" + currentEnemy
    end if
    if currentEnemy != 0 and alertedFrame < 0 then alertedFrame = frameIndex end if
    previousEnemy = currentEnemy
    frameIndex = frameIndex + 1
  end while
  baseline.disable()
  baseline.printSummary("enemy-alert", "e1m1")
  baseline.printSlowFrames(20)
  print "alerted_frame=" + alertedFrame
  host.shutdown(session)
  if alertedFrame < 0 then return 3 end if
  return 0
end function
