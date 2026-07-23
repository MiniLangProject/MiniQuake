package miniquake.quakec.builtins

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.mathlib as math
import miniquake.message as msg
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.world_bsp as world
import miniquake.server_collision as collision
import miniquake.server_move as serverMove
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as qvm

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

function definitionOffset(definitions, name)
  wanted = bio.lower(name)
  for each definition in definitions
    if bio.lower(definition.name) == wanted then return definition.offset end if
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
  setEntityVector(machine, entityIndex, "absmin", math.add(origin, mins))
  setEntityVector(machine, entityIndex, "absmax", math.add(origin, maxs))
  setEntityVector(machine, entityIndex, "size", math.subtract(maxs, mins))
end function

function allocateEdict(machine)
  index = 1
  while index < len(machine.edicts)
    if machine.edictFree[index] then
      machine.edictFree[index] = false
      qvm.clearEntity(machine, index)
      return index
    end if
    index = index + 1
  end while
  return error(2650, "ED_Alloc: no free edicts")
end function

function releaseEdict(machine, entityIndex)
  if entityIndex <= 0 or entityIndex >= len(machine.edicts) then return false end if
  qvm.clearEntity(machine, entityIndex)
  machine.edictFree[entityIndex] = true
  return true
end function

function precacheIndex(values, name)
  wanted = bio.lower(name)
  index = 0
  while index < len(values)
    if bio.lower(values[index]) == wanted then return index end if
    index = index + 1
  end while
  return -1
end function

function appendConsole(text)
  ctx = context()
  ctx.consoleLines = ctx.consoleLines + [text]
end function

function fixme(machine)
  return true
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
  nameBytes = bytes(modelName)
  if len(nameBytes) > 1 and nameBytes[0] == 42 then
    submodel = toNumber(decode(slice(nameBytes, 1, len(nameBytes) - 1)))
    if submodel is not void and submodel >= 0 and submodel < len(ctx.worldMap.models) then
      model = ctx.worldMap.models[submodel]
      setEntityVector(machine, entityIndex, "mins", model.mins)
      setEntityVector(machine, entityIndex, "maxs", model.maxs)
      updateBounds(machine, entityIndex)
    end if
  end if
  return true
end function

function setSize(machine)
  entityIndex = parmWord(machine, 0)
  mins = parmVector(machine, 1)
  maxs = parmVector(machine, 2)
  if mins.x > maxs.x or mins.y > maxs.y or mins.z > maxs.z then return error(2652, "PF_setsize: backwards mins/maxs") end if
  setEntityVector(machine, entityIndex, "mins", mins)
  setEntityVector(machine, entityIndex, "maxs", maxs)
  updateBounds(machine, entityIndex)
  return true
end function

function breakBuiltin(machine)
  appendConsole("break statement")
  return true
end function

function randomBuiltin(machine)
  ctx = context()
  ctx.randomSeed = (ctx.randomSeed * 1103515245 + 12345) & 0x7fffffff
  returnFloat(machine, (ctx.randomSeed & 0xffff) / 65536.0)
  return true
end function

function soundBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  channel = native.trunc(parmFloat(machine, 1))
  sample = parmString(machine, 2)
  volume = parmFloat(machine, 3)
  attenuation = parmFloat(machine, 4)
  if channel < 0 or channel > 7 then return error(2660, "SV_StartSound: bad channel " + channel) end if
  if volume < 0.0 or volume > 1.0 then return error(2661, "SV_StartSound: bad volume " + volume) end if
  if attenuation < 0.0 or attenuation > 4.0 then return error(2662, "SV_StartSound: bad attenuation " + attenuation) end if
  ctx.soundEvents = ctx.soundEvents + [[entityIndex, channel, sample, volume, attenuation]]
  return true
end function

function normalizeBuiltin(machine)
  returnVector(machine, math.normalize(parmVector(machine, 0)))
  return true
end function

function errorBuiltin(machine)
  return error(2653, "QuakeC error: " + parmString(machine, 0))
end function

function objectErrorBuiltin(machine)
  selfIndex = globalWord(machine, "self")
  releaseEdict(machine, selfIndex)
  return error(2654, "QuakeC object error: " + parmString(machine, 0))
end function

function vectorLengthBuiltin(machine)
  returnFloat(machine, math.length(parmVector(machine, 0)))
  return true
end function

function vectorYawBuiltin(machine)
  value = parmVector(machine, 0)
  yaw = 0.0
  if value.x != 0.0 or value.y != 0.0 then
    yaw = math.atan2(value.y, value.x) * math.RAD_TO_DEG
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
  if ctx.server is void then
    setTraceGlobals(machine, world.traceLine(ctx.worldMap, parmVector(machine, 0), parmVector(machine, 1)))
  else
    setTraceGlobals(machine, collision.move(ctx.server, parmVector(machine, 0), zero, zero, parmVector(machine, 1), moveType, passedEntity))
  end if
  return true
end function

function checkClientBuiltin(machine)
  returnWord(machine, 1)
  return true
end function

function findBuiltin(machine)
  ctx = context()
  start = parmWord(machine, 0) + 1
  offset = parmWord(machine, 1)
  match = parmString(machine, 2)
  index = start
  while index < len(machine.edicts)
    if not machine.edictFree[index] and stringAt(machine, machine.edicts[index][offset]) == match then returnWord(machine, index); return true end if
    index = index + 1
  end while
  returnWord(machine, 0)
  return true
end function

function precacheSoundBuiltin(machine)
  ctx = context()
  name = parmString(machine, 0)
  if name == "" then return error(2655, "PF_precache_sound: empty name") end if
  if precacheIndex(ctx.soundPrecache, name) < 0 then
    if len(ctx.soundPrecache) >= c.MAX_SOUNDS then return error(2656, "PF_precache_sound: overflow") end if
    ctx.soundPrecache = ctx.soundPrecache + [name]
  end if
  returnWord(machine, parmWord(machine, 0))
  return true
end function

function precacheModelBuiltin(machine)
  ctx = context()
  name = parmString(machine, 0)
  if name == "" then return error(2657, "PF_precache_model: empty name") end if
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
  ctx = context()
  origin = parmVector(machine, 0)
  radius = parmFloat(machine, 1)
  chain = 0
  index = 1
  while index < len(machine.edicts)
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
  buffer = context().reliableDatagram
  text = parmString(machine, 0)
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, text)
  appendConsole(text)
  return true
end function

function clientPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to sprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, parmString(machine, 1))
  return true
end function

function debugPrintBuiltin(machine)
  appendConsole(parmString(machine, 0))
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
  if value == rounded then returnString(machine, "" + rounded) else returnString(machine, "" + value) end if
  return true
end function

function vectorToStringBuiltin(machine)
  value = parmVector(machine, 0)
  returnString(machine, "'" + value.x + " " + value.y + " " + value.z + "'")
  return true
end function

function activeEdictCount(machine)
  count = 0
  index = 0
  while index < len(machine.edicts)
    if not machine.edictFree[index] then count = count + 1 end if
    index = index + 1
  end while
  return count
end function

function coreDumpBuiltin(machine)
  appendConsole("QuakeC edicts: " + activeEdictCount(machine))
  return true
end function

function traceOnBuiltin(machine)
  appendConsole("QuakeC statement trace enabled")
  return true
end function

function traceOffBuiltin(machine)
  appendConsole("QuakeC statement trace disabled")
  return true
end function

function entityPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  appendConsole("edict " + entityIndex + " classname=" + entityString(machine, entityIndex, "classname"))
  return true
end function

function traceEntityMove(machine, entityIndex, start, finish)
  mins = entityVector(machine, entityIndex, "mins")
  maxs = entityVector(machine, entityIndex, "maxs")
  ctx = context()
  if ctx.server is void then return world.trace(ctx.worldMap, start, mins, maxs, finish) end if
  return collision.move(ctx.server, start, mins, maxs, finish, c.MOVE_NORMAL, entityIndex)
end function

function walkMoveBuiltin(machine)
  ctx = context()
  entityIndex = globalWord(machine, "self")
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
  for each buffer in ctx.clientMessages
    msg.writeByte(buffer, c.SVC_LIGHTSTYLE)
    msg.writeByte(buffer, style)
    msg.writeString(buffer, value)
  end for
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
  if ctx.server is not void and collision.checkBottom(ctx.server, entityIndex) then returnFloat(machine, 1.0) else returnFloat(machine, 0.0) end if
  return true
end function

function pointContentsBuiltin(machine)
  returnFloat(machine, world.pointContentsWorld(context().worldMap, parmVector(machine, 0)))
  return true
end function

function absoluteBuiltin(machine)
  value = parmFloat(machine, 0)
  if value < 0.0 then value = -value end if
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
  if bestDistance <= 0.0 then bestDistance = 0.93 end if
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
  ctx = context()
  index = parmWord(machine, 0) + 1
  while index < len(machine.edicts)
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
    yaw = math.atan2(value.y, value.x) * math.RAD_TO_DEG
    if yaw < 0.0 then yaw = yaw + 360.0 end if
    forward = math.sqrt(value.x * value.x + value.y * value.y)
    pitch = math.atan2(value.z, forward) * math.RAD_TO_DEG
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
  origin = entityVector(machine, entityIndex, "origin")
  angles = entityVector(machine, entityIndex, "angles")
  msg.writeByte(buffer, native.trunc(entityFloat(machine, entityIndex, "modelindex")))
  msg.writeByte(buffer, native.trunc(entityFloat(machine, entityIndex, "frame")))
  msg.writeByte(buffer, native.trunc(entityFloat(machine, entityIndex, "colormap")))
  msg.writeByte(buffer, native.trunc(entityFloat(machine, entityIndex, "skin")))
  msg.writeCoord(buffer, origin.x); msg.writeAngle(buffer, angles.x)
  msg.writeCoord(buffer, origin.y); msg.writeAngle(buffer, angles.y)
  msg.writeCoord(buffer, origin.z); msg.writeAngle(buffer, angles.z)
end function

function makeStaticBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  msg.writeByte(ctx.signon, c.SVC_SPAWNSTATIC)
  writeStaticBaseline(ctx.signon, machine, entityIndex)
  releaseEdict(machine, entityIndex)
  return true
end function

function changeLevelBuiltin(machine)
  ctx = context()
  if ctx.changeLevel == "" then ctx.changeLevel = parmString(machine, 0) end if
  return true
end function

function cvarSetBuiltin(machine)
  result = cvar.set(context().cvars, parmString(machine, 0), parmString(machine, 1))
  if result is error then return result end if
  return true
end function

function centerPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to centerprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_CENTERPRINT)
  msg.writeString(buffer, parmString(machine, 1))
  return true
end function

function ambientSoundBuiltin(machine)
  ctx = context()
  origin = parmVector(machine, 0)
  sample = parmString(machine, 1)
  soundIndex = precacheIndex(ctx.soundPrecache, sample)
  if soundIndex < 0 then appendConsole("no precache: " + sample); return true end if
  msg.writeByte(ctx.signon, c.SVC_SPAWNSTATICSOUND)
  msg.writeCoord(ctx.signon, origin.x)
  msg.writeCoord(ctx.signon, origin.y)
  msg.writeCoord(ctx.signon, origin.z)
  msg.writeByte(ctx.signon, soundIndex)
  msg.writeByte(ctx.signon, native.trunc(parmFloat(machine, 2) * 255.0))
  msg.writeByte(ctx.signon, native.trunc(parmFloat(machine, 3) * 64.0))
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

function install(machine, contextValue)
  bind(contextValue)
  machine.builtins = [
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
  return machine
end function
