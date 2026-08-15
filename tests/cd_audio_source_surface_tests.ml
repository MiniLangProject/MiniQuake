/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-081 source-surface runtime entry. main(args) must remain in the global package.
*/
import miniquake.sound.cd_audio as cd

bp081Failures = 0
bp081Checks = 0

// Assert that the condition holds and identify a failing test.
function bp081Check(condition, label)
  global bp081Failures, bp081Checks
  bp081Checks = bp081Checks + 1
  if not condition then
    bp081Failures = bp081Failures + 1
    print "FAIL: " + label
  end if
end function

// Assert exact equality and report both values on failure.
function bp081Equal(actual, expected, label)
  bp081Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global bp081Failures, bp081Checks
  state = cd.create(void, 12)

  print "[1/20] initialization"
  bp081Equal(cd.CDAudio_Init(state), 0, "init result")
  bp081Check(state.initialized and state.enabled and state.valid, "init flags")

  print "[2/20] disk info"
  bp081Equal(cd.CDAudio_GetAudioDiskInfo(state), 0, "disk info")
  bp081Equal(state.maxTrack, 12, "max track")

  print "[3/20] close door"
  bp081Check(cd.CDAudio_CloseDoor(state), "close door")
  bp081Check(len(bytes(state.lastMessage)) > 0, "close door message")

  print "[4/20] play"
  state.volume = 1.0
  bp081Check(cd.CDAudio_Play(state, 3, false), "play")
  bp081Equal(state.track, 3, "play track")

  print "[5/20] successful completion"
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_SUCCESSFUL, true), 0, "notify success")
  bp081Check(not state.playing, "success clears playing")

  print "[6/20] looping completion"
  bp081Check(cd.CDAudio_Play(state, 4, true), "loop play")
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_SUCCESSFUL, true), 0, "loop notify")
  bp081Check(state.playing and state.looping, "loop restarts")

  print "[7/20] superseded notification"
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_SUPERSEDED, true), 0, "superseded")

  print "[8/20] aborted notification"
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_ABORTED, true), 0, "aborted")

  print "[9/20] foreign device"
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_SUCCESSFUL, false), 1, "foreign device")

  print "[10/20] unknown notification"
  bp081Equal(cd.CDAudio_MessageHandler(state, 99, true), 1, "unknown notify")
  bp081Check(len(bytes(state.lastMessage)) > 0, "unknown message")

  print "[11/20] failure notification"
  state.valid = true
  state.playing = true
  bp081Equal(cd.CDAudio_MessageHandler(state, cd.MCI_NOTIFY_FAILURE, true), 0, "failure notify")
  bp081Check(not state.valid and not state.playing, "failure state")

  print "[12/20] disk revalidation"
  bp081Equal(cd.CDAudio_GetAudioDiskInfo(state), 0, "revalidate")
  bp081Check(state.valid, "revalidated")

  print "[13/20] eject"
  state.playing = true
  bp081Check(cd.CDAudio_Eject(state), "eject")
  bp081Check(not state.valid and not state.playing, "eject state")

  print "[14/20] play rejected without media"
  bp081Check(not cd.CDAudio_Play(state, 1, false), "invalid media reject")

  print "[15/20] close command"
  cd.CD_f(state, ["cd", "close"])
  bp081Check(len(bytes(state.lastMessage)) > 0, "close command")

  print "[16/20] reset command"
  cd.CD_f(state, ["cd", "reset"])
  bp081Check(state.valid and state.enabled, "reset state")

  print "[17/20] eject command"
  cd.CD_f(state, ["cd", "eject"])
  bp081Check(not state.valid, "eject command state")

  print "[18/20] invalid disk info"
  empty = cd.create(void, 1)
  empty.maxTrack = 0
  empty.initialized = true
  bp081Equal(cd.CDAudio_GetAudioDiskInfo(empty), -1, "empty media")
  bp081Check(not empty.valid, "empty invalid")

  print "[19/20] identity remap"
  remap = cd.identityRemap()
  bp081Equal(remap[0], 0, "remap zero")
  bp081Equal(remap[99], 99, "remap ninety-nine")

  print "[20/20] shutdown"
  state.valid = true
  state.playing = true
  bp081Check(cd.CDAudio_Shutdown(state), "shutdown")
  bp081Check(not state.playing, "shutdown stops")

  if bp081Failures > 0 then
    print "MiniQuake BP-081 CD audio source-surface tests failed: " + bp081Failures + "/" + bp081Checks
    return 1
  end if
  print "MiniQuake BP-081 CD audio source-surface tests passed: 20"
  return 0
end function
