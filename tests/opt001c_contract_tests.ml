/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/opt001c_contract_tests.ml.
*/
import miniquake.build_info as buildInfo
import miniquake.render.gl11 as gl

opt001cPassed = 0
opt001cFailed = 0

// Assert that the condition holds and identify a failing test.
function opt001cCheck(condition, label)
  global opt001cPassed, opt001cFailed
  if condition then
    opt001cPassed = opt001cPassed + 1
    print "[PASS] " + label
  else
    opt001cFailed = opt001cFailed + 1
    print "[FAIL] " + label
  end if
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  opt001cCheck(buildInfo.OPT001C_STATUS == "opt001c_frame_allocation_candidate_v1", "optimization status")
  opt001cCheck(buildInfo.OPT001C_FINGERPRINT == 0x1c001c03, "optimization fingerprint")
  opt001cCheck(buildInfo.OPT001C_PARENT == "OPT-001B", "optimization parent")
  opt001cCheck(not gl.traceEnabled(), "trace disabled initially")

  gl.Trace_Begin()
  opt001cCheck(gl.traceEnabled(), "trace enabled")
  gl.begin(gl.GL_POLYGON)
  gl.texcoord2(0.25, 0.75)
  gl.vertex3(1.0, 2.0, 3.0)
  gl.colorFloat(1.0, 0.5, 0.25, 1.0)
  gl.finishPrimitive()
  trace = gl.Trace_End()

  opt001cCheck(not gl.traceEnabled(), "trace disabled after end")
  opt001cCheck(len(trace) == 5, "trace command count")
  opt001cCheck(trace[0][0] == "begin", "begin command preserved")
  opt001cCheck(len(trace[0][1]) == 1 and trace[0][1][0] == gl.GL_POLYGON, "begin arguments preserved")
  opt001cCheck(trace[1][0] == "texcoord" and len(trace[1][1]) == 2, "texcoord arguments preserved")
  opt001cCheck(trace[2][0] == "vertex" and len(trace[2][1]) == 3, "vertex arguments preserved")
  opt001cCheck(trace[2][1][0] == 1.0 and trace[2][1][1] == 2.0 and trace[2][1][2] == 3.0, "vertex values preserved")
  opt001cCheck(trace[3][0] == "color" and len(trace[3][1]) == 4, "color arguments preserved")
  opt001cCheck(trace[4][0] == "end" and len(trace[4][1]) == 0, "end command preserved")

  print "MiniQuake OPT-001C allocation tests passed: " + opt001cPassed
  if opt001cFailed > 0 then
    print "MiniQuake OPT-001C allocation tests failed: " + opt001cFailed
    return 1
  end if
  return 0
end function
