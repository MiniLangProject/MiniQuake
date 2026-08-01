/* BP-039: client/view/transient/particle/refrag closure contract. */

import miniquake.render.gl_refrag as refrag
import miniquake.render.entities as entityRenderer
import miniquake.client_render_contract as contract
import miniquake.client_render_handoff as handoff
import miniquake.client as client
import miniquake.player_move as playerMove
import miniquake.protocol_transients as transients
import miniquake.particles as particles
import miniquake.view as view
import miniquake.types as t
import miniquake.constants as c

function yes(value, name)
  if not value then return error(3900, name + ": expected true") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(3901, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3902, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function makeEntity(number, modelIndex)
  zero = t.Vec3(0.0, 0.0, 0.0)
  return t.ClientEntityState(number, modelIndex, 0, 0, 0, 0, zero, zero, 0.0, zero, zero, zero, zero, false, void, 0.0)
end function

function setup()
  zero = t.Vec3(0.0, 0.0, 0.0)
  minimum = t.Vec3(-64.0, -64.0, -64.0)
  maximum = t.Vec3(64.0, 64.0, 64.0)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -1, -2, minimum, maximum, 0, 0)
  leaf0 = t.BspLeaf(c.CONTENTS_EMPTY, -1, minimum, maximum, 0, 0, bytes(4))
  leaf1 = t.BspLeaf(c.CONTENTS_EMPTY, -1, minimum, maximum, 0, 0, bytes(4))
  worldModel = t.BspModel(minimum, maximum, zero, [0, 0, 0, 0], 2, 0, 0)
  submodel = t.BspModel(t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0), zero, [0, 0, 0, 0], 0, 0, 0)
  map = t.BspMap("closure.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [], bytes(), [node], [], [], bytes(), [], [leaf0, leaf1], [], [], [], [worldModel, submodel])
  renderer = t.WorldRenderer(map, bytes(), [], [], [], true, 0, false, false, 0, bytes(), 0, 1.0)
  noneModel = t.ClientRenderModel("", entityRenderer.MODEL_NONE, void, void, [], false)
  brushModel = t.ClientRenderModel("*1", entityRenderer.MODEL_BRUSH, void, void, [], false)
  entities = [makeEntity(0, 1), makeEntity(1, 1), makeEntity(2, 0)]
  modelRenderer = t.EntityRenderer(void, bytes(), [noneModel, brushModel], 0)
  refrag.Configure(renderer, modelRenderer, entities)
  return entities
end function

function split(entity, minimum, maximum)
  refrag.SetSplitState(entity, minimum, maximum)
  return refrag.R_SplitEntityOnNode(0)
end function

function testStatus()
  yes(contract.status() == "client_render_109_frozen_v1", "contract status")
  return true
end function

function testFingerprint()
  equal(contract.fingerprint(), 0x95e2b295, "contract fingerprint")
  return true
end function

function testLimits()
  equal(contract.maxVisibleEntities(), c.MAX_VISEDICTS, "visible limit")
  equal(contract.maxTemporaryEntities(), c.MAX_TEMP_ENTITIES, "temporary limit")
  return true
end function

function testConfigureEmpty()
  setup()
  equal(len(refrag.R_VisibleEntities()), 0, "configured visible list")
  return true
end function

function testPositiveLeaf()
  entities = setup()
  equal(split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0)), 1, "positive split")
  state = refrag.GetState(0)
  equal(state[2][0], 1, "positive leaf count")
  return true
end function

function testNegativeLeaf()
  entities = setup()
  equal(split(entities[0], t.Vec3(-2.0, 0.0, 0.0), t.Vec3(-1.0, 1.0, 1.0)), 1, "negative split")
  state = refrag.GetState(0)
  equal(state[2][1], 1, "negative leaf count")
  return true
end function

function testMixedLeaves()
  entities = setup()
  equal(split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0)), 2, "mixed split")
  return true
end function

function testBeginVisibleFrame()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_StoreEfrags(0)
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_VisibleEntities()), 0, "begin clears visible")
  return true
end function

function testAccumulateLeaves()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  split(entities[1], t.Vec3(-2.0, 0.0, 0.0), t.Vec3(-1.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_StoreEfrags(0)), 1, "first leaf")
  equal(len(refrag.R_StoreEfrags(1)), 2, "second leaf accumulates")
  return true
end function

function testDeduplicateLeaves()
  entities = setup()
  split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  refrag.R_StoreEfrags(0)
  equal(len(refrag.R_StoreEfrags(1)), 1, "deduplicated entity")
  return true
end function

function testRemoveEfrags()
  entities = setup()
  split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  yes(refrag.R_RemoveEfrags(entities[0]), "remove efrags")
  state = refrag.GetState(0)
  equal(state[0], 0, "entity efrags removed")
  equal(state[2][0] + state[2][1], 0, "leaf efrags removed")
  return true
end function

function testInvalidLeafNoChange()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  refrag.R_StoreEfrags(0)
  equal(len(refrag.R_StoreEfrags(99)), 1, "invalid leaf retains frame")
  return true
end function

function testInvalidModelFiltered()
  entities = setup()
  split(entities[2], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_StoreEfrags(0)), 0, "invalid model hidden")
  return true
end function

function testClientActiveView()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  valid = client.createEntity(1); valid.modelIndex = 1
  stale = client.createEntity(2); stale.modelIndex = 0
  value.visibleEntities = [valid, stale, void]
  equal(len(client.CL_ActiveVisibleEntities(value)), 1, "active client view")
  return true
end function

function testClientRemovalView()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  stale = client.ensureEntity(value, 1)
  stale.modelIndex = 0
  stale.forceLink = true
  equal(len(client.CL_EfragRemovalCandidates(value)), 1, "client removal handoff")
  return true
end function

function testBeamSegmentContract()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(61.0, 0.0, 0.0), c.MAX_TEMP_ENTITIES)
  equal(len(origins), 3, "beam 30-unit segmentation")
  return true
end function

function testParticleGravityContract()
  particle = particles.spawn(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 10.0), 2.0, 0, particles.PT_GRAVITY)
  updated = particles.updateWithGravity([particle], 1.0, 0.1, 400.0)
  near(updated[0].velocity.z, 8.0, 0.000001, "particle gravity handoff")
  return true
end function

function testViewCshiftContract()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "1.9", "2", "3", "4"])
  equal(state.emptyCshift[0], 1.0, "view atoi contract")
  return true
end function

function testStoreOrder()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  split(entities[1], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  visible = refrag.R_StoreEfrags(0)
  equal(len(visible), 2, "store order count")
  equal(visible[0].number, 1, "leaf head insertion order")
  equal(visible[1].number, 0, "leaf tail order")
  return true
end function

function testFrameRestartAllowsEntityAgain()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame(); equal(len(refrag.R_StoreEfrags(0)), 1, "first frame")
  refrag.R_BeginVisibleFrame(); equal(len(refrag.R_StoreEfrags(0)), 1, "second frame")
  return true
end function

function testCapConstantPositive()
  yes(contract.maxVisibleEntities() > 0 and contract.maxTemporaryEntities() > 0, "positive limits")
  return true
end function


function testBeamModelNames()
  equal(handoff.beamModelName(c.TE_LIGHTNING1), "progs/bolt.mdl", "lightning1 model")
  equal(handoff.beamModelName(c.TE_LIGHTNING3), "progs/bolt3.mdl", "lightning3 model")
  equal(handoff.beamModelName(c.TE_BEAM), "progs/beam.mdl", "beam model")
  return true
end function

function testTemporarySubmissionCap()
  visible = []
  index = 0
  while index < c.MAX_VISEDICTS
    visible = visible + [makeEntity(index, 1)]
    index = index + 1
  end while
  output = handoff.submitEntities(visible, [makeEntity(-1, 1)])
  equal(len(output), c.MAX_VISEDICTS, "submission cap")
  return true
end function

function testRenderSubmittedSymbol()
  // Function values are first-class; this binds the prefiltered renderer API.
  fn = entityRenderer.renderSubmitted
  yes(typeof(fn) == "function", "renderSubmitted function")
  return true
end function

function testContractFeatureBits()
  equal(contract.BEAM_MODEL_HANDOFF, 1, "beam handoff")
  equal(contract.CHASE_REFDEF_PRESERVATION, 1, "chase refdef")
  equal(contract.EFRAG_FRAME_ACCUMULATION, 1, "efrag accumulate")
  equal(contract.PARTICLE_FLOAT_STORAGE, 1, "particle floats")
  return true
end function

function main(args)
  tests = [
    ["contract status", testStatus],
    ["contract fingerprint", testFingerprint],
    ["contract limits", testLimits],
    ["configure empty", testConfigureEmpty],
    ["positive leaf", testPositiveLeaf],
    ["negative leaf", testNegativeLeaf],
    ["mixed leaves", testMixedLeaves],
    ["begin visible frame", testBeginVisibleFrame],
    ["accumulate leaves", testAccumulateLeaves],
    ["deduplicate leaves", testDeduplicateLeaves],
    ["remove efrags", testRemoveEfrags],
    ["invalid leaf", testInvalidLeafNoChange],
    ["invalid model", testInvalidModelFiltered],
    ["client active view", testClientActiveView],
    ["client removal view", testClientRemovalView],
    ["beam contract", testBeamSegmentContract],
    ["particle gravity", testParticleGravityContract],
    ["view cshift", testViewCshiftContract],
    ["store order", testStoreOrder],
    ["frame restart", testFrameRestartAllowsEntityAgain],
    ["beam model names", testBeamModelNames],
    ["temporary submission cap", testTemporarySubmissionCap],
    ["render submitted symbol", testRenderSubmittedSymbol],
    ["contract feature bits", testContractFeatureBits],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 24 then return 1 end if
  print "MiniQuake BP-039 client/render closure tests passed: 24"
  return 0
end function
