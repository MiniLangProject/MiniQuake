/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-028: source-guided sv_user.c intention, angle and movement fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sv_user as svuser
import miniquake.server as server
import miniquake.player_move as movement
import miniquake.message as msg
import miniquake.sizebuf as sz

// Report the requested value and return the corresponding failure status.
function fail(text)
  return error(9281, text)
end function
// Assert floating-point equality within the requested tolerance.
function near(actual, expected, text)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > 0.001 then return fail(text + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert exact equality and report both values on failure.
function equal(actual, expected, text)
  if actual != expected then return fail(text + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function require(value, text)
  if not value then return fail(text) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/16] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Exercise state and command as part of this deterministic regression fixture.
function stateAndCommand()
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  svuser.SV_UserSetFrameTime(state, 0.1)
  svuser.SV_UserSetMovement(state, 320.0, 10.0, 4.0, 2.0, 100.0)
  return [game, state, game.clients[0].command]
end function
// Exercise player as part of this deterministic regression fixture.
function player()
  value = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  value.health = 100.0
  return value
end function

// Verify frame clamp high against the expected Quake behavior.
function testFrameClampHigh()
  pair = stateAndCommand()
  near(svuser.SV_UserSetFrameTime(pair[1], 1.0), 0.1, "high frame clamp")
  return true
end function
// Verify frame clamp low against the expected Quake behavior.
function testFrameClampLow()
  pair = stateAndCommand()
  near(svuser.SV_UserSetFrameTime(pair[1], -1.0), 0.0, "low frame clamp")
  return true
end function
// Verify noclip pitch projection against the expected Quake behavior.
function testNoclipPitchProjection()
  pair = stateAndCommand(); value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_NOCLIP
  value.renderAngles = t.Vec3(60.0, 0.0, 0.0)
  command.forwardMove = 100.0; command.upMove = 25.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 50.0, "pitched noclip horizontal projection")
  near(value.velocity.y, 0.0, "pitched noclip y")
  near(value.velocity.z, 25.0, "noclip upmove overrides forward z")
  return true
end function
// Verify walk pitch projection against the expected Quake behavior.
function testWalkPitchProjection()
  pair = stateAndCommand(); value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_WALK; value.onGround = true
  value.renderAngles = t.Vec3(60.0, 0.0, 0.0)
  command.forwardMove = 100.0; command.upMove = 80.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 50.0, "pitched walk projection")
  near(value.velocity.z, 0.0, "walk discards vertical intention")
  return true
end function
// Verify teleport backward gate against the expected Quake behavior.
function testTeleportBackwardGate()
  pair = stateAndCommand(); game = pair[0]; value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_NOCLIP; value.teleportTime = 2.0
  game.time = 1.0; command.forwardMove = -100.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 0.0, "teleport backward gate")
  return true
end function
// Verify noclip max speed against the expected Quake behavior.
function testNoclipMaxSpeed()
  pair = stateAndCommand(); value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_NOCLIP; command.forwardMove = 500.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 320.0, "noclip maxspeed")
  return true
end function
// Verify side move basis against the expected Quake behavior.
function testSideMoveBasis()
  pair = stateAndCommand(); value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_NOCLIP; command.sideMove = 100.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 0.0, "side basis x")
  near(value.velocity.y, -100.0, "side basis y")
  return true
end function
// Verify air acceleration cap against the expected Quake behavior.
function testAirAccelerationCap()
  pair = stateAndCommand(); value = player(); command = pair[2]
  value.moveType = c.MOVETYPE_WALK; value.onGround = false; command.forwardMove = 100.0
  svuser.SV_AirMove(pair[1], value, command, void, 1)
  near(value.velocity.x, 30.0, "air acceleration cap")
  return true
end function
// Verify idle water sink against the expected Quake behavior.
function testIdleWaterSink()
  pair = stateAndCommand(); value = player(); command = pair[2]
  svuser.SV_WaterMove(pair[1], value, command)
  near(value.velocity.z, -42.0, "idle water sink")
  return true
end function
// Verify forward water acceleration against the expected Quake behavior.
function testForwardWaterAcceleration()
  pair = stateAndCommand(); value = player(); command = pair[2]
  command.forwardMove = 100.0
  svuser.SV_WaterMove(pair[1], value, command)
  near(value.velocity.x, 70.0, "forward water acceleration")
  return true
end function
// Verify water jump active against the expected Quake behavior.
function testWaterJumpActive()
  pair = stateAndCommand(); game = pair[0]; value = player()
  value.flags = c.FL_WATERJUMP; value.waterLevel = 2; value.teleportTime = 10.0
  value.moveDir = t.Vec3(120.0, -30.0, 0.0); value.velocity.z = 5.0; game.time = 5.0
  svuser.SV_WaterJump(pair[1], value)
  equal(value.flags & c.FL_WATERJUMP, c.FL_WATERJUMP, "active waterjump flag")
  near(value.velocity.x, 120.0, "active waterjump x"); near(value.velocity.y, -30.0, "active waterjump y")
  near(value.velocity.z, 5.0, "active waterjump z preserved")
  return true
end function
// Verify water jump expired against the expected Quake behavior.
function testWaterJumpExpired()
  pair = stateAndCommand(); game = pair[0]; value = player()
  value.flags = c.FL_WATERJUMP; value.waterLevel = 2; value.teleportTime = 10.0
  value.moveDir = t.Vec3(12.0, 4.0, 0.0); game.time = 11.0
  svuser.SV_WaterJump(pair[1], value)
  equal(value.flags & c.FL_WATERJUMP, 0, "expired waterjump flag")
  near(value.teleportTime, 0.0, "expired teleport time")
  return true
end function
// Verify ideal pitch integer steps against the expected Quake behavior.
function testIdealPitchIntegerSteps()
  pair = stateAndCommand()
  pitch = svuser.SV_IdealPitchFromHeights(pair[1], [3.6, 4.8, 6.0, 7.2, 8.4, 9.6], 0)
  near(pitch, -0.8, "integer sampled ideal pitch")
  return true
end function
// Verify read client move against the expected Quake behavior.
function testReadClientMove()
  pair = stateAndCommand(); game = pair[0]; state = pair[1]
  buffer = sz.alloc(64)
  msg.writeFloat(buffer, 2.5); msg.writeByte(buffer, 64); msg.writeByte(buffer, 128); msg.writeByte(buffer, 0)
  msg.writeShort(buffer, 100); msg.writeShort(buffer, -50); msg.writeShort(buffer, 25)
  msg.writeByte(buffer, 3); msg.writeByte(buffer, 7)
  clientValue = server.createServerClient(0); value = player(); game.time = 5.0
  svuser.SV_ReadClientMove(state, msg.beginReading(buffer), clientValue, value)
  near(clientValue.pingTimes[0], 2.5, "move ping")
  near(value.viewAngles.x, 90.0, "move angle x"); near(value.viewAngles.y, -180.0, "move angle y signed char")
  near(clientValue.command.forwardMove, 100.0, "move forward")
  equal(clientValue.command.buttons, 3, "move buttons"); equal(clientValue.command.impulse, 7, "move impulse")
  return true
end function
// Verify client think angles against the expected Quake behavior.
function testClientThinkAngles()
  pair = stateAndCommand(); value = player(); clientValue = pair[0].clients[0]
  value.moveType = c.MOVETYPE_NOCLIP; value.viewAngles = t.Vec3(30.0, 40.0, 0.0)
  svuser.SV_ClientThink(pair[1], clientValue, value, void)
  near(value.renderAngles.x, -10.0, "render pitch third")
  near(value.renderAngles.y, 40.0, "render yaw")
  return true
end function
// Verify punch decay against the expected Quake behavior.
function testPunchDecay()
  pair = stateAndCommand(); value = player(); value.punchAngle = t.Vec3(3.0, 4.0, 0.0)
  svuser.SV_UserSetFrameTime(pair[1], 0.05); svuser.DropPunchAngle(pair[1], value)
  near(value.punchAngle.x, 2.7, "punch x"); near(value.punchAngle.y, 3.6, "punch y")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed = 0
  if run(1,"frame clamp high",testFrameClampHigh) then passed=passed+1 else return 1 end if
  if run(2,"frame clamp low",testFrameClampLow) then passed=passed+1 else return 1 end if
  if run(3,"noclip pitch projection",testNoclipPitchProjection) then passed=passed+1 else return 1 end if
  if run(4,"walk pitch projection",testWalkPitchProjection) then passed=passed+1 else return 1 end if
  if run(5,"teleport backward gate",testTeleportBackwardGate) then passed=passed+1 else return 1 end if
  if run(6,"noclip maxspeed",testNoclipMaxSpeed) then passed=passed+1 else return 1 end if
  if run(7,"side movement basis",testSideMoveBasis) then passed=passed+1 else return 1 end if
  if run(8,"air acceleration cap",testAirAccelerationCap) then passed=passed+1 else return 1 end if
  if run(9,"idle water sink",testIdleWaterSink) then passed=passed+1 else return 1 end if
  if run(10,"forward water acceleration",testForwardWaterAcceleration) then passed=passed+1 else return 1 end if
  if run(11,"waterjump active",testWaterJumpActive) then passed=passed+1 else return 1 end if
  if run(12,"waterjump expired",testWaterJumpExpired) then passed=passed+1 else return 1 end if
  if run(13,"ideal pitch integer steps",testIdealPitchIntegerSteps) then passed=passed+1 else return 1 end if
  if run(14,"read client move",testReadClientMove) then passed=passed+1 else return 1 end if
  if run(15,"client think angles",testClientThinkAngles) then passed=passed+1 else return 1 end if
  if run(16,"punch decay",testPunchDecay) then passed=passed+1 else return 1 end if
  print "MiniQuake BP-028 sv_user movement tests passed: " + passed
  return 0
end function
