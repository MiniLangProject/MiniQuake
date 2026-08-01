/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-018 demo framing, recording, keepalive filtering and timedemo fixtures.
*/

import miniquake.demo as demo
import miniquake.demo_player as player
import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.byteio as bio

function equal(actual, expected, name)
  if actual != expected then return error(9800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function yes(value, name)
  if not value then return error(9801, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(9802, name + ": expected false") end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9803, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "  [" + number + "/19] " + name
  result = try(fn())
  if result is error then print "    FAIL: " + result.message; return false end if
  return true
end function

function playerState()
  return movement.createPlayer(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
end function

function pair()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26100, true)
  clientSocket = netmain.NET_Connect(network, "local", 1)
  serverSocket = netmain.NET_CheckNewConnections(network)
  if clientSocket is void or serverSocket is void then return error(9804, "loop pair missing") end if
  return [network, clientSocket, serverSocket]
end function

function closePair(value)
  if value[2] is not void then netmain.NET_Close(value[2]) end if
  if value[1] is not void then netmain.NET_Close(value[1]) end if
  netmain.NET_Shutdown(value[0])
  return true
end function

function timeMessage(value)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, value)
  return buffer
end function

function playbackFixture()
  recording = t.Demo(-1, [
    t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), sz.dataSlice(timeMessage(1.1))),
    t.DemoMessage(t.Vec3(40.0, 50.0, 60.0), sz.dataSlice(timeMessage(1.2))),
  ], "-1\n")
  playback = player.create(recording)
  playback.client.connected = true
  playback.client.signon = c.SIGNONS
  playback.client.spawned = true
  playback.client.messageTimes = [1.0, 0.0]
  playback.client.time = 0.9
  return playback
end function

function testRecordAtoi()
  equal(demo.recordTrackNumber("1.5"), 1, "decimal suffix")
  equal(demo.recordTrackNumber("soundtrack"), 0, "no digits")
  equal(demo.recordTrackNumber("  -12tail"), -12, "leading whitespace and sign")
  equal(demo.recordTrackNumber("\t+7"), 7, "tab and plus")
  equal(demo.CL_Record_f(["record", "x", "start", "1.5"], false)[1].forcedTrack, 1, "record command track")
  return true
end function

function testFilenameRules()
  equal(demo.filename("route"), "route.dem", "default extension")
  equal(demo.filename("ROUTE.DEM"), "ROUTE.DEM", "case-insensitive extension")
  equal(demo.filename("demos/route"), "demos/route.dem", "game-relative subdirectory")
  yes(try(demo.filename("../escape")) is error, "relative traversal rejected")
  return true
end function

function testRecordPlan()
  plan = demo.CL_Record_f(["record", "fixture", "e1m1", "4"], false)
  equal(plan[0], "fixture.dem", "record name")
  equal(plan[1].forcedTrack, 4, "forced track")
  equal(plan[1].trackHeader, "4\n", "track header")
  equal(plan[2], "e1m1", "map name")
  yes(try(demo.CL_Record_f(["record", "late"], true)) is error, "connected record without map rejected")
  return true
end function

function testExactFrameBytes()
  recording = t.Demo(4, [], "4\n")
  demo.CL_WriteDemoMessage(recording, bytes([1, 2, 3]), t.Vec3(1.0, -2.5, 90.0))
  equal(hex(demo.serialize(recording)), "340a030000000000803f000020c00000b442010203", "GLQuake frame bytes")
  return true
end function

function testRoundTrip()
  recording = t.Demo(-1, [], "-1\n")
  demo.CL_WriteDemoMessage(recording, bytes("alpha"), t.Vec3(1.25, 2.5, 5.0))
  demo.CL_WriteDemoMessage(recording, bytes([0, 1, 127, 255]), t.Vec3(-1.0, 180.0, 359.0))
  encoded = demo.serialize(recording)
  decoded = demo.parse(encoded)
  equal(decoded.forcedTrack, -1, "roundtrip track")
  equal(len(decoded.messages), 2, "roundtrip message count")
  equal(hex(decoded.messages[1].payload), "00017fff", "roundtrip binary payload")
  equal(hex(demo.serialize(decoded)), hex(encoded), "roundtrip bytes")
  return true
end function

function testKeepalivePredicate()
  yes(demo.isKeepalivePayload(bytes([c.SVC_NOP])), "isolated NOP")
  no(demo.isKeepalivePayload(bytes([c.SVC_NOP, c.SVC_NOP])), "two-byte payload")
  no(demo.isKeepalivePayload(bytes([c.SVC_DISCONNECT])), "other singleton")
  no(demo.isKeepalivePayload("not bytes"), "type boundary")
  return true
end function

function testRecordingPumpFiltersKeepalive()
  value = pair()
  if value is error then return value end if
  localClient = client.create(playerState())
  localClient.connected = true
  localClient.socket = value[1]
  recording = t.Demo(-1, [], "-1\n")
  nop = sz.alloc(2); msg.writeByte(nop, c.SVC_NOP)
  netmain.NET_SendUnreliableMessage(value[2], nop)
  netmain.NET_SendUnreliableMessage(value[2], timeMessage(3.5))
  equal(client.pumpRecording(localClient, recording), 1, "only non-keepalive processed")
  equal(len(recording.messages), 1, "only non-keepalive recorded")
  equal(recording.messages[0].payload[0], c.SVC_TIME, "recorded command")
  near(localClient.serverTime, 3.5, 0.000001, "recorded command parsed")
  closePair(value)
  return true
end function

function testNormalPumpFiltersKeepalive()
  value = pair()
  if value is error then return value end if
  localClient = client.create(playerState())
  localClient.connected = true
  localClient.socket = value[1]
  nop = sz.alloc(2); msg.writeByte(nop, c.SVC_NOP)
  netmain.NET_SendUnreliableMessage(value[2], nop)
  equal(client.readNetworkMessages(localClient, 7.0), 0, "isolated keepalive not returned")
  equal(localClient.lastMessageTime, 0.0, "keepalive does not reach parser timestamp")
  closePair(value)
  return true
end function

function testStopWritesDisconnect()
  recording = t.Demo(-1, [], "-1\n")
  demo.CL_WriteDemoMessage(recording, bytes([c.SVC_NOP, c.SVC_PRINT, 0]), t.Vec3(0.0, 0.0, 0.0))
  stopped = demo.CL_Stop_f(recording, t.Vec3(4.0, 5.0, 6.0))
  yes(stopped is not error, "stop succeeds")
  equal(len(recording.messages), 2, "disconnect frame appended")
  equal(hex(recording.messages[1].payload), "02", "svc_disconnect payload")
  return true
end function

function testMaxMessageBoundary()
  recording = t.Demo(-1, [], "-1\n")
  equal(demo.CL_WriteDemoMessage(recording, bytes(c.MAX_MSGLEN), t.Vec3(0.0, 0.0, 0.0)), 1, "MAX_MSGLEN accepted")
  tooLarge = try(demo.CL_WriteDemoMessage(recording, bytes(c.MAX_MSGLEN + 1), t.Vec3(0.0, 0.0, 0.0)))
  yes(tooLarge is error, "MAX_MSGLEN plus one rejected")
  return true
end function

function testMalformedFraming()
  yes(try(demo.parse(bytes("-1"))) is error, "missing track newline")
  yes(try(demo.parse(bytes("-1\nx"))) is error, "truncated message header")
  oversized = bytes(19)
  oversized[0] = 45; oversized[1] = 49; oversized[2] = 10
  bio.putI32(oversized, 3, c.MAX_MSGLEN + 1)
  yes(try(demo.parse(oversized)) is error, "oversized frame length")
  truncated = bytes(20)
  truncated[0] = 48; truncated[1] = 10
  bio.putI32(truncated, 2, 8)
  yes(try(demo.parse(truncated)) is error, "truncated payload")
  return true
end function

function testPlaybackPacing()
  playback = playbackFixture()
  equal(player.stepFrame(playback, 1, 1.0, 0.05), 0, "early frame blocked")
  equal(player.stepFrame(playback, 2, 1.1, 0.1), 1, "first due frame")
  equal(player.stepFrame(playback, 3, 1.2, 0.025), 0, "second frame still paced")
  equal(player.stepFrame(playback, 4, 1.3, 0.05), 1, "second due frame")
  equal(playback.client.viewAngleSamples[1].x, 10.0, "previous view angle")
  equal(playback.client.viewAngleSamples[0].x, 40.0, "current view angle")
  return true
end function

function testTimedemoSameFrameGate()
  playback = playbackFixture()
  player.CL_TimeDemo_f(playback, 10)
  equal(player.stepFrame(playback, 10, 4.0, 0.0), 1, "first timedemo message")
  equal(player.stepFrame(playback, 10, 4.1, 0.0), 0, "same host frame blocked")
  equal(playback.index, 1, "same frame index")
  equal(player.stepFrame(playback, 11, 5.0, 0.0), 1, "next host frame advances")
  near(playback.startTime, 5.0, 0.000001, "second-frame start time")
  return true
end function

function testTimedemoFinish()
  playback = playbackFixture()
  playback.timedemo = true
  playback.client.timedemo = true
  playback.startFrame = 10
  playback.startTime = 5.0
  result = player.CL_FinishTimeDemo(playback, 21, 10.0)
  equal(result[0], 10, "first frame excluded")
  near(result[1], 5.0, 0.000001, "elapsed time")
  near(result[2], 2.0, 0.000001, "fps")
  no(playback.timedemo, "timedemo cleared")
  no(playback.client.timedemo, "client timedemo cleared")
  return true
end function

function testEofStopsPlayback()
  recording = t.Demo(0, [t.DemoMessage(t.Vec3(0.0, 0.0, 0.0), bytes([c.SVC_NOP]))], "0\n")
  playback = player.create(recording)
  playback.client.connected = true
  first = player.CL_GetMessage(playback, 1, 1.0)
  yes(first is not void, "first item")
  eof = player.CL_GetMessage(playback, 2, 2.0)
  yes(eof is void, "EOF returns no message")
  yes(playback.stopped, "EOF stops playback")
  no(playback.client.connected, "EOF disconnects client")
  return true
end function

function testViewAnglesApplied()
  recording = t.Demo(0, [
    t.DemoMessage(t.Vec3(1.0, 2.0, 3.0), bytes([c.SVC_NOP])),
    t.DemoMessage(t.Vec3(4.0, 5.0, 6.0), bytes([c.SVC_NOP])),
  ], "0\n")
  playback = player.create(recording)
  playback.client.connected = true
  player.CL_GetMessage(playback, 1, 1.0)
  player.CL_GetMessage(playback, 2, 2.0)
  equal(playback.client.viewAngleSamples[1].y, 2.0, "previous sampled yaw")
  equal(playback.client.viewAngleSamples[0].y, 5.0, "current sampled yaw")
  equal(playback.client.command.viewAngles.y, 5.0, "command yaw")
  equal(playback.client.player.viewAngles.y, 5.0, "player yaw")
  return true
end function

function testOfflineVerifier()
  recording = t.Demo(0, [
    t.DemoMessage(t.Vec3(0.0, 90.0, 0.0), bytes([c.SVC_NOP])),
    t.DemoMessage(t.Vec3(0.0, 180.0, 0.0), bytes([c.SVC_DISCONNECT])),
  ], "0\n")
  report = player.verify(recording)
  yes(report.ok, "offline verifier")
  equal(report.eventCount, 2, "offline event count")
  equal(report.payloadBytes, 2, "offline payload bytes")
  return true
end function

function deterministicCorpus()
  messages = []
  index = 0
  while index < 64
    payload = bytes(1 + (index % 31))
    cursor = 0
    while cursor < len(payload)
      payload[cursor] = (index * 13 + cursor * 7) & 255
      cursor = cursor + 1
    end while
    messages = messages + [t.DemoMessage(t.Vec3(index * 0.25, index * -0.5, index * 1.5), payload)]
    index = index + 1
  end while
  return t.Demo(-1, messages, "-1\n")
end function

function testDeterministicCorpus()
  first = demo.serialize(deterministicCorpus())
  second = demo.serialize(deterministicCorpus())
  equal(hex(first), hex(second), "independent corpus bytes")
  parsed = demo.parse(first)
  equal(len(parsed.messages), 64, "corpus message count")
  equal(hex(demo.serialize(parsed)), hex(first), "corpus parse/serialize identity")
  return true
end function

function testTrackHeaderPlaybackArithmetic()
  whitespace = demo.parse(bytes("  2\n"))
  equal(whitespace.forcedTrack, -1758, "GLQuake bytewise whitespace arithmetic")
  negative = demo.parse(bytes("-12\n"))
  equal(negative.forcedTrack, -12, "negative playback track")
  return true
end function

passed = 0
if run(1, "C atoi recording track", testRecordAtoi) then passed = passed + 1 end if
if run(2, "demo filename rules", testFilenameRules) then passed = passed + 1 end if
if run(3, "record command plan", testRecordPlan) then passed = passed + 1 end if
if run(4, "exact frame bytes", testExactFrameBytes) then passed = passed + 1 end if
if run(5, "multi-frame byte roundtrip", testRoundTrip) then passed = passed + 1 end if
if run(6, "isolated keepalive predicate", testKeepalivePredicate) then passed = passed + 1 end if
if run(7, "recording pump keepalive filter", testRecordingPumpFiltersKeepalive) then passed = passed + 1 end if
if run(8, "normal pump keepalive filter", testNormalPumpFiltersKeepalive) then passed = passed + 1 end if
if run(9, "stop writes disconnect", testStopWritesDisconnect) then passed = passed + 1 end if
if run(10, "MAX_MSGLEN boundary", testMaxMessageBoundary) then passed = passed + 1 end if
if run(11, "malformed framing rejection", testMalformedFraming) then passed = passed + 1 end if
if run(12, "mtime playback pacing", testPlaybackPacing) then passed = passed + 1 end if
if run(13, "timedemo same-frame gate", testTimedemoSameFrameGate) then passed = passed + 1 end if
if run(14, "timedemo first-frame exclusion", testTimedemoFinish) then passed = passed + 1 end if
if run(15, "EOF stop and disconnect", testEofStopsPlayback) then passed = passed + 1 end if
if run(16, "demo view-angle replacement", testViewAnglesApplied) then passed = passed + 1 end if
if run(17, "offline verifier", testOfflineVerifier) then passed = passed + 1 end if
if run(18, "deterministic 64-message corpus", testDeterministicCorpus) then passed = passed + 1 end if
if run(19, "playback track header arithmetic", testTrackHeaderPlaybackArithmetic) then passed = passed + 1 end if

if passed != 19 then
  print "MiniQuake BP-018 Protocol 15 demo tests failed: " + passed + "/19"
  error(9899, "BP-018 Protocol 15 demo fixtures failed")
end if
print "MiniQuake BP-018 Protocol 15 demo tests passed: 19"
