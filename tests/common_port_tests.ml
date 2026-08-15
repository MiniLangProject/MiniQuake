/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused MiniQuake common.c/common.h compatibility tests.
*/
import miniquake.types as t
import miniquake.common as common
import miniquake.byteio as bio
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.pak as pak
import miniquake.filesystem as qfs
import miniquake.memory as memory
import std.fs as fs

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9200, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9201, name + ": expected true") end if
  return true
end function

// Return registered bytes derived from the active module state.
function registeredBytes()
  words = qfs.registeredWords()
  data = bytes(len(words) * 2)
  index = 0
  while index < len(words)
    data[index * 2] = (words[index] >> 8) & 255
    data[index * 2 + 1] = words[index] & 255
    index = index + 1
  end while
  return data
end function

// Exercise pack system as part of this deterministic regression fixture.
function packSystem(files, data)
  archive = t.PackArchive("fixture.pak", data, files, len(files))
  return t.FileSystem("", "id1", [t.SearchPath("", archive)], "", true, false, true, false)
end function

// Return registered pack bytes derived from the active module state.
function registeredPackBytes()
  pop = registeredBytes()
  progs = bytes("base")
  directoryOffset = 12 + len(pop) + len(progs)
  data = bytes(directoryOffset + 128)
  data[0] = 80
  data[1] = 65
  data[2] = 67
  data[3] = 75
  bio.putI32(data, 4, directoryOffset)
  bio.putI32(data, 8, 128)
  bio.copyInto(data, 12, pop, 0, len(pop))
  bio.copyInto(data, 12 + len(pop), progs, 0, len(progs))

  popName = bytes("gfx/pop.lmp")
  bio.copyInto(data, directoryOffset, popName, 0, len(popName))
  bio.putI32(data, directoryOffset + 56, 12)
  bio.putI32(data, directoryOffset + 60, len(pop))

  progsEntry = directoryOffset + 64
  progsName = bytes("progs.dat")
  bio.copyInto(data, progsEntry, progsName, 0, len(progsName))
  bio.putI32(data, progsEntry + 56, 12 + len(pop))
  bio.putI32(data, progsEntry + 60, len(progs))
  return data
end function

// Verify links and formatting against the expected Quake behavior.
function testLinksAndFormatting()
  head = t.Link(void, void)
  common.clearLink(head)
  first = t.Link(void, void)
  common.clearLink(first)
  second = t.Link(void, void)
  common.clearLink(second)
  common.insertLinkAfter(first, head)
  common.insertLinkBefore(second, head)
  assertEqual(head.next, first, "InsertLinkAfter")
  assertEqual(head.previous, second, "InsertLinkBefore")
  common.removeLink(first)
  assertEqual(head.next, second, "RemoveLink next")
  assertEqual(second.previous, head, "RemoveLink previous")

  assertEqual(common.va("map %s", ["e1m1"]), "map e1m1", "va string")
  assertEqual(common.va("color %i %u", [13, 4]), "color 13 4", "va integers")
  assertEqual(common.va("%c %x %%", [65, 255]), "A ff %", "va character/hex/percent")
  assertEqual(common.va("%f", [1.25]), "1.250000", "va float")
  assertEqual(common.stringConcat("Mini", "Quake"), "MiniQuake", "Q_strcat")
  assertEqual(common.stringCopy("quake"), "quake", "Q_strcpy")
  assertEqual(common.stringCopyCount("quake", 3), "qua", "Q_strncpy")
  assertEqual(common.stringLength("quake"), 5, "Q_strlen")
  assertEqual(common.stringLastIndex("a/b/c", 47), 3, "Q_strrchr adapter")
  return true
end function

// Verify registered and search against the expected Quake behavior.
function testRegisteredAndSearch()
  pop = registeredBytes()
  system = packSystem([t.PackFile("gfx/pop.lmp", 0, len(pop))], pop)
  assertEqual(qfs.checkRegistered(system), true, "COM_CheckRegistered")
  assertEqual(system.registered, true, "registered state")
  assertEqual(system.staticRegistered, true, "registered search permission")

  corrupt = bytes(len(pop))
  bio.copyInto(corrupt, 0, pop, 0, len(pop))
  corrupt[20] = corrupt[20] ^ 1
  corruptSystem = packSystem([t.PackFile("gfx/pop.lmp", 0, len(corrupt))], corrupt)
  bad = try(qfs.checkRegistered(corruptSystem))
  assertTrue(bad is error, "corrupt pop.lmp rejected")

  shareware = t.FileSystem("", "id1", [], "", false, false, true, false)
  assertEqual(qfs.checkRegistered(shareware), false, "shareware accepted without modification")
  assertEqual(shareware.staticRegistered, false, "shareware directory restriction")
  modified = t.FileSystem("", "mod", [], "", true, false, true, false)
  missing = try(qfs.checkRegistered(modified))
  assertTrue(missing is error, "modified shareware rejected")

  combined = bytes([79, 66])
  override = t.PackArchive("override.pak", combined, [t.PackFile("progs.dat", 0, 1)], 1)
  base = t.PackArchive("base.pak", combined, [t.PackFile("progs.dat", 1, 1)], 1)
  proghack = t.FileSystem(
    "",
    "id1",
    [t.SearchPath("", override), t.SearchPath("", base)],
    "",
    false,
    true,
    true,
    true,
  )
  assertEqual(decode(qfs.readFile(proghack, "progs.dat")), "B", "-proghack skips first path")
  assertTrue(len(bytes(qfs.pathCommandText(proghack))) > 20, "COM_Path_f text")
  return true
end function

// Verify handles and lifetimes against the expected Quake behavior.
function testHandlesAndLifetimes()
  source = bytes("hello")
  system = packSystem([t.PackFile("test.bin", 0, len(source))], source)
  system.registered = true
  system.staticRegistered = true

  opened = qfs.openFile(system, "test.bin")
  assertEqual(opened[0], 5, "COM_OpenFile length")
  handle = opened[1]
  assertEqual(decode(qfs.handleRead(handle, 2)), "he", "handle read")
  qfs.handleSeek(handle, 1)
  assertEqual(decode(qfs.handleRead(handle, 2)), "el", "handle seek")
  qfs.closeFile(handle)
  assertEqual(decode(qfs.handleRead(handle, 2)), "lo", "PACK handle remains open")

  stream = qfs.fOpenFile(system, "test.bin")[1]
  qfs.closeFile(stream)
  closed = try(qfs.handleRead(stream, 1))
  assertTrue(closed is error, "FOpen stream closes")

  state = memory.create(128)
  hunk = qfs.loadHunkAllocation(system, state, "test.bin")
  temp = qfs.loadTempAllocation(system, state, "test.bin")
  zone = qfs.loadZoneAllocation(system, state, "test.bin")
  cache = qfs.loadCacheAllocation(system, state, "test.bin")
  assertEqual(hunk.kind, "hunk", "COM_LoadHunkFile lifetime")
  assertEqual(temp.kind, "temp", "COM_LoadTempFile lifetime")
  assertEqual(zone.kind, "zone", "COM_LoadFile zone lifetime")
  assertEqual(cache.block.kind, "cache", "COM_LoadCacheFile lifetime")
  assertEqual(hunk.data[5], 0, "load allocation terminator")
  stack = qfs.loadStackAllocation(system, state, "test.bin", bytes(6))
  assertEqual(stack[1], void, "COM_LoadStackFile uses fitting stack")
  fallback = qfs.loadStackAllocation(system, state, "test.bin", bytes(2))
  assertEqual(fallback[1].kind, "temp", "COM_LoadStackFile temp fallback")
  assertEqual(temp.alive, false, "Hunk_TempAlloc invalidates previous temporary")
  return true
end function

// Verify filesystem initialization against the expected Quake behavior.
function testFilesystemInitialization()
  packPath = "build\\common_path_test.pak"
  fs.writeAllBytes(packPath, registeredPackBytes())
  arguments = common.create(["-path", packPath, packPath, "-proghack", "-cachedir", "-"])
  system = qfs.initFilesystem(".", arguments)
  assertEqual(len(system.searchPaths), 2, "COM_InitFilesystem -path")
  assertEqual(system.progsHack, true, "COM_InitFilesystem -proghack")
  assertEqual(system.cacheDirectory, "", "COM_InitFilesystem disables cache")
  assertEqual(system.registered, true, "COM_InitFilesystem registration")
  assertEqual(decode(qfs.readFile(system, "progs.dat")), "base", "COM_LoadPackFile search")

  cached = qfs.initFilesystem(".", common.create(["-cachedir", "build"]))
  assertEqual(cached.cacheDirectory, "build", "COM_InitFilesystem -cachedir")

  sourcePath = "build\\common_copy_source.tmp"
  destinationPath = "build\\common_copy_destination.tmp"
  fs.writeAllBytes(sourcePath, bytes("copy"))
  assertEqual(qfs.copyFile(sourcePath, destinationPath), true, "COM_CopyFile")
  assertEqual(decode(fs.readAllBytes(destinationPath)), "copy", "COM_CopyFile contents")

  writable = t.FileSystem(".", "build", [], "", false, false, true, false)
  assertEqual(qfs.writeFile(writable, "common_write.tmp", bytes("write")), true, "COM_WriteFile")
  assertEqual(decode(fs.readAllBytes("build\\common_write.tmp")), "write", "COM_WriteFile contents")

  fs.delete(packPath)
  fs.delete(sourcePath)
  fs.delete(destinationPath)
  fs.delete("build\\common_write.tmp")
  return true
end function

// Verify message and size buffer against the expected Quake behavior.
function testMessageAndSizeBuffer()
  buffer = sz.alloc(16)
  msg.writeAngle(buffer, 1.9)
  msg.writeAngle(buffer, 180.0)
  reader = msg.beginReading(buffer)
  assertEqual(msg.readAngle(reader), 0.0, "MSG_WriteAngle cast order")
  assertEqual(msg.readAngle(reader), -180.0, "MSG_ReadAngle signed byte")
  badReader = msg.beginReadingBytes(bytes([1]))
  assertEqual(msg.readLong(badReader), -1, "MSG overflow sentinel")
  assertEqual(badReader.badRead, true, "MSG badread")

  overflowing = sz.allocOverflowing(2)
  sz.writeBytes(overflowing, bytes([1, 2]))
  sz.writeBytes(overflowing, bytes([3]))
  sz.clear(overflowing)
  assertEqual(overflowing.overflowed, true, "SZ_Clear retains overflowed")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  result = try(testLinksAndFormatting())
  if result is error then print "FAIL: " + result.message; return 1 end if
  result = try(testRegisteredAndSearch())
  if result is error then print "FAIL: " + result.message; return 1 end if
  result = try(testHandlesAndLifetimes())
  if result is error then print "FAIL: " + result.message; return 1 end if
  result = try(testMessageAndSizeBuffer())
  if result is error then print "FAIL: " + result.message; return 1 end if
  result = try(testFilesystemInitialization())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "MiniQuake common compatibility tests passed: 5"
  return 0
end function
