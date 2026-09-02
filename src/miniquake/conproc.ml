/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang port of conproc.c/conproc.h.  The four QHOST commands and all state
transitions remain here; native code only exposes Win32 mappings, events and
console primitives.
*/
package miniquake.conproc

import miniquake.native as native

/// Defines the ccom write text value used by `miniquake.conproc`.
const CCOM_WRITE_TEXT = 0x2
/// Defines the ccom get text value used by `miniquake.conproc`.
const CCOM_GET_TEXT = 0x3
/// Defines the ccom get scr lines value used by `miniquake.conproc`.
const CCOM_GET_SCR_LINES = 0x4
/// Defines the ccom set scr lines value used by `miniquake.conproc`.
const CCOM_SET_SCR_LINES = 0x5
/// Defines the infinite value used by `miniquake.conproc`.
const INFINITE = 0xffffffff

// Track mutable con proc state across subsystem calls.
struct ConProcState
  /// Stores the file buffer value in `miniquake.conproc.ConProcState`.
  fileBuffer
  /// Stores the parent send value in `miniquake.conproc.ConProcState`.
  parentSend
  /// Stores the child send value in `miniquake.conproc.ConProcState`.
  childSend
  /// Stores the event done value in `miniquake.conproc.ConProcState`.
  eventDone
  /// Stores the active value in `miniquake.conproc.ConProcState`.
  active
  /// Stores the use native value in `miniquake.conproc.ConProcState`.
  useNative
  /// Stores the mapped buffer value in `miniquake.conproc.ConProcState`.
  mappedBuffer
  /// Stores the test buffer value in `miniquake.conproc.ConProcState`.
  testBuffer
  /// Stores the screen width value in `miniquake.conproc.ConProcState`.
  screenWidth
  /// Stores the screen height value in `miniquake.conproc.ConProcState`.
  screenHeight
  /// Stores the maximum width value in `miniquake.conproc.ConProcState`.
  maximumWidth
  /// Stores the maximum height value in `miniquake.conproc.ConProcState`.
  maximumHeight
  /// Stores the console lines value in `miniquake.conproc.ConProcState`.
  consoleLines
  /// Stores the input events value in `miniquake.conproc.ConProcState`.
  inputEvents
  /// Stores the last error value in `miniquake.conproc.ConProcState`.
  lastError
  /// Stores the requests value in `miniquake.conproc.ConProcState`.
  requests
end struct

/// Tracks the module-level console-process state owned by `miniquake.conproc`.
conProcState = void

/// Creates state for `miniquake.conproc`.
function createState()
  return ConProcState(0, 0, 0, 0, false, false, void, void, 80, 25, 200, 200, [], [], "", 0)
end function

/// Mirror Quake's ConProc_UseState routine and its observable state changes.
/// @param state Mutable `miniquake.conproc` state used by `ConProc_UseState`.
function ConProc_UseState(state)
  global conProcState
  conProcState = state
  return state
end function

// Mirror Quake's ConProc_State routine and its observable state changes.
function ConProc_State()
  global conProcState
  if conProcState is void then conProcState = createState() end if
  return conProcState
end function

/// Initialize state for init con proc.
/// @param fileHandle The file handle input consumed by `InitConProc`.
/// @param parentEvent The parent event input consumed by `InitConProc`.
/// @param childEvent The child event input consumed by `InitConProc`.
/// @param useNative The use native input consumed by `InitConProc`.
function InitConProc(fileHandle, parentEvent, childEvent, useNative)
  state = createState()
  ConProc_UseState(state)
  if fileHandle == 0 or parentEvent == 0 or childEvent == 0 then return false end if
  state.fileBuffer = fileHandle
  state.parentSend = parentEvent
  state.childSend = childEvent
  state.useNative = useNative
  if useNative then
    state.eventDone = native.conprocCreateEvent()
    if state.eventDone == 0 then state.lastError = "Couldn't create heventDone"; return false end if
  else
    state.eventDone = 1
  end if
  state.active = true
  SetConsoleCXCY(0, 80, 25)
  return true
end function

// Release or remove state for con proc.
function DeinitConProc()
  state = ConProc_State()
  if state.eventDone != 0 and state.useNative then native.conprocSetEvent(state.eventDone) end if
  state.active = false
  return true
end function

/// Return mapped buffer.
/// @param fileHandle The file handle input consumed by `GetMappedBuffer`.
function GetMappedBuffer(fileHandle)
  state = ConProc_State()
  if state.testBuffer is not void then state.mappedBuffer = state.testBuffer; return state.testBuffer end if
  if not state.useNative or fileHandle == 0 then return void end if
  state.mappedBuffer = native.conprocMap(fileHandle)
  return state.mappedBuffer
end function

/// Release or remove state for mapped buffer.
/// @param mapped The mapped input consumed by `ReleaseMappedBuffer`.
function ReleaseMappedBuffer(mapped)
  state = ConProc_State()
  if mapped is void then return false end if
  if state.useNative then native.conprocUnmap(mapped) end if
  state.mappedBuffer = void
  return true
end function

// Return screen buffer lines.
function GetScreenBufferLines()
  state = ConProc_State()
  if state.useNative then
    lines = native.conprocScreenLines()
    if lines >= 0 then state.screenHeight = lines; return lines end if
  end if
  return state.screenHeight
end function

/// Update module state for screen buffer lines.
/// @param lines The lines input consumed by `SetScreenBufferLines`.
function SetScreenBufferLines(lines)
  return SetConsoleCXCY(0, 80, lines)
end function

/// Implements the `paddedLine` operation for `miniquake.conproc` (padded line).
/// @param text Text to parse or process.
/// @param width Requested width in pixels or data units.
function paddedLine(text, width)
  source = bytes(text)
  output = bytes(width)
  index = 0
  while index < width
    output[index] = 32
    if index < len(source) then output[index] = source[index] end if
    index = index + 1
  end while
  return decode(output)
end function

/// Reads text for `miniquake.conproc`.
/// @param beginLine The begin line input consumed by `ReadText`.
/// @param endLine The end line input consumed by `ReadText`.
function ReadText(beginLine, endLine)
  state = ConProc_State()
  if endLine < beginLine then return "" end if
  if state.useNative then return native.conprocReadConsoleText(beginLine, endLine) end if
  result = ""
  line = beginLine
  while line <= endLine
    text = ""
    if line >= 0 and line < len(state.consoleLines) then text = state.consoleLines[line] end if
    result = result + paddedLine(text, 80)
    line = line + 1
  end while
  return result
end function

/// Implements the `asciiUpper` operation for `miniquake.conproc` (ascii upper).
/// @param code The code input consumed by `asciiUpper`.
function asciiUpper(code)
  if code >= 97 and code <= 122 then return code - 32 end if
  return code
end function

/// Implements the `CharToCode` operation for `miniquake.conproc` (char to code).
/// @param character The character input consumed by `CharToCode`.
function CharToCode(character)
  if character == 13 then return 28 end if
  upper = asciiUpper(character)
  if (character >= 65 and character <= 90) or (character >= 97 and character <= 122) then return 30 + upper - 65 end if
  if character >= 48 and character <= 57 then return 1 + upper - 47 end if
  return character
end function

/// Writes text for `miniquake.conproc`.
/// @param text Text to parse or process.
function WriteText(text)
  state = ConProc_State()
  source = bytes(text)
  index = 0
  while index < len(source)
    character = source[index]
    if character == 10 then character = 13 end if
    upper = asciiUpper(character)
    shifted = character >= 65 and character <= 90
    state.inputEvents = state.inputEvents + [
      [character, upper, CharToCode(character), shifted, true],
      [character, upper, CharToCode(character), shifted, false],
    ]
    if state.useNative then
      shiftValue = 0
      if shifted then shiftValue = 1 end if
      /*
      Original conproc.c intentionally ignores WriteConsoleInput failures and
      reports TRUE after attempting every key-down/key-up pair.
      */
      native.conprocWriteKey(character, upper, CharToCode(character), shiftValue, 1)
      native.conprocWriteKey(character, upper, CharToCode(character), shiftValue, 0)
    end if
    index = index + 1
  end while
  return true
end function

/// Update module state for console cxcy.
/// @param stdoutHandle The stdout handle input consumed by `SetConsoleCXCY`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function SetConsoleCXCY(stdoutHandle, width, height)
  state = ConProc_State()
  if width < 1 or height < 1 then return false end if
  if width > state.maximumWidth then width = state.maximumWidth end if
  if height > state.maximumHeight then height = state.maximumHeight end if
  if state.useNative and native.conprocSetScreenSize(width, height) == 0 then return false end if
  state.screenWidth = width
  state.screenHeight = height
  return true
end function

/// Execute test request.
/// @param state Mutable `miniquake.conproc` state used by `processTestRequest`.
function processTestRequest(state)
  buffer = state.testBuffer
  if buffer is void or len(buffer) == 0 then return false end if
  command = buffer[0]
  if command == CCOM_WRITE_TEXT then
    result = WriteText(buffer[1])
    state.testBuffer = [result]
  else if command == CCOM_GET_TEXT then
    result = ReadText(buffer[1], buffer[2])
    state.testBuffer = [true, result]
  else if command == CCOM_GET_SCR_LINES then
    state.testBuffer = [true, GetScreenBufferLines()]
  else if command == CCOM_SET_SCR_LINES then
    lines = buffer[1]
    state.testBuffer = [SetScreenBufferLines(lines), lines]
  else
    return false
  end if
  return true
end function

/// Execute native request.
/// @param state Mutable `miniquake.conproc` state used by `processNativeRequest`.
/// @param mapped The mapped input consumed by `processNativeRequest`.
function processNativeRequest(state, mapped)
  command = native.conprocReadI32(mapped, 0)
  success = false
  if command == CCOM_WRITE_TEXT then
    success = WriteText(native.conprocReadText(mapped, 4))
    if success then native.conprocWriteI32(mapped, 0, 1) else native.conprocWriteI32(mapped, 0, 0) end if
  else if command == CCOM_GET_TEXT then
    beginLine = native.conprocReadI32(mapped, 1)
    endLine = native.conprocReadI32(mapped, 2)
    text = ReadText(beginLine, endLine)
    success = native.conprocWriteText(mapped, 4, text, 65532) != 0
    if success then native.conprocWriteI32(mapped, 0, 1) else native.conprocWriteI32(mapped, 0, 0) end if
  else if command == CCOM_GET_SCR_LINES then
    native.conprocWriteI32(mapped, 1, GetScreenBufferLines())
    native.conprocWriteI32(mapped, 0, 1)
    success = true
  else if command == CCOM_SET_SCR_LINES then
    success = SetScreenBufferLines(native.conprocReadI32(mapped, 1))
    if success then native.conprocWriteI32(mapped, 0, 1) else native.conprocWriteI32(mapped, 0, 0) end if
  end if
  return success
end function

/// Implements the `RequestProc` operation for `miniquake.conproc` (request proc).
/// @param block The block input consumed by `RequestProc`.
function RequestProc(block)
  state = ConProc_State()
  if not state.active then return false end if
  if state.useNative then
    timeout = 0
    if block then timeout = INFINITE end if
    waitResult = native.conprocWaitAny(state.parentSend, state.eventDone, timeout)
    if waitResult == 1 then state.active = false; return false end if
    if waitResult != 0 then return false end if
  end if
  mapped = GetMappedBuffer(state.fileBuffer)
  if mapped is void then state.lastError = "Invalid hfileBuffer"; state.active = false; return false end if
  success = false
  if state.useNative then success = processNativeRequest(state, mapped)
  else success = processTestRequest(state)
  end if
  ReleaseMappedBuffer(mapped)
  if state.useNative then native.conprocSetEvent(state.childSend) end if
  state.requests = state.requests + 1
  return success
end function

/// Mirror Quake's ConProc_SetTestBuffer routine and its observable state changes.
/// @param buffer The buffer input consumed by `ConProc_SetTestBuffer`.
function ConProc_SetTestBuffer(buffer)
  state = ConProc_State()
  state.testBuffer = buffer
  return buffer
end function

// Mirror Quake's ConProc_RequestBuffer routine and its observable state changes.
function ConProc_RequestBuffer()
  return ConProc_State().testBuffer
end function

// Mirror Quake's ConProc_Poll routine and its observable state changes.
function ConProc_Poll()
  return RequestProc(false)
end function
