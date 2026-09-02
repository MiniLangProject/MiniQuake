/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

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

/// Defines the max beams value used by `miniquake.client_render_handoff`.
const MAX_BEAMS = 24
/// Defines the max temp entities value used by `miniquake.client_render_handoff`.
const MAX_TEMP_ENTITIES = 64
/// Defines the beam step value used by `miniquake.client_render_handoff`.
const BEAM_STEP = 30.0

/// Tracks the module-level empty temporary state owned by `miniquake.client_render_handoff`.
emptyTemporary = []
/// Tracks the module-level current temporary state owned by `miniquake.client_render_handoff`.
currentTemporary = emptyTemporary

/// Render float.
/// @param value Value consumed by `renderFloat`.
function renderFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Return beam angles derived from the active module state.
/// @param startPosition The start position input consumed by `beamAngles`.
/// @param endPosition The end position input consumed by `beamAngles`.
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

/// Return beam segment origins derived from the active module state.
/// @param startPosition The start position input consumed by `beamSegmentOrigins`.
/// @param endPosition The end position input consumed by `beamSegmentOrigins`.
/// @param limit The limit input consumed by `beamSegmentOrigins`.
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

/// Implements the `compactBeamStart` operation for `miniquake.client_render_handoff` (compact beam start).
/// @param value Value consumed by `compactBeamStart`.
/// @param viewEntity The view entity input consumed by `compactBeamStart`.
/// @param viewOrigin The view origin input consumed by `compactBeamStart`.
function compactBeamStart(value, viewEntity, viewOrigin)
  if value.entity == viewEntity then return math.copy(viewOrigin) end if
  return math.copy(value.origin)
end function

/// Return beam model name derived from the active module state.
/// @param type The type input consumed by `beamModelName`.
function beamModelName(type)
  if type == c.TE_LIGHTNING1 then return "progs/bolt.mdl" end if
  if type == c.TE_LIGHTNING2 then return "progs/bolt2.mdl" end if
  if type == c.TE_LIGHTNING3 then return "progs/bolt3.mdl" end if
  if type == c.TE_BEAM then return "progs/beam.mdl" end if
  return ""
end function

/// Return model index for name derived from the active module state.
/// @param client Client state participating in the operation.
/// @param name Stable name that identifies the requested object or option.
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

/// CL_InitTEnts owns the lightning models rather than receiving them in the
/// server model list. Register them during signon so the first beam does not
/// parse and upload a model while gameplay is already visible.
/// @param client Client state participating in the operation.
function precacheBeamModels(client)
  names = ["progs/bolt.mdl", "progs/bolt2.mdl", "progs/bolt3.mdl", "progs/beam.mdl"]
  for each name in names
    modelIndexForName(client, name)
  end for
  return names
end function

/// Create and initialize beam entity.
/// @param number The number input consumed by `makeBeamEntity`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
/// @param currentTime Time value used by the operation.
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

/// Mirrors CL_UpdateTEnts: reset per-frame temp storage, update player-owned
/// beam starts, append 30-unit model segments, and stop at either shared cap.
/// @param compactBeams The compact beams input consumed by `buildTemporaryEntities`.
/// @param client Client state participating in the operation.
/// @param currentTime Time value used by the operation.
/// @param visibleCount Number of entries or units to process.
function buildTemporaryEntities(compactBeams, client, currentTime, visibleCount)
  global currentTemporary
  available = c.MAX_VISEDICTS - visibleCount
  if available < 0 then available = 0 end if
  capacity = MAX_TEMP_ENTITIES
  if available < capacity then capacity = available end if
  // Most frames have no active lightning beam. Avoid allocating the 64-slot
  // builder and its exact-sized result for that empty handoff.
  if capacity <= 0 or len(compactBeams) == 0 then
    currentTemporary = emptyTemporary
    return currentTemporary
  end if
  active = transients.activeCompactBeamList(compactBeams, currentTime)
  if len(active) == 0 then
    currentTemporary = emptyTemporary
    return currentTemporary
  end if
  builder = arrays.createArrayBuilder(capacity)
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

// Return temporary entities.
function currentTemporaryEntities()
  global currentTemporary
  return currentTemporary
end function

// Update module state for temporary entities.
function clearTemporaryEntities()
  global currentTemporary
  currentTemporary = emptyTemporary
  return true
end function

/// Submit state for submit mirror entities.
/// @param visibleEntities The visible entities input consumed by `submitMirrorEntities`.
/// @param temporaryEntities The temporary entities input consumed by `submitMirrorEntities`.
/// @param viewEntity The view entity input consumed by `submitMirrorEntities`.
function submitMirrorEntities(visibleEntities, temporaryEntities, viewEntity)
  result = submitEntities(visibleEntities, temporaryEntities)
  if viewEntity is void or viewEntity.modelIndex == 0 then return result end if
  for each entity in result
    if entity is not void and entity.number == viewEntity.number then return result end if
  end for
  if len(result) >= c.MAX_VISEDICTS then return result end if
  return result + [viewEntity]
end function

/// Submit state for submit entities.
/// @param visibleEntities The visible entities input consumed by `submitEntities`.
/// @param temporaryEntities The temporary entities input consumed by `submitEntities`.
function submitEntities(visibleEntities, temporaryEntities)
  // The overwhelmingly common frame has no active beam segments. The visible
  // list is already capped by CL_RelinkEntities, so it can be consumed directly
  // instead of being copied into a third frame-local array.
  if len(temporaryEntities) == 0 and len(visibleEntities) <= c.MAX_VISEDICTS then return visibleEntities end if
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
