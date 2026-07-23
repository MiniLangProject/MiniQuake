package miniquake.cmd

import miniquake.types as t
import miniquake.byteio as bio

function create()
  return t.CommandSystem([], [], [], "", false)
end function

function addCommand(system, name, callback)
  wanted = bio.lower(name)
  for each item in system.commands
    if bio.lower(item[0]) == wanted then return error(1450, "Cmd_AddCommand: duplicate " + name) end if
  end for
  system.commands = system.commands + [[name, callback]]
  return true
end function

function commandExists(system, name)
  wanted = bio.lower(name)
  for each item in system.commands
    if bio.lower(item[0]) == wanted then return true end if
  end for
  return false
end function

function addAlias(system, name, value)
  wanted = bio.lower(name)
  for each alias in system.aliases
    if bio.lower(alias.name) == wanted then
      alias.value = value
      return alias
    end if
  end for
  alias = t.CommandAlias(name, value)
  system.aliases = system.aliases + [alias]
  return alias
end function

function tokenize(text)
  source = bytes(text)
  result = []
  index = 0
  while index < len(source)
    while index < len(source) and source[index] <= 32
      index = index + 1
    end while
    if index >= len(source) then break end if
    if source[index] == 47 and index + 1 < len(source) and source[index + 1] == 47 then break end if

    quoted = false
    if source[index] == 34 then
      quoted = true
      index = index + 1
    end if
    output = bytes(len(source) - index)
    count = 0
    while index < len(source)
      value = source[index]
      if quoted then
        if value == 34 then
          index = index + 1
          break
        end if
        if value == 92 and index + 1 < len(source) then
          index = index + 1
          value = source[index]
          if value == 110 then value = 10 end if
          if value == 116 then value = 9 end if
        end if
      else
        if value <= 32 then break end if
        if value == 47 and index + 1 < len(source) and source[index + 1] == 47 then break end if
      end if
      output[count] = value
      count = count + 1
      index = index + 1
    end while
    result = result + [decode(slice(output, 0, count))]
    while index < len(source) and source[index] <= 32
      index = index + 1
    end while
  end while
  return result
end function

function argc(system)
  return len(system.arguments)
end function

function argv(system, index)
  if index < 0 or index >= len(system.arguments) then return "" end if
  return system.arguments[index]
end function

function argsFrom(system, first)
  result = ""
  index = first
  while index < len(system.arguments)
    if result != "" then result = result + " " end if
    result = result + system.arguments[index]
    index = index + 1
  end while
  return result
end function

function executeString(system, text)
  system.arguments = tokenize(text)
  if len(system.arguments) == 0 then return false end if
  name = bio.lower(system.arguments[0])
  if name == "wait" then
    system.wait = true
    return true
  end if
  for each item in system.commands
    if bio.lower(item[0]) == name then return item[1](system.arguments) end if
  end for
  for each alias in system.aliases
    if bio.lower(alias.name) == name then
      system.text = alias.value + "\n" + system.text
      return true
    end if
  end for
  return false
end function

function addText(system, text)
  system.text = system.text + text
end function

function insertText(system, text)
  system.text = text + system.text
end function

function splitFirstCommand(text)
  source = bytes(text)
  quoted = false
  comment = false
  index = 0
  while index < len(source)
    value = source[index]
    if comment then
      if value == 10 or value == 13 then break end if
    else if value == 34 then
      quoted = not quoted
    else if not quoted and value == 47 and index + 1 < len(source) and source[index + 1] == 47 then
      comment = true
      index = index + 1
    else if not quoted and (value == 10 or value == 13 or value == 59) then
      break
    end if
    index = index + 1
  end while

  line = decode(slice(source, 0, index))
  while index < len(source) and (source[index] == 10 or source[index] == 13 or source[index] == 59)
    index = index + 1
  end while
  rest = ""
  if index < len(source) then rest = decode(slice(source, index, len(source) - index)) end if
  return [line, rest]
end function

function executeBuffer(system)
  count = 0
  while system.text != ""
    parts = splitFirstCommand(system.text)
    system.text = parts[1]
    if len(tokenize(parts[0])) > 0 then
      executeString(system, parts[0])
      count = count + 1
    end if
    if system.wait then
      system.wait = false
      break
    end if
  end while
  return count
end function

function prefixMatches(candidate, partial)
  left = bytes(bio.lower(candidate))
  right = bytes(bio.lower(partial))
  if len(right) > len(left) then return false end if
  index = 0
  while index < len(right)
    if left[index] != right[index] then return false end if
    index = index + 1
  end while
  return true
end function

function completeCommand(system, partial)
  for each item in system.commands
    if prefixMatches(item[0], partial) then return item[0] end if
  end for
  for each alias in system.aliases
    if prefixMatches(alias.name, partial) then return alias.name end if
  end for
  return void
end function
