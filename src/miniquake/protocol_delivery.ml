/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Protocol-15 reliable/unreliable scheduling helpers shared by client and server.
The normal WinQuake drivers return -1 or 1 after NET_CanSendMessage succeeds,
but modern backends are permitted to return 0 for a transient race.  A zero
result must retain the queued message; only a committed send clears it.
*/

package miniquake.protocol_delivery

const SEND_DROP = 1
const SEND_RETAIN = 2
const SEND_COMMIT = 3

function reliableSendOutcome(result)
  if result < 0 then return SEND_DROP end if
  if result == 0 then return SEND_RETAIN end if
  return SEND_COMMIT
end function

function clientReliablePlan(connected, messageSize, canSend)
  if not connected then return SEND_DROP end if
  if messageSize <= 0 then return 0 end if
  if not canSend then return SEND_RETAIN end if
  return SEND_COMMIT
end function

function inline keepaliveDue(elapsed)
  return elapsed > 5.0
end function

function reliableWorkPending(messageSize, dropAsap)
  return messageSize > 0 or dropAsap
end function

function clearAfterSend(result)
  return reliableSendOutcome(result) == SEND_COMMIT
end function
