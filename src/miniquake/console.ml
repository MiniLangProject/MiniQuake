package miniquake.console

import miniquake.types as t

function create(maxLines)
  if maxLines < 32 then maxLines = 32 end if
  return t.ConsoleState([], maxLines, "", false, 0.0, 0, false, "", 0.0)
end function

function trimOldest(lines, maximum)
  if len(lines) <= maximum then return lines end if
  result = []
  start = len(lines) - maximum
  index = start
  while index < len(lines)
    result = result + [lines[index]]
    index = index + 1
  end while
  return result
end function

function appendLine(state, text)
  state.lines = state.lines + [text]
  state.lines = trimOldest(state.lines, state.maxLines)
  return len(state.lines)
end function

function append(state, text)
  data = bytes(text)
  start = 0
  index = 0
  while index < len(data)
    if data[index] == 10 then
      length = index - start
      if length > 0 and data[index - 1] == 13 then length = length - 1 end if
      appendLine(state, decode(slice(data, start, length)))
      start = index + 1
    end if
    index = index + 1
  end while
  if start < len(data) then appendLine(state, decode(slice(data, start, len(data) - start))) end if
  if len(data) == 0 then appendLine(state, "") end if
  return len(state.lines)
end function

function clear(state)
  state.lines = []
  return true
end function

function toggle(state)
  state.active = not state.active
  return state.active
end function

function setActive(state, active)
  state.active = active
  return state.active
end function

function setInput(state, text)
  state.inputText = text
  return text
end function

function visibleLines(state, count)
  result = []
  if count <= 0 then return result end if
  start = len(state.lines) - count
  if start < 0 then start = 0 end if
  index = start
  while index < len(state.lines)
    result = result + [state.lines[index]]
    index = index + 1
  end while
  return result
end function

function appendCharacter(state, code)
  if code < 32 or code > 126 then return false end if
  // The native queue reports UTF-16 code units, while MiniLang decode is UTF-8.
  // Keep console editing ASCII-only until a real UTF-16-to-UTF-8 text path is
  // exposed; this also matches the printable range of the original Quake UI.
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
  appendLine(state, text)
  return true
end function

function clearExpiredCenter(state, currentTime)
  if state.centerUntil > 0.0 and currentTime >= state.centerUntil then
    state.centerText = ""
    state.centerUntil = 0.0
  end if
  return state.centerText
end function
