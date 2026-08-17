/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Cross-process Protocol-15 join, post-signon progress and movement regression.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.input as input
import miniquake.keys as keys
import miniquake.native as native
import miniquake.net_main as netmain
import miniquake.platform.win32 as win
import miniquake.screen as screen

// Shut down a partially initialized client and report a deterministic failure.
function fail(session, message)
  if session is not void then host.shutdown(session) end if
  print "MiniQuake multiplayer live join test: FAIL"
  print "  " + message
  return 1
end function

// Let a BASEDIR-only launch enter and actively play the retail attract loop
// before a later menu action replaces it. Immediate post-initialize actions
// miss the real user's demo-to-network transition and therefore cannot catch
// stale demo, renderer or signon state retained by that path.
function warmAttractMode(session, windowed, frameTarget, label)
  frames = 0
  while frames < frameTarget
    if windowed and not win.poll() then return error(4001, label + " window closed during attract warmup") end if
    result = try(host.frame(session, 0.02))
    if result is error then return error(4002, label + " attract frame: " + result.message) end if
    if windowed then win.sleep(20) else win.sleep(1) end if
    frames = frames + 1
  end while
  if session.demoPlayback is void then return error(4003, label + " never entered attract-demo playback") end if
  return frames
end function

// Start a listen server through the same actions emitted by the multiplayer
// menu. The initial single-player fallback is intentional: it reproduces a
// normal BASEDIR-only launch before the user selects New Game.
function runMenuHost(baseDirectory, port, frameTarget, windowed)
  // Reproduce the user workflow in three explicit phases: initialize the
  // BASEDIR-only attract-mode session, dispatch the listen-server menu action,
  // then sustain rendered host frames while a second process signs on.
  hostArguments = ["--play", baseDirectory, "-game", "id1", "-port", "" + port]
  if windowed then
    hostArguments = hostArguments + ["-window", "-width", "640", "-height", "480", "-noinput", "-noautosaveconfig"]
  else
    hostArguments = hostArguments + ["-nosound", "-headless"]
  end if
  session = host.create(hostArguments)
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, "menu host init: " + initialized.message) end if
  warmed = try(warmAttractMode(session, windowed, 100, "menu host"))
  if warmed is error then return fail(session, warmed.message) end if
  host.setMenuActive(session, true)
  session.menu.lanPort = port
  session.menu.lanPortText = "" + port
  accepted = host.handleExactMenuAction(session, ["begin_game", "start", 4])
  if not accepted then return fail(session, "menu host action was rejected") end if

  frames = 0
  while frames < frameTarget
    if windowed and not win.poll() then return fail(session, "menu host window closed") end if
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, "menu host frame: " + result.message) end if
    if frames == 5 then
      if not session.server.active or session.server.maxClients != 4 or not netmain.listening then
        return fail(session, "menu host did not become a four-player listen server")
      end if
      print "MiniQuake multiplayer menu host: READY"
    end if
    if windowed then win.sleep(20) else win.sleep(1) end if
    frames = frames + 1
  end while

  beforeCollect = host.resourceSnapshot(session)
  collectStarted = native.winTicks()
  gc_collect()
  collectElapsed = native.winTicks() - collectStarted
  afterCollect = host.resourceSnapshot(session)
  print "MiniQuake multiplayer menu host: PASS"
  print "  frames=" + frames + " clients=" + host.activeServerClients(session)
  print "  heap before GC: used=" + beforeCollect[1] + " live=" + beforeCollect[2] + " free=" + beforeCollect[3]
  print "  heap after GC: used=" + afterCollect[1] + " live=" + afterCollect[2] + " free=" + afterCollect[3] + " gc_ms=" + collectElapsed
  host.shutdown(session)
  return 0
end function

// Queue the exact direct-address action emitted by the LAN configuration menu.
function queueMenuJoin(session, hostName, port)
  host.setMenuActive(session, true)
  session.menu.joiningGame = true
  session.menu.lanPort = port
  session.menu.lanPortText = "" + port
  return host.handleExactMenuAction(session, ["connect", hostName])
end function

// Run a real remote client through signon and sustained forward movement.
function main(args)
  if len(args) >= 4 and (args[0] == "host-menu" or args[0] == "host-window-menu") then
    hostPort = toNumber(args[2])
    hostFrames = toNumber(args[3])
    if hostPort is void or hostFrames is void then return fail(void, "invalid menu host numeric argument") end if
    return runMenuHost(args[1], native.trunc(hostPort), native.trunc(hostFrames), args[0] == "host-window-menu")
  end if
  if len(args) < 4 then
    print "usage: multiplayer_live_join_tests BASE HOST PORT POST_FRAMES [menu]"
    print "   or: multiplayer_live_join_tests host-menu BASE PORT FRAMES"
    return 2
  end if
  port = toNumber(args[2])
  postFrameTarget = toNumber(args[3])
  if port is void or postFrameTarget is void then return fail(void, "invalid numeric argument") end if
  target = args[1] + ":" + port
  useMenu = len(args) >= 5 and (args[4] == "menu" or args[4] == "windowed-menu")
  useWindow = len(args) >= 5 and args[4] == "windowed-menu"
  clientArguments = ["--play", args[0], "-game", "id1", "-port", "" + port]
  if useWindow then
    clientArguments = clientArguments + ["-window", "-width", "640", "-height", "480", "-noinput", "-noautosaveconfig"]
  else
    clientArguments = clientArguments + ["-nosound", "-headless"]
  end if
  if not useMenu then clientArguments = clientArguments + ["-original-interop-target", target] end if
  session = host.create(clientArguments)
  initialized = try(host.initialize(session))
  if initialized is error then return fail(session, initialized.message) end if
  if useMenu then
    warmed = try(warmAttractMode(session, useWindow, 100, "menu client"))
    if warmed is error then return fail(session, warmed.message) end if
  end if
  if useMenu and not queueMenuJoin(session, args[1], native.trunc(port)) then
    return fail(session, "menu join action was rejected")
  end if

  signonFrames = 0
  // A menu action is queued for the next host frame. The client may still be
  // the fully signed-on local fallback or attract demo until that frame
  // executes `connect`; do not mistake either old SIGNONS value for completion
  // of the new UDP join.
  remoteSocketReady = not useMenu
  if useMenu and session.client.socket is not void then
    remoteSocketReady = session.client.socket.transport == "udp"
  end if
  while (session.client.signon != c.SIGNONS or not remoteSocketReady) and signonFrames < 2000
    if useWindow and not win.poll() then return fail(session, "client window closed during signon") end if
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, "signon frame: " + result.message) end if
    remoteSocketReady = not useMenu
    if useMenu and session.client.socket is not void then
      remoteSocketReady = session.client.socket.transport == "udp"
    end if
    if useWindow then win.sleep(20) else win.sleep(1) end if
    signonFrames = signonFrames + 1
  end while
  if not session.client.connected or not session.client.spawned or session.client.signon != c.SIGNONS then
    return fail(session, "signon did not complete")
  end if
  if session.server.worldModel is void then return fail(session, "remote world was not prepared after signon") end if
  if useWindow and (session.renderer is void or session.entityRenderer is void) then
    return fail(session, "remote renderers were not rebuilt after leaving the attract demo")
  end if
  if useWindow and (session.menu.active or session.console.active or keys.destination() != keys.KEY_GAME) then
    return fail(
      session,
      "windowed join retained non-game input: menu=" + session.menu.active +
      " console=" + session.console.active + " key_dest=" + keys.destination(),
    )
  end if

  startX = session.player.origin.x
  startY = session.player.origin.y
  startZ = session.player.origin.z
  startClientTime = session.client.time
  startServerTime = session.client.serverTime
  startHostFrames = session.timing.frameCount
  input.IN_ForwardDown(911)
  postFrames = 0
  while postFrames < postFrameTarget
    if useWindow and not win.poll() then input.IN_ForwardUp(911); return fail(session, "client window closed after signon") end if
    result = try(host.frame(session, 0.02))
    if result is error then input.IN_ForwardUp(911); return fail(session, "post-signon frame: " + result.message) end if
    if not session.client.connected or session.client.signon != c.SIGNONS then
      input.IN_ForwardUp(911)
      socketDisconnected = true
      lastReceive = -1.0
      if session.client.socket is not void then
        socketDisconnected = session.client.socket.disconnected
        lastReceive = session.client.socket.lastReceiveTime
      end if
      return fail(
        session,
        "connection dropped after signon: frame=" + postFrames +
        " connected=" + session.client.connected +
        " signon=" + session.client.signon +
        " socket_disconnected=" + socketDisconnected +
        " last_receive=" + lastReceive +
        " realtime=" + session.timing.realtime +
        " status=" + session.statusMessage,
      )
    end if
    if useWindow and (session.menu.active or session.console.active or keys.destination() != keys.KEY_GAME) then
      input.IN_ForwardUp(911)
      return fail(
        session,
        "windowed input destination changed: frame=" + postFrames +
        " menu=" + session.menu.active + " console=" + session.console.active +
        " key_dest=" + keys.destination(),
      )
    end if
    if useWindow then win.sleep(20) else win.sleep(1) end if
    postFrames = postFrames + 1
  end while
  input.IN_ForwardUp(911)
  beforeCollect = host.resourceSnapshot(session)
  collectStarted = native.winTicks()
  gc_collect()
  collectElapsed = native.winTicks() - collectStarted
  afterCollect = host.resourceSnapshot(session)
  print "  heap before GC: used=" + beforeCollect[1] + " live=" + beforeCollect[2] + " free=" + beforeCollect[3]
  print "  heap after GC: used=" + afterCollect[1] + " live=" + afterCollect[2] + " free=" + afterCollect[3] + " gc_ms=" + collectElapsed
  deltaX = session.player.origin.x - startX
  deltaY = session.player.origin.y - startY
  deltaZ = session.player.origin.z - startZ
  distanceSquared = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
  advanced = session.client.time - startClientTime
  serverAdvanced = session.client.serverTime - startServerTime
  hostFrames = session.timing.frameCount - startHostFrames
  if hostFrames < postFrameTarget then return fail(session, "host frame loop stopped advancing: " + hostFrames) end if
  if serverAdvanced < 0.1 then return fail(session, "server snapshots stopped advancing: " + serverAdvanced) end if
  if useWindow then
    screenState = screen.SCR_DifferentialState()
    if screenState[2] > 0.01 or screenState[3] > 0.01 then
      return fail(session, "remote console remained visible after signon: current=" + screenState[2] + " target=" + screenState[3])
    end if
  end if
  // -noinput deliberately clears all button state before CL_BaseMove in the
  // rendered evidence path. Headless mode remains the deterministic movement
  // assertion; the windowed pair verifies real rendering, signon and sustained
  // server-snapshot progress without synthesizing desktop input.
  if not useWindow and distanceSquared < 1.0 then return fail(session, "forward commands did not move the remote player") end if

  print "MiniQuake multiplayer live join test: PASS"
  print "  signon_frames=" + signonFrames + " post_frames=" + postFrames
  print "  client_time_advanced=" + advanced + " server_time_advanced=" + serverAdvanced
  print "  distance_squared=" + distanceSquared
  host.shutdown(session)
  return 0
end function
