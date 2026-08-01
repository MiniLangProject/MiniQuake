import miniquake.game_profile as profile
import miniquake.common as common
import miniquake.launch as launch
import miniquake.game_validation as validation

passed = 0
failed = 0

function bp085Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; return true end if
  print "FAIL: " + label
  failed = failed + 1
  return false
end function

function bp085Equal(actual, expected, label)
  return bp085Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

function main(args)
  global passed, failed
  print "[1/22] status"
  bp085Equal(profile.STATUS, "game_profile_109_frozen_v1", "status")
  print "[2/22] fingerprint"
  bp085Equal(profile.FINGERPRINT, 0x7a03b68d, "fingerprint")

  base = common.create([])
  print "[3/22] default directories"
  bp085Equal(len(profile.requestedDirectories(base)), 1, "default count")
  print "[4/22] default id1"
  bp085Equal(profile.effectiveGameDirectory(base), "id1", "default game")
  print "[5/22] default mission mode"
  bp085Equal(profile.missionMode(base), "id1", "default mode")

  rogue = common.create(["-rogue"])
  print "[6/22] rogue directory"
  bp085Equal(profile.effectiveGameDirectory(rogue), "rogue", "rogue game")
  print "[7/22] rogue mode"
  bp085Equal(profile.missionMode(rogue), "rogue", "rogue mode")

  hipnotic = common.create(["-hipnotic"])
  print "[8/22] hipnotic directory"
  bp085Equal(profile.effectiveGameDirectory(hipnotic), "hipnotic", "hipnotic game")
  print "[9/22] hipnotic classification"
  bp085Check(profile.isMissionPack("HIPNOTIC"), "hipnotic classification")

  both = common.create(["-rogue", "-hipnotic"])
  bothDirs = profile.requestedDirectories(both)
  print "[10/22] combined directory count"
  bp085Equal(len(bothDirs), 3, "combined count")
  print "[11/22] combined addition order"
  bp085Check(bothDirs[0] == "id1" and bothDirs[1] == "rogue" and bothDirs[2] == "hipnotic", "combined order")
  print "[12/22] combined effective game"
  bp085Equal(profile.effectiveGameDirectory(both), "hipnotic", "combined game")
  print "[13/22] combined mission mode"
  bp085Equal(profile.missionMode(both), "rogue+hipnotic", "combined mode")

  custom = common.create(["-rogue", "-hipnotic", "-game", "my_mod"])
  customDirs = profile.requestedDirectories(custom)
  print "[14/22] explicit game appended"
  bp085Equal(customDirs[3], "my_mod", "custom appended")
  print "[15/22] explicit game effective"
  bp085Equal(profile.effectiveGameDirectory(custom), "my_mod", "custom effective")
  print "[16/22] explicit game value"
  bp085Equal(profile.explicitGame(custom), "my_mod", "explicit value")
  expectedSearch = profile.expectedSearchDirectoryNames(custom)
  print "[17/22] generated search precedence"
  bp085Check(expectedSearch[0] == "my_mod" and expectedSearch[1] == "hipnotic" and expectedSearch[2] == "rogue" and expectedSearch[3] == "id1", "search precedence")

  pathLine = common.create(["-path", "loose", "pak2.pak", "+map", "start"])
  override = profile.pathOverride(pathLine)
  print "[18/22] path override values"
  bp085Check(len(override) == 2 and override[0] == "loose" and override[1] == "pak2.pak", "path values")
  overrideSearch = profile.expectedSearchDirectoryNames(pathLine)
  print "[19/22] path override precedence"
  bp085Check(overrideSearch[0] == "pak2.pak" and overrideSearch[1] == "loose", "path precedence")

  proghack = profile.profileVector(common.create(["-proghack"]))
  print "[20/22] proghack flag"
  bp085Check(proghack[7], "proghack")

  parsed = launch.parse([
    "--validate-game", "C:/Quake", "start",
    "-rogue", "-hipnotic", "-game", "my_mod",
    "-cachedir", "C:/Cache", "-proghack",
    "-path", "loose", "pak2.pak", "+map", "start",
  ])
  filesystemArgs = validation.filesystemArguments(parsed)
  print "[21/22] validation preserves profile"
  bp085Check(
    len(filesystemArgs) == 12 and
    filesystemArgs[2] == "-rogue" and
    filesystemArgs[3] == "-hipnotic" and
    filesystemArgs[4] == "-game" and filesystemArgs[5] == "my_mod" and
    filesystemArgs[6] == "-cachedir" and filesystemArgs[7] == "C:/Cache" and
    filesystemArgs[8] == "-proghack" and
    filesystemArgs[9] == "-path" and filesystemArgs[10] == "loose" and filesystemArgs[11] == "pak2.pak",
    "validation profile",
  )
  print "[22/22] contract text"
  bp085Check(len(bytes(profile.CONTRACT_TEXT)) > 32, "contract text")

  if failed > 0 then print "MiniQuake BP-085 game-profile tests failed: " + failed + "/22"; return 1 end if
  print "MiniQuake BP-085 game-profile tests passed: 22"
  return 0
end function
