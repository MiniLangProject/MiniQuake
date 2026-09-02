/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Optional Quake .lit sidecar support shared by model loading and rendering.
*/
package miniquake.render.colored_lightmaps

import miniquake.byteio as bio
import miniquake.common as common
import miniquake.filesystem as qfs

/// Tracks the module-level map keys state owned by `miniquake.render.colored_lightmaps`.
mapKeys = []
/// Tracks the module-level map values state owned by `miniquake.render.colored_lightmaps`.
mapValues = []

/// Decode a version-one QLIT payload and verify that it exactly mirrors the
/// BSP's scalar light sample count. Invalid sidecars are ignored safely.
/// @param data Input data consumed by the operation.
/// @param lightSampleCount Number of entries or units to process.
function decode(data, lightSampleCount)
  if data is not bytes or len(data) < 8 then return void end if
  if data[0] != 81 or data[1] != 76 or data[2] != 73 or data[3] != 84 then return void end if
  if bio.u32(data, 4) != 1 then return void end if
  expected = lightSampleCount * 3
  if expected < 0 or len(data) != expected + 8 then return void end if
  return slice(data, 8, expected)
end function

/// Associate validated RGB light samples with the relocatable BSP object.
/// @param map The map input consumed by `attach`.
/// @param samples The samples input consumed by `attach`.
function attach(map, samples)
  global mapKeys, mapValues
  if map is void or samples is void or samples is not bytes then return false end if
  index = 0
  while index < len(mapKeys)
    if nativeRawValue(mapKeys[index]) == nativeRawValue(map) then mapValues[index] = samples; return true end if
    index = index + 1
  end while
  // Retain the object itself, not its current numeric address. The MiniLang GC
  // relocates heap objects and updates rooted array elements during collection.
  mapKeys = mapKeys + [map]
  mapValues = mapValues + [samples]
  return true
end function

/// Load the optional sidecar through Quake's normal search path. This supports
/// loose files as well as .lit files supplied by a selected -game directory.
/// @param filesystem The filesystem input consumed by `loadForMap`.
/// @param map The map input consumed by `loadForMap`.
function loadForMap(filesystem, map)
  if filesystem is void or map is void or map.filename == "" then return false end if
  name = common.stripExtension(map.filename) + ".lit"
  if not qfs.exists(filesystem, name) then return false end if
  source = qfs.readFile(filesystem, name)
  if source is error then return false end if
  samples = decode(source, len(map.lighting))
  if samples is void then return false end if
  return attach(map, samples)
end function

/// Return RGB samples previously associated with this exact BSP instance.
/// @param map The map input consumed by `forMap`.
function forMap(map)
  if map is void then return void end if
  index = 0
  while index < len(mapKeys)
    if nativeRawValue(mapKeys[index]) == nativeRawValue(map) then return mapValues[index] end if
    index = index + 1
  end while
  return void
end function

// Clear sidecar roots when renderer/model state is torn down by tests.
function clear()
  global mapKeys, mapValues
  mapKeys = []
  mapValues = []
  return true
end function
