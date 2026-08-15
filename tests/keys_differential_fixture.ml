/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/keys_differential_fixture.ml.
*/
import miniquake.keys as keys
import miniquake.input as input
import miniquake.console as console
import miniquake.cmd as commandSystem
import miniquake.cvar as variables

// Return bool number derived from the active module state.
function boolNumber(value)
  if value then return 1 end if
  return 0
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  input.unbindAll()
  keys.Key_Init()
  print "{\"function\":\"Key_Init\",\"case\":\"tables\",\"registered\":" +
    len(keys.registeredCommandNames) + ",\"console_a\":" +
    keys.consoleKeys[97] + ",\"console_tick\":" + keys.consoleKeys[96] +
    ",\"shift_a\":" + keys.keyShift[97] + ",\"menu_f12\":" +
    keys.menuBound[keys.K_F12] + ",\"linepos\":" + keys.keyLinePos + "}"

  state = console.create(64)
  commands = commandSystem.create()
  registry = variables.createRegistry()
  keys.Key_Console(104, state, commands, registry, 25)
  keys.Key_Console(105, state, commands, registry, 25)
  queued = keys.Key_Console(keys.K_ENTER, state, commands, registry, 25)
  queuedExact = 0
  if queued == "hi\n" then queuedExact = 1 end if
  print "{\"function\":\"Key_Console\",\"case\":\"submit\",\"queued\":" +
    queuedExact + ",\"line\":\"hi\",\"edit\":" + keys.editLine +
    ",\"linepos\":" + keys.keyLinePos + "}"

  keys.beginMessage(false)
  keys.Key_Message(104)
  keys.Key_Message(105)
  message = keys.Key_Message(keys.K_ENTER)
  messageExact = 0
  if message == "say \"hi\"\n" then messageExact = 1 end if
  print "{\"function\":\"Key_Message\",\"case\":\"say\",\"queued\":" +
    messageExact + ",\"destination\":" + keys.destination() +
    ",\"empty\":" + boolNumber(keys.chatBuffer == "") + "}"

  print "{\"function\":\"Key_StringToKeynum\",\"case\":\"names\",\"ascii\":" +
    keys.Key_StringToKeynum("a") + ",\"arrow\":" +
    keys.Key_StringToKeynum("UPARROW") + ",\"unknown\":" +
    keys.Key_StringToKeynum("not-a-key") + "}"

  print "{\"function\":\"Key_KeynumToString\",\"case\":\"names\",\"mouse\":\"" +
    keys.Key_KeynumToString(keys.K_MOUSE2) + "\",\"missing\":\"" +
    keys.Key_KeynumToString(-1) + "\",\"ascii\":\"" +
    keys.Key_KeynumToString(65) + "\"}"

  keys.Key_SetBinding(65, "+attack")
  print "{\"function\":\"Key_SetBinding\",\"case\":\"replace\",\"binding\":\"" +
    input.bindingForCode(65) + "\"}"

  keys.Key_Unbind_f(["unbind", "A"])
  print "{\"function\":\"Key_Unbind_f\",\"case\":\"bound\",\"empty\":" +
    boolNumber(input.bindingForCode(65) == "") + "}"

  keys.Key_SetBinding(65, "+attack")
  keys.Key_SetBinding(66, "+use")
  keys.Key_Unbindall_f()
  active = 0
  code = 0
  while code < 256
    binding = input.bindingForCode(code)
    if binding is not void and binding != "" then active = active + 1 end if
    code = code + 1
  end while
  print "{\"function\":\"Key_Unbindall_f\",\"case\":\"all\",\"active\":" +
    active + "}"

  keys.Key_Bind_f(["bind", "MOUSE1", "+attack"])
  print "{\"function\":\"Key_Bind_f\",\"case\":\"set\",\"binding\":\"" +
    input.bindingForCode(keys.K_MOUSE1) + "\"}"

  written = keys.Key_WriteBindings()
  writeExact = 0
  if written == "bind \"MOUSE1\" \"+attack\"\n" then writeExact = 1 end if
  print "{\"function\":\"Key_WriteBindings\",\"case\":\"one\",\"exact\":" +
    writeExact + ",\"length\":" + len(bytes(written)) + "}"

  keys.Key_SetBinding(97, "+attack")
  keys.setDestination(keys.KEY_GAME)
  down = keys.Key_Event(
    97, true, state, commands, registry, false, false
  )
  keys.Key_Event(97, true, state, commands, registry, false, false)
  released = keys.Key_Event(
    97, false, state, commands, registry, false, false
  )
  downExact = 0
  releaseExact = 0
  if down[0] == "+attack 97\n" then downExact = 1 end if
  if released[0] == "-attack 97\n" then releaseExact = 1 end if
  print "{\"function\":\"Key_Event\",\"case\":\"button-repeat\",\"down\":" +
    downExact + ",\"release\":" + releaseExact + ",\"repeat\":" +
    keys.keyRepeats[97] + ",\"keydown\":" +
    boolNumber(keys.keyDownStates[97]) + ",\"last\":" +
    keys.keyLastPress + "}"

  keys.Key_Event(
    keys.K_SHIFT, true, state, commands, registry, false, false
  )
  keys.Key_Event(97, true, state, commands, registry, false, false)
  keys.Key_ClearStates()
  print "{\"function\":\"Key_ClearStates\",\"case\":\"held\",\"shift\":" +
    boolNumber(keys.shiftDown) + ",\"repeat\":" + keys.keyRepeats[97] +
    ",\"keydown\":" + boolNumber(keys.keyDownStates[97]) + "}"
  return 0
end function
