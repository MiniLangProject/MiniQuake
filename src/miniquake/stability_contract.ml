/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Release-candidate resource-stability contract layered on the existing host
soak implementations.
*/
package miniquake.stability_contract

import miniquake.constants as c

/// Defines the status value used by `miniquake.stability_contract`.
const STATUS = "stability_109_frozen_v1"
/// Defines the fingerprint value used by `miniquake.stability_contract`.
const FINGERPRINT = 0xd0e3c03f
/// Defines the contract text value used by `miniquake.stability_contract`.
const CONTRACT_TEXT = "stability|host-soak=5000|listen-soak=5000|gc-resource-plateau|client-entities<=server-highwater+baseline-static-offset|clean-shutdown|live-output"
/// Defines the client entity policy value used by `miniquake.stability_contract`.
const CLIENT_ENTITY_POLICY = "server_high_water_plus_existing_static_offset"
/// Defines the default soak frames value used by `miniquake.stability_contract`.
const DEFAULT_SOAK_FRAMES = 5000
/// Defines the listen soak frames value used by `miniquake.stability_contract`.
const LISTEN_SOAK_FRAMES = 5000
/// Defines the live block allowance value used by `miniquake.stability_contract`.
const LIVE_BLOCK_ALLOWANCE = 512
/// Defines the live byte allowance value used by `miniquake.stability_contract`.
const LIVE_BYTE_ALLOWANCE = 65536

/// Implements the `modes` operation for `miniquake.stability_contract` (modes).
function inline modes()
  return ["host", "listen"]
end function

/// Implements the `deltaStable` operation for `miniquake.stability_contract` (delta stable).
/// @param before The before input consumed by `deltaStable`.
/// @param after The after input consumed by `deltaStable`.
/// @param allowance The allowance input consumed by `deltaStable`.
function inline deltaStable(before, after, allowance)
  return after <= before + allowance
end function

/// Apply the Quake-compatible host stable behavior.
/// @param liveBefore The live before input consumed by `hostStable`.
/// @param liveAfter The live after input consumed by `hostStable`.
/// @param bytesBefore The bytes before input consumed by `hostStable`.
/// @param bytesAfter The bytes after input consumed by `hostStable`.
function hostStable(liveBefore, liveAfter, bytesBefore, bytesAfter)
  return deltaStable(liveBefore, liveAfter, 64) and deltaStable(bytesBefore, bytesAfter, 1048576)
end function

/// WinQuake owns a fixed cl_entities[MAX_EDICTS] array and advances
/// cl_num_entities as higher server entity numbers are first observed. The
/// MiniLang port stores only the reached prefix, so a listen-server client may
/// legitimately catch up from N to an already existing sv.num_edicts high-water
/// after the soak baseline. Preserve only the static-entity offset that already
/// existed at the baseline; new growth beyond that topology remains a failure.
/// @param serverBefore The server before input consumed by `clientEntityLimit`.
/// @param serverAfter The server after input consumed by `clientEntityLimit`.
/// @param entitiesBefore The entities before input consumed by `clientEntityLimit`.
function clientEntityLimit(serverBefore, serverAfter, entitiesBefore)
  if serverBefore < 0 or serverAfter < 0 or entitiesBefore < 0 then return -1 end if
  if serverBefore > c.MAX_EDICTS or serverAfter > c.MAX_EDICTS then return -1 end if
  maximumEntities = c.MAX_EDICTS + c.MAX_STATIC_ENTITIES
  if entitiesBefore > maximumEntities then return -1 end if

  serverHigh = serverBefore
  if serverAfter > serverHigh then serverHigh = serverAfter end if

  staticOffset = entitiesBefore - serverBefore
  if staticOffset < 0 then staticOffset = 0 end if

  limit = serverHigh + staticOffset
  if limit < entitiesBefore then limit = entitiesBefore end if
  if limit > maximumEntities then limit = maximumEntities end if
  return limit
end function

/// Implements the `clientEntityHighWaterStable` operation for `miniquake.stability_contract` (client entity high water stable).
/// @param serverBefore The server before input consumed by `clientEntityHighWaterStable`.
/// @param serverAfter The server after input consumed by `clientEntityHighWaterStable`.
/// @param entitiesBefore The entities before input consumed by `clientEntityHighWaterStable`.
/// @param entitiesAfter The entities after input consumed by `clientEntityHighWaterStable`.
function clientEntityHighWaterStable(serverBefore, serverAfter, entitiesBefore, entitiesAfter)
  limit = clientEntityLimit(serverBefore, serverAfter, entitiesBefore)
  if limit < 0 or entitiesAfter < 0 then return false end if
  return entitiesAfter <= limit
end function

/// Implements the `longChecks` operation for `miniquake.stability_contract` (long checks).
/// @param before The before input consumed by `longChecks`.
/// @param after The after input consumed by `longChecks`.
function longChecks(before, after)
  if before is not array or after is not array or len(before) < 16 or len(after) < 16 then
    return [false, false, false, false, false, false, false, false, false]
  end if

  heapStable = after[0] <= before[0] + LIVE_BLOCK_ALLOWANCE and
    after[2] <= before[2] + LIVE_BYTE_ALLOWANCE
  edictsStable = before[4] >= 0 and after[4] >= 0 and
    before[4] <= c.MAX_EDICTS and after[4] <= c.MAX_EDICTS and
    after[4] <= before[4]
  entitiesStable = clientEntityHighWaterStable(before[4], after[4], before[5], after[5])
  clientsStable = after[6] == before[6]
  socketsStable = after[7] == before[7] and after[8] == before[8]
  queuesStable = after[9] <= before[9] and after[10] <= before[10] and after[11] <= before[11]
  endpointsStable = after[12] == before[12]
  audioStable = after[13] <= before[13] and after[14] <= before[14]
  handlesStable = after[15] <= before[15]
  return [
    heapStable,
    edictsStable,
    entitiesStable,
    clientsStable,
    socketsStable,
    queuesStable,
    endpointsStable,
    audioStable,
    handlesStable,
  ]
end function

/// Implements the `longStable` operation for `miniquake.stability_contract` (long stable).
/// @param before The before input consumed by `longStable`.
/// @param after The after input consumed by `longStable`.
function longStable(before, after)
  checks = longChecks(before, after)
  for each passed in checks
    if not passed then return false end if
  end for
  return true
end function

/// Implements the `contractVector` operation for `miniquake.stability_contract` (contract vector).
function contractVector()
  return [STATUS, FINGERPRINT, DEFAULT_SOAK_FRAMES, LISTEN_SOAK_FRAMES, LIVE_BLOCK_ALLOWANCE, LIVE_BYTE_ALLOWANCE, CLIENT_ENTITY_POLICY, modes()]
end function
