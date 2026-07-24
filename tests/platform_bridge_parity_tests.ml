/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Deterministic platform-bridge branches which do not require real display,
focus, mouse or controller hardware.
*/

import miniquake.input as input
import miniquake.keys as keys
import miniquake.platform.win32 as win

function assertEqual(actual, expected, name)
  if actual != expected then return error(9750, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function testScanCodeMap()
  assertEqual(input.quakeKeyForScanCode(1), keys.K_ESCAPE, "escape")
  assertEqual(input.quakeKeyForScanCode(28), keys.K_ENTER, "enter")
  assertEqual(input.quakeKeyForScanCode(29), keys.K_CTRL, "control")
  assertEqual(input.quakeKeyForScanCode(42), keys.K_SHIFT, "left shift")
  assertEqual(input.quakeKeyForScanCode(54), keys.K_SHIFT, "right shift")
  assertEqual(input.quakeKeyForScanCode(56), keys.K_ALT, "alt")
  assertEqual(input.quakeKeyForScanCode(59), keys.K_F1, "F1")
  assertEqual(input.quakeKeyForScanCode(88), keys.K_F12, "F12")
  assertEqual(input.quakeKeyForScanCode(71), keys.K_HOME, "keypad home")
  assertEqual(input.quakeKeyForScanCode(83), keys.K_DEL, "keypad delete")
  assertEqual(input.quakeKeyForScanCode(127), 0, "unmapped high scan")
  assertEqual(input.quakeKeyForScanCode(128), 0, "invalid scan")
  return true
end function

function testOrderedScanEvents()
  keys.Key_Init()
  win.inputTestPush(5, 30, 1)
  win.inputTestPush(5, 30, 0)
  win.inputTestPush(5, 71, 1)
  events = keys.PollEvents()
  assertEqual(len(events), 3, "event count")
  assertEqual(events[0][0], 97, "A down key")
  assertEqual(events[0][1], true, "A down edge")
  assertEqual(events[1][0], 97, "A up key")
  assertEqual(events[1][1], false, "A up edge")
  assertEqual(events[2][0], keys.K_HOME, "keypad scan survives FIFO")
  return true
end function

function testLegacyVirtualKeyCompatibility()
  keys.Key_Init()
  win.inputTestPush(1, 65, 1)
  win.inputTestPush(1, 65, 0)
  events = keys.PollEvents()
  assertEqual(len(events), 2, "legacy event count")
  assertEqual(events[0][0], 97, "legacy virtual key down")
  assertEqual(events[1][1], false, "legacy virtual key up")
  return true
end function

function main(args)
  testScanCodeMap()
  testOrderedScanEvents()
  testLegacyVirtualKeyCompatibility()
  print "platform bridge parity tests: 3/3 passed"
  return 0
end function
