/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused net_loop.c framing, flow-control and reconnect fixtures.
*/
import miniquake.net_loop as loopPort
import miniquake.net_datagram as datagram
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.types as t

// Assert that the condition holds and identify a failing test.
function loopRequire(value, message)
  if not value then return error(9970, message) end if
  return true
end function

// Exercise message text as part of this deterministic regression fixture.
function messageText(text)
  buffer = sz.alloc(256)
  msg.writeString(buffer, text)
  return buffer
end function

// Verify init search and alignment against the expected Quake behavior.
function testInitSearchAndAlignment()
  loopRequire(loopPort.Loop_Init(false) == 0, "client loop init")
  loopRequire(loopPort.Loop_Init(true) == -1, "dedicated loop disabled")
  loopRequire(loopPort.IntAlign(0) == 0, "align zero")
  loopRequire(loopPort.IntAlign(1) == 4, "align one")
  loopRequire(loopPort.IntAlign(4) == 4, "align four")
  loopRequire(loopPort.IntAlign(7) == 8, "align seven")

  state = loopPort.createState()
  loopRequire(len(loopPort.Loop_SearchForHosts(state, false, 0)) == 0, "inactive server not advertised")
  loopPort.configureServer(state, "UNNAMED", "e1m1", 1, 4)
  hosts = loopPort.Loop_SearchForHosts(state, true, 0)
  loopRequire(len(hosts) == 1, "single local host")
  loopRequire(hosts[0][0] == "local", "local canonical name")
  loopRequire(hosts[0][1] == "local", "unnamed display fallback")
  loopRequire(hosts[0][2] == "e1m1", "local map")
  loopRequire(hosts[0][3] == 1 and hosts[0][4] == 4, "local users")
  state.hostName = "Ranger's game"
  hosts = loopPort.Loop_SearchForHosts(state, true, 0)
  loopRequire(hosts[0][1] == "Ranger's game", "configured hostname")

  localParts = loopPort.numericAddressParts(loopPort.expandPartialIPAddress("23"))
  loopRequire(localParts is not void and len(localParts) == 4, "partial IPv4 expansion")
  loopRequire(localParts[3] == 23, "partial IPv4 suffix")
  parsedAddress = loopPort.parseAddress("23:27001", 26000)
  loopRequire(parsedAddress[0] == localParts[0] + "." + localParts[1] + "." + localParts[2] + ".23", "production partial connect address")
  loopRequire(parsedAddress[1] == 27001, "partial connect explicit port")
  state.listener = t.UdpSocket(0, 26000, "", true, "10.20.30.40", false)
  loopRequire(loopPort.publicListenerAddress(state) == "10.20.30.40:26000", "-ip listener address in server-info reply")
  duplicateNames = [["a", "abcdefghijklmnZ", "", 0, 0, 3]]
  loopRequire(loopPort.uniqueHostName(duplicateNames, "abcdefghijklmnZ") == "abcdefghijklmn[", "15-byte host conflict increments final byte")
  loopRequire(loopPort.Loop_Shutdown(), "loop shutdown")
  return true
end function

// Verify connection and message order against the expected Quake behavior.
function testConnectionAndMessageOrder()
  state = loopPort.createState()
  loopRequire(loopPort.Loop_Connect(state, "LOCAL") is void, "host comparison is exact")
  client = loopPort.Loop_Connect(state, "local")
  loopRequire(client is not void and client.address == "localhost", "client address")
  // Messages sent before NET accepts the pending server socket are discarded
  // by Loop_CheckNewConnections, as in the original reset sequence.
  loopRequire(loopPort.Loop_SendMessage(client, messageText("stale")) == 1, "preaccept send")
  serverSocket = loopPort.Loop_CheckNewConnections(state)
  loopRequire(serverSocket is not void and serverSocket.address == "LOCAL", "server address")
  incoming = sz.alloc(512)
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 0, "accept clears stale queue")
  loopRequire(loopPort.Loop_CheckNewConnections(state) is void, "pending accepted once")

  first = messageText("first")
  snapshot = messageText("snapshot")
  second = messageText("second")
  loopRequire(loopPort.Loop_SendMessage(client, first) == 1, "first reliable send")
  loopRequire(not loopPort.Loop_CanSendMessage(client), "reliable flow control closes")
  loopRequire(loopPort.Loop_SendUnreliableMessage(client, snapshot) == 1, "unreliable queued")
  // The raw loop driver accepts another reliable record if called directly;
  // NET_SendMessage normally prevents this through Loop_CanSendMessage.
  loopRequire(loopPort.Loop_SendMessage(client, second) == 1, "direct second reliable")
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 1, "first reliable type")
  reader = msg.beginReading(incoming)
  loopRequire(msg.readString(reader) == "first", "first reliable payload")
  loopRequire(loopPort.Loop_CanSendMessage(client), "reliable receive acknowledges sender")
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 2, "unreliable type")
  reader = msg.beginReading(incoming)
  loopRequire(msg.readString(reader) == "snapshot", "unreliable payload")
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 1, "second reliable type")
  reader = msg.beginReading(incoming)
  loopRequire(msg.readString(reader) == "second", "second reliable payload")
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 0, "queue drained")
  loopRequire(loopPort.Loop_CanSendUnreliableMessage(void), "unreliable always sendable")
  return true
end function

// Verify capacity close and reconnect against the expected Quake behavior.
function testCapacityCloseAndReconnect()
  state = loopPort.createState()
  client = loopPort.Loop_Connect(state, "local")
  serverSocket = loopPort.Loop_CheckNewConnections(state)
  huge = sz.alloc(8192)
  hugeBytes = bytes(8188)
  sz.write(huge, hugeBytes, 0, len(hugeBytes))
  loopRequire(loopPort.Loop_SendMessage(client, huge) == 1, "exact reliable capacity")
  overflow = try(loopPort.Loop_SendMessage(client, messageText("x")))
  loopRequire(overflow is error, "reliable overflow is fatal")
  incoming = sz.alloc(8192)
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 1, "drain huge reliable")
  loopRequire(incoming.curSize == 8188, "huge reliable length")

  unreliable = sz.alloc(8192)
  unreliableBytes = bytes(8188)
  sz.write(unreliable, unreliableBytes, 0, len(unreliableBytes))
  loopRequire(loopPort.Loop_SendUnreliableMessage(client, unreliable) == 1, "large unreliable fits")
  loopRequire(loopPort.Loop_SendUnreliableMessage(client, messageText("overflow")) == 0, "unreliable overflow drops")
  loopRequire(loopPort.Loop_GetMessage(serverSocket, incoming) == 2, "drain huge unreliable")

  loopRequire(loopPort.Loop_Close(client), "close client")
  loopRequire(serverSocket.peer is void, "close severs peer link")
  loopRequire(loopPort.Loop_SendMessage(serverSocket, messageText("closed")) == -1, "closed peer send fails")

  reconnected = loopPort.Loop_Connect(state, "local")
  accepted = loopPort.Loop_CheckNewConnections(state)
  loopRequire(reconnected is not void and accepted is not void, "reconnect pair")
  loopRequire(loopPort.Loop_SendMessage(reconnected, messageText("again")) == 1, "reconnect send")
  loopRequire(loopPort.Loop_GetMessage(accepted, incoming) == 1, "reconnect receive")
  reader = msg.beginReading(incoming)
  loopRequire(msg.readString(reader) == "again", "reconnect payload")
  return true
end function

// Verify datagram reconnect classification against the expected Quake behavior.
function testDatagramReconnectClassification()
  now = 100.0
  loopRequire(loopPort.connectionRequestAction(void, 28000, now) == "new", "new address accepted")
  existing = loopPort.createRemoteSocket(void, "127.0.0.1", 27000)
  existing.connectTime = 99.0
  loopRequire(loopPort.connectionRequestAction(existing, 27000, now) == "duplicate", "recent endpoint is duplicate")
  loopRequire(loopPort.connectionRequestAction(existing, 28000, now) == "replace", "new source port replaces crash")
  existing.connectTime = 97.0
  loopRequire(loopPort.connectionRequestAction(existing, 27000, now) == "replace", "expired duplicate replaces crash")
  return true
end function

// Verify parallel remote isolation against the expected Quake behavior.
function testParallelRemoteIsolation()
  state = loopPort.createState()
  first = loopPort.createRemoteSocket(void, "127.0.0.2", 28000)
  second = loopPort.createRemoteSocket(void, "127.0.0.3", 28001)
  state.remoteSockets = [first, second]
  loopRequire(loopPort.matchingRemote(state, "127.0.0.2") == first, "first remote address identity")
  loopRequire(loopPort.matchingRemote(state, "127.0.0.3") == second, "second remote address identity")

  firstPacket = datagram.Datagram_SendUnreliableMessage(first.channel, bytes("a0"))
  secondPacket = datagram.Datagram_SendUnreliableMessage(second.channel, bytes("b0"))
  loopRequire(datagram.decodePacket(firstPacket).sequence == 0, "first channel starts at sequence zero")
  loopRequire(datagram.decodePacket(secondPacket).sequence == 0, "second channel independently starts at sequence zero")
  firstNext = datagram.Datagram_SendUnreliableMessage(first.channel, bytes("a1"))
  loopRequire(datagram.decodePacket(firstNext).sequence == 1, "first channel advances independently")
  loopRequire(second.channel.unreliableSendSequence == 1, "second channel remains independently advanced once")
  return true
end function

// Verify that LAN discovery reuses one non-blocking control socket across the
// send/poll phases instead of opening, waiting and closing inside one frame.
function testPersistentHostSearchLifecycle()
  state = loopPort.createState()
  loopRequire(loopPort.Datagram_Init(state, false) == 0, "datagram discovery enabled")
  // NET_Slist_f owns cache reset. Repeated discovery broadcasts must retain
  // replies already collected during the same 1.5-second search window.
  retained = [["192.0.2.1:26000", "Retained", "start", 1, 4]]
  state.hostCache = retained
  first = try(loopPort.Datagram_SearchForHosts(state, true, 65534, 0))
  loopRequire(first is not error, "non-blocking discovery broadcast")
  loopRequire(len(first) >= 1 and first[0][1] == "Retained", "broadcast retains prior replies")
  loopRequire(loopPort.Datagram_HostSearchActive(), "discovery socket persists after broadcast")
  second = try(loopPort.Datagram_SearchForHosts(state, false, 65534, 0))
  loopRequire(second is not error, "non-blocking discovery reply poll")
  loopRequire(loopPort.Datagram_HostSearchActive(), "discovery socket persists across poll")
  loopRequire(loopPort.Datagram_EndHostSearch(), "discovery socket closes explicitly")
  loopRequire(not loopPort.Datagram_HostSearchActive(), "discovery socket is released")
  loopPort.Datagram_Shutdown(state)
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/6] init, search and IntAlign"
  result = try(testInitSearchAndAlignment())
  if result is error then print "init/search/alignment failed"; return 1 end if
  print "[2/6] connection and message order"
  result = try(testConnectionAndMessageOrder())
  if result is error then print "connection/message failed"; return 1 end if
  print "[3/6] capacity, close and reconnect"
  result = try(testCapacityCloseAndReconnect())
  if result is error then print "capacity/close/reconnect failed"; return 1 end if
  print "[4/6] datagram reconnect classification"
  result = try(testDatagramReconnectClassification())
  if result is error then print "datagram reconnect classification failed"; return 1 end if
  print "[5/6] parallel remote sequence isolation"
  result = try(testParallelRemoteIsolation())
  if result is error then print "parallel remote isolation failed"; return 1 end if
  print "[6/6] persistent non-blocking host search"
  result = try(testPersistentHostSearchLifecycle())
  if result is error then print "persistent host search failed"; return 1 end if
  print "NET_LOOP PORT TESTS PASSED (6/6)"
  return 0
end function
