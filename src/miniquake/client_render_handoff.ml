/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Builds the temporary alias-model entities that CL_UpdateTEnts appends to
cl_visedicts.  Retained beam slots remain protocol state; this is the frame
view consumed by the modern renderer.
*/

package miniquake.client_render_handoff

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.array_util as arrays
import miniquake.protocol_transients as transients
import miniquake.particles as particles
import miniquake.client as clientRuntime

const MAX_BEAMS = 24
const MAX_TEMP_ENTITIES = 64
const BEAM_STEP = 30.0

currentTemporary = []

function renderFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

function beamAngles(startPosition, endPosition)
  distance = math.subtract(endPosition, startPosition)
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
  return t.Vec3(renderFloat(pitch), renderFloat(yaw), 0.0)
end function

function beamSegmentOrigins(startPosition, endPosition, limit)
  builder = arrays.createArrayBuilder(limit)
  distance = math.subtract(endPosition, startPosition)
  remaining = renderFloat(math.length(distance))
  direction = t.Vec3(0.0, 0.0, 0.0)
  if remaining != 0.0 then direction = math.scale(distance, 1.0 / remaining) end if
  origin = math.copy(startPosition)
  maximum = native.trunc(limit)
  if maximum < 0 then maximum = 0 end if
  while remaining > 0.0 and builder.count < maximum
    arrays.pushArrayBuilder(builder, math.copy(origin))
    origin.x = renderFloat(origin.x + direction.x * BEAM_STEP)
    origin.y = renderFloat(origin.y + direction.y * BEAM_STEP)
    origin.z = renderFloat(origin.z + direction.z * BEAM_STEP)
    remaining = renderFloat(remaining - BEAM_STEP)
  end while
  return arrays.finishArrayBuilder(builder)
end function

function compactBeamStart(value, viewEntity, viewOrigin)
  if value.entity == viewEntity then return math.copy(viewOrigin) end if
  return math.copy(value.origin)
end function

function beamModelName(type)
  if type == c.TE_LIGHTNING1 then return "progs/bolt.mdl" end if
  if type == c.TE_LIGHTNING2 then return "progs/bolt2.mdl" end if
  if type == c.TE_LIGHTNING3 then return "progs/bolt3.mdl" end if
  if type == c.TE_BEAM then return "progs/beam.mdl" end if
  return ""
end function

function modelIndexForName(client, name)
  if len(client.modelPrecache) == 0 then client.modelPrecache = [""] end if
  index = 1
  while index < len(client.modelPrecache)
    if client.modelPrecache[index] == name then return index end if
    index = index + 1
  end while
  client.modelPrecache = client.modelPrecache + [name]
  return len(client.modelPrecache) - 1
end function

function makeBeamEntity(number, modelIndex, origin, angles, currentTime)
  entityOrigin = math.copy(origin)
  entityAngles = math.copy(angles)
  messageOrigin = math.copy(origin)
  previousMessageOrigin = math.copy(origin)
  messageAngles = math.copy(angles)
  previousMessageAngles = math.copy(angles)
  return t.ClientEntityState(
    number,
    modelIndex,
    0,
    0,
    0,
    0,
    entityOrigin,
    entityAngles,
    currentTime,
    messageOrigin,
    previousMessageOrigin,
    messageAngles,
    previousMessageAngles,
    false,
    void,
    0.0,
  )
end function

// Mirrors CL_UpdateTEnts: reset per-frame temp storage, update player-owned
// beam starts, append 30-unit model segments, and stop at either shared cap.
function buildTemporaryEntities(compactBeams, client, currentTime, visibleCount)
  global currentTemporary
  available = c.MAX_VISEDICTS - visibleCount
  if available < 0 then available = 0 end if
  capacity = MAX_TEMP_ENTITIES
  if available < capacity then capacity = available end if
  builder = arrays.createArrayBuilder(capacity)
  active = transients.activeCompactBeamList(compactBeams, currentTime)
  beamIndex = 0
  while beamIndex < len(active) and builder.count < capacity
    effect = active[beamIndex][0]
    modelName = beamModelName(effect.type)
    if modelName != "" then
      start = compactBeamStart(effect, client.viewEntity, clientRuntime.CL_ViewEntityOrigin(client))
      origins = beamSegmentOrigins(start, effect.endPosition, capacity - builder.count)
      baseAngles = beamAngles(start, effect.endPosition)
      modelIndex = modelIndexForName(client, modelName)
      segment = 0
      while segment < len(origins) and builder.count < capacity
        angles = t.Vec3(baseAngles.x, baseAngles.y, particles.compatRand() % 360)
        number = -1 - beamIndex * MAX_TEMP_ENTITIES - segment
        arrays.pushArrayBuilder(
          builder,
          makeBeamEntity(number, modelIndex, origins[segment], angles, currentTime),
        )
        segment = segment + 1
      end while
    end if
    beamIndex = beamIndex + 1
  end while
  currentTemporary = arrays.finishArrayBuilder(builder)
  return currentTemporary
end function

function currentTemporaryEntities()
  global currentTemporary
  return currentTemporary
end function

function clearTemporaryEntities()
  global currentTemporary
  currentTemporary = []
  return true
end function

function submitMirrorEntities(visibleEntities, temporaryEntities, viewEntity)
  result = submitEntities(visibleEntities, temporaryEntities)
  if viewEntity is void or viewEntity.modelIndex == 0 then return result end if
  for each entity in result
    if entity is not void and entity.number == viewEntity.number then return result end if
  end for
  if len(result) >= c.MAX_VISEDICTS then return result end if
  return result + [viewEntity]
end function

function submitEntities(visibleEntities, temporaryEntities)
  capacity = len(visibleEntities) + len(temporaryEntities)
  if capacity > c.MAX_VISEDICTS then capacity = c.MAX_VISEDICTS end if
  builder = arrays.createArrayBuilder(capacity)
  for each entity in visibleEntities
    if builder.count < c.MAX_VISEDICTS then arrays.pushArrayBuilder(builder, entity) end if
  end for
  for each entity in temporaryEntities
    if builder.count < c.MAX_VISEDICTS then arrays.pushArrayBuilder(builder, entity) end if
  end for
  return arrays.finishArrayBuilder(builder)
end function
