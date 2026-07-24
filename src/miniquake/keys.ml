package miniquake.keys

import miniquake.input as input
import miniquake.console as console
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.byteio as bio
import miniquake.platform.win32 as win
import miniquake.native as native

const MAXCMDLINE = 256
const KEY_GAME = 0
const KEY_CONSOLE = 1
const KEY_MESSAGE = 2
const KEY_MENU = 3

const K_TAB = 9
const K_ENTER = 13
const K_ESCAPE = 27
const K_SPACE = 32
const K_BACKSPACE = 127
const K_UPARROW = 128
const K_DOWNARROW = 129
const K_LEFTARROW = 130
const K_RIGHTARROW = 131
const K_ALT = 132
const K_CTRL = 133
const K_SHIFT = 134
const K_F1 = 135
const K_F12 = 146
const K_INS = 147
const K_DEL = 148
const K_PGDN = 149
const K_PGUP = 150
const K_HOME = 151
const K_END = 152
const K_MOUSE1 = 200
const K_MOUSE2 = 201
const K_MOUSE3 = 202
const K_JOY1 = 203
const K_AUX1 = 207
const K_MWHEELUP = 239
const K_MWHEELDOWN = 240
const K_PAUSE = 255

keyLines = []
keyLinePos = 1
shiftDown = false
keyLastPress = 0
editLine = 0
historyLine = 0
keyDest = KEY_GAME
keyCount = 0
consoleKeys = []
menuBound = []
keyShift = []
keyRepeats = []
keyDownStates = []
chatBuffer = ""
teamMessage = false
registeredCommandNames = []

function zeroValues(count)
  result = []
  index = 0
  while index < count
    result = result + [0]
    index = index + 1
  end while
  return result
end function

function identityValues(count)
  result = []
  index = 0
  while index < count
    result = result + [index]
    index = index + 1
  end while
  return result
end function

function setDestination(destination)
  global keyDest
  keyDest = destination
  return keyDest
end function

function destination()
  return keyDest
end function

function beginMessage(team)
  global keyDest, teamMessage, chatBuffer
  keyDest = KEY_MESSAGE
  teamMessage = team
  chatBuffer = ""
  return true
end function

function Key_StringToKeynum(text)
  if text is void or text == "" then return -1 end if
  source = bytes(text)
  if len(source) == 1 then return source[0] end if
  return input.keyCodeForName(text)
end function

function Key_KeynumToString(keynum)
  return input.keyNameForCode(keynum)
end function

function Key_SetBinding(keynum, binding)
  if keynum < 0 or keynum > 255 then return false end if
  return input.setBindingCode(keynum, binding)
end function

function Key_Unbind_f(arguments)
  if len(arguments) != 2 then return "unbind <key> : remove commands from a key" end if
  keynum = Key_StringToKeynum(arguments[1])
  if keynum == -1 then return "\"" + arguments[1] + "\" isn't a valid key" end if
  Key_SetBinding(keynum, "")
  return ""
end function

function Key_Unbindall_f()
  keynum = 0
  while keynum < 256
    if input.hasBindingCode(keynum) then Key_SetBinding(keynum, "") end if
    keynum = keynum + 1
  end while
  return true
end function

function Key_Bind_f(arguments)
  count = len(arguments)
  if count != 2 and count != 3 then return "bind <key> [command] : attach a command to a key" end if
  keynum = Key_StringToKeynum(arguments[1])
  if keynum == -1 then return "\"" + arguments[1] + "\" isn't a valid key" end if
  if count == 2 then
    binding = input.bindingForCode(keynum)
    if binding is void then return "\"" + arguments[1] + "\" is not bound" end if
    return "\"" + arguments[1] + "\" = \"" + binding + "\""
  end if
  Key_SetBinding(keynum, arguments[2])
  return ""
end function

function Key_Bindlist_f()
  result = ""
  keynum = 0
  while keynum < 256
    binding = input.bindingForCode(keynum)
    if binding is not void and binding != "" then
      result = result + Key_KeynumToString(keynum) + " \"" + binding + "\"\n"
    end if
    keynum = keynum + 1
  end while
  return result
end function

function Key_WriteBindings()
  return input.bindingText()
end function

function initializeShiftTable()
  global keyShift
  keyShift = identityValues(256)
  code = 97
  while code <= 122
    keyShift[code] = code - 32
    code = code + 1
  end while
  keyShift[49] = 33
  keyShift[50] = 64
  keyShift[51] = 35
  keyShift[52] = 36
  keyShift[53] = 37
  keyShift[54] = 94
  keyShift[55] = 38
  keyShift[56] = 42
  keyShift[57] = 40
  keyShift[48] = 41
  keyShift[45] = 95
  keyShift[61] = 43
  keyShift[44] = 60
  keyShift[46] = 62
  keyShift[47] = 63
  keyShift[59] = 58
  keyShift[39] = 34
  keyShift[91] = 123
  keyShift[93] = 125
  keyShift[96] = 126
  keyShift[92] = 124
end function

function Key_Init()
  global keyLines, keyLinePos, editLine, historyLine
  global keyDest, keyCount, keyLastPress, shiftDown
  global consoleKeys, menuBound, keyRepeats, keyDownStates
  global chatBuffer, teamMessage
  global registeredCommandNames
  keyLines = []
  index = 0
  while index < 32
    keyLines = keyLines + [""]
    index = index + 1
  end while
  keyLinePos = 1
  editLine = 0
  historyLine = 0
  keyDest = KEY_GAME
  keyCount = 0
  keyLastPress = 0
  shiftDown = false
  chatBuffer = ""
  teamMessage = false
  registeredCommandNames = ["bind", "unbind", "unbindall"]
  console.setBackscroll(0)
  consoleKeys = zeroValues(256)
  menuBound = zeroValues(256)
  keyRepeats = zeroValues(256)
  keyDownStates = zeroValues(256)
  initializeShiftTable()

  index = 32
  while index < 128
    consoleKeys[index] = 1
    index = index + 1
  end while
  consoleKeys[K_ENTER] = 1
  consoleKeys[K_TAB] = 1
  consoleKeys[K_LEFTARROW] = 1
  consoleKeys[K_RIGHTARROW] = 1
  consoleKeys[K_UPARROW] = 1
  consoleKeys[K_DOWNARROW] = 1
  consoleKeys[K_BACKSPACE] = 1
  consoleKeys[K_PGUP] = 1
  consoleKeys[K_PGDN] = 1
  consoleKeys[K_SHIFT] = 1
  consoleKeys[K_MWHEELUP] = 1
  consoleKeys[K_MWHEELDOWN] = 1
  consoleKeys[96] = 0
  consoleKeys[126] = 0
  menuBound[K_ESCAPE] = 1
  index = K_F1
  while index <= K_F12
    menuBound[index] = 1
    index = index + 1
  end while
  return true
end function

function Key_Console(key, state, commandSystem, registry, visibleRows)
  global editLine, historyLine, keyLinePos, keyLines
  if key == K_ENTER then
    line = state.inputText
    keyLines[editLine] = line
    console.appendLine(state, "]" + line)
    editLine = (editLine + 1) & 31
    historyLine = editLine
    state.inputText = ""
    keyLinePos = 1
    if line == "" then return "" end if
    return line + "\n"
  end if

  if key == K_TAB then
    completion = cmd.completeCommand(commandSystem, state.inputText)
    if completion is void then completion = cvar.completeVariable(registry, state.inputText) end if
    if completion is not void then
      state.inputText = completion + " "
      keyLinePos = len(bytes(state.inputText)) + 1
    end if
    return ""
  end if

  if key == K_BACKSPACE or key == K_LEFTARROW then
    console.backspace(state)
    keyLinePos = len(bytes(state.inputText)) + 1
    return ""
  end if

  if key == K_UPARROW then
    next = (historyLine - 1) & 31
    while next != editLine and keyLines[next] == ""
      next = (next - 1) & 31
    end while
    if next == editLine then next = (editLine + 1) & 31 end if
    historyLine = next
    state.inputText = keyLines[historyLine]
    keyLinePos = len(bytes(state.inputText)) + 1
    return ""
  end if

  if key == K_DOWNARROW then
    if historyLine == editLine then return "" end if
    next = (historyLine + 1) & 31
    while next != editLine and keyLines[next] == ""
      next = (next + 1) & 31
    end while
    historyLine = next
    if historyLine == editLine then state.inputText = "" else state.inputText = keyLines[historyLine] end if
    keyLinePos = len(bytes(state.inputText)) + 1
    return ""
  end if

  // keys.c clamps against con_totallines, including blank ring rows, rather
  // than the number of lines printed since startup.
  maximumScroll = state.totalLines - visibleRows - 1
  if maximumScroll < 0 then maximumScroll = 0 end if
  if key == K_PGUP or key == K_MWHEELUP then
    value = console.backscroll() + 2
    if value > maximumScroll then value = maximumScroll end if
    console.setBackscroll(value)
    return ""
  end if
  if key == K_PGDN or key == K_MWHEELDOWN then
    value = console.backscroll() - 2
    if value < 0 then value = 0 end if
    console.setBackscroll(value)
    return ""
  end if
  if key == K_HOME then console.setBackscroll(maximumScroll); return "" end if
  if key == K_END then console.setBackscroll(0); return "" end if
  if key < 32 or key > 127 then return "" end if
  if len(bytes(state.inputText)) < MAXCMDLINE - 2 then
    console.appendCharacter(state, key)
    keyLinePos = len(bytes(state.inputText)) + 1
  end if
  return ""
end function

function Key_Message(key)
  global keyDest, chatBuffer
  if key == K_ENTER then
    prefix = "say \""
    if teamMessage then prefix = "say_team \"" end if
    command = prefix + chatBuffer + "\"\n"
    keyDest = KEY_GAME
    chatBuffer = ""
    return command
  end if
  if key == K_ESCAPE then
    keyDest = KEY_GAME
    chatBuffer = ""
    return ""
  end if
  if key < 32 or key > 127 then return "" end if
  if key == K_BACKSPACE then
    data = bytes(chatBuffer)
    if len(data) > 0 then chatBuffer = decode(slice(data, 0, len(data) - 1)) end if
    return ""
  end if
  if len(bytes(chatBuffer)) < 31 then chatBuffer = chatBuffer + decode(bytes([key])) end if
  return ""
end function

function plusRelease(binding, key)
  if binding is void or binding == "" then return "" end if
  source = bytes(binding)
  if len(source) == 0 or source[0] != 43 then return "" end if
  return "-" + decode(slice(source, 1, len(source) - 1)) + " " + key + "\n"
end function

// Returns [commands-to-buffer, host-action, routed-key]. Host actions are
// intentionally small: menu policy stays in menu/host while key routing and
// binding semantics remain wholly owned here.
function Key_Event(key, down, consoleState, commandSystem, registry, forcedConsole, demoPlayback)
  global keyCount, keyLastPress, shiftDown, keyRepeats, keyDownStates
  if key < 0 or key > 255 then return ["", "", key] end if
  if len(keyDownStates) != 256 then Key_Init() end if
  keyDownStates[key] = down
  if not down then keyRepeats[key] = 0 end if
  keyLastPress = key
  keyCount = keyCount + 1
  if keyCount <= 0 then return ["", "", key] end if

  if down then
    keyRepeats[key] = keyRepeats[key] + 1
    if key != K_BACKSPACE and key != K_PAUSE and keyRepeats[key] > 1 then return ["", "", key] end if
    if key >= 200 and input.bindingForCode(key) is void then
      print Key_KeynumToString(key) + " is unbound, hit F4 to set."
    end if
  end if
  if key == K_SHIFT then shiftDown = down end if

  if key == K_ESCAPE then
    if not down then return ["", "", key] end if
    if keyDest == KEY_MESSAGE then return [Key_Message(key), "", key] end if
    if keyDest == KEY_MENU then return ["", "menu_escape", key] end if
    return ["", "toggle_menu", key]
  end if

  if not down then
    queued = plusRelease(input.bindingForCode(key), key)
    shifted = keyShift[key]
    if shifted != key then queued = queued + plusRelease(input.bindingForCode(shifted), key) end if
    return [queued, "", key]
  end if

  if demoPlayback and consoleKeys[key] != 0 and keyDest == KEY_GAME then
    return ["", "toggle_menu", key]
  end if

  routeBinding = false
  if keyDest == KEY_MENU and menuBound[key] != 0 then routeBinding = true end if
  if keyDest == KEY_CONSOLE and consoleKeys[key] == 0 then routeBinding = true end if
  if keyDest == KEY_GAME and (not forcedConsole or consoleKeys[key] == 0) then routeBinding = true end if
  if routeBinding then
    binding = input.bindingForCode(key)
    if binding is void or binding == "" then return ["", "", key] end if
    source = bytes(binding)
    if source[0] == 43 then return [binding + " " + key + "\n", "", key] end if
    return [binding + "\n", "", key]
  end if

  routedKey = key
  if shiftDown then routedKey = keyShift[key] end if
  if keyDest == KEY_MESSAGE then return [Key_Message(routedKey), "", routedKey] end if
  if keyDest == KEY_MENU then return ["", "menu_key", routedKey] end if
  visibleRows = native.trunc(win.height() / 8)
  if visibleRows <= 0 then visibleRows = 25 end if
  return [Key_Console(routedKey, consoleState, commandSystem, registry, visibleRows), "", routedKey]
end function

function Key_ClearStates()
  global keyRepeats, keyDownStates
  if len(keyDownStates) != 256 then Key_Init() end if
  index = 0
  while index < 256
    keyDownStates[index] = false
    keyRepeats[index] = 0
    index = index + 1
  end while
  return true
end function

function hardwareKeyCodes()
  result = [K_TAB, K_ENTER, K_ESCAPE, K_SPACE, K_BACKSPACE]
  code = 97
  while code <= 122
    result = result + [code]
    code = code + 1
  end while
  code = 48
  while code <= 57
    result = result + [code]
    code = code + 1
  end while
  result = result + [45, 61, 44, 46, 47, 59, 39, 91, 93, 96, 92]
  result = result + [
    K_UPARROW, K_DOWNARROW, K_LEFTARROW, K_RIGHTARROW,
    K_ALT, K_CTRL, K_SHIFT,
  ]
  code = K_F1
  while code <= K_F12
    result = result + [code]
    code = code + 1
  end while
  result = result + [
    K_INS, K_DEL, K_PGDN, K_PGUP, K_HOME, K_END, K_PAUSE,
    K_MOUSE1, K_MOUSE2, K_MOUSE3,
  ]
  return result
end function

// Consumes the ordered Win32 message queue. Packed native event types are:
// keyboard=1 (legacy raw VK), mouse button=2, wheel=3, focus=4, and
// keyboard=5 (GLQuake hardware scan code).
function PollEvents()
  if len(keyDownStates) != 256 then Key_Init() end if
  events = []
  packed = win.inputEventPop()
  while packed != 0
    eventType = (packed >> 24) & 255
    code = (packed >> 8) & 65535
    value = packed & 255
    key = -1
    if eventType == 1 then
      key = input.quakeKeyForVirtualKey(code)
      if key >= 0 then events = events + [[key, value != 0]] end if
    else if eventType == 2 then
      if code < 3 then events = events + [[K_MOUSE1 + code, value != 0]] end if
    else if eventType == 3 then
      if value == 255 then key = K_MWHEELDOWN else key = K_MWHEELUP end if
      events = events + [[key, true], [key, false]]
    else if eventType == 4 then
      events = events + [[-1, value != 0]]
    else if eventType == 5 then
      key = input.quakeKeyForScanCode(code)
      if key != 0 then events = events + [[key, value != 0]] end if
    end if
    packed = win.inputEventPop()
  end while
  // The legacy aggregate remains exported for compatibility; ordered wheel
  // events above are authoritative.
  win.mouseWheel()
  for each event in input.IN_Commands()
    events = events + [event]
  end for
  return events
end function
