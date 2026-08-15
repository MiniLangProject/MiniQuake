/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/stability_contract_tests.ml.
*/
import miniquake.stability_contract as stability

passed = 0
failed = 0

// Assert that the condition holds and identify a failing test.
function bp088Check(condition, label)
  global passed, failed
  if condition then passed = passed + 1; return true end if
  print "FAIL: " + label
  failed = failed + 1
  return false
end function

// Assert exact equality and report both values on failure.
function bp088Equal(actual, expected, label)
  return bp088Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

// Exercise the snapshot test scenario and verify its expected result.
function inline bp088Snapshot()
  return [100, 100000, 50000, 10000, 90, 85, 1, 1, 7, 0, 0, 0, 1, 0, 4, 50]
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global passed, failed
  print "[1/20] status"
  bp088Equal(stability.STATUS, "stability_109_frozen_v1", "status")
  print "[2/20] fingerprint"
  bp088Equal(stability.FINGERPRINT, 0xd0e3c03f, "fingerprint")
  print "[3/20] host frames"
  bp088Equal(stability.DEFAULT_SOAK_FRAMES, 5000, "host frames")
  print "[4/20] listen frames"
  bp088Equal(stability.LISTEN_SOAK_FRAMES, 5000, "listen frames")
  print "[5/20] mode count"
  bp088Equal(len(stability.modes()), 2, "mode count")
  print "[6/20] host mode"
  bp088Equal(stability.modes()[0], "host", "host mode")
  print "[7/20] listen mode"
  bp088Equal(stability.modes()[1], "listen", "listen mode")
  print "[8/20] delta stable exact"
  bp088Check(stability.deltaStable(10, 10, 0), "delta exact")
  print "[9/20] delta stable allowance"
  bp088Check(stability.deltaStable(10, 15, 5), "delta allowance")
  print "[10/20] delta unstable"
  bp088Check(not stability.deltaStable(10, 16, 5), "delta unstable")
  print "[11/20] host stable"
  bp088Check(stability.hostStable(100, 164, 1000, 1049576), "host stable")
  print "[12/20] host live unstable"
  bp088Check(not stability.hostStable(100, 165, 1000, 1000), "host live unstable")
  print "[13/20] host bytes unstable"
  bp088Check(not stability.hostStable(100, 100, 1000, 1049577), "host bytes unstable")

  before = bp088Snapshot()
  after = bp088Snapshot()
  print "[14/20] long stable exact"
  bp088Check(stability.longStable(before, after), "long exact")

  catchupBefore = bp088Snapshot()
  catchupBefore[4] = 67
  catchupBefore[5] = 66
  catchupAfter = bp088Snapshot()
  catchupAfter[4] = 67
  catchupAfter[5] = 67
  staticBefore = bp088Snapshot()
  staticBefore[4] = 90
  staticBefore[5] = 96
  staticAfter = bp088Snapshot()
  staticAfter[4] = 90
  staticAfter[5] = 96
  print "[15/20] client entity high-water catch-up"
  bp088Check(
    stability.longStable(catchupBefore, catchupAfter) and
      stability.clientEntityLimit(67, 67, 66) == 67 and
      stability.longStable(staticBefore, staticAfter) and
      stability.clientEntityLimit(90, 90, 96) == 96,
    "client high-water catch-up",
  )

  overflowAfter = bp088Snapshot()
  overflowAfter[4] = 67
  overflowAfter[5] = 68
  staticOverflow = bp088Snapshot()
  staticOverflow[4] = 90
  staticOverflow[5] = 97
  serverGrowth = bp088Snapshot()
  serverGrowth[4] = 68
  serverGrowth[5] = 67
  print "[16/20] topology growth rejected"
  bp088Check(
    not stability.longStable(catchupBefore, overflowAfter) and
      not stability.longStable(staticBefore, staticOverflow) and
      not stability.longStable(catchupBefore, serverGrowth),
    "topology growth rejected",
  )

  afterBlocks = bp088Snapshot()
  afterBlocks[0] = before[0] + 512
  blockAllowance = stability.longStable(before, afterBlocks)
  afterBlocks[0] = before[0] + 513
  print "[17/20] long block boundary"
  bp088Check(blockAllowance and not stability.longStable(before, afterBlocks), "block boundary")

  afterBytes = bp088Snapshot()
  afterBytes[2] = before[2] + 65537
  print "[18/20] long byte overflow"
  bp088Check(not stability.longStable(before, afterBytes), "byte overflow")

  afterSockets = bp088Snapshot()
  afterSockets[7] = before[7] + 1
  print "[19/20] socket leak"
  bp088Check(not stability.longStable(before, afterSockets), "socket leak")

  print "[20/20] short snapshot and contract text"
  bp088Check(
    not stability.longStable([1], [1]) and
      stability.CLIENT_ENTITY_POLICY == "server_high_water_plus_existing_static_offset" and
      len(bytes(stability.CONTRACT_TEXT)) > 32,
    "short snapshot and contract text",
  )

  if failed > 0 then print "MiniQuake BP-088 stability tests failed: " + failed + "/20"; return 1 end if
  print "MiniQuake BP-088 stability tests passed: 20"
  return 0
end function
