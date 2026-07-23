package miniquake.demo_player

import miniquake.types as t
import miniquake.client as client
import miniquake.player_move as movement
import miniquake.mathlib as math

function create(recording)
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  state = client.create(player)
  return t.DemoPlayback(recording, state, 0, 0, 0, len(recording.messages) == 0, [])
end function

function step(playback)
  if playback.complete then return 0 end if
  if playback.index < 0 or playback.index >= len(playback.recording.messages) then
    playback.complete = true
    return 0
  end if
  item = playback.recording.messages[playback.index]
  playback.client.player.viewAngles = math.copy(item.viewAngles)
  playback.client.player.renderAngles = math.copy(item.viewAngles)
  parsed = try(client.parseMessage(playback.client, item.payload))
  if parsed is error then
    playback.errors = playback.errors + ["message " + playback.index + ": " + parsed.message]
    playback.complete = true
    return parsed
  end if
  playback.eventCount = playback.eventCount + parsed
  playback.payloadBytes = playback.payloadBytes + len(item.payload)
  playback.index = playback.index + 1
  if playback.index >= len(playback.recording.messages) then playback.complete = true end if
  return parsed
end function

function playAll(playback)
  while not playback.complete
    result = step(playback)
    if result is error then return result end if
  end while
  return playback.eventCount
end function

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

function printReport(report)
  for each line in report.messages
    print line
  end for
  print "demo state: signon=" + report.signon + " time=" + report.serverTime + " viewentity=" + report.viewEntity
  print "demo entities=" + report.entities + " prints=" + report.prints
  return report.ok
end function
