package miniquake.cvar

import miniquake.types as t
import miniquake.native as native
import miniquake.common as common

function numericValue(text)
  return common.atof(text)
end function

function createRegistry()
  return t.CvarRegistry([], [])
end function

function create(name, stringValue, archive, server)
  return t.Cvar(name, stringValue, numericValue(stringValue), archive, server)
end function

function find(registry, name)
  for each variable in registry.variables
    if variable.name == name then return variable end if
  end for
  return void
end function

function register(registry, variable, commandExists)
  if find(registry, variable.name) is not void then
    return error(1400, "Cvar_RegisterVariable: " + variable.name + " already defined")
  end if
  if commandExists(variable.name) then
    return error(1401, "Cvar_RegisterVariable: " + variable.name + " is a command")
  end if
  // Cvar_RegisterVariable links new variables at the head of cvar_vars.
  registry.variables = [variable] + registry.variables
  return variable
end function

function set(registry, name, stringValue)
  variable = find(registry, name)
  if variable is void then return error(1402, "Cvar_Set: variable not found: " + name) end if
  changed = variable.string != stringValue
  variable.string = stringValue
  variable.value = numericValue(stringValue)
  if variable.server and changed then
    registry.serverChanges = registry.serverChanges + [[variable.name, variable.string]]
  end if
  return variable
end function

function takeServerChanges(registry)
  changes = registry.serverChanges
  registry.serverChanges = []
  return changes
end function

function setValue(registry, name, value)
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
  text = "" + whole + "." + digits
  if negative then text = "-" + text end if
  return set(registry, name, text)
end function

function variableValue(registry, name)
  variable = find(registry, name)
  if variable is void then return 0.0 end if
  return variable.value
end function

function variableString(registry, name)
  variable = find(registry, name)
  if variable is void then return "" end if
  return variable.string
end function

function completeVariable(registry, partial)
  wantedBytes = bytes(partial)
  if len(wantedBytes) == 0 then return void end if
  for each variable in registry.variables
    candidateBytes = bytes(variable.name)
    if len(candidateBytes) >= len(wantedBytes) then
      matches = true
      i = 0
      while i < len(wantedBytes)
        if candidateBytes[i] != wantedBytes[i] then matches = false end if
        i = i + 1
      end while
      if matches then return variable.name end if
    end if
  end for
  return void
end function

function quoteValue(text)
  // Cvar_WriteVariables writes the original string verbatim between quotes.
  return text
end function

function archiveText(registry)
  text = ""
  for each variable in registry.variables
    if variable.archive then
      text = text + variable.name + " \"" + quoteValue(variable.string) + "\"\n"
    end if
  end for
  return text
end function
