package miniquake.console

import miniquake.types as t
import miniquake.filesystem as qfs
import miniquake.native as native
import miniquake.array_util as arrays
import std.fs as fs

const CON_TEXTSIZE = 16384
const NUM_CON_TIMES = 4
const DEFAULT_LINEWIDTH = 38
const MAXCMDLINE = 256

backscrollLines = 0
notifyBoxWaiting = false
notifyBoxSawDown = false

function filledBytes(count, value)
  output = bytes(count)
  index = 0
  while index < count
    output[index] = value
    index = index + 1
  end while
  return output
end function

function zeroTimes()
  return [0.0, 0.0, 0.0, 0.0]
end function

function create(maxLines)
  if maxLines < 32 then maxLines = 32 end if
  state = t.ConsoleState(
    [],
    maxLines,
    "",
    false,
    0.0,
    0,
    false,
    "",
    0.0,
    filledBytes(CON_TEXTSIZE, 32),
    DEFAULT_LINEWIDTH,
    native.trunc(CON_TEXTSIZE / DEFAULT_LINEWIDTH),
    native.trunc(CON_TEXTSIZE / DEFAULT_LINEWIDTH) - 1,
    0,
    false,
    zeroTimes(),
    0.0,
    0,
    false,
    false,
    0,
    false,
    "qconsole.log",
    void,
    0,
    false,
    [],
    false,
    0,
    "",
    false,
  )
  return state
end function

function backscroll()
  return backscrollLines
end function

function setBackscroll(value)
  global backscrollLines
  if value < 0 then value = 0 end if
  backscrollLines = value
  return backscrollLines
end function

function adjustBackscroll(state, delta, visibleRows)
  maximum = state.lineCount - visibleRows
  if maximum < 0 then maximum = 0 end if
  value = backscrollLines + delta
  if value < 0 then value = 0 end if
  if value > maximum then value = maximum end if
  return setBackscroll(value)
end function

function Con_ClearNotify(state)
  state.notifyTimes = zeroTimes()
  return true
end function

function Con_CheckResize(state, pixelWidth)
  // con_x is deliberately not reset by GLQuake's Con_CheckResize.  A resize
  // reformats the circular backing store but the next printed byte continues
  // at the same logical column.
  oldCursorX = state.cursorX
  width = native.trunc(pixelWidth / 8) - 2
  if width == state.lineWidth then return false end if
  if width < 1 then
    width = DEFAULT_LINEWIDTH
    state.lineWidth = width
    state.totalLines = native.trunc(CON_TEXTSIZE / width)
    state.textBuffer = filledBytes(CON_TEXTSIZE, 32)
    state.currentLine = state.totalLines - 1
    state.cursorX = oldCursorX
    state.lineCount = 0
    setBackscroll(0)
    return true
  end if

  oldWidth = state.lineWidth
  oldTotal = state.totalLines
  oldCurrent = state.currentLine
  oldBuffer = state.textBuffer
  state.lineWidth = width
  state.totalLines = native.trunc(CON_TEXTSIZE / width)
  state.textBuffer = filledBytes(CON_TEXTSIZE, 32)
  numLines = oldTotal
  if state.totalLines < numLines then numLines = state.totalLines end if
  if state.lineCount < numLines then numLines = state.lineCount end if
  numChars = oldWidth
  if state.lineWidth < numChars then numChars = state.lineWidth end if
  lineIndex = 0
  while lineIndex < numLines
    character = 0
    while character < numChars
      destination = (state.totalLines - 1 - lineIndex) * state.lineWidth + character
      sourceLine = (oldCurrent - lineIndex + oldTotal) % oldTotal
      state.textBuffer[destination] = oldBuffer[sourceLine * oldWidth + character]
      character = character + 1
    end while
    lineIndex = lineIndex + 1
  end while
  state.currentLine = state.totalLines - 1
  state.cursorX = oldCursorX
  Con_ClearNotify(state)
  setBackscroll(0)
  syncLines(state)
  return true
end function

function Con_Init(state, filesystem, pixelWidth, debugLog)
  state.filesystem = filesystem
  state.debugLog = debugLog
  state.debugLogName = "qconsole.log"
  if state.debugLog and filesystem is not void then qfs.writeText(filesystem, state.debugLogName, "") end if
  state.textBuffer = filledBytes(CON_TEXTSIZE, 32)
  state.lineWidth = -1
  state.totalLines = 0
  state.currentLine = 0
  state.cursorX = 0
  state.lineCount = 0
  Con_CheckResize(state, pixelWidth)
  Con_Printf(state, "Console initialized.\n", false, false)
  state.initialized = true
  return ["toggleconsole", "messagemode", "messagemode2", "clear"]
end function

function Con_Linefeed(state)
  state.cursorX = 0
  state.currentLine = state.currentLine + 1
  state.lineCount = state.lineCount + 1
  if state.lineCount > state.totalLines then state.lineCount = state.totalLines end if
  offset = (state.currentLine % state.totalLines) * state.lineWidth
  index = 0
  while index < state.lineWidth
    state.textBuffer[offset + index] = 32
    index = index + 1
  end while
  return state.currentLine
end function

function lineBytes(state, logicalLine)
  output = bytes(state.lineWidth)
  sourceLine = logicalLine % state.totalLines
  if sourceLine < 0 then sourceLine = sourceLine + state.totalLines end if
  start = sourceLine * state.lineWidth
  index = 0
  while index < state.lineWidth
    output[index] = state.textBuffer[start + index]
    index = index + 1
  end while
  return output
end function

function printableLine(raw)
  endIndex = len(raw)
  while endIndex > 0 and (raw[endIndex - 1] & 127) == 32
    endIndex = endIndex - 1
  end while
  output = bytes(endIndex)
  index = 0
  while index < endIndex
    value = raw[index] & 127
    if value == 0 then value = 32 end if
    output[index] = value
    index = index + 1
  end while
  return decode(output)
end function

function syncLines(state)
  count = state.lineCount
  if state.maxLines < count then count = state.maxLines end if
  lines = arrays.makeEmptyArray(count)
  first = state.currentLine - count + 1
  index = 0
  while index < count
    raw = lineBytes(state, first + index)
    lines[index] = printableLine(raw)
    index = index + 1
  end while
  state.lines = lines
  return state.lines
end function

function Con_Print(state, text, realtime)
  state.realtime = realtime
  setBackscroll(0)
  source = bytes(text)
  mask = 0
  position = 0
  if len(source) > 0 and source[0] == 1 then
    mask = 128
    state.talkSoundRequested = true
    position = 1
  else if len(source) > 0 and source[0] == 2 then
    mask = 128
    position = 1
  end if

  while position < len(source)
    code = source[position]
    wordLength = 0
    while wordLength < state.lineWidth and position + wordLength < len(source) and source[position + wordLength] > 32
      wordLength = wordLength + 1
    end while
    if wordLength != state.lineWidth and state.cursorX + wordLength > state.lineWidth then state.cursorX = 0 end if

    if state.carriageReturn then
      state.currentLine = state.currentLine - 1
      state.carriageReturn = false
    end if
    if state.cursorX == 0 then
      Con_Linefeed(state)
      if state.currentLine >= 0 then state.notifyTimes[state.currentLine % NUM_CON_TIMES] = realtime end if
    end if

    if code == 10 then
      state.cursorX = 0
    else if code == 13 then
      state.cursorX = 0
      state.carriageReturn = true
    else
      row = state.currentLine % state.totalLines
      state.textBuffer[row * state.lineWidth + state.cursorX] = code | mask
      state.cursorX = state.cursorX + 1
      if state.cursorX >= state.lineWidth then state.cursorX = 0 end if
    end if
    position = position + 1
  end while
  syncLines(state)
  return len(source)
end function

function Con_DebugLog(state, filename, text)
  if state.filesystem is void then return false end if
  written = try(fs.appendAllText(qfs.gamePath(state.filesystem, filename), text))
  return written is not error
end function

function Con_Printf(state, message, dedicated, loadingDisabled)
  // Sys_Printf's side effect remains visible in every mode.
  print message
  if state.debugLog then Con_DebugLog(state, state.debugLogName, message) end if
  if not state.initialized or dedicated then return false end if
  Con_Print(state, message, state.realtime)
  if not loadingDisabled and state.safePrintDepth == 0 then state.updateRequested = true end if
  return true
end function

function Con_DPrintf(state, message, developer, dedicated, loadingDisabled)
  if not developer then return false end if
  return Con_Printf(state, message, dedicated, loadingDisabled)
end function

function Con_SafePrintf(state, message, dedicated)
  state.safePrintDepth = state.safePrintDepth + 1
  result = Con_Printf(state, message, dedicated, true)
  state.safePrintDepth = state.safePrintDepth - 1
  return result
end function

function Con_Clear_f(state)
  // console.c only blanks con_text.  Cursor position, carriage-return state,
  // notify history and scroll position remain untouched.
  state.textBuffer = filledBytes(CON_TEXTSIZE, 32)
  syncLines(state)
  return true
end function

function clear(state)
  return Con_Clear_f(state)
end function

function Con_ToggleConsole_f(state, connected)
  Con_ClearNotify(state)
  state.notifyUntil = 0.0
  if state.active then
    if connected then
      state.inputText = ""
      state.active = false
      return "game"
    end if
    state.active = false
    return "menu"
  end if
  state.active = true
  return "console"
end function

function toggle(state)
  state.active = not state.active
  Con_ClearNotify(state)
  return state.active
end function

function setActive(state, active)
  state.active = active
  return state.active
end function

function Con_MessageMode_f(state)
  state.active = false
  return false
end function

function Con_MessageMode2_f(state)
  state.active = false
  return true
end function

function Con_DrawInput(state, realtime)
  if not state.active and not state.forcedUp then return [] end if
  cursor = 10 + (native.trunc(realtime * 4.0) & 1)
  text = bytes("]" + state.inputText)
  visible = state.lineWidth
  start = 0
  if len(text) + 1 >= visible then start = len(text) + 1 - visible end if
  output = []
  index = start
  while index < len(text)
    output = output + [text[index]]
    index = index + 1
  end while
  output = output + [cursor]
  return output
end function

function Con_NotifyRows(state, realtime, notifyTime)
  rows = []
  first = state.currentLine - NUM_CON_TIMES + 1
  line = first
  while line <= state.currentLine
    if line >= 0 then
      generated = state.notifyTimes[line % NUM_CON_TIMES]
      if generated != 0.0 and realtime - generated <= notifyTime then rows = rows + [lineBytes(state, line)] end if
    end if
    line = line + 1
  end while
  return rows
end function

function Con_DrawNotify(state, realtime, notifyTime, messageMode, chatText)
  rows = Con_NotifyRows(state, realtime, notifyTime)
  commands = []
  y = 0
  for each row in rows
    commands = commands + [["text", 8, y, row]]
    y = y + 8
  end for
  if messageMode then
    chat = bytes("say:" + chatText)
    commands = commands + [["chat", 8, y, chat, 10 + (native.trunc(realtime * 4.0) & 1)]]
    y = y + 8
  end if
  if y > state.notifyPixelLines then state.notifyPixelLines = y end if
  state.drawTrace = commands
  return commands
end function

function Con_ConsoleRows(state, pixelLines)
  rows = native.trunc((pixelLines - 16) / 8)
  if rows < 0 then rows = 0 end if
  output = []
  line = state.currentLine - rows + 1
  while line <= state.currentLine
    selected = line - backscrollLines
    if selected < 0 then selected = 0 end if
    output = output + [lineBytes(state, selected)]
    line = line + 1
  end while
  return output
end function

function Con_DrawConsole(state, pixelLines, drawInput, realtime)
  if pixelLines <= 0 then return [] end if
  state.visiblePixelLines = pixelLines
  commands = [["background", pixelLines]]
  rows = Con_ConsoleRows(state, pixelLines)
  y = pixelLines - 16 - len(rows) * 8
  for each row in rows
    commands = commands + [["text", 8, y, row]]
    y = y + 8
  end for
  if drawInput then commands = commands + [["input", Con_DrawInput(state, realtime)]] end if
  state.drawTrace = commands
  return commands
end function

function Con_NotifyBox(state, text)
  global notifyBoxWaiting, notifyBoxSawDown
  border = decode(bytes([29, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 31]))
  state.notifyBoxText = text
  Con_Printf(state, "\n\n" + border + "\n" + text + "Press a key.\n" + border + "\n", state.dedicated, true)
  state.active = true
  state.realtime = 0.0
  // console.c sets key_count=-2 and waits for one key-down followed by one
  // key-up. MiniQuake keeps the host loop non-blocking but preserves that
  // exact two-edge acknowledgement contract.
  notifyBoxWaiting = true
  notifyBoxSawDown = false
  return true
end function

function Con_NotifyBoxPending()
  return notifyBoxWaiting
end function

function Con_NotifyBoxKey(state, down)
  global notifyBoxWaiting, notifyBoxSawDown
  if not notifyBoxWaiting then return false end if
  if down then
    notifyBoxSawDown = true
    return false
  end if
  if not notifyBoxSawDown then return false end if
  notifyBoxWaiting = false
  notifyBoxSawDown = false
  Con_Printf(state, "\n", state.dedicated, true)
  state.active = false
  state.realtime = 0.0
  state.notifyBoxText = ""
  return true
end function

function Con_CancelNotifyBox(state)
  global notifyBoxWaiting, notifyBoxSawDown
  notifyBoxWaiting = false
  notifyBoxSawDown = false
  state.notifyBoxText = ""
  return true
end function

function Con_Print_f(state, arguments)
  text = ""
  index = 1
  while index < len(arguments)
    if index > 1 then text = text + " " end if
    text = text + arguments[index]
    index = index + 1
  end while
  return Con_Printf(state, text + "\n", state.dedicated, false)
end function

function Con_LogCenterPrint(state, text, realtime)
  Con_Print(state, "\n\n" + text + "\n\n", realtime)
  state.centerText = text
  return true
end function

function Con_Notify(state, text)
  return Con_NotifyBox(state, text)
end function

function appendLine(state, text)
  Con_Print(state, text + "\n", state.realtime)
  return len(state.lines)
end function

function append(state, text)
  Con_Print(state, text, state.realtime)
  return len(state.lines)
end function

function trimOldest(lines, maximum)
  if len(lines) <= maximum then return lines end if
  result = arrays.makeEmptyArray(maximum)
  sourceIndex = len(lines) - maximum
  targetIndex = 0
  while sourceIndex < len(lines)
    result[targetIndex] = lines[sourceIndex]
    sourceIndex = sourceIndex + 1
    targetIndex = targetIndex + 1
  end while
  return result
end function

function visibleLines(state, count)
  if count <= 0 then return [] end if
  start = len(state.lines) - count - backscrollLines
  if start < 0 then start = 0 end if
  visibleCount = len(state.lines) - start
  if visibleCount > count then visibleCount = count end if
  result = arrays.makeEmptyArray(visibleCount)
  index = 0
  while index < visibleCount
    result[index] = state.lines[start + index]
    index = index + 1
  end while
  return result
end function

function setInput(state, text)
  state.inputText = text
  return text
end function

function appendCharacter(state, code)
  if code < 32 or code > 126 then return false end if
  if len(bytes(state.inputText)) >= MAXCMDLINE - 2 then return false end if
  state.inputText = state.inputText + decode(bytes([code]))
  return true
end function

function backspace(state)
  data = bytes(state.inputText)
  if len(data) == 0 then return false end if
  state.inputText = decode(slice(data, 0, len(data) - 1))
  return true
end function

function takeInput(state)
  text = state.inputText
  state.inputText = ""
  return text
end function

function centerPrint(state, text, currentTime, duration)
  state.centerText = text
  state.centerUntil = currentTime + duration
  Con_LogCenterPrint(state, text, currentTime)
  return true
end function

function clearExpiredCenter(state, currentTime)
  if state.centerUntil > 0.0 and currentTime >= state.centerUntil then
    state.centerText = ""
    state.centerUntil = 0.0
  end if
  return state.centerText
end function

function Con_SetRealtime(state, realtime)
  state.realtime = realtime
  return realtime
end function

function Con_CommandTrace(state)
  return state.drawTrace
end function
