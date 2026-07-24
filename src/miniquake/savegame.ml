package miniquake.savegame

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.format.bsp as bsp
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as qcedict
import miniquake.array_util as arrayutil

const SAVEGAME_VERSION = 5
const SAVEGAME_COMMENT_LENGTH = 39

function typeSize(valueType)
  if valueType == c.EV_VECTOR then return 3 end if
  if valueType == c.EV_VOID then return 0 end if
  return 1
end function

function vectorComponentName(name)
  data = bytes(name)
  if len(data) < 2 then return false end if
  // ED_Write's original test is only name[strlen(name)-2] == '_'.  It does
  // not validate the final x/y/z suffix.
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

function functionName(machine, index)
  if index < 0 or index >= len(machine.program.functions) then return "" end if
  return machine.program.functions[index].name
end function

function fieldName(machine, offset)
  for each definition in machine.program.fieldDefs
    if definition.offset == offset then return definition.name end if
  end for
  return ""
end function

function uglyValue(machine, words, definition)
  valueType = definition.type & 0x7fff
  offset = definition.offset
  if valueType == c.EV_STRING then return vm.stringValue(machine, words[offset]) end if
  if valueType == c.EV_FLOAT then return qcedict.fixedSixDecimals(native.bitsFloat(words[offset])) end if
  if valueType == c.EV_VECTOR then
    return qcedict.fixedSixDecimals(native.bitsFloat(words[offset])) + " " +
      qcedict.fixedSixDecimals(native.bitsFloat(words[offset + 1])) + " " +
      qcedict.fixedSixDecimals(native.bitsFloat(words[offset + 2]))
  end if
  if valueType == c.EV_ENTITY then return "" + words[offset] end if
  if valueType == c.EV_FIELD then return fieldName(machine, words[offset]) end if
  if valueType == c.EV_FUNCTION then return functionName(machine, words[offset]) end if
  return ""
end function

function writeDefinitions(machine, words, definitions, globalsOnly)
  text = "{\n"
  index = 0
  while index < len(definitions)
    definition = definitions[index]
    valueType = definition.type & 0x7fff
    include = true
    if globalsOnly then
      include = (definition.type & c.DEF_SAVEGLOBAL) != 0
      include = include and (valueType == c.EV_STRING or valueType == c.EV_FLOAT or valueType == c.EV_ENTITY)
    else
      include = index > 0 and not vectorComponentName(definition.name)
    end if
    size = typeSize(valueType)
    if include and size > 0 and definition.offset >= 0 and definition.offset + size <= len(words) then
      if not wordsAreZero(words, definition.offset, size) then
        text = text + "\"" + definition.name + "\" \"" + uglyValue(machine, words, definition) + "\"\n"
      end if
    end if
    index = index + 1
  end while
  return text + "}\n"
end function

function writeGlobals(machine)
  return writeDefinitions(machine, machine.globals, machine.program.globalDefs, true)
end function

function writeEdict(machine, entityIndex)
  if entityIndex < 0 or entityIndex >= len(machine.edicts) then return error(3700, "ED_Write: bad edict " + entityIndex) end if
  if machine.edictFree[entityIndex] then return "{\n}\n" end if
  return writeDefinitions(machine, machine.edicts[entityIndex], machine.program.fieldDefs, false)
end function

function paddedComment(levelName, killed, total)
  output = arrayutil.makeFilledArray(SAVEGAME_COMMENT_LENGTH, 32)
  level = bytes(levelName)
  count = len(level)
  if count > SAVEGAME_COMMENT_LENGTH then count = SAVEGAME_COMMENT_LENGTH end if
  index = 0
  while index < count
    output[index] = level[index]
    index = index + 1
  end while
  killedText = "" + killed
  while len(bytes(killedText)) < 3
    killedText = " " + killedText
  end while
  totalText = "" + total
  while len(bytes(totalText)) < 3
    totalText = " " + totalText
  end while
  kills = bytes("kills:" + killedText + "/" + totalText)
  index = 0
  while index < len(kills) and 22 + index < SAVEGAME_COMMENT_LENGTH
    output[22 + index] = kills[index]
    index = index + 1
  end while
  index = 0
  while index < len(output)
    if output[index] == 32 then output[index] = 95 end if
    index = index + 1
  end while
  return decode(bytes(output))
end function

function namedGlobalFloat(machine, name)
  offset = vm.globalOffset(machine, name)
  if offset < 0 then return 0.0 end if
  return vm.globalFloat(machine, offset)
end function

function serializeServer(server)
  if server.machine is void then return error(3701, "savegame requires an active QuakeC server") end if
  machine = server.machine
  killed = native.trunc(namedGlobalFloat(machine, "killed_monsters"))
  total = native.trunc(namedGlobalFloat(machine, "total_monsters"))
  text = "" + SAVEGAME_VERSION + "\n"
  text = text + paddedComment(server.levelName, killed, total) + "\n"
  spawnParms = arrayutil.makeFilledArray(c.NUM_SPAWN_PARMS, 0.0)
  if len(server.clients) > 0 then spawnParms = server.clients[0].spawnParms end if
  index = 0
  while index < c.NUM_SPAWN_PARMS
    value = 0.0
    if index < len(spawnParms) then value = spawnParms[index] end if
    text = text + qcedict.fixedSixDecimals(value) + "\n"
    index = index + 1
  end while
  text = text + native.trunc(server.skill) + "\n"
  text = text + server.mapName + "\n"
  text = text + qcedict.fixedSixDecimals(server.time) + "\n"
  index = 0
  while index < c.MAX_LIGHTSTYLES
    style = "m"
    if index < len(server.lightStyles) and server.lightStyles[index] != "" then style = server.lightStyles[index] end if
    text = text + style + "\n"
    index = index + 1
  end while
  text = text + writeGlobals(machine)
  index = 0
  while index < server.numEdicts
    text = text + writeEdict(machine, index)
    index = index + 1
  end while
  return text
end function

function readLine(data, offset)
  if offset < 0 or offset > len(data) then return error(3702, "savegame line offset outside file") end if
  finish = offset
  while finish < len(data) and data[finish] != 10 and data[finish] != 13
    finish = finish + 1
  end while
  line = decode(slice(data, offset, finish - offset))
  while finish < len(data) and (data[finish] == 10 or data[finish] == 13)
    finish = finish + 1
  end while
  return [line, finish]
end function

function numberLine(data, offset, label)
  line = readLine(data, offset)
  value = toNumber(line[0])
  if value is void then return error(3703, "invalid savegame " + label + ": " + line[0]) end if
  return [value, line[1]]
end function

function parse(text)
  data = bytes(text)
  cursor = 0
  versionLine = numberLine(data, cursor, "version")
  version = native.trunc(versionLine[0])
  cursor = versionLine[1]
  if version != SAVEGAME_VERSION then return error(3704, "savegame is version " + version + ", not " + SAVEGAME_VERSION) end if
  commentLine = readLine(data, cursor)
  comment = commentLine[0]
  cursor = commentLine[1]
  spawnParms = arrayutil.makeEmptyArray(c.NUM_SPAWN_PARMS)
  index = 0
  while index < c.NUM_SPAWN_PARMS
    valueLine = numberLine(data, cursor, "spawn parm " + index)
    spawnParms[index] = valueLine[0]
    cursor = valueLine[1]
    index = index + 1
  end while
  skillLine = numberLine(data, cursor, "skill")
  skill = native.trunc(skillLine[0] + 0.1)
  cursor = skillLine[1]
  mapLine = readLine(data, cursor)
  mapName = mapLine[0]
  cursor = mapLine[1]
  timeLine = numberLine(data, cursor, "time")
  time = timeLine[0]
  cursor = timeLine[1]
  lightStyles = arrayutil.makeEmptyArray(c.MAX_LIGHTSTYLES)
  index = 0
  while index < c.MAX_LIGHTSTYLES
    styleLine = readLine(data, cursor)
    lightStyles[index] = styleLine[0]
    cursor = styleLine[1]
    index = index + 1
  end while
  if cursor >= len(data) then return error(3705, "savegame has no globals or edicts") end if
  blocks = bsp.parseEntities(decode(slice(data, cursor, len(data) - cursor)))
  if len(blocks) < 1 then return error(3706, "savegame has no global block") end if
  entityCount = len(blocks) - 1
  entities = arrayutil.makeEmptyArray(entityCount)
  index = 0
  while index < entityCount
    entities[index] = blocks[index + 1]
    index = index + 1
  end while
  return t.SaveGame(version, comment, spawnParms, skill, mapName, time, lightStyles, blocks[0], entities)
end function

function apply(server, saved)
  if server.machine is void or server.machine.context is void then return error(3707, "loadgame requires a spawned QuakeC server") end if
  machine = server.machine
  if len(saved.entities) > len(machine.edicts) then return error(3708, "savegame has too many edicts: " + len(saved.entities)) end if
  for each pair in saved.globalState.pairs
    qcedict.setGlobalByName(machine, pair.key, pair.value)
  end for
  index = 0
  while index < len(machine.edicts)
    vm.clearEntity(machine, index)
    machine.edictFree[index] = true
    index = index + 1
  end while
  index = 0
  while index < len(saved.entities)
    entity = saved.entities[index]
    if len(entity.pairs) > 0 then
      machine.edictFree[index] = false
      for each pair in entity.pairs
        if not qcedict.setKeyValue(machine, index, pair.key, pair.value) then
          return error(3709, "savegame field could not be restored: " + pair.key)
        end if
      end for
    end if
    index = index + 1
  end while
  if len(saved.entities) > 0 then machine.edictFree[0] = false end if
  runtime = machine.context.edicts
  runtime.numEdicts = len(saved.entities)
  server.numEdicts = len(saved.entities)
  server.time = saved.time
  server.skill = saved.skill
  server.lightStyles = saved.lightStyles
  machine.context.lightStyles = server.lightStyles
  machine.context.serverTime = saved.time
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, saved.time)
  if len(server.clients) > 0 then server.clients[0].spawnParms = saved.spawnParms end if
  return true
end function

function displayComment(comment)
  data = bytes(comment)
  index = 0
  while index < len(data)
    if data[index] == 95 then data[index] = 32 end if
    index = index + 1
  end while
  return decode(data)
end function

function inspectComment(text)
  data = bytes(text)
  versionLine = numberLine(data, 0, "version")
  if native.trunc(versionLine[0]) != SAVEGAME_VERSION then return "" end if
  commentLine = readLine(data, versionLine[1])
  return displayComment(commentLine[0])
end function

function hasSuffixInsensitive(text, suffix)
  left = bytes(text)
  right = bytes(suffix)
  if len(right) > len(left) then return false end if
  index = 0
  while index < len(right)
    a = left[len(left) - len(right) + index]
    b = right[index]
    if a >= 65 and a <= 90 then a = a + 32 end if
    if b >= 65 and b <= 90 then b = b + 32 end if
    if a != b then return false end if
    index = index + 1
  end while
  return true
end function

function filename(name)
  if name == "" then return error(3710, "empty savegame name") end if
  data = bytes(name)
  index = 0
  while index < len(data)
    value = data[index]
    if value == 47 or value == 92 or value == 58 then return error(3711, "relative savegame paths are not allowed") end if
    if value == 46 and index + 1 < len(data) and data[index + 1] == 46 then return error(3711, "relative savegame paths are not allowed") end if
    index = index + 1
  end while
  if hasSuffixInsensitive(name, ".sav") then return name end if
  return name + ".sav"
end function

// host_cmd.c entry points.  SaveGamestate/LoadGamestate are used only by the
// QUAKE2 compile-time path in the reference, but retain useful in-memory
// counterparts so the original functions have concrete MiniLang code sites.
function Host_SavegameComment(levelName, killed, total)
  return paddedComment(levelName, killed, total)
end function

function SaveGamestate(server)
  return serializeServer(server)
end function

function LoadGamestate(server, text)
  saved = parse(text)
  if saved is error then return saved end if
  return apply(server, saved)
end function
