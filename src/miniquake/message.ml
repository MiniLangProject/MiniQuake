package miniquake.message

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.sizebuf as sz
import miniquake.native as native
import miniquake.protocol_text as protocolText

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

function writeChar(buffer, value)
  integer = integerArgument(value, "MSG_WriteChar")
  offset = sz.getSpace(buffer, 1)
  bio.putI8(buffer.data, offset, integer)
end function

function writeByte(buffer, value)
  integer = integerArgument(value, "MSG_WriteByte")
  offset = sz.getSpace(buffer, 1)
  bio.putU8(buffer.data, offset, integer)
end function

function writeShort(buffer, value)
  integer = integerArgument(value, "MSG_WriteShort")
  offset = sz.getSpace(buffer, 2)
  bio.putI16(buffer.data, offset, integer)
end function

function writeLong(buffer, value)
  integer = integerArgument(value, "MSG_WriteLong")
  offset = sz.getSpace(buffer, 4)
  bio.putI32(buffer.data, offset, integer)
end function

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

function writeFloat(buffer, value)
  rounded = floatArgument(value, "MSG_WriteFloat")
  offset = sz.getSpace(buffer, 4)
  bio.putF32(buffer.data, offset, rounded)
end function

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

function writeString(buffer, text)
  return writeStringBytes(buffer, protocolText.encodeBytes(text))
end function

function writeCoord(buffer, value)
  rounded = floatArgument(value, "MSG_WriteCoord")
  writeShort(buffer, native.trunc(rounded * 8.0))
end function

function writeAngle(buffer, value)
  // common.c converts the function argument to float first, then casts the
  // angle itself before multiplying by 256/360.
  rounded = floatArgument(value, "MSG_WriteAngle")
  writeByte(buffer, native.trunc((native.trunc(rounded) * 256) / 360) & 255)
end function

function beginReading(buffer)
  return t.MessageReader(slice(buffer.data, 0, buffer.curSize), 0, false)
end function

function beginReadingBytes(data)
  return t.MessageReader(data, 0, false)
end function

function need(reader, count)
  if reader.readCount + count > len(reader.data) then
    reader.badRead = true
    return false
  end if
  return true
end function

function readChar(reader)
  if not need(reader, 1) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 1
  return bio.i8(reader.data, offset)
end function

function readByte(reader)
  if not need(reader, 1) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 1
  return bio.u8(reader.data, offset)
end function

function readShort(reader)
  if not need(reader, 2) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 2
  return bio.i16(reader.data, offset)
end function

function readUnsignedShort(reader)
  if not need(reader, 2) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 2
  return bio.u16(reader.data, offset)
end function

function readLong(reader)
  if not need(reader, 4) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.i32(reader.data, offset)
end function

function readUnsignedLong(reader)
  if not need(reader, 4) then return -1 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.u32(reader.data, offset)
end function

function readFloat(reader)
  // The 1.09 source omitted this bounds check.  Returning the same sentinel
  // used by the integer readers is the memory-safe platform divergence.
  if not need(reader, 4) then return -1.0 end if
  offset = reader.readCount
  reader.readCount = reader.readCount + 4
  return bio.f32(reader.data, offset)
end function

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

function readString(reader)
  return protocolText.decodeBytes(readStringBytes(reader))
end function

function readCoord(reader)
  return readShort(reader) * 0.125
end function

function readAngle(reader)
  return readChar(reader) * (360.0 / 256.0)
end function

function inline remaining(reader)
  return len(reader.data) - reader.readCount
end function

// Direct pendants for the message section of WinQuake/common.c.
function MSG_WriteChar(buffer, value)
  return writeChar(buffer, value)
end function

function MSG_WriteByte(buffer, value)
  return writeByte(buffer, value)
end function

function MSG_WriteShort(buffer, value)
  return writeShort(buffer, value)
end function

function MSG_WriteLong(buffer, value)
  return writeLong(buffer, value)
end function

function MSG_WriteFloat(buffer, value)
  return writeFloat(buffer, value)
end function

function MSG_WriteString(buffer, text)
  return writeString(buffer, text)
end function

function MSG_WriteCoord(buffer, value)
  return writeCoord(buffer, value)
end function

function MSG_WriteAngle(buffer, value)
  return writeAngle(buffer, value)
end function

function MSG_BeginReading(buffer)
  return beginReading(buffer)
end function

function MSG_ReadChar(reader)
  return readChar(reader)
end function

function MSG_ReadByte(reader)
  return readByte(reader)
end function

function MSG_ReadShort(reader)
  return readShort(reader)
end function

function MSG_ReadLong(reader)
  return readLong(reader)
end function

function MSG_ReadFloat(reader)
  return readFloat(reader)
end function

function MSG_ReadString(reader)
  return readString(reader)
end function

function MSG_ReadCoord(reader)
  return readCoord(reader)
end function

function MSG_ReadAngle(reader)
  return readAngle(reader)
end function
