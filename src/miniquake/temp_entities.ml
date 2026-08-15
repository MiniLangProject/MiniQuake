/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.temp_entities.
*/
package miniquake.temp_entities

import miniquake.types as t
import miniquake.constants as c
import miniquake.message as msg
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.sound.mixer as sound
import miniquake.protocol_transients as transients

const MAX_BEAMS = 24

struct TempBeam
  entity
  model
  endTime
  start
  endPosition
end struct

struct TempRenderEntity
  origin
  model
  angles
  colormap
end struct

struct TempEntityState
  beams
  numTempEntities
  tempEntities
  visibleEntities
  precachedSounds
  precachedModels
  soundEvents
  particleEvents
  dynamicLights
  diagnostics
  randomSeed
  colormap
end struct

// Read and validate position.
function readPosition(reader)
  return t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
end function

// Mirrors CL_ParseTEnt's wire consumption.  Keeping this in the protocol layer
// is important: treating svc_temp_entity as a one-byte payload desynchronizes
// every command that follows it in the same server message.
function parseType(reader, type)
  origin = t.Vec3(0.0, 0.0, 0.0)
  endPosition = t.Vec3(0.0, 0.0, 0.0)
  entity = 0
  kind = transients.tempKind(type)
  if kind is error then return kind end if

  if kind == transients.TEMP_KIND_BEAM then
    entity = msg.readShort(reader)
    origin = readPosition(reader)
    endPosition = readPosition(reader)
  else if kind == transients.TEMP_KIND_POINT then
    origin = readPosition(reader)
  else
    origin = readPosition(reader)
    colorStart = msg.readByte(reader)
    colorLength = msg.readByte(reader)
    entity = (colorStart << 8) | colorLength
  end if

  return t.TemporaryEntity(type, origin, endPosition, entity)
end function

// Read and validate the requested value.
function parse(reader)
  return parseType(reader, msg.readByte(reader))
end function

// Provide empty beam behavior for the active subsystem.
function emptyBeam()
  return TempBeam(0, "", 0.0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
end function

// Provide empty dynamic light behavior for the active subsystem.
function emptyDynamicLight()
  return t.DynamicLight(t.Vec3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, 0.0, 0)
end function

// Apply the Quake-compatible cl init tents behavior.
function CL_InitTEnts(mixer)
  sounds = [
    "wizard/hit.wav",
    "hknight/hit.wav",
    "weapons/tink1.wav",
    "weapons/ric1.wav",
    "weapons/ric2.wav",
    "weapons/ric3.wav",
    "weapons/r_exp3.wav",
  ]
  if mixer is not void then sound.precache(mixer, sounds) end if
  beams = []
  index = 0
  while index < MAX_BEAMS
    beams = beams + [emptyBeam()]
    index = index + 1
  end while
  lights = []
  index = 0
  while index < c.MAX_DLIGHTS
    lights = lights + [emptyDynamicLight()]
    index = index + 1
  end while
  return TempEntityState(beams, 0, [], [], sounds, [], [], [], lights, [], 1, void)
end function

// Apply the Quake-compatible cl set random seed behavior.
function CL_SetRandomSeed(state, seed)
  state.randomSeed = seed & 0xffffffff
  return state.randomSeed
end function

// Apply the Quake-compatible cl rand behavior.
function CL_Rand(state)
  state.randomSeed = (state.randomSeed * 214013 + 2531011) & 0xffffffff
  return (state.randomSeed >> 16) & 0x7fff
end function

// Add state for append unique.
function appendUnique(values, value)
  for each current in values
    if current == value then return values end if
  end for
  return values + [value]
end function

// Provide beam type for model behavior for the active subsystem.
function beamTypeForModel(model)
  if model == "progs/bolt.mdl" then return c.TE_LIGHTNING1 end if
  if model == "progs/bolt2.mdl" then return c.TE_LIGHTNING2 end if
  if model == "progs/bolt3.mdl" then return c.TE_LIGHTNING3 end if
  return c.TE_BEAM
end function

// Return beam model for type derived from the active module state.
function beamModelForType(type)
  if type == c.TE_LIGHTNING1 then return "progs/bolt.mdl" end if
  if type == c.TE_LIGHTNING2 then return "progs/bolt2.mdl" end if
  if type == c.TE_LIGHTNING3 then return "progs/bolt3.mdl" end if
  if type == c.TE_BEAM then return "progs/beam.mdl" end if
  return ""
end function

// Update module state for beam.
function setBeam(beam, entity, model, start, finish, currentTime)
  beam.entity = entity
  beam.model = model
  beam.endTime = transients.beamEndTime(currentTime)
  beam.start = math.copy(start)
  beam.endPosition = math.copy(finish)
  return beam
end function

// Apply the Quake-compatible cl parse beam behavior.
function CL_ParseBeam(state, reader, model, currentTime)
  entity = msg.readShort(reader)
  start = readPosition(reader)
  finish = readPosition(reader)
  state.precachedModels = appendUnique(state.precachedModels, model)
  event = t.TemporaryEntity(beamTypeForModel(model), start, finish, entity)

  index = 0
  while index < MAX_BEAMS
    beam = state.beams[index]
    if beam.entity == entity then
      setBeam(beam, entity, model, start, finish, currentTime)
      return event
    end if
    index = index + 1
  end while

  index = 0
  while index < MAX_BEAMS
    beam = state.beams[index]
    if beam.model == "" or beam.endTime < currentTime then
      setBeam(beam, entity, model, start, finish, currentTime)
      return event
    end if
    index = index + 1
  end while
  state.diagnostics = state.diagnostics + ["beam list overflow!"]
  return event
end function

// Add state for append sound event.
function appendSoundEvent(state, name, origin)
  state.soundEvents = state.soundEvents + [[-1, 0, name, math.copy(origin), 1.0, 1.0]]
end function

// Add state for append particle event.
function appendParticleEvent(state, name, origin, color, count, extra)
  state.particleEvents = state.particleEvents + [[name, math.copy(origin), color, count, extra]]
end function

// Allocate and initialize temp dlight.
function allocateTempDlight(state, currentTime)
  index = 0
  while index < len(state.dynamicLights)
    light = state.dynamicLights[index]
    if light.die < currentTime then
      light.origin = t.Vec3(0.0, 0.0, 0.0)
      light.radius = 0.0
      light.die = 0.0
      light.decay = 0.0
      light.minLight = 0.0
      light.key = 0
      return light
    end if
    index = index + 1
  end while
  return state.dynamicLights[0]
end function

// Add state for append explosion light.
function appendExplosionLight(state, origin, currentTime)
  light = allocateTempDlight(state, currentTime)
  light.origin = math.copy(origin)
  light.radius = 350.0
  light.die = transients.dynamicLightDieTime(currentTime)
  light.decay = 300.0
  return light
end function

// Add state for append spike sound.
function appendSpikeSound(state, origin)
  if CL_Rand(state) % 5 != 0 then
    appendSoundEvent(state, "weapons/tink1.wav", origin)
    return "weapons/tink1.wav"
  end if
  random = CL_Rand(state) & 3
  name = "weapons/ric3.wav"
  if random == 1 then name = "weapons/ric1.wav" else if random == 2 then name = "weapons/ric2.wav" end if
  appendSoundEvent(state, name, origin)
  return name
end function

// Apply the Quake-compatible cl parse tent behavior.
function CL_ParseTEnt(state, reader, currentTime)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  type = msg.readByte(reader)
  model = beamModelForType(type)
  if model != "" then return CL_ParseBeam(state, reader, model, currentTime) end if

  value = parseType(reader, type)
  if value is error then return value end if
  position = value.origin
  if type == c.TE_WIZSPIKE then
    appendParticleEvent(state, "R_RunParticleEffect", position, 20, 30, void)
    appendSoundEvent(state, "wizard/hit.wav", position)
  else if type == c.TE_KNIGHTSPIKE then
    appendParticleEvent(state, "R_RunParticleEffect", position, 226, 20, void)
    appendSoundEvent(state, "hknight/hit.wav", position)
  else if type == c.TE_SPIKE then
    appendParticleEvent(state, "R_RunParticleEffect", position, 0, 10, void)
    appendSpikeSound(state, position)
  else if type == c.TE_SUPERSPIKE then
    appendParticleEvent(state, "R_RunParticleEffect", position, 0, 20, void)
    appendSpikeSound(state, position)
  else if type == c.TE_GUNSHOT then
    appendParticleEvent(state, "R_RunParticleEffect", position, 0, 20, void)
  else if type == c.TE_EXPLOSION then
    appendParticleEvent(state, "R_ParticleExplosion", position, 0, 0, void)
    appendExplosionLight(state, position, currentTime)
    appendSoundEvent(state, "weapons/r_exp3.wav", position)
  else if type == c.TE_TAREXPLOSION then
    appendParticleEvent(state, "R_BlobExplosion", position, 0, 0, void)
    appendSoundEvent(state, "weapons/r_exp3.wav", position)
  else if type == c.TE_LAVASPLASH then
    appendParticleEvent(state, "R_LavaSplash", position, 0, 0, void)
  else if type == c.TE_TELEPORT then
    appendParticleEvent(state, "R_TeleportSplash", position, 0, 0, void)
  else if type == c.TE_EXPLOSION2 then
    colorStart = (value.entity >> 8) & 255
    colorLength = value.entity & 255
    appendParticleEvent(state, "R_ParticleExplosion2", position, colorStart, colorLength, [colorStart, colorLength])
    appendExplosionLight(state, position, currentTime)
    appendSoundEvent(state, "weapons/r_exp3.wav", position)
  end if
  return value
end function

// Apply the Quake-compatible cl new temp entity behavior.
function CL_NewTempEntity(state)
  if len(state.visibleEntities) >= c.MAX_VISEDICTS then return void end if
  if state.numTempEntities >= c.MAX_TEMP_ENTITIES then return void end if
  entity = TempRenderEntity(
    t.Vec3(0.0, 0.0, 0.0),
    "",
    t.Vec3(0.0, 0.0, 0.0),
    state.colormap,
  )
  state.tempEntities = state.tempEntities + [entity]
  state.visibleEntities = state.visibleEntities + [entity]
  state.numTempEntities = state.numTempEntities + 1
  return entity
end function

// Apply the Quake-compatible cl update tents behavior.
function CL_UpdateTEnts(state, currentTime, viewEntity, viewOrigin)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  state.numTempEntities = 0
  state.tempEntities = []
  state.visibleEntities = []
  beamIndex = 0
  while beamIndex < MAX_BEAMS
    beam = state.beams[beamIndex]
    if beam.model != "" and transients.beamAlive(beam.endTime, currentTime) then
      if beam.entity == viewEntity then beam.start = math.copy(viewOrigin) end if
      distance = math.subtract(beam.endPosition, beam.start)
      yaw = 0.0
      pitch = 0.0
      if distance.y == 0.0 and distance.x == 0.0 then
        if distance.z > 0.0 then pitch = 90.0 else pitch = 270.0 end if
      else
        yaw = native.trunc(native.atan2(distance.y, distance.x) * math.RAD_TO_DEG)
        if yaw < 0.0 then yaw = yaw + 360.0 end if
        forward = native.sqrt(distance.x * distance.x + distance.y * distance.y)
        pitch = native.trunc(native.atan2(distance.z, forward) * math.RAD_TO_DEG)
        if pitch < 0.0 then pitch = pitch + 360.0 end if
      end if
      length = math.length(distance)
      direction = t.Vec3(0.0, 0.0, 0.0)
      if length != 0.0 then direction = math.scale(distance, 1.0 / length) end if
      origin = math.copy(beam.start)
      remaining = length
      while remaining > 0.0
        entity = CL_NewTempEntity(state)
        if entity is void then return state.tempEntities end if
        entity.origin = math.copy(origin)
        entity.model = beam.model
        entity.angles.x = pitch
        entity.angles.y = yaw
        entity.angles.z = CL_Rand(state) % 360
        origin = math.multiplyAdd(origin, 30.0, direction)
        remaining = remaining - 30.0
      end while
    end if
    beamIndex = beamIndex + 1
  end while
  return state.tempEntities
end function
