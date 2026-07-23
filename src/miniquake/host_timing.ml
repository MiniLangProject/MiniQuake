package miniquake.host_timing

import miniquake.types as t
import miniquake.constants as c

function create()
  return t.HostTiming(0.0, 0.0, 0.0, 0, 0)
end function

function filter(timing, elapsed, timedemo, forcedFrameRate, timeScale)
  if elapsed < 0.0 then elapsed = 0.0 end if
  timing.realtime = timing.realtime + elapsed
  delta = timing.realtime - timing.oldRealtime
  if not timedemo and delta < 1.0 / 72.0 then
    timing.filteredFrames = timing.filteredFrames + 1
    return false
  end if

  timing.frameTime = delta
  timing.oldRealtime = timing.realtime
  if forcedFrameRate > 0.0 then
    timing.frameTime = forcedFrameRate
  else
    if timing.frameTime > c.MAXIMUM_FRAME_TIME then timing.frameTime = c.MAXIMUM_FRAME_TIME end if
    if timing.frameTime < c.MINIMUM_FRAME_TIME then timing.frameTime = c.MINIMUM_FRAME_TIME end if
  end if
  if timeScale > 0.0 then timing.frameTime = timing.frameTime * timeScale end if
  timing.frameCount = timing.frameCount + 1
  return true
end function

function milliseconds(timing)
  value = timing.frameTime * 1000.0
  if value < 1.0 then return 1 end if
  if value > 255.0 then return 255 end if
  return value
end function
