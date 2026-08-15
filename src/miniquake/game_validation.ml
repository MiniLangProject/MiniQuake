/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.game_validation.
*/
package miniquake.game_validation

import miniquake.types as t
import miniquake.filesystem as qfs
import miniquake.graphics_data as graphicsData
import miniquake.format.bsp as bsp
import miniquake.format.progs as progs
import miniquake.format.mdl as mdl
import miniquake.sound.wav as wav
import miniquake.byteio as bio
import miniquake.host as host
import miniquake.constants as c
import miniquake.world_bsp as world
import miniquake.mathlib as math
import miniquake.common as common

// Add state for append.
function inline append(messages, level, text)
  return messages + [level + " " + text]
end function

// Provide filesystem arguments behavior for the active subsystem.
function filesystemArguments(options)
  // Preserve the full COM_InitFilesystem profile instead of reducing it to
  // only the final com_gamedir.  In particular, -rogue and -hipnotic may both
  // be present before a later -game override.
  source = common.create(options.originalArgs)
  result = ["-basedir", options.basedir]
  if common.hasParm(source, "-rogue") then result = result + ["-rogue"] end if
  if common.hasParm(source, "-hipnotic") then result = result + ["-hipnotic"] end if
  gamePosition = common.checkParm(source, "-game")
  if gamePosition != 0 and gamePosition < len(source.args) then
    result = result + ["-game", source.args[gamePosition]]
  end if
  cachePosition = common.checkParm(source, "-cachedir")
  if cachePosition != 0 and cachePosition < len(source.args) then
    result = result + ["-cachedir", source.args[cachePosition]]
  end if
  if common.hasParm(source, "-proghack") then result = result + ["-proghack"] end if
  pathPosition = common.checkParm(source, "-path")
  if pathPosition != 0 then
    result = result + ["-path"]
    index = pathPosition
    while index < len(source.args)
      value = source.args[index]
      valueBytes = bytes(value)
      if len(valueBytes) == 0 or valueBytes[0] == 43 or valueBytes[0] == 45 then break end if
      result = result + [value]
      index = index + 1
    end while
  end if
  return result
end function

// Provide runtime arguments behavior for the active subsystem.
function runtimeArguments(options)
  result = filesystemArguments(options)
  result = result + ["-headless", "-nosound", "+map", options.startMap]
  return result
end function

// Validate integrated runtime and report any incompatibility.
function validateIntegratedRuntime(options, messages)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  session = host.create(runtimeArguments(options))
  initialized = try(host.initialize(session))
  if initialized is error then
    host.shutdown(session)
    return [append(messages, "FAIL", "integrated Host_Init: " + initialized.message), false]
  end if

  ok = true
  if not session.server.active then messages = append(messages, "FAIL", "integrated server did not become active"); ok = false end if
  if session.client.signon != c.SIGNONS or not session.client.spawned then
    messages = append(messages, "FAIL", "loopback signon stopped at " + session.client.signon)
    ok = false
  else
    messages = append(messages, "OK  ", "loopback signon reached stage " + session.client.signon + " and view entity " + session.client.viewEntity)
  end if
  if session.server.machine is void or session.server.machine.context is void then
    messages = append(messages, "FAIL", "QuakeC VM has no runtime context")
    ok = false
  else
    messages = append(messages, "OK  ", "QuakeC runtime: " + session.server.numEdicts + " edicts, " + len(session.server.modelPrecache) + " models, " + len(session.server.soundPrecache) + " sounds")
  end if

  frameIndex = 0
  while frameIndex < 8 and ok
    frameResult = try(host.frame(session, 0.02))
    if frameResult is error then
      messages = append(messages, "FAIL", "integrated Host_Frame " + frameIndex + ": " + frameResult.message)
      ok = false
    end if
    frameIndex = frameIndex + 1
  end while
  if ok then messages = append(messages, "OK  ", "8 headless Host_Frame iterations completed") end if

  if session.server.worldModel is not void then
    finish = math.add(session.player.origin, t.Vec3(0.0, 0.0, -128.0))
    trace = try(world.tracePlayer(session.server.worldModel, session.player.origin, finish))
    if trace is error then
      messages = append(messages, "FAIL", "player hull trace: " + trace.message)
      ok = false
    else if trace.fraction < 0.0 or trace.fraction > 1.0 then
      messages = append(messages, "FAIL", "player hull trace returned fraction " + trace.fraction)
      ok = false
    else
      messages = append(messages, "OK  ", "player hull trace fraction=" + trace.fraction + " startsolid=" + trace.startSolid)
    end if
  end if

  host.shutdown(session)
  return [messages, ok]
end function

// Validate graphics data and report any incompatibility.
function validateGraphicsData(system, messages)
  ok = true
  paletteData = try(qfs.readFile(system, "gfx/palette.lmp"))
  if paletteData is error then
    messages = append(messages, "FAIL", "gfx/palette.lmp: " + paletteData.message)
    ok = false
  else if len(paletteData) < 768 then
    messages = append(messages, "FAIL", "gfx/palette.lmp is shorter than 768 bytes")
    ok = false
  else
    messages = append(messages, "OK  ", "gfx/palette.lmp: " + len(paletteData) + " bytes")
  end if

  colormapData = try(qfs.readFile(system, "gfx/colormap.lmp"))
  if colormapData is error then
    messages = append(messages, "FAIL", "gfx/colormap.lmp: " + colormapData.message)
    ok = false
  else if len(colormapData) < 16384 then
    messages = append(messages, "WARN", "gfx/colormap.lmp has only " + len(colormapData) + " bytes")
  else
    messages = append(messages, "OK  ", "gfx/colormap.lmp: " + len(colormapData) + " bytes")
  end if

  conchars = try(graphicsData.readConsoleCharacters(system))
  if conchars is error then
    messages = append(messages, "WARN", "gfx.wad:conchars: " + conchars.message)
  else if len(conchars) != 16384 then
    messages = append(messages, "WARN", "gfx.wad:conchars has " + len(conchars) + " bytes; expected 16384")
  else
    messages = append(messages, "OK  ", "gfx.wad:conchars: 128x128 font")
  end if
  return [messages, ok]
end function

// Validate program data and report any incompatibility.
function validateProgramData(system, messages)
  ok = true
  functionCount = 0
  programData = try(qfs.readFile(system, "progs.dat"))
  if programData is error then
    messages = append(messages, "FAIL", "progs.dat: " + programData.message)
    ok = false
  else
    program = try(progs.parse(programData, "progs.dat"))
    if program is error then
      messages = append(messages, "FAIL", "progs.dat: " + program.message)
      ok = false
    else
      functionCount = len(program.functions)
      messages = append(messages, "OK  ", "progs.dat: " + functionCount + " functions, " + program.entityFields + " entity words")
      if program.crc != c.PROGHEADER_CRC then messages = append(messages, "WARN", "progs.dat system CRC is " + program.crc + "; stock Quake is " + c.PROGHEADER_CRC) end if
    end if
  end if
  return [messages, ok, functionCount]
end function

// Validate map data and report any incompatibility.
function validateMapData(system, options, messages)
  ok = true
  faceCount = 0
  textureCount = 0
  entityCount = 0
  mapPath = "maps/" + options.startMap + ".bsp"
  mapData = try(qfs.readFile(system, mapPath))
  if mapData is error then
    messages = append(messages, "FAIL", mapPath + ": " + mapData.message)
    ok = false
  else
    map = try(bsp.parse(mapData, mapPath))
    if map is error then
      messages = append(messages, "FAIL", mapPath + ": " + map.message)
      ok = false
    else
      faceCount = len(map.faces)
      entityCount = len(map.entities)
      playerStarts = 0
      for each texture in map.textures
        if texture is not void and len(texture.pixels) > 0 then textureCount = textureCount + 1 end if
      end for
      for each entity in map.entities
        classname = bio.lower(bsp.entityValue(entity, "classname"))
        if classname == "info_player_start" or classname == "info_player_deathmatch" then playerStarts = playerStarts + 1 end if
      end for
      messages = append(messages, "OK  ", mapPath + ": " + faceCount + " faces, " + textureCount + " textures, " + entityCount + " entities")
      if playerStarts == 0 then
        messages = append(messages, "WARN", mapPath + " contains no player start")
      else
        messages = append(messages, "OK  ", mapPath + ": " + playerStarts + " player start(s)")
      end if
    end if
  end if
  return [messages, ok, faceCount, textureCount, entityCount]
end function

// Validate player model and report any incompatibility.
function validatePlayerModel(system, messages)
  ok = true
  playerData = try(qfs.readFile(system, "progs/player.mdl"))
  if playerData is error then
    messages = append(messages, "WARN", "progs/player.mdl: " + playerData.message)
  else
    playerModel = try(mdl.parse(playerData, "progs/player.mdl"))
    if playerModel is error then
      messages = append(messages, "FAIL", "progs/player.mdl: " + playerModel.message)
      ok = false
    else
      messages = append(messages, "OK  ", "progs/player.mdl: " + playerModel.numFrames + " frames")
    end if
  end if
  return [messages, ok]
end function

// Validate menu sound and report any incompatibility.
function validateMenuSound(system, messages)
  ok = true
  soundData = try(qfs.readFile(system, "sound/misc/menu1.wav"))
  if soundData is error then
    messages = append(messages, "WARN", "sound/misc/menu1.wav: " + soundData.message)
  else
    soundInfo = try(wav.parse(soundData, "sound/misc/menu1.wav"))
    if soundInfo is error then
      messages = append(messages, "FAIL", "sound/misc/menu1.wav: " + soundInfo.message)
      ok = false
    else
      messages = append(messages, "OK  ", "sound/misc/menu1.wav: " + soundInfo.rate + " Hz, " + soundInfo.samples + " samples")
    end if
  end if
  return [messages, ok]
end function

// Validate the requested value and report any incompatibility.
function validate(options)
  print "[validate 1/7] mounting game search paths"
  system = qfs.initializeArguments(options.basedir, common.create(filesystemArguments(options)))
  messages = []
  ok = true
  packFiles = qfs.packFileCount(system)
  mapFaces = 0
  mapTextures = 0
  mapEntities = 0
  progsFunctions = 0

  if packFiles == 0 then
    messages = append(messages, "FAIL", "no PACK archives found below " + options.basedir)
    ok = false
  else
    messages = append(messages, "OK  ", "PACK search paths expose " + packFiles + " files")
  end if

  print "[validate 2/7] graphics lumps"
  graphicsResult = validateGraphicsData(system, messages)
  messages = graphicsResult[0]
  if not graphicsResult[1] then ok = false end if
  gc_collect()

  print "[validate 3/7] progs.dat"
  programResult = validateProgramData(system, messages)
  messages = programResult[0]
  if not programResult[1] then ok = false end if
  progsFunctions = programResult[2]
  gc_collect()

  print "[validate 4/7] BSP map"
  mapResult = validateMapData(system, options, messages)
  messages = mapResult[0]
  if not mapResult[1] then ok = false end if
  mapFaces = mapResult[2]
  mapTextures = mapResult[3]
  mapEntities = mapResult[4]
  gc_collect()

  print "[validate 5/7] player model"
  playerResult = validatePlayerModel(system, messages)
  messages = playerResult[0]
  if not playerResult[1] then ok = false end if
  gc_collect()

  print "[validate 6/7] menu sound"
  soundResult = validateMenuSound(system, messages)
  messages = soundResult[0]
  if not soundResult[1] then ok = false end if
  gc_collect()

  // The integrated host owns a fresh filesystem.  Release the validator's PAK
  // image first so the retail archive is not retained twice during Host_Init.
  qfs.release(system)
  system = void
  gc_collect()

  print "[validate 7/7] integrated headless host"
  if ok then
    runtime = validateIntegratedRuntime(options, messages)
    messages = runtime[0]
    ok = runtime[1]
  else
    messages = append(messages, "WARN", "integrated host validation skipped because required game data failed")
  end if

  return t.GameValidation(ok, messages, packFiles, mapFaces, mapTextures, mapEntities, progsFunctions)
end function

// Format and emit report.
function printReport(report)
  print "MiniQuake game-data validation"
  for each line in report.messages
    print line
  end for
  if report.ok then
    print "Validation result: PASS"
  else
    print "Validation result: FAIL"
  end if
  return report.ok
end function
