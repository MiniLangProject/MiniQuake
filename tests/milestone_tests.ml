/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.launch as launch
import miniquake.host as host
import miniquake.input as gameInput
import miniquake.runtime_validation as runtimeValidation
import miniquake.console as console
import miniquake.menu as menu
import miniquake.statusbar as statusbar
import miniquake.view as view
import miniquake.particles as particles
import miniquake.client_effects as effects
import miniquake.client_protocol as protocol
import miniquake.client as client
import miniquake.player_move as movement
import miniquake.demo_player as demoPlayer
import miniquake.net_datagram as datagram
import miniquake.net_loop as netloop
import miniquake.server as server
import miniquake.edict as edict
import miniquake.sound.mixer as mixer
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_write as protocolWriter
import miniquake.byteio as bio

function assertEqual(actual, expected, name)
  if actual != expected then return error(9100, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9101, name + ": expected true") end if
  return true
end function

function assertNear(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(9102, name + ": expected " + expected + " +/- " + tolerance + ", got " + actual) end if
  return true
end function

function testLaunchParsing()
  options = launch.parse(["-basedir", "C:/Quake", "-game", "hipnotic", "-width", "1024", "-height", "768", "-nosound", "+map", "e1m1"])
  assertEqual(options.basedir, "C:/Quake", "basedir")
  assertEqual(options.gameDirectory, "hipnotic", "game directory")
  assertEqual(options.width, 1024, "width")
  assertEqual(options.height, 768, "height")
  assertEqual(options.noSound, true, "nosound")
  assertEqual(options.startMap, "e1m1", "start map")
  assertTrue(len(options.plusCommands) == 1, "plus command count")
  return true
end function

function testHostTiming()
  timing = t.HostTiming(0.0, 0.0, 0.0, 0, 0)
  assertEqual(host.filterTime(timing, 0.001, 72.0, 0.0, false), false, "filtered short frame")
  assertEqual(timing.filteredFrames, 1, "filtered counter")
  assertEqual(host.filterTime(timing, 0.02, 72.0, 0.0, false), true, "accepted frame")
  assertNear(timing.frameTime, 0.02, 0.00001, "elapsed frame time")
  assertEqual(host.filterTime(timing, 0.04, 0.0, 0.05, false), true, "forced frame")
  assertNear(timing.frameTime, 0.05, 0.00001, "forced frame time")
  assertEqual(runtimeValidation.worldFaceCount(void), 0, "void world has zero validation faces")
  assertEqual(runtimeValidation.renderSurfaceCount(void), 0, "headless renderer has zero validation surfaces")
  return true
end function

function testMoveCommandEncoding()
  // usercmd_t stores movement as float in WinQuake, while MSG_WriteShort takes
  // int. This verifies the same truncation at MiniQuake's protocol boundary.
  command = t.UserCommand(
    t.Vec3(45.0, 90.0, 180.0),
    200.75,
    -123.75,
    0.0,
    3,
    7,
    20.0,
  )
  buffer = sz.alloc(64)
  protocolWriter.writeMove(buffer, command, 12.5)
  reader = msg.beginReading(buffer)

  assertEqual(msg.readByte(reader), c.CLC_MOVE, "move command opcode")
  assertNear(msg.readFloat(reader), 12.5, 0.0001, "move command client time")
  assertNear(msg.readAngle(reader), 45.0, 0.0001, "move command pitch")
  assertNear(msg.readAngle(reader), 90.0, 0.0001, "move command yaw")
  assertNear(msg.readAngle(reader), 180.0, 0.0001, "move command roll")
  assertEqual(msg.readShort(reader), 200, "move command forward truncation")
  assertEqual(msg.readShort(reader), -123, "move command side truncation")
  assertEqual(msg.readShort(reader), 0, "move command zero upmove")
  assertEqual(msg.readByte(reader), 3, "move command buttons")
  assertEqual(msg.readByte(reader), 7, "move command impulse")
  assertEqual(msg.remaining(reader), 0, "move command payload consumed")
  return true
end function

function testConsoleState()
  state = console.create(32)
  index = 0
  while index < 40
    console.appendLine(state, "line " + index)
    index = index + 1
  end while
  assertEqual(len(state.lines), 32, "console ring size")
  assertEqual(state.lines[0], "line 8", "console oldest line")
  console.appendCharacter(state, 65)
  console.appendCharacter(state, 66)
  console.backspace(state)
  assertEqual(console.takeInput(state), "A", "console editing")
  console.centerPrint(state, "CENTER", 1.0, 2.0)
  assertEqual(console.clearExpiredCenter(state, 2.0), "CENTER", "center still active")
  assertEqual(console.clearExpiredCenter(state, 3.0), "", "center expired")
  return true
end function

function testMenuState()
  state = menu.create()
  assertEqual(state.active, false, "menu initially closed")
  assertEqual(state.page, menu.PAGE_MAIN, "menu starts at classic main page")
  assertEqual(len(state.items), 5, "classic main menu item count")
  menu.setActive(state, true)
  assertEqual(state.active, true, "menu opened")
  menu.move(state, -1)
  assertEqual(state.selection, 4, "main menu wraps upward")
  assertEqual(menu.selectedCommand(state), "menu_quit", "main menu quit action")
  menu.setPage(state, menu.PAGE_SINGLE)
  assertEqual(len(state.items), 3, "single-player item count")
  assertEqual(menu.selectedCommand(state), "new_game", "single-player new game action")
  assertEqual(menu.back(state), "page", "submenu returns to main")
  assertEqual(state.page, menu.PAGE_MAIN, "submenu back page")
  menu.setPage(state, menu.PAGE_OPTIONS)
  assertEqual(len(state.items), 14, "classic WinQuake options item count")
  menu.setPage(state, menu.PAGE_KEYS)
  assertEqual(len(state.items), 18, "classic key menu command count")
  assertEqual(menu.keyCommandAt(state), "+attack", "key menu first command")
  state.waitingForKey = true
  assertEqual(menu.back(state), "page", "escape cancels key grab")
  assertEqual(state.page, menu.PAGE_KEYS, "cancel key grab keeps page")
  assertEqual(menu.back(state), "page", "keys page returns to options")
  assertEqual(state.page, menu.PAGE_OPTIONS, "keys parent page")
  menu.setPage(state, menu.PAGE_LOAD)
  assertEqual(len(state.items), 12, "classic save slot count")
  assertEqual(menu.back(state), "page", "load returns to single player")
  assertEqual(state.page, menu.PAGE_SINGLE, "load parent page")
  menu.setPage(state, menu.PAGE_HELP)
  menu.changeHelpPage(state, -1)
  assertEqual(state.helpPage, 5, "help page wraps backward")
  return true
end function

function testMouseScaling()
  command = gameInput.createCommand()
  gameInput.applyMouseDelta(command, 100.0, 50.0, 3.0, 0.022, 0.022)
  assertNear(command.viewAngles.y, 353.4, 0.001, "mouse yaw uses m_yaw scale")
  assertNear(command.viewAngles.x, 3.3, 0.001, "mouse pitch uses m_pitch scale")
  gameInput.applyMouseDelta(command, 0.0, 10000.0, 3.0, 0.022, 0.022)
  assertEqual(command.viewAngles.x, 80.0, "mouse pitch upper clamp")
  return true
end function

function testKeyBindings()
  gameInput.resetBindings()
  assertEqual(gameInput.commandForKey("W"), "+forward", "default W binding")
  assertTrue(gameInput.bindKey("Q", "+attack"), "bind Q")
  assertEqual(gameInput.commandForKey("Q"), "+attack", "Q attack binding")
  found = gameInput.bindingsForCommand("+attack")
  assertTrue(len(found) >= 2, "two attack bindings are discoverable")
  assertTrue(gameInput.unbindCommand("+attack"), "unbind command")
  assertEqual(gameInput.bindingForCommand("+attack"), "???", "attack binding cleared")
  gameInput.resetBindings()
  return true
end function

function testStatusBarRules()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 100.0
  assertEqual(statusbar.faceName(player), "face1", "healthy face")
  player.health = 20.0
  assertEqual(statusbar.faceName(player), "face5", "critical face")
  player.items = c.IT_QUAD
  assertEqual(statusbar.faceName(player), "face_quad", "quad face")
  assertEqual(statusbar.armorName(c.IT_ARMOR3), "sb_armor3", "red armor icon")
  assertEqual(statusbar.ammoName(c.IT_ROCKETS), "sb_rocket", "rocket ammo icon")
  assertEqual(statusbar.scaleFor(640, 480), 1.0, "640 status bar scale")
  assertEqual(statusbar.scaleFor(1280, 720), 2.0, "1280 status bar scale")
  return true
end function

function testViewMath()
  velocity = t.Vec3(160.0, 80.0, 0.0)
  bob = view.calcBob(0.15, velocity, 0.02, 0.6, 0.5)
  assertTrue(bob >= -7.0 and bob <= 4.0, "bob clamp")
  roll = view.calcRoll(t.Vec3(0.0, 0.0, 0.0), velocity, 2.0, 200.0)
  assertTrue(roll >= -2.0 and roll <= 2.0, "roll clamp")
  state = view.create()
  view.addDamage(state, 25.0, t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.6, 0.6, 0.5)
  assertTrue(state.blend[3] > 0.0, "damage blend")

  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.onGround = true
  stairState = view.create()
  view.reset(stairState, player.origin)
  player.origin.z = 10.0
  cameraAngles = t.Vec3(12.345, 123.456, 0.0)
  view.calculate(stairState, player, cameraAngles, 0.0, 0.02, 0.0, 0.6, 0.5, 2.0, 200.0, 0.0)
  assertNear(stairState.oldZ, 1.6, 0.001, "stair smoothing rate")
  assertTrue(stairState.origin.z < player.origin.z + player.viewHeight, "stair camera does not snap upward")
  assertNear(stairState.angles.x, 12.345, 0.0001, "camera keeps unquantized pitch")
  assertNear(stairState.angles.y, 123.456, 0.0001, "camera keeps unquantized yaw")

  // An 18-unit Quake stair initially clamps the camera lag to 12 units.
  view.reset(stairState, t.Vec3(0.0, 0.0, 0.0))
  player.origin.z = 18.0
  view.calculate(stairState, player, cameraAngles, 0.0, 0.02, 0.0, 0.6, 0.5, 2.0, 200.0, 0.0)
  assertNear(stairState.oldZ, 6.0, 0.001, "stair smoothing twelve-unit clamp")
  return true
end function

function testParticleLifecycle()
  spawned = particles.runEffect(t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), 5000, 32, 1.0)
  assertEqual(len(spawned), particles.MAX_PARTICLES, "particle cap")
  alive = particles.update(spawned, 0.5, 0.01)
  assertTrue(len(alive) > 0, "particles alive")
  dead = particles.update(alive, 100.0, 0.01)
  assertEqual(len(dead), 0, "particles expired")
  return true
end function

function testTemporaryEntityProtocol()
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.SVC_TEMP_ENTITY)
  msg.writeByte(buffer, c.TE_EXPLOSION2)
  msg.writeCoord(buffer, 1.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeCoord(buffer, 3.0)
  msg.writeByte(buffer, 40)
  msg.writeByte(buffer, 8)
  msg.writeByte(buffer, c.SVC_NOP)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 2, "temp entity preserves following command")
  assertEqual(parsed.events[0].command, "svc_temp_entity", "temp command")
  temporary = parsed.events[0].payload
  assertEqual(temporary.type, c.TE_EXPLOSION2, "temp type")
  assertEqual((temporary.entity >> 8) & 255, 40, "explosion color start")
  assertEqual(temporary.entity & 255, 8, "explosion color length")
  assertEqual(parsed.events[1].command, "svc_nop", "following nop")
  return true
end function

function testClientEffects()
  client.CL_ClearDlights()
  explosion = t.TemporaryEntity(c.TE_EXPLOSION, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0)
  result = effects.processTemporary(explosion, void, [], [], 1.0)
  assertTrue(len(result[0]) > 0, "explosion particles")
  assertEqual(len(client.clDlights), c.MAX_DLIGHTS, "fixed dynamic-light pool")
  assertNear(client.clDlights[0].radius, 350.0, 0.001, "explosion dynamic-light radius")
  assertNear(client.clDlights[0].die, 1.5, 0.001, "explosion dynamic-light lifetime")
  assertNear(client.clDlights[0].decay, 300.0, 0.001, "explosion dynamic-light decay")
  client.CL_DecayLightsAt(1.25, 0.25)
  assertNear(client.clDlights[0].radius, 275.0, 0.001, "dynamic-light frame decay")
  beam = t.TemporaryEntity(c.TE_LIGHTNING1, t.Vec3(1.0, 2.0, 3.0), t.Vec3(4.0, 5.0, 6.0), 7)
  result = effects.processTemporary(beam, void, result[0], result[1], 1.0)
  assertEqual(len(result[1]), 1, "active beam")
  assertEqual(len(effects.pruneTemporary(result[1], 2.0)), 0, "beam expiry")
  return true
end function

function testServerEventEncoding()
  gameServer = server.create(1)
  gameServer.soundPrecache = ["", "weapons/test.wav"]
  worldItem = edict.create(0)
  item = edict.create(1)
  item.origin = t.Vec3(10.0, 20.0, 30.0)
  item.mins = t.Vec3(-1.0, -2.0, -3.0)
  item.maxs = t.Vec3(1.0, 2.0, 3.0)
  gameServer.edicts = [worldItem, item]
  assertEqual(server.writeQueuedSound(gameServer, [1, 2, "weapons/test.wav", 1.0, 1.0]), true, "queued sound write")
  assertEqual(server.writeQueuedParticle(gameServer, [t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.5, -0.5, 0.0), 12, 77]), true, "queued particle write")
  parsed = protocol.parse(sz.dataSlice(gameServer.datagram))
  assertEqual(len(parsed.events), 2, "server event count")
  assertEqual(parsed.events[0].command, "svc_sound", "sound command")
  assertEqual(parsed.events[0].payload[3], 10, "packed sound channel")
  assertEqual(parsed.events[0].payload[4], 1, "sound index")
  assertEqual(parsed.events[1].command, "svc_particle", "particle command")
  assertEqual(parsed.events[1].payload[2], 12, "particle count")
  assertEqual(parsed.events[1].payload[3], 77, "particle color")
  return true
end function

function testBaselineEncoding()
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.SVC_SPAWNBASELINE)
  msg.writeShort(buffer, 7)
  msg.writeByte(buffer, 3)
  msg.writeByte(buffer, 4)
  msg.writeByte(buffer, 5)
  msg.writeByte(buffer, 6)
  msg.writeCoord(buffer, 8.0); msg.writeAngle(buffer, 45.0)
  msg.writeCoord(buffer, 16.0); msg.writeAngle(buffer, 90.0)
  msg.writeCoord(buffer, 24.0); msg.writeAngle(buffer, 180.0)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "baseline event count")
  payload = parsed.events[0].payload
  assertEqual(payload[0], 7, "baseline entity")
  baseline = payload[1]
  assertEqual(baseline[0], 3, "baseline model")
  assertEqual(baseline[1], 4, "baseline frame")
  assertEqual(baseline[4].x, 8.0, "baseline origin x")
  assertEqual(baseline[4].y, 16.0, "baseline origin y")
  assertEqual(baseline[4].z, 24.0, "baseline origin z")
  assertNear(baseline[5].x, 45.0, 1.5, "baseline angle x")
  assertNear(baseline[5].y, 90.0, 1.5, "baseline angle y")
  assertNear(baseline[5].z, 180.0, 1.5, "baseline angle z")
  return true
end function

function testFastEntityEncoding()
  gameServer = server.create(1)
  item = edict.create(2)
  item.model = "progs/test.mdl"
  item.modelIndex = 3
  item.frame = 4
  item.origin = t.Vec3(8.0, 16.0, 24.0)
  item.angles = t.Vec3(0.0, 90.0, 0.0)
  item.baseline = t.EntityBaseline(1, 0, 0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  buffer = sz.alloc(128)
  server.writeEntityUpdate(gameServer, buffer, item)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "fast entity count")
  update = parsed.events[0].payload
  assertEqual(update[0], 2, "fast entity number")
  assertEqual(update[2], 3, "fast entity model")
  assertEqual(update[3], 4, "fast entity frame")
  assertEqual(update[7][0], 8.0, "fast entity origin x")
  assertEqual(update[8][1], 90.0, "fast entity yaw")
  return true
end function

function testLocalPlayerPrecision()
  player = movement.create(t.Vec3(10.125, 20.25, 30.375), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  localClient.viewEntity = 1
  localClient.localAuthoritative = true
  localClient.serverTime = 1.0
  payload = [
    1,
    0,
    void,
    void,
    void,
    void,
    void,
    [20.0, 21.0, 22.0],
    [void, 90.0, void],
  ]
  entity = client.applyFastUpdate(localClient, payload)
  assertEqual(entity.origin.z, 22.0, "client entity receives network origin")
  assertNear(player.origin.x, 10.125, 0.0001, "local authoritative x is not quantized")
  assertNear(player.origin.y, 20.25, 0.0001, "local authoritative y is not quantized")
  assertNear(player.origin.z, 30.375, 0.0001, "local authoritative z is not quantized")

  player.onGround = true
  player.waterLevel = 0
  player.velocity = t.Vec3(1.25, 2.5, 3.75)
  player.health = 91.0
  player.items = c.IT_SHOTGUN
  staleClientData = t.ProtocolEvent(
    "svc_clientdata",
    [0, 17, 0, [0, 0, 0], [0, 0, -160], c.IT_AXE, 0, 0, 0, 12, 0, 0, 0, 0, 0, c.IT_AXE],
  )
  client.applyEvent(localClient, staleClientData)
  assertEqual(player.onGround, true, "local clientdata cannot clear authoritative ground flag")
  assertNear(player.velocity.z, 3.75, 0.0001, "local clientdata cannot replace authoritative velocity")
  assertEqual(player.health, 91.0, "local clientdata cannot replace authoritative health")
  assertEqual(player.items, c.IT_SHOTGUN, "local clientdata cannot replace authoritative inventory")
  return true
end function

function testBatchedFastEntityPacket()
  // A real server frame contains many fast updates in one datagram. This
  // packet is large enough to exercise the event collector with hundreds of
  // entries without repeatedly concatenating arrays of structs.
  buffer = sz.alloc(4096)
  index = 0
  while index < 1024
    msg.writeByte(buffer, c.U_SIGNAL)
    msg.writeByte(buffer, (index % 254) + 1)
    index = index + 1
  end while

  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1024, "batched fast update count")
  assertEqual(parsed.bytesRead, buffer.curSize, "batched fast update bytes read")
  assertEqual(parsed.events[0].command, "fast_update", "batched first command")
  assertEqual(parsed.events[0].payload[0], 1, "batched first entity")
  assertEqual(parsed.events[255].payload[0], 2, "batched wrapped entity")
  assertEqual(parsed.events[1023].payload[0], 8, "batched last entity")
  assertEqual(parsed.events[1023].payload[1], 0, "batched last update bits")
  return true
end function

function testSoftwareMixer()
  samples = bytes(4)
  bio.putI16(samples, 0, 1000)
  bio.putI16(samples, 2, -1000)
  effect = t.SoundEffect("synthetic", samples, 22050, 2, 1, -1)
  state = mixer.create(void, 22050)
  state.masterVolume = 1.0
  mixer.setListenerEntity(state, 1)
  mixer.updateListener(state, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0))
  // View-entity sounds stay full volume even when their encoded origin is far
  // away; this is the original SND_Spatialize exception for local weapons.
  state.channels = [t.MixerChannel(1, 1, effect, t.Vec3(5000.0, 0.0, 0.0), 1.0, 1.0, 0, false, true)]
  mixed = mixer.mix(state, 3)
  assertEqual(len(mixed), 12, "stereo mix bytes")
  assertEqual(bio.i16(mixed, 0), 1000, "left sample 0")
  assertEqual(bio.i16(mixed, 2), 1000, "right sample 0")
  assertEqual(bio.i16(mixed, 4), -1000, "left sample 1")
  assertEqual(bio.i16(mixed, 6), -1000, "right sample 1")
  assertEqual(len(state.channels), 0, "finished channel removed")

  loopEffect = t.SoundEffect("loop", samples, 22050, 2, 1, 0)
  state.channels = [t.MixerChannel(1, 1, loopEffect, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, true, true)]
  looped = mixer.mix(state, 5)
  assertEqual(bio.i16(looped, 0), 1000, "loop sample 0")
  assertEqual(bio.i16(looped, 4), -1000, "loop sample 1")
  assertEqual(bio.i16(looped, 8), 1000, "loop repeats")
  assertEqual(len(state.channels), 1, "looping channel remains active")

  assertNear(mixer.ambientTarget(255, 0.3), 0.3, 0.0001, "full ambient leaf level")
  assertEqual(mixer.ambientTarget(20, 0.3), 0.0, "quiet ambient level threshold")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.016, 0.1), 6, "default mix-ahead queue depth")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.0, 0.0), 3, "minimum audio queue depth")

  // Mix in a wide accumulator and clamp once.  Per-channel clipping would
  // produce 2767 here instead of the mathematically correct 30000.
  positiveSamples = bytes(2)
  negativeSamples = bytes(2)
  bio.putI16(positiveSamples, 0, 30000)
  bio.putI16(negativeSamples, 0, -30000)
  positive = t.SoundEffect("positive", positiveSamples, 22050, 2, 1, -1)
  negative = t.SoundEffect("negative", negativeSamples, 22050, 2, 1, -1)
  state.channels = [
    t.MixerChannel(1, 0, positive, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true),
    t.MixerChannel(2, 0, positive, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true),
    t.MixerChannel(3, 0, negative, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true),
  ]
  accumulated = mixer.mix(state, 1)
  assertEqual(bio.i16(accumulated, 0), 30000, "wide mixer accumulation left")
  assertEqual(bio.i16(accumulated, 2), 30000, "wide mixer accumulation right")
  return true
end function

function testDatagramFraming()
  sender = datagram.createChannel()
  reliableBytes = datagram.reliable(sender, bytes("abc"), true)
  assertEqual(len(reliableBytes), 11, "reliable packet size")
  assertEqual(reliableBytes[0], 0, "reliable header byte 0")
  assertEqual(reliableBytes[1], 9, "reliable DATA/EOM flags")
  assertEqual(reliableBytes[2], 0, "reliable header byte 2")
  assertEqual(reliableBytes[3], 11, "reliable length")
  assertEqual(sender.sendSequence, 1, "reliable send sequence")

  packet = datagram.decodePacket(reliableBytes)
  assertTrue((packet.flags & datagram.NETFLAG_DATA) != 0, "reliable data flag")
  assertTrue((packet.flags & datagram.NETFLAG_EOM) != 0, "reliable eom flag")
  assertEqual(packet.sequence, 0, "reliable wire sequence")
  assertEqual(decode(packet.payload), "abc", "reliable payload")

  receiver = datagram.createChannel()
  assertEqual(datagram.acceptReliable(receiver, packet), true, "accept reliable")
  assertEqual(receiver.receiveSequence, 1, "reliable receive sequence")
  assertEqual(datagram.acceptReliable(receiver, packet), false, "reject duplicate reliable")

  acknowledgement = datagram.decodePacket(datagram.acknowledgement(packet.sequence))
  assertTrue((acknowledgement.flags & datagram.NETFLAG_ACK) != 0, "ack flag")
  assertEqual(acknowledgement.sequence, 0, "ack sequence")
  assertEqual(len(acknowledgement.payload), 0, "ack payload")

  skipped = datagram.decodePacket(datagram.encode(datagram.NETFLAG_UNRELIABLE, 2, bytes("u")))
  assertEqual(datagram.acceptUnreliable(receiver, skipped), true, "accept unreliable")
  assertEqual(receiver.unreliableReceiveSequence, 3, "unreliable receive sequence")
  assertEqual(receiver.droppedUnreliable, 2, "unreliable drop accounting")

  control = datagram.decodePacket(datagram.control(bytes([1, 2, 3])))
  assertTrue((control.flags & datagram.NETFLAG_CTL) != 0, "control flag")
  assertEqual(control.sequence, 0, "control has no sequence")
  assertEqual(hex(control.payload), "010203", "control payload")
  return true
end function

function testClientInventoryProtocol()
  sourcePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  sourcePlayer.viewHeight = 25.0
  sourcePlayer.onGround = true
  sourcePlayer.waterLevel = 2
  sourcePlayer.health = 87.0
  sourcePlayer.armor = 63.0
  sourcePlayer.ammo = 41
  sourcePlayer.shells = 17
  sourcePlayer.nails = 23
  sourcePlayer.rockets = 5
  sourcePlayer.cells = 9
  sourcePlayer.items = 0x12345678
  sourcePlayer.activeWeapon = 4
  sourcePlayer.weaponFrame = 7
  sourcePlayer.weapon = 9
  sourcePlayer.punchAngle = t.Vec3(2.0, -3.0, 1.0)
  sourcePlayer.velocity = t.Vec3(160.0, -80.0, 32.0)

  buffer = sz.alloc(128)
  bits = server.writeClientData(buffer, sourcePlayer)
  assertTrue((bits & c.SU_WEAPON) != 0, "clientdata always includes view weapon")
  targetPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(targetPlayer)
  count = client.parseMessage(localClient, sz.dataSlice(buffer))
  assertEqual(count, 1, "clientdata event count")
  assertEqual(targetPlayer.viewHeight, 25, "clientdata viewheight")
  assertEqual(targetPlayer.onGround, true, "clientdata onground")
  assertEqual(targetPlayer.waterLevel, 2, "clientdata inwater")
  assertEqual(targetPlayer.health, 87, "clientdata health")
  assertEqual(targetPlayer.armor, 63, "clientdata armor")
  assertEqual(targetPlayer.ammo, 41, "clientdata ammo")
  assertEqual(targetPlayer.shells, 17, "clientdata shells")
  assertEqual(targetPlayer.nails, 23, "clientdata nails")
  assertEqual(targetPlayer.rockets, 5, "clientdata rockets")
  assertEqual(targetPlayer.cells, 9, "clientdata cells")
  assertEqual(targetPlayer.items, 0x12345678, "clientdata items")
  assertEqual(targetPlayer.activeWeapon, 4, "clientdata active weapon")
  assertEqual(targetPlayer.weaponFrame, 7, "clientdata weapon frame")
  assertEqual(targetPlayer.weapon, 9, "clientdata weapon model")
  assertEqual(targetPlayer.punchAngle.x, 2, "clientdata punch x")
  assertEqual(targetPlayer.punchAngle.y, -3, "clientdata punch y")
  assertEqual(targetPlayer.velocity.x, 160, "clientdata velocity x")
  assertEqual(targetPlayer.velocity.y, -80, "clientdata velocity y")
  assertEqual(targetPlayer.velocity.z, 32, "clientdata velocity z")
  return true
end function

function testLoopbackSignonHandshake()
  network = netloop.createState()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  localServer = server.create(1)

  client.connect(localClient, network)
  assertEqual(localClient.signon, c.SIGNON_NONE, "transport connect keeps protocol signon at zero")
  serverSocket = netloop.checkNewConnections(network)
  assertTrue(serverSocket is not void, "loopback server socket")
  serverClient = server.acceptLocal(localServer, serverSocket)
  assertTrue(serverClient is not void, "server accepts local client")

  assertEqual(client.pump(localClient), 1, "client consumes serverinfo and signon one")
  assertEqual(localClient.signon, c.SIGNON_SERVERINFO, "client advances to signon stage one")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes prespawn")
  assertEqual(serverClient.signonStage, c.SIGNON_PRESPAWN, "server sends signon stage two")

  assertEqual(client.pump(localClient), 1, "client consumes signon stage two")
  assertEqual(localClient.signon, c.SIGNON_PRESPAWN, "client advances to signon stage two")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes name color and spawn")
  assertEqual(serverClient.signonStage, c.SIGNON_SPAWN, "server sends signon stage three")

  assertEqual(client.pump(localClient), 1, "client consumes signon stage three")
  assertEqual(localClient.signon, c.SIGNON_SPAWN, "client advances to signon stage three")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes begin")
  assertEqual(serverClient.signonStage, c.SIGNON_ACTIVE, "server sends signon stage four")

  assertEqual(client.pump(localClient), 1, "client consumes signon stage four")
  assertEqual(localClient.signon, c.SIGNON_ACTIVE, "client completes signon")
  assertEqual(localClient.spawned, true, "client becomes spawned")
  assertEqual(serverClient.spawned, true, "server marks client spawned")
  assertEqual(serverClient.name, "player", "signon name command")
  assertEqual(localClient.viewEntity, 1, "signon assigns player view entity")

  // usercmd_t movement is floating point in WinQuake.  The wire protocol stores
  // the three movement components as signed shorts, so exercise the implicit C
  // float-to-int conversion that the MiniLang writer must perform explicitly.
  move = t.UserCommand(t.Vec3(10.0, 20.0, 30.0), 123.75, -45.5, 7.9, c.BUTTON_ATTACK, 2, 16)
  assertEqual(client.sendMove(localClient, move), 1, "client sends floating-point usercmd")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes floating-point usercmd")
  assertEqual(serverClient.command.forwardMove, 123, "forward move truncates toward zero")
  assertEqual(serverClient.command.sideMove, -45, "side move truncates toward zero")
  assertEqual(serverClient.command.upMove, 7, "up move truncates toward zero")
  assertEqual(serverClient.command.buttons, c.BUTTON_ATTACK, "move buttons")
  assertEqual(serverClient.command.impulse, 2, "move impulse")

  duplicate = try(client.advanceSignon(localClient, c.SIGNON_ACTIVE))
  assertTrue(duplicate is error, "duplicate signon is rejected")
  netloop.close(localClient.socket)
  return true
end function

function testDemoPlayback()
  payload = sz.alloc(128)
  msg.writeByte(payload, c.SVC_VERSION)
  msg.writeLong(payload, c.PROTOCOL_VERSION)
  msg.writeByte(payload, c.SVC_TIME)
  msg.writeFloat(payload, 12.5)
  msg.writeByte(payload, c.SVC_PRINT)
  msg.writeString(payload, "demo hello")
  msg.writeByte(payload, c.SVC_SETVIEW)
  msg.writeShort(payload, 3)
  msg.writeByte(payload, c.SVC_SIGNONNUM)
  msg.writeByte(payload, c.SIGNONS)
  recording = t.Demo(-1, [t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), sz.dataSlice(payload))])
  report = demoPlayer.verify(recording)
  assertEqual(report.ok, true, "demo verification")
  assertEqual(report.eventCount, 5, "demo event count")
  assertEqual(report.payloadBytes, payload.curSize, "demo payload bytes")
  assertEqual(report.viewEntity, 3, "demo view entity")
  assertTrue(report.entities >= 4, "demo entity allocation")
  assertEqual(report.signon, c.SIGNONS, "demo signon")
  assertEqual(report.prints, 1, "demo print count")
  assertNear(report.serverTime, 12.5, 0.0001, "demo server time")
  return true
end function

function main(args)
  passed = 0
  print "MiniQuake milestone tests starting: 22"

  print "[01/22] launch parsing"
  result = try(testLaunchParsing())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[02/22] host frame timing"
  result = try(testHostTiming())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[03/22] user command encoding"
  result = try(testMoveCommandEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[04/22] original mouse scaling"
  result = try(testMouseScaling())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[05/22] key bindings"
  result = try(testKeyBindings())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[06/22] console state"
  result = try(testConsoleState())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[07/22] classic menu state"
  result = try(testMenuState())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[08/22] original status bar rules"
  result = try(testStatusBarRules())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[09/22] view bob/roll/stair smoothing"
  result = try(testViewMath())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[10/22] particles"
  result = try(testParticleLifecycle())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[11/22] temporary-entity protocol"
  result = try(testTemporaryEntityProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[12/22] client effects"
  result = try(testClientEffects())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[13/22] server sound/particle encoding"
  result = try(testServerEventEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[14/22] baseline encoding"
  result = try(testBaselineEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[15/22] fast entity encoding"
  result = try(testFastEntityEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[16/22] local player precision/ground state"
  result = try(testLocalPlayerPrecision())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[17/22] batched fast entity packet"
  result = try(testBatchedFastEntityPacket())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[18/22] software mixer"
  result = try(testSoftwareMixer())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[19/22] client inventory/view weapon protocol"
  result = try(testClientInventoryProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[20/22] complete loopback signon"
  result = try(testLoopbackSignonHandshake())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[21/22] demo playback"
  result = try(testDemoPlayback())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[22/22] datagram framing"
  result = try(testDatagramFraming())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "MiniQuake milestone tests passed: " + passed
  return 0
end function
