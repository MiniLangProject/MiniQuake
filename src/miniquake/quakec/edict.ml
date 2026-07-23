package miniquake.quakec.edict

import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.format.bsp as bsp
import miniquake.quakec.vm as vm
import miniquake.native as native

function allocate(machine, firstIndex)
  index = firstIndex
  if index < 1 then index = 1 end if
  while index < len(machine.edicts)
    if machine.edictFree[index] then
      machine.edictFree[index] = false
      vm.clearEntity(machine, index)
      return index
    end if
    index = index + 1
  end while
  return error(2600, "ED_Alloc: no free edicts")
end function

function free(machine, entityIndex)
  if entityIndex <= 0 or entityIndex >= len(machine.edicts) then return false end if
  vm.clearEntity(machine, entityIndex)
  machine.edictFree[entityIndex] = true
  return true
end function

function fieldDefinition(machine, name)
  wanted = bio.lower(name)
  for each definition in machine.program.fieldDefs
    if bio.lower(definition.name) == wanted then return definition end if
  end for
  return void
end function

function globalDefinition(machine, name)
  wanted = bio.lower(name)
  for each definition in machine.program.globalDefs
    if bio.lower(definition.name) == wanted then return definition end if
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
  else if valueType == c.EV_FUNCTION then
    vm.setWord(machine, definition.offset, vm.functionIndex(machine, value))
  else
    number = toNumber(value)
    if number is void then number = 0 end if
    vm.setWord(machine, definition.offset, number)
  end if
  return true
end function

function setKeyValue(machine, entityIndex, key, value)
  if key == "" then return false end if
  keyData = bytes(key)
  if len(keyData) > 0 and keyData[0] == 95 then return true end if
  actualKey = key
  actualValue = value
  if bio.lower(actualKey) == "angle" then
    actualKey = "angles"
    actualValue = "0 " + value + " 0"
  else if bio.lower(actualKey) == "light" then
    if fieldDefinition(machine, "light_lev") is not void then actualKey = "light_lev" end if
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
    vm.setEntityField(machine, entityIndex, definition.offset, number)
  else if valueType == c.EV_FIELD then
    referenced = fieldDefinition(machine, actualValue)
    if referenced is void then return false end if
    vm.setEntityField(machine, entityIndex, definition.offset, referenced.offset)
  else if valueType == c.EV_FUNCTION then
    vm.setEntityField(machine, entityIndex, definition.offset, vm.functionIndex(machine, actualValue))
  else
    return false
  end if
  return true
end function

function parseEntity(machine, entityIndex, entity)
  for each pair in entity.pairs
    setKeyValue(machine, entityIndex, pair.key, pair.value)
  end for
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
  spawned = 0
  inhibited = 0
  sourceIndex = 0
  while sourceIndex < len(map.entities)
    entityIndex = 0
    if sourceIndex > 0 then entityIndex = allocate(machine, firstDynamicIndex) end if
    parseEntity(machine, entityIndex, map.entities[sourceIndex])
    if sourceIndex == 0 then initializeWorldEntity(machine, map) end if
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
        vm.setWord(machine, c.QC_GLOBAL_OTHER, 0)
        vm.execute(machine, functionValue)
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
