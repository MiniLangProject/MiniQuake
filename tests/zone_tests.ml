/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Focused zone.c/zone.h behavioral tests.
*/
import miniquake.zone as zone
import miniquake.memory as memory

// Group the deterministic test command line fields used by this test fixture.
struct TestCommandLine
  args
end struct

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9300, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9301, name + ": expected true") end if
  return true
end function

// Verify zone allocator against the expected Quake behavior.
function testZoneAllocator()
  state = zone.create(512)
  initialFree = zone.Z_FreeMemory(state)
  assertEqual(initialFree, 480, "Z_ClearZone free span")
  zeroTag = try(zone.Z_TagMalloc(state, 8, 0))
  assertTrue(zeroTag is error, "Z_TagMalloc rejects tag zero")

  first = zone.Z_TagMalloc(state, 40, 7)
  second = zone.Z_Malloc(state, 32)
  assertEqual(first.tag, 7, "Z_TagMalloc tag")
  assertEqual(second.tag, 1, "Z_Malloc tag")
  assertEqual(first.start % 8, 0, "zone block alignment")
  assertEqual(zone.Z_CheckHeap(state), true, "Z_CheckHeap allocated")
  assertTrue(len(bytes(zone.Z_Print(state))) > 20, "Z_Print")
  assertEqual(zone.Z_DumpHeap(state), zone.Z_Print(state), "Z_DumpHeap")

  zone.Z_Free(first)
  assertEqual(zone.Z_CheckHeap(state), true, "Z_Free previous merge check")
  zone.Z_Free(second)
  assertEqual(len(state.blocks), 1, "Z_Free coalesces both neighbors")
  assertEqual(zone.Z_FreeMemory(state), initialFree, "Z_FreeMemory restored")
  doubleFree = try(zone.Z_Free(second))
  assertTrue(doubleFree is error, "Z_Free rejects double free")
  nullFree = try(zone.Z_Free(void))
  assertTrue(nullFree is error, "Z_Free rejects NULL")
  return true
end function

// Verify hunk allocator against the expected Quake behavior.
function testHunkAllocator()
  state = memory.create(1024)
  low = memory.Hunk_LowMark(state)
  first = memory.Hunk_AllocName(state, 1, "123456789")
  assertEqual(first.name, "12345678", "Hunk name is eight bytes")
  assertEqual(memory.Hunk_LowMark(state), low + 32, "Hunk_AllocName header/alignment")
  unknown = memory.Hunk_Alloc(state, 16)
  assertEqual(unknown.name, "unknown", "Hunk_Alloc default name")
  assertEqual(memory.Hunk_Check(state), true, "Hunk_Check")
  assertTrue(len(bytes(memory.Hunk_Print(state, true))) > 20, "Hunk_Print")

  high = memory.Hunk_HighAllocName(state, 1, "video")
  highBase = memory.Hunk_HighMark(state)
  assertEqual(highBase, 32, "Hunk_HighAllocName alignment")
  tempOne = memory.Hunk_TempAlloc(state, 17)
  assertEqual(state.highUsed, highBase + 48, "Hunk_TempAlloc high usage")
  tempTwo = memory.Hunk_TempAlloc(state, 17)
  assertEqual(tempOne.alive, false, "next temp invalidates previous")
  assertEqual(state.highUsed, highBase + 48, "temp allocation reuses mark")
  assertEqual(memory.Hunk_HighMark(state), highBase, "Hunk_HighMark clears temp")
  assertEqual(tempTwo.alive, false, "Hunk_HighMark invalidates temp")

  memory.Hunk_FreeToLowMark(state, low)
  assertEqual(first.alive, false, "Hunk_FreeToLowMark")
  assertEqual(unknown.alive, false, "Hunk_FreeToLowMark all later blocks")
  memory.Hunk_FreeToHighMark(state, 0)
  assertEqual(high.alive, false, "Hunk_FreeToHighMark")
  badLow = try(memory.Hunk_FreeToLowMark(state, 1))
  assertTrue(badLow is error, "Hunk_FreeToLowMark validates mark")
  badHigh = try(memory.Hunk_FreeToHighMark(state, 1))
  assertTrue(badHigh is error, "Hunk_FreeToHighMark validates mark")

  tiny = memory.create(32)
  assertEqual(memory.Hunk_HighAllocName(tiny, 17, "fail"), void, "Hunk_HighAllocName nonfatal failure")
  lowFailure = try(memory.Hunk_AllocName(tiny, 17, "fail"))
  assertTrue(lowFailure is error, "Hunk_AllocName fatal failure")
  return true
end function

// Verify cache lru and purge against the expected Quake behavior.
function testCacheLruAndPurge()
  state = memory.create(512)
  first = memory.cacheAlloc(state, 64, "first")
  second = memory.cacheAlloc(state, 64, "second")
  third = memory.cacheAlloc(state, 64, "third")
  assertEqual(first.block.start, 0, "Cache_TryAlloc bottom")
  assertEqual(second.block.start, 112, "Cache_TryAlloc second")
  assertEqual(third.block.start, 224, "Cache_TryAlloc third")
  memory.Cache_UnlinkLRU(first.block)
  duplicateUnlink = try(memory.Cache_UnlinkLRU(first.block))
  assertTrue(duplicateUnlink is error, "Cache_UnlinkLRU validates active link")
  memory.Cache_MakeLRU(first.block)
  duplicateMake = try(memory.Cache_MakeLRU(first.block))
  assertTrue(duplicateMake is error, "Cache_MakeLRU validates inactive link")
  memory.Cache_Check(state, first)
  large = memory.cacheAlloc(state, 200, "large")
  assertTrue(first.block is not void, "Cache_Check protects MRU")
  assertEqual(second.block, void, "Cache_Alloc purges oldest")
  assertEqual(third.block, void, "Cache_Alloc purges until contiguous space")
  assertEqual(large.block.start, 112, "Cache_Alloc reuses purged gap")

  duplicate = try(memory.cacheAllocUser(state, first, 8, "duplicate"))
  assertTrue(duplicate is error, "Cache_Alloc rejects allocated user")
  assertTrue(len(bytes(memory.Cache_Print(state))) > 10, "Cache_Print")
  assertTrue(memory.Cache_Report(state) > 0.0, "Cache_Report")
  assertEqual(memory.Cache_Compact(state), true, "Cache_Compact")
  memory.Cache_Flush(state)
  assertEqual(len(state.caches), 0, "Cache_Flush")
  assertEqual(first.block, void, "Cache_Flush clears users")
  assertEqual(large.block, void, "Cache_Flush clears all users")
  return true
end function

// Verify cache hunk collision against the expected Quake behavior.
function testCacheHunkCollision()
  state = memory.create(512)
  first = memory.cacheAlloc(state, 64, "first")
  second = memory.cacheAlloc(state, 64, "second")
  probe = memory.create(512)
  memory.cacheAlloc(probe, 64, "first")
  memory.cacheAlloc(probe, 64, "second")
  tried = memory.Cache_TryAlloc(probe, 32, false)
  assertEqual(tried.start, 224, "Cache_TryAlloc explicit gap")
  assertEqual(len(probe.caches), 3, "Cache_TryAlloc links cache header")
  originalStart = first.block.start
  memory.Cache_Move(first.block)
  assertTrue(first.block.start > originalStart, "Cache_Move relocates bottom block")
  memory.Cache_Move(first.block)
  // Put the cache back into a deterministic bottom-first layout for the
  // collision checks.
  memory.Cache_Flush(state)
  first = memory.cacheAlloc(state, 64, "first")
  second = memory.cacheAlloc(state, 64, "second")
  memory.hunkAllocName(state, 32, "low")
  assertEqual(first.block.start, 224, "Cache_FreeLow moves bottom block")
  assertEqual(second.block.start, 112, "Cache_FreeLow preserves noncolliding block")

  high = memory.hunkHighAllocName(state, 160, "high")
  assertTrue(high is not void, "high hunk allocation")
  for each block in state.caches
    assertTrue(block.start + block.span <= state.capacity - state.highUsed, "Cache_FreeHigh clears collision")
  end for
  return true
end function

// Verify memory init and zone wrappers against the expected Quake behavior.
function testMemoryInitAndZoneWrappers()
  state = memory.Memory_Init(4096, 1024)
  assertEqual(memory.lowMark(state), 1040, "Memory_Init reserves zone on low hunk")
  assertEqual(state.mainZone.capacity, 1024, "Memory_Init zone size")
  tagged = memory.zoneTagMalloc(state, 24, 5, "tagged")
  zeroed = memory.zoneMalloc(state, 24, "malloc")
  assertEqual(tagged.tag, 5, "Z_TagMalloc wrapper")
  assertEqual(zeroed.data[0], 0, "Z_Malloc zero filled")
  assertEqual(memory.zoneCheck(state), true, "Z_CheckHeap wrapper")
  assertTrue(memory.zoneFreeMemory(state) > 0, "Z_FreeMemory wrapper")
  assertTrue(len(bytes(memory.zonePrint(state))) > 10, "Z_Print wrapper")
  memory.zoneFree(tagged)
  memory.zoneFree(zeroed)
  assertEqual(memory.zoneCheck(state), true, "zone wrapper coalescing")

  argumentState = memory.memoryInitArguments(8192, TestCommandLine(["-zone", "2"]))
  assertEqual(argumentState.mainZone.capacity, 2048, "Memory_Init -zone kilobytes")
  missingZone = try(memory.memoryInitArguments(8192, TestCommandLine(["-zone"])))
  assertTrue(missingZone is error, "Memory_Init requires -zone value")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  print "[1/5] zone allocator"
  result = try(testZoneAllocator())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[2/5] hunk allocator"
  result = try(testHunkAllocator())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[3/5] cache LRU/purge"
  result = try(testCacheLruAndPurge())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[4/5] cache/hunk collision"
  result = try(testCacheHunkCollision())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "[5/5] Memory_Init/zone wrappers"
  result = try(testMemoryInitAndZoneWrappers())
  if result is error then print "FAIL: " + result.message; return 1 end if
  print "MiniQuake zone compatibility tests passed: 5"
  return 0
end function
