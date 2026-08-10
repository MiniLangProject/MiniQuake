/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

MiniLang pendant for WinQuake/chase.c.  chase.h does not exist in the pinned
MiniQuake tree; the four public routines and cvars are all defined in chase.c.
*/

package miniquake.chase

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.cvar as cvar
import miniquake.world_bsp as world

const CHASE_BACK_DEFAULT = 100.0
const CHASE_UP_DEFAULT = 16.0
const CHASE_RIGHT_DEFAULT = 0.0

function commandNeverExists(name)
  return false
end function

function create()
  return t.ChaseState(false, CHASE_BACK_DEFAULT, CHASE_UP_DEFAULT, CHASE_RIGHT_DEFAULT)
end function

// Chase_Init registers the same four non-archived, non-server cvars as MiniQuake
// and returns the value state used by the data-oriented MiniLang renderer.
function Chase_Init(registry)
  cvar.register(registry, cvar.create("chase_back", "100", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_up", "16", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_right", "0", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_active", "0", false, false), commandNeverExists)
  return create()
end function

function syncCvars(state, registry)
  state.back = cvar.variableValue(registry, "chase_back")
  state.up = cvar.variableValue(registry, "chase_up")
  state.right = cvar.variableValue(registry, "chase_right")
  state.active = cvar.variableValue(registry, "chase_active") != 0.0
  return state
end function

// The original reset hook intentionally contains no state changes.
function Chase_Reset(state)
  return state
end function

function TraceLine(worldMap, start, finish)
  if worldMap is void then return math.VectorCopy(finish) end if
  trace = world.traceLine(worldMap, start, finish)
  return math.VectorCopy(trace.endPosition)
end function

// Returns [new view origin, new view angles, exact chase destination, impact].
// cl.viewangles supplies the trace direction.  Original Chase_Update modifies
// only r_refdef.viewangles[PITCH]; yaw/roll, damage kick and idle sway survive.
function Chase_UpdateRefdef(state, viewOrigin, clientViewAngles, renderViewAngles, worldMap)
  vectors = math.AngleVectors(clientViewAngles)
  forward = vectors[0]
  right = vectors[1]

  chaseDestination = t.Vec3(
    viewOrigin.x - forward.x * state.back - right.x * state.right,
    viewOrigin.y - forward.y * state.back - right.y * state.right,
    viewOrigin.z + state.up,
  )

  farDestination = math.VectorMA(viewOrigin, 4096.0, forward)
  stop = TraceLine(worldMap, viewOrigin, farDestination)
  stopDelta = math.VectorSubtract(stop, viewOrigin)
  distance = math.DotProduct(stopDelta, forward)
  if distance < 1.0 then distance = 1.0 end if

  adjustedAngles = math.VectorCopy(renderViewAngles)
  adjustedAngles.x = -math.atan2(stopDelta.z, distance) * math.RAD_TO_DEG
  return [chaseDestination, adjustedAngles, math.VectorCopy(chaseDestination), stop]
end function

function Chase_Update(state, viewOrigin, clientViewAngles, worldMap)
  return Chase_UpdateRefdef(state, viewOrigin, clientViewAngles, clientViewAngles, worldMap)
end function

// Existing convenience API retains its destination-only contract.
function update(state, viewOrigin, viewAngles)
  return Chase_Update(state, viewOrigin, viewAngles, void)[0]
end function
