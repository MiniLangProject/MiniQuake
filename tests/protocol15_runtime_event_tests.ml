/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-014R1 byte-exact Protocol-15 temporary-entity, dynamic-sound, beam-pool,
keepalive and reusable-client-message fixtures. The wire vectors are reproduced
independently by tools/oracle/protocol15_runtime_events_oracle.c and
tools/check_protocol15_runtime_events.py.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native
import miniquake.protocol_transients as transients
import miniquake.protocol_serverdata as serverData
import miniquake.client_protocol as protocol
import miniquake.client_effects as clientEffects
import miniquake.temp_entities as temporary
import miniquake.server as server

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9701, name + ": expected true") end if
  return true
end function

// Exercise assert false as part of this deterministic regression fixture.
function assertFalse(value, name)
  if value != false then return error(9702, name + ": expected false") end if
  return true
end function

// Exercise assert hex as part of this deterministic regression fixture.
function assertHex(buffer, expected, name)
  return assertEqual(hex(sz.dataSlice(buffer)), expected, name)
end function

// Execute one named test case and record its pass/fail result.
function runTest(number, name, fn)
  print "  [" + number + "/28] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Exercise origin a as part of this deterministic regression fixture.
function originA()
  return t.Vec3(10.0, -20.0, 30.0)
end function

// Exercise origin b as part of this deterministic regression fixture.
function originB()
  return t.Vec3(-12.25, 0.125, 4095.875)
end function

// Return beam value derived from the active module state.
function beamValue(type, entityNumber)
  return t.TemporaryEntity(type, originA(), originB(), entityNumber)
end function

// Verify temp point vector against the expected Quake behavior.
function testTempPointVector()
  buffer = sz.alloc(64)
  assertEqual(transients.writePoint(buffer, c.TE_SPIKE, originA()), 8, "point length")
  assertHex(buffer, "1700500060fff000", "temp_point_spike")
  return true
end function

// Verify temp beam vector against the expected Quake behavior.
function testTempBeamVector()
  buffer = sz.alloc(64)
  assertEqual(transients.writeBeam(buffer, c.TE_LIGHTNING1, 300, originA(), originB()), 16, "beam length")
  assertHex(buffer, "17052c01500060fff0009eff0100ff7f", "temp_beam_lightning")
  return true
end function

// Verify temp explosion2 vector against the expected Quake behavior.
function testTempExplosion2Vector()
  buffer = sz.alloc(64)
  assertEqual(transients.writeExplosion2(buffer, originA(), 0x12, 0x34), 10, "explosion2 length")
  assertHex(buffer, "170c500060fff0001234", "temp_explosion2")
  return true
end function

// Verify stop sound vector against the expected Quake behavior.
function testStopSoundVector()
  buffer = sz.alloc(16)
  assertEqual(transients.writeStopSound(buffer, 300, 7), 3, "stop sound length")
  assertHex(buffer, "106709", "stop_sound")
  return true
end function

// Verify dynamic sound default vector against the expected Quake behavior.
function testDynamicSoundDefaultVector()
  buffer = sz.alloc(64)
  serverData.writeSound(buffer, 300, 2, 5, 255, 1.0, originA())
  assertHex(buffer, "0600620905500060fff000", "dynamic_sound_default")
  assertEqual(transients.dynamicSoundWireSize(255, 1.0), 11, "default dynamic sound size")
  return true
end function

// Verify dynamic sound optional vector against the expected Quake behavior.
function testDynamicSoundOptionalVector()
  buffer = sz.alloc(64)
  serverData.writeSound(buffer, 1, 7, 300, 128, 0.5, originB())
  assertHex(buffer, "060380200f002c9eff0100ff7f", "dynamic_sound_options")
  assertEqual(transients.dynamicSoundWireSize(128, 0.5), 13, "optional dynamic sound size")
  return true
end function

// Verify temp type matrix against the expected Quake behavior.
function testTempTypeMatrix()
  types = [
    c.TE_SPIKE, c.TE_SUPERSPIKE, c.TE_GUNSHOT, c.TE_EXPLOSION,
    c.TE_TAREXPLOSION, c.TE_LIGHTNING1, c.TE_LIGHTNING2, c.TE_WIZSPIKE,
    c.TE_KNIGHTSPIKE, c.TE_LIGHTNING3, c.TE_LAVASPLASH, c.TE_TELEPORT,
    c.TE_EXPLOSION2, c.TE_BEAM,
  ]
  index = 0
  while index < len(types)
    type = types[index]
    kind = transients.tempKind(type)
    expectedKind = transients.TEMP_KIND_POINT
    expectedSize = 8
    if transients.isBeamType(type) then
      expectedKind = transients.TEMP_KIND_BEAM
      expectedSize = 16
    else if type == c.TE_EXPLOSION2 then
      expectedKind = transients.TEMP_KIND_EXPLOSION2
      expectedSize = 10
    end if
    assertEqual(kind, expectedKind, "temp kind " + type)
    assertEqual(transients.tempWireSize(type), expectedSize, "temp size " + type)
    index = index + 1
  end while
  return true
end function

// Verify point parser round trip against the expected Quake behavior.
function testPointParserRoundTrip()
  buffer = sz.alloc(64)
  transients.writePoint(buffer, c.TE_TELEPORT, originB())
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "point event count")
  value = parsed.events[0].payload
  assertEqual(value.type, c.TE_TELEPORT, "point type")
  assertEqual(value.origin.x, -12.25, "point origin x")
  assertEqual(value.origin.y, 0.125, "point origin y")
  assertEqual(value.origin.z, 4095.875, "point origin z")
  return true
end function

// Verify beam parser round trip against the expected Quake behavior.
function testBeamParserRoundTrip()
  buffer = sz.alloc(64)
  transients.writeBeam(buffer, c.TE_BEAM, 300, originA(), originB())
  parsed = protocol.parse(sz.dataSlice(buffer))
  value = parsed.events[0].payload
  assertEqual(value.type, c.TE_BEAM, "beam type")
  assertEqual(value.entity, 300, "beam entity")
  assertEqual(value.origin.x, 10.0, "beam start")
  assertEqual(value.endPosition.z, 4095.875, "beam end")
  return true
end function

// Verify explosion2 parser round trip against the expected Quake behavior.
function testExplosion2ParserRoundTrip()
  buffer = sz.alloc(64)
  transients.writeExplosion2(buffer, originA(), 0x12, 0x34)
  parsed = protocol.parse(sz.dataSlice(buffer))
  value = parsed.events[0].payload
  assertEqual(value.type, c.TE_EXPLOSION2, "explosion2 type")
  assertEqual(value.entity, 0x1234, "explosion2 color packing")
  return true
end function

// Verify invalid and truncated temp entity against the expected Quake behavior.
function testInvalidAndTruncatedTempEntity()
  invalid = try(transients.tempKind(14))
  assertTrue(invalid is error, "invalid type rejected")
  badType = try(protocol.parse(fromHex("170e")))
  assertTrue(badType is error, "unknown temp type rejected")
  truncatedPoint = try(protocol.parse(fromHex("17005000")))
  assertTrue(truncatedPoint is error, "truncated point rejected")
  truncatedBeam = try(protocol.parse(fromHex("17052c015000")))
  assertTrue(truncatedBeam is error, "truncated beam rejected")
  return true
end function

// Verify dynamic sound default parser against the expected Quake behavior.
function testDynamicSoundDefaultParser()
  buffer = sz.alloc(64)
  serverData.writeSound(buffer, 3, 2, 5, 255, 1.0, originA())
  parsed = protocol.parse(sz.dataSlice(buffer))
  payload = parsed.events[0].payload
  assertEqual(payload[0], 0, "default sound mask")
  assertEqual(payload[1], 255, "default sound volume byte")
  assertEqual(native.floatBits(payload[2]), 0x3f800000, "default attenuation bits")
  assertEqual(transients.soundEntity(payload[3]), 3, "default sound entity")
  assertEqual(transients.soundChannel(payload[3]), 2, "default sound channel")
  return true
end function

// Verify dynamic sound optional parser against the expected Quake behavior.
function testDynamicSoundOptionalParser()
  buffer = sz.alloc(64)
  serverData.writeSound(buffer, 1, 7, 9, 128, 0.5, originB())
  parsed = protocol.parse(sz.dataSlice(buffer))
  payload = parsed.events[0].payload
  assertEqual(payload[0], c.SND_VOLUME | c.SND_ATTENUATION, "optional sound mask")
  assertEqual(payload[1], 128, "optional volume byte")
  assertEqual(native.floatBits(payload[2]), 0x3f000000, "optional attenuation bits")
  assertEqual(native.floatBits(transients.clientSoundVolume(payload[1])), 0x3f008081, "mixer volume bits")
  return true
end function

// Verify dynamic sound entity boundary against the expected Quake behavior.
function testDynamicSoundEntityBoundary()
  accepted = sz.alloc(64)
  serverData.writeSound(accepted, c.MAX_EDICTS, 0, 1, 255, 1.0, originA())
  parsed = try(protocol.parse(sz.dataSlice(accepted)))
  assertFalse(parsed is error, "MAX_EDICTS accepted")

  rejected = sz.alloc(64)
  serverData.writeSound(rejected, c.MAX_EDICTS + 1, 0, 1, 255, 1.0, originA())
  failed = try(protocol.parse(sz.dataSlice(rejected)))
  assertTrue(failed is error, "MAX_EDICTS+1 rejected")
  return true
end function

// Verify stop sound parser against the expected Quake behavior.
function testStopSoundParser()
  buffer = sz.alloc(16)
  transients.writeStopSound(buffer, 300, 7)
  parsed = protocol.parse(sz.dataSlice(buffer))
  packed = parsed.events[0].payload
  assertEqual(transients.soundEntity(packed), 300, "stop sound entity")
  assertEqual(transients.soundChannel(packed), 7, "stop sound channel")
  assertEqual(transients.packSoundChannel(300, 15), packed, "channel masks to three bits")
  return true
end function

// Verify compact beam same entity slot against the expected Quake behavior.
function testCompactBeamSameEntitySlot()
  first = beamValue(c.TE_LIGHTNING1, 42)
  initial = transients.updateCompactBeamListResult([], first, 0.0)
  assertTrue(initial[1], "first beam accepted")
  assertEqual(initial[2], 0, "first beam slot")

  other = beamValue(c.TE_LIGHTNING2, 7)
  second = transients.updateCompactBeamListResult(initial[0], other, 1.0)
  assertEqual(second[2], 0, "expired first beam slot reused")
  assertEqual(second[0][0][0].entity, 7, "reused slot stores new entity")

  replacement = beamValue(c.TE_LIGHTNING3, 42)
  replaced = transients.updateCompactBeamListResult(second[0], replacement, 2.0)
  assertEqual(replaced[2], 0, "expired same entity retains original slot")
  assertEqual(replaced[0][0][0].type, c.TE_LIGHTNING3, "same slot payload replaced")
  return true
end function

// Verify compact beam pool limit against the expected Quake behavior.
function testCompactBeamPoolLimit()
  beams = []
  index = 0
  while index < transients.MAX_BEAMS
    result = transients.updateCompactBeamListResult(beams, beamValue(c.TE_BEAM, index + 1), 0.0)
    assertTrue(result[1], "beam accepted " + index)
    assertEqual(result[2], index, "beam slot " + index)
    beams = result[0]
    index = index + 1
  end while
  overflow = transients.updateCompactBeamListResult(beams, beamValue(c.TE_BEAM, 999), 0.0)
  assertFalse(overflow[1], "twenty-fifth beam rejected")
  assertEqual(len(overflow[0]), transients.MAX_BEAMS, "beam pool remains fixed")
  return true
end function

// Verify compact beam free slot order against the expected Quake behavior.
function testCompactBeamFreeSlotOrder()
  zero = [beamValue(c.TE_BEAM, 10), 2.0, 0]
  two = [beamValue(c.TE_BEAM, 12), 2.0, 2]
  missing = transients.updateCompactBeamListResult([two, zero], beamValue(c.TE_BEAM, 11), 1.0)
  assertEqual(missing[2], 1, "lowest missing slot selected")
  assertEqual(missing[0][0][2], 0, "normalized slot zero")
  assertEqual(missing[0][1][2], 1, "normalized slot one")
  assertEqual(missing[0][2][2], 2, "normalized slot two")
  assertTrue(transients.beamAlive(1.0, 1.0), "endtime equality remains alive")
  assertFalse(transients.beamAlive(1.0, 1.0001), "strictly expired beam is free")
  return true
end function

// Verify full beam pool diagnostic against the expected Quake behavior.
function testFullBeamPoolDiagnostic()
  state = temporary.CL_InitTEnts(void)
  index = 0
  while index < temporary.MAX_BEAMS + 1
    buffer = sz.alloc(64)
    transients.writeBeam(buffer, c.TE_LIGHTNING1, index + 1, originA(), originB())
    wire = sz.dataSlice(buffer)
    reader = msg.beginReadingBytes(slice(wire, 2, len(wire) - 2))
    temporary.CL_ParseBeam(state, reader, "progs/bolt.mdl", 0.0)
    index = index + 1
  end while
  assertEqual(len(state.diagnostics), 1, "beam overflow diagnostic count")
  assertEqual(state.diagnostics[0], "beam list overflow!", "beam overflow diagnostic")
  return true
end function

// Verify timing binary32 against the expected Quake behavior.
function testTimingBinary32()
  assertEqual(native.floatBits(transients.beamEndTime(1.0)), 0x3f99999a, "beam endtime bits")
  assertEqual(native.floatBits(transients.dynamicLightDieTime(1.0)), 0x3fc00000, "dlight die bits")
  return true
end function

// Verify quake csound conversions against the expected Quake behavior.
function testQuakeCSoundConversions()
  assertEqual(transients.quakeCSoundChannel(2.9), 2, "QuakeC channel truncation")
  assertEqual(transients.quakeCSoundVolumeByte(0.5), 127, "QuakeC volume binary32 product")
  assertEqual(native.floatBits(transients.quakeCSoundAttenuation(1.00000001)), 0x3f800000, "QuakeC attenuation boundary")
  assertEqual(transients.soundAttenuationByte(0.5), 32, "sound attenuation byte")
  return true
end function

// Verify sound center binary32 against the expected Quake behavior.
function testSoundCenterBinary32()
  center = transients.soundCenter(
    t.Vec3(-12.25, 20.0, 30.0),
    t.Vec3(-1.5, -16.0, -24.0),
    t.Vec3(2.25, 16.0, 32.0),
  )
  assertEqual(native.floatBits(center.x), 0xc13e0000, "sound center x bits")
  assertEqual(center.y, 20.0, "sound center y")
  assertEqual(center.z, 34.0, "sound center z")
  return true
end function

// Verify dynamic sound datagram boundary against the expected Quake behavior.
function testDynamicSoundDatagramBoundary()
  buffer = sz.alloc(c.MAX_DATAGRAM)
  buffer.curSize = c.MAX_DATAGRAM - 16
  assertTrue(transients.canWriteDynamicSound(buffer), "exact dynamic sound margin accepted")
  buffer.curSize = c.MAX_DATAGRAM - 15
  assertFalse(transients.canWriteDynamicSound(buffer), "above dynamic sound margin rejected")
  return true
end function

// Verify reusable client message reset against the expected Quake behavior.
function testReusableClientMessageReset()
  value = server.create(1)
  clientValue = value.clients[0]
  clientValue.message.curSize = 99
  clientValue.message.allowOverflow = false
  clientValue.message.overflowed = true
  server.resetClientMessageForConnect(clientValue)
  assertEqual(clientValue.message.curSize, 0, "reused message cleared")
  assertTrue(clientValue.message.allowOverflow, "reused message allows overflow")
  assertFalse(clientValue.message.overflowed, "sticky overflow reset")
  return true
end function

// Verify reliable overflow and drop priority against the expected Quake behavior.
function testReliableOverflowAndDropPriority()
  assertEqual(
    serverData.reliableDeliveryPlan(true, 1, true, true),
    serverData.RELIABLE_DROP_OVERFLOW,
    "overflow precedes dropasap",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 0, true, false),
    serverData.RELIABLE_WAIT,
    "dropasap waits while blocked",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 0, true, true),
    serverData.RELIABLE_DROP_ASAP,
    "dropasap fires when sendable",
  )
  return true
end function

// Verify keepalive and reconnect boundaries against the expected Quake behavior.
function testKeepaliveAndReconnectBoundaries()
  assertEqual(
    serverData.initialDeliveryPlan(false, false, 5.0),
    serverData.PLAN_WAIT_SIGNON,
    "keepalive equality waits",
  )
  assertEqual(
    serverData.initialDeliveryPlan(false, false, 5.0001),
    serverData.PLAN_SEND_NOP,
    "keepalive strictly above five sends nop",
  )
  buffer = sz.alloc(32)
  assertEqual(transients.writeReconnect(buffer), 12, "reconnect length")
  assertHex(buffer, "097265636f6e6e6563740a00", "reconnect payload")
  return true
end function

// Verify static sound client scalars against the expected Quake behavior.
function testStaticSoundClientScalars()
  normalizedVolume = transients.staticSoundVolume(127)
  assertEqual(native.floatBits(normalizedVolume), 0x3efefeff, "static volume mixer normalization")
  assertEqual(native.trunc(normalizedVolume * 255.0), 127, "static volume effective master byte")
  assertEqual(native.floatBits(transients.staticSoundAttenuation(80)), 0x42a00000, "static attenuation raw float")
  rounded = transients.cFloat(1.00000001)
  assertEqual(transients.soundFieldMask(255, rounded), 0, "rounded default optional bits")
  return true
end function

// Verify compact beam state and active view against the expected Quake behavior.
function testCompactBeamStateAndActiveView()
  firstValue = beamValue(c.TE_LIGHTNING1, 42)
  first = clientEffects.processTemporary(firstValue, void, [], [], 1.0)
  retained = first[1]
  assertEqual(len(retained), 1, "retained beam state")

  expiry = retained[0][1]
  assertEqual(len(clientEffects.pruneTemporary(retained, expiry)), 1, "beam alive at exact expiry")
  assertEqual(len(clientEffects.pruneTemporary(retained, expiry + 0.001)), 0, "expired beam absent from active view")
  assertEqual(len(clientEffects.retainTemporarySlots(retained)), 1, "expired beam slot retained")

  replacementValue = beamValue(c.TE_LIGHTNING3, 42)
  replaced = clientEffects.processTemporary(replacementValue, void, [], retained, 2.0)
  assertEqual(len(replaced[1]), 1, "same-entity replacement retains one slot")
  assertEqual(replaced[1][0][2], 0, "same-entity replacement reuses retained slot")
  assertEqual(replaced[1][0][0].type, c.TE_LIGHTNING3, "same-entity replacement updates payload")
  return true
end function

passed = 0
if runTest("01", "temporary point writer", testTempPointVector) then passed = passed + 1 end if
if runTest("02", "temporary beam writer", testTempBeamVector) then passed = passed + 1 end if
if runTest("03", "temporary explosion2 writer", testTempExplosion2Vector) then passed = passed + 1 end if
if runTest("04", "svc_stopsound writer", testStopSoundVector) then passed = passed + 1 end if
if runTest("05", "dynamic sound default vector", testDynamicSoundDefaultVector) then passed = passed + 1 end if
if runTest("06", "dynamic sound optional vector", testDynamicSoundOptionalVector) then passed = passed + 1 end if
if runTest("07", "temporary type and size matrix", testTempTypeMatrix) then passed = passed + 1 end if
if runTest("08", "temporary point parser roundtrip", testPointParserRoundTrip) then passed = passed + 1 end if
if runTest("09", "temporary beam parser roundtrip", testBeamParserRoundTrip) then passed = passed + 1 end if
if runTest("10", "temporary explosion2 parser roundtrip", testExplosion2ParserRoundTrip) then passed = passed + 1 end if
if runTest("11", "invalid and truncated temporary entities", testInvalidAndTruncatedTempEntity) then passed = passed + 1 end if
if runTest("12", "dynamic sound default parser", testDynamicSoundDefaultParser) then passed = passed + 1 end if
if runTest("13", "dynamic sound optional parser", testDynamicSoundOptionalParser) then passed = passed + 1 end if
if runTest("14", "dynamic sound entity boundary", testDynamicSoundEntityBoundary) then passed = passed + 1 end if
if runTest("15", "svc_stopsound parser and unpack", testStopSoundParser) then passed = passed + 1 end if
if runTest("16", "compact beam same-entity slot", testCompactBeamSameEntitySlot) then passed = passed + 1 end if
if runTest("17", "compact beam fixed pool", testCompactBeamPoolLimit) then passed = passed + 1 end if
if runTest("18", "compact beam free-slot ordering", testCompactBeamFreeSlotOrder) then passed = passed + 1 end if
if runTest("19", "full CL_ParseBeam overflow diagnostic", testFullBeamPoolDiagnostic) then passed = passed + 1 end if
if runTest("20", "beam and dlight binary32 timing", testTimingBinary32) then passed = passed + 1 end if
if runTest("21", "QuakeC sound scalar conversion", testQuakeCSoundConversions) then passed = passed + 1 end if
if runTest("22", "dynamic sound center binary32", testSoundCenterBinary32) then passed = passed + 1 end if
if runTest("23", "dynamic sound datagram boundary", testDynamicSoundDatagramBoundary) then passed = passed + 1 end if
if runTest("24", "reused client message reset", testReusableClientMessageReset) then passed = passed + 1 end if
if runTest("25", "reliable overflow and drop priority", testReliableOverflowAndDropPriority) then passed = passed + 1 end if
if runTest("26", "keepalive and reconnect boundaries", testKeepaliveAndReconnectBoundaries) then passed = passed + 1 end if
if runTest("27", "static sound client scalar ABI", testStaticSoundClientScalars) then passed = passed + 1 end if
if runTest("28", "beam retained-state and active-view separation", testCompactBeamStateAndActiveView) then passed = passed + 1 end if

if passed != 28 then
  print "MiniQuake BP-014R1 Protocol 15 runtime-event tests failed: " + passed + "/28"
  error(9799, "BP-014R1 Protocol 15 runtime-event fixtures failed")
end if
print "MiniQuake BP-014R1 Protocol 15 runtime-event tests passed: 28"
