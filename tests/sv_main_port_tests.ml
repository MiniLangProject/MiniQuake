/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused deterministic sv_main.c / server.h fixtures.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.sv_main as svmain
import miniquake.edict as edict
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.net_loop as netloop

function svmTestEqual(actual, expected, name)
  if actual != expected then return error(9960, name + ": got " + actual + " expected " + expected) end if
  return true
end function

function svmTestTrue(value, name)
  if value != true then return error(9961, name) end if
  return true
end function

function svmTestNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.01 then return error(9962, name) end if
  return true
end function

function svmBaseline(modelIndex, frame, colormap, skin, origin, angles)
  return t.EntityBaseline(modelIndex, frame, colormap, skin, origin, angles)
end function

function testEntityUpdatePacking()
  state = svmain.SV_Init(1)
  item = edict.create(300)
  item.model = "progs/ogre.mdl"
  item.modelIndex = 7
  item.frame = 5
  item.colormap = 3
  item.skin = 2
  item.effects = c.EF_MUZZLEFLASH | c.EF_DIMLIGHT
  item.origin = t.Vec3(1.0, 2.0, 3.0)
  item.angles = t.Vec3(45.0, 90.0, 135.0)
  item.moveType = c.MOVETYPE_STEP
  item.baseline = svmBaseline(4, 1, 0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  buffer = sz.alloc(128)
  bits = svmain.SV_WriteEntityDelta(state, buffer, item)
  expected = c.U_ORIGIN1 | c.U_ORIGIN2 | c.U_ORIGIN3 | c.U_ANGLE1 | c.U_ANGLE2 | c.U_ANGLE3 | c.U_NOLERP | c.U_MODEL | c.U_FRAME | c.U_COLORMAP | c.U_SKIN | c.U_EFFECTS | c.U_LONGENTITY | c.U_MOREBITS
  svmTestEqual(bits, expected, "entity bit mask")
  reader = msg.beginReading(buffer)
  svmTestEqual(msg.readByte(reader), (expected & 255) | c.U_SIGNAL, "fast update signal byte")
  svmTestEqual(msg.readByte(reader), (expected >> 8) & 255, "morebits byte")
  svmTestEqual(msg.readShort(reader), 300, "long entity")
  svmTestEqual(msg.readByte(reader), 7, "model")
  svmTestEqual(msg.readByte(reader), 5, "frame")
  svmTestEqual(msg.readByte(reader), 3, "colormap")
  svmTestEqual(msg.readByte(reader), 2, "skin")
  svmTestEqual(msg.readByte(reader), c.EF_MUZZLEFLASH | c.EF_DIMLIGHT, "effects")
  svmTestNear(msg.readCoord(reader), 1.0, "origin x")
  svmTestNear(msg.readAngle(reader), 45.0, "angle x")
  svmTestNear(msg.readCoord(reader), 2.0, "origin y")
  svmTestNear(msg.readAngle(reader), 90.0, "angle y")
  svmTestNear(msg.readCoord(reader), 3.0, "origin z")
  svmTestNear(msg.readAngle(reader), 135.0, "angle z")
  return true
end function

function testBaselineAndClientData()
  state = svmain.SV_Init(1)
  server = state.server
  server.serverFlags = 3
  server.modelPrecache = ["", "maps/start.bsp", "progs/player.mdl", "progs/ogre.mdl"]
  worldEntity = edict.create(0)
  worldEntity.className = "worldspawn"
  worldEntity.model = "maps/start.bsp"
  worldEntity.modelIndex = 1
  playerEntity = edict.create(1)
  playerEntity.className = "player"
  playerEntity.origin = t.Vec3(8.0, 16.0, 24.0)
  monster = edict.create(2)
  monster.className = "monster_ogre"
  monster.model = "progs/ogre.mdl"
  monster.modelIndex = 3
  monster.frame = 4
  server.edicts = [worldEntity, playerEntity, monster]
  server.numEdicts = 3
  sz.clear(server.signon)
  svmTestEqual(svmain.SV_CreateBaseline(state), 3, "world player monster baselines")
  svmTestEqual(playerEntity.baseline.modelIndex, 2, "player baseline model")
  svmTestEqual(playerEntity.baseline.colormap, 1, "player baseline colormap")
  svmTestEqual(monster.baseline.modelIndex, 3, "monster baseline model")

  baselineReader = msg.beginReading(server.signon)
  baselineIndex = 0
  while baselineIndex < 3
    svmTestEqual(msg.readByte(baselineReader), c.SVC_SPAWNBASELINE, "baseline command")
    svmTestEqual(msg.readShort(baselineReader), baselineIndex, "baseline entity number")
    msg.readByte(baselineReader)
    msg.readByte(baselineReader)
    msg.readByte(baselineReader)
    msg.readByte(baselineReader)
    msg.readCoord(baselineReader); msg.readAngle(baselineReader)
    msg.readCoord(baselineReader); msg.readAngle(baselineReader)
    msg.readCoord(baselineReader); msg.readAngle(baselineReader)
    baselineIndex = baselineIndex + 1
  end while
  svmTestEqual(msg.remaining(baselineReader), 0, "baseline stream consumed")

  clientValue = server.clients[0]
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.viewHeight = 30.0
  player.flags = c.FL_CLIENT | c.FL_ONGROUND
  player.waterLevel = 2
  player.punchAngle = t.Vec3(1.0, 0.0, -2.0)
  player.velocity = t.Vec3(16.0, -32.0, 0.0)
  player.weaponFrame = 6
  player.armor = 75.0
  player.weapon = 2
  player.health = 99.0
  player.ammo = 10
  player.shells = 11
  player.nails = 12
  player.rockets = 13
  player.cells = 14
  player.items = 5
  player.activeWeapon = 4
  data = sz.alloc(128)
  bits = svmain.SV_WriteClientdataToMessage(state, clientValue, player, data)
  expectedBits = c.SU_ITEMS | c.SU_WEAPON | c.SU_VIEWHEIGHT | c.SU_ONGROUND | c.SU_INWATER | c.SU_PUNCH1 | c.SU_PUNCH3 | c.SU_VELOCITY1 | c.SU_VELOCITY2 | c.SU_WEAPONFRAME | c.SU_ARMOR
  svmTestEqual(bits, expectedBits, "clientdata bits")
  reader = msg.beginReading(data)
  svmTestEqual(msg.readByte(reader), c.SVC_CLIENTDATA, "clientdata command")
  svmTestEqual(msg.readShort(reader), expectedBits, "clientdata mask")
  svmTestEqual(msg.readChar(reader), 30, "viewheight")
  svmTestEqual(msg.readChar(reader), 1, "punch x")
  svmTestEqual(msg.readChar(reader), 1, "velocity x")
  svmTestEqual(msg.readChar(reader), -2, "velocity y")
  svmTestEqual(msg.readChar(reader), -2, "punch z")
  svmTestEqual(msg.readLong(reader), 5 | (3 << 28), "items and serverflags")
  svmTestEqual(msg.readByte(reader), 6, "weaponframe")
  svmTestEqual(msg.readByte(reader), 75, "armor")
  svmTestEqual(msg.readByte(reader), 2, "weapon model")
  svmTestEqual(msg.readShort(reader), 99, "health")
  svmTestEqual(msg.readByte(reader), 10, "ammo")
  svmTestEqual(msg.readByte(reader), 11, "shells")
  svmTestEqual(msg.readByte(reader), 12, "nails")
  svmTestEqual(msg.readByte(reader), 13, "rockets")
  svmTestEqual(msg.readByte(reader), 14, "cells")
  svmTestEqual(msg.readByte(reader), 4, "active weapon")
  return true
end function

function testReliableBroadcastAndOverflow()
  state = svmain.SV_Init(2)
  first = state.server.clients[0]
  second = state.server.clients[1]
  first.active = true
  second.active = true
  first.oldFrags = 0
  second.oldFrags = 0
  svmain.SV_SetClientFrags(state, 0, 7)
  svmain.SV_SetClientFrags(state, 1, -2)
  msg.writeByte(state.server.reliableDatagram, c.SVC_NOP)
  svmTestEqual(svmain.SV_UpdateToReliableMessages(state), 2, "two frag deltas")
  svmTestEqual(state.server.reliableDatagram.curSize, 0, "reliable datagram cleared")
  svmTestEqual(first.message.curSize, 9, "first reliable payload")
  svmTestEqual(second.message.curSize, 9, "second reliable payload")

  overflowState = svmain.SV_Init(1)
  overflowClient = overflowState.server.clients[0]
  overflowClient.active = true
  overflowClient.oldFrags = 0
  overflowState.clientFrags[0] = 0
  overflowClient.message = sz.allocOverflowing(8)
  index = 0
  while index < 7
    msg.writeByte(overflowClient.message, 44)
    index = index + 1
  end while
  msg.writeLong(overflowState.server.reliableDatagram, 0x12345678)
  svmain.SV_UpdateToReliableMessages(overflowState)
  svmTestTrue(overflowClient.message.overflowed, "client reliable overflow flagged")
  svmain.SV_SendClientMessages(overflowState, movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  svmTestEqual(overflowClient.active, false, "overflowed client dropped")
  return true
end function

function testConnectAndSignonLifecycle()
  state = svmain.SV_Init(1)
  state.server.active = true
  state.server.levelName = "Entrance"
  state.server.mapName = "start"
  state.server.modelPrecache = ["", "maps/start.bsp", "progs/player.mdl"]
  state.server.soundPrecache = [""]
  network = netloop.createState()
  svmain.SV_SetNetworkState(state, network)
  clientSocket = netloop.Loop_Connect(network, "local")
  svmTestTrue(clientSocket is not void, "local socket")
  svmTestEqual(svmain.SV_CheckForNewClients(state), 1, "one accepted client")
  serverClient = state.server.clients[0]
  svmTestTrue(serverClient.active, "client active")
  svmTestTrue(serverClient.sendSignon, "serverinfo pending")
  svmTestEqual(serverClient.signonStage, c.SIGNON_SERVERINFO, "serverinfo stage")
  svmTestTrue(serverClient.message.curSize > 0, "serverinfo buffered")

  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  svmain.SV_SendClientMessages(state, player)
  svmTestEqual(serverClient.sendSignon, false, "serverinfo sent")
  destination = sz.alloc(c.MAX_MSGLEN)
  svmTestEqual(netloop.Loop_GetMessage(clientSocket, destination), 1, "client receives reliable serverinfo")
  reader = msg.beginReading(destination)
  svmTestEqual(msg.readByte(reader), c.SVC_PRINT, "serverinfo starts with print")
  return true
end function

function main(args)
  print "[1/4] Protocol-15 entity update packing"
  result = try(testEntityUpdatePacking())
  if result is error then print result.message; print "entity packing failed"; return 1 end if
  print "[2/4] baseline and clientdata"
  result = try(testBaselineAndClientData())
  if result is error then print result.message; print "baseline/clientdata failed"; return 1 end if
  print "[3/4] reliable broadcast and overflow"
  result = try(testReliableBroadcastAndOverflow())
  if result is error then print result.message; print "reliable/overflow failed"; return 1 end if
  print "[4/4] connect and signon lifecycle"
  result = try(testConnectAndSignonLifecycle())
  if result is error then print result.message; print "connect/signon failed"; return 1 end if
  print "SV_MAIN PORT TESTS PASSED (4/4)"
  return 0
end function
