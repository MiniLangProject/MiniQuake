/* BP-040: world-surface visibility, texture chains, sky, and water planning. */

import miniquake.render.world as worldRender
import miniquake.types as t
import miniquake.constants as c

function yes(value, name)
  if not value then return error(4000, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(4001, name + ": expected false") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(4002, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function surface(face, texture, flags)
  zero = t.Vec3(0.0, 0.0, 0.0)
  return t.RenderSurface(face, texture, zero, zero, 1, 1, -1, flags, [], 0)
end function

function setup()
  zero = t.Vec3(0.0, 0.0, 0.0)
  map = t.BspMap("bp040.bsp", bytes(), c.BSP_VERSION, [], "", [], [], [], [], bytes(), [], [], [], bytes(), [], [], [], [], [], [])
  textures = [
    t.RenderTexture("stone", 16, 16, 1, bytes(), false),
    t.RenderTexture("sky", 16, 16, 2, bytes(), false),
    t.RenderTexture("*water", 16, 16, 3, bytes(), false),
  ]
  renderer = t.WorldRenderer(map, bytes(), textures, [], [], true, 0, false, false, 0, bytes(), 0, 1.0)
  worldRender.R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  worldRender.R_SetSurfaceChainCompatibility(true, [], [])
  return renderer
end function

function testWorldFrontVisible()
  setup()
  yes(worldRender.R_SurfaceFacesViewer(surface(0, 0, 0), 1.0), "front visible")
  return true
end function

function testWorldFrontCulled()
  setup()
  no(worldRender.R_SurfaceFacesViewer(surface(0, 0, 0), -1.0), "front culled")
  return true
end function

function testWorldBackVisible()
  setup()
  yes(worldRender.R_SurfaceFacesViewer(surface(0, 0, c.SURF_PLANEBACK), -1.0), "back visible")
  return true
end function

function testWorldBackCulled()
  setup()
  no(worldRender.R_SurfaceFacesViewer(surface(0, 0, c.SURF_PLANEBACK), 1.0), "back culled")
  return true
end function

function testUnderwaterBypassesCull()
  setup()
  yes(worldRender.R_SurfaceFacesViewer(surface(0, 0, c.SURF_UNDERWATER), -1.0), "underwater front")
  return true
end function

function testBrushFrontVisible()
  setup()
  yes(worldRender.R_BrushSurfaceFacesViewer(surface(0, 0, 0), 0.011), "brush front")
  return true
end function

function testBrushFrontEpsilonCulled()
  setup()
  no(worldRender.R_BrushSurfaceFacesViewer(surface(0, 0, 0), 0.01), "brush epsilon")
  return true
end function

function testBrushBackVisible()
  setup()
  yes(worldRender.R_BrushSurfaceFacesViewer(surface(0, 0, c.SURF_PLANEBACK), -0.011), "brush back")
  return true
end function

function testBrushBackEpsilonCulled()
  setup()
  no(worldRender.R_BrushSurfaceFacesViewer(surface(0, 0, c.SURF_PLANEBACK), -0.01), "brush back epsilon")
  return true
end function

function testResetTextureChains()
  setup()
  equal(worldRender.R_ResetTextureChains(), 3, "texture chain count")
  return true
end function

function testHeadInsertionOrder()
  setup()
  first = surface(1, 0, 0)
  second = surface(2, 0, 0)
  yes(worldRender.R_ChainSurface(first), "chain first")
  yes(worldRender.R_ChainSurface(second), "chain second")
  chain = worldRender.R_GetTextureChains()[0]
  equal(chain[0].faceIndex, 2, "head face")
  equal(chain[1].faceIndex, 1, "tail face")
  return true
end function

function testSeparateTextureChains()
  setup()
  worldRender.R_ChainSurface(surface(1, 0, 0))
  worldRender.R_ChainSurface(surface(2, 1, c.SURF_DRAWSKY))
  chains = worldRender.R_GetTextureChains()
  equal(len(chains[0]), 1, "normal chain")
  equal(len(chains[1]), 1, "sky chain")
  equal(len(chains[2]), 0, "water chain empty")
  return true
end function

function testInvalidTextureRejected()
  setup()
  no(worldRender.R_ChainSurface(surface(0, 99, 0)), "invalid texture")
  return true
end function

function testWaterDeferred()
  yes(worldRender.R_WaterPassDeferred(true, 0.5), "sorted translucent water")
  return true
end function

function testOpaqueWaterImmediate()
  no(worldRender.R_WaterPassDeferred(true, 1.0), "sorted opaque water")
  return true
end function

function testUnsortedWaterImmediate()
  no(worldRender.R_WaterPassDeferred(false, 0.5), "unsorted translucent water")
  return true
end function

function testResetClearsExistingChains()
  setup()
  worldRender.R_ChainSurface(surface(1, 0, 0))
  worldRender.R_ResetTextureChains()
  equal(len(worldRender.R_GetTextureChains()[0]), 0, "reset clears")
  return true
end function

function testSkyFlagRetained()
  setup()
  worldRender.R_ChainSurface(surface(3, 1, c.SURF_DRAWSKY))
  equal(worldRender.R_GetTextureChains()[1][0].flags & c.SURF_DRAWSKY, c.SURF_DRAWSKY, "sky flag")
  return true
end function

function testWaterFlagRetained()
  setup()
  worldRender.R_ChainSurface(surface(4, 2, c.SURF_DRAWTURB))
  equal(worldRender.R_GetTextureChains()[2][0].flags & c.SURF_DRAWTURB, c.SURF_DRAWTURB, "water flag")
  return true
end function

function testVoidSurfaceRejected()
  setup()
  no(worldRender.R_ChainSurface(void), "void surface")
  return true
end function

passed = 0
if run(1, "world front-facing surface", testWorldFrontVisible) then passed = passed + 1 end if
if run(2, "world back-face rejection", testWorldFrontCulled) then passed = passed + 1 end if
if run(3, "planeback visibility", testWorldBackVisible) then passed = passed + 1 end if
if run(4, "planeback rejection", testWorldBackCulled) then passed = passed + 1 end if
if run(5, "underwater culling bypass", testUnderwaterBypassesCull) then passed = passed + 1 end if
if run(6, "brush front-face epsilon", testBrushFrontVisible) then passed = passed + 1 end if
if run(7, "brush front epsilon boundary", testBrushFrontEpsilonCulled) then passed = passed + 1 end if
if run(8, "brush back-face epsilon", testBrushBackVisible) then passed = passed + 1 end if
if run(9, "brush back epsilon boundary", testBrushBackEpsilonCulled) then passed = passed + 1 end if
if run(10, "texture-chain allocation", testResetTextureChains) then passed = passed + 1 end if
if run(11, "texture-chain head insertion", testHeadInsertionOrder) then passed = passed + 1 end if
if run(12, "per-texture chain separation", testSeparateTextureChains) then passed = passed + 1 end if
if run(13, "invalid texture chain", testInvalidTextureRejected) then passed = passed + 1 end if
if run(14, "translucent water deferral", testWaterDeferred) then passed = passed + 1 end if
if run(15, "opaque water immediate pass", testOpaqueWaterImmediate) then passed = passed + 1 end if
if run(16, "unsorted water immediate pass", testUnsortedWaterImmediate) then passed = passed + 1 end if
if run(17, "texture-chain reset", testResetClearsExistingChains) then passed = passed + 1 end if
if run(18, "sky chain classification", testSkyFlagRetained) then passed = passed + 1 end if
if run(19, "water chain classification", testWaterFlagRetained) then passed = passed + 1 end if
if run(20, "void chain rejection", testVoidSurfaceRejected) then passed = passed + 1 end if

if passed != 20 then error(4099, "BP-040 world surface tests failed: " + passed + "/20") end if
print "MiniQuake BP-040 world surface tests passed: 20"
