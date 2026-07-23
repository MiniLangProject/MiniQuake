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

function ticks()
  return native.winTicks()
end function

function sleep(milliseconds)
  native.winSleep(milliseconds)
end function
