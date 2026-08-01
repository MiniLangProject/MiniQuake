/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-019 closure fixtures stitch the source-guided Protocol-15 layers together:
wire primitives, command catalogs, signon, reliable scheduling, datagram
fragmentation, demo framing and client parsing.  Component suites remain the
fine-grained oracle; this file is the final cross-layer freeze gate.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol15_freeze as freeze
import miniquake.protocol_signon as signon
import miniquake.protocol_delivery as delivery
import miniquake.protocol_update as update
import miniquake.client_protocol as protocol
import miniquake.net_datagram as datagram
import miniquake.demo as demo

function equal(actual, expected, name)
  if actual != expected then return error(9900, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function yes(value, name)
  if value != true then return error(9901, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value != false then return error(9902, name + ": expected false") end if
  return true
end function

function run(number, name, fn)
  print "  [" + number + "/15] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

function baseline()
  return t.EntityBaseline(
    1, 0, 0, 0, 0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
  )
end function

function testFreezeIdentity()
  equal(freeze.STATUS, "protocol15_frozen_v1", "freeze status")
  equal(freeze.PROTOCOL_VERSION, c.PROTOCOL_VERSION, "protocol version")
  equal(freeze.protocolFingerprint(), freeze.FINGERPRINT, "protocol fingerprint")
  equal(freeze.FINGERPRINT, 217178410, "golden fingerprint")
  return true
end function

function testSvcCatalog()
  values = freeze.validSvcCommands()
  equal(len(values), 33, "SVC count")
  equal(values[0], c.SVC_NOP, "first valid SVC")
  equal(values[19], c.SVC_SPAWNSTATIC, "pre-gap SVC")
  equal(values[20], c.SVC_SPAWNBASELINE, "post-gap SVC")
  equal(values[32], c.SVC_CUTSCENE, "last valid SVC")
  index = 0
  while index < len(values)
    yes(freeze.isValidSvc(values[index]), "valid SVC " + index)
    index = index + 1
  end while
  no(freeze.isValidSvc(c.SVC_BAD), "svc_bad invalid")
  no(freeze.isValidSvc(c.SVC_SPAWNBINARY), "svc_spawnbinary invalid")
  yes(freeze.isReservedSvc(c.SVC_BAD), "svc_bad reserved")
  yes(freeze.isReservedSvc(c.SVC_SPAWNBINARY), "svc_spawnbinary reserved")
  return true
end function

function testClcCatalog()
  values = freeze.validClcCommands()
  equal(len(values), 4, "CLC count")
  index = 0
  while index < len(values)
    equal(values[index], index + 1, "CLC ordering " + index)
    yes(freeze.isValidClc(values[index]), "valid CLC " + index)
    index = index + 1
  end while
  no(freeze.isValidClc(c.CLC_BAD), "clc_bad invalid")
  no(freeze.isValidClc(5), "unknown CLC invalid")
  return true
end function

function testBitMasks()
  equal(freeze.combineMask(freeze.fastUpdateBits()), 0x7fff, "fast update mask")
  equal(freeze.combineMask(freeze.clientDataBits()), 0x7eff, "client data mask")
  equal(freeze.combineMask(freeze.soundBits()), 0x0007, "sound mask")
  equal(freeze.FAST_UPDATE_MASK, 0x7fff, "frozen fast update mask")
  equal(freeze.CLIENT_DATA_MASK, 0x7eff, "frozen client data mask")
  equal(freeze.SOUND_MASK, 7, "frozen sound mask")
  return true
end function

function testTemporaryEntityCatalog()
  values = freeze.temporaryEntityTypes()
  equal(len(values), 14, "temporary entity count")
  index = 0
  while index < len(values)
    equal(values[index], index, "temporary entity ordering " + index)
    index = index + 1
  end while
  equal(values[13], c.TE_BEAM, "last temporary entity")
  return true
end function

function testReservedServerCommands()
  yes(try(protocol.parse(bytes([c.SVC_BAD]))) is error, "svc_bad rejected")
  yes(try(protocol.parse(bytes([c.SVC_SPAWNBINARY]))) is error, "spawnbinary rejected")
  yes(try(protocol.parse(bytes([35]))) is error, "unknown SVC rejected")
  return true
end function

function testSignonWireSequence()
  buffer = sz.alloc(1024)
  first = signon.writeClientReply(buffer, c.SIGNON_SERVERINFO, "player", 0x4f, "")
  second = signon.writeClientReply(buffer, c.SIGNON_PRESPAWN, "player", 0x4f, "spawn-parms")
  third = signon.writeClientReply(buffer, c.SIGNON_SPAWN, "player", 0x4f, "")
  fourth = signon.writeClientReply(buffer, c.SIGNON_ACTIVE, "player", 0x4f, "")
  yes(first > 0, "stage one queued")
  yes(second > first, "stage two compound reply")
  yes(third > 0, "stage three queued")
  equal(fourth, 0, "stage four local only")
  data = sz.dataSlice(buffer)
  equal(data[0], c.CLC_STRINGCMD, "first signon command")
  parsed = msg.beginReadingBytes(data)
  commands = 0
  while msg.remaining(parsed) > 0
    equal(msg.readChar(parsed), c.CLC_STRINGCMD, "signon CLC opcode")
    text = msg.readString(parsed)
    yes(len(bytes(text)) > 0, "signon command text")
    commands = commands + 1
  end while
  equal(commands, 5, "queued signon command count")
  return true
end function

function testDeliveryBoundaries()
  equal(delivery.clientReliablePlan(true, 1, false), delivery.SEND_RETAIN, "blocked client retains")
  equal(delivery.clientReliablePlan(true, 1, true), delivery.SEND_COMMIT, "sendable client commits")
  equal(delivery.reliableSendOutcome(-1), delivery.SEND_DROP, "negative send drops")
  equal(delivery.reliableSendOutcome(0), delivery.SEND_RETAIN, "zero send retains")
  equal(delivery.reliableSendOutcome(1), delivery.SEND_COMMIT, "positive send commits")
  no(delivery.keepaliveDue(5.0), "exact five seconds")
  yes(delivery.keepaliveDue(5.0001), "above five seconds")
  return true
end function

function testFastUpdateSignal()
  buffer = sz.alloc(64)
  item = baseline()
  bits = update.writeFastUpdate(
    buffer, 1, item, 1, 0, 0, 0, 0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    c.MOVETYPE_NONE,
  )
  equal(bits, 0, "unchanged update bits")
  equal(hex(sz.dataSlice(buffer)), "8001", "signal-only update")
  parsed = protocol.parse(sz.dataSlice(buffer))
  equal(parsed.events[0].command, "fast_update", "fast update parser")
  equal(parsed.events[0].payload[0], 1, "fast update entity")
  return true
end function

function buildClosureMessage()
  buffer = sz.alloc(2048)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, 12.5)
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, decode(bytes(1050, 65)))
  item = baseline()
  update.writeFastUpdate(
    buffer, 1, item, 1, 0, 0, 0, 0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    c.MOVETYPE_NONE,
  )
  return sz.dataSlice(buffer)
end function

function transferReliable(payload)
  sender = datagram.createChannel()
  receiver = datagram.createChannel()
  packet = datagram.Datagram_SendMessage(sender, payload, 1.0)
  complete = void
  fragments = 0
  while packet is bytes
    fragments = fragments + 1
    received = datagram.Datagram_GetMessage(receiver, packet, 1.0 + fragments * 0.1)
    if received is error then return received end if
    if received[0] == 1 then complete = received[1] end if
    if received[2] is bytes then
      acked = datagram.Datagram_GetMessage(sender, received[2], 1.0 + fragments * 0.1 + 0.01)
      if acked is error then return acked end if
    end if
    packet = datagram.Datagram_FlushSendNext(sender, 1.0 + fragments * 0.1 + 0.01)
  end while
  return [complete, fragments, sender.canSend]
end function

function testDatagramDemoParserClosure()
  original = buildClosureMessage()
  yes(len(original) > datagram.MAX_DATAGRAM, "closure message fragments")
  transferred = transferReliable(original)
  if transferred is error then return transferred end if
  yes(transferred[0] is bytes, "reliable message completed")
  equal(transferred[1], 2, "reliable fragment count")
  yes(transferred[2], "sender released after final ACK")
  equal(hex(transferred[0]), hex(original), "datagram payload identity")

  recording = t.Demo(-1, [], "-1\n")
  demo.CL_WriteDemoMessage(recording, transferred[0], t.Vec3(1.0, 2.0, 3.0))
  replay = demo.parse(demo.serialize(recording))
  equal(len(replay.messages), 1, "demo message count")
  parsed = protocol.parse(replay.messages[0].payload)
  equal(len(parsed.events), 3, "cross-layer event count")
  equal(parsed.events[0].command, "svc_time", "cross-layer time")
  equal(parsed.events[1].command, "svc_print", "cross-layer print")
  equal(len(bytes(parsed.events[1].payload)), 1050, "cross-layer long string")
  equal(parsed.events[2].command, "fast_update", "cross-layer update")
  return true
end function

function testDemoKeepaliveAndDisconnect()
  yes(demo.isKeepalivePayload(bytes([c.SVC_NOP])), "isolated keepalive")
  no(demo.isKeepalivePayload(bytes([c.SVC_NOP, c.SVC_NOP])), "compound payload retained")
  recording = t.Demo(-1, [], "-1\n")
  stopped = demo.CL_Stop_f(recording, t.Vec3(0.0, 0.0, 0.0))
  yes(stopped is not error, "demo stop succeeds")
  equal(hex(recording.messages[0].payload), "02", "demo stop disconnect")
  return true
end function

function testSequenceWrap()
  channel = datagram.createChannel()
  channel.sendSequence = 0xffffffff
  packet = datagram.reliable(channel, bytes([1]), true)
  equal(datagram.decodePacket(packet).sequence, 0xffffffff, "wire wrap sequence")
  equal(channel.sendSequence, 0, "next sequence wraps")
  equal(datagram.previousSequence(0), 0xffffffff, "previous sequence wraps")
  return true
end function

function closureScenarioHex()
  payload = buildClosureMessage()
  transferred = transferReliable(payload)
  if transferred is error then return transferred end if
  recording = t.Demo(7, [], "7\n")
  demo.CL_WriteDemoMessage(recording, transferred[0], t.Vec3(4.0, 5.0, 6.0))
  return hex(demo.serialize(recording))
end function

function testDeterministicClosureScenario()
  first = closureScenarioHex()
  if first is error then return first end if
  second = closureScenarioHex()
  if second is error then return second end if
  equal(first, second, "independent closure scenario")
  return true
end function

function testCoverageSummary()
  summary = freeze.coverageSummary()
  equal(len(summary), 8, "summary fields")
  equal(summary[0], 15, "summary protocol")
  equal(summary[1], 33, "summary SVC")
  equal(summary[2], 4, "summary CLC")
  equal(summary[3], 0x7fff, "summary U mask")
  equal(summary[4], 0x7eff, "summary SU mask")
  equal(summary[5], 7, "summary sound mask")
  equal(summary[6], 14, "summary TE")
  equal(summary[7], freeze.FINGERPRINT, "summary fingerprint")
  return true
end function

function testProtocolLimits()
  equal(c.MAX_MSGLEN, 8000, "MAX_MSGLEN")
  equal(c.MAX_DATAGRAM, 1024, "MAX_DATAGRAM")
  equal(c.MAX_EDICTS, 600, "MAX_EDICTS")
  equal(datagram.NET_MAXMESSAGE, 8192, "NET_MAXMESSAGE")
  return true
end function

function testFingerprintMutationSensitivity()
  original = freeze.protocolFingerprint()
  changed = freeze.fingerprintValue(original, c.SVC_CUTSCENE + 1)
  if changed == original then return error(9903, "fingerprint ignored mutation") end if
  equal(freeze.protocolFingerprint(), original, "fingerprint remains stable")
  return true
end function

function testLimitsAndFingerprint()
  testProtocolLimits()
  testFingerprintMutationSensitivity()
  return true
end function

passed = 0
if run(1, "freeze identity and fingerprint", testFreezeIdentity) then passed = passed + 1 end if
if run(2, "complete SVC catalog", testSvcCatalog) then passed = passed + 1 end if
if run(3, "complete CLC catalog", testClcCatalog) then passed = passed + 1 end if
if run(4, "Protocol 15 bit masks", testBitMasks) then passed = passed + 1 end if
if run(5, "temporary-entity catalog", testTemporaryEntityCatalog) then passed = passed + 1 end if
if run(6, "reserved server commands", testReservedServerCommands) then passed = passed + 1 end if
if run(7, "signon command sequence", testSignonWireSequence) then passed = passed + 1 end if
if run(8, "reliable delivery boundaries", testDeliveryBoundaries) then passed = passed + 1 end if
if run(9, "fast-update signal", testFastUpdateSignal) then passed = passed + 1 end if
if run(10, "datagram-demo-parser closure", testDatagramDemoParserClosure) then passed = passed + 1 end if
if run(11, "demo keepalive and disconnect", testDemoKeepaliveAndDisconnect) then passed = passed + 1 end if
if run(12, "datagram sequence wrap", testSequenceWrap) then passed = passed + 1 end if
if run(13, "deterministic closure scenario", testDeterministicClosureScenario) then passed = passed + 1 end if
if run(14, "coverage summary", testCoverageSummary) then passed = passed + 1 end if
if run(15, "limits and fingerprint sensitivity", testLimitsAndFingerprint) then passed = passed + 1 end if

if passed != 15 then
  print "MiniQuake BP-019 Protocol 15 closure tests failed: " + passed + "/15"
  error(9999, "BP-019 Protocol 15 closure fixtures failed")
end if
print "MiniQuake BP-019 Protocol 15 closure tests passed: 15"
