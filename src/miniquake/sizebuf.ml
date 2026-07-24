package miniquake.sizebuf

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.memory as memory

function alloc(maxSize)
  if maxSize < 0 then return error(1200, "negative size buffer") end if
  return t.SizeBuffer(bytes(maxSize), maxSize, 0, false, false)
end function

function allocHunk(startSize)
  if startSize < 256 then startSize = 256 end if
  return alloc(startSize)
end function

function allocHunkManaged(memoryState, startSize)
  if startSize < 256 then startSize = 256 end if
  block = memory.hunkAllocName(memoryState, startSize, "sizebuf")
  buffer = t.SizeBuffer(block.data, startSize, 0, false, false)
  return [buffer, block]
end function

function allocOverflowing(maxSize)
  buffer = alloc(maxSize)
  buffer.allowOverflow = true
  return buffer
end function

function clear(buffer)
  buffer.curSize = 0
  return buffer
end function

function free(buffer)
  // SZ_Free did not release its hunk allocation in GLQuake 1.09; only the
  // logical contents became empty.
  buffer.curSize = 0
  return buffer
end function

function getSpace(buffer, count)
  if count < 0 then return error(1201, "negative size request") end if
  if buffer.curSize + count > buffer.maxSize then
    if not buffer.allowOverflow then return error(1202, "SZ_GetSpace overflow") end if
    if count > buffer.maxSize then return error(1203, "SZ_GetSpace request exceeds buffer") end if
    clear(buffer)
    buffer.overflowed = true
  end if
  offset = buffer.curSize
  buffer.curSize = buffer.curSize + count
  return offset
end function

function write(buffer, source, sourceOffset, count)
  offset = getSpace(buffer, count)
  bio.copyInto(buffer.data, offset, source, sourceOffset, count)
  return offset
end function

function writeBytes(buffer, source)
  return write(buffer, source, 0, len(source))
end function

function printText(buffer, text)
  encoded = bytes(text)
  if buffer.curSize > 0 and buffer.data[buffer.curSize - 1] == 0 then
    buffer.curSize = buffer.curSize - 1
  end if
  writeBytes(buffer, encoded)
  offset = getSpace(buffer, 1)
  buffer.data[offset] = 0
  return offset
end function

function dataSlice(buffer)
  return slice(buffer.data, 0, buffer.curSize)
end function

// Direct pendants for the size-buffer section of WinQuake/common.c.
function SZ_Alloc(startSize)
  return allocHunk(startSize)
end function

function SZ_Free(buffer)
  return free(buffer)
end function

function SZ_Clear(buffer)
  return clear(buffer)
end function

function SZ_GetSpace(buffer, count)
  return getSpace(buffer, count)
end function

function SZ_Write(buffer, source, sourceOffset, count)
  return write(buffer, source, sourceOffset, count)
end function

function SZ_Print(buffer, text)
  return printText(buffer, text)
end function
