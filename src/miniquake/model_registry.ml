/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.model_registry.
*/
package miniquake.model_registry

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.cvar as cvar
import miniquake.filesystem as qfs
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as sprite
import miniquake.render.gl_warp as glWarp
import miniquake.render.colored_lightmaps as coloredLightmaps
import miniquake.world_bsp as world
import miniquake.array_util as arrayutil

/// Defines the mod unknown value used by `miniquake.model_registry`.
const MOD_UNKNOWN = -1
/// Defines the mod brush value used by `miniquake.model_registry`.
const MOD_BRUSH = 0
/// Defines the mod sprite value used by `miniquake.model_registry`.
const MOD_SPRITE = 1
/// Defines the mod alias value used by `miniquake.model_registry`.
const MOD_ALIAS = 2

/// Report whether model command never exists holds for the active state.
/// @param name Stable name that identifies the requested object or option.
function modelCommandNeverExists(name)
  return false
end function

/// Mod_Init.  mod_novis is the original MAX_MAP_LEAFS/8 all-visible row.
/// gl_subdivide_size is archived exactly as in gl_model.c.
/// @param registry The registry input consumed by `Mod_Init`.
/// @param cvars The cvars input consumed by `Mod_Init`.
function Mod_Init(registry, cvars)
  if registry is void then registry = create() end if
  registry.noVis = bytes(1024, 255)
  if cvars is not void and cvar.find(cvars, "gl_subdivide_size") is void then
    cvar.register(cvars, cvar.create("gl_subdivide_size", "128", true, false), modelCommandNeverExists)
  end if
  value = 128.0
  if cvars is not void then value = cvar.variableValue(cvars, "gl_subdivide_size") end if
  glWarp.SetSubdivideSize(value)
  return registry
end function

/// Implements the `create` operation for `miniquake.model_registry` (create).
function create()
  return t.ModelRegistry([], [], [], [], [], bytes(1024, 255))
end function

/// strcmp, not Q_strcasecmp: model identity is case-sensitive in MiniQuake.
/// @param registry The registry input consumed by `findIndex`.
/// @param name Stable name that identifies the requested object or option.
function findIndex(registry, name)
  i = 0
  while i < len(registry.names)
    if registry.names[i] == name then return i end if
    i = i + 1
  end while
  return -1
end function

/// Mirror Quake's Mod_FindName routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_FindName`.
/// @param name Stable name that identifies the requested object or option.
function Mod_FindName(registry, name)
  if name == "" then return error(1900, "Mod_ForName: NULL name") end if
  index = findIndex(registry, name)
  if index >= 0 then return index end if
  if len(registry.names) >= c.MAX_MOD_KNOWN then return error(1901, "mod_numknown == MAX_MOD_KNOWN") end if
  registry.names = registry.names + [name]
  registry.models = registry.models + [void]
  registry.needLoad = registry.needLoad + [true]
  registry.types = registry.types + [MOD_UNKNOWN]
  registry.touched = registry.touched + [false]
  return len(registry.names) - 1
end function

/// Update subsystem configuration for register typed.
/// @param registry The registry input consumed by `registerTyped`.
/// @param name Stable name that identifies the requested object or option.
/// @param model Model resource processed by the operation.
/// @param type The type input consumed by `registerTyped`.
function registerTyped(registry, name, model, type)
  index = Mod_FindName(registry, name)
  if index is error then return index end if
  registry.models[index] = model
  registry.types[index] = type
  registry.needLoad[index] = false
  return index
end function

/// Compatibility helper retained for existing callers.
/// @param registry The registry input consumed by `register`.
/// @param name Stable name that identifies the requested object or option.
/// @param model Model resource processed by the operation.
function register(registry, name, model)
  return registerTyped(registry, name, model, MOD_UNKNOWN)
end function

/// Implements the `get` operation for `miniquake.model_registry` (get).
/// @param registry The registry input consumed by `get`.
/// @param name Stable name that identifies the requested object or option.
function get(registry, name)
  index = findIndex(registry, name)
  if index < 0 then return void end if
  return registry.models[index]
end function

/// Return model type derived from the active module state.
/// @param registry The registry input consumed by `modelType`.
/// @param name Stable name that identifies the requested object or option.
function modelType(registry, name)
  index = findIndex(registry, name)
  if index < 0 then return MOD_UNKNOWN end if
  return registry.types[index]
end function

/// Update subsystem configuration for register brush submodels.
/// @param registry The registry input consumed by `registerBrushSubmodels`.
/// @param map The map input consumed by `registerBrushSubmodels`.
function registerBrushSubmodels(registry, map)
  if len(map.models) <= 1 then return 0 end if
  index = 1
  while index < len(map.models)
    name = "*" + index
    registerTyped(registry, name, [map, index], MOD_BRUSH)
    index = index + 1
  end while
  return len(map.models) - 1
end function

/// Loads bytes for `miniquake.model_registry`.
/// @param registry The registry input consumed by `loadBytes`.
/// @param name Stable name that identifies the requested object or option.
/// @param data Input data consumed by the operation.
function loadBytes(registry, name, data)
  if len(data) < 4 then return error(1902, name + ": model file is truncated") end if
  magic = bio.fourCC(data, 0)
  if magic == "IDPO" then return [mdl.Mod_LoadAliasModel(data, name), MOD_ALIAS] end if
  if magic == "IDSP" then return [sprite.Mod_LoadSpriteModel(data, name), MOD_SPRITE] end if
  return [bsp.Mod_LoadBrushModel(data, name), MOD_BRUSH]
end function

/// Mod_LoadModel.  MiniLang objects are relocatable GC values, so the alias
/// cache check is represented by retaining registry.models[index].
/// @param registry The registry input consumed by `Mod_LoadModel`.
/// @param filesystem The filesystem input consumed by `Mod_LoadModel`.
/// @param index Zero-based index of the requested entry.
/// @param crash The crash input consumed by `Mod_LoadModel`.
function Mod_LoadModel(registry, filesystem, index, crash)
  if index < 0 or index >= len(registry.names) then return error(1903, "Mod_LoadModel: bad model index") end if
  if not registry.needLoad[index] and registry.models[index] is not void then
    registry.touched[index] = true
    return registry.models[index]
  end if
  name = registry.names[index]
  data = try(qfs.readFile(filesystem, name))
  if data is error then
    if crash then return error(1904, "Mod_NumForName: " + name + " not found") end if
    return void
  end if
  loaded = loadBytes(registry, name, data)
  if loaded is error then return loaded end if
  model = loaded[0]
  if model is error then return model end if
  // Colored light data is an optional renderer sidecar, never part of BSP29
  // gameplay state. Keep it associated by object identity instead of changing
  // the public BspMap layout used by protocol and differential fixtures.
  if loaded[1] == MOD_BRUSH then coloredLightmaps.loadForMap(filesystem, model) end if
  registry.models[index] = model
  registry.types[index] = loaded[1]
  registry.needLoad[index] = false
  registry.touched[index] = true
  if loaded[1] == MOD_BRUSH then registerBrushSubmodels(registry, model) end if
  return model
end function

/// Mirror Quake's Mod_ForName routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_ForName`.
/// @param filesystem The filesystem input consumed by `Mod_ForName`.
/// @param name Stable name that identifies the requested object or option.
/// @param crash The crash input consumed by `Mod_ForName`.
function Mod_ForName(registry, filesystem, name, crash)
  index = Mod_FindName(registry, name)
  if index is error then return index end if
  return Mod_LoadModel(registry, filesystem, index, crash)
end function

/// Mirror Quake's Mod_TouchModel routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_TouchModel`.
/// @param name Stable name that identifies the requested object or option.
function Mod_TouchModel(registry, name)
  index = Mod_FindName(registry, name)
  if index is error then return index end if
  if not registry.needLoad[index] and registry.types[index] == MOD_ALIAS then
    registry.touched[index] = true
  end if
  return index
end function

/// Mirror Quake's Mod_Extradata routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_Extradata`.
/// @param filesystem The filesystem input consumed by `Mod_Extradata`.
/// @param index Zero-based index of the requested entry.
function Mod_Extradata(registry, filesystem, index)
  if index < 0 or index >= len(registry.models) then return error(1905, "Mod_Extradata: bad model") end if
  value = registry.models[index]
  if value is not void and not registry.needLoad[index] then return value end if
  value = Mod_LoadModel(registry, filesystem, index, true)
  if value is error then return value end if
  if value is void then return error(1906, "Mod_Extradata: caching failed") end if
  return value
end function

/// Mirror Quake's Mod_ClearAll routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_ClearAll`.
function Mod_ClearAll(registry)
  index = 0
  while index < len(registry.names)
    if registry.types[index] != MOD_ALIAS then registry.needLoad[index] = true end if
    index = index + 1
  end while
  return len(registry.names)
end function

/// Mirror Quake's Mod_Print routine and its observable state changes.
/// @param registry The registry input consumed by `Mod_Print`.
function Mod_Print(registry)
  print "Cached models:"
  index = 0
  while index < len(registry.names)
    marker = "       0"
    if registry.models[index] is not void then marker = "  cached" end if
    print marker + " : " + registry.names[index]
    index = index + 1
  end while
  return len(registry.names)
end function

/// Implements the `modelBounds` operation for `miniquake.model_registry` (model bounds).
/// @param registry The registry input consumed by `modelBounds`.
/// @param name Stable name that identifies the requested object or option.
function modelBounds(registry, name)
  index = findIndex(registry, name)
  if index < 0 or registry.models[index] is void then return void end if
  value = registry.models[index]
  if registry.types[index] == MOD_ALIAS then
    return [t.Vec3(-16.0, -16.0, -16.0), t.Vec3(16.0, 16.0, 16.0)]
  end if
  if registry.types[index] == MOD_SPRITE then
    halfWidth = value.width / 2.0
    halfHeight = value.height / 2.0
    return [t.Vec3(-halfWidth, -halfWidth, -halfHeight), t.Vec3(halfWidth, halfWidth, halfHeight)]
  end if
  modelIndex = 0
  map = value
  if value is array then map = value[0]; modelIndex = value[1] end if
  if modelIndex < 0 or modelIndex >= len(map.models) then return void end if
  model = map.models[modelIndex]
  return [model.mins, model.maxs]
end function

/// Implements the `modelRadius` operation for `miniquake.model_registry` (model radius).
/// @param registry The registry input consumed by `modelRadius`.
/// @param name Stable name that identifies the requested object or option.
function modelRadius(registry, name)
  bounds = modelBounds(registry, name)
  if bounds is void then return 0.0 end if
  return world.RadiusFromBounds(bounds[0], bounds[1])
end function
