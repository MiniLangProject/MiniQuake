/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-051: MiniQuake R_Clear, z-trick, finish and no-refresh contract.
*/
import miniquake.render.special_paths as bp051Special
import miniquake.render.world as bp051World
import miniquake.render.gl11 as bp051Gl

// Assert exact equality and report both values on failure.
function bp051Equal(actual, expected, name)
  if actual != expected then return error(5100, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp051Yes(value, name)
  if not value then return error(5101, name + ": expected true") end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp051Run(number, name, fn)
  print "[" + number + "/20] " + name
  value = try(fn())
  if value is error then print "FAIL: " + value.message; return false end if
  return true
end function
// Exercise the mirror depth test scenario and verify its expected result.
function bp051MirrorDepth()
  plan = bp051Special.clearPlan(0.5, false, true, 7)
  bp051Equal(plan[0], bp051Gl.GL_DEPTH_BUFFER_BIT, "mirror mask")
  bp051Equal(plan[1], 0.0, "mirror near")
  bp051Equal(plan[2], 0.5, "mirror far")
  bp051Equal(plan[3], bp051Gl.GL_LEQUAL, "mirror function")
  bp051Equal(plan[4], 7, "mirror trick frame")
  return true
end function
// Exercise the mirror color test scenario and verify its expected result.
function bp051MirrorColor()
  plan = bp051Special.clearPlan(0.25, true, true, 2)
  bp051Equal(plan[0], bp051Gl.GL_DEPTH_BUFFER_BIT | bp051Gl.GL_COLOR_BUFFER_BIT, "mirror color mask")
  return true
end function
// Exercise the ztrick odd test scenario and verify its expected result.
function bp051ZTrickOdd()
  plan = bp051Special.clearPlan(1.0, false, true, 0)
  bp051Equal(plan[0], 0, "odd mask")
  bp051Equal(plan[1], 0.0, "odd near")
  bp051Equal(plan[3], bp051Gl.GL_LEQUAL, "odd function")
  bp051Equal(plan[4], 1, "odd frame")
  return true
end function
// Exercise the ztrick odd far test scenario and verify its expected result.
function bp051ZTrickOddFar()
  plan = bp051Special.clearPlan(1.0, false, true, 0)
  bp051Yes(plan[2] > 0.4999 and plan[2] < 0.5, "odd far")
  return true
end function
// Exercise the ztrick even test scenario and verify its expected result.
function bp051ZTrickEven()
  plan = bp051Special.clearPlan(1.0, false, true, 1)
  bp051Equal(plan[0], 0, "even mask")
  bp051Equal(plan[1], 1.0, "even near")
  bp051Equal(plan[2], 0.5, "even far")
  bp051Equal(plan[3], bp051Gl.GL_GEQUAL, "even function")
  bp051Equal(plan[4], 2, "even frame")
  return true
end function
// Exercise the ztrick color test scenario and verify its expected result.
function bp051ZTrickColor()
  plan = bp051Special.clearPlan(1.0, true, true, 0)
  bp051Equal(plan[0], bp051Gl.GL_COLOR_BUFFER_BIT, "ztrick color mask")
  return true
end function
// Exercise the normal depth test scenario and verify its expected result.
function bp051NormalDepth()
  plan = bp051Special.clearPlan(1.0, false, false, 4)
  bp051Equal(plan[0], bp051Gl.GL_DEPTH_BUFFER_BIT, "normal mask")
  bp051Equal(plan[1], 0.0, "normal near")
  bp051Equal(plan[2], 1.0, "normal far")
  bp051Equal(plan[3], bp051Gl.GL_LEQUAL, "normal function")
  bp051Equal(plan[4], 4, "normal frame")
  return true
end function
// Exercise the normal color test scenario and verify its expected result.
function bp051NormalColor()
  plan = bp051Special.clearPlan(1.0, true, false, 4)
  bp051Equal(plan[0], bp051Gl.GL_DEPTH_BUFFER_BIT | bp051Gl.GL_COLOR_BUFFER_BIT, "normal color mask")
  return true
end function
// Exercise the configure state test scenario and verify its expected result.
function bp051ConfigureState()
  state = bp051World.R_ConfigureSpecialCompatibility(0.75, true, false, true, true)
  bp051Equal(state[0], 0.75, "state alpha")
  bp051Equal(state[1], true, "state clear")
  bp051Equal(state[2], false, "state ztrick")
  bp051Equal(state[3], true, "state finish")
  bp051Equal(state[4], true, "state norefresh")
  return true
end function
// Exercise the state vector test scenario and verify its expected result.
function bp051StateVector()
  bp051World.R_ConfigureSpecialCompatibility(0.625, false, true, false, false)
  state = bp051World.R_SpecialCompatibilityState()
  bp051Equal(len(state), 8, "state vector length")
  bp051Equal(state[0], 0.625, "state vector alpha")
  return true
end function
// Exercise the world mirror trace test scenario and verify its expected result.
function bp051WorldMirrorTrace()
  bp051World.R_ConfigureSpecialCompatibility(0.5, false, true, false, false)
  bp051Gl.Trace_Begin()
  plan = bp051World.R_ClearProduction()
  trace = bp051Gl.Trace_End()
  bp051Equal(plan[2], 0.5, "world mirror far")
  bp051Equal(len(trace), 3, "world mirror trace count")
  bp051Equal(trace[0][0], "clear", "world mirror clear")
  bp051Equal(trace[1][0], "depth_func", "world mirror depth function")
  bp051Equal(trace[2][0], "depth_range", "world mirror depth range")
  return true
end function
// Exercise the world normal trace test scenario and verify its expected result.
function bp051WorldNormalTrace()
  bp051World.R_ConfigureSpecialCompatibility(1.0, false, false, false, false)
  bp051Gl.Trace_Begin()
  plan = bp051World.R_ClearProduction()
  trace = bp051Gl.Trace_End()
  bp051Equal(plan[2], 1.0, "world normal far")
  bp051Equal(len(trace), 3, "world normal trace count")
  return true
end function
// Exercise the world ztrick trace test scenario and verify its expected result.
function bp051WorldZTrickTrace()
  bp051World.R_ConfigureSpecialCompatibility(1.0, false, true, false, false)
  bp051Gl.Trace_Begin()
  plan = bp051World.R_ClearProduction()
  trace = bp051Gl.Trace_End()
  bp051Equal(plan[0], 0, "world ztrick no clear")
  bp051Equal(len(trace), 2, "world ztrick trace count")
  return true
end function
// Exercise the no refresh state test scenario and verify its expected result.
function bp051NoRefreshState()
  bp051World.R_ConfigureSpecialCompatibility(1.0, false, true, false, true)
  state = bp051World.R_SpecialCompatibilityState()
  bp051Equal(state[4], true, "no refresh state")
  return true
end function
// Finalize state for state.
function bp051FinishState()
  bp051World.R_ConfigureSpecialCompatibility(1.0, false, true, true, false)
  state = bp051World.R_SpecialCompatibilityState()
  bp051Equal(state[3], true, "finish state")
  return true
end function
// Exercise the mirror dominates ztrick test scenario and verify its expected result.
function bp051MirrorDominatesZTrick()
  plan = bp051Special.clearPlan(0.999, false, true, 11)
  bp051Equal(plan[4], 11, "mirror does not advance ztrick")
  bp051Equal(plan[2], 0.5, "mirror split")
  return true
end function
// Exercise the exact alpha one test scenario and verify its expected result.
function bp051ExactAlphaOne()
  plan = bp051Special.clearPlan(1.0, false, true, 0)
  bp051Equal(plan[4], 1, "exact one activates ztrick")
  return true
end function
// Exercise the alpha above one test scenario and verify its expected result.
function bp051AlphaAboveOne()
  plan = bp051Special.clearPlan(1.001, false, true, 0)
  bp051Equal(plan[2], 0.5, "non-one mirror alpha")
  return true
end function
// Exercise the depth constants test scenario and verify its expected result.
function bp051DepthConstants()
  bp051Equal(bp051Gl.GL_LEQUAL, 0x0203, "LEQUAL")
  bp051Equal(bp051Gl.GL_GEQUAL, 0x0206, "GEQUAL")
  return true
end function
// Update module state for constants.
function bp051ClearConstants()
  bp051Equal(bp051Gl.GL_DEPTH_BUFFER_BIT, 0x00000100, "depth bit")
  bp051Equal(bp051Gl.GL_COLOR_BUFFER_BIT, 0x00004000, "color bit")
  return true
end function

passed = 0
if bp051Run(1, "mirror depth clear", bp051MirrorDepth) then passed = passed + 1 end if
if bp051Run(2, "mirror color clear", bp051MirrorColor) then passed = passed + 1 end if
if bp051Run(3, "ztrick odd range", bp051ZTrickOdd) then passed = passed + 1 end if
if bp051Run(4, "ztrick odd far", bp051ZTrickOddFar) then passed = passed + 1 end if
if bp051Run(5, "ztrick even range", bp051ZTrickEven) then passed = passed + 1 end if
if bp051Run(6, "ztrick color clear", bp051ZTrickColor) then passed = passed + 1 end if
if bp051Run(7, "normal depth clear", bp051NormalDepth) then passed = passed + 1 end if
if bp051Run(8, "normal color clear", bp051NormalColor) then passed = passed + 1 end if
if bp051Run(9, "special cvar configuration", bp051ConfigureState) then passed = passed + 1 end if
if bp051Run(10, "special state vector", bp051StateVector) then passed = passed + 1 end if
if bp051Run(11, "world mirror GL trace", bp051WorldMirrorTrace) then passed = passed + 1 end if
if bp051Run(12, "world normal GL trace", bp051WorldNormalTrace) then passed = passed + 1 end if
if bp051Run(13, "world ztrick GL trace", bp051WorldZTrickTrace) then passed = passed + 1 end if
if bp051Run(14, "norefresh state", bp051NoRefreshState) then passed = passed + 1 end if
if bp051Run(15, "finish state", bp051FinishState) then passed = passed + 1 end if
if bp051Run(16, "mirror dominates ztrick", bp051MirrorDominatesZTrick) then passed = passed + 1 end if
if bp051Run(17, "exact alpha one", bp051ExactAlphaOne) then passed = passed + 1 end if
if bp051Run(18, "non-one mirror alpha", bp051AlphaAboveOne) then passed = passed + 1 end if
if bp051Run(19, "depth constants", bp051DepthConstants) then passed = passed + 1 end if
if bp051Run(20, "clear constants", bp051ClearConstants) then passed = passed + 1 end if
if passed != 20 then print "MiniQuake BP-051 render-clear special tests failed: " + passed + "/20"; error(5199, "BP-051 render clear") end if
print "MiniQuake BP-051 render-clear special tests passed: 20"
