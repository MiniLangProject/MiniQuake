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

const AF_INET = 2
const MAXHOSTNAMELEN = 256
const NET_NAMELEN = 64

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

// Mirror Quake's WINS_SetLocalAddress routine and its observable state changes.
function WINS_SetLocalAddress(addressText)
  global myAddr, my_tcpip_address
  numeric = parseIpv4(addressText)
  if numeric is void then return error(3453, "invalid local IPv4 address " + addressText) end if
  myAddr = htonl(numeric)
  my_tcpip_address = addressText
  return my_tcpip_address
end function

// Mirror Quake's WINS_SetBlockTime routine and its observable state changes.
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

// Mirror Quake's WINS_SetAcceptSocket routine and its observable state changes.
function WINS_SetAcceptSocket(socketValue)
  global net_acceptsocket
  net_acceptsocket = socketValue
  return net_acceptsocket
end function

// Mirror Quake's WINS_SetBroadcastSocket routine and its observable state changes.
function WINS_SetBroadcastSocket(socketValue)
  global net_broadcastsocket
  net_broadcastsocket = socketValue
  return net_broadcastsocket
end function

// Provide htons behavior for the active subsystem.
function htons(value)
  number = value & 0xffff
  return ((number & 255) << 8) | ((number >> 8) & 255)
end function

// Provide ntohs behavior for the active subsystem.
function ntohs(value)
  return htons(value)
end function

// Provide htonl behavior for the active subsystem.
function htonl(value)
  return ((value & 255) << 24) |
    ((value & 0xff00) << 8) |
    ((value >> 8) & 0xff00) |
    ((value >> 24) & 255)
end function

// Provide ntohl behavior for the active subsystem.
function ntohl(value)
  return htonl(value)
end function

// Provide short text behavior for the active subsystem.
function shortText(text, maximum)
  data = bytes(text)
  if len(data) <= maximum then return text end if
  return decode(slice(data, 0, maximum))
end function

// Convert text into its canonical representation.
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

// Read and validate decimal.
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

// Read and validate ipv4.
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

// Provide ipv4 text behavior for the active subsystem.
function ipv4Text(hostOrderAddress)
  return ((hostOrderAddress >> 24) & 255) + "." +
    ((hostOrderAddress >> 16) & 255) + "." +
    ((hostOrderAddress >> 8) & 255) + "." +
    (hostOrderAddress & 255)
end function

// Create and initialize address.
function newAddress(addressText, port)
  numeric = parseIpv4(addressText)
  if numeric is void then return error(3450, "invalid IPv4 address " + addressText) end if
  return t.WinSockAddress(AF_INET, htonl(numeric), htons(port))
end function

// Update module state for address.
function setAddress(target, source)
  target.family = source.family
  target.address = source.address
  target.port = source.port
  return target
end function

// Provide blocking hook behavior for the active subsystem.
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

// Return numeric host name derived from the active module state.
function numericHostName(text)
  source = bytes(text)
  if len(source) == 0 then return false end if
  for each character in source
    if (character < 48 or character > 57) and character != 46 then return false end if
  end for
  return true
end function

// Return short host name derived from the active module state.
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

// Mirror Quake's WINS_Init routine and its observable state changes.
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

// Mirror Quake's WINS_Listen routine and its observable state changes.
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

// Mirror Quake's WINS_OpenSocket routine and its observable state changes.
function WINS_OpenSocket(port)
  global lastError
  bindAddress = "0.0.0.0"
  if myAddr != 0 then bindAddress = ipv4Text(ntohl(myAddr)) end if
  opened = try(udp.openBound(port, bindAddress))
  if opened is error then lastError = opened.code; return -1 end if
  lastError = 0
  return opened
end function

// Mirror Quake's WINS_CloseSocket routine and its observable state changes.
function WINS_CloseSocket(socketValue)
  global net_broadcastsocket
  if socketValue is void or socketValue == -1 then return -1 end if
  if net_broadcastsocket is not void and socketValue == net_broadcastsocket then net_broadcastsocket = void end if
  if udp.close(socketValue) then return 0 end if
  return -1
end function

// Provide partial ipaddress behavior for the active subsystem.
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

// Mirror Quake's WINS_Connect routine and its observable state changes.
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

// Mirror Quake's WINS_Read routine and its observable state changes.
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

// Mirror Quake's WINS_MakeSocketBroadcastCapable routine and its observable state changes.
function WINS_MakeSocketBroadcastCapable(socketValue)
  global net_broadcastsocket, lastError
  result = try(udp.makeBroadcastCapable(socketValue))
  if result is error then lastError = result.code; return -1 end if
  net_broadcastsocket = socketValue
  lastError = 0
  return 0
end function

// Mirror Quake's WINS_Broadcast routine and its observable state changes.
function WINS_Broadcast(socketValue, buffer, length)
  if net_broadcastsocket is void or socketValue != net_broadcastsocket then
    if net_broadcastsocket is not void then return error(3452, "Attempted to use multiple broadcasts sockets") end if
    WINS_GetLocalAddress()
    capable = WINS_MakeSocketBroadcastCapable(socketValue)
    if capable == -1 then return -1 end if
  end if
  return WINS_Write(socketValue, buffer, length, broadcastaddr)
end function

// Mirror Quake's WINS_Write routine and its observable state changes.
function WINS_Write(socketValue, buffer, length, addr)
  global lastError
  if length < 0 or length > len(buffer) then return -1 end if
  payload = slice(buffer, 0, length)
  result = try(udp.send(socketValue, ipv4Text(ntohl(addr.address)), ntohs(addr.port), payload))
  if result is error then lastError = result.code; return -1 end if
  lastError = 0
  return result
end function

// Mirror Quake's WINS_AddrToString routine and its observable state changes.
function WINS_AddrToString(addr)
  return ipv4Text(ntohl(addr.address)) + ":" + ntohs(addr.port)
end function

// Mirror Quake's WINS_StringToAddr routine and its observable state changes.
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

// Mirror Quake's WINS_GetSocketAddr routine and its observable state changes.
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

// Mirror Quake's WINS_GetNameFromAddr routine and its observable state changes.
function WINS_GetNameFromAddr(addr)
  addressText = ipv4Text(ntohl(addr.address))
  resolved = try(udp.reverseName(addressText))
  if resolved is error then return shortText(WINS_AddrToString(addr), NET_NAMELEN - 1) end if
  return shortText(resolved, NET_NAMELEN - 1)
end function

// Mirror Quake's WINS_GetAddrFromName routine and its observable state changes.
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

// Mirror Quake's WINS_AddrCompare routine and its observable state changes.
function WINS_AddrCompare(addr1, addr2)
  if addr1.family != addr2.family then return -1 end if
  if addr1.address != addr2.address then return -1 end if
  if addr1.port != addr2.port then return 1 end if
  return 0
end function

// Mirror Quake's WINS_GetSocketPort routine and its observable state changes.
function WINS_GetSocketPort(addr)
  return ntohs(addr.port)
end function

// Mirror Quake's WINS_SetSocketPort routine and its observable state changes.
function WINS_SetSocketPort(addr, port)
  addr.port = htons(port)
  return 0
end function
