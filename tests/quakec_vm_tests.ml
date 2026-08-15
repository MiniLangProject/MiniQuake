/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-021 source-guided QuakeC VM parity fixtures for pr_exec.c.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.protocol_text as protocolText
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9920, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if value != true then return error(9921, name + ": expected true") end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "  [" + number + "/16] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Exercise dummy function as part of this deterministic regression fixture.
function dummyFunction()
  return t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
end function

// Create and initialize machine.
function makeMachine(statements, functions, globalDefs, fieldDefs, entityFields)
  program = t.QuakeCProgram(
    "bp021-vm.dat",
    bytes(),
    c.PROG_VERSION,
    c.PROGHEADER_CRC,
    statements,
    globalDefs,
    fieldDefs,
    functions,
    bytes([0, 0xe9, 0]),
    vm.zeroArray(128),
    entityFields,
  )
  return vm.create(program, 4)
end function

// Exercise simple machine as part of this deterministic regression fixture.
function simpleMachine(statements)
  fn = t.QuakeCFunction(0, 40, 0, 0, "fixture", "bp021.qc", 0, [])
  return makeMachine(statements, [dummyFunction(), fn], [], [], 8)
end function

// Verify trace reset against the expected Quake behavior.
function testTraceReset()
  machine = simpleMachine([t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  machine.trace = true
  vm.PR_ExecuteProgram(machine, 1)
  equal(machine.trace, false, "trace reset")
  return true
end function

// Exercise unexpected builtin zero as part of this deterministic regression fixture.
function unexpectedBuiltinZero(machine)
  return error(9922, "builtin slot zero was invoked")
end function

// Exercise enable trace as part of this deterministic regression fixture.
function enableTrace(machine)
  machine.trace = true
  return true
end function

// Verify trace on current invocation only against the expected Quake behavior.
function testTraceOnCurrentInvocationOnly()
  functions = [
    dummyFunction(),
    t.QuakeCFunction(0, 40, 0, 0, "trace_call", "bp021.qc", 0, []),
    t.QuakeCFunction(-1, 40, 0, 0, "traceon", "bp021.qc", 0, []),
    t.QuakeCFunction(2, 40, 0, 0, "plain", "bp021.qc", 0, []),
  ]
  statements = [
    t.QuakeCStatement(op.OP_CALL0, 50, 0, 0),
    t.QuakeCStatement(op.OP_DONE, 0, 0, 0),
    t.QuakeCStatement(op.OP_DONE, 0, 0, 0),
  ]
  machine = makeMachine(statements, functions, [], [], 8)
  // firstStatement=-1 denotes builtin slot 1.  Slot zero is the historical
  // PF_Fixme entry and must remain present in every Quake builtin table.
  machine.builtins = [unexpectedBuiltinZero, enableTrace]
  vm.setWord(machine, 50, 2)
  vm.PR_ExecuteProgram(machine, 1)
  equal(machine.trace, true, "traceon survives current invocation")
  vm.PR_ExecuteProgram(machine, 3)
  equal(machine.trace, false, "next invocation resets trace")
  return true
end function

// Exercise state machine as part of this deterministic regression fixture.
function stateMachine(frameWord)
  globals = [
    t.QuakeCDef(c.EV_ENTITY, 40, 0, "self"),
    t.QuakeCDef(c.EV_FLOAT, 41, 0, "time"),
  ]
  fields = [
    t.QuakeCDef(c.EV_FLOAT, 0, 0, "nextthink"),
    t.QuakeCDef(c.EV_FLOAT, 1, 0, "frame"),
    t.QuakeCDef(c.EV_FUNCTION, 2, 0, "think"),
  ]
  statements = [
    t.QuakeCStatement(op.OP_STATE, 50, 51, 0),
    t.QuakeCStatement(op.OP_DONE, 0, 0, 0),
  ]
  fn = t.QuakeCFunction(0, 60, 0, 0, "state", "bp021.qc", 0, [])
  machine = makeMachine(statements, [dummyFunction(), fn], globals, fields, 8)
  vm.setWord(machine, 40, 1)
  vm.setGlobalFloat(machine, 41, 10.0)
  vm.setWord(machine, 50, frameWord)
  vm.setWord(machine, 51, 7)
  return machine
end function

// Verify state signed zero preserved against the expected Quake behavior.
function testStateSignedZeroPreserved()
  machine = stateMachine(0)
  vm.setEntityField(machine, 1, 1, 0x80000000)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.entityField(machine, 1, 1), 0x80000000, "negative zero frame word")
  return true
end function

// Verify state changed frame stored against the expected Quake behavior.
function testStateChangedFrameStored()
  machine = stateMachine(native.floatBits(3.5))
  vm.setEntityFloat(machine, 1, 1, 2.0)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.entityField(machine, 1, 1), native.floatBits(3.5), "changed frame")
  equal(vm.entityField(machine, 1, 2), 7, "think function")
  return true
end function

// Verify state nan stored against the expected Quake behavior.
function testStateNanStored()
  machine = stateMachine(0x7fc00001)
  vm.setEntityField(machine, 1, 1, 0x7fc00002)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.entityField(machine, 1, 1), 0x7fc00001, "NaN frame payload")
  return true
end function

// Verify state next think float against the expected Quake behavior.
function testStateNextThinkFloat()
  machine = stateMachine(0)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.entityField(machine, 1, 0), native.floatBits(10.1), "nextthink binary32")
  return true
end function

// Exercise expect program error as part of this deterministic regression fixture.
function expectProgramError(machine, name)
  result = try(vm.PR_ExecuteProgram(machine, 1))
  yes(result is error, name + " returns error")
  yes(result.message != "", name + " message")
  equal(len(machine.callStack), 0, name + " stack reset")
  equal(machine.currentFunction, 0, name + " function reset")
  return true
end function

// Verify invalid load uses run error against the expected Quake behavior.
function testInvalidLoadUsesRunError()
  machine = simpleMachine([t.QuakeCStatement(op.OP_LOAD_F, 50, 51, 52)])
  vm.setWord(machine, 50, 9)
  vm.setWord(machine, 51, 0)
  return expectProgramError(machine, "invalid LOAD")
end function

// Verify invalid vector load uses run error against the expected Quake behavior.
function testInvalidVectorLoadUsesRunError()
  machine = simpleMachine([t.QuakeCStatement(op.OP_LOAD_V, 50, 51, 52)])
  vm.setWord(machine, 50, 1)
  vm.setWord(machine, 51, 7)
  return expectProgramError(machine, "cross-boundary LOAD_V")
end function

// Verify invalid address entity uses run error against the expected Quake behavior.
function testInvalidAddressEntityUsesRunError()
  machine = simpleMachine([t.QuakeCStatement(op.OP_ADDRESS, 50, 51, 52)])
  vm.setWord(machine, 50, 8)
  vm.setWord(machine, 51, 0)
  return expectProgramError(machine, "invalid ADDRESS entity")
end function

// Verify invalid address field uses run error against the expected Quake behavior.
function testInvalidAddressFieldUsesRunError()
  machine = simpleMachine([t.QuakeCStatement(op.OP_ADDRESS, 50, 51, 52)])
  vm.setWord(machine, 50, 1)
  vm.setWord(machine, 51, 8)
  return expectProgramError(machine, "invalid ADDRESS field")
end function

// Verify pointer boundary rejected against the expected Quake behavior.
function testPointerBoundaryRejected()
  machine = simpleMachine([t.QuakeCStatement(op.OP_STOREP_V, 50, 51, 0)])
  vm.setWord(machine, 51, 1 * 8 + 7)
  return expectProgramError(machine, "cross-boundary STOREP_V")
end function

// Verify pointer scalar accepted against the expected Quake behavior.
function testPointerScalarAccepted()
  machine = simpleMachine([
    t.QuakeCStatement(op.OP_STOREP_F, 50, 51, 0),
    t.QuakeCStatement(op.OP_DONE, 0, 0, 0),
  ])
  vm.setWord(machine, 50, 0x12345678)
  vm.setWord(machine, 51, 1 * 8 + 7)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.entityField(machine, 1, 7), 0x12345678, "scalar pointer store")
  return true
end function

// Verify program string latin1 against the expected Quake behavior.
function testProgramStringLatin1()
  machine = simpleMachine([t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  text = vm.stringValue(machine, 1)
  equal(hex(protocolText.encodeBytes(text)), "e9", "program string byte")
  return true
end function

// Verify dynamic string latin1 against the expected Quake behavior.
function testDynamicStringLatin1()
  machine = simpleMachine([t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  handle = vm.internString(machine, decode(bytes([0xc3, 0xa9])))
  equal(hex(protocolText.encodeBytes(vm.stringValue(machine, handle))), "e9", "dynamic string byte")
  return true
end function

// Verify string compare unsigned bytes against the expected Quake behavior.
function testStringCompareUnsignedBytes()
  machine = simpleMachine([t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  high = vm.stringValue(machine, 1)
  yes(vm.stringCompare(high, "z") > 0, "unsigned Latin-1 strcmp ordering")
  return true
end function

// Verify stack and local constants against the expected Quake behavior.
function testStackAndLocalConstants()
  equal(vm.MAX_STACK_DEPTH, 32, "stack depth")
  equal(vm.LOCALSTACK_SIZE, 2048, "local stack size")
  // Vector destinations may overlap their sources, as in pr_exec.c.  Reading
  // every source component before writing the result preserves that contract.
  machine = simpleMachine([
    t.QuakeCStatement(op.OP_ADD_V, 50, 53, 51),
    t.QuakeCStatement(op.OP_DONE, 0, 0, 0),
  ])
  vm.setGlobalFloat(machine, 50, 1.0)
  vm.setGlobalFloat(machine, 51, 2.0)
  vm.setGlobalFloat(machine, 52, 3.0)
  vm.setGlobalFloat(machine, 53, 4.0)
  vm.setGlobalFloat(machine, 54, 5.0)
  vm.setGlobalFloat(machine, 55, 6.0)
  vm.PR_ExecuteProgram(machine, 1)
  equal(vm.word(machine, 51), native.floatBits(5.0), "overlapping vector x")
  equal(vm.word(machine, 52), native.floatBits(7.0), "overlapping vector y")
  equal(vm.word(machine, 53), native.floatBits(9.0), "overlapping vector z")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-021 QuakeC VM tests"
  passed = 0
  if run(1, "PR_ExecuteProgram trace reset", testTraceReset) then passed = passed + 1 end if
  if run(2, "traceon lifetime", testTraceOnCurrentInvocationOnly) then passed = passed + 1 end if
  if run(3, "OP_STATE signed zero", testStateSignedZeroPreserved) then passed = passed + 1 end if
  if run(4, "OP_STATE changed frame", testStateChangedFrameStored) then passed = passed + 1 end if
  if run(5, "OP_STATE NaN payload", testStateNanStored) then passed = passed + 1 end if
  if run(6, "OP_STATE nextthink", testStateNextThinkFloat) then passed = passed + 1 end if
  if run(7, "invalid scalar load", testInvalidLoadUsesRunError) then passed = passed + 1 end if
  if run(8, "invalid vector load", testInvalidVectorLoadUsesRunError) then passed = passed + 1 end if
  if run(9, "invalid address entity", testInvalidAddressEntityUsesRunError) then passed = passed + 1 end if
  if run(10, "invalid address field", testInvalidAddressFieldUsesRunError) then passed = passed + 1 end if
  if run(11, "pointer boundary", testPointerBoundaryRejected) then passed = passed + 1 end if
  if run(12, "pointer scalar", testPointerScalarAccepted) then passed = passed + 1 end if
  if run(13, "program Latin-1 string", testProgramStringLatin1) then passed = passed + 1 end if
  if run(14, "dynamic Latin-1 string", testDynamicStringLatin1) then passed = passed + 1 end if
  if run(15, "string compare", testStringCompareUnsignedBytes) then passed = passed + 1 end if
  if run(16, "VM limits", testStackAndLocalConstants) then passed = passed + 1 end if
  if passed != 16 then return 1 end if
  print "MiniQuake BP-021 QuakeC VM tests passed: 16"
  return 0
end function
