/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-013 byte-exact Protocol-15 static-entity, static-sound, particle,
scoreboard and graceful-disconnect fixtures. The wire streams are reproduced
independently by tools/oracle/protocol15_events_oracle.c and
 tools/check_protocol15_events.py.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_events as events
import miniquake.protocol_serverdata as serverData
import miniquake.client_protocol as protocol
import miniquake.server as server
import miniquake.sv_main as svmain
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.player_move as movement

function assertEqual(actual, expected, name)
  if actual != expected then return error(9600, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9601, name + ": expected true") end if
  return true
end function

function assertFalse(value, name)
  if value != false then return error(9602, name + ": expected false") end if
  return true
end function

function assertHex(buffer, expected, name)
  return assertEqual(hex(sz.dataSlice(buffer)), expected, name)
end function

function runTest(number, name, fn)
  print "  [" + number + "/22] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

function basicBaseline()
  return t.EntityBaseline(
    1,
    2,
    3,
    4,
    0,
    t.Vec3(-12.25, 0.125, 4095.875),
    t.Vec3(90.75, -90.9, 359.9),
  )
end function

function testStaticEntityBasic()
  buffer = sz.alloc(64)
  assertEqual(events.writeStaticEntity(buffer, basicBaseline()), 14, "static length")
  assertHex(buffer, "14010203049eff400100c0ff7fff", "static_entity_basic")
  return true
end function

function testStaticEntityWrapped()
  buffer = sz.alloc(64)
  value = t.EntityBaseline(
    300,
    -1,
    257,
    511,
    0,
    t.Vec3(10.0, -20.0, 30.0),
    t.Vec3(0.0, 45.0, 90.0),
  )
  events.writeStaticEntity(buffer, value)
  assertHex(buffer, "142cff01ff50000060ff20f00040", "static_entity_wrapped")
  return true
end function

function testStaticEntityRoundTrip()
  buffer = sz.alloc(64)
  events.writeStaticEntity(buffer, basicBaseline())
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "static event count")
  assertEqual(parsed.events[0].command, "svc_spawnstatic", "static command")
  payload = parsed.events[0].payload
  assertEqual(payload[0], 1, "static model")
  assertEqual(payload[1], 2, "static frame")
  assertEqual(payload[2], 3, "static colormap")
  assertEqual(payload[3], 4, "static skin")
  assertEqual(payload[4].x, -12.25, "static origin")
  assertEqual(payload[5].x, 90.0, "static angle quantization")
  return true
end function

function testStaticSoundVectors()
  basic = sz.alloc(64)
  events.writeStaticSound(basic, t.Vec3(10.0, -20.0, 30.0), 5, 0.5, 1.25)
  assertHex(basic, "1d500060fff000057f50", "static_sound_basic")

  wrapped = sz.alloc(64)
  events.writeStaticSound(wrapped, t.Vec3(-12.25, 0.125, 4095.875), 300, 1.25, 4.5)
  assertHex(wrapped, "1d9eff0100ff7f2c3e20", "static_sound_wrapped")
  return true
end function

function testStaticSoundRoundTrip()
  buffer = sz.alloc(64)
  events.writeStaticSound(buffer, t.Vec3(10.0, -20.0, 30.0), 5, 0.5, 1.25)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "static sound event count")
  assertEqual(parsed.events[0].command, "svc_spawnstaticsound", "static sound command")
  payload = parsed.events[0].payload
  assertEqual(payload[0].x, 10.0, "static sound origin")
  assertEqual(payload[1], 5, "static sound index")
  assertEqual(payload[2], 127, "static sound volume")
  assertEqual(payload[3], 80, "static sound attenuation")
  return true
end function

function testParticleBasic()
  buffer = sz.alloc(64)
  events.writeParticle(
    buffer,
    t.Vec3(10.0, -20.0, 30.0),
    t.Vec3(1.0, -2.0, 0.0625),
    20,
    7,
  )
  assertHex(buffer, "12500060fff00010e0011407", "particle_basic")
  return true
end function

function testParticleClamp()
  buffer = sz.alloc(64)
  events.writeParticle(
    buffer,
    t.Vec3(-12.25, 0.125, 4095.875),
    t.Vec3(100.0, -100.0, -7.999),
    255,
    300,
  )
  assertHex(buffer, "129eff0100ff7f7f8081ff2c", "particle_clamped")
  assertEqual(events.particleDirectionByte(100.0), 127, "particle high clamp")
  assertEqual(events.particleDirectionByte(-100.0), -128, "particle low clamp")
  return true
end function

function testParticleExplosionCount()
  buffer = sz.alloc(64)
  events.writeParticle(
    buffer,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    255,
    4,
  )
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(parsed.events[0].payload[2], 1024, "wire 255 particle expansion")
  assertEqual(events.particleCount(0), 0, "zero particle count")
  assertEqual(events.particleCount(254), 254, "normal particle count")
  return true
end function

function testProductionParticle()
  state = svmain.SV_Init(1)
  sz.clear(state.server.datagram)
  accepted = svmain.SV_StartParticle(
    state,
    t.Vec3(10.0, -20.0, 30.0),
    t.Vec3(1.0, -2.0, 0.0625),
    7,
    20,
  )
  assertTrue(accepted, "SV_StartParticle accepted")
  assertHex(state.server.datagram, "12500060fff00010e0011407", "production particle")
  return true
end function

function testParticleDatagramBoundary()
  state = svmain.SV_Init(1)
  state.server.datagram.curSize = c.MAX_DATAGRAM - 16
  assertTrue(
    svmain.SV_StartParticle(
      state,
      t.Vec3(0.0, 0.0, 0.0),
      t.Vec3(0.0, 0.0, 0.0),
      0,
      0,
    ),
    "exact margin accepted",
  )
  state.server.datagram.curSize = c.MAX_DATAGRAM - 15
  assertFalse(
    svmain.SV_StartParticle(
      state,
      t.Vec3(0.0, 0.0, 0.0),
      t.Vec3(0.0, 0.0, 0.0),
      0,
      0,
    ),
    "above margin rejected",
  )
  return true
end function

function testIntegratedQueuedParticle()
  value = server.create(1)
  sz.clear(value.datagram)
  accepted = server.writeQueuedParticle(
    value,
    [t.Vec3(10.0, -20.0, 30.0), t.Vec3(1.0, -2.0, 0.0625), 20, 7],
  )
  assertTrue(accepted, "queued particle accepted")
  assertHex(value.datagram, "12500060fff00010e0011407", "queued particle shared writer")
  return true
end function

function testScoreVectors()
  buffer = sz.alloc(128)
  events.writeUpdateName(buffer, 2, "Ranger")
  assertHex(buffer, "0d0252616e67657200", "update_name_ascii")

  sz.clear(buffer)
  events.writeUpdateFrags(buffer, 3, -123)
  assertHex(buffer, "0e0385ff", "update_frags_negative")

  sz.clear(buffer)
  events.writeUpdateFrags(buffer, 255, 40000)
  assertHex(buffer, "0eff409c", "update_frags_wrapped")

  sz.clear(buffer)
  events.writeUpdateColors(buffer, 4, 0xde)
  assertHex(buffer, "1104de", "update_colors")

  sz.clear(buffer)
  events.writeScoreReset(buffer, 5)
  assertHex(buffer, "0d05000e050000110500", "score_reset")
  return true
end function

function testLatin1NameAndTruncation()
  buffer = sz.alloc(64)
  events.writeUpdateName(buffer, 1, "José")
  assertHex(buffer, "0d014a6f73e900", "update_name_latin1")
  assertEqual(events.truncatePlayerName("12345678901234éX"), "12345678901234é", "one-byte name truncation")
  return true
end function

function testIntegratedNameAndColor()
  value = server.create(1)
  clientValue = value.clients[0]
  clientValue.active = true
  sz.clear(value.reliableDatagram)
  server.setClientName(value, clientValue, "12345678901234éX")
  server.setClientColors(value, clientValue, 4, 13)
  assertHex(value.reliableDatagram, "0d003132333435363738393031323334e90011004d", "integrated name/color")
  return true
end function

function testIntegratedFragFanout()
  value = server.create(2)
  value.clients[0].active = true
  value.clients[1].active = true
  value.clients[0].oldFrags = -1
  value.clients[1].oldFrags = 0
  sz.clear(value.clients[0].message)
  sz.clear(value.clients[1].message)
  assertEqual(server.updateReliableClientState(value), 1, "integrated frag changes")
  assertHex(value.clients[0].message, "0e000000", "frag fanout destination 0")
  assertHex(value.clients[1].message, "0e000000", "frag fanout destination 1")
  return true
end function

function testDirectFractionalFragFanout()
  state = svmain.SV_Init(2)
  state.server.clients[0].active = true
  state.server.clients[1].active = true
  state.server.clients[0].oldFrags = 42
  state.server.clients[1].oldFrags = 0
  svmain.SV_SetClientFrags(state, 0, 42.75)

  sz.clear(state.server.clients[0].message)
  sz.clear(state.server.clients[1].message)
  assertEqual(svmain.SV_UpdateToReliableMessages(state), 1, "first fractional frag change")
  assertHex(state.server.clients[0].message, "0e002a00", "fractional fanout destination 0")
  assertHex(state.server.clients[1].message, "0e002a00", "fractional fanout destination 1")
  assertEqual(state.server.clients[0].oldFrags, 42, "stored client_t old_frags")

  sz.clear(state.server.clients[0].message)
  sz.clear(state.server.clients[1].message)
  assertEqual(svmain.SV_UpdateToReliableMessages(state), 1, "fractional value rebroadcasts")
  assertHex(state.server.clients[1].message, "0e002a00", "fractional repeat payload")
  assertFalse(events.fragChanged(16777217, 16777216.0), "C int-to-float comparison boundary")
  return true
end function

function testSpawnUsesOldFrags()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  wireClient = netmain.NET_Connect(network, "local", 1)
  wireServer = netmain.NET_CheckNewConnections(network)
  assertTrue(wireClient is not void and wireServer is not void, "spawn loop connection")

  value = server.create(2)
  target = value.clients[0]
  target.active = true
  target.name = "target"
  target.oldFrags = 7
  target.colors = 0x21
  target.socket = wireServer
  other = value.clients[1]
  other.active = true
  other.name = "other"
  other.oldFrags = 73
  other.colors = 0x4d
  player = movement.createPlayer(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))

  assertTrue(server.writeSpawn(value, target, player) > 0, "Host_Spawn_f queues wire data")
  assertTrue(target.sendSignon, "Host_Spawn_f marks sendsignon")
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(wireClient, incoming, 1.0), 0, "Host_Spawn_f does not send inside command parser")
  assertEqual(server.sendReliableMessagesAt(value, 1.0), 1, "Host_Spawn_f reliable phase")
  assertEqual(netmain.NET_GetMessage(wireClient, incoming, 1.0), 1, "Host_Spawn_f packet receive")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.SVC_TIME, "spawn time opcode")
  msg.readFloat(reader)

  assertEqual(msg.readByte(reader), c.SVC_UPDATENAME, "score zero name opcode")
  assertEqual(msg.readByte(reader), 0, "score zero index")
  assertEqual(msg.readString(reader), "target", "score zero name")
  assertEqual(msg.readByte(reader), c.SVC_UPDATEFRAGS, "score zero frags opcode")
  assertEqual(msg.readByte(reader), 0, "score zero frags index")
  assertEqual(msg.readShort(reader), 7, "score zero old_frags")
  assertEqual(msg.readByte(reader), c.SVC_UPDATECOLORS, "score zero colors opcode")
  assertEqual(msg.readByte(reader), 0, "score zero colors index")
  assertEqual(msg.readByte(reader), 0x21, "score zero colors")

  assertEqual(msg.readByte(reader), c.SVC_UPDATENAME, "score one name opcode")
  assertEqual(msg.readByte(reader), 1, "score one index")
  assertEqual(msg.readString(reader), "other", "score one name")
  assertEqual(msg.readByte(reader), c.SVC_UPDATEFRAGS, "score one frags opcode")
  assertEqual(msg.readByte(reader), 1, "score one frags index")
  assertEqual(msg.readShort(reader), 73, "Host_Spawn_f uses client.old_frags")

  netmain.NET_Close(wireServer)
  netmain.NET_Close(wireClient)
  netmain.NET_Shutdown(network)
  return true
end function

function testReliableDistributionAndOverflow()
  value = server.create(2)
  value.clients[0].active = true
  value.clients[1].active = true
  sz.clear(value.clients[0].message)
  sz.clear(value.clients[1].message)
  sz.clear(value.reliableDatagram)
  events.writeUpdateColors(value.reliableDatagram, 1, 0x4d)
  assertEqual(server.distributeReliableDatagram(value), 2, "broadcast copy count")
  assertHex(value.clients[0].message, "11014d", "reliable destination zero")
  assertHex(value.clients[1].message, "11014d", "reliable destination one")
  assertEqual(value.reliableDatagram.curSize, 0, "reliable datagram cleared")

  sz.clear(value.clients[0].message)
  value.clients[0].message.overflowed = false
  sz.write(value.clients[0].message, bytes(c.MAX_MSGLEN, 0xaa), 0, c.MAX_MSGLEN)
  sz.clear(value.reliableDatagram)
  events.writeDisconnect(value.reliableDatagram)
  server.distributeReliableDatagram(value)
  assertTrue(value.clients[0].message.overflowed, "client reliable overflow marked")
  assertHex(value.clients[0].message, "02", "overflow restarts with broadcast payload")
  return true
end function

function testIntegratedGracefulDrop()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  wireClient = netmain.NET_Connect(network, "local", 1)
  wireServer = netmain.NET_CheckNewConnections(network)
  assertTrue(wireClient is not void and wireServer is not void, "drop loop connection")
  netmain.NET_ConnectionAccepted()

  value = server.create(2)
  dropped = value.clients[0]
  peer = value.clients[1]
  dropped.active = true
  dropped.spawned = false
  dropped.name = "dropme"
  dropped.socket = wireServer
  peer.active = true
  sz.clear(dropped.message)
  sz.clear(peer.message)
  msg.writeByte(dropped.message, c.SVC_PRINT)
  msg.writeString(dropped.message, "bye\n")

  assertTrue(server.dropClient(value, dropped, false), "integrated graceful drop")
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(wireClient, incoming, 1.0), 1, "graceful final reliable")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.SVC_PRINT, "pending reliable precedes disconnect")
  assertEqual(msg.readString(reader), "bye\n", "pending reliable text")
  assertEqual(msg.readByte(reader), c.SVC_DISCONNECT, "appended disconnect opcode")
  assertHex(peer.message, "0d00000e000000110000", "integrated peer score reset")
  assertFalse(dropped.active, "integrated dropped inactive")
  assertEqual(dropped.name, "", "integrated dropped name")
  assertEqual(dropped.oldFrags, -999999, "integrated dropped old frags")

  netmain.NET_Close(wireClient)
  netmain.NET_Shutdown(network)
  return true
end function

function testDirectGracefulDrop()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  wireClient = netmain.NET_Connect(network, "local", 1)
  wireServer = netmain.NET_CheckNewConnections(network)
  assertTrue(wireClient is not void and wireServer is not void, "direct drop loop connection")
  netmain.NET_ConnectionAccepted()

  state = svmain.SV_Init(2)
  dropped = state.server.clients[0]
  peer = state.server.clients[1]
  dropped.active = true
  dropped.spawned = false
  dropped.name = "dropme"
  dropped.socket = wireServer
  peer.active = true
  sz.clear(dropped.message)
  sz.clear(peer.message)
  msg.writeByte(dropped.message, c.SVC_PRINT)
  msg.writeString(dropped.message, "direct\n")

  assertTrue(svmain.SV_DropClient(state, dropped, false), "direct graceful drop")
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(wireClient, incoming, 1.0), 1, "direct final reliable")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.SVC_PRINT, "direct pending reliable")
  assertEqual(msg.readString(reader), "direct\n", "direct pending text")
  assertEqual(msg.readByte(reader), c.SVC_DISCONNECT, "direct appended disconnect")
  assertHex(peer.message, "0d00000e000000110000", "direct peer score reset")
  assertFalse(dropped.active, "direct dropped inactive")
  assertEqual(dropped.oldFrags, -999999, "direct dropped old frags")

  netmain.NET_Close(wireClient)
  netmain.NET_Shutdown(network)
  return true
end function

function testBlockedAndCrashDrop()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  wireClient = netmain.NET_Connect(network, "local", 1)
  wireServer = netmain.NET_CheckNewConnections(network)
  assertTrue(wireClient is not void and wireServer is not void, "blocked drop loop connection")
  netmain.NET_ConnectionAccepted()
  wireServer.canSend = false

  value = server.create(2)
  dropped = value.clients[0]
  peer = value.clients[1]
  dropped.active = true
  dropped.socket = wireServer
  peer.active = true
  msg.writeByte(dropped.message, c.SVC_PRINT)
  msg.writeString(dropped.message, "blocked\n")
  assertTrue(server.dropClient(value, dropped, false), "blocked graceful drop completes")
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(wireClient, incoming, 1.0), 0, "blocked drop sends no signoff")
  assertHex(peer.message, "0d00000e000000110000", "blocked drop still resets score")
  netmain.NET_Close(wireClient)
  netmain.NET_Shutdown(network)

  crashState = svmain.SV_Init(2)
  crashState.server.clients[0].active = true
  crashState.server.clients[1].active = true
  sz.clear(crashState.server.clients[1].message)
  assertTrue(svmain.SV_DropClient(crashState, crashState.server.clients[0], true), "crash drop")
  assertHex(crashState.server.clients[1].message, "0d00000e000000110000", "crash drop score reset")
  return true
end function

function testReliableDeliveryBoundaries()
  assertEqual(
    serverData.reliableDeliveryPlan(true, 0, false, false),
    serverData.RELIABLE_DROP_OVERFLOW,
    "overflow drop",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 0, false, false),
    serverData.RELIABLE_NONE,
    "empty reliable",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 1, false, false),
    serverData.RELIABLE_WAIT,
    "reliable wait",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 0, true, false),
    serverData.RELIABLE_WAIT,
    "dropasap waits until sendable",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 0, true, true),
    serverData.RELIABLE_DROP_ASAP,
    "dropasap",
  )
  assertEqual(
    serverData.reliableDeliveryPlan(false, 1, false, true),
    serverData.RELIABLE_SEND,
    "reliable send",
  )
  return true
end function

passed = 0
if runTest("01", "svc_spawnstatic basic", testStaticEntityBasic) then passed = passed + 1 end if
if runTest("02", "svc_spawnstatic wrapping", testStaticEntityWrapped) then passed = passed + 1 end if
if runTest("03", "svc_spawnstatic parser roundtrip", testStaticEntityRoundTrip) then passed = passed + 1 end if
if runTest("04", "svc_spawnstaticsound vectors", testStaticSoundVectors) then passed = passed + 1 end if
if runTest("05", "svc_spawnstaticsound parser roundtrip", testStaticSoundRoundTrip) then passed = passed + 1 end if
if runTest("06", "svc_particle basic", testParticleBasic) then passed = passed + 1 end if
if runTest("07", "svc_particle clamp and wrapping", testParticleClamp) then passed = passed + 1 end if
if runTest("08", "svc_particle count 255 expansion", testParticleExplosionCount) then passed = passed + 1 end if
if runTest("09", "direct SV_StartParticle", testProductionParticle) then passed = passed + 1 end if
if runTest("10", "particle MAX_DATAGRAM-16 gate", testParticleDatagramBoundary) then passed = passed + 1 end if
if runTest("11", "integrated queued particle", testIntegratedQueuedParticle) then passed = passed + 1 end if
if runTest("12", "scoreboard update vectors", testScoreVectors) then passed = passed + 1 end if
if runTest("13", "Latin-1 name and byte truncation", testLatin1NameAndTruncation) then passed = passed + 1 end if
if runTest("14", "integrated name/color production", testIntegratedNameAndColor) then passed = passed + 1 end if
if runTest("15", "integrated frag fanout", testIntegratedFragFanout) then passed = passed + 1 end if
if runTest("16", "direct fractional frag fanout", testDirectFractionalFragFanout) then passed = passed + 1 end if
if runTest("17", "Host_Spawn_f uses old_frags", testSpawnUsesOldFrags) then passed = passed + 1 end if
if runTest("18", "reliable distribution and overflow", testReliableDistributionAndOverflow) then passed = passed + 1 end if
if runTest("19", "integrated graceful drop", testIntegratedGracefulDrop) then passed = passed + 1 end if
if runTest("20", "direct sv_main graceful drop", testDirectGracefulDrop) then passed = passed + 1 end if
if runTest("21", "blocked and crash drop", testBlockedAndCrashDrop) then passed = passed + 1 end if
if runTest("22", "reliable delivery boundaries", testReliableDeliveryBoundaries) then passed = passed + 1 end if

if passed != 22 then
  print "MiniQuake BP-013 Protocol 15 event tests failed: " + passed + "/22"
  error(9699, "BP-013 Protocol 15 event fixtures failed")
end if
print "MiniQuake BP-013 Protocol 15 event tests passed: 22"
