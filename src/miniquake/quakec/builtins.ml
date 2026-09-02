/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.quakec.builtins.
*/
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

/// Defines the builtin count value used by `miniquake.quakec.builtins`.
const BUILTIN_COUNT = 79
/// Defines the fnv offset value used by `miniquake.quakec.builtins`.
const FNV_OFFSET = 2166136261
/// Defines the fnv prime value used by `miniquake.quakec.builtins`.
const FNV_PRIME = 16777619

/// Tracks the module-level active context state owned by `miniquake.quakec.builtins`.
activeContext = void
/// Tracks the module-level brush bounds names state owned by `miniquake.quakec.builtins`.
brushBoundsNames = []
/// Tracks the module-level brush bounds values state owned by `miniquake.quakec.builtins`.
brushBoundsValues = []

/// Implements the `bind` operation for `miniquake.quakec.builtins` (bind).
/// @param contextValue The context value input consumed by `bind`.
function bind(contextValue)
  global activeContext, brushBoundsNames, brushBoundsValues
  activeContext = contextValue
  // A new QuakeC server context may point at a different -game search path.
  // Keep the Mod_ForName-style cache map-local so identically named mod BSPs
  // never inherit bounds from the previous server.
  brushBoundsNames = []
  brushBoundsValues = []
  return contextValue
end function

/// Implements the `context` operation for `miniquake.quakec.builtins` (context).
function context()
  global activeContext
  return activeContext
end function

/// Ensure sufficient storage or state for global.
/// @param machine The machine input consumed by `ensureGlobal`.
/// @param offset Zero-based offset of the requested data.
function ensureGlobal(machine, offset)
  return qvm.ensureGlobal(machine, offset)
end function

/// Implements the `word` operation for `miniquake.quakec.builtins` (word).
/// @param machine The machine input consumed by `word`.
/// @param offset Zero-based offset of the requested data.
function word(machine, offset)
  ensureGlobal(machine, offset)
  return machine.globals[offset]
end function

/// Update module state for word.
/// @param machine The machine input consumed by `setWord`.
/// @param offset Zero-based offset of the requested data.
/// @param value Value consumed by `setWord`.
function setWord(machine, offset, value)
  ensureGlobal(machine, offset)
  machine.globals[offset] = value & 0xffffffff
  return value
end function

/// Return float value derived from the active module state.
/// @param machine The machine input consumed by `floatValue`.
/// @param offset Zero-based offset of the requested data.
function floatValue(machine, offset)
  return native.bitsFloat(word(machine, offset))
end function

/// Update module state for float.
/// @param machine The machine input consumed by `setFloat`.
/// @param offset Zero-based offset of the requested data.
/// @param value Value consumed by `setFloat`.
function setFloat(machine, offset, value)
  if value is bool then
    if value then value = 1.0 else value = 0.0 end if
  end if
  return setWord(machine, offset, native.floatBits(value))
end function

/// Return vector value derived from the active module state.
/// @param machine The machine input consumed by `vectorValue`.
/// @param offset Zero-based offset of the requested data.
function vectorValue(machine, offset)
  return t.Vec3(floatValue(machine, offset), floatValue(machine, offset + 1), floatValue(machine, offset + 2))
end function

/// Update module state for vector value.
/// @param machine The machine input consumed by `setVectorValue`.
/// @param offset Zero-based offset of the requested data.
/// @param value Value consumed by `setVectorValue`.
function setVectorValue(machine, offset, value)
  setFloat(machine, offset, value.x)
  setFloat(machine, offset + 1, value.y)
  setFloat(machine, offset + 2, value.z)
end function

/// Return parameter offset derived from the active module state.
/// @param index Zero-based index of the requested entry.
function inline parameterOffset(index)
  return op.OFS_PARM0 + index * 3
end function

/// Implements the `parmWord` operation for `miniquake.quakec.builtins` (parm word).
/// @param machine The machine input consumed by `parmWord`.
/// @param index Zero-based index of the requested entry.
function parmWord(machine, index)
  return word(machine, parameterOffset(index))
end function

/// Implements the `parmFloat` operation for `miniquake.quakec.builtins` (parm float).
/// @param machine The machine input consumed by `parmFloat`.
/// @param index Zero-based index of the requested entry.
function parmFloat(machine, index)
  return floatValue(machine, parameterOffset(index))
end function

/// Return parm vector derived from the active module state.
/// @param machine The machine input consumed by `parmVector`.
/// @param index Zero-based index of the requested entry.
function parmVector(machine, index)
  return vectorValue(machine, parameterOffset(index))
end function

/// Implements the `stringAt` operation for `miniquake.quakec.builtins` (string at).
/// @param machine The machine input consumed by `stringAt`.
/// @param handle The handle input consumed by `stringAt`.
function stringAt(machine, handle)
  return qvm.stringValue(machine, handle)
end function

/// Implements the `parmString` operation for `miniquake.quakec.builtins` (parm string).
/// @param machine The machine input consumed by `parmString`.
/// @param index Zero-based index of the requested entry.
function parmString(machine, index)
  return stringAt(machine, parmWord(machine, index))
end function

/// Implements the `varString` operation for `miniquake.quakec.builtins` (var string).
/// @param machine The machine input consumed by `varString`.
/// @param first The first input consumed by `varString`.
function varString(machine, first)
  text = ""
  index = first
  while index < machine.argCount
    text = text + parmString(machine, index)
    index = index + 1
  end while
  return text
end function

/// Implements the `internString` operation for `miniquake.quakec.builtins` (intern string).
/// @param machine The machine input consumed by `internString`.
/// @param text Text to parse or process.
function internString(machine, text)
  return qvm.internString(machine, text)
end function

/// Implements the `returnWord` operation for `miniquake.quakec.builtins` (return word).
/// @param machine The machine input consumed by `returnWord`.
/// @param value Value consumed by `returnWord`.
function returnWord(machine, value)
  setWord(machine, op.OFS_RETURN, value)
  setWord(machine, op.OFS_RETURN + 1, 0)
  setWord(machine, op.OFS_RETURN + 2, 0)
end function

/// Implements the `returnFloat` operation for `miniquake.quakec.builtins` (return float).
/// @param machine The machine input consumed by `returnFloat`.
/// @param value Value consumed by `returnFloat`.
function returnFloat(machine, value)
  setFloat(machine, op.OFS_RETURN, value)
  setWord(machine, op.OFS_RETURN + 1, 0)
  setWord(machine, op.OFS_RETURN + 2, 0)
end function

/// Return return vector derived from the active module state.
/// @param machine The machine input consumed by `returnVector`.
/// @param value Value consumed by `returnVector`.
function returnVector(machine, value)
  setVectorValue(machine, op.OFS_RETURN, value)
end function

/// Implements the `returnString` operation for `miniquake.quakec.builtins` (return string).
/// @param machine The machine input consumed by `returnString`.
/// @param text Text to parse or process.
function returnString(machine, text)
  returnWord(machine, internString(machine, text))
end function

/// Implements the `returnTemporaryString` operation for `miniquake.quakec.builtins` (return temporary string).
/// @param machine The machine input consumed by `returnTemporaryString`.
/// @param text Text to parse or process.
function returnTemporaryString(machine, text)
  returnWord(machine, qvm.setTemporaryString(machine, text))
end function

/// Return definition offset derived from the active module state.
/// @param definitions The definitions input consumed by `definitionOffset`.
/// @param name Stable name that identifies the requested object or option.
function definitionOffset(definitions, name)
  for each definition in definitions
    if definition.name == name then return definition.offset end if
  end for
  return -1
end function

/// Return global offset derived from the active module state.
/// @param machine The machine input consumed by `globalOffset`.
/// @param name Stable name that identifies the requested object or option.
function globalOffset(machine, name)
  return definitionOffset(machine.program.globalDefs, name)
end function

/// Implements the `fieldOffset` operation for `miniquake.quakec.builtins` (field offset).
/// @param machine The machine input consumed by `fieldOffset`.
/// @param name Stable name that identifies the requested object or option.
function fieldOffset(machine, name)
  return definitionOffset(machine.program.fieldDefs, name)
end function

/// Implements the `globalWord` operation for `miniquake.quakec.builtins` (global word).
/// @param machine The machine input consumed by `globalWord`.
/// @param name Stable name that identifies the requested object or option.
function globalWord(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return 0 end if
  return word(machine, offset)
end function

/// Return global vector derived from the active module state.
/// @param machine The machine input consumed by `globalVector`.
/// @param name Stable name that identifies the requested object or option.
function globalVector(machine, name)
  offset = globalOffset(machine, name)
  if offset < 0 then return t.Vec3(0.0, 0.0, 0.0) end if
  return vectorValue(machine, offset)
end function

/// Update module state for global word.
/// @param machine The machine input consumed by `setGlobalWord`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setGlobalWord`.
function setGlobalWord(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setWord(machine, offset, value)
  return true
end function

/// Update module state for global float.
/// @param machine The machine input consumed by `setGlobalFloat`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setGlobalFloat`.
function setGlobalFloat(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setFloat(machine, offset, value)
  return true
end function

/// Update module state for global vector.
/// @param machine The machine input consumed by `setGlobalVector`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setGlobalVector`.
function setGlobalVector(machine, name, value)
  offset = globalOffset(machine, name)
  if offset < 0 then return false end if
  setVectorValue(machine, offset, value)
  return true
end function

/// Implements the `entityWord` operation for `miniquake.quakec.builtins` (entity word).
/// @param machine The machine input consumed by `entityWord`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function entityWord(machine, entityIndex, name)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return 0 end if
  return machine.edicts[entityIndex][offset]
end function

/// Update module state for entity word.
/// @param machine The machine input consumed by `setEntityWord`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityWord`.
function setEntityWord(machine, entityIndex, name, value)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return false end if
  machine.edicts[entityIndex][offset] = value & 0xffffffff
  return true
end function

/// Implements the `entityFloat` operation for `miniquake.quakec.builtins` (entity float).
/// @param machine The machine input consumed by `entityFloat`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function entityFloat(machine, entityIndex, name)
  return native.bitsFloat(entityWord(machine, entityIndex, name))
end function

/// Sets entity float for `miniquake.quakec.builtins`.
/// @param machine The machine input consumed by `setEntityFloat`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityFloat`.
function setEntityFloat(machine, entityIndex, name, value)
  return setEntityWord(machine, entityIndex, name, native.floatBits(value))
end function

/// Implements the `entityVector` operation for `miniquake.quakec.builtins` (entity vector).
/// @param machine The machine input consumed by `entityVector`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function entityVector(machine, entityIndex, name)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return t.Vec3(0.0, 0.0, 0.0) end if
  return t.Vec3(native.bitsFloat(machine.edicts[entityIndex][offset]), native.bitsFloat(machine.edicts[entityIndex][offset + 1]), native.bitsFloat(machine.edicts[entityIndex][offset + 2]))
end function

/// Sets entity vector for `miniquake.quakec.builtins`.
/// @param machine The machine input consumed by `setEntityVector`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityVector`.
function setEntityVector(machine, entityIndex, name, value)
  offset = fieldOffset(machine, name)
  if offset < 0 or entityIndex < 0 or entityIndex >= len(machine.edicts) then return false end if
  machine.edicts[entityIndex][offset] = native.floatBits(value.x)
  machine.edicts[entityIndex][offset + 1] = native.floatBits(value.y)
  machine.edicts[entityIndex][offset + 2] = native.floatBits(value.z)
  return true
end function

/// Implements the `entityString` operation for `miniquake.quakec.builtins` (entity string).
/// @param machine The machine input consumed by `entityString`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function entityString(machine, entityIndex, name)
  return stringAt(machine, entityWord(machine, entityIndex, name))
end function

/// Update module state for bounds.
/// @param machine The machine input consumed by `updateBounds`.
/// @param entityIndex Zero-based index of the requested entry.
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

/// Update module state for min max size.
/// @param machine The machine input consumed by `setMinMaxSize`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param mins The mins input consumed by `setMinMaxSize`.
/// @param maxs The maxs input consumed by `setMinMaxSize`.
/// @param rotate The rotate input consumed by `setMinMaxSize`.
function setMinMaxSize(machine, entityIndex, mins, maxs, rotate)
  if mins.x > maxs.x or mins.y > maxs.y or mins.z > maxs.z then return error(2652, "PF_setsize: backwards mins/maxs") end if
  // MiniQuake's SetMinMaxSize forcibly disables rotation despite accepting the
  // parameter, so the stored axis-aligned bounds are always the input bounds.
  setEntityVector(machine, entityIndex, "mins", mins)
  setEntityVector(machine, entityIndex, "maxs", maxs)
  updateBounds(machine, entityIndex)
  return true
end function

/// External brush entities (ammo/health boxes, explosive barrels, etc.) are
/// complete BSP29 files.  WinQuake's Mod_ForName loads their first dmodel and
/// PF_setmodel copies its expanded mins/maxs into the edict.  Parsing only the
/// model lump here keeps the server independent of renderer-owned model data
/// and avoids loading all render/lightmap lumps during QuakeC spawning.
/// @param data Input data consumed by the operation.
/// @param modelName Name that identifies the requested value or resource.
function brushModelBounds(data, modelName)
  headerSize = 4 + c.HEADER_LUMPS * 8
  if len(data) < headerSize then return error(2669, "PF_setmodel: truncated BSP " + modelName) end if
  version = bio.i32(data, 0)
  if version != c.BSP_VERSION then return error(2669, "PF_setmodel: unsupported BSP version " + version + " in " + modelName) end if
  descriptor = 4 + c.LUMP_MODELS * 8
  lumpOffset = bio.i32(data, descriptor)
  lumpLength = bio.i32(data, descriptor + 4)
  if lumpOffset < 0 or lumpLength < 64 or lumpLength % 64 != 0 or lumpOffset + lumpLength > len(data) then
    return error(2669, "PF_setmodel: invalid BSP model lump in " + modelName)
  end if
  // Mod_LoadSubmodels spreads every side by one unit before setmodel uses it.
  mins = t.Vec3(
    bio.f32(data, lumpOffset) - 1.0,
    bio.f32(data, lumpOffset + 4) - 1.0,
    bio.f32(data, lumpOffset + 8) - 1.0,
  )
  maxs = t.Vec3(
    bio.f32(data, lumpOffset + 12) + 1.0,
    bio.f32(data, lumpOffset + 16) + 1.0,
    bio.f32(data, lumpOffset + 20) + 1.0,
  )
  return [mins, maxs]
end function

/// Implements the `cachedBrushModelBounds` operation for `miniquake.quakec.builtins` (cached brush model bounds).
/// @param ctx The ctx input consumed by `cachedBrushModelBounds`.
/// @param modelName Name that identifies the requested value or resource.
function cachedBrushModelBounds(ctx, modelName)
  global brushBoundsNames, brushBoundsValues
  index = 0
  while index < len(brushBoundsNames)
    if brushBoundsNames[index] == modelName then return brushBoundsValues[index] end if
    index = index + 1
  end while
  if ctx.filesystem is void then return error(2668, "PF_setmodel: no filesystem for " + modelName) end if
  data = try(filesystem.readFile(ctx.filesystem, modelName))
  bounds = try(brushModelBounds(data, modelName))
  brushBoundsNames = brushBoundsNames + [modelName]
  brushBoundsValues = brushBoundsValues + [bounds]
  return bounds
end function

/// Implements the `modelBounds` operation for `miniquake.quakec.builtins` (model bounds).
/// @param machine The machine input consumed by `modelBounds`.
/// @param modelName Name that identifies the requested value or resource.
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
    // Mod_LoadAliasModel in MiniQuake explicitly uses this fixed FIXME box.
    if suffix == ".mdl" then
      return [t.Vec3(-16.0, -16.0, -16.0), t.Vec3(16.0, 16.0, 16.0)]
    end if
    if suffix == ".bsp" then return cachedBrushModelBounds(ctx, modelName) end if
    if suffix == ".spr" then
      if ctx.filesystem is void then return error(2668, "PF_setmodel: no filesystem for " + modelName) end if
      data = filesystem.readFile(ctx.filesystem, modelName)
      model = sprite.parse(data, modelName)
      return sprite.spriteModelBounds(model)
    end if
  end if
  return [zero, zero]
end function

/// Allocate and initialize edict.
/// @param machine The machine input consumed by `allocateEdict`.
function allocateEdict(machine)
  ctx = context()
  first = 1
  if ctx is not void and ctx.server is not void then
    first = ctx.server.maxClients + 1
  end if
  return qcedict.allocate(machine, first)
end function

/// Release or remove state for edict.
/// @param machine The machine input consumed by `releaseEdict`.
/// @param entityIndex Zero-based index of the requested entry.
function releaseEdict(machine, entityIndex)
  return qcedict.free(machine, entityIndex)
end function

/// Preload and register the index asset.
/// @param values The values input consumed by `precacheIndex`.
/// @param name Stable name that identifies the requested object or option.
function precacheIndex(values, name)
  index = 0
  while index < len(values)
    if values[index] == name then return index end if
    index = index + 1
  end while
  return -1
end function

/// Report whether active edict limit holds for the active state.
/// @param machine The machine input consumed by `activeEdictLimit`.
function activeEdictLimit(machine)
  ctx = context()
  if ctx is not void and ctx.edicts is not void then return ctx.edicts.numEdicts end if
  return len(machine.edicts)
end function

/// Implements the `badPrecacheString` operation for `miniquake.quakec.builtins` (bad precache string).
/// @param name Stable name that identifies the requested object or option.
function badPrecacheString(name)
  data = bytes(name)
  return len(data) == 0 or data[0] <= 32
end function

/// Add state for append console.
/// @param text Text to parse or process.
function appendConsole(text)
  ctx = context()
  ctx.consoleLines = ctx.consoleLines + [text]
end function

/// Implements the `fixme` operation for `miniquake.quakec.builtins` (fixme).
/// @param machine The machine input consumed by `fixme`.
function fixme(machine)
  return error(2650, "unimplemented bulitin")
end function

/// Create and initialize vectors.
/// @param machine The machine input consumed by `makeVectors`.
function makeVectors(machine)
  vectors = math.angleVectors(parmVector(machine, 0))
  setGlobalVector(machine, "v_forward", vectors[0])
  setGlobalVector(machine, "v_right", vectors[1])
  setGlobalVector(machine, "v_up", vectors[2])
  return true
end function

/// Update module state for origin.
/// @param machine The machine input consumed by `setOrigin`.
function setOrigin(machine)
  entityIndex = parmWord(machine, 0)
  setEntityVector(machine, entityIndex, "origin", parmVector(machine, 1))
  updateBounds(machine, entityIndex)
  return true
end function

/// Update module state for model.
/// @param machine The machine input consumed by `setModel`.
function setModel(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  modelName = parmString(machine, 1)
  modelIndex = precacheIndex(ctx.modelPrecache, modelName)
  if modelIndex < 0 then return error(2651, "PF_setmodel: no precache for " + modelName) end if
  setEntityWord(machine, entityIndex, "model", parmWord(machine, 1))
  setEntityFloat(machine, entityIndex, "modelindex", modelIndex)
  bounds = try(modelBounds(machine, modelName))
  setMinMaxSize(machine, entityIndex, bounds[0], bounds[1], true)
  return true
end function

/// Update module state for size.
/// @param machine The machine input consumed by `setSize`.
function setSize(machine)
  entityIndex = parmWord(machine, 0)
  mins = parmVector(machine, 1)
  maxs = parmVector(machine, 2)
  return setMinMaxSize(machine, entityIndex, mins, maxs, false)
end function

/// Implements the `breakBuiltin` operation for `miniquake.quakec.builtins` (break builtin).
/// @param machine The machine input consumed by `breakBuiltin`.
function breakBuiltin(machine)
  appendConsole("break statement")
  // The C builtin deliberately writes through address -4 to break into a
  // debugger.  MiniLang cannot reproduce memory corruption, but it must still
  // abort QuakeC execution instead of returning to the calling mod.
  return error(2670, "break statement")
end function

/// Implements the `randomBuiltin` operation for `miniquake.quakec.builtins` (random builtin).
/// @param machine The machine input consumed by `randomBuiltin`.
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

/// Implements the `soundBuiltin` operation for `miniquake.quakec.builtins` (sound builtin).
/// @param machine The machine input consumed by `soundBuiltin`.
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

/// Convert builtin into its canonical representation.
/// @param machine The machine input consumed by `normalizeBuiltin`.
function normalizeBuiltin(machine)
  returnVector(machine, math.normalize(parmVector(machine, 0)))
  return true
end function

/// Report builtin and return the corresponding failure status.
/// @param machine The machine input consumed by `errorBuiltin`.
function errorBuiltin(machine)
  text = varString(machine, 0)
  appendConsole("======SERVER ERROR: " + text)
  appendConsole(qcedict.ED_Print(machine, globalWord(machine, "self")))
  return error(2653, "QuakeC error: " + text)
end function

/// Implements the `objectErrorBuiltin` operation for `miniquake.quakec.builtins` (object error builtin).
/// @param machine The machine input consumed by `objectErrorBuiltin`.
function objectErrorBuiltin(machine)
  selfIndex = globalWord(machine, "self")
  text = varString(machine, 0)
  appendConsole("======OBJECT ERROR: " + text)
  appendConsole(qcedict.ED_Print(machine, selfIndex))
  releaseEdict(machine, selfIndex)
  return error(2654, "QuakeC object error: " + text)
end function

/// Implements the `vectorLengthBuiltin` operation for `miniquake.quakec.builtins` (vector length builtin).
/// @param machine The machine input consumed by `vectorLengthBuiltin`.
function vectorLengthBuiltin(machine)
  returnFloat(machine, math.length(parmVector(machine, 0)))
  return true
end function

/// Implements the `vectorYawBuiltin` operation for `miniquake.quakec.builtins` (vector yaw builtin).
/// @param machine The machine input consumed by `vectorYawBuiltin`.
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

/// Allocate and initialize builtin.
/// @param machine The machine input consumed by `spawnBuiltin`.
function spawnBuiltin(machine)
  entityIndex = allocateEdict(machine)
  returnWord(machine, entityIndex)
  return true
end function

/// Release state for remove builtin.
/// @param machine The machine input consumed by `removeBuiltin`.
function removeBuiltin(machine)
  return releaseEdict(machine, parmWord(machine, 0))
end function

/// Update module state for trace globals.
/// @param machine The machine input consumed by `setTraceGlobals`.
/// @param trace The trace input consumed by `setTraceGlobals`.
function setTraceGlobals(machine, trace)
  setGlobalFloat(machine, "trace_allsolid", trace.allSolid)
  setGlobalFloat(machine, "trace_startsolid", trace.startSolid)
  setGlobalFloat(machine, "trace_fraction", trace.fraction)
  setGlobalVector(machine, "trace_endpos", trace.endPosition)
  setGlobalVector(machine, "trace_plane_normal", trace.plane.normal)
  setGlobalFloat(machine, "trace_plane_dist", trace.plane.dist)
  // PF_traceline publishes the world edict when SV_Move reports no entity.
  // The collision layer uses -1 as its private no-hit sentinel; exposing that
  // value as an unsigned QuakeC entity creates 0xffffffff and crashes on the
  // next field access with "entity outside edict table".
  traceEntity = trace.entity
  if traceEntity < 0 then traceEntity = 0 end if
  setGlobalWord(machine, "trace_ent", traceEntity)
  setGlobalFloat(machine, "trace_inopen", trace.inOpen)
  setGlobalFloat(machine, "trace_inwater", trace.inWater)
end function

/// Trace line builtin through the collision world.
/// @param machine The machine input consumed by `traceLineBuiltin`.
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

/// Create and initialize check client.
/// @param machine The machine input consumed by `newCheckClient`.
/// @param current The current input consumed by `newCheckClient`.
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

/// Validate client builtin and report any incompatibility.
/// @param machine The machine input consumed by `checkClientBuiltin`.
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

/// Return builtin.
/// @param machine The machine input consumed by `findBuiltin`.
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

/// Preload and register the sound builtin asset.
/// @param machine The machine input consumed by `precacheSoundBuiltin`.
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

/// Preload and register the model builtin asset.
/// @param machine The machine input consumed by `precacheModelBuiltin`.
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

/// Implements the `clientMessageBuffer` operation for `miniquake.quakec.builtins` (client message buffer).
/// @param entityIndex Zero-based index of the requested entry.
function clientMessageBuffer(entityIndex)
  ctx = context()
  if entityIndex < 1 or entityIndex > len(ctx.clientMessages) then return void end if
  return ctx.clientMessages[entityIndex - 1]
end function

/// Implements the `stuffCommandBuiltin` operation for `miniquake.quakec.builtins` (stuff command builtin).
/// @param machine The machine input consumed by `stuffCommandBuiltin`.
function stuffCommandBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then return error(2663, "PF_stuffcmd: parm 0 is not a client") end if
  msg.writeByte(buffer, c.SVC_STUFFTEXT)
  msg.writeString(buffer, parmString(machine, 1))
  return true
end function

/// Return radius builtin.
/// @param machine The machine input consumed by `findRadiusBuiltin`.
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

/// Implements the `broadcastPrintBuiltin` operation for `miniquake.quakec.builtins` (broadcast print builtin).
/// @param machine The machine input consumed by `broadcastPrintBuiltin`.
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

/// Implements the `clientPrintBuiltin` operation for `miniquake.quakec.builtins` (client print builtin).
/// @param machine The machine input consumed by `clientPrintBuiltin`.
function clientPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to sprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, varString(machine, 1))
  return true
end function

/// Implements the `debugPrintBuiltin` operation for `miniquake.quakec.builtins` (debug print builtin).
/// @param machine The machine input consumed by `debugPrintBuiltin`.
function debugPrintBuiltin(machine)
  appendConsole(varString(machine, 0))
  return true
end function

/// Return floor number derived from the active module state.
/// @param value Value consumed by `floorNumber`.
function floorNumber(value)
  truncated = native.trunc(value)
  if value < truncated then return truncated - 1 end if
  return truncated
end function

/// Return ceil number derived from the active module state.
/// @param value Value consumed by `ceilNumber`.
function ceilNumber(value)
  truncated = native.trunc(value)
  if value > truncated then return truncated + 1 end if
  return truncated
end function

/// Implements the `floatToStringBuiltin` operation for `miniquake.quakec.builtins` (float to string builtin).
/// @param machine The machine input consumed by `floatToStringBuiltin`.
function floatToStringBuiltin(machine)
  value = parmFloat(machine, 0)
  rounded = native.trunc(value)
  if value == rounded then returnTemporaryString(machine, "" + rounded) else returnTemporaryString(machine, fixedOneDecimal(value)) end if
  return true
end function

/// Implements the `roundHalfEvenPositive` operation for `miniquake.quakec.builtins` (round half even positive).
/// @param value Value consumed by `roundHalfEvenPositive`.
function roundHalfEvenPositive(value)
  lower = floorNumber(value)
  fraction = value - lower
  if fraction < 0.5 then return lower end if
  if fraction > 0.5 then return lower + 1 end if
  if (lower % 2) != 0 then return lower + 1 end if
  return lower
end function

/// Implements the `fixedOneDecimal` operation for `miniquake.quakec.builtins` (fixed one decimal).
/// @param value Value consumed by `fixedOneDecimal`.
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

/// Implements the `vectorToStringBuiltin` operation for `miniquake.quakec.builtins` (vector to string builtin).
/// @param machine The machine input consumed by `vectorToStringBuiltin`.
function vectorToStringBuiltin(machine)
  value = parmVector(machine, 0)
  returnTemporaryString(machine, "'" + fixedOneDecimal(value.x) + " " + fixedOneDecimal(value.y) + " " + fixedOneDecimal(value.z) + "'")
  return true
end function

/// Report whether active edict count holds for the active state.
/// @param machine The machine input consumed by `activeEdictCount`.
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

/// Implements the `coreDumpBuiltin` operation for `miniquake.quakec.builtins` (core dump builtin).
/// @param machine The machine input consumed by `coreDumpBuiltin`.
function coreDumpBuiltin(machine)
  appendConsole(qcedict.ED_PrintEdicts(machine))
  return true
end function

/// Trace on builtin through the collision world.
/// @param machine The machine input consumed by `traceOnBuiltin`.
function traceOnBuiltin(machine)
  machine.trace = true
  return true
end function

/// Trace off builtin through the collision world.
/// @param machine The machine input consumed by `traceOffBuiltin`.
function traceOffBuiltin(machine)
  machine.trace = false
  return true
end function

/// Implements the `entityPrintBuiltin` operation for `miniquake.quakec.builtins` (entity print builtin).
/// @param machine The machine input consumed by `entityPrintBuiltin`.
function entityPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  appendConsole(qcedict.ED_Print(machine, entityIndex))
  return true
end function

/// Trace entity move through the collision world.
/// @param machine The machine input consumed by `traceEntityMove`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param start The start input consumed by `traceEntityMove`.
/// @param finish The finish input consumed by `traceEntityMove`.
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

/// Implements the `walkMoveBuiltin` operation for `miniquake.quakec.builtins` (walk move builtin).
/// @param machine The machine input consumed by `walkMoveBuiltin`.
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

/// Release state for drop to floor builtin.
/// @param machine The machine input consumed by `dropToFloorBuiltin`.
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

/// Implements the `lightStyleBuiltin` operation for `miniquake.quakec.builtins` (light style builtin).
/// @param machine The machine input consumed by `lightStyleBuiltin`.
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

/// Implements the `roundBuiltin` operation for `miniquake.quakec.builtins` (round builtin).
/// @param machine The machine input consumed by `roundBuiltin`.
function roundBuiltin(machine)
  value = parmFloat(machine, 0)
  if value > 0.0 then
    returnFloat(machine, floorNumber(value + 0.5))
  else
    returnFloat(machine, ceilNumber(value - 0.5))
  end if
  return true
end function

/// Implements the `floorBuiltin` operation for `miniquake.quakec.builtins` (floor builtin).
/// @param machine The machine input consumed by `floorBuiltin`.
function floorBuiltin(machine)
  returnFloat(machine, floorNumber(parmFloat(machine, 0)))
  return true
end function

/// Implements the `ceilBuiltin` operation for `miniquake.quakec.builtins` (ceil builtin).
/// @param machine The machine input consumed by `ceilBuiltin`.
function ceilBuiltin(machine)
  returnFloat(machine, ceilNumber(parmFloat(machine, 0)))
  return true
end function

/// Validate bottom builtin and report any incompatibility.
/// @param machine The machine input consumed by `checkBottomBuiltin`.
function checkBottomBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  if ctx.server is not void and ctx.server.worldModel is not void and collision.checkBottom(ctx.server, entityIndex) then returnFloat(machine, 1.0) else returnFloat(machine, 0.0) end if
  return true
end function

/// Implements the `pointContentsBuiltin` operation for `miniquake.quakec.builtins` (point contents builtin).
/// @param machine The machine input consumed by `pointContentsBuiltin`.
function pointContentsBuiltin(machine)
  if context().worldMap is void then returnFloat(machine, c.CONTENTS_EMPTY) else returnFloat(machine, world.pointContentsWorld(context().worldMap, parmVector(machine, 0))) end if
  return true
end function

/// Implements the `absoluteBuiltin` operation for `miniquake.quakec.builtins` (absolute builtin).
/// @param machine The machine input consumed by `absoluteBuiltin`.
function absoluteBuiltin(machine)
  value = parmFloat(machine, 0)
  if value == 0.0 then value = 0.0 else if value < 0.0 then value = -value end if
  returnFloat(machine, value)
  return true
end function

/// Implements the `aimBuiltin` operation for `miniquake.quakec.builtins` (aim builtin).
/// @param machine The machine input consumed by `aimBuiltin`.
function aimBuiltin(machine)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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

/// Implements the `cvarBuiltin` operation for `miniquake.quakec.builtins` (cvar builtin).
/// @param machine The machine input consumed by `cvarBuiltin`.
function cvarBuiltin(machine)
  returnFloat(machine, cvar.variableValue(context().cvars, parmString(machine, 0)))
  return true
end function

/// Implements the `localCommandBuiltin` operation for `miniquake.quakec.builtins` (local command builtin).
/// @param machine The machine input consumed by `localCommandBuiltin`.
function localCommandBuiltin(machine)
  cmd.addText(context().commands, parmString(machine, 0))
  return true
end function

/// Return next entity builtin for the active module state.
/// @param machine The machine input consumed by `nextEntityBuiltin`.
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

/// Implements the `particleBuiltin` operation for `miniquake.quakec.builtins` (particle builtin).
/// @param machine The machine input consumed by `particleBuiltin`.
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

/// Update subsystem configuration for change yaw builtin.
/// @param machine The machine input consumed by `changeYawBuiltin`.
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

/// Implements the `vectorAnglesBuiltin` operation for `miniquake.quakec.builtins` (vector angles builtin).
/// @param machine The machine input consumed by `vectorAnglesBuiltin`.
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

/// Implements the `destinationBuffer` operation for `miniquake.quakec.builtins` (destination buffer).
/// @param machine The machine input consumed by `destinationBuffer`.
/// @param destination Destination value or collection to update.
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

/// Encode and write byte builtin.
/// @param machine The machine input consumed by `writeByteBuiltin`.
function writeByteBuiltin(machine)
  msg.writeByte(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

/// Encode and write char builtin.
/// @param machine The machine input consumed by `writeCharBuiltin`.
function writeCharBuiltin(machine)
  msg.writeChar(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

/// Encode and write short builtin.
/// @param machine The machine input consumed by `writeShortBuiltin`.
function writeShortBuiltin(machine)
  msg.writeShort(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

/// Encode and write long builtin.
/// @param machine The machine input consumed by `writeLongBuiltin`.
function writeLongBuiltin(machine)
  msg.writeLong(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), native.trunc(parmFloat(machine, 1)))
  return true
end function

/// Encode and write coord builtin.
/// @param machine The machine input consumed by `writeCoordBuiltin`.
function writeCoordBuiltin(machine)
  msg.writeCoord(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmFloat(machine, 1))
  return true
end function

/// Encode and write angle builtin.
/// @param machine The machine input consumed by `writeAngleBuiltin`.
function writeAngleBuiltin(machine)
  msg.writeAngle(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmFloat(machine, 1))
  return true
end function

/// Encode and write string builtin.
/// @param machine The machine input consumed by `writeStringBuiltin`.
function writeStringBuiltin(machine)
  msg.writeString(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmString(machine, 1))
  return true
end function

/// Encode and write entity builtin.
/// @param machine The machine input consumed by `writeEntityBuiltin`.
function writeEntityBuiltin(machine)
  msg.writeShort(destinationBuffer(machine, native.trunc(parmFloat(machine, 0))), parmWord(machine, 1))
  return true
end function

/// Transfer data for move to goal builtin.
/// @param machine The machine input consumed by `moveToGoalBuiltin`.
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

/// Preload and register the file builtin asset.
/// @param machine The machine input consumed by `precacheFileBuiltin`.
function precacheFileBuiltin(machine)
  returnWord(machine, parmWord(machine, 0))
  return true
end function

/// Encode and write static baseline.
/// @param buffer The buffer input consumed by `writeStaticBaseline`.
/// @param machine The machine input consumed by `writeStaticBaseline`.
/// @param entityIndex Zero-based index of the requested entry.
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

/// Create and initialize static builtin.
/// @param machine The machine input consumed by `makeStaticBuiltin`.
function makeStaticBuiltin(machine)
  ctx = context()
  entityIndex = parmWord(machine, 0)
  writeStaticBaseline(ctx.signon, machine, entityIndex)
  releaseEdict(machine, entityIndex)
  return true
end function

/// Update subsystem configuration for change level builtin.
/// @param machine The machine input consumed by `changeLevelBuiltin`.
function changeLevelBuiltin(machine)
  ctx = context()
  if ctx.changeLevel == "" then
    ctx.changeLevel = parmString(machine, 0)
    if ctx.commands is not void then cmd.addText(ctx.commands, "changelevel " + ctx.changeLevel + "\n") end if
  end if
  return true
end function

/// Implements the `cvarSetBuiltin` operation for `miniquake.quakec.builtins` (cvar set builtin).
/// @param machine The machine input consumed by `cvarSetBuiltin`.
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

/// Implements the `centerPrintBuiltin` operation for `miniquake.quakec.builtins` (center print builtin).
/// @param machine The machine input consumed by `centerPrintBuiltin`.
function centerPrintBuiltin(machine)
  entityIndex = parmWord(machine, 0)
  buffer = clientMessageBuffer(entityIndex)
  if buffer is void then appendConsole("tried to centerprint to a non-client"); return true end if
  msg.writeByte(buffer, c.SVC_CENTERPRINT)
  msg.writeString(buffer, varString(machine, 1))
  return true
end function

/// Implements the `ambientSoundBuiltin` operation for `miniquake.quakec.builtins` (ambient sound builtin).
/// @param machine The machine input consumed by `ambientSoundBuiltin`.
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

/// Update module state for spawn parms builtin.
/// @param machine The machine input consumed by `setSpawnParmsBuiltin`.
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

// Return builtin names derived from the active module state.
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

/// Implements the `fixmeSlots` operation for `miniquake.quakec.builtins` (fixme slots).
function fixmeSlots()
  return [0, 5, 33, 39, 42, 50, 60, 61, 62, 63, 64, 65, 66, 71]
end function

/// Implements the `builtinContractFingerprint` operation for `miniquake.quakec.builtins` (builtin contract fingerprint).
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

/// Implements the `install` operation for `miniquake.quakec.builtins` (install).
/// @param machine The machine input consumed by `install`.
/// @param contextValue The context value input consumed by `install`.
function install(machine, contextValue)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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

/// MiniQuake pr_cmds.c entry points.  These names intentionally mirror the C
/// source so every target function has a concrete, searchable MiniLang pendant.
/// @param machine The machine input consumed by `PF_VarString`.
/// @param first The first input consumed by `PF_VarString`.
function PF_VarString(machine, first)
  return varString(machine, first)
end function

/// Mirror Quake's PF_error routine and its observable state changes.
/// @param machine The machine input consumed by `PF_error`.
function PF_error(machine)
  return errorBuiltin(machine)
end function

/// Mirror Quake's PF_objerror routine and its observable state changes.
/// @param machine The machine input consumed by `PF_objerror`.
function PF_objerror(machine)
  return objectErrorBuiltin(machine)
end function

/// Mirror Quake's PF_makevectors routine and its observable state changes.
/// @param machine The machine input consumed by `PF_makevectors`.
function PF_makevectors(machine)
  return makeVectors(machine)
end function

/// Mirror Quake's PF_setorigin routine and its observable state changes.
/// @param machine The machine input consumed by `PF_setorigin`.
function PF_setorigin(machine)
  return setOrigin(machine)
end function

/// Update module state for min max size.
/// @param machine The machine input consumed by `SetMinMaxSize`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param mins The mins input consumed by `SetMinMaxSize`.
/// @param maxs The maxs input consumed by `SetMinMaxSize`.
/// @param rotate The rotate input consumed by `SetMinMaxSize`.
function SetMinMaxSize(machine, entityIndex, mins, maxs, rotate)
  return setMinMaxSize(machine, entityIndex, mins, maxs, rotate)
end function

/// Mirror Quake's PF_setsize routine and its observable state changes.
/// @param machine The machine input consumed by `PF_setsize`.
function PF_setsize(machine)
  return setSize(machine)
end function

/// Mirror Quake's PF_setmodel routine and its observable state changes.
/// @param machine The machine input consumed by `PF_setmodel`.
function PF_setmodel(machine)
  return setModel(machine)
end function

/// Mirror Quake's PF_bprint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_bprint`.
function PF_bprint(machine)
  return broadcastPrintBuiltin(machine)
end function

/// Mirror Quake's PF_sprint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_sprint`.
function PF_sprint(machine)
  return clientPrintBuiltin(machine)
end function

/// Mirror Quake's PF_centerprint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_centerprint`.
function PF_centerprint(machine)
  return centerPrintBuiltin(machine)
end function

/// Mirror Quake's PF_normalize routine and its observable state changes.
/// @param machine The machine input consumed by `PF_normalize`.
function PF_normalize(machine)
  return normalizeBuiltin(machine)
end function

/// Mirror Quake's PF_vlen routine and its observable state changes.
/// @param machine The machine input consumed by `PF_vlen`.
function PF_vlen(machine)
  return vectorLengthBuiltin(machine)
end function

/// Mirror Quake's PF_vectoyaw routine and its observable state changes.
/// @param machine The machine input consumed by `PF_vectoyaw`.
function PF_vectoyaw(machine)
  return vectorYawBuiltin(machine)
end function

/// Mirror Quake's PF_vectoangles routine and its observable state changes.
/// @param machine The machine input consumed by `PF_vectoangles`.
function PF_vectoangles(machine)
  return vectorAnglesBuiltin(machine)
end function

/// Mirror Quake's PF_random routine and its observable state changes.
/// @param machine The machine input consumed by `PF_random`.
function PF_random(machine)
  return randomBuiltin(machine)
end function

/// Mirror Quake's PF_particle routine and its observable state changes.
/// @param machine The machine input consumed by `PF_particle`.
function PF_particle(machine)
  return particleBuiltin(machine)
end function

/// Mirror Quake's PF_ambientsound routine and its observable state changes.
/// @param machine The machine input consumed by `PF_ambientsound`.
function PF_ambientsound(machine)
  return ambientSoundBuiltin(machine)
end function

/// Mirror Quake's PF_sound routine and its observable state changes.
/// @param machine The machine input consumed by `PF_sound`.
function PF_sound(machine)
  return soundBuiltin(machine)
end function

/// Mirror Quake's PF_break routine and its observable state changes.
/// @param machine The machine input consumed by `PF_break`.
function PF_break(machine)
  return breakBuiltin(machine)
end function

/// Mirror Quake's PF_traceline routine and its observable state changes.
/// @param machine The machine input consumed by `PF_traceline`.
function PF_traceline(machine)
  return traceLineBuiltin(machine)
end function

/// Mirror Quake's PF_TraceToss routine and its observable state changes.
/// @param machine The machine input consumed by `PF_TraceToss`.
function PF_TraceToss(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_checkpos routine and its observable state changes.
/// @param machine The machine input consumed by `PF_checkpos`.
function PF_checkpos(machine)
  // The MiniQuake function body is intentionally empty and is not installed in
  // the stock builtin table (slot 5 remains PF_Fixme).
  return true
end function

/// Mirror Quake's PF_newcheckclient routine and its observable state changes.
/// @param machine The machine input consumed by `PF_newcheckclient`.
/// @param check The check input consumed by `PF_newcheckclient`.
function PF_newcheckclient(machine, check)
  return newCheckClient(machine, check)
end function

/// Mirror Quake's PF_checkclient routine and its observable state changes.
/// @param machine The machine input consumed by `PF_checkclient`.
function PF_checkclient(machine)
  return checkClientBuiltin(machine)
end function

/// Mirror Quake's PF_stuffcmd routine and its observable state changes.
/// @param machine The machine input consumed by `PF_stuffcmd`.
function PF_stuffcmd(machine)
  return stuffCommandBuiltin(machine)
end function

/// Mirror Quake's PF_localcmd routine and its observable state changes.
/// @param machine The machine input consumed by `PF_localcmd`.
function PF_localcmd(machine)
  return localCommandBuiltin(machine)
end function

/// Mirror Quake's PF_cvar routine and its observable state changes.
/// @param machine The machine input consumed by `PF_cvar`.
function PF_cvar(machine)
  return cvarBuiltin(machine)
end function

/// Mirror Quake's PF_cvar_set routine and its observable state changes.
/// @param machine The machine input consumed by `PF_cvar_set`.
function PF_cvar_set(machine)
  return cvarSetBuiltin(machine)
end function

/// Mirror Quake's PF_findradius routine and its observable state changes.
/// @param machine The machine input consumed by `PF_findradius`.
function PF_findradius(machine)
  return findRadiusBuiltin(machine)
end function

/// Mirror Quake's PF_dprint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_dprint`.
function PF_dprint(machine)
  return debugPrintBuiltin(machine)
end function

/// Mirror Quake's PF_ftos routine and its observable state changes.
/// @param machine The machine input consumed by `PF_ftos`.
function PF_ftos(machine)
  return floatToStringBuiltin(machine)
end function

/// Mirror Quake's PF_fabs routine and its observable state changes.
/// @param machine The machine input consumed by `PF_fabs`.
function PF_fabs(machine)
  return absoluteBuiltin(machine)
end function

/// Mirror Quake's PF_vtos routine and its observable state changes.
/// @param machine The machine input consumed by `PF_vtos`.
function PF_vtos(machine)
  return vectorToStringBuiltin(machine)
end function

/// Mirror Quake's PF_etos routine and its observable state changes.
/// @param machine The machine input consumed by `PF_etos`.
function PF_etos(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_Spawn routine and its observable state changes.
/// @param machine The machine input consumed by `PF_Spawn`.
function PF_Spawn(machine)
  return spawnBuiltin(machine)
end function

/// Mirror Quake's PF_Remove routine and its observable state changes.
/// @param machine The machine input consumed by `PF_Remove`.
function PF_Remove(machine)
  return removeBuiltin(machine)
end function

/// Mirror Quake's PF_Find routine and its observable state changes.
/// @param machine The machine input consumed by `PF_Find`.
function PF_Find(machine)
  return findBuiltin(machine)
end function

/// Mirror Quake's PR_CheckEmptyString routine and its observable state changes.
/// @param value Value consumed by `PR_CheckEmptyString`.
function PR_CheckEmptyString(value)
  if badPrecacheString(value) then return error(2669, "Bad string") end if
  return true
end function

/// Mirror Quake's PF_precache_file routine and its observable state changes.
/// @param machine The machine input consumed by `PF_precache_file`.
function PF_precache_file(machine)
  return precacheFileBuiltin(machine)
end function

/// Mirror Quake's PF_precache_sound routine and its observable state changes.
/// @param machine The machine input consumed by `PF_precache_sound`.
function PF_precache_sound(machine)
  return precacheSoundBuiltin(machine)
end function

/// Mirror Quake's PF_precache_model routine and its observable state changes.
/// @param machine The machine input consumed by `PF_precache_model`.
function PF_precache_model(machine)
  return precacheModelBuiltin(machine)
end function

/// Mirror Quake's PF_coredump routine and its observable state changes.
/// @param machine The machine input consumed by `PF_coredump`.
function PF_coredump(machine)
  return coreDumpBuiltin(machine)
end function

/// Mirror Quake's PF_traceon routine and its observable state changes.
/// @param machine The machine input consumed by `PF_traceon`.
function PF_traceon(machine)
  return traceOnBuiltin(machine)
end function

/// Mirror Quake's PF_traceoff routine and its observable state changes.
/// @param machine The machine input consumed by `PF_traceoff`.
function PF_traceoff(machine)
  return traceOffBuiltin(machine)
end function

/// Mirror Quake's PF_eprint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_eprint`.
function PF_eprint(machine)
  return entityPrintBuiltin(machine)
end function

/// Mirror Quake's PF_walkmove routine and its observable state changes.
/// @param machine The machine input consumed by `PF_walkmove`.
function PF_walkmove(machine)
  return walkMoveBuiltin(machine)
end function

/// Mirror Quake's PF_droptofloor routine and its observable state changes.
/// @param machine The machine input consumed by `PF_droptofloor`.
function PF_droptofloor(machine)
  return dropToFloorBuiltin(machine)
end function

/// Mirror Quake's PF_lightstyle routine and its observable state changes.
/// @param machine The machine input consumed by `PF_lightstyle`.
function PF_lightstyle(machine)
  return lightStyleBuiltin(machine)
end function

/// Mirror Quake's PF_rint routine and its observable state changes.
/// @param machine The machine input consumed by `PF_rint`.
function PF_rint(machine)
  return roundBuiltin(machine)
end function

/// Mirror Quake's PF_floor routine and its observable state changes.
/// @param machine The machine input consumed by `PF_floor`.
function PF_floor(machine)
  return floorBuiltin(machine)
end function

/// Mirror Quake's PF_ceil routine and its observable state changes.
/// @param machine The machine input consumed by `PF_ceil`.
function PF_ceil(machine)
  return ceilBuiltin(machine)
end function

/// Mirror Quake's PF_checkbottom routine and its observable state changes.
/// @param machine The machine input consumed by `PF_checkbottom`.
function PF_checkbottom(machine)
  return checkBottomBuiltin(machine)
end function

/// Mirror Quake's PF_pointcontents routine and its observable state changes.
/// @param machine The machine input consumed by `PF_pointcontents`.
function PF_pointcontents(machine)
  return pointContentsBuiltin(machine)
end function

/// Mirror Quake's PF_nextent routine and its observable state changes.
/// @param machine The machine input consumed by `PF_nextent`.
function PF_nextent(machine)
  return nextEntityBuiltin(machine)
end function

/// Mirror Quake's PF_aim routine and its observable state changes.
/// @param machine The machine input consumed by `PF_aim`.
function PF_aim(machine)
  return aimBuiltin(machine)
end function

/// Mirror Quake's PF_changeyaw routine and its observable state changes.
/// @param machine The machine input consumed by `PF_changeyaw`.
function PF_changeyaw(machine)
  return changeYawBuiltin(machine)
end function

/// Mirror Quake's PF_changepitch routine and its observable state changes.
/// @param machine The machine input consumed by `PF_changepitch`.
function PF_changepitch(machine)
  return fixme(machine)
end function

/// Encode and write dest.
/// @param machine The machine input consumed by `WriteDest`.
function WriteDest(machine)
  return destinationBuffer(machine, native.trunc(parmFloat(machine, 0)))
end function

/// Mirror Quake's PF_WriteByte routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteByte`.
function PF_WriteByte(machine)
  return writeByteBuiltin(machine)
end function

/// Mirror Quake's PF_WriteChar routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteChar`.
function PF_WriteChar(machine)
  return writeCharBuiltin(machine)
end function

/// Mirror Quake's PF_WriteShort routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteShort`.
function PF_WriteShort(machine)
  return writeShortBuiltin(machine)
end function

/// Mirror Quake's PF_WriteLong routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteLong`.
function PF_WriteLong(machine)
  return writeLongBuiltin(machine)
end function

/// Mirror Quake's PF_WriteAngle routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteAngle`.
function PF_WriteAngle(machine)
  return writeAngleBuiltin(machine)
end function

/// Mirror Quake's PF_WriteCoord routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteCoord`.
function PF_WriteCoord(machine)
  return writeCoordBuiltin(machine)
end function

/// Mirror Quake's PF_WriteString routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteString`.
function PF_WriteString(machine)
  return writeStringBuiltin(machine)
end function

/// Mirror Quake's PF_WriteEntity routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WriteEntity`.
function PF_WriteEntity(machine)
  return writeEntityBuiltin(machine)
end function

/// Mirror Quake's PF_makestatic routine and its observable state changes.
/// @param machine The machine input consumed by `PF_makestatic`.
function PF_makestatic(machine)
  return makeStaticBuiltin(machine)
end function

/// Mirror Quake's PF_setspawnparms routine and its observable state changes.
/// @param machine The machine input consumed by `PF_setspawnparms`.
function PF_setspawnparms(machine)
  return setSpawnParmsBuiltin(machine)
end function

/// Mirror Quake's PF_changelevel routine and its observable state changes.
/// @param machine The machine input consumed by `PF_changelevel`.
function PF_changelevel(machine)
  return changeLevelBuiltin(machine)
end function

/// Mirror Quake's PF_WaterMove routine and its observable state changes.
/// @param machine The machine input consumed by `PF_WaterMove`.
function PF_WaterMove(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_sin routine and its observable state changes.
/// @param machine The machine input consumed by `PF_sin`.
function PF_sin(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_cos routine and its observable state changes.
/// @param machine The machine input consumed by `PF_cos`.
function PF_cos(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_sqrt routine and its observable state changes.
/// @param machine The machine input consumed by `PF_sqrt`.
function PF_sqrt(machine)
  return fixme(machine)
end function

/// Mirror Quake's PF_Fixme routine and its observable state changes.
/// @param machine The machine input consumed by `PF_Fixme`.
function PF_Fixme(machine)
  return fixme(machine)
end function
