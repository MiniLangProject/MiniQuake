import miniquake.input as input
import miniquake.cvar as cvar
import miniquake.native as native

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function registry()
  result = cvar.createRegistry()
  result.variables = [
    cvar.create("joystick", "1", true, false),
    cvar.create("joyadvanced", "0", false, false),
    cvar.create("joyadvaxisx", "0", false, false),
    cvar.create("joyadvaxisy", "0", false, false),
    cvar.create("joyadvaxisz", "0", false, false),
    cvar.create("joyadvaxisr", "0", false, false),
    cvar.create("joyadvaxisu", "0", false, false),
    cvar.create("joyadvaxisv", "0", false, false),
    cvar.create("joyforwardthreshold", "0.15", false, false),
    cvar.create("joysidethreshold", "0.15", false, false),
    cvar.create("joypitchthreshold", "0.15", false, false),
    cvar.create("joyyawthreshold", "0.15", false, false),
    cvar.create("joyforwardsensitivity", "-1", false, false),
    cvar.create("joysidesensitivity", "-1", false, false),
    cvar.create("joypitchsensitivity", "1", false, false),
    cvar.create("joyyawsensitivity", "-1", false, false),
    cvar.create("joywwhack1", "0", false, false),
    cvar.create("joywwhack2", "0", false, false),
    cvar.create("cl_movespeedkey", "2", false, false),
    cvar.create("cl_yawspeed", "140", false, false),
    cvar.create("cl_pitchspeed", "150", false, false),
    cvar.create("cl_forwardspeed", "200", false, false),
    cvar.create("cl_sidespeed", "350", false, false),
    cvar.create("lookstrafe", "0", false, false),
    cvar.create("m_pitch", "0.022", false, false),
    cvar.create("lookspring", "0", false, false),
  ]
  return result
end function

function main(args)
  variables = registry()
  input.configurePlatform(variables, false, false, false)

  command = input.createCommand()
  command.viewAngles.x = 25.0
  input.Force_CenterView_f(command)
  print "{\"function\":\"Force_CenterView_f\",\"case\":\"pitch\",\"pitch\":" +
    native.floatText(command.viewAngles.x) + "}"

  input.IN_DifferentialSetMouse(true, false, false, true, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  input.IN_ActivateMouse()
  clipped = input.IN_UpdateClipCursor()
  print "{\"function\":\"IN_UpdateClipCursor\",\"case\":\"active\",\"clips\":1}"

  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  shown = input.IN_ShowMouse()
  print "{\"function\":\"IN_ShowMouse\",\"case\":\"hidden\",\"toggle\":" +
    boolNumber(shown) + ",\"shows\":1}"

  hidden = input.IN_HideMouse()
  print "{\"function\":\"IN_HideMouse\",\"case\":\"shown\",\"toggle\":0,\"shows\":0}"

  input.IN_DifferentialSetMouse(true, false, false, true, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  activated = input.IN_ActivateMouse()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_ActivateMouse\",\"case\":\"win32\",\"active\":" +
    boolNumber(state[1]) + ",\"toggle\":" + boolNumber(state[2]) +
    ",\"spi\":1,\"capture\":1,\"clips\":1}"

  input.IN_DifferentialSetMouse(true, false, true, true, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  input.IN_SetQuakeMouseState()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_SetQuakeMouseState\",\"case\":\"enabled\",\"active\":" +
    boolNumber(state[1]) + "}"

  input.IN_DeactivateMouse()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_DeactivateMouse\",\"case\":\"active\",\"active\":" +
    boolNumber(state[1]) + ",\"toggle\":" + boolNumber(state[2]) +
    ",\"release\":1}"

  input.IN_DifferentialSetMouse(true, false, true, true, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  input.IN_RestoreOriginalMouseState()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_RestoreOriginalMouseState\",\"case\":\"reactivate\"," +
    "\"toggle\":" + boolNumber(state[2]) + ",\"shows\":0}"

  input.IN_DifferentialSetMouse(false, false, false, true, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  print "{\"function\":\"IN_InitDInput\",\"case\":\"missing-dll\",\"result\":" +
    boolNumber(input.IN_InitDInput()) + "}"

  input.configurePlatform(variables, false, false, false)
  started = input.IN_StartupMouse()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_StartupMouse\",\"case\":\"classic\",\"initialized\":" +
    boolNumber(state[0]) + ",\"buttons\":3,\"parms\":1}"

  input.IN_DifferentialSetJoystickStartup(6, true)
  input.IN_Init()
  print "{\"function\":\"IN_Init\",\"case\":\"register\",\"cvars\":20," +
    "\"commands\":2,\"wheel\":77}"

  input.IN_Shutdown()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_Shutdown\",\"case\":\"release\",\"active\":" +
    boolNumber(state[1]) + ",\"mouse_device\":0,\"input\":0}"

  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 0.0, 0.0, 0.0, 0.0, false)
  events1 = input.IN_MouseEvent(3)
  events2 = input.IN_MouseEvent(2)
  events = events1 + events2
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_MouseEvent\",\"case\":\"edges\",\"events\":" +
    len(events) + ",\"codes\":[" + events[0][0] + "," + events[1][0] +
    "," + events[2][0] + "],\"downs\":[" + boolNumber(events[0][1]) +
    "," + boolNumber(events[1][1]) + "," + boolNumber(events[2][1]) +
    "],\"old\":" + state[5] + "}"

  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 10.0, -5.0, 0.0, 0.0, false)
  command = input.createCommand()
  input.IN_MouseMove(command, 3.0, 0.022, 0.022, false, 0.8, 1.0, false, false)
  print "{\"function\":\"IN_MouseMove\",\"case\":\"delta\",\"yaw\":" +
    native.floatText(command.viewAngles.y) + ",\"forward\":" +
    native.floatText(command.forwardMove) + ",\"mouse\":[30,-15]}"

  input.clearJoystickSnapshot()
  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 4.0, 2.0, 0.0, 0.0, false)
  command = input.createCommand()
  command.viewAngles.y = -0.659999967
  input.IN_Move(command, 3.0, 0.022, 0.022, false, 0.8, 1.0, false, false, 0.1, true, false)
  print "{\"function\":\"IN_Move\",\"case\":\"active\",\"yaw\":" +
    native.floatText(command.viewAngles.y) + ",\"forward\":" +
    native.floatText(command.forwardMove) + "}"
  command = input.createCommand()
  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 20.0, 20.0, 0.0, 0.0, false)
  input.IN_Move(command, 3.0, 0.022, 0.022, false, 0.8, 1.0, false, false, 0.1, false, false)
  print "{\"function\":\"IN_Move\",\"case\":\"inactive\",\"forward\":" +
    native.floatText(command.forwardMove) + ",\"side\":" +
    native.floatText(command.sideMove) + "}"

  input.IN_DifferentialSetMouse(true, true, true, false, false, 0, 7.0, -3.0, 0.0, 0.0, false)
  input.IN_Accumulate()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_Accumulate\",\"case\":\"active\",\"accum\":[" +
    native.trunc(state[6]) + "," + native.trunc(state[7]) + "]}"

  input.IN_DifferentialSetMouse(true, true, true, false, false, 7, 7.0, -3.0, 0.0, 0.0, false)
  input.IN_ClearStates()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_ClearStates\",\"case\":\"active\",\"accum\":[" +
    native.trunc(state[6]) + "," + native.trunc(state[7]) +
    "],\"old\":" + state[5] + "}"

  input.IN_DifferentialSetJoystickStartup(6, true)
  input.configurePlatform(variables, false, false, false)
  input.IN_StartupJoystick()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_StartupJoystick\",\"case\":\"detected\"," +
    "\"available\":" + boolNumber(state[11]) + ",\"buttons\":" +
    state[12] + ",\"pov\":" + boolNumber(state[13]) + ",\"advanced\":" +
    boolNumber(state[14]) + "}"
  input.configurePlatform(variables, false, true, false)
  input.IN_StartupJoystick()
  state = input.IN_DifferentialState()
  print "{\"function\":\"IN_StartupJoystick\",\"case\":\"disabled\"," +
    "\"available\":" + boolNumber(state[11]) + "}"
  input.configurePlatform(variables, false, false, false)
  input.IN_StartupJoystick()

  input.setJoystickSnapshot([12345, 32768, 32768, 32768, 32768, 32768], 0, 65535, 6, true)
  print "{\"function\":\"RawValuePointer\",\"case\":\"x\",\"value\":" +
    input.RawValuePointer(0) + "}"

  maps = input.Joy_AdvancedUpdate_f()
  state = input.IN_DifferentialState()
  controls = state[16]
  print "{\"function\":\"Joy_AdvancedUpdate_f\",\"case\":\"default\",\"maps\":[" +
    maps[0] + "," + maps[1] + "," + maps[2] + "],\"controls\":[" +
    controls[0] + "," + controls[1] + "],\"flags\":451}"
  cvar.set(variables, "joyadvanced", "1")
  cvar.set(variables, "joyadvaxisx", "19")
  cvar.set(variables, "joyadvaxisy", "2")
  input.Joy_AdvancedUpdate_f()
  state = input.IN_DifferentialState()
  print "{\"function\":\"Joy_AdvancedUpdate_f\",\"case\":\"advanced\"," +
    "\"maps\":[" + state[15][0] + "," + state[15][1] +
    "],\"controls\":[" + state[16][0] + "," + state[16][1] + "]}"
  cvar.set(variables, "joyadvanced", "0")
  input.Joy_AdvancedUpdate_f()

  input.updateJoystickSnapshot([32768, 32768, 32768, 32768, 32768, 32768], 3, 0)
  events = input.IN_Commands()
  print "{\"function\":\"IN_Commands\",\"case\":\"buttons-pov\",\"events\":" +
    len(events) + ",\"first\":[" + events[0][0] + "," +
    boolNumber(events[0][1]) + "],\"last\":[" + events[len(events) - 1][0] +
    "," + boolNumber(events[len(events) - 1][1]) + "]}"
  input.updateJoystickSnapshot([32768, 32768, 32768, 32768, 32768, 32768], 0, 9000)
  events = input.IN_Commands()
  print "{\"function\":\"IN_Commands\",\"case\":\"release-pov-change\"," +
    "\"events\":" + len(events) + ",\"first\":[" + events[0][0] + "," +
    boolNumber(events[0][1]) + "],\"last\":[" + events[len(events) - 1][0] +
    "," + boolNumber(events[len(events) - 1][1]) + "]}"

  input.updateJoystickSnapshot([32768, 32768, 32768, 32768, 32768, 32768], 0, 65535)
  print "{\"function\":\"IN_ReadJoystick\",\"case\":\"warrior\",\"result\":" +
    boolNumber(input.IN_ReadJoystick()) + ",\"u\":" +
    input.RawValuePointer(4) + "}"

  input.updateJoystickSnapshot([49152, 16384, 32768, 32768, 32768, 32768], 0, 65535)
  command = input.createCommand()
  input.IN_JoyMove(command, 0.1)
  print "{\"function\":\"IN_JoyMove\",\"case\":\"default-axes\",\"forward\":" +
    native.floatText(command.forwardMove) + ",\"side\":" +
    native.floatText(command.sideMove) + ",\"pitch\":" +
    native.floatText(command.viewAngles.x) + ",\"yaw\":" +
    native.floatText(command.viewAngles.y) + "}"
  cvar.set(variables, "joywwhack2", "1")
  input.updateJoystickSnapshot([33268, 32768, 32768, 32768, 32768, 32768], 0, 65535)
  command = input.createCommand()
  input.IN_JoyMove(command, 0.1)
  print "{\"function\":\"IN_JoyMove\",\"case\":\"warrior-curve\",\"yaw\":" +
    native.floatText(command.viewAngles.y) + "}"
  return 0
end function
