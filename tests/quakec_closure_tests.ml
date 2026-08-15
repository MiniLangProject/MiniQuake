/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-024 asset-free closure fixtures for the frozen QuakeC 1.09 contract.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.quakec.vm as vm
import miniquake.quakec.builtins as builtins
import miniquake.quakec.contract as contract

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(10040, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if value != true then return error(10041, name + ": expected true") end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "  [" + number + "/20] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Create and initialize definitions.
function makeDefinitions(names, typeValue)
  result = []
  offset = 0
  for each name in names
    result = result + [t.QuakeCDef(typeValue, offset, 0, name)]
    offset = offset + 1
  end for
  return result
end function

// Create and initialize functions.
function makeFunctions(skipName, builtinIndex)
  result = [t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])]
  statement = 0
  for each name in contract.requiredFunctions()
    if name != skipName then
      result = result + [t.QuakeCFunction(statement, 0, 0, 0, name, "stock.qc", 0, [])]
      statement = statement + 1
    end if
  end for
  if builtinIndex > 0 then
    result = result + [t.QuakeCFunction(-builtinIndex, 0, 0, 0, "builtin_" + builtinIndex, "builtins.qc", 0, [])]
  end if
  return result
end function

// Create and initialize program.
function makeProgram(skipGlobal, skipField, skipFunction, builtinIndex)
  globalNames = []
  for each name in contract.requiredGlobals()
    if name != skipGlobal then globalNames = globalNames + [name] end if
  end for
  fieldNames = []
  for each name in contract.requiredFields()
    if name != skipField then fieldNames = fieldNames + [name] end if
  end for
  functions = makeFunctions(skipFunction, builtinIndex)
  statements = []
  index = 0
  while index < len(functions)
    statements = statements + [t.QuakeCStatement(0, 0, 0, 0)]
    index = index + 1
  end while
  return t.QuakeCProgram(
    "bp024-contract.dat",
    bytes(),
    c.PROG_VERSION,
    c.PROGHEADER_CRC,
    statements,
    makeDefinitions(globalNames, c.EV_FLOAT),
    makeDefinitions(fieldNames, c.EV_FLOAT),
    functions,
    bytes([0]),
    vm.zeroArray(256),
    128,
  )
end function

// Report whether program.
function validProgram()
  return makeProgram("", "", "", 78)
end function

// Verify status against the expected Quake behavior.
function testStatus()
  equal(contract.STATUS, "quakec_109_frozen_v1", "status")
  return true
end function

// Verify constants against the expected Quake behavior.
function testConstants()
  equal(contract.EXPECTED_VERSION, 6, "version")
  equal(contract.EXPECTED_HEADER_CRC, 5927, "header CRC")
  equal(contract.EXPECTED_OPCODE_COUNT, 66, "opcodes")
  equal(contract.EXPECTED_BUILTIN_COUNT, 79, "builtins")
  equal(contract.EXPECTED_STACK_DEPTH, 32, "stack")
  equal(contract.EXPECTED_LOCALSTACK_SIZE, 2048, "locals")
  return true
end function

// Verify builtin table against the expected Quake behavior.
function testBuiltinTable()
  equal(len(builtins.builtinNames()), 79, "name count")
  equal(len(builtins.fixmeSlots()), 14, "fixme count")
  equal(builtins.builtinContractFingerprint(), 0xb86a0245, "builtin fingerprint")
  return true
end function

// Verify contract fingerprint against the expected Quake behavior.
function testContractFingerprint()
  equal(contract.contractFingerprint(), 0xbc89cbf1, "contract fingerprint")
  return true
end function

// Verify valid program against the expected Quake behavior.
function testValidProgram()
  yes(contract.validate(validProgram()), "valid synthetic stock program")
  return true
end function

// Verify bad version against the expected Quake behavior.
function testBadVersion()
  program = validProgram()
  program.version = 5
  yes(try(contract.validate(program)) is error, "version rejected")
  return true
end function

// Verify bad crc against the expected Quake behavior.
function testBadCrc()
  program = validProgram()
  program.crc = 1
  yes(try(contract.validate(program)) is error, "CRC rejected")
  return true
end function

// Verify bad entity fields against the expected Quake behavior.
function testBadEntityFields()
  program = validProgram()
  program.entityFields = 0
  yes(try(contract.validate(program)) is error, "zero entity fields rejected")
  return true
end function

// Verify highest stock builtin against the expected Quake behavior.
function testHighestStockBuiltin()
  program = makeProgram("", "", "", 78)
  yes(contract.validate(program), "builtin 78 accepted")
  equal(contract.maximumBuiltinReference(program), 78, "maximum builtin")
  return true
end function

// Verify out of range builtin against the expected Quake behavior.
function testOutOfRangeBuiltin()
  program = makeProgram("", "", "", 79)
  yes(try(contract.validate(program)) is error, "builtin 79 rejected")
  return true
end function

// Verify missing global against the expected Quake behavior.
function testMissingGlobal()
  yes(try(contract.validate(makeProgram("self", "", "", 78))) is error, "missing self rejected")
  return true
end function

// Verify missing field against the expected Quake behavior.
function testMissingField()
  yes(try(contract.validate(makeProgram("", "classname", "", 78))) is error, "missing classname rejected")
  return true
end function

// Verify missing function against the expected Quake behavior.
function testMissingFunction()
  yes(try(contract.validate(makeProgram("", "", "worldspawn", 78))) is error, "missing worldspawn rejected")
  return true
end function

// Verify builtin reference count against the expected Quake behavior.
function testBuiltinReferenceCount()
  program = validProgram()
  equal(contract.builtinReferenceCount(program), 1, "builtin reference count")
  return true
end function

// Verify no builtin references against the expected Quake behavior.
function testNoBuiltinReferences()
  program = makeProgram("", "", "", 0)
  equal(contract.builtinReferenceCount(program), 0, "no builtin references")
  equal(contract.maximumBuiltinReference(program), 0, "no maximum builtin")
  return true
end function

// Verify program fingerprint stable against the expected Quake behavior.
function testProgramFingerprintStable()
  program = validProgram()
  equal(contract.programFingerprint(program), contract.programFingerprint(program), "stable fingerprint")
  return true
end function

// Verify program fingerprint mutation against the expected Quake behavior.
function testProgramFingerprintMutation()
  first = validProgram()
  second = validProgram()
  second.entityFields = second.entityFields + 1
  yes(contract.programFingerprint(first) != contract.programFingerprint(second), "entity field mutation changes fingerprint")
  return true
end function

// Verify summary against the expected Quake behavior.
function testSummary()
  program = validProgram()
  summary = contract.summary(program)
  equal(len(summary), 11, "summary width")
  equal(summary[0], contract.STATUS, "summary status")
  equal(summary[1], contract.contractFingerprint(), "summary contract")
  equal(summary[9], 1, "summary builtin count")
  equal(summary[10], 78, "summary builtin maximum")
  return true
end function

// Verify required definition sets against the expected Quake behavior.
function testRequiredDefinitionSets()
  yes(len(contract.requiredGlobals()) >= 50, "generated globals covered")
  yes(len(contract.requiredFields()) >= 70, "generated fields covered")
  equal(len(contract.requiredFunctions()), 11, "entry functions")
  return true
end function

// Verify vm limits bound against the expected Quake behavior.
function testVmLimitsBound()
  equal(vm.MAX_STACK_DEPTH, contract.EXPECTED_STACK_DEPTH, "VM stack bound")
  equal(vm.LOCALSTACK_SIZE, contract.EXPECTED_LOCALSTACK_SIZE, "VM local bound")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-024 QuakeC closure tests"
  passed = 0
  if run(1, "status", testStatus) then passed = passed + 1 end if
  if run(2, "constants", testConstants) then passed = passed + 1 end if
  if run(3, "builtin table", testBuiltinTable) then passed = passed + 1 end if
  if run(4, "contract fingerprint", testContractFingerprint) then passed = passed + 1 end if
  if run(5, "valid program", testValidProgram) then passed = passed + 1 end if
  if run(6, "bad version", testBadVersion) then passed = passed + 1 end if
  if run(7, "bad CRC", testBadCrc) then passed = passed + 1 end if
  if run(8, "bad entity fields", testBadEntityFields) then passed = passed + 1 end if
  if run(9, "highest stock builtin", testHighestStockBuiltin) then passed = passed + 1 end if
  if run(10, "out-of-range builtin", testOutOfRangeBuiltin) then passed = passed + 1 end if
  if run(11, "missing global", testMissingGlobal) then passed = passed + 1 end if
  if run(12, "missing field", testMissingField) then passed = passed + 1 end if
  if run(13, "missing function", testMissingFunction) then passed = passed + 1 end if
  if run(14, "builtin reference count", testBuiltinReferenceCount) then passed = passed + 1 end if
  if run(15, "no builtin references", testNoBuiltinReferences) then passed = passed + 1 end if
  if run(16, "program fingerprint stable", testProgramFingerprintStable) then passed = passed + 1 end if
  if run(17, "program fingerprint mutation", testProgramFingerprintMutation) then passed = passed + 1 end if
  if run(18, "summary", testSummary) then passed = passed + 1 end if
  if run(19, "required definitions", testRequiredDefinitionSets) then passed = passed + 1 end if
  if run(20, "VM limits", testVmLimitsBound) then passed = passed + 1 end if
  if passed != 20 then return 1 end if
  print "MiniQuake BP-024 QuakeC closure tests passed: 20"
  return 0
end function
