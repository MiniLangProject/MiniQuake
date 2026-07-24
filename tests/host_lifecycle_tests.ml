import miniquake.host as host
import miniquake.common as common
import miniquake.cvar as cvar
import miniquake.constants as c
import miniquake.keys as keys
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.client as clientRuntime

function assertEqual(actual, expected, name)
  if actual != expected then return error(9850, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9851, name + ": expected true") end if
  return true
end function

function assertNear(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(9852, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrace(actual, expected)
  assertEqual(len(actual), len(expected), "frame trace length")
  index = 0
  while index < len(expected)
    assertEqual(actual[index], expected[index], "frame trace stage " + index)
    index = index + 1
  end while
  return true
end function

function newSession(extra)
  return host.create(["-headless", "-nosound", "-nolan"] + extra)
end function

function testFindMaxClients()
  single = host.Host_FindMaxClients(common.create([]))
  assertEqual(single[0], 1, "default one client")
  assertEqual(single[1], false, "default not dedicated")
  listen = host.Host_FindMaxClients(common.create(["-listen", "99"]))
  assertEqual(listen[0], c.MAX_CLIENTS, "listen clamps scoreboard clients")
  dedicated = host.Host_FindMaxClients(common.create(["-dedicated"]))
  assertEqual(dedicated[0], 8, "dedicated default clients")
  dedicatedSession = host.create(["-dedicated", "2", "-nosound", "-nolan"])
  assertEqual(dedicatedSession.headless, true, "dedicated host suppresses presentation")
  conflict = try(host.Host_FindMaxClients(common.create(["-listen", "4", "-dedicated", "4"])))
  assertTrue(conflict is error, "listen and dedicated conflict")
  return true
end function

function testFilterTime()
  session = newSession([])
  assertEqual(host.Host_FilterTime(session, 0.005), false, "sub-72Hz frame filtered")
  assertEqual(session.timing.frameCount, 0, "filtered frame not counted")
  assertTrue(host.Host_FilterTime(session, 0.010), "accumulated 15ms frame accepted")
  assertNear(session.timing.frameTime, 0.015, 0.000001, "accepted accumulated frame time")
  cvar.set(session.cvars, "host_framerate", "0.033")
  assertTrue(host.Host_FilterTime(session, 0.020), "forced frame accepted")
  assertNear(session.timing.frameTime, 0.033, 0.000001, "host_framerate overrides simulation delta")
  cvar.set(session.cvars, "host_framerate", "0.25")
  assertTrue(host.Host_FilterTime(session, 0.020), "long forced frame accepted")
  assertNear(session.timing.frameTime, 0.25, 0.000001, "forced host_framerate is not clamped")

  timed = newSession([])
  timed.timedemoActive = true
  assertTrue(host.Host_FilterTime(timed, 0.0001), "timedemo bypasses 72Hz filter")
  assertNear(timed.timing.frameTime, 0.001, 0.000001, "timedemo still applies minimum frame bound")
  return true
end function

function testFrameOrder()
  session = newSession([])
  keys.Key_Init()
  keys.setDestination(keys.KEY_GAME)
  session.server.active = true
  assertTrue(host.Host_Frame(session, 0.02), "host frame accepted")
  assertTrace(session.frameTrace, [
    "filter", "commands", "net_poll", "local_send", "console", "server",
    "host_time", "client_read", "demo_scene", "entity_relink",
    "entity_effects", "client_events", "qc_control", "centerprint",
    "view", "screen", "dlight_decay", "particles", "audio",
  ])
  assertNear(session.hostTime, 1.02, 0.000001, "host time advances after server")
  assertNear(session.server.time, 0.02, 0.000001, "server physics time advances")
  assertEqual(session.simulatedFrames, 1, "simulation frame counted")

  keys.setDestination(keys.KEY_CONSOLE)
  assertTrue(host.Host_Frame(session, 0.02), "console frame accepted")
  assertNear(session.server.time, 0.02, 0.000001, "singleplayer console suppresses physics")
  assertEqual(session.simulatedFrames, 1, "suppressed physics not counted")
  host.Host_ClearMemory(session)
  assertEqual(session.server.active, false, "clear memory stops server")
  assertEqual(session.client.signon, c.SIGNON_NONE, "clear memory resets signon")
  return true
end function

function testErrorsDropAndShutdown()
  session = newSession(["-listen", "2"])
  session.server.active = true
  first = session.server.clients[0]
  second = session.server.clients[1]
  first.active = true
  first.spawned = true
  first.name = "one"
  second.active = true
  second.spawned = true
  second.name = "two"

  sz.clear(first.message)
  assertTrue(host.SV_ClientPrintf(first, "hello\n"), "client print queued")
  assertEqual(first.message.data[0], c.SVC_PRINT, "client print opcode")
  sz.clear(first.message)
  assertTrue(host.Host_ClientCommands(first, "echo hi\n"), "stufftext queued")
  assertEqual(first.message.data[0], c.SVC_STUFFTEXT, "stufftext opcode")
  assertTrue(host.SV_DropClient(session, first, true), "crashed client dropped")
  assertEqual(first.active, false, "drop clears active")

  ended = try(host.Host_Error(session, "fixture"))
  assertTrue(ended is error, "Host_Error abort result")
  assertEqual(session.server.active, false, "Host_Error shuts server down")
  assertEqual(session.inError, false, "Host_Error clears recursion guard")
  assertEqual(session.demoNumber, -1, "Host_Error stops demo loop")

  endSession = newSession([])
  endSession.server.active = true
  endedGame = try(host.Host_EndGame(endSession, "fixture complete"))
  assertTrue(endedGame is error, "Host_EndGame abort result")
  assertEqual(endSession.server.active, false, "Host_EndGame shuts local server down")

  dedicated = newSession(["-dedicated", "2"])
  dedicated.server.active = true
  dedicatedError = try(host.Host_Error(dedicated, "dedicated fixture"))
  assertTrue(dedicatedError is error, "dedicated Host_Error result")
  assertEqual(dedicated.running, false, "dedicated Host_Error terminates host")

  shutdownSession = newSession([])
  assertTrue(host.Host_Shutdown(shutdownSession), "first shutdown succeeds")
  assertEqual(host.Host_Shutdown(shutdownSession), false, "recursive shutdown is ignored")
  return true
end function

function testVcrExclusion()
  normal = newSession([])
  assertTrue(host.Host_InitVCR(normal), "normal host skips VCR")
  playback = newSession(["-playback"])
  rejected = try(host.Host_InitVCR(playback))
  assertTrue(rejected is error, "VCR playback explicitly rejected")
  return true
end function

function testProductionClientSendAndLoopSlist()
  network = netloop.createState()
  wireClient = netloop.Loop_Connect(network, "local")
  wireServer = netloop.Loop_CheckNewConnections(network)
  session = newSession([])
  session.client.socket = wireClient
  session.client.connected = true
  session.client.spawned = true
  session.client.signon = c.SIGNONS
  session.client.serverTime = 12.5
  session.client.command.forwardMove = 123.0
  clientRuntime.CL_SetMoveMessageCount(2)
  clientRuntime.queueString(session.client, "say parity\n")
  assertEqual(host.sendClientIntentions(session), 1, "production client intention send")

  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(wireServer, incoming, 300.0), 2, "clc_move is first packet")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.CLC_MOVE, "first packet move opcode")
  assertEqual(netmain.NET_GetMessage(wireServer, incoming, 300.0), 1, "reliable command is second packet")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.CLC_STRINGCMD, "second packet stringcmd opcode")
  netloop.Loop_Close(wireClient)

  slistSession = newSession([])
  netloop.configureServer(slistSession.network, "UNNAMED", "e1m1", 0, 1)
  assertEqual(netmain.NET_Init(slistSession.network, 1, false, false, 26000, true), -1, "disable datagram driver")
  assertTrue(host.executeCommand(slistSession, "slist"), "host slist retains loop driver under -nolan")
  assertEqual(netmain.hostCacheCount, 1, "host slist local result")
  assertEqual(netmain.hostcache[0][0], "local", "host slist local canonical name")
  netmain.NET_Shutdown(slistSession.network)
  return true
end function

function testShutdownReliableFlush()
  // A queued incoming reliable record makes Loop_GetMessage mark this
  // self-peered test socket sendable, deterministically exercising the
  // blocked -> ACK-polled -> flushed branch without wall-clock races.
  unblockedSession = newSession(["-listen", "1"])
  unblockedClient = unblockedSession.server.clients[0]
  unblockedClient.active = true
  unblockedSocket = netloop.createSocket()
  unblockedSocket.peer = unblockedSocket
  unblockedSocket.canSend = false
  unblockedSocket.messages = [bytes("ack")]
  unblockedSocket.messageTypes = [1]
  unblockedClient.socket = unblockedSocket
  msg.writeByte(unblockedClient.message, c.SVC_PRINT)
  msg.writeString(unblockedClient.message, "final\n")
  assertEqual(host.Host_FlushPendingClientMessages(unblockedSession, 0.05), 0, "blocked reliable becomes sendable")
  assertEqual(unblockedClient.message.curSize, 0, "unblocked reliable message flushed")

  blockedSession = newSession(["-listen", "1"])
  blockedClient = blockedSession.server.clients[0]
  blockedClient.active = true
  blockedSocket = netloop.createSocket()
  blockedSocket.peer = netloop.createSocket()
  blockedSocket.canSend = false
  blockedClient.socket = blockedSocket
  msg.writeByte(blockedClient.message, c.SVC_PRINT)
  msg.writeString(blockedClient.message, "blocked\n")
  assertEqual(host.Host_FlushPendingClientMessages(blockedSession, 0.0), 1, "blocked reliable timeout count")
  assertTrue(blockedClient.message.curSize > 0, "timed-out reliable remains pending")

  // The complete shutdown path must place all final reliable data before the
  // reliable svc_disconnect broadcast.
  shutdownNetwork = netloop.createState()
  assertEqual(netmain.NET_Init(shutdownNetwork, 1, false, false, 26000, true), -1, "shutdown loop-only network init")
  shutdownWireClient = netmain.NET_Connect(shutdownNetwork, "local", 1)
  shutdownWireServer = netmain.NET_CheckNewConnections(shutdownNetwork)
  shutdownSession = newSession(["-listen", "1"])
  shutdownSession.server.active = true
  shutdownClient = shutdownSession.server.clients[0]
  shutdownClient.active = true
  shutdownClient.socket = shutdownWireServer
  msg.writeByte(shutdownClient.message, c.SVC_PRINT)
  msg.writeString(shutdownClient.message, "score final\n")
  assertTrue(host.Host_ShutdownServer(shutdownSession, true), "shutdown server")
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(shutdownWireClient, incoming, 300.0), 1, "final reliable delivered")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.SVC_PRINT, "final reliable precedes disconnect")
  assertEqual(msg.readString(reader), "score final\n", "final reliable payload")
  assertEqual(netmain.NET_GetMessage(shutdownWireClient, incoming, 300.0), 1, "disconnect reliable delivered")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readByte(reader), c.SVC_DISCONNECT, "shutdown disconnect opcode")
  netmain.NET_Close(shutdownWireClient)
  netmain.NET_Shutdown(shutdownNetwork)
  return true
end function

function main(args)
  print "MiniQuake host lifecycle tests starting: 7"
  result = try(testFindMaxClients())
  if result is error then print "FAIL maxclients: " + result.message; return 1 end if
  print "[1/5] dedicated/listen maxclients"
  result = try(testFilterTime())
  if result is error then print "FAIL filter: " + result.message; return 1 end if
  print "[2/5] filter/timedemo/host_framerate"
  result = try(testFrameOrder())
  if result is error then print "FAIL frame order: " + result.message; return 1 end if
  print "[3/5] deterministic host frame order"
  result = try(testErrorsDropAndShutdown())
  if result is error then print "FAIL lifecycle: " + result.message; return 1 end if
  print "[4/5] error/drop/shutdown"
  result = try(testVcrExclusion())
  if result is error then print "FAIL VCR exclusion: " + result.message; return 1 end if
  print "[5/6] VCR exclusion"
  result = try(testProductionClientSendAndLoopSlist())
  if result is error then print "FAIL production client/slist: " + result.message; return 1 end if
  print "[6/7] production CL_SendCmd order / loop slist"
  result = try(testShutdownReliableFlush())
  if result is error then print "FAIL shutdown reliable flush: " + result.message; return 1 end if
  print "[7/7] shutdown pending reliable / disconnect order"
  print "MiniQuake host lifecycle tests passed: 7"
  return 0
end function
