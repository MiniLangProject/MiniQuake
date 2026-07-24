/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors
*/

import miniquake.types as t
import miniquake.net_wins as wins
import miniquake.platform.win32 as win

function require(value, message)
  if not value then return error(9360, message) end if
  return true
end function

function waitForConnection(attempts)
  index = 0
  while index < attempts
    socketValue = wins.WINS_CheckNewConnections()
    if socketValue != -1 then return socketValue end if
    win.sleep(1)
    index = index + 1
  end while
  return error(9361, "WINS_CheckNewConnections timed out")
end function

function main(args)
  require(wins.htons(0x1234) == 0x3412, "htons")
  require(wins.ntohs(0x3412) == 0x1234, "ntohs")
  require(wins.htonl(0x01020304) == 0x04030201, "htonl")
  require(wins.ntohl(0x04030201) == 0x01020304, "ntohl")

  address = t.WinSockAddress(0, 0, 0)
  require(wins.WINS_StringToAddr("1.2.3.4:26000", address) == 0, "StringToAddr")
  require(address.family == wins.AF_INET, "address family")
  require(wins.WINS_AddrToString(address) == "1.2.3.4:26000", "AddrToString")
  require(wins.WINS_GetSocketPort(address) == 26000, "GetSocketPort")
  wins.WINS_SetSocketPort(address, 27000)
  require(wins.WINS_GetSocketPort(address) == 27000, "SetSocketPort")
  sameAddress = t.WinSockAddress(wins.AF_INET, address.address, wins.htons(27001))
  require(wins.WINS_AddrCompare(address, sameAddress) == 1, "AddrCompare port")
  sameAddress.address = wins.htonl(0x01020305)
  require(wins.WINS_AddrCompare(address, sameAddress) == -1, "AddrCompare host")
  require(wins.WINS_StringToAddr("1.2.3:26000", address) == -1, "reject short StringToAddr")

  require(wins.WINS_Init("UNNAMED", true, "", 27881) == -1, "-noudp")
  invalidInit = try(wins.WINS_Init("UNNAMED", false, "999.1.1.1", 27881))
  require(invalidInit is error, "invalid -ip")
  control = wins.WINS_Init("UNNAMED", false, "", 27881)
  require(control != -1 and control is not error, "WINS_Init")
  require(wins.tcpipAvailable, "tcpip available")
  require(wins.configuredHostname != "" and wins.configuredHostname != "UNNAMED", "configured hostname")

  partial = t.WinSockAddress(0, 0, 0)
  require(wins.PartialIPAddress("55", partial) == 0, "partial IP")
  require((wins.ntohl(partial.address) & 255) == 55, "partial IP suffix")
  require((wins.ntohl(partial.address) & 0xffffff00) == (wins.ntohl(wins.myAddr) & 0xffffff00), "partial IP local prefix")
  require(wins.PartialIPAddress("1.2.3.4:27000", partial) == 0, "full partial IP")
  require(wins.WINS_AddrToString(partial) == "1.2.3.4:27000", "full partial address")
  require(wins.PartialIPAddress("1234", partial) == -1, "partial IP digit limit")

  named = t.WinSockAddress(0, 0, 0)
  require(wins.WINS_GetAddrFromName("localhost", named) == 0, "hostname resolution")
  require(wins.WINS_GetSocketPort(named) == 27881, "hostname default port")
  require(wins.WINS_GetNameFromAddr(named) != "", "reverse name or numeric fallback")

  listener = wins.WINS_Listen(true)
  require(listener != -1, "WINS_Listen")
  listenerAddress = t.WinSockAddress(0, 0, 0)
  require(wins.WINS_GetSocketAddr(listener, listenerAddress) == 0, "GetSocketAddr")
  sender = wins.WINS_OpenSocket(0)
  require(sender != -1, "sender socket")
  payload = bytes("net_wins unicast")
  require(wins.WINS_Write(sender, payload, len(payload), listenerAddress) == len(payload), "WINS_Write")
  accepted = waitForConnection(2000)
  require(accepted is not error, "peek new connection")
  buffer = bytes(256)
  source = t.WinSockAddress(0, 0, 0)
  count = wins.WINS_Read(listener, buffer, len(buffer), source)
  require(count == len(payload), "WINS_Read length")
  require(decode(slice(buffer, 0, count)) == decode(payload), "WINS_Read payload")
  require(wins.WINS_GetSocketPort(source) == sender.port, "recvfrom source port")

  broadcastPayload = bytes("net_wins broadcast")
  broadcastResult = wins.WINS_Broadcast(sender, broadcastPayload, len(broadcastPayload))
  require(broadcastResult == len(broadcastPayload), "WINS_Broadcast")
  require(sender.broadcast, "SO_BROADCAST enabled lazily")
  other = wins.WINS_OpenSocket(0)
  require(other != -1, "second sender")
  secondBroadcast = try(wins.WINS_Broadcast(other, broadcastPayload, len(broadcastPayload)))
  require(secondBroadcast is error, "single broadcast socket invariant")

  wins.WINS_CloseSocket(other)
  wins.WINS_CloseSocket(sender)
  wins.WINS_Listen(false)
  wins.WINS_Shutdown()
  require(not wins.tcpipAvailable, "WINS_Shutdown")
  print "MiniQuake net_wins tests passed"
  return 0
end function
