import miniquake.crc as crcPort

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
