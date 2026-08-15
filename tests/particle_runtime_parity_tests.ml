/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-038: r_part.c per-frame particle physics and sv_gravity hand-off.
*/
import miniquake.particles as particles
import miniquake.types as t
import miniquake.native as native

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3800, name + ": expected true") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3801, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3802, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Create and initialize the requested value.
function make(type, velocity, die)
  return particles.spawn(t.Vec3(0.0, 0.0, 0.0), velocity, die, 100, type)
end function

// Advance one by one processing step.
function advanceOne(particle, gravity)
  result = particles.updateWithGravity([particle], 1.0, 0.1, gravity)
  equal(len(result), 1, "particle survives")
  return result[0]
end function

// Verify custom gravity against the expected Quake behavior.
function testCustomGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 400.0)
  near(value.origin.z, 1.0, 0.000001, "draw-before-update origin")
  near(value.velocity.z, 8.0, 0.000001, "custom gravity")
  return true
end function

// Verify default wrapper gravity against the expected Quake behavior.
function testDefaultWrapperGravity()
  value = make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0)
  result = particles.update([value], 1.0, 0.1)
  near(result[0].velocity.z, 6.0, 0.000001, "default gravity")
  return true
end function

// Verify static velocity against the expected Quake behavior.
function testStaticVelocity()
  value = advanceOne(make(particles.PT_STATIC, t.Vec3(1.0, 2.0, 3.0), 2.0), 800.0)
  near(value.velocity.z, 3.0, 0.0, "static velocity")
  near(value.origin.x, 0.1, 0.000001, "static origin")
  return true
end function

// Verify slow gravity against the expected Quake behavior.
function testSlowGravity()
  value = advanceOne(make(particles.PT_SLOW_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 800.0)
  near(value.velocity.z, 6.0, 0.000001, "slow gravity matches original")
  return true
end function

// Verify fire rise against the expected Quake behavior.
function testFireRise()
  value = advanceOne(make(particles.PT_FIRE, t.Vec3(0.0, 0.0, 0.0), 2.0), 800.0)
  near(value.velocity.z, 4.0, 0.000001, "fire rises by grav")
  equal(value.color, 0x6d, "fire ramp color")
  return true
end function

// Verify explode expansion against the expected Quake behavior.
function testExplodeExpansion()
  value = advanceOne(make(particles.PT_EXPLODE, t.Vec3(10.0, 0.0, 0.0), 2.0), 0.0)
  near(value.velocity.x, 14.0, 0.000001, "explode expansion")
  return true
end function

// Verify explode gravity against the expected Quake behavior.
function testExplodeGravity()
  value = advanceOne(make(particles.PT_EXPLODE, t.Vec3(0.0, 0.0, 10.0), 2.0), 800.0)
  near(value.velocity.z, 10.0, 0.000001, "explode expand then gravity")
  return true
end function

// Verify explode2 damping against the expected Quake behavior.
function testExplode2Damping()
  value = advanceOne(make(particles.PT_EXPLODE2, t.Vec3(10.0, 0.0, 10.0), 2.0), 0.0)
  near(value.velocity.x, 9.0, 0.000001, "explode2 damping x")
  near(value.velocity.z, 9.0, 0.000001, "explode2 damping z")
  return true
end function

// Verify blob expansion against the expected Quake behavior.
function testBlobExpansion()
  value = advanceOne(make(particles.PT_BLOB, t.Vec3(10.0, 0.0, 0.0), 2.0), 0.0)
  near(value.velocity.x, 14.0, 0.000001, "blob expansion")
  return true
end function

// Verify blob2 damping against the expected Quake behavior.
function testBlob2Damping()
  value = advanceOne(make(particles.PT_BLOB2, t.Vec3(10.0, 10.0, 10.0), 2.0), 0.0)
  near(value.velocity.x, 6.0, 0.000001, "blob2 damping x")
  near(value.velocity.y, 6.0, 0.000001, "blob2 damping y")
  near(value.velocity.z, 10.0, 0.000001, "blob2 z only gravity")
  return true
end function

// Verify expired removed against the expected Quake behavior.
function testExpiredRemoved()
  value = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 0.99)
  result = particles.updateWithGravity([value], 1.0, 0.1, 800.0)
  equal(len(result), 0, "expired removed")
  return true
end function

// Verify expiry equality survives against the expected Quake behavior.
function testExpiryEqualitySurvives()
  value = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 1.0)
  result = particles.updateWithGravity([value], 1.0, 0.1, 800.0)
  equal(len(result), 1, "die equality survives")
  return true
end function

// Verify order preserved against the expected Quake behavior.
function testOrderPreserved()
  first = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  second = make(particles.PT_STATIC, t.Vec3(2.0, 0.0, 0.0), 2.0)
  result = particles.updateWithGravity([first, second], 1.0, 0.1, 800.0)
  near(result[0].velocity.x, 1.0, 0.0, "first order")
  near(result[1].velocity.x, 2.0, 0.0, "second order")
  return true
end function

// Verify draw before simulate against the expected Quake behavior.
function testDrawBeforeSimulate()
  system = particles.createSystem(512)
  value = particles.R_AllocParticle(system)
  value.origin = t.Vec3(100.0, 0.0, 0.0)
  value.velocity = t.Vec3(10.0, 0.0, 0.0)
  value.die = 2.0
  commands = particles.R_DrawParticles(
    system, 1.0, 0.9, 0.0,
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0), t.Vec3(0.0, -1.0, 0.0),
  )
  near(commands[4][2].x, 100.0, 0.0, "draw origin")
  near(value.origin.x, 101.0, 0.000001, "post-draw simulation")
  return true
end function

// Verify distance scale against the expected Quake behavior.
function testDistanceScale()
  system = particles.createSystem(512)
  value = particles.R_AllocParticle(system)
  value.origin = t.Vec3(100.0, 0.0, 0.0)
  value.die = 2.0
  commands = particles.R_DrawParticles(
    system, 1.0, 1.0, 0.0,
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0), t.Vec3(0.0, -1.0, 0.0),
  )
  near(commands[4][5], 1.4, 0.000001, "distance scale")
  return true
end function

// Verify fire ramp death against the expected Quake behavior.
function testFireRampDeath()
  value = make(particles.PT_FIRE, t.Vec3(0.0, 0.0, 0.0), 2.0)
  value.ramp = 5.6
  advanceOne(value, 0.0)
  yes(value.die < 0.0, "fire ramp death")
  return true
end function

// Verify explode ramp color against the expected Quake behavior.
function testExplodeRampColor()
  value = make(particles.PT_EXPLODE, t.Vec3(0.0, 0.0, 0.0), 2.0)
  advanceOne(value, 0.0)
  equal(value.color, 0x6d, "explode ramp index one")
  return true
end function

// Verify zero gravity against the expected Quake behavior.
function testZeroGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 0.0)
  near(value.velocity.z, 10.0, 0.0, "zero gravity")
  return true
end function

// Verify negative gravity against the expected Quake behavior.
function testNegativeGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), -400.0)
  near(value.velocity.z, 12.0, 0.000001, "negative gravity")
  return true
end function

// Verify mixed survivors against the expected Quake behavior.
function testMixedSurvivors()
  expired = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 0.5)
  alive = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  result = particles.updateWithGravity([expired, alive], 1.0, 0.1, 800.0)
  equal(len(result), 1, "mixed survivor count")
  near(result[0].velocity.x, 1.0, 0.0, "mixed survivor identity")
  return true
end function


// Verify particle float boundary against the expected Quake behavior.
function testParticleFloatBoundary()
  equal(particles.particleFloat(16777217), 16777216.0, "particle float boundary")
  return true
end function

// Verify particle origin stored float against the expected Quake behavior.
function testParticleOriginStoredFloat()
  value = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  value.origin.x = 16777216.0
  result = particles.updateWithGravity([value], 1.0, 1.0, 0.0)
  equal(native.floatBits(result[0].origin.x), native.floatBits(16777216.0), "stored origin bits")
  return true
end function

// Verify blood impact effect against the expected Quake behavior.
function testBloodImpactEffect()
  system = particles.createSystem(64)
  spawned = particles.R_RunParticleEffect(
    system,
    t.Vec3(16.0, 32.0, 48.0),
    t.Vec3(1.0, -2.0, 0.5),
    73,
    20,
    1.0,
  )
  equal(len(spawned), 20, "stock blood particle count")
  for each value in spawned
    equal(value.type, particles.PT_SLOW_GRAVITY, "stock blood gravity type")
    yes(value.color >= 72 and value.color <= 79, "stock blood palette range")
    near(value.velocity.x, 15.0, 0.000001, "stock blood direction x")
    near(value.velocity.y, -30.0, 0.000001, "stock blood direction y")
    near(value.velocity.z, 7.5, 0.000001, "stock blood direction z")
  end for
  return true
end function

// Verify survivor array reuse against the expected Quake behavior.
function testSurvivorArrayReuse()
  first = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  second = make(particles.PT_STATIC, t.Vec3(2.0, 0.0, 0.0), 2.0)
  active = [first, second]
  originalRaw = nativeRawValue(active)
  result = particles.updateWithGravity(active, 1.0, 0.1, 800.0)
  equal(nativeRawValue(result), originalRaw, "unchanged survivor array reused")
  near(result[0].origin.x, 0.1, 0.000001, "reused array particle advanced")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  tests = [
    ["custom gravity", testCustomGravity],
    ["default gravity wrapper", testDefaultWrapperGravity],
    ["static velocity", testStaticVelocity],
    ["slow gravity", testSlowGravity],
    ["fire rise", testFireRise],
    ["explode expansion", testExplodeExpansion],
    ["explode gravity", testExplodeGravity],
    ["explode2 damping", testExplode2Damping],
    ["blob expansion", testBlobExpansion],
    ["blob2 damping", testBlob2Damping],
    ["expired removed", testExpiredRemoved],
    ["expiry equality", testExpiryEqualitySurvives],
    ["order preserved", testOrderPreserved],
    ["draw before simulate", testDrawBeforeSimulate],
    ["distance scale", testDistanceScale],
    ["fire ramp death", testFireRampDeath],
    ["explode ramp color", testExplodeRampColor],
    ["zero gravity", testZeroGravity],
    ["negative gravity", testNegativeGravity],
    ["mixed survivors", testMixedSurvivors],
    ["particle float boundary", testParticleFloatBoundary],
    ["particle origin float", testParticleOriginStoredFloat],
    ["blood impact effect", testBloodImpactEffect],
    ["survivor array reuse", testSurvivorArrayReuse],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 24 then return 1 end if
  print "MiniQuake BP-038 particle runtime tests passed: 24"
  return 0
end function
