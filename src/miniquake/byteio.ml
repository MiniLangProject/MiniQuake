/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.byteio.
*/
package miniquake.byteio

import miniquake.native as native
import miniquake.protocol_text as quakeText

// Validate range and report any invalid state.
function requireRange(data, offset, count)
  if typeof(data) != "bytes" then return error(1000, "byte buffer required") end if
  if offset < 0 or count < 0 or offset + count > len(data) then
    return error(1001, "byte range outside buffer")
  end if
  return true
end function

// Read an unsigned 8-bit value from the byte buffer.
function inline u8(data, offset)
  requireRange(data, offset, 1)
  return data[offset]
end function

// Read a signed 8-bit value from the byte buffer.
function inline i8(data, offset)
  value = u8(data, offset)
  if value >= 128 then value = value - 256 end if
  return value
end function

// Read a little-endian unsigned 16-bit value from the byte buffer.
function inline u16(data, offset)
  requireRange(data, offset, 2)
  return data[offset] | (data[offset + 1] << 8)
end function

// Read a little-endian signed 16-bit value from the byte buffer.
function inline i16(data, offset)
  value = u16(data, offset)
  if value >= 0x8000 then value = value - 0x10000 end if
  return value
end function

// Read a little-endian unsigned 32-bit value from the byte buffer.
function u32(data, offset)
  requireRange(data, offset, 4)
  return data[offset] |
    (data[offset + 1] << 8) |
    (data[offset + 2] << 16) |
    (data[offset + 3] << 24)
end function

// Read a little-endian signed 32-bit value from the byte buffer.
function i32(data, offset)
  value = u32(data, offset)
  if value >= 0x80000000 then value = value - 0x100000000 end if
  return value
end function

// Read an IEEE-754 single-precision value from the byte buffer.
function inline f32(data, offset)
  return native.bitsFloat(u32(data, offset))
end function

// Encode and write u8.
function inline putU8(data, offset, value)
  requireRange(data, offset, 1)
  data[offset] = value & 255
  return offset + 1
end function

// Encode and write i8.
function inline putI8(data, offset, value)
  return putU8(data, offset, value)
end function

// Encode and write u16.
function inline putU16(data, offset, value)
  requireRange(data, offset, 2)
  data[offset] = value & 255
  data[offset + 1] = (value >> 8) & 255
  return offset + 2
end function

// Encode and write i16.
function inline putI16(data, offset, value)
  return putU16(data, offset, value)
end function

// Encode and write u32.
function putU32(data, offset, value)
  requireRange(data, offset, 4)
  data[offset] = value & 255
  data[offset + 1] = (value >> 8) & 255
  data[offset + 2] = (value >> 16) & 255
  data[offset + 3] = (value >> 24) & 255
  return offset + 4
end function

// Encode and write i32.
function putI32(data, offset, value)
  return putU32(data, offset, value)
end function

// Encode and write f32.
function inline putF32(data, offset, value)
  return putU32(data, offset, native.floatBits(value))
end function

// Convert byte order for short swap.
function shortSwap(value)
  swapped = ((value & 255) << 8) | ((value >> 8) & 255)
  if swapped >= 0x8000 then swapped = swapped - 0x10000 end if
  return swapped
end function

// Convert byte order for short no swap.
function shortNoSwap(value)
  narrowed = value & 0xffff
  if narrowed >= 0x8000 then return narrowed - 0x10000 end if
  return narrowed
end function

// Convert byte order for long swap.
function longSwap(value)
  swapped = ((value & 255) << 24) |
    (((value >> 8) & 255) << 16) |
    (((value >> 16) & 255) << 8) |
    ((value >> 24) & 255)
  if swapped >= 0x80000000 then swapped = swapped - 0x100000000 end if
  return swapped
end function

// Convert byte order for long no swap.
function longNoSwap(value)
  narrowed = value & 0xffffffff
  if narrowed >= 0x80000000 then return narrowed - 0x100000000 end if
  return narrowed
end function

// Convert byte order for float swap.
function floatSwap(value)
  return native.bitsFloat(longSwap(native.floatBits(value)) & 0xffffffff)
end function

// Convert byte order for float no swap.
function floatNoSwap(value)
  return native.bitsFloat(native.floatBits(value))
end function

// MiniQuake's supported release platform is little-endian Windows x64.
function bigShort(value)
  return shortSwap(value)
end function

// Convert byte order for little short.
function littleShort(value)
  return shortNoSwap(value)
end function

// Convert byte order for big long.
function bigLong(value)
  return longSwap(value)
end function

// Convert byte order for little long.
function littleLong(value)
  return longNoSwap(value)
end function

// Convert byte order for big float.
function bigFloat(value)
  return floatSwap(value)
end function

// Convert byte order for little float.
function littleFloat(value)
  return floatNoSwap(value)
end function

// Transfer data for copy into.
function copyInto(destination, destinationOffset, source, sourceOffset, count)
  requireRange(destination, destinationOffset, count)
  requireRange(source, sourceOffset, count)
  i = 0
  while i < count
    destination[destinationOffset + i] = source[sourceOffset + i]
    i = i + 1
  end while
  return destinationOffset + count
end function

// Provide fixed string behavior for the active subsystem.
function fixedString(data, offset, count)
  requireRange(data, offset, count)
  length = 0
  while length < count and data[offset + length] != 0
    length = length + 1
  end while
  return quakeText.decodeBytes(slice(data, offset, length))
end function

// Provide c string behavior for the active subsystem.
function cString(data, offset)
  if offset < 0 or offset > len(data) then return error(1002, "string offset outside buffer") end if
  endOffset = offset
  while endOffset < len(data) and data[endOffset] != 0
    endOffset = endOffset + 1
  end while
  return quakeText.decodeBytes(slice(data, offset, endOffset - offset))
end function

// Convert data for lower.
function lower(text)
  source = bytes(text)
  output = bytes(len(source))
  i = 0
  while i < len(source)
    value = source[i]
    if value >= 65 and value <= 90 then value = value + 32 end if
    output[i] = value
    i = i + 1
  end while
  return decode(output)
end function

// Check equal insensitive.
function equalInsensitive(a, b)
  return lower(a) == lower(b)
end function

// Provide four cc behavior for the active subsystem.
function fourCC(data, offset)
  requireRange(data, offset, 4)
  return decode(slice(data, offset, 4))
end function
