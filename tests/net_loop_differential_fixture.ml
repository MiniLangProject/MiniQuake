/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/net_loop_differential_fixture.ml.
*/
import miniquake.sizebuf as sz
import miniquake.net_loop as loopPort

// Return bool value derived from the active module state.
function boolValue(value)
  if value then return 1 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "{\"function\":\"Loop_Init\",\"case\":\"modes\",\"values\":[" +
    loopPort.Loop_Init(false) + "," + loopPort.Loop_Init(true) + "]}"
  print "{\"function\":\"Loop_Shutdown\",\"case\":\"noop\",\"called\":" +
    boolValue(loopPort.Loop_Shutdown()) + "}"

  state = loopPort.createState()
  listened = loopPort.Loop_Listen(state)
  print "{\"function\":\"Loop_Listen\",\"case\":\"noop\",\"same\":" +
    boolValue(listened == state) + "}"

  state.hostName = "UNNAMED"
  state.mapName = "e1m1"
  state.currentPlayers = 2
  state.maxPlayers = 4
  hosts = loopPort.Loop_SearchForHosts(state, true, 7)
  host = hosts[0]
  print "{\"function\":\"Loop_SearchForHosts\",\"case\":\"active\",\"count\":" +
    len(hosts) + ",\"name\":\"" + host[1] + "\",\"map\":\"" + host[2] +
    "\",\"users\":" + host[3] + ",\"maxusers\":" + host[4] +
    ",\"driver\":" + host[6] + ",\"cname\":\"" + host[0] + "\"}"

  wrong = loopPort.Loop_Connect(state, "localhost")
  client = loopPort.Loop_Connect(state, "local")
  print "{\"function\":\"Loop_Connect\",\"case\":\"local\",\"wrong\":" +
    boolValue(wrong is void) + ",\"client\":" + boolValue(client is not void) +
    ",\"canSend\":" + boolValue(client.canSend) + "}"

  server = loopPort.Loop_CheckNewConnections(state)
  print "{\"function\":\"Loop_CheckNewConnections\",\"case\":\"pending\",\"server\":" +
    boolValue(server is not void) + ",\"canSend\":" + boolValue(server.canSend) + "}"
  print "{\"function\":\"IntAlign\",\"case\":\"boundaries\",\"values\":[" +
    loopPort.IntAlign(1) + "," + loopPort.IntAlign(5) + "," +
    loopPort.IntAlign(8) + "]}"

  data = sz.alloc(16)
  sz.writeBytes(data, bytes([1, 2, 3]))
  sent = loopPort.Loop_SendMessage(client, data)
  print "{\"function\":\"Loop_SendMessage\",\"case\":\"reliable\",\"result\":" +
    sent + ",\"canSend\":" + boolValue(client.canSend) +
    ",\"queued\":" + len(server.messages) + "}"

  destination = sz.alloc(16)
  received = loopPort.Loop_GetMessage(server, destination)
  print "{\"function\":\"Loop_GetMessage\",\"case\":\"reliable\",\"result\":" +
    received + ",\"size\":" + destination.curSize + ",\"values\":[" +
    destination.data[0] + "," + destination.data[1] + "," +
    destination.data[2] + "],\"peerCanSend\":" + boolValue(client.canSend) + "}"

  unreliable = loopPort.Loop_SendUnreliableMessage(client, data)
  print "{\"function\":\"Loop_SendUnreliableMessage\",\"case\":\"unreliable\",\"result\":" +
    unreliable + ",\"queued\":" + len(server.messages) + "}"
  receivedUnreliable = loopPort.Loop_GetMessage(server, destination)
  print "{\"function\":\"Loop_GetMessage\",\"case\":\"unreliable\",\"result\":" +
    receivedUnreliable + ",\"size\":" + destination.curSize + ",\"values\":[" +
    destination.data[0] + "," + destination.data[1] + "," +
    destination.data[2] + "]}"

  print "{\"function\":\"Loop_CanSendMessage\",\"case\":\"ready\",\"value\":" +
    boolValue(loopPort.Loop_CanSendMessage(client)) + "}"
  print "{\"function\":\"Loop_CanSendUnreliableMessage\",\"case\":\"always\",\"value\":" +
    boolValue(loopPort.Loop_CanSendUnreliableMessage(client)) + "}"
  loopPort.Loop_Close(client)
  print "{\"function\":\"Loop_Close\",\"case\":\"client\",\"closed\":1,\"peerCleared\":" +
    boolValue(server.peer is void) + ",\"canSend\":" + boolValue(client.canSend) + "}"
  return 0
end function
