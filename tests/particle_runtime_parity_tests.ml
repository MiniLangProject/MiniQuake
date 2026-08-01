/* BP-038: r_part.c per-frame particle physics and sv_gravity hand-off. */

import miniquake.particles as particles
import miniquake.types as t
import miniquake.native as native

function yes(value, name)
  if not value then return error(3800, name + ": expected true") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(3801, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3802, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function make(type, velocity, die)
  return particles.spawn(t.Vec3(0.0, 0.0, 0.0), velocity, die, 100, type)
end function

function advanceOne(particle, gravity)
  result = particles.updateWithGravity([particle], 1.0, 0.1, gravity)
  equal(len(result), 1, "particle survives")
  return result[0]
end function

function testCustomGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 400.0)
  near(value.origin.z, 1.0, 0.000001, "draw-before-update origin")
  near(value.velocity.z, 8.0, 0.000001, "custom gravity")
  return true
end function

function testDefaultWrapperGravity()
  value = make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0)
  result = particles.update([value], 1.0, 0.1)
  near(result[0].velocity.z, 6.0, 0.000001, "default gravity")
  return true
end function

function testStaticVelocity()
  value = advanceOne(make(particles.PT_STATIC, t.Vec3(1.0, 2.0, 3.0), 2.0), 800.0)
  near(value.velocity.z, 3.0, 0.0, "static velocity")
  near(value.origin.x, 0.1, 0.000001, "static origin")
  return true
end function

function testSlowGravity()
  value = advanceOne(make(particles.PT_SLOW_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 800.0)
  near(value.velocity.z, 6.0, 0.000001, "slow gravity matches original")
  return true
end function

function testFireRise()
  value = advanceOne(make(particles.PT_FIRE, t.Vec3(0.0, 0.0, 0.0), 2.0), 800.0)
  near(value.velocity.z, 4.0, 0.000001, "fire rises by grav")
  equal(value.color, 0x6d, "fire ramp color")
  return true
end function

function testExplodeExpansion()
  value = advanceOne(make(particles.PT_EXPLODE, t.Vec3(10.0, 0.0, 0.0), 2.0), 0.0)
  near(value.velocity.x, 14.0, 0.000001, "explode expansion")
  return true
end function

function testExplodeGravity()
  value = advanceOne(make(particles.PT_EXPLODE, t.Vec3(0.0, 0.0, 10.0), 2.0), 800.0)
  near(value.velocity.z, 10.0, 0.000001, "explode expand then gravity")
  return true
end function

function testExplode2Damping()
  value = advanceOne(make(particles.PT_EXPLODE2, t.Vec3(10.0, 0.0, 10.0), 2.0), 0.0)
  near(value.velocity.x, 9.0, 0.000001, "explode2 damping x")
  near(value.velocity.z, 9.0, 0.000001, "explode2 damping z")
  return true
end function

function testBlobExpansion()
  value = advanceOne(make(particles.PT_BLOB, t.Vec3(10.0, 0.0, 0.0), 2.0), 0.0)
  near(value.velocity.x, 14.0, 0.000001, "blob expansion")
  return true
end function

function testBlob2Damping()
  value = advanceOne(make(particles.PT_BLOB2, t.Vec3(10.0, 10.0, 10.0), 2.0), 0.0)
  near(value.velocity.x, 6.0, 0.000001, "blob2 damping x")
  near(value.velocity.y, 6.0, 0.000001, "blob2 damping y")
  near(value.velocity.z, 10.0, 0.000001, "blob2 z only gravity")
  return true
end function

function testExpiredRemoved()
  value = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 0.99)
  result = particles.updateWithGravity([value], 1.0, 0.1, 800.0)
  equal(len(result), 0, "expired removed")
  return true
end function

function testExpiryEqualitySurvives()
  value = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 1.0)
  result = particles.updateWithGravity([value], 1.0, 0.1, 800.0)
  equal(len(result), 1, "die equality survives")
  return true
end function

function testOrderPreserved()
  first = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  second = make(particles.PT_STATIC, t.Vec3(2.0, 0.0, 0.0), 2.0)
  result = particles.updateWithGravity([first, second], 1.0, 0.1, 800.0)
  near(result[0].velocity.x, 1.0, 0.0, "first order")
  near(result[1].velocity.x, 2.0, 0.0, "second order")
  return true
end function

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

function testFireRampDeath()
  value = make(particles.PT_FIRE, t.Vec3(0.0, 0.0, 0.0), 2.0)
  value.ramp = 5.6
  advanceOne(value, 0.0)
  yes(value.die < 0.0, "fire ramp death")
  return true
end function

function testExplodeRampColor()
  value = make(particles.PT_EXPLODE, t.Vec3(0.0, 0.0, 0.0), 2.0)
  advanceOne(value, 0.0)
  equal(value.color, 0x6d, "explode ramp index one")
  return true
end function

function testZeroGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), 0.0)
  near(value.velocity.z, 10.0, 0.0, "zero gravity")
  return true
end function

function testNegativeGravity()
  value = advanceOne(make(particles.PT_GRAVITY, t.Vec3(0.0, 0.0, 10.0), 2.0), -400.0)
  near(value.velocity.z, 12.0, 0.000001, "negative gravity")
  return true
end function

function testMixedSurvivors()
  expired = make(particles.PT_STATIC, t.Vec3(0.0, 0.0, 0.0), 0.5)
  alive = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  result = particles.updateWithGravity([expired, alive], 1.0, 0.1, 800.0)
  equal(len(result), 1, "mixed survivor count")
  near(result[0].velocity.x, 1.0, 0.0, "mixed survivor identity")
  return true
end function


function testParticleFloatBoundary()
  equal(particles.particleFloat(16777217), 16777216.0, "particle float boundary")
  return true
end function

function testParticleOriginStoredFloat()
  value = make(particles.PT_STATIC, t.Vec3(1.0, 0.0, 0.0), 2.0)
  value.origin.x = 16777216.0
  result = particles.updateWithGravity([value], 1.0, 1.0, 0.0)
  equal(native.floatBits(result[0].origin.x), native.floatBits(16777216.0), "stored origin bits")
  return true
end function

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
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 22 then return 1 end if
  print "MiniQuake BP-038 particle runtime tests passed: 22"
  return 0
end function
