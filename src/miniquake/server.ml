package miniquake.server

import miniquake.types as t
import miniquake.constants as c
import miniquake.filesystem as qfs
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as qcedict
import miniquake.quakec.builtins as qcbuiltins
import miniquake.edict as edict
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.net_loop as netloop
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

function zeroSpawnParms()
  return arrayutil.makeFilledArray(16, 0.0)
end function

function createServerClient(index)
  return t.ServerClient(
    false,
    false,
    false,
    0,
    "unconnected",
    0,
    index + 1,
    void,
    sz.alloc(c.MAX_MSGLEN),
    zeroSpawnParms(),
    input.createCommand(),
  )
end function

function defaultLightStyles()
  return arrayutil.makeFilledArray(64, "m")
end function

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
    sz.allocOverflowing(c.MAX_DATAGRAM),
    sz.allocOverflowing(c.MAX_MSGLEN),
    sz.alloc(c.MAX_MSGLEN),
    void,
    t.Vec3(0.0, 0.0, 64.0),
    t.Vec3(0.0, 0.0, 0.0),
    1,
    false,
    false,
    0,
    [],
  )
end function

function hasBspSuffix(name)
  source = bytes(name)
  if len(source) < 4 then return false end if
  suffix = decode(slice(source, len(source) - 4, 4))
  return suffix == ".bsp" or suffix == ".BSP"
end function

function cleanMapName(name)
  result = name
  if hasBspSuffix(result) then result = decode(slice(bytes(result), 0, len(bytes(result)) - 4)) end if
  if len(bytes(result)) >= 5 and decode(slice(bytes(result), 0, 5)) == "maps/" then result = decode(slice(bytes(result), 5, len(bytes(result)) - 5)) end if
  return result
end function

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

function modelIndex(server, name)
  index = 0
  while index < len(server.modelPrecache)
    if server.modelPrecache[index] == name then return index end if
    index = index + 1
  end while
  return 0
end function

function assignModelIndexes(server)
  for each item in server.edicts
    if item.model != "" then item.modelIndex = modelIndex(server, item.model) end if
  end for
end function

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

function writeBaseline(buffer, item)
  base = edict.baseline(item)
  msg.writeByte(buffer, base.modelIndex)
  msg.writeByte(buffer, base.frame)
  msg.writeByte(buffer, base.colormap)
  msg.writeByte(buffer, base.skin)
  msg.writeCoord(buffer, base.origin.x); msg.writeAngle(buffer, base.angles.x)
  msg.writeCoord(buffer, base.origin.y); msg.writeAngle(buffer, base.angles.y)
  msg.writeCoord(buffer, base.origin.z); msg.writeAngle(buffer, base.angles.z)
end function

function appendBaselines(server)
  for each item in server.edicts
    if not item.free and item.number > server.maxClients and item.modelIndex != 0 then
      msg.writeByte(server.signon, c.SVC_SPAWNBASELINE)
      msg.writeShort(server.signon, item.number)
      writeBaseline(server.signon, item)
    end if
  end for
  return server.signon.curSize
end function

function buildSignon(server)
  sz.clear(server.signon)
  return appendBaselines(server)
end function

function soundIndex(server, name)
  index = 1
  while index < len(server.soundPrecache)
    if server.soundPrecache[index] == name then return index end if
    index = index + 1
  end while
  return 0
end function

function writeBaselineValues(buffer, baseline)
  msg.writeByte(buffer, baseline[0])
  msg.writeByte(buffer, baseline[1])
  msg.writeByte(buffer, baseline[2])
  msg.writeByte(buffer, baseline[3])
  origin = baseline[4]
  angles = baseline[5]
  msg.writeCoord(buffer, origin.x); msg.writeAngle(buffer, angles.x)
  msg.writeCoord(buffer, origin.y); msg.writeAngle(buffer, angles.y)
  msg.writeCoord(buffer, origin.z); msg.writeAngle(buffer, angles.z)
  return true
end function

function appendQuakeCSignon(server, contextValue)
  staticCount = 0
  for each baseline in contextValue.staticEntities
    msg.writeByte(server.signon, c.SVC_SPAWNSTATIC)
    writeBaselineValues(server.signon, baseline)
    staticCount = staticCount + 1
  end for
  ambientCount = 0
  for each ambient in contextValue.staticSounds
    index = soundIndex(server, ambient[1])
    if index > 0 then
      msg.writeByte(server.signon, c.SVC_SPAWNSTATICSOUND)
      msg.writeCoord(server.signon, ambient[0].x)
      msg.writeCoord(server.signon, ambient[0].y)
      msg.writeCoord(server.signon, ambient[0].z)
      msg.writeByte(server.signon, index)
      volume = native.trunc(math.clamp(ambient[2], 0.0, 1.0) * 255.0)
      attenuation = native.trunc(math.clamp(ambient[3], 0.0, 4.0) * 64.0)
      msg.writeByte(server.signon, volume)
      msg.writeByte(server.signon, attenuation)
      ambientCount = ambientCount + 1
    else
      server.diagnostics = server.diagnostics + ["ambient sound was not precached: " + ambient[1]]
    end if
  end for
  return [staticCount, ambientCount]
end function

function spawn(server, filesystem, mapName, skill)
  name = cleanMapName(mapName)
  if name == "" then return error(2800, "SV_SpawnServer: empty map name") end if
  server.loading = true
  server.active = false
  server.time = 1.0
  server.mapName = name
  server.modelName = "maps/" + name + ".bsp"
  server.skill = skill
  server.diagnostics = []
  sz.clear(server.datagram)
  sz.clear(server.reliableDatagram)
  sz.clear(server.signon)

  mapData = qfs.readFile(filesystem, server.modelName)
  server.worldModel = bsp.parse(mapData, server.modelName)
  progsData = qfs.readFile(filesystem, "progs.dat")
  server.progs = progs.parse(progsData, "progs.dat")
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
    sz.clear(client.message)
  end for
  server.loading = false
  server.active = true
  server.diagnostics = server.diagnostics + ["spawned " + name + ": " + server.numEdicts + " edicts"]
  return server
end function

function sendBuffer(client, buffer)
  if client.socket is void then return -1 end if
  if not netloop.canSendMessage(client.socket) then return 0 end if
  return netloop.sendMessage(client.socket, buffer)
end function

function sendServerInfo(server, client)
  buffer = sz.alloc(c.MAX_MSGLEN)
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, "\nMiniQuake " + c.QUAKE_VERSION + " SERVER (protocol " + c.PROTOCOL_VERSION + ")\n")
  msg.writeByte(buffer, c.SVC_SERVERINFO)
  msg.writeLong(buffer, c.PROTOCOL_VERSION)
  msg.writeByte(buffer, server.maxClients)
  if server.deathmatch then msg.writeByte(buffer, c.GAME_DEATHMATCH) else msg.writeByte(buffer, c.GAME_COOP) end if
  msg.writeString(buffer, server.levelName)
  index = 1
  while index < len(server.modelPrecache)
    msg.writeString(buffer, server.modelPrecache[index])
    index = index + 1
  end while
  msg.writeByte(buffer, 0)
  index = 1
  while index < len(server.soundPrecache)
    msg.writeString(buffer, server.soundPrecache[index])
    index = index + 1
  end while
  msg.writeByte(buffer, 0)
  msg.writeByte(buffer, c.SVC_CDTRACK)
  msg.writeByte(buffer, 0)
  msg.writeByte(buffer, 0)
  msg.writeByte(buffer, c.SVC_SETVIEW)
  msg.writeShort(buffer, client.edictIndex)
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_SERVERINFO)
  client.signonStage = c.SIGNON_SERVERINFO
  return sendBuffer(client, buffer)
end function

function globalSpawnParmOffset(machine, index)
  return vm.globalOffset(machine, "parm" + (index + 1))
end function

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
  selected.command = input.createCommand()
  sz.clear(selected.message)
  if server.machine is not void and server.machine.context is not void then
    executeQcFunction(server, "SetNewParms", selected.edictIndex, 0)
    copyGlobalsToSpawnParms(server, selected)
  end if
  sendServerInfo(server, selected)
  return selected
end function

function writeSignonStage2(server, client)
  buffer = sz.alloc(c.MAX_MSGLEN)
  if server.signon.curSize > 0 then sz.write(buffer, server.signon.data, 0, server.signon.curSize) end if
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_PRESPAWN)
  client.signonStage = c.SIGNON_PRESPAWN
  return sendBuffer(client, buffer)
end function

function placeClient(server, client, player)
  player.origin = math.copy(server.spawnPoint)
  player.viewAngles = math.copy(server.spawnAngles)
  player.renderAngles = math.copy(server.spawnAngles)
  player.velocity = t.Vec3(0.0, 0.0, 0.0)
  player.health = 100.0
  player.onGround = false
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

function writeSpawn(server, client, player)
  placeClient(server, client, player)
  if server.machine is not void and server.machine.context is not void then
    copySpawnParmsToGlobals(server, client)
    syncPlayerToQuakeC(server, client, player)
    executeQcFunction(server, "ClientConnect", client.edictIndex, 0)
    executeQcFunction(server, "PutClientInServer", client.edictIndex, 0)
    syncPlayerFromQuakeC(server, client, player)
    syncQuakeCEdicts(server)
  end if
  buffer = sz.alloc(c.MAX_MSGLEN)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, server.time)
  index = 0
  while index < server.maxClients
    other = server.clients[index]
    msg.writeByte(buffer, c.SVC_UPDATENAME)
    msg.writeByte(buffer, index)
    if other.active then msg.writeString(buffer, other.name) else msg.writeString(buffer, "") end if
    msg.writeByte(buffer, c.SVC_UPDATEFRAGS)
    msg.writeByte(buffer, index)
    msg.writeShort(buffer, 0)
    msg.writeByte(buffer, c.SVC_UPDATECOLORS)
    msg.writeByte(buffer, index)
    msg.writeByte(buffer, other.colors)
    index = index + 1
  end while
  index = 0
  while index < len(server.lightStyles)
    msg.writeByte(buffer, c.SVC_LIGHTSTYLE)
    msg.writeByte(buffer, index)
    msg.writeString(buffer, server.lightStyles[index])
    index = index + 1
  end while
  msg.writeByte(buffer, c.SVC_SETVIEW)
  msg.writeShort(buffer, client.edictIndex)
  msg.writeByte(buffer, c.SVC_SETANGLE)
  msg.writeAngle(buffer, player.viewAngles.x)
  msg.writeAngle(buffer, player.viewAngles.y)
  msg.writeAngle(buffer, 0.0)
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_SPAWN)
  client.signonStage = c.SIGNON_SPAWN
  return sendBuffer(client, buffer)
end function

function writeBegin(client)
  buffer = sz.alloc(32)
  msg.writeByte(buffer, c.SVC_SIGNONNUM)
  msg.writeByte(buffer, c.SIGNON_ACTIVE)
  client.spawned = true
  client.signonStage = c.SIGNON_ACTIVE
  return sendBuffer(client, buffer)
end function

function executeStringCommand(server, client, text, player)
  args = cmd.tokenize(text)
  if len(args) == 0 then return false end if
  name = args[0]
  if name == "prespawn" then return writeSignonStage2(server, client) end if
  if name == "name" and len(args) >= 2 then client.name = args[1]; return true end if
  if name == "color" and len(args) >= 2 then
    top = toNumber(args[1])
    bottom = top
    if len(args) >= 3 then bottom = toNumber(args[2]) end if
    if top is void then top = 0 end if
    if bottom is void then bottom = 0 end if
    client.colors = ((native.trunc(top) & 15) << 4) | (native.trunc(bottom) & 15)
    return true
  end if
  if name == "spawn" then return writeSpawn(server, client, player) end if
  if name == "begin" then return writeBegin(client) end if
  if name == "disconnect" then client.active = false; client.spawned = false; return true end if
  return false
end function

function readMove(reader, client)
  clientTime = msg.readFloat(reader)
  client.command.viewAngles = t.Vec3(msg.readAngle(reader), msg.readAngle(reader), msg.readAngle(reader))
  client.command.forwardMove = msg.readShort(reader)
  client.command.sideMove = msg.readShort(reader)
  client.command.upMove = msg.readShort(reader)
  client.command.buttons = msg.readByte(reader)
  client.command.impulse = msg.readByte(reader)
  client.command.msec = 0
  return clientTime
end function

function readClientMessage(server, client, data, player)
  reader = msg.beginReadingBytes(data)
  while msg.remaining(reader) > 0
    command = msg.readByte(reader)
    if command == c.CLC_NOP then
      continue
    else if command == c.CLC_DISCONNECT then
      client.active = false
      client.spawned = false
      return false
    else if command == c.CLC_MOVE then
      readMove(reader, client)
    else if command == c.CLC_STRINGCMD then
      executeStringCommand(server, client, msg.readString(reader), player)
    else
      return error(2802, "SV_ReadClientMessage: unknown command " + command)
    end if
  end while
  return true
end function

function pumpClientMessages(server, player)
  destination = sz.alloc(c.MAX_MSGLEN)
  processed = 0
  for each client in server.clients
    if client.active and client.socket is not void then
      messageType = netloop.getMessage(client.socket, destination)
      while messageType > 0
        readClientMessage(server, client, sz.dataSlice(destination), player)
        processed = processed + 1
        messageType = netloop.getMessage(client.socket, destination)
      end while
    end if
  end for
  return processed
end function

function clampByte(value)
  result = native.trunc(value)
  if result < 0 then result = 0 end if
  if result > 255 then result = 255 end if
  return result
end function

function writeClientDataWithFlags(buffer, player, serverFlags)
  // SV_WriteClientdataToMessage.  SU_ITEMS is carried for protocol parity even
  // though the 32-bit item word is always present, and SU_WEAPON is always set
  // in stock Quake so the first-person model cannot disappear on zero/default
  // transitions.
  bits = c.SU_ITEMS | c.SU_WEAPON
  if player.viewHeight != c.DEFAULT_VIEWHEIGHT then bits = bits | c.SU_VIEWHEIGHT end if
  if player.onGround then bits = bits | c.SU_ONGROUND end if
  if player.waterLevel >= 2 then bits = bits | c.SU_INWATER end if

  punchValues = [player.punchAngle.x, player.punchAngle.y, player.punchAngle.z]
  velocityValues = [player.velocity.x, player.velocity.y, player.velocity.z]
  axis = 0
  while axis < 3
    if punchValues[axis] != 0.0 then bits = bits | (c.SU_PUNCH1 << axis) end if
    if velocityValues[axis] != 0.0 then bits = bits | (c.SU_VELOCITY1 << axis) end if
    axis = axis + 1
  end while

  if player.weaponFrame != 0 then bits = bits | c.SU_WEAPONFRAME end if
  if player.armor != 0.0 then bits = bits | c.SU_ARMOR end if

  msg.writeByte(buffer, c.SVC_CLIENTDATA)
  msg.writeShort(buffer, bits)
  if (bits & c.SU_VIEWHEIGHT) != 0 then msg.writeChar(buffer, native.trunc(player.viewHeight)) end if

  axis = 0
  while axis < 3
    if (bits & (c.SU_PUNCH1 << axis)) != 0 then msg.writeChar(buffer, native.trunc(punchValues[axis])) end if
    if (bits & (c.SU_VELOCITY1 << axis)) != 0 then msg.writeChar(buffer, native.trunc(velocityValues[axis] / 16.0)) end if
    axis = axis + 1
  end while

  items = native.trunc(player.items) | ((native.trunc(serverFlags) & 15) << 28)
  msg.writeLong(buffer, items)
  if (bits & c.SU_WEAPONFRAME) != 0 then msg.writeByte(buffer, clampByte(player.weaponFrame)) end if
  if (bits & c.SU_ARMOR) != 0 then msg.writeByte(buffer, clampByte(player.armor)) end if
  msg.writeByte(buffer, clampByte(player.weapon))
  msg.writeShort(buffer, native.trunc(player.health))
  msg.writeByte(buffer, clampByte(player.ammo))
  msg.writeByte(buffer, clampByte(player.shells))
  msg.writeByte(buffer, clampByte(player.nails))
  msg.writeByte(buffer, clampByte(player.rockets))
  msg.writeByte(buffer, clampByte(player.cells))
  msg.writeByte(buffer, clampByte(player.activeWeapon))
  return bits
end function

function writeClientData(buffer, player)
  return writeClientDataWithFlags(buffer, player, 0)
end function

function writePlayerUpdate(buffer, client, player)
  bits = c.U_MOREBITS | c.U_ORIGIN1 | c.U_ORIGIN2 | c.U_ORIGIN3 | c.U_ANGLE1 | c.U_ANGLE2 | c.U_ANGLE3
  msg.writeByte(buffer, (bits & 255) | c.U_SIGNAL)
  msg.writeByte(buffer, (bits >> 8) & 255)
  msg.writeByte(buffer, client.edictIndex)
  msg.writeCoord(buffer, player.origin.x); msg.writeAngle(buffer, player.renderAngles.x)
  msg.writeCoord(buffer, player.origin.y); msg.writeAngle(buffer, player.renderAngles.y)
  msg.writeCoord(buffer, player.origin.z); msg.writeAngle(buffer, player.renderAngles.z)
end function

function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

function entityFloatValue(server, item, fieldName, fallback)
  if server.machine is not void and server.machine.context is not void then
    return qcFloat(server.machine, item.number, fieldName, fallback)
  end if
  return fallback
end function

function writeEntityUpdate(server, buffer, item)
  base = item.baseline
  modelValue = item.modelIndex
  frameValue = native.trunc(entityFloatValue(server, item, "frame", item.frame))
  colormapValue = native.trunc(entityFloatValue(server, item, "colormap", item.colormap))
  skinValue = native.trunc(entityFloatValue(server, item, "skin", item.skin))
  effectsValue = native.trunc(entityFloatValue(server, item, "effects", item.effects))
  bits = 0
  if absolute(item.origin.x - base.origin.x) > 0.1 then bits = bits | c.U_ORIGIN1 end if
  if absolute(item.origin.y - base.origin.y) > 0.1 then bits = bits | c.U_ORIGIN2 end if
  if absolute(item.origin.z - base.origin.z) > 0.1 then bits = bits | c.U_ORIGIN3 end if
  if item.angles.x != base.angles.x then bits = bits | c.U_ANGLE1 end if
  if item.angles.y != base.angles.y then bits = bits | c.U_ANGLE2 end if
  if item.angles.z != base.angles.z then bits = bits | c.U_ANGLE3 end if
  if item.moveType == c.MOVETYPE_STEP then bits = bits | c.U_NOLERP end if
  if modelValue != base.modelIndex then bits = bits | c.U_MODEL end if
  if frameValue != base.frame then bits = bits | c.U_FRAME end if
  if colormapValue != base.colormap then bits = bits | c.U_COLORMAP end if
  if skinValue != base.skin then bits = bits | c.U_SKIN end if
  if effectsValue != 0 then bits = bits | c.U_EFFECTS end if
  if item.number >= 256 then bits = bits | c.U_LONGENTITY end if
  if bits >= 256 then bits = bits | c.U_MOREBITS end if

  msg.writeByte(buffer, (bits & 255) | c.U_SIGNAL)
  if (bits & c.U_MOREBITS) != 0 then msg.writeByte(buffer, (bits >> 8) & 255) end if
  if (bits & c.U_LONGENTITY) != 0 then msg.writeShort(buffer, item.number) else msg.writeByte(buffer, item.number) end if
  if (bits & c.U_MODEL) != 0 then msg.writeByte(buffer, modelValue) end if
  if (bits & c.U_FRAME) != 0 then msg.writeByte(buffer, frameValue) end if
  if (bits & c.U_COLORMAP) != 0 then msg.writeByte(buffer, colormapValue) end if
  if (bits & c.U_SKIN) != 0 then msg.writeByte(buffer, skinValue) end if
  if (bits & c.U_EFFECTS) != 0 then msg.writeByte(buffer, effectsValue) end if
  if (bits & c.U_ORIGIN1) != 0 then msg.writeCoord(buffer, item.origin.x) end if
  if (bits & c.U_ANGLE1) != 0 then msg.writeAngle(buffer, item.angles.x) end if
  if (bits & c.U_ORIGIN2) != 0 then msg.writeCoord(buffer, item.origin.y) end if
  if (bits & c.U_ANGLE2) != 0 then msg.writeAngle(buffer, item.angles.y) end if
  if (bits & c.U_ORIGIN3) != 0 then msg.writeCoord(buffer, item.origin.z) end if
  if (bits & c.U_ANGLE3) != 0 then msg.writeAngle(buffer, item.angles.z) end if
  return bits
end function

function entityVisible(server, pvs, item, clientEdict)
  if item.number == clientEdict then return true end if
  if item.modelIndex == 0 or item.model == "" then return false end if
  leafIndex = world.leafForPoint(server.worldModel, item.origin)
  return world.leafVisible(pvs, leafIndex)
end function

function appendDatagram(destination, source)
  if source.curSize <= 0 then return true end if
  if destination.curSize + source.curSize > destination.maxSize then return false end if
  sz.write(destination, source.data, 0, source.curSize)
  return true
end function

function sendClientFrame(server, client, player)
  if not client.active or not client.spawned or client.socket is void then return 0 end if
  buffer = sz.alloc(c.MAX_DATAGRAM)
  buffer.allowOverflow = true
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, server.time)
  writeClientDataWithFlags(buffer, player, server.serverFlags)
  writePlayerUpdate(buffer, client, player)

  eye = math.add(player.origin, t.Vec3(0.0, 0.0, player.viewHeight))
  viewLeaf = world.leafForPoint(server.worldModel, eye)
  pvs = world.leafPvs(server.worldModel, viewLeaf)
  index = 1
  while index < len(server.edicts)
    item = server.edicts[index]
    if item is not void and not item.free and item.number != client.edictIndex and entityVisible(server, pvs, item, client.edictIndex) then
      // Original Quake leaves a 16-byte safety margin. MiniQuake uses a larger
      // bound because long entity numbers and all coordinate deltas can take 24.
      if buffer.maxSize - buffer.curSize < 32 then break end if
      writeEntityUpdate(server, buffer, item)
    end if
    index = index + 1
  end while
  appendDatagram(buffer, server.datagram)
  return netloop.sendUnreliableMessage(client.socket, buffer)
end function

function qcEntityVector(server, entityIndex, name)
  return qcVector(server.machine, entityIndex, name, t.Vec3(0.0, 0.0, 0.0))
end function

function qcSetFlags(server, entityIndex, flags)
  setQcEntityFloat(server, entityIndex, "flags", flags)
end function

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

function boundsOverlap(originA, minsA, maxsA, originB, minsB, maxsB)
  if originA.x + maxsA.x < originB.x + minsB.x then return false end if
  if originA.x + minsA.x > originB.x + maxsB.x then return false end if
  if originA.y + maxsA.y < originB.y + minsB.y then return false end if
  if originA.y + minsA.y > originB.y + maxsB.y then return false end if
  if originA.z + maxsA.z < originB.z + minsB.z then return false end if
  if originA.z + minsA.z > originB.z + maxsB.z then return false end if
  return true
end function

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

function runEntityThink(server, entityIndex, frameTime)
  machine = server.machine
  nextThink = qcFloat(machine, entityIndex, "nextthink", 0.0)
  if nextThink <= 0.0 or nextThink > server.time + frameTime then return true end if
  thinkFunction = qcWord(machine, entityIndex, "think", 0)
  if thinkFunction == 0 then return true end if
  if nextThink < server.time then nextThink = server.time end if
  setQcEntityFloat(server, entityIndex, "nextthink", 0.0)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, nextThink)
  vm.setWord(machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, 0)
  vm.execute(machine, thinkFunction)
  return not machine.context.edicts.freeFlags[entityIndex]
end function

function executePusherThink(server, pusherIndex)
  thinkFunction = qcWord(server.machine, pusherIndex, "think", 0)
  if thinkFunction == 0 then return true end if
  setQcEntityFloat(server, pusherIndex, "nextthink", 0.0)
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
  movedFlags = arrayutil.createArrayBuilder(16)
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
          arrayutil.pushArrayBuilder(movedFlags, flags)
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
    flagsValues = arrayutil.finishArrayBuilder(movedFlags)
    rollback = 0
    while rollback < len(indexes)
      setQcEntityVector(server, indexes[rollback], "origin", origins[rollback])
      setQcEntityFloat(server, indexes[rollback], "flags", flagsValues[rollback])
      rollback = rollback + 1
    end while
    runQcBlocked(server, pusherIndex, blockedBy)
    return false
  end if
  return true
end function

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

function moveQcEntity(server, entityIndex, frameTime, gravity)
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

function runNonClientPhysics(server, frameTime, registry)
  if server.machine is void or server.machine.context is void then return 0 end if
  gravity = cvar.variableValue(registry, "sv_gravity")
  if gravity <= 0.0 then gravity = 800.0 end if
  moved = 0
  index = server.maxClients + 1
  while index < server.machine.context.edicts.numEdicts
    if not server.machine.context.edicts.freeFlags[index] then
      if moveQcEntity(server, index, frameTime, gravity) then moved = moved + 1 end if
    end if
    index = index + 1
  end while
  return moved
end function

function clampDirection(value)
  result = native.trunc(value * 16.0)
  if result > 127 then result = 127 end if
  if result < -128 then result = -128 end if
  return result
end function

function queuedSoundOrigin(server, entityIndex)
  if entityIndex < 0 or entityIndex >= len(server.edicts) then return t.Vec3(0.0, 0.0, 0.0) end if
  item = server.edicts[entityIndex]
  if item is void or item.free then return t.Vec3(0.0, 0.0, 0.0) end if
  center = math.scale(math.add(item.mins, item.maxs), 0.5)
  return math.add(item.origin, center)
end function

function writeQueuedSound(server, event)
  if server.datagram.curSize > c.MAX_DATAGRAM - 16 then return false end if
  entityIndex = event[0]
  channel = event[1]
  sample = event[2]
  volume = native.trunc(math.clamp(event[3], 0.0, 1.0) * 255.0)
  attenuation = math.clamp(event[4], 0.0, 4.0)
  index = soundIndex(server, sample)
  if index == 0 then
    server.diagnostics = server.diagnostics + ["sound was not precached: " + sample]
    return false
  end if
  fieldMask = 0
  if volume != 255 then fieldMask = fieldMask | 1 end if
  if attenuation != 1.0 then fieldMask = fieldMask | 2 end if
  msg.writeByte(server.datagram, c.SVC_SOUND)
  msg.writeByte(server.datagram, fieldMask)
  if (fieldMask & 1) != 0 then msg.writeByte(server.datagram, volume) end if
  if (fieldMask & 2) != 0 then msg.writeByte(server.datagram, native.trunc(attenuation * 64.0)) end if
  msg.writeShort(server.datagram, (entityIndex << 3) | channel)
  msg.writeByte(server.datagram, index)
  origin = queuedSoundOrigin(server, entityIndex)
  msg.writeCoord(server.datagram, origin.x)
  msg.writeCoord(server.datagram, origin.y)
  msg.writeCoord(server.datagram, origin.z)
  return true
end function

function writeQueuedParticle(server, event)
  if server.datagram.curSize > c.MAX_DATAGRAM - 16 then return false end if
  origin = event[0]
  direction = event[1]
  count = event[2]
  color = event[3]
  msg.writeByte(server.datagram, c.SVC_PARTICLE)
  msg.writeCoord(server.datagram, origin.x)
  msg.writeCoord(server.datagram, origin.y)
  msg.writeCoord(server.datagram, origin.z)
  msg.writeChar(server.datagram, clampDirection(direction.x))
  msg.writeChar(server.datagram, clampDirection(direction.y))
  msg.writeChar(server.datagram, clampDirection(direction.z))
  msg.writeByte(server.datagram, count)
  msg.writeByte(server.datagram, color)
  return true
end function

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

function sendReliableMessages(server)
  sent = 0
  for each clientValue in server.clients
    if clientValue.active and clientValue.socket is not void then
      if server.reliableDatagram.curSize > 0 then
        if sendBuffer(clientValue, server.reliableDatagram) > 0 then sent = sent + 1 end if
      end if
      if clientValue.message.curSize > 0 then
        if sendBuffer(clientValue, clientValue.message) > 0 then sz.clear(clientValue.message); sent = sent + 1 end if
      end if
    end if
  end for
  sz.clear(server.reliableDatagram)
  return sent
end function

function frame(server, player, frameTime, registry)
  if not server.active or server.paused then return false end if
  pumpClientMessages(server, player)

  // SV_Physics ordering: StartFrame, client edicts in numerical order, then
  // every remaining entity. This matters for pushers: a door/platform moves
  // after the player and carries anything standing on it during that frame.
  if server.machine is not void and server.machine.context is not void then
    for each clientValue in server.clients
      if clientValue.active and clientValue.spawned then syncPlayerToQuakeC(server, clientValue, player) end if
    end for
    runQuakeCFrame(server, frameTime)
  end if

  for each clientValue in server.clients
    if clientValue.active and clientValue.spawned then
      if server.machine is not void and server.machine.context is not void then
        syncPlayerFromQuakeC(server, clientValue, player)
        syncCommandToQuakeC(server, clientValue)
        executeQcFunction(server, "PlayerPreThink", clientValue.edictIndex, 0)
        syncPlayerFromQuakeC(server, clientValue, player)
        // SV_RunThink is part of SV_Physics_Client as well.
        runEntityThink(server, clientValue.edictIndex, frameTime)
        syncPlayerFromQuakeC(server, clientValue, player)
      end if

      physics.moveServer(player, server, clientValue.edictIndex, clientValue.command, frameTime, registry)
      player.renderAngles.y = player.viewAngles.y

      if server.machine is not void and server.machine.context is not void then
        syncPlayerToQuakeC(server, clientValue, player)
        executeQcFunction(server, "PlayerPostThink", clientValue.edictIndex, 0)
        syncPlayerFromQuakeC(server, clientValue, player)
      end if
    end if
  end for

  if server.machine is not void and server.machine.context is not void then
    runNonClientPhysics(server, frameTime, registry)
    // Pushers are evaluated after clients in SV_Physics.  A door, lift or train
    // may therefore carry the player after PlayerPostThink.  Preserve that
    // authoritative edict position in the shared local PlayerState instead of
    // overwriting it with the pre-pusher position at the start of the next
    // frame.
    for each clientValue in server.clients
      if clientValue.active and clientValue.spawned then syncPlayerFromQuakeC(server, clientValue, player) end if
    end for
  end if

  server.time = server.time + frameTime
  if server.machine is not void and server.machine.context is not void then
    server.machine.context.serverTime = server.time
    vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
    syncQuakeCEdicts(server)
    flushQuakeCEvents(server)
  end if
  sendReliableMessages(server)
  for each clientValue in server.clients
    sendClientFrame(server, clientValue, player)
  end for
  sz.clear(server.datagram)
  return true
end function

function shutdown(server)
  for each client in server.clients
    if client.socket is not void then netloop.close(client.socket) end if
    client.active = false
    client.spawned = false
  end for
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

function numberArray(count, defaultValue)
  return arrayutil.makeFilledArray(count, defaultValue)
end function

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

function clientMessageBuffers(server)
  result = arrayutil.makeEmptyArray(len(server.clients))
  index = 0
  while index < len(server.clients)
    result[index] = server.clients[index].message
    index = index + 1
  end while
  return result
end function

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
    1,
    "",
    0,
    server,
    clientMessageBuffers(server),
    clientSpawnParmBuffers(server),
  )
end function

function qcFloat(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityFloat(machine, entityIndex, offset)
end function

function qcWord(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityField(machine, entityIndex, offset)
end function

function qcVector(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  return vm.entityVector(machine, entityIndex, offset)
end function

function qcString(machine, entityIndex, fieldName, fallback)
  offset = vm.fieldOffset(machine, fieldName)
  if offset < 0 then return fallback end if
  value = vm.entityString(machine, entityIndex, offset)
  if value == "" then return fallback end if
  return value
end function

function syncQuakeCEdict(server, entityIndex)
  machine = server.machine
  runtime = machine.context.edicts
  item = edict.create(entityIndex)
  item.free = runtime.freeFlags[entityIndex]
  if item.free then return item end if
  item.className = qcString(machine, entityIndex, "classname", "")
  item.model = qcString(machine, entityIndex, "model", "")
  item.modelIndex = native.trunc(qcFloat(machine, entityIndex, "modelindex", 0.0))
  item.frame = native.trunc(qcFloat(machine, entityIndex, "frame", 0.0))
  item.skin = native.trunc(qcFloat(machine, entityIndex, "skin", 0.0))
  item.colormap = native.trunc(qcFloat(machine, entityIndex, "colormap", 0.0))
  item.effects = native.trunc(qcFloat(machine, entityIndex, "effects", 0.0))
  item.origin = qcVector(machine, entityIndex, "origin", t.Vec3(0.0, 0.0, 0.0))
  item.angles = qcVector(machine, entityIndex, "angles", t.Vec3(0.0, 0.0, 0.0))
  item.velocity = qcVector(machine, entityIndex, "velocity", t.Vec3(0.0, 0.0, 0.0))
  item.mins = qcVector(machine, entityIndex, "mins", t.Vec3(0.0, 0.0, 0.0))
  item.maxs = qcVector(machine, entityIndex, "maxs", t.Vec3(0.0, 0.0, 0.0))
  item.moveType = native.trunc(qcFloat(machine, entityIndex, "movetype", c.MOVETYPE_NONE))
  item.solid = native.trunc(qcFloat(machine, entityIndex, "solid", c.SOLID_NOT))
  item.flags = native.trunc(qcFloat(machine, entityIndex, "flags", 0.0))
  item.health = qcFloat(machine, entityIndex, "health", 0.0)
  item.viewOffset = qcVector(machine, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT))
  item.onGround = (item.flags & c.FL_ONGROUND) != 0
  item.groundEntity = qcWord(machine, entityIndex, "groundentity", -1)
  base = qcedict.baseline(machine, entityIndex)
  item.baseline = t.EntityBaseline(
    native.trunc(base[0]),
    native.trunc(base[1]),
    native.trunc(base[2]),
    native.trunc(base[3]),
    base[4],
    base[5],
  )
  return item
end function

function recomputeEdictCount(server)
  runtime = server.machine.context.edicts
  highest = server.maxClients
  index = server.maxClients + 1
  while index < runtime.maxEdicts
    if not runtime.freeFlags[index] then highest = index end if
    index = index + 1
  end while
  runtime.numEdicts = highest + 1
  server.numEdicts = runtime.numEdicts
  return runtime.numEdicts
end function

function syncQuakeCEdicts(server)
  recomputeEdictCount(server)
  result = arrayutil.makeEmptyArray(server.numEdicts)
  index = 0
  while index < server.numEdicts
    result[index] = syncQuakeCEdict(server, index)
    index = index + 1
  end while
  // Client edicts are reserved before ED_LoadFromFile and initially have no
  // classname. Keep their physical defaults ready for PutClientInServer.
  index = 1
  while index <= server.maxClients and index < len(result)
    if result[index].className == "" then
      result[index].className = "player"
      result[index].mins = t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z)
      result[index].maxs = t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z)
      result[index].moveType = c.MOVETYPE_WALK
      result[index].solid = c.SOLID_SLIDEBOX
      result[index].flags = c.FL_CLIENT
      result[index].health = 100.0
      result[index].viewOffset = t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT)
    end if
    index = index + 1
  end while
  server.edicts = result
  return len(result)
end function

function spawnRuntime(server, filesystem, mapName, skill, registry, commandSystem)
  spawn(server, filesystem, mapName, skill)
  // The QuakeC spawn builtins append static entities and ambient sounds to the
  // signon stream. Discard the provisional non-QC baseline before ED_LoadFromFile.
  sz.clear(server.signon)
  runtime = createEdictRuntime(server.maxEdicts, server.maxClients)
  server.machine.edictFree = runtime.freeFlags
  contextValue = createQuakeCContext(server, filesystem, registry, commandSystem, runtime)
  vm.setContext(server.machine, contextValue)
  qcbuiltins.install(server.machine, contextValue)
  qcedict.initializeGlobals(server.machine, server.mapName, skill, server.deathmatch, server.coop, server.serverFlags)
  result = qcedict.loadMapEntitiesFrom(server.machine, server.worldModel, skill, server.deathmatch, server.maxClients + 1)
  recomputeEdictCount(server)
  server.modelPrecache = contextValue.modelPrecache
  server.soundPrecache = contextValue.soundPrecache
  server.lightStyles = contextValue.lightStyles
  syncQuakeCEdicts(server)
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
  syncQuakeCEdicts(server)
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
  return server
end function

function setQcEntityVector(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityVector(server.machine, entityIndex, offset, value) end if
end function

function setQcEntityFloat(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityFloat(server.machine, entityIndex, offset, value) end if
end function

function setQcEntityWord(server, entityIndex, fieldName, value)
  offset = vm.fieldOffset(server.machine, fieldName)
  if offset >= 0 then vm.setEntityField(server.machine, entityIndex, offset, value) end if
end function

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
  setQcEntityVector(server, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, player.viewHeight))
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

function syncPlayerFromQuakeC(server, clientValue, player)
  if server.machine is void then return false end if
  entityIndex = clientValue.edictIndex
  player.origin = qcVector(server.machine, entityIndex, "origin", player.origin)
  player.oldOrigin = qcVector(server.machine, entityIndex, "oldorigin", player.oldOrigin)
  player.velocity = qcVector(server.machine, entityIndex, "velocity", player.velocity)
  player.viewAngles = qcVector(server.machine, entityIndex, "v_angle", player.viewAngles)
  player.renderAngles = qcVector(server.machine, entityIndex, "angles", player.renderAngles)
  player.punchAngle = qcVector(server.machine, entityIndex, "punchangle", player.punchAngle)
  player.moveDir = qcVector(server.machine, entityIndex, "movedir", player.moveDir)
  player.mins = qcVector(server.machine, entityIndex, "mins", player.mins)
  player.maxs = qcVector(server.machine, entityIndex, "maxs", player.maxs)
  player.viewHeight = qcVector(server.machine, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, player.viewHeight)).z
  player.health = qcFloat(server.machine, entityIndex, "health", player.health)
  player.armor = qcFloat(server.machine, entityIndex, "armorvalue", player.armor)
  player.ammo = native.trunc(qcFloat(server.machine, entityIndex, "currentammo", player.ammo))
  player.shells = native.trunc(qcFloat(server.machine, entityIndex, "ammo_shells", player.shells))
  player.nails = native.trunc(qcFloat(server.machine, entityIndex, "ammo_nails", player.nails))
  player.rockets = native.trunc(qcFloat(server.machine, entityIndex, "ammo_rockets", player.rockets))
  player.cells = native.trunc(qcFloat(server.machine, entityIndex, "ammo_cells", player.cells))
  player.items = native.trunc(qcFloat(server.machine, entityIndex, "items", player.items))
  player.activeWeapon = native.trunc(qcFloat(server.machine, entityIndex, "weapon", player.activeWeapon))
  player.weaponFrame = native.trunc(qcFloat(server.machine, entityIndex, "weaponframe", player.weaponFrame))
  weaponModel = qcString(server.machine, entityIndex, "weaponmodel", "")
  if weaponModel == "" then player.weapon = 0 else player.weapon = modelIndex(server, weaponModel) end if
  player.moveType = native.trunc(qcFloat(server.machine, entityIndex, "movetype", player.moveType))
  player.flags = native.trunc(qcFloat(server.machine, entityIndex, "flags", player.flags))
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  player.groundEntity = qcWord(server.machine, entityIndex, "groundentity", player.groundEntity)
  player.waterLevel = native.trunc(qcFloat(server.machine, entityIndex, "waterlevel", player.waterLevel))
  player.waterType = native.trunc(qcFloat(server.machine, entityIndex, "watertype", player.waterType))
  player.fixAngle = qcFloat(server.machine, entityIndex, "fixangle", 0.0) != 0.0
  player.teleportTime = qcFloat(server.machine, entityIndex, "teleport_time", player.teleportTime)
  player.deadFlag = native.trunc(qcFloat(server.machine, entityIndex, "deadflag", player.deadFlag))
  player.noclip = player.moveType == c.MOVETYPE_NOCLIP
  return true
end function

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
