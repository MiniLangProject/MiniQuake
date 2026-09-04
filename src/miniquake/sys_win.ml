/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang port of sys_win.c, sys.h and the applicable winquake.h hooks.
The Win32 bridge contains only primitives; handle policy, timing quirks,
console editing, command-line parsing and lifecycle remain here.
*/
package miniquake.sys_win

import miniquake.conproc as conproc
import miniquake.native as native
import miniquake.platform.win32 as win
import std.fs as fs

/// Defines the minimum win memory value used by `miniquake.sys_win`.
const MINIMUM_WIN_MEMORY = 0x0880000
/// Defines the maximum win memory value used by `miniquake.sys_win`.
const MAXIMUM_WIN_MEMORY = 0x1000000
/// Defines the console error timeout value used by `miniquake.sys_win`.
const CONSOLE_ERROR_TIMEOUT = 60.0
/// Defines the pause sleep value used by `miniquake.sys_win`.
const PAUSE_SLEEP = 50
/// Defines the not focus sleep value used by `miniquake.sys_win`.
const NOT_FOCUS_SLEEP = 20
/// Defines the max handles value used by `miniquake.sys_win`.
const MAX_HANDLES = 10
/// Defines the file begin value used by `miniquake.sys_win`.
const FILE_BEGIN = 0
/// Defines the invalid set file pointer value used by `miniquake.sys_win`.
const INVALID_SET_FILE_POINTER = 0xffffffff

#if TARGET_OS == "windows"
/// Move a file pointer through the Win32 filesystem API.
/// @param handle Open Win32 file handle.
/// @param distance Signed low-order seek distance.
/// @param distanceHigh Optional high-order seek-distance pointer.
/// @param moveMethod Win32 seek-origin selector.
/// @returns The resulting low-order file position or the Win32 failure value.
extern function SetFilePointer(
  handle as ptr,
  distance as i32,
  distanceHigh as ptr,
  moveMethod as u32
) from "kernel32.dll" returns u32

/// Create a directory through the Win32 wide-character filesystem API.
/// @param path Filesystem path to create.
/// @param security Optional Win32 security attributes pointer.
/// @returns True when Windows creates the directory.
extern function CreateDirectoryW(
  path as wstr,
  security as ptr
) from "kernel32.dll" returns bool
#else
/// Open a file descriptor through the POSIX filesystem API.
/// @param path Filesystem path to open.
/// @param flags POSIX access and creation flags.
/// @param mode Permission bits used when a file is created.
/// @returns A non-negative file descriptor or a negative failure result.
extern function PosixOpen(path as cstr, flags as i32, mode as u32) from "libc.so.6" symbol "open" returns i32
/// Read bytes from a POSIX file descriptor.
/// @param handle Open POSIX file descriptor.
/// @param destination Caller-owned destination buffer.
/// @param count Maximum number of bytes to read.
/// @returns Bytes read or a negative failure result.
extern function PosixRead(handle as i32, destination as bytes, count as u64) from "libc.so.6" symbol "read" returns i64
/// Write bytes to a POSIX file descriptor.
/// @param handle Open POSIX file descriptor.
/// @param data Bytes to write.
/// @param count Number of bytes to write.
/// @returns Bytes written or a negative failure result.
extern function PosixWrite(handle as i32, data as bytes, count as u64) from "libc.so.6" symbol "write" returns i64
/// Reposition a POSIX file descriptor.
/// @param handle Open POSIX file descriptor.
/// @param offset Signed seek distance.
/// @param origin POSIX seek-origin selector.
/// @returns The resulting file offset or a negative failure result.
extern function PosixSeek(handle as i32, offset as i64, origin as i32) from "libc.so.6" symbol "lseek" returns i64
/// Close a POSIX file descriptor.
/// @param handle Open POSIX file descriptor.
/// @returns Zero on success or a negative failure result.
extern function PosixClose(handle as i32) from "libc.so.6" symbol "close" returns i32
/// Create a directory through the POSIX filesystem API.
/// @param path Filesystem path to create.
/// @param mode POSIX permission bits filtered by the process umask.
/// @returns Zero on success or a negative failure result.
extern function PosixMkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
#endif

// Track mutable sys win state across subsystem calls.
struct SysWinState
  /// Stores the use native value in `miniquake.sys_win.SysWinState`.
  useNative
  /// Stores the handles value in `miniquake.sys_win.SysWinState`.
  handles
  /// Stores the checksum value in `miniquake.sys_win.SysWinState`.
  checksum
  /// Stores the active app value in `miniquake.sys_win.SysWinState`.
  ActiveApp
  /// Stores the minimized value in `miniquake.sys_win.SysWinState`.
  Minimized
  /// Stores the win nt value in `miniquake.sys_win.SysWinState`.
  WinNT
  /// Stores the is dedicated value in `miniquake.sys_win.SysWinState`.
  isDedicated
  /// Stores the sc return on enter value in `miniquake.sys_win.SysWinState`.
  scReturnOnEnter
  /// Stores the output log value in `miniquake.sys_win.SysWinState`.
  outputLog
  /// Stores the console buffer value in `miniquake.sys_win.SysWinState`.
  consoleBuffer
  /// Stores the console length value in `miniquake.sys_win.SysWinState`.
  consoleLength
  /// Stores the console events value in `miniquake.sys_win.SysWinState`.
  consoleEvents
  /// Stores the pfreq value in `miniquake.sys_win.SysWinState`.
  pfreq
  /// Stores the lowshift value in `miniquake.sys_win.SysWinState`.
  lowshift
  /// Stores the curtime value in `miniquake.sys_win.SysWinState`.
  curtime
  /// Stores the lastcurtime value in `miniquake.sys_win.SysWinState`.
  lastcurtime
  /// Stores the oldtime value in `miniquake.sys_win.SysWinState`.
  oldtime
  /// Stores the first time value in `miniquake.sys_win.SysWinState`.
  firstTime
  /// Stores the same time count value in `miniquake.sys_win.SysWinState`.
  sameTimeCount
  /// Stores the counter queue value in `miniquake.sys_win.SysWinState`.
  counterQueue
  /// Stores the test frequency value in `miniquake.sys_win.SysWinState`.
  testFrequency
  /// Stores the arguments value in `miniquake.sys_win.SysWinState`.
  arguments
  /// Stores the memory size value in `miniquake.sys_win.SysWinState`.
  memorySize
  /// Stores the available memory value in `miniquake.sys_win.SysWinState`.
  availableMemory
  /// Stores the total memory value in `miniquake.sys_win.SysWinState`.
  totalMemory
  /// Stores the quit requested value in `miniquake.sys_win.SysWinState`.
  quitRequested
  /// Stores the error text value in `miniquake.sys_win.SysWinState`.
  errorText
  /// Stores the initialized value in `miniquake.sys_win.SysWinState`.
  initialized
  /// Stores the code write requests value in `miniquake.sys_win.SysWinState`.
  codeWriteRequests
  /// Stores the sent key events value in `miniquake.sys_win.SysWinState`.
  sentKeyEvents
  /// Stores the slept milliseconds value in `miniquake.sys_win.SysWinState`.
  sleptMilliseconds
  /// Stores the h file value in `miniquake.sys_win.SysWinState`.
  hFile
  /// Stores the h parent value in `miniquake.sys_win.SysWinState`.
  hParent
  /// Stores the h child value in `miniquake.sys_win.SysWinState`.
  hChild
end struct

/// Tracks the module-level Windows system state owned by `miniquake.sys_win`.
sysWinState = void

/// Implements the `emptyHandles` operation for `miniquake.sys_win` (empty handles).
function emptyHandles()
  return array(MAX_HANDLES, 0)
end function

/// Mirror Quake's Sys_CreateState routine and its observable state changes.
/// @param useNative The use native input consumed by `Sys_CreateState`.
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

/// Mirror Quake's Sys_UseState routine and its observable state changes.
/// @param state Mutable `miniquake.sys_win` state used by `Sys_UseState`.
function Sys_UseState(state)
  global sysWinState
  sysWinState = state
  return state
end function

// Mirror Quake's Sys_State routine and its observable state changes.
function Sys_State()
  global sysWinState
  if sysWinState is void then sysWinState = Sys_CreateState(true) end if
  return sysWinState
end function

/// Implements the `signed32` operation for `miniquake.sys_win` (signed32).
/// @param value Value consumed by `signed32`.
function signed32(value)
  value = value & 0xffffffff
  if value >= 0x80000000 then return value - 0x100000000 end if
  return value
end function

/// Read and validate i32.
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
function readI32(data, offset)
  value = data[offset] | (data[offset + 1] << 8) | (data[offset + 2] << 16) | (data[offset + 3] << 24)
  return signed32(value)
end function

/// Read and validate u32.
/// @param data Input data consumed by the operation.
function inline readU32(data)
  return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)
end function

/// Mirror Quake's Sys_PageIn routine and its observable state changes.
/// @param memory The memory input consumed by `Sys_PageIn`.
/// @param size Size of the requested data or resource.
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

/// Finds handle for `miniquake.sys_win`.
function findhandle()
  state = Sys_State()
  index = 1
  while index < MAX_HANDLES
    if state.handles[index] == 0 then return index end if
    index = index + 1
  end while
  return Sys_Error("out of handles")
end function

/// Report whether valid handle.
/// @param index Zero-based index of the requested entry.
function validHandle(index)
  state = Sys_State()
  return index > 0 and index < MAX_HANDLES and state.handles[index] != 0
end function

/// Implements the `filelength` operation for `miniquake.sys_win` (filelength).
/// @param handle The handle input consumed by `filelength`.
function filelength(handle)
  state = Sys_State()
  if not validHandle(handle) then return -1 end if
#if TARGET_OS == "windows"
  size = bytes(8)
  if not fs.GetFileSizeEx(state.handles[handle], size) then return -1 end if
  high = readU32(slice(size, 4, 4))
  low = readU32(size)
  if high != 0 or low > 0x7fffffff then return -1 end if
  return low
#else
  descriptor = state.handles[handle]
  previous = PosixSeek(descriptor, 0, 1)
  if previous < 0 then return -1 end if
  size = PosixSeek(descriptor, 0, 2)
  PosixSeek(descriptor, previous, 0)
  if size < 0 or size > 0x7fffffff then return -1 end if
  return size
#endif
end function

/// Mirror Quake's Sys_FileOpenRead routine and its observable state changes.
/// @param path Filesystem path to process.
function Sys_FileOpenRead(path)
  state = Sys_State()
  index = findhandle()
  if index is error then return index end if
#if TARGET_OS == "windows"
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
#else
  handle = PosixOpen(path, 0, 0)
  if handle < 0 then return [-1, -1] end if
#endif
  state.handles[index] = handle
  return [filelength(index), index]
end function

/// Mirror Quake's Sys_FileOpenWrite routine and its observable state changes.
/// @param path Filesystem path to process.
function Sys_FileOpenWrite(path)
  state = Sys_State()
  index = findhandle()
  if index is error then return index end if
#if TARGET_OS == "windows"
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
#else
  // O_WRONLY | O_CREAT | O_TRUNC with mode 0666 filtered by the process umask.
  handle = PosixOpen(path, 577, 0x1b6)
  if handle < 0 then return Sys_Error("Error opening " + path) end if
#endif
  state.handles[index] = handle
  return index
end function

/// Mirror Quake's Sys_FileClose routine and its observable state changes.
/// @param handle The handle input consumed by `Sys_FileClose`.
function Sys_FileClose(handle)
  state = Sys_State()
  if not validHandle(handle) then return false end if
#if TARGET_OS == "windows"
  result = fs.CloseHandle(state.handles[handle])
#else
  result = PosixClose(state.handles[handle]) == 0
#endif
  state.handles[handle] = 0
  return result
end function

/// Mirror Quake's Sys_FileSeek routine and its observable state changes.
/// @param handle The handle input consumed by `Sys_FileSeek`.
/// @param position Position used by the operation.
function Sys_FileSeek(handle, position)
  state = Sys_State()
  if not validHandle(handle) then return false end if
#if TARGET_OS == "windows"
  result = SetFilePointer(state.handles[handle], position, 0, FILE_BEGIN)
  return result != INVALID_SET_FILE_POINTER
#else
  return PosixSeek(state.handles[handle], position, 0) >= 0
#endif
end function

/// Mirror Quake's Sys_FileRead routine and its observable state changes.
/// @param handle The handle input consumed by `Sys_FileRead`.
/// @param destination Destination value or collection to update.
/// @param count Number of entries or units to process.
function Sys_FileRead(handle, destination, count)
  state = Sys_State()
  if not validHandle(handle) or typeof(destination) != "bytes" then return -1 end if
  if count > len(destination) then count = len(destination) end if
  if count < 0 then return -1 end if
#if TARGET_OS == "windows"
  readCount = bytes(4)
  if not fs.ReadFile(state.handles[handle], destination, count, readCount, 0) then return -1 end if
  return readU32(readCount)
#else
  return PosixRead(state.handles[handle], destination, count)
#endif
end function

/// Mirror Quake's Sys_FileWrite routine and its observable state changes.
/// @param handle The handle input consumed by `Sys_FileWrite`.
/// @param data Input data consumed by the operation.
/// @param count Number of entries or units to process.
function Sys_FileWrite(handle, data, count)
  state = Sys_State()
  if not validHandle(handle) or typeof(data) != "bytes" then return -1 end if
  if count > len(data) then count = len(data) end if
  if count < 0 then return -1 end if
#if TARGET_OS == "windows"
  written = bytes(4)
  if not fs.WriteFile(state.handles[handle], data, count, written, 0) then return -1 end if
  return readU32(written)
#else
  return PosixWrite(state.handles[handle], data, count)
#endif
end function

/// Mirror Quake's Sys_FileTime routine and its observable state changes.
/// @param path Filesystem path to process.
function Sys_FileTime(path)
  if fs.isFile(path) then return 1 end if
  return -1
end function

/// Mirror Quake's Sys_mkdir routine and its observable state changes.
/// @param path Filesystem path to process.
function Sys_mkdir(path)
  if fs.isDir(path) then return true end if
#if TARGET_OS == "windows"
  return CreateDirectoryW(path, 0)
#else
  return PosixMkdir(path, 0x1ff) == 0 or fs.isDir(path)
#endif
end function

/// Mirror Quake's Sys_MakeCodeWriteable routine and its observable state changes.
/// @param startAddress The start address input consumed by `Sys_MakeCodeWriteable`.
/// @param length Length of the requested data in units appropriate to the operation.
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

// Mirror Quake's Sys_SetFPCW routine and its observable state changes.
function Sys_SetFPCW()
  return true
end function

// Mirror Quake's Sys_PushFPCW_SetHigh routine and its observable state changes.
function inline Sys_PushFPCW_SetHigh()
  return true
end function

// Mirror Quake's Sys_PopFPCW routine and its observable state changes.
function inline Sys_PopFPCW()
  return true
end function

/// Implements the `MaskExceptions` operation for `miniquake.sys_win` (mask exceptions).
function MaskExceptions()
  return true
end function

/// Implements the `listTail` operation for `miniquake.sys_win` (list tail).
/// @param values The values input consumed by `listTail`.
function listTail(values)
  result = []
  index = 1
  while index < len(values)
    result = result + [values[index]]
    index = index + 1
  end while
  return result
end function

// Return next counter for the active module state.
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

/// Mirror Quake's Sys_SetCounterFixture routine and its observable state changes.
/// @param frequency The frequency input consumed by `Sys_SetCounterFixture`.
/// @param counters The counters input consumed by `Sys_SetCounterFixture`.
function Sys_SetCounterFixture(frequency, counters)
  state = Sys_State()
  state.testFrequency = frequency
  state.counterQueue = counters
  state.firstTime = true
  state.oldtime = 0
  return true
end function

/// Return argument index derived from the active module state.
/// @param arguments Command-line arguments to inspect or execute.
/// @param name Stable name that identifies the requested object or option.
function argumentIndex(arguments, name)
  index = 0
  while index < len(arguments)
    if arguments[index] == name then return index end if
    index = index + 1
  end while
  return -1
end function

// Mirror Quake's Sys_Init routine and its observable state changes.
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

/// Mirror Quake's Sys_Error routine and its observable state changes.
/// @param text Text to parse or process.
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

/// Mirror Quake's Sys_Printf routine and its observable state changes.
/// @param text Text to parse or process.
function Sys_Printf(text)
  state = Sys_State()
  state.outputLog = state.outputLog + text
  if state.isDedicated and state.useNative then native.sysConsoleWrite(text) end if
  return true
end function

// Mirror Quake's Sys_Quit routine and its observable state changes.
function Sys_Quit()
  state = Sys_State()
  state.quitRequested = true
  conproc.DeinitConProc()
  if state.isDedicated and state.useNative then native.sysConsoleFree() end if
  return true
end function

// Mirror Quake's Sys_FloatTime routine and its observable state changes.
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

// Mirror Quake's Sys_InitFloatTime routine and its observable state changes.
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

/// Mirror Quake's Sys_ConsoleInject routine and its observable state changes.
/// @param character The character input consumed by `Sys_ConsoleInject`.
/// @param keyDown The key down input consumed by `Sys_ConsoleInject`.
function Sys_ConsoleInject(character, keyDown)
  state = Sys_State()
  state.consoleEvents = state.consoleEvents + [[keyDown, character]]
  return true
end function

// Consume pending state for pop console event.
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

// Mirror Quake's Sys_ConsoleInput routine and its observable state changes.
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

// Mirror Quake's Sys_Sleep routine and its observable state changes.
function Sys_Sleep()
  state = Sys_State()
  state.sleptMilliseconds = state.sleptMilliseconds + 1
  if state.useNative then win.sleep(1) end if
  return true
end function

// Mirror Quake's Sys_SendKeyEvents routine and its observable state changes.
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

/// Implements the `SleepUntilInput` operation for `miniquake.sys_win` (sleep until input).
/// @param time Simulation or presentation time for the operation.
function SleepUntilInput(time)
  state = Sys_State()
  if time < 0 then time = 0 end if
  state.sleptMilliseconds = state.sleptMilliseconds + time
  if state.useNative then native.sysSleepUntilInput(time) end if
  return true
end function

/// Mirror Quake's Sys_ParseCommandLine routine and its observable state changes.
/// @param commandLine The command line input consumed by `Sys_ParseCommandLine`.
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

/// Mirror Quake's Sys_SelectMemorySize routine and its observable state changes.
/// @param available The available input consumed by `Sys_SelectMemorySize`.
/// @param total The total input consumed by `Sys_SelectMemorySize`.
/// @param arguments Command-line arguments to inspect or execute.
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

/// Handle argument and update the associated state.
/// @param arguments Command-line arguments to inspect or execute.
/// @param name Stable name that identifies the requested object or option.
function handleArgument(arguments, name)
  index = argumentIndex(arguments, name)
  if index < 0 or index + 1 >= len(arguments) then return 0 end if
  value = toNumber(arguments[index + 1])
  if value is void then return 0 end if
  return native.trunc(value)
end function

/// Implements the `WinMain` operation for `miniquake.sys_win` (win main).
/// @param arguments Command-line arguments to inspect or execute.
/// @param runner The runner input consumed by `WinMain`.
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

// Mirror Quake's Sys_LowFPPrecision routine and its observable state changes.
function Sys_LowFPPrecision()
  return Sys_PopFPCW()
end function

// Mirror Quake's Sys_HighFPPrecision routine and its observable state changes.
function Sys_HighFPPrecision()
  return Sys_PushFPCW_SetHigh()
end function
