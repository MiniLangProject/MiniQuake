/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-039: client/view/transient/particle/refrag closure contract.
*/
import miniquake.render.gl_refrag as refrag
import miniquake.render.entities as entityRenderer
import miniquake.client_render_contract as contract
import miniquake.client_render_handoff as handoff
import miniquake.client as client
import miniquake.edict as edict
import miniquake.physics as physics
import miniquake.player_move as playerMove
import miniquake.protocol_transients as transients
import miniquake.particles as particles
import miniquake.view as view
import miniquake.types as t
import miniquake.constants as c

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3900, name + ": expected true") end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3901, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3902, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/30] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Create and initialize entity.
function makeEntity(number, modelIndex)
  zero = t.Vec3(0.0, 0.0, 0.0)
  return t.ClientEntityState(number, modelIndex, 0, 0, 0, 0, zero, zero, 0.0, zero, zero, zero, zero, false, void, 0.0)
end function

// Exercise setup as part of this deterministic regression fixture.
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
  noneModel = t.ClientRenderModel("", entityRenderer.MODEL_NONE, void, void, void, [], false)
  brushModel = t.ClientRenderModel("*1", entityRenderer.MODEL_BRUSH, void, void, void, [], false)
  entities = [makeEntity(0, 1), makeEntity(1, 1), makeEntity(2, 0)]
  modelRenderer = t.EntityRenderer(void, bytes(), [noneModel, brushModel], 0)
  refrag.Configure(renderer, modelRenderer, entities)
  return entities
end function

// Convert the requested value into its canonical representation.
function split(entity, minimum, maximum)
  refrag.SetSplitState(entity, minimum, maximum)
  return refrag.R_SplitEntityOnNode(0)
end function

// Verify status against the expected Quake behavior.
function testStatus()
  yes(contract.status() == "client_render_109_frozen_v1", "contract status")
  return true
end function

// Verify fingerprint against the expected Quake behavior.
function testFingerprint()
  equal(contract.fingerprint(), 0x95e2b295, "contract fingerprint")
  return true
end function

// Verify limits against the expected Quake behavior.
function testLimits()
  equal(contract.maxVisibleEntities(), c.MAX_VISEDICTS, "visible limit")
  equal(contract.maxTemporaryEntities(), c.MAX_TEMP_ENTITIES, "temporary limit")
  return true
end function

// Verify configure empty against the expected Quake behavior.
function testConfigureEmpty()
  setup()
  equal(len(refrag.R_VisibleEntities()), 0, "configured visible list")
  return true
end function

// Verify positive leaf against the expected Quake behavior.
function testPositiveLeaf()
  entities = setup()
  equal(split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0)), 1, "positive split")
  state = refrag.GetState(0)
  equal(state[2][0], 1, "positive leaf count")
  return true
end function

// Verify negative leaf against the expected Quake behavior.
function testNegativeLeaf()
  entities = setup()
  equal(split(entities[0], t.Vec3(-2.0, 0.0, 0.0), t.Vec3(-1.0, 1.0, 1.0)), 1, "negative split")
  state = refrag.GetState(0)
  equal(state[2][1], 1, "negative leaf count")
  return true
end function

// Verify mixed leaves against the expected Quake behavior.
function testMixedLeaves()
  entities = setup()
  equal(split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0)), 2, "mixed split")
  return true
end function

// Verify begin visible frame against the expected Quake behavior.
function testBeginVisibleFrame()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_StoreEfrags(0)
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_VisibleEntities()), 0, "begin clears visible")
  return true
end function

// Verify accumulate leaves against the expected Quake behavior.
function testAccumulateLeaves()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  split(entities[1], t.Vec3(-2.0, 0.0, 0.0), t.Vec3(-1.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_StoreEfrags(0)), 1, "first leaf")
  equal(len(refrag.R_StoreEfrags(1)), 2, "second leaf accumulates")
  return true
end function

// Verify deduplicate leaves against the expected Quake behavior.
function testDeduplicateLeaves()
  entities = setup()
  split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  refrag.R_StoreEfrags(0)
  equal(len(refrag.R_StoreEfrags(1)), 1, "deduplicated entity")
  return true
end function

// Verify remove efrags against the expected Quake behavior.
function testRemoveEfrags()
  entities = setup()
  split(entities[0], t.Vec3(-1.0, -1.0, -1.0), t.Vec3(1.0, 1.0, 1.0))
  yes(refrag.R_RemoveEfrags(entities[0]), "remove efrags")
  state = refrag.GetState(0)
  equal(state[0], 0, "entity efrags removed")
  equal(state[2][0] + state[2][1], 0, "leaf efrags removed")
  return true
end function

// Verify invalid leaf no change against the expected Quake behavior.
function testInvalidLeafNoChange()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  refrag.R_StoreEfrags(0)
  equal(len(refrag.R_StoreEfrags(99)), 1, "invalid leaf retains frame")
  return true
end function

// Verify invalid model filtered against the expected Quake behavior.
function testInvalidModelFiltered()
  entities = setup()
  split(entities[2], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame()
  equal(len(refrag.R_StoreEfrags(0)), 0, "invalid model hidden")
  return true
end function

// Verify client active view against the expected Quake behavior.
function testClientActiveView()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  valid = client.createEntity(1); valid.modelIndex = 1
  stale = client.createEntity(2); stale.modelIndex = 0
  value.visibleEntities = [valid, stale, void]
  equal(len(client.CL_ActiveVisibleEntities(value)), 1, "active client view")
  return true
end function

// Verify client removal view against the expected Quake behavior.
function testClientRemovalView()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  stale = client.ensureEntity(value, 1)
  stale.modelIndex = 0
  stale.forceLink = true
  equal(len(client.CL_EfragRemovalCandidates(value)), 1, "client removal handoff")
  return true
end function

// Verify client active view reuse against the expected Quake behavior.
function testClientActiveViewReuse()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  valid = client.createEntity(1); valid.modelIndex = 1
  value.visibleEntities = [valid]
  originalRaw = nativeRawValue(value.visibleEntities)
  visible = client.CL_ActiveVisibleEntities(value)
  equal(nativeRawValue(visible), originalRaw, "active client view reused")

  authoritative = [edict.create(0), edict.create(1), edict.create(2)]
  authoritative[1].model = "progs/armor.mdl"
  authoritative[1].modelIndex = 1
  authoritative[1].free = false
  authoritative[2].model = ""
  authoritative[2].modelIndex = 2
  authoritative[2].free = false
  hiddenPickup = client.createEntity(2); hiddenPickup.modelIndex = 2
  staticEntity = client.createEntity(99); staticEntity.modelIndex = 3; staticEntity.messageTime = -1.0
  filtered = client.CL_FilterAuthoritativeVisibleEntities([valid, hiddenPickup, staticEntity], authoritative)
  equal(len(filtered), 2, "authoritative hidden pickup filtered")
  equal(filtered[0].number, 1, "authoritative visible entity retained")
  equal(filtered[1].number, 99, "client-only static entity retained")
  filteredReuse = client.CL_FilterAuthoritativeVisibleEntities(value.visibleEntities, authoritative)
  equal(nativeRawValue(filteredReuse), originalRaw, "authoritative valid view reused")
  return true
end function

// Verify authoritative pickup clears source entity against the expected Quake behavior.
function testAuthoritativePickupClearsSourceEntity()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  value.maxClients = 1
  pickup = client.ensureEntity(value, 2)
  pickup.modelIndex = 2
  pickup.forceLink = false
  authoritative = [edict.create(0), edict.create(1), edict.create(2)]
  authoritative[2].model = ""
  authoritative[2].modelIndex = 2
  authoritative[2].free = false
  equal(client.CL_ApplyAuthoritativeEntityVisibility(value, authoritative), 1, "authoritative pickup clear count")
  equal(pickup.modelIndex, 0, "authoritative pickup source model cleared")
  yes(pickup.forceLink, "authoritative pickup requests efrag removal")
  equal(len(client.CL_RelinkEntities(value)), 0, "authoritative pickup absent before render")
  return true
end function

// Verify beam segment contract against the expected Quake behavior.
function testBeamSegmentContract()
  origins = handoff.beamSegmentOrigins(t.Vec3(0.0, 0.0, 0.0), t.Vec3(61.0, 0.0, 0.0), c.MAX_TEMP_ENTITIES)
  equal(len(origins), 3, "beam 30-unit segmentation")
  return true
end function

// Verify particle gravity contract against the expected Quake behavior.
function testParticleGravityContract()
  particle = particles.spawn(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 10.0), 2.0, 0, particles.PT_GRAVITY)
  updated = particles.updateWithGravity([particle], 1.0, 0.1, 400.0)
  near(updated[0].velocity.z, 8.0, 0.000001, "particle gravity handoff")
  return true
end function

// Verify view cshift contract against the expected Quake behavior.
function testViewCshiftContract()
  state = view.create()
  view.V_cshift_f(state, ["v_cshift", "1.9", "2", "3", "4"])
  equal(state.emptyCshift[0], 1.0, "view atoi contract")
  return true
end function

// Verify store order against the expected Quake behavior.
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

// Verify frame restart allows entity again against the expected Quake behavior.
function testFrameRestartAllowsEntityAgain()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  refrag.R_BeginVisibleFrame(); equal(len(refrag.R_StoreEfrags(0)), 1, "first frame")
  refrag.R_BeginVisibleFrame(); equal(len(refrag.R_StoreEfrags(0)), 1, "second frame")
  return true
end function

// Verify that the production single-pass PVS collector excludes statics in a
// hidden BSP leaf while retaining dynamic entities and visible-leaf statics.
function testStaticPvsCollection()
  entities = setup()
  split(entities[0], t.Vec3(1.0, 0.0, 0.0), t.Vec3(2.0, 1.0, 1.0))
  split(entities[1], t.Vec3(-2.0, 0.0, 0.0), t.Vec3(-1.0, 1.0, 1.0))
  dynamic = makeEntity(99, 1)
  hiddenNegativeLeaf = refrag.R_AppendVisiblePvs([dynamic], bytes(1, 0))
  equal(len(hiddenNegativeLeaf), 2, "hidden leaf static excluded")
  equal(hiddenNegativeLeaf[0].number, 99, "dynamic entity retains priority")
  equal(hiddenNegativeLeaf[1].number, 0, "visible positive-leaf static retained")
  bothLeaves = refrag.R_AppendVisiblePvs([dynamic], bytes(1, 1))
  equal(len(bothLeaves), 3, "visible negative leaf static restored")
  return true
end function

// Verify non-axial BSP29 planes use computed support corners rather than the
// renderer Plane.signBits representation, which BspPlane deliberately lacks.
function testNonAxialEfragSplit()
  entities = setup()
  plane = t.BspPlane(t.Vec3(0.70710678, 0.70710678, 0.0), 0.0, 3)
  node = t.BspNode(0, -1, -2, t.Vec3(-64.0, -64.0, -64.0), t.Vec3(64.0, 64.0, 64.0), 0, 0)
  // Reconfigure a real two-leaf map whose root is the diagonal plane.
  minimum = t.Vec3(-64.0, -64.0, -64.0)
  maximum = t.Vec3(64.0, 64.0, 64.0)
  leaf0 = t.BspLeaf(c.CONTENTS_EMPTY, -1, minimum, maximum, 0, 0, bytes(4))
  leaf1 = t.BspLeaf(c.CONTENTS_EMPTY, -1, minimum, maximum, 0, 0, bytes(4))
  model = t.BspModel(minimum, maximum, t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 2, 0, 0)
  map = t.BspMap("diagonal.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [], bytes(), [node], [], [], bytes(), [], [leaf0, leaf1], [], [], [], [model])
  renderer = t.WorldRenderer(map, bytes(), [], [], [], true, 0, false, false, 0, bytes(), 0, 1.0)
  noneModel = t.ClientRenderModel("", entityRenderer.MODEL_NONE, void, void, void, [], false)
  aliasModel = t.ClientRenderModel("progs/test.mdl", entityRenderer.MODEL_ALIAS, void, void, void, [], false)
  modelRenderer = t.EntityRenderer(void, bytes(), [noneModel, aliasModel], 0)
  refrag.Configure(renderer, modelRenderer, entities)
  refrag.SetSplitState(entities[0], t.Vec3(-2.0, -2.0, -1.0), t.Vec3(2.0, 2.0, 1.0))
  equal(refrag.R_SplitEntityOnNode(0), 2, "diagonal plane touches both leaves")
  return true
end function

// Verify cap constant positive against the expected Quake behavior.
function testCapConstantPositive()
  yes(contract.maxVisibleEntities() > 0 and contract.maxTemporaryEntities() > 0, "positive limits")
  return true
end function


// Verify beam model names against the expected Quake behavior.
function testBeamModelNames()
  equal(handoff.beamModelName(c.TE_LIGHTNING1), "progs/bolt.mdl", "lightning1 model")
  equal(handoff.beamModelName(c.TE_LIGHTNING3), "progs/bolt3.mdl", "lightning3 model")
  equal(handoff.beamModelName(c.TE_BEAM), "progs/beam.mdl", "beam model")
  return true
end function

// Verify beam models precached once against the expected Quake behavior.
function testBeamModelsPrecachedOnce()
  player = physics.createPlayer(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  state = client.create(player)
  first = handoff.precacheBeamModels(state)
  equal(len(first), 4, "beam preload names")
  equal(len(state.modelPrecache), 5, "beam preload slots")
  handoff.precacheBeamModels(state)
  equal(len(state.modelPrecache), 5, "beam preload idempotent")
  return true
end function

// Verify temporary submission cap against the expected Quake behavior.
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

// Verify empty temporary submission reuse against the expected Quake behavior.
function testEmptyTemporarySubmissionReuse()
  visible = [makeEntity(1, 1), makeEntity(2, 1)]
  originalRaw = nativeRawValue(visible)
  output = handoff.submitEntities(visible, [])
  equal(nativeRawValue(output), originalRaw, "empty temporary submission reused")
  return true
end function

// Verify render submitted symbol against the expected Quake behavior.
function testRenderSubmittedSymbol()
  // Function values are first-class; this binds the prefiltered renderer API.
  fn = entityRenderer.renderSubmitted
  yes(typeof(fn) == "function", "renderSubmitted function")
  return true
end function

// Verify contract feature bits against the expected Quake behavior.
function testContractFeatureBits()
  equal(contract.BEAM_MODEL_HANDOFF, 1, "beam handoff")
  equal(contract.CHASE_REFDEF_PRESERVATION, 1, "chase refdef")
  equal(contract.EFRAG_FRAME_ACCUMULATION, 1, "efrag accumulate")
  equal(contract.PARTICLE_FLOAT_STORAGE, 1, "particle floats")
  return true
end function

// Parse command-line arguments and run the selected operation.
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
    ["client active view reuse", testClientActiveViewReuse],
    ["authoritative pickup source clear", testAuthoritativePickupClearsSourceEntity],
    ["beam contract", testBeamSegmentContract],
    ["particle gravity", testParticleGravityContract],
    ["view cshift", testViewCshiftContract],
    ["store order", testStoreOrder],
    ["frame restart", testFrameRestartAllowsEntityAgain],
    ["static PVS collection", testStaticPvsCollection],
    ["non-axial efrag split", testNonAxialEfragSplit],
    ["beam model names", testBeamModelNames],
    ["beam model preload", testBeamModelsPrecachedOnce],
    ["temporary submission cap", testTemporarySubmissionCap],
    ["empty temporary submission reuse", testEmptyTemporarySubmissionReuse],
    ["render submitted symbol", testRenderSubmittedSymbol],
    ["contract feature bits", testContractFeatureBits],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 30 then return 1 end if
  print "MiniQuake BP-039 client/render closure tests passed: 30"
  return 0
end function
