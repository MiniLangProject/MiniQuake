/* BP-077: gl_screen.c loading, modal and screenshot parity. */

import miniquake.screen as screen
import miniquake.console as console
import miniquake.cvar as cvar
import miniquake.types as t
import miniquake.constants as c

function yes(value, name)
  if not value then return error(10770, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(10771, name + ": expected false") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(10772, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(10773, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function makeRegistry()
  registry = cvar.createRegistry()
  registry.variables = [
    cvar.create("viewsize", "100", true, false),
    cvar.create("fov", "90", false, false),
    cvar.create("scr_conspeed", "300", false, false),
    cvar.create("scr_centertime", "2", false, false),
    cvar.create("showram", "1", false, false),
    cvar.create("showturtle", "0", false, false),
    cvar.create("showpause", "1", false, false),
    cvar.create("scr_printspeed", "8", false, false),
    cvar.create("gl_triplebuffer", "1", true, false),
  ]
  return registry
end function

function testCenterPrintLines()
  lines = screen.SCR_CenterPrint(void, "one\ntwo", 4.0)
  equal(lines, 2, "center lines")
  return true
end function

function testCenterDrawCharacters()
  screen.SCR_CenterPrint(void, "one\ntwo", 4.0)
  equal(screen.SCR_DrawCenterString(320, 200, 4.0), 6, "center characters")
  return true
end function

function testCenterTimeout()
  screen.SCR_CenterPrint(void, "text", 1.0)
  equal(screen.SCR_CheckDrawCenterString(320, 200, 4.0, 3.0, true), 0, "expired center")
  return true
end function

function testCalcFovClassic()
  near(screen.CalcFov(90.0, 320.0, 200.0), 64.01076641616699, 0.0001, "classic fov")
  return true
end function

function testCalcFovLowError()
  result = try(screen.CalcFov(0.5, 320.0, 200.0))
  yes(result is error, "low fov error")
  return true
end function

function testCalcFovHighError()
  result = try(screen.CalcFov(180.0, 320.0, 200.0))
  yes(result is error, "high fov error")
  return true
end function

function testCalcRefdef()
  refdef = screen.SCR_CalcRefdef(320, 200, makeRegistry(), 0)
  equal(refdef[0], 0, "refdef x")
  equal(refdef[2], 320, "refdef width")
  yes(refdef[3] < 200, "statusbar reserves height")
  return true
end function

function testSizeUp()
  registry = makeRegistry()
  screen.SCR_SizeUp_f(registry)
  near(cvar.variableValue(registry, "viewsize"), 110.0, 0.0, "size up")
  return true
end function

function testSizeDown()
  registry = makeRegistry()
  screen.SCR_SizeDown_f(registry)
  near(cvar.variableValue(registry, "viewsize"), 90.0, 0.0, "size down")
  return true
end function

function testTgaLayout()
  tga = screen.BuildTga(2, 1, bytes([1, 2, 3, 255, 4, 5, 6, 255]))
  equal(len(tga), 24, "tga bytes")
  equal(tga[2], 2, "tga type")
  equal(tga[12], 2, "tga width")
  equal(tga[14], 1, "tga height")
  equal(tga[16], 24, "tga depth")
  return true
end function

function testTgaBgr()
  tga = screen.BuildTga(1, 1, bytes([1, 2, 3, 255]))
  equal(tga[18], 3, "blue")
  equal(tga[19], 2, "green")
  equal(tga[20], 1, "red")
  return true
end function

function testScreenshotHistoricalError()
  result = try(screen.SCR_ScreenshotFailure())
  yes(result is error, "screenshot error")
  equal(result.message, "SCR_ScreenShot_f: Couldn't create a PCX file", "historical error text")
  return true
end function

function testLoadingDisconnected()
  no(screen.SCR_BeginLoadingPlaque(void, 1.0, false, c.SIGNONS), "disconnected plaque")
  return true
end function

function testLoadingUnsignoned()
  no(screen.SCR_BeginLoadingPlaque(void, 1.0, true, c.SIGNON_SPAWN), "unsignoned plaque")
  return true
end function

function testLoadingAccepted()
  yes(screen.SCR_BeginLoadingPlaque(void, 10.0, true, c.SIGNONS), "accepted plaque")
  state = screen.SCR_DifferentialState()
  equal(state[10], 0, "full update")
  return true
end function

function testLoadingEnd()
  screen.SCR_BeginLoadingPlaque(void, 10.0, true, c.SIGNONS)
  screen.SCR_EndLoadingPlaque(void)
  state = screen.SCR_DifferentialState()
  no(state[11], "loading disabled")
  return true
end function

function testModalDedicated()
  yes(screen.SCR_ModalMessage("Continue?", void, true), "dedicated modal")
  return true
end function

function testModalYes()
  yes(screen.SCR_ModalMessage("Continue?", 121, false), "modal y")
  return true
end function

function testModalNo()
  no(screen.SCR_ModalMessage("Continue?", 110, false), "modal n")
  return true
end function

function testTileClearHistoricalWidth()
  screen.SCR_DifferentialSetTile([10, 5, 100, 80, 90.0, 60.0], 48)
  tiles = screen.SCR_TileClear(320, 200)
  equal(len(tiles), 4, "tile calls")
  equal(tiles[1][0], 110, "right x")
  equal(tiles[1][2], 410, "historical right width")
  return true
end function

function testOverlayDialog()
  order = screen.ScreenOverlayOrder(true, false, 0, true)
  equal(len(order), 6, "dialog stages")
  equal(order[2], "dialog", "dialog stage")
  equal(order[5], "notify-string", "notify stage")
  return true
end function

function testOverlayNormal()
  order = screen.ScreenOverlayOrder(false, false, 0, true)
  equal(len(order), 11, "normal stages")
  equal(order[0], "set2d", "first stage")
  equal(order[10], "menu", "last stage")
  return true
end function

function main(args)
  passed = 0
  if run(1, "center print lines", testCenterPrintLines) then passed = passed + 1 end if
  if run(2, "center draw characters", testCenterDrawCharacters) then passed = passed + 1 end if
  if run(3, "center timeout", testCenterTimeout) then passed = passed + 1 end if
  if run(4, "classic FOV", testCalcFovClassic) then passed = passed + 1 end if
  if run(5, "low FOV error", testCalcFovLowError) then passed = passed + 1 end if
  if run(6, "high FOV error", testCalcFovHighError) then passed = passed + 1 end if
  if run(7, "refdef", testCalcRefdef) then passed = passed + 1 end if
  if run(8, "size up", testSizeUp) then passed = passed + 1 end if
  if run(9, "size down", testSizeDown) then passed = passed + 1 end if
  if run(10, "TGA layout", testTgaLayout) then passed = passed + 1 end if
  if run(11, "TGA BGR", testTgaBgr) then passed = passed + 1 end if
  if run(12, "screenshot diagnostic", testScreenshotHistoricalError) then passed = passed + 1 end if
  if run(13, "loading disconnected", testLoadingDisconnected) then passed = passed + 1 end if
  if run(14, "loading unsignoned", testLoadingUnsignoned) then passed = passed + 1 end if
  if run(15, "loading accepted", testLoadingAccepted) then passed = passed + 1 end if
  if run(16, "loading end", testLoadingEnd) then passed = passed + 1 end if
  if run(17, "modal dedicated", testModalDedicated) then passed = passed + 1 end if
  if run(18, "modal yes", testModalYes) then passed = passed + 1 end if
  if run(19, "modal no", testModalNo) then passed = passed + 1 end if
  if run(20, "tile clear", testTileClearHistoricalWidth) then passed = passed + 1 end if
  if run(21, "dialog overlay", testOverlayDialog) then passed = passed + 1 end if
  if run(22, "normal overlay", testOverlayNormal) then passed = passed + 1 end if
  if passed != 22 then print "MiniQuake BP-077 screen/loading tests failed: " + passed + "/22"; return 1 end if
  print "MiniQuake BP-077 screen/loading tests passed: 22"
  return 0
end function
