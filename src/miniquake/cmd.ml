package miniquake.cmd

import miniquake.types as t
import miniquake.byteio as bio
import miniquake.constants as c
import miniquake.sizebuf as sz
import miniquake.message as msg

const MAX_ALIAS_NAME = 32
const MAX_ARGS = 80
const COMMAND_BUFFER_SIZE = 8192

function create()
  return t.CommandSystem([], [], [], "", "", false)
end function

function addCommand(system, name, callback)
  for each item in system.commands
    if item[0] == name then return error(1450, "Cmd_AddCommand: " + name + " already defined") end if
  end for
  // Cmd_AddCommand links at the head of cmd_functions.
  system.commands = [[name, callback]] + system.commands
  return true
end function

function commandExists(system, name)
  for each item in system.commands
    if item[0] == name then return true end if
  end for
  return false
end function

function terminatedAliasValue(value)
  data = bytes(value)
  if len(data) > 0 and data[len(data) - 1] == 10 then return value end if
  if len(data) > 0 and data[len(data) - 1] == 32 then return value + "\n" end if
  return value + " \n"
end function

function addAlias(system, name, value)
  if len(bytes(name)) >= MAX_ALIAS_NAME then return error(1451, "Alias name is too long") end if
  for each alias in system.aliases
    // Cmd_Alias_f reuses only an exactly matching alias. Execution remains
    // case-insensitive, so differently-cased aliases keep original list order.
    if alias.name == name then
      alias.value = terminatedAliasValue(value)
      return alias
    end if
  end for
  alias = t.CommandAlias(name, terminatedAliasValue(value))
  system.aliases = [alias] + system.aliases
  return alias
end function

function tokenize(text)
  source = bytes(text)
  result = []
  index = 0
  while index < len(source)
    while index < len(source) and source[index] <= 32
      if source[index] == 10 then return result end if
      index = index + 1
    end while
    if index >= len(source) then break end if
    if source[index] == 47 and index + 1 < len(source) and source[index + 1] == 47 then break end if

    output = bytes(len(source) - index)
    count = 0
    if source[index] == 34 then
      index = index + 1
      while index < len(source)
        value = source[index]
        index = index + 1
        if value == 34 then
          break
        end if
        output[count] = value
        count = count + 1
      end while
    else if source[index] == 123 or source[index] == 125 or source[index] == 41 or source[index] == 40 or source[index] == 39 or source[index] == 58 then
      output[0] = source[index]
      count = 1
      index = index + 1
    else
      while index < len(source)
        value = source[index]
        if value <= 32 or value == 123 or value == 125 or value == 41 or value == 40 or value == 39 or value == 58 then break end if
        output[count] = value
        count = count + 1
        index = index + 1
      end while
    end if
    if len(result) < MAX_ARGS then result = result + [decode(slice(output, 0, count))] end if
  end while
  return result
end function

function rawArgumentTail(text)
  source = bytes(text)
  index = 0
  while index < len(source) and source[index] <= 32 and source[index] != 10
    index = index + 1
  end while
  if index >= len(source) or source[index] == 10 then return "" end if
  if source[index] == 34 then
    index = index + 1
    while index < len(source) and source[index] != 34
      index = index + 1
    end while
    if index < len(source) then index = index + 1 end if
  else if source[index] == 123 or source[index] == 125 or source[index] == 41 or source[index] == 40 or source[index] == 39 or source[index] == 58 then
    index = index + 1
  else
    while index < len(source)
      value = source[index]
      if value <= 32 or value == 123 or value == 125 or value == 41 or value == 40 or value == 39 or value == 58 then break end if
      index = index + 1
    end while
  end if
  while index < len(source) and source[index] <= 32 and source[index] != 10
    index = index + 1
  end while
  finish = index
  while finish < len(source) and source[finish] != 10
    finish = finish + 1
  end while
  if finish <= index then return "" end if
  return decode(slice(source, index, finish - index))
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

function checkParm(system, name)
  if name is void then return error(1452, "Cmd_CheckParm: NULL") end if
  index = 1
  while index < len(system.arguments)
    if bio.equalInsensitive(system.arguments[index], name) then return index end if
    index = index + 1
  end while
  return 0
end function

function executeString(system, text)
  system.arguments = tokenize(text)
  system.rawArgs = rawArgumentTail(text)
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
      system.text = alias.value + system.text
      return true
    end if
  end for
  return false
end function

function addText(system, text)
  if len(bytes(system.text)) + len(bytes(text)) >= COMMAND_BUFFER_SIZE then
    print "Cbuf_AddText: overflow"
    return false
  end if
  system.text = system.text + text
  return true
end function

function insertText(system, text)
  if len(bytes(system.text)) + len(bytes(text)) >= COMMAND_BUFFER_SIZE then
    print "Cbuf_AddText: overflow"
    return false
  end if
  system.text = text + system.text
  return true
end function

function splitFirstCommand(text)
  source = bytes(text)
  quoted = false
  index = 0
  while index < len(source)
    value = source[index]
    if value == 34 then
      quoted = not quoted
    else if not quoted and (value == 10 or value == 59) then
      break
    end if
    index = index + 1
  end while

  line = decode(slice(source, 0, index))
  if index < len(source) then index = index + 1 end if
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
  left = bytes(candidate)
  right = bytes(partial)
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
  return void
end function

function Cmd_Wait_f(system)
  system.wait = true
  return true
end function

function Cbuf_Init()
  return create()
end function

function Cbuf_AddText(system, text)
  return addText(system, text)
end function

function Cbuf_InsertText(system, text)
  return insertText(system, text)
end function

function Cbuf_Execute(system)
  return executeBuffer(system)
end function

function Cmd_StuffCmds_f(system, commandLineArgs)
  if len(system.arguments) != 1 then return false end if
  combined = ""
  index = 1
  while index < len(commandLineArgs)
    if commandLineArgs[index] is not void then
      if combined != "" then combined = combined + " " end if
      combined = combined + commandLineArgs[index]
    end if
    index = index + 1
  end while
  data = bytes(combined)
  build = ""
  index = 0
  while index < len(data)
    if data[index] == 43 then
      index = index + 1
      start = index
      while index < len(data) and data[index] != 43 and data[index] != 45
        index = index + 1
      end while
      build = build + decode(slice(data, start, index - start)) + "\n"
      index = index - 1
    end if
    index = index + 1
  end while
  if build == "" then return false end if
  return insertText(system, build)
end function

function Cmd_Exec_f(system, arguments, loadedText)
  if len(arguments) != 2 or loadedText is void then return false end if
  return insertText(system, loadedText)
end function

function Cmd_Echo_f(arguments)
  text = ""
  index = 1
  while index < len(arguments)
    text = text + arguments[index] + " "
    index = index + 1
  end while
  print text
  return len(arguments)
end function

function CopyString(value)
  return "" + value
end function

function Cmd_Alias_f(system, arguments)
  if len(arguments) == 1 then return false end if
  value = ""
  index = 2
  while index < len(arguments)
    value = value + arguments[index]
    if index != len(arguments) then value = value + " " end if
    index = index + 1
  end while
  return addAlias(system, arguments[1], value)
end function

function Cmd_InitCallback(arguments)
  return true
end function

function Cmd_Init(system)
  addCommand(system, "stuffcmds", Cmd_InitCallback)
  addCommand(system, "exec", Cmd_InitCallback)
  addCommand(system, "echo", Cmd_InitCallback)
  addCommand(system, "alias", Cmd_InitCallback)
  addCommand(system, "cmd", Cmd_InitCallback)
  addCommand(system, "wait", Cmd_InitCallback)
  return system
end function

function Cmd_Argc(system)
  return argc(system)
end function

function Cmd_Argv(system, index)
  return argv(system, index)
end function

function Cmd_Args(system)
  return system.rawArgs
end function

function Cmd_TokenizeString(system, text)
  system.arguments = tokenize(text)
  system.rawArgs = rawArgumentTail(text)
  return system.arguments
end function

function Cmd_AddCommand(system, name, callback, variableExists)
  if variableExists then return error(1453, "Cmd_AddCommand: " + name + " already defined as a var") end if
  return addCommand(system, name, callback)
end function

function Cmd_Exists(system, name)
  return commandExists(system, name)
end function

function Cmd_CompleteCommand(system, partial)
  return completeCommand(system, partial)
end function

function Cmd_ExecuteString(system, text, source)
  return executeString(system, text)
end function

function Cmd_ForwardToServer(system, outgoing, connected, demoPlayback)
  if not connected or demoPlayback then return false end if
  msg.writeByte(outgoing, c.CLC_STRINGCMD)
  if bio.lower(argv(system, 0)) != "cmd" then
    sz.printText(outgoing, argv(system, 0))
    sz.printText(outgoing, " ")
  end if
  if argc(system) > 1 then sz.printText(outgoing, system.rawArgs) else sz.printText(outgoing, "\n") end if
  return true
end function

function Cmd_CheckParm(system, name)
  return checkParm(system, name)
end function
