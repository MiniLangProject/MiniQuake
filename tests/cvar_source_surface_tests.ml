/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-080 source-surface runtime entry. main(args) must remain in the global package.
*/
import miniquake.cvar as cvars
import miniquake.types as t
import miniquake.native as native

bp080Failures = 0
bp080Checks = 0

// Assert that the condition holds and identify a failing test.
function bp080Check(condition, label)
  global bp080Failures, bp080Checks
  bp080Checks = bp080Checks + 1
  if not condition then
    bp080Failures = bp080Failures + 1
    print "FAIL: " + label
  end if
end function

// Assert exact equality and report both values on failure.
function bp080Equal(actual, expected, label)
  bp080Check(actual == expected, label + ": expected " + expected + ", got " + actual)
end function

// Report whether command exists holds for the active state.
function bp080CommandExists(name)
  return name == "echo"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  global bp080Failures, bp080Checks

  registry = cvars.createRegistry()
  alpha = cvars.create("alpha", "1", true, false)
  server = cvars.create("server_value", "2", false, true)

  print "[1/20] find missing"
  bp080Check(cvars.Cvar_FindVar(registry, "alpha") is void, "missing variable")

  print "[2/20] register alpha"
  result = cvars.Cvar_RegisterVariable(registry, alpha, bp080CommandExists)
  bp080Check(result[0], "register alpha")

  print "[3/20] find alpha"
  bp080Check(cvars.Cvar_FindVar(registry, "alpha") == alpha, "find alpha")

  print "[4/20] duplicate registration"
  duplicate = cvars.Cvar_RegisterVariable(registry, alpha, bp080CommandExists)
  bp080Check(not duplicate[0], "duplicate rejected")

  print "[5/20] command collision"
  echoVariable = cvars.create("echo", "1", false, false)
  collision = cvars.Cvar_RegisterVariable(registry, echoVariable, bp080CommandExists)
  bp080Check(not collision[0], "command collision rejected")

  print "[6/20] variable value"
  bp080Equal(native.floatBits(cvars.Cvar_VariableValue(registry, "alpha")), native.floatBits(1.0), "alpha numeric")

  print "[7/20] missing value"
  bp080Equal(native.floatBits(cvars.Cvar_VariableValue(registry, "missing")), native.floatBits(0.0), "missing numeric")

  print "[8/20] variable string"
  bp080Equal(cvars.Cvar_VariableString(registry, "alpha"), "1", "alpha string")

  print "[9/20] missing string"
  bp080Equal(cvars.Cvar_VariableString(registry, "missing"), "", "missing string")

  print "[10/20] completion"
  bp080Equal(cvars.Cvar_CompleteVariable(registry, "al"), "alpha", "completion")

  print "[11/20] empty completion"
  bp080Check(cvars.Cvar_CompleteVariable(registry, "") is void, "empty completion")

  print "[12/20] set"
  setResult = cvars.Cvar_Set(registry, "alpha", "3.5")
  bp080Check(setResult[0], "set alpha")
  bp080Equal(cvars.Cvar_VariableString(registry, "alpha"), "3.5", "set string")

  print "[13/20] set missing"
  missingSet = cvars.Cvar_Set(registry, "missing", "7")
  bp080Check(not missingSet[0], "missing set non-fatal")

  print "[14/20] set value formatting"
  setValueResult = cvars.Cvar_SetValue(registry, "alpha", 0.8)
  bp080Check(setValueResult[0], "set value")
  bp080Equal(cvars.Cvar_VariableString(registry, "alpha"), "0.800000", "set value text")

  print "[15/20] register server cvar"
  bp080Check(cvars.Cvar_RegisterVariable(registry, server, bp080CommandExists)[0], "register server")

  print "[16/20] server change"
  bp080Check(cvars.Cvar_Set(registry, "server_value", "4")[0], "set server")
  changes = cvars.takeServerChanges(registry)
  bp080Equal(len(changes), 1, "server changes")
  bp080Equal(changes[0][0], "server_value", "server change name")

  print "[17/20] command query"
  query = cvars.Cvar_Command(registry, ["alpha"])
  bp080Check(query[0], "command handled")
  bp080Check(len(bytes(query[1])) > 0, "command query output")

  print "[18/20] command set"
  commandSet = cvars.Cvar_Command(registry, ["alpha", "9"])
  bp080Check(commandSet[0], "command set handled")
  bp080Equal(cvars.Cvar_VariableString(registry, "alpha"), "9", "command set value")

  print "[19/20] non-cvar command"
  notHandled = cvars.Cvar_Command(registry, ["unknown"])
  bp080Check(not notHandled[0], "unknown command")

  print "[20/20] archive output"
  archive = cvars.Cvar_WriteVariables(registry)
  bp080Check(archive == "alpha \"9\"\n", "archive text")

  if bp080Failures > 0 then
    print "MiniQuake BP-080 cvar source-surface tests failed: " + bp080Failures + "/" + bp080Checks
    return 1
  end if
  print "MiniQuake BP-080 cvar source-surface tests passed: 20"
  return 0
end function
