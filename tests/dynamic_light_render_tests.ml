/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-042: dynamic-light marking, frame order, and brush-model light roots.
*/
import miniquake.render.world as worldRender
import miniquake.types as t
import miniquake.constants as c

struct BrushEntity
  modelIndex
  origin
  angles
end struct

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(4200, name + ": expected true") end if
  return true
end function

// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(4201, name + ": expected false") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(4202, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Exercise light as part of this deterministic regression fixture.
function light(radius, die)
  return t.DynamicLight(t.Vec3(0.0, 0.0, 8.0), radius, die, 0.0, 0.0, 0)
end function

// Exercise setup as part of this deterministic regression fixture.
function setup(lights, flashBlend, dynamicEnabled, includeModels)
  zero = t.Vec3(0.0, 0.0, 0.0)
  minimum = t.Vec3(-32.0, -32.0, -32.0)
  maximum = t.Vec3(32.0, 32.0, 32.0)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -1, -2, minimum, maximum, 0, 2)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  face0 = t.BspFace(0, 0, 0, 0, 0, bytes([0, 255, 255, 255]), 0)
  face1 = t.BspFace(0, 0, 0, 0, 0, bytes([0, 255, 255, 255]), 1)
  models = []
  if includeModels then
    models = [
      t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 0, 0, 1),
      t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 0, 1, 1),
      t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 0, 0, 1),
    ]
  end if
  map = t.BspMap("bp042.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [], bytes(), [node], [info], [face0, face1], bytes([8, 8]), [], [], [], [], [], models)
  surfaces = [
    t.RenderSurface(0, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, 0, 0, [], 500),
    t.RenderSurface(1, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, 1, 0, [], 500),
  ]
  renderer = t.WorldRenderer(map, bytes(), [], surfaces, [], true, 0, false, false, 0, bytes(2, 1), 0, 1.0)
  worldRender.R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    lights, [], [0.0, 0.0, 0.0, 0.0], 1.0, 1.0, 0.02,
    flashBlend, dynamicEnabled, false,
  )
  worldRender.R_SetFrameCompatibility(7, 1)
  worldRender.R_SetSurfaceCompatibilityState(0, 0, 0, [256, 0, 0, 0], false, 0, 0, 0)
  worldRender.R_SetSurfaceCompatibilityState(1, 0, 0, [256, 0, 0, 0], false, 0, 0, 0)
  return renderer
end function

// Verify active at deadline against the expected Quake behavior.
function testActiveAtDeadline()
  yes(worldRender.R_DynamicLightIsActive(light(10.0, 1.0), 1.0), "deadline active")
  return true
end function

// Verify expired light against the expected Quake behavior.
function testExpiredLight()
  no(worldRender.R_DynamicLightIsActive(light(10.0, 0.999), 1.0), "expired")
  return true
end function

// Verify zero radius against the expected Quake behavior.
function testZeroRadius()
  no(worldRender.R_DynamicLightIsActive(light(0.0, 2.0), 1.0), "zero radius")
  return true
end function

// Verify negative radius against the expected Quake behavior.
function testNegativeRadius()
  no(worldRender.R_DynamicLightIsActive(light(-1.0, 2.0), 1.0), "negative radius")
  return true
end function

// Verify void light against the expected Quake behavior.
function testVoidLight()
  no(worldRender.R_DynamicLightIsActive(void, 1.0), "void light")
  return true
end function

// Verify push targets next frame against the expected Quake behavior.
function testPushTargetsNextFrame()
  setup([light(64.0, 2.0)], false, true, true)
  equal(worldRender.R_PushDlights(), 2, "marked surfaces")
  state = worldRender.R_GetDynamicLightCompatibilityState(0)
  equal(state[0], 1, "dlight bit")
  equal(state[1], 8, "next frame target")
  return true
end function

// Verify begin frame alignment against the expected Quake behavior.
function testBeginFrameAlignment()
  setup([light(64.0, 2.0)], false, true, true)
  result = worldRender.R_BeginWorldFrame()
  equal(result[0], 8, "frame advanced")
  equal(result[1], 8, "dlight frame aligned")
  equal(result[2], 2, "marked count")
  return true
end function

// Verify second surface marked against the expected Quake behavior.
function testSecondSurfaceMarked()
  setup([light(64.0, 2.0)], false, true, true)
  worldRender.R_BeginWorldFrame()
  equal(worldRender.R_GetDynamicLightCompatibilityState(1)[0], 1, "second surface bit")
  return true
end function

// Verify multiple light bits against the expected Quake behavior.
function testMultipleLightBits()
  setup([light(64.0, 2.0), light(64.0, 2.0)], false, true, true)
  worldRender.R_BeginWorldFrame()
  equal(worldRender.R_GetDynamicLightCompatibilityState(0)[0], 3, "combined bits")
  return true
end function

// Verify stale bits reset against the expected Quake behavior.
function testStaleBitsReset()
  setup([light(64.0, 2.0)], false, true, true)
  worldRender.R_SetSurfaceCompatibilityState(0, 7, 7, [256, 0, 0, 0], false, 0, 0, 0)
  worldRender.R_BeginWorldFrame()
  equal(worldRender.R_GetDynamicLightCompatibilityState(0)[0], 1, "stale reset")
  return true
end function

// Verify flash blend skips marks against the expected Quake behavior.
function testFlashBlendSkipsMarks()
  setup([light(64.0, 2.0)], true, true, true)
  equal(worldRender.R_PushDlights(), 0, "flashblend skip")
  return true
end function

// Verify dynamic disabled skips marks against the expected Quake behavior.
function testDynamicDisabledSkipsMarks()
  setup([light(64.0, 2.0)], false, false, true)
  equal(worldRender.R_PushDlights(), 0, "dynamic skip")
  return true
end function

// Verify no world model against the expected Quake behavior.
function testNoWorldModel()
  setup([light(64.0, 2.0)], false, true, false)
  equal(worldRender.R_PushDlights(), 0, "no model")
  return true
end function

// Verify expired skipped against the expected Quake behavior.
function testExpiredSkipped()
  setup([light(64.0, 0.5)], false, true, true)
  equal(worldRender.R_PushDlights(), 0, "expired push")
  return true
end function

// Verify brush model marks against the expected Quake behavior.
function testBrushModelMarks()
  setup([light(64.0, 2.0)], false, true, true)
  entity = BrushEntity(1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  yes(worldRender.R_MarkBrushModelLights(entity) > 0, "brush marking")
  return true
end function

// Verify world like brush skips against the expected Quake behavior.
function testWorldLikeBrushSkips()
  setup([light(64.0, 2.0)], false, true, true)
  entity = BrushEntity(2, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  equal(worldRender.R_MarkBrushModelLights(entity), 0, "world-like brush")
  return true
end function

// Verify invalid brush model against the expected Quake behavior.
function testInvalidBrushModel()
  setup([light(64.0, 2.0)], false, true, true)
  entity = BrushEntity(99, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  equal(worldRender.R_MarkBrushModelLights(entity), 0, "invalid brush")
  return true
end function

// Verify brush flash blend skip against the expected Quake behavior.
function testBrushFlashBlendSkip()
  setup([light(64.0, 2.0)], true, true, true)
  entity = BrushEntity(1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  equal(worldRender.R_MarkBrushModelLights(entity), 0, "brush flashblend")
  return true
end function

// Verify frame getter against the expected Quake behavior.
function testFrameGetter()
  setup([], false, true, true)
  worldRender.R_BeginWorldFrame()
  state = worldRender.R_GetFrameCompatibility()
  equal(state[0], 8, "frame getter")
  return true
end function

// Verify invalid dlight state against the expected Quake behavior.
function testInvalidDlightState()
  setup([], false, true, true)
  state = worldRender.R_GetDynamicLightCompatibilityState(99)
  equal(state[0], 0, "invalid bits")
  equal(state[1], 0, "invalid frame")
  return true
end function

passed = 0
if run(1, "light active at die time", testActiveAtDeadline) then passed = passed + 1 end if
if run(2, "expired dynamic light", testExpiredLight) then passed = passed + 1 end if
if run(3, "zero-radius dynamic light", testZeroRadius) then passed = passed + 1 end if
if run(4, "negative-radius dynamic light", testNegativeRadius) then passed = passed + 1 end if
if run(5, "void dynamic light", testVoidLight) then passed = passed + 1 end if
if run(6, "push targets next frame", testPushTargetsNextFrame) then passed = passed + 1 end if
if run(7, "push-before-frame alignment", testBeginFrameAlignment) then passed = passed + 1 end if
if run(8, "all node surfaces marked", testSecondSurfaceMarked) then passed = passed + 1 end if
if run(9, "dynamic-light bit union", testMultipleLightBits) then passed = passed + 1 end if
if run(10, "stale bit reset", testStaleBitsReset) then passed = passed + 1 end if
if run(11, "flashblend mark bypass", testFlashBlendSkipsMarks) then passed = passed + 1 end if
if run(12, "dynamic-light disable", testDynamicDisabledSkipsMarks) then passed = passed + 1 end if
if run(13, "missing world model", testNoWorldModel) then passed = passed + 1 end if
if run(14, "expired light skip", testExpiredSkipped) then passed = passed + 1 end if
if run(15, "brush-model light marking", testBrushModelMarks) then passed = passed + 1 end if
if run(16, "world-like brush skip", testWorldLikeBrushSkips) then passed = passed + 1 end if
if run(17, "invalid brush model", testInvalidBrushModel) then passed = passed + 1 end if
if run(18, "brush flashblend skip", testBrushFlashBlendSkip) then passed = passed + 1 end if
if run(19, "frame-state getter", testFrameGetter) then passed = passed + 1 end if
if run(20, "invalid dlight state", testInvalidDlightState) then passed = passed + 1 end if

if passed != 20 then error(4299, "BP-042 dynamic-light tests failed: " + passed + "/20") end if
print "MiniQuake BP-042 dynamic-light render tests passed: 20"
