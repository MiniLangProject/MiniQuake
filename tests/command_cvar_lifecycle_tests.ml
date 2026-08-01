/* BP-031: command buffer, alias and cvar lifecycle parity. */
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.native as native

function never(name)
  return false
end function

function yes(value, name)
  if not value then return error(3100, name + ": expected true") end if
  return true
end function
function no(value, name)
  if value then return error(3101, name + ": expected false") end if
  return true
end function
function equal(actual, expected, name)
  if actual != expected then return error(3102, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function registry()
  value = cvar.createRegistry()
  cvar.register(value, cvar.create("first", "1", true, false), never)
  cvar.register(value, cvar.create("second", "2", true, true), never)
  return value
end function

function testStoredFloat()
  value = cvar.create("x", "0.100000001", false, false)
  equal(native.floatBits(value.value), native.floatBits(0.100000001), "stored binary32")
  return true
end function
function testSetValue()
  value = registry(); cvar.setValue(value, "first", 1.25)
  equal(cvar.variableString(value, "first"), "1.250000", "setvalue text")
  cvar.setValue(value, "first", 4097.0)
  equal(cvar.variableString(value, "first"), "4097.000000", "setvalue stock item mask")
  cvar.setValue(value, "first", -4097.0)
  equal(cvar.variableString(value, "first"), "-4097.000000", "setvalue negative large")
  return true
end function
function testNegativeZero()
  value = registry(); cvar.setValue(value, "first", native.bitsFloat(0x80000000))
  equal(cvar.variableString(value, "first"), "-0.000000", "negative zero")
  return true
end function
function testPositiveZero()
  value = registry(); cvar.setValue(value, "first", 0.0)
  equal(cvar.variableString(value, "first"), "0.000000", "positive zero")
  return true
end function
function testServerChange()
  value = registry(); cvar.set(value, "second", "3")
  changes = cvar.takeServerChanges(value)
  equal(len(changes), 1, "server change count")
  equal(changes[0][0], "second", "server change name")
  return true
end function
function testUnchangedServerValue()
  value = registry(); cvar.set(value, "second", "2")
  equal(len(cvar.takeServerChanges(value)), 0, "unchanged server value")
  return true
end function
function testNonServerChange()
  value = registry(); cvar.set(value, "first", "4")
  equal(len(cvar.takeServerChanges(value)), 0, "non-server change")
  return true
end function
function testHeadInsertion()
  value = registry()
  equal(value.variables[0].name, "second", "cvar head insertion")
  return true
end function
function testArchiveOrder()
  value = registry()
  equal(cvar.archiveText(value), "second \"2\"\nfirst \"1\"\n", "archive list order")
  return true
end function
function testCompletion()
  value = registry()
  equal(cvar.completeVariable(value, "sec"), "second", "completion")
  return true
end function
function testCompletionCaseSensitive()
  value = registry()
  yes(cvar.completeVariable(value, "Sec") is void, "completion case")
  return true
end function
function testCommandQuery()
  value = registry(); result = cvar.command(value, ["first"])
  yes(result[0], "query handled")
  equal(result[1], "\"first\" is \"1\"", "query text")
  return true
end function
function testCommandSet()
  value = registry(); result = cvar.command(value, ["first", "7", "ignored"])
  yes(result[0], "set handled")
  equal(cvar.variableString(value, "first"), "7", "only argv1 used")
  return true
end function
function testUnknownCommand()
  value = registry(); result = cvar.command(value, ["missing"])
  no(result[0], "unknown cvar")
  return true
end function
function testCommandBufferBoundary()
  system = cmd.create(); fill = bytes(cmd.COMMAND_BUFFER_SIZE - 1, 97)
  yes(cmd.addText(system, decode(fill)), "buffer max minus one")
  no(cmd.addText(system, "b"), "exact max rejected")
  return true
end function
function testQuotedSemicolon()
  parts = cmd.splitFirstCommand("echo \"a;b\";echo c")
  equal(parts[0], "echo \"a;b\"", "quoted semicolon")
  equal(parts[1], "echo c", "remaining command")
  return true
end function
function testAliasTermination()
  system = cmd.create(); alias = cmd.addAlias(system, "x", "echo hi")
  equal(alias.value, "echo hi \n", "alias trailing space and newline")
  return true
end function
function testAliasExactReplacement()
  system = cmd.create(); cmd.addAlias(system, "x", "one"); cmd.addAlias(system, "X", "two")
  equal(len(system.aliases), 2, "case-distinct aliases")
  cmd.addAlias(system, "x", "three")
  equal(len(system.aliases), 2, "exact alias reused")
  return true
end function
function testWaitRetainsBuffer()
  system = cmd.create(); cmd.addText(system, "wait;echo later\n")
  equal(cmd.executeBuffer(system), 1, "wait executes one")
  yes(system.text != "", "wait retains rest")
  return true
end function
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
