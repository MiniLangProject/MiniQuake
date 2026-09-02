/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.protocol_write.
*/
package miniquake.protocol_write

import miniquake.constants as c
import miniquake.message as msg
import miniquake.native as native

/// Encode and write string command.
/// @param buffer The buffer input consumed by `writeStringCommand`.
/// @param text Text to parse or process.
function writeStringCommand(buffer, text)
  msg.writeByte(buffer, c.CLC_STRINGCMD)
  msg.writeString(buffer, text)
end function

/// Encode and write disconnect.
/// @param buffer The buffer input consumed by `writeDisconnect`.
function writeDisconnect(buffer)
  msg.writeByte(buffer, c.CLC_DISCONNECT)
end function

/// Encode and write move.
/// @param buffer The buffer input consumed by `writeMove`.
/// @param command Console or protocol command to execute.
/// @param clientTime Time value used by the operation.
function writeMove(buffer, command, clientTime)
  msg.writeByte(buffer, c.CLC_MOVE)
  msg.writeFloat(buffer, clientTime)
  msg.writeAngle(buffer, command.viewAngles.x)
  msg.writeAngle(buffer, command.viewAngles.y)
  msg.writeAngle(buffer, command.viewAngles.z)
  // WinQuake's usercmd_t movement fields are floats, while MSG_WriteShort
  // accepts an int. C performs that truncating conversion at the call boundary;
  // MiniLang keeps the float unless we make the conversion explicit.
  msg.writeShort(buffer, native.trunc(command.forwardMove))
  msg.writeShort(buffer, native.trunc(command.sideMove))
  msg.writeShort(buffer, native.trunc(command.upMove))
  msg.writeByte(buffer, command.buttons)
  msg.writeByte(buffer, command.impulse)
  return buffer
end function

/// Writes baseline for `miniquake.protocol_write`.
/// @param buffer The buffer input consumed by `writeBaseline`.
/// @param baseline The baseline input consumed by `writeBaseline`.
function writeBaseline(buffer, baseline)
  msg.writeByte(buffer, baseline[0])
  msg.writeByte(buffer, baseline[1])
  msg.writeByte(buffer, baseline[2])
  msg.writeByte(buffer, baseline[3])
  origin = baseline[4]
  angles = baseline[5]
  msg.writeCoord(buffer, origin.x); msg.writeAngle(buffer, angles.x)
  msg.writeCoord(buffer, origin.y); msg.writeAngle(buffer, angles.y)
  msg.writeCoord(buffer, origin.z); msg.writeAngle(buffer, angles.z)
end function
