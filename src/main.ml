/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See COPYING.
*/

import miniquake.constants as c
import miniquake.crc as crc
import miniquake.pak as pak
import miniquake.wad as wad
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as sprite
import miniquake.format.progs as progs
import miniquake.sound.wav as wav
import miniquake.demo as demo
import miniquake.demo_player as demoPlayer
import miniquake.client_protocol as protocol
import miniquake.gl_smoke as smoke
import miniquake.map_viewer as viewer
import miniquake.launch as launch
import miniquake.game_validation as gameValidation
import miniquake.runtime_validation as runtimeValidation
import miniquake.net_udp as udp
import miniquake.host as host
import miniquake.byteio as bio
import std.fs as fs

function printUsage()
  print "MiniQuake " + c.QUAKE_VERSION + " / protocol " + c.PROTOCOL_VERSION
  print "usage: MiniQuake.exe [-basedir PATH] [-game DIR] [+map MAP] [options]"
  print "       MiniQuake.exe COMMAND [arguments]"
  print ""
  print "Inspection and validation commands:"
  print "  --pak FILE                 inspect a Quake PACK archive"
  print "  --wad FILE                 inspect a WAD2 archive"
  print "  --bsp FILE                 inspect a Quake BSP v29 map"
  print "  --mdl FILE                 inspect an IDPO v6 alias model"
  print "  --spr FILE                 inspect an IDSP v1 sprite"
  print "  --progs FILE               inspect a progs.dat v6 program"
  print "  --wav FILE                 inspect a PCM RIFF/WAVE sound"
  print "  --demo FILE                inspect a Quake network demo"
  print "  --demo-verify FILE         replay every demo message through the client"
  print "  --message FILE             parse a raw protocol-15 server message"
  print ""
  print "Windows/OpenGL and integrated-engine diagnostics:"
  print "  --gl-smoke                 create a Win32/WGL window and draw a triangle"
  print "  --gl-smoke-frames N        run the OpenGL smoke test for N frames"
  print "  --bsp-view BSP PALETTE     display BSP geometry with palette.lmp"
  print "  --map-view BASEDIR MAP     load id1/PAK files and display maps/MAP.bsp"
  print "  --validate-game BASE [MAP] [-game DIR]"
  print "                             validate assets plus integrated runtime"
  print "  --runtime-smoke BASE MAP [FRAMES] [-game DIR]"
  print "                             run fixed headless Host_Frame iterations"
  print "  --validate-runtime BASE MAP [FRAMES] [-game DIR]"
  print "                             report signon, QuakeC, collision and heap checks"
  print "  --render-smoke BASE MAP [FRAMES] [-game DIR]"
  print "                             run the textured host and exit automatically"
  print "  --soak BASE MAP [FRAMES] [-game DIR]"
  print "                             run GC/heap stability validation (default 10000)"
  print "  --udp-smoke [TIMEOUT_MS]   exchange a datagram through Winsock loopback"
  print "  --play BASEDIR MAP         shorthand for -basedir BASEDIR +map MAP"
  print ""
  print "  --version                  print version information"
  print "  --help                     print this help"
end function

function fail(result)
  print "MiniQuake: " + result.message
  return 2
end function

function inspectPack(filename)
  archive = try(pak.load(filename))
  if archive is error then return fail(archive) end if
  print archive.filename + ": " + archive.numFiles + " pack files"
  return 0
end function

function inspectWad(filename)
  archive = try(wad.load(filename))
  if archive is error then return fail(archive) end if
  print archive.filename + ": " + archive.numLumps + " WAD2 lumps"
  return 0
end function

function inspectBsp(filename)
  map = try(bsp.load(filename))
  if map is error then return fail(map) end if
  print map.filename + ": BSP " + map.version
  print "  entities=" + len(map.entities) + " models=" + len(map.models) + " planes=" + len(map.planes)
  print "  vertices=" + len(map.vertices) + " faces=" + len(map.faces) + " leafs=" + len(map.leafs)
  print "  textures=" + len(map.textures) + " clipnodes=" + len(map.clipNodes)
  return 0
end function

function inspectMdl(filename)
  model = try(mdl.load(filename))
  if model is error then return fail(model) end if
  print model.filename + ": IDPO v6"
  print "  skins=" + model.numSkins + " size=" + model.skinWidth + "x" + model.skinHeight
  print "  vertices=" + model.numVertices + " triangles=" + model.numTriangles + " frames=" + model.numFrames
  return 0
end function

function inspectSprite(filename)
  model = try(sprite.load(filename))
  if model is error then return fail(model) end if
  print model.filename + ": IDSP v1"
  print "  size=" + model.width + "x" + model.height + " frames=" + model.numFrames + " type=" + model.type
  return 0
end function

function inspectProgs(filename)
  program = try(progs.load(filename))
  if program is error then return fail(program) end if
  print program.filename + ": progs.dat v" + program.version + " crc=" + program.crc
  print "  statements=" + len(program.statements) + " functions=" + len(program.functions)
  print "  globals=" + len(program.globals) + " globaldefs=" + len(program.globalDefs) + " fielddefs=" + len(program.fieldDefs)
  return 0
end function

function inspectWav(filename)
  loaded = try(wav.load(filename))
  if loaded is error then return fail(loaded) end if
  info = loaded[0]
  print filename + ": PCM " + (info.width * 8) + "-bit, " + info.channels + " channel(s), " + info.rate + " Hz"
  print "  samples=" + info.samples + " loopstart=" + info.loopStart + " dataoffset=" + info.dataOffset
  return 0
end function

function inspectDemo(filename)
  recording = try(demo.load(filename))
  if recording is error then return fail(recording) end if
  totalBytes = 0
  for each item in recording.messages
    totalBytes = totalBytes + len(item.payload)
  end for
  print filename + ": forced track " + recording.forcedTrack
  print "  messages=" + len(recording.messages) + " payload-bytes=" + totalBytes
  return 0
end function

function verifyDemo(filename)
  recording = try(demo.load(filename))
  if recording is error then return fail(recording) end if
  report = demoPlayer.verify(recording)
  print filename + ": protocol replay"
  if demoPlayer.printReport(report) then return 0 end if
  return 2
end function

function inspectMessage(filename)
  data = try(fs.readAllBytes(filename))
  if data is error then return fail(data) end if
  parsed = try(protocol.parse(data))
  if parsed is error then return fail(parsed) end if
  print filename + ": " + len(parsed.events) + " protocol events, " + parsed.bytesRead + " bytes"
  for each item in parsed.events
    print "  " + item.command
  end for
  return 0
end function

function validateGame(arguments)
  options = launch.parse(arguments)
  report = try(gameValidation.validate(options))
  if report is error then return fail(report) end if
  if gameValidation.printReport(report) then return 0 end if
  return 2
end function

function boundedInteger(text, fallback, minimum, maximum)
  value = toNumber(text)
  if value is void or value is not int then return fallback end if
  if value < minimum then return minimum end if
  if value > maximum then return maximum end if
  return value
end function

function gameOption(arguments)
  gameDirectory = "id1"
  index = 1
  while index + 1 < len(arguments)
    if bio.lower(arguments[index]) == "-game" then
      gameDirectory = arguments[index + 1]
      index = index + 2
    else
      index = index + 1
    end if
  end while
  return gameDirectory
end function

function optionalFrameCount(arguments, index, fallback, maximum)
  if index >= len(arguments) then return fallback end if
  value = toNumber(arguments[index])
  if value is void or value is not int then return fallback end if
  return boundedInteger(arguments[index], fallback, 1, maximum)
end function

function headlessArguments(baseDirectory, mapName, gameDirectory)
  return ["-basedir", baseDirectory, "-game", gameDirectory, "-headless", "-nosound", "+map", mapName]
end function

function runtimeSmoke(arguments)
  frames = optionalFrameCount(arguments, 3, 120, 1000000)
  return host.runHeadlessFrames(headlessArguments(arguments[1], arguments[2], gameOption(arguments)), frames)
end function

function runRuntimeValidationCommand(arguments)
  frames = optionalFrameCount(arguments, 3, 300, 1000000)
  report = runtimeValidation.validate(arguments[1], gameOption(arguments), arguments[2], frames)
  if runtimeValidation.printReport(report) then return 0 end if
  return 2
end function

function runSoakCommand(arguments)
  frames = optionalFrameCount(arguments, 3, 10000, 2000000000)
  return host.runSoak(headlessArguments(arguments[1], arguments[2], gameOption(arguments)), frames)
end function

function renderSmoke(arguments)
  frames = optionalFrameCount(arguments, 3, 300, 1000000)
  return host.run([
    "-basedir", arguments[1],
    "-game", gameOption(arguments),
    "-window",
    "-nosound",
    "-maxframes", "" + frames,
    "+map", arguments[2],
  ])
end function

function runUdpSmoke(arguments)
  timeout = 1000
  if len(arguments) >= 2 then timeout = boundedInteger(arguments[1], timeout, 1, 60000) end if
  report = udp.smoke(timeout)
  print "MiniQuake UDP loopback smoke"
  print "  sender=" + report.senderPort + " receiver=" + report.receiverPort
  print "  sent=" + report.bytesSent + " received=" + report.bytesReceived
  if report.ok then
    print "  peer=" + report.remoteAddress + ":" + report.remotePort
    print "  payload=" + report.payload
    print "  result=PASS"
    return 0
  end if
  print "  error=" + report.errorCode
  print "  result=FAIL"
  return 2
end function

function runSelfCheck()
  check = crc.block(bytes("123456789"), 0, 9)
  print "MiniQuake " + c.QUAKE_VERSION + " / protocol " + c.PROTOCOL_VERSION
  print "Core CRC self-check: 0x" + hex(bytes([(check >> 8) & 255, check & 255]))
  print "Port status: integrated host/server/client/QuakeC/render/audio milestone; see PORT_STATUS.md for remaining parity work."
  return 0
end function

function main(args)
  if len(args) == 0 then
    runSelfCheck()
    print ""
    printUsage()
    return 0
  end if

  command = args[0]
  if command == "--help" or command == "-h" then printUsage(); return 0 end if
  if command == "--version" then return runSelfCheck() end if
  if command == "--gl-smoke" and len(args) == 1 then return smoke.run() end if
  if command == "--gl-smoke-frames" and len(args) == 2 then return smoke.runFrames(boundedInteger(args[1], 120, 1, 1000000)) end if
  if command == "--pak" and len(args) == 2 then return inspectPack(args[1]) end if
  if command == "--wad" and len(args) == 2 then return inspectWad(args[1]) end if
  if command == "--bsp" and len(args) == 2 then return inspectBsp(args[1]) end if
  if command == "--mdl" and len(args) == 2 then return inspectMdl(args[1]) end if
  if command == "--spr" and len(args) == 2 then return inspectSprite(args[1]) end if
  if command == "--progs" and len(args) == 2 then return inspectProgs(args[1]) end if
  if command == "--wav" and len(args) == 2 then return inspectWav(args[1]) end if
  if command == "--demo" and len(args) == 2 then return inspectDemo(args[1]) end if
  if command == "--demo-verify" and len(args) == 2 then return verifyDemo(args[1]) end if
  if command == "--message" and len(args) == 2 then return inspectMessage(args[1]) end if
  if command == "--bsp-view" and len(args) == 3 then return viewer.runDirect(args[1], args[2]) end if
  if command == "--map-view" and len(args) == 3 then return viewer.runFromGame(args[1], args[2]) end if
  if command == "--validate-game" and len(args) >= 2 then return validateGame(args) end if
  if command == "--runtime-smoke" and len(args) >= 3 then return runtimeSmoke(args) end if
  if command == "--validate-runtime" and len(args) >= 3 then return runRuntimeValidationCommand(args) end if
  if command == "--render-smoke" and len(args) >= 3 then return renderSmoke(args) end if
  if command == "--soak" and len(args) >= 3 then return runSoakCommand(args) end if
  if command == "--udp-smoke" and len(args) <= 2 then return runUdpSmoke(args) end if
  if command == "--play" and len(args) == 3 then return host.run(args) end if
  if len(bytes(command)) > 1 and decode(slice(bytes(command), 0, 2)) == "--" then
    print "MiniQuake: invalid command or argument count"
    printUsage()
    return 2
  end if
  return host.run(args)
end function
