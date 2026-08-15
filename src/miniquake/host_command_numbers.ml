/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Shared numeric argument conversions for host_cmd.c.  The original command
surface deliberately mixes Q_atof and the C runtime atoi; using MiniLang's
stricter toNumber() changes accepted prefixes and therefore observable command
semantics.
*/
package miniquake.host_command_numbers

import miniquake.common as common
import miniquake.native as native

// Return player index derived from the active module state.
function playerIndex(text)
  // Host_Please_f and Host_Kick_f use Q_atof(...)-1 assigned to int.
  return native.trunc(common.atof(text)) - 1
end function

// Provide integer behavior for the active subsystem.
function integer(text)
  // Host_Color_f, Host_Give_f and Host_Viewframe_f use the C runtime atoi.
  // ED_PrintEdict_f is separate and continues to use Quake Q_atoi.
  return common.cAtoi(text)
end function

// Provide color component behavior for the active subsystem.
function colorComponent(value)
  result = native.trunc(value) & 15
  if result > 13 then result = 13 end if
  return result
end function

// Provide color arguments behavior for the active subsystem.
function colorArguments(arguments, firstIndex)
  top = 0
  if firstIndex < len(arguments) then top = integer(arguments[firstIndex]) end if
  bottom = top
  if firstIndex + 1 < len(arguments) then bottom = integer(arguments[firstIndex + 1]) end if
  return [colorComponent(top), colorComponent(bottom)]
end function
