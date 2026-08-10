package miniquake.common

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.constants as c
import miniquake.native as native
import miniquake.protocol_text as quakeText

function clearLink(link)
  link.previous = link
  link.next = link
  return link
end function

function removeLink(link)
  link.next.previous = link.previous
  link.previous.next = link.next
  return link
end function

function insertLinkBefore(link, before)
  link.next = before
  link.previous = before.previous
  link.previous.next = link
  link.next.previous = link
  return link
end function

function insertLinkAfter(link, after)
  link.next = after.next
  link.previous = after
  link.previous.next = link
  link.next.previous = link
  return link
end function

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

function stringLength(text)
  return len(quakeText.encodeBytes(text))
end function

function stringCopy(text)
  return quakeText.decodeBytes(quakeText.encodeBytes(text))
end function

function stringCopyCount(text, count)
  if count <= 0 then return "" end if
  data = quakeText.encodeBytes(text)
  if len(data) <= count then return quakeText.decodeBytes(data) end if
  return quakeText.decodeBytes(slice(data, 0, count))
end function

function stringConcat(destination, source)
  return destination + source
end function

function stringLastIndex(text, character)
  data = quakeText.encodeBytes(text)
  index = len(data) - 1
  while index >= 0
    if data[index] == character then return index end if
    index = index - 1
  end while
  return -1
end function

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

function stringCompare(first, second)
  firstLength = len(quakeText.encodeBytes(first))
  secondLength = len(quakeText.encodeBytes(second))
  count = firstLength
  if secondLength > count then count = secondLength end if
  return stringCompareCount(first, second, count + 1)
end function

function upperAscii(value)
  if value >= 97 and value <= 122 then return value - 32 end if
  return value
end function

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

function stringCompareInsensitive(first, second)
  return stringCompareInsensitiveCount(first, second, 99999)
end function

function substring(text, offset, count)
  data = quakeText.encodeBytes(text)
  if offset < 0 then offset = 0 end if
  if offset > len(data) then offset = len(data) end if
  if count < 0 then count = 0 end if
  if offset + count > len(data) then count = len(data) - offset end if
  return quakeText.decodeBytes(slice(data, offset, count))
end function

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

function stripExtension(pathname)
  data = quakeText.encodeBytes(pathname)
  index = 0
  while index < len(data) and data[index] != 46
    index = index + 1
  end while
  return substring(pathname, 0, index)
end function

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

function defaultExtension(pathname, extension)
  data = quakeText.encodeBytes(pathname)
  index = len(data) - 1
  while index > 0 and data[index] != 47
    if data[index] == 46 then return pathname end if
    index = index - 1
  end while
  return pathname + extension
end function

function punctuation(value)
  return value == 123 or value == 125 or value == 41 or value == 40 or value == 39 or value == 58
end function

// COM_Parse returns a pointer to the remaining source.  Its MiniLang pendant
// returns [token, nextOffset, eof], retaining punctuation and comment rules.
function parseToken(text, startOffset)
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

function memorySearch(data, count, search)
  bio.requireRange(data, 0, count)
  index = 0
  while index < count
    if data[index] == search then return index end if
    index = index + 1
  end while
  return -1
end function

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

function formatFlag(value)
  if value == 45 or value == 43 or value == 32 or value == 35 then return true end if
  if value >= 48 and value <= 57 then return true end if
  return value == 46 or value == 104 or value == 108
end function

// C va() is a transient 1024-byte vsprintf buffer. MiniLang strings are
// immutable, so callers pass the variadic values as an array and receive an
// owned string. This covers every conversion used by the MiniQuake target.
function va(format, arguments)
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

function startsWithMarker(text, marker)
  data = bytes(text)
  if len(data) == 0 then return false end if
  return data[0] == marker
end function

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

function hasParm(commandLine, name)
  return checkParm(commandLine, name) != 0
end function

function parmValue(commandLine, name, fallback)
  position = checkParm(commandLine, name)
  if position != 0 and position < len(commandLine.args) then
    return commandLine.args[position]
  end if
  return fallback
end function

function integerOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  return atoi(text)
end function

function floatOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  return atof(text)
end function

function baseDirectory(commandLine)
  return parmValue(commandLine, "-basedir", ".")
end function

function gameDirectory(commandLine)
  return parmValue(commandLine, "-game", "id1")
end function

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

function RemoveLink(link)
  return removeLink(link)
end function

function InsertLinkBefore(link, before)
  return insertLinkBefore(link, before)
end function

function InsertLinkAfter(link, after)
  return insertLinkAfter(link, after)
end function

function Q_memset(destination, fill, count)
  return memSet(destination, fill, count)
end function

function Q_memcpy(destination, source, count)
  return memCopy(destination, source, count)
end function

function Q_memcmp(first, second, count)
  return memCompare(first, second, count)
end function

function Q_strcpy(source)
  return stringCopy(source)
end function

function Q_strncpy(source, count)
  return stringCopyCount(source, count)
end function

function Q_strlen(text)
  return stringLength(text)
end function

function Q_strrchr(text, character)
  return stringLastIndex(text, character)
end function

function Q_strcat(destination, source)
  return stringConcat(destination, source)
end function

function Q_strcmp(first, second)
  return stringCompare(first, second)
end function

function Q_strncmp(first, second, count)
  return stringCompareCount(first, second, count)
end function

function Q_strncasecmp(first, second, count)
  return stringCompareInsensitiveCount(first, second, count)
end function

function Q_strcasecmp(first, second)
  return stringCompareInsensitive(first, second)
end function

function Q_atoi(text)
  return atoi(text)
end function

function Q_atof(text)
  return atof(text)
end function

function signedShort(value)
  value = value & 65535
  if value >= 32768 then return value - 65536 end if
  return value
end function

function ShortSwap(value)
  value = value & 65535
  return signedShort(((value & 255) << 8) | ((value >> 8) & 255))
end function

function ShortNoSwap(value)
  return signedShort(value)
end function

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

function LongNoSwap(value)
  // The C parameter is a signed 32-bit int. Preserve that call boundary.
  return quakeInt32(value)
end function

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

function FloatNoSwap(value)
  // The C parameter and return type are both float, not host double.
  return quakeFloat(value)
end function

function COM_SkipPath(pathname)
  return skipPath(pathname)
end function

function COM_StripExtension(pathname)
  return stripExtension(pathname)
end function

function COM_FileExtension(pathname)
  return fileExtension(pathname)
end function

function COM_FileBase(pathname)
  return fileBase(pathname)
end function

function COM_DefaultExtension(pathname, extension)
  return defaultExtension(pathname, extension)
end function

function COM_Parse(text, startOffset)
  return parseToken(text, startOffset)
end function

function COM_CheckParm(commandLine, name)
  return checkParm(commandLine, name)
end function

function COM_InitArgv(arguments)
  return create(arguments)
end function

function COM_Init(basedir, arguments)
  commandLine = COM_InitArgv(arguments)
  // The C routine also selected little-endian conversion functions and
  // registered two cvars plus the path command.  Return those explicit
  // startup effects to the host layer instead of hiding them in globals.
  return [commandLine, basedir, false, 2, 1]
end function

function memsearch(data, count, search)
  return memorySearch(data, count, search)
end function

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

function describe(commandLine)
  result = "argv=" + len(commandLine.args)
  if commandLine.safeMode then result = result + " safe" end if
  if commandLine.rogue then result = result + " rogue" end if
  if commandLine.hipnotic then result = result + " hipnotic" end if
  return result
end function
