/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cl_demo_differential_fixture.ml.
*/
import miniquake.demo as demo
import miniquake.demo_player as player
import miniquake.client as client
import miniquake.constants as c
import miniquake.types as t
import miniquake.player_move as movement
import miniquake.net_loop as netloop
import miniquake.native as native

// Exercise payload as part of this deterministic regression fixture.
function payload(values)
  result = bytes(len(values))
  index = 0
  while index < len(values)
    result[index] = values[index]
    index = index + 1
  end while
  return result
end function

// Exercise bool text as part of this deterministic regression fixture.
function boolText(value)
  if value then return "true" end if
  return "false"
end function

// Exercise playback fixture as part of this deterministic regression fixture.
function playbackFixture(messages)
  recording = t.Demo(-1, messages, "-1\n")
  result = player.create(recording)
  result.client.connected = true
  return result
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  recording = t.Demo(-1, [], "-1\n")
  demo.CL_WriteDemoMessage(recording, payload([c.SVC_NOP, c.SVC_DISCONNECT]), t.Vec3(1.0, -2.5, 90.0))
  print "{\"function\":\"CL_WriteDemoMessage\",\"case\":\"framing\",\"file_length\":18,\"length_prefix\":2,\"payload\":[1,2],\"viewangles\":[1,-2.5,90]}"

  stopped = t.Demo(-1, [], "-1\n")
  demo.CL_Stop_f(stopped, t.Vec3(4.0, 5.0, 6.0))
  print "{\"function\":\"CL_Stop_f\",\"case\":\"disconnect\",\"recording\":false,\"closed\":true,\"file_length\":17,\"opcode\":" + stopped.messages[0].payload[0] + "}"

  plan = demo.CL_Record_f(["record", "fixture", "e1m1", "4"], false)
  print "{\"function\":\"CL_Record_f\",\"case\":\"map_track\",\"recording\":true,\"forcetrack\":" + plan[1].forcedTrack + ",\"header\":[52,10],\"map\":\"" + plan[2] + "\",\"filename\":\"" + plan[0] + "\"}"

  whitespace = demo.CL_PlayDemo_f(bytes(" 2\n"))
  print "{\"function\":\"CL_PlayDemo_f\",\"case\":\"header_whitespace\",\"forcetrack\":" + whitespace.forcedTrack + ",\"playback\":true,\"connected\":true,\"disconnect_calls\":1}"

  timedemoStart = playbackFixture([])
  player.CL_TimeDemo_f(timedemoStart, 30)
  print "{\"function\":\"CL_TimeDemo_f\",\"case\":\"start\",\"timedemo\":" + boolText(timedemoStart.timedemo) + ",\"start_frame\":" + timedemoStart.startFrame + ",\"last_frame\":" + timedemoStart.lastFrame + ",\"playback\":true}"

  finished = playbackFixture([])
  finished.timedemo = true
  finished.client.timedemo = true
  finished.startFrame = 10
  finished.startTime = 5.0
  finishResult = player.CL_FinishTimeDemo(finished, 21, 9.0)
  print "{\"function\":\"CL_FinishTimeDemo\",\"case\":\"first_frame_excluded\",\"timedemo\":" + boolText(finished.timedemo) + ",\"frames\":" + finishResult[0] + ",\"seconds\":" + finishResult[1] + ",\"fps\":" + finishResult[2] + "}"

  stopping = playbackFixture([])
  stopping.timedemo = true
  stopping.client.timedemo = true
  stopping.startFrame = 10
  stopping.startTime = 5.0
  stopResult = player.CL_StopPlayback(stopping, 21, 9.0)
  print "{\"function\":\"CL_StopPlayback\",\"case\":\"timedemo_eof\",\"playback\":" + boolText(not stopping.stopped) + ",\"connected\":" + boolText(stopping.client.connected) + ",\"closed\":true,\"frames\":" + stopResult[0] + ",\"seconds\":" + stopResult[1] + ",\"fps\":" + stopResult[2] + "}"

  paced = playbackFixture([t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), payload([c.SVC_NOP]))])
  paced.client.signon = c.SIGNONS
  paced.client.time = 1.0
  paced.client.messageTimes = [1.1, 0.0]
  blocked = player.CL_GetMessage(paced, 0, 0.0)
  paced.client.time = 1.2
  read = player.CL_GetMessage(paced, 0, 0.0)
  blockedResult = 0
  if blocked is not void then blockedResult = 1 end if
  readResult = 0
  if read is not void then readResult = 1 end if
  print "{\"function\":\"CL_GetMessage\",\"case\":\"pacing_viewangles\",\"blocked\":" + blockedResult + ",\"read\":" + readResult + ",\"cursize\":" + len(read.payload) + ",\"viewangles\":[" + native.trunc(read.viewAngles.x) + "," + native.trunc(read.viewAngles.y) + "," + native.trunc(read.viewAngles.z) + "]}"

  timed = playbackFixture([
    t.DemoMessage(t.Vec3(1.0, 2.0, 3.0), payload([c.SVC_NOP])),
    t.DemoMessage(t.Vec3(4.0, 5.0, 6.0), payload([c.SVC_DISCONNECT])),
  ])
  timed.client.signon = c.SIGNONS
  player.CL_TimeDemo_f(timed, 10)
  firstItem = player.CL_GetMessage(timed, 10, 6.0)
  sameItem = player.CL_GetMessage(timed, 10, 6.0)
  secondItem = player.CL_GetMessage(timed, 11, 7.0)
  firstResult = 0
  if firstItem is not void then firstResult = 1 end if
  sameResult = 0
  if sameItem is not void then sameResult = 1 end if
  secondResult = 0
  if secondItem is not void then secondResult = 1 end if
  print "{\"function\":\"CL_GetMessage\",\"case\":\"timedemo_pacing\",\"first\":" + firstResult + ",\"same_frame\":" + sameResult + ",\"second_frame\":" + secondResult + ",\"last_frame\":" + timed.lastFrame + ",\"start_time\":" + native.trunc(timed.startTime) + ",\"previous_angle\":" + native.trunc(timed.client.viewAngleSamples[1].x) + ",\"current_angle\":" + native.trunc(timed.client.viewAngleSamples[0].x) + "}"

  eof = player.CL_GetMessage(timed, 12, 8.0)
  eofResult = 0
  if eof is not void then eofResult = 1 end if
  print "{\"function\":\"CL_GetMessage\",\"case\":\"eof_disconnect\",\"result\":" + eofResult + ",\"playback\":" + boolText(not timed.stopped) + ",\"connected\":" + boolText(timed.client.connected) + ",\"timedemo\":" + boolText(timed.timedemo) + ",\"frames\":" + timed.finishResult[0] + ",\"seconds\":" + timed.finishResult[1] + "}"

  networkRecording = t.Demo(-1, [], "-1\n")
  networkClient = client.create(movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  networkClient.connected = true
  networkClient.command.viewAngles = t.Vec3(7.0, 8.0, 9.0)
  networkClient.socket = netloop.createSocket()
  networkClient.socket.messages = [payload([c.SVC_NOP]), payload([c.SVC_NOP, c.SVC_NOP])]
  networkClient.socket.messageTypes = [1, 1]
  client.pumpRecording(networkClient, networkRecording)
  print "{\"function\":\"CL_GetMessage\",\"case\":\"network_keepalive_record\",\"result\":1,\"net_calls\":2,\"recorded_length\":18,\"payload\":[" + networkRecording.messages[0].payload[0] + "," + networkRecording.messages[0].payload[1] + "]}"
  return 0
end function
