/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-034: WinQuake host lifecycle, transition and shutdown closure.
*/
import miniquake.host_lifecycle_contract as contract
import miniquake.host as host
import miniquake.server as server
import miniquake.filesystem as qfs
import miniquake.screen as screen
import miniquake.constants as c
import miniquake.cvar as cvar
import miniquake.keys as keys
import miniquake.input as gameInput

// Assert that the condition holds and identify a failing test.
function yes(value, name)
  if not value then return error(3400, name + ": expected true") end if
  return true
end function
// Exercise no as part of this deterministic regression fixture.
function no(value, name)
  if value then return error(3401, name + ": expected false") end if
  return true
end function
// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(3402, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Report whether list.
function equalList(actual, expected, name)
  equal(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    equal(actual[index], expected[index], name + " item " + index)
    index = index + 1
  end while
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/25] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Exercise session as part of this deterministic regression fixture.
function session()
  return host.create(["-headless", "-nosound", "-nolan"])
end function
// Verify status against the expected Quake behavior.
function testStatus()
  equal(contract.STATUS, "host_lifecycle_109_frozen_v1", "status")
  return true
end function
// Verify fingerprint constant against the expected Quake behavior.
function testFingerprintConstant()
  equal(contract.CONTRACT_FINGERPRINT, 0x8cbb709f, "fingerprint")
  return true
end function
// Verify fingerprint runtime against the expected Quake behavior.
function testFingerprintRuntime()
  yes(contract.verify(), "canonical fingerprint")
  return true
end function
// Verify local frame count against the expected Quake behavior.
function testLocalFrameCount()
  equal(len(contract.localFrameStages()), 19, "local frame stage count")
  return true
end function
// Verify local send stage against the expected Quake behavior.
function testLocalSendStage()
  equal(contract.localFrameStages()[3], "local_send", "local send stage")
  return true
end function
// Verify remote send stage against the expected Quake behavior.
function testRemoteSendStage()
  equal(contract.remoteFrameStages()[3], "remote_send", "remote send stage")
  return true
end function
// Verify demo send stage against the expected Quake behavior.
function testDemoSendStage()
  equal(contract.demoFrameStages()[3], "demo_send", "demo send stage")
  return true
end function
// Verify server frame no physics against the expected Quake behavior.
function testServerFrameNoPhysics()
  equalList(contract.serverFrameStages(false), ["clear_datagram", "new_clients", "run_clients", "send_messages"], "paused server")
  return true
end function
// Verify server frame physics against the expected Quake behavior.
function testServerFramePhysics()
  equalList(contract.serverFrameStages(true), ["clear_datagram", "new_clients", "run_clients", "physics", "send_messages"], "active server")
  return true
end function
// Verify map count against the expected Quake behavior.
function testMapCount()
  equal(len(contract.mapReplaceStages()), 6, "map stages")
  return true
end function
// Verify map shutdown order against the expected Quake behavior.
function testMapShutdownOrder()
  value = contract.mapReplaceStages()
  equal(value[1], "disconnect_client", "map disconnect")
  equal(value[2], "shutdown_server", "map shutdown")
  equal(value[4], "spawn_server", "map spawn")
  return true
end function
// Verify change level count against the expected Quake behavior.
function testChangeLevelCount()
  equal(len(contract.changeLevelStages()), 4, "changelevel stages")
  return true
end function
// Verify change level save order against the expected Quake behavior.
function testChangeLevelSaveOrder()
  value = contract.changeLevelStages()
  equal(value[0], "save_spawnparms", "save spawn parms")
  equal(value[2], "spawn_server", "changelevel spawn")
  return true
end function
// Verify restart count against the expected Quake behavior.
function testRestartCount()
  equal(len(contract.restartStages()), 3, "restart stages")
  return true
end function
// Verify restart preserves parms against the expected Quake behavior.
function testRestartPreservesParms()
  equal(contract.restartStages()[1], "preserve_spawnparms", "restart spawn parms")
  return true
end function
// Verify save layout count against the expected Quake behavior.
function testSaveLayoutCount()
  equal(len(contract.savegameStages()), 9, "save layout")
  return true
end function
// Verify save layout version against the expected Quake behavior.
function testSaveLayoutVersion()
  equal(contract.SAVEGAME_VERSION, 5, "save version")
  equal(contract.SAVEGAME_COMMENT_LENGTH, 39, "comment length")
  equal(contract.SPAWN_PARM_COUNT, 16, "spawn parms")
  equal(contract.LIGHTSTYLE_COUNT, 64, "lightstyles")
  return true
end function
// Verify shutdown count against the expected Quake behavior.
function testShutdownCount()
  equal(len(contract.shutdownStages()), 6, "shutdown stages")
  return true
end function
// Verify shutdown timeouts against the expected Quake behavior.
function testShutdownTimeouts()
  equal(contract.SHUTDOWN_FLUSH_SECONDS, 3, "flush timeout")
  equal(contract.SHUTDOWN_BROADCAST_SECONDS, 5, "broadcast timeout")
  return true
end function
// Verify error stages against the expected Quake behavior.
function testErrorStages()
  equalList(contract.errorStages(), ["recursion_guard", "end_loading", "shutdown_server", "disconnect_client", "stop_demo_loop", "abort_frame"], "error stages")
  return true
end function
// Verify inactive shutdown against the expected Quake behavior.
function testInactiveShutdown()
  no(host.Host_ShutdownServer(session(), false), "inactive shutdown")
  return true
end function
// Verify map usage against the expected Quake behavior.
function testMapUsage()
  no(host.Host_Map_f(session(), ["map"]), "map usage")
  runtime = server.create(1)
  missing = try(server.spawn(runtime, qfs.create(".", "id1"), "__miniquake_missing_map__", 1.0))
  yes(missing is error, "missing map returns an error")
  no(runtime.loading, "missing map clears loading state")
  no(runtime.active, "missing map leaves server inactive")
  yes(runtime.worldModel is void, "missing map clears world model")
  failedSession = session()
  failedSession.filesystem = qfs.create(".", "id1")
  failedSession.server.active = true
  failedSession.server.mapName = "start"
  failedSession.client.connected = true
  failedSession.client.signon = c.SIGNONS
  failedSession.demoNumber = 7
  failedSession.server.serverFlags = 42
  failedSession.client.spawnParms = "keep"
  oldConsoleLines = len(failedSession.console.lines)
  failedTransition = try(host.Host_Map_f(failedSession, ["map", "__miniquake_missing_map__"]))
  no(failedTransition, "missing map command is rejected")
  no(failedSession.server.loading, "missing map command clears loading state")
  yes(failedSession.server.active, "missing map command preserves active server")
  yes(failedSession.client.connected, "missing map command preserves client connection")
  equal(failedSession.server.mapName, "start", "missing map command preserves current map")
  equal(failedSession.demoNumber, 7, "missing map command preserves demo sequence")
  equal(failedSession.server.serverFlags, 42, "missing map command preserves server flags")
  equal(failedSession.client.spawnParms, "keep", "missing map command preserves spawn parms")
  yes(len(failedSession.console.lines) > oldConsoleLines, "missing map command prints console diagnostic")
  no(screen.SCR_DrawLoading(320, 200), "missing map command never starts loading plaque")
  attractSession = session()
  attractSession.startMap = ""
  attractSession.headless = false
  attractSession.demoNumber = 0
  yes(host.Host_Startdemos_f(attractSession, ["startdemos", "demo1", "demo2"]), "attract demos queue")
  equal(attractSession.demoNumber, 1, "attract loop advances to second slot")
  equal(attractSession.demoLoop[0], "demo1", "attract first demo")
  equal(attractSession.demoLoop[1], "demo2", "attract second demo")
  equal(attractSession.commands.text, "playdemo demo1\n", "attract first command")
  // A demo may finish immediately before the menu input frame, leaving its
  // successor in Cbuf. The first New Game selection must discard that command
  // and queue only the normal single-player startup sequence.
  attractSession.commands.text = "playdemo demo2\necho keep\n"
  attractSession.demoNumber = 2
  attractSession.menu.page = "singleplayer"
  attractSession.menu.selection = 0
  yes(host.executeMenuSelection(attractSession), "new game selection")
  equal(attractSession.demoNumber, -1, "new game stops attract loop")
  equal(attractSession.commands.text, "echo keep\ndisconnect\nmaxplayers 1\nmap start\n", "new game removes queued attract demo")

  // Joining from the multiplayer menu has the same race with a demo that
  // completed earlier in the input frame. The queued successor must be gone
  // before connect runs or it will disconnect the newly signed-on client.
  joinSession = session()
  joinSession.startMap = ""
  joinSession.headless = false
  joinSession.demoNumber = 2
  joinSession.commands.text = "playdemo demo2\necho keep\n"
  joinSession.menu.active = true
  joinSession.menu.lanPort = 26000
  yes(host.handleExactMenuAction(joinSession, ["connect", "127.0.0.1"]), "menu join selection")
  equal(joinSession.demoNumber, -1, "menu join stops attract loop")
  equal(joinSession.commands.text, "echo keep\nconnect \"127.0.0.1\"\n", "menu join removes queued attract demo")
  no(joinSession.menu.active, "menu join closes menu")

  // quake.rc executes stuffcmds before startdemos. A startup +connect can
  // therefore finish first; startdemos must preserve the -1 sentinel written
  // by Host_Connect_f instead of replacing the live network game with demo1.
  connectedSession = session()
  connectedSession.startMap = ""
  connectedSession.headless = false
  connectedSession.client.connected = true
  connectedSession.demoNumber = -1
  yes(host.Host_Startdemos_f(connectedSession, ["startdemos", "demo1", "demo2"]), "connected startdemos is harmless")
  equal(connectedSession.demoNumber, -1, "connected startdemos preserves stopped attract loop")
  equal(connectedSession.commands.text, "", "connected startdemos queues no playdemo")
  return true
end function
// Verify changelevel inactive against the expected Quake behavior.
function testChangelevelInactive()
  no(host.Host_Changelevel_f(session(), ["changelevel", "start"]), "inactive changelevel")
  no(host.Host_Restart_f(session()), "inactive restart")
  return true
end function
// Verify quit paths against the expected Quake behavior.
function testQuitPaths()
  menuSession = session()
  yes(host.Host_Quit_f(menuSession), "menu quit request")
  yes(menuSession.running, "menu confirmation keeps host running")
  yes(menuSession.menu.active, "quit menu active")
  consoleSession = session()
  consoleSession.console.active = true
  yes(host.Host_Quit_f(consoleSession), "console quit")
  no(consoleSession.running, "console quit stops host")
  return true
end function

// Persist representative input, gameplay, audio and video settings through the
// exact config.cfg writer and command-buffer loader used by production startup.
function testSettingsPersistence()
  root = "build\\settings_persistence_fixture"
  configPath = qfs.join(root, "id1\\config.cfg")
  qfs.COM_CreatePath(configPath)
  saved = host.create(["-basedir", root, "-headless", "-nosound", "-nolan"])
  settings = [
    ["vid_width", "1920"], ["vid_height", "1080"], ["vid_bpp", "32"],
    ["vid_fullscreen", "1"], ["vid_renderer", "vulkan"],
    ["r_lighting", "1"], ["r_shadows", "1"], ["r_shadowquality", "2"],
    ["gamma", "0.750000"], ["viewsize", "110"], ["sensitivity", "4.500000"],
    ["volume", "0.600000"], ["bgmvolume", "0.800000"],
    ["host_maxfps", "240"], ["_windowed_mouse", "1"],
  ]
  for each setting in settings
    cvar.set(saved.cvars, setting[0], setting[1])
  end for
  keys.Key_SetBinding(119, "+forward")
  saved.initialized = true
  yes(host.Host_WriteConfiguration(saved), "settings config write")
  yes(qfs.fileExists(saved.filesystem, "config.cfg"), "settings config exists")

  loaded = host.create(["-basedir", root, "-headless", "-nosound", "-nolan"])
  host.queueStartupCommands(loaded)
  yes(host.executeCommandBuffer(loaded, 4096) > 0, "settings config executed")
  for each setting in settings
    equal(cvar.variableString(loaded.cvars, setting[0]), setting[1], "roundtrip " + setting[0])
  end for
  equal(gameInput.bindingForCode(119), "+forward", "roundtrip key binding")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  tests = [
    ["status",testStatus],["fingerprint constant",testFingerprintConstant],["fingerprint runtime",testFingerprintRuntime],
    ["local frame count",testLocalFrameCount],["local send",testLocalSendStage],["remote send",testRemoteSendStage],["demo send",testDemoSendStage],
    ["server paused",testServerFrameNoPhysics],["server physics",testServerFramePhysics],["map count",testMapCount],["map order",testMapShutdownOrder],
    ["changelevel count",testChangeLevelCount],["changelevel order",testChangeLevelSaveOrder],["restart count",testRestartCount],["restart parms",testRestartPreservesParms],
    ["save layout",testSaveLayoutCount],["save constants",testSaveLayoutVersion],["shutdown count",testShutdownCount],["shutdown timeouts",testShutdownTimeouts],
    ["error stages",testErrorStages],["inactive shutdown",testInactiveShutdown],["map usage",testMapUsage],["inactive transition",testChangelevelInactive],["quit paths",testQuitPaths],
    ["settings persistence",testSettingsPersistence],
  ]
  passed=0; index=0
  while index < len(tests)
    if run(index+1, tests[index][0], tests[index][1]) then passed=passed+1 end if
    index=index+1
  end while
  if passed != 25 then return 1 end if
  print "MiniQuake BP-034 host lifecycle closure tests passed: 25"
  return 0
end function
