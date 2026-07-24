import miniquake.types as t
import miniquake.constants as c
import miniquake.temp_entities as tent
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function modelMarker(model)
  if model == "progs/bolt.mdl" then return 1 end if
  if model == "progs/bolt2.mdl" then return 2 end if
  if model == "progs/bolt3.mdl" then return 3 end if
  return 4
end function

function soundMarker(name)
  if name == "wizard/hit.wav" then return 1 end if
  if name == "hknight/hit.wav" then return 2 end if
  if name == "weapons/tink1.wav" then return 3 end if
  if name == "weapons/ric1.wav" then return 4 end if
  if name == "weapons/ric2.wav" then return 5 end if
  if name == "weapons/ric3.wav" then return 6 end if
  if name == "weapons/r_exp3.wav" then return 7 end if
  return 0
end function

function beamReader(entity, start, finish)
  buffer = sz.alloc(64)
  msg.writeShort(buffer, entity)
  msg.writeCoord(buffer, start.x)
  msg.writeCoord(buffer, start.y)
  msg.writeCoord(buffer, start.z)
  msg.writeCoord(buffer, finish.x)
  msg.writeCoord(buffer, finish.y)
  msg.writeCoord(buffer, finish.z)
  return msg.beginReading(buffer)
end function

function activeBeamCount(state)
  count = 0
  for each beam in state.beams
    if beam.model != "" then count = count + 1 end if
  end for
  return count
end function

function main(args)
  initialized = tent.CL_InitTEnts(void)
  print "{\"function\":\"CL_InitTEnts\",\"case\":\"stock_precache\",\"sounds\":" + len(initialized.precachedSounds) + ",\"first_ok\":" + boolText(initialized.precachedSounds[0] == "wizard/hit.wav") + ",\"last_ok\":" + boolText(initialized.precachedSounds[6] == "weapons/r_exp3.wav") + "}"

  beamState = tent.CL_InitTEnts(void)
  firstReader = beamReader(7, t.Vec3(1.0, 2.0, 3.0), t.Vec3(61.0, 2.0, 3.0))
  tent.CL_ParseBeam(beamState, firstReader, "progs/bolt.mdl", 10.0)
  replacementReader = beamReader(7, t.Vec3(4.0, 5.0, 6.0), t.Vec3(64.0, 5.0, 6.0))
  tent.CL_ParseBeam(beamState, replacementReader, "progs/bolt2.mdl", 10.1)
  beam = beamState.beams[0]
  print "{\"function\":\"CL_ParseBeam\",\"case\":\"allocate_override\",\"entity\":" + beam.entity + ",\"model\":" + modelMarker(beam.model) + ",\"end_time\":" + beam.endTime + ",\"start\":[" + beam.start.x + "," + beam.start.y + "," + beam.start.z + "],\"end\":[" + beam.endPosition.x + "," + beam.endPosition.y + "," + beam.endPosition.z + "],\"active\":" + activeBeamCount(beamState) + ",\"bytes_read\":" + replacementReader.readCount + "}"

  effectState = tent.CL_InitTEnts(void)
  effectBuffer = sz.alloc(32)
  msg.writeByte(effectBuffer, c.TE_EXPLOSION2)
  msg.writeCoord(effectBuffer, 8.0)
  msg.writeCoord(effectBuffer, -16.0)
  msg.writeCoord(effectBuffer, 24.0)
  msg.writeByte(effectBuffer, 40)
  msg.writeByte(effectBuffer, 8)
  effectReader = msg.beginReading(effectBuffer)
  tent.CL_ParseTEnt(effectState, effectReader, 3.0)
  particle = effectState.particleEvents[0]
  soundEvent = effectState.soundEvents[0]
  light = effectState.dynamicLights[0]
  print "{\"function\":\"CL_ParseTEnt\",\"case\":\"explosion2\",\"particles\":" + len(effectState.particleEvents) + ",\"color_start\":" + particle[2] + ",\"color_length\":" + particle[3] + ",\"sound\":" + soundMarker(soundEvent[2]) + ",\"light_radius\":" + native.trunc(light.radius) + ",\"light_die\":" + light.die + ",\"light_decay\":" + native.trunc(light.decay) + ",\"origin\":[" + native.trunc(light.origin.x) + "," + native.trunc(light.origin.y) + "," + native.trunc(light.origin.z) + "],\"bytes_read\":" + effectReader.readCount + "}"

  allocationState = tent.CL_InitTEnts(void)
  created = tent.CL_NewTempEntity(allocationState)
  allocationState.numTempEntities = c.MAX_TEMP_ENTITIES
  overflow = tent.CL_NewTempEntity(allocationState)
  print "{\"function\":\"CL_NewTempEntity\",\"case\":\"allocate_and_cap\",\"created\":" + boolText(created is not void) + ",\"temp_count\":1,\"visible_count\":1,\"colormap\":" + boolText(created.colormap == allocationState.colormap) + ",\"cap_returns_null\":" + boolText(overflow is void) + "}"

  updateState = tent.CL_InitTEnts(void)
  updateBeam = updateState.beams[0]
  updateBeam.entity = 1
  updateBeam.model = "progs/bolt.mdl"
  updateBeam.endTime = 0.2
  updateBeam.start = t.Vec3(0.0, 0.0, 0.0)
  updateBeam.endPosition = t.Vec3(95.0, 0.0, 0.0)
  segments = tent.CL_UpdateTEnts(updateState, 0.1, 1, t.Vec3(5.0, 0.0, 0.0))
  print "{\"function\":\"CL_UpdateTEnts\",\"case\":\"player_beam_segments\",\"segments\":" + len(segments) + ",\"origins\":[" + native.trunc(segments[0].origin.x) + "," + native.trunc(segments[1].origin.x) + "," + native.trunc(segments[2].origin.x) + "],\"model\":" + modelMarker(segments[0].model) + ",\"pitch\":" + native.trunc(segments[0].angles.x) + ",\"yaw\":" + native.trunc(segments[0].angles.y) + ",\"visible\":" + len(updateState.visibleEntities) + "}"
  return 0
end function
