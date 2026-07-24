package miniquake.net_udp

import miniquake.types as t
import miniquake.native as native
import miniquake.platform.win32 as win

const MAX_UDP_PAYLOAD = 65507
defaultBindAddress = "0.0.0.0"

function open(port)
  return openBound(port, defaultBindAddress)
end function

function configureBindAddress(address)
  global defaultBindAddress
  if address is void or address == "" then defaultBindAddress = "0.0.0.0" else defaultBindAddress = address end if
  return defaultBindAddress
end function

function openBound(port, bindAddress)
  if port < 0 or port > 65535 then return error(3200, "UDP_OpenSocket: invalid port " + port) end if
  handle = native.udpOpenBound(port, bindAddress)
  if handle == 0 then return error(3201, "UDP_OpenSocket: WSA error " + native.udpLastError()) end if
  actualPort = native.udpBoundPort(handle)
  if actualPort == 0 then
    errorCode = native.udpLastError()
    native.udpClose(handle)
    return error(3202, "UDP_OpenSocket: getsockname failed with WSA error " + errorCode)
  end if
  actualAddress = native.udpBoundAddress(handle)
  if actualAddress is void or actualAddress == "" then actualAddress = bindAddress end if
  return t.UdpSocket(handle, actualPort, "0.0.0.0", true, actualAddress, false)
end function

function close(socketValue)
  if socketValue is void or not socketValue.open then return false end if
  native.udpClose(socketValue.handle)
  socketValue.handle = 0
  socketValue.open = false
  return true
end function

function send(socketValue, address, port, payload)
  if socketValue is void or not socketValue.open then return error(3203, "UDP_Write: socket is closed") end if
  if payload is not bytes then return error(3204, "UDP_Write: payload must be bytes") end if
  if len(payload) > MAX_UDP_PAYLOAD then return error(3205, "UDP_Write: payload exceeds 65507 bytes") end if
  if port < 1 or port > 65535 then return error(3206, "UDP_Write: invalid destination port " + port) end if
  written = native.udpSend(socketValue.handle, address, port, payload, len(payload))
  if written < 0 then return error(3207, "UDP_Write: WSA error " + native.udpLastError()) end if
  return written
end function

function broadcast(socketValue, port, payload)
  capable = try(makeBroadcastCapable(socketValue))
  if capable is error then return capable end if
  return send(socketValue, "255.255.255.255", port, payload)
end function

function makeBroadcastCapable(socketValue)
  if socketValue is void or not socketValue.open then return error(3211, "UDP_Broadcast: socket is closed") end if
  if socketValue.broadcast then return true end if
  if native.udpEnableBroadcast(socketValue.handle) < 0 then return error(3212, "UDP_Broadcast: WSA error " + native.udpLastError()) end if
  socketValue.broadcast = true
  return true
end function

function peek(socketValue)
  if socketValue is void or not socketValue.open then return error(3213, "UDP_Peek: socket is closed") end if
  count = native.udpPeek(socketValue.handle)
  if count < 0 then return error(3214, "UDP_Peek: WSA error " + native.udpLastError()) end if
  return count
end function

function localAddress()
  address = native.udpLocalAddress()
  if address is void or address == "" then return "127.0.0.1" end if
  return address
end function

function hostName()
  value = native.udpHostName()
  if value is void then return "" end if
  return value
end function

function resolveName(name)
  value = native.udpResolveName(name)
  if value is void or value == "" then return error(3215, "UDP_GetAddrFromName: WSA error " + native.udpLastError()) end if
  return value
end function

function reverseName(address)
  value = native.udpReverseName(address)
  if value is void or value == "" then return error(3216, "UDP_GetNameFromAddr: WSA error " + native.udpLastError()) end if
  return value
end function

function receive(socketValue, capacity)
  if socketValue is void or not socketValue.open then return error(3208, "UDP_Read: socket is closed") end if
  if capacity < 1 then capacity = 1 end if
  if capacity > 65535 then capacity = 65535 end if
  buffer = bytes(capacity)
  count = native.udpReceive(socketValue.handle, buffer, capacity)
  if count < 0 then return error(3209, "UDP_Read: WSA error " + native.udpLastError()) end if
  if count == 0 then return void end if
  address = native.udpLastAddress()
  if address is void then address = "0.0.0.0" end if
  port = native.udpLastPort()
  socketValue.address = address
  return [slice(buffer, 0, count), address, port]
end function

function smoke(timeoutMilliseconds)
  receiverResult = try(open(0))
  if receiverResult is error then
    return t.UdpSmokeResult(false, 0, 0, 0, 0, "", "", 0, receiverResult.code)
  end if
  receiver = receiverResult
  senderResult = try(open(0))
  if senderResult is error then
    close(receiver)
    return t.UdpSmokeResult(false, 0, receiver.port, 0, 0, "", "", 0, senderResult.code)
  end if
  sender = senderResult

  payload = bytes("MiniQuake UDP loopback")
  sentResult = try(send(sender, "127.0.0.1", receiver.port, payload))
  if sentResult is error then
    errorCode = sentResult.code
    close(sender)
    close(receiver)
    return t.UdpSmokeResult(false, sender.port, receiver.port, 0, 0, "", "", 0, errorCode)
  end if

  if timeoutMilliseconds < 1 then timeoutMilliseconds = 1 end if
  elapsed = 0
  received = void
  while elapsed < timeoutMilliseconds
    packet = try(receive(receiver, 2048))
    if packet is error then
      errorCode = packet.code
      close(sender)
      close(receiver)
      return t.UdpSmokeResult(false, sender.port, receiver.port, sentResult, 0, "", "", 0, errorCode)
    end if
    if packet is not void then received = packet; break end if
    win.sleep(1)
    elapsed = elapsed + 1
  end while

  senderPort = sender.port
  receiverPort = receiver.port
  close(sender)
  close(receiver)
  if received is void then
    return t.UdpSmokeResult(false, senderPort, receiverPort, sentResult, 0, "", "", 0, 3210)
  end if
  text = decode(received[0])
  ok = text == decode(payload) and received[2] == senderPort
  return t.UdpSmokeResult(ok, senderPort, receiverPort, sentResult, len(received[0]), text, received[1], received[2], 0)
end function
