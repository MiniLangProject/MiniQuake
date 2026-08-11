/* BP-041: lightmap formats, atlas row strides, and shared texture ownership. */

import miniquake.render.world as worldRender
import miniquake.types as t
import miniquake.constants as c
import miniquake.array_util as arrayutil

function yes(value, name)
  if not value then return error(4100, name + ": expected true") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(4101, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function byteEqual(data, offset, expected, name)
  equal(data[offset], expected, name)
  return true
end function

function run(number, name, fn)
  print "[" + number + "/23] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function setup(lighting, lightOffset, fullbright)
  zero = t.Vec3(0.0, 0.0, 0.0)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  face = t.BspFace(0, 0, 0, 0, 0, bytes([0, 255, 255, 255]), lightOffset)
  map = t.BspMap("bp041.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [], bytes(), [], [info], [face], lighting, [], [], [], [], [], [])
  surface = t.RenderSurface(0, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, lightOffset, 0, [], 500)
  renderer = t.WorldRenderer(map, bytes(), [], [surface], [], true, 0, fullbright, false, 0, bytes(1, 1), 0, 1.0)
  worldRender.R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  styles = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, 256)
  worldRender.R_SetLightStyleCompatibility(styles)
  worldRender.R_SetFrameCompatibility(7, 1)
  worldRender.R_SetSurfaceCompatibilityState(0, 0, 0, [0, 0, 0, 0], false, 0, 0, 0)
  return [renderer, surface]
end function

function standardFixture()
  return setup(bytes([0, 10, 20, 30]), 0, false)
end function

function testRequiredLuminance()
  equal(worldRender.R_LightmapRequiredBytes(2, 2, 2, 1), 4, "luminance required")
  return true
end function

function testRequiredStrideClamp()
  equal(worldRender.R_LightmapRequiredBytes(2, 2, 1, 1), 4, "stride clamp")
  return true
end function

function testRequiredRgba()
  equal(worldRender.R_LightmapRequiredBytes(2, 2, 10, 4), 18, "rgba required")
  return true
end function

function testBadFormat()
  result = try(worldRender.R_LightmapRequiredBytes(2, 2, 2, 2))
  yes(result is error, "bad lightmap format")
  return true
end function

function testLuminanceExact()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(4, 204), 2)
  byteEqual(result, 0, 255, "lum 0")
  byteEqual(result, 1, 235, "lum 1")
  byteEqual(result, 2, 215, "lum 2")
  byteEqual(result, 3, 195, "lum 3")
  return true
end function

function testLuminancePadded()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(8, 204), 4)
  byteEqual(result, 0, 255, "pad row0 a")
  byteEqual(result, 1, 235, "pad row0 b")
  byteEqual(result, 2, 204, "pad untouched")
  byteEqual(result, 4, 215, "pad row1 a")
  byteEqual(result, 5, 195, "pad row1 b")
  return true
end function

function testRgbaAlphaExact()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 4)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(16, 204), 8)
  byteEqual(result, 3, 255, "rgba alpha0")
  byteEqual(result, 7, 235, "rgba alpha1")
  byteEqual(result, 11, 215, "rgba alpha2")
  byteEqual(result, 15, 195, "rgba alpha3")
  return true
end function

function testRgbaPadded()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 4)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(20, 204), 10)
  byteEqual(result, 3, 255, "rgba padded alpha0")
  byteEqual(result, 7, 235, "rgba padded alpha1")
  byteEqual(result, 13, 215, "rgba padded alpha2")
  byteEqual(result, 17, 195, "rgba padded alpha3")
  return true
end function

function testRgbaRgbUntouched()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 4)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(16, 204), 8)
  byteEqual(result, 0, 204, "rgba red untouched")
  byteEqual(result, 1, 204, "rgba green untouched")
  byteEqual(result, 2, 204, "rgba blue untouched")
  return true
end function

function testDestinationTooSmall()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 4)
  result = try(worldRender.R_BuildLightMap(setupValue[1], bytes(15), 8))
  yes(result is error, "small destination")
  return true
end function

function testDestinationType()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = try(worldRender.R_BuildLightMap(setupValue[1], [0, 0, 0, 0], 2))
  yes(result is error, "destination type")
  return true
end function

function testFullbright()
  setupValue = setup(bytes([0, 10, 20, 30]), 0, true)
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(4, 99), 2)
  equal(result[0] + result[1] + result[2] + result[3], 0, "fullbright inverse")
  return true
end function

function testMissingLightData()
  setupValue = setup(bytes(), 0, false)
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(4, 99), 2)
  equal(result[0] + result[1] + result[2] + result[3], 0, "missing lightdata")
  return true
end function

function testNegativeLightOffset()
  setupValue = setup(bytes([1, 2, 3, 4]), -1, false)
  worldRender.R_SetLightmapCompatibility(500, 1)
  result = worldRender.R_BuildLightMap(setupValue[1], bytes(4, 99), 2)
  equal(result[0] + result[1] + result[2] + result[3], 0, "negative offset")
  return true
end function

function testCachedStyle()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 1)
  worldRender.R_BuildLightMap(setupValue[1], bytes(4), 2)
  equal(worldRender.R_GetSurfaceCompatibilityState(0)[0][0], 256, "cached light style")
  return true
end function

function testBuildPreservesChain()
  setupValue = standardFixture()
  worldRender.R_SetLightmapCompatibility(500, 1)
  worldRender.R_SetLightmapChainCompatibility(0, [setupValue[1], setupValue[1]])
  worldRender.R_BuildLightMap(setupValue[1], bytes(4), 2)
  equal(worldRender.R_GetLightmapCompatibilityState(0)[3], 2, "animated rebuild preserves chain")
  return true
end function

function collectorRenderer(pageIds, surfaceIds)
  renderer = setup(bytes(), -1, true)[0]
  renderer.lightmaps = pageIds
  renderer.surfaces = []
  index = 0
  while index < len(surfaceIds)
    renderer.surfaces = renderer.surfaces + [t.RenderSurface(index, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 1, 1, -1, 0, [], surfaceIds[index])]
    index = index + 1
  end while
  return renderer
end function

function testCollectorPages()
  ids = worldRender.R_CollectLightmapTextureIds(collectorRenderer([500, 501], []))
  equal(len(ids), 2, "page ids")
  equal(ids[0], 500, "page first")
  return true
end function

function testCollectorSurfaces()
  ids = worldRender.R_CollectLightmapTextureIds(collectorRenderer([], [600, 601]))
  equal(len(ids), 2, "surface ids")
  equal(ids[1], 601, "surface second")
  return true
end function

function testCollectorDeduplicates()
  ids = worldRender.R_CollectLightmapTextureIds(collectorRenderer([500], [500, 500]))
  equal(len(ids), 1, "deduplicated ids")
  return true
end function

function testCollectorIgnoresZero()
  ids = worldRender.R_CollectLightmapTextureIds(collectorRenderer([0, 500], [0]))
  equal(len(ids), 1, "ignore zero")
  equal(ids[0], 500, "remaining id")
  return true
end function

function testCollectorOrder()
  ids = worldRender.R_CollectLightmapTextureIds(collectorRenderer([502, 500], [501]))
  equal(ids[0], 502, "order page0")
  equal(ids[1], 500, "order page1")
  equal(ids[2], 501, "order surface")
  return true
end function

function testCollectorVoid()
  equal(len(worldRender.R_CollectLightmapTextureIds(void)), 0, "void collector")
  return true
end function

function testRequiredEmpty()
  equal(worldRender.R_LightmapRequiredBytes(0, 2, 8, 4), 0, "empty width")
  equal(worldRender.R_LightmapRequiredBytes(2, 0, 8, 4), 0, "empty height")
  return true
end function

passed = 0
if run(1, "luminance required size", testRequiredLuminance) then passed = passed + 1 end if
if run(2, "minimum row stride", testRequiredStrideClamp) then passed = passed + 1 end if
if run(3, "RGBA required size", testRequiredRgba) then passed = passed + 1 end if
if run(4, "invalid lightmap format", testBadFormat) then passed = passed + 1 end if
if run(5, "luminance lightmap", testLuminanceExact) then passed = passed + 1 end if
if run(6, "luminance padded rows", testLuminancePadded) then passed = passed + 1 end if
if run(7, "RGBA alpha lightmap", testRgbaAlphaExact) then passed = passed + 1 end if
if run(8, "RGBA padded rows", testRgbaPadded) then passed = passed + 1 end if
if run(9, "RGBA RGB preservation", testRgbaRgbUntouched) then passed = passed + 1 end if
if run(10, "small destination", testDestinationTooSmall) then passed = passed + 1 end if
if run(11, "destination type", testDestinationType) then passed = passed + 1 end if
if run(12, "fullbright lightmap", testFullbright) then passed = passed + 1 end if
if run(13, "missing lightdata", testMissingLightData) then passed = passed + 1 end if
if run(14, "negative sample offset", testNegativeLightOffset) then passed = passed + 1 end if
if run(15, "cached style update", testCachedStyle) then passed = passed + 1 end if
if run(16, "animated rebuild preserves chain", testBuildPreservesChain) then passed = passed + 1 end if
if run(17, "atlas page ownership", testCollectorPages) then passed = passed + 1 end if
if run(18, "legacy surface ownership", testCollectorSurfaces) then passed = passed + 1 end if
if run(19, "shared page deduplication", testCollectorDeduplicates) then passed = passed + 1 end if
if run(20, "zero texture ignored", testCollectorIgnoresZero) then passed = passed + 1 end if
if run(21, "texture deletion order", testCollectorOrder) then passed = passed + 1 end if
if run(22, "void renderer ownership", testCollectorVoid) then passed = passed + 1 end if
if run(23, "empty lightmap dimensions", testRequiredEmpty) then passed = passed + 1 end if

if passed != 23 then error(4199, "BP-041 lightmap tests failed: " + passed + "/23") end if
print "MiniQuake BP-041 lightmap atlas tests passed: 23"
