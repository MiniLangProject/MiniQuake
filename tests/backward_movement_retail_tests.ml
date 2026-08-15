/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regression for backward movement across a preserved-client changelevel.
*/
import miniquake.constants as c
import miniquake.host as host
import miniquake.input as input
import miniquake.mathlib as math
import miniquake.screen as screen
import miniquake.server as server

// Shut down the retail session and report a failed invariant.
function fail(session, message)
  host.shutdown(session)
  print "MiniQuake backward movement retail test: FAIL"
  print "  " + message
  return 1
end function

// Run a real id1 changelevel and verify that S produces negative forward motion.
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

  changed = try(host.changeLevel(session, "e1m2"))
  if changed is error then return fail(session, changed.message) end if
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
  input.IN_BackDown(115)
  frameIndex = 0
  while frameIndex < 12
    result = try(host.frame(session, 0.02))
    if result is error then return fail(session, result.message) end if
    frameIndex = frameIndex + 1
  end while
  input.IN_BackUp(115)

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

  host.shutdown(session)
  print "MiniQuake backward movement retail test: PASS"
  print "  map=e1m2 forwardmove=" + serverForwardMove + " forward_displacement=" + backwardDistance
  return 0
end function
