/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-079: host_cmd.c numeric surface and gameplay/presentation freeze.
*/
import miniquake.gameplay_presentation_contract as contract
import miniquake.host_command_numbers as numbers
import miniquake.host as host
import miniquake.server as server
import miniquake.cvar as cvar
import miniquake.common as common

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(10790, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(10791, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(10792, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify contract verify against the expected Quake behavior.
function testContractVerify()
  yes(contract.verify(), "contract verify")
  return true
end function

// Verify contract status against the expected Quake behavior.
function testContractStatus()
  equal(contract.STATUS, "gameplay_presentation_109_frozen_v1", "status")
  return true
end function

// Verify contract fingerprint against the expected Quake behavior.
function testContractFingerprint()
  equal(contract.fnv1a32(contract.canonicalText()), contract.FINGERPRINT, "fingerprint")
  return true
end function

// Verify contract math against the expected Quake behavior.
function testContractMath()
  equal(contract.ANGLE_UNITS, 65536, "angle units")
  equal(contract.CHASE_TRACE_DISTANCE, 4096, "trace distance")
  return true
end function

// Verify contract view against the expected Quake behavior.
function testContractView()
  equal(contract.GAMMA_ENTRIES, 256, "gamma entries")
  equal(contract.CSHIFT_COUNT, 4, "cshift count")
  equal(contract.VIEW_BSP_NUDGE, 0.03125, "view nudge")
  return true
end function

// Verify contract screen against the expected Quake behavior.
function testContractScreen()
  equal(contract.CENTER_LINE_CHARS, 40, "center chars")
  equal(contract.SCREENSHOT_SLOTS, 100, "screenshot slots")
  equal(contract.LOADING_TIMEOUT_SECONDS, 60, "loading timeout")
  return true
end function

// Verify contract statusbar against the expected Quake behavior.
function testContractStatusbar()
  equal(contract.STATUSBAR_HEIGHT, 24, "sbar height")
  equal(contract.MAX_SCOREBOARD, 16, "scoreboard")
  return true
end function

// Verify player index integer against the expected Quake behavior.
function testPlayerIndexInteger()
  equal(numbers.playerIndex("2"), 1, "player index")
  return true
end function

// Verify player index float prefix against the expected Quake behavior.
function testPlayerIndexFloatPrefix()
  equal(numbers.playerIndex("2.9junk"), 1, "player float prefix")
  return true
end function

// Verify player index hex against the expected Quake behavior.
function testPlayerIndexHex()
  equal(numbers.playerIndex("0x3"), 2, "player hex")
  return true
end function

// Verify integer trailing against the expected Quake behavior.
function testIntegerTrailing()
  equal(numbers.integer("  +12junk"), 12, "integer whitespace plus trailing")
  return true
end function

// Verify integer decimal stop against the expected Quake behavior.
function testIntegerDecimalStop()
  equal(numbers.integer("1.5"), 1, "integer decimal stop")
  return true
end function

// Verify integer invalid against the expected Quake behavior.
function testIntegerInvalid()
  equal(numbers.integer("abc"), 0, "integer invalid")
  return true
end function

// Verify integer negative against the expected Quake behavior.
function testIntegerNegative()
  equal(numbers.integer("-17tail"), -17, "integer negative")
  return true
end function

// Verify edict quake integer against the expected Quake behavior.
function testEdictQuakeInteger()
  equal(common.atoi("0x20"), 32, "edict Q_atoi hex")
  return true
end function

// Verify integer character against the expected Quake behavior.
function testIntegerCharacter()
  equal(numbers.integer("'A"), 0, "CRT atoi rejects character syntax")
  return true
end function

// Verify color single against the expected Quake behavior.
function testColorSingle()
  components = numbers.colorArguments(["color", "12junk"], 1)
  equal(components[0], 12, "single top")
  equal(components[1], 12, "single bottom")
  return true
end function

// Verify color pair against the expected Quake behavior.
function testColorPair()
  components = numbers.colorArguments(["color", "3", "9"], 1)
  equal(components[0], 3, "pair top")
  equal(components[1], 9, "pair bottom")
  return true
end function

// Verify color mask and cap against the expected Quake behavior.
function testColorMaskAndCap()
  components = numbers.colorArguments(["color", "-1", "14"], 1)
  equal(components[0], 13, "negative cap")
  equal(components[1], 13, "fourteen cap")
  return true
end function

// Verify host color trailing against the expected Quake behavior.
function testHostColorTrailing()
  session = host.create([])
  host.Host_Color_f(session, ["color", "12junk"])
  equal(session.client.colors, 204, "host color")
  nearValue = cvar.variableValue(session.cvars, "_cl_color")
  equal(nearValue, 204.0, "host color cvar")
  return true
end function

// Verify host color decimal stop against the expected Quake behavior.
function testHostColorDecimalStop()
  session = host.create([])
  host.Host_Color_f(session, ["color", "1.5"])
  equal(session.client.colors, 17, "host decimal stop")
  return true
end function

// Verify server color trailing against the expected Quake behavior.
function testServerColorTrailing()
  gameServer = server.create(1)
  clientValue = gameServer.clients[0]
  clientValue.active = true
  server.Host_Color_f(gameServer, clientValue, ["color", "12junk", "3tail"])
  equal(clientValue.colors, 195, "server color")
  return true
end function

// Verify server kick index prefix against the expected Quake behavior.
function testServerKickIndexPrefix()
  gameServer = server.create(2)
  gameServer.clients[0].active = true
  gameServer.clients[0].name = "alpha"
  gameServer.clients[1].active = true
  gameServer.clients[1].name = "bravo"
  yes(server.Host_Kick_f(gameServer, void, ["kick", "#", "2junk"]), "kick accepted")
  no(gameServer.clients[1].active, "second client dropped")
  return true
end function

// Verify command registry against the expected Quake behavior.
function testCommandRegistry()
  commands = host.Host_InitCommands()
  foundViewframe = false
  foundEdict = false
  foundColor = false
  for each name in commands
    if name == "viewframe" then foundViewframe = true end if
    if name == "edict" then foundEdict = true end if
    if name == "color" then foundColor = true end if
  end for
  yes(foundViewframe and foundEdict and foundColor, "command registry")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed = 0
  if run(1, "contract verify", testContractVerify) then passed = passed + 1 end if
  if run(2, "contract status", testContractStatus) then passed = passed + 1 end if
  if run(3, "contract fingerprint", testContractFingerprint) then passed = passed + 1 end if
  if run(4, "contract math", testContractMath) then passed = passed + 1 end if
  if run(5, "contract view", testContractView) then passed = passed + 1 end if
  if run(6, "contract screen", testContractScreen) then passed = passed + 1 end if
  if run(7, "contract statusbar", testContractStatusbar) then passed = passed + 1 end if
  if run(8, "player index integer", testPlayerIndexInteger) then passed = passed + 1 end if
  if run(9, "player index float prefix", testPlayerIndexFloatPrefix) then passed = passed + 1 end if
  if run(10, "player index hex", testPlayerIndexHex) then passed = passed + 1 end if
  if run(11, "integer trailing", testIntegerTrailing) then passed = passed + 1 end if
  if run(12, "integer decimal stop", testIntegerDecimalStop) then passed = passed + 1 end if
  if run(13, "integer invalid", testIntegerInvalid) then passed = passed + 1 end if
  if run(14, "integer negative", testIntegerNegative) then passed = passed + 1 end if
  if run(15, "edict Q_atoi", testEdictQuakeInteger) then passed = passed + 1 end if
  if run(16, "integer character", testIntegerCharacter) then passed = passed + 1 end if
  if run(17, "single color", testColorSingle) then passed = passed + 1 end if
  if run(18, "color pair", testColorPair) then passed = passed + 1 end if
  if run(19, "color mask cap", testColorMaskAndCap) then passed = passed + 1 end if
  if run(20, "host color trailing", testHostColorTrailing) then passed = passed + 1 end if
  if run(21, "host color decimal stop", testHostColorDecimalStop) then passed = passed + 1 end if
  if run(22, "server color trailing", testServerColorTrailing) then passed = passed + 1 end if
  if run(23, "server kick index", testServerKickIndexPrefix) then passed = passed + 1 end if
  if run(24, "command registry", testCommandRegistry) then passed = passed + 1 end if
  if passed != 24 then print "MiniQuake BP-079 gameplay/presentation closure tests failed: " + passed + "/24"; return 1 end if
  print "MiniQuake BP-079 gameplay/presentation closure tests passed: 24"
  return 0
end function
