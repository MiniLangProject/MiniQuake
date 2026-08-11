/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Shared gl_draw.c / gl_screen.c / sbar.c compatibility decisions. Keeping these
pure rules in one package makes the 2D/HUD handoff observable and testable.
*/

package miniquake.render_ui_contract

import miniquake.constants as c
import miniquake.native as native

const STATUSBAR_WIDTH = 320
const STATUSBAR_HEIGHT = 24
const INVENTORY_HEIGHT = 24
const TGA_HEADER_BYTES = 18
const TGA_BYTES_PER_PIXEL = 3

function statusbarXOffset(width, gameType)
  if gameType == c.GAME_DEATHMATCH then return 0 end if
  return native.trunc((width - STATUSBAR_WIDTH) / 2)
end function

function overlayOrder(dialog, loading, intermission, gameInput)
  if dialog then return ["set2d", "tileclear", "dialog", "hud", "fade", "notify-string"] end if
  if loading then return ["set2d", "tileclear", "loading", "hud"] end if
  if intermission == 1 and gameInput then return ["set2d", "tileclear", "intermission"] end if
  if intermission == 2 and gameInput then return ["set2d", "tileclear", "finale", "center"] end if
  if intermission == 3 and gameInput then return ["set2d", "tileclear", "center"] end if
  return ["set2d", "tileclear", "crosshair", "ram", "net", "turtle", "pause", "center", "hud", "console", "menu"]
end function

// GLQuake's menu helpers retain a 320-pixel logical canvas and only center it
// horizontally. Modern high-DPI modes need enlargement, but fractional or
// unbounded stretching makes the indexed font and qpics visibly uneven. Use a
// conservative integral scale: original size around 640x480, 2x around 1080p,
// and at most 4x on very large displays.
function virtualCanvasScale(width, height)
  safeWidth = width
  safeHeight = height
  if safeWidth < 1 then safeWidth = 1 end if
  if safeHeight < 1 then safeHeight = 1 end if
  ratioX = safeWidth / 640.0
  ratioY = safeHeight / 480.0
  ratio = ratioX
  if ratioY < ratio then ratio = ratioY end if
  value = native.trunc(ratio + 0.5)
  if value < 1 then value = 1 end if
  if value > 4 then value = 4 end if
  return value * 1.0
end function

function virtualCanvasLayout(width, height)
  scale = virtualCanvasScale(width, height)
  offsetX = (width - 320.0 * scale) * 0.5
  offsetY = 0.0
  if scale > 1.0 then offsetY = (height - 200.0 * scale) * 0.5 end if
  return [offsetX, offsetY, scale]
end function

function set2dStateOrder()
  return [
    "viewport", "projection", "identity", "ortho", "modelview", "identity",
    "disable-depth", "disable-cull", "disable-blend", "enable-alpha", "white",
  ]
end function

function tgaByteLength(width, height)
  if width <= 0 or height <= 0 then return 0 end if
  return TGA_HEADER_BYTES + width * height * TGA_BYTES_PER_PIXEL
end function

function viewModelDepthMaximum()
  return 0.3
end function

function statusbarLines(viewSize, intermission)
  if intermission != 0 then return 0 end if
  if viewSize >= 120.0 then return 0 end if
  if viewSize >= 110.0 then return STATUSBAR_HEIGHT end if
  return STATUSBAR_HEIGHT + INVENTORY_HEIGHT
end function
