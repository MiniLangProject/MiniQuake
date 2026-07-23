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

import miniquake.types as t
import miniquake.constants as c
import miniquake.crc as crc
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.mathlib as math
import miniquake.cvar as cvar
import miniquake.pak as pak
import miniquake.wad as wad
import miniquake.graphics_data as graphicsData
import miniquake.net_loop as netloop
import miniquake.memory as memory
import miniquake.world_hull as hull
import miniquake.world_bsp as worldBsp
import miniquake.format.bsp as bsp
import miniquake.sound.wav as wav
import miniquake.demo as demo
import miniquake.client_protocol as protocol
import miniquake.quakec.opcodes as op
import miniquake.quakec.vm as vm
import miniquake.format.progs as progs

function assertEqual(actual, expected, name)
  if actual != expected then return error(9000, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9001, name + ": expected true") end if
  return true
end function

function assertNear(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0 then difference = -difference end if
  if difference > tolerance then
    return error(9002, name + ": expected " + expected + " +/- " + tolerance + ", got " + actual)
  end if
  return true
end function

function commandNeverExists(name)
  return false
end function

function testCrc()
  assertEqual(crc.block(bytes("123456789"), 0, 9), 0x29b1, "CRC-CCITT")
  return true
end function

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

  print "  [02.15] native C string return"
  assertEqual(native.asciiChar(65), "A", "native C string return")

  print "  [02.16] byte I/O complete"
  return true
end function

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
  return true
end function

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

function testCvar()
  registry = cvar.createRegistry()
  variable = cvar.create("test", "12.5", false, false)
  cvar.register(registry, variable, commandNeverExists)
  assertEqual(cvar.variableValue(registry, "test"), 12.5, "cvar value")
  cvar.set(registry, "test", "7")
  assertEqual(cvar.variableString(registry, "test"), "7", "cvar string")
  return true
end function

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

function testPack()
  archive = pak.parse(makeSyntheticPack(), "synthetic.pak")
  assertEqual(archive.numFiles, 1, "pack count")
  assertEqual(decode(pak.readFile(archive, "maps/test.bsp")), "hello", "pack data")
  return true
end function

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
  filesystem = t.FileSystem("", "id1", [t.SearchPath("", packArchive)])
  conchars = graphicsData.readConsoleCharacters(filesystem)
  assertEqual(len(conchars), 8, "gfx.wad conchars size")
  assertEqual(bio.i32(conchars, 0), 320, "gfx.wad conchars payload")
  return true
end function

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
  assertEqual(second.alive, false, "zone freed to mark")
  assertEqual(memory.used(state), 0, "memory reclaimed")
  return true
end function

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

function testBspEntityAndPvs()
  entities = bsp.parseEntities("{\n\"classname\" \"worldspawn\"\n\"origin\" \"1 2 3\"\n}\n")
  assertEqual(len(entities), 1, "entity count")
  assertEqual(bsp.entityValue(entities[0], "classname"), "worldspawn", "entity classname")
  origin = bsp.entityVector(entities[0], "origin")
  assertEqual(origin.x, 1.0, "entity origin x")
  assertEqual(origin.y, 2.0, "entity origin y")
  assertEqual(origin.z, 3.0, "entity origin z")
  decompressed = bsp.decompressVisibility(bytes([1, 0, 3, 2]), 0, 5)
  assertEqual(decompressed[0], 1, "PVS literal")
  assertEqual(decompressed[1], 0, "PVS run 1")
  assertEqual(decompressed[3], 0, "PVS run 3")
  assertEqual(decompressed[4], 2, "PVS trailing literal")

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
  return true
end function

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

function testDemoRoundtrip()
  recording = t.Demo(-1, [
    t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), bytes("abc")),
    t.DemoMessage(t.Vec3(-1.0, 2.5, 90.0), bytes([1, 2, 3, 4])),
  ])
  encoded = demo.serialize(recording)
  parsed = demo.parse(encoded)
  assertEqual(parsed.forcedTrack, -1, "demo track")
  assertEqual(len(parsed.messages), 2, "demo message count")
  assertEqual(parsed.messages[0].viewAngles.y, 20.0, "demo angle")
  assertEqual(decode(parsed.messages[0].payload), "abc", "demo payload")
  assertEqual(parsed.messages[1].payload[3], 4, "demo binary payload")
  return true
end function

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


function makeLargeSyntheticProgs(statementCount)
  data = bytes(60 + statementCount * 8)
  bio.putI32(data, 0, c.PROG_VERSION)
  bio.putI32(data, 4, 5927)
  sectionEnd = 60 + statementCount * 8
  bio.putI32(data, 8, 60)
  bio.putI32(data, 12, statementCount)
  bio.putI32(data, 16, sectionEnd)
  bio.putI32(data, 20, 0)
  bio.putI32(data, 24, sectionEnd)
  bio.putI32(data, 28, 0)
  bio.putI32(data, 32, sectionEnd)
  bio.putI32(data, 36, 0)
  bio.putI32(data, 40, sectionEnd)
  bio.putI32(data, 44, 0)
  bio.putI32(data, 48, sectionEnd)
  bio.putI32(data, 52, 0)
  bio.putI32(data, 56, 1)
  return data
end function

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

  // Large statement tables used to grow with `array + [item]`.  This count
  // reproduces the scale implied by the 126104-byte array request observed
  // during retail-data validation, without distributing any Quake data.
  statementCount = 15760
  largeProgram = progs.parse(makeLargeSyntheticProgs(statementCount), "large-synthetic.dat")
  assertEqual(len(largeProgram.statements), statementCount, "linear progs statement allocation")
  return true
end function

function main(args)
  passed = 0
  print "MiniQuake core tests starting: 15"

  print "[01/15] CRC-CCITT"
  result = try(testCrc())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[02/15] byte I/O"
  result = try(testByteIo())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[03/15] Quake messages"
  result = try(testMessage())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[04/15] math"
  result = try(testMath())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[05/15] cvars"
  result = try(testCvar())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[06/15] PACK"
  result = try(testPack())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[07/15] WAD2"
  result = try(testWad())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[08/15] loopback network"
  result = try(testLoopback())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[09/15] memory lifetimes"
  result = try(testMemoryLifetimes())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[10/15] box hull"
  result = try(testBoxHull())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[11/15] BSP entities/PVS"
  result = try(testBspEntityAndPvs())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[12/15] WAV"
  result = try(testWave())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[13/15] DEM roundtrip"
  result = try(testDemoRoundtrip())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[14/15] protocol 15"
  result = try(testServerProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[15/15] QuakeC arithmetic"
  result = try(testQuakeCArithmetic())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "MiniQuake core tests passed: " + passed
  return 0
end function
