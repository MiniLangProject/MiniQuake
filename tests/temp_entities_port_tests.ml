/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused cl_tent.c protocol, beam and effect fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.temp_entities as tent
import miniquake.sizebuf as sz
import miniquake.message as msg

// Assert that the condition holds and identify a failing test.
function tentRequire(value, message)
  if not value then return error(9980, message) end if
  return true
end function

// Encode and write position.
function writePosition(buffer, value)
  msg.writeCoord(buffer, value.x)
  msg.writeCoord(buffer, value.y)
  msg.writeCoord(buffer, value.z)
end function

// Exercise point message as part of this deterministic regression fixture.
function pointMessage(type, position)
  buffer = sz.alloc(64)
  msg.writeByte(buffer, type)
  writePosition(buffer, position)
  return buffer
end function

// Exercise beam message as part of this deterministic regression fixture.
function beamMessage(type, entity, start, finish)
  buffer = sz.alloc(64)
  msg.writeByte(buffer, type)
  msg.writeShort(buffer, entity)
  writePosition(buffer, start)
  writePosition(buffer, finish)
  return buffer
end function

// Read and validate buffer.
function parseBuffer(state, buffer, currentTime)
  return tent.CL_ParseTEnt(state, msg.beginReading(buffer), currentTime)
end function

// Report whether active beam count holds for the active state.
function activeBeamCount(state)
  count = 0
  for each beam in state.beams
    if beam.model != "" then count = count + 1 end if
  end for
  return count
end function

// Verify precache parse and effects against the expected Quake behavior.
function testPrecacheParseAndEffects()
  state = tent.CL_InitTEnts(void)
  tentRequire(len(state.precachedSounds) == 7, "seven stock sounds")
  tentRequire(state.precachedSounds[0] == "wizard/hit.wav", "wizard precache")
  tentRequire(state.precachedSounds[6] == "weapons/r_exp3.wav", "explosion precache")
  tentRequire(len(state.beams) == 24, "fixed beam pool")
  tentRequire(len(state.dynamicLights) == c.MAX_DLIGHTS, "fixed dlight pool")

  position = t.Vec3(8.0, -16.0, 24.0)
  value = parseBuffer(state, pointMessage(c.TE_WIZSPIKE, position), 1.0)
  tentRequire(value.type == c.TE_WIZSPIKE, "wizard type")
  tentRequire(len(state.particleEvents) == 1, "wizard particle event")
  tentRequire(state.particleEvents[0][0] == "R_RunParticleEffect", "wizard particle function")
  tentRequire(state.particleEvents[0][2] == 20 and state.particleEvents[0][3] == 30, "wizard particle args")
  tentRequire(state.soundEvents[0][2] == "wizard/hit.wav", "wizard sound")

  value = parseBuffer(state, pointMessage(c.TE_EXPLOSION, position), 2.0)
  tentRequire(value.type == c.TE_EXPLOSION, "explosion type")
  tentRequire(state.particleEvents[1][0] == "R_ParticleExplosion", "explosion particles")
  tentRequire(state.dynamicLights[0].radius == 350.0, "explosion radius")
  tentRequire(state.dynamicLights[0].die == 2.5, "explosion lifetime")
  tentRequire(state.dynamicLights[0].decay == 300.0, "explosion decay")
  tentRequire(state.soundEvents[1][2] == "weapons/r_exp3.wav", "explosion sound")

  colored = pointMessage(c.TE_EXPLOSION2, position)
  msg.writeByte(colored, 40)
  msg.writeByte(colored, 8)
  value = parseBuffer(state, colored, 3.0)
  tentRequire((value.entity >> 8) == 40 and (value.entity & 255) == 8, "explosion2 colors")
  tentRequire(state.particleEvents[2][0] == "R_ParticleExplosion2", "explosion2 function")
  tentRequire(state.particleEvents[2][2] == 40 and state.particleEvents[2][3] == 8, "explosion2 args")

  tent.CL_SetRandomSeed(state, 1)
  value = parseBuffer(state, pointMessage(c.TE_SPIKE, position), 4.0)
  tentRequire(value.type == c.TE_SPIKE, "spike type")
  tentRequire(state.particleEvents[3][3] == 10, "spike particle count")
  tentRequire(state.soundEvents[3][2] == "weapons/tink1.wav", "deterministic spike sound")

  bad = sz.alloc(8)
  msg.writeByte(bad, 255)
  rejected = try(parseBuffer(state, bad, 4.0))
  tentRequire(rejected is error, "bad temp entity type")
  return true
end function

// Verify beam allocation override and overflow against the expected Quake behavior.
function testBeamAllocationOverrideAndOverflow()
  state = tent.CL_InitTEnts(void)
  first = beamMessage(c.TE_LIGHTNING1, 7, t.Vec3(1.0, 2.0, 3.0), t.Vec3(61.0, 2.0, 3.0))
  value = parseBuffer(state, first, 10.0)
  tentRequire(value.entity == 7, "beam entity")
  tentRequire(state.beams[0].model == "progs/bolt.mdl", "lightning1 model")
  tentRequire(state.beams[0].endTime == 10.2, "beam lifetime")
  tentRequire(len(state.precachedModels) == 1, "model loaded on parse")

  replacement = beamMessage(c.TE_LIGHTNING2, 7, t.Vec3(4.0, 5.0, 6.0), t.Vec3(64.0, 5.0, 6.0))
  parseBuffer(state, replacement, 10.1)
  tentRequire(activeBeamCount(state) == 1, "same entity overrides beam")
  tentRequire(state.beams[0].model == "progs/bolt2.mdl", "override model")
  tentRequire(state.beams[0].start.x == 4.0, "override start")
  tentRequire(len(state.precachedModels) == 2, "second model loaded")

  entity = 100
  while entity < 123
    parseBuffer(state, beamMessage(c.TE_BEAM, entity, t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0)), 10.1)
    entity = entity + 1
  end while
  tentRequire(activeBeamCount(state) == 24, "beam pool full")
  parseBuffer(state, beamMessage(c.TE_LIGHTNING3, 999, t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0)), 10.1)
  tentRequire(len(state.diagnostics) == 1 and state.diagnostics[0] == "beam list overflow!", "beam overflow diagnostic")

  // At equality a beam remains occupied; strictly later time can reuse it.
  parseBuffer(state, beamMessage(c.TE_LIGHTNING3, 998, t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0)), 10.31)
  tentRequire(activeBeamCount(state) == 24, "expired slot reused")
  found = false
  for each beam in state.beams
    if beam.entity == 998 and beam.model == "progs/bolt3.mdl" then found = true end if
  end for
  tentRequire(found, "replacement occupies expired slot")
  return true
end function

// Verify beam update segments and limits against the expected Quake behavior.
function testBeamUpdateSegmentsAndLimits()
  state = tent.CL_InitTEnts(void)
  parseBuffer(
    state,
    beamMessage(c.TE_LIGHTNING1, 1, t.Vec3(0.0, 0.0, 0.0), t.Vec3(95.0, 0.0, 0.0)),
    0.0,
  )
  entities = tent.CL_UpdateTEnts(state, 0.1, 1, t.Vec3(5.0, 0.0, 0.0))
  tentRequire(len(entities) == 3, "one model every 30 units")
  tentRequire(entities[0].origin.x == 5.0, "view beam start follows player")
  tentRequire(entities[1].origin.x == 35.0 and entities[2].origin.x == 65.0, "beam segment spacing")
  tentRequire(entities[0].model == "progs/bolt.mdl", "segment model")
  tentRequire(entities[0].angles.x == 0.0 and entities[0].angles.y == 0.0, "horizontal beam angles")
  tentRequire(len(tent.CL_UpdateTEnts(state, 0.21, 1, t.Vec3(5.0, 0.0, 0.0))) == 0, "beam expiration")

  capped = tent.CL_InitTEnts(void)
  parseBuffer(
    capped,
    beamMessage(c.TE_LIGHTNING3, 2, t.Vec3(0.0, 0.0, 0.0), t.Vec3(3000.0, 0.0, 0.0)),
    0.0,
  )
  entities = tent.CL_UpdateTEnts(capped, 0.1, 0, t.Vec3(0.0, 0.0, 0.0))
  tentRequire(len(entities) == c.MAX_TEMP_ENTITIES, "temp entity pool cap")
  tentRequire(tent.CL_NewTempEntity(capped) is void, "temp allocation exhausted")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/3] precache, parse and effects"
  result = try(testPrecacheParseAndEffects())
  if result is error then print "precache/parse/effects failed"; return 1 end if
  print "[2/3] beam allocation, override and overflow"
  result = try(testBeamAllocationOverrideAndOverflow())
  if result is error then print "beam allocation failed"; return 1 end if
  print "[3/3] beam update segments and limits"
  result = try(testBeamUpdateSegmentsAndLimits())
  if result is error then print "beam update failed"; return 1 end if
  print "CL_TENT PORT TESTS PASSED (3/3)"
  return 0
end function
