/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Protocol-15 strings are byte-oriented C strings. MiniLang strings are UTF-8,
so sending bytes(text) directly changes every Quake character >= 0x80. This
module defines a reversible one-byte bridge: Unicode U+0000..U+00FF maps to
Quake byte 0x00..0xFF. Code points outside that range are rejected rather than
silently changing the wire format.
*/

package miniquake.protocol_text

const TEXT_ABI = "quake_latin1_cstring_v1"

function encodeBytes(text)
  if text is void then return bytes() end if
  if text is not string then return error(1310, "Quake C string requires string or void") end if

  source = bytes(text)
  output = bytes(len(source))
  sourceIndex = 0
  outputCount = 0

  while sourceIndex < len(source)
    first = source[sourceIndex]

    // Q_strlen stops at the first NUL even when a higher-level MiniLang string
    // happens to contain more data after it.
    if first == 0 then break end if

    if first < 0x80 then
      output[outputCount] = first
      outputCount = outputCount + 1
      sourceIndex = sourceIndex + 1
    else if first == 0xc2 or first == 0xc3 then
      if sourceIndex + 1 >= len(source) then
        return error(1311, "truncated UTF-8 sequence in Quake C string")
      end if
      continuation = source[sourceIndex + 1]
      if continuation < 0x80 or continuation > 0xbf then
        return error(1312, "invalid UTF-8 sequence in Quake C string")
      end if
      // Assign inside each branch. MiniLang uses lexical block scopes, so a
      // temporary first introduced inside either branch is not visible after
      // the if block. Writing the selected byte here also mirrors the simple
      // one-byte conversion performed by the C adapter.
      if first == 0xc2 then
        output[outputCount] = continuation
      else
        output[outputCount] = continuation + 0x40
      end if
      outputCount = outputCount + 1
      sourceIndex = sourceIndex + 2
    else
      return error(1313, "Quake C string contains a character outside U+0000..U+00FF")
    end if
  end while

  return slice(output, 0, outputCount)
end function

function decodeBytes(data)
  if data is not bytes then return error(1314, "Quake byte string requires bytes") end if

  // A Latin-1 code point needs at most two UTF-8 bytes.
  output = bytes(len(data) * 2)
  outputCount = 0
  index = 0
  while index < len(data)
    value = data[index]
    if value < 0x80 then
      output[outputCount] = value
      outputCount = outputCount + 1
    else if value < 0xc0 then
      output[outputCount] = 0xc2
      output[outputCount + 1] = value
      outputCount = outputCount + 2
    else
      output[outputCount] = 0xc3
      output[outputCount + 1] = value - 0x40
      outputCount = outputCount + 2
    end if
    index = index + 1
  end while

  decoded = decode(slice(output, 0, outputCount))
  if decoded is void then return error(1315, "cannot decode Quake byte string") end if
  return decoded
end function

function encodedLength(text)
  return len(encodeBytes(text))
end function

function roundTripBytes(data)
  return encodeBytes(decodeBytes(data))
end function

// Truncate by Quake bytes rather than MiniLang's UTF-8 storage bytes. This is
// the newName[15]=0 behavior needed by Host_Name_f while preserving every
// extended Quake byte 0x80..0xff.
function truncate(text, maximum)
  if maximum <= 0 then return "" end if
  encoded = encodeBytes(text)
  if len(encoded) <= maximum then return decodeBytes(encoded) end if
  return decodeBytes(slice(encoded, 0, maximum))
end function
