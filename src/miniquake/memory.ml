package miniquake.memory

import miniquake.types as t

function create(capacity)
  if capacity < 0 then return error(1600, "negative memory capacity") end if
  return t.MemoryState(capacity, [], 0)
end function

function used(state)
  total = 0
  for each block in state.blocks
    if block.alive then total = total + block.size end if
  end for
  return total
end function

function allocate(state, size, name, kind)
  if size < 0 then return error(1601, "negative allocation") end if
  if used(state) + size > state.capacity then return error(1602, "MiniQuake memory exhausted") end if
  block = t.MemoryBlock(kind, name, bytes(size), size, true, len(state.blocks))
  state.blocks = state.blocks + [block]
  state.totalAllocated = state.totalAllocated + size
  return block
end function

function lowMark(state)
  return len(state.blocks)
end function

function highMark(state)
  return len(state.blocks)
end function

function hunkAllocName(state, size, name)
  return allocate(state, size, name, "hunk")
end function

function zoneMalloc(state, size, name)
  return allocate(state, size, name, "zone")
end function

function zoneFree(block)
  if block is void then return end if
  block.alive = false
end function

function freeToLowMark(state, mark)
  if mark < 0 or mark > len(state.blocks) then return error(1603, "bad hunk mark") end if
  i = mark
  while i < len(state.blocks)
    state.blocks[i].alive = false
    i = i + 1
  end while
end function

function freeToHighMark(state, mark)
  return freeToLowMark(state, mark)
end function

function cacheAlloc(state, size, name)
  block = allocate(state, size, name, "cache")
  return t.CacheUser(block)
end function

function cacheCheck(state, user)
  if user is void or user.block is void or not user.block.alive then return void end if
  return user.block.data
end function

function cacheFree(user)
  if user is void or user.block is void then return end if
  user.block.alive = false
  user.block = void
end function
