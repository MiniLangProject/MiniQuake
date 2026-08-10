/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

MiniLang pendant for WinQuake/crc.c and crc.h.
*/

package miniquake.crc

const CRC_INIT_VALUE = 0xffff
const CRC_XOR_VALUE = 0x0000
const CRC_POLYNOMIAL = 0x1021

function inline CRC_Init()
  return CRC_INIT_VALUE
end function

// crc.c uses a 256-entry lookup table.  This bitwise form produces that exact
// non-reflected CCITT transition while retaining unsigned-short truncation.
function CRC_ProcessByte(crcValue, data)
  value = (crcValue & 0xffff) ^ ((data & 255) << 8)
  bit = 0
  while bit < 8
    if (value & 0x8000) != 0 then
      value = ((value << 1) ^ CRC_POLYNOMIAL) & 0xffff
    else
      value = (value << 1) & 0xffff
    end if
    bit = bit + 1
  end while
  return value
end function

function CRC_Value(crcValue)
  return (crcValue ^ CRC_XOR_VALUE) & 0xffff
end function

function CRC_Block(data, offset, count)
  if typeof(data) != "bytes" then return error(1100, "CRC input must be bytes") end if
  if offset < 0 or count < 0 or offset > len(data) or count > len(data) - offset then
    return error(1101, "CRC range outside buffer")
  end if
  value = CRC_Init()
  index = 0
  while index < count
    value = CRC_ProcessByte(value, data[offset + index])
    index = index + 1
  end while
  return CRC_Value(value)
end function

// Existing idiomatic aliases retained for already-ported callers.
function processByte(value, data)
  return CRC_ProcessByte(value, data)
end function

function block(data, offset, count)
  return CRC_Block(data, offset, count)
end function
