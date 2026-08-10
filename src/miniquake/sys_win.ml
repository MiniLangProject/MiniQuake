/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

MiniLang port of sys_win.c, sys.h and the applicable winquake.h hooks.
The Win32 bridge contains only primitives; handle policy, timing quirks,
console editing, command-line parsing and lifecycle remain here.
*/

package miniquake.sys_win

import miniquake.conproc as conproc
import miniquake.native as native
import miniquake.platform.win32 as win
import std.fs as fs

const MINIMUM_WIN_MEMORY = 0x0880000
const MAXIMUM_WIN_MEMORY = 0x1000000
const CONSOLE_ERROR_TIMEOUT = 60.0
const PAUSE_SLEEP = 50
const NOT_FOCUS_SLEEP = 20
const MAX_HANDLES = 10
const FILE_BEGIN = 0
const INVALID_SET_FILE_POINTER = 0xffffffff

extern function SetFilePointer(
  handle as ptr,
  distance as i32,
  distanceHigh as ptr,
  moveMethod as u32
) from "kernel32.dll" returns u32

extern function CreateDirectoryW(
  path as wstr,
  security as ptr
) from "kernel32.dll" returns bool

struct SysWinState
  useNative
  handles
  checksum
  ActiveApp
  Minimized
  WinNT
  isDedicated
  scReturnOnEnter
  outputLog
  consoleBuffer
  consoleLength
  consoleEvents
  pfreq
  lowshift
  curtime
  lastcurtime
  oldtime
  firstTime
  sameTimeCount
  counterQueue
  testFrequency
  arguments
  memorySize
  availableMemory
  totalMemory
  quitRequested
  errorText
  initialized
  codeWriteRequests
  sentKeyEvents
  sleptMilliseconds
  hFile
  hParent
  hChild
end struct

sysWinState = void

function emptyHandles()
  return array(MAX_HANDLES, 0)
end function

function Sys_CreateState(useNative)
  return SysWinState(
    useNative,
    emptyHandles(),
    0,
    true,
    false,
    true,
    false,
    false,
    "",
    bytes(256),
    0,
    [],
    0.0,
    0,
    0.0,
    0.0,
    0,
    true,
    0,
    [],
    0,
    [],
    MINIMUM_WIN_MEMORY,
    MAXIMUM_WIN_MEMORY,
    MAXIMUM_WIN_MEMORY * 2,
    false,
    "",
    false,
    [],
    0,
    0,
    0,
    0,
    0
  )
end function

function Sys_UseState(state)
  global sysWinState
  sysWinState = state
  return state
end function

function Sys_State()
  global sysWinState
  if sysWinState is void then sysWinState = Sys_CreateState(true) end if
  return sysWinState
end function

function signed32(value)
  value = value & 0xffffffff
  if value >= 0x80000000 then return value - 0x100000000 end if
  return value
end function

function readI32(data, offset)
  value = data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24)
  return signed32(value)
end function

function inline readU32(data)
  return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)
end function

function Sys_PageIn(memory, size)
  state = Sys_State()
  if memory is void or typeof(memory) != "bytes" then return Sys_Error("Sys_PageIn: invalid memory") end if
  if size > len(memory) then size = len(memory) end if
  pageOffset = 16 * 0x1000
  pass = 0
  while pass < 4
    offset = 0
    while offset < size - pageOffset
      if offset + pageOffset + 3 >= size then break end if
      state.checksum = signed32(state.checksum + readI32(memory, offset))
      state.checksum = signed32(state.checksum + readI32(memory, offset + pageOffset))
      offset = offset + 4
    end while
    pass = pass + 1
  end while
  return state.checksum
end function

function findhandle()
  state = Sys_State()
  index = 1
  while index < MAX_HANDLES
    if state.handles[index] == 0 then return index end if
    index = index + 1
  end while
  return Sys_Error("out of handles")
end function

function validHandle(index)
  state = Sys_State()
  return index > 0 and index < MAX_HANDLES and state.handles[index] != 0
end function

function filelength(handle)
  state = Sys_State()
  if not validHandle(handle) then return -1 end if
  size = bytes(8)
  if not fs.GetFileSizeEx(state.handles[handle], size) then return -1 end if
  high = readU32(slice(size, 4, 4))
  low = readU32(size)
  if high != 0 or low > 0x7fffffff then return -1 end if
  return low
end function

function Sys_FileOpenRead(path)
  state = Sys_State()
  index = findhandle()
  if index is error then return index end if
  handle = fs.CreateFileW(
    path,
    fs.Access.GENERIC_READ,
    fs.Share.FILE_SHARE_READ,
    0,
    fs.Creation.OPEN_EXISTING,
    fs.FileAttr.FILE_ATTRIBUTE_NORMAL,
    0
  )
  if handle == fs.INVALID_HANDLE_VALUE then return [-1, -1] end if
  state.handles[index] = handle
  return [filelength(index), index]
end function

function Sys_FileOpenWrite(path)
  state = Sys_State()
  index = findhandle()
  if index is error then return index end if
  handle = fs.CreateFileW(
    path,
    fs.Access.GENERIC_WRITE,
    fs.Share.NONE,
    0,
    fs.Creation.CREATE_ALWAYS,
    fs.FileAttr.FILE_ATTRIBUTE_NORMAL,
    0
  )
  if handle == fs.INVALID_HANDLE_VALUE then return Sys_Error("Error opening " + path) end if
  state.handles[index] = handle
  return index
end function

function Sys_FileClose(handle)
  state = Sys_State()
  if not validHandle(handle) then return false end if
  result = fs.CloseHandle(state.handles[handle])
  state.handles[handle] = 0
  return result
end function

function Sys_FileSeek(handle, position)
  state = Sys_State()
  if not validHandle(handle) then return false end if
  result = SetFilePointer(state.handles[handle], position, 0, FILE_BEGIN)
  return result != INVALID_SET_FILE_POINTER
end function

function Sys_FileRead(handle, destination, count)
  state = Sys_State()
  if not validHandle(handle) or typeof(destination) != "bytes" then return -1 end if
  if count > len(destination) then count = len(destination) end if
  if count < 0 then return -1 end if
  readCount = bytes(4)
  if not fs.ReadFile(state.handles[handle], destination, count, readCount, 0) then return -1 end if
  return readU32(readCount)
end function

function Sys_FileWrite(handle, data, count)
  state = Sys_State()
  if not validHandle(handle) or typeof(data) != "bytes" then return -1 end if
  if count > len(data) then count = len(data) end if
  if count < 0 then return -1 end if
  written = bytes(4)
  if not fs.WriteFile(state.handles[handle], data, count, written, 0) then return -1 end if
  return readU32(written)
end function

function Sys_FileTime(path)
  if fs.isFile(path) then return 1 end if
  return -1
end function

function Sys_mkdir(path)
  if fs.isDir(path) then return true end if
  return CreateDirectoryW(path, 0)
end function

function Sys_MakeCodeWriteable(startAddress, length)
  state = Sys_State()
  state.codeWriteRequests = state.codeWriteRequests + [[startAddress, length]]
  if not state.useNative then
    if startAddress == 0 or length <= 0 then return Sys_Error("Protection change failed") end if
    return true
  end if
  if native.sysMakeCodeWriteable(startAddress, length) == 0 then return Sys_Error("Protection change failed") end if
  return true
end function

function Sys_SetFPCW()
  return true
end function

function inline Sys_PushFPCW_SetHigh()
  return true
end function

function inline Sys_PopFPCW()
  return true
end function

function MaskExceptions()
  return true
end function

function listTail(values)
  result = []
  index = 1
  while index < len(values)
    result = result + [values[index]]
    index = index + 1
  end while
  return result
end function

function nextCounter()
  state = Sys_State()
  if state.counterQueue is not void and len(state.counterQueue) > 0 then
    value = state.counterQueue[0]
    if len(state.counterQueue) == 1 then
      state.counterQueue = []
    else
      state.counterQueue = listTail(state.counterQueue)
    end if
    return value
  end if
  if not state.useNative then return 0 end if
  return native.sysCounter()
end function

function Sys_SetCounterFixture(frequency, counters)
  state = Sys_State()
  state.testFrequency = frequency
  state.counterQueue = counters
  state.firstTime = true
  state.oldtime = 0
  return true
end function

function argumentIndex(arguments, name)
  index = 0
  while index < len(arguments)
    if arguments[index] == name then return index end if
    index = index + 1
  end while
  return -1
end function

function Sys_Init()
  state = Sys_State()
  MaskExceptions()
  Sys_SetFPCW()
  frequency = state.testFrequency
  if frequency == 0 then frequency = native.sysFrequency() end if
  if frequency <= 0 then return Sys_Error("No hardware timer available") end if
  lowpart = frequency & 0xffffffff
  highpart = (frequency >> 32) & 0xffffffff
  state.lowshift = 0
  while highpart != 0 or lowpart > 2000000
    state.lowshift = state.lowshift + 1
    lowpart = (lowpart >> 1) | ((highpart & 1) << 31)
    highpart = highpart >> 1
  end while
  state.pfreq = 1.0 / lowpart
  Sys_InitFloatTime()
  state.WinNT = true
  state.initialized = true
  return true
end function

function Sys_Error(text)
  state = Sys_State()
  state.errorText = text
  state.quitRequested = true
  if state.isDedicated then
    Sys_Printf("\n***********************************\nERROR: " + text + "\nPress Enter to exit\n***********************************\n")
    state.scReturnOnEnter = true
  end if
  conproc.DeinitConProc()
  return error(2500, text)
end function

function Sys_Printf(text)
  state = Sys_State()
  state.outputLog = state.outputLog + text
  if state.isDedicated and state.useNative then native.sysConsoleWrite(text) end if
  return true
end function

function Sys_Quit()
  state = Sys_State()
  state.quitRequested = true
  conproc.DeinitConProc()
  if state.isDedicated and state.useNative then native.sysConsoleFree() end if
  return true
end function

function Sys_FloatTime()
  state = Sys_State()
  Sys_PushFPCW_SetHigh()
  counter = nextCounter()
  temp = (counter >> state.lowshift) & 0xffffffff
  if state.firstTime then
    state.oldtime = temp
    state.firstTime = false
  else
    if temp <= state.oldtime and (state.oldtime - temp) < 0x10000000 then
      state.oldtime = temp
    else
      elapsed = (temp - state.oldtime) & 0xffffffff
      state.oldtime = temp
      state.curtime = state.curtime + elapsed * state.pfreq
      if state.curtime == state.lastcurtime then
        state.sameTimeCount = state.sameTimeCount + 1
        if state.sameTimeCount > 100000 then
          state.curtime = state.curtime + 1.0
          state.sameTimeCount = 0
        end if
      else
        state.sameTimeCount = 0
      end if
      state.lastcurtime = state.curtime
    end if
  end if
  Sys_PopFPCW()
  return state.curtime
end function

function Sys_InitFloatTime()
  state = Sys_State()
  Sys_FloatTime()
  index = argumentIndex(state.arguments, "-starttime")
  if index >= 0 and index + 1 < len(state.arguments) then
    value = toNumber(state.arguments[index + 1])
    if value is void then value = 0.0 end if
    state.curtime = value * 1.0
  else
    state.curtime = 0.0
  end if
  state.lastcurtime = state.curtime
  return state.curtime
end function

function Sys_ConsoleInject(character, keyDown)
  state = Sys_State()
  state.consoleEvents = state.consoleEvents + [[keyDown, character]]
  return true
end function

function popConsoleEvent()
  state = Sys_State()
  if len(state.consoleEvents) > 0 then
    event = state.consoleEvents[0]
    if len(state.consoleEvents) == 1 then
      state.consoleEvents = []
    else
      state.consoleEvents = listTail(state.consoleEvents)
    end if
    return event
  end if
  if not state.useNative then return void end if
  encoded = native.sysConsoleEventPop()
  if (encoded & 0x80000000) == 0 then return void end if
  return [(encoded & 0x00010000) != 0, encoded & 255]
end function

function Sys_ConsoleInput()
  state = Sys_State()
  if not state.isDedicated then return void end if
  /*
  MiniQuake gives QHOST a dedicated RequestProc thread.  MiniLang keeps the
  command decoding in MiniLang and uses a non-blocking native event wait, so
  service one synchronous QHOST request from every dedicated-console pass.
  QHOST waits for the child event before issuing another request.
  */
  conproc.ConProc_Poll()
  while true
    event = popConsoleEvent()
    if event is void then break end if
    keyDown = event[0]
    character = event[1]
    if not keyDown then
      if character == 13 then
        Sys_Printf("\r\n")
        if state.consoleLength != 0 then
          result = decode(slice(state.consoleBuffer, 0, state.consoleLength))
          state.consoleLength = 0
          return result
        else if state.scReturnOnEnter then
          return "\r"
        end if
      else if character == 8 then
        Sys_Printf("\b \b")
        if state.consoleLength != 0 then state.consoleLength = state.consoleLength - 1 end if
      else if character >= 32 then
        Sys_Printf(native.asciiChar(character))
        state.consoleBuffer[state.consoleLength] = character
        state.consoleLength = (state.consoleLength + 1) & 255
      end if
    end if
  end while
  return void
end function

function Sys_Sleep()
  state = Sys_State()
  state.sleptMilliseconds = state.sleptMilliseconds + 1
  if state.useNative then win.sleep(1) end if
  return true
end function

function Sys_SendKeyEvents()
  state = Sys_State()
  state.sentKeyEvents = state.sentKeyEvents + 1
  if state.useNative then
    running = win.poll()
    state.ActiveApp = win.hasFocus()
    state.Minimized = win.minimized()
    return running
  end if
  return not state.quitRequested
end function

function SleepUntilInput(time)
  state = Sys_State()
  if time < 0 then time = 0 end if
  state.sleptMilliseconds = state.sleptMilliseconds + time
  if state.useNative then native.sysSleepUntilInput(time) end if
  return true
end function

function Sys_ParseCommandLine(commandLine)
  source = bytes(commandLine)
  arguments = [""]
  index = 0
  while index < len(source)
    while index < len(source) and (source[index] <= 32 or source[index] > 126)
      index = index + 1
    end while
    if index >= len(source) then break end if
    start = index
    while index < len(source) and source[index] > 32 and source[index] <= 126
      index = index + 1
    end while
    arguments = arguments + [decode(slice(source, start, index - start))]
  end while
  return arguments
end function

function Sys_SelectMemorySize(available, total, arguments)
  size = available
  if size < MINIMUM_WIN_MEMORY then size = MINIMUM_WIN_MEMORY end if
  half = total >> 1
  if size < half then size = half end if
  if size > MAXIMUM_WIN_MEMORY then size = MAXIMUM_WIN_MEMORY end if
  heapIndex = argumentIndex(arguments, "-heapsize")
  if heapIndex >= 0 and heapIndex + 1 < len(arguments) then
    requested = toNumber(arguments[heapIndex + 1])
    if requested is not void then size = native.trunc(requested) * 1024 end if
  end if
  return size
end function

function handleArgument(arguments, name)
  index = argumentIndex(arguments, name)
  if index < 0 or index + 1 >= len(arguments) then return 0 end if
  value = toNumber(arguments[index + 1])
  if value is void then return 0 end if
  return native.trunc(value)
end function

function WinMain(arguments, runner)
  state = Sys_State()
  if typeof(arguments) == "string" then arguments = Sys_ParseCommandLine(arguments) end if
  state.arguments = arguments
  state.isDedicated = argumentIndex(arguments, "-dedicated") >= 0
  state.memorySize = Sys_SelectMemorySize(state.availableMemory, state.totalMemory, arguments)
  state.hFile = handleArgument(arguments, "-HFILE")
  state.hParent = handleArgument(arguments, "-HPARENT")
  state.hChild = handleArgument(arguments, "-HCHILD")
  if state.isDedicated and state.useNative then
    if native.sysConsoleAlloc() == 0 then return Sys_Error("Couldn't create dedicated server console") end if
  end if
  if state.hFile != 0 and state.hParent != 0 and state.hChild != 0 then
    conproc.InitConProc(state.hFile, state.hParent, state.hChild, state.useNative)
  end if
  initialized = Sys_Init()
  if initialized is error then return initialized end if
  result = runner(arguments)
  Sys_Quit()
  return result
end function

function Sys_LowFPPrecision()
  return Sys_PopFPCW()
end function

function Sys_HighFPPrecision()
  return Sys_PushFPCW_SetHigh()
end function
