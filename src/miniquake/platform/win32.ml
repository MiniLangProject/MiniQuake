/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.platform.win32.
*/
package miniquake.platform.win32

import miniquake.native as native

/// Defines the render opengl value used by `miniquake.platform.win32`.
const RENDER_OPENGL = 0
/// Defines the render direct3 d9 value used by `miniquake.platform.win32`.
const RENDER_DIRECT3D9 = 1
/// Defines the render vulkan value used by `miniquake.platform.win32`.
const RENDER_VULKAN = 2

/// Update subsystem configuration for select renderer.
/// @param backend The backend input consumed by `selectRenderer`.
function selectRenderer(backend)
  return native.renderSelect(backend) != 0
end function

/// Renders er for `miniquake.platform.win32`.
function renderer()
  return native.renderBackend()
end function

/// Report whether renderer available holds for the active state.
/// @param backend The backend input consumed by `rendererAvailable`.
function rendererAvailable(backend)
  return native.renderAvailable(backend) != 0
end function

/// Implements the `create` operation for `miniquake.platform.win32` (create).
/// @param title The title input consumed by `create`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param fullscreen The fullscreen input consumed by `create`.
function create(title, width, height, fullscreen)
  handle = native.winCreate(title, width, height, fullscreen)
  if handle is void then
#if TARGET_OS == "windows"
    return error(2300, "Win32/WGL window creation failed")
#else
    return error(2300, "SDL2/OpenGL window creation failed")
#endif
  end if
  return handle
end function

/// Implements the `destroy` operation for `miniquake.platform.win32` (destroy).
function destroy()
  native.winDestroy()
end function

/// Implements the `poll` operation for `miniquake.platform.win32` (poll).
function poll()
  return native.winPoll() != 0
end function

// Convert data for swap.
function swap()
  native.winSwap()
end function

/// Implements the `keyDown` operation for `miniquake.platform.win32` (key down).
/// @param virtualKey The virtual key input consumed by `keyDown`.
function keyDown(virtualKey)
  return native.winKeyDown(virtualKey) != 0
end function

/// Implements the `keyPressed` operation for `miniquake.platform.win32` (key pressed).
/// @param virtualKey The virtual key input consumed by `keyPressed`.
function keyPressed(virtualKey)
  return native.winKeyPressed(virtualKey) != 0
end function

/// Capture the requested keyboard levels and complete edge table in one call.
/// @param downStates The down states input consumed by `keySnapshot`.
/// @param pressedStates The pressed states input consumed by `keySnapshot`.
/// @param queryMask The query mask input consumed by `keySnapshot`.
function keySnapshot(downStates, pressedStates, queryMask)
  count = len(downStates)
  if len(pressedStates) < count then count = len(pressedStates) end if
  if len(queryMask) < count then count = len(queryMask) end if
  return native.winKeySnapshot(downStates, pressedStates, queryMask, count)
end function

/// Implements the `textPop` operation for `miniquake.platform.win32` (text pop).
function textPop()
  return native.winTextPop()
end function

// Report whether focus.
function hasFocus()
  return native.winHasFocus() != 0
end function

/// Implements the `width` operation for `miniquake.platform.win32` (width).
function width()
  return native.winClientWidth()
end function

/// Implements the `height` operation for `miniquake.platform.win32` (height).
function height()
  return native.winClientHeight()
end function

/// Implements the `resizeClient` operation for `miniquake.platform.win32` (resize client).
/// @param widthValue The width value input consumed by `resizeClient`.
/// @param heightValue The height value input consumed by `resizeClient`.
function resizeClient(widthValue, heightValue)
  return native.winResizeClient(widthValue, heightValue) != 0
end function

/// Implements the `windowX` operation for `miniquake.platform.win32` (window x).
function windowX()
  return native.winWindowX()
end function

/// Implements the `windowY` operation for `miniquake.platform.win32` (window y).
function windowY()
  return native.winWindowY()
end function

/// Implements the `minimized` operation for `miniquake.platform.win32` (minimized).
function minimized()
  return native.winIsMinimized() != 0
end function

/// Implements the `desktopWidth` operation for `miniquake.platform.win32` (desktop width).
function desktopWidth()
  return native.winDesktopWidth()
end function

/// Implements the `desktopHeight` operation for `miniquake.platform.win32` (desktop height).
function desktopHeight()
  return native.winDesktopHeight()
end function

/// Implements the `displayModes` operation for `miniquake.platform.win32` (display modes).
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

/// Verify display mode against the expected Quake behavior.
/// @param widthValue The width value input consumed by `testDisplayMode`.
/// @param heightValue The height value input consumed by `testDisplayMode`.
/// @param bpp The bpp input consumed by `testDisplayMode`.
/// @param frequency The frequency input consumed by `testDisplayMode`.
function testDisplayMode(widthValue, heightValue, bpp, frequency)
  return native.winTestDisplayMode(widthValue, heightValue, bpp, frequency) != 0
end function

/// Update subsystem configuration for configure display mode.
/// @param widthValue The width value input consumed by `configureDisplayMode`.
/// @param heightValue The height value input consumed by `configureDisplayMode`.
/// @param bpp The bpp input consumed by `configureDisplayMode`.
/// @param frequency The frequency input consumed by `configureDisplayMode`.
/// @param fullscreen The fullscreen input consumed by `configureDisplayMode`.
/// @param useCurrent The use current input consumed by `configureDisplayMode`.
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

/// Update module state for gamma ramp.
/// @param ramp The ramp input consumed by `setGammaRamp`.
function setGammaRamp(ramp)
  if len(ramp) < 1536 then return false end if
  return native.winSetGammaRamp(ramp, len(ramp)) != 0
end function

/// Implements the `contextReady` operation for `miniquake.platform.win32` (context ready).
function contextReady()
  return native.winContextReady() != 0
end function

// Create and initialize current.
function makeCurrent()
  return native.winMakeCurrent() != 0
end function

/// Implements the `activate` operation for `miniquake.platform.win32` (activate).
/// @param active The active input consumed by `activate`.
/// @param minimizedValue The minimized value input consumed by `activate`.
function activate(active, minimizedValue)
  activeValue = 0
  minimizedNumber = 0
  if active then activeValue = 1 end if
  if minimizedValue then minimizedNumber = 1 end if
  native.winActivate(activeValue, minimizedNumber)
  return true
end function

/// Update module state for title.
/// @param title The title input consumed by `setTitle`.
function setTitle(title)
  native.winSetTitle(title)
end function

/// Implements the `captureMouse` operation for `miniquake.platform.win32` (capture mouse).
/// @param enabled Whether the optional behavior is enabled.
function captureMouse(enabled)
  if enabled then native.winSetCursorCapture(1) else native.winSetCursorCapture(0) end if
end function

/// Implements the `mouseDelta` operation for `miniquake.platform.win32` (mouse delta).
function mouseDelta()
  return [native.winMouseDx(), native.winMouseDy()]
end function

/// Implements the `mouseButtons` operation for `miniquake.platform.win32` (mouse buttons).
function mouseButtons()
  return native.winMouseButtons()
end function

/// Implements the `mouseWheel` operation for `miniquake.platform.win32` (mouse wheel).
function mouseWheel()
  return native.winMouseWheel()
end function

/// Implements the `inputEventPop` operation for `miniquake.platform.win32` (input event pop).
function inputEventPop()
  return native.winInputEventPop()
end function

/// Implements the `inputTestPush` operation for `miniquake.platform.win32` (input test push).
/// @param eventType The event type input consumed by `inputTestPush`.
/// @param code The code input consumed by `inputTestPush`.
/// @param value Value consumed by `inputTestPush`.
function inputTestPush(eventType, code, value)
  native.winInputTestPush(eventType, code, value)
end function

/// Implements the `showCursor` operation for `miniquake.platform.win32` (show cursor).
/// @param show The show input consumed by `showCursor`.
function showCursor(show)
  if show then native.winCursorShow(1) else native.winCursorShow(0) end if
end function

/// Implements the `centerCursor` operation for `miniquake.platform.win32` (center cursor).
function centerCursor()
  return native.winCursorCenter() != 0
end function

// Update module state for clip cursor.
function updateClipCursor()
  return native.winUpdateClipCursor() != 0
end function

/// Implements the `joyStartup` operation for `miniquake.platform.win32` (joy startup).
function joyStartup()
  return native.winJoyStartup() != 0
end function

/// Implements the `joyRead` operation for `miniquake.platform.win32` (joy read).
function joyRead()
  return native.winJoyRead() != 0
end function

/// Implements the `joyAxis` operation for `miniquake.platform.win32` (joy axis).
/// @param axis The axis input consumed by `joyAxis`.
function joyAxis(axis)
  return native.winJoyAxis(axis)
end function

/// Implements the `joyButtons` operation for `miniquake.platform.win32` (joy buttons).
function joyButtons()
  return native.winJoyButtons()
end function

/// Implements the `joyPov` operation for `miniquake.platform.win32` (joy pov).
function joyPov()
  return native.winJoyPov()
end function

// Return joy button count derived from the active module state.
function joyButtonCount()
  return native.winJoyButtonCount()
end function

/// Implements the `joyHasPov` operation for `miniquake.platform.win32` (joy has pov).
function joyHasPov()
  return native.winJoyHasPov() != 0
end function

/// Implements the `joyWarriorCurve` operation for `miniquake.platform.win32` (joy warrior curve).
/// @param rawValue The raw value input consumed by `joyWarriorCurve`.
function joyWarriorCurve(rawValue)
  return native.bitsFloat(native.winJoyWarriorCurveF32(rawValue))
end function

/// Implements the `ticks` operation for `miniquake.platform.win32` (ticks).
function ticks()
  return native.winTicks()
end function

/// Implements the `sleep` operation for `miniquake.platform.win32` (sleep).
/// @param milliseconds The milliseconds input consumed by `sleep`.
function sleep(milliseconds)
  native.winSleep(milliseconds)
end function
