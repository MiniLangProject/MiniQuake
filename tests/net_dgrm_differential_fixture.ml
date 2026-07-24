import miniquake.net_datagram as datagram
import miniquake.net_control as control
import miniquake.net_loop as netloop
import miniquake.sizebuf as sz

function boolInt(value)
  if value then return 1 end if
  return 0
end function

function emit(functionName, caseName, result, index, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"index\":" + index +
    ",\"value\":" + value + ",\"count\":" + count + "}"
end function

function fatalMode(mode)
  channel = datagram.createChannel()
  result = void
  if mode == "--error-send-empty" then
    result = try(datagram.Datagram_SendMessage(channel, bytes(), 0.0))
  else if mode == "--error-send-large" then
    result = try(datagram.Datagram_SendMessage(channel, bytes(datagram.NET_MAXMESSAGE + 1), 0.0))
  else if mode == "--error-send-busy" then
    channel.canSend = false
    result = try(datagram.Datagram_SendMessage(channel, bytes([1]), 0.0))
  else if mode == "--error-unreliable-empty" then
    result = try(datagram.Datagram_SendUnreliableMessage(channel, bytes()))
  else
    result = try(datagram.Datagram_SendUnreliableMessage(channel, bytes(datagram.MAX_DATAGRAM + 1)))
  end if
  if result is error then return 42 end if
  return 0
end function

function main(args)
  if len(args) > 0 then return fatalMode(args[0]) end if

  banState = netloop.createState()
  banResult = netloop.NET_Ban_f(banState, ["ban", "192.168.1.0"])
  emit("NET_Ban_f", "address",
    boolInt(banState.banAddress != 0), boolInt(banState.banMask == 0xffffffff),
    0, boolInt(banResult != ""))

  datagram.resetStats()
  channel = datagram.createChannel()
  payload = bytes(1500)
  packet = datagram.Datagram_SendMessage(channel, payload, 10.0)
  decoded = datagram.decodePacket(packet)
  emit("Datagram_SendMessage", "fragment", 1, len(packet),
    boolInt(decoded.flags == datagram.NETFLAG_DATA), len(channel.sendMessage))

  channel.sendMessage = slice(payload, datagram.MAX_DATAGRAM, 1500 - datagram.MAX_DATAGRAM)
  channel.sendNext = true
  packet = datagram.SendMessageNext(channel, 10.1)
  decoded = datagram.decodePacket(packet)
  emit("SendMessageNext", "final_fragment", 1, len(packet),
    boolInt(decoded.flags == (datagram.NETFLAG_DATA | datagram.NETFLAG_EOM)),
    boolInt(channel.sendNext))

  packet = datagram.ReSendMessage(channel, 10.2)
  decoded = datagram.decodePacket(packet)
  emit("ReSendMessage", "same_sequence", 1,
    boolInt(decoded.sequence == datagram.previousSequence(channel.sendSequence)),
    datagram.packetsReSent,
    boolInt(decoded.flags == (datagram.NETFLAG_DATA | datagram.NETFLAG_EOM)))

  channel.sendNext = true
  channel.canSend = false
  sentBefore = datagram.packetsSent
  ready = datagram.Datagram_CanSendMessage(channel)
  emit("Datagram_CanSendMessage", "flush_next", boolInt(ready),
    datagram.packetsSent - sentBefore, boolInt(channel.sendNext), 1)
  emit("Datagram_CanSendUnreliableMessage", "always",
    boolInt(datagram.Datagram_CanSendUnreliableMessage(channel)), 0, 0, 1)

  packet = datagram.Datagram_SendUnreliableMessage(channel, bytes([7, 7, 7]))
  decoded = datagram.decodePacket(packet)
  emit("Datagram_SendUnreliableMessage", "wire", 1, len(packet),
    boolInt(decoded.flags == datagram.NETFLAG_UNRELIABLE),
    channel.unreliableSendSequence)

  datagram.resetStats()
  receive = datagram.createChannel()
  first = datagram.encode(datagram.NETFLAG_DATA, 0, bytes([97, 98]))
  second = datagram.encode(
    datagram.NETFLAG_DATA | datagram.NETFLAG_EOM,
    1,
    bytes([99, 100]),
  )
  firstResult = datagram.Datagram_GetMessage(receive, first, 10.0)
  secondResult = datagram.Datagram_GetMessage(receive, second, 10.1)
  complete = secondResult[1]
  emit("Datagram_GetMessage", "reliable_fragments", secondResult[0],
    len(complete), complete[0] * 1000 + complete[3],
    boolInt(firstResult[2] is bytes) + boolInt(secondResult[2] is bytes))

  datagram.resetStats()
  ackChannel = datagram.createChannel()
  ackChannel.canSend = false
  ackChannel.sendSequence = 1
  ackChannel.ackSequence = 0
  ackChannel.sendMessage = bytes(1200)
  ackResult = datagram.Datagram_GetMessage(
    ackChannel,
    datagram.acknowledgement(0),
    10.0,
  )
  emit("Datagram_GetMessage", "ack_next", ackResult[0],
    len(ackChannel.sendMessage), boolInt(ackChannel.sendNext),
    boolInt(ackChannel.canSend))

  datagram.resetStats()
  unreliableChannel = datagram.createChannel()
  unreliableResult = datagram.Datagram_GetMessage(
    unreliableChannel,
    datagram.encode(datagram.NETFLAG_UNRELIABLE, 3, bytes([97, 98])),
    10.0,
  )
  emit("Datagram_GetMessage", "unreliable_gap", unreliableResult[0],
    unreliableChannel.unreliableReceiveSequence, datagram.droppedDatagrams,
    len(unreliableResult[1]))

  datagram.resetStats()
  resendChannel = datagram.createChannel()
  resendChannel.canSend = false
  resendChannel.sendSequence = 1
  resendChannel.sendMessage = bytes([97, 98])
  resendChannel.lastSendTime = 0.0
  resend = datagram.pollRetransmit(resendChannel, 10.0)
  emit("Datagram_GetMessage", "timeout_resend", 0,
    boolInt(resend is bytes), datagram.packetsReSent, 1)

  statsChannel = datagram.createChannel()
  statsChannel.sendSequence = 4
  statsChannel.receiveSequence = 7
  stats = datagram.PrintStats(statsChannel)
  emit("PrintStats", "socket", boolInt(stats != ""), statsChannel.sendSequence,
    statsChannel.receiveSequence, 4)

  datagram.resetStats()
  stats = datagram.NET_Stats_f(void, 0, 0, 0, 0)
  emit("NET_Stats_f", "global", boolInt(stats != ""), datagram.packetsSent,
    datagram.packetsReceived, 10)

  driverState = netloop.createState()
  initialized = netloop.Datagram_Init(driverState, false)
  emit("Datagram_Init", "drivers", initialized, 4, 21,
    3 * boolInt(driverState.lanEnabled))
  shutdown = netloop.Datagram_Shutdown(driverState)
  emit("Datagram_Shutdown", "drivers", boolInt(shutdown), 2, 0, 1)

  closeSocket = netloop.createSocket()
  closeSocket.port = 77
  closed = netloop.Datagram_Close(closeSocket)
  emit("Datagram_Close", "landriver", boolInt(closed), closeSocket.port, 0, 1)

  listenState = netloop.createState()
  netloop.Datagram_Init(listenState, true)
  listenOn = try(netloop.Datagram_Listen(listenState, true, 26000))
  listenOff = try(netloop.Datagram_Listen(listenState, false, 26000))
  emit("Datagram_Listen", "all", 2,
    boolInt(listenOn is error and listenOff is void), 0, 2)

  checkState = netloop.createState()
  pendingRemote = netloop.createSocket()
  checkState.pendingRemote = pendingRemote
  checkedRemote = netloop._Datagram_CheckNewConnections(checkState)
  infoRequest = control.parse(control.requestServerInfo())
  infoReply = control.parse(control.replyServerInfo(
    "10.0.0.1:26000", "oracle", "start", 0, 2,
  ))
  emit("_Datagram_CheckNewConnections", "server_info",
    boolInt(checkedRemote == pendingRemote),
    boolInt(infoReply[0] == control.CCREP_SERVER_INFO),
    boolInt(control.validServerInfoRequest(infoRequest)), 0)

  checkState = netloop.createState()
  pendingLocal = netloop.createSocket()
  checkState.pending = pendingLocal
  checkedLocal = netloop.Datagram_CheckNewConnections(checkState)
  connectRequest = control.parse(control.requestConnect())
  acceptReply = control.parse(control.replyAccept(27500))
  emit("Datagram_CheckNewConnections", "accept_second",
    boolInt(checkedLocal == pendingLocal), 1,
    boolInt(control.validConnectRequest(connectRequest)),
    boolInt(acceptReply[0] == control.CCREP_ACCEPT))

  searched = netloop._Datagram_SearchForHosts(void, [], 26000, 0, false)
  serverReply = control.parse(control.replyServerInfo(
    "10.0.0.2:26000", "Alpha", "start", 1, 4,
  ))
  emit("_Datagram_SearchForHosts", "broadcast_reply",
    boolInt(searched is not error and serverReply[0] == control.CCREP_SERVER_INFO),
    1, serverReply[1][3], boolInt(serverReply[1][1] == "Alpha"))

  searchState = netloop.createState()
  netloop.Datagram_Init(searchState, true)
  searchResult = try(netloop.Datagram_SearchForHosts(searchState, true, 26000, 0))
  emit("Datagram_SearchForHosts", "all_drivers",
    2 * boolInt(searchResult is error), 2, 2, 2)

  connectState = netloop.createState()
  netloop.Datagram_Init(connectState, true)
  directResult = try(netloop._Datagram_Connect(connectState, "bad:70000", 1))
  accepted = control.parse(control.replyAccept(27500))
  emit("_Datagram_Connect", "accept",
    boolInt(directResult is error and accepted[0] == control.CCREP_ACCEPT),
    2, accepted[1][0], 0)

  connectState.hostCache = [["bad:70000", "Friendly", "start", 0, 4, 15]]
  publicResult = try(netloop.Datagram_Connect(connectState, "friendly", 1))
  emit("Datagram_Connect", "second_driver",
    boolInt(publicResult is error), 1, 2, 0)

  testResult = try(netloop.Test_f("bad:70000", 2, 0))
  playerRequest0 = control.parse(control.requestPlayerInfo(0))
  playerRequest1 = control.parse(control.requestPlayerInfo(1))
  emit("Test_f", "cached_host",
    boolInt(testResult is error),
    boolInt(playerRequest0[1][0] == 0) + boolInt(playerRequest1[1][0] == 1),
    1, 20)

  pollResult = netloop.Test_Poll(void, "bad", 0, 0)
  playerReply = control.parse(control.replyPlayerInfo(
    0, "Ranger", 0x4f, 0, 0, "local",
  ))
  emit("Test_Poll", "player_reply", boolInt(len(pollResult) == 0), 19, 2,
    boolInt(playerReply[0] == control.CCREP_PLAYER_INFO))

  test2Result = try(netloop.Test2_f("bad:70000", 0))
  ruleRequest = control.parse(control.requestRuleInfo(""))
  emit("Test2_f", "start", boolInt(test2Result is error),
    boolInt(ruleRequest[0] == control.CCREQ_RULE_INFO), 1, 1)

  test2Poll = try(netloop.Test2_Poll(void, "bad", 0, 0))
  ruleReply = control.parse(control.replyRuleInfo("sv_gravity", "800"))
  emit("Test2_Poll", "next_rule", boolInt(test2Poll is error),
    2, 2, boolInt(ruleReply[0] == control.CCREP_RULE_INFO))
  return 0
end function
