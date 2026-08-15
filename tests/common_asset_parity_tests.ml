/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-070 common.c/common.h, byte order, Quake strings and CRC fixtures.
*/
import miniquake.common as common
import miniquake.byteio as bio
import miniquake.protocol_text as quakeText
import miniquake.crc as crc
import miniquake.native as native

// Assert exact equality and report both values on failure.
function bp070Equal(actual, expected, name)
  if actual != expected then return error(10700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Exercise the true test scenario and verify its expected result.
function bp070True(value, name)
  if value != true then return error(10701, name + ": expected true") end if
  return true
end function
// Exercise the bits test scenario and verify its expected result.
function bp070Bits(value)
  return native.floatBits(value) & 0xffffffff
end function
// Exercise the case01 test scenario and verify its expected result.
function bp070Case01()
  bp070Equal(common.Q_atoi("123xyz"), 123, "Q_atoi stops"); return true
end function
// Exercise the case02 test scenario and verify its expected result.
function bp070Case02()
  bp070Equal(common.Q_atoi("-42"), -42, "Q_atoi negative"); return true
end function
// Exercise the case03 test scenario and verify its expected result.
function bp070Case03()
  bp070Equal(common.Q_atoi("0x7fffffff"), 2147483647, "Q_atoi hex"); return true
end function
// Exercise the case04 test scenario and verify its expected result.
function bp070Case04()
  bp070Equal(common.Q_atoi("'A"), 65, "Q_atoi character"); return true
end function
// Exercise the case05 test scenario and verify its expected result.
function bp070Case05()
  bp070Equal(common.Q_atoi("2147483648"), -2147483648, "Q_atoi signed wrap"); return true
end function
// Exercise the case06 test scenario and verify its expected result.
function bp070Case06()
  bp070Equal(common.Q_atoi("0xffffffff"), -1, "Q_atoi hex wrap")
  bp070Equal(common.Q_atoi("4294967295"), -1, "Q_atoi decimal wrap"); return true
end function
// Exercise the case07 test scenario and verify its expected result.
function bp070Case07()
  bp070Equal(bp070Bits(common.Q_atof("0.1")), 0x3dcccccd, "Q_atof binary32")
  bp070Equal(bp070Bits(common.cAtof("-0.000000")), 0x80000000, "C atof signed zero")
  return true
end function
// Exercise the case08 test scenario and verify its expected result.
function bp070Case08()
  bp070Equal(bp070Bits(common.Q_atof("16777217")), 0x4b800000, "Q_atof integer boundary")
  bp070Equal(bp070Bits(common.Q_atof("0x1000001")), 0x4b800000, "Q_atof hex boundary"); return true
end function
// Exercise the case09 test scenario and verify its expected result.
function bp070Case09()
  bp070Equal(bp070Bits(common.Q_atof("'é")), 0x43690000, "Q_atof Quake character"); return true
end function
// Exercise the case10 test scenario and verify its expected result.
function bp070Case10()
  bp070Equal(common.ShortSwap(0x1234), 0x3412, "ShortSwap")
  bp070Equal(common.ShortSwap(0x80ff), -128, "ShortSwap signed"); return true
end function
// Exercise the case11 test scenario and verify its expected result.
function bp070Case11()
  bp070Equal(common.LongSwap(0x12345678), 0x78563412, "LongSwap")
  bp070Equal(common.LongSwap(0x00000080), -2147483648, "LongSwap signed"); return true
end function
// Exercise the case12 test scenario and verify its expected result.
function bp070Case12()
  bp070Equal(common.ShortNoSwap(0xffff), -1, "ShortNoSwap narrowing")
  bp070Equal(common.LongNoSwap(0xffffffff), -1, "LongNoSwap narrowing"); return true
end function
// Exercise the case13 test scenario and verify its expected result.
function bp070Case13()
  bp070Equal(bp070Bits(common.FloatNoSwap(16777217.0)), 0x4b800000, "FloatNoSwap binary32"); return true
end function
// Exercise the case14 test scenario and verify its expected result.
function bp070Case14()
  bp070Equal(common.COM_FileExtension("maps/start.bsp"), "bsp", "file extension")
  bp070Equal(common.COM_FileExtension("x.123456789"), "1234567", "extension truncation"); return true
end function
// Exercise the case15 test scenario and verify its expected result.
function bp070Case15()
  bp070Equal(common.COM_FileBase("progs/player.mdl"), "player", "file base"); return true
end function
// Exercise the case16 test scenario and verify its expected result.
function bp070Case16()
  bp070Equal(common.COM_FileBase("x.mdl"), "?model?", "short file base"); return true
end function
// Exercise the case17 test scenario and verify its expected result.
function bp070Case17()
  bp070Equal(common.COM_DefaultExtension("save.sav", ".sav"), "save.sav", "existing extension"); return true
end function
// Exercise the case18 test scenario and verify its expected result.
function bp070Case18()
  bp070Equal(common.COM_DefaultExtension("save", ".sav"), "save.sav", "append extension")
  bp070Equal(common.COM_DefaultExtension(".quake", ".cfg"), ".quake.cfg", "leading dot original loop"); return true
end function
// Exercise the case19 test scenario and verify its expected result.
function bp070Case19()
  parsed = common.parseToken("  \"hello quake\" tail", 0)
  bp070Equal(parsed[0], "hello quake", "quoted token")
  bp070Equal(common.parseToken("  \"hello quake\" tail", parsed[1])[0], "tail", "quoted remainder"); return true
end function
// Exercise the case20 test scenario and verify its expected result.
function bp070Case20()
  parsed = common.parseToken("// ignored\n{abc:}", 0)
  bp070Equal(parsed[0], "{", "comment punctuation open")
  parsed = common.parseToken("// ignored\n{abc:}", parsed[1]); bp070Equal(parsed[0], "abc", "comment word")
  parsed = common.parseToken("// ignored\n{abc:}", parsed[1]); bp070Equal(parsed[0], ":", "comment punctuation colon"); return true
end function
// Exercise the case21 test scenario and verify its expected result.
function bp070Case21()
  source = ""; index = 0
  while index < 1100
    source = source + "a"; index = index + 1
  end while
  parsed = common.parseToken(source, 0)
  bp070Equal(len(bytes(parsed[0])), 1023, "COM_Parse token cap"); return true
end function
// Exercise the case22 test scenario and verify its expected result.
function bp070Case22()
  text = quakeText.decodeBytes(bytes([65, 0xe9]))
  fixed = bytes([65, 0xe9, 0, 90])
  bp070Equal(bio.fixedString(fixed, 0, 4), text, "fixedString Latin-1")
  bp070Equal(bio.cString(fixed, 0), text, "cString Latin-1"); return true
end function
// Exercise the case23 test scenario and verify its expected result.
function bp070Case23()
  source = bytes([1,2,3,4]); target = bytes(4)
  common.Q_memcpy(target, source, 4)
  bp070Equal(common.Q_memcmp(target, source, 4), 0, "Q_memcpy/Q_memcmp")
  common.Q_memset(target, 0xaa, 4)
  bp070Equal(common.memsearch(target, 4, 0xaa), 0, "memsearch"); return true
end function
// Exercise the case24 test scenario and verify its expected result.
function bp070Case24()
  bp070Equal(crc.CRC_Block(bytes("123456789"), 0, 9), 0x29b1, "CRC-16 check vector"); return true
end function
// Execute one named test case and record its pass/fail result.
function bp070Run(index, name, callback)
  print "[" + index + "/24] " + name
  result = try(callback())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
// Parse command-line arguments and run the selected operation.
function main(args)
  callbacks=[bp070Case01,bp070Case02,bp070Case03,bp070Case04,bp070Case05,bp070Case06,bp070Case07,bp070Case08,bp070Case09,bp070Case10,bp070Case11,bp070Case12,bp070Case13,bp070Case14,bp070Case15,bp070Case16,bp070Case17,bp070Case18,bp070Case19,bp070Case20,bp070Case21,bp070Case22,bp070Case23,bp070Case24]
  names=["Q_atoi decimal","Q_atoi negative","Q_atoi hexadecimal","Q_atoi character","Q_atoi signed wrap","Q_atoi 32-bit boundary","Q_atof binary32","Q_atof precision boundary","Q_atof character","ShortSwap","LongSwap","NoSwap narrowing","FloatNoSwap","file extension","file base","short file base","existing extension","default extension","quoted COM_Parse","comment/punctuation COM_Parse","COM_Parse token cap","Quake one-byte strings","Q_mem and memsearch","CRC-16"]
  index=0
  while index < len(callbacks)
    if not bp070Run(index + 1, names[index], callbacks[index]) then return 1 end if
    index = index + 1
  end while
  print "MiniQuake BP-070 common core tests passed: 24"
  return 0
end function
