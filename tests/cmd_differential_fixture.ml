import miniquake.cmd as cmd
import miniquake.sizebuf as sz

callbackCalls = 0

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function markCallback(arguments)
  global callbackCalls
  callbackCalls = callbackCalls + 1
  return true
end function

function repeated(value, count)
  result = ""
  index = 0
  while index < count
    result = result + value
    index = index + 1
  end while
  return result
end function

function main(args)
  global callbackCalls
  waitSystem = cmd.create()
  cmd.Cmd_Wait_f(waitSystem)
  print "{\"function\":\"Cmd_Wait_f\",\"case\":\"set\",\"wait\":" + boolText(waitSystem.wait) + "}"

  initialized = cmd.Cbuf_Init()
  print "{\"function\":\"Cbuf_Init\",\"case\":\"capacity\",\"capacity\":8192,\"size\":" + len(bytes(initialized.text)) + "}"

  boundary = cmd.Cbuf_Init()
  cmd.Cbuf_AddText(boundary, repeated("x", 8190))
  cmd.Cbuf_AddText(boundary, "x")
  overflowAccepted = cmd.Cbuf_AddText(boundary, "x")
  print "{\"function\":\"Cbuf_AddText\",\"case\":\"boundary\",\"size\":" + len(bytes(boundary.text)) + ",\"overflow_rejected\":" + boolText(not overflowAccepted) + "}"

  inserted = cmd.Cbuf_Init()
  cmd.Cbuf_AddText(inserted, "tail")
  cmd.Cbuf_InsertText(inserted, "head")
  print "{\"function\":\"Cbuf_InsertText\",\"case\":\"prepend\",\"text\":\"" + inserted.text + "\"}"

  callbackCalls = 0
  execute = cmd.Cbuf_Init()
  cmd.Cmd_Init(execute)
  cmd.Cmd_AddCommand(execute, "mark", markCallback, false)
  cmd.Cbuf_AddText(execute, "mark one;wait;mark two")
  cmd.Cbuf_Execute(execute)
  print "{\"function\":\"Cbuf_Execute\",\"case\":\"wait_defers\",\"calls\":" + callbackCalls + ",\"remaining\":\"" + execute.text + "\"}"

  stuffed = cmd.Cbuf_Init()
  cmd.Cmd_TokenizeString(stuffed, "stuffcmds")
  cmd.Cmd_StuffCmds_f(stuffed, ["quake", "+foo", "bar", "-x", "+baz", "qux"])
  print "{\"function\":\"Cmd_StuffCmds_f\",\"case\":\"plus_commands\",\"size\":" + len(bytes(stuffed.text)) + ",\"content_ok\":" + boolText(stuffed.text == "foo bar \nbaz qux\n") + "}"

  execSystem = cmd.Cbuf_Init()
  execArgs = ["exec", "script.cfg"]
  cmd.Cmd_Exec_f(execSystem, execArgs, "echo loaded\n")
  print "{\"function\":\"Cmd_Exec_f\",\"case\":\"loaded\",\"size\":" + len(bytes(execSystem.text)) + ",\"content_ok\":" + boolText(execSystem.text == "echo loaded\n") + "}"

  echoArguments = ["echo", "one", "two"]
  echoPrints = cmd.Cmd_Echo_f(echoArguments)
  print "{\"function\":\"Cmd_Echo_f\",\"case\":\"two_args\",\"prints\":" + echoPrints + "}"

  copied = cmd.CopyString("quake")
  print "{\"function\":\"CopyString\",\"case\":\"copy\",\"text\":\"" + copied + "\",\"distinct\":" + boolText(copied == "quake") + "}"

  aliasSystem = cmd.create()
  alias = cmd.Cmd_Alias_f(aliasSystem, ["alias", "combo", "echo", "hi"])
  print "{\"function\":\"Cmd_Alias_f\",\"case\":\"create\",\"name\":\"" + alias.name + "\",\"value_size\":" + len(bytes(alias.value)) + ",\"trailing_space\":" + boolText(alias.value == "echo hi \n") + "}"

  initSystem = cmd.create()
  cmd.Cmd_Init(initSystem)
  print "{\"function\":\"Cmd_Init\",\"case\":\"stock\",\"commands\":" + len(initSystem.commands) + "}"

  tokenSystem = cmd.create()
  cmd.Cmd_TokenizeString(tokenSystem, "alpha one \"two words\"")
  print "{\"function\":\"Cmd_Argc\",\"case\":\"tokenized\",\"argc\":" + cmd.Cmd_Argc(tokenSystem) + "}"
  print "{\"function\":\"Cmd_Argv\",\"case\":\"bounds\",\"first\":\"" + cmd.Cmd_Argv(tokenSystem, 0) + "\",\"missing\":\"" + cmd.Cmd_Argv(tokenSystem, 9) + "\"}"
  print "{\"function\":\"Cmd_Args\",\"case\":\"tail\",\"args_size\":" + len(bytes(cmd.Cmd_Args(tokenSystem))) + ",\"raw_quotes\":" + boolText(cmd.Cmd_Args(tokenSystem) == "one \"two words\"") + "}"
  print "{\"function\":\"Cmd_TokenizeString\",\"case\":\"quoted\",\"argc\":" + cmd.Cmd_Argc(tokenSystem) + ",\"second\":\"" + cmd.Cmd_Argv(tokenSystem, 1) + "\",\"third\":\"" + cmd.Cmd_Argv(tokenSystem, 2) + "\"}"

  commandSystem = cmd.create()
  cmd.Cmd_AddCommand(commandSystem, "known", markCallback, false)
  duplicate = try(cmd.Cmd_AddCommand(commandSystem, "known", markCallback, false))
  variable = try(cmd.Cmd_AddCommand(commandSystem, "taken", markCallback, true))
  rejections = 0
  if duplicate is error then rejections = rejections + 1 end if
  if variable is error then rejections = rejections + 1 end if
  print "{\"function\":\"Cmd_AddCommand\",\"case\":\"duplicates\",\"exists\":" + boolText(cmd.Cmd_Exists(commandSystem, "known")) + ",\"rejections\":" + rejections + "}"
  print "{\"function\":\"Cmd_Exists\",\"case\":\"known_missing\",\"known\":" + boolText(cmd.Cmd_Exists(commandSystem, "known")) + ",\"missing\":" + boolText(cmd.Cmd_Exists(commandSystem, "missing")) + "}"

  completeSystem = cmd.create()
  cmd.Cmd_AddCommand(completeSystem, "status", markCallback, false)
  print "{\"function\":\"Cmd_CompleteCommand\",\"case\":\"prefix\",\"match\":\"" + cmd.Cmd_CompleteCommand(completeSystem, "sta") + "\",\"case_sensitive_null\":" + boolText(cmd.Cmd_CompleteCommand(completeSystem, "Sta") is void) + "}"

  callbackCalls = 0
  executeSystem = cmd.create()
  cmd.Cmd_AddCommand(executeSystem, "known", markCallback, false)
  cmd.Cmd_ExecuteString(executeSystem, "KNOWN one", 1)
  print "{\"function\":\"Cmd_ExecuteString\",\"case\":\"registered\",\"calls\":" + callbackCalls + ",\"source\":1}"

  forwardSystem = cmd.create()
  cmd.Cmd_TokenizeString(forwardSystem, "say hi")
  outgoing = sz.alloc(64)
  cmd.Cmd_ForwardToServer(forwardSystem, outgoing, false, false)
  print "{\"function\":\"Cmd_ForwardToServer\",\"case\":\"disconnected\",\"bytes\":" + outgoing.curSize + "}"

  checkSystem = cmd.create()
  cmd.Cmd_TokenizeString(checkSystem, "tool -first value")
  print "{\"function\":\"Cmd_CheckParm\",\"case\":\"found_missing\",\"found\":" + cmd.Cmd_CheckParm(checkSystem, "-FIRST") + ",\"missing\":" + cmd.Cmd_CheckParm(checkSystem, "-none") + "}"
  return 0
end function
