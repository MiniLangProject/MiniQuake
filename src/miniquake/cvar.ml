package miniquake.cvar

import miniquake.types as t
import miniquake.byteio as bio

function numericValue(text)
  value = toNumber(text)
  if value is void then return 0.0 end if
  return value
end function

function createRegistry()
  return t.CvarRegistry([])
end function

function create(name, stringValue, archive, server)
  return t.Cvar(name, stringValue, numericValue(stringValue), archive, server)
end function

function find(registry, name)
  wanted = bio.lower(name)
  for each variable in registry.variables
    if bio.lower(variable.name) == wanted then return variable end if
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
  registry.variables = registry.variables + [variable]
  return variable
end function

function set(registry, name, stringValue)
  variable = find(registry, name)
  if variable is void then return error(1402, "Cvar_Set: variable not found: " + name) end if
  variable.string = stringValue
  variable.value = numericValue(stringValue)
  return variable
end function

function setValue(registry, name, value)
  return set(registry, name, "" + value)
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
  wanted = bio.lower(partial)
  wantedBytes = bytes(wanted)
  for each variable in registry.variables
    candidate = bio.lower(variable.name)
    candidateBytes = bytes(candidate)
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
