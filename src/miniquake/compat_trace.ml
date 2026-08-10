/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Deterministic compatibility traces and state snapshots for the source-guided
black-port workflow.  The .mqtrace stream intentionally excludes heap addresses,
wall-clock timestamps and output paths so two identical runs are byte-identical.
*/

package miniquake.compat_trace

import miniquake.types as t
import miniquake.build_info as buildInfo
import miniquake.host as host
import miniquake.compat_diagnostics as diagnostics
import miniquake.native as native
import std.fs as fs

const TRACE_SCHEMA = 1
const FNV_OFFSET = 2166136261
const FNV_PRIME = 16777619

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function safeText(value)
  if value is string then return value end if
  return ""
end function

function qcFunctionIndex(session)
  if session.server.machine is void then return -1 end if
  return session.server.machine.currentFunction
end function

function inline hashByte(state, value)
  return (((state & 0xffffffff) ^ (value & 255)) * FNV_PRIME) & 0xffffffff
end function

function hashWord(state, value)
  word = value & 0xffffffff
  result = hashByte(state, word)
  result = hashByte(result, word >> 8)
  result = hashByte(result, word >> 16)
  result = hashByte(result, word >> 24)
  return result
end function

function hashFloat(state, value)
  return hashWord(state, native.floatBits(value))
end function

function vec3Error(label, value)
  return error(9301, label + " expected Vec3, got " + typeName(value))
end function

// Hash a Vec3 without keeping a heap object only inside a nested call
// expression.  This is deliberately allocation-free after the type check.
function hashVec3(state, value, label)
  if not t.isVec3Value(value) then return vec3Error(label, value) end if
  x = value.x
  y = value.y
  z = value.z
  result = hashFloat(state, x)
  result = hashFloat(result, y)
  result = hashFloat(result, z)
  return result
end function

function vec3Hex(value, label)
  if not t.isVec3Value(value) then return vec3Error(label, value) end if
  x = value.x
  y = value.y
  z = value.z
  result = diagnostics.f32Hex(x)
  result = result + "," + diagnostics.f32Hex(y)
  result = result + "," + diagnostics.f32Hex(z)
  return result
end function

function hashTextSeed(state, text)
  source = bytes(text)
  result = state & 0xffffffff
  index = 0
  while index < len(source)
    result = hashByte(result, source[index])
    index = index + 1
  end while
  return result
end function

function hashText(text)
  return hashTextSeed(FNV_OFFSET, text)
end function

function hashWordArray(words)
  result = FNV_OFFSET
  index = 0
  while index < len(words)
    result = hashWord(result, words[index])
    index = index + 1
  end while
  return result
end function

function hashSizeBuffer(state, buffer)
  result = hashWord(state, buffer.curSize)
  limit = buffer.curSize
  if limit < 0 then limit = 0 end if
  if limit > len(buffer.data) then limit = len(buffer.data) end if
  index = 0
  while index < limit
    result = hashByte(result, buffer.data[index])
    index = index + 1
  end while
  return result
end function

function globalsHash(session)
  machine = session.server.machine
  if machine is void then return 0 end if
  return hashWordArray(machine.globals)
end function

function qcEdictsHash(session)
  machine = session.server.machine
  if machine is void then return 0 end if
  limit = session.server.numEdicts
  if limit > len(machine.edicts) then limit = len(machine.edicts) end if
  result = FNV_OFFSET
  index = 0
  while index < limit
    result = hashWord(result, index)
    freeValue = 1
    if index < len(machine.edictFree) and not machine.edictFree[index] then freeValue = 0 end if
    result = hashByte(result, freeValue)
    if freeValue == 0 then
      words = machine.edicts[index]
      wordIndex = 0
      while wordIndex < len(words)
        result = hashWord(result, words[wordIndex])
        wordIndex = wordIndex + 1
      end while
    end if
    index = index + 1
  end while
  return result
end function

function serverEdictsHash(session)
  limit = session.server.numEdicts
  if limit > len(session.server.edicts) then limit = len(session.server.edicts) end if
  result = FNV_OFFSET
  index = 0
  while index < limit
    item = session.server.edicts[index]
    if item is void then return error(9302, "server edict " + index + " is void") end if
    // Root the nested vectors before hashing strings or performing any other
    // operation that may allocate.  QuakeC synchronization rebuilds this table
    // every frame, so these are the most allocation-sensitive diagnostics.
    origin = item.origin
    angles = item.angles
    velocity = item.velocity
    result = hashWord(result, item.number)
    result = hashByte(result, boolNumber(item.free))
    if not item.free then
      result = hashTextSeed(result, safeText(item.className))
      result = hashTextSeed(result, safeText(item.model))
      result = hashWord(result, item.modelIndex)
      result = hashWord(result, item.frame)
      result = hashWord(result, item.skin)
      result = hashWord(result, item.colormap)
      result = hashWord(result, item.effects)
      result = hashVec3(result, origin, "server edict " + index + " origin")
      result = hashVec3(result, angles, "server edict " + index + " angles")
      result = hashVec3(result, velocity, "server edict " + index + " velocity")
      result = hashWord(result, item.moveType)
      result = hashWord(result, item.solid)
      result = hashWord(result, item.flags)
      result = hashFloat(result, item.health)
      result = hashWord(result, item.groundEntity)
    end if
    index = index + 1
  end while
  return result
end function

// cl.entities is intentionally sparse.  SV_CreateBaseline omits non-model
// entities, while CL_EntityNum grows the array with void slots up to the next
// transmitted entity number.  Hash both the slot topology and the populated
// records without dereferencing void.
function clientEntitiesHash(session)
  result = hashWord(FNV_OFFSET, len(session.client.entities))
  index = 0
  while index < len(session.client.entities)
    result = hashWord(result, index)
    item = session.client.entities[index]
    if item is void then
      result = hashByte(result, 0)
    else
      origin = item.origin
      angles = item.angles
      result = hashByte(result, 1)
      result = hashWord(result, item.number)
      result = hashWord(result, item.modelIndex)
      result = hashWord(result, item.frame)
      result = hashWord(result, item.colormap)
      result = hashWord(result, item.skin)
      result = hashWord(result, item.effects)
      result = hashVec3(result, origin, "client entity slot " + index + " origin")
      result = hashVec3(result, angles, "client entity slot " + index + " angles")
      result = hashFloat(result, item.syncBase)
    end if
    index = index + 1
  end while
  return result
end function

function protocolHash(session)
  result = FNV_OFFSET
  result = hashSizeBuffer(result, session.server.datagram)
  result = hashSizeBuffer(result, session.server.reliableDatagram)
  result = hashSizeBuffer(result, session.server.signon)
  for each item in session.server.clients
    if item.active then result = hashSizeBuffer(result, item.message) end if
  end for
  result = hashSizeBuffer(result, session.client.outgoing)
  result = hashSizeBuffer(result, session.client.incoming)
  return result
end function

function stagesHash(session)
  result = FNV_OFFSET
  for each stage in session.frameTrace
    result = hashTextSeed(result, stage)
    result = hashByte(result, 0)
  end for
  return result
end function

// BP-001 originally expressed the complete frame as one deeply nested + tree.
// The Win64 backend has a bounded expression-temporary area, so keep every
// canonical field in the same order but append it in compiler-safe statements.
function canonicalFrame(session, frameIndex, accepted)
  // Capture every nested/vector value and every allocation-sensitive digest
  // before the first long string concatenation.  The canonical formatter is a
  // diagnostics client, not an owner of engine state; its allocation pattern
  // must never determine whether a freshly synchronized edict vector remains
  // reachable.
  playerOrigin = vec3Hex(session.player.origin, "player origin")
  playerVelocity = vec3Hex(session.player.velocity, "player velocity")
  playerAngles = vec3Hex(session.player.viewAngles, "player view angles")
  globalsDigest = globalsHash(session)
  qcEdictsDigest = qcEdictsHash(session)
  serverEdictsDigest = serverEdictsHash(session)
  clientEntitiesDigest = clientEntitiesHash(session)
  protocolDigest = protocolHash(session)
  stagesDigest = stagesHash(session)

  result = "frame=" + frameIndex
  result = result + "|accepted=" + boolNumber(accepted)
  result = result + "|host_frame=" + session.timing.frameCount
  result = result + "|simulated=" + session.simulatedFrames
  result = result + "|realtime=" + diagnostics.f32Hex(session.timing.realtime)
  result = result + "|frametime=" + diagnostics.f32Hex(session.timing.frameTime)
  result = result + "|hosttime=" + diagnostics.f32Hex(session.hostTime)
  result = result + "|server_active=" + boolNumber(session.server.active)
  result = result + "|server_paused=" + boolNumber(session.server.paused)
  result = result + "|server_time=" + diagnostics.f32Hex(session.server.time)
  result = result + "|map_hex=" + hex(bytes(session.server.mapName))
  result = result + "|random=" + diagnostics.u32Hex(session.server.randomSeed)
  result = result + "|num_edicts=" + session.server.numEdicts
  result = result + "|active_edicts=" + diagnostics.activeEdicts(session)
  result = result + "|active_clients=" + diagnostics.activeServerClients(session)
  result = result + "|client_connected=" + boolNumber(session.client.connected)
  result = result + "|signon=" + session.client.signon
  result = result + "|spawned=" + boolNumber(session.client.spawned)
  result = result + "|view_entity=" + session.client.viewEntity
  result = result + "|client_time=" + diagnostics.f32Hex(session.client.time)
  result = result + "|server_message_time=" + diagnostics.f32Hex(session.client.serverTime)
  result = result + "|player_origin=" + playerOrigin
  result = result + "|player_velocity=" + playerVelocity
  result = result + "|player_angles=" + playerAngles
  result = result + "|health=" + diagnostics.f32Hex(session.player.health)
  result = result + "|flags=" + session.player.flags
  result = result + "|movetype=" + session.player.moveType
  result = result + "|waterlevel=" + session.player.waterLevel
  result = result + "|ground=" + session.player.groundEntity
  result = result + "|items=" + session.player.items
  result = result + "|weapon=" + session.player.activeWeapon
  result = result + "|qc_function=" + qcFunctionIndex(session)
  result = result + "|qc_statement=" + diagnostics.qcStatement(session)
  result = result + "|qc_depth=" + diagnostics.qcCallDepth(session)
  result = result + "|qc_globals=" + diagnostics.u32Hex(globalsDigest)
  result = result + "|qc_edicts=" + diagnostics.u32Hex(qcEdictsDigest)
  result = result + "|server_edicts=" + diagnostics.u32Hex(serverEdictsDigest)
  result = result + "|client_entities=" + diagnostics.u32Hex(clientEntitiesDigest)
  result = result + "|protocol=" + diagnostics.u32Hex(protocolDigest)
  result = result + "|stages=" + diagnostics.u32Hex(stagesDigest)
  return result
end function

function traceLine(session, frameIndex, accepted)
  canonical = canonicalFrame(session, frameIndex, accepted)
  return canonical + "|state_hash=" + diagnostics.u32Hex(hashText(canonical)) + "\n"
end function

function rawEdictHash(session, index)
  machine = session.server.machine
  if machine is void or index < 0 or index >= len(machine.edicts) then return 0 end if
  return hashWordArray(machine.edicts[index])
end function

function edictJson(session, index, item)
  result = "{"
  result = result + "\"number\":" + item.number + ","
  result = result + "\"free\":" + diagnostics.boolText(item.free) + ","
  result = result + "\"class\":" + diagnostics.jsonString(safeText(item.className)) + ","
  result = result + "\"model\":" + diagnostics.jsonString(safeText(item.model)) + ","
  result = result + "\"model_index\":" + item.modelIndex + ","
  result = result + "\"frame\":" + item.frame + ","
  result = result + "\"skin\":" + item.skin + ","
  result = result + "\"effects\":" + item.effects + ","
  result = result + "\"origin\":" + diagnostics.vecJson(item.origin) + ","
  result = result + "\"angles\":" + diagnostics.vecJson(item.angles) + ","
  result = result + "\"velocity\":" + diagnostics.vecJson(item.velocity) + ","
  result = result + "\"movetype\":" + item.moveType + ","
  result = result + "\"solid\":" + item.solid + ","
  result = result + "\"flags\":" + item.flags + ","
  result = result + "\"health_f32\":\"" + diagnostics.f32Hex(item.health) + "\","
  result = result + "\"ground_entity\":" + item.groundEntity + ","
  result = result + "\"qc_words_hash\":\"" + diagnostics.u32Hex(rawEdictHash(session, index)) + "\""
  return result + "}"
end function

function edictsJson(session)
  limit = session.server.numEdicts
  if limit > len(session.server.edicts) then limit = len(session.server.edicts) end if
  result = "["
  index = 0
  while index < limit
    if index > 0 then result = result + "," end if
    item = session.server.edicts[index]
    result = result + edictJson(session, index, item)
    index = index + 1
  end while
  return result + "]"
end function

function clientEntityJson(item)
  result = "{"
  result = result + "\"number\":" + item.number + ","
  result = result + "\"model_index\":" + item.modelIndex + ","
  result = result + "\"frame\":" + item.frame + ","
  result = result + "\"skin\":" + item.skin + ","
  result = result + "\"effects\":" + item.effects + ","
  result = result + "\"origin\":" + diagnostics.vecJson(item.origin) + ","
  result = result + "\"angles\":" + diagnostics.vecJson(item.angles) + ","
  result = result + "\"sync_base_f32\":\"" + diagnostics.f32Hex(item.syncBase) + "\""
  return result + "}"
end function

function clientEntitiesJson(session)
  result = "["
  index = 0
  while index < len(session.client.entities)
    if index > 0 then result = result + "," end if
    item = session.client.entities[index]
    if item is void then
      // Preserve the entity number-to-array-index relationship in snapshots.
      result = result + "null"
    else
      result = result + clientEntityJson(item)
    end if
    index = index + 1
  end while
  return result + "]"
end function

function resourceJson(session)
  values = host.resourceSnapshot(session)
  result = "{"
  result = result + "\"heap_live\":" + values[0] + ","
  result = result + "\"heap_high_water\":" + values[1] + ","
  result = result + "\"heap_live_bytes\":" + values[2] + ","
  result = result + "\"heap_free_bytes\":" + values[3] + ","
  result = result + "\"edicts\":" + values[4] + ","
  result = result + "\"client_entities\":" + values[5] + ","
  result = result + "\"active_clients\":" + values[6] + ","
  result = result + "\"active_qsockets\":" + values[7] + ","
  result = result + "\"free_qsockets\":" + values[8] + ","
  result = result + "\"queued_messages\":" + values[9] + ","
  result = result + "\"queued_bytes\":" + values[10] + ","
  result = result + "\"poll_procedures\":" + values[11] + ","
  result = result + "\"udp_endpoints\":" + values[12] + ","
  result = result + "\"audio_queued\":" + values[13] + ","
  result = result + "\"audio_channels\":" + values[14] + ","
  result = result + "\"process_handles\":" + values[15] + ","
  result = result + "\"particles\":" + values[16] + ","
  result = result + "\"temporary_entities\":" + values[17]
  return result + "}"
end function

function snapshotHostJson(session)
  result = "{"
  result = result + "\"frame_count\":" + session.timing.frameCount + ","
  result = result + "\"simulated_frames\":" + session.simulatedFrames + ","
  result = result + "\"realtime_f32\":\"" + diagnostics.f32Hex(session.timing.realtime) + "\","
  result = result + "\"frametime_f32\":\"" + diagnostics.f32Hex(session.timing.frameTime) + "\","
  result = result + "\"host_time_f32\":\"" + diagnostics.f32Hex(session.hostTime) + "\""
  return result + "}"
end function

function snapshotServerJson(session)
  result = "{"
  result = result + "\"active\":" + diagnostics.boolText(session.server.active) + ","
  result = result + "\"paused\":" + diagnostics.boolText(session.server.paused) + ","
  result = result + "\"time_f32\":\"" + diagnostics.f32Hex(session.server.time) + "\","
  result = result + "\"random_seed_u32\":\"" + diagnostics.u32Hex(session.server.randomSeed) + "\","
  result = result + "\"num_edicts\":" + session.server.numEdicts + ","
  result = result + "\"active_edicts\":" + diagnostics.activeEdicts(session) + ","
  result = result + "\"active_clients\":" + diagnostics.activeServerClients(session)
  return result + "}"
end function

function snapshotClientJson(session)
  result = "{"
  result = result + "\"connected\":" + diagnostics.boolText(session.client.connected) + ","
  result = result + "\"signon\":" + session.client.signon + ","
  result = result + "\"spawned\":" + diagnostics.boolText(session.client.spawned) + ","
  result = result + "\"view_entity\":" + session.client.viewEntity + ","
  result = result + "\"time_f32\":\"" + diagnostics.f32Hex(session.client.time) + "\","
  result = result + "\"server_time_f32\":\"" + diagnostics.f32Hex(session.client.serverTime) + "\""
  return result + "}"
end function

function snapshotPlayerJson(session)
  result = "{"
  result = result + "\"origin\":" + diagnostics.vecJson(session.player.origin) + ","
  result = result + "\"velocity\":" + diagnostics.vecJson(session.player.velocity) + ","
  result = result + "\"view_angles\":" + diagnostics.vecJson(session.player.viewAngles) + ","
  result = result + "\"render_angles\":" + diagnostics.vecJson(session.player.renderAngles) + ","
  result = result + "\"health_f32\":\"" + diagnostics.f32Hex(session.player.health) + "\","
  result = result + "\"armor_f32\":\"" + diagnostics.f32Hex(session.player.armor) + "\","
  result = result + "\"flags\":" + session.player.flags + ","
  result = result + "\"movetype\":" + session.player.moveType + ","
  result = result + "\"waterlevel\":" + session.player.waterLevel + ","
  result = result + "\"ground_entity\":" + session.player.groundEntity + ","
  result = result + "\"items\":" + session.player.items + ","
  result = result + "\"active_weapon\":" + session.player.activeWeapon
  return result + "}"
end function

function snapshotQuakeCJson(session)
  result = "{"
  result = result + "\"function\":" + diagnostics.jsonString(diagnostics.qcFunctionName(session)) + ","
  result = result + "\"function_index\":" + qcFunctionIndex(session) + ","
  result = result + "\"statement\":" + diagnostics.qcStatement(session) + ","
  result = result + "\"call_depth\":" + diagnostics.qcCallDepth(session) + ","
  result = result + "\"globals_hash\":\"" + diagnostics.u32Hex(globalsHash(session)) + "\","
  result = result + "\"edicts_hash\":\"" + diagnostics.u32Hex(qcEdictsHash(session)) + "\""
  return result + "}"
end function

function snapshotDigestsJson(session)
  result = "{"
  result = result + "\"server_edicts\":\"" + diagnostics.u32Hex(serverEdictsHash(session)) + "\","
  result = result + "\"client_entities\":\"" + diagnostics.u32Hex(clientEntitiesHash(session)) + "\","
  result = result + "\"protocol\":\"" + diagnostics.u32Hex(protocolHash(session)) + "\""
  return result + "}"
end function

function snapshotJson(session, frameIndex, phase, errorText)
  canonical = canonicalFrame(session, frameIndex, true)
  result = "{"
  result = result + "\"schema\":\"MiniQuakeSnapshot/" + TRACE_SCHEMA + "\","
  result = result + "\"package\":" + diagnostics.jsonString(buildInfo.PACKAGE_ID) + ","
  result = result + "\"profile\":" + diagnostics.jsonString(buildInfo.COMPATIBILITY_PROFILE) + ","
  result = result + "\"phase\":" + diagnostics.jsonString(phase) + ","
  result = result + "\"error\":" + diagnostics.jsonString(errorText) + ","
  result = result + "\"frame\":" + frameIndex + ","
  result = result + "\"state_hash\":\"" + diagnostics.u32Hex(hashText(canonical)) + "\","
  result = result + "\"map\":" + diagnostics.jsonString(session.server.mapName) + ","
  result = result + "\"frame_stages\":" + diagnostics.stageJson(session.frameTrace) + ","
  result = result + "\"host\":" + snapshotHostJson(session) + ","
  result = result + "\"server\":" + snapshotServerJson(session) + ","
  result = result + "\"client\":" + snapshotClientJson(session) + ","
  result = result + "\"player\":" + snapshotPlayerJson(session) + ","
  result = result + "\"quakec\":" + snapshotQuakeCJson(session) + ","
  result = result + "\"digests\":" + snapshotDigestsJson(session) + ","
  result = result + "\"resources\":" + resourceJson(session) + ","
  result = result + "\"edicts\":" + edictsJson(session) + ","
  result = result + "\"client_entities\":" + clientEntitiesJson(session)
  return result + "}\n"
end function

function writeFile(path, text)
  result = try(fs.writeAllText(path, text))
  if result is error then return result end if
  return true
end function

function appendFile(path, text)
  result = try(fs.appendAllText(path, text))
  if result is error then return result end if
  return true
end function

function traceErrorLine(frameIndex, lastStage, message)
  result = "error_frame=" + frameIndex
  result = result + "|last_stage=" + lastStage
  result = result + "|message_hex=" + hex(bytes(message))
  return result + "\n"
end function

function attemptShutdown(session)
  result = try(host.shutdown(session))
  if result is error then return [false, result.message] end if
  if result != true then return [false, "Host_Shutdown failed"] end if
  return [true, ""]
end function

function summaryJson(ok, requested, written, accepted, rollingHash, tracePath, snapshotPath, contextPath, lastStage, errorText, cleanShutdown, diagnosticWriteError)
  result = "{"
  result = result + "\"schema\":\"MiniQuakeTraceSummary/" + TRACE_SCHEMA + "\","
  result = result + "\"package\":" + diagnostics.jsonString(buildInfo.PACKAGE_ID) + ","
  result = result + "\"profile\":" + diagnostics.jsonString(buildInfo.COMPATIBILITY_PROFILE) + ","
  result = result + "\"ok\":" + diagnostics.boolText(ok) + ","
  result = result + "\"frames_requested\":" + requested + ","
  result = result + "\"frames_written\":" + written + ","
  result = result + "\"accepted_frames\":" + accepted + ","
  result = result + "\"rolling_hash\":\"" + diagnostics.u32Hex(rollingHash) + "\","
  result = result + "\"trace_path\":" + diagnostics.jsonString(tracePath) + ","
  result = result + "\"snapshot_path\":" + diagnostics.jsonString(snapshotPath) + ","
  result = result + "\"context_path\":" + diagnostics.jsonString(contextPath) + ","
  result = result + "\"last_stage\":" + diagnostics.jsonString(lastStage) + ","
  result = result + "\"error\":" + diagnostics.jsonString(errorText) + ","
  result = result + "\"diagnostic_write_error\":" + diagnostics.jsonString(diagnosticWriteError) + ","
  result = result + "\"clean_shutdown\":" + diagnostics.boolText(cleanShutdown)
  return result + "}\n"
end function

function makeResult(ok, requested, written, accepted, rollingHash, prefix, lastStage, errorText, cleanShutdown)
  return t.CompatibilityTraceResult(
    ok,
    requested,
    written,
    accepted,
    rollingHash,
    prefix + ".mqtrace",
    prefix + "-snapshot.json",
    prefix + "-context.json",
    prefix + "-summary.json",
    lastStage,
    errorText,
    cleanShutdown,
  )
end function

function runInternal(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
  if gameDirectory == "" then gameDirectory = "id1" end if
  if mapName == "" then mapName = "start" end if
  if frameCount < 1 then frameCount = 1 end if
  if frameCount > 1000000 then frameCount = 1000000 end if
  if outputPrefix == "" then outputPrefix = "miniquake-compat" end if

  tracePath = outputPrefix + ".mqtrace"
  snapshotPath = outputPrefix + "-snapshot.json"
  contextPath = outputPrefix + "-context.json"
  summaryPath = outputPrefix + "-summary.json"
  header = "MiniQuakeCompatTrace|schema=" + TRACE_SCHEMA
  header = header + "|package=" + buildInfo.PACKAGE_ID
  header = header + "|profile=" + buildInfo.COMPATIBILITY_PROFILE
  header = header + "|game_hex=" + hex(bytes(gameDirectory))
  header = header + "|map_hex=" + hex(bytes(mapName))
  header = header + "|frames=" + frameCount
  header = header + "|step_f32=" + diagnostics.f32Hex(0.02) + "\n"

  initializedTrace = try(writeFile(tracePath, header))
  if initializedTrace is error then
    return makeResult(false, frameCount, 0, 0, FNV_OFFSET, outputPrefix, "trace_open", initializedTrace.message, false)
  end if

  args = ["-basedir", baseDirectory, "-game", gameDirectory, "-headless", "-nosound", "-nolan", "-nomouse", "-nojoy", "+map", mapName]
  created = try(host.create(args))
  if created is error then
    createFailure = created.message
    createSummary = summaryJson(false, frameCount, 0, 0, FNV_OFFSET, tracePath, snapshotPath, contextPath, "create", createFailure, false, "")
    createSummaryWrite = try(writeFile(summaryPath, createSummary))
    if createSummaryWrite is error then createFailure = createFailure + "; summary: " + createSummaryWrite.message end if
    return makeResult(false, frameCount, 0, 0, FNV_OFFSET, outputPrefix, "create", createFailure, false)
  end if
  session = created
  session.diagnosticContextPath = contextPath
  session.diagnosticFrame = -1
  diagnostics.persist(session, "before_initialize", "")
  initialized = try(host.initialize(session))
  if initialized is error then
    diagnostics.failFrame(session, initialized.message)
    initializationFailure = initialized.message
    snapshotText = try(snapshotJson(session, -1, "initialize_error", initializationFailure))
    if snapshotText is error then
      initializationFailure = initializationFailure + "; snapshot serialization: " + snapshotText.message
    else
      snapshotWrite = try(writeFile(snapshotPath, snapshotText))
      if snapshotWrite is error then initializationFailure = initializationFailure + "; snapshot write: " + snapshotWrite.message end if
    end if
    shutdownResult = attemptShutdown(session)
    clean = shutdownResult[0]
    if shutdownResult[1] != "" then initializationFailure = initializationFailure + "; shutdown: " + shutdownResult[1] end if
    summary = summaryJson(false, frameCount, 0, 0, FNV_OFFSET, tracePath, snapshotPath, contextPath, diagnostics.lastStage(session), initializationFailure, clean, session.diagnosticWriteError)
    summaryWrite = try(writeFile(summaryPath, summary))
    if summaryWrite is error then initializationFailure = initializationFailure + "; summary: " + summaryWrite.message end if
    return makeResult(false, frameCount, 0, 0, FNV_OFFSET, outputPrefix, diagnostics.lastStage(session), initializationFailure, clean)
  end if

  rollingHash = FNV_OFFSET
  writtenFrames = 0
  acceptedFrames = 0
  failure = ""
  index = 0
  while index < frameCount
    session.diagnosticFrame = index
    frameResult = try(host.frame(session, 0.02))
    if frameResult is error then
      failure = frameResult.message
      diagnostics.failFrame(session, failure)
      errorAppend = try(appendFile(tracePath, traceErrorLine(index, diagnostics.lastStage(session), failure)))
      if errorAppend is error then failure = failure + "; trace error record: " + errorAppend.message end if
      break
    end if
    accepted = frameResult == true

    diagnostics.postFrameStage(session, "trace_canonical")
    canonicalResult = try(canonicalFrame(session, index, accepted))
    if canonicalResult is error then
      failure = "canonical frame: " + canonicalResult.message
      diagnostics.failFrame(session, failure)
      errorAppend = try(appendFile(tracePath, traceErrorLine(index, diagnostics.lastStage(session), failure)))
      if errorAppend is error then failure = failure + "; trace error record: " + errorAppend.message end if
      break
    end if
    canonical = canonicalResult

    diagnostics.postFrameStage(session, "trace_state_hash")
    stateHashResult = try(hashText(canonical))
    if stateHashResult is error then
      failure = "state hash: " + stateHashResult.message
      diagnostics.failFrame(session, failure)
      errorAppend = try(appendFile(tracePath, traceErrorLine(index, diagnostics.lastStage(session), failure)))
      if errorAppend is error then failure = failure + "; trace error record: " + errorAppend.message end if
      break
    end if

    diagnostics.postFrameStage(session, "trace_append")
    line = canonical + "|state_hash=" + diagnostics.u32Hex(stateHashResult) + "\n"
    appended = try(appendFile(tracePath, line))
    if appended is error then
      failure = "trace append: " + appended.message
      diagnostics.failFrame(session, failure)
      break
    end if

    diagnostics.postFrameStage(session, "trace_rolling_hash")
    rollingResult = try(hashTextSeed(rollingHash, canonical))
    if rollingResult is error then
      failure = "rolling hash: " + rollingResult.message
      diagnostics.failFrame(session, failure)
      break
    end if
    rollingHash = hashByte(rollingResult, 10)
    writtenFrames = writtenFrames + 1
    if accepted then acceptedFrames = acceptedFrames + 1 end if
    diagnostics.postFrameStage(session, "trace_frame_complete")
    index = index + 1
  end while

  if failure == "" and session.diagnosticWriteError != "" then failure = session.diagnosticWriteError end if
  phase = "complete"
  ok = failure == "" and writtenFrames == frameCount
  if not ok then phase = "error" end if
  snapshotText = try(snapshotJson(session, writtenFrames - 1, phase, failure))
  if snapshotText is error then
    ok = false
    if failure == "" then failure = "snapshot serialization: " + snapshotText.message else failure = failure + "; snapshot serialization: " + snapshotText.message end if
  else
    snapshotWritten = try(writeFile(snapshotPath, snapshotText))
    if snapshotWritten is error then
      ok = false
      if failure == "" then failure = "snapshot write: " + snapshotWritten.message else failure = failure + "; snapshot write: " + snapshotWritten.message end if
    end if
  end if
  contextPhase = "trace_complete"
  if not ok then contextPhase = "trace_error" end if
  diagnostics.persist(session, contextPhase, failure)
  contextWriteError = session.diagnosticWriteError
  session.diagnosticContextPath = ""
  lastStageValue = diagnostics.lastStage(session)
  shutdownResult = attemptShutdown(session)
  cleanShutdown = shutdownResult[0]
  if not cleanShutdown then
    ok = false
    if failure == "" then failure = shutdownResult[1] else failure = failure + "; shutdown: " + shutdownResult[1] end if
  end if

  summary = summaryJson(ok, frameCount, writtenFrames, acceptedFrames, rollingHash, tracePath, snapshotPath, contextPath, lastStageValue, failure, cleanShutdown, contextWriteError)
  summaryWritten = try(writeFile(summaryPath, summary))
  if summaryWritten is error then
    ok = false
    if failure == "" then failure = summaryWritten.message end if
  end if
  return makeResult(ok, frameCount, writtenFrames, acceptedFrames, rollingHash, outputPrefix, lastStageValue, failure, cleanShutdown)
end function

// No diagnostics-only failure may escape as an unclassified process exit.
// Convert unexpected propagation into a regular failed result and leave an
// emergency summary for the black-port feedback loop whenever possible.
function run(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
  prefix = outputPrefix
  if prefix == "" then prefix = "miniquake-compat" end if
  requested = frameCount
  if requested < 1 then requested = 1 end if
  if requested > 1000000 then requested = 1000000 end if

  result = try(runInternal(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix))
  if result is not error then return result end if

  failure = "unhandled compatibility diagnostic error: " + result.message
  tracePath = prefix + ".mqtrace"
  snapshotPath = prefix + "-snapshot.json"
  contextPath = prefix + "-context.json"
  summaryPath = prefix + "-summary.json"
  emergency = try(summaryJson(false, requested, 0, 0, FNV_OFFSET, tracePath, snapshotPath, contextPath, "unhandled", failure, false, ""))
  if emergency is not error then
    ignored = try(writeFile(summaryPath, emergency))
  end if
  return makeResult(false, requested, 0, 0, FNV_OFFSET, prefix, "unhandled", failure, false)
end function

function printResult(result)
  print "MiniQuake deterministic compatibility trace"
  print "  trace=" + result.tracePath
  print "  snapshot=" + result.snapshotPath
  print "  context=" + result.contextPath
  print "  summary=" + result.summaryPath
  print "  frames=" + result.framesWritten + "/" + result.framesRequested + " accepted=" + result.acceptedFrames
  print "  rolling-hash=" + diagnostics.u32Hex(result.rollingHash)
  print "  last-stage=" + result.lastStage
  if result.errorMessage != "" then print "  error=" + result.errorMessage end if
  if result.ok then print "  result=PASS" else print "  result=FAIL" end if
  return result.ok
end function

function containsText(text, needle)
  source = bytes(text)
  wanted = bytes(needle)
  if len(wanted) == 0 then return true end if
  if len(wanted) > len(source) then return false end if
  start = 0
  while start <= len(source) - len(wanted)
    matched = true
    index = 0
    while index < len(wanted)
      if source[start + index] != wanted[index] then matched = false; break end if
      index = index + 1
    end while
    if matched then return true end if
    start = start + 1
  end while
  return false
end function

function lineCount(text)
  source = bytes(text)
  count = 0
  index = 0
  while index < len(source)
    if source[index] == 10 then count = count + 1 end if
    index = index + 1
  end while
  return count
end function

function inspect(path)
  loaded = try(fs.readAllText(path))
  if loaded is error then print "MiniQuake compatibility report: " + loaded.message; return false end if
  recognized = containsText(loaded, "MiniQuakeCompatTrace|schema=") or
    containsText(loaded, "\"schema\":\"MiniQuakeTraceSummary/") or
    containsText(loaded, "\"schema\":\"MiniQuakeSnapshot/") or
    containsText(loaded, "\"schema\":\"MiniQuakeCrashContext/")
  print "MiniQuake compatibility report"
  print "  file=" + path
  print "  bytes=" + len(bytes(loaded)) + " lines=" + lineCount(loaded)
  if recognized then print "  schema=recognized"; print "  result=PASS" else print "  schema=unknown"; print "  result=FAIL" end if
  return recognized
end function
