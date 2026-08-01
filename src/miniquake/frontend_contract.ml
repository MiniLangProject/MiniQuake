/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Frozen WinQuake 1.09 keyboard, input, console, menu and Win32-video contract.
*/

package miniquake.frontend_contract

import miniquake.keys as frontendKeys
import miniquake.input as frontendInput
import miniquake.console as frontendConsole
import miniquake.menu as frontendMenu
import miniquake.gl_vidnt as frontendVideo

const STATUS = "frontend_109_frozen_v1"
const FINGERPRINT = 0x924251fa
const KEY_COUNT = 256
const HISTORY_LINES = 32
const MAX_COMMAND_LINE = 256
const CHAT_BYTES = 31
const CONSOLE_TEXT_BYTES = 16384
const NOTIFY_TIMES = 4
const JOYSTICK_AXES = 6
const MOUSE_BUTTONS = 3
const OPTIONS_ITEMS = 14
const HELP_PAGES = 6
const MAX_VIDEO_MODES = 30
const MAX_VIDEO_DESCRIPTIONS = 27
const NOTIFY_ACK_EDGES = 2

function values()
  return [
    KEY_COUNT,
    HISTORY_LINES,
    MAX_COMMAND_LINE,
    CHAT_BYTES,
    CONSOLE_TEXT_BYTES,
    NOTIFY_TIMES,
    JOYSTICK_AXES,
    MOUSE_BUTTONS,
    OPTIONS_ITEMS,
    HELP_PAGES,
    MAX_VIDEO_MODES,
    MAX_VIDEO_DESCRIPTIONS,
    NOTIFY_ACK_EDGES,
  ]
end function

function verify()
  return frontendKeys.MAXCMDLINE == MAX_COMMAND_LINE and
    frontendConsole.CON_TEXTSIZE == CONSOLE_TEXT_BYTES and
    frontendConsole.NUM_CON_TIMES == NOTIFY_TIMES and
    frontendInput.JOY_MAX_AXES == JOYSTICK_AXES and
    len(frontendMenu.optionsItems()) == OPTIONS_ITEMS and
    frontendMenu.HELP_PAGES == HELP_PAGES and
    frontendVideo.MAX_MODE_LIST == MAX_VIDEO_MODES and
    frontendVideo.MAX_MODEDESCS == MAX_VIDEO_DESCRIPTIONS
end function
