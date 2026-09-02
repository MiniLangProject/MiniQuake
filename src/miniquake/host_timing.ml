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

/// Implements the `create` operation for `miniquake.host_timing` (create).
function create()
  return t.HostTiming(0.0, 0.0, 0.0, 0, 0)
end function

/// Implements the `binary32` operation for `miniquake.host_timing` (binary32).
/// @param value Value consumed by `binary32`.
function binary32(value)
  return native.bitsFloat(native.floatBits(value))
end function

/// Exact Host_FilterTime core.  WinQuake receives a float delta from the
/// platform entry point, accumulates it in the double-precision realtime clock,
/// filters against the unmodified oldRealtime value and only then updates the
/// accepted frame time.
/// @param timing The timing input consumed by `filterAbsolute`.
/// @param newRealtime Time value used by the operation.
/// @param maxFps The max fps input consumed by `filterAbsolute`.
/// @param forcedFrameRate The forced frame rate input consumed by `filterAbsolute`.
/// @param timedemo The timedemo input consumed by `filterAbsolute`.
/// @param timeScale The time scale input consumed by `filterAbsolute`.
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

/// Implements the `filter` operation for `miniquake.host_timing` (filter).
/// @param timing The timing input consumed by `filter`.
/// @param elapsed The elapsed input consumed by `filter`.
/// @param timedemo The timedemo input consumed by `filter`.
/// @param forcedFrameRate The forced frame rate input consumed by `filter`.
/// @param timeScale The time scale input consumed by `filter`.
/// @param maxFps The max fps input consumed by `filter`.
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

/// Implements the `milliseconds` operation for `miniquake.host_timing` (milliseconds).
/// @param timing The timing input consumed by `milliseconds`.
function milliseconds(timing)
  value = timing.frameTime * 1000.0
  if value < 1.0 then return 1 end if
  if value > 255.0 then return 255 end if
  return native.trunc(value)
end function
