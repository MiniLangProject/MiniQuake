/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-078: sbar.c scoreboard, face, inventory and intermission parity.
*/
import miniquake.statusbar as sbar
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as playerMove

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(10780, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(10781, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(10782, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(10783, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/23] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify height against the expected Quake behavior.
function testHeight()
  equal(sbar.SBAR_HEIGHT, 24, "statusbar height")
  return true
end function

// Verify scale minimum against the expected Quake behavior.
function testScaleMinimum()
  near(sbar.scaleFor(320, 200), 1.0, 0.0, "minimum scale")
  return true
end function

// Verify scale wide against the expected Quake behavior.
function testScaleWide()
  near(sbar.scaleFor(1920, 1080), 3.0, 0.0, "wide scale")
  return true
end function

// Verify itoa negative against the expected Quake behavior.
function testItoaNegative()
  value = sbar.Sbar_itoa(-1234)
  equal(value[0], "-1234", "negative text")
  equal(value[1], 5, "negative length")
  return true
end function

// Verify itoa zero against the expected Quake behavior.
function testItoaZero()
  value = sbar.Sbar_itoa(0)
  equal(value[0], "0", "zero text")
  equal(value[1], 1, "zero length")
  return true
end function

// Verify itoa positive against the expected Quake behavior.
function testItoaPositive()
  value = sbar.Sbar_itoa(9876)
  equal(value[0], "9876", "positive text")
  equal(value[1], 4, "positive length")
  return true
end function

// Verify color for map against the expected Quake behavior.
function testColorForMap()
  equal(sbar.Sbar_ColorForMap(0), 8, "color zero")
  equal(sbar.Sbar_ColorForMap(112), 120, "color offset")
  return true
end function

// Verify sort excludes empty against the expected Quake behavior.
function testSortExcludesEmpty()
  scores = [
    t.ClientScore("alpha", 0.0, 1, 0),
    t.ClientScore("", 0.0, 99, 0),
    t.ClientScore("bravo", 0.0, 2, 0),
  ]
  order = sbar.Sbar_SortFrags(scores)
  equal(len(order), 2, "nonempty lines")
  return true
end function

// Verify sort descending against the expected Quake behavior.
function testSortDescending()
  scores = [
    t.ClientScore("alpha", 0.0, 1, 0),
    t.ClientScore("bravo", 0.0, 3, 0),
    t.ClientScore("charlie", 0.0, 2, 0),
  ]
  order = sbar.Sbar_SortFrags(scores)
  equal(order[0], 1, "first")
  equal(order[1], 2, "second")
  equal(order[2], 0, "third")
  return true
end function

// Verify sort stable tie against the expected Quake behavior.
function testSortStableTie()
  scores = [
    t.ClientScore("alpha", 0.0, 2, 0),
    t.ClientScore("bravo", 0.0, 2, 0),
  ]
  order = sbar.Sbar_SortFrags(scores)
  equal(order[0], 0, "stable first")
  equal(order[1], 1, "stable second")
  return true
end function

// Verify show scores against the expected Quake behavior.
function testShowScores()
  sbar.Sbar_DontShowScores()
  sbar.Sbar_ShowScores()
  state = sbar.Sbar_DifferentialState()
  yes(state[1], "show scores")
  return true
end function

// Verify dont show scores against the expected Quake behavior.
function testDontShowScores()
  sbar.Sbar_ShowScores()
  sbar.Sbar_DontShowScores()
  state = sbar.Sbar_DifferentialState()
  no(state[1], "hide scores")
  return true
end function

// Verify changed against the expected Quake behavior.
function testChanged()
  sbar.Sbar_DifferentialSetState(9, false, false, false, 0.0)
  sbar.Sbar_Changed()
  state = sbar.Sbar_DifferentialState()
  equal(state[0], 0, "updates reset")
  return true
end function

// Verify face combined against the expected Quake behavior.
function testFaceCombined()
  equal(sbar.faceNameFor(c.IT_INVISIBILITY | c.IT_INVULNERABILITY, 100), "face_inv2", "combined face")
  return true
end function

// Verify face quad against the expected Quake behavior.
function testFaceQuad()
  equal(sbar.faceNameFor(c.IT_QUAD, 100), "face_quad", "quad face")
  return true
end function

// Verify face health bands against the expected Quake behavior.
function testFaceHealthBands()
  equal(sbar.faceNameFor(0, 80), "face1", "healthy")
  equal(sbar.faceNameFor(0, 60), "face2", "hurt")
  equal(sbar.faceNameFor(0, 40), "face3", "wounded")
  equal(sbar.faceNameFor(0, 20), "face4", "critical")
  equal(sbar.faceNameFor(0, 19), "face5", "dying")
  return true
end function

// Verify armor priority against the expected Quake behavior.
function testArmorPriority()
  equal(sbar.armorName(c.IT_ARMOR1 | c.IT_ARMOR3), "sb_armor3", "armor priority")
  return true
end function

// Verify ammo priority against the expected Quake behavior.
function testAmmoPriority()
  equal(sbar.ammoName(c.IT_SHELLS | c.IT_NAILS), "sb_shells", "ammo priority")
  return true
end function

// Verify rogue armor against the expected Quake behavior.
function testRogueArmor()
  equal(sbar.rogueArmorName(c.RIT_ARMOR1 | c.RIT_ARMOR2), "sb_armor2", "rogue armor")
  return true
end function

// Verify rogue ammo against the expected Quake behavior.
function testRogueAmmo()
  equal(sbar.rogueAmmoName(c.RIT_LAVA_NAILS), "r_ammolava", "rogue lava ammo")
  equal(sbar.rogueAmmoName(c.RIT_PLASMA_AMMO), "r_ammomulti", "rogue plasma ammo")
  equal(sbar.rogueAmmoName(c.RIT_MULTI_ROCKETS), "r_ammoplasma", "rogue multi rockets")
  return true
end function

// Verify flash names against the expected Quake behavior.
function testFlashNames()
  equal(sbar.flashWeaponName("", "shotgun", 0), "inv_shotgun", "normal weapon")
  equal(sbar.flashWeaponName("", "shotgun", 1), "inv2_shotgun", "active weapon")
  equal(sbar.flashWeaponName("", "shotgun", 4), "inva3_shotgun", "flash weapon")
  return true
end function

// Verify zero lines draw gate against the expected Quake behavior.
function testZeroLinesDrawGate()
  sbar.Sbar_Configure(void, 1, void, void, 640, 480, 0, 0.0)
  sbar.Sbar_SetFrameState(0.0, 3)
  no(sbar.Sbar_Draw(), "no player draw")
  return true
end function

// Verify buffered page counter redraws against the expected Quake behavior.
function testBufferedPageCounterRedraws()
  sbar.Sbar_DifferentialReset([])
  player = playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 100.0
  player.ammo = 25.0
  player.shells = 25.0
  player.items = c.IT_SHOTGUN | c.IT_SHELLS
  player.activeWeapon = c.IT_SHOTGUN
  sbar.Sbar_Configure(void, 1, player, void, 640, 480, 48, 0.0)
  sbar.Sbar_SetFrameState(0.0, 3)
  yes(sbar.Sbar_Draw(), "page one")
  yes(sbar.Sbar_Draw(), "page two")
  yes(sbar.Sbar_Draw(), "page three")
  yes(sbar.Sbar_Draw(), "redraw after buffered pages")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed = 0
  if run(1, "statusbar height", testHeight) then passed = passed + 1 end if
  if run(2, "minimum scale", testScaleMinimum) then passed = passed + 1 end if
  if run(3, "wide scale", testScaleWide) then passed = passed + 1 end if
  if run(4, "itoa negative", testItoaNegative) then passed = passed + 1 end if
  if run(5, "itoa zero", testItoaZero) then passed = passed + 1 end if
  if run(6, "itoa positive", testItoaPositive) then passed = passed + 1 end if
  if run(7, "palette map", testColorForMap) then passed = passed + 1 end if
  if run(8, "exclude empty scores", testSortExcludesEmpty) then passed = passed + 1 end if
  if run(9, "sort descending", testSortDescending) then passed = passed + 1 end if
  if run(10, "stable tie", testSortStableTie) then passed = passed + 1 end if
  if run(11, "show scores", testShowScores) then passed = passed + 1 end if
  if run(12, "hide scores", testDontShowScores) then passed = passed + 1 end if
  if run(13, "changed", testChanged) then passed = passed + 1 end if
  if run(14, "combined face", testFaceCombined) then passed = passed + 1 end if
  if run(15, "quad face", testFaceQuad) then passed = passed + 1 end if
  if run(16, "health bands", testFaceHealthBands) then passed = passed + 1 end if
  if run(17, "armor priority", testArmorPriority) then passed = passed + 1 end if
  if run(18, "ammo priority", testAmmoPriority) then passed = passed + 1 end if
  if run(19, "rogue armor", testRogueArmor) then passed = passed + 1 end if
  if run(20, "rogue ammo", testRogueAmmo) then passed = passed + 1 end if
  if run(21, "weapon flash names", testFlashNames) then passed = passed + 1 end if
  if run(22, "draw gate", testZeroLinesDrawGate) then passed = passed + 1 end if
  if run(23, "hardware backbuffer redraw", testBufferedPageCounterRedraws) then passed = passed + 1 end if
  if passed != 23 then print "MiniQuake BP-078 statusbar/scoreboard tests failed: " + passed + "/23"; return 1 end if
  print "MiniQuake BP-078 statusbar/scoreboard tests passed: 23"
  return 0
end function
