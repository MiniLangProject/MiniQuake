/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/crc_differential_fixture.ml.
*/
import miniquake.crc as crcPort

// Parse command-line arguments and run the selected operation.
function main(args)
  value = crcPort.CRC_Init()
  print "{\"function\":\"CRC_Init\",\"case\":\"initial\",\"value\":" + value + "}"

  first = crcPort.CRC_ProcessByte(value, 0x51)
  second = crcPort.CRC_ProcessByte(first, 0x75)
  third = crcPort.CRC_ProcessByte(second, 0x61)
  fourth = crcPort.CRC_ProcessByte(third, 0x6b)
  fifth = crcPort.CRC_ProcessByte(fourth, 0x65)
  print "{\"function\":\"CRC_ProcessByte\",\"case\":\"quake\",\"values\":[" +
    first + "," + second + "," + third + "," + fourth + "," + fifth + "]}"

  print "{\"function\":\"CRC_Value\",\"case\":\"quake\",\"value\":" +
    crcPort.CRC_Value(fifth) + "}"
  return 0
end function
