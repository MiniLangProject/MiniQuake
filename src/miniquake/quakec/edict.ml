package miniquake.quakec.edict

import miniquake.types as t
import miniquake.constants as c
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.quakec.vm as vm
import miniquake.native as native

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

function fieldDefinition(machine, name)
  for each definition in machine.program.fieldDefs
    if definition.name == name then return definition end if
  end for
  return void
end function

function globalDefinition(machine, name)
  for each definition in machine.program.globalDefs
    if definition.name == name then return definition end if
  end for
  return void
end function

function setGlobalByName(machine, name, value)
  definition = globalDefinition(machine, name)
  if definition is void then return false end if
  valueType = definition.type & 0x7fff
  if valueType == c.EV_STRING then
    vm.setGlobalString(machine, definition.offset, value)
  else if valueType == c.EV_FLOAT then
    number = toNumber(value)
    if number is void then number = 0.0 end if
    vm.setGlobalFloat(machine, definition.offset, number)
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

function trimTrailingSpaces(text)
  data = bytes(text)
  count = len(data)
  while count > 0 and data[count - 1] == 32
    count = count - 1
  end while
  if count == len(data) then return text end if
  return decode(slice(data, 0, count))
end function

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
    number = toNumber(actualValue)
    if number is void then number = 0.0 end if
    vm.setEntityFloat(machine, entityIndex, definition.offset, number)
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

function parseEntity(machine, entityIndex, entity)
  // ED_ParseEdict clears every non-world edict before consuming its pairs.
  if entityIndex != 0 then vm.clearEntity(machine, entityIndex) end if
  initialized = false
  for each pair in entity.pairs
    initialized = true
    parsed = try(setKeyValue(machine, entityIndex, pair.key, pair.value))
    if parsed is error then return parsed end if
  end for
  if not initialized then machine.edictFree[entityIndex] = true end if
  return entityIndex
end function

function setWorldVector(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityVector(machine, 0, definition.offset, value) end if
end function

function setWorldFloat(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityFloat(machine, 0, definition.offset, value) end if
end function

function setWorldString(machine, name, value)
  definition = fieldDefinition(machine, name)
  if definition is not void then vm.setEntityString(machine, 0, definition.offset, value) end if
end function

// SV_SpawnServer initializes the world edict before ED_LoadFromFile.  The
// entity text then contributes keys such as message/sounds/worldtype while the
// engine-owned model, bounds and collision fields stay authoritative.
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

function className(machine, entityIndex)
  field = vm.fieldOffset(machine, "classname")
  if field < 0 then return "" end if
  return vm.entityString(machine, entityIndex, field)
end function

function loadMapEntitiesFrom(machine, map, skill, deathmatch, firstDynamicIndex)
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

function loadMapEntities(machine, map, skill, deathmatch)
  return loadMapEntitiesFrom(machine, map, skill, deathmatch, 1)
end function

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

function typeSize(valueType)
  valueType = valueType & 0x7fff
  if valueType == c.EV_VOID then return 0 end if
  if valueType == c.EV_VECTOR then return 3 end if
  return 1
end function

function definitionAtOffset(definitions, offset)
  for each definition in definitions
    if definition.offset == offset then return definition end if
  end for
  return void
end function

function vectorComponentDefinition(name)
  data = bytes(name)
  if len(data) < 2 then return false end if
  return data[len(data) - 2] == 95
end function

function wordsAreZero(words, offset, count)
  index = 0
  while index < count
    if offset + index >= len(words) or words[offset + index] != 0 then return false end if
    index = index + 1
  end while
  return true
end function

function edictFloor(value)
  truncated = native.trunc(value)
  if value < truncated then return truncated - 1 end if
  return truncated
end function

function edictCeil(value)
  truncated = native.trunc(value)
  if value > truncated then return truncated + 1 end if
  return truncated
end function

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

function fixedSixDecimals(value)
  negative = value < 0.0
  magnitude = value
  if negative then magnitude = -magnitude end if
  scaled = native.trunc(magnitude * 1000000.0 + 0.5)
  whole = native.trunc(scaled / 1000000)
  fraction = "" + (scaled % 1000000)
  while len(bytes(fraction)) < 6
    fraction = "0" + fraction
  end while
  text = "" + whole + "." + fraction
  if negative then text = "-" + text end if
  return text
end function

function valueString(machine, valueType, words, offset, ugly)
  valueType = valueType & 0x7fff
  if valueType == c.EV_STRING then return vm.stringValue(machine, words[offset]) end if
  if valueType == c.EV_ENTITY then
    if ugly then return "" + words[offset] end if
    return "entity " + words[offset]
  end if
  if valueType == c.EV_FUNCTION then
    index = words[offset]
    if index < 0 or index >= len(machine.program.functions) then return "" end if
    name = machine.program.functions[index].name
    if ugly then return name end if
    return name + "()"
  end if
  if valueType == c.EV_FIELD then
    definition = definitionAtOffset(machine.program.fieldDefs, words[offset])
    if definition is void then return "" end if
    if ugly then return definition.name end if
    return "." + definition.name
  end if
  if valueType == c.EV_VOID then return "void" end if
  if valueType == c.EV_FLOAT then
    value = native.bitsFloat(words[offset])
    if ugly then return fixedSixDecimals(value) end if
    return fixedOneDecimal(value)
  end if
  if valueType == c.EV_VECTOR then
    x = native.bitsFloat(words[offset])
    y = native.bitsFloat(words[offset + 1])
    z = native.bitsFloat(words[offset + 2])
    if ugly then return fixedSixDecimals(x) + " " + fixedSixDecimals(y) + " " + fixedSixDecimals(z) end if
    return "'" + fixedOneDecimal(x) + " " + fixedOneDecimal(y) + " " + fixedOneDecimal(z) + "'"
  end if
  if valueType == c.EV_POINTER and not ugly then return "pointer" end if
  return "bad type " + valueType
end function

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

function writeEdict(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2606, "ED_Write: bad edict " + entityIndex) end if
  text = "{\n"
  if machine.edictFree[entityIndex] then return text + "}\n" end if
  index = 1
  while index < len(machine.program.fieldDefs)
    definition = machine.program.fieldDefs[index]
    size = typeSize(definition.type)
    include = not vectorComponentDefinition(definition.name) and size > 0
    include = include and definition.offset + size <= len(machine.edicts[entityIndex])
    include = include and not wordsAreZero(machine.edicts[entityIndex], definition.offset, size)
    if include then
      text = text + "\"" + definition.name + "\" \"" +
        valueString(machine, definition.type, machine.edicts[entityIndex], definition.offset, true) + "\"\n"
    end if
    index = index + 1
  end while
  return text + "}\n"
end function

function writeGlobals(machine)
  text = "{\n"
  for each definition in machine.program.globalDefs
    valueType = definition.type & 0x7fff
    include = (definition.type & c.DEF_SAVEGLOBAL) != 0
    include = include and (valueType == c.EV_STRING or valueType == c.EV_FLOAT or valueType == c.EV_ENTITY)
    if include then
      text = text + "\"" + definition.name + "\" \"" +
        valueString(machine, valueType, machine.globals, definition.offset, true) + "\"\n"
    end if
  end for
  return text + "}\n"
end function

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

function newString(text)
  source = bytes(text)
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
  return decode(slice(output, 0, outputIndex))
end function

// Explicit GLQuake entry-point names provide a one-to-one code-location map.
function ED_ClearEdict(machine, entityIndex)
  vm.clearEntity(machine, entityIndex)
  machine.edictFree[entityIndex] = false
  return entityIndex
end function

function ED_Alloc(machine, firstIndex)
  return allocate(machine, firstIndex)
end function

function ED_Free(machine, entityIndex)
  return free(machine, entityIndex)
end function

function ED_GlobalAtOfs(machine, offset)
  return definitionAtOffset(machine.program.globalDefs, offset)
end function

function ED_FieldAtOfs(machine, offset)
  return definitionAtOffset(machine.program.fieldDefs, offset)
end function

function ED_FindField(machine, name)
  return fieldDefinition(machine, name)
end function

function ED_FindGlobal(machine, name)
  return globalDefinition(machine, name)
end function

function ED_FindFunction(machine, name)
  return vm.functionIndex(machine, name)
end function

function GetEdictFieldValue(machine, entityIndex, name)
  definition = fieldDefinition(machine, name)
  if definition is void then return void end if
  return [definition.offset, vm.entityField(machine, entityIndex, definition.offset)]
end function

function PR_ValueString(machine, valueType, words, offset)
  return valueString(machine, valueType, words, offset, false)
end function

function PR_UglyValueString(machine, valueType, words, offset)
  return valueString(machine, valueType, words, offset, true)
end function

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

function PR_GlobalStringNoContents(machine, offset)
  definition = ED_GlobalAtOfs(machine, offset)
  text = ""
  if definition is void then text = offset + "(???)" else text = offset + "(" + definition.name + ")" end if
  while len(bytes(text)) < 20
    text = text + " "
  end while
  return text + " "
end function

function ED_Print(machine, entityIndex)
  return printEdict(machine, entityIndex)
end function

function ED_Write(machine, entityIndex)
  return writeEdict(machine, entityIndex)
end function

function ED_PrintNum(machine, entityIndex)
  return printEdict(machine, entityIndex)
end function

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

function ED_PrintEdict_f(machine, entityIndex)
  return printEdict(machine, entityIndex)
end function

function ED_Count(machine)
  return countEdicts(machine)
end function

function ED_WriteGlobals(machine)
  return writeGlobals(machine)
end function

function ED_ParseGlobals(machine, entity)
  for each pair in entity.pairs
    parsed = try(setGlobalByName(machine, pair.key, pair.value))
    if parsed is error then return parsed end if
  end for
  return true
end function

function ED_NewString(text)
  return newString(text)
end function

function ED_ParseEpair(machine, entityIndex, definition, value, globalBase)
  if globalBase then return setGlobalByName(machine, definition.name, value) end if
  return setKeyValue(machine, entityIndex, definition.name, value)
end function

function ED_ParseEdict(machine, entityIndex, entity)
  return parseEntity(machine, entityIndex, entity)
end function

function ED_LoadFromFile(machine, map, skill, deathmatch, firstDynamicIndex)
  return loadMapEntitiesFrom(machine, map, skill, deathmatch, firstDynamicIndex)
end function

function PR_LoadProgs(data, filename)
  program = try(progs.parse(data, filename))
  if program is error then return program end if
  // PROGHEADER_CRC: the generated system globals/fields must retain the
  // stock ABI.  GLQuake rejects v6 programs that changed that header layout.
  if program.crc != 5927 then return error(2609, filename + ": system vars have been modified; progdefs CRC is " + program.crc) end if
  return program
end function

function PR_Init()
  return ["edict", "edicts", "edictcount", "profile"]
end function

function EDICT_NUM(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(2607, "EDICT_NUM: bad number " + entityIndex) end if
  return entityIndex
end function

function NUM_FOR_EDICT(machine, entityIndex)
  limit = len(machine.edicts)
  if machine.context is not void and machine.context.edicts is not void then limit = machine.context.edicts.numEdicts end if
  if entityIndex < 0 or entityIndex >= limit then return error(2608, "NUM_FOR_EDICT: bad pointer") end if
  return entityIndex
end function
