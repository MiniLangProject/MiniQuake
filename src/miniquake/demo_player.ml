/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.demo_player.
*/
package miniquake.demo_player

import miniquake.types as t
import miniquake.client as client
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.mathlib as math
import miniquake.native as native

/// Implements the `create` operation for `miniquake.demo_player` (create).
/// @param recording The recording input consumed by `create`.
function create(recording)
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  state = client.create(player)
  state.demoPlayback = true
  return t.DemoPlayback(
    recording,
    state,
    0,
    0,
    0,
    len(recording.messages) == 0,
    [],
    false,
    0,
    0.0,
    -1,
    false,
    void,
  )
end function

/// Apply the Quake-compatible cl finish time demo behavior.
/// @param playback The playback input consumed by `CL_FinishTimeDemo`.
/// @param hostFrameCount Number of entries or units to process.
/// @param realtime Time value used by the operation.
function CL_FinishTimeDemo(playback, hostFrameCount, realtime)
  playback.timedemo = false
  playback.client.timedemo = false
  frames = (hostFrameCount - playback.startFrame) - 1
  // CL_FinishTimeDemo stores the elapsed double clock in a C float before
  // printing, and the frames/time division is a float expression as well.
  seconds = native.bitsFloat(native.floatBits(realtime - playback.startTime))
  if seconds == 0.0 then seconds = 1.0 end if
  fps = native.bitsFloat(native.floatBits(frames / seconds))
  playback.finishResult = [frames, seconds, fps]
  return playback.finishResult
end function

/// Apply the Quake-compatible cl stop playback behavior.
/// @param playback The playback input consumed by `CL_StopPlayback`.
/// @param hostFrameCount Number of entries or units to process.
/// @param realtime Time value used by the operation.
function CL_StopPlayback(playback, hostFrameCount, realtime)
  if playback is void or playback.stopped then return false end if
  playback.client.demoPlayback = false
  playback.client.connected = false
  playback.client.spawned = false
  playback.complete = true
  playback.stopped = true
  if playback.timedemo then return CL_FinishTimeDemo(playback, hostFrameCount, realtime) end if
  return true
end function

/// Apply the Quake-compatible cl time demo f behavior.
/// @param playback The playback input consumed by `CL_TimeDemo_f`.
/// @param hostFrameCount Number of entries or units to process.
function CL_TimeDemo_f(playback, hostFrameCount)
  if playback is void then return error(2020, "timedemo has no playback") end if
  playback.timedemo = true
  playback.client.timedemo = true
  playback.startFrame = hostFrameCount
  playback.startTime = 0.0
  playback.lastFrame = -1
  return true
end function

/// Apply the Quake-compatible cl get message behavior.
/// @param playback The playback input consumed by `CL_GetMessage`.
/// @param hostFrameCount Number of entries or units to process.
/// @param realtime Time value used by the operation.
function CL_GetMessage(playback, hostFrameCount, realtime)
  if playback is void or playback.stopped then return void end if
  if playback.client.signon == c.SIGNONS then
    if playback.timedemo then
      if hostFrameCount == playback.lastFrame then return void end if
      playback.lastFrame = hostFrameCount
      if hostFrameCount == playback.startFrame + 1 then playback.startTime = realtime end if
    else if playback.client.time <= playback.client.messageTimes[0] then
      return void
    end if
  end if
  if playback.index < 0 or playback.index >= len(playback.recording.messages) then
    CL_StopPlayback(playback, hostFrameCount, realtime)
    return void
  end if
  item = playback.recording.messages[playback.index]
  playback.client.viewAngleSamples[1] = math.copy(playback.client.viewAngleSamples[0])
  playback.client.viewAngleSamples[0] = math.copy(item.viewAngles)
  // cl.viewangles is the camera input consumed by V_RenderView.  Demo headers
  // replace it for every message; updating only the entity/player copies left
  // timedemos facing the initial yaw while movement and events advanced.
  playback.client.command.viewAngles = math.copy(item.viewAngles)
  playback.client.player.viewAngles = math.copy(item.viewAngles)
  playback.client.player.renderAngles = math.copy(item.viewAngles)
  playback.index = playback.index + 1
  return item
end function

/// Execute message.
/// @param playback The playback input consumed by `processMessage`.
/// @param item The item input consumed by `processMessage`.
function processMessage(playback, item)
  parsed = try(client.parseMessage(playback.client, item.payload))
  if parsed is error then
    playback.errors = playback.errors + ["message " + (playback.index - 1) + ": " + parsed.message]
    playback.complete = true
    return parsed
  end if
  playback.eventCount = playback.eventCount + parsed
  playback.payloadBytes = playback.payloadBytes + len(item.payload)
  return parsed
end function

/// Advance frame by one processing step.
/// @param playback The playback input consumed by `stepFrame`.
/// @param hostFrameCount Number of entries or units to process.
/// @param realtime Time value used by the operation.
/// @param frameTime Time value used by the operation.
function stepFrame(playback, hostFrameCount, realtime, frameTime)
  if playback is void or playback.stopped then return 0 end if
  playback.client.oldTime = playback.client.time
  playback.client.time = playback.client.time + frameTime
  parsedEvents = 0
  reading = true
  while reading and not playback.stopped
    item = CL_GetMessage(playback, hostFrameCount, realtime)
    if item is void then
      reading = false
    else
      parsed = processMessage(playback, item)
      if parsed is error then return parsed end if
      parsedEvents = parsedEvents + parsed
    end if
  end while
  // CL_ReadFromServer owns relinking after all messages for the frame have
  // been parsed.  The integrated host performs that common step for both DEM
  // and live-network input, after synchronizing the renderer's MDL flags.
  return parsedEvents
end function

/// Implements the `step` operation for `miniquake.demo_player` (step).
/// @param playback The playback input consumed by `step`.
function step(playback)
  if playback.complete then return 0 end if
  if playback.index < 0 or playback.index >= len(playback.recording.messages) then
    playback.complete = true
    return 0
  end if
  item = playback.recording.messages[playback.index]
  playback.client.viewAngleSamples[1] = math.copy(playback.client.viewAngleSamples[0])
  playback.client.viewAngleSamples[0] = math.copy(item.viewAngles)
  playback.client.command.viewAngles = math.copy(item.viewAngles)
  playback.client.player.viewAngles = math.copy(item.viewAngles)
  playback.client.player.renderAngles = math.copy(item.viewAngles)
  playback.index = playback.index + 1
  parsed = processMessage(playback, item)
  if parsed is error then return parsed end if
  if playback.index >= len(playback.recording.messages) then playback.complete = true end if
  return parsed
end function

/// Play all through the active media subsystem.
/// @param playback The playback input consumed by `playAll`.
function playAll(playback)
  while not playback.complete
    result = step(playback)
    if result is error then return result end if
  end while
  return playback.eventCount
end function

/// Implements the `verify` operation for `miniquake.demo_player` (verify).
/// @param recording The recording input consumed by `verify`.
function verify(recording)
  playback = create(recording)
  result = try(playAll(playback))
  messages = []
  ok = true
  if result is error then
    ok = false
    messages = messages + ["FAIL " + result.message]
  else
    messages = messages + ["OK   parsed " + len(recording.messages) + " demo messages"]
    messages = messages + ["OK   protocol events " + playback.eventCount + ", payload bytes " + playback.payloadBytes]
  end if
  for each value in playback.errors
    messages = messages + ["FAIL " + value]
  end for
  return t.DemoVerification(
    ok,
    messages,
    playback.eventCount,
    playback.payloadBytes,
    playback.client.signon,
    playback.client.serverTime,
    playback.client.viewEntity,
    len(playback.client.entities),
    len(playback.client.printLog),
  )
end function

/// Implements the `printReport` operation for `miniquake.demo_player` (print report).
/// @param report The report input consumed by `printReport`.
function printReport(report)
  for each line in report.messages
    print line
  end for
  print "demo state: signon=" + report.signon + " time=" + report.serverTime + " viewentity=" + report.viewEntity
  print "demo entities=" + report.entities + " prints=" + report.prints
  return report.ok
end function
