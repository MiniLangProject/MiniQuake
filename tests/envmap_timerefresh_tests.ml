/* BP-052: MiniQuake envmap and timerefresh special paths. */
import miniquake.render.special_paths as bp052Special
import miniquake.render.gl_rmisc as bp052Rmisc
import miniquake.native as bp052Native
import miniquake.types as bp052Types

function bp052Equal(actual, expected, name)
  if actual != expected then return error(5200, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp052Yes(value, name)
  if not value then return error(5201, name + ": expected true") end if
  return true
end function
function bp052Near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(5202, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp052Run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function bp052DirectionCount()
  bp052Equal(len(bp052Special.envmapDirections()), 6, "direction count")
  return true
end function
function bp052DirectionFront()
  value = bp052Special.envmapDirections()[0]
  bp052Equal(value.x, 0.0, "front pitch")
  bp052Equal(value.y, 0.0, "front yaw")
  return true
end function
function bp052DirectionRight()
  value = bp052Special.envmapDirections()[1]
  bp052Equal(value.y, 90.0, "right yaw")
  return true
end function
function bp052DirectionBack()
  value = bp052Special.envmapDirections()[2]
  bp052Equal(value.y, 180.0, "back yaw")
  return true
end function
function bp052DirectionLeft()
  value = bp052Special.envmapDirections()[3]
  bp052Equal(value.y, 270.0, "left yaw")
  return true
end function
function bp052DirectionUp()
  value = bp052Special.envmapDirections()[4]
  bp052Equal(value.x, -90.0, "up pitch")
  return true
end function
function bp052DirectionDown()
  value = bp052Special.envmapDirections()[5]
  bp052Equal(value.x, 90.0, "down pitch")
  return true
end function
function bp052ByteCount()
  bp052Equal(bp052Special.envmapByteCount(), 262144, "envmap bytes")
  return true
end function
function bp052FileZero()
  bp052Equal(bp052Special.envmapFileName(0), "env0.rgb", "envmap file zero")
  return true
end function
function bp052FileFive()
  bp052Equal(bp052Special.envmapFileName(5), "env5.rgb", "envmap file five")
  return true
end function
function bp052YawZero()
  bp052Equal(bp052Special.timeRefreshYaw(0), 0.0, "yaw zero")
  return true
end function
function bp052YawQuarter()
  bp052Near(bp052Special.timeRefreshYaw(32), 90.0, 0.0001, "yaw quarter")
  return true
end function
function bp052YawHalf()
  bp052Near(bp052Special.timeRefreshYaw(64), 180.0, 0.0001, "yaw half")
  return true
end function
function bp052YawLast()
  bp052Near(bp052Special.timeRefreshYaw(127), 357.1875, 0.0001, "yaw last")
  return true
end function
function bp052Result()
  value = bp052Special.timeRefreshResult(2.0)
  bp052Equal(value[0], 2.0, "refresh seconds")
  bp052Equal(value[1], 64.0, "refresh fps")
  return true
end function
function bp052ResultError()
  value = try(bp052Special.timeRefreshResult(0.0))
  bp052Yes(value is error, "non-positive duration")
  return true
end function
function bp052AngleList()
  values = bp052Special.timeRefreshAngles(bp052Types.Vec3(5.0, 7.0, 9.0))
  bp052Equal(len(values), 128, "angle count")
  bp052Equal(values[0].x, 5.0, "pitch preserved")
  bp052Equal(values[127].z, 9.0, "roll preserved")
  return true
end function
function bp052RmiscEnvmap()
  bp052Rmisc.ResetCompatibility()
  directions = bp052Rmisc.R_Envmap_f()
  state = bp052Rmisc.GetRefreshState()
  bp052Equal(len(directions), 6, "rmisc directions")
  bp052Equal(state[0], 6, "rmisc view count")
  bp052Equal(state[2], 0x0405, "rmisc back buffer")
  bp052Equal(state[3], 1, "rmisc end rendering")
  return true
end function
function bp052RmiscTimeRefresh()
  bp052Rmisc.ResetCompatibility()
  value = bp052Rmisc.R_TimeRefresh_f()
  state = bp052Rmisc.GetRefreshState()
  bp052Equal(value[0], 2.0, "rmisc seconds")
  bp052Equal(value[1], 64.0, "rmisc fps")
  bp052Equal(state[0], 128, "rmisc refresh views")
  bp052Near(state[1], 357.1875, 0.0001, "rmisc last yaw")
  return true
end function
function bp052Binary32LastYaw()
  bp052Equal(bp052Native.floatBits(bp052Special.timeRefreshYaw(127)), bp052Native.floatBits(357.1875), "last yaw bits")
  return true
end function

passed = 0
if bp052Run(1, "envmap direction count", bp052DirectionCount) then passed = passed + 1 end if
if bp052Run(2, "envmap front", bp052DirectionFront) then passed = passed + 1 end if
if bp052Run(3, "envmap right", bp052DirectionRight) then passed = passed + 1 end if
if bp052Run(4, "envmap back", bp052DirectionBack) then passed = passed + 1 end if
if bp052Run(5, "envmap left", bp052DirectionLeft) then passed = passed + 1 end if
if bp052Run(6, "envmap up", bp052DirectionUp) then passed = passed + 1 end if
if bp052Run(7, "envmap down", bp052DirectionDown) then passed = passed + 1 end if
if bp052Run(8, "envmap byte count", bp052ByteCount) then passed = passed + 1 end if
if bp052Run(9, "envmap file zero", bp052FileZero) then passed = passed + 1 end if
if bp052Run(10, "envmap file five", bp052FileFive) then passed = passed + 1 end if
if bp052Run(11, "timerefresh yaw zero", bp052YawZero) then passed = passed + 1 end if
if bp052Run(12, "timerefresh yaw quarter", bp052YawQuarter) then passed = passed + 1 end if
if bp052Run(13, "timerefresh yaw half", bp052YawHalf) then passed = passed + 1 end if
if bp052Run(14, "timerefresh yaw last", bp052YawLast) then passed = passed + 1 end if
if bp052Run(15, "timerefresh result", bp052Result) then passed = passed + 1 end if
if bp052Run(16, "timerefresh invalid duration", bp052ResultError) then passed = passed + 1 end if
if bp052Run(17, "timerefresh angle list", bp052AngleList) then passed = passed + 1 end if
if bp052Run(18, "rmisc envmap state", bp052RmiscEnvmap) then passed = passed + 1 end if
if bp052Run(19, "rmisc timerefresh state", bp052RmiscTimeRefresh) then passed = passed + 1 end if
if bp052Run(20, "timerefresh Binary32 yaw", bp052Binary32LastYaw) then passed = passed + 1 end if
if passed != 20 then print "MiniQuake BP-052 envmap/timerefresh tests failed: " + passed + "/20"; error(5299, "BP-052 envmap/timerefresh") end if
print "MiniQuake BP-052 envmap/timerefresh tests passed: 20"
