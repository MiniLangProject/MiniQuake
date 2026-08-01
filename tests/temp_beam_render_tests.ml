/* BP-037: cl_tent.c beam pool, angles and 30-unit render segmentation. */

import miniquake.protocol_transients as transients
import miniquake.temp_entities as temp
import miniquake.types as t
import miniquake.constants as c
import miniquake.particles as particles
import miniquake.player_move as playerMove
import miniquake.client as client
import miniquake.client_render_handoff as handoff

function yes(value, name)
  if not value then return error(3700, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(3701, name + ": expected false") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(3702, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3703, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function beam(entity, startPosition, endPosition)
  return t.TemporaryEntity(c.TE_LIGHTNING1, startPosition, endPosition, entity)
end function

function testHorizontalAngles()
  angles = handoff.beamAngles(t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0))
  near(angles.x, 0.0, 0.0, "horizontal pitch")
  near(angles.y, 0.0, 0.0, "horizontal yaw")
  return true
end function

function testPositiveYaw()
  angles = handoff.beamAngles(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 30.0, 0.0))
  near(angles.y, 90.0, 0.0, "positive yaw")
  return true
end function

function testNegativeYaw()
  angles = handoff.beamAngles(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, -30.0, 0.0))
  near(angles.y, 270.0, 0.0, "negative yaw")
  return true
end function

function testVerticalUp()
  angles = handoff.beamAngles(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 30.0))
  near(angles.x, 90.0, 0.0, "up pitch")
  return true
end function

function testVerticalDown()
  angles = handoff.beamAngles(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, -30.0))
  near(angles.x, 270.0, 0.0, "down pitch")
  return true
end function

function testZeroLength()
  origins = handoff.beamSegmentOrigins(t.Vec3(1.0, 2.0, 3.0), t.Vec3(1.0, 2.0, 3.0), 64)
  equal(len(origins), 0, "zero length")
  return true
end function

function testOneUnitSegment()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), 64)
  equal(len(origins), 1, "one unit segment")
  return true
end function

function testExactThirty()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0), 64)
  equal(len(origins), 1, "exact thirty")
  return true
end function

function testThirtyOne()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(31.0, 0.0, 0.0), 64)
  equal(len(origins), 2, "thirty one")
  return true
end function

function testSegmentPositions()
  origins = handoff.beamSegmentOrigins(t.Vec3(5.0, 0.0, 0.0), t.Vec3(70.0, 0.0, 0.0), 64)
  equal(len(origins), 3, "segment count")
  near(origins[0].x, 5.0, 0.0, "segment zero")
  near(origins[1].x, 35.0, 0.000001, "segment one")
  near(origins[2].x, 65.0, 0.000001, "segment two")
  return true
end function

function testSegmentLimit()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(1000.0, 0.0, 0.0), 4)
  equal(len(origins), 4, "segment limit")
  return true
end function

function testCompactViewStart()
  value = beam(7, t.Vec3(1.0, 2.0, 3.0), t.Vec3(10.0, 2.0, 3.0))
  start = handoff.compactBeamStart(value, 7, t.Vec3(9.0, 8.0, 7.0))
  near(start.x, 9.0, 0.0, "view start x")
  near(start.z, 7.0, 0.0, "view start z")
  return true
end function

function testNonViewStart()
  value = beam(7, t.Vec3(1.0, 2.0, 3.0), t.Vec3(10.0, 2.0, 3.0))
  start = handoff.compactBeamStart(value, 8, t.Vec3(9.0, 8.0, 7.0))
  near(start.x, 1.0, 0.0, "wire start")
  return true
end function

function testFullStateViewOverride()
  state = temp.CL_InitTEnts(void)
  item = state.beams[0]
  item.entity = 7
  item.model = "progs/bolt.mdl"
  item.endTime = transients.beamEndTime(1.0)
  item.start = t.Vec3(0.0, 0.0, 0.0)
  item.endPosition = t.Vec3(61.0, 0.0, 0.0)
  output = temp.CL_UpdateTEnts(state, 1.0, 7, t.Vec3(1.0, 0.0, 0.0))
  equal(len(output), 2, "view beam segment count")
  near(output[0].origin.x, 1.0, 0.0, "view beam origin")
  return true
end function

function testExpiryEquality()
  yes(transients.beamAlive(transients.beamEndTime(1.0), 1.2), "expiry equality")
  return true
end function

function testStrictExpiry()
  no(transients.beamAlive(transients.beamEndTime(1.0), 1.2001), "strict expiry")
  return true
end function

function testTempEntityCap()
  state = temp.CL_InitTEnts(void)
  item = state.beams[0]
  item.entity = 1
  item.model = "progs/bolt.mdl"
  item.endTime = 2.0
  item.start = t.Vec3(0.0, 0.0, 0.0)
  item.endPosition = t.Vec3(100000.0, 0.0, 0.0)
  output = temp.CL_UpdateTEnts(state, 1.0, -1, t.Vec3(0.0, 0.0, 0.0))
  equal(len(output), c.MAX_TEMP_ENTITIES, "temp entity cap")
  return true
end function

function testSameEntitySlot()
  first = beam(5, t.Vec3(0.0, 0.0, 0.0), t.Vec3(30.0, 0.0, 0.0))
  result = transients.updateCompactBeamListResult([], first, 1.0)
  second = beam(5, t.Vec3(10.0, 0.0, 0.0), t.Vec3(40.0, 0.0, 0.0))
  replaced = transients.updateCompactBeamListResult(result[0], second, 5.0)
  equal(replaced[2], 0, "same entity slot")
  near(replaced[0][0][0].origin.x, 10.0, 0.0, "same entity payload")
  return true
end function


function renderClient()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  value.modelPrecache = [""]
  entity = client.ensureEntity(value, 7)
  entity.origin = t.Vec3(5.0, 0.0, 0.0)
  value.viewEntity = 7
  return value
end function

function activeBeamRecords(type, entity, startPosition, endPosition)
  value = t.TemporaryEntity(type, startPosition, endPosition, entity)
  return transients.updateCompactBeamList([], value, 1.0)
end function

function testModelBeamSegments()
  particles.resetRandom(1)
  value = renderClient()
  records = activeBeamRecords(c.TE_LIGHTNING1, 8, t.Vec3(0.0, 0.0, 0.0), t.Vec3(61.0, 0.0, 0.0))
  output = handoff.buildTemporaryEntities(records, value, 1.0, 0)
  equal(len(output), 3, "model segment count")
  yes(output[0].modelIndex > 0, "model index")
  equal(value.modelPrecache[output[0].modelIndex], "progs/bolt.mdl", "bolt model")
  return true
end function

function testModelBeamViewOrigin()
  particles.resetRandom(1)
  value = renderClient()
  records = activeBeamRecords(c.TE_LIGHTNING2, 7, t.Vec3(0.0, 0.0, 0.0), t.Vec3(36.0, 0.0, 0.0))
  output = handoff.buildTemporaryEntities(records, value, 1.0, 0)
  near(output[0].origin.x, 5.0, 0.0, "view model start")
  equal(value.modelPrecache[output[0].modelIndex], "progs/bolt2.mdl", "bolt2 model")
  return true
end function

function testModelBeamVisibleCap()
  particles.resetRandom(1)
  value = renderClient()
  records = activeBeamRecords(c.TE_LIGHTNING3, 8, t.Vec3(0.0, 0.0, 0.0), t.Vec3(200.0, 0.0, 0.0))
  output = handoff.buildTemporaryEntities(records, value, 1.0, c.MAX_VISEDICTS - 2)
  equal(len(output), 2, "visible cap")
  return true
end function

function testSubmissionOrder()
  value = renderClient()
  visible = [client.createEntity(1), client.createEntity(2)]
  temporary = [client.createEntity(-1), client.createEntity(-2)]
  output = handoff.submitEntities(visible, temporary)
  equal(len(output), 4, "submission count")
  equal(output[0].number, 1, "visible first")
  equal(output[2].number, -1, "temporary appended")
  return true
end function

function main(args)
  tests = [
    ["horizontal angles", testHorizontalAngles],
    ["positive yaw", testPositiveYaw],
    ["negative yaw", testNegativeYaw],
    ["vertical up", testVerticalUp],
    ["vertical down", testVerticalDown],
    ["zero length", testZeroLength],
    ["one-unit segment", testOneUnitSegment],
    ["exact thirty", testExactThirty],
    ["thirty one", testThirtyOne],
    ["segment positions", testSegmentPositions],
    ["segment limit", testSegmentLimit],
    ["view start", testCompactViewStart],
    ["wire start", testNonViewStart],
    ["full state view override", testFullStateViewOverride],
    ["expiry equality", testExpiryEquality],
    ["strict expiry", testStrictExpiry],
    ["temp entity cap", testTempEntityCap],
    ["same entity slot", testSameEntitySlot],
    ["model beam segments", testModelBeamSegments],
    ["model beam view origin", testModelBeamViewOrigin],
    ["model beam visible cap", testModelBeamVisibleCap],
    ["submission order", testSubmissionOrder],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 22 then return 1 end if
  print "MiniQuake BP-037 temporary beam tests passed: 22"
  return 0
end function
