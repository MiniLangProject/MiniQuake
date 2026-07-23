package miniquake.input

import miniquake.types as t
import miniquake.constants as c
import miniquake.platform.win32 as win
import miniquake.mathlib as math
import miniquake.byteio as bio

const DEFAULT_M_YAW = 0.022
const DEFAULT_M_PITCH = 0.022

oldMouseX = 0.0
oldMouseY = 0.0
mouseFilterReady = false
mouseCaptured = false
bindings = []

function lower(text)
  return bio.lower(text)
end function

function keyCodeForName(name)
  wanted = lower(name)
  if wanted == "tab" then return c.VK_TAB end if
  if wanted == "enter" then return c.VK_RETURN end if
  if wanted == "escape" or wanted == "esc" then return c.VK_ESCAPE end if
  if wanted == "space" then return c.VK_SPACE end if
  if wanted == "backspace" then return c.VK_BACK end if
  if wanted == "uparrow" then return c.VK_UP end if
  if wanted == "downarrow" then return c.VK_DOWN end if
  if wanted == "leftarrow" then return c.VK_LEFT end if
  if wanted == "rightarrow" then return c.VK_RIGHT end if
  if wanted == "alt" then return c.VK_ALT end if
  if wanted == "ctrl" or wanted == "control" then return c.VK_CONTROL end if
  if wanted == "shift" then return c.VK_SHIFT end if
  if wanted == "del" or wanted == "delete" then return c.VK_DELETE end if
  if wanted == "mouse1" then return 1001 end if
  if wanted == "mouse2" then return 1002 end if
  if wanted == "mouse3" then return 1003 end if
  if wanted == "mwheelup" then return 1010 end if
  if wanted == "mwheeldown" then return 1011 end if
  if wanted == "f1" then return c.VK_F1 end if
  if wanted == "f2" then return c.VK_F2 end if
  if wanted == "f3" then return c.VK_F3 end if
  if wanted == "f4" then return c.VK_F4 end if
  if wanted == "f5" then return c.VK_F5 end if
  if wanted == "f6" then return c.VK_F6 end if
  if wanted == "f7" then return c.VK_F7 end if
  if wanted == "f8" then return c.VK_F8 end if
  if wanted == "f9" then return c.VK_F9 end if
  if wanted == "f10" then return c.VK_F10 end if
  if wanted == "f11" then return c.VK_F11 end if
  if wanted == "f12" then return c.VK_F12 end if
  source = bytes(wanted)
  if len(source) == 1 then
    code = source[0]
    if code >= 97 and code <= 122 then code = code - 32 end if
    if (code >= 65 and code <= 90) or (code >= 48 and code <= 57) then return code end if
    if code == 96 or code == 126 then return c.VK_OEM_3 end if
  end if
  return -1
end function

function keyNameForCode(code)
  if code == c.VK_TAB then return "TAB" end if
  if code == c.VK_RETURN then return "ENTER" end if
  if code == c.VK_ESCAPE then return "ESCAPE" end if
  if code == c.VK_SPACE then return "SPACE" end if
  if code == c.VK_BACK then return "BACKSPACE" end if
  if code == c.VK_UP then return "UPARROW" end if
  if code == c.VK_DOWN then return "DOWNARROW" end if
  if code == c.VK_LEFT then return "LEFTARROW" end if
  if code == c.VK_RIGHT then return "RIGHTARROW" end if
  if code == c.VK_ALT then return "ALT" end if
  if code == c.VK_CONTROL then return "CTRL" end if
  if code == c.VK_SHIFT then return "SHIFT" end if
  if code == c.VK_DELETE then return "DEL" end if
  if code == c.VK_OEM_3 then return "`" end if
  if code == 1001 then return "MOUSE1" end if
  if code == 1002 then return "MOUSE2" end if
  if code == 1003 then return "MOUSE3" end if
  if code == 1010 then return "MWHEELUP" end if
  if code == 1011 then return "MWHEELDOWN" end if
  if code >= c.VK_F1 and code <= c.VK_F12 then return "F" + (code - c.VK_F1 + 1) end if
  if (code >= 65 and code <= 90) or (code >= 48 and code <= 57) then return decode(bytes([code])) end if
  return "???"
end function

function bindKey(keyName, command)
  global bindings
  code = keyCodeForName(keyName)
  if code < 0 then return false end if
  index = 0
  while index < len(bindings)
    if bindings[index][0] == code then
      bindings[index] = [code, keyNameForCode(code), command]
      return true
    end if
    index = index + 1
  end while
  bindings = bindings + [[code, keyNameForCode(code), command]]
  return true
end function

function unbindKey(keyName)
  global bindings
  code = keyCodeForName(keyName)
  if code < 0 then return false end if
  result = []
  for each item in bindings
    if item[0] != code then result = result + [item] end if
  end for
  bindings = result
  return true
end function

function unbindAll()
  global bindings
  bindings = []
  return true
end function

function resetBindings()
  unbindAll()
  bindKey("UPARROW", "+forward")
  bindKey("DOWNARROW", "+back")
  bindKey("LEFTARROW", "+left")
  bindKey("RIGHTARROW", "+right")
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

function bindingForCommand(command)
  found = bindingsForCommand(command)
  if len(found) == 0 then return "???" end if
  if len(found) == 1 then return found[0] end if
  return found[0] + " or " + found[1]
end function

function unbindCommand(command)
  global bindings
  wanted = lower(command)
  result = []
  for each item in bindings
    if lower(item[2]) != wanted then result = result + [item] end if
  end for
  bindings = result
  return true
end function

function commandForKey(keyName)
  code = keyCodeForName(keyName)
  for each item in bindings
    if item[0] == code then return item[2] end if
  end for
  return ""
end function

function keyIsDown(code)
  if code == 1001 then return (win.mouseButtons() & 1) != 0 end if
  if code == 1002 then return (win.mouseButtons() & 2) != 0 end if
  if code == 1003 then return (win.mouseButtons() & 4) != 0 end if
  if code < 0 or code > 255 then return false end if
  return win.keyDown(code)
end function

function actionDown(command)
  wanted = lower(command)
  for each item in bindings
    if lower(item[2]) == wanted and keyIsDown(item[0]) then return true end if
  end for
  return false
end function

function actionPressed(command)
  wanted = lower(command)
  for each item in bindings
    if lower(item[2]) == wanted then
      code = item[0]
      if code >= 0 and code <= 255 and win.keyPressed(code) then return true end if
    end if
  end for
  return false
end function

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

function createCommand()
  return t.UserCommand(t.Vec3(0.0, 0.0, 0.0), 0.0, 0.0, 0.0, 0, 0, 0)
end function

// Clear both the MiniLang filter history and any native cursor displacement
// accumulated while the menu, console, or another application owned the mouse.
// WinQuake performs the equivalent reset whenever capture is reacquired.
function resetMouse()
  global oldMouseX, oldMouseY, mouseFilterReady
  oldMouseX = 0.0
  oldMouseY = 0.0
  mouseFilterReady = false
  win.mouseDelta()
  return true
end function

// Keep the capture transition in one place.  Calling this every host frame is
// intentional: it only touches Win32 when the desired state changes, while a
// focus loss/reacquire reliably resets both native and filtered deltas.
function setMouseCapture(enabled)
  global mouseCaptured
  if enabled == mouseCaptured then return mouseCaptured end if
  win.captureMouse(enabled)
  mouseCaptured = enabled
  resetMouse()
  return mouseCaptured
end function

function filteredMouseDelta(filterEnabled)
  global oldMouseX, oldMouseY, mouseFilterReady
  raw = win.mouseDelta()
  mouseX = raw[0] * 1.0
  mouseY = raw[1] * 1.0
  filteredX = mouseX
  filteredY = mouseY
  if filterEnabled and mouseFilterReady then
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

function applyMouse(command, mouseSensitivity, yawScale, pitchScale, filterEnabled)
  delta = filteredMouseDelta(filterEnabled)
  return applyMouseDelta(command, delta[0], delta[1], mouseSensitivity, yawScale, pitchScale)
end function

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

function clear(command)
  command.forwardMove = 0.0
  command.sideMove = 0.0
  command.upMove = 0.0
  command.buttons = 0
  command.impulse = 0
  return command
end function

function collectGame(command, frameMilliseconds, mouseSensitivity, yawScale, pitchScale, filterEnabled, forwardSpeed, backSpeed, sideSpeed, upSpeed)
  applyMouse(command, mouseSensitivity, yawScale, pitchScale, filterEnabled)
  command.forwardMove = 0.0
  command.sideMove = 0.0
  command.upMove = 0.0
  command.buttons = 0
  command.impulse = 0

  if actionDown("+forward") then command.forwardMove = command.forwardMove + forwardSpeed end if
  if actionDown("+back") then command.forwardMove = command.forwardMove - backSpeed end if
  if actionDown("+moveright") then command.sideMove = command.sideMove + sideSpeed end if
  if actionDown("+moveleft") then command.sideMove = command.sideMove - sideSpeed end if
  if actionDown("+moveup") then command.upMove = command.upMove + upSpeed end if
  if actionDown("+movedown") then command.upMove = command.upMove - upSpeed end if
  if actionDown("+speed") then
    command.forwardMove = command.forwardMove * 2.0
    command.sideMove = command.sideMove * 2.0
    command.upMove = command.upMove * 2.0
  end if
  if actionDown("+jump") then command.buttons = command.buttons | c.BUTTON_JUMP end if
  if actionDown("+attack") then command.buttons = command.buttons | c.BUTTON_ATTACK end if

  impulse = 1
  while impulse <= 8
    if actionPressed("impulse " + impulse) then command.impulse = impulse end if
    impulse = impulse + 1
  end while
  command.msec = frameMilliseconds
  return command
end function
