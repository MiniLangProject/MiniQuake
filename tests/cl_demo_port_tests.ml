import miniquake.demo as demo
import miniquake.demo_player as player
import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.byteio as bio

function require(value, name)
  if value != true then return error(9880, name) end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(9881, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9882, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function byteFixture(values)
  result = bytes(len(values))
  index = 0
  while index < len(values)
    result[index] = values[index]
    index = index + 1
  end while
  return result
end function

function bytesEqual(actual, expected, name)
  equal(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    equal(actual[index], expected[index], name + " byte " + index)
    index = index + 1
  end while
  return true
end function

function timePayload(value)
  buffer = sz.alloc(16)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, value)
  return sz.dataSlice(buffer)
end function

function playbackFixture()
  recording = t.Demo(-1, [
    t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), timePayload(1.1)),
    t.DemoMessage(t.Vec3(40.0, 50.0, 60.0), timePayload(1.2)),
  ], "-1\n")
  playback = player.create(recording)
  playback.client.connected = true
  playback.client.signon = c.SIGNONS
  playback.client.spawned = true
  playback.client.messageTimes = [1.0, 0.0]
  playback.client.time = 0.9
  return playback
end function

function testGlquakeFraming()
  fixture = byteFixture([
    45, 49, 10,
    3, 0, 0, 0,
    0, 0, 128, 63,
    0, 0, 32, 192,
    0, 0, 180, 66,
    c.SVC_NOP, c.SVC_PRINT, 0,
  ])
  recording = demo.CL_PlayDemo_f(fixture)
  equal(recording.forcedTrack, -1, "forced track")
  equal(len(recording.messages), 1, "message count")
  near(recording.messages[0].viewAngles.x, 1.0, 0.000001, "view angle x")
  near(recording.messages[0].viewAngles.y, -2.5, 0.000001, "view angle y")
  near(recording.messages[0].viewAngles.z, 90.0, 0.000001, "view angle z")
  bytesEqual(recording.messages[0].payload, byteFixture([c.SVC_NOP, c.SVC_PRINT, 0]), "payload")
  bytesEqual(demo.serialize(recording), fixture, "MiniQuake roundtrip")
  return true
end function

function testRecordWriteStop()
  plan = demo.CL_Record_f(["record", "fixture", "e1m1", "4"], false)
  equal(plan[0], "fixture.dem", "record filename")
  recording = plan[1]
  equal(recording.forcedTrack, 4, "record track")
  payload = byteFixture([c.SVC_NOP])
  equal(demo.CL_WriteDemoMessage(recording, payload, t.Vec3(1.0, 2.0, 3.0)), 1, "write message")
  payload[0] = c.SVC_BAD
  equal(recording.messages[0].payload[0], c.SVC_NOP, "recording owns payload copy")
  stopped = demo.CL_Stop_f(recording, t.Vec3(4.0, 5.0, 6.0))
  require(stopped is not error, "stop recording")
  equal(len(recording.messages), 2, "disconnect appended")
  equal(recording.messages[1].payload[0], c.SVC_DISCONNECT, "disconnect opcode")
  reparsed = demo.parse(demo.serialize(recording))
  equal(len(reparsed.messages), 2, "recorded demo reparses")

  connected = try(demo.CL_Record_f(["record", "late"], true))
  require(connected is error, "connected record without map rejected")
  traversal = try(demo.CL_Record_f(["record", "../bad"], false))
  require(traversal is error, "relative pathname rejected")
  nested = demo.CL_Record_f(["record", "demos/route", "e1m1"], false)
  require(nested is not error, "original record command accepts game-relative subdirectories")
  equal(nested[0], "demos/route.dem", "nested demo filename")
  decimalTrack = demo.CL_Record_f(["record", "decimal", "e1m1", "1.5"], false)
  equal(decimalTrack[1].forcedTrack, 1, "C atoi consumes integer prefix")
  alphaTrack = demo.CL_Record_f(["record", "alpha", "e1m1", "soundtrack"], false)
  equal(alphaTrack[1].forcedTrack, 0, "C atoi returns zero without digits")
  return true
end function

function testPlaybackPacing()
  playback = playbackFixture()
  equal(player.stepFrame(playback, 1, 1.0, 0.05), 0, "mtime blocks early message")
  equal(playback.index, 0, "blocked index")
  equal(player.stepFrame(playback, 2, 1.1, 0.1), 1, "first due message")
  equal(playback.index, 1, "first message index")
  near(playback.client.serverTime, 1.1, 0.000001, "first server time")
  equal(player.stepFrame(playback, 3, 1.2, 0.025), 0, "second message still paced")
  equal(playback.index, 1, "paced second index")
  equal(player.stepFrame(playback, 4, 1.3, 0.05), 1, "second due message")
  near(playback.client.serverTime, 1.2, 0.000001, "second server time")
  equal(playback.client.viewAngleSamples[1].x, 10.0, "previous demo view angle")
  equal(playback.client.viewAngleSamples[0].x, 40.0, "current demo view angle")
  return true
end function

function testTimedemo()
  playback = playbackFixture()
  require(player.CL_TimeDemo_f(playback, 10), "start timedemo")
  equal(player.stepFrame(playback, 10, 4.0, 0.0), 1, "one message in first timedemo frame")
  equal(playback.index, 1, "timedemo first index")
  equal(player.stepFrame(playback, 10, 4.1, 0.0), 0, "same frame cannot read twice")
  equal(playback.index, 1, "same-frame index")
  equal(player.stepFrame(playback, 11, 5.0, 0.0), 1, "next frame reads next message")
  equal(playback.index, 2, "timedemo second index")
  equal(player.stepFrame(playback, 12, 6.0, 0.0), 0, "EOF stops timedemo")
  require(playback.stopped, "timedemo playback stopped")
  equal(playback.finishResult[0], 1, "first timedemo frame excluded")
  near(playback.finishResult[1], 1.0, 0.000001, "timedemo seconds")
  near(playback.finishResult[2], 1.0, 0.000001, "timedemo fps")
  require(not playback.client.timedemo, "client timedemo flag cleared")
  return true
end function

function testGetMessageAndStop()
  playback = playbackFixture()
  playback.client.time = 1.1
  item = player.CL_GetMessage(playback, 1, 1.0)
  require(item is not void, "CL_GetMessage returns due message")
  equal(item.viewAngles.y, 20.0, "message viewangles")
  stopped = player.CL_StopPlayback(playback, 2, 2.0)
  require(stopped == true, "stop playback")
  require(playback.complete and playback.stopped, "playback terminal state")
  require(not playback.client.connected, "client disconnected")
  equal(player.CL_StopPlayback(playback, 3, 3.0), false, "repeat stop ignored")

  direct = playbackFixture()
  result = player.CL_FinishTimeDemo(direct, 20, 10.0)
  equal(result[0], 19, "direct timedemo frames")
  near(result[1], 10.0, 0.000001, "direct timedemo time")
  return true
end function

function testMalformed()
  missingHeader = try(demo.parse(byteFixture([45, 49])))
  require(missingHeader is error, "missing track newline")
  decimalTrack = try(demo.parse(bytes("1.5\n")))
  require(decimalTrack is error, "decimal track")
  truncatedHeader = try(demo.parse(bytes("-1\nx")))
  require(truncatedHeader is error, "truncated message header")

  oversized = bytes(19)
  oversized[0] = 45; oversized[1] = 49; oversized[2] = 10
  bio.putI32(oversized, 3, c.MAX_MSGLEN + 1)
  tooLarge = try(demo.parse(oversized))
  require(tooLarge is error, "oversized message")

  truncatedPayload = bytes(20)
  truncatedPayload[0] = 48; truncatedPayload[1] = 10
  bio.putI32(truncatedPayload, 2, 8)
  missingPayload = try(demo.parse(truncatedPayload))
  require(missingPayload is error, "truncated payload")
  return true
end function

function testVerifierPath()
  recording = t.Demo(0, [
    t.DemoMessage(t.Vec3(0.0, 90.0, 0.0), byteFixture([c.SVC_NOP])),
    t.DemoMessage(t.Vec3(0.0, 180.0, 0.0), byteFixture([c.SVC_DISCONNECT])),
  ], "0\n")
  playback = player.create(recording)
  playback.client.connected = true
  equal(player.playAll(playback), 2, "offline verifier event count")
  equal(playback.client.viewAngleSamples[1].y, 90.0, "verifier previous angle")
  equal(playback.client.viewAngleSamples[0].y, 180.0, "verifier current angle")
  report = player.verify(recording)
  require(report.ok, "verification report")
  equal(report.eventCount, 2, "verification event count")
  return true
end function

function main(args)
  print "MiniQuake cl_demo port tests starting: 7"
  result = try(testGlquakeFraming())
  if result is error then print "FAIL framing: " + result.message; return 1 end if
  print "[1/7] MiniQuake framing roundtrip"
  result = try(testRecordWriteStop())
  if result is error then print "FAIL record: " + result.message; return 1 end if
  print "[2/7] record / write / stop"
  result = try(testPlaybackPacing())
  if result is error then print "FAIL pacing: " + result.message; return 1 end if
  print "[3/7] mtime playback pacing"
  result = try(testTimedemo())
  if result is error then print "FAIL timedemo: " + result.message; return 1 end if
  print "[4/7] one-message timedemo frames"
  result = try(testGetMessageAndStop())
  if result is error then print "FAIL get/stop: " + result.message; return 1 end if
  print "[5/7] get / stop / finish"
  result = try(testMalformed())
  if result is error then print "FAIL malformed: " + result.message; return 1 end if
  print "[6/7] malformed demo rejection"
  result = try(testVerifierPath())
  if result is error then print "FAIL verifier: " + result.message; return 1 end if
  print "[7/7] offline verifier path"
  print "MiniQuake cl_demo port tests passed: 7"
  return 0
end function
