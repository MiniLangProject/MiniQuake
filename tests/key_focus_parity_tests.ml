/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-065: keys.c/gl_vidnt.c key routing and synthetic release parity.
*/

import miniquake.keys as bp065Keys
import miniquake.input as bp065Input
import miniquake.console as bp065Console
import miniquake.cmd as bp065Cmd
import miniquake.cvar as bp065Cvar
import miniquake.gl_vidnt as bp065Video

bp065Index = 0
bp065Failures = 0

function bp065Check(value, name)
  global bp065Index, bp065Failures
  bp065Index = bp065Index + 1
  print "[" + bp065Index + "/20] " + name
  if not value then
    bp065Failures = bp065Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

function main(args)
  bp065Input.unbindAll()
  bp065Keys.Key_Init()
  bp065Keys.Key_TakePendingCommands()
  state = bp065Console.create(64)
  commands = bp065Cmd.create()
  registry = bp065Cvar.createRegistry()

  bp065Check(bp065Keys.MAXCMDLINE == 256, "command-line limit")
  bp065Check(len(bp065Keys.keyLines) == 32, "history line count")
  bp065Check(bp065Keys.consoleKeys[97] == 1, "printable console key")
  bp065Check(bp065Keys.keyShift[97] == 65, "lowercase shift mapping")

  bp065Keys.Key_SetBinding(65, "+attack")
  bp065Keys.Key_SetBinding(97, "+forward")
  bp065Keys.Key_SetBinding(98, "impulse 1")
  bp065Keys.Key_Event(bp065Keys.K_SHIFT, true, state, commands, registry, false, false)
  bp065Keys.Key_Event(97, true, state, commands, registry, false, false)
  released = bp065Keys.Key_ReleaseAllCommands()
  expected = "-attack 65\n-forward 97\n-attack 97\n"
  bp065Check(released == expected, "release-all command order")
  bp065Check(not bp065Keys.keyDownStates[97], "release clears key state")
  bp065Check(bp065Keys.keyRepeats[97] == 0, "release clears repeat")
  bp065Check(not bp065Keys.shiftDown, "release clears shift")
  bp065Check(len(bytes(released)) == len(bytes(expected)), "release byte length")
  bp065Check(not ("impulse 1" == released), "plain binding excluded")

  queuedLength = bp065Keys.Key_QueueReleaseAllCommands()
  bp065Check(queuedLength == len(bytes(expected)), "queue release length")
  bp065Check(bp065Keys.Key_TakePendingCommands() == expected, "take pending releases")
  bp065Check(bp065Keys.Key_TakePendingCommands() == "", "pending queue drains")

  bp065Video.ClearAllStates()
  bp065Check(bp065Keys.Key_TakePendingCommands() == expected, "video clear queues releases")

  videoState = bp065Video.createVideoState()
  bp065Video.VID_UseState(videoState)
  bp065Keys.Key_Event(97, true, state, commands, registry, false, false)
  activation = bp065Video.MainWndProc(0x0006, 0, 0)
  bp065Check(activation[0] == "activate", "WM_ACTIVATE dispatch")
  bp065Check(bp065Keys.Key_TakePendingCommands() == expected, "WM_ACTIVATE release queue")
  bp065Check(not bp065Keys.keyDownStates[97], "WM_ACTIVATE clears keydown")
  bp065Check(bp065Keys.Key_StringToKeynum("MOUSE1") == bp065Keys.K_MOUSE1, "key name lookup")
  bp065Check(bp065Keys.Key_KeynumToString(bp065Keys.K_MWHEELUP) == "MWHEELUP", "wheel key name")
  bp065Check(bp065Keys.Key_WriteBindings() != "", "binding serialization remains available")

  if bp065Failures > 0 then
    print "MiniQuake BP-065 key/focus tests failed: " + bp065Failures + "/20"
    return 1
  end if
  print "MiniQuake BP-065 key/focus tests passed: 20"
  return 0
end function
