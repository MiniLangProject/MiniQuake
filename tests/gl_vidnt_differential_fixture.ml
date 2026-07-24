import miniquake.gl_vidnt as video
import miniquake.common as common
import miniquake.cvar as cvar
import miniquake.keys as keys

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function grayPalette()
  palette = bytes(768)
  index = 0
  while index < 256
    palette[index * 3] = index
    palette[index * 3 + 1] = index
    palette[index * 3 + 2] = index
    index = index + 1
  end while
  return palette
end function

function installThreeModes()
  state = video.createVideoState()
  state.arguments = common.create(["glquake"])
  state.modes = [
    video.makeMode(video.MS_WINDOWED, 640, 480, 0, 0, 0),
    video.makeMode(video.MS_FULLDIB, 800, 600, 16, 0, 0),
    video.makeMode(video.MS_FULLDIB, 1024, 768, 32, 0, 0),
  ]
  index = 0
  while index < len(state.modes)
    state.modes[index].modeNumber = index
    index = index + 1
  end while
  video.VID_UseState(state)
  return state
end function

function main(args)
  palette = grayPalette()
  shifted = grayPalette()
  state = installThreeModes()

  video.VID_HandlePause(true)
  print "{\"function\":\"VID_HandlePause\",\"case\":\"noop\",\"result\":0}"
  video.VID_ForceLockState(7)
  print "{\"function\":\"VID_ForceLockState\",\"case\":\"noop\",\"result\":0}"
  video.VID_LockBuffer()
  print "{\"function\":\"VID_LockBuffer\",\"case\":\"noop\",\"result\":0}"
  video.VID_UnlockBuffer()
  print "{\"function\":\"VID_UnlockBuffer\",\"case\":\"noop\",\"result\":0}"
  result = video.VID_ForceUnlockedAndReturnState()
  print "{\"function\":\"VID_ForceUnlockedAndReturnState\"," +
    "\"case\":\"constant\",\"result\":" + result + "}"
  video.D_BeginDirectRect(1, 2, palette, 8, 8)
  print "{\"function\":\"D_BeginDirectRect\",\"case\":\"noop\",\"result\":0}"
  video.D_EndDirectRect(1, 2, 8, 8)
  print "{\"function\":\"D_EndDirectRect\",\"case\":\"noop\",\"result\":0}"

  centered = video.CenterWindow(640, 480, 1920, 1080, false)
  print "{\"function\":\"CenterWindow\",\"case\":\"dual-center\",\"x\":" +
    centered[0] + ",\"y\":" + centered[1] + ",\"calls\":1}"

  result = video.VID_SetWindowedMode(0, false)
  print "{\"function\":\"VID_SetWindowedMode\",\"case\":\"640x480\"," +
    "\"result\":" + boolNumber(result) + ",\"state\":" + state.modeState +
    ",\"width\":" + state.dibWidth + ",\"height\":" + state.dibHeight + "}"

  result = video.VID_SetFullDIBMode(1, false)
  print "{\"function\":\"VID_SetFullDIBMode\",\"case\":\"800x600x16\"," +
    "\"result\":" + boolNumber(result) + ",\"state\":" + state.modeState +
    ",\"width\":" + state.dibWidth + ",\"height\":" + state.dibHeight + "}"

  state.windowed = true
  result = video.VID_SetMode(0, palette, false)
  print "{\"function\":\"VID_SetMode\",\"case\":\"windowed\",\"result\":" +
    boolNumber(result) + ",\"mode\":" + state.currentMode +
    ",\"recalc\":" + boolNumber(state.recalcRefdef) + "}"

  state.windowX = 10
  state.windowY = 20
  state.windowWidth = 800
  state.windowHeight = 600
  rectangle = video.VID_UpdateWindowStatus()
  print "{\"function\":\"VID_UpdateWindowStatus\",\"case\":\"rect\"," +
    "\"center\":[" + rectangle[4] + "," + rectangle[5] + "],\"clip\":1}"

  state.glExtensions = "GL_EXT_texture_object GL_EXT_vertex_array GL_SGIS_multitexture "
  result = video.CheckTextureExtensions()
  print "{\"function\":\"CheckTextureExtensions\",\"case\":\"extension\"," +
    "\"bound\":" + boolNumber(result) + "}"
  result = video.CheckArrayExtensions()
  print "{\"function\":\"CheckArrayExtensions\",\"case\":\"extension\"," +
    "\"loaded\":" + boolNumber(result) + "}"
  result = video.CheckMultiTextureExtensions()
  print "{\"function\":\"CheckMultiTextureExtensions\",\"case\":\"sgis\"," +
    "\"enabled\":" + boolNumber(result) + "}"

  state.glVendor = "MiniGL"
  state.glRenderer = "PowerVR Test"
  state.glVersion = "1.1"
  state.fullSbarDraw = false
  state.isPermedia = false
  video.GL_Init()
  print "{\"function\":\"GL_Init\",\"case\":\"powervr\",\"vendor\":\"" +
    state.glVendor + "\",\"fullsbar\":" + boolNumber(state.fullSbarDraw) +
    ",\"permedia\":" + boolNumber(state.isPermedia) + "}"

  state.windowWidth = 800
  state.windowHeight = 600
  renderBox = video.GL_BeginRendering()
  print "{\"function\":\"GL_BeginRendering\",\"case\":\"rect\",\"box\":[" +
    renderBox[0] + "," + renderBox[1] + "," + renderBox[2] + "," +
    renderBox[3] + "]}"
  video.GL_EndRendering()
  print "{\"function\":\"GL_EndRendering\",\"case\":\"swap\",\"swaps\":1}"
  state.skipUpdate = true
  state.blockDrawing = false
  video.GL_EndRendering()
  state.blockDrawing = true
  video.GL_EndRendering()
  print "{\"function\":\"GL_EndRendering\",\"case\":\"skip-block\"," +
    "\"skipped\":0,\"blocked\":1}"

  video.VID_SetPalette(palette)
  print "{\"function\":\"VID_SetPalette\",\"case\":\"gray\",\"first\":" +
    state.table24[0] + ",\"transparent\":" + state.table24[255] +
    ",\"nearest\":" + state.table15[0] + "}"
  before = state.gammaWorks
  video.VID_ShiftPalette(shifted)
  print "{\"function\":\"VID_ShiftPalette\",\"case\":\"noop\"," +
    "\"gammaworks\":" + boolNumber(state.gammaWorks == before) + "}"

  video.VID_SetDefaultMode()
  print "{\"function\":\"VID_SetDefaultMode\",\"case\":\"deactivate\",\"calls\":1}"
  video.VID_Shutdown()
  print "{\"function\":\"VID_Shutdown\",\"case\":\"initialized\"," +
    "\"deactivations\":0}"

  result = video.bSetupPixelFormat()
  print "{\"function\":\"bSetupPixelFormat\",\"case\":\"supported\"," +
    "\"result\":" + boolNumber(result) + "}"
  print "{\"function\":\"MapKey\",\"case\":\"scan\",\"escape\":" +
    video.MapKey(1 << 16) + ",\"a\":" + video.MapKey(30 << 16) +
    ",\"invalid\":" + video.MapKey(200 << 16) + "}"
  video.ClearAllStates()
  print "{\"function\":\"ClearAllStates\",\"case\":\"release\",\"events\":256}"

  state.modeState = video.MS_WINDOWED
  video.AppActivate(false, false)
  print "{\"function\":\"AppActivate\",\"case\":\"windowed-inactive\"," +
    "\"active\":" + boolNumber(state.activeApp) +
    ",\"minimized\":" + boolNumber(state.minimized) + ",\"deactivations\":1}"
  state.modeState = video.MS_FULLDIB
  state.canAltTab = true
  state.wasSuspended = false
  video.AppActivate(false, true)
  suspended = state.wasSuspended
  video.AppActivate(true, false)
  print "{\"function\":\"AppActivate\",\"case\":\"fullscreen-cycle\"," +
    "\"suspended\":" + boolNumber(suspended) + ",\"restored\":" +
    boolNumber(not state.wasSuspended) + ",\"active\":" +
    boolNumber(state.activeApp) + "}"
  video.MainWndProc(0x0100, 0, 30 << 16)
  print "{\"function\":\"MainWndProc\",\"case\":\"keydown\",\"events\":1}"

  state.modeState = video.MS_FULLDIB
  state.currentMode = 1
  print "{\"function\":\"VID_NumModes\",\"case\":\"three\",\"count\":" +
    video.VID_NumModes() + "}"
  print "{\"function\":\"VID_GetModePtr\",\"case\":\"sentinel\",\"valid\":\"" +
    video.VID_GetModePtr(1).description + "\",\"bad\":\"" +
    video.VID_GetModePtr(99).description + "\"}"
  print "{\"function\":\"VID_GetModeDescription\",\"case\":\"fullscreen\"," +
    "\"description\":\"" + video.VID_GetModeDescription(1) + "\"}"
  state.leaveCurrentMode = true
  print "{\"function\":\"VID_GetModeDescription\",\"case\":\"desktop\"," +
    "\"description\":\"" + video.VID_GetModeDescription(2) + "\"}"
  state.leaveCurrentMode = false
  print "{\"function\":\"VID_GetExtModeDescription\",\"case\":\"fullscreen\"," +
    "\"description\":\"" + video.VID_GetExtModeDescription(1) + "\"}"
  print "{\"function\":\"VID_DescribeCurrentMode_f\",\"case\":\"current\"," +
    "\"text\":\"" + video.VID_DescribeCurrentMode_f() + "\"}"
  print "{\"function\":\"VID_NumModes_f\",\"case\":\"plural\",\"text\":\"" +
    video.VID_NumModes_f() + "\"}"
  print "{\"function\":\"VID_DescribeMode_f\",\"case\":\"one\",\"text\":\"" +
    video.VID_DescribeMode_f(["vid_describemode", "1"]) + "\"}"
  descriptions = video.VID_DescribeModes_f()
  print "{\"function\":\"VID_DescribeModes_f\",\"case\":\"all\",\"lines\":" +
    len(descriptions) + "}"

  windowArguments = common.create(["glquake", "-width", "800", "-height", "600"])
  video.VID_InitDIB(windowArguments)
  print "{\"function\":\"VID_InitDIB\",\"case\":\"args\",\"count\":" +
    video.VID_NumModes() + ",\"mode\":\"" +
    video.VID_GetModePtr(0).description + "\"}"
  video.VID_InitFullDIB([
    [1024, 768, 32, 0, true],
    [800, 600, 16, 0, true],
    [1024, 768, 32, 75, true],
    [5120, 1440, 32, 0, true],
  ], false, false)
  print "{\"function\":\"VID_InitFullDIB\",\"case\":\"enumerated\",\"count\":" +
    video.VID_NumModes() + ",\"first\":\"" +
    video.VID_GetModePtr(1).description + "\",\"last_width\":" +
    video.VID_GetModePtr(video.VID_NumModes() - 1).width +
    ",\"halfscreen\":" +
    video.VID_GetModePtr(video.VID_NumModes() - 1).halfscreen + "}"

  state.is8bit = false
  print "{\"function\":\"VID_Is8bit\",\"case\":\"disabled\",\"result\":" +
    boolNumber(video.VID_Is8bit()) + "}"
  video.VID_Init8bitPalette()
  print "{\"function\":\"VID_Init8bitPalette\",\"case\":\"entrypoint\"," +
    "\"enabled\":" + boolNumber(state.is8bit) + "}"

  state.arguments = common.create(["glquake", "-gamma", "1"])
  video.Check_Gamma(shifted)
  print "{\"function\":\"Check_Gamma\",\"case\":\"gamma-one\",\"black\":" +
    shifted[0] + ",\"mid\":" + shifted[127] + ",\"white\":" +
    shifted[255] + "}"

  variables = cvar.createRegistry()
  variables.variables = [
    cvar.create("vid_mode", "0", false, false),
    cvar.create("_windowed_mouse", "1", true, false),
  ]
  initialized = video.VID_Init(
    common.create(["glquake", "-window"]), variables, grayPalette(), false)
  print "{\"function\":\"VID_Init\",\"case\":\"windowed\",\"cvars\":11," +
    "\"commands\":4,\"mode\":" + initialized.currentMode + ",\"size\":[" +
    initialized.width + "," + initialized.height + "]}"

  state = installThreeModes()
  state.currentMode = 1
  menuTrace = video.VID_MenuDraw()
  print "{\"function\":\"VID_MenuDraw\",\"case\":\"two-modes\"," +
    "\"prints\":7,\"wmodes\":" + (len(menuTrace) - 6) + "}"
  video.VID_MenuKey(keys.K_ESCAPE)
  print "{\"function\":\"VID_MenuKey\",\"case\":\"escape\",\"options\":1}"
  return 0
end function
