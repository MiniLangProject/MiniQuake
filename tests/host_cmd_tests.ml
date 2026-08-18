/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/host_cmd_tests.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.server as server
import miniquake.host as host
import miniquake.savegame as savegame
import miniquake.quakec.vm as vm
import miniquake.cvar as cvar
import miniquake.cmd as cmd
import miniquake.player_move as movement
import miniquake.mathlib as math
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.native as native
import miniquake.byteio as bio

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9800, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9801, name + ": expected true") end if
  return true
end function

// Exercise never command as part of this deterministic regression fixture.
function neverCommand(name)
  return false
end function

// Update subsystem configuration for register variable.
function registerVariable(registry, name, value)
  return cvar.register(registry, cvar.create(name, value, false, true), neverCommand)
end function

// Exercise contains as part of this deterministic regression fixture.
function contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Exercise contains text as part of this deterministic regression fixture.
function containsText(text, wanted)
  source = bytes(text)
  needle = bytes(wanted)
  if len(needle) == 0 then return true end if
  start = 0
  while start + len(needle) <= len(source)
    matched = true
    index = 0
    while index < len(needle)
      if source[start + index] != needle[index] then matched = false; break end if
      index = index + 1
    end while
    if matched then return true end if
    start = start + 1
  end while
  return false
end function

// Create and initialize server.
function makeServer()
  fieldDefs = [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_STRING, 0, 0, "netname"),
    t.QuakeCDef(c.EV_FLOAT, 1, 0, "flags"),
    t.QuakeCDef(c.EV_FLOAT, 2, 0, "movetype"),
    t.QuakeCDef(c.EV_FLOAT, 3, 0, "team"),
    t.QuakeCDef(c.EV_FLOAT, 4, 0, "health"),
    t.QuakeCDef(c.EV_FLOAT, 5, 0, "frags"),
    t.QuakeCDef(c.EV_FLOAT, 6, 0, "items"),
    t.QuakeCDef(c.EV_FLOAT, 7, 0, "ammo_shells"),
    t.QuakeCDef(c.EV_FLOAT, 8, 0, "ammo_nails"),
    t.QuakeCDef(c.EV_FLOAT, 9, 0, "ammo_rockets"),
    t.QuakeCDef(c.EV_FLOAT, 10, 0, "ammo_cells"),
    t.QuakeCDef(c.EV_FLOAT, 11, 0, "weapon"),
    t.QuakeCDef(c.EV_FLOAT, 12, 0, "impulse"),
    t.QuakeCDef(c.EV_ENTITY, 13, 0, "enemy"),
    t.QuakeCDef(c.EV_ENTITY, 14, 0, "oldenemy"),
    t.QuakeCDef(c.EV_ENTITY, 15, 0, "goalentity"),
  ]
  globalDefs = [t.QuakeCDef(c.EV_FLOAT | c.DEF_SAVEGLOBAL, 40, 0, "serverflags")]
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "host-cmd-fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    globalDefs,
    fieldDefs,
    [dummy],
    bytes(1),
    vm.zeroArray(64),
    16,
  )
  machine = vm.create(program, 8)
  gameServer = server.create(2)
  registry = cvar.createRegistry()
  registerVariable(registry, "hostname", "fixture")
  registerVariable(registry, "teamplay", "1")
  registerVariable(registry, "pausable", "1")
  runtime = server.createEdictRuntime(8, 2)
  filesystem = t.FileSystem("", "id1", [], "", false, false, true, false)
  context = server.createQuakeCContext(gameServer, filesystem, registry, cmd.create(), runtime)
  vm.setContext(machine, context)
  machine.edictFree = runtime.freeFlags
  gameServer.machine = machine
  gameServer.active = true
  gameServer.mapName = "start"
  gameServer.levelName = "Entrance"
  gameServer.numEdicts = 3
  gameServer.clients[0].active = true
  gameServer.clients[0].spawned = true
  gameServer.clients[0].name = "alpha"
  gameServer.clients[1].active = true
  gameServer.clients[1].spawned = true
  gameServer.clients[1].name = "bravo"
  machine.edictFree[1] = false
  machine.edictFree[2] = false
  server.setClientFloat(gameServer, gameServer.clients[0], "health", 100.0)
  server.setClientFloat(gameServer, gameServer.clients[1], "health", 100.0)
  server.setClientFloat(gameServer, gameServer.clients[0], "movetype", c.MOVETYPE_WALK)
  server.setClientFloat(gameServer, gameServer.clients[1], "movetype", c.MOVETYPE_WALK)
  server.setClientFloat(gameServer, gameServer.clients[0], "team", 1.0)
  server.setClientFloat(gameServer, gameServer.clients[1], "team", 2.0)
  return gameServer
end function

// Build one client string-command packet using the Protocol-15 wire format.
function stringCommandPacket(text)
  packet = sz.alloc(128)
  msg.writeByte(packet, c.CLC_STRINGCMD)
  msg.writeString(packet, text)
  return sz.dataSlice(packet)
end function

// Build a neutral move packet whose zero impulse must preserve a queued cheat.
function neutralMovePacket()
  packet = sz.alloc(32)
  msg.writeByte(packet, c.CLC_MOVE)
  msg.writeFloat(packet, 0.0)
  msg.writeByte(packet, 0)
  msg.writeByte(packet, 0)
  msg.writeByte(packet, 0)
  msg.writeShort(packet, 0)
  msg.writeShort(packet, 0)
  msg.writeShort(packet, 0)
  msg.writeByte(packet, 0)
  msg.writeByte(packet, 0)
  return sz.dataSlice(packet)
end function

// Verify client commands against the expected Quake behavior.
function testClientCommands()
  gameServer = makeServer()
  first = gameServer.clients[0]
  second = gameServer.clients[1]

  sz.clear(gameServer.reliableDatagram)
  server.Host_Name_f(gameServer, first, ["name", "12345678901234567890"])
  assertEqual(first.name, "123456789012345", "name is limited to 15 bytes")
  assertEqual(gameServer.reliableDatagram.data[0], c.SVC_UPDATENAME, "name protocol opcode")

  sz.clear(gameServer.reliableDatagram)
  server.Host_Color_f(gameServer, first, ["color", "-1", "14"])
  assertEqual(first.colors, 221, "color masks and caps both components")
  assertEqual(gameServer.reliableDatagram.data[0], c.SVC_UPDATECOLORS, "color protocol opcode")
  assertEqual(gameServer.reliableDatagram.data[2], 221, "color protocol payload")

  gameServer.deathmatch = true
  sz.clear(first.message)
  assertEqual(server.Host_God_f(gameServer, first), false, "deathmatch denies unprivileged god")
  assertEqual(first.message.curSize, 0, "denied cheat is silent")
  first.privileged = true
  assertEqual(server.Host_God_f(gameServer, first), true, "privileged god command")
  assertTrue((native.trunc(server.clientFloat(gameServer, first, "flags", 0.0)) & c.FL_GODMODE) != 0, "god flag toggled")

  sz.clear(first.message)
  sz.clear(second.message)
  server.Host_Say_Team_f(gameServer, first, ["say_team", "red", "only"])
  assertTrue(first.message.curSize > 0, "team chat reaches sender team")
  assertEqual(second.message.curSize, 0, "team chat excludes other team")

  sz.clear(second.message)
  assertTrue(server.Host_Tell_f(gameServer, first, ["tell", "bravo", "hello"]), "private tell reaches named client")
  assertEqual(
    bio.cString(second.message.data, 1),
    "123456789012345: bravo hello\n",
    "Host_Tell preserves original Cmd_Args target-token quirk",
  )

  gameServer.deathmatch = false
  sz.clear(first.message)
  sz.clear(second.message)
  sz.clear(gameServer.reliableDatagram)
  assertTrue(server.Host_Pause_f(gameServer, first), "pause accepted")
  assertEqual(gameServer.paused, true, "pause toggles server")
  assertEqual(gameServer.reliableDatagram.data[0], c.SVC_SETPAUSE, "pause protocol opcode")

  gameServer.deathmatch = true
  first.privileged = false
  assertEqual(server.Host_Kick_f(gameServer, first, ["kick", "bravo"]), false, "deathmatch denies unprivileged kick")
  assertEqual(second.active, true, "denied kick preserves target")
  first.privileged = true
  assertTrue(server.Host_Kick_f(gameServer, first, ["kick", "bravo", "bye"]), "privileged kick")
  assertEqual(second.active, false, "kick drops target")
  return true
end function

// Verify cheats survive the PlayerState/QuakeC boundary and paused move input.
function testCheatStateSynchronization()
  gameServer = makeServer()
  first = gameServer.clients[0]
  player = movement.create(t.Vec3(0.0, 0.0, 24.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 100.0

  assertTrue(
    server.readClientMessage(gameServer, first, stringCommandPacket("god"), player),
    "god string command accepted",
  )
  assertTrue((player.flags & c.FL_GODMODE) != 0, "god mirrors into PlayerState")
  server.syncPlayerToQuakeC(gameServer, first, player)
  assertTrue(
    (native.trunc(server.clientFloat(gameServer, first, "flags", 0.0)) & c.FL_GODMODE) != 0,
    "god survives the following PlayerState upload",
  )

  assertTrue(
    server.readClientMessage(gameServer, first, stringCommandPacket("give 8 1"), player),
    "weapon give command accepted",
  )
  assertTrue((player.items & c.IT_LIGHTNING) != 0, "give weapon mirrors into PlayerState")
  assertTrue(
    server.readClientMessage(gameServer, first, stringCommandPacket("give s 77"), player),
    "ammunition give command accepted",
  )
  assertEqual(player.shells, 77, "give ammunition mirrors into PlayerState")
  server.readClientMessage(gameServer, first, stringCommandPacket("give h 250"), player)
  assertEqual(player.health, 250.0, "give health mirrors into PlayerState")

  server.readClientMessage(gameServer, first, stringCommandPacket("notarget"), player)
  assertTrue((player.flags & c.FL_NOTARGET) != 0, "notarget mirrors into PlayerState")
  server.readClientMessage(gameServer, first, stringCommandPacket("notarget"), player)
  assertTrue((player.flags & c.FL_NOTARGET) == 0, "second notarget disables cheat")
  server.readClientMessage(gameServer, first, stringCommandPacket("noclip"), player)
  assertEqual(player.moveType, c.MOVETYPE_NOCLIP, "noclip mirrors into PlayerState")
  assertTrue(player.noclip, "noclip mirror updates convenience flag")
  server.readClientMessage(gameServer, first, stringCommandPacket("noclip"), player)
  assertEqual(player.moveType, c.MOVETYPE_WALK, "second noclip restores walking")
  server.readClientMessage(gameServer, first, stringCommandPacket("fly"), player)
  assertEqual(player.moveType, c.MOVETYPE_FLY, "fly mirrors into PlayerState")
  server.readClientMessage(gameServer, first, stringCommandPacket("fly"), player)
  assertEqual(player.moveType, c.MOVETYPE_WALK, "second fly restores walking")

  first.command.impulse = 9
  assertTrue(
    server.readClientMessage(gameServer, first, neutralMovePacket(), player),
    "neutral move after console impulse accepted",
  )
  assertEqual(first.command.impulse, 9, "zero move impulse preserves queued impulse 9")
  server.syncCommandToQuakeC(gameServer, first)
  assertEqual(
    native.trunc(server.clientFloat(gameServer, first, "impulse", 0.0)),
    9,
    "impulse 9 reaches QuakeC",
  )
  assertEqual(first.command.impulse, 0, "QuakeC synchronization consumes impulse once")

  runtime = gameServer.machine.context.edicts
  runtime.numEdicts = 4
  gameServer.numEdicts = 4
  runtime.freeFlags[3] = false
  server.setQcEntityFloat(gameServer, 3, "flags", c.FL_MONSTER)
  server.setQcEntityWord(gameServer, 3, "enemy", first.edictIndex)
  server.setQcEntityWord(gameServer, 3, "oldenemy", first.edictIndex)
  server.setQcEntityWord(gameServer, 3, "goalentity", first.edictIndex)
  assertTrue(
    server.readClientMessage(gameServer, first, stringCommandPacket("invisible"), player),
    "invisible command accepted",
  )
  assertTrue((player.flags & c.FL_NOTARGET) != 0, "invisible mirrors FL_NOTARGET")
  assertEqual(server.qcWord(gameServer.machine, 3, "enemy", -1), 0, "invisible clears monster enemy")
  assertEqual(server.qcWord(gameServer.machine, 3, "oldenemy", -1), 0, "invisible clears monster oldenemy")
  assertEqual(server.qcWord(gameServer.machine, 3, "goalentity", -1), 0, "invisible clears monster goalentity")
  server.syncPlayerToQuakeC(gameServer, first, player)
  assertTrue(
    (native.trunc(server.clientFloat(gameServer, first, "flags", 0.0)) & c.FL_NOTARGET) != 0,
    "invisible survives the following PlayerState upload",
  )
  server.readClientMessage(gameServer, first, stringCommandPacket("invisible"), player)
  assertTrue((player.flags & c.FL_NOTARGET) == 0, "second invisible command disables cheat")
  return true
end function

// Verify save format against the expected Quake behavior.
function testSaveFormat()
  comment = savegame.Host_SavegameComment("Entrance", 1, 12)
  assertEqual(len(bytes(comment)), 39, "save comment length")
  assertEqual(comment, "Entrance______________kills:__1/_12____", "save comment exact padding")

  gameServer = makeServer()
  gameServer.maxClients = 1
  gameServer.clients = [gameServer.clients[0]]
  gameServer.skill = 2
  gameServer.time = 12.5
  text = savegame.SaveGamestate(gameServer)
  assertTrue(containsText(text, "12.500000\n"), "save header uses original percent-f precision")
  assertTrue(containsText(text, "\"health\" \"100.000000\"\n"), "edict floats use original percent-f precision")
  parsed = savegame.parse(text)
  assertEqual(parsed.version, 5, "savegame version five")
  assertEqual(parsed.mapName, "start", "savegame map roundtrip")
  assertEqual(parsed.skill, 2, "savegame skill roundtrip")
  assertEqual(len(parsed.spawnParms), c.NUM_SPAWN_PARMS, "spawn parm count")
  assertEqual(len(parsed.lightStyles), c.MAX_LIGHTSTYLES, "lightstyle count")
  restored = makeServer()
  applied = savegame.LoadGamestate(restored, text)
  assertEqual(applied, true, "savegame state apply")
  assertEqual(restored.time, 12.5, "applied server time")
  assertEqual(restored.skill, 2, "applied server skill")
  assertEqual(restored.numEdicts, 3, "applied edict count")
  return true
end function

// Verify registration against the expected Quake behavior.
function testRegistration()
  commands = host.Host_InitCommands()
  assertTrue(contains(commands, "status"), "host status registered")
  assertTrue(contains(commands, "save"), "host save registered")
  assertTrue(contains(commands, "edict"), "PR edict registered")
  assertTrue(contains(commands, "edicts"), "PR edicts registered")
  assertTrue(contains(commands, "edictcount"), "PR edictcount registered")
  assertTrue(contains(commands, "profile"), "PR profile registered")
  assertTrue(contains(commands, "flush"), "Cache_Init flush command registered")
  assertTrue(contains(commands, "invisible"), "AI-invisibility cheat registered")
  assertTrue(contains(commands, "cheats"), "cheat help command registered")
  assertTrue(contains(commands, "cheatcodes"), "cheat help alias registered")

  helpLines = host.Host_CheatHelpLines()
  assertTrue(contains(helpLines, "  god                 toggle invulnerability"), "god help listed")
  assertTrue(contains(helpLines, "  invisible           hide from AI and clear current targets"), "invisible help listed")
  assertTrue(contains(helpLines, "  impulse 9           give all stock weapons"), "impulse help listed")
  assertTrue(contains(helpLines, "  impulse 11          advance the rune/serverflags cheat"), "rune cheat listed")
  assertTrue(contains(helpLines, "  impulse 255         grant 30 seconds of Quad Damage"), "quad cheat listed")

  helpSession = host.create([])
  before = len(helpSession.console.lines)
  assertTrue(host.executeCommand(helpSession, "cheats"), "cheats console command accepted")
  assertTrue(len(helpSession.console.lines) > before, "cheats prints console help")
  aliasBefore = len(helpSession.console.lines)
  assertTrue(host.executeCommand(helpSession, "cheatcodes"), "cheatcodes console command accepted")
  assertTrue(len(helpSession.console.lines) > aliasBefore, "cheatcodes prints console help")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "MiniQuake host_cmd tests starting: 4"
  result = try(testClientCommands())
  if result is error then print "FAIL client commands: " + result.message; return 1 end if
  print "[1/4] client command source/privilege/protocol"
  result = try(testSaveFormat())
  if result is error then print "FAIL save format: " + result.message; return 1 end if
  print "[2/4] save v5 roundtrip"
  result = try(testCheatStateSynchronization())
  if result is error then print "FAIL cheat synchronization: " + result.message; return 1 end if
  print "[3/4] god/give/impulse/invisible synchronization"
  result = try(testRegistration())
  if result is error then print "FAIL registration: " + result.message; return 1 end if
  print "[4/4] host/PR command registration"
  print "MiniQuake host_cmd tests passed: 4"
  return 0
end function
