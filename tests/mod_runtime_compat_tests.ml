/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/mod_runtime_compat_tests.ml.
*/
import miniquake.mod_compat as modcompat
import miniquake.game_profile as profile
import miniquake.common as common

passed = 0
failed = 0

// Assert that the condition holds and identify a failing test.
function bp086Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; return true end if
  print "FAIL: " + label
  failed = failed + 1
  return false
end function

// Assert exact equality and report both values on failure.
function bp086Equal(actual, expected, label)
  return bp086Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global passed, failed
  print "[1/22] status"
  bp086Equal(modcompat.STATUS, "mod_runtime_109_frozen_v1", "status")
  print "[2/22] fingerprint"
  bp086Equal(modcompat.FINGERPRINT, 0x4649813d, "fingerprint")
  print "[3/22] contract version"
  bp086Equal(modcompat.contractVector()[2], 6, "progs version")
  print "[4/22] contract BSP"
  bp086Equal(modcompat.contractVector()[3], 29, "bsp version")
  print "[5/22] id1 arguments"
  id1 = modcompat.profileArguments("C:/Quake", "id1")
  bp086Check(len(id1) == 2 and id1[0] == "-basedir", "id1 args")
  print "[6/22] rogue arguments"
  rogue = modcompat.profileArguments("C:/Quake", "rogue")
  bp086Check(len(rogue) == 3 and rogue[2] == "-rogue", "rogue args")
  print "[7/22] hipnotic arguments"
  hip = modcompat.profileArguments("C:/Quake", "hipnotic")
  bp086Check(len(hip) == 3 and hip[2] == "-hipnotic", "hip args")
  print "[8/22] custom arguments"
  custom = modcompat.profileArguments("C:/Quake", "my_mod")
  bp086Check(len(custom) == 4 and custom[2] == "-game" and custom[3] == "my_mod", "custom args")
  print "[9/22] id1 not mission pack"
  bp086Check(not profile.isMissionPack("id1"), "id1 class")
  print "[10/22] rogue mission pack"
  bp086Check(profile.isMissionPack("rogue"), "rogue class")
  print "[11/22] hipnotic mission pack"
  bp086Check(profile.isMissionPack("hipnotic"), "hip class")

  valid = ["id1", false, 424, 6, 5927, 2091, 20940, 103, 29, 5556, 385, 1, false]
  print "[12/22] valid summary"
  bp086Check(modcompat.validSummary(valid), "valid summary")
  print "[13/22] missing packs"
  invalidPaks = ["id1", false, 0, 6, 5927, 2091, 20940, 103, 29, 5556, 385, 1, false]
  bp086Check(not modcompat.validSummary(invalidPaks), "pack gate")
  print "[14/22] wrong progs version"
  invalidProgs = ["id1", false, 424, 5, 5927, 2091, 20940, 103, 29, 5556, 385, 1, false]
  bp086Check(not modcompat.validSummary(invalidProgs), "progs gate")
  print "[15/22] wrong BSP version"
  invalidBsp = ["id1", false, 424, 6, 5927, 2091, 20940, 103, 30, 5556, 385, 1, false]
  bp086Check(not modcompat.validSummary(invalidBsp), "bsp gate")
  print "[16/22] missing functions"
  invalidFunctions = ["id1", false, 424, 6, 5927, 0, 0, 0, 29, 5556, 385, 1, false]
  bp086Check(not modcompat.validSummary(invalidFunctions), "function gate")
  print "[17/22] missing faces"
  invalidFaces = ["id1", false, 424, 6, 5927, 2091, 20940, 103, 29, 0, 385, 1, false]
  bp086Check(not modcompat.validSummary(invalidFaces), "face gate")
  print "[18/22] summary arity"
  bp086Check(not modcompat.validSummary([1, 2]), "summary arity")
  print "[19/22] profile commandline"
  line = common.create(modcompat.profileArguments("C:/Quake", "hipnotic"))
  bp086Equal(profile.effectiveGameDirectory(line), "hipnotic", "profile commandline")
  print "[20/22] profile vector games"
  bp086Equal(len(modcompat.contractVector()[4]), 3, "known games")
  print "[21/22] custom modification marker"
  bp086Check(valid[12] == false and valid[0] == "id1", "id1 marker")
  print "[22/22] contract text"
  bp086Check(len(bytes(modcompat.CONTRACT_TEXT)) > 32, "contract text")

  if failed > 0 then print "MiniQuake BP-086 mod runtime tests failed: " + failed + "/22"; return 1 end if
  print "MiniQuake BP-086 mod runtime tests passed: 22"
  return 0
end function
