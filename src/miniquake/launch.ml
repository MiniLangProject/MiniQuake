/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.launch.
*/
package miniquake.launch

import miniquake.types as t
import miniquake.byteio as bio

// Return first byte for the active module state.
function firstByte(text)
  data = bytes(text)
  if len(data) == 0 then return -1 end if
  return data[0]
end function

// Provide substring behavior for the active subsystem.
function substring(text, offset, count)
  data = bytes(text)
  if offset < 0 then offset = 0 end if
  if offset > len(data) then offset = len(data) end if
  if count < 0 then count = 0 end if
  if offset + count > len(data) then count = len(data) - offset end if
  return decode(slice(data, offset, count))
end function

// Convert map name into its canonical representation.
function stripMapName(name)
  value = name
  lower = bio.lower(value)
  source = bytes(value)
  if len(source) >= 5 and substring(lower, 0, 5) == "maps/" then
    value = substring(value, 5, len(source) - 5)
    lower = bio.lower(value)
    source = bytes(value)
  end if
  if len(source) >= 4 and substring(lower, len(source) - 4, 4) == ".bsp" then
    value = substring(value, 0, len(source) - 4)
  end if
  return value
end function

// Provide integer option behavior for the active subsystem.
function integerOption(text, fallback, minimum, maximum)
  value = toNumber(text)
  if value is void or value is not int then return fallback end if
  if value < minimum then return minimum end if
  if value > maximum then return maximum end if
  return value
end function

// Return command name derived from the active module state.
function commandName(text)
  data = bytes(text)
  if len(data) <= 1 then return "" end if
  return bio.lower(decode(slice(data, 1, len(data) - 1)))
end function

// Add state for append plus command.
function appendPlusCommand(commands, args, startIndex)
  text = commandName(args[startIndex])
  index = startIndex + 1
  while index < len(args)
    marker = firstByte(args[index])
    if marker == 43 or marker == 45 then break end if
    text = text + " \"" + args[index] + "\""
    index = index + 1
  end while
  return [commands + [text], index]
end function

// Provide words behavior for the active subsystem.
function words(text)
  source = bytes(text)
  result = []
  index = 0
  while index < len(source)
    while index < len(source) and source[index] <= 32
      index = index + 1
    end while
    if index >= len(source) then break end if
    quoted = false
    if source[index] == 34 then
      quoted = true
      index = index + 1
    end if
    output = bytes(len(source) - index)
    count = 0
    while index < len(source)
      value = source[index]
      if quoted then
        if value == 34 then
          index = index + 1
          break
        end if
      else if value <= 32 then
        break
      end if
      output[count] = value
      count = count + 1
      index = index + 1
    end while
    result = result + [decode(slice(output, 0, count))]
  end while
  return result
end function

// Read and validate the requested value.
function parse(args)
  basedir = "."
  gameDirectory = "id1"
  width = 1280
  height = 720
  fullscreen = false
  noSound = false
  developer = false
  dedicated = false
  skill = 1
  startMap = ""
  plusCommands = []
  maxFrames = 0
  validateOnly = false
  headless = false
  timedemo = false
  explicitGame = false
  rogue = false
  hipnotic = false
  attractStart = false

  index = 0
  while index < len(args)
    argument = args[index]
    lower = bio.lower(argument)

    if lower == "--play" and index + 1 < len(args) then
      basedir = args[index + 1]
      attractStart = true
      index = index + 2
      // The map is intentionally optional. With only a basedir, quake.rc and
      // startdemos retain ownership of startup just as in the original game.
      if index < len(args) and firstByte(args[index]) != 45 and firstByte(args[index]) != 43 then
        startMap = stripMapName(args[index])
        plusCommands = plusCommands + ["map \"" + startMap + "\""]
        attractStart = false
        index = index + 1
      end if
      continue
    else if lower == "--validate-game" and index + 1 < len(args) then
      basedir = args[index + 1]
      validateOnly = true
      if index + 2 < len(args) and firstByte(args[index + 2]) != 45 and firstByte(args[index + 2]) != 43 then
        startMap = stripMapName(args[index + 2])
        index = index + 3
      else
        index = index + 2
      end if
      continue
    else if lower == "-basedir" and index + 1 < len(args) then
      basedir = args[index + 1]
      index = index + 2
      continue
    else if lower == "-game" and index + 1 < len(args) then
      gameDirectory = args[index + 1]
      explicitGame = true
      index = index + 2
      continue
    else if lower == "-width" and index + 1 < len(args) then
      width = integerOption(args[index + 1], width, 320, 8192)
      index = index + 2
      continue
    else if lower == "-height" and index + 1 < len(args) then
      height = integerOption(args[index + 1], height, 200, 8192)
      index = index + 2
      continue
    else if lower == "-skill" and index + 1 < len(args) then
      skill = integerOption(args[index + 1], skill, 0, 3)
      index = index + 2
      continue
    else if lower == "-maxframes" and index + 1 < len(args) then
      maxFrames = integerOption(args[index + 1], 0, 0, 2000000000)
      index = index + 2
      continue
    else if lower == "-fullscreen" then
      fullscreen = true
    else if lower == "-window" or lower == "-windowed" then
      fullscreen = false
    else if lower == "-nosound" then
      noSound = true
    else if lower == "-safe" then
      noSound = true
    else if lower == "-rogue" then
      rogue = true
    else if lower == "-hipnotic" then
      hipnotic = true
    else if lower == "-developer" or lower == "-dev" then
      developer = true
    else if lower == "-dedicated" then
      dedicated = true
      headless = true
    else if lower == "-headless" then
      headless = true
    else if lower == "-timedemo" then
      timedemo = true
    else if firstByte(argument) == 43 then
      parsed = appendPlusCommand(plusCommands, args, index)
      plusCommands = parsed[0]
      index = parsed[1]
      latest = plusCommands[len(plusCommands) - 1]
      latestWords = words(latest)
      if len(latestWords) >= 2 and bio.lower(latestWords[0]) == "map" then
        startMap = stripMapName(latestWords[1])
        attractStart = false
      end if
      continue
    end if
    index = index + 1
  end while

  // COM_InitFilesystem adds mission-pack directories after id1, with
  // hipnotic after rogue, unless an explicit -game directory overrides both.
  if not explicitGame then
    if rogue then gameDirectory = "rogue" end if
    if hipnotic then gameDirectory = "hipnotic" end if
  end if
  if startMap == "" and not attractStart then startMap = "start" end if
  return t.LaunchOptions(
    args,
    basedir,
    gameDirectory,
    width,
    height,
    fullscreen,
    noSound,
    developer,
    dedicated,
    skill,
    startMap,
    plusCommands,
    maxFrames,
    validateOnly,
    headless,
    timedemo,
  )
end function

// Initialize state for startup text.
function startupText(options)
  result = ""
  for each command in options.plusCommands
    result = result + command + "\n"
  end for
  return result
end function

// Report whether parm.
function hasParm(options, name)
  wanted = bio.lower(name)
  for each value in options.originalArgs
    if bio.lower(value) == wanted then return true end if
  end for
  return false
end function
