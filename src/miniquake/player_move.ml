/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.player_move.
*/
package miniquake.player_move

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.world_bsp as world

/// Implements the `zeroVector` operation for `miniquake.player_move` (zero vector).
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `create` operation for `miniquake.player_move` (create).
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function create(origin, angles)
  return t.PlayerState(
    math.copy(origin),
    zeroVector(),
    math.copy(angles),
    math.copy(angles),
    t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z),
    t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z),
    c.PLAYER_VIEW_HEIGHT,
    false,
    0,
    c.MOVETYPE_WALK,
    100.0,
    0.0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    false,
    false,
    c.FL_CLIENT,
    0,
    c.CONTENTS_EMPTY,
    zeroVector(),
    false,
    0.0,
    zeroVector(),
    math.copy(origin),
    0,
  )
end function

/// Implements the `clipVelocity` operation for `miniquake.player_move` (clip velocity).
/// @param input The input input consumed by `clipVelocity`.
/// @param normal The normal input consumed by `clipVelocity`.
/// @param overbounce The overbounce input consumed by `clipVelocity`.
function clipVelocity(input, normal, overbounce)
  backoff = math.dot(input, normal) * overbounce
  output = t.Vec3(
    input.x - normal.x * backoff,
    input.y - normal.y * backoff,
    input.z - normal.z * backoff,
  )
  if output.x > -0.1 and output.x < 0.1 then output.x = 0.0 end if
  if output.y > -0.1 and output.y < 0.1 then output.y = 0.0 end if
  if output.z > -0.1 and output.z < 0.1 then output.z = 0.0 end if
  return output
end function

/// Implements the `horizontalSpeed` operation for `miniquake.player_move` (horizontal speed).
/// @param velocity Velocity applied by the operation.
function horizontalSpeed(velocity)
  return math.length(t.Vec3(velocity.x, velocity.y, 0.0))
end function

/// Validate water and report any incompatibility.
/// @param player The player input consumed by `checkWater`.
/// @param map The map input consumed by `checkWater`.
function checkWater(player, map)
  point = t.Vec3(player.origin.x, player.origin.y, player.origin.z + player.mins.z + 1.0)
  player.waterLevel = 0
  contents = world.pointContentsWorld(map, point)
  if contents <= c.CONTENTS_WATER then
    player.waterLevel = 1
    point.z = player.origin.z + (player.mins.z + player.maxs.z) * 0.5
    if world.pointContentsWorld(map, point) <= c.CONTENTS_WATER then
      player.waterLevel = 2
      point.z = player.origin.z + player.viewHeight
      if world.pointContentsWorld(map, point) <= c.CONTENTS_WATER then player.waterLevel = 3 end if
    end if
  end if
  return player.waterLevel > 1
end function

/// Validate ground and report any incompatibility.
/// @param player The player input consumed by `checkGround`.
/// @param map The map input consumed by `checkGround`.
function checkGround(player, map)
  finish = t.Vec3(player.origin.x, player.origin.y, player.origin.z - 2.0)
  trace = world.trace(map, player.origin, player.mins, player.maxs, finish)
  player.onGround = trace.fraction < 1.0 and not trace.startSolid and trace.plane.normal.z > 0.7
  if player.onGround then player.origin = trace.endPosition end if
  return player.onGround
end function

/// Implements the `userFriction` operation for `miniquake.player_move` (user friction).
/// @param player The player input consumed by `userFriction`.
/// @param map The map input consumed by `userFriction`.
/// @param frameTime Time value used by the operation.
/// @param friction The friction input consumed by `userFriction`.
/// @param edgeFriction The edge friction input consumed by `userFriction`.
/// @param stopSpeed The stop speed input consumed by `userFriction`.
function userFriction(player, map, frameTime, friction, edgeFriction, stopSpeed)
  speed = horizontalSpeed(player.velocity)
  if speed == 0.0 then return player end if

  start = t.Vec3(
    player.origin.x + player.velocity.x / speed * 16.0,
    player.origin.y + player.velocity.y / speed * 16.0,
    player.origin.z + player.mins.z,
  )
  finish = t.Vec3(start.x, start.y, start.z - 34.0)
  edgeTrace = world.traceLine(map, start, finish)
  appliedFriction = friction
  if edgeTrace.fraction == 1.0 then appliedFriction = friction * edgeFriction end if

  control = speed
  if control < stopSpeed then control = stopSpeed end if
  newSpeed = speed - frameTime * control * appliedFriction
  if newSpeed < 0.0 then newSpeed = 0.0 end if
  scale = newSpeed / speed
  player.velocity.x = player.velocity.x * scale
  player.velocity.y = player.velocity.y * scale
  player.velocity.z = player.velocity.z * scale
  return player
end function

/// Implements the `accelerate` operation for `miniquake.player_move` (accelerate).
/// @param player The player input consumed by `accelerate`.
/// @param wishDirection The wish direction input consumed by `accelerate`.
/// @param wishSpeed The wish speed input consumed by `accelerate`.
/// @param frameTime Time value used by the operation.
/// @param acceleration The acceleration input consumed by `accelerate`.
function accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
  currentSpeed = math.dot(player.velocity, wishDirection)
  addSpeed = wishSpeed - currentSpeed
  if addSpeed <= 0.0 then return player end if
  accelerationSpeed = acceleration * frameTime * wishSpeed
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, wishDirection)
  return player
end function

/// Implements the `airAccelerate` operation for `miniquake.player_move` (air accelerate).
/// @param player The player input consumed by `airAccelerate`.
/// @param wishVelocity The wish velocity input consumed by `airAccelerate`.
/// @param wishSpeed The wish speed input consumed by `airAccelerate`.
/// @param frameTime Time value used by the operation.
/// @param acceleration The acceleration input consumed by `airAccelerate`.
function airAccelerate(player, wishVelocity, wishSpeed, frameTime, acceleration)
  direction = math.normalize(wishVelocity)
  limitedSpeed = math.length(wishVelocity)
  if limitedSpeed > 30.0 then limitedSpeed = 30.0 end if
  currentSpeed = math.dot(player.velocity, direction)
  addSpeed = limitedSpeed - currentSpeed
  if addSpeed <= 0.0 then return player end if
  accelerationSpeed = acceleration * wishSpeed * frameTime
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, direction)
  return player
end function

/// Implements the `waterMove` operation for `miniquake.player_move` (water move).
/// @param player The player input consumed by `waterMove`.
/// @param command Console or protocol command to execute.
/// @param frameTime Time value used by the operation.
function waterMove(player, command, frameTime)
  vectors = math.angleVectors(player.viewAngles)
  forward = vectors[0]
  right = vectors[1]
  wishVelocity = t.Vec3(
    forward.x * command.forwardMove + right.x * command.sideMove,
    forward.y * command.forwardMove + right.y * command.sideMove,
    forward.z * command.forwardMove + right.z * command.sideMove,
  )
  if command.forwardMove == 0.0 and command.sideMove == 0.0 and command.upMove == 0.0 then
    wishVelocity.z = wishVelocity.z - 60.0
  else
    wishVelocity.z = wishVelocity.z + command.upMove
  end if

  wishSpeed = math.length(wishVelocity)
  if wishSpeed > c.DEFAULT_MAX_SPEED then
    wishVelocity = math.scale(wishVelocity, c.DEFAULT_MAX_SPEED / wishSpeed)
    wishSpeed = c.DEFAULT_MAX_SPEED
  end if
  wishSpeed = wishSpeed * 0.7

  speed = math.length(player.velocity)
  newSpeed = 0.0
  if speed > 0.0 then
    newSpeed = speed - frameTime * speed * c.DEFAULT_FRICTION
    if newSpeed < 0.0 then newSpeed = 0.0 end if
    player.velocity = math.scale(player.velocity, newSpeed / speed)
  end if
  if wishSpeed == 0.0 then return player end if
  addSpeed = wishSpeed - newSpeed
  if addSpeed <= 0.0 then return player end if
  wishDirection = math.normalize(wishVelocity)
  accelerationSpeed = c.DEFAULT_ACCELERATE * wishSpeed * frameTime
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, wishDirection)
  return player
end function

/// Implements the `wishMove` operation for `miniquake.player_move` (wish move).
/// @param player The player input consumed by `wishMove`.
/// @param command Console or protocol command to execute.
/// @param frameTime Time value used by the operation.
/// @param map The map input consumed by `wishMove`.
function wishMove(player, command, frameTime, map)
  movementAngles = t.Vec3(0.0, player.viewAngles.y, 0.0)
  vectors = math.angleVectors(movementAngles)
  forward = vectors[0]
  right = vectors[1]
  wishVelocity = t.Vec3(
    forward.x * command.forwardMove + right.x * command.sideMove,
    forward.y * command.forwardMove + right.y * command.sideMove,
    0.0,
  )
  if player.moveType != c.MOVETYPE_WALK then wishVelocity.z = command.upMove end if
  wishSpeed = math.length(wishVelocity)
  if wishSpeed > c.DEFAULT_MAX_SPEED then
    wishVelocity = math.scale(wishVelocity, c.DEFAULT_MAX_SPEED / wishSpeed)
    wishSpeed = c.DEFAULT_MAX_SPEED
  end if
  wishDirection = math.normalize(wishVelocity)

  if player.noclip or player.moveType == c.MOVETYPE_NOCLIP then
    player.velocity = wishVelocity
  else if player.onGround then
    userFriction(player, map, frameTime, c.DEFAULT_FRICTION, c.DEFAULT_EDGE_FRICTION, c.DEFAULT_STOP_SPEED)
    accelerate(player, wishDirection, wishSpeed, frameTime, c.DEFAULT_ACCELERATE)
  else
    airAccelerate(player, wishVelocity, wishSpeed, frameTime, c.DEFAULT_AIR_ACCELERATE)
  end if
  return player
end function

/// Implements the `slideMove` operation for `miniquake.player_move` (slide move).
/// @param player The player input consumed by `slideMove`.
/// @param map The map input consumed by `slideMove`.
/// @param frameTime Time value used by the operation.
function slideMove(player, map, frameTime)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  originalVelocity = math.copy(player.velocity)
  primalVelocity = math.copy(player.velocity)
  planes = []
  timeLeft = frameTime
  blocked = 0
  bump = 0
  while bump < 4
    if math.lengthSquared(player.velocity) == 0.0 then break end if
    finish = math.multiplyAdd(player.origin, timeLeft, player.velocity)
    trace = world.trace(map, player.origin, player.mins, player.maxs, finish)
    if trace.allSolid then
      player.velocity = zeroVector()
      return 3
    end if
    if trace.fraction > 0.0 then
      player.origin = trace.endPosition
      originalVelocity = math.copy(player.velocity)
      planes = []
    end if
    if trace.fraction == 1.0 then break end if
    if trace.plane.normal.z > 0.7 then
      blocked = blocked | 1
      player.onGround = true
    end if
    if trace.plane.normal.z == 0.0 then blocked = blocked | 2 end if
    timeLeft = timeLeft - timeLeft * trace.fraction
    if len(planes) >= 5 then
      player.velocity = zeroVector()
      return 3
    end if
    planes = planes + [math.copy(trace.plane.normal)]

    found = false
    newVelocity = zeroVector()
    planeIndex = 0
    while planeIndex < len(planes)
      candidate = clipVelocity(originalVelocity, planes[planeIndex], 1.0)
      okay = true
      otherIndex = 0
      while otherIndex < len(planes)
        if otherIndex != planeIndex and math.dot(candidate, planes[otherIndex]) < 0.0 then
          okay = false
          break
        end if
        otherIndex = otherIndex + 1
      end while
      if okay then
        newVelocity = candidate
        found = true
        break
      end if
      planeIndex = planeIndex + 1
    end while

    if found then
      player.velocity = newVelocity
    else if len(planes) == 2 then
      direction = math.cross(planes[0], planes[1])
      player.velocity = math.scale(direction, math.dot(direction, player.velocity))
    else
      player.velocity = zeroVector()
      return 7
    end if
    if math.dot(player.velocity, primalVelocity) <= 0.0 then
      player.velocity = zeroVector()
      return blocked
    end if
    bump = bump + 1
  end while
  return blocked
end function

/// Implements the `walkMove` operation for `miniquake.player_move` (walk move).
/// @param player The player input consumed by `walkMove`.
/// @param map The map input consumed by `walkMove`.
/// @param frameTime Time value used by the operation.
function walkMove(player, map, frameTime)
  wasOnGround = player.onGround
  oldOrigin = math.copy(player.origin)
  oldVelocity = math.copy(player.velocity)
  player.onGround = false
  blocked = slideMove(player, map, frameTime)
  if (blocked & 2) == 0 then return blocked end if
  if not wasOnGround and player.waterLevel == 0 then return blocked end if

  noStepOrigin = math.copy(player.origin)
  noStepVelocity = math.copy(player.velocity)
  player.origin = oldOrigin
  upFinish = t.Vec3(oldOrigin.x, oldOrigin.y, oldOrigin.z + c.DEFAULT_STEP_SIZE)
  upTrace = world.trace(map, oldOrigin, player.mins, player.maxs, upFinish)
  if upTrace.allSolid then
    player.origin = noStepOrigin
    player.velocity = noStepVelocity
    return blocked
  end if
  player.origin = upTrace.endPosition
  player.velocity = t.Vec3(oldVelocity.x, oldVelocity.y, 0.0)
  slideMove(player, map, frameTime)

  downFinish = t.Vec3(
    player.origin.x,
    player.origin.y,
    player.origin.z - c.DEFAULT_STEP_SIZE + oldVelocity.z * frameTime,
  )
  downTrace = world.trace(map, player.origin, player.mins, player.maxs, downFinish)
  if not downTrace.allSolid then player.origin = downTrace.endPosition end if
  if downTrace.fraction < 1.0 and downTrace.plane.normal.z > 0.7 then
    player.onGround = true
  else
    player.origin = noStepOrigin
    player.velocity = noStepVelocity
  end if
  return blocked
end function

/// Apply command to the active subsystem state.
/// @param player The player input consumed by `applyCommand`.
/// @param map The map input consumed by `applyCommand`.
/// @param command Console or protocol command to execute.
/// @param frameTime Time value used by the operation.
function applyCommand(player, map, command, frameTime)
  player.viewAngles = math.copy(command.viewAngles)
  player.renderAngles.x = -player.viewAngles.x / 3.0
  player.renderAngles.y = player.viewAngles.y
  player.renderAngles.z = 0.0

  if player.noclip then player.moveType = c.MOVETYPE_NOCLIP else player.moveType = c.MOVETYPE_WALK end if
  checkWater(player, map)
  checkGround(player, map)

  wantsJump = (command.buttons & c.BUTTON_JUMP) != 0
  if wantsJump and not player.jumpHeld and player.onGround and player.waterLevel < 2 and not player.noclip then
    player.velocity.z = 270.0
    player.onGround = false
  end if
  player.jumpHeld = wantsJump

  if player.waterLevel >= 2 and not player.noclip then
    waterMove(player, command, frameTime)
    slideMove(player, map, frameTime)
  else
    wishMove(player, command, frameTime, map)
    if player.noclip then
      player.origin = math.multiplyAdd(player.origin, frameTime, player.velocity)
    else
      if not player.onGround then player.velocity.z = player.velocity.z - c.DEFAULT_GRAVITY * frameTime end if
      walkMove(player, map, frameTime)
      checkGround(player, map)
    end if
  end if
  return player
end function

/// Return camera origin derived from the active module state.
/// @param player The player input consumed by `cameraOrigin`.
function cameraOrigin(player)
  return t.Vec3(player.origin.x, player.origin.y, player.origin.z + player.viewHeight)
end function

/// Create and initialize player.
/// @param origin World-space origin of the operation.
/// @param angles Orientation angles used by the operation.
function createPlayer(origin, angles)
  return create(origin, angles)
end function

/// Transfer data for move.
/// @param player The player input consumed by `move`.
/// @param map The map input consumed by `move`.
/// @param command Console or protocol command to execute.
/// @param frameTime Time value used by the operation.
/// @param registry The registry input consumed by `move`.
function move(player, map, command, frameTime, registry)
  return applyCommand(player, map, command, frameTime)
end function
