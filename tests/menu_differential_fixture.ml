/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/menu_differential_fixture.ml.
*/
import miniquake.menu as menu
import miniquake.keys as keys
import miniquake.common as common
import miniquake.host as host
import miniquake.net_loop as netloop

// Add the requested value to the destination state.
function emit(name)
  print "{\"function\":\"" + name + "\",\"scene\":\"execute\",\"executed\":1}"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  state = menu.create()
  registry = host.createCvars(common.create([]), true)
  transform = [160.0, 0.0, 1.0]
  network = netloop.createState()

  menu.M_DrawCharacter(0, 1, 2, 3, transform); emit("M_DrawCharacter")
  menu.M_Print(0, 1, 2, "ab", transform); emit("M_Print")
  menu.M_PrintWhite(0, 1, 2, "ab", transform); emit("M_PrintWhite")
  menu.M_DrawTransPic(state, "probe", 1, 2, transform); emit("M_DrawTransPic")
  menu.M_DrawPic(state, "probe", 1, 2, transform); emit("M_DrawPic")
  menu.M_BuildTranslationTable(16, 144); emit("M_BuildTranslationTable")
  menu.M_DrawTransPicTranslate(state, "probe", 1, 2, transform, 16, 144); emit("M_DrawTransPicTranslate")
  menu.M_DrawTextBox(state, 8, 8, 4, 2, transform); emit("M_DrawTextBox")
  menu.M_ToggleMenu_f(state); emit("M_ToggleMenu_f")
  menu.M_Menu_Main_f(state); emit("M_Menu_Main_f")
  menu.M_Main_Draw(state, 0, transform, 0.0); emit("M_Main_Draw")
  menu.M_Main_Key(state, keys.K_DOWNARROW); emit("M_Main_Key")
  menu.M_Menu_SinglePlayer_f(state); emit("M_Menu_SinglePlayer_f")
  menu.M_SinglePlayer_Draw(state, 0, transform, 0.0); emit("M_SinglePlayer_Draw")
  menu.M_SinglePlayer_Key(state, keys.K_DOWNARROW); emit("M_SinglePlayer_Key")
  menu.M_ScanSaves(state, ["--- UNUSED SLOT ---"], [false]); emit("M_ScanSaves")
  menu.M_Menu_Load_f(state); emit("M_Menu_Load_f")
  menu.M_Menu_Save_f(state, true, 0, 1); emit("M_Menu_Save_f")
  menu.M_Load_Draw(state, 0, transform, 0.0); emit("M_Load_Draw")
  menu.M_Save_Draw(state, 0, transform, 0.0); emit("M_Save_Draw")
  menu.M_Load_Key(state, keys.K_DOWNARROW); emit("M_Load_Key")
  menu.M_Save_Key(state, keys.K_DOWNARROW); emit("M_Save_Key")
  menu.M_Menu_MultiPlayer_f(state); emit("M_Menu_MultiPlayer_f")
  menu.M_MultiPlayer_Draw(state, 0, transform, 0.0); emit("M_MultiPlayer_Draw")
  menu.M_MultiPlayer_Key(state, keys.K_DOWNARROW); emit("M_MultiPlayer_Key")
  menu.M_Menu_Setup_f(state, registry); emit("M_Menu_Setup_f")
  menu.M_Setup_Draw(state, 0, transform, 0.0, registry); emit("M_Setup_Draw")
  menu.M_Setup_Key(state, keys.K_DOWNARROW); emit("M_Setup_Key")
  menu.M_Menu_Net_f(state); emit("M_Menu_Net_f")
  menu.M_Net_Draw(state, 0, transform, 0.0); emit("M_Net_Draw")
  menu.M_Net_Key(state, keys.K_DOWNARROW); emit("M_Net_Key")
  menu.M_Menu_Options_f(state); emit("M_Menu_Options_f")
  state.selection = 3
  menu.M_AdjustSliders(state, registry, 1); emit("M_AdjustSliders")
  menu.M_DrawSlider(0, 8, 8, 0.5, transform); emit("M_DrawSlider")
  menu.M_DrawCheckbox(0, 8, 8, true, transform); emit("M_DrawCheckbox")
  menu.M_Options_Draw(state, 0, transform, 0.0, registry); emit("M_Options_Draw")
  menu.M_Options_Key(state, keys.K_DOWNARROW, registry); emit("M_Options_Key")
  menu.M_Menu_Keys_f(state); emit("M_Menu_Keys_f")
  menu.M_FindKeysForCommand("+attack"); emit("M_FindKeysForCommand")
  menu.M_UnbindCommand("+attack"); emit("M_UnbindCommand")
  menu.M_Keys_Draw(state, 0, transform, 0.0); emit("M_Keys_Draw")
  menu.M_Keys_Key(state, keys.K_DOWNARROW); emit("M_Keys_Key")
  menu.M_Menu_Video_f(state); emit("M_Menu_Video_f")
  menu.M_Video_Draw(state, 0, transform, 0.0); emit("M_Video_Draw")
  menu.M_Video_Key(state, keys.K_DOWNARROW); emit("M_Video_Key")
  menu.M_Menu_Help_f(state); emit("M_Menu_Help_f")
  menu.M_Help_Draw(state, 0, transform); emit("M_Help_Draw")
  menu.M_Help_Key(state, keys.K_RIGHTARROW); emit("M_Help_Key")
  menu.M_Menu_Quit_f(state); emit("M_Menu_Quit_f")
  menu.M_Quit_Key(state, 110); emit("M_Quit_Key")
  menu.M_Quit_Draw(state, 0, transform); emit("M_Quit_Draw")
  state.joiningGame = true
  menu.M_Menu_LanConfig_f(state); emit("M_Menu_LanConfig_f")
  menu.M_LanConfig_Draw(state, 0, transform, 0.0); emit("M_LanConfig_Draw")
  menu.M_LanConfig_Key(state, keys.K_DOWNARROW); emit("M_LanConfig_Key")
  menu.M_Menu_GameOptions_f(state, 16, "id1"); emit("M_Menu_GameOptions_f")
  menu.M_GameOptions_Draw(state, 0, transform, 0.0, registry); emit("M_GameOptions_Draw")
  state.selection = 1
  menu.M_NetStart_Change(state, registry, 1); emit("M_NetStart_Change")
  menu.M_GameOptions_Key(state, keys.K_DOWNARROW, registry); emit("M_GameOptions_Key")
  menu.M_Menu_Search_f(state, network, 26000, 0.0); emit("M_Menu_Search_f")
  menu.M_Search_Draw(state, 0, transform, 0.0); emit("M_Search_Draw")
  menu.M_Search_Key(state, keys.K_ESCAPE); emit("M_Search_Key")
  menu.M_Menu_ServerList_f(state, [["127.0.0.1", "fixture", "start", 1, 4]]); emit("M_Menu_ServerList_f")
  menu.M_ServerList_Draw(state, 0, transform, 0.0); emit("M_ServerList_Draw")
  menu.M_ServerList_Key(state, keys.K_DOWNARROW); emit("M_ServerList_Key")
  menu.M_Init(state); emit("M_Init")
  menu.M_Menu_Main_f(state)
  menu.M_Draw(state, 0, 640, 480, "start", 0.0, registry); emit("M_Draw")
  menu.M_Keydown(state, keys.K_DOWNARROW, registry); emit("M_Keydown")
  menu.M_ConfigureNetSubsystem(state); emit("M_ConfigureNetSubsystem")
  return 0
end function
