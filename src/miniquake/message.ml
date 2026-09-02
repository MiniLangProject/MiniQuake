/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.message.
*/
package miniquake.message

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.sizebuf as sz
import miniquake.native as native
import miniquake.protocol_text as protocolText

/// Implements the `integerArgument` operation for `miniquake.message` (integer argument).
/// @param value Value consumed by `integerArgument`.
/// @param operation The operation input consumed by `integerArgument`.
function integerArgument(value, operation)
  // The original MSG_WriteChar/Byte/Short/Long functions take an int. C therefore
  // truncates Quake's float usercmd fields before the byte-wise masks and shifts.
  // qboolean is also an int in the original ABI.
  if value is int then return value end if
  if value is float then return native.trunc(value) end if
  if value is bool then
    if value then return 1 end if
    return 0
  end if
  return error(1301, operation + ": numeric argument required")
end function

/// Encode and write char.
/// @param buffer The buffer input consumed by `writeChar`.
/// @param value Value consumed by `writeChar`.
function writeChar(buffer, value)
  integer = integerArgument(value, "MSG_WriteChar")
  offset = sz.getSpace(buffer, 1)
  bio.putI8(buffer.data, offset, integer)
end function

/// Encode and write byte.
/// @param buffer The buffer input consumed by `writeByte`.
/// @param value Value consumed by `writeByte`.
function writeByte(buffer, value)
  integer = integerArgument(value, "MSG_WriteByte")
  offset = sz.getSpace(buffer, 1)
  bio.putU8(buffer.data, offset, integer)
end function

/// Encode and write short.
/// @param buffer The buffer input consumed by `writeShort`.
/// @param value Value consumed by `writeShort`.
function writeShort(buffer, value)
  integer = integerArgument(value, "MSG_WriteShort")
  offset = sz.getSpace(buffer, 2)
  bio.putI16(buffer.data, offset, integer)
end function

/// Encode and write long.
/// @param buffer The buffer input consumed by `writeLong`.
/// @param value Value consumed by `writeLong`.
function writeLong(buffer, value)
  integer = integerArgument(value, "MSG_WriteLong")
  offset = sz.getSpace(buffer, 4)
  bio.putI32(buffer.data, offset, integer)
end function

/// Implements the `floatArgument` operation for `miniquake.message` (float argument).
/// @param value Value consumed by `floatArgument`.
/// @param operation The operation input consumed by `floatArgument`.
function floatArgument(value, operation)
  // MSG_WriteFloat/Coord/Angle receive a C float. MiniLang integers therefore
  // also have to cross an IEEE-754 binary32 call boundary before any scaling
  // or truncation takes place.
  if value is int or value is float then
    return native.bitsFloat(native.floatBits(value))
  end if
  if value is bool then
    if value then return 1.0 end if
    return 0.0
  end if
  return error(1303, operation + ": numeric argument required")
end function

/// Encode and write float.
/// @param buffer The buffer input consumed by `writeFloat`.
/// @param value Value consumed by `writeFloat`.
function writeFloat(buffer, value)
  rounded = floatArgument(value, "MSG_WriteFloat")
  offset = sz.getSpace(buffer, 4)
  bio.putF32(buffer.data, offset, rounded)
end function

/// Encode and write string bytes.
/// @param buffer The buffer input consumed by `writeStringBytes`.
/// @param data Input data consumed by the operation.
function writeStringBytes(buffer, data)
  if data is not bytes then return error(1302, "MSG_WriteString requires bytes") end if
  count = 0
  while count < len(data) and data[count] != 0
    count = count + 1
  end while

  // common.c performs one SZ_Write of Q_strlen(s)+1 bytes. Keeping payload and
  // terminator in one reservation is observable when an overflow-enabled buffer
  // has room for the payload but not for its trailing NUL.
  offset = sz.getSpace(buffer, count + 1)
  if count > 0 then bio.copyInto(buffer.data, offset, data, 0, count) end if
  buffer.data[offset + count] = 0
  return buffer
end function

/// Encode and write string.
/// @param buffer The buffer input consumed by `writeString`.
/// @param text Text to parse or process.
function writeString(buffer, text)
  return writeStringBytes(buffer, protocolText.encodeBytes(text))
end function

/// Encode and write coord.
/// @param buffer The buffer input consumed by `writeCoord`.
/// @param value Value consumed by `writeCoord`.
function writeCoord(buffer, value)
  rounded = floatArgument(value, "MSG_WriteCoord")
  writeShort(buffer, native.trunc(rounded * 8.0))
end function

/// Encode and write angle.
/// @param buffer The buffer input consumed by `writeAngle`.
/// @param value Value consumed by `writeAngle`.
function writeAngle(buffer, value)
  // common.c converts the function argument to float first, then casts the
  // angle itself before multiplying by 256/360.
  rounded = floatArgument(value, "MSG_WriteAngle")
  writeByte(buffer, native.trunc((native.trunc(rounded) * 256) / 360) & 255)
end function

/// Initialize state for begin reading.
/// @param buffer The buffer input consumed by `beginReading`.
function beginReading(buffer)
  return t.MessageReader(slice(buffer.data, 0, buffer.curSize), 0, false)
end function

/// Initialize state for begin reading bytes.
/// @param data Input data consumed by the operation.
function beginReadingBytes(data)
  return t.MessageReader(data, 0, false)
end function

/// Implements the `need` operation for `miniquake.message` (need).
/// @param reader The reader input consumed by `need`.
/// @param count Number of entries or units to process.
function need(reader, count)
  if reader.readCount + count > len(reader.data) then
    reader.badRead = true
    return false
  end if
  return true
end function

/// Read and validate char.
/// @param reader The reader input consumed by `readChar`.
function readChar(reader)
  if not need(reader, 1) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 1
  return bio.i8(reader.data, offset)
end function

/// Read and validate byte.
/// @param reader The reader input consumed by `readByte`.
function readByte(reader)
  if not need(reader, 1) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 1
  return bio.u8(reader.data, offset)
end function

/// Read and validate short.
/// @param reader The reader input consumed by `readShort`.
function readShort(reader)
  if not need(reader, 2) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 2
  return bio.i16(reader.data, offset)
end function

/// Read and validate unsigned short.
/// @param reader The reader input consumed by `readUnsignedShort`.
function readUnsignedShort(reader)
  if not need(reader, 2) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 2
  return bio.u16(reader.data, offset)
end function

/// Read and validate long.
/// @param reader The reader input consumed by `readLong`.
function readLong(reader)
  if not need(reader, 4) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.i32(reader.data, offset)
end function

/// Read and validate unsigned long.
/// @param reader The reader input consumed by `readUnsignedLong`.
function readUnsignedLong(reader)
  if not need(reader, 4) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.u32(reader.data, offset)
end function

/// Read and validate float.
/// @param reader The reader input consumed by `readFloat`.
function readFloat(reader)
  // The 1.09 source omitted this bounds check.  Returning the same sentinel
  // used by the integer readers is the memory-safe platform divergence.
  if not need(reader, 4) then return -1.0 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.f32(reader.data, offset)
end function

/// Read and validate string bytes.
/// @param reader The reader input consumed by `readStringBytes`.
function readStringBytes(reader)
  output = bytes(2047)
  count = 0
  while count < len(output)
    value = readChar(reader)
    if value == -1 or value == 0 then break end if
    output[count] = value & 255
    count = count + 1
  end while
  return slice(output, 0, count)
end function

/// Read and validate string.
/// @param reader The reader input consumed by `readString`.
function readString(reader)
  return protocolText.decodeBytes(readStringBytes(reader))
end function

/// Read and validate coord.
/// @param reader The reader input consumed by `readCoord`.
function readCoord(reader)
  return readShort(reader) * 0.125
end function

/// Read and validate angle.
/// @param reader The reader input consumed by `readAngle`.
function readAngle(reader)
  return readChar(reader) * (360.0 / 256.0)
end function

/// Implements the `remaining` operation for `miniquake.message` (remaining).
/// @param reader The reader input consumed by `remaining`.
function inline remaining(reader)
  return len(reader.data) - reader.readCount
end function

/// Direct pendants for the message section of WinQuake/common.c.
/// @param buffer The buffer input consumed by `MSG_WriteChar`.
/// @param value Value consumed by `MSG_WriteChar`.
function MSG_WriteChar(buffer, value)
  return writeChar(buffer, value)
end function

/// Mirror Quake's MSG_WriteByte routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteByte`.
/// @param value Value consumed by `MSG_WriteByte`.
function MSG_WriteByte(buffer, value)
  return writeByte(buffer, value)
end function

/// Mirror Quake's MSG_WriteShort routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteShort`.
/// @param value Value consumed by `MSG_WriteShort`.
function MSG_WriteShort(buffer, value)
  return writeShort(buffer, value)
end function

/// Mirror Quake's MSG_WriteLong routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteLong`.
/// @param value Value consumed by `MSG_WriteLong`.
function MSG_WriteLong(buffer, value)
  return writeLong(buffer, value)
end function

/// Mirror Quake's MSG_WriteFloat routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteFloat`.
/// @param value Value consumed by `MSG_WriteFloat`.
function MSG_WriteFloat(buffer, value)
  return writeFloat(buffer, value)
end function

/// Mirror Quake's MSG_WriteString routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteString`.
/// @param text Text to parse or process.
function MSG_WriteString(buffer, text)
  return writeString(buffer, text)
end function

/// Mirror Quake's MSG_WriteCoord routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteCoord`.
/// @param value Value consumed by `MSG_WriteCoord`.
function MSG_WriteCoord(buffer, value)
  return writeCoord(buffer, value)
end function

/// Mirror Quake's MSG_WriteAngle routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_WriteAngle`.
/// @param value Value consumed by `MSG_WriteAngle`.
function MSG_WriteAngle(buffer, value)
  return writeAngle(buffer, value)
end function

/// Mirror Quake's MSG_BeginReading routine and its observable state changes.
/// @param buffer The buffer input consumed by `MSG_BeginReading`.
function MSG_BeginReading(buffer)
  return beginReading(buffer)
end function

/// Mirror Quake's MSG_ReadChar routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadChar`.
function MSG_ReadChar(reader)
  return readChar(reader)
end function

/// Mirror Quake's MSG_ReadByte routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadByte`.
function MSG_ReadByte(reader)
  return readByte(reader)
end function

/// Mirror Quake's MSG_ReadShort routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadShort`.
function MSG_ReadShort(reader)
  return readShort(reader)
end function

/// Mirror Quake's MSG_ReadLong routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadLong`.
function MSG_ReadLong(reader)
  return readLong(reader)
end function

/// Mirror Quake's MSG_ReadFloat routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadFloat`.
function MSG_ReadFloat(reader)
  return readFloat(reader)
end function

/// Mirror Quake's MSG_ReadString routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadString`.
function MSG_ReadString(reader)
  return readString(reader)
end function

/// Mirror Quake's MSG_ReadCoord routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadCoord`.
function MSG_ReadCoord(reader)
  return readCoord(reader)
end function

/// Mirror Quake's MSG_ReadAngle routine and its observable state changes.
/// @param reader The reader input consumed by `MSG_ReadAngle`.
function MSG_ReadAngle(reader)
  return readAngle(reader)
end function
