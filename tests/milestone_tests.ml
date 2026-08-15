/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/milestone_tests.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.launch as launch
import miniquake.host as host
import miniquake.input as gameInput
import miniquake.keys as keys
import miniquake.cmd as commandSystem
import miniquake.cvar as variables
import miniquake.runtime_validation as runtimeValidation
import miniquake.console as console
import miniquake.menu as menu
import miniquake.statusbar as statusbar
import miniquake.view as view
import miniquake.particles as particles
import miniquake.client_effects as effects
import miniquake.client_protocol as protocol
import miniquake.client as client
import miniquake.player_move as movement
import miniquake.demo as demo
import miniquake.demo_player as demoPlayer
import miniquake.savegame as savegame
import miniquake.net_datagram as datagram
import miniquake.net_control as netControl
import miniquake.net_loop as netloop
import miniquake.net_main as netmain
import miniquake.net_udp as netUdp
import miniquake.server as server
import miniquake.edict as edict
import miniquake.sound.mixer as mixer
import miniquake.sizebuf as sz
import miniquake.message as msg
import miniquake.protocol_write as protocolWriter
import miniquake.byteio as bio
import miniquake.quakec.vm as vm
import miniquake.quakec.edict as quakecEdict
import miniquake.platform.win32 as platformWin

// Assert exact equality and report both values on failure.
function assertEqual(actual, expected, name)
  if actual != expected then return error(9100, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Assert that the condition holds and identify a failing test.
function assertTrue(value, name)
  if value != true then return error(9101, name + ": expected true") end if
  return true
end function

// Assert floating-point equality within the requested tolerance.
function assertNear(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(9102, name + ": expected " + expected + " +/- " + tolerance + ", got " + actual) end if
  return true
end function

// Exercise receive udp as part of this deterministic regression fixture.
function receiveUdp(socket, attempts)
  index = 0
  while index < attempts
    received = try(netUdp.receive(socket, 2048))
    if received is error then return received end if
    if received is not void then return received end if
    platformWin.sleep(1)
    index = index + 1
  end while
  return error(9103, "UDP fixture timed out")
end function

// Verify launch parsing against the expected Quake behavior.
function testLaunchParsing()
  options = launch.parse(["-basedir", "C:/Quake", "-game", "hipnotic", "-width", "1024", "-height", "768", "-nosound", "+map", "e1m1"])
  assertEqual(options.basedir, "C:/Quake", "basedir")
  assertEqual(options.gameDirectory, "hipnotic", "game directory")
  assertEqual(options.width, 1024, "width")
  assertEqual(options.height, 768, "height")
  assertEqual(options.noSound, true, "nosound")
  assertEqual(options.startMap, "e1m1", "start map")
  assertTrue(len(options.plusCommands) == 1, "plus command count")
  attract = launch.parse(["--play", "C:/Quake"])
  assertEqual(attract.basedir, "C:/Quake", "directory-only play basedir")
  assertEqual(attract.startMap, "", "directory-only play leaves map to startdemos")
  assertEqual(len(attract.plusCommands), 0, "directory-only play has no map command")
  direct = launch.parse(["--play", "C:/Quake", "e1m2", "-nosound"])
  assertEqual(direct.startMap, "e1m2", "play optional map")
  assertEqual(direct.noSound, true, "play options continue after optional map")
  assertEqual(len(direct.plusCommands), 1, "play optional map command")
  return true
end function

// Verify host timing against the expected Quake behavior.
function testHostTiming()
  timing = t.HostTiming(0.0, 0.0, 0.0, 0, 0)
  assertEqual(host.filterTime(timing, 0.001, 72.0, 0.0, false), false, "filtered short frame")
  assertEqual(timing.filteredFrames, 1, "filtered counter")
  assertEqual(host.filterTime(timing, 0.02, 72.0, 0.0, false), true, "accepted frame")
  assertNear(timing.frameTime, 0.02, 0.00001, "elapsed frame time")
  assertEqual(host.filterTime(timing, 0.04, 0.0, 0.05, false), true, "forced frame")
  assertNear(timing.frameTime, 0.05, 0.00001, "forced frame time")
  assertEqual(runtimeValidation.worldFaceCount(void), 0, "void world has zero validation faces")
  assertEqual(runtimeValidation.renderSurfaceCount(void), 0, "headless renderer has zero validation surfaces")
  return true
end function

// Verify move command encoding against the expected Quake behavior.
function testMoveCommandEncoding()
  // usercmd_t stores movement as float in WinQuake, while MSG_WriteShort takes
  // int. This verifies the same truncation at MiniQuake's protocol boundary.
  command = t.UserCommand(
    t.Vec3(45.0, 90.0, 180.0),
    200.75,
    -123.75,
    0.0,
    3,
    7,
    20.0,
  )
  buffer = sz.alloc(64)
  protocolWriter.writeMove(buffer, command, 12.5)
  reader = msg.beginReading(buffer)

  assertEqual(msg.readByte(reader), c.CLC_MOVE, "move command opcode")
  assertNear(msg.readFloat(reader), 12.5, 0.0001, "move command client time")
  assertNear(msg.readAngle(reader), 45.0, 0.0001, "move command pitch")
  assertNear(msg.readAngle(reader), 90.0, 0.0001, "move command yaw")
  assertNear(msg.readAngle(reader), -180.0, 0.0001, "move command roll")
  assertEqual(msg.readShort(reader), 200, "move command forward truncation")
  assertEqual(msg.readShort(reader), -123, "move command side truncation")
  assertEqual(msg.readShort(reader), 0, "move command zero upmove")
  assertEqual(msg.readByte(reader), 3, "move command buttons")
  assertEqual(msg.readByte(reader), 7, "move command impulse")
  assertEqual(msg.remaining(reader), 0, "move command payload consumed")
  return true
end function

// Verify console state against the expected Quake behavior.
function testConsoleState()
  state = console.create(32)
  index = 0
  while index < 40
    console.appendLine(state, "line " + index)
    index = index + 1
  end while
  assertEqual(len(state.lines), 32, "console ring size")
  assertEqual(state.lines[0], "line 8", "console oldest line")
  console.appendCharacter(state, 65)
  console.appendCharacter(state, 66)
  console.backspace(state)
  assertEqual(console.takeInput(state), "A", "console editing")
  console.centerPrint(state, "CENTER", 1.0, 2.0)
  assertEqual(console.clearExpiredCenter(state, 2.0), "CENTER", "center still active")
  assertEqual(console.clearExpiredCenter(state, 3.0), "", "center expired")
  return true
end function

// Verify menu state against the expected Quake behavior.
function testMenuState()
  state = menu.create()
  assertEqual(state.active, false, "menu initially closed")
  assertEqual(state.page, menu.PAGE_MAIN, "menu starts at classic main page")
  assertEqual(len(state.items), 5, "classic main menu item count")
  menu.setActive(state, true)
  assertEqual(state.active, true, "menu opened")
  menu.move(state, -1)
  assertEqual(state.selection, 4, "main menu wraps upward")
  assertEqual(menu.selectedCommand(state), "menu_quit", "main menu quit action")
  menu.setPage(state, menu.PAGE_SINGLE)
  assertEqual(len(state.items), 3, "single-player item count")
  assertEqual(menu.selectedCommand(state), "new_game", "single-player new game action")
  assertEqual(menu.back(state), "page", "submenu returns to main")
  assertEqual(state.page, menu.PAGE_MAIN, "submenu back page")
  menu.setPage(state, menu.PAGE_OPTIONS)
  assertEqual(len(state.items), 14, "classic WinQuake options item count")
  menu.setPage(state, menu.PAGE_KEYS)
  assertEqual(len(state.items), 18, "classic key menu command count")
  assertEqual(menu.keyCommandAt(state), "+attack", "key menu first command")
  state.waitingForKey = true
  assertEqual(menu.back(state), "page", "escape cancels key grab")
  assertEqual(state.page, menu.PAGE_KEYS, "cancel key grab keeps page")
  assertEqual(menu.back(state), "page", "keys page returns to options")
  assertEqual(state.page, menu.PAGE_OPTIONS, "keys parent page")
  menu.setPage(state, menu.PAGE_LOAD)
  assertEqual(len(state.items), 12, "classic save slot count")
  assertEqual(menu.back(state), "page", "load returns to single player")
  assertEqual(state.page, menu.PAGE_SINGLE, "load parent page")
  menu.setPage(state, menu.PAGE_HELP)
  menu.changeHelpPage(state, -1)
  assertEqual(state.helpPage, 5, "help page wraps backward")
  return true
end function

// Verify mouse scaling against the expected Quake behavior.
function testMouseScaling()
  command = gameInput.createCommand()
  gameInput.applyMouseDelta(command, 100.0, 50.0, 3.0, 0.022, 0.022)
  assertNear(command.viewAngles.y, 353.402709960938, 0.00001, "mouse yaw uses quantized anglemod")
  assertNear(command.viewAngles.x, 3.3, 0.001, "mouse pitch uses m_pitch scale")
  gameInput.applyMouseDelta(command, 0.0, 10000.0, 3.0, 0.022, 0.022)
  assertEqual(command.viewAngles.x, 80.0, "mouse pitch upper clamp")
  return true
end function

// Verify key bindings against the expected Quake behavior.
function testKeyBindings()
  gameInput.resetBindings()
  assertEqual(gameInput.commandForKey("W"), "+forward", "default W binding")
  assertTrue(gameInput.bindKey("Q", "+attack"), "bind Q")
  assertEqual(gameInput.commandForKey("Q"), "+attack", "Q attack binding")
  found = gameInput.bindingsForCommand("+attack")
  assertTrue(len(found) >= 2, "two attack bindings are discoverable")
  assertTrue(gameInput.unbindCommand("+attack"), "unbind command")
  assertEqual(gameInput.bindingForCommand("+attack"), "???", "attack binding cleared")
  gameInput.resetBindings()

  // cl_input.c kbutton_t: two physical keys may hold one logical action.
  button = gameInput.createButton()
  assertEqual(gameInput.KeyDown(button, 11), true, "first holder presses button")
  assertEqual(gameInput.KeyDown(button, 12), false, "second holder adds no new down edge")
  assertEqual(button[0], 11, "first key holder")
  assertEqual(button[1], 12, "second key holder")
  assertEqual(gameInput.KeyUp(button, 11), false, "first release leaves second holder")
  assertNear(gameInput.CL_KeyState(button), 0.5, 0.0001, "pressed and held frame fraction")
  assertEqual(gameInput.KeyUp(button, 12), true, "last holder releases button")
  assertNear(gameInput.CL_KeyState(button), 0.0, 0.0001, "release frame fraction")

  tapped = gameInput.createButton()
  gameInput.KeyDown(tapped, 21)
  gameInput.KeyUp(tapped, 21)
  assertNear(gameInput.CL_KeyState(tapped), 0.25, 0.0001, "press and release in one frame")
  gameInput.KeyDown(tapped, 21)
  gameInput.CL_KeyState(tapped)
  gameInput.KeyUp(tapped, 21)
  gameInput.KeyDown(tapped, 21)
  assertNear(gameInput.CL_KeyState(tapped), 0.75, 0.0001, "release and repress in one frame")
  gameInput.KeyUp(tapped, void)
  assertEqual(tapped[0], 0, "manual keyup unsticks first holder")
  assertEqual(tapped[1], 0, "manual keyup unsticks second holder")
  assertEqual(tapped[2], 4, "manual keyup leaves impulse-up")

  commands = gameInput.CL_InitInput()
  assertEqual(len(commands), 35, "CL_InitInput stock command count")
  command = gameInput.createCommand()
  gameInput.IN_ForwardDown(87)
  assertEqual(gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5), true, "CL_BaseMove active signon")
  assertNear(command.forwardMove, 100.0, 0.0001, "impulse-down contributes half frame")
  gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5)
  assertNear(command.forwardMove, 200.0, 0.0001, "held forward contributes full frame")
  gameInput.IN_SpeedDown(16)
  gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5)
  assertNear(command.forwardMove, 400.0, 0.0001, "speed key scales movement")

  gameInput.IN_ClearStates()
  command.viewAngles.y = 20.0
  gameInput.IN_StrafeDown(1)
  gameInput.IN_RightDown(2)
  gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5)
  assertNear(command.sideMove, 175.0, 0.0001, "strafe converts turn key to side move")
  assertNear(command.viewAngles.y, 20.0, 0.0001, "strafe suppresses keyboard yaw")

  gameInput.IN_ClearStates()
  command.viewAngles = t.Vec3(0.0, 0.0, 0.0)
  gameInput.IN_RightDown(2)
  gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5)
  assertNear(command.viewAngles.y, 353.001708984375, 0.00001, "turn key uses quantized anglemod")

  gameInput.IN_ClearStates()
  command.viewAngles = t.Vec3(0.0, 0.0, 0.0)
  gameInput.IN_KLookDown(1)
  gameInput.IN_ForwardDown(2)
  gameInput.CL_BaseMove(command, c.SIGNONS, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5)
  assertNear(command.viewAngles.x, -7.5, 0.0001, "klook turns forward into pitch")
  assertNear(command.forwardMove, 0.0, 0.0001, "klook suppresses forward movement")

  gameInput.IN_ClearStates()
  gameInput.IN_AttackDown(1)
  gameInput.IN_AttackUp(1)
  assertEqual(gameInput.CL_ButtonBits(), c.BUTTON_ATTACK, "attack tap survives until move packet")
  assertEqual(gameInput.CL_ButtonBits(), 0, "attack impulse-down is consumed once")
  gameInput.IN_JumpDown(2)
  assertEqual(gameInput.CL_ButtonBits(), c.BUTTON_JUMP, "jump impulse-down button bit")
  assertEqual(gameInput.CL_ButtonBits(), c.BUTTON_JUMP, "held jump remains asserted")
  gameInput.IN_Impulse(255)
  assertEqual(gameInput.CL_TakeImpulse(), 255, "impulse accepts original byte range")
  assertEqual(gameInput.CL_TakeImpulse(), 0, "impulse is consumed once")

  gameInput.IN_ClearStates()
  gameInput.consumePitchDriftRequests()
  gameInput.IN_MLookDown(3)
  command = gameInput.createCommand()
  gameInput.IN_MoveDelta(command, 10.0, 5.0, 3.0, 0.022, 0.022, 0.8, 1.0, false, false)
  assertNear(command.viewAngles.y, -0.66, 0.0001, "mlook mouse yaw")
  assertNear(command.viewAngles.x, 0.33, 0.0001, "mlook mouse pitch")
  gameInput.setLookSpring(true)
  gameInput.IN_MLookUp(3)
  drift = gameInput.consumePitchDriftRequests()
  assertEqual(drift[0], true, "mlook requests pitch-drift stop")
  assertEqual(drift[1], true, "mlook release requests lookspring")
  gameInput.setLookSpring(false)

  inactive = gameInput.createCommand()
  inactive.forwardMove = 33.0
  assertEqual(gameInput.CL_BaseMove(inactive, c.SIGNON_SPAWN, 0.1, 200.0, 200.0, 350.0, 200.0, 2.0, 140.0, 150.0, 1.5), false, "CL_BaseMove rejects incomplete signon")
  assertNear(inactive.forwardMove, 33.0, 0.0001, "incomplete signon preserves command")
  gameInput.IN_ClearStates()

  keys.Key_Init()
  assertEqual(keys.Key_StringToKeynum("a"), 97, "single ASCII key number")
  assertEqual(keys.Key_StringToKeynum("UPARROW"), keys.K_UPARROW, "named arrow key number")
  assertEqual(keys.Key_StringToKeynum("AUX32"), 238, "last auxiliary key number")
  assertEqual(keys.Key_StringToKeynum("SEMICOLON"), 59, "semicolon key alias")
  assertEqual(keys.Key_StringToKeynum("not-a-key"), -1, "unknown key number")
  assertEqual(keys.Key_KeynumToString(keys.K_MOUSE2), "MOUSE2", "mouse key name")
  assertEqual(keys.Key_KeynumToString(-1), "<KEY NOT FOUND>", "missing key name")

  gameInput.unbindAll()
  keys.Key_SetBinding(97, "+attack")
  keyConsole = console.create(64)
  keyCommands = commandSystem.create()
  keyVariables = variables.createRegistry()
  keys.setDestination(keys.KEY_GAME)
  eventResult = keys.Key_Event(97, true, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[0], "+attack 97\n", "keydown appends original key number")
  repeatResult = keys.Key_Event(97, true, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(repeatResult[0], "", "normal key autorepeat suppressed")
  eventResult = keys.Key_Event(97, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[0], "-attack 97\n", "keyup emits matching button release")
  keys.Key_SetBinding(65, "+use")
  keys.Key_Event(97, true, keyConsole, keyCommands, keyVariables, false, false)
  eventResult = keys.Key_Event(97, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[0], "-attack 97\n-use 97\n", "keyup releases base and shifted bindings")

  gameInput.unbindAll()
  keys.setDestination(keys.KEY_CONSOLE)
  keys.Key_Event(104, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(104, false, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(105, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(105, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(keyConsole.inputText, "hi", "console receives printable key events")
  eventResult = keys.Key_Event(keys.K_ENTER, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(keys.K_ENTER, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[0], "hi\n", "console enter queues line")
  assertEqual(keyConsole.lines[len(keyConsole.lines) - 1], "]hi", "console echoes submitted line")
  keys.Key_Event(keys.K_UPARROW, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(keys.K_UPARROW, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(keyConsole.inputText, "hi", "console history recalls previous line")
  lineIndex = 0
  while lineIndex < 40
    console.appendLine(keyConsole, "scroll " + lineIndex)
    lineIndex = lineIndex + 1
  end while
  keys.Key_Event(keys.K_PGUP, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(keys.K_PGUP, false, keyConsole, keyCommands, keyVariables, false, false)
  assertTrue(console.backscroll() > 0, "console page-up scrolls toward older text")
  keys.Key_Console(keys.K_HOME, keyConsole, keyCommands, keyVariables, 25)
  assertTrue(console.backscroll() > 2, "Key_Console home selects oldest visible text")
  keys.Key_Console(keys.K_END, keyConsole, keyCommands, keyVariables, 25)
  assertEqual(console.backscroll(), 0, "console end returns to newest text")
  keyConsole.inputText = ""
  keys.Key_Event(keys.K_SHIFT, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(97, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(97, false, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(keys.K_SHIFT, false, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(keyConsole.inputText, "A", "console shift table maps lowercase ASCII")

  keys.beginMessage(false)
  keys.Key_Event(104, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(104, false, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(105, true, keyConsole, keyCommands, keyVariables, false, false)
  keys.Key_Event(105, false, keyConsole, keyCommands, keyVariables, false, false)
  eventResult = keys.Key_Event(keys.K_ENTER, true, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[0], "say \"hi\"\n", "message destination queues say command")
  assertEqual(keys.destination(), keys.KEY_GAME, "message enter returns to game")

  keys.setDestination(keys.KEY_MENU)
  eventResult = keys.Key_Event(keys.K_DOWNARROW, true, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[1], "menu_key", "menu destination receives navigation key")
  keys.Key_Event(keys.K_DOWNARROW, false, keyConsole, keyCommands, keyVariables, false, false)
  eventResult = keys.Key_Event(keys.K_ESCAPE, true, keyConsole, keyCommands, keyVariables, false, false)
  assertEqual(eventResult[1], "menu_escape", "escape is permanently menu-bound")

  gameInput.unbindAll()
  assertEqual(keys.Key_Bind_f(["bind", "MOUSE1", "+attack"]), "", "bind command sets binding")
  assertEqual(keys.Key_Bind_f(["bind", "MOUSE1"]), "\"MOUSE1\" = \"+attack\"", "bind command queries binding")
  assertEqual(keys.Key_Bindlist_f(), "MOUSE1 \"+attack\"\n", "bindlist enumerates active bindings")
  assertEqual(keys.Key_WriteBindings(), "bind \"MOUSE1\" \"+attack\"\n", "config writes original bind syntax")
  assertEqual(keys.Key_Unbind_f(["unbind", "MOUSE1"]), "", "unbind command clears binding")
  assertEqual(keys.Key_WriteBindings(), "", "empty bindings omitted from config")
  keys.Key_SetBinding(97, "+attack")
  keys.Key_ClearStates()
  assertEqual(keys.keyDownStates[97], false, "Key_ClearStates releases key state")
  assertEqual(keys.keyRepeats[97], 0, "Key_ClearStates clears repeat count")

  // in_win.c events must retain message order, including multiple transitions
  // of the same key in a single host frame.
  gameInput.clearJoystickSnapshot()
  packed = platformWin.inputEventPop()
  while packed != 0
    packed = platformWin.inputEventPop()
  end while
  platformWin.inputTestPush(1, 65, 1)
  platformWin.inputTestPush(2, 1, 1)
  platformWin.inputTestPush(3, 0, -1)
  platformWin.inputTestPush(1, 65, 0)
  platformWin.inputTestPush(4, 0, 0)
  ordered = keys.PollEvents()
  assertEqual(len(ordered), 6, "ordered native event count")
  assertEqual(ordered[0][0], 97, "raw A maps to Quake lowercase a")
  assertEqual(ordered[0][1], true, "ordered key down")
  assertEqual(ordered[1][0], keys.K_MOUSE2, "ordered second mouse button")
  assertEqual(ordered[2][0], keys.K_MWHEELDOWN, "negative wheel direction")
  assertEqual(ordered[2][1], true, "wheel down press")
  assertEqual(ordered[3][0], keys.K_MWHEELDOWN, "wheel release key")
  assertEqual(ordered[3][1], false, "wheel release edge")
  assertEqual(ordered[4][0], 97, "ordered key up code")
  assertEqual(ordered[4][1], false, "ordered key up")
  assertEqual(ordered[5][0], -1, "focus event sentinel")
  assertEqual(ordered[5][1], false, "focus loss event")

  // WinMM joystick mapping and thresholds follow MiniQuake's default X=turn,
  // Y=forward map and use the same absolute-axis frame scaling.
  joystickVariables = host.createCvars(void, false)
  gameInput.configurePlatform(joystickVariables, true, false, false)
  variables.set(joystickVariables, "joystick", "1")
  gameInput.setJoystickSnapshot([49152, 49152, 32768, 32768, 32768, 32768], 17, 0, 5, true)
  gameInput.Joy_AdvancedUpdate_f()
  joystickCommand = gameInput.createCommand()
  gameInput.IN_JoyMove(joystickCommand, 0.1)
  assertNear(joystickCommand.forwardMove, -100.0, 0.0001, "joystick forward axis")
  assertNear(joystickCommand.viewAngles.y, -7.0, 0.0001, "joystick absolute yaw axis")
  joystickEvents = gameInput.IN_Commands()
  assertEqual(len(joystickEvents), 3, "joystick button and POV press count")
  assertEqual(joystickEvents[0][0], keys.K_JOY1, "first joystick button")
  assertEqual(joystickEvents[1][0], keys.K_AUX1 + 4, "fifth joystick button")
  assertEqual(joystickEvents[2][0], keys.K_AUX1 + 28, "POV forward auxiliary button")
  gameInput.updateJoystickSnapshot([32768, 32768, 32768, 32768, 32768, 32768], 0, 65535)
  joystickEvents = gameInput.IN_Commands()
  assertEqual(len(joystickEvents), 3, "joystick button and POV release count")
  assertEqual(joystickEvents[0][1], false, "joystick release edge")
  assertEqual(joystickEvents[2][1], false, "POV release edge")
  gameInput.clearJoystickSnapshot()
  gameInput.resetBindings()
  return true
end function

// Verify status bar rules against the expected Quake behavior.
function testStatusBarRules()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.health = 100.0
  assertEqual(statusbar.faceName(player), "face1", "healthy face")
  player.health = 20.0
  assertEqual(statusbar.faceName(player), "face4", "critical face")
  player.items = c.IT_QUAD
  assertEqual(statusbar.faceName(player), "face_quad", "quad face")
  assertEqual(statusbar.armorName(c.IT_ARMOR3), "sb_armor3", "red armor icon")
  assertEqual(statusbar.ammoName(c.IT_ROCKETS), "sb_rocket", "rocket ammo icon")
  assertEqual(statusbar.scaleFor(640, 480), 1.0, "640 status bar scale")
  assertEqual(statusbar.scaleFor(1280, 720), 2.0, "1280 status bar scale")

  converted = statusbar.Sbar_itoa(-42)
  assertEqual(converted[0], "-42", "Sbar_itoa signed text")
  assertEqual(converted[1], 3, "Sbar_itoa length")
  scores = [
    t.ClientScore("low", 0.0, 2, 0x12),
    t.ClientScore("high", 0.0, 9, 0x43),
    t.ClientScore("", 0.0, 99, 0x00),
  ]
  sorted = statusbar.Sbar_SortFrags(scores)
  assertEqual(len(sorted), 2, "scoreboard ignores empty clients")
  assertEqual(sorted[0], 1, "scoreboard descending frags")
  assertEqual(sorted[1], 0, "scoreboard second place")
  assertEqual(statusbar.Sbar_ColorForMap(0x40), 0x48, "scoreboard palette translation")

  scoreClient = client.create(player)
  scoreClient.maxClients = 4
  scoreClient.gameType = c.GAME_DEATHMATCH
  client.resetScores(scoreClient, 4)
  client.applyEvent(scoreClient, t.ProtocolEvent("svc_updatename", [1, "Ranger"]))
  client.applyEvent(scoreClient, t.ProtocolEvent("svc_updatefrags", [1, 17]))
  client.applyEvent(scoreClient, t.ProtocolEvent("svc_updatecolors", [1, 0x4d]))
  client.applyEvent(scoreClient, t.ProtocolEvent("svc_updatestat", [c.STAT_TOTALMONSTERS, 23]))
  assertEqual(scoreClient.scores[1].name, "Ranger", "protocol scoreboard name")
  assertEqual(scoreClient.scores[1].frags, 17, "protocol scoreboard frags")
  assertEqual(scoreClient.scores[1].colors, 0x4d, "protocol scoreboard colors")
  assertEqual(scoreClient.stats[c.STAT_TOTALMONSTERS], 23, "protocol scoreboard stat")
  id1Layout = statusbar.Sbar_LayoutTrace("id1", player, scoreClient, 640, 480, 48, 0.0)
  hipLayout = statusbar.Sbar_LayoutTrace("hipnotic", player, scoreClient, 640, 480, 48, 0.0)
  player.activeWeapon = c.RIT_LAVA_NAILGUN
  rogueLayout = statusbar.Sbar_LayoutTrace("rogue", player, scoreClient, 640, 480, 48, 4.0)
  assertEqual(id1Layout[1][1], true, "id1 inventory layout")
  assertEqual(id1Layout[3][1], false, "id1 has no hipnotic strip")
  assertEqual(hipLayout[3][1], true, "hipnotic extra weapon strip")
  assertEqual(rogueLayout[2][1], true, "rogue powered weapon strip")
  assertEqual(rogueLayout[4][1], true, "rogue team face border")
  assertEqual(rogueLayout[5][1], true, "deathmatch mini scoreboard")
  return true
end function

// Verify view math against the expected Quake behavior.
function testViewMath()
  velocity = t.Vec3(160.0, 80.0, 0.0)
  bob = view.calcBob(0.15, velocity, 0.02, 0.6, 0.5)
  assertTrue(bob >= -7.0 and bob <= 4.0, "bob clamp")
  roll = view.calcRoll(t.Vec3(0.0, 0.0, 0.0), velocity, 2.0, 200.0)
  assertTrue(roll >= -2.0 and roll <= 2.0, "roll clamp")
  state = view.create()
  view.addDamage(state, 25.0, t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0.6, 0.6, 0.5)
  assertTrue(state.blend[3] > 0.0, "damage blend")

  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  player.onGround = true
  stairState = view.create()
  view.reset(stairState, player.origin)
  player.origin.z = 10.0
  cameraAngles = t.Vec3(12.345, 123.456, 0.0)
  view.calculate(stairState, player, cameraAngles, 0.0, 0.02, 0.0, 0.6, 0.5, 2.0, 200.0, 0.0)
  assertNear(stairState.oldZ, 1.6, 0.001, "stair smoothing rate")
  assertTrue(stairState.origin.z < player.origin.z + player.viewHeight, "stair camera does not snap upward")
  assertNear(stairState.angles.x, 12.345, 0.0001, "camera keeps unquantized pitch")
  assertNear(stairState.angles.y, 123.456, 0.0001, "camera keeps unquantized yaw")

  // An 18-unit Quake stair initially clamps the camera lag to 12 units.
  view.reset(stairState, t.Vec3(0.0, 0.0, 0.0))
  player.origin.z = 18.0
  view.calculate(stairState, player, cameraAngles, 0.0, 0.02, 0.0, 0.6, 0.5, 2.0, 200.0, 0.0)
  assertNear(stairState.oldZ, 6.0, 0.001, "stair smoothing twelve-unit clamp")
  return true
end function

// Verify particle lifecycle against the expected Quake behavior.
function testParticleLifecycle()
  spawned = particles.runEffect(t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), 5000, 32, 1.0)
  assertEqual(len(spawned), particles.MAX_PARTICLES, "particle cap")
  alive = particles.update(spawned, 0.5, 0.01)
  assertTrue(len(alive) > 0, "particles alive")
  dead = particles.update(alive, 100.0, 0.01)
  assertEqual(len(dead), 0, "particles expired")
  return true
end function

// Verify temporary entity protocol against the expected Quake behavior.
function testTemporaryEntityProtocol()
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.SVC_TEMP_ENTITY)
  msg.writeByte(buffer, c.TE_EXPLOSION2)
  msg.writeCoord(buffer, 1.0)
  msg.writeCoord(buffer, 2.0)
  msg.writeCoord(buffer, 3.0)
  msg.writeByte(buffer, 40)
  msg.writeByte(buffer, 8)
  msg.writeByte(buffer, c.SVC_NOP)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 2, "temp entity preserves following command")
  assertEqual(parsed.events[0].command, "svc_temp_entity", "temp command")
  temporary = parsed.events[0].payload
  assertEqual(temporary.type, c.TE_EXPLOSION2, "temp type")
  assertEqual((temporary.entity >> 8) & 255, 40, "explosion color start")
  assertEqual(temporary.entity & 255, 8, "explosion color length")
  assertEqual(parsed.events[1].command, "svc_nop", "following nop")
  return true
end function

// Verify client effects against the expected Quake behavior.
function testClientEffects()
  client.CL_ClearDlights()
  explosion = t.TemporaryEntity(c.TE_EXPLOSION, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0)
  result = effects.processTemporary(explosion, void, [], [], 1.0)
  assertTrue(len(result[0]) > 0, "explosion particles")
  assertEqual(len(client.clDlights), c.MAX_DLIGHTS, "fixed dynamic-light pool")
  assertNear(client.clDlights[0].radius, 350.0, 0.001, "explosion dynamic-light radius")
  assertNear(client.clDlights[0].die, 1.5, 0.001, "explosion dynamic-light lifetime")
  assertNear(client.clDlights[0].decay, 300.0, 0.001, "explosion dynamic-light decay")
  client.CL_DecayLightsAt(1.25, 0.25)
  assertNear(client.clDlights[0].radius, 275.0, 0.001, "dynamic-light frame decay")
  beam = t.TemporaryEntity(c.TE_LIGHTNING1, t.Vec3(1.0, 2.0, 3.0), t.Vec3(4.0, 5.0, 6.0), 7)
  result = effects.processTemporary(beam, void, result[0], result[1], 1.0)
  assertEqual(len(result[1]), 1, "active beam")
  assertEqual(len(effects.pruneTemporary(result[1], 2.0)), 0, "beam expiry")
  spike = t.TemporaryEntity(c.TE_SPIKE, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0), 0)
  spikeResult = effects.processTemporary(spike, void, [], [], 4.0)
  for each particle in spikeResult[0]
    assertTrue(particle.die <= 4.4, "temporary particle lifetime starts at cl.time")
  end for
  particles.resetRandom(1)
  assertEqual(effects.spikeImpactSound(), "weapons/tink1.wav", "production spike tink branch")
  particles.resetRandom(2)
  assertEqual(effects.spikeImpactSound(), "weapons/ric3.wav", "production spike ricochet branch")
  return true
end function

// Verify server event encoding against the expected Quake behavior.
function testServerEventEncoding()
  gameServer = server.create(1)
  gameServer.soundPrecache = ["", "weapons/test.wav"]
  worldItem = edict.create(0)
  item = edict.create(1)
  item.origin = t.Vec3(10.0, 20.0, 30.0)
  item.mins = t.Vec3(-1.0, -2.0, -3.0)
  item.maxs = t.Vec3(1.0, 2.0, 3.0)
  gameServer.edicts = [worldItem, item]
  assertEqual(server.writeQueuedSound(gameServer, [1, 2, "weapons/test.wav", 1.0, 1.0]), true, "queued sound write")
  assertEqual(server.writeQueuedParticle(gameServer, [t.Vec3(1.0, 2.0, 3.0), t.Vec3(0.5, -0.5, 0.0), 12, 77]), true, "queued particle write")
  parsed = protocol.parse(sz.dataSlice(gameServer.datagram))
  assertEqual(len(parsed.events), 2, "server event count")
  assertEqual(parsed.events[0].command, "svc_sound", "sound command")
  assertEqual(parsed.events[0].payload[3], 10, "packed sound channel")
  assertEqual(parsed.events[0].payload[4], 1, "sound index")
  assertEqual(parsed.events[1].command, "svc_particle", "particle command")
  assertEqual(parsed.events[1].payload[2], 12, "particle count")
  assertEqual(parsed.events[1].payload[3], 77, "particle color")
  return true
end function

// Verify baseline encoding against the expected Quake behavior.
function testBaselineEncoding()
  buffer = sz.alloc(128)
  msg.writeByte(buffer, c.SVC_SPAWNBASELINE)
  msg.writeShort(buffer, 7)
  msg.writeByte(buffer, 3)
  msg.writeByte(buffer, 4)
  msg.writeByte(buffer, 5)
  msg.writeByte(buffer, 6)
  msg.writeCoord(buffer, 8.0); msg.writeAngle(buffer, 45.0)
  msg.writeCoord(buffer, 16.0); msg.writeAngle(buffer, 90.0)
  msg.writeCoord(buffer, 24.0); msg.writeAngle(buffer, 180.0)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "baseline event count")
  payload = parsed.events[0].payload
  assertEqual(payload[0], 7, "baseline entity")
  baseline = payload[1]
  assertEqual(baseline[0], 3, "baseline model")
  assertEqual(baseline[1], 4, "baseline frame")
  assertEqual(baseline[4].x, 8.0, "baseline origin x")
  assertEqual(baseline[4].y, 16.0, "baseline origin y")
  assertEqual(baseline[4].z, 24.0, "baseline origin z")
  assertNear(baseline[5].x, 45.0, 1.5, "baseline angle x")
  assertNear(baseline[5].y, 90.0, 1.5, "baseline angle y")
  assertNear(baseline[5].z, -180.0, 1.5, "baseline angle z")
  return true
end function

// Verify fast entity encoding against the expected Quake behavior.
function testFastEntityEncoding()
  gameServer = server.create(1)
  item = edict.create(2)
  item.model = "progs/test.mdl"
  item.modelIndex = 3
  item.frame = 4
  item.origin = t.Vec3(8.0, 16.0, 24.0)
  item.angles = t.Vec3(0.0, 90.0, 0.0)
  item.baseline = t.EntityBaseline(1, 0, 0, 0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  buffer = sz.alloc(128)
  server.writeEntityUpdate(gameServer, buffer, item)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1, "fast entity count")
  update = parsed.events[0].payload
  assertEqual(update[0], 2, "fast entity number")
  assertEqual(update[2], 3, "fast entity model")
  assertEqual(update[3], 4, "fast entity frame")
  assertEqual(update[7][0], 8.0, "fast entity origin x")
  assertEqual(update[8][1], 90.0, "fast entity yaw")

  longItem = edict.create(286)
  longItem.model = "progs/test.mdl"
  longItem.modelIndex = 3
  longItem.frame = 4
  longItem.origin = t.Vec3(8.0, 16.0, 24.0)
  longItem.baseline = t.EntityBaseline(1, 0, 0, 0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  sz.clear(buffer)
  server.writeEntityUpdate(gameServer, buffer, longItem)
  msg.writeByte(buffer, c.SVC_NOP)
  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 2, "long entity plus following command")
  assertEqual(parsed.events[0].payload[0], 286, "long entity number consumes one short")
  assertEqual(parsed.events[1].command, "svc_nop", "long entity preserves following command")
  assertEqual(parsed.bytesRead, buffer.curSize, "long entity packet fully consumed")

  demoClient = client.create(movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  demoClient.signon = c.SIGNON_SPAWN
  client.applyEvent(demoClient, parsed.events[0])
  assertEqual(demoClient.signon, c.SIGNON_ACTIVE, "first fast update completes original signon")
  assertEqual(demoClient.spawned, true, "implicit signon marks client active")
  return true
end function

// Verify local player precision against the expected Quake behavior.
function testLocalPlayerPrecision()
  player = movement.create(t.Vec3(10.125, 20.25, 30.375), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  localClient.viewEntity = 1
  localClient.localAuthoritative = true
  localClient.serverTime = 1.0
  payload = [
    1,
    0,
    void,
    void,
    void,
    void,
    void,
    [20.0, 21.0, 22.0],
    [void, 90.0, void],
  ]
  entity = client.applyFastUpdate(localClient, payload)
  assertEqual(entity.origin.z, 22.0, "client entity receives network origin")
  assertNear(player.origin.x, 10.125, 0.0001, "local authoritative x is not quantized")
  assertNear(player.origin.y, 20.25, 0.0001, "local authoritative y is not quantized")
  assertNear(player.origin.z, 30.375, 0.0001, "local authoritative z is not quantized")

  player.onGround = true
  player.waterLevel = 0
  player.velocity = t.Vec3(1.25, 2.5, 3.75)
  player.health = 91.0
  player.items = c.IT_SHOTGUN
  staleClientData = t.ProtocolEvent(
    "svc_clientdata",
    [0, 17, 0, [0, 0, 0], [0, 0, -160], c.IT_AXE, 0, 0, 0, 12, 0, 0, 0, 0, 0, c.IT_AXE],
  )
  client.applyEvent(localClient, staleClientData)
  assertEqual(player.onGround, true, "local clientdata cannot clear authoritative ground flag")
  assertNear(player.velocity.z, 3.75, 0.0001, "local clientdata cannot replace authoritative velocity")
  assertEqual(player.health, 91.0, "local clientdata cannot replace authoritative health")
  assertEqual(player.items, c.IT_SHOTGUN, "local clientdata cannot replace authoritative inventory")
  return true
end function

// Verify batched fast entity packet against the expected Quake behavior.
function testBatchedFastEntityPacket()
  // A real server frame contains many fast updates in one datagram. This
  // packet is large enough to exercise the event collector with hundreds of
  // entries without repeatedly concatenating arrays of structs.
  buffer = sz.alloc(4096)
  index = 0
  while index < 1024
    msg.writeByte(buffer, c.U_SIGNAL)
    msg.writeByte(buffer, (index % 254) + 1)
    index = index + 1
  end while

  parsed = protocol.parse(sz.dataSlice(buffer))
  assertEqual(len(parsed.events), 1024, "batched fast update count")
  assertEqual(parsed.bytesRead, buffer.curSize, "batched fast update bytes read")
  assertEqual(parsed.events[0].command, "fast_update", "batched first command")
  assertEqual(parsed.events[0].payload[0], 1, "batched first entity")
  assertEqual(parsed.events[255].payload[0], 2, "batched wrapped entity")
  assertEqual(parsed.events[1023].payload[0], 8, "batched last entity")
  assertEqual(parsed.events[1023].payload[1], 0, "batched last update bits")
  return true
end function

// Verify software mixer against the expected Quake behavior.
function testSoftwareMixer()
  samples = bytes(4)
  bio.putI16(samples, 0, 1000)
  bio.putI16(samples, 2, -1000)
  effect = t.SoundEffect("synthetic", samples, 22050, 2, 1, -1)
  state = mixer.create(void, 22050)
  state.masterVolume = 1.0
  mixer.setListenerEntity(state, 1)
  mixer.updateListener(state, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0))
  // View-entity sounds stay full volume even when their encoded origin is far
  // away; this is the original SND_Spatialize exception for local weapons.
  state.channels = [t.MixerChannel(1, 1, effect, t.Vec3(5000.0, 0.0, 0.0), 1.0, 1.0, 0, false, true, 2)]
  mixed = mixer.mix(state, 3)
  assertEqual(len(mixed), 12, "stereo mix bytes")
  assertEqual(bio.i16(mixed, 0), 996, "left sample 0")
  assertEqual(bio.i16(mixed, 2), 996, "right sample 0")
  assertEqual(bio.i16(mixed, 4), -997, "left sample 1")
  assertEqual(bio.i16(mixed, 6), -997, "right sample 1")
  assertEqual(len(state.channels), 0, "finished channel removed")

  loopEffect = t.SoundEffect("loop", samples, 22050, 2, 1, 0)
  state.channels = [t.MixerChannel(1, 1, loopEffect, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, true, true, state.paintedTime + 2)]
  looped = mixer.mix(state, 5)
  // MiniQuake's SND_PaintChannelFrom16 restarts at paintbuffer[0] whenever a
  // cue loops inside one paint block, accumulating the repeated passes there.
  assertEqual(bio.i16(looped, 0), 2988, "loop cue accumulated sample 0")
  assertEqual(bio.i16(looped, 4), -1994, "loop cue accumulated sample 1")
  assertEqual(bio.i16(looped, 8), 0, "loop cue tail remains clear")
  assertEqual(len(state.channels), 1, "looping channel remains active")

  assertNear(mixer.ambientTarget(255, 0.3), 0.3, 0.0001, "full ambient leaf level")
  assertEqual(mixer.ambientTarget(20, 0.3), 0.0, "quiet ambient level threshold")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.016, 0.1), 5, "default mix-ahead queue depth")
  assertEqual(mixer.desiredQueuedBuffers(state, 0.0, 0.0), 3, "minimum audio queue depth")

  // Mix in a wide accumulator and clamp once.  Per-channel clipping would
  // produce 2767 here instead of the mathematically correct 30000.
  positiveSamples = bytes(2)
  negativeSamples = bytes(2)
  bio.putI16(positiveSamples, 0, 30000)
  bio.putI16(negativeSamples, 0, -30000)
  positive = t.SoundEffect("positive", positiveSamples, 22050, 2, 1, -1)
  negative = t.SoundEffect("negative", negativeSamples, 22050, 2, 1, -1)
  state.channels = [
    t.MixerChannel(1, 0, positive, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true, state.paintedTime + 1),
    t.MixerChannel(2, 0, positive, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true, state.paintedTime + 1),
    t.MixerChannel(3, 0, negative, t.Vec3(0.0, 0.0, 0.0), 1.0, 0.0, 0, false, true, state.paintedTime + 1),
  ]
  accumulated = mixer.mix(state, 1)
  assertEqual(bio.i16(accumulated, 0), 29881, "wide mixer accumulation left")
  assertEqual(bio.i16(accumulated, 2), 29881, "wide mixer accumulation right")
  return true
end function

// Verify datagram framing against the expected Quake behavior.
function testDatagramFraming()
  datagram.resetStats()
  sender = datagram.createChannel()
  reliableBytes = datagram.reliable(sender, bytes("abc"), true)
  assertEqual(len(reliableBytes), 11, "reliable packet size")
  assertEqual(reliableBytes[0], 0, "reliable header byte 0")
  assertEqual(reliableBytes[1], 9, "reliable DATA/EOM flags")
  assertEqual(reliableBytes[2], 0, "reliable header byte 2")
  assertEqual(reliableBytes[3], 11, "reliable length")
  assertEqual(sender.sendSequence, 1, "reliable send sequence")

  packet = datagram.decodePacket(reliableBytes)
  assertTrue((packet.flags & datagram.NETFLAG_DATA) != 0, "reliable data flag")
  assertTrue((packet.flags & datagram.NETFLAG_EOM) != 0, "reliable eom flag")
  assertEqual(packet.sequence, 0, "reliable wire sequence")
  assertEqual(decode(packet.payload), "abc", "reliable payload")

  receiver = datagram.createChannel()
  assertEqual(datagram.acceptReliable(receiver, packet), true, "accept reliable")
  assertEqual(receiver.receiveSequence, 1, "reliable receive sequence")
  assertEqual(datagram.acceptReliable(receiver, packet), false, "reject duplicate reliable")

  acknowledgement = datagram.decodePacket(datagram.acknowledgement(packet.sequence))
  assertTrue((acknowledgement.flags & datagram.NETFLAG_ACK) != 0, "ack flag")
  assertEqual(acknowledgement.sequence, 0, "ack sequence")
  assertEqual(len(acknowledgement.payload), 0, "ack payload")

  skipped = datagram.decodePacket(datagram.encode(datagram.NETFLAG_UNRELIABLE, 2, bytes("u")))
  assertEqual(datagram.acceptUnreliable(receiver, skipped), true, "accept unreliable")
  assertEqual(receiver.unreliableReceiveSequence, 3, "unreliable receive sequence")
  assertEqual(receiver.droppedUnreliable, 2, "unreliable drop accounting")

  control = datagram.decodePacket(datagram.control(bytes([1, 2, 3])))
  assertTrue((control.flags & datagram.NETFLAG_CTL) != 0, "control flag")
  assertEqual(control.sequence, 0, "control has no sequence")
  assertEqual(hex(control.payload), "010203", "control payload")

  // net_dgrm.c sends one 1024-byte reliable fragment at a time and advances
  // only after the matching ACK. Exercise both loss directions: first lose
  // the ACK for fragment zero, then lose fragment one itself.
  large = bytes(2500)
  index = 0
  while index < len(large)
    large[index] = index & 255
    index = index + 1
  end while
  tx = datagram.createChannel()
  rx = datagram.createChannel()
  first = datagram.beginReliable(tx, large, 0.0)
  assertEqual(len(first), datagram.MAX_DATAGRAM + datagram.NET_HEADERSIZE, "first reliable fragment size")
  firstResult = datagram.processPacket(rx, first, 0.0)
  assertEqual(firstResult[0], 0, "partial fragment has no complete message")
  assertTrue(firstResult[2] is bytes, "first fragment ACK")
  assertEqual(datagram.pollRetransmit(tx, 1.0), void, "lost ACK waits one second")
  firstResent = datagram.pollRetransmit(tx, 1.1)
  assertTrue(firstResent is bytes, "lost ACK retransmits first fragment")
  assertEqual(datagram.decodePacket(firstResent).sequence, 0, "lost ACK retains first sequence")
  duplicateFirst = datagram.processPacket(rx, firstResent, 1.1)
  assertEqual(duplicateFirst[0], 0, "duplicate first fragment is not appended")
  assertTrue(duplicateFirst[2] is bytes, "duplicate first fragment is re-ACKed")
  secondResult = datagram.processPacket(tx, duplicateFirst[2], 1.2)
  assertTrue(secondResult[3] is void, "ACK defers next fragment until receive loop exit")
  assertEqual(tx.sendNext, true, "ACK marks next fragment pending")
  second = datagram.Datagram_FlushSendNext(tx, 1.2)
  assertTrue(second is bytes, "receive-loop exit sends second fragment")
  assertEqual(datagram.pollRetransmit(tx, 2.1), void, "lost data waits one second")
  resent = datagram.pollRetransmit(tx, 2.3)
  assertTrue(resent is bytes, "lost fragment retransmitted")
  assertEqual(datagram.decodePacket(resent).sequence, 1, "retransmit keeps sequence")
  assertEqual(tx.packetsReSent, 2, "bidirectional loss retransmit accounting")
  middleResult = datagram.processPacket(rx, resent, 2.3)
  thirdResult = datagram.processPacket(tx, middleResult[2], 2.4)
  assertTrue(thirdResult[3] is void, "middle ACK defers final fragment")
  third = datagram.Datagram_FlushSendNext(tx, 2.4)
  completeResult = datagram.processPacket(rx, third, 2.4)
  assertEqual(completeResult[0], 1, "final fragment completes reliable message")
  assertEqual(len(completeResult[1]), len(large), "reassembled reliable size")
  assertEqual(completeResult[1][0], 0, "reassembled first byte")
  assertEqual(completeResult[1][2499], 195, "reassembled last byte")
  datagram.processPacket(tx, completeResult[2], 2.5)
  assertEqual(tx.canSend, true, "final ACK releases reliable sender")
  duplicateResult = datagram.processPacket(rx, third, 2.6)
  assertEqual(duplicateResult[0], 0, "duplicate reliable fragment ignored")
  assertTrue(duplicateResult[2] is bytes, "duplicate reliable fragment re-ACKed")

  nak = datagram.decodePacket(datagram.negativeAcknowledgement(7))
  assertTrue((nak.flags & datagram.NETFLAG_NAK) != 0, "NAK flag")
  nakSender = datagram.createChannel()
  datagram.beginReliable(nakSender, bytes("retry"), 0.0)
  nakResult = datagram.processPacket(nakSender, datagram.negativeAcknowledgement(0), 0.1)
  assertTrue(nakResult[3] is bytes, "matching NAK retransmits reliable fragment")
  assertEqual(datagram.decodePacket(nakResult[3]).sequence, 0, "NAK preserves sequence")

  wrapping = datagram.createChannel()
  wrapping.sendSequence = 0xffffffff
  wrapped = datagram.reliable(wrapping, bytes("w"), true)
  assertEqual(datagram.decodePacket(wrapped).sequence, 0xffffffff, "wire sequence wraps from unsigned maximum")
  assertEqual(wrapping.sendSequence, 0, "send sequence wraps to zero")

  beforeShort = datagram.shortPacketCount
  malformed = try(datagram.processPacket(datagram.createChannel(), bytes([1, 2, 3]), 0.0))
  assertTrue(malformed is error, "short connected packet rejected")
  assertEqual(datagram.shortPacketCount, beforeShort + 1, "short packet accounting")
  assertTrue(datagram.receivedDuplicateCount > 0, "duplicate packet accounting")

  connectRequest = netControl.parse(netControl.requestConnect())
  assertEqual(connectRequest[0], netControl.CCREQ_CONNECT, "connect request command")
  assertEqual(connectRequest[1][0], "QUAKE", "connect request game")
  assertEqual(connectRequest[1][1], 3, "connect request protocol")
  assertEqual(netControl.validQuakeRequest(connectRequest), true, "valid Quake connect request")
  serverReply = netControl.parse(netControl.replyServerInfo("127.0.0.1:26000", "quake", "start", 1, 4))
  assertEqual(serverReply[0], netControl.CCREP_SERVER_INFO, "server info reply command")
  assertEqual(serverReply[1][0], "127.0.0.1:26000", "server info address")
  assertEqual(serverReply[1][2], "start", "server info level")
  assertEqual(serverReply[1][3], 1, "server info players")
  assertEqual(serverReply[1][4], 4, "server info max players")
  assertEqual(serverReply[1][5], 3, "server info protocol")
  acceptReply = netControl.parse(netControl.replyAccept(26001))
  assertEqual(acceptReply[0], netControl.CCREP_ACCEPT, "accept reply command")
  assertEqual(acceptReply[1][0], 26001, "accept reply port")

  loopSocket = netloop.createSocket()
  assertEqual(netloop.timedOut(loopSocket, 0.001), false, "loopback never times out")
  remoteSocket = netloop.createRemoteSocket(void, "127.0.0.1", 26001)
  remoteSocket.lastReceiveTime = -100000.0
  assertEqual(netloop.timedOut(remoteSocket, 1.0), true, "stale UDP socket times out")
  assertEqual(netloop.timedOut(remoteSocket, 0.0), false, "zero timeout disables expiry")
  rejectReply = netControl.parse(netControl.replyReject("Server is full."))
  assertEqual(rejectReply[1][0], "Server is full.", "reject reply reason")

  terminalRuleWire = netControl.replyRuleInfo("", "")
  assertEqual(len(terminalRuleWire), 5, "rule enumeration terminal wire size")
  terminalRule = netControl.parse(terminalRuleWire)
  assertEqual(terminalRule[1][0], "", "rule enumeration terminal name")
  invalidControl = try(netControl.parse(datagram.encode(datagram.NETFLAG_CTL | datagram.NETFLAG_ACK, 0, bytes([netControl.CCREQ_PLAYER_INFO, 0]))))
  assertTrue(invalidControl is error, "mixed control flags rejected")

  // Real nonblocking UDP control path: accept loss, duplicate connect reply,
  // player/rule queries, ban rejection, stale reconnect, and DNS resolution.
  networkState = netloop.createState()
  netloop.Datagram_Init(networkState, false)
  listener = netloop.listen(networkState, 0)
  netloop.configureServer(networkState, "fixture", "e1m1", 0, 4)
  netloop.configureQueryData(networkState, [["ranger", 17, 9, 12, "127.0.0.1:27001"]], [["sv_gravity", "800"]])
  controlClient = netUdp.open(0)
  netUdp.send(controlClient, "localhost", listener.port, netControl.requestConnect())
  netloop.pumpListener(networkState)
  firstAcceptWire = receiveUdp(controlClient, 100)
  firstAccept = netControl.parse(firstAcceptWire[0])
  assertEqual(firstAccept[0], netControl.CCREP_ACCEPT, "UDP connect accepted")
  acceptedPort = firstAccept[1][0]

  // Pretend the first accept was lost: the retry must receive the same game
  // port rather than a spurious Server is full rejection.
  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestConnect())
  netloop.pumpListener(networkState)
  duplicateAccept = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(duplicateAccept[0], netControl.CCREP_ACCEPT, "duplicate connect request re-accepted")
  assertEqual(duplicateAccept[1][0], acceptedPort, "duplicate accept keeps allocated port")
  acceptedSocket = netloop.checkNewConnections(networkState)
  assertTrue(acceptedSocket is not void, "accepted UDP socket queued")

  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestPlayerInfo(0))
  netloop.pumpListener(networkState)
  playerReply = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(playerReply[0], netControl.CCREP_PLAYER_INFO, "player info control reply")
  assertEqual(playerReply[1][1], "ranger", "player info name")
  assertEqual(playerReply[1][3], 9, "player info frags")

  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestRuleInfo(""))
  netloop.pumpListener(networkState)
  ruleReply = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(ruleReply[1][0], "sv_gravity", "first server rule")
  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestRuleInfo("sv_gravity"))
  netloop.pumpListener(networkState)
  ruleEnd = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(ruleEnd[1][0], "", "server rule enumeration ends")

  netloop.NET_Ban_f(networkState, ["ban", "127.0.0.1"])
  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestConnect())
  netloop.pumpListener(networkState)
  bannedReply = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(bannedReply[0], netControl.CCREP_REJECT, "banned client rejected")
  assertEqual(bannedReply[1][0], "You have been banned.\n", "ban rejection reason")
  netloop.NET_Ban_f(networkState, ["ban", "off"])

  acceptedSocket.connectTime = -100000.0
  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestConnect())
  netloop.pumpListener(networkState)
  assertEqual(acceptedSocket.disconnected, true, "stale reconnect closes old socket")
  netUdp.send(controlClient, "127.0.0.1", listener.port, netControl.requestConnect())
  netloop.pumpListener(networkState)
  reconnectReply = netControl.parse(receiveUdp(controlClient, 100)[0])
  assertEqual(reconnectReply[0], netControl.CCREP_ACCEPT, "retry after stale close reconnects")
  reconnectedSocket = netloop.checkNewConnections(networkState)
  assertTrue(reconnectedSocket is not void, "reconnected socket queued")
  netUdp.close(controlClient)
  netloop.Datagram_Shutdown(networkState)
  return true
end function

// Verify client inventory protocol against the expected Quake behavior.
function testClientInventoryProtocol()
  sourcePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  sourcePlayer.viewHeight = 25.0
  sourcePlayer.onGround = true
  sourcePlayer.waterLevel = 2
  sourcePlayer.health = 87.0
  sourcePlayer.armor = 63.0
  sourcePlayer.ammo = 41
  sourcePlayer.shells = 17
  sourcePlayer.nails = 23
  sourcePlayer.rockets = 5
  sourcePlayer.cells = 9
  sourcePlayer.items = 0x12345678
  sourcePlayer.activeWeapon = 4
  sourcePlayer.weaponFrame = 7
  sourcePlayer.weapon = 9
  sourcePlayer.punchAngle = t.Vec3(2.0, -3.0, 1.0)
  sourcePlayer.velocity = t.Vec3(160.0, -80.0, 32.0)

  buffer = sz.alloc(128)
  bits = server.writeClientData(buffer, sourcePlayer)
  assertTrue((bits & c.SU_WEAPON) != 0, "clientdata always includes view weapon")
  targetPlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(targetPlayer)
  count = client.parseMessage(localClient, sz.dataSlice(buffer))
  assertEqual(count, 1, "clientdata event count")
  assertEqual(targetPlayer.viewHeight, 25, "clientdata viewheight")
  assertEqual(targetPlayer.onGround, true, "clientdata onground")
  assertEqual(targetPlayer.waterLevel, 2, "clientdata inwater")
  assertEqual(targetPlayer.health, 87, "clientdata health")
  assertEqual(targetPlayer.armor, 63, "clientdata armor")
  assertEqual(targetPlayer.ammo, 41, "clientdata ammo")
  assertEqual(targetPlayer.shells, 17, "clientdata shells")
  assertEqual(targetPlayer.nails, 23, "clientdata nails")
  assertEqual(targetPlayer.rockets, 5, "clientdata rockets")
  assertEqual(targetPlayer.cells, 9, "clientdata cells")
  assertEqual(targetPlayer.items, 0x12345678, "clientdata items")
  assertEqual(targetPlayer.activeWeapon, 4, "clientdata active weapon")
  assertEqual(targetPlayer.weaponFrame, 7, "clientdata weapon frame")
  assertEqual(targetPlayer.weapon, 9, "clientdata weapon model")
  assertEqual(targetPlayer.punchAngle.x, 2, "clientdata punch x")
  assertEqual(targetPlayer.punchAngle.y, -3, "clientdata punch y")
  assertEqual(targetPlayer.velocity.x, 160, "clientdata velocity x")
  assertEqual(targetPlayer.velocity.y, -80, "clientdata velocity y")
  assertEqual(targetPlayer.velocity.z, 32, "clientdata velocity z")
  return true
end function

// Verify loopback signon handshake against the expected Quake behavior.
function testLoopbackSignonHandshake()
  allocationProgram = t.QuakeCProgram(
    "allocation.dat",
    bytes(),
    6,
    0,
    [],
    [],
    [],
    [],
    bytes(1),
    vm.zeroArray(64),
    16,
  )
  allocationMachine = vm.create(allocationProgram, 8)
  allocationServer = server.create(1)
  allocationRuntime = server.createEdictRuntime(8, 1)
  allocationContext = server.createQuakeCContext(allocationServer, void, void, void, allocationRuntime)
  vm.setContext(allocationMachine, allocationContext)
  allocationMachine.edictFree = allocationRuntime.freeFlags
  firstMapEdict = quakecEdict.allocate(allocationMachine, 2)
  allocationMachine.edicts[firstMapEdict][0] = 123
  secondMapEdict = quakecEdict.allocate(allocationMachine, 2)
  assertEqual(firstMapEdict, 2, "first map edict follows reserved client")
  assertEqual(secondMapEdict, 3, "ED_Alloc advances num_edicts")
  assertEqual(allocationRuntime.numEdicts, 4, "ED_Alloc high-water mark")
  assertEqual(allocationMachine.edicts[firstMapEdict][0], 123, "later spawn preserves earlier map edict")

  network = netloop.createState()
  player = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  localClient = client.create(player)
  localServer = server.create(1)
  localServer.edicts = [edict.create(0), edict.create(1)]
  localServer.numEdicts = 2

  client.connect(localClient, network)
  assertEqual(localClient.signon, c.SIGNON_NONE, "transport connect keeps protocol signon at zero")
  serverSocket = netloop.checkNewConnections(network)
  assertTrue(serverSocket is not void, "loopback server socket")
  serverClient = server.acceptLocal(localServer, serverSocket)
  assertTrue(serverClient is not void, "server accepts local client")
  assertTrue(serverClient.message.curSize > 0, "serverinfo is queued on the reliable client stream")
  assertTrue(server.sendReliableMessages(localServer) > 0, "server sends queued serverinfo")

  assertEqual(client.pump(localClient), 1, "client consumes serverinfo and signon one")
  assertEqual(localClient.signon, c.SIGNON_SERVERINFO, "client advances to signon stage one")
  assertTrue(localClient.outgoing.curSize > 0, "client queues prespawn after signon one")
  assertEqual(server.pumpClientMessages(localServer, player), 0, "server cannot consume prespawn before CL_SendCmd")
  assertEqual(client.CL_SendCmd(localClient, localClient.command), 1, "client sends prespawn in CL_SendCmd phase")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes prespawn")
  assertEqual(serverClient.signonStage, c.SIGNON_PRESPAWN, "server queues signon stage two")
  assertTrue(serverClient.message.curSize > 0, "server retains signon stage two until reliable phase")
  assertEqual(client.pump(localClient), 0, "client cannot consume signon stage two before server reliable phase")
  assertTrue(server.sendReliableMessages(localServer) > 0, "server sends signon stage two in reliable phase")

  assertEqual(client.pump(localClient), 1, "client consumes signon stage two")
  assertEqual(localClient.signon, c.SIGNON_PRESPAWN, "client advances to signon stage two")
  assertTrue(localClient.outgoing.curSize > 0, "client queues name color and spawn")
  assertEqual(server.pumpClientMessages(localServer, player), 0, "server cannot consume stage-two commands before CL_SendCmd")
  assertEqual(client.CL_SendCmd(localClient, localClient.command), 1, "client sends stage-two commands in CL_SendCmd phase")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes name color and spawn")
  assertEqual(serverClient.signonStage, c.SIGNON_SPAWN, "server queues signon stage three")
  assertTrue(serverClient.message.curSize > 0, "server retains signon stage three until reliable phase")
  assertEqual(client.pump(localClient), 0, "client cannot consume signon stage three before server reliable phase")
  assertTrue(server.sendReliableMessages(localServer) > 0, "server sends signon stage three in reliable phase")

  assertEqual(client.pump(localClient), 1, "client consumes signon stage three")
  assertEqual(localClient.signon, c.SIGNON_SPAWN, "client advances to signon stage three")
  assertTrue(localClient.outgoing.curSize > 0, "client queues begin after signon three")
  assertEqual(server.pumpClientMessages(localServer, player), 0, "server cannot consume begin before CL_SendCmd")
  assertEqual(client.CL_SendCmd(localClient, localClient.command), 1, "client sends begin in CL_SendCmd phase")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes begin")
  assertEqual(serverClient.signonStage, c.SIGNON_ACTIVE, "server accepts begin without a stage-four packet")
  assertEqual(localClient.signon, c.SIGNON_SPAWN, "client remains at stage three before first entity update")

  firstFrame = sz.alloc(64)
  msg.writeByte(firstFrame, c.SVC_TIME)
  msg.writeFloat(firstFrame, 0.0)
  server.writePlayerUpdate(localServer, firstFrame, serverClient, player)
  assertEqual(netmain.NET_SendUnreliableMessage(serverClient.socket, firstFrame), 1, "server sends first ordinary entity update")
  assertEqual(client.pump(localClient), 1, "client consumes first fast entity update")
  assertEqual(localClient.signon, c.SIGNON_ACTIVE, "first fast update completes signon")
  assertEqual(localClient.spawned, true, "client becomes spawned")
  assertEqual(serverClient.spawned, true, "server marks client spawned")
  assertEqual(serverClient.name, "player", "signon name command")
  assertEqual(localClient.viewEntity, 1, "signon assigns player view entity")

  // usercmd_t movement is floating point in WinQuake.  The wire protocol stores
  // the three movement components as signed shorts, so exercise the implicit C
  // float-to-int conversion that the MiniLang writer must perform explicitly.
  // CL_SendMove discards the first two post-connect movement messages.
  move = t.UserCommand(t.Vec3(10.0, 20.0, 30.0), 123.75, -45.5, 7.9, c.BUTTON_ATTACK, 2, 16)
  assertEqual(client.sendMove(localClient, move), 0, "client discards first stale usercmd")
  assertEqual(client.sendMove(localClient, move), 0, "client discards second stale usercmd")
  assertEqual(client.sendMove(localClient, move), 1, "client sends floating-point usercmd")
  assertEqual(server.pumpClientMessages(localServer, player), 1, "server consumes floating-point usercmd")
  assertEqual(serverClient.command.forwardMove, 123, "forward move truncates toward zero")
  assertEqual(serverClient.command.sideMove, -45, "side move truncates toward zero")
  assertEqual(serverClient.command.upMove, 7, "up move truncates toward zero")
  assertEqual(serverClient.command.buttons, c.BUTTON_ATTACK, "move buttons")
  assertEqual(serverClient.command.impulse, 2, "move impulse")

  duplicate = try(client.advanceSignon(localClient, c.SIGNON_ACTIVE))
  assertTrue(duplicate is error, "duplicate signon is rejected")
  netloop.close(localClient.socket)
  return true
end function

// Verify demo playback against the expected Quake behavior.
function testDemoPlayback()
  payload = sz.alloc(128)
  msg.writeByte(payload, c.SVC_VERSION)
  msg.writeLong(payload, c.PROTOCOL_VERSION)
  msg.writeByte(payload, c.SVC_TIME)
  msg.writeFloat(payload, 12.5)
  msg.writeByte(payload, c.SVC_PRINT)
  msg.writeString(payload, "demo hello")
  msg.writeByte(payload, c.SVC_SETVIEW)
  msg.writeShort(payload, 3)
  msg.writeByte(payload, c.SVC_SIGNONNUM)
  msg.writeByte(payload, c.SIGNONS)
  recording = t.Demo(-1, [t.DemoMessage(t.Vec3(10.0, 20.0, 30.0), sz.dataSlice(payload))], "-1\n")
  report = demoPlayer.verify(recording)
  assertEqual(report.ok, true, "demo verification")
  assertEqual(report.eventCount, 5, "demo event count")
  assertEqual(report.payloadBytes, payload.curSize, "demo payload bytes")
  assertEqual(report.viewEntity, 3, "demo view entity")
  assertTrue(report.entities >= 4, "demo entity allocation")
  assertEqual(report.signon, c.SIGNONS, "demo signon")
  assertEqual(report.prints, 1, "demo print count")
  assertNear(report.serverTime, 12.5, 0.0001, "demo server time")

  encoded = demo.serialize(recording)
  decoded = demo.parse(encoded)
  assertEqual(decoded.forcedTrack, -1, "demo forced track roundtrip")
  assertEqual(len(decoded.messages), 1, "demo message count roundtrip")
  assertEqual(demo.filename("run"), "run.dem", "demo default extension")
  rejected = try(demo.filename("../run"))
  assertTrue(rejected is error, "demo relative path rejection")

  network = netloop.createState()
  capturePlayer = movement.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0))
  captureClient = client.create(capturePlayer)
  client.connect(captureClient, network)
  serverSocket = netloop.checkNewConnections(network)
  capture = t.Demo(4, [], "4\n")
  captureClient.command.viewAngles = t.Vec3(1.0, 2.0, 3.0)
  netloop.sendMessage(serverSocket, payload)
  assertEqual(client.pumpRecording(captureClient, capture), 1, "demo capture pumps message")
  assertEqual(len(capture.messages), 1, "demo capture message count")
  assertEqual(capture.messages[0].viewAngles.y, 2.0, "demo capture view angles")
  assertEqual(len(capture.messages[0].payload), payload.curSize, "demo capture payload")
  netloop.close(captureClient.socket)
  return true
end function

// Verify savegame compatibility against the expected Quake behavior.
function testSavegameCompatibility()
  globalDefs = [
    t.QuakeCDef(c.EV_FLOAT | c.DEF_SAVEGLOBAL, 40, 0, "serverflags"),
  ]
  fieldDefs = [
    t.QuakeCDef(c.EV_VOID, 0, 0, ""),
    t.QuakeCDef(c.EV_STRING, 0, 0, "classname"),
    t.QuakeCDef(c.EV_VECTOR, 1, 0, "origin"),
    t.QuakeCDef(c.EV_FLOAT, 1, 0, "origin_x"),
    t.QuakeCDef(c.EV_FLOAT, 2, 0, "origin_y"),
    t.QuakeCDef(c.EV_FLOAT, 3, 0, "origin_z"),
  ]
  dummy = t.QuakeCFunction(0, 0, 0, 0, "", "", 0, [])
  program = t.QuakeCProgram(
    "savegame-synthetic.dat",
    bytes(),
    c.PROG_VERSION,
    0,
    [],
    globalDefs,
    fieldDefs,
    [dummy],
    bytes(1),
    vm.zeroArray(64),
    8,
  )
  machine = vm.create(program, 4)
  vm.setGlobalFloat(machine, 40, 3.0)
  vm.setEntityString(machine, 0, 0, "worldspawn")
  vm.setEntityVector(machine, 0, 1, t.Vec3(1.25, -2.5, 64.0))
  machine.edictFree[0] = false
  machine.edictFree[1] = true

  gameServer = server.create(1)
  gameServer.active = true
  gameServer.mapName = "start"
  gameServer.levelName = "Entrance"
  gameServer.time = 12.5
  gameServer.skill = 1
  gameServer.machine = machine
  gameServer.numEdicts = 2
  text = savegame.serializeServer(gameServer)
  loaded = savegame.parse(text)
  assertEqual(loaded.version, 5, "savegame version")
  assertEqual(loaded.mapName, "start", "savegame map")
  assertNear(loaded.time, 12.5, 0.00001, "savegame time")
  assertEqual(len(loaded.spawnParms), 16, "savegame spawn parms")
  assertEqual(len(loaded.lightStyles), 64, "savegame lightstyles")
  assertEqual(len(loaded.entities), 2, "savegame edict count")
  assertEqual(loaded.entities[0].pairs[0].key, "classname", "savegame first field")
  assertEqual(loaded.entities[0].pairs[0].value, "worldspawn", "savegame string value")
  assertEqual(loaded.entities[0].pairs[1].key, "origin", "savegame vector field")
  assertEqual(len(loaded.entities[1].pairs), 0, "savegame free edict")
  assertEqual(savegame.filename("s0"), "s0.sav", "savegame extension")
  rejected = try(savegame.filename("../escape"))
  assertTrue(rejected is error, "savegame path rejection")
  assertTrue(savegame.inspectComment(text) != "", "savegame comment inspection")
  return true
end function

// Verify net main lifecycle against the expected Quake behavior.
function testNetMainLifecycle()
  networkState = netloop.createState()
  initialized = netmain.NET_Init(networkState, 2, false, false, 26000, true)
  assertEqual(initialized, -1, "-nolan leaves datagram driver unavailable")
  assertEqual(netmain.net_numsockets, 3, "client build owns maxclients plus one qsockets")
  assertEqual(netmain.net_hostport, 26000, "default host port")

  pooled = netmain.NET_NewQSocket()
  assertTrue(pooled is not void, "NET_NewQSocket takes free-list entry")
  assertEqual(pooled.disconnected, false, "new qsocket initialized")
  netmain.NET_FreeQSocket(pooled)
  assertEqual(pooled.disconnected, true, "NET_FreeQSocket disconnects endpoint")

  assertTrue(netmain.IsID("192.246.40.17", true), "ID subnet detection")
  assertEqual(netmain.IsID("192.246.41.17", true), false, "ID subnet mask")
  assertEqual(netmain.IsID("192.246.40.17", false), false, "idgods gate")
  badPort = try(netmain.NET_Port_f(networkState, 65535))
  assertTrue(badPort is error, "port range rejection")
  maxResult = netmain.MaxPlayers_f(1, 16, false, 32)
  assertEqual(maxResult[0], 16, "maxplayers clamps to limit")
  assertEqual(maxResult[1], true, "multiplayer enables listening")

  clientSocket = netmain.NET_Connect(networkState, "local", 1)
  assertTrue(clientSocket is not void, "NET_Connect loop client")
  serverSocket = netmain.NET_CheckNewConnections(networkState)
  assertTrue(serverSocket is not void, "NET_CheckNewConnections loop server")
  gameServer = server.create(1)
  gameServer.active = true
  accepted = server.acceptLocal(gameServer, serverSocket)
  assertTrue(accepted is not error, "server accepts tracked qsocket")
  assertEqual(netmain.net_activeconnections, 1, "active connection counter")
  assertTrue(server.sendReliableMessages(gameServer) > 0, "queued serverinfo delivery")

  // Drain initial serverinfo so the reliable loop channel can send reconnect.
  incoming = sz.alloc(c.MAX_MSGLEN)
  assertEqual(netmain.NET_GetMessage(clientSocket, incoming, 300.0), 1, "initial serverinfo delivery")
  accepted.spawned = true
  accepted.spawnParms[0] = 42.0
  accepted.playerState.origin.x = 123.0
  preservedPlayerState = accepted.playerState
  preservedSocket = accepted.socket
  snapshot = server.beginChangeLevel(gameServer)
  assertEqual(netmain.NET_GetMessage(clientSocket, incoming, 300.0), 1, "changelevel reconnect delivery")
  reader = msg.beginReadingBytes(sz.dataSlice(incoming))
  assertEqual(msg.readByte(reader), c.SVC_STUFFTEXT, "changelevel emits stufftext")
  assertEqual(msg.readString(reader), "reconnect\n", "changelevel reconnect command")

  accepted.active = false
  accepted.spawned = false
  accepted.socket = void
  restored = server.finishChangeLevel(gameServer, snapshot)
  assertEqual(restored, 1, "active client restored after level spawn")
  assertTrue(gameServer.clients[0].socket == preservedSocket, "changelevel retains qsocket")
  assertNear(gameServer.clients[0].spawnParms[0], 42.0, 0.00001, "changelevel retains spawn parms")
  assertTrue(gameServer.clients[0].playerState == preservedPlayerState, "changelevel retains player-state identity")
  assertNear(gameServer.clients[0].playerState.origin.x, 123.0, 0.00001, "changelevel retains player state")
  assertEqual(gameServer.clients[0].spawned, false, "changelevel restarts signon")

  server.shutdown(gameServer)
  assertEqual(netmain.net_activeconnections, 0, "shutdown releases active connection")
  netmain.NET_Shutdown(networkState)
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  passed = 0
  print "MiniQuake milestone tests starting: 24"

  print "[01/24] launch parsing"
  result = try(testLaunchParsing())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[02/24] host frame timing"
  result = try(testHostTiming())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[03/24] user command encoding"
  result = try(testMoveCommandEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[04/24] original mouse scaling"
  result = try(testMouseScaling())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[05/24] key bindings"
  result = try(testKeyBindings())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[06/24] console state"
  result = try(testConsoleState())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[07/24] classic menu state"
  result = try(testMenuState())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[08/24] original status bar rules"
  result = try(testStatusBarRules())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[09/24] view bob/roll/stair smoothing"
  result = try(testViewMath())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[10/24] particles"
  result = try(testParticleLifecycle())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[11/24] temporary-entity protocol"
  result = try(testTemporaryEntityProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[12/24] client effects"
  result = try(testClientEffects())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[13/24] server sound/particle encoding"
  result = try(testServerEventEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[14/24] baseline encoding"
  result = try(testBaselineEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[15/24] fast entity encoding"
  result = try(testFastEntityEncoding())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[16/24] local player precision/ground state"
  result = try(testLocalPlayerPrecision())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[17/24] batched fast entity packet"
  result = try(testBatchedFastEntityPacket())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[18/24] software mixer"
  result = try(testSoftwareMixer())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[19/24] client inventory/view weapon protocol"
  result = try(testClientInventoryProtocol())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[20/24] complete loopback signon"
  result = try(testLoopbackSignonHandshake())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[21/24] demo playback"
  result = try(testDemoPlayback())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[22/24] datagram framing"
  result = try(testDatagramFraming())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[23/24] savegame/config compatibility"
  result = try(testSavegameCompatibility())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "[24/24] net_main lifecycle/changelevel"
  result = try(testNetMainLifecycle())
  if result is error then print "FAIL: " + result.message; return 1 end if
  passed = passed + 1

  print "MiniQuake milestone tests passed: " + passed
  return 0
end function
