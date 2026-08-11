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
import miniquake.build_info as buildInfo
import miniquake.external_reference_contract as externalReference
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
import miniquake.compat_trace as compatTrace
import miniquake.net_udp as udp
import miniquake.host as host
import miniquake.sys_win as sysWin
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.filesystem as qfs
import miniquake.sound.mixer as mixer
import std.fs as fs

function printUsage()
  print "MiniQuake " + c.QUAKE_VERSION + " / protocol " + c.PROTOCOL_VERSION
  print "package " + buildInfo.PACKAGE_ID + " / profile " + buildInfo.COMPATIBILITY_PROFILE
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
  print "  --ogg FILE                 inspect and decode an Ogg Vorbis music track"
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
  print "  --compat-trace BASE MAP FRAMES PREFIX [-game DIR]"
  print "                             write deterministic trace, snapshot and crash context"
  print "  --compat-snapshot BASE MAP FRAME PREFIX [-game DIR]"
  print "                             run to FRAME and write the same diagnostic artifact set"
  print "  --compat-report FILE       recognize and summarize a compatibility artifact"
  print "  --validate-runtime BASE MAP [FRAMES] [-game DIR]"
  print "                             report signon, QuakeC, collision and heap checks"
  print "  --render-smoke BASE MAP [FRAMES] [-game DIR]"
  print "                             run the textured host and exit automatically"
  print "  --render-evidence BASE MAP FRAME PREFIX [-game DIR]"
  print "                             capture deterministic TGA after UI and before swap"
  print "  --render-demo-evidence BASE DEMO FRAME PREFIX [-game DIR]"
  print "                             capture a deterministic demo frame for external comparison"
  print "  --original-interop-server BASE MAP PORT FRAMES PREFIX [-game DIR]"
  print "                             run MiniQuake server for an original MiniQuake client"
  print "  --original-interop-client BASE HOST PORT FRAMES PREFIX [-game DIR]"
  print "                             connect MiniQuake client to an original MiniQuake server"
  print "  --soak BASE MAP [FRAMES] [-game DIR]"
  print "                             run GC/heap stability validation (default 10000)"
  print "  --long-soak MODE BASE TARGET [FRAMES] [-game DIR] [-port N]"
  print "                             100k-frame listen/dedicated/demo resource soak"
  print "  --opt001a-map-parse BASE MAP PREFIX [-game DIR]"
  print "                             parse a retail map and write start metrics"
  print "  --opt001a-frame-baseline BASE MAP MODE WARMUP MEASURE PREFIX [-game DIR]"
  print "                             record headless/render frame-time and stage baseline"
  print "  --opt001a-handle-plateau BASE MAP WARMUP WINDOW WINDOWS PREFIX [-game DIR] [-port N]"
  print "                             classify process handles as STABLE, PLATEAU or LEAK"
  print "  --opt001b-transition BASE FRAMES PREFIX [-game DIR]"
  print "                             render e1m1 -> e1m2 -> e1m1 in one session"
  print "  --udp-smoke [TIMEOUT_MS]   exchange a datagram through Winsock loopback"
  print "  --music-smoke BASE GAME TRACK"
  print "                             decode and mix an OGG replacement track"
  print "  --play BASEDIR MAP         shorthand for -basedir BASEDIR +map MAP"
  print ""
  print "  --version                  print version information"
  print "  --help                     print this help"
end function

function fail(result)
  print "MiniQuake: " + result.message
  return 2
end function

function inspectOgg(filename)
  data = fs.readAllBytes(filename)
  if native.oggOpen(data, len(data)) == 0 then return error(2414, "invalid Ogg Vorbis file " + filename) end if
  rate = native.oggRate()
  channels = native.oggChannels()
  frames = native.oggFrames()
  capacity = frames
  if capacity > 4096 then capacity = 4096 end if
  output = bytes(capacity * channels * 2)
  decoded = native.oggDecode(output, capacity)
  native.oggClose()
  if decoded < 1 then return error(2415, "Ogg Vorbis produced no PCM samples") end if
  print "Ogg Vorbis " + filename
  print "  rate=" + rate + " channels=" + channels + " frames=" + frames
  print "  decoded=" + decoded + " first-pcm=" + bio.i16(output, 0)
  return 0
end function

function musicSmoke(baseDirectory, gameDirectory, trackText)
  track = toNumber(trackText)
  if track is void then return error(2416, "invalid music track " + trackText) end if
  filesystem = qfs.initialize(baseDirectory, gameDirectory)
  soundMixer = mixer.create(filesystem, 22050)
  soundMixer.enabled = true
  played = try(mixer.playMusic(soundMixer, native.trunc(track), true))
  if played is error then qfs.release(filesystem); return played end if
  mixed = mixer.mix(soundMixer, 512)
  music = soundMixer.music
  print "MiniQuake OGG music smoke"
  print "  game=" + gameDirectory + " track=" + music.number
  print "  source=" + music.rate + "Hz channels=" + music.channels + " frames=" + music.frames
  print "  mixed=" + (len(mixed) / 4) + " stereo frames first-pcm=" + bio.i16(mixed, 0)
  mixer.stopMusic(soundMixer)
  qfs.release(filesystem)
  return 0
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

function integerNamedOption(arguments, name, fallback, minimum, maximum)
  index = 1
  while index + 1 < len(arguments)
    if bio.lower(arguments[index]) == name then
      return boundedInteger(arguments[index + 1], fallback, minimum, maximum)
    end if
    index = index + 1
  end while
  return fallback
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

function runCompatibilityTraceCommand(arguments)
  frames = boundedInteger(arguments[3], 120, 1, 1000000)
  result = try(compatTrace.run(arguments[1], gameOption(arguments), arguments[2], frames, arguments[4]))
  if result is error then print "MiniQuake compatibility trace: " + result.message; return 3 end if
  if compatTrace.printResult(result) then return 0 end if
  return 3
end function

function runCompatibilitySnapshotCommand(arguments)
  frames = boundedInteger(arguments[3], 1, 1, 1000000)
  result = try(compatTrace.run(arguments[1], gameOption(arguments), arguments[2], frames, arguments[4]))
  if result is error then print "MiniQuake compatibility snapshot: " + result.message; return 3 end if
  if compatTrace.printResult(result) then return 0 end if
  return 3
end function

function runCompatibilityReportCommand(path)
  if compatTrace.inspect(path) then return 0 end if
  return 2
end function

function runSoakCommand(arguments)
  frames = optionalFrameCount(arguments, 3, 10000, 2000000000)
  return host.runSoak(headlessArguments(arguments[1], arguments[2], gameOption(arguments)), frames)
end function

function runLongSoakCommand(arguments)
  mode = bio.lower(arguments[1])
  frames = optionalFrameCount(arguments, 4, 100000, 2000000000)
  port = integerNamedOption(arguments, "-port", 26000, 1, 65534)
  result = try(host.runLongSoak(arguments[2], gameOption(arguments), mode, arguments[3], frames, port))
  if result is error then
    print "MiniQuake long soak: " + result.message
    return 3
  end if
  return 0
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

function runRenderEvidenceCommand(arguments)
  frames = boundedInteger(arguments[3], 128, 1, 1000000)
  return host.runRenderEvidence([
    "-basedir", arguments[1],
    "-game", gameOption(arguments),
    "-window",
    "-nosound",
    "-nolan",
    "-nomouse",
    "-nojoy",
    "-noinput",
    "-width", "640",
    "-height", "480",
    "-maxframes", "" + frames,
    "+map", arguments[2],
  ], frames, arguments[4])
end function

function runRenderDemoEvidenceCommand(arguments)
  frames = boundedInteger(arguments[3], 256, 1, 1000000)
  return host.runRenderEvidence([
    "-basedir", arguments[1],
    "-game", gameOption(arguments),
    "-window",
    "-nosound",
    "-nolan",
    "-nomouse",
    "-nojoy",
    "-noinput",
    // Match MiniQuake's startup palette transform.  The runtime +gamma cvar is
    // separate from gl_vidnt::Check_Gamma and does not affect uploaded textures.
    "-gamma", "1",
    "-width", "640",
    "-height", "480",
    "-maxframes", "" + frames,
    "+viewsize", "100",
    "+fov", "90",
    "+gamma", "1",
    "+crosshair", "0",
    "+gl_picmip", "0",
    "+gl_polyblend", "1",
    "+gl_ztrick", "0",
    "+gl_clear", "1",
    "+gl_finish", "1",
    "+timedemo", arguments[2],
  ], frames, arguments[4])
end function

function runOriginalInteropServerCommand(arguments)
  port = boundedInteger(arguments[3], 26000, 1, 65534)
  frames = boundedInteger(arguments[4], externalReference.ORIGINAL_INTEROP_MAX_FRAMES, 1, 1000000)
  return host.runOriginalInteropServer([
    "-basedir", arguments[1],
    "-game", gameOption(arguments),
    "-dedicated", "1",
    "-nosound",
    "-ip", "127.0.0.1",
    "-port", "" + port,
    "+map", arguments[2],
  ], frames, arguments[5])
end function

function runOriginalInteropClientCommand(arguments)
  port = boundedInteger(arguments[3], 26000, 1, 65534)
  frames = boundedInteger(arguments[4], externalReference.ORIGINAL_INTEROP_MAX_FRAMES, 1, 1000000)
  return host.runOriginalInteropClient([
    "-basedir", arguments[1],
    "-game", gameOption(arguments),
    "-headless",
    "-nosound",
    "-ip", "127.0.0.1",
    "-nomouse",
    "-nojoy",
    "-noinput",
    // Private BP-090 interop option. Host_Init consumes this before the
    // normal standalone map/demo fallback, so an external-connect failure
    // cannot first build and tear down a local loopback server.
    "-original-interop-target", arguments[2] + ":" + port,
  ], frames, arguments[5], arguments[2], port)
end function


function runOpt001AMapParseCommand(arguments)
  result = try(host.opt001aMapParse(arguments[1], gameOption(arguments), arguments[2], arguments[3]))
  if result is error then print "MiniQuake OPT-001A map parse: " + result.message; return 3 end if
  return 0
end function

function runOpt001AFrameBaselineCommand(arguments)
  warmup = boundedInteger(arguments[4], 300, 0, 1000000)
  measure = boundedInteger(arguments[5], 3000, 1, 1000000)
  result = try(host.runOpt001AFrameBaseline(
    arguments[1], gameOption(arguments), arguments[2], bio.lower(arguments[3]),
    warmup, measure, arguments[6],
  ))
  if result is error then print "MiniQuake OPT-001A frame baseline: " + result.message; return 3 end if
  return 0
end function

function runOpt001AHandlePlateauCommand(arguments)
  warmup = boundedInteger(arguments[3], 1200, 1, 1000000)
  windowFrames = boundedInteger(arguments[4], 5000, 1, 100000000)
  windows = boundedInteger(arguments[5], 3, 3, 16)
  port = integerNamedOption(arguments, "-port", 26000, 1, 65534)
  result = try(host.runOpt001AHandlePlateau(
    arguments[1], gameOption(arguments), arguments[2],
    warmup, windowFrames, windows, port, arguments[6],
  ))
  if result is error then print "MiniQuake OPT-001A handle plateau: " + result.message; return 3 end if
  return 0
end function

function runOpt001BTransitionCommand(arguments)
  frames = boundedInteger(arguments[2], 64, 1, 1000000)
  result = try(host.runOpt001BTransition(arguments[1], gameOption(arguments), frames, arguments[3]))
  if result is error then print "MiniQuake OPT-001B transition: " + result.message; return 3 end if
  return 0
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
  print "Package: " + buildInfo.PACKAGE_ID
  print "Parent package: " + buildInfo.PARENT_PACKAGE_ID
  print "Block: " + buildInfo.BLOCK_ID
  print "Block parent package: " + buildInfo.BLOCK_PARENT_PACKAGE_ID
  print "Protocol status: " + buildInfo.PROTOCOL_STATUS
  print "QuakeC status: " + buildInfo.QUAKEC_STATUS
  print "World/physics status: " + buildInfo.WORLD_PHYSICS_STATUS
  print "Host/lifecycle status: " + buildInfo.HOST_LIFECYCLE_STATUS
  print "Host/lifecycle fingerprint: 0x8cbb709f"
  print "Client/render status: " + buildInfo.CLIENT_RENDER_STATUS
  print "Client/render fingerprint: 0x95e2b295"
  print "World/render status: " + buildInfo.WORLD_RENDER_STATUS
  print "World/render fingerprint: 0x846a74de"
  print "Model/UI/render status: " + buildInfo.MODEL_UI_RENDER_STATUS
  print "Model/UI/render fingerprint: 0x0a62f5b1"
  print "Render-special status: " + buildInfo.RENDER_SPECIAL_STATUS
  print "Render-special fingerprint: 0x2a3d8081"
  print "Audio status: " + buildInfo.AUDIO_STATUS
  print "Audio fingerprint: 0xdcf7a002"
  print "Network/platform status: " + buildInfo.NETWORK_PLATFORM_STATUS
  print "Network/platform fingerprint: 0xb3ec7589"
  print "Frontend status: " + buildInfo.FRONTEND_STATUS
  print "Frontend fingerprint: 0x924251fa"
  print "Core assets/memory status: " + buildInfo.CORE_ASSETS_MEMORY_STATUS
  print "Core assets/memory fingerprint: 0x6c8d974d"
  print "Gameplay/presentation status: " + buildInfo.GAMEPLAY_PRESENTATION_STATUS
  print "Gameplay/presentation fingerprint: 0xad91624c"
  print "Black-port source status: " + buildInfo.BLACK_PORT_SOURCE_STATUS
  print "Black-port source fingerprint: 0x309b0737"
  print "Game profile status: " + buildInfo.GAME_PROFILE_STATUS
  print "Game profile fingerprint: 0x7a03b68d"
  print "Mod runtime status: " + buildInfo.MOD_RUNTIME_STATUS
  print "Mod runtime fingerprint: 0x4649813d"
  print "Artifact compatibility status: " + buildInfo.ARTIFACT_COMPAT_STATUS
  print "Artifact compatibility fingerprint: 0x59531091"
  print "Stability status: " + buildInfo.STABILITY_STATUS
  print "Stability fingerprint: 0xd0e3c03f"
  print "Compatibility release status: " + buildInfo.COMPAT_RELEASE_STATUS
  print "Compatibility release fingerprint: 0x29b72a98"
  print "Original reference status: " + buildInfo.ORIGINAL_REFERENCE_STATUS
  print "Original reference fingerprint: 0xdc355175"
  print "Final compatibility status: " + buildInfo.COMPAT_FINAL_STATUS
  print "Final compatibility fingerprint: 0xe04a7727"
  print "Optimization status: " + buildInfo.OPTIMIZATION_STATUS
  print "Optimization fingerprint: 0x1c001c0c"
  print "Optimization parent: " + buildInfo.OPTIMIZATION_PARENT
  print "Package purpose: " + buildInfo.PACKAGE_PURPOSE
  print "Compatibility profile: " + buildInfo.COMPATIBILITY_PROFILE
  print "Native text ABI: " + buildInfo.NATIVE_TEXT_ABI
  print "Protocol text ABI: " + buildInfo.PROTOCOL_TEXT_ABI
  print "Package date: " + buildInfo.PACKAGE_DATE
  print "Baseline archive SHA-256: " + buildInfo.BASE_ARCHIVE_SHA256
  print "Core CRC self-check: 0x" + hex(bytes([(check >> 8) & 255, check & 255]))
  print "Port status: BP-094 is the external-reference compat_109 candidate; original binary interop and visual-reference gates are runnable and pending Windows acceptance."
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
  if command == "--ogg" and len(args) == 2 then return inspectOgg(args[1]) end if
  if command == "--demo" and len(args) == 2 then return inspectDemo(args[1]) end if
  if command == "--demo-verify" and len(args) == 2 then return verifyDemo(args[1]) end if
  if command == "--message" and len(args) == 2 then return inspectMessage(args[1]) end if
  if command == "--bsp-view" and len(args) == 3 then return viewer.runDirect(args[1], args[2]) end if
  if command == "--map-view" and len(args) == 3 then return viewer.runFromGame(args[1], args[2]) end if
  if command == "--validate-game" and len(args) >= 2 then return validateGame(args) end if
  if command == "--runtime-smoke" and len(args) >= 3 then return runtimeSmoke(args) end if
  if command == "--compat-trace" and len(args) >= 5 then return runCompatibilityTraceCommand(args) end if
  if command == "--compat-snapshot" and len(args) >= 5 then return runCompatibilitySnapshotCommand(args) end if
  if command == "--compat-report" and len(args) == 2 then return runCompatibilityReportCommand(args[1]) end if
  if command == "--validate-runtime" and len(args) >= 3 then return runRuntimeValidationCommand(args) end if
  if command == "--render-smoke" and len(args) >= 3 then return renderSmoke(args) end if
  if command == "--render-evidence" and len(args) >= 5 then return runRenderEvidenceCommand(args) end if
  if command == "--render-demo-evidence" and len(args) >= 5 then return runRenderDemoEvidenceCommand(args) end if
  if command == "--original-interop-server" and len(args) >= 6 then return runOriginalInteropServerCommand(args) end if
  if command == "--original-interop-client" and len(args) >= 6 then return runOriginalInteropClientCommand(args) end if
  if command == "--soak" and len(args) >= 3 then return runSoakCommand(args) end if
  if command == "--long-soak" and len(args) >= 4 then return runLongSoakCommand(args) end if
  if command == "--opt001a-map-parse" and len(args) >= 4 then return runOpt001AMapParseCommand(args) end if
  if command == "--opt001a-frame-baseline" and len(args) >= 7 then return runOpt001AFrameBaselineCommand(args) end if
  if command == "--opt001a-handle-plateau" and len(args) >= 7 then return runOpt001AHandlePlateauCommand(args) end if
  if command == "--opt001b-transition" and len(args) >= 4 then return runOpt001BTransitionCommand(args) end if
  if command == "--udp-smoke" and len(args) <= 2 then return runUdpSmoke(args) end if
  if command == "--music-smoke" and len(args) == 4 then return musicSmoke(args[1], args[2], args[3]) end if
  if command == "--play" and len(args) == 3 then return sysWin.WinMain(args, host.run) end if
  if len(bytes(command)) > 1 and decode(slice(bytes(command), 0, 2)) == "--" then
    print "MiniQuake: invalid command or argument count"
    printUsage()
    return 2
  end if
  return sysWin.WinMain(args, host.run)
end function
