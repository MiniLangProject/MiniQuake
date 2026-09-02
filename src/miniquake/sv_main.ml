/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sv_main.
*/
package miniquake.sv_main

// Functional pendant of WinQuake/sv_main.c and the public server.h lifecycle
// hooks owned by that unit.  GameServer remains the shared storage model, but
// this module owns the original message construction and per-client delivery
// rules instead of routing them through the playable host's convenience path.

import miniquake.types as t
import miniquake.constants as c
import miniquake.format.progs as progs
import miniquake.server as runtime
import miniquake.server_move as serverMove
import miniquake.physics as physics
import miniquake.edict as edict
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_update as protocolUpdate
import miniquake.protocol_serverdata as serverData
import miniquake.protocol_events as protocolEvents
import miniquake.protocol_transients as transients
import miniquake.quakec.vm as vm
import miniquake.net_main as netmain
import miniquake.net_loop as netloop
import miniquake.mathlib as math
import miniquake.world_bsp as world
import miniquake.native as native
import miniquake.array_util as arrayutil

/// Defines the multicast all value used by `miniquake.sv_main`.
const MULTICAST_ALL = 0
/// Defines the multicast pvs value used by `miniquake.sv_main`.
const MULTICAST_PVS = 1
/// Defines the multicast phs value used by `miniquake.sv_main`.
const MULTICAST_PHS = 2

// Track mutable sv main state across subsystem calls.
struct SvMainState
  /// Stores the server value in `miniquake.sv_main.SvMainState`.
  server
  /// Stores the network value in `miniquake.sv_main.SvMainState`.
  network
  /// Stores the realtime value in `miniquake.sv_main.SvMainState`.
  realtime
  /// Stores the last messages value in `miniquake.sv_main.SvMainState`.
  lastMessages
  /// Stores the drop asap value in `miniquake.sv_main.SvMainState`.
  dropAsap
  /// Stores the client frags value in `miniquake.sv_main.SvMainState`.
  clientFrags
  /// Stores the ideal pitches value in `miniquake.sv_main.SvMainState`.
  idealPitches
  /// Stores the local models value in `miniquake.sv_main.SvMainState`.
  localModels
  /// Stores the fat pvs value in `miniquake.sv_main.SvMainState`.
  fatPvs
  /// Stores the standard quake value in `miniquake.sv_main.SvMainState`.
  standardQuake
  /// Stores the diagnostics value in `miniquake.sv_main.SvMainState`.
  diagnostics
end struct

// Apply server-side zero spawn parms semantics.
function svmZeroSpawnParms()
  return arrayutil.makeFilledArray(c.NUM_SPAWN_PARMS, 0.0)
end function

// Apply server-side local models semantics.
function svmLocalModels()
  result = arrayutil.makeEmptyArray(c.MAX_MODELS)
  index = 0
  while index < c.MAX_MODELS
    result[index] = "*" + index
    index = index + 1
  end while
  return result
end function

/// SV_Init
/// @param maxClients The max clients input consumed by `SV_Init`.
function SV_Init(maxClients)
  gameServer = runtime.create(maxClients)
  // sv.reliable_datagram is a MAX_DATAGRAM broadcast buffer.  Client message
  // buffers are the larger MAX_MSGLEN buffers and are allowed to overflow so
  // SV_SendClientMessages can drop a backed-up connection deterministically.
  gameServer.reliableDatagram = sz.alloc(c.MAX_DATAGRAM)
  for each clientValue in gameServer.clients
    clientValue.message.allowOverflow = true
  end for
  count = len(gameServer.clients)
  return SvMainState(
    gameServer,
    void,
    0.0,
    arrayutil.makeFilledArray(count, -999999.0),
    arrayutil.makeFilledArray(count, false),
    arrayutil.makeFilledArray(count, 0),
    arrayutil.makeFilledArray(count, 0.0),
    svmLocalModels(),
    bytes(),
    true,
    [],
  )
end function

/// Apply the Quake-compatible sv set network state behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetNetworkState`.
/// @param network The network input consumed by `SV_SetNetworkState`.
function SV_SetNetworkState(state, network)
  state.network = network
  return network
end function

/// Apply the Quake-compatible sv set realtime behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetRealtime`.
/// @param value Value consumed by `SV_SetRealtime`.
function SV_SetRealtime(state, value)
  state.realtime = value
  return value
end function

/// Apply the Quake-compatible sv set standard quake behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetStandardQuake`.
/// @param enabled Whether the optional behavior is enabled.
function SV_SetStandardQuake(state, enabled)
  state.standardQuake = enabled
  state.server.standardQuake = enabled
  return enabled
end function

/// Apply the Quake-compatible sv set client frags behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetClientFrags`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param frags The frags input consumed by `SV_SetClientFrags`.
function SV_SetClientFrags(state, clientIndex, frags)
  if clientIndex < 0 or clientIndex >= len(state.clientFrags) then return error(2870, "SV_SetClientFrags: bad client") end if
  state.clientFrags[clientIndex] = protocolEvents.cFloat(frags)
  return state.clientFrags[clientIndex]
end function

/// Apply server-side sound index semantics.
/// @param server Server state participating in the operation.
/// @param sample The sample input consumed by `svmSoundIndex`.
function svmSoundIndex(server, sample)
  index = 1
  while index < len(server.soundPrecache) and index < 256
    if server.soundPrecache[index] == sample then return index end if
    index = index + 1
  end while
  return 0
end function

/// Apply server-side entity center semantics.
/// @param item The item input consumed by `svmEntityCenter`.
function svmEntityCenter(item)
  return transients.soundCenter(item.origin, item.mins, item.maxs)
end function

/// SV_StartParticle
/// @param state Mutable `miniquake.sv_main` state used by `SV_StartParticle`.
/// @param origin World-space origin of the operation.
/// @param direction The direction input consumed by `SV_StartParticle`.
/// @param color Color value used by the operation.
/// @param count Number of entries or units to process.
function SV_StartParticle(state, origin, direction, color, count)
  buffer = state.server.datagram
  if not protocolEvents.canWriteTransient(buffer) then return false end if
  protocolEvents.writeParticle(buffer, origin, direction, count, color)
  return true
end function

/// SV_StartSound
/// @param state Mutable `miniquake.sv_main` state used by `SV_StartSound`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param channel The channel input consumed by `SV_StartSound`.
/// @param sample The sample input consumed by `SV_StartSound`.
/// @param volume The volume input consumed by `SV_StartSound`.
/// @param attenuation The attenuation input consumed by `SV_StartSound`.
function SV_StartSound(state, entityIndex, channel, sample, volume, attenuation)
  entityIndexValue = native.trunc(entityIndex)
  channelValue = native.trunc(channel)
  volumeValue = native.trunc(volume)
  attenuationValue = transients.cFloat(attenuation)
  if volumeValue < 0 or volumeValue > 255 then return error(2871, "SV_StartSound: volume = " + volumeValue) end if
  if attenuationValue < 0.0 or attenuationValue > 4.0 then return error(2872, "SV_StartSound: attenuation = " + attenuationValue) end if
  if channelValue < 0 or channelValue > 7 then return error(2873, "SV_StartSound: channel = " + channelValue) end if
  server = state.server
  if not transients.canWriteDynamicSound(server.datagram) then return false end if
  if entityIndexValue < 0 or entityIndexValue >= len(server.edicts) then return error(2874, "SV_StartSound: bad entity") end if
  item = server.edicts[entityIndexValue]
  if item is void then return error(2874, "SV_StartSound: bad entity") end if
  soundNumber = svmSoundIndex(server, sample)
  if soundNumber == 0 then
    state.diagnostics = state.diagnostics + ["SV_StartSound: " + sample + " not precached"]
    return false
  end if
  center = svmEntityCenter(item)
  serverData.writeSound(server.datagram, entityIndexValue, channelValue, soundNumber, volumeValue, attenuationValue, center)
  return true
end function

/// Apply server-side progs crc semantics.
/// @param server Server state participating in the operation.
function svmProgsCrc(server)
  if server.progs is not void then return progs.runtimeCrc(server.progs) end if
  if server.machine is not void and server.machine.program is not void then return progs.runtimeCrc(server.machine.program) end if
  return 0
end function

/// Apply server-side append server info semantics.
/// @param server Server state participating in the operation.
/// @param clientValue The client value input consumed by `svmAppendServerInfo`.
function svmAppendServerInfo(server, clientValue)
  gameType = c.GAME_COOP
  if not server.coop and server.deathmatch then gameType = c.GAME_DEATHMATCH end if
  serverData.writeServerInfo(
    clientValue.message,
    svmProgsCrc(server),
    server.maxClients,
    gameType,
    server.levelName,
    server.modelPrecache,
    server.soundPrecache,
    server.cdTrack,
    clientValue.edictIndex,
  )
  clientValue.sendSignon = true
  clientValue.spawned = false
  clientValue.signonStage = c.SIGNON_SERVERINFO
  return clientValue.message.curSize
end function

/// SV_SendServerinfo
/// @param state Mutable `miniquake.sv_main` state used by `SV_SendServerinfo`.
/// @param clientValue The client value input consumed by `SV_SendServerinfo`.
function SV_SendServerinfo(state, clientValue)
  return svmAppendServerInfo(state.server, clientValue)
end function

/// Apply server-side reset client semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmResetClient`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param socket Network socket used for communication.
function svmResetClient(state, clientIndex, socket)
  clientValue = state.server.clients[clientIndex]
  savedSpawnParms = clientValue.spawnParms
  clientValue.active = true
  clientValue.spawned = false
  clientValue.sendSignon = false
  clientValue.signonStage = 0
  clientValue.name = "unconnected"
  clientValue.colors = 0
  clientValue.privileged = false
  clientValue.edictIndex = clientIndex + 1
  clientValue.socket = socket
  clientValue.message = sz.allocOverflowing(c.MAX_MSGLEN)
  clientValue.spawnParms = svmZeroSpawnParms()
  clientValue.command = runtime.createServerClient(clientIndex).command
  clientValue.pingTimes = arrayutil.makeFilledArray(16, 0.0)
  clientValue.numPings = 0
  clientValue.oldFrags = 0
  if state.server.loadGame then clientValue.spawnParms = savedSpawnParms end if
  state.lastMessages[clientIndex] = state.realtime
  state.dropAsap[clientIndex] = false
  clientValue.lastMessage = state.realtime
  clientValue.dropAsap = false
  state.clientFrags[clientIndex] = 0
  return clientValue
end function

/// SV_ConnectClient
/// @param state Mutable `miniquake.sv_main` state used by `SV_ConnectClient`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param socket Network socket used for communication.
function SV_ConnectClient(state, clientIndex, socket)
  if clientIndex < 0 or clientIndex >= len(state.server.clients) then return error(2875, "SV_ConnectClient: bad client") end if
  clientValue = svmResetClient(state, clientIndex, socket)
  if state.server.machine is not void and state.server.machine.context is not void and not state.server.loadGame then
    runtime.executeQcFunction(state.server, "SetNewParms", clientValue.edictIndex, 0)
    runtime.copyGlobalsToSpawnParms(state.server, clientValue)
  end if
  netmain.NET_ConnectionAccepted()
  SV_SendServerinfo(state, clientValue)
  return clientValue
end function

/// Apply server-side free client index semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmFreeClientIndex`.
function svmFreeClientIndex(state)
  index = 0
  while index < len(state.server.clients)
    if not state.server.clients[index].active then return index end if
    index = index + 1
  end while
  return -1
end function

/// SV_CheckForNewClients
/// @param state Mutable `miniquake.sv_main` state used by `SV_CheckForNewClients`.
function SV_CheckForNewClients(state)
  if state.network is void then return 0 end if
  connected = 0
  while true
    socket = void
    if state.network.pending is not void then
      socket = netloop.Loop_CheckNewConnections(state.network)
    else
      socket = netmain.NET_CheckNewConnections(state.network)
    end if
    if socket is error then return socket end if
    if socket is void then break end if
    clientIndex = svmFreeClientIndex(state)
    if clientIndex < 0 then return error(2876, "Host_CheckForNewClients: no free clients") end if
    SV_ConnectClient(state, clientIndex, socket)
    connected = connected + 1
  end while
  return connected
end function

/// Public server.h spelling retained for callers that already own a socket.
/// @param state Mutable `miniquake.sv_main` state used by `SV_AddClientToServer`.
/// @param socket Network socket used for communication.
function SV_AddClientToServer(state, socket)
  clientIndex = svmFreeClientIndex(state)
  if clientIndex < 0 then return error(2876, "Host_CheckForNewClients: no free clients") end if
  return SV_ConnectClient(state, clientIndex, socket)
end function

/// SV_ClearDatagram
/// @param state Mutable `miniquake.sv_main` state used by `SV_ClearDatagram`.
function SV_ClearDatagram(state)
  sz.clear(state.server.datagram)
  return true
end function

/// Apply server-side or bytes semantics.
/// @param destination Destination value or collection to update.
/// @param source Source value or collection to read.
/// @param count Number of entries or units to process.
function svmOrBytes(destination, source, count)
  limit = count
  if len(destination) < limit then limit = len(destination) end if
  if len(source) < limit then limit = len(source) end if
  index = 0
  while index < limit
    destination[index] = destination[index] | source[index]
    index = index + 1
  end while
  return destination
end function

/// SV_AddToFatPVS
/// @param state Mutable `miniquake.sv_main` state used by `SV_AddToFatPVS`.
/// @param origin World-space origin of the operation.
/// @param nodeIndex Zero-based index of the requested entry.
function SV_AddToFatPVS(state, origin, nodeIndex)
  map = state.server.worldModel
  current = nodeIndex
  while true
    if current < 0 then
      leafIndex = -1 - current
      if leafIndex > 0 and leafIndex < len(map.leafs) and map.leafs[leafIndex].contents != c.CONTENTS_SOLID then
        pvs = world.leafPvs(map, leafIndex)
        svmOrBytes(state.fatPvs, pvs, len(state.fatPvs))
      end if
      return state.fatPvs
    end if
    if current >= len(map.nodes) then return error(2877, "SV_AddToFatPVS: bad node") end if
    node = map.nodes[current]
    plane = map.planes[node.planeIndex]
    distance = world.planeDistance(plane, origin)
    if distance > 8.0 then
      current = node.child0
    else if distance < -8.0 then
      current = node.child1
    else
      SV_AddToFatPVS(state, origin, node.child0)
      current = node.child1
    end if
  end while
end function

/// SV_FatPVS
/// @param state Mutable `miniquake.sv_main` state used by `SV_FatPVS`.
/// @param origin World-space origin of the operation.
function SV_FatPVS(state, origin)
  map = state.server.worldModel
  if map is void or len(map.models) == 0 then
    state.fatPvs = bytes()
    return state.fatPvs
  end if
  fatBytes = (map.models[0].visibleLeafs + 31) >> 3
  if fatBytes < 1 then fatBytes = 1 end if
  state.fatPvs = bytes(fatBytes)
  if len(map.nodes) == 0 then
    index = 0
    while index < fatBytes
      state.fatPvs[index] = 255
      index = index + 1
    end while
    return state.fatPvs
  end if
  SV_AddToFatPVS(state, origin, map.models[0].headNodes[0])
  return state.fatPvs
end function

/// Apply server-side box plane sides semantics.
/// @param mins The mins input consumed by `svmBoxPlaneSides`.
/// @param maxs The maxs input consumed by `svmBoxPlaneSides`.
/// @param plane The plane input consumed by `svmBoxPlaneSides`.
function svmBoxPlaneSides(mins, maxs, plane)
  if plane.type == 0 then
    if mins.x >= plane.dist then return 1 end if
    if maxs.x <= plane.dist then return 2 end if
    return 3
  end if
  if plane.type == 1 then
    if mins.y >= plane.dist then return 1 end if
    if maxs.y <= plane.dist then return 2 end if
    return 3
  end if
  if plane.type == 2 then
    if mins.z >= plane.dist then return 1 end if
    if maxs.z <= plane.dist then return 2 end if
    return 3
  end if
  positive = t.Vec3(mins.x, mins.y, mins.z)
  negative = t.Vec3(maxs.x, maxs.y, maxs.z)
  if plane.normal.x >= 0.0 then positive.x = maxs.x; negative.x = mins.x end if
  if plane.normal.y >= 0.0 then positive.y = maxs.y; negative.y = mins.y end if
  if plane.normal.z >= 0.0 then positive.z = maxs.z; negative.z = mins.z end if
  sides = 0
  if math.dot(plane.normal, positive) >= plane.dist then sides = sides | 1 end if
  if math.dot(plane.normal, negative) < plane.dist then sides = sides | 2 end if
  return sides
end function

/// Apply server-side touched leaves semantics.
/// @param map The map input consumed by `svmTouchedLeaves`.
/// @param nodeIndex Zero-based index of the requested entry.
/// @param mins The mins input consumed by `svmTouchedLeaves`.
/// @param maxs The maxs input consumed by `svmTouchedLeaves`.
/// @param result Result value to report or translate into a status code.
function svmTouchedLeaves(map, nodeIndex, mins, maxs, result)
  if len(result) >= 16 then return result end if
  if nodeIndex < 0 then
    leafIndex = -1 - nodeIndex
    // Leaf zero is the shared solid leaf in stock BSPs. Also check the
    // contents explicitly so malformed or hand-authored maps cannot make a
    // nonzero solid leaf participate in PVS visibility.
    if leafIndex > 0 and leafIndex < len(map.leafs) and map.leafs[leafIndex].contents != c.CONTENTS_SOLID then
      result = result + [leafIndex]
    end if
    return result
  end if
  node = map.nodes[nodeIndex]
  sides = svmBoxPlaneSides(mins, maxs, map.planes[node.planeIndex])
  if (sides & 1) != 0 then result = svmTouchedLeaves(map, node.child0, mins, maxs, result) end if
  if (sides & 2) != 0 and len(result) < 16 then result = svmTouchedLeaves(map, node.child1, mins, maxs, result) end if
  return result
end function

/// Apply server-side leaf bit visible semantics.
/// @param pvs The pvs input consumed by `svmLeafBitVisible`.
/// @param leafIndex Zero-based index of the requested entry.
function svmLeafBitVisible(pvs, leafIndex)
  bitIndex = leafIndex - 1
  if bitIndex < 0 then return true end if
  byteIndex = bitIndex >> 3
  if byteIndex < 0 or byteIndex >= len(pvs) then return false end if
  return (pvs[byteIndex] & (1 << (bitIndex & 7))) != 0
end function

/// Apply server-side entity visible semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmEntityVisible`.
/// @param item The item input consumed by `svmEntityVisible`.
/// @param clientEdict The client edict input consumed by `svmEntityVisible`.
/// @param pvs The pvs input consumed by `svmEntityVisible`.
function svmEntityVisible(state, item, clientEdict, pvs)
  if item.number == clientEdict then return true end if
  if item.modelIndex == 0 or item.model == "" then return false end if
  map = state.server.worldModel
  if map is void or len(map.nodes) == 0 then return true end if
  mins = math.add(item.origin, item.mins)
  maxs = math.add(item.origin, item.maxs)
  leaves = svmTouchedLeaves(map, map.models[0].headNodes[0], mins, maxs, [])
  for each leafIndex in leaves
    if svmLeafBitVisible(pvs, leafIndex) then return true end if
  end for
  return false
end function

/// Apply server-side absolute semantics.
/// @param value Value consumed by `svmAbsolute`.
function svmAbsolute(value)
  if value < 0.0 then return -value end if
  return value
end function

/// Apply server-side entity bits semantics.
/// @param item The item input consumed by `svmEntityBits`.
function svmEntityBits(item)
  return protocolUpdate.computeBits(
    item.number, item.baseline, item.modelIndex, item.frame, item.colormap, item.skin,
    item.effects, item.origin, item.angles, item.moveType,
  )
end function

/// Exact Protocol-15 fast-update encoder used by SV_WriteEntitiesToClient.
/// @param state Mutable `miniquake.sv_main` state used by `SV_WriteEntityDelta`.
/// @param buffer The buffer input consumed by `SV_WriteEntityDelta`.
/// @param item The item input consumed by `SV_WriteEntityDelta`.
function SV_WriteEntityDelta(state, buffer, item)
  bits = svmEntityBits(item)
  return protocolUpdate.writeFastUpdateBits(
    buffer, bits, item.number, item.modelIndex, item.frame, item.colormap, item.skin,
    item.effects, item.origin, item.angles,
  )
end function

/// SV_WriteEntitiesToClient with an optional tail budget supplied by
/// SV_SendClientDatagram for frame-local sounds and temporary entities.
/// @param state Mutable `miniquake.sv_main` state used by `SV_WriteEntitiesToClientReserved`.
/// @param clientEntity The client entity input consumed by `SV_WriteEntitiesToClientReserved`.
/// @param buffer The buffer input consumed by `SV_WriteEntitiesToClientReserved`.
/// @param reservedBytes Byte data consumed by the operation.
function SV_WriteEntitiesToClientReserved(state, clientEntity, buffer, reservedBytes)
  eye = math.add(clientEntity.origin, clientEntity.viewOffset)
  pvs = SV_FatPVS(state, eye)
  written = 0
  clientIndex = clientEntity.number
  if clientIndex > 0 and clientIndex < state.server.numEdicts and clientIndex < len(state.server.edicts) then
    playerItem = state.server.edicts[clientIndex]
    if playerItem is not void and not playerItem.free then
      playerBits = svmEntityBits(playerItem)
      if not protocolUpdate.canWriteWithReservedTail(buffer, playerBits, reservedBytes) then
        state.diagnostics = state.diagnostics + ["packet overflow before player update"]
        return written
      end if
      protocolUpdate.writeFastUpdateBits(
        buffer, playerBits, playerItem.number, playerItem.modelIndex, playerItem.frame,
        playerItem.colormap, playerItem.skin, playerItem.effects, playerItem.origin,
        playerItem.angles,
      )
      written = written + 1
    end if
  end if

  // Protocol 15 permits arbitrary fast-update ordering. Send active missiles
  // and the stock bouncing grenade before ordinary entities so the fixed
  // datagram cannot intermittently omit a newly fired high-numbered edict.
  index = 1
  while index < state.server.numEdicts and index < len(state.server.edicts)
    item = state.server.edicts[index]
    if index != clientIndex and item is not void and not item.free and
      runtime.entityIsPriorityProjectile(item) and
      item.modelIndex != 0 and item.model != "" then
      bits = svmEntityBits(item)
      if not protocolUpdate.canWriteWithReservedTail(buffer, bits, reservedBytes) then
        state.diagnostics = state.diagnostics + ["packet overflow during projectile updates"]
        return written
      end if
      protocolUpdate.writeFastUpdateBits(
        buffer, bits, item.number, item.modelIndex, item.frame, item.colormap, item.skin,
        item.effects, item.origin, item.angles,
      )
      written = written + 1
    end if
    index = index + 1
  end while

  index = 1
  while index < state.server.numEdicts and index < len(state.server.edicts)
    item = state.server.edicts[index]
    if index != clientIndex and item is not void and not item.free and
      not runtime.entityIsPriorityProjectile(item) and
      svmEntityVisible(state, item, clientIndex, pvs) then
      bits = svmEntityBits(item)
      if not protocolUpdate.canWriteWithReservedTail(buffer, bits, reservedBytes) then
        state.diagnostics = state.diagnostics + ["packet overflow"]
        return written
      end if
      protocolUpdate.writeFastUpdateBits(
        buffer, bits, item.number, item.modelIndex, item.frame, item.colormap, item.skin,
        item.effects, item.origin, item.angles,
      )
      written = written + 1
    end if
    index = index + 1
  end while
  return written
end function

/// Apply the Quake-compatible sv write entities to client behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_WriteEntitiesToClient`.
/// @param clientEntity The client entity input consumed by `SV_WriteEntitiesToClient`.
/// @param buffer The buffer input consumed by `SV_WriteEntitiesToClient`.
function SV_WriteEntitiesToClient(state, clientEntity, buffer)
  return SV_WriteEntitiesToClientReserved(state, clientEntity, buffer, 0)
end function

/// SV_CleanupEnts
/// @param state Mutable `miniquake.sv_main` state used by `SV_CleanupEnts`.
function SV_CleanupEnts(state)
  cleaned = 0
  index = 1
  while index < state.server.numEdicts and index < len(state.server.edicts)
    item = state.server.edicts[index]
    if item is not void and (item.effects & c.EF_MUZZLEFLASH) != 0 then
      item.effects = item.effects & ~c.EF_MUZZLEFLASH
      if state.server.machine is not void then runtime.setQcEntityFloat(state.server, index, "effects", item.effects) end if
      cleaned = cleaned + 1
    end if
    index = index + 1
  end while
  return cleaned
end function

/// Apply server-side qc float semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmQcFloat`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param fieldName Name that identifies the requested value or resource.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function svmQcFloat(state, entityIndex, fieldName, fallback)
  if state.server.machine is void or state.server.machine.context is void then return fallback end if
  return runtime.qcFloat(state.server.machine, entityIndex, fieldName, fallback)
end function

/// Apply server-side qc vector semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmQcVector`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param fieldName Name that identifies the requested value or resource.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function svmQcVector(state, entityIndex, fieldName, fallback)
  if state.server.machine is void or state.server.machine.context is void then return fallback end if
  return runtime.qcVector(state.server.machine, entityIndex, fieldName, fallback)
end function

/// Apply server-side client items semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmClientItems`.
/// @param clientValue The client value input consumed by `svmClientItems`.
/// @param player The player input consumed by `svmClientItems`.
function svmClientItems(state, clientValue, player)
  entityIndex = clientValue.edictIndex
  items = native.trunc(svmQcFloat(state, entityIndex, "items", player.items))
  if state.server.machine is not void and state.server.machine.context is not void then
    items2Offset = vm.fieldOffset(state.server.machine, "items2")
    if items2Offset >= 0 then
      return items | (native.trunc(vm.entityFloat(state.server.machine, entityIndex, items2Offset)) << 23)
    end if
  end if
  return items | (native.trunc(state.server.serverFlags) << 28)
end function

/// Apply server-side weapon model index semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmWeaponModelIndex`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function svmWeaponModelIndex(state, entityIndex, fallback)
  if state.server.machine is void or state.server.machine.context is void then return fallback end if
  modelName = runtime.qcString(state.server.machine, entityIndex, "weaponmodel", "")
  if modelName == "" then return 0 end if
  return SV_ModelIndex(state, modelName)
end function

/// SV_SetIdealPitch.  The result is cached per client for hosts that keep their
/// player state outside QuakeC and is also written to the edict field when a VM
/// is active.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetIdealPitch`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param player The player input consumed by `SV_SetIdealPitch`.
/// @param pitchScale The pitch scale input consumed by `SV_SetIdealPitch`.
function SV_SetIdealPitch(state, clientIndex, player, pitchScale)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if clientIndex < 0 or clientIndex >= len(state.idealPitches) then return error(2879, "SV_SetIdealPitch: bad client") end if
  if (player.flags & c.FL_ONGROUND) == 0 or state.server.worldModel is void then return state.idealPitches[clientIndex] end if
  radians = player.renderAngles.y * math.PI * 2.0 / 360.0
  sine = math.sin(radians)
  cosine = math.cos(radians)
  heights = []
  index = 0
  while index < 6
    top = t.Vec3(
      player.origin.x + cosine * (index + 3) * 12.0,
      player.origin.y + sine * (index + 3) * 12.0,
      player.origin.z + player.viewHeight,
    )
    bottom = t.Vec3(top.x, top.y, top.z - 160.0)
    trace = world.traceLine(state.server.worldModel, top, bottom)
    if trace.allSolid or trace.fraction == 1.0 then return state.idealPitches[clientIndex] end if
    heights = heights + [top.z + trace.fraction * (bottom.z - top.z)]
    index = index + 1
  end while
  direction = 0
  steps = 0
  index = 1
  while index < len(heights)
    step = native.trunc(heights[index] - heights[index - 1])
    if step <= -0.1 or step >= 0.1 then
      if direction != 0 and (step - direction > 0.1 or step - direction < -0.1) then return state.idealPitches[clientIndex] end if
      steps = steps + 1
      direction = step
    end if
    index = index + 1
  end while
  if direction == 0 then
    state.idealPitches[clientIndex] = 0.0
  else if steps >= 2 then
    state.idealPitches[clientIndex] = -direction * pitchScale
  end if
  entityIndex = state.server.clients[clientIndex].edictIndex
  if state.server.machine is not void then runtime.setQcEntityFloat(state.server, entityIndex, "idealpitch", state.idealPitches[clientIndex]) end if
  return state.idealPitches[clientIndex]
end function

/// Apply server-side clamp byte semantics.
/// @param value Value consumed by `svmClampByte`.
function svmClampByte(value)
  result = native.trunc(value)
  if result < 0 then result = 0 end if
  if result > 255 then result = 255 end if
  return result
end function

/// Apply server-side write damage semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmWriteDamage`.
/// @param clientValue The client value input consumed by `svmWriteDamage`.
/// @param buffer The buffer input consumed by `svmWriteDamage`.
function svmWriteDamage(state, clientValue, buffer)
  entityIndex = clientValue.edictIndex
  damageTake = native.trunc(svmQcFloat(state, entityIndex, "dmg_take", 0.0))
  damageSave = native.trunc(svmQcFloat(state, entityIndex, "dmg_save", 0.0))
  if damageTake == 0 and damageSave == 0 then return false end if
  inflictor = runtime.qcWord(state.server.machine, entityIndex, "dmg_inflictor", 0)
  center = t.Vec3(0.0, 0.0, 0.0)
  if inflictor >= 0 and inflictor < len(state.server.edicts) then center = svmEntityCenter(state.server.edicts[inflictor]) end if
  msg.writeByte(buffer, c.SVC_DAMAGE)
  msg.writeByte(buffer, damageSave)
  msg.writeByte(buffer, damageTake)
  msg.writeCoord(buffer, center.x)
  msg.writeCoord(buffer, center.y)
  msg.writeCoord(buffer, center.z)
  runtime.setQcEntityFloat(state.server, entityIndex, "dmg_take", 0.0)
  runtime.setQcEntityFloat(state.server, entityIndex, "dmg_save", 0.0)
  return true
end function

/// Apply server-side write fix angle semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmWriteFixAngle`.
/// @param clientValue The client value input consumed by `svmWriteFixAngle`.
/// @param player The player input consumed by `svmWriteFixAngle`.
/// @param buffer The buffer input consumed by `svmWriteFixAngle`.
function svmWriteFixAngle(state, clientValue, player, buffer)
  entityIndex = clientValue.edictIndex
  fixAngle = player.fixAngle
  if svmQcFloat(state, entityIndex, "fixangle", 0.0) != 0.0 then fixAngle = true end if
  if not fixAngle then return false end if
  angles = svmQcVector(state, entityIndex, "angles", player.renderAngles)
  msg.writeByte(buffer, c.SVC_SETANGLE)
  msg.writeAngle(buffer, angles.x)
  msg.writeAngle(buffer, angles.y)
  msg.writeAngle(buffer, angles.z)
  player.fixAngle = false
  if state.server.machine is not void then runtime.setQcEntityFloat(state.server, entityIndex, "fixangle", 0.0) end if
  return true
end function

/// Apply server-side write damage and angle semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmWriteDamageAndAngle`.
/// @param clientValue The client value input consumed by `svmWriteDamageAndAngle`.
/// @param player The player input consumed by `svmWriteDamageAndAngle`.
/// @param buffer The buffer input consumed by `svmWriteDamageAndAngle`.
function svmWriteDamageAndAngle(state, clientValue, player, buffer)
  svmWriteDamage(state, clientValue, buffer)
  svmWriteFixAngle(state, clientValue, player, buffer)
  return true
end function

/// SV_WriteClientdataToMessage
/// @param state Mutable `miniquake.sv_main` state used by `SV_WriteClientdataToMessage`.
/// @param clientValue The client value input consumed by `SV_WriteClientdataToMessage`.
/// @param player The player input consumed by `SV_WriteClientdataToMessage`.
/// @param buffer The buffer input consumed by `SV_WriteClientdataToMessage`.
function SV_WriteClientdataToMessage(state, clientValue, player, buffer)
  entityIndex = clientValue.edictIndex
  clientIndex = entityIndex - 1
  // Original ordering is damage, SV_SetIdealPitch, fixangle, then the
  // svc_clientdata bitfield and payload.
  svmWriteDamage(state, clientValue, buffer)
  if clientIndex >= 0 and clientIndex < len(state.idealPitches) then
    SV_SetIdealPitch(state, clientIndex, player, 0.8)
  end if
  svmWriteFixAngle(state, clientValue, player, buffer)

  viewHeight = svmQcVector(state, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, player.viewHeight)).z
  idealPitchFallback = 0.0
  if clientIndex >= 0 and clientIndex < len(state.idealPitches) then idealPitchFallback = state.idealPitches[clientIndex] end if
  idealPitch = svmQcFloat(state, entityIndex, "idealpitch", idealPitchFallback)
  punch = svmQcVector(state, entityIndex, "punchangle", player.punchAngle)
  velocity = svmQcVector(state, entityIndex, "velocity", player.velocity)
  // Without a live QuakeC edict, PlayerState.onGround is the authoritative
  // mirror used by the integrated movement path. With QuakeC loaded, the
  // real ent->v.flags value still wins exactly as in the original engine.
  fallbackFlags = runtime.playerProtocolFlags(player)
  flags = native.trunc(svmQcFloat(state, entityIndex, "flags", fallbackFlags))
  waterLevel = native.trunc(svmQcFloat(state, entityIndex, "waterlevel", player.waterLevel))
  weaponFrame = svmQcFloat(state, entityIndex, "weaponframe", player.weaponFrame)
  armor = svmQcFloat(state, entityIndex, "armorvalue", player.armor)
  weaponModel = svmWeaponModelIndex(state, entityIndex, player.weapon)

  data = t.ProtocolClientData(
    viewHeight,
    idealPitch,
    punch,
    velocity,
    flags,
    waterLevel,
    weaponFrame,
    armor,
    weaponModel,
    svmQcFloat(state, entityIndex, "health", player.health),
    svmQcFloat(state, entityIndex, "currentammo", player.ammo),
    svmQcFloat(state, entityIndex, "ammo_shells", player.shells),
    svmQcFloat(state, entityIndex, "ammo_nails", player.nails),
    svmQcFloat(state, entityIndex, "ammo_rockets", player.rockets),
    svmQcFloat(state, entityIndex, "ammo_cells", player.cells),
    svmClientItems(state, clientValue, player),
    svmQcFloat(state, entityIndex, "weapon", player.activeWeapon),
    state.standardQuake,
  )
  result = serverData.writeClientData(buffer, data)
  return result[0]
end function

/// Apply server-side append datagram semantics.
/// @param destination Destination value or collection to update.
/// @param source Source value or collection to read.
function svmAppendDatagram(destination, source)
  return serverData.appendDatagramIfFits(destination, source)
end function

/// SV_SendClientDatagram
/// @param state Mutable `miniquake.sv_main` state used by `SV_SendClientDatagram`.
/// @param clientValue The client value input consumed by `SV_SendClientDatagram`.
/// @param player The player input consumed by `SV_SendClientDatagram`.
function SV_SendClientDatagram(state, clientValue, player)
  if not clientValue.active or not clientValue.spawned or clientValue.socket is void then return false end if
  buffer = sz.alloc(c.MAX_DATAGRAM)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, state.server.time)
  SV_WriteClientdataToMessage(state, clientValue, player, buffer)
  if clientValue.edictIndex >= 0 and clientValue.edictIndex < len(state.server.edicts) then
    item = state.server.edicts[clientValue.edictIndex]
    item.origin = math.copy(player.origin)
    item.angles = math.copy(player.renderAngles)
    item.velocity = math.copy(player.velocity)
    item.viewOffset = t.Vec3(0.0, 0.0, player.viewHeight)
    SV_WriteEntitiesToClientReserved(state, item, buffer, state.server.datagram.curSize)
  end if
  svmAppendDatagram(buffer, state.server.datagram)
  sent = netmain.NET_SendUnreliableMessage(clientValue.socket, buffer)
  if sent == -1 then
    SV_DropClient(state, clientValue, true)
    return false
  end if
  return true
end function

/// Apply server-side current frags semantics.
/// @param state Mutable `miniquake.sv_main` state used by `svmCurrentFrags`.
/// @param clientIndex Zero-based index of the requested entry.
function svmCurrentFrags(state, clientIndex)
  clientValue = state.server.clients[clientIndex]
  if state.server.machine is not void and state.server.machine.context is not void then
    return runtime.qcFloat(state.server.machine, clientValue.edictIndex, "frags", state.clientFrags[clientIndex])
  end if
  return state.clientFrags[clientIndex]
end function

/// SV_UpdateToReliableMessages
/// @param state Mutable `miniquake.sv_main` state used by `SV_UpdateToReliableMessages`.
function SV_UpdateToReliableMessages(state)
  changed = 0
  index = 0
  while index < len(state.server.clients)
    sourceClient = state.server.clients[index]
    frags = svmCurrentFrags(state, index)
    if protocolEvents.fragChanged(sourceClient.oldFrags, frags) then
      destinationIndex = 0
      while destinationIndex < len(state.server.clients)
        destination = state.server.clients[destinationIndex]
        if destination.active then protocolEvents.writeUpdateFrags(destination.message, index, frags) end if
        destinationIndex = destinationIndex + 1
      end while
      sourceClient.oldFrags = protocolEvents.storedFrag(frags)
      changed = changed + 1
    end if
    index = index + 1
  end while
  if state.server.reliableDatagram.curSize > 0 then
    for each destination in state.server.clients
      if destination.active then
        sz.write(destination.message, state.server.reliableDatagram.data, 0, state.server.reliableDatagram.curSize)
      end if
    end for
  end if
  sz.clear(state.server.reliableDatagram)
  return changed
end function

/// SV_SendNop
/// @param state Mutable `miniquake.sv_main` state used by `SV_SendNop`.
/// @param clientValue The client value input consumed by `SV_SendNop`.
function SV_SendNop(state, clientValue)
  buffer = sz.alloc(4)
  msg.writeChar(buffer, c.SVC_NOP)
  sent = netmain.NET_SendUnreliableMessage(clientValue.socket, buffer)
  if sent == -1 then SV_DropClient(state, clientValue, true) end if
  clientIndex = clientValue.edictIndex - 1
  if clientIndex >= 0 and clientIndex < len(state.lastMessages) then state.lastMessages[clientIndex] = state.realtime end if
  clientValue.lastMessage = state.realtime
  return sent != -1
end function

/// SV_DropClient is declared by server.h and implemented by host.c in the
/// original tree; it lives here because all message lifecycle decisions call it.
/// @param state Mutable `miniquake.sv_main` state used by `SV_DropClient`.
/// @param clientValue The client value input consumed by `SV_DropClient`.
/// @param crashed The crashed input consumed by `SV_DropClient`.
function SV_DropClient(state, clientValue, crashed)
  clientIndex = clientValue.edictIndex - 1
  connected = clientValue.active and clientValue.socket is not void
  if clientValue.socket is not void and not crashed and netmain.NET_CanSendMessage(clientValue.socket) then
    protocolEvents.writeDisconnect(clientValue.message)
    netmain.NET_SendMessage(clientValue.socket, clientValue.message)
  end if
  if not crashed and clientValue.active and clientValue.spawned and state.server.machine is not void then
    runtime.executeQcFunction(state.server, "ClientDisconnect", clientValue.edictIndex, 0)
  end if
  if clientValue.socket is not void then netmain.NET_Close(clientValue.socket) end if
  clientValue.socket = void
  clientValue.active = false
  clientValue.spawned = false
  clientValue.sendSignon = false
  clientValue.signonStage = 0
  clientValue.name = ""
  clientValue.oldFrags = -999999
  clientValue.lastMessage = 0.0
  clientValue.dropAsap = false
  sz.clear(clientValue.message)
  if clientIndex >= 0 and clientIndex < state.server.maxClients then
    for each peer in state.server.clients
      if peer.active then protocolEvents.writeScoreReset(peer.message, clientIndex) end if
    end for
  end if
  if connected then netmain.NET_ConnectionClosed() end if
  if clientIndex >= 0 and clientIndex < len(state.dropAsap) then state.dropAsap[clientIndex] = false end if
  return true
end function

/// Apply the Quake-compatible sv set drop asap behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SetDropAsap`.
/// @param clientIndex Zero-based index of the requested entry.
/// @param enabled Whether the optional behavior is enabled.
function SV_SetDropAsap(state, clientIndex, enabled)
  if clientIndex < 0 or clientIndex >= len(state.dropAsap) then return false end if
  state.dropAsap[clientIndex] = enabled
  state.server.clients[clientIndex].dropAsap = enabled
  return enabled
end function

/// SV_SendClientMessages
/// @param state Mutable `miniquake.sv_main` state used by `SV_SendClientMessages`.
/// @param player The player input consumed by `SV_SendClientMessages`.
function SV_SendClientMessages(state, player)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  SV_UpdateToReliableMessages(state)
  sent = 0
  index = 0
  while index < len(state.server.clients)
    clientValue = state.server.clients[index]
    if clientValue.active then
      initialPlan = serverData.initialDeliveryPlan(
        clientValue.spawned,
        clientValue.sendSignon,
        state.realtime - state.lastMessages[index],
      )

      if (initialPlan & serverData.PLAN_SEND_UNRELIABLE) != 0 then
        if not SV_SendClientDatagram(state, clientValue, player) then
          index = index + 1
          continue
        end if
        sent = sent + 1
      end if

      if clientValue.active and (initialPlan & serverData.PLAN_SEND_NOP) != 0 then
        SV_SendNop(state, clientValue)
        index = index + 1
        continue
      end if
      if clientValue.active and (initialPlan & serverData.PLAN_WAIT_SIGNON) != 0 then
        index = index + 1
        continue
      end if

      if clientValue.active and (initialPlan & serverData.PLAN_RELIABLE_PHASE) != 0 then
        canSend = false
        if clientValue.message.curSize > 0 or state.dropAsap[index] then
          canSend = netmain.NET_CanSendMessage(clientValue.socket)
        end if
        reliablePlan = serverData.reliableDeliveryPlan(
          clientValue.message.overflowed,
          clientValue.message.curSize,
          state.dropAsap[index],
          canSend,
        )
        if reliablePlan == serverData.RELIABLE_DROP_OVERFLOW then
          SV_DropClient(state, clientValue, true)
          clientValue.message.overflowed = false
        else if reliablePlan == serverData.RELIABLE_DROP_ASAP then
          SV_DropClient(state, clientValue, false)
        else if reliablePlan == serverData.RELIABLE_SEND then
          result = netmain.NET_SendMessage(clientValue.socket, clientValue.message)
          if result == -1 then
            SV_DropClient(state, clientValue, true)
          else
            sent = sent + 1
          end if
          sz.clear(clientValue.message)
          state.lastMessages[index] = state.realtime
          clientValue.lastMessage = state.realtime
          clientValue.sendSignon = false
        end if
      end if
    end if
    index = index + 1
  end while
  SV_CleanupEnts(state)
  return sent
end function

/// SV_ModelIndex
/// @param state Mutable `miniquake.sv_main` state used by `SV_ModelIndex`.
/// @param name Stable name that identifies the requested object or option.
function SV_ModelIndex(state, name)
  if name is void or name == "" then return 0 end if
  index = 0
  while index < len(state.server.modelPrecache) and index < c.MAX_MODELS
    if state.server.modelPrecache[index] == name then return index end if
    index = index + 1
  end while
  return error(2878, "SV_ModelIndex: model " + name + " not precached")
end function

/// Apply server-side write baseline semantics.
/// @param buffer The buffer input consumed by `svmWriteBaseline`.
/// @param entityNumber The entity number input consumed by `svmWriteBaseline`.
/// @param baseline The baseline input consumed by `svmWriteBaseline`.
function svmWriteBaseline(buffer, entityNumber, baseline)
  serverData.writeBaseline(buffer, entityNumber, baseline)
  return true
end function

/// SV_CreateBaseline
/// @param state Mutable `miniquake.sv_main` state used by `SV_CreateBaseline`.
function SV_CreateBaseline(state)
  created = 0
  entityNumber = 0
  while entityNumber < state.server.numEdicts and entityNumber < len(state.server.edicts)
    item = state.server.edicts[entityNumber]
    if item is not void and not item.free and (entityNumber <= state.server.maxClients or item.modelIndex != 0) then
      modelIndex = 0
      colormap = 0
      if entityNumber > 0 and entityNumber <= state.server.maxClients then
        colormap = entityNumber
        modelResult = SV_ModelIndex(state, "progs/player.mdl")
        if modelResult is error then return modelResult end if
        modelIndex = modelResult
      else
        modelResult = SV_ModelIndex(state, item.model)
        if modelResult is error then return modelResult end if
        modelIndex = modelResult
      end if
      item.baseline = t.EntityBaseline(
        modelIndex,
        item.frame,
        colormap,
        item.skin,
        0,
        math.copy(item.origin),
        math.copy(item.angles),
      )
      svmWriteBaseline(state.server.signon, entityNumber, item.baseline)
      created = created + 1
    end if
    entityNumber = entityNumber + 1
  end while
  return created
end function

/// SV_SendReconnect
/// @param state Mutable `miniquake.sv_main` state used by `SV_SendReconnect`.
function SV_SendReconnect(state)
  buffer = sz.alloc(128)
  transients.writeReconnect(buffer)
  return netmain.NET_SendToAll(state.server.clients, buffer, 5.0)
end function

/// SV_SaveSpawnparms
/// @param state Mutable `miniquake.sv_main` state used by `SV_SaveSpawnparms`.
function SV_SaveSpawnparms(state)
  return runtime.saveSpawnParmsForChange(state.server)
end function

/// SV_SpawnServer is intentionally present even though the inventory's C parser
/// drops the preprocessor-split definition.  It preserves sockets/spawn parms,
/// loads and settles QuakeC through the shared low-level runtime, then restarts
/// the four-stage signon on the new map.
/// @param state Mutable `miniquake.sv_main` state used by `SV_SpawnServer`.
/// @param filesystem The filesystem input consumed by `SV_SpawnServer`.
/// @param mapName Name of the map to load or inspect.
/// @param skill The skill input consumed by `SV_SpawnServer`.
/// @param registry The registry input consumed by `SV_SpawnServer`.
/// @param commandSystem The command system input consumed by `SV_SpawnServer`.
function SV_SpawnServer(state, filesystem, mapName, skill, registry, commandSystem)
  snapshot = []
  changing = state.server.active
  if changing then
    SV_SaveSpawnparms(state)
    snapshot = runtime.preserveClientConnections(state.server)
    SV_SendReconnect(state)
  end if
  spawned = runtime.spawnRuntime(state.server, filesystem, mapName, skill, registry, commandSystem)
  if spawned is error then return spawned end if
  if changing then runtime.finishChangeLevel(state.server, snapshot) end if
  return state.server
end function

/// Protocol-15 has no QuakeWorld multicast opcode.  The stock MiniQuake server
/// routes transient events through datagram/reliable_datagram.  This helper
/// exposes equivalent target selection for private engine producers: ALL is a
/// reliable broadcast, PVS/PHS append only to active clients in the selected
/// visibility set.  PHS falls back to PVS because MiniQuake 1.09 does not build a
/// separate hearability table.
/// @param state Mutable `miniquake.sv_main` state used by `SV_Multicast`.
/// @param origin World-space origin of the operation.
/// @param source Source value or collection to read.
/// @param mode The mode input consumed by `SV_Multicast`.
function SV_Multicast(state, origin, source, mode)
  if mode == MULTICAST_ALL then
    sz.write(state.server.reliableDatagram, source.data, 0, source.curSize)
    return len(state.server.clients)
  end if
  pvs = SV_FatPVS(state, origin)
  written = 0
  for each clientValue in state.server.clients
    if clientValue.active and clientValue.edictIndex < len(state.server.edicts) then
      clientEntity = state.server.edicts[clientValue.edictIndex]
      leafIndex = 0
      if state.server.worldModel is not void and len(state.server.worldModel.nodes) > 0 then
        leafIndex = world.leafForPoint(state.server.worldModel, math.add(clientEntity.origin, clientEntity.viewOffset))
      end if
      if leafIndex == 0 or svmLeafBitVisible(pvs, leafIndex) then
        sz.write(clientValue.message, source.data, 0, source.curSize)
        written = written + 1
      end if
    end if
  end for
  return written
end function

/// Apply the Quake-compatible sv client printf behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_ClientPrintf`.
/// @param clientValue The client value input consumed by `SV_ClientPrintf`.
/// @param text Text to parse or process.
function SV_ClientPrintf(state, clientValue, text)
  if clientValue is void or not clientValue.active then return false end if
  msg.writeByte(clientValue.message, c.SVC_PRINT)
  msg.writeString(clientValue.message, text)
  return true
end function

/// Apply the Quake-compatible sv broadcast printf behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_BroadcastPrintf`.
/// @param text Text to parse or process.
function SV_BroadcastPrintf(state, text)
  count = 0
  for each clientValue in state.server.clients
    if clientValue.active and clientValue.spawned then
      SV_ClientPrintf(state, clientValue, text)
      count = count + 1
    end if
  end for
  return count
end function

/// Apply the Quake-compatible sv add updates behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_AddUpdates`.
function SV_AddUpdates(state)
  return SV_UpdateToReliableMessages(state)
end function

/// Apply the Quake-compatible sv check bottom behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_CheckBottom`.
/// @param entityIndex Zero-based index of the requested entry.
function SV_CheckBottom(state, entityIndex)
  return serverMove.SV_CheckBottom(state.server, entityIndex)
end function

/// Apply the Quake-compatible sv movestep behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_movestep`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param movement The movement input consumed by `SV_movestep`.
/// @param relink The relink input consumed by `SV_movestep`.
function SV_movestep(state, entityIndex, movement, relink)
  return serverMove.SV_movestep(state.server, entityIndex, movement, relink)
end function

/// Apply the Quake-compatible sv move to goal behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_MoveToGoal`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param distance The distance input consumed by `SV_MoveToGoal`.
function SV_MoveToGoal(state, entityIndex, distance)
  return serverMove.SV_MoveToGoal(state.server, entityIndex, distance)
end function

/// Apply the Quake-compatible sv run clients behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_RunClients`.
/// @param player The player input consumed by `SV_RunClients`.
function SV_RunClients(state, player)
  return runtime.pumpClientMessages(state.server, player)
end function

/// Apply the Quake-compatible sv client think behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_ClientThink`.
/// @param player The player input consumed by `SV_ClientThink`.
/// @param frameTime Time value used by the operation.
/// @param registry The registry input consumed by `SV_ClientThink`.
function SV_ClientThink(state, player, frameTime, registry)
  return physics.moveServer(player, state.server, 1, state.server.clients[0].command, frameTime, registry)
end function

/// Apply the Quake-compatible sv physics behavior.
/// @param state Mutable `miniquake.sv_main` state used by `SV_Physics`.
/// @param frameTime Time value used by the operation.
/// @param gravity The gravity input consumed by `SV_Physics`.
/// @param maxVelocity The max velocity input consumed by `SV_Physics`.
function SV_Physics(state, frameTime, gravity, maxVelocity)
  return physics.SV_Physics(state.server, frameTime, gravity, maxVelocity)
end function
