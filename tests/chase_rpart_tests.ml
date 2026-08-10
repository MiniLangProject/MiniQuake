/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused chase.c and r_part.c behavioral fixtures.
*/

import miniquake.types as t
import miniquake.chase as chase
import miniquake.cvar as cvar
import miniquake.particles as particles
import miniquake.render.particles as particleRender
import miniquake.sizebuf as sz
import miniquake.message as msg

function assertEqual(actual, expected, name)
  if actual != expected then return error(9800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9801, name + ": expected true") end if
  return true
end function

function assertNear(actual, expected, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > 0.00001 then return error(9802, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertVec(value, x, y, z, name)
  assertNear(value.x, x, name + ".x")
  assertNear(value.y, y, name + ".y")
  assertNear(value.z, z, name + ".z")
end function

function inline firstGenerated(system)
  return system.active[len(system.active) - 1]
end function

function testChase()
  registry = cvar.createRegistry()
  state = chase.Chase_Init(registry)
  assertEqual(len(registry.variables), 4, "Chase_Init cvars")
  assertNear(cvar.variableValue(registry, "chase_back"), 100.0, "chase_back")
  assertNear(cvar.variableValue(registry, "chase_up"), 16.0, "chase_up")
  assertNear(cvar.variableValue(registry, "chase_right"), 0.0, "chase_right")
  assertNear(cvar.variableValue(registry, "chase_active"), 0.0, "chase_active")

  cvar.set(registry, "chase_right", "5")
  cvar.set(registry, "chase_active", "1")
  chase.syncCvars(state, registry)
  assertEqual(state.active, true, "sync active")
  result = chase.Chase_Update(state, t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 0.0, 0.0), void)
  assertVec(result[0], -90.0, 25.0, 46.0, "Chase_Update destination")
  assertVec(result[1], 0.0, 0.0, 0.0, "Chase_Update angles")
  assertVec(result[3], 4106.0, 20.0, 30.0, "TraceLine no-world impact")
  assertTrue(chase.Chase_Reset(state) == state, "Chase_Reset no-op")
  return true
end function

function testInitPoolAndRandom()
  minimum = particles.R_InitParticles(["-particles", "12"])
  assertEqual(minimum.capacity, particles.ABSOLUTE_MIN_PARTICLES, "absolute minimum particles")
  selected = particles.R_InitParticles(["-particles", "777"])
  assertEqual(selected.capacity, 777, "-particles value")
  defaults = particles.R_InitParticles([])
  assertEqual(defaults.capacity, particles.MAX_PARTICLES, "default particles")
  assertEqual(particles.R_Rand(defaults), 41, "MSVCRT rand first")
  assertEqual(particles.R_Rand(defaults), 18467, "MSVCRT rand second")
  particle = particles.R_AllocParticle(defaults)
  assertEqual(len(defaults.active), 1, "particle allocation")
  particles.R_ClearParticles(defaults)
  assertEqual(len(defaults.active), 0, "R_ClearParticles")
  oldParticle = particles.spawn(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 1.0, 1, particles.PT_STATIC)
  newParticle = particles.spawn(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 1.0, 2, particles.PT_STATIC)
  merged = particles.appendLimited([oldParticle], [newParticle])
  assertEqual(merged[0].color, 2, "new particles link at active-list head")
  assertEqual(merged[1].color, 1, "old particle follows new batch")
  return true
end function

function testEffectsAndRandomOrder()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_RunParticleEffect(
    system,
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(2.0, -1.0, 0.5),
    32,
    2,
    10.0,
  )
  assertEqual(len(system.active), 2, "regular effect count")
  first = firstGenerated(system)
  assertNear(first.die, 10.1, "regular die")
  assertEqual(first.color, 35, "regular color")
  assertVec(first.origin, 7.0, -2.0, -4.0, "regular origin")
  assertVec(first.velocity, 30.0, -15.0, 7.5, "regular velocity")
  assertEqual(first.type, particles.PT_SLOW_GRAVITY, "regular type")

  explosion = particles.createSystem(2048)
  particles.R_SetRandomSeed(explosion, 1)
  particles.R_ParticleExplosion(explosion, t.Vec3(0.0, 0.0, 0.0), 2.0)
  assertEqual(len(explosion.active), 1024, "particle explosion count")
  first = firstGenerated(explosion)
  assertEqual(first.ramp, 1, "explosion ramp rand order")
  assertEqual(first.type, particles.PT_EXPLODE2, "explosion alternating first")
  assertVec(first.origin, -13.0, -12.0, -4.0, "explosion origin")
  assertVec(first.velocity, -66.0, -31.0, -42.0, "explosion velocity")

  explosionEffect = particles.createSystem(2048)
  particles.R_SetRandomSeed(explosionEffect, 1)
  particles.R_RunParticleEffect(explosionEffect, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 99, 1024, 2.0)
  effectFirst = firstGenerated(explosionEffect)
  assertVec(effectFirst.origin, first.origin.x, first.origin.y, first.origin.z, "1024 effect explosion identity")
  assertVec(effectFirst.velocity, first.velocity.x, first.velocity.y, first.velocity.z, "1024 effect velocity identity")

  second = particles.createSystem(512)
  particles.R_SetRandomSeed(second, 1)
  particles.R_ParticleExplosion2(second, t.Vec3(0.0, 0.0, 0.0), 120, 3, 4.0)
  assertEqual(len(second.active), 512, "explosion2 count")
  assertEqual(firstGenerated(second).color, 120, "explosion2 color sequence")

  blob = particles.createSystem(2048)
  particles.R_SetRandomSeed(blob, 1)
  particles.R_BlobExplosion(blob, t.Vec3(0.0, 0.0, 0.0), 3.0)
  first = firstGenerated(blob)
  assertNear(first.die, 4.4, "blob die rand bit quirk")
  assertEqual(first.type, particles.PT_BLOB2, "blob alternating first")
  assertEqual(first.color, 155, "blob color")
  assertVec(first.origin, 14.0, -15.0, 6.0, "blob origin")
  assertVec(first.velocity, 132.0, 108.0, -82.0, "blob velocity")
  return true
end function

function testSplashEntityAndPointFile()
  lava = particles.createSystem(2048)
  particles.R_LavaSplash(lava, t.Vec3(10.0, 20.0, 30.0), 1.0)
  assertEqual(len(lava.active), 1024, "lava count")
  lavaFirst = firstGenerated(lava)
  assertEqual(lavaFirst.type, particles.PT_SLOW_GRAVITY, "lava type")
  assertTrue(lavaFirst.color >= 224 and lavaFirst.color <= 231, "lava color range")

  teleport = particles.createSystem(2048)
  particles.R_TeleportSplash(teleport, t.Vec3(0.0, 0.0, 0.0), 1.0)
  assertEqual(len(teleport.active), 896, "teleport lattice count")

  dark = particles.createSystem(512)
  particles.R_DarkFieldParticles(dark, t.Vec3(0.0, 0.0, 0.0), 1.0)
  assertEqual(len(dark.active), 64, "dark-field lattice count")

  entity = particles.createSystem(512)
  particles.R_SetRandomSeed(entity, 1)
  normals = [t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 1.0, 0.0)]
  particles.R_EntityParticles(entity, t.Vec3(0.0, 0.0, 0.0), 0.0, normals)
  assertEqual(len(entity.active), 2, "entity particle count")
  assertVec(firstGenerated(entity).origin, 80.0, 0.0, 0.0, "entity first origin")
  assertEqual(len(entity.angularVelocities), 2, "entity angular initialization")
  assertNear(entity.angularVelocities[0].x, 0.41, "entity angular rand")
  canonical = particles.entityParticlesInto([], t.Vec3(0.0, 0.0, 0.0), 0.0)
  assertEqual(len(canonical), particles.NUM_VERTEX_NORMALS, "canonical brightfield normal count")

  points = particles.createSystem(512)
  count = particles.R_ReadPointFile_f(points, "1 2 3\n-4.5 6 7\nbad")
  assertEqual(count, 2, "point-file count")
  assertEqual(firstGenerated(points).color, 15, "point-file first color")
  assertVec(firstGenerated(points).origin, 1.0, 2.0, 3.0, "point-file origin")
  return true
end function

function testParseAndTrails()
  buffer = sz.alloc(32)
  msg.writeCoord(buffer, 1.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeCoord(buffer, 3.0)
  msg.writeChar(buffer, 16)
  msg.writeChar(buffer, -16)
  msg.writeChar(buffer, 0)
  msg.writeByte(buffer, 255)
  msg.writeByte(buffer, 40)
  reader = msg.beginReading(buffer)
  parsed = particles.createSystem(2048)
  particles.R_ParseParticleEffect(parsed, reader, 5.0)
  assertEqual(len(parsed.active), 1024, "R_ParseParticleEffect 255 count")
  assertEqual(reader.badRead, false, "R_ParseParticleEffect range")

  rocket = particles.createSystem(512)
  particles.R_SetRandomSeed(rocket, 1)
  start = t.Vec3(0.0, 0.0, 0.0)
  particles.R_RocketTrail(rocket, start, t.Vec3(10.0, 0.0, 0.0), 0, 2.0)
  assertEqual(len(rocket.active), 4, "rocket trail count")
  assertVec(start, 4.0, 0.0, 0.0, "rocket trail mutates start")
  first = firstGenerated(rocket)
  assertEqual(first.ramp, 1, "rocket trail ramp")
  assertEqual(first.color, particles.ramp3[1], "rocket trail color")
  assertVec(first.origin, 2.0, 1.0, 1.0, "rocket trail jitter")

  slight = particles.createSystem(512)
  particles.R_RocketTrail(slight, t.Vec3(0.0, 0.0, 0.0), t.Vec3(10.0, 0.0, 0.0), 4, 0.0)
  assertEqual(len(slight.active), 2, "slight blood extra decrement")

  tracer = particles.createSystem(512)
  particles.R_RocketTrail(tracer, t.Vec3(0.0, 0.0, 0.0), t.Vec3(7.0, 0.0, 0.0), 3, 0.0)
  assertEqual(len(tracer.active), 3, "tracer count")
  assertNear(firstGenerated(tracer).velocity.y, -30.0, "tracer first side")
  assertNear(tracer.active[1].velocity.y, 30.0, "tracer alternating side")

  saturated = particles.createSystem(2048)
  index = 0
  while index < 2047
    particles.R_AllocParticle(saturated)
    index = index + 1
  end while
  integrated = particles.rocketTrailInto(
    saturated.active,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(10.0, 0.0, 0.0),
    0,
    2.0,
  )
  assertEqual(len(integrated), 2048, "integrated trail respects shared pool saturation")
  assertEqual(integrated[0].type, particles.PT_FIRE, "integrated trail links at active head")
  return true
end function

function testDrawPhysicsAndTexture()
  texture = particleRender.particleTexturePixels()
  assertEqual(len(texture), 256, "particle texture byte count")
  assertEqual(texture[3], 0, "particle texture transparent corner")
  assertEqual(texture[7], 255, "particle texture dot alpha")
  assertEqual(texture[0], 255, "particle texture white red")

  system = particles.createSystem(512)
  particle = particles.R_AllocParticle(system)
  particle.origin = t.Vec3(100.0, 0.0, 0.0)
  particle.velocity = t.Vec3(0.0, 0.0, 10.0)
  particle.die = 10.0
  particle.type = particles.PT_BLOB2
  trace = particles.R_DrawParticles(
    system,
    1.0,
    0.9,
    800.0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    t.Vec3(0.0, -1.0, 0.0),
  )
  assertEqual(len(trace), 8, "draw command count")
  assertEqual(trace[0][0], "GL_Bind", "draw bind command")
  assertEqual(trace[4][0], "particle", "draw particle command")
  assertNear(trace[4][5], 1.4, "distance particle scale")
  assertVec(trace[4][3], 100.0, 0.0, 2.1, "up triangle vertex")
  assertVec(trace[4][4], 100.0, -2.1, 0.0, "right triangle vertex")
  assertNear(particle.velocity.x, 0.0, "blob2 x damping")
  assertNear(particle.velocity.z, 6.0, "blob2 z gravity only")
  assertNear(particle.origin.z, 1.0, "draw-before-physics integration")

  renderTrace = particleRender.R_DrawParticlesTrace(
    system.active,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    t.Vec3(0.0, -1.0, 0.0),
  )
  assertEqual(renderTrace[3][1], "GL_TRIANGLES", "renderer triangle mode")

  fireSystem = particles.createSystem(512)
  fire = particles.R_AllocParticle(fireSystem)
  fire.die = 10.0
  fire.type = particles.PT_FIRE
  fire.ramp = 5.9
  particles.R_DrawParticles(fireSystem, 1.0, 0.9, 800.0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 1.0), t.Vec3(0.0, -1.0, 0.0))
  assertEqual(len(fireSystem.active), 1, "ramp death delayed until next draw")
  assertNear(fire.die, -1.0, "ramp sets die")
  assertNear(fire.velocity.z, 4.0, "fire rises by grav")
  particles.R_DrawParticles(fireSystem, 1.1, 1.0, 800.0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 1.0), t.Vec3(0.0, -1.0, 0.0))
  assertEqual(len(fireSystem.active), 0, "expired ramp removed")

  // The host-side simulation path must remain bounded when a retail explosion
  // fills half the original 2048-particle pool.  It intentionally performs no
  // GL command-trace allocation.
  particles.resetRandom(1)
  active = particles.explosion(t.Vec3(0.0, 0.0, 0.0), 0.0)
  frame = 0
  while frame < 400
    active = particles.update(active, frame * 0.02, 0.02)
    frame = frame + 1
  end while
  assertEqual(len(active), 0, "headless particle simulation drains explosion")
  return true
end function

function main(args)
  print "[1/6] chase.c"
  result = try(testChase())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[2/6] particle init/pool/rand"
  result = try(testInitPoolAndRandom())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[3/6] effects/explosions"
  result = try(testEffectsAndRandomOrder())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[4/6] splashes/entity/point file"
  result = try(testSplashEntityAndPointFile())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[5/6] protocol/trails"
  result = try(testParseAndTrails())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[6/6] draw/physics/texture"
  result = try(testDrawPhysicsAndTexture())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "MiniQuake chase/r_part compatibility tests passed: 6"
  return 0
end function
