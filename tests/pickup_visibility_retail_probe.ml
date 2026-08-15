/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail diagnostic for the pickup-to-render-list lifecycle.
*/
import miniquake.host as host
import miniquake.server as server
import miniquake.server_collision as collision
import miniquake.client as client

// Exercise contains entity as part of this deterministic regression fixture.
function containsEntity(values, entityIndex)
  for each value in values
    if value is not void and value.number == entityIndex then return true end if
  end for
  return false
end function

// Print authoritative and client-side visibility state for one pickup.
function printPickupState(session, entityIndex, label)
  machine = session.server.machine
  mirror = session.server.edicts[entityIndex]
  clientEntity = session.client.entities[entityIndex]
  active = client.CL_ActiveVisibleEntities(session.client)
  filtered = client.CL_FilterAuthoritativeVisibleEntities(active, session.server.edicts)
  print label +
    " qc_model='" + server.qcString(machine, entityIndex, "model", "") + "'" +
    " qc_modelindex=" + server.qcFloat(machine, entityIndex, "modelindex", 0.0) +
    " qc_solid=" + server.qcFloat(machine, entityIndex, "solid", 0.0) +
    " qc_free=" + machine.context.edicts.freeFlags[entityIndex] +
    " mirror_model='" + mirror.model + "'" +
    " mirror_modelindex=" + mirror.modelIndex +
    " mirror_free=" + mirror.free +
    " client_modelindex=" + clientEntity.modelIndex +
    " client_message=" + clientEntity.messageTime +
    " visible=" + containsEntity(active, entityIndex) +
    " filtered=" + containsEntity(filtered, entityIndex)
  return true
end function

// Pick up one requested stock item and verify every render boundary hides it.
function main(args)
  if len(args) < 1 then print "usage: probe BASE [CLASS] [MAP]"; return 2 end if
  wanted = "item_armor1"
  if len(args) > 1 then wanted = args[1] end if
  mapName = "e1m1"
  if len(args) > 2 then mapName = args[2] end if
  session = host.create([
    "-basedir", args[0], "-game", "id1", "-nosound", "-noinput",
    "-window", "-width", "640", "-height", "480", "+map", mapName,
  ])
  initialized = try(host.initialize(session))
  if initialized is error then print initialized.message; return 1 end if
  machine = session.server.machine
  entityIndex = -1
  index = session.server.maxClients + 1
  while index < machine.context.edicts.numEdicts
    name = server.qcString(machine, index, "classname", "")
    if name == wanted and entityIndex < 0 then entityIndex = index end if
    if name == "item_armor1" or name == "item_armor2" or name == "item_armorInv" or
      name == "item_rockets" or name == "weapon_rocketlauncher" then
      print "candidate entity=" + index + " class=" + name
    end if
    index = index + 1
  end while
  if entityIndex < 0 then print "missing pickup " + wanted; host.shutdown(session); return 3 end if

  frameResult = try(host.frame(session, 0.05))
  if frameResult is error then print frameResult.message; host.shutdown(session); return 4 end if
  target = server.qcVector(machine, entityIndex, "origin", session.player.origin)
  // Seed the exact retained-client state reported by gameplay. The pickup is
  // still authoritative and its numbered client entity has already rendered
  // in an earlier PVS before the following touch clears the QuakeC model.
  clientEntity = client.ensureEntity(session.client, entityIndex)
  clientEntity.modelIndex = session.server.edicts[entityIndex].modelIndex
  clientEntity.messageTime = session.client.messageTimes[0]
  session.client.visibleEntities = [clientEntity]
  printPickupState(session, entityIndex, "before")
  session.player.origin.x = target.x
  session.player.origin.y = target.y
  session.player.origin.z = target.z
  server.setQcEntityVector(session.server, 1, "origin", target)
  collision.linkEntity(session.server, 1, true)
  printPickupState(session, entityIndex, "after_touch")

  frameIndex = 0
  while frameIndex < 4
    nextFrame = try(host.frame(session, 0.05))
    if nextFrame is error then print nextFrame.message; host.shutdown(session); return 5 end if
    printPickupState(session, entityIndex, "after_frame_" + (frameIndex + 1))
    frameIndex = frameIndex + 1
  end while
  active = client.CL_ActiveVisibleEntities(session.client)
  filtered = client.CL_FilterAuthoritativeVisibleEntities(active, session.server.edicts)
  visibleAfter = containsEntity(filtered, entityIndex)
  host.shutdown(session)
  if visibleAfter then return 6 end if
  return 0
end function
