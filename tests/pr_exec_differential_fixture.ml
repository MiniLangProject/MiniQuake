/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/pr_exec_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.quakec.vm as vm
import miniquake.quakec.opcodes as op

// Exercise dummy function as part of this deterministic regression fixture.
function dummyFunction()
  return t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
end function

// Create and initialize machine.
function makeMachine(functionValue, statements)
  program = t.QuakeCProgram(
    "pr_exec_fixture.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    statements,
    [],
    [],
    [dummyFunction(), functionValue],
    bytes(1),
    vm.zeroArray(128),
    16,
  )
  return vm.create(program, 4)
end function

// Add exec to the destination state.
function emitExec(functionName, caseName, result, depth, locals, value, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"depth\":" + depth +
    ",\"locals\":" + locals + ",\"value\":" + native.floatText(value) +
    ",\"count\":" + count + "}"
end function

// Report mode and return the corresponding failure status.
function errorMode()
  functionValue = t.QuakeCFunction(0, 40, 0, 0, "error", "fixture.qc", 0, [])
  machine = makeMachine(functionValue, [t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  result = try(vm.PR_RunError(machine, "fatal fixture"))
  if result is error then return 42 end if
  return 0
end function

// Exercise hidden semantic checks as part of this deterministic regression fixture.
function hiddenSemanticChecks()
  functionValue = t.QuakeCFunction(0, 40, 0, 0, "stacked", "fixture.qc", 0, [])
  machine = makeMachine(functionValue, [t.QuakeCStatement(op.OP_DONE, 0, 0, 0)])
  entered = try(vm.PR_EnterFunction(machine, 1))
  if entered is error then return entered end if
  if len(vm.PR_StackTrace(machine)) != 2 then return error(9890, "active stack trace must include base frame") end if
  left = try(vm.PR_LeaveFunction(machine))
  if left is error then return left end if
  underflow = try(vm.PR_LeaveFunction(machine))
  if not underflow is error then return error(9891, "PR_LeaveFunction must reject stack underflow") end if

  // OP_STATE needs generated fields and a context.  A program without either
  // must surface PR_RunError instead of silently continuing past the opcode.
  stateFunction = t.QuakeCFunction(0, 40, 0, 0, "state_error", "fixture.qc", 0, [])
  stateMachine = makeMachine(stateFunction, [t.QuakeCStatement(op.OP_STATE, 28, 29, 0)])
  stateResult = try(vm.PR_ExecuteProgram(stateMachine, 1))
  if not stateResult is error then return error(9892, "OP_STATE error must abort PR_ExecuteProgram") end if
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  if len(args) > 0 and args[0] == "--error" then return errorMode() end if
  hidden = try(hiddenSemanticChecks())
  if hidden is error then return 1 end if

  functionValue = t.QuakeCFunction(0, 40, 0, 0, "fixture", "fixture.qc", 0, [])
  statement = t.QuakeCStatement(op.OP_ADD_F, 28, 29, 30)
  machine = makeMachine(functionValue, [statement])
  text = vm.PR_PrintStatement(machine, statement)
  emitExec("PR_PrintStatement", "add", 1, 0, 0, 0.0, 10)

  lines = vm.PR_StackTrace(machine)
  emitExec("PR_StackTrace", "empty", 1, 0, 0, 0.0, len(lines))

  machine.program.functions[0].profile = 3
  machine.program.functions[1].profile = 5
  lines = vm.PR_Profile_f(machine)
  emitExec(
    "PR_Profile_f",
    "ranked",
    1,
    0,
    0,
    machine.program.functions[0].profile + machine.program.functions[1].profile,
    len(lines),
  )

  result = try(vm.PR_RunError(machine, "fixture error"))
  emitExec("PR_RunError", "host_error", 1, len(machine.callStack), 0, 0.0, 10)

  enterFunction = t.QuakeCFunction(7, 40, 2, 0, "enter", "fixture.qc", 1, [1])
  machine = makeMachine(enterFunction, [])
  vm.setWord(machine, 40, 111)
  vm.setWord(machine, 41, 222)
  vm.setWord(machine, op.OFS_PARM0, 333)
  vm.PR_EnterFunction(machine, 1)
  emitExec(
    "PR_EnterFunction",
    "locals_params",
    6,
    len(machine.callStack),
    len(machine.callStack[0].savedLocals),
    vm.word(machine, 40),
    0,
  )
  vm.PR_LeaveFunction(machine)
  emitExec(
    "PR_LeaveFunction",
    "restore",
    0,
    len(machine.callStack),
    0,
    vm.word(machine, 40),
    0,
  )

  executeFunction = t.QuakeCFunction(0, 40, 0, 0, "add", "fixture.qc", 0, [])
  statements = [
    t.QuakeCStatement(op.OP_ADD_F, 28, 29, 30),
    t.QuakeCStatement(op.OP_RETURN, 30, 0, 0),
  ]
  machine = makeMachine(executeFunction, statements)
  vm.setGlobalFloat(machine, 28, 1.25)
  vm.setGlobalFloat(machine, 29, 2.5)
  vm.PR_ExecuteProgram(machine, 1)
  emitExec(
    "PR_ExecuteProgram",
    "add_return",
    1,
    len(machine.callStack),
    0,
    vm.globalFloat(machine, op.OFS_RETURN),
    machine.program.functions[1].profile,
  )
  return 0
end function
