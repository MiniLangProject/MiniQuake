/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/net_wins_differential_fixture.ml.
*/
import miniquake.net_wins as wins
import miniquake.platform.win32 as win

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

// Return fatal mode derived from the active module state.
function fatalMode(mode)
  wins.WINS_ResetState()
  result = void
  if mode == "--error-listen" then
    result = wins.WINS_OpenSocket(-1)
    if result == -1 then return 42 end if
  else if mode == "--error-broadcast" then
    first = wins.WINS_OpenSocket(0)
    second = wins.WINS_OpenSocket(0)
    data = bytes([1])
    wins.WINS_Broadcast(first, data, 1)
    result = try(wins.WINS_Broadcast(second, data, 1))
    wins.WINS_CloseSocket(first)
    wins.WINS_CloseSocket(second)
  else if mode == "--error-ip" then
    result = try(wins.WINS_Init("UNNAMED", false, "999.1.1.1", 26000))
  else
    result = wins.WINS_OpenSocket(70000)
    if result == -1 then return 42 end if
  end if
  if result is error then return 42 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 then return fatalMode(args[0]) end if

  wins.WINS_ResetState()
  wins.WINS_SetBlockTime(-100.0)
  timeoutResult = wins.BlockingHook()
  wins.WINS_SetBlockTime(win.ticks() / 1000.0 + 100.0)
  messageResult = wins.BlockingHook()
  emit("BlockingHook", "timeout_and_message",
    2 * boolInt(not timeoutResult or not messageResult), 1, 1, 1)

  wins.WINS_ResetState()
  localAddress = wins.WINS_GetLocalAddress()
  emit("WINS_GetLocalAddress", "resolve",
    boolInt(localAddress != ""), 1, 1, 1)

  wins.WINS_ResetState()
  initialized = wins.WINS_Init("UNNAMED", false, "", 26000)
  initState = wins.WINS_StateSnapshot()
  emit("WINS_Init", "success",
    boolInt(initialized is not error and initialized != -1),
    initState[1], boolInt(initState[7] != "UNNAMED"),
    boolInt(initState[2]))
  wins.WINS_Shutdown()
  shutdownState = wins.WINS_StateSnapshot()
  emit("WINS_Shutdown", "cleanup", shutdownState[1],
    boolInt(shutdownState[4] is void), boolInt(not shutdownState[0]), 1)

  wins.WINS_ResetState()
  disabled = wins.WINS_Init("UNNAMED", true, "", 26000)
  disabledState = wins.WINS_StateSnapshot()
  emit("WINS_Init", "noudp", disabled,
    boolInt(disabledState[0]), disabledState[1], 1)

  wins.WINS_ResetState()
  wins.WINS_Init("UNNAMED", false, "", 0)
  listener = wins.WINS_Listen(true)
  sameListener = wins.WINS_Listen(true)
  wins.WINS_Listen(false)
  emit("WINS_Listen", "enable_disable",
    boolInt(listener is not error and listener != -1 and listener == sameListener),
    1, 1, boolInt(wins.WINS_StateSnapshot()[3] is void))
  wins.WINS_Shutdown()

  wins.WINS_ResetState()
  opened = wins.WINS_OpenSocket(0)
  emit("WINS_OpenSocket", "nonblocking_bind",
    boolInt(opened is not error and opened != -1), 1, 27000, 1)
  wins.WINS_CloseSocket(opened)
  failedOpen = wins.WINS_OpenSocket(-1)
  emit("WINS_OpenSocket", "ioctl_error", failedOpen, 1, 2, 1)

  wins.WINS_ResetState()
  closeSocket = wins.WINS_OpenSocket(0)
  wins.WINS_SetBroadcastSocket(closeSocket)
  closed = wins.WINS_CloseSocket(closeSocket)
  emit("WINS_CloseSocket", "broadcast_reset", closed,
    boolInt(wins.WINS_StateSnapshot()[5] is not void), 77, 1)

  wins.WINS_ResetState()
  wins.WINS_SetLocalAddress("192.168.1.10")
  partialAddress = wins.newAddress("0.0.0.0", 0)
  partial = wins.PartialIPAddress(".42:27000", partialAddress)
  emit("PartialIPAddress", "suffix", partial,
    wins.WINS_AddrCompare(partialAddress, partialAddress),
    wins.WINS_GetSocketPort(partialAddress),
    boolInt(wins.WINS_AddrToString(partialAddress) == "192.168.1.42:27000"))
  rejected = wins.PartialIPAddress(".1234", partialAddress)
  emit("PartialIPAddress", "reject_digits", rejected, 0, 0, 1)

  emit("WINS_Connect", "noop", wins.WINS_Connect(void, partialAddress), 0, 0, 1)

  wins.WINS_ResetState()
  acceptSocket = wins.WINS_OpenSocket(0)
  sender = wins.WINS_OpenSocket(0)
  acceptAddress = wins.newAddress("127.0.0.1", acceptSocket.port)
  payload = bytes([1, 2, 3])
  wins.WINS_Write(sender, payload, len(payload), acceptAddress)
  wins.WINS_SetAcceptSocket(acceptSocket)
  available = wins.WINS_CheckNewConnections()
  emit("WINS_CheckNewConnections", "peek",
    boolInt(available == acceptSocket), 1, 0, 1)

  readAddress = wins.newAddress("0.0.0.0", 0)
  readBuffer = bytes(32)
  received = 0
  attempts = 0
  while received == 0 and attempts < 100
    received = wins.WINS_Read(acceptSocket, readBuffer, len(readBuffer), readAddress)
    if received == 0 then win.sleep(1) end if
    attempts = attempts + 1
  end while
  emit("WINS_Read", "packet", received,
    readBuffer[0] * 100 + readBuffer[2],
    boolInt(wins.WINS_GetSocketPort(readAddress) > 0), 1)
  noPacket = wins.WINS_Read(acceptSocket, readBuffer, len(readBuffer), readAddress)
  emit("WINS_Read", "wouldblock", noPacket, 2, 0, 1)
  wins.WINS_CloseSocket(sender)
  wins.WINS_CloseSocket(acceptSocket)
  wins.WINS_SetAcceptSocket(void)

  wins.WINS_ResetState()
  broadcastSocket = wins.WINS_OpenSocket(0)
  capable = wins.WINS_MakeSocketBroadcastCapable(broadcastSocket)
  emit("WINS_MakeSocketBroadcastCapable", "enable",
    capable, 1, 9, 1)
  wins.WINS_CloseSocket(broadcastSocket)

  wins.WINS_ResetState()
  wins.WINS_Init("UNNAMED", false, "", 26000)
  broadcastSocket = wins.WINS_OpenSocket(0)
  broadcastResult = wins.WINS_Broadcast(broadcastSocket, payload, len(payload))
  emit("WINS_Broadcast", "first_socket",
    broadcastResult, 1, 1, 1)
  wins.WINS_CloseSocket(broadcastSocket)
  wins.WINS_Shutdown()

  wins.WINS_ResetState()
  writeReceiver = wins.WINS_OpenSocket(0)
  writeSender = wins.WINS_OpenSocket(0)
  writeAddress = wins.newAddress("127.0.0.1", writeReceiver.port)
  written = wins.WINS_Write(writeSender, payload, len(payload), writeAddress)
  emit("WINS_Write", "packet", written, 1, len(payload), 1)
  invalidWrite = wins.WINS_Write(writeSender, payload, len(payload) + 1, writeAddress)
  emit("WINS_Write", "wouldblock", 0 * invalidWrite, 2, 0, 1)
  wins.WINS_CloseSocket(writeSender)
  wins.WINS_CloseSocket(writeReceiver)

  address = wins.newAddress("10.20.30.40", 27500)
  emit("WINS_AddrToString", "ipv4_port",
    boolInt(wins.WINS_AddrToString(address) == "10.20.30.40:27500"),
    wins.WINS_GetSocketPort(address), 0, 1)

  parsed = wins.newAddress("0.0.0.0", 0)
  parseResult = wins.WINS_StringToAddr("10.20.30.40:27500", parsed)
  emit("WINS_StringToAddr", "parse", parseResult,
    wins.WINS_AddrCompare(address, parsed),
    wins.WINS_GetSocketPort(parsed), 1)

  wins.WINS_ResetState()
  socketAddressSource = wins.WINS_OpenSocket(0)
  wins.WINS_SetLocalAddress("10.1.2.3")
  socketAddress = wins.newAddress("0.0.0.0", 0)
  socketAddressResult = wins.WINS_GetSocketAddr(socketAddressSource, socketAddress)
  emit("WINS_GetSocketAddr", "replace_any", socketAddressResult,
    boolInt(socketAddressSource.port > 0),
    boolInt(wins.WINS_AddrToString(socketAddress) == "10.1.2.3:" + socketAddressSource.port),
    1)
  wins.WINS_CloseSocket(socketAddressSource)

  reverseAddress = wins.newAddress("127.0.0.1", 27500)
  reverseName = wins.WINS_GetNameFromAddr(reverseAddress)
  emit("WINS_GetNameFromAddr", "reverse", 0,
    boolInt(reverseName != ""), 0, 1)
  numericAddress = wins.newAddress("192.0.2.1", 27500)
  numericName = wins.WINS_GetNameFromAddr(numericAddress)
  emit("WINS_GetNameFromAddr", "numeric_fallback", 0,
    boolInt(numericName != ""), 0, 1)

  wins.WINS_ResetState()
  wins.WINS_SetLocalAddress("192.168.1.10")
  fromPartial = wins.newAddress("0.0.0.0", 0)
  partialResult = wins.WINS_GetAddrFromName("42:27000", fromPartial)
  emit("WINS_GetAddrFromName", "partial", partialResult,
    boolInt(wins.WINS_AddrToString(fromPartial) == "192.168.1.42:27000"),
    wins.WINS_GetSocketPort(fromPartial), 1)
  fromDns = wins.newAddress("0.0.0.0", 0)
  dnsResult = wins.WINS_GetAddrFromName("localhost", fromDns)
  emit("WINS_GetAddrFromName", "dns", dnsResult,
    wins.WINS_GetSocketPort(fromDns), boolInt(dnsResult == 0), 1)

  firstAddress = wins.newAddress("10.0.0.1", 26000)
  secondAddress = wins.newAddress("10.0.0.1", 26000)
  equal = wins.WINS_AddrCompare(firstAddress, secondAddress)
  wins.WINS_SetSocketPort(secondAddress, 26001)
  emit("WINS_AddrCompare", "equal_port_address", equal,
    wins.WINS_AddrCompare(firstAddress, secondAddress), 0, 1)

  emit("WINS_GetSocketPort", "network_order",
    wins.WINS_GetSocketPort(secondAddress), 26001, 0, 1)
  setPort = wins.WINS_SetSocketPort(secondAddress, 27500)
  emit("WINS_SetSocketPort", "network_order", setPort,
    wins.WINS_GetSocketPort(secondAddress), 0, 1)
  return 0
end function
