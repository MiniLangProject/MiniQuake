/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Frozen WinQuake 1.09 keyboard, input, console, menu and Win32-video contract.
*/
package miniquake.frontend_contract

import miniquake.keys as frontendKeys
import miniquake.input as frontendInput
import miniquake.console as frontendConsole
import miniquake.menu as frontendMenu
import miniquake.gl_vidnt as frontendVideo

/// Defines the status value used by `miniquake.frontend_contract`.
const STATUS = "frontend_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.frontend_contract`.
const FINGERPRINT = 0x924251fa
/// Defines the key count value used by `miniquake.frontend_contract`.
const KEY_COUNT = 256
/// Defines the history lines value used by `miniquake.frontend_contract`.
const HISTORY_LINES = 32
/// Defines the max command line value used by `miniquake.frontend_contract`.
const MAX_COMMAND_LINE = 256
/// Defines the chat bytes value used by `miniquake.frontend_contract`.
const CHAT_BYTES = 31
/// Defines the console text bytes value used by `miniquake.frontend_contract`.
const CONSOLE_TEXT_BYTES = 16384
/// Defines the notify times value used by `miniquake.frontend_contract`.
const NOTIFY_TIMES = 4
/// Defines the joystick axes value used by `miniquake.frontend_contract`.
const JOYSTICK_AXES = 6
/// Defines the mouse buttons value used by `miniquake.frontend_contract`.
const MOUSE_BUTTONS = 3
/// Defines the options items value used by `miniquake.frontend_contract`.
const OPTIONS_ITEMS = 14
/// Defines the help pages value used by `miniquake.frontend_contract`.
const HELP_PAGES = 6
/// Defines the max video modes value used by `miniquake.frontend_contract`.
const MAX_VIDEO_MODES = 30
/// Defines the max video descriptions value used by `miniquake.frontend_contract`.
const MAX_VIDEO_DESCRIPTIONS = 27
/// Defines the notify ack edges value used by `miniquake.frontend_contract`.
const NOTIFY_ACK_EDGES = 2

// Return values derived from the active module state.
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

/// Implements the `verify` operation for `miniquake.frontend_contract` (verify).
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
