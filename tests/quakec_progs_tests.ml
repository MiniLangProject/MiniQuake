/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-020 validates the on-disk dprograms_t ABI, source-guided semantic checks,
Quake byte strings and the full-file runtime CRC used by SV_SendServerinfo.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.crc as crc16
import miniquake.protocol_text as protocolText
import miniquake.format.progs as progs
import miniquake.quakec.edict as edict

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(10000, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if value != true then return error(10001, name + ": expected true") end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "  [" + number + "/18] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Encode and write def.
function putDef(data, offset, typeValue, wordOffset, nameOffset)
  bio.putU16(data, offset, typeValue)
  bio.putU16(data, offset + 2, wordOffset)
  bio.putI32(data, offset + 4, nameOffset)
end function

// Encode and write function.
function putFunction(data, offset, firstStatement, parmStart, locals, nameOffset, fileOffset, numParms)
  bio.putI32(data, offset, firstStatement)
  bio.putI32(data, offset + 4, parmStart)
  bio.putI32(data, offset + 8, locals)
  bio.putI32(data, offset + 12, 0)
  bio.putI32(data, offset + 16, nameOffset)
  bio.putI32(data, offset + 20, fileOffset)
  bio.putI32(data, offset + 24, numParms)
  index = 0
  while index < c.QC_MAX_PARMS
    bio.putU8(data, offset + 28 + index, 0)
    index = index + 1
  end while
end function

// Build deterministic test data for the requested value.
function fixture()
  statementOffset = 60
  globalDefOffset = 68
  fieldDefOffset = 84
  functionOffset = 100
  stringOffset = 172
  strings = bytes([
    0,
    116, 105, 109, 101, 0,
    104, 101, 97, 108, 116, 104, 0,
    109, 97, 105, 110, 0,
    102, 105, 120, 116, 117, 114, 101, 46, 113, 99, 0,
  ])
  globalsOffset = stringOffset + len(strings)
  globalsCount = 32
  data = bytes(globalsOffset + globalsCount * 4, 0)
  bio.putI32(data, 0, c.PROG_VERSION)
  bio.putI32(data, 4, c.PROGHEADER_CRC)
  bio.putI32(data, 8, statementOffset)
  bio.putI32(data, 12, 1)
  bio.putI32(data, 16, globalDefOffset)
  bio.putI32(data, 20, 2)
  bio.putI32(data, 24, fieldDefOffset)
  bio.putI32(data, 28, 2)
  bio.putI32(data, 32, functionOffset)
  bio.putI32(data, 36, 2)
  bio.putI32(data, 40, stringOffset)
  bio.putI32(data, 44, len(strings))
  bio.putI32(data, 48, globalsOffset)
  bio.putI32(data, 52, globalsCount)
  bio.putI32(data, 56, 4)
  bio.putU16(data, statementOffset, 0)
  putDef(data, globalDefOffset, c.EV_VOID, 0, 0)
  putDef(data, globalDefOffset + 8, c.EV_FLOAT, 28, 1)
  putDef(data, fieldDefOffset, c.EV_VOID, 0, 0)
  putDef(data, fieldDefOffset + 8, c.EV_FLOAT, 1, 6)
  putFunction(data, functionOffset, 0, 0, 0, 0, 0, 0)
  putFunction(data, functionOffset + 36, 0, 28, 1, 13, 18, 0)
  bio.copyInto(data, stringOffset, strings, 0, len(strings))
  return data
end function

// Exercise parsed fixture as part of this deterministic regression fixture.
function parsedFixture()
  return progs.parse(fixture(), "fixture-progs.dat")
end function

// Verify header and sections against the expected Quake behavior.
function testHeaderAndSections()
  program = parsedFixture()
  equal(program.version, c.PROG_VERSION, "version")
  equal(program.crc, c.PROGHEADER_CRC, "header CRC")
  equal(len(program.statements), 1, "statement count")
  equal(len(program.globalDefs), 2, "global definition count")
  equal(len(program.fieldDefs), 2, "field definition count")
  equal(len(program.functions), 2, "function count")
  equal(len(program.globals), 32, "global word count")
  equal(program.entityFields, 4, "entity field words")
  return true
end function

// Verify names against the expected Quake behavior.
function testNames()
  program = parsedFixture()
  equal(program.globalDefs[1].name, "time", "global name")
  equal(program.fieldDefs[1].name, "health", "field name")
  equal(program.functions[1].name, "main", "function name")
  equal(program.functions[1].file, "fixture.qc", "source filename")
  return true
end function

// Verify runtime crc against the expected Quake behavior.
function testRuntimeCrc()
  data = fixture()
  program = progs.parse(data, "fixture-progs.dat")
  equal(progs.runtimeCrc(program), crc16.CRC_Block(data, 0, len(data)), "full-file runtime CRC")
  yes(progs.runtimeCrc(program) != program.crc, "runtime CRC differs from header ABI CRC")
  return true
end function

// Verify synthetic crc fallback against the expected Quake behavior.
function testSyntheticCrcFallback()
  program = t.QuakeCProgram("synthetic", bytes(), c.PROG_VERSION, 1234, [], [], [], [], bytes([0]), [], 1)
  equal(progs.runtimeCrc(program), 1234, "synthetic CRC fallback")
  return true
end function

// Verify quake byte strings against the expected Quake behavior.
function testQuakeByteStrings()
  text = progs.stringAt(bytes([0xe9, 0]), 0)
  equal(hex(protocolText.encodeBytes(text)), "e9", "Latin-1 byte string")
  return true
end function

// Verify load progs header crc against the expected Quake behavior.
function testLoadProgsHeaderCrc()
  loaded = edict.PR_LoadProgs(fixture(), "fixture-progs.dat")
  equal(loaded.crc, c.PROGHEADER_CRC, "PR_LoadProgs accepts stock header CRC")
  data = fixture()
  bio.putI32(data, 4, 1)
  yes(try(edict.PR_LoadProgs(data, "bad-progs.dat")) is error, "PR_LoadProgs rejects altered ABI CRC")
  return true
end function

// Verify bad version against the expected Quake behavior.
function testBadVersion()
  data = fixture()
  bio.putI32(data, 0, 5)
  yes(try(progs.parse(data, "bad-version.dat")) is error, "bad version rejected")
  return true
end function

// Verify truncated section against the expected Quake behavior.
function testTruncatedSection()
  data = fixture()
  bio.putI32(data, 8, len(data) - 4)
  yes(try(progs.parse(data, "bad-section.dat")) is error, "truncated statement section rejected")
  return true
end function

// Verify string table nul against the expected Quake behavior.
function testStringTableNul()
  data = fixture()
  stringOffset = bio.i32(data, 40)
  data[stringOffset] = 1
  yes(try(progs.parse(data, "bad-strings.dat")) is error, "missing initial NUL rejected")
  return true
end function

// Verify opcode range against the expected Quake behavior.
function testOpcodeRange()
  data = fixture()
  bio.putU16(data, bio.i32(data, 8), 66)
  program = progs.parse(data, "bad-opcode.dat")
  yes(try(progs.validateProgram(program)) is error, "invalid opcode rejected by strict audit")
  return true
end function

// Verify global type against the expected Quake behavior.
function testGlobalType()
  data = fixture()
  bio.putU16(data, bio.i32(data, 16) + 8, 12)
  program = progs.parse(data, "bad-global-type.dat")
  yes(try(progs.validateProgram(program)) is error, "invalid global type rejected by strict audit")
  return true
end function

// Verify global offset against the expected Quake behavior.
function testGlobalOffset()
  data = fixture()
  bio.putU16(data, bio.i32(data, 16) + 10, 32)
  program = progs.parse(data, "bad-global-offset.dat")
  yes(try(progs.validateProgram(program)) is error, "global range rejected by strict audit")
  return true
end function

// Verify field save global against the expected Quake behavior.
function testFieldSaveGlobal()
  data = fixture()
  bio.putU16(data, bio.i32(data, 24) + 8, c.EV_FLOAT | c.DEF_SAVEGLOBAL)
  yes(try(progs.parse(data, "bad-field-save.dat")) is error, "field DEF_SAVEGLOBAL rejected")
  return true
end function

// Verify field offset against the expected Quake behavior.
function testFieldOffset()
  data = fixture()
  bio.putU16(data, bio.i32(data, 24) + 10, 4)
  program = progs.parse(data, "bad-field-offset.dat")
  yes(try(progs.validateProgram(program)) is error, "field range rejected by strict audit")
  return true
end function

// Verify parameter count against the expected Quake behavior.
function testParameterCount()
  data = fixture()
  functionOffset = bio.i32(data, 32) + 36
  bio.putI32(data, functionOffset + 24, 9)
  program = progs.parse(data, "bad-parm-count.dat")
  yes(try(progs.validateProgram(program)) is error, "parameter count rejected by strict audit")
  return true
end function

// Verify parameter size against the expected Quake behavior.
function testParameterSize()
  data = fixture()
  functionOffset = bio.i32(data, 32) + 36
  bio.putI32(data, functionOffset + 24, 1)
  bio.putU8(data, functionOffset + 28, 2)
  program = progs.parse(data, "bad-parm-size.dat")
  yes(try(progs.validateProgram(program)) is error, "parameter size rejected by strict audit")
  return true
end function

// Verify parameter storage against the expected Quake behavior.
function testParameterStorage()
  // qcc may emit a bytecode function whose declared parameters are copied to
  // parmStart while locals remains zero.  SUB_AttackFinished in stock
  // progs.dat is a real example and must pass both loading and strict audit.
  data = fixture()
  functionOffset = bio.i32(data, 32) + 36
  bio.putI32(data, functionOffset + 8, 0)
  bio.putI32(data, functionOffset + 24, 1)
  bio.putU8(data, functionOffset + 28, 3)
  program = progs.parse(data, "bytecode-zero-locals.dat")
  equal(program.functions[1].locals, 0, "bytecode zero locals")
  equal(progs.validateProgram(program), true, "bytecode parameter storage accepted")

  // The audit still rejects a parameter destination that leaves the globals
  // array, which is the actual memory-safety boundary used by PR_EnterFunction.
  outside = fixture()
  outsideOffset = bio.i32(outside, 32) + 36
  globalsCount = bio.i32(outside, 52)
  bio.putI32(outside, outsideOffset + 4, globalsCount - 1)
  bio.putI32(outside, outsideOffset + 8, 0)
  bio.putI32(outside, outsideOffset + 24, 1)
  bio.putU8(outside, outsideOffset + 28, 3)
  outsideProgram = progs.parse(outside, "parameter-storage-outside-globals.dat")
  yes(try(progs.validateProgram(outsideProgram)) is error, "parameter storage outside globals rejected")

  // Builtin declarations likewise retain signatures without local storage.
  builtinData = fixture()
  builtinOffset = bio.i32(builtinData, 32) + 36
  bio.putI32(builtinData, builtinOffset, -1)
  bio.putI32(builtinData, builtinOffset + 8, 0)
  bio.putI32(builtinData, builtinOffset + 24, 1)
  bio.putU8(builtinData, builtinOffset + 28, 3)
  builtinProgram = progs.parse(builtinData, "builtin-zero-locals.dat")
  equal(builtinProgram.functions[1].firstStatement, -1, "builtin statement")
  equal(builtinProgram.functions[1].locals, 0, "builtin zero locals")
  equal(progs.validateProgram(builtinProgram), true, "builtin signature accepted")

  // Stock qcc emits zero parm_size entries for builtins such as
  // makevectors. Builtins consume OFS_PARM words directly and never enter
  // PR_EnterFunction, so these zero entries are valid original data.
  stockBuiltinData = fixture()
  stockBuiltinOffset = bio.i32(stockBuiltinData, 32) + 36
  bio.putI32(stockBuiltinData, stockBuiltinOffset, -1)
  bio.putI32(stockBuiltinData, stockBuiltinOffset + 8, 0)
  bio.putI32(stockBuiltinData, stockBuiltinOffset + 24, 1)
  stockBuiltinProgram = progs.parse(stockBuiltinData, "stock-builtin-zero-parm-size.dat")
  equal(stockBuiltinProgram.functions[1].parmSize[0], 0, "stock builtin zero parameter size")
  equal(progs.validateProgram(stockBuiltinProgram), true, "stock builtin zero parameter size accepted")

  extensionStubData = fixture()
  extensionStubOffset = bio.i32(extensionStubData, 32) + 36
  bio.putI32(extensionStubData, extensionStubOffset, 0)
  bio.putI32(extensionStubData, extensionStubOffset + 4, 0)
  bio.putI32(extensionStubData, extensionStubOffset + 8, 0)
  bio.putI32(extensionStubData, extensionStubOffset + 24, 1)
  extensionStubProgram = progs.parse(extensionStubData, "extension-stub-zero-parm-size.dat")
  equal(extensionStubProgram.functions[1].parmSize[0], 0, "extension stub zero parameter size")
  equal(progs.validateProgram(extensionStubProgram), true, "extension stub zero parameter size accepted")
  return true
end function

// Verify function statement against the expected Quake behavior.
function testFunctionStatement()
  data = fixture()
  functionOffset = bio.i32(data, 32) + 36
  bio.putI32(data, functionOffset, 1)
  program = progs.parse(data, "bad-function-statement.dat")
  yes(try(progs.validateProgram(program)) is error, "first statement range rejected by strict audit")
  return true
end function

// Verify void word size against the expected Quake behavior.
function testVoidWordSize()
  equal(progs.typeSize(c.EV_VOID), 1, "EV_VOID storage size")
  equal(progs.typeSize(c.EV_VECTOR), 3, "EV_VECTOR storage size")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-020 QuakeC progs.dat tests"
  passed = 0
  if run(1, "dprograms header and sections", testHeaderAndSections) then passed = passed + 1 end if
  if run(2, "definition and function names", testNames) then passed = passed + 1 end if
  if run(3, "full-file runtime CRC", testRuntimeCrc) then passed = passed + 1 end if
  if run(4, "synthetic CRC fallback", testSyntheticCrcFallback) then passed = passed + 1 end if
  if run(5, "Quake byte strings", testQuakeByteStrings) then passed = passed + 1 end if
  if run(6, "PR_LoadProgs ABI CRC", testLoadProgsHeaderCrc) then passed = passed + 1 end if
  if run(7, "version validation", testBadVersion) then passed = passed + 1 end if
  if run(8, "section bounds", testTruncatedSection) then passed = passed + 1 end if
  if run(9, "string table NUL", testStringTableNul) then passed = passed + 1 end if
  if run(10, "opcode range", testOpcodeRange) then passed = passed + 1 end if
  if run(11, "global type", testGlobalType) then passed = passed + 1 end if
  if run(12, "global storage range", testGlobalOffset) then passed = passed + 1 end if
  if run(13, "field save-global rejection", testFieldSaveGlobal) then passed = passed + 1 end if
  if run(14, "field storage range", testFieldOffset) then passed = passed + 1 end if
  if run(15, "parameter count", testParameterCount) then passed = passed + 1 end if
  if run(16, "parameter size", testParameterSize) then passed = passed + 1 end if
  if run(17, "qcc parameter storage", testParameterStorage) then passed = passed + 1 end if
  if run(18, "function statement and type sizes", testFunctionStatement) then testVoidWordSize(); passed = passed + 1 end if
  if passed != 18 then
    print "MiniQuake BP-020 QuakeC progs.dat tests failed: " + passed + "/18"
    return 1
  end if
  print "MiniQuake BP-020 QuakeC progs.dat tests passed: 18"
  return 0
end function
