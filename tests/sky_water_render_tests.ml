/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-043: MiniQuake sky/water binary32 math and subdivision boundaries.
*/
import miniquake.render.gl_warp as warp
import miniquake.types as t
import miniquake.native as native

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(4300, name + ": expected true") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(4301, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Build deterministic test data for float bits.
function fixtureFloatBits(value)
  return native.floatBits(value)
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Exercise vertex as part of this deterministic regression fixture.
function vertex(x, y, z, s, tt)
  return t.RenderVertex(t.Vec3(x, y, z), s, tt, 0.0, 0.0)
end function

// Exercise quad as part of this deterministic regression fixture.
function quad(size)
  return [
    vertex(-size, -size, 0.0, -size, -size),
    vertex(size, -size, 0.0, size, -size),
    vertex(size, size, 0.0, size, size),
    vertex(-size, size, 0.0, -size, size),
  ]
end function

// Verify warp float boundary against the expected Quake behavior.
function testWarpFloatBoundary()
  equal(fixtureFloatBits(warp.warpFloat(16777217.0)), 0x4b800000, "float boundary")
  return true
end function

// Verify subdivide default against the expected Quake behavior.
function testSubdivideDefault()
  equal(fixtureFloatBits(warp.SetSubdivideSize(0.0)), fixtureFloatBits(128.0), "default subdivide")
  return true
end function

// Verify subdivide float storage against the expected Quake behavior.
function testSubdivideFloatStorage()
  equal(fixtureFloatBits(warp.SetSubdivideSize(16777217.0)), 0x4b800000, "subdivide float")
  return true
end function

// Verify water one s against the expected Quake behavior.
function testWaterOneS()
  value = warp.WaterTexCoords(64.0, 32.0, 0.25)
  equal(fixtureFloatBits(value[0]), 0x3f636ab6, "water one s")
  return true
end function

// Verify water one t against the expected Quake behavior.
function testWaterOneT()
  value = warp.WaterTexCoords(64.0, 32.0, 0.25)
  equal(fixtureFloatBits(value[1]), 0x3f1d906d, "water one t")
  return true
end function

// Verify water two s against the expected Quake behavior.
function testWaterTwoS()
  value = warp.WaterTexCoords(-17.25, 93.5, 123.75)
  equal(fixtureFloatBits(value[0]), 0xbe9f8f9b, "water two s")
  return true
end function

// Verify water two t against the expected Quake behavior.
function testWaterTwoT()
  value = warp.WaterTexCoords(-17.25, 93.5, 123.75)
  equal(fixtureFloatBits(value[1]), 0x3fc7d9f0, "water two t")
  return true
end function

// Verify solid speed wrap against the expected Quake behavior.
function testSolidSpeedWrap()
  equal(fixtureFloatBits(warp.WrappedSpeedScale(20.0, 8.0)), 0x42000000, "solid speed")
  return true
end function

// Verify alpha speed wrap against the expected Quake behavior.
function testAlphaSpeedWrap()
  equal(fixtureFloatBits(warp.WrappedSpeedScale(20.0, 16.0)), 0x42800000, "alpha speed")
  return true
end function

// Verify negative speed wrap against the expected Quake behavior.
function testNegativeSpeedWrap()
  equal(fixtureFloatBits(warp.WrappedSpeedScale(-1.25, 8.0)), 0x42ec0000, "negative speed")
  return true
end function

// Verify sky general s against the expected Quake behavior.
function testSkyGeneralS()
  value = warp.SkyTexCoords(t.Vec3(64.0, 32.0, 16.0), t.Vec3(3.0, -2.0, 1.0), 32.0)
  equal(fixtureFloatBits(value[0]), 0x401ac5d2, "sky general s")
  return true
end function

// Verify sky general t against the expected Quake behavior.
function testSkyGeneralT()
  value = warp.SkyTexCoords(t.Vec3(64.0, 32.0, 16.0), t.Vec3(3.0, -2.0, 1.0), 32.0)
  equal(fixtureFloatBits(value[1]), 0x3fbab28e, "sky general t")
  return true
end function

// Verify sky axis against the expected Quake behavior.
function testSkyAxis()
  value = warp.SkyTexCoords(t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.0)
  equal(fixtureFloatBits(value[0]), 0x403d0000, "sky x axis")
  equal(fixtureFloatBits(value[1]), 0, "sky x axis t")
  return true
end function

// Verify sky zero direction against the expected Quake behavior.
function testSkyZeroDirection()
  value = warp.SkyTexCoords(t.Vec3(1.0, 2.0, 3.0), t.Vec3(1.0, 2.0, 3.0), 10.0)
  equal(value[0], 0.0, "zero sky s")
  equal(value[1], 0.0, "zero sky t")
  return true
end function

// Verify surface vectors ignore offset against the expected Quake behavior.
function testSurfaceVectorsIgnoreOffset()
  values = warp.SurfaceWarpVertices([vertex(2.0, 3.0, 4.0, 0.0, 0.0)], [1.0, 2.0, 3.0, 999.0], [4.0, 5.0, 6.0, 999.0])
  equal(values[0].s, 20.0, "surface s")
  equal(values[0].t, 47.0, "surface t")
  return true
end function

// Verify subdivide vertex limit against the expected Quake behavior.
function testSubdivideVertexLimit()
  values = []
  index = 0
  while index < 61
    values = values + [vertex(index, 0.0, 0.0, 0.0, 0.0)]
    index = index + 1
  end while
  result = try(warp.SubdividePolygon(values, 128.0))
  yes(result is error, "vertex limit")
  return true
end function

// Verify small polygon no split against the expected Quake behavior.
function testSmallPolygonNoSplit()
  polygon = [
    vertex(16.0, 16.0, 0.0, 16.0, 16.0),
    vertex(48.0, 16.0, 0.0, 48.0, 16.0),
    vertex(48.0, 48.0, 0.0, 48.0, 48.0),
    vertex(16.0, 48.0, 0.0, 16.0, 48.0),
  ]
  equal(len(warp.SubdividePolygon(polygon, 128.0)), 1, "small polygon")
  return true
end function

// Verify large polygon splits against the expected Quake behavior.
function testLargePolygonSplits()
  yes(len(warp.SubdividePolygon(quad(128.0), 128.0)) > 1, "large polygon split")
  return true
end function

// Verify invalid sky size against the expected Quake behavior.
function testInvalidSkySize()
  texture = t.BspTexture("bad", 128, 128, [0, 0, 0, 0], bytes(128 * 128))
  yes(try(warp.R_InitSky(texture, bytes(768))) is error, "sky size")
  return true
end function

// Verify invalid sky palette against the expected Quake behavior.
function testInvalidSkyPalette()
  texture = t.BspTexture("bad", 256, 128, [0, 0, 0, 0], bytes(256 * 128))
  yes(try(warp.R_InitSky(texture, bytes(767))) is error, "sky palette")
  return true
end function

// Verify sky transparent average against the expected Quake behavior.
function testSkyTransparentAverage()
  palette = bytes(768)
  palette[3] = 10; palette[4] = 20; palette[5] = 30
  pixels = bytes(256 * 128, 1)
  pixels[0] = 0
  texture = t.BspTexture("sky", 256, 128, [0, 0, 0, 0], pixels)
  result = warp.R_InitSky(texture, palette)
  equal(result[1][0], 10, "average red")
  equal(result[1][1], 20, "average green")
  equal(result[1][2], 30, "average blue")
  equal(result[1][3], 0, "average alpha")
  return true
end function

// Verify layer speeds against the expected Quake behavior.
function testLayerSpeeds()
  result = warp.EmitBothSkyLayers([quad(16.0)], t.Vec3(0.0, 0.0, 0.0), 20.0)
  equal(fixtureFloatBits(result[0]), 0x42000000, "solid layer speed")
  equal(fixtureFloatBits(result[2]), 0x42800000, "alpha layer speed")
  return true
end function

passed = 0
if run(1, "binary32 warp storage", testWarpFloatBoundary) then passed = passed + 1 end if
if run(2, "default subdivision cvar", testSubdivideDefault) then passed = passed + 1 end if
if run(3, "subdivision binary32 cvar", testSubdivideFloatStorage) then passed = passed + 1 end if
if run(4, "water coordinates one S", testWaterOneS) then passed = passed + 1 end if
if run(5, "water coordinates one T", testWaterOneT) then passed = passed + 1 end if
if run(6, "water coordinates two S", testWaterTwoS) then passed = passed + 1 end if
if run(7, "water coordinates two T", testWaterTwoT) then passed = passed + 1 end if
if run(8, "solid sky speed wrapping", testSolidSpeedWrap) then passed = passed + 1 end if
if run(9, "alpha sky speed wrapping", testAlphaSpeedWrap) then passed = passed + 1 end if
if run(10, "negative sky speed wrapping", testNegativeSpeedWrap) then passed = passed + 1 end if
if run(11, "sky coordinate S", testSkyGeneralS) then passed = passed + 1 end if
if run(12, "sky coordinate T", testSkyGeneralT) then passed = passed + 1 end if
if run(13, "sky axis coordinate", testSkyAxis) then passed = passed + 1 end if
if run(14, "zero sky direction", testSkyZeroDirection) then passed = passed + 1 end if
if run(15, "surface texture vectors", testSurfaceVectorsIgnoreOffset) then passed = passed + 1 end if
if run(16, "subdivision vertex limit", testSubdivideVertexLimit) then passed = passed + 1 end if
if run(17, "small polygon subdivision", testSmallPolygonNoSplit) then passed = passed + 1 end if
if run(18, "large polygon subdivision", testLargePolygonSplits) then passed = passed + 1 end if
if run(19, "sky texture dimensions", testInvalidSkySize) then passed = passed + 1 end if
if run(20, "sky palette length", testInvalidSkyPalette) then passed = passed + 1 end if
if run(21, "sky transparent average", testSkyTransparentAverage) then passed = passed + 1 end if
if run(22, "two-layer sky speeds", testLayerSpeeds) then passed = passed + 1 end if

if passed != 22 then error(4399, "BP-043 sky/water tests failed: " + passed + "/22") end if
print "MiniQuake BP-043 sky/water render tests passed: 22"
