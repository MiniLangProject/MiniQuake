/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

OPT-001A diagnostics only.  The module is disabled during normal gameplay.
When enabled explicitly by the OPT-001A commands it records frame durations
and checkpoint-to-checkpoint stage times in fixed arrays.
*/
package miniquake.optimization_baseline

import miniquake.native as native
import std.fs as fs

/// Defines the stage count value used by `miniquake.optimization_baseline`.
const STAGE_COUNT = 46
/// Defines the other stage index value used by `miniquake.optimization_baseline`.
const OTHER_STAGE_INDEX = 19

/// Tracks the module-level stage names state owned by `miniquake.optimization_baseline`.
stageNames = [
  "filter",
  "commands",
  "net_poll",
  "send",
  "console",
  "server",
  "host_time",
  "client_read",
  "demo_scene",
  "entity_relink",
  "entity_effects",
  "client_events",
  "qc_control",
  "centerprint",
  "view",
  "screen",
  "dlight_decay",
  "particles",
  "audio",
  "other",
  "screen_world",
  "screen_entities",
  "screen_particles_draw",
  "screen_viewmodel",
  "screen_water",
  "screen_mirror",
  "screen_polyblend",
  "screen_ui",
  "screen_evidence",
  "screen_swap",
  "screen_title",
  "world_clear",
  "world_recursive",
  "world_multitexture",
  "world_chains",
  "world_lightmaps",
  "mtex_lightmaps",
  "mtex_uploads",
  "mtex_setup",
  "mtex_records",
  "mtex_native",
  "alias_upload",
  "alias_frame",
  "alias_light",
  "alias_mesh",
  "alias_native",
]

/// Tracks the module-level stage lookup keys state owned by `miniquake.optimization_baseline`.
stageLookupKeys = array(64, 0)
/// Tracks the module-level stage lookup values state owned by `miniquake.optimization_baseline`.
stageLookupValues = array(64, -1)

/// Tracks the module-level profile enabled state owned by `miniquake.optimization_baseline`.
profileEnabled = false
/// Tracks the module-level profile capacity state owned by `miniquake.optimization_baseline`.
profileCapacity = 0
/// Tracks the module-level profile frame count state owned by `miniquake.optimization_baseline`.
profileFrameCount = 0
/// Tracks the module-level profile frame start state owned by `miniquake.optimization_baseline`.
profileFrameStart = 0
/// Tracks the module-level profile last tick state owned by `miniquake.optimization_baseline`.
profileLastTick = 0
/// Tracks the module-level profile frame active state owned by `miniquake.optimization_baseline`.
profileFrameActive = false
/// Tracks the module-level profile durations state owned by `miniquake.optimization_baseline`.
profileDurations = []
/// Tracks the module-level profile stage totals state owned by `miniquake.optimization_baseline`.
profileStageTotals = array(STAGE_COUNT, 0)
/// Tracks the module-level profile stage hits state owned by `miniquake.optimization_baseline`.
profileStageHits = array(STAGE_COUNT, 0)
/// Tracks the module-level profile stage frames state owned by `miniquake.optimization_baseline`.
profileStageFrames = []

/// Implements the `boolText` operation for `miniquake.optimization_baseline` (bool text).
/// @param value Value consumed by `boolText`.
function boolText(value)
  if value then return "true" end if
  return "false"
end function

// Report whether enabled holds for the active state.
function enabled()
  return profileEnabled
end function

/// Convert stage into its canonical representation.
/// @param stage The stage input consumed by `normalizeStage`.
function normalizeStage(stage)
  if stage == "demo_send" or stage == "local_send" or stage == "remote_send" then
    return "send"
  end if
  return stage
end function

/// Return stage index derived from the active module state.
/// @param stage The stage input consumed by `stageIndex`.
function stageIndex(stage)
  global stageLookupKeys, stageLookupValues
  key = nativeRawValue(stage)
  slot = ((key >> 3) ^ (key >> 11)) & 63
  if stageLookupValues[slot] >= 0 and stageLookupKeys[slot] == key then return stageLookupValues[slot] end if
  target = normalizeStage(stage)
  index = 0
  while index < len(stageNames)
    if stageNames[index] == target then
      stageLookupKeys[slot] = key
      stageLookupValues[slot] = index
      return index
    end if
    index = index + 1
  end while
  stageLookupKeys[slot] = key
  stageLookupValues[slot] = OTHER_STAGE_INDEX
  return OTHER_STAGE_INDEX
end function

/// Implements the `configure` operation for `miniquake.optimization_baseline` (configure).
/// @param frameCapacity The frame capacity input consumed by `configure`.
function configure(frameCapacity)
  global profileEnabled, profileCapacity, profileFrameCount
  global profileFrameStart, profileLastTick, profileFrameActive
  global profileDurations, profileStageTotals, profileStageHits, profileStageFrames

  if frameCapacity < 1 then frameCapacity = 1 end if
  profileCapacity = frameCapacity
  profileFrameCount = 0
  profileFrameStart = 0
  profileLastTick = 0
  profileFrameActive = false
  profileDurations = array(frameCapacity, 0)
  profileStageTotals = array(STAGE_COUNT, 0)
  profileStageHits = array(STAGE_COUNT, 0)
  profileStageFrames = array(frameCapacity * STAGE_COUNT, 0)
  profileEnabled = true
  return true
end function

/// Implements the `disable` operation for `miniquake.optimization_baseline` (disable).
function disable()
  global profileEnabled, profileFrameActive
  profileEnabled = false
  profileFrameActive = false
  return true
end function

// Initialize state for begin frame.
function beginFrame()
  global profileFrameStart, profileLastTick, profileFrameActive
  if not profileEnabled then return true end if
  now = native.winTicks()
  profileFrameStart = now
  profileLastTick = now
  profileFrameActive = true
  return true
end function

/// Checks point for `miniquake.optimization_baseline`.
/// @param stage The stage input consumed by `checkpoint`.
function checkpoint(stage)
  global profileLastTick, profileStageTotals, profileStageHits, profileStageFrames
  if not profileEnabled or not profileFrameActive then return true end if
  now = native.winTicks()
  index = stageIndex(stage)
  elapsed = now - profileLastTick
  profileStageTotals[index] = profileStageTotals[index] + elapsed
  profileStageHits[index] = profileStageHits[index] + 1
  if profileFrameCount < profileCapacity then
    profileStageFrames[profileFrameCount * STAGE_COUNT + index] = elapsed
  end if
  profileLastTick = now
  return true
end function

/// Implements the `filteredFrame` operation for `miniquake.optimization_baseline` (filtered frame).
function filteredFrame()
  global profileFrameActive
  if not profileEnabled then return true end if
  profileFrameActive = false
  return true
end function

// Handle frame and update the associated state.
function completeFrame()
  global profileFrameCount, profileFrameActive, profileDurations
  global profileLastTick, profileStageTotals, profileStageHits

  if not profileEnabled or not profileFrameActive then return true end if
  now = native.winTicks()
  remainder = now - profileLastTick
  profileStageTotals[OTHER_STAGE_INDEX] = profileStageTotals[OTHER_STAGE_INDEX] + remainder
  profileStageHits[OTHER_STAGE_INDEX] = profileStageHits[OTHER_STAGE_INDEX] + 1
  if profileFrameCount < profileCapacity then
    profileDurations[profileFrameCount] = now - profileFrameStart
    profileFrameCount = profileFrameCount + 1
  end if
  profileFrameActive = false
  return true
end function

/// Implements the `recordedFrames` operation for `miniquake.optimization_baseline` (recorded frames).
function recordedFrames()
  return profileFrameCount
end function

/// Implements the `sortedDurations` operation for `miniquake.optimization_baseline` (sorted durations).
function sortedDurations()
  count = profileFrameCount
  values = array(count, 0)
  // Copy the recorded prefix in one native operation before sorting the
  // private snapshot in place.
  copyArray(values, 0, profileDurations, 0, count)

  index = 1
  while index < count
    value = values[index]
    cursor = index - 1
    while cursor >= 0 and values[cursor] > value
      values[cursor + 1] = values[cursor]
      cursor = cursor - 1
    end while
    values[cursor + 1] = value
    index = index + 1
  end while
  return values
end function

/// Implements the `percentileFromSorted` operation for `miniquake.optimization_baseline` (percentile from sorted).
/// @param values The values input consumed by `percentileFromSorted`.
/// @param numerator The numerator input consumed by `percentileFromSorted`.
/// @param denominator The denominator input consumed by `percentileFromSorted`.
function percentileFromSorted(values, numerator, denominator)
  count = len(values)
  if count == 0 then return 0 end if
  index = native.trunc(((count - 1) * numerator) / denominator)
  if index < 0 then index = 0 end if
  if index >= count then index = count - 1 end if
  return values[index]
end function

// Return summary derived from the active module state.
function summary()
  values = sortedDurations()
  count = len(values)
  if count == 0 then return [0, 0, 0, 0, 0, 0] end if
  total = 0
  maximum = 0
  index = 0
  while index < count
    total = total + values[index]
    if values[index] > maximum then maximum = values[index] end if
    index = index + 1
  end while
  return [
    count,
    total,
    percentileFromSorted(values, 50, 100),
    percentileFromSorted(values, 95, 100),
    percentileFromSorted(values, 99, 100),
    maximum,
  ]
end function

/// Implements the `stageTotalsJson` operation for `miniquake.optimization_baseline` (stage totals json).
function stageTotalsJson()
  result = "["
  index = 0
  while index < STAGE_COUNT
    if index > 0 then result = result + "," end if
    result = result + "{\"name\":\"" + stageNames[index] + "\","
    result = result + "\"total_ms\":" + profileStageTotals[index] + ","
    result = result + "\"hits\":" + profileStageHits[index] + "}"
    index = index + 1
  end while
  return result + "]"
end function

/// Implements the `resourceJson` operation for `miniquake.optimization_baseline` (resource json).
/// @param values The values input consumed by `resourceJson`.
function resourceJson(values)
  result = "["
  index = 0
  while index < len(values)
    if index > 0 then result = result + "," end if
    result = result + values[index]
    index = index + 1
  end while
  return result + "]"
end function

/// Encode and write reports.
/// @param prefix The prefix input consumed by `writeReports`.
/// @param mode The mode input consumed by `writeReports`.
/// @param mapName Name of the map to load or inspect.
/// @param beforeResources The before resources input consumed by `writeReports`.
/// @param afterResources The after resources input consumed by `writeReports`.
function writeReports(prefix, mode, mapName, beforeResources, afterResources)
  stats = summary()

  csv = "frame,duration_ms"
  stageIndexValue = 0
  while stageIndexValue < STAGE_COUNT
    csv = csv + "," + stageNames[stageIndexValue] + "_ms"
    stageIndexValue = stageIndexValue + 1
  end while
  csv = csv + "\n"
  index = 0
  while index < profileFrameCount
    csv = csv + index + "," + profileDurations[index]
    stageIndexValue = 0
    while stageIndexValue < STAGE_COUNT
      csv = csv + "," + profileStageFrames[index * STAGE_COUNT + stageIndexValue]
      stageIndexValue = stageIndexValue + 1
    end while
    csv = csv + "\n"
    index = index + 1
  end while
  csvResult = try(fs.writeAllText(prefix + "-frames.csv", csv))
  if csvResult is error then return csvResult end if

  json = "{"
  json = json + "\"schema\":\"MiniQuakeOPT001AFrameBaseline/1\","
  json = json + "\"mode\":\"" + mode + "\","
  json = json + "\"map\":\"" + mapName + "\","
  json = json + "\"frames\":" + stats[0] + ","
  json = json + "\"total_ms\":" + stats[1] + ","
  json = json + "\"median_ms\":" + stats[2] + ","
  json = json + "\"p95_ms\":" + stats[3] + ","
  json = json + "\"p99_ms\":" + stats[4] + ","
  json = json + "\"max_ms\":" + stats[5] + ","
  json = json + "\"stage_totals\":" + stageTotalsJson() + ","
  json = json + "\"resources_before\":" + resourceJson(beforeResources) + ","
  json = json + "\"resources_after\":" + resourceJson(afterResources)
  json = json + "}\n"
  jsonResult = try(fs.writeAllText(prefix + "-summary.json", json))
  if jsonResult is error then return jsonResult end if
  return true
end function

/// Format and emit summary.
/// @param mode The mode input consumed by `printSummary`.
/// @param mapName Name of the map to load or inspect.
function printSummary(mode, mapName)
  stats = summary()
  print "MiniQuake OPT-001A frame baseline"
  print "  mode=" + mode + " map=" + mapName
  print "  frames=" + stats[0]
  print "  total_ms=" + stats[1]
  print "  median_ms=" + stats[2]
  print "  p95_ms=" + stats[3]
  print "  p99_ms=" + stats[4]
  print "  max_ms=" + stats[5]
  index = 0
  while index < STAGE_COUNT
    print "  stage_" + stageNames[index] + "_ms=" + profileStageTotals[index]
    index = index + 1
  end while
  return stats
end function

/// Print the stage breakdown for frames at or above the requested duration.
/// @param minimumMilliseconds The minimum milliseconds input consumed by `printSlowFrames`.
function printSlowFrames(minimumMilliseconds)
  index = 0
  while index < profileFrameCount
    duration = profileDurations[index]
    if duration >= minimumMilliseconds then
      line = "  slow_frame=" + index + " total_ms=" + duration
      stageIndexValue = 0
      while stageIndexValue < STAGE_COUNT
        elapsed = profileStageFrames[index * STAGE_COUNT + stageIndexValue]
        if elapsed > 0 then
          line = line + " " + stageNames[stageIndexValue] + "=" + elapsed
        end if
        stageIndexValue = stageIndexValue + 1
      end while
      print line
    end if
    index = index + 1
  end while
  return true
end function

/// Handle sequence text and update the associated state.
/// @param values The values input consumed by `handleSequenceText`.
function handleSequenceText(values)
  result = ""
  index = 0
  while index < len(values)
    if index > 0 then result = result + "," end if
    result = result + values[index]
    index = index + 1
  end while
  return result
end function

/// Implements the `classifyHandles` operation for `miniquake.optimization_baseline` (classify handles).
/// @param handles The handles input consumed by `classifyHandles`.
/// @param nonHandleStable The non handle stable input consumed by `classifyHandles`.
function classifyHandles(handles, nonHandleStable)
  if not nonHandleStable then return "RESOURCE_GROWTH" end if
  if len(handles) < 2 then return "INCONCLUSIVE" end if

  allEqual = true
  index = 1
  while index < len(handles)
    if handles[index] != handles[0] then allEqual = false end if
    index = index + 1
  end while
  if allEqual then return "STABLE" end if

  if len(handles) >= 3 then
    tail = len(handles) - 1
    nonDecreasing = true
    minimum = handles[0]
    maximum = handles[0]
    index = 1
    while index < len(handles)
      if handles[index] < handles[index - 1] then nonDecreasing = false end if
      if handles[index] < minimum then minimum = handles[index] end if
      if handles[index] > maximum then maximum = handles[index] end if
      index = index + 1
    end while
    // A single delayed +1 handle after warm-up is a one-time initialization
    // when the final two windows are stable.  Continued growth is still a leak.
    if nonDecreasing and maximum - minimum <= 1 and handles[tail] == handles[tail - 1] then
      return "PLATEAU"
    end if
    if len(handles) >= 4 and handles[tail] == handles[tail - 1] and handles[tail - 1] == handles[tail - 2] then
      return "PLATEAU"
    end if
  end if

  strictlyIncreasing = true
  index = 1
  while index < len(handles)
    if handles[index] <= handles[index - 1] then strictlyIncreasing = false end if
    index = index + 1
  end while
  if strictlyIncreasing then return "LEAK" end if
  return "INCONCLUSIVE"
end function
