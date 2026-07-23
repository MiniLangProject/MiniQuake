package miniquake.host

import miniquake.types as t
import miniquake.constants as c
import miniquake.common as common
import miniquake.launch as launch
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.filesystem as qfs
import miniquake.server as server
import miniquake.client as client
import miniquake.client_effects as clientEffects
import miniquake.net_loop as netloop
import miniquake.player_move as movement
import miniquake.input as input
import miniquake.render.world as worldRenderer
import miniquake.render.entities as entityRenderer
import miniquake.render.particles as particleRenderer
import miniquake.console as console
import miniquake.menu as menu
import miniquake.screen as screen
import miniquake.view as view
import miniquake.sound.mixer as mixer
import miniquake.particles as particles
import miniquake.platform.win32 as win
import miniquake.mathlib as math
import miniquake.byteio as bio

function commandNeverExists(name)
  return false
end function

function registerCvar(registry, name, value, archive, serverFlag)
  return cvar.register(registry, cvar.create(name, value, archive, serverFlag), commandNeverExists)
end function

function createCvars()
  registry = cvar.createRegistry()
  registerCvar(registry, "host_framerate", "0", false, false)
  registerCvar(registry, "host_maxfps", "72", false, false)
  registerCvar(registry, "developer", "0", false, false)
  registerCvar(registry, "skill", "1", false, true)
  registerCvar(registry, "deathmatch", "0", false, true)
  registerCvar(registry, "coop", "0", false, true)
  registerCvar(registry, "pausable", "1", false, true)
  registerCvar(registry, "sv_gravity", "800", false, true)
  registerCvar(registry, "sv_maxspeed", "320", false, true)
  registerCvar(registry, "sv_accelerate", "10", false, true)
  registerCvar(registry, "sv_friction", "4", false, true)
  registerCvar(registry, "sv_stopspeed", "100", false, true)
  registerCvar(registry, "sv_maxvelocity", "2000", false, true)
  registerCvar(registry, "edgefriction", "2", false, true)
  registerCvar(registry, "sensitivity", "3", true, false)
  registerCvar(registry, "m_pitch", "0.022", true, false)
  registerCvar(registry, "m_yaw", "0.022", true, false)
  registerCvar(registry, "m_filter", "0", true, false)
  registerCvar(registry, "lookspring", "0", true, false)
  registerCvar(registry, "lookstrafe", "0", true, false)
  registerCvar(registry, "cl_forwardspeed", "200", true, false)
  registerCvar(registry, "cl_backspeed", "200", true, false)
  registerCvar(registry, "cl_sidespeed", "350", true, false)
  registerCvar(registry, "cl_upspeed", "200", true, false)
  registerCvar(registry, "r_fullbright", "0", false, false)
  registerCvar(registry, "r_wireframe", "0", false, false)
  registerCvar(registry, "r_wateralpha", "1", false, false)
  registerCvar(registry, "r_drawviewmodel", "1", false, false)
  registerCvar(registry, "r_drawentities", "1", false, false)
  registerCvar(registry, "cl_bob", "0.02", false, false)
  registerCvar(registry, "cl_bobcycle", "0.6", false, false)
  registerCvar(registry, "cl_bobup", "0.5", false, false)
  registerCvar(registry, "v_rollangle", "2", false, false)
  registerCvar(registry, "v_rollspeed", "200", false, false)
  registerCvar(registry, "v_kicktime", "0.5", false, false)
  registerCvar(registry, "ambient_level", "0.3", false, false)
  registerCvar(registry, "ambient_fade", "100", false, false)
  registerCvar(registry, "volume", "0.7", true, false)
  registerCvar(registry, "_snd_mixahead", "0.1", true, false)
  registerCvar(registry, "bgmvolume", "1", true, false)
  registerCvar(registry, "gamma", "1", true, false)
  registerCvar(registry, "viewsize", "100", true, false)
  registerCvar(registry, "_windowed_mouse", "1", true, false)
  registerCvar(registry, "crosshair", "1", true, false)
  return registry
end function

function create(args)
  options = launch.parse(args)
  arguments = common.create(args)
  filesystem = qfs.initialize(options.basedir, options.gameDirectory)
  commands = cmd.create()
  variables = createCvars()
  input.resetBindings()
  if options.developer then cvar.set(variables, "developer", "1") end if
  cvar.set(variables, "skill", "" + options.skill)
  timing = t.HostTiming(0.0, 0.0, 0.0, 0, 0)
  network = netloop.createState()
  player = movement.create(t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  // The integrated loopback client shares the authoritative PlayerState with
  // the local server. Network snapshots must not be written back into it.
  localClient.localAuthoritative = true
  maxClients = common.integerOption(arguments, "-listen", 1)
  if options.dedicated and maxClients < 1 then maxClients = 1 end if
  gameServer = server.create(maxClients)
  consoleState = console.create(1024)
  menuState = menu.create()
  viewState = view.create()
  soundMixer = mixer.create(filesystem, 22050)
  soundDisabled = options.noSound or options.headless or options.dedicated
  soundMixer.enabled = not soundDisabled
  quakeCEnabled = not launch.hasParm(options, "-noqc")
  return t.GameSession(
    arguments,
    filesystem,
    commands,
    variables,
    timing,
    gameServer,
    localClient,
    network,
    player,
    void,
    void,
    true,
    false,
    false,
    options.basedir,
    options.gameDirectory,
    options.startMap,
    options.width,
    options.height,
    options.fullscreen,
    options.headless,
    options.maxFrames,
    0,
    false,
    "",
    consoleState,
    menuState,
    viewState,
    soundMixer,
    [],
    [],
    quakeCEnabled,
    soundDisabled,
    false,
    0,
    0,
  )
end function

function gameplayMouseEnabled(session)
  // WinQuake always owns the mouse in fullscreen.  In a window the original
  // _windowed_mouse cvar controls capture and relative mouse-look.
  if session.fullscreen then return true end if
  return cvar.variableValue(session.cvars, "_windowed_mouse") != 0.0
end function

function updateMouseCapture(session)
  desired = false
  if session.windowCreated and win.hasFocus() and not session.menu.active and not session.console.active then
    desired = gameplayMouseEnabled(session)
  end if
  return input.setMouseCapture(desired)
end function

function filterTime(timing, newRealtime, maxFps, forcedFrameRate, timedemo)
  timing.realtime = newRealtime
  elapsed = timing.realtime - timing.oldRealtime
  if not timedemo and maxFps > 0.0 and elapsed < 1.0 / maxFps then
    timing.filteredFrames = timing.filteredFrames + 1
    return false
  end if
  if forcedFrameRate > 0.0 then timing.frameTime = forcedFrameRate else timing.frameTime = elapsed end if
  timing.oldRealtime = timing.realtime
  if timing.frameTime > 0.1 then timing.frameTime = 0.1 end if
  if timing.frameTime < 0.001 then timing.frameTime = 0.001 end if
  timing.frameCount = timing.frameCount + 1
  return true
end function

function cvarCommand(session, arguments)
  if len(arguments) == 0 then return false end if
  variable = cvar.find(session.cvars, arguments[0])
  if variable is void then return false end if
  if len(arguments) == 1 then
    print "\"" + variable.name + "\" is \"" + variable.string + "\""
  else
    cvar.set(session.cvars, variable.name, arguments[1])
  end if
  return true
end function

function findAlias(system, name)
  wanted = bio.lower(name)
  for each alias in system.aliases
    if bio.lower(alias.name) == wanted then return alias end if
  end for
  return void
end function

function startMap(session, mapName)
  if session.mixer is not void then mixer.stopAll(session.mixer) end if
  if session.renderer is not void and session.renderer.uploaded then worldRenderer.destroy(session.renderer) end if
  if session.entityRenderer is not void then entityRenderer.destroy(session.entityRenderer) end if
  session.renderer = void
  session.entityRenderer = void
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then server.shutdown(session.server) end if

  skill = cvar.variableValue(session.cvars, "skill")
  session.server.deathmatch = cvar.variableValue(session.cvars, "deathmatch") != 0.0
  session.server.coop = cvar.variableValue(session.cvars, "coop") != 0.0
  if session.qcEnabled then
    server.spawnRuntime(session.server, session.filesystem, mapName, skill, session.cvars, session.commands)
  else
    server.spawn(session.server, session.filesystem, mapName, skill)
  end if
  session.player.origin = math.copy(session.server.spawnPoint)
  session.player.viewAngles = math.copy(session.server.spawnAngles)
  session.player.renderAngles = math.copy(session.server.spawnAngles)
  session.player.velocity = t.Vec3(0.0, 0.0, 0.0)
  session.client.command.viewAngles = math.copy(session.player.viewAngles)
  input.clear(session.client.command)
  input.resetMouse()
  view.reset(session.view, session.player.origin)
  session.particles = []
  session.temporaryEntities = []

  // Headless validation and dedicated servers do not need the expensive
  // render-surface and client-model copies.  The original host keeps renderer
  // initialization behind the video boundary as well.
  if not session.headless then
    palette = qfs.readFile(session.filesystem, "gfx/palette.lmp")
    session.renderer = worldRenderer.create(session.server.worldModel, palette)
    session.entityRenderer = entityRenderer.create(session.filesystem, palette, session.server.modelPrecache)
    if session.windowCreated then screen.initialize(session.console, session.menu, session.filesystem, palette) end if
  end if
  session.startMap = session.server.mapName

  client.connect(session.client, session.network)
  serverSocket = netloop.checkNewConnections(session.network)
  if serverSocket is void then return error(3000, "Host_Map: loopback server connection missing") end if
  server.acceptLocal(session.server, serverSocket)

  attempts = 0
  while session.client.signon < c.SIGNONS and attempts < 128
    client.sendReliable(session.client)
    client.pump(session.client)
    server.pumpClientMessages(session.server, session.player)
    client.pump(session.client)
    attempts = attempts + 1
  end while
  if session.client.signon != c.SIGNONS then return error(3001, "Host_Map: local signon stopped at " + session.client.signon) end if
  if session.entityRenderer is not void then entityRenderer.synchronize(session.entityRenderer, session.client.modelPrecache) end if
  if session.mixer.enabled then
    mixer.setListenerEntity(session.mixer, session.client.viewEntity)
    soundPrecache = mixer.precache(session.mixer, session.client.soundPrecache)
    if soundPrecache[1] > 0 and cvar.variableValue(session.cvars, "developer") != 0.0 then
      print "sound precache: " + soundPrecache[0] + " loaded, " + soundPrecache[1] + " failed"
    end if
  end if
  session.statusMessage = "map " + session.server.mapName + ": " + session.server.levelName
  console.appendLine(session.console, session.statusMessage)
  print session.statusMessage
  for each line in session.server.diagnostics
    console.appendLine(session.console, line)
    if cvar.variableValue(session.cvars, "developer") != 0.0 then print line end if
  end for
  session.server.diagnostics = []
  return true
end function

function executeCommand(session, text)
  arguments = cmd.tokenize(text)
  if len(arguments) == 0 then return false end if
  name = bio.lower(arguments[0])

  alias = findAlias(session.commands, name)
  if alias is not void then cmd.insertText(session.commands, alias.value + "\n"); return true end if
  if name == "wait" then session.commands.wait = true; return true end if
  if name == "echo" then print cmd.argsFrom(t.CommandSystem([], [], arguments, "", false), 1); return true end if
  if name == "exec" and len(arguments) >= 2 then
    script = try(qfs.readText(session.filesystem, arguments[1]))
    if script is error then print "couldn't exec " + arguments[1] else cmd.insertText(session.commands, script + "\n") end if
    return true
  end if
  if name == "alias" and len(arguments) >= 3 then
    value = ""
    index = 2
    while index < len(arguments)
      if index > 2 then value = value + " " end if
      value = value + arguments[index]
      index = index + 1
    end while
    cmd.addAlias(session.commands, arguments[1], value)
    return true
  end if
  if name == "set" and len(arguments) >= 3 then
    variable = cvar.find(session.cvars, arguments[1])
    if variable is void then registerCvar(session.cvars, arguments[1], arguments[2], false, false) else cvar.set(session.cvars, arguments[1], arguments[2]) end if
    return true
  end if
  if (name == "map" or name == "changelevel") and len(arguments) >= 2 then return startMap(session, arguments[1]) end if
  if name == "restart" and session.server.active then return startMap(session, session.server.mapName) end if
  if name == "disconnect" then client.disconnect(session.client); server.shutdown(session.server); return true end if
  if name == "quit" or name == "exit" then session.running = false; return true end if
  if name == "pause" then session.server.paused = not session.server.paused; return true end if
  if name == "noclip" then session.player.noclip = not session.player.noclip; print "noclip " + session.player.noclip; return true end if
  if name == "toggleconsole" then setConsoleActive(session, not session.console.active); return true end if
  if name == "togglemenu" then setMenuActive(session, not session.menu.active); return true end if
  if name == "status" then
    print "map: " + session.server.mapName
    print "time: " + session.server.time
    print "origin: " + session.player.origin.x + " " + session.player.origin.y + " " + session.player.origin.z
    return true
  end if
  if name == "bind" then
    if len(arguments) == 2 then
      print "\"" + arguments[1] + "\" = \"" + input.commandForKey(arguments[1]) + "\""
      return true
    end if
    if len(arguments) >= 3 then
      value = arguments[2]
      index = 3
      while index < len(arguments)
        value = value + " " + arguments[index]
        index = index + 1
      end while
      return input.bindKey(arguments[1], value)
    end if
    return false
  end if
  if name == "unbind" and len(arguments) >= 2 then return input.unbindKey(arguments[1]) end if
  if name == "unbindall" then return input.unbindAll() end if
  if cvarCommand(session, arguments) then return true end if
  if cvar.variableValue(session.cvars, "developer") != 0.0 then print "Unknown command \"" + arguments[0] + "\"" end if
  return false
end function

function executeCommandBuffer(session, maximumCommands)
  executed = 0
  session.commands.wait = false
  while len(session.commands.text) > 0 and executed < maximumCommands
    split = cmd.splitFirstCommand(session.commands.text)
    session.commands.text = split[1]
    executeCommand(session, split[0])
    executed = executed + 1
    if session.commands.wait then break end if
  end while
  return executed
end function

function queueStartupCommands(session)
  if qfs.fileExists(session.filesystem, "quake.rc") then
    cmd.addText(session.commands, "exec quake.rc\n")
  else
    if qfs.fileExists(session.filesystem, "default.cfg") then cmd.addText(session.commands, "exec default.cfg\n") end if
    if qfs.fileExists(session.filesystem, "config.cfg") then cmd.addText(session.commands, "exec config.cfg\n") end if
    if qfs.fileExists(session.filesystem, "autoexec.cfg") then cmd.addText(session.commands, "exec autoexec.cfg\n") end if
  end if
  cmd.addText(session.commands, common.stuffCommands(session.arguments))
  return true
end function

function initialize(session)
  print "MiniQuake " + c.QUAKE_VERSION + " / protocol " + c.PROTOCOL_VERSION
  print common.describe(session.arguments)
  print qfs.describe(session.filesystem)
  console.appendLine(session.console, "MiniQuake " + c.QUAKE_VERSION)
  if not session.headless then
    fullscreenValue = 0
    if session.fullscreen then fullscreenValue = 1 end if
    win.create("MiniQuake", session.width, session.height, fullscreenValue)
    session.windowCreated = true
    updateMouseCapture(session)
  end if

  if not session.noSound then
    opened = try(mixer.open(session.mixer))
    if opened is error then
      session.noSound = true
      session.mixer.enabled = false
      console.appendLine(session.console, "sound disabled: " + opened.message)
      print "sound disabled: " + opened.message
    else
      session.audioStarted = true
      // Menu feedback must be available before the first game event.  These
      // effects remain cached when the current level sound list is precached.
      mixer.precache(session.mixer, ["misc/menu1.wav", "misc/menu2.wav", "misc/menu3.wav"])
    end if
  end if

  queueStartupCommands(session)
  executeCommandBuffer(session, 4096)
  if not session.server.active then
    fallbackMap = session.startMap
    if fallbackMap == "" and qfs.fileExists(session.filesystem, "maps/start.bsp") then fallbackMap = "start" end if
    if fallbackMap != "" then startMap(session, fallbackMap) end if
  end if
  session.lastTicks = win.ticks()
  session.timing.oldRealtime = 0.0
  session.initialized = true
  return session
end function

function consumeClientEvents(session)
  pending = client.consumeMessages(session.client)
  result = clientEffects.process(
    pending,
    session.client,
    session.player,
    session.mixer,
    session.view,
    session.console,
    session.commands,
    session.particles,
    session.temporaryEntities,
    session.client.serverTime,
  )
  session.particles = result[0]
  session.temporaryEntities = result[1]
  return len(pending)
end function

function consumeQuakeCControl(session)
  count = 0
  for each line in session.server.diagnostics
    console.append(session.console, line)
    if cvar.variableValue(session.cvars, "developer") != 0.0 then print line end if
    count = count + 1
  end for
  session.server.diagnostics = []
  if session.server.machine is void or session.server.machine.context is void then return count end if
  contextValue = session.server.machine.context
  for each line in contextValue.consoleLines
    console.append(session.console, line)
    if cvar.variableValue(session.cvars, "developer") != 0.0 then print line end if
    count = count + 1
  end for
  contextValue.consoleLines = []
  if contextValue.changeLevel != "" then
    cmd.addText(session.commands, "map \"" + contextValue.changeLevel + "\"\n")
    contextValue.changeLevel = ""
    count = count + 1
  end if
  return count
end function

function playLocalSound(session, name)
  if session.mixer is void or not session.mixer.enabled then return false end if
  played = try(mixer.localSound(session.mixer, name))
  if played is error then return false end if
  return played
end function

function playMenuSound(session, name)
  if session.mixer is void or not session.mixer.enabled then return false end if
  result = try(mixer.localSound(session.mixer, name))
  if result is error then return false end if
  return result
end function

function setMenuActive(session, active)
  wasActive = session.menu.active
  if active then
    console.setActive(session.console, false)
    session.consoleVisible = false
    if not wasActive then
      session.menu.pausedByMenu = session.server.active and not session.server.paused and session.server.maxClients == 1 and cvar.variableValue(session.cvars, "pausable") != 0.0
      if session.menu.pausedByMenu then session.server.paused = true end if
      menu.openMain(session.menu)
    else
      menu.setActive(session.menu, true)
    end if
  else
    if session.menu.pausedByMenu then
      session.server.paused = false
      session.menu.pausedByMenu = false
    end if
    menu.setActive(session.menu, false)
  end if
  updateMouseCapture(session)
  return active
end function

function setConsoleActive(session, active)
  if active and session.menu.active then setMenuActive(session, false) end if
  console.setActive(session.console, active)
  session.consoleVisible = active
  updateMouseCapture(session)
  return active
end function

function adjustMenuOption(session, direction)
  selection = session.menu.selection
  changed = true
  if selection == 3 then
    value = math.clamp(cvar.variableValue(session.cvars, "viewsize") + direction * 10.0, 30.0, 120.0)
    cvar.setValue(session.cvars, "viewsize", value)
  else if selection == 4 then
    value = math.clamp(cvar.variableValue(session.cvars, "gamma") - direction * 0.05, 0.5, 1.0)
    cvar.setValue(session.cvars, "gamma", value)
  else if selection == 5 then
    value = math.clamp(cvar.variableValue(session.cvars, "sensitivity") + direction * 0.5, 1.0, 11.0)
    cvar.setValue(session.cvars, "sensitivity", value)
  else if selection == 6 then
    value = math.clamp(cvar.variableValue(session.cvars, "bgmvolume") + direction * 0.1, 0.0, 1.0)
    cvar.setValue(session.cvars, "bgmvolume", value)
    session.menu.statusText = "CD MUSIC IS NOT IMPLEMENTED"
  else if selection == 7 then
    value = math.clamp(cvar.variableValue(session.cvars, "volume") + direction * 0.1, 0.0, 1.0)
    cvar.setValue(session.cvars, "volume", value)
  else if selection == 8 then
    value = 400.0
    if cvar.variableValue(session.cvars, "cl_forwardspeed") > 200.0 then value = 200.0 end if
    cvar.setValue(session.cvars, "cl_forwardspeed", value)
    cvar.setValue(session.cvars, "cl_backspeed", value)
  else if selection == 9 then
    value = cvar.variableValue(session.cvars, "m_pitch")
    if value == 0.0 then value = 0.022 end if
    cvar.setValue(session.cvars, "m_pitch", -value)
  else if selection == 10 then
    value = 1.0
    if cvar.variableValue(session.cvars, "lookspring") != 0.0 then value = 0.0 end if
    cvar.setValue(session.cvars, "lookspring", value)
  else if selection == 11 then
    value = 1.0
    if cvar.variableValue(session.cvars, "lookstrafe") != 0.0 then value = 0.0 end if
    cvar.setValue(session.cvars, "lookstrafe", value)
  else if selection == 13 then
    value = 1.0
    if cvar.variableValue(session.cvars, "_windowed_mouse") != 0.0 then value = 0.0 end if
    cvar.setValue(session.cvars, "_windowed_mouse", value)
    updateMouseCapture(session)
  else
    changed = false
  end if
  if changed then playMenuSound(session, "misc/menu3.wav") end if
  return changed
end function

function executeMenuSelection(session)
  action = menu.selectedCommand(session.menu)
  if action == "menu_single" then
    menu.setPage(session.menu, menu.PAGE_SINGLE)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_multi" then
    menu.setPage(session.menu, menu.PAGE_MULTI)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_options" then
    menu.setPage(session.menu, menu.PAGE_OPTIONS)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_help" then
    menu.setPage(session.menu, menu.PAGE_HELP)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_quit" then
    menu.setPage(session.menu, menu.PAGE_QUIT)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "new_game" then
    setMenuActive(session, false)
    cmd.addText(session.commands, "map start\n")
  else if action == "load_game" then
    menu.setPage(session.menu, menu.PAGE_LOAD)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "save_game" then
    menu.setPage(session.menu, menu.PAGE_SAVE)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "join_game" or action == "host_game" then
    menu.setStatus(session.menu, "NETWORK CONNECTION MENUS ARE STILL PENDING")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "player_setup" then
    menu.setPage(session.menu, menu.PAGE_SETUP)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "customize_controls" then
    menu.setPage(session.menu, menu.PAGE_KEYS)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "open_console" then
    setMenuActive(session, false)
    setConsoleActive(session, true)
  else if action == "reset_defaults" then
    cmd.addText(session.commands, "exec default.cfg\n")
    menu.setStatus(session.menu, "DEFAULT CONTROLS RESTORED")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "video_options" then
    menu.setPage(session.menu, menu.PAGE_VIDEO)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "bind_selected" then
    command = menu.keyCommandAt(session.menu)
    if command != "" then
      found = input.bindingsForCommand(command)
      if len(found) >= 2 then input.unbindCommand(command) end if
      session.menu.waitingForKey = true
      menu.setStatus(session.menu, "")
      playMenuSound(session, "misc/menu2.wav")
    end if
  else if action == "load_slot" then
    menu.setStatus(session.menu, "SAVEGAME LOADING IS STILL PENDING")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "save_slot" then
    menu.setStatus(session.menu, "SAVEGAME WRITING IS STILL PENDING")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "setup_option" then
    menu.setStatus(session.menu, "PLAYER NAME/COLOR EDITING IS STILL PENDING")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "video_option" then
    menu.setStatus(session.menu, "USE -WINDOW -WIDTH -HEIGHT; RESTART REQUIRED")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "adjust_option" then
    adjustMenuOption(session, 1)
  else if action == "help_next" then
    menu.changeHelpPage(session.menu, 1)
    playMenuSound(session, "misc/menu2.wav")
  end if
  return action
end function

function discardTextInput()
  count = 0
  code = win.textPop()
  while code >= 0
    count = count + 1
    code = win.textPop()
  end while
  return count
end function

function processConsoleInput(session)
  if not session.windowCreated then return 0 end if
  handled = 0
  if win.keyPressed(c.VK_OEM_3) then
    setConsoleActive(session, not session.console.active)
    handled = handled + 1
  end if

  if win.keyPressed(c.VK_ESCAPE) then
    if session.console.active then
      setConsoleActive(session, false)
    else if session.menu.active then
      result = menu.back(session.menu)
      if result == "close" then setMenuActive(session, false) else playMenuSound(session, "misc/menu1.wav") end if
    else
      setMenuActive(session, true)
      playMenuSound(session, "misc/menu2.wav")
    end if
    handled = handled + 1
  end if

  if session.menu.active then
    if session.menu.page == menu.PAGE_QUIT then
      if win.keyPressed(c.VK_Y) then session.running = false; handled = handled + 1 end if
      if win.keyPressed(c.VK_N) then menu.back(session.menu); playMenuSound(session, "misc/menu1.wav"); handled = handled + 1 end if
    else
      if session.menu.page == menu.PAGE_KEYS and session.menu.waitingForKey then
        keyName = input.firstPressedKey()
        if keyName != "" and keyName != "ESCAPE" and keyName != "`" then
          command = menu.keyCommandAt(session.menu)
          if command != "" then input.bindKey(keyName, command) end if
          session.menu.waitingForKey = false
          playMenuSound(session, "misc/menu1.wav")
          handled = handled + 1
        end if
      else if session.menu.page == menu.PAGE_KEYS and (win.keyPressed(c.VK_BACK) or win.keyPressed(c.VK_DELETE)) then
        input.unbindCommand(menu.keyCommandAt(session.menu))
        playMenuSound(session, "misc/menu2.wav")
        handled = handled + 1
      end if
      if not session.menu.waitingForKey and win.keyPressed(c.VK_UP) then menu.move(session.menu, -1); playMenuSound(session, "misc/menu1.wav"); handled = handled + 1 end if
      if not session.menu.waitingForKey and win.keyPressed(c.VK_DOWN) then menu.move(session.menu, 1); playMenuSound(session, "misc/menu1.wav"); handled = handled + 1 end if
      if not session.menu.waitingForKey and win.keyPressed(c.VK_LEFT) then
        if session.menu.page == menu.PAGE_OPTIONS then adjustMenuOption(session, -1) else if session.menu.page == menu.PAGE_HELP then menu.changeHelpPage(session.menu, -1); playMenuSound(session, "misc/menu2.wav") end if
        handled = handled + 1
      end if
      if not session.menu.waitingForKey and win.keyPressed(c.VK_RIGHT) then
        if session.menu.page == menu.PAGE_OPTIONS then adjustMenuOption(session, 1) else if session.menu.page == menu.PAGE_HELP then menu.changeHelpPage(session.menu, 1); playMenuSound(session, "misc/menu2.wav") end if
        handled = handled + 1
      end if
      if not session.menu.waitingForKey and win.keyPressed(c.VK_RETURN) then executeMenuSelection(session); handled = handled + 1 end if
    end if
    discardTextInput()
    updateMouseCapture(session)
    return handled
  end if

  if not session.console.active then
    // Discard text produced while gameplay owns the keyboard so opening the
    // console later cannot replay stale characters.
    discardTextInput()
    updateMouseCapture(session)
    return handled
  end if

  updateMouseCapture(session)
  if win.keyPressed(c.VK_BACK) then console.backspace(session.console); handled = handled + 1 end if
  if win.keyPressed(c.VK_RETURN) then
    text = console.takeInput(session.console)
    if text != "" then
      console.appendLine(session.console, "]" + text)
      cmd.addText(session.commands, text + "\n")
    end if
    handled = handled + 1
  end if
  code = win.textPop()
  while code >= 0
    // WM_CHAR also reports return/backspace; those are handled as key events.
    if code != 8 and code != 13 and code != 96 and code != 126 then
      if console.appendCharacter(session.console, code) then handled = handled + 1 end if
    end if
    code = win.textPop()
  end while
  return handled
end function

function updateTitle(session)
  if not session.windowCreated then return end if
  if session.timing.frameCount % 30 != 0 then return end if
  title = "MiniQuake - " + session.server.mapName + "  (" + session.player.origin.x + ", " + session.player.origin.y + ", " + session.player.origin.z + ")"
  win.setTitle(title)
end function

function frame(session, elapsedSeconds)
  maxFps = cvar.variableValue(session.cvars, "host_maxfps")
  forced = cvar.variableValue(session.cvars, "host_framerate")
  newRealtime = session.timing.realtime + elapsedSeconds
  if not filterTime(session.timing, newRealtime, maxFps, forced, common.hasParm(session.arguments, "-timedemo")) then return false end if

  executeCommandBuffer(session, 64)
  client.sendReliable(session.client)
  client.pump(session.client)

  if session.client.spawned and session.server.active then
    command = session.client.command
    if not session.headless and not session.console.active and not session.menu.active and session.windowCreated and win.hasFocus() then
      input.collectGame(
        command,
        session.timing.frameTime * 1000.0,
        cvar.variableValue(session.cvars, "sensitivity"),
        cvar.variableValue(session.cvars, "m_yaw"),
        cvar.variableValue(session.cvars, "m_pitch"),
        cvar.variableValue(session.cvars, "m_filter") != 0.0,
        cvar.variableValue(session.cvars, "cl_forwardspeed"),
        cvar.variableValue(session.cvars, "cl_backspeed"),
        cvar.variableValue(session.cvars, "cl_sidespeed"),
        cvar.variableValue(session.cvars, "cl_upspeed"),
      )
      client.sendMove(session.client, command)
    else if not session.headless then
      input.clear(command)
      client.sendMove(session.client, command)
    end if
    server.frame(session.server, session.player, session.timing.frameTime, session.cvars)
    session.simulatedFrames = session.simulatedFrames + 1
    client.sendReliable(session.client)
    client.pump(session.client)
  end if

  consumeClientEvents(session)
  client.CL_DecayLightsAt(session.client.serverTime, session.timing.frameTime)
  client.CL_UpdateEntityDlights(session.client, session.client.serverTime)
  consumeQuakeCControl(session)
  console.clearExpiredCenter(session.console, session.client.serverTime)
  session.particles = particles.update(session.particles, session.client.serverTime, session.timing.frameTime)
  view.calculate(
    session.view,
    session.player,
    session.client.command.viewAngles,
    session.client.serverTime,
    session.timing.frameTime,
    cvar.variableValue(session.cvars, "cl_bob"),
    cvar.variableValue(session.cvars, "cl_bobcycle"),
    cvar.variableValue(session.cvars, "cl_bobup"),
    cvar.variableValue(session.cvars, "v_rollangle"),
    cvar.variableValue(session.cvars, "v_rollspeed"),
    cvar.variableValue(session.cvars, "v_kicktime"),
  )

  if session.mixer.enabled then
    session.mixer.masterVolume = cvar.variableValue(session.cvars, "volume")
    mixer.updateListener(session.mixer, session.view.origin, session.view.forward, session.view.right)
    mixer.setListenerEntity(session.mixer, session.client.viewEntity)
    mixer.updateEntityOrigins(session.mixer, session.client.entities)
    mixer.updateAmbient(
      session.mixer,
      session.server.worldModel,
      session.view.origin,
      session.timing.frameTime,
      cvar.variableValue(session.cvars, "ambient_level"),
      cvar.variableValue(session.cvars, "ambient_fade"),
    )
    mixer.update(session.mixer, session.timing.frameTime, cvar.variableValue(session.cvars, "_snd_mixahead"))
  end if

  if session.renderer is not void and session.windowCreated then
    session.renderer.fullbright = cvar.variableValue(session.cvars, "r_fullbright") != 0.0
    session.renderer.wireframe = cvar.variableValue(session.cvars, "r_wireframe") != 0.0
    session.renderer.waterAlpha = cvar.variableValue(session.cvars, "r_wateralpha")
    width = win.width()
    height = win.height()
    worldRenderer.render(session.renderer, width, height, session.view.origin, session.view.angles)
    if session.entityRenderer is not void then
      entityRenderer.synchronize(session.entityRenderer, session.client.modelPrecache)
      if cvar.variableValue(session.cvars, "r_drawentities") != 0.0 then
        entityRenderer.render(session.entityRenderer, session.renderer, session.client.entities, session.client.viewEntity, session.view.right, session.view.up, session.client.serverTime)
      end if
      if cvar.variableValue(session.cvars, "r_drawviewmodel") != 0.0 then
        entityRenderer.renderViewModel(session.entityRenderer, session.player, session.view, session.client.serverTime)
      end if
    end if
    particleRenderer.render(session.particles, session.renderer.palette)
    particleRenderer.renderTemporary(session.temporaryEntities, session.client.serverTime, session.renderer.palette)
    screen.render(
      session.console,
      session.menu,
      session.view,
      session.player,
      width,
      height,
      session.server.mapName,
      cvar.variableValue(session.cvars, "crosshair") != 0.0,
      session.timing.realtime,
      session.cvars,
    )
    win.swap()
    // WinQuake performs S_ExtraUpdate around expensive rendering work.  A
    // second non-blocking top-up keeps waveOut fed when a frame takes longer
    // than one 512-sample block.
    if session.mixer.enabled then
      mixer.update(session.mixer, session.timing.frameTime, cvar.variableValue(session.cvars, "_snd_mixahead"))
    end if
    session.renderedFrames = session.renderedFrames + 1
    updateTitle(session)
  end if
  return true
end function

function shutdown(session)
  if session.entityRenderer is not void then entityRenderer.destroy(session.entityRenderer); session.entityRenderer = void end if
  if session.renderer is not void and session.renderer.uploaded then worldRenderer.destroy(session.renderer) end if
  session.renderer = void
  screen.shutdown(session.console, session.menu)
  if session.audioStarted then mixer.close(session.mixer); session.audioStarted = false end if
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then server.shutdown(session.server) end if
  if session.windowCreated then input.setMouseCapture(false); win.destroy(); session.windowCreated = false end if
  qfs.release(session.filesystem)
  session.running = false
  return true
end function

function run(args)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then print "Host_Init: " + initialized.message; shutdown(session); return 2 end if
  if not session.server.active then
    print "MiniQuake: no map started. Use -basedir PATH +map start"
    shutdown(session)
    return 2
  end if

  lastTicks = win.ticks()
  while session.running
    if session.windowCreated then
      if not win.poll() then session.running = false end if
      processConsoleInput(session)
    end if
    now = win.ticks()
    elapsedMs = now - lastTicks
    lastTicks = now
    if elapsedMs < 0 then elapsedMs = 0 end if
    if elapsedMs > 250 then elapsedMs = 250 end if
    frame(session, elapsedMs / 1000.0)
    if session.maxFrames > 0 and session.timing.frameCount >= session.maxFrames then session.running = false end if
    if session.windowCreated then win.sleep(1) else if elapsedMs == 0 then win.sleep(1) end if
  end while
  shutdown(session)
  return 0
end function

function soak(session, frameCount, frameTime)
  gc_collect()
  liveBefore = heap_count()
  bytesBefore = heap_bytes_used()
  index = 0
  while index < frameCount
    frame(session, frameTime)
    index = index + 1
  end while
  gc_collect()
  liveAfter = heap_count()
  bytesAfter = heap_bytes_used()
  stable = liveAfter <= liveBefore + 64 and bytesAfter <= bytesBefore + 1048576
  return t.HostSoakResult(frameCount, liveBefore, liveAfter, bytesBefore, bytesAfter, stable)
end function

function runSoak(args, frameCount)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    print "Host_Init: " + initialized.message
    shutdown(session)
    return 2
  end if
  if not session.server.active then
    print "MiniQuake soak: no map started"
    shutdown(session)
    return 2
  end if
  warmup = 0
  // Let one-time gameplay transitions settle before taking the heap baseline.
  // On start.bsp the player can die after the old 120-frame warmup, which
  // changes the retained object graph without representing sustained growth.
  while warmup < 1200
    frame(session, 0.02)
    warmup = warmup + 1
  end while
  result = soak(session, frameCount, 0.02)
  print "MiniQuake host soak"
  print "  frames=" + result.frames
  print "  live blocks: " + result.liveBefore + " -> " + result.liveAfter
  print "  heap bytes:  " + result.bytesBefore + " -> " + result.bytesAfter
  if result.stable then print "  result=PASS" else print "  result=FAIL" end if
  shutdown(session)
  if result.stable then return 0 end if
  return 3
end function
function runHeadlessFrames(args, frameCount)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    print "Host_Init: " + initialized.message
    shutdown(session)
    return 2
  end if
  if not session.server.active then
    print "MiniQuake runtime smoke: no map started"
    shutdown(session)
    return 2
  end if
  index = 0
  while index < frameCount
    frameResult = try(frame(session, 0.02))
    if frameResult is error then
      print "Host_Frame " + index + ": " + frameResult.message
      shutdown(session)
      return 3
    end if
    index = index + 1
  end while
  print "MiniQuake runtime smoke: PASS"
  print "  map=" + session.server.mapName + " frames=" + frameCount + " edicts=" + session.server.numEdicts
  print "  signon=" + session.client.signon + " player=" + session.player.origin.x + " " + session.player.origin.y + " " + session.player.origin.z
  shutdown(session)
  return 0
end function
