/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused view.c differential-math and command-trace fixtures.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.common as common
import miniquake.host as host
import miniquake.client as client
import miniquake.player_move as movement
import miniquake.cvar as cvar
import miniquake.view as view

function assertEqual(actual, expected, name)
  if actual != expected then return error(9400, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertNear(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9401, name + ": expected " + expected + " +/- " + tolerance + ", got " + actual) end if
  return true
end function

function testRollAndBob()
  angles = t.Vec3(0.0, 0.0, 0.0)
  assertNear(view.V_CalcRoll(angles, t.Vec3(0.0, 100.0, 0.0), 2.0, 200.0), -1.0, 0.00001, "V_CalcRoll proportional side")
  assertNear(view.V_CalcRoll(angles, t.Vec3(0.0, -500.0, 0.0), 2.0, 200.0), 2.0, 0.00001, "V_CalcRoll clamp")
  assertNear(view.V_CalcBob(0.0, t.Vec3(100.0, 0.0, 999.0), 0.02, 0.6, 0.5), 0.6, 0.00001, "V_CalcBob ignores vertical velocity")
  return true
end function

function testDamageAndPalette()
  state = view.create()
  view.V_ParseDamage(
    state,
    20,
    5,
    t.Vec3(0.0, -10.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    0.6,
    0.6,
    0.5,
  )
  assertNear(state.cshifts[1][3], 37.0, 0.00001, "damage cshift percent")
  assertEqual(state.cshifts[1][0], 200.0, "armor-dominant red")
  assertEqual(state.cshifts[1][1], 100.0, "armor-dominant green")
  assertNear(state.damageRoll, 7.5, 0.00001, "damage roll projection")
  assertNear(state.damageTime, 0.5, 0.00001, "damage kick time")

  view.V_BonusFlash_f(state)
  assertEqual(state.cshifts[2][0], 215.0, "bonus flash color")
  view.V_cshift_f(state, ["v_cshift", "1", "2", "3", "4"])
  view.V_SetContentsColor(state, c.CONTENTS_WATER)
  view.V_SetContentsColor(state, c.CONTENTS_EMPTY)
  assertEqual(state.cshifts[0][0], 1.0, "custom empty cshift survives water")
  assertEqual(state.cshifts[0][3], 4.0, "custom empty cshift percent")

  view.V_CalcPowerupCshift(state, c.IT_QUAD | c.IT_INVULNERABILITY)
  assertEqual(state.cshifts[3][2], 255.0, "quad has powerup priority")
  updated = view.V_UpdatePalette(state, c.IT_QUAD, 0.1, 100.0, 1.0)
  assertEqual(updated, true, "first palette update")
  assertNear(state.cshifts[1][3], 22.0, 0.00001, "damage palette decay")
  assertNear(state.cshifts[2][3], 40.0, 0.00001, "bonus palette decay")
  assertEqual(len(state.gammaTable), 256, "gamma table size")
  return true
end function

function testPitchDrift()
  state = view.create()
  angles = t.Vec3(20.0, 0.0, 0.0)
  view.V_StartPitchDrift(state, 1.0, 500.0)
  view.V_DriftPitch(state, angles, 0.0, 0.0, 200.0, 0.01, 1.0, 0.15, 500.0, false, true, false)
  assertNear(angles.x, 15.0, 0.00001, "pitch drift first step")
  assertNear(state.pitchVelocity, 505.0, 0.00001, "pitch drift acceleration")
  view.V_StopPitchDrift(state, 1.01)
  assertEqual(state.noDrift, true, "pitch drift stop")
  return true
end function

function testRefdefAndTrace()
  registry = host.createCvars(common.create([]), false)
  player = movement.create(t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 90.0, 0.0))
  player.onGround = true
  player.weapon = 1
  localClient = client.create(player)
  localClient.connected = true
  localClient.maxClients = 1
  localClient.serverTime = 2.0
  localClient.time = 2.0
  localClient.command.viewAngles = t.Vec3(0.0, 90.0, 0.0)

  state = view.create()
  view.reset(state, player.origin)
  view.V_RenderView(state, player, localClient, registry, 0.02, false, false, 0, false)
  assertNear(state.origin.x, 10.03125, 0.00001, "refdef BSP-plane x nudge")
  assertNear(state.origin.y, 20.03125, 0.00001, "refdef BSP-plane y nudge")
  assertNear(state.gunOrigin.z, 54.0, 0.00001, "100-percent viewsize gun fudge")
  assertEqual(state.commandTrace[0][0], "V_CalcRefdef", "normal refdef trace")
  assertEqual(state.commandTrace[1][0], "R_PushDlights", "dlight trace")
  assertEqual(state.commandTrace[2][0], "R_RenderView", "render trace")

  view.V_RenderView(state, player, localClient, registry, 0.02, false, false, 1, false)
  assertEqual(state.intermission, true, "intermission refdef")
  assertEqual(state.viewModelVisible, false, "intermission hides weapon")
  assertEqual(state.commandTrace[0][0], "V_CalcIntermissionRefdef", "intermission trace")

  localClient.maxClients = 2
  cvar.set(registry, "scr_ofsx", "100")
  view.V_RenderView(state, player, localClient, registry, 0.02, false, false, 0, false)
  assertNear(cvar.variableValue(registry, "scr_ofsx"), 0.0, 0.00001, "multiplayer offset cheat reset")
  return true
end function

function main(args)
  testRollAndBob()
  testDamageAndPalette()
  testPitchDrift()
  testRefdefAndTrace()
  print "View parity tests: 4/4 passed"
  return 0
end function
