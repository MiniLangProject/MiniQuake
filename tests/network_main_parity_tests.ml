/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-060: net_main.c public lifecycle, qsocket pool, polling and active-port parity.
*/

import miniquake.net_main as netmain
import miniquake.net_loop as netloop

testIndex = 0
failures = 0

function bp060Check(value, name)
  global testIndex, failures
  testIndex = testIndex + 1
  print "[" + testIndex + "/20] " + name
  if not value then
    failures = failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

function main(args)
  state = netloop.createState()
  bp060Check(netmain.DEFAULTnet_hostport == 26000, "historical default port")
  bp060Check(netmain.NET_Init(state, 2, false, false, 27500, true) == -1, "-nolan leaves loop driver")
  ports = netmain.NET_PortState()
  bp060Check(ports[0] == 27500 and ports[1] == 27500, "configured host port")
  counts = netmain.NET_SocketCounts()
  bp060Check(counts[2] == 3 and counts[0] == 0 and counts[1] == 3, "client qsocket pool size")

  low = netmain.MaxPlayers_f(4, 8, false, 0)
  bp060Check(low[0] == 1 and not low[1] and not low[2], "maxplayers lower clamp")
  high = netmain.MaxPlayers_f(1, 8, false, 99)
  bp060Check(high[0] == 8 and high[1] and high[2], "maxplayers upper clamp")
  active = netmain.MaxPlayers_f(4, 8, true, 2)
  bp060Check(active[0] == 4 and active[3] != "", "active server blocks maxplayers")

  bp060Check(try(netmain.NET_Port_f(state, 0)) is error and try(netmain.NET_Port_f(state, 65535)) is error, "reject invalid port range")
  bp060Check(netmain.NET_Port_f(state, 28001) == 28001, "accept valid port")

  netmain.NET_ClearPollProcedures()
  netmain.SchedulePollProcedure("late", 0.30, void)
  netmain.SchedulePollProcedure("early", 0.10, void)
  netmain.SchedulePollProcedure("middle", 0.20, void)
  poll = netmain.NET_PollProcedureSnapshot()
  bp060Check(len(poll) == 3 and poll[0][0] == "early" and poll[1][0] == "middle" and poll[2][0] == "late", "poll queue time order")
  netmain.SchedulePollProcedure("middle", 0.05, void)
  poll = netmain.NET_PollProcedureSnapshot()
  bp060Check(len(poll) == 3 and poll[0][0] == "middle", "poll procedure replacement")

  socket = netmain.NET_NewQSocket()
  bp060Check(socket is not void and not socket.disconnected, "allocate qsocket")
  netmain.NET_SetMaximumClients(1)
  netmain.NET_ConnectionAccepted()
  bp060Check(netmain.NET_NewQSocket() is void, "active connection limit")
  netmain.NET_ConnectionClosed()
  bp060Check(netmain.NET_FreeQSocket(socket), "free qsocket")
  reused = netmain.NET_NewQSocket()
  bp060Check(reused == socket and reused.address == "UNSET ADDRESS", "reuse reset qsocket")
  netmain.NET_FreeQSocket(reused)

  direct = netloop.resolveDatagramTarget(state, "127.0.0.1", 28001)
  bp060Check(direct[0] == "127.0.0.1" and direct[1] == 28001, "active default port reaches datagram target")
  explicit = netloop.resolveDatagramTarget(state, "127.0.0.1:29002", 28001)
  bp060Check(explicit[1] == 29002, "explicit port overrides active default")
  state.hostCache = [["10.20.30.40:30003", "Named Server", "start", 1, 4, 3]]
  cached = netloop.resolveDatagramTarget(state, "named server", 28001)
  bp060Check(cached[0] == "10.20.30.40" and cached[1] == 30003, "case-insensitive host cache resolution")

  bp060Check(netmain.NET_Shutdown(state), "network shutdown")
  counts = netmain.NET_SocketCounts()
  bp060Check(counts[0] == 0, "shutdown clears active sockets")

  if failures > 0 then
    print "MiniQuake BP-060 network main tests failed: " + failures + "/20"
    return 1
  end if
  print "MiniQuake BP-060 network main tests passed: 20"
  return 0
end function
