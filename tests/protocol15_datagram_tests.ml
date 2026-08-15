/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-017 byte-exact net_dgrm.c fragmentation, ACK, retransmit and loss tests.
*/
import miniquake.net_datagram as datagram

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(9701, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(9702, name + ": expected false") end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "  [" + number + "/18] " + name
  result = try(fn())
  if result is error then print "    FAIL: " + result.message; return false end if
  return true
end function

// Exercise patterned as part of this deterministic regression fixture.
function patterned(count)
  data = bytes(count)
  index = 0
  while index < count
    data[index] = (index * 17 + 3) & 255
    index = index + 1
  end while
  return data
end function

// Verify header encoding against the expected Quake behavior.
function testHeaderEncoding()
  wire = datagram.encode(datagram.NETFLAG_DATA | datagram.NETFLAG_EOM, 0x12345678, bytes([1, 2, 3]))
  equal(hex(wire), "0009000b12345678010203", "wire header")
  packet = datagram.decodePacket(wire)
  equal(packet.flags, datagram.NETFLAG_DATA | datagram.NETFLAG_EOM, "decoded flags")
  equal(packet.sequence, 0x12345678, "decoded sequence")
  equal(hex(packet.payload), "010203", "decoded payload")
  return true
end function

// Verify fragment boundaries against the expected Quake behavior.
function testFragmentBoundaries()
  exact = datagram.createChannel()
  exactPacket = datagram.Datagram_SendMessage(exact, bytes(datagram.MAX_DATAGRAM), 1.0)
  exactDecoded = datagram.decodePacket(exactPacket)
  yes((exactDecoded.flags & datagram.NETFLAG_EOM) != 0, "exact fragment is EOM")
  equal(len(exactPacket), datagram.MAX_DATAGRAM + datagram.NET_HEADERSIZE, "exact packet size")

  split = datagram.createChannel()
  splitPacket = datagram.Datagram_SendMessage(split, bytes(datagram.MAX_DATAGRAM + 1), 1.0)
  splitDecoded = datagram.decodePacket(splitPacket)
  no((splitDecoded.flags & datagram.NETFLAG_EOM) != 0, "oversize first fragment is not EOM")
  equal(len(splitDecoded.payload), datagram.MAX_DATAGRAM, "first fragment payload")
  return true
end function

// Verify ack defers next fragment against the expected Quake behavior.
function testAckDefersNextFragment()
  sender = datagram.createChannel()
  datagram.Datagram_SendMessage(sender, bytes(1500), 2.0)
  before = datagram.packetsSent
  result = datagram.Datagram_GetMessage(sender, datagram.acknowledgement(0), 2.1)
  equal(result[0], 0, "ACK has no application message")
  yes(result[3] is void, "ACK does not manufacture immediate fragment")
  yes(sender.sendNext, "next fragment marked pending")
  equal(datagram.packetsSent, before, "ACK processing sends nothing")
  next = datagram.Datagram_FlushSendNext(sender, 2.1)
  yes(next is bytes, "pending fragment flushed")
  no(sender.sendNext, "pending marker cleared")
  equal(datagram.decodePacket(next).sequence, 1, "second sequence")
  return true
end function

// Verify reliable reassembly against the expected Quake behavior.
function testReliableReassembly()
  payload = patterned(2500)
  sender = datagram.createChannel()
  receiver = datagram.createChannel()
  packet = datagram.Datagram_SendMessage(sender, payload, 0.0)
  completed = void
  fragments = 0
  while packet is bytes
    fragments = fragments + 1
    received = datagram.Datagram_GetMessage(receiver, packet, fragments * 0.1)
    yes(received[2] is bytes, "fragment ACK")
    if received[0] == 1 then completed = received[1] end if
    acked = datagram.Datagram_GetMessage(sender, received[2], fragments * 0.1 + 0.01)
    yes(acked[3] is void, "ACK is deferred")
    packet = datagram.Datagram_FlushSendNext(sender, fragments * 0.1 + 0.01)
  end while
  equal(fragments, 3, "fragment count")
  yes(completed is bytes, "complete message delivered")
  equal(len(completed), 2500, "complete size")
  equal(hex(completed), hex(payload), "complete payload")
  yes(sender.canSend, "final ACK releases sender")
  equal(len(sender.sendMessage), 0, "send queue drained")
  return true
end function

// Verify lost ack retransmit against the expected Quake behavior.
function testLostAckRetransmit()
  sender = datagram.createChannel()
  receiver = datagram.createChannel()
  first = datagram.Datagram_SendMessage(sender, bytes("lost-ack"), 10.0)
  received = datagram.Datagram_GetMessage(receiver, first, 10.0)
  equal(received[0], 1, "first delivery")
  yes(datagram.pollRetransmit(sender, 11.0) is void, "exact one second waits")
  resent = datagram.pollRetransmit(sender, 11.0001)
  yes(resent is bytes, "above one second retransmits")
  equal(datagram.decodePacket(resent).sequence, 0, "retransmit sequence unchanged")
  duplicate = datagram.Datagram_GetMessage(receiver, resent, 11.0001)
  equal(duplicate[0], 0, "duplicate not redelivered")
  yes(duplicate[2] is bytes, "duplicate re-ACKed")
  datagram.Datagram_GetMessage(sender, duplicate[2], 11.1)
  yes(sender.canSend, "duplicate ACK releases sender")
  return true
end function

// Verify lost data retransmit against the expected Quake behavior.
function testLostDataRetransmit()
  sender = datagram.createChannel()
  first = datagram.Datagram_SendMessage(sender, bytes(1500), 20.0)
  receiver = datagram.createChannel()
  firstResult = datagram.Datagram_GetMessage(receiver, first, 20.0)
  datagram.Datagram_GetMessage(sender, firstResult[2], 20.1)
  second = datagram.Datagram_FlushSendNext(sender, 20.1)
  yes(second is bytes, "second fragment created")
  yes(datagram.pollRetransmit(sender, 21.1) is void, "lost data exact boundary")
  resent = datagram.pollRetransmit(sender, 21.1001)
  equal(hex(resent), hex(second), "lost data retransmit byte-identical")
  return true
end function

// Verify duplicate data against the expected Quake behavior.
function testDuplicateData()
  receiver = datagram.createChannel()
  packet = datagram.encode(datagram.NETFLAG_DATA, 0, bytes([1, 2, 3]))
  first = datagram.Datagram_GetMessage(receiver, packet, 0.0)
  equal(len(receiver.receiveMessage), 3, "first fragment retained")
  duplicate = datagram.Datagram_GetMessage(receiver, packet, 0.1)
  equal(duplicate[0], 0, "duplicate ignored")
  yes(duplicate[2] is bytes, "duplicate ACK")
  equal(len(receiver.receiveMessage), 3, "duplicate not appended")
  return true
end function

// Verify stale and duplicate ack against the expected Quake behavior.
function testStaleAndDuplicateAck()
  sender = datagram.createChannel()
  datagram.Datagram_SendMessage(sender, bytes(1500), 1.0)
  stale = datagram.Datagram_GetMessage(sender, datagram.acknowledgement(7), 1.1)
  equal(stale[0], 0, "stale ACK ignored")
  equal(len(sender.sendMessage), 1500, "stale ACK queue unchanged")
  datagram.Datagram_GetMessage(sender, datagram.acknowledgement(0), 1.2)
  equal(len(sender.sendMessage), 476, "matching ACK advances queue")
  duplicate = datagram.Datagram_GetMessage(sender, datagram.acknowledgement(0), 1.3)
  equal(duplicate[0], 0, "duplicate ACK ignored")
  equal(len(sender.sendMessage), 476, "duplicate ACK queue unchanged")
  return true
end function

// Verify nak extension against the expected Quake behavior.
function testNakExtension()
  sender = datagram.createChannel()
  original = datagram.Datagram_SendMessage(sender, bytes("retry"), 3.0)
  response = datagram.Datagram_GetMessage(sender, datagram.negativeAcknowledgement(0), 3.1)
  yes(response[3] is bytes, "matching NAK creates immediate resend")
  equal(hex(response[3]), hex(original), "NAK resend byte-identical")
  equal(sender.packetsReSent, 1, "NAK resend count")
  return true
end function

// Verify unreliable gap and stale against the expected Quake behavior.
function testUnreliableGapAndStale()
  receiver = datagram.createChannel()
  gap = datagram.Datagram_GetMessage(receiver, datagram.encode(datagram.NETFLAG_UNRELIABLE, 3, bytes("u3")), 1.0)
  equal(gap[0], 2, "gap packet delivered")
  equal(receiver.unreliableReceiveSequence, 4, "unreliable next sequence")
  equal(receiver.droppedUnreliable, 3, "unreliable drop count")
  stale = datagram.Datagram_GetMessage(receiver, datagram.encode(datagram.NETFLAG_UNRELIABLE, 2, bytes("old")), 1.1)
  equal(stale[0], 0, "stale unreliable ignored")
  equal(receiver.unreliableReceiveSequence, 4, "stale does not rewind")
  return true
end function

// Verify sequence wrap against the expected Quake behavior.
function testSequenceWrap()
  sender = datagram.createChannel()
  sender.sendSequence = 0xffffffff
  packet = datagram.Datagram_SendMessage(sender, bytes("w"), 0.0)
  equal(datagram.decodePacket(packet).sequence, 0xffffffff, "maximum sequence on wire")
  equal(sender.sendSequence, 0, "reliable sequence wraps")
  unreliable = datagram.createChannel()
  unreliable.unreliableSendSequence = 0xffffffff
  upacket = datagram.Datagram_SendUnreliableMessage(unreliable, bytes("u"))
  equal(datagram.decodePacket(upacket).sequence, 0xffffffff, "maximum unreliable sequence")
  equal(unreliable.unreliableSendSequence, 0, "unreliable sequence wraps")
  return true
end function

// Verify receive overflow against the expected Quake behavior.
function testReceiveOverflow()
  receiver = datagram.createChannel()
  receiver.receiveMessage = bytes(datagram.NET_MAXMESSAGE)
  overflow = try(datagram.Datagram_GetMessage(receiver, datagram.encode(datagram.NETFLAG_DATA, 0, bytes([1])), 0.0))
  yes(overflow is error, "receive overflow is controlled error")
  equal(len(receiver.receiveMessage), 0, "overflow clears partial message")
  return true
end function

// Verify payload bounds against the expected Quake behavior.
function testPayloadBounds()
  empty = try(datagram.Datagram_SendMessage(datagram.createChannel(), bytes(), 0.0))
  yes(empty is error, "empty reliable rejected")
  large = try(datagram.Datagram_SendMessage(datagram.createChannel(), bytes(datagram.NET_MAXMESSAGE + 1), 0.0))
  yes(large is error, "oversize reliable rejected")
  uempty = try(datagram.Datagram_SendUnreliableMessage(datagram.createChannel(), bytes()))
  yes(uempty is error, "empty unreliable rejected")
  ularge = try(datagram.Datagram_SendUnreliableMessage(datagram.createChannel(), bytes(datagram.MAX_DATAGRAM + 1)))
  yes(ularge is error, "oversize unreliable rejected")
  return true
end function

// Verify can send query side effect free against the expected Quake behavior.
function testCanSendQuerySideEffectFree()
  channel = datagram.createChannel()
  channel.canSend = false
  channel.sendNext = true
  channel.sendMessage = bytes(100)
  before = datagram.packetsSent
  no(datagram.Datagram_CanSendMessage(channel), "busy channel cannot send")
  yes(channel.sendNext, "query retains pending fragment")
  equal(datagram.packetsSent, before, "query emits no packet")
  return true
end function

// Verify receive loop deferral against the expected Quake behavior.
function testReceiveLoopDeferral()
  sender = datagram.createChannel()
  datagram.Datagram_SendMessage(sender, bytes(1500), 0.0)
  datagram.Datagram_GetMessage(sender, datagram.acknowledgement(0), 0.1)
  yes(sender.sendNext, "ACK sets pending")
  unrelated = datagram.Datagram_GetMessage(sender, datagram.encode(datagram.NETFLAG_UNRELIABLE, 0, bytes("side")), 0.1)
  equal(unrelated[0], 2, "receive loop continues before flush")
  yes(sender.sendNext, "pending survives later packet")
  next = datagram.Datagram_FlushSendNext(sender, 0.1)
  equal(datagram.decodePacket(next).sequence, 1, "flush after receive loop")
  return true
end function

// Verify control ignored against the expected Quake behavior.
function testControlIgnored()
  channel = datagram.createChannel()
  packet = datagram.control(bytes([1, 2, 3, 4]))
  result = datagram.Datagram_GetMessage(channel, packet, 0.0)
  equal(result[0], 0, "control ignored on connected channel")
  equal(channel.receiveSequence, 0, "control does not alter sequence")
  return true
end function

// Verify statistics against the expected Quake behavior.
function testStatistics()
  datagram.resetStats()
  sender = datagram.createChannel()
  receiver = datagram.createChannel()
  packet = datagram.Datagram_SendUnreliableMessage(sender, bytes("x"))
  datagram.Datagram_GetMessage(receiver, packet, 0.0)
  equal(datagram.packetsSent, 1, "packets sent")
  equal(datagram.packetsReceived, 1, "packets received")
  datagram.resetStats()
  equal(datagram.packetsSent, 0, "sent reset")
  equal(datagram.packetsReceived, 0, "received reset")
  return true
end function

// Verify strict length decode against the expected Quake behavior.
function testStrictLengthDecode()
  valid = datagram.encode(datagram.NETFLAG_UNRELIABLE, 0, bytes([1]))
  malformed = bytes(len(valid) + 1)
  index = 0
  while index < len(valid)
    malformed[index] = valid[index]
    index = index + 1
  end while
  bad = try(datagram.decodePacket(malformed))
  yes(bad is error, "length mismatch rejected")
  return true
end function

// Exercise fault scenario as part of this deterministic regression fixture.
function faultScenario()
  sender = datagram.createChannel()
  receiver = datagram.createChannel()
  payload = patterned(2050)
  first = datagram.Datagram_SendMessage(sender, payload, 0.0)
  firstRx = datagram.Datagram_GetMessage(receiver, first, 0.0)
  resentFirst = datagram.pollRetransmit(sender, 1.01)
  duplicate = datagram.Datagram_GetMessage(receiver, resentFirst, 1.01)
  datagram.Datagram_GetMessage(sender, duplicate[2], 1.02)
  second = datagram.Datagram_FlushSendNext(sender, 1.02)
  resentSecond = datagram.pollRetransmit(sender, 2.03)
  secondRx = datagram.Datagram_GetMessage(receiver, resentSecond, 2.03)
  datagram.Datagram_GetMessage(sender, secondRx[2], 2.04)
  third = datagram.Datagram_FlushSendNext(sender, 2.04)
  finalRx = datagram.Datagram_GetMessage(receiver, third, 2.04)
  datagram.Datagram_GetMessage(sender, finalRx[2], 2.05)
  return hex(finalRx[1]) + ":" + sender.sendSequence + ":" + receiver.receiveSequence + ":" + sender.packetsReSent
end function

// Verify deterministic fault schedule against the expected Quake behavior.
function testDeterministicFaultSchedule()
  first = faultScenario()
  second = faultScenario()
  equal(first, second, "fault schedule deterministic")
  yes(len(first) > 4100, "fault scenario includes complete payload")
  return true
end function

passed = 0
if run(1, "big-endian header encoding", testHeaderEncoding) then passed = passed + 1 end if
if run(2, "fragment and EOM boundaries", testFragmentBoundaries) then passed = passed + 1 end if
if run(3, "ACK defers next fragment", testAckDefersNextFragment) then passed = passed + 1 end if
if run(4, "three-fragment reliable reassembly", testReliableReassembly) then passed = passed + 1 end if
if run(5, "lost ACK retransmission", testLostAckRetransmit) then passed = passed + 1 end if
if run(6, "lost data retransmission", testLostDataRetransmit) then passed = passed + 1 end if
if run(7, "duplicate reliable data", testDuplicateData) then passed = passed + 1 end if
if run(8, "stale and duplicate ACK", testStaleAndDuplicateAck) then passed = passed + 1 end if
if run(9, "optional NAK extension", testNakExtension) then passed = passed + 1 end if
if run(10, "unreliable gap and stale packet", testUnreliableGapAndStale) then passed = passed + 1 end if
if run(11, "32-bit sequence wrap", testSequenceWrap) then passed = passed + 1 end if
if run(12, "fragment receive overflow", testReceiveOverflow) then passed = passed + 1 end if
if run(13, "message size boundaries", testPayloadBounds) then passed = passed + 1 end if
if run(14, "side-effect-free can-send query", testCanSendQuerySideEffectFree) then passed = passed + 1 end if
if run(15, "receive-loop sendNext deferral", testReceiveLoopDeferral) then passed = passed + 1 end if
if run(16, "connected control packet ignored", testControlIgnored) then passed = passed + 1 end if
if run(17, "transport statistics", testStatistics) then passed = passed + 1 end if
if run(18, "deterministic loss schedule", testDeterministicFaultSchedule) then passed = passed + 1 end if

if passed != 18 then
  print "MiniQuake BP-017 Protocol 15 datagram tests failed: " + passed + "/18"
  error(9799, "BP-017 Protocol 15 datagram fixtures failed")
end if
print "MiniQuake BP-017 Protocol 15 datagram tests passed: 18"
