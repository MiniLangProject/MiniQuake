package miniquake.crc

function processByte(value, data)
  value = value ^ (data << 8)
  bit = 0
  while bit < 8
    if (value & 0x8000) != 0 then
      value = ((value << 1) ^ 0x1021) & 0xffff
    else
      value = (value << 1) & 0xffff
    end if
    bit = bit + 1
  end while
  return value
end function

function block(data, offset, count)
  if typeof(data) != "bytes" then return error(1100, "CRC input must be bytes") end if
  if offset < 0 or count < 0 or offset + count > len(data) then return error(1101, "CRC range outside buffer") end if
  value = 0xffff
  i = 0
  while i < count
    value = processByte(value, data[offset + i])
    i = i + 1
  end while
  return value
end function
