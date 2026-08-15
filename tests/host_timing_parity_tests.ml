/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-030: WinQuake Host_FilterTime and frame-clock parity.
*/
import miniquake.host_timing as timing
import miniquake.native as native

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3000, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(3001, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3002, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3003, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/18] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify initial against the expected Quake behavior.
function testInitial()
  value = timing.create()
  equal(value.frameCount, 0, "initial frame count")
  near(value.realtime, 0.0, 0.0, "initial realtime")
  return true
end function

// Verify filter below threshold against the expected Quake behavior.
function testFilterBelowThreshold()
  value = timing.create()
  no(timing.filter(value, 0.001, false, 0.0, 1.0, 72.0), "sub-threshold frame")
  equal(value.frameCount, 0, "filtered count does not advance frame")
  equal(value.filteredFrames, 1, "filtered frame counter")
  near(value.oldRealtime, 0.0, 0.0, "old realtime retained")
  return true
end function

// Verify accumulation across filtered calls against the expected Quake behavior.
function testAccumulationAcrossFilteredCalls()
  value = timing.create()
  // Mirror the independent C oracle exactly: 0.001 + 0.007 remains below
  // 1/72, while the following 0.007 advances the accumulated clock to 0.015.
  no(timing.filter(value, 0.001, false, 0.0, 1.0, 72.0), "first filtered")
  no(timing.filter(value, 0.007, false, 0.0, 1.0, 72.0), "second filtered")
  yes(timing.filter(value, 0.007, false, 0.0, 1.0, 72.0), "accumulated frame")
  equal(value.filteredFrames, 2, "accumulated filtered count")
  equal(value.frameCount, 1, "accumulated accepted count")
  near(value.realtime, 0.015, 0.000001, "accumulated realtime")
  near(value.oldRealtime, value.realtime, 0.0, "accepted old realtime")
  near(value.frameTime, 0.015, 0.000001, "accumulated frame time")
  return true
end function

// Verify timedemo bypasses filter against the expected Quake behavior.
function testTimedemoBypassesFilter()
  value = timing.create()
  yes(timing.filter(value, 0.0001, true, 0.0, 1.0, 72.0), "timedemo frame")
  near(value.frameTime, 0.001, 0.0, "timedemo minimum clamp")
  return true
end function

// Verify minimum clamp against the expected Quake behavior.
function testMinimumClamp()
  value = timing.create()
  yes(timing.filterAbsolute(value, 0.0005, 0.0, 0.0, true, 1.0), "minimum clamp frame")
  near(value.frameTime, 0.001, 0.0, "minimum clamp")
  return true
end function

// Verify maximum clamp against the expected Quake behavior.
function testMaximumClamp()
  value = timing.create()
  yes(timing.filter(value, 1.0, false, 0.0, 1.0, 72.0), "maximum clamp frame")
  near(value.frameTime, 0.1, 0.0, "maximum clamp")
  return true
end function

// Verify forced rate not clamped against the expected Quake behavior.
function testForcedRateNotClamped()
  value = timing.create()
  yes(timing.filter(value, 0.02, false, 0.25, 1.0, 72.0), "forced frame")
  near(value.frameTime, 0.25, 0.0, "forced frame not clamped")
  return true
end function

// Verify forced rate does not change realtime against the expected Quake behavior.
function testForcedRateDoesNotChangeRealtime()
  value = timing.create()
  yes(timing.filter(value, 0.02, false, 0.5, 1.0, 72.0), "forced frame")
  near(value.realtime, timing.binary32(0.02), 0.000000001, "realtime uses platform delta")
  near(value.oldRealtime, value.realtime, 0.0, "old realtime follows realtime")
  return true
end function

// Verify float input boundary against the expected Quake behavior.
function testFloatInputBoundary()
  value = timing.create()
  precise = 0.020000000123
  yes(timing.filter(value, precise, false, 0.0, 1.0, 72.0), "float-boundary frame")
  expected = native.bitsFloat(native.floatBits(precise))
  near(value.realtime, expected, 0.0, "input rounded to binary32")
  return true
end function

// Verify absolute clock is double against the expected Quake behavior.
function testAbsoluteClockIsDouble()
  value = timing.create()
  base = 123456.0
  value.realtime = base
  value.oldRealtime = base
  yes(timing.filterAbsolute(value, base + 0.02, 72.0, 0.0, false, 1.0), "absolute clock")
  near(value.frameTime, 0.02, 0.00000001, "double absolute delta")
  return true
end function

// Verify time scale after clamp against the expected Quake behavior.
function testTimeScaleAfterClamp()
  value = timing.create()
  yes(timing.filter(value, 1.0, false, 0.0, 0.5, 72.0), "scaled frame")
  near(value.frameTime, 0.05, 0.0, "scale follows maximum clamp")
  return true
end function

// Verify zero scale means original against the expected Quake behavior.
function testZeroScaleMeansOriginal()
  value = timing.create()
  yes(timing.filter(value, 0.02, false, 0.0, 0.0, 72.0), "zero scale extension disabled")
  near(value.frameTime, timing.binary32(0.02), 0.000000001, "zero scale leaves frame")
  return true
end function

// Verify frame counter against the expected Quake behavior.
function testFrameCounter()
  value = timing.create()
  yes(timing.filter(value, 0.02, false, 0.0, 1.0, 72.0), "first")
  yes(timing.filter(value, 0.02, false, 0.0, 1.0, 72.0), "second")
  equal(value.frameCount, 2, "accepted frame count")
  return true
end function

// Verify filtered counter only against the expected Quake behavior.
function testFilteredCounterOnly()
  value = timing.create()
  no(timing.filter(value, 0.001, false, 0.0, 1.0, 72.0), "filtered one")
  no(timing.filter(value, 0.001, false, 0.0, 1.0, 72.0), "filtered two")
  equal(value.filteredFrames, 2, "filtered count")
  return true
end function

// Verify milliseconds minimum against the expected Quake behavior.
function testMillisecondsMinimum()
  value = timing.create()
  value.frameTime = 0.0001
  equal(timing.milliseconds(value), 1, "minimum milliseconds")
  return true
end function

// Verify milliseconds truncates against the expected Quake behavior.
function testMillisecondsTruncates()
  value = timing.create()
  value.frameTime = 0.0169
  equal(timing.milliseconds(value), 16, "milliseconds truncation")
  return true
end function

// Verify milliseconds maximum against the expected Quake behavior.
function testMillisecondsMaximum()
  value = timing.create()
  value.frameTime = 1.0
  equal(timing.milliseconds(value), 255, "maximum milliseconds")
  return true
end function

// Verify negative platform delta preserved against the expected Quake behavior.
function testNegativePlatformDeltaPreserved()
  value = timing.create()
  no(timing.filter(value, -0.01, false, 0.0, 1.0, 72.0), "negative delta remains filtered")
  yes(value.realtime < 0.0, "negative realtime is not silently clamped")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  tests = [
    ["initial state", testInitial],
    ["threshold filtering", testFilterBelowThreshold],
    ["filtered accumulation", testAccumulationAcrossFilteredCalls],
    ["timedemo bypass", testTimedemoBypassesFilter],
    ["minimum clamp", testMinimumClamp],
    ["maximum clamp", testMaximumClamp],
    ["forced rate", testForcedRateNotClamped],
    ["forced realtime", testForcedRateDoesNotChangeRealtime],
    ["platform float boundary", testFloatInputBoundary],
    ["absolute double clock", testAbsoluteClockIsDouble],
    ["time scale order", testTimeScaleAfterClamp],
    ["zero scale", testZeroScaleMeansOriginal],
    ["frame counter", testFrameCounter],
    ["filtered counter", testFilteredCounterOnly],
    ["milliseconds minimum", testMillisecondsMinimum],
    ["milliseconds truncation", testMillisecondsTruncates],
    ["milliseconds maximum", testMillisecondsMaximum],
    ["negative delta", testNegativePlatformDeltaPreserved],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 18 then return 1 end if
  print "MiniQuake BP-030 host timing tests passed: 18"
  return 0
end function
