package miniquake.memory

import miniquake.zone as zone

const HUNK_SENTINEL = 0x1df001ed
const HUNK_HEADER_SIZE = 16
const CACHE_HEADER_SIZE = 40

struct HunkBlock
  kind
  name
  data
  size
  alive
  allocationIndex
  side
  start
  span
  sentinel
end struct

struct CacheBlock
  kind
  name
  data
  size
  alive
  allocationIndex
  start
  span
  lruStamp
  owner
  user
end struct

struct CacheUser
  block
  manager
end struct

struct MemoryManager
  capacity
  blocks
  totalAllocated
  lowUsed
  highUsed
  tempActive
  tempMark
  caches
  lruClock
  nextAllocationIndex
  mainZone
  zoneBacking
end struct

function align16(value)
  return (value + 15) & ~15
end function

function truncateName(name, count)
  data = bytes(name)
  if len(data) <= count then return name end if
  return decode(slice(data, 0, count))
end function

function create(capacity)
  if capacity < 0 then return error(1600, "negative memory capacity") end if
  return MemoryManager(capacity, [], 0, 0, 0, false, 0, [], 0, 1, void, void)
end function

function hunkPayloadUsed(state)
  total = 0
  for each block in state.blocks
    if block.alive then total = total + block.size end if
  end for
  return total
end function

function cachePayloadUsed(state)
  total = 0
  for each block in state.caches
    if block.alive then total = total + block.size end if
  end for
  return total
end function

function zonePayloadUsed(state)
  if state.mainZone is void then return 0 end if
  total = 0
  for each block in state.mainZone.blocks
    if block.alive then total = total + block.size end if
  end for
  return total
end function

function used(state)
  return hunkPayloadUsed(state) + cachePayloadUsed(state) + zonePayloadUsed(state)
end function

function freeHunkBytes(state)
  return state.capacity - state.lowUsed - state.highUsed
end function

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

function lowMark(state)
  return state.lowUsed
end function

function highMark(state)
  if state.tempActive then
    mark = state.tempMark
    state.tempActive = false
    freeToHighMark(state, mark)
  end if
  return state.highUsed
end function

function hunkAllocName(state, size, name)
  if size < 0 then return error(1601, "Hunk_Alloc: bad size: " + size) end if
  span = HUNK_HEADER_SIZE + align16(size)
  if freeHunkBytes(state) < span then return error(1602, "Hunk_Alloc: failed on " + span + " bytes") end if
  start = state.lowUsed
  state.lowUsed = state.lowUsed + span
  cacheFreeLow(state, state.lowUsed)
  return newHunkBlock(state, size, name, "hunk", "low", start, span)
end function

function hunkAlloc(state, size)
  return hunkAllocName(state, size, "unknown")
end function

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

function cacheStartIndex(state, block)
  index = 0
  while index < len(state.caches)
    if state.caches[index].allocationIndex == block.allocationIndex then return index end if
    index = index + 1
  end while
  return -1
end function

function insertCacheSorted(state, block)
  index = 0
  while index < len(state.caches) and state.caches[index].start < block.start
    index = index + 1
  end while
  result = array(len(state.caches) + 1)
  sourceIndex = 0
  destinationIndex = 0
  while destinationIndex < len(result)
    if destinationIndex == index then
      result[destinationIndex] = block
    else
      result[destinationIndex] = state.caches[sourceIndex]
      sourceIndex = sourceIndex + 1
    end if
    destinationIndex = destinationIndex + 1
  end while
  state.caches = result
end function

function removeCacheAt(state, index)
  result = array(len(state.caches) - 1)
  sourceIndex = 0
  destinationIndex = 0
  while sourceIndex < len(state.caches)
    if sourceIndex != index then
      result[destinationIndex] = state.caches[sourceIndex]
      destinationIndex = destinationIndex + 1
    end if
    sourceIndex = sourceIndex + 1
  end while
  state.caches = result
end function

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

// Cache_TryAlloc itself creates and links a cache header.  Cache_Alloc uses
// the lower-level position search because it must fill the user/name/payload
// fields atomically before exposing the new block.
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

function newCacheUser(state)
  return CacheUser(void, state)
end function

function makeLru(block)
  if block is void or not block.alive then return error(1609, "Cache_MakeLRU: NULL link") end if
  if block.lruStamp != 0 then return error(1610, "Cache_MakeLRU: active link") end if
  state = block.owner
  state.lruClock = state.lruClock + 1
  block.lruStamp = state.lruClock
  return block
end function

function unlinkLru(block)
  if block is void or not block.alive or block.lruStamp == 0 then
    return error(1611, "Cache_UnlinkLRU: NULL link")
  end if
  block.lruStamp = 0
  return block
end function

function leastRecentlyUsed(state)
  result = void
  for each block in state.caches
    if block.alive and (result is void or block.lruStamp < result.lruStamp) then result = block end if
  end for
  return result
end function

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

function cacheCheck(state, user)
  if user is void or user.block is void or not user.block.alive then return void end if
  unlinkLru(user.block)
  makeLru(user.block)
  return user.block.data
end function

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

function cacheAlloc(state, size, name)
  user = newCacheUser(state)
  allocated = cacheAllocUser(state, user, size, name)
  if allocated is error then return allocated end if
  return user
end function

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

function cacheFreeLow(state, newLowHunk)
  while len(state.caches) > 0
    block = state.caches[0]
    if block.start >= newLowHunk then return true end if
    cacheMove(block)
  end while
  return true
end function

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

function cacheFlush(state)
  while len(state.caches) > 0
    cacheFree(state.caches[0].user)
  end while
  return true
end function

function cachePrint(state)
  text = ""
  for each block in state.caches
    text = text + block.span + " : " + block.name + "\n"
  end for
  return text
end function

function cacheReport(state)
  return freeHunkBytes(state) / (1024.0 * 1024.0)
end function

function cacheCompact(state)
  return true
end function

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

function zoneState(state)
  if state.mainZone is void then state.mainZone = zone.create(state.capacity) end if
  return state.mainZone
end function

function zoneTagMalloc(state, size, tag, name)
  block = zone.tagMalloc(zoneState(state), size, tag)
  if block is void or block is error then return block end if
  block.name = name
  state.totalAllocated = state.totalAllocated + size
  return block
end function

function zoneMalloc(state, size, name)
  zone.check(zoneState(state))
  block = zoneTagMalloc(state, size, 1, name)
  if block is void then return error(1635, "Z_Malloc: failed on allocation of " + size + " bytes") end if
  return block
end function

function zoneFree(block)
  return zone.free(block)
end function

function zoneCheck(state)
  return zone.check(zoneState(state))
end function

function zonePrint(state)
  return zone.printHeap(zoneState(state))
end function

function zoneDumpHeap(state)
  return zone.dumpHeap(zoneState(state))
end function

function zoneFreeMemory(state)
  return zone.freeMemory(zoneState(state))
end function

function allocate(state, size, name, kind)
  if kind == "zone" then return zoneMalloc(state, size, name) end if
  if kind == "temp" then return hunkTempAlloc(state, size, name) end if
  if kind == "high" then return hunkHighAllocName(state, size, name) end if
  return hunkAllocName(state, size, name)
end function

function memoryInit(capacity, zoneSize)
  state = create(capacity)
  cacheInit(state)
  if zoneSize <= 0 then zoneSize = zone.DYNAMIC_SIZE end if
  backing = hunkAllocName(state, zoneSize, "zone")
  state.zoneBacking = backing
  state.mainZone = zone.create(zoneSize)
  return state
end function

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

// Explicit zone.c entry points. MemoryManager replaces the original global
// hunk/cache variables, while marks remain byte offsets as in GLQuake.
function Hunk_Check(state)
  return hunkCheck(state)
end function

function Hunk_Print(state, all)
  return hunkPrint(state, all)
end function

function Hunk_AllocName(state, size, name)
  return hunkAllocName(state, size, name)
end function

function Hunk_Alloc(state, size)
  return hunkAlloc(state, size)
end function

function Hunk_LowMark(state)
  return lowMark(state)
end function

function Hunk_FreeToLowMark(state, mark)
  return freeToLowMark(state, mark)
end function

function Hunk_HighMark(state)
  return highMark(state)
end function

function Hunk_FreeToHighMark(state, mark)
  return freeToHighMark(state, mark)
end function

function Hunk_HighAllocName(state, size, name)
  return hunkHighAllocName(state, size, name)
end function

function Hunk_TempAlloc(state, size)
  return hunkTempAlloc(state, size, "")
end function

function Cache_Move(block)
  return cacheMove(block)
end function

function Cache_FreeLow(state, newLowHunk)
  return cacheFreeLow(state, newLowHunk)
end function

function Cache_FreeHigh(state, newHighHunk)
  return cacheFreeHigh(state, newHighHunk)
end function

function Cache_UnlinkLRU(block)
  return unlinkLru(block)
end function

function Cache_MakeLRU(block)
  return makeLru(block)
end function

function Cache_TryAlloc(state, size, noBottom)
  return cacheTryAllocBlock(state, size, noBottom)
end function

function Cache_Flush(state)
  return cacheFlush(state)
end function

function Cache_Print(state)
  return cachePrint(state)
end function

function Cache_Report(state)
  return cacheReport(state)
end function

function Cache_Compact(state)
  return cacheCompact(state)
end function

function Cache_Init(state)
  return cacheInit(state)
end function

function Cache_Free(user)
  return cacheFree(user)
end function

function Cache_Check(state, user)
  return cacheCheck(state, user)
end function

function Cache_Alloc(state, user, size, name)
  return cacheAllocUser(state, user, size, name)
end function

function Memory_Init(capacity, zoneSize)
  return memoryInit(capacity, zoneSize)
end function
