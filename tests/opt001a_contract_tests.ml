/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/opt001a_contract_tests.ml.
*/
import miniquake.optimization_baseline as opt

opt001aPassed = 0
opt001aFailed = 0

// Assert that the condition holds and identify a failing test.
function optCheck(condition, label)
  global opt001aPassed, opt001aFailed
  if condition then
    opt001aPassed = opt001aPassed + 1
    print "[PASS] " + label
  else
    opt001aFailed = opt001aFailed + 1
    print "[FAIL] " + label
  end if
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  optCheck(opt.classifyHandles([264, 264, 264, 264], true) == "STABLE", "stable handles")
  optCheck(opt.classifyHandles([264, 265, 265, 265], true) == "PLATEAU", "one-time plateau")
  optCheck(opt.classifyHandles([264, 265, 266, 267], true) == "LEAK", "monotonic leak")
  optCheck(opt.classifyHandles([264, 265, 265, 266], true) == "INCONCLUSIVE", "late change")
  optCheck(opt.classifyHandles([264, 264, 264, 264], false) == "RESOURCE_GROWTH", "non-handle resource growth")
  optCheck(opt.classifyHandles([1], true) == "INCONCLUSIVE", "insufficient samples")
  optCheck(opt.handleSequenceText([1, 2, 3, 3]) == "1,2,3,3", "handle sequence")
  optCheck(opt.stageIndex("demo_send") == opt.stageIndex("send"), "demo send bucket")
  optCheck(opt.stageIndex("local_send") == opt.stageIndex("send"), "local send bucket")
  optCheck(opt.stageIndex("remote_send") == opt.stageIndex("send"), "remote send bucket")
  optCheck(opt.stageIndex("unknown_stage") == 19, "unknown stage bucket")
  optCheck(not opt.enabled(), "profiling disabled by default")

  print "MiniQuake OPT-001A contract tests passed: " + opt001aPassed
  if opt001aFailed > 0 then
    print "MiniQuake OPT-001A contract tests failed: " + opt001aFailed
    return 1
  end if
  return 0
end function
