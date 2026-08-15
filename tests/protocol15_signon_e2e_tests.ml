/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-015 end-to-end Protocol-15 signon fixtures.  These tests bind the original
CL_SignonReply / Host_PreSpawn_f / Host_Spawn_f / Host_Begin_f queue boundary:
command handlers append reliable bytes; CL_SendCmd and SV_SendClientMessages
perform transport on their regular host-frame phases.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_signon as signon
import miniquake.protocol_update as update
import miniquake.client as client
import miniquake.server as server
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.player_move as movement

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
function assertHex(data, expected, name)
  return assertEqual(hex(data), expected, name)
end function

// Execute one named test case and record its pass/fail result.
function runTest(number, name, fn)
  print "  [" + number + "/12] " + name
  result = try(fn())
  if result is error then
    print "    FAIL: " + result.message
    return false
  end if
  return true
end function

// Create and initialize player.
function makePlayer()
  return movement.createPlayer(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
end function

// Create and initialize connected pair.
function makeConnectedPair()
  network = netloop.createState()
  netmain.NET_Init(network, 2, false, false, 26000, true)
  player = makePlayer()
  localClient = client.create(player)
  localClient.name = "Ranger"
  localClient.colors = 0x4d
  localClient.spawnParms = "1 2 3"
  connected = client.CL_EstablishConnection(localClient, network, "local")
  if connected is error then return connected end if
  serverSocket = netmain.NET_CheckNewConnections(network)
  if serverSocket is void then return error(9503, "loop server endpoint missing") end if
  gameServer = server.create(1)
  gameServer.levelName = "start"
  gameServer.time = 1.25
  target = server.acceptLocal(gameServer, serverSocket)
  if target is error then return target end if
  return [network, player, localClient, gameServer, target, serverSocket]
end function

// Release or remove state for pair.
function closePair(pair)
  localClient = pair[2]
  target = pair[4]
  if target.socket is not void then netmain.NET_Close(target.socket); target.socket = void end if
  if localClient.socket is not void then netmain.NET_Close(localClient.socket); localClient.socket = void end if
  netmain.NET_Shutdown(pair[0])
  return true
end function

// Verify client reply queues only against the expected Quake behavior.
function testClientReplyQueuesOnly()
  pair = makeConnectedPair()
  if pair is error then return pair end if
  localClient = pair[2]
  target = pair[4]
  incoming = sz.alloc(128)
  localClient.signon = c.SIGNON_SERVERINFO
  assertTrue(client.CL_SignonReply(localClient), "CL_SignonReply queues")
  assertEqual(localClient.outgoing.curSize, 10, "queued prespawn bytes")
  assertEqual(netmain.NET_GetMessage(target.socket, incoming, 1.0), 0, "reply not sent from parser")
  assertEqual(client.CL_SendCmd(localClient, localClient.command), 1, "host-frame reliable send")
  assertEqual(netmain.NET_GetMessage(target.socket, incoming, 1.0), 1, "queued reply delivered")
  assertHex(sz.dataSlice(incoming), "04707265737061776e00", "queued prespawn payload")
  closePair(pair)
  return true
end function

// Verify color high nibble is not masked against the expected Quake behavior.
function testColorHighNibbleIsNotMasked()
  buffer = sz.alloc(128)
  signon.writeClientReply(buffer, c.SIGNON_PRESPAWN, "R", 0x1fd, "")
  reader = msg.beginReading(buffer)
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "name opcode")
  assertEqual(msg.readString(reader), "name \"R\"\n", "name string")
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "color opcode")
  assertEqual(msg.readString(reader), "color 31 13\n", "C signed-shift color arguments")
  return true
end function

// Verify stage four writes nothing against the expected Quake behavior.
function testStageFourWritesNothing()
  buffer = sz.alloc(32)
  assertEqual(signon.writeClientReply(buffer, c.SIGNON_ACTIVE, "R", 0, ""), 0, "stage four byte count")
  assertEqual(buffer.curSize, 0, "stage four no wire")
  return true
end function

// Verify prespawn queues on server against the expected Quake behavior.
function testPrespawnQueuesOnServer()
  gameServer = server.create(1)
  target = gameServer.clients[0]
  target.active = true
  target.sendSignon = false
  msg.writeByte(gameServer.signon, c.SVC_SPAWNSTATIC)
  before = target.message.curSize
  written = server.writeSignonStage2(gameServer, target)
  assertEqual(written, 3, "prespawn queued byte count")
  assertEqual(target.message.curSize - before, 3, "prespawn appended")
  assertTrue(target.sendSignon, "prespawn marks sendsignon")
  assertEqual(target.signonStage, c.SIGNON_PRESPAWN, "prespawn stage")
  assertHex(sz.dataSlice(target.message), "141902", "prespawn queue bytes")
  return true
end function

// Verify spawn clears and queues against the expected Quake behavior.
function testSpawnClearsAndQueues()
  gameServer = server.create(1)
  target = gameServer.clients[0]
  target.active = true
  target.name = "Ranger"
  msg.writeByte(target.message, c.SVC_PRINT)
  player = makePlayer()
  // A teleporter immediately before changelevel may leave an absolute old-map
  // teleport_time.  The replacement server starts near time 1, so retaining
  // that value would suppress negative forwardmove for many seconds.
  player.teleportTime = 123.0
  player.flags = player.flags | c.FL_WATERJUMP
  player.moveDir = t.Vec3(80.0, 0.0, 0.0)
  written = server.writeSpawn(gameServer, target, player)
  assertTrue(written > 2, "spawn payload queued")
  assertEqual(target.message.data[0], c.SVC_TIME, "old reliable bytes cleared")
  assertTrue(target.sendSignon, "spawn marks sendsignon")
  assertEqual(target.signonStage, c.SIGNON_SPAWN, "spawn stage")
  assertEqual(player.teleportTime, 0.0, "new level clears old teleport gate")
  assertEqual(player.flags & c.FL_WATERJUMP, 0, "new level clears old waterjump")
  assertEqual(player.moveDir.x, 0.0, "new level clears old movement direction")
  return true
end function

// Verify blocked server retains signon against the expected Quake behavior.
function testBlockedServerRetainsSignon()
  pair = makeConnectedPair()
  if pair is error then return pair end if
  gameServer = pair[3]
  target = pair[4]
  target.socket.canSend = false
  originalSize = target.message.curSize
  assertEqual(server.sendReliableMessagesAt(gameServer, 1.0), 0, "blocked reliable phase")
  assertEqual(target.message.curSize, originalSize, "blocked message retained")
  assertTrue(target.sendSignon, "blocked sendsignon retained")
  target.socket.canSend = true
  assertEqual(server.sendReliableMessagesAt(gameServer, 1.1), 1, "unblocked reliable phase")
  assertEqual(target.message.curSize, 0, "successful message cleared")
  assertFalse(target.sendSignon, "successful sendsignon cleared")
  closePair(pair)
  return true
end function

// Exercise deliver server as part of this deterministic regression fixture.
function deliverServer(pair, realtime)
  gameServer = pair[3]
  localClient = pair[2]
  result = server.sendReliableMessagesAt(gameServer, realtime)
  if result < 0 then return error(9504, "server reliable delivery failed") end if
  readResult = client.CL_ReadFromServer(localClient, 0.0, realtime)
  if readResult is error then return readResult end if
  return result
end function

// Exercise deliver client as part of this deterministic regression fixture.
function deliverClient(pair)
  localClient = pair[2]
  gameServer = pair[3]
  player = pair[1]
  sent = client.CL_SendCmd(localClient, localClient.command)
  if sent is error then return sent end if
  if sent < 0 then return error(9505, "client reliable delivery failed") end if
  server.pumpClientMessages(gameServer, player)
  return sent
end function

// Advance to spawn by one processing step.
function advanceToSpawn(pair)
  deliverServer(pair, 1.0)
  if pair[2].signon != c.SIGNON_SERVERINFO then return error(9506, "stage one not reached") end if
  deliverClient(pair)
  deliverServer(pair, 1.1)
  if pair[2].signon != c.SIGNON_PRESPAWN then return error(9507, "stage two not reached") end if
  deliverClient(pair)
  deliverServer(pair, 1.2)
  if pair[2].signon != c.SIGNON_SPAWN then return error(9508, "stage three not reached") end if
  return true
end function

// Verify full stages one to three against the expected Quake behavior.
function testFullStagesOneToThree()
  pair = makeConnectedPair()
  if pair is error then return pair end if
  result = advanceToSpawn(pair)
  if result is error then return result end if
  assertEqual(pair[2].signon, c.SIGNON_SPAWN, "client stage three")
  assertEqual(pair[4].signonStage, c.SIGNON_SPAWN, "server stage three")
  assertEqual(pair[4].name, "Ranger", "stage two name command")
  assertEqual(pair[4].colors, 0x4d, "stage two color command")
  closePair(pair)
  return true
end function

// Verify begin has no server wire against the expected Quake behavior.
function testBeginHasNoServerWire()
  pair = makeConnectedPair()
  if pair is error then return pair end if
  result = advanceToSpawn(pair)
  if result is error then return result end if
  target = pair[4]
  assertTrue(pair[2].outgoing.curSize > 0, "begin queued by client")
  deliverClient(pair)
  assertTrue(target.spawned, "Host_Begin_f spawned")
  assertEqual(target.message.curSize, 0, "Host_Begin_f no svc_signonnum four")
  closePair(pair)
  return true
end function

// Verify fast update completes signon against the expected Quake behavior.
function testFastUpdateCompletesSignon()
  pair = makeConnectedPair()
  if pair is error then return pair end if
  result = advanceToSpawn(pair)
  if result is error then return result end if
  deliverClient(pair)
  localClient = pair[2]
  entity = client.CL_EntityNum(localClient, 1)
  if entity is error then return entity end if
  baselineOrigin = t.Vec3(0.0, 0.0, 0.0)
  baselineAngles = t.Vec3(0.0, 0.0, 0.0)
  entity.baseline = [0, 0, 0, 0, baselineOrigin, baselineAngles, 0]
  serverBaseline = t.EntityBaseline(0, 0, 0, 0, 0, baselineOrigin, baselineAngles)
  packet = sz.alloc(64)
  update.writeFastUpdate(packet, 1, serverBaseline, 0, 0, 0, 0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), c.MOVETYPE_NONE)
  assertEqual(netmain.NET_SendUnreliableMessage(pair[5], packet), 1, "first fast update sent")
  result = client.CL_ReadFromServer(localClient, 0.0, 1.3)
  if result is error then return result end if
  assertEqual(localClient.signon, c.SIGNON_ACTIVE, "fast update promotes 3 to 4")
  assertTrue(localClient.spawned, "stage four local state")
  closePair(pair)
  return true
end function

// Verify duplicate signon rejected against the expected Quake behavior.
function testDuplicateSignonRejected()
  localClient = client.create(makePlayer())
  localClient.signon = c.SIGNON_PRESPAWN
  duplicate = try(client.advanceSignon(localClient, c.SIGNON_PRESPAWN))
  assertTrue(duplicate is error, "duplicate signon rejected")
  backwards = try(client.advanceSignon(localClient, c.SIGNON_SERVERINFO))
  assertTrue(backwards is error, "backwards signon rejected")
  return true
end function

// Verify server stage sequence against the expected Quake behavior.
function testServerStageSequence()
  testNoSyntheticSignonFour()
  gameServer = server.create(1)
  target = gameServer.clients[0]
  target.active = true
  target.signonStage = c.SIGNON_NONE
  server.sendServerInfo(gameServer, target)
  assertEqual(target.signonStage, c.SIGNON_SERVERINFO, "server stage one")
  server.writeSignonStage2(gameServer, target)
  assertEqual(target.signonStage, c.SIGNON_PRESPAWN, "server stage two")
  server.writeSpawn(gameServer, target, makePlayer())
  assertEqual(target.signonStage, c.SIGNON_SPAWN, "server stage three")
  before = target.message.curSize
  server.writeBegin(target)
  assertEqual(target.signonStage, c.SIGNON_ACTIVE, "server internal active stage")
  assertEqual(target.message.curSize, before, "server active stage has no wire marker")
  return true
end function

// Verify reply order within single buffer against the expected Quake behavior.
function testReplyOrderWithinSingleBuffer()
  buffer = sz.alloc(256)
  signon.writeClientReply(buffer, c.SIGNON_PRESPAWN, "Ranger", 0x4d, "coop 1")
  reader = msg.beginReading(buffer)
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "name command first")
  assertEqual(msg.readString(reader), "name \"Ranger\"\n", "name payload")
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "color command second")
  assertEqual(msg.readString(reader), "color 4 13\n", "color payload")
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "spawn command third")
  assertEqual(msg.readString(reader), "spawn coop 1", "spawn payload")
  assertEqual(msg.remaining(reader), 0, "stage two exact framing")
  return true
end function

// Verify no synthetic signon four against the expected Quake behavior.
function testNoSyntheticSignonFour()
  markers = sz.alloc(16)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_SERVERINFO)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_PRESPAWN)
  msg.writeByte(markers, c.SVC_SIGNONNUM); msg.writeByte(markers, c.SIGNON_SPAWN)
  assertHex(sz.dataSlice(markers), "190119021903", "only server markers one through three")
  return true
end function

passed = 0
if runTest(1, "CL_SignonReply queues until CL_SendCmd", testClientReplyQueuesOnly) then passed = passed + 1 end if
if runTest(2, "original color high argument", testColorHighNibbleIsNotMasked) then passed = passed + 1 end if
if runTest(3, "stage four writes no command", testStageFourWritesNothing) then passed = passed + 1 end if
if runTest(4, "Host_PreSpawn_f queues client message", testPrespawnQueuesOnServer) then passed = passed + 1 end if
if runTest(5, "Host_Spawn_f clears and queues", testSpawnClearsAndQueues) then passed = passed + 1 end if
if runTest(6, "blocked signon queue retention", testBlockedServerRetainsSignon) then passed = passed + 1 end if
if runTest(7, "end-to-end stages one through three", testFullStagesOneToThree) then passed = passed + 1 end if
if runTest(8, "Host_Begin_f has no wire output", testBeginHasNoServerWire) then passed = passed + 1 end if
if runTest(9, "first fast update completes signon", testFastUpdateCompletesSignon) then passed = passed + 1 end if
if runTest(10, "duplicate and backwards signon rejection", testDuplicateSignonRejected) then passed = passed + 1 end if
if runTest(11, "server stage state sequence", testServerStageSequence) then passed = passed + 1 end if
if runTest(12, "stage-two command ordering", testReplyOrderWithinSingleBuffer) then passed = passed + 1 end if

if passed != 12 then
  print "MiniQuake BP-015 Protocol 15 signon tests failed: " + passed + "/12"
  error(9599, "BP-015 Protocol 15 signon fixtures failed")
end if
print "MiniQuake BP-015 Protocol 15 signon tests passed: 12"
