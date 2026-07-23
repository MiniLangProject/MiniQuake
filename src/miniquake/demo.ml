package miniquake.demo

import miniquake.types as t
import miniquake.byteio as bio
import std.fs as fs

function parseTrack(data)
  i = 0
  while i < len(data) and data[i] != 10
    i = i + 1
  end while
  if i >= len(data) then return error(2000, "demo track header is missing newline") end if
  text = decode(slice(data, 0, i))
  value = toNumber(text)
  if value is void then return error(2001, "invalid demo track") end if
  return [value, i + 1]
end function

function parse(data)
  track = parseTrack(data)
  forcedTrack = track[0]
  offset = track[1]
  messages = []
  while offset < len(data)
    if offset + 16 > len(data) then return error(2002, "truncated demo message header") end if
    length = bio.i32(data, offset)
    if length < 0 or offset + 16 + length > len(data) then return error(2003, "invalid demo message length") end if
    angles = t.Vec3(bio.f32(data, offset + 4), bio.f32(data, offset + 8), bio.f32(data, offset + 12))
    messages = messages + [t.DemoMessage(angles, slice(data, offset + 16, length))]
    offset = offset + 16 + length
  end while
  return t.Demo(forcedTrack, messages)
end function

function load(filename)
  return parse(fs.readAllBytes(filename))
end function

function serialize(recording)
  header = bytes("" + recording.forcedTrack + "\n")
  total = len(header)
  for each message in recording.messages
    total = total + 16 + len(message.payload)
  end for
  output = bytes(total)
  bio.copyInto(output, 0, header, 0, len(header))
  offset = len(header)
  for each message in recording.messages
    bio.putI32(output, offset, len(message.payload))
    bio.putF32(output, offset + 4, message.viewAngles.x)
    bio.putF32(output, offset + 8, message.viewAngles.y)
    bio.putF32(output, offset + 12, message.viewAngles.z)
    bio.copyInto(output, offset + 16, message.payload, 0, len(message.payload))
    offset = offset + 16 + len(message.payload)
  end for
  return output
end function

function save(filename, recording)
  return fs.writeAllBytes(filename, serialize(recording))
end function
