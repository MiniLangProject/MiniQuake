/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Deterministic black-port diagnostics.  This module deliberately depends only
on stable engine state and std.fs; it does not import the host module, so the
host can call checkpoint() without creating an import cycle.
*/

package miniquake.compat_diagnostics

import miniquake.build_info as buildInfo
import miniquake.types as t
import miniquake.native as native
import miniquake.optimization_baseline as optBaseline
import std.fs as fs

const CONTEXT_SCHEMA = 1

function boolText(value)
  if value then return "true" end if
  return "false"
end function

function u32Hex(value)
  masked = value & 0xffffffff
  return hex(bytes([
    (masked >> 24) & 255,
    (masked >> 16) & 255,
    (masked >> 8) & 255,
    masked & 255,
  ]))
end function

function f32Hex(value)
  return u32Hex(native.floatBits(value))
end function

function jsonEscape(text)
  source = bytes(text)
  result = ""
  index = 0
  while index < len(source)
    value = source[index]
    if value == 34 then
      result = result + "\\\""
    else if value == 92 then
      result = result + "\\\\"
    else if value == 8 then
      result = result + "\\b"
    else if value == 9 then
      result = result + "\\t"
    else if value == 10 then
      result = result + "\\n"
    else if value == 12 then
      result = result + "\\f"
    else if value == 13 then
      result = result + "\\r"
    else if value < 32 or value > 126 then
      result = result + "\\u00" + hex(bytes([value]))
    else
      result = result + decode(bytes([value]))
    end if
    index = index + 1
  end while
  return result
end function

function jsonString(text)
  return "\"" + jsonEscape(text) + "\""
end function

function vecJson(value)
  kind = typeName(value)
  if not t.isVec3Value(value) then return error(9300, "diagnostic vector expected Vec3, got " + kind) end if
  // Read all scalar components before allocating the JSON string.  The native
  // MiniLang backend may collect while concatenating; keeping the source Vec3
  // and its scalar values in named locals prevents a nested-field lifetime from
  // depending on expression evaluation order.
  x = value.x
  y = value.y
  z = value.z
  result = "{\"x_f32\":\"" + f32Hex(x)
  result = result + "\",\"y_f32\":\"" + f32Hex(y)
  result = result + "\",\"z_f32\":\"" + f32Hex(z) + "\"}"
  return result
end function

function stageText(stages)
  result = ""
  index = 0
  while index < len(stages)
    if index > 0 then result = result + "," end if
    result = result + stages[index]
    index = index + 1
  end while
  return result
end function

function stageJson(stages)
  result = "["
  index = 0
  while index < len(stages)
    if index > 0 then result = result + "," end if
    result = result + jsonString(stages[index])
    index = index + 1
  end while
  return result + "]"
end function

function activeServerClients(session)
  count = 0
  for each item in session.server.clients
    if item.active then count = count + 1 end if
  end for
  return count
end function

function activeEdicts(session)
  count = 0
  limit = session.server.numEdicts
  if limit > len(session.server.edicts) then limit = len(session.server.edicts) end if
  index = 0
  while index < limit
    if not session.server.edicts[index].free then count = count + 1 end if
    index = index + 1
  end while
  return count
end function

function qcFunctionName(session)
  machine = session.server.machine
  if machine is void then return "" end if
  if machine.program is void then return "" end if
  index = machine.currentFunction
  if index < 0 or index >= len(machine.program.functions) then return "" end if
  return machine.program.functions[index].name
end function

function qcStatement(session)
  machine = session.server.machine
  if machine is void then return -1 end if
  return machine.statement
end function

function qcCallDepth(session)
  machine = session.server.machine
  if machine is void then return 0 end if
  return len(machine.callStack)
end function

function lastStage(session)
  if session.diagnosticLastStage != "" then return session.diagnosticLastStage end if
  if len(session.frameTrace) == 0 then return "before_filter" end if
  return session.frameTrace[len(session.frameTrace) - 1]
end function

// The MiniLang Win64 backend reserves a bounded expression-temporary area.
// Keep serialized records as short, ordered appends instead of one very deep
// binary + tree. This preserves the BP-001 byte format while compiling safely.
function hostContextJson(session)
  result = "{"
  result = result + "\"frame_count\":" + session.timing.frameCount + ","
  result = result + "\"simulated_frames\":" + session.simulatedFrames + ","
  result = result + "\"realtime_f32\":\"" + f32Hex(session.timing.realtime) + "\","
  result = result + "\"frametime_f32\":\"" + f32Hex(session.timing.frameTime) + "\","
  result = result + "\"host_time_f32\":\"" + f32Hex(session.hostTime) + "\""
  return result + "}"
end function

function serverContextJson(session)
  result = "{"
  result = result + "\"active\":" + boolText(session.server.active) + ","
  result = result + "\"paused\":" + boolText(session.server.paused) + ","
  result = result + "\"time_f32\":\"" + f32Hex(session.server.time) + "\","
  result = result + "\"num_edicts\":" + session.server.numEdicts + ","
  result = result + "\"active_edicts\":" + activeEdicts(session) + ","
  result = result + "\"active_clients\":" + activeServerClients(session) + ","
  result = result + "\"random_seed_u32\":\"" + u32Hex(session.server.randomSeed) + "\""
  return result + "}"
end function

function clientContextJson(session)
  result = "{"
  result = result + "\"connected\":" + boolText(session.client.connected) + ","
  result = result + "\"signon\":" + session.client.signon + ","
  result = result + "\"spawned\":" + boolText(session.client.spawned) + ","
  result = result + "\"view_entity\":" + session.client.viewEntity + ","
  result = result + "\"time_f32\":\"" + f32Hex(session.client.time) + "\","
  result = result + "\"server_time_f32\":\"" + f32Hex(session.client.serverTime) + "\","
  result = result + "\"entities\":" + len(session.client.entities)
  return result + "}"
end function

function playerContextJson(session)
  result = "{"
  result = result + "\"origin\":" + vecJson(session.player.origin) + ","
  result = result + "\"velocity\":" + vecJson(session.player.velocity) + ","
  result = result + "\"angles\":" + vecJson(session.player.viewAngles) + ","
  result = result + "\"health_f32\":\"" + f32Hex(session.player.health) + "\","
  result = result + "\"flags\":" + session.player.flags + ","
  result = result + "\"movetype\":" + session.player.moveType + ","
  result = result + "\"waterlevel\":" + session.player.waterLevel + ","
  result = result + "\"ground_entity\":" + session.player.groundEntity
  return result + "}"
end function

function quakeCContextJson(session)
  result = "{"
  result = result + "\"function\":" + jsonString(qcFunctionName(session)) + ","
  result = result + "\"statement\":" + qcStatement(session) + ","
  result = result + "\"call_depth\":" + qcCallDepth(session)
  return result + "}"
end function

function contextJson(session, phase, errorText)
  result = "{"
  result = result + "\"schema\":\"MiniQuakeCrashContext/" + CONTEXT_SCHEMA + "\","
  result = result + "\"package\":" + jsonString(buildInfo.PACKAGE_ID) + ","
  result = result + "\"profile\":" + jsonString(buildInfo.COMPATIBILITY_PROFILE) + ","
  result = result + "\"phase\":" + jsonString(phase) + ","
  result = result + "\"frame\":" + session.diagnosticFrame + ","
  result = result + "\"last_completed_stage\":" + jsonString(lastStage(session)) + ","
  result = result + "\"frame_stages\":" + stageJson(session.frameTrace) + ","
  result = result + "\"error\":" + jsonString(errorText) + ","
  result = result + "\"map\":" + jsonString(session.server.mapName) + ","
  result = result + "\"host\":" + hostContextJson(session) + ","
  result = result + "\"server\":" + serverContextJson(session) + ","
  result = result + "\"client\":" + clientContextJson(session) + ","
  result = result + "\"player\":" + playerContextJson(session) + ","
  result = result + "\"quakec\":" + quakeCContextJson(session) + ","
  result = result + "\"diagnostic_write_error\":" + jsonString(session.diagnosticWriteError)
  return result + "}\n"
end function

function persist(session, phase, errorText)
  if session.diagnosticContextPath == "" then return true end if
  written = try(fs.writeAllText(session.diagnosticContextPath, contextJson(session, phase, errorText)))
  if written is error then
    session.diagnosticWriteError = written.message
    session.diagnosticContextPath = ""
    return false
  end if
  return true
end function

function inline stageTraceEnabled(session)
  // Headless sessions are also the deterministic diagnostics/test path.  Keep
  // their historical frame-stage contract, while the interactive renderer
  // avoids allocating a new trace array at every checkpoint.
  return session.diagnosticContextPath != "" or session.headless
end function

function beginFrame(session)
  optBaseline.beginFrame()
  if not stageTraceEnabled(session) then return true end if
  session.frameTrace = []
  session.diagnosticLastStage = "before_filter"
  if session.diagnosticContextPath == "" then return true end if
  return persist(session, "before_frame", "")
end function

function checkpoint(session, stage)
  optBaseline.checkpoint(stage)
  session.diagnosticLastStage = stage
  if stageTraceEnabled(session) then
    session.frameTrace = session.frameTrace + [stage]
  end if
  if session.diagnosticContextPath != "" then
    persist(session, "in_frame", "")
  end if
  return true
end function

function filteredFrame(session)
  optBaseline.filteredFrame()
  session.diagnosticLastStage = "filtered"
  if session.diagnosticContextPath != "" then persist(session, "filtered", "") end if
  return true
end function

function completeFrame(session)
  optBaseline.completeFrame()
  session.diagnosticLastStage = "complete"
  if session.diagnosticContextPath != "" then persist(session, "frame_complete", "") end if
  return true
end function

function postFrameStage(session, stage)
  session.diagnosticLastStage = stage
  if session.diagnosticContextPath != "" then persist(session, "post_frame", "") end if
  return true
end function

function failFrame(session, message)
  if session.diagnosticContextPath != "" then persist(session, "frame_error", message) end if
  return true
end function
