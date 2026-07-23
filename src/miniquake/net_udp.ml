package miniquake.net_udp

import miniquake.types as t
import miniquake.native as native
import miniquake.platform.win32 as win

const MAX_UDP_PAYLOAD = 65507

function open(port)
  if port < 0 or port > 65535 then return error(3200, "UDP_OpenSocket: invalid port " + port) end if
  handle = native.udpOpen(port)
  if handle == 0 then return error(3201, "UDP_OpenSocket: WSA error " + native.udpLastError()) end if
  actualPort = native.udpBoundPort(handle)
  if actualPort == 0 then
    errorCode = native.udpLastError()
    native.udpClose(handle)
    return error(3202, "UDP_OpenSocket: getsockname failed with WSA error " + errorCode)
  end if
  return t.UdpSocket(handle, actualPort, "0.0.0.0", true)
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
