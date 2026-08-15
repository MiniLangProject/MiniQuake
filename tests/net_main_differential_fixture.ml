/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/net_main_differential_fixture.ml.
*/
import miniquake.net_main as netmain
import miniquake.net_loop as netloop
import miniquake.sizebuf as sz

struct FixtureClient
  active
  socket
end struct

// Exercise bool int as part of this deterministic regression fixture.
function boolInt(value)
  if value then return 1 end if
  return 0
end function

// Add the requested value to the destination state.
function emit(functionName, caseName, result, index, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"index\":" + index +
    ",\"value\":" + value + ",\"count\":" + count + "}"
end function

// Return initialized state derived from the active module state.
function initializedState(maxClients, noLan)
  state = netloop.createState()
  netmain.NET_Init(state, maxClients, false, false, 26000, noLan)
  return state
end function

// Return fatal mode derived from the active module state.
function fatalMode(mode)
  state = netloop.createState()
  result = void
  if mode == "--error-free-socket" then
    netmain.NET_Init(state, 1, false, false, 26000, true)
    result = try(netmain.NET_FreeQSocket(netloop.createSocket()))
  else
    result = try(netmain.NET_Init(state, 1, false, false, void, true))
  end if
  if result is error then return 42 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 then return fatalMode(args[0]) end if

  clock = netmain.SetNetTime()
  emit("SetNetTime", "clock", boolInt(clock > 0.0), 0, 0, 1)

  state = initializedState(1, true)
  socket = netmain.NET_NewQSocket()
  counts = netmain.NET_SocketCounts()
  emit("NET_NewQSocket", "initialize",
    boolInt(socket is not void and socket.canSend and not socket.disconnected),
    counts[0], 0, counts[1])
  netmain.NET_FreeQSocket(socket)
  counts = netmain.NET_SocketCounts()
  emit("NET_FreeQSocket", "recycle", boolInt(socket.disconnected), counts[0], 0, counts[1])

  state = initializedState(1, true)
  enabled = try(netmain.NET_Listen_f(state, true, 26000))
  emit("NET_Listen_f", "enable", boolInt(netmain.NET_IsListening()),
    boolInt(enabled is error), 0, boolInt(netmain.NET_IsListening()))
  queried = netmain.NET_Listen_f(state, void, 0)
  emit("NET_Listen_f", "query", boolInt(queried), 1, 0, boolInt(netmain.NET_IsListening()))

  state = initializedState(1, true)
  maximum = netmain.MaxPlayers_f(2, 4, false, 5)
  emit("MaxPlayers_f", "clamp_enable_listen", maximum[0],
    boolInt(maximum[3] != ""), boolInt(maximum[2]), boolInt(maximum[1]))
  activeMaximum = netmain.MaxPlayers_f(maximum[0], 4, true, 5)
  emit("MaxPlayers_f", "active_server", activeMaximum[0],
    boolInt(activeMaximum[3] != ""), boolInt(activeMaximum[1]), 1)

  state = initializedState(1, true)
  try(netmain.NET_Listen_f(state, true, 26000))
  changed = try(netmain.NET_Port_f(state, 27500))
  ports = netmain.NET_PortState()
  emit("NET_Port_f", "change_while_listening", ports[0], ports[1], 0,
    boolInt(changed is error) + 1)
  rejected = try(netmain.NET_Port_f(state, 70000))
  ports = netmain.NET_PortState()
  emit("NET_Port_f", "reject_range", ports[0], boolInt(rejected is error), 0, 2)

  header = netmain.PrintSlistHeader()
  emit("PrintSlistHeader", "header", 1, len(header), 0, len(header))
  netmain.NET_ReplaceHostCache([
    ["10.0.0.1:26000", "Alpha", "start", 1, 4, 15],
    ["10.0.0.2:26000", "Beta", "e1m1", 0, 0, 15],
  ])
  lines = netmain.PrintSlist()
  remaining = netmain.PrintSlist()
  emit("PrintSlist", "new_entries", len(lines), len(lines), 0,
    len(lines) + len(remaining))
  trailer = netmain.PrintSlistTrailer()
  emit("PrintSlistTrailer", "nonempty", 1, boolInt(len(trailer) == 2), 0, 2)
  netmain.NET_ReplaceHostCache([])
  trailer = netmain.PrintSlistTrailer()
  emit("PrintSlistTrailer", "empty", 1, boolInt(len(trailer) == 2), 0, 0)

  state = initializedState(1, true)
  started = netmain.NET_Slist_f(state, false, true, 26000)
  poll = netmain.NET_PollProcedureSnapshot()
  emit("NET_Slist_f", "start", boolInt(started), len(poll), 3, 0)
  netmain.NET_ClearPollProcedures()
  netmain.NET_SetSlistStartTime(netmain.SetNetTime() - 2.0)
  netmain.Slist_Poll()

  state = initializedState(1, true)
  netmain.NET_Slist_f(state, false, true, 26000)
  netmain.NET_ClearPollProcedures()
  netmain.NET_SetSlistStartTime(netmain.SetNetTime() + 100.0)
  sendSearch = try(netmain.Slist_Send())
  poll = netmain.NET_PollProcedureSnapshot()
  emit("Slist_Send", "broadcast", boolInt(sendSearch is error),
    boolInt(len(poll) == 1), 0, 1)

  state = initializedState(1, true)
  netmain.NET_Slist_f(state, false, false, 26000)
  netmain.NET_ClearPollProcedures()
  netmain.NET_SetSlistStartTime(netmain.SetNetTime() - 2.0)
  netmain.Slist_Poll()
  flags = netmain.NET_SlistFlags()
  emit("Slist_Poll", "finish",
    boolInt(not flags[0] and not flags[1] and flags[2]), 1, 0, 1)

  cachedState = initializedState(1, true)
  cachedState.hostCache = [["bad:70000", "Friendly", "start", 0, 4, 15]]
  cached = try(netmain.NET_Connect(cachedState, "friendly", 1))
  localState = initializedState(1, true)
  localClient = netmain.NET_Connect(localState, "local", 1)
  emit("NET_Connect", "cache_and_local",
    boolInt(cached is error and localClient is not void), 1, 0, 0)

  localServer = netmain.NET_CheckNewConnections(localState)
  counts = netmain.NET_SocketCounts()
  emit("NET_CheckNewConnections", "second_driver",
    boolInt(localServer is not void and counts[0] == 2), 1, 0, 1)

  closeState = initializedState(1, true)
  closeSocket = netmain.NET_Connect(closeState, "local", 1)
  closed = netmain.NET_Close(closeSocket)
  counts = netmain.NET_SocketCounts()
  emit("NET_Close", "driver_and_recycle",
    boolInt(closed and closeSocket.disconnected), 1, 0, counts[1])

  getState = initializedState(1, true)
  getSocket = netloop.createSocket()
  getSocket.transport = "test-datagram"
  getSocket.driver = 1
  getSocket.messages = [bytes([9])]
  getSocket.messageTypes = [1]
  netmain.NET_TrackSocket(getSocket)
  destination = sz.alloc(32)
  received = netmain.NET_GetMessage(getSocket, destination, 1.0)
  getSocket.lastReceiveTime = -1000000000.0
  timedOut = netmain.NET_GetMessage(getSocket, destination, 1.0)
  counters = netmain.NET_MessageCounters()
  emit("NET_GetMessage", "receive_then_timeout", received, counters[1], 0,
    boolInt(timedOut == -1 and getSocket.disconnected))

  sendState = initializedState(1, true)
  sendSocket = netloop.createSocket()
  sendSocket.transport = "test-datagram"
  sendSocket.driver = 1
  sendPeer = netloop.createSocket()
  sendSocket.peer = sendPeer
  sendPeer.peer = sendSocket
  netmain.NET_TrackSocket(sendSocket)
  data = sz.alloc(16)
  sz.writeBytes(data, bytes([1, 2, 3]))
  sent = netmain.NET_SendMessage(sendSocket, data)
  emit("NET_SendMessage", "reliable", sent, boolInt(sent == 1), 0,
    boolInt(len(sendPeer.messages) == 1))

  unreliable = netmain.NET_SendUnreliableMessage(sendSocket, data)
  emit("NET_SendUnreliableMessage", "unreliable", unreliable,
    boolInt(unreliable == 1), 0, boolInt(len(sendPeer.messages) == 2))

  sendSocket.canSend = true
  canSend = netmain.NET_CanSendMessage(sendSocket)
  emit("NET_CanSendMessage", "driver", boolInt(canSend), boolInt(canSend), 0,
    boolInt(sendSocket.disconnected))

  localSend = netloop.createSocket()
  localPeer = netloop.createSocket()
  localSend.peer = localPeer
  localPeer.peer = localSend
  localSend.driver = 0
  remoteSend = netloop.createSocket()
  remotePeer = netloop.createSocket()
  remoteSend.peer = remotePeer
  remotePeer.peer = remoteSend
  remoteSend.driver = 1
  remoteSend.transport = "test-datagram"
  sendAllResult = netmain.NET_SendToAll([
    FixtureClient(true, localSend),
    FixtureClient(true, remoteSend),
  ], data, -1.0)
  emit("NET_SendToAll", "loop_and_remote", sendAllResult,
    len(localPeer.messages) + len(remotePeer.messages), 0, 1)

  initState = netloop.createState()
  initResult = netmain.NET_Init(initState, 4, false, false, 27500, false)
  counts = netmain.NET_SocketCounts()
  ports = netmain.NET_PortState()
  emit("NET_Init", "port_no_listen", counts[2], ports[0], 10,
    4 * boolInt(initResult == 0 and counts[1] == 5))

  shutdownSocket = netmain.NET_NewQSocket()
  shutdown = netmain.NET_Shutdown(initState)
  counts = netmain.NET_SocketCounts()
  emit("NET_Shutdown", "close_all",
    boolInt(shutdown and shutdownSocket.disconnected and counts[0] == 0),
    boolInt(counts[1] == 0 and counts[2] == 0), 0, 1)

  state = initializedState(1, true)
  netmain.SchedulePollProcedure("slist_poll", -1.0, void)
  executed = netmain.NET_Poll()
  poll = netmain.NET_PollProcedureSnapshot()
  pollResult = 0
  if executed == 1 then pollResult = 7 end if
  emit("NET_Poll", "restore_and_execute", pollResult, len(poll), 0, 1)

  netmain.NET_ClearPollProcedures()
  netmain.SchedulePollProcedure("third", 0.3, 3)
  netmain.SchedulePollProcedure("first", 0.1, 1)
  netmain.SchedulePollProcedure("second", 0.2, 2)
  poll = netmain.NET_PollProcedureSnapshot()
  order = poll[0][2] * 100 + poll[1][2] * 10 + poll[2][2]
  count = len(poll)
  netmain.NET_ClearPollProcedures()
  emit("SchedulePollProcedure", "sorted", order,
    len(netmain.NET_PollProcedureSnapshot()), 0, count)
  return 0
end function
