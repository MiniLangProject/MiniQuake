/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-068: menu.c toggle, options and save-entry lifecycle parity.
*/

import miniquake.menu as bp068Menu
import miniquake.cvar as bp068Cvar
import miniquake.keys as bp068Keys
import miniquake.native as bp068Native

bp068Index = 0
bp068Failures = 0
const BP068_FIXTURES = 24

function bp068Check(value, name)
  global bp068Index, bp068Failures
  bp068Index = bp068Index + 1
  print "[" + bp068Index + "/" + BP068_FIXTURES + "] " + name
  if not value then
    bp068Failures = bp068Failures + 1
    print "FAIL: " + name
    return false
  end if
  return true
end function

function bp068Registry()
  registry = bp068Cvar.createRegistry()
  registry.variables = [
    bp068Cvar.create("viewsize", "100", true, false),
    bp068Cvar.create("gamma", "1", true, false),
    bp068Cvar.create("sensitivity", "3", true, false),
    bp068Cvar.create("bgmvolume", "1", true, false),
    bp068Cvar.create("volume", "0.7", true, false),
    bp068Cvar.create("cl_forwardspeed", "200", true, false),
    bp068Cvar.create("cl_backspeed", "200", true, false),
    bp068Cvar.create("m_pitch", "0.022", true, false),
    bp068Cvar.create("lookspring", "0", true, false),
    bp068Cvar.create("lookstrafe", "0", true, false),
    bp068Cvar.create("_windowed_mouse", "1", true, false),
    bp068Cvar.create("_cl_name", "player", true, false),
    bp068Cvar.create("_cl_color", "0", true, false),
    bp068Cvar.create("hostname", "UNNAMED", true, false),
  ]
  return registry
end function

function main(args)
  state = bp068Menu.create()
  registry = bp068Registry()
  bp068Check(len(bp068Menu.optionsItems()) == 14, "Windows options item count")
  bp068Check(len(bp068Menu.saveSlotItems()) == 12, "save slot count")
  bp068Check(bp068Menu.HELP_PAGES == 6, "help page count")

  bp068Check(bp068Menu.M_ToggleMenu_f(state), "toggle opens menu")
  bp068Check(state.active and state.page == bp068Menu.PAGE_MAIN, "toggle opens main page")
  bp068Menu.M_Menu_Options_f(state)
  bp068Check(state.page == bp068Menu.PAGE_OPTIONS, "options page entered")
  bp068Check(bp068Menu.M_ToggleMenu_f(state), "submenu toggle remains open")
  bp068Check(state.active and state.page == bp068Menu.PAGE_MAIN, "submenu toggle returns main")
  bp068Check(not bp068Menu.M_ToggleMenu_f(state), "main toggle closes")
  bp068Check(not state.active, "toggle close state")

  bp068Check(not bp068Menu.M_Menu_Save_f(state, false, 0, 1), "save rejects inactive server")
  bp068Check(not bp068Menu.M_Menu_Save_f(state, true, 1, 1), "save rejects intermission")
  bp068Check(not bp068Menu.M_Menu_Save_f(state, true, 0, 2), "save rejects multiplayer")
  bp068Check(bp068Menu.M_Menu_Save_f(state, true, 0, 1), "save accepts local game")
  bp068Check(state.page == bp068Menu.PAGE_SAVE, "save page selected")

  bp068Menu.M_Menu_Options_f(state)
  state.selection = 6
  bp068Menu.M_AdjustSliders(state, registry, -1)
  bp068Check(bp068Cvar.variableValue(registry, "bgmvolume") == 0.0, "CD volume full-step down")
  bp068Menu.M_AdjustSliders(state, registry, 1)
  bp068Check(bp068Cvar.variableValue(registry, "bgmvolume") == 1.0, "CD volume full-step up")
  state.selection = 7
  bp068Menu.M_AdjustSliders(state, registry, 1)
  soundVolume = bp068Cvar.variableValue(registry, "volume")
  bp068Check(
    bp068Native.floatBits(soundVolume) == 0x3f4ccccd and
      bp068Cvar.variableString(registry, "volume") == "0.800000",
    "sound volume tenth-step",
  )
  state.selection = 8
  bp068Menu.M_AdjustSliders(state, registry, 1)
  bp068Check(bp068Cvar.variableValue(registry, "cl_forwardspeed") == 400.0, "always-run toggle on")
  bp068Menu.M_AdjustSliders(state, registry, 1)
  bp068Check(bp068Cvar.variableValue(registry, "cl_forwardspeed") == 200.0, "always-run toggle off")
  state.selection = 9
  bp068Menu.M_AdjustSliders(state, registry, 1)
  invertedPitch = bp068Cvar.variableValue(registry, "m_pitch")
  bp068Check(
    bp068Native.floatBits(invertedPitch) == 0xbcb43958 and
      bp068Cvar.variableString(registry, "m_pitch") == "-0.022000",
    "invert mouse",
  )
  state.selection = 13
  bp068Menu.M_AdjustSliders(state, registry, 1)
  bp068Check(bp068Cvar.variableValue(registry, "_windowed_mouse") == 0.0, "windowed mouse toggle")

  bp068Menu.M_Menu_Help_f(state)
  state.helpPage = 5
  bp068Menu.M_Help_Key(state, bp068Keys.K_RIGHTARROW)
  bp068Check(state.helpPage == 0, "help pages wrap")
  bp068Menu.M_Menu_Net_f(state)
  bp068Check(state.selection == 3, "excluded transports skip to TCP/IP")

  if bp068Failures > 0 then
    print "MiniQuake BP-068 menu lifecycle tests failed: " + bp068Failures + "/" + BP068_FIXTURES
    return 1
  end if
  print "MiniQuake BP-068 menu lifecycle tests passed: 24"
  return 0
end function
