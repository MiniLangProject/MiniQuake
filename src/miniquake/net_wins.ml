/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.net_wins.
*/
package miniquake.net_wins

// WinQuake/net_wins.c pendant.  Address parsing, byte order, landriver state
// and original return conventions live here; net_udp/native expose only the
// non-blocking Winsock primitives.

import miniquake.types as t
import miniquake.net_udp as udp
import miniquake.platform.win32 as win
import miniquake.common as common

/// Defines the af inet value used by `miniquake.net_wins`.
const AF_INET = 2
/// Defines the maxhostnamelen value used by `miniquake.net_wins`.
const MAXHOSTNAMELEN = 256
/// Defines the net namelen value used by `miniquake.net_wins`.
const NET_NAMELEN = 64

/// Tracks the module-level net acceptsocket state owned by `miniquake.net_wins`.
net_acceptsocket = void
/// Tracks the module-level net controlsocket state owned by `miniquake.net_wins`.
net_controlsocket = void
/// Tracks the module-level net broadcastsocket state owned by `miniquake.net_wins`.
net_broadcastsocket = void
/// Tracks the module-level broadcastaddr state owned by `miniquake.net_wins`.
broadcastaddr = t.WinSockAddress(AF_INET, 0xffffffff, 0)
/// Tracks the module-level my addr state owned by `miniquake.net_wins`.
myAddr = 0
/// Tracks the module-level my tcpip address state owned by `miniquake.net_wins`.
my_tcpip_address = "INADDR_ANY"
/// Tracks the module-level configured hostname state owned by `miniquake.net_wins`.
configuredHostname = "UNNAMED"
/// Tracks the module-level winsock lib initialized state owned by `miniquake.net_wins`.
winsock_lib_initialized = false
/// Tracks the module-level winsock initialized state owned by `miniquake.net_wins`.
winsock_initialized = 0
/// Tracks the module-level tcpip available state owned by `miniquake.net_wins`.
tcpipAvailable = false
/// Tracks the module-level net hostport state owned by `miniquake.net_wins`.
net_hostport = 26000
/// Tracks the module-level blocktime state owned by `miniquake.net_wins`.
blocktime = 0.0
/// Tracks the module-level last error state owned by `miniquake.net_wins`.
lastError = 0

// Mirror Quake's WINS_ResetState routine and its observable state changes.
function WINS_ResetState()
  global net_acceptsocket, net_controlsocket, net_broadcastsocket, broadcastaddr
  global myAddr, my_tcpip_address, configuredHostname, winsock_lib_initialized
  global winsock_initialized, tcpipAvailable, net_hostport, blocktime, lastError
  net_acceptsocket = void
  net_controlsocket = void
  net_broadcastsocket = void
  broadcastaddr = t.WinSockAddress(AF_INET, 0xffffffff, 0)
  myAddr = 0
  my_tcpip_address = "INADDR_ANY"
  configuredHostname = "UNNAMED"
  winsock_lib_initialized = false
  winsock_initialized = 0
  tcpipAvailable = false
  net_hostport = 26000
  blocktime = 0.0
  lastError = 0
  udp.configureBindAddress("0.0.0.0")
  return true
end function

/// Mirror Quake's WINS_SetLocalAddress routine and its observable state changes.
/// @param addressText The address text input consumed by `WINS_SetLocalAddress`.
function WINS_SetLocalAddress(addressText)
  global myAddr, my_tcpip_address
  numeric = parseIpv4(addressText)
  if numeric is void then return error(3453, "invalid local IPv4 address " + addressText) end if
  myAddr = htonl(numeric)
  my_tcpip_address = addressText
  return my_tcpip_address
end function

/// Mirror Quake's WINS_SetBlockTime routine and its observable state changes.
/// @param value Value consumed by `WINS_SetBlockTime`.
function WINS_SetBlockTime(value)
  global blocktime
  blocktime = value
  return blocktime
end function

// Mirror Quake's WINS_StateSnapshot routine and its observable state changes.
function WINS_StateSnapshot()
  return [
    winsock_lib_initialized,
    winsock_initialized,
    tcpipAvailable,
    net_acceptsocket,
    net_controlsocket,
    net_broadcastsocket,
    my_tcpip_address,
    configuredHostname,
  ]
end function

/// Mirror Quake's WINS_SetAcceptSocket routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_SetAcceptSocket`.
function WINS_SetAcceptSocket(socketValue)
  global net_acceptsocket
  net_acceptsocket = socketValue
  return net_acceptsocket
end function

/// Mirror Quake's WINS_SetBroadcastSocket routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_SetBroadcastSocket`.
function WINS_SetBroadcastSocket(socketValue)
  global net_broadcastsocket
  net_broadcastsocket = socketValue
  return net_broadcastsocket
end function

/// Implements the `htons` operation for `miniquake.net_wins` (htons).
/// @param value Value consumed by `htons`.
function htons(value)
  number = value & 0xffff
  return ((number & 255) << 8) | ((number >> 8) & 255)
end function

/// Implements the `ntohs` operation for `miniquake.net_wins` (ntohs).
/// @param value Value consumed by `ntohs`.
function ntohs(value)
  return htons(value)
end function

/// Implements the `htonl` operation for `miniquake.net_wins` (htonl).
/// @param value Value consumed by `htonl`.
function htonl(value)
  return ((value & 255) << 24) |
    ((value & 0xff00) << 8) |
    ((value >> 8) & 0xff00) |
    ((value >> 24) & 255)
end function

/// Implements the `ntohl` operation for `miniquake.net_wins` (ntohl).
/// @param value Value consumed by `ntohl`.
function ntohl(value)
  return htonl(value)
end function

/// Implements the `shortText` operation for `miniquake.net_wins` (short text).
/// @param text Text to parse or process.
/// @param maximum Largest accepted value.
function shortText(text, maximum)
  data = bytes(text)
  if len(data) <= maximum then return text end if
  return decode(slice(data, 0, maximum))
end function

/// Convert text into its canonical representation.
/// @param text Text to parse or process.
/// @param separator The separator input consumed by `splitText`.
function splitText(text, separator)
  source = bytes(text)
  values = []
  start = 0
  index = 0
  while index <= len(source)
    if index == len(source) or source[index] == separator then
      values = values + [decode(slice(source, start, index - start))]
      start = index + 1
    end if
    index = index + 1
  end while
  return values
end function

/// Read and validate decimal.
/// @param text Text to parse or process.
/// @param maximumDigits The maximum digits input consumed by `parseDecimal`.
/// @param maximumValue The maximum value input consumed by `parseDecimal`.
function parseDecimal(text, maximumDigits, maximumValue)
  source = bytes(text)
  if len(source) == 0 or len(source) > maximumDigits then return void end if
  value = 0
  for each character in source
    if character < 48 or character > 57 then return void end if
    value = value * 10 + character - 48
  end for
  if value > maximumValue then return void end if
  return value
end function

/// Read and validate ipv4.
/// @param text Text to parse or process.
function parseIpv4(text)
  parts = splitText(text, 46)
  if len(parts) != 4 then return void end if
  values = []
  for each part in parts
    value = parseDecimal(part, 3, 255)
    if value is void then return void end if
    values = values + [value]
  end for
  return ((values[0] & 255) << 24) | ((values[1] & 255) << 16) | ((values[2] & 255) << 8) | (values[3] & 255)
end function

/// Implements the `ipv4Text` operation for `miniquake.net_wins` (ipv4 text).
/// @param hostOrderAddress The host order address input consumed by `ipv4Text`.
function ipv4Text(hostOrderAddress)
  return ((hostOrderAddress >> 24) & 255) + "." +
    ((hostOrderAddress >> 16) & 255) + "." +
    ((hostOrderAddress >> 8) & 255) + "." +
    (hostOrderAddress & 255)
end function

/// Create and initialize address.
/// @param addressText The address text input consumed by `newAddress`.
/// @param port The port input consumed by `newAddress`.
function newAddress(addressText, port)
  numeric = parseIpv4(addressText)
  if numeric is void then return error(3450, "invalid IPv4 address " + addressText) end if
  return t.WinSockAddress(AF_INET, htonl(numeric), htons(port))
end function

/// Update module state for address.
/// @param target The target input consumed by `setAddress`.
/// @param source Source value or collection to read.
function setAddress(target, source)
  target.family = source.family
  target.address = source.address
  target.port = source.port
  return target
end function

/// Implements the `BlockingHook` operation for `miniquake.net_wins` (blocking hook).
function BlockingHook()
  if win.ticks() / 1000.0 - blocktime > 2.0 then return false end if
  return win.poll()
end function

// Mirror Quake's WINS_GetLocalAddress routine and its observable state changes.
function WINS_GetLocalAddress()
  global myAddr, my_tcpip_address
  if myAddr != 0 then return my_tcpip_address end if
  addressText = udp.localAddress()
  numeric = parseIpv4(addressText)
  if numeric is void then return my_tcpip_address end if
  myAddr = htonl(numeric)
  my_tcpip_address = addressText
  return my_tcpip_address
end function

/// Return numeric host name derived from the active module state.
/// @param text Text to parse or process.
function numericHostName(text)
  source = bytes(text)
  if len(source) == 0 then return false end if
  for each character in source
    if (character < 48 or character > 57) and character != 46 then return false end if
  end for
  return true
end function

/// Return short host name derived from the active module state.
/// @param text Text to parse or process.
function shortHostName(text)
  if numericHostName(text) then return text end if
  source = bytes(text)
  count = len(source)
  if count > 15 then count = 15 end if
  index = 0
  while index < count
    if source[index] == 46 then count = index; break end if
    index = index + 1
  end while
  return decode(slice(source, 0, count))
end function

/// Mirror Quake's WINS_Init routine and its observable state changes.
/// @param hostName Name that identifies the requested value or resource.
/// @param noUdp The no udp input consumed by `WINS_Init`.
/// @param configuredIp The configured ip input consumed by `WINS_Init`.
/// @param hostPort The host port input consumed by `WINS_Init`.
function WINS_Init(hostName, noUdp, configuredIp, hostPort)
  global winsock_lib_initialized, winsock_initialized, configuredHostname
  global myAddr, my_tcpip_address, net_hostport, net_controlsocket, broadcastaddr, tcpipAvailable
  winsock_lib_initialized = true
  if noUdp then return -1 end if
  net_hostport = hostPort
  machineName = udp.hostName()
  if machineName == "" then return -1 end if
  winsock_initialized = winsock_initialized + 1
  configuredHostname = hostName
  if configuredHostname == "UNNAMED" then configuredHostname = shortHostName(machineName) end if
  if configuredIp != "" then
    parsed = parseIpv4(configuredIp)
    if parsed is void then
      winsock_initialized = winsock_initialized - 1
      return error(3451, configuredIp + " is not a valid IP address")
    end if
    myAddr = htonl(parsed)
    my_tcpip_address = configuredIp
    udp.configureBindAddress(configuredIp)
  else
    myAddr = 0
    my_tcpip_address = "INADDR_ANY"
    udp.configureBindAddress("0.0.0.0")
  end if
  net_controlsocket = WINS_OpenSocket(0)
  if net_controlsocket == -1 then
    winsock_initialized = winsock_initialized - 1
    return -1
  end if
  broadcastaddr = t.WinSockAddress(AF_INET, 0xffffffff, htons(net_hostport))
  tcpipAvailable = true
  return net_controlsocket
end function

// Mirror Quake's WINS_Shutdown routine and its observable state changes.
function WINS_Shutdown()
  global winsock_initialized, winsock_lib_initialized, net_controlsocket, tcpipAvailable
  WINS_Listen(false)
  if net_controlsocket is not void and net_controlsocket != -1 then WINS_CloseSocket(net_controlsocket) end if
  net_controlsocket = void
  if winsock_initialized > 0 then winsock_initialized = winsock_initialized - 1 end if
  if winsock_initialized == 0 then winsock_lib_initialized = false end if
  tcpipAvailable = false
  udp.configureBindAddress("0.0.0.0")
  return true
end function

/// Mirror Quake's WINS_Listen routine and its observable state changes.
/// @param state Mutable `miniquake.net_wins` state used by `WINS_Listen`.
function WINS_Listen(state)
  global net_acceptsocket
  if state then
    if net_acceptsocket is not void then return net_acceptsocket end if
    WINS_GetLocalAddress()
    net_acceptsocket = WINS_OpenSocket(net_hostport)
    return net_acceptsocket
  end if
  if net_acceptsocket is void then return true end if
  WINS_CloseSocket(net_acceptsocket)
  net_acceptsocket = void
  return true
end function

/// Mirror Quake's WINS_OpenSocket routine and its observable state changes.
/// @param port The port input consumed by `WINS_OpenSocket`.
function WINS_OpenSocket(port)
  global lastError
  bindAddress = "0.0.0.0"
  if myAddr != 0 then bindAddress = ipv4Text(ntohl(myAddr)) end if
  opened = try(udp.openBound(port, bindAddress))
  if opened is error then lastError = opened.code; return -1 end if
  lastError = 0
  return opened
end function

/// Mirror Quake's WINS_CloseSocket routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_CloseSocket`.
function WINS_CloseSocket(socketValue)
  global net_broadcastsocket
  if socketValue is void or socketValue == -1 then return -1 end if
  if net_broadcastsocket is not void and socketValue == net_broadcastsocket then net_broadcastsocket = void end if
  if udp.close(socketValue) then return 0 end if
  return -1
end function

/// Implements the `PartialIPAddress` operation for `miniquake.net_wins` (partial ip address).
/// @param input The input input consumed by `PartialIPAddress`.
/// @param hostaddr The hostaddr input consumed by `PartialIPAddress`.
function PartialIPAddress(input, hostaddr)
  text = input
  source = bytes(text)
  if len(source) > 0 and source[0] == 46 then text = decode(slice(source, 1, len(source) - 1)) end if
  colon = -1
  source = bytes(text)
  index = 0
  while index < len(source)
    if source[index] == 58 then
      if colon >= 0 then return -1 end if
      colon = index
    end if
    index = index + 1
  end while
  addressPart = text
  port = net_hostport
  if colon >= 0 then
    addressPart = decode(slice(source, 0, colon))
    portText = decode(slice(source, colon + 1, len(source) - colon - 1))
    // WinQuake uses Q_atoi here and then stores the result through htons(short).
    // Preserve decimal-prefix parsing and 16-bit wrapping for PartialIPAddress.
    port = common.atoi(portText)
  end if
  parts = splitText(addressPart, 46)
  if len(parts) < 1 or len(parts) > 4 then return -1 end if
  suffix = []
  for each part in parts
    value = parseDecimal(part, 3, 255)
    if value is void then return -1 end if
    suffix = suffix + [value]
  end for
  WINS_GetLocalAddress()
  localHost = ntohl(myAddr)
  localParts = [
    (localHost >> 24) & 255,
    (localHost >> 16) & 255,
    (localHost >> 8) & 255,
    localHost & 255,
  ]
  combined = array(4, 0)
  prefixCount = 4 - len(suffix)
  index = 0
  while index < prefixCount
    combined[index] = localParts[index]
    index = index + 1
  end while
  suffixIndex = 0
  while suffixIndex < len(suffix)
    combined[prefixCount + suffixIndex] = suffix[suffixIndex]
    suffixIndex = suffixIndex + 1
  end while
  hostOrder = ((combined[0] & 255) << 24) | ((combined[1] & 255) << 16) | ((combined[2] & 255) << 8) | (combined[3] & 255)
  hostaddr.family = AF_INET
  hostaddr.address = htonl(hostOrder)
  hostaddr.port = htons(port)
  return 0
end function

/// Mirror Quake's WINS_Connect routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_Connect`.
/// @param addr The addr input consumed by `WINS_Connect`.
function WINS_Connect(socketValue, addr)
  return 0
end function

// Mirror Quake's WINS_CheckNewConnections routine and its observable state changes.
function WINS_CheckNewConnections()
  if net_acceptsocket is void then return -1 end if
  available = try(udp.peek(net_acceptsocket))
  if available is error or available <= 0 then return -1 end if
  return net_acceptsocket
end function

/// Mirror Quake's WINS_Read routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_Read`.
/// @param buffer The buffer input consumed by `WINS_Read`.
/// @param length Length of the requested data in units appropriate to the operation.
/// @param addr The addr input consumed by `WINS_Read`.
function WINS_Read(socketValue, buffer, length, addr)
  global lastError
  received = try(udp.receive(socketValue, length))
  if received is error then lastError = received.code; return -1 end if
  if received is void then lastError = 0; return 0 end if
  count = len(received[0])
  index = 0
  while index < count
    buffer[index] = received[0][index]
    index = index + 1
  end while
  parsed = newAddress(received[1], received[2])
  if parsed is not error then setAddress(addr, parsed) end if
  lastError = 0
  return count
end function

/// Mirror Quake's WINS_MakeSocketBroadcastCapable routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_MakeSocketBroadcastCapable`.
function WINS_MakeSocketBroadcastCapable(socketValue)
  global net_broadcastsocket, lastError
  result = try(udp.makeBroadcastCapable(socketValue))
  if result is error then lastError = result.code; return -1 end if
  net_broadcastsocket = socketValue
  lastError = 0
  return 0
end function

/// Mirror Quake's WINS_Broadcast routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_Broadcast`.
/// @param buffer The buffer input consumed by `WINS_Broadcast`.
/// @param length Length of the requested data in units appropriate to the operation.
function WINS_Broadcast(socketValue, buffer, length)
  if net_broadcastsocket is void or socketValue != net_broadcastsocket then
    if net_broadcastsocket is not void then return error(3452, "Attempted to use multiple broadcasts sockets") end if
    WINS_GetLocalAddress()
    capable = WINS_MakeSocketBroadcastCapable(socketValue)
    if capable == -1 then return -1 end if
  end if
  return WINS_Write(socketValue, buffer, length, broadcastaddr)
end function

/// Mirror Quake's WINS_Write routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_Write`.
/// @param buffer The buffer input consumed by `WINS_Write`.
/// @param length Length of the requested data in units appropriate to the operation.
/// @param addr The addr input consumed by `WINS_Write`.
function WINS_Write(socketValue, buffer, length, addr)
  global lastError
  if length < 0 or length > len(buffer) then return -1 end if
  payload = slice(buffer, 0, length)
  result = try(udp.send(socketValue, ipv4Text(ntohl(addr.address)), ntohs(addr.port), payload))
  if result is error then lastError = result.code; return -1 end if
  lastError = 0
  return result
end function

/// Mirror Quake's WINS_AddrToString routine and its observable state changes.
/// @param addr The addr input consumed by `WINS_AddrToString`.
function WINS_AddrToString(addr)
  return ipv4Text(ntohl(addr.address)) + ":" + ntohs(addr.port)
end function

/// Mirror Quake's WINS_StringToAddr routine and its observable state changes.
/// @param text Text to parse or process.
/// @param addr The addr input consumed by `WINS_StringToAddr`.
function WINS_StringToAddr(text, addr)
  source = bytes(text)
  colon = -1
  index = 0
  while index < len(source)
    if source[index] == 58 then colon = index end if
    index = index + 1
  end while
  if colon < 1 or colon >= len(source) - 1 then return -1 end if
  addressText = decode(slice(source, 0, colon))
  portText = decode(slice(source, colon + 1, len(source) - colon - 1))
  numeric = parseIpv4(addressText)
  port = parseDecimal(portText, 5, 65535)
  if numeric is void or port is void then return -1 end if
  addr.family = AF_INET
  addr.address = htonl(numeric)
  addr.port = htons(port)
  return 0
end function

/// Mirror Quake's WINS_GetSocketAddr routine and its observable state changes.
/// @param socketValue The socket value input consumed by `WINS_GetSocketAddr`.
/// @param addr The addr input consumed by `WINS_GetSocketAddr`.
function WINS_GetSocketAddr(socketValue, addr)
  addressText = socketValue.bindAddress
  if addressText == "0.0.0.0" or addressText == "127.0.0.1" then
    WINS_GetLocalAddress()
    addressText = ipv4Text(ntohl(myAddr))
  end if
  parsed = newAddress(addressText, socketValue.port)
  if parsed is error then return -1 end if
  setAddress(addr, parsed)
  return 0
end function

/// Mirror Quake's WINS_GetNameFromAddr routine and its observable state changes.
/// @param addr The addr input consumed by `WINS_GetNameFromAddr`.
function WINS_GetNameFromAddr(addr)
  addressText = ipv4Text(ntohl(addr.address))
  resolved = try(udp.reverseName(addressText))
  if resolved is error then return shortText(WINS_AddrToString(addr), NET_NAMELEN - 1) end if
  return shortText(resolved, NET_NAMELEN - 1)
end function

/// Mirror Quake's WINS_GetAddrFromName routine and its observable state changes.
/// @param name Stable name that identifies the requested object or option.
/// @param addr The addr input consumed by `WINS_GetAddrFromName`.
function WINS_GetAddrFromName(name, addr)
  source = bytes(name)
  if len(source) == 0 then return -1 end if
  if source[0] >= 48 and source[0] <= 57 then return PartialIPAddress(name, addr) end if
  resolved = try(udp.resolveName(name))
  if resolved is error then return -1 end if
  parsed = newAddress(resolved, net_hostport)
  if parsed is error then return -1 end if
  setAddress(addr, parsed)
  return 0
end function

/// Mirror Quake's WINS_AddrCompare routine and its observable state changes.
/// @param addr1 The addr1 input consumed by `WINS_AddrCompare`.
/// @param addr2 The addr2 input consumed by `WINS_AddrCompare`.
function WINS_AddrCompare(addr1, addr2)
  if addr1.family != addr2.family then return -1 end if
  if addr1.address != addr2.address then return -1 end if
  if addr1.port != addr2.port then return 1 end if
  return 0
end function

/// Mirror Quake's WINS_GetSocketPort routine and its observable state changes.
/// @param addr The addr input consumed by `WINS_GetSocketPort`.
function WINS_GetSocketPort(addr)
  return ntohs(addr.port)
end function

/// Mirror Quake's WINS_SetSocketPort routine and its observable state changes.
/// @param addr The addr input consumed by `WINS_SetSocketPort`.
/// @param port The port input consumed by `WINS_SetSocketPort`.
function WINS_SetSocketPort(addr, port)
  addr.port = htons(port)
  return 0
end function
