/*
MiniLang side of the pinned WinQuake/r_part.c differential oracle.
*/

import miniquake.particles as particles
import miniquake.types as t
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native
import std.string as string

function jsonNumber(value)
  integerValue = native.trunc(value)
  difference = value - integerValue
  if difference < 0.0 then difference = -difference end if
  if difference < 0.000001 then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function emitValues(scene, functionName, values)
  arguments = "["
  index = 0
  while index < len(values)
    if index > 0 then arguments = arguments + "," end if
    arguments = arguments + jsonNumber(values[index])
    index = index + 1
  end while
  arguments = arguments + "]"
  print "{\"schema\":\"miniquake.r_part.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":0,\"op\":\"state\",\"args\":" + arguments + "}"
end function

function emit(scene, functionName, system, randomCalls, glCalls, vertices, a, b, freeOverride)
  activeCount = len(system.active)
  freeCount = system.capacity - activeCount
  if freeOverride >= 0 then freeCount = freeOverride end if
  headColor = -1
  headType = -1
  tailColor = -1
  tailType = -1
  tailDie = -1.0
  tailOrigin = t.Vec3(0.0, 0.0, 0.0)
  tailVelocity = t.Vec3(0.0, 0.0, 0.0)
  if activeCount > 0 then
    head = system.active[0]
    tail = system.active[activeCount - 1]
    headColor = head.color
    headType = head.type
    tailColor = tail.color
    tailType = tail.type
    tailDie = tail.die
    tailOrigin = tail.origin
    tailVelocity = tail.velocity
  end if
  emitValues(
    scene, functionName,
    [
      activeCount, freeCount, randomCalls, glCalls, vertices,
      headColor, headType, tailColor, tailType, tailDie,
      tailOrigin.x, tailOrigin.y, tailOrigin.z,
      tailVelocity.x, tailVelocity.y, tailVelocity.z, a, b,
    ],
  )
end function

function traceInit()
  system = particles.R_InitParticles(["quake", "-particles", "128"])
  emit("rpart_init", "R_InitParticles", system, 0, 0, 0, system.capacity, 1, 0)
end function

function traceEntity()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  normals = []
  index = 0
  while index < 162
    if index % 3 == 0 then normals = normals + [t.Vec3(1.0, 0.0, 0.0)]
    else if index % 3 == 1 then normals = normals + [t.Vec3(0.0, 1.0, 0.0)]
    else normals = normals + [t.Vec3(0.0, 0.0, 1.0)]
    end if
    index = index + 1
  end while
  particles.R_EntityParticles(system, t.Vec3(1.0, 2.0, 3.0), 2.0, normals)
  emit("rpart_entity", "R_EntityParticles", system, 486, 0, 0, 0, 0, -1)
end function

function traceClear()
  system = particles.createSystem(2048)
  particles.R_RunParticleEffect(
    system, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), 40, 2, 2.0
  )
  particles.R_SetRandomSeed(system, 1)
  particles.R_ClearParticles(system)
  emit("rpart_clear", "R_ClearParticles", system, 0, 0, 0, 0, 0, -1)
end function

function tracePointFile()
  system = particles.createSystem(2048)
  particles.R_ReadPointFile_f(system, "1 2 3\n-4.5 6 7\n")
  emit("rpart_point_file", "R_ReadPointFile_f", system, 0, 0, 0, 0, 0, -1)
end function

function traceParse()
  buffer = sz.alloc(32)
  msg.writeCoord(buffer, 1.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeCoord(buffer, 3.0)
  msg.writeChar(buffer, 16)
  msg.writeChar(buffer, -16)
  msg.writeChar(buffer, 0)
  msg.writeByte(buffer, 4)
  msg.writeByte(buffer, 40)
  reader = msg.beginReading(buffer)
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_ParseParticleEffect(system, reader, 2.0)
  emit("rpart_parse", "R_ParseParticleEffect", system, 20, 0, 0, 3, 2, -1)
end function

function traceExplosion()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_ParticleExplosion(system, t.Vec3(0.0, 0.0, 0.0), 2.0)
  emit("rpart_explosion", "R_ParticleExplosion", system, 7168, 0, 0, 0, 0, -1)
end function

function traceExplosion2()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_ParticleExplosion2(system, t.Vec3(0.0, 0.0, 0.0), 120, 3, 2.0)
  emit("rpart_explosion2", "R_ParticleExplosion2", system, 3072, 0, 0, 0, 0, -1)
end function

function traceBlob()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_BlobExplosion(system, t.Vec3(0.0, 0.0, 0.0), 2.0)
  emit("rpart_blob", "R_BlobExplosion", system, 8192, 0, 0, 0, 0, -1)
end function

function traceRunEffect()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_RunParticleEffect(
    system, t.Vec3(1.0, 2.0, 3.0), t.Vec3(1.0, -1.0, 0.0), 40, 4, 2.0
  )
  emit("rpart_run_effect", "R_RunParticleEffect", system, 20, 0, 0, 0, 0, -1)
end function

function traceLava()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_LavaSplash(system, t.Vec3(10.0, 20.0, 30.0), 2.0)
  emit("rpart_lava", "R_LavaSplash", system, 6144, 0, 0, 0, 0, -1)
end function

function traceTeleport()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  particles.R_TeleportSplash(system, t.Vec3(0.0, 0.0, 0.0), 2.0)
  emit("rpart_teleport", "R_TeleportSplash", system, 5376, 0, 0, 0, 0, -1)
end function

function traceRocket()
  system = particles.createSystem(2048)
  particles.R_SetRandomSeed(system, 1)
  start = t.Vec3(0.0, 0.0, 0.0)
  particles.R_RocketTrail(system, start, t.Vec3(10.0, 0.0, 0.0), 0, 2.0)
  emit("rpart_rocket", "R_RocketTrail", system, 16, 0, 0, start.x, start.y, -1)
end function

function traceDraw()
  system = particles.createSystem(2048)
  alive = particles.R_AllocParticle(system)
  alive.origin = t.Vec3(100.0, 0.0, 0.0)
  alive.velocity = t.Vec3(0.0, 0.0, 10.0)
  alive.die = 10.0
  alive.color = 5
  alive.type = particles.PT_BLOB2
  expired = particles.R_AllocParticle(system)
  expired.die = 0.0
  trace = particles.R_DrawParticles(
    system, 1.0, 0.9, 800.0,
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0), t.Vec3(0.0, -1.0, 0.0),
  )
  glCalls = 4 + (len(trace) - 7) * 7 + 3
  vertices = (len(trace) - 7) * 3
  emit("rpart_draw", "R_DrawParticles", system, 0, glCalls, vertices, alive.origin.z, alive.velocity.z, -1)
end function

function main(args)
  traceInit()
  traceEntity()
  traceClear()
  tracePointFile()
  traceParse()
  traceExplosion()
  traceExplosion2()
  traceBlob()
  traceRunEffect()
  traceLava()
  traceTeleport()
  traceRocket()
  traceDraw()
  return 0
end function
