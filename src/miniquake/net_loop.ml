package miniquake.net_loop

import miniquake.types as t
import miniquake.sizebuf as sz
import miniquake.byteio as bio

function createState()
  return t.LoopState(void, void, void)
end function

function createSocket()
  return t.LoopSocket(void, [], [], true, false)
end function

function connect(state, host)
  if host != "local" and host != "localhost" then return void end if
  client = createSocket()
  server = createSocket()
  client.peer = server
  server.peer = client
  state.client = client
  state.server = server
  state.pending = server
  return client
end function

function checkNewConnections(state)
  socket = state.pending
  state.pending = void
  return socket
end function

function arrayTail(values)
  result = []
  i = 1
  while i < len(values)
    result = result + [values[i]]
    i = i + 1
  end while
  return result
end function

function sendMessage(socket, buffer)
  if socket is void or socket.disconnected or socket.peer is void then return -1 end if
  if not socket.canSend then return 0 end if
  payload = slice(buffer.data, 0, buffer.curSize)
  socket.peer.messages = socket.peer.messages + [payload]
  socket.peer.messageTypes = socket.peer.messageTypes + [1]
  socket.canSend = false
  return 1
end function

function sendUnreliableMessage(socket, buffer)
  if socket is void or socket.disconnected or socket.peer is void then return -1 end if
  payload = slice(buffer.data, 0, buffer.curSize)
  socket.peer.messages = socket.peer.messages + [payload]
  socket.peer.messageTypes = socket.peer.messageTypes + [2]
  return 1
end function

function getMessage(socket, destination)
  if socket is void or socket.disconnected then return -1 end if
  if len(socket.messages) == 0 then return 0 end if
  payload = socket.messages[0]
  messageType = socket.messageTypes[0]
  socket.messages = arrayTail(socket.messages)
  socket.messageTypes = arrayTail(socket.messageTypes)
  sz.clear(destination)
  sz.write(destination, payload, 0, len(payload))
  if messageType == 1 and socket.peer is not void then socket.peer.canSend = true end if
  return messageType
end function

function canSendMessage(socket)
  if socket is void or socket.disconnected then return false end if
  return socket.canSend
end function

function close(socket)
  if socket is void then return end if
  socket.disconnected = true
  if socket.peer is not void then socket.peer.peer = void end if
  socket.peer = void
end function
