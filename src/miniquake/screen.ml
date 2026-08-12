package miniquake.screen

import miniquake.render.gl11 as gl
import miniquake.render.draw2d as draw
import miniquake.native as native
import miniquake.menu as menu
import miniquake.statusbar as statusbar
import miniquake.cvar as cvar
import miniquake.console as console
import miniquake.keys as keys
import miniquake.filesystem as qfs
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.view as view
import miniquake.gl_vidnt as glvid
import std.fs as fs
import miniquake.render_ui_contract as renderUiContract

scr_copytop = 0
scr_copyeverything = 0
scr_con_current = 0.0
scr_conlines = 0.0
oldscreensize = -1.0
oldfov = -1.0
oldRefdefWidth = -1
oldRefdefHeight = -1
oldRefdefIntermission = -1
scr_initialized = false
scr_ram = void
scr_net = void
scr_turtle = void
scr_fullupdate = 0
clearconsole = 0
clearnotify = 0
sb_lines = 0
scr_vrect = [0, 0, 320, 152, 90.0, 74.0]
scr_disabled_for_loading = false
scr_drawloading = false
scr_disabled_time = 0.0
scr_loading_pending = false
block_drawing = false
scr_skipupdate = false
scr_centerstring = ""
scr_centertime_start = 0.0
scr_centertime_off = 0.0
scr_center_lines = 0
scr_erase_lines = 0
scr_erase_center = 0
scr_notifystring = ""
scr_drawdialog = false
scr_turtle_count = 0
scr_intermission = 0
scr_transition_clear_frames = 0
screenFilesystem = void
screenRegistry = void
screenClient = void
screenConsole = void
screenBasePalette = void
lastScreenCommands = []
screenRealtime = 0.0
screenVideoWidth = 320

function initialize(consoleState, menuState, filesystem, palette, width, height, registry)
  global screenConsole, screenBasePalette
  if consoleState is void then return false end if
  screenConsole = consoleState
  screenBasePalette = palette
  if consoleState.textureId == 0 then
    initialized = try(draw.Draw_Init(filesystem, palette, width, height, registry))
    if initialized is error then return false end if
    consoleState.textureId = draw.CharTexture()
  end if
  if not scr_initialized then
    initialized = try(SCR_Init(filesystem, registry, width, height))
    if initialized is error then return false end if
  end if
  if menuState is not void then menu.initialize(menuState, filesystem, palette) end if
  sbarInitialized = try(statusbar.Sbar_Init(filesystem.gameDirectory))
  if sbarInitialized is error then return false end if
  return true
end function

function SCR_ConfigureClient(clientState)
  global screenClient
  screenClient = clientState
  return true
end function

function shutdown(consoleState, menuState)
  global scr_initialized, scr_ram, scr_net, scr_turtle, screenFilesystem, screenRegistry, screenClient, screenConsole, screenBasePalette
  if menuState is not void then menu.shutdown(menuState) end if
  if consoleState is not void then consoleState.textureId = 0 end if
  draw.Draw_Shutdown()
  statusbar.Sbar_Shutdown()
  scr_initialized = false
  scr_ram = void
  scr_net = void
  scr_turtle = void
  screenFilesystem = void
  screenRegistry = void
  screenClient = void
  screenConsole = void
  screenBasePalette = void
  return true
end function

function drawCrosshair(width, height)
  centerX = native.trunc(width * 0.5) - 4
  centerY = native.trunc(height * 0.5) - 4
  return draw.Draw_Character(centerX, centerY, 43)
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
  teamplay = 0.0
  if registry is not void then teamplay = cvar.variableValue(registry, "teamplay") end if
  return statusbar.render(menuState, consoleState.textureId, player, width, height, viewSize, screenClient, teamplay)
end function


function drawNotify(consoleState, width, height)
  if consoleState is void or consoleState.textureId == 0 or consoleState.active then return false end if
  scale = renderUiContract.consoleScale(width, height)
  messageMode = keys.destination() == keys.KEY_MESSAGE
  commands = console.Con_DrawNotify(consoleState, screenRealtime, screenCvar("con_notifytime", 3.0), messageMode, keys.chatBuffer)
  for each command in commands
    data = command[3]
    index = 0
    while index < len(data)
      draw.character(
        consoleState.textureId,
        (command[1] + index * 8) * scale,
        command[2] * scale,
        data[index],
        scale,
        255,
      )
      index = index + 1
    end while
    if command[0] == "chat" then
      draw.character(
        consoleState.textureId,
        (command[1] + len(data) * 8) * scale,
        command[2] * scale,
        command[4],
        scale,
        255,
      )
    end if
  end for
  return true
end function

function drawCenter(consoleState, width, height)
  if consoleState is void or consoleState.textureId == 0 or consoleState.centerText == "" then return false end if
  data = bytes(consoleState.centerText)
  transform = menu.layout(width, height)
  if transform[2] <= 1.0 then
    lineWidth = len(data) * 8.0
    x = (width - lineWidth) * 0.5
    if x < 8.0 then x = 8.0 end if
    y = height * 0.35
    draw.string(consoleState.textureId, x, y, consoleState.centerText, 1.0, 255)
    return true
  end if
  lineWidth = len(data) * 8.0
  x = (320.0 - lineWidth) * 0.5
  if x < 8.0 then x = 8.0 end if
  y = 70.0
  draw.string(
    consoleState.textureId,
    transform[0] + x * transform[2],
    transform[1] + y * transform[2],
    consoleState.centerText,
    transform[2],
    255,
  )
  return true
end function

// =============================================================================
// gl_screen.c compatibility surface
// =============================================================================

function screenCvar(name, fallback)
  if screenRegistry is void then return fallback end if
  variable = cvar.find(screenRegistry, name)
  if variable is void then return fallback end if
  return variable.value
end function

function SCR_CenterPrint(consoleState, text, currentTime)
  global scr_centerstring, scr_centertime_off, scr_centertime_start, scr_center_lines
  data = bytes(text)
  if len(data) > 1023 then data = slice(data, 0, 1023); text = decode(data) end if
  scr_centerstring = text
  scr_centertime_off = screenCvar("scr_centertime", 2.0)
  scr_centertime_start = currentTime
  scr_center_lines = 1
  index = 0
  while index < len(data)
    if data[index] == 10 then scr_center_lines = scr_center_lines + 1 end if
    index = index + 1
  end while
  if consoleState is not void then
    consoleState.centerText = text
    consoleState.centerUntil = currentTime + scr_centertime_off
    console.Con_LogCenterPrint(consoleState, text, currentTime)
  end if
  return scr_center_lines
end function

function CenterStringTrace(text, width, height, lineCount, remaining)
  commands = []
  source = bytes(text)
  offset = 0
  y = 48
  if lineCount <= 4 then y = native.trunc(height * 0.35) end if
  while offset < len(source)
    length = 0
    while length < 40 and offset + length < len(source) and source[offset + length] != 10
      length = length + 1
    end while
    x = native.trunc((width - length * 8) / 2)
    index = 0
    while index < length
      commands = commands + [[x, y, source[offset + index]]]
      if remaining == 0 then return commands end if
      remaining = remaining - 1
      x = x + 8
      index = index + 1
    end while
    y = y + 8
    offset = offset + length
    if offset >= len(source) then break end if
    if source[offset] == 10 then offset = offset + 1 end if
  end while
  return commands
end function

function SCR_DrawCenterString(width, height, currentTime)
  global scr_erase_center
  remaining = 9999
  if scr_intermission != 0 then
    remaining = native.trunc(screenCvar("scr_printspeed", 8.0) * (currentTime - scr_centertime_start))
  end if
  scr_erase_center = 0
  transform = menu.layout(width, height)
  commands = []
  if transform[2] <= 1.0 then
    commands = CenterStringTrace(scr_centerstring, width, height, scr_center_lines, remaining)
    for each command in commands
      draw.Draw_Character(command[0], command[1], command[2])
    end for
  else
    commands = CenterStringTrace(scr_centerstring, 320, 200, scr_center_lines, remaining)
    for each command in commands
      if screenConsole is not void and screenConsole.textureId != 0 then
        draw.character(
          screenConsole.textureId,
          transform[0] + command[0] * transform[2],
          transform[1] + command[1] * transform[2],
          command[2],
          transform[2],
          255,
        )
      else
        draw.Draw_Character(
          transform[0] + command[0] * transform[2],
          transform[1] + command[1] * transform[2],
          command[2],
        )
      end if
    end for
  end if
  return len(commands)
end function

function SCR_CheckDrawCenterString(width, height, currentTime, frameTime, gameInput)
  global scr_copytop, scr_erase_lines, scr_centertime_off
  scr_copytop = 1
  if scr_center_lines > scr_erase_lines then scr_erase_lines = scr_center_lines end if
  scr_centertime_off = scr_centertime_off - frameTime
  if scr_centertime_off <= 0.0 and scr_intermission == 0 then return 0 end if
  if not gameInput then return 0 end if
  return SCR_DrawCenterString(width, height, currentTime)
end function

function CalcFov(fov_x, width, height)
  if fov_x < 1.0 or fov_x > 179.0 then return error(3400, "Bad fov: " + fov_x) end if
  halfAngle = fov_x * math.DEG_TO_RAD * 0.5
  tangent = math.sin(halfAngle) / math.cos(halfAngle)
  x = width / tangent
  return math.atan2(height, x) * 2.0 * math.RAD_TO_DEG
end function

function SCR_CalcRefdef(width, height, registry, intermission)
  global scr_fullupdate, sb_lines, scr_vrect, oldscreensize, oldfov, screenRegistry
  global oldRefdefWidth, oldRefdefHeight, oldRefdefIntermission, scr_transition_clear_frames
  if registry is not void then screenRegistry = registry end if
  viewSize = screenCvar("viewsize", 100.0)
  fov = screenCvar("fov", 90.0)
  refdefChanged = viewSize != oldscreensize or fov != oldfov or width != oldRefdefWidth or height != oldRefdefHeight or intermission != oldRefdefIntermission
  oldscreensize = viewSize
  oldfov = fov
  oldRefdefWidth = width
  oldRefdefHeight = height
  oldRefdefIntermission = intermission
  if refdefChanged then
    scr_fullupdate = 0
    scr_transition_clear_frames = 3
    statusbar.Sbar_Changed()
  end if
  if viewSize < 30.0 then viewSize = 30.0; if screenRegistry is not void then cvar.setValue(screenRegistry, "viewsize", viewSize) end if end if
  if viewSize > 120.0 then viewSize = 120.0; if screenRegistry is not void then cvar.setValue(screenRegistry, "viewsize", viewSize) end if end if
  if fov < 10.0 then fov = 10.0; if screenRegistry is not void then cvar.setValue(screenRegistry, "fov", fov) end if end if
  if fov > 170.0 then fov = 170.0; if screenRegistry is not void then cvar.setValue(screenRegistry, "fov", fov) end if end if

  size = viewSize
  if intermission != 0 then size = 120.0 end if
  sb_lines = renderUiContract.statusbarPhysicalLines(width, height, size, intermission)

  full = false
  if viewSize >= 100.0 then full = true; size = 100.0 else size = viewSize end if
  if intermission != 0 then full = true; size = 100.0; sb_lines = 0 end if
  size = size / 100.0
  availableHeight = height - sb_lines
  viewWidth = native.trunc(width * size)
  if viewWidth < 96 then size = 96.0 / viewWidth; viewWidth = 96 end if
  viewHeight = native.trunc(height * size)
  if viewHeight > availableHeight then viewHeight = availableHeight end if
  if viewHeight > height then viewHeight = height end if
  viewX = native.trunc((width - viewWidth) / 2)
  viewY = 0
  if not full then viewY = native.trunc((availableHeight - viewHeight) / 2) end if
  fovY = try(CalcFov(fov, viewWidth, viewHeight))
  if fovY is error then return fovY end if
  scr_vrect = [viewX, viewY, viewWidth, viewHeight, fov, fovY]
  return scr_vrect
end function

function SCR_SizeUp_f(registry)
  if registry is void then return false end if
  return cvar.setValue(registry, "viewsize", cvar.variableValue(registry, "viewsize") + 10.0)
end function

function SCR_SizeDown_f(registry)
  if registry is void then return false end if
  return cvar.setValue(registry, "viewsize", cvar.variableValue(registry, "viewsize") - 10.0)
end function

function SCR_SizeUp()
  return SCR_SizeUp_f(screenRegistry)
end function

function SCR_SizeDown()
  return SCR_SizeDown_f(screenRegistry)
end function

function SCR_Init(filesystem, registry, width, height)
  global scr_initialized, scr_ram, scr_net, scr_turtle, screenFilesystem, screenRegistry, screenVideoWidth
  screenFilesystem = filesystem
  screenRegistry = registry
  screenVideoWidth = width
  draw.SetVideoSize(width, height)
  scr_ram = try(draw.Draw_PicFromWad("ram"))
  if scr_ram is error then return scr_ram end if
  scr_net = try(draw.Draw_PicFromWad("net"))
  if scr_net is error then return scr_net end if
  scr_turtle = try(draw.Draw_PicFromWad("turtle"))
  if scr_turtle is error then return scr_turtle end if
  SCR_CalcRefdef(width, height, registry, 0)
  scr_initialized = true
  return true
end function

// scr_conspeed is expressed in the original UI's logical pixels per second.
// The console itself is enlarged by an integral factor on high-resolution
// displays, so its physical travel must use that same factor. Otherwise a
// 1080p/4K console takes two to four times as long to open or close.
function SCR_ConsoleSlidePixels(width, height, frameTime, registry)
  if registry is not void then
    variable = cvar.find(registry, "scr_conspeed")
    if variable is not void then return variable.value * frameTime * renderUiContract.consoleScale(width, height) end if
  end if
  return 300.0 * frameTime * renderUiContract.consoleScale(width, height)
end function

function SCR_DrawRam(cacheThrash)
  if screenCvar("showram", 1.0) == 0.0 or not cacheThrash or scr_ram is void then return false end if
  return draw.Draw_Pic(scr_vrect[0] + 32, scr_vrect[1], scr_ram)
end function

function SCR_DrawTurtle(frameTime)
  global scr_turtle_count
  if screenCvar("showturtle", 0.0) == 0.0 or scr_turtle is void then return false end if
  if frameTime < 0.1 then scr_turtle_count = 0; return false end if
  scr_turtle_count = scr_turtle_count + 1
  if scr_turtle_count < 3 then return false end if
  return draw.Draw_Pic(scr_vrect[0], scr_vrect[1], scr_turtle)
end function

function inline SCR_ShouldDrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)
  if not connected or localServerActive or demoPlayback then return false end if
  if lastMessageTime <= 0.0 or realtime - lastMessageTime < 0.3 then return false end if
  return true
end function

function SCR_DrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)
  if not SCR_ShouldDrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive) then return false end if
  if scr_net is void then return false end if
  return draw.Draw_Pic(scr_vrect[0] + 64, scr_vrect[1], scr_net)
end function

function SCR_DrawPause(paused, width, height)
  if screenCvar("showpause", 1.0) == 0.0 or not paused then return false end if
  picture = try(draw.Draw_CachePic("gfx/pause.lmp"))
  if picture is error then return picture end if
  return draw.Draw_Pic(native.trunc((width - picture.width) / 2), native.trunc((height - 48 - picture.height) / 2), picture)
end function

function SCR_DrawLoading(width, height)
  if not scr_drawloading then return false end if
  picture = try(draw.Draw_CachePic("gfx/loading.lmp"))
  if picture is error then return picture end if
  return draw.Draw_Pic(native.trunc((width - picture.width) / 2), native.trunc((height - 48 - picture.height) / 2), picture)
end function

function SCR_SetUpToDrawConsole(consoleState, height, frameTime, registry, forcedUp, consoleInput, numPages)
  global scr_conlines, scr_con_current, clearconsole, clearnotify, screenRegistry, screenVideoWidth
  if registry is not void then screenRegistry = registry end if
  if consoleState is not void then consoleState.forcedUp = forcedUp end if
  if scr_drawloading then return scr_con_current end if
  if forcedUp then
    scr_conlines = height
    scr_con_current = scr_conlines
  else if consoleInput then scr_conlines = height / 2.0
  else scr_conlines = 0.0
  end if
  speed = SCR_ConsoleSlidePixels(screenVideoWidth, height, frameTime, registry)
  if scr_conlines < scr_con_current then
    scr_con_current = scr_con_current - speed
    if scr_conlines > scr_con_current then scr_con_current = scr_conlines end if
  else if scr_conlines > scr_con_current then
    scr_con_current = scr_con_current + speed
    if scr_conlines < scr_con_current then scr_con_current = scr_conlines end if
  end if
  oldClear = clearconsole
  clearconsole = clearconsole + 1
  if oldClear < numPages then
    statusbar.Sbar_Changed()
  else
    oldNotify = clearnotify
    clearnotify = clearnotify + 1
    if oldNotify >= numPages and consoleState is not void then consoleState.notifyPixelLines = 0 end if
  end if
  return scr_con_current
end function

function drawConsoleHeight(consoleState, width, height, visibleHeight)
  if consoleState is void or consoleState.textureId == 0 or visibleHeight <= 0 then return false end if
  scale = renderUiContract.consoleScale(width, height)
  physicalLines = native.trunc(visibleHeight)
  logicalLines = renderUiContract.consoleLogicalHeight(width, height, physicalLines)
  commands = console.Con_DrawConsole(consoleState, logicalLines, true, screenRealtime)
  for each command in commands
    if command[0] == "background" then
      draw.Draw_ConsoleBackground(physicalLines)
    else if command[0] == "text" then
      data = command[3]
      index = 0
      while index < len(data)
        draw.character(
          consoleState.textureId,
          (command[1] + index * 8) * scale,
          command[2] * scale,
          data[index],
          scale,
          255,
        )
        index = index + 1
      end while
    else if command[0] == "input" then
      data = command[1]
      index = 0
      while index < len(data)
        draw.character(
          consoleState.textureId,
          (8 + index * 8) * scale,
          (logicalLines - 16) * scale,
          data[index],
          scale,
          255,
        )
        index = index + 1
      end while
    end if
  end for
  return true
end function

function SCR_DrawConsole(consoleState, width, height, gameOrMessageInput)
  global scr_copyeverything, clearconsole
  if scr_con_current > 0.0 then
    scr_copyeverything = 1
    drawConsoleHeight(consoleState, width, height, scr_con_current)
    clearconsole = 0
    return "console"
  end if
  if gameOrMessageInput or keys.destination() == keys.KEY_MESSAGE then drawNotify(consoleState, width, height); return "notify" end if
  return "none"
end function

function BuildTga(width, height, rgba)
  if width <= 0 or height <= 0 or len(rgba) < width * height * 4 then return error(3401, "SCR_ScreenShot_f: invalid framebuffer") end if
  output = bytes(renderUiContract.tgaByteLength(width, height))
  output[2] = 2
  output[12] = width & 255
  output[13] = (width >> 8) & 255
  output[14] = height & 255
  output[15] = (height >> 8) & 255
  output[16] = 24
  index = 0
  while index < width * height
    source = index * 4
    destination = 18 + index * 3
    output[destination] = rgba[source + 2]
    output[destination + 1] = rgba[source + 1]
    output[destination + 2] = rgba[source]
    index = index + 1
  end while
  return output
end function

function screenshotName(filesystem)
  index = 0
  while index <= 99
    tens = native.trunc(index / 10)
    ones = index % 10
    name = "quake" + tens + ones + ".tga"
    if not fs.exists(qfs.gamePath(filesystem, name)) then return name end if
    index = index + 1
  end while
  return ""
end function

function SCR_ScreenshotFailure()
  // MiniQuake writes a TGA but preserves this historical PCX diagnostic text.
  return error(3402, "SCR_ScreenShot_f: Couldn't create a PCX file")
end function

function SCR_ScreenShot_f(filesystem, x, y, width, height)
  name = screenshotName(filesystem)
  if name == "" then return SCR_ScreenshotFailure() end if
  rgba = gl.readPixelsRgba(x, y, width, height)
  tga = try(BuildTga(width, height, rgba))
  if tga is error then return tga end if
  written = qfs.writeFile(filesystem, name, tga)
  if written is error then return written end if
  return name
end function

function SCR_BeginLoadingPlaque(consoleState, realtime, connected, signon)
  global scr_drawloading, scr_fullupdate, scr_disabled_for_loading, scr_disabled_time, scr_centertime_off, scr_con_current, scr_loading_pending
  if not connected or signon != c.SIGNONS then return false end if
  if consoleState is not void then console.Con_ClearNotify(consoleState) end if
  scr_centertime_off = 0.0
  scr_con_current = 0.0
  scr_drawloading = true
  scr_loading_pending = true
  scr_fullupdate = 0
  statusbar.Sbar_Changed()
  scr_disabled_for_loading = false
  scr_disabled_time = realtime
  return true
end function

function SCR_EndLoadingPlaque(consoleState)
  global scr_disabled_for_loading, scr_drawloading, scr_fullupdate, scr_loading_pending
  scr_disabled_for_loading = false
  scr_drawloading = false
  scr_loading_pending = false
  scr_fullupdate = 0
  if consoleState is not void then console.Con_ClearNotify(consoleState) end if
  return true
end function

function SCR_DrawNotifyString(width, height)
  transform = menu.layout(width, height)
  if transform[2] <= 1.0 then
    commands = CenterStringTrace(scr_notifystring, width, height, 1, 9999)
    for each command in commands
      draw.Draw_Character(command[0], command[1], command[2])
    end for
    return len(commands)
  end if
  commands = CenterStringTrace(scr_notifystring, 320, 200, 1, 9999)
  for each command in commands
    if screenConsole is void or screenConsole.textureId == 0 then
      draw.Draw_Character(
        transform[0] + command[0] * transform[2],
        transform[1] + command[1] * transform[2],
        command[2],
      )
    else
      draw.character(
        screenConsole.textureId,
        transform[0] + command[0] * transform[2],
        transform[1] + command[1] * transform[2],
        command[2],
        transform[2],
        255,
      )
    end if
  end for
  return len(commands)
end function

// The original blocks in a platform event loop.  MiniLang's host owns that
// loop, so a key code is supplied when available; void means "still pending".
function SCR_ModalMessage(text, keyCode, dedicated)
  global scr_notifystring, scr_drawdialog, scr_fullupdate
  if dedicated then return true end if
  scr_notifystring = text
  scr_fullupdate = 0
  scr_drawdialog = true
  if keyCode is void then return void end if
  if keyCode == 121 or keyCode == 89 then scr_drawdialog = false; scr_fullupdate = 0; return true end if
  if keyCode == 110 or keyCode == 78 or keyCode == 27 then scr_drawdialog = false; scr_fullupdate = 0; return false end if
  return void
end function

function SCR_BringDownConsole(consoleState, height, frameTime, registry, viewState)
  global scr_centertime_off
  scr_centertime_off = 0.0
  steps = 0
  while steps < 20 and scr_conlines != scr_con_current
    SCR_SetUpToDrawConsole(consoleState, height, frameTime, registry, false, false, 3)
    steps = steps + 1
  end while
  if viewState is not void then viewState.cshifts[view.CSHIFT_CONTENTS][3] = 0.0 end if
  if screenBasePalette is not void then glvid.VID_SetPalette(screenBasePalette) end if
  return steps
end function

function SCR_TileClear(width, height)
  commands = []
  x = scr_vrect[0]
  y = scr_vrect[1]
  viewWidth = scr_vrect[2]
  viewHeight = scr_vrect[3]
  if x > 0 then
    draw.Draw_TileClear(0, 0, x, height - sb_lines)
    commands = commands + [[0, 0, x, height - sb_lines]]
    rightX = x + viewWidth
    // Preserve MiniQuake 1.09's historical width expression verbatim.
    rightWidth = width - x + viewWidth
    if rightWidth > 0 then draw.Draw_TileClear(rightX, 0, rightWidth, height - sb_lines); commands = commands + [[rightX, 0, rightWidth, height - sb_lines]] end if
  end if
  if y > 0 then
    topWidth = x + viewWidth
    draw.Draw_TileClear(x, 0, topWidth, y)
    commands = commands + [[x, 0, topWidth, y]]
    bottomY = y + viewHeight
    bottomHeight = height - sb_lines - bottomY
    if bottomHeight > 0 then draw.Draw_TileClear(x, bottomY, viewWidth, bottomHeight); commands = commands + [[x, bottomY, viewWidth, bottomHeight]] end if
  end if
  return commands
end function

function SCR_SetIntermission(mode, text, consoleState, currentTime)
  global scr_intermission, scr_fullupdate, scr_transition_clear_frames
  if mode != scr_intermission then
    scr_fullupdate = 0
    scr_transition_clear_frames = 3
    statusbar.Sbar_Changed()
  end if
  scr_intermission = mode
  if text != "" then SCR_CenterPrint(void, text, currentTime) end if
  return scr_intermission
end function

// Refdef and overlay transitions can expose pixels that belonged to a smaller
// viewport or an older status bar on another swap-chain page. Clear each
// buffered page once; steady-state frames retain GLQuake's gl_clear behavior.
function SCR_ConsumeTransitionClear()
  global scr_transition_clear_frames
  if scr_transition_clear_frames <= 0 then return false end if
  scr_transition_clear_frames = scr_transition_clear_frames - 1
  return true
end function

function inline SCR_IntermissionMode()
  return scr_intermission
end function

// Deterministic differential hooks. They expose logical C globals without
// putting renderer or platform behavior into the native bridge.
function SCR_DifferentialSetEraseLines(value)
  global scr_erase_lines
  scr_erase_lines = value
  return value
end function

function SCR_DifferentialSetTurtleCount(value)
  global scr_turtle_count
  scr_turtle_count = value
  return value
end function

function SCR_DifferentialSetDrawLoading(value)
  global scr_drawloading
  scr_drawloading = value
  return value
end function

function SCR_DifferentialSetConsole(current, lines)
  global scr_con_current, scr_conlines
  scr_con_current = current
  scr_conlines = lines
  return current
end function

function SCR_DifferentialSetNotify(text)
  global scr_notifystring
  scr_notifystring = text
  return text
end function

function SCR_DifferentialSetTile(viewRectangle, statusLines)
  global scr_vrect, sb_lines
  scr_vrect = viewRectangle
  sb_lines = statusLines
  return scr_vrect
end function

function SCR_DifferentialSetBlocked(value)
  global block_drawing
  block_drawing = value
  return block_drawing
end function

function SCR_DifferentialState()
  return [
    scr_copytop,
    scr_copyeverything,
    scr_con_current,
    scr_conlines,
    scr_centertime_off,
    scr_centertime_start,
    scr_center_lines,
    scr_erase_lines,
    scr_erase_center,
    sb_lines,
    scr_fullupdate,
    scr_disabled_for_loading,
    scr_turtle_count,
    clearconsole,
    scr_ram,
    scr_net,
    scr_turtle,
  ]
end function

function SCR_ShouldSkipUpdate(realtime)
  global scr_disabled_for_loading
  if block_drawing or scr_skipupdate then return true end if
  if scr_loading_pending then return false end if
  if not scr_disabled_for_loading then return false end if
  if realtime - scr_disabled_time > 60.0 then
    scr_disabled_for_loading = false
    if screenConsole is not void then
      console.Con_Printf(screenConsole, "load failed.\n", screenConsole.dedicated, false)
    else
      print "load failed."
    end if
    return false
  end if
  return true
end function

function ScreenCommandTrace()
  return lastScreenCommands
end function

function SCR_UpdateWholeScreen()
  global scr_fullupdate
  scr_fullupdate = 0
  return true
end function

function ScreenOverlayOrder(dialog, loading, intermission, gameInput)
  return renderUiContract.overlayOrder(dialog, loading, intermission, gameInput)
end function

function SCR_UpdateScreen(
  consoleState,
  menuState,
  viewState,
  player,
  width,
  height,
  mapName,
  showCrosshair,
  realtime,
  frameTime,
  registry,
  connected,
  localServerActive,
  signon,
  paused,
  lastMessageTime,
  demoPlayback,
  cacheThrash,
  gameInput,
  consoleInput
)
  global scr_copytop, scr_copyeverything, lastScreenCommands, scr_fullupdate, scr_loading_pending, scr_drawloading, scr_disabled_for_loading, scr_disabled_time, screenRealtime, screenVideoWidth
  screenRealtime = realtime
  screenVideoWidth = width
  lastScreenCommands = []
  if block_drawing or scr_skipupdate or not scr_initialized then return lastScreenCommands end if
  if SCR_ShouldSkipUpdate(realtime) then lastScreenCommands = [["skip-loading"]]; return lastScreenCommands end if
  scr_copytop = 0
  scr_copyeverything = 0
  draw.SetVideoSize(width, height)
  console.Con_CheckResize(consoleState, renderUiContract.consoleLogicalWidth(width, height))
  refdef = SCR_CalcRefdef(width, height, registry, scr_intermission)
  if refdef is error then return refdef end if
  numPages = 2 + native.trunc(screenCvar("gl_triplebuffer", 1.0))
  SCR_SetUpToDrawConsole(consoleState, height, frameTime, registry, not connected or signon != c.SIGNONS, consoleInput, numPages)
  draw.GL_Set2D()
  lastScreenCommands = lastScreenCommands + [["set2d"]]
  SCR_TileClear(width, height)
  lastScreenCommands = lastScreenCommands + [["tileclear"]]
  teamplay = screenCvar("teamplay", 0.0)
  statusbar.Sbar_Configure(menuState, consoleState.textureId, player, screenClient, width, height, sb_lines, teamplay)
  statusbar.Sbar_SetFrameState(scr_con_current, numPages)

  if scr_drawdialog then
    drawHud(consoleState, menuState, player, width, height, registry)
    draw.Draw_FadeScreen()
    statusbar.Sbar_Changed()
    SCR_DrawNotifyString(width, height)
    scr_copyeverything = 1
    lastScreenCommands = lastScreenCommands + [["dialog"], ["hud"], ["fade"], ["notify-string"]]
  else if scr_drawloading then
    SCR_DrawLoading(width, height)
    drawHud(consoleState, menuState, player, width, height, registry)
    lastScreenCommands = lastScreenCommands + [["loading"], ["hud"]]
  else if scr_intermission == 1 and gameInput then
    statusbar.Sbar_IntermissionOverlay()
    lastScreenCommands = lastScreenCommands + [["intermission"]]
  else if scr_intermission == 2 and gameInput then
    statusbar.Sbar_FinaleOverlay()
    SCR_CheckDrawCenterString(width, height, realtime, frameTime, gameInput)
    lastScreenCommands = lastScreenCommands + [["finale"], ["center"]]
  else if scr_intermission == 3 and gameInput then
    SCR_CheckDrawCenterString(width, height, realtime, frameTime, gameInput)
    lastScreenCommands = lastScreenCommands + [["center"]]
  else
    if showCrosshair then
      draw.Draw_Character(scr_vrect[0] + native.trunc(scr_vrect[2] / 2), scr_vrect[1] + native.trunc(scr_vrect[3] / 2), 43)
      lastScreenCommands = lastScreenCommands + [["crosshair"]]
    end if
    if SCR_DrawRam(cacheThrash) then lastScreenCommands = lastScreenCommands + [["ram"]] end if
    if SCR_DrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive) then lastScreenCommands = lastScreenCommands + [["net"]] end if
    if SCR_DrawTurtle(frameTime) then lastScreenCommands = lastScreenCommands + [["turtle"]] end if
    if SCR_DrawPause(paused, width, height) then lastScreenCommands = lastScreenCommands + [["pause"]] end if
    SCR_CheckDrawCenterString(width, height, realtime, frameTime, gameInput)
    lastScreenCommands = lastScreenCommands + [["center"]]
    drawHud(consoleState, menuState, player, width, height, registry)
    lastScreenCommands = lastScreenCommands + [["hud"]]
    consoleResult = SCR_DrawConsole(consoleState, width, height, gameInput)
    lastScreenCommands = lastScreenCommands + [[consoleResult]]
    menu.render(menuState, consoleState.textureId, width, height, mapName, realtime, registry)
    lastScreenCommands = lastScreenCommands + [["menu"]]
  end if
  draw.end2d()
  // gl_screen.c updates the cshifts only after the entire 2D overlay has been
  // drawn.  R_PolyBlend therefore consumed the pre-update blend for this
  // frame, while this prepares the blend/gamma ramps for the next frame.
  if viewState is not void and player is not void and registry is not void then
    view.V_UpdatePalette(
      viewState,
      player.items,
      frameTime,
      cvar.variableValue(registry, "gl_cshiftpercent"),
      cvar.variableValue(registry, "gamma"),
    )
    lastScreenCommands = lastScreenCommands + [["palette"]]
  end if
  if scr_loading_pending then
    scr_loading_pending = false
    scr_drawloading = false
    scr_disabled_for_loading = true
    scr_disabled_time = realtime
  end if
  scr_fullupdate = scr_fullupdate + 1
  return lastScreenCommands
end function

function render(consoleState, menuState, viewState, player, width, height, mapName, showCrosshair, realtime, registry)
  global screenRealtime
  screenRealtime = realtime
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
