/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-029 source-guided sv_user.c command, movement and gate fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sv_user as svuser
import miniquake.server as server
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.mathlib as math
import miniquake.native as native

struct SvUserTestMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Assert exact equality and report both values on failure.
function svuTestEqual(actual, expected, name)
  if actual != expected then return error(9970, name + ": got " + actual + " expected " + expected) end if
  return true
end function

// Exercise svu test true as part of this deterministic regression fixture.
function svuTestTrue(value, name)
  if value != true then return error(9971, name) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function svuTestNear(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(9972, name + ": got " + actual + " expected " + expected) end if
  return true
end function

// Create and initialize user floor map.
function makeUserFloorMap(slope, solidBack)
  planeType = 3
  if slope == 0.0 then planeType = 2 end if
  plane = t.BspPlane(t.Vec3(-slope, 0.0, 1.0), 0.0, planeType)
  node = t.BspNode(0, -2, -1, t.Vec3(-4096.0, -4096.0, -4096.0), t.Vec3(4096.0, 4096.0, 4096.0), 0, 0)
  backContents = c.CONTENTS_EMPTY
  if solidBack then backContents = c.CONTENTS_SOLID end if
  backLeaf = t.BspLeaf(backContents, -1, t.Vec3(-4096.0, -4096.0, -4096.0), t.Vec3(4096.0, 4096.0, 0.0), 0, 0, bytes(4))
  frontLeaf = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(-4096.0, -4096.0, 0.0), t.Vec3(4096.0, 4096.0, 4096.0), 0, 0, bytes(4))
  model = t.BspModel(
    t.Vec3(-4096.0, -4096.0, -4096.0),
    t.Vec3(4096.0, 4096.0, 4096.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  clipNode = t.BspClipNode(0, c.CONTENTS_EMPTY, backContents)
  return SvUserTestMap([model], [node], [clipNode], [plane], [backLeaf, frontLeaf])
end function

// Verify edge friction against the expected Quake behavior.
function testEdgeFriction()
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  svuser.SV_UserSetFrameTime(state, 0.1)
  svuser.SV_UserSetMovement(state, 320.0, 10.0, 4.0, 2.0, 100.0)
  floorMap = makeUserFloorMap(0.0, true)
  edgeMap = makeUserFloorMap(0.0, false)

  floorPlayer = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  floorPlayer.velocity = t.Vec3(100.0, 0.0, 0.0)
  state.server = void
  svuser.SV_UserFriction(state, floorPlayer, floorMap, 1)
  svuTestNear(floorPlayer.velocity.x, 60.0, 0.001, "normal floor friction")

  edgePlayer = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  edgePlayer.velocity = t.Vec3(100.0, 0.0, 0.0)
  svuser.SV_UserFriction(state, edgePlayer, edgeMap, 1)
  svuTestNear(edgePlayer.velocity.x, 20.0, 0.001, "edge friction multiplier")
  return true
end function

// Verify air water and waterjump against the expected Quake behavior.
function testAirWaterAndWaterjump()
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  svuser.SV_UserSetFrameTime(state, 0.1)
  svuser.SV_UserSetMovement(state, 320.0, 10.0, 4.0, 2.0, 100.0)

  airPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  svuser.SV_AirAccelerate(state, airPlayer, t.Vec3(100.0, 0.0, 0.0), 100.0)
  svuTestNear(airPlayer.velocity.x, 30.0, 0.001, "air acceleration capped at 30")

  waterPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  waterPlayer.velocity = t.Vec3(100.0, 0.0, 0.0)
  command = game.clients[0].command
  command.forwardMove = 100.0
  svuser.SV_WaterMove(state, waterPlayer, command)
  svuTestNear(waterPlayer.velocity.x, 70.0, 0.001, "water friction and acceleration")

  jumpPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  jumpPlayer.flags = jumpPlayer.flags | c.FL_WATERJUMP
  jumpPlayer.waterLevel = 2
  jumpPlayer.teleportTime = 10.0
  jumpPlayer.moveDir = t.Vec3(120.0, -30.0, 0.0)
  game.time = 5.0
  svuser.SV_WaterJump(state, jumpPlayer)
  svuTestTrue((jumpPlayer.flags & c.FL_WATERJUMP) != 0, "active waterjump retained")
  svuTestNear(jumpPlayer.velocity.x, 120.0, 0.001, "waterjump x")
  svuTestNear(jumpPlayer.velocity.y, -30.0, 0.001, "waterjump y")
  game.time = 11.0
  svuser.SV_WaterJump(state, jumpPlayer)
  svuTestEqual(jumpPlayer.flags & c.FL_WATERJUMP, 0, "expired waterjump cleared")
  svuTestNear(jumpPlayer.teleportTime, 0.0, 0.001, "waterjump timer cleared")
  return true
end function

// Verify angles ideal pitch and gates against the expected Quake behavior.
function testAnglesIdealPitchAndGates()
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  svuser.SV_UserSetFrameTime(state, 0.05)
  slopeMap = makeUserFloorMap(0.1, true)
  player = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  player.flags = player.flags | c.FL_ONGROUND
  pitch = svuser.SV_SetIdealPitch(state, player, slopeMap, 0)
  svuTestNear(pitch, -0.8, 0.001, "ideal pitch on uniform slope")

  clientValue = game.clients[0]
  player.viewAngles = t.Vec3(30.0, 90.0, 0.0)
  player.velocity = t.Vec3(0.0, 100.0, 0.0)
  player.flags = c.FL_CLIENT
  svuser.SV_ClientThink(state, clientValue, player, slopeMap)
  svuTestNear(player.renderAngles.x, -10.0, 0.001, "one third pitch")
  svuTestNear(player.renderAngles.y, 90.0, 0.001, "full yaw")
  svuTestTrue(player.renderAngles.z != 0.0, "movement roll")

  dead = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  dead.health = 0.0
  dead.punchAngle = t.Vec3(5.0, 0.0, 0.0)
  dead.renderAngles.x = 17.0
  svuser.SV_ClientThink(state, clientValue, dead, slopeMap)
  svuTestNear(dead.punchAngle.x, 4.5, 0.001, "dead player punch still decays")
  svuTestNear(dead.renderAngles.x, 17.0, 0.001, "dead player angles frozen")

  frozen = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  frozen.punchAngle = t.Vec3(5.0, 0.0, 0.0)
  svuser.SV_UserSetFrozen(state, true)
  svuser.SV_ClientThink(state, clientValue, frozen, slopeMap)
  svuTestNear(frozen.punchAngle.x, 5.0, 0.001, "frozen client not simulated")
  svuser.SV_UserSetFrozen(state, false)

  noclip = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  noclip.moveType = c.MOVETYPE_NOCLIP
  noclip.noclip = true
  clientValue.command.forwardMove = 100.0
  clientValue.command.sideMove = 0.0
  clientValue.command.upMove = 25.0
  svuser.SV_ClientThink(state, clientValue, noclip, slopeMap)
  svuTestNear(math.length(noclip.velocity), math.length(t.Vec3(100.0, 0.0, 25.0)), 0.01, "noclip direct wish velocity")

  clientValue.active = true
  clientValue.spawned = true
  pausedPlayer = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  pausedPlayer.renderAngles.x = 12.0
  svuser.SV_UserSetPaused(state, true, "console")
  game.worldModel = slopeMap
  svuser.SV_RunClients(state, pausedPlayer)
  svuTestNear(pausedPlayer.renderAngles.x, 12.0, 0.001, "paused single player not simulated")
  return true
end function

// Verify client command parsing against the expected Quake behavior.
function testClientCommandParsing()
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  clientValue = game.clients[0]
  clientValue.active = true
  clientValue.spawned = true
  clientValue.name = "unconnected"
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  game.time = 5.0

  packet = sz.alloc(128)
  msg.writeByte(packet, c.CLC_MOVE)
  msg.writeFloat(packet, 4.75)
  msg.writeAngle(packet, 45.0)
  msg.writeAngle(packet, 90.0)
  msg.writeAngle(packet, 0.0)
  msg.writeShort(packet, 120)
  msg.writeShort(packet, -30)
  msg.writeShort(packet, 10)
  msg.writeByte(packet, 3)
  msg.writeByte(packet, 7)
  msg.writeByte(packet, c.CLC_STRINGCMD)
  msg.writeString(packet, "name Ranger")
  msg.writeByte(packet, c.CLC_STRINGCMD)
  msg.writeString(packet, "quit")
  svuTestTrue(svuser.SV_ReadClientMessage(state, clientValue, sz.dataSlice(packet), player), "move and string packet accepted")
  svuTestNear(clientValue.pingTimes[0], 0.25, 0.001, "ping sample")
  svuTestNear(clientValue.command.viewAngles.x, 45.0, 0.001, "move pitch")
  svuTestNear(clientValue.command.viewAngles.y, 90.0, 0.001, "move yaw")
  svuTestEqual(clientValue.command.forwardMove, 120, "forward move")
  svuTestEqual(clientValue.command.sideMove, -30, "side move")
  svuTestEqual(clientValue.command.upMove, 10, "up move")
  svuTestEqual(clientValue.command.buttons, 3, "button bits")
  svuTestEqual(clientValue.command.impulse, 7, "impulse")
  svuTestEqual(clientValue.name, "Ranger", "allowed name command")
  svuTestEqual(len(state.diagnostics), 1, "blocked command diagnosed")

  disconnect = sz.alloc(4)
  msg.writeByte(disconnect, c.CLC_DISCONNECT)
  svuTestEqual(svuser.SV_ReadClientMessage(state, clientValue, sz.dataSlice(disconnect), player), false, "disconnect rejects client message")
  unknown = sz.alloc(4)
  msg.writeByte(unknown, 99)
  svuTestEqual(svuser.SV_ReadClientMessage(state, clientValue, sz.dataSlice(unknown), player), false, "unknown command rejects message")
  return true
end function

// Execute one named test case and record its pass/fail result.
function parityRun(number, name, fn)
  print "[" + number + "/18] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify privileged allowed uses client context against the expected Quake behavior.
function testPrivilegedAllowedUsesClientContext()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.name="before";clientValue.privileged=true
  player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  svuTestTrue(svuser.svuExecuteString(state,clientValue,player,"name Ranger"),"privileged allowed command")
  svuTestEqual(state.commandEvents[0][0],"client","allowed command source");svuTestEqual(clientValue.name,"Ranger","allowed command effect")
  return true
end function
// Verify privileged arbitrary uses insert against the expected Quake behavior.
function testPrivilegedArbitraryUsesInsert()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.name="admin";clientValue.privileged=true
  player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  svuTestTrue(svuser.svuExecuteString(state,clientValue,player,"map e1m1"),"privileged insert")
  svuTestEqual(state.commandEvents[0][0],"insert","insert source");svuTestEqual(len(state.diagnostics),0,"no privileged diagnostic")
  return true
end function
// Verify case insensitive whitelist against the expected Quake behavior.
function testCaseInsensitiveWhitelist()
  svuTestTrue(svuser.svuAllowedCommand("StAtUs"),"case-insensitive status")
  svuTestTrue(svuser.svuAllowedCommand("NaMe Ranger"),"case-insensitive name")
  return true
end function
// Verify prefix whitelist matches original against the expected Quake behavior.
function testPrefixWhitelistMatchesOriginal()
  svuTestTrue(svuser.svuAllowedCommand("status_extra"),"status prefix")
  svuTestTrue(svuser.svuAllowedCommand("say_teamhello"),"say_team prefix")
  return true
end function
// Verify unprivileged blocked diagnostic against the expected Quake behavior.
function testUnprivilegedBlockedDiagnostic()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.name="guest";clientValue.privileged=false
  player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  svuTestEqual(svuser.svuExecuteString(state,clientValue,player,"map e1m1"),false,"blocked command")
  svuTestEqual(len(state.diagnostics),1,"blocked diagnostic")
  return true
end function
// Create and initialize move packet.
function makeMovePacket(clientTime, impulse)
  packet=sz.alloc(64);msg.writeFloat(packet,clientTime);msg.writeAngle(packet,45.0);msg.writeAngle(packet,90.0);msg.writeAngle(packet,0.0)
  msg.writeShort(packet,120);msg.writeShort(packet,-30);msg.writeShort(packet,10);msg.writeByte(packet,3);msg.writeByte(packet,impulse)
  return sz.dataSlice(packet)
end function
// Verify ping stored as binary32 against the expected Quake behavior.
function testPingStoredAsBinary32()
  game=server.create(1);state=svuser.SV_UserInit(game);game.time=5.0;clientValue=game.clients[0];player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  reader=msg.beginReadingBytes(makeMovePacket(4.9,0));svuser.SV_ReadClientMove(state,reader,clientValue,player)
  decodedClientTime = native.bitsFloat(native.floatBits(4.9))
  expectedPingBits = native.floatBits(5.0 - decodedClientTime)
  svuTestEqual(native.floatBits(clientValue.pingTimes[0]),expectedPingBits,"ping double-minus-float then float store")
  return true
end function
// Verify zero impulse preserves previous against the expected Quake behavior.
function testZeroImpulsePreservesPrevious()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.command.impulse=7;player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0))
  reader=msg.beginReadingBytes(makeMovePacket(0.0,0));svuser.SV_ReadClientMove(state,reader,clientValue,player)
  svuTestEqual(clientValue.command.impulse,7,"zero impulse preserves old")
  return true
end function
// Verify water jump equal time retained against the expected Quake behavior.
function testWaterJumpEqualTimeRetained()
  game=server.create(1);state=svuser.SV_UserInit(game);player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0));player.flags=player.flags|c.FL_WATERJUMP;player.waterLevel=2;player.teleportTime=5.0;game.time=5.0
  svuser.SV_WaterJump(state,player);svuTestTrue((player.flags&c.FL_WATERJUMP)!=0,"equal time retains waterjump")
  return true
end function
// Verify water jump no water clears against the expected Quake behavior.
function testWaterJumpNoWaterClears()
  game=server.create(1);state=svuser.SV_UserInit(game);player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0));player.flags=player.flags|c.FL_WATERJUMP;player.waterLevel=0;player.teleportTime=10.0;game.time=5.0
  svuser.SV_WaterJump(state,player);svuTestEqual(player.flags&c.FL_WATERJUMP,0,"no water clears jump");svuTestNear(player.teleportTime,0.0,0.0,"timer cleared")
  return true
end function
// Verify frame time lower clamp against the expected Quake behavior.
function testFrameTimeLowerClamp()
  state=svuser.SV_UserInit(server.create(1));svuTestNear(svuser.SV_UserSetFrameTime(state,-1.0),0.0,0.0,"negative frame time")
  return true
end function
// Verify frame time upper clamp against the expected Quake behavior.
function testFrameTimeUpperClamp()
  state=svuser.SV_UserInit(server.create(1));svuTestNear(svuser.SV_UserSetFrameTime(state,1.0),0.1,0.0,"large frame time")
  return true
end function
// Verify mixed ideal pitch retains previous against the expected Quake behavior.
function testMixedIdealPitchRetainsPrevious()
  state=svuser.SV_UserInit(server.create(1));state.idealPitches[0]=2.5
  value=svuser.SV_IdealPitchFromHeights(state,[0.0,1.0,3.0,4.0],0)
  svuTestNear(value,2.5,0.0,"mixed slope retains ideal pitch")
  return true
end function
// Verify unspawned client command cleared against the expected Quake behavior.
function testUnspawnedClientCommandCleared()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.active=true;clientValue.spawned=false;clientValue.command.forwardMove=123
  player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0));svuser.SV_RunClients(state,player)
  svuTestEqual(clientValue.command.forwardMove,0,"unspawned movement cleared")
  return true
end function
// Verify unknown command rejects against the expected Quake behavior.
function testUnknownCommandRejects()
  game=server.create(1);state=svuser.SV_UserInit(game);clientValue=game.clients[0];clientValue.active=true;player=movement.create(t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0));packet=sz.alloc(4);msg.writeByte(packet,99)
  svuTestEqual(svuser.SV_ReadClientMessage(state,clientValue,sz.dataSlice(packet),player),false,"unknown clc")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed=0
  if parityRun(1,"edge friction",testEdgeFriction) then passed=passed+1 end if
  if parityRun(2,"air water and waterjump",testAirWaterAndWaterjump) then passed=passed+1 end if
  if parityRun(3,"angles ideal pitch and gates",testAnglesIdealPitchAndGates) then passed=passed+1 end if
  if parityRun(4,"client command parsing",testClientCommandParsing) then passed=passed+1 end if
  if parityRun(5,"privileged allowed client context",testPrivilegedAllowedUsesClientContext) then passed=passed+1 end if
  if parityRun(6,"privileged arbitrary insert",testPrivilegedArbitraryUsesInsert) then passed=passed+1 end if
  if parityRun(7,"case-insensitive whitelist",testCaseInsensitiveWhitelist) then passed=passed+1 end if
  if parityRun(8,"prefix whitelist",testPrefixWhitelistMatchesOriginal) then passed=passed+1 end if
  if parityRun(9,"blocked diagnostic",testUnprivilegedBlockedDiagnostic) then passed=passed+1 end if
  if parityRun(10,"binary32 ping",testPingStoredAsBinary32) then passed=passed+1 end if
  if parityRun(11,"zero impulse retention",testZeroImpulsePreservesPrevious) then passed=passed+1 end if
  if parityRun(12,"waterjump equal-time boundary",testWaterJumpEqualTimeRetained) then passed=passed+1 end if
  if parityRun(13,"waterjump no-water clear",testWaterJumpNoWaterClears) then passed=passed+1 end if
  if parityRun(14,"frame-time lower clamp",testFrameTimeLowerClamp) then passed=passed+1 end if
  if parityRun(15,"frame-time upper clamp",testFrameTimeUpperClamp) then passed=passed+1 end if
  if parityRun(16,"mixed ideal pitch",testMixedIdealPitchRetainsPrevious) then passed=passed+1 end if
  if parityRun(17,"unspawned command clear",testUnspawnedClientCommandCleared) then passed=passed+1 end if
  if parityRun(18,"unknown command reject",testUnknownCommandRejects) then passed=passed+1 end if
  if passed!=18 then return 1 end if
  print "MiniQuake BP-029 server user tests passed: 18"
  return 0
end function
