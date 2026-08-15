/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/host_differential_fixture.ml.
*/
import miniquake.host as host
import miniquake.common as common
import miniquake.constants as c
import miniquake.cvar as cvar
import miniquake.keys as keys
import miniquake.sizebuf as sz
import miniquake.native as native

// Exercise bool text as part of this deterministic regression fixture.
function boolText(value)
  if value then return "true" end if
  return "false"
end function

// Create and initialize session.
function newSession(extra)
  return host.create(["-headless", "-nosound", "-nolan"] + extra)
end function

// Trace contains through the collision world.
function traceContains(trace, value)
  for each item in trace
    if item == value then return true end if
  end for
  return false
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  endSession = newSession([])
  endResult = try(host.Host_EndGame(endSession, "done"))
  print "{\"function\":\"Host_EndGame\",\"case\":\"disconnect_abort\",\"server_active\":" + boolText(endSession.server.active) + ",\"demonum\":" + endSession.demoNumber + ",\"abort\":" + boolText(endResult is error) + "}"

  errorSession = newSession([])
  errorSession.server.active = true
  errorSession.demoNumber = 4
  errorResult = try(host.Host_Error(errorSession, "bad"))
  print "{\"function\":\"Host_Error\",\"case\":\"disconnect_stopdemo_abort\",\"server_active\":" + boolText(errorSession.server.active) + ",\"demonum\":" + errorSession.demoNumber + ",\"abort\":" + boolText(errorResult is error) + "}"

  maxClients = host.Host_FindMaxClients(common.create(["-listen", "99"]))
  print "{\"function\":\"Host_FindMaxClients\",\"case\":\"listen_clamp\",\"maxclients\":" + maxClients[0] + ",\"limit\":" + maxClients[0] + ",\"dedicated\":" + boolText(maxClients[1]) + ",\"deathmatch\":1}"

  localSession = newSession([])
  host.Host_InitLocal(localSession)
  print "{\"function\":\"Host_InitLocal\",\"case\":\"registrations\",\"maxclients\":" + localSession.server.maxClients + ",\"deathmatch\":" + native.trunc(cvar.variableValue(localSession.cvars, "deathmatch")) + ",\"host_time\":" + native.trunc(localSession.hostTime) + "}"

  writeSession = newSession([])
  wrote = host.Host_WriteConfiguration(writeSession)
  print "{\"function\":\"Host_WriteConfiguration\",\"case\":\"uninitialized_skip\",\"wrote\":" + boolText(wrote) + "}"

  printSession = newSession([])
  printClient = printSession.server.clients[0]
  printClient.active = true
  sz.clear(printClient.message)
  host.SV_ClientPrintf(printClient, "hello")
  print "{\"function\":\"SV_ClientPrintf\",\"case\":\"print_message\",\"size\":" + printClient.message.curSize + ",\"opcode\":" + printClient.message.data[0] + ",\"terminated\":" + boolText(printClient.message.data[printClient.message.curSize - 1] == 0) + "}"

  broadcastSession = newSession(["-listen", "3"])
  broadcastSession.server.clients[0].active = true
  broadcastSession.server.clients[0].spawned = true
  broadcastSession.server.clients[1].active = true
  broadcastSession.server.clients[2].active = true
  broadcastSession.server.clients[2].spawned = true
  host.SV_BroadcastPrintf(broadcastSession, "all")
  print "{\"function\":\"SV_BroadcastPrintf\",\"case\":\"active_spawned_only\",\"first\":" + broadcastSession.server.clients[0].message.curSize + ",\"second\":" + broadcastSession.server.clients[1].message.curSize + ",\"third\":" + broadcastSession.server.clients[2].message.curSize + "}"

  commandSession = newSession([])
  commandClient = commandSession.server.clients[0]
  commandClient.active = true
  sz.clear(commandClient.message)
  host.Host_ClientCommands(commandClient, "echo hi")
  print "{\"function\":\"Host_ClientCommands\",\"case\":\"stufftext_message\",\"size\":" + commandClient.message.curSize + ",\"opcode\":" + commandClient.message.data[0] + ",\"terminated\":" + boolText(commandClient.message.data[commandClient.message.curSize - 1] == 0) + "}"

  dropSession = newSession(["-listen", "2"])
  dropped = dropSession.server.clients[0]
  peer = dropSession.server.clients[1]
  dropped.active = true
  dropped.spawned = true
  dropped.name = "one"
  peer.active = true
  peer.spawned = true
  sz.clear(peer.message)
  host.SV_DropClient(dropSession, dropped, true)
  print "{\"function\":\"SV_DropClient\",\"case\":\"crash_drop\",\"active\":" + boolText(dropped.active) + ",\"name_empty\":" + boolText(dropped.name == "") + ",\"old_frags\":" + dropped.oldFrags + ",\"peer_notice\":" + peer.message.curSize + "}"

  shutdownServerSession = newSession([])
  shutdownServerSession.server.active = true
  shutdownServerSession.server.clients[0].active = true
  host.Host_ShutdownServer(shutdownServerSession, true)
  print "{\"function\":\"Host_ShutdownServer\",\"case\":\"active_crash\",\"active\":" + boolText(shutdownServerSession.server.active) + ",\"clients_cleared\":" + boolText(not shutdownServerSession.server.clients[0].active) + "}"

  clearSession = newSession([])
  clearSession.server.active = true
  clearSession.client.signon = c.SIGNONS
  host.Host_ClearMemory(clearSession)
  print "{\"function\":\"Host_ClearMemory\",\"case\":\"clear_runtime\",\"signon\":" + clearSession.client.signon + ",\"server_active\":" + boolText(clearSession.server.active) + ",\"client_cleared\":" + boolText(len(clearSession.client.entities) == 0) + "}"

  filterSession = newSession([])
  firstFilter = host.Host_FilterTime(filterSession, 0.005)
  secondFilter = host.Host_FilterTime(filterSession, 0.020)
  print "{\"function\":\"Host_FilterTime\",\"case\":\"filter_then_accept\",\"first\":" + boolText(firstFilter) + ",\"second\":" + boolText(secondFilter) + ",\"realtime_ms\":" + native.trunc(filterSession.timing.realtime * 1000.0) + ",\"old_ms\":" + native.trunc(filterSession.timing.oldRealtime * 1000.0) + ",\"frametime_ms\":" + native.trunc(filterSession.timing.frameTime * 1000.0) + "}"

  consoleSession = newSession([])
  consoleCommands = host.Host_GetConsoleCommands(consoleSession, ["status", "map start"])
  print "{\"function\":\"Host_GetConsoleCommands\",\"case\":\"two_lines\",\"commands\":" + consoleCommands + "}"

  serverFrameSession = newSession([])
  keys.Key_Init()
  keys.setDestination(keys.KEY_GAME)
  serverFrameSession.server.active = true
  serverFrameSession.timing.frameTime = 0.02
  host.Host_ServerFrame(serverFrameSession)
  print "{\"function\":\"Host_ServerFrame\",\"case\":\"singleplayer_game\",\"datagram_cleared\":" + boolText(serverFrameSession.server.datagram.curSize == 0) + ",\"server_time_ms\":" + native.trunc(serverFrameSession.server.time * 1000.0) + ",\"simulated\":" + serverFrameSession.simulatedFrames + ",\"frametime_ms\":" + native.trunc(serverFrameSession.timing.frameTime * 1000.0) + "}"

  directFrame = newSession([])
  keys.Key_Init()
  keys.setDestination(keys.KEY_GAME)
  directFrame.server.active = true
  initialHostTime = directFrame.hostTime
  host._Host_Frame(directFrame, 0.02)
  print "{\"function\":\"_Host_Frame\",\"case\":\"active_connected\",\"framecount\":" + directFrame.timing.frameCount + ",\"server_advanced\":" + boolText(directFrame.simulatedFrames == 1) + ",\"screen\":" + boolText(traceContains(directFrame.frameTrace, "screen")) + ",\"audio\":" + boolText(traceContains(directFrame.frameTrace, "audio")) + ",\"host_delta_ms\":" + native.trunc((directFrame.hostTime - initialHostTime) * 1000.0) + "}"

  publicFrame = newSession([])
  keys.Key_Init()
  keys.setDestination(keys.KEY_GAME)
  publicFrame.server.active = true
  host.Host_Frame(publicFrame, 0.02)
  screenCount = 0
  if traceContains(publicFrame.frameTrace, "screen") then screenCount = 1 end if
  print "{\"function\":\"Host_Frame\",\"case\":\"unprofiled\",\"framecount\":" + publicFrame.timing.frameCount + ",\"server\":" + publicFrame.simulatedFrames + ",\"screen\":" + screenCount + "}"

  vcrSession = newSession([])
  vcrResult = try(host.Host_InitVCR(vcrSession))
  print "{\"function\":\"Host_InitVCR\",\"case\":\"no_switch\",\"accepted\":" + boolText(vcrResult is not error and vcrResult) + "}"

  initSession = host.create(["-dedicated", "2", "-nosound", "-nolan"])
  initSession.startMap = ""
  initResult = try(host.Host_Init(initSession))
  print "{\"function\":\"Host_Init\",\"case\":\"dedicated\",\"initialized\":" + boolText(initResult is not error and initSession.initialized) + ",\"maxclients\":" + initSession.server.maxClients + ",\"host_time\":" + native.trunc(initSession.hostTime) + "}"

  shutdownSession = newSession([])
  firstShutdown = host.Host_Shutdown(shutdownSession)
  secondShutdown = host.Host_Shutdown(shutdownSession)
  print "{\"function\":\"Host_Shutdown\",\"case\":\"once_only\",\"first_effect\":" + boolText(firstShutdown and not shutdownSession.running) + ",\"recursive_ignored\":" + boolText(not secondShutdown) + "}"
  return 0
end function
