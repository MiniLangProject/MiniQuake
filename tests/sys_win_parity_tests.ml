/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused sys_win.c/sys.h/winquake.h parity fixtures.
*/

import miniquake.sys_win as system
import miniquake.conproc as conproc
import std.fs as fs

runnerArguments = []

function assertEqual(actual, expected, name)
  if actual != expected then return error(9900, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertNear(actual, expected, epsilon, name)
  if actual < expected - epsilon or actual > expected + epsilon then
    return error(9901, name + ": expected " + expected + ", got " + actual)
  end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9902, name + ": expected true") end if
  return true
end function

function useTestState()
  state = system.Sys_CreateState(false)
  system.Sys_UseState(state)
  return state
end function

function fixtureRunner(arguments)
  global runnerArguments
  runnerArguments = arguments
  return 7
end function

function testCommandLineAndWinMain()
  state = useTestState()
  parsed = system.Sys_ParseCommandLine("  -dedicated\t-heapsize 4096  +map start")
  assertEqual(parsed, ["", "-dedicated", "-heapsize", "4096", "+map", "start"], "WinMain whitespace parser")
  assertEqual(system.Sys_SelectMemorySize(1024, 64 * 1024 * 1024, parsed), 4096 * 1024, "-heapsize override")
  assertEqual(system.Sys_SelectMemorySize(1024, 16 * 1024 * 1024, []), system.MINIMUM_WIN_MEMORY, "minimum Win memory")
  system.Sys_SetCounterFixture(1000000, [100])
  result = system.WinMain(parsed, fixtureRunner)
  assertEqual(result, 7, "WinMain runner result")
  assertEqual(runnerArguments, parsed, "WinMain forwards argv")
  assertEqual(state.isDedicated, true, "dedicated detection")
  assertEqual(state.memorySize, 4096 * 1024, "WinMain memory choice")
  assertEqual(state.initialized, true, "Sys_Init completed")
  return true
end function

function testPageIn()
  state = useTestState()
  memory = bytes(65540)
  memory[0] = 1
  memory[65536] = 2
  assertEqual(system.Sys_PageIn(memory, len(memory)), 12, "four-pass page-in checksum")
  assertEqual(state.checksum, 12, "volatile checksum state")
  return true
end function

function testFileIo()
  useTestState()
  path = "build\\sys_win_fixture.tmp"
  writeHandle = system.Sys_FileOpenWrite(path)
  assertTrue(writeHandle > 0, "open write")
  assertEqual(system.Sys_FileWrite(writeHandle, bytes("abcdef"), 6), 6, "file write")
  assertTrue(system.Sys_FileClose(writeHandle), "close write")
  assertEqual(system.Sys_FileTime(path), 1, "file time present")

  opened = system.Sys_FileOpenRead(path)
  assertEqual(opened[0], 6, "open read length")
  readHandle = opened[1]
  first = bytes(3)
  assertEqual(system.Sys_FileRead(readHandle, first, 3), 3, "file read")
  assertEqual(decode(first), "abc", "file read contents")
  assertTrue(system.Sys_FileSeek(readHandle, 2), "file seek")
  middle = bytes(2)
  assertEqual(system.Sys_FileRead(readHandle, middle, 2), 2, "file read after seek")
  assertEqual(decode(middle), "cd", "seek contents")
  assertTrue(system.Sys_FileClose(readHandle), "close read")
  assertEqual(system.Sys_FileTime("build\\sys_win_missing.tmp"), -1, "file time missing")
  return true
end function

function testHandleTable()
  state = useTestState()
  index = 1
  while index < system.MAX_HANDLES
    state.handles[index] = index
    index = index + 1
  end while
  exhausted = try(system.findhandle())
  assertTrue(exhausted is error, "ten-slot handle table exhaustion")
  assertEqual(state.errorText, "out of handles", "handle exhaustion error")
  return true
end function

function testFloatTime()
  state = useTestState()
  state.arguments = ["", "-starttime", "3.5"]
  system.Sys_SetCounterFixture(2000000, [100, 1000100, 900000, 0x10])
  assertTrue(system.Sys_Init(), "timer init")
  assertEqual(state.lowshift, 0, "two MHz timer shift")
  assertNear(system.Sys_FloatTime(), 4.0, 0.000001, "timer delta")
  assertNear(system.Sys_FloatTime(), 4.0, 0.000001, "backward timer reset")
  state.oldtime = 0xfffffff0
  assertNear(system.Sys_FloatTime(), 4.000016, 0.000001, "32-bit timer wrap")
  return true
end function

function testConsoleInput()
  state = useTestState()
  state.isDedicated = true
  system.Sys_ConsoleInject(120, true)
  system.Sys_ConsoleInject(104, false)
  system.Sys_ConsoleInject(105, false)
  system.Sys_ConsoleInject(8, false)
  system.Sys_ConsoleInject(111, false)
  system.Sys_ConsoleInject(13, false)
  assertEqual(system.Sys_ConsoleInput(), "ho", "dedicated line editing")
  assertEqual(state.outputLog, "hi\b \bo\r\n", "dedicated console echo")
  state.scReturnOnEnter = true
  system.Sys_ConsoleInject(13, false)
  assertEqual(system.Sys_ConsoleInput(), "\r", "error-handler empty Enter")
  return true
end function

function testQHostPolling()
  state = useTestState()
  state.isDedicated = true
  assertTrue(conproc.InitConProc(10, 20, 30, false), "QHOST initialization")
  conproc.ConProc_SetTestBuffer([conproc.CCOM_SET_SCR_LINES, 33])
  assertEqual(system.Sys_ConsoleInput(), void, "QHOST poll without console line")
  assertEqual(conproc.ConProc_RequestBuffer()[0], true, "QHOST request response")
  assertEqual(conproc.ConProc_State().screenHeight, 33, "QHOST request serviced")
  return true
end function

function testSystemHooks()
  state = useTestState()
  assertTrue(system.Sys_MakeCodeWriteable(4096, 128), "diagnostic writable request")
  assertEqual(state.codeWriteRequests[0], [4096, 128], "writable request trace")
  assertTrue(system.Sys_SetFPCW(), "FPCW setup")
  assertTrue(system.Sys_PushFPCW_SetHigh(), "high FPCW")
  assertTrue(system.Sys_PopFPCW(), "restore FPCW")
  assertTrue(system.MaskExceptions(), "mask exceptions")
  assertTrue(system.Sys_Sleep(), "one millisecond sleep")
  assertTrue(system.SleepUntilInput(50), "message wait")
  assertEqual(state.sleptMilliseconds, 51, "sleep accounting")
  assertTrue(system.Sys_SendKeyEvents(), "test message pump")
  assertEqual(state.sentKeyEvents, 1, "message pump count")
  return true
end function

function testErrorAndQuit()
  state = useTestState()
  state.isDedicated = true
  failed = try(system.Sys_Error("fixture failure"))
  assertTrue(failed is error, "Sys_Error value")
  assertEqual(state.errorText, "fixture failure", "Sys_Error text")
  assertEqual(state.scReturnOnEnter, true, "Sys_Error console escape")
  assertTrue(system.Sys_Quit(), "Sys_Quit")
  assertEqual(state.quitRequested, true, "quit state")
  return true
end function

function main(args)
  testCommandLineAndWinMain()
  testPageIn()
  testFileIo()
  testHandleTable()
  testFloatTime()
  testConsoleInput()
  testQHostPolling()
  testSystemHooks()
  testErrorAndQuit()
  print "sys_win parity tests: 9/9 passed"
  return 0
end function
