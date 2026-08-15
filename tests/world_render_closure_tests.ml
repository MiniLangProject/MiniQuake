/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-044: central MiniQuake viewport, culling, pass order and freeze contract.
*/
import miniquake.render.world as worldRender
import miniquake.world_render_contract as contract

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(4400, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(4401, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(4402, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert exact equality and report both values on failure.
function arrayEqual(actual, expected, name)
  equal(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    equal(actual[index], expected[index], name + "[" + index + "]")
    index = index + 1
  end while
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Verify status against the expected Quake behavior.
function testStatus()
  equal(contract.status(), "world_render_109_frozen_v1", "status")
  return true
end function

// Verify fingerprint against the expected Quake behavior.
function testFingerprint()
  equal(contract.fingerprint(), 0x846a74de, "fingerprint")
  return true
end function

// Verify near clip against the expected Quake behavior.
function testNearClip()
  equal(contract.constants()[0], 4, "near clip")
  return true
end function

// Verify far clip against the expected Quake behavior.
function testFarClip()
  equal(contract.constants()[1], 4096, "far clip")
  return true
end function

// Verify atlas width against the expected Quake behavior.
function testAtlasWidth()
  equal(contract.constants()[2], 128, "atlas width")
  return true
end function

// Verify atlas height against the expected Quake behavior.
function testAtlasHeight()
  equal(contract.constants()[3], 128, "atlas height")
  return true
end function

// Verify atlas pages against the expected Quake behavior.
function testAtlasPages()
  equal(contract.constants()[4], 64, "atlas pages")
  return true
end function

// Verify visible entities against the expected Quake behavior.
function testVisibleEntities()
  equal(contract.constants()[5], 256, "visible entities")
  return true
end function

// Verify backface epsilon against the expected Quake behavior.
function testBackfaceEpsilon()
  equal(contract.constants()[6], 10, "epsilon milli")
  return true
end function

// Verify stage count against the expected Quake behavior.
function testStageCount()
  equal(len(contract.stageOrder()), 7, "stage count")
  return true
end function

// Verify stage world against the expected Quake behavior.
function testStageWorld()
  equal(contract.stageOrder()[0], 1, "world stage")
  return true
end function

// Verify stage entities against the expected Quake behavior.
function testStageEntities()
  equal(contract.stageOrder()[1], 2, "entity stage")
  return true
end function

// Verify stage dlights against the expected Quake behavior.
function testStageDlights()
  equal(contract.stageOrder()[2], 3, "dlight stage")
  return true
end function

// Verify stage particles against the expected Quake behavior.
function testStageParticles()
  equal(contract.stageOrder()[3], 4, "particle stage")
  return true
end function

// Verify stage viewmodel against the expected Quake behavior.
function testStageViewmodel()
  equal(contract.stageOrder()[4], 5, "viewmodel stage")
  return true
end function

// Verify stage water against the expected Quake behavior.
function testStageWater()
  equal(contract.stageOrder()[5], 6, "water stage")
  return true
end function

// Verify stage polyblend against the expected Quake behavior.
function testStagePolyblend()
  equal(contract.stageOrder()[6], 7, "polyblend stage")
  return true
end function

// Verify named stage order against the expected Quake behavior.
function testNamedStageOrder()
  arrayEqual(
    worldRender.R_MainRenderStageOrder(),
    ["world", "entities", "dlights", "particles", "viewmodel", "water", "polyblend"],
    "named stages",
  )
  return true
end function

// Verify full viewport against the expected Quake behavior.
function testFullViewport()
  arrayEqual(worldRender.R_ViewportRect(0, 0, 640, 480, 640, 480), [0, 0, 640, 480], "full viewport")
  return true
end function

// Verify inset viewport against the expected Quake behavior.
function testInsetViewport()
  arrayEqual(worldRender.R_ViewportRect(100, 50, 320, 200, 640, 480), [99, 230, 322, 201], "inset viewport")
  return true
end function

// Verify right edge viewport against the expected Quake behavior.
function testRightEdgeViewport()
  arrayEqual(worldRender.R_ViewportRect(320, 0, 320, 480, 640, 480), [319, 0, 321, 480], "right edge")
  return true
end function

// Verify bottom edge viewport against the expected Quake behavior.
function testBottomEdgeViewport()
  arrayEqual(worldRender.R_ViewportRect(0, 280, 640, 200, 640, 480), [0, 0, 640, 201], "bottom edge")
  return true
end function

// Verify cull enabled against the expected Quake behavior.
function testCullEnabled()
  yes(worldRender.R_SetCullCompatibility(true), "cull enabled")
  return true
end function

// Verify cull disabled against the expected Quake behavior.
function testCullDisabled()
  no(worldRender.R_SetCullCompatibility(false), "cull disabled")
  return true
end function

passed = 0
if run(1, "world-render contract status", testStatus) then passed = passed + 1 end if
if run(2, "world-render contract fingerprint", testFingerprint) then passed = passed + 1 end if
if run(3, "projection near clip", testNearClip) then passed = passed + 1 end if
if run(4, "projection far clip", testFarClip) then passed = passed + 1 end if
if run(5, "lightmap atlas width", testAtlasWidth) then passed = passed + 1 end if
if run(6, "lightmap atlas height", testAtlasHeight) then passed = passed + 1 end if
if run(7, "lightmap atlas pages", testAtlasPages) then passed = passed + 1 end if
if run(8, "visible entity limit", testVisibleEntities) then passed = passed + 1 end if
if run(9, "brush backface epsilon", testBackfaceEpsilon) then passed = passed + 1 end if
if run(10, "central render stage count", testStageCount) then passed = passed + 1 end if
if run(11, "world render stage", testStageWorld) then passed = passed + 1 end if
if run(12, "entity render stage", testStageEntities) then passed = passed + 1 end if
if run(13, "dynamic-light stage", testStageDlights) then passed = passed + 1 end if
if run(14, "particle stage", testStageParticles) then passed = passed + 1 end if
if run(15, "viewmodel stage", testStageViewmodel) then passed = passed + 1 end if
if run(16, "deferred water stage", testStageWater) then passed = passed + 1 end if
if run(17, "polyblend stage", testStagePolyblend) then passed = passed + 1 end if
if run(18, "named production stage order", testNamedStageOrder) then passed = passed + 1 end if
if run(19, "full framebuffer viewport", testFullViewport) then passed = passed + 1 end if
if run(20, "fractional-scale viewport fudge", testInsetViewport) then passed = passed + 1 end if
if run(21, "right-edge viewport fudge", testRightEdgeViewport) then passed = passed + 1 end if
if run(22, "bottom-edge viewport fudge", testBottomEdgeViewport) then passed = passed + 1 end if
if run(23, "GL culling enabled", testCullEnabled) then passed = passed + 1 end if
if run(24, "GL culling disabled", testCullDisabled) then passed = passed + 1 end if

if passed != 24 then error(4499, "BP-044 world-render closure tests failed: " + passed + "/24") end if
print "MiniQuake BP-044 world-render closure tests passed: 24"
