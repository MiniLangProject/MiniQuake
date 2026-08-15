/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-053: deterministic multi-scene render-evidence corpus.
*/
import miniquake.render_evidence_corpus as bp053Corpus

// Assert exact equality and report both values on failure.
function bp053Equal(actual, expected, name)
  if actual != expected then return error(5300, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp053Yes(value, name)
  if not value then return error(5301, name + ": expected true") end if
  return true
end function
// Assert floating-point equality within the requested tolerance.
function bp053Near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(5302, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp053Run(number, name, fn)
  print "[" + number + "/18] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Exercise the schema test scenario and verify its expected result.
function bp053Schema()
  bp053Equal(bp053Corpus.CORPUS_SCHEMA, 1, "corpus schema")
  return true
end function
// Return count derived from the active module state.
function bp053Count()
  bp053Equal(bp053Corpus.count(), 3, "scenario count")
  return true
end function
// Return first name for the active module state.
function bp053FirstName()
  bp053Equal(bp053Corpus.name(0), "start-064", "first name")
  return true
end function
// Return first map for the active module state.
function bp053FirstMap()
  bp053Equal(bp053Corpus.mapName(0), "start", "first map")
  return true
end function
// Return first frame for the active module state.
function bp053FirstFrame()
  bp053Equal(bp053Corpus.frame(0), 64, "first frame")
  return true
end function
// Exercise the second test scenario and verify its expected result.
function bp053Second()
  value = bp053Corpus.scenario(1)
  bp053Equal(value[0], "start-128", "second name")
  bp053Equal(value[1], "start", "second map")
  bp053Equal(value[2], 128, "second frame")
  return true
end function
// Exercise the third test scenario and verify its expected result.
function bp053Third()
  value = bp053Corpus.scenario(2)
  bp053Equal(value[0], "e1m1-128", "third name")
  bp053Equal(value[1], "e1m1", "third map")
  bp053Equal(value[2], 128, "third frame")
  return true
end function
// Exercise the bounds test scenario and verify its expected result.
function bp053Bounds()
  value = try(bp053Corpus.scenario(3))
  bp053Yes(value is error, "scenario bounds")
  return true
end function
// Exercise the prefix test scenario and verify its expected result.
function bp053Prefix()
  bp053Equal(bp053Corpus.miniPrefix("root", 1, "a"), "root/start-128-a", "mini prefix")
  return true
end function
// Exercise the original name test scenario and verify its expected result.
function bp053OriginalName()
  bp053Equal(bp053Corpus.originalFileName(2), "e1m1-128.tga", "original file")
  return true
end function
// Exercise the exact pair test scenario and verify its expected result.
function bp053ExactPair()
  bp053Yes(bp053Corpus.exactPair("aa", "aa", "bb", "bb"), "exact pair")
  return true
end function
// Exercise the different pair test scenario and verify its expected result.
function bp053DifferentPair()
  bp053Equal(bp053Corpus.exactPair("aa", "ab", "bb", "bb"), false, "different pair")
  return true
end function
// Exercise the ssim accept test scenario and verify its expected result.
function bp053SsimAccept()
  bp053Yes(bp053Corpus.ssimAccepted(0.95), "SSIM threshold")
  return true
end function
// Exercise the ssim reject test scenario and verify its expected result.
function bp053SsimReject()
  bp053Equal(bp053Corpus.ssimAccepted(0.949), false, "SSIM rejection")
  return true
end function
// Exercise the minimum test scenario and verify its expected result.
function bp053Minimum()
  bp053Near(bp053Corpus.minimum([1.0, 0.97, 0.99]), 0.97, 0.000001, "minimum")
  return true
end function
// Exercise the average test scenario and verify its expected result.
function bp053Average()
  bp053Near(bp053Corpus.average([1.0, 0.5, 1.0]), 0.8333333333, 0.00001, "average")
  return true
end function
// Exercise the dimensions test scenario and verify its expected result.
function bp053Dimensions()
  bp053Equal(bp053Corpus.CAPTURE_WIDTH, 640, "capture width")
  bp053Equal(bp053Corpus.CAPTURE_HEIGHT, 480, "capture height")
  return true
end function
// Exercise the vector test scenario and verify its expected result.
function bp053Vector()
  value = bp053Corpus.contractVector()
  bp053Equal(len(value), 6, "contract vector length")
  bp053Equal(value[3], 3, "contract scenario count")
  bp053Equal(value[4], 950, "contract SSIM")
  return true
end function

passed = 0
if bp053Run(1, "corpus schema", bp053Schema) then passed = passed + 1 end if
if bp053Run(2, "scenario count", bp053Count) then passed = passed + 1 end if
if bp053Run(3, "first scenario name", bp053FirstName) then passed = passed + 1 end if
if bp053Run(4, "first scenario map", bp053FirstMap) then passed = passed + 1 end if
if bp053Run(5, "first scenario frame", bp053FirstFrame) then passed = passed + 1 end if
if bp053Run(6, "second scenario", bp053Second) then passed = passed + 1 end if
if bp053Run(7, "third scenario", bp053Third) then passed = passed + 1 end if
if bp053Run(8, "scenario bounds", bp053Bounds) then passed = passed + 1 end if
if bp053Run(9, "mini prefix", bp053Prefix) then passed = passed + 1 end if
if bp053Run(10, "original file name", bp053OriginalName) then passed = passed + 1 end if
if bp053Run(11, "exact evidence pair", bp053ExactPair) then passed = passed + 1 end if
if bp053Run(12, "different evidence pair", bp053DifferentPair) then passed = passed + 1 end if
if bp053Run(13, "SSIM accepted", bp053SsimAccept) then passed = passed + 1 end if
if bp053Run(14, "SSIM rejected", bp053SsimReject) then passed = passed + 1 end if
if bp053Run(15, "minimum SSIM", bp053Minimum) then passed = passed + 1 end if
if bp053Run(16, "average SSIM", bp053Average) then passed = passed + 1 end if
if bp053Run(17, "capture dimensions", bp053Dimensions) then passed = passed + 1 end if
if bp053Run(18, "corpus contract vector", bp053Vector) then passed = passed + 1 end if
if passed != 18 then print "MiniQuake BP-053 render-evidence corpus tests failed: " + passed + "/18"; error(5399, "BP-053 render evidence corpus") end if
print "MiniQuake BP-053 render-evidence corpus tests passed: 18"
