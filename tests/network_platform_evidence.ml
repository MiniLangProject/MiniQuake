/* BP-064: independent-process UDP control handshake evidence. */
import miniquake.net_udp as udp
import miniquake.net_control as control
import miniquake.platform.win32 as win

function fail(message)
  print "MiniQuake BP-064 network platform evidence: FAIL"
  print "  " + message
  return 1
end function

function waitPacket(socketValue, wanted, timeoutMilliseconds)
  elapsed = 0
  while elapsed < timeoutMilliseconds
    packet = try(udp.receive(socketValue, 2048))
    if packet is error then return packet end if
    if packet is not void then
      parsed = try(control.parse(packet[0]))
      if parsed is not error and parsed[0] == wanted then return [parsed, packet[1], packet[2]] end if
    end if
    win.sleep(1)
    elapsed = elapsed + 1
  end while
  return error(3680, "network evidence receive timeout")
end function

function runServer(port)
  opened = try(udp.openBound(port, "127.0.0.1"))
  if opened is error then return fail(opened.message) end if
  socketValue = opened
  gotInfo = false
  gotConnect = false
  elapsed = 0
  while elapsed < 5000 and (not gotInfo or not gotConnect)
    packet = try(udp.receive(socketValue, 2048))
    if packet is error then udp.close(socketValue); return fail(packet.message) end if
    if packet is void then
      win.sleep(1)
    else
      parsed = try(control.parse(packet[0]))
      if parsed is not error then
        if parsed[0] == control.CCREQ_SERVER_INFO and control.validServerInfoRequest(parsed) then
          reply = control.replyServerInfo("127.0.0.1:" + port, "MiniQuake Evidence", "start", 1, 4)
          sent = try(udp.send(socketValue, packet[1], packet[2], reply))
          if sent is error then udp.close(socketValue); return fail(sent.message) end if
          gotInfo = true
        else if parsed[0] == control.CCREQ_CONNECT and control.validConnectRequest(parsed) then
          reply = control.replyAccept(port)
          sent = try(udp.send(socketValue, packet[1], packet[2], reply))
          if sent is error then udp.close(socketValue); return fail(sent.message) end if
          gotConnect = true
        end if
      end if
    end if
    elapsed = elapsed + 1
  end while
  udp.close(socketValue)
  if not gotInfo or not gotConnect then return fail("server did not receive both control requests") end if
  print "MiniQuake BP-064 network platform evidence server: PASS"
  return 0
end function

function runClient(port)
  opened = try(udp.open(0))
  if opened is error then return fail(opened.message) end if
  socketValue = opened
  sent = try(udp.send(socketValue, "127.0.0.1", port, control.requestServerInfo()))
  if sent is error then udp.close(socketValue); return fail(sent.message) end if
  info = try(waitPacket(socketValue, control.CCREP_SERVER_INFO, 3000))
  if info is error then udp.close(socketValue); return fail(info.message) end if
  fields = info[0][1]
  sent = try(udp.send(socketValue, "127.0.0.1", port, control.requestConnect()))
  if sent is error then udp.close(socketValue); return fail(sent.message) end if
  accepted = try(waitPacket(socketValue, control.CCREP_ACCEPT, 3000))
  if accepted is error then udp.close(socketValue); return fail(accepted.message) end if
  udp.close(socketValue)
  if fields[1] != "MiniQuake Evidence" or fields[2] != "start" or fields[3] != 1 or fields[4] != 4 or fields[5] != 3 then
    return fail("unexpected server-info payload")
  end if
  print "MiniQuake BP-064 network platform evidence"
  print "  schema=1"
  print "  host=MiniQuake Evidence"
  print "  map=start"
  print "  users=1/4"
  print "  protocol=3"
  print "  connect=accepted"
  print "MiniQuake BP-064 network platform evidence: PASS"
  return 0
end function

function main(args)
  if len(args) < 2 then print "usage: evidence server|client PORT"; return 2 end if
  port = toNumber(args[1])
  if port is void or port < 1 or port > 65535 then return fail("invalid port") end if
  if args[0] == "server" then return runServer(port) end if
  if args[0] == "client" then return runClient(port) end if
  return fail("unknown mode")
end function
