package miniquake.client

import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.net_main as netmain
import miniquake.client_protocol as protocol
import miniquake.protocol_write as writer
import miniquake.protocol_signon as protocolSignon
import miniquake.protocol_delivery as delivery
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.input as input
import miniquake.array_util as arrayutil
import miniquake.cvar as cvar
import miniquake.cmd as commandBuffer
import miniquake.message as msg
import miniquake.demo as demo
import miniquake.statusbar as statusbar
import miniquake.particles as particles

// cl_main.c: client-side dynamic-light pool.  The original stores this as a
// fixed translation-unit array rather than inside client_state_t; a package
// global is the direct MiniLang equivalent.
clDlights = []
clDlightTime = 0.0
clDlightOldTime = 0.0
clModelFlags = []
clModelSyncTypes = []
clRelinkParticleEffects = []
clChaseActive = false
clRelinkParticlePool = []
clRelinkParticlePoolActive = false
clRelinkParticleTime = 0.0
clMoveMessages = 0
clKeepaliveLastMessage = 0.0
clTranslations = []
clStandardQuake = true
clRegisteredCommands = []
clDisconnectRequestedServerShutdown = false

// client_state_t stores interpolation velocities, entity transforms and
// dlight fields as C floats even though cl.time/mtime are doubles.
function clientFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

function clientLerp(previous, current, fraction)
  delta = clientFloat(current - previous)
  return clientFloat(previous + clientFloat(fraction * delta))
end function

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

function CL_Dlights()
  ensureDynamicLights()
  return clDlights
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

function CL_DlightIndexForKey(key)
  global clDlights
  ensureDynamicLights()
  index = 0
  while index < len(clDlights)
    if clDlights[index].key == key then return index end if
    index = index + 1
  end while
  return -1
end function

function CL_DecayLights()
  global clDlights, clDlightOldTime, clDlightTime
  ensureDynamicLights()
  elapsed = clientFloat(clDlightTime - clDlightOldTime)
  index = 0
  while index < c.MAX_DLIGHTS
    light = clDlights[index]
    if light.die >= clDlightTime and light.radius != 0.0 then
      light.radius = clientFloat(light.radius - clientFloat(elapsed * light.decay))
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

function CL_LerpPoint(client)
  // f and frac are float locals in cl_main.c; mtime/time remain double.
  interval = clientFloat(client.messageTimes[0] - client.messageTimes[1])
  if interval == 0.0 or client.noLerp or client.timedemo or client.localAuthoritative then
    client.time = client.messageTimes[0]
    return clientFloat(1.0)
  end if
  if interval > 0.1 then
    client.messageTimes[1] = client.messageTimes[0] - 0.1
    interval = clientFloat(0.1)
  end if
  fraction = clientFloat((client.time - client.messageTimes[1]) / interval)
  if fraction < 0.0 then
    if fraction < -0.01 then client.time = client.messageTimes[1]; SetPal(1) end if
    return clientFloat(0.0)
  end if
  if fraction > 1.0 then
    if fraction > 1.01 then client.time = client.messageTimes[0]; SetPal(2) end if
    return clientFloat(1.0)
  end if
  SetPal(0)
  return fraction
end function

function interpolatedAngle(previous, current, fraction)
  delta = clientFloat(current - previous)
  if delta > 180.0 then delta = clientFloat(delta - 360.0) else if delta < -180.0 then delta = clientFloat(delta + 360.0) end if
  return clientLerp(previous, clientFloat(previous + delta), fraction)
end function

function CL_SetModelFlags(flags)
  global clModelFlags
  clModelFlags = flags
  return len(clModelFlags)
end function

function CL_ModelFlags()
  global clModelFlags
  return clModelFlags
end function

function CL_SetModelSyncTypes(syncTypes)
  global clModelSyncTypes
  clModelSyncTypes = syncTypes
  return len(clModelSyncTypes)
end function

function CL_ModelSyncTypes()
  global clModelSyncTypes
  return clModelSyncTypes
end function

function modelSyncTypeForIndex(modelIndex)
  global clModelSyncTypes
  if modelIndex < 0 or modelIndex >= len(clModelSyncTypes) then return c.ST_SYNC end if
  return clModelSyncTypes[modelIndex]
end function

function CL_AssignModelSyncBase(entity, previousModelIndex)
  if entity.modelIndex == previousModelIndex then return entity.syncBase end if
  if entity.modelIndex <= 0 then entity.syncBase = 0.0; return entity.syncBase end if
  if modelSyncTypeForIndex(entity.modelIndex) == c.ST_RAND then
    entity.syncBase = clientFloat(particles.compatRand() / 32767.0)
  else
    entity.syncBase = 0.0
  end if
  return entity.syncBase
end function

function CL_SetChaseActive(active)
  global clChaseActive
  clChaseActive = active
  return active
end function

function modelFlagsForIndex(modelIndex)
  global clModelFlags
  if modelIndex < 0 or modelIndex >= len(clModelFlags) then return 0 end if
  return clModelFlags[modelIndex]
end function

function queueRelinkParticleEffect(command, payload)
  global clRelinkParticleEffects, clRelinkParticlePool, clRelinkParticlePoolActive, clRelinkParticleTime
  if clRelinkParticlePoolActive then
    if command == "entity_particles" then
      clRelinkParticlePool = particles.entityParticlesInto(clRelinkParticlePool, payload, clRelinkParticleTime)
    else if command == "rocket_trail" then
      clRelinkParticlePool = particles.rocketTrailInto(
        clRelinkParticlePool,
        payload[0],
        payload[1],
        payload[2],
        clRelinkParticleTime,
      )
    end if
    return len(clRelinkParticlePool)
  end if
  clRelinkParticleEffects = clRelinkParticleEffects + [t.ProtocolEvent(command, payload)]
  return len(clRelinkParticleEffects)
end function

function CL_TakeRelinkParticleEffects()
  global clRelinkParticleEffects
  result = clRelinkParticleEffects
  clRelinkParticleEffects = []
  return result
end function

function CL_BeginRelinkParticles(active)
  global clRelinkParticlePool, clRelinkParticlePoolActive
  clRelinkParticlePool = active
  clRelinkParticlePoolActive = true
  return len(clRelinkParticlePool)
end function

function CL_EndRelinkParticles()
  global clRelinkParticlePool, clRelinkParticlePoolActive
  result = clRelinkParticlePool
  clRelinkParticlePool = []
  clRelinkParticlePoolActive = false
  return result
end function

function CL_SetRandomSeed(seed)
  return particles.resetRandom(seed)
end function

function addEntityEffectDlights(entity, currentTime)
  effects = entity.effects
  if (effects & c.EF_MUZZLEFLASH) != 0 then
    light = CL_AllocDlight(entity.number)
    light.origin = math.copy(entity.origin)
    light.origin.z = light.origin.z + 16.0
    axes = math.angleVectors(entity.angles)
    light.origin = math.add(light.origin, math.scale(axes[0], 18.0))
    light.radius = clientFloat(200.0 + (nextDlightRandom() & 31))
    light.minLight = 32.0
    light.die = clientFloat(currentTime + 0.1)
  end if
  if (effects & c.EF_BRIGHTLIGHT) != 0 then
    light = CL_AllocDlight(entity.number)
    light.origin = math.copy(entity.origin)
    light.origin.z = light.origin.z + 16.0
    light.radius = clientFloat(400.0 + (nextDlightRandom() & 31))
    light.die = clientFloat(currentTime + 0.001)
  end if
  if (effects & c.EF_DIMLIGHT) != 0 then
    light = CL_AllocDlight(entity.number)
    light.origin = math.copy(entity.origin)
    light.radius = clientFloat(200.0 + (nextDlightRandom() & 31))
    light.die = clientFloat(currentTime + 0.001)
  end if
  return true
end function

function CL_RelinkEntities(client)
  global clRelinkParticleEffects, clChaseActive, clDlightTime, clRelinkParticleTime
  fraction = CL_LerpPoint(client)
  clDlightTime = client.time
  clRelinkParticleTime = client.time
  if client.player is not void and not client.localAuthoritative then
    previousVelocity = client.velocitySamples[1]
    currentVelocity = client.velocitySamples[0]
    // Keep the sampled vectors rooted across the result allocation.  This
    // path runs immediately after a changelevel has rebuilt a large client
    // heap; spelling the original VectorInterpolate arithmetic directly
    // prevents a collection between nested temporary Vec3 allocations from
    // leaving a partially initialized remote-player velocity.
    client.player.velocity = t.Vec3(
      clientLerp(previousVelocity.x, currentVelocity.x, fraction),
      clientLerp(previousVelocity.y, currentVelocity.y, fraction),
      clientLerp(previousVelocity.z, currentVelocity.z, fraction),
    )
    if client.demoPlayback then
      interpolatedViewAngles = t.Vec3(
        interpolatedAngle(client.viewAngleSamples[1].x, client.viewAngleSamples[0].x, fraction),
        interpolatedAngle(client.viewAngleSamples[1].y, client.viewAngleSamples[0].y, fraction),
        interpolatedAngle(client.viewAngleSamples[1].z, client.viewAngleSamples[0].z, fraction),
      )
      // CL_RelinkEntities writes the interpolated demo angles to
      // cl.viewangles. V_RenderView consumes that value directly; retaining
      // the newest DEM header here bypassed interpolation and shifted the
      // camera relative to every world/entity draw.
      client.command.viewAngles = math.copy(interpolatedViewAngles)
      client.player.viewAngles = interpolatedViewAngles
    end if
  end if

  clRelinkParticleEffects = []
  visibleBuilder = arrayutil.createArrayBuilder(c.MAX_VISEDICTS)
  binaryObjectRotation = clientFloat(math.anglemod(100.0 * client.time))
  entityCount = len(client.entities)
  index = 1
  while index < entityCount
    entity = client.entities[index]
    if entity is not void and entity.modelIndex != 0 then
      if entity.messageTime < 0.0 then
        if visibleBuilder.count < c.MAX_VISEDICTS then arrayutil.pushArrayBuilder(visibleBuilder, entity) end if
      else if entity.messageTime != client.messageTimes[0] then
        entity.modelIndex = 0
      else
        oldOrigin = math.copy(entity.origin)
        entityFraction = fraction
        delta = t.Vec3(
          clientFloat(entity.messageOrigin.x - entity.previousMessageOrigin.x),
          clientFloat(entity.messageOrigin.y - entity.previousMessageOrigin.y),
          clientFloat(entity.messageOrigin.z - entity.previousMessageOrigin.z),
        )
        if delta.x > 100.0 or delta.x < -100.0 then entityFraction = clientFloat(1.0) end if
        if delta.y > 100.0 or delta.y < -100.0 then entityFraction = clientFloat(1.0) end if
        if delta.z > 100.0 or delta.z < -100.0 then entityFraction = clientFloat(1.0) end if
        if entity.forceLink then entityFraction = clientFloat(1.0) end if
        previousOrigin = entity.previousMessageOrigin
        entity.origin = t.Vec3(
          clientLerp(previousOrigin.x, entity.messageOrigin.x, entityFraction),
          clientLerp(previousOrigin.y, entity.messageOrigin.y, entityFraction),
          clientLerp(previousOrigin.z, entity.messageOrigin.z, entityFraction),
        )
        entity.angles = t.Vec3(
          interpolatedAngle(entity.previousMessageAngles.x, entity.messageAngles.x, entityFraction),
          interpolatedAngle(entity.previousMessageAngles.y, entity.messageAngles.y, entityFraction),
          interpolatedAngle(entity.previousMessageAngles.z, entity.messageAngles.z, entityFraction),
        )
        modelFlags = modelFlagsForIndex(entity.modelIndex)
        if (modelFlags & c.EF_ROTATE) != 0 then entity.angles.y = binaryObjectRotation end if
        if (entity.effects & c.EF_BRIGHTFIELD) != 0 then
          queueRelinkParticleEffect("entity_particles", math.copy(entity.origin))
        end if
        addEntityEffectDlights(entity, client.time)
        if (modelFlags & c.EF_GIB) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 2])
        else if (modelFlags & c.EF_ZOMGIB) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 4])
        else if (modelFlags & c.EF_TRACER) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 3])
        else if (modelFlags & c.EF_TRACER2) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 5])
        else if (modelFlags & c.EF_ROCKET) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 0])
          light = CL_AllocDlight(entity.number)
          light.origin = math.copy(entity.origin)
          light.radius = 200.0
          light.die = clientFloat(client.time + 0.01)
        else if (modelFlags & c.EF_GRENADE) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 1])
        else if (modelFlags & c.EF_TRACER3) != 0 then
          queueRelinkParticleEffect("rocket_trail", [oldOrigin, math.copy(entity.origin), 6])
        end if
        entity.forceLink = false
        if (index != client.viewEntity or clChaseActive) and visibleBuilder.count < c.MAX_VISEDICTS then
          arrayutil.pushArrayBuilder(visibleBuilder, entity)
        end if
      end if
    end if
    index = index + 1
  end while
  client.visibleEntities = arrayutil.finishArrayBuilder(visibleBuilder)
  return client.visibleEntities
end function

// Return the exact entity list consumed by the renderer after CL_RelinkEntities.
// WinQuake renders cl_visedicts rather than the entire sparse cl_entities array.
// Keep this as a defensive view: invalid/cleared entries can never leak into a
// modern backend even if a caller retained an older visibleEntities array.
function CL_ActiveVisibleEntities(client)
  builder = arrayutil.createArrayBuilder(len(client.visibleEntities))
  for each entity in client.visibleEntities
    if entity is not void and entity.modelIndex != 0 and builder.count < c.MAX_VISEDICTS then
      arrayutil.pushArrayBuilder(builder, entity)
    end if
  end for
  return arrayutil.finishArrayBuilder(builder)
end function

// gl_refrag.c removes stale efrags when a force-linked entity no longer has a
// model.  The integrated renderer does not expose native efrag pointers, so
// this source-guided list is the hand-off boundary for efrag-aware backends.
function CL_ViewEntityOrigin(client)
  index = client.viewEntity
  if index >= 0 and index < len(client.entities) then
    entity = client.entities[index]
    if entity is not void then return math.copy(entity.origin) end if
  end if
  if client.player is not void then return math.copy(client.player.origin) end if
  return t.Vec3(0.0, 0.0, 0.0)
end function

function CL_EfragRemovalCandidates(client)
  builder = arrayutil.createArrayBuilder(len(client.entities))
  for each entity in client.entities
    if entity is not void and entity.modelIndex == 0 and entity.forceLink then
      arrayutil.pushArrayBuilder(builder, entity)
    end if
  end for
  return arrayutil.finishArrayBuilder(builder)
end function

function nextDlightRandom()
  return particles.compatRand()
end function

// The EF_* lights are created during CL_RelinkEntities in WinQuake.  This
// helper performs only that lighting side effect; entity interpolation and
// trail generation remain in their existing rendering path.
function CL_UpdateEntityDlights(client, currentTime)
  global clDlightTime
  clDlightTime = currentTime
  for each entity in client.entities
    if entity is not void and entity.modelIndex != 0 then
      addEntityEffectDlights(entity, currentTime)
    end if
  end for
  return clDlights
end function

function createEntity(number)
  origin = t.Vec3(0.0, 0.0, 0.0)
  angles = t.Vec3(0.0, 0.0, 0.0)
  entityOrigin = math.copy(origin)
  entityAngles = math.copy(angles)
  messageOrigin = math.copy(origin)
  previousMessageOrigin = math.copy(origin)
  messageAngles = math.copy(angles)
  previousMessageAngles = math.copy(angles)
  baselineOrigin = math.copy(origin)
  baselineAngles = math.copy(angles)
  baseline = [0, 0, 0, 0, baselineOrigin, baselineAngles, 0]
  return t.ClientEntityState(
    number,
    0,
    0,
    0,
    0,
    0,
    entityOrigin,
    entityAngles,
    0.0,
    messageOrigin,
    previousMessageOrigin,
    messageAngles,
    previousMessageAngles,
    true,
    baseline,
    0.0,
  )
end function

function create(player)
  CL_ClearDlights()
  scores = arrayutil.makeEmptyArray(1)
  scores[0] = t.ClientScore("", 0.0, 0, 0)
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
    "player",
    0,
    false,
    scores,
    arrayutil.makeFilledArray(c.MAX_CL_STATS, 0),
    arrayutil.makeFilledArray(32, 0.0),
    0.0,
    0.0,
    0,
    0.0,
    0.0,
    0.0,
    [0.0, 0.0],
    [t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)],
    [t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)],
    "",
    [],
    false,
    false,
    false,
    false,
    arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, ""),
    false,
    0,
    "",
    0,
    0,
    false,
    clStandardQuake,
  )
end function

function CL_SetStandardQuake(client, value)
  global clStandardQuake
  clStandardQuake = value
  client.standardQuake = value
  return value
end function

// CL_ClearState wipes client_state_t while retaining the transport and the
// client_static_t connection/signon fields represented by LocalClient.
function CL_ClearState(client)
  global clRelinkParticleEffects
  client.spawned = false
  client.protocol = c.PROTOCOL_VERSION
  client.maxClients = 1
  client.gameType = c.GAME_COOP
  client.levelName = ""
  client.modelPrecache = [""]
  client.soundPrecache = [""]
  CL_SetModelSyncTypes([c.ST_SYNC])
  client.viewEntity = 0
  client.serverTime = 0.0
  client.time = 0.0
  client.oldTime = 0.0
  client.messageTimes = [0.0, 0.0]
  client.velocitySamples = [
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
  ]
  client.viewAngleSamples = [
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
  ]
  client.messages = []
  client.printLog = []
  client.entities = []
  client.visibleEntities = []
  resetScores(client, 1)
  client.stats = arrayutil.makeFilledArray(c.MAX_CL_STATS, 0)
  client.itemGetTime = arrayutil.makeFilledArray(32, 0.0)
  client.completedTime = 0.0
  client.faceAnimTime = 0.0
  client.items = 0
  client.idealPitch = 0.0
  client.lightStyles = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, "")
  client.paused = false
  client.intermission = 0
  client.intermissionText = ""
  client.cdTrack = 0
  client.loopTrack = 0
  client.sellScreen = false
  clRelinkParticleEffects = []
  sz.clear(client.outgoing)
  sz.clear(client.incoming)
  CL_ClearDlights()
  return true
end function

function clearState(client)
  return CL_ClearState(client)
end function

// CL_NextDemo returns the updated demonum because MiniLang integers are value
// types. The command buffer and demo selection behavior match cl_main.c.
function CL_NextDemo(commands, demos, demoNumber)
  if demoNumber < 0 then return [false, demoNumber] end if
  if len(demos) == 0 then
    print "No demos listed with startdemos"
    return [false, -1]
  end if
  if demoNumber >= len(demos) or demos[demoNumber] == "" then demoNumber = 0 end if
  if demos[demoNumber] == "" then
    print "No demos listed with startdemos"
    return [false, -1]
  end if
  commandBuffer.insertText(commands, "playdemo " + demos[demoNumber] + "\n")
  return [true, demoNumber + 1]
end function

function CL_PrintEntities_f(client)
  lines = []
  index = 0
  while index < len(client.entities)
    entity = client.entities[index]
    prefix = "" + index + ":"
    line = ""
    if entity is void or entity.modelIndex <= 0 or entity.modelIndex >= len(client.modelPrecache) then
      line = prefix + "EMPTY"
    else
      line = prefix + client.modelPrecache[entity.modelIndex] + ":" + entity.frame +
        " (" + entity.origin.x + "," + entity.origin.y + "," + entity.origin.z + ")" +
        " [" + entity.angles.x + " " + entity.angles.y + " " + entity.angles.z + "]"
    end if
    print line
    lines = lines + [line]
    index = index + 1
  end while
  return lines
end function

// The MiniQuake SetPal debug body is compiled out with #if 0.
function inline SetPal(index)
  return false
end function

function resetScores(client, count)
  if count < 1 then count = 1 end if
  client.scores = arrayutil.makeEmptyArray(count)
  index = 0
  while index < count
    client.scores[index] = t.ClientScore("", client.serverTime, 0, 0)
    index = index + 1
  end while
  return client.scores
end function

function validScoreIndex(client, index)
  return index >= 0 and index < len(client.scores)
end function

function ensureEntity(client, number)
  while len(client.entities) <= number
    client.entities = client.entities + [void]
  end while
  if client.entities[number] is void then client.entities[number] = createEntity(number) end if
  return client.entities[number]
end function

function CL_EntityNum(client, number)
  if number < 0 or number >= c.MAX_EDICTS then return error(2910, "CL_EntityNum: " + number + " is an invalid number") end if
  return ensureEntity(client, number)
end function

function CL_NewTranslation(client, slot)
  global clTranslations
  if slot < 0 or slot >= client.maxClients or slot >= len(client.scores) then
    return error(2911, "CL_NewTranslation: slot > cl.maxclients")
  end if
  while len(clTranslations) <= slot
    clTranslations = clTranslations + [void]
  end while
  // scoreboard_t.translations contains every colormap grade in MiniQuake,
  // even though the GL player-skin upload consumes the first grade directly.
  gradeCount = 64
  translation = bytes(256 * gradeCount)
  top = client.scores[slot].colors & 0xf0
  bottom = (client.scores[slot].colors & 15) << 4
  grade = 0
  while grade < gradeCount
    gradeOffset = grade * 256
    index = 0
    while index < 256
      translation[gradeOffset + index] = index
      index = index + 1
    end while
    index = 0
    while index < 16
      if top < 128 then translation[gradeOffset + c.TOP_RANGE + index] = top + index else translation[gradeOffset + c.TOP_RANGE + index] = top + 15 - index end if
      if bottom < 128 then translation[gradeOffset + c.BOTTOM_RANGE + index] = bottom + index else translation[gradeOffset + c.BOTTOM_RANGE + index] = bottom + 15 - index end if
      index = index + 1
    end while
    grade = grade + 1
  end while
  clTranslations[slot] = translation
  return translation
end function

function connect(client, network)
  return CL_EstablishConnection(client, network, "local")
end function

function CL_EstablishConnection(client, network, host)
  global clMoveMessages
  if client.demoPlayback then return false end if
  CL_Disconnect(client)
  CL_ClearDlights()
  socket = netmain.NET_Connect(network, host, 2500)
  if socket is void then return error(2900, "CL_EstablishConnection: connect failed") end if
  if socket is error then return socket end if
  client.socket = socket
  client.connected = true
  // A transport connection is not a protocol signon stage. The original
  // CL_EstablishConnection resets cls.signon to zero and waits for the
  // server's first svc_signonnum before replying with "prespawn".
  client.signon = c.SIGNON_NONE
  client.spawned = false
  client.printLog = []
  clMoveMessages = 0
  if client.player is not void then client.command.viewAngles = math.copy(client.player.viewAngles) end if
  sz.clear(client.outgoing)
  sz.clear(client.incoming)
  return client
end function

function connectHost(client, network, host)
  return CL_EstablishConnection(client, network, host)
end function

function CL_EstablishInteropConnection(client, network, host, timeoutMilliseconds, resendMilliseconds)
  global clMoveMessages
  if client.demoPlayback then return error(2950, "interop connect cannot start during demo playback") end if
  CL_Disconnect(client)
  CL_ClearDlights()
  socket = netmain.NET_ConnectInterop(network, host, timeoutMilliseconds, resendMilliseconds)
  if socket is void then return error(2951, "CL_EstablishInteropConnection: connect failed") end if
  if socket is error then return socket end if
  client.socket = socket
  client.connected = true
  client.signon = c.SIGNON_NONE
  client.spawned = false
  client.printLog = []
  clMoveMessages = 0
  if client.player is not void then client.command.viewAngles = math.copy(client.player.viewAngles) end if
  sz.clear(client.outgoing)
  sz.clear(client.incoming)
  return client
end function

function connectHostInterop(client, network, host, timeoutMilliseconds, resendMilliseconds)
  return CL_EstablishInteropConnection(client, network, host, timeoutMilliseconds, resendMilliseconds)
end function

function CL_KeepaliveMessage(client, localServerActive, realtime)
  global clKeepaliveLastMessage
  if localServerActive or client.demoPlayback or not client.connected or client.socket is void then return false end if

  saved = sz.dataSlice(client.incoming)
  result = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  while result != 0
    if result == -1 then return error(2912, "CL_KeepaliveMessage: CL_GetMessage failed") end if
    if result == 1 then return error(2913, "CL_KeepaliveMessage: received a message") end if
    payload = sz.dataSlice(client.incoming)
    if len(payload) != 1 or payload[0] != c.SVC_NOP then return error(2914, "CL_KeepaliveMessage: datagram wasn't a nop") end if
    result = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  end while
  sz.clear(client.incoming)
  sz.writeBytes(client.incoming, saved)

  if realtime - clKeepaliveLastMessage < 5.0 then return false end if
  clKeepaliveLastMessage = realtime
  sz.clear(client.outgoing)
  msg.writeByte(client.outgoing, c.CLC_NOP)
  sent = netmain.NET_SendMessage(client.socket, client.outgoing)
  sz.clear(client.outgoing)
  if sent == -1 then return error(2915, "CL_KeepaliveMessage: lost server connection") end if
  return sent == 1
end function

function reconnect(client)
  global clMoveMessages
  if not client.connected or client.socket is void or client.socket.disconnected then return false end if
  client.signon = c.SIGNON_NONE
  client.spawned = false
  clMoveMessages = 0
  sz.clear(client.outgoing)
  sz.clear(client.incoming)
  return true
end function

function CL_Disconnect(client)
  global clMoveMessages
  if client.demoPlayback then
    client.demoPlayback = false
  else if client.connected and client.socket is not void then
    buffer = sz.alloc(16)
    writer.writeDisconnect(buffer)
    netmain.NET_SendUnreliableMessage(client.socket, buffer)
    netmain.NET_Close(client.socket)
  end if
  client.socket = void
  client.connected = false
  client.spawned = false
  client.signon = c.SIGNON_NONE
  client.demoPlayback = false
  client.timedemo = false
  clMoveMessages = 0
  sz.clear(client.outgoing)
  return true
end function

function disconnect(client)
  return CL_Disconnect(client)
end function

function CL_Disconnect_f(client)
  global clDisconnectRequestedServerShutdown
  clDisconnectRequestedServerShutdown = true
  return CL_Disconnect(client)
end function

function CL_ServerShutdownRequested()
  global clDisconnectRequestedServerShutdown
  return clDisconnectRequestedServerShutdown
end function

function dropConnection(client)
  global clMoveMessages
  if client.socket is not void then netmain.NET_Close(client.socket) end if
  client.socket = void
  client.connected = false
  client.spawned = false
  client.signon = c.SIGNON_NONE
  clMoveMessages = 0
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
  if not netmain.NET_CanSendMessage(client.socket) then return 0 end if
  result = netmain.NET_SendMessage(client.socket, client.outgoing)
  if delivery.clearAfterSend(result) then sz.clear(client.outgoing) end if
  return result
end function

function sendString(client, text)
  queued = queueString(client, text)
  if queued < 0 then return queued end if
  return sendReliable(client)
end function

function sendMove(client, command)
  global clMoveMessages
  if not client.spawned then return 0 end if

  // cl.cmd = *cmd: retain an independent copy for rendering/demo state.
  client.command.viewAngles = math.copy(command.viewAngles)
  client.command.forwardMove = command.forwardMove
  client.command.sideMove = command.sideMove
  client.command.upMove = command.upMove
  client.command.buttons = command.buttons
  client.command.impulse = command.impulse
  client.command.msec = command.msec

  // CL_SendMove still snapshots and consumes the completed command during
  // demo playback, but never advances movemessages or touches the network.
  if client.demoPlayback then return 0 end if
  if not client.connected or client.socket is void then return 0 end if

  buffer = sz.alloc(64)
  writer.writeMove(buffer, command, client.serverTime)
  // CL_SendMove always discards the first two post-connect commands because
  // they may contain input left over from the previous level.
  clMoveMessages = clMoveMessages + 1
  if clMoveMessages <= 2 then return 0 end if
  result = netmain.NET_SendUnreliableMessage(client.socket, buffer)
  if result == -1 then
    print "CL_SendMove: lost server connection"
    dropConnection(client)
  end if
  return result
end function

function CL_SendMove(client, command)
  return sendMove(client, command)
end function

function applyBaseline(client, number, baseline)
  entity = CL_EntityNum(client, number)
  if entity is error then return entity end if
  previousModelIndex = entity.modelIndex
  entity.baseline = [
    baseline[0],
    baseline[1],
    baseline[2],
    baseline[3],
    math.copy(baseline[4]),
    math.copy(baseline[5]),
    0,
  ]
  entity.modelIndex = baseline[0]
  entity.frame = baseline[1]
  entity.colormap = baseline[2]
  entity.skin = baseline[3]
  entity.origin = math.copy(baseline[4])
  entity.angles = math.copy(baseline[5])
  entity.messageOrigin = math.copy(baseline[4])
  entity.previousMessageOrigin = math.copy(baseline[4])
  entity.messageAngles = math.copy(baseline[5])
  entity.previousMessageAngles = math.copy(baseline[5])
  entity.forceLink = true
  CL_AssignModelSyncBase(entity, previousModelIndex)
  return entity
end function

function applyFastUpdate(client, payload)
  number = payload[0]
  entity = CL_EntityNum(client, number)
  if entity is error then return entity end if
  previousModelIndex = entity.modelIndex
  forceLink = entity.forceLink or entity.messageTime != client.messageTimes[1]
  entity.previousMessageOrigin = math.copy(entity.messageOrigin)
  entity.previousMessageAngles = math.copy(entity.messageAngles)
  entity.messageOrigin = math.copy(entity.baseline[4])
  entity.messageAngles = math.copy(entity.baseline[5])
  entity.modelIndex = entity.baseline[0]
  entity.frame = entity.baseline[1]
  entity.colormap = entity.baseline[2]
  entity.skin = entity.baseline[3]
  entity.effects = entity.baseline[6]
  if payload[2] is not void then entity.modelIndex = payload[2] end if
  if payload[3] is not void then entity.frame = payload[3] end if
  if payload[4] is not void then entity.colormap = payload[4] end if
  if payload[5] is not void then entity.skin = payload[5] end if
  if payload[6] is not void then entity.effects = payload[6] end if
  if entity.modelIndex < 0 or entity.modelIndex >= c.MAX_MODELS then
    return error(2916, "CL_ParseModel: bad modnum " + entity.modelIndex)
  end if
  if entity.colormap < 0 or entity.colormap > client.maxClients then
    return error(2917, "CL_ParseUpdate: colormap > maxclients")
  end if
  CL_AssignModelSyncBase(entity, previousModelIndex)
  origin = payload[7]
  angles = payload[8]
  if origin[0] is not void then entity.messageOrigin.x = origin[0] end if
  if origin[1] is not void then entity.messageOrigin.y = origin[1] end if
  if origin[2] is not void then entity.messageOrigin.z = origin[2] end if
  if angles[0] is not void then entity.messageAngles.x = angles[0] end if
  if angles[1] is not void then entity.messageAngles.y = angles[1] end if
  if angles[2] is not void then entity.messageAngles.z = angles[2] end if
  if (payload[1] & c.U_NOLERP) != 0 then forceLink = true end if
  if forceLink then
    entity.previousMessageOrigin = math.copy(entity.messageOrigin)
    entity.previousMessageAngles = math.copy(entity.messageAngles)
  end if
  // Preserve the existing packet-level API: CL_RelinkEntities may replace
  // these with interpolated coordinates later in the frame.
  entity.origin = math.copy(entity.messageOrigin)
  entity.angles = math.copy(entity.messageAngles)
  entity.messageTime = client.serverTime
  entity.forceLink = forceLink
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
  return CL_SignonReply(client)
end function

function CL_SignonReply(client)
  if client.signon == c.SIGNON_ACTIVE then
    client.spawned = true
    return true
  end if
  if not client.connected or client.socket is void then return false end if
  protocolSignon.writeClientReply(
    client.outgoing,
    client.signon,
    client.name,
    client.colors,
    client.spawnParms,
  )
  // CL_SignonReply only appends to cls.message. CL_SendCmd performs the
  // reliable transport phase on the following host frame. Keeping that
  // boundary is observable when a socket is temporarily blocked and avoids
  // sending a reply from inside CL_ParseServerMessage.
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
    if payload[1] < 1 or payload[1] > c.MAX_CLIENTS then return error(2918, "Bad maxclients from server") end if
    // CL_ParseServerMessage executes svc_print immediately.  MiniQuake
    // defers protocol side effects until the host consumes this event list,
    // so retain events which appeared before serverinfo in the same packet
    // while clearing the old level state.
    pendingMessages = client.messages
    pendingPrintLog = client.printLog
    CL_ClearState(client)
    client.messages = pendingMessages
    client.printLog = pendingPrintLog
    client.maxClients = payload[1]
    client.gameType = payload[2]
    client.levelName = payload[3]
    client.modelPrecache = [""] + payload[4]
    client.soundPrecache = [""] + payload[5]
    client.entities = []
    resetScores(client, client.maxClients)
    client.stats = arrayutil.makeFilledArray(c.MAX_CL_STATS, 0)
    client.itemGetTime = arrayutil.makeFilledArray(32, 0.0)
    client.items = 0
    world = CL_EntityNum(client, 0)
    if world is error then return world end if
    if len(client.modelPrecache) > 1 then world.modelIndex = 1 end if
  else if name == "svc_updatename" then
    if not validScoreIndex(client, payload[0]) then return error(2919, "svc_updatename > MAX_SCOREBOARD") end if
    statusbar.Sbar_Changed()
    client.scores[payload[0]].name = payload[1]
  else if name == "svc_updatefrags" then
    if not validScoreIndex(client, payload[0]) then return error(2920, "svc_updatefrags > MAX_SCOREBOARD") end if
    statusbar.Sbar_Changed()
    client.scores[payload[0]].frags = payload[1]
  else if name == "svc_updatecolors" then
    if not validScoreIndex(client, payload[0]) then return error(2921, "svc_updatecolors > MAX_SCOREBOARD") end if
    statusbar.Sbar_Changed()
    client.scores[payload[0]].colors = payload[1]
    translated = CL_NewTranslation(client, payload[0])
    if translated is error then return translated end if
  else if name == "svc_updatestat" then
    if payload[0] < 0 or payload[0] >= len(client.stats) then return error(2922, "svc_updatestat: invalid index " + payload[0]) end if
    if client.stats[payload[0]] != payload[1] then statusbar.Sbar_Changed() end if
    client.stats[payload[0]] = payload[1]
  else if name == "svc_setview" then
    viewEntity = CL_EntityNum(client, payload)
    if viewEntity is error then return viewEntity end if
    client.viewEntity = payload
  else if name == "svc_setangle" then
    client.viewAngleSamples[1] = math.copy(client.viewAngleSamples[0])
    client.viewAngleSamples[0] = math.copy(payload)
    client.command.viewAngles = math.copy(payload)
    if client.player is not void then
      client.player.viewAngles = math.copy(payload)
      client.player.renderAngles = math.copy(payload)
    end if
  else if name == "svc_time" then
    client.messageTimes[1] = client.messageTimes[0]
    client.messageTimes[0] = payload
    client.serverTime = payload
  else if name == "svc_lightstyle" then
    if payload[0] < 0 or payload[0] >= c.MAX_LIGHTSTYLES then return error(2923, "svc_lightstyle > MAX_LIGHTSTYLES") end if
    client.lightStyles[payload[0]] = payload[1]
  else if name == "svc_print" then
    client.printLog = client.printLog + [payload]
    client.messages = client.messages + [item]
  else if name == "svc_centerprint" then
    client.messages = client.messages + [item]
  else if name == "svc_damage" then
    // V_ParseDamage keys the face animation to cl.time, not the newest
    // server-message timestamp.  They differ during interpolation and demos.
    client.faceAnimTime = client.time + 0.2
    client.messages = client.messages + [item]
  else if name == "svc_sound" then
    soundIndex = payload[4]
    if soundIndex < 0 or soundIndex >= len(client.soundPrecache) then return error(2924, "svc_sound: bad sound index " + soundIndex) end if
    client.messages = client.messages + [item]
  else if name == "svc_spawnstaticsound" then
    soundIndex = payload[1]
    if soundIndex < 0 or soundIndex >= len(client.soundPrecache) then return error(2925, "svc_spawnstaticsound: bad sound index " + soundIndex) end if
    client.messages = client.messages + [item]
  else if name == "svc_stopsound" or name == "svc_particle" or name == "svc_temp_entity" or name == "svc_stufftext" then
    client.messages = client.messages + [item]
  else if name == "svc_signonnum" then
    return advanceSignon(client, payload)
  else if name == "svc_spawnbaseline" then
    baselineEntity = applyBaseline(client, payload[0], payload[1])
    if baselineEntity is error then return baselineEntity end if
  else if name == "svc_spawnstatic" then
    number = len(client.entities)
    staticCount = 0
    for each candidate in client.entities
      if candidate is not void and candidate.messageTime < 0.0 then staticCount = staticCount + 1 end if
    end for
    if staticCount >= c.MAX_STATIC_ENTITIES then return error(2926, "Too many static entities") end if
    staticEntity = applyBaseline(client, number, payload)
    if staticEntity is error then return staticEntity end if
    staticEntity.messageTime = -1.0
    staticEntity.forceLink = false
  else if name == "fast_update" then
    // MiniQuake promotes signon 3 to 4 on the first entity update. The server
    // never emits svc_signonnum 4 on the original demo/network path.
    if client.signon == c.SIGNON_SPAWN then
      signedOn = try(advanceSignon(client, c.SIGNON_ACTIVE))
      if signedOn is error then return signedOn end if
    end if
    updated = applyFastUpdate(client, payload)
    if updated is error then return updated end if
  else if name == "svc_clientdata" then
    changedItems = client.items ^ payload[5]
    if changedItems != 0 then statusbar.Sbar_Changed() end if
    client.items = payload[5]
    itemIndex = 0
    while itemIndex < 32
      if (changedItems & (1 << itemIndex)) != 0 and (client.items & (1 << itemIndex)) != 0 then client.itemGetTime[itemIndex] = client.time end if
      itemIndex = itemIndex + 1
    end while
    if client.stats[c.STAT_HEALTH] != payload[9] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_WEAPON] != payload[8] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_AMMO] != payload[10] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_ARMOR] != payload[7] then statusbar.Sbar_Changed() end if
    client.stats[c.STAT_HEALTH] = payload[9]
    client.stats[c.STAT_WEAPON] = payload[8]
    client.stats[c.STAT_AMMO] = payload[10]
    client.stats[c.STAT_ARMOR] = payload[7]
    client.stats[c.STAT_WEAPONFRAME] = payload[6]
    if client.stats[c.STAT_SHELLS] != payload[11] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_NAILS] != payload[12] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_ROCKETS] != payload[13] then statusbar.Sbar_Changed() end if
    if client.stats[c.STAT_CELLS] != payload[14] then statusbar.Sbar_Changed() end if
    client.stats[c.STAT_SHELLS] = payload[11]
    client.stats[c.STAT_NAILS] = payload[12]
    client.stats[c.STAT_ROCKETS] = payload[13]
    client.stats[c.STAT_CELLS] = payload[14]
    if client.standardQuake then
      if client.stats[c.STAT_ACTIVEWEAPON] != payload[15] then statusbar.Sbar_Changed() end if
      client.stats[c.STAT_ACTIVEWEAPON] = payload[15]
    else
      if client.stats[c.STAT_ACTIVEWEAPON] != (1 << payload[15]) then statusbar.Sbar_Changed() end if
      client.stats[c.STAT_ACTIVEWEAPON] = 1 << payload[15]
    end if
    client.idealPitch = 0.0
    if payload[2] is not void then client.idealPitch = payload[2] end if
    sampledVelocity = t.Vec3(0.0, 0.0, 0.0)
    if payload[4][0] is not void then sampledVelocity.x = payload[4][0] end if
    if payload[4][1] is not void then sampledVelocity.y = payload[4][1] end if
    if payload[4][2] is not void then sampledVelocity.z = payload[4][2] end if
    client.velocitySamples[1] = math.copy(client.velocitySamples[0])
    client.velocitySamples[0] = sampledVelocity
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
      client.player.activeWeapon = client.stats[c.STAT_ACTIVEWEAPON]
    end if
  else if name == "svc_killedmonster" then
    client.stats[c.STAT_MONSTERS] = client.stats[c.STAT_MONSTERS] + 1
    client.messages = client.messages + [item]
  else if name == "svc_foundsecret" then
    client.stats[c.STAT_SECRETS] = client.stats[c.STAT_SECRETS] + 1
    client.messages = client.messages + [item]
  else if name == "svc_intermission" then
    client.intermission = 1
    client.intermissionText = ""
    client.completedTime = client.time
    client.messages = client.messages + [item]
  else if name == "svc_finale" then
    client.intermission = 2
    client.intermissionText = payload
    client.completedTime = client.time
    client.messages = client.messages + [item]
  else if name == "svc_cutscene" then
    client.intermission = 3
    client.intermissionText = payload
    client.completedTime = client.time
    client.messages = client.messages + [item]
  else if name == "svc_setpause" then
    client.paused = payload != 0
    client.messages = client.messages + [item]
  else if name == "svc_cdtrack" then
    client.cdTrack = payload[0]
    client.loopTrack = payload[1]
    client.messages = client.messages + [item]
  else if name == "svc_sellscreen" then
    client.sellScreen = true
    client.messages = client.messages + [item]
  else if name == "svc_disconnect" then
    client.connected = false
    client.spawned = false
    client.signon = c.SIGNON_NONE
    if not client.demoPlayback then return error(2927, "Server disconnected") end if
  else
    client.messages = client.messages + [item]
  end if
  return true
end function

function parseMessage(client, data)
  result = try(protocol.CL_ParseServerMessage(data))
  if result is error then return result end if
  for each item in result.events
    applied = try(applyEvent(client, item))
    if applied is error then return applied end if
  end for
  return len(result.events)
end function

function readNetworkMessages(client, realtime)
  if not client.connected or client.socket is void then return 0 end if
  processed = 0
  messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  while messageType > 0
    payload = sz.dataSlice(client.incoming)
    // CL_GetMessage consumes isolated svc_nop keepalives internally.  They
    // are neither returned to CL_ParseServerMessage nor written to demos.
    if demo.isKeepalivePayload(payload) then
      messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
      continue
    end if
    // CL_ParseServerMessage aborts the host on an illegible or truncated
    // server message.  Do not discard the error object here: this is the
    // production network path, not merely the direct parser API exercised by
    // the protocol fixtures.
    parsed = try(parseMessage(client, payload))
    if parsed is error then return parsed end if
    if realtime < 0.0 then client.lastMessageTime = client.serverTime else client.lastMessageTime = realtime end if
    processed = processed + 1
    messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  end while
  if messageType == -1 then return error(2905, "CL_ReadFromServer: lost server connection") end if
  return processed
end function

function pump(client)
  return readNetworkMessages(client, -1.0)
end function

function pumpRecording(client, recording)
  if not client.connected or client.socket is void then return 0 end if
  processed = 0
  messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  while messageType > 0
    payload = sz.dataSlice(client.incoming)
    // The original CL_GetMessage loops until a non-keepalive packet arrives.
    if demo.isKeepalivePayload(payload) then
      messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
      continue
    end if
    written = demo.CL_WriteDemoMessage(recording, payload, client.command.viewAngles)
    if written is error then return written end if
    parsed = try(parseMessage(client, payload))
    if parsed is error then return parsed end if
    client.lastMessageTime = client.serverTime
    processed = processed + 1
    messageType = netmain.NET_GetMessage(client.socket, client.incoming, netmain.net_messagetimeout)
  end while
  if messageType == -1 then return error(2905, "CL_ReadFromServer: lost server connection") end if
  return processed
end function

function CL_ReadFromServer(client, frameTime, realtime)
  client.oldTime = client.time
  client.time = client.time + frameTime
  result = readNetworkMessages(client, realtime)
  if result is error then return result end if
  CL_RelinkEntities(client)
  return 0
end function

function CL_SendCmd(client, command)
  if not client.connected and not client.demoPlayback then return 0 end if
  moveResult = 0
  if client.signon == c.SIGNONS then moveResult = sendMove(client, command) end if
  if client.demoPlayback then
    sz.clear(client.outgoing)
    return moveResult
  end if
  reliableResult = sendReliable(client)
  if reliableResult == -1 then return error(2906, "CL_WriteToServer: lost server connection") end if
  return reliableResult
end function

function clientCommandExists(name)
  return false
end function

function ensureClientCvar(registry, name, value, archive)
  existing = cvar.find(registry, name)
  if existing is not void then return existing end if
  return cvar.register(registry, cvar.create(name, value, archive, false), clientCommandExists)
end function

function CL_Init(client, registry)
  global clMoveMessages, clRegisteredCommands
  client.outgoing = sz.alloc(1024)
  ensureClientCvar(registry, "_cl_name", "player", true)
  ensureClientCvar(registry, "_cl_color", "0", true)
  ensureClientCvar(registry, "cl_upspeed", "200", false)
  ensureClientCvar(registry, "cl_forwardspeed", "200", true)
  ensureClientCvar(registry, "cl_backspeed", "200", true)
  ensureClientCvar(registry, "cl_sidespeed", "350", false)
  ensureClientCvar(registry, "cl_movespeedkey", "2.0", false)
  ensureClientCvar(registry, "cl_yawspeed", "140", false)
  ensureClientCvar(registry, "cl_pitchspeed", "150", false)
  ensureClientCvar(registry, "cl_anglespeedkey", "1.5", false)
  ensureClientCvar(registry, "cl_shownet", "0", false)
  ensureClientCvar(registry, "cl_nolerp", "0", false)
  ensureClientCvar(registry, "lookspring", "0", true)
  ensureClientCvar(registry, "lookstrafe", "0", true)
  ensureClientCvar(registry, "sensitivity", "3", true)
  ensureClientCvar(registry, "m_pitch", "0.022", true)
  ensureClientCvar(registry, "m_yaw", "0.022", true)
  ensureClientCvar(registry, "m_forward", "1", true)
  ensureClientCvar(registry, "m_side", "0.8", true)
  clRegisteredCommands = ["entities", "disconnect", "record", "stop", "playdemo", "timedemo"]
  CL_ClearDlights()
  clMoveMessages = 0
  client.initialized = true
  return true
end function

function CL_RegisteredCommands()
  global clRegisteredCommands
  return clRegisteredCommands
end function

function CL_MoveMessageCount()
  global clMoveMessages
  return clMoveMessages
end function

function CL_SetMoveMessageCount(value)
  global clMoveMessages
  clMoveMessages = value
  return clMoveMessages
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
