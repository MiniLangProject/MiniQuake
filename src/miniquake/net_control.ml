/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.net_control.
*/
package miniquake.net_control

import miniquake.net_datagram as datagram
import miniquake.sizebuf as sz
import miniquake.message as msg

/// Defines the net protocol version value used by `miniquake.net_control`.
const NET_PROTOCOL_VERSION = 3
/// Defines the game name value used by `miniquake.net_control`.
const GAME_NAME = "QUAKE"

/// Defines the ccreq connect value used by `miniquake.net_control`.
const CCREQ_CONNECT = 0x01
/// Defines the ccreq server info value used by `miniquake.net_control`.
const CCREQ_SERVER_INFO = 0x02
/// Defines the ccreq player info value used by `miniquake.net_control`.
const CCREQ_PLAYER_INFO = 0x03
/// Defines the ccreq rule info value used by `miniquake.net_control`.
const CCREQ_RULE_INFO = 0x04

/// Defines the ccrep accept value used by `miniquake.net_control`.
const CCREP_ACCEPT = 0x81
/// Defines the ccrep reject value used by `miniquake.net_control`.
const CCREP_REJECT = 0x82
/// Defines the ccrep server info value used by `miniquake.net_control`.
const CCREP_SERVER_INFO = 0x83
/// Defines the ccrep player info value used by `miniquake.net_control`.
const CCREP_PLAYER_INFO = 0x84
/// Defines the ccrep rule info value used by `miniquake.net_control`.
const CCREP_RULE_INFO = 0x85

/// Implements the `wrap` operation for `miniquake.net_control` (wrap).
/// @param buffer The buffer input consumed by `wrap`.
function wrap(buffer)
  return datagram.control(sz.dataSlice(buffer))
end function

/// Implements the `requestConnect` operation for `miniquake.net_control` (request connect).
function requestConnect()
  buffer = sz.alloc(64)
  msg.writeByte(buffer, CCREQ_CONNECT)
  msg.writeString(buffer, GAME_NAME)
  msg.writeByte(buffer, NET_PROTOCOL_VERSION)
  return wrap(buffer)
end function

/// Implements the `requestServerInfo` operation for `miniquake.net_control` (request server info).
function requestServerInfo()
  buffer = sz.alloc(64)
  msg.writeByte(buffer, CCREQ_SERVER_INFO)
  msg.writeString(buffer, GAME_NAME)
  msg.writeByte(buffer, NET_PROTOCOL_VERSION)
  return wrap(buffer)
end function

/// Implements the `requestPlayerInfo` operation for `miniquake.net_control` (request player info).
/// @param playerNumber The player number input consumed by `requestPlayerInfo`.
function requestPlayerInfo(playerNumber)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, CCREQ_PLAYER_INFO)
  msg.writeByte(buffer, playerNumber)
  return wrap(buffer)
end function

/// Implements the `requestRuleInfo` operation for `miniquake.net_control` (request rule info).
/// @param previousRule The previous rule input consumed by `requestRuleInfo`.
function requestRuleInfo(previousRule)
  buffer = sz.alloc(256)
  msg.writeByte(buffer, CCREQ_RULE_INFO)
  msg.writeString(buffer, previousRule)
  return wrap(buffer)
end function

/// Implements the `replyAccept` operation for `miniquake.net_control` (reply accept).
/// @param port The port input consumed by `replyAccept`.
function replyAccept(port)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, CCREP_ACCEPT)
  msg.writeLong(buffer, port)
  return wrap(buffer)
end function

/// Implements the `replyReject` operation for `miniquake.net_control` (reply reject).
/// @param reason The reason input consumed by `replyReject`.
function replyReject(reason)
  buffer = sz.alloc(512)
  msg.writeByte(buffer, CCREP_REJECT)
  msg.writeString(buffer, reason)
  return wrap(buffer)
end function

/// Implements the `replyServerInfo` operation for `miniquake.net_control` (reply server info).
/// @param address Network address of the peer.
/// @param hostName Name that identifies the requested value or resource.
/// @param levelName Name that identifies the requested value or resource.
/// @param currentPlayers The current players input consumed by `replyServerInfo`.
/// @param maxPlayers The max players input consumed by `replyServerInfo`.
function replyServerInfo(address, hostName, levelName, currentPlayers, maxPlayers)
  buffer = sz.alloc(512)
  msg.writeByte(buffer, CCREP_SERVER_INFO)
  msg.writeString(buffer, address)
  msg.writeString(buffer, hostName)
  msg.writeString(buffer, levelName)
  msg.writeByte(buffer, currentPlayers)
  msg.writeByte(buffer, maxPlayers)
  msg.writeByte(buffer, NET_PROTOCOL_VERSION)
  return wrap(buffer)
end function

/// Implements the `replyPlayerInfo` operation for `miniquake.net_control` (reply player info).
/// @param playerNumber The player number input consumed by `replyPlayerInfo`.
/// @param name Stable name that identifies the requested object or option.
/// @param colors The colors input consumed by `replyPlayerInfo`.
/// @param frags The frags input consumed by `replyPlayerInfo`.
/// @param connectTime Time value used by the operation.
/// @param address Network address of the peer.
function replyPlayerInfo(playerNumber, name, colors, frags, connectTime, address)
  buffer = sz.alloc(512)
  msg.writeByte(buffer, CCREP_PLAYER_INFO)
  msg.writeByte(buffer, playerNumber)
  msg.writeString(buffer, name)
  msg.writeLong(buffer, colors)
  msg.writeLong(buffer, frags)
  msg.writeLong(buffer, connectTime)
  msg.writeString(buffer, address)
  return wrap(buffer)
end function

/// Implements the `replyRuleInfo` operation for `miniquake.net_control` (reply rule info).
/// @param rule The rule input consumed by `replyRuleInfo`.
/// @param value Value consumed by `replyRuleInfo`.
function replyRuleInfo(rule, value)
  buffer = sz.alloc(512)
  msg.writeByte(buffer, CCREP_RULE_INFO)
  // net_dgrm.c terminates rule enumeration with a command-only packet.
  if rule != "" then
    msg.writeString(buffer, rule)
    msg.writeString(buffer, value)
  end if
  return wrap(buffer)
end function

/// Returns [command, fields].  The field order is the exact net.h wire order.
/// @param wirePacket The wire packet input consumed by `parse`.
function parse(wirePacket)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  packet = datagram.decodePacket(wirePacket)
  if packet is error then return packet end if
  if packet.flags != datagram.NETFLAG_CTL then return error(3420, "not a connectionless control packet") end if
  reader = msg.beginReadingBytes(packet.payload)
  if msg.remaining(reader) < 1 then return error(3421, "empty connectionless control packet") end if
  command = msg.readByte(reader)
  fields = []
  if command == CCREQ_CONNECT or command == CCREQ_SERVER_INFO then
    fields = [msg.readString(reader), msg.readByte(reader)]
  else if command == CCREQ_PLAYER_INFO then
    fields = [msg.readByte(reader)]
  else if command == CCREQ_RULE_INFO then
    fields = [msg.readString(reader)]
  else if command == CCREP_ACCEPT then
    fields = [msg.readLong(reader)]
  else if command == CCREP_REJECT then
    fields = [msg.readString(reader)]
  else if command == CCREP_SERVER_INFO then
    fields = [
      msg.readString(reader),
      msg.readString(reader),
      msg.readString(reader),
      msg.readByte(reader),
      msg.readByte(reader),
      msg.readByte(reader),
    ]
  else if command == CCREP_PLAYER_INFO then
    fields = [
      msg.readByte(reader),
      msg.readString(reader),
      msg.readLong(reader),
      msg.readLong(reader),
      msg.readLong(reader),
      msg.readString(reader),
    ]
  else if command == CCREP_RULE_INFO then
    if msg.remaining(reader) == 0 then fields = ["", ""] else fields = [msg.readString(reader), msg.readString(reader)] end if
  else
    return error(3422, "unknown connectionless command " + command)
  end if
  if reader.badRead then return error(3423, "truncated connectionless control packet") end if
  return [command, fields]
end function

/// Report whether valid quake request.
/// @param parsed The parsed input consumed by `validQuakeRequest`.
function validQuakeRequest(parsed)
  if parsed[0] != CCREQ_CONNECT and parsed[0] != CCREQ_SERVER_INFO then return false end if
  if parsed[1][0] != GAME_NAME then return false end if
  if parsed[0] == CCREQ_CONNECT then return parsed[1][1] == NET_PROTOCOL_VERSION end if
  // The original server-info path consumes the version byte but only checks
  // the game name; compatibility is reported in CCREP_SERVER_INFO.
  return true
end function

/// Report whether valid connect request.
/// @param parsed The parsed input consumed by `validConnectRequest`.
function inline validConnectRequest(parsed)
  return parsed[0] == CCREQ_CONNECT and parsed[1][0] == GAME_NAME and parsed[1][1] == NET_PROTOCOL_VERSION
end function

/// Report whether valid server info request.
/// @param parsed The parsed input consumed by `validServerInfoRequest`.
function inline validServerInfoRequest(parsed)
  return parsed[0] == CCREQ_SERVER_INFO and parsed[1][0] == GAME_NAME
end function
