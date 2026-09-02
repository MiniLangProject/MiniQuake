/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Runtime-facing compatibility inspection for id1, mission packs and custom
-game directories.  This intentionally accepts arbitrary QuakeC programs that
satisfy the version-6 ABI rather than imposing stock id1 counts on mods.
*/
package miniquake.mod_compat

import miniquake.filesystem as qfs
import miniquake.format.progs as progs
import miniquake.format.bsp as bsp
import miniquake.game_profile as profile
import miniquake.common as common
import std.fs as fs

/// Defines the status value used by `miniquake.mod_compat`.
const STATUS = "mod_runtime_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.mod_compat`.
const FINGERPRINT = 0x4649813d
/// Defines the contract text value used by `miniquake.mod_compat`.
const CONTRACT_TEXT = "mod-runtime|progs-v6|bsp-v29|id1-required|rogue-optional|hipnotic-optional|integrated-host"

/// Implements the `directoryPresent` operation for `miniquake.mod_compat` (directory present).
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameDirectory Selected Quake game-data directory.
function directoryPresent(baseDirectory, gameDirectory)
  return fs.isDir(fs.joinPath(baseDirectory, gameDirectory))
end function

/// Report whether candidate directories.
/// @param baseDirectory Root directory containing the Quake installation.
function candidateDirectories(baseDirectory)
  result = ["id1"]
  if directoryPresent(baseDirectory, "rogue") then result = result + ["rogue"] end if
  if directoryPresent(baseDirectory, "hipnotic") then result = result + ["hipnotic"] end if
  return result
end function

/// Implements the `profileArguments` operation for `miniquake.mod_compat` (profile arguments).
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameDirectory Selected Quake game-data directory.
function profileArguments(baseDirectory, gameDirectory)
  if gameDirectory == "rogue" then return ["-basedir", baseDirectory, "-rogue"] end if
  if gameDirectory == "hipnotic" then return ["-basedir", baseDirectory, "-hipnotic"] end if
  if gameDirectory == "id1" then return ["-basedir", baseDirectory] end if
  return ["-basedir", baseDirectory, "-game", gameDirectory]
end function

/// Implements the `inspect` operation for `miniquake.mod_compat` (inspect).
/// @param baseDirectory Root directory containing the Quake installation.
/// @param gameDirectory Selected Quake game-data directory.
/// @param mapName Name of the map to load or inspect.
function inspect(baseDirectory, gameDirectory, mapName)
  args = profileArguments(baseDirectory, gameDirectory)
  commandLine = common.create(args)
  system = qfs.initializeArguments(baseDirectory, commandLine)
  programBytes = qfs.readFile(system, "progs.dat")
  if programBytes is error then qfs.release(system); return programBytes end if
  program = progs.parse(programBytes, gameDirectory + "/progs.dat")
  if program is error then qfs.release(system); return program end if
  mapPath = "maps/" + mapName + ".bsp"
  mapBytes = qfs.readFile(system, mapPath)
  if mapBytes is error then qfs.release(system); return mapBytes end if
  map = bsp.parse(mapBytes, mapPath)
  if map is error then qfs.release(system); return map end if
  result = [
    gameDirectory,
    profile.isMissionPack(gameDirectory),
    qfs.packFileCount(system),
    program.version,
    program.crc,
    len(program.functions),
    len(program.statements),
    program.entityFields,
    map.version,
    len(map.faces),
    len(map.entities),
    len(map.models),
    qfs.isModified(system),
  ]
  qfs.release(system)
  return result
end function

/// Report whether valid summary.
/// @param summary The summary input consumed by `validSummary`.
function validSummary(summary)
  if summary is not array or len(summary) != 13 then return false end if
  return summary[2] > 0 and summary[3] == 6 and summary[8] == 29 and summary[5] > 0 and summary[9] > 0
end function

/// Implements the `contractVector` operation for `miniquake.mod_compat` (contract vector).
function inline contractVector()
  return [STATUS, FINGERPRINT, 6, 29, ["id1", "rogue", "hipnotic"]]
end function
