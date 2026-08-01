/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-063: sys_win.c, conproc.c and Win32 platform lifecycle parity.
*/

import miniquake.sys_win as system
import miniquake.conproc as conproc

fixtureArguments = []
testIndex = 0
failures = 0

function bp063Check(value, name)
  global testIndex, failures
  testIndex = testIndex + 1
  print "[" + testIndex + "/21] " + name
  if not value then failures = failures + 1; print "FAIL: " + name; return false end if
  return true
end function

function runner(arguments)
  global fixtureArguments
  fixtureArguments = arguments
  return 17
end function

function stateForTest()
  state = system.Sys_CreateState(false)
  system.Sys_UseState(state)
  return state
end function

function main(args)
  bp063Check(system.MINIMUM_WIN_MEMORY == 0x0880000 and system.MAXIMUM_WIN_MEMORY == 0x1000000, "WinQuake memory bounds")
  parsed = system.Sys_ParseCommandLine("  -dedicated\t-heapsize 4096  +map start")
  bp063Check(parsed == ["", "-dedicated", "-heapsize", "4096", "+map", "start"], "command-line whitespace parser")
  quoted = system.Sys_ParseCommandLine("\"two words\"")
  bp063Check(quoted == ["", "\"two", "words\""], "historical parser has no quote syntax")
  bp063Check(system.Sys_SelectMemorySize(1024, 16 * 1024 * 1024, []) == system.MINIMUM_WIN_MEMORY, "minimum memory clamp")
  bp063Check(system.Sys_SelectMemorySize(4 * 1024 * 1024, 24 * 1024 * 1024, []) == 12 * 1024 * 1024, "half physical memory floor")
  bp063Check(system.Sys_SelectMemorySize(64 * 1024 * 1024, 128 * 1024 * 1024, []) == system.MAXIMUM_WIN_MEMORY, "maximum memory clamp")
  bp063Check(system.Sys_SelectMemorySize(1024, 16 * 1024 * 1024, ["", "-heapsize", "4096"]) == 4096 * 1024, "heapsize override")

  state = stateForTest()
  memory = bytes(65540)
  memory[0] = 1
  memory[65536] = 2
  bp063Check(system.Sys_PageIn(memory, len(memory)) == 12 and state.checksum == 12, "four-pass page-in checksum")

  system.Sys_SetCounterFixture(1000000, [100, 1000100])
  state.arguments = [""]
  system.Sys_Init()
  counterTime = system.Sys_FloatTime()
  bp063Check(counterTime > 0.9999 and counterTime < 1.0002, "performance-counter time base")

  state = stateForTest()
  state.isDedicated = true
  system.Sys_ConsoleInject(104, false)
  system.Sys_ConsoleInject(105, false)
  system.Sys_ConsoleInject(8, false)
  system.Sys_ConsoleInject(111, false)
  system.Sys_ConsoleInject(13, false)
  bp063Check(system.Sys_ConsoleInput() == "ho", "dedicated console line editing")
  state.scReturnOnEnter = true
  system.Sys_ConsoleInject(13, false)
  bp063Check(system.Sys_ConsoleInput() == "\r", "empty Enter escapes error handler")
  bp063Check(system.Sys_Sleep() and state.sleptMilliseconds == 1, "one-millisecond Sys_Sleep")
  bp063Check(system.SleepUntilInput(50) and state.sleptMilliseconds == 51, "message-aware input sleep accounting")
  bp063Check(system.Sys_SendKeyEvents() and state.sentKeyEvents == 1, "message-pump accounting")

  bp063Check(conproc.InitConProc(10, 20, 30, false), "QHOST test initialization")
  cp = conproc.ConProc_State()
  conproc.ConProc_SetTestBuffer([conproc.CCOM_WRITE_TEXT, "go\n"])
  bp063Check(conproc.RequestProc(false) and len(cp.inputEvents) == 6, "QHOST write-text request")
  cp.consoleLines = ["zero", "one", "two"]
  conproc.ConProc_SetTestBuffer([conproc.CCOM_GET_TEXT, 1, 2])
  bp063Check(conproc.RequestProc(false) and len(bytes(conproc.ConProc_RequestBuffer()[1])) == 160, "QHOST inclusive text request")
  conproc.ConProc_SetTestBuffer([conproc.CCOM_GET_SCR_LINES])
  bp063Check(conproc.RequestProc(false) and conproc.ConProc_RequestBuffer()[1] == 25, "QHOST get screen lines")
  conproc.ConProc_SetTestBuffer([conproc.CCOM_SET_SCR_LINES, 35])
  bp063Check(conproc.RequestProc(false) and cp.screenHeight == 35, "QHOST set screen lines")
  bp063Check(conproc.CharToCode(13) == 28 and conproc.CharToCode(97) == 30 and conproc.CharToCode(57) == 11, "console scan-code mapping")
  conproc.DeinitConProc()

  state = stateForTest()
  system.Sys_SetCounterFixture(1000000, [100])
  result = system.WinMain(["", "-dedicated", "-HFILE", "10", "-HPARENT", "20", "-HCHILD", "30"], runner)
  bp063Check(result == 17 and fixtureArguments[1] == "-dedicated" and state.quitRequested, "WinMain initialization and runner lifecycle")

  if failures > 0 then print "MiniQuake BP-063 system/platform tests failed: " + failures + "/21"; return 1 end if
  print "MiniQuake BP-063 system/platform tests passed: 21"
  return 0
end function
