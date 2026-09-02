/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Shared gl_draw.c / gl_screen.c / sbar.c compatibility decisions. Keeping these
pure rules in one package makes the 2D/HUD handoff observable and testable.
*/
package miniquake.render_ui_contract

import miniquake.constants as c
import miniquake.native as native

/// Defines the statusbar width value used by `miniquake.render_ui_contract`.
const STATUSBAR_WIDTH = 320
/// Defines the statusbar height value used by `miniquake.render_ui_contract`.
const STATUSBAR_HEIGHT = 24
/// Defines the inventory height value used by `miniquake.render_ui_contract`.
const INVENTORY_HEIGHT = 24
/// Defines the tga header bytes value used by `miniquake.render_ui_contract`.
const TGA_HEADER_BYTES = 18
/// Defines the tga bytes per pixel value used by `miniquake.render_ui_contract`.
const TGA_BYTES_PER_PIXEL = 3

/// Implements the `statusbarXOffset` operation for `miniquake.render_ui_contract` (statusbar x offset).
/// @param width Requested width in pixels or data units.
/// @param gameType The game type input consumed by `statusbarXOffset`.
function statusbarXOffset(width, gameType)
  if gameType == c.GAME_DEATHMATCH then return 0 end if
  return native.trunc((width - STATUSBAR_WIDTH) / 2)
end function

/// Implements the `statusbarScaledXOffset` operation for `miniquake.render_ui_contract` (statusbar scaled x offset).
/// @param width Requested width in pixels or data units.
/// @param gameType The game type input consumed by `statusbarScaledXOffset`.
/// @param scale The scale input consumed by `statusbarScaledXOffset`.
function statusbarScaledXOffset(width, gameType, scale)
  if gameType == c.GAME_DEATHMATCH then return 0 end if
  return native.trunc((width - STATUSBAR_WIDTH * scale) / 2)
end function

/// Implements the `overlayOrder` operation for `miniquake.render_ui_contract` (overlay order).
/// @param dialog The dialog input consumed by `overlayOrder`.
/// @param loading The loading input consumed by `overlayOrder`.
/// @param intermission The intermission input consumed by `overlayOrder`.
/// @param gameInput The game input input consumed by `overlayOrder`.
function overlayOrder(dialog, loading, intermission, gameInput)
  if dialog then return ["set2d", "tileclear", "dialog", "hud", "fade", "notify-string"] end if
  if loading then return ["set2d", "tileclear", "loading", "hud"] end if
  if intermission == 1 and gameInput then return ["set2d", "tileclear", "intermission"] end if
  if intermission == 2 and gameInput then return ["set2d", "tileclear", "finale", "center"] end if
  if intermission == 3 and gameInput then return ["set2d", "tileclear", "center"] end if
  return ["set2d", "tileclear", "crosshair", "ram", "net", "turtle", "pause", "center", "hud", "console", "menu"]
end function

/// GLQuake's menu helpers retain a 320-pixel logical canvas and only center it
/// horizontally. Modern high-DPI modes need enlargement, but fractional or
/// unbounded stretching makes the indexed font and qpics visibly uneven. Use a
/// conservative integral scale: original size around 640x480, 2x around 1080p,
/// and at most 4x on very large displays. Some valid widescreen modes (for
/// example 1176x664) fall just below the legacy 1.5x ratio threshold despite
/// having ample room for a 2x 320x200 canvas; promote those explicitly so the
/// original 8-pixel menu font does not become needlessly tiny.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
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
  if value == 1 and safeWidth >= 960 and safeHeight >= 600 then value = 2 end if
  if value < 1 then value = 1 end if
  if value > 4 then value = 4 end if
  return value * 1.0
end function

/// Console glyphs use the same nearest-neighbour integer enlargement as the
/// other indexed Quake UI art.  Keep the backing text buffer in logical pixels
/// so a resize changes wrapping at the same scale that is actually rendered.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function consoleScale(width, height)
  return virtualCanvasScale(width, height)
end function

/// The status bar, inventory strip and their 8-pixel glyphs are authored for
/// the same 320-pixel Quake canvas as the menus.  Keeping one integral scale
/// avoids a tiny HUD at high resolutions and prevents filtered indexed art.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function statusbarScale(width, height)
  return virtualCanvasScale(width, height)
end function

/// Implements the `consoleLogicalWidth` operation for `miniquake.render_ui_contract` (console logical width).
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function consoleLogicalWidth(width, height)
  return native.trunc(width / consoleScale(width, height))
end function

/// Implements the `consoleLogicalHeight` operation for `miniquake.render_ui_contract` (console logical height).
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param physicalHeight The physical height input consumed by `consoleLogicalHeight`.
function consoleLogicalHeight(width, height, physicalHeight)
  return native.trunc(physicalHeight / consoleScale(width, height))
end function

/// Implements the `virtualCanvasLayout` operation for `miniquake.render_ui_contract` (virtual canvas layout).
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function virtualCanvasLayout(width, height)
  scale = virtualCanvasScale(width, height)
  offsetX = (width - 320.0 * scale) * 0.5
  offsetY = 0.0
  if scale > 1.0 then offsetY = (height - 200.0 * scale) * 0.5 end if
  return [offsetX, offsetY, scale]
end function

// Update module state for 2d state order.
function set2dStateOrder()
  return [
    "viewport", "projection", "identity", "ortho", "modelview", "identity",
    "disable-depth", "disable-cull", "disable-blend", "enable-alpha", "white",
  ]
end function

/// Return tga byte length derived from the active module state.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function tgaByteLength(width, height)
  if width <= 0 or height <= 0 then return 0 end if
  return TGA_HEADER_BYTES + width * height * TGA_BYTES_PER_PIXEL
end function

/// Implements the `viewModelDepthMaximum` operation for `miniquake.render_ui_contract` (view model depth maximum).
function viewModelDepthMaximum()
  return 0.3
end function

/// Implements the `statusbarLines` operation for `miniquake.render_ui_contract` (statusbar lines).
/// @param viewSize Size of the requested data or resource.
/// @param intermission The intermission input consumed by `statusbarLines`.
function statusbarLines(viewSize, intermission)
  if intermission != 0 then return 0 end if
  // MiniQuake clears and redraws a modern hardware backbuffer every frame.
  // Never hide the primary 24-line status bar at viewsize 120: without it the
  // reserved lower area could become an uninformative black strip until the
  // user changed viewsize.  Intermissions still own the complete screen.
  if viewSize >= 120.0 then return STATUSBAR_HEIGHT end if
  if viewSize >= 110.0 then return STATUSBAR_HEIGHT end if
  return STATUSBAR_HEIGHT + INVENTORY_HEIGHT
end function

/// Implements the `statusbarPhysicalLines` operation for `miniquake.render_ui_contract` (statusbar physical lines).
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param viewSize Size of the requested data or resource.
/// @param intermission The intermission input consumed by `statusbarPhysicalLines`.
function statusbarPhysicalLines(width, height, viewSize, intermission)
  return native.trunc(statusbarLines(viewSize, intermission) * statusbarScale(width, height))
end function
