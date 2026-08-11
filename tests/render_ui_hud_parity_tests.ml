/* BP-047: GL_Set2D, screen overlay, statusbar and TGA contract. */
import miniquake.render_ui_contract as ui
import miniquake.constants as c

function bp047Equal(actual, expected, name)
  if actual != expected then return error(4700, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp047Array(actual, expected, name)
  bp047Equal(len(actual), len(expected), name + " length")
  index = 0
  while index < len(expected)
    bp047Equal(actual[index], expected[index], name + "[" + index + "]")
    index = index + 1
  end while
  return true
end function
function bp047Run(number, name, fn)
  print "[" + number + "/24] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function bp047Coop320()
  bp047Equal(ui.statusbarXOffset(320, c.GAME_COOP), 0, "coop 320")
  return true
end function
function bp047Coop640()
  bp047Equal(ui.statusbarXOffset(640, c.GAME_COOP), 160, "coop 640")
  return true
end function
function bp047Coop800()
  bp047Equal(ui.statusbarXOffset(800, c.GAME_COOP), 240, "coop 800")
  return true
end function
function bp047Dm640()
  bp047Equal(ui.statusbarXOffset(640, c.GAME_DEATHMATCH), 0, "deathmatch left")
  return true
end function
function bp047Dialog()
  bp047Array(ui.overlayOrder(true, false, 0, true), ["set2d","tileclear","dialog","hud","fade","notify-string"], "dialog")
  return true
end function
function bp047Loading()
  bp047Array(ui.overlayOrder(false, true, 0, true), ["set2d","tileclear","loading","hud"], "loading")
  return true
end function
function bp047Intermission()
  bp047Array(ui.overlayOrder(false, false, 1, true), ["set2d","tileclear","intermission"], "intermission")
  return true
end function
function bp047Finale()
  bp047Array(ui.overlayOrder(false, false, 2, true), ["set2d","tileclear","finale","center"], "finale")
  bp047Array(ui.overlayOrder(false, false, 3, true), ["set2d","tileclear","center"], "cutscene")
  bp047Equal(ui.virtualCanvasScale(640, 480), 1.0, "original UI scale")
  bp047Equal(ui.virtualCanvasScale(2048, 1152), 2.0, "high-DPI integral UI scale")
  return true
end function
function bp047NormalCount()
  bp047Equal(len(ui.overlayOrder(false, false, 0, true)), 11, "normal overlay count")
  return true
end function
function bp047NormalFirst()
  bp047Equal(ui.overlayOrder(false, false, 0, true)[0], "set2d", "normal first")
  return true
end function
function bp047NormalLast()
  bp047Equal(ui.overlayOrder(false, false, 0, true)[10], "menu", "normal last")
  return true
end function
function bp047Set2dCount()
  bp047Equal(len(ui.set2dStateOrder()), 11, "set2d count")
  return true
end function
function bp047Set2dViewport()
  bp047Equal(ui.set2dStateOrder()[0], "viewport", "set2d viewport")
  return true
end function
function bp047Set2dDepth()
  bp047Equal(ui.set2dStateOrder()[6], "disable-depth", "set2d depth")
  return true
end function
function bp047Set2dAlpha()
  bp047Equal(ui.set2dStateOrder()[9], "enable-alpha", "set2d alpha")
  return true
end function
function bp047TgaOne()
  bp047Equal(ui.tgaByteLength(1, 1), 21, "TGA 1x1")
  return true
end function
function bp047Tga640()
  bp047Equal(ui.tgaByteLength(640, 480), 921618, "TGA 640x480")
  return true
end function
function bp047TgaInvalid()
  bp047Equal(ui.tgaByteLength(0, 480), 0, "TGA invalid")
  return true
end function
function bp047ViewmodelDepth()
  bp047Equal(ui.viewModelDepthMaximum(), 0.3, "viewmodel depth")
  return true
end function
function bp047Lines100()
  bp047Equal(ui.statusbarLines(100.0, 0), 48, "viewsize 100")
  return true
end function
function bp047Lines110()
  bp047Equal(ui.statusbarLines(110.0, 0), 24, "viewsize 110")
  return true
end function
function bp047Lines120()
  bp047Equal(ui.statusbarLines(120.0, 0), 0, "viewsize 120")
  return true
end function
function bp047LinesIntermission()
  bp047Equal(ui.statusbarLines(100.0, 1), 0, "intermission lines")
  return true
end function
function bp047Constants()
  bp047Equal(ui.STATUSBAR_WIDTH, 320, "statusbar width")
  bp047Equal(ui.TGA_BYTES_PER_PIXEL, 3, "TGA BPP")
  return true
end function

passed = 0
if bp047Run(1,"co-op statusbar 320",bp047Coop320) then passed=passed+1 end if
if bp047Run(2,"co-op statusbar 640",bp047Coop640) then passed=passed+1 end if
if bp047Run(3,"co-op statusbar 800",bp047Coop800) then passed=passed+1 end if
if bp047Run(4,"deathmatch left alignment",bp047Dm640) then passed=passed+1 end if
if bp047Run(5,"dialog overlay order",bp047Dialog) then passed=passed+1 end if
if bp047Run(6,"loading overlay order",bp047Loading) then passed=passed+1 end if
if bp047Run(7,"intermission overlay order",bp047Intermission) then passed=passed+1 end if
if bp047Run(8,"finale overlay order",bp047Finale) then passed=passed+1 end if
if bp047Run(9,"normal overlay count",bp047NormalCount) then passed=passed+1 end if
if bp047Run(10,"normal overlay first",bp047NormalFirst) then passed=passed+1 end if
if bp047Run(11,"normal overlay last",bp047NormalLast) then passed=passed+1 end if
if bp047Run(12,"GL_Set2D state count",bp047Set2dCount) then passed=passed+1 end if
if bp047Run(13,"GL_Set2D viewport",bp047Set2dViewport) then passed=passed+1 end if
if bp047Run(14,"GL_Set2D depth",bp047Set2dDepth) then passed=passed+1 end if
if bp047Run(15,"GL_Set2D alpha",bp047Set2dAlpha) then passed=passed+1 end if
if bp047Run(16,"TGA one pixel",bp047TgaOne) then passed=passed+1 end if
if bp047Run(17,"TGA 640x480",bp047Tga640) then passed=passed+1 end if
if bp047Run(18,"TGA invalid size",bp047TgaInvalid) then passed=passed+1 end if
if bp047Run(19,"viewmodel depth",bp047ViewmodelDepth) then passed=passed+1 end if
if bp047Run(20,"statusbar 48 lines",bp047Lines100) then passed=passed+1 end if
if bp047Run(21,"statusbar 24 lines",bp047Lines110) then passed=passed+1 end if
if bp047Run(22,"statusbar hidden",bp047Lines120) then passed=passed+1 end if
if bp047Run(23,"intermission statusbar",bp047LinesIntermission) then passed=passed+1 end if
if bp047Run(24,"2D constants",bp047Constants) then passed=passed+1 end if
if passed != 24 then print "MiniQuake BP-047 render UI/HUD tests failed: " + passed + "/24"; error(4799,"BP-047 render UI/HUD") end if
print "MiniQuake BP-047 render UI/HUD tests passed: 24"
