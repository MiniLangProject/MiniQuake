package miniquake.common

import miniquake.types as t
import miniquake.byteio as bio

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
  for each argument in args
    lowered = bio.lower(argument)
    if lowered == "-safe" then safe = true end if
    if lowered == "-rogue" then rogue = true end if
    if lowered == "-hipnotic" then hipnotic = true end if
  end for

  finalArgs = args
  if safe then
    safeArguments = ["-stdvid", "-nolan", "-nosound", "-nocdaudio", "-nojoy", "-nomouse", "-dibonly"]
    for each safeArgument in safeArguments
      found = false
      for each existing in finalArgs
        if bio.equalInsensitive(existing, safeArgument) then found = true; break end if
      end for
      if not found then finalArgs = finalArgs + [safeArgument] end if
    end for
  end if
  return t.CommandLine(finalArgs, joinArguments(finalArgs), safe, rogue, hipnotic, not rogue and not hipnotic)
end function

function checkParm(commandLine, name)
  wanted = bio.lower(name)
  index = 0
  while index < len(commandLine.args)
    if bio.lower(commandLine.args[index]) == wanted then return index end if
    index = index + 1
  end while
  return -1
end function

function hasParm(commandLine, name)
  return checkParm(commandLine, name) >= 0
end function

function parmValue(commandLine, name, fallback)
  index = checkParm(commandLine, name)
  if index >= 0 and index + 1 < len(commandLine.args) then
    value = commandLine.args[index + 1]
    if not startsWithMarker(value, 45) and not startsWithMarker(value, 43) then return value end if
  end if
  return fallback
end function

function integerOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  value = toNumber(text)
  if value is int then return value end if
  return fallback
end function

function floatOption(commandLine, name, fallback)
  text = parmValue(commandLine, name, "")
  if text == "" then return fallback end if
  value = toNumber(text)
  if value is int or value is float then return value end if
  return fallback
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
  text = ""
  index = 0
  while index < len(commandLine.args)
    argument = commandLine.args[index]
    if startsWithMarker(argument, 43) then
      if len(bytes(argument)) > 1 then
        command = decode(slice(bytes(argument), 1, len(bytes(argument)) - 1))
        index = index + 1
        while index < len(commandLine.args)
          next = commandLine.args[index]
          if startsWithMarker(next, 43) or startsWithMarker(next, 45) then break end if
          command = command + " " + quoteCommandArgument(next)
          index = index + 1
        end while
        text = text + command + "\n"
        continue
      end if
    end if
    index = index + 1
  end while
  return text
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
