/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused conproc.c QHOST protocol and console fixtures.
*/
import miniquake.conproc as conproc

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9801, name + ": expected true") end if
  return true
end function

// Return initialized state derived from the active module state.
function initializedState()
  assertTrue(conproc.InitConProc(1, 2, 3, false), "test conproc init")
  return conproc.ConProc_State()
end function

// Verify lifecycle against the expected Quake behavior.
function testLifecycle()
  assertEqual(conproc.InitConProc(0, 2, 3, false), false, "missing mapping ignored")
  state = initializedState()
  assertEqual(state.active, true, "conproc active")
  assertEqual(state.screenWidth, 80, "forced console width")
  assertEqual(state.screenHeight, 25, "minimum console height")
  assertTrue(conproc.DeinitConProc(), "conproc deinit")
  assertEqual(state.active, false, "conproc stopped")
  return true
end function

// Verify character codes against the expected Quake behavior.
function testCharacterCodes()
  assertEqual(conproc.CharToCode(13), 28, "return scan code")
  assertEqual(conproc.CharToCode(97), 30, "lowercase A scan code")
  assertEqual(conproc.CharToCode(90), 55, "uppercase Z scan code")
  assertEqual(conproc.CharToCode(48), 2, "zero source mapping")
  assertEqual(conproc.CharToCode(57), 11, "nine source mapping")
  assertEqual(conproc.CharToCode(33), 33, "punctuation passthrough")
  return true
end function

// Verify screen buffer against the expected Quake behavior.
function testScreenBuffer()
  state = initializedState()
  state.maximumWidth = 100
  state.maximumHeight = 40
  assertTrue(conproc.SetConsoleCXCY(0, 120, 80), "console resize")
  assertEqual(state.screenWidth, 100, "console width clamped")
  assertEqual(state.screenHeight, 40, "console height clamped")
  assertTrue(conproc.SetScreenBufferLines(30), "screen-line setter")
  assertEqual(conproc.GetScreenBufferLines(), 30, "screen-line getter")
  state.consoleLines = ["alpha", "beta", "gamma"]
  text = conproc.ReadText(1, 2)
  assertEqual(len(bytes(text)), 160, "inclusive 80-column read")
  assertEqual(decode(slice(bytes(text), 0, 4)), "beta", "first selected line")
  assertEqual(decode(slice(bytes(text), 80, 5)), "gamma", "second selected line")
  return true
end function

// Verify write text against the expected Quake behavior.
function testWriteText()
  state = initializedState()
  assertTrue(conproc.WriteText("aB\n"), "write text")
  assertEqual(len(state.inputEvents), 6, "down/up event pairs")
  assertEqual(state.inputEvents[0][0], 97, "lowercase character")
  assertEqual(state.inputEvents[0][1], 65, "uppercase virtual key")
  assertEqual(state.inputEvents[0][3], false, "lowercase shift state")
  assertEqual(state.inputEvents[2][3], true, "uppercase shift state")
  assertEqual(state.inputEvents[4][0], 13, "newline converted to carriage return")
  assertEqual(state.inputEvents[4][2], 28, "return scan code emitted")
  return true
end function

// Verify requests against the expected Quake behavior.
function testRequests()
  state = initializedState()
  conproc.ConProc_SetTestBuffer([conproc.CCOM_WRITE_TEXT, "go\n"])
  assertTrue(conproc.RequestProc(false), "write request")
  assertEqual(conproc.ConProc_RequestBuffer()[0], true, "write response")

  state.consoleLines = ["zero", "one", "two"]
  conproc.ConProc_SetTestBuffer([conproc.CCOM_GET_TEXT, 1, 2])
  assertTrue(conproc.RequestProc(false), "read request")
  assertEqual(len(bytes(conproc.ConProc_RequestBuffer()[1])), 160, "read response length")

  conproc.ConProc_SetTestBuffer([conproc.CCOM_GET_SCR_LINES])
  assertTrue(conproc.RequestProc(false), "get-lines request")
  assertEqual(conproc.ConProc_RequestBuffer()[1], 25, "get-lines response")

  conproc.ConProc_SetTestBuffer([conproc.CCOM_SET_SCR_LINES, 35])
  assertTrue(conproc.RequestProc(false), "set-lines request")
  assertEqual(state.screenHeight, 35, "set-lines applied")
  assertEqual(state.requests, 4, "request count")
  return true
end function

// Verify mapped buffer hooks against the expected Quake behavior.
function testMappedBufferHooks()
  state = initializedState()
  buffer = [conproc.CCOM_GET_SCR_LINES]
  conproc.ConProc_SetTestBuffer(buffer)
  assertEqual(conproc.GetMappedBuffer(1), buffer, "test mapping")
  assertTrue(conproc.ReleaseMappedBuffer(buffer), "test unmapping")
  assertEqual(state.mappedBuffer, void, "mapping cleared")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  testLifecycle()
  testCharacterCodes()
  testScreenBuffer()
  testWriteText()
  testRequests()
  testMappedBufferHooks()
  print "conproc parity tests: 6/6 passed"
  return 0
end function
