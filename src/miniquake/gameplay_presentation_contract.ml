/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.gameplay_presentation_contract.
*/
package miniquake.gameplay_presentation_contract

/// Defines the status value used by `miniquake.gameplay_presentation_contract`.
const STATUS = "gameplay_presentation_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.gameplay_presentation_contract`.
const FINGERPRINT = 0xad91624c
/// Defines the angle units value used by `miniquake.gameplay_presentation_contract`.
const ANGLE_UNITS = 65536
/// Defines the chase trace distance value used by `miniquake.gameplay_presentation_contract`.
const CHASE_TRACE_DISTANCE = 4096
/// Defines the chase back default value used by `miniquake.gameplay_presentation_contract`.
const CHASE_BACK_DEFAULT = 100
/// Defines the chase up default value used by `miniquake.gameplay_presentation_contract`.
const CHASE_UP_DEFAULT = 16
/// Defines the chase right default value used by `miniquake.gameplay_presentation_contract`.
const CHASE_RIGHT_DEFAULT = 0
/// Defines the gamma entries value used by `miniquake.gameplay_presentation_contract`.
const GAMMA_ENTRIES = 256
/// Defines the cshift count value used by `miniquake.gameplay_presentation_contract`.
const CSHIFT_COUNT = 4
/// Defines the view bsp nudge value used by `miniquake.gameplay_presentation_contract`.
const VIEW_BSP_NUDGE = 0.03125
/// Defines the bob max value used by `miniquake.gameplay_presentation_contract`.
const BOB_MAX = 4
/// Defines the bob min value used by `miniquake.gameplay_presentation_contract`.
const BOB_MIN = -7
/// Defines the center line chars value used by `miniquake.gameplay_presentation_contract`.
const CENTER_LINE_CHARS = 40
/// Defines the screenshot slots value used by `miniquake.gameplay_presentation_contract`.
const SCREENSHOT_SLOTS = 100
/// Defines the loading timeout seconds value used by `miniquake.gameplay_presentation_contract`.
const LOADING_TIMEOUT_SECONDS = 60
/// Defines the statusbar height value used by `miniquake.gameplay_presentation_contract`.
const STATUSBAR_HEIGHT = 24
/// Defines the max scoreboard value used by `miniquake.gameplay_presentation_contract`.
const MAX_SCOREBOARD = 16

/// Returns whether `miniquake.gameplay_presentation_contract` can onical text.
function canonicalText()
  return STATUS + "\n" +
    "angle_units=65536\n" +
    "chase_trace_distance=4096\n" +
    "chase_back_default=100\n" +
    "chase_up_default=16\n" +
    "chase_right_default=0\n" +
    "gamma_entries=256\n" +
    "cshift_count=4\n" +
    "view_bsp_nudge=0.03125\n" +
    "bob_max=4\n" +
    "bob_min=-7\n" +
    "center_line_chars=40\n" +
    "screenshot_slots=100\n" +
    "loading_timeout_seconds=60\n" +
    "statusbar_height=24\n" +
    "max_scoreboard=16\n" +
    "host_color_parser=atoi\n" +
    "host_give_parser=atoi\n" +
    "host_viewframe_parser=atoi\n" +
    "host_edict_parser=q_atoi\n" +
    "host_player_index_parser=q_atof\n" +
    "loading_stops_audio_before_gate=1\n" +
    "screenshot_failure_text=PCX\n"
end function

/// Implements the `fnv1a32` operation for `miniquake.gameplay_presentation_contract` (fnv1a32).
/// @param text Text to parse or process.
function fnv1a32(text)
  data = bytes(text)
  value = 0x811c9dc5
  index = 0
  while index < len(data)
    value = ((value ^ data[index]) * 0x01000193) & 0xffffffff
    index = index + 1
  end while
  return value
end function

/// Implements the `verify` operation for `miniquake.gameplay_presentation_contract` (verify).
function verify()
  if fnv1a32(canonicalText()) != FINGERPRINT then return error(10790, "gameplay/presentation fingerprint mismatch") end if
  if ANGLE_UNITS != 65536 or CHASE_TRACE_DISTANCE != 4096 then return error(10791, "math/chase contract mismatch") end if
  if CHASE_BACK_DEFAULT != 100 or CHASE_UP_DEFAULT != 16 or CHASE_RIGHT_DEFAULT != 0 then return error(10792, "chase defaults mismatch") end if
  if GAMMA_ENTRIES != 256 or CSHIFT_COUNT != 4 then return error(10793, "view contract mismatch") end if
  if VIEW_BSP_NUDGE != 0.03125 or BOB_MAX != 4 or BOB_MIN != -7 then return error(10794, "view numeric contract mismatch") end if
  if CENTER_LINE_CHARS != 40 or SCREENSHOT_SLOTS != 100 or LOADING_TIMEOUT_SECONDS != 60 then return error(10795, "screen contract mismatch") end if
  if STATUSBAR_HEIGHT != 24 or MAX_SCOREBOARD != 16 then return error(10796, "statusbar contract mismatch") end if
  return true
end function
