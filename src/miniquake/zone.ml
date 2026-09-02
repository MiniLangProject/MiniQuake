/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.zone.
*/
package miniquake.zone

/// Defines the dynamic size value used by `miniquake.zone`.
const DYNAMIC_SIZE = 0xc000
/// Defines the zoneid value used by `miniquake.zone`.
const ZONEID = 0x1d4a11
/// Defines the minfragment value used by `miniquake.zone`.
const MINFRAGMENT = 64
/// Defines the zone admin size value used by `miniquake.zone`.
const ZONE_ADMIN_SIZE = 32
/// Defines the block header size value used by `miniquake.zone`.
const BLOCK_HEADER_SIZE = 24
/// Defines the trash size value used by `miniquake.zone`.
const TRASH_SIZE = 4

// Group the fields that describe one zone block.
struct ZoneBlock
  /// Stores the kind value in `miniquake.zone.ZoneBlock`.
  kind
  /// Stores the name value in `miniquake.zone.ZoneBlock`.
  name
  /// Stores the data value in `miniquake.zone.ZoneBlock`.
  data
  /// Stores the size value in `miniquake.zone.ZoneBlock`.
  size
  /// Stores the alive value in `miniquake.zone.ZoneBlock`.
  alive
  /// Stores the tag value in `miniquake.zone.ZoneBlock`.
  tag
  /// Stores the id value in `miniquake.zone.ZoneBlock`.
  id
  /// Stores the start value in `miniquake.zone.ZoneBlock`.
  start
  /// Stores the span value in `miniquake.zone.ZoneBlock`.
  span
  /// Stores the owner value in `miniquake.zone.ZoneBlock`.
  owner
  /// Stores the allocation id value in `miniquake.zone.ZoneBlock`.
  allocationId
  /// Stores the trash id value in `miniquake.zone.ZoneBlock`.
  trashId
end struct

// Track mutable zone state across subsystem calls.
struct ZoneState
  /// Stores the capacity value in `miniquake.zone.ZoneState`.
  capacity
  /// Stores the blocks value in `miniquake.zone.ZoneState`.
  blocks
  /// Stores the rover value in `miniquake.zone.ZoneState`.
  rover
  /// Stores the next allocation id value in `miniquake.zone.ZoneState`.
  nextAllocationId
end struct

/// Implements the `align8` operation for `miniquake.zone` (align8).
/// @param value Value consumed by `align8`.
function align8(value)
  return (value + 7) & ~7
end function

/// Implements the `clear` operation for `miniquake.zone` (clear).
/// @param state Mutable `miniquake.zone` state used by `clear`.
/// @param size Size of the requested data or resource.
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

/// Implements the `create` operation for `miniquake.zone` (create).
/// @param size Size of the requested data or resource.
function create(size)
  state = ZoneState(size, [], 0, 1)
  return clear(state, size)
end function

/// Return index of for the active module state.
/// @param state Mutable `miniquake.zone` state used by `indexOf`.
/// @param block The block input consumed by `indexOf`.
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

/// Add state for insert after.
/// @param state Mutable `miniquake.zone` state used by `insertAfter`.
/// @param index Zero-based index of the requested entry.
/// @param block The block input consumed by `insertAfter`.
function insertAfter(state, index, block)
  oldCount = len(state.blocks)
  insertionIndex = index + 1
  result = array(oldCount + 1)
  // Preserve the linked block ordering around the inserted fragment.
  copyArray(result, 0, state.blocks, 0, insertionIndex)
  result[insertionIndex] = block
  copyArray(result, insertionIndex + 1, state.blocks, insertionIndex, oldCount - insertionIndex)
  state.blocks = result
end function

/// Release state for remove at.
/// @param state Mutable `miniquake.zone` state used by `removeAt`.
/// @param index Zero-based index of the requested entry.
function removeAt(state, index)
  oldCount = len(state.blocks)
  result = array(oldCount - 1)
  // Compact the two retained ranges into the newly allocated block array.
  copyArray(result, 0, state.blocks, 0, index)
  copyArray(result, index, state.blocks, index + 1, oldCount - index - 1)
  state.blocks = result
end function

/// Implements the `check` operation for `miniquake.zone` (check).
/// @param state Mutable `miniquake.zone` state used by `check`.
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

/// Implements the `tagMalloc` operation for `miniquake.zone` (tag malloc).
/// @param state Mutable `miniquake.zone` state used by `tagMalloc`.
/// @param size Size of the requested data or resource.
/// @param tag The tag input consumed by `tagMalloc`.
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

/// Implements the `malloc` operation for `miniquake.zone` (malloc).
/// @param state Mutable `miniquake.zone` state used by `malloc`.
/// @param size Size of the requested data or resource.
function malloc(state, size)
  check(state)
  block = tagMalloc(state, size, 1)
  if block is void then return error(1621, "Z_Malloc: failed on allocation of " + size + " bytes") end if
  return block
end function

/// Implements the `free` operation for `miniquake.zone` (free).
/// @param block The block input consumed by `free`.
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

/// Release state for free memory.
/// @param state Mutable `miniquake.zone` state used by `freeMemory`.
function freeMemory(state)
  total = 0
  for each block in state.blocks
    if block.tag == 0 then total = total + block.span end if
  end for
  return total
end function

/// Format and emit heap.
/// @param state Mutable `miniquake.zone` state used by `printHeap`.
function printHeap(state)
  text = "zone size: " + state.capacity
  for each block in state.blocks
    text = text + "\nblock:" + block.start + " size:" + block.span + " tag:" + block.tag
  end for
  return text
end function

/// Implements the `dumpHeap` operation for `miniquake.zone` (dump heap).
/// @param state Mutable `miniquake.zone` state used by `dumpHeap`.
function dumpHeap(state)
  return printHeap(state)
end function

/// Explicit zone.c/header entry points. The zone state parameter replaces the
/// original process-global mainzone pointer.
/// @param state Mutable `miniquake.zone` state used by `Z_ClearZone`.
/// @param size Size of the requested data or resource.
function Z_ClearZone(state, size)
  return clear(state, size)
end function

/// Mirror Quake's Z_Free routine and its observable state changes.
/// @param block The block input consumed by `Z_Free`.
function Z_Free(block)
  return free(block)
end function

/// Mirror Quake's Z_Malloc routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_Malloc`.
/// @param size Size of the requested data or resource.
function Z_Malloc(state, size)
  return malloc(state, size)
end function

/// Mirror Quake's Z_TagMalloc routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_TagMalloc`.
/// @param size Size of the requested data or resource.
/// @param tag The tag input consumed by `Z_TagMalloc`.
function Z_TagMalloc(state, size, tag)
  return tagMalloc(state, size, tag)
end function

/// Mirror Quake's Z_Print routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_Print`.
function Z_Print(state)
  return printHeap(state)
end function

/// Mirror Quake's Z_DumpHeap routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_DumpHeap`.
function Z_DumpHeap(state)
  return dumpHeap(state)
end function

/// Mirror Quake's Z_CheckHeap routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_CheckHeap`.
function Z_CheckHeap(state)
  return check(state)
end function

/// Mirror Quake's Z_FreeMemory routine and its observable state changes.
/// @param state Mutable `miniquake.zone` state used by `Z_FreeMemory`.
function Z_FreeMemory(state)
  return freeMemory(state)
end function
