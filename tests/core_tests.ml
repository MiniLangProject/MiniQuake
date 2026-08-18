/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/core_tests.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.crc as crc
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.mathlib as math
import miniquake.common as common
import miniquake.cmd as cmd
import miniquake.cvar as cvar
import miniquake.pak as pak
import miniquake.filesystem as qfs
import miniquake.wad as wad
import miniquake.graphics_data as graphicsData
import miniquake.net_loop as netloop
import miniquake.memory as memory
import miniquake.world_hull as hull
import miniquake.world_bsp as worldBsp
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as sprite
import miniquake.model_registry as modelRegistry
import miniquake.sound.wav as wav
import miniquake.demo as demo
import miniquake.client_protocol as protocol
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.quakec.builtins as qcb
import miniquake.quakec.edict as qcedict
import miniquake.format.progs as progs
import miniquake.render.gl_warp as glWarp
import miniquake.render.gl_rlight as glRlight
import miniquake.render.draw2d as draw2d
import miniquake.render.texture_upscale as textureUpscale
import miniquake.screen as screenCompat

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9000, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9001, name + ": expected true") end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0 then difference = -difference end if
  if difference > tolerance then
    return error(9002, name + ": expected " + expected + " +/- " + tolerance + ", got " + actual)
  end if
  return true
end function

// Report whether command never exists holds for the active state.
function commandNeverExists(name)
  return false
end function

// Return command argument count derived from the active module state.
function commandArgumentCount(arguments)
  return len(arguments)
end function

// Verify crc against the expected Quake behavior.
function testCrc()
  assertEqual(crc.block(bytes("123456789"), 0, 9), 0x29b1, "CRC-CCITT")
  return true
end function

// Verify byte io against the expected Quake behavior.
function testByteIo()
  print "  [02.01] allocate bytes"
  data = bytes(16)

  print "  [02.02] direct byte write"
  data[15] = 0x5a

  print "  [02.03] direct byte read"
  directValue = data[15]
  assertEqual(directValue, 0x5a, "direct byte roundtrip")

  print "  [02.04] put u16"
  bio.putU16(data, 0, 0xabcd)

  print "  [02.05] read u16"
  u16Value = bio.u16(data, 0)
  assertEqual(u16Value, 0xabcd, "u16 roundtrip")

  print "  [02.06] put u32"
  bio.putU32(data, 2, 0x78563412)

  print "  [02.07] read u32"
  u32Value = bio.u32(data, 2)
  assertEqual(u32Value, 0x78563412, "u32 roundtrip")

  print "  [02.08] put i16"
  bio.putI16(data, 6, -1234)

  print "  [02.09] read i16"
  i16Value = bio.i16(data, 6)
  assertEqual(i16Value, -1234, "i16 roundtrip")

  print "  [02.10] MiniLang raw float -> IEEE-754 bits"
  bits = native.floatBits(12.5)
  assertEqual(bits, 0x41480000, "12.5 float bits")

  print "  [02.11] IEEE-754 bits -> MiniLang raw float"
  decoded = native.bitsFloat(bits)
  assertEqual(decoded, 12.5, "12.5 raw float roundtrip")

  print "  [02.12] put f32"
  bio.putF32(data, 8, 12.5)

  print "  [02.13] read f32"
  f32Value = bio.f32(data, 8)
  assertEqual(f32Value, 12.5, "f32 roundtrip")

  print "  [02.14] exact integer truncation"
  assertEqual(native.trunc(0x12345678), 0x12345678, "integer truncation preserves 32-bit mask")

  print "  [02.15] buffered native ASCII return"
  assertEqual(native.asciiChar(65), "A", "buffered native ASCII return")

  print "  [02.16] buffered native NUL return"
  assertEqual(native.asciiChar(0), "", "buffered native NUL return")

  print "  [02.17] buffered native float text"
  assertEqual(native.floatText(12.5), "12.5", "buffered native float text")

  print "  [02.18] byte I/O complete"
  assertEqual(bio.shortSwap(0x1234), 0x3412, "ShortSwap")
  assertEqual(bio.shortSwap(0x0080), -32768, "ShortSwap signed return")
  assertEqual(bio.longSwap(0x12345678), 0x78563412, "LongSwap")
  assertEqual(bio.longSwap(0x00000080), -2147483648, "LongSwap signed return")
  assertEqual(bio.floatSwap(bio.floatSwap(12.5)), 12.5, "FloatSwap roundtrip")

  first = bytes([1, 2, 3, 4])
  second = bytes([1, 2, 3, 4])
  assertEqual(common.memCompare(first, second, 4), 0, "Q_memcmp equal")
  second[0] = 9
  assertEqual(common.memCompare(first, second, 4), -1, "Q_memcmp mismatch")
  common.memSet(second, 0xaa, 2)
  assertEqual(second[0], 0xaa, "Q_memset first")
  common.memCopy(second, first, 3)
  assertEqual(second[2], 3, "Q_memcpy")
  return true
end function

// Verify message against the expected Quake behavior.
function testMessage()
  buffer = sz.alloc(256)
  msg.writeByte(buffer, 200)
  msg.writeShort(buffer, -1234)
  msg.writeLong(buffer, 0x12345678)
  msg.writeFloat(buffer, 12.5)
  msg.writeString(buffer, "quake")
  msg.writeCoord(buffer, 10.25)
  msg.writeAngle(buffer, 90.0)
  reader = msg.beginReading(buffer)
  assertEqual(msg.readByte(reader), 200, "MSG byte")
  assertEqual(msg.readShort(reader), -1234, "MSG short")
  assertEqual(msg.readLong(reader), 0x12345678, "MSG long")
  assertEqual(msg.readFloat(reader), 12.5, "MSG float")
  assertEqual(msg.readString(reader), "quake", "MSG string")
  assertEqual(msg.readCoord(reader), 10.25, "MSG coord")
  assertEqual(msg.readAngle(reader), 90.0, "MSG angle")

  angleBuffer = sz.alloc(8)
  msg.writeAngle(angleBuffer, 1.9)
  msg.writeAngle(angleBuffer, 180.0)
  angleReader = msg.beginReading(angleBuffer)
  assertEqual(msg.readAngle(angleReader), 0.0, "MSG_WriteAngle casts before scale")
  assertEqual(msg.readAngle(angleReader), -180.0, "MSG_ReadAngle signed char")

  overflowReader = msg.beginReadingBytes(bytes([1]))
  assertEqual(msg.readLong(overflowReader), -1, "MSG_ReadLong overflow sentinel")
  assertEqual(overflowReader.badRead, true, "MSG_ReadLong badread")
  assertEqual(overflowReader.readCount, 0, "MSG_ReadLong overflow does not advance")

  longString = bytes(2050)
  index = 0
  while index < 2049
    longString[index] = 97
    index = index + 1
  end while
  stringReader = msg.beginReadingBytes(longString)
  assertEqual(len(bytes(msg.readString(stringReader))), 2047, "MSG_ReadString static limit")
  assertEqual(msg.remaining(stringReader), 3, "MSG_ReadString leaves overlong suffix unread")

  hunkBuffer = sz.allocHunk(1)
  assertEqual(hunkBuffer.maxSize, 256, "SZ_Alloc minimum allocation")
  overflowing = sz.allocOverflowing(2)
  sz.writeBytes(overflowing, bytes([1, 2]))
  sz.writeBytes(overflowing, bytes([3]))
  assertEqual(overflowing.overflowed, true, "SZ_GetSpace overflow flag")
  sz.clear(overflowing)
  assertEqual(overflowing.overflowed, true, "SZ_Clear preserves overflow flag")
  printable = sz.alloc(32)
  sz.printText(printable, "one")
  sz.printText(printable, "two")
  assertEqual(decode(slice(printable.data, 0, printable.curSize - 1)), "onetwo", "SZ_Print strcat")
  return true
end function

// Verify math against the expected Quake behavior.
function testMath()
  a = t.Vec3(1.0, 2.0, 3.0)
  b = t.Vec3(4.0, 5.0, 6.0)
  assertEqual(math.dot(a, b), 32.0, "dot product")
  cross = math.cross(a, b)
  assertEqual(cross.x, -3.0, "cross x")
  assertEqual(cross.y, 6.0, "cross y")
  assertEqual(cross.z, -3.0, "cross z")
  assertEqual(math.greatestCommonDivisor(54, 24), 6, "gcd")
  assertEqual(math.angleMod(450.0), 90.0, "angle mod")
  return true
end function

// Verify cvar against the expected Quake behavior.
function testCvar()
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  assertEqual(common.atoi("0x10"), 16, "Q_atoi hexadecimal")
  assertEqual(common.atoi("-'A"), -65, "Q_atoi character literal")
  assertEqual(common.atoi("12tail"), 12, "Q_atoi stops at suffix")
  assertEqual(common.atof("0x10"), 16.0, "Q_atof hexadecimal")
  assertEqual(common.atof("-'A"), -65.0, "Q_atof character literal")
  assertEqual(common.atof("12.50tail"), 12.5, "Q_atof stops at suffix")
  assertEqual(common.stringCompare("Quake", "Quake"), 0, "Q_strcmp equal")
  assertEqual(common.stringCompare("Quake", "quake"), -1, "Q_strcmp case-sensitive")
  assertEqual(common.stringCompareInsensitive("Quake", "quake"), 0, "Q_strcasecmp")
  assertEqual(common.skipPath("maps/e1m1.bsp"), "e1m1.bsp", "COM_SkipPath")
  assertEqual(common.stripExtension("maps/e1m1.bsp"), "maps/e1m1", "COM_StripExtension")
  assertEqual(common.fileExtension("maps/e1m1.bsp"), "bsp", "COM_FileExtension")
  assertEqual(common.fileBase("maps/e1m1.bsp"), "e1m1", "COM_FileBase")
  assertEqual(common.defaultExtension("maps/e1m1", ".bsp"), "maps/e1m1.bsp", "COM_DefaultExtension")
  parsed = common.parseToken(" // ignored\n{ \"two words\" next", 0)
  assertEqual(parsed[0], "{", "COM_Parse comment and punctuation")
  parsed = common.parseToken(" // ignored\n{ \"two words\" next", parsed[1])
  assertEqual(parsed[0], "two words", "COM_Parse quoted string")

  commandLine = common.create(["-safe", "-nosound", "-rogue"])
  assertEqual(common.checkParm(commandLine, "-safe"), 1, "COM_CheckParm one-based")
  assertEqual(common.checkParm(commandLine, "-SAFE"), 0, "COM_CheckParm case-sensitive")
  assertEqual(len(commandLine.args), 10, "COM_InitArgv appends all safe switches")
  assertEqual(commandLine.commandLine, "-safe -nosound -rogue ", "COM_InitArgv command line")
  stuffed = common.stuffCommands(common.create(["+map", "e1m1", "-nosound", "+skill", "2"]))
  assertEqual(stuffed, "map e1m1 \nskill 2\n", "Cmd_StuffCmds original scan")

  registry = cvar.createRegistry()
  variable = cvar.create("test", "12.5", false, false)
  cvar.register(registry, variable, commandNeverExists)
  assertEqual(cvar.variableValue(registry, "test"), 12.5, "cvar value")
  assertEqual(cvar.find(registry, "TEST"), void, "cvar names are case-sensitive")
  cvar.set(registry, "test", "7")
  assertEqual(cvar.variableString(registry, "test"), "7", "cvar string")
  cvar.setValue(registry, "test", 1.25)
  assertEqual(cvar.variableString(registry, "test"), "1.250000", "Cvar_SetValue percent-f formatting")
  archived = cvar.create("archived", "raw\\value", true, false)
  cvar.register(registry, archived, commandNeverExists)
  assertEqual(cvar.completeVariable(registry, "arch"), "archived", "cvar head-first completion")
  assertEqual(cvar.completeVariable(registry, "Arch"), void, "cvar completion case-sensitive")
  assertEqual(cvar.archiveText(registry), "archived \"raw\\value\"\n", "Cvar_WriteVariables verbatim value")
  serverVariable = cvar.create("server_test", "1", false, true)
  cvar.register(registry, serverVariable, commandNeverExists)
  cvar.set(registry, "server_test", "1")
  assertEqual(len(cvar.takeServerChanges(registry)), 0, "unchanged server cvar not broadcast")
  cvar.set(registry, "server_test", "2")
  changes = cvar.takeServerChanges(registry)
  assertEqual(len(changes), 1, "changed server cvar queued")
  assertEqual(changes[0][0], "server_test", "server cvar broadcast name")
  assertEqual(changes[0][1], "2", "server cvar broadcast value")

  system = cmd.create()
  cmd.addCommand(system, "Echo", commandArgumentCount)
  assertEqual(cmd.executeString(system, "ECHO one two"), 3, "command execution case-insensitive")
  duplicate = try(cmd.addCommand(system, "Echo", commandArgumentCount))
  assertTrue(duplicate is error, "exact duplicate command rejected")
  assertEqual(cmd.completeCommand(system, "E"), "Echo", "command completion")
  assertEqual(cmd.completeCommand(system, "e"), void, "command completion case-sensitive")

  cmd.addAlias(system, "combo", "wait; Echo after")
  assertEqual(cmd.executeString(system, "COMBO"), true, "alias execution case-insensitive")
  assertEqual(cmd.executeBuffer(system), 1, "wait defers command buffer")
  assertTrue(system.text != "", "wait preserves remaining commands")
  assertEqual(cmd.executeBuffer(system), 1, "deferred command executes next frame")
  aliasTooLong = try(cmd.addAlias(system, "12345678901234567890123456789012", "Echo"))
  assertTrue(aliasTooLong is error, "MAX_ALIAS_NAME enforced")

  split = cmd.splitFirstCommand("echo one // comment;echo two")
  assertEqual(split[0], "echo one // comment", "Cbuf semicolon split matches original")
  assertEqual(split[1], "echo two", "Cbuf retains command after comment semicolon")
  tokens = cmd.tokenize("alpha { beta : \"two words\" // ignored")
  assertEqual(len(tokens), 5, "COM_Parse token count")
  assertEqual(tokens[1], "{", "COM_Parse punctuation token")
  assertEqual(tokens[3], ":", "COM_Parse colon token")
  assertEqual(tokens[4], "two words", "COM_Parse quoted token")
  manyArguments = ""
  argumentIndex = 0
  while argumentIndex < 85
    manyArguments = manyArguments + " x"
    argumentIndex = argumentIndex + 1
  end while
  assertEqual(len(cmd.tokenize(manyArguments)), 80, "MAX_ARGS enforced")
  system.arguments = ["command", "-first", "value"]
  assertEqual(cmd.checkParm(system, "-FIRST"), 1, "Cmd_CheckParm case-insensitive")
  assertEqual(cmd.checkParm(system, "-missing"), 0, "Cmd_CheckParm absent")
  bounded = cmd.create()
  largeText = ""
  textIndex = 0
  while textIndex < 8191
    largeText = largeText + "x"
    textIndex = textIndex + 1
  end while
  assertEqual(cmd.addText(bounded, largeText), true, "Cbuf accepts maxsize minus one")
  assertEqual(cmd.addText(bounded, "x"), false, "Cbuf rejects maxsize overflow")
  assertEqual(len(bytes(bounded.text)), 8191, "Cbuf overflow preserves buffered text")
  return true
end function

// Create and initialize synthetic pack.
function makeSyntheticPack()
  data = bytes(12 + 5 + 64)
  data[0] = 80; data[1] = 65; data[2] = 67; data[3] = 75
  bio.putU32(data, 4, 17)
  bio.putU32(data, 8, 64)
  content = bytes("hello")
  bio.copyInto(data, 12, content, 0, 5)
  name = bytes("maps/test.bsp")
  bio.copyInto(data, 17, name, 0, len(name))
  bio.putU32(data, 17 + 56, 12)
  bio.putU32(data, 17 + 60, 5)
  return data
end function

// Verify pack against the expected Quake behavior.
function testPack()
  archive = pak.parse(makeSyntheticPack(), "synthetic.pak")
  assertEqual(archive.numFiles, 1, "pack count")
  assertEqual(decode(pak.readFile(archive, "maps/test.bsp")), "hello", "pack data")
  assertEqual(pak.find(archive, "MAPS/TEST.BSP"), void, "PACK lookup is case-sensitive")

  system = t.FileSystem("", "id1", [t.SearchPath("", archive)], "", false, false, true, false)
  missingCase = try(qfs.readFile(system, "MAPS/TEST.BSP"))
  assertTrue(missingCase is error, "COM_FindFile PACK strcmp")
  loaded = qfs.loadFile(system, "maps/test.bsp")
  assertEqual(len(loaded), 6, "COM_LoadFile appends NUL")
  assertEqual(loaded[5], 0, "COM_LoadFile terminator")
  stack = bytes(8)
  loadedStack = qfs.loadStackFile(system, "maps/test.bsp", stack)
  assertEqual(len(loadedStack), 8, "COM_LoadStackFile reuses fitting buffer")
  assertEqual(loadedStack[5], 0, "COM_LoadStackFile terminator")
  return true
end function

// Create and initialize synthetic wad.
function makeSyntheticWad()
  data = bytes(12 + 8 + 32)
  data[0] = 87; data[1] = 65; data[2] = 68; data[3] = 50
  bio.putU32(data, 4, 1)
  bio.putU32(data, 8, 20)
  bio.putU32(data, 12, 320)
  bio.putU32(data, 16, 200)
  bio.putU32(data, 20, 12)
  bio.putU32(data, 24, 8)
  bio.putU32(data, 28, 8)
  data[32] = 66
  name = bytes("conchars")
  bio.copyInto(data, 36, name, 0, len(name))
  return data
end function

// Verify wad against the expected Quake behavior.
function testWad()
  wadData = makeSyntheticWad()
  archive = wad.parse(wadData, "synthetic.wad")
  assertEqual(archive.numLumps, 1, "wad count")
  dimensions = wad.pictureDimensions(archive, "CONCHARS")
  assertEqual(dimensions[0], 320, "qpic width")
  assertEqual(dimensions[1], 200, "qpic height")

  // Stock Quake exposes the console font as gfx.wad:conchars. Keep this path
  // covered so retail data does not regress to the non-standard .lmp lookup.
  packArchive = t.PackArchive(
    "synthetic.pak",
    wadData,
    [t.PackFile("gfx.wad", 0, len(wadData))],
    1,
  )
  filesystem = t.FileSystem("", "id1", [t.SearchPath("", packArchive)], "", false, false, true, false)
  conchars = graphicsData.readConsoleCharacters(filesystem)
  assertEqual(len(conchars), 8, "gfx.wad conchars size")
  assertEqual(bio.i32(conchars, 0), 320, "gfx.wad conchars payload")
  return true
end function

// Verify loopback against the expected Quake behavior.
function testLoopback()
  state = netloop.createState()
  client = netloop.connect(state, "local")
  server = netloop.checkNewConnections(state)
  outgoing = sz.alloc(256)
  msg.writeString(outgoing, "hello")
  assertEqual(netloop.sendMessage(client, outgoing), 1, "loop send")
  incoming = sz.alloc(256)
  assertEqual(netloop.getMessage(server, incoming), 1, "loop receive type")
  reader = msg.beginReading(incoming)
  assertEqual(msg.readString(reader), "hello", "loop payload")
  assertEqual(netloop.canSendMessage(client), true, "loop can send restored")
  return true
end function

// Verify memory lifetimes against the expected Quake behavior.
function testMemoryLifetimes()
  state = memory.create(256)
  mark = memory.lowMark(state)
  first = memory.hunkAllocName(state, 32, "first")
  second = memory.zoneMalloc(state, 16, "zone")
  assertEqual(len(first.data), 32, "hunk payload")
  assertEqual(memory.used(state), 48, "memory used")
  cache = memory.cacheAlloc(state, 24, "sound/cache")
  assertEqual(memory.used(state), 72, "memory plus cache")
  assertEqual(len(memory.cacheCheck(state, cache)), 24, "cache check")
  memory.cacheFree(cache)
  memory.freeToLowMark(state, mark)
  assertEqual(first.alive, false, "hunk freed to mark")
  assertEqual(second.alive, true, "zone lifetime is independent of hunk mark")
  memory.zoneFree(second)
  assertEqual(second.alive, false, "Z_Free releases zone block")
  assertEqual(memory.used(state), 0, "memory reclaimed")

  managedState = memory.create(512)
  managed = sz.allocHunkManaged(managedState, 1)
  managedBuffer = managed[0]
  managedBlock = managed[1]
  assertEqual(managedBuffer.maxSize, 256, "SZ_Alloc managed minimum")
  assertEqual(managedBlock.name, "sizebuf", "SZ_Alloc hunk name")
  msg.writeByte(managedBuffer, 77)
  assertEqual(managedBlock.data[0], 77, "SZ_Alloc shares hunk payload")
  return true
end function

// Verify box hull against the expected Quake behavior.
function testBoxHull()
  box = hull.createBoxHull(t.Vec3(-1.0, -2.0, -3.0), t.Vec3(1.0, 2.0, 3.0))
  assertEqual(hull.truePointContents(box, t.Vec3(0.0, 0.0, 0.0)), c.CONTENTS_SOLID, "box interior")
  assertEqual(hull.truePointContents(box, t.Vec3(2.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "box exterior")
  trace = hull.traceLine(box, t.Vec3(2.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  assertEqual(trace.startSolid, false, "trace starts outside")
  assertTrue(trace.fraction > 0.0 and trace.fraction < 1.0, "trace impact fraction")
  assertNear(trace.endPosition.x, 1.03125, 0.05, "trace impact x")
  return true
end function

// Verify bsp entity and pvs against the expected Quake behavior.
function testBspEntityAndPvs()
  entities = bsp.parseEntities("{\n\"classname\" \"worldspawn\"\n\"origin\" \"1 2 3\"\n}\n")
  assertEqual(len(entities), 1, "entity count")
  assertEqual(bsp.entityValue(entities[0], "classname"), "worldspawn", "entity classname")
  origin = bsp.entityVector(entities[0], "origin")
  assertEqual(origin.x, 1.0, "entity origin x")
  assertEqual(origin.y, 2.0, "entity origin y")
  assertEqual(origin.z, 3.0, "entity origin z")
  escapedEntities = bsp.parseEntities("{\n\"message\" \"line1\\nline2\"\n\"path\" \"a\\tb\"\n}\n")
  assertEqual(bsp.entityValue(escapedEntities[0], "message"), "line1\nline2", "ED_NewString newline escape")
  assertEqual(bsp.entityValue(escapedEntities[0], "path"), "a\\b", "ED_NewString non-newline escape")
  decompressed = bsp.decompressVisibility(bytes([1, 0, 3, 2]), 0, 5)
  assertEqual(decompressed[0], 1, "PVS literal")
  assertEqual(decompressed[1], 0, "PVS run 1")
  assertEqual(decompressed[3], 0, "PVS run 3")
  assertEqual(decompressed[4], 2, "PVS trailing literal")
  noVis = bsp.Mod_DecompressVis(bytes(), -1, 9)
  assertEqual(len(noVis), 2, "Mod_DecompressVis row ceiling")
  assertEqual(noVis[1], 255, "Mod_DecompressVis null row")

  textures = [
    t.BspTexture("+0fixture", 16, 16, [40, 296, 360, 376], bytes(256)),
    t.BspTexture("+1fixture", 16, 16, [40, 296, 360, 376], bytes(256)),
    t.BspTexture("+Afixture", 16, 16, [40, 296, 360, 376], bytes(256)),
    t.BspTexture("+Bfixture", 16, 16, [40, 296, 360, 376], bytes(256)),
  ]
  animation = bsp.sequenceTextureAnimations(textures)
  assertEqual(nativeRawValue(bsp.sequenceTextureAnimations(textures)), nativeRawValue(animation), "texture animation table cache")
  assertEqual(animation[0][0], 4, "texture animation total")
  assertEqual(animation[0][3], 1, "texture animation next link")
  assertEqual(animation[0][4], 2, "texture animation alternate link")
  assertEqual(bsp.textureAnimationIndex(textures, 0, 0.25, false), 1, "texture animation regular frame")
  assertEqual(bsp.textureAnimationIndex(textures, 0, 0.25, true), 3, "texture animation alternate frame")
  missingAnimation = try(bsp.sequenceTextureAnimations([
    t.BspTexture("+0broken", 16, 16, [40, 296, 360, 376], bytes(256)),
    t.BspTexture("+2broken", 16, 16, [40, 296, 360, 376], bytes(256)),
  ]))
  assertTrue(missingAnimation is error, "texture animation rejects missing frame")

  submodelBytes = bytes(64)
  bio.putF32(submodelBytes, 0, -4.0)
  bio.putF32(submodelBytes, 12, 8.0)
  parsedSubmodels = bsp.Mod_LoadSubmodels(submodelBytes, t.Lump(0, 64))
  assertEqual(parsedSubmodels[0].mins.x, -5.0, "submodel minimum spread")
  assertEqual(parsedSubmodels[0].maxs.x, 9.0, "submodel maximum spread")
  assertNear(worldBsp.RadiusFromBounds(t.Vec3(-3.0, -4.0, 0.0), t.Vec3(2.0, 1.0, 12.0)), 13.0, 0.00001, "RadiusFromBounds")

  skin = bytes([1, 1, 1, 1])
  mdl.Mod_FloodFillSkin(skin, 2, 2)
  assertEqual(hex(skin), "00000000", "alias skin flood fill")

  aliasBytes = bytes(436)
  aliasBytes[0] = 73; aliasBytes[1] = 68; aliasBytes[2] = 80; aliasBytes[3] = 79
  bio.putU32(aliasBytes, 4, c.MDL_VERSION)
  bio.putF32(aliasBytes, 8, 1.0); bio.putF32(aliasBytes, 12, 1.0); bio.putF32(aliasBytes, 16, 1.0)
  bio.putU32(aliasBytes, 48, 1)
  bio.putU32(aliasBytes, 52, 16)
  bio.putU32(aliasBytes, 56, 16)
  bio.putU32(aliasBytes, 60, 3)
  bio.putU32(aliasBytes, 64, 1)
  bio.putU32(aliasBytes, 68, 1)
  bio.putF32(aliasBytes, 80, 11.0)
  // skin type at 84, then 256 texels, three stverts and one triangle.
  triangleOffset = 84 + 4 + 256 + 36
  bio.putU32(aliasBytes, triangleOffset, 1)
  bio.putU32(aliasBytes, triangleOffset + 4, 0)
  bio.putU32(aliasBytes, triangleOffset + 8, 1)
  bio.putU32(aliasBytes, triangleOffset + 12, 2)
  frameTypeOffset = triangleOffset + 16
  bio.putU32(aliasBytes, frameTypeOffset, 0)
  aliasModel = mdl.Mod_LoadAliasModel(aliasBytes, "progs/fixture.mdl")
  assertEqual(aliasModel.numVertices, 3, "alias model vertex count")
  assertNear(aliasModel.size, 1.0, 0.000001, "alias base size ratio")

  invalidSpriteGroup = bytes(8)
  bio.putU32(invalidSpriteGroup, 0, 1)
  bio.putF32(invalidSpriteGroup, 4, 0.0)
  spriteInterval = try(sprite.Mod_LoadSpriteGroup(invalidSpriteGroup, 0))
  assertTrue(spriteInterval is error, "sprite group rejects non-positive interval")
  spriteBytes = bytes(312)
  spriteBytes[0] = 73; spriteBytes[1] = 68; spriteBytes[2] = 83; spriteBytes[3] = 80
  bio.putU32(spriteBytes, 4, c.SPRITE_VERSION)
  bio.putU32(spriteBytes, 16, 16)
  bio.putU32(spriteBytes, 20, 16)
  bio.putU32(spriteBytes, 24, 1)
  // single-frame type and frame dimensions
  bio.putU32(spriteBytes, 36, 0)
  bio.putU32(spriteBytes, 48, 16)
  bio.putU32(spriteBytes, 52, 16)
  spriteModel = sprite.Mod_LoadSpriteModel(spriteBytes, "progs/fixture.spr")
  assertEqual(spriteModel.numFrames, 1, "sprite model frame count")
  spriteBounds = sprite.spriteModelBounds(spriteModel)
  assertEqual(spriteBounds[0].x, -8.0, "sprite model minimum")

  registry = modelRegistry.create()
  upper = modelRegistry.registerTyped(registry, "PROGS/PLAYER.MDL", "alias-cache", modelRegistry.MOD_ALIAS)
  lower = modelRegistry.Mod_FindName(registry, "progs/player.mdl")
  assertTrue(upper != lower, "model registry strcmp identity")
  modelRegistry.registerTyped(registry, "maps/start.bsp", "brush-cache", modelRegistry.MOD_BRUSH)
  modelRegistry.Mod_ClearAll(registry)
  assertEqual(registry.needLoad[upper], false, "alias cache survives Mod_ClearAll")
  assertEqual(registry.needLoad[modelRegistry.findIndex(registry, "maps/start.bsp")], true, "brush model reloads after Mod_ClearAll")

  // Regression for a real BSP leaf count that is not byte aligned.
  // The old '/' calculation produced 2.125 for 10 visible leafs, so
  // bytes(rowBytes) returned void and the first zero-run write failed.
  zero = t.Vec3(0.0, 0.0, 0.0)
  model = t.BspModel(zero, zero, zero, [0, 0, 0, 0], 10, 0, 0)
  leaf0 = t.BspLeaf(c.CONTENTS_SOLID, -1, zero, zero, 0, 0, bytes(4))
  leaf1 = t.BspLeaf(c.CONTENTS_EMPTY, 0, zero, zero, 0, 0, bytes(4))
  map = t.BspMap(
    "synthetic-pvs.bsp", bytes(), c.BSP_VERSION, [], "", [], [], [], [],
    bytes([0, 2]), [], [], [], bytes(), [], [leaf0, leaf1], [], [], [], [model],
  )
  leafPvs = worldBsp.leafPvs(map, 1)
  assertEqual(typeof(leafPvs), "bytes", "PVS row target type")
  assertEqual(len(leafPvs), 2, "PVS row ceiling bytes")
  assertEqual(leafPvs[0], 0, "PVS row zero byte 0")
  assertEqual(leafPvs[1], 0, "PVS row zero byte 1")
  assertTrue(bsp.validLeafVisibilityOffset(-1, 0), "BSP29 no-PVS sentinel")
  assertTrue(bsp.validLeafVisibilityOffset(0, 0), "external BSP accepts empty VIS at offset zero")
  assertTrue(not bsp.validLeafVisibilityOffset(1, 0), "empty VIS rejects non-zero offset")
  assertTrue(bsp.validLeafVisibilityOffset(1, 2), "non-empty VIS accepts in-range offset")
  assertTrue(not bsp.validLeafVisibilityOffset(2, 2), "non-empty VIS rejects end offset")
  return true
end function

// Create and initialize synthetic wav.
function makeSyntheticWav()
  data = bytes(48)
  bio.copyInto(data, 0, bytes("RIFF"), 0, 4)
  bio.putU32(data, 4, 40)
  bio.copyInto(data, 8, bytes("WAVE"), 0, 4)
  bio.copyInto(data, 12, bytes("fmt "), 0, 4)
  bio.putU32(data, 16, 16)
  bio.putU16(data, 20, 1)
  bio.putU16(data, 22, 1)
  bio.putU32(data, 24, 11025)
  bio.putU32(data, 28, 11025)
  bio.putU16(data, 32, 1)
  bio.putU16(data, 34, 8)
  bio.copyInto(data, 36, bytes("data"), 0, 4)
  bio.putU32(data, 40, 4)
  data[44] = 128
  data[45] = 129
  data[46] = 127
  data[47] = 255
  return data
end function


// Create and initialize looped synthetic wav.
function makeLoopedSyntheticWav()
  data = bytes(122)
  bio.copyInto(data, 0, bytes("RIFF"), 0, 4)
  bio.putU32(data, 4, 114)
  bio.copyInto(data, 8, bytes("WAVE"), 0, 4)

  bio.copyInto(data, 12, bytes("fmt "), 0, 4)
  bio.putU32(data, 16, 16)
  bio.putU16(data, 20, 1)
  bio.putU16(data, 22, 1)
  bio.putU32(data, 24, 11025)
  bio.putU32(data, 28, 11025)
  bio.putU16(data, 32, 1)
  bio.putU16(data, 34, 8)

  bio.copyInto(data, 36, bytes("cue "), 0, 4)
  bio.putU32(data, 40, 28)
  bio.putI32(data, 68, 2)

  bio.copyInto(data, 72, bytes("LIST"), 0, 4)
  bio.putU32(data, 76, 24)
  bio.putI32(data, 96, 4)
  bio.copyInto(data, 100, bytes("mark"), 0, 4)

  bio.copyInto(data, 104, bytes("data"), 0, 4)
  bio.putU32(data, 108, 10)
  index = 0
  while index < 10
    data[112 + index] = 128 + index
    index = index + 1
  end while
  return data
end function

// Verify wave against the expected Quake behavior.
function testWave()
  data = makeSyntheticWav()
  info = wav.parse(data, "synthetic.wav")
  assertEqual(info.rate, 11025, "wave rate")
  assertEqual(info.width, 1, "wave width")
  assertEqual(info.channels, 1, "wave channels")
  assertEqual(info.samples, 4, "wave samples")
  converted = wav.resample(info, data, 11025, false)
  assertEqual(len(converted), 4, "wave resample length")
  assertEqual(converted[0], 0, "wave sample zero")
  assertEqual(converted[1], 1, "wave positive sample")
  assertEqual(converted[2], 255, "wave negative sample")

  looped = makeLoopedSyntheticWav()
  loopInfo = wav.parse(looped, "looped.wav")
  assertEqual(loopInfo.loopStart, 2, "wave cue loop start")
  assertEqual(loopInfo.samples, 6, "wave LIST/mark loop length")
  loopPcm = wav.resample(loopInfo, looped, 11025, false)
  assertEqual(len(loopPcm), 6, "wave loop tail is trimmed")
  return true
end function

// Verify demo roundtrip against the expected Quake behavior.
function testDemoRoundtrip()
  recording = t.Demo(-1, [
    t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), bytes("abc")),
    t.DemoMessage(t.Vec3(-1.0, 2.5, 90.0), bytes([1, 2, 3, 4])),
  ], "-1\n")
  encoded = demo.serialize(recording)
  parsed = demo.parse(encoded)
  assertEqual(parsed.forcedTrack, -1, "demo track")
  assertEqual(len(parsed.messages), 2, "demo message count")
  assertEqual(parsed.messages[0].viewAngles.y, 20.0, "demo angle")
  assertEqual(decode(parsed.messages[0].payload), "abc", "demo payload")
  assertEqual(parsed.messages[1].payload[3], 4, "demo binary payload")
  return true
end function

// Verify server protocol against the expected Quake behavior.
function testServerProtocol()
  buffer = sz.alloc(256)
  msg.writeByte(buffer, c.SVC_VERSION)
  msg.writeLong(buffer, c.PROTOCOL_VERSION)
  msg.writeByte(buffer, c.SVC_TIME)
  msg.writeFloat(buffer, 1.25)
  msg.writeByte(buffer, c.SVC_PRINT)
  msg.writeString(buffer, "hello client")
  msg.writeByte(buffer, c.SVC_SETVIEW)
  msg.writeShort(buffer, 42)
  data = slice(buffer.data, 0, buffer.curSize)
  parsed = protocol.parse(data)
  assertEqual(len(parsed.events), 4, "protocol event count")
  assertEqual(parsed.events[0].command, "svc_version", "protocol version command")
  assertEqual(parsed.events[0].payload, c.PROTOCOL_VERSION, "protocol version payload")
  assertEqual(parsed.events[1].payload, 1.25, "protocol time")
  assertEqual(parsed.events[2].payload, "hello client", "protocol print")
  assertEqual(parsed.events[3].payload, 42, "protocol setview")
  return true
end function


// Create and initialize large synthetic progs.
function makeLargeSyntheticProgs(statementCount)
  sectionEnd = 60 + statementCount * 8
  // dprograms_t requires the first string-table byte to be the empty string.
  // Keep the large statement allocation while emitting a minimally valid
  // one-byte string lump and a zero-length globals lump after it.
  data = bytes(sectionEnd + 1)
  bio.putI32(data, 0, c.PROG_VERSION)
  bio.putI32(data, 4, 5927)
  bio.putI32(data, 8, 60)
  bio.putI32(data, 12, statementCount)
  bio.putI32(data, 16, sectionEnd)
  bio.putI32(data, 20, 0)
  bio.putI32(data, 24, sectionEnd)
  bio.putI32(data, 28, 0)
  bio.putI32(data, 32, sectionEnd)
  bio.putI32(data, 36, 0)
  bio.putI32(data, 40, sectionEnd)
  bio.putI32(data, 44, 1)
  bio.putI32(data, 48, sectionEnd + 1)
  bio.putI32(data, 52, 0)
  bio.putI32(data, 56, 1)
  data[sectionEnd] = 0
  return data
end function

// Exercise reentrant execute builtin as part of this deterministic regression fixture.
function reentrantExecuteBuiltin(machine)
  vm.execute(machine, 2)
  return true
end function

// Verify quake carithmetic against the expected Quake behavior.
function testQuakeCArithmetic()
  statements = [
    t.QuakeCStatement(op.OP_ADD_F, 30, 31, 32),
    t.QuakeCStatement(op.OP_RETURN, 32, 0, 0),
  ]
  dummy = t.QuakeCFunction(0, 0, 0, 0, 0, 0, 0, [])
  entry = t.QuakeCFunction(0, 0, 0, 0, 0, 0, 0, [])
  globals = vm.zeroArray(64)
  program = t.QuakeCProgram("synthetic.dat", bytes(), 6, 0, statements, [], [], [dummy, entry], bytes(1), globals, 16)
  machine = vm.create(program, 2)
  vm.setGlobalFloat(machine, 30, 2.0)
  vm.setGlobalFloat(machine, 31, 3.5)
  vm.execute(machine, 1)
  assertEqual(vm.returnFloat(machine), 5.5, "QuakeC OP_ADD_F")
  assertEqual(machine.program.functions[1].profile, 2, "QuakeC function profiling")

  // walkmove/movetogoal can relink an edict and execute a trigger's touch
  // function while the calling QuakeC program is still running.  The nested
  // PR_ExecuteProgram must unwind only its own frame and resume its caller.
  reentrantStatements = [
    t.QuakeCStatement(op.OP_CALL0, 40, 0, 0),
    t.QuakeCStatement(op.OP_ADD_F, 30, 31, 32),
    t.QuakeCStatement(op.OP_RETURN, 32, 0, 0),
    t.QuakeCStatement(op.OP_ADD_F, 33, 34, 35),
    t.QuakeCStatement(op.OP_RETURN, 35, 0, 0),
  ]
  outerFunction = t.QuakeCFunction(0, 0, 0, 0, "outer", "synthetic.qc", 0, [])
  nestedFunction = t.QuakeCFunction(3, 0, 0, 0, "nested_touch", "synthetic.qc", 0, [])
  builtinFunction = t.QuakeCFunction(-1, 0, 0, 0, "nested_builtin", "synthetic.qc", 0, [])
  reentrantProgram = t.QuakeCProgram(
    "reentrant.dat",
    bytes(),
    6,
    0,
    reentrantStatements,
    [],
    [],
    [dummy, outerFunction, nestedFunction, builtinFunction],
    bytes(1),
    vm.zeroArray(64),
    16,
  )
  reentrantMachine = vm.create(reentrantProgram, 2)
  reentrantMachine.builtins = [qcb.fixme, reentrantExecuteBuiltin]
  vm.setWord(reentrantMachine, 40, 3)
  vm.setGlobalFloat(reentrantMachine, 30, 2.0)
  vm.setGlobalFloat(reentrantMachine, 31, 3.5)
  vm.setGlobalFloat(reentrantMachine, 33, 7.0)
  vm.setGlobalFloat(reentrantMachine, 34, 8.0)
  vm.execute(reentrantMachine, 1)
  assertEqual(vm.returnFloat(reentrantMachine), 5.5, "QuakeC reentrant caller result")
  assertEqual(vm.globalFloat(reentrantMachine, 35), 15.0, "QuakeC nested callback result")
  assertEqual(len(reentrantMachine.callStack), 0, "QuakeC reentrant stack unwind")

  // pr_exec.c branches on eval_t._int, not its float interpretation.  The
  // sign bit alone is negative zero as a float, but remains a true QC word.
  branchStatements = [
    t.QuakeCStatement(op.OP_IF, 40, 2, 0),
    t.QuakeCStatement(op.OP_RETURN, 30, 0, 0),
    t.QuakeCStatement(op.OP_RETURN, 31, 0, 0),
  ]
  branchProgram = t.QuakeCProgram("branch.dat", bytes(), 6, 0, branchStatements, [], [], [dummy, entry], bytes(1), vm.zeroArray(64), 16)
  branchMachine = vm.create(branchProgram, 2)
  vm.setGlobalFloat(branchMachine, 30, 10.0)
  vm.setGlobalFloat(branchMachine, 31, 20.0)
  vm.setWord(branchMachine, 40, 0x80000000)
  vm.execute(branchMachine, 1)
  assertEqual(vm.returnFloat(branchMachine), 20.0, "QuakeC OP_IF raw word truth")

  branchMachine.argCount = 3
  vm.setWord(branchMachine, op.OFS_PARM0, vm.internString(branchMachine, "one"))
  vm.setWord(branchMachine, op.OFS_PARM0 + 3, vm.internString(branchMachine, " two"))
  vm.setWord(branchMachine, op.OFS_PARM0 + 6, vm.internString(branchMachine, " three"))
  assertEqual(qcb.varString(branchMachine, 0), "one two three", "QuakeC PF_VarString")
  assertEqual(qcb.fixedOneDecimal(1.26), "  1.3", "QuakeC percent-5.1f formatting")
  assertEqual(qcb.fixedOneDecimal(-12.34), "-12.3", "QuakeC negative percent-5.1f formatting")
  vm.setVector(branchMachine, op.OFS_PARM0, t.Vec3(1.0, 2.0, 0.0))
  qcb.vectorYawBuiltin(branchMachine)
  assertEqual(vm.returnFloat(branchMachine), 63.0, "QuakeC vectoyaw integer truncation")
  missingBuiltin = try(qcb.fixme(branchMachine))
  assertTrue(missingBuiltin is error, "QuakeC reserved builtin errors")

  // PR_EnterFunction overlays each callee's parm/local area, then restores
  // the caller's words on return.  The return value proves that the inner
  // parameter copy did not permanently replace outer local 40.
  localStatements = [
    t.QuakeCStatement(op.OP_CALL1, 50, 0, 0),
    t.QuakeCStatement(op.OP_ADD_F, op.OFS_RETURN, 40, 60),
    t.QuakeCStatement(op.OP_RETURN, 60, 0, 0),
    t.QuakeCStatement(op.OP_RETURN, 40, 0, 0),
  ]
  localOuter = t.QuakeCFunction(0, 40, 2, 0, "local_outer", "synthetic.qc", 0, [])
  localInner = t.QuakeCFunction(3, 40, 2, 0, "local_inner", "synthetic.qc", 1, [1])
  localProgram = t.QuakeCProgram("locals.dat", bytes(), 6, 0, localStatements, [], [], [dummy, localOuter, localInner], bytes(1), vm.zeroArray(64), 16)
  localMachine = vm.create(localProgram, 2)
  vm.setGlobalFloat(localMachine, 40, 7.0)
  vm.setGlobalFloat(localMachine, op.OFS_PARM0, 42.0)
  vm.setWord(localMachine, 50, 2)
  vm.execute(localMachine, 1)
  assertEqual(vm.returnFloat(localMachine), 49.0, "QuakeC parameter overlay and local restore")

  // pr_exec.c has hard compatibility limits: depth 32 is rejected after the
  // increment, and the shared locals stack contains 2048 words.
  depthProgram = t.QuakeCProgram("depth.dat", bytes(), 6, 0, [], [], [], [dummy, entry], bytes(1), vm.zeroArray(64), 16)
  depthMachine = vm.create(depthProgram, 1)
  depth = 0
  while depth < 31
    vm.enterFunction(depthMachine, 1)
    depth = depth + 1
  end while
  depthOverflow = try(vm.enterFunction(depthMachine, 1))
  assertTrue(depthOverflow is error, "QuakeC MAX_STACK_DEPTH")
  hugeLocals = t.QuakeCFunction(0, 40, 2049, 0, "huge_locals", "synthetic.qc", 0, [])
  localLimitProgram = t.QuakeCProgram("local-limit.dat", bytes(), 6, 0, [], [], [], [dummy, hugeLocals], bytes(1), vm.zeroArray(64), 16)
  localLimitMachine = vm.create(localLimitProgram, 1)
  localOverflow = try(vm.enterFunction(localLimitMachine, 1))
  assertTrue(localOverflow is error, "QuakeC LOCALSTACK_SIZE")

  // ED_Find* is strcmp-based.  A field value is parsed through G_INT at the
  // referenced field's offset, and ED_Free preserves non-runtime fields until
  // the slot is allocated again.
  semanticGlobals = [
    t.QuakeCDef(c.EV_ENTITY, c.QC_GLOBAL_SELF, 0, "self"),
  ]
  semanticFields = [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_STRING, 1, 0, "classname"),
    t.QuakeCDef(c.EV_STRING, 2, 0, "model"),
    t.QuakeCDef(c.EV_FLOAT, 3, 0, "nextthink"),
    t.QuakeCDef(c.EV_VECTOR, 4, 0, "origin"),
    t.QuakeCDef(c.EV_VECTOR, 7, 0, "angles"),
    t.QuakeCDef(c.EV_FLOAT, 10, 0, "solid"),
    t.QuakeCDef(c.EV_FLOAT, 11, 0, "flags"),
    t.QuakeCDef(c.EV_FLOAT, 12, 0, "target_field"),
    t.QuakeCDef(c.EV_FIELD, 13, 0, "field_holder"),
    t.QuakeCDef(c.EV_ENTITY, 14, 0, "entity_holder"),
  ]
  semanticFunction = t.QuakeCFunction(0, 0, 0, 0, "ExactFunction", "synthetic.qc", 0, [])
  semanticProgram = t.QuakeCProgram("edict-semantics.dat", bytes(), 6, 0, [], semanticGlobals, semanticFields, [dummy, semanticFunction], bytes(1), vm.zeroArray(64), 16)
  semanticMachine = vm.create(semanticProgram, 3)
  semanticMachine.edictFree[1] = false
  vm.setWord(semanticMachine, 12, 9)
  assertEqual(qcedict.setKeyValue(semanticMachine, 1, "field_holder", "target_field"), true, "QuakeC field epair accepted")
  assertEqual(vm.entityField(semanticMachine, 1, 13), 9, "QuakeC field epair uses G_INT(def->ofs)")
  assertEqual(qcedict.setKeyValue(semanticMachine, 1, "Classname", "wrong"), false, "QuakeC field lookup is case-sensitive")
  assertEqual(vm.functionIndex(semanticMachine, "exactfunction"), 0, "QuakeC function lookup is case-sensitive")
  assertEqual(vm.functionIndex(semanticMachine, "ExactFunction"), 1, "QuakeC exact function lookup")
  missingFieldValue = try(qcedict.setKeyValue(semanticMachine, 1, "field_holder", "missing_field"))
  assertTrue(missingFieldValue is error, "QuakeC bad field epair is fatal")
  qcedict.setKeyValue(semanticMachine, 1, "entity_holder", "2.9")
  assertEqual(vm.entityField(semanticMachine, 1, 14), 2, "QuakeC entity epair uses atoi semantics")
  vm.setEntityString(semanticMachine, 1, 1, "preserved")
  vm.setEntityString(semanticMachine, 1, 2, "progs/test.mdl")
  vm.setEntityFloat(semanticMachine, 1, 3, 12.0)
  qcedict.free(semanticMachine, 1)
  assertEqual(vm.entityString(semanticMachine, 1, 1), "preserved", "ED_Free preserves classname")
  assertEqual(vm.entityField(semanticMachine, 1, 2), 0, "ED_Free clears model")
  assertEqual(vm.entityFloat(semanticMachine, 1, 3), -1.0, "ED_Free disables nextthink")
  assertEqual(semanticMachine.edictFree[1], true, "ED_Free marks slot free")

  qcb.bind(void)
  vm.setWord(semanticMachine, c.QC_GLOBAL_SELF, 1)
  vm.setGlobalFloat(semanticMachine, op.OFS_PARM0, 90.0)
  vm.setGlobalFloat(semanticMachine, op.OFS_PARM0 + 3, 16.0)
  qcb.walkMoveBuiltin(semanticMachine)
  assertEqual(vm.returnFloat(semanticMachine), 0.0, "PF_walkmove rejects airborne non-fly/non-swim entity")
  assertEqual(qcb.precacheIndex(["Progs/Test.mdl"], "progs/test.mdl"), -1, "precache lookup is case-sensitive")
  assertEqual(qcb.badPrecacheString(" model.mdl"), true, "precache rejects leading whitespace")

  aliasBounds = qcb.modelBounds(semanticMachine, "progs/player.mdl")
  assertEqual(aliasBounds[0].x, -16.0, "MiniQuake alias model minimum bound")
  assertEqual(aliasBounds[1].z, 16.0, "MiniQuake alias model maximum bound")
  brushHeaderSize = 4 + c.HEADER_LUMPS * 8
  brushData = bytes(brushHeaderSize + 64)
  bio.putI32(brushData, 0, c.BSP_VERSION)
  bio.putI32(brushData, 4 + c.LUMP_MODELS * 8, brushHeaderSize)
  bio.putI32(brushData, 8 + c.LUMP_MODELS * 8, 64)
  bio.putF32(brushData, brushHeaderSize, 0.0)
  bio.putF32(brushData, brushHeaderSize + 4, -16.0)
  bio.putF32(brushData, brushHeaderSize + 8, -24.0)
  bio.putF32(brushData, brushHeaderSize + 12, 32.0)
  bio.putF32(brushData, brushHeaderSize + 16, 16.0)
  bio.putF32(brushData, brushHeaderSize + 20, 40.0)
  brushBounds = qcb.brushModelBounds(brushData, "maps/fixture.bsp")
  assertEqual(brushBounds[0].x, -1.0, "QuakeC external BSP expanded minimum x")
  assertEqual(brushBounds[0].z, -25.0, "QuakeC external BSP expanded minimum z")
  assertEqual(brushBounds[1].x, 33.0, "QuakeC external BSP expanded maximum x")
  assertEqual(brushBounds[1].z, 41.0, "QuakeC external BSP expanded maximum z")
  assertEqual(vm.PR_PrintStatement(branchMachine, branchStatements[0]), "IF         40(???)              branch 2", "PR_PrintStatement branch fixture")
  assertEqual(vm.PR_StackTrace(branchMachine)[0], "<NO STACK>", "PR_StackTrace empty fixture")
  profileLines = vm.PR_Profile_f(reentrantMachine)
  assertTrue(len(profileLines) > 0, "PR_Profile_f emits executed functions")
  assertEqual(reentrantMachine.program.functions[1].profile, 0, "PR_Profile_f clears counters")
  runErrorResult = try(vm.PR_RunError(depthMachine, "synthetic failure"))
  assertTrue(runErrorResult is error, "PR_RunError is terminal")
  assertEqual(len(depthMachine.callStack), 0, "PR_RunError clears execution depth")

  qcedict.ED_ClearEdict(semanticMachine, 1)
  vm.setEntityString(semanticMachine, 1, 1, "fixture")
  printedEdict = qcedict.ED_Print(semanticMachine, 1)
  assertTrue(len(bytes(printedEdict)) > 0, "ED_Print fixture")
  writtenEdict = qcedict.ED_Write(semanticMachine, 1)
  assertTrue(len(bytes(writtenEdict)) > 0, "ED_Write fixture")
  assertEqual(qcedict.ED_FindField(semanticMachine, "classname").offset, 1, "ED_FindField fixture")
  assertEqual(qcedict.ED_NewString("a\\nb"), "a\nb", "ED_NewString direct fixture")
  edictCounts = qcedict.ED_Count(semanticMachine)
  assertEqual(edictCounts[0], 3, "ED_Count num_edicts fixture")
  assertTrue(edictCounts[1] >= 2, "ED_Count active fixture")

  // Large statement tables used to grow with `array + [item]`.  This count
  // reproduces the scale implied by the 126104-byte array request observed
  // during retail-data validation, without distributing any Quake data.
  statementCount = 15760
  largeProgram = progs.parse(makeLargeSyntheticProgs(statementCount), "large-synthetic.dat")
  assertEqual(len(largeProgram.statements), statementCount, "linear progs statement allocation")
  return true
end function

// Verify gl warp and rlight parity against the expected Quake behavior.
function testGlWarpAndRlightParity()
  drawPalette = bytes(768)
  paletteIndex = 0
  while paletteIndex < 256
    drawPalette[paletteIndex * 3] = paletteIndex
    drawPalette[paletteIndex * 3 + 1] = paletteIndex
    drawPalette[paletteIndex * 3 + 2] = paletteIndex
    paletteIndex = paletteIndex + 1
  end while
  draw2d.configureDraw(void, drawPalette, void)

  resampled8 = draw2d.GL_Resample8BitTexture(bytes([0, 1, 2, 3]), 2, 2, 4, 4)
  assertEqual(resampled8[0], 0, "8-bit resample top left")
  assertEqual(resampled8[2], 1, "8-bit resample horizontal selection")
  assertEqual(resampled8[15], 3, "8-bit resample bottom right")

  rgbaSource = bytes([
    0, 0, 0, 0,
    4, 4, 4, 4,
    8, 8, 8, 8,
    12, 12, 12, 12,
  ])
  mip = draw2d.GL_MipMap(rgbaSource, 2, 2)
  assertEqual(len(mip), 4, "RGBA mip dimensions")
  assertEqual(mip[0], 6, "RGBA mip average")
  indexedMip = draw2d.GL_MipMap8Bit(bytes([0, 8, 16, 24]), 2, 2)
  assertEqual(indexedMip[0], 12, "indexed mip palette quantization")

  draw2d.ResetScrap([101, 102])
  firstScrap = draw2d.Scrap_AllocBlock(8, 8)
  secondScrap = draw2d.Scrap_AllocBlock(8, 8)
  assertEqual(firstScrap[0], 0, "first scrap texture")
  assertEqual(firstScrap[1], 0, "first scrap x")
  assertEqual(firstScrap[2], 0, "first scrap y")
  assertEqual(secondScrap[1], 8, "second scrap packed x")
  assertEqual(secondScrap[2], 0, "second scrap packed y")

  tracePicture = t.MenuPicture("trace", 16, 8, 77)
  draw2d.registerDrawPicture(tracePicture, [0.25, 0.5, 0.75, 1.0], bytes(128))
  drawTrace = draw2d.Draw_PicTrace(10, 20, tracePicture, 32, 16, 200)
  assertEqual(drawTrace[0][1], 77, "draw trace texture")
  assertEqual(drawTrace[2][1], 0.25, "draw trace s0")
  assertEqual(drawTrace[2][2], 0.5, "draw trace t0")
  assertEqual(drawTrace[4][3], 42, "draw trace x1")
  assertEqual(drawTrace[4][4], 36, "draw trace y1")

  assertNear(screenCompat.CalcFov(90.0, 640.0, 480.0), 73.739795, 0.00001, "vertical field of view")
  screenCvars = cvar.createRegistry()
  cvar.register(screenCvars, cvar.create("viewsize", "80", true, false), commandNeverExists)
  cvar.register(screenCvars, cvar.create("fov", "90", false, false), commandNeverExists)
  cvar.register(screenCvars, cvar.create("scr_conspeed", "300", false, false), commandNeverExists)
  refdef = screenCompat.SCR_CalcRefdef(640, 480, screenCvars, 0)
  assertEqual(refdef[0], 64, "screen view x")
  assertEqual(refdef[1], 24, "screen view y")
  assertEqual(refdef[2], 512, "screen view width")
  assertEqual(refdef[3], 384, "screen view height")

  centerTrace = screenCompat.CenterStringTrace("AB\nC", 320, 200, 2, 1)
  assertEqual(len(centerTrace), 2, "slow center-print character budget")
  assertEqual(centerTrace[0][0], 152, "center-print first line x")
  assertEqual(centerTrace[0][2], 65, "center-print first character")
  dialogOrder = screenCompat.ScreenOverlayOrder(true, false, 0, true)
  assertEqual(dialogOrder[2], "dialog", "modal overlay branch")
  assertEqual(dialogOrder[4], "fade", "modal fade ordering")
  finaleOrder = screenCompat.ScreenOverlayOrder(false, false, 2, true)
  assertEqual(finaleOrder[2], "finale", "finale overlay branch")
  assertEqual(finaleOrder[3], "center", "finale slow-print ordering")

  tga = screenCompat.BuildTga(1, 1, bytes([1, 2, 3, 4]))
  assertEqual(len(tga), 21, "TGA screenshot length")
  assertEqual(tga[2], 2, "TGA uncompressed type")
  assertEqual(tga[16], 24, "TGA pixel size")
  assertEqual(tga[18], 3, "TGA blue channel")
  assertEqual(tga[19], 2, "TGA green channel")
  assertEqual(tga[20], 1, "TGA red channel")

  // Exact gl_warp_sin.h lookup and C integer masking.
  water = glWarp.WaterTexCoords(64.0, 0.0, 0.0)
  assertNear(water[0], 1.0, 0.000001, "water warp s")
  assertNear(water[1], 7.93984 / 64.0, 0.000001, "water warp table t")
  assertEqual(glWarp.WrappedSpeedScale(20.0, 8.0), 32.0, "sky speed wrap")

  zero = t.Vec3(0.0, 0.0, 0.0)
  vertices = [
    t.RenderVertex(t.Vec3(-64.0, -64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, -64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, 64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(-64.0, 64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
  ]
  polygons = glWarp.SubdividePolygon(vertices, 128.0)
  assertEqual(len(polygons), 4, "warp axial subdivision count")
  // Hunk insertion prepends leaves; the back/back quadrant is first.
  firstBounds = glWarp.BoundPoly(polygons[0])
  assertEqual(firstBounds[1].x, 0.0, "warp polygon chain x order")
  assertEqual(firstBounds[1].y, 0.0, "warp polygon chain y order")
  raw = glWarp.SurfaceWarpVertices(
    [t.RenderVertex(t.Vec3(4.0, 5.0, 6.0), 99.0, 99.0, 0.0, 0.0)],
    [1.0, 0.0, 0.0, 128.0],
    [0.0, 1.0, 0.0, 256.0],
  )
  assertEqual(raw[0].s, 4.0, "warp texture s excludes translation")
  assertEqual(raw[0].t, 5.0, "warp texture t excludes translation")
  waterTrace = glWarp.EmitWaterPolys([[t.RenderVertex(zero, 64.0, 0.0, 0.0, 0.0)]], 0.0)
  assertNear(waterTrace[0][0][1], 7.93984 / 64.0, 0.000001, "water command trace t")
  skyLayers = glWarp.EmitBothSkyLayers([[t.RenderVertex(t.Vec3(128.0, 0.0, 0.0), 0.0, 0.0, 0.0, 0.0)]], zero, 20.0)
  assertEqual(skyLayers[0], 32.0, "solid sky layer speed")
  assertEqual(skyLayers[2], 64.0, "alpha sky layer speed")

  palette = bytes(768)
  palette[6] = 20
  palette[7] = 21
  palette[8] = 22
  palette[9] = 30
  palette[10] = 31
  palette[11] = 32
  skySource = bytes(256 * 128)
  y = 0
  while y < 128
    x = 128
    while x < 256
      skySource[y * 256 + x] = 2
      x = x + 1
    end while
    y = y + 1
  end while
  skySource[1] = 3
  sky = t.BspTexture("skyfixture", 256, 128, [0, 0, 0, 0], skySource)
  skyPixels = glWarp.R_InitSkyPixels(sky, palette)
  assertEqual(skyPixels[0][0], 20, "solid sky red")
  assertEqual(skyPixels[0][3], 255, "solid sky alpha")
  assertEqual(skyPixels[1][0], 20, "transparent sky fringe average")
  assertEqual(skyPixels[1][3], 0, "transparent sky alpha")
  assertEqual(skyPixels[1][4], 30, "alpha sky source red")
  assertEqual(skyPixels[1][7], 255, "alpha sky opaque pixel")

  styles = glRlight.R_AnimateLight(["az", "mmn"], 0.1)
  assertEqual(styles[0], 25 * 22, "animated light z")
  assertEqual(styles[1], 12 * 22, "animated light m")
  blend = glRlight.AddLightBlend([0.1, 0.2, 0.3, 0.4], 1.0, 0.5, 0.0, 0.25)
  assertNear(blend[3], 0.55, 0.000001, "dlight blend alpha")
  assertNear(blend[0], 0.5636363636, 0.000001, "dlight blend red quirk")

  outsideLight = t.DynamicLight(t.Vec3(100.0, 0.0, 0.0), 10.0, 1.0, 0.0, 0.0, 0)
  fan = glRlight.R_RenderDlightTrace(
    outsideLight,
    0.0,
    zero,
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    [0.0, 0.0, 0.0, 0.0],
  )
  assertEqual(len(fan[2]), 18, "dlight triangle fan command vertices")
  assertNear(fan[2][0].x, 96.5, 0.000001, "dlight fan center")
  assertNear(fan[2][1].y, 3.5, 0.000001, "dlight fan first rim")
  dlightBatch = glRlight.R_RenderDlights(
    [outsideLight],
    0.0,
    zero,
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, 1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    [0.0, 0.0, 0.0, 0.0],
  )
  assertEqual(dlightBatch[0], 1, "dlight batch count")
  assertEqual(len(dlightBatch[2][0]), 18, "dlight batch command trace")

  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -1, -2, zero, zero, 0, 1)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  face = t.BspFace(0, 0, 0, 0, 0, bytes([0, 255, 255, 255]), 0)
  model = t.BspModel(zero, zero, zero, [0, 0, 0, 0], 0, 0, 1)
  lightMap = t.BspMap(
    "synthetic-light.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane], [], [], bytes(),
    [node], [info], [face], bytes([100, 0, 0, 0]), [], [], [], [], [], [model],
  )
  surface = t.RenderSurface(0, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, 0, 0, [], 0)
  bits = [0]
  frames = [0]
  marked = glRlight.R_MarkLights(lightMap, bits, frames, 7, outsideLight, 4, 0)
  assertEqual(marked, 1, "dlight marked surface count")
  assertEqual(bits[0], 4, "dlight surface bit")
  assertEqual(frames[0], 7, "dlight surface frame")
  pushed = glRlight.R_PushDlights(lightMap, bits, frames, 8, [outsideLight], 0.0, 0)
  assertEqual(pushed, 1, "active dlight push count")
  assertEqual(bits[0], 1, "active dlight push bit")
  sampled = glRlight.R_LightPoint(
    lightMap,
    [surface],
    styles,
    0,
    t.Vec3(0.0, 0.0, 10.0),
  )
  assertEqual(sampled[0], 214, "recursive styled light sample")
  assertEqual(sampled[1].z, 0.0, "recursive light spot")
  return true
end function

// Verify dimensions, edge rules and stable names for every texture scaler.
function testTextureUpscaling()
  fixture = bytes(3 * 3 * 4)
  pixel = 0
  while pixel < 9
    fixture[pixel * 4 + 2] = 255
    fixture[pixel * 4 + 3] = 255
    pixel = pixel + 1
  end while
  // A matching red north/west pair around the blue center exercises the
  // canonical ScaleNx corner rule and both edge-directed smoothers.
  north = (0 * 3 + 1) * 4
  west = (1 * 3 + 0) * 4
  fixture[north] = 255; fixture[north + 2] = 0
  fixture[west] = 255; fixture[west + 2] = 0

  assertEqual(textureUpscale.modeName(-12), "OFF", "upscale lower clamp")
  assertEqual(textureUpscale.modeName(99), "XBR4X", "upscale upper clamp")
  assertEqual(textureUpscale.scaleFactor(textureUpscale.UPSCALE_SCALE3X), 3, "Scale3x factor")

  nearest = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_NEAREST_2X)
  assertEqual(nearest[1], 6, "nearest width")
  assertEqual(nearest[2], 6, "nearest height")
  centerTopLeft = (2 * 6 + 2) * 4
  assertEqual(nearest[0][centerTopLeft + 2], 255, "nearest keeps center blue")

  scaled2 = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_SCALE2X)
  assertEqual(scaled2[1], 6, "Scale2x width")
  assertEqual(scaled2[0][centerTopLeft], 255, "Scale2x joins matching corner")
  assertEqual(scaled2[0][centerTopLeft + 4 + 2], 255, "Scale2x preserves unmatched corner")

  scaled3 = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_SCALE3X)
  assertEqual(scaled3[1], 9, "Scale3x width")
  assertEqual(scaled3[2], 9, "Scale3x height")
  assertEqual(scaled3[0][(3 * 9 + 3) * 4], 255, "Scale3x joins matching corner")

  hq2 = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_HQ2X)
  assertTrue(hq2[0][centerTopLeft] > 0, "HQ2x smooths diagonal red")
  assertTrue(hq2[0][centerTopLeft + 2] < 255, "HQ2x reduces diagonal blue")
  xbr2 = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_XBR2X)
  assertTrue(xbr2[0][centerTopLeft] > 0, "xBR2x smooths diagonal red")
  xbr4 = textureUpscale.apply(fixture, 3, 3, textureUpscale.UPSCALE_XBR4X)
  assertEqual(xbr4[1], 12, "xBR4x width")
  assertEqual(xbr4[2], 12, "xBR4x height")

  registry = cvar.createRegistry()
  registry.variables = [cvar.create("r_textureupscale", "2", true, false)]
  draw2d.configureDraw(void, bytes(768), registry)
  integrated = draw2d.GL_UpscaleTextureRgba(fixture, 3, 3)
  assertEqual(integrated[1], 6, "draw upload honors archived scale mode")
  assertEqual(integrated[0][centerTopLeft], 255, "draw upload applies selected algorithm")
  cvar.setValue(registry, "r_textureupscale", 0)
  unscaled = draw2d.GL_UpscaleTextureRgba(fixture, 3, 3)
  assertEqual(unscaled[1], 3, "draw upload preserves legacy size when disabled")

  invalid = try(textureUpscale.apply(bytes(3), 1, 1, textureUpscale.UPSCALE_SCALE2X))
  assertTrue(invalid is error, "truncated RGBA input is rejected")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  passed = 0
  print "MiniQuake core tests starting: 17"

  print "[01/17] CRC-CCITT"
  result = try(testCrc())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[02/17] byte I/O"
  result = try(testByteIo())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[03/17] Quake messages"
  result = try(testMessage())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[04/17] math"
  result = try(testMath())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[05/17] cvars"
  result = try(testCvar())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[06/17] PACK"
  result = try(testPack())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[07/17] WAD2"
  result = try(testWad())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[08/17] loopback network"
  result = try(testLoopback())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[09/17] memory lifetimes"
  result = try(testMemoryLifetimes())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[10/17] box hull"
  result = try(testBoxHull())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[11/17] BSP entities/PVS"
  result = try(testBspEntityAndPvs())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[12/17] WAV"
  result = try(testWave())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[13/17] DEM roundtrip"
  result = try(testDemoRoundtrip())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[14/17] protocol 15"
  result = try(testServerProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[15/17] QuakeC arithmetic"
  result = try(testQuakeCArithmetic())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[16/17] GL warp/light parity"
  result = try(testGlWarpAndRlightParity())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[17/17] texture upscaling"
  result = try(testTextureUpscaling())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "MiniQuake core tests passed: " + passed
  return 0
end function
