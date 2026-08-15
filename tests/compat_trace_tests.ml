/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-001R3 deterministic-diagnostics unit tests. These tests require no Quake game
assets and exercise the canonical hashing, JSON escaping and host checkpoint
contract that the Windows acceptance test later uses with real id1 data.
*/
import miniquake.types as t
import miniquake.host as host
import miniquake.client as client
import miniquake.edict as edict
import miniquake.server as serverRuntime
import miniquake.quakec.vm as vm
import miniquake.constants as c
import miniquake.compat_trace as trace
import miniquake.compat_diagnostics as diagnostics

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9200, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9201, name + ": expected true") end if
  return true
end function

// Execute one named test case and record its pass/fail result.
function runTest(number, name, fn)
  print "  [" + number + "/10] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Verify fnv against the expected Quake behavior.
function testFnv()
  assertEqual(trace.hashText("hello"), 0x4f9f2cab, "FNV-1a hello")
  assertEqual(trace.hashText("hello"), trace.hashText("hello"), "stable FNV")
  return true
end function

// Verify json escape against the expected Quake behavior.
function testJsonEscape()
  assertEqual(diagnostics.jsonEscape("a\"b\\c\n"), "a\\\"b\\\\c\\n", "JSON escape")
  assertEqual(diagnostics.jsonString("quake"), "\"quake\"", "JSON string")
  return true
end function

// Verify float hex against the expected Quake behavior.
function testFloatHex()
  assertEqual(diagnostics.f32Hex(0.0), "00000000", "zero float bits")
  assertEqual(diagnostics.f32Hex(12.5), "41480000", "12.5 float bits")
  assertTrue(t.isVec3Value(t.Vec3(1.0, 2.0, 3.0)), "qualified Vec3 type name accepted")
  return true
end function

// Create and initialize session.
function makeSession()
  return host.create(["-headless", "-nosound", "-nolan"])
end function

// Update module state for field definitions.
function bp001SyncFieldDefinitions()
  return [
    t.QuakeCDef(c.EV_STRING, 0, 0, "classname"),
    t.QuakeCDef(c.EV_STRING, 1, 0, "model"),
    t.QuakeCDef(c.EV_FLOAT, 2, 0, "modelindex"),
    t.QuakeCDef(c.EV_FLOAT, 3, 0, "frame"),
    t.QuakeCDef(c.EV_FLOAT, 4, 0, "colormap"),
    t.QuakeCDef(c.EV_FLOAT, 5, 0, "skin"),
    t.QuakeCDef(c.EV_FLOAT, 6, 0, "effects"),
    t.QuakeCDef(c.EV_VECTOR, 7, 0, "origin"),
    t.QuakeCDef(c.EV_VECTOR, 10, 0, "angles"),
    t.QuakeCDef(c.EV_VECTOR, 13, 0, "velocity"),
    t.QuakeCDef(c.EV_VECTOR, 16, 0, "mins"),
    t.QuakeCDef(c.EV_VECTOR, 19, 0, "maxs"),
    t.QuakeCDef(c.EV_FLOAT, 22, 0, "movetype"),
    t.QuakeCDef(c.EV_FLOAT, 23, 0, "solid"),
    t.QuakeCDef(c.EV_FLOAT, 24, 0, "flags"),
    t.QuakeCDef(c.EV_FLOAT, 25, 0, "health"),
    t.QuakeCDef(c.EV_VECTOR, 26, 0, "view_ofs"),
    t.QuakeCDef(c.EV_ENTITY, 29, 0, "groundentity"),
  ]
end function

// Create and initialize sync machine.
function bp001MakeSyncMachine(entityCount)
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "bp001_sync_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    [],
    bp001SyncFieldDefinitions(),
    [dummy],
    bytes(2),
    vm.zeroArray(64),
    30,
  )
  return vm.create(program, entityCount)
end function

// Exercise the populate sync machine test scenario and verify its expected result.
function bp001PopulateSyncMachine(machine, entityCount)
  index = 0
  while index < entityCount
    origin = t.Vec3(index + 0.25, index * -2.0, index + 64.0)
    angles = t.Vec3(index, index + 90.0, -index)
    velocity = t.Vec3(index * 3.0, index * -4.0, index * 5.0)
    mins = t.Vec3(-16.0, -16.0, -24.0)
    maxs = t.Vec3(16.0, 16.0, 32.0)
    viewOffset = t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT)
    vm.setEntityVector(machine, index, 7, origin)
    vm.setEntityVector(machine, index, 10, angles)
    vm.setEntityVector(machine, index, 13, velocity)
    vm.setEntityVector(machine, index, 16, mins)
    vm.setEntityVector(machine, index, 19, maxs)
    vm.setEntityFloat(machine, index, 2, index & 255)
    vm.setEntityFloat(machine, index, 3, index & 31)
    vm.setEntityFloat(machine, index, 4, 0.0)
    vm.setEntityFloat(machine, index, 5, index & 7)
    vm.setEntityFloat(machine, index, 6, index & 15)
    vm.setEntityFloat(machine, index, 22, c.MOVETYPE_NONE)
    vm.setEntityFloat(machine, index, 23, c.SOLID_NOT)
    vm.setEntityFloat(machine, index, 24, 0.0)
    vm.setEntityFloat(machine, index, 25, 100.0 + index)
    vm.setEntityVector(machine, index, 26, viewOffset)
    vm.setEntityField(machine, index, 29, 0)
    index = index + 1
  end while
  return true
end function

// Verify synchronized edict gc roots against the expected Quake behavior.
function bp001TestSynchronizedEdictGcRoots()
  // e1m2 exposed the remaining bug with 227 server edicts after more than
  // fifty otherwise identical frames.  Reproduce that scale and duration
  // against the actual production mirror while forcing collections.
  entityCount = 227
  game = serverRuntime.create(1)
  machine = bp001MakeSyncMachine(entityCount)
  runtime = serverRuntime.createEdictRuntime(entityCount, 1)
  contextValue = serverRuntime.createQuakeCContext(game, void, void, void, runtime)
  vm.setContext(machine, contextValue)
  machine.edictFree = runtime.freeFlags
  index = 0
  while index < entityCount
    runtime.freeFlags[index] = false
    machine.edictFree[index] = false
    index = index + 1
  end while
  runtime.numEdicts = entityCount
  bp001PopulateSyncMachine(machine, entityCount)
  game.machine = machine
  game.active = true

  gc_set_limit(256)
  synchronizedCount = serverRuntime.syncQuakeCEdicts(game)
  assertEqual(synchronizedCount, entityCount, "initial synchronized edict count")
  stableEdict = game.edicts[77]
  stableOrigin = stableEdict.origin
  stableAngles = stableEdict.angles
  stableVelocity = stableEdict.velocity
  stableEdictRaw = nativeRawValue(stableEdict)
  stableOriginRaw = nativeRawValue(stableOrigin)
  stableAnglesRaw = nativeRawValue(stableAngles)
  stableVelocityRaw = nativeRawValue(stableVelocity)

  pass = 0
  while pass < 80
    // Change the raw QuakeC values each pass so the test proves in-place data
    // refresh, not merely survival of one initial mirror snapshot.
    vm.setEntityFloat(machine, 77, 7, 77.25 + pass)
    synchronizedCount = serverRuntime.syncQuakeCEdicts(game)
    assertEqual(synchronizedCount, entityCount, "stable synchronized edict count")

    churn = array(96)
    churnIndex = 0
    while churnIndex < len(churn)
      churn[churnIndex] = t.Vec3(pass, churnIndex, pass + churnIndex)
      churnIndex = churnIndex + 1
    end while
    gc_collect()

    item = game.edicts[77]
    assertEqual(nativeRawValue(item), stableEdictRaw, "stable QuakeEdict identity")
    assertEqual(nativeRawValue(item.origin), stableOriginRaw, "stable origin identity")
    assertEqual(nativeRawValue(item.angles), stableAnglesRaw, "stable angles identity")
    assertEqual(nativeRawValue(item.velocity), stableVelocityRaw, "stable velocity identity")
    assertEqual(item.origin.x, 77.25 + pass, "stable origin refresh")

    index = 0
    while index < entityCount
      checked = game.edicts[index]
      assertTrue(t.isVec3Value(checked.origin), "synchronized origin root " + index)
      assertTrue(t.isVec3Value(checked.angles), "synchronized angles root " + index)
      assertTrue(t.isVec3Value(checked.velocity), "synchronized velocity root " + index)
      assertTrue(t.isVec3Value(checked.mins), "synchronized mins root " + index)
      assertTrue(t.isVec3Value(checked.maxs), "synchronized maxs root " + index)
      assertTrue(t.isVec3Value(checked.viewOffset), "synchronized view offset root " + index)
      assertTrue(t.isVec3Value(checked.baseline.origin), "synchronized baseline origin root " + index)
      assertTrue(t.isVec3Value(checked.baseline.angles), "synchronized baseline angles root " + index)
      index = index + 1
    end while
    pass = pass + 1
  end while

  // ED_Free does not lower sv.num_edicts.  Preserve the C high-water mark and
  // the stable array even when the last slot becomes free.
  runtime.freeFlags[entityCount - 1] = true
  machine.edictFree[entityCount - 1] = true
  synchronizedCount = serverRuntime.syncQuakeCEdicts(game)
  assertEqual(synchronizedCount, entityCount, "freed tail keeps high-water mark")
  assertEqual(len(game.edicts), entityCount, "freed tail keeps stable array length")

  // Stock pickup QuakeC hides an item with `self.model = string_null` while
  // deliberately retaining modelindex for a possible later respawn. The
  // frame-local snapshot mirror must preserve this two-field distinction or
  // SV_WriteEntitiesToClient keeps sending the already collected item.
  runtime.freeFlags[77] = false
  machine.edictFree[77] = false
  vm.setEntityFloat(machine, 77, 2, 5.0)
  vm.setEntityString(machine, 77, 1, "progs/g_rock2.mdl")
  serverRuntime.syncQuakeCSnapshotEdicts(game)
  assertEqual(game.edicts[77].model, "progs/g_rock2.mdl", "pickup model enters snapshot")
  assertEqual(game.edicts[77].modelIndex, 5, "pickup modelindex enters snapshot")
  vm.setEntityField(machine, 77, 1, 0)
  serverRuntime.syncQuakeCSnapshotEdicts(game)
  assertEqual(game.edicts[77].model, "", "collected pickup model string clears")
  assertEqual(game.edicts[77].modelHandle, 0, "collected pickup model handle clears")
  assertEqual(game.edicts[77].modelIndex, 5, "collected pickup retains modelindex")
  vm.setEntityString(machine, 77, 1, "progs/g_rock2.mdl")
  serverRuntime.syncQuakeCSnapshotEdicts(game)
  assertEqual(game.edicts[77].model, "progs/g_rock2.mdl", "respawned pickup model restores")
  // QuakeC strings are offsets, not nullable host strings. A mod can assign
  // an empty string at a non-zero program offset; retaining only modelindex
  // and the previous decoded text would keep drawing the collected pickup.
  vm.setEntityField(machine, 77, 1, 1)
  serverRuntime.syncQuakeCSnapshotEdicts(game)
  assertEqual(game.edicts[77].modelHandle, 1, "non-zero empty pickup handle enters snapshot")
  assertEqual(game.edicts[77].model, "", "non-zero empty pickup string clears")

  gc_set_limit(1048576)
  serverRuntime.shutdown(game)
  return true
end function

// Verify canonical stable against the expected Quake behavior.
function testCanonicalStable()
  session = makeSession()
  first = trace.canonicalFrame(session, 0, true)
  second = trace.canonicalFrame(session, 0, true)
  assertEqual(first, second, "canonical frame stable")
  assertEqual(trace.hashText(first), trace.hashText(second), "canonical hash stable")

  // BP-060-064R2 exposed a native GC-rooting edge case while the QuakeC
  // mirror rebuilt many heap-backed QuakeEdicts.  Exercise the same ownership
  // shape under deliberate allocation pressure and a forced collection.
  serverEdicts = array(192)
  index = 0
  while index < len(serverEdicts)
    item = edict.create(index)
    item.origin.x = index
    item.angles.y = index * 2
    item.velocity.z = -index
    serverEdicts[index] = item
    index = index + 1
  end while
  session.server.edicts = serverEdicts
  session.server.numEdicts = len(serverEdicts)

  churn = array(2048)
  index = 0
  while index < len(churn)
    churn[index] = t.Vec3(index, index + 1, index + 2)
    index = index + 1
  end while
  gc_collect()

  index = 0
  while index < len(serverEdicts)
    assertTrue(t.isVec3Value(serverEdicts[index].origin), "rooted edict origin")
    assertTrue(t.isVec3Value(serverEdicts[index].angles), "rooted edict angles")
    assertTrue(t.isVec3Value(serverEdicts[index].velocity), "rooted edict velocity")
    index = index + 1
  end while
  stressedFirst = trace.canonicalFrame(session, 1, true)
  gc_collect()
  stressedSecond = trace.canonicalFrame(session, 1, true)
  assertEqual(stressedFirst, stressedSecond, "GC-stressed canonical frame stable")

  savedOrigin = serverEdicts[7].origin
  serverEdicts[7].origin = 0
  malformed = try(trace.serverEdictsHash(session))
  assertTrue(malformed is error, "malformed Vec3 is classified")
  assertTrue(trace.containsText(malformed.message, "server edict 7 origin"), "malformed Vec3 identifies field")
  serverEdicts[7].origin = savedOrigin
  bp001TestSynchronizedEdictGcRoots()
  host.shutdown(session)
  return true
end function

// Verify canonical changes against the expected Quake behavior.
function testCanonicalChanges()
  session = makeSession()
  before = trace.canonicalFrame(session, 0, true)
  session.player.origin = t.Vec3(1.0, 2.0, 3.0)
  after = trace.canonicalFrame(session, 0, true)
  assertTrue(before != after, "canonical frame changes with player origin")
  assertTrue(trace.hashText(before) != trace.hashText(after), "state hash changes")
  host.shutdown(session)
  return true
end function

// Verify checkpoint contract against the expected Quake behavior.
function testCheckpointContract()
  session = makeSession()
  session.frameTrace = []
  diagnostics.checkpoint(session, "filter")
  diagnostics.checkpoint(session, "commands")
  assertEqual(len(session.frameTrace), 2, "stage count")
  assertEqual(session.frameTrace[0], "filter", "first stage")
  assertEqual(session.diagnosticLastStage, "commands", "last stage")
  host.shutdown(session)
  return true
end function

// Verify context json against the expected Quake behavior.
function testContextJson()
  session = makeSession()
  session.diagnosticFrame = 7
  session.frameTrace = ["filter", "commands"]
  session.diagnosticLastStage = "commands"
  text = diagnostics.contextJson(session, "in_frame", "")
  assertTrue(trace.containsText(text, "MiniQuakeCrashContext/1"), "context schema")
  assertTrue(trace.containsText(text, "\"frame\":7"), "context frame")
  assertTrue(trace.containsText(text, "\"last_completed_stage\":\"commands\""), "context stage")
  host.shutdown(session)
  return true
end function


// Verify sparse client entities against the expected Quake behavior.
function testSparseClientEntities()
  session = makeSession()
  firstEntity = client.createEntity(1)
  firstEntity.modelIndex = 1
  laterEntity = client.createEntity(4)
  laterEntity.modelIndex = 2
  session.client.entities = [void, firstEntity, void, void, laterEntity, void]

  firstHash = trace.clientEntitiesHash(session)
  secondHash = trace.clientEntitiesHash(session)
  serialized = trace.clientEntitiesJson(session)
  canonical = trace.canonicalFrame(session, 0, true)

  assertEqual(firstHash, secondHash, "sparse client hash stable")
  assertTrue(trace.containsText(serialized, "[null,"), "leading sparse slot serialized")
  assertTrue(trace.containsText(serialized, ",null,null,"), "interior sparse slots serialized")
  assertTrue(trace.containsText(serialized, ",null]"), "trailing sparse slot serialized")
  assertTrue(trace.containsText(canonical, "|client_entities="), "sparse canonical frame")

  session.client.entities = [firstEntity, laterEntity]
  assertTrue(trace.clientEntitiesHash(session) != firstHash, "sparse topology participates in hash")
  session.client.entities = [void, firstEntity, void, void, laterEntity, void]
  laterEntity.frame = 7
  assertTrue(trace.clientEntitiesHash(session) != firstHash, "sparse client hash mutation")
  host.shutdown(session)
  return true
end function

// Verify headless input isolation against the expected Quake behavior.
function testHeadlessInputIsolation()
  assertEqual(host.shouldPollLiveButtonBindings(true, true, false, false), false, "headless game input disabled")
  assertEqual(host.shouldPollLiveButtonBindings(false, true, false, false), true, "interactive game input enabled")
  assertEqual(host.shouldPollLiveButtonBindings(false, false, false, false), false, "non-game destination disabled")
  assertEqual(host.shouldPollLiveButtonBindings(false, true, true, false), false, "console destination disabled")
  assertEqual(host.shouldPollLiveButtonBindings(false, true, false, true), false, "menu destination disabled")
  return true
end function

// Verify trace schemas against the expected Quake behavior.
function testTraceSchemas()
  session = makeSession()
  snapshot = trace.snapshotJson(session, 0, "unit", "")
  summary = trace.summaryJson(true, 1, 1, 1, trace.hashText("x"), "a", "b", "c", "complete", "", true, "")
  assertTrue(trace.containsText(snapshot, "MiniQuakeSnapshot/1"), "snapshot schema")
  assertTrue(trace.containsText(summary, "MiniQuakeTraceSummary/1"), "summary schema")
  host.shutdown(session)
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-001R3 compatibility diagnostics tests"
  passed = 0
  if runTest("01", "FNV-1a hashing", testFnv) then passed = passed + 1 end if
  if runTest("02", "JSON escaping", testJsonEscape) then passed = passed + 1 end if
  if runTest("03", "exact float hex", testFloatHex) then passed = passed + 1 end if
  if runTest("04", "canonical stability", testCanonicalStable) then passed = passed + 1 end if
  if runTest("05", "canonical mutation sensitivity", testCanonicalChanges) then passed = passed + 1 end if
  if runTest("06", "host checkpoint contract", testCheckpointContract) then passed = passed + 1 end if
  if runTest("07", "crash-context JSON", testContextJson) then passed = passed + 1 end if
  if runTest("08", "snapshot and summary schemas", testTraceSchemas) then passed = passed + 1 end if
  if runTest("09", "sparse client entity diagnostics", testSparseClientEntities) then passed = passed + 1 end if
  if runTest("10", "headless live-input isolation", testHeadlessInputIsolation) then passed = passed + 1 end if
  if passed != 10 then
    print "MiniQuake BP-001R3 diagnostics tests failed: " + passed + "/10"
    return 1
  end if
  print "MiniQuake BP-001R3 diagnostics tests passed: 10"
  return 0
end function
