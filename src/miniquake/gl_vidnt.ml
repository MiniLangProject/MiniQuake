/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Windows x64 MiniLang port of WinQuake/gl_vidnt.c and vid.h.  Display, WGL and
device-gamma calls remain in the native bridge; all selection and compatibility
semantics live here.
*/

package miniquake.gl_vidnt

import miniquake.common as common
import miniquake.cvar as cvar
import miniquake.keys as keys
import miniquake.input as input
import miniquake.platform.win32 as win
import miniquake.render.gl11 as gl
import miniquake.native as native
import miniquake.sound.mixer as sound
import std.math as stdmath
import std.string as string

const MAX_MODE_LIST = 30
const MAX_MODEDESCS = 27
const VID_ROW_SIZE = 3
const WARP_WIDTH = 320
const WARP_HEIGHT = 200
const MODE_WINDOWED = 0
const NO_MODE = -1
const MODE_FULLSCREEN_DEFAULT = 1
const MS_WINDOWED = 0
const MS_FULLDIB = 2
const MS_UNINIT = 3

struct VideoMode
  type
  width
  height
  modeNumber
  dib
  fullscreen
  bpp
  halfscreen
  frequency
  description
end struct

struct VideoState
  modes
  badMode
  initialized
  windowed
  leaveCurrentMode
  canAltTab
  wasSuspended
  activeApp
  minimized
  windowedMouse
  currentMode
  realMode
  defaultMode
  windowedDefault
  modeState
  dibWidth
  dibHeight
  windowX
  windowY
  windowWidth
  windowHeight
  windowCenterX
  windowCenterY
  conWidth
  conHeight
  width
  height
  numPages
  recalcRefdef
  maxWarpWidth
  maxWarpHeight
  palette
  table16
  table24
  table15
  gamma
  gammaWorks
  glVendor
  glRenderer
  glVersion
  glExtensions
  textureObjects
  arrayExtension
  multitexture
  is8bit
  isPermedia
  fullSbarDraw
  registry
  arguments
  lastModeMessage
  drawTrace
  createNative
  skipUpdate
  blockDrawing
  soundBlocked
  paused
  forceLock
  desktopWidth
  desktopHeight
  sbarChangedCount
  soundMixer
end struct

currentVideoState = void

function makeMode(type, width, height, bpp, frequency, halfscreen)
  description = "" + width + "x" + height
  if type == MS_FULLDIB then description = description + "x" + bpp end if
  return VideoMode(type, width, height, 0, 1, type == MS_FULLDIB, bpp, halfscreen, frequency, description)
end function

function createVideoState()
  bad = makeMode(MS_UNINIT, 0, 0, 0, 0, 0)
  bad.description = "Bad mode"
  return VideoState(
    [],
    bad,
    false,
    true,
    false,
    false,
    false,
    true,
    false,
    false,
    NO_MODE,
    NO_MODE,
    MODE_WINDOWED,
    MODE_WINDOWED,
    MS_UNINIT,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    640,
    480,
    640,
    480,
    2,
    true,
    WARP_WIDTH,
    WARP_HEIGHT,
    bytes(768),
    [],
    [],
    bytes(65536),
    1.0,
    false,
    "",
    "",
    "",
    "",
    false,
    false,
    false,
    false,
    false,
    false,
    void,
    void,
    "",
    [],
    false,
    false,
    false,
    false,
    false,
    0,
    0,
    0,
    0,
    void,
  )
end function

function inline VID_WindowTitleForFps(fps)
  safeFps = native.trunc(fps)
  if safeFps < 0 then safeFps = 0 end if
  if safeFps > 9999 then safeFps = 9999 end if
  return "MiniQuake - " + safeFps + " FPS"
end function

function VID_UseState(state)
  global currentVideoState
  currentVideoState = state
  return state
end function

function VID_State()
  global currentVideoState
  if currentVideoState is void then currentVideoState = createVideoState() end if
  return currentVideoState
end function

function VID_SetSoundMixer(mixerState)
  state = VID_State()
  state.soundMixer = mixerState
  return mixerState
end function

function hasText(value, needle)
  if value == "" or needle == "" then return false end if
  return string.indexOf(value, needle, 0) >= 0
end function

function startsWithIgnoreCase(value, prefix)
  source = bytes(value)
  wanted = bytes(prefix)
  if len(source) < len(wanted) then return false end if
  index = 0
  while index < len(wanted)
    left = source[index]
    right = wanted[index]
    if left >= 65 and left <= 90 then left = left + 32 end if
    if right >= 65 and right <= 90 then right = right + 32 end if
    if left != right then return false end if
    index = index + 1
  end while
  return true
end function

function VID_HandlePause(pause)
  state = VID_State()
  state.paused = pause
  return true
end function

function VID_ForceLockState(lockState)
  state = VID_State()
  state.forceLock = lockState
  return true
end function

function VID_LockBuffer()
  return true
end function

function VID_UnlockBuffer()
  return true
end function

function VID_ForceUnlockedAndReturnState()
  return 0
end function

function D_BeginDirectRect(x, y, bitmap, width, height)
  return false
end function

function D_EndDirectRect(x, y, width, height)
  return false
end function

function CenterWindow(width, height, screenWidth, screenHeight, leftTopJustify)
  centerX = native.trunc((screenWidth - width) / 2)
  centerY = native.trunc((screenHeight - height) / 2)
  if centerX > centerY * 2 then centerX = centerX >> 1 end if
  if centerX < 0 then centerX = 0 end if
  if centerY < 0 then centerY = 0 end if
  return [centerX, centerY]
end function

function VID_ModeLess(left, right)
  if left.width != right.width then return left.width < right.width end if
  if left.height != right.height then return left.height < right.height end if
  if left.bpp != right.bpp then return left.bpp < right.bpp end if
  return left.frequency < right.frequency
end function

function VID_SortModes(modes)
  sorted = []
  for each candidate in modes
    inserted = false
    next = []
    for each existing in sorted
      if not inserted and VID_ModeLess(candidate, existing) then
        next = next + [candidate]
        inserted = true
      end if
      next = next + [existing]
    end for
    if not inserted then next = next + [candidate] end if
    sorted = next
  end for
  return sorted
end function

function VID_ModeExists(modes, candidate)
  for each existing in modes
    // MiniQuake's vmode_t has no refresh-rate field. EnumDisplaySettings can
    // report the same width/height/depth several times, but the original mode
    // list collapses every such refresh variant into one entry.
    if existing.width == candidate.width and existing.height == candidate.height and existing.bpp == candidate.bpp then return true end if
  end for
  return false
end function

function VID_SetWindowedMode(modeNumber, createNative)
  state = VID_State()
  mode = VID_GetModePtr(modeNumber)
  if mode.type != MS_WINDOWED then return error(3900, "VID_SetWindowedMode: bad mode") end if
  state.modeState = MS_WINDOWED
  state.dibWidth = mode.width
  state.dibHeight = mode.height
  state.windowWidth = mode.width
  state.windowHeight = mode.height
  state.windowed = true
  state.numPages = 2
  if state.conHeight > mode.height then state.conHeight = mode.height end if
  if state.conWidth > mode.width then state.conWidth = mode.width end if
  state.width = state.conWidth
  state.height = state.conHeight
  if createNative then
    if win.contextReady() then win.destroy() end if
    if not win.configureDisplayMode(mode.width, mode.height, 0, 0, false, false) then return error(3901, "VID_SetWindowedMode: display configuration failed") end if
    created = try(win.create(VID_WindowTitleForFps(0), mode.width, mode.height, 0))
    if created is error then return created end if
  end if
  VID_UpdateWindowStatus()
  return true
end function

function VID_SetFullDIBMode(modeNumber, createNative)
  state = VID_State()
  mode = VID_GetModePtr(modeNumber)
  if mode.type != MS_FULLDIB then return error(3902, "VID_SetFullDIBMode: bad mode") end if
  state.modeState = MS_FULLDIB
  state.dibWidth = mode.width
  state.dibHeight = mode.height
  state.windowWidth = mode.width
  state.windowHeight = mode.height
  state.windowX = 0
  state.windowY = 0
  state.windowed = false
  state.numPages = 2
  if state.conHeight > mode.height then state.conHeight = mode.height end if
  if state.conWidth > mode.width then state.conWidth = mode.width end if
  state.width = state.conWidth
  state.height = state.conHeight
  if createNative then
    if win.contextReady() then win.destroy() end if
    physicalWidth = mode.width << mode.halfscreen
    if not win.configureDisplayMode(physicalWidth, mode.height, mode.bpp, mode.frequency, true, state.leaveCurrentMode) then
      return error(3903, "VID_SetFullDIBMode: mode unavailable")
    end if
    created = try(win.create(VID_WindowTitleForFps(0), mode.width, mode.height, 1))
    if created is error then return created end if
  end if
  VID_UpdateWindowStatus()
  return true
end function

function VID_SetMode(modeNumber, palette, createNative)
  state = VID_State()
  if modeNumber < 0 or modeNumber >= len(state.modes) then return error(3904, "Bad video mode") end if
  mode = state.modes[modeNumber]
  if state.windowed and modeNumber != MODE_WINDOWED then return error(3905, "Bad windowed video mode") end if
  if not state.windowed and modeNumber < MODE_FULLSCREEN_DEFAULT then return error(3905, "Bad fullscreen video mode") end if
  result = void
  if mode.type == MS_WINDOWED then
    windowedMouse = false
    if state.registry is not void then windowedMouse = cvar.variableValue(state.registry, "_windowed_mouse") != 0.0 end if
    if windowedMouse and keys.destination() == keys.KEY_GAME then
      result = try(VID_SetWindowedMode(modeNumber, createNative))
      if result is not error then input.IN_ActivateMouse(); input.IN_HideMouse() end if
    else
      input.IN_DeactivateMouse()
      input.IN_ShowMouse()
      result = try(VID_SetWindowedMode(modeNumber, createNative))
    end if
  else if mode.type == MS_FULLDIB then
    result = try(VID_SetFullDIBMode(modeNumber, createNative))
    if result is not error then input.IN_ActivateMouse(); input.IN_HideMouse() end if
  else
    return error(3906, "VID_SetMode: bad mode type")
  end if
  if result is error then return result end if
  state.currentMode = modeNumber
  state.realMode = modeNumber
  if state.registry is not void then cvar.setValue(state.registry, "vid_mode", modeNumber) end if
  ClearAllStates()
  if palette is not void and len(palette) >= 768 then VID_SetPalette(palette) end if
  state.recalcRefdef = true
  state.lastModeMessage = "Video mode " + VID_GetModeDescription(modeNumber) + " initialized."
  if createNative then win.sleep(100) end if
  return true
end function

function VID_UpdateWindowStatus()
  state = VID_State()
  if state.createNative and win.contextReady() then
    state.windowX = win.windowX()
    state.windowY = win.windowY()
    state.windowWidth = win.width()
    state.windowHeight = win.height()
  end if
  state.windowCenterX = native.trunc((state.windowX + state.windowX + state.windowWidth) / 2)
  state.windowCenterY = native.trunc((state.windowY + state.windowY + state.windowHeight) / 2)
  input.IN_UpdateClipCursor()
  return [state.windowX, state.windowY, state.windowWidth, state.windowHeight, state.windowCenterX, state.windowCenterY]
end function

function CheckTextureExtensions()
  state = VID_State()
  // OpenGL 1.1 exposes core texture objects even when the EXT spelling is not
  // advertised, exactly matching the source's opengl32.dll fallback.
  state.textureObjects = true
  return true
end function

function CheckArrayExtensions()
  state = VID_State()
  state.arrayExtension = hasText(state.glExtensions, "GL_EXT_vertex_array")
  if not state.arrayExtension then return error(3911, "Vertex array extension not present") end if
  return state.arrayExtension
end function

function CheckMultiTextureExtensions()
  state = VID_State()
  disabled = false
  if state.arguments is not void then disabled = common.hasParm(state.arguments, "-nomtex") end if
  // The reference used SGIS_multitexture. Modern ICDs expose the equivalent
  // fixed-function texture units through core/ARB entry points instead.
  state.multitexture = gl.multitextureAvailable() and not disabled
  return state.multitexture
end function

function CheckMultiTextureExtensions_NonWindows()
  state = VID_State()
  state.multitexture = true
  return true
end function

function GL_Init()
  state = VID_State()
  if state.createNative and not win.contextReady() then return error(3907, "GL_Init: WGL context unavailable") end if
  if state.createNative then
    state.glVendor = gl.getString(gl.GL_VENDOR)
    state.glRenderer = gl.getString(gl.GL_RENDERER)
    state.glVersion = gl.getString(gl.GL_VERSION)
    state.glExtensions = gl.getString(gl.GL_EXTENSIONS)
  end if
  if startsWithIgnoreCase(state.glRenderer, "PowerVR") then state.fullSbarDraw = true end if
  if startsWithIgnoreCase(state.glRenderer, "Permedia") then state.isPermedia = true end if
  CheckTextureExtensions()
  CheckMultiTextureExtensions()
  if not state.createNative then return true end if
  gl.clearColor(1.0, 0.0, 0.0, 0.0)
  gl.cullFace(gl.GL_FRONT)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.enable(gl.GL_ALPHA_TEST)
  gl.alphaFunc(gl.GL_GREATER, 0.666)
  gl.polygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL)
  gl.shadeModel(gl.GL_FLAT)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
  gl.textureEnvironment(gl.GL_REPLACE)
  return true
end function

function GL_BeginRendering()
  state = VID_State()
  width = state.windowWidth
  height = state.windowHeight
  if state.createNative and win.contextReady() then width = win.width(); height = win.height() end if
  return [0, 0, width, height]
end function

function GL_EndRendering()
  state = VID_State()
  if state.createNative and win.contextReady() then
    focused = win.hasFocus()
    minimized = win.minimized()
    if focused != state.activeApp or minimized != state.minimized then AppActivate(focused, minimized) end if
    if not state.skipUpdate or state.blockDrawing then win.swap() end if
  end if
  if state.modeState == MS_WINDOWED and state.registry is not void then
    wanted = cvar.variableValue(state.registry, "_windowed_mouse") != 0.0
    if not wanted then
      if state.windowedMouse then input.IN_DeactivateMouse(); input.IN_ShowMouse(); state.windowedMouse = false end if
    else
      state.windowedMouse = true
      if keys.destination() == keys.KEY_GAME and state.activeApp then input.IN_ActivateMouse(); input.IN_HideMouse()
      else input.IN_DeactivateMouse(); input.IN_ShowMouse()
      end if
    end if
  end if
  if state.fullSbarDraw then state.sbarChangedCount = state.sbarChangedCount + 1 end if
  return true
end function

function VID_Build15To8(state)
  value = 0
  while value < 32768
    red = ((value & 0x1f) << 3) + 4
    green = ((value & 0x03e0) >> 2) + 4
    blue = ((value & 0x7c00) >> 7) + 4
    best = 0
    bestDistance = 100000000
    color = 0
    while color < 256
      packed = state.table24[color]
      deltaRed = red - (packed & 255)
      deltaGreen = green - ((packed >> 8) & 255)
      deltaBlue = blue - ((packed >> 16) & 255)
      distance = deltaRed * deltaRed + deltaGreen * deltaGreen + deltaBlue * deltaBlue
      if distance < bestDistance then best = color; bestDistance = distance end if
      color = color + 1
    end while
    state.table15[value] = best
    value = value + 1
  end while
  return state.table15
end function

function VID_SetPalette(palette)
  state = VID_State()
  if palette is void or len(palette) < 768 then return error(3908, "VID_SetPalette: invalid palette") end if
  state.palette = bytes(768)
  state.table16 = []
  state.table24 = []
  index = 0
  while index < 256
    red = palette[index * 3]
    green = palette[index * 3 + 1]
    blue = palette[index * 3 + 2]
    state.palette[index * 3] = red
    state.palette[index * 3 + 1] = green
    state.palette[index * 3 + 2] = blue
    state.table16 = state.table16 + [((red >> 3) << 11) | ((green >> 2) << 5) | (blue >> 3)]
    state.table24 = state.table24 + [(255 << 24) | red | (green << 8) | (blue << 16)]
    index = index + 1
  end while
  state.table24[255] = state.table24[255] & 0xffffff
  VID_Build15To8(state)
  return true
end function

function VID_ShiftPalette(palette)
  // The MiniQuake source intentionally leaves SetDeviceGammaRamp commented out.
  return false
end function

function VID_SetDefaultMode()
  input.IN_DeactivateMouse()
  return true
end function

function VID_Shutdown()
  state = VID_State()
  if not state.initialized then return false end if
  state.canAltTab = false
  if state.createNative then
    win.destroy()
    win.restoreDisplayMode()
  end if
  AppActivate(false, false)
  state.initialized = false
  state.modeState = MS_UNINIT
  return true
end function

function bSetupPixelFormat()
  state = VID_State()
  if not state.createNative then return true end if
  return win.contextReady()
end function

function MapKey(key)
  scan = (key >> 16) & 255
  return input.quakeKeyForScanCode(scan)
end function

function ClearAllStates()
  // Queue the same synthetic key-up commands emitted by WinQuake before the
  // physical state tables are cleared. The host drains this queue into Cbuf.
  keys.Key_QueueReleaseAllCommands()
  input.IN_ClearDeviceStates()
  return true
end function

function AppActivate(active, minimized)
  state = VID_State()
  state.activeApp = active
  state.minimized = minimized
  if not active and not state.soundBlocked then
    if state.soundMixer is not void then sound.block(state.soundMixer) end if
    state.soundBlocked = true
  else if active and state.soundBlocked then
    if state.soundMixer is not void then sound.unblock(state.soundMixer) end if
    state.soundBlocked = false
  end if
  if state.createNative then win.activate(active, minimized) end if
  windowedMouse = false
  if state.registry is not void then windowedMouse = cvar.variableValue(state.registry, "_windowed_mouse") != 0.0 end if
  if active then
    if state.modeState == MS_FULLDIB then
      input.IN_ActivateMouse()
      input.IN_HideMouse()
      if state.canAltTab and state.wasSuspended then state.wasSuspended = false end if
    else if state.modeState == MS_WINDOWED and windowedMouse and keys.destination() == keys.KEY_GAME then
      input.IN_ActivateMouse()
      input.IN_HideMouse()
    end if
  else
    if state.modeState == MS_FULLDIB then
      input.IN_DeactivateMouse()
      input.IN_ShowMouse()
      if state.canAltTab then state.wasSuspended = true end if
    else if state.modeState == MS_WINDOWED and windowedMouse then
      input.IN_DeactivateMouse()
      input.IN_ShowMouse()
    end if
  end if
  return true
end function

function signedWord(value)
  result = value & 0xffff
  if result >= 0x8000 then result = result - 0x10000 end if
  return result
end function

function MainWndProc(message, wParam, lParam)
  state = VID_State()
  if message == 0x0003 then
    state.windowX = signedWord(lParam)
    state.windowY = signedWord(lParam >> 16)
    VID_UpdateWindowStatus()
    return ["move", state.windowX, state.windowY]
  end if
  if message == 0x0005 then
    state.minimized = wParam == 1
    if not state.minimized then state.windowWidth = lParam & 0xffff; state.windowHeight = (lParam >> 16) & 0xffff end if
    VID_UpdateWindowStatus()
    return ["size", state.windowWidth, state.windowHeight, state.minimized]
  end if
  if message == 0x0006 then
    active = (wParam & 0xffff) != 0
    minimized = ((wParam >> 16) & 0xffff) != 0
    AppActivate(active, minimized)
    ClearAllStates()
    return ["activate", active, minimized]
  end if
  if message == 0x0008 then return ["killfocus"] end if
  if message == 0x0100 or message == 0x0104 then return ["key", MapKey(lParam), true] end if
  if message == 0x0101 or message == 0x0105 then return ["key", MapKey(lParam), false] end if
  if message == 0x0106 then return ["syschar"] end if
  if message == 0x020a then
    delta = signedWord(wParam >> 16)
    if delta > 0 then return ["wheel", keys.K_MWHEELUP] end if
    return ["wheel", keys.K_MWHEELDOWN]
  end if
  if message == 0x0010 then return ["confirm_quit"] end if
  if message == 0x0002 then return ["destroy"] end if
  return ["default", message]
end function

function VID_NumModes()
  return len(VID_State().modes)
end function

function VID_GetModePtr(modeNumber)
  state = VID_State()
  if modeNumber >= 0 and modeNumber < len(state.modes) then return state.modes[modeNumber] end if
  return state.badMode
end function

function VID_GetModeDescription(modeNumber)
  state = VID_State()
  if modeNumber < 0 or modeNumber >= len(state.modes) then return "" end if
  if state.leaveCurrentMode then
    mode = state.modes[MODE_FULLSCREEN_DEFAULT]
    return "Desktop resolution (" + mode.width + "x" + mode.height + ")"
  end if
  return state.modes[modeNumber].description
end function

function VID_GetExtModeDescription(modeNumber)
  state = VID_State()
  if modeNumber < 0 or modeNumber >= len(state.modes) then return "" end if
  mode = state.modes[modeNumber]
  if mode.type == MS_FULLDIB then
    if state.leaveCurrentMode and modeNumber == state.currentMode then return "Desktop resolution (" + mode.width + "x" + mode.height + ")" end if
    return mode.description + " fullscreen"
  end if
  if state.modeState == MS_WINDOWED then return mode.description + " windowed" end if
  return "windowed"
end function

function VID_DescribeCurrentMode_f()
  state = VID_State()
  return VID_GetExtModeDescription(state.currentMode)
end function

function VID_NumModes_f()
  count = VID_NumModes()
  if count == 1 then return "1 video mode is available" end if
  return "" + count + " video modes are available"
end function

function VID_DescribeMode_f(arguments)
  if len(arguments) < 2 then return "" end if
  state = VID_State()
  previous = state.leaveCurrentMode
  state.leaveCurrentMode = false
  result = VID_GetExtModeDescription(common.atoi(arguments[1]))
  state.leaveCurrentMode = previous
  return result
end function

function VID_DescribeModes_f()
  state = VID_State()
  previous = state.leaveCurrentMode
  state.leaveCurrentMode = false
  result = []
  index = 1
  while index < len(state.modes)
    prefix = "" + index
    if index < 10 then prefix = " " + prefix end if
    result = result + [prefix + ": " + VID_GetExtModeDescription(index)]
    index = index + 1
  end while
  state.leaveCurrentMode = previous
  return result
end function

function VID_InitDIB(arguments)
  state = VID_State()
  width = common.integerOption(arguments, "-width", 640)
  if width < 320 then width = 320 end if
  height = common.integerOption(arguments, "-height", native.trunc(width * 240 / 320))
  if height < 240 then height = 240 end if
  mode = makeMode(MS_WINDOWED, width, height, 0, 0, 0)
  mode.modeNumber = MODE_WINDOWED
  state.modes = [mode]
  state.windowedDefault = MODE_WINDOWED
  return mode
end function

function VID_InitFullDIB(enumeratedModes, testNative, noAdjustAspect)
  state = VID_State()
  fullscreenModes = []
  for each item in enumeratedModes
    if len(item) >= 3 and item[2] >= 15 and item[0] <= 10000 and item[1] <= 10000 then
      accepted = true
      if len(item) >= 5 then accepted = item[4] end if
      if testNative then accepted = win.testDisplayMode(item[0], item[1], item[2], 0) end if
      if accepted then
        width = item[0]
        halfscreen = 0
        if not noAdjustAspect and width > item[1] * 2 then width = width >> 1; halfscreen = 1 end if
        candidate = makeMode(MS_FULLDIB, width, item[1], item[2], 0, halfscreen)
        if not VID_ModeExists(fullscreenModes, candidate) and len(fullscreenModes) < MAX_MODE_LIST - 1 then fullscreenModes = fullscreenModes + [candidate] end if
      end if
    end if
  end for
  if testNative then
    lowres = [[320, 200], [320, 240], [400, 300], [512, 384]]
    bpps = [16, 32, 24]
    for each bpp in bpps
      for each dimensions in lowres
        if len(fullscreenModes) < MAX_MODE_LIST - 1 and win.testDisplayMode(dimensions[0], dimensions[1], bpp, 0) then
          candidate = makeMode(MS_FULLDIB, dimensions[0], dimensions[1], bpp, 0, 0)
          if not VID_ModeExists(fullscreenModes, candidate) then fullscreenModes = fullscreenModes + [candidate] end if
        end if
      end for
    end for
  end if
  // EnumDisplaySettings order is observable through -mode and the vid_* mode
  // commands.  The original appends accepted modes without sorting.
  state.modes = [state.modes[0]] + fullscreenModes
  index = 0
  while index < len(state.modes)
    state.modes[index].modeNumber = index
    index = index + 1
  end while
  return len(fullscreenModes)
end function

function VID_Is8bit()
  return VID_State().is8bit
end function

function VID_Init8bitPalette()
  state = VID_State()
  disabled = false
  if state.arguments is not void then disabled = common.hasParm(state.arguments, "-no8bit") end if
  // No GL_EXT_shared_texture_palette entry point crosses the fixed-function
  // bridge. The reference also leaves this path disabled when unavailable.
  state.is8bit = false
  return not disabled and state.is8bit
end function

function Check_Gamma(palette)
  state = VID_State()
  gamma = 0.7
  if hasText(state.glRenderer, "Voodoo") or hasText(state.glVendor, "3Dfx") then gamma = 1.0 end if
  if state.arguments is not void and common.hasParm(state.arguments, "-gamma") then gamma = common.floatOption(state.arguments, "-gamma", gamma) end if
  state.gamma = gamma
  index = 0
  while index < 768
    fraction = (palette[index] + 1) / 256.0
    corrected = stdmath.pow(fraction, gamma) * 255.0 + 0.5
    if corrected < 0.0 then corrected = 0.0 end if
    if corrected > 255.0 then corrected = 255.0 end if
    palette[index] = native.trunc(corrected)
    index = index + 1
  end while
  return gamma
end function

function VID_BuildGammaRamp(gamma)
  ramp = bytes(1536)
  channel = 0
  while channel < 3
    index = 0
    while index < 256
      fraction = index / 255.0
      value = native.trunc(stdmath.pow(fraction, gamma) * 65535.0 + 0.5)
      if value < 0 then value = 0 end if
      if value > 65535 then value = 65535 end if
      offset = channel * 512 + index * 2
      ramp[offset] = value & 255
      ramp[offset + 1] = (value >> 8) & 255
      index = index + 1
    end while
    channel = channel + 1
  end while
  return ramp
end function

function VID_ApplyGammaRamp(gamma)
  state = VID_State()
  state.gammaWorks = win.setGammaRamp(VID_BuildGammaRamp(gamma))
  return state.gammaWorks
end function

function VID_WindowedRequested(arguments)
  return common.hasParm(arguments, "-window") or
    common.hasParm(arguments, "-windowed") or
    common.hasParm(arguments, "-startwindowed")
end function

function VID_FullscreenRequested(arguments)
  return common.hasParm(arguments, "-fullscreen") or
    common.hasParm(arguments, "-mode") or
    common.hasParm(arguments, "-current") or
    common.hasParm(arguments, "-bpp") or
    common.hasParm(arguments, "-force")
end function

function VID_FindRequestedMode(arguments)
  state = VID_State()
  if VID_WindowedRequested(arguments) or not VID_FullscreenRequested(arguments) then
    state.windowed = true
    return MODE_WINDOWED
  end if
  state.windowed = false
  if common.hasParm(arguments, "-mode") then
    requested = common.integerOption(arguments, "-mode", MODE_FULLSCREEN_DEFAULT)
    if requested > 0 and requested < len(state.modes) then return requested end if
    return NO_MODE
  end if
  if common.hasParm(arguments, "-current") then
    state.leaveCurrentMode = true
    if len(state.modes) > MODE_FULLSCREEN_DEFAULT then
      if state.desktopWidth > 0 and state.desktopHeight > 0 then
        state.modes[MODE_FULLSCREEN_DEFAULT].width = state.desktopWidth
        state.modes[MODE_FULLSCREEN_DEFAULT].height = state.desktopHeight
        state.modes[MODE_FULLSCREEN_DEFAULT].description = "" + state.desktopWidth + "x" + state.desktopHeight + "x" + state.modes[MODE_FULLSCREEN_DEFAULT].bpp
      end if
      return MODE_FULLSCREEN_DEFAULT
    end if
    return NO_MODE
  end if
  width = common.integerOption(arguments, "-width", 640)
  requestedHeight = common.integerOption(arguments, "-height", -1)
  explicitBpp = common.hasParm(arguments, "-bpp")
  requestedBpp = common.integerOption(arguments, "-bpp", 15)
  bppOrder = [requestedBpp]
  if not explicitBpp then bppOrder = [15, 16, 32, 24] end if
  for each bpp in bppOrder
    index = 1
    while index < len(state.modes)
      mode = state.modes[index]
      if mode.width == width and mode.bpp == bpp and (requestedHeight < 0 or mode.height == requestedHeight) then return index end if
      index = index + 1
    end while
  end for
  if common.hasParm(arguments, "-force") and len(state.modes) < MAX_MODE_LIST then
    height = requestedHeight
    if height < 1 then height = native.trunc(width * 3 / 4) end if
    forced = makeMode(MS_FULLDIB, width, height, requestedBpp, 0, 0)
    state.modes = state.modes + [forced]
    forced.modeNumber = len(state.modes) - 1
    return forced.modeNumber
  end if
  return NO_MODE
end function

function VID_Init(arguments, registry, palette, createNative)
  state = createVideoState()
  VID_UseState(state)
  state.arguments = arguments
  state.registry = registry
  state.createNative = createNative
  if createNative then
    state.desktopWidth = win.desktopWidth()
    state.desktopHeight = win.desktopHeight()
  end if
  VID_InitDIB(arguments)
  enumerated = []
  if createNative then enumerated = win.displayModes() end if
  VID_InitFullDIB(enumerated, createNative, common.hasParm(arguments, "-noadjustaspect"))
  selected = VID_FindRequestedMode(arguments)
  if selected == NO_MODE then return error(3909, "Specified video mode not available") end if
  state.defaultMode = selected
  state.conWidth = common.integerOption(arguments, "-conwidth", 640) & 0xfff8
  if state.conWidth < 320 then state.conWidth = 320 end if
  state.conHeight = native.trunc(state.conWidth * 3 / 4)
  if common.hasParm(arguments, "-conheight") then state.conHeight = common.integerOption(arguments, "-conheight", state.conHeight) end if
  if state.conHeight < 200 then state.conHeight = 200 end if
  state.initialized = true
  Check_Gamma(palette)
  setMode = try(VID_SetMode(selected, palette, createNative))
  if setMode is error then return setMode end if
  if createNative then
    if not bSetupPixelFormat() then return error(3910, "ChoosePixelFormat failed") end if
    initialized = try(GL_Init())
    if initialized is error then return initialized end if
  end if
  state.realMode = state.currentMode
  VID_Init8bitPalette()
  state.canAltTab = true
  if common.hasParm(arguments, "-fullsbar") then state.fullSbarDraw = true end if
  return state
end function

function VID_MenuDraw()
  state = VID_State()
  commands = [["picture", "gfx/vidmodes.lmp"], ["heading", "Fullscreen Modes (WIDTHxHEIGHTxBPP)"]]
  count = 0
  index = 1
  while index < len(state.modes) and count < MAX_MODEDESCS
    mode = state.modes[index]
    commands = commands + [["mode", index, mode.description, index == state.currentMode, count % VID_ROW_SIZE, native.trunc(count / VID_ROW_SIZE)]]
    count = count + 1
    index = index + 1
  end while
  commands = commands + [
    ["help", "Video modes must be set from the"],
    ["help", "command line with -width <width>"],
    ["help", "and -bpp <bits-per-pixel>"],
    ["help", "Select windowed mode with -window"],
  ]
  state.drawTrace = commands
  return commands
end function

function VID_MenuKey(key)
  if key == keys.K_ESCAPE then return "options" end if
  return "none"
end function

function VID_MenuDrawCallback()
  return VID_MenuDraw()
end function

function VID_MenuKeyCallback(key)
  return VID_MenuKey(key)
end function
