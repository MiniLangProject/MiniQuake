/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-061: net_dgrm.c control queries, discovery cache and connect classification.
*/
import miniquake.net_control as control
import miniquake.net_datagram as datagram
import miniquake.net_loop as netloop
import miniquake.types as t

testIndex = 0
failures = 0

// Assert that the condition holds and identify a failing test.
function bp061Check(value, name)
  global testIndex, failures
  testIndex = testIndex + 1
  print "[" + testIndex + "/24] " + name
  if not value then failures = failures + 1; print "FAIL: " + name; return false end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  bp061Check(control.NET_PROTOCOL_VERSION == 3 and control.GAME_NAME == "QUAKE", "control protocol identity")

  connectRequest = control.parse(control.requestConnect())
  bp061Check(connectRequest[0] == control.CCREQ_CONNECT and control.validConnectRequest(connectRequest), "connect request")
  serverRequest = control.parse(control.requestServerInfo())
  bp061Check(serverRequest[0] == control.CCREQ_SERVER_INFO and control.validServerInfoRequest(serverRequest), "server-info request")
  playerRequest = control.parse(control.requestPlayerInfo(7))
  bp061Check(playerRequest[0] == control.CCREQ_PLAYER_INFO and playerRequest[1][0] == 7, "player-info request")
  ruleRequest = control.parse(control.requestRuleInfo("fraglimit"))
  bp061Check(ruleRequest[0] == control.CCREQ_RULE_INFO and ruleRequest[1][0] == "fraglimit", "rule-info request")

  accepted = control.parse(control.replyAccept(28000))
  bp061Check(accepted[0] == control.CCREP_ACCEPT and accepted[1][0] == 28000, "accept reply")
  rejected = control.parse(control.replyReject("Server is full."))
  bp061Check(rejected[0] == control.CCREP_REJECT and rejected[1][0] == "Server is full.", "reject reply")
  serverInfo = control.parse(control.replyServerInfo("1.2.3.4:26000", "Ranger", "e1m1", 2, 8))
  bp061Check(serverInfo[0] == control.CCREP_SERVER_INFO and serverInfo[1][0] == "1.2.3.4:26000" and serverInfo[1][5] == 3, "server-info reply")
  playerInfo = control.parse(control.replyPlayerInfo(2, "Ranger", 0x4f, 12, 31, "1.2.3.4:26000"))
  bp061Check(playerInfo[0] == control.CCREP_PLAYER_INFO and playerInfo[1][2] == 0x4f and playerInfo[1][3] == 12, "player-info reply")
  ruleInfo = control.parse(control.replyRuleInfo("deathmatch", "1"))
  bp061Check(ruleInfo[0] == control.CCREP_RULE_INFO and ruleInfo[1][0] == "deathmatch", "rule-info reply")

  malformed = bytes(control.requestConnect())
  malformed[3] = (malformed[3] + 1) & 255
  bp061Check(try(control.parse(malformed)) is error, "reject mismatched control length")
  bp061Check((datagram.bigU32(control.requestServerInfo(), 0) & datagram.NETFLAG_CTL) != 0, "control flag set")

  bp061Check(netloop.HOST_CACHE_SIZE == 8, "host cache size")
  hosts = [["a", "abcdefghijklmnZ", "start", 0, 4, 3]]
  bp061Check(netloop.uniqueHostName(hosts, "abcdefghijklmnZ") == "abcdefghijklmn[", "case-insensitive name conflict suffix")
  bp061Check(netloop.uniqueHostName([], "") == "UNNAMED", "empty discovery name fallback")
  bp061Check(netloop.discoveredAddress(["0.0.0.0:27001"], "10.1.2.3", 26000) == "10.1.2.3:27001", "wildcard advertised address")
  bp061Check(netloop.discoveredAddress(["192.168.1.8:27001"], "10.1.2.3", 26000) == "192.168.1.8:27001", "explicit advertised address")
  bp061Check(netloop.listenerAddress("10.0.0.5", 26000) == "10.0.0.5:26000", "listener address text")

  rules = [["deathmatch", "1"], ["fraglimit", "20"]]
  unknownRule = try(netloop.nextServerRule(rules, "missing"))
  bp061Check(netloop.nextServerRule(rules, "")[0] == "deathmatch" and netloop.nextServerRule(rules, "deathmatch")[0] == "fraglimit" and unknownRule is error, "rule enumeration")
  finalRule = netloop.nextServerRule(rules, "fraglimit")
  terminatorPacket = control.parse(control.replyRuleInfo(finalRule[0], finalRule[1]))
  bp061Check(finalRule[0] == "" and finalRule[1] == "" and terminatorPacket[0] == control.CCREP_RULE_INFO and terminatorPacket[1][0] == "" and terminatorPacket[1][1] == "", "rule enumeration terminator")

  remote = netloop.createRemoteSocket(void, "127.0.0.1", 27000)
  remote.connectTime = 99.0
  bp061Check(netloop.connectionRequestAction(remote, 27000, 100.0) == "duplicate", "recent duplicate connect")
  bp061Check(netloop.connectionRequestAction(remote, 28000, 100.0) == "replace", "new source port replaces crashed connect")

  state = netloop.createState()
  state.remoteSockets = [remote]
  bp061Check(netloop.matchingRemote(state, "127.0.0.1") == remote, "remote address lookup")
  state.banAddress = 0x0a000000
  state.banMask = 0xff000000
  bp061Check(netloop.addressIsBanned(state, "10.23.45.67") and not netloop.addressIsBanned(state, "11.23.45.67"), "IPv4 ban mask")

  if failures > 0 then print "MiniQuake BP-061 network control tests failed: " + failures + "/24"; return 1 end if
  print "MiniQuake BP-061 network control tests passed: 24"
  return 0
end function
