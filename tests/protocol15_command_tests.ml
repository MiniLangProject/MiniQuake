/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-011 Protocol-15 signon, client/server command-stream and fast entity-update
fixtures. Golden bytes are generated independently by the C oracle in
tools/oracle/protocol15_commands_oracle.c and the Python model in
tools/check_protocol15_commands.py.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_write as writer
import miniquake.protocol_signon as signon
import miniquake.protocol_update as update
import miniquake.client_protocol as protocol
import miniquake.client as client
import miniquake.server as server
import miniquake.sv_main as svmain
import miniquake.edict as edict
import miniquake.player_move as movement

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9400, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9401, name + ": expected true") end if
  return true
end function

// Exercise assert false as part of this deterministic regression fixture.
function assertFalse(value, name)
  if value != false then return error(9402, name + ": expected false") end if
  return true
end function

// Exercise assert hex as part of this deterministic regression fixture.
function assertHex(data, expected, name)
  return assertEqual(hex(data), expected, name)
end function

// Execute one named test case and record its pass/fail result.
function runTest(number, name, fn)
  print "  [" + number + "/14] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Return baseline state derived from the active module state.
function baselineState()
  return t.EntityBaseline(
    1,
    2,
    3,
    4,
    5,
    t.Vec3(10.0, 20.0, 30.0),
    t.Vec3(0.0, 45.0, 90.0),
  )
end function

// Return full origin derived from the active module state.
function fullOrigin()
  return t.Vec3(11.25, 18.75, 31.5)
end function

// Return full angles derived from the active module state.
function fullAngles()
  return t.Vec3(12.0, 90.0, -45.0)
end function

// Verify client signon replies against the expected Quake behavior.
function testClientSignonReplies()
  first = sz.alloc(128)
  assertEqual(signon.writeClientReply(first, c.SIGNON_SERVERINFO, "Ranger", 0x4d, "1 2 3"), 10, "stage one bytes")
  assertHex(sz.dataSlice(first), "04707265737061776e00", "signon_reply_1")

  second = sz.alloc(128)
  assertEqual(signon.writeClientReply(second, c.SIGNON_PRESPAWN, "Ranger", 0x4d, "1 2 3"), 42, "stage two bytes")
  assertHex(sz.dataSlice(second), "046e616d65202252616e676572220a0004636f6c6f7220342031330a0004737061776e20312032203300", "signon_reply_2")

  third = sz.alloc(128)
  assertEqual(signon.writeClientReply(third, c.SIGNON_SPAWN, "Ranger", 0x4d, "1 2 3"), 7, "stage three bytes")
  assertHex(sz.dataSlice(third), "04626567696e00", "signon_reply_3")

  fourth = sz.alloc(128)
  assertEqual(signon.writeClientReply(fourth, c.SIGNON_ACTIVE, "Ranger", 0x4d, "1 2 3"), 0, "stage four writes nothing")
  assertHex(sz.dataSlice(fourth), "", "signon_reply_4")
  return true
end function

// Verify server signon stages against the expected Quake behavior.
function testServerSignonStages()
  markers = sz.alloc(16)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_SERVERINFO)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_PRESPAWN)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_SPAWN)
  assertHex(sz.dataSlice(markers), "190119021903", "server_signon_markers_1_2_3")

  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  before = serverClient.message.curSize
  assertTrue(server.writeBegin(serverClient), "Host_Begin_f")
  assertTrue(serverClient.spawned, "server client spawned")
  assertEqual(serverClient.message.curSize, before, "Host_Begin_f has no wire output")
  return true
end function

// Verify clc compound stream against the expected Quake behavior.
function testClcCompoundStream()
  command = t.UserCommand(
    t.Vec3(12.75, 180.0, -90.9),
    200.75,
    -123.9,
    32768.9,
    3,
    7,
    0,
  )
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.CLC_NOP)
  writer.writeMove(buffer, command, 12.5)
  writer.writeStringCommand(buffer, "name \"Ranger\"\n")
  expected = "0103000048410880c0c80085ff00800307046e616d65202252616e676572220a00"
  assertHex(sz.dataSlice(buffer), expected, "clc_compound_stream")

  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  serverClient.active = true
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertTrue(server.readClientMessage(gameServer, serverClient, sz.dataSlice(buffer), player), "compound CLC parse")
  assertEqual(serverClient.name, "Ranger", "name command applied")
  assertEqual(serverClient.command.forwardMove, 200, "forward move")
  assertEqual(serverClient.command.sideMove, -123, "side move")
  assertEqual(serverClient.command.upMove, -32768, "wrapped up move")
  assertEqual(serverClient.command.buttons, 3, "buttons")
  assertEqual(serverClient.command.impulse, 7, "impulse")
  return true
end function

// Verify clc disconnect against the expected Quake behavior.
function testClcDisconnect()
  assertHex(bytes([c.CLC_DISCONNECT]), "02", "clc_disconnect")
  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  serverClient.active = true
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertFalse(server.readClientMessage(gameServer, serverClient, bytes([c.CLC_DISCONNECT]), player), "disconnect returns false")
  assertFalse(serverClient.active, "disconnect drops client")
  return true
end function

// Verify signed client end of message against the expected Quake behavior.
function testSignedClientEndOfMessage()
  assertHex(bytes([0xff]), "ff", "clc_signed_eom")
  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  serverClient.active = true
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertTrue(server.readClientMessage(gameServer, serverClient, bytes([0xff]), player), "0xff is signed end-of-message")
  assertTrue(serverClient.active, "signed EOM keeps client active")
  return true
end function

// Verify malformed client commands against the expected Quake behavior.
function testMalformedClientCommands()
  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  serverClient.active = true
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertFalse(server.readClientMessage(gameServer, serverClient, bytes([5]), player), "unknown CLC rejected")
  assertTrue(len(gameServer.diagnostics) > 0, "unknown CLC diagnostic")

  gameServer = server.create(1)
  serverClient = gameServer.clients[0]
  serverClient.active = true
  assertFalse(server.readClientMessage(gameServer, serverClient, bytes([c.CLC_MOVE, 0, 0]), player), "truncated move rejected")
  assertTrue(len(gameServer.diagnostics) > 0, "truncated move diagnostic")
  return true
end function

// Verify effects aware fast update against the expected Quake behavior.
function testEffectsAwareFastUpdate()
  baseline = baselineState()
  unchanged = sz.alloc(64)
  bits = update.writeFastUpdate(
    unchanged, 1, baseline, 1, 2, 3, 4, 5,
    t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 45.0, 90.0), c.MOVETYPE_NONE,
  )
  assertEqual(bits, 0, "unchanged bits")
  assertHex(sz.dataSlice(unchanged), "8001", "fast_update_unchanged_short")

  effects = sz.alloc(64)
  bits = update.writeFastUpdate(
    effects, 1, baseline, 1, 2, 3, 4, 6,
    t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 45.0, 90.0), c.MOVETYPE_NONE,
  )
  assertTrue((bits & c.U_EFFECTS) != 0, "effects bit")
  assertTrue((bits & c.U_MOREBITS) != 0, "effects MoreBits")
  assertHex(sz.dataSlice(effects), "81200106", "fast_update_effects_changed")
  return true
end function

// Verify step no lerp update against the expected Quake behavior.
function testStepNoLerpUpdate()
  baseline = baselineState()
  buffer = sz.alloc(64)
  bits = update.writeFastUpdate(
    buffer, 1, baseline, 1, 2, 3, 4, 5,
    t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 45.0, 90.0), c.MOVETYPE_STEP,
  )
  assertEqual(bits, c.U_NOLERP, "step-only bits")
  assertHex(sz.dataSlice(buffer), "a001", "fast_update_step_only")
  return true
end function

// Verify full short fast update against the expected Quake behavior.
function testFullShortFastUpdate()
  baseline = baselineState()
  buffer = sz.alloc(128)
  bits = update.writeFastUpdate(buffer, 7, baseline, 9, 8, 6, 7, 10, fullOrigin(), fullAngles(), c.MOVETYPE_STEP)
  assertHex(sz.dataSlice(buffer), "ff3f07090806070a5a0008960040fc00e0", "fast_update_full_short")
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "short update event count")
  payload = parsed.events[0].payload
  assertEqual(payload[0], 7, "short entity number")
  assertEqual(payload[1], bits, "short update bits")
  assertEqual(payload[2], 9, "short model")
  assertEqual(payload[6], 10, "short effects")
  assertEqual(payload[7][0], 11.25, "short origin x")
  assertEqual(payload[8][1], 90.0, "short angle y")
  return true
end function

// Verify full long fast update against the expected Quake behavior.
function testFullLongFastUpdate()
  baseline = baselineState()
  buffer = sz.alloc(128)
  bits = update.writeFastUpdate(buffer, 300, baseline, 9, 8, 6, 7, 10, fullOrigin(), fullAngles(), c.MOVETYPE_STEP)
  assertHex(sz.dataSlice(buffer), "ff7f2c01090806070a5a0008960040fc00e0", "fast_update_full_long")
  parsed = protocol.parse(sz.dataSlice(buffer))
  payload = parsed.events[0].payload
  assertEqual(payload[0], 300, "long entity number")
  assertTrue((payload[1] & c.U_LONGENTITY) != 0, "long entity bit")
  assertEqual(payload[1], bits, "long update bits")
  return true
end function

// Verify svc catalog against the expected Quake behavior.
function testSvcCatalog()
  encoded = "0102030240e20100040f00000005010006001100010800100018000700004841087072696e740a00096563686f20666978747572650a000a0740e00b0f00000001007374617274006d6170732f73746172742e6273700070726f67732f706c617965722e6d646c00006d6973632f6d656e75312e77617600000c006d000d0052616e676572000e0007000f0040785634120264000a0b0c0d0e0110110011004d1208001000180001fe0304051301022000280030001401020000080000100040180080160200010200000800001000401800801700380040004800180119011a63656e746572001b1c1d08001000180001ff401e1f66696e616c650020030321226375747363656e65008001"
  data = fromHex(encoded)
  assertEqual(len(data), 268, "SVC catalog bytes")
  parsed = protocol.parse(data)
  expected = [
    "svc_nop", "svc_disconnect", "svc_updatestat", "svc_version", "svc_setview",
    "svc_sound", "svc_time", "svc_print", "svc_stufftext", "svc_setangle",
    "svc_serverinfo", "svc_lightstyle", "svc_updatename", "svc_updatefrags",
    "svc_clientdata", "svc_stopsound", "svc_updatecolors", "svc_particle",
    "svc_damage", "svc_spawnstatic", "svc_spawnbaseline", "svc_temp_entity",
    "svc_setpause", "svc_signonnum", "svc_centerprint", "svc_killedmonster",
    "svc_foundsecret", "svc_spawnstaticsound", "svc_intermission", "svc_finale",
    "svc_cdtrack", "svc_sellscreen", "svc_cutscene", "fast_update",
  ]
  assertEqual(len(parsed.events), len(expected), "SVC catalog event count")
  index = 0
  while index < len(expected)
    assertEqual(parsed.events[index].command, expected[index], "SVC event " + index)
    index = index + 1
  end while
  assertEqual(parsed.bytesRead, len(data), "SVC catalog consumed")
  return true
end function

// Verify malformed server commands against the expected Quake behavior.
function testMalformedServerCommands()
  reserved = try(protocol.parse(bytes([c.SVC_SPAWNBINARY])))
  assertTrue(reserved is error, "reserved svc_spawnbinary rejected")
  unknown = try(protocol.parse(bytes([35])))
  assertTrue(unknown is error, "unknown SVC rejected")
  truncated = try(protocol.parse(bytes([c.SVC_VERSION, 15])))
  assertTrue(truncated is error, "truncated SVC rejected")
  return true
end function

// Verify first update completes signon against the expected Quake behavior.
function testFirstUpdateCompletesSignon()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  localClient.signon = c.SIGNON_SPAWN
  localClient.spawned = false
  parsed = protocol.parse(fromHex("8001"))
  assertEqual(len(parsed.events), 1, "first update event count")
  result = client.applyEvent(localClient, parsed.events[0])
  assertTrue(result is not error, "first update applied")
  assertEqual(localClient.signon, c.SIGNON_ACTIVE, "first update signon stage")
  assertTrue(localClient.spawned, "first update ends loading state")
  return true
end function

// Verify shared production entity writer against the expected Quake behavior.
function testSharedProductionEntityWriter()
  baseline = baselineState()
  item = edict.create(1)
  item.baseline = baseline
  item.modelIndex = 1
  item.frame = 2
  item.colormap = 3
  item.skin = 4
  item.effects = 6
  item.origin = t.Vec3(10.0, 20.0, 30.0)
  item.angles = t.Vec3(0.0, 45.0, 90.0)

  gameServer = server.create(1)
  gameServer.edicts = [edict.create(0), item]
  gameServer.numEdicts = 2
  runtimeBuffer = sz.alloc(64)
  server.writeEntityUpdate(gameServer, runtimeBuffer, item)
  assertHex(sz.dataSlice(runtimeBuffer), "81200106", "runtime shared writer")

  portBuffer = sz.alloc(64)
  svmain.SV_WriteEntityDelta(void, portBuffer, item)
  assertHex(sz.dataSlice(portBuffer), "81200106", "sv_main shared writer")
  assertEqual(hex(sz.dataSlice(runtimeBuffer)), hex(sz.dataSlice(portBuffer)), "production writers agree")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-011 Protocol 15 command tests"
  passed = 0
  if runTest("01", "client signon replies 1-4", testClientSignonReplies) then passed = passed + 1 end if
  if runTest("02", "server signon markers and Host_Begin", testServerSignonStages) then passed = passed + 1 end if
  if runTest("03", "compound CLC stream", testClcCompoundStream) then passed = passed + 1 end if
  if runTest("04", "CLC disconnect", testClcDisconnect) then passed = passed + 1 end if
  if runTest("05", "signed 0xff CLC end-of-message", testSignedClientEndOfMessage) then passed = passed + 1 end if
  if runTest("06", "malformed CLC rejection", testMalformedClientCommands) then passed = passed + 1 end if
  if runTest("07", "effects-aware fast update", testEffectsAwareFastUpdate) then passed = passed + 1 end if
  if runTest("08", "MOVETYPE_STEP no-lerp update", testStepNoLerpUpdate) then passed = passed + 1 end if
  if runTest("09", "full short fast update", testFullShortFastUpdate) then passed = passed + 1 end if
  if runTest("10", "full long fast update", testFullLongFastUpdate) then passed = passed + 1 end if
  if runTest("11", "complete SVC command catalog", testSvcCatalog) then passed = passed + 1 end if
  if runTest("12", "malformed SVC rejection", testMalformedServerCommands) then passed = passed + 1 end if
  if runTest("13", "first update completes signon", testFirstUpdateCompletesSignon) then passed = passed + 1 end if
  if runTest("14", "shared production entity writer", testSharedProductionEntityWriter) then passed = passed + 1 end if

  if passed != 14 then
    print "MiniQuake BP-011 Protocol 15 command tests failed: " + passed + "/14"
    return 1
  end if
  print "MiniQuake BP-011 Protocol 15 command tests passed: 14"
  return 0
end function
