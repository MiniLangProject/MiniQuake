/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-031: command buffer, alias and cvar lifecycle parity.
*/
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.native as native

// Exercise never as part of this deterministic regression fixture.
function never(name)
  return false
end function

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3100, name + ": expected true") end if
  return true
end function
// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(3101, name + ": expected false") end if
  return true
end function
// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3102, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Exercise registry as part of this deterministic regression fixture.
function registry()
  value = cvar.createRegistry()
  cvar.register(value, cvar.create("first", "1", true, false), never)
  cvar.register(value, cvar.create("second", "2", true, true), never)
  return value
end function

// Verify stored float against the expected Quake behavior.
function testStoredFloat()
  value = cvar.create("x", "0.100000001", false, false)
  equal(native.floatBits(value.value), native.floatBits(0.100000001), "stored binary32")
  return true
end function
// Verify set value against the expected Quake behavior.
function testSetValue()
  value = registry(); cvar.setValue(value, "first", 1.25)
  equal(cvar.variableString(value, "first"), "1.250000", "setvalue text")
  cvar.setValue(value, "first", 4097.0)
  equal(cvar.variableString(value, "first"), "4097.000000", "setvalue stock item mask")
  cvar.setValue(value, "first", -4097.0)
  equal(cvar.variableString(value, "first"), "-4097.000000", "setvalue negative large")
  return true
end function
// Verify negative zero against the expected Quake behavior.
function testNegativeZero()
  value = registry(); cvar.setValue(value, "first", native.bitsFloat(0x80000000))
  equal(cvar.variableString(value, "first"), "-0.000000", "negative zero")
  return true
end function
// Verify positive zero against the expected Quake behavior.
function testPositiveZero()
  value = registry(); cvar.setValue(value, "first", 0.0)
  equal(cvar.variableString(value, "first"), "0.000000", "positive zero")
  return true
end function
// Verify server change against the expected Quake behavior.
function testServerChange()
  value = registry(); cvar.set(value, "second", "3")
  changes = cvar.takeServerChanges(value)
  equal(len(changes), 1, "server change count")
  equal(changes[0][0], "second", "server change name")
  return true
end function
// Verify unchanged server value against the expected Quake behavior.
function testUnchangedServerValue()
  value = registry(); cvar.set(value, "second", "2")
  equal(len(cvar.takeServerChanges(value)), 0, "unchanged server value")
  return true
end function
// Verify non server change against the expected Quake behavior.
function testNonServerChange()
  value = registry(); cvar.set(value, "first", "4")
  equal(len(cvar.takeServerChanges(value)), 0, "non-server change")
  return true
end function
// Verify head insertion against the expected Quake behavior.
function testHeadInsertion()
  value = registry()
  equal(value.variables[0].name, "second", "cvar head insertion")
  indexed = value.lookup.get("second")
  equal(nativeRawValue(indexed), nativeRawValue(value.variables[0]), "registered cvar hash index")
  // Legacy renderer setup can prepend an internal cvar directly. A cache miss
  // must discover and index that entry without changing public list behavior.
  legacy = cvar.create("legacy_direct", "3", false, false)
  value.variables = [legacy] + value.variables
  found = cvar.find(value, "legacy_direct")
  equal(nativeRawValue(found), nativeRawValue(legacy), "direct cvar lazy index")
  equal(nativeRawValue(value.lookup.get("legacy_direct")), nativeRawValue(legacy), "direct cvar cached")
  return true
end function
// Verify archive order against the expected Quake behavior.
function testArchiveOrder()
  value = registry()
  equal(cvar.archiveText(value), "second \"2\"\nfirst \"1\"\n", "archive list order")
  return true
end function
// Verify completion against the expected Quake behavior.
function testCompletion()
  value = registry()
  equal(cvar.completeVariable(value, "sec"), "second", "completion")
  return true
end function
// Verify completion case sensitive against the expected Quake behavior.
function testCompletionCaseSensitive()
  value = registry()
  yes(cvar.completeVariable(value, "Sec") is void, "completion case")
  return true
end function
// Verify command query against the expected Quake behavior.
function testCommandQuery()
  value = registry(); result = cvar.command(value, ["first"])
  yes(result[0], "query handled")
  equal(result[1], "\"first\" is \"1\"", "query text")
  return true
end function
// Verify command set against the expected Quake behavior.
function testCommandSet()
  value = registry(); result = cvar.command(value, ["first", "7", "ignored"])
  yes(result[0], "set handled")
  equal(cvar.variableString(value, "first"), "7", "only argv1 used")
  return true
end function
// Verify unknown command against the expected Quake behavior.
function testUnknownCommand()
  value = registry(); result = cvar.command(value, ["missing"])
  no(result[0], "unknown cvar")
  return true
end function
// Verify command buffer boundary against the expected Quake behavior.
function testCommandBufferBoundary()
  system = cmd.create(); fill = bytes(cmd.COMMAND_BUFFER_SIZE - 1, 97)
  yes(cmd.addText(system, decode(fill)), "buffer max minus one")
  no(cmd.addText(system, "b"), "exact max rejected")
  return true
end function
// Verify quoted semicolon against the expected Quake behavior.
function testQuotedSemicolon()
  parts = cmd.splitFirstCommand("echo \"a;b\";echo c")
  equal(parts[0], "echo \"a;b\"", "quoted semicolon")
  equal(parts[1], "echo c", "remaining command")
  return true
end function
// Verify alias termination against the expected Quake behavior.
function testAliasTermination()
  system = cmd.create(); alias = cmd.addAlias(system, "x", "echo hi")
  equal(alias.value, "echo hi \n", "alias trailing space and newline")
  return true
end function
// Verify alias exact replacement against the expected Quake behavior.
function testAliasExactReplacement()
  system = cmd.create(); cmd.addAlias(system, "x", "one"); cmd.addAlias(system, "X", "two")
  equal(len(system.aliases), 2, "case-distinct aliases")
  cmd.addAlias(system, "x", "three")
  equal(len(system.aliases), 2, "exact alias reused")
  return true
end function
// Verify wait retains buffer against the expected Quake behavior.
function testWaitRetainsBuffer()
  system = cmd.create(); cmd.addText(system, "wait;echo later\n")
  equal(cmd.executeBuffer(system), 1, "wait executes one")
  yes(system.text != "", "wait retains rest")
  return true
end function
// Verify token limit against the expected Quake behavior.
function testTokenLimit()
  text = "command"
  index = 0
  while index < 100
    text = text + " x"
    index = index + 1
  end while
  equal(len(cmd.tokenize(text)), cmd.MAX_ARGS, "MAX_ARGS")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  tests = [
    ["binary32 cvar storage", testStoredFloat], ["setvalue formatting", testSetValue],
    ["negative zero", testNegativeZero], ["positive zero", testPositiveZero],
    ["server change", testServerChange], ["unchanged server value", testUnchangedServerValue],
    ["non-server change", testNonServerChange], ["registration order", testHeadInsertion],
    ["archive order", testArchiveOrder], ["completion", testCompletion],
    ["completion case", testCompletionCaseSensitive], ["cvar query", testCommandQuery],
    ["cvar set", testCommandSet], ["unknown cvar", testUnknownCommand],
    ["command buffer boundary", testCommandBufferBoundary], ["quoted semicolon", testQuotedSemicolon],
    ["alias termination", testAliasTermination], ["alias replacement", testAliasExactReplacement],
    ["wait semantics", testWaitRetainsBuffer], ["argument limit", testTokenLimit],
  ]
  passed = 0; index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 20 then return 1 end if
  print "MiniQuake BP-031 command/cvar lifecycle tests passed: 20"
  return 0
end function
