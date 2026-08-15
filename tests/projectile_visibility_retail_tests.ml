/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regression for Protocol-15 rocket and grenade visibility.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.server as server

// Shut down the session and report a failed projectile invariant.
function projectileFail(session, message)
  host.shutdown(session)
  print "MiniQuake projectile visibility retail test: FAIL"
  print "  " + message
  return 1
end function

// Return projectile.
function findProjectile(session, firstIndex)
  count = server.recomputeEdictCount(session.server)
  index = firstIndex
  while index < count
    if not session.server.machine.context.edicts.freeFlags[index] then
      moveType = server.qcFloat(session.server.machine, index, "movetype", 0.0)
      model = server.qcString(session.server.machine, index, "model", "")
      if moveType == c.MOVETYPE_FLYMISSILE or moveType == c.MOVETYPE_BOUNCE or model == "progs/missile.mdl" or model == "progs/grenade.mdl" then
        return index
      end if
    end if
    index = index + 1
  end while
  return -1
end function

// Report whether a numbered entity reached the active client render list.
function clientSees(session, entityNumber)
  for each item in session.client.visibleEntities
    if item is not void and item.number == entityNumber and item.modelIndex != 0 then return true end if
  end for
  return false
end function

// Spawn real stock-Quake projectiles and require them to cross the full server/client path.
function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeProjectileVisibilityRetailTests.exe BASE [GAME]"
    return 2
  end if
  // Fire repeated stock QuakeC projectiles and inspect each one only after it
  // has crossed the server snapshot and client relink phases.
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  session = host.create([
    "-basedir", args[0], "-game", game, "-headless", "-nosound", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return projectileFail(session, initialized.message) end if

  playerIndex = session.server.clients[0].edictIndex
  names = ["W_FireRocket", "W_FireGrenade"]
  for each functionName in names
    shot = 0
    while shot < 8
      oldCount = server.recomputeEdictCount(session.server)
      fired = try(server.executeQcFunction(session.server, functionName, playerIndex, 0))
      if fired is error then return projectileFail(session, functionName + ": " + fired.message) end if
      if not fired then return projectileFail(session, functionName + " is missing from retail progs.dat") end if
      entityNumber = findProjectile(session, oldCount)
      if entityNumber < 0 then entityNumber = findProjectile(session, session.server.maxClients + 1) end if
      if entityNumber < 0 then return projectileFail(session, functionName + " did not allocate a projectile") end if
      frameResult = try(host.frame(session, 0.02))
      if frameResult is error then return projectileFail(session, functionName + " frame: " + frameResult.message) end if
      if entityNumber >= len(session.server.edicts) then return projectileFail(session, functionName + " mirror was not synchronized") end if
      mirror = session.server.edicts[entityNumber]
      print functionName + " shot=" + (shot + 1) + " edict=" + entityNumber + " model=" + mirror.model + " modelindex=" + mirror.modelIndex + " packet=" + session.server.clients[0].datagramBuffer.curSize + " visible=" + clientSees(session, entityNumber)
      if not clientSees(session, entityNumber) then
        return projectileFail(session, functionName + " edict " + entityNumber + " did not reach the client")
      end if
      shot = shot + 1
    end while
  end for

  host.shutdown(session)
  print "MiniQuake projectile visibility retail test: PASS"
  return 0
end function
