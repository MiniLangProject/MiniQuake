/* BP-064: frozen network/platform closure contract. */
import miniquake.network_platform_contract as contract
import miniquake.net_main as netmain
import miniquake.net_loop as netloop
import miniquake.net_datagram as datagram
import miniquake.net_control as control
import miniquake.net_wins as wins
import miniquake.net_udp as udp
import miniquake.sys_win as system
import miniquake.conproc as conproc
import miniquake.types as t

testIndex = 0
failures = 0
function bp064Check(value, name)
  global testIndex, failures
  testIndex = testIndex + 1
  print "[" + testIndex + "/24] " + name
  if not value then failures = failures + 1; print "FAIL: " + name; return false end if
  return true
end function

function main(args)
  bp064Check(contract.verify(), "frozen contract verification")
  bp064Check(contract.STATUS == "network_platform_109_frozen_v1", "contract status")
  bp064Check(contract.FINGERPRINT == 0xb3ec7589, "contract fingerprint")
  bp064Check(contract.DEFAULT_HOST_PORT == netmain.DEFAULTnet_hostport, "default host port")
  bp064Check(contract.CONTROL_PROTOCOL_VERSION == control.NET_PROTOCOL_VERSION, "control protocol version")
  bp064Check(contract.MAX_RELIABLE_MESSAGE == datagram.NET_MAXMESSAGE, "reliable message limit")
  bp064Check(contract.MAX_DATAGRAM == datagram.MAX_DATAGRAM, "datagram fragment limit")
  bp064Check(contract.HOST_CACHE_SIZE == netloop.HOST_CACHE_SIZE, "host cache limit")
  bp064Check(contract.MESSAGE_TIMEOUT_SECONDS == 300, "message timeout")
  bp064Check(contract.MAX_FILE_HANDLES == system.MAX_HANDLES, "system handle limit")
  bp064Check(contract.MAX_HOST_NAME == wins.MAXHOSTNAMELEN, "WinSock hostname limit")
  bp064Check(contract.NET_NAME_LENGTH == wins.NET_NAMELEN, "network display-name limit")
  bp064Check(contract.QHOST_COMMANDS == 4, "QHOST command count")

  state = netloop.createState()
  netmain.NET_Init(state, 1, false, false, 26000, true)
  bp064Check(netmain.NET_SocketCounts()[2] == 2, "loop plus client qsocket pool")
  bp064Check(netloop.Loop_Init(false) == 0 and netloop.Datagram_Init(state, true) == -1, "driver initialization contract")
  parsedLocal = netloop.parseAddress("localhost", 26000)
  bp064Check(parsedLocal[0] == "127.0.0.1" and parsedLocal[1] == 26000, "localhost normalization")
  bp064Check(netloop.parseAddress("127.0.0.1:27000", 26000)[1] == 27000, "explicit UDP port")
  bp064Check(netloop.connectionRequestAction(void, 27000, 1.0) == "new", "new control connection")
  bp064Check(control.validQuakeRequest(control.parse(control.requestConnect())), "valid Quake control request")

  address = t.WinSockAddress(0, 0, 0)
  wins.WINS_SetLocalAddress("10.20.30.40")
  bp064Check(wins.PartialIPAddress("55", address) == 0 and wins.WINS_AddrToString(address) == "10.20.30.55:26000", "partial-IP contract")
  bp064Check(wins.WINS_AddrCompare(address, address) == 0, "address comparison contract")
  bp064Check(udp.MAX_UDP_PAYLOAD == 65507, "UDP payload ceiling")
  bp064Check(conproc.CCOM_WRITE_TEXT == 2 and conproc.CCOM_SET_SCR_LINES == 5, "QHOST opcode range")
  bp064Check(system.Sys_ParseCommandLine(" -dedicated +map start") == ["", "-dedicated", "+map", "start"], "WinMain command-line contract")

  netmain.NET_Shutdown(state)
  if failures > 0 then print "MiniQuake BP-064 network/platform closure tests failed: " + failures + "/24"; return 1 end if
  print "MiniQuake BP-064 network/platform closure tests passed: 24"
  return 0
end function
