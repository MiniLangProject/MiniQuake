/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.sizebuf.
*/
package miniquake.sizebuf

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.memory as memory
import miniquake.protocol_text as protocolText

/// Create and initialize the requested value.
/// @param maxSize Size of the requested data or resource.
function alloc(maxSize)
  if maxSize < 0 then return error(1200, "negative size buffer") end if
  return t.SizeBuffer(bytes(maxSize), maxSize, 0, false, false)
end function

/// Create and initialize hunk.
/// @param startSize Size of the requested data or resource.
function allocHunk(startSize)
  if startSize < 256 then startSize = 256 end if
  return alloc(startSize)
end function

/// Create and initialize hunk managed.
/// @param memoryState Mutable state used by `allocHunkManaged`.
/// @param startSize Size of the requested data or resource.
function allocHunkManaged(memoryState, startSize)
  if startSize < 256 then startSize = 256 end if
  block = memory.hunkAllocName(memoryState, startSize, "sizebuf")
  buffer = t.SizeBuffer(block.data, startSize, 0, false, false)
  return [buffer, block]
end function

/// Create and initialize overflowing.
/// @param maxSize Size of the requested data or resource.
function allocOverflowing(maxSize)
  buffer = alloc(maxSize)
  buffer.allowOverflow = true
  return buffer
end function

/// Implements the `clear` operation for `miniquake.sizebuf` (clear).
/// @param buffer The buffer input consumed by `clear`.
function clear(buffer)
  buffer.curSize = 0
  return buffer
end function

/// Implements the `free` operation for `miniquake.sizebuf` (free).
/// @param buffer The buffer input consumed by `free`.
function free(buffer)
  // SZ_Free did not release its hunk allocation in MiniQuake 1.09; only the
  // logical contents became empty.
  buffer.curSize = 0
  return buffer
end function

/// Return space.
/// @param buffer The buffer input consumed by `getSpace`.
/// @param count Number of entries or units to process.
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

/// Implements the `write` operation for `miniquake.sizebuf` (write).
/// @param buffer The buffer input consumed by `write`.
/// @param source Source value or collection to read.
/// @param sourceOffset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
function write(buffer, source, sourceOffset, count)
  offset = getSpace(buffer, count)
  bio.copyInto(buffer.data, offset, source, sourceOffset, count)
  return offset
end function

/// Writes bytes for `miniquake.sizebuf`.
/// @param buffer The buffer input consumed by `writeBytes`.
/// @param source Source value or collection to read.
function writeBytes(buffer, source)
  return write(buffer, source, 0, len(source))
end function

/// Encode and write encoded cstring at.
/// @param buffer The buffer input consumed by `writeEncodedCStringAt`.
/// @param encoded The encoded input consumed by `writeEncodedCStringAt`.
/// @param count Number of entries or units to process.
/// @param offset Zero-based offset of the requested data.
function writeEncodedCStringAt(buffer, encoded, count, offset)
  if count > 0 then bio.copyInto(buffer.data, offset, encoded, 0, count) end if
  buffer.data[offset + count] = 0
  return offset + count
end function

/// Format and emit text.
/// @param buffer The buffer input consumed by `printText`.
/// @param text Text to parse or process.
function printText(buffer, text)
  // SZ_Print consumes the same raw one-byte C string representation as
  // MSG_WriteString. Stop at embedded NUL and never leak UTF-8 multibyte data
  // into the command or network buffers.
  encoded = protocolText.encodeBytes(text)
  count = len(encoded)
  replacesTerminator = buffer.curSize > 0 and buffer.data[buffer.curSize - 1] == 0

  if replacesTerminator and buffer.curSize + count <= buffer.maxSize then
    // Original valid path: reserve strlen bytes, then copy strlen+1 starting one
    // byte earlier so the old terminator is replaced.
    offset = getSpace(buffer, count) - 1
    return writeEncodedCStringAt(buffer, encoded, count, offset)
  else if replacesTerminator and buffer.curSize + count > buffer.maxSize then
    // The original clears the buffer in SZ_GetSpace and then subtracts one from
    // the returned base pointer. That writes before data[0]. Define this invalid
    // overflow edge as a safe restart containing the complete new C string.
    if not buffer.allowOverflow then return error(1202, "SZ_GetSpace overflow") end if
    if count + 1 > buffer.maxSize then return error(1203, "SZ_GetSpace request exceeds buffer") end if
    clear(buffer)
    buffer.overflowed = true
    offset = getSpace(buffer, count + 1)
    return writeEncodedCStringAt(buffer, encoded, count, offset)
  else
    // Original no-terminator path reserves strlen+1 atomically. This matters at
    // an overflow boundary; splitting payload and NUL into two reservations is
    // not equivalent.
    offset = getSpace(buffer, count + 1)
    return writeEncodedCStringAt(buffer, encoded, count, offset)
  end if
end function

/// Implements the `dataSlice` operation for `miniquake.sizebuf` (data slice).
/// @param buffer The buffer input consumed by `dataSlice`.
function dataSlice(buffer)
  return slice(buffer.data, 0, buffer.curSize)
end function

/// Direct pendants for the size-buffer section of WinQuake/common.c.
/// @param startSize Size of the requested data or resource.
function SZ_Alloc(startSize)
  return allocHunk(startSize)
end function

/// Mirror Quake's SZ_Free routine and its observable state changes.
/// @param buffer The buffer input consumed by `SZ_Free`.
function SZ_Free(buffer)
  return free(buffer)
end function

/// Mirror Quake's SZ_Clear routine and its observable state changes.
/// @param buffer The buffer input consumed by `SZ_Clear`.
function SZ_Clear(buffer)
  return clear(buffer)
end function

/// Mirror Quake's SZ_GetSpace routine and its observable state changes.
/// @param buffer The buffer input consumed by `SZ_GetSpace`.
/// @param count Number of entries or units to process.
function SZ_GetSpace(buffer, count)
  return getSpace(buffer, count)
end function

/// Mirror Quake's SZ_Write routine and its observable state changes.
/// @param buffer The buffer input consumed by `SZ_Write`.
/// @param source Source value or collection to read.
/// @param sourceOffset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
function SZ_Write(buffer, source, sourceOffset, count)
  return write(buffer, source, sourceOffset, count)
end function

/// Mirror Quake's SZ_Print routine and its observable state changes.
/// @param buffer The buffer input consumed by `SZ_Print`.
/// @param text Text to parse or process.
function SZ_Print(buffer, text)
  return printText(buffer, text)
end function
