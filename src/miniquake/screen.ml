package miniquake.screen

import miniquake.render.gl11 as gl
import miniquake.render.draw2d as draw
import miniquake.graphics_data as graphicsData
import miniquake.native as native
import miniquake.menu as menu
import miniquake.statusbar as statusbar
import miniquake.cvar as cvar

function initialize(consoleState, menuState, filesystem, palette)
  if consoleState is void then return false end if
  if consoleState.textureId == 0 then
    source = try(graphicsData.readConsoleCharacters(filesystem))
    if source is error then return false end if
    texture = try(draw.uploadFont(source, palette))
    if texture is error then return false end if
    consoleState.textureId = texture
  end if
  if menuState is not void then menu.initialize(menuState, filesystem, palette) end if
  return true
end function

function shutdown(consoleState, menuState)
  if menuState is not void then menu.shutdown(menuState) end if
  if consoleState is not void and consoleState.textureId != 0 then
    gl.deleteTexture(consoleState.textureId)
    consoleState.textureId = 0
  end if
  return true
end function

function drawCrosshair(width, height)
  centerX = width * 0.5
  centerY = height * 0.5
  draw.solidQuad(centerX - 5.0, centerY, 11.0, 1.0, 255, 255, 255, 220)
  draw.solidQuad(centerX, centerY - 5.0, 1.0, 11.0, 255, 255, 255, 220)
end function

function drawBlend(viewState, width, height)
  if viewState is void or len(viewState.blend) < 4 or viewState.blend[3] <= 0.0 then return false end if
  red = native.trunc(viewState.blend[0] * 255.0)
  green = native.trunc(viewState.blend[1] * 255.0)
  blue = native.trunc(viewState.blend[2] * 255.0)
  alpha = native.trunc(viewState.blend[3] * 255.0)
  draw.solidQuad(0.0, 0.0, width * 1.0, height * 1.0, red, green, blue, alpha)
  return true
end function

function drawHud(consoleState, menuState, player, width, height, registry)
  if consoleState is void or consoleState.textureId == 0 then return false end if
  viewSize = 100.0
  if registry is not void then viewSize = cvar.variableValue(registry, "viewsize") end if
  return statusbar.render(menuState, consoleState.textureId, player, width, height, viewSize)
end function


function drawNotify(consoleState, width, height)
  if consoleState is void or consoleState.textureId == 0 or consoleState.active then return false end if
  count = 4
  start = len(consoleState.lines) - count
  if start < 0 then start = 0 end if
  y = 8.0
  index = start
  while index < len(consoleState.lines)
    draw.string(consoleState.textureId, 8.0, y, consoleState.lines[index], 1.0, 220)
    y = y + 8.0
    index = index + 1
  end while
  return true
end function

function drawCenter(consoleState, width, height)
  if consoleState is void or consoleState.textureId == 0 or consoleState.centerText == "" then return false end if
  data = bytes(consoleState.centerText)
  lineWidth = len(data) * 8.0
  x = (width - lineWidth) * 0.5
  if x < 8.0 then x = 8.0 end if
  y = height * 0.35
  draw.string(consoleState.textureId, x, y, consoleState.centerText, 1.0, 255)
  return true
end function

function render(consoleState, menuState, viewState, player, width, height, mapName, showCrosshair, realtime, registry)
  draw.begin2d(width, height)
  if showCrosshair and (menuState is void or not menuState.active) then drawCrosshair(width, height) end if
  drawBlend(viewState, width, height)
  drawHud(consoleState, menuState, player, width, height, registry)
  drawNotify(consoleState, width, height)
  drawCenter(consoleState, width, height)
  draw.end2d()
  menu.render(menuState, consoleState.textureId, width, height, mapName, realtime, registry)
  draw.drawConsole(consoleState, width, height, 1.0)
  return true
end function
