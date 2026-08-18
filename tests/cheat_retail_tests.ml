/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail id1 regressions for stock cheats and MiniQuake AI invisibility.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.keys as keys
import miniquake.native as native
import miniquake.quakec.vm as vm
import miniquake.server as server

// Shut down the retail session and identify the violated cheat invariant.
function fail(session, message)
  if session is not void then host.shutdown(session) end if
  print "MiniQuake retail cheat test: FAIL"
  print "  " + message
  return 1
end function

// Run one complete local client/server frame and preserve useful diagnostics.
function runFrame(session, label)
  result = try(host.frame(session, 0.02))
  if result is error then return error(9890, label + ": " + result.message) end if
  return true
end function

// Invoke the stock id1 T_Damage entry point with the player as its target.
function damagePlayer(session, amount)
  machine = session.server.machine
  clientIndex = session.server.clients[0].edictIndex
  vm.setWord(machine, 4, clientIndex)
  vm.setWord(machine, 7, 0)
  vm.setWord(machine, 10, 0)
  vm.setGlobalFloat(machine, 13, amount)
  result = try(server.executeQcFunction(session.server, "T_Damage", 0, 0))
  if result is error then return result end if
  if not result then return error(9891, "retail progs.dat has no T_Damage") end if
  server.syncPlayerFromQuakeC(session.server, session.server.clients[0], session.player)
  return true
end function

// Find one live stock monster to exercise immediate invisible target clearing.
function findMonster(session)
  runtime = session.server.machine.context.edicts
  entityIndex = session.server.maxClients + 1
  while entityIndex < runtime.numEdicts
    if not runtime.freeFlags[entityIndex] then
      flags = native.trunc(server.qcFloat(session.server.machine, entityIndex, "flags", 0.0))
      if (flags & c.FL_MONSTER) != 0 then return entityIndex end if
    end if
    entityIndex = entityIndex + 1
  end while
  return -1
end function

// Parse arguments and run cheats through the production loopback command path.
function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeCheatRetailTests.exe BASE [GAME]"
    return 2
  end if
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  session = host.create([
    "-basedir", args[0], "-game", game, "-headless", "-nosound", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, initialized.message) end if

  initialHealth = session.player.health
  if not host.executeCommand(session, "god") then return fail(session, "god command was rejected") end if
  framed = try(runFrame(session, "enable god"))
  if framed is error then return fail(session, framed.message) end if
  if (session.player.flags & c.FL_GODMODE) == 0 then return fail(session, "god flag did not reach PlayerState") end if
  damaged = try(damagePlayer(session, 25.0))
  if damaged is error then return fail(session, damaged.message) end if
  if session.player.health != initialHealth then return fail(session, "godmode player took damage") end if

  host.executeCommand(session, "god")
  runFrame(session, "disable god")
  if (session.player.flags & c.FL_GODMODE) != 0 then return fail(session, "second god command did not disable the flag") end if
  damaged = try(damagePlayer(session, 25.0))
  if damaged is error then return fail(session, damaged.message) end if
  if session.player.health >= initialHealth then return fail(session, "ordinary T_Damage was unexpectedly blocked") end if

  host.executeCommand(session, "give 8 1")
  runFrame(session, "give lightning gun")
  if (session.player.items & c.IT_LIGHTNING) == 0 then return fail(session, "give 8 did not grant the lightning gun") end if
  host.executeCommand(session, "give s 77")
  runFrame(session, "give shells")
  if session.player.shells != 77 then return fail(session, "give s did not grant 77 shells") end if
  host.executeCommand(session, "give h 123")
  runFrame(session, "give health")
  if session.player.health != 123.0 then return fail(session, "give h did not set health") end if

  // Reproduce console pause: the impulse arrives during a non-simulating frame,
  // followed by a neutral move packet before gameplay resumes.
  session.console.active = true
  keys.setDestination(keys.KEY_CONSOLE)
  host.executeCommand(session, "impulse 9")
  runFrame(session, "queue impulse 9 while console is active")
  runFrame(session, "retain impulse 9 across neutral console frame")
  session.console.active = false
  keys.setDestination(keys.KEY_GAME)
  runFrame(session, "consume impulse 9 in QuakeC")
  weaponMask = c.IT_SHOTGUN | c.IT_SUPER_SHOTGUN | c.IT_NAILGUN | c.IT_SUPER_NAILGUN |
    c.IT_GRENADE_LAUNCHER | c.IT_ROCKET_LAUNCHER | c.IT_LIGHTNING
  if (session.player.items & weaponMask) != weaponMask then return fail(session, "impulse 9 did not grant all stock weapons") end if

  previousServerFlags = native.trunc(vm.namedGlobalFloat(session.server.machine, "serverflags"))
  host.executeCommand(session, "impulse 11")
  runFrame(session, "consume impulse 11 in QuakeC")
  expectedServerFlags = previousServerFlags * 2 + 1
  if native.trunc(vm.namedGlobalFloat(session.server.machine, "serverflags")) != expectedServerFlags then
    return fail(session, "impulse 11 did not advance stock serverflags")
  end if

  host.executeCommand(session, "impulse 255")
  runFrame(session, "consume impulse 255 in QuakeC")
  if (session.player.items & c.IT_QUAD) == 0 then return fail(session, "impulse 255 did not grant Quad Damage") end if
  if server.qcFloat(session.server.machine, session.server.clients[0].edictIndex, "super_damage_finished", 0.0) <= session.server.time then
    return fail(session, "impulse 255 did not set the Quad Damage timeout")
  end if

  monsterIndex = findMonster(session)
  if monsterIndex < 0 then return fail(session, "e1m1 supplied no live monster for invisible regression") end if
  clientIndex = session.server.clients[0].edictIndex
  server.setQcEntityWord(session.server, monsterIndex, "enemy", clientIndex)
  server.setQcEntityWord(session.server, monsterIndex, "oldenemy", clientIndex)
  server.setQcEntityWord(session.server, monsterIndex, "goalentity", clientIndex)
  host.executeCommand(session, "invisible")
  runFrame(session, "enable invisible")
  if (session.player.flags & c.FL_NOTARGET) == 0 then return fail(session, "invisible did not set FL_NOTARGET") end if
  if server.qcWord(session.server.machine, monsterIndex, "enemy", -1) == clientIndex then return fail(session, "monster retained player enemy while invisible") end if
  if server.qcWord(session.server.machine, monsterIndex, "oldenemy", -1) == clientIndex then return fail(session, "monster retained player oldenemy while invisible") end if
  if server.qcWord(session.server.machine, monsterIndex, "goalentity", -1) == clientIndex then return fail(session, "monster retained player goalentity while invisible") end if
  host.executeCommand(session, "invisible")
  runFrame(session, "disable invisible")
  if (session.player.flags & c.FL_NOTARGET) != 0 then return fail(session, "second invisible command did not disable the flag") end if

  host.shutdown(session)
  print "MiniQuake retail cheat test: PASS"
  print "  god_damage=blocked ordinary_damage=applied give=weapons/ammo/health impulse9=all impulse11=runes impulse255=quad invisible=AI-notarget"
  return 0
end function
