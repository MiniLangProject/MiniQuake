/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors
*/

import miniquake.constants as c
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.server as server
import miniquake.sizebuf as sz
import miniquake.message as msg

function require(value, message)
  if not value then return error(9350, message) end if
  return true
end function

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
