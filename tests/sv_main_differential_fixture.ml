/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang side of the pinned WinQuake/sv_main.c differential oracle.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.sv_main as svmain
import miniquake.edict as edict
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.net_loop as netloop

// Group the deterministic sv main differential map fields used by this test fixture.
struct SvMainDifferentialMap
  models
  nodes
  clipNodes
  planes
  leafs
  visibility
end struct

// Exercise differential map as part of this deterministic regression fixture.
function differentialMap()
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(
    0,
    -2,
    -2,
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    0,
    0,
  )
  solidLeaf = t.BspLeaf(
    c.CONTENTS_SOLID,
    -1,
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(0.0, 100.0, 100.0),
    0,
    0,
    bytes(4),
  )
  emptyLeaf = t.BspLeaf(
    c.CONTENTS_EMPTY,
    0,
    t.Vec3(0.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    0,
    0,
    bytes(4),
  )
  model = t.BspModel(
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  visibility = bytes(1)
  visibility[0] = 5
  return SvMainDifferentialMap(
    [model],
    [node],
    [t.BspClipNode(0, c.CONTENTS_EMPTY, c.CONTENTS_EMPTY)],
    [plane],
    [solidLeaf, emptyLeaf],
    visibility,
  )
end function

// Exercise differential entity as part of this deterministic regression fixture.
function differentialEntity(number)
  item = edict.create(number)
  item.number = number
  return item
end function

// Return differential state derived from the active module state.
function differentialState()
  state = svmain.SV_Init(1)
  state.server.worldModel = differentialMap()
  worldEntity = differentialEntity(0)
  playerEntity = differentialEntity(1)
  state.server.edicts = [worldEntity, playerEntity]
  state.server.numEdicts = 2
  return state
end function

// Exercise byte at as part of this deterministic regression fixture.
function byteAt(buffer, index)
  if index < 0 or index >= buffer.curSize then return 0 end if
  return buffer.data[index]
end function

// Exercise number text as part of this deterministic regression fixture.
function numberText(value)
  return native.floatText(value)
end function

// Return bool number derived from the active module state.
function boolNumber(value)
  if value then return 1 end if
  return 0
end function

// Add sv main to the destination state.
function emitSvMain(functionName, caseName, result, size, b0, b1, b2, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"size\":" + size +
    ",\"b0\":" + b0 + ",\"b1\":" + b1 + ",\"b2\":" + b2 +
    ",\"value\":" + numberText(value) + ",\"count\":" + count + "}"
end function

// Exercise setup server info as part of this deterministic regression fixture.
function setupServerInfo(state)
  state.server.levelName = "Oracle"
  state.server.cdTrack = 3
  state.server.modelPrecache = [""]
  state.server.soundPrecache = [""]
  return true
end function

// Exercise loop pair as part of this deterministic regression fixture.
function loopPair()
  network = netloop.createState()
  clientSocket = netloop.Loop_Connect(network, "local")
  serverSocket = netloop.Loop_CheckNewConnections(network)
  return [network, clientSocket, serverSocket]
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  state = svmain.SV_Init(1)
  emitSvMain(
    "SV_Init",
    "local_models",
    boolNumber(state.localModels[5] == "*5"),
    len(state.localModels),
    0,
    0,
    0,
    0.0,
    10,
  )

  state = differentialState()
  svmain.SV_StartParticle(
    state,
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(20.0, -20.0, 0.5),
    17,
    9,
  )
  buffer = state.server.datagram
  emitSvMain(
    "SV_StartParticle",
    "clamped_direction",
    1,
    buffer.curSize,
    byteAt(buffer, 0),
    byteAt(buffer, 7),
    byteAt(buffer, 8),
    byteAt(buffer, 9),
    byteAt(buffer, buffer.curSize - 1),
  )

  state = differentialState()
  state.server.soundPrecache = ["", "misc/test.wav"]
  item = state.server.edicts[1]
  item.origin = t.Vec3(10.0, 0.0, 0.0)
  item.mins = t.Vec3(-2.0, 0.0, 0.0)
  item.maxs = t.Vec3(2.0, 0.0, 0.0)
  svmain.SV_StartSound(state, 1, 2, "misc/test.wav", 200, 0.5)
  buffer = state.server.datagram
  emitSvMain(
    "SV_StartSound",
    "masked",
    1,
    buffer.curSize,
    byteAt(buffer, 0),
    byteAt(buffer, 1),
    byteAt(buffer, 2),
    byteAt(buffer, 4),
    byteAt(buffer, 6),
  )

  state = differentialState()
  setupServerInfo(state)
  clientValue = state.server.clients[0]
  svmain.SV_SendServerinfo(state, clientValue)
  emitSvMain(
    "SV_SendServerinfo",
    "signon",
    boolNumber(clientValue.sendSignon),
    0,
    byteAt(clientValue.message, 0),
    byteAt(clientValue.message, clientValue.message.curSize - 1),
    boolNumber(clientValue.spawned),
    0.0,
    0,
  )

  state = differentialState()
  setupServerInfo(state)
  pair = loopPair()
  clientValue = svmain.SV_ConnectClient(state, 0, pair[2])
  emitSvMain(
    "SV_ConnectClient",
    "fresh",
    boolNumber(clientValue.active),
    clientValue.edictIndex,
    boolNumber(clientValue.sendSignon),
    byteAt(clientValue.message, 0),
    boolNumber(clientValue.spawned),
    0.0,
    1,
  )

  state = differentialState()
  setupServerInfo(state)
  network = netloop.createState()
  pendingClient = netloop.Loop_Connect(network, "local")
  svmain.SV_SetNetworkState(state, network)
  result = svmain.SV_CheckForNewClients(state)
  clientValue = state.server.clients[0]
  emitSvMain(
    "SV_CheckForNewClients",
    "one_pending",
    boolNumber(clientValue.active),
    result,
    boolNumber(clientValue.sendSignon),
    byteAt(clientValue.message, 0),
    0,
    0.0,
    1,
  )

  state = differentialState()
  msg.writeByte(state.server.datagram, 99)
  result = svmain.SV_ClearDatagram(state)
  emitSvMain(
    "SV_ClearDatagram",
    "nonempty",
    boolNumber(result),
    state.server.datagram.curSize,
    0,
    0,
    0,
    0.0,
    0,
  )

  state = differentialState()
  state.fatPvs = bytes(1)
  svmain.SV_AddToFatPVS(state, t.Vec3(0.0, 0.0, 0.0), -2)
  emitSvMain(
    "SV_AddToFatPVS",
    "leaf_or",
    1,
    len(state.fatPvs),
    state.fatPvs[0],
    0,
    0,
    0.0,
    0,
  )

  state = differentialState()
  pvs = svmain.SV_FatPVS(state, t.Vec3(0.0, 0.0, 0.0))
  emitSvMain("SV_FatPVS", "leaf_root", 1, len(pvs), 0, 0, 0, 0.0, 0)

  state = differentialState()
  item = state.server.edicts[1]
  item.origin = t.Vec3(1.0, 0.0, 0.0)
  item.moveType = c.MOVETYPE_STEP
  buffer = sz.alloc(1024)
  result = svmain.SV_WriteEntitiesToClient(state, item, buffer)
  emitSvMain(
    "SV_WriteEntitiesToClient",
    "client_delta",
    1,
    buffer.curSize,
    byteAt(buffer, 0),
    byteAt(buffer, 1),
    byteAt(buffer, 2),
    byteAt(buffer, 3),
    result,
  )

  state = differentialState()
  state.server.edicts[1].effects = c.EF_MUZZLEFLASH | 8
  result = svmain.SV_CleanupEnts(state)
  emitSvMain(
    "SV_CleanupEnts",
    "muzzle",
    1,
    0,
    0,
    0,
    0,
    state.server.edicts[1].effects,
    result,
  )

  state = differentialState()
  state.server.serverFlags = 3
  state.server.modelPrecache = ["", "weapon.mdl"]
  clientValue = state.server.clients[0]
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.viewHeight = 30.0
  player.flags = c.FL_ONGROUND
  player.waterLevel = 2
  player.punchAngle = t.Vec3(1.0, 0.0, -2.0)
  player.velocity = t.Vec3(16.0, -32.0, 0.0)
  player.weaponFrame = 6
  player.armor = 75.0
  player.weapon = 1
  player.health = 99.0
  player.ammo = 10
  player.shells = 11
  player.nails = 12
  player.rockets = 13
  player.cells = 14
  player.items = 5
  player.activeWeapon = 4
  buffer = sz.alloc(1024)
  svmain.SV_WriteClientdataToMessage(state, clientValue, player, buffer)
  emitSvMain(
    "SV_WriteClientdataToMessage",
    "protocol15",
    1,
    buffer.curSize,
    byteAt(buffer, 0),
    byteAt(buffer, 1),
    byteAt(buffer, 2),
    0.0,
    byteAt(buffer, buffer.curSize - 1),
  )

  state = differentialState()
  pair = loopPair()
  clientValue = state.server.clients[0]
  clientValue.active = true
  clientValue.spawned = true
  clientValue.socket = pair[2]
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.viewHeight = c.DEFAULT_VIEWHEIGHT
  result = svmain.SV_SendClientDatagram(state, clientValue, player)
  received = sz.alloc(c.MAX_DATAGRAM)
  netloop.Loop_GetMessage(pair[1], received)
  emitSvMain(
    "SV_SendClientDatagram",
    "success",
    boolNumber(result),
    0,
    byteAt(received, 0),
    0,
    0,
    0.0,
    0,
  )

  state = differentialState()
  clientValue = state.server.clients[0]
  clientValue.active = true
  clientValue.oldFrags = 0
  svmain.SV_SetClientFrags(state, 0, 7)
  msg.writeByte(state.server.reliableDatagram, 99)
  svmain.SV_UpdateToReliableMessages(state)
  emitSvMain(
    "SV_UpdateToReliableMessages",
    "frags_broadcast",
    clientValue.oldFrags,
    clientValue.message.curSize,
    byteAt(clientValue.message, 0),
    byteAt(clientValue.message, 1),
    byteAt(clientValue.message, 2),
    byteAt(clientValue.message, clientValue.message.curSize - 1),
    state.server.reliableDatagram.curSize,
  )

  state = differentialState()
  pair = loopPair()
  clientValue = state.server.clients[0]
  clientValue.socket = pair[2]
  svmain.SV_SetRealtime(state, 9.0)
  result = svmain.SV_SendNop(state, clientValue)
  received = sz.alloc(4)
  netloop.Loop_GetMessage(pair[1], received)
  emitSvMain(
    "SV_SendNop",
    "keepalive",
    boolNumber(result),
    received.curSize,
    byteAt(received, 0),
    0,
    0,
    state.lastMessages[0],
    0,
  )

  state = differentialState()
  state.server.edicts[1].effects = c.EF_MUZZLEFLASH | 8
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  svmain.SV_SendClientMessages(state, player)
  emitSvMain(
    "SV_SendClientMessages",
    "inactive_cleanup",
    1,
    0,
    0,
    0,
    0,
    state.server.edicts[1].effects,
    0,
  )

  state = differentialState()
  state.server.modelPrecache = ["", "maps/test.bsp"]
  result = svmain.SV_ModelIndex(state, "maps/test.bsp")
  emitSvMain("SV_ModelIndex", "precache_hit", result, 0, 0, 0, 0, 0.0, 0)

  state = differentialState()
  state.server.modelPrecache = ["", "maps/test.bsp", "progs/player.mdl"]
  state.server.edicts[0].model = "maps/test.bsp"
  state.server.edicts[0].modelIndex = 1
  state.server.edicts[1].model = "progs/player.mdl"
  sz.clear(state.server.signon)
  result = svmain.SV_CreateBaseline(state)
  emitSvMain(
    "SV_CreateBaseline",
    "world_player",
    1,
    state.server.signon.curSize,
    state.server.edicts[0].baseline.modelIndex,
    state.server.edicts[1].baseline.modelIndex,
    state.server.edicts[1].baseline.colormap,
    0.0,
    result,
  )

  state = differentialState()
  result = svmain.SV_SendReconnect(state)
  emitSvMain("SV_SendReconnect", "local_command", 1, 0, 9, 0, 1, 0.0, result)

  state = differentialState()
  state.server.serverFlags = 5
  svmain.SV_SaveSpawnparms(state)
  emitSvMain(
    "SV_SaveSpawnparms",
    "no_active",
    1,
    state.server.serverFlags,
    0,
    0,
    0,
    0.0,
    0,
  )
  return 0
end function
