/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/pr_edict_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.byteio as bio
import miniquake.array_util as arrayutil
import miniquake.format.bsp as bsp
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as edict

// Create and initialize machine.
function makeMachine()
  fields = [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_STRING, 0, 0, "model"),
    t.QuakeCDef(c.EV_FLOAT, 1, 0, "takedamage"),
    t.QuakeCDef(c.EV_FLOAT, 2, 0, "modelindex"),
    t.QuakeCDef(c.EV_FLOAT, 3, 0, "colormap"),
    t.QuakeCDef(c.EV_FLOAT, 4, 0, "skin"),
    t.QuakeCDef(c.EV_FLOAT, 5, 0, "frame"),
    t.QuakeCDef(c.EV_VECTOR, 6, 0, "origin"),
    t.QuakeCDef(c.EV_VECTOR, 9, 0, "angles"),
    t.QuakeCDef(c.EV_FLOAT, 12, 0, "nextthink"),
    t.QuakeCDef(c.EV_FLOAT, 13, 0, "solid"),
    t.QuakeCDef(c.EV_FLOAT, 14, 0, "movetype"),
    t.QuakeCDef(c.EV_FLOAT, 15, 0, "spawnflags"),
    t.QuakeCDef(c.EV_STRING, 16, 0, "classname"),
    t.QuakeCDef(c.EV_FLOAT, 17, 0, "health"),
  ]
  globals = [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_FLOAT | c.DEF_SAVEGLOBAL, 10, 0, "globalx"),
  ]
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  spawnFunction = t.QuakeCFunction(0, 0, 0, 0, "spawnfn", "fixture.qc", 0, [])
  program = t.QuakeCProgram(
    "pr_edict_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    5927,
    [t.QuakeCStatement(op.OP_DONE, 0, 0, 0)],
    globals,
    fields,
    [dummy, spawnFunction],
    bytes(1),
    vm.zeroArray(64),
    18,
  )
  machine = vm.create(program, 16)
  freeFlags = arrayutil.makeFilledArray(16, true)
  freeTimes = arrayutil.makeFilledArray(16, 0.0)
  freeFlags[0] = false
  freeFlags[1] = false
  runtime = t.EdictRuntime(16, 2, freeFlags, freeTimes)
  context = t.QuakeCContext(
    void,
    void,
    void,
    void,
    void,
    runtime,
    [],
    [],
    [],
    void,
    void,
    void,
    [],
    [],
    [],
    [],
    [],
    10.0,
    1,
    "",
    0,
    void,
    [],
    [],
    0,
    0.0,
    bytes(),
  )
  vm.setContext(machine, context)
  machine.edictFree = runtime.freeFlags
  return machine
end function

// Encode and write ascii.
function putAscii(data, offset, text)
  source = bytes(text)
  index = 0
  while index < len(source)
    data[offset + index] = source[index]
    index = index + 1
  end while
  return offset + len(source)
end function

// Create and initialize synthetic progs.
function makeSyntheticProgs()
  statementOffset = 60
  globalDefOffset = statementOffset + 8
  fieldDefOffset = globalDefOffset + 16
  functionOffset = fieldDefOffset + 24
  stringOffset = functionOffset + 72
  globalsOffset = stringOffset + 128
  data = bytes(globalsOffset + 64 * 4)

  bio.putI32(data, 0, c.PROG_VERSION)
  bio.putI32(data, 4, 5927)
  bio.putI32(data, 8, statementOffset)
  bio.putI32(data, 12, 1)
  bio.putI32(data, 16, globalDefOffset)
  bio.putI32(data, 20, 2)
  bio.putI32(data, 24, fieldDefOffset)
  bio.putI32(data, 28, 3)
  bio.putI32(data, 32, functionOffset)
  bio.putI32(data, 36, 2)
  bio.putI32(data, 40, stringOffset)
  bio.putI32(data, 44, 128)
  bio.putI32(data, 48, globalsOffset)
  bio.putI32(data, 52, 64)
  bio.putI32(data, 56, 18)

  bio.putU16(data, statementOffset, op.OP_DONE)
  bio.putU16(data, globalDefOffset + 8, c.EV_FLOAT | c.DEF_SAVEGLOBAL)
  bio.putU16(data, globalDefOffset + 10, 10)
  bio.putI32(data, globalDefOffset + 12, 32)
  bio.putU16(data, fieldDefOffset + 8, c.EV_FLOAT)
  bio.putU16(data, fieldDefOffset + 10, 17)
  bio.putI32(data, fieldDefOffset + 12, 1)
  bio.putU16(data, fieldDefOffset + 16, c.EV_STRING)
  bio.putU16(data, fieldDefOffset + 18, 16)
  bio.putI32(data, fieldDefOffset + 20, 16)
  bio.putI32(data, functionOffset + 36, 0)
  bio.putI32(data, functionOffset + 52, 48)
  bio.putI32(data, functionOffset + 56, 64)

  putAscii(data, stringOffset + 1, "health")
  putAscii(data, stringOffset + 16, "classname")
  putAscii(data, stringOffset + 32, "globalx")
  putAscii(data, stringOffset + 48, "spawnfn")
  return data
end function

// Return oracle stub crc derived from the active module state.
function oracleStubCrc(data)
  value = 0xffff
  for each item in data
    value = (value ^ item) & 0xffff
  end for
  return value
end function

// Add edict to the destination state.
function emitEdict(functionName, caseName, result, index, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"index\":" + index +
    ",\"value\":" + native.floatText(value) + ",\"count\":" + count + "}"
end function

// Exercise bool int as part of this deterministic regression fixture.
function boolInt(value)
  if value then return 1 end if
  return 0
end function

// Return fatal mode derived from the active module state.
function fatalMode(name)
  machine = makeMachine()
  result = void
  if name == "--error-edict-num" then
    result = try(edict.EDICT_NUM(machine, -1))
  else
    result = try(edict.NUM_FOR_EDICT(machine, machine.context.edicts.numEdicts))
  end if
  if result is error then return 42 end if
  return 0
end function

// Exercise hidden semantic checks as part of this deterministic regression fixture.
function hiddenSemanticChecks()
  machine = makeMachine()
  vm.setEntityFloat(machine, 1, 17, 99.0)
  emptyEntity = bsp.parseEntities("{ }")[0]
  parsed = try(edict.ED_ParseEdict(machine, 1, emptyEntity))
  if parsed is error then return parsed end if
  if not machine.edictFree[1] then return error(9880, "empty ED_ParseEdict must free the edict") end if
  if vm.entityFloat(machine, 1, 17) != 0.0 then return error(9881, "ED_ParseEdict must clear non-world fields") end if

  // ED_LoadFromFile sets only `self` before a spawn function; `other` is not
  // reset between entity spawns in the original global VM.
  machine = makeMachine()
  vm.setWord(machine, c.QC_GLOBAL_OTHER, 7)
  entities = bsp.parseEntities("{ \"classname\" \"spawnfn\" }")
  map = t.BspMap("maps/start.bsp", bytes(), 29, [], "", entities, [], [], [], bytes(), [], [], [], bytes(), [], [], [], [], [], [])
  loaded = try(edict.ED_LoadFromFile(machine, map, 1, false, 1))
  if loaded is error then return loaded end if
  if vm.word(machine, c.QC_GLOBAL_OTHER) != 7 then return error(9882, "ED_LoadFromFile must preserve `other`") end if
  badProgs = makeSyntheticProgs()
  bio.putI32(badProgs, 4, 1)
  rejected = try(edict.PR_LoadProgs(badProgs, "bad-progs.dat"))
  if not rejected is error then return error(9883, "PR_LoadProgs must enforce PROGHEADER_CRC") end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 and (args[0] == "--error-edict-num" or args[0] == "--error-num-for-edict") then
    return fatalMode(args[0])
  end if
  hidden = try(hiddenSemanticChecks())
  if hidden is error then return 1 end if

  machine = makeMachine()
  vm.setEntityFloat(machine, 1, 17, 9.0)
  machine.edictFree[1] = true
  cleared = edict.ED_ClearEdict(machine, 1)
  emitEdict("ED_ClearEdict", "clear", boolInt(not machine.edictFree[cleared]), cleared, vm.entityFloat(machine, cleared, 17), 0)

  machine = makeMachine()
  allocated = edict.ED_Alloc(machine, 1)
  emitEdict("ED_Alloc", "append", 1, allocated, 0.0, machine.context.edicts.numEdicts)
  edict.ED_Free(machine, allocated)
  emitEdict("ED_Free", "release", boolInt(machine.edictFree[allocated]), allocated, machine.context.edicts.freeTimes[allocated], 1)

  machine = makeMachine()
  definition = edict.ED_GlobalAtOfs(machine, 10)
  emitEdict("ED_GlobalAtOfs", "hit", boolInt(definition is not void), definition.offset, 0.0, 0)
  definition = edict.ED_FieldAtOfs(machine, 17)
  emitEdict("ED_FieldAtOfs", "hit", boolInt(definition is not void), definition.offset, 0.0, 0)
  definition = edict.ED_FindField(machine, "health")
  emitEdict("ED_FindField", "name", boolInt(definition is not void), definition.offset, 0.0, 0)
  definition = edict.ED_FindGlobal(machine, "globalx")
  emitEdict("ED_FindGlobal", "name", boolInt(definition is not void), definition.offset, 0.0, 0)
  functionIndex = edict.ED_FindFunction(machine, "spawnfn")
  emitEdict("ED_FindFunction", "name", boolInt(functionIndex != 0), functionIndex, 0.0, 0)

  vm.setEntityFloat(machine, 1, 17, 12.5)
  fieldValue = edict.GetEdictFieldValue(machine, 1, "health")
  emitEdict("GetEdictFieldValue", "health", boolInt(fieldValue is not void), 1, vm.entityFloat(machine, 1, fieldValue[0]), 0)
  valueWords = [native.floatBits(12.5)]
  text = edict.PR_ValueString(machine, c.EV_FLOAT, valueWords, 0)
  emitEdict("PR_ValueString", "float", 1, len(bytes(text)), 12.5, 0)
  text = edict.PR_UglyValueString(machine, c.EV_FLOAT, valueWords, 0)
  emitEdict("PR_UglyValueString", "float", 1, len(bytes(text)), 12.5, 0)
  vm.setGlobalFloat(machine, 10, 12.5)
  text = edict.PR_GlobalString(machine, 10)
  emitEdict("PR_GlobalString", "known", 1, len(bytes(text)), vm.globalFloat(machine, 10), 0)
  text = edict.PR_GlobalStringNoContents(machine, 10)
  emitEdict("PR_GlobalStringNoContents", "known", 1, len(bytes(text)), 0.0, 0)

  text = edict.ED_Print(machine, 1)
  emitEdict("ED_Print", "active", 1, 1, vm.entityFloat(machine, 1, 17), 12)
  text = edict.ED_Write(machine, 1)
  emitEdict("ED_Write", "active", 1, 1, 0.0, 4)
  text = edict.ED_PrintNum(machine, 1)
  emitEdict("ED_PrintNum", "one", 1, 1, 0.0, 12)
  text = edict.ED_PrintEdicts(machine)
  emitEdict("ED_PrintEdicts", "all", 1, machine.context.edicts.numEdicts, 0.0, 14)
  text = edict.ED_PrintEdict_f(machine, 1)
  emitEdict("ED_PrintEdict_f", "command", 1, 1, 0.0, 12)
  vm.setEntityString(machine, 1, 0, "progs/fixture.mdl")
  vm.setEntityFloat(machine, 1, 13, 1.0)
  vm.setEntityFloat(machine, 1, 14, 4.0)
  counts = edict.ED_Count(machine)
  emitEdict("ED_Count", "summary", 1, counts[0], 0.0, 5)
  text = edict.ED_WriteGlobals(machine)
  emitEdict("ED_WriteGlobals", "saved", 1, 10, vm.globalFloat(machine, 10), 4)

  globalEntity = bsp.parseEntities("{ \"globalx\" \"7.5\" }")[0]
  edict.ED_ParseGlobals(machine, globalEntity)
  emitEdict("ED_ParseGlobals", "float", 1, 10, vm.globalFloat(machine, 10), 0)
  text = edict.ED_NewString("a\\nb")
  emitEdict("ED_NewString", "escape", boolInt(bytes(text)[1] == 10), len(bytes(text)), 0.0, 0)
  vm.setGlobalFloat(machine, 10, 0.0)
  edict.ED_ParseEpair(machine, 0, edict.ED_FindGlobal(machine, "globalx"), "3.25", true)
  emitEdict("ED_ParseEpair", "float", 1, 10, vm.globalFloat(machine, 10), 0)
  parsedEntity = bsp.parseEntities("{ \"health\" \"42\" }")[0]
  edict.ED_ParseEdict(machine, 1, parsedEntity)
  emitEdict("ED_ParseEdict", "pair", 1, 1, vm.entityFloat(machine, 1, 17), 0)

  machine = makeMachine()
  entities = bsp.parseEntities("{ \"classname\" \"spawnfn\" \"health\" \"5\" }")
  map = t.BspMap("maps/start.bsp", bytes(), 29, [], "", entities, [], [], [], bytes(), [], [], [], bytes(), [], [], [], [], [], [])
  loaded = edict.ED_LoadFromFile(machine, map, 1, false, 1)
  emitEdict("ED_LoadFromFile", "world_spawn", 1, 0, vm.entityFloat(machine, 0, 17), machine.program.functions[1].profile)

  progsData = makeSyntheticProgs()
  loadedProgram = edict.PR_LoadProgs(progsData, "progs.dat")
  emitEdict("PR_LoadProgs", "synthetic", loadedProgram.version, loadedProgram.entityFields * 4 + 8, oracleStubCrc(progsData), len(loadedProgram.functions))
  commands = edict.PR_Init()
  emitEdict("PR_Init", "register", 1, len(commands), 0.0, 11)

  machine = makeMachine()
  entityIndex = edict.EDICT_NUM(machine, 1)
  emitEdict("EDICT_NUM", "valid", 1, entityIndex, 0.0, boolInt(entityIndex == 1))
  entityIndex = edict.NUM_FOR_EDICT(machine, entityIndex)
  emitEdict("NUM_FOR_EDICT", "valid", entityIndex, 1, 0.0, 0)
  return 0
end function
