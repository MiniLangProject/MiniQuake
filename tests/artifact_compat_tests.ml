import miniquake.artifact_compat as artifacts
import miniquake.demo as demo
import miniquake.demo_player as player
import miniquake.types as t
import miniquake.constants as c
import miniquake.quakec.edict as qcedict
import miniquake.common as common
import miniquake.native as native

passed = 0
failed = 0

function bp087Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; return true end if
  print "FAIL: " + label
  failed = failed + 1
  return false
end function

function bp087Equal(actual, expected, label)
  return bp087Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

function bp087SyntheticDemo()
  payload = bytes(1)
  payload[0] = c.SVC_NOP
  message = t.DemoMessage(t.Vec3(1.0, 2.0, 3.0), payload)
  return t.Demo(-1, [message], "-1\n")
end function

function bp087SaveFixture(value)
  globalState = t.Entity([t.EntityPair("serverflags", "3")])
  world = t.Entity([t.EntityPair("classname", "worldspawn"), t.EntityPair("message", value)])
  return t.SaveGame(5, "comment", [1.0], 1, "start", 2.0, ["m"], globalState, [world])
end function

function main(args)
  global passed, failed
  print "[1/24] status"
  bp087Equal(artifacts.STATUS, "artifact_compat_109_frozen_v1", "status")
  print "[2/24] fingerprint"
  bp087Equal(artifacts.FINGERPRINT, 0x59531091, "fingerprint")
  print "[3/24] save version"
  bp087Equal(artifacts.SAVEGAME_VERSION, 5, "save version")
  print "[4/24] retail demo count"
  bp087Equal(artifacts.RETAIL_DEMO_COUNT, 3, "demo count")
  names = artifacts.retailDemoNames()
  print "[5/24] demo1 name"
  bp087Equal(names[0], "demo1.dem", "demo1")
  print "[6/24] demo2 name"
  bp087Equal(names[1], "demo2.dem", "demo2")
  print "[7/24] demo3 name"
  bp087Equal(names[2], "demo3.dem", "demo3")
  print "[8/24] byte equality"
  bp087Check(artifacts.bytesEqual(bytes([1, 2, 3]), bytes([1, 2, 3])), "byte equality")
  print "[9/24] byte inequality"
  bp087Check(not artifacts.bytesEqual(bytes([1, 2, 3]), bytes([1, 2, 4])), "byte inequality")
  print "[10/24] byte length inequality"
  bp087Check(not artifacts.bytesEqual(bytes([1]), bytes([1, 2])), "length inequality")
  print "[11/24] CRC known"
  bp087Equal(artifacts.bytesCrc(bytes("123456789")), 0x29b1, "CRC")

  recording = bp087SyntheticDemo()
  encoded = demo.serialize(recording)
  decoded = demo.parse(encoded)
  print "[12/24] demo forced track"
  bp087Equal(decoded.forcedTrack, -1, "forced track")
  print "[13/24] demo message count"
  bp087Equal(len(decoded.messages), 1, "message count")
  print "[14/24] demo angle x"
  bp087Equal(decoded.messages[0].viewAngles.x, 1.0, "angle x")
  print "[15/24] demo payload"
  bp087Equal(decoded.messages[0].payload[0], c.SVC_NOP, "payload")
  print "[16/24] demo reserialize"
  bp087Check(artifacts.bytesEqual(encoded, demo.serialize(decoded)), "reserialize")
  report = player.verify(decoded)
  print "[17/24] demo verification"
  bp087Check(report.ok, "verification")
  print "[18/24] demo payload bytes"
  bp087Equal(report.payloadBytes, 1, "payload bytes")
  summary = artifacts.demoSummary(decoded, report, encoded)
  print "[19/24] demo summary arity"
  bp087Equal(len(summary), 9, "summary arity")
  print "[20/24] demo summary CRC"
  bp087Equal(summary[8], artifacts.bytesCrc(encoded), "summary CRC")

  saveSummary = artifacts.saveSummary(bytes([1, 2, 3]), "start", 1.5, 0x1234, 0x5678)
  print "[21/24] save summary version"
  bp087Equal(saveSummary[0], 5, "summary version")
  saveLeft = bp087SaveFixture("alpha")
  saveRight = bp087SaveFixture("alpha")
  print "[22/24] save semantic equality"
  bp087Check(artifacts.saveSemanticEqual(saveLeft, saveRight), "semantic equality")
  changed = bp087SaveFixture("beta")
  print "[23/24] save semantic difference"
  bp087Equal(artifacts.saveSemanticDifference(saveLeft, changed), "entity 0 pair 1 value for message", "semantic difference")
  difference = artifacts.firstByteDifference(bytes([1, 2, 3]), bytes([1, 9, 3]))
  print "[24/24] byte difference and contract"
  bp087Check(difference[0] == 1 and difference[1] == 2 and difference[2] == 9 and len(bytes(artifacts.CONTRACT_TEXT)) > 32, "byte difference contract")
  bp087Equal(qcedict.fixedSixDecimals(4097.0), "4097.000000", "retail spawn parm fixed-six")
  bp087Equal(qcedict.fixedSixDecimals(-4097.0), "-4097.000000", "negative retail spawn parm fixed-six")
  bp087Equal(native.floatBits(common.cAtof("-0.000000")), 0x80000000, "retail save signed-zero parse")

  if failed > 0 then print "MiniQuake BP-087 artifact compatibility tests failed: " + failed + "/24"; return 1 end if
  print "MiniQuake BP-087 artifact compatibility tests passed: 24"
  return 0
end function
