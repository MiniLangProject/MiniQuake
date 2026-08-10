/*
Copyright (C) 2026 MiniQuake contributors

OPT-001A diagnostics only.  The module is disabled during normal gameplay.
When enabled explicitly by the OPT-001A commands it records frame durations
and checkpoint-to-checkpoint stage times in fixed arrays.
*/

package miniquake.optimization_baseline

import miniquake.native as native
import std.fs as fs

const STAGE_COUNT = 20

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
]

profileEnabled = false
profileCapacity = 0
profileFrameCount = 0
profileFrameStart = 0
profileLastTick = 0
profileFrameActive = false
profileDurations = []
profileStageTotals = array(STAGE_COUNT, 0)
profileStageHits = array(STAGE_COUNT, 0)

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function enabled()
  return profileEnabled
end function

function normalizeStage(stage)
  if stage == "demo_send" or stage == "local_send" or stage == "remote_send" then
    return "send"
  end if
  return stage
end function

function stageIndex(stage)
  target = normalizeStage(stage)
  index = 0
  while index < len(stageNames)
    if stageNames[index] == target then return index end if
    index = index + 1
  end while
  return STAGE_COUNT - 1
end function

function configure(frameCapacity)
  global profileEnabled, profileCapacity, profileFrameCount
  global profileFrameStart, profileLastTick, profileFrameActive
  global profileDurations, profileStageTotals, profileStageHits

  if frameCapacity < 1 then frameCapacity = 1 end if
  profileCapacity = frameCapacity
  profileFrameCount = 0
  profileFrameStart = 0
  profileLastTick = 0
  profileFrameActive = false
  profileDurations = array(frameCapacity, 0)
  profileStageTotals = array(STAGE_COUNT, 0)
  profileStageHits = array(STAGE_COUNT, 0)
  profileEnabled = true
  return true
end function

function disable()
  global profileEnabled, profileFrameActive
  profileEnabled = false
  profileFrameActive = false
  return true
end function

function beginFrame()
  global profileFrameStart, profileLastTick, profileFrameActive
  if not profileEnabled then return true end if
  now = native.winTicks()
  profileFrameStart = now
  profileLastTick = now
  profileFrameActive = true
  return true
end function

function checkpoint(stage)
  global profileLastTick, profileStageTotals, profileStageHits
  if not profileEnabled or not profileFrameActive then return true end if
  now = native.winTicks()
  index = stageIndex(stage)
  profileStageTotals[index] = profileStageTotals[index] + (now - profileLastTick)
  profileStageHits[index] = profileStageHits[index] + 1
  profileLastTick = now
  return true
end function

function filteredFrame()
  global profileFrameActive
  if not profileEnabled then return true end if
  profileFrameActive = false
  return true
end function

function completeFrame()
  global profileFrameCount, profileFrameActive, profileDurations
  global profileLastTick, profileStageTotals, profileStageHits

  if not profileEnabled or not profileFrameActive then return true end if
  now = native.winTicks()
  remainder = now - profileLastTick
  profileStageTotals[STAGE_COUNT - 1] = profileStageTotals[STAGE_COUNT - 1] + remainder
  profileStageHits[STAGE_COUNT - 1] = profileStageHits[STAGE_COUNT - 1] + 1
  if profileFrameCount < profileCapacity then
    profileDurations[profileFrameCount] = now - profileFrameStart
    profileFrameCount = profileFrameCount + 1
  end if
  profileFrameActive = false
  return true
end function

function recordedFrames()
  return profileFrameCount
end function

function sortedDurations()
  count = profileFrameCount
  values = array(count, 0)
  index = 0
  while index < count
    values[index] = profileDurations[index]
    index = index + 1
  end while

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

function percentileFromSorted(values, numerator, denominator)
  count = len(values)
  if count == 0 then return 0 end if
  index = native.trunc(((count - 1) * numerator) / denominator)
  if index < 0 then index = 0 end if
  if index >= count then index = count - 1 end if
  return values[index]
end function

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

function writeReports(prefix, mode, mapName, beforeResources, afterResources)
  stats = summary()

  csv = "frame,duration_ms\n"
  index = 0
  while index < profileFrameCount
    csv = csv + index + "," + profileDurations[index] + "\n"
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
