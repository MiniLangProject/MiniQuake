/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/sys_win_differential_fixture.ml.
*/
import miniquake.sys_win as system
import miniquake.native as native
import std.fs as fs

runnerCalls = 0

// Exercise bool int as part of this deterministic regression fixture.
function boolInt(value)
  if value then return 1 end if
  return 0
end function

// Add the requested value to the destination state.
function emit(functionName, caseName, result, index, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"index\":" + index +
    ",\"value\":" + value + ",\"count\":" + count + "}"
end function

// Return use state derived from the active module state.
function useState()
  state = system.Sys_CreateState(false)
  system.Sys_UseState(state)
  return state
end function

// Exercise runner as part of this deterministic regression fixture.
function runner(arguments)
  global runnerCalls
  runnerCalls = runnerCalls + 1
  return 1
end function

// Report mode and return the corresponding failure status.
function errorMode(mode)
  state = useState()
  result = void
  if mode == "--error-handles" then
    index = 1
    while index < system.MAX_HANDLES
      state.handles[index] = index
      index = index + 1
    end while
    result = try(system.findhandle())
  else if mode == "--error-protect" then
    result = try(system.Sys_MakeCodeWriteable(0, 128))
  else if mode == "--error-timer" then
    state.testFrequency = -1
    result = try(system.Sys_Init())
  else
    result = try(system.Sys_FileOpenWrite("build\\sys_win_differential\\missing\\file.tmp"))
  end if
  if result is error then return 42 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 then return errorMode(args[0]) end if

  state = useState()
  memory = bytes(65540)
  memory[0] = 1
  memory[65536] = 2
  result = system.Sys_PageIn(memory, len(memory))
  emit("Sys_PageIn", "four_pass", result, 0, 0, 4)

  state = useState()
  emit("findhandle", "first_free", system.findhandle(), 1, 9, 1)

  state = useState()
  path = "build\\sys_win_differential\\candidate.tmp"
  handle = system.Sys_FileOpenWrite(path)
  system.Sys_FileWrite(handle, bytes("abcdef"), 6)
  system.Sys_FileClose(handle)
  opened = system.Sys_FileOpenRead(path)
  readHandle = opened[1]
  system.Sys_FileSeek(readHandle, 2)
  length = system.filelength(readHandle)
  positionByte = bytes(1)
  system.Sys_FileRead(readHandle, positionByte, 1)
  emit("filelength", "restore_position", length, positionByte[0], 7, 1)
  system.Sys_FileClose(readHandle)

  state = useState()
  opened = system.Sys_FileOpenRead(path)
  emit("Sys_FileOpenRead", "success", opened[0], opened[1], 1, 2)
  system.Sys_FileClose(opened[1])

  state = useState()
  handle = system.Sys_FileOpenWrite(path)
  emit("Sys_FileOpenWrite", "success", handle, 1,
    boolInt(state.handles[handle] != 0), 1)

  closed = system.Sys_FileClose(handle)
  emit("Sys_FileClose", "clear", boolInt(state.handles[handle] == 0), 0, 7, 2)

  handle = system.Sys_FileOpenWrite(path)
  system.Sys_FileWrite(handle, bytes("abcdef"), 6)
  system.Sys_FileClose(handle)
  opened = system.Sys_FileOpenRead(path)
  readHandle = opened[1]
  system.Sys_FileSeek(readHandle, 4)
  seekByte = bytes(1)
  system.Sys_FileRead(readHandle, seekByte, 1)
  emit("Sys_FileSeek", "absolute", seekByte[0], 7, 1, 1)
  system.Sys_FileClose(readHandle)

  opened = system.Sys_FileOpenRead(path)
  readHandle = opened[1]
  readBuffer = bytes(3)
  readCount = system.Sys_FileRead(readHandle, readBuffer, 3)
  emit("Sys_FileRead", "bytes", readCount,
    readBuffer[0] * 100 + readBuffer[2], 3, 2)
  system.Sys_FileClose(readHandle)

  handle = system.Sys_FileOpenWrite(path)
  writeCount = system.Sys_FileWrite(handle, bytes("XYZ"), 3)
  system.Sys_FileClose(handle)
  opened = system.Sys_FileOpenRead(path)
  verify = bytes(3)
  system.Sys_FileRead(opened[1], verify, 3)
  system.Sys_FileClose(opened[1])
  emit("Sys_FileWrite", "bytes", writeCount, verify[0], len(verify), 1)

  emit("Sys_FileTime", "present", system.Sys_FileTime(path), 0, 7, 1)

  directory = "build\\sys_win_differential\\fixture_dir"
  mkdirResult = system.Sys_mkdir(directory)
  emit("Sys_mkdir", "delegate", boolInt(mkdirResult), 0, 0, 1)

  state = useState()
  protectResult = system.Sys_MakeCodeWriteable(4096, 128)
  emit("Sys_MakeCodeWriteable", "protect", boolInt(protectResult),
    state.codeWriteRequests[0][0], state.codeWriteRequests[0][1], 1)

  emit("MaskExceptions", "x64_noop", boolInt(system.MaskExceptions()), 0, 0, 1)
  emit("Sys_SetFPCW", "x64_noop", boolInt(system.Sys_SetFPCW()), 0, 0, 1)
  emit("Sys_PushFPCW_SetHigh", "x64_noop",
    boolInt(system.Sys_PushFPCW_SetHigh()), 0, 0, 1)
  emit("Sys_PopFPCW", "x64_noop", boolInt(system.Sys_PopFPCW()), 0, 0, 1)

  state = useState()
  state.arguments = [""]
  system.Sys_SetCounterFixture(4000000, [100])
  initialized = system.Sys_Init()
  emit("Sys_Init", "timer_and_os", boolInt(initialized), state.lowshift,
    boolInt(state.WinNT), native.trunc(state.pfreq * 4000000.0))

  state = useState()
  state.arguments = ["", "-starttime", "3.5"]
  system.Sys_SetCounterFixture(1000000, [100])
  startValue = system.Sys_InitFloatTime()
  emit("Sys_InitFloatTime", "starttime", native.trunc(startValue * 1000.0),
    3, 500, 1)

  state = useState()
  state.pfreq = 0.000001
  state.lowshift = 0
  system.Sys_SetCounterFixture(1000000, [100, 1000100])
  system.Sys_FloatTime()
  elapsed = system.Sys_FloatTime()
  emit("Sys_FloatTime", "delta", native.trunc(elapsed * 1000.0), 1000, 0, 1)

  state = useState()
  state.isDedicated = true
  system.Sys_ConsoleInject(120, true)
  system.Sys_ConsoleInject(104, false)
  system.Sys_ConsoleInject(105, false)
  system.Sys_ConsoleInject(8, false)
  system.Sys_ConsoleInject(111, false)
  system.Sys_ConsoleInject(13, false)
  line = system.Sys_ConsoleInput()
  emit("Sys_ConsoleInput", "line_edit", boolInt(line == "ho"),
    bytes(line)[0], bytes(line)[1], 5)

  state = useState()
  state.isDedicated = true
  system.Sys_Printf("hello")
  emit("Sys_Printf", "dedicated", len(state.outputLog), 1,
    len(state.outputLog), 1)

  state = useState()
  failed = try(system.Sys_Error("fixture failure"))
  emit("Sys_Error", "shutdown", boolInt(failed is error),
    boolInt(state.errorText == "fixture failure"), boolInt(state.quitRequested), 1)

  state = useState()
  state.isDedicated = true
  system.Sys_Quit()
  emit("Sys_Quit", "shutdown", 0, boolInt(state.quitRequested),
    boolInt(state.isDedicated), 1)

  state = useState()
  system.Sys_Sleep()
  emit("Sys_Sleep", "one_ms", state.sleptMilliseconds, 1, 0, 1)

  state = useState()
  running = system.Sys_SendKeyEvents()
  emit("Sys_SendKeyEvents", "pump", 0, state.sentKeyEvents,
    boolInt(running), 1)

  state = useState()
  system.SleepUntilInput(50)
  emit("SleepUntilInput", "wait", state.sleptMilliseconds, 1, 0, 1)

  state = useState()
  global runnerCalls
  runnerCalls = 0
  state.availableMemory = 1024
  state.totalMemory = 64 * 1024 * 1024
  system.Sys_SetCounterFixture(1000000, [0, 100000, 200000])
  winResult = system.WinMain("-dedicated -heapsize 4096", runner)
  emit("WinMain", "dedicated_one_frame", winResult,
    len(state.arguments), state.memorySize / 1024, runnerCalls)
  return 0
end function
