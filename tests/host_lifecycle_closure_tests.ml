/* BP-034: WinQuake host lifecycle, transition and shutdown closure. */

import miniquake.host_lifecycle_contract as contract
import miniquake.host as host

function yes(value, name)
  if not value then return error(3400, name + ": expected true") end if
  return true
end function
function no(value, name)
  if value then return error(3401, name + ": expected false") end if
  return true
end function
function equal(actual, expected, name)
  if actual != expected then return error(3402, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function equalList(actual, expected, name)
  equal(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    equal(actual[index], expected[index], name + " item " + index)
    index = index + 1
  end while
  return true
end function
function run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function session()
  return host.create(["-headless", "-nosound", "-nolan"])
end function
function testStatus()
  equal(contract.STATUS, "host_lifecycle_109_frozen_v1", "status")
  return true
end function
function testFingerprintConstant()
  equal(contract.CONTRACT_FINGERPRINT, 0x8cbb709f, "fingerprint")
  return true
end function
function testFingerprintRuntime()
  yes(contract.verify(), "canonical fingerprint")
  return true
end function
function testLocalFrameCount()
  equal(len(contract.localFrameStages()), 19, "local frame stage count")
  return true
end function
function testLocalSendStage()
  equal(contract.localFrameStages()[3], "local_send", "local send stage")
  return true
end function
function testRemoteSendStage()
  equal(contract.remoteFrameStages()[3], "remote_send", "remote send stage")
  return true
end function
function testDemoSendStage()
  equal(contract.demoFrameStages()[3], "demo_send", "demo send stage")
  return true
end function
function testServerFrameNoPhysics()
  equalList(contract.serverFrameStages(false), ["clear_datagram", "new_clients", "run_clients", "send_messages"], "paused server")
  return true
end function
function testServerFramePhysics()
  equalList(contract.serverFrameStages(true), ["clear_datagram", "new_clients", "run_clients", "physics", "send_messages"], "active server")
  return true
end function
function testMapCount()
  equal(len(contract.mapReplaceStages()), 6, "map stages")
  return true
end function
function testMapShutdownOrder()
  value = contract.mapReplaceStages()
  equal(value[1], "disconnect_client", "map disconnect")
  equal(value[2], "shutdown_server", "map shutdown")
  equal(value[4], "spawn_server", "map spawn")
  return true
end function
function testChangeLevelCount()
  equal(len(contract.changeLevelStages()), 4, "changelevel stages")
  return true
end function
function testChangeLevelSaveOrder()
  value = contract.changeLevelStages()
  equal(value[0], "save_spawnparms", "save spawn parms")
  equal(value[2], "spawn_server", "changelevel spawn")
  return true
end function
function testRestartCount()
  equal(len(contract.restartStages()), 3, "restart stages")
  return true
end function
function testRestartPreservesParms()
  equal(contract.restartStages()[1], "preserve_spawnparms", "restart spawn parms")
  return true
end function
function testSaveLayoutCount()
  equal(len(contract.savegameStages()), 9, "save layout")
  return true
end function
function testSaveLayoutVersion()
  equal(contract.SAVEGAME_VERSION, 5, "save version")
  equal(contract.SAVEGAME_COMMENT_LENGTH, 39, "comment length")
  equal(contract.SPAWN_PARM_COUNT, 16, "spawn parms")
  equal(contract.LIGHTSTYLE_COUNT, 64, "lightstyles")
  return true
end function
function testShutdownCount()
  equal(len(contract.shutdownStages()), 6, "shutdown stages")
  return true
end function
function testShutdownTimeouts()
  equal(contract.SHUTDOWN_FLUSH_SECONDS, 3, "flush timeout")
  equal(contract.SHUTDOWN_BROADCAST_SECONDS, 5, "broadcast timeout")
  return true
end function
function testErrorStages()
  equalList(contract.errorStages(), ["recursion_guard", "end_loading", "shutdown_server", "disconnect_client", "stop_demo_loop", "abort_frame"], "error stages")
  return true
end function
function testInactiveShutdown()
  no(host.Host_ShutdownServer(session(), false), "inactive shutdown")
  return true
end function
function testMapUsage()
  no(host.Host_Map_f(session(), ["map"]), "map usage")
  return true
end function
function testChangelevelInactive()
  no(host.Host_Changelevel_f(session(), ["changelevel", "start"]), "inactive changelevel")
  no(host.Host_Restart_f(session()), "inactive restart")
  return true
end function
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

function main(args)
  tests = [
    ["status",testStatus],["fingerprint constant",testFingerprintConstant],["fingerprint runtime",testFingerprintRuntime],
    ["local frame count",testLocalFrameCount],["local send",testLocalSendStage],["remote send",testRemoteSendStage],["demo send",testDemoSendStage],
    ["server paused",testServerFrameNoPhysics],["server physics",testServerFramePhysics],["map count",testMapCount],["map order",testMapShutdownOrder],
    ["changelevel count",testChangeLevelCount],["changelevel order",testChangeLevelSaveOrder],["restart count",testRestartCount],["restart parms",testRestartPreservesParms],
    ["save layout",testSaveLayoutCount],["save constants",testSaveLayoutVersion],["shutdown count",testShutdownCount],["shutdown timeouts",testShutdownTimeouts],
    ["error stages",testErrorStages],["inactive shutdown",testInactiveShutdown],["map usage",testMapUsage],["inactive transition",testChangelevelInactive],["quit paths",testQuitPaths],
  ]
  passed=0; index=0
  while index < len(tests)
    if run(index+1, tests[index][0], tests[index][1]) then passed=passed+1 end if
    index=index+1
  end while
  if passed != 24 then return 1 end if
  print "MiniQuake BP-034 host lifecycle closure tests passed: 24"
  return 0
end function
