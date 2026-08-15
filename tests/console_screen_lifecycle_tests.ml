/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-067: console notify-box and screen modal lifecycle parity.
*/
import miniquake.console as bp067Console
import miniquake.screen as bp067Screen

bp067Index = 0
bp067Failures = 0

// Assert that the condition holds and identify a failing test.
function bp067Check(value, name)
  global bp067Index, bp067Failures
  bp067Index = bp067Index + 1
  print "[" + bp067Index + "/22] " + name
  if not value then
    bp067Failures = bp067Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  state = bp067Console.create(64)
  bp067Console.Con_Init(state, void, 320, false)
  bp067Console.Con_CancelNotifyBox(state)
  bp067Check(not bp067Console.Con_NotifyBoxPending(), "notify initially idle")
  bp067Check(bp067Console.Con_NotifyBox(state, "Warning\n"), "notify starts")
  bp067Check(bp067Console.Con_NotifyBoxPending(), "notify pending")
  bp067Check(state.active, "notify selects console")
  bp067Check(state.notifyBoxText == "Warning\n", "notify text retained")
  bp067Check(state.realtime == 0.0, "notify cursor time reset")
  bp067Check(not bp067Console.Con_NotifyBoxKey(state, false), "up before down ignored")
  bp067Check(bp067Console.Con_NotifyBoxPending(), "up-before-down remains pending")
  bp067Check(not bp067Console.Con_NotifyBoxKey(state, true), "down arms acknowledgement")
  bp067Check(bp067Console.Con_NotifyBoxPending(), "down alone remains pending")
  bp067Check(bp067Console.Con_NotifyBoxKey(state, false), "following up dismisses")
  bp067Check(not bp067Console.Con_NotifyBoxPending(), "notify no longer pending")
  bp067Check(not state.active, "notify restores game console state")
  bp067Check(state.notifyBoxText == "", "notify text cleared")
  bp067Check(state.realtime == 0.0, "dismissal resets cursor time")
  bp067Check(state.lineCount > 0, "notify output reached console")

  bp067Console.Con_NotifyBox(state, "Second\n")
  bp067Check(bp067Console.Con_CancelNotifyBox(state), "notify cancellation")
  bp067Check(not bp067Console.Con_NotifyBoxPending(), "cancel clears pending")

  bp067Check(bp067Screen.SCR_ModalMessage("Continue?", void, true), "dedicated modal auto accepts")
  bp067Check(bp067Screen.SCR_ModalMessage("Continue?", void, false) is void, "interactive modal waits")
  bp067Check(bp067Screen.SCR_ModalMessage("Continue?", 89, false) == true, "modal Y accepts")
  bp067Check(bp067Screen.SCR_ModalMessage("Continue?", 78, false) == false and bp067Screen.SCR_ModalMessage("Continue?", 27, false) == false, "modal N and escape reject")

  if bp067Failures > 0 then
    print "MiniQuake BP-067 console/screen tests failed: " + bp067Failures + "/22"
    return 1
  end if
  print "MiniQuake BP-067 console/screen tests passed: 22"
  return 0
end function
