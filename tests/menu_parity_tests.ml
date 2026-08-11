/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused menu.c state, transition, TCP/IP and mission-pack fixtures.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.common as common
import miniquake.host as host
import miniquake.menu as menu
import miniquake.cvar as cvar
import miniquake.keys as keys

function assertEqual(actual, expected, name)
  if actual != expected then return error(9500, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9501, name + ": expected true") end if
  return true
end function

function registry()
  return host.createCvars(common.create([]), true)
end function

function testTopLevelTransitions()
  state = menu.create()
  assertEqual(len(menu.M_Init(state)), 12, "M_Init command count")
  menu.M_Menu_Main_f(state)
  assertEqual(menu.M_Main_Key(state, keys.K_DOWNARROW), "move", "main down")
  assertEqual(state.selection, 1, "main cursor")
  assertEqual(menu.M_Main_Key(state, keys.K_ENTER), "menu_multi", "main multiplayer")
  menu.M_Menu_MultiPlayer_f(state)
  state.selection = 0
  assertEqual(menu.M_MultiPlayer_Key(state, keys.K_ENTER), "network", "join opens network")
  assertEqual(state.page, menu.PAGE_NET, "network page")
  assertEqual(state.selection, 3, "unavailable protocols skipped")
  assertEqual(menu.M_Net_Key(state, keys.K_ENTER), "lan_config", "TCP/IP opens LAN config")
  assertEqual(state.page, menu.PAGE_LAN, "LAN page")
  assertEqual(state.selection, 2, "join defaults to address")
  return true
end function

function testExcludedPaths()
  state = menu.create()
  excluded = menu.M_ExcludedPaths(state)
  assertEqual(len(excluded), 3, "excluded transport count")
  assertEqual(excluded[0], "serial", "serial excluded")
  assertEqual(menu.M_Menu_SerialConfig_f(state), false, "serial path rejected")
  assertEqual(state.action[0], "excluded", "serial rejection classified")
  assertEqual(menu.M_Menu_ModemConfig_f(state), false, "modem path rejected")
  return true
end function

function testSetupEditing()
  variables = registry()
  cvar.set(variables, "hostname", "RangerHost")
  cvar.set(variables, "_cl_name", "Ranger")
  cvar.setValue(variables, "_cl_color", 0x4d)
  state = menu.create()
  menu.M_Menu_Setup_f(state, variables)
  assertEqual(state.setupHostname, "RangerHost", "setup hostname copy")
  assertEqual(state.setupName, "Ranger", "setup name copy")
  assertEqual(state.setupTop, 4, "setup shirt")
  assertEqual(state.setupBottom, 13, "setup pants")
  state.selection = 1
  menu.M_Setup_Key(state, keys.K_BACKSPACE)
  menu.M_Setup_Key(state, 88)
  assertEqual(state.setupName, "RangeX", "setup name editing")
  state.selection = 2
  menu.M_Setup_Key(state, keys.K_RIGHTARROW)
  assertEqual(state.setupTop, 5, "setup shirt adjustment")
  state.selection = 4
  accepted = menu.M_Setup_Key(state, keys.K_ENTER)
  assertEqual(accepted[0], "setup_accept", "setup acceptance action")
  assertEqual(len(menu.M_BuildTranslationTable(5 * 16, 13 * 16)), 256, "player translation size")
  return true
end function

function testLanAndServerList()
  state = menu.create()
  state.joiningGame = true
  menu.M_Menu_LanConfig_f(state)
  state.lanJoinName = "127.0.0.1:26000"
  action = menu.M_LanConfig_Key(state, keys.K_ENTER)
  assertEqual(action[0], "connect", "direct connect action")
  assertEqual(action[1], "127.0.0.1:26000", "direct connect address")
  servers = [
    ["10.0.0.2:26000", "Zulu", "e1m2", 2, 8],
    ["10.0.0.1:26000", "Alpha", "start", 1, 4],
  ]
  menu.M_Menu_ServerList_f(state, servers)
  menu.sortServers(state)
  assertEqual(state.servers[0][1], "Alpha", "hostcache alphabetical sort")
  menu.M_ServerList_Key(state, keys.K_DOWNARROW)
  assertEqual(state.selection, 1, "server list cursor")
  selected = menu.M_ServerList_Key(state, keys.K_ENTER)
  assertEqual(selected[0], "connect", "server list connect")
  assertEqual(selected[1], "10.0.0.2:26000", "server list canonical address")
  return true
end function

function testGameOptions()
  variables = registry()
  state = menu.create()
  menu.M_Menu_GameOptions_f(state, 16, "id1")
  assertEqual(menu.selectedLevel(state)[0], "start", "id1 start map")
  state.selection = 7
  menu.M_NetStart_Change(state, variables, 1)
  assertEqual(menu.selectedLevel(state)[0], "e1m1", "id1 episode one")
  menu.M_Menu_GameOptions_f(state, 16, "hipnotic")
  state.startEpisode = 0
  state.startLevel = 0
  assertEqual(menu.selectedLevel(state)[0], "start", "hipnotic start map")
  state.startEpisode = 4
  assertEqual(menu.selectedLevel(state)[0], "hipend", "hipnotic final map")
  menu.M_Menu_GameOptions_f(state, 16, "rogue")
  state.startEpisode = 3
  state.startLevel = 0
  assertEqual(menu.selectedLevel(state)[0], "ctf1", "rogue deathmatch map")
  state.selection = 3
  menu.M_NetStart_Change(state, variables, -1)
  assertEqual(cvar.variableValue(variables, "teamplay"), 6.0, "rogue teamplay wrap")
  return true
end function

function testDrawAndKeyDispatch()
  variables = registry()
  state = menu.create()
  scaled = menu.layout(640, 480)
  assertEqual(scaled[0], 0.0, "scaled menu horizontal center")
  assertEqual(scaled[1], 40.0, "scaled menu vertical center")
  assertEqual(scaled[2], 2.0, "scaled menu fills 640x480 proportionally")
  menu.M_Menu_Main_f(state)
  menu.M_Main_Draw(state, 0, [0.0, 0.0, 1.0], 0.0)
  assertEqual(state.drawTrace[0][0], "M_Main_Draw", "main draw trace")
  menu.M_Menu_Help_f(state)
  assertEqual(menu.M_Keydown(state, keys.K_RIGHTARROW, variables), "page", "help key dispatcher")
  assertEqual(state.helpPage, 1, "help page advance")
  menu.M_Menu_Video_f(state)
  assertEqual(menu.M_Keydown(state, keys.K_ESCAPE, variables), "back", "video callback fallback")
  assertEqual(state.page, menu.PAGE_OPTIONS, "video escape options")
  return true
end function

function main(args)
  testTopLevelTransitions()
  testExcludedPaths()
  testSetupEditing()
  testLanAndServerList()
  testGameOptions()
  testDrawAndKeyDispatch()
  print "Menu parity tests: 6/6 passed"
  return 0
end function
