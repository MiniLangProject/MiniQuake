/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.input.
*/
package miniquake.input

import miniquake.types as t
import miniquake.constants as c
import miniquake.platform.win32 as win
import miniquake.mathlib as math
import miniquake.byteio as bio
import miniquake.common as common
import miniquake.cvar as cv
import miniquake.native as native

const DEFAULT_M_YAW = 0.022
const DEFAULT_M_PITCH = 0.022
const DEFAULT_M_SIDE = 0.8
const DEFAULT_M_FORWARD = 1.0
const DEFAULT_YAW_SPEED = 140.0
const DEFAULT_PITCH_SPEED = 150.0
const DEFAULT_ANGLE_SPEED_KEY = 1.5
const DEFAULT_MOVE_SPEED_KEY = 2.0
const JOY_ABSOLUTE_AXIS = 0
const JOY_RELATIVE_AXIS = 16
const JOY_MAX_AXES = 6
const AXIS_NADA = 0
const AXIS_FORWARD = 1
const AXIS_LOOK = 2
const AXIS_SIDE = 3
const AXIS_TURN = 4

oldMouseX = 0.0
oldMouseY = 0.0
mouseFilterReady = false
mouseCaptured = false
mouseInitialized = false
mouseActive = false
mouseActivateToggle = false
mouseShowToggle = true
directInput = false
mouseOldButtonState = 0
mouseAccumX = 0.0
mouseAccumY = 0.0
joyAvailable = false
joyAdvancedInitialized = false
joyHasPov = false
joyButtonCount = 0
joyOldButtonState = 0
joyOldPovState = 0
joyAxes = [32768, 32768, 32768, 32768, 32768, 32768]
joyAxisMap = [AXIS_TURN, AXIS_FORWARD, AXIS_NADA, AXIS_NADA, AXIS_NADA, AXIS_NADA]
joyControlMap = [JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS]
inputRegistry = void
noMouseRequested = false
noJoystickRequested = false
directInputRequested = false
joystickTestSnapshot = false
joystickStartupOverride = void
joyPov = 65535
joySnapshotButtons = 0
bindings = []
polledBindings = []
polledKeyDownSnapshot = bytes(256)
polledKeyPressedSnapshot = bytes(256)
polledKeyQueryMask = bytes(256)
eventKeyDownStates = bytes(256)
gameplayTransitionBlocked = false
gameplayTransitionHeldCodes = []
alwaysMouseLook = false

// cl_input.c's kbutton_t is deliberately represented as a three-element
// mutable value: two independently held key numbers followed by the original
// state bitfield (down=1, impulse-down=2, impulse-up=4).
inMLook = [0, 0, 0]
inKLook = [0, 0, 0]
inLeft = [0, 0, 0]
inRight = [0, 0, 0]
inForward = [0, 0, 0]
inBack = [0, 0, 0]
inLookup = [0, 0, 0]
inLookdown = [0, 0, 0]
inMoveleft = [0, 0, 0]
inMoveright = [0, 0, 0]
inStrafe = [0, 0, 0]
inSpeed = [0, 0, 0]
inUse = [0, 0, 0]
inJump = [0, 0, 0]
inAttack = [0, 0, 0]
inUp = [0, 0, 0]
inDown = [0, 0, 0]
inImpulse = 0
pitchDriftStopRequested = false
pitchDriftStartRequested = false
lookSpringEnabled = false

// Keep the stock kbutton command set in persistent storage.  Constructing this
// array in buttonCommands used to allocate it multiple times in every gameplay
// frame while the live binding poll was active.
buttonCommandNames = [
  "+klook", "+mlook", "+moveup", "+movedown", "+left", "+right",
  "+forward", "+back", "+lookup", "+lookdown", "+moveleft",
  "+moveright", "+speed", "+strafe", "+attack", "+use", "+jump",
]

// Create and initialize button.
function createButton()
  return [0, 0, 0]
end function

// KeyDown/KeyUp retain the original two-key ownership rule. A key number of
// -1 is the console's manual, continuously-held form; void on KeyUp is the
// original "unstick this action" command with no key-number argument.
function KeyDown(button, key)
  if key is void then key = -1 end if
  if key == button[0] or key == button[1] then return false end if
  if button[0] == 0 then
    button[0] = key
  else if button[1] == 0 then
    button[1] = key
  else
    print "Three keys down for a button!"
    return false
  end if
  if (button[2] & 1) != 0 then return false end if
  button[2] = button[2] | 3
  return true
end function

// Provide key up behavior for the active subsystem.
function KeyUp(button, key)
  if key is void then
    button[0] = 0
    button[1] = 0
    button[2] = 4
    return true
  end if
  if button[0] == key then
    button[0] = 0
  else if button[1] == key then
    button[1] = 0
  else
    return false
  end if
  if button[0] != 0 or button[1] != 0 then return false end if
  if (button[2] & 1) == 0 then return false end if
  button[2] = (button[2] & ~1) | 4
  return true
end function

// Apply the Quake-compatible cl key state behavior.
function CL_KeyState(button)
  impulseDown = (button[2] & 2) != 0
  impulseUp = (button[2] & 4) != 0
  down = (button[2] & 1) != 0
  value = 0.0
  if impulseDown and impulseUp then
    if down then value = 0.75 else value = 0.25 end if
  else if impulseDown then
    if down then value = 0.5 end if
  else if not impulseUp and down then
    value = 1.0
  end if
  button[2] = button[2] & 1
  return value
end function

// Mirror Quake's IN_KLookDown routine and its observable state changes.
function IN_KLookDown(key) return KeyDown(inKLook, key) end function
// Mirror Quake's IN_KLookUp routine and its observable state changes.
function IN_KLookUp(key) return KeyUp(inKLook, key) end function
// Mirror Quake's IN_MLookDown routine and its observable state changes.
function IN_MLookDown(key) return KeyDown(inMLook, key) end function
// Mirror Quake's IN_MLookUp routine and its observable state changes.
function IN_MLookUp(key)
  result = KeyUp(inMLook, key)
  if (inMLook[2] & 1) == 0 and lookSpringEnabled then requestStartPitchDrift() end if
  return result
end function
// Mirror Quake's IN_UpDown routine and its observable state changes.
function IN_UpDown(key) return KeyDown(inUp, key) end function
// Mirror Quake's IN_UpUp routine and its observable state changes.
function IN_UpUp(key) return KeyUp(inUp, key) end function
// Mirror Quake's IN_DownDown routine and its observable state changes.
function IN_DownDown(key) return KeyDown(inDown, key) end function
// Mirror Quake's IN_DownUp routine and its observable state changes.
function IN_DownUp(key) return KeyUp(inDown, key) end function
// Mirror Quake's IN_LeftDown routine and its observable state changes.
function IN_LeftDown(key) return KeyDown(inLeft, key) end function
// Mirror Quake's IN_LeftUp routine and its observable state changes.
function IN_LeftUp(key) return KeyUp(inLeft, key) end function
// Mirror Quake's IN_RightDown routine and its observable state changes.
function IN_RightDown(key) return KeyDown(inRight, key) end function
// Mirror Quake's IN_RightUp routine and its observable state changes.
function IN_RightUp(key) return KeyUp(inRight, key) end function
// Mirror Quake's IN_ForwardDown routine and its observable state changes.
function IN_ForwardDown(key) return KeyDown(inForward, key) end function
// Mirror Quake's IN_ForwardUp routine and its observable state changes.
function IN_ForwardUp(key) return KeyUp(inForward, key) end function
// Mirror Quake's IN_BackDown routine and its observable state changes.
function IN_BackDown(key) return KeyDown(inBack, key) end function
// Mirror Quake's IN_BackUp routine and its observable state changes.
function IN_BackUp(key) return KeyUp(inBack, key) end function
// Mirror Quake's IN_LookupDown routine and its observable state changes.
function IN_LookupDown(key) return KeyDown(inLookup, key) end function
// Mirror Quake's IN_LookupUp routine and its observable state changes.
function IN_LookupUp(key) return KeyUp(inLookup, key) end function
// Mirror Quake's IN_LookdownDown routine and its observable state changes.
function IN_LookdownDown(key) return KeyDown(inLookdown, key) end function
// Mirror Quake's IN_LookdownUp routine and its observable state changes.
function IN_LookdownUp(key) return KeyUp(inLookdown, key) end function
// Mirror Quake's IN_MoveleftDown routine and its observable state changes.
function IN_MoveleftDown(key) return KeyDown(inMoveleft, key) end function
// Mirror Quake's IN_MoveleftUp routine and its observable state changes.
function IN_MoveleftUp(key) return KeyUp(inMoveleft, key) end function
// Mirror Quake's IN_MoverightDown routine and its observable state changes.
function IN_MoverightDown(key) return KeyDown(inMoveright, key) end function
// Mirror Quake's IN_MoverightUp routine and its observable state changes.
function IN_MoverightUp(key) return KeyUp(inMoveright, key) end function
// Mirror Quake's IN_SpeedDown routine and its observable state changes.
function IN_SpeedDown(key) return KeyDown(inSpeed, key) end function
// Mirror Quake's IN_SpeedUp routine and its observable state changes.
function IN_SpeedUp(key) return KeyUp(inSpeed, key) end function
// Mirror Quake's IN_StrafeDown routine and its observable state changes.
function IN_StrafeDown(key) return KeyDown(inStrafe, key) end function
// Mirror Quake's IN_StrafeUp routine and its observable state changes.
function IN_StrafeUp(key) return KeyUp(inStrafe, key) end function
// Mirror Quake's IN_AttackDown routine and its observable state changes.
function IN_AttackDown(key) return KeyDown(inAttack, key) end function
// Mirror Quake's IN_AttackUp routine and its observable state changes.
function IN_AttackUp(key) return KeyUp(inAttack, key) end function
// Mirror Quake's IN_UseDown routine and its observable state changes.
function IN_UseDown(key) return KeyDown(inUse, key) end function
// Mirror Quake's IN_UseUp routine and its observable state changes.
function IN_UseUp(key) return KeyUp(inUse, key) end function
// Mirror Quake's IN_JumpDown routine and its observable state changes.
function IN_JumpDown(key) return KeyDown(inJump, key) end function
// Mirror Quake's IN_JumpUp routine and its observable state changes.
function IN_JumpUp(key) return KeyUp(inJump, key) end function

// Mirror Quake's IN_Impulse routine and its observable state changes.
function IN_Impulse(value)
  global inImpulse
  if value is string then value = common.atoi(value) end if
  inImpulse = value
  return inImpulse
end function

// Provide request stop pitch drift behavior for the active subsystem.
function requestStopPitchDrift()
  global pitchDriftStopRequested
  pitchDriftStopRequested = true
  return true
end function

// Provide request start pitch drift behavior for the active subsystem.
function requestStartPitchDrift()
  global pitchDriftStartRequested
  pitchDriftStartRequested = true
  return true
end function

// Consume pending state for consume pitch drift requests.
function consumePitchDriftRequests()
  global pitchDriftStopRequested, pitchDriftStartRequested
  result = [pitchDriftStopRequested, pitchDriftStartRequested]
  pitchDriftStopRequested = false
  pitchDriftStartRequested = false
  return result
end function

// Update module state for look spring.
function setLookSpring(enabled)
  global lookSpringEnabled
  lookSpringEnabled = enabled
  return lookSpringEnabled
end function

// Convert data for lower.
function lower(text)
  return bio.lower(text)
end function

// Return key code for name derived from the active module state.
function keyCodeForName(name)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  wanted = lower(name)
  if wanted == "tab" then return 9 end if
  if wanted == "enter" then return 13 end if
  if wanted == "escape" or wanted == "esc" then return 27 end if
  if wanted == "space" then return 32 end if
  if wanted == "backspace" then return 127 end if
  if wanted == "uparrow" then return 128 end if
  if wanted == "downarrow" then return 129 end if
  if wanted == "leftarrow" then return 130 end if
  if wanted == "rightarrow" then return 131 end if
  if wanted == "alt" then return 132 end if
  if wanted == "ctrl" or wanted == "control" then return 133 end if
  if wanted == "shift" then return 134 end if
  if wanted == "ins" then return 147 end if
  if wanted == "del" or wanted == "delete" then return 148 end if
  if wanted == "pgdn" then return 149 end if
  if wanted == "pgup" then return 150 end if
  if wanted == "home" then return 151 end if
  if wanted == "end" then return 152 end if
  if wanted == "mouse1" then return 200 end if
  if wanted == "mouse2" then return 201 end if
  if wanted == "mouse3" then return 202 end if
  if wanted == "mwheelup" then return 239 end if
  if wanted == "mwheeldown" then return 240 end if
  if wanted == "pause" then return 255 end if
  if len(bytes(wanted)) >= 4 and decode(slice(bytes(wanted), 0, 3)) == "joy" then
    number = toNumber(decode(slice(bytes(wanted), 3, len(bytes(wanted)) - 3)))
    if number is not void and number >= 1 and number <= 4 then return 202 + number end if
  end if
  if len(bytes(wanted)) >= 4 and decode(slice(bytes(wanted), 0, 3)) == "aux" then
    number = toNumber(decode(slice(bytes(wanted), 3, len(bytes(wanted)) - 3)))
    if number is not void and number >= 1 and number <= 32 then return 206 + number end if
  end if
  if len(bytes(wanted)) >= 2 and bytes(wanted)[0] == 102 then
    number = toNumber(decode(slice(bytes(wanted), 1, len(bytes(wanted)) - 1)))
    if number is not void and number >= 1 and number <= 12 then return 134 + number end if
  end if
  if wanted == "semicolon" then return 59 end if
  source = bytes(wanted)
  if len(source) == 1 then return source[0] end if
  return -1
end function

// Provide key name for code behavior for the active subsystem.
function keyNameForCode(code)
  if code == -1 then return "<KEY NOT FOUND>" end if
  if code > 32 and code < 127 then return decode(bytes([code])) end if
  if code == 9 then return "TAB" end if
  if code == 13 then return "ENTER" end if
  if code == 27 then return "ESCAPE" end if
  if code == 32 then return "SPACE" end if
  if code == 127 then return "BACKSPACE" end if
  if code == 128 then return "UPARROW" end if
  if code == 129 then return "DOWNARROW" end if
  if code == 130 then return "LEFTARROW" end if
  if code == 131 then return "RIGHTARROW" end if
  if code == 132 then return "ALT" end if
  if code == 133 then return "CTRL" end if
  if code == 134 then return "SHIFT" end if
  if code >= 135 and code <= 146 then return "F" + (code - 134) end if
  if code == 147 then return "INS" end if
  if code == 148 then return "DEL" end if
  if code == 149 then return "PGDN" end if
  if code == 150 then return "PGUP" end if
  if code == 151 then return "HOME" end if
  if code == 152 then return "END" end if
  if code >= 200 and code <= 202 then return "MOUSE" + (code - 199) end if
  if code >= 203 and code <= 206 then return "JOY" + (code - 202) end if
  if code >= 207 and code <= 238 then return "AUX" + (code - 206) end if
  if code == 239 then return "MWHEELUP" end if
  if code == 240 then return "MWHEELDOWN" end if
  if code == 255 then return "PAUSE" end if
  return "<UNKNOWN KEYNUM>"
end function

// Provide bind key behavior for the active subsystem.
function bindKey(keyName, command)
  global bindings
  code = keyCodeForName(keyName)
  if code < 0 then return false end if
  return setBindingCode(code, command)
end function

// Update module state for binding code.
function setBindingCode(code, command)
  global bindings
  if code < 0 or code > 255 then return false end if
  index = 0
  while index < len(bindings)
    if bindings[index][0] == code then
      bindings[index] = [code, keyNameForCode(code), command]
      rebuildPolledBindings()
      return true
    end if
    index = index + 1
  end while
  bindings = bindings + [[code, keyNameForCode(code), command]]
  rebuildPolledBindings()
  return true
end function

// Provide binding for code behavior for the active subsystem.
function bindingForCode(code)
  for each item in bindings
    if item[0] == code then return item[2] end if
  end for
  return void
end function

// Report whether binding code.
function hasBindingCode(code)
  for each item in bindings
    if item[0] == code then return true end if
  end for
  return false
end function

// Provide unbind key behavior for the active subsystem.
function unbindKey(keyName)
  global bindings
  code = keyCodeForName(keyName)
  if code < 0 then return false end if
  result = []
  for each item in bindings
    if item[0] != code then result = result + [item] end if
  end for
  bindings = result
  rebuildPolledBindings()
  return true
end function

// Provide unbind all behavior for the active subsystem.
function unbindAll()
  global bindings
  bindings = []
  rebuildPolledBindings()
  return true
end function

// Update module state for bindings.
function resetBindings()
  unbindAll()
  bindKey("`", "toggleconsole")
  bindKey("UPARROW", "+forward")
  bindKey("DOWNARROW", "+back")
  bindKey("LEFTARROW", "+left")
  bindKey("RIGHTARROW", "+right")
  bindKey("ALT", "+strafe")
  bindKey("W", "+forward")
  bindKey("S", "+back")
  bindKey("A", "+moveleft")
  bindKey("D", "+moveright")
  bindKey("CTRL", "+attack")
  bindKey("MOUSE1", "+attack")
  bindKey("SPACE", "+jump")
  bindKey("MOUSE2", "+jump")
  bindKey("SHIFT", "+speed")
  bindKey("1", "impulse 1")
  bindKey("2", "impulse 2")
  bindKey("3", "impulse 3")
  bindKey("4", "impulse 4")
  bindKey("5", "impulse 5")
  bindKey("6", "impulse 6")
  bindKey("7", "impulse 7")
  bindKey("8", "impulse 8")
  return true
end function

// Install the modern movement layout once when upgrading an original Quake
// configuration.  Key_StringToKeynum deliberately distinguishes one-character
// upper- and lower-case names, while live Win32 polling uses the lower-case
// slots installed by resetBindings.  Clear stale upper-case aliases so one
// physical key cannot own two different kbutton commands.
function applyModernMovementBindings()
  setBindingCode(87, "")
  setBindingCode(83, "")
  setBindingCode(65, "")
  setBindingCode(68, "")
  setBindingCode(119, "+forward")
  setBindingCode(115, "+back")
  setBindingCode(97, "+moveleft")
  setBindingCode(100, "+moveright")
  return true
end function

// Provide bindings for command behavior for the active subsystem.
function bindingsForCommand(command)
  wanted = lower(command)
  result = []
  for each item in bindings
    if lower(item[2]) == wanted then
      result = result + [item[1]]
      if len(result) >= 2 then return result end if
    end if
  end for
  return result
end function

// Provide binding for command behavior for the active subsystem.
function bindingForCommand(command)
  found = bindingsForCommand(command)
  if len(found) == 0 then return "???" end if
  if len(found) == 1 then return found[0] end if
  return found[0] + " or " + found[1]
end function

// Provide unbind command behavior for the active subsystem.
function unbindCommand(command)
  global bindings
  wanted = lower(command)
  result = []
  for each item in bindings
    if lower(item[2]) != wanted then result = result + [item] end if
  end for
  bindings = result
  rebuildPolledBindings()
  return true
end function

// Provide command for key behavior for the active subsystem.
function commandForKey(keyName)
  code = keyCodeForName(keyName)
  binding = bindingForCode(code)
  if binding is not void then return binding end if
  return ""
end function

// Convert data for quote binding.
function quoteBinding(text)
  source = bytes(text)
  result = ""
  index = 0
  while index < len(source)
    value = source[index]
    if value == 34 or value == 92 then result = result + "\\" end if
    result = result + decode(bytes([value]))
    index = index + 1
  end while
  return result
end function

// Provide binding text behavior for the active subsystem.
function bindingText()
  text = ""
  code = 0
  while code < 256
    binding = bindingForCode(code)
    if binding is not void and binding != "" then
      text = text + "bind \"" + keyNameForCode(code) + "\" \"" + quoteBinding(binding) + "\"\n"
    end if
    code = code + 1
  end while
  return text
end function

// Provide key is down behavior for the active subsystem.
function keyIsDown(code)
  if code == 200 then return (win.mouseButtons() & 1) != 0 end if
  if code == 201 then return (win.mouseButtons() & 2) != 0 end if
  if code == 202 then return (win.mouseButtons() & 4) != 0 end if
  if code >= 203 and code <= 206 then return (joyOldButtonState & (1 << (code - 203))) != 0 end if
  if code >= 211 and code <= 234 then return (joyOldButtonState & (1 << (code - 207))) != 0 end if
  if code >= 235 and code <= 238 then return (joyOldPovState & (1 << (code - 235))) != 0 end if
  // Ordered WM_KEYDOWN/WM_KEYUP state is the WinQuake-compatible authority.
  // The asynchronous query remains a fallback for a delayed window message.
  if code >= 0 and code < len(eventKeyDownStates) and eventKeyDownStates[code] != 0 then return true end if
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 then return false end if
  return win.keyDown(virtualKey)
end function

// Test a physical key while reusing the mouse snapshot captured for this poll.
// Keyboard and joystick semantics deliberately remain identical to keyIsDown.
function keyIsDownWithMouseSnapshot(code, mouseButtons)
  if code == 200 then return (mouseButtons & 1) != 0 end if
  if code == 201 then return (mouseButtons & 2) != 0 end if
  if code == 202 then return (mouseButtons & 4) != 0 end if
  if code >= 203 and code <= 206 then return (joyOldButtonState & (1 << (code - 203))) != 0 end if
  if code >= 211 and code <= 234 then return (joyOldButtonState & (1 << (code - 207))) != 0 end if
  if code >= 235 and code <= 238 then return (joyOldPovState & (1 << (code - 235))) != 0 end if
  if code >= 0 and code < len(eventKeyDownStates) and eventKeyDownStates[code] != 0 then return true end if
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 then return false end if
  return win.keyDown(virtualKey)
end function

// Provide virtual key for code behavior for the active subsystem.
function virtualKeyForCode(code)
  if code >= 97 and code <= 122 then return code - 32 end if
  if code >= 48 and code <= 57 then return code end if
  if code == 9 or code == 13 or code == 27 or code == 32 then return code end if
  if code == 127 then return c.VK_BACK end if
  if code == 128 then return c.VK_UP end if
  if code == 129 then return c.VK_DOWN end if
  if code == 130 then return c.VK_LEFT end if
  if code == 131 then return c.VK_RIGHT end if
  if code == 132 then return c.VK_ALT end if
  if code == 133 then return c.VK_CONTROL end if
  if code == 134 then return c.VK_SHIFT end if
  if code >= 135 and code <= 146 then return c.VK_F1 + code - 135 end if
  if code == 147 then return 45 end if
  if code == 148 then return c.VK_DELETE end if
  if code == 149 then return 34 end if
  if code == 150 then return 33 end if
  if code == 151 then return 36 end if
  if code == 152 then return 35 end if
  if code == 255 then return 19 end if
  if code == 96 or code == 126 then return c.VK_OEM_3 end if
  if code == 45 or code == 95 then return 189 end if
  if code == 61 or code == 43 then return 187 end if
  if code == 44 or code == 60 then return 188 end if
  if code == 46 or code == 62 then return 190 end if
  if code == 47 or code == 63 then return 191 end if
  if code == 59 or code == 58 then return 186 end if
  if code == 39 or code == 34 then return 222 end if
  if code == 91 or code == 123 then return 219 end if
  if code == 93 or code == 125 then return 221 end if
  if code == 92 or code == 124 then return 220 end if
  return -1
end function

// Provide quake key for virtual key behavior for the active subsystem.
function quakeKeyForVirtualKey(virtualKey)
  if virtualKey >= 65 and virtualKey <= 90 then return virtualKey + 32 end if
  if virtualKey >= 48 and virtualKey <= 57 then return virtualKey end if
  if virtualKey == c.VK_TAB or virtualKey == c.VK_RETURN or virtualKey == c.VK_ESCAPE or virtualKey == c.VK_SPACE then return virtualKey end if
  if virtualKey == c.VK_BACK then return 127 end if
  if virtualKey == c.VK_UP then return 128 end if
  if virtualKey == c.VK_DOWN then return 129 end if
  if virtualKey == c.VK_LEFT then return 130 end if
  if virtualKey == c.VK_RIGHT then return 131 end if
  if virtualKey == c.VK_ALT then return 132 end if
  if virtualKey == c.VK_CONTROL then return 133 end if
  if virtualKey == c.VK_SHIFT then return 134 end if
  if virtualKey >= c.VK_F1 and virtualKey <= c.VK_F12 then return 135 + virtualKey - c.VK_F1 end if
  if virtualKey == 45 then return 147 end if
  if virtualKey == c.VK_DELETE then return 148 end if
  if virtualKey == 34 then return 149 end if
  if virtualKey == 33 then return 150 end if
  if virtualKey == 36 then return 151 end if
  if virtualKey == 35 then return 152 end if
  if virtualKey == 19 then return 255 end if
  if virtualKey == c.VK_OEM_3 then return 96 end if
  if virtualKey == 189 then return 45 end if
  if virtualKey == 187 then return 61 end if
  if virtualKey == 188 then return 44 end if
  if virtualKey == 190 then return 46 end if
  if virtualKey == 191 then return 47 end if
  if virtualKey == 186 then return 59 end if
  if virtualKey == 222 then return 39 end if
  if virtualKey == 219 then return 91 end if
  if virtualKey == 221 then return 93 end if
  if virtualKey == 220 then return 92 end if
  return -1
end function

// gl_vidnt.c does not translate keyboard messages through virtual-key values.
// It uses bits 16..23 of lParam, i.e. the hardware scan code.  Keeping that
// mapping here preserves keypad/navigation distinctions and makes keyboard
// input independent of the active Windows keyboard layout.
function quakeKeyForScanCode(scanCode)
  if scanCode < 0 or scanCode > 127 then return 0 end if
  table = [
    0, 27, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 127, 9,
    113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 13, 133, 97, 115,
    100, 102, 103, 104, 106, 107, 108, 59, 39, 96, 134, 92, 122, 120, 99, 118,
    98, 110, 109, 44, 46, 47, 134, 42, 132, 32, 0, 135, 136, 137, 138, 139,
    140, 141, 142, 143, 144, 255, 0, 151, 128, 150, 45, 130, 53, 131, 43, 152,
    129, 149, 147, 148, 0, 0, 0, 145, 146, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  ]
  return table[scanCode]
end function

// Provide action down behavior for the active subsystem.
function actionDown(command)
  wanted = lower(command)
  for each item in bindings
    if lower(item[2]) == wanted and keyIsDown(item[0]) then return true end if
  end for
  return false
end function

// Provide action pressed behavior for the active subsystem.
function actionPressed(command)
  wanted = lower(command)
  for each item in bindings
    if lower(item[2]) == wanted then
      code = item[0]
      if keyPressedForCode(code) then return true end if
    end if
  end for
  return false
end function

// Provide button for command behavior for the active subsystem.
function buttonForCommand(command)
  wanted = lower(command)
  if wanted == "+klook" then return inKLook end if
  if wanted == "+mlook" then return inMLook end if
  if wanted == "+moveup" then return inUp end if
  if wanted == "+movedown" then return inDown end if
  if wanted == "+left" then return inLeft end if
  if wanted == "+right" then return inRight end if
  if wanted == "+forward" then return inForward end if
  if wanted == "+back" then return inBack end if
  if wanted == "+lookup" then return inLookup end if
  if wanted == "+lookdown" then return inLookdown end if
  if wanted == "+moveleft" then return inMoveleft end if
  if wanted == "+moveright" then return inMoveright end if
  if wanted == "+speed" then return inSpeed end if
  if wanted == "+strafe" then return inStrafe end if
  if wanted == "+attack" then return inAttack end if
  if wanted == "+use" then return inUse end if
  if wanted == "+jump" then return inJump end if
  return void
end function

// Parse the exact canonical impulse binding accepted by the original polling
// path.  Non-impulse and non-canonical command strings return zero.
function impulseForCommand(command)
  source = bytes(command)
  if len(source) < 9 or decode(slice(source, 0, 8)) != "impulse " then return 0 end if
  impulse = common.atoi(decode(slice(source, 8, len(source) - 8)))
  if impulse < 1 or impulse > 255 or command != "impulse " + impulse then return 0 end if
  return impulse
end function

// Rebuild the small, immutable-at-runtime subset needed by the live input poll.
// Bind commands that are handled solely by Key_Event are intentionally absent.
function rebuildPolledBindings()
  global polledBindings
  result = []
  for each item in bindings
    command = lower(item[2])
    button = buttonForCommand(command)
    impulse = 0
    if button is void then impulse = impulseForCommand(command) end if
    if button is not void or impulse != 0 then
      result = result + [[item[0], button, impulse, command]]
    end if
  end for
  polledBindings = result
  index = 0
  while index < len(polledKeyQueryMask)
    polledKeyQueryMask[index] = 0
    index = index + 1
  end while
  for each item in polledBindings
    virtualKey = virtualKeyForCode(item[0])
    if virtualKey >= 0 and virtualKey < len(polledKeyQueryMask) then polledKeyQueryMask[virtualKey] = 1 end if
  end for
  return true
end function

// Provide button commands behavior for the active subsystem.
function buttonCommands()
  return buttonCommandNames
end function

// Provide binding holds key behavior for the active subsystem.
function bindingHoldsKey(command, key)
  if key == -1 then return true end if
  wanted = lower(command)
  for each item in bindings
    if item[0] == key and lower(item[2]) == wanted and keyIsDown(key) then return true end if
  end for
  return false
end function

// Check a held owner against the pre-normalized polling cache and current
// physical snapshot without allocating or rescanning unrelated bind commands.
function polledBindingHoldsKey(command, key, mouseButtons)
  if key == -1 then return true end if
  for each item in polledBindings
    if item[0] == key and item[3] == command then
      if polledKeyDownAt(key, mouseButtons) then return true end if
    end if
  end for
  return false
end function

// Resolve a binding level from the frame-local bulk keyboard/mouse snapshot.
function polledKeyDownAt(code, mouseButtons)
  if code == 200 then return (mouseButtons & 1) != 0 end if
  if code == 201 then return (mouseButtons & 2) != 0 end if
  if code == 202 then return (mouseButtons & 4) != 0 end if
  if code >= 203 and code <= 206 then return (joyOldButtonState & (1 << (code - 203))) != 0 end if
  if code >= 211 and code <= 234 then return (joyOldButtonState & (1 << (code - 207))) != 0 end if
  if code >= 235 and code <= 238 then return (joyOldPovState & (1 << (code - 235))) != 0 end if
  if code >= 0 and code < len(eventKeyDownStates) and eventKeyDownStates[code] != 0 then return true end if
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 or virtualKey >= len(polledKeyDownSnapshot) then return false end if
  return polledKeyDownSnapshot[virtualKey] != 0
end function

// Record the ordered Quake key level delivered by the Win32 event queue.
// Keeping this separate from kbutton ownership lets live polling repair a
// consumed command without trusting a transient asynchronous key sample.
function setEventKeyState(code, down)
  if code < 0 or code >= len(eventKeyDownStates) then return false end if
  if down then eventKeyDownStates[code] = 1 else eventKeyDownStates[code] = 0 end if
  return true
end function

// Clear all ordered keyboard levels after focus loss or input shutdown.
function clearEventKeyStates()
  index = 0
  while index < len(eventKeyDownStates)
    eventKeyDownStates[index] = 0
    index = index + 1
  end while
  return true
end function

// Resolve a binding press edge from the frame-local bulk keyboard snapshot.
function polledKeyPressedAt(code)
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 or virtualKey >= len(polledKeyPressedSnapshot) then return false end if
  return polledKeyPressedSnapshot[virtualKey] != 0
end function

// Provide key pressed for code behavior for the active subsystem.
function keyPressedForCode(code)
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 then return false end if
  return win.keyPressed(virtualKey)
end function

// Translate the native polling API into the same edge events Key_Event feeds
// into cl_input.c. This preserves ownership when two bound keys hold one
// action, and also preserves a press/release completed between two frames.
function synchronizeButton(command)
  button = buttonForCommand(command)
  if button is void then return false end if
  wanted = lower(command)
  for each item in bindings
    if lower(item[2]) == wanted then
      code = item[0]
      if keyIsDown(code) then
        // WM_KEYDOWN records an edge as well as the held state.  Key_Event has
        // already delivered the matching +command, so consume that native edge
        // while the key is still held.  Leaving it pending made the eventual
        // key-up look like a complete tap and injected a spurious quarter-frame
        // move (especially visible when releasing S / +back).
        keyPressedForCode(code)
        KeyDown(button, code)
      else if keyPressedForCode(code) then
        KeyDown(button, code)
        KeyUp(button, code)
      end if
    end if
  end for
  first = button[0]
  second = button[1]
  if first != 0 and not bindingHoldsKey(command, first) then KeyUp(button, first) end if
  if second != 0 and not bindingHoldsKey(command, second) then KeyUp(button, second) end if
  return true
end function

// Return cvar value derived from the active module state.
function cvarValue(name, fallback)
  if inputRegistry is void then return fallback end if
  variable = cv.find(inputRegistry, name)
  if variable is void then return fallback end if
  return variable.value
end function

// Mirror Quake's Joy_AdvancedUpdate_f routine and its observable state changes.
function Joy_AdvancedUpdate_f()
  global joyAxisMap, joyControlMap, joyAdvancedInitialized
  joyAxisMap = [AXIS_NADA, AXIS_NADA, AXIS_NADA, AXIS_NADA, AXIS_NADA, AXIS_NADA]
  joyControlMap = [JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS, JOY_ABSOLUTE_AXIS]
  if cvarValue("joyadvanced", 0.0) == 0.0 then
    joyAxisMap[0] = AXIS_TURN
    joyAxisMap[1] = AXIS_FORWARD
  else
    names = ["joyadvaxisx", "joyadvaxisy", "joyadvaxisz", "joyadvaxisr", "joyadvaxisu", "joyadvaxisv"]
    index = 0
    while index < JOY_MAX_AXES
      setting = native.trunc(cvarValue(names[index], 0.0))
      joyAxisMap[index] = setting & 15
      joyControlMap[index] = setting & JOY_RELATIVE_AXIS
      index = index + 1
    end while
  end if
  joyAdvancedInitialized = true
  return joyAxisMap
end function

// Provide raw value pointer behavior for the active subsystem.
function RawValuePointer(axis)
  if axis < 0 or axis >= JOY_MAX_AXES then return 32768 end if
  return joyAxes[axis]
end function

// Mirror Quake's IN_StartupJoystick routine and its observable state changes.
function IN_StartupJoystick()
  global joyAvailable, joyAdvancedInitialized, joyHasPov, joyButtonCount
  global joyOldButtonState, joyOldPovState, joystickTestSnapshot
  joyAvailable = false
  joyAdvancedInitialized = false
  joyOldButtonState = 0
  joyOldPovState = 0
  if noJoystickRequested then return false end if
  if joystickStartupOverride is not void then
    joyButtonCount = joystickStartupOverride[0]
    joyHasPov = joystickStartupOverride[1]
    joyAvailable = true
    joystickTestSnapshot = true
    return true
  end if
  joystickTestSnapshot = false
  joyAvailable = win.joyStartup()
  if not joyAvailable then return false end if
  joyHasPov = win.joyHasPov()
  joyButtonCount = win.joyButtonCount()
  return true
end function

// Update module state for joystick snapshot.
function setJoystickSnapshot(axes, buttons, pov, buttonCount, hasPov)
  global joyAxes, joyOldButtonState, joyOldPovState, joyButtonCount
  global joyHasPov, joyAvailable, joystickTestSnapshot, joyPov, joySnapshotButtons
  joyAxes = axes
  joyOldButtonState = 0
  joyOldPovState = 0
  joyButtonCount = buttonCount
  joyHasPov = hasPov
  joyPov = pov
  joySnapshotButtons = buttons
  joyAvailable = true
  joystickTestSnapshot = true
  return true
end function

// Update module state for joystick snapshot.
function updateJoystickSnapshot(axes, buttons, pov)
  global joyAxes, joyPov, joySnapshotButtons
  joyAxes = axes
  joyPov = pov
  joySnapshotButtons = buttons
  return joystickTestSnapshot
end function

// Update module state for joystick snapshot.
function clearJoystickSnapshot()
  global joyAvailable, joystickTestSnapshot, joyOldButtonState, joyOldPovState
  joyAvailable = false
  joystickTestSnapshot = false
  joyOldButtonState = 0
  joyOldPovState = 0
  return true
end function

// Mirror Quake's IN_DifferentialSetJoystickStartup routine and its observable state changes.
function IN_DifferentialSetJoystickStartup(buttonCount, hasPov)
  global joystickStartupOverride
  joystickStartupOverride = [buttonCount, hasPov]
  return true
end function

// Mirror Quake's IN_DifferentialClearJoystickStartup routine and its observable state changes.
function IN_DifferentialClearJoystickStartup()
  global joystickStartupOverride
  joystickStartupOverride = void
  return true
end function

// Mirror Quake's IN_ReadJoystick routine and its observable state changes.
function IN_ReadJoystick()
  global joyAxes, joyPov
  if not joyAvailable then return false end if
  if joystickTestSnapshot then return true end if
  if not win.joyRead() then return false end if
  index = 0
  while index < JOY_MAX_AXES
    joyAxes[index] = win.joyAxis(index)
    index = index + 1
  end while
  if cvarValue("joywwhack1", 0.0) != 0.0 then joyAxes[4] = joyAxes[4] + 100 end if
  joyPov = win.joyPov()
  return true
end function

// Mirror Quake's IN_Commands routine and its observable state changes.
function IN_Commands()
  global joyOldButtonState, joyOldPovState
  events = []
  // WinQuake consumes the JOYINFOEX snapshot left by startup/the previous
  // IN_JoyMove here.  IN_JoyMove performs the fresh read later in the frame.
  // Reading again in IN_Commands moved button edges one poll earlier and could
  // observe axes and buttons from different hardware samples.
  if not joyAvailable then return events end if
  buttons = 0
  if joystickTestSnapshot then buttons = joySnapshotButtons else buttons = win.joyButtons() end if
  index = 0
  while index < joyButtonCount
    mask = 1 << index
    key = 207 + index
    if index < 4 then key = 203 + index end if
    if (buttons & mask) != 0 and (joyOldButtonState & mask) == 0 then events = events + [[key, true]] end if
    if (buttons & mask) == 0 and (joyOldButtonState & mask) != 0 then events = events + [[key, false]] end if
    index = index + 1
  end while
  joyOldButtonState = buttons

  if joyHasPov then
    povState = 0
    if joyPov != 65535 then
      if joyPov == 0 then povState = povState | 1 end if
      if joyPov == 9000 then povState = povState | 2 end if
      if joyPov == 18000 then povState = povState | 4 end if
      if joyPov == 27000 then povState = povState | 8 end if
    end if
    index = 0
    while index < 4
      mask = 1 << index
      key = 235 + index
      if (povState & mask) != 0 and (joyOldPovState & mask) == 0 then events = events + [[key, true]] end if
      if (povState & mask) == 0 and (joyOldPovState & mask) != 0 then events = events + [[key, false]] end if
      index = index + 1
    end while
    joyOldPovState = povState
  end if
  return events
end function

// Mirror Quake's IN_PollButtonCommands routine and its observable state changes.
function IN_PollButtonCommands()
  // Poll the bindings once.  The previous implementation performed 17 full
  // binding scans for kbuttons plus another 255 full scans for impulses, which
  // produced thousands of temporary strings per frame and visible GC hitches.
  win.keySnapshot(polledKeyDownSnapshot, polledKeyPressedSnapshot, polledKeyQueryMask)
  mouseButtons = win.mouseButtons()
  for each item in polledBindings
    button = item[1]
    code = item[0]
    if button is not void then
      if polledKeyDownAt(code, mouseButtons) then
        // Key_Event normally delivered the +command already.  Consume the
        // parallel native edge so release cannot later become a false tap.
        KeyDown(button, code)
      else if polledKeyPressedAt(code) then
        // Preserve a complete press/release occurring between host frames.
        KeyDown(button, code)
        KeyUp(button, code)
      end if
    else
      if polledKeyPressedAt(code) then IN_Impulse(item[2]) end if
    end if
  end for

  // A binding can change while its key owns a kbutton.  Releasing stale owners
  // after the single poll retains the original two-key ownership behavior.
  for each command in buttonCommandNames
    button = buttonForCommand(command)
    first = button[0]
    second = button[1]
    if first != 0 and not polledBindingHoldsKey(command, first, mouseButtons) then KeyUp(button, first) end if
    if second != 0 and not polledBindingHoldsKey(command, second, mouseButtons) then KeyUp(button, second) end if
  end for
  return true
end function

// Return first pressed key for the active module state.
function firstPressedKey()
  buttons = win.mouseButtons()
  if (buttons & 1) != 0 then return "MOUSE1" end if
  if (buttons & 2) != 0 then return "MOUSE2" end if
  if (buttons & 4) != 0 then return "MOUSE3" end if
  code = 8
  while code <= 255
    if win.keyPressed(code) then return keyNameForCode(code) end if
    code = code + 1
  end while
  return ""
end function

// Create and initialize command.
function createCommand()
  return t.UserCommand(t.Vec3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, 0, 0, 0)
end function

// Update module state for button.
function resetButton(button)
  button[0] = 0
  button[1] = 0
  button[2] = 0
  return button
end function

// Update subsystem configuration for configure platform.
function configurePlatform(registry, noMouse, noJoystick, useDirectInput)
  global inputRegistry, noMouseRequested, noJoystickRequested, directInputRequested
  inputRegistry = registry
  noMouseRequested = noMouse
  noJoystickRequested = noJoystick
  directInputRequested = useDirectInput
  return true
end function

// Mirror Quake's IN_DifferentialSetMouse routine and its observable state changes.
function IN_DifferentialSetMouse(
  initialized,
  active,
  activateToggle,
  showToggle,
  useDirectInput,
  oldButtonState,
  accumulatedX,
  accumulatedY,
  previousX,
  previousY,
  filterReady
)
  global mouseInitialized, mouseActive, mouseActivateToggle, mouseShowToggle
  global directInput, mouseOldButtonState, mouseAccumX, mouseAccumY
  global oldMouseX, oldMouseY, mouseFilterReady
  mouseInitialized = initialized
  mouseActive = active
  mouseActivateToggle = activateToggle
  mouseShowToggle = showToggle
  directInput = useDirectInput
  mouseOldButtonState = oldButtonState
  mouseAccumX = accumulatedX
  mouseAccumY = accumulatedY
  oldMouseX = previousX
  oldMouseY = previousY
  mouseFilterReady = filterReady
  return true
end function

// Mirror Quake's IN_DifferentialState routine and its observable state changes.
function IN_DifferentialState()
  return [
    mouseInitialized,
    mouseActive,
    mouseActivateToggle,
    mouseShowToggle,
    directInput,
    mouseOldButtonState,
    mouseAccumX,
    mouseAccumY,
    oldMouseX,
    oldMouseY,
    mouseFilterReady,
    joyAvailable,
    joyButtonCount,
    joyHasPov,
    joyAdvancedInitialized,
    joyAxisMap,
    joyControlMap,
  ]
end function

// Mirror Quake's Force_CenterView_f routine and its observable state changes.
function Force_CenterView_f(command)
  command.viewAngles.x = 0.0
  return command
end function

// Mirror Quake's IN_UpdateClipCursor routine and its observable state changes.
function IN_UpdateClipCursor()
  if mouseInitialized and mouseActive and not directInput then return win.updateClipCursor() end if
  return false
end function

// Mirror Quake's IN_ShowMouse routine and its observable state changes.
function IN_ShowMouse()
  global mouseShowToggle
  if not mouseShowToggle then
    win.showCursor(true)
    mouseShowToggle = true
  end if
  return mouseShowToggle
end function

// Mirror Quake's IN_HideMouse routine and its observable state changes.
function IN_HideMouse()
  global mouseShowToggle
  if mouseShowToggle then
    win.showCursor(false)
    mouseShowToggle = false
  end if
  return not mouseShowToggle
end function

// Mirror Quake's IN_ActivateMouse routine and its observable state changes.
function IN_ActivateMouse()
  global mouseActivateToggle, mouseActive, mouseCaptured
  mouseActivateToggle = true
  if not mouseInitialized then return false end if
  win.captureMouse(true)
  mouseCaptured = true
  mouseActive = true
  resetMouse()
  return true
end function

// Mirror Quake's IN_SetQuakeMouseState routine and its observable state changes.
function IN_SetQuakeMouseState()
  if mouseActivateToggle then return IN_ActivateMouse() end if
  return false
end function

// Mirror Quake's IN_DeactivateMouse routine and its observable state changes.
function IN_DeactivateMouse()
  global mouseActivateToggle, mouseActive, mouseCaptured
  mouseActivateToggle = false
  if mouseInitialized then win.captureMouse(false) end if
  mouseCaptured = false
  mouseActive = false
  resetMouse()
  return true
end function

// Mirror Quake's IN_RestoreOriginalMouseState routine and its observable state changes.
function IN_RestoreOriginalMouseState()
  global mouseActivateToggle
  reactivate = mouseActivateToggle
  if reactivate then
    IN_DeactivateMouse()
    mouseActivateToggle = true
  end if
  IN_ShowMouse()
  IN_HideMouse()
  return true
end function

// Mirror Quake's IN_InitDInput routine and its observable state changes.
function IN_InitDInput()
  // The x64 bridge uses the ordered Win32 message FIFO and centered relative
  // cursor sampling instead of loading the obsolete DirectInput 3 mouse COM
  // interface. Its externally visible buffered semantics are equivalent.
  return mouseInitialized
end function

// Mirror Quake's IN_StartupMouse routine and its observable state changes.
function IN_StartupMouse()
  global mouseInitialized, directInput, mouseOldButtonState
  if noMouseRequested then mouseInitialized = false; return false end if
  mouseInitialized = true
  directInput = directInputRequested
  if directInput then directInput = IN_InitDInput() end if
  mouseOldButtonState = 0
  if mouseActivateToggle then IN_ActivateMouse() end if
  return true
end function

// in_win.c::IN_ClearStates only clears the active mouse device state. Keep
// this distinct from MiniQuake's full input reset, which is used at startup
// and by deterministic evidence runs to clear command buttons as well.
function IN_ClearDeviceStates()
  global mouseAccumX, mouseAccumY, mouseOldButtonState
  if mouseActive then
    mouseAccumX = 0.0
    mouseAccumY = 0.0
    mouseOldButtonState = 0
  end if
  return true
end function

// Mirror Quake's IN_ClearStates routine and its observable state changes.
function IN_ClearStates()
  global inImpulse
  for each command in buttonCommands()
    resetButton(buttonForCommand(command))
  end for
  inImpulse = 0
  IN_ClearDeviceStates()
  resetMouse()
  return true
end function

// Consume native keyboard press edges while UI-to-game handoff is blocked.
function IN_DiscardPolledKeyEdges()
  win.keySnapshot(polledKeyDownSnapshot, polledKeyPressedSnapshot, polledKeyQueryMask)
  index = 0
  while index < len(polledKeyPressedSnapshot)
    polledKeyPressedSnapshot[index] = 0
    index = index + 1
  end while
  return true
end function

// Block live gameplay controls while a menu selection or a map transition is
// still physically held.  Clearing kbutton_t alone is insufficient because
// IN_PollButtonCommands would reconstruct +attack/+jump from the held Win32
// key or mouse button on the first playable frame.
function IN_BlockGameplayTransition()
  global gameplayTransitionBlocked, gameplayTransitionHeldCodes
  gameplayTransitionHeldCodes = captureGameplayTransitionHeldCodes()
  // A synchronous map load can outlive the WM_KEYUP message for the menu key
  // that initiated it.  Do not let that old ordered event level become the
  // authority after the handoff; the captured list below is checked against
  // the current physical device level until every initiating control is up.
  clearEventKeyStates()
  IN_ClearStates()
  IN_DiscardPolledKeyEdges()
  gameplayTransitionBlocked = true
  return true
end function

// Report whether a menu/map handoff is still suppressing live controls.
function IN_GameplayTransitionBlocked()
  return gameplayTransitionBlocked
end function

// Capture only the physical +command controls that were already held when the
// UI/map transition began. Inputs first pressed after loading are intentional
// gameplay and must never extend the suppression latch.
function captureGameplayTransitionHeldCodes()
  result = []
  for each item in bindings
    command = bytes(lower(item[2]))
    if len(command) > 0 and command[0] == 43 and keyIsDown(item[0]) then
      present = false
      for each code in result
        if code == item[0] then present = true; break end if
      end for
      if not present then result = result + [item[0]] end if
    end if
  end for
  return result
end function

// Query only the current physical device level for a control captured at a
// menu/map boundary.  eventKeyDownStates intentionally is not consulted here:
// it describes the pre-transition message stream and can remain set when the
// renderer or a synchronous map load clears/recreates the native input queue.
function gameplayTransitionCodeDown(code)
  if code == 200 then return (win.mouseButtons() & 1) != 0 end if
  if code == 201 then return (win.mouseButtons() & 2) != 0 end if
  if code == 202 then return (win.mouseButtons() & 4) != 0 end if
  if code >= 203 and code <= 206 then return (joyOldButtonState & (1 << (code - 203))) != 0 end if
  if code >= 211 and code <= 234 then return (joyOldButtonState & (1 << (code - 207))) != 0 end if
  if code >= 235 and code <= 238 then return (joyOldPovState & (1 << (code - 235))) != 0 end if
  virtualKey = virtualKeyForCode(code)
  if virtualKey < 0 then return false end if
  return win.keyDown(virtualKey)
end function

// Report whether a control captured at the transition boundary remains held.
function IN_GameplayTransitionControlHeld()
  for each code in gameplayTransitionHeldCodes
    if gameplayTransitionCodeDown(code) then return true end if
  end for
  return false
end function

// Release the transition latch only after every gameplay control has returned
// to neutral.  The caller deliberately suppresses the release-detecting frame
// as well, so queued native press edges cannot leak into the new level.
function IN_ReleaseGameplayTransitionIfNeutral()
  global gameplayTransitionBlocked, gameplayTransitionHeldCodes
  if not gameplayTransitionBlocked then return true end if
  // Menu navigation can produce keyboard edges without a gameplay poll. Drain
  // them on every blocked frame, including the neutral release frame.
  IN_DiscardPolledKeyEdges()
  if IN_GameplayTransitionControlHeld() then return false end if
  IN_ClearStates()
  gameplayTransitionBlocked = false
  gameplayTransitionHeldCodes = []
  return true
end function

// Mirror Quake's IN_Init routine and its observable state changes.
function IN_Init()
  global gameplayTransitionBlocked, gameplayTransitionHeldCodes
  gameplayTransitionBlocked = false
  gameplayTransitionHeldCodes = []
  clearEventKeyStates()
  IN_ClearStates()
  IN_StartupMouse()
  IN_StartupJoystick()
  return true
end function

// Mirror Quake's IN_Shutdown routine and its observable state changes.
function IN_Shutdown()
  global gameplayTransitionBlocked, gameplayTransitionHeldCodes
  IN_DeactivateMouse()
  IN_ShowMouse()
  IN_ClearStates()
  clearEventKeyStates()
  gameplayTransitionBlocked = false
  gameplayTransitionHeldCodes = []
  return true
end function

// CL_InitInput's command registrations are represented explicitly so both the
// host command layer and tests can dispatch exactly the stock command set.
function CL_InitInput()
  return [
    "+moveup", "-moveup", "+movedown", "-movedown",
    "+left", "-left", "+right", "-right",
    "+forward", "-forward", "+back", "-back",
    "+lookup", "-lookup", "+lookdown", "-lookdown",
    "+strafe", "-strafe", "+moveleft", "-moveleft",
    "+moveright", "-moveright", "+speed", "-speed",
    "+attack", "-attack", "+use", "-use", "+jump", "-jump",
    "impulse", "+klook", "-klook", "+mlook", "-mlook",
  ]
end function

// Provide command button behavior for the active subsystem.
function commandButton(command)
  source = bytes(lower(command))
  if len(source) == 0 then return void end if
  if source[0] == 45 then
    source[0] = 43
    return buttonForCommand(decode(source))
  end if
  return buttonForCommand(command)
end function

// Execute input command.
function dispatchInputCommand(command, key, value)
  wanted = lower(command)
  if wanted == "impulse" then return IN_Impulse(value) end if
  button = commandButton(wanted)
  if button is void then return false end if
  source = bytes(wanted)
  if source[0] == 43 then return KeyDown(button, key) end if
  return KeyUp(button, key)
end function

// Apply the Quake-compatible cl adjust angles behavior.
function CL_AdjustAngles(command, frameTime, yawSpeed, pitchSpeed, angleSpeedKey)
  speed = frameTime
  if (inSpeed[2] & 1) != 0 then speed = speed * angleSpeedKey end if

  if (inStrafe[2] & 1) == 0 then
    command.viewAngles.y = command.viewAngles.y - speed * yawSpeed * CL_KeyState(inRight)
    command.viewAngles.y = command.viewAngles.y + speed * yawSpeed * CL_KeyState(inLeft)
    command.viewAngles.y = math.angleMod(command.viewAngles.y)
  end if

  if (inKLook[2] & 1) != 0 then
    requestStopPitchDrift()
    command.viewAngles.x = command.viewAngles.x - speed * pitchSpeed * CL_KeyState(inForward)
    command.viewAngles.x = command.viewAngles.x + speed * pitchSpeed * CL_KeyState(inBack)
  end if

  up = CL_KeyState(inLookup)
  down = CL_KeyState(inLookdown)
  command.viewAngles.x = command.viewAngles.x - speed * pitchSpeed * up
  command.viewAngles.x = command.viewAngles.x + speed * pitchSpeed * down
  if up != 0.0 or down != 0.0 then requestStopPitchDrift() end if

  command.viewAngles.x = math.clamp(command.viewAngles.x, -70.0, 80.0)
  command.viewAngles.z = math.clamp(command.viewAngles.z, -50.0, 50.0)
  return command
end function

// Apply the Quake-compatible cl base move behavior.
function CL_BaseMove(command, signon, frameTime, forwardSpeed, backSpeed, sideSpeed, upSpeed, moveSpeedKey, yawSpeed, pitchSpeed, angleSpeedKey)
  if signon != c.SIGNONS then return false end if
  CL_AdjustAngles(command, frameTime, yawSpeed, pitchSpeed, angleSpeedKey)
  clear(command)

  if (inStrafe[2] & 1) != 0 then
    command.sideMove = command.sideMove + sideSpeed * CL_KeyState(inRight)
    command.sideMove = command.sideMove - sideSpeed * CL_KeyState(inLeft)
  end if
  command.sideMove = command.sideMove + sideSpeed * CL_KeyState(inMoveright)
  command.sideMove = command.sideMove - sideSpeed * CL_KeyState(inMoveleft)
  command.upMove = command.upMove + upSpeed * CL_KeyState(inUp)
  command.upMove = command.upMove - upSpeed * CL_KeyState(inDown)

  if (inKLook[2] & 1) == 0 then
    command.forwardMove = command.forwardMove + forwardSpeed * CL_KeyState(inForward)
    command.forwardMove = command.forwardMove - backSpeed * CL_KeyState(inBack)
  end if

  if (inSpeed[2] & 1) != 0 then
    command.forwardMove = command.forwardMove * moveSpeedKey
    command.sideMove = command.sideMove * moveSpeedKey
    command.upMove = command.upMove * moveSpeedKey
  end if
  return true
end function

// Clear both the MiniLang filter history and any native cursor displacement
// accumulated while the menu, console, or another application owned the mouse.
// WinQuake performs the equivalent reset whenever capture is reacquired.
function resetMouse()
  global oldMouseX, oldMouseY, mouseFilterReady, mouseAccumX, mouseAccumY
  oldMouseX = 0.0
  oldMouseY = 0.0
  mouseFilterReady = false
  mouseAccumX = 0.0
  mouseAccumY = 0.0
  win.mouseDelta()
  return true
end function

// Keep the capture transition in one place.  Calling this every host frame is
// intentional: it only touches Win32 when the desired state changes, while a
// focus loss/reacquire reliably resets both native and filtered deltas.
function setMouseCapture(enabled)
  if enabled == mouseCaptured then return mouseCaptured end if
  if enabled then IN_ActivateMouse() else IN_DeactivateMouse() end if
  return mouseCaptured
end function

// Provide filtered mouse delta behavior for the active subsystem.
function filteredMouseDelta(filterEnabled)
  global oldMouseX, oldMouseY, mouseFilterReady, mouseAccumX, mouseAccumY
  if not mouseActive then return [0.0, 0.0] end if
  raw = win.mouseDelta()
  mouseX = raw[0] * 1.0 + mouseAccumX
  mouseY = raw[1] * 1.0 + mouseAccumY
  mouseAccumX = 0.0
  mouseAccumY = 0.0
  filteredX = mouseX
  filteredY = mouseY
  // WinQuake averages the first filtered sample with the zero-initialized
  // previous sample as well; there is no one-frame unfiltered warmup.
  if filterEnabled then
    filteredX = (mouseX + oldMouseX) * 0.5
    filteredY = (mouseY + oldMouseY) * 0.5
  end if
  oldMouseX = mouseX
  oldMouseY = mouseY
  mouseFilterReady = true
  return [filteredX, filteredY]
end function

// IN_MouseMove first multiplies raw cursor motion by sensitivity and then by
// m_yaw/m_pitch.  The former port treated sensitivity itself as degrees per
// pixel, making the stock value 3 about 45 times too strong.
function applyMouseDelta(command, deltaX, deltaY, mouseSensitivity, yawScale, pitchScale)
  command.viewAngles.y = math.angleMod(command.viewAngles.y - deltaX * mouseSensitivity * yawScale)
  command.viewAngles.x = math.clamp(command.viewAngles.x + deltaY * mouseSensitivity * pitchScale, -70.0, 80.0)
  return command
end function

// Apply mouse to the active subsystem state.
function applyMouse(command, mouseSensitivity, yawScale, pitchScale, filterEnabled)
  delta = filteredMouseDelta(filterEnabled)
  return applyMouseDelta(command, delta[0], delta[1], mouseSensitivity, yawScale, pitchScale)
end function

// Select modern persistent free-look without changing the original +mlook
// button state.  Differential tests and compatibility callers retain stock
// Quake behavior until the production host explicitly enables this mode.
function IN_SetFreeLook(enabled)
  global alwaysMouseLook
  alwaysMouseLook = enabled
  return alwaysMouseLook
end function

// Mirror Quake's IN_MoveDelta routine and its observable state changes.
function IN_MoveDelta(command, deltaX, deltaY, mouseSensitivity, yawScale, pitchScale, sideScale, forwardScale, lookStrafe, noclipAngleHack)
  mouseX = deltaX * mouseSensitivity
  mouseY = deltaY * mouseSensitivity
  mouseLookActive = alwaysMouseLook or (inMLook[2] & 1) != 0
  // Free-look owns both mouse axes. Legacy +strafe/lookstrafe remapping remains
  // available when free-look is disabled, preserving the original input path.
  if not alwaysMouseLook and ((inStrafe[2] & 1) != 0 or (lookStrafe and (inMLook[2] & 1) != 0)) then
    command.sideMove = command.sideMove + sideScale * mouseX
  else
    command.viewAngles.y = command.viewAngles.y - yawScale * mouseX
  end if

  if mouseLookActive then requestStopPitchDrift() end if
  if alwaysMouseLook or ((inMLook[2] & 1) != 0 and (inStrafe[2] & 1) == 0) then
    command.viewAngles.x = command.viewAngles.x + pitchScale * mouseY
    command.viewAngles.x = math.clamp(command.viewAngles.x, -70.0, 80.0)
  else if (inStrafe[2] & 1) != 0 and noclipAngleHack then
    command.upMove = command.upMove - forwardScale * mouseY
  else
    command.forwardMove = command.forwardMove - forwardScale * mouseY
  end if
  return command
end function

// Mirror Quake's IN_MouseEvent routine and its observable state changes.
function IN_MouseEvent(mouseState)
  global mouseOldButtonState
  events = []
  if not mouseActive or directInput then return events end if
  index = 0
  while index < 3
    mask = 1 << index
    if (mouseState & mask) != 0 and (mouseOldButtonState & mask) == 0 then
      events = events + [[200 + index, true]]
    end if
    if (mouseState & mask) == 0 and (mouseOldButtonState & mask) != 0 then
      events = events + [[200 + index, false]]
    end if
    index = index + 1
  end while
  mouseOldButtonState = mouseState
  return events
end function

// Mirror Quake's IN_MouseMove routine and its observable state changes.
function IN_MouseMove(command, mouseSensitivity, yawScale, pitchScale, filterEnabled, sideScale, forwardScale, lookStrafe, noclipAngleHack)
  delta = filteredMouseDelta(filterEnabled)
  moved = IN_MoveDelta(
    command,
    delta[0],
    delta[1],
    mouseSensitivity,
    yawScale,
    pitchScale,
    sideScale,
    forwardScale,
    lookStrafe,
    noclipAngleHack,
  )
  if delta[0] != 0.0 or delta[1] != 0.0 then win.centerCursor() end if
  return moved
end function

// Return absolute value derived from the active module state.
function absoluteValue(value)
  if value < 0.0 then return -value end if
  return value
end function

// Mirror Quake's IN_JoyMove routine and its observable state changes.
function IN_JoyMove(command, frameSeconds)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if not joyAdvancedInitialized then Joy_AdvancedUpdate_f() end if
  if not joyAvailable or cvarValue("joystick", 0.0) == 0.0 then return command end if
  if not IN_ReadJoystick() then return command end if

  speed = 1.0
  if (inSpeed[2] & 1) != 0 then speed = cvarValue("cl_movespeedkey", DEFAULT_MOVE_SPEED_KEY) end if
  angleSpeed = speed * frameSeconds
  index = 0
  while index < JOY_MAX_AXES
    rawValue = RawValuePointer(index) - 32768
    if cvarValue("joywwhack2", 0.0) != 0.0 and joyAxisMap[index] == AXIS_TURN then
      rawValue = win.joyWarriorCurve(rawValue)
    end if
    axisValue = rawValue / 32768.0
    axis = joyAxisMap[index]

    if axis == AXIS_FORWARD then
      if cvarValue("joyadvanced", 0.0) == 0.0 and (inMLook[2] & 1) != 0 then
        if absoluteValue(axisValue) > cvarValue("joypitchthreshold", 0.15) then
          pitchChange = axisValue * cvarValue("joypitchsensitivity", 1.0) * angleSpeed * cvarValue("cl_pitchspeed", DEFAULT_PITCH_SPEED)
          if cvarValue("m_pitch", DEFAULT_M_PITCH) < 0.0 then
            command.viewAngles.x = command.viewAngles.x - pitchChange
          else
            command.viewAngles.x = command.viewAngles.x + pitchChange
          end if
          requestStopPitchDrift()
        else if cvarValue("lookspring", 0.0) == 0.0 then
          requestStopPitchDrift()
        end if
      else if absoluteValue(axisValue) > cvarValue("joyforwardthreshold", 0.15) then
        command.forwardMove = command.forwardMove + axisValue * cvarValue("joyforwardsensitivity", -1.0) * speed * cvarValue("cl_forwardspeed", 200.0)
      end if
    else if axis == AXIS_SIDE then
      if absoluteValue(axisValue) > cvarValue("joysidethreshold", 0.15) then
        command.sideMove = command.sideMove + axisValue * cvarValue("joysidesensitivity", -1.0) * speed * cvarValue("cl_sidespeed", 350.0)
      end if
    else if axis == AXIS_TURN then
      if (inStrafe[2] & 1) != 0 or (cvarValue("lookstrafe", 0.0) != 0.0 and (inMLook[2] & 1) != 0) then
        if absoluteValue(axisValue) > cvarValue("joysidethreshold", 0.15) then
          command.sideMove = command.sideMove - axisValue * cvarValue("joysidesensitivity", -1.0) * speed * cvarValue("cl_sidespeed", 350.0)
        end if
      else if absoluteValue(axisValue) > cvarValue("joyyawthreshold", 0.15) then
        if joyControlMap[index] == JOY_ABSOLUTE_AXIS then
          command.viewAngles.y = command.viewAngles.y + axisValue * cvarValue("joyyawsensitivity", -1.0) * angleSpeed * cvarValue("cl_yawspeed", DEFAULT_YAW_SPEED)
        else
          command.viewAngles.y = command.viewAngles.y + axisValue * cvarValue("joyyawsensitivity", -1.0) * speed * 180.0
        end if
      end if
    else if axis == AXIS_LOOK and (inMLook[2] & 1) != 0 then
      if absoluteValue(axisValue) > cvarValue("joypitchthreshold", 0.15) then
        if joyControlMap[index] == JOY_ABSOLUTE_AXIS then
          command.viewAngles.x = command.viewAngles.x + axisValue * cvarValue("joypitchsensitivity", 1.0) * angleSpeed * cvarValue("cl_pitchspeed", DEFAULT_PITCH_SPEED)
        else
          command.viewAngles.x = command.viewAngles.x + axisValue * cvarValue("joypitchsensitivity", 1.0) * speed * 180.0
        end if
        requestStopPitchDrift()
      else if cvarValue("lookspring", 0.0) == 0.0 then
        requestStopPitchDrift()
      end if
    end if
    index = index + 1
  end while
  command.viewAngles.x = math.clamp(command.viewAngles.x, -70.0, 80.0)
  return command
end function

// Mirror Quake's IN_Move routine and its observable state changes.
function IN_Move(command, mouseSensitivity, yawScale, pitchScale, filterEnabled, sideScale, forwardScale, lookStrafe, noclipAngleHack, frameSeconds, active, minimized)
  if active and not minimized then
    IN_MouseMove(command, mouseSensitivity, yawScale, pitchScale, filterEnabled, sideScale, forwardScale, lookStrafe, noclipAngleHack)
    IN_JoyMove(command, frameSeconds)
  end if
  return command
end function

// Mirror Quake's IN_Accumulate routine and its observable state changes.
function IN_Accumulate()
  global mouseAccumX, mouseAccumY
  if not mouseActive or directInput then return false end if
  raw = win.mouseDelta()
  mouseAccumX = mouseAccumX + raw[0]
  mouseAccumY = mouseAccumY + raw[1]
  if raw[0] != 0 or raw[1] != 0 then win.centerCursor() end if
  return true
end function

// Apply the Quake-compatible cl button bits behavior.
function CL_ButtonBits()
  bits = 0
  if (inAttack[2] & 3) != 0 then bits = bits | c.BUTTON_ATTACK end if
  inAttack[2] = inAttack[2] & ~2
  if (inJump[2] & 3) != 0 then bits = bits | c.BUTTON_JUMP end if
  inJump[2] = inJump[2] & ~2
  return bits
end function

// Apply the Quake-compatible cl take impulse behavior.
function CL_TakeImpulse()
  global inImpulse
  value = inImpulse
  inImpulse = 0
  return value
end function

// Apply the Quake-compatible cl finish move behavior.
function CL_FinishMove(command)
  command.buttons = CL_ButtonBits()
  command.impulse = CL_TakeImpulse()
  return command
end function

// Provide collect behavior for the active subsystem.
function collect(command, frameMilliseconds, mouseSensitivity)
  applyMouse(command, mouseSensitivity, DEFAULT_M_YAW, DEFAULT_M_PITCH, false)
  command.forwardMove = 0.0
  command.sideMove = 0.0
  command.upMove = 0.0
  command.buttons = 0
  command.impulse = 0

  if win.keyDown(c.VK_W) or win.keyDown(c.VK_UP) then command.forwardMove = command.forwardMove + c.DEFAULT_FORWARD_SPEED end if
  if win.keyDown(c.VK_S) or win.keyDown(c.VK_DOWN) then command.forwardMove = command.forwardMove - c.DEFAULT_BACK_SPEED end if
  if win.keyDown(c.VK_D) or win.keyDown(c.VK_RIGHT) then command.sideMove = command.sideMove + c.DEFAULT_SIDE_SPEED end if
  if win.keyDown(c.VK_A) or win.keyDown(c.VK_LEFT) then command.sideMove = command.sideMove - c.DEFAULT_SIDE_SPEED end if
  if win.keyDown(c.VK_SPACE) then command.buttons = command.buttons | c.BUTTON_JUMP end if

  mouseButtons = win.mouseButtons()
  if (mouseButtons & 1) != 0 or win.keyDown(c.VK_CONTROL) then command.buttons = command.buttons | c.BUTTON_ATTACK end if
  if (mouseButtons & 2) != 0 then command.buttons = command.buttons | c.BUTTON_JUMP end if
  command.msec = frameMilliseconds
  return command
end function

// Update module state for the requested operation.
function clear(command)
  command.forwardMove = 0.0
  command.sideMove = 0.0
  command.upMove = 0.0
  command.buttons = 0
  command.impulse = 0
  return command
end function

// Create and initialize original move.
function buildOriginalMove(command, signon, frameMilliseconds, mouseSensitivity, yawScale, pitchScale, filterEnabled, forwardSpeed, backSpeed, sideSpeed, upSpeed, noclipAngleHack, pollButtonBindings, deviceActive, minimized)
  if pollButtonBindings then IN_PollButtonCommands() end if
  built = CL_BaseMove(
    command,
    signon,
    frameMilliseconds * 0.001,
    forwardSpeed,
    backSpeed,
    sideSpeed,
    upSpeed,
    cvarValue("cl_movespeedkey", DEFAULT_MOVE_SPEED_KEY),
    cvarValue("cl_yawspeed", DEFAULT_YAW_SPEED),
    cvarValue("cl_pitchspeed", DEFAULT_PITCH_SPEED),
    cvarValue("cl_anglespeedkey", DEFAULT_ANGLE_SPEED_KEY),
  )
  if not built then return command end if
  IN_Move(
    command,
    mouseSensitivity,
    yawScale,
    pitchScale,
    filterEnabled,
    cvarValue("m_side", DEFAULT_M_SIDE),
    cvarValue("m_forward", DEFAULT_M_FORWARD),
    cvarValue("lookstrafe", 0.0) != 0.0,
    noclipAngleHack,
    frameMilliseconds * 0.001,
    deviceActive,
    minimized,
  )
  CL_FinishMove(command)
  command.msec = frameMilliseconds
  return command
end function

// Provide collect game behavior for the active subsystem.
function collectGame(command, frameMilliseconds, mouseSensitivity, yawScale, pitchScale, filterEnabled, forwardSpeed, backSpeed, sideSpeed, upSpeed)
  return buildOriginalMove(
    command,
    c.SIGNONS,
    frameMilliseconds,
    mouseSensitivity,
    yawScale,
    pitchScale,
    filterEnabled,
    forwardSpeed,
    backSpeed,
    sideSpeed,
    upSpeed,
    false,
    true,
    true,
    false,
  )
end function
