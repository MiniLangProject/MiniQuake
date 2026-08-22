/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/cvar_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.native as native
import miniquake.cvar as cvarPort
import miniquake.host as hostPort

// Group the deterministic cvar command session fields used by this test fixture.
struct CvarCommandSession
  cvars
end struct

// Report whether differential command never exists holds for the active state.
function differentialCommandNeverExists(name)
  return false
end function

// Return number derived from the active module state.
function number(value)
  return native.floatText(value)
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  registry = cvarPort.createRegistry()
  cvarPort.register(registry, cvarPort.create("foo", "1.25", true, false), differentialCommandNeverExists)
  cvarPort.register(registry, cvarPort.create("bar", "7", false, true), differentialCommandNeverExists)
  cvarPort.register(registry, cvarPort.create("alpha", "4", false, false), differentialCommandNeverExists)
  print "{\"function\":\"Cvar_RegisterVariable\",\"case\":\"three\",\"count\":" +
    len(registry.variables) + ",\"values\":[" +
    number(cvarPort.variableValue(registry, "foo")) + "," +
    number(cvarPort.variableValue(registry, "bar")) + "," +
    number(cvarPort.variableValue(registry, "alpha")) + "]}"

  found = cvarPort.find(registry, "foo")
  missing = cvarPort.find(registry, "missing")
  missingFlag = 0
  if missing is void then missingFlag = 1 end if
  print "{\"function\":\"Cvar_FindVar\",\"case\":\"found-missing\",\"found\":\"" +
    found.name + "\",\"missing\":" + missingFlag + "}"
  print "{\"function\":\"Cvar_VariableValue\",\"case\":\"found-missing\",\"values\":[" +
    number(cvarPort.variableValue(registry, "foo")) + "," +
    number(cvarPort.variableValue(registry, "missing")) + "]}"
  print "{\"function\":\"Cvar_VariableString\",\"case\":\"found-missing\",\"values\":[\"" +
    cvarPort.variableString(registry, "foo") + "\",\"" +
    cvarPort.variableString(registry, "missing") + "\"]}"

  completion = cvarPort.completeVariable(registry, "al")
  empty = cvarPort.completeVariable(registry, "")
  emptyFlag = 0
  if empty is void then emptyFlag = 1 end if
  print "{\"function\":\"Cvar_CompleteVariable\",\"case\":\"prefix\",\"value\":\"" +
    completion + "\",\"empty\":" + emptyFlag + "}"

  cvarPort.set(registry, "bar", "9.5")
  changes = cvarPort.takeServerChanges(registry)
  print "{\"function\":\"Cvar_Set\",\"case\":\"server\",\"value\":" +
    number(cvarPort.variableValue(registry, "bar")) + ",\"string\":\"" +
    cvarPort.variableString(registry, "bar") + "\",\"broadcast\":" + len(changes) + "}"

  cvarPort.setValue(registry, "foo", 2.5)
  print "{\"function\":\"Cvar_SetValue\",\"case\":\"format\",\"value\":" +
    number(cvarPort.variableValue(registry, "foo")) + ",\"string\":\"" +
    cvarPort.variableString(registry, "foo") + "\"}"

  session = CvarCommandSession(registry)
  inspectResult = hostPort.cvarCommand(session, ["foo"])
  setResult = hostPort.cvarCommand(session, ["foo", "3.75"])
  inspectValue = 0
  if inspectResult then inspectValue = 1 end if
  setValue = 0
  if setResult then setValue = 1 end if
  print "{\"function\":\"Cvar_Command\",\"case\":\"inspect-set\",\"inspect\":" +
    inspectValue + ",\"set\":" + setValue + ",\"value\":" +
    number(cvarPort.variableValue(registry, "foo")) + "}"

  archived = cvarPort.archiveText(registry)
  archiveMatches = 0
  if archived == "foo \"3.75\"\n" then archiveMatches = 1 end if
  print "{\"function\":\"Cvar_WriteVariables\",\"case\":\"archive\",\"matches\":" +
    archiveMatches + ",\"length\":" + len(bytes(archived)) + "}"
  return 0
end function
