/* BP-033: WinQuake savegame version-5 framing and byte-boundary parity. */

import miniquake.savegame as save
import miniquake.constants as c
import miniquake.native as native
import miniquake.protocol_text as protocolText
import miniquake.format.bsp as bsp
import miniquake.quakec.edict as qcedict

function yes(value, name)
  if not value then return error(3300, name + ": expected true") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(3301, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function latin1(value)
  return protocolText.decodeBytes(bytes(1, value))
end function

function sampleText()
  extended = latin1(0xe9)
  text = "5\n"
  text = text + "Start_________________kills:__2/__9\n"
  index = 0
  while index < c.NUM_SPAWN_PARMS
    if index == 0 then
      text = text + "0.100000001\n"
    else if index == 1 then
      text = text + "-0.000000\n"
    else
      text = text + "0.000000\n"
    end if
    index = index + 1
  end while
  text = text + "1.900000\n"
  text = text + "st" + extended + "rt\n"
  text = text + "12.3456789\n"
  index = 0
  while index < c.MAX_LIGHTSTYLES
    if index == 1 then text = text + extended + "\n" else text = text + "m\n" end if
    index = index + 1
  end while
  text = text + "{\n\"serverflags\" \"3\"\n}\n"
  text = text + "{\n\"classname\" \"worldspawn\"\n\"message\" \"caf" + extended + "\"\n}\n"
  return text
end function

function parsedSample()
  return save.parseBytes(save.encodeText(sampleText()))
end function

function testVersionConstant()
  equal(save.SAVEGAME_VERSION, 5, "save version")
  return true
end function

function testCommentLength()
  value = save.paddedComment("Start", 2, 9)
  equal(len(protocolText.encodeBytes(value)), save.SAVEGAME_COMMENT_LENGTH, "comment bytes")
  return true
end function

function testCommentSpaces()
  value = save.paddedComment("The Slipgate Complex", 2, 9)
  yes(save.displayComment(value) != value, "underscores converted for display")
  return true
end function

function testCommentKills()
  value = save.paddedComment("Start", 2, 9)
  data = protocolText.encodeBytes(value)
  suffix = protocolText.decodeBytes(slice(data, 22, 15))
  equal(suffix, "kills:__2/__9__", "kill summary")
  return true
end function

function testExtendedCommentByte()
  value = save.paddedComment("caf" + latin1(0xe9), 0, 0)
  data = protocolText.encodeBytes(value)
  equal(data[3], 0xe9, "extended comment byte")
  return true
end function

function testDisplayComment()
  equal(save.displayComment("A_B_C"), "A B C", "display comment")
  return true
end function

function testFilenameExtension()
  equal(save.filename("quick"), "quick.sav", "default extension")
  return true
end function

function testFilenameExistingExtension()
  equal(save.filename("quick.SAV"), "quick.SAV", "existing extension")
  return true
end function

function testFilenameParentRejected()
  value = try(save.filename("../quick"))
  yes(value is error, "parent path")
  return true
end function

function testFilenameSeparatorRejected()
  value = try(save.filename("dir/quick"))
  yes(value is error, "directory separator")
  return true
end function

function testByteRoundtrip()
  data = bytes(4)
  data[0] = 0x41; data[1] = 0x80; data[2] = 0xe9; data[3] = 0xff
  equal(hex(save.encodeText(save.decodeText(data))), hex(data), "save byte roundtrip")
  return true
end function

function testParsedVersion()
  equal(parsedSample().version, 5, "parsed version")
  return true
end function

function testParsedComment()
  equal(parsedSample().comment, "Start_________________kills:__2/__9", "parsed comment")
  return true
end function

function testSpawnCount()
  equal(len(parsedSample().spawnParms), c.NUM_SPAWN_PARMS, "spawn parm count")
  return true
end function

function testSpawnFloatBoundary()
  saved = parsedSample()
  value = saved.spawnParms[0]
  equal(native.floatBits(value), native.floatBits(0.100000001), "spawn binary32")
  equal(native.floatBits(saved.spawnParms[1]), 0x80000000, "spawn negative zero binary32")
  equal(qcedict.fixedSixDecimals(4097.0), "4097.000000", "stock item spawn parm text")
  equal(qcedict.fixedSixDecimals(-4097.0), "-4097.000000", "negative spawn parm text")
  return true
end function

function testLegacySkillRounding()
  equal(parsedSample().skill, 2, "1.06 float skill compatibility")
  return true
end function

function testExtendedMapName()
  equal(parsedSample().mapName, "st" + latin1(0xe9) + "rt", "map byte text")
  return true
end function

function testSavedTimeFloatBoundary()
  value = parsedSample().time
  equal(native.floatBits(value), native.floatBits(12.3456789), "saved time binary32")
  return true
end function

function testLightStyleCount()
  equal(len(parsedSample().lightStyles), c.MAX_LIGHTSTYLES, "lightstyle count")
  return true
end function

function testExtendedLightStyle()
  equal(parsedSample().lightStyles[1], latin1(0xe9), "lightstyle byte")
  return true
end function

function testGlobalBlock()
  equal(bsp.entityValue(parsedSample().globalState, "serverflags"), "3", "global block")
  return true
end function

function testEntityBlock()
  saved = parsedSample()
  equal(len(saved.entities), 1, "entity count")
  equal(bsp.entityValue(saved.entities[0], "classname"), "worldspawn", "entity classname")
  equal(bsp.entityValue(saved.entities[0], "message"), "caf" + latin1(0xe9), "entity byte value")
  return true
end function

function testInvalidVersion()
  data = save.encodeText(sampleText())
  data[0] = 54
  value = try(save.parseBytes(data))
  yes(value is error, "invalid version")
  return true
end function

function testInspectBytes()
  text = "5\nA_B_C\n"
  equal(save.inspectCommentBytes(save.encodeText(text)), "A B C", "inspect comment bytes")
  return true
end function

function main(args)
  tests = [
    ["version constant", testVersionConstant],
    ["comment length", testCommentLength],
    ["comment spaces", testCommentSpaces],
    ["comment kills", testCommentKills],
    ["extended comment", testExtendedCommentByte],
    ["display comment", testDisplayComment],
    ["filename extension", testFilenameExtension],
    ["filename existing", testFilenameExistingExtension],
    ["filename parent", testFilenameParentRejected],
    ["filename separator", testFilenameSeparatorRejected],
    ["byte roundtrip", testByteRoundtrip],
    ["parsed version", testParsedVersion],
    ["parsed comment", testParsedComment],
    ["spawn count", testSpawnCount],
    ["spawn float", testSpawnFloatBoundary],
    ["legacy skill", testLegacySkillRounding],
    ["map bytes", testExtendedMapName],
    ["saved time", testSavedTimeFloatBoundary],
    ["lightstyle count", testLightStyleCount],
    ["lightstyle bytes", testExtendedLightStyle],
    ["global block", testGlobalBlock],
    ["entity block", testEntityBlock],
    ["invalid version", testInvalidVersion],
    ["inspect bytes", testInspectBytes],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 24 then return 1 end if
  print "MiniQuake BP-033 savegame v5 tests passed: 24"
  return 0
end function
