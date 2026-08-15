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

const NET_PROTOCOL_VERSION = 3
const GAME_NAME = "QUAKE"

const CCREQ_CONNECT = 0x01
const CCREQ_SERVER_INFO = 0x02
const CCREQ_PLAYER_INFO = 0x03
const CCREQ_RULE_INFO = 0x04

const CCREP_ACCEPT = 0x81
const CCREP_REJECT = 0x82
const CCREP_SERVER_INFO = 0x83
const CCREP_PLAYER_INFO = 0x84
const CCREP_RULE_INFO = 0x85

// Provide wrap behavior for the active subsystem.
function wrap(buffer)
  return datagram.control(sz.dataSlice(buffer))
end function

// Provide request connect behavior for the active subsystem.
function requestConnect()
  buffer = sz.alloc(64)
  msg.writeByte(buffer, CCREQ_CONNECT)
  msg.writeString(buffer, GAME_NAME)
  msg.writeByte(buffer, NET_PROTOCOL_VERSION)
  return wrap(buffer)
end function

// Provide request server info behavior for the active subsystem.
function requestServerInfo()
  buffer = sz.alloc(64)
  msg.writeByte(buffer, CCREQ_SERVER_INFO)
  msg.writeString(buffer, GAME_NAME)
  msg.writeByte(buffer, NET_PROTOCOL_VERSION)
  return wrap(buffer)
end function

// Provide request player info behavior for the active subsystem.
function requestPlayerInfo(playerNumber)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, CCREQ_PLAYER_INFO)
  msg.writeByte(buffer, playerNumber)
  return wrap(buffer)
end function

// Provide request rule info behavior for the active subsystem.
function requestRuleInfo(previousRule)
  buffer = sz.alloc(256)
  msg.writeByte(buffer, CCREQ_RULE_INFO)
  msg.writeString(buffer, previousRule)
  return wrap(buffer)
end function

// Provide reply accept behavior for the active subsystem.
function replyAccept(port)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, CCREP_ACCEPT)
  msg.writeLong(buffer, port)
  return wrap(buffer)
end function

// Provide reply reject behavior for the active subsystem.
function replyReject(reason)
  buffer = sz.alloc(512)
  msg.writeByte(buffer, CCREP_REJECT)
  msg.writeString(buffer, reason)
  return wrap(buffer)
end function

// Provide reply server info behavior for the active subsystem.
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

// Provide reply player info behavior for the active subsystem.
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

// Provide reply rule info behavior for the active subsystem.
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

// Returns [command, fields].  The field order is the exact net.h wire order.
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

// Report whether valid quake request.
function validQuakeRequest(parsed)
  if parsed[0] != CCREQ_CONNECT and parsed[0] != CCREQ_SERVER_INFO then return false end if
  if parsed[1][0] != GAME_NAME then return false end if
  if parsed[0] == CCREQ_CONNECT then return parsed[1][1] == NET_PROTOCOL_VERSION end if
  // The original server-info path consumes the version byte but only checks
  // the game name; compatibility is reported in CCREP_SERVER_INFO.
  return true
end function

// Report whether valid connect request.
function inline validConnectRequest(parsed)
  return parsed[0] == CCREQ_CONNECT and parsed[1][0] == GAME_NAME and parsed[1][1] == NET_PROTOCOL_VERSION
end function

// Report whether valid server info request.
function inline validServerInfoRequest(parsed)
  return parsed[0] == CCREQ_SERVER_INFO and parsed[1][0] == GAME_NAME
end function
