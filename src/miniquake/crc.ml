/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang pendant for WinQuake/crc.c and crc.h.
*/
package miniquake.crc

/// Defines the crc init value value used by `miniquake.crc`.
const CRC_INIT_VALUE = 0xffff
/// Defines the crc xor value value used by `miniquake.crc`.
const CRC_XOR_VALUE = 0x0000
/// Defines the crc polynomial value used by `miniquake.crc`.
const CRC_POLYNOMIAL = 0x1021

// Compute crc init.
function inline CRC_Init()
  return CRC_INIT_VALUE
end function

/// crc.c uses a 256-entry lookup table.  This bitwise form produces that exact
/// non-reflected CCITT transition while retaining unsigned-short truncation.
/// @param crcValue The crc value input consumed by `CRC_ProcessByte`.
/// @param data Input data consumed by the operation.
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

/// Compute crc value.
/// @param crcValue The crc value input consumed by `CRC_Value`.
function CRC_Value(crcValue)
  return (crcValue ^ CRC_XOR_VALUE) & 0xffff
end function

/// Compute crc block.
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
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

/// Existing idiomatic aliases retained for already-ported callers.
/// @param value Value consumed by `processByte`.
/// @param data Input data consumed by the operation.
function processByte(value, data)
  return CRC_ProcessByte(value, data)
end function

/// Implements the `block` operation for `miniquake.crc` (block).
/// @param data Input data consumed by the operation.
/// @param offset Zero-based offset of the requested data.
/// @param count Number of entries or units to process.
function block(data, offset, count)
  return CRC_Block(data, offset, count)
end function
