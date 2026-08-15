/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-012R1 byte-exact Protocol-15 server payload, baseline, packet-planning
and PlayerState ground-adapter fixtures. The golden byte streams are independently reproduced by
tools/oracle/protocol15_serverdata_oracle.c and
tools/check_protocol15_serverdata.py.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.client as clientModule
import miniquake.client_protocol as clientProtocol
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_serverdata as serverData
import miniquake.protocol_update as update
import miniquake.server as server
import miniquake.sv_main as svmain
import miniquake.edict as edict
import miniquake.player_move as movement
import miniquake.world_bsp as worldBsp

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9500, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9501, name + ": expected true") end if
  return true
end function

// Exercise assert false as part of this deterministic regression fixture.
function assertFalse(value, name)
  if value != false then return error(9502, name + ": expected false") end if
  return true
end function

// Exercise assert hex as part of this deterministic regression fixture.
function assertHex(buffer, expected, name)
  return assertEqual(hex(sz.dataSlice(buffer)), expected, name)
end function

// Execute one named test case and record its pass/fail result.
function runTest(number, name, fn)
  print "  [" + number + "/18] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Verify that dense snapshots retain high-numbered rockets and grenades.
function testProjectileSnapshotPriority()
  gameServer = server.create(1)
  entities = [edict.create(0)]
  player = edict.create(1)
  entities = entities + [player]
  index = 2
  while index < 70
    filler = edict.create(index)
    filler.model = "progs/filler.mdl"
    filler.modelIndex = 2
    filler.origin = t.Vec3(index * 8.0, index * 4.0, index * 2.0)
    filler.frame = index
    entities = entities + [filler]
    index = index + 1
  end while
  rocket = edict.create(70)
  rocket.model = "progs/missile.mdl"
  rocket.modelIndex = 3
  rocket.moveType = c.MOVETYPE_FLYMISSILE
  rocket.origin = t.Vec3(128.0, 64.0, 32.0)
  entities = entities + [rocket]
  gameServer.edicts = entities
  gameServer.numEdicts = len(entities)

  // A 64-byte fixture cannot contain every low-numbered filler. The planner
  // must nevertheless emit the player followed by the high-numbered rocket.
  buffer = sz.alloc(64)
  written = server.writeVisibleEntityUpdatesReserved(gameServer, buffer, bytes(), 1, 0)
  assertTrue(written >= 2, "dense snapshot writes player and projectile")
  parsed = clientProtocol.CL_ParseServerMessage(sz.dataSlice(buffer))
  assertTrue(len(parsed.events) >= 2, "dense snapshot has fast updates")
  assertEqual(parsed.events[0].payload[0], 1, "player update is first")
  assertEqual(parsed.events[1].payload[0], 70, "rocket update precedes filler saturation")
  return true
end function

// Return minimal client data derived from the active module state.
function minimalClientData(standardQuake, activeWeapon)
  return t.ProtocolClientData(
    22.0,
    0.0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    0,
    0,
    0.0,
    0.0,
    3,
    100,
    40,
    25,
    50,
    5,
    100,
    0x12345678,
    activeWeapon,
    standardQuake,
  )
end function

// Return full client data derived from the active module state.
function fullClientData()
  return t.ProtocolClientData(
    30.0,
    -5.0,
    t.Vec3(1.0, -2.0, 3.0),
    t.Vec3(16.0, -32.0, 48.0),
    c.FL_ONGROUND,
    2,
    300.0,
    -1.0,
    257,
    -20,
    300,
    -1,
    256,
    511,
    128,
    0xf1234567,
    260,
    true,
  )
end function

// Return mission client data derived from the active module state.
function missionClientData(activeWeapon)
  return t.ProtocolClientData(
    22.0,
    0.0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    0,
    0,
    0.0,
    0.0,
    4,
    80,
    12,
    13,
    14,
    15,
    16,
    0x00800001,
    activeWeapon,
    false,
  )
end function

// Verify server info coop against the expected Quake behavior.
function testServerInfoCoop()
  buffer = sz.alloc(c.MAX_MSGLEN)
  written = serverData.writeServerInfo(
    buffer,
    5927,
    1,
    c.GAME_COOP,
    "The Slipgate Complex",
    ["", "maps/e1m1.bsp", "progs/player.mdl", "", "ignored.mdl"],
    ["", "misc/menu1.wav", "", "ignored.wav"],
    2,
    1,
  )
  expected = "08020a56455253494f4e20312e3039205345525645522028353932372043524329000b0f000000010054686520536c69706761746520436f6d706c6578006d6170732f65316d312e6273700070726f67732f706c617965722e6d646c00006d6973632f6d656e75312e77617600002002020501001901"
  assertHex(buffer, expected, "serverinfo_coop")
  assertEqual(written, 118, "serverinfo byte count")
  return true
end function

// Verify production server info against the expected Quake behavior.
function testProductionServerInfo()
  state = svmain.SV_Init(4)
  state.server.coop = false
  state.server.deathmatch = true
  state.server.levelName = "Place of Two Deaths"
  state.server.modelPrecache = ["", "maps/dm1.bsp", ""]
  state.server.soundPrecache = ["", ""]
  state.server.cdTrack = 0
  clientValue = state.server.clients[0]
  clientValue.edictIndex = 4
  sz.clear(clientValue.message)

  expected = sz.alloc(c.MAX_MSGLEN)
  serverData.writeServerInfo(
    expected, 0, 4, c.GAME_DEATHMATCH, "Place of Two Deaths",
    state.server.modelPrecache, state.server.soundPrecache, 0, 4,
  )
  assertHex(expected, "08020a56455253494f4e20312e3039205345525645522028302043524329000b0f0000000401506c616365206f662054776f20446561746873006d6170732f646d312e6273700000002000000504001901", "production serverinfo without progs")

  golden = sz.alloc(c.MAX_MSGLEN)
  serverData.writeServerInfo(
    golden, 12345, 4, c.GAME_DEATHMATCH, "Place of Two Deaths",
    state.server.modelPrecache, state.server.soundPrecache, 0, 4,
  )
  assertHex(golden, "08020a56455253494f4e20312e303920534552564552202831323334352043524329000b0f0000000401506c616365206f662054776f20446561746873006d6170732f646d312e6273700000002000000504001901", "serverinfo_deathmatch")
  written = svmain.SV_SendServerinfo(state, clientValue)
  assertEqual(written, expected.curSize, "production serverinfo size")
  assertEqual(hex(sz.dataSlice(clientValue.message)), hex(sz.dataSlice(expected)), "production shared serverinfo")
  assertEqual(clientValue.signonStage, c.SIGNON_SERVERINFO, "serverinfo signon stage")
  assertTrue(clientValue.sendSignon, "serverinfo sendsignon")
  assertFalse(clientValue.spawned, "serverinfo spawned reset")
  return true
end function

// Verify sound vectors against the expected Quake behavior.
function testSoundVectors()
  defaultSound = sz.alloc(64)
  serverData.writeSound(defaultSound, 3, 2.9, 5, 255.9, 1.0000000298023224, t.Vec3(10.0, -20.0, 30.0))
  assertHex(defaultSound, "06001a0005500060fff000", "sound_default")

  customSound = sz.alloc(64)
  serverData.writeSound(customSound, 300, 7, 255, 128, 0.5, t.Vec3(-12.25, 0.125, 4095.875))
  assertHex(customSound, "060380206709ff9eff0100ff7f", "sound_custom")

  roundedDefault = sz.alloc(64)
  serverData.writeSound(roundedDefault, 3, 2, 5, 255, 1.00000001, t.Vec3(10.0, -20.0, 30.0))
  assertHex(roundedDefault, "06001a0005500060fff000", "sound_float_parameter_rounding")
  assertEqual(serverData.soundFieldMask(255, 1.00000001), 0, "float parameter rounding field mask")
  assertEqual(serverData.soundFieldMask(255, 1.0), 0, "default sound field mask")
  assertEqual(serverData.soundFieldMask(128, 0.5), c.SND_VOLUME | c.SND_ATTENUATION, "custom sound field mask")
  return true
end function

// Verify production sound against the expected Quake behavior.
function testProductionSound()
  state = svmain.SV_Init(1)
  item = edict.create(0)
  item.origin = t.Vec3(10.0, -20.0, 30.0)
  item.mins = t.Vec3(0.0, 0.0, 0.0)
  item.maxs = t.Vec3(0.0, 0.0, 0.0)
  state.server.edicts = [item]
  state.server.numEdicts = 1
  state.server.soundPrecache = ["", "misc/test.wav"]
  sz.clear(state.server.datagram)

  expected = sz.alloc(64)
  serverData.writeSound(expected, 0, 2, 1, 255, 1.0, item.origin)
  assertTrue(svmain.SV_StartSound(state, 0, 2, "misc/test.wav", 255, 1.0), "production sound accepted")
  assertEqual(hex(sz.dataSlice(state.server.datagram)), hex(sz.dataSlice(expected)), "production shared sound")

  rejected = try(svmain.SV_StartSound(state, 0, 8, "misc/test.wav", 255, 1.0))
  assertTrue(rejected is error, "invalid channel rejected")
  return true
end function

// Verify client data minimal against the expected Quake behavior.
function testClientDataMinimal()
  buffer = sz.alloc(64)
  result = serverData.writeClientData(buffer, minimalClientData(true, 2))
  assertEqual(result[0], 16896, "minimal clientdata bits")
  assertEqual(result[1], 16, "minimal clientdata length")
  assertHex(buffer, "0f004278563412036400281932056402", "clientdata_minimal")
  return true
end function

// Verify client data full standard against the expected Quake behavior.
function testClientDataFullStandard()
  buffer = sz.alloc(64)
  result = serverData.writeClientData(buffer, fullClientData())
  assertEqual(result[0], 32511, "full clientdata bits")
  assertEqual(result[1], 26, "full clientdata length")
  assertHex(buffer, "0fff7e1efb0101fefe0303674523f12cff01ecff2cff00ff8004", "clientdata_full_standard")
  return true
end function

// Verify client data mission pack against the expected Quake behavior.
function testClientDataMissionPack()
  buffer = sz.alloc(64)
  result = serverData.writeClientData(buffer, missionClientData(1 << 7))
  assertEqual(result[0], 16896, "mission clientdata bits")
  assertHex(buffer, "0f0042010080000450000c0d0e0f1007", "clientdata_missionpack")

  zero = sz.alloc(64)
  zeroResult = serverData.writeClientData(zero, missionClientData(0))
  assertEqual(zeroResult[1], 15, "mission zero active weapon length")
  assertHex(zero, "0f0042010080000450000c0d0e0f10", "clientdata_missionpack_zero")
  return true
end function

// Verify baseline vectors against the expected Quake behavior.
function testBaselineVectors()
  world = t.EntityBaseline(1, 2, 0, 4, 0, t.Vec3(-12.25, 0.125, 4095.875), t.Vec3(90.75, -90.9, 359.9))
  worldBuffer = sz.alloc(64)
  serverData.writeBaseline(worldBuffer, 0, world)
  assertHex(worldBuffer, "160000010200049eff400100c0ff7fff", "baseline_world")

  player = t.EntityBaseline(2, 3, 1, 5, 0, t.Vec3(10.0, 20.0, 30.0), t.Vec3(0.0, 45.0, 90.0))
  playerBuffer = sz.alloc(64)
  serverData.writeBaseline(playerBuffer, 1, player)
  assertHex(playerBuffer, "16010002030105500000a00020f00040", "baseline_player")
  return true
end function

// Verify production baseline selection against the expected Quake behavior.
function testProductionBaselineSelection()
  state = svmain.SV_Init(1)
  world = edict.create(0)
  world.model = "maps/start.bsp"
  world.modelIndex = 1
  world.frame = 2
  world.skin = 4
  world.origin = t.Vec3(-12.25, 0.125, 4095.875)
  world.angles = t.Vec3(90.75, -90.9, 359.9)

  player = edict.create(1)
  player.frame = 3
  player.skin = 5
  player.origin = t.Vec3(10.0, 20.0, 30.0)
  player.angles = t.Vec3(0.0, 45.0, 90.0)

  staticEntity = edict.create(2)
  staticEntity.model = "progs/ogre.mdl"
  staticEntity.modelIndex = 3
  staticEntity.frame = 4
  staticEntity.skin = 6
  staticEntity.origin = t.Vec3(1.0, 2.0, 3.0)
  staticEntity.angles = t.Vec3(0.0, 90.0, 180.0)

  skipped = edict.create(3)
  state.server.modelPrecache = ["", "maps/start.bsp", "progs/player.mdl", "progs/ogre.mdl"]
  state.server.edicts = [world, player, staticEntity, skipped]
  state.server.numEdicts = 4
  sz.clear(state.server.signon)

  assertEqual(svmain.SV_CreateBaseline(state), 3, "baseline entity count")
  expected = "160000010200049eff400100c0ff7fff16010002030105500000a00020f0004016020003040006080000100040180080"
  assertHex(state.server.signon, expected, "production baseline stream")
  assertEqual(player.baseline.modelIndex, 2, "player baseline model")
  assertEqual(player.baseline.colormap, 1, "player baseline colormap")
  assertEqual(staticEntity.baseline.effects, 0, "baseline effects stay zero")
  return true
end function

// Create and initialize buffer.
function makeBuffer(size, count, value)
  buffer = sz.alloc(size)
  if count > 0 then sz.writeBytes(buffer, bytes(count, value)) end if
  return buffer
end function

// Verify strict datagram boundary against the expected Quake behavior.
function testStrictDatagramBoundary()
  emptyDestination = makeBuffer(10, 4, 1)
  emptySource = sz.alloc(10)
  assertTrue(serverData.appendDatagramIfFits(emptyDestination, emptySource), "empty datagram accepted")
  assertEqual(emptyDestination.curSize, 4, "empty datagram leaves size")

  belowDestination = makeBuffer(10, 4, 1)
  belowSource = makeBuffer(10, 5, 2)
  assertTrue(serverData.appendDatagramIfFits(belowDestination, belowSource), "sum below max accepted")
  assertEqual(belowDestination.curSize, 9, "below max copied")

  equalDestination = makeBuffer(10, 5, 1)
  equalSource = makeBuffer(10, 5, 2)
  assertFalse(serverData.appendDatagramIfFits(equalDestination, equalSource), "sum equal max rejected")
  assertEqual(equalDestination.curSize, 5, "equal max not copied")

  aboveDestination = makeBuffer(10, 6, 1)
  aboveSource = makeBuffer(10, 5, 2)
  assertFalse(serverData.appendDatagramIfFits(aboveDestination, aboveSource), "sum above max rejected")

  fullDestination = makeBuffer(10, 10, 1)
  assertFalse(serverData.appendDatagramIfFits(fullDestination, emptySource), "empty source at exact max rejected")
  return true
end function

// Return full update bits derived from the active module state.
function fullUpdateBits(longEntity)
  bits = c.U_MOREBITS | c.U_ORIGIN1 | c.U_ORIGIN2 | c.U_ORIGIN3 | c.U_ANGLE2 |
    c.U_NOLERP | c.U_FRAME | c.U_ANGLE1 | c.U_ANGLE3 | c.U_MODEL |
    c.U_COLORMAP | c.U_SKIN | c.U_EFFECTS
  if longEntity then bits = bits | c.U_LONGENTITY end if
  return bits
end function

// Verify fast update planner against the expected Quake behavior.
function testFastUpdatePlanner()
  shortBits = fullUpdateBits(false)
  longBits = fullUpdateBits(true)
  assertEqual(update.encodedSize(0), 2, "unchanged update size")
  assertEqual(update.encodedSize(shortBits), 17, "full short update size")
  assertEqual(update.encodedSize(longBits), 18, "full long update size")

  assertFalse(update.canWrite(makeBuffer(16, 1, 0), 0), "15-byte original gate")
  assertTrue(update.canWrite(makeBuffer(16, 0, 0), 0), "16-byte unchanged update")
  assertFalse(update.canWrite(makeBuffer(16, 0, 0), shortBits), "16-byte full short safe rejection")
  assertTrue(update.canWrite(makeBuffer(17, 0, 0), shortBits), "17-byte full short accepted")
  assertFalse(update.canWrite(makeBuffer(17, 0, 0), longBits), "17-byte full long rejected")
  assertTrue(update.canWrite(makeBuffer(18, 0, 0), longBits), "18-byte full long accepted")

  reservedFits = makeBuffer(64, 30, 0)
  assertTrue(update.canWriteWithReservedTail(reservedFits, shortBits, 16), "transient tail remains strictly below max")
  assertFalse(update.canWriteWithReservedTail(reservedFits, shortBits, 17), "transient tail rejects exact max boundary")
  assertFalse(update.canWriteWithReservedTail(makeBuffer(64, 40, 0), 0, 9), "reserved tail preserves original 16-byte update gate")

  // A large door can have its origin in an invisible leaf while its visible
  // face crosses into the client's PVS. SV_LinkEdict/SV_WriteEntitiesToClient
  // must test all touched leaves, not only Mod_PointInLeaf(origin).
  minimum = t.Vec3(-64.0, -64.0, -64.0)
  maximum = t.Vec3(64.0, 64.0, 64.0)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -2, -3, minimum, maximum, 0, 0)
  leaf0 = t.BspLeaf(c.CONTENTS_SOLID, -1, minimum, maximum, 0, 0, bytes(4))
  leaf1 = t.BspLeaf(c.CONTENTS_EMPTY, 0, minimum, maximum, 0, 0, bytes(4))
  leaf2 = t.BspLeaf(c.CONTENTS_EMPTY, 1, minimum, maximum, 0, 0, bytes(4))
  worldModel = t.BspModel(minimum, maximum, t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 2, 0, 0)
  map = t.BspMap(
    "multi-leaf.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [],
    bytes([1, 2]), [node], [], [], bytes(), [], [leaf0, leaf1, leaf2], [], [], [], [worldModel],
  )
  gameServer = server.create(1)
  gameServer.worldModel = map
  door = edict.create(2)
  door.model = "*1"
  door.modelIndex = 2
  door.origin = t.Vec3(16.0, 0.0, 0.0)
  door.mins = t.Vec3(-32.0, -8.0, -8.0)
  door.maxs = t.Vec3(1.0, 8.0, 8.0)
  assertTrue(server.entityVisible(gameServer, bytes([2]), door, 1), "multi-leaf door visible from crossed PVS")
  assertEqual(len(door.leafNums), 2, "multi-leaf door caches both touched leaves")
  assertFalse(server.entityVisible(gameServer, bytes([0]), door, 1), "multi-leaf door hidden outside every touched PVS")
  fat = worldBsp.fatPvs(map, t.Vec3(0.0, 0.0, 0.0))
  assertEqual(fat[0], 3, "fat PVS merges both sides of portal boundary")
  return testProjectileSnapshotPriority()
end function

// Verify delivery plans against the expected Quake behavior.
function testDeliveryPlans()
  assertEqual(serverData.initialDeliveryPlan(true, false, 0.0), 9, "spawned initial plan")
  assertEqual(serverData.initialDeliveryPlan(false, false, 5.01), 2, "keepalive after five seconds")
  assertEqual(serverData.initialDeliveryPlan(false, false, 5.0), 4, "wait at exactly five seconds")
  assertEqual(serverData.initialDeliveryPlan(false, true, 0.0), 8, "requested signon reliable phase")

  assertEqual(serverData.reliableDeliveryPlan(false, 0, false, true), 0, "no reliable work")
  assertEqual(serverData.reliableDeliveryPlan(true, 0, false, true), 1, "overflow drop")
  assertEqual(serverData.reliableDeliveryPlan(false, 1, false, false), 2, "reliable wait")
  assertEqual(serverData.reliableDeliveryPlan(false, 1, true, true), 3, "drop-asap plan")
  assertEqual(serverData.reliableDeliveryPlan(false, 1, false, true), 4, "reliable send plan")
  return true
end function

// Verify sv main bsp boundary parity against the expected Quake behavior.
function testSvMainBspBoundaryParity()
  minimum = t.Vec3(-64.0, -64.0, -64.0)
  maximum = t.Vec3(64.0, 64.0, 64.0)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)

  // BOX_ON_PLANE_SIDE in WinQuake classifies a box whose maximum lies
  // exactly on an axial plane as back-only, not as straddling the plane.
  assertEqual(
    svmain.svmBoxPlaneSides(t.Vec3(-8.0, -1.0, -1.0), t.Vec3(0.0, 1.0, 1.0), plane),
    2,
    "sv_main axial maximum-on-plane classification",
  )

  node = t.BspNode(0, -2, -3, minimum, maximum, 0, 0)
  leaf0 = t.BspLeaf(c.CONTENTS_SOLID, -1, minimum, maximum, 0, 0, bytes(1))
  leaf1 = t.BspLeaf(c.CONTENTS_SOLID, -1, minimum, maximum, 0, 0, bytes(1))
  leaf2 = t.BspLeaf(c.CONTENTS_EMPTY, 0, minimum, maximum, 0, 0, bytes(1))
  worldModel = t.BspModel(minimum, maximum, t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 2, 0, 0)
  map = t.BspMap(
    "solid-leaf-fixture.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [],
    bytes([1]), [node], [], [], bytes(), [], [leaf0, leaf1, leaf2], [], [], [], [worldModel],
  )
  touched = svmain.svmTouchedLeaves(
    map,
    0,
    t.Vec3(0.0, -1.0, -1.0),
    t.Vec3(8.0, 1.0, 1.0),
    [],
  )
  assertEqual(len(touched), 0, "sv_main excludes nonzero solid leaves")
  return true
end function

// Verify integrated client data wrapper against the expected Quake behavior.
function testIntegratedClientDataWrapper()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.viewHeight = 22.0
  player.weapon = 3
  player.health = 100
  player.ammo = 40
  player.shells = 25
  player.nails = 50
  player.rockets = 5
  player.cells = 100
  player.items = 0x02345678
  player.activeWeapon = 2
  player.flags = 0
  player.onGround = true

  actual = sz.alloc(64)
  actualBits = server.writeClientDataWithFlags(actual, player, 1)
  expected = sz.alloc(64)
  data = minimalClientData(true, 2)
  data.flags = c.FL_ONGROUND
  data.items = 0x12345678
  expectedResult = serverData.writeClientData(expected, data)
  assertEqual(actualBits, expectedResult[0], "integrated clientdata bits")
  assertTrue((actualBits & c.SU_ONGROUND) != 0, "integrated onground bit derived from PlayerState")
  assertEqual(hex(sz.dataSlice(actual)), hex(sz.dataSlice(expected)), "integrated shared clientdata")

  // Exact BP-012 Windows regression: a remote client must consume
  // SU_ONGROUND even when the PlayerState flags mirror was not pre-synced.
  targetPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  targetClient = clientModule.create(targetPlayer)
  assertEqual(clientModule.parseMessage(targetClient, sz.dataSlice(actual)), 1, "integrated clientdata event count")
  assertTrue(targetPlayer.onGround, "integrated clientdata onground roundtrip")

  // The inverse mirror must be corrected as well.
  player.onGround = false
  player.flags = player.flags | c.FL_ONGROUND
  airborne = sz.alloc(64)
  airborneBits = server.writeClientDataWithFlags(airborne, player, 1)
  assertEqual(airborneBits & c.SU_ONGROUND, 0, "stale FL_ONGROUND mirror cleared")
  return true
end function

// Verify sv main client data wrapper against the expected Quake behavior.
function testSvMainClientDataWrapper()
  state = svmain.SV_Init(1)
  state.server.serverFlags = 1
  state.standardQuake = true
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.viewHeight = 22.0
  player.weapon = 3
  player.health = 100
  player.ammo = 40
  player.shells = 25
  player.nails = 50
  player.rockets = 5
  player.cells = 100
  player.items = 0x02345678
  player.activeWeapon = 2
  player.flags = 0
  player.onGround = true

  actual = sz.alloc(64)
  bits = svmain.SV_WriteClientdataToMessage(state, state.server.clients[0], player, actual)
  expected = sz.alloc(64)
  data = minimalClientData(true, 2)
  data.flags = c.FL_ONGROUND
  data.items = 0x12345678
  expectedResult = serverData.writeClientData(expected, data)
  assertEqual(bits, expectedResult[0], "sv_main clientdata bits")
  assertTrue((bits & c.SU_ONGROUND) != 0, "sv_main onground bit derived from PlayerState fallback")
  assertEqual(hex(sz.dataSlice(actual)), hex(sz.dataSlice(expected)), "sv_main shared clientdata")
  return true
end function


// Verify player ground flag mirror against the expected Quake behavior.
function testPlayerGroundFlagMirror()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.flags = c.FL_CLIENT | c.FL_ONGROUND
  player.onGround = false
  assertEqual(server.playerProtocolFlags(player), c.FL_CLIENT, "stale FL_ONGROUND cleared")

  player.flags = c.FL_CLIENT
  player.onGround = true
  assertEqual(server.playerProtocolFlags(player), c.FL_CLIENT | c.FL_ONGROUND, "missing FL_ONGROUND restored")

  gameServer = server.create(1)
  clientValue = gameServer.clients[0]
  data = server.protocolClientData(gameServer, clientValue, player)
  assertTrue((data.flags & c.FL_ONGROUND) != 0, "no-QC production adapter sets FL_ONGROUND")

  player.flags = c.FL_CLIENT | c.FL_ONGROUND
  player.onGround = false
  data = server.protocolClientData(gameServer, clientValue, player)
  assertFalse((data.flags & c.FL_ONGROUND) != 0, "no-QC production adapter clears FL_ONGROUND")
  return true
end function

// Verify reliable distribution and cleanup against the expected Quake behavior.
function testReliableDistributionAndCleanup()
  gameServer = server.create(2)
  first = gameServer.clients[0]
  second = gameServer.clients[1]
  first.active = true
  second.active = true
  first.oldFrags = 0
  second.oldFrags = 0
  msg.writeByte(gameServer.reliableDatagram, c.SVC_SETPAUSE)
  msg.writeByte(gameServer.reliableDatagram, 1)

  prepared = server.prepareReliableMessages(gameServer)
  assertEqual(prepared[0], 0, "no fragment changes")
  assertEqual(prepared[1], 2, "reliable datagram copied to both active clients")
  assertHex(first.message, "1801", "first reliable payload")
  assertHex(second.message, "1801", "second reliable payload")
  assertEqual(gameServer.reliableDatagram.curSize, 0, "reliable broadcast cleared")

  worldEntity = edict.create(0)
  flashed = edict.create(1)
  flashed.effects = c.EF_MUZZLEFLASH | 8
  unchanged = edict.create(2)
  unchanged.effects = 4
  gameServer.edicts = [worldEntity, flashed, unchanged]
  gameServer.numEdicts = 3
  assertEqual(server.cleanupMuzzleFlashes(gameServer), 1, "one muzzle flash cleared")
  assertEqual(flashed.effects, 8, "non-muzzle effect retained")
  assertEqual(unchanged.effects, 4, "unrelated effect unchanged")
  return true
end function

// Verify server buffer and sound cutoff against the expected Quake behavior.
function testServerBufferAndSoundCutoff()
  gameServer = server.create(1)
  assertEqual(gameServer.datagram.maxSize, c.MAX_DATAGRAM, "server datagram size")
  assertFalse(gameServer.datagram.allowOverflow, "server datagram is fatal-on-overflow")
  assertEqual(gameServer.reliableDatagram.maxSize, c.MAX_DATAGRAM, "reliable broadcast size")
  assertFalse(gameServer.reliableDatagram.allowOverflow, "reliable datagram is fatal-on-overflow")
  assertEqual(gameServer.clients[0].message.maxSize, c.MAX_MSGLEN, "client reliable message size")
  assertTrue(gameServer.clients[0].message.allowOverflow, "client reliable message catches overflow")

  source = edict.create(0)
  source.origin = t.Vec3(10.0, -20.0, 30.0)
  gameServer.edicts = [source]
  gameServer.numEdicts = 1
  gameServer.soundPrecache = ["", "misc/test.wav"]

  sz.writeBytes(gameServer.datagram, bytes(c.MAX_DATAGRAM - 15, 0))
  before = gameServer.datagram.curSize
  assertFalse(server.writeQueuedSound(gameServer, [0, 2, "misc/test.wav", 255, 1.0]), "sound skipped above MAX_DATAGRAM-16")
  assertEqual(gameServer.datagram.curSize, before, "skipped sound leaves datagram unchanged")

  sz.clear(gameServer.datagram)
  sz.writeBytes(gameServer.datagram, bytes(c.MAX_DATAGRAM - 16, 0))
  assertTrue(server.writeQueuedSound(gameServer, [0, 2, "misc/test.wav", 255, 1.0]), "sound accepted at exact cutoff")
  assertEqual(gameServer.datagram.curSize, c.MAX_DATAGRAM - 5, "default sound adds eleven bytes")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake BP-012R1 Protocol 15 server-data tests"
  passed = 0
  if runTest("01", "exact cooperative serverinfo", testServerInfoCoop) then passed = passed + 1 end if
  if runTest("02", "production deathmatch serverinfo", testProductionServerInfo) then passed = passed + 1 end if
  if runTest("03", "sound payload vectors", testSoundVectors) then passed = passed + 1 end if
  if runTest("04", "production sound path", testProductionSound) then passed = passed + 1 end if
  if runTest("05", "minimal clientdata", testClientDataMinimal) then passed = passed + 1 end if
  if runTest("06", "full stock clientdata and byte wrapping", testClientDataFullStandard) then passed = passed + 1 end if
  if runTest("07", "mission-pack active weapon encoding", testClientDataMissionPack) then passed = passed + 1 end if
  if runTest("08", "baseline payload vectors", testBaselineVectors) then passed = passed + 1 end if
  if runTest("09", "production baseline selection", testProductionBaselineSelection) then passed = passed + 1 end if
  if runTest("10", "strict datagram boundary", testStrictDatagramBoundary) then passed = passed + 1 end if
  if runTest("11", "fast-update packet planner", testFastUpdatePlanner) then passed = passed + 1 end if
  if runTest("12", "client delivery planning", testDeliveryPlans) then passed = passed + 1 end if
  if runTest("13", "integrated clientdata writer", testIntegratedClientDataWrapper) then passed = passed + 1 end if
  if runTest("14", "sv_main clientdata writer", testSvMainClientDataWrapper) then passed = passed + 1 end if
  if runTest("15", "reliable distribution and muzzle cleanup", testReliableDistributionAndCleanup) then passed = passed + 1 end if
  if runTest("16", "server buffers and sound cutoff", testServerBufferAndSoundCutoff) then passed = passed + 1 end if
  if runTest("17", "PlayerState ground-flag adapters", testPlayerGroundFlagMirror) then passed = passed + 1 end if
  if runTest("18", "sv_main BSP boundary parity", testSvMainBspBoundaryParity) then passed = passed + 1 end if

  if passed != 18 then
    print "MiniQuake BP-012R1 Protocol 15 server-data tests failed: " + passed + "/18"
    return 1
  end if
  print "MiniQuake BP-012R1 Protocol 15 server-data tests passed: 18"
  return 0
end function
