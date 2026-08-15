/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.common.
*/
package miniquake.common

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.constants as c
import miniquake.native as native
import miniquake.protocol_text as quakeText

// Update module state for link.
function clearLink(link)
  link.previous = link
  link.next = link
  return link
end function

// Release state for remove link.
function removeLink(link)
  link.next.previous = link.previous
  link.previous.next = link.next
  return link
end function

// Add state for insert link before.
function insertLinkBefore(link, before)
  link.next = before
  link.previous = before.previous
  link.previous.next = link
  link.next.previous = link
  return link
end function

// Add state for insert link after.
function insertLinkAfter(link, after)
  link.next = after.next
  link.previous = after
  link.previous.next = link
  link.next.previous = link
  return link
end function

// Provide hex digit behavior for the active subsystem.
function hexDigit(value)
  if value >= 48 and value <= 57 then return value - 48 end if
  if value >= 97 and value <= 102 then return value - 97 + 10 end if
  if value >= 65 and value <= 70 then return value - 65 + 10 end if
  return -1
end function

// Original Q_atof returns C float even though it accumulates through a double.
// Make the return boundary explicit so MiniLang wider precision cannot leak.
function quakeFloat(value)
  return native.bitsFloat(native.floatBits(value))
end function

// WinQuake Q_atoi stores all intermediate results in a signed 32-bit int.
// MSVC on the original target observes two's-complement wrapping here.
function quakeInt32(value)
  narrowed = native.trunc(value) & 0xffffffff
  if narrowed >= 0x80000000 then return narrowed - 0x100000000 end if
  return narrowed
end function

// Q_atof deliberately stops at the first non-number and supports Quake's
// hexadecimal and character literal forms. It is not the host language's
// stricter general-purpose number parser.
function atof(text)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  data = quakeText.encodeBytes(text)
  index = 0
  sign = 1.0
  if index < len(data) and data[index] == 45 then
    sign = -1.0
    index = index + 1
  end if

  if index + 1 < len(data) and data[index] == 48 and (data[index + 1] == 120 or data[index + 1] == 88) then
    index = index + 2
    value = 0.0
    while index < len(data)
      digit = hexDigit(data[index])
      if digit < 0 then return quakeFloat(value * sign) end if
      value = value * 16.0 + digit
      index = index + 1
    end while
    return quakeFloat(value * sign)
  end if

  if index < len(data) and data[index] == 39 then
    if index + 1 < len(data) then return quakeFloat(sign * data[index + 1]) end if
    return quakeFloat(0.0)
  end if

  value = 0.0
  decimal = -1
  total = 0
  while index < len(data)
    current = data[index]
    index = index + 1
    if current == 46 then
      decimal = total
      continue
    end if
    if current < 48 or current > 57 then break end if
    value = value * 10.0 + current - 48
    total = total + 1
  end while
  if decimal < 0 then return quakeFloat(value * sign) end if
  while total > decimal
    value = value / 10.0
    total = total - 1
  end while
  return quakeFloat(value * sign)
end function

// Provide atoi behavior for the active subsystem.
function atoi(text)
  data = quakeText.encodeBytes(text)
  index = 0
  sign = 1
  if index < len(data) and data[index] == 45 then
    sign = -1
    index = index + 1
  end if

  if index + 1 < len(data) and data[index] == 48 and (data[index + 1] == 120 or data[index + 1] == 88) then
    index = index + 2
    value = 0
    while index < len(data)
      digit = hexDigit(data[index])
      if digit < 0 then return quakeInt32(value * sign) end if
      value = quakeInt32((value << 4) + digit)
      index = index + 1
    end while
    return quakeInt32(value * sign)
  end if

  if index < len(data) and data[index] == 39 then
    if index + 1 < len(data) then return quakeInt32(sign * data[index + 1]) end if
    return 0
  end if

  value = 0
  while index < len(data)
    current = data[index]
    if current < 48 or current > 57 then return quakeInt32(value * sign) end if
    value = quakeInt32(value * 10 + current - 48)
    index = index + 1
  end while
  return quakeInt32(value * sign)
end function

// C runtime atoi semantics used by host_cmd.c and view.c.  Unlike Quake's
// Q_atoi above, this accepts only the initial decimal digit run after ASCII
// whitespace and an optional sign; 0x and character-literal syntax are not
// recognized.  The result is narrowed to WinQuake's signed 32-bit int.
function cAtoi(text)
  data = quakeText.encodeBytes(text)
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
    value = quakeInt32(value * 10 + data[index] - 48)
    index = index + 1
  end while
  return quakeInt32(value * sign)
end function

// C runtime atof semantics used by pr_edict.c and host_cmd.c save loading.
// The main native bridge calls strtod and narrows the result to C float, so
// signed zero, exponent syntax and the exact IEEE-754 binary32 boundary match
// WinQuake instead of depending on MiniLang's general toNumber() conversion.
function cAtof(text)
  return native.bitsFloat(native.f32FromText(text))
end function

// MiniLang byte arrays replace Q_mem*'s untyped pointers.  These functions
// preserve Quake's observable copy/fill/compare rules at offset zero.
function memSet(destination, fill, count)
  bio.requireRange(destination, 0, count)
  index = 0
  while index < count
    destination[index] = fill & 255
    index = index + 1
  end while
  return destination
end function

// Provide mem copy behavior for the active subsystem.
function memCopy(destination, source, count)
  bio.requireRange(destination, 0, count)
  bio.requireRange(source, 0, count)
  index = 0
  while index < count
    destination[index] = source[index]
    index = index + 1
  end while
  return destination
end function

// Provide mem compare behavior for the active subsystem.
function memCompare(first, second, count)
  bio.requireRange(first, 0, count)
  bio.requireRange(second, 0, count)
  index = count - 1
  while index >= 0
    if first[index] != second[index] then return -1 end if
    index = index - 1
  end while
  return 0
end function

// Return string length derived from the active module state.
function stringLength(text)
  return len(quakeText.encodeBytes(text))
end function

// Provide string copy behavior for the active subsystem.
function stringCopy(text)
  return quakeText.decodeBytes(quakeText.encodeBytes(text))
end function

// Return string copy count derived from the active module state.
function stringCopyCount(text, count)
  if count <= 0 then return "" end if
  data = quakeText.encodeBytes(text)
  if len(data) <= count then return quakeText.decodeBytes(data) end if
  return quakeText.decodeBytes(slice(data, 0, count))
end function

// Provide string concat behavior for the active subsystem.
function stringConcat(destination, source)
  return destination + source
end function

// Return string last index derived from the active module state.
function stringLastIndex(text, character)
  data = quakeText.encodeBytes(text)
  index = len(data) - 1
  while index >= 0
    if data[index] == character then return index end if
    index = index - 1
  end while
  return -1
end function

// Return string compare count derived from the active module state.
function stringCompareCount(first, second, count)
  firstData = quakeText.encodeBytes(first)
  secondData = quakeText.encodeBytes(second)
  index = 0
  while index < count
    firstValue = 0
    secondValue = 0
    if index < len(firstData) then firstValue = firstData[index] end if
    if index < len(secondData) then secondValue = secondData[index] end if
    if firstValue != secondValue then return -1 end if
    if firstValue == 0 then return 0 end if
    index = index + 1
  end while
  return 0
end function

// Provide string compare behavior for the active subsystem.
function stringCompare(first, second)
  firstLength = len(quakeText.encodeBytes(first))
  secondLength = len(quakeText.encodeBytes(second))
  count = firstLength
  if secondLength > count then count = secondLength end if
  return stringCompareCount(first, second, count + 1)
end function

// Convert data for upper ascii.
function upperAscii(value)
  if value >= 97 and value <= 122 then return value - 32 end if
  return value
end function

// Return string compare insensitive count derived from the active module state.
function stringCompareInsensitiveCount(first, second, count)
  firstData = quakeText.encodeBytes(first)
  secondData = quakeText.encodeBytes(second)
  index = 0
  while index < count
    firstValue = 0
    secondValue = 0
    if index < len(firstData) then firstValue = upperAscii(firstData[index]) end if
    if index < len(secondData) then secondValue = upperAscii(secondData[index]) end if
    if firstValue != secondValue then return -1 end if
    if firstValue == 0 then return 0 end if
    index = index + 1
  end while
  return 0
end function

// Provide string compare insensitive behavior for the active subsystem.
function stringCompareInsensitive(first, second)
  return stringCompareInsensitiveCount(first, second, 99999)
end function

// Provide substring behavior for the active subsystem.
function substring(text, offset, count)
  data = quakeText.encodeBytes(text)
  if offset < 0 then offset = 0 end if
  if offset > len(data) then offset = len(data) end if
  if count < 0 then count = 0 end if
  if offset + count > len(data) then count = len(data) - offset end if
  return quakeText.decodeBytes(slice(data, offset, count))
end function

// Return skip path derived from the active module state.
function skipPath(pathname)
  data = quakeText.encodeBytes(pathname)
  start = 0
  index = 0
  while index < len(data)
    if data[index] == 47 then start = index + 1 end if
    index = index + 1
  end while
  return substring(pathname, start, len(data) - start)
end function

// Convert extension into its canonical representation.
function stripExtension(pathname)
  data = quakeText.encodeBytes(pathname)
  index = 0
  while index < len(data) and data[index] != 46
    index = index + 1
  end while
  return substring(pathname, 0, index)
end function

// Provide file extension behavior for the active subsystem.
function fileExtension(pathname)
  data = quakeText.encodeBytes(pathname)
  index = 0
  while index < len(data) and data[index] != 46
    index = index + 1
  end while
  if index >= len(data) then return "" end if
  count = len(data) - index - 1
  if count > 7 then count = 7 end if
  return substring(pathname, index + 1, count)
end function

// Provide file base behavior for the active subsystem.
function fileBase(pathname)
  data = quakeText.encodeBytes(pathname)
  if len(data) == 0 then return "?model?" end if
  slash = -1
  dot = -1
  index = 0
  while index < len(data)
    if data[index] == 47 then slash = index end if
    if data[index] == 46 then dot = index end if
    index = index + 1
  end while
  if dot < slash then dot = len(data) end if
  count = dot - slash - 1
  // WinQuake treats zero- and one-character basenames as unusable model
  // tags and substitutes ?model?.
  if count < 2 then return "?model?" end if
  return substring(pathname, slash + 1, count)
end function

// Provide default extension behavior for the active subsystem.
function defaultExtension(pathname, extension)
  data = quakeText.encodeBytes(pathname)
  index = len(data) - 1
  while index > 0 and data[index] != 47
    if data[index] == 46 then return pathname end if
    index = index - 1
  end while
  return pathname + extension
end function

// Provide punctuation behavior for the active subsystem.
function punctuation(value)
  return value == 123 or value == 125 or value == 41 or value == 40 or value == 39 or value == 58
end function

// COM_Parse returns a pointer to the remaining source.  Its MiniLang pendant
// returns [token, nextOffset, eof], retaining punctuation and comment rules.
function parseToken(text, startOffset)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  data = quakeText.encodeBytes(text)
  index = startOffset
  scanning = true
  while scanning
    while index < len(data) and data[index] <= 32
      index = index + 1
    end while
    if index >= len(data) then return ["", len(data), true] end if
    if data[index] == 47 and index + 1 < len(data) and data[index + 1] == 47 then
      while index < len(data) and data[index] != 10
        index = index + 1
      end while
      continue
    end if
    scanning = false
  end while

  if data[index] == 34 then
    index = index + 1
    output = bytes(1023)
    count = 0
    while index < len(data) and data[index] != 34
      if count < len(output) then output[count] = data[index]; count = count + 1 end if
      index = index + 1
    end while
    if index < len(data) and data[index] == 34 then index = index + 1 end if
    return [quakeText.decodeBytes(slice(output, 0, count)), index, false]
  end if

  if punctuation(data[index]) then
    token = quakeText.decodeBytes(slice(data, index, 1))
    return [token, index + 1, false]
  end if

  output = bytes(1023)
  count = 0
  while index < len(data) and data[index] > 32 and not punctuation(data[index])
    if count < len(output) then output[count] = data[index]; count = count + 1 end if
    index = index + 1
  end while
  return [quakeText.decodeBytes(slice(output, 0, count)), index, false]
end function

// Provide memory search behavior for the active subsystem.
function memorySearch(data, count, search)
  bio.requireRange(data, 0, count)
  index = 0
  while index < count
    if data[index] == search then return index end if
    index = index + 1
  end while
  return -1
end function

// Provide fixed float behavior for the active subsystem.
function fixedFloat(value)
  negative = value < 0.0
  magnitude = value
  if negative then magnitude = -magnitude end if
  scaled = native.trunc(magnitude * 1000000.0 + 0.5)
  whole = native.trunc(scaled / 1000000)
  fraction = scaled % 1000000
  digits = "" + fraction
  while len(bytes(digits)) < 6
    digits = "0" + digits
  end while
  output = "" + whole + "." + digits
  if negative then output = "-" + output end if
  return output
end function

// Provide hexadecimal behavior for the active subsystem.
function hexadecimal(value, upper)
  digits = "0123456789abcdef"
  if upper then digits = "0123456789ABCDEF" end if
  number = native.trunc(value)
  if number < 0 then number = number & 0xffffffff end if
  if number == 0 then return "0" end if
  output = ""
  while number > 0
    nibble = number & 15
    output = substring(digits, nibble, 1) + output
    number = number >> 4
  end while
  return output
end function

// Format and emit flag.
function formatFlag(value)
  if value == 45 or value == 43 or value == 32 or value == 35 then return true end if
  if value >= 48 and value <= 57 then return true end if
  return value == 46 or value == 104 or value == 108
end function

// C va() is a transient 1024-byte vsprintf buffer. MiniLang strings are
// immutable, so callers pass the variadic values as an array and receive an
// owned string. This covers every conversion used by the MiniQuake target.
function va(format, arguments)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  source = bytes(format)
  output = ""
  sourceIndex = 0
  argumentIndex = 0
  while sourceIndex < len(source)
    if source[sourceIndex] != 37 then
      output = output + decode(slice(source, sourceIndex, 1))
      sourceIndex = sourceIndex + 1
      continue
    end if

    sourceIndex = sourceIndex + 1
    if sourceIndex < len(source) and source[sourceIndex] == 37 then
      output = output + "%"
      sourceIndex = sourceIndex + 1
      continue
    end if

    while sourceIndex < len(source) and formatFlag(source[sourceIndex])
      sourceIndex = sourceIndex + 1
    end while
    if sourceIndex >= len(source) then break end if
    if argumentIndex >= len(arguments) then return error(1003, "va: missing argument") end if

    conversion = source[sourceIndex]
    value = arguments[argumentIndex]
    argumentIndex = argumentIndex + 1
    if conversion == 115 then
      output = output + value
    else if conversion == 99 then
      output = output + native.asciiChar(native.trunc(value))
    else if conversion == 120 then
      output = output + hexadecimal(value, false)
    else if conversion == 88 then
      output = output + hexadecimal(value, true)
    else if conversion == 102 then
      output = output + fixedFloat(value)
    else if conversion == 100 or conversion == 105 or conversion == 117 then
      output = output + native.trunc(value)
    else
      return error(1004, "va: unsupported conversion")
    end if
    sourceIndex = sourceIndex + 1
  end while
  if len(bytes(output)) > 1023 then return substring(output, 0, 1023) end if
  return output
end function

// Initialize state for starts with marker.
function startsWithMarker(text, marker)
  data = bytes(text)
  if len(data) == 0 then return false end if
  return data[0] == marker
end function

// Provide join arguments behavior for the active subsystem.
function joinArguments(args)
  text = ""
  index = 0
  while index < len(args)
    if index > 0 then text = text + " " end if
    text = text + args[index]
    index = index + 1
  end while
  return text
end function

// Create and initialize the module state.
function create(args)
  safe = false
  rogue = false
  hipnotic = false
  originalArgs = []
  index = 0
  while index < len(args) and index < c.MAX_NUM_ARGVS
    originalArgs = originalArgs + [args[index]]
    if args[index] == "-safe" then safe = true end if
    index = index + 1
  end while

  reconstructed = ""
  for each argument in originalArgs
    source = bytes(argument + " ")
    sourceIndex = 0
    while sourceIndex < len(source) and len(bytes(reconstructed)) < 255
      reconstructed = reconstructed + decode(slice(source, sourceIndex, 1))
      sourceIndex = sourceIndex + 1
    end while
  end for

  finalArgs = originalArgs
  if safe then
    safeArguments = ["-stdvid", "-nolan", "-nosound", "-nocdaudio", "-nojoy", "-nomouse", "-dibonly"]
    for each safeArgument in safeArguments
      finalArgs = finalArgs + [safeArgument]
    end for
  end if

  for each argument in finalArgs
    if argument == "-rogue" then rogue = true end if
    if argument == "-hipnotic" then hipnotic = true end if
  end for
  return t.CommandLine(finalArgs, reconstructed, safe, rogue, hipnotic, not rogue and not hipnotic)
end function

// Validate parm and report any incompatibility.
function checkParm(commandLine, name)
  // MiniLang stores only arguments after argv[0].  Preserve COM_CheckParm's
  // externally visible one-based position by adding one to the array index.
  index = 0
  while index < len(commandLine.args)
    if commandLine.args[index] == name then return index + 1 end if
    index = index + 1
  end while
  return 0
end function

// Report whether parm.
function hasParm(commandLine, name)
  return checkParm(commandLine, name) != 0
end function

// Return parm value derived from the active module state.
function parmValue(commandLine, name, fallback)
  position = checkParm(commandLine, name)
  if position != 0 and position < len(commandLine.args) then
    return commandLine.args[position]
  end if
  return fallback
end function

// Provide integer option behavior for the active subsystem.
function integerOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  return atoi(text)
end function

// Provide float option behavior for the active subsystem.
function floatOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  return atof(text)
end function

// Provide base directory behavior for the active subsystem.
function baseDirectory(commandLine)
  return parmValue(commandLine, "-basedir", ".")
end function

// Provide game directory behavior for the active subsystem.
function gameDirectory(commandLine)
  return parmValue(commandLine, "-game", "id1")
end function

// Convert data for quote command argument.
function quoteCommandArgument(text)
  source = bytes(text)
  needsQuotes = false
  for each value in source
    if value <= 32 or value == 59 then needsQuotes = true; break end if
  end for
  if not needsQuotes then return text end if
  output = "\""
  for each value in source
    if value == 34 then output = output + "\\\"" else output = output + decode(bytes([value])) end if
  end for
  return output + "\""
end function

// Provide stuff commands behavior for the active subsystem.
function stuffCommands(commandLine)
  combined = joinArguments(commandLine.args)
  source = bytes(combined)
  text = ""
  index = 0
  while index < len(source)
    if source[index] == 43 then
      start = index + 1
      index = start
      while index < len(source) and source[index] != 43 and source[index] != 45
        index = index + 1
      end while
      text = text + decode(slice(source, start, index - start)) + "\n"
      continue
    end if
    index = index + 1
  end while
  return text
end function

// Original WinQuake/common.c entry points.  The engine uses the descriptive
// MiniLang names above internally; these aliases keep the source-file pendant
// explicit and make one-to-one differential fixtures readable.
function ClearLink(link)
  return clearLink(link)
end function

// Release state for remove link.
function RemoveLink(link)
  return removeLink(link)
end function

// Add state for insert link before.
function InsertLinkBefore(link, before)
  return insertLinkBefore(link, before)
end function

// Add state for insert link after.
function InsertLinkAfter(link, after)
  return insertLinkAfter(link, after)
end function

// Provide the Quake-compatible memset entry point.
function Q_memset(destination, fill, count)
  return memSet(destination, fill, count)
end function

// Provide the Quake-compatible memcpy entry point.
function Q_memcpy(destination, source, count)
  return memCopy(destination, source, count)
end function

// Provide the Quake-compatible memcmp entry point.
function Q_memcmp(first, second, count)
  return memCompare(first, second, count)
end function

// Provide the Quake-compatible strcpy entry point.
function Q_strcpy(source)
  return stringCopy(source)
end function

// Provide the Quake-compatible strncpy entry point.
function Q_strncpy(source, count)
  return stringCopyCount(source, count)
end function

// Provide the Quake-compatible strlen entry point.
function Q_strlen(text)
  return stringLength(text)
end function

// Provide the Quake-compatible strrchr entry point.
function Q_strrchr(text, character)
  return stringLastIndex(text, character)
end function

// Provide the Quake-compatible strcat entry point.
function Q_strcat(destination, source)
  return stringConcat(destination, source)
end function

// Provide the Quake-compatible strcmp entry point.
function Q_strcmp(first, second)
  return stringCompare(first, second)
end function

// Provide the Quake-compatible strncmp entry point.
function Q_strncmp(first, second, count)
  return stringCompareCount(first, second, count)
end function

// Provide the Quake-compatible strncasecmp entry point.
function Q_strncasecmp(first, second, count)
  return stringCompareInsensitiveCount(first, second, count)
end function

// Provide the Quake-compatible strcasecmp entry point.
function Q_strcasecmp(first, second)
  return stringCompareInsensitive(first, second)
end function

// Provide the Quake-compatible atoi entry point.
function Q_atoi(text)
  return atoi(text)
end function

// Provide the Quake-compatible atof entry point.
function Q_atof(text)
  return atof(text)
end function

// Provide signed short behavior for the active subsystem.
function signedShort(value)
  value = value & 65535
  if value >= 32768 then return value - 65536 end if
  return value
end function

// Convert byte order for short swap.
function ShortSwap(value)
  value = value & 65535
  return signedShort(((value & 255) << 8) | ((value >> 8) & 255))
end function

// Convert byte order for short no swap.
function ShortNoSwap(value)
  return signedShort(value)
end function

// Convert byte order for long swap.
function LongSwap(value)
  input = bytes(4)
  output = bytes(4)
  bio.putI32(input, 0, value)
  output[0] = input[3]
  output[1] = input[2]
  output[2] = input[1]
  output[3] = input[0]
  return bio.i32(output, 0)
end function

// Convert byte order for long no swap.
function LongNoSwap(value)
  // The C parameter is a signed 32-bit int. Preserve that call boundary.
  return quakeInt32(value)
end function

// Convert byte order for float swap.
function FloatSwap(value)
  input = bytes(4)
  output = bytes(4)
  bio.putF32(input, 0, value)
  output[0] = input[3]
  output[1] = input[2]
  output[2] = input[1]
  output[3] = input[0]
  return bio.f32(output, 0)
end function

// Convert byte order for float no swap.
function FloatNoSwap(value)
  // The C parameter and return type are both float, not host double.
  return quakeFloat(value)
end function

// Mirror Quake's COM_SkipPath routine and its observable state changes.
function COM_SkipPath(pathname)
  return skipPath(pathname)
end function

// Mirror Quake's COM_StripExtension routine and its observable state changes.
function COM_StripExtension(pathname)
  return stripExtension(pathname)
end function

// Mirror Quake's COM_FileExtension routine and its observable state changes.
function COM_FileExtension(pathname)
  return fileExtension(pathname)
end function

// Mirror Quake's COM_FileBase routine and its observable state changes.
function COM_FileBase(pathname)
  return fileBase(pathname)
end function

// Mirror Quake's COM_DefaultExtension routine and its observable state changes.
function COM_DefaultExtension(pathname, extension)
  return defaultExtension(pathname, extension)
end function

// Mirror Quake's COM_Parse routine and its observable state changes.
function COM_Parse(text, startOffset)
  return parseToken(text, startOffset)
end function

// Mirror Quake's COM_CheckParm routine and its observable state changes.
function COM_CheckParm(commandLine, name)
  return checkParm(commandLine, name)
end function

// Mirror Quake's COM_InitArgv routine and its observable state changes.
function COM_InitArgv(arguments)
  return create(arguments)
end function

// Mirror Quake's COM_Init routine and its observable state changes.
function COM_Init(basedir, arguments)
  commandLine = COM_InitArgv(arguments)
  // The C routine also selected little-endian conversion functions and
  // registered two cvars plus the path command.  Return those explicit
  // startup effects to the host layer instead of hiding them in globals.
  return [commandLine, basedir, false, 2, 1]
end function

// Provide memsearch behavior for the active subsystem.
function memsearch(data, count, search)
  return memorySearch(data, count, search)
end function

// Return plus value derived from the active module state.
function plusValue(commandLine, commandName, fallback)
  wanted = "+" + bio.lower(commandName)
  index = 0
  while index < len(commandLine.args)
    if bio.lower(commandLine.args[index]) == wanted then
      if index + 1 < len(commandLine.args) then return commandLine.args[index + 1] end if
      return fallback
    end if
    index = index + 1
  end while
  return fallback
end function

// Inspect the requested value and emit its decoded metadata.
function describe(commandLine)
  result = "argv=" + len(commandLine.args)
  if commandLine.safeMode then result = result + " safe" end if
  if commandLine.rogue then result = result + " rogue" end if
  if commandLine.hipnotic then result = result + " hipnotic" end if
  return result
end function
