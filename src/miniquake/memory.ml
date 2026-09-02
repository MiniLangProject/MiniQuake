/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.memory.
*/
package miniquake.memory

import miniquake.zone as zone
import miniquake.protocol_text as quakeText

/// Defines the hunk sentinel value used by `miniquake.memory`.
const HUNK_SENTINEL = 0x1df001ed
/// Defines the hunk header size value used by `miniquake.memory`.
const HUNK_HEADER_SIZE = 16
/// Defines the cache header size value used by `miniquake.memory`.
const CACHE_HEADER_SIZE = 40

// Group the fields that describe one hunk block.
struct HunkBlock
  /// Stores the kind value in `miniquake.memory.HunkBlock`.
  kind
  /// Stores the name value in `miniquake.memory.HunkBlock`.
  name
  /// Stores the data value in `miniquake.memory.HunkBlock`.
  data
  /// Stores the size value in `miniquake.memory.HunkBlock`.
  size
  /// Stores the alive value in `miniquake.memory.HunkBlock`.
  alive
  /// Stores the allocation index value in `miniquake.memory.HunkBlock`.
  allocationIndex
  /// Stores the side value in `miniquake.memory.HunkBlock`.
  side
  /// Stores the start value in `miniquake.memory.HunkBlock`.
  start
  /// Stores the span value in `miniquake.memory.HunkBlock`.
  span
  /// Stores the sentinel value in `miniquake.memory.HunkBlock`.
  sentinel
end struct

// Group the fields that describe one cache block.
struct CacheBlock
  /// Stores the kind value in `miniquake.memory.CacheBlock`.
  kind
  /// Stores the name value in `miniquake.memory.CacheBlock`.
  name
  /// Stores the data value in `miniquake.memory.CacheBlock`.
  data
  /// Stores the size value in `miniquake.memory.CacheBlock`.
  size
  /// Stores the alive value in `miniquake.memory.CacheBlock`.
  alive
  /// Stores the allocation index value in `miniquake.memory.CacheBlock`.
  allocationIndex
  /// Stores the start value in `miniquake.memory.CacheBlock`.
  start
  /// Stores the span value in `miniquake.memory.CacheBlock`.
  span
  /// Stores the lru stamp value in `miniquake.memory.CacheBlock`.
  lruStamp
  /// Stores the owner value in `miniquake.memory.CacheBlock`.
  owner
  /// Stores the user value in `miniquake.memory.CacheBlock`.
  user
end struct

// Group the fields that describe one cache user.
struct CacheUser
  /// Stores the block value in `miniquake.memory.CacheUser`.
  block
  /// Stores the manager value in `miniquake.memory.CacheUser`.
  manager
end struct

// Own the coordinated data required by the memory manager.
struct MemoryManager
  /// Stores the capacity value in `miniquake.memory.MemoryManager`.
  capacity
  /// Stores the blocks value in `miniquake.memory.MemoryManager`.
  blocks
  /// Stores the total allocated value in `miniquake.memory.MemoryManager`.
  totalAllocated
  /// Stores the low used value in `miniquake.memory.MemoryManager`.
  lowUsed
  /// Stores the high used value in `miniquake.memory.MemoryManager`.
  highUsed
  /// Stores the temp active value in `miniquake.memory.MemoryManager`.
  tempActive
  /// Stores the temp mark value in `miniquake.memory.MemoryManager`.
  tempMark
  /// Stores the caches value in `miniquake.memory.MemoryManager`.
  caches
  /// Stores the lru clock value in `miniquake.memory.MemoryManager`.
  lruClock
  /// Stores the next allocation index value in `miniquake.memory.MemoryManager`.
  nextAllocationIndex
  /// Stores the main zone value in `miniquake.memory.MemoryManager`.
  mainZone
  /// Stores the zone backing value in `miniquake.memory.MemoryManager`.
  zoneBacking
end struct

/// Implements the `align16` operation for `miniquake.memory` (align16).
/// @param value Value consumed by `align16`.
function inline align16(value)
  return (value + 15) & ~15
end function

/// Return truncate name derived from the active module state.
/// @param name Stable name that identifies the requested object or option.
/// @param count Number of entries or units to process.
function truncateName(name, count)
  data = quakeText.encodeBytes(name)
  if len(data) <= count then return quakeText.decodeBytes(data) end if
  return quakeText.decodeBytes(slice(data, 0, count))
end function

/// Implements the `create` operation for `miniquake.memory` (create).
/// @param capacity Maximum number of entries the destination can hold.
function create(capacity)
  if capacity < 0 then return error(1600, "negative memory capacity") end if
  return MemoryManager(capacity, [], 0, 0, 0, false, 0, [], 0, 1, void, void)
end function

/// Implements the `hunkPayloadUsed` operation for `miniquake.memory` (hunk payload used).
/// @param state Mutable `miniquake.memory` state used by `hunkPayloadUsed`.
function hunkPayloadUsed(state)
  total = 0
  for each block in state.blocks
    if block.alive then total = total + block.size end if
  end for
  return total
end function

/// Implements the `cachePayloadUsed` operation for `miniquake.memory` (cache payload used).
/// @param state Mutable `miniquake.memory` state used by `cachePayloadUsed`.
function cachePayloadUsed(state)
  total = 0
  for each block in state.caches
    if block.alive then total = total + block.size end if
  end for
  return total
end function

/// Implements the `zonePayloadUsed` operation for `miniquake.memory` (zone payload used).
/// @param state Mutable `miniquake.memory` state used by `zonePayloadUsed`.
function zonePayloadUsed(state)
  if state.mainZone is void then return 0 end if
  total = 0
  for each block in state.mainZone.blocks
    if block.alive then total = total + block.size end if
  end for
  return total
end function

/// Implements the `used` operation for `miniquake.memory` (used).
/// @param state Mutable `miniquake.memory` state used by `used`.
function used(state)
  return hunkPayloadUsed(state) + cachePayloadUsed(state) + zonePayloadUsed(state)
end function

/// Release state for free hunk bytes.
/// @param state Mutable `miniquake.memory` state used by `freeHunkBytes`.
function inline freeHunkBytes(state)
  return state.capacity - state.lowUsed - state.highUsed
end function

/// Create and initialize hunk block.
/// @param state Mutable `miniquake.memory` state used by `newHunkBlock`.
/// @param requestedSize Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
/// @param kind The kind input consumed by `newHunkBlock`.
/// @param side The side input consumed by `newHunkBlock`.
/// @param start The start input consumed by `newHunkBlock`.
/// @param span The span input consumed by `newHunkBlock`.
function newHunkBlock(state, requestedSize, name, kind, side, start, span)
  block = HunkBlock(
    kind,
    truncateName(name, 8),
    bytes(requestedSize),
    requestedSize,
    true,
    state.nextAllocationIndex,
    side,
    start,
    span,
    HUNK_SENTINEL,
  )
  state.nextAllocationIndex = state.nextAllocationIndex + 1
  state.totalAllocated = state.totalAllocated + requestedSize
  state.blocks = state.blocks + [block]
  return block
end function

/// Implements the `lowMark` operation for `miniquake.memory` (low mark).
/// @param state Mutable `miniquake.memory` state used by `lowMark`.
function lowMark(state)
  return state.lowUsed
end function

/// Implements the `highMark` operation for `miniquake.memory` (high mark).
/// @param state Mutable `miniquake.memory` state used by `highMark`.
function highMark(state)
  if state.tempActive then
    mark = state.tempMark
    state.tempActive = false
    freeToHighMark(state, mark)
  end if
  return state.highUsed
end function

/// Return hunk alloc name derived from the active module state.
/// @param state Mutable `miniquake.memory` state used by `hunkAllocName`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function hunkAllocName(state, size, name)
  if size < 0 then return error(1601, "Hunk_Alloc: bad size: " + size) end if
  span = HUNK_HEADER_SIZE + align16(size)
  if freeHunkBytes(state) < span then return error(1602, "Hunk_Alloc: failed on " + span + " bytes") end if
  start = state.lowUsed
  state.lowUsed = state.lowUsed + span
  cacheFreeLow(state, state.lowUsed)
  return newHunkBlock(state, size, name, "hunk", "low", start, span)
end function

/// Implements the `hunkAlloc` operation for `miniquake.memory` (hunk alloc).
/// @param state Mutable `miniquake.memory` state used by `hunkAlloc`.
/// @param size Size of the requested data or resource.
function hunkAlloc(state, size)
  return hunkAllocName(state, size, "unknown")
end function

/// Return hunk high alloc name derived from the active module state.
/// @param state Mutable `miniquake.memory` state used by `hunkHighAllocName`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function hunkHighAllocName(state, size, name)
  if size < 0 then return error(1604, "Hunk_HighAllocName: bad size: " + size) end if
  if state.tempActive then
    mark = state.tempMark
    state.tempActive = false
    freeToHighMark(state, mark)
  end if
  span = HUNK_HEADER_SIZE + align16(size)
  if freeHunkBytes(state) < span then return void end if
  start = state.highUsed
  state.highUsed = state.highUsed + span
  cacheFreeHigh(state, state.highUsed)
  return newHunkBlock(state, size, name, "hunk", "high", start, span)
end function

/// Implements the `hunkTempAlloc` operation for `miniquake.memory` (hunk temp alloc).
/// @param state Mutable `miniquake.memory` state used by `hunkTempAlloc`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function hunkTempAlloc(state, size, name)
  aligned = align16(size)
  if state.tempActive then
    mark = state.tempMark
    state.tempActive = false
    freeToHighMark(state, mark)
  end if
  state.tempMark = highMark(state)
  block = hunkHighAllocName(state, aligned, "temp")
  if block is not void then
    block.kind = "temp"
    if name != "" then block.name = truncateName(name, 8) end if
  end if
  state.tempActive = true
  return block
end function

/// Release state for free to low mark.
/// @param state Mutable `miniquake.memory` state used by `freeToLowMark`.
/// @param mark The mark input consumed by `freeToLowMark`.
function freeToLowMark(state, mark)
  if mark < 0 or mark > state.lowUsed then return error(1603, "Hunk_FreeToLowMark: bad mark " + mark) end if
  for each block in state.blocks
    if block.alive and block.side == "low" and block.start + block.span > mark then
      block.alive = false
      block.data = bytes()
    end if
  end for
  state.lowUsed = mark
  return true
end function

/// Release state for free to high mark.
/// @param state Mutable `miniquake.memory` state used by `freeToHighMark`.
/// @param mark The mark input consumed by `freeToHighMark`.
function freeToHighMark(state, mark)
  if state.tempActive then
    tempRestore = state.tempMark
    state.tempActive = false
    freeToHighMark(state, tempRestore)
  end if
  if mark < 0 or mark > state.highUsed then return error(1605, "Hunk_FreeToHighMark: bad mark " + mark) end if
  for each block in state.blocks
    if block.alive and block.side == "high" and block.start + block.span > mark then
      block.alive = false
      block.data = bytes()
    end if
  end for
  state.highUsed = mark
  return true
end function

/// Implements the `hunkCheck` operation for `miniquake.memory` (hunk check).
/// @param state Mutable `miniquake.memory` state used by `hunkCheck`.
function hunkCheck(state)
  expected = 0
  for each block in state.blocks
    if block.alive and block.side == "low" then
      if block.sentinel != HUNK_SENTINEL then return error(1606, "Hunk_Check: trashed sentinel") end if
      if block.span < HUNK_HEADER_SIZE or block.start != expected then
        return error(1607, "Hunk_Check: bad size")
      end if
      expected = expected + block.span
    end if
  end for
  if expected != state.lowUsed then return error(1607, "Hunk_Check: bad low mark") end if
  return true
end function

/// Implements the `hunkPrint` operation for `miniquake.memory` (hunk print).
/// @param state Mutable `miniquake.memory` state used by `hunkPrint`.
/// @param all The all input consumed by `hunkPrint`.
function hunkPrint(state, all)
  text = "          :" + state.capacity + " total hunk size\n-------------------------"
  totalBlocks = 0
  groupName = ""
  groupSpan = 0
  for each block in state.blocks
    if block.alive and block.side == "low" then
      totalBlocks = totalBlocks + 1
      if all then
        text = text + "\n" + block.start + " :" + block.span + " " + block.name
      else if groupName == "" or groupName == block.name then
        groupName = block.name
        groupSpan = groupSpan + block.span
      else
        text = text + "\n          :" + groupSpan + " " + groupName + " (TOTAL)"
        groupName = block.name
        groupSpan = block.span
      end if
    end if
  end for
  if not all and groupName != "" then
    text = text + "\n          :" + groupSpan + " " + groupName + " (TOTAL)"
  end if

  text = text + "\n-------------------------\n          :" +
    freeHunkBytes(state) + " REMAINING\n-------------------------"

  // High allocations grow down from the top.  Their physical print order is
  // therefore the reverse of allocation order, exactly as zone.c walks from
  // starthigh toward endhigh.
  remaining = state.highUsed
  groupName = ""
  groupSpan = 0
  while remaining > 0
    current = void
    for each block in state.blocks
      if block.alive and block.side == "high" and block.start + block.span == remaining then
        current = block
        break
      end if
    end for
    if current is void then return error(1607, "Hunk_Check: bad high mark") end if
    totalBlocks = totalBlocks + 1
    physicalStart = state.capacity - remaining
    if all then
      text = text + "\n" + physicalStart + " :" + current.span + " " + current.name
    else if groupName == "" or groupName == current.name then
      groupName = current.name
      groupSpan = groupSpan + current.span
    else
      text = text + "\n          :" + groupSpan + " " + groupName + " (TOTAL)"
      groupName = current.name
      groupSpan = current.span
    end if
    remaining = current.start
  end while
  if not all and groupName != "" then
    text = text + "\n          :" + groupSpan + " " + groupName + " (TOTAL)"
  end if
  text = text + "\n-------------------------\n" + totalBlocks + " total blocks"
  return text
end function

/// Return cache start index derived from the active module state.
/// @param state Mutable `miniquake.memory` state used by `cacheStartIndex`.
/// @param block The block input consumed by `cacheStartIndex`.
function cacheStartIndex(state, block)
  index = 0
  while index < len(state.caches)
    if state.caches[index].allocationIndex == block.allocationIndex then return index end if
    index = index + 1
  end while
  return -1
end function

/// Add state for insert cache sorted.
/// @param state Mutable `miniquake.memory` state used by `insertCacheSorted`.
/// @param block The block input consumed by `insertCacheSorted`.
function insertCacheSorted(state, block)
  index = 0
  while index < len(state.caches) and state.caches[index].start < block.start
    index = index + 1
  end while
  oldCount = len(state.caches)
  result = array(oldCount + 1)
  // The insertion splits the old array into two non-overlapping source ranges.
  copyArray(result, 0, state.caches, 0, index)
  result[index] = block
  copyArray(result, index + 1, state.caches, index, oldCount - index)
  state.caches = result
end function

/// Release state for remove cache at.
/// @param state Mutable `miniquake.memory` state used by `removeCacheAt`.
/// @param index Zero-based index of the requested entry.
function removeCacheAt(state, index)
  oldCount = len(state.caches)
  result = array(oldCount - 1)
  // Compact around the removed cache block without changing object identity.
  copyArray(result, 0, state.caches, 0, index)
  copyArray(result, index, state.caches, index + 1, oldCount - index - 1)
  state.caches = result
end function

/// Implements the `cacheTryAlloc` operation for `miniquake.memory` (cache try alloc).
/// @param state Mutable `miniquake.memory` state used by `cacheTryAlloc`.
/// @param span The span input consumed by `cacheTryAlloc`.
/// @param noBottom The no bottom input consumed by `cacheTryAlloc`.
function cacheTryAlloc(state, span, noBottom)
  if span <= 0 then return -1 end if
  if len(state.caches) == 0 then
    if noBottom then return -1 end if
    if freeHunkBytes(state) < span then
      return error(1608, "Cache_TryAlloc: " + span + " is greater then free hunk")
    end if
    return state.lowUsed
  end if

  candidate = state.lowUsed
  index = 0
  while index < len(state.caches)
    block = state.caches[index]
    if not (noBottom and index == 0) and block.start - candidate >= span then return candidate end if
    candidate = block.start + block.span
    index = index + 1
  end while
  if state.capacity - state.highUsed - candidate >= span then return candidate end if
  return -1
end function

/// Cache_TryAlloc itself creates and links a cache header.  Cache_Alloc uses
/// the lower-level position search because it must fill the user/name/payload
/// fields atomically before exposing the new block.
/// @param state Mutable `miniquake.memory` state used by `cacheTryAllocBlock`.
/// @param span The span input consumed by `cacheTryAllocBlock`.
/// @param noBottom The no bottom input consumed by `cacheTryAllocBlock`.
function cacheTryAllocBlock(state, span, noBottom)
  start = cacheTryAlloc(state, span, noBottom)
  if start is error or start < 0 then return start end if
  payloadSize = span - CACHE_HEADER_SIZE
  if payloadSize < 0 then payloadSize = 0 end if
  block = CacheBlock(
    "cache",
    "",
    bytes(payloadSize),
    payloadSize,
    true,
    state.nextAllocationIndex,
    start,
    span,
    0,
    state,
    void,
  )
  state.nextAllocationIndex = state.nextAllocationIndex + 1
  insertCacheSorted(state, block)
  makeLru(block)
  return block
end function

/// Create and initialize cache user.
/// @param state Mutable `miniquake.memory` state used by `newCacheUser`.
function newCacheUser(state)
  return CacheUser(void, state)
end function

/// Create and initialize lru.
/// @param block The block input consumed by `makeLru`.
function makeLru(block)
  if block is void or not block.alive then return error(1609, "Cache_MakeLRU: NULL link") end if
  if block.lruStamp != 0 then return error(1610, "Cache_MakeLRU: active link") end if
  state = block.owner
  state.lruClock = state.lruClock + 1
  block.lruStamp = state.lruClock
  return block
end function

/// Implements the `unlinkLru` operation for `miniquake.memory` (unlink lru).
/// @param block The block input consumed by `unlinkLru`.
function unlinkLru(block)
  if block is void or not block.alive or block.lruStamp == 0 then
    return error(1611, "Cache_UnlinkLRU: NULL link")
  end if
  block.lruStamp = 0
  return block
end function

/// Implements the `leastRecentlyUsed` operation for `miniquake.memory` (least recently used).
/// @param state Mutable `miniquake.memory` state used by `leastRecentlyUsed`.
function leastRecentlyUsed(state)
  result = void
  for each block in state.caches
    if block.alive and (result is void or block.lruStamp < result.lruStamp) then result = block end if
  end for
  return result
end function

/// Implements the `cacheFree` operation for `miniquake.memory` (cache free).
/// @param user The user input consumed by `cacheFree`.
function cacheFree(user)
  if user is void or user.block is void or not user.block.alive then
    return error(1630, "Cache_Free: not allocated")
  end if
  block = user.block
  state = user.manager
  index = cacheStartIndex(state, block)
  if index < 0 then return error(1631, "Cache_Free: cache block is unlinked") end if
  unlinkLru(block)
  removeCacheAt(state, index)
  block.alive = false
  block.data = bytes()
  user.block = void
  return true
end function

/// Implements the `cacheCheck` operation for `miniquake.memory` (cache check).
/// @param state Mutable `miniquake.memory` state used by `cacheCheck`.
/// @param user The user input consumed by `cacheCheck`.
function cacheCheck(state, user)
  if user is void or user.block is void or not user.block.alive then return void end if
  unlinkLru(user.block)
  makeLru(user.block)
  return user.block.data
end function

/// Implements the `cacheAllocUser` operation for `miniquake.memory` (cache alloc user).
/// @param state Mutable `miniquake.memory` state used by `cacheAllocUser`.
/// @param user The user input consumed by `cacheAllocUser`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function cacheAllocUser(state, user, size, name)
  if user.block is not void and user.block.alive then return error(1632, "Cache_Alloc: already allocated") end if
  if size <= 0 then return error(1633, "Cache_Alloc: size " + size) end if
  span = align16(size + CACHE_HEADER_SIZE)
  start = cacheTryAlloc(state, span, false)
  while start == -1
    oldest = leastRecentlyUsed(state)
    if oldest is void then return error(1634, "Cache_Alloc: out of memory") end if
    cacheFree(oldest.user)
    start = cacheTryAlloc(state, span, false)
  end while
  if start is error then return start end if

  block = CacheBlock(
    "cache",
    truncateName(name, 15),
    bytes(size),
    size,
    true,
    state.nextAllocationIndex,
    start,
    span,
    0,
    state,
    user,
  )
  state.nextAllocationIndex = state.nextAllocationIndex + 1
  state.totalAllocated = state.totalAllocated + size
  user.manager = state
  user.block = block
  insertCacheSorted(state, block)
  makeLru(block)
  return block.data
end function

/// Implements the `cacheAlloc` operation for `miniquake.memory` (cache alloc).
/// @param state Mutable `miniquake.memory` state used by `cacheAlloc`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function cacheAlloc(state, size, name)
  user = newCacheUser(state)
  allocated = cacheAllocUser(state, user, size, name)
  if allocated is error then return allocated end if
  return user
end function

/// Implements the `cacheMove` operation for `miniquake.memory` (cache move).
/// @param block The block input consumed by `cacheMove`.
function cacheMove(block)
  if block is void or not block.alive then return false end if
  state = block.owner
  newStart = cacheTryAlloc(state, block.span, true)
  if newStart is error or newStart < 0 then
    cacheFree(block.user)
    return false
  end if
  index = cacheStartIndex(state, block)
  removeCacheAt(state, index)
  block.start = newStart
  insertCacheSorted(state, block)
  unlinkLru(block)
  makeLru(block)
  return true
end function

/// Implements the `cacheFreeLow` operation for `miniquake.memory` (cache free low).
/// @param state Mutable `miniquake.memory` state used by `cacheFreeLow`.
/// @param newLowHunk The new low hunk input consumed by `cacheFreeLow`.
function cacheFreeLow(state, newLowHunk)
  while len(state.caches) > 0
    block = state.caches[0]
    if block.start >= newLowHunk then return true end if
    cacheMove(block)
  end while
  return true
end function

/// Implements the `cacheFreeHigh` operation for `miniquake.memory` (cache free high).
/// @param state Mutable `miniquake.memory` state used by `cacheFreeHigh`.
/// @param newHighHunk The new high hunk input consumed by `cacheFreeHigh`.
function cacheFreeHigh(state, newHighHunk)
  while len(state.caches) > 0
    block = state.caches[len(state.caches) - 1]
    if block.start + block.span <= state.capacity - newHighHunk then return true end if
    oldStart = block.start
    cacheMove(block)
    if block.alive and block.start >= oldStart then cacheFree(block.user) end if
  end while
  return true
end function

/// Implements the `cacheFlush` operation for `miniquake.memory` (cache flush).
/// @param state Mutable `miniquake.memory` state used by `cacheFlush`.
function cacheFlush(state)
  while len(state.caches) > 0
    cacheFree(state.caches[0].user)
  end while
  return true
end function

/// Implements the `cachePrint` operation for `miniquake.memory` (cache print).
/// @param state Mutable `miniquake.memory` state used by `cachePrint`.
function cachePrint(state)
  text = ""
  for each block in state.caches
    text = text + block.span + " : " + block.name + "\n"
  end for
  return text
end function

/// Implements the `cacheReport` operation for `miniquake.memory` (cache report).
/// @param state Mutable `miniquake.memory` state used by `cacheReport`.
function cacheReport(state)
  return freeHunkBytes(state) / (1024.0 * 1024.0)
end function

/// Implements the `cacheCompact` operation for `miniquake.memory` (cache compact).
/// @param state Mutable `miniquake.memory` state used by `cacheCompact`.
function cacheCompact(state)
  return true
end function

/// Update subsystem state for cache init.
/// @param state Mutable `miniquake.memory` state used by `cacheInit`.
function cacheInit(state)
  for each block in state.caches
    block.alive = false
    block.data = bytes()
    block.user.block = void
  end for
  state.caches = []
  state.lruClock = 0
  return state
end function

/// Return zone state derived from the active module state.
/// @param state Mutable `miniquake.memory` state used by `zoneState`.
function zoneState(state)
  if state.mainZone is void then state.mainZone = zone.create(state.capacity) end if
  return state.mainZone
end function

/// Implements the `zoneTagMalloc` operation for `miniquake.memory` (zone tag malloc).
/// @param state Mutable `miniquake.memory` state used by `zoneTagMalloc`.
/// @param size Size of the requested data or resource.
/// @param tag The tag input consumed by `zoneTagMalloc`.
/// @param name Stable name that identifies the requested object or option.
function zoneTagMalloc(state, size, tag, name)
  block = zone.tagMalloc(zoneState(state), size, tag)
  if block is void or block is error then return block end if
  block.name = name
  state.totalAllocated = state.totalAllocated + size
  return block
end function

/// Implements the `zoneMalloc` operation for `miniquake.memory` (zone malloc).
/// @param state Mutable `miniquake.memory` state used by `zoneMalloc`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function zoneMalloc(state, size, name)
  zone.check(zoneState(state))
  block = zoneTagMalloc(state, size, 1, name)
  if block is void then return error(1635, "Z_Malloc: failed on allocation of " + size + " bytes") end if
  return block
end function

/// Implements the `zoneFree` operation for `miniquake.memory` (zone free).
/// @param block The block input consumed by `zoneFree`.
function zoneFree(block)
  return zone.free(block)
end function

/// Implements the `zoneCheck` operation for `miniquake.memory` (zone check).
/// @param state Mutable `miniquake.memory` state used by `zoneCheck`.
function zoneCheck(state)
  return zone.check(zoneState(state))
end function

/// Implements the `zonePrint` operation for `miniquake.memory` (zone print).
/// @param state Mutable `miniquake.memory` state used by `zonePrint`.
function zonePrint(state)
  return zone.printHeap(zoneState(state))
end function

/// Implements the `zoneDumpHeap` operation for `miniquake.memory` (zone dump heap).
/// @param state Mutable `miniquake.memory` state used by `zoneDumpHeap`.
function zoneDumpHeap(state)
  return zone.dumpHeap(zoneState(state))
end function

/// Implements the `zoneFreeMemory` operation for `miniquake.memory` (zone free memory).
/// @param state Mutable `miniquake.memory` state used by `zoneFreeMemory`.
function zoneFreeMemory(state)
  return zone.freeMemory(zoneState(state))
end function

/// Implements the `allocate` operation for `miniquake.memory` (allocate).
/// @param state Mutable `miniquake.memory` state used by `allocate`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
/// @param kind The kind input consumed by `allocate`.
function allocate(state, size, name, kind)
  if kind == "zone" then return zoneMalloc(state, size, name) end if
  if kind == "temp" then return hunkTempAlloc(state, size, name) end if
  if kind == "high" then return hunkHighAllocName(state, size, name) end if
  return hunkAllocName(state, size, name)
end function

/// Update subsystem state for memory init.
/// @param capacity Maximum number of entries the destination can hold.
/// @param zoneSize Size of the requested data or resource.
function memoryInit(capacity, zoneSize)
  state = create(capacity)
  cacheInit(state)
  if zoneSize <= 0 then zoneSize = zone.DYNAMIC_SIZE end if
  backing = hunkAllocName(state, zoneSize, "zone")
  state.zoneBacking = backing
  state.mainZone = zone.create(zoneSize)
  return state
end function

/// Implements the `memoryInitArguments` operation for `miniquake.memory` (memory init arguments).
/// @param capacity Maximum number of entries the destination can hold.
/// @param commandLine The command line input consumed by `memoryInitArguments`.
function memoryInitArguments(capacity, commandLine)
  zoneSize = zone.DYNAMIC_SIZE
  position = 0
  index = 0
  while index < len(commandLine.args)
    if commandLine.args[index] == "-zone" then position = index + 1; break end if
    index = index + 1
  end while
  if position != 0 then
    if position >= len(commandLine.args) then
      return error(1636, "Memory_Init: you must specify a size in KB after -zone")
    end if
    source = bytes(commandLine.args[position])
    value = 0
    sourceIndex = 0
    while sourceIndex < len(source) and source[sourceIndex] >= 48 and source[sourceIndex] <= 57
      value = value * 10 + source[sourceIndex] - 48
      sourceIndex = sourceIndex + 1
    end while
    zoneSize = value * 1024
  end if
  return memoryInit(capacity, zoneSize)
end function

/// Explicit zone.c entry points. MemoryManager replaces the original global
/// hunk/cache variables, while marks remain byte offsets as in MiniQuake.
/// @param state Mutable `miniquake.memory` state used by `Hunk_Check`.
function Hunk_Check(state)
  return hunkCheck(state)
end function

/// Mirror Quake's Hunk_Print routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_Print`.
/// @param all The all input consumed by `Hunk_Print`.
function Hunk_Print(state, all)
  return hunkPrint(state, all)
end function

/// Mirror Quake's Hunk_AllocName routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_AllocName`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function Hunk_AllocName(state, size, name)
  return hunkAllocName(state, size, name)
end function

/// Mirror Quake's Hunk_Alloc routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_Alloc`.
/// @param size Size of the requested data or resource.
function Hunk_Alloc(state, size)
  return hunkAlloc(state, size)
end function

/// Mirror Quake's Hunk_LowMark routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_LowMark`.
function Hunk_LowMark(state)
  return lowMark(state)
end function

/// Mirror Quake's Hunk_FreeToLowMark routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_FreeToLowMark`.
/// @param mark The mark input consumed by `Hunk_FreeToLowMark`.
function Hunk_FreeToLowMark(state, mark)
  return freeToLowMark(state, mark)
end function

/// Mirror Quake's Hunk_HighMark routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_HighMark`.
function Hunk_HighMark(state)
  return highMark(state)
end function

/// Mirror Quake's Hunk_FreeToHighMark routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_FreeToHighMark`.
/// @param mark The mark input consumed by `Hunk_FreeToHighMark`.
function Hunk_FreeToHighMark(state, mark)
  return freeToHighMark(state, mark)
end function

/// Mirror Quake's Hunk_HighAllocName routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_HighAllocName`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function Hunk_HighAllocName(state, size, name)
  return hunkHighAllocName(state, size, name)
end function

/// Mirror Quake's Hunk_TempAlloc routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Hunk_TempAlloc`.
/// @param size Size of the requested data or resource.
function Hunk_TempAlloc(state, size)
  return hunkTempAlloc(state, size, "")
end function

/// Mirror Quake's Cache_Move routine and its observable state changes.
/// @param block The block input consumed by `Cache_Move`.
function Cache_Move(block)
  return cacheMove(block)
end function

/// Mirror Quake's Cache_FreeLow routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_FreeLow`.
/// @param newLowHunk The new low hunk input consumed by `Cache_FreeLow`.
function Cache_FreeLow(state, newLowHunk)
  return cacheFreeLow(state, newLowHunk)
end function

/// Mirror Quake's Cache_FreeHigh routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_FreeHigh`.
/// @param newHighHunk The new high hunk input consumed by `Cache_FreeHigh`.
function Cache_FreeHigh(state, newHighHunk)
  return cacheFreeHigh(state, newHighHunk)
end function

/// Mirror Quake's Cache_UnlinkLRU routine and its observable state changes.
/// @param block The block input consumed by `Cache_UnlinkLRU`.
function Cache_UnlinkLRU(block)
  return unlinkLru(block)
end function

/// Mirror Quake's Cache_MakeLRU routine and its observable state changes.
/// @param block The block input consumed by `Cache_MakeLRU`.
function Cache_MakeLRU(block)
  return makeLru(block)
end function

/// Mirror Quake's Cache_TryAlloc routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_TryAlloc`.
/// @param size Size of the requested data or resource.
/// @param noBottom The no bottom input consumed by `Cache_TryAlloc`.
function Cache_TryAlloc(state, size, noBottom)
  return cacheTryAllocBlock(state, size, noBottom)
end function

/// Mirror Quake's Cache_Flush routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Flush`.
function Cache_Flush(state)
  return cacheFlush(state)
end function

/// Mirror Quake's Cache_Print routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Print`.
function Cache_Print(state)
  return cachePrint(state)
end function

/// Mirror Quake's Cache_Report routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Report`.
function Cache_Report(state)
  return cacheReport(state)
end function

/// Mirror Quake's Cache_Compact routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Compact`.
function Cache_Compact(state)
  return cacheCompact(state)
end function

/// Mirror Quake's Cache_Init routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Init`.
function Cache_Init(state)
  return cacheInit(state)
end function

/// Mirror Quake's Cache_Free routine and its observable state changes.
/// @param user The user input consumed by `Cache_Free`.
function Cache_Free(user)
  return cacheFree(user)
end function

/// Implements the `Cache_Check` operation for `miniquake.memory` (cache check).
/// @param state Mutable `miniquake.memory` state used by `Cache_Check`.
/// @param user The user input consumed by `Cache_Check`.
function Cache_Check(state, user)
  return cacheCheck(state, user)
end function

/// Mirror Quake's Cache_Alloc routine and its observable state changes.
/// @param state Mutable `miniquake.memory` state used by `Cache_Alloc`.
/// @param user The user input consumed by `Cache_Alloc`.
/// @param size Size of the requested data or resource.
/// @param name Stable name that identifies the requested object or option.
function Cache_Alloc(state, user, size, name)
  return cacheAllocUser(state, user, size, name)
end function

/// Mirror Quake's Memory_Init routine and its observable state changes.
/// @param capacity Maximum number of entries the destination can hold.
/// @param zoneSize Size of the requested data or resource.
function Memory_Init(capacity, zoneSize)
  return memoryInit(capacity, zoneSize)
end function
