/* BP-076: view.c camera, palette and refdef parity. */

import miniquake.view as view
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as playerMove
import miniquake.client as client
import miniquake.host as host
import miniquake.common as common
import miniquake.cvar as cvar

function yes(value, name)
  if not value then return error(10760, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(10761, name + ": expected false") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(10762, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(10763, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function testRollProportional()
  near(view.V_CalcRoll(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, -100.0, 0.0), 2.0, 200.0), 1.0, 0.00001, "roll")
  return true
end function

function testRollCap()
  near(view.V_CalcRoll(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, -400.0, 0.0), 2.0, 200.0), 2.0, 0.00001, "roll cap")
  return true
end function

function testBobIgnoresZ()
  near(view.V_CalcBob(0.0, t.Vec3(100.0, 0.0, 999.0), 0.02, 0.6, 0.5), 0.6, 0.00001, "bob")
  return true
end function

function testBobUpperClamp()
  value = view.V_CalcBob(0.25, t.Vec3(10000.0, 0.0, 0.0), 1.0, 1.0, 0.5)
  yes(value <= 4.0, "bob upper")
  return true
end function

function testBobLowerClamp()
  value = view.V_CalcBob(0.75, t.Vec3(10000.0, 0.0, 0.0), 1.0, 1.0, 0.5)
  yes(value >= -7.0, "bob lower")
  return true
end function

function testStartPitchDrift()
  state = view.create()
  state.noDrift = true
  view.V_StartPitchDrift(state, 1.0, 500.0)
  no(state.noDrift, "drift active")
  near(state.pitchVelocity, 500.0, 0.0, "drift velocity")
  return true
end function

function testStopPitchDrift()
  state = view.create()
  view.V_StopPitchDrift(state, 2.0)
  yes(state.noDrift, "drift stopped")
  near(state.lastStop, 2.0, 0.0, "last stop")
  return true
end function

function testAirborneCancelsDrift()
  state = view.create()
  state.noDrift = false
  state.pitchVelocity = 100.0
  angles = t.Vec3(20.0, 0.0, 0.0)
  view.V_DriftPitch(state, angles, 0.0, 400.0, 200.0, 0.1, 1.0, 0.15, 500.0, false, false, false)
  near(state.pitchVelocity, 0.0, 0.0, "airborne pitch velocity")
  near(angles.x, 20.0, 0.0, "airborne angle")
  return true
end function

function testPitchStep()
  state = view.create()
  state.noDrift = false
  state.pitchVelocity = 500.0
  angles = t.Vec3(20.0, 0.0, 0.0)
  view.V_DriftPitch(state, angles, 0.0, 400.0, 200.0, 0.01, 1.0, 0.15, 500.0, false, true, false)
  near(angles.x, 15.0, 0.00001, "pitch step")
  near(state.pitchVelocity, 505.0, 0.00001, "pitch acceleration")
  return true
end function

function testGammaIdentity()
  state = view.create()
  table = view.BuildGammaTable(state, 1.0)
  equal(len(table), 256, "gamma entries")
  equal(table[0], 0, "gamma zero")
  equal(table[128], 128, "gamma midpoint")
  equal(table[255], 255, "gamma max")
  return true
end function

function testGammaChangeGate()
  state = view.create()
  yes(view.V_CheckGamma(state, 0.8), "first change")
  no(view.V_CheckGamma(state, 0.8), "same ignored")
  return true
end function

function testGammaCurve()
  state = view.create()
  table = view.BuildGammaTable(state, 0.5)
  yes(table[64] > 64, "bright gamma")
  equal(table[255], 255, "gamma clamp")
  return true
end function

function testDamageMinimum()
  state = view.create()
  view.V_ParseDamage(state, 1, 0, t.Vec3(10.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.6, 0.6, 0.5)
  equal(state.cshifts[view.CSHIFT_DAMAGE][3], 30.0, "minimum damage shift")
  return true
end function

function testCshiftAtoi()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "12.75", "-7junk", "0x20", "'A"])
  equal(state.emptyCshift[0], 12.0, "decimal")
  equal(state.emptyCshift[1], -7.0, "trailing")
  equal(state.emptyCshift[2], 0.0, "hex rejected by CRT atoi")
  equal(state.emptyCshift[3], 0.0, "character rejected by CRT atoi")
  return true
end function

function testBonusFlash()
  state = view.create()
  view.V_BonusFlash_f(state)
  equal(state.cshifts[view.CSHIFT_BONUS][0], 215.0, "bonus red")
  equal(state.cshifts[view.CSHIFT_BONUS][3], 50.0, "bonus percent")
  return true
end function

function testLavaContents()
  state = view.create()
  shift = view.V_SetContentsColor(state, c.CONTENTS_LAVA)
  equal(shift[0], 255.0, "lava red")
  equal(shift[3], 150.0, "lava percent")
  return true
end function

function testPowerupPriority()
  state = view.create()
  shift = view.V_CalcPowerupCshift(state, c.IT_QUAD | c.IT_INVULNERABILITY)
  equal(shift[2], 255.0, "quad blue")
  equal(shift[3], 30.0, "quad percent")
  return true
end function

function testBlendDisabled()
  state = view.create()
  state.cshifts[view.CSHIFT_DAMAGE] = [255.0, 0.0, 0.0, 100.0]
  blend = view.V_CalcBlend(state, 0.0)
  near(blend[3], 0.0, 0.0, "disabled alpha")
  return true
end function

function testBlendActive()
  state = view.create()
  state.cshifts[view.CSHIFT_DAMAGE] = [255.0, 0.0, 0.0, 128.0]
  blend = view.V_CalcBlend(state, 100.0)
  yes(blend[0] > 0.99, "red blend")
  yes(blend[3] > 0.49 and blend[3] < 0.51, "alpha blend")
  return true
end function

function testStairSmoothing()
  state = view.create()
  player = playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.onGround = true
  view.reset(state, player.origin)
  player.origin.z = 16.0
  offset = view.smoothStairStep(state, player, 0.05)
  near(offset, -12.0, 0.00001, "stair clamp")
  return true
end function

function makeRefdefState()
  registry = host.createCvars(common.create([]), false)
  player = playerMove.create(t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 90.0, 0.0))
  player.onGround = true
  player.weapon = 1
  localClient = client.create(player)
  localClient.connected = true
  localClient.maxClients = 1
  localClient.time = 2.0
  localClient.command.viewAngles = t.Vec3(0.0, 90.0, 0.0)
  state = view.create()
  view.reset(state, player.origin)
  return [state, player, localClient, registry]
end function

function testRefdefNudge()
  values = makeRefdefState()
  view.V_RenderView(values[0], values[1], values[2], values[3], 0.02, false, false, 0, false)
  near(values[0].origin.x, 10.03125, 0.00001, "nudge x")
  near(values[0].origin.y, 20.03125, 0.00001, "nudge y")
  return true
end function

function testIntermissionRefdef()
  values = makeRefdefState()
  view.V_RenderView(values[0], values[1], values[2], values[3], 0.02, false, false, 1, false)
  yes(values[0].intermission, "intermission")
  no(values[0].viewModelVisible, "view model hidden")
  return true
end function

function main(args)
  passed = 0
  if run(1, "roll proportional", testRollProportional) then passed = passed + 1 end if
  if run(2, "roll cap", testRollCap) then passed = passed + 1 end if
  if run(3, "bob ignores z", testBobIgnoresZ) then passed = passed + 1 end if
  if run(4, "bob upper clamp", testBobUpperClamp) then passed = passed + 1 end if
  if run(5, "bob lower clamp", testBobLowerClamp) then passed = passed + 1 end if
  if run(6, "start pitch drift", testStartPitchDrift) then passed = passed + 1 end if
  if run(7, "stop pitch drift", testStopPitchDrift) then passed = passed + 1 end if
  if run(8, "airborne drift", testAirborneCancelsDrift) then passed = passed + 1 end if
  if run(9, "pitch step", testPitchStep) then passed = passed + 1 end if
  if run(10, "gamma identity", testGammaIdentity) then passed = passed + 1 end if
  if run(11, "gamma gate", testGammaChangeGate) then passed = passed + 1 end if
  if run(12, "gamma curve", testGammaCurve) then passed = passed + 1 end if
  if run(13, "damage minimum", testDamageMinimum) then passed = passed + 1 end if
  if run(14, "cshift atoi", testCshiftAtoi) then passed = passed + 1 end if
  if run(15, "bonus flash", testBonusFlash) then passed = passed + 1 end if
  if run(16, "lava contents", testLavaContents) then passed = passed + 1 end if
  if run(17, "powerup priority", testPowerupPriority) then passed = passed + 1 end if
  if run(18, "blend disabled", testBlendDisabled) then passed = passed + 1 end if
  if run(19, "blend active", testBlendActive) then passed = passed + 1 end if
  if run(20, "stair smoothing", testStairSmoothing) then passed = passed + 1 end if
  if run(21, "refdef nudge", testRefdefNudge) then passed = passed + 1 end if
  if run(22, "intermission refdef", testIntermissionRefdef) then passed = passed + 1 end if
  if passed != 22 then print "MiniQuake BP-076 view/palette tests failed: " + passed + "/22"; return 1 end if
  print "MiniQuake BP-076 view/palette tests passed: 22"
  return 0
end function
