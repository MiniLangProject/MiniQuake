/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-016 Protocol-15 reliable/unreliable delivery and failure-order fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_delivery as delivery
import miniquake.protocol_serverdata as planning
import miniquake.protocol_transients as transients
import miniquake.client as client
import miniquake.server as server
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.player_move as movement

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9600, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(9601, name + ": expected true") end if
  return true
end function
// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(9602, name + ": expected false") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "  [" + number + "/14] " + name
  result = try(fn())
  if result is error then print "    FAIL: " + result.message; return false end if
  return true
end function

// Exercise player as part of this deterministic regression fixture.
function player()
  return movement.createPlayer(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
end function

// Exercise pair as part of this deterministic regression fixture.
function pair()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  a = netmain.NET_Connect(network, "local", 1)
  b = netmain.NET_CheckNewConnections(network)
  if a is void or b is void then return error(9603, "loop pair missing") end if
  return [network, a, b]
end function

// Release or remove state for pair.
function closePair(value)
  if value[2] is not void then netmain.NET_Close(value[2]) end if
  if value[1] is not void then netmain.NET_Close(value[1]) end if
  netmain.NET_Shutdown(value[0])
  return true
end function

// Verify outcome classification against the expected Quake behavior.
function testOutcomeClassification()
  equal(delivery.reliableSendOutcome(-1), delivery.SEND_DROP, "negative result")
  equal(delivery.reliableSendOutcome(0), delivery.SEND_RETAIN, "zero result")
  equal(delivery.reliableSendOutcome(1), delivery.SEND_COMMIT, "positive result")
  return true
end function

// Verify client plans against the expected Quake behavior.
function testClientPlans()
  equal(delivery.clientReliablePlan(false, 10, true), delivery.SEND_DROP, "disconnected")
  equal(delivery.clientReliablePlan(true, 0, true), 0, "empty")
  equal(delivery.clientReliablePlan(true, 10, false), delivery.SEND_RETAIN, "blocked")
  equal(delivery.clientReliablePlan(true, 10, true), delivery.SEND_COMMIT, "sendable")
  return true
end function

// Verify keepalive strict boundary against the expected Quake behavior.
function testKeepaliveStrictBoundary()
  no(delivery.keepaliveDue(5.0), "exactly five seconds")
  yes(delivery.keepaliveDue(5.000001), "strictly above five seconds")
  return true
end function

// Verify initial delivery plans against the expected Quake behavior.
function testInitialDeliveryPlans()
  equal(planning.initialDeliveryPlan(true, false, 0.0), planning.PLAN_SEND_UNRELIABLE | planning.PLAN_RELIABLE_PHASE, "spawned plan")
  equal(planning.initialDeliveryPlan(false, false, 5.0), planning.PLAN_WAIT_SIGNON, "signon exact keepalive")
  equal(planning.initialDeliveryPlan(false, false, 5.1), planning.PLAN_SEND_NOP, "signon keepalive")
  equal(planning.initialDeliveryPlan(false, true, 0.0), planning.PLAN_RELIABLE_PHASE, "requested signon")
  return true
end function

// Verify reliable ordering against the expected Quake behavior.
function testReliableOrdering()
  equal(planning.reliableDeliveryPlan(true, 1, true, true), planning.RELIABLE_DROP_OVERFLOW, "overflow first")
  equal(planning.reliableDeliveryPlan(false, 0, true, false), planning.RELIABLE_WAIT, "drop waits blocked")
  equal(planning.reliableDeliveryPlan(false, 0, true, true), planning.RELIABLE_DROP_ASAP, "drop when sendable")
  equal(planning.reliableDeliveryPlan(false, 1, false, true), planning.RELIABLE_SEND, "normal reliable")
  return true
end function

// Verify blocked client queue against the expected Quake behavior.
function testBlockedClientQueue()
  value = pair()
  if value is error then return value end if
  localClient = client.create(player())
  localClient.connected = true
  localClient.socket = value[1]
  client.queueString(localClient, "status")
  value[1].canSend = false
  equal(client.sendReliable(localClient), 0, "blocked client send")
  yes(localClient.outgoing.curSize > 0, "blocked client queue retained")
  value[1].canSend = true
  equal(client.sendReliable(localClient), 1, "unblocked client send")
  equal(localClient.outgoing.curSize, 0, "committed client queue cleared")
  closePair(value)
  return true
end function

// Verify blocked server queue against the expected Quake behavior.
function testBlockedServerQueue()
  value = pair()
  if value is error then return value end if
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.spawned = true
  target.socket = value[2]
  target.sendSignon = true
  msg.writeByte(target.message, c.SVC_PRINT); msg.writeString(target.message, "queued")
  value[2].canSend = false
  equal(server.processReliableClientAt(game, target, 1.0), 0, "blocked server send")
  yes(target.message.curSize > 0, "blocked server queue retained")
  yes(target.sendSignon, "blocked sendsignon retained")
  value[2].canSend = true
  equal(server.processReliableClientAt(game, target, 1.1), 1, "unblocked server send")
  equal(target.message.curSize, 0, "committed server queue cleared")
  no(target.sendSignon, "committed sendsignon cleared")
  closePair(value)
  return true
end function

// Verify reliable broadcast accumulates during signon against the expected Quake behavior.
function testReliableBroadcastAccumulatesDuringSignon()
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.spawned = false
  target.sendSignon = false
  msg.writeByte(game.reliableDatagram, c.SVC_SETPAUSE); msg.writeByte(game.reliableDatagram, 1)
  server.prepareReliableMessages(game)
  equal(target.message.curSize, 2, "reliable bytes accumulate")
  equal(game.reliableDatagram.curSize, 0, "broadcast source cleared")
  return true
end function

// Verify reconnect payload against the expected Quake behavior.
function testReconnectPayload()
  buffer = sz.alloc(32)
  transients.writeReconnect(buffer)
  equal(hex(sz.dataSlice(buffer)), "097265636f6e6e6563740a00", "reconnect payload")
  return true
end function

// Verify nop payload and timestamp against the expected Quake behavior.
function testNopPayloadAndTimestamp()
  value = pair()
  if value is error then return value end if
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.socket = value[2]
  equal(server.sendNopAt(game, target, 7.0), 1, "nop send")
  equal(target.lastMessage, 7.0, "nop updates last_message")
  incoming = sz.alloc(8)
  equal(netmain.NET_GetMessage(value[1], incoming, 1.0), 2, "nop is unreliable")
  equal(hex(sz.dataSlice(incoming)), "01", "svc_nop payload")
  closePair(value)
  return true
end function

// Verify drop asap waits then drops against the expected Quake behavior.
function testDropAsapWaitsThenDrops()
  value = pair()
  if value is error then return value end if
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.socket = value[2]
  target.dropAsap = true
  value[2].canSend = false
  equal(server.processReliableClientAt(game, target, 1.0), 0, "dropasap blocked")
  yes(target.active, "blocked dropasap remains active")
  value[2].canSend = true
  equal(server.processReliableClientAt(game, target, 1.1), -1, "dropasap executes")
  no(target.active, "dropasap client inactive")
  netmain.NET_Shutdown(value[0])
  return true
end function

// Verify overflow precedes drop asap against the expected Quake behavior.
function testOverflowPrecedesDropAsap()
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.dropAsap = true
  target.message.overflowed = true
  // No socket is required: overflow must be selected before can-send/dropasap.
  equal(server.processReliableClientAt(game, target, 1.0), -1, "overflow drop result")
  no(target.active, "overflow crashed client")
  no(target.message.overflowed, "overflow flag reset after drop")
  return true
end function

// Verify empty reliable no work against the expected Quake behavior.
function testEmptyReliableNoWork()
  no(delivery.reliableWorkPending(0, false), "empty no work")
  yes(delivery.reliableWorkPending(1, false), "bytes are work")
  yes(delivery.reliableWorkPending(0, true), "dropasap is work")
  return true
end function

// Verify committed message round trip against the expected Quake behavior.
function testCommittedMessageRoundTrip()
  value = pair()
  if value is error then return value end if
  game = server.create(1)
  target = game.clients[0]
  target.active = true
  target.spawned = true
  target.socket = value[2]
  msg.writeByte(target.message, c.SVC_PRINT); msg.writeString(target.message, "hello")
  equal(server.processReliableClientAt(game, target, 2.0), 1, "server reliable commit")
  incoming = sz.alloc(32)
  equal(netmain.NET_GetMessage(value[1], incoming, 1.0), 1, "client receives reliable")
  equal(hex(sz.dataSlice(incoming)), "0868656c6c6f00", "reliable payload preserved")
  closePair(value)
  return true
end function

// Verify send outcome clear contract against the expected Quake behavior.
function testSendOutcomeClearContract()
  no(delivery.clearAfterSend(-1), "failed send does not commit")
  no(delivery.clearAfterSend(0), "blocked send does not commit")
  yes(delivery.clearAfterSend(1), "successful send commits")
  return true
end function

passed = 0
if run(1, "send-result classification", testOutcomeClassification) then passed = passed + 1 end if
if run(2, "client reliable plans", testClientPlans) then passed = passed + 1 end if
if run(3, "strict keepalive boundary", testKeepaliveStrictBoundary) then passed = passed + 1 end if
if run(4, "initial delivery plans", testInitialDeliveryPlans) then passed = passed + 1 end if
if run(5, "overflow/drop/send ordering", testReliableOrdering) then passed = passed + 1 end if
if run(6, "blocked client queue retention", testBlockedClientQueue) then passed = passed + 1 end if
if run(7, "blocked server queue retention", testBlockedServerQueue) then passed = passed + 1 end if
if run(8, "reliable accumulation during signon", testReliableBroadcastAccumulatesDuringSignon) then passed = passed + 1 end if
if run(9, "reconnect payload", testReconnectPayload) then passed = passed + 1 end if
if run(10, "keepalive NOP payload", testNopPayloadAndTimestamp) then passed = passed + 1 end if
if run(11, "dropasap waits then drops", testDropAsapWaitsThenDrops) then passed = passed + 1 end if
if run(12, "overflow precedes dropasap", testOverflowPrecedesDropAsap) then passed = passed + 1 end if
if run(13, "committed reliable roundtrip", testCommittedMessageRoundTrip) then passed = passed + 1 end if
if run(14, "send outcome clear contract", testSendOutcomeClearContract) then passed = passed + 1 end if

if passed != 14 then
  print "MiniQuake BP-016 Protocol 15 delivery tests failed: " + passed + "/14"
  error(9699, "BP-016 Protocol 15 delivery fixtures failed")
end if
print "MiniQuake BP-016 Protocol 15 delivery tests passed: 14"
