/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-036: WinQuake view.c state, cshift, damage and refdef helpers.
*/
import miniquake.view as view
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as playerMove
import miniquake.chase as chase

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3600, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(3601, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3602, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3603, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify roll cap against the expected Quake behavior.
function testRollCap()
  value = view.V_CalcRoll(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, -400.0, 0.0), 2.0, 200.0)
  near(value, 2.0, 0.000001, "roll cap")
  return true
end function

// Verify roll scale against the expected Quake behavior.
function testRollScale()
  value = view.V_CalcRoll(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, -100.0, 0.0), 2.0, 200.0)
  near(value, 1.0, 0.000001, "roll scale")
  return true
end function

// Verify bob zero cycle against the expected Quake behavior.
function testBobZeroCycle()
  near(view.V_CalcBob(1.0, t.Vec3(100.0, 0.0, 0.0), 0.02, 0.0, 0.5), 0.0, 0.0, "zero bob cycle")
  return true
end function

// Verify bob upper clamp against the expected Quake behavior.
function testBobUpperClamp()
  value = view.V_CalcBob(0.25, t.Vec3(10000.0, 0.0, 0.0), 1.0, 1.0, 0.5)
  yes(value <= 4.0, "bob upper clamp")
  return true
end function

// Verify start pitch drift against the expected Quake behavior.
function testStartPitchDrift()
  state = view.create()
  state.noDrift = true
  view.V_StartPitchDrift(state, 1.0, 500.0)
  no(state.noDrift, "drift starts")
  near(state.pitchVelocity, 500.0, 0.0, "center speed")
  return true
end function

// Verify stop pitch drift against the expected Quake behavior.
function testStopPitchDrift()
  state = view.create()
  view.V_StopPitchDrift(state, 2.0)
  yes(state.noDrift, "drift stops")
  near(state.lastStop, 2.0, 0.0, "last stop")
  return true
end function

// Verify airborne cancels drift against the expected Quake behavior.
function testAirborneCancelsDrift()
  state = view.create()
  state.noDrift = false
  state.pitchVelocity = 100.0
  angles = t.Vec3(20.0, 0.0, 0.0)
  view.V_DriftPitch(state, angles, 0.0, 400.0, 200.0, 0.1, 1.0, 0.5, 500.0, false, false, false)
  near(state.pitchVelocity, 0.0, 0.0, "airborne drift velocity")
  near(angles.x, 20.0, 0.0, "airborne angle unchanged")
  return true
end function

// Verify gamma identity against the expected Quake behavior.
function testGammaIdentity()
  state = view.create()
  table = view.BuildGammaTable(state, 1.0)
  equal(table[0], 0, "gamma zero")
  equal(table[128], 128, "gamma midpoint")
  equal(table[255], 255, "gamma max")
  return true
end function

// Verify gamma change gate against the expected Quake behavior.
function testGammaChangeGate()
  state = view.create()
  yes(view.V_CheckGamma(state, 0.8), "first gamma change")
  no(view.V_CheckGamma(state, 0.8), "same gamma ignored")
  return true
end function

// Verify damage minimum and armor color against the expected Quake behavior.
function testDamageMinimumAndArmorColor()
  state = view.create()
  view.V_ParseDamage(state, 1, 0, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.6, 0.6, 0.5)
  equal(state.cshifts[view.CSHIFT_DAMAGE][0], 200.0, "armor color red")
  equal(state.cshifts[view.CSHIFT_DAMAGE][3], 30.0, "minimum damage percent")
  return true
end function

// Verify damage blood color against the expected Quake behavior.
function testDamageBloodColor()
  state = view.create()
  view.V_ParseDamage(state, 0, 20, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.6, 0.6, 0.5)
  equal(state.cshifts[view.CSHIFT_DAMAGE][0], 255.0, "blood red")
  equal(state.cshifts[view.CSHIFT_DAMAGE][1], 0.0, "blood green")
  return true
end function

// Verify cshift atoi against the expected Quake behavior.
function testCshiftAtoi()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "12.75", "-7junk", "0x20", "'A"])
  equal(state.emptyCshift[0], 12.0, "decimal truncation")
  equal(state.emptyCshift[1], -7.0, "trailing text")
  equal(state.emptyCshift[2], 0.0, "hex rejected by CRT atoi")
  equal(state.emptyCshift[3], 0.0, "character rejected by CRT atoi")
  return true
end function

// Verify cshift missing arguments against the expected Quake behavior.
function testCshiftMissingArguments()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "9"])
  equal(state.emptyCshift[0], 9.0, "first cshift")
  equal(state.emptyCshift[3], 0.0, "missing cshift")
  return true
end function

// Verify bonus flash against the expected Quake behavior.
function testBonusFlash()
  state = view.create()
  view.V_BonusFlash_f(state)
  equal(state.cshifts[view.CSHIFT_BONUS][0], 215.0, "bonus red")
  equal(state.cshifts[view.CSHIFT_BONUS][3], 50.0, "bonus percent")
  return true
end function

// Verify contents lava against the expected Quake behavior.
function testContentsLava()
  state = view.create()
  shift = view.V_SetContentsColor(state, c.CONTENTS_LAVA)
  equal(shift[0], 255.0, "lava red")
  equal(shift[3], 150.0, "lava percent")
  return true
end function

// Verify contents empty uses configured shift against the expected Quake behavior.
function testContentsEmptyUsesConfiguredShift()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "1", "2", "3", "4"])
  shift = view.V_SetContentsColor(state, c.CONTENTS_EMPTY)
  equal(shift[0], 1.0, "empty red")
  equal(shift[3], 4.0, "empty percent")
  return true
end function

// Verify powerup priority against the expected Quake behavior.
function testPowerupPriority()
  state = view.create()
  shift = view.V_CalcPowerupCshift(state, c.IT_QUAD | c.IT_INVULNERABILITY)
  equal(shift[2], 255.0, "quad blue")
  equal(shift[3], 30.0, "quad percent")
  return true
end function

// Verify blend disabled against the expected Quake behavior.
function testBlendDisabled()
  state = view.create()
  state.cshifts[view.CSHIFT_DAMAGE] = [255.0, 0.0, 0.0, 100.0]
  blend = view.V_CalcBlend(state, 0.0)
  near(blend[3], 0.0, 0.0, "disabled alpha")
  return true
end function

// Verify palette decay order against the expected Quake behavior.
function testPaletteDecayOrder()
  state = view.create()
  state.oldGamma = 1.0
  state.cshifts[view.CSHIFT_DAMAGE] = [255.0, 0.0, 0.0, 100.0]
  yes(view.V_UpdatePalette(state, 0, 0.1, 100.0, 1.0), "first palette change")
  equal(state.cshifts[view.CSHIFT_DAMAGE][3], 85.0, "damage decay")
  return true
end function

// Verify intermission hides weapon against the expected Quake behavior.
function testIntermissionHidesWeapon()
  state = view.create()
  player = playerMove.create(t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.0, 90.0, 0.0))
  view.V_CalcIntermissionRefdef(state, player, 1.0, 2.0, 0.5, 1.0, 0.3, 0.1, 0.3)
  yes(state.intermission, "intermission state")
  no(state.viewModelVisible, "intermission weapon hidden")
  near(state.origin.x, 1.0, 0.0, "intermission origin")
  return true
end function


// Verify chase preserves yaw roll against the expected Quake behavior.
function testChasePreservesYawRoll()
  state = chase.create()
  state.active = true
  result = chase.Chase_UpdateRefdef(
    state,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(11.0, 123.0, 7.0),
    void,
  )
  near(result[1].y, 123.0, 0.0, "chase yaw")
  near(result[1].z, 7.0, 0.0, "chase roll")
  return true
end function

// Verify chase destination against the expected Quake behavior.
function testChaseDestination()
  state = chase.create()
  state.back = 100.0
  state.right = 0.0
  state.up = 16.0
  result = chase.Chase_UpdateRefdef(
    state,
    t.Vec3(10.0, 20.0, 30.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    void,
  )
  near(result[0].x, -90.0, 0.00001, "chase back")
  near(result[0].z, 46.0, 0.00001, "chase up")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  tests = [
    ["roll cap", testRollCap],
    ["roll scale", testRollScale],
    ["bob zero cycle", testBobZeroCycle],
    ["bob upper clamp", testBobUpperClamp],
    ["start pitch drift", testStartPitchDrift],
    ["stop pitch drift", testStopPitchDrift],
    ["airborne drift", testAirborneCancelsDrift],
    ["gamma identity", testGammaIdentity],
    ["gamma gate", testGammaChangeGate],
    ["damage minimum", testDamageMinimumAndArmorColor],
    ["damage blood", testDamageBloodColor],
    ["cshift atoi", testCshiftAtoi],
    ["cshift missing", testCshiftMissingArguments],
    ["bonus flash", testBonusFlash],
    ["contents lava", testContentsLava],
    ["contents empty", testContentsEmptyUsesConfiguredShift],
    ["powerup priority", testPowerupPriority],
    ["blend disabled", testBlendDisabled],
    ["palette decay", testPaletteDecayOrder],
    ["intermission view", testIntermissionHidesWeapon],
    ["chase preserves yaw roll", testChasePreservesYawRoll],
    ["chase destination", testChaseDestination],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 22 then return 1 end if
  print "MiniQuake BP-036 view state tests passed: 22"
  return 0
end function
