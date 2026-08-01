package miniquake.cvar

import miniquake.types as t
import miniquake.native as native
import miniquake.common as common

function numericValue(text)
  // cvar_t.value is a C float even though MiniLang expressions may retain more
  // precision.  Keep the stored numeric view at the original binary32 boundary.
  return native.bitsFloat(native.floatBits(common.atof(text)))
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

function fixedSixValue(value)
  return native.fixedSixText(value)
end function

function setValue(registry, name, value)
  return set(registry, name, fixedSixValue(value))
end function

function command(registry, arguments)
  if len(arguments) == 0 then return [false, ""] end if
  variable = find(registry, arguments[0])
  if variable is void then return [false, ""] end if
  if len(arguments) == 1 then
    return [true, "\"" + variable.name + "\" is \"" + variable.string + "\""]
  end if
  set(registry, variable.name, arguments[1])
  return [true, ""]
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

// ---------------------------------------------------------------------------
// WinQuake cvar.c source-surface adapters.
//
// The C implementation stores its registry and current command arguments in
// globals. MiniQuake keeps those contexts explicit, so the original exported
// names are retained with the required context passed as parameters.
// ---------------------------------------------------------------------------

function Cvar_FindVar(registry, varName)
  return find(registry, varName)
end function

function Cvar_VariableValue(registry, varName)
  return variableValue(registry, varName)
end function

function Cvar_VariableString(registry, varName)
  return variableString(registry, varName)
end function

function Cvar_CompleteVariable(registry, partial)
  return completeVariable(registry, partial)
end function

function Cvar_Set(registry, varName, value)
  result = try(set(registry, varName, value))
  if result is error then
    // The original prints and returns when a variable does not exist. Keep the
    // adapter non-fatal while preserving the diagnostic for callers.
    return [false, result.message]
  end if
  return [true, ""]
end function

function Cvar_SetValue(registry, varName, value)
  result = try(setValue(registry, varName, value))
  if result is error then return [false, result.message] end if
  return [true, ""]
end function

function Cvar_RegisterVariable(registry, variable, commandExists)
  result = try(register(registry, variable, commandExists))
  if result is error then return [false, result.message] end if
  return [true, ""]
end function

function Cvar_Command(registry, arguments)
  return command(registry, arguments)
end function

function Cvar_WriteVariables(registry)
  return archiveText(registry)
end function

