package miniquake.particles

import miniquake.types as t
import miniquake.mathlib as math

const PT_STATIC = 0
const PT_GRAVITY = 1
const PT_SLOW_GRAVITY = 2
const PT_FIRE = 3
const PT_EXPLODE = 4
const PT_EXPLODE2 = 5
const PT_BLOB = 6
const PT_BLOB2 = 7
const MAX_PARTICLES = 4096

ramp1 = [0x6f, 0x6d, 0x6b, 0x69, 0x67, 0x65, 0x63, 0x61]
ramp2 = [0x6f, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x68, 0x66]
ramp3 = [0x6d, 0x6b, 6, 5, 4, 3]

function pseudo(seed, span)
  if span <= 0 then return 0 end if
  value = (seed * 1103515245 + 12345) & 0x7fffffff
  return value % span
end function

function spawn(origin, velocity, dieTime, color, type)
  return t.Particle(math.copy(origin), math.copy(velocity), dieTime, color, 0.0, type)
end function

function appendLimited(target, source)
  result = target
  index = 0
  while index < len(source) and len(result) < MAX_PARTICLES
    result = result + [source[index]]
    index = index + 1
  end while
  return result
end function

function rampColor(values, ramp)
  index = ramp
  if index < 0 then index = 0 end if
  if index >= len(values) then return -1 end if
  return values[index]
end function

function update(particles, currentTime, deltaTime)
  alive = []
  gravity = 800.0
  for each particle in particles
    if particle.die >= currentTime then
      particle.origin = math.multiplyAdd(particle.origin, deltaTime, particle.velocity)
      keep = true
      if particle.type == PT_FIRE then
        particle.ramp = particle.ramp + deltaTime * 5.0
        color = rampColor(ramp3, particle.ramp)
        if color < 0 then keep = false else particle.color = color end if
        particle.velocity.z = particle.velocity.z + gravity * 0.05 * deltaTime
      else if particle.type == PT_EXPLODE then
        particle.ramp = particle.ramp + deltaTime * 10.0
        color = rampColor(ramp1, particle.ramp)
        if color < 0 then keep = false else particle.color = color end if
        particle.velocity = math.scale(particle.velocity, 1.0 + deltaTime * 4.0)
        particle.velocity.z = particle.velocity.z - gravity * deltaTime
      else if particle.type == PT_EXPLODE2 then
        particle.ramp = particle.ramp + deltaTime * 15.0
        color = rampColor(ramp2, particle.ramp)
        if color < 0 then keep = false else particle.color = color end if
        particle.velocity = math.scale(particle.velocity, 1.0 - deltaTime)
        particle.velocity.z = particle.velocity.z - gravity * deltaTime
      else if particle.type == PT_BLOB then
        particle.velocity = math.scale(particle.velocity, 1.0 + deltaTime * 4.0)
        particle.velocity.z = particle.velocity.z - gravity * deltaTime
      else if particle.type == PT_BLOB2 then
        particle.velocity = math.scale(particle.velocity, 1.0 - deltaTime * 4.0)
        particle.velocity.z = particle.velocity.z - gravity * deltaTime
      else if particle.type == PT_GRAVITY then
        particle.velocity.z = particle.velocity.z - gravity * deltaTime
      else if particle.type == PT_SLOW_GRAVITY then
        particle.velocity.z = particle.velocity.z - gravity * 0.05 * deltaTime
      end if
      if keep then alive = alive + [particle] end if
    end if
  end for
  return alive
end function

function runEffect(origin, direction, count, color, dieTime)
  if count == 255 then count = 1024 end if
  if count > MAX_PARTICLES then count = MAX_PARTICLES end if
  result = []
  index = 0
  while index < count
    jitterX = pseudo(index * 3 + color, 16) - 8
    jitterY = pseudo(index * 5 + color, 16) - 8
    jitterZ = pseudo(index * 7 + color, 16) - 8
    position = t.Vec3(origin.x + jitterX, origin.y + jitterY, origin.z + jitterZ)
    velocity = t.Vec3(
      direction.x * 15.0 + jitterX,
      direction.y * 15.0 + jitterY,
      direction.z * 15.0 + jitterZ,
    )
    result = result + [spawn(position, velocity, dieTime + pseudo(index, 6) * 0.1, color + (pseudo(index, 8) & 7), PT_SLOW_GRAVITY)]
    index = index + 1
  end while
  return result
end function

function pointEffect(origin, count, color, dieTime)
  return runEffect(origin, t.Vec3(0.0, 0.0, 0.0), count, color, dieTime)
end function

function explosion(origin, currentTime)
  result = []
  index = 0
  while index < 1024 and len(result) < MAX_PARTICLES
    position = t.Vec3(
      origin.x + pseudo(index * 11, 32) - 16,
      origin.y + pseudo(index * 13, 32) - 16,
      origin.z + pseudo(index * 17, 32) - 16,
    )
    velocity = t.Vec3(
      pseudo(index * 19, 512) - 256,
      pseudo(index * 23, 512) - 256,
      pseudo(index * 29, 512) - 256,
    )
    type = PT_EXPLODE
    if (index & 1) == 0 then type = PT_EXPLODE2 end if
    particle = spawn(position, velocity, currentTime + 5.0, ramp1[0], type)
    particle.ramp = pseudo(index, 4)
    result = result + [particle]
    index = index + 1
  end while
  return result
end function

function explosion2(origin, colorStart, colorLength, currentTime)
  if colorLength <= 0 then colorLength = 1 end if
  result = []
  index = 0
  while index < 512 and len(result) < MAX_PARTICLES
    position = t.Vec3(origin.x + pseudo(index * 7, 32) - 16, origin.y + pseudo(index * 11, 32) - 16, origin.z + pseudo(index * 13, 32) - 16)
    velocity = t.Vec3(pseudo(index * 17, 512) - 256, pseudo(index * 19, 512) - 256, pseudo(index * 23, 512) - 256)
    result = result + [spawn(position, velocity, currentTime + 0.3, colorStart + (index % colorLength), PT_BLOB)]
    index = index + 1
  end while
  return result
end function

function blobExplosion(origin, currentTime)
  result = []
  index = 0
  while index < 1024 and len(result) < MAX_PARTICLES
    position = t.Vec3(origin.x + pseudo(index * 7, 32) - 16, origin.y + pseudo(index * 11, 32) - 16, origin.z + pseudo(index * 13, 32) - 16)
    velocity = t.Vec3(pseudo(index * 17, 512) - 256, pseudo(index * 19, 512) - 256, pseudo(index * 23, 512) - 256)
    type = PT_BLOB
    color = 66 + pseudo(index, 6)
    if (index & 1) == 0 then type = PT_BLOB2; color = 150 + pseudo(index, 6) end if
    result = result + [spawn(position, velocity, currentTime + 1.0 + pseudo(index, 9) * 0.05, color, type)]
    index = index + 1
  end while
  return result
end function

function lavaSplash(origin, currentTime)
  result = []
  i = -16
  seed = 0
  while i < 16 and len(result) < MAX_PARTICLES
    j = -16
    while j < 16 and len(result) < MAX_PARTICLES
      direction = math.normalize(t.Vec3(j * 8.0, i * 8.0, 256.0))
      speed = 50.0 + pseudo(seed, 64)
      position = t.Vec3(origin.x + i + pseudo(seed + 1, 8), origin.y + j + pseudo(seed + 2, 8), origin.z + pseudo(seed + 3, 64))
      result = result + [spawn(position, math.scale(direction, speed), currentTime + 2.0 + pseudo(seed + 4, 32) * 0.02, 224 + pseudo(seed + 5, 8), PT_SLOW_GRAVITY)]
      seed = seed + 1
      j = j + 1
    end while
    i = i + 1
  end while
  return result
end function

function teleportSplash(origin, currentTime)
  result = []
  i = -16
  seed = 0
  while i < 16 and len(result) < MAX_PARTICLES
    j = -16
    while j < 16 and len(result) < MAX_PARTICLES
      k = -24
      while k < 32 and len(result) < MAX_PARTICLES
        direction = math.normalize(t.Vec3(j * 8.0, i * 8.0, k * 8.0))
        position = t.Vec3(origin.x + i + pseudo(seed, 4), origin.y + j + pseudo(seed + 1, 4), origin.z + k + pseudo(seed + 2, 4))
        result = result + [spawn(position, math.scale(direction, 50.0 + pseudo(seed + 3, 64)), currentTime + 0.2 + pseudo(seed + 4, 8) * 0.02, 7 + pseudo(seed + 5, 8), PT_SLOW_GRAVITY)]
        seed = seed + 1
        k = k + 4
      end while
      j = j + 4
    end while
    i = i + 4
  end while
  return result
end function
