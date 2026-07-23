package miniquake.message

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.sizebuf as sz
import miniquake.native as native

function integerArgument(value, operation)
  // The original MSG_WriteChar/Byte/Short/Long functions take an int. C therefore
  // truncates Quake's float usercmd fields before the byte-wise masks and shifts.
  // MiniLang keeps int and float distinct, so reproduce that conversion here at
  // the protocol boundary instead of letting a bitwise operation yield void.
  if value is int then return value end if
  if value is float then return native.trunc(value) end if
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

function writeFloat(buffer, value)
  offset = sz.getSpace(buffer, 4)
  bio.putF32(buffer.data, offset, value)
end function

function writeString(buffer, text)
  encoded = bytes(text)
  sz.writeBytes(buffer, encoded)
  writeByte(buffer, 0)
end function

function writeCoord(buffer, value)
  writeShort(buffer, native.trunc(value * 8.0))
end function

function writeAngle(buffer, value)
  writeByte(buffer, native.trunc(value * 256.0 / 360.0) & 255)
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
    return error(1300, "MSG_Read overflow")
  end if
  return reader.readCount
end function

function readChar(reader)
  offset = need(reader, 1)
  reader.readCount = reader.readCount + 1
  return bio.i8(reader.data, offset)
end function

function readByte(reader)
  offset = need(reader, 1)
  reader.readCount = reader.readCount + 1
  return bio.u8(reader.data, offset)
end function

function readShort(reader)
  offset = need(reader, 2)
  reader.readCount = reader.readCount + 2
  return bio.i16(reader.data, offset)
end function

function readUnsignedShort(reader)
  offset = need(reader, 2)
  reader.readCount = reader.readCount + 2
  return bio.u16(reader.data, offset)
end function

function readLong(reader)
  offset = need(reader, 4)
  reader.readCount = reader.readCount + 4
  return bio.i32(reader.data, offset)
end function

function readUnsignedLong(reader)
  offset = need(reader, 4)
  reader.readCount = reader.readCount + 4
  return bio.u32(reader.data, offset)
end function

function readFloat(reader)
  offset = need(reader, 4)
  reader.readCount = reader.readCount + 4
  return bio.f32(reader.data, offset)
end function

function readString(reader)
  output = bytes(2048)
  count = 0
  done = false
  while not done and reader.readCount < len(reader.data)
    value = readByte(reader)
    if value == 0 then
      done = true
    else if count < len(output) then
      output[count] = value
      count = count + 1
    end if
  end while
  if not done then reader.badRead = true end if
  return decode(slice(output, 0, count))
end function

function readCoord(reader)
  return readShort(reader) * 0.125
end function

function readAngle(reader)
  return readByte(reader) * (360.0 / 256.0)
end function

function remaining(reader)
  return len(reader.data) - reader.readCount
end function
