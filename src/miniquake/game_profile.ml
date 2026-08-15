/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Source-guided COM_InitFilesystem game-profile helpers.  WinQuake's global
command-line and com_gamedir state is explicit here, while directory order and
mission-pack precedence remain observable and testable.
*/
package miniquake.game_profile

import miniquake.common as common
import miniquake.byteio as bio

const STATUS = "game_profile_109_frozen_v1"
const FINGERPRINT = 0x7a03b68d
const CONTRACT_TEXT = "game-profile|id1-first|rogue-before-hipnotic|explicit-game-last|path-overrides|registered-gate|caching-once"

// Provide requested directories behavior for the active subsystem.
function requestedDirectories(commandLine)
  result = ["id1"]
  if common.hasParm(commandLine, "-rogue") then result = result + ["rogue"] end if
  if common.hasParm(commandLine, "-hipnotic") then result = result + ["hipnotic"] end if
  gamePosition = common.checkParm(commandLine, "-game")
  if gamePosition != 0 and gamePosition < len(commandLine.args) then
    result = result + [commandLine.args[gamePosition]]
  end if
  return result
end function

// Provide effective game directory behavior for the active subsystem.
function effectiveGameDirectory(commandLine)
  directories = requestedDirectories(commandLine)
  return directories[len(directories) - 1]
end function

// Report whether is mission pack.
function isMissionPack(name)
  lower = bio.lower(name)
  return lower == "rogue" or lower == "hipnotic"
end function

// Return mission mode derived from the active module state.
function missionMode(commandLine)
  rogue = common.hasParm(commandLine, "-rogue")
  hipnotic = common.hasParm(commandLine, "-hipnotic")
  if rogue and hipnotic then return "rogue+hipnotic" end if
  if hipnotic then return "hipnotic" end if
  if rogue then return "rogue" end if
  return "id1"
end function

// Provide explicit game behavior for the active subsystem.
function explicitGame(commandLine)
  position = common.checkParm(commandLine, "-game")
  if position == 0 or position >= len(commandLine.args) then return "" end if
  return commandLine.args[position]
end function

// Return path override for the active module state.
function pathOverride(commandLine)
  position = common.checkParm(commandLine, "-path")
  if position == 0 then return [] end if
  result = []
  index = position
  while index < len(commandLine.args)
    value = commandLine.args[index]
    source = bytes(value)
    if len(source) == 0 or source[0] == 43 or source[0] == 45 then break end if
    result = result + [value]
    index = index + 1
  end while
  return result
end function

// Return expected search directory names derived from the active module state.
function expectedSearchDirectoryNames(commandLine)
  override = pathOverride(commandLine)
  if len(override) > 0 then
    // -path inserts each item at the head while scanning left to right.
    reversed = []
    for each value in override
      reversed = [value] + reversed
    end for
    return reversed
  end if
  // COM_AddGameDirectory also inserts at the head.  The final search order is
  // therefore the reverse of the command-line addition order.
  additions = requestedDirectories(commandLine)
  result = []
  for each value in additions
    result = [value] + result
  end for
  return result
end function

// Return profile vector derived from the active module state.
function profileVector(commandLine)
  directories = requestedDirectories(commandLine)
  override = pathOverride(commandLine)
  return [
    STATUS,
    FINGERPRINT,
    directories,
    effectiveGameDirectory(commandLine),
    missionMode(commandLine),
    explicitGame(commandLine),
    override,
    common.hasParm(commandLine, "-proghack"),
  ]
end function
