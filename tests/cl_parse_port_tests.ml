/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cl_parse_port_tests.ml.
*/
import miniquake.client_protocol as protocol
import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as movement
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_write as writer
import miniquake.net_loop as netloop
import miniquake.net_main as netmain

// Assert that the condition holds and identify a failing test.
function require(value, name)
  if value != true then return error(9870, name) end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9871, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9872, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Exercise byte fixture as part of this deterministic regression fixture.
function byteFixture(values)
  result = bytes(len(values))
  index = 0
  while index < len(values)
    result[index] = values[index]
    index = index + 1
  end while
  return result
end function

// Create and initialize client.
function newClient()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  result = client.create(player)
  result.localAuthoritative = false
  return result
end function

// Exercise server info packet as part of this deterministic regression fixture.
function serverInfoPacket(maxClients)
  buffer = sz.alloc(2048)
  msg.writeByte(buffer, c.SVC_SERVERINFO)
  msg.writeLong(buffer, c.PROTOCOL_VERSION)
  msg.writeByte(buffer, maxClients)
  msg.writeByte(buffer, c.GAME_COOP)
  msg.writeString(buffer, "fixture")
  msg.writeString(buffer, "maps/fixture.bsp")
  msg.writeString(buffer, "progs/player.mdl")
  msg.writeString(buffer, "")
  msg.writeString(buffer, "misc/menu1.wav")
  msg.writeString(buffer, "")
  return sz.dataSlice(buffer)
end function

// Verify server info against the expected Quake behavior.
function testServerInfo()
  packet = serverInfoPacket(2)
  parsed = protocol.CL_ParseServerMessage(packet)
  equal(len(parsed.events), 1, "serverinfo event count")
  equal(parsed.events[0].command, "svc_serverinfo", "serverinfo event")
  equal(parsed.events[0].payload[0], c.PROTOCOL_VERSION, "protocol")
  equal(len(parsed.events[0].payload[4]), 2, "model precache count")

  localClient = newClient()
  localClient.connected = true
  equal(client.parseMessage(localClient, packet), 1, "apply serverinfo")
  equal(localClient.maxClients, 2, "maxclients")
  equal(localClient.levelName, "fixture", "level name")
  equal(localClient.modelPrecache[1], "maps/fixture.bsp", "world model")
  equal(localClient.soundPrecache[1], "misc/menu1.wav", "sound precache")
  equal(localClient.entities[0].modelIndex, 1, "world entity")

  badMax = try(protocol.CL_ParseServerMessage(serverInfoPacket(c.MAX_CLIENTS + 1)))
  require(badMax is error, "bad maxclients rejected")
  badVersion = sz.alloc(32)
  msg.writeByte(badVersion, c.SVC_VERSION)
  msg.writeLong(badVersion, 14)
  wrong = try(client.parseMessage(localClient, sz.dataSlice(badVersion)))
  require(wrong is error, "wrong protocol rejected")
  return true
end function

// Verify sound packets against the expected Quake behavior.
function testSoundPackets()
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.SVC_SOUND)
  msg.writeByte(buffer, 3)
  msg.writeByte(buffer, 200)
  msg.writeByte(buffer, 32)
  msg.writeShort(buffer, (599 << 3) | 6)
  msg.writeByte(buffer, 1)
  msg.writeCoord(buffer, 8.0)
  msg.writeCoord(buffer, -4.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeByte(buffer, c.SVC_SPAWNSTATICSOUND)
  msg.writeCoord(buffer, 1.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeCoord(buffer, 3.0)
  msg.writeByte(buffer, 1)
  msg.writeByte(buffer, 128)
  msg.writeByte(buffer, 64)
  parsed = protocol.CL_ParseServerMessage(sz.dataSlice(buffer))
  equal(len(parsed.events), 2, "sound event count")
  equal(parsed.events[0].payload[1], 200, "sound volume")
  near(parsed.events[0].payload[2], 0.5, 0.000001, "sound attenuation")
  equal(parsed.events[0].payload[3] >> 3, 599, "sound entity")
  near(parsed.events[0].payload[5].y, -4.0, 0.000001, "sound position")
  equal(parsed.events[1].command, "svc_spawnstaticsound", "static sound")

  invalid = sz.alloc(32)
  msg.writeByte(invalid, c.SVC_SOUND)
  msg.writeByte(invalid, 0)
  msg.writeShort(invalid, 601 << 3)
  msg.writeByte(invalid, 1)
  msg.writeCoord(invalid, 0.0); msg.writeCoord(invalid, 0.0); msg.writeCoord(invalid, 0.0)
  rejected = try(protocol.CL_ParseServerMessage(sz.dataSlice(invalid)))
  require(rejected is error, "invalid sound entity rejected")
  return true
end function

// Verify fast update against the expected Quake behavior.
function testFastUpdate()
  // Every protocol-15 update bit is set. This hard-coded fixture verifies the
  // exact byte order rather than round-tripping through the same writer.
  packet = byteFixture([
    255, 127, 44, 1, 5, 7, 1, 2, 8,
    64, 0, 64, 128, 0, 192, 224, 255, 32,
  ])
  parsed = protocol.CL_ParseServerMessage(packet)
  equal(parsed.bytesRead, len(packet), "fast update byte count")
  update = parsed.events[0].payload
  equal(update[0], 300, "long entity")
  equal(update[1], 32639, "all update bits")
  equal(update[2], 5, "model")
  equal(update[3], 7, "frame")
  equal(update[4], 1, "colormap")
  equal(update[5], 2, "skin")
  equal(update[6], 8, "effects")
  near(update[7][0], 8.0, 0.000001, "origin x")
  near(update[7][1], 16.0, 0.000001, "origin y")
  near(update[7][2], -4.0, 0.000001, "origin z")
  near(update[8][0], 90.0, 0.000001, "angle x")
  near(update[8][1], -90.0, 0.000001, "angle y")
  near(update[8][2], 45.0, 0.000001, "angle z")

  localClient = newClient()
  localClient.maxClients = 2
  client.resetScores(localClient, 2)
  localClient.modelPrecache = ["", "base", "two", "three", "four", "five"]
  localClient.messageTimes = [2.0, 1.0]
  localClient.serverTime = 2.0
  baseline = [1, 3, 0, 0, t.Vec3(1.0, 2.0, 3.0), t.Vec3(10.0, 20.0, 30.0)]
  entity = client.applyBaseline(localClient, 300, baseline)
  entity.messageTime = 1.0
  require(client.applyEvent(localClient, parsed.events[0]), "apply fast update")
  equal(entity.modelIndex, 5, "updated model")
  require(entity.forceLink, "U_NOLERP forcelink")

  fallbackEvent = protocol.CL_ParseServerMessage(byteFixture([128, 44]))
  // The one-byte entity form truncates 300 to 44; use it to verify omitted
  // fields reset to that entity's baseline.
  fallbackEntity = client.applyBaseline(localClient, 44, baseline)
  localClient.serverTime = 3.0
  localClient.messageTimes = [3.0, 2.0]
  client.applyEvent(localClient, fallbackEvent.events[0])
  equal(fallbackEntity.modelIndex, 1, "omitted model uses baseline")
  equal(fallbackEntity.frame, 3, "omitted frame uses baseline")
  near(fallbackEntity.messageOrigin.z, 3.0, 0.000001, "omitted origin uses baseline")
  return true
end function

// Verify client data and svc state against the expected Quake behavior.
function testClientDataAndSvcState()
  buffer = sz.alloc(1024)
  bits = c.SU_VIEWHEIGHT | c.SU_IDEALPITCH |
    c.SU_PUNCH1 | c.SU_PUNCH2 | c.SU_PUNCH3 |
    c.SU_VELOCITY1 | c.SU_VELOCITY2 | c.SU_VELOCITY3 |
    c.SU_ITEMS | c.SU_ONGROUND | c.SU_INWATER |
    c.SU_WEAPONFRAME | c.SU_ARMOR | c.SU_WEAPON
  msg.writeByte(buffer, c.SVC_CLIENTDATA)
  msg.writeShort(buffer, bits)
  msg.writeChar(buffer, 24)
  msg.writeChar(buffer, -2)
  msg.writeChar(buffer, 1); msg.writeChar(buffer, 2)
  msg.writeChar(buffer, 3); msg.writeChar(buffer, 4)
  msg.writeChar(buffer, 5); msg.writeChar(buffer, 6)
  msg.writeLong(buffer, 5)
  msg.writeByte(buffer, 7)
  msg.writeByte(buffer, 80)
  msg.writeByte(buffer, 4)
  msg.writeShort(buffer, 99)
  msg.writeByte(buffer, 50)
  msg.writeByte(buffer, 10)
  msg.writeByte(buffer, 20)
  msg.writeByte(buffer, 30)
  msg.writeByte(buffer, 40)
  msg.writeByte(buffer, 3)
  msg.writeByte(buffer, c.SVC_LIGHTSTYLE); msg.writeByte(buffer, 0); msg.writeString(buffer, "abc")
  msg.writeByte(buffer, c.SVC_UPDATENAME); msg.writeByte(buffer, 0); msg.writeString(buffer, "Ranger")
  msg.writeByte(buffer, c.SVC_UPDATEFRAGS); msg.writeByte(buffer, 0); msg.writeShort(buffer, -4)
  msg.writeByte(buffer, c.SVC_UPDATECOLORS); msg.writeByte(buffer, 0); msg.writeByte(buffer, 0x4f)
  msg.writeByte(buffer, c.SVC_UPDATESTAT); msg.writeByte(buffer, c.STAT_MONSTERS); msg.writeLong(buffer, 5)
  msg.writeByte(buffer, c.SVC_DAMAGE)
  msg.writeByte(buffer, 2); msg.writeByte(buffer, 3)
  msg.writeCoord(buffer, 1.0); msg.writeCoord(buffer, 2.0); msg.writeCoord(buffer, 3.0)
  msg.writeByte(buffer, c.SVC_SETPAUSE); msg.writeByte(buffer, 1)
  msg.writeByte(buffer, c.SVC_CDTRACK); msg.writeByte(buffer, 3); msg.writeByte(buffer, 4)
  msg.writeByte(buffer, c.SVC_INTERMISSION)
  msg.writeByte(buffer, c.SVC_FINALE); msg.writeString(buffer, "finale")
  msg.writeByte(buffer, c.SVC_CUTSCENE); msg.writeString(buffer, "cut")
  msg.writeByte(buffer, c.SVC_SELLSCREEN)

  localClient = newClient()
  localClient.maxClients = 1
  client.resetScores(localClient, 1)
  localClient.standardQuake = false
  localClient.time = 12.0
  localClient.serverTime = 20.0
  count = client.parseMessage(localClient, sz.dataSlice(buffer))
  equal(count, 13, "svc event count")
  equal(localClient.stats[c.STAT_HEALTH], 99, "health")
  equal(localClient.stats[c.STAT_ACTIVEWEAPON], 8, "mission-pack active weapon")
  equal(localClient.itemGetTime[0], 12.0, "item flash time")
  equal(localClient.lightStyles[0], "abc", "lightstyle")
  equal(localClient.scores[0].name, "Ranger", "score name")
  equal(localClient.scores[0].frags, -4, "score frags")
  equal(localClient.scores[0].colors, 0x4f, "score colors")
  equal(localClient.stats[c.STAT_MONSTERS], 5, "stat update")
  near(localClient.faceAnimTime, 12.2, 0.000001, "damage face animation uses cl.time")
  require(localClient.paused, "pause state")
  equal(localClient.cdTrack, 3, "cd track")
  equal(localClient.loopTrack, 4, "loop track")
  equal(localClient.intermission, 3, "cutscene mode")
  equal(localClient.intermissionText, "cut", "cutscene text")
  require(localClient.sellScreen, "sell screen")
  translation = client.CL_NewTranslation(localClient, 0)
  equal(translation[c.TOP_RANGE], 64, "top translation")
  equal(translation[c.BOTTOM_RANGE], 255, "reversed bottom translation")
  equal(translation[c.BOTTOM_RANGE + 15], 240, "reversed bottom end")
  return true
end function

// Verify baselines and disconnect against the expected Quake behavior.
function testBaselinesAndDisconnect()
  buffer = sz.alloc(256)
  baseline = [1, 2, 0, 3, t.Vec3(4.0, 5.0, 6.0), t.Vec3(0.0, 90.0, 0.0)]
  msg.writeByte(buffer, c.SVC_SPAWNBASELINE)
  msg.writeShort(buffer, 5)
  writer.writeBaseline(buffer, baseline)
  msg.writeByte(buffer, c.SVC_SPAWNSTATIC)
  writer.writeBaseline(buffer, baseline)
  localClient = newClient()
  localClient.modelPrecache = ["", "progs/torch.mdl"]
  equal(client.parseMessage(localClient, sz.dataSlice(buffer)), 2, "baseline/static parse")
  equal(localClient.entities[5].baseline[1], 2, "stored baseline frame")
  equal(len(localClient.staticEntities), 1, "separate static entity table")
  staticEntity = localClient.staticEntities[0]
  near(staticEntity.messageTime, -1.0, 0.000001, "static entity marker")
  near(staticEntity.origin.x, 4.0, 0.000001, "static entity origin")

  // A future ED_Alloc uses dynamic slot 6, which used to alias the appended
  // static entity. An omitted zero coordinate must come from the dynamic
  // zero baseline, never from the torch's x=4 baseline.
  localClient.messageTimes = [1.0, 0.0]
  localClient.serverTime = 1.0
  dynamic = client.applyFastUpdate(localClient, [
    6, 0, 1, 0, 0, 0, 0,
    [void, 20.0, 30.0], [void, void, void],
  ])
  require(dynamic is not error, "future dynamic update after spawnstatic")
  near(dynamic.messageOrigin.x, 0.0, 0.000001, "dynamic zero coordinate uses dynamic baseline")
  near(staticEntity.origin.x, 4.0, 0.000001, "static entity survives dynamic slot reuse")
  client.CL_RelinkEntities(localClient)
  equal(len(localClient.visibleEntities), 2, "static and reused dynamic slot both relink")
  equal(localClient.visibleEntities[0].number, 6, "dynamic protocol entity has render priority")
  equal(localClient.visibleEntities[1].number, c.MAX_EDICTS, "static renderer-local number")

  localClient.connected = true
  disconnected = try(client.parseMessage(localClient, byteFixture([c.SVC_DISCONNECT])))
  require(disconnected is error, "network disconnect aborts message")
  require(not localClient.connected, "disconnect clears connection")
  demoClient = newClient()
  demoClient.demoPlayback = true
  demoClient.connected = true
  equal(client.parseMessage(demoClient, byteFixture([c.SVC_DISCONNECT])), 1, "demo disconnect completes cleanly")
  return true
end function

// Verify keepalive and malformed against the expected Quake behavior.
function testKeepaliveAndMalformed()
  network = netloop.createState()
  localClient = newClient()
  connected = try(client.CL_EstablishConnection(localClient, network, "local"))
  require(connected is not error, "keepalive connection")
  serverSocket = netloop.checkNewConnections(network)
  nop = sz.alloc(8)
  msg.writeByte(nop, c.SVC_NOP)
  equal(netmain.NET_SendUnreliableMessage(serverSocket, nop), 1, "server nop")
  msg.writeByte(localClient.incoming, 77)
  require(client.CL_KeepaliveMessage(localClient, false, 6.0), "keepalive sent")
  equal(localClient.incoming.curSize, 1, "incoming buffer restored")
  equal(localClient.incoming.data[0], 77, "incoming byte restored")
  received = sz.alloc(16)
  equal(netmain.NET_GetMessage(serverSocket, received, 1.0), 1, "server receives keepalive")
  equal(received.data[0], c.CLC_NOP, "keepalive opcode")
  client.CL_Disconnect(localClient)

  truncated = try(protocol.CL_ParseServerMessage(byteFixture([c.SVC_TIME, 0, 0])))
  require(truncated is error, "truncated float rejected")
  unterminated = try(protocol.CL_ParseServerMessage(byteFixture([c.SVC_PRINT, 65])))
  require(unterminated is error, "unterminated string rejected")
  unknown = try(protocol.CL_ParseServerMessage(byteFixture([35])))
  require(unknown is error, "unknown svc rejected")
  invalidEntity = try(protocol.CL_ParseServerMessage(byteFixture([129, 64, 88, 2])))
  require(invalidEntity is error, "MAX_EDICTS entity rejected")
  truncatedFast = try(protocol.CL_ParseServerMessage(byteFixture([255])))
  require(truncatedFast is error, "truncated fast update rejected")

  // Exercise the actual CL_ReadFromServer transport path.  A direct parser
  // fixture alone would not catch callers which accidentally discard the
  // returned Host_Error equivalent.
  malformedNetwork = netloop.createState()
  malformedClient = newClient()
  established = try(client.CL_EstablishConnection(malformedClient, malformedNetwork, "local"))
  require(established is not error, "malformed production connection")
  malformedServer = netloop.checkNewConnections(malformedNetwork)
  malformedMessage = sz.alloc(8)
  msg.writeByte(malformedMessage, c.SVC_TIME)
  msg.writeByte(malformedMessage, 0)
  msg.writeByte(malformedMessage, 0)
  equal(netmain.NET_SendUnreliableMessage(malformedServer, malformedMessage), 1, "malformed packet queued")
  productionError = try(client.readNetworkMessages(malformedClient, 1.0))
  require(productionError is error, "production network path propagates malformed server message")
  client.CL_Disconnect(malformedClient)

  overfull = sz.alloc(2048)
  msg.writeByte(overfull, c.SVC_SERVERINFO)
  msg.writeLong(overfull, c.PROTOCOL_VERSION)
  msg.writeByte(overfull, 1)
  msg.writeByte(overfull, c.GAME_COOP)
  msg.writeString(overfull, "overflow")
  index = 0
  while index < c.MAX_MODELS
    msg.writeString(overfull, "x")
    index = index + 1
  end while
  msg.writeString(overfull, "")
  msg.writeString(overfull, "")
  tooMany = try(protocol.CL_ParseServerMessage(sz.dataSlice(overfull)))
  require(tooMany is error, "model precache overflow rejected")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake cl_parse port tests starting: 7"
  result = try(testServerInfo())
  if result is error then print "FAIL serverinfo: " + result.message; return 1 end if
  print "[1/7] serverinfo / protocol"
  result = try(testSoundPackets())
  if result is error then print "FAIL sound: " + result.message; return 1 end if
  print "[2/7] start/static sound packets"
  result = try(testFastUpdate())
  if result is error then print "FAIL fast update: " + result.message; return 1 end if
  print "[3/7] bit-exact fast updates"
  result = try(testClientDataAndSvcState())
  if result is error then print "FAIL clientdata/svc: " + result.message; return 1 end if
  print "[4/7] clientdata / target svc state"
  result = try(testBaselinesAndDisconnect())
  if result is error then print "FAIL baseline/disconnect: " + result.message; return 1 end if
  print "[5/7] baselines / statics / disconnect"
  result = try(testKeepaliveAndMalformed())
  if result is error then print "FAIL malformed/keepalive: " + result.message; return 1 end if
  print "[6/7] keepalive / malformed packets"
  entityClient = newClient()
  require(client.CL_EntityNum(entityClient, c.MAX_EDICTS - 1) is not error, "last edict")
  invalid = try(client.CL_EntityNum(entityClient, c.MAX_EDICTS))
  require(invalid is error, "entity allocator bounds")
  print "[7/7] CL_EntityNum bounds"
  print "MiniQuake cl_parse port tests passed: 7"
  return 0
end function
