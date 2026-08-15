/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-066: in_win.c device clear and first-sample m_filter parity.
*/
import miniquake.input as bp066Input
import miniquake.constants as bp066Constants
import miniquake.platform.win32 as bp066Win

bp066Index = 0
bp066Failures = 0

// Assert that the condition holds and identify a failing test.
function bp066Check(value, name)
  global bp066Index, bp066Failures
  bp066Index = bp066Index + 1
  print "[" + bp066Index + "/31] " + name
  if not value then
    bp066Failures = bp066Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  bp066Input.IN_ClearStates()

  bp066Input.IN_DifferentialSetMouse(true, true, true, false, false, 3, 10.0, -6.0, 0.0, 0.0, false)
  first = bp066Input.filteredMouseDelta(true)
  bp066Check(first[0] == 5.0, "first filtered x averages zero")
  bp066Check(first[1] == -3.0, "first filtered y averages zero")
  state = bp066Input.IN_DifferentialState()
  bp066Check(state[8] == 10.0 and state[9] == -6.0, "first sample becomes previous")
  bp066Check(state[10], "filter readiness recorded")

  bp066Input.IN_DifferentialSetMouse(true, true, true, false, false, 3, 6.0, 2.0, 10.0, -6.0, true)
  second = bp066Input.filteredMouseDelta(true)
  bp066Check(second[0] == 8.0, "second filtered x")
  bp066Check(second[1] == -2.0, "second filtered y")

  bp066Input.IN_DifferentialSetMouse(true, true, true, false, false, 3, 7.0, -9.0, 99.0, 99.0, true)
  raw = bp066Input.filteredMouseDelta(false)
  bp066Check(raw[0] == 7.0, "unfiltered x")
  bp066Check(raw[1] == -9.0, "unfiltered y")

  bp066Input.IN_DifferentialSetMouse(true, true, true, false, false, 7, 12.0, 13.0, 4.0, 5.0, true)
  bp066Input.IN_ClearDeviceStates()
  state = bp066Input.IN_DifferentialState()
  bp066Check(state[5] == 0, "active clear mouse buttons")
  bp066Check(state[6] == 0.0 and state[7] == 0.0, "active clear accumulators")
  bp066Check(state[8] == 4.0 and state[9] == 5.0, "device clear preserves filter history")
  bp066Check(state[10], "device clear preserves filter readiness")

  bp066Input.IN_DifferentialSetMouse(true, false, false, true, false, 5, 8.0, 9.0, 2.0, 3.0, true)
  bp066Input.IN_ClearDeviceStates()
  state = bp066Input.IN_DifferentialState()
  bp066Check(state[5] == 5, "inactive device clear leaves buttons")
  bp066Check(state[6] == 8.0 and state[7] == 9.0, "inactive device clear leaves accumulators")

  bp066Input.IN_ClearStates()
  bp066Input.IN_AttackDown(7)
  bp066Input.IN_DifferentialSetMouse(true, true, true, false, false, 3, 1.0, 2.0, 0.0, 0.0, false)
  bp066Input.IN_ClearDeviceStates()
  bp066Check(bp066Input.CL_ButtonBits() != 0, "device clear preserves command buttons")
  bp066Input.IN_ClearStates()
  bp066Check(bp066Input.CL_ButtonBits() == 0, "full clear resets command buttons")
  state = bp066Input.IN_DifferentialState()
  bp066Check(state[6] == 0.0 and state[7] == 0.0, "full clear resets accumulators")
  bp066Check(state[8] == 0.0 and state[9] == 0.0, "full clear resets filter history")
  bp066Check(not state[10], "full clear resets filter readiness")

  bp066Input.IN_Impulse(7)
  bp066Check(bp066Input.CL_TakeImpulse() == 7, "impulse transfer")
  bp066Check(bp066Input.CL_TakeImpulse() == 0, "impulse consumed")
  bp066Check(bp066Input.JOY_MAX_AXES == 6, "joystick axis count")
  bp066Check(len(bp066Input.CL_InitInput()) == 35, "stock input command set")

  // The live poll cache must follow every bind mutation while excluding
  // commands already handled exclusively by Key_Event.
  bp066Input.resetBindings()
  cachedCount = len(bp066Input.polledBindings)
  bp066Input.bindKey("F1", "echo fixture")
  bp066Check(len(bp066Input.polledBindings) == cachedCount, "poll cache excludes unrelated command")
  bp066Input.bindKey("F1", "impulse 255")
  cached = bp066Input.polledBindings[len(bp066Input.polledBindings) - 1]
  bp066Check(len(bp066Input.polledBindings) == cachedCount + 1 and cached[0] == 135 and cached[2] == 255, "poll cache accepts canonical impulse")
  bp066Input.bindKey("F1", "impulse 0255")
  bp066Check(len(bp066Input.polledBindings) == cachedCount, "poll cache rejects noncanonical impulse")
  bp066Input.bindKey("F1", "+attack")
  cached = bp066Input.polledBindings[len(bp066Input.polledBindings) - 1]
  bp066Check(len(bp066Input.polledBindings) == cachedCount + 1 and cached[0] == 135 and cached[3] == "+attack", "poll cache tracks button rebind")
  bp066Input.unbindKey("F1")
  bp066Check(len(bp066Input.polledBindings) == cachedCount, "poll cache tracks unbind")
  bp066Input.resetBindings()

  // A continuously held physical movement key must never acquire a synthetic
  // release between frames. The native test level follows the same bulk
  // snapshot path as the interactive Win32 window without requiring a GUI.
  bp066Input.IN_ClearStates()
  bp066Win.inputTestPush(1, 87, 1)
  heldCommand = bp066Input.createCommand()
  bp066Input.buildOriginalMove(
    heldCommand, bp066Constants.SIGNONS, 4.0,
    3.0, 0.022, 0.022, false,
    200.0, 200.0, 350.0, 200.0,
    false, true, false, false,
  )
  bp066Check(heldCommand.forwardMove == 100.0, "held W preserves stock half-frame press edge")
  continuous = true
  heldFrame = 0
  while heldFrame < 512
    bp066Input.buildOriginalMove(
      heldCommand, bp066Constants.SIGNONS, 4.0,
      3.0, 0.022, 0.022, false,
      200.0, 200.0, 350.0, 200.0,
      false, true, false, false,
    )
    if heldCommand.forwardMove != 200.0 then continuous = false end if
    heldFrame = heldFrame + 1
  end while
  bp066Check(continuous, "held W remains continuous for 512 input frames")
  bp066Win.inputTestPush(1, 87, 0)
  bp066Input.buildOriginalMove(
    heldCommand, bp066Constants.SIGNONS, 4.0,
    3.0, 0.022, 0.022, false,
    200.0, 200.0, 350.0, 200.0,
    false, true, false, false,
  )
  bp066Check(heldCommand.forwardMove == 0.0, "released W stops forward movement")
  bp066Input.IN_ClearStates()

  if bp066Failures > 0 then
    print "MiniQuake BP-066 input device tests failed: " + bp066Failures + "/31"
    return 1
  end if
  print "MiniQuake BP-066 input device tests passed: 31"
  return 0
end function
