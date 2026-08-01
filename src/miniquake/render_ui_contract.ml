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
  return ["set2d", "tileclear", "crosshair", "ram", "net", "turtle", "pause", "center", "hud", "console", "menu"]
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
