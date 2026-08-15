/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang pendant for WinQuake/r_part.c.  The C free/active linked lists are
represented by a bounded ParticleSystem whose active array retains list order.
*/
package miniquake.particles

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.common as common
import miniquake.message as msg
import miniquake.array_util as arrays
import miniquake.render.alias_normals as aliasNormals

const PT_STATIC = 0
const PT_GRAVITY = 1
const PT_SLOW_GRAVITY = 2
const PT_FIRE = 3
const PT_EXPLODE = 4
const PT_EXPLODE2 = 5
const PT_BLOB = 6
const PT_BLOB2 = 7

const MAX_PARTICLES = 2048
const ABSOLUTE_MIN_PARTICLES = 512
const NUM_VERTEX_NORMALS = 162

// Provide particle float behavior for the active subsystem.
function particleFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

ramp1 = [0x6f, 0x6d, 0x6b, 0x69, 0x67, 0x65, 0x63, 0x61]
ramp2 = [0x6f, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x68, 0x66]
ramp3 = [0x6d, 0x6b, 6, 5, 4, 3]

struct ParticleSystem
  capacity
  active
  randomSeed
  tracerCount
  angularVelocities
end struct

compatRandomSeed = 1
compatTracerCount = 0
compatAngularVelocities = []
canonicalVertexNormals = []

// Allocate and initialize the requested value.
function spawn(origin, velocity, dieTime, color, type)
  originCopy = t.Vec3(origin.x, origin.y, origin.z)
  velocityCopy = t.Vec3(velocity.x, velocity.y, velocity.z)
  return t.Particle(originCopy, velocityCopy, dieTime, color, 0.0, type)
end function

// Create the zero-initialized state for vector.
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

// Create and initialize system.
function createSystem(capacity)
  if capacity < ABSOLUTE_MIN_PARTICLES then capacity = ABSOLUTE_MIN_PARTICLES end if
  return ParticleSystem(capacity, [], 1, 0, [])
end function

// Apply the Quake-compatible r init particles behavior.
function R_InitParticles(arguments)
  capacity = MAX_PARTICLES
  index = 0
  while index < len(arguments)
    if arguments[index] == "-particles" then
      if index + 1 >= len(arguments) then return error(3700, "-particles requires a count") end if
      capacity = common.atoi(arguments[index + 1])
      if capacity < ABSOLUTE_MIN_PARTICLES then capacity = ABSOLUTE_MIN_PARTICLES end if
      break
    end if
    index = index + 1
  end while
  return createSystem(capacity)
end function

// Apply the Quake-compatible r clear particles behavior.
function R_ClearParticles(system)
  system.active = []
  return system
end function

// Apply the Quake-compatible r set random seed behavior.
function R_SetRandomSeed(system, seed)
  system.randomSeed = seed & 0xffffffff
  return system.randomSeed
end function

// MiniQuake's Win32 build uses the Microsoft C runtime rand() sequence.
function R_Rand(system)
  system.randomSeed = (system.randomSeed * 214013 + 2531011) & 0xffffffff
  return (system.randomSeed >> 16) & 0x7fff
end function

// Apply the Quake-compatible r alloc particle behavior.
function R_AllocParticle(system)
  if len(system.active) >= system.capacity then return void end if
  origin = zeroVector()
  velocity = zeroVector()
  particle = spawn(origin, velocity, 0.0, 0, PT_STATIC)
  // r_part.c links every newly allocated particle at the active-list head.
  previous = system.active
  system.active = [particle] + previous
  return particle
end function

// Provide ramp color behavior for the active subsystem.
function rampColor(values, ramp)
  index = native.trunc(ramp)
  if index < 0 then index = 0 end if
  if index >= len(values) then return -1 end if
  return values[index]
end function

// Apply the Quake-compatible r dark field particles behavior.
function R_DarkFieldParticles(system, entityOrigin, currentTime)
  i = -16
  while i < 16
    j = -16
    while j < 16
      k = 0
      while k < 32
        particle = R_AllocParticle(system)
        if particle is void then return system.active end if
        particle.die = currentTime + 0.2 + (R_Rand(system) & 7) * 0.02
        particle.color = 150 + (R_Rand(system) % 6)
        particle.type = PT_SLOW_GRAVITY

        direction = t.Vec3(j * 8.0, i * 8.0, k * 8.0)
        particle.origin.x = entityOrigin.x + i + (R_Rand(system) & 3)
        particle.origin.y = entityOrigin.y + j + (R_Rand(system) & 3)
        particle.origin.z = entityOrigin.z + k + (R_Rand(system) & 3)
        math.VectorNormalize(direction)
        velocity = 50.0 + (R_Rand(system) & 63)
        particle.velocity = math.VectorScale(direction, velocity)
        k = k + 8
      end while
      j = j + 8
    end while
    i = i + 8
  end while
  return system.active
end function

// Initialize state for initialize angular velocities.
function initializeAngularVelocities(system, count)
  if len(system.angularVelocities) != 0 then return true end if
  system.angularVelocities = []
  index = 0
  while index < count
    system.angularVelocities = system.angularVelocities + [
      t.Vec3(
        (R_Rand(system) & 255) * 0.01,
        (R_Rand(system) & 255) * 0.01,
        (R_Rand(system) & 255) * 0.01,
      )
    ]
    index = index + 1
  end while
  return true
end function

// r_avertexnormals belongs to the renderer rather than r_part.c, so callers
// provide that canonical 162-vector table as the explicit dependency.
function R_EntityParticles(system, entityOrigin, currentTime, vertexNormals)
  count = len(vertexNormals)
  if count > NUM_VERTEX_NORMALS then count = NUM_VERTEX_NORMALS end if
  initializeAngularVelocities(system, count)
  index = 0
  while index < count
    angular = system.angularVelocities[index]
    yaw = currentTime * angular.x
    pitch = currentTime * angular.y
    roll = currentTime * angular.z
    sy = math.sin(yaw)
    cy = math.cos(yaw)
    sp = math.sin(pitch)
    cp = math.cos(pitch)
    // The original calculates roll sine/cosine even though the values are
    // unused; preserve the calls' floating-point side effects/order.
    sr = math.sin(roll)
    cr = math.cos(roll)
    forward = t.Vec3(cp * cy, cp * sy, -sp)

    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    particle.die = currentTime + 0.01
    particle.color = 0x6f
    particle.type = PT_EXPLODE
    normal = vertexNormals[index]
    particle.origin = t.Vec3(
      entityOrigin.x + normal.x * 64.0 + forward.x * 16.0,
      entityOrigin.y + normal.y * 64.0 + forward.y * 16.0,
      entityOrigin.z + normal.z * 64.0 + forward.z * 16.0,
    )
    index = index + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r read point file f behavior.
function R_ReadPointFile_f(system, text)
  offset = 0
  pointCount = 0
  reading = true
  while reading
    first = common.parseToken(text, offset)
    if first[2] then break end if
    second = common.parseToken(text, first[1])
    third = common.parseToken(text, second[1])
    if second[2] or third[2] then break end if
    offset = third[1]

    particle = R_AllocParticle(system)
    if particle is void then break end if
    pointCount = pointCount + 1
    particle.die = 99999.0
    particle.color = (-pointCount) & 15
    particle.type = PT_STATIC
    particle.velocity = zeroVector()
    particle.origin = t.Vec3(common.atof(first[0]), common.atof(second[0]), common.atof(third[0]))
  end while
  return pointCount
end function

// Apply the Quake-compatible r parse particle effect behavior.
function R_ParseParticleEffect(system, reader, currentTime)
  origin = t.Vec3(msg.readCoord(reader), msg.readCoord(reader), msg.readCoord(reader))
  direction = t.Vec3(
    msg.readChar(reader) * 0.0625,
    msg.readChar(reader) * 0.0625,
    msg.readChar(reader) * 0.0625,
  )
  messageCount = msg.readByte(reader)
  color = msg.readByte(reader)
  count = messageCount
  if messageCount == 255 then count = 1024 end if
  return R_RunParticleEffect(system, origin, direction, color, count, currentTime)
end function

// Return random explosion vector derived from the active module state.
function randomExplosionVector(system, origin, particle)
  // The C body assigns org[j] and vel[j] in the same loop.  The interleaved
  // rand() order is observable in demos/effects and must not be regrouped.
  particle.origin.x = origin.x + (R_Rand(system) % 32) - 16
  particle.velocity.x = (R_Rand(system) % 512) - 256
  particle.origin.y = origin.y + (R_Rand(system) % 32) - 16
  particle.velocity.y = (R_Rand(system) % 512) - 256
  particle.origin.z = origin.z + (R_Rand(system) % 32) - 16
  particle.velocity.z = (R_Rand(system) % 512) - 256
end function

// Apply the Quake-compatible r particle explosion behavior.
function R_ParticleExplosion(system, origin, currentTime)
  index = 0
  while index < 1024
    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    particle.die = currentTime + 5.0
    particle.color = ramp1[0]
    particle.ramp = R_Rand(system) & 3
    particle.type = PT_EXPLODE2
    if (index & 1) != 0 then particle.type = PT_EXPLODE end if
    randomExplosionVector(system, origin, particle)
    index = index + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r particle explosion2 behavior.
function R_ParticleExplosion2(system, origin, colorStart, colorLength, currentTime)
  if colorLength <= 0 then return error(3701, "R_ParticleExplosion2 colorLength must be positive") end if
  colorMod = 0
  index = 0
  while index < 512
    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    particle.die = currentTime + 0.3
    particle.color = colorStart + (colorMod % colorLength)
    colorMod = colorMod + 1
    particle.type = PT_BLOB
    randomExplosionVector(system, origin, particle)
    index = index + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r blob explosion behavior.
function R_BlobExplosion(system, origin, currentTime)
  index = 0
  while index < 1024
    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    particle.die = currentTime + 1.0 + (R_Rand(system) & 8) * 0.05
    if (index & 1) != 0 then
      particle.type = PT_BLOB
      particle.color = 66 + (R_Rand(system) % 6)
    else
      particle.type = PT_BLOB2
      particle.color = 150 + (R_Rand(system) % 6)
    end if
    randomExplosionVector(system, origin, particle)
    index = index + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r run particle effect behavior.
function R_RunParticleEffect(system, origin, direction, color, count, currentTime)
  index = 0
  while index < count
    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    if count == 1024 then
      particle.die = currentTime + 5.0
      particle.color = ramp1[0]
      particle.ramp = R_Rand(system) & 3
      particle.type = PT_EXPLODE2
      if (index & 1) != 0 then particle.type = PT_EXPLODE end if
      randomExplosionVector(system, origin, particle)
    else
      particle.die = currentTime + 0.1 * (R_Rand(system) % 5)
      particle.color = (color & ~7) + (R_Rand(system) & 7)
      particle.type = PT_SLOW_GRAVITY
      particle.origin = t.Vec3(
        origin.x + (R_Rand(system) & 15) - 8,
        origin.y + (R_Rand(system) & 15) - 8,
        origin.z + (R_Rand(system) & 15) - 8,
      )
      particle.velocity = math.VectorScale(direction, 15.0)
    end if
    index = index + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r lava splash behavior.
function R_LavaSplash(system, origin, currentTime)
  i = -16
  while i < 16
    j = -16
    while j < 16
      particle = R_AllocParticle(system)
      if particle is void then return system.active end if
      particle.die = currentTime + 2.0 + (R_Rand(system) & 31) * 0.02
      particle.color = 224 + (R_Rand(system) & 7)
      particle.type = PT_SLOW_GRAVITY
      direction = t.Vec3(
        j * 8.0 + (R_Rand(system) & 7),
        i * 8.0 + (R_Rand(system) & 7),
        256.0,
      )
      particle.origin = t.Vec3(origin.x + direction.x, origin.y + direction.y, origin.z + (R_Rand(system) & 63))
      math.VectorNormalize(direction)
      velocity = 50.0 + (R_Rand(system) & 63)
      particle.velocity = math.VectorScale(direction, velocity)
      j = j + 1
    end while
    i = i + 1
  end while
  return system.active
end function

// Apply the Quake-compatible r teleport splash behavior.
function R_TeleportSplash(system, origin, currentTime)
  i = -16
  while i < 16
    j = -16
    while j < 16
      k = -24
      while k < 32
        particle = R_AllocParticle(system)
        if particle is void then return system.active end if
        particle.die = currentTime + 0.2 + (R_Rand(system) & 7) * 0.02
        particle.color = 7 + (R_Rand(system) & 7)
        particle.type = PT_SLOW_GRAVITY
        direction = t.Vec3(j * 8.0, i * 8.0, k * 8.0)
        particle.origin = t.Vec3(
          origin.x + i + (R_Rand(system) & 3),
          origin.y + j + (R_Rand(system) & 3),
          origin.z + k + (R_Rand(system) & 3),
        )
        math.VectorNormalize(direction)
        velocity = 50.0 + (R_Rand(system) & 63)
        particle.velocity = math.VectorScale(direction, velocity)
        k = k + 4
      end while
      j = j + 4
    end while
    i = i + 4
  end while
  return system.active
end function

// Apply the Quake-compatible r rocket trail behavior.
function R_RocketTrail(system, start, finish, trailType, currentTime)
  direction = math.VectorSubtract(finish, start)
  length = math.VectorNormalize(direction)
  decrement = 3.0
  if trailType >= 128 then
    decrement = 1.0
    trailType = trailType - 128
  end if

  while length > 0.0
    length = length - decrement
    particle = R_AllocParticle(system)
    if particle is void then return system.active end if
    particle.velocity = zeroVector()
    particle.die = currentTime + 2.0

    if trailType == 0 then
      particle.ramp = R_Rand(system) & 3
      particle.color = ramp3[native.trunc(particle.ramp)]
      particle.type = PT_FIRE
      particle.origin = t.Vec3(
        start.x + (R_Rand(system) % 6) - 3,
        start.y + (R_Rand(system) % 6) - 3,
        start.z + (R_Rand(system) % 6) - 3,
      )
    else if trailType == 1 then
      particle.ramp = (R_Rand(system) & 3) + 2
      particle.color = ramp3[native.trunc(particle.ramp)]
      particle.type = PT_FIRE
      particle.origin = t.Vec3(
        start.x + (R_Rand(system) % 6) - 3,
        start.y + (R_Rand(system) % 6) - 3,
        start.z + (R_Rand(system) % 6) - 3,
      )
    else if trailType == 2 or trailType == 4 then
      particle.type = PT_GRAVITY
      particle.color = 67 + (R_Rand(system) & 3)
      particle.origin = t.Vec3(
        start.x + (R_Rand(system) % 6) - 3,
        start.y + (R_Rand(system) % 6) - 3,
        start.z + (R_Rand(system) % 6) - 3,
      )
      if trailType == 4 then length = length - 3.0 end if
    else if trailType == 3 or trailType == 5 then
      particle.die = currentTime + 0.5
      particle.type = PT_STATIC
      if trailType == 3 then
        particle.color = 52 + ((system.tracerCount & 4) << 1)
      else
        particle.color = 230 + ((system.tracerCount & 4) << 1)
      end if
      system.tracerCount = system.tracerCount + 1
      particle.origin = math.VectorCopy(start)
      if (system.tracerCount & 1) != 0 then
        particle.velocity.x = 30.0 * direction.y
        particle.velocity.y = -30.0 * direction.x
      else
        particle.velocity.x = -30.0 * direction.y
        particle.velocity.y = 30.0 * direction.x
      end if
    else if trailType == 6 then
      particle.color = 152 + (R_Rand(system) & 3)
      particle.type = PT_STATIC
      particle.die = currentTime + 0.3
      particle.origin = t.Vec3(
        start.x + (R_Rand(system) & 15) - 8,
        start.y + (R_Rand(system) & 15) - 8,
        start.z + (R_Rand(system) & 15) - 8,
      )
    end if

    // VectorAdd(start, vec, start) mutates the caller's start vector in C.
    start.x = start.x + direction.x
    start.y = start.y + direction.y
    start.z = start.z + direction.z
  end while
  return system.active
end function

// Provide particle draw command behavior for the active subsystem.
function particleDrawCommand(particle, viewOrigin, viewForward, scaledUp, scaledRight)
  distance = math.DotProduct(math.VectorSubtract(particle.origin, viewOrigin), viewForward)
  scale = 1.0
  if distance >= 20.0 then scale = 1.0 + distance * 0.004 end if
  upVertex = math.VectorMA(particle.origin, scale, scaledUp)
  rightVertex = math.VectorMA(particle.origin, scale, scaledRight)
  return ["particle", particle.color, math.VectorCopy(particle.origin), upVertex, rightVertex, scale]
end function

// Update module state for particle physics.
function updateParticlePhysics(particle, frameTime, gravity)
  // r_part.c stores frametime and all particle fields as float.
  frameTime = particleFloat(frameTime)
  grav = particleFloat(particleFloat(frameTime * gravity) * 0.05)
  time3 = particleFloat(frameTime * 15.0)
  time2 = particleFloat(frameTime * 10.0)
  time1 = particleFloat(frameTime * 5.0)
  dvel = particleFloat(4.0 * frameTime)

  // VectorMA(p->org, frametime, p->vel, p->org) mutates the C particle in
  // place.  Keep the same lifetime here: allocating a replacement Vec3 for
  // every active particle creates thousands of short-lived objects and can
  // trigger collection while a large active array is being traversed.
  particle.origin.x = particleFloat(particle.origin.x + frameTime * particle.velocity.x)
  particle.origin.y = particleFloat(particle.origin.y + frameTime * particle.velocity.y)
  particle.origin.z = particleFloat(particle.origin.z + frameTime * particle.velocity.z)
  if particle.type == PT_FIRE then
    particle.ramp = particleFloat(particle.ramp + time1)
    rampIndex = native.trunc(particle.ramp)
    if particle.ramp >= 6.0 or rampIndex < 0 or rampIndex >= len(ramp3) then particle.die = -1.0 else particle.color = ramp3[rampIndex] end if
    particle.velocity.z = particleFloat(particle.velocity.z + grav)
  else if particle.type == PT_EXPLODE then
    particle.ramp = particleFloat(particle.ramp + time2)
    rampIndex = native.trunc(particle.ramp)
    if particle.ramp >= 8.0 or rampIndex < 0 or rampIndex >= len(ramp1) then particle.die = -1.0 else particle.color = ramp1[rampIndex] end if
    particle.velocity.x = particleFloat(particle.velocity.x + particle.velocity.x * dvel)
    particle.velocity.y = particleFloat(particle.velocity.y + particle.velocity.y * dvel)
    particle.velocity.z = particleFloat(particle.velocity.z + particle.velocity.z * dvel)
    particle.velocity.z = particleFloat(particle.velocity.z - grav)
  else if particle.type == PT_EXPLODE2 then
    particle.ramp = particleFloat(particle.ramp + time3)
    rampIndex = native.trunc(particle.ramp)
    if particle.ramp >= 8.0 or rampIndex < 0 or rampIndex >= len(ramp2) then particle.die = -1.0 else particle.color = ramp2[rampIndex] end if
    particle.velocity.x = particleFloat(particle.velocity.x - particle.velocity.x * frameTime)
    particle.velocity.y = particleFloat(particle.velocity.y - particle.velocity.y * frameTime)
    particle.velocity.z = particleFloat(particle.velocity.z - particle.velocity.z * frameTime)
    particle.velocity.z = particleFloat(particle.velocity.z - grav)
  else if particle.type == PT_BLOB then
    particle.velocity.x = particleFloat(particle.velocity.x + particle.velocity.x * dvel)
    particle.velocity.y = particleFloat(particle.velocity.y + particle.velocity.y * dvel)
    particle.velocity.z = particleFloat(particle.velocity.z + particle.velocity.z * dvel)
    particle.velocity.z = particleFloat(particle.velocity.z - grav)
  else if particle.type == PT_BLOB2 then
    particle.velocity.x = particleFloat(particle.velocity.x - particle.velocity.x * dvel)
    particle.velocity.y = particleFloat(particle.velocity.y - particle.velocity.y * dvel)
    particle.velocity.z = particleFloat(particle.velocity.z - grav)
  else if particle.type == PT_GRAVITY or particle.type == PT_SLOW_GRAVITY then
    particle.velocity.z = particleFloat(particle.velocity.z - grav)
  end if
  return particle
end function

// Produces the fixed-function MiniQuake command trace and advances particles in
// the same draw-before-simulate order as R_DrawParticles.
function R_DrawParticles(system, currentTime, oldTime, gravity, viewOrigin, viewForward, viewUp, viewRight)
  activeCount = len(system.active)
  commandBuffer = array(activeCount + 7, void)
  commandCount = 0
  commandBuffer[commandCount] = ["GL_Bind", "particletexture"]
  commandCount = commandCount + 1
  commandBuffer[commandCount] = ["glEnable", "GL_BLEND"]
  commandCount = commandCount + 1
  commandBuffer[commandCount] = ["glTexEnv", "GL_MODULATE"]
  commandCount = commandCount + 1
  commandBuffer[commandCount] = ["glBegin", "GL_TRIANGLES"]
  commandCount = commandCount + 1

  scaledUp = math.VectorScale(viewUp, 1.5)
  scaledRight = math.VectorScale(viewRight, 1.5)
  frameTime = currentTime - oldTime
  aliveBuffer = array(activeCount, void)
  aliveCount = 0
  index = 0
  while index < activeCount
    particle = system.active[index]
    if particle.die >= currentTime then
      commandBuffer[commandCount] = particleDrawCommand(particle, viewOrigin, viewForward, scaledUp, scaledRight)
      commandCount = commandCount + 1
      updateParticlePhysics(particle, frameTime, gravity)
      aliveBuffer[aliveCount] = particle
      aliveCount = aliveCount + 1
    end if
    index = index + 1
  end while
  system.active = arrays.copyArrayPrefix(aliveBuffer, aliveCount)

  commandBuffer[commandCount] = ["glEnd"]
  commandCount = commandCount + 1
  commandBuffer[commandCount] = ["glDisable", "GL_BLEND"]
  commandCount = commandCount + 1
  commandBuffer[commandCount] = ["glTexEnv", "GL_REPLACE"]
  commandCount = commandCount + 1
  return arrays.copyArrayPrefix(commandBuffer, commandCount)
end function

// Provide compatibility system behavior for the active subsystem.
function compatibilitySystem()
  global compatRandomSeed, compatTracerCount, compatAngularVelocities
  return ParticleSystem(MAX_PARTICLES, [], compatRandomSeed, compatTracerCount, compatAngularVelocities)
end function

// Report whether compatibility system with active holds for the active state.
function compatibilitySystemWithActive(active)
  global compatRandomSeed, compatTracerCount, compatAngularVelocities
  return ParticleSystem(MAX_PARTICLES, active, compatRandomSeed, compatTracerCount, compatAngularVelocities)
end function

// Provide canonical entity normals behavior for the active subsystem.
function canonicalEntityNormals()
  global canonicalVertexNormals
  if len(canonicalVertexNormals) == NUM_VERTEX_NORMALS then return canonicalVertexNormals end if
  canonicalVertexNormals = arrays.makeEmptyArray(len(aliasNormals.normals))
  index = 0
  while index < len(aliasNormals.normals)
    source = aliasNormals.normals[index]
    canonicalVertexNormals[index] = t.Vec3(source[0], source[1], source[2])
    index = index + 1
  end while
  return canonicalVertexNormals
end function

// Finalize state for finish compatibility.
function finishCompatibility(system)
  global compatRandomSeed, compatTracerCount, compatAngularVelocities
  compatRandomSeed = system.randomSeed
  compatTracerCount = system.tracerCount
  compatAngularVelocities = system.angularVelocities
  return system.active
end function

// Update module state for random.
function resetRandom(seed)
  global compatRandomSeed, compatTracerCount, compatAngularVelocities
  compatRandomSeed = seed & 0xffffffff
  compatTracerCount = 0
  compatAngularVelocities = []
  return compatRandomSeed
end function

// Provide compat rand behavior for the active subsystem.
function compatRand()
  global compatRandomSeed
  compatRandomSeed = (compatRandomSeed * 214013 + 2531011) & 0xffffffff
  return (compatRandomSeed >> 16) & 0x7fff
end function

// Add state for append limited.
function appendLimited(target, source)
  appendCount = len(source)
  available = MAX_PARTICLES - len(target)
  if appendCount > available then appendCount = available end if
  if appendCount <= 0 then return target end if
  result = arrays.makeEmptyArray(len(target) + appendCount)
  index = 0
  // R_AllocParticle links each new particle at active_particles' head.
  // Preserve that ordering when the compatibility wrappers merge a newly
  // spawned batch into the session-owned active array.
  while index < appendCount
    result[index] = source[index]
    index = index + 1
  end while
  targetIndex = 0
  while targetIndex < len(target)
    result[index] = target[targetIndex]
    targetIndex = targetIndex + 1
    index = index + 1
  end while
  return result
end function

// Update module state for with gravity.
function updateWithGravity(particles, currentTime, deltaTime, gravity)
  // Host_Frame advances effects even in a headless client/demo.  Building the
  // complete GL command trace here used to allocate several copied Vec3s and
  // an ever-growing nested array for every one of up to 2048 particles even
  // though the result was discarded.  Besides quadratic allocation traffic,
  // that could force a collection while the command array was only partially
  // rooted.  Advance in the same draw-before-simulate order without producing
  // renderer commands; R_DrawParticles remains the trace/render oracle.
  activeCount = len(particles)
  survivorCount = 0
  readIndex = 0
  while readIndex < activeCount
    particle = particles[readIndex]
    if particle.die >= currentTime then survivorCount = survivorCount + 1 end if
    readIndex = readIndex + 1
  end while
  // Most frames have no particle crossing its die time. The particle structs
  // are intentionally advanced in place, so preserve the already-rooted active
  // array instead of allocating and filling an identical replacement.
  if survivorCount == activeCount then
    readIndex = 0
    while readIndex < activeCount
      updateParticlePhysics(particles[readIndex], deltaTime, gravity)
      readIndex = readIndex + 1
    end while
    return particles
  end if
  alive = arrays.makeEmptyArray(survivorCount)
  readIndex = 0
  writeIndex = 0
  while readIndex < activeCount
    particle = particles[readIndex]
    if particle.die >= currentTime then
      updateParticlePhysics(particle, deltaTime, gravity)
      if writeIndex >= len(alive) then return error(3702, "particle survivor count changed during update") end if
      alive[writeIndex] = particle
      writeIndex = writeIndex + 1
    end if
    readIndex = readIndex + 1
  end while
  return alive
end function

// Compatibility wrapper for callers that do not own the server cvar table.
// The integrated Host_Frame path uses updateWithGravity and passes the current
// sv_gravity value, matching R_DrawParticles' extern cvar dependency.
function update(particles, currentTime, deltaTime)
  return updateWithGravity(particles, currentTime, deltaTime, 800.0)
end function

// Execute effect.
function runEffect(origin, direction, count, color, currentTime)
  system = compatibilitySystem()
  R_RunParticleEffect(system, origin, direction, color, count, currentTime)
  return finishCompatibility(system)
end function

// Provide point effect behavior for the active subsystem.
function pointEffect(origin, count, color, currentTime)
  return runEffect(origin, zeroVector(), count, color, currentTime)
end function

// Provide explosion behavior for the active subsystem.
function explosion(origin, currentTime)
  system = compatibilitySystem()
  R_ParticleExplosion(system, origin, currentTime)
  return finishCompatibility(system)
end function

// Provide explosion2 behavior for the active subsystem.
function explosion2(origin, colorStart, colorLength, currentTime)
  system = compatibilitySystem()
  result = R_ParticleExplosion2(system, origin, colorStart, colorLength, currentTime)
  if result is error then return result end if
  return finishCompatibility(system)
end function

// Provide blob explosion behavior for the active subsystem.
function blobExplosion(origin, currentTime)
  system = compatibilitySystem()
  R_BlobExplosion(system, origin, currentTime)
  return finishCompatibility(system)
end function

// Provide lava splash behavior for the active subsystem.
function lavaSplash(origin, currentTime)
  system = compatibilitySystem()
  R_LavaSplash(system, origin, currentTime)
  return finishCompatibility(system)
end function

// Provide teleport splash behavior for the active subsystem.
function teleportSplash(origin, currentTime)
  system = compatibilitySystem()
  R_TeleportSplash(system, origin, currentTime)
  return finishCompatibility(system)
end function

// Provide rocket trail behavior for the active subsystem.
function rocketTrail(start, finish, trailType, currentTime)
  system = compatibilitySystem()
  R_RocketTrail(system, start, finish, trailType, currentTime)
  return finishCompatibility(system)
end function

// CL_RelinkEntities shares r_part.c's single active/free particle pool with
// temp entities.  These integration helpers operate on that existing pool so
// saturation stops allocation (and random-number consumption) at the same
// particle as the original linked-list implementation.
function entityParticlesInto(active, entityOrigin, currentTime)
  system = compatibilitySystemWithActive(active)
  R_EntityParticles(system, entityOrigin, currentTime, canonicalEntityNormals())
  return finishCompatibility(system)
end function

// Provide rocket trail into behavior for the active subsystem.
function rocketTrailInto(active, start, finish, trailType, currentTime)
  system = compatibilitySystemWithActive(active)
  R_RocketTrail(system, start, finish, trailType, currentTime)
  return finishCompatibility(system)
end function
