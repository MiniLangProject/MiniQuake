/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.platform.win32.
*/
package miniquake.platform.win32

import miniquake.native as native

const RENDER_OPENGL = 0
const RENDER_DIRECT3D9 = 1
const RENDER_VULKAN = 2

// Update subsystem configuration for select renderer.
function selectRenderer(backend)
  return native.renderSelect(backend) != 0
end function

// Provide renderer behavior for the active subsystem.
function renderer()
  return native.renderBackend()
end function

// Report whether renderer available holds for the active state.
function rendererAvailable(backend)
  return native.renderAvailable(backend) != 0
end function

// Create and initialize the module state.
function create(title, width, height, fullscreen)
  handle = native.winCreate(title, width, height, fullscreen)
  if handle is void then return error(2300, "Win32/WGL window creation failed") end if
  return handle
end function

// Release resources owned by the requested value.
function destroy()
  native.winDestroy()
end function

// Provide poll behavior for the active subsystem.
function poll()
  return native.winPoll() != 0
end function

// Convert data for swap.
function swap()
  native.winSwap()
end function

// Provide key down behavior for the active subsystem.
function keyDown(virtualKey)
  return native.winKeyDown(virtualKey) != 0
end function

// Provide key pressed behavior for the active subsystem.
function keyPressed(virtualKey)
  return native.winKeyPressed(virtualKey) != 0
end function

// Capture the requested keyboard levels and complete edge table in one call.
function keySnapshot(downStates, pressedStates, queryMask)
  count = len(downStates)
  if len(pressedStates) < count then count = len(pressedStates) end if
  if len(queryMask) < count then count = len(queryMask) end if
  return native.winKeySnapshot(downStates, pressedStates, queryMask, count)
end function

// Provide text pop behavior for the active subsystem.
function textPop()
  return native.winTextPop()
end function

// Report whether focus.
function hasFocus()
  return native.winHasFocus() != 0
end function

// Provide width behavior for the active subsystem.
function width()
  return native.winClientWidth()
end function

// Provide height behavior for the active subsystem.
function height()
  return native.winClientHeight()
end function

// Provide resize client behavior for the active subsystem.
function resizeClient(widthValue, heightValue)
  return native.winResizeClient(widthValue, heightValue) != 0
end function

// Provide window x behavior for the active subsystem.
function windowX()
  return native.winWindowX()
end function

// Provide window y behavior for the active subsystem.
function windowY()
  return native.winWindowY()
end function

// Provide minimized behavior for the active subsystem.
function minimized()
  return native.winIsMinimized() != 0
end function

// Provide desktop width behavior for the active subsystem.
function desktopWidth()
  return native.winDesktopWidth()
end function

// Provide desktop height behavior for the active subsystem.
function desktopHeight()
  return native.winDesktopHeight()
end function

// Provide display modes behavior for the active subsystem.
function displayModes()
  count = native.winDisplayModeCount()
  result = []
  index = 0
  while index < count
    result = result + [[
      native.winDisplayModeWidth(index),
      native.winDisplayModeHeight(index),
      native.winDisplayModeBpp(index),
      native.winDisplayModeFrequency(index),
    ]]
    index = index + 1
  end while
  return result
end function

// Verify display mode against the expected Quake behavior.
function testDisplayMode(widthValue, heightValue, bpp, frequency)
  return native.winTestDisplayMode(widthValue, heightValue, bpp, frequency) != 0
end function

// Update subsystem configuration for configure display mode.
function configureDisplayMode(widthValue, heightValue, bpp, frequency, fullscreen, useCurrent)
  fullscreenValue = 0
  currentValue = 0
  if fullscreen then fullscreenValue = 1 end if
  if useCurrent then currentValue = 1 end if
  return native.winConfigureDisplayMode(widthValue, heightValue, bpp, frequency, fullscreenValue, currentValue) != 0
end function

// Return restore display mode derived from the active module state.
function restoreDisplayMode()
  native.winRestoreDisplayMode()
  return true
end function

// Return gamma ramp.
function getGammaRamp()
  ramp = bytes(1536)
  if native.winGetGammaRamp(ramp, len(ramp)) == 0 then return error(2301, "GetDeviceGammaRamp failed") end if
  return ramp
end function

// Update module state for gamma ramp.
function setGammaRamp(ramp)
  if len(ramp) < 1536 then return false end if
  return native.winSetGammaRamp(ramp, len(ramp)) != 0
end function

// Provide context ready behavior for the active subsystem.
function contextReady()
  return native.winContextReady() != 0
end function

// Create and initialize current.
function makeCurrent()
  return native.winMakeCurrent() != 0
end function

// Provide activate behavior for the active subsystem.
function activate(active, minimizedValue)
  activeValue = 0
  minimizedNumber = 0
  if active then activeValue = 1 end if
  if minimizedValue then minimizedNumber = 1 end if
  native.winActivate(activeValue, minimizedNumber)
  return true
end function

// Update module state for title.
function setTitle(title)
  native.winSetTitle(title)
end function

// Provide capture mouse behavior for the active subsystem.
function captureMouse(enabled)
  if enabled then native.winSetCursorCapture(1) else native.winSetCursorCapture(0) end if
end function

// Provide mouse delta behavior for the active subsystem.
function mouseDelta()
  return [native.winMouseDx(), native.winMouseDy()]
end function

// Provide mouse buttons behavior for the active subsystem.
function mouseButtons()
  return native.winMouseButtons()
end function

// Provide mouse wheel behavior for the active subsystem.
function mouseWheel()
  return native.winMouseWheel()
end function

// Provide input event pop behavior for the active subsystem.
function inputEventPop()
  return native.winInputEventPop()
end function

// Provide input test push behavior for the active subsystem.
function inputTestPush(eventType, code, value)
  native.winInputTestPush(eventType, code, value)
end function

// Provide show cursor behavior for the active subsystem.
function showCursor(show)
  if show then native.winCursorShow(1) else native.winCursorShow(0) end if
end function

// Provide center cursor behavior for the active subsystem.
function centerCursor()
  return native.winCursorCenter() != 0
end function

// Update module state for clip cursor.
function updateClipCursor()
  return native.winUpdateClipCursor() != 0
end function

// Provide joy startup behavior for the active subsystem.
function joyStartup()
  return native.winJoyStartup() != 0
end function

// Provide joy read behavior for the active subsystem.
function joyRead()
  return native.winJoyRead() != 0
end function

// Provide joy axis behavior for the active subsystem.
function joyAxis(axis)
  return native.winJoyAxis(axis)
end function

// Provide joy buttons behavior for the active subsystem.
function joyButtons()
  return native.winJoyButtons()
end function

// Provide joy pov behavior for the active subsystem.
function joyPov()
  return native.winJoyPov()
end function

// Return joy button count derived from the active module state.
function joyButtonCount()
  return native.winJoyButtonCount()
end function

// Provide joy has pov behavior for the active subsystem.
function joyHasPov()
  return native.winJoyHasPov() != 0
end function

// Provide joy warrior curve behavior for the active subsystem.
function joyWarriorCurve(rawValue)
  return native.bitsFloat(native.winJoyWarriorCurveF32(rawValue))
end function

// Provide ticks behavior for the active subsystem.
function ticks()
  return native.winTicks()
end function

// Provide sleep behavior for the active subsystem.
function sleep(milliseconds)
  native.winSleep(milliseconds)
end function
