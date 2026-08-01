/* BP-032: WinQuake demo recording, playback and timedemo lifecycle parity. */
import miniquake.demo as demo
import miniquake.demo_player as playback
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native

function yes(value, name)
  if not value then return error(3200, name + ": expected true") end if
  return true
end function
function no(value, name)
  if value then return error(3201, name + ": expected false") end if
  return true
end function
function equal(actual, expected, name)
  if actual != expected then return error(3202, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function message(value)
  payload = bytes(1, value)
  return t.DemoMessage(t.Vec3(1.25, -2.5, 180.0), payload)
end function
function recording()
  return t.Demo(-1, [message(c.SVC_NOP), message(c.SVC_DISCONNECT)], "-1\n")
end function

function testTrackZero()
  equal(demo.parseTrack(bytes("0\n"))[0], 0, "track zero")
  return true
end function
function testTrackNegative()
  equal(demo.parseTrack(bytes("-12\n"))[0], -12, "negative track")
  return true
end function
function testTrackRawByteArithmetic()
  equal(demo.parseTrack(bytes("A\n"))[0], 17, "raw byte arithmetic")
  return true
end function
function testTrackWhitespaceArithmetic()
  equal(demo.parseTrack(bytes(" 1\n"))[0], -159, "retail whitespace arithmetic")
  return true
end function
function testTrackMissingNewline()
  value = try(demo.parseTrack(bytes("1")))
  yes(value is error, "missing newline")
  return true
end function
function testFrameRoundtrip()
  value = recording(); parsed = demo.parse(demo.serialize(value))
  equal(parsed.forcedTrack, -1, "forced track")
  equal(len(parsed.messages), 2, "message count")
  equal(parsed.messages[1].payload[0], c.SVC_DISCONNECT, "payload")
  return true
end function
function testAngleBinary32()
  value = t.Demo(-1, [t.DemoMessage(t.Vec3(0.100000001, -0.0, 359.99999), bytes(0))], "-1\n")
  parsed = demo.parse(demo.serialize(value))
  equal(native.floatBits(parsed.messages[0].viewAngles.x), native.floatBits(0.100000001), "angle x")
  equal(native.floatBits(parsed.messages[0].viewAngles.z), native.floatBits(359.99999), "angle z")
  return true
end function
function testWriteCopiesBinary32()
  value = t.Demo(-1, [], "-1\n")
  demo.CL_WriteDemoMessage(value, bytes(0), t.Vec3(0.100000001, 2.0, 3.0))
  equal(native.floatBits(value.messages[0].viewAngles.x), native.floatBits(0.100000001), "write angle")
  return true
end function
function testOversizeWrite()
  value = try(demo.CL_WriteDemoMessage(t.Demo(-1, [], "-1\n"), bytes(c.MAX_MSGLEN + 1), t.Vec3(0.0, 0.0, 0.0)))
  yes(value is error, "oversize message")
  return true
end function
function testTruncatedHeader()
  value = try(demo.parse(bytes("-1\n123")))
  yes(value is error, "truncated header")
  return true
end function
function testInvalidLength()
  data = bytes(20, 0); data[0] = 48; data[1] = 10; data[2] = 255; data[3] = 255; data[4] = 255; data[5] = 127
  value = try(demo.parse(data))
  yes(value is error, "invalid length")
  return true
end function
function testKeepalive()
  yes(demo.isKeepalivePayload(bytes(1, c.SVC_NOP)), "single nop")
  return true
end function
function testMixedKeepalive()
  no(demo.isKeepalivePayload(bytes(2, c.SVC_NOP)), "multi-byte nop")
  return true
end function
function testRecordArguments()
  value = try(demo.CL_Record_f(["record"], false))
  yes(value is error, "record usage")
  return true
end function
function testConnectedRecordRejected()
  value = try(demo.CL_Record_f(["record", "x"], true))
  yes(value is error, "connected record")
  return true
end function
function testRecordMapPlan()
  value = demo.CL_Record_f(["record", "x", "start", "2"], true)
  equal(value[0], "x.dem", "demo extension")
  equal(value[1].forcedTrack, 2, "track")
  equal(value[2], "start", "map plan")
  return true
end function
function testAtoiTrack()
  equal(demo.recordTrackNumber("  -12.5"), -12, "atoi track")
  equal(demo.recordTrackNumber("text"), 0, "atoi no digits")
  return true
end function
function testStopAddsDisconnect()
  value = t.Demo(-1, [], "-1\n")
  demo.CL_Stop_f(value, t.Vec3(0.0, 0.0, 0.0))
  equal(len(value.messages), 1, "stop message count")
  equal(value.messages[0].payload[0], c.SVC_DISCONNECT, "stop opcode")
  return true
end function
function testTimedemoFrameGate()
  state = playback.create(recording()); state.client.signon = c.SIGNONS
  playback.CL_TimeDemo_f(state, 10)
  yes(playback.CL_GetMessage(state, 10, 100.0) is not void, "first frame message")
  yes(playback.CL_GetMessage(state, 10, 100.0) is void, "one message per frame")
  yes(playback.CL_GetMessage(state, 11, 100.25) is not void, "second frame message")
  equal(native.floatBits(state.startTime), native.floatBits(100.25), "second-frame start time")
  return true
end function
function testFinishTimedemoFloat()
  state = playback.create(recording()); state.timedemo = true; state.client.timedemo = true; state.startFrame = 10; state.startTime = 100.0
  result = playback.CL_FinishTimeDemo(state, 20, 102.50000001)
  equal(result[0], 9, "timedemo frames")
  equal(native.floatBits(result[1]), native.floatBits(2.50000001), "timedemo seconds f32")
  equal(native.floatBits(result[2]), native.floatBits(9 / native.bitsFloat(native.floatBits(2.50000001))), "timedemo fps f32")
  return true
end function

function main(args)
  tests = [
    ["track zero",testTrackZero],["negative track",testTrackNegative],["raw track byte",testTrackRawByteArithmetic],["track whitespace",testTrackWhitespaceArithmetic],
    ["missing track newline",testTrackMissingNewline],["frame roundtrip",testFrameRoundtrip],["angle binary32",testAngleBinary32],["recorded angle boundary",testWriteCopiesBinary32],
    ["oversize write",testOversizeWrite],["truncated header",testTruncatedHeader],["invalid length",testInvalidLength],["keepalive",testKeepalive],
    ["mixed keepalive",testMixedKeepalive],["record arguments",testRecordArguments],["connected record",testConnectedRecordRejected],["record map plan",testRecordMapPlan],
    ["record atoi",testAtoiTrack],["stop recording",testStopAddsDisconnect],["timedemo frame gate",testTimedemoFrameGate],["timedemo finish",testFinishTimedemoFloat],
  ]
  passed=0;index=0
  while index < len(tests)
    if run(index+1,tests[index][0],tests[index][1]) then passed=passed+1 end if
    index=index+1
  end while
  if passed != 20 then return 1 end if
  print "MiniQuake BP-032 demo lifecycle tests passed: 20"
  return 0
end function
