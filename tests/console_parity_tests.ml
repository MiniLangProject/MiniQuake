/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused console.c ring-buffer, notify, input and condebug fixtures.
*/

import miniquake.console as console
import miniquake.filesystem as qfs
import std.fs as fs

function assertEqual(actual, expected, name)
  if actual != expected then return error(9600, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9601, name + ": expected true") end if
  return true
end function

function testRingAndResize()
  state = console.create(32)
  assertTrue(console.Con_CheckResize(state, 80), "initial resize")
  assertEqual(state.lineWidth, 8, "320-style character width")
  console.Con_Print(state, "first\nsecond\nthird", 1.0)
  assertEqual(state.lines[0], "first", "oldest ring row")
  assertEqual(state.lines[2], "third", "current ring row")
  console.Con_CheckResize(state, 160)
  assertEqual(state.lineWidth, 18, "resized character width")
  assertEqual(state.lines[0], "first", "resize preserves oldest")
  assertEqual(state.lines[2], "third", "resize preserves newest")
  return true
end function

function testCarriageReturnAndWordWrap()
  state = console.create(32)
  console.Con_CheckResize(state, 160)
  console.Con_Print(state, "progress 1" + decode(bytes([13])) + "progress 2", 2.0)
  assertEqual(state.lines[len(state.lines) - 1], "progress 2", "carriage return rewrites current row")

  wrapped = console.create(32)
  console.Con_CheckResize(wrapped, 80)
  console.Con_Print(wrapped, "12345 678", 2.0)
  assertEqual(wrapped.lines[0], "12345", "word wrap first row")
  assertEqual(wrapped.lines[1], "678", "word wrap second row")
  return true
end function

function testMaskAndNotifyTimes()
  state = console.create(32)
  console.Con_CheckResize(state, 320)
  console.Con_Print(state, decode(bytes([1, 65, 66])), 1.0)
  row = console.lineBytes(state, state.currentLine)
  assertEqual(row[0], 193, "talk text mask first character")
  assertEqual(row[1], 194, "talk text mask second character")
  assertTrue(state.talkSoundRequested, "talk sound request")
  console.Con_Print(state, "\nsecond", 2.0)
  oldRows = console.Con_NotifyRows(state, 4.1, 3.0)
  assertEqual(len(oldRows), 1, "expired notify row removed")
  assertEqual(console.printableLine(oldRows[0]), "second", "new notify row retained")
  console.Con_ClearNotify(state)
  assertEqual(len(console.Con_NotifyRows(state, 4.1, 3.0)), 0, "notify timestamps cleared")
  return true
end function

function testBackscrollAndInputTrace()
  state = console.create(32)
  console.Con_CheckResize(state, 80)
  index = 0
  while index < 6
    console.appendLine(state, "line" + index)
    index = index + 1
  end while
  console.setBackscroll(2)
  rows = console.Con_ConsoleRows(state, 40)
  assertEqual(len(rows), 3, "console visible row count")
  assertEqual(console.printableLine(rows[2]), "line3", "backscroll newest visible row")
  console.setInput(state, "123456789")
  state.active = true
  input = console.Con_DrawInput(state, 1.0)
  assertEqual(len(input), 8, "input clipped to line width")
  assertEqual(input[0], 51, "input horizontally scrolled")
  trace = console.Con_DrawConsole(state, 40, true, 1.0)
  assertEqual(trace[0][0], "background", "console trace begins with background")
  assertEqual(trace[len(trace) - 1][0], "input", "console trace ends with input")
  return true
end function

function testPrintingModesAndCommands()
  state = console.create(32)
  state.initialized = true
  console.Con_CheckResize(state, 320)
  assertEqual(console.Con_DPrintf(state, "hidden\n", false, false, false), false, "developer print hidden")
  assertEqual(len(state.lines), 0, "hidden developer print not buffered")
  assertEqual(console.Con_Printf(state, "dedicated\n", true, false), false, "dedicated print bypass")
  assertEqual(len(state.lines), 0, "dedicated print not buffered")
  state.updateRequested = false
  assertTrue(console.Con_SafePrintf(state, "safe\n", false), "safe print")
  assertEqual(state.updateRequested, false, "safe print suppresses screen update")
  assertTrue(console.Con_Print_f(state, ["con_print", "hello", "quake"]), "print command")
  assertEqual(state.lines[len(state.lines) - 1], "hello quake", "print command text")
  state.active = true
  assertEqual(console.Con_ToggleConsole_f(state, false), "menu", "disconnected close routes to menu")
  assertEqual(state.active, false, "menu route closes console")
  assertEqual(console.Con_ToggleConsole_f(state, true), "console", "connected open routes to console")
  assertEqual(console.Con_MessageMode2_f(state), true, "team message mode")
  return true
end function

function testOriginalStatePreservation()
  state = console.create(32)
  state.initialized = true
  console.Con_CheckResize(state, 320)
  console.Con_Print(state, "abcdef", 1.0)
  state.carriageReturn = true
  console.setBackscroll(3)
  state.notifyPixelLines = 24
  current = state.currentLine
  count = state.lineCount
  cursor = state.cursorX
  console.Con_Clear_f(state)
  assertEqual(state.currentLine, current, "clear preserves current line")
  assertEqual(state.lineCount, count, "clear preserves line count")
  assertEqual(state.cursorX, cursor, "clear preserves cursor")
  assertEqual(state.carriageReturn, true, "clear preserves carriage return")
  assertEqual(console.backscroll(), 3, "clear preserves backscroll")

  state.notifyTimes = [1.0, 2.0, 3.0, 4.0]
  console.Con_ClearNotify(state)
  assertEqual(state.notifyPixelLines, 24, "clear notify preserves high water")

  state.carriageReturn = false
  state.cursorX = 6
  console.Con_CheckResize(state, 640)
  assertEqual(state.cursorX, 6, "resize preserves cursor")

  state.active = true
  state.inputText = "disconnected"
  assertEqual(console.Con_ToggleConsole_f(state, false), "menu", "disconnected toggle route")
  assertEqual(state.inputText, "disconnected", "disconnected toggle preserves input")
  state.active = true
  assertEqual(console.Con_ToggleConsole_f(state, true), "game", "connected toggle route")
  assertEqual(state.inputText, "", "connected toggle clears input")
  return true
end function

function testDebugLogAndNotifyTrace()
  system = qfs.create(".", "build")
  state = console.create(32)
  console.Con_Init(state, system, 320, true)
  console.Con_Printf(state, "one\n", false, false)
  console.Con_Printf(state, "two\n", false, false)
  logged = fs.readAllText(qfs.gamePath(system, "qconsole.log"))
  if logged is error then return logged end if
  assertEqual(logged, "Console initialized.\none\ntwo\n", "condebug append log")
  state.active = false
  console.Con_ClearNotify(state)
  console.Con_Print(state, "notice", 10.0)
  commands = console.Con_DrawNotify(state, 11.0, 3.0, true, "hello")
  assertEqual(commands[0][0], "text", "notify text trace")
  assertEqual(commands[1][0], "chat", "notify chat trace")
  assertEqual(console.Con_CommandTrace(state)[1][0], "chat", "stored command trace")
  return true
end function

function main(args)
  testRingAndResize()
  testCarriageReturnAndWordWrap()
  testMaskAndNotifyTimes()
  testBackscrollAndInputTrace()
  testPrintingModesAndCommands()
  testDebugLogAndNotifyTrace()
  testOriginalStatePreservation()
  print "Console parity tests: 7/7 passed"
  return 0
end function
