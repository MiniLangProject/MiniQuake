/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.quakec.edict.
*/
package miniquake.quakec.edict

import miniquake.types as t
import miniquake.constants as c
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.quakec.vm as vm
import miniquake.native as native
import miniquake.common as common
import miniquake.protocol_text as protocolText

/// Implements the `allocate` operation for `miniquake.quakec.edict` (allocate).
/// @param machine The machine input consumed by `allocate`.
/// @param firstIndex Zero-based index of the requested entry.
function allocate(machine, firstIndex)
  index = firstIndex
  if index < 1 then index = 1 end if
  runtime = void
  allocationLimit = len(machine.edicts)
  currentTime = 0.0
  if machine.context is not void and machine.context.edicts is not void then
    runtime = machine.context.edicts
    allocationLimit = runtime.numEdicts
    currentTime = machine.context.serverTime
  end if

  // ED_Alloc only searches the existing [firstIndex, num_edicts) range.
  // If no reusable slot exists, it allocates exactly num_edicts and advances
  // the high-water mark. Scanning the entire backing array without updating
  // numEdicts lets a QuakeC spawn() overwrite a map entity loaded moments
  // earlier.
  while index < allocationLimit
    freeTime = 0.0
    if runtime is not void and index < len(runtime.freeTimes) then freeTime = runtime.freeTimes[index] end if
    if machine.edictFree[index] and (runtime is void or freeTime < 2.0 or currentTime - freeTime > 0.5) then
      machine.edictFree[index] = false
      vm.clearEntity(machine, index)
      return index
    end if
    index = index + 1
  end while

  index = allocationLimit
  if index < firstIndex then index = firstIndex end if
  if index < len(machine.edicts) then
    machine.edictFree[index] = false
    vm.clearEntity(machine, index)
    if runtime is not void then runtime.numEdicts = index + 1 end if
    return index
  end if
  return error(2600, "ED_Alloc: no free edicts")
end function

/// Implements the `free` operation for `miniquake.quakec.edict` (free).
/// @param machine The machine input consumed by `free`.
/// @param entityIndex Zero-based index of the requested entry.
function free(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return false end if
  // ED_Free deliberately leaves most fields intact until ED_Alloc reuses the
  // slot.  Quake clears only the fields that could keep the entity visible,
  // solid, moving, or scheduled for a think.
  machine.edictFree[entityIndex] = true
  zeroFields = ["model", "takedamage", "modelindex", "colormap", "skin", "frame", "solid"]
  for each name in zeroFields
    definition = fieldDefinition(machine, name)
    if definition is not void then vm.setEntityField(machine, entityIndex, definition.offset, 0) end if
  end for
  origin = fieldDefinition(machine, "origin")
  if origin is not void then vm.setEntityVector(machine, entityIndex, origin.offset, t.Vec3(0.0, 0.0, 0.0)) end if
  angles = fieldDefinition(machine, "angles")
  if angles is not void then vm.setEntityVector(machine, entityIndex, angles.offset, t.Vec3(0.0, 0.0, 0.0)) end if
  nextThink = fieldDefinition(machine, "nextthink")
  if nextThink is not void then vm.setEntityFloat(machine, entityIndex, nextThink.offset, -1.0) end if
  if machine.context is not void and machine.context.edicts is not void then
    if entityIndex < len(machine.context.edicts.freeTimes) then
      machine.context.edicts.freeTimes[entityIndex] = machine.context.serverTime
    end if
  end if
  return true
end function

/// Implements the `fieldDefinition` operation for `miniquake.quakec.edict` (field definition).
/// @param machine The machine input consumed by `fieldDefinition`.
/// @param name Stable name that identifies the requested object or option.
function fieldDefinition(machine, name)
  for each definition in machine.program.fieldDefs
    if definition.name == name then return definition end if
  end for
  return void
end function

/// Implements the `globalDefinition` operation for `miniquake.quakec.edict` (global definition).
/// @param machine The machine input consumed by `globalDefinition`.
/// @param name Stable name that identifies the requested object or option.
function globalDefinition(machine, name)
  for each definition in machine.program.globalDefs
    if definition.name == name then return definition end if
  end for
  return void
end function

/// Update module state for global by name.
/// @param machine The machine input consumed by `setGlobalByName`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setGlobalByName`.
function setGlobalByName(machine, name, value)
  definition = globalDefinition(machine, name)
  if definition is void then return false end if
  valueType = definition.type & 0x7fff
  if valueType == c.EV_STRING then
    vm.setGlobalString(machine, definition.offset, value)
  else if valueType == c.EV_FLOAT then
    vm.setGlobalFloat(machine, definition.offset, common.cAtof(value))
  else if valueType == c.EV_VECTOR then
    vm.setVector(machine, definition.offset, bsp.parseVector(value))
  else if valueType == c.EV_ENTITY then
    number = toNumber(value)
    if number is void then number = 0 end if
    vm.setWord(machine, definition.offset, native.trunc(number))
  else if valueType == c.EV_FIELD then
    referenced = fieldDefinition(machine, value)
    if referenced is void then return error(2603, "ED_ParseEpair: can't find field " + value) end if
    vm.setWord(machine, definition.offset, vm.word(machine, referenced.offset))
  else if valueType == c.EV_FUNCTION then
    functionValue = vm.functionIndex(machine, value)
    if functionValue == 0 and value != "" then return error(2604, "ED_ParseEpair: can't find function " + value) end if
    vm.setWord(machine, definition.offset, functionValue)
  else
    number = toNumber(value)
    if number is void then number = 0 end if
    vm.setWord(machine, definition.offset, number)
  end if
  return true
end function

/// Implements the `trimTrailingSpaces` operation for `miniquake.quakec.edict` (trim trailing spaces).
/// @param text Text to parse or process.
function trimTrailingSpaces(text)
  data = bytes(text)
  count = len(data)
  while count > 0 and data[count - 1] == 32
    count = count - 1
  end while
  if count == len(data) then return text end if
  return decode(slice(data, 0, count))
end function

/// Update module state for key value.
/// @param machine The machine input consumed by `setKeyValue`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param key Key used to identify the requested entry.
/// @param value Value consumed by `setKeyValue`.
function setKeyValue(machine, entityIndex, key, value)
  if key == "" then return false end if
  keyData = bytes(key)
  if len(keyData) > 0 and keyData[0] == 95 then return true end if
  actualKey = trimTrailingSpaces(key)
  actualValue = value
  if actualKey == "angle" then
    actualKey = "angles"
    actualValue = "0 " + value + " 0"
  else if actualKey == "light" then
    actualKey = "light_lev"
  end if

  definition = fieldDefinition(machine, actualKey)
  if definition is void then return false end if
  valueType = definition.type & 0x7fff
  if valueType == c.EV_STRING then
    vm.setEntityString(machine, entityIndex, definition.offset, actualValue)
  else if valueType == c.EV_FLOAT then
    vm.setEntityFloat(machine, entityIndex, definition.offset, common.cAtof(actualValue))
  else if valueType == c.EV_VECTOR then
    vm.setEntityVector(machine, entityIndex, definition.offset, bsp.parseVector(actualValue))
  else if valueType == c.EV_ENTITY then
    number = toNumber(actualValue)
    if number is void then number = 0 end if
    vm.setEntityField(machine, entityIndex, definition.offset, native.trunc(number))
  else if valueType == c.EV_FIELD then
    referenced = fieldDefinition(machine, actualValue)
    if referenced is void then return error(2603, "ED_ParseEpair: can't find field " + actualValue) end if
    // ED_ParseEpair stores G_INT(def->ofs), not def->ofs itself.  The global
    // word is the authoritative QuakeC field value.
    vm.setEntityField(machine, entityIndex, definition.offset, vm.word(machine, referenced.offset))
  else if valueType == c.EV_FUNCTION then
    functionValue = vm.functionIndex(machine, actualValue)
    if functionValue == 0 and actualValue != "" then return error(2604, "ED_ParseEpair: can't find function " + actualValue) end if
    vm.setEntityField(machine, entityIndex, definition.offset, functionValue)
  else
    return false
  end if
  return true
end function

/// Implements the `diagnostic` operation for `miniquake.quakec.edict` (diagnostic).
/// @param machine The machine input consumed by `diagnostic`.
/// @param text Text to parse or process.
function diagnostic(machine, text)
  if machine.context is not void then machine.context.consoleLines = machine.context.consoleLines + [text] end if
  return false
end function

/// Read and validate entity.
/// @param machine The machine input consumed by `parseEntity`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param entity Entity affected by the operation.
function parseEntity(machine, entityIndex, entity)
  // ED_ParseEdict clears every non-world edict before consuming its pairs.
  if entityIndex != 0 then vm.clearEntity(machine, entityIndex) end if
  initialized = false
  for each pair in entity.pairs
    initialized = true
    parsed = try(setKeyValue(machine, entityIndex, pair.key, pair.value))
    if parsed is error then return parsed end if
    if parsed == false then diagnostic(machine, "'" + pair.key + "' is not a field") end if
  end for
  if not initialized then machine.edictFree[entityIndex] = true end if
  return entityIndex
end function

/// Update module state for world vector.
/// @param machine The machine input consumed by `setWorldVector`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setWorldVector`.
function setWorldVector(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityVector(machine, 0, definition.offset, value) end if
end function

/// Update module state for world float.
/// @param machine The machine input consumed by `setWorldFloat`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setWorldFloat`.
function setWorldFloat(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityFloat(machine, 0, definition.offset, value) end if
end function

/// Update module state for world string.
/// @param machine The machine input consumed by `setWorldString`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setWorldString`.
function setWorldString(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityString(machine, 0, definition.offset, value) end if
end function

/// SV_SpawnServer initializes the world edict before ED_LoadFromFile.  The
/// entity text then contributes keys such as message/sounds/worldtype while the
/// engine-owned model, bounds and collision fields stay authoritative.
/// @param machine The machine input consumed by `initializeWorldEntity`.
/// @param map The map input consumed by `initializeWorldEntity`.
function initializeWorldEntity(machine, map)
  modelName = map.filename
  if modelName == "" then modelName = "maps/start.bsp" end if
  setWorldString(machine, "model", modelName)
  setWorldFloat(machine, "modelindex", 1.0)
  setWorldFloat(machine, "solid", c.SOLID_BSP)
  setWorldFloat(machine, "movetype", c.MOVETYPE_PUSH)
  if len(map.models) > 0 then
    worldModel = map.models[0]
    setWorldVector(machine, "mins", worldModel.mins)
    setWorldVector(machine, "maxs", worldModel.maxs)
    setWorldVector(machine, "absmin", worldModel.mins)
    setWorldVector(machine, "absmax", worldModel.maxs)
    setWorldVector(machine, "size", t.Vec3(
      worldModel.maxs.x - worldModel.mins.x,
      worldModel.maxs.y - worldModel.mins.y,
      worldModel.maxs.z - worldModel.mins.z,
    ))
  end if
  return true
end function

/// Report whether should inhibit.
/// @param machine The machine input consumed by `shouldInhibit`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param skill The skill input consumed by `shouldInhibit`.
/// @param deathmatch The deathmatch input consumed by `shouldInhibit`.
function shouldInhibit(machine, entityIndex, skill, deathmatch)
  spawnField = vm.fieldOffset(machine, "spawnflags")
  if spawnField < 0 then return false end if
  flags = vm.entityFloat(machine, entityIndex, spawnField)
  intFlags = native.trunc(flags)
  if deathmatch and (intFlags & c.SPAWNFLAG_NOT_DEATHMATCH) != 0 then return true end if
  if skill <= 0 and (intFlags & c.SPAWNFLAG_NOT_EASY) != 0 then return true end if
  if skill == 1 and (intFlags & c.SPAWNFLAG_NOT_MEDIUM) != 0 then return true end if
  if skill >= 2 and (intFlags & c.SPAWNFLAG_NOT_HARD) != 0 then return true end if
  return false
end function

/// Return class name derived from the active module state.
/// @param machine The machine input consumed by `className`.
/// @param entityIndex Zero-based index of the requested entry.
function className(machine, entityIndex)
  field = vm.fieldOffset(machine, "classname")
  if field < 0 then return "" end if
  return vm.entityString(machine, entityIndex, field)
end function

/// Read and validate map entities from.
/// @param machine The machine input consumed by `loadMapEntitiesFrom`.
/// @param map The map input consumed by `loadMapEntitiesFrom`.
/// @param skill The skill input consumed by `loadMapEntitiesFrom`.
/// @param deathmatch The deathmatch input consumed by `loadMapEntitiesFrom`.
/// @param firstDynamicIndex Zero-based index of the requested entry.
function loadMapEntitiesFrom(machine, map, skill, deathmatch, firstDynamicIndex)
  // `map` is a deeply nested BSP object graph held by the live server.  A
  // forced collection here can reclaim boxed members that the current
  // backend does not discover through every nested struct/array edge; the
  // renderer then sees sporadic non-struct vertices during first upload.
  // Normal heap pressure still invokes the collector at safe allocation
  // boundaries, so do not force it in the middle of level construction.
  if len(map.entities) == 0 then return error(2601, "ED_LoadFromFile: no worldspawn entity") end if
  if firstDynamicIndex < 1 then firstDynamicIndex = 1 end if
  machine.edictFree[0] = false
  vm.clearEntity(machine, 0)
  // SV_SpawnServer initializes the world edict before ED_LoadFromFile.
  // ED_ParseEdict deliberately does not clear world, so explicit worldspawn
  // keys retain the original opportunity to override these defaults.
  initializeWorldEntity(machine, map)
  spawned = 0
  inhibited = 0
  sourceIndex = 0
  while sourceIndex < len(map.entities)
    entityIndex = 0
    if sourceIndex > 0 then
      allocated = try(allocate(machine, firstDynamicIndex))
      if allocated is error then return allocated end if
      entityIndex = allocated
    end if
    parsed = try(parseEntity(machine, entityIndex, map.entities[sourceIndex]))
    if parsed is error then return parsed end if
    if sourceIndex > 0 and shouldInhibit(machine, entityIndex, skill, deathmatch) then
      free(machine, entityIndex)
      inhibited = inhibited + 1
    else
      name = className(machine, entityIndex)
      functionValue = vm.functionIndex(machine, name)
      if functionValue == 0 then
        if sourceIndex == 0 then return error(2602, "worldspawn function was not found in progs.dat") end if
        free(machine, entityIndex)
      else
        vm.setWord(machine, c.QC_GLOBAL_SELF, entityIndex)
        executed = try(vm.execute(machine, functionValue))
        if executed is error then return executed end if
        spawned = spawned + 1
      end if
    end if
    sourceIndex = sourceIndex + 1
  end while
  return [spawned, inhibited]
end function

/// Read and validate map entities.
/// @param machine The machine input consumed by `loadMapEntities`.
/// @param map The map input consumed by `loadMapEntities`.
/// @param skill The skill input consumed by `loadMapEntities`.
/// @param deathmatch The deathmatch input consumed by `loadMapEntities`.
function loadMapEntities(machine, map, skill, deathmatch)
  return loadMapEntitiesFrom(machine, map, skill, deathmatch, 1)
end function

/// Initialize state for initialize globals.
/// @param machine The machine input consumed by `initializeGlobals`.
/// @param mapName Name of the map to load or inspect.
/// @param skill The skill input consumed by `initializeGlobals`.
/// @param deathmatch The deathmatch input consumed by `initializeGlobals`.
/// @param coop The coop input consumed by `initializeGlobals`.
/// @param serverFlags The server flags input consumed by `initializeGlobals`.
function initializeGlobals(machine, mapName, skill, deathmatch, coop, serverFlags)
  setGlobalByName(machine, "mapname", mapName)
  setGlobalByName(machine, "skill", "" + skill)
  if deathmatch then setGlobalByName(machine, "deathmatch", "1") else setGlobalByName(machine, "deathmatch", "0") end if
  if coop then setGlobalByName(machine, "coop", "1") else setGlobalByName(machine, "coop", "0") end if
  setGlobalByName(machine, "serverflags", "" + serverFlags)
  vm.setWord(machine, c.QC_GLOBAL_WORLD, 0)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, 1.0)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_FRAMETIME, 0.1)
  return true
end function

/// Implements the `baseline` operation for `miniquake.quakec.edict` (baseline).
/// @param machine The machine input consumed by `baseline`.
/// @param entityIndex Zero-based index of the requested entry.
function baseline(machine, entityIndex)
  modelField = vm.fieldOffset(machine, "modelindex")
  frameField = vm.fieldOffset(machine, "frame")
  colorField = vm.fieldOffset(machine, "colormap")
  skinField = vm.fieldOffset(machine, "skin")
  originField = vm.fieldOffset(machine, "origin")
  anglesField = vm.fieldOffset(machine, "angles")
  modelIndex = 0
  frame = 0
  colormap = 0
  skin = 0
  origin = t.Vec3(0.0, 0.0, 0.0)
  angles = t.Vec3(0.0, 0.0, 0.0)
  if modelField >= 0 then modelIndex = vm.entityFloat(machine, entityIndex, modelField) end if
  if frameField >= 0 then frame = vm.entityFloat(machine, entityIndex, frameField) end if
  if colorField >= 0 then colormap = vm.entityFloat(machine, entityIndex, colorField) end if
  if skinField >= 0 then skin = vm.entityFloat(machine, entityIndex, skinField) end if
  if originField >= 0 then origin = vm.entityVector(machine, entityIndex, originField) end if
  if anglesField >= 0 then angles = vm.entityVector(machine, entityIndex, anglesField) end if
  return [modelIndex, frame, colormap, skin, origin, angles]
end function

/// Implements the `typeSize` operation for `miniquake.quakec.edict` (type size).
/// @param valueType The value type input consumed by `typeSize`.
function typeSize(valueType)
  valueType = valueType & 0x7fff
  if valueType == c.EV_VOID then return 1 end if
  if valueType == c.EV_VECTOR then return 3 end if
  return 1
end function

/// Return definition at offset derived from the active module state.
/// @param definitions The definitions input consumed by `definitionAtOffset`.
/// @param offset Zero-based offset of the requested data.
function definitionAtOffset(definitions, offset)
  for each definition in definitions
    if definition.offset == offset then return definition end if
  end for
  return void
end function

/// Implements the `vectorComponentDefinition` operation for `miniquake.quakec.edict` (vector component definition).
/// @param name Stable name that identifies the requested object or option.
function vectorComponentDefinition(name)
  data = bytes(name)
  if len(data) < 2 then return false end if
  return data[len(data) - 2] == 95
end function

/// Implements the `wordsAreZero` operation for `miniquake.quakec.edict` (words are zero).
/// @param words The words input consumed by `wordsAreZero`.
/// @param offset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
function wordsAreZero(words, offset, count)
  index = 0
  while index < count
    if offset + index >= len(words) or words[offset + index] != 0 then return false end if
    index = index + 1
  end while
  return true
end function

/// Implements the `edictFloor` operation for `miniquake.quakec.edict` (edict floor).
/// @param value Value consumed by `edictFloor`.
function edictFloor(value)
  truncated = native.trunc(value)
  if value < truncated then return truncated - 1 end if
  return truncated
end function

/// Implements the `edictCeil` operation for `miniquake.quakec.edict` (edict ceil).
/// @param value Value consumed by `edictCeil`.
function edictCeil(value)
  truncated = native.trunc(value)
  if value > truncated then return truncated + 1 end if
  return truncated
end function

/// Implements the `fixedOneDecimal` operation for `miniquake.quakec.edict` (fixed one decimal).
/// @param value Value consumed by `fixedOneDecimal`.
function fixedOneDecimal(value)
  scaled = 0
  if value >= 0.0 then
    scaled = edictFloor(value * 10.0 + 0.5)
  else
    scaled = edictCeil(value * 10.0 - 0.5)
  end if
  negative = scaled < 0
  if negative then scaled = -scaled end if
  whole = native.trunc(scaled / 10)
  text = "" + whole + "." + (scaled % 10)
  if negative then text = "-" + text end if
  while len(bytes(text)) < 5
    text = " " + text
  end while
  return text
end function

/// Implements the `fixedSixDecimalsWord` operation for `miniquake.quakec.edict` (fixed six decimals word).
/// @param rawWord The raw word input consumed by `fixedSixDecimalsWord`.
function fixedSixDecimalsWord(rawWord)
  return native.f32ToFixed6(rawWord & 0xffffffff)
end function

/// Implements the `fixedSixDecimals` operation for `miniquake.quakec.edict` (fixed six decimals).
/// @param value Value consumed by `fixedSixDecimals`.
function fixedSixDecimals(value)
  return fixedSixDecimalsWord(native.floatBits(value))
end function

/// Implements the `uglyVectorString` operation for `miniquake.quakec.edict` (ugly vector string).
/// @param words The words input consumed by `uglyVectorString`.
/// @param offset Zero-based offset of the requested data.
function uglyVectorString(words, offset)
  result = fixedSixDecimalsWord(words[offset])
  result = result + " "
  result = result + fixedSixDecimalsWord(words[offset + 1])
  result = result + " "
  result = result + fixedSixDecimalsWord(words[offset + 2])
  return result
end function

/// Implements the `displayVectorString` operation for `miniquake.quakec.edict` (display vector string).
/// @param words The words input consumed by `displayVectorString`.
/// @param offset Zero-based offset of the requested data.
function displayVectorString(words, offset)
  result = "'"
  result = result + fixedOneDecimal(native.bitsFloat(words[offset]))
  result = result + " "
  result = result + fixedOneDecimal(native.bitsFloat(words[offset + 1]))
  result = result + " "
  result = result + fixedOneDecimal(native.bitsFloat(words[offset + 2]))
  result = result + "'"
  return result
end function

/// Implements the `voidValueString` operation for `miniquake.quakec.edict` (void value string).
function voidValueString()
  // Construct the textual ev_void representation through the Quake byte
  // codec. This guarantees a real four-byte string at MiniLang's strict
  // void/string boundary.
  return protocolText.decodeBytes(bytes([118, 111, 105, 100]))
end function

/// Implements the `valueString` operation for `miniquake.quakec.edict` (value string).
/// @param machine The machine input consumed by `valueString`.
/// @param valueType The value type input consumed by `valueString`.
/// @param words The words input consumed by `valueString`.
/// @param offset Zero-based offset of the requested data.
/// @param ugly The ugly input consumed by `valueString`.
function valueString(machine, valueType, words, offset, ugly)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  valueType = valueType & 0x7fff
  if valueType == c.EV_STRING then
    text = vm.stringValue(machine, words[offset])
    if typeof(text) != "string" then return error(2612, "QuakeC string formatter returned no text") end if
    return text
  end if
  if valueType == c.EV_ENTITY then
    if ugly then return "" + words[offset] end if
    return "entity " + words[offset]
  end if
  if valueType == c.EV_FUNCTION then
    index = words[offset]
    if index < 0 or index >= len(machine.program.functions) then return "" end if
    name = machine.program.functions[index].name
    if typeof(name) != "string" then return error(2613, "QuakeC function formatter received no name") end if
    if ugly then return name end if
    return name + "()"
  end if
  if valueType == c.EV_FIELD then
    definition = definitionAtOffset(machine.program.fieldDefs, words[offset])
    if definition is void then return "" end if
    if typeof(definition.name) != "string" then return error(2614, "QuakeC field formatter received no name") end if
    if ugly then return definition.name end if
    return "." + definition.name
  end if
  if valueType == c.EV_VOID then return voidValueString() end if
  if valueType == c.EV_FLOAT then
    if ugly then return fixedSixDecimalsWord(words[offset]) end if
    return fixedOneDecimal(native.bitsFloat(words[offset]))
  end if
  if valueType == c.EV_VECTOR then
    if ugly then return uglyVectorString(words, offset) end if
    return displayVectorString(words, offset)
  end if
  if valueType == c.EV_POINTER and not ugly then return "pointer" end if
  return "bad type " + valueType
end function

/// Add state for append quoted pair.
/// @param prefix The prefix input consumed by `appendQuotedPair`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `appendQuotedPair`.
function appendQuotedPair(prefix, name, value)
  if typeof(prefix) != "string" then return error(2610, "QuakeC serialization received a non-string prefix") end if
  if typeof(name) != "string" then return error(2611, "QuakeC serialization received a non-string field name") end if
  if typeof(value) != "string" then return error(2615, "QuakeC serialization received a non-string field value") end if

  prefixData = try(protocolText.encodeBytes(prefix))
  if prefixData is error then return prefixData end if
  nameData = try(protocolText.encodeBytes(name))
  if nameData is error then return nameData end if
  valueData = try(protocolText.encodeBytes(value))
  if valueData is error then return valueData end if

  // Build the complete quoted pair as Quake bytes.  The earlier implementation
  // repeatedly concatenated MiniLang strings and could surface a transient void
  // value in the native runtime after several ED_Write fields.  The C original
  // writes directly to FILE, so a caller-owned byte buffer is the closer model.
  output = bytes(len(prefixData) + len(nameData) + len(valueData) + 6, 0)
  cursor = 0
  if len(prefixData) > 0 then
    copyBytes(output, cursor, prefixData, 0, len(prefixData))
    cursor = cursor + len(prefixData)
  end if
  output[cursor] = 34
  cursor = cursor + 1
  if len(nameData) > 0 then
    copyBytes(output, cursor, nameData, 0, len(nameData))
    cursor = cursor + len(nameData)
  end if
  output[cursor] = 34
  output[cursor + 1] = 32
  output[cursor + 2] = 34
  cursor = cursor + 3
  if len(valueData) > 0 then
    copyBytes(output, cursor, valueData, 0, len(valueData))
    cursor = cursor + len(valueData)
  end if
  output[cursor] = 34
  output[cursor + 1] = 10

  decoded = try(protocolText.decodeBytes(output))
  if decoded is error then return decoded end if
  if typeof(decoded) != "string" then return error(2617, "QuakeC quoted-pair decoder returned no text") end if
  return decoded
end function

/// Implements the `quotedPairLine` operation for `miniquake.quakec.edict` (quoted pair line).
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `quotedPairLine`.
function quotedPairLine(name, value)
  return appendQuotedPair("", name, value)
end function

/// Format and emit edict.
/// @param machine The machine input consumed by `printEdict`.
/// @param entityIndex Zero-based index of the requested entry.
function printEdict(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2605, "ED_Print: bad edict " + entityIndex) end if
  if machine.edictFree[entityIndex] then return "FREE\n" end if
  text = "\nEDICT " + entityIndex + ":\n"
  index = 1
  while index < len(machine.program.fieldDefs)
    definition = machine.program.fieldDefs[index]
    size = typeSize(definition.type)
    include = not vectorComponentDefinition(definition.name) and size > 0
    include = include and definition.offset + size <= len(machine.edicts[entityIndex])
    include = include and not wordsAreZero(machine.edicts[entityIndex], definition.offset, size)
    if include then
      text = text + definition.name
      padding = len(bytes(definition.name))
      while padding < 15
        text = text + " "
        padding = padding + 1
      end while
      text = text + valueString(machine, definition.type, machine.edicts[entityIndex], definition.offset, false) + "\n"
    end if
    index = index + 1
  end while
  return text
end function

/// Implements the `definitionShouldSerialize` operation for `miniquake.quakec.edict` (definition should serialize).
/// @param words The words input consumed by `definitionShouldSerialize`.
/// @param definition The definition input consumed by `definitionShouldSerialize`.
/// @param globalsOnly The globals only input consumed by `definitionShouldSerialize`.
function definitionShouldSerialize(words, definition, globalsOnly)
  valueType = definition.type & 0x7fff
  size = typeSize(valueType)
  include = size > 0

  if globalsOnly then
    include = include and (definition.type & c.DEF_SAVEGLOBAL) != 0
    include = include and (valueType == c.EV_STRING or valueType == c.EV_FLOAT or valueType == c.EV_ENTITY)
    if not include then return false end if
    if definition.offset < 0 or definition.offset + size > len(words) then
      return error(2616, "ED_WriteGlobals: definition outside global storage")
    end if
  else
    include = include and not vectorComponentDefinition(definition.name)
    include = include and definition.offset >= 0
    include = include and definition.offset + size <= len(words)
    if not include then return false end if
  end if

  // ED_Write skips zero-valued entity fields, while ED_WriteGlobals writes
  // every DEF_SAVEGLOBAL string/float/entity even when the stored value is 0.
  if globalsOnly then return true end if
  return not wordsAreZero(words, definition.offset, size)
end function

/// Return definition serialized length derived from the active module state.
/// @param machine The machine input consumed by `definitionSerializedLength`.
/// @param words The words input consumed by `definitionSerializedLength`.
/// @param definition The definition input consumed by `definitionSerializedLength`.
function definitionSerializedLength(machine, words, definition)
  serialized = try(valueString(machine, definition.type, words, definition.offset, true))
  if serialized is error then return serialized end if
  if typeof(serialized) != "string" then return error(2618, "QuakeC definition formatter returned no text") end if
  if typeof(definition.name) != "string" then return error(2611, "QuakeC serialization received a non-string field name") end if

  nameData = try(protocolText.encodeBytes(definition.name))
  if nameData is error then return nameData end if
  valueData = try(protocolText.encodeBytes(serialized))
  if valueData is error then return valueData end if
  return len(nameData) + len(valueData) + 6
end function

/// Encode and write definition bytes.
/// @param machine The machine input consumed by `writeDefinitionBytes`.
/// @param words The words input consumed by `writeDefinitionBytes`.
/// @param definition The definition input consumed by `writeDefinitionBytes`.
/// @param output Destination buffer that receives the serialized definition.
/// @param cursor The cursor input consumed by `writeDefinitionBytes`.
function writeDefinitionBytes(machine, words, definition, output, cursor)
  serialized = try(valueString(machine, definition.type, words, definition.offset, true))
  if serialized is error then return serialized end if
  if typeof(serialized) != "string" then return error(2618, "QuakeC definition formatter returned no text") end if
  if typeof(definition.name) != "string" then return error(2611, "QuakeC serialization received a non-string field name") end if

  nameData = try(protocolText.encodeBytes(definition.name))
  if nameData is error then return nameData end if
  valueData = try(protocolText.encodeBytes(serialized))
  if valueData is error then return valueData end if

  output[cursor] = 34
  cursor = cursor + 1
  if len(nameData) > 0 then
    copyBytes(output, cursor, nameData, 0, len(nameData))
    cursor = cursor + len(nameData)
  end if
  output[cursor] = 34
  output[cursor + 1] = 32
  output[cursor + 2] = 34
  cursor = cursor + 3
  if len(valueData) > 0 then
    copyBytes(output, cursor, valueData, 0, len(valueData))
    cursor = cursor + len(valueData)
  end if
  output[cursor] = 34
  output[cursor + 1] = 10
  return cursor + 2
end function

/// Encode and write definitions.
/// @param machine The machine input consumed by `serializeDefinitions`.
/// @param words The words input consumed by `serializeDefinitions`.
/// @param definitions The definitions input consumed by `serializeDefinitions`.
/// @param firstIndex Zero-based index of the requested entry.
/// @param globalsOnly The globals only input consumed by `serializeDefinitions`.
function serializeDefinitions(machine, words, definitions, firstIndex, globalsOnly)
  total = 4 // "{\n" plus "}\n"
  index = firstIndex
  while index < len(definitions)
    include = try(definitionShouldSerialize(words, definitions[index], globalsOnly))
    if include is error then return include end if
    if include then
      length = try(definitionSerializedLength(machine, words, definitions[index]))
      if length is error then return length end if
      total = total + length
    end if
    index = index + 1
  end while

  output = bytes(total, 0)
  output[0] = 123
  output[1] = 10
  cursor = 2
  index = firstIndex
  while index < len(definitions)
    include = try(definitionShouldSerialize(words, definitions[index], globalsOnly))
    if include is error then return include end if
    if include then
      nextCursor = try(writeDefinitionBytes(machine, words, definitions[index], output, cursor))
      if nextCursor is error then return nextCursor end if
      cursor = nextCursor
    end if
    index = index + 1
  end while
  output[cursor] = 125
  output[cursor + 1] = 10

  decoded = try(protocolText.decodeBytes(output))
  if decoded is error then return decoded end if
  if typeof(decoded) != "string" then return error(2619, "QuakeC block decoder returned no text") end if
  return decoded
end function

/// Encode and write edict.
/// @param machine The machine input consumed by `writeEdict`.
/// @param entityIndex Zero-based index of the requested entry.
function writeEdict(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2606, "ED_Write: bad edict " + entityIndex) end if
  if machine.edictFree[entityIndex] then return "{\n}\n" end if
  return serializeDefinitions(machine, machine.edicts[entityIndex], machine.program.fieldDefs, 1, false)
end function

/// Encode and write globals.
/// @param machine The machine input consumed by `writeGlobals`.
function writeGlobals(machine)
  return serializeDefinitions(machine, machine.globals, machine.program.globalDefs, 0, true)
end function

/// Return count edicts for the active module state.
/// @param machine The machine input consumed by `countEdicts`.
function countEdicts(machine)
  limit = len(machine.edicts)
  if machine.context is not void and machine.context.edicts is not void then limit = machine.context.edicts.numEdicts end if
  active = 0
  models = 0
  solid = 0
  step = 0
  modelField = vm.fieldOffset(machine, "model")
  solidField = vm.fieldOffset(machine, "solid")
  moveTypeField = vm.fieldOffset(machine, "movetype")
  index = 0
  while index < limit
    if not machine.edictFree[index] then
      active = active + 1
      if modelField >= 0 and vm.entityField(machine, index, modelField) != 0 then models = models + 1 end if
      if solidField >= 0 and vm.entityFloat(machine, index, solidField) != 0.0 then solid = solid + 1 end if
      if moveTypeField >= 0 and vm.entityFloat(machine, index, moveTypeField) == c.MOVETYPE_STEP then step = step + 1 end if
    end if
    index = index + 1
  end while
  return [limit, active, models, solid, step]
end function

/// Create and initialize string.
/// @param text Text to parse or process.
function newString(text)
  source = protocolText.encodeBytes(text)
  output = bytes(len(source))
  sourceIndex = 0
  outputIndex = 0
  while sourceIndex < len(source)
    if source[sourceIndex] == 92 and sourceIndex + 1 < len(source) then
      sourceIndex = sourceIndex + 1
      if source[sourceIndex] == 110 then output[outputIndex] = 10 else output[outputIndex] = 92 end if
    else
      output[outputIndex] = source[sourceIndex]
    end if
    sourceIndex = sourceIndex + 1
    outputIndex = outputIndex + 1
  end while
  return protocolText.decodeBytes(slice(output, 0, outputIndex))
end function

/// Explicit MiniQuake entry-point names provide a one-to-one code-location map.
/// @param machine The machine input consumed by `ED_ClearEdict`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_ClearEdict(machine, entityIndex)
  vm.clearEntity(machine, entityIndex)
  machine.edictFree[entityIndex] = false
  return entityIndex
end function

/// Mirror Quake's ED_Alloc routine and its observable state changes.
/// @param machine The machine input consumed by `ED_Alloc`.
/// @param firstIndex Zero-based index of the requested entry.
function ED_Alloc(machine, firstIndex)
  return allocate(machine, firstIndex)
end function

/// Mirror Quake's ED_Free routine and its observable state changes.
/// @param machine The machine input consumed by `ED_Free`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_Free(machine, entityIndex)
  return free(machine, entityIndex)
end function

/// Mirror Quake's ED_GlobalAtOfs routine and its observable state changes.
/// @param machine The machine input consumed by `ED_GlobalAtOfs`.
/// @param offset Zero-based offset of the requested data.
function ED_GlobalAtOfs(machine, offset)
  return definitionAtOffset(machine.program.globalDefs, offset)
end function

/// Mirror Quake's ED_FieldAtOfs routine and its observable state changes.
/// @param machine The machine input consumed by `ED_FieldAtOfs`.
/// @param offset Zero-based offset of the requested data.
function ED_FieldAtOfs(machine, offset)
  return definitionAtOffset(machine.program.fieldDefs, offset)
end function

/// Mirror Quake's ED_FindField routine and its observable state changes.
/// @param machine The machine input consumed by `ED_FindField`.
/// @param name Stable name that identifies the requested object or option.
function ED_FindField(machine, name)
  return fieldDefinition(machine, name)
end function

/// Mirror Quake's ED_FindGlobal routine and its observable state changes.
/// @param machine The machine input consumed by `ED_FindGlobal`.
/// @param name Stable name that identifies the requested object or option.
function ED_FindGlobal(machine, name)
  return globalDefinition(machine, name)
end function

/// Mirror Quake's ED_FindFunction routine and its observable state changes.
/// @param machine The machine input consumed by `ED_FindFunction`.
/// @param name Stable name that identifies the requested object or option.
function ED_FindFunction(machine, name)
  return vm.functionIndex(machine, name)
end function

/// Return edict field value.
/// @param machine The machine input consumed by `GetEdictFieldValue`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function GetEdictFieldValue(machine, entityIndex, name)
  definition = fieldDefinition(machine, name)
  if definition is void then return void end if
  return [definition.offset, vm.entityField(machine, entityIndex, definition.offset)]
end function

/// Mirror Quake's PR_ValueString routine and its observable state changes.
/// @param machine The machine input consumed by `PR_ValueString`.
/// @param valueType The value type input consumed by `PR_ValueString`.
/// @param words The words input consumed by `PR_ValueString`.
/// @param offset Zero-based offset of the requested data.
function PR_ValueString(machine, valueType, words, offset)
  return valueString(machine, valueType, words, offset, false)
end function

/// Mirror Quake's PR_UglyValueString routine and its observable state changes.
/// @param machine The machine input consumed by `PR_UglyValueString`.
/// @param valueType The value type input consumed by `PR_UglyValueString`.
/// @param words The words input consumed by `PR_UglyValueString`.
/// @param offset Zero-based offset of the requested data.
function PR_UglyValueString(machine, valueType, words, offset)
  return valueString(machine, valueType, words, offset, true)
end function

/// Mirror Quake's PR_GlobalString routine and its observable state changes.
/// @param machine The machine input consumed by `PR_GlobalString`.
/// @param offset Zero-based offset of the requested data.
function PR_GlobalString(machine, offset)
  definition = ED_GlobalAtOfs(machine, offset)
  text = ""
  if definition is void then
    text = offset + "(???)"
  else
    text = offset + "(" + definition.name + ")" + PR_ValueString(machine, definition.type, machine.globals, offset)
  end if
  while len(bytes(text)) < 20
    text = text + " "
  end while
  return text + " "
end function

/// Mirror Quake's PR_GlobalStringNoContents routine and its observable state changes.
/// @param machine The machine input consumed by `PR_GlobalStringNoContents`.
/// @param offset Zero-based offset of the requested data.
function PR_GlobalStringNoContents(machine, offset)
  definition = ED_GlobalAtOfs(machine, offset)
  text = ""
  if definition is void then text = offset + "(???)" else text = offset + "(" + definition.name + ")" end if
  while len(bytes(text)) < 20
    text = text + " "
  end while
  return text + " "
end function

/// Mirror Quake's ED_Print routine and its observable state changes.
/// @param machine The machine input consumed by `ED_Print`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_Print(machine, entityIndex)
  return printEdict(machine, entityIndex)
end function

/// Mirror Quake's ED_Write routine and its observable state changes.
/// @param machine The machine input consumed by `ED_Write`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_Write(machine, entityIndex)
  return writeEdict(machine, entityIndex)
end function

/// Mirror Quake's ED_PrintNum routine and its observable state changes.
/// @param machine The machine input consumed by `ED_PrintNum`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_PrintNum(machine, entityIndex)
  return printEdict(machine, entityIndex)
end function

/// Mirror Quake's ED_PrintEdicts routine and its observable state changes.
/// @param machine The machine input consumed by `ED_PrintEdicts`.
function ED_PrintEdicts(machine)
  counts = countEdicts(machine)
  text = counts[0] + " entities\n"
  index = 0
  while index < counts[0]
    text = text + printEdict(machine, index)
    index = index + 1
  end while
  return text
end function

/// Mirror Quake's ED_PrintEdict_f routine and its observable state changes.
/// @param machine The machine input consumed by `ED_PrintEdict_f`.
/// @param entityIndex Zero-based index of the requested entry.
function ED_PrintEdict_f(machine, entityIndex)
  limit = len(machine.edicts)
  if machine.context is not void and machine.context.edicts is not void then limit = machine.context.edicts.numEdicts end if
  if entityIndex < 0 or entityIndex >= limit then return "Bad edict number\n" end if
  return printEdict(machine, entityIndex)
end function

/// Mirror Quake's ED_Count routine and its observable state changes.
/// @param machine The machine input consumed by `ED_Count`.
function ED_Count(machine)
  return countEdicts(machine)
end function

/// Mirror Quake's ED_WriteGlobals routine and its observable state changes.
/// @param machine The machine input consumed by `ED_WriteGlobals`.
function ED_WriteGlobals(machine)
  return writeGlobals(machine)
end function

/// Mirror Quake's ED_ParseGlobals routine and its observable state changes.
/// @param machine The machine input consumed by `ED_ParseGlobals`.
/// @param entity Entity affected by the operation.
function ED_ParseGlobals(machine, entity)
  for each pair in entity.pairs
    parsed = try(setGlobalByName(machine, pair.key, pair.value))
    if parsed is error then return parsed end if
    if parsed == false then diagnostic(machine, "'" + pair.key + "' is not a global") end if
  end for
  return true
end function

/// Mirror Quake's ED_NewString routine and its observable state changes.
/// @param text Text to parse or process.
function ED_NewString(text)
  return newString(text)
end function

/// Mirror Quake's ED_ParseEpair routine and its observable state changes.
/// @param machine The machine input consumed by `ED_ParseEpair`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param definition The definition input consumed by `ED_ParseEpair`.
/// @param value Value consumed by `ED_ParseEpair`.
/// @param globalBase The global base input consumed by `ED_ParseEpair`.
function ED_ParseEpair(machine, entityIndex, definition, value, globalBase)
  if globalBase then return setGlobalByName(machine, definition.name, value) end if
  return setKeyValue(machine, entityIndex, definition.name, value)
end function

/// Mirror Quake's ED_ParseEdict routine and its observable state changes.
/// @param machine The machine input consumed by `ED_ParseEdict`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param entity Entity affected by the operation.
function ED_ParseEdict(machine, entityIndex, entity)
  return parseEntity(machine, entityIndex, entity)
end function

/// Mirror Quake's ED_LoadFromFile routine and its observable state changes.
/// @param machine The machine input consumed by `ED_LoadFromFile`.
/// @param map The map input consumed by `ED_LoadFromFile`.
/// @param skill The skill input consumed by `ED_LoadFromFile`.
/// @param deathmatch The deathmatch input consumed by `ED_LoadFromFile`.
/// @param firstDynamicIndex Zero-based index of the requested entry.
function ED_LoadFromFile(machine, map, skill, deathmatch, firstDynamicIndex)
  return loadMapEntitiesFrom(machine, map, skill, deathmatch, firstDynamicIndex)
end function

/// Mirror Quake's PR_LoadProgs routine and its observable state changes.
/// @param data Input data consumed by the operation.
/// @param filename Path of the file to process.
function PR_LoadProgs(data, filename)
  program = try(progs.parse(data, filename))
  if program is error then return program end if
  // PROGHEADER_CRC: the generated system globals/fields must retain the
  // stock ABI.  MiniQuake rejects v6 programs that changed that header layout.
  if program.crc != c.PROGHEADER_CRC then return error(2609, filename + ": system vars have been modified; progdefs CRC is " + program.crc) end if
  return program
end function

// Mirror Quake's PR_Init routine and its observable state changes.
function PR_Init()
  return ["edict", "edicts", "edictcount", "profile"]
end function

/// Mirror Quake's EDICT_NUM routine and its observable state changes.
/// @param machine The machine input consumed by `EDICT_NUM`.
/// @param entityIndex Zero-based index of the requested entry.
function EDICT_NUM(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2607, "EDICT_NUM: bad number " + entityIndex) end if
  return entityIndex
end function

/// Mirror Quake's NUM_FOR_EDICT routine and its observable state changes.
/// @param machine The machine input consumed by `NUM_FOR_EDICT`.
/// @param entityIndex Zero-based index of the requested entry.
function NUM_FOR_EDICT(machine, entityIndex)
  limit = len(machine.edicts)
  if machine.context is not void and machine.context.edicts is not void then limit = machine.context.edicts.numEdicts end if
  if entityIndex < 0 or entityIndex >= limit then return error(2608, "NUM_FOR_EDICT: bad pointer") end if
  return entityIndex
end function
