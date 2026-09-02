/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.protocol_signon.
*/
package miniquake.protocol_signon

import miniquake.constants as c
import miniquake.protocol_write as writer
import miniquake.native as native

/// CL_SignonReply from cl_main.c. Stage four is local client state only and
/// deliberately writes no command: the first fast entity update promotes 3->4.
/// @param buffer The buffer input consumed by `writeClientReply`.
/// @param stage The stage input consumed by `writeClientReply`.
/// @param name Stable name that identifies the requested object or option.
/// @param colors The colors input consumed by `writeClientReply`.
/// @param spawnParms The spawn parms input consumed by `writeClientReply`.
function writeClientReply(buffer, stage, name, colors, spawnParms)
  before = buffer.curSize
  if stage == c.SIGNON_SERVERINFO then
    writer.writeStringCommand(buffer, "prespawn")
  else if stage == c.SIGNON_PRESPAWN then
    writer.writeStringCommand(buffer, "name \"" + name + "\"\n")
    colorValue = native.trunc(colors)
    writer.writeStringCommand(buffer, "color " + (colorValue >> 4) + " " + (colorValue & 15) + "\n")
    writer.writeStringCommand(buffer, "spawn " + spawnParms)
  else if stage == c.SIGNON_SPAWN then
    writer.writeStringCommand(buffer, "begin")
  end if
  return buffer.curSize - before
end function
