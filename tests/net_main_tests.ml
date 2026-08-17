/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/net_main_tests.ml.
*/
import miniquake.constants as c
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.server as server
import miniquake.sizebuf as sz
import miniquake.message as msg

// Assert that the condition holds and identify a failing test.
function require(value, message)
  if not value then return error(9350, message) end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  state = netloop.createState()
  require(netmain.NET_Init(state, 2, false, false, 26000, true) == -1, "-nolan init")
  require(netmain.net_numsockets == 3, "qsocket pool size")

  pooled = netmain.NET_NewQSocket()
  require(pooled is not void and not pooled.disconnected, "NET_NewQSocket")
  netmain.NET_FreeQSocket(pooled)
  require(pooled.disconnected, "NET_FreeQSocket")
  externallyClosed = netmain.NET_NewQSocket()
  require(externallyClosed is not void, "externally closed allocation")
  netloop.close(externallyClosed)
  require(netmain.NET_Close(externallyClosed), "NET_Close releases preclosed qsocket")
  recycled = netmain.NET_NewQSocket()
  require(recycled is not void, "preclosed qsocket pool slot recycled")
  netmain.NET_FreeQSocket(recycled)

  // A driver-side disconnect can precede the higher-level NET_Close call.
  // Merely querying socket counts used to discard that active identity
  // without returning it to the finite pool, eventually crashing reconnects
  // with "NET_NewQSocket: no qsocket available".
  externallyCompacted = netmain.NET_NewQSocket()
  require(externallyCompacted is not void, "externally compacted allocation")
  netloop.close(externallyCompacted)
  compactedCounts = netmain.NET_SocketCounts()
  require(compactedCounts[0] == 0 and compactedCounts[1] == compactedCounts[2], "compaction reclaims disconnected qsocket")
  require(netmain.NET_Close(externallyCompacted), "close after compaction is idempotent")

  // net_loop reuses the same two loopback socket objects.  Repeatedly move
  // them through active/free state and force compaction between driver close
  // and NET_Close; neither aliases nor duplicate free entries may accumulate.
  cycle = 0
  while cycle < 12
    cycleClient = netmain.NET_Connect(state, "local", 1)
    cycleServer = netmain.NET_CheckNewConnections(state)
    require(cycleClient is not void and cycleClient is not error, "loop reconnect client " + cycle)
    require(cycleServer is not void and cycleServer is not error, "loop reconnect server " + cycle)
    netloop.close(cycleClient)
    netloop.close(cycleServer)
    netmain.NET_SocketCounts()
    require(netmain.NET_Close(cycleClient), "loop reconnect client release " + cycle)
    require(netmain.NET_Close(cycleServer), "loop reconnect server release " + cycle)
    cycleCounts = netmain.NET_SocketCounts()
    require(cycleCounts[0] == 0 and cycleCounts[1] == cycleCounts[2], "loop reconnect pool remains complete " + cycle)
    cycle = cycle + 1
  end while

  // Reproduce the crash path itself: the driver closes both endpoints and a
  // new connection arrives before either owner calls NET_Close.  Tracking the
  // new endpoints must reclaim the old slots during its own compaction.
  cycle = 0
  while cycle < 12
    earlyClient = netmain.NET_Connect(state, "local", 1)
    earlyServer = netmain.NET_CheckNewConnections(state)
    require(earlyClient is not void and earlyClient is not error, "early reconnect client " + cycle)
    require(earlyServer is not void and earlyServer is not error, "early reconnect server " + cycle)
    netloop.close(earlyClient)
    netloop.close(earlyServer)
    cycle = cycle + 1
  end while
  earlyCounts = netmain.NET_SocketCounts()
  require(earlyCounts[0] == 0 and earlyCounts[1] == earlyCounts[2], "early reconnects reclaim complete pool")

  // The ordinary executable boots with maxplayers 1 and therefore initially
  // owns two qsockets. Hosting through the multiplayer menu later raises
  // maxplayers without restarting NET. The arena must grow to four server
  // clients plus the listen host's local client socket before the first join.
  netmain.NET_Shutdown(state)
  hostState = netloop.createState()
  require(netmain.NET_Init(hostState, 1, false, false, 26000, true) == -1, "single-player boot network init")
  bootCounts = netmain.NET_SocketCounts()
  require(bootCounts[2] == 2, "single-player boot qsocket capacity")
  require(netmain.NET_SetMaximumClients(4) == 4, "multiplayer menu raises maxplayers")
  grownCounts = netmain.NET_SocketCounts()
  require(grownCounts[0] == 0 and grownCounts[1] == 5 and grownCounts[2] == 5, "listen qsocket arena grows with maxplayers")
  hostClient = netmain.NET_Connect(hostState, "local", 1)
  hostServer = netmain.NET_CheckNewConnections(hostState)
  require(hostClient is not void and hostClient is not error, "listen host local client")
  require(hostServer is not void and hostServer is not error, "listen host local server socket")
  remoteSockets = []
  remoteIndex = 0
  while remoteIndex < 3
    remoteSocket = netloop.createSocket()
    remoteSocket.transport = "udp"
    remoteSocket.address = "192.0.2." + (remoteIndex + 1)
    trackedRemote = netmain.NET_TrackSocket(remoteSocket)
    require(trackedRemote is not error, "external multiplayer join " + remoteIndex)
    remoteSockets = remoteSockets + [trackedRemote]
    remoteIndex = remoteIndex + 1
  end while
  fullHostCounts = netmain.NET_SocketCounts()
  require(fullHostCounts[0] == 5 and fullHostCounts[1] == 0 and fullHostCounts[2] == 5, "listen host supports local plus three remote clients")
  for each remoteSocket in remoteSockets
    require(netmain.NET_Close(remoteSocket), "external multiplayer release")
  end for
  require(netmain.NET_Close(hostClient), "listen host client release")
  require(netmain.NET_Close(hostServer), "listen host server release")
  releasedHostCounts = netmain.NET_SocketCounts()
  require(releasedHostCounts[0] == 0 and releasedHostCounts[1] == releasedHostCounts[2], "grown listen pool fully recyclable")
  netmain.NET_Shutdown(hostState)
  state = netloop.createState()
  require(netmain.NET_Init(state, 2, false, false, 26000, true) == -1, "restore loop-only test network")
  require(netmain.IsID("192.246.40.17", true), "IsID positive")
  require(not netmain.IsID("192.246.41.17", true), "IsID mask")

  // Driver 0 remains available when -nolan disables UDP.  Exercise the
  // production NET_Slist/Slist_Send call chain rather than Loop_Search alone.
  netloop.configureServer(state, "UNNAMED", "e1m1", 0, 2)
  require(netmain.NET_Slist_f(state, true, true, 26000), "start local-only slist")
  localSearch = netmain.Slist_Send()
  require(localSearch is not error, "loop discovery survives disabled datagram driver")
  require(netmain.hostCacheCount == 1, "production slist local host count")
  require(netmain.hostcache[0][0] == "local", "production slist local canonical name")
  netmain.NET_ClearPollProcedures()

  clientSocket = netmain.NET_Connect(state, "LOCAL", 1)
  serverSocket = netmain.NET_CheckNewConnections(state)
  require(clientSocket is not void and serverSocket is not void, "loop connection")

  gameServer = server.create(1)
  gameServer.active = true
  accepted = server.acceptLocal(gameServer, serverSocket)
  require(accepted is not error, "accept")
  require(netmain.net_activeconnections == 1, "active connection counter")
  require(server.sendReliableMessages(gameServer) > 0, "queued serverinfo delivery")
  queued = netmain.NET_QueueSnapshot()
  require(queued[0] >= 2, "queue snapshot active qsockets")
  require(queued[3] >= 1 and queued[4] > 0, "queue snapshot pending serverinfo")

  incoming = sz.alloc(c.MAX_MSGLEN)
  require(netmain.NET_GetMessage(clientSocket, incoming, 300.0) == 1, "initial serverinfo")
  accepted.spawned = true
  accepted.spawnParms[0] = 42.0
  retainedSocket = accepted.socket
  snapshot = server.beginChangeLevel(gameServer)
  require(netmain.NET_GetMessage(clientSocket, incoming, 300.0) == 1, "reconnect delivery")
  reader = msg.beginReadingBytes(sz.dataSlice(incoming))
  require(msg.readByte(reader) == c.SVC_STUFFTEXT, "reconnect command")
  require(msg.readString(reader) == "reconnect\n", "reconnect text")

  accepted.active = false
  accepted.spawned = false
  accepted.socket = void
  require(server.finishChangeLevel(gameServer, snapshot) == 1, "restore client")
  require(gameServer.clients[0].socket == retainedSocket, "retain qsocket")
  require(gameServer.clients[0].spawnParms[0] == 42.0, "retain spawn parms")
  require(not gameServer.clients[0].spawned, "restart signon")

  server.shutdown(gameServer)
  require(netmain.net_activeconnections == 0, "release connection")
  netmain.NET_Shutdown(state)
  print "MiniQuake net_main tests passed"
  return 0
end function
