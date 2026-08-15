/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regression for backward movement across a preserved-client changelevel.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.input as input
import miniquake.keys as keys
import miniquake.mathlib as math
import miniquake.menu as menu
import miniquake.platform.win32 as win
import miniquake.screen as screen
import miniquake.server as server

// Shut down the retail session and report a failed invariant.
function fail(session, message)
  host.shutdown(session)
  print "MiniQuake backward movement retail test: FAIL"
  print "  " + message
  return 1
end function

// Queue one real scan-code event through Host::processConsoleInput without
// creating a renderer window for this otherwise headless retail fixture.
function queueArrowEvent(session, scanCode, down)
  value = 0
  if down then value = 1 end if
  win.inputTestPush(5, scanCode, value)
  session.windowCreated = true
  host.processConsoleInput(session)
  session.windowCreated = false
  return true
end function

// Run a real id1 changelevel and verify both original arrow movement binds.
function main(args)
  if len(args) < 1 then
    print "usage: MiniQuakeBackwardMovementRetailTests.exe BASE [GAME]"
    return 2
  end if
  game = "id1"
  if len(args) > 1 then game = args[1] end if
  session = host.create([
    "-basedir", args[0], "-game", game, "-headless", "-nosound", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, initialized.message) end if

  // Reproduce the directory-only launch path before testing ordinary map
  // movement: the attract loop replaces the integrated client with a remote-
  // style demo client. Starting New Game must restore local authority before
  // Protocol 15 begins feeding snapshots into the shared server PlayerState.
  playingDemo = try(host.playDemo(session, "demo1", false))
  if playingDemo is error then return fail(session, "attract demo did not start: " + playingDemo.message) end if
  if session.demoPlayback is void then return fail(session, "attract demo playback was not active") end if
  if session.client.localAuthoritative then return fail(session, "demo client incorrectly retained local authority") end if
  host.setMenuActive(session, true)
  menu.M_Menu_SinglePlayer_f(session.menu)
  if not host.executeMenuSelection(session) then return fail(session, "New Game menu selection was rejected") end if
  newGameFrame = try(host.frame(session, 0.02))
  if newGameFrame is error then return fail(session, "New Game after attract demo failed: " + newGameFrame.message) end if
  if session.server.mapName != "start" then return fail(session, "New Game menu selection did not load start") end if
  if not session.client.localAuthoritative then return fail(session, "New Game retained the non-authoritative demo client") end if

  // Prove the user-visible symptom immediately on the first New Game map,
  // before a second transition could accidentally repair the client state.
  session.player.moveType = c.MOVETYPE_NOCLIP
  session.player.noclip = true
  session.client.command.viewAngles = math.copy(session.player.viewAngles)
  attractForward = math.angleVectors(session.client.command.viewAngles)[0]
  attractStart = math.copy(session.player.origin)
  input.IN_ClearStates()
  keys.setDestination(keys.KEY_GAME)
  queueArrowEvent(session, 72, true)
  attractFrame = 0
  while attractFrame < 12
    attractResult = try(host.frame(session, 0.02))
    if attractResult is error then return fail(session, attractResult.message) end if
    attractFrame = attractFrame + 1
  end while
  queueArrowEvent(session, 72, false)
  attractDisplacement = math.subtract(session.player.origin, attractStart)
  attractForwardDistance = math.dot(attractDisplacement, attractForward)
  if session.server.clients[0].command.forwardMove <= 0.0 then return fail(session, "New Game after attract demo lost UPARROW forwardmove") end if
  if attractForwardDistance <= 0.5 then return fail(session, "New Game after attract demo did not move forward") end if

  restoredMap = try(host.Host_Map_f(session, ["map", "e1m1"]))
  if restoredMap is error then return fail(session, restoredMap.message) end if

  // A mistyped in-game map command must not enter the destructive transition
  // path. Keep the real retail e1m1 server, loopback signon and screen state
  // intact while reporting the missing BSP to the console.
  currentMap = session.server.mapName
  currentModel = session.server.modelName
  currentEdicts = session.server.numEdicts
  currentTime = session.server.time
  currentSignon = session.client.signon
  missing = try(host.Host_Map_f(session, ["map", "__miniquake_missing_map__"]))
  if missing is error then return fail(session, "missing map command raised: " + missing.message) end if
  if missing then return fail(session, "missing map command was accepted") end if
  if not session.server.active then return fail(session, "missing map stopped the active server") end if
  if not session.client.connected then return fail(session, "missing map disconnected the client") end if
  if session.server.mapName != currentMap then return fail(session, "missing map replaced the current map") end if
  if session.server.modelName != currentModel then return fail(session, "missing map replaced the world model") end if
  if session.server.numEdicts != currentEdicts then return fail(session, "missing map changed the edict table") end if
  if session.server.time != currentTime then return fail(session, "missing map advanced server time") end if
  if session.client.signon != currentSignon then return fail(session, "missing map changed client signon") end if
  if screen.SCR_DrawLoading(320, 200) then return fail(session, "missing map displayed LOADING") end if

  // Reproduce the failure: an old-map teleport gate used to survive while the
  // replacement server restarted its clock near one second.
  session.player.teleportTime = 500.0
  session.player.flags = session.player.flags | c.FL_WATERJUMP
  session.player.moveDir.x = 80.0
  if session.server.machine is not void then
    clientIndex = session.server.clients[0].edictIndex
    server.setQcEntityFloat(session.server, clientIndex, "teleport_time", 500.0)
    server.setQcEntityFloat(session.server, clientIndex, "flags", session.player.flags)
    server.setQcEntityVector(session.server, clientIndex, "movedir", session.player.moveDir)
  end if

  // Reproduce the interactive New Game/changelevel handoff. ENTER is also a
  // stock +jump binding, and its ordered key-down used to survive the
  // synchronous load and keep the global gameplay gate armed indefinitely.
  input.bindKey("ENTER", "+jump")
  input.setEventKeyState(keys.K_ENTER, true)
  session.windowCreated = true
  changed = try(host.changeLevel(session, "e1m2"))
  session.windowCreated = false
  if changed is error then return fail(session, changed.message) end if
  if not input.IN_GameplayTransitionBlocked() then return fail(session, "interactive transition gate was not armed") end if
  result = try(host.frame(session, 0.02))
  if result is error then return fail(session, result.message) end if
  if input.IN_GameplayTransitionBlocked() then return fail(session, "stale ENTER retained the transition gate") end if
  if (session.server.clients[0].command.buttons & c.BUTTON_JUMP) != 0 then return fail(session, "menu ENTER leaked into gameplay jump") end if
  if session.player.teleportTime != 0.0 then return fail(session, "old teleport_time survived changelevel") end if
  if (session.player.flags & c.FL_WATERJUMP) != 0 then return fail(session, "old waterjump survived changelevel") end if

  // Noclip removes map geometry from this directional assertion; the command,
  // loopback Protocol-15 packet and authoritative server movement remain real.
  session.player.moveType = c.MOVETYPE_NOCLIP
  session.player.noclip = true
  session.client.command.viewAngles = math.copy(session.player.viewAngles)
  // Movement follows cl.viewangles/usercmd, while the server entity's pitch
  // and yaw are presentation angles and can still contain the prior sample.
  forward = math.angleVectors(session.client.command.viewAngles)[0]
  start = math.copy(session.player.origin)
  input.IN_ClearStates()
  keys.setDestination(keys.KEY_GAME)
  queueArrowEvent(session, 80, true)
  frameIndex = 0
  while frameIndex < 12
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, result.message) end if
    frameIndex = frameIndex + 1
  end while
  queueArrowEvent(session, 80, false)

  displacement = math.subtract(session.player.origin, start)
  backwardDistance = math.dot(displacement, forward)
  serverForwardMove = session.server.clients[0].command.forwardMove
  if serverForwardMove >= 0.0 then return fail(session, "server did not receive negative forwardmove") end if
  if backwardDistance >= -0.5 then
    return fail(
      session,
      "player did not move opposite the view direction: displacement=" +
        displacement.x + "," + displacement.y + "," + displacement.z +
        " forward=" + forward.x + "," + forward.y + "," + forward.z +
        " velocity=" + session.player.velocity.x + "," + session.player.velocity.y + "," + session.player.velocity.z +
        " movetype=" + session.player.moveType + " noclip=" + session.player.noclip +
        " teleport_time=" + session.player.teleportTime + " flags=" + session.player.flags,
    )
  end if

  // Repeat in the opposite direction so both navigation scan codes, bindings,
  // command-buffer dispatch and Protocol-15 movement are covered end to end.
  forwardStart = math.copy(session.player.origin)
  queueArrowEvent(session, 72, true)
  frameIndex = 0
  while frameIndex < 12
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, result.message) end if
    frameIndex = frameIndex + 1
  end while
  queueArrowEvent(session, 72, false)
  forwardDisplacement = math.subtract(session.player.origin, forwardStart)
  forwardDistance = math.dot(forwardDisplacement, forward)
  serverForwardMove = session.server.clients[0].command.forwardMove
  if serverForwardMove <= 0.0 then return fail(session, "server did not receive positive forwardmove") end if
  if forwardDistance <= 0.5 then return fail(session, "UPARROW did not move the player along the view direction") end if

  // Stock keyboard strafing is ALT plus a turn arrow. Verify both bindings,
  // ordered scan events, command construction and server delivery together.
  strafeStart = math.copy(session.player.origin)
  queueArrowEvent(session, 56, true)
  queueArrowEvent(session, 75, true)
  frameIndex = 0
  while frameIndex < 12
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, result.message) end if
    frameIndex = frameIndex + 1
  end while
  serverSideMove = session.server.clients[0].command.sideMove
  queueArrowEvent(session, 75, false)
  queueArrowEvent(session, 56, false)
  strafeDisplacement = math.subtract(session.player.origin, strafeStart)
  strafeDistance = math.dot(strafeDisplacement, math.angleVectors(session.client.command.viewAngles)[1])
  if serverSideMove >= 0.0 then return fail(session, "ALT+LEFTARROW did not send negative sidemove") end if
  if strafeDistance >= -0.5 then return fail(session, "ALT+LEFTARROW did not strafe left") end if

  // SPACE must survive the same transition and reach Protocol 15 button2.
  queueArrowEvent(session, 57, true)
  result = try(host.frame(session, 0.02))
  if result is error then return fail(session, result.message) end if
  serverButtons = session.server.clients[0].command.buttons
  queueArrowEvent(session, 57, false)
  if (serverButtons & c.BUTTON_JUMP) == 0 then return fail(session, "SPACE did not reach the server jump button") end if

  // Exercise gravity at the sub-72-Hz frame intervals seen by an uncapped
  // renderer. One tenth of real simulation time must remain one tenth of
  // server time and apply the full stock 800 units/s^2 acceleration.
  changed = try(host.changeLevel(session, "e1m2"))
  if changed is error then return fail(session, changed.message) end if
  session.player.moveType = c.MOVETYPE_WALK
  session.player.noclip = false
  session.player.origin.z = session.player.origin.z + 32.0
  session.player.velocity.x = 0.0
  session.player.velocity.y = 0.0
  session.player.velocity.z = 0.0
  session.player.flags = session.player.flags & ~c.FL_ONGROUND
  fallStartZ = session.player.origin.z
  fallStartTime = session.server.time
  frameIndex = 0
  while frameIndex < 100
    result = try(host.frame(session, 0.001))
    if result is error then return fail(session, result.message) end if
    frameIndex = frameIndex + 1
  end while
  fallElapsed = session.server.time - fallStartTime
  fallDistance = fallStartZ - session.player.origin.z
  if fallElapsed < 0.099 or fallElapsed > 0.101 then return fail(session, "high-FPS gravity advanced wrong server time: " + fallElapsed) end if
  if session.player.velocity.z > -75.0 then return fail(session, "high-FPS gravity was too slow: velocity=" + session.player.velocity.z) end if
  if fallDistance < 3.5 then return fail(session, "high-FPS fall distance was too small: " + fallDistance) end if

  host.shutdown(session)
  print "MiniQuake backward movement retail test: PASS"
  print "  map=e1m2 forwardmove=" + serverForwardMove + " backward_displacement=" + backwardDistance + " forward_displacement=" + forwardDistance + " sidemove=" + serverSideMove + " strafe_displacement=" + strafeDistance + " jump_buttons=" + serverButtons + " fall_elapsed=" + fallElapsed + " fall_distance=" + fallDistance + " fall_velocity=" + session.player.velocity.z
  return 0
end function
