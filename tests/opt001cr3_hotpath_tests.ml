import miniquake.build_info as buildInfo
import miniquake.array_util as arrays
import miniquake.client_state as clientState
import miniquake.server_state as serverState
import miniquake.keys as keys
import miniquake.sys_win as sysWin
import miniquake.mathlib as math
import miniquake.types as t
import miniquake.gl_vidnt as video
import miniquake.common as common
import miniquake.screen as screen

opt001cr3r8Passed = 0
opt001cr3r8Failed = 0

function opt001cr3r8Check(condition, label)
  global opt001cr3r8Passed, opt001cr3r8Failed
  if condition then
    opt001cr3r8Passed = opt001cr3r8Passed + 1
    print "[PASS] " + label
  else
    opt001cr3r8Failed = opt001cr3r8Failed + 1
    print "[FAIL] " + label
  end if
end function

function opt001cr3r8VideoState()
  state = video.createVideoState()
  video.VID_UseState(state)
  video.VID_InitDIB(common.create([]))
  video.VID_InitFullDIB([[800, 600, 16, 60, true]], false, false)
  return state
end function

function main(args)
  opt001cr3r8Check(buildInfo.OPTIMIZATION_STATUS == "opt001d_performance_audio_ui_candidate_v1", "optimization status")
  opt001cr3r8Check(buildInfo.OPTIMIZATION_FINGERPRINT == 0x1c001c10, "optimization fingerprint")
  opt001cr3r8Check(buildInfo.OPTIMIZATION_PARENT == "OPT-001CR3R7", "optimization parent")
  opt001cr3r8Check(buildInfo.OPTIMIZATION_DELIVERY_REVISION == "OPT-001D", "optimization delivery revision")
  opt001cr3r8Check(buildInfo.OPTIMIZATION_DELIVERY_PARENT == "OPT-001CR3R7", "optimization delivery parent")
  opt001cr3r8Check(buildInfo.OPT001C_STATUS == "opt001c_frame_allocation_candidate_v1", "frozen OPT-001C status")
  opt001cr3r8Check(buildInfo.OPT001C_FINGERPRINT == 0x1c001c03, "frozen OPT-001C fingerprint")

  filled = arrays.makeFilledArray(5, 7)
  opt001cr3r8Check(len(filled) == 5, "filled array length")
  opt001cr3r8Check(filled[0] == 7 and filled[4] == 7, "filled array values")
  stats = clientState.zeroStats(32)
  opt001cr3r8Check(len(stats) == 32 and stats[0] == 0 and stats[31] == 0, "zero stats exact allocation")
  identity = keys.identityValues(8)
  opt001cr3r8Check(len(identity) == 8 and identity[0] == 0 and identity[7] == 7, "identity exact allocation")
  server = serverState.create(4)
  opt001cr3r8Check(len(server.clients) == 4 and server.clients[0] is void, "server client exact allocation")
  handles = sysWin.emptyHandles()
  opt001cr3r8Check(len(handles) == 10 and handles[0] == 0 and handles[9] == 0, "system handle exact allocation")

  a = t.Vec3(1.0, 2.0, 3.0)
  b = t.Vec3(4.0, 5.0, 6.0)
  opt001cr3r8Check(math.DotProduct(a, b) == 32.0, "inline dot product")

  state = opt001cr3r8VideoState()
  opt001cr3r8Check(video.VID_FindRequestedMode(common.create([])) == video.MODE_WINDOWED, "default video mode is windowed")
  opt001cr3r8Check(video.VID_FindRequestedMode(common.create(["-width", "1024", "-height", "768"])) == video.MODE_WINDOWED, "window dimensions remain windowed")
  opt001cr3r8Check(video.VID_FindRequestedMode(common.create(["-fullscreen", "-width", "800", "-height", "600", "-bpp", "16"])) == 1, "explicit fullscreen override")

  opt001cr3r8Check(video.VID_WindowTitleForFps(-10) == "MiniQuake - 0 FPS", "window title clamps negative FPS")
  opt001cr3r8Check(video.VID_WindowTitleForFps(73) == "MiniQuake - 73 FPS", "window title reports FPS")
  opt001cr3r8Check(video.VID_WindowTitleForFps(20000) == "MiniQuake - 9999 FPS", "window title clamps high FPS")
  opt001cr3r8Check(not screen.SCR_ShouldDrawNet(10.0, 0.0, false, true, false), "net icon hidden before first packet")
  opt001cr3r8Check(not screen.SCR_ShouldDrawNet(10.0, 1.0, false, true, true), "net icon hidden for local server")
  opt001cr3r8Check(screen.SCR_ShouldDrawNet(10.0, 9.0, false, true, false), "net icon retained for stale remote connection")

  print "MiniQuake OPT-001CR3R8 hotpath/window tests passed: " + opt001cr3r8Passed
  if opt001cr3r8Failed > 0 then
    print "MiniQuake OPT-001CR3R8 hotpath/window tests failed: " + opt001cr3r8Failed
    return 1
  end if
  return 0
end function
