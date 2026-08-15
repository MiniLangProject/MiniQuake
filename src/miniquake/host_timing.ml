/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.host_timing.
*/
package miniquake.host_timing

import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native

// Create and initialize the module state.
function create()
  return t.HostTiming(0.0, 0.0, 0.0, 0, 0)
end function

// Provide binary32 behavior for the active subsystem.
function binary32(value)
  return native.bitsFloat(native.floatBits(value))
end function

// Exact Host_FilterTime core.  WinQuake receives a float delta from the
// platform entry point, accumulates it in the double-precision realtime clock,
// filters against the unmodified oldRealtime value and only then updates the
// accepted frame time.
function filterAbsolute(timing, newRealtime, maxFps, forcedFrameRate, timedemo, timeScale)
  timing.realtime = newRealtime
  delta = timing.realtime - timing.oldRealtime
  if not timedemo and maxFps > 0.0 and delta < 1.0 / maxFps then
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
  // timeScale is a MiniQuake extension and is deliberately applied only after
  // the complete WinQuake decision and clamp sequence.
  if timeScale > 0.0 and timeScale != 1.0 then timing.frameTime = timing.frameTime * timeScale end if
  timing.frameCount = timing.frameCount + 1
  return true
end function

// Provide filter behavior for the active subsystem.
function filter(timing, elapsed, timedemo, forcedFrameRate, timeScale, maxFps)
  // _Host_Frame takes float time in WinQuake.  Preserve that boundary even
  // though MiniLang numeric expressions can otherwise retain more precision.
  inputDelta = binary32(elapsed)
  return filterAbsolute(
    timing,
    timing.realtime + inputDelta,
    maxFps,
    forcedFrameRate,
    timedemo,
    timeScale,
  )
end function

// Provide milliseconds behavior for the active subsystem.
function milliseconds(timing)
  value = timing.frameTime * 1000.0
  if value < 1.0 then return 1 end if
  if value > 255.0 then return 255 end if
  return native.trunc(value)
end function
