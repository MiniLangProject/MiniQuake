/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/zone_differential_fixture.ml.
*/
import miniquake.native as native
import miniquake.zone as zone
import miniquake.memory as memory

struct ZoneFixtureCommandLine
  args
end struct

// Return state derived from the active module state.
function state()
  return memory.Memory_Init(32768, 1024)
end function

// Exercise bool int as part of this deterministic regression fixture.
function boolInt(value)
  if value then return 1 end if
  return 0
end function

// Release or remove state for zone blocks.
function freeZoneBlocks(zoneState)
  count = 0
  for each block in zoneState.blocks
    if block.tag == 0 then count = count + 1 end if
  end for
  return count
end function

// Add zone to the destination state.
function emitZone(functionName, caseName, result, index, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"index\":" + index +
    ",\"value\":" + native.floatText(value) + ",\"count\":" + count + "}"
end function

// Return line count derived from the active module state.
function lineCount(text)
  data = bytes(text)
  if len(data) == 0 then return 0 end if
  count = 1
  for each item in data
    if item == 10 then count = count + 1 end if
  end for
  return count
end function

// Return fatal mode derived from the active module state.
function fatalMode(mode)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  manager = state()
  result = void
  if mode == "--error-z-free" then
    result = try(zone.Z_Free(void))
  else if mode == "--error-z-tag" then
    result = try(zone.Z_TagMalloc(manager.mainZone, 8, 0))
  else if mode == "--error-z-check" then
    manager.mainZone.blocks[0].start = manager.mainZone.blocks[0].start + 1
    result = try(zone.Z_CheckHeap(manager.mainZone))
  else if mode == "--error-hunk-check" then
    block = memory.Hunk_Alloc(manager, 16)
    block.sentinel = 0
    result = try(memory.Hunk_Check(manager))
  else if mode == "--error-hunk-alloc" then
    result = try(memory.Hunk_AllocName(manager, -1, "bad"))
  else if mode == "--error-low-mark" then
    result = try(memory.Hunk_FreeToLowMark(manager, manager.lowUsed + 1))
  else if mode == "--error-high-mark" then
    result = try(memory.Hunk_FreeToHighMark(manager, manager.highUsed + 1))
  else if mode == "--error-high-alloc" then
    result = try(memory.Hunk_HighAllocName(manager, -1, "bad"))
  else if mode == "--error-cache-unlink" then
    user = memory.cacheAlloc(manager, 16, "unlink")
    memory.Cache_UnlinkLRU(user.block)
    result = try(memory.Cache_UnlinkLRU(user.block))
  else if mode == "--error-cache-make" then
    user = memory.cacheAlloc(manager, 16, "active")
    result = try(memory.Cache_MakeLRU(user.block))
  else if mode == "--error-cache-try" then
    result = try(memory.Cache_TryAlloc(manager, manager.capacity, false))
  else if mode == "--error-cache-free" then
    user = memory.newCacheUser(manager)
    result = try(memory.Cache_Free(user))
  else if mode == "--error-cache-duplicate" then
    user = memory.newCacheUser(manager)
    memory.Cache_Alloc(manager, user, 16, "first")
    result = try(memory.Cache_Alloc(manager, user, 16, "second"))
  else if mode == "--error-cache-size" then
    user = memory.newCacheUser(manager)
    result = try(memory.Cache_Alloc(manager, user, 0, "zero"))
  else if mode == "--error-z-malloc" then
    result = try(zone.Z_Malloc(manager.mainZone, 2048))
  else if mode == "--error-hunk-overflow" then
    result = try(memory.Hunk_AllocName(manager, manager.capacity, "overflow"))
  else if mode == "--error-z-id" then
    block = zone.Z_TagMalloc(manager.mainZone, 8, 1)
    block.id = 0
    result = try(zone.Z_Free(block))
  else
    result = try(memory.memoryInitArguments(32768, ZoneFixtureCommandLine(["-zone"])))
  end if
  if result is error then return 42 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 then return fatalMode(args[0]) end if

  manager = state()
  zone.Z_ClearZone(manager.mainZone, 1024)
  emitZone("Z_ClearZone", "single_free", boolInt(freeZoneBlocks(manager.mainZone) == 1), len(manager.mainZone.blocks), 0.0, 1)

  manager = state()
  pointer = zone.Z_TagMalloc(manager.mainZone, 40, 2)
  zone.Z_Free(pointer)
  emitZone("Z_Free", "merge", boolInt(len(manager.mainZone.blocks) == 1), freeZoneBlocks(manager.mainZone), 0.0, 1)

  manager = state()
  pointer = zone.Z_Malloc(manager.mainZone, 17)
  emitZone("Z_Malloc", "zeroed", boolInt(pointer.data[0] == 0 and pointer.data[16] == 0), len(manager.mainZone.blocks), 17.0, freeZoneBlocks(manager.mainZone))

  manager = state()
  pointer = zone.Z_TagMalloc(manager.mainZone, 33, 7)
  emitZone("Z_TagMalloc", "tagged", boolInt(pointer is not void), len(manager.mainZone.blocks), 33.0, pointer.tag)

  manager = state()
  zone.Z_TagMalloc(manager.mainZone, 24, 3)
  text = zone.Z_Print(manager.mainZone)
  emitZone("Z_Print", "two_blocks", 1, len(manager.mainZone.blocks), 0.0, 3)

  manager = state()
  zone.Z_TagMalloc(manager.mainZone, 24, 3)
  checked = zone.Z_CheckHeap(manager.mainZone)
  emitZone("Z_CheckHeap", "consistent", boolInt(checked), len(manager.mainZone.blocks), 0.0, freeZoneBlocks(manager.mainZone))

  manager = state()
  memory.Hunk_AllocName(manager, 33, "check")
  checked = memory.Hunk_Check(manager)
  emitZone("Hunk_Check", "consistent", boolInt(checked), manager.lowUsed, 0.0, 1)

  manager = state()
  memory.Hunk_AllocName(manager, 17, "alpha")
  memory.Hunk_HighAllocName(manager, 19, "beta")
  text = memory.Hunk_Print(manager, true)
  emitZone("Hunk_Print", "both_sides", 1, manager.lowUsed, manager.highUsed, 10)

  manager = state()
  memory.Hunk_AllocName(manager, 17, "alpha")
  memory.Hunk_AllocName(manager, 1, "alpha")
  memory.Hunk_HighAllocName(manager, 19, "beta")
  text = memory.Hunk_Print(manager, false)
  emitZone("Hunk_Print", "grouped_names", 1, manager.lowUsed, manager.highUsed, lineCount(text))

  manager = state()
  before = manager.lowUsed
  pointer = memory.Hunk_AllocName(manager, 17, "abcdefghijk")
  emitZone("Hunk_AllocName", "aligned_named", boolInt(pointer is not void), manager.lowUsed - before, 17.0, boolInt(pointer.data[0] == 0))

  manager = state()
  before = manager.lowUsed
  pointer = memory.Hunk_Alloc(manager, 1)
  emitZone("Hunk_Alloc", "unknown", boolInt(pointer is not void), manager.lowUsed - before, 1.0, 1)

  manager = state()
  memory.Hunk_Alloc(manager, 20)
  mark = memory.Hunk_LowMark(manager)
  emitZone("Hunk_LowMark", "after_alloc", mark, mark, 0.0, 1)

  manager = state()
  mark = memory.Hunk_LowMark(manager)
  memory.Hunk_Alloc(manager, 20)
  memory.Hunk_FreeToLowMark(manager, mark)
  emitZone("Hunk_FreeToLowMark", "restore", boolInt(manager.lowUsed == mark), manager.lowUsed, 0.0, 1)

  manager = state()
  memory.Hunk_TempAlloc(manager, 20)
  mark = memory.Hunk_HighMark(manager)
  emitZone("Hunk_HighMark", "clears_temp", boolInt(not manager.tempActive), mark, manager.highUsed, 1)

  manager = state()
  mark = memory.Hunk_HighMark(manager)
  memory.Hunk_HighAllocName(manager, 20, "high")
  memory.Hunk_FreeToHighMark(manager, mark)
  emitZone("Hunk_FreeToHighMark", "restore", boolInt(manager.highUsed == mark), manager.highUsed, 0.0, 1)

  manager = state()
  before = manager.highUsed
  pointer = memory.Hunk_HighAllocName(manager, 17, "highname")
  emitZone("Hunk_HighAllocName", "aligned_named", boolInt(pointer is not void), manager.highUsed - before, 17.0, 1)

  manager = state()
  before = manager.highUsed
  pointer = memory.Hunk_TempAlloc(manager, 17)
  emitZone("Hunk_TempAlloc", "active", boolInt(pointer is not void), manager.highUsed - before, manager.tempMark, boolInt(manager.tempActive))

  manager = state()
  first = memory.cacheAlloc(manager, 64, "move")
  oldStart = first.block.start
  memory.Cache_Move(first.block)
  moved = first.block is not void and first.block.start != oldStart
  manager = state()
  first = memory.cacheAlloc(manager, memory.freeHunkBytes(manager) - memory.CACHE_HEADER_SIZE, "full")
  memory.Cache_Move(first.block)
  emitZone("Cache_Move", "relocate_or_release", boolInt(moved and first.block is void), 1, 64.0, len(manager.caches))

  manager = state()
  first = memory.cacheAlloc(manager, 64, "low")
  mark = manager.lowUsed + 16
  memory.Cache_FreeLow(manager, mark)
  result = first.block is void
  if first.block is not void then result = first.block.start >= mark end if
  emitZone("Cache_FreeLow", "make_room", boolInt(result), len(manager.caches), 64.0, boolInt(first.block is not void))

  manager = state()
  first = memory.cacheAlloc(manager, 256, "high")
  mark = manager.capacity - manager.lowUsed - 64
  memory.Cache_FreeHigh(manager, mark)
  result = first.block is void
  if first.block is not void then result = first.block.start + first.block.span <= manager.capacity - mark end if
  emitZone("Cache_FreeHigh", "make_room", boolInt(result), len(manager.caches), 256.0, boolInt(first.block is not void))

  manager = state()
  first = memory.cacheAlloc(manager, 16, "unlink")
  block = first.block
  memory.Cache_UnlinkLRU(block)
  emitZone("Cache_UnlinkLRU", "detach", boolInt(block.lruStamp == 0), len(manager.caches), 0.0, 1)
  memory.Cache_MakeLRU(block)
  emitZone("Cache_MakeLRU", "attach", boolInt(block.lruStamp != 0), len(manager.caches), 0.0, 1)

  manager = state()
  tried = memory.Cache_TryAlloc(manager, 128, false)
  emitZone("Cache_TryAlloc", "empty_bottom", boolInt(tried is not void), tried.start, 128.0, len(manager.caches))

  manager = state()
  first = memory.cacheAlloc(manager, 16, "first")
  second = memory.cacheAlloc(manager, 16, "second")
  memory.Cache_Flush(manager)
  emitZone("Cache_Flush", "all", boolInt(first.block is void and second.block is void), len(manager.caches), 0.0, 2)

  manager = state()
  first = memory.cacheAlloc(manager, 16, "print")
  text = memory.Cache_Print(manager)
  emitZone("Cache_Print", "one", 1, len(manager.caches), 0.0, 1)

  manager = state()
  report = memory.Cache_Report(manager)
  emitZone("Cache_Report", "free_megabytes", 1, manager.capacity - manager.lowUsed - manager.highUsed, 0.0, 1)

  manager = state()
  memory.Cache_Compact(manager)
  emitZone("Cache_Compact", "noop", 1, len(manager.caches), 0.0, 0)

  manager = state()
  memory.Cache_Init(manager)
  emitZone("Cache_Init", "sentinels", boolInt(len(manager.caches) == 0), len(manager.caches), 0.0, 1)

  manager = state()
  first = memory.cacheAlloc(manager, 16, "free")
  memory.Cache_Free(first)
  emitZone("Cache_Free", "release", boolInt(first.block is void), len(manager.caches), 0.0, 1)

  manager = state()
  first = memory.cacheAlloc(manager, 16, "check")
  second = memory.cacheAlloc(manager, 16, "other")
  data = memory.Cache_Check(manager, first)
  emitZone("Cache_Check", "touch_lru", boolInt(data is not void and first.block is not void and first.block.lruStamp > second.block.lruStamp), len(manager.caches), 16.0, 2)

  manager = state()
  first = memory.newCacheUser(manager)
  data = memory.Cache_Alloc(manager, first, 33, "allocate")
  emitZone("Cache_Alloc", "new", boolInt(data is not void and first.block is not void), len(manager.caches), 33.0, 1)

  manager = memory.Memory_Init(32768, 1024)
  emitZone("Memory_Init", "zone_override", boolInt(manager.mainZone is not void), manager.lowUsed, manager.capacity, 1)
  return 0
end function
