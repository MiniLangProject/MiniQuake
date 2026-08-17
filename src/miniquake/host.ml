/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.host.
*/
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
import miniquake.net_datagram as netDatagram
import miniquake.net_main as netmain
import miniquake.net_wins as netwins
import miniquake.player_move as movement
import miniquake.input as input
import miniquake.keys as keys
import miniquake.render.world as worldRenderer
import miniquake.render.gl11 as gl
import miniquake.render.enhanced as enhancedRenderer
import miniquake.render.entities as entityRenderer
import miniquake.render.gl_refrag as glRefrag
import miniquake.render.particles as particleRenderer
import miniquake.client_render_handoff as renderHandoff
import miniquake.render.draw2d as draw2d
import miniquake.render_evidence as renderEvidence
import miniquake.statusbar as statusbar
import miniquake.console as console
import miniquake.menu as menu
import miniquake.screen as screen
import miniquake.view as view
import miniquake.chase as chase
import miniquake.sound.mixer as mixer
import miniquake.sound.cd_audio as cdAudio
import miniquake.savegame as savegame
import miniquake.savegame_runtime as saveRuntime
import miniquake.demo as demo
import miniquake.demo_player as demoPlayer
import miniquake.format.bsp as bsp
import miniquake.particles as particles
import miniquake.platform.win32 as win
import miniquake.sys_win as sysWin
import miniquake.gl_vidnt as glvid
import miniquake.mathlib as math
import miniquake.world_bsp as worldBsp
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.message as msg
import miniquake.sizebuf as sz
import miniquake.array_util as arrayutil
import miniquake.quakec.edict as qcedict
import miniquake.quakec.vm as qcvm
import miniquake.compat_diagnostics as compatDiagnostics
import miniquake.host_timing as hostTiming
import miniquake.host_command_numbers as hostNumbers
import miniquake.stability_contract as stability
import miniquake.external_reference_contract as externalReference
import miniquake.optimization_baseline as optBaseline
import std.fs as fs

titleFpsInitialized = false
titleFpsLastFrame = 0
titleFpsLastRealtime = 0.0
titleFpsLastValue = -1

// Append only static entities linked into leaves visible from the current
// world PVS. CL_RelinkEntities intentionally contains dynamic entities only;
// this is the production counterpart of GLQuake's R_StoreEfrags calls made
// while traversing visible world leaves.
function appendVisibleStaticEntities(session, dynamicEntities)
  if session.renderer is void or session.entityRenderer is void or len(session.client.staticEntities) == 0 then return dynamicEntities end if
  glRefrag.ConfigureStaticEntities(session.renderer, session.entityRenderer, session.client.staticEntities)
  pvs = worldBsp.leafPvs(session.renderer.map, session.renderer.viewLeaf)
  return glRefrag.R_AppendVisiblePvs(dynamicEntities, pvs)
end function

// Report whether command never exists holds for the active state.
function commandNeverExists(name)
  return false
end function

// Update subsystem configuration for register cvar.
function registerCvar(registry, name, value, archive, serverFlag)
  return cvar.register(registry, cvar.create(name, value, archive, serverFlag), commandNeverExists)
end function

// Create and initialize cvars.
function createCvars(commandLine, registered)
  registry = cvar.createRegistry()
  registeredValue = "0"
  commandLineValue = "0"
  if registered then
    registeredValue = "1"
    commandLineValue = commandLine.commandLine
  end if
  registerCvar(registry, "registered", registeredValue, false, false)
  registerCvar(registry, "cmdline", commandLineValue, false, true)
  registerCvar(registry, "host_framerate", "0", false, false)
  // GLQuake hard-coded 72 Hz in Host_FilterTime. Keep an explicit limiter for
  // users who want steadier pacing, but let modern machines render well above
  // that historical ceiling. A value of zero disables filtering entirely.
  registerCvar(registry, "host_maxfps", "250", true, false)
  registerCvar(registry, "host_speeds", "0", false, false)
  registerCvar(registry, "sys_ticrate", "0.05", false, false)
  registerCvar(registry, "serverprofile", "0", false, false)
  registerCvar(registry, "hostname", "UNNAMED", true, false)
  registerCvar(registry, "net_messagetimeout", "300", false, false)
  registerCvar(registry, "developer", "0", false, false)
  registerCvar(registry, "skill", "1", false, true)
  registerCvar(registry, "deathmatch", "0", false, true)
  registerCvar(registry, "coop", "0", false, true)
  registerCvar(registry, "teamplay", "0", false, true)
  registerCvar(registry, "fraglimit", "0", false, true)
  registerCvar(registry, "timelimit", "0", false, true)
  registerCvar(registry, "pausable", "1", false, true)
  registerCvar(registry, "samelevel", "0", false, false)
  registerCvar(registry, "noexit", "0", false, true)
  registerCvar(registry, "temp1", "0", false, false)
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
  registerCvar(registry, "m_forward", "1", true, false)
  registerCvar(registry, "m_side", "0.8", true, false)
  registerCvar(registry, "m_filter", "0", true, false)
  registerCvar(registry, "lookspring", "0", true, false)
  registerCvar(registry, "lookstrafe", "0", true, false)
  registerCvar(registry, "cl_forwardspeed", "200", true, false)
  registerCvar(registry, "cl_backspeed", "200", true, false)
  registerCvar(registry, "cl_sidespeed", "350", true, false)
  registerCvar(registry, "cl_upspeed", "200", true, false)
  registerCvar(registry, "cl_movespeedkey", "2.0", false, false)
  registerCvar(registry, "cl_yawspeed", "140", false, false)
  registerCvar(registry, "cl_pitchspeed", "150", false, false)
  registerCvar(registry, "cl_anglespeedkey", "1.5", false, false)
  registerCvar(registry, "joystick", "0", true, false)
  registerCvar(registry, "joyname", "joystick", false, false)
  registerCvar(registry, "joyadvanced", "0", false, false)
  registerCvar(registry, "joyadvaxisx", "0", false, false)
  registerCvar(registry, "joyadvaxisy", "0", false, false)
  registerCvar(registry, "joyadvaxisz", "0", false, false)
  registerCvar(registry, "joyadvaxisr", "0", false, false)
  registerCvar(registry, "joyadvaxisu", "0", false, false)
  registerCvar(registry, "joyadvaxisv", "0", false, false)
  registerCvar(registry, "joyforwardthreshold", ".15", false, false)
  registerCvar(registry, "joysidethreshold", ".15", false, false)
  registerCvar(registry, "joypitchthreshold", ".15", false, false)
  registerCvar(registry, "joyyawthreshold", ".15", false, false)
  registerCvar(registry, "joyforwardsensitivity", "-1.0", false, false)
  registerCvar(registry, "joysidesensitivity", "-1.0", false, false)
  registerCvar(registry, "joypitchsensitivity", "1.0", false, false)
  registerCvar(registry, "joyyawsensitivity", "-1.0", false, false)
  registerCvar(registry, "joywwhack1", "0.0", false, false)
  registerCvar(registry, "joywwhack2", "0.0", false, false)
  registerCvar(registry, "r_fullbright", "0", false, false)
  registerCvar(registry, "r_wireframe", "0", false, false)
  registerCvar(registry, "r_wateralpha", "1", false, false)
  registerCvar(registry, "r_drawviewmodel", "1", false, false)
  registerCvar(registry, "r_drawentities", "1", false, false)
  // Modern lighting is opt-in so the exact GLQuake-compatible renderer stays
  // the default and remains available for differential/reference testing.
  registerCvar(registry, "r_lighting", "0", true, false)
  registerCvar(registry, "r_shadows", "1", true, false)
  registerCvar(registry, "r_shadowquality", "1", true, false)
  registerCvar(registry, "gl_subdivide_size", "128", true, false)
  registerCvar(registry, "gl_nobind", "0", false, false)
  registerCvar(registry, "gl_max_size", "1024", false, false)
  registerCvar(registry, "gl_picmip", "0", false, false)
  registerCvar(registry, "gl_polyblend", "1", false, false)
  registerCvar(registry, "gl_cull", "1", false, false)
  registerCvar(registry, "r_mirroralpha", "1", false, false)
  registerCvar(registry, "r_norefresh", "0", false, false)
  registerCvar(registry, "r_speeds", "0", false, false)
  registerCvar(registry, "gl_finish", "0", false, false)
  registerCvar(registry, "gl_clear", "0", false, false)
  registerCvar(registry, "chase_back", "100", false, false)
  registerCvar(registry, "chase_up", "16", false, false)
  registerCvar(registry, "chase_right", "0", false, false)
  registerCvar(registry, "chase_active", "0", false, false)
  registerCvar(registry, "fov", "90", false, false)
  registerCvar(registry, "scr_conspeed", "300", false, false)
  registerCvar(registry, "con_notifytime", "3", false, false)
  registerCvar(registry, "scr_centertime", "2", false, false)
  registerCvar(registry, "showram", "1", false, false)
  registerCvar(registry, "showturtle", "0", false, false)
  registerCvar(registry, "showpause", "1", false, false)
  registerCvar(registry, "scr_printspeed", "8", false, false)
  registerCvar(registry, "gl_triplebuffer", "1", true, false)
  registerCvar(registry, "vid_mode", "0", true, false)
  registerCvar(registry, "vid_width", "0", true, false)
  registerCvar(registry, "vid_height", "0", true, false)
  registerCvar(registry, "vid_bpp", "0", true, false)
  registerCvar(registry, "vid_fullscreen", "0", true, false)
  registerCvar(registry, "vid_renderer", "OPENGL", true, false)
  registerCvar(registry, "vid_wait", "0", true, false)
  registerCvar(registry, "vid_nopageflip", "0", true, false)
  registerCvar(registry, "_vid_wait_override", "0", true, false)
  registerCvar(registry, "_vid_default_mode", "0", true, false)
  registerCvar(registry, "_vid_default_mode_win", "3", true, false)
  registerCvar(registry, "vid_config_x", "800", true, false)
  registerCvar(registry, "vid_config_y", "600", true, false)
  registerCvar(registry, "vid_stretch_by_2", "1", true, false)
  registerCvar(registry, "gl_ztrick", "1", false, false)
  registerCvar(registry, "cl_bob", "0.02", false, false)
  registerCvar(registry, "cl_bobcycle", "0.6", false, false)
  registerCvar(registry, "cl_bobup", "0.5", false, false)
  registerCvar(registry, "lcd_x", "0", false, false)
  registerCvar(registry, "lcd_yaw", "0", false, false)
  registerCvar(registry, "scr_ofsx", "0", false, false)
  registerCvar(registry, "scr_ofsy", "0", false, false)
  registerCvar(registry, "scr_ofsz", "0", false, false)
  registerCvar(registry, "cl_rollangle", "2", false, false)
  registerCvar(registry, "cl_rollspeed", "200", false, false)
  // Retain the early MiniQuake spellings as compatibility aliases.
  registerCvar(registry, "v_rollangle", "2", false, false)
  registerCvar(registry, "v_rollspeed", "200", false, false)
  registerCvar(registry, "v_kicktime", "0.5", false, false)
  registerCvar(registry, "v_kickroll", "0.6", false, false)
  registerCvar(registry, "v_kickpitch", "0.6", false, false)
  registerCvar(registry, "v_centermove", "0.15", false, false)
  registerCvar(registry, "v_centerspeed", "500", false, false)
  registerCvar(registry, "v_iyaw_cycle", "2", false, false)
  registerCvar(registry, "v_iroll_cycle", "0.5", false, false)
  registerCvar(registry, "v_ipitch_cycle", "1", false, false)
  registerCvar(registry, "v_iyaw_level", "0.3", false, false)
  registerCvar(registry, "v_iroll_level", "0.1", false, false)
  registerCvar(registry, "v_ipitch_level", "0.3", false, false)
  registerCvar(registry, "v_idlescale", "0", false, false)
  registerCvar(registry, "cl_crossx", "0", false, false)
  registerCvar(registry, "cl_crossy", "0", false, false)
  registerCvar(registry, "gl_cshiftpercent", "100", false, false)
  registerCvar(registry, "ambient_level", "0.3", false, false)
  registerCvar(registry, "ambient_fade", "100", false, false)
  registerCvar(registry, "volume", "0.7", true, false)
  registerCvar(registry, "_snd_mixahead", "0.35", true, false)
  registerCvar(registry, "bgmvolume", "1", true, false)
  registerCvar(registry, "gamma", "1", true, false)
  registerCvar(registry, "viewsize", "100", true, false)
  registerCvar(registry, "_windowed_mouse", "1", true, false)
  registerCvar(registry, "crosshair", "0", true, false)
  registerCvar(registry, "_cl_name", "player", true, false)
  registerCvar(registry, "_cl_color", "0", true, false)
  return registry
end function

// Apply the Quake-compatible host find max clients behavior.
function Host_FindMaxClients(arguments)
  dedicated = common.hasParm(arguments, "-dedicated")
  listening = common.hasParm(arguments, "-listen")
  if dedicated and listening then return error(3010, "Only one of -dedicated or -listen can be specified") end if
  maximum = 1
  if dedicated then maximum = common.integerOption(arguments, "-dedicated", 8) end if
  if listening then maximum = common.integerOption(arguments, "-listen", 8) end if
  if maximum < 1 then maximum = 8 end if
  if maximum > c.MAX_CLIENTS then maximum = c.MAX_CLIENTS end if
  return [maximum, dedicated, listening]
end function

// Create and initialize the module state.
function create(args)
  // Screen command arrays are a differential-test trace, not renderer input.
  // Keep them disabled in the production host to avoid per-frame UI garbage.
  screen.SCR_SetCommandTraceEnabled(false)
  options = launch.parse(args)
  arguments = common.create(args)
  filesystem = qfs.initializeArguments(options.basedir, arguments)
  commands = cmd.create()
  variables = createCvars(arguments, filesystem.registered)
  input.resetBindings()
  keys.Key_Init()
  input.configurePlatform(
    variables,
    common.hasParm(arguments, "-nomouse"),
    common.hasParm(arguments, "-nojoy"),
    common.hasParm(arguments, "-dinput"),
  )
  input.IN_Init()
  if options.developer then cvar.set(variables, "developer", "1") end if
  cvar.set(variables, "skill", "" + options.skill)
  timing = t.HostTiming(0.0, 0.0, 0.0, 0, 0)
  network = netloop.createState()
  player = movement.create(t.Vec3(0.0, 0.0, 64.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  client.CL_SetStandardQuake(localClient, arguments.standardQuake)
  // The integrated loopback client shares the authoritative PlayerState with
  // the local server. Network snapshots must not be written back into it.
  localClient.localAuthoritative = true
  clientMode = try(Host_FindMaxClients(arguments))
  maxClients = 1
  if clientMode is not error then maxClients = clientMode[0] end if
  gameServer = server.create(maxClients)
  gameServer.standardQuake = arguments.standardQuake
  if maxClients > 1 then cvar.set(variables, "deathmatch", "1") else cvar.set(variables, "deathmatch", "0") end if
  consoleState = console.create(1024)
  consoleState.dedicated = options.dedicated
  console.Con_Init(consoleState, filesystem, options.width, common.hasParm(arguments, "-condebug"))
  menuState = menu.create()
  viewState = view.create()
  soundMixer = mixer.create(filesystem, 22050)
  soundDisabled = options.noSound or options.headless or options.dedicated
  soundMixer.enabled = not soundDisabled
  quakeCEnabled = not launch.hasParm(options, "-noqc")
  effectiveHeadless = options.headless or options.dedicated
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
    effectiveHeadless,
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
    "",
    void,
    void,
    false,
    0,
    0.0,
    -1,
    "",
    [],
    -1,
    1.0,
    false,
    false,
    [],
    0.0,
    0,
    "",
    -1,
    "",
    "",
  )
end function

// Report whether gameplay mouse enabled holds for the active state.
function gameplayMouseEnabled(session)
  // WinQuake always owns the mouse in fullscreen.  In a window the original
  // _windowed_mouse cvar controls capture and relative mouse-look.
  if session.fullscreen then return true end if
  return cvar.variableValue(session.cvars, "_windowed_mouse") != 0.0
end function

// Update module state for mouse capture.
function updateMouseCapture(session)
  desired = false
  if session.windowCreated and win.hasFocus() and not session.menu.active and not session.console.active then
    desired = gameplayMouseEnabled(session)
  end if
  return input.setMouseCapture(desired)
end function

// Provide filter time behavior for the active subsystem.
function filterTime(timing, newRealtime, maxFps, forcedFrameRate, timedemo)
  return hostTiming.filterAbsolute(timing, newRealtime, maxFps, forcedFrameRate, timedemo, 1.0)
end function

// Provide cvar command behavior for the active subsystem.
function cvarCommand(session, arguments)
  result = cvar.command(session.cvars, arguments)
  if not result[0] then return false end if
  if result[1] != "" then print result[1] end if
  return true
end function

// Provide flush server cvar changes behavior for the active subsystem.
function flushServerCvarChanges(session)
  changes = cvar.takeServerChanges(session.cvars)
  if not session.server.active then return 0 end if
  written = 0
  for each change in changes
    text = "\"" + change[0] + "\" changed to \"" + change[1] + "\"\n"
    written = written + server.broadcastPrint(session.server, text)
  end for
  return written
end function

// Return alias.
function findAlias(system, name)
  wanted = bio.lower(name)
  for each alias in system.aliases
    if bio.lower(alias.name) == wanted then return alias end if
  end for
  return void
end function

// Initialize state for start map.
function startMap(session, mapName)
  return transitionMap(session, mapName, false, false, false)
end function

// Update subsystem configuration for change level.
function changeLevel(session, mapName)
  return transitionMap(session, mapName, true, true, false)
end function

// Provide restart level behavior for the active subsystem.
function restartLevel(session, mapName)
  // Host_Restart_f keeps the existing spawn_parms.  Only changelevel calls
  // SV_SaveSpawnparms/SetChangeParms before SV_SpawnServer.
  return transitionMap(session, mapName, true, false, false)
end function

// Complete every deterministic client-side first-use cache before gameplay is
// exposed. This corresponds to the original CL_InitTEnts/S_BeginPrecaching and
// renderer cache work, with the modern OGG/audio queue included as well.
function precachePlayableLevel(session, developerValue)
  server.precacheClientFrameLookups(session.server, session.player)
  if session.entityRenderer is not void then
    renderHandoff.precacheBeamModels(session.client)
    entityRenderer.synchronize(session.entityRenderer, session.client.modelPrecache)
    entities = try(entityRenderer.precache(session.entityRenderer))
    if entities is error then return error(3932, "client entity precache: " + entities.message) end if
    synchronizeClientRelinkModels(session)
  end if
  if session.windowCreated and session.renderer is not void then
    particleRenderer.R_InitParticleTexture()
    // Prime the player's initial PVS and visible-face set. This is a pure
    // render cache calculation: unlike a hidden Host_Frame it advances no
    // game time and executes no monster/player QuakeC.
    initialViewOrigin = t.Vec3(
      session.player.origin.x + 0.03125,
      session.player.origin.y + 0.03125,
      session.player.origin.z + session.player.viewHeight + 0.03125,
    )
    worldRenderer.markVisible(session.renderer, initialViewOrigin)
  end if

  if session.mixer.enabled then
    mixer.setListenerEntity(session.mixer, session.client.viewEntity)
    soundPrecache = mixer.precache(session.mixer, session.client.soundPrecache)
    temporaryPrecache = clientEffects.precacheTemporarySounds(session.mixer)
    ambientPrecache = mixer.precache(session.mixer, ["ambience/water1.wav", "ambience/wind2.wav"])
    failedSounds = soundPrecache[1] + temporaryPrecache[1] + ambientPrecache[1]
    if failedSounds > 0 and developerValue != 0.0 then
      loadedSounds = soundPrecache[0] + temporaryPrecache[0] + ambientPrecache[0]
      print "sound precache: " + loadedSounds + " loaded, " + failedSounds + " failed"
    end if
    session.mixer.masterVolume = cvar.variableValue(session.cvars, "volume")
    requestedVolume = cvar.variableValue(session.cvars, "bgmvolume")
    cdState = cdAudio.ensure(session.mixer)
    actualVolume = cdAudio.CDAudio_Update(cdState, requestedVolume)
    if cdState.enabled then
      if actualVolume != requestedVolume then cvar.setValue(session.cvars, "bgmvolume", actualVolume) end if
      session.mixer.musicVolume = actualVolume
    else
      session.mixer.musicVolume = 0.0
    end if
    mixer.updateListener(session.mixer, session.view.origin, session.view.forward, session.view.right)
    mixer.updateEntityOrigins(session.mixer, session.client.entities)
    if session.server.worldModel is not void then
      mixer.updateAmbient(
        session.mixer,
        session.server.worldModel,
        session.view.origin,
        session.timing.frameTime,
        cvar.variableValue(session.cvars, "ambient_level"),
        cvar.variableValue(session.cvars, "ambient_fade"),
      )
    end if
    // Fill the waveOut queue now so neither PCM painting nor the first OGG
    // decode block is charged to the first visible gameplay frame.
    mixer.update(
      session.mixer,
      session.timing.frameTime,
      cvar.variableValue(session.cvars, "_snd_mixahead"),
    )
  end if
  return true
end function

// Present one non-simulating loading frame after the new renderer and all
// level assets exist.  This moves the driver's one-time first SwapBuffers cost
// out of the first ordinary Host_Frame while retaining four stock-order warmup
// updates under the loading plaque.
function finishLoadingPresentation(session)
  if not session.windowCreated or session.renderer is void then
    screen.SCR_EndLoadingPlaque(session.console)
    return true
  end if
  // The first scene presents can complete asynchronously in the driver. Keep
  // four ordinary world frames under the plaque so a deferred third-present
  // stall cannot become the first visible gameplay frame.
  screen.SCR_FinishLoadingAfterUpdates(5)
  updated = try(screen.SCR_UpdateScreen(
    session.console,
    session.menu,
    session.view,
    session.player,
    win.width(),
    win.height(),
    session.server.mapName,
    false,
    session.timing.realtime,
    session.timing.frameTime,
    session.cvars,
    session.client.connected,
    session.server.active,
    session.client.signon,
    session.server.paused,
    session.client.lastMessageTime,
    session.demoPlayback is not void,
    false,
    true,
    false,
  ))
  if updated is error then return updated end if
  glvid.GL_EndRendering()
  win.poll()
  return true
end function

// Finalize state for finish local map connection.
function finishLocalMapConnection(session, preserveClients)
  opt001dCvarDeveloper = cvar.variableValue(session.cvars, "developer")
  // Demo playback and remote connections deliberately use a non-authoritative
  // LocalClient because protocol snapshots own their rendered PlayerState.
  // A following local map reuses that client object, so restore the integrated
  // loopback invariant before any signon packet can write quantized origin,
  // velocity or FL_ONGROUND data back into the server's shared PlayerState.
  // Direct +map starts already carry this flag from create(); the attract-demo
  // -> New Game path is the transition that requires the explicit reset.
  session.client.localAuthoritative = true
  session.client.demoPlayback = false
  session.client.player = session.player
  session.client.name = cvar.variableString(session.cvars, "_cl_name")
  session.client.colors = native.trunc(cvar.variableValue(session.cvars, "_cl_color"))
  if not preserveClients then
    connected = try(client.connect(session.client, session.network))
    if connected is error then return connected end if
    serverSocket = netmain.NET_CheckNewConnections(session.network)
    if serverSocket is void then return error(3000, "Host_Map: loopback server connection missing") end if
    accepted = try(server.acceptLocal(session.server, serverSocket))
    if accepted is error then return accepted end if
  else if not session.client.connected then
    return true
  end if

  attempts = 0
  while session.client.signon < c.SIGNONS and attempts < 128
    client.sendReliable(session.client)
    pumpClient(session)
    server.pumpClientMessages(session.server, session.player)
    server.sendReliableMessages(session.server)
    // Host_Begin_f sends no stage-four packet in WinQuake. Once the server has
    // accepted "begin", its first ordinary datagram contains a fast entity
    // update; CL_ParseUpdate promotes signon 3 to 4.
    if session.client.signon == c.SIGNON_SPAWN then
      for each serverClient in session.server.clients
        if serverClient.active and serverClient.spawned then
          server.sendClientFrame(
            session.server,
            serverClient,
            server.playerStateForClient(session.server, serverClient, session.player),
          )
        end if
      end for
    end if
    pumpClient(session)
    attempts = attempts + 1
  end while
  if session.client.signon != c.SIGNONS then return error(3001, "Host_Map: local signon stopped at " + session.client.signon) end if
  // CL_ParseServerMessage handles prints, static sounds and CD tracks during
  // signon in GLQuake. MiniQuake queues those presentation events, so drain
  // them now: OGG opening/probing and static-channel creation then happen
  // behind the loading plaque and before the audio queue is painted.
  consumeClientEvents(session)
  precached = try(precachePlayableLevel(session, opt001dCvarDeveloper))
  if precached is error then return precached end if
  statusbar.Sbar_Changed()
  session.statusMessage = "map " + session.server.mapName + ": " + session.server.levelName
  console.appendLine(session.console, session.statusMessage)
  print session.statusMessage
  for each line in session.server.diagnostics
    console.appendLine(session.console, line)
    if opt001dCvarDeveloper != 0.0 then print line end if
  end for
  session.server.diagnostics = []
  return true
end function

// Provide failed map transition behavior for the active subsystem.
function failedMapTransition(session, result)
  // A failed create/upload may leave either the error value itself or a
  // partially initialized renderer in the session.  Never let the following
  // frame mistake that value for a live renderer, and release any companion
  // renderer that was already created during this transition.
  if session.renderer is not void and session.renderer is not error then worldRenderer.destroy(session.renderer) end if
  if session.entityRenderer is not void and session.entityRenderer is not error then entityRenderer.destroy(session.entityRenderer) end if
  session.renderer = void
  session.entityRenderer = void
  // Every map-loading failure must leave the host in ss_dead rather than the
  // transient ss_loading state.  Otherwise later frames continue treating an
  // already failed synchronous command as an in-progress level transition.
  session.server.loading = false
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then
    Host_ShutdownServer(session, true)
  else
    server.shutdown(session.server)
  end if
  screen.SCR_EndLoadingPlaque(session.console)
  session.statusMessage = result.message
  line = "Map transition failed: " + result.message
  console.appendLine(session.console, line)
  print line
  // Host_Map_f switches to gameplay before spawning in the original engine.
  // On failure, expose the diagnostic console so an interactive build remains
  // visibly responsive and the player can immediately enter another command.
  if not session.headless and not common.hasParm(session.arguments, "-dedicated") then
    setConsoleActive(session, true)
  end if
  return result
end function

// Provide transition map behavior for the active subsystem.
function transitionMap(session, mapName, preserveClients, saveChangeParms, deferLocalConnection)
  if session.windowCreated then
    input.IN_BlockGameplayTransition()
    input.clear(session.client.command)
    keys.Key_ClearStates()
  end if
  screen.SCR_SetIntermission(0, "", session.console, session.client.time)
  // gl_screen.c stops every active sound before it even checks whether the
  // loading plaque can be displayed. Preserve that ordering here.
  if session.mixer is not void then mixer.stopAll(session.mixer) end if
  loadingPlaque = screen.SCR_BeginLoadingPlaque(
    session.console,
    session.timing.realtime,
    session.client.connected,
    session.client.signon,
  )
  if loadingPlaque and session.windowCreated and session.renderer is not void then
    screen.SCR_UpdateScreen(
      session.console,
      session.menu,
      session.view,
      session.player,
      win.width(),
      win.height(),
      session.server.mapName,
      false,
      session.timing.realtime,
      session.timing.frameTime,
      session.cvars,
      session.client.connected,
      session.server.active,
      session.client.signon,
      session.server.paused,
      session.client.lastMessageTime,
      session.demoPlayback is not void,
      false,
      true,
      false,
    )
    glvid.GL_EndRendering()
  end if
  // Keep the Win32 queue responsive between the synchronous loading phases.
  // The expensive parsers remain deterministic, while resize/focus/close
  // messages no longer wait until the complete new map has been installed.
  if session.windowCreated then win.poll() end if
  if session.renderer is not void then worldRenderer.destroy(session.renderer) end if
  if session.entityRenderer is not void then entityRenderer.destroy(session.entityRenderer) end if
  session.renderer = void
  session.entityRenderer = void
  preserved = void
  if preserveClients then
    if not session.server.active then return failedMapTransition(session, error(3002, "Only the server may changelevel")) end if
    if saveChangeParms then
      preserved = server.beginChangeLevel(session.server)
    else
      preserved = server.preserveClientConnections(session.server)
      server.sendReconnect(session.server)
    end if
    if session.client.connected then client.reconnect(session.client) end if
  else
    if session.client.connected then client.disconnect(session.client) end if
    // Host_Map_f calls Host_ShutdownServer rather than clearing sv directly:
    // pending reliable data and the final disconnect packet must be handled
    // before the server structures are reset.
    if session.server.active then Host_ShutdownServer(session, false) end if
  end if

  skill = cvar.variableValue(session.cvars, "skill")
  session.server.deathmatch = cvar.variableValue(session.cvars, "deathmatch") != 0.0
  session.server.coop = cvar.variableValue(session.cvars, "coop") != 0.0
  spawned = true
  if session.qcEnabled then
    spawned = try(server.spawnRuntime(session.server, session.filesystem, mapName, skill, session.cvars, session.commands))
  else
    spawned = try(server.spawn(session.server, session.filesystem, mapName, skill))
  end if
  if spawned is error then return failedMapTransition(session, spawned) end if
  if session.windowCreated then win.poll() end if
  if preserveClients then server.finishChangeLevel(session.server, preserved) end if
  session.player.origin = math.copy(session.server.spawnPoint)
  session.player.viewAngles = math.copy(session.server.spawnAngles)
  session.player.renderAngles = math.copy(session.server.spawnAngles)
  session.player.velocity = t.Vec3(0.0, 0.0, 0.0)
  session.client.command.viewAngles = math.copy(session.player.viewAngles)
  input.clear(session.client.command)
  input.resetMouse()
  view.V_ClearClientState(session.view)
  session.particles = []
  session.temporaryEntities = []
  // Cvar_Set broadcasts only to clients that are active at the instant of the
  // change. Spawn-time changes therefore must not leak to later connections.
  cvar.takeServerChanges(session.cvars)

  // Headless validation and dedicated servers do not need the expensive
  // render-surface and client-model copies.  The original host keeps renderer
  // initialization behind the video boundary as well.
  if not session.headless then
    palette = try(qfs.readFile(session.filesystem, "gfx/palette.lmp"))
    if palette is error then return failedMapTransition(session, palette) end if
    videoState = glvid.VID_State()
    if videoState.initialized then palette = videoState.palette end if
    // Build the world first so external BSP pickup models cannot replace the
    // active world-surface root while they are parsed and uploaded.
    session.renderer = try(worldRenderer.create(session.server.worldModel, palette))
    if session.renderer is error then return failedMapTransition(session, session.renderer) end if
    worldRenderer.R_SetMultitextureCompatibility(videoState.multitexture, false)
    if session.windowCreated then
      uploadedWorld = try(worldRenderer.upload(session.renderer))
      if uploadedWorld is error then return failedMapTransition(session, error(3930, "startup world upload: " + uploadedWorld.message)) end if
      win.poll()
    end if
    session.entityRenderer = try(entityRenderer.create(session.filesystem, palette, session.server.modelPrecache))
    if session.entityRenderer is error then return failedMapTransition(session, session.entityRenderer) end if
    if session.windowCreated then
      precachedEntities = try(entityRenderer.precache(session.entityRenderer))
      if precachedEntities is error then return failedMapTransition(session, error(3931, "startup entity precache: " + precachedEntities.message)) end if
      win.poll()
    end if
    if session.windowCreated then
      session.width = win.width()
      session.height = win.height()
      screenInitialized = try(screen.initialize(session.console, session.menu, session.filesystem, palette, session.width, session.height, session.cvars))
      if screenInitialized is error then return failedMapTransition(session, screenInitialized) end if
      // SetWindowText and the compositor's first title repaint can each block
      // for several milliseconds.  Initialize the FPS title under the loading
      // plaque instead of charging it to the first playable frame.
      updateTitle(session)
    end if
  end if
  session.startMap = session.server.mapName

  if common.hasParm(session.arguments, "-dedicated") then
    session.statusMessage = "map " + session.server.mapName + ": " + session.server.levelName
    console.appendLine(session.console, session.statusMessage)
    print session.statusMessage
    screen.SCR_EndLoadingPlaque(session.console)
    return true
  end if

  if deferLocalConnection then return true end if
  connected = try(finishLocalMapConnection(session, preserveClients))
  if connected is error then return failedMapTransition(session, connected) end if
  statusbar.Sbar_Changed()
  // Reclaim parser, signon and renderer-upload temporaries while the loading
  // plaque is still visible. Interactive gameplay otherwise reaches the heap
  // boundary unpredictably and pays for a full collection in an ordinary
  // movement/render frame, which is perceived as asset streaming stutter.
  gc_collect()
  // Prime presentation without advancing simulation, then retain the plaque
  // for two ordinary Host_Frame updates. The third frame is the first visible
  // gameplay frame and no longer pays the driver's first-swap initialization.
  presented = try(finishLoadingPresentation(session))
  if presented is error then return failedMapTransition(session, presented) end if
  return connected
end function

// Encode and write configuration.
function writeConfiguration(session)
  if session.filesystem is void then return false end if
  // Automated render/transition diagnostics deliberately force small windowed
  // modes.  They share the production host, but must never replace the user's
  // persistent interactive settings when their temporary session shuts down.
  if common.hasParm(session.arguments, "-noautosaveconfig") then return false end if
  if session.windowCreated then glvid.VID_SaveCurrentConfigurationCvars() end if
  text = keys.Key_WriteBindings() + cvar.archiveText(session.cvars)
  written = try(qfs.writeText(session.filesystem, "config.cfg", text))
  if written is error then
    if cvar.variableValue(session.cvars, "developer") != 0.0 then print "couldn't write config.cfg: " + written.message end if
    return false
  end if
  return true
end function

// Apply the Quake-compatible host init local behavior.
function Host_InitLocal(session)
  mode = Host_FindMaxClients(session.arguments)
  if mode is error then return mode end if
  if session.server.maxClients != mode[0] and not session.server.active then
    server.resizeClients(session.server, mode[0])
  end if
  if mode[0] > 1 then cvar.set(session.cvars, "deathmatch", "1") else cvar.set(session.cvars, "deathmatch", "0") end if
  session.hostTime = 1.0
  return true
end function

// Apply the Quake-compatible host write configuration behavior.
function Host_WriteConfiguration(session)
  if not session.initialized or common.hasParm(session.arguments, "-dedicated") then return false end if
  return writeConfiguration(session)
end function

// Apply the Quake-compatible sv client printf behavior.
function SV_ClientPrintf(clientValue, text)
  return server.clientPrint(clientValue, text)
end function

// Apply the Quake-compatible sv broadcast printf behavior.
function SV_BroadcastPrintf(session, text)
  return server.broadcastPrint(session.server, text)
end function

// Apply the Quake-compatible host client commands behavior.
function Host_ClientCommands(clientValue, text)
  if clientValue is void or not clientValue.active then return false end if
  msg.writeByte(clientValue.message, c.SVC_STUFFTEXT)
  msg.writeString(clientValue.message, text)
  return true
end function

// Apply the Quake-compatible sv drop client behavior.
function SV_DropClient(session, clientValue, crash)
  if clientValue is void then return false end if
  return server.dropClient(session.server, clientValue, crash)
end function

// Apply the Quake-compatible host flush pending client messages behavior.
function Host_FlushPendingClientMessages(session, timeoutSeconds)
  start = win.ticks() / 1000.0
  count = 0
  running = true
  while running
    count = 0
    for each clientValue in session.server.clients
      if clientValue.active and clientValue.socket is not void and clientValue.message.curSize > 0 then
        if netmain.NET_CanSendMessage(clientValue.socket) then
          netmain.NET_SendMessage(clientValue.socket, clientValue.message)
          sz.clear(clientValue.message)
        else
          netmain.NET_GetMessage(clientValue.socket, session.client.incoming, netmain.net_messagetimeout)
          count = count + 1
        end if
      end if
    end for
    if count == 0 or win.ticks() / 1000.0 - start > timeoutSeconds then
      running = false
    else
      // Remote clients ACK concurrently. Yielding avoids monopolizing the
      // process while retaining host.c's three-second upper bound.
      win.sleep(1)
    end if
  end while
  return count
end function

// Apply the Quake-compatible host shutdown server behavior.
function Host_ShutdownServer(session, crash)
  if not session.server.active then return false end if
  // Mark inactive before disconnecting the local client, matching host.c and
  // preventing re-entrant frame work while final messages are flushed.
  session.server.active = false
  if session.client.connected then client.disconnect(session.client) end if
  // Flush score/name/final-print messages before the disconnect broadcast.
  // A blocked reliable channel is polled for ACKs for at most three seconds,
  // exactly as Host_ShutdownServer does in MiniQuake.
  pending = Host_FlushPendingClientMessages(session, 3.0)
  if pending > 0 then print "Host_ShutdownServer: pending reliable messages for " + pending + " clients" end if
  disconnectMessage = sz.alloc(4)
  msg.writeByte(disconnectMessage, c.SVC_DISCONNECT)
  failed = netmain.NET_SendToAll(session.server.clients, disconnectMessage, 5.0)
  if failed > 0 then print "Host_ShutdownServer: NET_SendToAll failed for " + failed + " clients" end if
  for each clientValue in session.server.clients
    if clientValue.active then server.dropClient(session.server, clientValue, crash) end if
  end for
  server.shutdown(session.server)
  return true
end function

// Apply the Quake-compatible host clear memory behavior.
function Host_ClearMemory(session)
  if session.entityRenderer is not void or session.renderer is not void then destroyScene(session) end if
  if session.client.connected then client.dropConnection(session.client) end if
  if session.server.active then Host_ShutdownServer(session, true) else server.shutdown(session.server) end if
  session.client.signon = c.SIGNON_NONE
  session.client.spawned = false
  session.client.entities = []
  session.client.modelPrecache = [""]
  session.client.soundPrecache = [""]
  session.particles = []
  session.temporaryEntities = []
  session.demoPlayback = void
  return true
end function

// Apply the Quake-compatible host filter time behavior.
function Host_FilterTime(session, elapsedSeconds)
  forced = cvar.variableValue(session.cvars, "host_framerate")
  maximum = cvar.variableValue(session.cvars, "host_maxfps")
  if maximum < 0.0 then maximum = 0.0 end if
  timedemo = session.timedemoActive or common.hasParm(session.arguments, "-timedemo")
  return hostTiming.filter(session.timing, elapsedSeconds, timedemo, forced, 1.0, maximum)
end function

// Apply the Quake-compatible host get console commands behavior.
function Host_GetConsoleCommands(session, inputLines)
  count = 0
  for each line in inputLines
    if line != "" then
      cmd.addText(session.commands, line + "\n")
      count = count + 1
    end if
  end for
  return count
end function

// Apply the Quake-compatible host init vcr behavior.
function Host_InitVCR(session)
  // VCR network capture/playback is an explicit project exclusion.  Rejecting
  // the original switches at initialization is deterministic and avoids
  // silently pretending to record a compatible quake.vcr.
  if common.hasParm(session.arguments, "-playback") or common.hasParm(session.arguments, "-record") then
    return error(3011, "VCR network capture/playback is not supported")
  end if
  return true
end function

// Apply the Quake-compatible host end game behavior.
function Host_EndGame(session, message)
  if cvar.variableValue(session.cvars, "developer") != 0.0 then print "Host_EndGame: " + message end if
  if session.server.active then Host_ShutdownServer(session, false) end if
  if common.hasParm(session.arguments, "-dedicated") then
    session.running = false
    return error(3012, "Host_EndGame: " + message)
  end if
  if session.demoNumber >= 0 and len(session.demoLoop) > 0 then nextDemo(session) else client.disconnect(session.client) end if
  return error(3013, "Host_EndGame: " + message)
end function

// Apply the Quake-compatible host error behavior.
function Host_Error(session, message)
  if session.inError then
    session.running = false
    return error(3014, "Host_Error: recursively entered")
  end if
  session.inError = true
  screen.SCR_EndLoadingPlaque(session.console)
  print "Host_Error: " + message
  if session.server.active then Host_ShutdownServer(session, false) end if
  if session.client.connected then client.disconnect(session.client) end if
  session.demoNumber = -1
  if common.hasParm(session.arguments, "-dedicated") then session.running = false end if
  session.inError = false
  return error(3015, "Host_Error: " + message)
end function

// Provide refresh save slots behavior for the active subsystem.
function refreshSaveSlots(session)
  items = []
  loadable = []
  index = 0
  while index < 12
    name = "s" + index + ".sav"
    label = "--- UNUSED SLOT ---"
    if qfs.fileExists(session.filesystem, name) then
      source = try(qfs.readFile(session.filesystem, name))
      if source is not error then
        inspected = try(savegame.inspectCommentBytes(source))
        if inspected is not error and inspected != "" then label = inspected end if
      end if
    end if
    items = items + [label]
    loadable = loadable + [label != "--- UNUSED SLOT ---"]
    index = index + 1
  end while
  menu.M_ScanSaves(session.menu, items, loadable)
  return items
end function

// Encode and write game.
function saveGame(session, requestedName)
  if not session.server.active then return error(3712, "Not playing a local game.") end if
  if screen.SCR_IntermissionMode() != 0 then return error(3715, "Can't save in intermission.") end if
  if session.server.maxClients != 1 then return error(3713, "Can't save multiplayer games.") end if
  for each clientValue in session.server.clients
    if clientValue.active then
      health = session.player.health
      if session.server.machine is not void then
        health = server.qcFloat(session.server.machine, clientValue.edictIndex, "health", health)
      end if
      if health <= 0.0 then return error(3714, "Can't savegame with a dead player.") end if
    end if
  end for
  name = savegame.filename(requestedName)
  if name is error then return name end if
  data = savegame.serializeBytes(session.server)
  if data is error then return data end if
  written = qfs.writeBytes(session.filesystem, name, data)
  if written is error then return written end if
  message = "Saved " + name
  console.appendLine(session.console, message)
  print message
  return true
end function

// Read and validate game.
function loadGame(session, requestedName)
  name = savegame.filename(requestedName)
  if name is error then return name end if
  source = qfs.readFile(session.filesystem, name)
  if source is error then return source end if
  saved = savegame.parseBytes(source)
  if saved is error then return saved end if
  // Host_Loadgame_f sets cls.demonum to -1 and disconnects the current
  // client before spawning the saved map. In MiniQuake an attract demo also
  // has a session-level DemoPlayback owner; merely disconnecting its
  // LocalClient leaves that owner eligible for stepDemoPlayback on the next
  // Host_Frame. Stop it only after the save has been validated, so a missing
  // or corrupt save remains a non-destructive menu/console error.
  stopAttractMode(session)
  cvar.setValue(session.cvars, "skill", saved.skill)
  // Host_Loadgame_f spawns the map, restores all globals/edicts, and only
  // then establishes the local connection.  Deferring signon is essential:
  // Host_Spawn_f must not run ClientConnect or PutClientInServer over the
  // authoritative player state from the save.
  started = transitionMap(session, saved.mapName, false, false, true)
  if started is error then return started end if
  restored = savegame.apply(session.server, saved)
  if restored is error then return failedMapTransition(session, restored) end if
  synchronized = saveRuntime.synchronizeLoadedServer(session.server)
  if synchronized is error then return failedMapTransition(session, synchronized) end if
  if len(session.server.clients) > 0 then
    server.syncPlayerFromQuakeC(session.server, session.server.clients[0], session.player)
  end if
  session.client.command.viewAngles = math.copy(session.player.viewAngles)
  view.V_ClearClientState(session.view)
  session.server.paused = true
  session.server.loadGame = true
  if not common.hasParm(session.arguments, "-dedicated") then
    connected = try(finishLocalMapConnection(session, false))
    if connected is error then return failedMapTransition(session, connected) end if
  end if
  // Saved edict/global parsing creates a large temporary graph. Reclaim it and
  // prime the new presentation while the load plaque is still authoritative.
  gc_collect()
  presented = try(finishLoadingPresentation(session))
  if presented is error then return failedMapTransition(session, presented) end if
  message = "Loaded " + name
  console.appendLine(session.console, message)
  print message
  return true
end function

// Update module state for player flag.
function setPlayerFlag(session, flag, enabled)
  if enabled then session.player.flags = session.player.flags | flag else session.player.flags = session.player.flags & ~flag end if
  if session.server.machine is not void and len(session.server.clients) > 0 then
    server.setQcEntityFloat(session.server, session.server.clients[0].edictIndex, "flags", session.player.flags)
  end if
  return enabled
end function

// Report whether player flag enabled holds for the active state.
function playerFlagEnabled(session, flag)
  return (session.player.flags & flag) != 0
end function

// Advance client by one processing step.
function pumpClient(session)
  if session.demoRecording is not void then
    return client.pumpRecording(session.client, session.demoRecording)
  end if
  return client.pump(session.client)
end function

// Finalize state for stop demo recording.
function stopDemoRecording(session)
  if session.demoRecording is void then return error(3722, "Not recording a demo.") end if
  stopped = try(demo.CL_Stop_f(session.demoRecording, session.client.command.viewAngles))
  if stopped is error then return stopped end if
  written = try(qfs.writeBytes(session.filesystem, session.demoName, demo.serialize(session.demoRecording)))
  if written is error then return written end if
  session.demoRecording = void
  session.demoName = ""
  print "Completed demo"
  return true
end function

// Initialize state for begin demo recording.
function beginDemoRecording(session, arguments)
  if session.demoRecording is not void then return error(3724, "Already recording a demo.") end if
  plan = try(demo.CL_Record_f(arguments, session.client.connected))
  if plan is error then return plan end if
  name = plan[0]
  recording = plan[1]
  // MiniQuake executes the optional map command before opening the demo file.
  // A failed map therefore leaves no empty recording behind; an open failure
  // occurs after the requested map transition and simply does not record it.
  if len(arguments) >= 3 then
    started = try(startMap(session, arguments[2]))
    if started is error then return started end if
  end if
  opened = try(qfs.writeBytes(session.filesystem, name, demo.serialize(recording)))
  if opened is error then return opened end if
  session.demoName = name
  session.demoRecording = recording
  print "recording to " + qfs.gamePath(session.filesystem, name) + "."
  return true
end function

// Release resources owned by scene.
function destroyScene(session)
  if session.entityRenderer is not void then entityRenderer.destroy(session.entityRenderer); session.entityRenderer = void end if
  if session.renderer is not void then worldRenderer.destroy(session.renderer) end if
  session.renderer = void
  return true
end function

// Provide rebuild renderer resources behavior for the active subsystem.
function rebuildRendererResources(session)
  videoState = glvid.VID_State()
  palette = videoState.palette
  modelPrecache = session.server.modelPrecache
  if len(session.client.modelPrecache) > 1 then modelPrecache = session.client.modelPrecache end if
  if session.server.worldModel is not void then
    session.entityRenderer = try(entityRenderer.create(session.filesystem, palette, modelPrecache))
    if session.entityRenderer is error then return session.entityRenderer end if
    precached = try(entityRenderer.precache(session.entityRenderer))
    if precached is error then return precached end if
    session.renderer = try(worldRenderer.create(session.server.worldModel, palette))
    if session.renderer is error then return session.renderer end if
    worldRenderer.R_SetMultitextureCompatibility(videoState.multitexture, false)
    uploaded = try(worldRenderer.upload(session.renderer))
    if uploaded is error then return uploaded end if
  end if
  session.width = win.width()
  session.height = win.height()
  initialized = try(screen.initialize(session.console, session.menu, session.filesystem, palette, session.width, session.height, session.cvars))
  if initialized is error then return initialized end if
  // The particle texture belongs to the active graphics context.  Recreate it
  // eagerly so the first gunshot after a renderer switch cannot use a stale
  // texture name or introduce an upload hitch.
  particleRenderer.R_InitParticleTexture()
  menu.M_SetVideoCallbacks(session.menu, glvid.VID_MenuDrawCallback, glvid.VID_MenuKeyCallback)
  screen.SCR_ConfigureClient(session.client)
  return true
end function

// Provide restart renderer behavior for the active subsystem.
function restartRenderer(session, backend)
  particleRenderer.R_ShutdownParticleTexture()
  destroyScene(session)
  screen.shutdown(session.console, session.menu)
  switched = glvid.VID_RestartRenderer(backend)
  rebuilt = rebuildRendererResources(session)
  if rebuilt is error then return error(3933, "Renderer resource rebuild failed: " + rebuilt.message) end if
  session.fullscreen = glvid.VID_State().modeState == glvid.MS_FULLDIB
  updateMouseCapture(session)
  if switched is error then return switched end if
  return true
end function

// Provide prepare demo scene behavior for the active subsystem.
function prepareDemoScene(session)
  if len(session.client.modelPrecache) <= 1 then return error(3727, "demo has no world model") end if
  modelName = session.client.modelPrecache[1]
  mapData = qfs.readFile(session.filesystem, modelName)
  if mapData is error then return mapData end if
  worldModel = bsp.parse(mapData, modelName)
  if worldModel is error then return worldModel end if
  session.server.worldModel = worldModel
  session.server.modelName = modelName
  session.server.modelPrecache = session.client.modelPrecache
  session.server.soundPrecache = session.client.soundPrecache
  session.server.levelName = session.client.levelName
  destroyScene(session)
  if not session.headless then
    palette = qfs.readFile(session.filesystem, "gfx/palette.lmp")
    if palette is error then return palette end if
    videoState = glvid.VID_State()
    if videoState.initialized then palette = videoState.palette end if
    session.renderer = try(worldRenderer.create(worldModel, palette))
    if session.renderer is error then return session.renderer end if
    worldRenderer.R_SetMultitextureCompatibility(videoState.multitexture, false)
    session.entityRenderer = try(entityRenderer.create(session.filesystem, palette, session.client.modelPrecache))
    if session.entityRenderer is error then return session.entityRenderer end if
    if session.windowCreated then
      uploadedWorld = try(worldRenderer.upload(session.renderer))
      if uploadedWorld is error then return error(3935, "demo world upload: " + uploadedWorld.message) end if
      precachedEntities = try(entityRenderer.precache(session.entityRenderer))
      if precachedEntities is error then return error(3936, "demo entity precache: " + precachedEntities.message) end if
      session.width = win.width()
      session.height = win.height()
      initialized = try(screen.initialize(session.console, session.menu, session.filesystem, palette, session.width, session.height, session.cvars))
      if initialized is error then return initialized end if
    end if
  end if
  if session.mixer.enabled then
    mixer.stopAll(session.mixer)
    mixer.setListenerEntity(session.mixer, session.client.viewEntity)
  end if
  // Demo signon has the same complete model/sound precache tables as a live
  // connection.  Warm every renderer, temporary-effect and audio cache before
  // the first timed frame so a newly visible monster or projectile cannot
  // trigger synchronous parsing/upload work during playback.
  precached = try(precachePlayableLevel(session, cvar.variableValue(session.cvars, "developer")))
  if precached is error then return precached end if
  gc_collect()
  return true
end function

// Establish remote host using the active network transport.
function connectRemoteHost(session, hostName)
  if session.demoRecording is not void then stopDemoRecording(session) end if
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then Host_ShutdownServer(session, false) end if
  destroyScene(session)
  remoteClient = client.create(session.player)
  remoteClient.name = cvar.variableString(session.cvars, "_cl_name")
  remoteClient.colors = native.trunc(cvar.variableValue(session.cvars, "_cl_color"))
  remoteClient.localAuthoritative = false
  // Keep the control endpoint, not the ephemeral per-connection data port.
  // Host_Reconnect_f reconnects to cls.servername in the original engine.
  session.lastRemoteHost = hostName
  connected = client.connectHost(remoteClient, session.network, hostName)
  if connected is error then return connected end if
  session.client = remoteClient
  session.statusMessage = "connected to " + hostName
  print session.statusMessage
  return true
end function

// Establish remote host interop using the active network transport.
function connectRemoteHostInterop(session, hostName, timeoutMilliseconds, resendMilliseconds)
  if session.demoRecording is not void then stopDemoRecording(session) end if
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  session.demoNumber = -1
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then Host_ShutdownServer(session, false) end if
  destroyScene(session)
  remoteClient = client.create(session.player)
  remoteClient.name = cvar.variableString(session.cvars, "_cl_name")
  remoteClient.colors = native.trunc(cvar.variableValue(session.cvars, "_cl_color"))
  remoteClient.localAuthoritative = false
  session.lastRemoteHost = hostName
  connected = client.connectHostInterop(remoteClient, session.network, hostName, timeoutMilliseconds, resendMilliseconds)
  if connected is error then return connected end if
  session.client = remoteClient
  session.statusMessage = "connected to " + hostName
  print session.statusMessage
  return true
end function

// Report whether active server clients holds for the active state.
function activeServerClients(session)
  count = 0
  for each serverClient in session.server.clients
    if serverClient.active then count = count + 1 end if
  end for
  return count
end function

// Update subsystem configuration for configure network queries.
function configureNetworkQueries(session)
  players = []
  now = win.ticks() / 1000.0
  for each serverClient in session.server.clients
    if serverClient.active then
      address = "LOCAL"
      connectedSeconds = 0
      if serverClient.socket is not void then
        if serverClient.socket.transport == "udp" then address = serverClient.socket.address + ":" + serverClient.socket.port end if
        connectedSeconds = native.trunc(now - serverClient.socket.connectTime)
        if connectedSeconds < 0 then connectedSeconds = 0 end if
      end if
      frags = 0
      if session.server.machine is not void then frags = native.trunc(server.qcFloat(session.server.machine, serverClient.edictIndex, "frags", 0.0)) end if
      players = players + [[serverClient.name, serverClient.colors, frags, connectedSeconds, address]]
    end if
  end for
  rules = []
  for each variable in session.cvars.variables
    if variable.server then rules = rules + [[variable.name, variable.string]] end if
  end for
  return netloop.configureQueryData(session.network, players, rules)
end function

// Advance new connections by one processing step.
function pumpNewConnections(session)
  if session.network.listener is void or not session.server.active then return 0 end if
  netloop.configureServer(
    session.network,
    cvar.variableString(session.cvars, "hostname"),
    session.server.mapName,
    activeServerClients(session),
    session.server.maxClients,
  )
  configureNetworkQueries(session)
  accepted = 0
  iterations = 0
  while iterations < session.server.maxClients
    socket = try(netmain.NET_CheckNewConnections(session.network))
    if socket is error then return socket end if
    if socket is void then break end if
    connected = try(server.acceptLocal(session.server, socket))
    if connected is error then
      netmain.NET_Close(socket)
    else
      accepted = accepted + 1
    end if
    iterations = iterations + 1
  end while
  return accepted
end function

// Finalize state for finish demo playback.
function finishDemoPlayback(session)
  if session.demoPlayback is void then return false end if
  playback = session.demoPlayback
  demoPlayer.CL_StopPlayback(playback, session.timing.frameCount, session.timing.realtime)
  session.demoPlayback = void
  session.client.connected = false
  session.client.spawned = false
  if playback.finishResult is not void then
    print playback.finishResult[0] + " frames " + native.floatText(playback.finishResult[1]) + " seconds " + native.floatText(playback.finishResult[2]) + " fps"
  end if
  if session.timedemoActive then
    session.timedemoActive = false
  end if
  if session.demoNumber >= 0 and len(session.demoLoop) > 0 then nextDemo(session) end if
  return true
end function

// Advance demo playback by one processing step.
function stepDemoPlayback(session)
  playback = session.demoPlayback
  if playback is void then return 0 end if
  if playback.complete then finishDemoPlayback(session); return 0 end if
  parsed = demoPlayer.stepFrame(playback, session.timing.frameCount, session.timing.realtime, session.timing.frameTime)
  if parsed is error then finishDemoPlayback(session); return parsed end if
  if playback.complete then finishDemoPlayback(session) end if
  return parsed
end function

// Play demo through the active media subsystem.
function playDemo(session, requestedName, timed)
  name = demo.filename(requestedName)
  if name is error then return name end if
  source = qfs.readFile(session.filesystem, name)
  if source is error then return source end if
  recording = demo.CL_PlayDemo_f(source)
  if recording is error then return recording end if
  if session.demoRecording is not void then stopDemoRecording(session) end if
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then Host_ShutdownServer(session, false) end if
  destroyScene(session)
  // CL_ClearState/R_ClearParticles clear transient client effects when a demo
  // starts.  Session-owned arrays must not survive into the next recording in
  // a demo loop.
  session.particles = []
  session.temporaryEntities = []
  playback = demoPlayer.create(recording)
  playback.client.connected = true
  session.demoPlayback = playback
  session.client = playback.client
  session.player = playback.client.player
  session.timedemoActive = timed
  session.timedemoStartFrame = session.timing.frameCount
  session.timedemoStartTime = session.timing.realtime
  session.timedemoLastFrame = -1
  if timed then demoPlayer.CL_TimeDemo_f(playback, session.timing.frameCount) end if
  // Signon messages are consumed without frame pacing in CL_GetMessage.
  while not playback.complete and playback.client.signon < c.SIGNONS
    stepped = demoPlayer.stepFrame(playback, session.timing.frameCount, session.timing.realtime, 0.0)
    if stepped is error then session.demoPlayback = void; return stepped end if
  end while
  if playback.complete then finishDemoPlayback(session); return error(3728, "demo ended during signon") end if
  prepared = try(prepareDemoScene(session))
  if prepared is error then session.demoPlayback = void; return prepared end if
  print "Playing demo from " + name + "."
  return true
end function

// Provide network command address behavior for the active subsystem.
function networkCommandAddress(arguments)
  if len(arguments) == 2 then return arguments[1] end if
  if len(arguments) == 4 and arguments[2] == ":" then return arguments[1] + ":" + arguments[3] end if
  return ""
end function

// Apply the Quake-compatible host forward to server behavior.
function Host_ForwardToServer(session, text)
  if not session.client.connected or session.client.socket is void then return false end if
  return client.sendString(session.client, text + "\n") >= 0
end function

// Apply the Quake-compatible host disconnect f behavior.
function Host_Disconnect_f(session)
  // CL_Disconnect_f disconnects the client and explicitly shuts down a local
  // server as a second step.  Keep the explicit host shutdown even when the
  // client was already disconnected.
  if session.client.connected then client.disconnect(session.client) end if
  if session.server.active then Host_ShutdownServer(session, false) end if
  return true
end function

// Apply the Quake-compatible host quit f behavior.
function Host_Quit_f(session)
  dedicated = common.hasParm(session.arguments, "-dedicated")
  if not session.console.active and not dedicated then
    setMenuActive(session, true)
    menu.M_Menu_Quit_f(session.menu)
    return true
  end if
  Host_Disconnect_f(session)
  session.running = false
  return true
end function

// Apply the Quake-compatible host status f behavior.
function Host_Status_f(session)
  if not session.server.active then return Host_ForwardToServer(session, "status") end if
  print "host:    " + cvar.variableString(session.cvars, "hostname")
  print "version: " + c.QUAKE_VERSION
  print "map:     " + session.server.mapName
  active = activeServerClients(session)
  print "players: " + active + " active (" + session.server.maxClients + " max)"
  index = 0
  while index < len(session.server.clients)
    clientValue = session.server.clients[index]
    if clientValue.active then
      frags = 0
      if session.server.machine is not void then frags = native.trunc(server.qcFloat(session.server.machine, clientValue.edictIndex, "frags", 0.0)) end if
      seconds = 0
      address = "LOCAL"
      if clientValue.socket is not void then
        seconds = native.trunc(win.ticks() / 1000.0 - clientValue.socket.connectTime)
        if seconds < 0 then seconds = 0 end if
        if clientValue.socket.transport == "udp" then address = clientValue.socket.address + ":" + clientValue.socket.port end if
      end if
      minutes = native.trunc(seconds / 60)
      seconds = seconds - minutes * 60
      hours = native.trunc(minutes / 60)
      minutes = minutes - hours * 60
      print "#" + (index + 1) + " " + clientValue.name + " " + frags + " " + hours + ":" + minutes + ":" + seconds
      print "   " + address
    end if
    index = index + 1
  end while
  return true
end function

// Apply the Quake-compatible host god f behavior.
function Host_God_f(session)
  return Host_ForwardToServer(session, "god")
end function

// Apply the Quake-compatible host notarget f behavior.
function Host_Notarget_f(session)
  return Host_ForwardToServer(session, "notarget")
end function

// Apply the Quake-compatible host noclip f behavior.
function Host_Noclip_f(session)
  return Host_ForwardToServer(session, "noclip")
end function

// Apply the Quake-compatible host fly f behavior.
function Host_Fly_f(session)
  return Host_ForwardToServer(session, "fly")
end function

// Apply the Quake-compatible host ping f behavior.
function Host_Ping_f(session)
  return Host_ForwardToServer(session, "ping")
end function

// Apply the Quake-compatible host map f behavior.
function Host_Map_f(session, arguments)
  if len(arguments) < 2 then print "map <levelname> : start a new server"; return false end if
  requestedMap = server.cleanMapName(arguments[1])
  requestedPath = "maps/" + requestedMap + ".bsp"
  // A mistyped console command must be non-destructive.  Probe the search
  // path before stopping demos, disconnecting, drawing LOADING or destroying
  // the current renderer/server; the player can correct the name immediately.
  if session.filesystem is void or not qfs.fileExists(session.filesystem, requestedPath) then
    line = "Map \"" + requestedMap + "\" does not exist."
    console.appendLine(session.console, line)
    print line
    return false
  end if
  if session.demoRecording is not void then stopDemoRecording(session) end if
  // Host_Map_f sets cls.demonum to -1 before CL_Disconnect.  Doing this after
  // finishing playback lets CL_StopPlayback enqueue the next attract demo.
  session.demoNumber = -1
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  session.server.serverFlags = 0
  // host_cmd.c preserves every token following the map name in
  // cls.spawnparms and includes it in the subsequent "spawn" command.
  session.client.spawnParms = server.commandText(arguments, 2)
  return startMap(session, requestedMap)
end function

// Apply the Quake-compatible host changelevel f behavior.
function Host_Changelevel_f(session, arguments)
  if len(arguments) != 2 then print "changelevel <levelname> : continue game on a new level"; return false end if
  if session.demoPlayback is not void or not session.server.active then print "Only the server may changelevel"; return false end if
  return changeLevel(session, arguments[1])
end function

// Apply the Quake-compatible host restart f behavior.
function Host_Restart_f(session)
  if session.demoPlayback is not void or not session.server.active then return false end if
  return restartLevel(session, session.server.mapName)
end function

// Apply the Quake-compatible host reconnect f behavior.
function Host_Reconnect_f(session)
  // SCR_BeginLoadingPlaque begins with S_StopAllSounds(true) in WinQuake.
  if session.mixer is not void then mixer.stopAll(session.mixer) end if
  screen.SCR_BeginLoadingPlaque(
    session.console,
    session.timing.realtime,
    session.client.connected,
    session.client.signon,
  )
  session.client.signon = c.SIGNON_NONE
  session.client.spawned = false
  return true
end function

// Apply the Quake-compatible host connect f behavior.
function Host_Connect_f(session, arguments)
  remoteName = networkCommandAddress(arguments)
  if remoteName == "" then print "connect <server>"; return false end if
  session.demoNumber = -1
  connected = try(connectRemoteHost(session, remoteName))
  if connected is error then print connected.message; return false end if
  client.reconnect(session.client)
  return true
end function

// Apply the Quake-compatible host savegame f behavior.
function Host_Savegame_f(session, arguments)
  if len(arguments) != 2 then print "save <savename> : save a game"; return false end if
  saved = try(saveGame(session, arguments[1]))
  if saved is error then print saved.message; return false end if
  return true
end function

// Apply the Quake-compatible host loadgame f behavior.
function Host_Loadgame_f(session, arguments)
  if len(arguments) != 2 then print "load <savename> : load a game"; return false end if
  session.demoNumber = -1
  loaded = try(loadGame(session, arguments[1]))
  if loaded is error then print loaded.message; return false end if
  return true
end function

// Apply the Quake-compatible host changelevel2 f behavior.
function Host_Changelevel2_f(session, arguments)
  // QUAKE2-only in MiniQuake 1.09.  Retain the transition entry point while the
  // target build deliberately omits .gip hub-state semantics.
  return Host_Changelevel_f(session, arguments)
end function

// Apply the Quake-compatible host name f behavior.
function Host_Name_f(session, arguments)
  if len(arguments) == 1 then print "\"name\" is \"" + cvar.variableString(session.cvars, "_cl_name") + "\""; return true end if
  newName = server.commandText(arguments, 1)
  newName = server.truncateBytes(newName, 15)
  if cvar.variableString(session.cvars, "_cl_name") == newName then return true end if
  cvar.set(session.cvars, "_cl_name", newName)
  session.client.name = newName
  if session.client.connected then return Host_ForwardToServer(session, "name \"" + newName + "\"") end if
  return true
end function

// Apply the Quake-compatible host version f behavior.
function Host_Version_f()
  print "Version " + c.QUAKE_VERSION
  return true
end function

// Apply the Quake-compatible host please f behavior.
function Host_Please_f(session, arguments)
  // IDGODS-only in the reference.  The state is retained for faithful
  // privilege checks without enabling it automatically for public clients.
  targetIndex = -1
  if len(arguments) == 3 and arguments[1] == "#" then
    targetIndex = hostNumbers.playerIndex(arguments[2])
  else if len(arguments) == 2 then
    index = 0
    while index < len(session.server.clients)
      if session.server.clients[index].active and bio.equalInsensitive(session.server.clients[index].name, arguments[1]) then targetIndex = index; break end if
      index = index + 1
    end while
  end if
  if targetIndex < 0 or targetIndex >= len(session.server.clients) then return false end if
  target = session.server.clients[targetIndex]
  target.privileged = not target.privileged
  if not target.privileged and session.server.machine is not void then
    flags = native.trunc(server.qcFloat(session.server.machine, target.edictIndex, "flags", 0.0))
    server.setQcEntityFloat(session.server, target.edictIndex, "flags", flags & ~(c.FL_GODMODE | c.FL_NOTARGET))
    server.setQcEntityFloat(session.server, target.edictIndex, "movetype", c.MOVETYPE_WALK)
  end if
  return true
end function

// Apply the Quake-compatible host say behavior.
function Host_Say(session, arguments, teamOnly)
  if len(arguments) < 2 then return false end if
  commandName = "say"
  if teamOnly then commandName = "say_team" end if
  if common.hasParm(session.arguments, "-dedicated") then
    prefixData = bytes(1)
    prefixData[0] = 1
    prefix = decode(prefixData) + "<" + cvar.variableString(session.cvars, "hostname") + "> "
    server.broadcastPrint(session.server, prefix + server.truncateBytes(server.commandText(arguments, 1), 62 - len(bytes(prefix))) + "\n")
    return true
  end if
  return Host_ForwardToServer(session, commandName + " \"" + server.commandText(arguments, 1) + "\"")
end function

// Apply the Quake-compatible host say f behavior.
function Host_Say_f(session, arguments)
  return Host_Say(session, arguments, false)
end function

// Apply the Quake-compatible host say team f behavior.
function Host_Say_Team_f(session, arguments)
  return Host_Say(session, arguments, true)
end function

// Apply the Quake-compatible host tell f behavior.
function Host_Tell_f(session, arguments)
  if len(arguments) < 3 then return false end if
  return Host_ForwardToServer(session, "tell " + arguments[1] + " \"" + server.commandText(arguments, 2) + "\"")
end function

// Apply the Quake-compatible host color f behavior.
function Host_Color_f(session, arguments)
  if len(arguments) == 1 then
    colors = native.trunc(cvar.variableValue(session.cvars, "_cl_color"))
    print "\"color\" is \"" + (colors >> 4) + " " + (colors & 15) + "\""
    print "color <0-13> [0-13]"
    return true
  end if
  components = hostNumbers.colorArguments(arguments, 1)
  top = components[0]
  bottom = components[1]
  colors = top * 16 + bottom
  cvar.setValue(session.cvars, "_cl_color", colors)
  session.client.colors = colors
  if session.client.connected then return Host_ForwardToServer(session, "color " + top + " " + bottom) end if
  return true
end function

// Apply the Quake-compatible host kill f behavior.
function Host_Kill_f(session)
  return Host_ForwardToServer(session, "kill")
end function

// Apply the Quake-compatible host pause f behavior.
function Host_Pause_f(session)
  return Host_ForwardToServer(session, "pause")
end function

// Apply the Quake-compatible host pre spawn f behavior.
function Host_PreSpawn_f()
  print "prespawn is not valid from the console"
  return false
end function

// Apply the Quake-compatible host spawn f behavior.
function Host_Spawn_f()
  print "spawn is not valid from the console"
  return false
end function

// Apply the Quake-compatible host begin f behavior.
function Host_Begin_f()
  print "begin is not valid from the console"
  return false
end function

// Apply the Quake-compatible host kick f behavior.
function Host_Kick_f(session, arguments)
  if session.server.active then return server.Host_Kick_f(session.server, void, arguments) end if
  return Host_ForwardToServer(session, server.commandText(arguments, 0))
end function

// Apply the Quake-compatible host give f behavior.
function Host_Give_f(session, arguments)
  return Host_ForwardToServer(session, server.commandText(arguments, 0))
end function

// Return viewthing.
function FindViewthing(session)
  for each item in session.server.edicts
    // The original scans every edict without testing ent->free.  ED_Free
    // deliberately leaves classname intact, so preserve that observable quirk.
    if item is not void and item.className == "viewthing" then return item end if
  end for
  print "No viewthing on map"
  return void
end function

// Apply the Quake-compatible host viewmodel f behavior.
function Host_Viewmodel_f(session, arguments)
  if len(arguments) < 2 or session.entityRenderer is void then return false end if
  item = FindViewthing(session)
  if item is void then return false end if
  if item.modelIndex < 0 or item.modelIndex >= len(session.entityRenderer.models) then return false end if
  loaded = entityRenderer.loadModel(session.entityRenderer, arguments[1])
  if loaded.kind == 0 then print "Can't load " + arguments[1]; return false end if
  item.frame = 0
  if session.server.machine is not void then server.setQcEntityFloat(session.server, item.number, "frame", 0.0) end if
  session.entityRenderer.models[item.modelIndex] = loaded
  return true
end function

// Provide viewthing model behavior for the active subsystem.
function viewthingModel(session, item)
  if session.entityRenderer is void then return void end if
  if item.modelIndex < 0 or item.modelIndex >= len(session.entityRenderer.models) then return void end if
  return session.entityRenderer.models[item.modelIndex]
end function

// Apply the Quake-compatible host viewframe f behavior.
function Host_Viewframe_f(session, arguments)
  if len(arguments) < 2 then return false end if
  item = FindViewthing(session)
  if item is void then return false end if
  model = viewthingModel(session, item)
  if model is void or model.aliasModel is void then return false end if
  frame = hostNumbers.integer(arguments[1])
  if frame >= model.aliasModel.numFrames then frame = model.aliasModel.numFrames - 1 end if
  item.frame = frame
  if session.server.machine is not void then server.setQcEntityFloat(session.server, item.number, "frame", frame) end if
  return true
end function

// Format and emit frame name.
function PrintFrameName(model, frame)
  if model is void or model.aliasModel is void then return "" end if
  if frame < 0 or frame >= len(model.aliasModel.frames) then return "" end if
  frameSet = model.aliasModel.frames[frame]
  if len(frameSet.frames) == 0 then return "" end if
  text = "frame " + frame + ": " + frameSet.frames[0].name
  print text
  return text
end function

// Apply the Quake-compatible host viewnext f behavior.
function Host_Viewnext_f(session)
  item = FindViewthing(session)
  if item is void then return false end if
  model = viewthingModel(session, item)
  if model is void or model.aliasModel is void then return false end if
  item.frame = item.frame + 1
  if item.frame >= model.aliasModel.numFrames then item.frame = model.aliasModel.numFrames - 1 end if
  if session.server.machine is not void then server.setQcEntityFloat(session.server, item.number, "frame", item.frame) end if
  PrintFrameName(model, item.frame)
  return true
end function

// Apply the Quake-compatible host viewprev f behavior.
function Host_Viewprev_f(session)
  item = FindViewthing(session)
  if item is void then return false end if
  model = viewthingModel(session, item)
  if model is void or model.aliasModel is void then return false end if
  item.frame = item.frame - 1
  if item.frame < 0 then item.frame = 0 end if
  if session.server.machine is not void then server.setQcEntityFloat(session.server, item.number, "frame", item.frame) end if
  PrintFrameName(model, item.frame)
  return true
end function

// Return next demo for the active module state.
function nextDemo(session)
  if len(session.demoLoop) == 0 or session.demoNumber < 0 then return false end if
  if session.demoNumber >= len(session.demoLoop) then session.demoNumber = 0 end if
  name = session.demoLoop[session.demoNumber]
  session.demoNumber = session.demoNumber + 1
  return cmd.addText(session.commands, "playdemo " + name + "\n")
end function

// Stop attract playback before a user-selected game action. This also removes
// a next-demo command queued at the end of the preceding host frame.
function stopAttractMode(session)
  session.demoNumber = -1
  cmd.removeCommandsNamed(session.commands, "playdemo")
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  // Demo protocol side effects are deferred until the host presentation
  // phase. A menu selection can occur between parsing and that drain; never
  // carry those old sounds/prints/temporary effects into a new local game or
  // a loaded save's serverinfo packet.
  session.client.messages = []
  session.client.printLog = []
  session.particles = []
  session.temporaryEntities = []
  return true
end function

// Apply the Quake-compatible host startdemos f behavior.
function Host_Startdemos_f(session, arguments)
  if common.hasParm(session.arguments, "-dedicated") then
    if not session.server.active then cmd.addText(session.commands, "map start\n") end if
    return true
  end if
  count = len(arguments) - 1
  if count > 8 then print "Max 8 demos in demoloop"; count = 8 end if
  session.demoLoop = []
  index = 1
  while index <= count
    session.demoLoop = session.demoLoop + [arguments[index]]
    index = index + 1
  end while
  print count + " demo(s) in loop"
  // host_cmd.c arms cls.demonum at slot zero before deciding whether the
  // first demo can start immediately. The previous -1 guard prevented a
  // directory-only launch from ever entering the attract loop.
  session.demoNumber = 0
  // +map / validation starts are authoritative.  quake.rc is executed before
  // initialize() performs that direct map start in MiniQuake, so queuing
  // playdemo here would otherwise run after the requested map and tear down
  // the freshly spawned server.
  if session.startMap != "" or session.headless then
    session.demoNumber = -1
    return true
  end if
  if not session.server.active and session.demoPlayback is void then
    queued = nextDemo(session)
    if queued then return true end if
  end if
  session.demoNumber = -1
  return true
end function

// Apply the Quake-compatible host demos f behavior.
function Host_Demos_f(session)
  if common.hasParm(session.arguments, "-dedicated") then return false end if
  // MiniQuake resumes a stopped loop at slot one; CL_NextDemo wraps to zero if
  // the second slot is empty.
  if session.demoNumber == -1 then session.demoNumber = 1 end if
  if session.demoPlayback is not void then return finishDemoPlayback(session) end if
  if session.client.connected then client.disconnect(session.client) end if
  return nextDemo(session)
end function

// Apply the Quake-compatible host stopdemo f behavior.
function Host_Stopdemo_f(session)
  if common.hasParm(session.arguments, "-dedicated") or session.demoPlayback is void then return false end if
  session.demoNumber = -1
  finishDemoPlayback(session)
  client.disconnect(session.client)
  return true
end function

// Apply the Quake-compatible host edict f behavior.
function Host_Edict_f(session, arguments)
  if session.server.machine is void then print "No server running."; return false end if
  if len(arguments) != 2 then print "edict <number>"; return false end if
  value = common.atoi(arguments[1])
  output = try(qcedict.ED_Print(session.server.machine, value))
  if output is error then print output.message; return false end if
  print output
  return true
end function

// Apply the Quake-compatible host edicts f behavior.
function Host_Edicts_f(session)
  if session.server.machine is void then print "No server running."; return false end if
  index = 0
  while index < session.server.machine.context.edicts.numEdicts
    print qcedict.ED_PrintNum(session.server.machine, index)
    index = index + 1
  end while
  return true
end function

// Apply the Quake-compatible host edict count f behavior.
function Host_EdictCount_f(session)
  if session.server.machine is void then print "No server running."; return false end if
  counts = qcedict.ED_Count(session.server.machine)
  print "num_edicts:" + counts[0]
  print "active    :" + counts[1]
  print "view      :" + counts[2]
  print "touch     :" + counts[3]
  print "step      :" + counts[4]
  return true
end function

// Apply the Quake-compatible host profile f behavior.
function Host_Profile_f(session)
  if session.server.machine is void then print "No server running."; return false end if
  for each line in qcvm.PR_Profile_f(session.server.machine)
    print line
  end for
  return true
end function

// Apply the Quake-compatible host mod print behavior.
function Host_Mod_Print(session)
  count = 0
  index = 0
  while index < len(session.client.modelPrecache)
    name = session.client.modelPrecache[index]
    if name != "" then
      print index + " : " + name
      count = count + 1
    end if
    index = index + 1
  end while
  return count
end function

// Apply the Quake-compatible host flush cache f behavior.
function Host_FlushCache_f(session)
  // Cache_Flush makes purgeable alias/sprite data get loaded again on demand.
  // MiniQuake's GC-backed model cache has no hunk address to purge, so rebuild
  // the entity-model registry from the authoritative precache list.
  if session.entityRenderer is void then return true end if
  palette = qfs.readFile(session.filesystem, "gfx/palette.lmp")
  if palette is error then return palette end if
  videoState = glvid.VID_State()
  if videoState.initialized then palette = videoState.palette end if
  entityRenderer.destroy(session.entityRenderer)
  session.entityRenderer = entityRenderer.create(session.filesystem, palette, session.client.modelPrecache)
  return true
end function

// Apply the Quake-compatible host init commands behavior.
function Host_InitCommands()
  return [
    "status", "quit", "god", "notarget", "fly", "map", "restart",
    "changelevel", "connect", "reconnect", "name", "noclip", "version",
    "say", "say_team", "tell", "color", "kill", "pause", "spawn", "begin",
    "prespawn", "kick", "ping", "load", "save", "give", "startdemos",
    "demos", "stopdemo", "viewmodel", "viewframe", "viewnext", "viewprev",
    "mcache", "flush", "edict", "edicts", "edictcount", "profile",
  ]
end function

// Apply the Quake-compatible host dispatch command behavior.
function Host_DispatchCommand(session, text, arguments)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  name = bio.lower(arguments[0])
  if name == "status" then return Host_Status_f(session) end if
  if name == "quit" or name == "exit" then return Host_Quit_f(session) end if
  if name == "disconnect" then return Host_Disconnect_f(session) end if
  if name == "god" then return Host_God_f(session) end if
  if name == "notarget" then return Host_Notarget_f(session) end if
  if name == "noclip" then return Host_Noclip_f(session) end if
  if name == "fly" then return Host_Fly_f(session) end if
  if name == "ping" then return Host_Ping_f(session) end if
  if name == "map" then return Host_Map_f(session, arguments) end if
  if name == "changelevel" then return Host_Changelevel_f(session, arguments) end if
  if name == "changelevel2" then return Host_Changelevel2_f(session, arguments) end if
  if name == "restart" then return Host_Restart_f(session) end if
  if name == "reconnect" then return Host_Reconnect_f(session) end if
  if name == "connect" then return Host_Connect_f(session, arguments) end if
  if name == "save" then return Host_Savegame_f(session, arguments) end if
  if name == "load" then return Host_Loadgame_f(session, arguments) end if
  if name == "name" then return Host_Name_f(session, arguments) end if
  if name == "version" then return Host_Version_f() end if
  if name == "please" then return Host_Please_f(session, arguments) end if
  if name == "say" then return Host_Say_f(session, arguments) end if
  if name == "say_team" then return Host_Say_Team_f(session, arguments) end if
  if name == "tell" then return Host_Tell_f(session, arguments) end if
  if name == "color" then return Host_Color_f(session, arguments) end if
  if name == "kill" then return Host_Kill_f(session) end if
  if name == "pause" then return Host_Pause_f(session) end if
  if name == "prespawn" then return Host_PreSpawn_f() end if
  if name == "spawn" then return Host_Spawn_f() end if
  if name == "begin" then return Host_Begin_f() end if
  if name == "kick" then return Host_Kick_f(session, arguments) end if
  if name == "give" then return Host_Give_f(session, arguments) end if
  if name == "viewmodel" then return Host_Viewmodel_f(session, arguments) end if
  if name == "viewframe" then return Host_Viewframe_f(session, arguments) end if
  if name == "viewnext" then return Host_Viewnext_f(session) end if
  if name == "viewprev" then return Host_Viewprev_f(session) end if
  if name == "startdemos" then return Host_Startdemos_f(session, arguments) end if
  if name == "demos" then return Host_Demos_f(session) end if
  if name == "stopdemo" then return Host_Stopdemo_f(session) end if
  if name == "edict" then return Host_Edict_f(session, arguments) end if
  if name == "edicts" then return Host_Edicts_f(session) end if
  if name == "edictcount" then return Host_EdictCount_f(session) end if
  if name == "profile" then return Host_Profile_f(session) end if
  if name == "mcache" then Host_Mod_Print(session); return true end if
  if name == "flush" then return Host_FlushCache_f(session) end if
  return void
end function

// Execute command.
function executeCommand(session, text)
  arguments = cmd.tokenize(text)
  if len(arguments) == 0 then return false end if
  name = bio.lower(arguments[0])

  hostResult = Host_DispatchCommand(session, text, arguments)
  if hostResult is not void then return hostResult end if

  if name == "impulse" then
    if len(arguments) >= 2 then input.IN_Impulse(arguments[1]) else input.IN_Impulse("") end if
    return true
  end if
  if name == "force_centerview" then input.Force_CenterView_f(session.client.command); return true end if
  if name == "centerview" then
    view.V_StartPitchDrift(session.view, session.client.time, cvar.variableValue(session.cvars, "v_centerspeed"))
    return true
  end if
  if name == "v_cshift" then view.V_cshift_f(session.view, arguments); return true end if
  if name == "bf" then view.V_BonusFlash_f(session.view); return true end if
  if name == "joyadvancedupdate" then input.Joy_AdvancedUpdate_f(); return true end if
  if name == "gl_texturemode" then
    message = draw2d.Draw_TextureMode_f(arguments)
    print message
    return message != "bad filter name"
  end if
  if name == "sizeup" then screen.SCR_SizeUp_f(session.cvars); return true end if
  if name == "sizedown" then screen.SCR_SizeDown_f(session.cvars); return true end if
  if name == "screenshot" then
    if not session.windowCreated then print "SCR_ScreenShot_f: video is unavailable"; return false end if
    shot = try(screen.SCR_ScreenShot_f(session.filesystem, 0, 0, win.width(), win.height()))
    if shot is error then print shot.message; return false end if
    print "Wrote " + shot
    return true
  end if
  if name == "vid_restart" then
    if session.headless or not session.windowCreated then return error(3934, "vid_restart requires an active video device") end if
    restarted = restartRenderer(session, glvid.VID_RendererFromName(cvar.variableString(session.cvars, "vid_renderer")))
    if restarted is error then return restarted end if
    print glvid.VID_State().lastModeMessage
    return true
  end if
  if name == "+showscores" then statusbar.Sbar_ShowScores(); return true end if
  if name == "-showscores" then statusbar.Sbar_DontShowScores(); return true end if
  inputButton = input.commandButton(name)
  if inputButton is not void then
    keynum = void
    if bytes(name)[0] == 43 then keynum = -1 end if
    if len(arguments) >= 2 then
      parsedKey = toNumber(arguments[1])
      if parsedKey is not void then keynum = native.trunc(parsedKey) end if
    end if
    return input.dispatchInputCommand(name, keynum, 0)
  end if

  if name == "wait" then session.commands.wait = true; return true end if
  if name == "stuffcmds" then
    // Cmd_StuffCmds_f inserts command-line +commands at the exact point where
    // quake.rc requests them, ahead of the remaining startdemos command.
    cmd.insertText(session.commands, common.stuffCommands(session.arguments))
    return true
  end if
  if name == "echo" then print cmd.argsFrom(t.CommandSystem([], [], arguments, "", "", false), 1); return true end if
  if name == "exec" and len(arguments) >= 2 then
    script = try(qfs.readText(session.filesystem, arguments[1]))
    if script is error then print "couldn't exec " + arguments[1] else cmd.insertText(session.commands, script + "\n") end if
    return true
  end if
  if name == "alias" and len(arguments) == 1 then
    print "Current alias commands:"
    for each existingAlias in session.commands.aliases
      print existingAlias.name + " : " + existingAlias.value
    end for
    return true
  end if
  if name == "alias" and len(arguments) >= 2 then
    value = ""
    index = 2
    while index < len(arguments)
      if index > 2 then value = value + " " end if
      value = value + arguments[index]
      index = index + 1
    end while
    aliased = try(cmd.addAlias(session.commands, arguments[1], value))
    if aliased is error then print aliased.message; return false end if
    return true
  end if
  if name == "set" and len(arguments) >= 3 then
    variable = cvar.find(session.cvars, arguments[1])
    if variable is void then registerCvar(session.cvars, arguments[1], arguments[2], false, false) else cvar.set(session.cvars, arguments[1], arguments[2]) end if
    return true
  end if
  if name == "save" then
    if len(arguments) != 2 then print "save <savename> : save a game"; return false end if
    saved = try(saveGame(session, arguments[1]))
    if saved is error then print saved.message; return false end if
    return true
  end if
  if name == "load" then
    if len(arguments) != 2 then print "load <savename> : load a game"; return false end if
    loaded = try(loadGame(session, arguments[1]))
    if loaded is error then print loaded.message; return false end if
    return true
  end if
  if name == "writeconfig" then
    if writeConfiguration(session) then print "Wrote config.cfg"; return true end if
    print "Couldn't write config.cfg"
    return false
  end if
  if name == "record" then
    recorded = try(beginDemoRecording(session, arguments))
    if recorded is error then print recorded.message; return false end if
    return true
  end if
  if name == "stop" then
    stopped = try(stopDemoRecording(session))
    if stopped is error then print stopped.message; return false end if
    return true
  end if
  if name == "playdemo" then
    if len(arguments) != 2 then print "playdemo <demoname> : plays a demo"; return false end if
    played = try(playDemo(session, arguments[1], false))
    if played is error then print played.message; return false end if
    return true
  end if
  if name == "timedemo" then
    if len(arguments) != 2 then print "timedemo <demoname> : gets demo speeds"; return false end if
    played = try(playDemo(session, arguments[1], true))
    if played is error then print played.message; return false end if
    return true
  end if
  if name == "connect" then
    remoteName = networkCommandAddress(arguments)
    // COM_Parse tokenizes ':' as punctuation. Accept the unquoted address
    // form produced by +connect on the command line as well.
    if remoteName == "" then print "connect <server>"; return false end if
    connected = try(connectRemoteHost(session, remoteName))
    if connected is error then print connected.message; return false end if
    return true
  end if
  if name == "reconnect" then
    if client.reconnect(session.client) then return true end if
    if session.lastRemoteHost == "" then print "No previous server."; return false end if
    connected = try(connectRemoteHost(session, session.lastRemoteHost))
    if connected is error then print connected.message; return false end if
    return true
  end if
  if name == "listen" then
    if len(arguments) == 1 then print "\"listen\" is \"" + netmain.listening + "\""; return true end if
    requested = toNumber(arguments[1])
    if requested is void then print "listen <0|1>"; return false end if
    enabled = requested != 0
    result = try(netmain.NET_Listen_f(session.network, enabled, netmain.net_hostport))
    if result is error then print result.message; return false end if
    return true
  end if
  if name == "maxplayers" then
    if len(arguments) == 1 then print "\"maxplayers\" is \"" + session.server.maxClients + "\""; return true end if
    requested = toNumber(arguments[1])
    if requested is void then print "maxplayers <count>"; return false end if
    changed = netmain.MaxPlayers_f(session.server.maxClients, c.MAX_CLIENTS, session.server.active, native.trunc(requested))
    if changed[3] != "" then print changed[3] end if
    if changed[0] != session.server.maxClients then
      resized = try(server.resizeClients(session.server, changed[0]))
      if resized is error then print resized.message; return false end if
      netmain.NET_SetMaximumClients(resized)
    end if
    deathmatchText = "0"
    if changed[2] then deathmatchText = "1" end if
    cvar.set(session.cvars, "deathmatch", deathmatchText)
    if changed[1] != netmain.listening then netmain.NET_Listen_f(session.network, changed[1], netmain.net_hostport) end if
    return true
  end if
  if name == "port" then
    if len(arguments) == 1 then print "\"port\" is \"" + netmain.net_hostport + "\""; return true end if
    requested = toNumber(arguments[1])
    if requested is void then print "port <number>"; return false end if
    changed = try(netmain.NET_Port_f(session.network, native.trunc(requested)))
    if changed is error then print changed.message; return false end if
    return true
  end if
  if name == "slist" then
    netmain.NET_Slist_f(session.network, false, true, netmain.net_hostport)
    for each line in netmain.PrintSlistHeader()
      print line
    end for
    while netmain.slistInProgress
      netmain.NET_Poll()
      win.sleep(1)
    end while
    for each line in netmain.PrintSlist()
      print line
    end for
    for each line in netmain.PrintSlistTrailer()
      print line
    end for
    return true
  end if
  if name == "net_stats" then
    channels = void
    if len(arguments) >= 2 then
      channels = []
      for each socket in session.network.remoteSockets
        if socket.channel is not void and (arguments[1] == "*" or bio.lower(arguments[1]) == bio.lower(socket.address)) then
          channels = channels + [socket.channel]
        end if
      end for
    end if
    print netDatagram.NET_Stats_f(
      channels,
      netmain.messagesSent,
      netmain.messagesReceived,
      netmain.unreliableMessagesSent,
      netmain.unreliableMessagesReceived,
    )
    return true
  end if
  if name == "ban" then
    result = netloop.NET_Ban_f(session.network, arguments)
    if result != "" then print result end if
    return true
  end if
  if name == "test" then
    remoteName = networkCommandAddress(arguments)
    if remoteName == "" then print "test <host>"; return false end if
    result = try(netloop.Test_f(remoteName, session.server.maxClients, 2000))
    if result is error then print result.message; return false end if
    for each playerInfo in result
      print playerInfo[1] + " frags:" + playerInfo[3] + " colors:" + playerInfo[2] + " time:" + playerInfo[4] + " " + playerInfo[5]
    end for
    return true
  end if
  if name == "test2" then
    remoteName = networkCommandAddress(arguments)
    if remoteName == "" then print "test2 <host>"; return false end if
    result = try(netloop.Test2_f(remoteName, 2000))
    if result is error then print result.message; return false end if
    for each rule in result
      print rule[0] + " " + rule[1]
    end for
    return true
  end if
  if name == "cd" then
    if session.headless or common.hasParm(session.arguments, "-nocdaudio") then return false end if
    cdState = cdAudio.ensure(session.mixer)
    response = cdAudio.CD_f(cdState, arguments)
    if response != "" then print response end if
    return true
  end if
  if (name == "play" or name == "playvol" or name == "stopsound" or name == "soundlist" or name == "soundinfo" or name == "musicinfo") and (session.headless or common.hasParm(session.arguments, "-nosound")) then return false end if
  if name == "play" then
    played = try(mixer.play(session.mixer, arguments))
    if played is error then print played.message; return false end if
    return true
  end if
  if name == "playvol" then
    played = try(mixer.playVol(session.mixer, arguments))
    if played is error then print played.message; return false end if
    return true
  end if
  if name == "stopsound" then mixer.stopAll(session.mixer); return true end if
  if name == "soundlist" then
    soundEntries = mixer.soundList(session.mixer)
    for each soundEntry in soundEntries[0]
      loopMarker = " "
      if soundEntry[0] then loopMarker = "L" end if
      print loopMarker + "(" + soundEntry[1] + "b) " + soundEntry[2] + " : " + soundEntry[3]
    end for
    print "Total resident: " + soundEntries[1]
    return true
  end if
  if name == "soundinfo" then
    for each soundField in mixer.soundInfo(session.mixer)
      print soundField[0] + " " + soundField[1]
    end for
    return true
  end if
  if name == "musicinfo" then
    for each musicField in mixer.musicInfo(session.mixer)
      print musicField[0] + " " + musicField[1]
    end for
    return true
  end if
  if name == "map" and len(arguments) >= 2 then
    if session.demoRecording is not void then stopDemoRecording(session) end if
    if session.demoPlayback is not void then finishDemoPlayback(session) end if
    return startMap(session, arguments[1])
  end if
  if name == "changelevel" and len(arguments) >= 2 then
    if session.demoPlayback is not void or not session.server.active then print "Only the server may changelevel"; return false end if
    return changeLevel(session, arguments[1])
  end if
  if name == "restart" then return Host_Restart_f(session) end if
  if name == "disconnect" then return Host_Disconnect_f(session) end if
  if name == "quit" or name == "exit" then return Host_Quit_f(session) end if
  if name == "pause" then session.server.paused = not session.server.paused; return true end if
  if name == "noclip" then
    session.player.noclip = not session.player.noclip
    if session.player.noclip then session.player.moveType = c.MOVETYPE_NOCLIP else session.player.moveType = c.MOVETYPE_WALK end if
    if session.server.machine is not void and len(session.server.clients) > 0 then
      server.setQcEntityFloat(session.server, session.server.clients[0].edictIndex, "movetype", session.player.moveType)
    end if
    print "noclip " + session.player.noclip
    return true
  end if
  if name == "god" then
    enabled = not playerFlagEnabled(session, c.FL_GODMODE)
    setPlayerFlag(session, c.FL_GODMODE, enabled)
    print "godmode " + enabled
    return true
  end if
  if name == "notarget" then
    enabled = not playerFlagEnabled(session, c.FL_NOTARGET)
    setPlayerFlag(session, c.FL_NOTARGET, enabled)
    print "notarget " + enabled
    return true
  end if
  if name == "fly" then
    if session.player.moveType == c.MOVETYPE_FLY then session.player.moveType = c.MOVETYPE_WALK else session.player.moveType = c.MOVETYPE_FLY end if
    session.player.noclip = false
    if session.server.machine is not void and len(session.server.clients) > 0 then
      server.setQcEntityFloat(session.server, session.server.clients[0].edictIndex, "movetype", session.player.moveType)
    end if
    print "flymode " + (session.player.moveType == c.MOVETYPE_FLY)
    return true
  end if
  if name == "name" then
    if len(arguments) == 1 then print "\"" + cvar.variableString(session.cvars, "_cl_name") + "\""; return true end if
    newName = arguments[1]
    cvar.set(session.cvars, "_cl_name", newName)
    session.client.name = newName
    if len(session.server.clients) > 0 then session.server.clients[0].name = newName end if
    return true
  end if
  if name == "color" then
    if len(arguments) == 1 then print "" + cvar.variableValue(session.cvars, "_cl_color"); return true end if
    colorParts = hostNumbers.colorArguments(arguments, 1)
    top = colorParts[0]
    bottom = colorParts[1]
    colors = (top << 4) | bottom
    cvar.setValue(session.cvars, "_cl_color", colors)
    session.client.colors = colors
    if len(session.server.clients) > 0 then session.server.clients[0].colors = colors end if
    return true
  end if
  if name == "kill" then
    if session.server.machine is not void and len(session.server.clients) > 0 then
      server.executeQcFunction(session.server, "ClientKill", session.server.clients[0].edictIndex, 0)
      server.syncPlayerFromQuakeC(session.server, session.server.clients[0], session.player)
    else
      session.player.health = 0.0
    end if
    return true
  end if
  if name == "version" then print "Version " + c.QUAKE_VERSION; return true end if
  if name == "vid_nummodes" then print glvid.VID_NumModes_f(); return true end if
  if name == "vid_describecurrentmode" then print glvid.VID_DescribeCurrentMode_f(); return true end if
  if name == "vid_describemode" then print glvid.VID_DescribeMode_f(arguments); return true end if
  if name == "vid_describemodes" then
    for each description in glvid.VID_DescribeModes_f()
      print description
    end for
    return true
  end if
  if name == "toggleconsole" then
    screen.SCR_EndLoadingPlaque(session.console)
    destination = console.Con_ToggleConsole_f(session.console, session.client.connected)
    if destination == "menu" then
      setMenuActive(session, true)
    else
      setConsoleActive(session, destination == "console")
    end if
    return true
  end if
  if name == "togglemenu" then toggleMenu(session); return true end if
  if name == "menu_main" then setMenuActive(session, true); menu.M_Menu_Main_f(session.menu); return true end if
  if name == "menu_singleplayer" then setMenuActive(session, true); menu.M_Menu_SinglePlayer_f(session.menu); return true end if
  if name == "menu_load" then setMenuActive(session, true); menu.M_Menu_Load_f(session.menu); refreshSaveSlots(session); return true end if
  if name == "menu_save" then
    if menu.M_Menu_Save_f(session.menu, session.server.active, screen.SCR_IntermissionMode(), session.server.maxClients) then
      setMenuActive(session, true)
      refreshSaveSlots(session)
    end if
    return true
  end if
  if name == "menu_multiplayer" then setMenuActive(session, true); menu.M_Menu_MultiPlayer_f(session.menu); return true end if
  if name == "menu_setup" then setMenuActive(session, true); menu.M_Menu_Setup_f(session.menu, session.cvars); return true end if
  if name == "menu_options" then setMenuActive(session, true); menu.M_Menu_Options_f(session.menu); return true end if
  if name == "menu_keys" then setMenuActive(session, true); menu.M_Menu_Keys_f(session.menu); return true end if
  if name == "menu_video" then setMenuActive(session, true); menu.M_Menu_Video_f(session.menu); return true end if
  if name == "help" then setMenuActive(session, true); menu.M_Menu_Help_f(session.menu); return true end if
  if name == "menu_quit" then setMenuActive(session, true); menu.M_Menu_Quit_f(session.menu); return true end if
  if name == "messagemode" then
    console.Con_MessageMode_f(session.console)
    setMenuActive(session, false)
    setConsoleActive(session, false)
    keys.beginMessage(false)
    return true
  end if
  if name == "messagemode2" then
    console.Con_MessageMode2_f(session.console)
    setMenuActive(session, false)
    setConsoleActive(session, false)
    keys.beginMessage(true)
    return true
  end if
  if name == "clear" then return console.Con_Clear_f(session.console) end if
  if name == "con_print" then return console.Con_Print_f(session.console, arguments) end if
  if name == "status" then
    print "map: " + session.server.mapName
    print "time: " + session.server.time
    print "origin: " + session.player.origin.x + " " + session.player.origin.y + " " + session.player.origin.z
    return true
  end if
  if name == "bind" then
    message = keys.Key_Bind_f(arguments)
    if message != "" then print message end if
    return len(arguments) == 2 or len(arguments) == 3
  end if
  if name == "unbind" then
    message = keys.Key_Unbind_f(arguments)
    if message != "" then print message end if
    return message == ""
  end if
  if name == "unbindall" then return keys.Key_Unbindall_f() end if
  if name == "bindlist" then
    listing = keys.Key_Bindlist_f()
    if listing != "" then print listing end if
    return true
  end if
  alias = findAlias(session.commands, name)
  if alias is not void then cmd.insertText(session.commands, alias.value); return true end if
  if cvarCommand(session, arguments) then return true end if
  if cvar.variableValue(session.cvars, "developer") != 0.0 then print "Unknown command \"" + arguments[0] + "\"" end if
  return false
end function

// Execute command buffer.
function executeCommandBuffer(session, maximumCommands)
  executed = 0
  session.commands.wait = false
  while len(session.commands.text) > 0 and executed < maximumCommands
    split = cmd.splitFirstCommand(session.commands.text)
    session.commands.text = split[1]
    commandResult = try(executeCommand(session, split[0]))
    executed = executed + 1
    if commandResult is error then
      screen.SCR_EndLoadingPlaque(session.console)
      if session.statusMessage != commandResult.message then
        session.statusMessage = commandResult.message
        console.appendLine(session.console, commandResult.message)
        print commandResult.message
      end if
      break
    end if
    if session.commands.wait then break end if
  end while
  return executed
end function

// Add state for queue startup commands.
function queueStartupCommands(session)
  if qfs.fileExists(session.filesystem, "quake.rc") then
    cmd.addText(session.commands, "exec quake.rc\n")
  else
    if qfs.fileExists(session.filesystem, "default.cfg") then cmd.addText(session.commands, "exec default.cfg\n") end if
    if qfs.fileExists(session.filesystem, "config.cfg") then cmd.addText(session.commands, "exec config.cfg\n") end if
    if qfs.fileExists(session.filesystem, "autoexec.cfg") then cmd.addText(session.commands, "exec autoexec.cfg\n") end if
    // A data set without quake.rc has no embedded stuffcmds command.
    cmd.addText(session.commands, common.stuffCommands(session.arguments))
  end if
  return true
end function

// Apply the Quake-compatible host init behavior.
function Host_Init(session)
  // MiniLang's default small-object threshold runs a complete mark/sweep
  // collection after 8 MiB of tiny allocations. Scanning Quake's live map,
  // VM and renderer graph in the middle of Host_Frame creates visible
  // 50-200 ms pauses. MiniQuake owns a 2 GiB reserved/committed heap and explicit safe
  // collection points in diagnostic/validation flows; allocation-failure GC
  // remains enabled by the runtime.
  gc_set_limit(0)
  // An empty requested map is meaningful: --play BASEDIR asks quake.rc to
  // start the retail attract demos and show the menu over their playback.
  attractStartup = session.startMap == ""
  localInit = try(Host_InitLocal(session))
  if localInit is error then return localInit end if
  vcrInit = try(Host_InitVCR(session))
  if vcrInit is error then return vcrInit end if
  print "MiniQuake " + c.QUAKE_VERSION + " / protocol " + c.PROTOCOL_VERSION
  print common.describe(session.arguments)
  print qfs.describe(session.filesystem)
  console.appendLine(session.console, "MiniQuake " + c.QUAKE_VERSION)
  if not session.headless then
    palette = try(qfs.readFile(session.filesystem, "gfx/palette.lmp"))
    if palette is error then return palette end if
    video = try(glvid.VID_Init(session.arguments, session.cvars, palette, true))
    if video is error then return video end if
    // gl_vidnt.c owns focus-driven S_BlockSound/S_UnblockSound calls.
    glvid.VID_SetSoundMixer(session.mixer)
    session.width = video.width
    session.height = video.height
    session.fullscreen = video.modeState == glvid.MS_FULLDIB
    session.windowCreated = true
    menu.M_SetVideoCallbacks(session.menu, glvid.VID_MenuDrawCallback, glvid.VID_MenuKeyCallback)
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
      glvid.VID_SynchronizeSoundFocus()
      // Menu feedback must be available before the first game event.  These
      // effects remain cached when the current level sound list is precached.
      mixer.precache(session.mixer, ["misc/menu1.wav", "misc/menu2.wav", "misc/menu3.wav"])
      cdState = cdAudio.ensure(session.mixer)
      if common.hasParm(session.arguments, "-nocdaudio") then
        cdState.enabled = false
        cdState.valid = false
      end if
    end if
  end if

  requestedPort = common.integerOption(session.arguments, "-port", 26000)
  udpDisabled = common.hasParm(session.arguments, "-nolan") or common.hasParm(session.arguments, "-noudp")
  winsInitialized = try(netwins.WINS_Init(
    cvar.variableString(session.cvars, "hostname"),
    udpDisabled,
    common.parmValue(session.arguments, "-ip", ""),
    requestedPort,
  ))
  if winsInitialized is error then return winsInitialized end if
  if winsInitialized != -1 then cvar.set(session.cvars, "hostname", netwins.configuredHostname) end if
  netInitialized = try(netmain.NET_Init(
    session.network,
    session.server.maxClients,
    common.hasParm(session.arguments, "-dedicated"),
    common.hasParm(session.arguments, "-listen"),
    requestedPort,
    udpDisabled,
  ))
  if netInitialized is error then return netInitialized end if
  if session.network.listener is not void then
    print "UDP listening on port " + session.network.listener.port
  end if

  queueStartupCommands(session)
  executeCommandBuffer(session, 4096)
  if not session.headless and session.windowCreated then
    if glvid.VID_ApplyConfiguredRenderer() then print glvid.VID_State().lastModeMessage end if
    if glvid.VID_ApplyConfiguredResolution() then print glvid.VID_State().lastModeMessage end if
    session.width = win.width()
    session.height = win.height()
  end if

  // The strict original-binary interop client must connect before the
  // standalone fallback can start a local map or demo.  Normal launches do
  // not carry this private option and therefore retain their exact behavior.
  originalInteropTarget = common.parmValue(session.arguments, "-original-interop-target", "")
  if originalInteropTarget != "" and not session.server.active and session.demoPlayback is void and not session.client.connected then
    print "MiniQuake original interop pre-fallback connect"
    print "  target=" + originalInteropTarget + " local_server_active=false"
    interopConnected = try(connectRemoteHostInterop(session, originalInteropTarget, 20000, 500))
    if interopConnected is error then return interopConnected end if
  end if

  if not session.server.active and session.demoPlayback is void and not session.client.connected then
    fallbackMap = session.startMap
    if fallbackMap == "" and qfs.fileExists(session.filesystem, "maps/start.bsp") then fallbackMap = "start" end if
    if fallbackMap != "" then
      // A missing/corrupt demo must not leave a half-armed loop that can fire
      // after the fallback level ends.
      if attractStartup then session.demoNumber = -1 end if
      started = try(startMap(session, fallbackMap))
      if started is error then return started end if
    end if
  end if
  if attractStartup and not session.headless and (session.demoPlayback is not void or session.server.active) then
    setMenuActive(session, true)
    menu.M_Menu_Main_f(session.menu)
  end if
  session.lastTicks = win.ticks()
  session.timing.oldRealtime = 0.0
  session.initialized = true
  return session
end function

// Initialize state for initialize.
function initialize(session)
  return Host_Init(session)
end function

// Consume pending state for consume client events.
function consumeClientEvents(session)
  pending = client.consumeMessages(session.client)
  processable = []
  for each item in pending
    suppress = false
    if item.command == "svc_stufftext" and session.server.active and session.client.connected and session.client.signon == c.SIGNONS then
      // SV_SpawnServer sends every preserved client "reconnect\n" before it
      // builds the replacement server.  MiniQuake completes its local
      // loopback signon synchronously inside transitionMap; by the time this
      // queued stufftext reaches CL_NextDemo/command execution it is stale.
      // Executing it again resets the already-active client to signon 0 and
      // leaves SCR_BeginLoadingPlaque frozen over the new map.  Remote clients
      // and incomplete local signons still consume the original command.
      if item.payload == "reconnect\n" then suppress = true end if
    end if
    if item.command == "svc_cdtrack" and session.mixer.enabled and not common.hasParm(session.arguments, "-nocdaudio") then
      track = item.payload[0]
      if session.demoPlayback is not void and session.demoPlayback.recording.forcedTrack != -1 then
        track = session.demoPlayback.recording.forcedTrack
      else if session.demoRecording is not void and session.demoRecording.forcedTrack != -1 then
        track = session.demoRecording.forcedTrack
      end if
      cdState = cdAudio.ensure(session.mixer)
      played = try(cdAudio.CDAudio_Play(cdState, track, true))
      if played is error then
        line = "CDAudio: " + played.message
        console.appendLine(session.console, line)
        print line
      else if not played then
        line = cdState.lastMessage
        if line == "" then line = "CDAudio: could not play track " + track end if
        console.appendLine(session.console, line)
        print line
      end if
    else if item.command == "svc_centerprint" then
      screen.SCR_CenterPrint(void, item.payload, session.client.time)
    else if item.command == "svc_intermission" then
      screen.SCR_SetIntermission(1, "", session.console, session.client.time)
    else if item.command == "svc_finale" then
      screen.SCR_SetIntermission(2, item.payload, session.console, session.client.time)
    else if item.command == "svc_cutscene" then
      screen.SCR_SetIntermission(3, item.payload, session.console, session.client.time)
    end if
    if not suppress then processable = processable + [item] end if
  end for
  result = clientEffects.process(
    processable,
    session.client,
    session.player,
    session.mixer,
    session.view,
    session.console,
    session.commands,
    session.particles,
    session.temporaryEntities,
    session.client.time,
    session.cvars,
  )
  session.particles = result[0]
  session.temporaryEntities = result[1]
  return len(pending)
end function

// Update module state for client relink models.
function synchronizeClientRelinkModels(session)
  targetCount = len(session.client.modelPrecache)
  modelsChanged = false
  if session.entityRenderer is not void then
    oldModelCount = len(session.entityRenderer.models)
    entityRenderer.synchronize(session.entityRenderer, session.client.modelPrecache)
    modelsChanged = oldModelCount < targetCount
  end if
  currentFlags = client.CL_ModelFlags()
  currentSyncTypes = client.CL_ModelSyncTypes()
  // Model precaches are immutable between serverinfo messages. Once the
  // renderer and the two relink lookup tables cover the current precache,
  // rebuilding both arrays every Host_Frame only creates garbage.
  if not modelsChanged and len(currentFlags) == targetCount and len(currentSyncTypes) == targetCount then
    client.CL_SetChaseActive(cvar.variableValue(session.cvars, "chase_active") != 0.0)
    return targetCount
  end if
  flags = arrayutil.makeFilledArray(targetCount, 0)
  syncTypes = arrayutil.makeFilledArray(targetCount, c.ST_SYNC)
  if session.entityRenderer is not void then
    index = 0
    while index < len(flags) and index < len(session.entityRenderer.models)
      model = session.entityRenderer.models[index]
      if model is not void and model.aliasModel is not void then
        flags[index] = model.aliasModel.flags
        syncTypes[index] = model.aliasModel.syncType
      else if model is not void and model.spriteModel is not void then
        syncTypes[index] = model.spriteModel.syncType
      end if
      index = index + 1
    end while
  end if
  client.CL_SetModelFlags(flags)
  client.CL_SetModelSyncTypes(syncTypes)
  client.CL_SetChaseActive(cvar.variableValue(session.cvars, "chase_active") != 0.0)
  return len(flags)
end function

// Consume pending state for consume relink particle effects.
function consumeRelinkParticleEffects(session)
  effects = client.CL_TakeRelinkParticleEffects()
  for each item in effects
    if item.command == "entity_particles" then
      session.particles = particles.entityParticlesInto(session.particles, item.payload, session.client.time)
    else if item.command == "rocket_trail" then
      session.particles = particles.rocketTrailInto(
        session.particles,
        item.payload[0],
        item.payload[1],
        item.payload[2],
        session.client.time,
      )
    end if
  end for
  return len(effects)
end function

// Consume pending state for consume quake ccontrol.
function consumeQuakeCControl(session)
  opt001dCvarDeveloper = cvar.variableValue(session.cvars, "developer")
  count = 0
  for each line in session.server.diagnostics
    source = bytes(line)
    if len(source) >= 10 and decode(slice(source, 0, 10)) == "SYS_PRINT:" then
      sysLine = decode(slice(source, 10, len(source) - 10))
      if common.hasParm(session.arguments, "-dedicated") then print sysLine end if
    else
      console.append(session.console, line)
      if opt001dCvarDeveloper != 0.0 then print line end if
    end if
    count = count + 1
  end for
  session.server.diagnostics = []
  if session.server.machine is void or session.server.machine.context is void then return count end if
  contextValue = session.server.machine.context
  for each line in contextValue.consoleLines
    console.append(session.console, line)
    if opt001dCvarDeveloper != 0.0 then print line end if
    count = count + 1
  end for
  contextValue.consoleLines = []
  // PF_changelevel mirrors the original C builtin and has already appended
  // exactly one changelevel command to the host command buffer.  Keep its
  // context marker set for the lifetime of this server, just like the C
  // builtin's spawn-count guard.  Re-appending and clearing it here made a
  // QuakeC exit execute the transition twice on the following frame: the first
  // reached the new map, then the second left its loading plaque over it.
  return count
end function

// Play local sound through the active media subsystem.
function playLocalSound(session, name)
  if session.mixer is void or not session.mixer.enabled then return false end if
  played = try(mixer.localSound(session.mixer, name))
  if played is error then return false end if
  return played
end function

// Play menu sound through the active media subsystem.
function playMenuSound(session, name)
  if session.mixer is void or not session.mixer.enabled then return false end if
  result = try(mixer.localSound(session.mixer, name))
  if result is error then return false end if
  return result
end function

// console.c performs these two effects synchronously from Con_Print/Con_Printf.
// MiniLang records them on ConsoleState so the host can invoke the production
// audio and screen paths without creating a console<->host import cycle.
function consumeConsoleSideEffects(session)
  if session.console.talkSoundRequested then
    session.console.talkSoundRequested = false
    if session.mixer is not void and session.mixer.enabled then
      played = try(mixer.localSound(session.mixer, "misc/talk.wav"))
      if played is error and cvar.variableValue(session.cvars, "developer") != 0.0 then print played.message end if
    end if
  end if

  forceScreen = session.console.updateRequested and session.client.signon != c.SIGNONS
  session.console.updateRequested = false
  return forceScreen
end function

// Update module state for menu active.
function setMenuActive(session, active)
  wasActive = session.menu.active
  // Some exact menu handlers clear MenuState.active before returning "close".
  // KEY_MENU and pausedByMenu still prove that the menu owned input, so retain
  // the gameplay-transition gate even on that action-driven close path.
  menuOwnedInput = wasActive or keys.destination() == keys.KEY_MENU or session.menu.pausedByMenu
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
    if menuOwnedInput and session.windowCreated then
      input.IN_BlockGameplayTransition()
      input.clear(session.client.command)
      keys.Key_ClearStates()
    end if
    if session.menu.pausedByMenu then
      session.server.paused = false
      session.menu.pausedByMenu = false
    end if
    menu.setActive(session.menu, false)
  end if
  if active then
    keys.setDestination(keys.KEY_MENU)
  else if session.console.active then
    keys.setDestination(keys.KEY_CONSOLE)
  else
    keys.setDestination(keys.KEY_GAME)
  end if
  updateMouseCapture(session)
  if menuOwnedInput and not active and session.initialized then writeConfiguration(session) end if
  return active
end function

// menu.c::M_ToggleMenu_f returns from a submenu to the main menu before it
// closes the menu. Keep this distinct from explicit action-driven closes.
function toggleMenu(session)
  if session.menu.active and session.menu.page != menu.PAGE_MAIN then
    menu.M_Menu_Main_f(session.menu)
    keys.setDestination(keys.KEY_MENU)
    updateMouseCapture(session)
    return true
  end if
  return setMenuActive(session, not session.menu.active)
end function

// Update module state for console active.
function setConsoleActive(session, active)
  // Con_ToggleConsole_f mutates ConsoleState.active before returning its next
  // destination. consoleVisible and KEY_CONSOLE therefore preserve ownership
  // of the old input context when this helper receives active=false.
  consoleOwnedInput = session.console.active or session.consoleVisible or keys.destination() == keys.KEY_CONSOLE
  if active and session.menu.active then setMenuActive(session, false) end if
  if not active and consoleOwnedInput and session.windowCreated then
    // ENTER is both the console submit key and a stock +jump binding. Native
    // press edges are intentionally retained while gameplay polling is off;
    // discard those console-owned edges before the first gameplay frame so a
    // previously submitted command cannot become a delayed jump.
    input.IN_BlockGameplayTransition()
    input.clear(session.client.command)
    keys.Key_ClearStates()
  end if
  console.setActive(session.console, active)
  session.consoleVisible = active
  if active then
    keys.setDestination(keys.KEY_CONSOLE)
  else if session.menu.active then
    keys.setDestination(keys.KEY_MENU)
  else
    keys.setDestination(keys.KEY_GAME)
  end if
  updateMouseCapture(session)
  return active
end function

// Provide adjust menu option behavior for the active subsystem.
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
    // WinQuake's Windows options menu changes CD volume by a full unit.
    value = math.clamp(cvar.variableValue(session.cvars, "bgmvolume") + direction * 1.0, 0.0, 1.0)
    cvar.setValue(session.cvars, "bgmvolume", value)
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
  if changed and session.initialized then writeConfiguration(session) end if
  return changed
end function

// Execute menu selection.
function executeMenuSelection(session)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  action = menu.selectedCommand(session.menu)
  if action == "menu_single" then
    menu.M_Menu_SinglePlayer_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_multi" then
    menu.M_Menu_MultiPlayer_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_options" then
    menu.M_Menu_Options_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_help" then
    menu.M_Menu_Help_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "menu_quit" then
    menu.M_Menu_Quit_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "new_game" then
    stopAttractMode(session)
    setMenuActive(session, false)
    cmd.addText(session.commands, "disconnect\nmaxplayers 1\nmap start\n")
  else if action == "load_game" then
    menu.M_Menu_Load_f(session.menu)
    refreshSaveSlots(session)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "save_game" then
    if menu.M_Menu_Save_f(session.menu, session.server.active, screen.SCR_IntermissionMode(), session.server.maxClients) then
      refreshSaveSlots(session)
      playMenuSound(session, "misc/menu2.wav")
    end if
  else if action == "join_game" or action == "host_game" then
    session.menu.joiningGame = action == "join_game"
    menu.M_Menu_Net_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "player_setup" then
    menu.M_Menu_Setup_f(session.menu, session.cvars)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "customize_controls" then
    menu.M_Menu_Keys_f(session.menu)
    playMenuSound(session, "misc/menu2.wav")
  else if action == "open_console" then
    setMenuActive(session, false)
    setConsoleActive(session, true)
  else if action == "reset_defaults" then
    cmd.addText(session.commands, "exec default.cfg\n")
    menu.setStatus(session.menu, "DEFAULT CONTROLS RESTORED")
    playMenuSound(session, "misc/menu2.wav")
  else if action == "video_options" then
    menu.M_Menu_Video_f(session.menu)
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
    loaded = try(loadGame(session, "s" + session.menu.selection))
    if loaded is error then
      menu.setStatus(session.menu, loaded.message)
      playMenuSound(session, "misc/menu3.wav")
    else
      setMenuActive(session, false)
      playMenuSound(session, "misc/menu2.wav")
    end if
  else if action == "save_slot" then
    saved = try(saveGame(session, "s" + session.menu.selection))
    if saved is error then
      menu.setStatus(session.menu, saved.message)
      playMenuSound(session, "misc/menu3.wav")
    else
      refreshSaveSlots(session)
      menu.setStatus(session.menu, "GAME SAVED")
      playMenuSound(session, "misc/menu2.wav")
    end if
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

// Handle exact menu action and update the associated state.
function handleExactMenuAction(session, result)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if result is array then
    if len(result) == 0 then return false end if
    if result[0] == "renderer_switch" then
      changed = restartRenderer(session, result[1])
      if changed is error then
        menu.setStatus(session.menu, changed.message)
        playMenuSound(session, "misc/menu3.wav")
      else
        menu.setStatus(session.menu, glvid.VID_State().lastModeMessage)
        writeConfiguration(session)
        playMenuSound(session, "misc/menu2.wav")
      end if
      return true
    end if
    if result[0] == "setup_accept" then
      cvar.set(session.cvars, "hostname", result[1])
      cvar.set(session.cvars, "_cl_name", result[2])
      cvar.setValue(session.cvars, "_cl_color", ((result[3] & 15) << 4) | (result[4] & 15))
      session.client.name = result[2]
      session.client.colors = ((result[3] & 15) << 4) | (result[4] & 15)
      if len(session.server.clients) > 0 then
        session.server.clients[0].name = result[2]
        session.server.clients[0].colors = session.client.colors
      end if
      writeConfiguration(session)
      menu.M_Menu_MultiPlayer_f(session.menu)
      playMenuSound(session, "misc/menu2.wav")
      return true
    end if
    if result[0] == "connect" then
      if len(result) < 2 or result[1] == "" then
        menu.setStatus(session.menu, "Enter a server address")
        playMenuSound(session, "misc/menu3.wav")
        return true
      end if
      changedPort = try(netmain.NET_Port_f(session.network, session.menu.lanPort))
      if changedPort is error then
        menu.setStatus(session.menu, changedPort.message)
        playMenuSound(session, "misc/menu3.wav")
        return true
      end if
      setMenuActive(session, false)
      cmd.addText(session.commands, "connect \"" + result[1] + "\"\n")
      playMenuSound(session, "misc/menu2.wav")
      return true
    end if
    if result[0] == "begin_game" then
      if session.server.active then cmd.addText(session.commands, "disconnect\n") end if
      changedPort = try(netmain.NET_Port_f(session.network, session.menu.lanPort))
      if changedPort is error then
        menu.setStatus(session.menu, changedPort.message)
        return true
      end if
      cmd.addText(session.commands, "listen 0\nmaxplayers " + result[2] + "\nmap " + result[1] + "\n")
      setMenuActive(session, false)
      playMenuSound(session, "misc/menu2.wav")
      return true
    end if
    return false
  end if

  if result == "quit" then session.running = false; return true end if
  if result == "search" then
    changedPort = try(netmain.NET_Port_f(session.network, session.menu.lanPort))
    if changedPort is error then menu.setStatus(session.menu, changedPort.message); return true end if
    menu.M_Menu_Search_f(session.menu, session.network, session.menu.lanPort, session.timing.realtime)
    playMenuSound(session, "misc/menu2.wav")
    return true
  end if
  if result == "game_options" then
    changedPort = try(netmain.NET_Port_f(session.network, session.menu.lanPort))
    if changedPort is error then menu.setStatus(session.menu, changedPort.message); return true end if
    maximumClients = session.server.maxClients
    if maximumClients < 2 then maximumClients = 4 end if
    menu.M_Menu_GameOptions_f(session.menu, maximumClients, session.gameDirectory)
    playMenuSound(session, "misc/menu2.wav")
    return true
  end if
  if result == "mode_applied" then
    videoState = glvid.VID_State()
    session.fullscreen = videoState.modeState == glvid.MS_FULLDIB
    session.width = videoState.windowWidth
    session.height = videoState.windowHeight
    updateMouseCapture(session)
    writeConfiguration(session)
    playMenuSound(session, "misc/menu2.wav")
    return true
  end if
  if result == "mode_error" then
    playMenuSound(session, "misc/menu3.wav")
    return true
  end if
  if result == "lighting_applied" then
    writeConfiguration(session)
    playMenuSound(session, "misc/menu2.wav")
    return true
  end if
  if result == "lighting_error" then
    playMenuSound(session, "misc/menu3.wav")
    return true
  end if
  if result == "menu_single" or result == "menu_multi" or result == "menu_options" or result == "menu_help" or result == "menu_quit" or result == "new_game" or result == "load_game" or result == "save_game" or result == "player_setup" or result == "customize_controls" or result == "open_console" or result == "reset_defaults" or result == "video_options" or result == "bind_selected" or result == "load_slot" or result == "save_slot" or result == "video_option" or result == "adjust_option" or result == "help_next" then
    executeMenuSelection(session)
    return true
  end if
  if result == "close" then setMenuActive(session, false); return true end if
  if result == "adjust" then
    if session.menu.page == menu.PAGE_OPTIONS and session.menu.selection == 13 then updateMouseCapture(session) end if
    writeConfiguration(session)
  end if
  if result == "none" then return false end if
  playMenuSound(session, "misc/menu1.wav")
  return true
end function

// Release or consume state for discard text input.
function discardTextInput()
  count = 0
  code = win.textPop()
  while code >= 0
    count = count + 1
    code = win.textPop()
  end while
  return count
end function

// Handle menu key and update the associated state.
function handleMenuKey(session, key)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if session.menu.page == menu.PAGE_QUIT then
    return handleExactMenuAction(session, menu.M_Quit_Key(session.menu, key))
  end if

  if session.menu.page == menu.PAGE_KEYS and session.menu.waitingForKey then
    if key != keys.K_ESCAPE and key != 96 and key != 126 then
      command = menu.keyCommandAt(session.menu)
      if command != "" then keys.Key_SetBinding(key, command) end if
      session.menu.waitingForKey = false
      playMenuSound(session, "misc/menu1.wav")
      return true
    end if
    session.menu.waitingForKey = false
    playMenuSound(session, "misc/menu1.wav")
    return true
  end if

  if session.menu.page == menu.PAGE_KEYS and (key == keys.K_BACKSPACE or key == keys.K_DEL) then
    input.unbindCommand(menu.keyCommandAt(session.menu))
    playMenuSound(session, "misc/menu2.wav")
    return true
  end if
  if session.menu.active then
    result = menu.M_Keydown(session.menu, key, session.cvars)
    return handleExactMenuAction(session, result)
  end if
  if key == keys.K_UPARROW then menu.move(session.menu, -1); playMenuSound(session, "misc/menu1.wav"); return true end if
  if key == keys.K_DOWNARROW then menu.move(session.menu, 1); playMenuSound(session, "misc/menu1.wav"); return true end if
  if key == keys.K_LEFTARROW then
    if session.menu.page == menu.PAGE_OPTIONS then
      adjustMenuOption(session, -1)
    else if session.menu.page == menu.PAGE_HELP then
      menu.changeHelpPage(session.menu, -1)
      playMenuSound(session, "misc/menu2.wav")
    end if
    return true
  end if
  if key == keys.K_RIGHTARROW then
    if session.menu.page == menu.PAGE_OPTIONS then
      adjustMenuOption(session, 1)
    else if session.menu.page == menu.PAGE_HELP then
      menu.changeHelpPage(session.menu, 1)
      playMenuSound(session, "misc/menu2.wav")
    end if
    return true
  end if
  if key == keys.K_ENTER then executeMenuSelection(session); return true end if
  return false
end function

// Handle key result and update the associated state.
function handleKeyResult(session, result)
  if result[0] != "" then cmd.addText(session.commands, result[0]) end if
  action = result[1]
  key = result[2]
  if action == "toggle_menu" then
    toggleMenu(session)
    if session.menu.active then playMenuSound(session, "misc/menu2.wav") end if
    return true
  end if
  if action == "menu_escape" then
    backResult = menu.back(session.menu)
    if backResult == "close" then setMenuActive(session, false) else playMenuSound(session, "misc/menu1.wav") end if
    return true
  end if
  if action == "menu_key" then return handleMenuKey(session, key) end if
  return result[0] != ""
end function

// Execute console input.
function processConsoleInput(session)
  if not session.windowCreated then return 0 end if
  handled = 0
  // Mode changes and WM_ACTIVATE can synthesize releases outside the normal
  // event loop. Drain them before processing new downs so +commands cannot
  // remain stuck for one extra host frame.
  pendingReleases = keys.Key_TakePendingCommands()
  if pendingReleases != "" then
    cmd.addText(session.commands, pendingReleases)
    handled = handled + 1
  end if
  if keys.destination() != keys.KEY_MESSAGE then
    if session.menu.active then
      keys.setDestination(keys.KEY_MENU)
    else if session.console.active then
      keys.setDestination(keys.KEY_CONSOLE)
    else
      keys.setDestination(keys.KEY_GAME)
    end if
  end if
  forcedConsole = not session.client.connected and session.demoPlayback is void
  for each event in keys.PollEvents()
    if event[0] == -1 then
      if not event[1] then
        keys.Key_QueueReleaseAllCommands()
        pendingReleases = keys.Key_TakePendingCommands()
        if pendingReleases != "" then cmd.addText(session.commands, pendingReleases) end if
        input.IN_ClearDeviceStates()
        input.setMouseCapture(false)
      end if
      updateMouseCapture(session)
      handled = handled + 1
      continue
    end if
    if console.Con_NotifyBoxPending() then
      completed = console.Con_NotifyBoxKey(session.console, event[1])
      if completed then keys.setDestination(keys.KEY_GAME) end if
      handled = handled + 1
      continue
    end if
    result = keys.Key_Event(
      event[0],
      event[1],
      session.console,
      session.commands,
      session.cvars,
      forcedConsole,
      session.demoPlayback is not void,
    )
    if handleKeyResult(session, result) then handled = handled + 1 end if
  end for
  // Key_Event derives printable ASCII from Quake's keyshift table. Drain the
  // redundant WM_CHAR queue so it cannot replay characters on a later frame.
  discardTextInput()
  updateMouseCapture(session)
  return handled
end function

// Update module state for title.
function updateTitle(session)
  global titleFpsInitialized, titleFpsLastFrame, titleFpsLastRealtime, titleFpsLastValue
  if not session.windowCreated then return end if

  frameCount = session.timing.frameCount
  realtime = session.timing.realtime
  if not titleFpsInitialized or frameCount < titleFpsLastFrame or realtime < titleFpsLastRealtime then
    titleFpsInitialized = true
    titleFpsLastFrame = frameCount
    titleFpsLastRealtime = realtime
    titleFpsLastValue = 0
    win.setTitle(glvid.VID_WindowTitleForFps(0))
    return
  end if

  frameDelta = frameCount - titleFpsLastFrame
  if frameDelta < 30 then return end if
  elapsed = realtime - titleFpsLastRealtime
  // SetWindowTextW can synchronize with DWM. Sampling once per second and
  // avoiding identical writes removes that periodic OS-side frame disturbance.
  if elapsed < 1.0 then return end if
  fps = 0
  if elapsed > 0.000001 then fps = native.trunc(frameDelta / elapsed) end if
  if fps != titleFpsLastValue then
    win.setTitle(glvid.VID_WindowTitleForFps(fps))
    titleFpsLastValue = fps
  end if
  titleFpsLastFrame = frameCount
  titleFpsLastRealtime = realtime
end function

// Live Win32 button polling is a convenience layer for the interactive port.
// It must never participate in a headless/deterministic run: unlike original
// WinQuake's window-message input, GetAsyncKeyState-style polling can observe
// keys pressed in another application and make two identical traces diverge.
function inline shouldPollLiveButtonBindings(headless, destinationIsGame, consoleActive, menuActive)
  return not headless and destinationIsGame and not consoleActive and not menuActive
end function

// Provide deterministic input requested behavior for the active subsystem.
function deterministicInputRequested(session)
  return common.hasParm(session.arguments, "-noinput")
end function

// Send client intentions through the active connection.
function sendClientIntentions(session)
  if session.demoPlayback is void and not session.client.connected then return 0 end if
  command = session.client.command
  inputSuppressed = deterministicInputRequested(session)
  transitionSuppressed = input.IN_GameplayTransitionBlocked()
  if transitionSuppressed then
    // A neutral sample only arms the following frame. This prevents the key-up
    // event and a queued keyPressed edge from becoming a one-frame shot/jump.
    input.IN_ReleaseGameplayTransitionIfNeutral()
    input.IN_ClearStates()
    input.clear(command)
  end if
  if inputSuppressed then
    // Render evidence needs a real OpenGL window but must not inherit keyboard,
    // mouse or joystick state from the desktop.  Original WinQuake only sees
    // input messages delivered to its game window; the port's asynchronous
    // convenience polling is therefore outside the deterministic contract.
    input.IN_ClearStates()
    input.clear(command)
  end if
  if session.client.signon == c.SIGNONS then
    pollButtonBindings = not inputSuppressed and not transitionSuppressed and shouldPollLiveButtonBindings(
      session.headless,
      keys.destination() == keys.KEY_GAME,
      session.console.active,
      session.menu.active,
    )
    deviceActive = not inputSuppressed and not transitionSuppressed and not session.headless and session.windowCreated and win.hasFocus()
    minimized = session.windowCreated and win.minimized()
    input.buildOriginalMove(
      command,
      session.client.signon,
      session.timing.frameTime * 1000.0,
      cvar.variableValue(session.cvars, "sensitivity"),
      cvar.variableValue(session.cvars, "m_yaw"),
      cvar.variableValue(session.cvars, "m_pitch"),
      cvar.variableValue(session.cvars, "m_filter") != 0.0,
      cvar.variableValue(session.cvars, "cl_forwardspeed"),
      cvar.variableValue(session.cvars, "cl_backspeed"),
      cvar.variableValue(session.cvars, "cl_sidespeed"),
      cvar.variableValue(session.cvars, "cl_upspeed"),
      session.player.noclip,
      pollButtonBindings,
      deviceActive,
      minimized,
    )
  end if
  return client.CL_SendCmd(session.client, command)
end function

// Apply the Quake-compatible host server frame behavior.
function Host_ServerFrame(session)
  if not session.server.active then return false end if
  sz.clear(session.server.datagram)
  newConnections = pumpNewConnections(session)
  if newConnections is error then return newConnections end if
  timeout = cvar.variableValue(session.cvars, "net_messagetimeout")
  netmain.NET_SetMessageTimeout(timeout)
  server.dropTimedOutClients(session.server, timeout)
  simulate = not session.server.paused
  if session.server.maxClients == 1 and keys.destination() != keys.KEY_GAME then simulate = false end if
  result = server.frameMode(session.server, session.player, session.timing.frameTime, session.cvars, simulate)
  if result and simulate then session.simulatedFrames = session.simulatedFrames + 1 end if
  flushServerCvarChanges(session)
  return result
end function

// Apply the Quake-compatible host server frame behavior.
function _Host_ServerFrame(session)
  return Host_ServerFrame(session)
end function

// Apply the Quake-compatible host frame behavior.
function _Host_Frame(session, elapsedSeconds)
  // BP-001 persists the last completed host stage only when a compatibility
  // trace explicitly provides a context path. Normal gameplay does no I/O.
  compatDiagnostics.beginFrame(session)
  // The original advances the process-global MSVC rand stream before the
  // frame-rate gate.  QuakeC PF_random and monster movement consume that same
  // stream, so even filtered frames must perturb their next value.
  if session.server.machine is not void and session.server.machine.context is not void then
    contextValue = session.server.machine.context
    session.server.randomSeed = contextValue.randomSeed
  end if
  session.server.randomSeed = (session.server.randomSeed * 214013 + 2531011) & 0xffffffff
  if session.server.machine is not void and session.server.machine.context is not void then
    session.server.machine.context.randomSeed = session.server.randomSeed
  end if
  if not Host_FilterTime(session, elapsedSeconds) then
    compatDiagnostics.filteredFrame(session)
    return false
  end if
  if session.diagnosticContextPath != "" then session.frameTrace = [] end if
  compatDiagnostics.checkpoint(session, "filter")
  console.Con_SetRealtime(session.console, session.timing.realtime)

  executeCommandBuffer(session, 64)
  compatDiagnostics.checkpoint(session, "commands")
  netmain.NET_Poll()
  compatDiagnostics.checkpoint(session, "net_poll")
  flushServerCvarChanges(session)
  timeout = cvar.variableValue(session.cvars, "net_messagetimeout")
  netmain.NET_SetMessageTimeout(timeout)
  if session.client.connected and netmain.NET_SocketTimedOut(session.client.socket, timeout) then
    client.dropConnection(session.client)
    session.statusMessage = "Server connection timed out."
    console.appendLine(session.console, session.statusMessage)
    print session.statusMessage
  end if
  if session.demoPlayback is not void then
    sendClientIntentions(session)
    compatDiagnostics.checkpoint(session, "demo_send")
    stepped = stepDemoPlayback(session)
    if stepped is error then print stepped.message end if
  else if session.server.active then
    sendClientIntentions(session)
    compatDiagnostics.checkpoint(session, "local_send")
  end if

  Host_GetConsoleCommands(session, [])
  compatDiagnostics.checkpoint(session, "console")
  if session.server.active then
    serverResult = try(Host_ServerFrame(session))
    if serverResult is error then return Host_Error(session, serverResult.message) end if
    compatDiagnostics.checkpoint(session, "server")
  else if session.demoPlayback is void then
    sendClientIntentions(session)
    compatDiagnostics.checkpoint(session, "remote_send")
  end if

  session.hostTime = session.hostTime + session.timing.frameTime
  compatDiagnostics.checkpoint(session, "host_time")

  if session.demoPlayback is void then
    if session.client.connected then
      session.client.oldTime = session.client.time
      session.client.time = session.client.time + session.timing.frameTime
    end if
    readResult = try(pumpClient(session))
    if readResult is error then return Host_Error(session, readResult.message) end if
  end if
  compatDiagnostics.checkpoint(session, "client_read")

  if not session.server.active and session.demoPlayback is void and session.client.signon == c.SIGNONS and session.server.worldModel is void then
    prepared = try(prepareDemoScene(session))
    if prepared is error then print prepared.message end if
  end if
  compatDiagnostics.checkpoint(session, "demo_scene")

  // A local pickup can clear its authoritative QuakeC model during the server
  // phase above. Remove that numbered client entity before relinking and
  // before the world/entity render phases; filtering only the final submitted
  // list left older entity/efrag consumers with one retained model.
  // The presence of the same-process server is the authoritative ownership
  // test. A LocalClient can temporarily retain remote/demo interpolation flags
  // across reconnect-style transitions; those flags must never allow an old
  // numbered model to bypass the server edict that already hid or freed it.
  if session.server.active then
    client.CL_ApplyAuthoritativeEntityVisibility(session.client, session.server.edicts)
  end if
  synchronizeClientRelinkModels(session)
  client.CL_BeginRelinkParticles(session.particles)
  client.CL_RelinkEntities(session.client)
  session.particles = client.CL_EndRelinkParticles()
  compatDiagnostics.checkpoint(session, "entity_relink")
  clientFrameTime = session.client.time - session.client.oldTime
  consumeRelinkParticleEffects(session)
  compatDiagnostics.checkpoint(session, "entity_effects")
  consumeClientEvents(session)
  // CL_ReadFromServer calls CL_UpdateTEnts immediately after entity relinking.
  // Build the frame-local beam model entities even in headless mode so the
  // shared client rand() stream and retained view match an interactive client.
  renderHandoff.buildTemporaryEntities(
    session.temporaryEntities,
    session.client,
    session.client.time,
    len(session.client.visibleEntities),
  )
  compatDiagnostics.checkpoint(session, "client_events")
  forceConsoleUpdate = consumeConsoleSideEffects(session)
  consumeQuakeCControl(session)
  compatDiagnostics.checkpoint(session, "qc_control")
  console.clearExpiredCenter(session.console, session.client.time)
  compatDiagnostics.checkpoint(session, "centerprint")
  pitchDrift = input.consumePitchDriftRequests()
  if pitchDrift[0] then view.V_StopPitchDrift(session.view, session.client.time) end if
  if pitchDrift[1] then
    view.V_StartPitchDrift(session.view, session.client.time, cvar.variableValue(session.cvars, "v_centerspeed"))
  end if
  view.V_RenderView(
    session.view,
    session.player,
    session.client,
    session.cvars,
    session.timing.frameTime,
    session.server.paused,
    session.demoPlayback is not void,
    screen.SCR_IntermissionMode(),
      not session.client.connected and session.demoPlayback is void,
  )
  forcedConsole = not session.client.connected and session.demoPlayback is void
  chaseActive = cvar.variableValue(session.cvars, "chase_active") != 0.0
  if chaseActive and not session.server.paused and screen.SCR_IntermissionMode() == 0 and not forcedConsole then
    // The chase state has no persistent frame-to-frame mutation. Construct it
    // only when the optional camera is actually active; first-person gameplay
    // otherwise allocated a state object and performed four extra cvar scans.
    chaseState = chase.syncCvars(chase.create(), session.cvars)
    chaseWorld = session.server.worldModel
    if session.renderer is not void then chaseWorld = session.renderer.map end if
    chased = chase.Chase_UpdateRefdef(
      chaseState,
      session.view.origin,
      session.client.command.viewAngles,
      session.view.angles,
      chaseWorld,
    )
    session.view.origin = chased[0]
    session.view.angles = chased[1]
    chaseVectors = math.angleVectors(session.view.angles)
    session.view.forward = chaseVectors[0]
    session.view.right = chaseVectors[1]
    session.view.up = chaseVectors[2]
    session.view.viewModelVisible = false
  end if
  compatDiagnostics.checkpoint(session, "view")

  // Before a world renderer exists, Con_Printf during signon still forces the
  // 2D console update that the original calls directly.  With a renderer, the
  // regular screen phase below consumes the request in the same frame.
  if forceConsoleUpdate and session.renderer is void and session.windowCreated and not screen.SCR_ShouldSkipUpdate(session.timing.realtime) then
    screen.SCR_UpdateScreen(
      session.console,
      session.menu,
      session.view,
      session.player,
      win.width(),
      win.height(),
      session.server.mapName,
      false,
      session.timing.realtime,
      session.timing.frameTime,
      session.cvars,
      session.client.connected,
      session.server.active,
      session.client.signon,
      session.server.paused,
      session.client.lastMessageTime,
      session.demoPlayback is not void,
      false,
      false,
      keys.destination() == keys.KEY_CONSOLE,
    )
    glvid.GL_EndRendering()
  end if

  frameMixAhead = 0.0
  if session.mixer.enabled then frameMixAhead = cvar.variableValue(session.cvars, "_snd_mixahead") end if

  // Top up the queued audio before the potentially expensive world/entity/UI
  // render.  The mixer is demand-driven, so a full queue makes this a cheap
  // no-op while a starving queue receives additional 512-frame blocks.
  if session.mixer.enabled and session.renderer is not void then
    mixer.update(session.mixer, session.timing.frameTime, frameMixAhead)
  end if

  if session.renderer is not void and session.windowCreated and not screen.SCR_ShouldSkipUpdate(session.timing.realtime) then
    screen.SCR_ConfigureClient(session.client)
    // Frame-local hot-Cvar cache: command execution for this frame is already
    // complete, so repeated linear string lookups below can safely share values.
    rFullbright = cvar.variableValue(session.cvars, "r_fullbright")
    rWireframe = cvar.variableValue(session.cvars, "r_wireframe")
    rWaterAlpha = cvar.variableValue(session.cvars, "r_wateralpha")
    glCshiftPercent = cvar.variableValue(session.cvars, "gl_cshiftpercent")
    glCull = cvar.variableValue(session.cvars, "gl_cull")
    noRefresh = cvar.variableValue(session.cvars, "r_norefresh") != 0.0
    rMirrorAlpha = cvar.variableValue(session.cvars, "r_mirroralpha")
    glClear = cvar.variableValue(session.cvars, "gl_clear")
    glZTrick = cvar.variableValue(session.cvars, "gl_ztrick")
    glFinish = cvar.variableValue(session.cvars, "gl_finish")
    rDrawEntities = cvar.variableValue(session.cvars, "r_drawentities") != 0.0
    rDrawViewModel = cvar.variableValue(session.cvars, "r_drawviewmodel") != 0.0
    glPolyBlend = cvar.variableValue(session.cvars, "gl_polyblend") != 0.0
    crosshairEnabled = cvar.variableValue(session.cvars, "crosshair") != 0.0
    enhancedRequested = cvar.variableValue(session.cvars, "r_lighting") != 0.0
    enhancedShadows = cvar.variableValue(session.cvars, "r_shadows") != 0.0
    enhancedShadowQuality = native.trunc(cvar.variableValue(session.cvars, "r_shadowquality"))
    enhancedActive = worldRenderer.R_ConfigureEnhancedLighting(
      enhancedRequested,
      enhancedShadows,
      enhancedShadowQuality,
    )
    // Projected geometry shadows use the fixed-function entity pass and do not
    // depend on the optional per-pixel lighting shader.  Keeping this tied to
    // enhancedActive made an archived `r_lighting 0` silently disable the
    // visibly enabled Shadows menu option during normal first-person starts.
    entityRenderer.ConfigureAliasRendering(true, false, enhancedShadows, false, true)
    entityRenderer.ConfigureEnhancedShadowQuality(enhancedRenderer.shadowQuality())

    session.renderer.fullbright = rFullbright != 0.0
    session.renderer.wireframe = rWireframe != 0.0
    session.renderer.waterAlpha = rWaterAlpha
    width = win.width()
    height = win.height()
    screenRefdef = screen.SCR_CalcRefdef(width, height, session.cvars, screen.SCR_IntermissionMode())
    view.V_SetContentsColor(session.view, worldRenderer.ViewContents(session.renderer, session.view.origin))
    view.V_CalcBlend(session.view, glCshiftPercent)
    worldRenderer.R_SetCullCompatibility(glCull != 0.0)
    worldRenderer.R_ConfigureSpecialCompatibility(
      rMirrorAlpha,
      glClear != 0.0,
      glZTrick != 0.0,
      glFinish != 0.0,
      noRefresh,
    )
    if screen.SCR_ConsumeTransitionClear() then
      gl.clearColor(0.0, 0.0, 0.0, 1.0)
      gl.clear(gl.GL_COLOR_BUFFER_BIT)
    end if
    renderEntities = []
    visibleEntities = []
    temporaryModels = []
    if not noRefresh then
      worldResult = try(worldRenderer.renderViewport(
        session.renderer, width, height, screenRefdef, session.view.origin, session.view.angles,
        client.CL_Dlights(), session.client.lightStyles, session.client.time,
        session.timing.realtime, session.timing.frameTime, session.view.blend,
      ))
      if worldResult is error then return error(3890, "screen_world: " + worldResult.message) end if
      compatDiagnostics.checkpoint(session, "screen_world")
      if session.entityRenderer is not void then
        visibleEntities = client.CL_ActiveVisibleEntities(session.client)
        // A local server and client share one process, so use the authoritative
        // mirror as the final render gate. This makes collected pickups vanish
        // immediately even if a stale Protocol-15 visible list survived one
        // frame; remote clients and demos retain the original network path.
        if session.server.active then
          visibleEntities = client.CL_FilterAuthoritativeVisibleEntities(
            visibleEntities,
            session.server.edicts,
          )
        end if
        // Static efrag bounds need the fully synchronized model table before
        // they can be split across BSP leaves.
        entityRenderer.synchronize(session.entityRenderer, session.client.modelPrecache)
        visibleEntities = appendVisibleStaticEntities(session, visibleEntities)
        temporaryModels = renderHandoff.currentTemporaryEntities()
        if rDrawEntities then
          renderEntities = renderHandoff.submitEntities(visibleEntities, temporaryModels)
          // CL_RelinkEntities already applies first-person/chase filtering.
          entityResult = try(entityRenderer.renderSubmitted(session.entityRenderer, session.renderer, renderEntities, void, session.view.right, session.view.up, session.client.time))
          if entityResult is error then return error(3891, "screen_entities: " + entityResult.message) end if
          if enhancedActive then
            enhancedEntityResult = try(entityRenderer.renderEnhancedSubmitted(session.entityRenderer, session.renderer, renderEntities, void, session.client.time))
            if enhancedEntityResult is error then return error(3936, "screen_enhanced_entities: " + enhancedEntityResult.message) end if
          end if
        end if
      end if
      compatDiagnostics.checkpoint(session, "screen_entities")
      particleRenderer.renderView(
        session.particles, session.renderer.palette,
        session.view.origin, session.view.forward, session.view.up, session.view.right,
      )
      compatDiagnostics.checkpoint(session, "screen_particles_draw")
      if session.entityRenderer is not void and rDrawViewModel then
        viewModelResult = try(entityRenderer.renderViewModel(session.entityRenderer, session.player, session.view, session.client.time))
        if viewModelResult is error then return error(3892, "screen_viewmodel: " + viewModelResult.message) end if
        if enhancedActive then
          enhancedViewModelResult = try(entityRenderer.renderViewModelEnhanced(session.entityRenderer, session.player, session.view, session.client.time))
          if enhancedViewModelResult is error then return error(3937, "screen_enhanced_viewmodel: " + enhancedViewModelResult.message) end if
        end if
      end if
      compatDiagnostics.checkpoint(session, "screen_viewmodel")
      // R_RenderView draws the deferred translucent/unsorted water pass after
      // particles and the view model, before mirrors and the final polyblend.
      worldRenderer.R_DrawWaterSurfaces()
      compatDiagnostics.checkpoint(session, "screen_water")
      if worldRenderer.R_MirrorReady() then
        reflected = try(worldRenderer.R_MirrorView(session.view.origin, session.view.angles))
        if reflected is error then return reflected end if
        if reflected is not void then
          reflectedOrigin = reflected[0]
          reflectedAngles = reflected[1]
          reflectedVectors = math.angleVectors(reflectedAngles)
          worldRenderer.renderMirrorViewport(
            session.renderer, width, height, screenRefdef, reflectedOrigin, reflectedAngles,
            client.CL_Dlights(), session.client.lightStyles, session.client.time,
            session.timing.realtime, session.timing.frameTime, session.view.blend,
          )
          if session.entityRenderer is not void and rDrawEntities then
            viewEntity = void
            if session.client.viewEntity >= 0 and session.client.viewEntity < len(session.client.entities) then
              viewEntity = session.client.entities[session.client.viewEntity]
            end if
            mirrorEntities = renderHandoff.submitMirrorEntities(visibleEntities, temporaryModels, viewEntity)
            entityRenderer.renderSubmitted(
              session.entityRenderer, session.renderer, mirrorEntities, void,
              reflectedVectors[1], reflectedVectors[2], session.client.time,
            )
          end if
          particleRenderer.renderView(
            session.particles, session.renderer.palette,
            reflectedOrigin, reflectedVectors[0], reflectedVectors[2], reflectedVectors[1],
          )
          worldRenderer.R_DrawWaterSurfaces()
          worldRenderer.R_DrawMirrorOverlay(width, height, screenRefdef, session.view.origin, session.view.angles)
        end if
      end if
      compatDiagnostics.checkpoint(session, "screen_mirror")
      worldRenderer.R_PolyBlendProduction(
        session.view.blend,
        glPolyBlend,
      )
      compatDiagnostics.checkpoint(session, "screen_polyblend")
      enhancedRenderer.endFrame()
    else
      compatDiagnostics.checkpoint(session, "screen_world")
      compatDiagnostics.checkpoint(session, "screen_entities")
      compatDiagnostics.checkpoint(session, "screen_particles_draw")
      compatDiagnostics.checkpoint(session, "screen_viewmodel")
      compatDiagnostics.checkpoint(session, "screen_water")
      compatDiagnostics.checkpoint(session, "screen_mirror")
      compatDiagnostics.checkpoint(session, "screen_polyblend")
    end if
    screen.SCR_UpdateScreen(
      session.console,
      session.menu,
      session.view,
      session.player,
      width,
      height,
      session.server.mapName,
      crosshairEnabled,
      session.timing.realtime,
      session.timing.frameTime,
      session.cvars,
      session.client.connected,
      session.server.active,
      session.client.signon,
      session.server.paused,
      session.client.lastMessageTime,
      session.demoPlayback is not void,
      false,
      keys.destination() == keys.KEY_GAME,
      keys.destination() == keys.KEY_CONSOLE,
    )
    compatDiagnostics.checkpoint(session, "screen_ui")
    capturedEvidence = try(renderEvidence.captureIfRequested(session.timing.frameCount, width, height))
    if capturedEvidence is error then return capturedEvidence end if
    compatDiagnostics.checkpoint(session, "screen_evidence")
    glvid.GL_EndRendering()
    compatDiagnostics.checkpoint(session, "screen_swap")
    session.renderedFrames = session.renderedFrames + 1
    updateTitle(session)
    compatDiagnostics.checkpoint(session, "screen_title")
  end if
  compatDiagnostics.checkpoint(session, "screen")
  // Host_Frame decays client lights after SCR_UpdateScreen.  Relinking must
  // first be allowed to clamp cl.time to the latest message, because timedemo
  // particle/light integration uses that final cl.time-cl.oldtime interval.
  client.CL_DecayLightsAt(session.client.time, clientFrameTime)
  compatDiagnostics.checkpoint(session, "dlight_decay")
  // MiniQuake draws every active particle before applying that frame's motion,
  // ramp and gravity update inside R_DrawParticles.  Advancing before the
  // renderer made explosions one simulation step too old and too dispersed.
  // Headless modes still reach this common post-render update.
  session.particles = particles.updateWithGravity(
    session.particles, session.client.time, clientFrameTime,
    cvar.variableValue(session.cvars, "sv_gravity"),
  )
  compatDiagnostics.checkpoint(session, "particles")

  if session.mixer.enabled then
    glvid.VID_SynchronizeSoundFocusIfNeeded()
    session.mixer.masterVolume = cvar.variableValue(session.cvars, "volume")
    requestedMusicVolume = cvar.variableValue(session.cvars, "bgmvolume")
    cdState = cdAudio.ensure(session.mixer)
    actualMusicVolume = cdAudio.CDAudio_Update(cdState, requestedMusicVolume)
    if cdState.enabled then
      if actualMusicVolume != requestedMusicVolume then cvar.setValue(session.cvars, "bgmvolume", actualMusicVolume) end if
      session.mixer.musicVolume = actualMusicVolume
    else
      session.mixer.musicVolume = 0.0
    end if
    mixer.updateListener(session.mixer, session.view.origin, session.view.forward, session.view.right)
    mixer.setListenerEntity(session.mixer, session.client.viewEntity)
    mixer.updateEntityOrigins(session.mixer, session.client.entities)
    ambientLevel = cvar.variableValue(session.cvars, "ambient_level")
    ambientFade = cvar.variableValue(session.cvars, "ambient_fade")
    if session.server.worldModel is not void then
      mixer.updateAmbient(
        session.mixer,
        session.server.worldModel,
        session.view.origin,
        session.timing.frameTime,
        ambientLevel,
        ambientFade,
      )
    end if
    mixer.update(session.mixer, session.timing.frameTime, frameMixAhead)
  end if
  compatDiagnostics.checkpoint(session, "audio")
  compatDiagnostics.completeFrame(session)
  return true
end function

// Apply the Quake-compatible host frame behavior.
function Host_Frame(session, elapsedSeconds)
  if cvar.variableValue(session.cvars, "serverprofile") == 0.0 then return _Host_Frame(session, elapsedSeconds) end if
  started = win.ticks()
  result = _Host_Frame(session, elapsedSeconds)
  finished = win.ticks()
  session.profileTime = session.profileTime + (finished - started)
  session.profileCount = session.profileCount + 1
  if session.profileCount >= 1000 then
    print "serverprofile: " + activeServerClients(session) + " clients " + native.trunc(session.profileTime / session.profileCount) + " msec"
    session.profileTime = 0.0
    session.profileCount = 0
  end if
  return result
end function

// Advance the requested value by one processing step.
function frame(session, elapsedSeconds)
  return Host_Frame(session, elapsedSeconds)
end function

// Apply the Quake-compatible host shutdown behavior.
function Host_Shutdown(session)
  if session.shutdownStarted then
    print "recursive shutdown"
    return false
  end if
  session.shutdownStarted = true
  if session.initialized and not session.headless and session.maxFrames == 0 then Host_WriteConfiguration(session) end if
  if session.demoRecording is not void then
    stopped = try(stopDemoRecording(session))
    if stopped is error then print stopped.message end if
  end if
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  particleRenderer.R_ShutdownParticleTexture()
  if session.entityRenderer is not void then entityRenderer.destroy(session.entityRenderer); session.entityRenderer = void end if
  if session.renderer is not void then worldRenderer.destroy(session.renderer) end if
  session.renderer = void
  screen.shutdown(session.console, session.menu)
  if session.audioStarted then
    cdAudio.release(session.mixer)
    mixer.close(session.mixer)
    session.audioStarted = false
  end if
  if session.server.active then
    Host_ShutdownServer(session, false)
  else if session.client.connected then
    client.disconnect(session.client)
  end if
  netmain.NET_Shutdown(session.network)
  netwins.WINS_Shutdown()
  input.IN_Shutdown()
  if session.windowCreated then glvid.VID_Shutdown(); session.windowCreated = false end if
  glvid.VID_SetSoundMixer(void)
  qfs.release(session.filesystem)
  session.running = false
  return true
end function

// Release state for shutdown.
function shutdown(session)
  return Host_Shutdown(session)
end function

// Execute one named test case and record its pass/fail result.
function run(args)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then print "Host_Init: " + initialized.message; shutdown(session); return 2 end if
  if not session.server.active and session.demoPlayback is void and not session.client.connected then
    print "MiniQuake: no map or demo started. Use +map start or +playdemo demo1"
    shutdown(session)
    return 2
  end if

  useSystemLoop = sysWin.Sys_State().initialized
  lastTicks = win.ticks()
  lastSystemTime = 0.0
  if useSystemLoop then lastSystemTime = sysWin.Sys_FloatTime() end if
  while session.running
    if session.windowCreated then
      if useSystemLoop then
        if not sysWin.Sys_SendKeyEvents() then session.running = false end if
      else
        if not win.poll() then session.running = false end if
      end if
      input.IN_Accumulate()
      processConsoleInput(session)
    end if
    dedicated = common.hasParm(session.arguments, "-dedicated")
    if useSystemLoop and dedicated then
      consoleCommand = sysWin.Sys_ConsoleInput()
      if consoleCommand is not void then cmd.addText(session.commands, consoleCommand + "\n") end if
    end if
    elapsedSeconds = 0.0
    if useSystemLoop then
      if session.windowCreated and (win.minimized() or not win.hasFocus()) then
        waitTime = sysWin.NOT_FOCUS_SLEEP
        if session.server.paused or win.minimized() then waitTime = sysWin.PAUSE_SLEEP end if
        sysWin.SleepUntilInput(waitTime)
      end if
      systemNow = sysWin.Sys_FloatTime()
      elapsedSeconds = systemNow - lastSystemTime
      if dedicated then
        ticrate = cvar.variableValue(session.cvars, "sys_ticrate")
        while elapsedSeconds < ticrate and session.running
          sysWin.Sys_Sleep()
          systemNow = sysWin.Sys_FloatTime()
          elapsedSeconds = systemNow - lastSystemTime
        end while
      end if
      lastSystemTime = systemNow
    else
      now = win.ticks()
      elapsedMs = now - lastTicks
      if dedicated then
        ticrateMs = cvar.variableValue(session.cvars, "sys_ticrate") * 1000.0
        if ticrateMs < 1.0 then ticrateMs = 1.0 end if
        while elapsedMs < ticrateMs and session.running
          sleepMs = native.trunc(ticrateMs - elapsedMs)
          if sleepMs < 1 then sleepMs = 1 end if
          win.sleep(sleepMs)
          now = win.ticks()
          elapsedMs = now - lastTicks
        end while
      end if
      lastTicks = now
      elapsedSeconds = elapsedMs / 1000.0
    end if
    if elapsedSeconds < 0.0 then elapsedSeconds = 0.0 end if
    if elapsedSeconds > 0.25 then elapsedSeconds = 0.25 end if
    frame(session, elapsedSeconds)
    if session.maxFrames > 0 and session.timing.frameCount >= session.maxFrames then session.running = false end if
    if not useSystemLoop then
      if session.windowCreated then win.sleep(1) else if elapsedSeconds == 0.0 then win.sleep(1) end if
    end if
  end while
  shutdown(session)
  return 0
end function

// Provide protocol queue snapshot behavior for the active subsystem.
function protocolQueueSnapshot(session)
  queuedMessages = 0
  queuedBytes = 0
  if session.server.reliableDatagram.curSize > 0 then
    queuedMessages = queuedMessages + 1
    queuedBytes = queuedBytes + session.server.reliableDatagram.curSize
  end if
  for each serverClient in session.server.clients
    if serverClient.active and serverClient.message.curSize > 0 then
      queuedMessages = queuedMessages + 1
      queuedBytes = queuedBytes + serverClient.message.curSize
    end if
  end for
  if session.client.outgoing.curSize > 0 then
    queuedMessages = queuedMessages + 1
    queuedBytes = queuedBytes + session.client.outgoing.curSize
  end if
  if session.client.incoming.curSize > 0 then
    queuedMessages = queuedMessages + 1
    queuedBytes = queuedBytes + session.client.incoming.curSize
  end if
  return [queuedMessages, queuedBytes]
end function

// Return udp endpoint count derived from the active module state.
function udpEndpointCount(session)
  count = 0
  if session.network.listener is not void and session.network.listener.open then count = count + 1 end if
  for each socket in session.network.remoteSockets
    if socket is not void and not socket.disconnected and socket.udp is not void and socket.udp.open then count = count + 1 end if
  end for
  return count
end function

// Provide resource snapshot behavior for the active subsystem.
function resourceSnapshot(session)
  network = netmain.NET_QueueSnapshot()
  protocol = protocolQueueSnapshot(session)
  edicts = 0
  if session.server.active then edicts = session.server.numEdicts end if
  audioQueued = 0
  if session.audioStarted then audioQueued = native.audioQueued() end if
  heapHighWater = heap_bytes_used()
  heapFree = heap_free_bytes()
  return [
    heap_count(),
    heapHighWater,
    heapHighWater - heapFree,
    heapFree,
    edicts,
    len(session.client.entities),
    activeServerClients(session),
    network[0],
    network[1],
    network[3] + protocol[0],
    network[4] + protocol[1],
    network[5],
    udpEndpointCount(session),
    audioQueued,
    len(session.mixer.channels),
    native.processHandleCount(),
    len(session.particles),
    len(session.temporaryEntities),
  ]
end function

// Provide resource high water behavior for the active subsystem.
function resourceHighWater(high, value)
  updated = []
  index = 0
  while index < len(value)
    maximum = high[index]
    if value[index] > maximum then maximum = value[index] end if
    updated = updated + [maximum]
    index = index + 1
  end while
  return updated
end function

// Provide resource stable behavior for the active subsystem.
function resourceStable(before, after)
  return stability.longStable(before, after)
end function

// Format and emit resource delta.
function printResourceDelta(label, before, after, high)
  print "  " + label + ": " + before + " -> " + after + " (max " + high + ")"
  return true
end function

// Format and emit resource soak.
function printResourceSoak(mode, target, frameCount, before, after, high, cycles, demoMessages, stable)
  print "MiniQuake long soak"
  print "  mode=" + mode + " target=" + target + " frames=" + frameCount
  printResourceDelta("heap live", before[0], after[0], high[0])
  printResourceDelta("heap high-water bytes", before[1], after[1], high[1])
  printResourceDelta("heap live bytes", before[2], after[2], high[2])
  printResourceDelta("heap free bytes", before[3], after[3], high[3])
  printResourceDelta("edicts", before[4], after[4], high[4])
  printResourceDelta("client entities", before[5], after[5], high[5])
  printResourceDelta("active clients", before[6], after[6], high[6])
  printResourceDelta("active qsockets", before[7], after[7], high[7])
  printResourceDelta("free qsockets", before[8], after[8], high[8])
  printResourceDelta("network queued messages", before[9], after[9], high[9])
  printResourceDelta("network queued bytes", before[10], after[10], high[10])
  printResourceDelta("network poll procedures", before[11], after[11], high[11])
  printResourceDelta("udp endpoints", before[12], after[12], high[12])
  printResourceDelta("audio queued buffers", before[13], after[13], high[13])
  printResourceDelta("audio channels", before[14], after[14], high[14])
  printResourceDelta("process handles", before[15], after[15], high[15])
  printResourceDelta("particles", before[16], after[16], high[16])
  printResourceDelta("temporary entities", before[17], after[17], high[17])
  entityLimit = stability.clientEntityLimit(before[4], after[4], before[5])
  checks = stability.longChecks(before, after)
  print "  client entity high-water limit=" + entityLimit
  print "  stability gates: heap=" + checks[0] +
    " server_edicts=" + checks[1] +
    " client_entities=" + checks[2] +
    " clients=" + checks[3] +
    " sockets=" + checks[4] +
    " queues=" + checks[5] +
    " endpoints=" + checks[6] +
    " audio=" + checks[7] +
    " handles=" + checks[8]
  print "  demo cycles=" + cycles + " messages=" + demoMessages
  if stable then print "  result=PASS" else print "  result=FAIL" end if
  return stable
end function

// Provide soak frame error behavior for the active subsystem.
function soakFrameError(session, phase, frameIndex, frameError)
  stage = "before-filter"
  if len(session.frameTrace) > 0 then stage = session.frameTrace[len(session.frameTrace) - 1] end if
  return error(3736, phase + " frame " + frameIndex + " [" + stage + "]: " + frameError.message)
end function

// Execute measured frames.
function runMeasuredFrames(session, frameCount)
  gc_collect()
  before = resourceSnapshot(session)
  high = before
  index = 0
  checkpoint = 10000
  while index < frameCount
    frameResult = try(frame(session, 0.02))
    if frameResult is error then return soakFrameError(session, "measured", index, frameResult) end if
    index = index + 1
    if index == checkpoint or index == frameCount then
      gc_collect()
      high = resourceHighWater(high, resourceSnapshot(session))
      checkpoint = checkpoint + 10000
    end if
  end while
  gc_collect()
  after = resourceSnapshot(session)
  high = resourceHighWater(high, after)
  return [before, after, high]
end function

// Execute server mode soak.
function runServerModeSoak(args, mode, target, frameCount)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    shutdown(session)
    return initialized
  end if
  if not session.server.active then shutdown(session); return error(3730, "long soak did not start a server") end if
  warmup = 0
  while warmup < 1200
    frameResult = try(frame(session, 0.02))
    if frameResult is error then
      failure = soakFrameError(session, "warmup", warmup, frameResult)
      shutdown(session)
      return failure
    end if
    warmup = warmup + 1
  end while
  measured = try(runMeasuredFrames(session, frameCount))
  if measured is error then shutdown(session); return measured end if
  stable = resourceStable(measured[0], measured[1])
  printResourceSoak(mode, target, frameCount, measured[0], measured[1], measured[2], 0, 0, stable)
  shutdown(session)
  if not stable then return error(3731, mode + " resource growth exceeded soak limits") end if
  return true
end function

// Provide restart soak demo behavior for the active subsystem.
function restartSoakDemo(session, demoName)
  if session.demoPlayback is not void then finishDemoPlayback(session) end if
  return playDemo(session, demoName, false)
end function

// Execute demo mode soak.
function runDemoModeSoak(args, demoName, frameCount)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    shutdown(session)
    return initialized
  end if
  if session.demoPlayback is void then shutdown(session); return error(3732, "demo soak did not start playback") end if

  // Exercise complete retail recordings before the baseline so all
  // message families and persistent caches have already been encountered.
  warmup = 0
  warmCycles = 0
  // Eight cycles also fill the bounded console-history ring.  Measuring
  // before that one-time capacity is reached looks like a small-object leak
  // even though old lines are replaced once the ring is full.
  while warmCycles < 8 and warmup < 600000
    if session.demoPlayback is void then
      warmCycles = warmCycles + 1
      if warmCycles < 8 then
        restarted = try(restartSoakDemo(session, demoName))
        if restarted is error then shutdown(session); return restarted end if
      end if
    else
      frameResult = try(frame(session, 0.02))
      if frameResult is error then
        failure = soakFrameError(session, "demo warmup", warmup, frameResult)
        shutdown(session)
        return failure
      end if
      warmup = warmup + 1
    end if
  end while
  if warmCycles < 8 then shutdown(session); return error(3733, "demo warmup did not complete eight cycles") end if
  restarted = try(restartSoakDemo(session, demoName))
  if restarted is error then shutdown(session); return restarted end if

  gc_collect()
  before = resourceSnapshot(session)
  high = before
  cycles = 0
  demoMessages = 0
  index = 0
  checkpoint = 10000
  while index < frameCount
    playback = session.demoPlayback
    if playback is void then
      cycles = cycles + 1
      restarted = try(restartSoakDemo(session, demoName))
      if restarted is error then shutdown(session); return restarted end if
      playback = session.demoPlayback
    end if
    messageIndex = playback.index
    frameResult = try(frame(session, 0.02))
    if frameResult is error then
      failure = soakFrameError(session, "demo measured", index, frameResult)
      shutdown(session)
      return failure
    end if
    demoMessages = demoMessages + playback.index - messageIndex
    index = index + 1
    if index == checkpoint or index == frameCount then
      gc_collect()
      high = resourceHighWater(high, resourceSnapshot(session))
      checkpoint = checkpoint + 10000
    end if
  end while

  // Compare the same post-signon phase on both sides.  Otherwise an endpoint
  // in the middle of a demo legitimately has a different entity graph.
  restarted = try(restartSoakDemo(session, demoName))
  if restarted is error then shutdown(session); return restarted end if
  gc_collect()
  after = resourceSnapshot(session)
  high = resourceHighWater(high, after)
  stable = resourceStable(before, after) and cycles > 0 and demoMessages > 0
  printResourceSoak("demo", demoName, frameCount, before, after, high, cycles, demoMessages, stable)
  shutdown(session)
  if not stable then return error(3734, "demo resource growth exceeded soak limits") end if
  return true
end function


// Provide opt001a resource header behavior for the active subsystem.
function opt001aResourceHeader()
  return "sample,frame,heap_live,heap_high_water_bytes,heap_live_bytes,heap_free_bytes,edicts,client_entities,active_clients,active_qsockets,free_qsockets,queued_messages,queued_bytes,poll_procedures,udp_endpoints,audio_queued,audio_channels,process_handles,particles,temporary_entities\n"
end function

// Provide opt001a resource row behavior for the active subsystem.
function opt001aResourceRow(sampleName, frameIndex, values)
  result = sampleName + "," + frameIndex
  index = 0
  while index < len(values)
    result = result + "," + values[index]
    index = index + 1
  end while
  return result + "\n"
end function

// Provide opt001a resource json behavior for the active subsystem.
function opt001aResourceJson(values)
  result = "["
  index = 0
  while index < len(values)
    if index > 0 then result = result + "," end if
    result = result + values[index]
    index = index + 1
  end while
  return result + "]"
end function

// Provide opt001a non handle stable behavior for the active subsystem.
function opt001aNonHandleStable(before, after)
  checks = stability.longChecks(before, after)
  index = 0
  while index < 8
    if not checks[index] then return false end if
    index = index + 1
  end while
  return true
end function

// Provide opt001a map parse behavior for the active subsystem.
function opt001aMapParse(baseDirectory, gameDirectory, mapName, outputPrefix)
  commandLine = common.create(["-basedir", baseDirectory, "-game", gameDirectory])
  filesystem = qfs.initializeArguments(baseDirectory, commandLine)
  path = "maps/" + mapName + ".bsp"
  started = native.winTicks()
  data = try(qfs.readFile(filesystem, path))
  readFinished = native.winTicks()
  if data is error then
    qfs.release(filesystem)
    return data
  end if
  parsed = try(bsp.parse(data, path))
  parseFinished = native.winTicks()
  if parsed is error then
    qfs.release(filesystem)
    return parsed
  end if

  json = "{"
  json = json + "\"schema\":\"MiniQuakeOPT001AMapParse/1\","
  json = json + "\"map\":\"" + mapName + "\","
  json = json + "\"game\":\"" + gameDirectory + "\","
  json = json + "\"bytes\":" + len(data) + ","
  json = json + "\"read_ms\":" + (readFinished - started) + ","
  json = json + "\"parse_ms\":" + (parseFinished - readFinished) + ","
  json = json + "\"total_ms\":" + (parseFinished - started) + ","
  json = json + "\"entities\":" + len(parsed.entities) + ","
  json = json + "\"models\":" + len(parsed.models) + ","
  json = json + "\"planes\":" + len(parsed.planes) + ","
  json = json + "\"vertices\":" + len(parsed.vertices) + ","
  json = json + "\"faces\":" + len(parsed.faces) + ","
  json = json + "\"leafs\":" + len(parsed.leafs) + ","
  json = json + "\"mark_surfaces\":" + len(parsed.markSurfaces) + ","
  json = json + "\"textures\":" + len(parsed.textures) + ","
  json = json + "\"clipnodes\":" + len(parsed.clipNodes)
  json = json + "}\n"
  written = try(fs.writeAllText(outputPrefix + "-map-parse.json", json))
  qfs.release(filesystem)
  if written is error then return written end if

  print "MiniQuake OPT-001A map parse"
  print "  map=" + mapName + " game=" + gameDirectory
  print "  bytes=" + len(data)
  print "  read_ms=" + (readFinished - started)
  print "  parse_ms=" + (parseFinished - readFinished)
  print "  total_ms=" + (parseFinished - started)
  print "  faces=" + len(parsed.faces) + " leafs=" + len(parsed.leafs) + " marksurfaces=" + len(parsed.markSurfaces)
  print "  result=PASS"
  return true
end function

// Provide opt001a session arguments behavior for the active subsystem.
function opt001aSessionArguments(baseDirectory, gameDirectory, mapName, mode, port, width, height)
  if mode == "demo" or mode == "demo-audio" then
    arguments = [
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-noautosaveconfig",
      "-window",
      "-nolan",
      "-nomouse",
      "-nojoy",
      "-noinput",
      "-width", "" + width,
      "-height", "" + height,
      "+vid_wait", "0",
      "+gl_finish", "0",
      "+timedemo", mapName,
    ]
    if mode == "demo" then arguments = arguments + ["-nosound"] end if
    return arguments
  end if
  if mode == "render" or mode == "render-audio" then
    arguments = [
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-noautosaveconfig",
      "-window",
      "-nolan",
      "-nomouse",
      "-nojoy",
      "-noinput",
      "-width", "" + width,
      "-height", "" + height,
      "+vid_wait", "0",
      "+gl_finish", "0",
      "+map", mapName,
    ]
    if mode == "render" then arguments = arguments + ["-nosound"] end if
    return arguments
  end if
  if mode == "listen" then
    return [
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-noautosaveconfig",
      "-headless",
      "-nosound",
      "-listen", "8",
      "-ip", "127.0.0.1",
      "-port", "" + port,
      "+map", mapName,
    ]
  end if
  return [
    "-basedir", baseDirectory,
    "-game", gameDirectory,
    "-noautosaveconfig",
    "-headless",
    "-nosound",
    "+map", mapName,
  ]
end function

// Provide opt001a run frames behavior for the active subsystem.
function opt001aRunFrames(session, frameCount, phase)
  index = 0
  checkpoint = 500
  while index < frameCount
    result = try(frame(session, 0.02))
    if result is error then return soakFrameError(session, phase, index, result) end if
    index = index + 1
    if index == checkpoint or index == frameCount then
      print "  " + phase + "_progress=" + index + "/" + frameCount
      checkpoint = checkpoint + 500
    end if
  end while
  return true
end function

// Execute opt001 aframe baseline.
function runOpt001AFrameBaseline(baseDirectory, gameDirectory, mapName, mode, warmupFrames, measureFrames, outputPrefix, rendererName, width, height)
  demoMode = mode == "demo" or mode == "demo-audio"
  renderMode = mode == "render" or mode == "render-audio" or demoMode
  if mode != "headless" and not renderMode then return error(3800, "OPT-001A baseline mode must be headless, render, render-audio, demo or demo-audio") end if
  sessionArguments = opt001aSessionArguments(baseDirectory, gameDirectory, mapName, mode, 26000, width, height)
  if renderMode and rendererName != "" then sessionArguments = sessionArguments + ["-renderer", rendererName] end if
  session = create(sessionArguments)
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if
  if demoMode then
    if session.demoPlayback is void then shutdown(session); return error(3801, "OPT-001A baseline did not start demo " + mapName) end if
  else if not session.server.active then
    shutdown(session); return error(3801, "OPT-001A baseline did not start map " + mapName)
  end if
  if renderMode and not demoMode and (not session.windowCreated or session.renderer is void) then
    shutdown(session)
    return error(3802, "OPT-001A render baseline requires a window and renderer")
  end if

  print "MiniQuake OPT-001A baseline warm-up"
  print "  mode=" + mode + " map=" + mapName + " frames=" + warmupFrames
  warmed = try(opt001aRunFrames(session, warmupFrames, "warmup"))
  if warmed is error then shutdown(session); return warmed end if
  if renderMode and (not session.windowCreated or session.renderer is void) then
    shutdown(session)
    return error(3802, "OPT-001A render baseline requires a window and renderer")
  end if

  // A zero-warmup run measures the real post-load first frame.  Do not insert
  // a synthetic full collection that the interactive engine never performs at
  // this boundary; warmed leak/plateau measurements retain the GC barrier.
  if warmupFrames > 0 then gc_collect() end if
  before = resourceSnapshot(session)
  optBaseline.configure(measureFrames)
  print "MiniQuake OPT-001A baseline measurement"
  print "  mode=" + mode + " map=" + mapName + " frames=" + measureFrames
  measured = try(opt001aRunFrames(session, measureFrames, "measure"))
  optBaseline.disable()
  if measured is error then shutdown(session); return measured end if
  gc_collect()
  after = resourceSnapshot(session)

  written = try(optBaseline.writeReports(outputPrefix, mode, mapName, before, after))
  if written is error then shutdown(session); return written end if
  stats = optBaseline.printSummary(mode, mapName)
  print "  heap_live=" + before[0] + "->" + after[0]
  print "  heap_live_bytes=" + before[2] + "->" + after[2]
  print "  process_handles=" + before[15] + "->" + after[15]
  if stats[0] == measureFrames then print "  result=PASS" else print "  result=FAIL" end if
  shutdown(session)
  if stats[0] == measureFrames then return true end if
  return error(3803, "OPT-001A frame baseline recorded an unexpected frame count")
end function

// Provide opt001b change level trigger behavior for the active subsystem.
function opt001bChangeLevelTrigger(session, destination)
  if session.server.machine is void then return error(3823, "OPT-001B QuakeC VM is unavailable") end if
  triggerIndex = -1
  index = session.server.maxClients + 1
  while index < session.server.numEdicts
    if not session.server.machine.context.edicts.freeFlags[index] then
      className = server.qcString(session.server.machine, index, "classname", "")
      mapName = server.qcString(session.server.machine, index, "map", "")
      if className == "trigger_changelevel" and mapName == destination then
        triggerIndex = index
        break
      end if
    end if
    index = index + 1
  end while
  if triggerIndex < 0 then return error(3823, "OPT-001B trigger_changelevel to " + destination + " is missing") end if
  return triggerIndex
end function

// Execute opt001 bquake cexit.
function runOpt001BQuakeCExit(session, destination, maximumFrames)
  triggerIndex = try(opt001bChangeLevelTrigger(session, destination))
  if triggerIndex is error then return triggerIndex end if

  clientIndex = session.server.clients[0].edictIndex
  if not server.runQcTouch(session.server, triggerIndex, clientIndex) then
    return error(3824, "OPT-001B trigger_changelevel has no touch function")
  end if
  source = session.server.mapName
  frames = 0
  while session.server.mapName == source and frames < maximumFrames
    // Stock Quake leaves a normal intermission after five seconds when the
    // player presses attack or jump. Feed that edge directly to the local
    // server command in this deterministic harness; the ordinary input/network
    // path is independently covered and -noinput must remain in force here.
    if frames == 260 then
      session.server.clients[0].command.buttons = c.BUTTON_ATTACK
      forced = try(server.frameMode(session.server, session.player, 0.02, session.cvars, true))
      if forced is error then return forced end if
      session.server.clients[0].command.buttons = 0
    end if
    advanced = try(frame(session, 0.02))
    if advanced is error then return advanced end if
    frames = frames + 1
  end while
  if session.server.mapName != destination then
    return error(
      3825,
      "OPT-001B QuakeC exit stopped after " + frames + " frames on " +
        session.server.mapName + " (intermission " + screen.SCR_IntermissionMode() +
        ", button0 " + server.qcFloat(session.server.machine, clientIndex, "button0", -1.0) +
        ", running " + qcvm.namedGlobalFloat(session.server.machine, "intermission_running") +
        ", exit " + qcvm.namedGlobalFloat(session.server.machine, "intermission_exittime") +
        ", time " + session.server.time + ")",
    )
  end if
  print "  quakec_exit_frames=" + frames
  return frames
end function

// Execute opt001 btransition.
function runOpt001BTransition(baseDirectory, gameDirectory, frameCount, outputPrefix, rendererName)
  transitionArguments = []
  for each argument in opt001aSessionArguments(baseDirectory, gameDirectory, "start", "render", 26000, 640, 480)
    if argument != "-nosound" then transitionArguments = transitionArguments + [argument] end if
  end for
  if rendererName != "" then transitionArguments = transitionArguments + ["-renderer", rendererName] end if
  session = create(transitionArguments)
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if
  if not session.server.active or session.renderer is void then
    shutdown(session)
    return error(3820, "OPT-001B transition did not initialize start renderer")
  end if

  // Exercise the real preserved-client changelevel path, beginning with the
  // start-map exit that exposed the duplicate PF_changelevel dispatch.
  maps = ["start", "e1m1", "e1m2", "e1m1"]
  json = "{\"schema\":\"MiniQuakeOPT001BTransition/1\",\"maps\":["
  mapIndex = 0
  while mapIndex < len(maps)
    mapName = maps[mapIndex]
    if mapIndex > 0 then
      changed = true
      if mapIndex <= 2 then changed = try(runOpt001BQuakeCExit(session, mapName, 512))
      else changed = try(changeLevel(session, mapName))
      end if
      if changed is error then shutdown(session); return changed end if
    end if
    if session.server.mapName != mapName then
      shutdown(session)
      return error(3821, "OPT-001B transition expected " + mapName + " got " + session.server.mapName)
    end if
    if session.renderer is void or not session.windowCreated then
      shutdown(session)
      return error(3822, "OPT-001B transition missing renderer for " + mapName)
    end if
    renderedBefore = session.renderedFrames
    ran = try(opt001aRunFrames(session, frameCount, "transition_" + mapName))
    if ran is error then shutdown(session); return ran end if
    if session.client.signon != c.SIGNONS then
      shutdown(session)
      return error(3826, "OPT-001B transition left " + mapName + " at client signon " + session.client.signon)
    end if
    if screen.SCR_ShouldSkipUpdate(session.timing.realtime) then
      shutdown(session)
      return error(3827, "OPT-001B transition left the loading plaque active on " + mapName)
    end if
    renderedDelta = session.renderedFrames - renderedBefore
    if renderedDelta != frameCount then
      shutdown(session)
      return error(3828, "OPT-001B transition rendered " + renderedDelta + "/" + frameCount + " playable frames on " + mapName)
    end if
    if mapIndex > 0 then json = json + "," end if
    json = json + "{\"map\":\"" + mapName + "\",\"frames\":" + frameCount + ",\"renderer\":true}"
    print "MiniQuake OPT-001B transition " + mapName + ": PASS"
    mapIndex = mapIndex + 1
  end while
  json = json + "],\"result\":\"PASS\"}\n"
  written = try(fs.writeAllText(outputPrefix + "-summary.json", json))
  shutdown(session)
  if written is error then return written end if
  return true
end function

// Execute renderer switch smoke.
function runRendererSwitchSmoke(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
  sessionArguments = opt001aSessionArguments(baseDirectory, gameDirectory, mapName, "render", 26000, 640, 480)
  sessionArguments = sessionArguments + ["-renderer", "opengl"]
  session = create(sessionArguments)
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if

  backends = [win.RENDER_OPENGL, win.RENDER_DIRECT3D9, win.RENDER_VULKAN, win.RENDER_OPENGL]
  json = "{\"schema\":\"MiniQuakeRendererSwitch/1\",\"map\":\"" + mapName + "\",\"backends\":["
  index = 0
  while index < len(backends)
    backend = backends[index]
    if index > 0 then
      switched = try(restartRenderer(session, backend))
      if switched is error then shutdown(session); return switched end if
    end if
    if win.renderer() != backend or session.renderer is void or not session.windowCreated then
      shutdown(session)
      return error(3935, "renderer switch left an incomplete " + glvid.VID_RendererName(backend) + " scene")
    end if
    ran = try(opt001aRunFrames(session, frameCount, "renderer_" + glvid.VID_RendererName(backend)))
    if ran is error then shutdown(session); return ran end if
    if index > 0 then json = json + "," end if
    json = json + "{\"name\":\"" + glvid.VID_RendererName(backend) + "\",\"frames\":" + frameCount + "}"
    print "MiniQuake renderer switch " + glvid.VID_RendererName(backend) + ": PASS"
    index = index + 1
  end while
  json = json + "],\"result\":\"PASS\"}\n"
  written = try(fs.writeAllText(outputPrefix + "-summary.json", json))
  shutdown(session)
  if written is error then return written end if
  return true
end function

// Execute endscreen evidence.
function runEndscreenEvidence(baseDirectory, gameDirectory, width, height, outputPrefix)
  renderEvidence.reset()
  session = create([
    "-basedir", baseDirectory,
    "-game", gameDirectory,
    "-window",
    "-nosound",
    "-nolan",
    "-nomouse",
    "-nojoy",
    "-noinput",
    "-width", "" + width,
    "-height", "" + height,
    "+vid_wait", "0",
    "+gl_finish", "0",
    "+map", "e1m1",
  ])
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if
  if not session.server.active or session.renderer is void or not session.windowCreated then
    shutdown(session)
    return error(3829, "endscreen evidence did not initialize e1m1 renderer")
  end if

  triggerIndex = try(opt001bChangeLevelTrigger(session, "e1m2"))
  if triggerIndex is error then shutdown(session); return triggerIndex end if
  clientIndex = session.server.clients[0].edictIndex
  if not server.runQcTouch(session.server, triggerIndex, clientIndex) then
    shutdown(session)
    return error(3830, "endscreen evidence could not touch the e1m2 changelevel trigger")
  end if

  targetFrame = session.timing.frameCount + 24
  configured = try(renderEvidence.configure(outputPrefix, targetFrame))
  if configured is error then shutdown(session); renderEvidence.reset(); return configured end if
  index = 0
  failure = void
  while index < 48 and not renderEvidence.captured()
    frameResult = try(frame(session, 0.02))
    if frameResult is error then failure = frameResult; break end if
    index = index + 1
  end while
  result = renderEvidence.lastResult()
  captured = renderEvidence.captured()
  intermission = screen.SCR_IntermissionMode()
  if failure is error then shutdown(session); renderEvidence.reset(); return failure end if
  if intermission != 1 then shutdown(session); renderEvidence.reset(); return error(3831, "endscreen evidence expected intermission mode 1, got " + intermission) end if
  if not captured or result is void then shutdown(session); renderEvidence.reset(); return error(3832, "endscreen evidence framebuffer was not captured") end if

  // Exercise the other endscreen path as well.  The real svc_finale handler
  // installs the text through SCR_SetIntermission; a high print speed makes
  // the complete deterministic sample visible in the next few frames.
  renderEvidence.reset()
  cvar.setValue(session.cvars, "scr_printspeed", 1000.0)
  screen.SCR_SetIntermission(2, "THE DIMENSION OF THE DOOMED\nIS COMPLETE", session.console, session.client.time)
  finaleTarget = session.timing.frameCount + 4
  finaleConfigured = try(renderEvidence.configure(outputPrefix + "-finale", finaleTarget))
  if finaleConfigured is error then shutdown(session); renderEvidence.reset(); return finaleConfigured end if
  finaleIndex = 0
  finaleFailure = void
  while finaleIndex < 8 and not renderEvidence.captured()
    finaleFrame = try(frame(session, 0.02))
    if finaleFrame is error then finaleFailure = finaleFrame; break end if
    finaleIndex = finaleIndex + 1
  end while
  finaleResult = renderEvidence.lastResult()
  finaleCaptured = renderEvidence.captured()
  if finaleFailure is error then shutdown(session); renderEvidence.reset(); return finaleFailure end if
  if screen.SCR_IntermissionMode() != 2 then shutdown(session); renderEvidence.reset(); return error(3833, "endscreen evidence lost finale mode") end if
  if not finaleCaptured or finaleResult is void then shutdown(session); renderEvidence.reset(); return error(3834, "finale evidence framebuffer was not captured") end if

  completePicture = try(draw2d.Draw_CachePic("gfx/complete.lmp"))
  interPicture = try(draw2d.Draw_CachePic("gfx/inter.lmp"))
  numberPicture = statusbar.loadedSbarPicture("num_0")
  slashPicture = statusbar.loadedSbarPicture("num_slash")
  if completePicture is not error then print "  complete_texture=" + completePicture.textureId + " size=" + completePicture.width + "x" + completePicture.height end if
  if interPicture is not error then print "  inter_texture=" + interPicture.textureId + " size=" + interPicture.width + "x" + interPicture.height end if
  if numberPicture is not void then print "  number_texture=" + numberPicture.textureId + " size=" + numberPicture.width + "x" + numberPicture.height end if
  if slashPicture is not void then print "  slash_texture=" + slashPicture.textureId + " size=" + slashPicture.width + "x" + slashPicture.height end if
  shutdown(session)
  renderEvidence.reset()
  print "MiniQuake endscreen evidence: PASS"
  print "  frame=" + result[2] + " dimensions=" + result[3] + "x" + result[4]
  print "  tga=" + result[0]
  print "  summary=" + result[1]
  print "  finale_tga=" + finaleResult[0]
  print "  finale_summary=" + finaleResult[1]
  return true
end function

// Provide capture ui resolution scene behavior for the active subsystem.
function captureUiResolutionScene(session, outputPrefix, expectedWidth, expectedHeight)
  renderEvidence.reset()
  targetFrame = session.timing.frameCount + 1
  configured = try(renderEvidence.configure(outputPrefix, targetFrame))
  if configured is error then return configured end if
  captured = try(frame(session, 0.02))
  if captured is error then renderEvidence.reset(); return captured end if
  result = renderEvidence.lastResult()
  if not renderEvidence.captured() or result is void then
    renderEvidence.reset()
    return error(3835, "UI resolution matrix framebuffer was not captured")
  end if
  if result[3] != expectedWidth or result[4] != expectedHeight then
    renderEvidence.reset()
    return error(
      3836,
      "UI resolution matrix captured " + result[3] + "x" + result[4] +
      " instead of " + expectedWidth + "x" + expectedHeight,
    )
  end if
  if result[8] <= 0 then renderEvidence.reset(); return error(3837, "UI resolution matrix captured an empty framebuffer") end if
  renderEvidence.reset()
  return result
end function

// Provide warm ui resolution scene behavior for the active subsystem.
function warmUiResolutionScene(session)
  index = 0
  while index < 3
    warmed = try(frame(session, 0.02))
    if warmed is error then return warmed end if
    index = index + 1
  end while
  return true
end function

// Execute ui resolution matrix.
function runUiResolutionMatrix(baseDirectory, gameDirectory, outputPrefix)
  session = create([
    "-basedir", baseDirectory,
    "-game", gameDirectory,
    "-window",
    "-nosound",
    "-nolan",
    "-nomouse",
    "-nojoy",
    "-noinput",
    "-width", "640",
    "-height", "480",
    "-maxframes", "1",
    "+vid_wait", "0",
    "+gl_finish", "0",
    "+map", "e1m1",
  ])
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if
  if not session.server.active or session.renderer is void or not session.windowCreated then
    shutdown(session)
    return error(3838, "UI resolution matrix requires a rendered e1m1 session")
  end if

  videoState = glvid.VID_State()
  modeCount = glvid.VID_MenuModeCount()
  if modeCount < 1 then shutdown(session); return error(3839, "UI resolution matrix found no offered display modes") end if
  seenWidths = []
  seenHeights = []
  tested = 0
  captures = 0
  summary = "{\"schema\":\"MiniQuakeUIResolutionMatrix/1\",\"modes\":["
  cvar.setValue(session.cvars, "scr_printspeed", 1000.0)

  modeIndex = 1
  while modeIndex <= modeCount and modeIndex < len(videoState.modes)
    mode = videoState.modes[modeIndex]
    duplicate = false
    seenIndex = 0
    while seenIndex < len(seenWidths)
      if seenWidths[seenIndex] == mode.width and seenHeights[seenIndex] == mode.height then duplicate = true end if
      seenIndex = seenIndex + 1
    end while
    if duplicate then modeIndex = modeIndex + 1; continue end if

    applied = try(glvid.VID_ApplyResolution(modeIndex))
    if applied is error then shutdown(session); renderEvidence.reset(); return applied end if
    win.poll()
    width = win.width()
    height = win.height()
    if width != mode.width or height != mode.height then
      shutdown(session)
      renderEvidence.reset()
      return error(3840, "UI resolution matrix resize produced " + width + "x" + height + " for " + mode.width + "x" + mode.height)
    end if
    seenWidths = seenWidths + [width]
    seenHeights = seenHeights + [height]
    label = "" + width + "x" + height
    prefix = outputPrefix + "-" + label
    print "MiniQuake UI resolution matrix " + label

    // The first frame after a Win32 client resize consumes vid.recalc_refdef.
    // Render it before the HUD evidence frame so the matrix judges the stable
    // viewport rather than the intentionally cleared resize backbuffer.
    screen.SCR_SetIntermission(0, "", session.console, session.client.time)
    setMenuActive(session, false)
    setConsoleActive(session, false)
    screen.SCR_DifferentialSetConsole(0.0, 0.0)
    screen.SCR_CenterPrint(session.console, "", session.client.time)
    warmed = try(frame(session, 0.02))
    if warmed is error then shutdown(session); return warmed end if
    console.Con_Print(session.console, "UI LEGIBILITY " + label + "\n", session.timing.realtime)
    screen.SCR_CenterPrint(session.console, "GAMEPLAY OVERLAY\nREADABLE AT " + label, session.client.time)
    hudResult = try(captureUiResolutionScene(session, prefix + "-hud", width, height))
    if hudResult is error then shutdown(session); return hudResult end if
    screen.SCR_CenterPrint(session.console, "", session.client.time)

    setMenuActive(session, true)
    menu.M_Menu_Main_f(session.menu)
    mainResult = try(captureUiResolutionScene(session, prefix + "-menu-main", width, height))
    if mainResult is error then shutdown(session); return mainResult end if
    menu.M_Menu_Options_f(session.menu)
    optionsResult = try(captureUiResolutionScene(session, prefix + "-menu-options", width, height))
    if optionsResult is error then shutdown(session); return optionsResult end if
    menu.M_Menu_Video_f(session.menu)
    videoResult = try(captureUiResolutionScene(session, prefix + "-menu-video", width, height))
    if videoResult is error then shutdown(session); return videoResult end if
    menu.M_Menu_Help_f(session.menu)
    helpResult = try(captureUiResolutionScene(session, prefix + "-menu-help", width, height))
    if helpResult is error then shutdown(session); return helpResult end if

    setMenuActive(session, false)
    setConsoleActive(session, true)
    screen.SCR_DifferentialSetConsole(height / 2.0, height / 2.0)
    consoleResult = try(captureUiResolutionScene(session, prefix + "-console", width, height))
    if consoleResult is error then shutdown(session); return consoleResult end if

    setConsoleActive(session, false)
    screen.SCR_DifferentialSetConsole(0.0, 0.0)
    // V_CalcIntermissionRefdef deliberately uses the entity origin without
    // adding viewheight because a real svc_intermission first moves the
    // player to info_intermission.  This matrix changes only the UI mode, so
    // provide the already valid eye position and angles while it captures
    // the synthetic endscreen scenes; otherwise the camera sits in the BSP
    // floor and exposes the diagnostic red clear colour at some aspect ratios.
    savedPlayerOrigin = math.copy(session.player.origin)
    savedPlayerAngles = math.copy(session.player.renderAngles)
    session.player.origin = math.copy(session.view.origin)
    session.player.renderAngles = math.copy(session.view.angles)
    screen.SCR_SetIntermission(1, "", session.console, session.client.time)
    intermissionWarm = try(warmUiResolutionScene(session))
    if intermissionWarm is error then shutdown(session); return intermissionWarm end if
    intermissionResult = try(captureUiResolutionScene(session, prefix + "-intermission", width, height))
    if intermissionResult is error then shutdown(session); return intermissionResult end if
    screen.SCR_SetIntermission(2, "THE DIMENSION OF THE DOOMED\nIS COMPLETE", session.console, session.client.time)
    finaleWarm = try(warmUiResolutionScene(session))
    if finaleWarm is error then shutdown(session); return finaleWarm end if
    finaleResult = try(captureUiResolutionScene(session, prefix + "-finale", width, height))
    if finaleResult is error then shutdown(session); return finaleResult end if
    session.player.origin = savedPlayerOrigin
    session.player.renderAngles = savedPlayerAngles
    screen.SCR_SetIntermission(0, "", session.console, session.client.time)

    if tested > 0 then summary = summary + "," end if
    summary = summary + "{\"mode\":" + modeIndex + ",\"width\":" + width + ",\"height\":" + height + ",\"scenes\":8,\"ok\":true}"
    tested = tested + 1
    captures = captures + 8
    modeIndex = modeIndex + 1
  end while

  summary = summary + "],\"tested_resolutions\":" + tested + ",\"captures\":" + captures + ",\"result\":\"PASS\"}\n"
  written = try(fs.writeAllText(outputPrefix + "-summary.json", summary))
  shutdown(session)
  renderEvidence.reset()
  if written is error then return written end if
  print "MiniQuake UI resolution matrix: PASS"
  print "  resolutions=" + tested + " captures=" + captures
  print "  summary=" + outputPrefix + "-summary.json"
  return true
end function

// Execute opt001 ahandle plateau.
function runOpt001AHandlePlateau(baseDirectory, gameDirectory, mapName, warmupFrames, windowFrames, windowCount, port, outputPrefix, rendererName)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if windowCount < 3 then windowCount = 3 end if
  mode = "listen"
  if rendererName != "" then mode = "render" end if
  sessionArguments = opt001aSessionArguments(baseDirectory, gameDirectory, mapName, mode, port, 640, 480)
  if rendererName != "" then sessionArguments = sessionArguments + ["-renderer", rendererName] end if
  session = create(sessionArguments)
  initialized = try(initialize(session))
  if initialized is error then shutdown(session); return initialized end if
  if not session.server.active then shutdown(session); return error(3810, "OPT-001A plateau test did not start map " + mapName) end if

  print "MiniQuake OPT-001A handle plateau warm-up"
  print "  map=" + mapName + " frames=" + warmupFrames
  warmed = try(opt001aRunFrames(session, warmupFrames, "plateau_warmup"))
  if warmed is error then shutdown(session); return warmed end if

  gc_collect()
  endpoints = array(windowCount + 1)
  handles = array(windowCount + 1, 0)
  baseline = resourceSnapshot(session)
  endpoints[0] = baseline
  handles[0] = baseline[15]
  csv = opt001aResourceHeader()
  csv = csv + opt001aResourceRow("baseline", 0, baseline)

  window = 0
  absoluteFrame = 0
  while window < windowCount
    print "MiniQuake OPT-001A handle window"
    print "  window=" + (window + 1) + "/" + windowCount + " frames=" + windowFrames
    frameIndex = 0
    while frameIndex < windowFrames
      result = try(frame(session, 0.02))
      if result is error then
        failure = soakFrameError(session, "plateau window " + window, frameIndex, result)
        shutdown(session)
        return failure
      end if
      frameIndex = frameIndex + 1
      absoluteFrame = absoluteFrame + 1
      if frameIndex % 100 == 0 or frameIndex == windowFrames then
        sample = resourceSnapshot(session)
        csv = csv + opt001aResourceRow("window" + (window + 1), absoluteFrame, sample)
      end if
      if frameIndex % 1000 == 0 or frameIndex == windowFrames then
        print "  plateau_progress=" + frameIndex + "/" + windowFrames
      end if
    end while
    gc_collect()
    endpoint = resourceSnapshot(session)
    endpoints[window + 1] = endpoint
    handles[window + 1] = endpoint[15]
    csv = csv + opt001aResourceRow("window" + (window + 1) + "_end", absoluteFrame, endpoint)
    print "  window_handles=" + endpoint[15]
    window = window + 1
  end while

  finalSnapshot = endpoints[windowCount]
  nonHandleStable = opt001aNonHandleStable(baseline, finalSnapshot)
  classification = optBaseline.classifyHandles(handles, nonHandleStable)
  pass = classification == "STABLE" or classification == "PLATEAU"

  csvResult = try(fs.writeAllText(outputPrefix + "-resources.csv", csv))
  if csvResult is error then shutdown(session); return csvResult end if

  json = "{"
  json = json + "\"schema\":\"MiniQuakeOPT001AHandlePlateau/1\","
  json = json + "\"map\":\"" + mapName + "\","
  json = json + "\"warmup_frames\":" + warmupFrames + ","
  json = json + "\"window_frames\":" + windowFrames + ","
  json = json + "\"window_count\":" + windowCount + ","
  json = json + "\"handle_sequence\":\"" + optBaseline.handleSequenceText(handles) + "\","
  json = json + "\"classification\":\"" + classification + "\","
  json = json + "\"non_handle_stable\":" + optBaseline.boolText(nonHandleStable) + ","
  json = json + "\"baseline\":" + opt001aResourceJson(baseline) + ","
  json = json + "\"final\":" + opt001aResourceJson(finalSnapshot)
  json = json + "}\n"
  jsonResult = try(fs.writeAllText(outputPrefix + "-summary.json", json))
  if jsonResult is error then shutdown(session); return jsonResult end if

  print "MiniQuake OPT-001A handle plateau"
  print "  handles=" + optBaseline.handleSequenceText(handles)
  print "  non_handle_stable=" + nonHandleStable
  print "  classification=" + classification
  if pass then print "  result=PASS" else print "  result=FAIL" end if
  shutdown(session)
  if pass then return true end if
  return error(3811, "OPT-001A handle classification " + classification)
end function


// Execute long soak.
function runLongSoak(baseDirectory, gameDirectory, mode, target, frameCount, port)
  if mode == "listen" then
    return runServerModeSoak([
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-headless",
      "-nosound",
      "-listen", "8",
      "-port", "" + port,
      "+map", target,
    ], mode, target, frameCount)
  end if
  if mode == "dedicated" then
    return runServerModeSoak([
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-dedicated", "8",
      "-nosound",
      "-port", "" + port,
      "+map", target,
    ], mode, target, frameCount)
  end if
  if mode == "demo" then
    return runDemoModeSoak([
      "-basedir", baseDirectory,
      "-game", gameDirectory,
      "-headless",
      "-nosound",
      "+playdemo", target,
    ], target, frameCount)
  end if
  return error(3735, "unknown long soak mode " + mode)
end function

// Provide soak behavior for the active subsystem.
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

// Execute soak.
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
// Execute render evidence.
function runRenderEvidence(args, frameCount, outputPrefix)
  renderEvidence.reset()
  configured = try(renderEvidence.configure(outputPrefix, frameCount))
  if configured is error then print "MiniQuake render evidence: " + configured.message; return 2 end if

  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    print "Host_Init: " + initialized.message
    shutdown(session)
    renderEvidence.reset()
    return 2
  end if
  if not session.windowCreated or session.renderer is void then
    print "MiniQuake render evidence: rendered window and world renderer are required"
    shutdown(session)
    renderEvidence.reset()
    return 2
  end if
  if not session.server.active and session.demoPlayback is void then
    print "MiniQuake render evidence: no map or demo started"
    shutdown(session)
    renderEvidence.reset()
    return 2
  end if

  // Start the visible deterministic run from a known input state.  The
  // per-frame -noinput guard below keeps it clear even when the evidence
  // window receives focus while the two independent processes execute.
  keys.Key_ClearStates()
  input.IN_ClearStates()
  input.clear(session.client.command)

  index = 0
  failure = void
  while index < frameCount and not renderEvidence.captured()
    if session.windowCreated and not win.poll() then
      failure = error(3740, "render evidence window closed before capture")
      break
    end if
    frameResult = try(frame(session, 0.02))
    if frameResult is error then
      failure = frameResult
      break
    end if
    index = index + 1
  end while

  result = renderEvidence.lastResult()
  captured = renderEvidence.captured()
  shutdown(session)
  renderEvidence.reset()

  if failure is error then
    print "MiniQuake render evidence: " + failure.message
    return 3
  end if
  if not captured or result is void then
    print "MiniQuake render evidence: target frame was not captured"
    return 3
  end if
  print "MiniQuake render evidence: PASS"
  print "  frame=" + result[2] + " dimensions=" + result[3] + "x" + result[4]
  print "  pixel_hash=" + compatDiagnostics.u32Hex(result[5]) + " sample_hash=" + compatDiagnostics.u32Hex(result[7])
  print "  non_black_pixels=" + result[8]
  print "  tga=" + result[0]
  print "  summary=" + result[1]
  return 0
end function



// Provide interop bool behavior for the active subsystem.
function interopBool(value)
  if value then return "true" end if
  return "false"
end function

// Return interop write summary derived from the active module state.
function interopWriteSummary(
  outputPrefix,
  mode,
  success,
  frames,
  address,
  port,
  mapName,
  connected,
  spawned,
  signon,
  clientName,
  viewEntity,
  modelCount,
  soundCount,
  activeClients,
  errorText,
)
  path = outputPrefix + "-summary.json"
  text = "{\n"
  text = text + "  \"schema_version\": 1,\n"
  text = text + "  \"mode\": " + compatDiagnostics.jsonString(mode) + ",\n"
  text = text + "  \"success\": " + interopBool(success) + ",\n"
  text = text + "  \"frames\": " + frames + ",\n"
  text = text + "  \"address\": " + compatDiagnostics.jsonString(address) + ",\n"
  text = text + "  \"port\": " + port + ",\n"
  text = text + "  \"map\": " + compatDiagnostics.jsonString(mapName) + ",\n"
  text = text + "  \"connected\": " + interopBool(connected) + ",\n"
  text = text + "  \"spawned\": " + interopBool(spawned) + ",\n"
  text = text + "  \"signon\": " + signon + ",\n"
  text = text + "  \"client_name\": " + compatDiagnostics.jsonString(clientName) + ",\n"
  text = text + "  \"view_entity\": " + viewEntity + ",\n"
  text = text + "  \"model_count\": " + modelCount + ",\n"
  text = text + "  \"sound_count\": " + soundCount + ",\n"
  text = text + "  \"active_clients\": " + activeClients + ",\n"
  text = text + "  \"protocol\": " + c.PROTOCOL_VERSION + ",\n"
  text = text + "  \"control_protocol\": " + externalReference.ORIGINAL_CONTROL_PROTOCOL + ",\n"
  text = text + "  \"error\": " + compatDiagnostics.jsonString(errorText) + "\n"
  text = text + "}\n"
  written = try(fs.writeAllText(path, text))
  if written is error then return written end if
  return path
end function

// Provide interop write ready behavior for the active subsystem.
function interopWriteReady(outputPrefix, port, mapName)
  path = outputPrefix + "-ready.json"
  text = "{\n"
  text = text + "  \"schema_version\": 1,\n"
  text = text + "  \"ready\": true,\n"
  text = text + "  \"port\": " + port + ",\n"
  text = text + "  \"map\": " + compatDiagnostics.jsonString(mapName) + "\n"
  text = text + "}\n"
  written = try(fs.writeAllText(path, text))
  if written is error then return written end if
  return path
end function

// Return first remote server client for the active module state.
function firstRemoteServerClient(session)
  for each serverClient in session.server.clients
    if serverClient.active and serverClient.socket is not void and serverClient.socket.transport == "udp" then
      return serverClient
    end if
  end for
  return void
end function

// Execute original interop server.
function runOriginalInteropServer(args, maximumFrames, outputPrefix)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    reportError = try(interopWriteSummary(
      outputPrefix,
      "miniquake_server_original_client",
      false,
      0,
      "",
      0,
      "",
      false,
      false,
      0,
      "",
      0,
      0,
      0,
      0,
      initialized.message,
    ))
    shutdown(session)
    print "MiniQuake original-client interop server: " + initialized.message
    return 3
  end if
  if not session.server.active or session.network.listener is void then
    reportError = try(interopWriteSummary(
      outputPrefix,
      "miniquake_server_original_client",
      false,
      0,
      "",
      0,
      session.server.mapName,
      false,
      false,
      0,
      "",
      0,
      0,
      0,
      0,
      "dedicated UDP server did not start",
    ))
    shutdown(session)
    print "MiniQuake original-client interop server: dedicated UDP server did not start"
    return 3
  end if

  port = session.network.listener.port
  readyReport = try(interopWriteReady(outputPrefix, port, session.server.mapName))
  if readyReport is error then
    shutdown(session)
    print "MiniQuake original-client interop server: " + readyReport.message
    return 3
  end if
  print "MiniQuake original-client interop server"
  print "  ready=true port=" + port + " map=" + session.server.mapName
  print "  ready_report=" + readyReport
  index = 0
  postFrames = 0
  success = false
  failure = ""
  remote = void
  while index < maximumFrames
    frameResult = try(frame(session, 0.02))
    if frameResult is error then failure = frameResult.message; break end if
    remote = firstRemoteServerClient(session)
    if remote is not void and remote.spawned then
      postFrames = postFrames + 1
      if postFrames >= externalReference.ORIGINAL_INTEROP_POST_FRAMES then success = true; break end if
    end if
    win.sleep(1)
    index = index + 1
  end while

  address = ""
  name = ""
  signon = 0
  spawned = false
  connected = false
  if remote is not void then
    connected = remote.active
    spawned = remote.spawned
    signon = remote.signonStage
    name = remote.name
    if remote.socket is not void then address = remote.socket.address + ":" + remote.socket.port end if
  end if
  if not success and failure == "" then failure = "original client did not complete signon" end if
  report = try(interopWriteSummary(
    outputPrefix,
    "miniquake_server_original_client",
    success,
    index,
    address,
    port,
    session.server.mapName,
    connected,
    spawned,
    signon,
    name,
    0,
    len(session.server.modelPrecache),
    len(session.server.soundPrecache),
    activeServerClients(session),
    failure,
  ))
  shutdown(session)
  if report is error then print "MiniQuake original-client interop server: " + report.message; return 3 end if
  print "  connected=" + interopBool(connected) + " spawned=" + interopBool(spawned) + " signon=" + signon
  print "  client=" + name + " address=" + address
  print "  summary=" + report
  if success then print "  result=PASS"; return 0 end if
  print "  error=" + failure
  print "  result=FAIL"
  return 3
end function

// Provide original interop client network provenance behavior for the active subsystem.
function originalInteropClientNetworkProvenance(session, controlAddress)
  transport = "none"
  remoteAddress = ""
  if session.client.socket is not void then
    transport = session.client.socket.transport
    remoteAddress = session.client.socket.address
  end if
  return externalReference.originalServerInteropNetworkProvenance(
    transport,
    remoteAddress,
    controlAddress,
    session.server.active,
    session.client.localAuthoritative,
    session.client.demoPlayback,
  )
end function

// Execute original interop client.
function runOriginalInteropClient(args, maximumFrames, outputPrefix, controlAddress, controlPort)
  session = create(args)
  initialized = try(initialize(session))
  if initialized is error then
    reportError = try(interopWriteSummary(
      outputPrefix,
      "miniquake_client_original_server",
      false,
      0,
      controlAddress,
      controlPort,
      "",
      false,
      false,
      0,
      "",
      0,
      0,
      0,
      0,
      initialized.message,
    ))
    shutdown(session)
    print "MiniQuake original-server interop client: " + initialized.message
    return 3
  end if

  targetHost = controlAddress + ":" + controlPort
  // R13 normally establishes this connection during Host_Init, before the
  // local fallback. Keep the explicit call as a defensive compatibility
  // path for direct callers that do not pass -original-interop-target.
  strictConnection = true
  if not session.client.connected then
    strictConnection = try(connectRemoteHostInterop(session, targetHost, 20000, 500))
  else
    print "MiniQuake original interop connection established during Host_Init"
  end if
  if strictConnection is error then
    reportError = try(interopWriteSummary(
      outputPrefix,
      "miniquake_client_original_server",
      false,
      0,
      controlAddress,
      controlPort,
      "",
      false,
      false,
      0,
      "",
      0,
      0,
      0,
      0,
      strictConnection.message,
    ))
    shutdown(session)
    print "MiniQuake original-server interop client"
    print "  target=" + targetHost
    print "  error=" + strictConnection.message
    print "  result=FAIL"
    return 3
  end if

  print "MiniQuake original-server interop client"
  print "  target=" + controlAddress + ":" + controlPort
  index = 0
  postFrames = 0
  success = false
  failure = ""
  while index < maximumFrames
    frameResult = try(frame(session, 0.02))
    if frameResult is error then failure = frameResult.message; break end if
    if session.client.connected and session.client.signon == c.SIGNONS and session.client.spawned then
      if not originalInteropClientNetworkProvenance(session, controlAddress) then
        failure = "original-server interop completed signon without target UDP provenance"
        break
      end if
      postFrames = postFrames + 1
      if postFrames >= externalReference.ORIGINAL_INTEROP_POST_FRAMES then success = true; break end if
    end if
    win.sleep(1)
    index = index + 1
  end while
  if not success and failure == "" then failure = "MiniQuake client did not complete original-server signon" end if
  report = try(interopWriteSummary(
    outputPrefix,
    "miniquake_client_original_server",
    success,
    index,
    controlAddress,
    controlPort,
    session.client.levelName,
    session.client.connected,
    session.client.spawned,
    session.client.signon,
    session.client.name,
    session.client.viewEntity,
    len(session.client.modelPrecache),
    len(session.client.soundPrecache),
    0,
    failure,
  ))
  connected = session.client.connected
  spawned = session.client.spawned
  signon = session.client.signon
  levelName = session.client.levelName
  viewEntity = session.client.viewEntity
  modelCount = len(session.client.modelPrecache)
  soundCount = len(session.client.soundPrecache)
  transport = "none"
  remoteAddress = ""
  remotePort = 0
  if session.client.socket is not void then
    transport = session.client.socket.transport
    remoteAddress = session.client.socket.address
    remotePort = session.client.socket.port
  end if
  localServerActive = session.server.active
  localAuthoritative = session.client.localAuthoritative
  demoPlayback = session.client.demoPlayback
  networkProvenance = originalInteropClientNetworkProvenance(session, controlAddress)
  shutdown(session)
  if report is error then print "MiniQuake original-server interop client: " + report.message; return 3 end if
  print "  connected=" + interopBool(connected) + " spawned=" + interopBool(spawned) + " signon=" + signon
  print "  level=" + levelName + " view_entity=" + viewEntity
  print "  models=" + modelCount + " sounds=" + soundCount
  print "  transport=" + transport + " remote=" + remoteAddress + ":" + remotePort
  print "  local_server_active=" + interopBool(localServerActive) + " local_authoritative=" + interopBool(localAuthoritative) + " demo_playback=" + interopBool(demoPlayback)
  if networkProvenance then print "  network_provenance=target_udp" else print "  network_provenance=invalid" end if
  print "  summary=" + report
  if success then print "  result=PASS"; return 0 end if
  print "  error=" + failure
  print "  result=FAIL"
  return 3
end function

// Execute headless frames.
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
      stage = "before-filter"
      if len(session.frameTrace) > 0 then stage = session.frameTrace[len(session.frameTrace) - 1] end if
      print "Host_Frame " + index + " [" + stage + "]: " + frameResult.message
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
