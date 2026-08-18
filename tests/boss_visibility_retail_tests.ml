/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regression for Chthon's dormant-to-visible QuakeC transition in e1m7.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.server as server

// Shut down the retail session and identify the violated boss invariant.
function fail(session, message)
  if session is not void then host.shutdown(session) end if
  print "MiniQuake Chthon visibility retail test: FAIL"
  print "  " + message
  return 1
end function

// Find the first live edict with the requested QuakeC classname.
function findClass(session, className)
  runtime = session.server.machine.context.edicts
  entityIndex = session.server.maxClients + 1
  while entityIndex < runtime.numEdicts
    if not runtime.freeFlags[entityIndex] and
      server.qcString(session.server.machine, entityIndex, "classname", "") == className then
      return entityIndex
    end if
    entityIndex = entityIndex + 1
  end while
  return -1
end function

// Report whether the local protocol snapshot exposes one modeled entity.
function clientShowsEntity(session, entityIndex)
  if entityIndex < 0 or entityIndex >= len(session.client.entities) then return false end if
  entity = session.client.entities[entityIndex]
  if entity is void or entity.modelIndex == 0 then return false end if
  for each visible in session.client.visibleEntities
    if visible is not void and visible.number == entityIndex then return true end if
  end for
  return false
end function

// Activate Chthon through the stock e1m7 sigil and verify snapshot visibility.
function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeBossVisibilityRetailTests.exe BASE"
    return 2
  end if
  session = host.create([
    "-basedir", args[0], "-game", "id1", "-headless", "-nosound", "+map", "e1m6",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, initialized.message) end if
  transitioned = try(host.Host_Changelevel_f(session, ["changelevel", "e1m7"]))
  if transitioned is error then return fail(session, transitioned.message) end if
  if not transitioned or session.server.mapName != "e1m7" then
    return fail(session, "e1m6 -> e1m7 transition failed")
  end if

  bossIndex = findClass(session, "monster_boss")
  sigilIndex = findClass(session, "item_sigil")
  if bossIndex < 0 then return fail(session, "monster_boss edict is missing") end if
  if sigilIndex < 0 then return fail(session, "item_sigil activation trigger is missing") end if
  if server.qcString(session.server.machine, bossIndex, "model", "") != "" then
    return fail(session, "Chthon was not dormant before the sigil touch")
  end if

  // Use the real trigger path. boss_awake assigns both boss.mdl and Chthon's
  // large bounds at runtime; the lightweight snapshot must observe both in
  // the same frame or PVS culling can leave only his projectiles visible.
  session.player.origin.x = 8.0
  session.player.origin.y = 64.0
  session.player.origin.z = 24.0
  session.player.health = 10000.0
  session.player.moveType = c.MOVETYPE_NOCLIP
  playerIndex = session.server.clients[0].edictIndex
  server.setQcEntityVector(session.server, playerIndex, "origin", session.player.origin)
  server.setQcEntityFloat(session.server, playerIndex, "health", session.player.health)
  server.setQcEntityFloat(session.server, playerIndex, "movetype", c.MOVETYPE_NOCLIP)
  touched = try(server.runQcTouch(session.server, sigilIndex, playerIndex))
  if touched is error then return fail(session, touched.message) end if
  if not touched then return fail(session, "stock item_sigil touch function did not run") end if
  framed = try(host.frame(session, 0.05))
  if framed is error then return fail(session, framed.message) end if

  boss = session.server.edicts[bossIndex]
  if boss.model != "progs/boss.mdl" or boss.modelIndex <= 0 then
    return fail(session, "boss model did not reach the server snapshot")
  end if
  if boss.mins.x != -128.0 or boss.mins.y != -128.0 or boss.mins.z != -24.0 or
    boss.maxs.x != 128.0 or boss.maxs.y != 128.0 or boss.maxs.z != 256.0 then
    return fail(
      session,
      "runtime boss bounds stayed stale: mins=" + boss.mins.x + "," + boss.mins.y + "," + boss.mins.z +
        " maxs=" + boss.maxs.x + "," + boss.maxs.y + "," + boss.maxs.z,
    )
  end if
  if not clientShowsEntity(session, bossIndex) then
    return fail(session, "activated Chthon was absent from the first client snapshot")
  end if

  frame = 0
  while frame < 64
    result = try(host.frame(session, 0.05))
    if result is error then return fail(session, result.message) end if
    if not clientShowsEntity(session, bossIndex) then
      return fail(session, "Chthon disappeared from client frame " + (frame + 1))
    end if
    frame = frame + 1
  end while

  host.shutdown(session)
  print "MiniQuake Chthon visibility retail test: PASS"
  return 0
end function
