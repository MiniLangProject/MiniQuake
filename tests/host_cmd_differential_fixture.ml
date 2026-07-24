import miniquake.host as host
import miniquake.server as server
import miniquake.savegame as savegame
import miniquake.cvar as cvar
import miniquake.constants as c

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function newSession()
  return host.create([])
end function

function main(args)
  findSession = newSession()
  found = host.FindViewthing(findSession)
  print "{\"function\":\"FindViewthing\",\"case\":\"missing\",\"found\":" + boolText(found is not void) + "}"

  beginSession = newSession()
  beginClient = beginSession.server.clients[0]
  beginClient.active = true
  beginClient.spawned = false
  server.Host_Begin_f(beginClient)
  print "{\"function\":\"Host_Begin_f\",\"case\":\"client_begin\",\"spawned\":" + boolText(beginClient.spawned) + "}"

  changeSession = newSession()
  changeResult = host.Host_Changelevel_f(changeSession, ["changelevel"])
  print "{\"function\":\"Host_Changelevel_f\",\"case\":\"invalid_arguments\",\"spawned\":" + boolText(changeResult) + "}"

  colorSession = newSession()
  host.Host_Color_f(colorSession, ["color", "-1", "14"])
  print "{\"function\":\"Host_Color_f\",\"case\":\"console_clamp\",\"color\":" + colorSession.client.colors + "}"

  connectSession = newSession()
  connectSession.demoNumber = 3
  host.Host_Connect_f(connectSession, ["connect", "remote"])
  print "{\"function\":\"Host_Connect_f\",\"case\":\"remote_attempt\",\"demonum\":" + connectSession.demoNumber + "}"

  demosSession = newSession()
  demosSession.startMap = ""
  demosSession.demoLoop = ["demo1"]
  demosSession.demoNumber = -1
  host.Host_Demos_f(demosSession)
  print "{\"function\":\"Host_Demos_f\",\"case\":\"resume_loop\",\"demonum\":" + demosSession.demoNumber + ",\"next\":1}"

  flySession = newSession()
  print "{\"function\":\"Host_Fly_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Fly_f(flySession)) + "}"

  giveSession = newSession()
  print "{\"function\":\"Host_Give_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Give_f(giveSession, ["give", "h", "125"])) + "}"

  godSession = newSession()
  print "{\"function\":\"Host_God_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_God_f(godSession)) + "}"

  commands = host.Host_InitCommands()
  // The MiniLang host registry also aggregates four pr_edict.c commands and
  // the Cache_Init `flush` command, which live in separate original units.
  print "{\"function\":\"Host_InitCommands\",\"case\":\"stock_commands\",\"commands\":" + (len(commands) - 5) + "}"

  kickSession = newSession()
  print "{\"function\":\"Host_Kick_f\",\"case\":\"inactive_console\",\"sent\":" + boolText(host.Host_Kick_f(kickSession, ["kick"])) + "}"

  killSession = newSession()
  killClient = killSession.server.clients[0]
  killClient.active = true
  killRejected = not server.Host_Kill_f(killSession.server, killClient)
  print "{\"function\":\"Host_Kill_f\",\"case\":\"already_dead\",\"rejected\":" + boolText(killRejected) + "}"

  loadSession = newSession()
  print "{\"function\":\"Host_Loadgame_f\",\"case\":\"invalid_arguments\",\"loaded\":" + boolText(host.Host_Loadgame_f(loadSession, ["load"])) + "}"

  mapSession = newSession()
  host.Host_Map_f(mapSession, ["map"])
  print "{\"function\":\"Host_Map_f\",\"case\":\"empty_map\",\"active\":" + boolText(mapSession.server.active) + "}"

  nameSession = newSession()
  host.Host_Name_f(nameSession, ["name", "Ranger"])
  print "{\"function\":\"Host_Name_f\",\"case\":\"console_name\",\"name_ok\":" + boolText(cvar.variableString(nameSession.cvars, "_cl_name") == "Ranger") + "}"

  noclipSession = newSession()
  print "{\"function\":\"Host_Noclip_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Noclip_f(noclipSession)) + "}"

  notargetSession = newSession()
  print "{\"function\":\"Host_Notarget_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Notarget_f(notargetSession)) + "}"

  pauseSession = newSession()
  print "{\"function\":\"Host_Pause_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Pause_f(pauseSession)) + "}"

  pingSession = newSession()
  print "{\"function\":\"Host_Ping_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Ping_f(pingSession)) + "}"

  prespawnSession = newSession()
  prespawnClient = prespawnSession.server.clients[0]
  prespawnClient.active = true
  prespawnClient.spawned = true
  server.Host_PreSpawn_f(prespawnSession.server, prespawnClient)
  print "{\"function\":\"Host_PreSpawn_f\",\"case\":\"already_spawned\",\"sendsignon\":" + boolText(prespawnClient.sendSignon) + "}"

  quitSession = newSession()
  quitSession.console.active = false
  host.Host_Quit_f(quitSession)
  print "{\"function\":\"Host_Quit_f\",\"case\":\"menu_confirmation\",\"menu\":" + boolText(quitSession.menu.active) + ",\"quit\":" + boolText(not quitSession.running) + "}"

  reconnectSession = newSession()
  reconnectSession.client.signon = c.SIGNONS
  reconnectSession.client.connected = true
  host.Host_Reconnect_f(reconnectSession)
  print "{\"function\":\"Host_Reconnect_f\",\"case\":\"wait_for_signon\",\"signon\":" + reconnectSession.client.signon + "}"

  restartSession = newSession()
  restartResult = host.Host_Restart_f(restartSession)
  print "{\"function\":\"Host_Restart_f\",\"case\":\"inactive\",\"spawned\":" + boolText(restartResult) + "}"

  comment = savegame.Host_SavegameComment("Entrance", 1, 12)
  print "{\"function\":\"Host_SavegameComment\",\"case\":\"entrance\",\"comment\":\"" + comment + "\"}"

  saveSession = newSession()
  saveResult = host.Host_Savegame_f(saveSession, ["save", "s0"])
  print "{\"function\":\"Host_Savegame_f\",\"case\":\"inactive\",\"saved\":" + boolText(saveResult) + "}"

  saySession = newSession()
  print "{\"function\":\"Host_Say\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Say(saySession, ["say", "hello"], false)) + "}"

  sayTeamSession = newSession()
  print "{\"function\":\"Host_Say_Team_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Say_Team_f(sayTeamSession, ["say_team", "hello"])) + "}"

  sayFunctionSession = newSession()
  print "{\"function\":\"Host_Say_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Say_f(sayFunctionSession, ["say", "hello"])) + "}"

  spawnSession = newSession()
  spawnClient = spawnSession.server.clients[0]
  spawnClient.active = true
  spawnClient.spawned = true
  server.Host_Spawn_f(spawnSession.server, spawnClient, spawnSession.player)
  print "{\"function\":\"Host_Spawn_f\",\"case\":\"already_spawned\",\"sendsignon\":" + boolText(spawnClient.sendSignon) + "}"

  startSession = newSession()
  startSession.startMap = ""
  startSession.demoNumber = -1
  host.Host_Startdemos_f(startSession, ["startdemos", "demo1", "demo2"])
  print "{\"function\":\"Host_Startdemos_f\",\"case\":\"two_demos\",\"first_ok\":" + boolText(startSession.demoLoop[0] == "demo1") + ",\"second_ok\":" + boolText(startSession.demoLoop[1] == "demo2") + ",\"demonum\":" + startSession.demoNumber + "}"

  statusSession = newSession()
  print "{\"function\":\"Host_Status_f\",\"case\":\"inactive_console\",\"sent\":" + boolText(host.Host_Status_f(statusSession)) + "}"

  stopSession = newSession()
  print "{\"function\":\"Host_Stopdemo_f\",\"case\":\"not_playing\",\"stopped\":" + boolText(host.Host_Stopdemo_f(stopSession)) + "}"

  tellSession = newSession()
  print "{\"function\":\"Host_Tell_f\",\"case\":\"console_disconnected\",\"sent\":" + boolText(host.Host_Tell_f(tellSession, ["tell", "ranger", "hello"])) + "}"

  versionPrinted = host.Host_Version_f()
  print "{\"function\":\"Host_Version_f\",\"case\":\"version\",\"printed\":" + boolText(versionPrinted) + "}"

  viewFrameSession = newSession()
  print "{\"function\":\"Host_Viewframe_f\",\"case\":\"missing_viewthing\",\"changed\":" + boolText(host.Host_Viewframe_f(viewFrameSession, ["viewframe", "1"])) + "}"

  viewModelSession = newSession()
  print "{\"function\":\"Host_Viewmodel_f\",\"case\":\"missing_viewthing\",\"changed\":" + boolText(host.Host_Viewmodel_f(viewModelSession, ["viewmodel", "progs/player.mdl"])) + "}"

  viewNextSession = newSession()
  print "{\"function\":\"Host_Viewnext_f\",\"case\":\"missing_viewthing\",\"changed\":" + boolText(host.Host_Viewnext_f(viewNextSession)) + "}"

  viewPrevSession = newSession()
  print "{\"function\":\"Host_Viewprev_f\",\"case\":\"missing_viewthing\",\"changed\":" + boolText(host.Host_Viewprev_f(viewPrevSession)) + "}"

  frameText = host.PrintFrameName(void, 1)
  print "{\"function\":\"PrintFrameName\",\"case\":\"missing_extradata\",\"printed\":" + boolText(frameText != "") + "}"
  return 0
end function
