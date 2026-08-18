/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.net_loop.
*/
package miniquake.net_loop

import miniquake.types as t
import miniquake.sizebuf as sz
import miniquake.byteio as bio
import miniquake.net_udp as udp
import miniquake.net_datagram as datagram
import miniquake.net_control as control
import miniquake.platform.win32 as win

messagesSent = 0
messagesReceived = 0
unreliableMessagesSent = 0
unreliableMessagesReceived = 0
datagramSearchSocket = void

const LOOP_MAX_MESSAGE = 8192
const HOST_CACHE_SIZE = 8

// Create and initialize state.
function createState()
  return t.LoopState(void, void, void, void, void, "UNNAMED", "", 0, 1, [], [], 0, 0, [], [], true)
end function

// Create and initialize socket.
function createSocket()
  now = win.ticks() / 1000.0
  return t.LoopSocket(void, [], [], true, false, "loop", void, "", 0, void, now, now, now, 0, 0)
end function

// Create and initialize remote socket.
function createRemoteSocket(udpSocket, address, port)
  now = win.ticks() / 1000.0
  return t.LoopSocket(void, [], [], true, false, "udp", udpSocket, address, port, datagram.createChannel(), now, now, now, 1, 0)
end function

// Convert address into its canonical representation.
function normalizeAddress(address)
  lowered = bio.lower(address)
  if lowered == "localhost" or lowered == "local" then return "127.0.0.1" end if
  return address
end function

// Provide numeric address parts behavior for the active subsystem.
function numericAddressParts(address)
  source = bytes(address)
  if len(source) == 0 then return void end if
  parts = []
  start = 0
  index = 0
  while index <= len(source)
    if index == len(source) or source[index] == 46 then
      if index == start then return void end if
      value = toNumber(decode(slice(source, start, index - start)))
      if value is void or value is not int or value < 0 or value > 255 then return void end if
      parts = parts + [value]
      start = index + 1
    else if source[index] < 48 or source[index] > 57 then
      return void
    end if
    index = index + 1
  end while
  if len(parts) < 1 or len(parts) > 4 then return void end if
  return parts
end function

// WINS_GetAddrFromName routes digit-leading names through PartialIPAddress.
// Preserve that user-visible connect syntax in the production UDP path even
// though the x64 bridge uses sendto rather than the old landriver vtable.
function expandPartialIPAddress(address)
  parts = numericAddressParts(address)
  if parts is void or len(parts) == 4 then return address end if
  localParts = numericAddressParts(udp.localAddress())
  if localParts is void or len(localParts) != 4 then return address end if
  combined = array(4, 0)
  prefix = 4 - len(parts)
  index = 0
  while index < prefix
    combined[index] = localParts[index]
    index = index + 1
  end while
  partIndex = 0
  while partIndex < len(parts)
    combined[prefix + partIndex] = parts[partIndex]
    partIndex = partIndex + 1
  end while
  return combined[0] + "." + combined[1] + "." + combined[2] + "." + combined[3]
end function

// Read and validate address.
function parseAddress(text, defaultPort)
  data = bytes(text)
  colon = -1
  index = 0
  while index < len(data)
    if data[index] == 58 then colon = index end if
    index = index + 1
  end while
  address = text
  port = defaultPort
  if colon >= 0 then
    address = decode(slice(data, 0, colon))
    parsed = toNumber(decode(slice(data, colon + 1, len(data) - colon - 1)))
    if parsed is void or parsed < 1 or parsed > 65535 then return error(3430, "invalid UDP port in " + text) end if
    port = parsed
  end if
  address = normalizeAddress(address)
  source = bytes(address)
  if len(source) > 0 and source[0] >= 48 and source[0] <= 57 then address = expandPartialIPAddress(address) end if
  return [address, port]
end function

// Provide short text behavior for the active subsystem.
function shortText(text, maximum)
  data = bytes(text)
  if len(data) <= maximum then return text end if
  return decode(slice(data, 0, maximum))
end function

// Report whether is numeric address.
function isNumericAddress(address)
  data = bytes(address)
  if len(data) == 0 then return false end if
  dots = 0
  for each value in data
    if value == 46 then
      dots = dots + 1
    else if value < 48 or value > 57 then
      return false
    end if
  end for
  return dots == 3
end function

// Return ipv4 number derived from the active module state.
function ipv4Number(address)
  data = bytes(address)
  parts = []
  start = 0
  index = 0
  while index <= len(data)
    if index == len(data) or data[index] == 46 then
      if index == start then return void end if
      value = toNumber(decode(slice(data, start, index - start)))
      if value is void or value < 0 or value > 255 then return void end if
      parts = parts + [value]
      start = index + 1
    end if
    index = index + 1
  end while
  if len(parts) != 4 then return void end if
  return ((parts[0] & 255) << 24) | ((parts[1] & 255) << 16) | ((parts[2] & 255) << 8) | (parts[3] & 255)
end function

// Provide str addr behavior for the active subsystem.
function StrAddr(address, port)
  return address + ":" + port
end function

// Provide ipv4 text behavior for the active subsystem.
function inline ipv4Text(value)
  return ((value >> 24) & 255) + "." + ((value >> 16) & 255) + "." + ((value >> 8) & 255) + "." + (value & 255)
end function

// Mirror Quake's NET_Ban_f routine and its observable state changes.
function NET_Ban_f(state, arguments)
  if len(arguments) <= 1 then
    if state.banAddress == 0 then return "Banning not active" end if
    return "Banning " + ipv4Text(state.banAddress) + " [" + ipv4Text(state.banMask) + "]"
  end if
  if bio.lower(arguments[1]) == "off" then
    state.banAddress = 0
    state.banMask = 0xffffffff
    return ""
  end if
  address = ipv4Number(arguments[1])
  if address is void then return "BAN ip_address [mask]" end if
  mask = 0xffffffff
  if len(arguments) >= 3 then
    mask = ipv4Number(arguments[2])
    if mask is void then return "BAN ip_address [mask]" end if
  end if
  state.banAddress = address
  state.banMask = mask
  return ""
end function

// Add state for address is banned.
function addressIsBanned(state, address)
  if state.banAddress == 0 then return false end if
  numeric = ipv4Number(address)
  if numeric is void then return false end if
  return (numeric & state.banMask) == state.banAddress
end function

// Provide compact remote sockets behavior for the active subsystem.
function compactRemoteSockets(state)
  active = []
  for each socket in state.remoteSockets
    if not socket.disconnected then active = active + [socket] end if
  end for
  state.remoteSockets = active
  return len(active)
end function

// Establish the requested value using the active network transport.
function connect(state, host)
  if host != "local" and host != "localhost" then
    target = host
    wanted = bio.lower(host)
    for each cached in state.hostCache
      if bio.lower(cached[1]) == wanted then target = cached[0]; break end if
    end for
    parsed = parseAddress(target, 26000)
    if parsed is error then return parsed end if
    return connectRemote(state, parsed[0], parsed[1], 2500)
  end if
  client = state.client
  if client is void or client.transport != "loop" then client = createSocket() end if
  server = state.server
  if server is void or server.transport != "loop" then server = createSocket() end if
  client.messages = []
  client.messageTypes = []
  client.canSend = true
  client.disconnected = false
  client.address = "localhost"
  server.messages = []
  server.messageTypes = []
  server.canSend = true
  server.disconnected = false
  server.address = "LOCAL"
  client.peer = server
  server.peer = client
  state.client = client
  state.server = server
  state.pending = server
  return client
end function

// Establish remote using the active network transport.
function connectRemote(state, address, port, timeoutMilliseconds)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if not state.lanEnabled then return error(3436, "Datagram networking disabled by -nolan") end if
  compactRemoteSockets(state)
  socketResult = try(udp.open(0))
  if socketResult is error then return socketResult end if
  udpSocket = socketResult
  request = control.requestConnect()
  if timeoutMilliseconds < 1 then timeoutMilliseconds = 1 end if
  requestedAddress = normalizeAddress(address)
  if not isNumericAddress(requestedAddress) then
    resolved = try(udp.resolveName(requestedAddress))
    if resolved is error then udp.close(udpSocket); return resolved end if
    requestedAddress = resolved
  end if
  repetition = 0
  while repetition < 3
    sent = try(udp.send(udpSocket, requestedAddress, port, request))
    if sent is error then udp.close(udpSocket); return sent end if
    attemptStarted = win.ticks()
    while win.ticks() - attemptStarted < timeoutMilliseconds
      incoming = try(udp.receive(udpSocket, 2048))
      if incoming is error then udp.close(udpSocket); return incoming end if
      if incoming is not void and incoming[2] == port and incoming[1] == requestedAddress then
        parsed = try(control.parse(incoming[0]))
        if parsed is not error then
          if parsed[0] == control.CCREP_ACCEPT then
            remotePort = parsed[1][0]
            if remotePort < 1 or remotePort > 65535 then udp.close(udpSocket); return error(3431, "server returned invalid UDP port") end if
            remote = createRemoteSocket(udpSocket, incoming[1], remotePort)
            state.client = remote
            state.remoteSockets = state.remoteSockets + [remote]
            return remote
          else if parsed[0] == control.CCREP_REJECT then
            udp.close(udpSocket)
            return error(3432, parsed[1][0])
          end if
        end if
      end if
      if incoming is void then win.sleep(1) end if
    end while
    repetition = repetition + 1
  end while
  udp.close(udpSocket)
  return error(3433, "UDP connect timed out")
end function

// External original-binary interoperability needs a persistent control
// socket.  Reusing the same source endpoint and resending inside Quake's
// two-second duplicate window lets the original server repeat CCREP_ACCEPT
// instead of treating each short-lived process as a crashed client.
function connectRemotePersistent(state, address, port, timeoutMilliseconds, resendMilliseconds)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if not state.lanEnabled then return error(3436, "Datagram networking disabled by -nolan") end if
  compactRemoteSockets(state)
  socketResult = try(udp.open(0))
  if socketResult is error then return socketResult end if
  udpSocket = socketResult
  request = control.requestConnect()
  if timeoutMilliseconds < 1 then timeoutMilliseconds = 1 end if
  if resendMilliseconds < 1 then resendMilliseconds = 1 end if
  requestedAddress = normalizeAddress(address)
  if not isNumericAddress(requestedAddress) then
    resolved = try(udp.resolveName(requestedAddress))
    if resolved is error then udp.close(udpSocket); return resolved end if
    requestedAddress = resolved
  end if

  started = win.ticks()
  lastSend = started - resendMilliseconds
  sends = 0
  receives = 0
  ignored = 0
  print "MiniQuake Protocol-3 persistent connect"
  print "  local=" + udpSocket.bindAddress + ":" + udpSocket.port + " target=" + requestedAddress + ":" + port
  print "  request=" + hex(request) + " timeout_ms=" + timeoutMilliseconds + " resend_ms=" + resendMilliseconds

  while win.ticks() - started < timeoutMilliseconds
    now = win.ticks()
    if sends == 0 or now - lastSend >= resendMilliseconds then
      sent = try(udp.send(udpSocket, requestedAddress, port, request))
      if sent is error then udp.close(udpSocket); return sent end if
      if sent != len(request) then
        udp.close(udpSocket)
        return error(3437, "UDP control request was partially sent: " + sent + "/" + len(request))
      end if
      sends = sends + 1
      lastSend = now
    end if

    incoming = try(udp.receive(udpSocket, 2048))
    if incoming is error then udp.close(udpSocket); return incoming end if
    if incoming is void then
      win.sleep(1)
    else
      receives = receives + 1
      if incoming[2] == port and incoming[1] == requestedAddress then
        parsed = try(control.parse(incoming[0]))
        if parsed is error then
          ignored = ignored + 1
          print "  ignored=parse_error from=" + incoming[1] + ":" + incoming[2] + " bytes=" + len(incoming[0]) + " wire=" + hex(incoming[0])
        else if parsed[0] == control.CCREP_ACCEPT then
          remotePort = parsed[1][0]
          if remotePort < 1 or remotePort > 65535 then udp.close(udpSocket); return error(3431, "server returned invalid UDP port") end if
          remote = createRemoteSocket(udpSocket, incoming[1], remotePort)
          state.client = remote
          state.remoteSockets = state.remoteSockets + [remote]
          print "  accepted=true control_port=" + port + " game_port=" + remotePort + " sends=" + sends + " receives=" + receives
          return remote
        else if parsed[0] == control.CCREP_REJECT then
          udp.close(udpSocket)
          return error(3432, parsed[1][0])
        else
          ignored = ignored + 1
          print "  ignored=command_" + parsed[0] + " from=" + incoming[1] + ":" + incoming[2] + " wire=" + hex(incoming[0])
        end if
      else
        ignored = ignored + 1
        print "  ignored=endpoint from=" + incoming[1] + ":" + incoming[2] + " bytes=" + len(incoming[0])
      end if
    end if
  end while

  localPort = udpSocket.port
  udp.close(udpSocket)
  return error(3433, "UDP persistent connect timed out: local_port=" + localPort + " target=" + requestedAddress + ":" + port + " sends=" + sends + " receives=" + receives + " ignored=" + ignored)
end function

// Provide listen behavior for the active subsystem.
function listen(state, port)
  if not state.lanEnabled then return error(3436, "Datagram networking disabled by -nolan") end if
  if state.listener is not void then return state.listener end if
  opened = udp.open(port)
  if opened is error then return opened end if
  state.listener = opened
  return opened
end function

// Finalize state for stop listening.
function stopListening(state)
  if state.listener is void then return false end if
  udp.close(state.listener)
  state.listener = void
  if state.pendingRemote is not void then close(state.pendingRemote); state.pendingRemote = void end if
  return true
end function

// Update subsystem configuration for configure server.
function configureServer(state, hostName, mapName, currentPlayers, maxPlayers)
  state.hostName = hostName
  state.mapName = mapName
  state.currentPlayers = currentPlayers
  state.maxPlayers = maxPlayers
  return true
end function

// Update subsystem configuration for configure query data.
function configureQueryData(state, players, rules)
  state.playerInfo = players
  state.serverRules = rules
  return true
end function

// Apply the Quake-compatible host name exists behavior.
function hostNameExists(hosts, name)
  wanted = bio.lower(name)
  for each cached in hosts
    if bio.lower(cached[1]) == wanted then return true end if
  end for
  return false
end function

// Return unique host name derived from the active module state.
function uniqueHostName(hosts, requested)
  candidate = shortText(requested, 15)
  if candidate == "" then candidate = "UNNAMED" end if
  while hostNameExists(hosts, candidate)
    data = bytes(candidate)
    last = len(data) - 1
    if len(data) < 15 and data[last] > 56 then
      expanded = bytes(len(data) + 1)
      bio.copyInto(expanded, 0, data, 0, len(data))
      expanded[len(data)] = 48
      data = expanded
    else
      data[last] = (data[last] + 1) & 255
    end if
    candidate = decode(data)
  end while
  return candidate
end function

// Provide discovered address behavior for the active subsystem.
function discoveredAddress(fields, receivedAddress, receivedPort)
  parsed = try(parseAddress(fields[0], receivedPort))
  if parsed is error then return receivedAddress + ":" + receivedPort end if
  if parsed[0] == "0.0.0.0" then return receivedAddress + ":" + parsed[1] end if
  return parsed[0] + ":" + parsed[1]
end function

// Provide search hosts behavior for the active subsystem.
function searchHosts(port, timeoutMilliseconds)
  opened = udp.open(0)
  if opened is error then return opened end if
  searchSocket = opened
  hosts = try(_Datagram_SearchForHosts(searchSocket, [], port, timeoutMilliseconds, true))
  udp.close(searchSocket)
  return hosts
end function

// Provide datagram search for hosts behavior for the active subsystem.
function _Datagram_SearchForHosts(searchSocket, hosts, port, timeoutMilliseconds, xmit)
  // Differential/source-surface callers may exercise the no-landriver path
  // with no control socket, matching Datagram_SearchForHosts' skipped driver.
  if searchSocket is void then return hosts end if
  if xmit then
    sent = try(udp.broadcast(searchSocket, port, control.requestServerInfo()))
    if sent is error then return sent end if
  end if
  if timeoutMilliseconds < 0 then timeoutMilliseconds = 0 end if
  elapsed = 0
  result = hosts
  // The original control socket is non-blocking and is polled once even when
  // the caller supplies no wait horizon. This lets NET_Poll drain replies over
  // several frames without turning one menu frame into a 100-ms busy wait.
  firstPoll = true
  while (firstPoll or elapsed < timeoutMilliseconds) and len(result) < HOST_CACHE_SIZE
    firstPoll = false
    received = try(udp.receive(searchSocket, 2048))
    if received is error then return received end if
    if received is void then
      if timeoutMilliseconds == 0 then break end if
      win.sleep(1)
    else
      // _Datagram_SearchForHosts ignores replies whose IPv4 address matches
      // its own control socket, even when the source port differs.
      if received[1] == udp.localAddress() then elapsed = elapsed + 1; continue end if
      parsed = try(control.parse(received[0]))
      if parsed is not error and parsed[0] == control.CCREP_SERVER_INFO then
        address = discoveredAddress(parsed[1], received[1], received[2])
        duplicate = false
        for each cached in result
          if cached[0] == address then duplicate = true; break end if
        end for
        if not duplicate then
          name = parsed[1][1]
          if parsed[1][5] != control.NET_PROTOCOL_VERSION then name = "*" + shortText(name, 14) end if
          name = uniqueHostName(result, name)
          result = result + [[address, name, shortText(parsed[1][2], 15), parsed[1][3], parsed[1][4], parsed[1][5]]]
        end if
      end if
    end if
    elapsed = elapsed + 1
  end while
  return result
end function

// Mirror Quake's Datagram_SearchForHosts routine and its observable state changes.
function Datagram_SearchForHosts(state, xmit, port, timeoutMilliseconds)
  global datagramSearchSocket
  if not state.lanEnabled then return error(3436, "Datagram networking disabled by -nolan") end if
  if datagramSearchSocket is void or not datagramSearchSocket.open then
    opened = udp.open(0)
    if opened is error then return opened end if
    datagramSearchSocket = opened
  end if
  result = try(_Datagram_SearchForHosts(datagramSearchSocket, state.hostCache, port, timeoutMilliseconds, xmit))
  if result is error then return result end if
  state.hostCache = result
  return result
end function

// Finish a multi-frame server search and release its persistent control socket.
function Datagram_EndHostSearch()
  global datagramSearchSocket
  if datagramSearchSocket is void then return false end if
  udp.close(datagramSearchSocket)
  datagramSearchSocket = void
  return true
end function

// Report whether LAN discovery currently owns its non-blocking control socket.
function Datagram_HostSearchActive()
  return datagramSearchSocket is not void and datagramSearchSocket.open
end function

// Provide listener address behavior for the active subsystem.
function listenerAddress(address, port)
  return address + ":" + port
end function

// Provide public listener address behavior for the active subsystem.
function publicListenerAddress(state)
  address = state.listener.bindAddress
  if address == "" or address == "0.0.0.0" or address == "127.0.0.1" then address = udp.localAddress() end if
  return address + ":" + state.listener.port
end function

// Return next server rule for the active module state.
function nextServerRule(rules, previous)
  start = 0
  if previous != "" then
    found = -1
    index = 0
    while index < len(rules)
      if rules[index][0] == previous then found = index; break end if
      index = index + 1
    end while
    // net_dgrm.c silently ignores a rule query whose previous cvar does not
    // exist. Use an error value as an internal no-reply sentinel so the
    // listener can distinguish it from the normal end-of-list marker.
    if found < 0 then return error(3437, "unknown previous server rule") end if
    start = found + 1
  end if
  // After the final server cvar, Quake replies with CCREP_RULE_INFO and no
  // strings. Represent that command-only reply as an empty name/value pair.
  if start >= len(rules) then return ["", ""] end if
  return rules[start]
end function

// Provide matching remote behavior for the active subsystem.
function matchingRemote(state, address)
  for each socket in state.remoteSockets
    if not socket.disconnected and socket.transport == "udp" and socket.address == address then return socket end if
  end for
  return void
end function

// Provide connection request action behavior for the active subsystem.
function connectionRequestAction(existing, port, now)
  if existing is void then return "new" end if
  if existing.port == port and now - existing.connectTime < 2.0 then return "duplicate" end if
  return "replace"
end function

// Advance listener by one processing step.
function pumpListener(state)
  if state.listener is void then return 0 end if
  compactRemoteSockets(state)
  processed = 0
  iterations = 0
  while iterations < 64
    received = try(udp.receive(state.listener, 2048))
    if received is error then return received end if
    if received is void then break end if
    parsed = try(control.parse(received[0]))
    if parsed is not error then
      if parsed[0] == control.CCREQ_SERVER_INFO and control.validServerInfoRequest(parsed) then
        response = control.replyServerInfo(
          publicListenerAddress(state),
          state.hostName,
          state.mapName,
          state.currentPlayers,
          state.maxPlayers,
        )
        udp.send(state.listener, received[1], received[2], response)
        processed = processed + 1
      else if parsed[0] == control.CCREQ_PLAYER_INFO then
        playerNumber = parsed[1][0]
        if playerNumber >= 0 and playerNumber < len(state.playerInfo) then
          player = state.playerInfo[playerNumber]
          response = control.replyPlayerInfo(
            playerNumber,
            player[0],
            player[1],
            player[2],
            player[3],
            player[4],
          )
          udp.send(state.listener, received[1], received[2], response)
          processed = processed + 1
        end if
      else if parsed[0] == control.CCREQ_RULE_INFO then
        rule = try(nextServerRule(state.serverRules, parsed[1][0]))
        // An unknown previous cvar gets no reply. A valid end-of-list result
        // is ["", ""] and emits the command-only enumeration terminator.
        if rule is not error then
          response = control.replyRuleInfo(rule[0], rule[1])
          udp.send(state.listener, received[1], received[2], response)
          processed = processed + 1
        end if
      else if parsed[0] == control.CCREQ_CONNECT then
        if parsed[1][0] != control.GAME_NAME then
          // net_dgrm.c silently ignores requests for another game.
          processed = processed
        else if not control.validConnectRequest(parsed) then
          udp.send(state.listener, received[1], received[2], control.replyReject("Incompatible version.\n"))
        else if addressIsBanned(state, received[1]) then
          udp.send(state.listener, received[1], received[2], control.replyReject("You have been banned.\n"))
        else
          existing = matchingRemote(state, received[1])
          now = win.ticks() / 1000.0
          action = connectionRequestAction(existing, received[2], now)
          if action == "duplicate" then
            udp.send(state.listener, received[1], received[2], control.replyAccept(existing.udp.port))
            processed = processed + 1
            return processed
          else if action == "replace" then
            // net_dgrm.c closes a crashed connection and deliberately sends
            // no reply; the requester's retry is accepted after the server
            // frame has dropped the old client.
            close(existing)
            return processed
          else
            if state.currentPlayers >= state.maxPlayers then
              udp.send(state.listener, received[1], received[2], control.replyReject("Server is full.\n"))
            else
              connectionSocket = udp.open(0)
              if connectionSocket is not error then
                state.pendingRemote = createRemoteSocket(connectionSocket, received[1], received[2])
                state.remoteSockets = state.remoteSockets + [state.pendingRemote]
                udp.send(state.listener, received[1], received[2], control.replyAccept(connectionSocket.port))
                processed = processed + 1
                return processed
              end if
            end if
          end if
        end if
      end if
    end if
    iterations = iterations + 1
  end while
  return processed
end function

// Validate new connections and report any incompatibility.
function checkNewConnections(state)
  return Datagram_CheckNewConnections(state)
end function

// Provide array tail behavior for the active subsystem.
function arrayTail(values)
  result = []
  i = 1
  while i < len(values)
    result = result + [values[i]]
    i = i + 1
  end while
  return result
end function

// Provide int align behavior for the active subsystem.
function inline IntAlign(value)
  return (value + 3) & ~3
end function

// Return loop queued bytes derived from the active module state.
function loopQueuedBytes(socket)
  total = 0
  for each payload in socket.messages
    total = total + IntAlign(len(payload) + 4)
  end for
  return total
end function

// Send message through the active connection.
function sendMessage(socket, buffer)
  global messagesSent
  if socket is void or socket.disconnected then return -1 end if
  if socket.transport == "udp" then
    pumpRemote(socket)
    if not socket.channel.canSend then return 0 end if
    packet = datagram.Datagram_SendMessage(socket.channel, slice(buffer.data, 0, buffer.curSize), win.ticks() / 1000.0)
    if packet is error then return -1 end if
    sent = udp.send(socket.udp, socket.address, socket.port, packet)
    socket.canSend = socket.channel.canSend
    if sent is error then return -1 end if
    socket.lastSendTime = win.ticks() / 1000.0
    messagesSent = messagesSent + 1
    return 1
  end if
  if socket.peer is void then return -1 end if
  payload = slice(buffer.data, 0, buffer.curSize)
  if loopQueuedBytes(socket.peer) + len(payload) + 4 > LOOP_MAX_MESSAGE then return error(3437, "Loop_SendMessage: overflow") end if
  socket.peer.messages = socket.peer.messages + [payload]
  socket.peer.messageTypes = socket.peer.messageTypes + [1]
  socket.canSend = false
  socket.lastSendTime = win.ticks() / 1000.0
  return 1
end function

// Send unreliable message through the active connection.
function sendUnreliableMessage(socket, buffer)
  global unreliableMessagesSent
  if socket is void or socket.disconnected then return -1 end if
  if socket.transport == "udp" then
    payload = slice(buffer.data, 0, buffer.curSize)
    if len(payload) > datagram.MAX_DATAGRAM then return -1 end if
    packet = datagram.Datagram_SendUnreliableMessage(socket.channel, payload)
    sent = udp.send(socket.udp, socket.address, socket.port, packet)
    if sent is error then return -1 end if
    socket.lastSendTime = win.ticks() / 1000.0
    unreliableMessagesSent = unreliableMessagesSent + 1
    return 1
  end if
  if socket.peer is void then return -1 end if
  payload = slice(buffer.data, 0, buffer.curSize)
  // net_loop.c tests byte+short overhead here (three bytes), although the
  // stored record is subsequently padded to a four-byte boundary.
  if loopQueuedBytes(socket.peer) + len(payload) + 3 > LOOP_MAX_MESSAGE then return 0 end if
  socket.peer.messages = socket.peer.messages + [payload]
  socket.peer.messageTypes = socket.peer.messageTypes + [2]
  socket.lastSendTime = win.ticks() / 1000.0
  return 1
end function

// Advance remote by one processing step.
function pumpRemote(socket)
  if socket is void or socket.disconnected or socket.transport != "udp" then return 0 end if
  now = win.ticks() / 1000.0
  resend = datagram.pollRetransmit(socket.channel, now)
  if resend is bytes then udp.send(socket.udp, socket.address, socket.port, resend) end if
  processed = 0
  iterations = 0
  while iterations < 128
    incoming = try(udp.receive(socket.udp, 2048))
    if incoming is error then return incoming end if
    if incoming is void then break end if
    if incoming[1] == socket.address and incoming[2] == socket.port then
      result = try(datagram.Datagram_GetMessage(socket.channel, incoming[0], now))
      if result is error then return result end if
      if result[2] is bytes then udp.send(socket.udp, socket.address, socket.port, result[2]) end if
      // result[3] is reserved for an immediate response such as the optional
      // NAK extension.  Normal ACK progression is flushed once after the read
      // loop, exactly like Datagram_GetMessage in net_dgrm.c.
      if result[3] is bytes then udp.send(socket.udp, socket.address, socket.port, result[3]) end if
      if result[0] > 0 then
        socket.messages = socket.messages + [result[1]]
        socket.messageTypes = socket.messageTypes + [result[0]]
        processed = processed + 1
        socket.lastReceiveTime = now
      end if
    end if
    iterations = iterations + 1
  end while
  pending = datagram.Datagram_FlushSendNext(socket.channel, now)
  if pending is bytes then
    sent = udp.send(socket.udp, socket.address, socket.port, pending)
    if sent is error then return sent end if
    socket.lastSendTime = now
  end if
  socket.canSend = socket.channel.canSend
  return processed
end function

// Return message.
function getMessage(socket, destination)
  global messagesReceived, unreliableMessagesReceived
  if socket is void or socket.disconnected then return -1 end if
  if socket.transport == "udp" then
    pumped = pumpRemote(socket)
    if pumped is error then return -1 end if
  end if
  if len(socket.messages) == 0 then return 0 end if
  payload = socket.messages[0]
  messageType = socket.messageTypes[0]
  socket.messages = arrayTail(socket.messages)
  socket.messageTypes = arrayTail(socket.messageTypes)
  sz.clear(destination)
  sz.write(destination, payload, 0, len(payload))
  if messageType == 1 and socket.transport == "loop" and socket.peer is not void then socket.peer.canSend = true end if
  if socket.transport == "udp" or socket.transport == "test-datagram" then
    if messageType == 1 then messagesReceived = messagesReceived + 1 else if messageType == 2 then unreliableMessagesReceived = unreliableMessagesReceived + 1 end if
  end if
  return messageType
end function

// Report whether can send message.
function canSendMessage(socket)
  if socket is void or socket.disconnected then return false end if
  if socket.transport == "udp" then
    pumped = pumpRemote(socket)
    if pumped is error then return false end if
    return socket.channel.canSend
  end if
  return socket.canSend
end function

// Provide timed out behavior for the active subsystem.
function timedOut(socket, timeoutSeconds)
  if socket is void or socket.disconnected then return false end if
  if socket.transport != "udp" and socket.transport != "test-datagram" then return false end if
  if timeoutSeconds <= 0.0 then return false end if
  return win.ticks() / 1000.0 - socket.lastReceiveTime > timeoutSeconds
end function

// Release state for close.
function close(socket)
  if socket is void then return end if
  socket.disconnected = true
  if socket.transport == "udp" then
    if socket.udp is not void then udp.close(socket.udp); socket.udp = void end if
    return
  end if
  if socket.peer is not void then socket.peer.peer = void end if
  socket.peer = void
end function

// Mirror Quake's Datagram_Init routine and its observable state changes.
function Datagram_Init(state, noLan)
  global messagesSent, messagesReceived, unreliableMessagesSent, unreliableMessagesReceived
  datagram.resetStats()
  messagesSent = 0
  messagesReceived = 0
  unreliableMessagesSent = 0
  unreliableMessagesReceived = 0
  state.lanEnabled = not noLan
  if noLan then return -1 end if
  return 0
end function

// Mirror Quake's Datagram_Shutdown routine and its observable state changes.
function Datagram_Shutdown(state)
  Datagram_EndHostSearch()
  if state.listener is not void then stopListening(state) end if
  for each socket in state.remoteSockets
    if not socket.disconnected then close(socket) end if
  end for
  state.remoteSockets = []
  state.hostCache = []
  return true
end function

// Mirror Quake's Datagram_Close routine and its observable state changes.
function Datagram_Close(socket)
  close(socket)
  return true
end function

// Mirror Quake's Datagram_Listen routine and its observable state changes.
function Datagram_Listen(state, enabled, port)
  if enabled then return listen(state, port) end if
  stopListening(state)
  return void
end function

// Provide datagram check new connections behavior for the active subsystem.
function _Datagram_CheckNewConnections(state)
  socket = state.pendingRemote
  state.pendingRemote = void
  if socket is not void then return socket end if
  pumped = pumpListener(state)
  if pumped is error then return pumped end if
  socket = state.pendingRemote
  state.pendingRemote = void
  return socket
end function

// Mirror Quake's Datagram_CheckNewConnections routine and its observable state changes.
function Datagram_CheckNewConnections(state)
  socket = state.pending
  state.pending = void
  if socket is not void then
    socket.messages = []
    socket.messageTypes = []
    socket.canSend = true
    if socket.peer is not void then
      socket.peer.messages = []
      socket.peer.messageTypes = []
      socket.peer.canSend = true
    end if
    return socket
  end if
  return _Datagram_CheckNewConnections(state)
end function

// Provide resolve datagram target behavior for the active subsystem.
function resolveDatagramTarget(state, host, defaultPort)
  target = host
  wanted = bio.lower(host)
  for each cached in state.hostCache
    if bio.lower(cached[1]) == wanted then target = cached[0]; break end if
  end for
  return parseAddress(target, defaultPort)
end function

// Provide datagram connect port behavior for the active subsystem.
function _Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)
  parsed = resolveDatagramTarget(state, host, defaultPort)
  if parsed is error then return parsed end if
  return connectRemote(state, parsed[0], parsed[1], timeoutMilliseconds)
end function

// Mirror Quake's Datagram_ConnectPort routine and its observable state changes.
function Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)
  return _Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)
end function

// Mirror Quake's Datagram_ConnectPersistent routine and its observable state changes.
function Datagram_ConnectPersistent(state, host, timeoutMilliseconds, resendMilliseconds, defaultPort)
  parsed = resolveDatagramTarget(state, host, defaultPort)
  if parsed is error then return parsed end if
  return connectRemotePersistent(state, parsed[0], parsed[1], timeoutMilliseconds, resendMilliseconds)
end function

// Compatibility wrapper for callers that intentionally use the historical
// default port.  Public NET_Connect passes the active net_hostport instead.
function _Datagram_Connect(state, host, timeoutMilliseconds)
  return _Datagram_ConnectPort(state, host, timeoutMilliseconds, 26000)
end function

// Mirror Quake's Datagram_Connect routine and its observable state changes.
function Datagram_Connect(state, host, timeoutMilliseconds)
  return Datagram_ConnectPort(state, host, timeoutMilliseconds, 26000)
end function

// Verify poll against the expected Quake behavior.
function Test_Poll(socket, expectedAddress, expectedPort, timeoutMilliseconds)
  results = []
  elapsed = 0
  while elapsed < timeoutMilliseconds
    incoming = try(udp.receive(socket, 2048))
    if incoming is error then return incoming end if
    if incoming is void then
      win.sleep(1)
    else if incoming[2] == expectedPort and (not isNumericAddress(expectedAddress) or incoming[1] == expectedAddress) then
      parsed = try(control.parse(incoming[0]))
      if parsed is not error and parsed[0] == control.CCREP_PLAYER_INFO then results = results + [parsed[1]] end if
    end if
    elapsed = elapsed + 1
  end while
  return results
end function

// Verify f against the expected Quake behavior.
function Test_f(host, maximumPlayers, timeoutMilliseconds)
  parsedAddress = parseAddress(host, 26000)
  if parsedAddress is error then return parsedAddress end if
  socket = udp.open(0)
  if socket is error then return socket end if
  index = 0
  while index < maximumPlayers
    sent = try(udp.send(socket, parsedAddress[0], parsedAddress[1], control.requestPlayerInfo(index)))
    if sent is error then udp.close(socket); return sent end if
    index = index + 1
  end while
  results = try(Test_Poll(socket, parsedAddress[0], parsedAddress[1], timeoutMilliseconds))
  udp.close(socket)
  return results
end function

// Mirror Quake's Test2_Poll routine and its observable state changes.
function Test2_Poll(socket, expectedAddress, expectedPort, timeoutMilliseconds)
  elapsed = 0
  while elapsed < timeoutMilliseconds
    incoming = try(udp.receive(socket, 2048))
    if incoming is error then return incoming end if
    if incoming is not void and incoming[2] == expectedPort and (not isNumericAddress(expectedAddress) or incoming[1] == expectedAddress) then
      parsed = try(control.parse(incoming[0]))
      if parsed is not error and parsed[0] == control.CCREP_RULE_INFO then return parsed[1] end if
    end if
    if incoming is void then win.sleep(1) end if
    elapsed = elapsed + 1
  end while
  return error(3434, "rule query timed out")
end function

// Mirror Quake's Test2_f routine and its observable state changes.
function Test2_f(host, timeoutMilliseconds)
  parsedAddress = parseAddress(host, 26000)
  if parsedAddress is error then return parsedAddress end if
  socket = udp.open(0)
  if socket is error then return socket end if
  results = []
  previous = ""
  requests = 0
  while requests < 1024
    sent = try(udp.send(socket, parsedAddress[0], parsedAddress[1], control.requestRuleInfo(previous)))
    if sent is error then udp.close(socket); return sent end if
    reply = try(Test2_Poll(socket, parsedAddress[0], parsedAddress[1], timeoutMilliseconds))
    if reply is error then udp.close(socket); return reply end if
    if reply[0] == "" then udp.close(socket); return results end if
    results = results + [reply]
    previous = reply[0]
    requests = requests + 1
  end while
  udp.close(socket)
  return error(3435, "rule query exceeded 1024 entries")
end function

// --------------------------------------------------------------------------
// net_loop.c / net_loop.h compatibility surface

function Loop_Init(dedicated)
  if dedicated then return -1 end if
  return 0
end function

// Mirror Quake's Loop_Shutdown routine and its observable state changes.
function Loop_Shutdown()
  return true
end function

// Mirror Quake's Loop_Listen routine and its observable state changes.
function Loop_Listen(state)
  // The loop driver is always available in a non-dedicated process.
  return state
end function

// Mirror Quake's Loop_SearchForHosts routine and its observable state changes.
function Loop_SearchForHosts(state, serverActive, driverLevel)
  if not serverActive then return state.hostCache end if
  displayName = state.hostName
  if displayName == "UNNAMED" then displayName = "local" end if
  state.hostCache = [[
    "local",
    displayName,
    state.mapName,
    state.currentPlayers,
    state.maxPlayers,
    control.NET_PROTOCOL_VERSION,
    driverLevel,
  ]]
  return state.hostCache
end function

// Mirror Quake's Loop_Connect routine and its observable state changes.
function Loop_Connect(state, host)
  // The original driver recognizes exactly "local"; "localhost" is a
  // MiniQuake NET_Connect convenience handled before this public entry point.
  if host != "local" then return void end if
  return connect(state, host)
end function

// Mirror Quake's Loop_CheckNewConnections routine and its observable state changes.
function Loop_CheckNewConnections(state)
  socket = state.pending
  state.pending = void
  if socket is void then return void end if
  socket.messages = []
  socket.messageTypes = []
  socket.canSend = true
  if socket.peer is not void then
    socket.peer.messages = []
    socket.peer.messageTypes = []
    socket.peer.canSend = true
  end if
  return socket
end function

// Mirror Quake's Loop_GetMessage routine and its observable state changes.
function Loop_GetMessage(socket, destination)
  return getMessage(socket, destination)
end function

// Mirror Quake's Loop_SendMessage routine and its observable state changes.
function Loop_SendMessage(socket, data)
  return sendMessage(socket, data)
end function

// Mirror Quake's Loop_SendUnreliableMessage routine and its observable state changes.
function Loop_SendUnreliableMessage(socket, data)
  return sendUnreliableMessage(socket, data)
end function

// Mirror Quake's Loop_CanSendMessage routine and its observable state changes.
function Loop_CanSendMessage(socket)
  return canSendMessage(socket)
end function

// Mirror Quake's Loop_CanSendUnreliableMessage routine and its observable state changes.
function Loop_CanSendUnreliableMessage(socket)
  return true
end function

// Mirror Quake's Loop_Close routine and its observable state changes.
function Loop_Close(socket)
  close(socket)
  return true
end function
