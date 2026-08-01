/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Demo/savegame compatibility evidence helpers.  The actual retail evidence is
executed from a separate test executable so no user game data enters builds or
result archives.
*/

package miniquake.artifact_compat

import miniquake.crc as crc
import miniquake.native as native

const STATUS = "artifact_compat_109_frozen_v1"
const FINGERPRINT = 0x59531091
const CONTRACT_TEXT = "artifact-compat|demo-protocol15|retail-demos=3|save-version=5|save-roundtrip|deterministic-evidence"
const SAVEGAME_VERSION = 5
const RETAIL_DEMO_COUNT = 3
const SAVE_FLOAT_FORMAT = "msvcrt_percent_f"

function retailDemoNames()
  return ["demo1.dem", "demo2.dem", "demo3.dem"]
end function

function bytesEqual(left, right)
  if left is not bytes or right is not bytes or len(left) != len(right) then return false end if
  index = 0
  while index < len(left)
    if left[index] != right[index] then return false end if
    index = index + 1
  end while
  return true
end function

function bytesCrc(data)
  if data is not bytes then return -1 end if
  return crc.block(data, 0, len(data))
end function

// A Quake version-5 savegame is a deliberately lossy text snapshot.  Runtime
// floats are written with six decimals and only DEF_SAVEGLOBAL globals are
// archived.  Compare the parsed save-domain state instead of the complete live
// VM state, which also contains transient globals that the original format does
// not preserve.
function pairListDifference(leftPairs, rightPairs, label)
  if len(leftPairs) != len(rightPairs) then
    return label + " pair count: " + len(leftPairs) + " != " + len(rightPairs)
  end if
  index = 0
  while index < len(leftPairs)
    leftPair = leftPairs[index]
    rightPair = rightPairs[index]
    if leftPair.key != rightPair.key then
      return label + " pair " + index + " key: " + leftPair.key + " != " + rightPair.key
    end if
    if leftPair.value != rightPair.value then
      return label + " pair " + index + " value for " + leftPair.key
    end if
    index = index + 1
  end while
  return ""
end function

function saveSemanticDifference(left, right)
  if left.version != right.version then return "version" end if
  if left.comment != right.comment then return "comment" end if
  if len(left.spawnParms) != len(right.spawnParms) then return "spawn parm count" end if
  index = 0
  while index < len(left.spawnParms)
    if native.floatBits(left.spawnParms[index]) != native.floatBits(right.spawnParms[index]) then
      return "spawn parm " + index
    end if
    index = index + 1
  end while
  if left.skill != right.skill then return "skill" end if
  if left.mapName != right.mapName then return "map name" end if
  if native.floatBits(left.time) != native.floatBits(right.time) then return "server time" end if
  if len(left.lightStyles) != len(right.lightStyles) then return "lightstyle count" end if
  index = 0
  while index < len(left.lightStyles)
    if left.lightStyles[index] != right.lightStyles[index] then return "lightstyle " + index end if
    index = index + 1
  end while
  difference = pairListDifference(left.globalState.pairs, right.globalState.pairs, "globals")
  if difference != "" then return difference end if
  if len(left.entities) != len(right.entities) then return "entity count" end if
  index = 0
  while index < len(left.entities)
    difference = pairListDifference(left.entities[index].pairs, right.entities[index].pairs, "entity " + index)
    if difference != "" then return difference end if
    index = index + 1
  end while
  return ""
end function

function saveSemanticEqual(left, right)
  return saveSemanticDifference(left, right) == ""
end function

// Return [first differing offset, left byte, right byte, left length, right
// length].  Byte values are -1 when the corresponding stream ended first.
function firstByteDifference(left, right)
  if left is not bytes or right is not bytes then return [-2, -1, -1, 0, 0] end if
  limit = len(left)
  if len(right) < limit then limit = len(right) end if
  index = 0
  while index < limit
    if left[index] != right[index] then return [index, left[index], right[index], len(left), len(right)] end if
    index = index + 1
  end while
  if len(left) == len(right) then return [-1, -1, -1, len(left), len(right)] end if
  leftValue = -1
  rightValue = -1
  if index < len(left) then leftValue = left[index] end if
  if index < len(right) then rightValue = right[index] end if
  return [index, leftValue, rightValue, len(left), len(right)]
end function

function demoSummary(recording, report, sourceBytes)
  return [
    recording.forcedTrack,
    len(recording.messages),
    report.ok,
    report.eventCount,
    report.payloadBytes,
    report.signon,
    report.entities,
    len(sourceBytes),
    bytesCrc(sourceBytes),
  ]
end function

function saveSummary(saveBytes, mapName, timeValue, edictHash, globalsHash)
  return [SAVEGAME_VERSION, mapName, timeValue, len(saveBytes), bytesCrc(saveBytes), edictHash, globalsHash]
end function

function contractVector()
  return [STATUS, FINGERPRINT, SAVEGAME_VERSION, RETAIL_DEMO_COUNT, retailDemoNames(), SAVE_FLOAT_FORMAT]
end function
