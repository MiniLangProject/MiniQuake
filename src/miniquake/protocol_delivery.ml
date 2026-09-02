/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Protocol-15 reliable/unreliable scheduling helpers shared by client and server.
The normal WinQuake drivers return -1 or 1 after NET_CanSendMessage succeeds,
but modern backends are permitted to return 0 for a transient race.  A zero
result must retain the queued message; only a committed send clears it.
*/
package miniquake.protocol_delivery

/// Defines the send drop value used by `miniquake.protocol_delivery`.
const SEND_DROP = 1
/// Defines the send retain value used by `miniquake.protocol_delivery`.
const SEND_RETAIN = 2
/// Defines the send commit value used by `miniquake.protocol_delivery`.
const SEND_COMMIT = 3

/// Implements the `reliableSendOutcome` operation for `miniquake.protocol_delivery` (reliable send outcome).
/// @param result Result value to report or translate into a status code.
function reliableSendOutcome(result)
  if result < 0 then return SEND_DROP end if
  if result == 0 then return SEND_RETAIN end if
  return SEND_COMMIT
end function

/// Implements the `clientReliablePlan` operation for `miniquake.protocol_delivery` (client reliable plan).
/// @param connected The connected input consumed by `clientReliablePlan`.
/// @param messageSize Size of the requested data or resource.
/// @param canSend The can send input consumed by `clientReliablePlan`.
function clientReliablePlan(connected, messageSize, canSend)
  if not connected then return SEND_DROP end if
  if messageSize <= 0 then return 0 end if
  if not canSend then return SEND_RETAIN end if
  return SEND_COMMIT
end function

/// Implements the `keepaliveDue` operation for `miniquake.protocol_delivery` (keepalive due).
/// @param elapsed The elapsed input consumed by `keepaliveDue`.
function inline keepaliveDue(elapsed)
  return elapsed > 5.0
end function

/// Implements the `reliableWorkPending` operation for `miniquake.protocol_delivery` (reliable work pending).
/// @param messageSize Size of the requested data or resource.
/// @param dropAsap The drop asap input consumed by `reliableWorkPending`.
function reliableWorkPending(messageSize, dropAsap)
  return messageSize > 0 or dropAsap
end function

/// Update module state for after send.
/// @param result Result value to report or translate into a status code.
function clearAfterSend(result)
  return reliableSendOutcome(result) == SEND_COMMIT
end function
