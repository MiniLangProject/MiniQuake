/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.server.
*/
package miniquake.server

import miniquake.types as t
import miniquake.constants as c
import miniquake.host_command_numbers as hostNumbers
import miniquake.filesystem as qfs
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as qcedict
import miniquake.quakec.builtins as qcbuiltins
import miniquake.edict as edict
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_update as protocolUpdate
import miniquake.protocol_serverdata as serverData
import miniquake.protocol_events as protocolEvents
import miniquake.protocol_transients as transients
import miniquake.protocol_delivery as delivery
import miniquake.net_main as netmain
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.input as input
import miniquake.mathlib as math
import miniquake.player_move as movement
import miniquake.physics as physics
import miniquake.world_bsp as world
import miniquake.server_collision as collision
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.byteio as bio
import miniquake.platform.win32 as win

// SV_WriteEntitiesToClient uses one stack vec3 for the client eye position in
// the C engine. Keep the MiniLang equivalent as a stable scratch value rather
// than allocating two temporary Vec3 objects for every client snapshot.
sendClientEye = t.Vec3(0.0, 0.0, 0.0)

// Create the zero-initialized state for spawn parms.
function zeroSpawnParms()
  return arrayutil.makeFilledArray(16, 0.0)
end function

// Create and initialize server client.
function createServerClient(index)
  return t.ServerClient(
    false,
    false,
    false,
    0,
    "unconnected",
    0,
    false,
    index + 1,
    void,
    sz.allocOverflowing(c.MAX_MSGLEN),
    zeroSpawnParms(),
    input.createCommand(),
    arrayutil.makeFilledArray(16, 0.0),
    0,
    0,
    0.0,
    false,
    movement.create(t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0)),
    sz.alloc(c.MAX_DATAGRAM),
  )
end function

// The listen-server loopback client shares the host's render/input PlayerState.
// Every remote client needs an independent mirror of its own QuakeC edict.
// Socketless single-client fixtures predate ServerClient.playerState and keep
// using the supplied host state so their public frameMode contract is stable.
function playerStateForClient(server, clientValue, hostPlayer)
  if clientValue.socket is not void and clientValue.socket.transport == "loop" then
    clientValue.playerState = hostPlayer
    return hostPlayer
  end if
  if clientValue.socket is void and server.maxClients == 1 then
    clientValue.playerState = hostPlayer
    return hostPlayer
  end if
  if clientValue.playerState is void then
    clientValue.playerState = movement.create(t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0))
  end if
  return clientValue.playerState
end function

// Provide default light styles behavior for the active subsystem.
function defaultLightStyles()
  return arrayutil.makeFilledArray(64, "m")
end function

// Create and initialize the module state.
function create(maxClients)
  if maxClients < 1 then maxClients = 1 end if
  if maxClients > c.MAX_CLIENTS then maxClients = c.MAX_CLIENTS end if
  clients = arrayutil.makeEmptyArray(maxClients)
  index = 0
  while index < maxClients
    clients[index] = createServerClient(index)
    index = index + 1
  end while
  return t.GameServer(
    false,
    false,
    false,
    false,
    0.0,
    "",
    "",
    "",
    void,
    void,
    void,
    [],
    0,
    c.MAX_EDICTS,
    clients,
    maxClients,
    [""],
    [""],
    defaultLightStyles(),
    sz.alloc(c.MAX_DATAGRAM),
    sz.alloc(c.MAX_DATAGRAM),
    sz.alloc(c.MAX_MSGLEN),
    void,
    t.Vec3(0.0, 0.0, 64.0),
    t.Vec3(0.0, 0.0, 0.0),
    1,
    false,
    false,
    0,
    0,
    true,
    1,
    [],
  )
end function

// Provide resize clients behavior for the active subsystem.
function resizeClients(server, requested)
  if server.active then return error(2803, "maxplayers can not be changed while a server is running.") end if
  count = requested
  if count < 1 then count = 1 end if
  if count > c.MAX_CLIENTS then count = c.MAX_CLIENTS end if
  clients = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    if index < len(server.clients) then clients[index] = server.clients[index] else clients[index] = createServerClient(index) end if
    clients[index].edictIndex = index + 1
    index = index + 1
  end while
  server.clients = clients
  server.maxClients = count
  return count
end function

// Report whether bsp suffix.
function hasBspSuffix(name)
  source = bytes(name)
  if len(source) < 4 then return false end if
  suffix = decode(slice(source, len(source) - 4, 4))
  return suffix == ".bsp" or suffix == ".BSP"
end function

// Return clean map name derived from the active module state.
function cleanMapName(name)
  result = name
  if hasBspSuffix(result) then result = decode(slice(bytes(result), 0, len(bytes(result)) - 4)) end if
  if len(bytes(result)) >= 5 and decode(slice(bytes(result), 0, 5)) == "maps/" then result = decode(slice(bytes(result), 5, len(bytes(result)) - 5)) end if
  return result
end function

// Create and initialize player edict.
function makePlayerEdict(number)
  item = edict.create(number)
  item.className = "player"
  item.mins = t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z)
  item.maxs = t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z)
  item.moveType = c.MOVETYPE_WALK
  item.solid = c.SOLID_SLIDEBOX
  item.flags = c.FL_CLIENT
  item.health = 100.0
  item.viewOffset = t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT)
  return item
end function

// Read and validate edicts.
function loadEdicts(server, map)
  entityCount = len(map.entities)
  total = server.maxClients + entityCount
  if entityCount == 0 then total = server.maxClients + 1 end if
  result = arrayutil.makeEmptyArray(total)
  if entityCount > 0 then result[0] = edict.fromEntity(0, map.entities[0]) else result[0] = edict.create(0) end if
  result[0].className = "worldspawn"
  result[0].model = server.modelName
  result[0].modelIndex = 1
  result[0].moveType = c.MOVETYPE_PUSH
  result[0].solid = c.SOLID_BSP

  index = 0
  while index < server.maxClients
    result[index + 1] = makePlayerEdict(index + 1)
    index = index + 1
  end while

  entityIndex = 1
  while entityIndex < entityCount
    result[server.maxClients + entityIndex] = edict.fromEntity(server.maxClients + entityIndex, map.entities[entityIndex])
    entityIndex = entityIndex + 1
  end while
  return result
end function

// Return model index derived from the active module state.
function modelIndex(server, name)
  index = 0
  while index < len(server.modelPrecache)
    if server.modelPrecache[index] == name then return index end if
    index = index + 1
  end while
  return 0
end function

// Provide assign model indexes behavior for the active subsystem.
function assignModelIndexes(server)
  for each item in server.edicts
    if item.model != "" then item.modelIndex = modelIndex(server, item.model) end if
  end for
end function

// Create and initialize model precache.
function buildModelPrecache(server)
  total = len(server.worldModel.models) + 1
  if total < 2 then total = 2 end if
  result = arrayutil.makeFilledArray(total, "")
  result[1] = server.modelName
  modelIndexValue = 1
  while modelIndexValue < len(server.worldModel.models)
    result[modelIndexValue + 1] = "*" + modelIndexValue
    modelIndexValue = modelIndexValue + 1
  end while
  server.modelPrecache = result
  assignModelIndexes(server)
end function

// Provide protocol baseline behavior for the active subsystem.
function protocolBaseline(server, item)
  modelIndexValue = 0
  colormapValue = 0
  if item.number > 0 and item.number <= server.maxClients then
    colormapValue = item.number
    modelIndexValue = modelIndex(server, "progs/player.mdl")
    // The lightweight non-QuakeC spawn shell has not executed worldspawn's
    // precaches yet. Its provisional signon intentionally skips player
    // baselines; the production QuakeC spawn path must have player.mdl.
    if modelIndexValue == 0 then
      if server.machine is void or server.machine.context is void then return void end if
      return error(2812, "SV_ModelIndex: model progs/player.mdl not precached")
    end if
  else
    modelIndexValue = modelIndex(server, item.model)
    if modelIndexValue == 0 and item.model != "" then
      return error(2812, "SV_ModelIndex: model " + item.model + " not precached")
    end if
  end if
  item.baseline = t.EntityBaseline(
    modelIndexValue, native.trunc(item.frame), colormapValue, native.trunc(item.skin), 0,
    math.copy(item.origin), math.copy(item.angles),
  )
  return item.baseline
end function

// Encode and write baseline.
function writeBaseline(buffer, item)
  return serverData.writeBaseline(buffer, item.number, item.baseline)
end function

// Add state for append baselines.
function appendBaselines(server)
  entityNumber = 0
  while entityNumber < server.numEdicts and entityNumber < len(server.edicts)
    item = server.edicts[entityNumber]
    if item is not void and not item.free and (entityNumber <= server.maxClients or item.modelIndex != 0) then
      base = protocolBaseline(server, item)
      if base is error then return base end if
      if base is not void then serverData.writeBaseline(server.signon, entityNumber, base) end if
    end if
    entityNumber = entityNumber + 1
  end while
  return server.signon.curSize
end function

// Create and initialize signon.
function buildSignon(server)
  sz.clear(server.signon)
  return appendBaselines(server)
end function

// Return sound index derived from the active module state.
function soundIndex(server, name)
  index = 1
  while index < len(server.soundPrecache)
    if server.soundPrecache[index] == name then return index end if
    index = index + 1
  end while
  return 0
end function

// Add state for append quake csignon.
function appendQuakeCSignon(server, contextValue)
  staticCount = 0
  for each baseline in contextValue.staticEntities
    protocolEvents.writeSpawnStatic(
      server.signon,
      baseline[0],
      baseline[1],
      baseline[2],
      baseline[3],
      baseline[4],
      baseline[5],
    )
    staticCount = staticCount + 1
  end for
  ambientCount = 0
  for each ambient in contextValue.staticSounds
    index = soundIndex(server, ambient[1])
    if index > 0 then
      protocolEvents.writeStaticSound(server.signon, ambient[0], index, ambient[2], ambient[3])
      ambientCount = ambientCount + 1
    else
      server.diagnostics = server.diagnostics + ["ambient sound was not precached: " + ambient[1]]
    end if
  end for
  return [staticCount, ambientCount]
end function

// Report spawn and return the corresponding failure status.
function failSpawn(server, result)
  server.loading = false
  server.active = false
  server.paused = false
  server.worldModel = void
  server.progs = void
  server.machine = void
  server.edicts = []
  server.numEdicts = 0
  server.modelPrecache = [""]
  server.soundPrecache = [""]
  server.collisionHull = void
  return result
end function

// Allocate and initialize the requested value.
function spawn(server, filesystem, mapName, skill)
  name = cleanMapName(mapName)
  if name == "" then return error(2800, "SV_SpawnServer: empty map name") end if
  server.loading = true
  server.loadGame = false
  server.active = false
  server.paused = false
  server.time = 1.0
  server.mapName = name
  server.modelName = "maps/" + name + ".bsp"
  server.skill = skill
  server.diagnostics = []
  sz.clear(server.datagram)
  sz.clear(server.reliableDatagram)
  sz.clear(server.signon)

  mapData = try(qfs.readFile(filesystem, server.modelName))
  // Mod_ForName(..., false) returns null for an absent map in Quake.  Do not
  // pass MiniLang's error value to the BSP byte parser: it is not a byte array
  // and used to leave the synchronous map command stuck in its loading state.
  if mapData is error then
    return failSpawn(server, error(2865, "Couldn't spawn server " + server.modelName + ": " + mapData.message))
  end if
  parsedWorld = try(bsp.parse(mapData, server.modelName))
  if parsedWorld is error then return failSpawn(server, parsedWorld) end if
  server.worldModel = parsedWorld
  // PVS decompression is deterministic map data. Build every row now instead
  // of expanding it during server snapshots as the player explores the map.
  world.precacheLeafPvs(server.worldModel)
  // BSP collision hulls are immutable level data as well. In particular,
  // Mod_MakeHull0 expands every drawing node and must never run in a trace
  // hot path; prepare all three stock Quake hull sizes during level loading.
  world.precacheCollisionHulls(server.worldModel)
  progsData = try(qfs.readFile(filesystem, "progs.dat"))
  if progsData is error then return failSpawn(server, progsData) end if
  loadedProgs = try(qcedict.PR_LoadProgs(progsData, "progs.dat"))
  if loadedProgs is error then return failSpawn(server, loadedProgs) end if
  server.progs = loadedProgs
  server.machine = vm.create(server.progs, server.maxEdicts)
  server.edicts = loadEdicts(server, server.worldModel)
  server.numEdicts = len(server.edicts)
  buildModelPrecache(server)
  server.soundPrecache = [""]
  server.collisionHull = world.createHull(server.worldModel, 1)

  levelName = ""
  if len(server.worldModel.entities) > 0 then levelName = bsp.entityValue(server.worldModel.entities[0], "message") end if
  if levelName == "" then levelName = name end if
  server.levelName = levelName
  server.cdTrack = 0
  if len(server.worldModel.entities) > 0 then
    parsedTrack = toNumber(bsp.entityValue(server.worldModel.entities[0], "sounds"))
    if parsedTrack is not void then server.cdTrack = native.trunc(parsedTrack) end if
  end if
  location = edict.spawnPoint(server.edicts, server.deathmatch)
  server.spawnPoint = location[0]
  server.spawnAngles = location[1]
  buildSignon(server)

  for each client in server.clients
    client.active = false
    client.spawned = false
    client.sendSignon = false
    client.signonStage = 0
    client.socket = void
    client.lastMessage = 0.0
    client.dropAsap = false
    sz.clear(client.message)
  end for
  server.loading = false
  server.active = true
  server.diagnostics = server.diagnostics + ["spawned " + name + ": " + server.numEdicts + " edicts"]
  return server
end function

// Send buffer through the active connection.
function sendBuffer(client, buffer)
  if client.socket is void then return -1 end if
  if not netmain.NET_CanSendMessage(client.socket) then return 0 end if
  return netmain.NET_SendMessage(client.socket, buffer)
end function

// Return server progs crc derived from the active module state.
function serverProgsCrc(server)
  if server.progs is not void then return progs.runtimeCrc(server.progs) end if
  if server.machine is not void and server.machine.program is not void then return progs.runtimeCrc(server.machine.program) end if
  return 0
end function

// Return server game type derived from the active module state.
function serverGameType(server)
  if not server.coop and server.deathmatch then return c.GAME_DEATHMATCH end if
  return c.GAME_COOP
end function

// Send server info through the active connection.
function sendServerInfo(server, client)
  start = client.message.curSize
  serverData.writeServerInfo(
    client.message, serverProgsCrc(server), server.maxClients, serverGameType(server),
    server.levelName, server.modelPrecache, server.soundPrecache, server.cdTrack, client.edictIndex,
  )
  client.signonStage = c.SIGNON_SERVERINFO
  client.sendSignon = true
  client.spawned = false
  return client.message.curSize - start
end function

// Return global spawn parm offset derived from the active module state.
function globalSpawnParmOffset(machine, index)
  return vm.globalOffset(machine, "parm" + (index + 1))
end function

// Transfer data for copy globals to spawn parms.
function copyGlobalsToSpawnParms(server, clientValue)
  if server.machine is void then return false end if
  index = 0
  while index < len(clientValue.spawnParms)
    offset = globalSpawnParmOffset(server.machine, index)
    if offset >= 0 then clientValue.spawnParms[index] = vm.globalFloat(server.machine, offset) end if
    index = index + 1
  end while
  return true
end function

// Transfer data for copy spawn parms to globals.
function copySpawnParmsToGlobals(server, clientValue)
  if server.machine is void then return false end if
  index = 0
  while index < len(clientValue.spawnParms)
    offset = globalSpawnParmOffset(server.machine, index)
    if offset >= 0 then vm.setGlobalFloat(server.machine, offset, clientValue.spawnParms[index]) end if
    index = index + 1
  end while
  return true
end function

// Update module state for client message for connect.
function resetClientMessageForConnect(clientValue)
  // SV_ConnectClient memset() resets both cursize and the sticky overflow bit,
  // then reenables allowoverflow on the embedded client message. SZ_Clear by
  // itself intentionally does not clear overflowed.
  sz.clear(clientValue.message)
  clientValue.message.allowOverflow = true
  clientValue.message.overflowed = false
  return clientValue.message
end function

// Provide accept local behavior for the active subsystem.
function acceptLocal(server, socket)
  selected = void
  for each client in server.clients
    if not client.active then selected = client; break end if
  end for
  if selected is void then return error(2801, "SV_ConnectClient: server is full") end if
  selected.active = true
  selected.spawned = false
  selected.sendSignon = true
  selected.signonStage = 0
  selected.socket = socket
  selected.name = "unconnected"
  selected.colors = 0
  selected.oldFrags = 0
  selected.command = input.createCommand()
  // SV_ConnectClient memset() discards all per-connection movement state.
  // Do the same for MiniQuake's detached remote PlayerState mirror; otherwise
  // a later player reusing this client slot can inherit origin/health/items.
  selected.playerState = movement.create(t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0))
  selected.lastMessage = win.ticks() / 1000.0
  selected.dropAsap = false
  resetClientMessageForConnect(selected)
  netmain.NET_ConnectionAccepted()
  if server.machine is not void and server.machine.context is not void then
    // A loadgame connection preserves the spawn parms restored from disk.
    // SV_ConnectClient deliberately skips SetNewParms while sv.loadgame is set.
    if not server.loadGame then
      executeQcFunction(server, "SetNewParms", selected.edictIndex, 0)
      copyGlobalsToSpawnParms(server, selected)
    end if
  end if
  sendServerInfo(server, selected)
  return selected
end function

// Transfer data for copy number array.
function copyNumberArray(values)
  result = []
  for each value in values
    result = result + [value]
  end for
  return result
end function

// Encode and write spawn parms for change.
function saveSpawnParmsForChange(server)
  if server.machine is void or server.machine.context is void then return false end if
  serverFlagsOffset = vm.globalOffset(server.machine, "serverflags")
  if serverFlagsOffset >= 0 then server.serverFlags = native.trunc(vm.globalFloat(server.machine, serverFlagsOffset)) end if
  for each clientValue in server.clients
    if clientValue.active then
      executeQcFunction(server, "SetChangeParms", clientValue.edictIndex, 0)
      copyGlobalsToSpawnParms(server, clientValue)
    end if
  end for
  return true
end function

// Provide preserve client connections behavior for the active subsystem.
function preserveClientConnections(server)
  snapshot = []
  for each clientValue in server.clients
    snapshot = snapshot + [[
      clientValue.active,
      clientValue.socket,
      clientValue.name,
      clientValue.colors,
      clientValue.privileged,
      copyNumberArray(clientValue.spawnParms),
      clientValue.command,
      copyNumberArray(clientValue.pingTimes),
      clientValue.numPings,
      clientValue.oldFrags,
      clientValue.lastMessage,
      clientValue.dropAsap,
      clientValue.playerState,
    ]]
  end for
  return snapshot
end function

// Send reconnect through the active connection.
function sendReconnect(server)
  buffer = sz.alloc(128)
  transients.writeReconnect(buffer)
  return netmain.NET_SendToAll(server.clients, buffer, 5.0)
end function

// Initialize state for begin change level.
function beginChangeLevel(server)
  saveSpawnParmsForChange(server)
  snapshot = preserveClientConnections(server)
  if server.active then sendReconnect(server) end if
  return snapshot
end function

// Finalize state for finish change level.
function finishChangeLevel(server, snapshot)
  index = 0
  restored = 0
  while index < len(server.clients) and index < len(snapshot)
    saved = snapshot[index]
    clientValue = server.clients[index]
    if saved[0] and saved[1] is not void and not saved[1].disconnected then
      clientValue.active = true
      clientValue.spawned = false
      clientValue.sendSignon = true
      clientValue.signonStage = 0
      clientValue.socket = saved[1]
      clientValue.name = saved[2]
      clientValue.colors = saved[3]
      clientValue.privileged = saved[4]
      clientValue.spawnParms = saved[5]
      clientValue.command = saved[6]
      clientValue.pingTimes = saved[7]
      clientValue.numPings = saved[8]
      clientValue.oldFrags = saved[9]
      clientValue.lastMessage = saved[10]
      clientValue.dropAsap = saved[11]
      clientValue.playerState = saved[12]
      sz.clear(clientValue.message)
      sendServerInfo(server, clientValue)
      restored = restored + 1
    end if
    index = index + 1
  end while
  return restored
end function

// Encode and write signon stage2.
function writeSignonStage2(server, client)
  // Host_PreSpawn_f appends to client_t.message and merely marks sendsignon.
  // It must not attempt an immediate NET_SendMessage from the command parser.
  start = client.message.curSize
  if server.signon.curSize > 0 then sz.write(client.message, server.signon.data, 0, server.signon.curSize) end if
  msg.writeByte(client.message, c.SVC_SIGNONNUM)
  msg.writeByte(client.message, c.SIGNON_PRESPAWN)
  client.signonStage = c.SIGNON_PRESPAWN
  client.sendSignon = true
  return client.message.curSize - start
end function

// Reset the detached PlayerState mirror like SV_SpawnServer's cleared client
// edict before ClientConnect and PutClientInServer initialize the new level.
function resetPlayerForSpawn(player, origin, angles)
  fresh = movement.create(origin, angles)
  player.origin = fresh.origin
  player.velocity = fresh.velocity
  player.viewAngles = fresh.viewAngles
  player.renderAngles = fresh.renderAngles
  player.mins = fresh.mins
  player.maxs = fresh.maxs
  player.viewHeight = fresh.viewHeight
  player.onGround = fresh.onGround
  player.waterLevel = fresh.waterLevel
  player.moveType = fresh.moveType
  player.health = fresh.health
  player.armor = fresh.armor
  player.ammo = fresh.ammo
  player.shells = fresh.shells
  player.nails = fresh.nails
  player.rockets = fresh.rockets
  player.cells = fresh.cells
  player.items = fresh.items
  player.activeWeapon = fresh.activeWeapon
  player.weaponFrame = fresh.weaponFrame
  player.weapon = fresh.weapon
  player.noclip = fresh.noclip
  player.jumpHeld = fresh.jumpHeld
  player.flags = fresh.flags
  player.groundEntity = fresh.groundEntity
  player.waterType = fresh.waterType
  player.punchAngle = fresh.punchAngle
  player.fixAngle = fresh.fixAngle
  player.teleportTime = fresh.teleportTime
  player.moveDir = fresh.moveDir
  player.oldOrigin = fresh.oldOrigin
  player.deadFlag = fresh.deadFlag
  return player
end function

// Place one client at the new level's selected spawn point.
function placeClient(server, client, player)
  resetPlayerForSpawn(player, server.spawnPoint, server.spawnAngles)
  if client.edictIndex >= 0 and client.edictIndex < len(server.edicts) then
    item = server.edicts[client.edictIndex]
    item.free = false
    item.className = "player"
    item.origin = math.copy(player.origin)
    item.angles = math.copy(player.renderAngles)
    item.velocity = math.copy(player.velocity)
    item.health = player.health
  end if
  return true
end function

// Encode and write spawn.
function writeSpawn(server, client, player)
  if server.loadGame then
    // Host_Spawn_f treats a restored game as fully initialized.  It merely
    // unpauses and serializes the saved player; entrance QuakeC must not run.
    server.paused = false
    if server.machine is not void and server.machine.context is not void then
      syncPlayerFromQuakeC(server, client, player)
      syncQuakeCEdicts(server)
    end if
  else
    placeClient(server, client, player)
    if server.machine is not void and server.machine.context is not void then
      copySpawnParmsToGlobals(server, client)
      syncPlayerToQuakeC(server, client, player)
      executeQcFunction(server, "ClientConnect", client.edictIndex, 0)
      if client.socket is not void and win.ticks() / 1000.0 - client.socket.connectTime <= server.time then
        // Host_Spawn_f sends this through Sys_Printf.  Prefix it internally so
        // the host can preserve Sys_Printf's dedicated-only output contract.
        server.diagnostics = server.diagnostics + ["SYS_PRINT:" + client.name + " entered the game"]
      end if
      executeQcFunction(server, "PutClientInServer", client.edictIndex, 0)
      syncPlayerFromQuakeC(server, client, player)
      syncQuakeCEdicts(server)
    end if
  end if
  // Host_Spawn_f starts a fresh reliable client_t.message and leaves the
  // actual send to SV_SendClientMessages.
  sz.clear(client.message)
  client.message.overflowed = false
  buffer = client.message
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, server.time)
  index = 0
  while index < server.maxClients
    other = server.clients[index]
    scoreName = ""
    if other.active then scoreName = other.name end if
    protocolEvents.writeScoreState(buffer, index, scoreName, other.oldFrags, other.colors)
    index = index + 1
  end while
  index = 0
  while index < len(server.lightStyles)
    msg.writeByte(buffer, c.SVC_LIGHTSTYLE)
    msg.writeByte(buffer, index)
    msg.writeString(buffer, server.lightStyles[index])
    index = index + 1
  end while
  if server.machine is not void then
    statNames = ["total_secrets", "total_monsters", "found_secrets", "killed_monsters"]
    statNumbers = [c.STAT_TOTALSECRETS, c.STAT_TOTALMONSTERS, c.STAT_SECRETS, c.STAT_MONSTERS]
    index = 0
    while index < len(statNames)
      offset = vm.globalOffset(server.machine, statNames[index])
      value = 0
      if offset >= 0 then value = native.trunc(vm.globalFloat(server.machine, offset)) end if
      msg.writeByte(buffer, c.SVC_UPDATESTAT)
      msg.writeByte(buffer, statNumbers[index])
      msg.writeLong(buffer, value)
      index = index + 1
    end while
  end if
  msg.writeByte(buffer, c.SVC_SETVIEW)
  msg.writeShort(buffer, client.edictIndex)
  msg.writeByte(buffer, c.SVC_SETANGLE)
  msg.writeAngle(buffer, player.viewAngles.x)
  msg.writeAngle(buffer, player.viewAngles.y)
  msg.writeAngle(buffer, 0.0)
  writeClientData(buffer, player)
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_SPAWN)
  client.signonStage = c.SIGNON_SPAWN
  client.sendSignon = true
  return buffer.curSize
end function

// Encode and write begin.
function writeBegin(client)
  // Host_Begin_f only marks the server-side client spawned.  Original Quake
  // never emits svc_signonnum 4; the first fast entity update promotes the
  // client from signon stage three to four.
  client.spawned = true
  client.signonStage = c.SIGNON_ACTIVE
  return true
end function

// Provide client print behavior for the active subsystem.
function clientPrint(clientValue, text)
  if clientValue is void or not clientValue.active then return false end if
  msg.writeByte(clientValue.message, c.SVC_PRINT)
  msg.writeString(clientValue.message, text)
  return true
end function

// Provide command text behavior for the active subsystem.
function commandText(args, first)
  result = ""
  index = first
  while index < len(args)
    if result != "" then result = result + " " end if
    result = result + args[index]
    index = index + 1
  end while
  return result
end function

// Return truncate bytes derived from the active module state.
function truncateBytes(text, maximum)
  data = bytes(text)
  if len(data) <= maximum then return text end if
  if maximum <= 0 then return "" end if
  return decode(slice(data, 0, maximum))
end function

// Provide client float behavior for the active subsystem.
function clientFloat(server, clientValue, fieldName, fallback)
  if server.machine is void then return fallback end if
  return qcFloat(server.machine, clientValue.edictIndex, fieldName, fallback)
end function

// Update module state for client float.
function setClientFloat(server, clientValue, fieldName, value)
  if server.machine is void then return false end if
  return setQcEntityFloat(server, clientValue.edictIndex, fieldName, value)
end function

// Update module state for client name.
function setClientName(server, clientValue, newName)
  limited = protocolEvents.truncatePlayerName(newName)
  previous = clientValue.name
  clientValue.name = limited
  if server.machine is not void then qcedict.setKeyValue(server.machine, clientValue.edictIndex, "netname", limited) end if
  if previous != "" and previous != "unconnected" and previous != limited then
    server.diagnostics = server.diagnostics + [previous + " renamed to " + limited]
  end if
  protocolEvents.writeUpdateName(server.reliableDatagram, clientValue.edictIndex - 1, limited)
  return limited
end function

// Provide color component behavior for the active subsystem.
function colorComponent(value)
  result = native.trunc(value) & 15
  if result > 13 then result = 13 end if
  return result
end function

// Update module state for client colors.
function setClientColors(server, clientValue, topValue, bottomValue)
  top = colorComponent(topValue)
  bottom = colorComponent(bottomValue)
  colors = top * 16 + bottom
  clientValue.colors = colors
  setClientFloat(server, clientValue, "team", bottom + 1)
  protocolEvents.writeUpdateColors(server.reliableDatagram, clientValue.edictIndex - 1, colors)
  return colors
end function

// Provide privileged command allowed behavior for the active subsystem.
function inline privilegedCommandAllowed(server, clientValue)
  return not server.deathmatch or clientValue.privileged
end function

// Apply the Quake-compatible host status f behavior.
function Host_Status_f(server, requester)
  clientPrint(requester, "host:    " + cvar.variableString(server.machine.context.cvars, "hostname") + "\n")
  clientPrint(requester, "version: " + c.QUAKE_VERSION + "\n")
  clientPrint(requester, "map:     " + server.mapName + "\n")
  active = 0
  for each clientValue in server.clients
    if clientValue.active then active = active + 1 end if
  end for
  clientPrint(requester, "players: " + active + " active (" + server.maxClients + " max)\n\n")
  now = native.trunc(server.time)
  index = 0
  while index < len(server.clients)
    clientValue = server.clients[index]
    if clientValue.active then
      address = "LOCAL"
      seconds = now
      if clientValue.socket is not void then
        if clientValue.socket.transport == "udp" then address = clientValue.socket.address + ":" + clientValue.socket.port end if
        seconds = native.trunc(server.time - clientValue.socket.connectTime)
        if seconds < 0 then seconds = 0 end if
      end if
      minutes = native.trunc(seconds / 60)
      seconds = seconds - minutes * 60
      hours = native.trunc(minutes / 60)
      minutes = minutes - hours * 60
      frags = native.trunc(clientFloat(server, clientValue, "frags", 0.0))
      clientPrint(requester, "#" + (index + 1) + " " + clientValue.name + " " + frags + " " + hours + ":" + minutes + ":" + seconds + "\n")
      clientPrint(requester, "   " + address + "\n")
    end if
    index = index + 1
  end while
  return true
end function

// Apply the Quake-compatible host god f behavior.
function Host_God_f(server, clientValue)
  if not privilegedCommandAllowed(server, clientValue) then return false end if
  flags = native.trunc(clientFloat(server, clientValue, "flags", 0.0)) ^ c.FL_GODMODE
  setClientFloat(server, clientValue, "flags", flags)
  if (flags & c.FL_GODMODE) != 0 then clientPrint(clientValue, "godmode ON\n") else clientPrint(clientValue, "godmode OFF\n") end if
  return true
end function

// Apply the Quake-compatible host notarget f behavior.
function Host_Notarget_f(server, clientValue)
  if not privilegedCommandAllowed(server, clientValue) then return false end if
  flags = native.trunc(clientFloat(server, clientValue, "flags", 0.0)) ^ c.FL_NOTARGET
  setClientFloat(server, clientValue, "flags", flags)
  if (flags & c.FL_NOTARGET) != 0 then clientPrint(clientValue, "notarget ON\n") else clientPrint(clientValue, "notarget OFF\n") end if
  return true
end function

// Apply the Quake-compatible host noclip f behavior.
function Host_Noclip_f(server, clientValue)
  if not privilegedCommandAllowed(server, clientValue) then return false end if
  moveType = native.trunc(clientFloat(server, clientValue, "movetype", c.MOVETYPE_WALK))
  if moveType == c.MOVETYPE_NOCLIP then
    setClientFloat(server, clientValue, "movetype", c.MOVETYPE_WALK)
    clientPrint(clientValue, "noclip OFF\n")
  else
    setClientFloat(server, clientValue, "movetype", c.MOVETYPE_NOCLIP)
    clientPrint(clientValue, "noclip ON\n")
  end if
  return true
end function

// Apply the Quake-compatible host fly f behavior.
function Host_Fly_f(server, clientValue)
  if not privilegedCommandAllowed(server, clientValue) then return false end if
  moveType = native.trunc(clientFloat(server, clientValue, "movetype", c.MOVETYPE_WALK))
  if moveType == c.MOVETYPE_FLY then
    setClientFloat(server, clientValue, "movetype", c.MOVETYPE_WALK)
    clientPrint(clientValue, "flymode OFF\n")
  else
    setClientFloat(server, clientValue, "movetype", c.MOVETYPE_FLY)
    clientPrint(clientValue, "flymode ON\n")
  end if
  return true
end function

// Apply the Quake-compatible host ping f behavior.
function Host_Ping_f(server, requester)
  clientPrint(requester, "Client ping times:\n")
  for each clientValue in server.clients
    if clientValue.active then
      total = 0.0
      for each sample in clientValue.pingTimes
        total = total + sample
      end for
      if len(clientValue.pingTimes) > 0 then total = total / len(clientValue.pingTimes) end if
      clientPrint(requester, native.trunc(total * 1000.0) + " " + clientValue.name + "\n")
    end if
  end for
  return true
end function

// Apply the Quake-compatible host name f behavior.
function Host_Name_f(server, clientValue, args)
  if len(args) < 2 then return clientPrint(clientValue, "\"name\" is \"" + clientValue.name + "\"\n") end if
  return setClientName(server, clientValue, commandText(args, 1))
end function

// Apply the Quake-compatible host say behavior.
function Host_Say(server, sender, args, teamOnly)
  if len(args) < 2 then return false end if
  body = commandText(args, 1)
  prefixData = bytes(1)
  prefixData[0] = 1
  prefix = decode(prefixData) + sender.name + ": "
  maximum = 62 - len(bytes(prefix))
  text = prefix + truncateBytes(body, maximum) + "\n"
  senderTeam = native.trunc(clientFloat(server, sender, "team", 0.0))
  teamplay = cvar.variableValue(server.machine.context.cvars, "teamplay") != 0.0
  for each target in server.clients
    allowed = target.active and target.spawned
    if allowed and teamOnly and teamplay then
      allowed = native.trunc(clientFloat(server, target, "team", 0.0)) == senderTeam
    end if
    if allowed then clientPrint(target, text) end if
  end for
  server.diagnostics = server.diagnostics + [decode(slice(bytes(text), 1, len(bytes(text)) - 1))]
  return true
end function

// Apply the Quake-compatible host say f behavior.
function Host_Say_f(server, sender, args)
  return Host_Say(server, sender, args, false)
end function

// Apply the Quake-compatible host say team f behavior.
function Host_Say_Team_f(server, sender, args)
  return Host_Say(server, sender, args, true)
end function

// Apply the Quake-compatible host tell f behavior.
function Host_Tell_f(server, sender, args)
  if len(args) < 3 then return false end if
  targetName = args[1]
  // host_cmd.c uses Cmd_Args here (the complete text after "tell"), so the
  // target token is intentionally repeated in the private message body.
  body = commandText(args, 1)
  prefix = sender.name + ": "
  text = prefix + truncateBytes(body, 62 - len(bytes(prefix))) + "\n"
  for each target in server.clients
    if target.active and target.spawned and bio.equalInsensitive(target.name, targetName) then
      clientPrint(target, text)
      return true
    end if
  end for
  return false
end function

// Apply the Quake-compatible host color f behavior.
function Host_Color_f(server, clientValue, args)
  if len(args) < 2 then
    clientPrint(clientValue, "\"color\" is \"" + (clientValue.colors >> 4) + " " + (clientValue.colors & 15) + "\"\n")
    clientPrint(clientValue, "color <0-13> [0-13]\n")
    return true
  end if
  components = hostNumbers.colorArguments(args, 1)
  setClientColors(server, clientValue, components[0], components[1])
  return true
end function

// Apply the Quake-compatible host kill f behavior.
function Host_Kill_f(server, clientValue)
  if clientFloat(server, clientValue, "health", 0.0) <= 0.0 then
    clientPrint(clientValue, "Can't suicide -- allready dead!\n")
    return false
  end if
  executeQcFunction(server, "ClientKill", clientValue.edictIndex, 0)
  return true
end function

// Apply the Quake-compatible host pause f behavior.
function Host_Pause_f(server, clientValue)
  if cvar.variableValue(server.machine.context.cvars, "pausable") == 0.0 then
    clientPrint(clientValue, "Pause not allowed.\n")
    return false
  end if
  server.paused = not server.paused
  action = "unpaused"
  if server.paused then action = "paused" end if
  broadcastPrint(server, clientValue.name + " " + action + " the game\n")
  msg.writeByte(server.reliableDatagram, c.SVC_SETPAUSE)
  if server.paused then msg.writeByte(server.reliableDatagram, 1) else msg.writeByte(server.reliableDatagram, 0) end if
  return true
end function

// Apply the Quake-compatible host pre spawn f behavior.
function Host_PreSpawn_f(server, clientValue)
  if clientValue.spawned then return clientPrint(clientValue, "prespawn not valid -- allready spawned\n") end if
  return writeSignonStage2(server, clientValue)
end function

// Apply the Quake-compatible host spawn f behavior.
function Host_Spawn_f(server, clientValue, player)
  if clientValue.spawned then return clientPrint(clientValue, "Spawn not valid -- allready spawned\n") end if
  return writeSpawn(server, clientValue, player)
end function

// Apply the Quake-compatible host begin f behavior.
function Host_Begin_f(clientValue)
  return writeBegin(clientValue)
end function

// Apply the Quake-compatible host kick f behavior.
function Host_Kick_f(server, sourceClient, args)
  if len(args) < 2 then return false end if
  if sourceClient is not void and server.deathmatch and not sourceClient.privileged then return false end if
  targetIndex = -1
  messageStart = 2
  if len(args) > 2 and args[1] == "#" then
    targetIndex = hostNumbers.playerIndex(args[2])
    messageStart = 3
  else
    index = 0
    while index < len(server.clients)
      if server.clients[index].active and bio.equalInsensitive(server.clients[index].name, args[1]) then targetIndex = index; break end if
      index = index + 1
    end while
  end if
  if targetIndex < 0 or targetIndex >= len(server.clients) then return false end if
  target = server.clients[targetIndex]
  if not target.active then return false end if
  if sourceClient is not void and target.edictIndex == sourceClient.edictIndex then return false end if
  who = "Console"
  if sourceClient is not void then who = sourceClient.name end if
  reason = commandText(args, messageStart)
  if reason == "" then clientPrint(target, "Kicked by " + who + "\n") else clientPrint(target, "Kicked by " + who + ": " + reason + "\n") end if
  dropClient(server, target, false)
  return true
end function

// Update module state for give field.
function setGiveField(server, clientValue, name, value)
  if server.machine is void then return false end if
  return qcedict.setKeyValue(server.machine, clientValue.edictIndex, name, "" + value)
end function

// Apply the Quake-compatible host give f behavior.
function Host_Give_f(server, clientValue, args)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if len(args) < 3 or not privilegedCommandAllowed(server, clientValue) then return false end if
  token = args[1]
  if token == "" then return false end if
  value = hostNumbers.integer(args[2])
  first = bytes(token)[0]
  if first >= 48 and first <= 57 then
    items = native.trunc(clientFloat(server, clientValue, "items", 0.0))
    if server.machine.context.filesystem.gameDirectory == "hipnotic" then
      if first == 54 and len(bytes(token)) > 1 and bytes(token)[1] == 97 then items = items | c.HIT_PROXIMITY_GUN
      else if first == 54 then items = items | c.IT_GRENADE_LAUNCHER
      else if first == 57 then items = items | c.HIT_LASER_CANNON
      else if first == 48 then items = items | c.HIT_MJOLNIR
      else if first >= 50 then items = items | (c.IT_SHOTGUN << (first - 50))
      end if
    else if first >= 50 then
      items = items | (c.IT_SHOTGUN << (first - 50))
    end if
    setClientFloat(server, clientValue, "items", items)
    return true
  end if
  rogue = server.machine.context.filesystem.gameDirectory == "rogue"
  if first == 115 then
    if rogue then setGiveField(server, clientValue, "ammo_shells1", value) end if
    setClientFloat(server, clientValue, "ammo_shells", value)
  else if first == 110 then
    if rogue then
      setGiveField(server, clientValue, "ammo_nails1", value)
      if clientFloat(server, clientValue, "weapon", 0.0) <= c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_nails", value) end if
    else
      setClientFloat(server, clientValue, "ammo_nails", value)
    end if
  else if first == 108 and rogue then
    setGiveField(server, clientValue, "ammo_lava_nails", value)
    if clientFloat(server, clientValue, "weapon", 0.0) > c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_nails", value) end if
  else if first == 114 then
    if rogue then
      setGiveField(server, clientValue, "ammo_rockets1", value)
      if clientFloat(server, clientValue, "weapon", 0.0) <= c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_rockets", value) end if
    else
      setClientFloat(server, clientValue, "ammo_rockets", value)
    end if
  else if first == 109 and rogue then
    setGiveField(server, clientValue, "ammo_multi_rockets", value)
    if clientFloat(server, clientValue, "weapon", 0.0) > c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_rockets", value) end if
  else if first == 104 then setClientFloat(server, clientValue, "health", value)
  else if first == 99 then
    if rogue then
      setGiveField(server, clientValue, "ammo_cells1", value)
      if clientFloat(server, clientValue, "weapon", 0.0) <= c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_cells", value) end if
    else
      setClientFloat(server, clientValue, "ammo_cells", value)
    end if
  else if first == 112 and rogue then
    setGiveField(server, clientValue, "ammo_plasma", value)
    if clientFloat(server, clientValue, "weapon", 0.0) > c.IT_LIGHTNING then setClientFloat(server, clientValue, "ammo_cells", value) end if
  else
    return false
  end if
  return true
end function

// Execute string command.
function executeStringCommand(server, client, text, player)
  args = cmd.tokenize(text)
  if len(args) == 0 then return false end if
  name = bio.lower(args[0])
  if name == "prespawn" then return Host_PreSpawn_f(server, client) end if
  if name == "name" then return Host_Name_f(server, client, args) end if
  if name == "color" then return Host_Color_f(server, client, args) end if
  if name == "spawn" then return Host_Spawn_f(server, client, player) end if
  if name == "begin" then return Host_Begin_f(client) end if
  if name == "status" then return Host_Status_f(server, client) end if
  if name == "god" then return Host_God_f(server, client) end if
  if name == "notarget" then return Host_Notarget_f(server, client) end if
  if name == "noclip" then return Host_Noclip_f(server, client) end if
  if name == "fly" then return Host_Fly_f(server, client) end if
  if name == "ping" then return Host_Ping_f(server, client) end if
  if name == "say" then return Host_Say_f(server, client, args) end if
  if name == "say_team" then return Host_Say_Team_f(server, client, args) end if
  if name == "tell" then return Host_Tell_f(server, client, args) end if
  if name == "kill" then return Host_Kill_f(server, client) end if
  if name == "pause" then return Host_Pause_f(server, client) end if
  if name == "kick" then return Host_Kick_f(server, client, args) end if
  if name == "give" then return Host_Give_f(server, client, args) end if
  if name == "disconnect" then return dropClient(server, client, false) end if
  return false
end function

// Read and validate move.
function readMove(server, reader, client)
  clientTime = msg.readFloat(reader)
  ping = server.time - clientTime
  if ping < 0.0 then ping = 0.0 end if
  if len(client.pingTimes) > 0 then
    client.pingTimes[client.numPings % len(client.pingTimes)] = ping
    client.numPings = client.numPings + 1
  end if
  client.command.viewAngles = t.Vec3(msg.readAngle(reader), msg.readAngle(reader), msg.readAngle(reader))
  client.command.forwardMove = msg.readShort(reader)
  client.command.sideMove = msg.readShort(reader)
  client.command.upMove = msg.readShort(reader)
  client.command.buttons = msg.readByte(reader)
  client.command.impulse = msg.readByte(reader)
  client.command.msec = 0
  return clientTime
end function

// Release state for drop client.
function dropClient(server, client, crashed)
  wasConnected = client.active and client.socket is not void
  if client.socket is not void and not crashed and netmain.NET_CanSendMessage(client.socket) then
    protocolEvents.writeDisconnect(client.message)
    netmain.NET_SendMessage(client.socket, client.message)
  end if
  if not crashed and client.active and client.spawned and server.machine is not void then
    executeQcFunction(server, "ClientDisconnect", client.edictIndex, 0)
  end if
  if client.socket is not void then netmain.NET_Close(client.socket) end if
  client.socket = void
  client.active = false
  client.spawned = false
  client.sendSignon = false
  client.signonStage = 0
  client.name = ""
  client.oldFrags = -999999
  client.lastMessage = 0.0
  client.dropAsap = false
  sz.clear(client.message)
  scoreIndex = client.edictIndex - 1
  if scoreIndex >= 0 and scoreIndex < server.maxClients then
    for each peer in server.clients
      if peer.active then protocolEvents.writeScoreReset(peer.message, scoreIndex) end if
    end for
  end if
  if wasConnected then netmain.NET_ConnectionClosed() end if
  return true
end function

// Release state for drop timed out clients.
function dropTimedOutClients(server, timeoutSeconds)
  dropped = 0
  for each client in server.clients
    if client.active and netmain.NET_SocketTimedOut(client.socket, timeoutSeconds) then
      dropClient(server, client, true)
      dropped = dropped + 1
    end if
  end for
  return dropped
end function

// Read and validate client message.
function readClientMessage(server, client, data, player)
  reader = msg.beginReadingBytes(data)
  while msg.remaining(reader) > 0
    if not client.active or reader.badRead then return false end if
    // SV_ReadClientMessage uses MSG_ReadChar, not MSG_ReadByte. A literal 0xff
    // therefore has the same -1/end-of-message meaning as the C implementation.
    command = msg.readChar(reader)
    if command == -1 then return true end if
    if command == c.CLC_NOP then
      continue
    else if command == c.CLC_DISCONNECT then
      dropClient(server, client, false)
      return false
    else if command == c.CLC_MOVE then
      readMove(server, reader, client)
    else if command == c.CLC_STRINGCMD then
      executeStringCommand(server, client, msg.readString(reader), player)
    else
      server.diagnostics = server.diagnostics + ["SV_ReadClientMessage: unknown command char " + command]
      return false
    end if
    if reader.badRead then
      server.diagnostics = server.diagnostics + ["SV_ReadClientMessage: badread"]
      return false
    end if
  end while
  return true
end function

// Advance client messages by one processing step.
function pumpClientMessages(server, player)
  destination = sz.alloc(c.MAX_MSGLEN)
  processed = 0
  for each client in server.clients
    if client.active and client.socket is not void then
      clientPlayer = playerStateForClient(server, client, player)
      messageType = netmain.NET_GetMessage(client.socket, destination, netmain.net_messagetimeout)
      if messageType < 0 then
        dropClient(server, client, true)
        continue
      end if
      while messageType > 0
        parsed = try(readClientMessage(server, client, sz.dataSlice(destination), clientPlayer))
        if parsed is error or parsed == false then
          if client.active then dropClient(server, client, false) end if
          break
        end if
        processed = processed + 1
        messageType = netmain.NET_GetMessage(client.socket, destination, netmain.net_messagetimeout)
        if messageType < 0 then dropClient(server, client, true); break end if
      end while
    end if
  end for
  return processed
end function

// Provide entity center behavior for the active subsystem.
function entityCenter(item)
  return t.Vec3(
    item.origin.x + 0.5 * (item.mins.x + item.maxs.x),
    item.origin.y + 0.5 * (item.mins.y + item.maxs.y),
    item.origin.z + 0.5 * (item.mins.z + item.maxs.z),
  )
end function

// Encode and write damage.
function writeDamage(server, client, buffer)
  entityIndex = client.edictIndex
  if server.machine is void or server.machine.context is void then return false end if
  damageTake = native.trunc(qcFloat(server.machine, entityIndex, "dmg_take", 0.0))
  damageSave = native.trunc(qcFloat(server.machine, entityIndex, "dmg_save", 0.0))
  if damageTake == 0 and damageSave == 0 then return false end if
  inflictor = qcWord(server.machine, entityIndex, "dmg_inflictor", 0)
  center = t.Vec3(0.0, 0.0, 0.0)
  if inflictor >= 0 and inflictor < len(server.edicts) and server.edicts[inflictor] is not void then
    center = entityCenter(server.edicts[inflictor])
  end if
  msg.writeByte(buffer, c.SVC_DAMAGE)
  msg.writeByte(buffer, damageSave)
  msg.writeByte(buffer, damageTake)
  msg.writeCoord(buffer, center.x)
  msg.writeCoord(buffer, center.y)
  msg.writeCoord(buffer, center.z)
  setQcEntityFloat(server, entityIndex, "dmg_take", 0.0)
  setQcEntityFloat(server, entityIndex, "dmg_save", 0.0)
  return true
end function

// SV_SetIdealPitch. This mirrors sv_user.c's six point traces and deliberately
// truncates each sampled height delta to the original C int `step`.
function setClientIdealPitch(server, client, player, pitchScale)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  existing = 0.0
  if server.machine is not void and server.machine.context is not void then
    existing = qcFloat(server.machine, client.edictIndex, "idealpitch", 0.0)
  end if
  if (player.flags & c.FL_ONGROUND) == 0 or server.worldModel is void then return existing end if
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
    trace = world.traceLine(server.worldModel, top, bottom)
    if trace.allSolid or trace.fraction == 1.0 then
      return existing
    end if
    heights = heights + [top.z + trace.fraction * (bottom.z - top.z)]
    index = index + 1
  end while

  direction = 0
  steps = 0
  index = 1
  while index < len(heights)
    step = native.trunc(heights[index] - heights[index - 1])
    if step <= -0.1 or step >= 0.1 then
      if direction != 0 and (step - direction > 0.1 or step - direction < -0.1) then
        return existing
      end if
      steps = steps + 1
      direction = step
    end if
    index = index + 1
  end while

  value = existing
  if direction == 0 then value = 0.0 else if steps >= 2 then value = -direction * pitchScale end if
  if server.machine is not void and server.machine.context is not void then
    setQcEntityFloat(server, client.edictIndex, "idealpitch", value)
  end if
  return value
end function

// Encode and write fix angle.
function writeFixAngle(server, client, player, buffer)
  entityIndex = client.edictIndex
  fixAngle = player.fixAngle
  if server.machine is not void and server.machine.context is not void then
    if qcFloat(server.machine, entityIndex, "fixangle", 0.0) != 0.0 then fixAngle = true end if
  end if
  if not fixAngle then return false end if
  angles = player.renderAngles
  if server.machine is not void and server.machine.context is not void then
    angles = qcVector(server.machine, entityIndex, "angles", player.renderAngles)
    setQcEntityFloat(server, entityIndex, "fixangle", 0.0)
  end if
  msg.writeByte(buffer, c.SVC_SETANGLE)
  msg.writeAngle(buffer, angles.x)
  msg.writeAngle(buffer, angles.y)
  msg.writeAngle(buffer, angles.z)
  player.fixAngle = false
  return true
end function

// Encode and write damage and angle.
function writeDamageAndAngle(server, client, player, buffer)
  writeDamage(server, client, buffer)
  writeFixAngle(server, client, player, buffer)
  return true
end function

// Provide client items behavior for the active subsystem.
function clientItems(server, entityIndex, player)
  items = native.trunc(player.items)
  if server.machine is not void and server.machine.context is not void then
    items = native.trunc(qcFloat(server.machine, entityIndex, "items", player.items))
    items2Offset = vm.fieldOffset(server.machine, "items2")
    if items2Offset >= 0 then
      return items | (native.trunc(vm.entityFloat(server.machine, entityIndex, items2Offset)) << 23)
    end if
  end if
  return items | (native.trunc(server.serverFlags) << 28)
end function

// Return client weapon model index derived from the active module state.
function clientWeaponModelIndex(server, entityIndex, fallback)
  if server.machine is void or server.machine.context is void then return fallback end if
  modelName = qcString(server.machine, entityIndex, "weaponmodel", "")
  if modelName == "" then return 0 end if
  value = modelIndex(server, modelName)
  if value == 0 then return error(2812, "SV_ModelIndex: model " + modelName + " not precached") end if
  return value
end function

// PlayerState keeps groundedness in `onGround`, while the original network
// writer consumes FL_ONGROUND from ent->v.flags. Rebuild this mirrored bit for
// PlayerState-only adapter paths so stale flags cannot drop or invent
// SU_ONGROUND. QuakeC-backed paths still replace the value with QC flags.
function playerProtocolFlags(player)
  baseFlags = native.trunc(player.flags) & ~c.FL_ONGROUND
  if player.onGround then return baseFlags | c.FL_ONGROUND end if
  return baseFlags
end function

// Return protocol client data derived from the active module state.
function protocolClientData(server, client, player)
  entityIndex = client.edictIndex
  viewHeight = player.viewHeight
  idealPitch = 0.0
  punch = player.punchAngle
  velocity = player.velocity
  flags = playerProtocolFlags(player)
  waterLevel = player.waterLevel
  weaponFrame = player.weaponFrame
  armor = player.armor
  health = player.health
  currentAmmo = player.ammo
  shells = player.shells
  nails = player.nails
  rockets = player.rockets
  cells = player.cells
  activeWeapon = player.activeWeapon
  if server.machine is not void and server.machine.context is not void then
    viewHeight = qcVector(server.machine, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, player.viewHeight)).z
    idealPitch = qcFloat(server.machine, entityIndex, "idealpitch", 0.0)
    punch = qcVector(server.machine, entityIndex, "punchangle", player.punchAngle)
    velocity = qcVector(server.machine, entityIndex, "velocity", player.velocity)
    flags = native.trunc(qcFloat(server.machine, entityIndex, "flags", playerProtocolFlags(player)))
    waterLevel = native.trunc(qcFloat(server.machine, entityIndex, "waterlevel", player.waterLevel))
    weaponFrame = qcFloat(server.machine, entityIndex, "weaponframe", player.weaponFrame)
    armor = qcFloat(server.machine, entityIndex, "armorvalue", player.armor)
    health = qcFloat(server.machine, entityIndex, "health", player.health)
    currentAmmo = qcFloat(server.machine, entityIndex, "currentammo", player.ammo)
    shells = qcFloat(server.machine, entityIndex, "ammo_shells", player.shells)
    nails = qcFloat(server.machine, entityIndex, "ammo_nails", player.nails)
    rockets = qcFloat(server.machine, entityIndex, "ammo_rockets", player.rockets)
    cells = qcFloat(server.machine, entityIndex, "ammo_cells", player.cells)
    activeWeapon = qcFloat(server.machine, entityIndex, "weapon", player.activeWeapon)
  end if
  return t.ProtocolClientData(
    viewHeight, idealPitch, punch, velocity, flags, waterLevel, weaponFrame, armor,
    clientWeaponModelIndex(server, entityIndex, player.weapon), health, currentAmmo, shells, nails, rockets, cells,
    clientItems(server, entityIndex, player), activeWeapon, server.standardQuake,
  )
end function

// Encode and write client data for client.
function writeClientDataForClient(buffer, server, client, player)
  result = serverData.writeClientData(buffer, protocolClientData(server, client, player))
  return result[0]
end function

// Encode and write client data with flags.
function writeClientDataWithFlags(buffer, player, serverFlags)
  data = t.ProtocolClientData(
    player.viewHeight, 0.0, player.punchAngle, player.velocity, playerProtocolFlags(player), player.waterLevel,
    player.weaponFrame, player.armor, player.weapon, player.health, player.ammo,
    player.shells, player.nails, player.rockets, player.cells,
    native.trunc(player.items) | (native.trunc(serverFlags) << 28),
    player.activeWeapon, true,
  )
  result = serverData.writeClientData(buffer, data)
  return result[0]
end function

// Encode and write client data.
function writeClientData(buffer, player)
  return writeClientDataWithFlags(buffer, player, 0)
end function

// Encode and write player update.
function writePlayerUpdate(server, buffer, client, player)
  if client.edictIndex < 0 or client.edictIndex >= len(server.edicts) then
    return error(2810, "SV_WriteEntitiesToClient: missing player edict")
  end if
  item = server.edicts[client.edictIndex]
  if item is void then return error(2811, "SV_WriteEntitiesToClient: void player edict") end if
  // The local PlayerState is authoritative between QC synchronization points.
  // Reflect its transform before computing the same baseline delta used for all
  // other entities; the player is still always represented by a fast update.
  item.origin.x = player.origin.x
  item.origin.y = player.origin.y
  item.origin.z = player.origin.z
  item.angles.x = player.renderAngles.x
  item.angles.y = player.renderAngles.y
  item.angles.z = player.renderAngles.z
  item.moveType = player.moveType
  return writeEntityUpdate(server, buffer, item)
end function



// Return entity float value derived from the active module state.
function entityFloatValue(server, item, fieldName, fallback)
  if server.machine is not void and server.machine.context is not void then
    return qcFloat(server.machine, item.number, fieldName, fallback)
  end if
  return fallback
end function

// Return entity update values derived from the active module state.
function entityUpdateValues(server, item)
  return [
    item.modelIndex,
    native.trunc(entityFloatValue(server, item, "frame", item.frame)),
    native.trunc(entityFloatValue(server, item, "colormap", item.colormap)),
    native.trunc(entityFloatValue(server, item, "skin", item.skin)),
    native.trunc(entityFloatValue(server, item, "effects", item.effects)),
  ]
end function

// Return entity update bits derived from the active module state.
function entityUpdateBits(server, item)
  modelIndex = item.modelIndex
  frame = native.trunc(item.frame)
  colormap = native.trunc(item.colormap)
  skin = native.trunc(item.skin)
  effects = native.trunc(item.effects)
  return protocolUpdate.computeBits(
    item.number, item.baseline, modelIndex, frame, colormap, skin, effects,
    item.origin, item.angles, item.moveType,
  )
end function

// Encode and write entity update.
function writeEntityUpdate(server, buffer, item)
  modelIndex = item.modelIndex
  frame = native.trunc(item.frame)
  colormap = native.trunc(item.colormap)
  skin = native.trunc(item.skin)
  effects = native.trunc(item.effects)
  bits = protocolUpdate.computeBits(
    item.number, item.baseline, modelIndex, frame, colormap, skin, effects,
    item.origin, item.angles, item.moveType,
  )
  return protocolUpdate.writeFastUpdateBits(
    buffer, bits, item.number, modelIndex, frame, colormap, skin, effects,
    item.origin, item.angles,
  )
end function

// Report whether entity visible holds for the active state.
function entityVisible(server, pvs, item, clientEdict)
  if item.number == clientEdict then return true end if
  if item.modelIndex == 0 or item.model == "" then return false end if
  if server.worldModel is void or len(server.worldModel.nodes) == 0 then return true end if
  if len(item.leafNums) == 0 then
    mins = math.add(item.origin, item.mins)
    maxs = math.add(item.origin, item.maxs)
    if (item.flags & c.FL_ITEM) != 0 then
      mins.x = mins.x - 15.0; mins.y = mins.y - 15.0
      maxs.x = maxs.x + 15.0; maxs.y = maxs.y + 15.0
    else
      mins.x = mins.x - 1.0; mins.y = mins.y - 1.0; mins.z = mins.z - 1.0
      maxs.x = maxs.x + 1.0; maxs.y = maxs.y + 1.0; maxs.z = maxs.z + 1.0
    end if
    item.leafNums = world.touchedLeaves(server.worldModel, mins, maxs, c.MAX_ENT_LEAFS)
  end if
  return world.anyLeafVisible(pvs, item.leafNums)
end function

// Add state for append datagram.
function appendDatagram(destination, source)
  return serverData.appendDatagramIfFits(destination, source)
end function

// Encode and write planned entity update reserved.
function writePlannedEntityUpdateReserved(server, buffer, item, reservedBytes)
  // Resolve the five QuakeC values only once. The former plan-then-write path
  // built two arrays and repeated all field lookups for every visible entity.
  // syncQuakeCSnapshotEdicts has already copied these exact VM words into the
  // stable edict mirror immediately before this send phase.
  modelIndex = item.modelIndex
  frame = native.trunc(item.frame)
  colormap = native.trunc(item.colormap)
  skin = native.trunc(item.skin)
  effects = native.trunc(item.effects)
  bits = protocolUpdate.computeBits(
    item.number, item.baseline, modelIndex, frame, colormap, skin, effects,
    item.origin, item.angles, item.moveType,
  )
  if not protocolUpdate.canWriteWithReservedTail(buffer, bits, reservedBytes) then return false end if
  protocolUpdate.writeFastUpdateBits(
    buffer, bits, item.number, modelIndex, frame, colormap, skin, effects,
    item.origin, item.angles,
  )
  return true
end function

// Encode and write planned entity update.
function writePlannedEntityUpdate(server, buffer, item)
  return writePlannedEntityUpdateReserved(server, buffer, item, 0)
end function

// Report whether an entity is a latency-sensitive projectile that must be
// scheduled before ordinary snapshot entities. Rockets and expansion-pack
// missiles use MOVETYPE_FLYMISSILE; the stock grenade is a bouncing entity
// and therefore also needs its model-name discriminator.
function entityIsPriorityProjectile(item)
  if item is void then return false end if
  if item.moveType == c.MOVETYPE_FLYMISSILE then return true end if
  return item.moveType == c.MOVETYPE_BOUNCE and item.model == "progs/grenade.mdl"
end function

// Write one snapshot class while retaining the Protocol-15 packet budget.
// The caller selects either priority projectiles or ordinary entities; the
// client edict is handled separately so it can never be duplicated.
function writeVisibleEntityClassReserved(
  server,
  buffer,
  pvs,
  clientEdict,
  reservedBytes,
  priorityProjectiles,
)
  written = 0
  index = 1
  while index < server.numEdicts and index < len(server.edicts)
    item = server.edicts[index]
    classVisible = false
    if item is not void and not item.free then
      // A fast projectile can cross a BSP portal between two snapshots.  Its
      // cached/current leaf can then be outside this client's PVS for the
      // projectile's entire short lifetime even though its trajectory is
      // visible.  Priority projectiles are few and depth-occluded by the
      // world, so keep their renderable updates independent of that leaf race.
      if priorityProjectiles then
        classVisible = item.modelIndex != 0 and item.model != ""
      else
        classVisible = entityVisible(server, pvs, item, clientEdict)
      end if
    end if
    if item is not void and index != clientEdict and not item.free and
      entityIsPriorityProjectile(item) == priorityProjectiles and
      classVisible then
      if not writePlannedEntityUpdateReserved(server, buffer, item, reservedBytes) then return written end if
      written = written + 1
    end if
    index = index + 1
  end while
  return written
end function

// Write a complete visible-entity snapshot with the player and active
// projectiles ahead of less time-sensitive entities. Protocol 15 accepts fast
// updates in any entity order. Prioritization prevents a high-numbered rocket
// or grenade from disappearing when a dense PVS reaches MAX_DATAGRAM.
function writeVisibleEntityUpdatesReserved(server, buffer, pvs, clientEdict, reservedBytes)
  written = 0
  if clientEdict > 0 and clientEdict < server.numEdicts and clientEdict < len(server.edicts) then
    playerItem = server.edicts[clientEdict]
    if playerItem is not void and not playerItem.free then
      if not writePlannedEntityUpdateReserved(server, buffer, playerItem, reservedBytes) then return written end if
      written = written + 1
    end if
  end if
  written = written + writeVisibleEntityClassReserved(
    server, buffer, pvs, clientEdict, reservedBytes, true,
  )
  written = written + writeVisibleEntityClassReserved(
    server, buffer, pvs, clientEdict, reservedBytes, false,
  )
  return written
end function

// Send client frame through the active connection.
function sendClientFrame(server, client, player)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global sendClientEye
  if not client.active or not client.spawned or client.socket is void then return 0 end if
  buffer = client.datagramBuffer
  if buffer is void or buffer.maxSize != c.MAX_DATAGRAM then
    buffer = sz.alloc(c.MAX_DATAGRAM)
    client.datagramBuffer = buffer
  else
    sz.clear(buffer)
  end if
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, server.time)
  writeDamage(server, client, buffer)
  setClientIdealPitch(server, client, player, 0.8)
  writeFixAngle(server, client, player, buffer)
  writeClientDataForClient(buffer, server, client, player)

  if client.edictIndex < 0 or client.edictIndex >= len(server.edicts) then
    return error(2810, "SV_WriteEntitiesToClient: missing player edict")
  end if
  playerEdict = server.edicts[client.edictIndex]
  playerEdict.origin.x = player.origin.x
  playerEdict.origin.y = player.origin.y
  playerEdict.origin.z = player.origin.z
  playerEdict.angles.x = player.renderAngles.x
  playerEdict.angles.y = player.renderAngles.y
  playerEdict.angles.z = player.renderAngles.z
  playerEdict.moveType = player.moveType

  eye = sendClientEye
  eye.x = player.origin.x
  eye.y = player.origin.y
  eye.z = player.origin.z + player.viewHeight
  pvs = world.fatPvs(server.worldModel, eye)
  reservedBytes = server.datagram.curSize
  writeVisibleEntityUpdatesReserved(server, buffer, pvs, client.edictIndex, reservedBytes)
  appendDatagram(buffer, server.datagram)
  return netmain.NET_SendUnreliableMessage(client.socket, buffer)
end function

// Return qc entity vector derived from the active module state.
function qcEntityVector(server, entityIndex, name)
  return qcVector(server.machine, entityIndex, name, t.Vec3(0.0, 0.0, 0.0))
end function

// Provide qc set flags behavior for the active subsystem.
function qcSetFlags(server, entityIndex, flags)
  setQcEntityFloat(server, entityIndex, "flags", flags)
end function

// Execute qc touch.
function runQcTouch(server, entityIndex, otherIndex)
  touchField = vm.fieldOffset(server.machine, "touch")
  if touchField < 0 then return false end if
  touchFunction = vm.entityField(server.machine, entityIndex, touchField)
  if touchFunction == 0 then return false end if
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
  vm.execute(server.machine, touchFunction)
  return true
end function

// Provide bounds overlap behavior for the active subsystem.
function boundsOverlap(originA, minsA, maxsA, originB, minsB, maxsB)
  if originA.x + maxsA.x < originB.x + minsB.x then return false end if
  if originA.x + minsA.x > originB.x + maxsB.x then return false end if
  if originA.y + maxsA.y < originB.y + minsB.y then return false end if
  if originA.y + minsA.y > originB.y + maxsB.y then return false end if
  if originA.z + maxsA.z < originB.z + minsB.z then return false end if
  if originA.z + minsA.z > originB.z + maxsB.z then return false end if
  return true
end function

// Execute qc blocked.
function runQcBlocked(server, pusherIndex, otherIndex)
  blockedField = vm.fieldOffset(server.machine, "blocked")
  if blockedField < 0 then return false end if
  blockedFunction = vm.entityField(server.machine, pusherIndex, blockedField)
  if blockedFunction == 0 then return false end if
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, pusherIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
  vm.execute(server.machine, blockedFunction)
  return true
end function

// Execute entity think.
function runEntityThink(server, entityIndex, frameTime)
  machine = server.machine
  nextThink = qcFloat(machine, entityIndex, "nextthink", 0.0)
  if nextThink <= 0.0 or nextThink > server.time + frameTime then return true end if
  if nextThink < server.time then nextThink = server.time end if
  setQcEntityFloat(server, entityIndex, "nextthink", 0.0)
  thinkFunction = qcWord(machine, entityIndex, "think", 0)
  if thinkFunction == 0 then return error(2810, "PR_ExecuteProgram: NULL function") end if
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, nextThink)
  vm.setWord(machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, 0)
  vm.execute(machine, thinkFunction)
  return not machine.context.edicts.freeFlags[entityIndex]
end function

// Execute pusher think.
function executePusherThink(server, pusherIndex)
  thinkFunction = qcWord(server.machine, pusherIndex, "think", 0)
  setQcEntityFloat(server, pusherIndex, "nextthink", 0.0)
  if thinkFunction == 0 then return error(2810, "PR_ExecuteProgram: NULL function") end if
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, pusherIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, 0)
  vm.execute(server.machine, thinkFunction)
  return not server.machine.context.edicts.freeFlags[pusherIndex]
end function

// SV_PushMove. The pusher is moved first, every affected entity is carried by
// the same delta, and the complete operation is rolled back when one entity
// cannot be displaced. This is the stock Quake door/platform/train contract.
function movePusher(server, pusherIndex, moveTime)
  velocity = qcEntityVector(server, pusherIndex, "velocity")
  pusherSolid = native.trunc(qcFloat(server.machine, pusherIndex, "solid", c.SOLID_BSP))
  oldLtime = qcFloat(server.machine, pusherIndex, "ltime", 0.0)
  if velocity.x == 0.0 and velocity.y == 0.0 and velocity.z == 0.0 then
    setQcEntityFloat(server, pusherIndex, "ltime", oldLtime + moveTime)
    return true
  end if

  move = math.scale(velocity, moveTime)
  oldOrigin = qcEntityVector(server, pusherIndex, "origin")
  newOrigin = math.add(oldOrigin, move)
  pusherMins = qcEntityVector(server, pusherIndex, "mins")
  pusherMaxs = qcEntityVector(server, pusherIndex, "maxs")
  finalMins = math.add(newOrigin, pusherMins)
  finalMaxs = math.add(newOrigin, pusherMaxs)

  setQcEntityVector(server, pusherIndex, "origin", newOrigin)
  setQcEntityFloat(server, pusherIndex, "ltime", oldLtime + moveTime)

  movedIndexes = arrayutil.createArrayBuilder(16)
  movedOrigins = arrayutil.createArrayBuilder(16)
  blockedBy = -1
  runtime = server.machine.context.edicts
  index = 1
  while index < runtime.numEdicts
    if index != pusherIndex and not runtime.freeFlags[index] then
      moveType = native.trunc(qcFloat(server.machine, index, "movetype", c.MOVETYPE_NONE))
      solid = native.trunc(qcFloat(server.machine, index, "solid", c.SOLID_NOT))
      if moveType != c.MOVETYPE_PUSH and moveType != c.MOVETYPE_NONE and moveType != c.MOVETYPE_NOCLIP then
        flags = native.trunc(qcFloat(server.machine, index, "flags", 0.0))
        groundEntity = qcWord(server.machine, index, "groundentity", -1)
        standing = (flags & c.FL_ONGROUND) != 0 and groundEntity == pusherIndex
        shouldMove = standing
        if not shouldMove then
          origin = qcEntityVector(server, index, "origin")
          mins = qcEntityVector(server, index, "mins")
          maxs = qcEntityVector(server, index, "maxs")
          absMin = math.add(origin, mins)
          absMax = math.add(origin, maxs)
          if collision.boxesOverlap(absMin, absMax, finalMins, finalMaxs) then
            shouldMove = collision.testEntityPosition(server, index) >= 0
          end if
        end if

        if shouldMove then
          origin = qcEntityVector(server, index, "origin")
          arrayutil.pushArrayBuilder(movedIndexes, index)
          arrayutil.pushArrayBuilder(movedOrigins, origin)
          if moveType != c.MOVETYPE_WALK then
            flags = flags & ~c.FL_ONGROUND
            setQcEntityFloat(server, index, "flags", flags)
          end if

          // The contacted entity is allowed to move through the pusher that is
          // carrying it, exactly as SV_PushMove temporarily sets SOLID_NOT.
          setQcEntityFloat(server, pusherIndex, "solid", c.SOLID_NOT)
          collision.pushEntity(server, index, move)
          setQcEntityFloat(server, pusherIndex, "solid", pusherSolid)

          block = collision.testEntityPosition(server, index)
          if block >= 0 then
            mins = qcEntityVector(server, index, "mins")
            maxs = qcEntityVector(server, index, "maxs")
            if mins.x == maxs.x then
              // Point-sized entities never block pushers.
            else if solid == c.SOLID_NOT or solid == c.SOLID_TRIGGER then
              collapsed = t.Vec3(0.0, 0.0, 0.0)
              setQcEntityVector(server, index, "mins", collapsed)
              setQcEntityVector(server, index, "maxs", collapsed)
            else
              setQcEntityVector(server, index, "origin", origin)
              blockedBy = index
              break
            end if
          end if
        end if
      end if
    end if
    index = index + 1
  end while

  if blockedBy >= 0 then
    setQcEntityVector(server, pusherIndex, "origin", oldOrigin)
    setQcEntityFloat(server, pusherIndex, "ltime", oldLtime)
    indexes = arrayutil.finishArrayBuilder(movedIndexes)
    origins = arrayutil.finishArrayBuilder(movedOrigins)
    // In sv_phys.c the blocked callback runs while previously carried
    // entities are still at their pushed locations. The rollback follows the
    // callback, and only origins are restored (the cleared onground flag is
    // deliberately not restored).
    runQcBlocked(server, pusherIndex, blockedBy)
    rollback = 0
    while rollback < len(indexes)
      setQcEntityVector(server, indexes[rollback], "origin", origins[rollback])
      rollback = rollback + 1
    end while
    return false
  end if
  return true
end function

// Apply server-physics pusher semantics.
function physicsPusher(server, entityIndex, frameTime)
  oldLtime = qcFloat(server.machine, entityIndex, "ltime", 0.0)
  thinkTime = qcFloat(server.machine, entityIndex, "nextthink", 0.0)
  moveTime = frameTime
  if thinkTime > 0.0 and thinkTime < oldLtime + frameTime then
    moveTime = thinkTime - oldLtime
    if moveTime < 0.0 then moveTime = 0.0 end if
  end if
  if moveTime > 0.0 then movePusher(server, entityIndex, moveTime) end if
  newLtime = qcFloat(server.machine, entityIndex, "ltime", oldLtime)
  if thinkTime > oldLtime and thinkTime <= newLtime then executePusherThink(server, entityIndex) end if
  return true
end function

// Provide touch player triggers behavior for the active subsystem.
function touchPlayerTriggers(server, clientValue, player)
  if server.machine is void or server.machine.context is void then return 0 end if
  touched = 0
  index = server.maxClients + 1
  while index < server.machine.context.edicts.numEdicts
    if not server.machine.context.edicts.freeFlags[index] then
      solid = native.trunc(qcFloat(server.machine, index, "solid", c.SOLID_NOT))
      if solid == c.SOLID_TRIGGER then
        origin = qcEntityVector(server, index, "origin")
        mins = qcEntityVector(server, index, "mins")
        maxs = qcEntityVector(server, index, "maxs")
        if boundsOverlap(player.origin, player.mins, player.maxs, origin, mins, maxs) then
          if runQcTouch(server, index, clientValue.edictIndex) then touched = touched + 1 end if
        end if
      end if
    end if
    index = index + 1
  end while
  return touched
end function

// Provide resolve player entity collision behavior for the active subsystem.
function resolvePlayerEntityCollision(server, clientValue, player, oldOrigin)
  if server.machine is void or server.machine.context is void or player.noclip then return false end if
  index = server.maxClients + 1
  while index < server.machine.context.edicts.numEdicts
    if not server.machine.context.edicts.freeFlags[index] then
      solid = native.trunc(qcFloat(server.machine, index, "solid", c.SOLID_NOT))
      if solid == c.SOLID_BBOX or solid == c.SOLID_SLIDEBOX or solid == c.SOLID_BSP then
        origin = qcEntityVector(server, index, "origin")
        mins = qcEntityVector(server, index, "mins")
        maxs = qcEntityVector(server, index, "maxs")
        if boundsOverlap(player.origin, player.mins, player.maxs, origin, mins, maxs) then
          player.origin = math.copy(oldOrigin)
          player.velocity = t.Vec3(0.0, 0.0, 0.0)
          syncPlayerToQuakeC(server, clientValue, player)
          runQcTouch(server, index, clientValue.edictIndex)
          runQcTouch(server, clientValue.edictIndex, index)
          return true
        end if
      end if
    end if
    index = index + 1
  end while
  return false
end function

// Transfer data for move qc entity.
function moveQcEntity(server, entityIndex, frameTime, gravity)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  machine = server.machine
  moveType = native.trunc(qcFloat(machine, entityIndex, "movetype", c.MOVETYPE_NONE))
  if moveType == c.MOVETYPE_PUSH then return physicsPusher(server, entityIndex, frameTime) end if
  if not runEntityThink(server, entityIndex, frameTime) then return false end if
  if moveType == c.MOVETYPE_NONE then return false end if

  origin = qcEntityVector(server, entityIndex, "origin")
  velocity = qcEntityVector(server, entityIndex, "velocity")
  angles = qcEntityVector(server, entityIndex, "angles")
  angularVelocity = qcEntityVector(server, entityIndex, "avelocity")
  if moveType == c.MOVETYPE_NOCLIP then
    setQcEntityVector(server, entityIndex, "origin", math.multiplyAdd(origin, frameTime, velocity))
    setQcEntityVector(server, entityIndex, "angles", math.multiplyAdd(angles, frameTime, angularVelocity))
    return true
  end if

  flags = native.trunc(qcFloat(machine, entityIndex, "flags", 0.0))
  if moveType == c.MOVETYPE_STEP then
    if (flags & (c.FL_ONGROUND | c.FL_FLY | c.FL_SWIM)) == 0 then velocity.z = velocity.z - gravity * frameTime end if
  else if moveType == c.MOVETYPE_TOSS or moveType == c.MOVETYPE_BOUNCE then
    if (flags & c.FL_ONGROUND) != 0 then return false end if
    velocity.z = velocity.z - gravity * frameTime
  else if moveType != c.MOVETYPE_FLY and moveType != c.MOVETYPE_FLYMISSILE then
    return false
  end if

  setQcEntityVector(server, entityIndex, "angles", math.multiplyAdd(angles, frameTime, angularVelocity))
  mins = qcEntityVector(server, entityIndex, "mins")
  maxs = qcEntityVector(server, entityIndex, "maxs")
  destination = math.multiplyAdd(origin, frameTime, velocity)
  traceType = c.MOVE_NORMAL
  if moveType == c.MOVETYPE_FLYMISSILE then traceType = c.MOVE_MISSILE end if
  trace = collision.move(server, origin, mins, maxs, destination, traceType, entityIndex)
  setQcEntityVector(server, entityIndex, "origin", trace.endPosition)

  if trace.fraction < 1.0 then
    if trace.entity >= 0 then collision.impact(server, entityIndex, trace.entity) end if
    if machine.context.edicts.freeFlags[entityIndex] then return true end if
    overbounce = 1.0
    if moveType == c.MOVETYPE_BOUNCE then overbounce = 1.5 end if
    velocity = movement.clipVelocity(velocity, trace.plane.normal, overbounce)
    if trace.plane.normal.z > 0.7 and (velocity.z < 60.0 or moveType != c.MOVETYPE_BOUNCE) then
      flags = flags | c.FL_ONGROUND
      setQcEntityWord(server, entityIndex, "groundentity", trace.entity)
      velocity = t.Vec3(0.0, 0.0, 0.0)
      angularVelocity = t.Vec3(0.0, 0.0, 0.0)
      setQcEntityVector(server, entityIndex, "avelocity", angularVelocity)
    end if
  else
    flags = flags & ~c.FL_ONGROUND
  end if
  qcSetFlags(server, entityIndex, flags)
  setQcEntityVector(server, entityIndex, "velocity", velocity)
  collision.touchTriggers(server, entityIndex)
  return true
end function

// Apply server-physics frame parameters semantics.
function physicsFrameParameters(registry)
  gravity = cvar.variableValue(registry, "sv_gravity")
  if gravity <= 0.0 then gravity = 800.0 end if
  maxVelocity = cvar.variableValue(registry, "sv_maxvelocity")
  if maxVelocity <= 0.0 then maxVelocity = 2000.0 end if
  return [gravity, maxVelocity]
end function

// Execute world physics with retouch.
function runWorldPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
  if server.machine is void or server.machine.context is void then return 0 end if
  if server.machine.context.edicts.numEdicts <= 0 then return 0 end if
  if server.machine.context.edicts.freeFlags[0] then return 0 end if
  parameters = physicsFrameParameters(registry)
  physics.SV_ForceRetouchEntity(server, 0, forceRetouch)
  if physics.SV_Physics_NonClientEntity(server, 0, frameTime, parameters[0], parameters[1]) then return 1 end if
  return 0
end function

// Execute non client physics with retouch.
function runNonClientPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
  if server.machine is void or server.machine.context is void then return 0 end if
  parameters = physicsFrameParameters(registry)
  gravity = parameters[0]
  maxVelocity = parameters[1]
  machine = server.machine
  moveTypeOffset = vm.fieldOffset(machine, "movetype")
  nextThinkOffset = vm.fieldOffset(machine, "nextthink")
  moved = 0
  index = server.maxClients + 1
  while index < machine.context.edicts.numEdicts
    if not machine.context.edicts.freeFlags[index] then
      physics.SV_ForceRetouchEntity(server, index, forceRetouch)
      // Most map entities are MOVETYPE_NONE and have no think scheduled for
      // this frame.  The C engine reads those two entvars directly.  Avoid the
      // generic name-based collision adapter and full dispatch for this exact
      // no-op case; due thinks and every moving physics class still enter the
      // original SV_Physics_NonClientEntity implementation unchanged.
      directNoOp = false
      if moveTypeOffset >= 0 and nextThinkOffset >= 0 then
        fields = machine.edicts[index]
        moveType = native.trunc(native.bitsFloat(fields[moveTypeOffset]))
        if moveType == c.MOVETYPE_NONE then
          thinkTime = native.bitsFloat(fields[nextThinkOffset])
          directNoOp = thinkTime <= 0.0 or thinkTime > server.time + frameTime
        end if
      end if
      if directNoOp then
        moved = moved + 1
      else if physics.SV_Physics_NonClientEntity(server, index, frameTime, gravity, maxVelocity) then
        moved = moved + 1
      end if
    end if
    index = index + 1
  end while
  return moved
end function

// Execute non client physics.
function runNonClientPhysics(server, frameTime, registry)
  forceRetouch = physics.SV_ForceRetouchValue(server)
  moved = runWorldPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
  moved = moved + runNonClientPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
  physics.SV_FinishForceRetouch(server, forceRetouch)
  return moved
end function

// Add state for queued sound origin.
function queuedSoundOrigin(server, entityIndex)
  if entityIndex < 0 or entityIndex >= len(server.edicts) then return error(2816, "SV_StartSound: bad entity " + entityIndex) end if
  item = server.edicts[entityIndex]
  if item is void then return error(2816, "SV_StartSound: bad entity " + entityIndex) end if
  return transients.soundCenter(item.origin, item.mins, item.maxs)
end function

// Encode and write queued sound.
function writeQueuedSound(server, event)
  entityIndex = native.trunc(event[0])
  channel = native.trunc(event[1])
  sample = event[2]
  volume = native.trunc(event[3])
  attenuation = transients.cFloat(event[4])
  if volume < 0 or volume > 255 then return error(2813, "SV_StartSound: volume = " + volume) end if
  if attenuation < 0.0 or attenuation > 4.0 then return error(2814, "SV_StartSound: attenuation = " + attenuation) end if
  if channel < 0 or channel > 7 then return error(2815, "SV_StartSound: channel = " + channel) end if
  if not transients.canWriteDynamicSound(server.datagram) then return false end if
  index = soundIndex(server, sample)
  if index == 0 then
    server.diagnostics = server.diagnostics + ["sound was not precached: " + sample]
    return false
  end if
  origin = queuedSoundOrigin(server, entityIndex)
  serverData.writeSound(server.datagram, entityIndex, channel, index, volume, attenuation, origin)
  return true
end function

// Encode and write queued particle.
function writeQueuedParticle(server, event)
  if not protocolEvents.canWriteTransient(server.datagram) then return false end if
  protocolEvents.writeParticle(server.datagram, event[0], event[1], event[2], event[3])
  return true
end function

// Provide flush quake cevents behavior for the active subsystem.
function flushQuakeCEvents(server)
  if server.machine is void or server.machine.context is void then return 0 end if
  contextValue = server.machine.context
  written = 0
  for each event in contextValue.soundEvents
    if writeQueuedSound(server, event) then written = written + 1 end if
  end for
  for each event in contextValue.particles
    if writeQueuedParticle(server, event) then written = written + 1 end if
  end for
  contextValue.soundEvents = []
  contextValue.particles = []
  return written
end function

// Provide broadcast print behavior for the active subsystem.
function broadcastPrint(server, text)
  written = 0
  for each clientValue in server.clients
    if clientValue.active and clientValue.spawned then
      msg.writeByte(clientValue.message, c.SVC_PRINT)
      msg.writeString(clientValue.message, text)
      written = written + 1
    end if
  end for
  return written
end function

// Update module state for reliable client state.
function updateReliableClientState(server)
  changed = 0
  sourceIndex = 0
  while sourceIndex < len(server.clients)
    sourceClient = server.clients[sourceIndex]
    frags = 0.0
    if server.machine is not void and server.machine.context is not void then
      frags = qcFloat(server.machine, sourceClient.edictIndex, "frags", 0.0)
    end if
    if protocolEvents.fragChanged(sourceClient.oldFrags, frags) then
      destinationIndex = 0
      while destinationIndex < len(server.clients)
        destination = server.clients[destinationIndex]
        if destination.active then protocolEvents.writeUpdateFrags(destination.message, sourceIndex, frags) end if
        destinationIndex = destinationIndex + 1
      end while
      sourceClient.oldFrags = protocolEvents.storedFrag(frags)
      changed = changed + 1
    end if
    sourceIndex = sourceIndex + 1
  end while
  return changed
end function

// Provide distribute reliable datagram behavior for the active subsystem.
function distributeReliableDatagram(server)
  copied = 0
  if server.reliableDatagram.curSize > 0 then
    index = 0
    while index < len(server.clients)
      clientValue = server.clients[index]
      if clientValue.active then
        sz.write(clientValue.message, server.reliableDatagram.data, 0, server.reliableDatagram.curSize)
        copied = copied + 1
      end if
      index = index + 1
    end while
  end if
  sz.clear(server.reliableDatagram)
  return copied
end function

// Provide prepare reliable messages behavior for the active subsystem.
function prepareReliableMessages(server)
  updates = updateReliableClientState(server)
  copies = distributeReliableDatagram(server)
  return [updates, copies]
end function

// Send nop at through the active connection.
function sendNopAt(server, clientValue, realtime)
  buffer = sz.alloc(4)
  msg.writeChar(buffer, c.SVC_NOP)
  result = netmain.NET_SendUnreliableMessage(clientValue.socket, buffer)
  if result == -1 then dropClient(server, clientValue, true) end if
  clientValue.lastMessage = realtime
  return result
end function

// Execute reliable client at.
function processReliableClientAt(server, clientValue, realtime)
  canSend = false
  if clientValue.message.curSize > 0 or clientValue.dropAsap then
    canSend = netmain.NET_CanSendMessage(clientValue.socket)
  end if
  plan = serverData.reliableDeliveryPlan(
    clientValue.message.overflowed,
    clientValue.message.curSize,
    clientValue.dropAsap,
    canSend,
  )
  if plan == serverData.RELIABLE_DROP_OVERFLOW then
    dropClient(server, clientValue, true)
    clientValue.message.overflowed = false
    return -1
  end if
  if plan == serverData.RELIABLE_NONE or plan == serverData.RELIABLE_WAIT then return 0 end if
  if plan == serverData.RELIABLE_DROP_ASAP then
    dropClient(server, clientValue, false)
    return -1
  end if

  result = netmain.NET_SendMessage(clientValue.socket, clientValue.message)
  outcome = delivery.reliableSendOutcome(result)
  if outcome == delivery.SEND_DROP then
    dropClient(server, clientValue, true)
    return -1
  end if
  if outcome == delivery.SEND_RETAIN then return 0 end if
  sz.clear(clientValue.message)
  clientValue.lastMessage = realtime
  clientValue.sendSignon = false
  return result
end function

// Reliable-only pump used by the explicit local signon loop. The full server
// frame calls sendClientMessagesAt so spawned clients receive their unreliable
// datagram before this reliable phase.
function sendReliableMessagesAt(server, realtime)
  // The public helper returns a two-element diagnostic array. Production only
  // needs the side effects and must not allocate that array every host frame.
  updateReliableClientState(server)
  distributeReliableDatagram(server)
  sent = 0
  index = 0
  while index < len(server.clients)
    clientValue = server.clients[index]
    if clientValue.active and clientValue.socket is not void then
      if not clientValue.spawned and not clientValue.sendSignon then
        if delivery.keepaliveDue(realtime - clientValue.lastMessage) then
          result = sendNopAt(server, clientValue, realtime)
          if result > 0 then sent = sent + 1 end if
        end if
      else
        result = processReliableClientAt(server, clientValue, realtime)
        if result > 0 then sent = sent + 1 end if
      end if
    end if
    index = index + 1
  end while
  return sent
end function

// Send reliable messages through the active connection.
function sendReliableMessages(server)
  return sendReliableMessagesAt(server, win.ticks() / 1000.0)
end function

// Provide cleanup muzzle flashes behavior for the active subsystem.
function cleanupMuzzleFlashes(server)
  cleaned = 0
  index = 1
  while index < server.numEdicts and index < len(server.edicts)
    item = server.edicts[index]
    if item is not void and not item.free then
      effects = native.trunc(item.effects) & ~c.EF_MUZZLEFLASH
      if effects != native.trunc(item.effects) then
        item.effects = effects
        if server.machine is not void and server.machine.context is not void then
          setQcEntityFloat(server, index, "effects", effects)
        end if
        cleaned = cleaned + 1
      end if
    end if
    index = index + 1
  end while
  return cleaned
end function

// Send client messages at through the active connection.
function sendClientMessagesAt(server, player, realtime)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  updateReliableClientState(server)
  distributeReliableDatagram(server)
  sent = 0
  index = 0
  while index < len(server.clients)
    clientValue = server.clients[index]
    if clientValue.active and clientValue.socket is not void then
      clientPlayer = playerStateForClient(server, clientValue, player)
      initialPlan = serverData.initialDeliveryPlan(
        clientValue.spawned,
        clientValue.sendSignon,
        realtime - clientValue.lastMessage,
      )

      if (initialPlan & serverData.PLAN_SEND_UNRELIABLE) != 0 then
        frameResult = sendClientFrame(server, clientValue, clientPlayer)
        if frameResult == -1 then
          dropClient(server, clientValue, true)
          index = index + 1
          continue
        end if
        if frameResult > 0 then sent = sent + 1 end if
      end if

      if clientValue.active and (initialPlan & serverData.PLAN_SEND_NOP) != 0 then
        nopResult = sendNopAt(server, clientValue, realtime)
        if nopResult > 0 then sent = sent + 1 end if
        index = index + 1
        continue
      end if
      if clientValue.active and (initialPlan & serverData.PLAN_WAIT_SIGNON) != 0 then
        index = index + 1
        continue
      end if

      if clientValue.active and (initialPlan & serverData.PLAN_RELIABLE_PHASE) != 0 then
        reliableResult = processReliableClientAt(server, clientValue, realtime)
        if reliableResult > 0 then sent = sent + 1 end if
      end if
    end if
    index = index + 1
  end while
  cleanupMuzzleFlashes(server)
  return sent
end function

// Send client messages through the active connection.
function sendClientMessages(server, player)
  return sendClientMessagesAt(server, player, win.ticks() / 1000.0)
end function

// Advance mode by one processing step.
function frameMode(server, player, frameTime, registry, simulate)
  if not server.active then return false end if
  pumpClientMessages(server, player)
  forceRetouch = 0.0

  if simulate then
  // SV_Physics ordering: StartFrame, client edicts in numerical order, then
  // every remaining entity. This matters for pushers: a door/platform moves
  // after the player and carries anything standing on it during that frame.
  if server.machine is not void and server.machine.context is not void then
    for each clientValue in server.clients
      if clientValue.active and clientValue.spawned then
        clientPlayer = playerStateForClient(server, clientValue, player)
        syncPlayerToQuakeC(server, clientValue, clientPlayer)
      end if
    end for
    runQuakeCFrame(server, frameTime)
    forceRetouch = physics.SV_ForceRetouchValue(server)
    // SV_Physics begins with edict zero before the client slots.  The world
    // normally has no scheduled think, but preserving this order is required
    // for force_retouch and for maps or mods that do schedule one.
    runWorldPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
  end if

  for each clientValue in server.clients
    if server.machine is not void and server.machine.context is not void then
      physics.SV_ForceRetouchEntity(server, clientValue.edictIndex, forceRetouch)
    end if
    if clientValue.active and clientValue.spawned then
      clientPlayer = playerStateForClient(server, clientValue, player)
      if server.machine is not void and server.machine.context is not void then
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
        syncCommandToQuakeC(server, clientValue)
        executeQcFunction(server, "PlayerPreThink", clientValue.edictIndex, 0)
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
        // SV_RunThink is part of SV_Physics_Client as well.
        runEntityThink(server, clientValue.edictIndex, frameTime)
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
      end if

      physics.moveServer(clientPlayer, server, clientValue.edictIndex, clientValue.command, frameTime, registry)
      clientPlayer.renderAngles.y = clientPlayer.viewAngles.y

      if server.machine is not void and server.machine.context is not void then
        // moveServer links the client with touch=true, exactly where
        // SV_Physics_Client invokes item/teleport/trigger callbacks. Pull the
        // callback's edict mutations into PlayerState before pushing the
        // render yaw and entering PlayerPostThink.
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
        clientPlayer.renderAngles.y = clientPlayer.viewAngles.y
        syncPlayerToQuakeC(server, clientValue, clientPlayer)
        executeQcFunction(server, "PlayerPostThink", clientValue.edictIndex, 0)
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
      end if
    end if
  end for

  if server.machine is not void and server.machine.context is not void then
    runNonClientPhysicsWithRetouch(server, frameTime, registry, forceRetouch)
    physics.SV_FinishForceRetouch(server, forceRetouch)
    // Pushers are evaluated after clients in SV_Physics.  A door, lift or train
    // may therefore carry the player after PlayerPostThink.  Preserve that
    // authoritative edict position in the shared local PlayerState instead of
    // overwriting it with the pre-pusher position at the start of the next
    // frame.
    for each clientValue in server.clients
      if clientValue.active and clientValue.spawned then
        clientPlayer = playerStateForClient(server, clientValue, player)
        syncPlayerFromQuakeC(server, clientValue, clientPlayer)
      end if
    end for
  end if

  server.time = server.time + frameTime
  if server.machine is not void and server.machine.context is not void then
    server.machine.context.serverTime = server.time
    vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
    syncQuakeCSnapshotEdicts(server)
    flushQuakeCEvents(server)
  end if
  end if
  sendClientMessages(server, player)
  sz.clear(server.datagram)
  return true
end function

// Advance the requested value by one processing step.
function frame(server, player, frameTime, registry)
  return frameMode(server, player, frameTime, registry, not server.paused)
end function

// Release state for shutdown.
function shutdown(server)
  for each client in server.clients
    wasConnected = client.active and client.socket is not void
    if client.socket is not void then netmain.NET_Close(client.socket) end if
    if wasConnected then netmain.NET_ConnectionClosed() end if
    client.active = false
    client.spawned = false
  end for
  server.loading = false
  server.active = false
  server.worldModel = void
  server.machine = void
  return true
end function

// -----------------------------------------------------------------------------
// QuakeC-backed server spawning and per-frame execution.
// -----------------------------------------------------------------------------

function boolArray(count, defaultValue)
  return arrayutil.makeFilledArray(count, defaultValue)
end function

// Provide number array behavior for the active subsystem.
function numberArray(count, defaultValue)
  return arrayutil.makeFilledArray(count, defaultValue)
end function

// Create and initialize edict runtime.
function createEdictRuntime(maxEdicts, reservedClients)
  freeFlags = boolArray(maxEdicts, true)
  freeTimes = numberArray(maxEdicts, 0.0)
  index = 0
  while index <= reservedClients and index < maxEdicts
    freeFlags[index] = false
    index = index + 1
  end while
  return t.EdictRuntime(maxEdicts, reservedClients + 1, freeFlags, freeTimes)
end function

// Provide client message buffers behavior for the active subsystem.
function clientMessageBuffers(server)
  result = arrayutil.makeEmptyArray(len(server.clients))
  index = 0
  while index < len(server.clients)
    result[index] = server.clients[index].message
    index = index + 1
  end while
  return result
end function

// Provide client spawn parm buffers behavior for the active subsystem.
function clientSpawnParmBuffers(server)
  result = arrayutil.makeEmptyArray(len(server.clients))
  index = 0
  while index < len(server.clients)
    // Arrays are reference values in MiniLang, so the builtin sees the live
    // spawn-parm storage owned by each server client.
    result[index] = server.clients[index].spawnParms
    index = index + 1
  end while
  return result
end function

// Create and initialize quake ccontext.
function createQuakeCContext(server, filesystem, registry, commandSystem, runtime)
  return t.QuakeCContext(
    filesystem,
    server.worldModel,
    server.collisionHull,
    registry,
    commandSystem,
    runtime,
    server.modelPrecache,
    server.soundPrecache,
    server.lightStyles,
    server.datagram,
    server.reliableDatagram,
    server.signon,
    [],
    [],
    [],
    [],
    [],
    server.time,
    server.randomSeed,
    "",
    0,
    server,
    clientMessageBuffers(server),
    clientSpawnParmBuffers(server),
    0,
    0.0,
    bytes(),
  )
end function

// Provide qc float behavior for the active subsystem.
function qcFloat(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityFloat(machine, entityIndex, offset)
end function

// Provide qc word behavior for the active subsystem.
function qcWord(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityField(machine, entityIndex, offset)
end function

// Return qc vector derived from the active module state.
function qcVector(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityVector(machine, entityIndex, offset)
end function

// Provide qc string behavior for the active subsystem.
function qcString(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  value = vm.entityString(machine, entityIndex, offset)
  if value == "" then return fallback end if
  return value
end function

// Provide qc float at behavior for the active subsystem.
function qcFloatAt(machine, entityIndex, offset, fallback)
  if offset < 0 then return fallback end if
  return vm.entityFloat(machine, entityIndex, offset)
end function

// Provide qc word at behavior for the active subsystem.
function qcWordAt(machine, entityIndex, offset, fallback)
  if offset < 0 then return fallback end if
  return vm.entityField(machine, entityIndex, offset)
end function

// Provide qc string at behavior for the active subsystem.
function qcStringAt(machine, entityIndex, offset, fallback)
  if offset < 0 then return fallback end if
  value = vm.entityString(machine, entityIndex, offset)
  if value == "" then return fallback end if
  return value
end function

// The C engine resolves ddef_t offsets while loading progs.dat and then uses
// direct word offsets for every edict.  Resolve the MiniLang mirror's fixed
// synchronization set once per range instead of scanning fieldDefs 18 times
// for every live edict on every server frame.
function synchronizedEdictOffsets(machine)
  global synchronizedOffsetMachine, synchronizedOffsets
  if synchronizedOffsetMachine is not void and nativeRawValue(synchronizedOffsetMachine) == nativeRawValue(machine) then
    return synchronizedOffsets
  end if
  synchronizedOffsetMachine = machine
  synchronizedOffsets = [
    vm.fieldOffset(machine, "classname"),
    vm.fieldOffset(machine, "model"),
    vm.fieldOffset(machine, "modelindex"),
    vm.fieldOffset(machine, "frame"),
    vm.fieldOffset(machine, "skin"),
    vm.fieldOffset(machine, "colormap"),
    vm.fieldOffset(machine, "effects"),
    vm.fieldOffset(machine, "origin"),
    vm.fieldOffset(machine, "angles"),
    vm.fieldOffset(machine, "velocity"),
    vm.fieldOffset(machine, "mins"),
    vm.fieldOffset(machine, "maxs"),
    vm.fieldOffset(machine, "view_ofs"),
    vm.fieldOffset(machine, "movetype"),
    vm.fieldOffset(machine, "solid"),
    vm.fieldOffset(machine, "flags"),
    vm.fieldOffset(machine, "health"),
    vm.fieldOffset(machine, "groundentity"),
  ]
  return synchronizedOffsets
end function

synchronizedOffsetMachine = void
synchronizedOffsets = []

// Validate synchronized vector and report any invalid state.
function requireSynchronizedVector(value, entityIndex, fieldName)
  if t.isVec3Value(value) then return value end if
  return error(
    2860,
    "SV_SyncQuakeCEdict: edict " + entityIndex + " field " + fieldName +
      " expected Vec3, got " + typeName(value),
  )
end function

// The original server keeps edicts in one stable array and mutates their
// fields in place.  Rebuilding every QuakeEdict and every nested Vec3 on each
// frame creates avoidable allocation pressure and makes object lifetime depend
// on expression-temporary GC roots.  Keep the derived MiniLang mirror stable:
// allocate only when the high-water mark grows or a previously absent record
// appears, then copy raw QuakeC words into the existing structs.
function synchronizedVectorTarget(value, entityIndex, fieldName, x, y, z)
  if t.isVec3Value(value) then return value end if
  created = t.Vec3(x, y, z)
  return requireSynchronizedVector(created, entityIndex, fieldName)
end function

// Update module state for synchronized vector.
function setSynchronizedVector(value, entityIndex, fieldName, x, y, z)
  result = synchronizedVectorTarget(value, entityIndex, fieldName, x, y, z)
  result.x = x
  result.y = y
  result.z = z
  return result
end function

// Update module state for qc vector into.
function syncQcVectorInto(machine, entityIndex, fieldName, target, x, y, z)
  result = synchronizedVectorTarget(target, entityIndex, fieldName, x, y, z)
  offset = vm.fieldOffset(machine, fieldName)
  if offset >= 0 then
    result.x = vm.entityFloat(machine, entityIndex, offset)
    result.y = vm.entityFloat(machine, entityIndex, offset + 1)
    result.z = vm.entityFloat(machine, entityIndex, offset + 2)
  else
    result.x = x
    result.y = y
    result.z = z
  end if
  return requireSynchronizedVector(result, entityIndex, fieldName)
end function

// Update module state for qc vector into at.
function syncQcVectorIntoAt(machine, entityIndex, offset, fieldName, target, x, y, z)
  result = synchronizedVectorTarget(target, entityIndex, fieldName, x, y, z)
  if offset >= 0 then
    result.x = vm.entityFloat(machine, entityIndex, offset)
    result.y = vm.entityFloat(machine, entityIndex, offset + 1)
    result.z = vm.entityFloat(machine, entityIndex, offset + 2)
  else
    result.x = x
    result.y = y
    result.z = z
  end if
  return requireSynchronizedVector(result, entityIndex, fieldName)
end function

// Provide resize synchronized edict array behavior for the active subsystem.
function resizeSynchronizedEdictArray(server, requiredCount)
  if requiredCount < 0 or requiredCount > server.maxEdicts then
    return error(2861, "SV_SyncQuakeCEdicts: invalid edict count " + requiredCount)
  end if
  if len(server.edicts) == requiredCount then return server.edicts end if

  previous = server.edicts
  resized = arrayutil.makeEmptyArray(requiredCount)
  copyCount = len(previous)
  if copyCount > requiredCount then copyCount = requiredCount end if
  index = 0
  while index < copyCount
    resized[index] = previous[index]
    index = index + 1
  end while
  server.edicts = resized
  return resized
end function

// Ensure sufficient storage or state for synchronized baseline.
function ensureSynchronizedBaseline(item, entityIndex)
  baseline = item.baseline
  if not t.isEntityBaselineValue(baseline) then
    baseline = edict.emptyBaseline()
    item.baseline = baseline
  end if
  baselineOrigin = synchronizedVectorTarget(
    baseline.origin, entityIndex, "baseline.origin", 0.0, 0.0, 0.0
  )
  baselineAngles = synchronizedVectorTarget(
    baseline.angles, entityIndex, "baseline.angles", 0.0, 0.0, 0.0
  )
  baseline.origin = baselineOrigin
  baseline.angles = baselineAngles
  return baseline
end function

// Ensure sufficient storage or state for synchronized edict.
function ensureSynchronizedEdict(server, entityIndex)
  if entityIndex < 0 or entityIndex >= server.maxEdicts then
    return error(2862, "SV_SyncQuakeCEdict: invalid edict " + entityIndex)
  end if
  if entityIndex >= len(server.edicts) then
    resizeSynchronizedEdictArray(server, entityIndex + 1)
  end if

  item = server.edicts[entityIndex]
  if item is void then
    item = edict.create(entityIndex)
    server.edicts[entityIndex] = item
  else if not t.isQuakeEdictValue(item) then
    return error(
      2863,
      "SV_SyncQuakeCEdict: edict " + entityIndex +
        " expected QuakeEdict, got " + typeName(item),
    )
  end if
  item.number = entityIndex
  ensureSynchronizedBaseline(item, entityIndex)
  return item
end function

// Update module state for quake cedict at.
function syncQuakeCEdictAt(server, entityIndex, offsets)
  machine = server.machine
  runtime = machine.context.edicts
  item = ensureSynchronizedEdict(server, entityIndex)
  oldOriginX = item.origin.x
  oldOriginY = item.origin.y
  oldOriginZ = item.origin.z
  oldMinsX = item.mins.x
  oldMinsY = item.mins.y
  oldMinsZ = item.mins.z
  oldMaxsX = item.maxs.x
  oldMaxsY = item.maxs.y
  oldMaxsZ = item.maxs.z
  oldModelIndex = item.modelIndex
  item.free = runtime.freeFlags[entityIndex]
  if entityIndex < len(runtime.freeTimes) then item.freeTime = runtime.freeTimes[entityIndex] end if
  if item.free then return item end if

  item.className = qcStringAt(machine, entityIndex, offsets[0], "")
  item.modelHandle = qcWordAt(machine, entityIndex, offsets[1], 0)
  item.model = qcStringAt(machine, entityIndex, offsets[1], "")
  item.modelIndex = native.trunc(qcFloatAt(machine, entityIndex, offsets[2], 0.0))
  item.frame = native.trunc(qcFloatAt(machine, entityIndex, offsets[3], 0.0))
  item.skin = native.trunc(qcFloatAt(machine, entityIndex, offsets[4], 0.0))
  item.colormap = native.trunc(qcFloatAt(machine, entityIndex, offsets[5], 0.0))
  item.effects = native.trunc(qcFloatAt(machine, entityIndex, offsets[6], 0.0))

  // Copy the VM's raw vector words into the already-rooted nested structs.
  // After the first synchronization this hot path performs no Vec3 or Edict
  // allocation, matching the stable edict storage of WinQuake.
  origin = syncQcVectorIntoAt(
    machine, entityIndex, offsets[7], "origin", item.origin, 0.0, 0.0, 0.0
  )
  angles = syncQcVectorIntoAt(
    machine, entityIndex, offsets[8], "angles", item.angles, 0.0, 0.0, 0.0
  )
  velocity = syncQcVectorIntoAt(
    machine, entityIndex, offsets[9], "velocity", item.velocity, 0.0, 0.0, 0.0
  )
  mins = syncQcVectorIntoAt(
    machine, entityIndex, offsets[10], "mins", item.mins, 0.0, 0.0, 0.0
  )
  maxs = syncQcVectorIntoAt(
    machine, entityIndex, offsets[11], "maxs", item.maxs, 0.0, 0.0, 0.0
  )
  viewOffset = syncQcVectorIntoAt(
    machine, entityIndex, offsets[12], "view_ofs", item.viewOffset,
    0.0, 0.0, c.DEFAULT_VIEWHEIGHT
  )
  item.origin = origin
  item.angles = angles
  item.velocity = velocity
  item.mins = mins
  item.maxs = maxs
  item.viewOffset = viewOffset

  item.moveType = native.trunc(qcFloatAt(machine, entityIndex, offsets[13], c.MOVETYPE_NONE))
  item.solid = native.trunc(qcFloatAt(machine, entityIndex, offsets[14], c.SOLID_NOT))
  item.flags = native.trunc(qcFloatAt(machine, entityIndex, offsets[15], 0.0))
  item.health = qcFloatAt(machine, entityIndex, offsets[16], 0.0)
  item.onGround = (item.flags & c.FL_ONGROUND) != 0
  item.groundEntity = qcWordAt(machine, entityIndex, offsets[17], -1)
  if oldOriginX != item.origin.x or oldOriginY != item.origin.y or oldOriginZ != item.origin.z or
    oldMinsX != item.mins.x or oldMinsY != item.mins.y or oldMinsZ != item.mins.z or
    oldMaxsX != item.maxs.x or oldMaxsY != item.maxs.y or oldMaxsZ != item.maxs.z or
    oldModelIndex != item.modelIndex then
    item.leafNums = []
  end if
  return item
end function

// Synchronize only fields consumed by client snapshot encoding. Physics and
// collision already operate on the authoritative VM edicts; the full mirror
// remains available for lifecycle/save/compatibility boundaries.
function syncQuakeCSnapshotEdictAt(server, entityIndex, offsets)
  machine = server.machine
  runtime = machine.context.edicts
  item = ensureSynchronizedEdict(server, entityIndex)
  item.free = runtime.freeFlags[entityIndex]
  if entityIndex < len(runtime.freeTimes) then item.freeTime = runtime.freeTimes[entityIndex] end if
  if item.free then return item end if

  oldOriginX = item.origin.x
  oldOriginY = item.origin.y
  oldOriginZ = item.origin.z
  oldModelHandle = item.modelHandle
  oldModelIndex = item.modelIndex
  // SV_WriteEntitiesToClient rejects entities whose entvars_t::model string
  // handle is zero, independently of modelindex. Stock pickup QuakeC uses
  // exactly that distinction: it clears self.model immediately, retains the
  // precached modelindex, and may restore the string later for respawn. The
  // lightweight snapshot mirror must therefore copy model presence too.
  // Resolve text only when the item becomes visible or changes model; the
  // normal visible-entity frame remains allocation-free.
  modelHandle = qcWordAt(machine, entityIndex, offsets[1], 0)
  item.modelHandle = modelHandle
  item.modelIndex = native.trunc(qcFloatAt(machine, entityIndex, offsets[2], 0.0))
  if modelHandle == 0 then
    item.model = ""
  else if modelHandle == vm.TEMP_STRING_HANDLE or oldModelHandle != modelHandle or
    item.model == "" or oldModelIndex != item.modelIndex then
    item.model = vm.stringValue(machine, modelHandle)
  end if
  item.frame = native.trunc(qcFloatAt(machine, entityIndex, offsets[3], 0.0))
  item.skin = native.trunc(qcFloatAt(machine, entityIndex, offsets[4], 0.0))
  item.colormap = native.trunc(qcFloatAt(machine, entityIndex, offsets[5], 0.0))
  item.effects = native.trunc(qcFloatAt(machine, entityIndex, offsets[6], 0.0))
  item.origin = syncQcVectorIntoAt(machine, entityIndex, offsets[7], "origin", item.origin, 0.0, 0.0, 0.0)
  item.angles = syncQcVectorIntoAt(machine, entityIndex, offsets[8], "angles", item.angles, 0.0, 0.0, 0.0)
  item.moveType = native.trunc(qcFloatAt(machine, entityIndex, offsets[13], c.MOVETYPE_NONE))
  if oldOriginX != item.origin.x or oldOriginY != item.origin.y or oldOriginZ != item.origin.z or oldModelIndex != item.modelIndex then
    item.leafNums = []
  end if
  return item
end function

// Update module state for quake cedict.
function syncQuakeCEdict(server, entityIndex)
  return syncQuakeCEdictAt(server, entityIndex, synchronizedEdictOffsets(server.machine))
end function

// Return recompute edict count derived from the active module state.
function recomputeEdictCount(server)
  runtime = server.machine.context.edicts
  // ED_Alloc owns a monotonically non-decreasing num_edicts high-water mark.
  // ED_Free never shrinks it.  Re-scanning freeFlags each frame used to trim
  // trailing free slots and forced the derived array to be rebuilt, unlike the
  // original stable sv.edicts storage.
  count = runtime.numEdicts
  if count < server.maxClients + 1 then count = server.maxClients + 1 end if
  if count > runtime.maxEdicts then count = runtime.maxEdicts end if
  runtime.numEdicts = count
  server.numEdicts = count
  return count
end function

// Update module state for quake cedict range.
function syncQuakeCEdictRange(server, count)
  resizeSynchronizedEdictArray(server, count)
  server.numEdicts = count
  offsets = synchronizedEdictOffsets(server.machine)

  index = 0
  while index < count
    synchronized = syncQuakeCEdictAt(server, index, offsets)
    server.edicts[index] = synchronized
    index = index + 1
  end while

  // Client edicts are reserved before ED_LoadFromFile and initially have no
  // classname. Keep their physical defaults ready for PutClientInServer, but
  // mutate the already-rooted vectors instead of replacing them each frame.
  index = 1
  while index <= server.maxClients and index < count
    clientEdict = server.edicts[index]
    if clientEdict.className == "" then
      clientEdict.className = "player"
      playerMins = setSynchronizedVector(
        clientEdict.mins, index, "player.mins",
        c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z
      )
      playerMaxs = setSynchronizedVector(
        clientEdict.maxs, index, "player.maxs",
        c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z
      )
      clientEdict.mins = playerMins
      clientEdict.maxs = playerMaxs
      clientEdict.moveType = c.MOVETYPE_WALK
      clientEdict.solid = c.SOLID_SLIDEBOX
      clientEdict.flags = c.FL_CLIENT
      clientEdict.health = 100.0
      playerViewOffset = setSynchronizedVector(
        clientEdict.viewOffset, index, "player.view_ofs",
        0.0, 0.0, c.DEFAULT_VIEWHEIGHT
      )
      clientEdict.viewOffset = playerViewOffset
      server.edicts[index] = clientEdict
    end if
    index = index + 1
  end while
  return count
end function

// Update module state for quake cedicts.
function syncQuakeCEdicts(server)
  count = recomputeEdictCount(server)
  return syncQuakeCEdictRange(server, count)
end function

// Update the stable client-snapshot mirror without copying server-only fields.
function syncQuakeCSnapshotEdicts(server)
  count = recomputeEdictCount(server)
  resizeSynchronizedEdictArray(server, count)
  offsets = synchronizedEdictOffsets(server.machine)
  index = 0
  while index < count
    server.edicts[index] = syncQuakeCSnapshotEdictAt(server, index, offsets)
    index = index + 1
  end while
  return count
end function

// Update module state for loaded quake cedicts.
function syncLoadedQuakeCEdicts(server, savedCount)
  runtime = server.machine.context.edicts
  if savedCount < server.maxClients + 1 or savedCount > runtime.maxEdicts then
    return error(2864, "SV_SyncLoadedEdicts: invalid high-water mark " + savedCount)
  end if
  runtime.numEdicts = savedCount
  server.numEdicts = savedCount
  return syncQuakeCEdictRange(server, savedCount)
end function

// Allocate and initialize runtime.
function spawnRuntime(server, filesystem, mapName, skill, registry, commandSystem)
  // The C runtime owns one process-global rand() stream.  Preserve its latest
  // value across SV_SpawnServer even though the MiniLang QC context is rebuilt.
  if server.machine is not void and server.machine.context is not void then
    server.randomSeed = server.machine.context.randomSeed
  end if
  spawned = true
  spawned = try(spawn(server, filesystem, mapName, skill))
  if spawned is error then return spawned end if
  // spawn() prepares the BSP/progs shell, but Quake keeps sv.state at
  // ss_loading through ED_LoadFromFile, the two settle frames and baselines.
  server.loading = true
  // The QuakeC spawn builtins append static entities and ambient sounds to the
  // signon stream. Discard the provisional non-QC baseline before ED_LoadFromFile.
  sz.clear(server.signon)
  runtime = createEdictRuntime(server.maxEdicts, server.maxClients)
  server.machine.edictFree = runtime.freeFlags
  contextValue = createQuakeCContext(server, filesystem, registry, commandSystem, runtime)
  vm.setContext(server.machine, contextValue)
  qcbuiltins.install(server.machine, contextValue)
  qcedict.initializeGlobals(server.machine, server.mapName, skill, server.deathmatch, server.coop, server.serverFlags)
  result = try(qcedict.loadMapEntitiesFrom(server.machine, server.worldModel, skill, server.deathmatch, server.maxClients + 1))
  if result is error then return failSpawn(server, result) end if
  recomputeEdictCount(server)
  server.modelPrecache = contextValue.modelPrecache
  server.soundPrecache = contextValue.soundPrecache
  server.lightStyles = contextValue.lightStyles
  synced = true
  synced = try(syncQuakeCEdicts(server))
  if synced is error then return failSpawn(server, synced) end if
  assignModelIndexes(server)

  // WinQuake runs two 0.1 second physics frames before it creates baselines.
  // This lets dropped items and early thinks settle into their authoritative
  // initial positions.
  settle = 0
  while settle < 2
    runQuakeCFrame(server, 0.1)
    runNonClientPhysics(server, 0.1, registry)
    server.time = server.time + 0.1
    contextValue.serverTime = server.time
    vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
    flushQuakeCEvents(server)
    // Transient spawn-time sounds/particles are not part of the level signon.
    sz.clear(server.datagram)
    settle = settle + 1
  end while
  synced = try(syncQuakeCEdicts(server))
  if synced is error then return failSpawn(server, synced) end if
  assignModelIndexes(server)

  // ED_LoadFromFile is authoritative for spawn entities. Recompute the local
  // player start after QuakeC spawn functions and settling physics have had a
  // chance to inhibit, move or rewrite map entities.
  location = edict.spawnPoint(server.edicts, server.deathmatch)
  server.spawnPoint = location[0]
  server.spawnAngles = location[1]
  staticResult = appendQuakeCSignon(server, contextValue)
  appendBaselines(server)
  server.diagnostics = server.diagnostics + contextValue.consoleLines
  contextValue.consoleLines = []
  server.diagnostics = server.diagnostics + [
    "QuakeC spawned=" + result[0] + " inhibited=" + result[1],
    "QuakeC functions=" + len(server.progs.functions) + " edicts=" + server.numEdicts,
    "signon bytes=" + server.signon.curSize + " compatibility statics=" + staticResult[0] + "/" + staticResult[1],
  ]
  server.randomSeed = contextValue.randomSeed
  server.loading = false
  return server
end function

// Update module state for qc entity vector.
function setQcEntityVector(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityVector(server.machine, entityIndex, offset, value) end if
end function

// Update module state for qc entity float.
function setQcEntityFloat(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityFloat(server.machine, entityIndex, offset, value) end if
end function

// Update module state for qc entity word.
function setQcEntityWord(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityField(server.machine, entityIndex, offset, value) end if
end function

// Update module state for player to quake c.
function syncPlayerToQuakeC(server, clientValue, player)
  if server.machine is void then return false end if
  entityIndex = clientValue.edictIndex
  setQcEntityVector(server, entityIndex, "origin", player.origin)
  setQcEntityVector(server, entityIndex, "oldorigin", player.oldOrigin)
  setQcEntityVector(server, entityIndex, "velocity", player.velocity)
  setQcEntityVector(server, entityIndex, "angles", player.renderAngles)
  setQcEntityVector(server, entityIndex, "v_angle", player.viewAngles)
  setQcEntityVector(server, entityIndex, "punchangle", player.punchAngle)
  setQcEntityVector(server, entityIndex, "movedir", player.moveDir)
  setQcEntityVector(server, entityIndex, "mins", player.mins)
  setQcEntityVector(server, entityIndex, "maxs", player.maxs)
  viewOffset = t.Vec3(0.0, 0.0, player.viewHeight)
  setQcEntityVector(server, entityIndex, "view_ofs", viewOffset)
  setQcEntityFloat(server, entityIndex, "health", player.health)
  setQcEntityFloat(server, entityIndex, "movetype", player.moveType)
  setQcEntityFloat(server, entityIndex, "solid", c.SOLID_SLIDEBOX)
  flags = player.flags | c.FL_CLIENT
  if player.onGround then flags = flags | c.FL_ONGROUND else flags = flags & ~c.FL_ONGROUND end if
  player.flags = flags
  setQcEntityFloat(server, entityIndex, "flags", flags)
  setQcEntityWord(server, entityIndex, "groundentity", player.groundEntity)
  setQcEntityFloat(server, entityIndex, "waterlevel", player.waterLevel)
  setQcEntityFloat(server, entityIndex, "watertype", player.waterType)
  if player.fixAngle then setQcEntityFloat(server, entityIndex, "fixangle", 1.0) else setQcEntityFloat(server, entityIndex, "fixangle", 0.0) end if
  setQcEntityFloat(server, entityIndex, "teleport_time", player.teleportTime)
  setQcEntityFloat(server, entityIndex, "deadflag", player.deadFlag)
  return true
end function

// Update module state for command to quake c.
function syncCommandToQuakeC(server, clientValue)
  if server.machine is void then return false end if
  entityIndex = clientValue.edictIndex
  setQcEntityVector(server, entityIndex, "v_angle", clientValue.command.viewAngles)
  button0 = 0.0
  button2 = 0.0
  if (clientValue.command.buttons & c.BUTTON_ATTACK) != 0 then button0 = 1.0 end if
  if (clientValue.command.buttons & c.BUTTON_JUMP) != 0 then button2 = 1.0 end if
  setQcEntityFloat(server, entityIndex, "button0", button0)
  setQcEntityFloat(server, entityIndex, "button2", button2)
  if clientValue.command.impulse != 0 then
    setQcEntityFloat(server, entityIndex, "impulse", clientValue.command.impulse)
    clientValue.command.impulse = 0
  end if
  return true
end function

// Warm the pure field/function lookup paths used by the first client physics
// frame. No QuakeC code is executed and no game time advances; authoritative
// player values are written and read back unchanged.
function precacheClientFrameLookups(server, fallbackPlayer)
  if server.machine is void or server.machine.context is void then return 0 end if
  warmed = 0
  for each clientValue in server.clients
    if clientValue.active and clientValue.spawned then
      player = playerStateForClient(server, clientValue, fallbackPlayer)
      syncPlayerToQuakeC(server, clientValue, player)
      syncCommandToQuakeC(server, clientValue)
      syncPlayerFromQuakeC(server, clientValue, player)
      warmed = warmed + 1
    end if
  end for
  vm.functionIndex(server.machine, "PlayerPreThink")
  vm.functionIndex(server.machine, "PlayerPostThink")
  return warmed
end function

// Update module state for player from quake c.
function syncPlayerFromQuakeC(server, clientValue, player)
  if server.machine is void then return false end if
  entityIndex = clientValue.edictIndex
  machine = server.machine

  // PlayerState mirrors the same stable C edict words.  Mutate its existing
  // Vec3 fields in place so repeated PlayerPreThink/PostThink synchronization
  // cannot create transient nested objects that depend on expression roots.
  origin = syncQcVectorInto(
    machine, entityIndex, "origin", player.origin, 0.0, 0.0, 0.0
  )
  oldOrigin = syncQcVectorInto(
    machine, entityIndex, "oldorigin", player.oldOrigin, 0.0, 0.0, 0.0
  )
  velocity = syncQcVectorInto(
    machine, entityIndex, "velocity", player.velocity, 0.0, 0.0, 0.0
  )
  viewAngles = syncQcVectorInto(
    machine, entityIndex, "v_angle", player.viewAngles, 0.0, 0.0, 0.0
  )
  renderAngles = syncQcVectorInto(
    machine, entityIndex, "angles", player.renderAngles, 0.0, 0.0, 0.0
  )
  punchAngle = syncQcVectorInto(
    machine, entityIndex, "punchangle", player.punchAngle, 0.0, 0.0, 0.0
  )
  moveDir = syncQcVectorInto(
    machine, entityIndex, "movedir", player.moveDir, 0.0, 0.0, 0.0
  )
  mins = syncQcVectorInto(
    machine, entityIndex, "mins", player.mins,
    c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z
  )
  maxs = syncQcVectorInto(
    machine, entityIndex, "maxs", player.maxs,
    c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z
  )

  player.origin = origin
  player.oldOrigin = oldOrigin
  player.velocity = velocity
  player.viewAngles = viewAngles
  player.renderAngles = renderAngles
  player.punchAngle = punchAngle
  player.moveDir = moveDir
  player.mins = mins
  player.maxs = maxs

  viewOffset = vm.fieldOffset(machine, "view_ofs")
  if viewOffset >= 0 then
    player.viewHeight = vm.entityFloat(machine, entityIndex, viewOffset + 2)
  end if
  player.health = qcFloat(machine, entityIndex, "health", player.health)
  player.armor = qcFloat(machine, entityIndex, "armorvalue", player.armor)
  player.ammo = native.trunc(qcFloat(machine, entityIndex, "currentammo", player.ammo))
  player.shells = native.trunc(qcFloat(machine, entityIndex, "ammo_shells", player.shells))
  player.nails = native.trunc(qcFloat(machine, entityIndex, "ammo_nails", player.nails))
  player.rockets = native.trunc(qcFloat(machine, entityIndex, "ammo_rockets", player.rockets))
  player.cells = native.trunc(qcFloat(machine, entityIndex, "ammo_cells", player.cells))
  player.items = native.trunc(qcFloat(machine, entityIndex, "items", player.items))
  player.activeWeapon = native.trunc(qcFloat(machine, entityIndex, "weapon", player.activeWeapon))
  player.weaponFrame = native.trunc(qcFloat(machine, entityIndex, "weaponframe", player.weaponFrame))
  weaponModel = qcString(machine, entityIndex, "weaponmodel", "")
  if weaponModel == "" then player.weapon = 0 else player.weapon = modelIndex(server, weaponModel) end if
  player.moveType = native.trunc(qcFloat(machine, entityIndex, "movetype", player.moveType))
  player.flags = native.trunc(qcFloat(machine, entityIndex, "flags", player.flags))
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  player.groundEntity = qcWord(machine, entityIndex, "groundentity", player.groundEntity)
  player.waterLevel = native.trunc(qcFloat(machine, entityIndex, "waterlevel", player.waterLevel))
  player.waterType = native.trunc(qcFloat(machine, entityIndex, "watertype", player.waterType))
  player.fixAngle = qcFloat(machine, entityIndex, "fixangle", 0.0) != 0.0
  player.teleportTime = qcFloat(machine, entityIndex, "teleport_time", player.teleportTime)
  player.deadFlag = native.trunc(qcFloat(machine, entityIndex, "deadflag", player.deadFlag))
  player.noclip = player.moveType == c.MOVETYPE_NOCLIP
  return true
end function

// Execute qc function.
function executeQcFunction(server, functionName, selfIndex, otherIndex)
  if server.machine is void then return false end if
  functionIndex = vm.functionIndex(server.machine, functionName)
  if functionIndex == 0 then return false end if
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, selfIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
  vm.execute(server.machine, functionIndex)
  return true
end function

// Execute quake cframe.
function runQuakeCFrame(server, frameTime)
  if server.machine is void or server.machine.context is void then return 0 end if
  machine = server.machine
  contextValue = machine.context
  contextValue.serverTime = server.time
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_FRAMETIME, frameTime)
  executed = 0
  startFrame = vm.functionIndex(machine, "StartFrame")
  if startFrame != 0 then
    vm.setWord(machine, c.QC_GLOBAL_SELF, 0)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, 0)
    vm.execute(machine, startFrame)
    executed = executed + 1
  end if
  // Entity thinks are part of each entity's physics class. Pushers use ltime
  // and an exact split frame; running all thinks here used to make doors fire
  // early and then move with stale velocity.
  server.modelPrecache = contextValue.modelPrecache
  server.soundPrecache = contextValue.soundPrecache
  server.lightStyles = contextValue.lightStyles
  return executed
end function
