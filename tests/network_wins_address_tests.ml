/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-062: net_wins.c byte order, PartialIPAddress and landriver state parity.
*/
import miniquake.net_wins as wins
import miniquake.types as t

testIndex = 0
failures = 0

// Assert that the condition holds and identify a failing test.
function bp062Check(value, name)
  global testIndex, failures
  testIndex = testIndex + 1
  print "[" + testIndex + "/24] " + name
  if not value then failures = failures + 1; print "FAIL: " + name; return false end if
  return true
end function

// Exercise address text as part of this deterministic regression fixture.
function addressText(input)
  target = t.WinSockAddress(0, 0, 0)
  status = wins.PartialIPAddress(input, target)
  if status != 0 then return [status, ""] end if
  return [status, wins.WINS_AddrToString(target)]
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  wins.WINS_ResetState()
  wins.WINS_SetLocalAddress("10.20.30.40")

  bp062Check(wins.htons(0x1234) == 0x3412 and wins.ntohs(0x3412) == 0x1234, "16-bit byte order")
  bp062Check(wins.htonl(0x01020304) == 0x04030201 and wins.ntohl(0x04030201) == 0x01020304, "32-bit byte order")
  bp062Check(addressText("55")[1] == "10.20.30.55:26000", "single-octet partial address")
  bp062Check(addressText(".55")[1] == "10.20.30.55:26000", "leading-dot partial address")
  bp062Check(addressText("1.2")[1] == "10.20.1.2:26000", "two-octet partial address")
  bp062Check(addressText("1.2.3.4")[1] == "1.2.3.4:26000", "full partial address")
  bp062Check(addressText("55:27000")[1] == "10.20.30.55:27000", "explicit decimal port")
  bp062Check(addressText("55:27000junk")[1] == "10.20.30.55:27000", "Q_atoi port suffix")
  bp062Check(addressText("55:1.5")[1] == "10.20.30.55:1", "Q_atoi decimal-prefix port")
  bp062Check(addressText("55:")[1] == "10.20.30.55:0", "empty port becomes zero")
  bp062Check(addressText("55:-1")[1] == "10.20.30.55:65535", "negative port wraps to short")
  bp062Check(addressText("55:65536")[1] == "10.20.30.55:0", "large port wraps to short")
  bp062Check(addressText("1234")[0] == -1, "reject four-digit octet")
  bp062Check(addressText("256")[0] == -1, "reject octet above 255")
  bp062Check(addressText("1.a")[0] == -1, "reject invalid address character")

  full = t.WinSockAddress(0, 0, 0)
  bp062Check(wins.WINS_StringToAddr("1.2.3.4:26000", full) == 0 and wins.WINS_AddrToString(full) == "1.2.3.4:26000", "full address roundtrip")
  bp062Check(wins.WINS_StringToAddr("1.2.3:26000", full) == -1, "strict full-address parser")
  bp062Check(wins.shortHostName("192.168.0.1") == "192.168.0.1", "numeric hostname remains intact")
  bp062Check(wins.shortHostName("very-long-hostname.example.org") == "very-long-hostn", "hostname truncation and domain strip")

  a = t.WinSockAddress(wins.AF_INET, wins.htonl(0x01020304), wins.htons(26000))
  b = t.WinSockAddress(wins.AF_INET, wins.htonl(0x01020304), wins.htons(26000))
  bp062Check(wins.WINS_AddrCompare(a, b) == 0, "address equality")
  b.port = wins.htons(26001)
  bp062Check(wins.WINS_AddrCompare(a, b) == 1, "same host different port")
  b.address = wins.htonl(0x01020305)
  bp062Check(wins.WINS_AddrCompare(a, b) == -1, "different host")
  b.family = 99
  bp062Check(wins.WINS_AddrCompare(a, b) == -1, "different family")

  wins.WINS_ResetState()
  bp062Check(wins.WINS_StateSnapshot()[0] == false and wins.WINS_StateSnapshot()[1] == 0 and wins.WINS_StateSnapshot()[2] == false, "landriver reset state")

  if failures > 0 then print "MiniQuake BP-062 WinSock address tests failed: " + failures + "/24"; return 1 end if
  print "MiniQuake BP-062 WinSock address tests passed: 24"
  return 0
end function
