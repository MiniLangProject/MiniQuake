/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-069: WinQuake keyboard/input/console/menu/video closure contract.
*/

import miniquake.frontend_contract as bp069Contract
import miniquake.gl_vidnt as bp069Video
import miniquake.keys as bp069Keys
import miniquake.input as bp069Input
import miniquake.common as bp069Common
import miniquake.cvar as bp069Cvar

bp069Index = 0
bp069Failures = 0

function bp069Check(value, name)
  global bp069Index, bp069Failures
  bp069Index = bp069Index + 1
  print "[" + bp069Index + "/24] " + name
  if not value then
    bp069Failures = bp069Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

function main(args)
  bp069Check(bp069Contract.STATUS == "frontend_109_frozen_v1", "contract status")
  bp069Check(bp069Contract.FINGERPRINT == 0x924251fa, "contract fingerprint")
  bp069Check(bp069Contract.verify(), "contract module values")
  bp069Check(len(bp069Contract.values()) == 13, "contract value count")
  bp069Check(bp069Contract.KEY_COUNT == 256, "key space")
  bp069Check(bp069Contract.CHAT_BYTES == 31, "chat byte limit")
  bp069Check(bp069Contract.CONSOLE_TEXT_BYTES == 16384, "console backing bytes")
  bp069Check(bp069Contract.MAX_VIDEO_MODES == 30, "video mode capacity")

  state = bp069Video.createVideoState()
  bp069Video.VID_UseState(state)
  arguments = bp069Common.create(["-width", "640", "-height", "480"])
  state.arguments = arguments
  bp069Video.VID_InitDIB(arguments)
  bp069Video.VID_InitFullDIB([[800, 600, 32, 60, true]], false, false)
  bp069Check(bp069Video.VID_NumModes() == 2, "window and fullscreen modes")
  bp069Check(bp069Video.VID_GetModePtr(0).type == bp069Video.MS_WINDOWED, "windowed mode zero")
  bp069Check(bp069Video.VID_GetModePtr(1).type == bp069Video.MS_FULLDIB, "fullscreen mode one")
  centered = bp069Video.CenterWindow(640, 480, 1024, 768, false)
  bp069Check(centered[0] == 192 and centered[1] == 144, "window centering")
  bp069Check(bp069Video.MapKey(30 << 16) == 97, "scan-code mapping")
  wheel = bp069Video.MainWndProc(0x020a, 120 << 16, 0)
  bp069Check(wheel[0] == "wheel" and wheel[1] == bp069Keys.K_MWHEELUP, "wheel dispatch")

  bp069Input.unbindAll()
  bp069Keys.Key_Init()
  bp069Keys.Key_TakePendingCommands()
  bp069Keys.Key_SetBinding(97, "+forward")
  bp069Video.ClearAllStates()
  bp069Check(bp069Keys.Key_TakePendingCommands() == "-forward 97\n", "video clear release")

  state.windowed = true
  state.registry = bp069Cvar.createRegistry()
  state.registry.variables = [bp069Cvar.create("_windowed_mouse", "0", true, false), bp069Cvar.create("vid_mode", "0", true, false)]
  bp069Keys.Key_SetBinding(97, "+forward")
  bp069Check(bp069Video.VID_SetMode(0, bytes(768), false), "windowed mode set")
  bp069Check(state.currentMode == 0 and state.modeState == bp069Video.MS_WINDOWED, "windowed state committed")
  bp069Check(bp069Keys.Key_TakePendingCommands() == "-forward 97\n", "mode switch releases bindings")
  bp069Check(state.recalcRefdef, "mode switch recalculates refdef")

  state.modeState = bp069Video.MS_FULLDIB
  state.canAltTab = true
  bp069Video.AppActivate(false, true)
  bp069Check(state.wasSuspended and state.minimized, "fullscreen focus loss")
  bp069Video.AppActivate(true, false)
  bp069Check(not state.wasSuspended and not state.minimized, "fullscreen focus restore")
  activation = bp069Video.MainWndProc(0x0006, 1, 0)
  bp069Check(activation[0] == "activate" and activation[1], "WM_ACTIVATE result")
  bp069Check(bp069Keys.Key_TakePendingCommands() == "-forward 97\n", "activation queues release")
  bp069Check(bp069Video.VID_GetModeDescription(99) == "", "invalid mode description")

  if bp069Failures > 0 then
    print "MiniQuake BP-069 frontend closure tests failed: " + bp069Failures + "/24"
    return 1
  end if
  print "MiniQuake BP-069 frontend closure tests passed: 24"
  return 0
end function
