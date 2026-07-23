package miniquake.client

import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.net_loop as netloop
import miniquake.client_protocol as protocol
import miniquake.protocol_write as writer
import miniquake.mathlib as math
import miniquake.input as input
import miniquake.array_util as arrayutil

// cl_main.c: client-side dynamic-light pool.  The original stores this as a
// fixed translation-unit array rather than inside client_state_t; a package
// global is the direct MiniLang equivalent.
clDlights = []
clDlightTime = 0.0
clDlightOldTime = 0.0
clDlightRandomSeed = 0x12345

function newDynamicLight()
  return t.DynamicLight(
    t.Vec3(0.0, 0.0, 0.0),
    0.0,
    0.0,
    0.0,
    0.0,
    0,
  )
end function

function resetDynamicLight(light, key)
  light.origin = t.Vec3(0.0, 0.0, 0.0)
  light.radius = 0.0
  light.die = 0.0
  light.decay = 0.0
  light.minLight = 0.0
  light.key = key
  return light
end function

function ensureDynamicLights()
  global clDlights
  if len(clDlights) == c.MAX_DLIGHTS then return clDlights end if
  clDlights = arrayutil.makeEmptyArray(c.MAX_DLIGHTS)
  index = 0
  while index < c.MAX_DLIGHTS
    clDlights[index] = newDynamicLight()
    index = index + 1
  end while
  return clDlights
end function

function CL_ClearDlights()
  global clDlights
  ensureDynamicLights()
  index = 0
  while index < c.MAX_DLIGHTS
    resetDynamicLight(clDlights[index], 0)
    index = index + 1
  end while
  return true
end function

function CL_SetDlightTime(oldTime, currentTime)
  global clDlightOldTime, clDlightTime
  clDlightOldTime = oldTime
  clDlightTime = currentTime
  return currentTime
end function

// CL_AllocDlight from cl_main.c.  Exact key matches are preferred, then an
// expired slot, with slot zero as the original overflow fallback.
function CL_AllocDlight(key)
  global clDlights, clDlightTime
  ensureDynamicLights()
  if key != 0 then
    index = 0
    while index < c.MAX_DLIGHTS
      light = clDlights[index]
      if light.key == key then
        return resetDynamicLight(light, key)
      end if
      index = index + 1
    end while
  end if

  index = 0
  while index < c.MAX_DLIGHTS
    light = clDlights[index]
    if light.die < clDlightTime then
      return resetDynamicLight(light, key)
    end if
    index = index + 1
  end while

  return resetDynamicLight(clDlights[0], key)
end function

function CL_AllocDlightAt(key, currentTime)
  global clDlightTime
  clDlightTime = currentTime
  return CL_AllocDlight(key)
end function

function CL_DecayLights()
  global clDlights, clDlightOldTime, clDlightTime
  ensureDynamicLights()
  elapsed = clDlightTime - clDlightOldTime
  index = 0
  while index < c.MAX_DLIGHTS
    light = clDlights[index]
    if light.die >= clDlightTime and light.radius != 0.0 then
      light.radius = light.radius - elapsed * light.decay
      if light.radius < 0.0 then light.radius = 0.0 end if
    end if
    index = index + 1
  end while
  return true
end function

function CL_DecayLightsAt(currentTime, elapsed)
  global clDlightOldTime, clDlightTime
  clDlightOldTime = currentTime - elapsed
  clDlightTime = currentTime
  return CL_DecayLights()
end function

function nextDlightRandom()
  global clDlightRandomSeed
  clDlightRandomSeed = (clDlightRandomSeed * 1103515245 + 12345) & 0x7fffffff
  return clDlightRandomSeed
end function

// The EF_* lights are created during CL_RelinkEntities in WinQuake.  This
// helper performs only that lighting side effect; entity interpolation and
// trail generation remain in their existing rendering path.
function CL_UpdateEntityDlights(client, currentTime)
  global clDlightTime
  clDlightTime = currentTime
  for each entity in client.entities
    if entity is not void and entity.modelIndex != 0 then
      effects = entity.effects
      if (effects & c.EF_MUZZLEFLASH) != 0 then
        light = CL_AllocDlight(entity.number)
        light.origin = math.copy(entity.origin)
        light.origin.z = light.origin.z + 16.0
        axes = math.angleVectors(entity.angles)
        light.origin = math.add(light.origin, math.scale(axes[0], 18.0))
        light.radius = 200.0 + (nextDlightRandom() & 31)
        light.minLight = 32.0
        light.die = currentTime + 0.1
      end if
      if (effects & c.EF_BRIGHTLIGHT) != 0 then
        light = CL_AllocDlight(entity.number)
        light.origin = math.copy(entity.origin)
        light.origin.z = light.origin.z + 16.0
        light.radius = 400.0 + (nextDlightRandom() & 31)
        light.die = currentTime + 0.001
      end if
      if (effects & c.EF_DIMLIGHT) != 0 then
        light = CL_AllocDlight(entity.number)
        light.origin = math.copy(entity.origin)
        light.radius = 200.0 + (nextDlightRandom() & 31)
        light.die = currentTime + 0.001
      end if
    end if
  end for
  return clDlights
end function

function createEntity(number)
  return t.ClientEntityState(
    number,
    0,
    0,
    0,
    0,
    0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    0.0,
  )
end function

function create(player)
  CL_ClearDlights()
  return t.LocalClient(
    false,
    c.SIGNON_NONE,
    false,
    void,
    sz.alloc(c.MAX_MSGLEN),
    sz.alloc(c.MAX_MSGLEN),
    c.PROTOCOL_VERSION,
    1,
    c.GAME_COOP,
    "",
    [""],
    [""],
    0,
    0.0,
    [],
    [],
    [],
    player,
    0.0,
    input.createCommand(),
    false,
  )
end function

function ensureEntity(client, number)
  while len(client.entities) <= number
    client.entities = client.entities + [void]
  end while
  if client.entities[number] is void then client.entities[number] = createEntity(number) end if
  return client.entities[number]
end function

function connect(client, network)
  CL_ClearDlights()
  socket = netloop.connect(network, "local")
  if socket is void then return error(2900, "CL_EstablishConnection: loopback connect failed") end if
  client.socket = socket
  client.connected = true
  // A transport connection is not a protocol signon stage. The original
  // CL_EstablishConnection resets cls.signon to zero and waits for the
  // server's first svc_signonnum before replying with "prespawn".
  client.signon = c.SIGNON_NONE
  client.spawned = false
  client.printLog = []
  if client.player is not void then client.command.viewAngles = math.copy(client.player.viewAngles) end if
  sz.clear(client.outgoing)
  sz.clear(client.incoming)
  return client
end function

function disconnect(client)
  if client.socket is not void then
    buffer = sz.alloc(16)
    writer.writeDisconnect(buffer)
    netloop.sendUnreliableMessage(client.socket, buffer)
    netloop.close(client.socket)
  end if
  client.socket = void
  client.connected = false
  client.spawned = false
  client.signon = c.SIGNON_NONE
  return true
end function

function queueString(client, text)
  if not client.connected or client.socket is void then return -1 end if
  writer.writeStringCommand(client.outgoing, text)
  return client.outgoing.curSize
end function

function sendReliable(client)
  if not client.connected or client.socket is void then return -1 end if
  if client.outgoing.curSize == 0 then return 0 end if
  if not netloop.canSendMessage(client.socket) then return 0 end if
  result = netloop.sendMessage(client.socket, client.outgoing)
  if result == 1 then sz.clear(client.outgoing) end if
  return result
end function

function sendString(client, text)
  queued = queueString(client, text)
  if queued < 0 then return queued end if
  return sendReliable(client)
end function

function sendMove(client, command)
  if not client.connected or not client.spawned or client.socket is void then return 0 end if
  buffer = sz.alloc(64)
  writer.writeMove(buffer, command, client.serverTime)
  return netloop.sendUnreliableMessage(client.socket, buffer)
end function

function applyBaseline(client, number, baseline)
  entity = ensureEntity(client, number)
  entity.modelIndex = baseline[0]
  entity.frame = baseline[1]
  entity.colormap = baseline[2]
  entity.skin = baseline[3]
  entity.origin = math.copy(baseline[4])
  entity.angles = math.copy(baseline[5])
  return entity
end function

function applyFastUpdate(client, payload)
  number = payload[0]
  entity = ensureEntity(client, number)
  if payload[2] is not void then entity.modelIndex = payload[2] end if
  if payload[3] is not void then entity.frame = payload[3] end if
  if payload[4] is not void then entity.colormap = payload[4] end if
  if payload[5] is not void then entity.skin = payload[5] end if
  if payload[6] is not void then entity.effects = payload[6] end if
  origin = payload[7]
  angles = payload[8]
  if origin[0] is not void then entity.origin.x = origin[0] end if
  if origin[1] is not void then entity.origin.y = origin[1] end if
  if origin[2] is not void then entity.origin.z = origin[2] end if
  if angles[0] is not void then entity.angles.x = angles[0] end if
  if angles[1] is not void then entity.angles.y = angles[1] end if
  if angles[2] is not void then entity.angles.z = angles[2] end if
  entity.messageTime = client.serverTime
  // An integrated local game shares the authoritative PlayerState with the
  // server.  Reapplying protocol-quantized coordinates to that same object
  // produces a visible 1/8-unit camera shimmer.  Remote and demo clients still
  // consume the network state normally.
  if number == client.viewEntity and client.player is not void and not client.localAuthoritative then
    client.player.origin = math.copy(entity.origin)
    client.player.renderAngles = math.copy(entity.angles)
  end if
  return entity
end function

function advanceSignon(client, stage)
  if stage < c.SIGNON_SERVERINFO or stage > c.SIGNONS then
    return error(2903, "CL_ParseServerMessage: invalid signon " + stage)
  end if
  if stage <= client.signon then
    return error(2904, "CL_ParseServerMessage: received signon " + stage + " when at " + client.signon)
  end if
  client.signon = stage
  if stage == c.SIGNON_SERVERINFO then
    return sendString(client, "prespawn") >= 0
  else if stage == c.SIGNON_PRESPAWN then
    // CL_SignonReply writes all three commands into one reliable message.
    queueString(client, "name \"player\"\n")
    queueString(client, "color 0 0\n")
    queueString(client, "spawn")
    return sendReliable(client) >= 0
  else if stage == c.SIGNON_SPAWN then
    return sendString(client, "begin") >= 0
  else if stage == c.SIGNON_ACTIVE then
    client.spawned = true
    return true
  end if
  return true
end function

function applyEvent(client, item)
  name = item.command
  payload = item.payload
  if name == "svc_version" then
    if payload != c.PROTOCOL_VERSION then return error(2901, "CL_ParseServerMessage: protocol " + payload + " != " + c.PROTOCOL_VERSION) end if
    client.protocol = payload
  else if name == "svc_serverinfo" then
    if payload[0] != c.PROTOCOL_VERSION then return error(2902, "Server is protocol " + payload[0]) end if
    client.maxClients = payload[1]
    client.gameType = payload[2]
    client.levelName = payload[3]
    client.modelPrecache = [""] + payload[4]
    client.soundPrecache = [""] + payload[5]
    client.entities = []
  else if name == "svc_setview" then
    client.viewEntity = payload
    ensureEntity(client, payload)
  else if name == "svc_setangle" then
    client.command.viewAngles = math.copy(payload)
    if client.player is not void then
      client.player.viewAngles = math.copy(payload)
      client.player.renderAngles = math.copy(payload)
    end if
  else if name == "svc_time" then
    client.serverTime = payload
    client.lastMessageTime = payload
  else if name == "svc_print" then
    client.printLog = client.printLog + [payload]
    client.messages = client.messages + [item]
  else if name == "svc_centerprint" then
    client.messages = client.messages + [item]
  else if name == "svc_sound" or name == "svc_stopsound" or name == "svc_spawnstaticsound" or name == "svc_particle" or name == "svc_temp_entity" or name == "svc_damage" or name == "svc_stufftext" then
    client.messages = client.messages + [item]
  else if name == "svc_signonnum" then
    return advanceSignon(client, payload)
  else if name == "svc_spawnbaseline" then
    applyBaseline(client, payload[0], payload[1])
  else if name == "svc_spawnstatic" then
    number = len(client.entities)
    applyBaseline(client, number, payload)
  else if name == "fast_update" then
    applyFastUpdate(client, payload)
  else if name == "svc_clientdata" then
    if client.player is not void and not client.localAuthoritative then
      // Remote and demo clients consume the quantized clientdata state.  The
      // integrated loopback client shares the authoritative server-side
      // PlayerState and must never feed the previous packet's FL_ONGROUND,
      // velocity or view offsets back into the next physics frame.
      if payload[1] is void then client.player.viewHeight = c.DEFAULT_VIEWHEIGHT else client.player.viewHeight = payload[1] end if
      client.player.onGround = (payload[0] & c.SU_ONGROUND) != 0
      client.player.waterLevel = 0
      if (payload[0] & c.SU_INWATER) != 0 then client.player.waterLevel = 2 end if
      punch = payload[3]
      velocity = payload[4]
      client.player.punchAngle = t.Vec3(0.0, 0.0, 0.0)
      client.player.velocity = t.Vec3(0.0, 0.0, 0.0)
      if punch[0] is not void then client.player.punchAngle.x = punch[0] end if
      if punch[1] is not void then client.player.punchAngle.y = punch[1] end if
      if punch[2] is not void then client.player.punchAngle.z = punch[2] end if
      if velocity[0] is not void then client.player.velocity.x = velocity[0] end if
      if velocity[1] is not void then client.player.velocity.y = velocity[1] end if
      if velocity[2] is not void then client.player.velocity.z = velocity[2] end if
      client.player.health = payload[9]
      client.player.items = payload[5]
      client.player.weaponFrame = payload[6]
      client.player.armor = payload[7]
      client.player.weapon = payload[8]
      client.player.ammo = payload[10]
      client.player.shells = payload[11]
      client.player.nails = payload[12]
      client.player.rockets = payload[13]
      client.player.cells = payload[14]
      client.player.activeWeapon = payload[15]
    end if
  else if name == "svc_disconnect" then
    client.connected = false
    client.spawned = false
    client.signon = c.SIGNON_NONE
  else
    client.messages = client.messages + [item]
  end if
  return true
end function

function parseMessage(client, data)
  result = protocol.parse(data)
  for each item in result.events
    applyEvent(client, item)
  end for
  return len(result.events)
end function

function pump(client)
  if not client.connected or client.socket is void then return 0 end if
  processed = 0
  messageType = netloop.getMessage(client.socket, client.incoming)
  while messageType > 0
    parseMessage(client, sz.dataSlice(client.incoming))
    processed = processed + 1
    messageType = netloop.getMessage(client.socket, client.incoming)
  end while
  return processed
end function

function consumeMessages(client)
  result = client.messages
  client.messages = []
  return result
end function

function consumePrintLog(client)
  result = client.printLog
  client.printLog = []
  return result
end function

function drainMessages(client)
  pending = client.messages
  client.messages = []
  return pending
end function
