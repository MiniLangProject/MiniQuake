/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/opt001b_contract_tests.ml.
*/
import miniquake.optimization_baseline as opt
import miniquake.render.entities as entities

opt001bPassed = 0
opt001bFailed = 0

// Assert that the condition holds and identify a failing test.
function opt001bCheck(condition, label)
  global opt001bPassed, opt001bFailed
  if condition then
    opt001bPassed = opt001bPassed + 1
    print "[PASS] " + label
  else
    opt001bFailed = opt001bFailed + 1
    print "[FAIL] " + label
  end if
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  normal = entities.viewModelDepthRange(0.0, 1.0)
  opt001bCheck(normal[0] == 0.0, "normal weapon depth min")
  opt001bCheck(normal[1] == 0.3, "normal weapon depth max")

  lower = entities.viewModelDepthRange(0.0, 0.5)
  opt001bCheck(lower[0] == 0.0, "lower ztrick weapon depth min")
  opt001bCheck(lower[1] == 0.15, "lower ztrick weapon depth max")

  reverse = entities.viewModelDepthRange(1.0, 0.5)
  opt001bCheck(reverse[0] == 1.0, "reverse ztrick weapon depth min")
  opt001bCheck(reverse[1] == 0.85, "reverse ztrick weapon depth max")

  opt001bCheck(opt.classifyHandles([278, 278, 279, 279], true) == "PLATEAU", "delayed one-handle plateau")
  opt001bCheck(opt.classifyHandles([278, 279, 280, 281], true) == "LEAK", "continued handle growth")
  opt001bCheck(opt.classifyHandles([278, 278, 278, 278], true) == "STABLE", "stable handle sequence")
  opt001bCheck(opt.classifyHandles([278, 278, 279, 280], true) == "INCONCLUSIVE", "unsettled handle sequence")

  print "MiniQuake OPT-001B correctness tests passed: " + opt001bPassed
  if opt001bFailed > 0 then
    print "MiniQuake OPT-001B correctness tests failed: " + opt001bFailed
    return 1
  end if
  return 0
end function
