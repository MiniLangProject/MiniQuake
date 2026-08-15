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

const CCOM_WRITE_TEXT = 0x2
const CCOM_GET_TEXT = 0x3
const CCOM_GET_SCR_LINES = 0x4
const CCOM_SET_SCR_LINES = 0x5
const INFINITE = 0xffffffff

struct ConProcState
  fileBuffer
  parentSend
  childSend
  eventDone
  active
  useNative
  mappedBuffer
  testBuffer
  screenWidth
  screenHeight
  maximumWidth
  maximumHeight
  consoleLines
  inputEvents
  lastError
  requests
end struct

conProcState = void

// Create and initialize state.
function createState()
  return ConProcState(0, 0, 0, 0, false, false, void, void, 80, 25, 200, 200, [], [], "", 0)
end function

// Mirror Quake's ConProc_UseState routine and its observable state changes.
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

// Initialize state for init con proc.
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

// Return mapped buffer.
function GetMappedBuffer(fileHandle)
  state = ConProc_State()
  if state.testBuffer is not void then state.mappedBuffer = state.testBuffer; return state.testBuffer end if
  if not state.useNative or fileHandle == 0 then return void end if
  state.mappedBuffer = native.conprocMap(fileHandle)
  return state.mappedBuffer
end function

// Release or remove state for mapped buffer.
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

// Update module state for screen buffer lines.
function SetScreenBufferLines(lines)
  return SetConsoleCXCY(0, 80, lines)
end function

// Provide padded line behavior for the active subsystem.
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

// Read and validate text.
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

// Provide ascii upper behavior for the active subsystem.
function asciiUpper(code)
  if code >= 97 and code <= 122 then return code - 32 end if
  return code
end function

// Provide char to code behavior for the active subsystem.
function CharToCode(character)
  if character == 13 then return 28 end if
  upper = asciiUpper(character)
  if (character >= 65 and character <= 90) or (character >= 97 and character <= 122) then return 30 + upper - 65 end if
  if character >= 48 and character <= 57 then return 1 + upper - 47 end if
  return character
end function

// Encode and write text.
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

// Update module state for console cxcy.
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

// Execute test request.
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

// Execute native request.
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

// Provide request proc behavior for the active subsystem.
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

// Mirror Quake's ConProc_SetTestBuffer routine and its observable state changes.
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
