/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Deterministic MiniLang side of reference/harness/sv_user_oracle.c.
Stdout is JSONL and is consumed by tools/sv_user_differential.py.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sv_user as svuser
import miniquake.server as server
import miniquake.player_move as movement
import miniquake.native as native
import miniquake.message as msg
import miniquake.sizebuf as sz

struct SvUserDifferentialMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Exercise differential floor map as part of this deterministic regression fixture.
function differentialFloorMap(solidBack)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
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
  return SvUserDifferentialMap(
    [model],
    [node],
    [t.BspClipNode(0, c.CONTENTS_EMPTY, backContents)],
    [plane],
    [backLeaf, frontLeaf],
  )
end function

// Return differential number derived from the active module state.
function differentialNumber(value)
  return native.floatText(value)
end function

// Add vector to the destination state.
function emitVector(functionName, caseName, value)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName + "\",\"x\":" +
    differentialNumber(value.x) + ",\"y\":" + differentialNumber(value.y) +
    ",\"z\":" + differentialNumber(value.z) + "}"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  game = server.create(1)
  state = svuser.SV_UserInit(game)
  svuser.SV_UserSetFrameTime(state, 0.1)
  svuser.SV_UserSetMovement(state, 320.0, 10.0, 4.0, 2.0, 100.0)

  floorPlayer = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  floorPlayer.velocity = t.Vec3(100.0, 0.0, 10.0)
  state.server = void
  svuser.SV_UserFriction(state, floorPlayer, differentialFloorMap(true), 1)
  emitVector("SV_UserFriction", "floor", floorPlayer.velocity)

  edgePlayer = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  edgePlayer.velocity = t.Vec3(100.0, 0.0, 10.0)
  svuser.SV_UserFriction(state, edgePlayer, differentialFloorMap(false), 1)
  emitVector("SV_UserFriction", "edge", edgePlayer.velocity)

  accelerated = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  accelerated.velocity = t.Vec3(5.0, -2.0, 0.0)
  svuser.SV_Accelerate(state, accelerated, t.Vec3(1.0, 0.0, 0.0), 100.0)
  emitVector("SV_Accelerate", "ground", accelerated.velocity)

  air = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  svuser.SV_AirAccelerate(state, air, t.Vec3(100.0, 0.0, 0.0), 100.0)
  emitVector("SV_AirAccelerate", "cap30", air.velocity)

  punch = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  punch.punchAngle = t.Vec3(3.0, 4.0, 0.0)
  svuser.SV_UserSetFrameTime(state, 0.05)
  svuser.DropPunchAngle(state, punch)
  emitVector("DropPunchAngle", "decay", punch.punchAngle)

  svuser.SV_UserSetFrameTime(state, 0.1)
  water = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  water.velocity = t.Vec3(100.0, 0.0, 0.0)
  command = game.clients[0].command
  command.forwardMove = 100.0
  svuser.SV_WaterMove(state, water, command)
  emitVector("SV_WaterMove", "forward", water.velocity)

  idleWater = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  idleCommand = server.createServerClient(0).command
  svuser.SV_WaterMove(state, idleWater, idleCommand)
  emitVector("SV_WaterMove", "idle_sink", idleWater.velocity)

  state.server = game
  jump = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  jump.velocity.z = 5.0
  jump.flags = c.FL_WATERJUMP
  jump.waterLevel = 2
  jump.teleportTime = 10.0
  jump.moveDir = t.Vec3(120.0, -30.0, 0.0)
  game.time = 5.0
  svuser.SV_WaterJump(state, jump)
  print "{\"function\":\"SV_WaterJump\",\"case\":\"active\",\"x\":" + differentialNumber(jump.velocity.x) +
    ",\"y\":" + differentialNumber(jump.velocity.y) + ",\"z\":" + differentialNumber(jump.velocity.z) +
    ",\"flags\":" + jump.flags + ",\"teleport\":" + differentialNumber(jump.teleportTime) + "}"
  game.time = 11.0
  svuser.SV_WaterJump(state, jump)
  print "{\"function\":\"SV_WaterJump\",\"case\":\"expired\",\"x\":" + differentialNumber(jump.velocity.x) +
    ",\"y\":" + differentialNumber(jump.velocity.y) + ",\"z\":" + differentialNumber(jump.velocity.z) +
    ",\"flags\":" + jump.flags + ",\"teleport\":" + differentialNumber(jump.teleportTime) + "}"

  pitch = svuser.SV_IdealPitchFromHeights(state, [3.6, 4.8, 6.0, 7.2, 8.4, 9.6], 0)
  print "{\"function\":\"SV_SetIdealPitch\",\"case\":\"uniform_slope\",\"pitch\":" + differentialNumber(pitch) + "}"

  airMovePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  airMovePlayer.moveType = c.MOVETYPE_NOCLIP
  airMoveCommand = server.createServerClient(0).command
  airMoveCommand.forwardMove = 100.0
  airMoveCommand.sideMove = 25.0
  airMoveCommand.upMove = 30.0
  game.time = 5.0
  svuser.SV_AirMove(state, airMovePlayer, airMoveCommand, void, 1)
  emitVector("SV_AirMove", "noclip", airMovePlayer.velocity)

  thinkClient = game.clients[0]
  thinkPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  thinkPlayer.moveType = c.MOVETYPE_WALK
  thinkPlayer.health = 100.0
  thinkPlayer.flags = c.FL_WATERJUMP
  thinkPlayer.waterLevel = 2
  thinkPlayer.teleportTime = 10.0
  thinkPlayer.viewAngles = t.Vec3(30.0, 40.0, 0.0)
  thinkPlayer.moveDir = t.Vec3(12.0, -4.0, 0.0)
  game.time = 5.0
  svuser.SV_ClientThink(state, thinkClient, thinkPlayer, void)
  print "{\"function\":\"SV_ClientThink\",\"case\":\"waterjump-angles\",\"angles\":[" +
    differentialNumber(thinkPlayer.renderAngles.x) + "," +
    differentialNumber(thinkPlayer.renderAngles.y) + "," +
    differentialNumber(thinkPlayer.renderAngles.z) + "],\"velocity\":[" +
    differentialNumber(thinkPlayer.velocity.x) + "," +
    differentialNumber(thinkPlayer.velocity.y) + "," +
    differentialNumber(thinkPlayer.velocity.z) + "],\"flags\":" +
    thinkPlayer.flags + "}"

  moveBuffer = sz.alloc(64)
  msg.writeFloat(moveBuffer, 2.5)
  msg.writeByte(moveBuffer, 64)
  msg.writeByte(moveBuffer, 128)
  msg.writeByte(moveBuffer, 0)
  msg.writeShort(moveBuffer, 100)
  msg.writeShort(moveBuffer, -50)
  msg.writeShort(moveBuffer, 25)
  msg.writeByte(moveBuffer, 3)
  msg.writeByte(moveBuffer, 7)
  moveClient = server.createServerClient(0)
  moveClient.active = true
  movePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  game.time = 5.0
  svuser.SV_ReadClientMove(state, msg.beginReading(moveBuffer), moveClient, movePlayer)
  print "{\"function\":\"SV_ReadClientMove\",\"case\":\"protocol15\",\"ping\":" +
    differentialNumber(moveClient.pingTimes[0]) + ",\"pings\":" +
    moveClient.numPings + ",\"angles\":[" +
    differentialNumber(movePlayer.viewAngles.x) + "," +
    differentialNumber(movePlayer.viewAngles.y) + "," +
    differentialNumber(movePlayer.viewAngles.z) + "],\"move\":[" +
    differentialNumber(moveClient.command.forwardMove) + "," +
    differentialNumber(moveClient.command.sideMove) + "," +
    differentialNumber(moveClient.command.upMove) + "],\"buttons\":[" +
    (moveClient.command.buttons & 1) + "," +
    ((moveClient.command.buttons & 2) >> 1) + "],\"impulse\":" +
    moveClient.command.impulse + "}"

  messageBuffer = sz.alloc(128)
  msg.writeByte(messageBuffer, c.CLC_STRINGCMD)
  msg.writeString(messageBuffer, "echo fixture")
  msg.writeByte(messageBuffer, c.CLC_MOVE)
  msg.writeFloat(messageBuffer, 2.5)
  msg.writeByte(messageBuffer, 64)
  msg.writeByte(messageBuffer, 128)
  msg.writeByte(messageBuffer, 0)
  msg.writeShort(messageBuffer, 100)
  msg.writeShort(messageBuffer, -50)
  msg.writeShort(messageBuffer, 25)
  msg.writeByte(messageBuffer, 3)
  msg.writeByte(messageBuffer, 7)
  messageClient = server.createServerClient(0)
  messageClient.active = true
  messageClient.privileged = true
  messagePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  state.commandEvents = []
  result = svuser.SV_ReadClientMessage(
    state,
    messageClient,
    sz.dataSlice(messageBuffer),
    messagePlayer,
  )
  resultNumber = 0
  if result then resultNumber = 1 end if
  print "{\"function\":\"SV_ReadClientMessage\",\"case\":\"string-and-move\",\"result\":" +
    resultNumber + ",\"inserted\":" + len(state.commandEvents) + ",\"text\":\"" +
    state.commandEvents[0][1] + "\",\"forward\":" +
    differentialNumber(messageClient.command.forwardMove) + ",\"pings\":" +
    messageClient.numPings + "}"

  runGame = server.create(2)
  runState = svuser.SV_UserInit(runGame)
  runState.paused = true
  runState.keyDestination = "game"
  runGame.clients[0].active = true
  runGame.clients[0].spawned = false
  runGame.clients[0].command.forwardMove = 55.0
  runGame.clients[1].active = true
  runGame.clients[1].spawned = true
  runGame.clients[1].command.forwardMove = 77.0
  runPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  processed = svuser.SV_RunClients(runState, runPlayer)
  active0 = 0
  active1 = 0
  if runGame.clients[0].active then active0 = 1 end if
  if runGame.clients[1].active then active1 = 1 end if
  print "{\"function\":\"SV_RunClients\",\"case\":\"pause-spawn-gate\",\"processed\":" +
    processed + ",\"first_forward\":" +
    differentialNumber(runGame.clients[0].command.forwardMove) +
    ",\"second_forward\":" +
    differentialNumber(runGame.clients[1].command.forwardMove) +
    ",\"drops\":0,\"active\":[" + active0 + "," + active1 + "]}"

  return 0
end function
