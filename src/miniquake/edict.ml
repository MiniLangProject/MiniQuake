/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.edict.
*/
package miniquake.edict

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.format.bsp as bsp
import miniquake.byteio as bio
import miniquake.array_util as arrayutil

/// Implements the `emptyBaseline` operation for `miniquake.edict` (empty baseline).
function emptyBaseline()
  // EntityBaseline and Vec3 are heap-backed MiniLang structs.  Keep both
  // vectors in named roots while the baseline object itself is allocated.
  // A GC triggered between nested constructor arguments must never leave one
  // of the already-created vectors reachable only through an unevaluated
  // argument slot.
  origin = t.Vec3(0.0, 0.0, 0.0)
  angles = t.Vec3(0.0, 0.0, 0.0)
  return t.EntityBaseline(0, 0, 0, 0, 0, origin, angles)
end function

/// Implements the `create` operation for `miniquake.edict` (create).
/// @param number The number input consumed by `create`.
function create(number)
  // QuakeEdict contains several heap-backed values.  Constructing all of them
  // inline used to expose a native-backend GC rooting edge case: during the
  // per-frame QuakeC-to-server synchronization a collection could occur while
  // the outer struct constructor still held earlier Vec3/array arguments only
  // in transient expression slots.  The resulting edict looked valid, but one
  // vector field could later be a non-struct value.  Root every heap argument
  // explicitly before allocating the QuakeEdict.
  fields = []
  keyValues = []
  origin = t.Vec3(0.0, 0.0, 0.0)
  angles = t.Vec3(0.0, 0.0, 0.0)
  velocity = t.Vec3(0.0, 0.0, 0.0)
  mins = t.Vec3(0.0, 0.0, 0.0)
  maxs = t.Vec3(0.0, 0.0, 0.0)
  viewOffset = t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT)
  baseline = emptyBaseline()
  leafNums = []
  return t.QuakeEdict(
    number,
    false,
    0.0,
    fields,
    keyValues,
    "",
    "",
    0,
    0,
    0,
    0,
    0,
    0,
    origin,
    angles,
    velocity,
    mins,
    maxs,
    c.MOVETYPE_NONE,
    c.SOLID_NOT,
    0,
    0.0,
    viewOffset,
    false,
    -1,
    baseline,
    leafNums,
  )
end function

/// Return value derived from the active module state.
/// @param entity Entity affected by the operation.
/// @param key Key used to identify the requested entry.
function value(entity, key)
  return bsp.entityValue(entity, key)
end function

/// Return number value derived from the active module state.
/// @param text Text to parse or process.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function numberValue(text, fallback)
  if text == "" then return fallback end if
  result = toNumber(text)
  if result is int or result is float then return result end if
  return fallback
end function

/// Update module state for pair.
/// @param edict QuakeC edict affected by the operation.
/// @param key Key used to identify the requested entry.
/// @param newValue The new value input consumed by `setPair`.
function setPair(edict, key, newValue)
  for each pair in edict.keyValues
    if pair.key == key then pair.value = newValue; return true end if
  end for
  edict.keyValues = edict.keyValues + [t.EntityPair(key, newValue)]
  return true
end function

/// Return pair.
/// @param edict QuakeC edict affected by the operation.
/// @param key Key used to identify the requested entry.
function getPair(edict, key)
  for each pair in edict.keyValues
    if pair.key == key then return pair.value end if
  end for
  return ""
end function

/// Transfer data for copy pairs.
/// @param entity Entity affected by the operation.
function copyPairs(entity)
  result = arrayutil.makeEmptyArray(len(entity.pairs))
  index = 0
  while index < len(entity.pairs)
    pair = entity.pairs[index]
    result[index] = t.EntityPair(pair.key, pair.value)
    index = index + 1
  end while
  return result
end function

/// Implements the `fromEntity` operation for `miniquake.edict` (from entity).
/// @param number The number input consumed by `fromEntity`.
/// @param entity Entity affected by the operation.
function fromEntity(number, entity)
  edict = create(number)
  edict.keyValues = copyPairs(entity)
  edict.className = value(entity, "classname")
  edict.model = value(entity, "model")
  edict.frame = numberValue(value(entity, "frame"), 0)
  edict.skin = numberValue(value(entity, "skin"), 0)
  edict.colormap = numberValue(value(entity, "colormap"), 0)
  edict.effects = numberValue(value(entity, "effects"), 0)
  edict.origin = bsp.entityVector(entity, "origin")
  edict.angles = bsp.entityVector(entity, "angles")
  angle = value(entity, "angle")
  if angle != "" then edict.angles.y = numberValue(angle, 0.0) end if
  edict.velocity = bsp.entityVector(entity, "velocity")
  mins = value(entity, "mins")
  maxs = value(entity, "maxs")
  if mins != "" then edict.mins = bsp.parseVector(mins) end if
  if maxs != "" then edict.maxs = bsp.parseVector(maxs) end if
  edict.moveType = numberValue(value(entity, "movetype"), c.MOVETYPE_NONE)
  edict.solid = numberValue(value(entity, "solid"), c.SOLID_NOT)
  edict.flags = numberValue(value(entity, "flags"), 0)
  edict.health = numberValue(value(entity, "health"), 0.0)
  viewOffset = value(entity, "view_ofs")
  if viewOffset != "" then edict.viewOffset = bsp.parseVector(viewOffset) end if

  if number == 0 or bio.equalInsensitive(edict.className, "worldspawn") then
    edict.moveType = c.MOVETYPE_PUSH
    edict.solid = c.SOLID_BSP
    edict.modelIndex = 1
    edict.model = "maps/world.bsp"
  end if
  return edict
end function

/// Read and validate map entities.
/// @param map The map input consumed by `loadMapEntities`.
function loadMapEntities(map)
  // Keep the live BSP graph intact while deriving server edicts.  See the
  // QuakeC loader counterpart for the nested-object GC rationale.
  if len(map.entities) == 0 then
    worldEntity = t.Entity([t.EntityPair("classname", "worldspawn")])
    return [fromEntity(0, worldEntity)]
  end if
  result = arrayutil.makeEmptyArray(len(map.entities))
  index = 0
  while index < len(map.entities)
    result[index] = fromEntity(index, map.entities[index])
    index = index + 1
  end while
  return result
end function

/// Return class.
/// @param edicts The edicts input consumed by `findClass`.
/// @param className Name that identifies the requested value or resource.
function findClass(edicts, className)
  wanted = bio.lower(className)
  builder = arrayutil.createArrayBuilder(16)
  for each item in edicts
    if not item.free and bio.lower(item.className) == wanted then arrayutil.pushArrayBuilder(builder, item) end if
  end for
  return arrayutil.finishArrayBuilder(builder)
end function

/// Return first class.
/// @param edicts The edicts input consumed by `findFirstClass`.
/// @param className Name that identifies the requested value or resource.
function findFirstClass(edicts, className)
  wanted = bio.lower(className)
  for each item in edicts
    if not item.free and bio.lower(item.className) == wanted then return item end if
  end for
  return void
end function

/// Allocate and initialize point.
/// @param edicts The edicts input consumed by `spawnPoint`.
/// @param deathmatch The deathmatch input consumed by `spawnPoint`.
function spawnPoint(edicts, deathmatch)
  selected = void
  if deathmatch then selected = findFirstClass(edicts, "info_player_deathmatch") end if
  if selected is void then selected = findFirstClass(edicts, "info_player_start") end if
  if selected is void then selected = findFirstClass(edicts, "testplayerstart") end if
  if selected is void then return [t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0)] end if
  return [math.copy(selected.origin), math.copy(selected.angles)]
end function

/// Implements the `allocate` operation for `miniquake.edict` (allocate).
/// @param edicts The edicts input consumed by `allocate`.
/// @param currentTime Time value used by the operation.
function allocate(edicts, currentTime)
  index = 1
  while index < len(edicts)
    item = edicts[index]
    if item.free and (item.freeTime < 2.0 or currentTime - item.freeTime > 0.5) then
      replacement = create(index)
      edicts[index] = replacement
      return replacement
    end if
    index = index + 1
  end while
  replacement = create(len(edicts))
  edicts = edicts + [replacement]
  return [replacement, edicts]
end function

/// Implements the `free` operation for `miniquake.edict` (free).
/// @param item The item input consumed by `free`.
/// @param currentTime Time value used by the operation.
function free(item, currentTime)
  item.free = true
  item.freeTime = currentTime
  item.model = ""
  item.modelIndex = 0
  item.solid = c.SOLID_NOT
  item.origin = t.Vec3(0.0, 0.0, 0.0)
  item.velocity = t.Vec3(0.0, 0.0, 0.0)
  return true
end function

/// Implements the `baseline` operation for `miniquake.edict` (baseline).
/// @param item The item input consumed by `baseline`.
function baseline(item)
  origin = math.copy(item.origin)
  angles = math.copy(item.angles)
  value = t.EntityBaseline(
    item.modelIndex,
    item.frame,
    item.colormap,
    item.skin,
    0,
    origin,
    angles,
  )
  item.baseline = value
  return item.baseline
end function

/// Create and initialize baselines.
/// @param edicts The edicts input consumed by `buildBaselines`.
function buildBaselines(edicts)
  count = 0
  for each item in edicts
    if not item.free then count = count + 1 end if
  end for
  result = arrayutil.makeEmptyArray(count)
  index = 0
  for each item in edicts
    if not item.free then
      result[index] = baseline(item)
      index = index + 1
    end if
  end for
  return result
end function
