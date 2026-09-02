/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sv_user.
*/
package miniquake.sv_user

// Functional pendant of WinQuake/sv_user.c.  This module owns the complete
// client-intention stage: command decoding, pitch/roll, ground/edge friction,
// acceleration, water movement, waterjump and the per-client pause/spawn gate.

import miniquake.types as t
import miniquake.constants as c
import miniquake.server as runtime
import miniquake.physics as physics
import miniquake.world_bsp as world
import miniquake.mathlib as math
import miniquake.message as msg
import miniquake.sizebuf as sz
import miniquake.net_main as netmain
import miniquake.input as input
import miniquake.view as view
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.array_util as arrayutil

// Track mutable sv user state across subsystem calls.
struct SvUserState
  /// Stores the server value in `miniquake.sv_user.SvUserState`.
  server
  /// Stores the frame time value in `miniquake.sv_user.SvUserState`.
  frameTime
  /// Stores the max speed value in `miniquake.sv_user.SvUserState`.
  maxSpeed
  /// Stores the acceleration value in `miniquake.sv_user.SvUserState`.
  acceleration
  /// Stores the friction value in `miniquake.sv_user.SvUserState`.
  friction
  /// Stores the edge friction value in `miniquake.sv_user.SvUserState`.
  edgeFriction
  /// Stores the stop speed value in `miniquake.sv_user.SvUserState`.
  stopSpeed
  /// Stores the ideal pitch scale value in `miniquake.sv_user.SvUserState`.
  idealPitchScale
  /// Stores the paused value in `miniquake.sv_user.SvUserState`.
  paused
  /// Stores the frozen value in `miniquake.sv_user.SvUserState`.
  frozen
  /// Stores the key destination value in `miniquake.sv_user.SvUserState`.
  keyDestination
  /// Stores the ideal pitches value in `miniquake.sv_user.SvUserState`.
  idealPitches
  /// Stores the command events value in `miniquake.sv_user.SvUserState`.
  commandEvents
  /// Stores the diagnostics value in `miniquake.sv_user.SvUserState`.
  diagnostics
end struct

/// Implements the `quakeFloat` operation for `miniquake.sv_user` (quake float).
/// @param value Value consumed by `quakeFloat`.
function quakeFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Apply the Quake-compatible sv user init behavior.
/// @param server Server state participating in the operation.
function SV_UserInit(server)
  count = 1
  if server is not void then count = server.maxClients end if
  return SvUserState(
    server,
    0.05,
    320.0,
    10.0,
    4.0,
    2.0,
    100.0,
    0.8,
    false,
    false,
    "game",
    arrayutil.makeFilledArray(count, 0.0),
    [],
    [],
  )
end function

/// Apply the Quake-compatible sv user set frame time behavior.
/// @param state Mutable `miniquake.sv_user` state used by `SV_UserSetFrameTime`.
/// @param frameTime Time value used by the operation.
function SV_UserSetFrameTime(state, frameTime)
  state.frameTime = frameTime
  if state.frameTime < 0.0 then state.frameTime = 0.0 end if
  if state.frameTime > 0.1 then state.frameTime = 0.1 end if
  return state.frameTime
end function

/// Apply the Quake-compatible sv user set movement behavior.
/// @param state Mutable `miniquake.sv_user` state used by `SV_UserSetMovement`.
/// @param maxSpeed The max speed input consumed by `SV_UserSetMovement`.
/// @param acceleration The acceleration input consumed by `SV_UserSetMovement`.
/// @param friction The friction input consumed by `SV_UserSetMovement`.
/// @param edgeFriction The edge friction input consumed by `SV_UserSetMovement`.
/// @param stopSpeed The stop speed input consumed by `SV_UserSetMovement`.
function SV_UserSetMovement(state, maxSpeed, acceleration, friction, edgeFriction, stopSpeed)
  state.maxSpeed = maxSpeed
  state.acceleration = acceleration
  state.friction = friction
  state.edgeFriction = edgeFriction
  state.stopSpeed = stopSpeed
  return true
end function

/// Apply the Quake-compatible sv user set paused behavior.
/// @param state Mutable `miniquake.sv_user` state used by `SV_UserSetPaused`.
/// @param paused The paused input consumed by `SV_UserSetPaused`.
/// @param keyDestination The key destination input consumed by `SV_UserSetPaused`.
function SV_UserSetPaused(state, paused, keyDestination)
  state.paused = paused
  state.keyDestination = keyDestination
  return paused
end function

/// Apply the Quake-compatible sv user set frozen behavior.
/// @param state Mutable `miniquake.sv_user` state used by `SV_UserSetFrozen`.
/// @param frozen The frozen input consumed by `SV_UserSetFrozen`.
function SV_UserSetFrozen(state, frozen)
  state.frozen = frozen
  return frozen
end function

/// Apply the Quake-compatible sv ideal pitch from heights behavior.
/// @param state Mutable `miniquake.sv_user` state used by `SV_IdealPitchFromHeights`.
/// @param heights The heights input consumed by `SV_IdealPitchFromHeights`.
/// @param clientIndex Zero-based index of the requested entry.
function SV_IdealPitchFromHeights(state, heights, clientIndex)
  if clientIndex < 0 or clientIndex >= len(state.idealPitches) then return error(2880, "SV_SetIdealPitch: bad client") end if
  direction = 0
  steps = 0
  index = 1
  while index < len(heights)
    // sv_user.c declares both step and dir as int, so every sampled height
    // delta truncates before the ON_EPSILON/mixed-slope checks.
    step = native.trunc(heights[index] - heights[index - 1])
    if step <= -0.1 or step >= 0.1 then
      if direction != 0 and (step - direction > 0.1 or step - direction < -0.1) then return state.idealPitches[clientIndex] end if
      direction = step
      steps = steps + 1
    end if
    index = index + 1
  end while
  if direction == 0 then
    state.idealPitches[clientIndex] = 0.0
  else if steps >= 2 then
    state.idealPitches[clientIndex] = quakeFloat(-direction * state.idealPitchScale)
  end if
  if state.server is not void and state.server.machine is not void and clientIndex < len(state.server.clients) then
    runtime.setQcEntityFloat(state.server, state.server.clients[clientIndex].edictIndex, "idealpitch", state.idealPitches[clientIndex])
  end if
  return state.idealPitches[clientIndex]
end function

/// Implements the `svuTraceIdealPitch` operation for `miniquake.sv_user` (svu trace ideal pitch).
/// @param state Mutable `miniquake.sv_user` state used by `svuTraceIdealPitch`.
/// @param player The player input consumed by `svuTraceIdealPitch`.
/// @param map The map input consumed by `svuTraceIdealPitch`.
/// @param clientIndex Zero-based index of the requested entry.
function svuTraceIdealPitch(state, player, map, clientIndex)
  if clientIndex < 0 or clientIndex >= len(state.idealPitches) then return error(2880, "SV_SetIdealPitch: bad client") end if
  if (player.flags & c.FL_ONGROUND) == 0 or map is void then return state.idealPitches[clientIndex] end if
  radians = player.renderAngles.y * math.PI * 2.0 / 360.0
  sine = math.sin(radians)
  cosine = math.cos(radians)
  heights = []
  index = 0
  while index < 6
    top = t.Vec3(
      player.origin.x + cosine * (index + 3) * 12.0,
      player.origin.y + sine * (index + 3) * 12.0,
      player.origin.z + player.viewHeight,
    )
    bottom = t.Vec3(top.x, top.y, top.z - 160.0)
    trace = world.traceLine(map, top, bottom)
    if trace.allSolid or trace.fraction == 1.0 then return state.idealPitches[clientIndex] end if
    heights = heights + [top.z + trace.fraction * (bottom.z - top.z)]
    index = index + 1
  end while
  return SV_IdealPitchFromHeights(state, heights, clientIndex)
end function

/// SV_SetIdealPitch
/// @param state Mutable `miniquake.sv_user` state used by `SV_SetIdealPitch`.
/// @param player The player input consumed by `SV_SetIdealPitch`.
/// @param map The map input consumed by `SV_SetIdealPitch`.
/// @param clientIndex Zero-based index of the requested entry.
function SV_SetIdealPitch(state, player, map, clientIndex)
  return svuTraceIdealPitch(state, player, map, clientIndex)
end function

/// SV_UserFriction
/// @param state Mutable `miniquake.sv_user` state used by `SV_UserFriction`.
/// @param player The player input consumed by `SV_UserFriction`.
/// @param map The map input consumed by `SV_UserFriction`.
/// @param entityIndex Zero-based index of the requested entry.
function SV_UserFriction(state, player, map, entityIndex)
  physics.applyFriction(
    player,
    map,
    state.server,
    entityIndex,
    state.frameTime,
    state.friction,
    state.edgeFriction,
    state.stopSpeed,
  )
  return player
end function

/// SV_Accelerate.  One MiniLang entry represents both the disabled experimental
/// #if 0 definition and the active no-argument definition in the source file.
/// @param state Mutable `miniquake.sv_user` state used by `SV_Accelerate`.
/// @param player The player input consumed by `SV_Accelerate`.
/// @param wishDirection The wish direction input consumed by `SV_Accelerate`.
/// @param wishSpeed The wish speed input consumed by `SV_Accelerate`.
function SV_Accelerate(state, player, wishDirection, wishSpeed)
  physics.accelerate(player, wishDirection, wishSpeed, state.frameTime, state.acceleration)
  return player
end function

/// SV_AirAccelerate
/// @param state Mutable `miniquake.sv_user` state used by `SV_AirAccelerate`.
/// @param player The player input consumed by `SV_AirAccelerate`.
/// @param wishVelocity The wish velocity input consumed by `SV_AirAccelerate`.
/// @param wishSpeed The wish speed input consumed by `SV_AirAccelerate`.
function SV_AirAccelerate(state, player, wishVelocity, wishSpeed)
  physics.airAccelerate(player, wishVelocity, wishSpeed, state.frameTime, state.acceleration)
  return player
end function

/// DropPunchAngle
/// @param state Mutable `miniquake.sv_user` state used by `DropPunchAngle`.
/// @param player The player input consumed by `DropPunchAngle`.
function DropPunchAngle(state, player)
  physics.dropPunchAngle(player, state.frameTime)
  return player
end function

/// SV_WaterMove
/// @param state Mutable `miniquake.sv_user` state used by `SV_WaterMove`.
/// @param player The player input consumed by `SV_WaterMove`.
/// @param command Console or protocol command to execute.
function SV_WaterMove(state, player, command)
  physics.waterMove(player, command, state.frameTime, state.maxSpeed, state.acceleration, state.friction)
  return player
end function

/// SV_WaterJump
/// @param state Mutable `miniquake.sv_user` state used by `SV_WaterJump`.
/// @param player The player input consumed by `SV_WaterJump`.
function SV_WaterJump(state, player)
  serverTime = 0.0
  if state.server is not void then serverTime = state.server.time end if
  if serverTime > player.teleportTime or player.waterLevel == 0 then
    player.flags = player.flags & ~c.FL_WATERJUMP
    player.teleportTime = 0.0
  end if
  player.velocity.x = player.moveDir.x
  player.velocity.y = player.moveDir.y
  return player
end function

/// SV_AirMove
/// @param state Mutable `miniquake.sv_user` state used by `SV_AirMove`.
/// @param player The player input consumed by `SV_AirMove`.
/// @param command Console or protocol command to execute.
/// @param map The map input consumed by `SV_AirMove`.
/// @param entityIndex Zero-based index of the requested entry.
function SV_AirMove(state, player, command, map, entityIndex)
  physics.airMove(
    player,
    command,
    state.frameTime,
    state.maxSpeed,
    state.acceleration,
    state.friction,
    state.edgeFriction,
    state.stopSpeed,
    map,
    state.server,
    entityIndex,
  )
  return player
end function

/// SV_ClientThink
/// @param state Mutable `miniquake.sv_user` state used by `SV_ClientThink`.
/// @param clientValue The client value input consumed by `SV_ClientThink`.
/// @param player The player input consumed by `SV_ClientThink`.
/// @param map The map input consumed by `SV_ClientThink`.
function SV_ClientThink(state, clientValue, player, map)
  if state.frozen or player.moveType == c.MOVETYPE_NONE then return player end if
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  DropPunchAngle(state, player)
  if player.health <= 0.0 then return player end if

  viewAngle = math.add(player.viewAngles, player.punchAngle)
  player.renderAngles.z = view.V_CalcRoll(player.renderAngles, player.velocity, 2.0, 200.0) * 4.0
  if not player.fixAngle then
    player.renderAngles.x = -viewAngle.x / 3.0
    player.renderAngles.y = viewAngle.y
  end if

  if (player.flags & c.FL_WATERJUMP) != 0 then
    SV_WaterJump(state, player)
    return player
  end if
  if player.waterLevel >= 2 and player.moveType != c.MOVETYPE_NOCLIP then
    SV_WaterMove(state, player, clientValue.command)
    return player
  end if
  SV_AirMove(state, player, clientValue.command, map, clientValue.edictIndex)
  return player
end function

/// SV_ReadClientMove
/// @param state Mutable `miniquake.sv_user` state used by `SV_ReadClientMove`.
/// @param reader The reader input consumed by `SV_ReadClientMove`.
/// @param clientValue The client value input consumed by `SV_ReadClientMove`.
/// @param player The player input consumed by `SV_ReadClientMove`.
function SV_ReadClientMove(state, reader, clientValue, player)
  clientTime = msg.readFloat(reader)
  ping = quakeFloat(state.server.time - clientTime)
  if len(clientValue.pingTimes) > 0 then
    clientValue.pingTimes[clientValue.numPings % len(clientValue.pingTimes)] = ping
    clientValue.numPings = clientValue.numPings + 1
  end if
  angles = t.Vec3(msg.readAngle(reader), msg.readAngle(reader), msg.readAngle(reader))
  clientValue.command.viewAngles = angles
  player.viewAngles = math.copy(angles)
  clientValue.command.forwardMove = msg.readShort(reader)
  clientValue.command.sideMove = msg.readShort(reader)
  clientValue.command.upMove = msg.readShort(reader)
  bits = msg.readByte(reader)
  clientValue.command.buttons = bits
  impulse = msg.readByte(reader)
  if impulse != 0 then clientValue.command.impulse = impulse end if
  clientValue.command.msec = 0
  if state.server.machine is not void then
    entityIndex = clientValue.edictIndex
    runtime.setQcEntityVector(state.server, entityIndex, "v_angle", angles)
    runtime.setQcEntityFloat(state.server, entityIndex, "button0", bits & 1)
    runtime.setQcEntityFloat(state.server, entityIndex, "button2", (bits & 2) >> 1)
    if impulse != 0 then runtime.setQcEntityFloat(state.server, entityIndex, "impulse", impulse) end if
  end if
  return clientTime
end function

/// Implements the `svuStartsWith` operation for `miniquake.sv_user` (svu starts with).
/// @param text Text to parse or process.
/// @param prefix The prefix input consumed by `svuStartsWith`.
function svuStartsWith(text, prefix)
  source = bytes(bio.lower(text))
  wanted = bytes(prefix)
  if len(source) < len(wanted) then return false end if
  index = 0
  while index < len(wanted)
    if source[index] != wanted[index] then return false end if
    index = index + 1
  end while
  return true
end function

/// Implements the `svuAllowedCommand` operation for `miniquake.sv_user` (svu allowed command).
/// @param text Text to parse or process.
function svuAllowedCommand(text)
  prefixes = [
    "status", "god", "notarget", "fly", "name", "noclip", "say",
    "say_team", "tell", "color", "kill", "pause", "spawn", "begin",
    "prespawn", "kick", "ping", "give", "ban",
  ]
  for each prefix in prefixes
    if svuStartsWith(text, prefix) then return true end if
  end for
  return false
end function

/// Implements the `svuExecuteString` operation for `miniquake.sv_user` (svu execute string).
/// @param state Mutable `miniquake.sv_user` state used by `svuExecuteString`.
/// @param clientValue The client value input consumed by `svuExecuteString`.
/// @param player The player input consumed by `svuExecuteString`.
/// @param text Text to parse or process.
function svuExecuteString(state, clientValue, player, text)
  // sv_user.c initializes ret from privileged, then lets the whitelist replace
  // it with src_client.  A privileged client therefore still executes allowed
  // player commands in client context; only non-whitelisted text is inserted.
  if svuAllowedCommand(text) then
    state.commandEvents = state.commandEvents + [["client", text]]
    // Cmd_ExecuteString is void in WinQuake.  The command has been accepted once
    // it is dispatched in src_client context; handler-specific convenience
    // return values (for example Host_Name_f returning the limited name) must
    // not turn the client message into a rejection. Runtime errors still bubble.
    runtime.executeStringCommand(state.server, clientValue, text, player)
    return true
  end if
  if clientValue.privileged then
    state.commandEvents = state.commandEvents + [["insert", text]]
    return true
  end if
  state.diagnostics = state.diagnostics + [clientValue.name + " tried to " + text]
  return false
end function

/// SV_ReadClientMessage.  The original outer NET_GetMessage loop lives in
/// SV_RunClients; this entry consumes one already-framed reliable/unreliable
/// payload and preserves the exact clc_* command ordering.
/// @param state Mutable `miniquake.sv_user` state used by `SV_ReadClientMessage`.
/// @param clientValue The client value input consumed by `SV_ReadClientMessage`.
/// @param data Input data consumed by the operation.
/// @param player The player input consumed by `SV_ReadClientMessage`.
function SV_ReadClientMessage(state, clientValue, data, player)
  reader = msg.beginReadingBytes(data)
  while msg.remaining(reader) > 0
    if not clientValue.active or reader.badRead then return false end if
    command = msg.readChar(reader)
    if command == -1 then return true end if
    if command == c.CLC_NOP then
      continue
    else if command == c.CLC_STRINGCMD then
      svuExecuteString(state, clientValue, player, msg.readString(reader))
    else if command == c.CLC_DISCONNECT then
      return false
    else if command == c.CLC_MOVE then
      SV_ReadClientMove(state, reader, clientValue, player)
    else
      state.diagnostics = state.diagnostics + ["SV_ReadClientMessage: unknown command char " + command]
      return false
    end if
    if reader.badRead then
      state.diagnostics = state.diagnostics + ["SV_ReadClientMessage: badread"]
      return false
    end if
  end while
  return true
end function

/// Implements the `svuReadNetworkMessages` operation for `miniquake.sv_user` (svu read network messages).
/// @param state Mutable `miniquake.sv_user` state used by `svuReadNetworkMessages`.
/// @param clientValue The client value input consumed by `svuReadNetworkMessages`.
/// @param player The player input consumed by `svuReadNetworkMessages`.
function svuReadNetworkMessages(state, clientValue, player)
  if clientValue.socket is void then return true end if
  destination = sz.alloc(c.MAX_MSGLEN)
  while true
    messageType = netmain.NET_GetMessage(clientValue.socket, destination, netmain.net_messagetimeout)
    if messageType < 0 then return false end if
    if messageType == 0 then return true end if
    if not SV_ReadClientMessage(state, clientValue, sz.dataSlice(destination), player) then return false end if
    sz.clear(destination)
  end while
end function

/// SV_RunClients
/// @param state Mutable `miniquake.sv_user` state used by `SV_RunClients`.
/// @param player The player input consumed by `SV_RunClients`.
function SV_RunClients(state, player)
  processed = 0
  for each clientValue in state.server.clients
    if clientValue.active then
      if not svuReadNetworkMessages(state, clientValue, player) then
        runtime.dropClient(state.server, clientValue, false)
        continue
      end if
      processed = processed + 1
      if not clientValue.spawned then
        clientValue.command = input.createCommand()
        continue
      end if
      if not state.paused and (state.server.maxClients > 1 or state.keyDestination == "game") then
        SV_ClientThink(state, clientValue, player, state.server.worldModel)
      end if
    end if
  end for
  return processed
end function
