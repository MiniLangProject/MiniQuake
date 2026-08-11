package miniquake.platform.win32

import miniquake.native as native

function create(title, width, height, fullscreen)
  handle = native.winCreate(title, width, height, fullscreen)
  if handle is void then return error(2300, "Win32/WGL window creation failed") end if
  return handle
end function

function destroy()
  native.winDestroy()
end function

function poll()
  return native.winPoll() != 0
end function

function swap()
  native.winSwap()
end function

function keyDown(virtualKey)
  return native.winKeyDown(virtualKey) != 0
end function

function keyPressed(virtualKey)
  return native.winKeyPressed(virtualKey) != 0
end function

function textPop()
  return native.winTextPop()
end function

function hasFocus()
  return native.winHasFocus() != 0
end function

function width()
  return native.winClientWidth()
end function

function height()
  return native.winClientHeight()
end function

function resizeClient(widthValue, heightValue)
  return native.winResizeClient(widthValue, heightValue) != 0
end function

function windowX()
  return native.winWindowX()
end function

function windowY()
  return native.winWindowY()
end function

function minimized()
  return native.winIsMinimized() != 0
end function

function desktopWidth()
  return native.winDesktopWidth()
end function

function desktopHeight()
  return native.winDesktopHeight()
end function

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

function testDisplayMode(widthValue, heightValue, bpp, frequency)
  return native.winTestDisplayMode(widthValue, heightValue, bpp, frequency) != 0
end function

function configureDisplayMode(widthValue, heightValue, bpp, frequency, fullscreen, useCurrent)
  fullscreenValue = 0
  currentValue = 0
  if fullscreen then fullscreenValue = 1 end if
  if useCurrent then currentValue = 1 end if
  return native.winConfigureDisplayMode(widthValue, heightValue, bpp, frequency, fullscreenValue, currentValue) != 0
end function

function restoreDisplayMode()
  native.winRestoreDisplayMode()
  return true
end function

function getGammaRamp()
  ramp = bytes(1536)
  if native.winGetGammaRamp(ramp, len(ramp)) == 0 then return error(2301, "GetDeviceGammaRamp failed") end if
  return ramp
end function

function setGammaRamp(ramp)
  if len(ramp) < 1536 then return false end if
  return native.winSetGammaRamp(ramp, len(ramp)) != 0
end function

function contextReady()
  return native.winContextReady() != 0
end function

function makeCurrent()
  return native.winMakeCurrent() != 0
end function

function activate(active, minimizedValue)
  activeValue = 0
  minimizedNumber = 0
  if active then activeValue = 1 end if
  if minimizedValue then minimizedNumber = 1 end if
  native.winActivate(activeValue, minimizedNumber)
  return true
end function

function setTitle(title)
  native.winSetTitle(title)
end function

function captureMouse(enabled)
  if enabled then native.winSetCursorCapture(1) else native.winSetCursorCapture(0) end if
end function

function mouseDelta()
  return [native.winMouseDx(), native.winMouseDy()]
end function

function mouseButtons()
  return native.winMouseButtons()
end function

function mouseWheel()
  return native.winMouseWheel()
end function

function inputEventPop()
  return native.winInputEventPop()
end function

function inputTestPush(eventType, code, value)
  native.winInputTestPush(eventType, code, value)
end function

function showCursor(show)
  if show then native.winCursorShow(1) else native.winCursorShow(0) end if
end function

function centerCursor()
  return native.winCursorCenter() != 0
end function

function updateClipCursor()
  return native.winUpdateClipCursor() != 0
end function

function joyStartup()
  return native.winJoyStartup() != 0
end function

function joyRead()
  return native.winJoyRead() != 0
end function

function joyAxis(axis)
  return native.winJoyAxis(axis)
end function

function joyButtons()
  return native.winJoyButtons()
end function

function joyPov()
  return native.winJoyPov()
end function

function joyButtonCount()
  return native.winJoyButtonCount()
end function

function joyHasPov()
  return native.winJoyHasPov() != 0
end function

function joyWarriorCurve(rawValue)
  return native.bitsFloat(native.winJoyWarriorCurveF32(rawValue))
end function

function ticks()
  return native.winTicks()
end function

function sleep(milliseconds)
  native.winSleep(milliseconds)
end function
