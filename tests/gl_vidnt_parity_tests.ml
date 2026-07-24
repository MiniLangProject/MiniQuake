/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Deterministic gl_vidnt.c mode, gamma, palette, focus and command fixtures.
*/

import miniquake.gl_vidnt as video
import miniquake.common as common
import miniquake.keys as keys

function assertEqual(actual, expected, name)
  if actual != expected then return error(9700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9701, name + ": expected true") end if
  return true
end function

function modeFixture()
  arguments = common.create(["-width", "800", "-height", "600", "-bpp", "16"])
  state = video.createVideoState()
  video.VID_UseState(state)
  state.arguments = arguments
  video.VID_InitDIB(arguments)
  video.VID_InitFullDIB([
    [1024, 768, 32, 60, true],
    [640, 480, 32, 60, true],
    [800, 600, 16, 75, true],
    [5120, 1440, 32, 144, true],
    [640, 480, 32, 60, true],
    [320, 200, 8, 60, true],
  ], false, false)
  return state
end function

function testModeEnumeration()
  state = modeFixture()
  assertEqual(video.VID_NumModes(), 5, "window plus four unique fullscreen modes")
  assertEqual(video.VID_GetModePtr(1).description, "1024x768x32", "EnumDisplaySettings order is retained")
  assertEqual(video.VID_GetModePtr(2).description, "640x480x32", "second enumerated mode")
  assertEqual(video.VID_GetModePtr(3).description, "800x600x16", "third enumerated mode")
  assertEqual(video.VID_GetModePtr(4).width, 2560, "dual-screen aspect adjustment")
  assertEqual(video.VID_GetModePtr(4).halfscreen, 1, "dual-screen halfscreen flag")
  assertEqual(video.VID_GetModePtr(99).description, "Bad mode", "bad mode sentinel")
  assertEqual(video.VID_FindRequestedMode(state.arguments), 3, "width/height/bpp selection")
  assertEqual(video.VID_GetModePtr(1).frequency, 0, "refresh rate is not part of GLQuake vmode_t")
  windowArgs = common.create(["-startwindowed", "-width", "1024", "-height", "768"])
  assertEqual(video.VID_FindRequestedMode(windowArgs), video.MODE_WINDOWED, "startwindowed alias")

  currentState = modeFixture()
  currentState.desktopWidth = 1920
  currentState.desktopHeight = 1080
  assertEqual(video.VID_FindRequestedMode(common.create(["-current"])), 1, "current desktop mode")
  assertEqual(currentState.modes[1].width, 1920, "current desktop width")
  assertEqual(currentState.modes[1].height, 1080, "current desktop height")
  assertEqual(video.VID_GetModeDescription(2), "Desktop resolution (1920x1080)", "leave-current description applies globally")

  rejected = try(video.VID_SetMode(0, bytes(768), false))
  assertTrue(rejected is error, "fullscreen startup rejects windowed mode zero")
  return true
end function

function testDescriptionsAndMenu()
  state = modeFixture()
  state.currentMode = 3
  state.modeState = video.MS_FULLDIB
  assertEqual(video.VID_GetModeDescription(3), "800x600x16", "mode description")
  assertEqual(video.VID_GetExtModeDescription(3), "800x600x16 fullscreen", "extended fullscreen description")
  assertEqual(video.VID_DescribeCurrentMode_f(), "800x600x16 fullscreen", "current mode command")
  assertEqual(video.VID_NumModes_f(), "5 video modes are available", "mode count command")
  assertEqual(video.VID_DescribeMode_f(["vid_describemode", "2"]), "640x480x32 fullscreen", "describe mode command")
  assertEqual(len(video.VID_DescribeModes_f()), 4, "describe modes excludes windowed mode")
  trace = video.VID_MenuDraw()
  assertEqual(trace[0][0], "picture", "video menu picture")
  assertEqual(trace[4][3], true, "video menu current mode highlight")
  assertEqual(video.VID_MenuKey(keys.K_ESCAPE), "options", "video menu escape callback")
  return true
end function

function testWindowAndMessages()
  state = modeFixture()
  centered = video.CenterWindow(640, 480, 1024, 768, false)
  assertEqual(centered[0], 192, "window centered x")
  assertEqual(centered[1], 144, "window centered y")
  assertEqual(video.MapKey(1 << 16), keys.K_ESCAPE, "escape scan translation")
  assertEqual(video.MapKey(30 << 16), 97, "A scan translation")
  assertEqual(video.MapKey(71 << 16), keys.K_HOME, "numeric keypad scan translation")
  assertEqual(video.MapKey(128 << 16), 0, "out-of-range scan translation")
  moved = video.MainWndProc(0x0003, 0, 10 | (20 << 16))
  assertEqual(moved[0], "move", "WM_MOVE dispatch")
  assertEqual(state.windowX, 10, "WM_MOVE x")
  assertEqual(state.windowY, 20, "WM_MOVE y")
  sized = video.MainWndProc(0x0005, 0, 800 | (600 << 16))
  assertEqual(sized[0], "size", "WM_SIZE dispatch")
  assertEqual(state.windowWidth, 800, "WM_SIZE width")
  assertEqual(state.windowHeight, 600, "WM_SIZE height")
  state.modeState = video.MS_FULLDIB
  state.canAltTab = true
  video.AppActivate(false, true)
  assertEqual(state.wasSuspended, true, "fullscreen Alt-Tab suspend")
  video.AppActivate(true, false)
  assertEqual(state.wasSuspended, false, "fullscreen Alt-Tab restore")
  state.fullSbarDraw = true
  state.sbarChangedCount = 0
  video.GL_EndRendering()
  assertEqual(state.sbarChangedCount, 1, "PowerVR full statusbar invalidation")
  return true
end function

function testGamma()
  state = video.createVideoState()
  video.VID_UseState(state)
  state.arguments = common.create(["-gamma", "1"])
  palette = bytes(768)
  index = 0
  while index < len(palette)
    palette[index] = index & 255
    index = index + 1
  end while
  assertEqual(video.Check_Gamma(palette), 1.0, "command-line gamma")
  assertEqual(palette[0], 1, "gamma maps black using pal+1 rule")
  assertEqual(palette[127], 128, "gamma midpoint rounding")
  assertEqual(palette[255], 255, "gamma white clamp")
  ramp = video.VID_BuildGammaRamp(1.0)
  assertEqual(len(ramp), 1536, "three-channel gamma ramp size")
  assertEqual(ramp[0], 0, "gamma ramp black low")
  assertEqual(ramp[1], 0, "gamma ramp black high")
  assertEqual(ramp[256], 128, "gamma ramp midpoint low")
  assertEqual(ramp[257], 128, "gamma ramp midpoint high")
  assertEqual(ramp[510], 255, "gamma ramp white low")
  assertEqual(ramp[511], 255, "gamma ramp white high")
  return true
end function

function testPaletteTables()
  state = video.createVideoState()
  video.VID_UseState(state)
  palette = bytes(768)
  index = 0
  while index < 256
    palette[index * 3] = index
    palette[index * 3 + 1] = index
    palette[index * 3 + 2] = index
    index = index + 1
  end while
  video.VID_SetPalette(palette)
  assertEqual(len(state.table24), 256, "8-to-24 table size")
  assertEqual(state.table24[0], 255 << 24, "opaque black packing")
  assertEqual(state.table24[255], 0xffffff, "palette index 255 transparent")
  assertEqual(state.table15[0], 4, "15-bit nearest palette lookup")
  return true
end function

function testCompatibilityStubs()
  assertTrue(video.VID_HandlePause(true), "pause compatibility")
  assertTrue(video.VID_ForceLockState(3), "lock-state compatibility")
  assertTrue(video.VID_LockBuffer(), "lock compatibility")
  assertTrue(video.VID_UnlockBuffer(), "unlock compatibility")
  assertEqual(video.VID_ForceUnlockedAndReturnState(), 0, "unlock state")
  assertEqual(video.D_BeginDirectRect(0, 0, bytes(1), 1, 1), false, "direct rect begin no-op")
  assertEqual(video.D_EndDirectRect(0, 0, 1, 1), false, "direct rect end no-op")
  assertEqual(video.VID_ShiftPalette(bytes(768)), false, "GL palette shift no-op")
  state = video.createVideoState()
  video.VID_UseState(state)
  state.glExtensions = ""
  missingArrays = try(video.CheckArrayExtensions())
  assertTrue(missingArrays is error, "missing vertex-array extension follows Sys_Error path")
  return true
end function

function main(args)
  testModeEnumeration()
  testDescriptionsAndMenu()
  testWindowAndMessages()
  testGamma()
  testPaletteTables()
  testCompatibilityStubs()
  print "gl_vidnt parity tests: 6/6 passed"
  return 0
end function
