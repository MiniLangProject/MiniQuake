package miniquake.quakec.builtins

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.mathlib as math
import miniquake.message as msg
import miniquake.protocol_events as protocolEvents
import miniquake.protocol_transients as transients
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.filesystem as filesystem
import miniquake.byteio as bio
import miniquake.format.sprite as sprite
import miniquake.world_bsp as world
import miniquake.server_collision as collision
import miniquake.server_move as serverMove
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as qvm
import miniquake.quakec.edict as qcedict

const BUILTIN_COUNT = 79
const FNV_OFFSET = 2166136261
const FNV_PRIME = 16777619

activeContext = void

function bind(contextValue)
  global activeContext
  activeContext = contextValue
  return contextValue
end function

function context()
  global activeContext
  return activeContext
end function

function ensureGlobal(machine, offset)
  return qvm.ensureGlobal(machine, offset)
end function

function word(machine, offset)
  ensureGlobal(machine, offset)
  return machine.globals[offset]
end function

function setWord(machine, offset, value)
  ensureGlobal(machine, offset)
  machine.globals[offset] = value & 0xffffffff
  return value
end function

function floatValue(machine, offset)
  return native.bitsFloat(word(machine, offset))
end function

function setFloat(machine, offset, value)
  if value is bool then
    if value then value = 1.0 else value = 0.0 end if
  end if
  return setWord(machine, offset, native.floatBits(value))
end function

function vectorValue(machine, offset)
  return t.Vec3(floatValue(machine, offset), floatValue(machine, offset + 1), floatValue(machine, offset + 2))
end function

function setVectorValue(machine, offset, value)
  setFloat(machine, offset, value.x)
  setFloat(machine, offset + 1, value.y)
  setFloat(machine, offset + 2, value.z)
end function

function parameterOffset(index)
  return op.OFS_PARM0 + index * 3
end function

function parmWord(machine, index)
  return word(machine, parameterOffset(index))
end function

function parmFloat(machine, index)
  return floatValue(machine, parameterOffset(index))
end function

function parmVector(machine, index)
  return vectorValue(machine, parameterOffset(index))
end function

function stringAt(machine, handle)
  return qvm.stringValue(machine, handle)
end function

function parmString(machine, index)
  return stringAt(machine, parmWord(machine, index))
end function

function varString(machine, first)
  text = ""
  index = first
  while index < machine.argCount
    text = text + parmString(machine, index)
    index = index + 1
  end while
  return text
end function

function internString(machine, text)
  return qvm.internString(machine, text)
end function

function returnWord(machine, value)
  setWord(machine, op.OFS_RETURN, value)
  setWord(machine, op.OFS_RETURN + 1, 0)
  setWord(machine, op.OFS_RETURN + 2, 0)
end function

function returnFloat(machine, value)
  setFloat(machine, op.OFS_RETURN, value)
  setWord(machine, op.OFS_RETURN + 1, 0)
  setWord(machine, op.OFS_RETURN + 2, 0)
end function

function returnVector(machine, value)
  setVectorValue(machine, op.OFS_RETURN, value)
end function

function returnString(machine, text)
  returnWord(machine, internString(machine, text))
end function

function returnTemporaryString(machine, text)
  returnWord(machine, qvm.setTemporaryString(machine, text))
end function

function definitionOffset(definitions, name)
  for each definition in definitions
    if definition.name == name then return definition.offset end if
  end for
  return -1
end function

function globalOffset(machine, name)
  return definitionOffset(machine.program.globalDefs, name)
end function

function fieldOffset(machine, name)
  return definitionOffset(machine.program.fieldDefs, name)
end function

function globalWord(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return 0 end if
  return word(machine, offset)
end function

function globalVector(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return t.Vec3(0.0, 0.0, 0.0) end if
  return vectorValue(machine, offset)
end function

function setGlobalWord(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setWord(machine, offset, value)
  return true
end function

function setGlobalFloat(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setFloat(machine, offset, value)
  return true
end function

function setGlobalVector(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setVectorValue(machine, offset, value)
  return true
end function

function entityWord(machine, entityIndex, name)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return 0 end if
  return machine.edicts[entityIndex][offset]
end function

function setEntityWord(machine, entityIndex, name, value)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return false end if
  machine.edicts[entityIndex][offset] = value & 0xffffffff
  return true
end function

function entityFloat(machine, entityIndex, name)
  return native.bitsFloat(entityWord(machine, entityIndex, name))
end function

function setEntityFloat(machine, entityIndex, name, value)
  return setEntityWord(machine, entityIndex, name, native.floatBits(value))
end function

function entityVector(machine, entityIndex, name)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return t.Vec3(0.0, 0.0, 0.0) end if
  return t.Vec3(native.bitsFloat(machine.edicts[entityIndex][offset]), native.bitsFloat(machine.edicts[entityIndex][offset + 1]), native.bitsFloat(machine.edicts[entityIndex][offset + 2]))
end function

function setEntityVector(machine, entityIndex, name, value)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return false end if
  machine.edicts[entityIndex][offset] = native.floatBits(value.x)
  machine.edicts[entityIndex][offset + 1] = native.floatBits(value.y)
  machine.edicts[entityIndex][offset + 2] = native.floatBits(value.z)
  return true
end function

function entityString(machine, entityIndex, name)
  return stringAt(machine, entityWord(machine, entityIndex, name))
end function

function updateBounds(machine, entityIndex)
  origin = entityVector(machine, entityIndex, "origin")
  mins = entityVector(machine, entityIndex, "mins")
  maxs = entityVector(machine, entityIndex, "maxs")
  absMin = math.add(origin, mins)
  absMax = math.add(origin, maxs)
  flags = native.trunc(entityFloat(machine, entityIndex, "flags"))
  if (flags & c.FL_ITEM) != 0 then
    absMin.x = absMin.x - 15.0
    absMin.y = absMin.y - 15.0
    absMax.x = absMax.x + 15.0
    absMax.y = absMax.y + 15.0
  else
    absMin.x = absMin.x - 1.0
    absMin.y = absMin.y - 1.0
    absMin.z = absMin.z - 1.0
    absMax.x = absMax.x + 1.0
    absMax.y = absMax.y + 1.0
    absMax.z = absMax.z + 1.0
  end if
  setEntityVector(machine, entityIndex, "absmin", absMin)
  setEntityVector(machine, entityIndex, "absmax", absMax)
  setEntityVector(machine, entityIndex, "size", math.subtract(maxs, mins))
  if machine.context is not void and machine.context.server is not void then
    collision.linkEntity(machine.context.server, entityIndex, false)
  end if
end function

function setMinMaxSize(machine, entityIndex, mins, maxs, rotate)
  if mins.x > maxs.x or mins.y > maxs.y or mins.z > maxs.z then return error(2652, "PF_setsize: backwards mins/maxs") end if
  // GLQuake's SetMinMaxSize forcibly disables rotation despite accepting the
  // parameter, so the stored axis-aligned bounds are always the input bounds.
  setEntityVector(machine, entityIndex, "mins", mins)
  setEntityVector(machine, entityIndex, "maxs", maxs)
  updateBounds(machine, entityIndex)
  return true
end function

function modelBounds(machine, modelName)
  ctx = context()
  zero = t.Vec3(0.0, 0.0, 0.0)
  nameData = bytes(modelName)
  if len(nameData) > 1 and nameData[0] == 42 and ctx.worldMap is not void then
    submodel = toNumber(decode(slice(nameData, 1, len(nameData) - 1)))
    if submodel is not void and submodel >= 0 and submodel < len(ctx.worldMap.models) then
      model = ctx.worldMap.models[submodel]
      return [model.mins, model.maxs]
    end if
    return [zero, zero]
  end if
  lower = bio.lower(modelName)
  lowerData = bytes(lower)
  if len(lowerData) >= 4 then
    suffix = decode(slice(lowerData, len(lowerData) - 4, 4))
    // Mod_LoadAliasModel in GLQuake explicitly uses this fixed FIXME box.
    if suffix == ".mdl" then
      return [t.Vec3(-16.0, -16.0, -16.0), t.Vec3(16.0, 16.0, 16.0)]
    end if
    if suffix == ".spr" then
      if ctx.filesystem is void then return error(2668, "PF_setmodel: no filesystem for " + modelName) end if
      data = filesystem.readFile(ctx.filesystem, modelName)
      model = sprite.parse(data, modelName)
      return sprite.spriteModelBounds(model)
    end if
  end if
  return [zero, zero]
end function

function allocateEdict(machine)
  ctx = context()
  first = 1
  if ctx is not void and ctx.server is not void then
    first = ctx.server.maxClients + 1
  end if
  return qcedict.allocate(machine, first)
end function

function releaseEdict(machine, entityIndex)
  return qcedict.free(machine, entityIndex)
end function

function precacheIndex(values, name)
  index = 0
  while index < len(values)
    if values[index] == name then return index end if
    index = index + 1
  end while
  return -1
end function

function activeEdictLimit(machine)
  ctx = context()
  if ctx is not void and ctx.edicts is not void then return ctx.edicts.numEdicts end if
  return len(machine.edicts)
end function

function badPrecacheString(name)
  data = bytes(name)
  return len(data) == 0 or data[0] <= 32
end function

function appendConsole(text)
  ctx = context()
  ctx.consoleLines = ctx.consoleLines + [text]
end function

function fixme(machine)
  return error(2650, "unimplemented bulitin")
end function

function makeVectors(machine)
  vectors = math.angleVectors(parmVector(machine, 0))
  setGlobalVector(machine, "v_forward", vectors[0])
  setGlobalVector(machine, "v_right", vectors[1])
  setGlobalVector(machine, "v_up", vectors[2])
  return true
end function

function setOrigin(machine)
  entityIndex = parmWord(machine, 0)
  setEntityVector(machine, entityIndex, "origin", parmVector(machine, 1))
  updateBounds(machine, entityIndex)
  return true
end function

function setModel(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  modelName = parmString(machine, 1)
  modelIndex = precacheIndex(ctx.modelPrecache, modelName)
  if modelIndex < 0 then return error(2651, "PF_setmodel: no precache for " + modelName) end if
  setEntityWord(machine, entityIndex, "model", parmWord(machine, 1))
  setEntityFloat(machine, entityIndex, "modelindex", modelIndex)
  bounds = modelBounds(machine, modelName)
  setMinMaxSize(machine, entityIndex, bounds[0], bounds[1], true)
  return true
end function

function setSize(machine)
  entityIndex = parmWord(machine, 0)
  mins = parmVector(machine, 1)
  maxs = parmVector(machine, 2)
  return setMinMaxSize(machine, entityIndex, mins, maxs, false)
end function

function breakBuiltin(machine)
  appendConsole("break statement")
  // The C builtin deliberately writes through address -4 to break into a
  // debugger.  MiniLang cannot reproduce memory corruption, but it must still
  // abort QuakeC execution instead of returning to the calling mod.
  return error(2670, "break statement")
end function

function randomBuiltin(machine)
  ctx = context()
  // WinQuake used the Microsoft C runtime rand() state.  Keep the state on
  // the VM as the context-independent authority and mirror it into the host
  // context used by the integrated server.
  seed = machine.randomSeed
  if ctx is not void then seed = ctx.randomSeed end if
  seed = (seed * 214013 + 2531011) & 0xffffffff
  machine.randomSeed = seed
  if ctx is not void then ctx.randomSeed = seed end if
  value = (seed >> 16) & 0x7fff
  returnFloat(machine, value / 32767.0)
  return true
end function

function soundBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  channel = transients.quakeCSoundChannel(parmFloat(machine, 1))
  sample = parmString(machine, 2)
  volumeByte = transients.quakeCSoundVolumeByte(parmFloat(machine, 3))
  attenuation = transients.quakeCSoundAttenuation(parmFloat(machine, 4))
  if channel < 0 or channel > 7 then return error(2660, "SV_StartSound: bad channel " + channel) end if
  if volumeByte < 0 or volumeByte > 255 then return error(2661, "SV_StartSound: bad volume " + volumeByte) end if
  if attenuation < 0.0 or attenuation > 4.0 then return error(2662, "SV_StartSound: bad attenuation " + attenuation) end if
  ctx.soundEvents = ctx.soundEvents + [[entityIndex, channel, sample, volumeByte, attenuation]]
  return true
end function

function normalizeBuiltin(machine)
  returnVector(machine, math.normalize(parmVector(machine, 0)))
  return true
end function

function errorBuiltin(machine)
  text = varString(machine, 0)
  appendConsole("======SERVER ERROR: " + text)
  appendConsole(qcedict.ED_Print(machine, globalWord(machine, "self")))
  return error(2653, "QuakeC error: " + text)
end function

function objectErrorBuiltin(machine)
  selfIndex = globalWord(machine, "self")
  text = varString(machine, 0)
  appendConsole("======OBJECT ERROR: " + text)
  appendConsole(qcedict.ED_Print(machine, selfIndex))
  releaseEdict(machine, selfIndex)
  return error(2654, "QuakeC object error: " + text)
end function

function vectorLengthBuiltin(machine)
  returnFloat(machine, math.length(parmVector(machine, 0)))
  return true
end function

function vectorYawBuiltin(machine)
  value = parmVector(machine, 0)
  yaw = 0.0
  if value.x != 0.0 or value.y != 0.0 then
    yaw = native.trunc(math.atan2(value.y, value.x) * math.RAD_TO_DEG)
    if yaw < 0.0 then yaw = yaw + 360.0 end if
  end if
  returnFloat(machine, yaw)
  return true
end function

function spawnBuiltin(machine)
  entityIndex = allocateEdict(machine)
  returnWord(machine, entityIndex)
  return true
end function

function removeBuiltin(machine)
  return releaseEdict(machine, parmWord(machine, 0))
end function

function setTraceGlobals(machine, trace)
  setGlobalFloat(machine, "trace_allsolid", trace.allSolid)
  setGlobalFloat(machine, "trace_startsolid", trace.startSolid)
  setGlobalFloat(machine, "trace_fraction", trace.fraction)
  setGlobalVector(machine, "trace_endpos", trace.endPosition)
  setGlobalVector(machine, "trace_plane_normal", trace.plane.normal)
  setGlobalFloat(machine, "trace_plane_dist", trace.plane.dist)
  setGlobalWord(machine, "trace_ent", trace.entity)
  setGlobalFloat(machine, "trace_inopen", trace.inOpen)
  setGlobalFloat(machine, "trace_inwater", trace.inWater)
end function

function traceLineBuiltin(machine)
  ctx = context()
  moveType = c.MOVE_NORMAL
  if parmFloat(machine, 2) != 0.0 then moveType = c.MOVE_NOMONSTERS end if
  passedEntity = parmWord(machine, 3)
  zero = t.Vec3(0.0, 0.0, 0.0)
  if ctx.server is void and ctx.worldMap is void then
    plane = t.Plane(t.Vec3(0.0, 0.0, 0.0), 0.0, 0, 0)
    setTraceGlobals(machine, t.Trace(false, false, true, false, 1.0, parmVector(machine, 1), plane, 0))
  else if ctx.server is void then
    setTraceGlobals(machine, world.traceLine(ctx.worldMap, parmVector(machine, 0), parmVector(machine, 1)))
  else
    setTraceGlobals(machine, collision.move(ctx.server, parmVector(machine, 0), zero, zero, parmVector(machine, 1), moveType, passedEntity))
  end if
  return true
end function

function newCheckClient(machine, current)
  ctx = context()
  if ctx.server is void or ctx.server.maxClients < 1 then return 0 end if
  server = ctx.server
  if current < 1 then current = 1 end if
  if current > server.maxClients then current = server.maxClients end if
  candidate = current + 1
  if candidate > server.maxClients then candidate = 1 end if
  while candidate != current
    valid = candidate < len(machine.edicts) and not machine.edictFree[candidate]
    if valid and entityFloat(machine, candidate, "health") <= 0.0 then valid = false end if
    if valid and (native.trunc(entityFloat(machine, candidate, "flags")) & c.FL_NOTARGET) != 0 then valid = false end if
    if valid then break end if
    candidate = candidate + 1
    if candidate > server.maxClients then candidate = 1 end if
  end while
  if candidate >= 0 and candidate < len(machine.edicts) and not machine.edictFree[candidate] then
    if ctx.worldMap is void then
      ctx.checkPvs = bytes()
    else
      targetView = math.add(entityVector(machine, candidate, "origin"), entityVector(machine, candidate, "view_ofs"))
      targetLeaf = world.leafForPoint(ctx.worldMap, targetView)
      ctx.checkPvs = world.leafPvs(ctx.worldMap, targetLeaf)
    end if
  else
    ctx.checkPvs = bytes()
  end if
  return candidate
end function

function checkClientBuiltin(machine)
  ctx = context()
  if ctx.server is void or ctx.server.maxClients < 1 then returnWord(machine, 0); return true end if
  server = ctx.server
  if server.time - ctx.lastCheckTime >= 0.1 then
    ctx.lastCheckClient = newCheckClient(machine, ctx.lastCheckClient)
    ctx.lastCheckTime = server.time
  end if

  candidate = ctx.lastCheckClient
  if candidate < 1 or candidate >= len(machine.edicts) or machine.edictFree[candidate] then returnWord(machine, 0); return true end if
  if entityFloat(machine, candidate, "health") <= 0.0 then returnWord(machine, 0); return true end if
  selfIndex = globalWord(machine, "self")
  if selfIndex < 0 or selfIndex >= len(machine.edicts) or machine.edictFree[selfIndex] then returnWord(machine, 0); return true end if
  selfView = math.add(entityVector(machine, selfIndex, "origin"), entityVector(machine, selfIndex, "view_ofs"))
  selfLeaf = world.leafForPoint(ctx.worldMap, selfView)
  if selfLeaf <= 0 or not world.leafVisible(ctx.checkPvs, selfLeaf) then returnWord(machine, 0); return true end if
  returnWord(machine, candidate)
  return true
end function

function findBuiltin(machine)
  start = parmWord(machine, 0) + 1
  offset = parmWord(machine, 1)
  match = parmString(machine, 2)
  if offset < 0 or offset >= machine.program.entityFields then return error(2666, "PF_Find: field outside edict") end if
  index = start
  limit = activeEdictLimit(machine)
  while index < limit
    // PF_Find skips a null string_t before strcmp.  An unset field must not
    // match a request for the empty string.
    rawString = machine.edicts[index][offset]
    if not machine.edictFree[index] and rawString != 0 and stringAt(machine, rawString) == match then returnWord(machine, index); return true end if
    index = index + 1
  end while
  returnWord(machine, 0)
  return true
end function

function precacheSoundBuiltin(machine)
  ctx = context()
  if ctx.server is not void and not ctx.server.loading then return error(2654, "PF_Precache_*: Precache can only be done in spawn functions") end if
  name = parmString(machine, 0)
  if badPrecacheString(name) then return error(2655, "PF_precache_sound: bad string") end if
  if precacheIndex(ctx.soundPrecache, name) < 0 then
    if len(ctx.soundPrecache) >= c.MAX_SOUNDS then return error(2656, "PF_precache_sound: overflow") end if
    ctx.soundPrecache = ctx.soundPrecache + [name]
  end if
  returnWord(machine, parmWord(machine, 0))
  return true
end function

function precacheModelBuiltin(machine)
  ctx = context()
  if ctx.server is not void and not ctx.server.loading then return error(2654, "PF_Precache_*: Precache can only be done in spawn functions") end if
  name = parmString(machine, 0)
  if badPrecacheString(name) then return error(2657, "PF_precache_model: bad string") end if
  if precacheIndex(ctx.modelPrecache, name) < 0 then
    if len(ctx.modelPrecache) >= c.MAX_MODELS then return error(2658, "PF_precache_model: overflow") end if
    ctx.modelPrecache = ctx.modelPrecache + [name]
  end if
  returnWord(machine, parmWord(machine, 0))
  return true
end function

function clientMessageBuffer(entityIndex)
  ctx = context()
  if entityIndex < 1 or entityIndex > len(ctx.clientMessages) then return void end if
  return ctx.clientMessages[entityIndex - 1]
end function

function stuffCommandBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then return error(2663, "PF_stuffcmd: parm 0 is not a client") end if
  msg.writeByte(buffer, c.SVC_STUFFTEXT)
  msg.writeString(buffer, parmString(machine, 1))
  return true
end function

function findRadiusBuiltin(machine)
  origin = parmVector(machine, 0)
  radius = parmFloat(machine, 1)
  chain = 0
  index = 1
  limit = activeEdictLimit(machine)
  while index < limit
    if not machine.edictFree[index] and entityFloat(machine, index, "solid") != c.SOLID_NOT then
      entityOrigin = entityVector(machine, index, "origin")
      mins = entityVector(machine, index, "mins")
      maxs = entityVector(machine, index, "maxs")
      center = math.add(entityOrigin, math.scale(math.add(mins, maxs), 0.5))
      if math.length(math.subtract(origin, center)) <= radius then
        setEntityWord(machine, index, "chain", chain)
        chain = index
      end if
    end if
    index = index + 1
  end while
  returnWord(machine, chain)
  return true
end function

function broadcastPrintBuiltin(machine)
  ctx = context()
  text = varString(machine, 0)
  if ctx.server is void then
    // Synthetic VM contexts have no client records, but retain a broadcast
    // buffer so standalone QuakeC execution can still observe the message.
    msg.writeByte(ctx.reliableDatagram, c.SVC_PRINT)
    msg.writeString(ctx.reliableDatagram, text)
  else
    index = 0
    while index < len(ctx.server.clients) and index < len(ctx.clientMessages)
      client = ctx.server.clients[index]
      if client.active and client.spawned then
        msg.writeByte(ctx.clientMessages[index], c.SVC_PRINT)
        msg.writeString(ctx.clientMessages[index], text)
      end if
      index = index + 1
    end while
  end if
  appendConsole(text)
  return true
end function

function clientPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to sprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, varString(machine, 1))
  return true
end function

function debugPrintBuiltin(machine)
  appendConsole(varString(machine, 0))
  return true
end function

function floorNumber(value)
  truncated = native.trunc(value)
  if value < truncated then return truncated - 1 end if
  return truncated
end function

function ceilNumber(value)
  truncated = native.trunc(value)
  if value > truncated then return truncated + 1 end if
  return truncated
end function

function floatToStringBuiltin(machine)
  value = parmFloat(machine, 0)
  rounded = native.trunc(value)
  if value == rounded then returnTemporaryString(machine, "" + rounded) else returnTemporaryString(machine, fixedOneDecimal(value)) end if
  return true
end function

function roundHalfEvenPositive(value)
  lower = floorNumber(value)
  fraction = value - lower
  if fraction < 0.5 then return lower end if
  if fraction > 0.5 then return lower + 1 end if
  if (lower % 2) != 0 then return lower + 1 end if
  return lower
end function

function fixedOneDecimal(value)
  value = native.bitsFloat(native.floatBits(value))
  negative = (native.floatBits(value) & 0x80000000) != 0
  magnitude = value
  if negative then magnitude = -magnitude end if
  scaled = roundHalfEvenPositive(magnitude * 10.0)
  whole = native.trunc(scaled / 10)
  fraction = scaled % 10
  text = "" + whole + "." + fraction
  if negative then text = "-" + text end if
  while len(bytes(text)) < 5
    text = " " + text
  end while
  return text
end function

function vectorToStringBuiltin(machine)
  value = parmVector(machine, 0)
  returnTemporaryString(machine, "'" + fixedOneDecimal(value.x) + " " + fixedOneDecimal(value.y) + " " + fixedOneDecimal(value.z) + "'")
  return true
end function

function activeEdictCount(machine)
  count = 0
  index = 0
  limit = activeEdictLimit(machine)
  while index < limit
    if not machine.edictFree[index] then count = count + 1 end if
    index = index + 1
  end while
  return count
end function

function coreDumpBuiltin(machine)
  appendConsole(qcedict.ED_PrintEdicts(machine))
  return true
end function

function traceOnBuiltin(machine)
  machine.trace = true
  return true
end function

function traceOffBuiltin(machine)
  machine.trace = false
  return true
end function

function entityPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  appendConsole(qcedict.ED_Print(machine, entityIndex))
  return true
end function

function traceEntityMove(machine, entityIndex, start, finish)
  mins = entityVector(machine, entityIndex, "mins")
  maxs = entityVector(machine, entityIndex, "maxs")
  ctx = context()
  if ctx.server is void and ctx.worldMap is void then
    plane = t.Plane(t.Vec3(0.0, 0.0, 0.0), 0.0, 0, 0)
    return t.Trace(false, false, true, false, 1.0, finish, plane, 0)
  end if
  if ctx.server is void then return world.trace(ctx.worldMap, start, mins, maxs, finish) end if
  return collision.move(ctx.server, start, mins, maxs, finish, c.MOVE_NORMAL, entityIndex)
end function

function walkMoveBuiltin(machine)
  ctx = context()
  entityIndex = globalWord(machine, "self")
  flags = native.trunc(entityFloat(machine, entityIndex, "flags"))
  if (flags & (c.FL_ONGROUND | c.FL_FLY | c.FL_SWIM)) == 0 then
    returnFloat(machine, 0.0)
    return true
  end if
  yaw = parmFloat(machine, 0) * math.DEG_TO_RAD
  distance = parmFloat(machine, 1)
  movement = t.Vec3(native.cos(yaw) * distance, native.sin(yaw) * distance, 0.0)
  if ctx.server is not void then
    moved = serverMove.moveStep(ctx.server, entityIndex, movement, true)
    if moved then returnFloat(machine, 1.0) else returnFloat(machine, 0.0) end if
    return true
  end if

  // VM-only fallback retained for the isolated synthetic QuakeC tests.
  start = entityVector(machine, entityIndex, "origin")
  trace = traceEntityMove(machine, entityIndex, start, math.add(start, movement))
  if trace.fraction == 1.0 then
    setEntityVector(machine, entityIndex, "origin", trace.endPosition)
    updateBounds(machine, entityIndex)
    returnFloat(machine, 1.0)
  else
    returnFloat(machine, 0.0)
  end if
  return true
end function

function dropToFloorBuiltin(machine)
  ctx = context()
  entityIndex = globalWord(machine, "self")
  start = entityVector(machine, entityIndex, "origin")
  finish = math.subtract(start, t.Vec3(0.0, 0.0, 256.0))
  trace = traceEntityMove(machine, entityIndex, start, finish)
  if trace.fraction == 1.0 or trace.allSolid then returnFloat(machine, 0.0); return true end if
  setEntityVector(machine, entityIndex, "origin", trace.endPosition)
  flags = native.trunc(entityFloat(machine, entityIndex, "flags")) | c.FL_ONGROUND
  setEntityFloat(machine, entityIndex, "flags", flags)
  setEntityWord(machine, entityIndex, "groundentity", trace.entity)
  updateBounds(machine, entityIndex)
  returnFloat(machine, 1.0)
  return true
end function

function lightStyleBuiltin(machine)
  ctx = context()
  style = native.trunc(parmFloat(machine, 0))
  value = parmString(machine, 1)
  if style < 0 or style >= len(ctx.lightStyles) then return error(2664, "PF_lightstyle: bad style " + style) end if
  ctx.lightStyles[style] = value
  if ctx.server is not void and ctx.server.active and not ctx.server.loading then
    index = 0
    while index < len(ctx.server.clients) and index < len(ctx.clientMessages)
      client = ctx.server.clients[index]
      if client.active or client.spawned then
        msg.writeByte(ctx.clientMessages[index], c.SVC_LIGHTSTYLE)
        msg.writeByte(ctx.clientMessages[index], style)
        msg.writeString(ctx.clientMessages[index], value)
      end if
      index = index + 1
    end while
  end if
  return true
end function

function roundBuiltin(machine)
  value = parmFloat(machine, 0)
  if value > 0.0 then
    returnFloat(machine, floorNumber(value + 0.5))
  else
    returnFloat(machine, ceilNumber(value - 0.5))
  end if
  return true
end function

function floorBuiltin(machine)
  returnFloat(machine, floorNumber(parmFloat(machine, 0)))
  return true
end function

function ceilBuiltin(machine)
  returnFloat(machine, ceilNumber(parmFloat(machine, 0)))
  return true
end function

function checkBottomBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  if ctx.server is not void and ctx.server.worldModel is not void and collision.checkBottom(ctx.server, entityIndex) then returnFloat(machine, 1.0) else returnFloat(machine, 0.0) end if
  return true
end function

function pointContentsBuiltin(machine)
  if context().worldMap is void then returnFloat(machine, c.CONTENTS_EMPTY) else returnFloat(machine, world.pointContentsWorld(context().worldMap, parmVector(machine, 0))) end if
  return true
end function

function absoluteBuiltin(machine)
  value = parmFloat(machine, 0)
  if value == 0.0 then value = 0.0 else if value < 0.0 then value = -value end if
  returnFloat(machine, value)
  return true
end function

function aimBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  forward = globalVector(machine, "v_forward")
  if ctx.server is void then returnVector(machine, forward); return true end if

  start = entityVector(machine, entityIndex, "origin")
  start.z = start.z + 20.0
  finish = math.multiplyAdd(start, 2048.0, forward)
  zero = t.Vec3(0.0, 0.0, 0.0)
  trace = collision.move(ctx.server, start, zero, zero, finish, c.MOVE_NORMAL, entityIndex)
  teamplay = cvar.variableValue(ctx.cvars, "teamplay")
  ownTeam = entityFloat(machine, entityIndex, "team")
  if trace.entity > 0 and entityFloat(machine, trace.entity, "takedamage") == c.DAMAGE_AIM then
    targetTeam = entityFloat(machine, trace.entity, "team")
    if teamplay == 0.0 or ownTeam <= 0.0 or ownTeam != targetTeam then returnVector(machine, forward); return true end if
  end if

  bestDirection = forward
  bestDistance = cvar.variableValue(ctx.cvars, "sv_aim")
  bestEntity = 0
  runtime = ctx.server.machine.context.edicts
  candidate = 1
  while candidate < runtime.numEdicts
    if candidate != entityIndex and not runtime.freeFlags[candidate] and entityFloat(machine, candidate, "takedamage") == c.DAMAGE_AIM then
      candidateTeam = entityFloat(machine, candidate, "team")
      teammate = teamplay != 0.0 and ownTeam > 0.0 and ownTeam == candidateTeam
      if not teammate then
        candidateOrigin = entityVector(machine, candidate, "origin")
        mins = entityVector(machine, candidate, "mins")
        maxs = entityVector(machine, candidate, "maxs")
        center = math.add(candidateOrigin, math.scale(math.add(mins, maxs), 0.5))
        direction = math.normalize(math.subtract(center, start))
        distance = math.dot(direction, forward)
        if distance >= bestDistance then
          targetTrace = collision.move(ctx.server, start, zero, zero, center, c.MOVE_NORMAL, entityIndex)
          if targetTrace.entity == candidate then bestDistance = distance; bestEntity = candidate end if
        end if
      end if
    end if
    candidate = candidate + 1
  end while

  if bestEntity != 0 then
    direction = math.subtract(entityVector(machine, bestEntity, "origin"), entityVector(machine, entityIndex, "origin"))
    distance = math.dot(direction, forward)
    aimed = math.scale(forward, distance)
    aimed.z = direction.z
    returnVector(machine, math.normalize(aimed))
  else
    returnVector(machine, bestDirection)
  end if
  return true
end function

function cvarBuiltin(machine)
  returnFloat(machine, cvar.variableValue(context().cvars, parmString(machine, 0)))
  return true
end function

function localCommandBuiltin(machine)
  cmd.addText(context().commands, parmString(machine, 0))
  return true
end function

function nextEntityBuiltin(machine)
  index = parmWord(machine, 0) + 1
  limit = activeEdictLimit(machine)
  while index < limit
    if not machine.edictFree[index] then returnWord(machine, index); return true end if
    index = index + 1
  end while
  returnWord(machine, 0)
  return true
end function

function particleBuiltin(machine)
  ctx = context()
  ctx.particles = ctx.particles + [[
    parmVector(machine, 0),
    parmVector(machine, 1),
    native.trunc(parmFloat(machine, 3)),
    native.trunc(parmFloat(machine, 2)),
  ]]
  return true
end function

function changeYawBuiltin(machine)
  ctx = context()
  entityIndex = globalWord(machine, "self")
  if ctx.server is not void then
    serverMove.changeYaw(ctx.server, entityIndex)
    return true
  end if
  angles = entityVector(machine, entityIndex, "angles")
  current = math.angleMod(angles.y)
  ideal = math.angleMod(entityFloat(machine, entityIndex, "ideal_yaw"))
  speed = entityFloat(machine, entityIndex, "yaw_speed")
  movement = ideal - current
  if movement > 180.0 then movement = movement - 360.0 end if
  if movement < -180.0 then movement = movement + 360.0 end if
  if movement > speed then movement = speed end if
  if movement < -speed then movement = -speed end if
  angles.y = math.angleMod(current + movement)
  setEntityVector(machine, entityIndex, "angles", angles)
  return true
end function

function vectorAnglesBuiltin(machine)
  value = parmVector(machine, 0)
  yaw = 0.0
  pitch = 0.0
  if value.x == 0.0 and value.y == 0.0 then
    if value.z > 0.0 then pitch = 90.0 else pitch = 270.0 end if
  else
    yaw = native.trunc(math.atan2(value.y, value.x) * math.RAD_TO_DEG)
    if yaw < 0.0 then yaw = yaw + 360.0 end if
    forward = math.sqrt(value.x * value.x + value.y * value.y)
    pitch = native.trunc(math.atan2(value.z, forward) * math.RAD_TO_DEG)
    if pitch < 0.0 then pitch = pitch + 360.0 end if
  end if
  returnVector(machine, t.Vec3(pitch, yaw, 0.0))
  return true
end function

function destinationBuffer(machine, destination)
  ctx = context()
  if destination == 0 then return ctx.datagram end if
  if destination == 1 then
    entityIndex = globalWord(machine, "msg_entity")
    buffer = clientMessageBuffer(entityIndex)
    if buffer is void then return error(2659, "WriteDest: msg_entity is not a client") end if
    return buffer
  end if
  if destination == 2 then return ctx.reliableDatagram end if
  if destination == 3 then return ctx.signon end if
  return error(2665, "WriteDest: bad destination " + destination)
end function

function writeByteBuiltin(machine)
  msg.writeByte(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

function writeCharBuiltin(machine)
  msg.writeChar(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

function writeShortBuiltin(machine)
  msg.writeShort(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

function writeLongBuiltin(machine)
  msg.writeLong(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

function writeCoordBuiltin(machine)
  msg.writeCoord(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmFloat(machine, 1))
  return true
end function

function writeAngleBuiltin(machine)
  msg.writeAngle(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmFloat(machine, 1))
  return true
end function

function writeStringBuiltin(machine)
  msg.writeString(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmString(machine, 1))
  return true
end function

function writeEntityBuiltin(machine)
  msg.writeShort(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmWord(machine, 1))
  return true
end function

function moveToGoalBuiltin(machine)
  ctx = context()
  entityIndex = globalWord(machine, "self")
  distance = parmFloat(machine, 0)
  if ctx.server is not void then
    moved = serverMove.moveToGoal(ctx.server, entityIndex, distance)
    if moved then returnFloat(machine, 1.0) else returnFloat(machine, 0.0) end if
    return true
  end if
  yaw = entityFloat(machine, entityIndex, "ideal_yaw")
  setFloat(machine, parameterOffset(0), yaw)
  setFloat(machine, parameterOffset(1), distance)
  return walkMoveBuiltin(machine)
end function

function precacheFileBuiltin(machine)
  returnWord(machine, parmWord(machine, 0))
  return true
end function

function writeStaticBaseline(buffer, machine, entityIndex)
  modelName = entityString(machine, entityIndex, "model")
  modelIndex = 0
  if modelName != "" then
    modelIndex = precacheIndex(context().modelPrecache, modelName)
    if modelIndex < 0 then return error(2667, "SV_ModelIndex: model was not precached: " + modelName) end if
  end if
  return protocolEvents.writeSpawnStatic(
    buffer,
    modelIndex,
    entityFloat(machine, entityIndex, "frame"),
    entityFloat(machine, entityIndex, "colormap"),
    entityFloat(machine, entityIndex, "skin"),
    entityVector(machine, entityIndex, "origin"),
    entityVector(machine, entityIndex, "angles"),
  )
end function

function makeStaticBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  writeStaticBaseline(ctx.signon, machine, entityIndex)
  releaseEdict(machine, entityIndex)
  return true
end function

function changeLevelBuiltin(machine)
  ctx = context()
  if ctx.changeLevel == "" then
    ctx.changeLevel = parmString(machine, 0)
    if ctx.commands is not void then cmd.addText(ctx.commands, "changelevel " + ctx.changeLevel + "\n") end if
  end if
  return true
end function

function cvarSetBuiltin(machine)
  ctx = context()
  name = parmString(machine, 0)
  if cvar.find(ctx.cvars, name) is void then
    appendConsole("Cvar_Set: variable " + name + " not found")
    return true
  end if
  result = cvar.set(ctx.cvars, name, parmString(machine, 1))
  if result is error then return result end if
  return true
end function

function centerPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to centerprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_CENTERPRINT)
  msg.writeString(buffer, varString(machine, 1))
  return true
end function

function ambientSoundBuiltin(machine)
  ctx = context()
  origin = parmVector(machine, 0)
  sample = parmString(machine, 1)
  soundIndex = precacheIndex(ctx.soundPrecache, sample)
  if soundIndex < 0 then appendConsole("no precache: " + sample); return true end if
  protocolEvents.writeStaticSound(
    ctx.signon,
    origin,
    soundIndex,
    parmFloat(machine, 2),
    parmFloat(machine, 3),
  )
  return true
end function

function setSpawnParmsBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  clientIndex = entityIndex - 1
  if clientIndex < 0 or clientIndex >= len(ctx.clientSpawnParms) then
    return error(3350, "setspawnparms: entity " + entityIndex + " is not a client")
  end if
  values = ctx.clientSpawnParms[clientIndex]
  index = 0
  while index < 16 and index < len(values)
    offset = globalOffset(machine, "parm" + (index + 1))
    if offset >= 0 then setFloat(machine, offset, values[index]) end if
    index = index + 1
  end while
  return true
end function

function builtinNames()
  return [
    "PF_Fixme", "PF_makevectors", "PF_setorigin", "PF_setmodel", "PF_setsize", "PF_Fixme", "PF_break", "PF_random",
    "PF_sound", "PF_normalize", "PF_error", "PF_objerror", "PF_vlen", "PF_vectoyaw", "PF_Spawn", "PF_Remove",
    "PF_traceline", "PF_checkclient", "PF_Find", "PF_precache_sound", "PF_precache_model", "PF_stuffcmd", "PF_findradius", "PF_bprint",
    "PF_sprint", "PF_dprint", "PF_ftos", "PF_vtos", "PF_coredump", "PF_traceon", "PF_traceoff", "PF_eprint",
    "PF_walkmove", "PF_Fixme", "PF_droptofloor", "PF_lightstyle", "PF_rint", "PF_floor", "PF_ceil", "PF_Fixme",
    "PF_checkbottom", "PF_pointcontents", "PF_Fixme", "PF_fabs", "PF_aim", "PF_cvar", "PF_localcmd", "PF_nextent",
    "PF_particle", "PF_changeyaw", "PF_Fixme", "PF_vectoangles", "PF_WriteByte", "PF_WriteChar", "PF_WriteShort", "PF_WriteLong",
    "PF_WriteCoord", "PF_WriteAngle", "PF_WriteString", "PF_WriteEntity", "PF_Fixme", "PF_Fixme", "PF_Fixme", "PF_Fixme",
    "PF_Fixme", "PF_Fixme", "PF_Fixme", "SV_MoveToGoal", "PF_precache_file", "PF_makestatic", "PF_changelevel", "PF_Fixme",
    "PF_cvar_set", "PF_centerprint", "PF_ambientsound", "PF_precache_model", "PF_precache_sound", "PF_precache_file", "PF_setspawnparms",
  ]
end function

function fixmeSlots()
  return [0, 5, 33, 39, 42, 50, 60, 61, 62, 63, 64, 65, 66, 71]
end function

function builtinContractFingerprint()
  names = builtinNames()
  hash = FNV_OFFSET
  index = 0
  while index < len(names)
    hash = ((hash ^ (index & 255)) * FNV_PRIME) & 0xffffffff
    data = bytes(names[index])
    byteIndex = 0
    while byteIndex < len(data)
      hash = ((hash ^ data[byteIndex]) * FNV_PRIME) & 0xffffffff
      byteIndex = byteIndex + 1
    end while
    hash = (hash * FNV_PRIME) & 0xffffffff
    index = index + 1
  end while
  return hash
end function

function install(machine, contextValue)
  bind(contextValue)
  table = [
    fixme,
    makeVectors,
    setOrigin,
    setModel,
    setSize,
    fixme,
    breakBuiltin,
    randomBuiltin,
    soundBuiltin,
    normalizeBuiltin,
    errorBuiltin,
    objectErrorBuiltin,
    vectorLengthBuiltin,
    vectorYawBuiltin,
    spawnBuiltin,
    removeBuiltin,
    traceLineBuiltin,
    checkClientBuiltin,
    findBuiltin,
    precacheSoundBuiltin,
    precacheModelBuiltin,
    stuffCommandBuiltin,
    findRadiusBuiltin,
    broadcastPrintBuiltin,
    clientPrintBuiltin,
    debugPrintBuiltin,
    floatToStringBuiltin,
    vectorToStringBuiltin,
    coreDumpBuiltin,
    traceOnBuiltin,
    traceOffBuiltin,
    entityPrintBuiltin,
    walkMoveBuiltin,
    fixme,
    dropToFloorBuiltin,
    lightStyleBuiltin,
    roundBuiltin,
    floorBuiltin,
    ceilBuiltin,
    fixme,
    checkBottomBuiltin,
    pointContentsBuiltin,
    fixme,
    absoluteBuiltin,
    aimBuiltin,
    cvarBuiltin,
    localCommandBuiltin,
    nextEntityBuiltin,
    particleBuiltin,
    changeYawBuiltin,
    fixme,
    vectorAnglesBuiltin,
    writeByteBuiltin,
    writeCharBuiltin,
    writeShortBuiltin,
    writeLongBuiltin,
    writeCoordBuiltin,
    writeAngleBuiltin,
    writeStringBuiltin,
    writeEntityBuiltin,
    fixme,
    fixme,
    fixme,
    fixme,
    fixme,
    fixme,
    fixme,
    moveToGoalBuiltin,
    precacheFileBuiltin,
    makeStaticBuiltin,
    changeLevelBuiltin,
    fixme,
    cvarSetBuiltin,
    centerPrintBuiltin,
    ambientSoundBuiltin,
    precacheModelBuiltin,
    precacheSoundBuiltin,
    precacheFileBuiltin,
    setSpawnParmsBuiltin,
  ]
  if len(table) != BUILTIN_COUNT then return error(3370, "QuakeC builtin table size mismatch") end if
  if len(builtinNames()) != BUILTIN_COUNT then return error(3371, "QuakeC builtin name table size mismatch") end if
  machine.builtins = table
  return machine
end function

// GLQuake pr_cmds.c entry points.  These names intentionally mirror the C
// source so every target function has a concrete, searchable MiniLang pendant.
function PF_VarString(machine, first)
  return varString(machine, first)
end function

function PF_error(machine)
  return errorBuiltin(machine)
end function

function PF_objerror(machine)
  return objectErrorBuiltin(machine)
end function

function PF_makevectors(machine)
  return makeVectors(machine)
end function

function PF_setorigin(machine)
  return setOrigin(machine)
end function

function SetMinMaxSize(machine, entityIndex, mins, maxs, rotate)
  return setMinMaxSize(machine, entityIndex, mins, maxs, rotate)
end function

function PF_setsize(machine)
  return setSize(machine)
end function

function PF_setmodel(machine)
  return setModel(machine)
end function

function PF_bprint(machine)
  return broadcastPrintBuiltin(machine)
end function

function PF_sprint(machine)
  return clientPrintBuiltin(machine)
end function

function PF_centerprint(machine)
  return centerPrintBuiltin(machine)
end function

function PF_normalize(machine)
  return normalizeBuiltin(machine)
end function

function PF_vlen(machine)
  return vectorLengthBuiltin(machine)
end function

function PF_vectoyaw(machine)
  return vectorYawBuiltin(machine)
end function

function PF_vectoangles(machine)
  return vectorAnglesBuiltin(machine)
end function

function PF_random(machine)
  return randomBuiltin(machine)
end function

function PF_particle(machine)
  return particleBuiltin(machine)
end function

function PF_ambientsound(machine)
  return ambientSoundBuiltin(machine)
end function

function PF_sound(machine)
  return soundBuiltin(machine)
end function

function PF_break(machine)
  return breakBuiltin(machine)
end function

function PF_traceline(machine)
  return traceLineBuiltin(machine)
end function

function PF_TraceToss(machine)
  return fixme(machine)
end function

function PF_checkpos(machine)
  // The GLQuake function body is intentionally empty and is not installed in
  // the stock builtin table (slot 5 remains PF_Fixme).
  return true
end function

function PF_newcheckclient(machine, check)
  return newCheckClient(machine, check)
end function

function PF_checkclient(machine)
  return checkClientBuiltin(machine)
end function

function PF_stuffcmd(machine)
  return stuffCommandBuiltin(machine)
end function

function PF_localcmd(machine)
  return localCommandBuiltin(machine)
end function

function PF_cvar(machine)
  return cvarBuiltin(machine)
end function

function PF_cvar_set(machine)
  return cvarSetBuiltin(machine)
end function

function PF_findradius(machine)
  return findRadiusBuiltin(machine)
end function

function PF_dprint(machine)
  return debugPrintBuiltin(machine)
end function

function PF_ftos(machine)
  return floatToStringBuiltin(machine)
end function

function PF_fabs(machine)
  return absoluteBuiltin(machine)
end function

function PF_vtos(machine)
  return vectorToStringBuiltin(machine)
end function

function PF_etos(machine)
  return fixme(machine)
end function

function PF_Spawn(machine)
  return spawnBuiltin(machine)
end function

function PF_Remove(machine)
  return removeBuiltin(machine)
end function

function PF_Find(machine)
  return findBuiltin(machine)
end function

function PR_CheckEmptyString(value)
  if badPrecacheString(value) then return error(2669, "Bad string") end if
  return true
end function

function PF_precache_file(machine)
  return precacheFileBuiltin(machine)
end function

function PF_precache_sound(machine)
  return precacheSoundBuiltin(machine)
end function

function PF_precache_model(machine)
  return precacheModelBuiltin(machine)
end function

function PF_coredump(machine)
  return coreDumpBuiltin(machine)
end function

function PF_traceon(machine)
  return traceOnBuiltin(machine)
end function

function PF_traceoff(machine)
  return traceOffBuiltin(machine)
end function

function PF_eprint(machine)
  return entityPrintBuiltin(machine)
end function

function PF_walkmove(machine)
  return walkMoveBuiltin(machine)
end function

function PF_droptofloor(machine)
  return dropToFloorBuiltin(machine)
end function

function PF_lightstyle(machine)
  return lightStyleBuiltin(machine)
end function

function PF_rint(machine)
  return roundBuiltin(machine)
end function

function PF_floor(machine)
  return floorBuiltin(machine)
end function

function PF_ceil(machine)
  return ceilBuiltin(machine)
end function

function PF_checkbottom(machine)
  return checkBottomBuiltin(machine)
end function

function PF_pointcontents(machine)
  return pointContentsBuiltin(machine)
end function

function PF_nextent(machine)
  return nextEntityBuiltin(machine)
end function

function PF_aim(machine)
  return aimBuiltin(machine)
end function

function PF_changeyaw(machine)
  return changeYawBuiltin(machine)
end function

function PF_changepitch(machine)
  return fixme(machine)
end function

function WriteDest(machine)
  return destinationBuffer(machine, native.trunc(parmFloat(machine, 0)))
end function

function PF_WriteByte(machine)
  return writeByteBuiltin(machine)
end function

function PF_WriteChar(machine)
  return writeCharBuiltin(machine)
end function

function PF_WriteShort(machine)
  return writeShortBuiltin(machine)
end function

function PF_WriteLong(machine)
  return writeLongBuiltin(machine)
end function

function PF_WriteAngle(machine)
  return writeAngleBuiltin(machine)
end function

function PF_WriteCoord(machine)
  return writeCoordBuiltin(machine)
end function

function PF_WriteString(machine)
  return writeStringBuiltin(machine)
end function

function PF_WriteEntity(machine)
  return writeEntityBuiltin(machine)
end function

function PF_makestatic(machine)
  return makeStaticBuiltin(machine)
end function

function PF_setspawnparms(machine)
  return setSpawnParmsBuiltin(machine)
end function

function PF_changelevel(machine)
  return changeLevelBuiltin(machine)
end function

function PF_WaterMove(machine)
  return fixme(machine)
end function

function PF_sin(machine)
  return fixme(machine)
end function

function PF_cos(machine)
  return fixme(machine)
end function

function PF_sqrt(machine)
  return fixme(machine)
end function

function PF_Fixme(machine)
  return fixme(machine)
end function
