/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

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
import miniquake.byteio as bio
import miniquake.sound.mixer as sound
import miniquake.render.texture_upscale as textureUpscale
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

// Group the fields that describe one video mode.
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

// Track mutable video state across subsystem calls.
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
videoMenuSelection = NO_MODE
videoMenuDisplayFocus = false
videoMenuRendererFocus = false
videoMenuLightingFocus = false
videoMenuShadowFocus = false
videoMenuShadowQualityFocus = false
videoMenuTextureUpscaleFocus = false
rendererSelectionOverride = -1

// Apply the Quake-compatible vid renderer from name behavior.
function VID_RendererFromName(name)
  lowered = bio.lower(name)
  if lowered == "vulkan" or lowered == "vk" then return win.RENDER_VULKAN end if
  if lowered == "direct3d" or lowered == "direct3d9" or lowered == "direct3d 9" or lowered == "directx" or lowered == "d3d9" or lowered == "dx9" then return win.RENDER_DIRECT3D9 end if
  return win.RENDER_OPENGL
end function

// Apply the Quake-compatible vid renderer name behavior.
function VID_RendererName(backend)
  if backend == win.RENDER_VULKAN then return "VULKAN" end if
  if backend == win.RENDER_DIRECT3D9 then return "DIRECT3D 9" end if
  return "OPENGL"
end function

// Return the stable token written to config.cfg for a renderer backend.
function VID_RendererConfigName(backend)
  if backend == win.RENDER_VULKAN then return "vulkan" end if
  if backend == win.RENDER_DIRECT3D9 then return "direct3d9" end if
  return "opengl"
end function

// Apply the Quake-compatible vid command line renderer behavior.
function VID_CommandLineRenderer(arguments)
  if common.hasParm(arguments, "-vulkan") or common.hasParm(arguments, "-vk") then return win.RENDER_VULKAN end if
  if common.hasParm(arguments, "-directx") or common.hasParm(arguments, "-d3d9") then return win.RENDER_DIRECT3D9 end if
  if common.hasParm(arguments, "-opengl") then return win.RENDER_OPENGL end if
  named = common.parmValue(arguments, "-renderer", "")
  if named != "" then return VID_RendererFromName(named) end if
  return -1
end function

// Apply the Quake-compatible vid select configured renderer behavior.
function VID_SelectConfiguredRenderer(arguments, registry)
  global rendererSelectionOverride
  selected = rendererSelectionOverride
  rendererSelectionOverride = -1
  if selected < 0 then selected = VID_CommandLineRenderer(arguments) end if
  if selected < 0 and registry is not void and cvar.find(registry, "vid_renderer") is not void then selected = VID_RendererFromName(cvar.variableString(registry, "vid_renderer")) end if
  if selected < 0 then selected = win.RENDER_OPENGL end if
  if not win.rendererAvailable(selected) then return error(3916, VID_RendererName(selected) + " is not available") end if
  if not win.selectRenderer(selected) then return error(3917, "Could not select " + VID_RendererName(selected)) end if
  return selected
end function

// Create and initialize mode.
function makeMode(type, width, height, bpp, frequency, halfscreen)
  description = "" + width + "x" + height
  if type == MS_FULLDIB then description = description + "x" + bpp end if
  return VideoMode(type, width, height, 0, 1, type == MS_FULLDIB, bpp, halfscreen, frequency, description)
end function

// Create and initialize video state.
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

// Apply the Quake-compatible vid window title for fps behavior.
function inline VID_WindowTitleForFps(fps)
  safeFps = native.trunc(fps)
  if safeFps < 0 then safeFps = 0 end if
  if safeFps > 9999 then safeFps = 9999 end if
  return "MiniQuake - " + safeFps + " FPS"
end function

// Apply the Quake-compatible vid use state behavior.
function VID_UseState(state)
  global currentVideoState
  currentVideoState = state
  return state
end function

// Apply the Quake-compatible vid state behavior.
function VID_State()
  global currentVideoState
  if currentVideoState is void then currentVideoState = createVideoState() end if
  return currentVideoState
end function

// Apply the Quake-compatible vid set sound mixer behavior.
function VID_SetSoundMixer(mixerState)
  state = VID_State()
  state.soundMixer = mixerState
  return mixerState
end function

// Reconcile focus only after the sound device has been attached.  The video
// window is created before waveOut during Host_Init; if it loses focus during
// that interval, AppActivate records soundBlocked but cannot yet increment the
// mixer's block depth.  Attaching the mixer without this reconciliation leaves
// the state flag and the actual depth out of sync until another focus edge.
function VID_SynchronizeSoundFocus()
  state = VID_State()
  if state.soundMixer is void or not state.createNative then return false end if
  focused = win.hasFocus()
  minimized = win.minimized()
  actualBlocked = sound.blockDepth(state.soundMixer) > 0
  wantedBlocked = minimized or not focused
  if wantedBlocked and not actualBlocked then sound.block(state.soundMixer) end if
  if not wantedBlocked and actualBlocked then
    while sound.blockDepth(state.soundMixer) > 0
      sound.unblock(state.soundMixer)
    end while
  end if
  state.activeApp = focused
  state.minimized = minimized
  state.soundBlocked = wantedBlocked
  return true
end function

// Reconcile focus before every paint as well.  This deliberately compares the
// desired focus state with the mixer's real nesting depth rather than trusting
// soundBlocked: video starts before waveOut and renderer/display restarts also
// replace VideoState, so the two pieces of state can otherwise diverge.
function VID_SynchronizeSoundFocusIfNeeded()
  state = VID_State()
  if state.soundMixer is void or not state.createNative then return false end if
  focused = win.hasFocus()
  minimized = win.minimized()
  wantedBlocked = minimized or not focused
  actualBlocked = sound.blockDepth(state.soundMixer) > 0
  if wantedBlocked != actualBlocked or state.activeApp != focused or state.minimized != minimized or state.soundBlocked != wantedBlocked then
    return VID_SynchronizeSoundFocus()
  end if
  return false
end function

// Report whether text.
function hasText(value, needle)
  if value == "" or needle == "" then return false end if
  return string.indexOf(value, needle, 0) >= 0
end function

// Initialize state for starts with ignore case.
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

// Apply the Quake-compatible vid handle pause behavior.
function VID_HandlePause(pause)
  state = VID_State()
  state.paused = pause
  return true
end function

// Apply the Quake-compatible vid force lock state behavior.
function VID_ForceLockState(lockState)
  state = VID_State()
  state.forceLock = lockState
  return true
end function

// Apply the Quake-compatible vid lock buffer behavior.
function VID_LockBuffer()
  return true
end function

// Apply the Quake-compatible vid unlock buffer behavior.
function VID_UnlockBuffer()
  return true
end function

// Apply the Quake-compatible vid force unlocked and return state behavior.
function VID_ForceUnlockedAndReturnState()
  return 0
end function

// Mirror Quake's D_BeginDirectRect routine and its observable state changes.
function D_BeginDirectRect(x, y, bitmap, width, height)
  return false
end function

// Mirror Quake's D_EndDirectRect routine and its observable state changes.
function D_EndDirectRect(x, y, width, height)
  return false
end function

// Provide center window behavior for the active subsystem.
function CenterWindow(width, height, screenWidth, screenHeight, leftTopJustify)
  centerX = native.trunc((screenWidth - width) / 2)
  centerY = native.trunc((screenHeight - height) / 2)
  if centerX > centerY * 2 then centerX = centerX >> 1 end if
  if centerX < 0 then centerX = 0 end if
  if centerY < 0 then centerY = 0 end if
  return [centerX, centerY]
end function

// Apply the Quake-compatible vid mode less behavior.
function VID_ModeLess(left, right)
  if left.width != right.width then return left.width < right.width end if
  if left.height != right.height then return left.height < right.height end if
  if left.bpp != right.bpp then return left.bpp < right.bpp end if
  return left.frequency < right.frequency
end function

// Apply the Quake-compatible vid sort modes behavior.
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

// Apply the Quake-compatible vid mode exists behavior.
function VID_ModeExists(modes, candidate)
  for each existing in modes
    // MiniQuake's vmode_t has no refresh-rate field. EnumDisplaySettings can
    // report the same width/height/depth several times, but the original mode
    // list collapses every such refresh variant into one entry.
    if existing.width == candidate.width and existing.height == candidate.height and existing.bpp == candidate.bpp then return true end if
  end for
  return false
end function

// Apply the Quake-compatible vid set windowed mode behavior.
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

// Apply the Quake-compatible vid set full dibmode behavior.
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

// Apply the Quake-compatible vid set mode behavior.
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

// Apply the Quake-compatible vid update window status behavior.
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

// Validate texture extensions and report any incompatibility.
function CheckTextureExtensions()
  state = VID_State()
  // OpenGL 1.1 exposes core texture objects even when the EXT spelling is not
  // advertised, exactly matching the source's opengl32.dll fallback.
  state.textureObjects = true
  return true
end function

// Validate array extensions and report any incompatibility.
function CheckArrayExtensions()
  state = VID_State()
  state.arrayExtension = hasText(state.glExtensions, "GL_EXT_vertex_array")
  if not state.arrayExtension then return error(3911, "Vertex array extension not present") end if
  return state.arrayExtension
end function

// Validate multi texture extensions and report any incompatibility.
function CheckMultiTextureExtensions()
  state = VID_State()
  disabled = false
  if state.arguments is not void then disabled = common.hasParm(state.arguments, "-nomtex") end if
  // The reference used SGIS_multitexture. Modern ICDs expose the equivalent
  // fixed-function texture units through core/ARB entry points instead.
  state.multitexture = gl.multitextureAvailable() and not disabled
  return state.multitexture
end function

// Validate multi texture extensions non windows and report any incompatibility.
function CheckMultiTextureExtensions_NonWindows()
  state = VID_State()
  state.multitexture = true
  return true
end function

// Mirror Quake's GL_Init routine and its observable state changes.
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

// Mirror Quake's GL_BeginRendering routine and its observable state changes.
function GL_BeginRendering()
  state = VID_State()
  width = state.windowWidth
  height = state.windowHeight
  if state.createNative and win.contextReady() then width = win.width(); height = win.height() end if
  return [0, 0, width, height]
end function

// Mirror Quake's GL_EndRendering routine and its observable state changes.
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

// Apply the Quake-compatible vid build15 to8 behavior.
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

// Report whether the complete lookup-table palette is already installed.
// SCR_BringDownConsole restores the base palette during every level change;
// rebuilding the 8.4-million-comparison 15-to-8 table for identical bytes is
// observable only as a loading hitch, never as a changed rendering result.
function VID_PaletteMatches(state, palette)
  if len(state.palette) < 768 or len(state.table16) != 256 or len(state.table24) != 256 then return false end if
  index = 0
  while index < 768
    if state.palette[index] != palette[index] then return false end if
    index = index + 1
  end while
  return true
end function

// Apply the Quake-compatible vid set palette behavior.
function VID_SetPalette(palette)
  state = VID_State()
  if palette is void or len(palette) < 768 then return error(3908, "VID_SetPalette: invalid palette") end if
  if VID_PaletteMatches(state, palette) then return true end if
  state.palette = bytes(768)
  // These tables have fixed source-defined sizes. Allocate them once instead
  // of growing 256 intermediate MiniLang arrays through concatenation.
  state.table16 = array(256, 0)
  state.table24 = array(256, 0)
  index = 0
  while index < 256
    red = palette[index * 3]
    green = palette[index * 3 + 1]
    blue = palette[index * 3 + 2]
    state.palette[index * 3] = red
    state.palette[index * 3 + 1] = green
    state.palette[index * 3 + 2] = blue
    state.table16[index] = ((red >> 3) << 11) | ((green >> 2) << 5) | (blue >> 3)
    state.table24[index] = (255 << 24) | red | (green << 8) | (blue << 16)
    index = index + 1
  end while
  state.table24[255] = state.table24[255] & 0xffffff
  VID_Build15To8(state)
  return true
end function

// Apply the Quake-compatible vid shift palette behavior.
function VID_ShiftPalette(palette)
  // The MiniQuake source intentionally leaves SetDeviceGammaRamp commented out.
  return false
end function

// Apply the Quake-compatible vid set default mode behavior.
function VID_SetDefaultMode()
  input.IN_DeactivateMouse()
  return true
end function

// Apply the Quake-compatible vid shutdown behavior.
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

// Provide b setup pixel format behavior for the active subsystem.
function bSetupPixelFormat()
  state = VID_State()
  if not state.createNative then return true end if
  return win.contextReady()
end function

// Provide map key behavior for the active subsystem.
function MapKey(key)
  scan = (key >> 16) & 255
  return input.quakeKeyForScanCode(scan)
end function

// Update module state for all states.
function ClearAllStates()
  // Queue the same synthetic key-up commands emitted by WinQuake before the
  // physical state tables are cleared. The host drains this queue into Cbuf.
  keys.Key_QueueReleaseAllCommands()
  // A focus or renderer-mode transition may discard the matching native
  // WM_KEYUP.  Clear the ordered event mirror together with the device state
  // so live polling cannot resurrect a movement/jump key after activation.
  input.clearEventKeyStates()
  input.IN_ClearDeviceStates()
  return true
end function

// Provide app activate behavior for the active subsystem.
function AppActivate(active, minimized)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  state = VID_State()
  state.activeApp = active
  state.minimized = minimized
  wantedBlocked = minimized or not active
  actualBlocked = false
  if state.soundMixer is not void then actualBlocked = sound.blockDepth(state.soundMixer) > 0 end if
  if wantedBlocked and not actualBlocked then
    if state.soundMixer is not void then sound.block(state.soundMixer) end if
  else if not wantedBlocked and actualBlocked then
    if state.soundMixer is not void then
      while sound.blockDepth(state.soundMixer) > 0
        sound.unblock(state.soundMixer)
      end while
    end if
  end if
  state.soundBlocked = wantedBlocked
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

// Provide signed word behavior for the active subsystem.
function signedWord(value)
  result = value & 0xffff
  if result >= 0x8000 then result = result - 0x10000 end if
  return result
end function

// Provide main wnd proc behavior for the active subsystem.
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

// Apply the Quake-compatible vid num modes behavior.
function VID_NumModes()
  return len(VID_State().modes)
end function

// Apply the Quake-compatible vid get mode ptr behavior.
function VID_GetModePtr(modeNumber)
  state = VID_State()
  if modeNumber >= 0 and modeNumber < len(state.modes) then return state.modes[modeNumber] end if
  return state.badMode
end function

// Apply the Quake-compatible vid get mode description behavior.
function VID_GetModeDescription(modeNumber)
  state = VID_State()
  if modeNumber < 0 or modeNumber >= len(state.modes) then return "" end if
  if state.leaveCurrentMode then
    mode = state.modes[MODE_FULLSCREEN_DEFAULT]
    return "Desktop resolution (" + mode.width + "x" + mode.height + ")"
  end if
  return state.modes[modeNumber].description
end function

// Apply the Quake-compatible vid get ext mode description behavior.
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

// Apply the Quake-compatible vid describe current mode f behavior.
function VID_DescribeCurrentMode_f()
  state = VID_State()
  return VID_GetExtModeDescription(state.currentMode)
end function

// Apply the Quake-compatible vid num modes f behavior.
function VID_NumModes_f()
  count = VID_NumModes()
  if count == 1 then return "1 video mode is available" end if
  return "" + count + " video modes are available"
end function

// Apply the Quake-compatible vid describe mode f behavior.
function VID_DescribeMode_f(arguments)
  if len(arguments) < 2 then return "" end if
  state = VID_State()
  previous = state.leaveCurrentMode
  state.leaveCurrentMode = false
  result = VID_GetExtModeDescription(common.atoi(arguments[1]))
  state.leaveCurrentMode = previous
  return result
end function

// Apply the Quake-compatible vid describe modes f behavior.
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

// Apply the Quake-compatible vid init dib behavior.
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

// Apply the Quake-compatible vid init full dib behavior.
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

// Apply the Quake-compatible vid is8bit behavior.
function VID_Is8bit()
  return VID_State().is8bit
end function

// Apply the Quake-compatible vid init8bit palette behavior.
function VID_Init8bitPalette()
  state = VID_State()
  disabled = false
  if state.arguments is not void then disabled = common.hasParm(state.arguments, "-no8bit") end if
  // No GL_EXT_shared_texture_palette entry point crosses the fixed-function
  // bridge. The reference also leaves this path disabled when unavailable.
  state.is8bit = false
  return not disabled and state.is8bit
end function

// Validate gamma and report any incompatibility.
function Check_Gamma(palette)
  state = VID_State()
  // The shipped Windows GLQUAKE.EXE is the visual oracle. Its captured output
  // uses the unmodified palette unless -gamma is explicitly supplied; using
  // the source comment's 0.7 fallback made MiniQuake's world textures about
  // 50 percent brighter in matched retail frames. Keep -gamma available for
  // users who prefer that historical source-tree fallback.
  gamma = 1.0
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

// Apply the Quake-compatible vid build gamma ramp behavior.
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

// Apply the Quake-compatible vid apply gamma ramp behavior.
function VID_ApplyGammaRamp(gamma)
  state = VID_State()
  state.gammaWorks = win.setGammaRamp(VID_BuildGammaRamp(gamma))
  return state.gammaWorks
end function

// Apply the Quake-compatible vid windowed requested behavior.
function VID_WindowedRequested(arguments)
  return common.hasParm(arguments, "-window") or
    common.hasParm(arguments, "-windowed") or
    common.hasParm(arguments, "-startwindowed")
end function

// Apply the Quake-compatible vid fullscreen requested behavior.
function VID_FullscreenRequested(arguments)
  return common.hasParm(arguments, "-fullscreen") or
    common.hasParm(arguments, "-mode") or
    common.hasParm(arguments, "-current") or
    common.hasParm(arguments, "-bpp") or
    common.hasParm(arguments, "-force")
end function

// Apply the Quake-compatible vid find requested mode behavior.
function VID_FindRequestedMode(arguments)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
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

// Apply the Quake-compatible vid init behavior.
function VID_Init(arguments, registry, palette, createNative)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if createNative then
    selectedRenderer = try(VID_SelectConfiguredRenderer(arguments, registry))
    if selectedRenderer is error then return selectedRenderer end if
  end if
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

// Apply the Quake-compatible vid restart renderer behavior.
function VID_RestartRenderer(backend)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global rendererSelectionOverride
  state = VID_State()
  if backend == win.renderer() then
    if state.registry is not void and cvar.find(state.registry, "vid_renderer") is not void then cvar.set(state.registry, "vid_renderer", VID_RendererConfigName(backend)) end if
    state.lastModeMessage = VID_RendererName(backend) + " renderer active."
    return true
  end if
  if backend != win.RENDER_OPENGL and backend != win.RENDER_DIRECT3D9 and backend != win.RENDER_VULKAN then return error(3918, "Unknown renderer") end if
  if not win.rendererAvailable(backend) then return error(3919, VID_RendererName(backend) + " is not available") end if
  oldBackend = win.renderer()
  oldWidth = state.windowWidth
  oldHeight = state.windowHeight
  oldFullscreen = state.modeState == MS_FULLDIB
  oldPalette = state.palette
  oldArguments = state.arguments
  oldRegistry = state.registry
  oldCreateNative = state.createNative
  oldMixer = state.soundMixer
  VID_Shutdown()
  rendererSelectionOverride = backend
  restarted = VID_Init(oldArguments, oldRegistry, oldPalette, oldCreateNative)
  if restarted is error then
    rendererSelectionOverride = oldBackend
    recovered = VID_Init(oldArguments, oldRegistry, oldPalette, oldCreateNative)
    if recovered is error then return error(3920, "Renderer switch and rollback failed: " + restarted.message) end if
    VID_State().soundMixer = oldMixer
    VID_State().soundBlocked = true
    AppActivate(true, false)
    return restarted
  end if
  state = VID_State()
  state.soundMixer = oldMixer
  state.soundBlocked = true
  modeNumber = NO_MODE
  index = 1
  while index < len(state.modes)
    mode = state.modes[index]
    if mode.width == oldWidth and mode.height == oldHeight and modeNumber == NO_MODE then modeNumber = index end if
    index = index + 1
  end while
  if modeNumber != NO_MODE then
    applied = VID_ApplyDisplayMode(modeNumber, oldFullscreen)
    if applied is error then state.lastModeMessage = applied.message end if
  end if
  if oldRegistry is not void and cvar.find(oldRegistry, "vid_renderer") is not void then cvar.set(oldRegistry, "vid_renderer", VID_RendererConfigName(backend)) end if
  AppActivate(true, false)
  state.lastModeMessage = VID_RendererName(backend) + " renderer active."
  return true
end function

// Apply the Quake-compatible vid apply configured renderer behavior.
function VID_ApplyConfiguredRenderer()
  state = VID_State()
  if state.registry is void then return false end if
  if VID_CommandLineRenderer(state.arguments) >= 0 then return false end if
  target = VID_RendererFromName(cvar.variableString(state.registry, "vid_renderer"))
  if target == win.renderer() then return false end if
  applied = VID_RestartRenderer(target)
  if applied is error then state.lastModeMessage = applied.message; return false end if
  return true
end function

// Apply the Quake-compatible vid menu mode count behavior.
function VID_MenuModeCount()
  count = len(VID_State().modes) - 1
  if count < 0 then count = 0 end if
  if count > MAX_MODEDESCS then count = MAX_MODEDESCS end if
  return count
end function

// Apply the Quake-compatible vid menu reset behavior.
function VID_MenuReset()
  global videoMenuSelection, videoMenuDisplayFocus, videoMenuRendererFocus, videoMenuLightingFocus, videoMenuShadowFocus, videoMenuShadowQualityFocus, videoMenuTextureUpscaleFocus
  state = VID_State()
  // The original video menu opens on the active resolution.  Display mode and
  // renderer are separate entries above the grid and are reached with UP.
  // Starting on DISPLAY made the first LEFT/RIGHT press toggle fullscreen even
  // though the player had opened the menu to choose a resolution.
  videoMenuDisplayFocus = false
  videoMenuRendererFocus = false
  videoMenuLightingFocus = false
  videoMenuShadowFocus = false
  videoMenuShadowQualityFocus = false
  videoMenuTextureUpscaleFocus = false
  count = VID_MenuModeCount()
  if count == 0 then videoMenuSelection = NO_MODE; return videoMenuSelection end if
  selected = state.currentMode
  if selected < 1 or selected > count then
    selected = 1
    currentWidth = state.windowWidth
    currentHeight = state.windowHeight
    if state.createNative and win.contextReady() then
      currentWidth = win.width()
      currentHeight = win.height()
    end if
    index = 1
    while index <= count
      mode = state.modes[index]
      if mode.width == currentWidth and mode.height == currentHeight then selected = index end if
      index = index + 1
    end while
  end if
  videoMenuSelection = selected
  return videoMenuSelection
end function

// Apply the Quake-compatible vid menu selection behavior.
function VID_MenuSelection()
  global videoMenuSelection
  count = VID_MenuModeCount()
  if count == 0 then return NO_MODE end if
  if videoMenuSelection < 1 or videoMenuSelection > count then return VID_MenuReset() end if
  return videoMenuSelection
end function

// Apply the Quake-compatible vid menu move behavior.
function VID_MenuMove(delta)
  global videoMenuSelection
  count = VID_MenuModeCount()
  if count == 0 then videoMenuSelection = NO_MODE; return videoMenuSelection end if
  selected = VID_MenuSelection() - 1 + delta
  while selected < 0
    selected = selected + count
  end while
  while selected >= count
    selected = selected - count
  end while
  videoMenuSelection = selected + 1
  return videoMenuSelection
end function

// Apply the Quake-compatible vid menu display focused behavior.
function VID_MenuDisplayFocused()
  global videoMenuDisplayFocus
  return videoMenuDisplayFocus
end function

// Apply the Quake-compatible vid menu renderer focused behavior.
function VID_MenuRendererFocused()
  global videoMenuRendererFocus
  return videoMenuRendererFocus
end function

// Report whether the enhanced-lighting row owns keyboard focus.
function VID_MenuLightingFocused()
  global videoMenuLightingFocus
  return videoMenuLightingFocus
end function

// Report whether the shadow row owns keyboard focus.
function VID_MenuShadowFocused()
  global videoMenuShadowFocus
  return videoMenuShadowFocus
end function

// Report whether the shadow-quality row owns keyboard focus.
function VID_MenuShadowQualityFocused()
  global videoMenuShadowQualityFocus
  return videoMenuShadowQualityFocus
end function

// Report whether the load-time texture-upscaling row owns keyboard focus.
function VID_MenuTextureUpscaleFocused()
  global videoMenuTextureUpscaleFocus
  return videoMenuTextureUpscaleFocus
end function

// Toggle the archived classic/enhanced renderer policy without changing maps.
function VID_ToggleEnhancedLighting()
  state = VID_State()
  if state.registry is void or cvar.find(state.registry, "r_lighting") is void then return false end if
  enable = cvar.variableValue(state.registry, "r_lighting") == 0.0
  if enable and not gl.enhancedAvailable() then
    state.lastModeMessage = "Enhanced lighting is unavailable on this renderer."
    return false
  end if
  value = 0.0
  name = "CLASSIC"
  if enable then value = 1.0; name = "ENHANCED" end if
  cvar.setValue(state.registry, "r_lighting", value)
  state.lastModeMessage = "LIGHTING " + name + " applied."
  return true
end function

// Toggle archived dynamic entity shadows used by enhanced rendering.
function VID_ToggleEnhancedShadows()
  state = VID_State()
  if state.registry is void or cvar.find(state.registry, "r_shadows") is void then return false end if
  enabled = cvar.variableValue(state.registry, "r_shadows") == 0.0
  value = 0.0
  name = "OFF"
  if enabled then value = 1.0; name = "ON" end if
  cvar.setValue(state.registry, "r_shadows", value)
  state.lastModeMessage = "SHADOWS " + name + " applied."
  return true
end function

// Cycle the archived soft-shadow sampling level in the requested direction.
function VID_AdjustEnhancedShadowQuality(direction)
  state = VID_State()
  if state.registry is void or cvar.find(state.registry, "r_shadowquality") is void then return false end if
  value = native.trunc(cvar.variableValue(state.registry, "r_shadowquality"))
  if direction < 0 then value = value - 1 else value = value + 1 end if
  if value < 0 then value = 2 end if
  if value > 2 then value = 0 end if
  cvar.setValue(state.registry, "r_shadowquality", value)
  name = ["LOW", "MEDIUM", "HIGH"][value]
  state.lastModeMessage = "SHADOW QUALITY " + name + " applied."
  return true
end function

// Cycle the archived load-time texture-upscaling algorithm.
function VID_AdjustTextureUpscale(direction)
  state = VID_State()
  if state.registry is void or cvar.find(state.registry, "r_textureupscale") is void then return false end if
  previous = textureUpscale.clampMode(cvar.variableValue(state.registry, "r_textureupscale"))
  value = previous
  if direction < 0 then value = value - 1 else value = value + 1 end if
  if value < 0 then value = textureUpscale.UPSCALE_MODE_COUNT - 1 end if
  if value >= textureUpscale.UPSCALE_MODE_COUNT then value = 0 end if
  cvar.setValue(state.registry, "r_textureupscale", value)
  state.lastModeMessage = "TEXTURE UPSCALING " + textureUpscale.modeName(value) + " selected."
  return [previous, value]
end function

// Apply the Quake-compatible vid save resolution cvars behavior.
function VID_SaveResolutionCvars(state, width, height, bpp)
  if state.registry is void then return false end if
  if cvar.find(state.registry, "vid_width") is not void then cvar.setValue(state.registry, "vid_width", width) end if
  if cvar.find(state.registry, "vid_height") is not void then cvar.setValue(state.registry, "vid_height", height) end if
  if cvar.find(state.registry, "vid_bpp") is not void then cvar.setValue(state.registry, "vid_bpp", bpp) end if
  if cvar.find(state.registry, "vid_mode") is not void then cvar.setValue(state.registry, "vid_mode", state.currentMode) end if
  if cvar.find(state.registry, "vid_fullscreen") is not void then
    fullscreenValue = 0.0
    if state.modeState == MS_FULLDIB then fullscreenValue = 1.0 end if
    cvar.setValue(state.registry, "vid_fullscreen", fullscreenValue)
  end if
  return true
end function

// Synchronize the live window, fullscreen and renderer state into archived
// cvars immediately before config.cfg is written.  This also captures a window
// resized by dragging its frame rather than only changes made in the menu.
function VID_SaveCurrentConfigurationCvars()
  state = VID_State()
  if state.registry is void or not state.initialized then return false end if
  VID_UpdateWindowStatus()
  bpp = native.trunc(cvar.variableValue(state.registry, "vid_bpp"))
  if state.modeState == MS_FULLDIB and state.currentMode >= 1 and state.currentMode < len(state.modes) then
    bpp = state.modes[state.currentMode].bpp
  end if
  VID_SaveResolutionCvars(state, state.windowWidth, state.windowHeight, bpp)
  if cvar.find(state.registry, "vid_renderer") is not void then cvar.set(state.registry, "vid_renderer", VID_RendererConfigName(win.renderer())) end if
  return true
end function

// Apply the Quake-compatible vid restore native mode behavior.
function VID_RestoreNativeMode(state, wasFullscreen, previousWidth, previousHeight, previousBpp, previousFrequency, previousHalfscreen)
  if not state.createNative then return true end if
  if wasFullscreen then
    win.configureDisplayMode(previousWidth << previousHalfscreen, previousHeight, previousBpp, previousFrequency, true, false)
  else
    win.configureDisplayMode(previousWidth, previousHeight, 0, 0, false, false)
  end if
  return win.resizeClient(previousWidth, previousHeight)
end function

// Change resolution and presentation style on the existing HWND/HDC/WGL
// context.  Keeping the context alive is essential: all map textures, display
// lists and renderer caches remain valid across the menu operation.
function VID_ApplyDisplayMode(modeNumber, fullscreen)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  state = VID_State()
  if modeNumber < 1 or modeNumber >= len(state.modes) then return error(3912, "Video resolution is unavailable") end if
  mode = state.modes[modeNumber]
  previousFullscreen = state.modeState == MS_FULLDIB
  previousWidth = state.windowWidth
  previousHeight = state.windowHeight
  previousBpp = 0
  previousFrequency = 0
  previousHalfscreen = 0
  if previousFullscreen and state.currentMode >= 1 and state.currentMode < len(state.modes) then
    previousMode = state.modes[state.currentMode]
    previousBpp = previousMode.bpp
    previousFrequency = previousMode.frequency
    previousHalfscreen = previousMode.halfscreen
  end if

  if state.createNative then
    physicalWidth = mode.width << mode.halfscreen
    configured = false
    if fullscreen then configured = win.configureDisplayMode(physicalWidth, mode.height, mode.bpp, mode.frequency, true, false)
    else configured = win.configureDisplayMode(mode.width, mode.height, 0, 0, false, false)
    end if
    if not configured then
      return error(3913, "Fullscreen resolution is unavailable")
    end if
    if not win.resizeClient(mode.width, mode.height) then
      VID_RestoreNativeMode(state, previousFullscreen, previousWidth, previousHeight, previousBpp, previousFrequency, previousHalfscreen)
      return error(3914, "Display mode switch failed")
    end if
  end if

  state.dibWidth = mode.width
  state.dibHeight = mode.height
  state.windowWidth = mode.width
  state.windowHeight = mode.height
  state.width = mode.width
  state.height = mode.height
  if fullscreen then
    state.modeState = MS_FULLDIB
    state.currentMode = modeNumber
    state.realMode = modeNumber
    state.windowed = false
  else
    state.modeState = MS_WINDOWED
    state.modes[MODE_WINDOWED].width = mode.width
    state.modes[MODE_WINDOWED].height = mode.height
    state.modes[MODE_WINDOWED].description = "" + mode.width + "x" + mode.height
    state.currentMode = MODE_WINDOWED
    state.realMode = MODE_WINDOWED
    state.windowed = true
  end if
  state.recalcRefdef = true
  VID_UpdateWindowStatus()
  VID_SaveResolutionCvars(state, mode.width, mode.height, mode.bpp)
  ClearAllStates()
  modeName = "WINDOWED"
  if fullscreen then modeName = "FULLSCREEN" end if
  state.lastModeMessage = modeName + " " + mode.width + "x" + mode.height + " applied."
  return true
end function

// Apply the Quake-compatible vid apply resolution behavior.
function VID_ApplyResolution(modeNumber)
  return VID_ApplyDisplayMode(modeNumber, VID_State().modeState == MS_FULLDIB)
end function

// Apply the Quake-compatible vid toggle fullscreen behavior.
function VID_ToggleFullscreen()
  selected = VID_MenuSelection()
  if selected == NO_MODE then return error(3915, "No fullscreen resolution is available") end if
  return VID_ApplyDisplayMode(selected, VID_State().modeState != MS_FULLDIB)
end function

// config.cfg is executed after VID_Init.  Apply a resolution previously chosen
// in the menu once the archived cvars have been read, unless command-line video
// arguments explicitly override it.
function VID_ApplyConfiguredResolution()
  state = VID_State()
  if state.registry is void then return false end if
  if cvar.find(state.registry, "vid_width") is void or cvar.find(state.registry, "vid_height") is void then return false end if
  if state.arguments is not void then
    commandLineOverride = common.hasParm(state.arguments, "-width") or common.hasParm(state.arguments, "-height")
    commandLineOverride = commandLineOverride or common.hasParm(state.arguments, "-mode") or common.hasParm(state.arguments, "-current")
    commandLineOverride = commandLineOverride or common.hasParm(state.arguments, "-bpp") or common.hasParm(state.arguments, "-force")
    commandLineOverride = commandLineOverride or VID_WindowedRequested(state.arguments) or common.hasParm(state.arguments, "-fullscreen")
    if commandLineOverride then
      currentBpp = 0
      if state.currentMode >= 1 and state.currentMode < len(state.modes) then currentBpp = state.modes[state.currentMode].bpp end if
      VID_SaveResolutionCvars(state, state.windowWidth, state.windowHeight, currentBpp)
      return false
    end if
  end if
  wantedWidth = native.trunc(cvar.variableValue(state.registry, "vid_width"))
  wantedHeight = native.trunc(cvar.variableValue(state.registry, "vid_height"))
  wantedBpp = native.trunc(cvar.variableValue(state.registry, "vid_bpp"))
  wantedFullscreen = false
  if cvar.find(state.registry, "vid_fullscreen") is not void then wantedFullscreen = cvar.variableValue(state.registry, "vid_fullscreen") != 0.0 end if
  if wantedWidth < 320 or wantedHeight < 200 then return false end if
  index = 1
  while index < len(state.modes)
    mode = state.modes[index]
    if mode.width == wantedWidth and mode.height == wantedHeight and (wantedBpp <= 0 or mode.bpp == wantedBpp) then
      applied = try(VID_ApplyDisplayMode(index, wantedFullscreen))
      if applied is error then state.lastModeMessage = applied.message; return false end if
      return true
    end if
    index = index + 1
  end while
  // If a saved color depth is no longer enumerated, width and height remain a
  // safe fallback using the first currently available depth.
  if wantedBpp > 0 then
    index = 1
    while index < len(state.modes)
      mode = state.modes[index]
      if mode.width == wantedWidth and mode.height == wantedHeight then
        applied = try(VID_ApplyDisplayMode(index, wantedFullscreen))
        if applied is error then state.lastModeMessage = applied.message; return false end if
        return true
      end if
      index = index + 1
    end while
  end if
  state.lastModeMessage = "Saved resolution " + wantedWidth + "x" + wantedHeight + " is unavailable."
  return false
end function

// Apply the Quake-compatible vid menu draw behavior.
function VID_MenuDraw()
  state = VID_State()
  // Assemble fixed renderer rows first, then append the independently
  // navigable resolution grid and its help text.
  selection = VID_MenuSelection()
  modeName = "WINDOWED"
  if state.modeState == MS_FULLDIB then modeName = "FULLSCREEN" end if
  lightingName = "CLASSIC"
  shadowsName = "OFF"
  shadowQualityName = "MEDIUM"
  textureUpscaleName = "OFF"
  if state.registry is not void then
    if cvar.variableValue(state.registry, "r_lighting") != 0.0 then lightingName = "ENHANCED" end if
    if cvar.variableValue(state.registry, "r_shadows") != 0.0 then shadowsName = "ON" end if
    shadowQuality = native.trunc(cvar.variableValue(state.registry, "r_shadowquality"))
    if shadowQuality < 0 then shadowQuality = 0 end if
    if shadowQuality > 2 then shadowQuality = 2 end if
    shadowQualityName = ["LOW", "MEDIUM", "HIGH"][shadowQuality]
    if cvar.find(state.registry, "r_textureupscale") is not void then
      textureUpscaleName = textureUpscale.modeName(cvar.variableValue(state.registry, "r_textureupscale"))
    end if
  end if
  commands = [
    ["picture", "gfx/vidmodes.lmp"],
    ["heading", "Video Mode"],
    ["lighting", lightingName, VID_MenuLightingFocused()],
    ["shadows", shadowsName, VID_MenuShadowFocused()],
    ["shadow_quality", shadowQualityName, VID_MenuShadowQualityFocused()],
    ["texture_upscale", textureUpscaleName, VID_MenuTextureUpscaleFocused()],
    ["renderer", VID_RendererName(win.renderer()), VID_MenuRendererFocused()],
    ["display", modeName, VID_MenuDisplayFocused()],
  ]
  count = 0
  index = 1
  while index < len(state.modes) and count < MAX_MODEDESCS
    mode = state.modes[index]
    current = index == state.currentMode
    if state.modeState == MS_WINDOWED and mode.width == state.windowWidth and mode.height == state.windowHeight then current = true end if
    commands = commands + [["mode", index, mode.description, current, count % VID_ROW_SIZE, native.trunc(count / VID_ROW_SIZE), index == selection and not VID_MenuDisplayFocused() and not VID_MenuRendererFocused() and not VID_MenuLightingFocused() and not VID_MenuShadowFocused() and not VID_MenuShadowQualityFocused() and not VID_MenuTextureUpscaleFocused()]]
    count = count + 1
    index = index + 1
  end while
  commands = commands + [
    ["help", "LEFT/RIGHT select a resolution"],
    ["help", "UP reaches display and lighting"],
    ["help", "ENTER applies the selected setting"],
  ]
  state.drawTrace = commands
  return commands
end function

// Apply the Quake-compatible vid menu key behavior.
function VID_MenuKey(key)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global videoMenuDisplayFocus, videoMenuRendererFocus, videoMenuLightingFocus, videoMenuShadowFocus, videoMenuShadowQualityFocus, videoMenuTextureUpscaleFocus
  if key == keys.K_ESCAPE then return "options" end if
  if videoMenuLightingFocus then
    if key == keys.K_DOWNARROW then videoMenuLightingFocus = false; videoMenuShadowFocus = true; return "move" end if
    if key == keys.K_UPARROW then videoMenuLightingFocus = false; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      if VID_ToggleEnhancedLighting() then return "lighting_applied" end if
      return "lighting_error"
    end if
    return "none"
  end if
  if videoMenuShadowFocus then
    if key == keys.K_DOWNARROW then videoMenuShadowFocus = false; videoMenuShadowQualityFocus = true; return "move" end if
    if key == keys.K_UPARROW then videoMenuShadowFocus = false; videoMenuLightingFocus = true; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      if VID_ToggleEnhancedShadows() then return "lighting_applied" end if
      return "lighting_error"
    end if
    return "none"
  end if
  if videoMenuShadowQualityFocus then
    if key == keys.K_DOWNARROW then videoMenuShadowQualityFocus = false; videoMenuTextureUpscaleFocus = true; return "move" end if
    if key == keys.K_UPARROW then videoMenuShadowQualityFocus = false; videoMenuShadowFocus = true; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      direction = 1
      if key == keys.K_LEFTARROW then direction = -1 end if
      if VID_AdjustEnhancedShadowQuality(direction) then return "lighting_applied" end if
      return "lighting_error"
    end if
    return "none"
  end if
  if videoMenuTextureUpscaleFocus then
    if key == keys.K_DOWNARROW then videoMenuTextureUpscaleFocus = false; videoMenuRendererFocus = true; return "move" end if
    if key == keys.K_UPARROW then videoMenuTextureUpscaleFocus = false; videoMenuShadowQualityFocus = true; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      direction = 1
      if key == keys.K_LEFTARROW then direction = -1 end if
      changed = VID_AdjustTextureUpscale(direction)
      if changed is array then return ["texture_upscale", changed[0], changed[1], textureUpscale.modeName(changed[1])] end if
      return "lighting_error"
    end if
    return "none"
  end if
  if videoMenuRendererFocus then
    if key == keys.K_DOWNARROW then videoMenuRendererFocus = false; videoMenuDisplayFocus = true; return "move" end if
    if key == keys.K_UPARROW then videoMenuRendererFocus = false; videoMenuTextureUpscaleFocus = true; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      direction = 1
      if key == keys.K_LEFTARROW then direction = -1 end if
      target = win.renderer()
      attempts = 0
      while attempts < 3
        target = target + direction
        if target < win.RENDER_OPENGL then target = win.RENDER_VULKAN end if
        if target > win.RENDER_VULKAN then target = win.RENDER_OPENGL end if
        if win.rendererAvailable(target) then attempts = 3 else attempts = attempts + 1 end if
      end while
      return ["renderer_switch", target]
    end if
    return "none"
  end if
  if videoMenuDisplayFocus then
    if key == keys.K_UPARROW then videoMenuDisplayFocus = false; videoMenuRendererFocus = true; return "move" end if
    if key == keys.K_DOWNARROW then videoMenuDisplayFocus = false; return "move" end if
    if key == keys.K_LEFTARROW or key == keys.K_RIGHTARROW or key == keys.K_ENTER then
      toggled = try(VID_ToggleFullscreen())
      if toggled is error then VID_State().lastModeMessage = toggled.message; return "mode_error" end if
      return "mode_applied"
    end if
    return "none"
  end if
  selected = VID_MenuSelection()
  count = VID_MenuModeCount()
  if key == keys.K_LEFTARROW then VID_MenuMove(-1); return "move" end if
  if key == keys.K_RIGHTARROW then VID_MenuMove(1); return "move" end if
  if key == keys.K_UPARROW then
    if selected <= VID_ROW_SIZE then videoMenuDisplayFocus = true else VID_MenuMove(-VID_ROW_SIZE) end if
    return "move"
  end if
  if key == keys.K_DOWNARROW then
    if selected + VID_ROW_SIZE > count then videoMenuDisplayFocus = true else VID_MenuMove(VID_ROW_SIZE) end if
    return "move"
  end if
  if key == keys.K_ENTER then
    selected = VID_MenuSelection()
    if selected == NO_MODE then return "none" end if
    applied = try(VID_ApplyResolution(selected))
    if applied is error then VID_State().lastModeMessage = applied.message; return "mode_error" end if
    return "mode_applied"
  end if
  return "none"
end function

// Apply the Quake-compatible vid menu draw callback behavior.
function VID_MenuDrawCallback()
  return VID_MenuDraw()
end function

// Apply the Quake-compatible vid menu key callback behavior.
function VID_MenuKeyCallback(key)
  return VID_MenuKey(key)
end function
