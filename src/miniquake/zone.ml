/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.zone.
*/
package miniquake.zone

const DYNAMIC_SIZE = 0xc000
const ZONEID = 0x1d4a11
const MINFRAGMENT = 64
const ZONE_ADMIN_SIZE = 32
const BLOCK_HEADER_SIZE = 24
const TRASH_SIZE = 4

struct ZoneBlock
  kind
  name
  data
  size
  alive
  tag
  id
  start
  span
  owner
  allocationId
  trashId
end struct

struct ZoneState
  capacity
  blocks
  rover
  nextAllocationId
end struct

// Provide align8 behavior for the active subsystem.
function align8(value)
  return (value + 7) & ~7
end function

// Update module state for the requested operation.
function clear(state, size)
  if size < ZONE_ADMIN_SIZE + BLOCK_HEADER_SIZE + TRASH_SIZE then
    return error(1610, "Z_ClearZone: zone is too small")
  end if
  state.capacity = size
  freeBlock = ZoneBlock(
    "zone",
    "free",
    bytes(),
    0,
    false,
    0,
    ZONEID,
    ZONE_ADMIN_SIZE,
    size - ZONE_ADMIN_SIZE,
    state,
    0,
    ZONEID,
  )
  state.blocks = [freeBlock]
  state.rover = 0
  state.nextAllocationId = 1
  return state
end function

// Create and initialize the module state.
function create(size)
  state = ZoneState(size, [], 0, 1)
  return clear(state, size)
end function

// Return index of for the active module state.
function indexOf(state, block)
  index = 0
  while index < len(state.blocks)
    if state.blocks[index].allocationId == block.allocationId and state.blocks[index].start == block.start then
      return index
    end if
    index = index + 1
  end while
  return -1
end function

// Add state for insert after.
function insertAfter(state, index, block)
  result = array(len(state.blocks) + 1)
  sourceIndex = 0
  destinationIndex = 0
  while destinationIndex < len(result)
    if destinationIndex == index + 1 then
      result[destinationIndex] = block
    else
      result[destinationIndex] = state.blocks[sourceIndex]
      sourceIndex = sourceIndex + 1
    end if
    destinationIndex = destinationIndex + 1
  end while
  state.blocks = result
end function

// Release state for remove at.
function removeAt(state, index)
  result = array(len(state.blocks) - 1)
  sourceIndex = 0
  destinationIndex = 0
  while sourceIndex < len(state.blocks)
    if sourceIndex != index then
      result[destinationIndex] = state.blocks[sourceIndex]
      destinationIndex = destinationIndex + 1
    end if
    sourceIndex = sourceIndex + 1
  end while
  state.blocks = result
end function

// Validate the requested value and report any incompatibility.
function check(state)
  if state is void then return error(1611, "Z_CheckHeap: NULL zone") end if
  expectedStart = ZONE_ADMIN_SIZE
  previousFree = false
  index = 0
  while index < len(state.blocks)
    block = state.blocks[index]
    if block.id != ZONEID then return error(1612, "Z_CheckHeap: block without ZONEID") end if
    if block.start != expectedStart then
      return error(1613, "Z_CheckHeap: block size does not touch the next block")
    end if
    if block.span < BLOCK_HEADER_SIZE + TRASH_SIZE then
      return error(1614, "Z_CheckHeap: invalid block size")
    end if
    free = block.tag == 0
    if free and previousFree then return error(1615, "Z_CheckHeap: two consecutive free blocks") end if
    if not free and block.trashId != ZONEID then return error(1616, "Z_CheckHeap: trashed marker") end if
    previousFree = free
    expectedStart = expectedStart + block.span
    index = index + 1
  end while
  if expectedStart != state.capacity then return error(1617, "Z_CheckHeap: zone size mismatch") end if
  if state.rover < 0 or state.rover >= len(state.blocks) then return error(1618, "Z_CheckHeap: bad rover") end if
  return true
end function

// Provide tag malloc behavior for the active subsystem.
function tagMalloc(state, size, tag)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if tag == 0 then return error(1619, "Z_TagMalloc: tried to use a 0 tag") end if
  if size < 0 then return error(1620, "Z_TagMalloc: negative size") end if
  required = align8(size + BLOCK_HEADER_SIZE + TRASH_SIZE)
  if len(state.blocks) == 0 then return void end if

  scanned = 0
  index = state.rover
  while scanned < len(state.blocks)
    if index >= len(state.blocks) then index = 0 end if
    block = state.blocks[index]
    if block.tag == 0 and block.span >= required then
      extra = block.span - required
      if extra > MINFRAGMENT then
        fragment = ZoneBlock(
          "zone",
          "free",
          bytes(),
          0,
          false,
          0,
          ZONEID,
          block.start + required,
          extra,
          state,
          0,
          ZONEID,
        )
        block.span = required
        insertAfter(state, index, fragment)
      end if

      block.kind = "zone"
      block.name = "zone"
      block.data = bytes(size)
      block.size = size
      block.alive = true
      block.tag = tag
      block.id = ZONEID
      block.allocationId = state.nextAllocationId
      block.trashId = ZONEID
      state.nextAllocationId = state.nextAllocationId + 1
      state.rover = index + 1
      if state.rover >= len(state.blocks) then state.rover = 0 end if
      return block
    end if
    index = index + 1
    scanned = scanned + 1
  end while
  return void
end function

// Provide malloc behavior for the active subsystem.
function malloc(state, size)
  check(state)
  block = tagMalloc(state, size, 1)
  if block is void then return error(1621, "Z_Malloc: failed on allocation of " + size + " bytes") end if
  return block
end function

// Release state for free.
function free(block)
  if block is void then return error(1622, "Z_Free: NULL pointer") end if
  if block.id != ZONEID then return error(1623, "Z_Free: freed a pointer without ZONEID") end if
  if block.tag == 0 or not block.alive then return error(1624, "Z_Free: freed a freed pointer") end if
  state = block.owner
  index = indexOf(state, block)
  if index < 0 then return error(1625, "Z_Free: pointer is outside zone") end if

  block.tag = 0
  block.alive = false
  block.data = bytes()
  block.size = 0
  block.name = "free"

  if index > 0 and state.blocks[index - 1].tag == 0 then
    previous = state.blocks[index - 1]
    previous.span = previous.span + block.span
    if state.rover == index then state.rover = index - 1 end if
    removeAt(state, index)
    index = index - 1
    block = previous
  end if

  if index + 1 < len(state.blocks) and state.blocks[index + 1].tag == 0 then
    next = state.blocks[index + 1]
    block.span = block.span + next.span
    if state.rover == index + 1 then state.rover = index end if
    removeAt(state, index + 1)
  end if
  if state.rover >= len(state.blocks) then state.rover = 0 end if
  return true
end function

// Release state for free memory.
function freeMemory(state)
  total = 0
  for each block in state.blocks
    if block.tag == 0 then total = total + block.span end if
  end for
  return total
end function

// Format and emit heap.
function printHeap(state)
  text = "zone size: " + state.capacity
  for each block in state.blocks
    text = text + "\nblock:" + block.start + " size:" + block.span + " tag:" + block.tag
  end for
  return text
end function

// Provide dump heap behavior for the active subsystem.
function dumpHeap(state)
  return printHeap(state)
end function

// Explicit zone.c/header entry points. The zone state parameter replaces the
// original process-global mainzone pointer.
function Z_ClearZone(state, size)
  return clear(state, size)
end function

// Mirror Quake's Z_Free routine and its observable state changes.
function Z_Free(block)
  return free(block)
end function

// Mirror Quake's Z_Malloc routine and its observable state changes.
function Z_Malloc(state, size)
  return malloc(state, size)
end function

// Mirror Quake's Z_TagMalloc routine and its observable state changes.
function Z_TagMalloc(state, size, tag)
  return tagMalloc(state, size, tag)
end function

// Mirror Quake's Z_Print routine and its observable state changes.
function Z_Print(state)
  return printHeap(state)
end function

// Mirror Quake's Z_DumpHeap routine and its observable state changes.
function Z_DumpHeap(state)
  return dumpHeap(state)
end function

// Mirror Quake's Z_CheckHeap routine and its observable state changes.
function Z_CheckHeap(state)
  return check(state)
end function

// Mirror Quake's Z_FreeMemory routine and its observable state changes.
function Z_FreeMemory(state)
  return freeMemory(state)
end function
