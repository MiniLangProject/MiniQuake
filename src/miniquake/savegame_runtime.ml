/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Runtime synchronization for Quake version-5 savegames.

The text parser restores QuakeC globals and edict words.  This module rebuilds
MiniQuake's derived server-edict view without losing the saved sv.num_edicts
high-water mark.  WinQuake preserves that high-water mark even when the final
saved edict blocks are free.
*/
package miniquake.savegame_runtime

import miniquake.server as serverRuntime
import miniquake.server_collision as collision

// Update module state for loaded server.
function synchronizeLoadedServer(server)
  if server.machine is void or server.machine.context is void then
    return error(3790, "loadgame runtime synchronization requires a QuakeC server")
  end if

  savedCount = server.numEdicts
  runtime = server.machine.context.edicts
  if savedCount < 0 or savedCount > runtime.maxEdicts then
    return error(3791, "loadgame edict high-water mark outside runtime: " + savedCount)
  end if

  // The stable mirror keeps the provisional baselines that SV_SpawnServer
  // created, restores every saved slot including trailing free records, and
  // never recomputes the saved high-water mark from freeFlags.
  synchronized = try(serverRuntime.syncLoadedQuakeCEdicts(server, savedCount))
  if synchronized is error then return synchronized end if

  serverRuntime.assignModelIndexes(server)

  // ED_ParseEdict links every restored non-free edict without touching
  // triggers. MiniQuake's linear collision world has no persistent area-node
  // lists, but linkEntity still refreshes the observable absolute bounds.
  index = 0
  while index < savedCount
    if not runtime.freeFlags[index] then
      linked = try(collision.linkEntity(server, index, false))
      if linked is error then return linked end if
    end if
    index = index + 1
  end while

  return savedCount
end function
