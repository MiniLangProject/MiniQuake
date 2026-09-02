/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.server_move.
*/
package miniquake.server_move

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as world
import miniquake.server_collision as collision

/// Defines the step size value used by `miniquake.server_move`.
const STEP_SIZE = 18.0
/// Defines the di nodir value used by `miniquake.server_move`.
const DI_NODIR = -1.0

/// Implements the `zeroVector` operation for `miniquake.server_move` (zero vector).
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `absolute` operation for `miniquake.server_move` (absolute).
/// @param value Value consumed by `absolute`.
function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

/// Implements the `randomWord` operation for `miniquake.server_move` (random word).
/// @param server Server state participating in the operation.
function randomWord(server)
  if server is void or server.machine is void or server.machine.context is void then return 0 end if
  ctx = server.machine.context
  ctx.randomSeed = (ctx.randomSeed * 214013 + 2531011) & 0xffffffff
  return (ctx.randomSeed >> 16) & 0x7fff
end function

/// PF_changeyaw / SV_StepDirection share this exact angle update.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function changeYaw(server, entityIndex)
  angles = collision.entityVectorZero(server, entityIndex, "angles")
  current = math.angleMod(angles.y)
  ideal = math.angleMod(collision.entityFloat(server, entityIndex, "ideal_yaw", current))
  speed = collision.entityFloat(server, entityIndex, "yaw_speed", 0.0)
  if current == ideal then return current end if
  movement = ideal - current
  if ideal > current then
    if movement >= 180.0 then movement = movement - 360.0 end if
  else
    if movement <= -180.0 then movement = movement + 360.0 end if
  end if
  if movement > speed then movement = speed end if
  if movement < -speed then movement = -speed end if
  angles.y = math.angleMod(current + movement)
  collision.setEntityVector(server, entityIndex, "angles", angles)
  return angles.y
end function

/// SV_movestep: QuakeC monster movement, including stair/drop checks and
/// flying/swimming pursuit height adjustment.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param movement The movement input consumed by `moveStep`.
/// @param relink The relink input consumed by `moveStep`.
function moveStep(server, entityIndex, movement, relink)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if not collision.entityValid(server, entityIndex) then return false end if
  oldOrigin = collision.entityVectorZero(server, entityIndex, "origin")
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))

  if (flags & (c.FL_SWIM | c.FL_FLY)) != 0 then
    attempt = 0
    while attempt < 2
      target = math.add(oldOrigin, movement)
      enemy = collision.entityWord(server, entityIndex, "enemy", 0)
      if attempt == 0 and enemy != 0 and collision.entityValid(server, enemy) then
        enemyOrigin = collision.entityVectorZero(server, enemy, "origin")
        dz = oldOrigin.z - enemyOrigin.z
        if dz > 40.0 then target.z = target.z - 8.0 end if
        if dz < 30.0 then target.z = target.z + 8.0 end if
      end if
      mins = collision.entityVectorZero(server, entityIndex, "mins")
      maxs = collision.entityVectorZero(server, entityIndex, "maxs")
      trace = collision.move(server, oldOrigin, mins, maxs, target, c.MOVE_NORMAL, entityIndex)
      if trace.fraction == 1.0 then
        if (flags & c.FL_SWIM) != 0 and world.pointContentsWorld(server.worldModel, trace.endPosition) == c.CONTENTS_EMPTY then return false end if
        collision.setEntityVector(server, entityIndex, "origin", trace.endPosition)
        if relink then collision.linkEntity(server, entityIndex, true) end if
        return true
      end if
      if enemy == 0 then break end if
      attempt = attempt + 1
    end while
    return false
  end if

  target = math.add(oldOrigin, movement)
  target.z = target.z + STEP_SIZE
  finish = t.Vec3(target.x, target.y, target.z - STEP_SIZE * 2.0)
  mins = collision.entityVectorZero(server, entityIndex, "mins")
  maxs = collision.entityVectorZero(server, entityIndex, "maxs")
  trace = collision.move(server, target, mins, maxs, finish, c.MOVE_NORMAL, entityIndex)
  if trace.allSolid then return false end if

  if trace.startSolid then
    target.z = target.z - STEP_SIZE
    trace = collision.move(server, target, mins, maxs, finish, c.MOVE_NORMAL, entityIndex)
    if trace.allSolid or trace.startSolid then return false end if
  end if

  if trace.fraction == 1.0 then
    if (flags & c.FL_PARTIALGROUND) != 0 then
      collision.setEntityVector(server, entityIndex, "origin", math.add(oldOrigin, movement))
      flags = flags & ~c.FL_ONGROUND
      collision.setEntityFloat(server, entityIndex, "flags", flags)
      if relink then collision.linkEntity(server, entityIndex, true) end if
      return true
    end if
    return false
  end if

  collision.setEntityVector(server, entityIndex, "origin", trace.endPosition)
  if not collision.checkBottom(server, entityIndex) then
    if (flags & c.FL_PARTIALGROUND) != 0 then
      if relink then collision.linkEntity(server, entityIndex, true) end if
      return true
    end if
    collision.setEntityVector(server, entityIndex, "origin", oldOrigin)
    return false
  end if

  if (flags & c.FL_PARTIALGROUND) != 0 then
    flags = flags & ~c.FL_PARTIALGROUND
    collision.setEntityFloat(server, entityIndex, "flags", flags)
  end if
  collision.setEntityWord(server, entityIndex, "groundentity", trace.entity)
  if relink then collision.linkEntity(server, entityIndex, true) end if
  return true
end function

/// Advance direction by one processing step.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param yaw The yaw input consumed by `stepDirection`.
/// @param distance The distance input consumed by `stepDirection`.
function stepDirection(server, entityIndex, yaw, distance)
  collision.setEntityFloat(server, entityIndex, "ideal_yaw", yaw)
  changeYaw(server, entityIndex)
  radians = yaw * math.DEG_TO_RAD
  movement = t.Vec3(native.cos(radians) * distance, native.sin(radians) * distance, 0.0)
  oldOrigin = collision.entityVectorZero(server, entityIndex, "origin")
  if moveStep(server, entityIndex, movement, false) then
    angles = collision.entityVectorZero(server, entityIndex, "angles")
    ideal = collision.entityFloat(server, entityIndex, "ideal_yaw", yaw)
    delta = angles.y - ideal
    if delta > 45.0 and delta < 315.0 then collision.setEntityVector(server, entityIndex, "origin", oldOrigin) end if
    collision.linkEntity(server, entityIndex, true)
    return true
  end if
  collision.linkEntity(server, entityIndex, true)
  return false
end function

/// Implements the `fixCheckBottom` operation for `miniquake.server_move` (fix check bottom).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function fixCheckBottom(server, entityIndex)
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  collision.setEntityFloat(server, entityIndex, "flags", flags | c.FL_PARTIALGROUND)
end function

/// Create and initialize chase direction.
/// @param server Server state participating in the operation.
/// @param actor The actor input consumed by `newChaseDirection`.
/// @param enemy The enemy input consumed by `newChaseDirection`.
/// @param distance The distance input consumed by `newChaseDirection`.
function newChaseDirection(server, actor, enemy, distance)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  actorOrigin = collision.entityVectorZero(server, actor, "origin")
  enemyOrigin = collision.entityVectorZero(server, enemy, "origin")
  oldDirection = math.angleMod(native.trunc(collision.entityFloat(server, actor, "ideal_yaw", 0.0) / 45.0) * 45.0)
  turnaround = math.angleMod(oldDirection - 180.0)
  deltaX = enemyOrigin.x - actorOrigin.x
  deltaY = enemyOrigin.y - actorOrigin.y
  dirX = DI_NODIR
  dirY = DI_NODIR
  if deltaX > 10.0 then dirX = 0.0 else if deltaX < -10.0 then dirX = 180.0 end if
  if deltaY < -10.0 then dirY = 270.0 else if deltaY > 10.0 then dirY = 90.0 end if

  if dirX != DI_NODIR and dirY != DI_NODIR then
    diagonal = 0.0
    if dirX == 0.0 then
      if dirY == 90.0 then diagonal = 45.0 else diagonal = 315.0 end if
    else
      if dirY == 90.0 then diagonal = 135.0 else diagonal = 215.0 end if
    end if
    if diagonal != turnaround and stepDirection(server, actor, diagonal, distance) then return true end if
  end if

  if ((randomWord(server) & 3) & 1) != 0 or absolute(deltaY) > absolute(deltaX) then
    swap = dirX
    dirX = dirY
    dirY = swap
  end if
  if dirX != DI_NODIR and dirX != turnaround and stepDirection(server, actor, dirX, distance) then return true end if
  if dirY != DI_NODIR and dirY != turnaround and stepDirection(server, actor, dirY, distance) then return true end if
  if oldDirection != DI_NODIR and stepDirection(server, actor, oldDirection, distance) then return true end if

  if (randomWord(server) & 1) != 0 then
    direction = 0.0
    while direction <= 315.0
      if direction != turnaround and stepDirection(server, actor, direction, distance) then return true end if
      direction = direction + 45.0
    end while
  else
    direction = 315.0
    while direction >= 0.0
      if direction != turnaround and stepDirection(server, actor, direction, distance) then return true end if
      direction = direction - 45.0
    end while
  end if

  if turnaround != DI_NODIR and stepDirection(server, actor, turnaround, distance) then return true end if
  collision.setEntityFloat(server, actor, "ideal_yaw", oldDirection)
  if not collision.checkBottom(server, actor) then fixCheckBottom(server, actor) end if
  return false
end function

/// Release state for close enough.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param goalIndex Zero-based index of the requested entry.
/// @param distance The distance input consumed by `closeEnough`.
function closeEnough(server, entityIndex, goalIndex, distance)
  entityMins = collision.entityAbsMin(server, entityIndex)
  entityMaxs = collision.entityAbsMax(server, entityIndex)
  goalMins = collision.entityAbsMin(server, goalIndex)
  goalMaxs = collision.entityAbsMax(server, goalIndex)
  if goalMins.x > entityMaxs.x + distance or goalMaxs.x < entityMins.x - distance then return false end if
  if goalMins.y > entityMaxs.y + distance or goalMaxs.y < entityMins.y - distance then return false end if
  if goalMins.z > entityMaxs.z + distance or goalMaxs.z < entityMins.z - distance then return false end if
  return true
end function

/// Transfer data for move to goal.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param distance The distance input consumed by `moveToGoal`.
function moveToGoal(server, entityIndex, distance)
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  if (flags & (c.FL_ONGROUND | c.FL_FLY | c.FL_SWIM)) == 0 then return false end if
  goal = collision.entityWord(server, entityIndex, "goalentity", 0)
  if goal <= 0 or not collision.entityValid(server, goal) then return false end if
  enemy = collision.entityWord(server, entityIndex, "enemy", 0)
  if enemy != 0 and closeEnough(server, entityIndex, goal, distance) then return true end if
  ideal = collision.entityFloat(server, entityIndex, "ideal_yaw", 0.0)
  if (randomWord(server) & 3) == 1 or not stepDirection(server, entityIndex, ideal, distance) then
    return newChaseDirection(server, entityIndex, goal, distance)
  end if
  return true
end function

/// --------------------------------------------------------------------------
/// sv_move.c public compatibility surface.  Keep these names one-for-one with
/// the original server movement unit; the lower-case spellings above remain
/// convenient internal helpers for existing MiniQuake callers.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.

function SV_CheckBottom(server, entityIndex)
  return collision.checkBottom(server, entityIndex)
end function

/// Apply the Quake-compatible sv movestep behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param movement The movement input consumed by `SV_movestep`.
/// @param relink The relink input consumed by `SV_movestep`.
function SV_movestep(server, entityIndex, movement, relink)
  return moveStep(server, entityIndex, movement, relink)
end function

/// Apply the Quake-compatible sv step direction behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param yaw The yaw input consumed by `SV_StepDirection`.
/// @param distance The distance input consumed by `SV_StepDirection`.
function SV_StepDirection(server, entityIndex, yaw, distance)
  return stepDirection(server, entityIndex, yaw, distance)
end function

/// Apply the Quake-compatible sv fix check bottom behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function SV_FixCheckBottom(server, entityIndex)
  fixCheckBottom(server, entityIndex)
  return true
end function

/// Apply the Quake-compatible sv new chase dir behavior.
/// @param server Server state participating in the operation.
/// @param actor The actor input consumed by `SV_NewChaseDir`.
/// @param enemy The enemy input consumed by `SV_NewChaseDir`.
/// @param distance The distance input consumed by `SV_NewChaseDir`.
function SV_NewChaseDir(server, actor, enemy, distance)
  return newChaseDirection(server, actor, enemy, distance)
end function

/// Apply the Quake-compatible sv close enough behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param goalIndex Zero-based index of the requested entry.
/// @param distance The distance input consumed by `SV_CloseEnough`.
function SV_CloseEnough(server, entityIndex, goalIndex, distance)
  return closeEnough(server, entityIndex, goalIndex, distance)
end function

/// Apply the Quake-compatible sv move to goal behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param distance The distance input consumed by `SV_MoveToGoal`.
function SV_MoveToGoal(server, entityIndex, distance)
  return moveToGoal(server, entityIndex, distance)
end function

/// PF_changeyaw is declared in sv_move.c and implemented in pr_cmds.c.  This
/// explicit server hook completes the combined C/header pendant without
/// duplicating the QuakeC builtin.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function SV_ChangeYaw(server, entityIndex)
  return changeYaw(server, entityIndex)
end function
