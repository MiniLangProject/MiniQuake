/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-066: in_win.c device clear and first-sample m_filter parity.
*/

import miniquake.input as bp066Input

bp066Index = 0
bp066Failures = 0

function bp066Check(value, name)
  global bp066Index, bp066Failures
  bp066Index = bp066Index + 1
  print "[" + bp066Index + "/22] " + name
  if not value then
    bp066Failures = bp066Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

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

  if bp066Failures > 0 then
    print "MiniQuake BP-066 input device tests failed: " + bp066Failures + "/22"
    return 1
  end if
  print "MiniQuake BP-066 input device tests passed: 22"
  return 0
end function
