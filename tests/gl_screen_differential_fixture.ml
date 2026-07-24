import miniquake.screen as screen
import miniquake.render.draw2d as draw
import miniquake.render.gl11 as gl
import miniquake.types as t
import miniquake.cvar as cvar
import miniquake.console as console
import miniquake.keys as keys
import miniquake.native as native

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function registry()
  result = cvar.createRegistry()
  result.variables = [
    cvar.create("viewsize", "80", true, false),
    cvar.create("fov", "90", false, false),
    cvar.create("scr_conspeed", "300", false, false),
    cvar.create("scr_centertime", "2", false, false),
    cvar.create("showram", "1", false, false),
    cvar.create("showturtle", "0", false, false),
    cvar.create("showpause", "1", false, false),
    cvar.create("scr_printspeed", "8", false, false),
    cvar.create("gl_triplebuffer", "1", true, false),
  ]
  return result
end function

function main(args)
  variables = registry()
  consoleState = console.create(64)
  consoleState.textureId = 1
  draw.Draw_DifferentialSetCaches(
    [
      t.MenuPicture("wad:ram", 24, 24, 1),
      t.MenuPicture("wad:net", 24, 24, 2),
      t.MenuPicture("wad:turtle", 24, 24, 3),
    ],
    [
      t.MenuPicture("gfx/pause.lmp", 64, 24, 4),
      t.MenuPicture("gfx/loading.lmp", 80, 24, 5),
    ],
    t.MenuPicture("gfx/conback.lmp", 320, 200, 6),
  )
  gl.Trace_Begin()

  lines = screen.SCR_CenterPrint(consoleState, "one\ntwo", 4.0)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_CenterPrint\",\"case\":\"lines\",\"lines\":" +
    lines + ",\"off\":" + native.floatText(state[4]) +
    ",\"start\":" + native.floatText(state[5]) + "}"

  characters = screen.SCR_DrawCenterString(320, 200, 4.0)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_DrawCenterString\",\"case\":\"two-lines\"," +
    "\"characters\":" + characters + ",\"erase\":" +
    state[8] + "}"

  screen.SCR_DifferentialSetEraseLines(0)
  characters = screen.SCR_CheckDrawCenterString(320, 200, 4.0, 0.25, true)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_CheckDrawCenterString\",\"case\":\"visible\"," +
    "\"copytop\":" + state[0] + ",\"erase_lines\":" +
    state[7] + ",\"characters\":" + characters +
    ",\"remaining\":" + native.floatText(state[4]) + "}"

  fov = screen.CalcFov(90.0, 320.0, 200.0)
  print "{\"function\":\"CalcFov\",\"case\":\"classic\",\"value\":" +
    native.floatText(fov) + "}"

  refdef = screen.SCR_CalcRefdef(320, 200, variables, 0)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_CalcRefdef\",\"case\":\"windowed\",\"x\":" +
    refdef[0] + ",\"y\":" + refdef[1] + ",\"width\":" + refdef[2] +
    ",\"height\":" + refdef[3] + ",\"sb\":" + state[9] +
    ",\"fovx\":" + native.floatText(refdef[4]) + ",\"fovy\":" +
    native.floatText(refdef[5]) + "}"

  screen.SCR_SizeUp_f(variables)
  print "{\"function\":\"SCR_SizeUp_f\",\"case\":\"increment\",\"viewsize\":" +
    native.floatText(cvar.variableValue(variables, "viewsize")) +
    ",\"recalc\":1}"

  screen.SCR_SizeDown_f(variables)
  print "{\"function\":\"SCR_SizeDown_f\",\"case\":\"decrement\",\"viewsize\":" +
    native.floatText(cvar.variableValue(variables, "viewsize")) +
    ",\"recalc\":1}"

  initialized = screen.SCR_Init(void, variables, 320, 200)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_Init\",\"case\":\"register\",\"initialized\":" +
    boolNumber(initialized) + ",\"cvars\":9,\"commands\":3,\"pics\":" +
    boolNumber(state[14] is not void and state[15] is not void and state[16] is not void) + "}"

  print "{\"function\":\"SCR_DrawRam\",\"case\":\"thrash\",\"pictures\":" +
    boolNumber(screen.SCR_DrawRam(true)) + "}"

  cvar.set(variables, "showturtle", "1")
  screen.SCR_DifferentialSetTurtleCount(0)
  screen.SCR_DrawTurtle(0.2)
  screen.SCR_DrawTurtle(0.2)
  turtle = screen.SCR_DrawTurtle(0.2)
  print "{\"function\":\"SCR_DrawTurtle\",\"case\":\"three-slow\",\"pictures\":" +
    boolNumber(turtle) + "}"

  print "{\"function\":\"SCR_DrawNet\",\"case\":\"stalled\",\"pictures\":" +
    boolNumber(screen.SCR_DrawNet(1.0, 0.0, false)) + "}"

  print "{\"function\":\"SCR_DrawPause\",\"case\":\"paused\",\"pictures\":" +
    boolNumber(screen.SCR_DrawPause(true, 320, 200)) + "}"

  screen.SCR_DifferentialSetDrawLoading(true)
  print "{\"function\":\"SCR_DrawLoading\",\"case\":\"active\",\"pictures\":" +
    boolNumber(screen.SCR_DrawLoading(320, 200)) + "}"

  screen.SCR_DifferentialSetDrawLoading(false)
  screen.SCR_DifferentialSetConsole(0.0, 0.0)
  current = screen.SCR_SetUpToDrawConsole(consoleState, 200, 0.05, variables, true, false, 3)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_SetUpToDrawConsole\",\"case\":\"forced\"," +
    "\"forced\":" + boolNumber(consoleState.forcedUp) + ",\"lines\":" +
    native.floatText(state[3]) + ",\"current\":" +
    native.floatText(current) + "}"

  screen.SCR_DifferentialSetConsole(50.0, 200.0)
  result = screen.SCR_DrawConsole(consoleState, 320, 200, true)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_DrawConsole\",\"case\":\"visible\",\"copy\":" +
    state[1] + ",\"draws\":" +
    boolNumber(result == "console") + ",\"clear\":" + state[13] + "}"

  ignored = try(screen.SCR_ScreenShot_f(void, 0, 0, 2, 1))
  tga = screen.BuildTga(2, 1, bytes([1, 2, 3, 255, 4, 5, 6, 255]))
  print "{\"function\":\"SCR_ScreenShot_f\",\"case\":\"tga\",\"size\":" +
    len(tga) + ",\"type\":" + tga[2] + ",\"width\":" + tga[12] +
    ",\"height\":" + tga[14] + ",\"pixel\":" + tga[16] +
    ",\"bgr\":[" + tga[18] + "," + tga[19] + "," + tga[20] + "]}"

  accepted = screen.SCR_BeginLoadingPlaque(consoleState, 10.0, true, 4)
  print "{\"function\":\"SCR_BeginLoadingPlaque\",\"case\":\"connected\"," +
    "\"stops\":1,\"clears\":1,\"accepted\":" + boolNumber(accepted) + "}"

  screen.SCR_EndLoadingPlaque(consoleState)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_EndLoadingPlaque\",\"case\":\"end\",\"disabled\":" +
    boolNumber(state[11]) + ",\"full\":" +
    state[10] + ",\"clears\":1}"

  screen.SCR_DifferentialSetNotify("OK")
  characters = screen.SCR_DrawNotifyString(320, 200)
  print "{\"function\":\"SCR_DrawNotifyString\",\"case\":\"text\"," +
    "\"characters\":" + characters + "}"

  modal = screen.SCR_ModalMessage("Continue?", void, true)
  print "{\"function\":\"SCR_ModalMessage\",\"case\":\"dedicated\",\"result\":" +
    boolNumber(modal) + "}"

  screen.SCR_DifferentialSetConsole(0.0, 0.0)
  screen.SCR_BringDownConsole(consoleState, 200, 0.05, variables, void)
  state = screen.SCR_DifferentialState()
  print "{\"function\":\"SCR_BringDownConsole\",\"case\":\"settled\",\"center\":" +
    native.floatText(state[4]) +
    ",\"shift\":0,\"palettes\":1}"

  screen.SCR_DifferentialSetTile([10, 5, 100, 80, 90.0, 60.0], 48)
  tiles = screen.SCR_TileClear(320, 200)
  print "{\"function\":\"SCR_TileClear\",\"case\":\"border\",\"calls\":" +
    len(tiles) + ",\"left\":[" + tiles[0][0] + "," + tiles[0][1] + "," +
    tiles[0][2] + "," + tiles[0][3] + "],\"right\":[" + tiles[1][0] +
    "," + tiles[1][1] + "," + tiles[1][2] + "," + tiles[1][3] + "]}"

  screen.SCR_DifferentialSetBlocked(true)
  update = screen.SCR_UpdateScreen(
    consoleState, void, void, void, 320, 200, "", false, 1.0, 0.05,
    variables, true, 4, false, 0.0, false, false, true, false
  )
  print "{\"function\":\"SCR_UpdateScreen\",\"case\":\"blocked\",\"begin\":0," +
    "\"view\":0,\"set2d\":0,\"sbar\":0,\"menu\":0,\"end\":0,\"pages\":3}"
  gl.Trace_End()
  return 0
end function
