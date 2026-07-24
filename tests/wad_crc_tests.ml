/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Focused WinQuake/wad.c+wad.h and crc.c+crc.h behavioral fixtures.
*/

import miniquake.wad as wad
import miniquake.crc as crc
import miniquake.byteio as bio
import miniquake.filesystem as qfs
import std.fs as fs

function assertEqual(actual, expected, name)
  if actual != expected then return error(9700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function assertTrue(value, name)
  if value != true then return error(9701, name + ": expected true") end if
  return true
end function

function assertBytes(actual, expected, name)
  assertEqual(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    assertEqual(actual[index], expected[index], name + " byte " + index)
    index = index + 1
  end while
  return true
end function

function putName(data, offset, name)
  source = bytes(name)
  count = len(source)
  if count > 16 then count = 16 end if
  bio.copyInto(data, offset, source, 0, count)
end function

function makeSyntheticWad()
  // Header (12), qpic (8), compressed raw lump (3), directory (2 * 32).
  data = bytes(87)
  bio.copyInto(data, 0, bytes("WAD2"), 0, 4)
  bio.putI32(data, 4, 2)
  bio.putI32(data, 8, 23)

  bio.putI32(data, 12, 320)
  bio.putI32(data, 16, 200)
  data[20] = 0xde
  data[21] = 0xad
  data[22] = 0xbe

  bio.putI32(data, 23, 12)
  bio.putI32(data, 27, 8)
  bio.putI32(data, 31, 8)
  data[35] = wad.TYP_QPIC
  data[36] = wad.CMP_NONE
  putName(data, 39, "ABCDEFGHIJKLMNOP")

  bio.putI32(data, 55, 20)
  bio.putI32(data, 59, 3)
  bio.putI32(data, 63, 3)
  data[67] = wad.TYP_LUMPY
  data[68] = wad.CMP_LZSS
  putName(data, 71, "MixedCase")
  return data
end function

function testCleanupName()
  clean = wad.W_CleanupName("ABCdef")
  assertEqual(len(clean), 16, "W_CleanupName fixed length")
  assertBytes(slice(clean, 0, 6), bytes("abcdef"), "W_CleanupName lowercase")
  index = 6
  while index < 16
    assertEqual(clean[index], 0, "W_CleanupName NUL padding")
    index = index + 1
  end while

  exact = wad.W_CleanupName("ABCDEFGHIJKLMNOP")
  assertBytes(exact, bytes("abcdefghijklmnop"), "W_CleanupName exact 16")
  truncated = wad.W_CleanupName("ABCDEFGHIJKLMNOP-extra")
  assertBytes(truncated, exact, "W_CleanupName truncation")

  embedded = wad.W_CleanupName(bytes([65, 66, 0, 90]))
  assertEqual(embedded[0], 97, "W_CleanupName embedded first")
  assertEqual(embedded[1], 98, "W_CleanupName embedded second")
  assertEqual(embedded[2], 0, "W_CleanupName embedded stop")
  assertEqual(embedded[3], 0, "W_CleanupName embedded pad")
  return true
end function

function testWadLookupAndPictures()
  data = makeSyntheticWad()
  archive = wad.W_LoadWadData(data, "synthetic.wad")
  assertEqual(archive.numLumps, 2, "W_LoadWadData count")
  assertEqual(archive.lumps[0].name, "abcdefghijklmnop", "directory exact name cleanup")
  assertEqual(archive.lumps[1].name, "mixedcase", "directory lowercase cleanup")

  // Both lookup input and directory names use the same 16-byte cleanup.
  lump = wad.W_GetLumpinfo(archive, "ABCDEFGHIJKLMNOP-tail-is-ignored")
  assertEqual(lump.filePosition, 12, "W_GetLumpinfo truncated lookup")
  dimensions = wad.SwapPic(archive.data, lump.filePosition)
  assertEqual(dimensions[0], 320, "SwapPic width")
  assertEqual(dimensions[1], 200, "SwapPic height")
  assertEqual(wad.pictureDimensions(archive, "abcdefghijklmnop")[0], 320, "pictureDimensions")

  assertEqual(len(wad.W_GetLumpName(archive, "MIXEDCASE")), 3, "W_GetLumpName byte range")
  assertBytes(wad.W_GetLumpNum(archive, 1), bytes([0xde, 0xad, 0xbe]), "W_GetLumpNum")
  // W_GetLumpName mirrors the C pointer lookup; decompression policy belongs
  // to the higher-level readLump compatibility helper.
  assertBytes(wad.W_GetLumpName(archive, "mixedcase"), bytes([0xde, 0xad, 0xbe]), "compressed pointer lookup")
  assertTrue(try(wad.readLump(archive, "mixedcase")) is error, "readLump rejects LZSS")
  assertTrue(try(wad.W_GetLumpinfo(archive, "missing")) is error, "missing lump")
  assertTrue(try(wad.W_GetLumpNum(archive, -1)) is error, "negative lump number")
  assertTrue(try(wad.W_GetLumpNum(archive, 2)) is error, "one-past lump number")

  fixturePath = "build\\wad_crc_fixture.wad"
  fs.writeAllBytes(fixturePath, data)
  fileArchive = wad.W_LoadWadFile(fixturePath)
  assertEqual(fileArchive.numLumps, 2, "W_LoadWadFile")
  fs.delete(fixturePath)
  return true
end function

function testWadBounds()
  badMagic = makeSyntheticWad()
  badMagic[0] = 88
  assertTrue(try(wad.parse(badMagic, "bad-magic.wad")) is error, "WAD2 identity")

  badDirectory = makeSyntheticWad()
  bio.putI32(badDirectory, 8, 80)
  assertTrue(try(wad.parse(badDirectory, "bad-directory.wad")) is error, "directory bounds")

  badLump = makeSyntheticWad()
  bio.putI32(badLump, 23, 86)
  assertTrue(try(wad.parse(badLump, "bad-lump.wad")) is error, "lump bounds")

  shortPicture = makeSyntheticWad()
  bio.putI32(shortPicture, 27, 4)
  bio.putI32(shortPicture, 31, 4)
  assertTrue(try(wad.parse(shortPicture, "short-qpic.wad")) is error, "qpic bounds")
  assertTrue(try(wad.SwapPic(bytes(7), 0)) is error, "SwapPic direct bounds")
  return true
end function

function testCrc()
  assertEqual(crc.CRC_Init(), 0xffff, "CRC_Init")
  value = crc.CRC_Init()
  value = crc.CRC_ProcessByte(value, 0x31)
  assertEqual(value, 0xc782, "CRC_ProcessByte first")
  value = crc.CRC_ProcessByte(value, 0x32)
  assertEqual(value, 0x3dba, "CRC_ProcessByte second")
  assertEqual(crc.CRC_Value(value), 0x3dba, "CRC_Value")
  assertEqual(crc.CRC_ProcessByte(0xffff, 0x131), 0xc782, "CRC byte narrowing")
  assertEqual(crc.CRC_Block(bytes("123456789"), 0, 9), 0x29b1, "CRC_Block check vector")
  assertEqual(crc.block(bytes("x234y"), 1, 3), 0x4148, "CRC subrange")
  assertEqual(crc.CRC_Block(bytes(), 0, 0), 0xffff, "CRC empty")
  assertTrue(try(crc.CRC_Block(bytes(2), 1, 2)) is error, "CRC range")
  return true
end function

function testRetailGfxWad(baseDirectory)
  system = qfs.create(baseDirectory, "id1")
  qfs.addGameDirectory(system, qfs.join(baseDirectory, "id1"))
  data = qfs.readFile(system, "gfx.wad")
  assertEqual(len(data), 112828, "retail gfx.wad length")
  assertEqual(crc.CRC_Block(data, 0, len(data)), 0x3549, "retail gfx.wad CRC")
  archive = wad.W_LoadWadData(data, "gfx.wad")
  assertEqual(archive.numLumps, 163, "retail gfx.wad count")
  assertEqual(len(wad.readLump(archive, "CONCHARS")), 16384, "retail conchars")
  assertEqual(wad.pictureDimensions(archive, "backtile")[0], 64, "retail backtile width")
  assertEqual(wad.pictureDimensions(archive, "BACKTILE")[1], 64, "retail backtile height")
  assertEqual(wad.pictureDimensions(archive, "disc")[0], 24, "retail disc width")
  return true
end function

function main(args)
  print "[1/5] W_CleanupName"
  result = try(testCleanupName())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[2/5] WAD lookup/qpic"
  result = try(testWadLookupAndPictures())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[3/5] WAD bounds"
  result = try(testWadBounds())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[4/5] CRC"
  result = try(testCrc())
  if result is error then print "FAIL: " + result.message; return 1 end if
  if len(args) > 0 then
    print "[5/5] retail gfx.wad"
    result = try(testRetailGfxWad(args[0]))
    if result is error then print "FAIL: " + result.message; return 1 end if
  else
    print "[5/5] retail gfx.wad skipped (pass Quake basedir)"
  end if
  print "MiniQuake WAD/CRC compatibility tests passed: 5"
  return 0
end function
