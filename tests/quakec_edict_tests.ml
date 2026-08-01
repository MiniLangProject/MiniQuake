/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-022 source-guided ED_* fixtures: allocation lifetime, epair parsing,
Quake byte entity text, save serialization and debug formatting.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.common as common
import miniquake.protocol_text as protocolText
import miniquake.format.bsp as bsp
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as edict
import miniquake.savegame as savegame
import miniquake.array_util as arrayutil
import miniquake.sizebuf as sz

function equal(actual, expected, name)
  if actual != expected then return error(10200, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function yes(value, name)
  if value != true then return error(10201, name + ": expected true") end if
  return true
end function

function equalText(actual, expected, name)
  if typeof(actual) != "string" then return error(10202, name + ": expected string, got " + typeof(actual)) end if
  if typeof(expected) != "string" then return error(10203, name + ": fixture expected value is not a string") end if
  if actual != expected then return error(10204, name + ": text mismatch") end if
  return true
end function

function contains(text, wanted)
  source = bytes(text)
  needle = bytes(wanted)
  if len(needle) == 0 then return true end if
  start = 0
  while start + len(needle) <= len(source)
    index = 0
    while index < len(needle) and source[start + index] == needle[index]
      index = index + 1
    end while
    if index == len(needle) then return true end if
    start = start + 1
  end while
  return false
end function

function run(number, name, fn)
  print "  [" + number + "/22] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

function def(typeValue, offset, name)
  return t.QuakeCDef(typeValue, offset, 0, name)
end function

function fieldDefs()
  return [
    def(c.EV_VOID, 0, ""),
    def(c.EV_STRING, 1, "classname"),
    def(c.EV_VECTOR, 2, "angles"),
    def(c.EV_FLOAT, 3, "angles_x"),
    def(c.EV_FLOAT, 4, "angles_y"),
    def(c.EV_FLOAT, 5, "light_lev"),
    def(c.EV_FLOAT, 6, "health"),
    def(c.EV_FIELD, 7, "targetfield"),
    def(c.EV_FUNCTION, 8, "think"),
    def(c.EV_ENTITY, 9, "enemy"),
    def(c.EV_STRING, 10, "message"),
    def(c.EV_FLOAT, 11, "modelindex"),
    def(c.EV_FLOAT, 12, "colormap"),
    def(c.EV_FLOAT, 13, "skin"),
    def(c.EV_FLOAT, 14, "frame"),
    def(c.EV_STRING, 15, "model"),
    def(c.EV_FLOAT, 16, "takedamage"),
    def(c.EV_FLOAT, 17, "solid"),
    def(c.EV_VECTOR, 18, "origin"),
    def(c.EV_VECTOR, 21, "mins"),
    def(c.EV_VECTOR, 24, "maxs"),
    def(c.EV_FLOAT, 27, "nextthink"),
    def(c.EV_FLOAT, 28, "movetype"),
    def(c.EV_VOID, 29, "voidslot"),
  ]
end function

function globalDefs()
  return [
    def(c.EV_VOID, 0, ""),
    def(c.EV_FLOAT | c.DEF_SAVEGLOBAL, 40, "globalx"),
    def(c.EV_STRING | c.DEF_SAVEGLOBAL, 41, "globalstr"),
    def(c.EV_ENTITY | c.DEF_SAVEGLOBAL, 42, "globalent"),
    def(c.EV_VECTOR | c.DEF_SAVEGLOBAL, 43, "ignoredvector"),
  ]
end function

function makeMachine()
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, array(8, 0))
  spawnfn = t.QuakeCFunction(0, 0, 0, 0, "spawnfn", "fixture.qc", 0, array(8, 0))
  program = t.QuakeCProgram("edict-fixture.dat", bytes(), c.PROG_VERSION, c.PROGHEADER_CRC, [], globalDefs(), fieldDefs(), [dummy, spawnfn], bytes([0]), array(96, 0), 32)
  machine = vm.create(program, 8)
  freeFlags = arrayutil.makeFilledArray(8, true)
  freeTimes = arrayutil.makeFilledArray(8, 0.0)
  freeFlags[0] = false
  freeFlags[1] = false
  machine.edictFree = freeFlags
  runtime = t.EdictRuntime(8, 2, freeFlags, freeTimes)
  machine.context = t.QuakeCContext(
    void, void, void, void, void, runtime,
    [], [], [], sz.alloc(1024), sz.alloc(1024), sz.alloc(1024),
    [], [], [], [], [], 0.0, 1, "", 0, void, [], [], 0, 0.0, bytes(),
  )
  return machine
end function

function pair(key, value)
  return t.EntityPair(key, value)
end function

function entity(pairs)
  return t.Entity(pairs)
end function

function testTypeSizes()
  equal(edict.typeSize(c.EV_VOID), 1, "edict void size")
  equal(edict.typeSize(c.EV_VECTOR), 3, "edict vector size")
  equal(savegame.typeSize(c.EV_VOID), 1, "savegame void size")
  return true
end function

function testAllocateAppend()
  machine = makeMachine()
  index = edict.ED_Alloc(machine, 1)
  equal(index, 2, "new high-water index")
  equal(machine.context.edicts.numEdicts, 3, "advanced high-water mark")
  return true
end function

function testReuseDelay()
  machine = makeMachine()
  machine.context.serverTime = 3.0
  edict.ED_Free(machine, 1)
  machine.context.serverTime = 3.25
  equal(edict.ED_Alloc(machine, 1), 2, "recent slot not reused")
  machine.context.serverTime = 3.75
  equal(edict.ED_Alloc(machine, 1), 1, "old slot reused")
  return true
end function

function testEarlyFreeReuse()
  machine = makeMachine()
  machine.edictFree[1] = true
  machine.context.edicts.freeTimes[1] = 1.5
  machine.context.serverTime = 1.6
  equal(edict.ED_Alloc(machine, 1), 1, "early free-time slot reused")
  return true
end function

function testFreeClearsFields()
  machine = makeMachine()
  vm.setEntityString(machine, 1, 15, "progs/test.mdl")
  vm.setEntityFloat(machine, 1, 11, 3.0)
  vm.setEntityFloat(machine, 1, 17, 4.0)
  vm.setEntityVector(machine, 1, 18, t.Vec3(1.0, 2.0, 3.0))
  vm.setEntityFloat(machine, 1, 27, 8.0)
  edict.ED_Free(machine, 1)
  equal(vm.entityField(machine, 1, 15), 0, "model cleared")
  equal(vm.entityFloat(machine, 1, 11), 0.0, "modelindex cleared")
  equal(vm.entityFloat(machine, 1, 17), 0.0, "solid cleared")
  equal(vm.entityFloat(machine, 1, 27), -1.0, "nextthink reset")
  equal(vm.entityVector(machine, 1, 18).x, 0.0, "origin cleared")
  return true
end function

function testAngleHack()
  machine = makeMachine()
  edict.setKeyValue(machine, 1, "angle", "90")
  value = vm.entityVector(machine, 1, 2)
  equal(value.x, 0.0, "angle x")
  equal(value.y, 90.0, "angle yaw")
  equal(value.z, 0.0, "angle z")
  return true
end function

function testLightHack()
  machine = makeMachine()
  edict.setKeyValue(machine, 1, "light", "250")
  equal(vm.entityFloat(machine, 1, 5), 250.0, "light_lev alias")
  return true
end function

function testUnderscoreIgnored()
  machine = makeMachine()
  yes(edict.setKeyValue(machine, 1, "_comment", "ignored"), "underscore pair accepted")
  return true
end function

function testUnknownFieldDiagnostic()
  machine = makeMachine()
  edict.ED_ParseEdict(machine, 1, entity([pair("missing", "1")]))
  equal(machine.context.consoleLines[0], "'missing' is not a field", "unknown field diagnostic")
  return true
end function

function testUnknownGlobalDiagnostic()
  machine = makeMachine()
  edict.ED_ParseGlobals(machine, entity([pair("missing", "1")]))
  equal(machine.context.consoleLines[0], "'missing' is not a global", "unknown global diagnostic")
  return true
end function

function testFieldEpair()
  machine = makeMachine()
  vm.setWord(machine, 6, 0x1234)
  edict.setKeyValue(machine, 1, "targetfield", "health")
  equal(vm.entityField(machine, 1, 7), 0x1234, "field global word")
  return true
end function

function testFunctionEpair()
  machine = makeMachine()
  edict.setKeyValue(machine, 1, "think", "spawnfn")
  equal(vm.entityField(machine, 1, 8), 1, "function index")
  yes(try(edict.setKeyValue(machine, 1, "think", "missing")) is error, "missing function rejected")
  return true
end function

function testEntityEpair()
  machine = makeMachine()
  edict.setKeyValue(machine, 1, "enemy", "3")
  equal(vm.entityField(machine, 1, 9), 3, "entity number")
  return true
end function

function testNewString()
  high = protocolText.decodeBytes(bytes([0xe9]))
  text = edict.ED_NewString(high + "\\n" + "x\\t")
  equal(hex(protocolText.encodeBytes(text)), "e90a785c", "ED_NewString bytes and escapes")
  return true
end function

function testNegativeZeroFormat()
  negativeZero = native.bitsFloat(0x80000000)
  equal(native.floatBits(negativeZero), 0x80000000, "negative zero word")
  equal(native.floatBits(common.cAtof("-0.000000")), 0x80000000, "C atof negative zero word")
  equal(edict.fixedSixDecimalsWord(0x80000000), "-0.000000", "negative zero raw formatter")
  equal(edict.fixedSixDecimals(negativeZero), "-0.000000", "negative zero value formatter")
  equal(edict.fixedSixDecimals(1.25), "1.250000", "positive fixed format")
  equal(edict.fixedSixDecimals(4097.0), "4097.000000", "stock item spawn parm format")
  equal(edict.fixedSixDecimals(-4097.0), "-4097.000000", "negative large fixed format")
  equal(edict.fixedSixDecimals(16777215.0), "16777215.000000", "binary32 integer limit format")

  machine = makeMachine()
  edict.setGlobalByName(machine, "globalx", "-0.000000")
  equal(vm.word(machine, 40) & 0xffffffff, 0x80000000, "global epair negative zero")
  edict.setKeyValue(machine, 1, "health", "-0.000000")
  equal(vm.entityField(machine, 1, 6) & 0xffffffff, 0x80000000, "edict epair negative zero")
  parsedVector = bsp.parseVector("-0.000000 0.000000 -0.000000")
  equal(native.floatBits(parsedVector.x), 0x80000000, "vector x negative zero")
  equal(native.floatBits(parsedVector.y), 0x00000000, "vector y positive zero")
  equal(native.floatBits(parsedVector.z), 0x80000000, "vector z negative zero")
  return true
end function

function testWriteEdict()
  machine = makeMachine()
  vm.setEntityFloat(machine, 1, 6, 12.5)
  vm.setEntityVector(machine, 1, 2, t.Vec3(1.0, 2.0, 3.0))
  vm.setEntityField(machine, 1, 29, 1)
  high = protocolText.decodeBytes(bytes([0xe9]))
  vm.setEntityString(machine, 1, 10, high)
  floatText = try(edict.PR_UglyValueString(machine, c.EV_FLOAT, machine.edicts[1], 6))
  if floatText is error then return floatText end if
  equalText(floatText, "12.500000", "float value string")
  vectorText = try(edict.PR_UglyValueString(machine, c.EV_VECTOR, machine.edicts[1], 2))
  if vectorText is error then return vectorText end if
  equalText(vectorText, "1.000000 2.000000 3.000000", "vector value string")
  voidText = try(edict.PR_UglyValueString(machine, c.EV_VOID, machine.edicts[1], 29))
  if voidText is error then return voidText end if
  equalText(voidText, protocolText.decodeBytes(bytes([118, 111, 105, 100])), "void value string")
  pairText = try(edict.appendQuotedPair("{\n", "key", "value"))
  if pairText is error then return pairText end if
  equalText(pairText, "{\n\"key\" \"value\"\n", "quoted pair append")
  yes(try(edict.appendQuotedPair("", "key", void)) is error, "void value rejected before concatenation")

  cumulative = try(edict.appendQuotedPair("{\n", "first", "one"))
  if cumulative is error then return cumulative end if
  cumulative = try(edict.appendQuotedPair(cumulative, "second", "two"))
  if cumulative is error then return cumulative end if
  equalText(cumulative, "{\n\"first\" \"one\"\n\"second\" \"two\"\n", "quoted pair cumulative append")

  expected = "{\n"
  expected = expected + "\"angles\" \"1.000000 2.000000 3.000000\"\n"
  expected = expected + "\"health\" \"12.500000\"\n"
  expected = expected + "\"message\" \"" + high + "\"\n"
  expected = expected + "\"voidslot\" \"void\"\n"
  expected = expected + "}\n"

  actual = try(edict.ED_Write(machine, 1))
  if actual is error then return actual end if
  if typeof(actual) != "string" then return error(10202, "ED_Write returned " + typeof(actual)) end if
  equalText(actual, expected, "ED_Write exact text")
  equal(hex(protocolText.encodeBytes(actual)), "7b0a22616e676c6573222022312e30303030303020322e30303030303020332e303030303030220a226865616c746822202231322e353030303030220a226d657373616765222022e9220a22766f6964736c6f74222022766f6964220a7d0a", "ED_Write exact Quake bytes")

  saved = try(savegame.writeEdict(machine, 1))
  if saved is error then return saved end if
  if typeof(saved) != "string" then return error(10203, "savegame ED_Write returned " + typeof(saved)) end if
  equalText(saved, expected, "savegame ED_Write exact text")
  equal(hex(protocolText.encodeBytes(saved)), "7b0a22616e676c6573222022312e30303030303020322e30303030303020332e303030303030220a226865616c746822202231322e353030303030220a226d657373616765222022e9220a22766f6964736c6f74222022766f6964220a7d0a", "savegame ED_Write exact Quake bytes")
  return true
end function

function testWriteGlobals()
  machine = makeMachine()
  vm.setGlobalFloat(machine, 40, 2.5)
  vm.setGlobalString(machine, 41, "hello")
  vm.setWord(machine, 42, 3)
  vm.setVector(machine, 43, t.Vec3(1.0, 2.0, 3.0))
  expected = "{\n"
  expected = expected + "\"globalx\" \"2.500000\"\n"
  expected = expected + "\"globalstr\" \"hello\"\n"
  expected = expected + "\"globalent\" \"3\"\n"
  expected = expected + "}\n"
  actual = try(edict.ED_WriteGlobals(machine))
  if actual is error then return actual end if
  if typeof(actual) != "string" then return error(10204, "ED_WriteGlobals returned " + typeof(actual)) end if
  equalText(actual, expected, "ED_WriteGlobals exact text")
  saved = try(savegame.writeGlobals(machine))
  if saved is error then return saved end if
  if typeof(saved) != "string" then return error(10205, "savegame globals returned " + typeof(saved)) end if
  equalText(saved, expected, "savegame globals exact text")

  zeroMachine = makeMachine()
  zeroExpected = "{\n"
  zeroExpected = zeroExpected + "\"globalx\" \"0.000000\"\n"
  zeroExpected = zeroExpected + "\"globalstr\" \"\"\n"
  zeroExpected = zeroExpected + "\"globalent\" \"0\"\n"
  zeroExpected = zeroExpected + "}\n"
  zeroGlobals = try(edict.ED_WriteGlobals(zeroMachine))
  if zeroGlobals is error then return zeroGlobals end if
  equalText(zeroGlobals, zeroExpected, "ED_WriteGlobals preserves zero saveglobals")
  zeroSaved = try(savegame.writeGlobals(zeroMachine))
  if zeroSaved is error then return zeroSaved end if
  equalText(zeroSaved, zeroExpected, "savegame preserves zero saveglobals")
  return true
end function

function testEmptyEntity()
  machine = makeMachine()
  edict.ED_ParseEdict(machine, 1, entity([]))
  yes(machine.edictFree[1], "empty entity marked free")
  return true
end function

function testBadEdictCommand()
  machine = makeMachine()
  equal(edict.ED_PrintEdict_f(machine, 2), "Bad edict number\n", "command bounds")
  return true
end function

function testNumForEdict()
  machine = makeMachine()
  equal(edict.NUM_FOR_EDICT(machine, 1), 1, "valid high-water edict")
  yes(try(edict.NUM_FOR_EDICT(machine, 2)) is error, "edict above high-water rejected")
  return true
end function

function testBspEntityBytes()
  raw = bytes([123,34,109,101,115,115,97,103,101,34,32,34,0xe9,34,125])
  entities = bsp.parseEntities(protocolText.decodeBytes(raw))
  equal(len(entities), 1, "entity count")
  equal(hex(protocolText.encodeBytes(bsp.entityValue(entities[0], "message"))), "e9", "entity byte value")
  return true
end function

function testGlobalRoundtrip()
  machine = makeMachine()
  edict.ED_ParseGlobals(machine, entity([pair("globalx", "3.5"), pair("globalent", "2")]))
  equal(vm.globalFloat(machine, 40), 3.5, "global float parsed")
  equal(vm.word(machine, 42), 2, "global entity parsed")
  return true
end function

function testPrintFree()
  machine = makeMachine()
  machine.edictFree[1] = true
  equal(edict.ED_Print(machine, 1), "FREE\n", "free edict print")
  return true
end function

function main(args)
  print "MiniQuake BP-022 QuakeC edict tests"
  passed = 0
  if run(1, "type sizes", testTypeSizes) then passed = passed + 1 end if
  if run(2, "allocation high-water mark", testAllocateAppend) then passed = passed + 1 end if
  if run(3, "reuse delay", testReuseDelay) then passed = passed + 1 end if
  if run(4, "early free reuse", testEarlyFreeReuse) then passed = passed + 1 end if
  if run(5, "ED_Free field reset", testFreeClearsFields) then passed = passed + 1 end if
  if run(6, "angle compatibility key", testAngleHack) then passed = passed + 1 end if
  if run(7, "light compatibility key", testLightHack) then passed = passed + 1 end if
  if run(8, "underscore keys", testUnderscoreIgnored) then passed = passed + 1 end if
  if run(9, "unknown field diagnostic", testUnknownFieldDiagnostic) then passed = passed + 1 end if
  if run(10, "unknown global diagnostic", testUnknownGlobalDiagnostic) then passed = passed + 1 end if
  if run(11, "field epair", testFieldEpair) then passed = passed + 1 end if
  if run(12, "function epair", testFunctionEpair) then passed = passed + 1 end if
  if run(13, "entity epair", testEntityEpair) then passed = passed + 1 end if
  if run(14, "ED_NewString", testNewString) then passed = passed + 1 end if
  if run(15, "fixed float formatting", testNegativeZeroFormat) then passed = passed + 1 end if
  if run(16, "ED_Write", testWriteEdict) then passed = passed + 1 end if
  if run(17, "ED_WriteGlobals", testWriteGlobals) then passed = passed + 1 end if
  if run(18, "empty entity", testEmptyEntity) then passed = passed + 1 end if
  if run(19, "edict command bounds", testBadEdictCommand) then passed = passed + 1 end if
  if run(20, "NUM_FOR_EDICT", testNumForEdict) then passed = passed + 1 end if
  if run(21, "BSP entity byte text", testBspEntityBytes) then passed = passed + 1 end if
  if run(22, "global parse and free print", testGlobalRoundtrip) then testPrintFree(); passed = passed + 1 end if
  if passed != 22 then
    print "MiniQuake BP-022 QuakeC edict tests failed: " + passed + "/22"
    return 1
  end if
  print "MiniQuake BP-022 QuakeC edict tests passed: 22"
  return 0
end function
