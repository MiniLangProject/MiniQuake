/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang pendant for WinQuake/chase.c.  chase.h does not exist in the pinned
MiniQuake tree; the four public routines and cvars are all defined in chase.c.
*/
package miniquake.chase

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.cvar as cvar
import miniquake.world_bsp as world

/// Defines the chase back default value used by `miniquake.chase`.
const CHASE_BACK_DEFAULT = 100.0
/// Defines the chase up default value used by `miniquake.chase`.
const CHASE_UP_DEFAULT = 16.0
/// Defines the chase right default value used by `miniquake.chase`.
const CHASE_RIGHT_DEFAULT = 0.0

/// Report whether command never exists holds for the active state.
/// @param name Stable name that identifies the requested object or option.
function commandNeverExists(name)
  return false
end function

/// Implements the `create` operation for `miniquake.chase` (create).
function create()
  return t.ChaseState(false, CHASE_BACK_DEFAULT, CHASE_UP_DEFAULT, CHASE_RIGHT_DEFAULT)
end function

/// Chase_Init registers the same four non-archived, non-server cvars as MiniQuake
/// and returns the value state used by the data-oriented MiniLang renderer.
/// @param registry The registry input consumed by `Chase_Init`.
function Chase_Init(registry)
  cvar.register(registry, cvar.create("chase_back", "100", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_up", "16", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_right", "0", false, false), commandNeverExists)
  cvar.register(registry, cvar.create("chase_active", "0", false, false), commandNeverExists)
  return create()
end function

/// Update module state for cvars.
/// @param state Mutable `miniquake.chase` state used by `syncCvars`.
/// @param registry The registry input consumed by `syncCvars`.
function syncCvars(state, registry)
  state.back = cvar.variableValue(registry, "chase_back")
  state.up = cvar.variableValue(registry, "chase_up")
  state.right = cvar.variableValue(registry, "chase_right")
  state.active = cvar.variableValue(registry, "chase_active") != 0.0
  return state
end function

/// The original reset hook intentionally contains no state changes.
/// @param state Mutable `miniquake.chase` state used by `Chase_Reset`.
function Chase_Reset(state)
  return state
end function

/// Implements the `TraceLine` operation for `miniquake.chase` (trace line).
/// @param worldMap The world map input consumed by `TraceLine`.
/// @param start The start input consumed by `TraceLine`.
/// @param finish The finish input consumed by `TraceLine`.
function TraceLine(worldMap, start, finish)
  if worldMap is void then return math.VectorCopy(finish) end if
  trace = world.traceLine(worldMap, start, finish)
  return math.VectorCopy(trace.endPosition)
end function

/// Returns [new view origin, new view angles, exact chase destination, impact].
/// cl.viewangles supplies the trace direction.  Original Chase_Update modifies
/// only r_refdef.viewangles[PITCH]; yaw/roll, damage kick and idle sway survive.
/// @param state Mutable `miniquake.chase` state used by `Chase_UpdateRefdef`.
/// @param viewOrigin The view origin input consumed by `Chase_UpdateRefdef`.
/// @param clientViewAngles The client view angles input consumed by `Chase_UpdateRefdef`.
/// @param renderViewAngles The render view angles input consumed by `Chase_UpdateRefdef`.
/// @param worldMap The world map input consumed by `Chase_UpdateRefdef`.
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

/// Mirror Quake's Chase_Update routine and its observable state changes.
/// @param state Mutable `miniquake.chase` state used by `Chase_Update`.
/// @param viewOrigin The view origin input consumed by `Chase_Update`.
/// @param clientViewAngles The client view angles input consumed by `Chase_Update`.
/// @param worldMap The world map input consumed by `Chase_Update`.
function Chase_Update(state, viewOrigin, clientViewAngles, worldMap)
  return Chase_UpdateRefdef(state, viewOrigin, clientViewAngles, clientViewAngles, worldMap)
end function

/// Existing convenience API retains its destination-only contract.
/// @param state Mutable `miniquake.chase` state used by `update`.
/// @param viewOrigin The view origin input consumed by `update`.
/// @param viewAngles The view angles input consumed by `update`.
function update(state, viewOrigin, viewAngles)
  return Chase_Update(state, viewOrigin, viewAngles, void)[0]
end function
