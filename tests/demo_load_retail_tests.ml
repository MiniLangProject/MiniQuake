/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Retail regression for loading a save while an attract demo owns the client.
*/
import miniquake.host as host
import miniquake.cmd as cmd

// Shut down the retail session and report a failed demo-to-load invariant.
function loadFail(session, message)
  host.shutdown(session)
  print "MiniQuake demo-load retail test: FAIL"
  print "  " + message
  return 1
end function

// Load a real save from active demo playback and require stable local frames.
function main(args)
  if len(args) < 2 then
    print "usage: MiniQuakeDemoLoadRetailTests.exe BASE SAVE [GAME]"
    return 2
  end if
  // Reproduce all three ownership phases explicitly: a live local server,
  // an attract-demo client, and the restored save's new loopback client.
  game = "id1"
  if len(args) > 2 then game = args[2] end if
  session = host.create([
    "-basedir", args[0], "-game", game, "-headless", "-nosound", "+map", "e1m1",
  ])
  initialized = try(host.initialize(session))
  if initialized is error then return loadFail(session, initialized.message) end if

  playing = try(host.playDemo(session, "demo1", false))
  if playing is error then return loadFail(session, "attract demo: " + playing.message) end if
  if session.demoPlayback is void then return loadFail(session, "demo playback did not become active") end if
  session.demoNumber = 1
  cmd.addText(session.commands, "playdemo demo2\n")

  loaded = try(host.loadGame(session, args[1]))
  if loaded is error then return loadFail(session, "load from demo: " + loaded.message) end if
  if session.demoPlayback is not void then return loadFail(session, "old DemoPlayback survived load") end if
  if session.demoNumber != -1 then return loadFail(session, "attract loop remained armed") end if
  if not session.server.active then return loadFail(session, "loaded server is inactive") end if
  if not session.client.connected then return loadFail(session, "loaded client is disconnected") end if
  if not session.client.localAuthoritative then return loadFail(session, "loaded client retained demo authority") end if

  frameIndex = 0
  while frameIndex < 16
    frameResult = try(host.frame(session, 0.02))
    if frameResult is error then return loadFail(session, "post-load frame: " + frameResult.message) end if
    if session.demoPlayback is not void then return loadFail(session, "queued attract demo restarted") end if
    if not session.server.active or not session.client.connected then
      return loadFail(session, "loaded game disconnected during stabilization")
    end if
    frameIndex = frameIndex + 1
  end while

  print "loaded map=" + session.server.mapName + " signon=" + session.client.signon + " frames=" + frameIndex
  host.shutdown(session)
  print "MiniQuake demo-load retail test: PASS"
  return 0
end function
