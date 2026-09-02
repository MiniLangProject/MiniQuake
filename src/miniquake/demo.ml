/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.demo.
*/
package miniquake.demo

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.constants as c
import miniquake.array_util as arrays
import miniquake.native as native
import std.fs as fs

/// Report whether suffix insensitive.
/// @param text Text to parse or process.
/// @param suffix The suffix input consumed by `hasSuffixInsensitive`.
function hasSuffixInsensitive(text, suffix)
  if len(bytes(text)) < len(bytes(suffix)) then return false end if
  start = len(bytes(text)) - len(bytes(suffix))
  return bio.lower(decode(slice(bytes(text), start, len(bytes(suffix))))) == bio.lower(suffix)
end function

/// Implements the `filename` operation for `miniquake.demo` (filename).
/// @param name Stable name that identifies the requested object or option.
function filename(name)
  if name == "" then return error(3720, "empty demo name") end if
  data = bytes(name)
  index = 0
  while index < len(data)
    if data[index] == 46 and index + 1 < len(data) and data[index + 1] == 46 then return error(3721, "relative demo paths are not allowed") end if
    index = index + 1
  end while
  if hasSuffixInsensitive(name, ".dem") then return name end if
  return name + ".dem"
end function

/// CL_Record_f uses the C library atoi, not MiniLang toNumber/Q_atof.  It
/// skips leading ASCII whitespace, accepts an optional sign, consumes the
/// initial decimal digit run and returns zero when no digits are present.
/// @param text Text to parse or process.
function recordTrackNumber(text)
  data = bytes(text)
  index = 0
  while index < len(data) and (data[index] == 32 or (data[index] >= 9 and data[index] <= 13))
    index = index + 1
  end while
  sign = 1
  if index < len(data) and data[index] == 45 then
    sign = -1
    index = index + 1
  else if index < len(data) and data[index] == 43 then
    index = index + 1
  end if
  value = 0
  while index < len(data) and data[index] >= 48 and data[index] <= 57
    value = value * 10 + data[index] - 48
    index = index + 1
  end while
  return value * sign
end function

/// Report whether is keepalive payload.
/// @param payload The payload input consumed by `isKeepalivePayload`.
function isKeepalivePayload(payload)
  return payload is bytes and len(payload) == 1 and payload[0] == c.SVC_NOP
end function

/// Read and validate track.
/// @param data Input data consumed by the operation.
function parseTrack(data)
  i = 0
  while i < len(data) and data[i] != 10
    i = i + 1
  end while
  if i >= len(data) then return error(2000, "demo track header is missing newline") end if
  // MiniQuake deliberately does not call atoi here: every non-minus byte before
  // the newline participates in `forcetrack = forcetrack * 10 + (c - '0')`.
  // Retain that odd but observable retail-demo behavior byte for byte.
  value = 0
  negative = false
  index = 0
  while index < i
    item = data[index]
    if item == 45 then negative = true else value = value * 10 + (item - 48) end if
    index = index + 1
  end while
  if negative then value = -value end if
  return [value, i + 1, decode(slice(data, 0, i + 1))]
end function

/// Implements the `parse` operation for `miniquake.demo` (parse).
/// @param data Input data consumed by the operation.
function parse(data)
  track = parseTrack(data)
  forcedTrack = track[0]
  firstMessageOffset = track[1]
  trackHeader = track[2]
  offset = firstMessageOffset
  messageCount = 0
  // Validate and count first.  The previous repeated array concatenation
  // copied the complete prefix for every demo message and produced enough
  // short-lived arrays to expose partially rooted nested constructors during
  // long demo loops.
  while offset < len(data)
    if offset + 16 > len(data) then return error(2002, "truncated demo message header") end if
    length = bio.i32(data, offset)
    if length < 0 or length > c.MAX_MSGLEN or offset + 16 + length > len(data) then return error(2003, "invalid demo message length") end if
    offset = offset + 16 + length
    messageCount = messageCount + 1
  end while

  messages = arrays.makeEmptyArray(messageCount)
  offset = firstMessageOffset
  messageIndex = 0
  while messageIndex < messageCount
    length = bio.i32(data, offset)
    angleX = bio.f32(data, offset + 4)
    angleY = bio.f32(data, offset + 8)
    angleZ = bio.f32(data, offset + 12)
    angles = t.Vec3(angleX, angleY, angleZ)
    payload = slice(data, offset + 16, length)
    message = t.DemoMessage(angles, payload)
    messages[messageIndex] = message
    offset = offset + 16 + length
    messageIndex = messageIndex + 1
  end while
  return t.Demo(forcedTrack, messages, trackHeader)
end function

/// Implements the `load` operation for `miniquake.demo` (load).
/// @param filename Path of the file to process.
function load(filename)
  return parse(fs.readAllBytes(filename))
end function

/// Implements the `serialize` operation for `miniquake.demo` (serialize).
/// @param recording The recording input consumed by `serialize`.
function serialize(recording)
  headerText = recording.trackHeader
  if headerText is void or headerText == "" then headerText = "" + recording.forcedTrack + "\n" end if
  header = bytes(headerText)
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

/// Implements the `save` operation for `miniquake.demo` (save).
/// @param filename Path of the file to process.
/// @param recording The recording input consumed by `save`.
function save(filename, recording)
  return fs.writeAllBytes(filename, serialize(recording))
end function

/// Apply the Quake-compatible cl write demo message behavior.
/// @param recording The recording input consumed by `CL_WriteDemoMessage`.
/// @param payload The payload input consumed by `CL_WriteDemoMessage`.
/// @param viewAngles The view angles input consumed by `CL_WriteDemoMessage`.
function CL_WriteDemoMessage(recording, payload, viewAngles)
  if recording is void then return error(2010, "CL_WriteDemoMessage: not recording") end if
  if len(payload) > c.MAX_MSGLEN then return error(2011, "Demo message > MAX_MSGLEN") end if
  copiedAngles = t.Vec3(
    native.bitsFloat(native.floatBits(viewAngles.x)),
    native.bitsFloat(native.floatBits(viewAngles.y)),
    native.bitsFloat(native.floatBits(viewAngles.z)),
  )
  copiedPayload = slice(payload, 0, len(payload))
  recording.messages = recording.messages + [t.DemoMessage(copiedAngles, copiedPayload)]
  return len(recording.messages)
end function

/// Apply the Quake-compatible cl stop f behavior.
/// @param recording The recording input consumed by `CL_Stop_f`.
/// @param viewAngles The view angles input consumed by `CL_Stop_f`.
function CL_Stop_f(recording, viewAngles)
  if recording is void then return error(2012, "Not recording a demo.") end if
  disconnect = bytes(1)
  disconnect[0] = c.SVC_DISCONNECT
  written = CL_WriteDemoMessage(recording, disconnect, viewAngles)
  if written is error then return written end if
  return recording
end function

/// Apply the Quake-compatible cl record f behavior.
/// @param arguments Command-line arguments to inspect or execute.
/// @param connected The connected input consumed by `CL_Record_f`.
function CL_Record_f(arguments, connected)
  if len(arguments) != 2 and len(arguments) != 3 and len(arguments) != 4 then
    return error(2013, "record <demoname> [<map> [cd track]]")
  end if
  if len(arguments) == 2 and connected then
    return error(2014, "Can not record - already connected to server")
  end if
  name = filename(arguments[1])
  if name is error then return name end if
  track = -1
  if len(arguments) == 4 then track = recordTrackNumber(arguments[3]) end if
  mapName = ""
  if len(arguments) > 2 then mapName = arguments[2] end if
  return [name, t.Demo(track, [], "" + track + "\n"), mapName]
end function

/// Apply the Quake-compatible cl play demo f behavior.
/// @param data Input data consumed by the operation.
function CL_PlayDemo_f(data)
  return parse(data)
end function
