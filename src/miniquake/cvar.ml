/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.cvar.
*/
package miniquake.cvar

import miniquake.types as t
import miniquake.native as native
import miniquake.common as common
import std.ds.hashmap as hashmap

/// Return numeric value derived from the active module state.
/// @param text Text to parse or process.
function numericValue(text)
  // cvar_t.value is a C float even though MiniLang expressions may retain more
  // precision.  Keep the stored numeric view at the original binary32 boundary.
  return native.bitsFloat(native.floatBits(common.atof(text)))
end function

// Create and initialize registry.
function createRegistry()
  // Cvar_RegisterVariable keeps the original linked-list ordering in
  // variables. The hash index is private acceleration for the many per-frame
  // name lookups and has no effect on completion or archive order.
  return t.CvarRegistry([], [], hashmap.HashMap.withCapacity(256))
end function

/// Implements the `create` operation for `miniquake.cvar` (create).
/// @param name Stable name that identifies the requested object or option.
/// @param stringValue The string value input consumed by `create`.
/// @param archive The archive input consumed by `create`.
/// @param server Server state participating in the operation.
function create(name, stringValue, archive, server)
  return t.Cvar(name, stringValue, numericValue(stringValue), archive, server)
end function

/// Implements the `find` operation for `miniquake.cvar` (find).
/// @param registry The registry input consumed by `find`.
/// @param name Stable name that identifies the requested object or option.
function find(registry, name)
  if registry.lookup is not void then
    cached = registry.lookup.get(name)
    if cached is not void then return cached end if
  end if
  for each variable in registry.variables
    if variable.name == name then
      // A few legacy renderer initialization paths prepend directly to the
      // public variables list. Populate the index lazily for those entries.
      if registry.lookup is not void then registry.lookup.set(name, variable) end if
      return variable
    end if
  end for
  return void
end function

/// Update subsystem configuration for register.
/// @param registry The registry input consumed by `register`.
/// @param variable The variable input consumed by `register`.
/// @param commandExists The command exists input consumed by `register`.
function register(registry, variable, commandExists)
  if find(registry, variable.name) is not void then
    return error(1400, "Cvar_RegisterVariable: " + variable.name + " already defined")
  end if
  if commandExists(variable.name) then
    return error(1401, "Cvar_RegisterVariable: " + variable.name + " is a command")
  end if
  // Cvar_RegisterVariable links new variables at the head of cvar_vars.
  registry.variables = [variable] + registry.variables
  if registry.lookup is not void then registry.lookup.set(variable.name, variable) end if
  return variable
end function

/// Implements the `set` operation for `miniquake.cvar` (set).
/// @param registry The registry input consumed by `set`.
/// @param name Stable name that identifies the requested object or option.
/// @param stringValue The string value input consumed by `set`.
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

/// Consume pending state for take server changes.
/// @param registry The registry input consumed by `takeServerChanges`.
function takeServerChanges(registry)
  // Host drains this queue twice per frame, while server cvars change only on
  // explicit commands. Preserve the existing empty object in the common case
  // instead of replacing it with another short-lived empty array.
  if len(registry.serverChanges) == 0 then return registry.serverChanges end if
  changes = registry.serverChanges
  registry.serverChanges = []
  return changes
end function

/// Return fixed six value derived from the active module state.
/// @param value Value consumed by `fixedSixValue`.
function fixedSixValue(value)
  return native.fixedSixText(value)
end function

/// Update module state for value.
/// @param registry The registry input consumed by `setValue`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setValue`.
function setValue(registry, name, value)
  return set(registry, name, fixedSixValue(value))
end function

/// Implements the `command` operation for `miniquake.cvar` (command).
/// @param registry The registry input consumed by `command`.
/// @param arguments Command-line arguments to inspect or execute.
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

/// Return variable value derived from the active module state.
/// @param registry The registry input consumed by `variableValue`.
/// @param name Stable name that identifies the requested object or option.
function variableValue(registry, name)
  variable = find(registry, name)
  if variable is void then return 0.0 end if
  return variable.value
end function

/// Implements the `variableString` operation for `miniquake.cvar` (variable string).
/// @param registry The registry input consumed by `variableString`.
/// @param name Stable name that identifies the requested object or option.
function variableString(registry, name)
  variable = find(registry, name)
  if variable is void then return "" end if
  return variable.string
end function

/// Handle variable and update the associated state.
/// @param registry The registry input consumed by `completeVariable`.
/// @param partial The partial input consumed by `completeVariable`.
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

/// Convert data for quote value.
/// @param text Text to parse or process.
function quoteValue(text)
  // Cvar_WriteVariables writes the original string verbatim between quotes.
  return text
end function

/// Implements the `archiveText` operation for `miniquake.cvar` (archive text).
/// @param registry The registry input consumed by `archiveText`.
function archiveText(registry)
  text = ""
  for each variable in registry.variables
    if variable.archive then
      text = text + variable.name + " \"" + quoteValue(variable.string) + "\"\n"
    end if
  end for
  return text
end function

/// ---------------------------------------------------------------------------
/// WinQuake cvar.c source-surface adapters.
///
/// The C implementation stores its registry and current command arguments in
/// globals. MiniQuake keeps those contexts explicit, so the original exported
/// names are retained with the required context passed as parameters.
/// ---------------------------------------------------------------------------
/// @param registry The registry input consumed by `Cvar_FindVar`.
/// @param varName Name that identifies the requested value or resource.

function Cvar_FindVar(registry, varName)
  return find(registry, varName)
end function

/// Mirror Quake's Cvar_VariableValue routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_VariableValue`.
/// @param varName Name that identifies the requested value or resource.
function Cvar_VariableValue(registry, varName)
  return variableValue(registry, varName)
end function

/// Mirror Quake's Cvar_VariableString routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_VariableString`.
/// @param varName Name that identifies the requested value or resource.
function Cvar_VariableString(registry, varName)
  return variableString(registry, varName)
end function

/// Mirror Quake's Cvar_CompleteVariable routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_CompleteVariable`.
/// @param partial The partial input consumed by `Cvar_CompleteVariable`.
function Cvar_CompleteVariable(registry, partial)
  return completeVariable(registry, partial)
end function

/// Mirror Quake's Cvar_Set routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_Set`.
/// @param varName Name that identifies the requested value or resource.
/// @param value Value consumed by `Cvar_Set`.
function Cvar_Set(registry, varName, value)
  result = try(set(registry, varName, value))
  if result is error then
    // The original prints and returns when a variable does not exist. Keep the
    // adapter non-fatal while preserving the diagnostic for callers.
    return [false, result.message]
  end if
  return [true, ""]
end function

/// Mirror Quake's Cvar_SetValue routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_SetValue`.
/// @param varName Name that identifies the requested value or resource.
/// @param value Value consumed by `Cvar_SetValue`.
function Cvar_SetValue(registry, varName, value)
  result = try(setValue(registry, varName, value))
  if result is error then return [false, result.message] end if
  return [true, ""]
end function

/// Mirror Quake's Cvar_RegisterVariable routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_RegisterVariable`.
/// @param variable The variable input consumed by `Cvar_RegisterVariable`.
/// @param commandExists The command exists input consumed by `Cvar_RegisterVariable`.
function Cvar_RegisterVariable(registry, variable, commandExists)
  result = try(register(registry, variable, commandExists))
  if result is error then return [false, result.message] end if
  return [true, ""]
end function

/// Mirror Quake's Cvar_Command routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_Command`.
/// @param arguments Command-line arguments to inspect or execute.
function Cvar_Command(registry, arguments)
  return command(registry, arguments)
end function

/// Mirror Quake's Cvar_WriteVariables routine and its observable state changes.
/// @param registry The registry input consumed by `Cvar_WriteVariables`.
function Cvar_WriteVariables(registry)
  return archiveText(registry)
end function
