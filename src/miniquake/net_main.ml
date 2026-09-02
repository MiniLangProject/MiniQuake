/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.net_main.
*/
package miniquake.net_main

// Functional pendant of WinQuake/net_main.c.  Driver-specific packet framing
// remains in net_loop/net_datagram; this module owns the public NET_* lifecycle,
// qsocket pool, polling queue, discovery state, timeouts and aggregate counters.

import miniquake.net_loop as netloop
import miniquake.net_datagram as datagram
import miniquake.sizebuf as sz
import miniquake.platform.win32 as win
import miniquake.byteio as bio

/// Tracks the module-level defaul tnet hostport state owned by `miniquake.net_main`.
DEFAULTnet_hostport = 26000
/// Tracks the module-level net hostport state owned by `miniquake.net_main`.
net_hostport = 26000
/// Tracks the module-level net time state owned by `miniquake.net_main`.
net_time = 0.0
/// Tracks the module-level net driverlevel state owned by `miniquake.net_main`.
net_driverlevel = 0
/// Tracks the module-level net numsockets state owned by `miniquake.net_main`.
net_numsockets = 0
/// Tracks the module-level net socket reserve state owned by `miniquake.net_main`.
net_socketReserve = 1
/// Tracks the module-level net activeconnections state owned by `miniquake.net_main`.
net_activeconnections = 0
/// Tracks the module-level net active sockets state owned by `miniquake.net_main`.
net_activeSockets = []
/// Tracks the module-level net free sockets state owned by `miniquake.net_main`.
net_freeSockets = []

/// Tracks the module-level messages sent state owned by `miniquake.net_main`.
messagesSent = 0
/// Tracks the module-level messages received state owned by `miniquake.net_main`.
messagesReceived = 0
/// Tracks the module-level unreliable messages sent state owned by `miniquake.net_main`.
unreliableMessagesSent = 0
/// Tracks the module-level unreliable messages received state owned by `miniquake.net_main`.
unreliableMessagesReceived = 0

/// Tracks the module-level listening state owned by `miniquake.net_main`.
listening = false
/// Tracks the module-level slist in progress state owned by `miniquake.net_main`.
slistInProgress = false
/// Tracks the module-level slist silent state owned by `miniquake.net_main`.
slistSilent = false
/// Tracks the module-level slist local state owned by `miniquake.net_main`.
slistLocal = true
/// Tracks the module-level slist start time state owned by `miniquake.net_main`.
slistStartTime = 0.0
/// Tracks the module-level slist last shown state owned by `miniquake.net_main`.
slistLastShown = 0
/// Tracks the module-level host cache count state owned by `miniquake.net_main`.
hostCacheCount = 0
/// Tracks the module-level hostcache state owned by `miniquake.net_main`.
hostcache = []
/// Tracks the module-level poll procedure list state owned by `miniquake.net_main`.
pollProcedureList = []

/// Tracks the module-level network state owned by `miniquake.net_main`.
networkState = void
/// Tracks the module-level maximum clients state owned by `miniquake.net_main`.
maximumClients = 1
/// Tracks the module-level slist port state owned by `miniquake.net_main`.
slistPort = 26000
/// Tracks the module-level net messagetimeout state owned by `miniquake.net_main`.
net_messagetimeout = 300.0

// Update module state for net time.
function SetNetTime()
  global net_time
  net_time = win.ticks() / 1000.0
  return net_time
end function

/// Implements the `arrayTail` operation for `miniquake.net_main` (array tail).
/// @param values The values input consumed by `arrayTail`.
function arrayTail(values)
  result = []
  index = 1
  while index < len(values)
    result = result + [values[index]]
    index = index + 1
  end while
  return result
end function

/// Report whether the requested socket identity is present in an array.
/// @param values The values input consumed by `socketArrayContains`.
/// @param wanted The wanted input consumed by `socketArrayContains`.
function socketArrayContains(values, wanted)
  for each socket in values
    if socket == wanted then return true end if
  end for
  return false
end function

/// Return a socket array with every occurrence of one identity removed.
/// @param values The values input consumed by `socketArrayWithout`.
/// @param unwanted The unwanted input consumed by `socketArrayWithout`.
function socketArrayWithout(values, unwanted)
  result = []
  for each socket in values
    if socket is not void and socket != unwanted and not socketArrayContains(result, socket) then
      result = result + [socket]
    end if
  end for
  return result
end function

/// Add one socket identity at most once.
/// @param values The values input consumed by `appendUniqueSocket`.
/// @param socket Network socket used for communication.
function appendUniqueSocket(values, socket)
  if socket is void or socketArrayContains(values, socket) then return values end if
  return values + [socket]
end function

// Compact the active list and reclaim externally disconnected qsocket slots.
// Driver code may mark a socket disconnected before NET_Close observes it.
// The C engine still returns that fixed qsocket_t to net_freeSockets; dropping
// the MiniLang object here permanently shrank the pool on every reconnect.
function compactActiveSockets()
  global net_activeSockets, net_freeSockets
  active = []
  reclaimed = []
  for each socket in net_activeSockets
    if socket is not void then
      if socket.disconnected then
        reclaimed = appendUniqueSocket(reclaimed, socket)
      else
        active = appendUniqueSocket(active, socket)
      end if
    end if
  end for
  free = []
  for each socket in net_freeSockets
    if socket is not void and not socketArrayContains(active, socket) then
      // net_loop.connect reactivates its persistent loopback object before
      // NET_TrackSocket moves that same identity out of this free list.
      // Do not close such a temporarily reactivated pooled object here.
      free = appendUniqueSocket(free, socket)
    end if
  end for
  for each socket in reclaimed
    if not socketArrayContains(active, socket) then free = appendUniqueSocket(free, socket) end if
  end for
  net_activeSockets = active
  net_freeSockets = free
  return len(active)
end function

/// Update module state for qsocket.
/// @param socket Network socket used for communication.
function resetQSocket(socket)
  now = SetNetTime()
  socket.peer = void
  socket.messages = []
  socket.messageTypes = []
  socket.canSend = true
  socket.disconnected = false
  socket.transport = "loop"
  socket.udp = void
  socket.address = "UNSET ADDRESS"
  socket.port = 0
  socket.channel = void
  socket.lastReceiveTime = now
  socket.connectTime = now
  socket.lastSendTime = now
  socket.driver = net_driverlevel
  socket.landriver = 0
  return socket
end function

// Mirror Quake's NET_NewQSocket routine and its observable state changes.
function NET_NewQSocket()
  global net_activeSockets, net_freeSockets
  compactActiveSockets()
  if net_activeconnections >= maximumClients then return void end if
  if len(net_freeSockets) == 0 then return void end if
  socket = net_freeSockets[0]
  net_freeSockets = arrayTail(net_freeSockets)
  resetQSocket(socket)
  net_activeSockets = [socket] + net_activeSockets
  return socket
end function

// Ensure sufficient storage or state for socket pool.
function ensureSocketPool()
  global net_numsockets, net_freeSockets
  if net_numsockets > 0 then return net_numsockets end if
  net_numsockets = maximumClients + net_socketReserve
  index = 0
  while index < net_numsockets
    socket = netloop.createSocket()
    socket.disconnected = true
    net_freeSockets = [socket] + net_freeSockets
    index = index + 1
  end while
  return net_numsockets
end function

/// Grow the fixed qsocket arena when maxplayers is raised before a server
/// starts. Host_FindMaxClients reserves at least four client slots in Quake;
/// MiniQuake resizes its server dynamically, so the network arena must mirror
/// that growth instead of retaining the two sockets from a single-player boot.
/// @param clientCount Number of entries or units to process.
function ensureSocketPoolCapacity(clientCount)
  global net_numsockets, net_freeSockets
  wanted = clientCount + net_socketReserve
  if wanted < net_socketReserve then wanted = net_socketReserve end if
  while net_numsockets < wanted
    socket = netloop.createSocket()
    socket.disconnected = true
    net_freeSockets = appendUniqueSocket(net_freeSockets, socket)
    net_numsockets = net_numsockets + 1
  end while
  return net_numsockets
end function

/// Mirror Quake's NET_TrackSocket routine and its observable state changes.
/// @param socket Network socket used for communication.
function NET_TrackSocket(socket)
  global net_activeSockets, net_freeSockets
  if socket is void or socket is error then return socket end if
  ensureSocketPool()
  compactActiveSockets()
  // net_loop deliberately reuses its client/server objects.  Once such an
  // object has been returned to this pool, move that exact object back to the
  // active list instead of consuming another free identity and leaving an
  // active/free alias behind.
  if socketArrayContains(net_activeSockets, socket) then return socket end if
  alreadyPooled = socketArrayContains(net_freeSockets, socket)
  if len(net_activeSockets) >= net_numsockets or (not alreadyPooled and len(net_freeSockets) == 0) then
    netloop.close(socket)
    return error(3441, "NET_NewQSocket: no qsocket available")
  end if
  if alreadyPooled then
    net_freeSockets = socketArrayWithout(net_freeSockets, socket)
  else
    net_freeSockets = arrayTail(net_freeSockets)
  end if
  net_activeSockets = [socket] + net_activeSockets
  return socket
end function

/// Mirror Quake's NET_FreeQSocket routine and its observable state changes.
/// @param socket Network socket used for communication.
function NET_FreeQSocket(socket)
  global net_activeSockets, net_freeSockets
  if socket is void then return false end if
  found = false
  active = []
  reclaimed = []
  for each item in net_activeSockets
    if item == socket then
      found = true
    else if item is not void and item.disconnected then
      reclaimed = appendUniqueSocket(reclaimed, item)
    else if item is not void then
      active = appendUniqueSocket(active, item)
    end if
  end for
  free = []
  for each item in net_freeSockets
    if item is not void and not socketArrayContains(active, item) then free = appendUniqueSocket(free, item) end if
  end for
  for each item in reclaimed
    if not socketArrayContains(active, item) then free = appendUniqueSocket(free, item) end if
  end for
  if not found then
    // A diagnostic/count query may already have compacted an externally
    // closed socket into the free list.  Treat the subsequent NET_Close as an
    // idempotent release without inserting a duplicate free-list entry.
    if socketArrayContains(free, socket) then
      net_activeSockets = active
      net_freeSockets = free
      return true
    end if
    return error(3442, "NET_FreeQSocket: not active")
  end if
  if not socket.disconnected then netloop.close(socket) end if
  net_activeSockets = active
  net_freeSockets = [socket] + socketArrayWithout(free, socket)
  return true
end function

// Mirror Quake's NET_ConnectionAccepted routine and its observable state changes.
function NET_ConnectionAccepted()
  global net_activeconnections
  net_activeconnections = net_activeconnections + 1
  return net_activeconnections
end function

// Mirror Quake's NET_ConnectionClosed routine and its observable state changes.
function NET_ConnectionClosed()
  global net_activeconnections
  if net_activeconnections > 0 then net_activeconnections = net_activeconnections - 1 end if
  return net_activeconnections
end function

/// Mirror Quake's NET_SetMaximumClients routine and its observable state changes.
/// @param count Number of entries or units to process.
function NET_SetMaximumClients(count)
  global maximumClients
  maximumClients = count
  if maximumClients < 1 then maximumClients = 1 end if
  ensureSocketPoolCapacity(maximumClients)
  return maximumClients
end function

/// Mirror Quake's NET_Listen_f routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Listen_f`.
/// @param enabled Whether the optional behavior is enabled.
/// @param port The port input consumed by `NET_Listen_f`.
function NET_Listen_f(state, enabled, port)
  global listening, net_hostport
  if enabled is void then return listening end if
  listening = enabled
  if port > 0 then net_hostport = port end if
  result = netloop.Datagram_Listen(state, listening, net_hostport)
  if result is error then return result end if
  return listening
end function

/// Mirror Quake's MaxPlayers_f routine and its observable state changes.
/// @param currentPlayers The current players input consumed by `MaxPlayers_f`.
/// @param maximumLimit The maximum limit input consumed by `MaxPlayers_f`.
/// @param serverActive The server active input consumed by `MaxPlayers_f`.
/// @param requested The requested input consumed by `MaxPlayers_f`.
function MaxPlayers_f(currentPlayers, maximumLimit, serverActive, requested)
  if requested is void then return [currentPlayers, currentPlayers > 1, currentPlayers > 1, ""] end if
  if serverActive then return [currentPlayers, listening, currentPlayers > 1, "maxplayers can not be changed while a server is running."] end if
  count = requested
  message = ""
  if count < 1 then count = 1 end if
  if count > maximumLimit then
    count = maximumLimit
    message = "\"maxplayers\" set to \"" + count + "\""
  end if
  return [count, count > 1, count > 1, message]
end function

/// Mirror Quake's NET_Port_f routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Port_f`.
/// @param requested The requested input consumed by `NET_Port_f`.
function NET_Port_f(state, requested)
  global DEFAULTnet_hostport, net_hostport
  if requested is void then return net_hostport end if
  if requested < 1 or requested > 65534 then return error(3440, "Bad value, must be between 1 and 65534") end if
  DEFAULTnet_hostport = requested
  net_hostport = requested
  if listening then
    stopped = try(NET_Listen_f(state, false, net_hostport))
    if stopped is error then return stopped end if
    started = try(NET_Listen_f(state, true, net_hostport))
    if started is error then return started end if
  end if
  return net_hostport
end function

// Format and emit slist header.
function PrintSlistHeader()
  global slistLastShown
  slistLastShown = 0
  return ["Server          Map             Users", "--------------- --------------- -----"]
end function

// Format and emit slist.
function PrintSlist()
  global slistLastShown
  lines = []
  index = slistLastShown
  while index < len(hostcache)
    item = hostcache[index]
    if item[4] > 0 then
      lines = lines + [item[1] + " " + item[2] + " " + item[3] + "/" + item[4]]
    else
      lines = lines + [item[1] + " " + item[2]]
    end if
    index = index + 1
  end while
  slistLastShown = index
  return lines
end function

// Format and emit slist trailer.
function PrintSlistTrailer()
  if hostCacheCount > 0 then return ["== end list ==", ""] end if
  return ["No Quake servers found.", ""]
end function

/// Mirror Quake's NET_ReplaceHostCache routine and its observable state changes.
/// @param items The items input consumed by `NET_ReplaceHostCache`.
function NET_ReplaceHostCache(items)
  global hostcache, hostCacheCount
  hostcache = items
  hostCacheCount = len(items)
  return hostCacheCount
end function

// Mirror Quake's NET_ClearPollProcedures routine and its observable state changes.
function NET_ClearPollProcedures()
  global pollProcedureList
  pollProcedureList = []
  return true
end function

/// Mirror Quake's NET_SetSlistStartTime routine and its observable state changes.
/// @param value Value consumed by `NET_SetSlistStartTime`.
function NET_SetSlistStartTime(value)
  global slistStartTime
  slistStartTime = value
  return slistStartTime
end function

// Mirror Quake's NET_SlistFlags routine and its observable state changes.
function NET_SlistFlags()
  return [slistInProgress, slistSilent, slistLocal]
end function

// Mirror Quake's NET_PollProcedureSnapshot routine and its observable state changes.
function inline NET_PollProcedureSnapshot()
  return pollProcedureList
end function

// Mirror Quake's NET_SocketCounts routine and its observable state changes.
function NET_SocketCounts()
  compactActiveSockets()
  return [len(net_activeSockets), len(net_freeSockets), net_numsockets]
end function

/// Return socket queued state derived from the active module state.
/// @param socket Network socket used for communication.
function socketQueuedState(socket)
  if socket is void then return [0, 0] end if
  queuedMessages = 0
  queuedBytes = 0
  for each payload in socket.messages
    queuedMessages = queuedMessages + 1
    queuedBytes = queuedBytes + len(payload)
  end for
  if socket.channel is not void then
    if len(socket.channel.sendMessage) > 0 then
      queuedMessages = queuedMessages + 1
      queuedBytes = queuedBytes + len(socket.channel.sendMessage)
    end if
    if len(socket.channel.receiveMessage) > 0 then
      queuedMessages = queuedMessages + 1
      queuedBytes = queuedBytes + len(socket.channel.receiveMessage)
    end if
  end if
  return [queuedMessages, queuedBytes]
end function

// QSocket counts alone cannot reveal a reliable fragment permanently waiting
// for an ACK.  Include completed queues and in-progress channel bytes so soak
// tests can prove that network work is bounded.
function NET_QueueSnapshot()
  compactActiveSockets()
  queuedMessages = 0
  queuedBytes = 0
  for each socket in net_activeSockets
    queued = socketQueuedState(socket)
    queuedMessages = queuedMessages + queued[0]
    queuedBytes = queuedBytes + queued[1]
  end for
  return [
    len(net_activeSockets),
    len(net_freeSockets),
    net_numsockets,
    queuedMessages,
    queuedBytes,
    len(pollProcedureList),
  ]
end function

// Mirror Quake's NET_PortState routine and its observable state changes.
function inline NET_PortState()
  return [net_hostport, DEFAULTnet_hostport]
end function

// Mirror Quake's NET_IsListening routine and its observable state changes.
function NET_IsListening()
  return listening
end function

// Mirror Quake's NET_MessageCounters routine and its observable state changes.
function NET_MessageCounters()
  synchronizeCounters()
  return [messagesSent, messagesReceived, unreliableMessagesSent, unreliableMessagesReceived]
end function

/// Implements the `SchedulePollProcedure` operation for `miniquake.net_main` (schedule poll procedure).
/// @param procedureName Name that identifies the requested value or resource.
/// @param timeOffset Zero-based offset of the requested data.
/// @param argument The argument input consumed by `SchedulePollProcedure`.
function SchedulePollProcedure(procedureName, timeOffset, argument)
  global pollProcedureList
  scheduled = SetNetTime() + timeOffset
  kept = []
  for each item in pollProcedureList
    if item[0] != procedureName then kept = kept + [item] end if
  end for
  inserted = false
  result = []
  for each item in kept
    if not inserted and item[1] >= scheduled then
      result = result + [[procedureName, scheduled, argument]]
      inserted = true
    end if
    result = result + [item]
  end for
  if not inserted then result = result + [[procedureName, scheduled, argument]] end if
  pollProcedureList = result
  return scheduled
end function

/// Mirror Quake's NET_Slist_f routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Slist_f`.
/// @param silent The silent input consumed by `NET_Slist_f`.
/// @param localOnly The local only input consumed by `NET_Slist_f`.
/// @param port The port input consumed by `NET_Slist_f`.
function NET_Slist_f(state, silent, localOnly, port)
  global networkState, slistInProgress, slistSilent, slistLocal, slistStartTime, hostCacheCount, hostcache, slistPort
  if slistInProgress then return false end if
  // A prior search may have had its poll queue cancelled by a menu change.
  // Start each discovery cycle with exactly one fresh control endpoint.
  netloop.Datagram_EndHostSearch()
  networkState = state
  slistSilent = silent
  slistLocal = localOnly
  slistPort = port
  slistInProgress = true
  slistStartTime = SetNetTime()
  hostcache = []
  hostCacheCount = 0
  state.hostCache = []
  SchedulePollProcedure("slist_send", 0.0, void)
  SchedulePollProcedure("slist_poll", 0.1, void)
  return true
end function

// Mirror Quake's Slist_Send routine and its observable state changes.
function Slist_Send()
  global hostcache, hostCacheCount
  if not slistInProgress or networkState is void then return false end if
  localState = networkState
  // net_dgrm.c broadcasts and drains a non-blocking persistent control socket;
  // replies are collected by Slist_Poll over the following 1.5 seconds.
  result = try(netloop.Datagram_SearchForHosts(localState, true, slistPort, 0))
  remoteHosts = []
  if result is not error then remoteHosts = result end if
  hostcache = remoteHosts
  // Driver 0 is Loop_SearchForHosts.  Console `slist` keeps slistLocal set
  // and must advertise an active in-process listen server before the
  // datagram results; the network menu deliberately clears the flag.  The
  // loop driver remains usable under -nolan, so a disabled UDP driver must
  // not suppress this result.
  if slistLocal and localState.mapName != "" then
    localHosts = netloop.Loop_SearchForHosts(localState, true, 0)
    localAlreadyPresent = false
    for each discovered in remoteHosts
      if len(discovered) > 0 and discovered[0] == "local" then localAlreadyPresent = true end if
    end for
    if not localAlreadyPresent then hostcache = localHosts + remoteHosts end if
  end if
  localState.hostCache = hostcache
  hostCacheCount = len(hostcache)
  if SetNetTime() - slistStartTime < 0.5 then SchedulePollProcedure("slist_send", 0.75, void) end if
  if result is error and len(hostcache) > 0 then return hostcache end if
  return result
end function

// Mirror Quake's Slist_Poll routine and its observable state changes.
function Slist_Poll()
  global hostcache, hostCacheCount, slistInProgress, slistSilent, slistLocal
  if not slistInProgress or networkState is void then return false end if
  localState = networkState
  // Drain all replies that arrived since the preceding frame without waiting.
  // Datagram_SearchForHosts stores the accumulated cache on the driver state.
  if localState.lanEnabled then
    result = try(netloop.Datagram_SearchForHosts(localState, false, slistPort, 0))
    if result is not error then localState.hostCache = result end if
  end if
  hostcache = localState.hostCache
  hostCacheCount = len(hostcache)
  if SetNetTime() - slistStartTime < 1.5 then
    SchedulePollProcedure("slist_poll", 0.1, void)
    return true
  end if
  slistInProgress = false
  slistSilent = false
  slistLocal = true
  netloop.Datagram_EndHostSearch()
  return false
end function

// Mirror Quake's NET_Poll routine and its observable state changes.
function NET_Poll()
  global pollProcedureList
  SetNetTime()
  executed = 0
  while len(pollProcedureList) > 0 and pollProcedureList[0][1] <= net_time
    item = pollProcedureList[0]
    pollProcedureList = arrayTail(pollProcedureList)
    if item[0] == "slist_send" then Slist_Send() else if item[0] == "slist_poll" then Slist_Poll() end if
    executed = executed + 1
    SetNetTime()
  end while
  return executed
end function

/// Implements the `cachedAddress` operation for `miniquake.net_main` (cached address).
/// @param state Mutable `miniquake.net_main` state used by `cachedAddress`.
/// @param host The host input consumed by `cachedAddress`.
function cachedAddress(state, host)
  wanted = host
  for each cached in state.hostCache
    if bio.lower(netloop.normalizeAddress(cached[1])) == bio.lower(netloop.normalizeAddress(host)) then return cached[0] end if
  end for
  return wanted
end function

/// Mirror Quake's NET_Connect routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Connect`.
/// @param host The host input consumed by `NET_Connect`.
/// @param timeoutMilliseconds The timeout milliseconds input consumed by `NET_Connect`.
function NET_Connect(state, host, timeoutMilliseconds)
  SetNetTime()
  target = host
  if target == "" then target = void end if
  targetLower = ""
  if target is not void then targetLower = bio.lower(target) end if
  if targetLower == "local" or targetLower == "localhost" then
    result = netloop.connect(state, "local")
    if result is not error and result is not void then
      tracked = NET_TrackSocket(result)
      if tracked is error then return tracked end if
    end if
    return result
  end if
  if target is not void then target = cachedAddress(state, target) end if
  if target is void then
    NET_Slist_f(state, true, true, net_hostport)
    while slistInProgress
      NET_Poll()
      win.sleep(1)
    end while
    if hostCacheCount != 1 then return void end if
    target = hostcache[0][0]
  end if
  result = netloop.Datagram_ConnectPort(state, target, timeoutMilliseconds, net_hostport)
  if result is not error and result is not void then
    tracked = NET_TrackSocket(result)
    if tracked is error then return tracked end if
  end if
  return result
end function

/// Strict external-reference connection path.  Unlike the regular Quake
/// menu connection, this keeps one UDP source endpoint alive and resends the
/// Protocol-3 request at a short interval until the original server accepts.
/// @param state Mutable `miniquake.net_main` state used by `NET_ConnectInterop`.
/// @param host The host input consumed by `NET_ConnectInterop`.
/// @param timeoutMilliseconds The timeout milliseconds input consumed by `NET_ConnectInterop`.
/// @param resendMilliseconds The resend milliseconds input consumed by `NET_ConnectInterop`.
function NET_ConnectInterop(state, host, timeoutMilliseconds, resendMilliseconds)
  SetNetTime()
  if host == "" then return error(3448, "NET_ConnectInterop requires a host") end if
  target = cachedAddress(state, host)
  result = netloop.Datagram_ConnectPersistent(state, target, timeoutMilliseconds, resendMilliseconds, net_hostport)
  if result is not error and result is not void then
    tracked = NET_TrackSocket(result)
    if tracked is error then return tracked end if
  end if
  return result
end function

/// Mirror Quake's NET_CheckNewConnections routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_CheckNewConnections`.
function NET_CheckNewConnections(state)
  SetNetTime()
  result = netloop.Datagram_CheckNewConnections(state)
  if result is not error and result is not void then
    tracked = NET_TrackSocket(result)
    if tracked is error then return tracked end if
  end if
  return result
end function

/// Mirror Quake's NET_Close routine and its observable state changes.
/// @param socket Network socket used for communication.
function NET_Close(socket)
  if socket is void then return false end if
  SetNetTime()
  // Datagram_CheckNewConnections may already have closed a crashed peer
  // before the server client observes the disconnect.  NET_Close must still
  // unlink that tracked qsocket and return its pool slot, just as the
  // original NET_Close/NET_FreeQSocket pair does.
  released = NET_FreeQSocket(socket)
  if released is error then
    if not socket.disconnected then netloop.close(socket) end if
    compactActiveSockets()
    return false
  end if
  return released
end function

// Update module state for counters.
function synchronizeCounters()
  global messagesSent, messagesReceived, unreliableMessagesSent, unreliableMessagesReceived
  messagesSent = netloop.messagesSent
  messagesReceived = netloop.messagesReceived
  unreliableMessagesSent = netloop.unreliableMessagesSent
  unreliableMessagesReceived = netloop.unreliableMessagesReceived
  return true
end function

/// Mirror Quake's NET_SetMessageTimeout routine and its observable state changes.
/// @param timeoutSeconds The timeout seconds input consumed by `NET_SetMessageTimeout`.
function NET_SetMessageTimeout(timeoutSeconds)
  global net_messagetimeout
  net_messagetimeout = timeoutSeconds
  return net_messagetimeout
end function

/// Mirror Quake's NET_SocketTimedOut routine and its observable state changes.
/// @param socket Network socket used for communication.
/// @param timeoutSeconds The timeout seconds input consumed by `NET_SocketTimedOut`.
function NET_SocketTimedOut(socket, timeoutSeconds)
  return netloop.timedOut(socket, timeoutSeconds)
end function

/// Mirror Quake's NET_GetMessage routine and its observable state changes.
/// @param socket Network socket used for communication.
/// @param destination Destination value or collection to update.
/// @param timeoutSeconds The timeout seconds input consumed by `NET_GetMessage`.
function NET_GetMessage(socket, destination, timeoutSeconds)
  if socket is void or socket.disconnected then return -1 end if
  SetNetTime()
  result = netloop.getMessage(socket, destination)
  if result == 0 and socket.driver != 0 and netloop.timedOut(socket, timeoutSeconds) then
    NET_Close(socket)
    return -1
  end if
  synchronizeCounters()
  return result
end function

/// Mirror Quake's NET_SendMessage routine and its observable state changes.
/// @param socket Network socket used for communication.
/// @param data Input data consumed by the operation.
function NET_SendMessage(socket, data)
  if socket is void or socket.disconnected then return -1 end if
  SetNetTime()
  result = netloop.sendMessage(socket, data)
  synchronizeCounters()
  return result
end function

/// Mirror Quake's NET_SendUnreliableMessage routine and its observable state changes.
/// @param socket Network socket used for communication.
/// @param data Input data consumed by the operation.
function NET_SendUnreliableMessage(socket, data)
  if socket is void or socket.disconnected then return -1 end if
  SetNetTime()
  result = netloop.sendUnreliableMessage(socket, data)
  synchronizeCounters()
  return result
end function

/// Mirror Quake's NET_CanSendMessage routine and its observable state changes.
/// @param socket Network socket used for communication.
function NET_CanSendMessage(socket)
  if socket is void or socket.disconnected then return false end if
  SetNetTime()
  return netloop.canSendMessage(socket)
end function

/// Mirror Quake's NET_CanSendUnreliableMessage routine and its observable state changes.
/// @param socket Network socket used for communication.
function NET_CanSendUnreliableMessage(socket)
  if socket is void or socket.disconnected then return false end if
  return true
end function

/// Mirror Quake's NET_SendToAll routine and its observable state changes.
/// @param clients The clients input consumed by `NET_SendToAll`.
/// @param data Input data consumed by the operation.
/// @param blocktime Time value used by the operation.
function NET_SendToAll(clients, data, blocktime)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  state1 = []
  state2 = []
  count = 0
  for each client in clients
    if client.active and client.socket is not void then
      if client.socket.driver == 0 then
        NET_SendMessage(client.socket, data)
        state1 = state1 + [true]
        state2 = state2 + [true]
      else
        state1 = state1 + [false]
        state2 = state2 + [false]
        count = count + 1
      end if
    else
      state1 = state1 + [true]
      state2 = state2 + [true]
    end if
  end for

  start = SetNetTime()
  scratch = sz.alloc(datagram.NET_MAXMESSAGE)
  while count > 0
    count = 0
    index = 0
    while index < len(clients)
      client = clients[index]
      if not state1[index] then
        if NET_CanSendMessage(client.socket) then
          state1[index] = true
          NET_SendMessage(client.socket, data)
        else
          NET_GetMessage(client.socket, scratch, net_messagetimeout)
        end if
        count = count + 1
      else if not state2[index] then
        if NET_CanSendMessage(client.socket) then
          state2[index] = true
        else
          NET_GetMessage(client.socket, scratch, net_messagetimeout)
        end if
        count = count + 1
      end if
      index = index + 1
    end while
    if SetNetTime() - start > blocktime then break end if
    if count > 0 then win.sleep(1) end if
  end while
  return count
end function

/// Mirror Quake's NET_Init routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Init`.
/// @param maxClients The max clients input consumed by `NET_Init`.
/// @param dedicated The dedicated input consumed by `NET_Init`.
/// @param listenRequested The listen requested input consumed by `NET_Init`.
/// @param requestedPort The requested port input consumed by `NET_Init`.
/// @param noLan The no lan input consumed by `NET_Init`.
function NET_Init(state, maxClients, dedicated, listenRequested, requestedPort, noLan)
  global networkState, maximumClients, net_numsockets, net_socketReserve, net_activeSockets, net_freeSockets
  global net_activeconnections, listening, DEFAULTnet_hostport, net_hostport, pollProcedureList
  if requestedPort is void then return error(3443, "NET_Init: you must specify a number after -port") end if
  networkState = state
  maximumClients = maxClients
  if maximumClients < 1 then maximumClients = 1 end if
  DEFAULTnet_hostport = requestedPort
  net_hostport = requestedPort
  listening = listenRequested or dedicated
  net_socketReserve = 1
  if dedicated then net_socketReserve = 0 end if
  net_numsockets = maximumClients + net_socketReserve
  net_activeSockets = []
  net_freeSockets = []
  net_activeconnections = 0
  pollProcedureList = []
  index = 0
  while index < net_numsockets
    socket = netloop.createSocket()
    socket.disconnected = true
    net_freeSockets = [socket] + net_freeSockets
    index = index + 1
  end while
  datagramResult = netloop.Datagram_Init(state, noLan)
  if datagramResult < 0 then return datagramResult end if
  SetNetTime()
  if listening then return NET_Listen_f(state, true, net_hostport) end if
  return 0
end function

/// Mirror Quake's NET_Shutdown routine and its observable state changes.
/// @param state Mutable `miniquake.net_main` state used by `NET_Shutdown`.
function NET_Shutdown(state)
  global net_numsockets, net_activeSockets, net_freeSockets, net_activeconnections, listening, pollProcedureList
  for each socket in net_activeSockets
    if socket is not void and not socket.disconnected then netloop.close(socket) end if
  end for
  net_activeSockets = []
  net_freeSockets = []
  net_numsockets = 0
  net_activeconnections = 0
  listening = false
  pollProcedureList = []
  netloop.Datagram_Shutdown(state)
  return true
end function

/// Report whether is id.
/// @param address Network address of the peer.
/// @param idgodsEnabled The idgods enabled input consumed by `IsID`.
function IsID(address, idgodsEnabled)
  if not idgodsEnabled then return false end if
  numeric = netloop.ipv4Number(address)
  if numeric is void then return false end if
  return (numeric & 0xffffff00) == 0xc0f62800
end function
