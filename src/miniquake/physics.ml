/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.physics.
*/
package miniquake.physics

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as world
import miniquake.server_collision as collision
import miniquake.cvar as cvar
import miniquake.quakec.vm as vm

const STOP_EPSILON = 0.1
const STEP_SIZE = 18.0
const MAX_CLIP_PLANES = 5
// These two movetypes are present in the QUAKE2-conditioned half of the
// pinned MiniQuake source.  Keep them private to this pendant so the shared
// protocol/constants surface remains the stock Quake 1 one.
const MOVETYPE_BOUNCEMISSILE_COMPAT = 11
const MOVETYPE_FOLLOW_COMPAT = 12

// Create the zero-initialized state for vector.
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

// The compatibility profile in this port is the unconditioned WinQuake /
// MiniQuake 1.09 source, never the optional QUAKE2 preprocessor branch.
function strictQuake109()
  return true
end function

// Provide collapse pusher corpse bounds behavior for the active subsystem.
function collapsePusherCorpseBounds(mins)
  return t.Vec3(0.0, 0.0, mins.z)
end function

// Create and initialize player.
function createPlayer(origin, angles)
  return t.PlayerState(
    math.copy(origin),
    zeroVector(),
    math.copy(angles),
    math.copy(angles),
    t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z),
    t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z),
    c.DEFAULT_VIEWHEIGHT,
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

// Return horizontal length derived from the active module state.
function horizontalLength(value)
  return math.length(t.Vec3(value.x, value.y, 0.0))
end function

// Trace velocity through the collision world.
function clipVelocity(input, normal, overbounce)
  blocked = 0
  if normal.z > 0.0 then blocked = blocked | 1 end if
  if normal.z == 0.0 then blocked = blocked | 2 end if
  backoff = math.dot(input, normal) * overbounce
  output = math.subtract(input, math.scale(normal, backoff))
  if output.x > -STOP_EPSILON and output.x < STOP_EPSILON then output.x = 0.0 end if
  if output.y > -STOP_EPSILON and output.y < STOP_EPSILON then output.y = 0.0 end if
  if output.z > -STOP_EPSILON and output.z < STOP_EPSILON then output.z = 0.0 end if
  return [output, blocked]
end function

// Trace move through the collision world.
function traceMove(server, map, entityIndex, start, mins, maxs, finish, moveType)
  if server is void then return world.trace(map, start, mins, maxs, finish) end if
  return collision.move(server, start, mins, maxs, finish, moveType, entityIndex)
end function

// Provide mark ground behavior for the active subsystem.
function markGround(player, entityIndex)
  player.onGround = true
  player.flags = player.flags | c.FL_ONGROUND
  player.groundEntity = entityIndex
end function

// Update module state for ground.
function clearGround(player)
  player.onGround = false
  player.flags = player.flags & ~c.FL_ONGROUND
  // SV_Physics_Client clears FL_ONGROUND but leaves groundentity untouched.
  // Keeping the last valid edict prevents an internal -1 sentinel from being
  // serialized as the invalid QuakeC entity value 0xffffffff.
end function

// SV_FlyMove: the original four-bump, five-plane clipping algorithm.  The
// detailed form also returns the last vertical wall trace used by
// SV_WallFriction during step movement.
function flyMoveDetailed(player, map, server, entityIndex, frameTime)
  originalVelocity = math.copy(player.velocity)
  primalVelocity = math.copy(player.velocity)
  planes = []
  stepTrace = void
  timeLeft = frameTime
  blocked = 0
  bump = 0
  while bump < 4
    if player.velocity.x == 0.0 and player.velocity.y == 0.0 and player.velocity.z == 0.0 then break end if
    finish = math.multiplyAdd(player.origin, timeLeft, player.velocity)
    trace = traceMove(server, map, entityIndex, player.origin, player.mins, player.maxs, finish, c.MOVE_NORMAL)
    if trace.allSolid then
      player.velocity = zeroVector()
      return [3, stepTrace]
    end if
    if trace.fraction > 0.0 then
      player.origin = math.copy(trace.endPosition)
      originalVelocity = math.copy(player.velocity)
      planes = []
    end if
    if trace.fraction == 1.0 then break end if

    if trace.plane.normal.z > 0.7 then
      blocked = blocked | 1
      solid = c.SOLID_BSP
      if server is not void and trace.entity > 0 then solid = nativeSolid(server, trace.entity) end if
      if solid == c.SOLID_BSP then markGround(player, trace.entity) end if
    end if
    if trace.plane.normal.z == 0.0 then
      blocked = blocked | 2
      stepTrace = trace
    end if
    if server is not void and trace.entity >= 0 then collision.impact(server, entityIndex, trace.entity) end if
    // SV_Impact is allowed to execute QuakeC remove(self). WinQuake stops the
    // current SV_FlyMove immediately in that case; clipping the now-freed
    // edict can otherwise produce a second impact and resurrect cleared
    // velocity/origin fields through the MiniQuake PlayerState mirror.
    if server is not void and physicsEntityFree(server, entityIndex) then break end if

    timeLeft = timeLeft - timeLeft * trace.fraction
    if len(planes) >= MAX_CLIP_PLANES then
      player.velocity = zeroVector()
      return [3, stepTrace]
    end if
    planes = planes + [math.copy(trace.plane.normal)]

    accepted = false
    newVelocity = zeroVector()
    planeIndex = 0
    while planeIndex < len(planes)
      clipped = clipVelocity(originalVelocity, planes[planeIndex], 1.0)[0]
      valid = true
      other = 0
      while other < len(planes)
        if other != planeIndex and math.dot(clipped, planes[other]) < 0.0 then valid = false; break end if
        other = other + 1
      end while
      if valid then newVelocity = clipped; accepted = true; break end if
      planeIndex = planeIndex + 1
    end while

    if accepted then
      player.velocity = newVelocity
    else if len(planes) == 2 then
      direction = math.cross(planes[0], planes[1])
      player.velocity = math.scale(direction, math.dot(direction, player.velocity))
    else
      player.velocity = zeroVector()
      return [7, stepTrace]
    end if
    if math.dot(player.velocity, primalVelocity) <= 0.0 then
      player.velocity = zeroVector()
      return [blocked, stepTrace]
    end if
    bump = bump + 1
  end while
  return [blocked, stepTrace]
end function

// Provide fly move internal behavior for the active subsystem.
function flyMoveInternal(player, map, server, entityIndex, frameTime)
  return flyMoveDetailed(player, map, server, entityIndex, frameTime)[0]
end function

// Provide native solid behavior for the active subsystem.
function nativeSolid(server, entityIndex)
  if entityIndex == 0 then return c.SOLID_BSP end if
  return native.trunc(collision.entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
end function

// Provide fly move behavior for the active subsystem.
function flyMove(player, map, frameTime)
  return flyMoveInternal(player, map, void, -1, frameTime)
end function

// Provide position distance squared behavior for the active subsystem.
function positionDistanceSquared(a, b)
  dx = a.x - b.x
  dy = a.y - b.y
  return dx * dx + dy * dy
end function

// Add state for push player.
function pushPlayer(server, map, entityIndex, player, move)
  target = math.add(player.origin, move)
  trace = traceMove(server, map, entityIndex, player.origin, player.mins, player.maxs, target, c.MOVE_NORMAL)
  player.origin = math.copy(trace.endPosition)
  if server is not void and trace.entity >= 0 and trace.fraction < 1.0 then collision.impact(server, entityIndex, trace.entity) end if
  return trace
end function

// Provide wall friction behavior for the active subsystem.
function wallFriction(player, plane)
  vectors = math.angleVectors(player.viewAngles)
  forward = vectors[0]
  d = math.dot(plane.normal, forward) + 0.5
  if d >= 0.0 then return end if
  into = math.scale(plane.normal, math.dot(plane.normal, player.velocity))
  side = math.subtract(player.velocity, into)
  player.velocity.x = side.x * (1.0 + d)
  player.velocity.y = side.y * (1.0 + d)
end function

// Provide try unstick behavior for the active subsystem.
function tryUnstick(player, map, server, entityIndex, oldVelocity)
  oldOrigin = math.copy(player.origin)
  directions = [
    t.Vec3(2.0, 0.0, 0.0),
    t.Vec3(0.0, 2.0, 0.0),
    t.Vec3(-2.0, 0.0, 0.0),
    t.Vec3(0.0, -2.0, 0.0),
    t.Vec3(2.0, 2.0, 0.0),
    t.Vec3(-2.0, 2.0, 0.0),
    t.Vec3(2.0, -2.0, 0.0),
    t.Vec3(-2.0, -2.0, 0.0),
  ]
  for each direction in directions
    pushPlayer(server, map, entityIndex, player, direction)
    player.velocity = t.Vec3(oldVelocity.x, oldVelocity.y, 0.0)
    clip = flyMoveInternal(player, map, server, entityIndex, 0.1)
    dx = player.origin.x - oldOrigin.x
    dy = player.origin.y - oldOrigin.y
    if dx > 4.0 or dx < -4.0 or dy > 4.0 or dy < -4.0 then return clip end if
    player.origin = math.copy(oldOrigin)
  end for
  player.velocity = zeroVector()
  return 7
end function

// Provide walk move internal behavior for the active subsystem.
function walkMoveInternal(player, map, server, entityIndex, frameTime)
  oldOnGround = (player.flags & c.FL_ONGROUND) != 0
  clearGround(player)
  oldOrigin = math.copy(player.origin)
  oldVelocity = math.copy(player.velocity)
  firstMove = flyMoveDetailed(player, map, server, entityIndex, frameTime)
  clip = firstMove[0]
  if (clip & 2) == 0 then return clip end if
  if not oldOnGround and player.waterLevel == 0 then return clip end if
  if player.moveType != c.MOVETYPE_WALK then return clip end if
  if (player.flags & c.FL_WATERJUMP) != 0 then return clip end if

  noStepOrigin = math.copy(player.origin)
  noStepVelocity = math.copy(player.velocity)

  // Back up and try the classic 18-unit up/forward/down stair path.
  player.origin = math.copy(oldOrigin)
  pushPlayer(server, map, entityIndex, player, t.Vec3(0.0, 0.0, STEP_SIZE))
  player.velocity = t.Vec3(oldVelocity.x, oldVelocity.y, 0.0)
  steppedMove = flyMoveDetailed(player, map, server, entityIndex, frameTime)
  stepClip = steppedMove[0]
  stepTrace = steppedMove[1]

  dx = player.origin.x - oldOrigin.x
  dy = player.origin.y - oldOrigin.y
  if stepClip != 0 and dx > -0.03125 and dx < 0.03125 and dy > -0.03125 and dy < 0.03125 then
    stepClip = tryUnstick(player, map, server, entityIndex, oldVelocity)
  end if
  if (stepClip & 2) != 0 and stepTrace is not void then wallFriction(player, stepTrace.plane) end if

  downMove = t.Vec3(0.0, 0.0, -STEP_SIZE + oldVelocity.z * frameTime)
  downTrace = pushPlayer(server, map, entityIndex, player, downMove)
  if downTrace.plane.normal.z > 0.7 then
    solid = c.SOLID_BSP
    if server is not void and downTrace.entity > 0 then solid = nativeSolid(server, downTrace.entity) end if
    if solid == c.SOLID_BSP then markGround(player, downTrace.entity) end if
  else
    // Near a wall/slope corner the step path can land on an unclimbable face;
    // retain the ordinary slide move in that case.
    player.origin = noStepOrigin
    player.velocity = noStepVelocity
  end if
  return clip
end function

// Advance move by one processing step.
function stepMove(player, map, frameTime)
  return walkMoveInternal(player, map, void, -1, frameTime)
end function

// A diagnostic ground probe. Runtime physics intentionally does not snap the
// player down every frame; WinQuake derives FL_ONGROUND from actual movement
// impacts. The former repeated two-unit snap caused the visible fall/push loop.
function checkGround(player, map)
  target = math.subtract(player.origin, t.Vec3(0.0, 0.0, 2.0))
  trace = world.trace(map, player.origin, player.mins, player.maxs, target)
  if not trace.startSolid and trace.fraction < 1.0 and trace.plane.normal.z > 0.7 then
    markGround(player, 0)
    if player.velocity.z < 0.0 then player.velocity.z = 0.0 end if
    return true
  end if
  clearGround(player)
  return false
end function

// Update module state for water level.
function updateWaterLevel(player, map)
  player.waterLevel = 0
  player.waterType = c.CONTENTS_EMPTY
  feet = math.add(player.origin, t.Vec3(0.0, 0.0, player.mins.z + 1.0))
  contents = world.pointContentsWorld(map, feet)
  if contents <= c.CONTENTS_WATER then
    player.waterType = contents
    player.waterLevel = 1
    waist = math.add(player.origin, t.Vec3(0.0, 0.0, (player.mins.z + player.maxs.z) * 0.5))
    contents = world.pointContentsWorld(map, waist)
    if contents <= c.CONTENTS_WATER then
      player.waterLevel = 2
      eyes = math.add(player.origin, t.Vec3(0.0, 0.0, player.viewHeight))
      contents = world.pointContentsWorld(map, eyes)
      if contents <= c.CONTENTS_WATER then player.waterLevel = 3 end if
    end if
  end if
  return player.waterLevel
end function

// Apply friction to the active subsystem state.
function applyFriction(player, map, server, entityIndex, frameTime, friction, edgeFriction, stopSpeed)
  speed = horizontalLength(player.velocity)
  if speed == 0.0 then return end if
  start = t.Vec3(
    player.origin.x + player.velocity.x / speed * 16.0,
    player.origin.y + player.velocity.y / speed * 16.0,
    player.origin.z + player.mins.z,
  )
  stop = t.Vec3(start.x, start.y, start.z - 34.0)
  point = zeroVector()
  edgeTrace = traceMove(server, map, entityIndex, start, point, point, stop, c.MOVE_NOMONSTERS)
  applied = friction
  if edgeTrace.fraction == 1.0 then applied = friction * edgeFriction end if
  control = speed
  if control < stopSpeed then control = stopSpeed end if
  newSpeed = speed - frameTime * control * applied
  if newSpeed < 0.0 then newSpeed = 0.0 end if
  scale = newSpeed / speed
  player.velocity.x = player.velocity.x * scale
  player.velocity.y = player.velocity.y * scale
  player.velocity.z = player.velocity.z * scale
end function

// Provide accelerate behavior for the active subsystem.
function accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
  currentSpeed = math.dot(player.velocity, wishDirection)
  addSpeed = wishSpeed - currentSpeed
  if addSpeed <= 0.0 then return end if
  accelerationSpeed = acceleration * frameTime * wishSpeed
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, wishDirection)
end function

// Provide air accelerate behavior for the active subsystem.
function airAccelerate(player, wishVelocity, wishSpeed, frameTime, acceleration)
  direction = math.normalize(wishVelocity)
  limitedSpeed = math.length(wishVelocity)
  if limitedSpeed > 30.0 then limitedSpeed = 30.0 end if
  currentSpeed = math.dot(player.velocity, direction)
  addSpeed = limitedSpeed - currentSpeed
  if addSpeed <= 0.0 then return end if
  accelerationSpeed = acceleration * wishSpeed * frameTime
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, direction)
end function

// Provide water move behavior for the active subsystem.
function waterMove(player, command, frameTime, maxSpeed, acceleration, friction)
  vectors = math.angleVectors(player.viewAngles)
  wishVelocity = math.add(math.scale(vectors[0], command.forwardMove), math.scale(vectors[1], command.sideMove))
  if command.forwardMove == 0.0 and command.sideMove == 0.0 and command.upMove == 0.0 then wishVelocity.z = wishVelocity.z - 60.0 else wishVelocity.z = wishVelocity.z + command.upMove end if
  wishSpeed = math.length(wishVelocity)
  if wishSpeed > maxSpeed then wishVelocity = math.scale(wishVelocity, maxSpeed / wishSpeed); wishSpeed = maxSpeed end if
  wishSpeed = wishSpeed * 0.7
  speed = math.length(player.velocity)
  newSpeed = speed
  if speed > 0.0 then
    newSpeed = speed - frameTime * speed * friction
    if newSpeed < 0.0 then newSpeed = 0.0 end if
    player.velocity = math.scale(player.velocity, newSpeed / speed)
  end if
  if wishSpeed == 0.0 then return end if
  addSpeed = wishSpeed - newSpeed
  if addSpeed <= 0.0 then return end if
  wishDirection = math.normalize(wishVelocity)
  accelerationSpeed = acceleration * wishSpeed * frameTime
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, wishDirection)
end function

// Release state for drop punch angle.
function dropPunchAngle(player, frameTime)
  magnitude = math.length(player.punchAngle)
  if magnitude == 0.0 then return end if
  direction = math.scale(player.punchAngle, 1.0 / magnitude)
  magnitude = magnitude - 10.0 * frameTime
  if magnitude < 0.0 then magnitude = 0.0 end if
  player.punchAngle = math.scale(direction, magnitude)
end function

// Provide air move behavior for the active subsystem.
function airMove(player, command, frameTime, maxSpeed, acceleration, friction, edgeFriction, stopSpeed, map, server, entityIndex)
  // WinQuake passes the complete ent->v.angles vector to AngleVectors. Pitch
  // therefore contributes to noclip/fly intentions; WALK still clears the
  // vertical wish component below, exactly like sv_user.c.
  movementAngles = math.copy(player.renderAngles)
  vectors = math.angleVectors(movementAngles)
  forwardMove = command.forwardMove
  if server is not void and server.time < player.teleportTime and forwardMove < 0.0 then forwardMove = 0.0 end if
  wishVelocity = math.add(math.scale(vectors[0], forwardMove), math.scale(vectors[1], command.sideMove))
  if player.moveType != c.MOVETYPE_WALK then wishVelocity.z = command.upMove else wishVelocity.z = 0.0 end if
  wishSpeed = math.length(wishVelocity)
  if wishSpeed > maxSpeed then wishVelocity = math.scale(wishVelocity, maxSpeed / wishSpeed); wishSpeed = maxSpeed end if
  wishDirection = math.normalize(wishVelocity)
  if player.moveType == c.MOVETYPE_NOCLIP or player.noclip then
    player.velocity = wishVelocity
  else if player.onGround then
    applyFriction(player, map, server, entityIndex, frameTime, friction, edgeFriction, stopSpeed)
    accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
  else
    airAccelerate(player, wishVelocity, wishSpeed, frameTime, acceleration)
  end if
end function

// Validate stuck and report any incompatibility.
function checkStuck(player, map, server, entityIndex)
  if server is void then return false end if
  if collision.testEntityPosition(server, entityIndex) < 0 then
    player.oldOrigin = math.copy(player.origin)
    return false
  end if
  original = math.copy(player.origin)
  player.origin = math.copy(player.oldOrigin)
  collision.setEntityVector(server, entityIndex, "origin", player.origin)
  if collision.testEntityPosition(server, entityIndex) < 0 then return true end if
  player.origin = original
  z = 0
  while z < 18
    x = -1
    while x <= 1
      y = -1
      while y <= 1
        player.origin = t.Vec3(original.x + x, original.y + y, original.z + z)
        collision.setEntityVector(server, entityIndex, "origin", player.origin)
        if collision.testEntityPosition(server, entityIndex) < 0 then return true end if
        y = y + 1
      end while
      x = x + 1
    end while
    z = z + 1
  end while
  player.origin = original
  collision.setEntityVector(server, entityIndex, "origin", player.origin)
  return false
end function

// Transfer data for movement settings.
function movementSettings(registry)
  maxSpeed = cvar.variableValue(registry, "sv_maxspeed")
  if maxSpeed <= 0.0 then maxSpeed = 320.0 end if
  acceleration = cvar.variableValue(registry, "sv_accelerate")
  if acceleration <= 0.0 then acceleration = 10.0 end if
  friction = cvar.variableValue(registry, "sv_friction")
  if friction <= 0.0 then friction = 4.0 end if
  edgeFriction = cvar.variableValue(registry, "edgefriction")
  if edgeFriction <= 0.0 then edgeFriction = 2.0 end if
  stopSpeed = cvar.variableValue(registry, "sv_stopspeed")
  if stopSpeed <= 0.0 then stopSpeed = 100.0 end if
  gravity = cvar.variableValue(registry, "sv_gravity")
  if gravity <= 0.0 then gravity = 800.0 end if
  maxVelocity = cvar.variableValue(registry, "sv_maxvelocity")
  if maxVelocity <= 0.0 then maxVelocity = 2000.0 end if
  return [maxSpeed, acceleration, friction, edgeFriction, stopSpeed, gravity, maxVelocity]
end function

// Return a validated clamp velocity value.
function clampVelocity(player, maximum)
  if player.velocity.x > maximum then player.velocity.x = maximum end if
  if player.velocity.x < -maximum then player.velocity.x = -maximum end if
  if player.velocity.y > maximum then player.velocity.y = maximum end if
  if player.velocity.y < -maximum then player.velocity.y = -maximum end if
  if player.velocity.z > maximum then player.velocity.z = maximum end if
  if player.velocity.z < -maximum then player.velocity.z = -maximum end if
end function

// Provide client think behavior for the active subsystem.
function clientThink(player, command, frameTime, settings, map, server, entityIndex)
  if player.moveType == c.MOVETYPE_NONE then return end if
  dropPunchAngle(player, frameTime)
  if player.health <= 0.0 then return end if
  viewWithPunch = math.add(player.viewAngles, player.punchAngle)
  if not player.fixAngle then
    player.renderAngles.x = -viewWithPunch.x / 3.0
    player.renderAngles.y = viewWithPunch.y
  end if
  if (player.flags & c.FL_WATERJUMP) != 0 then
    if server is not void and (server.time > player.teleportTime or player.waterLevel == 0) then
      player.flags = player.flags & ~c.FL_WATERJUMP
      player.teleportTime = 0.0
    end if
    player.velocity.x = player.moveDir.x
    player.velocity.y = player.moveDir.y
    return
  end if
  if player.waterLevel >= 2 and player.moveType != c.MOVETYPE_NOCLIP then
    waterMove(player, command, frameTime, settings[0], settings[1], settings[2])
    return
  end if
  airMove(player, command, frameTime, settings[0], settings[1], settings[2], settings[3], settings[4], map, server, entityIndex)
end function

// Transfer data for move server.
function moveServer(player, server, entityIndex, command, frameTime, registry)
  if frameTime <= 0.0 then return player end if
  if frameTime > 0.1 then frameTime = 0.1 end if
  player.viewAngles = math.copy(command.viewAngles)
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  settings = movementSettings(registry)
  updateWaterLevel(player, server.worldModel)
  clientThink(player, command, frameTime, settings, server.worldModel, server, entityIndex)
  clampVelocity(player, settings[6])

  if player.moveType == c.MOVETYPE_NONE then
    physicsWritePlayerEdict(server, entityIndex, player)
    collision.linkEntity(server, entityIndex, true)
    return player
  end if
  if player.moveType == c.MOVETYPE_NOCLIP or player.noclip then
    player.origin = math.multiplyAdd(player.origin, frameTime, player.velocity)
    clearGround(player)
    physicsWritePlayerEdict(server, entityIndex, player)
    collision.linkEntity(server, entityIndex, true)
    return player
  end if
  if player.moveType == c.MOVETYPE_FLY then
    flyMoveInternal(player, server.worldModel, server, entityIndex, frameTime)
    if physicsEntityFree(server, entityIndex) then return player end if
    physicsWritePlayerEdict(server, entityIndex, player)
    collision.linkEntity(server, entityIndex, true)
    return player
  end if
  if player.moveType != c.MOVETYPE_WALK then
    physicsWritePlayerEdict(server, entityIndex, player)
    collision.linkEntity(server, entityIndex, true)
    return player
  end if

  if player.waterLevel <= 1 and (player.flags & c.FL_WATERJUMP) == 0 then
    player.velocity.z = player.velocity.z - settings[5] * frameTime
  end if
  checkStuck(player, server.worldModel, server, entityIndex)
  walkMoveInternal(player, server.worldModel, server, entityIndex, frameTime)
  if physicsEntityFree(server, entityIndex) then return player end if
  // In the C engine the client physics state and the QuakeC entvars are the
  // same edict.  PlayerState is a MiniQuake-side mirror, so publish the full
  // physical result before SV_LinkEdict runs trigger callbacks.  Publishing
  // only origin left velocity/flags stale and made a later full pull unsafe.
  physicsWritePlayerEdict(server, entityIndex, player)
  // SV_LinkEdict(..., true) executes trigger QuakeC synchronously.  ItemTouch,
  // teleports and other triggers may mutate health, inventory, velocity or
  // origin on the authoritative edict.  The host-owned PlayerState must pull
  // those mutations back before PlayerPostThink; otherwise the subsequent
  // syncPlayerToQuakeC writes its stale pre-touch values over the callback.
  collision.linkEntity(server, entityIndex, true)
  return player
end function

// World-only compatibility path used by the synthetic tests and diagnostic
// tools. It mirrors the server path without dynamic edicts or QuakeC impacts.
function move(player, map, command, frameTime, registry)
  if frameTime <= 0.0 then return player end if
  if frameTime > 0.1 then frameTime = 0.1 end if
  player.viewAngles = math.copy(command.viewAngles)
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  settings = movementSettings(registry)
  updateWaterLevel(player, map)
  clientThink(player, command, frameTime, settings, map, void, -1)
  if player.noclip or player.moveType == c.MOVETYPE_NOCLIP then
    player.origin = math.multiplyAdd(player.origin, frameTime, player.velocity)
    clearGround(player)
    return player
  end if
  if player.waterLevel <= 1 and (player.flags & c.FL_WATERJUMP) == 0 then player.velocity.z = player.velocity.z - settings[5] * frameTime end if
  walkMoveInternal(player, map, void, -1, frameTime)
  return player
end function

// --------------------------------------------------------------------------
// sv_phys.c compatibility surface
//
// The lower-case helpers above are the convenient PlayerState API used by the
// local client.  The functions below are the edict-oriented MiniQuake API.  They
// intentionally keep the original names and ordering rules so protocol tests,
// QuakeC and server code can use the same behavioral units as sv_phys.c.

function physicsEntityCount(server)
  if server is void or server.machine is void or server.machine.context is void then return 0 end if
  return server.machine.context.edicts.numEdicts
end function

// Apply server-physics entity free semantics.
function physicsEntityFree(server, entityIndex)
  if server is void or server.machine is void or server.machine.context is void then return true end if
  runtime = server.machine.context.edicts
  if entityIndex < 0 or entityIndex >= runtime.numEdicts then return true end if
  return runtime.freeFlags[entityIndex]
end function

// Apply server-physics has base velocity semantics.
function physicsHasBaseVelocity(server)
  return collision.fieldOffset(server, "basevelocity") >= 0
end function

// Apply server-physics vector is zero semantics.
function physicsVectorIsZero(value)
  return value.x == 0.0 and value.y == 0.0 and value.z == 0.0
end function

// The QUAKE2-conditioned MiniQuake branches use the presence of the extended
// entvars layout.  Testing the field is the MiniLang equivalent: stock v6
// progs.dat files have no basevelocity and therefore stay on the 1.09 path.
function physicsRefreshConveyorVelocity(server, entityIndex)
  baseVelocity = zeroVector()
  groundEntity = collision.entityWord(server, entityIndex, "groundentity", 0)
  if groundEntity >= 0 and groundEntity < physicsEntityCount(server) then
    groundFlags = native.trunc(collision.entityFloat(server, groundEntity, "flags", 0.0))
    if (groundFlags & c.FL_CONVEYOR) != 0 then
      moveDirection = collision.entityVectorZero(server, groundEntity, "movedir")
      speed = collision.entityFloat(server, groundEntity, "speed", 0.0)
      baseVelocity = math.scale(moveDirection, speed)
    end if
  end if
  collision.setEntityVector(server, entityIndex, "basevelocity", baseVelocity)
  return baseVelocity
end function

// Apply server-physics player from edict semantics.
function physicsPlayerFromEdict(server, entityIndex)
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  angles = collision.entityVectorZero(server, entityIndex, "v_angle")
  player = createPlayer(origin, angles)
  player.velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  player.renderAngles = collision.entityVectorZero(server, entityIndex, "angles")
  player.mins = collision.entityVector(server, entityIndex, "mins", player.mins)
  player.maxs = collision.entityVector(server, entityIndex, "maxs", player.maxs)
  viewOffset = collision.entityVector(server, entityIndex, "view_ofs", t.Vec3(0.0, 0.0, c.DEFAULT_VIEWHEIGHT))
  player.viewHeight = viewOffset.z
  player.waterLevel = native.trunc(collision.entityFloat(server, entityIndex, "waterlevel", 0.0))
  player.waterType = native.trunc(collision.entityFloat(server, entityIndex, "watertype", c.CONTENTS_EMPTY))
  player.moveType = native.trunc(collision.entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  player.health = collision.entityFloat(server, entityIndex, "health", 0.0)
  player.flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  player.groundEntity = collision.entityWord(server, entityIndex, "groundentity", 0)
  player.oldOrigin = collision.entityVector(server, entityIndex, "oldorigin", origin)
  player.teleportTime = collision.entityFloat(server, entityIndex, "teleport_time", 0.0)
  player.moveDir = collision.entityVectorZero(server, entityIndex, "movedir")
  return player
end function

// Apply server-physics write player edict semantics.
function physicsWritePlayerEdict(server, entityIndex, player)
  collision.setEntityVector(server, entityIndex, "origin", player.origin)
  collision.setEntityVector(server, entityIndex, "oldorigin", player.oldOrigin)
  collision.setEntityVector(server, entityIndex, "velocity", player.velocity)
  collision.setEntityVector(server, entityIndex, "angles", player.renderAngles)
  collision.setEntityVector(server, entityIndex, "v_angle", player.viewAngles)
  collision.setEntityVector(server, entityIndex, "punchangle", player.punchAngle)
  collision.setEntityVector(server, entityIndex, "movedir", player.moveDir)
  collision.setEntityFloat(server, entityIndex, "movetype", player.moveType)
  collision.setEntityFloat(server, entityIndex, "flags", player.flags)
  collision.setEntityWord(server, entityIndex, "groundentity", player.groundEntity)
  collision.setEntityFloat(server, entityIndex, "waterlevel", player.waterLevel)
  collision.setEntityFloat(server, entityIndex, "watertype", player.waterType)
  collision.setEntityFloat(server, entityIndex, "teleport_time", player.teleportTime)
  return player
end function

// Apply server-physics queue sound semantics.
function physicsQueueSound(server, entityIndex, sample)
  if server is void or server.machine is void or server.machine.context is void then return false end if
  contextValue = server.machine.context
  contextValue.soundEvents = contextValue.soundEvents + [[entityIndex, 0, sample, 255, 1.0]]
  return true
end function

// Apply server-physics execute entity function semantics.
function physicsExecuteEntityFunction(server, entityIndex, otherIndex, fieldName, executionTime)
  functionIndex = collision.entityWord(server, entityIndex, fieldName, 0)
  if functionIndex == 0 then return false end if
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, executionTime)
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.execute(server.machine, functionIndex)
  return true
end function

// Apply server-physics execute named function semantics.
function physicsExecuteNamedFunction(server, functionName, entityIndex)
  functionIndex = vm.functionIndex(server.machine, functionName)
  if functionIndex == 0 then return false end if
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, server.time)
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.execute(server.machine, functionIndex)
  return true
end function

// SV_CheckAllEnts is a diagnostic pass in MiniQuake. Return the offending edict
// indexes as well as appending the original diagnostic text.
function SV_CheckAllEnts(server)
  invalid = []
  index = 1
  while index < physicsEntityCount(server)
    if not physicsEntityFree(server, index) then
      moveType = native.trunc(collision.entityFloat(server, index, "movetype", c.MOVETYPE_NONE))
      if moveType != c.MOVETYPE_PUSH and moveType != c.MOVETYPE_NONE and moveType != c.MOVETYPE_NOCLIP then
        if collision.testEntityPosition(server, index) >= 0 then
          invalid = invalid + [index]
          server.diagnostics = server.diagnostics + ["entity in invalid position"]
        end if
      end if
    end if
    index = index + 1
  end while
  return invalid
end function

// Apply the Quake-compatible sv check velocity behavior.
function SV_CheckVelocity(server, entityIndex, maxVelocity)
  maximum = maxVelocity
  if maximum <= 0.0 then maximum = 2000.0 end if
  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  className = collision.entityString(server, entityIndex, "classname", "")
  if math.IS_NAN(velocity.x) then velocity.x = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN velocity on " + className] end if
  if math.IS_NAN(velocity.y) then velocity.y = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN velocity on " + className] end if
  if math.IS_NAN(velocity.z) then velocity.z = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN velocity on " + className] end if
  if math.IS_NAN(origin.x) then origin.x = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN origin on " + className] end if
  if math.IS_NAN(origin.y) then origin.y = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN origin on " + className] end if
  if math.IS_NAN(origin.z) then origin.z = 0.0; server.diagnostics = server.diagnostics + ["Got a NaN origin on " + className] end if
  velocity.x = math.clamp(velocity.x, -maximum, maximum)
  velocity.y = math.clamp(velocity.y, -maximum, maximum)
  velocity.z = math.clamp(velocity.z, -maximum, maximum)
  collision.setEntityVector(server, entityIndex, "velocity", velocity)
  collision.setEntityVector(server, entityIndex, "origin", origin)
  return velocity
end function

// Apply the Quake-compatible sv run think behavior.
function SV_RunThink(server, entityIndex, frameTime)
  thinkTime = collision.entityFloat(server, entityIndex, "nextthink", 0.0)
  if thinkTime <= 0.0 or thinkTime > server.time + frameTime then return true end if
  if thinkTime < server.time then thinkTime = server.time end if
  collision.setEntityFloat(server, entityIndex, "nextthink", 0.0)
  thinkFunction = collision.entityWord(server, entityIndex, "think", 0)
  if thinkFunction == 0 then return error(3412, "PR_ExecuteProgram: NULL function") end if
  vm.setGlobalFloat(server.machine, c.QC_GLOBAL_TIME, thinkTime)
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, entityIndex)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, 0)
  vm.execute(server.machine, thinkFunction)
  return not physicsEntityFree(server, entityIndex)
end function

// Apply the Quake-compatible sv impact behavior.
function SV_Impact(server, firstEntity, secondEntity)
  oldSelf = vm.word(server.machine, c.QC_GLOBAL_SELF)
  oldOther = vm.word(server.machine, c.QC_GLOBAL_OTHER)
  touched = collision.impact(server, firstEntity, secondEntity)
  vm.setWord(server.machine, c.QC_GLOBAL_SELF, oldSelf)
  vm.setWord(server.machine, c.QC_GLOBAL_OTHER, oldOther)
  return touched
end function

// Trace velocity through the collision world.
function ClipVelocity(input, normal, overbounce)
  return clipVelocity(input, normal, overbounce)
end function

// Apply the Quake-compatible sv fly move behavior.
function SV_FlyMove(server, entityIndex, moveTime)
  player = physicsPlayerFromEdict(server, entityIndex)
  result = flyMoveDetailed(player, server.worldModel, server, entityIndex, moveTime)
  // ED_Free already cleared the authoritative entvars when an impact callback
  // removed this entity. Do not publish the stale movement mirror afterward.
  if not physicsEntityFree(server, entityIndex) then physicsWritePlayerEdict(server, entityIndex, player) end if
  return result
end function

// Apply the Quake-compatible sv add gravity behavior.
function SV_AddGravity(server, entityIndex, gravity, frameTime)
  entityGravity = collision.entityFloat(server, entityIndex, "gravity", 0.0)
  if entityGravity == 0.0 then entityGravity = 1.0 end if
  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  velocity.z = velocity.z - entityGravity * gravity * frameTime
  collision.setEntityVector(server, entityIndex, "velocity", velocity)
  return velocity
end function

// Apply the Quake-compatible sv push entity behavior.
function SV_PushEntity(server, entityIndex, push)
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  mins = collision.entityVectorZero(server, entityIndex, "mins")
  maxs = collision.entityVectorZero(server, entityIndex, "maxs")
  destination = math.add(origin, push)
  moveType = c.MOVE_NORMAL
  entityMoveType = native.trunc(collision.entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  solid = native.trunc(collision.entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_TRIGGER or solid == c.SOLID_NOT then moveType = c.MOVE_NOMONSTERS end if
  if entityMoveType == c.MOVETYPE_FLYMISSILE then moveType = c.MOVE_MISSILE end if
  trace = collision.move(server, origin, mins, maxs, destination, moveType, entityIndex)
  collision.setEntityVector(server, entityIndex, "origin", trace.endPosition)
  collision.linkEntity(server, entityIndex, true)
  if trace.entity >= 0 then SV_Impact(server, entityIndex, trace.entity) end if
  return trace
end function

// Apply server-physics strict overlap semantics.
function physicsStrictOverlap(minsA, maxsA, minsB, maxsB)
  if minsA.x >= maxsB.x or maxsA.x <= minsB.x then return false end if
  if minsA.y >= maxsB.y or maxsA.y <= minsB.y then return false end if
  if minsA.z >= maxsB.z or maxsA.z <= minsB.z then return false end if
  return true
end function

// Apply server-physics pusher blocked semantics.
function physicsPusherBlocked(server, pusherIndex, blockedBy)
  return physicsExecuteEntityFunction(server, pusherIndex, blockedBy, "blocked", server.time)
end function

// Apply the Quake-compatible sv push move behavior.
function SV_PushMove(server, pusherIndex, moveTime)
  velocity = collision.entityVectorZero(server, pusherIndex, "velocity")
  oldLocalTime = collision.entityFloat(server, pusherIndex, "ltime", 0.0)
  if velocity.x == 0.0 and velocity.y == 0.0 and velocity.z == 0.0 then
    collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime + moveTime)
    return true
  end if

  move = math.scale(velocity, moveTime)
  oldPusherOrigin = collision.entityVectorZero(server, pusherIndex, "origin")
  // world.c keeps one-unit-expanded abs bounds on linked entities.  sv_phys.c
  // translates those stored bounds to find occupants of the final position.
  finalMins = math.add(collision.entityAbsMin(server, pusherIndex), move)
  finalMaxs = math.add(collision.entityAbsMax(server, pusherIndex), move)
  collision.setEntityVector(server, pusherIndex, "origin", math.add(oldPusherOrigin, move))
  collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime + moveTime)
  collision.linkEntity(server, pusherIndex, false)

  movedIndexes = []
  movedOrigins = []
  blockedBy = -1
  index = 1
  while index < physicsEntityCount(server)
    if index != pusherIndex and not physicsEntityFree(server, index) then
      moveType = native.trunc(collision.entityFloat(server, index, "movetype", c.MOVETYPE_NONE))
      if moveType != c.MOVETYPE_PUSH and moveType != c.MOVETYPE_NONE and moveType != c.MOVETYPE_NOCLIP then
        flags = native.trunc(collision.entityFloat(server, index, "flags", 0.0))
        standing = (flags & c.FL_ONGROUND) != 0 and collision.entityWord(server, index, "groundentity", -1) == pusherIndex
        shouldMove = standing
        if not shouldMove then
          shouldMove = physicsStrictOverlap(
            collision.entityAbsMin(server, index),
            collision.entityAbsMax(server, index),
            finalMins,
            finalMaxs,
          )
          if shouldMove and collision.testEntityPosition(server, index) < 0 then shouldMove = false end if
        end if
        if shouldMove then
          original = collision.entityVectorZero(server, index, "origin")
          movedIndexes = movedIndexes + [index]
          movedOrigins = movedOrigins + [original]
          if moveType != c.MOVETYPE_WALK then collision.setEntityFloat(server, index, "flags", flags & ~c.FL_ONGROUND) end if
          collision.setEntityFloat(server, pusherIndex, "solid", c.SOLID_NOT)
          SV_PushEntity(server, index, move)
          collision.setEntityFloat(server, pusherIndex, "solid", c.SOLID_BSP)
          if collision.testEntityPosition(server, index) >= 0 then
            entityMins = collision.entityVectorZero(server, index, "mins")
            entityMaxs = collision.entityVectorZero(server, index, "maxs")
            solid = native.trunc(collision.entityFloat(server, index, "solid", c.SOLID_NOT))
            if entityMins.x == entityMaxs.x then
              // Point entities do not block a pusher.
            else if solid == c.SOLID_NOT or solid == c.SOLID_TRIGGER then
              collapsed = collapsePusherCorpseBounds(entityMins)
              collision.setEntityVector(server, index, "mins", collapsed)
              collision.setEntityVector(server, index, "maxs", collapsed)
            else
              collision.setEntityVector(server, index, "origin", original)
              collision.linkEntity(server, index, true)
              blockedBy = index
              break
            end if
          end if
        end if
      end if
    end if
    index = index + 1
  end while

  if blockedBy >= 0 then
    collision.setEntityVector(server, pusherIndex, "origin", oldPusherOrigin)
    collision.linkEntity(server, pusherIndex, false)
    collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime)
    // blocked() observes entities already carried by the attempted move.
    physicsPusherBlocked(server, pusherIndex, blockedBy)
    rollback = 0
    while rollback < len(movedIndexes)
      collision.setEntityVector(server, movedIndexes[rollback], "origin", movedOrigins[rollback])
      collision.linkEntity(server, movedIndexes[rollback], false)
      rollback = rollback + 1
    end while
    return false
  end if
  return true
end function

// QUAKE2 kept a rotating-pusher sibling in this source file. It is not used by
// MiniQuake 1.09, but retaining it makes the source-file pendant complete.
function SV_PushRotate(server, pusherIndex, moveTime)
  angularVelocity = collision.entityVectorZero(server, pusherIndex, "avelocity")
  oldLocalTime = collision.entityFloat(server, pusherIndex, "ltime", 0.0)
  if angularVelocity.x == 0.0 and angularVelocity.y == 0.0 and angularVelocity.z == 0.0 then
    collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime + moveTime)
    return true
  end if
  angleMove = math.scale(angularVelocity, moveTime)
  inverseVectors = math.angleVectors(math.scale(angleMove, -1.0))
  oldAngles = collision.entityVectorZero(server, pusherIndex, "angles")
  newAngles = math.add(oldAngles, angleMove)
  collision.setEntityVector(server, pusherIndex, "angles", newAngles)
  collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime + moveTime)
  pusherOrigin = collision.entityVectorZero(server, pusherIndex, "origin")
  pusherMins = math.add(pusherOrigin, collision.entityVectorZero(server, pusherIndex, "mins"))
  pusherMaxs = math.add(pusherOrigin, collision.entityVectorZero(server, pusherIndex, "maxs"))
  pusherSolid = native.trunc(collision.entityFloat(server, pusherIndex, "solid", c.SOLID_BSP))
  movedIndexes = []
  movedOrigins = []
  blockedBy = -1
  index = 1
  while index < physicsEntityCount(server)
    if index != pusherIndex and not physicsEntityFree(server, index) then
      moveType = native.trunc(collision.entityFloat(server, index, "movetype", c.MOVETYPE_NONE))
      if moveType != c.MOVETYPE_PUSH and moveType != c.MOVETYPE_NONE and moveType != MOVETYPE_FOLLOW_COMPAT and moveType != c.MOVETYPE_NOCLIP then
        flags = native.trunc(collision.entityFloat(server, index, "flags", 0.0))
        standing = (flags & c.FL_ONGROUND) != 0 and collision.entityWord(server, index, "groundentity", -1) == pusherIndex
        entityOrigin = collision.entityVectorZero(server, index, "origin")
        entityMins = collision.entityVectorZero(server, index, "mins")
        entityMaxs = collision.entityVectorZero(server, index, "maxs")
        shouldMove = standing or physicsStrictOverlap(math.add(entityOrigin, entityMins), math.add(entityOrigin, entityMaxs), pusherMins, pusherMaxs)
        if shouldMove and not standing and collision.testEntityPosition(server, index) < 0 then shouldMove = false end if
        if shouldMove then
          movedIndexes = movedIndexes + [index]
          movedOrigins = movedOrigins + [entityOrigin]
          if moveType != c.MOVETYPE_WALK then collision.setEntityFloat(server, index, "flags", flags & ~c.FL_ONGROUND) end if
          relative = math.subtract(entityOrigin, pusherOrigin)
          rotated = t.Vec3(
            math.dot(relative, inverseVectors[0]),
            -math.dot(relative, inverseVectors[1]),
            math.dot(relative, inverseVectors[2]),
          )
          move = math.subtract(rotated, relative)
          collision.setEntityFloat(server, pusherIndex, "solid", c.SOLID_NOT)
          SV_PushEntity(server, index, move)
          collision.setEntityFloat(server, pusherIndex, "solid", pusherSolid)
          if collision.testEntityPosition(server, index) >= 0 then
            mins = collision.entityVectorZero(server, index, "mins")
            maxs = collision.entityVectorZero(server, index, "maxs")
            solid = native.trunc(collision.entityFloat(server, index, "solid", c.SOLID_NOT))
            if mins.x == maxs.x then
              // Point entity.
            else if solid == c.SOLID_NOT or solid == c.SOLID_TRIGGER then
              collision.setEntityVector(server, index, "mins", zeroVector())
              collision.setEntityVector(server, index, "maxs", zeroVector())
            else
              collision.setEntityVector(server, index, "origin", entityOrigin)
              blockedBy = index
              break
            end if
          else
            angles = collision.entityVectorZero(server, index, "angles")
            collision.setEntityVector(server, index, "angles", math.add(angles, angleMove))
          end if
        end if
      end if
    end if
    index = index + 1
  end while
  if blockedBy >= 0 then
    collision.setEntityVector(server, pusherIndex, "angles", oldAngles)
    collision.setEntityFloat(server, pusherIndex, "ltime", oldLocalTime)
    physicsPusherBlocked(server, pusherIndex, blockedBy)
    rollback = 0
    while rollback < len(movedIndexes)
      movedIndex = movedIndexes[rollback]
      collision.setEntityVector(server, movedIndex, "origin", movedOrigins[rollback])
      angles = collision.entityVectorZero(server, movedIndex, "angles")
      collision.setEntityVector(server, movedIndex, "angles", math.subtract(angles, angleMove))
      rollback = rollback + 1
    end while
    return false
  end if
  return true
end function

// Apply the Quake-compatible sv physics pusher behavior.
function SV_Physics_Pusher(server, entityIndex, frameTime)
  oldLocalTime = collision.entityFloat(server, entityIndex, "ltime", 0.0)
  thinkTime = collision.entityFloat(server, entityIndex, "nextthink", 0.0)
  moveTime = frameTime
  if thinkTime < oldLocalTime + frameTime then
    moveTime = thinkTime - oldLocalTime
    if moveTime < 0.0 then moveTime = 0.0 end if
  end if
  if moveTime != 0.0 then
    // MiniQuake 1.09 is compiled without QUAKE2: angular velocity never selects
    // the alternate rotating-pusher body.
    SV_PushMove(server, entityIndex, moveTime)
  end if
  newLocalTime = collision.entityFloat(server, entityIndex, "ltime", oldLocalTime)
  if thinkTime > oldLocalTime and thinkTime <= newLocalTime then
    collision.setEntityFloat(server, entityIndex, "nextthink", 0.0)
    physicsExecuteEntityFunction(server, entityIndex, 0, "think", server.time)
  end if
  return not physicsEntityFree(server, entityIndex)
end function

// Apply the Quake-compatible sv check stuck behavior.
function SV_CheckStuck(server, entityIndex)
  player = physicsPlayerFromEdict(server, entityIndex)
  unstuck = checkStuck(player, server.worldModel, server, entityIndex)
  physicsWritePlayerEdict(server, entityIndex, player)
  return unstuck
end function

// Apply the Quake-compatible sv check water behavior.
function SV_CheckWater(server, entityIndex)
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  mins = collision.entityVectorZero(server, entityIndex, "mins")
  maxs = collision.entityVectorZero(server, entityIndex, "maxs")
  viewOffset = collision.entityVectorZero(server, entityIndex, "view_ofs")
  waterLevel = 0
  waterType = c.CONTENTS_EMPTY
  point = t.Vec3(origin.x, origin.y, origin.z + mins.z + 1.0)
  contents = world.pointContentsWorld(server.worldModel, point)
  if contents <= c.CONTENTS_WATER then
    waterType = contents
    waterLevel = 1
    point.z = origin.z + (mins.z + maxs.z) * 0.5
    contents = world.pointContentsWorld(server.worldModel, point)
    if contents <= c.CONTENTS_WATER then
      waterLevel = 2
      point.z = origin.z + viewOffset.z
      contents = world.pointContentsWorld(server.worldModel, point)
      if contents <= c.CONTENTS_WATER then waterLevel = 3 end if
    end if
  end if
  collision.setEntityFloat(server, entityIndex, "waterlevel", waterLevel)
  collision.setEntityFloat(server, entityIndex, "watertype", waterType)
  return waterLevel > 1
end function

// Apply the Quake-compatible sv wall friction behavior.
function SV_WallFriction(server, entityIndex, trace)
  player = physicsPlayerFromEdict(server, entityIndex)
  wallFriction(player, trace.plane)
  physicsWritePlayerEdict(server, entityIndex, player)
  return player.velocity
end function

// Apply the Quake-compatible sv try unstick behavior.
function SV_TryUnstick(server, entityIndex, oldVelocity)
  player = physicsPlayerFromEdict(server, entityIndex)
  result = tryUnstick(player, server.worldModel, server, entityIndex, oldVelocity)
  if not physicsEntityFree(server, entityIndex) then physicsWritePlayerEdict(server, entityIndex, player) end if
  return result
end function

// Apply the Quake-compatible sv walk move behavior.
function SV_WalkMove(server, entityIndex, frameTime)
  player = physicsPlayerFromEdict(server, entityIndex)
  result = walkMoveInternal(player, server.worldModel, server, entityIndex, frameTime)
  if not physicsEntityFree(server, entityIndex) then physicsWritePlayerEdict(server, entityIndex, player) end if
  return result
end function

// Apply the Quake-compatible sv physics client behavior.
function SV_Physics_Client(server, entityIndex, frameTime, gravity, maxVelocity)
  if physicsEntityFree(server, entityIndex) then return false end if
  physicsExecuteNamedFunction(server, "PlayerPreThink", entityIndex)
  SV_CheckVelocity(server, entityIndex, maxVelocity)
  moveType = native.trunc(collision.entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  if moveType == c.MOVETYPE_NONE then
    if not SV_RunThink(server, entityIndex, frameTime) then return false end if
  else if moveType == c.MOVETYPE_WALK then
    if not SV_RunThink(server, entityIndex, frameTime) then return false end if
    flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
    if not SV_CheckWater(server, entityIndex) and (flags & c.FL_WATERJUMP) == 0 then SV_AddGravity(server, entityIndex, gravity, frameTime) end if
    SV_CheckStuck(server, entityIndex)
    SV_WalkMove(server, entityIndex, frameTime)
  else if moveType == c.MOVETYPE_TOSS or moveType == c.MOVETYPE_BOUNCE then
    SV_Physics_Toss(server, entityIndex, frameTime, gravity, maxVelocity)
  else if moveType == c.MOVETYPE_FLY then
    if not SV_RunThink(server, entityIndex, frameTime) then return false end if
    SV_FlyMove(server, entityIndex, frameTime)
  else if moveType == c.MOVETYPE_NOCLIP then
    if not SV_RunThink(server, entityIndex, frameTime) then return false end if
    origin = collision.entityVectorZero(server, entityIndex, "origin")
    velocity = collision.entityVectorZero(server, entityIndex, "velocity")
    collision.setEntityVector(server, entityIndex, "origin", math.multiplyAdd(origin, frameTime, velocity))
  else
    return error(3410, "SV_Physics_Client: bad movetype " + moveType)
  end if
  collision.linkEntity(server, entityIndex, true)
  physicsExecuteNamedFunction(server, "PlayerPostThink", entityIndex)
  return not physicsEntityFree(server, entityIndex)
end function

// Apply the Quake-compatible sv physics none behavior.
function SV_Physics_None(server, entityIndex, frameTime)
  return SV_RunThink(server, entityIndex, frameTime)
end function

// Apply the Quake-compatible sv physics follow behavior.
function SV_Physics_Follow(server, entityIndex, frameTime)
  SV_RunThink(server, entityIndex, frameTime)
  aimEntity = collision.entityWord(server, entityIndex, "aiment", 0)
  aimOrigin = collision.entityVectorZero(server, aimEntity, "origin")
  offset = collision.entityVectorZero(server, entityIndex, "v_angle")
  collision.setEntityVector(server, entityIndex, "origin", math.add(aimOrigin, offset))
  collision.linkEntity(server, entityIndex, true)
  return not physicsEntityFree(server, entityIndex)
end function

// Apply the Quake-compatible sv physics noclip behavior.
function SV_Physics_Noclip(server, entityIndex, frameTime)
  if not SV_RunThink(server, entityIndex, frameTime) then return false end if
  angles = collision.entityVectorZero(server, entityIndex, "angles")
  angularVelocity = collision.entityVectorZero(server, entityIndex, "avelocity")
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  collision.setEntityVector(server, entityIndex, "angles", math.multiplyAdd(angles, frameTime, angularVelocity))
  collision.setEntityVector(server, entityIndex, "origin", math.multiplyAdd(origin, frameTime, velocity))
  collision.linkEntity(server, entityIndex, false)
  return true
end function

// Apply the Quake-compatible sv check water transition behavior.
function SV_CheckWaterTransition(server, entityIndex)
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  contents = world.pointContentsWorld(server.worldModel, origin)
  waterType = native.trunc(collision.entityFloat(server, entityIndex, "watertype", 0.0))
  if waterType == 0 then
    collision.setEntityFloat(server, entityIndex, "watertype", contents)
    collision.setEntityFloat(server, entityIndex, "waterlevel", 1)
    return contents
  end if
  if contents <= c.CONTENTS_WATER then
    if waterType == c.CONTENTS_EMPTY then physicsQueueSound(server, entityIndex, "misc/h2ohit1.wav") end if
    collision.setEntityFloat(server, entityIndex, "watertype", contents)
    collision.setEntityFloat(server, entityIndex, "waterlevel", 1)
  else
    if waterType != c.CONTENTS_EMPTY then physicsQueueSound(server, entityIndex, "misc/h2ohit1.wav") end if
    collision.setEntityFloat(server, entityIndex, "watertype", c.CONTENTS_EMPTY)
    // This surprising CONTENTS_EMPTY-era assignment is observable stock code.
    collision.setEntityFloat(server, entityIndex, "waterlevel", contents)
  end if
  return contents
end function

// Apply the Quake-compatible sv physics toss behavior.
function SV_Physics_Toss(server, entityIndex, frameTime, gravity, maxVelocity)
  if not SV_RunThink(server, entityIndex, frameTime) then return false end if
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  if (flags & c.FL_ONGROUND) != 0 then return true end if
  SV_CheckVelocity(server, entityIndex, maxVelocity)
  moveType = native.trunc(collision.entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  if moveType != c.MOVETYPE_FLY and moveType != c.MOVETYPE_FLYMISSILE then SV_AddGravity(server, entityIndex, gravity, frameTime) end if
  angles = collision.entityVectorZero(server, entityIndex, "angles")
  angularVelocity = collision.entityVectorZero(server, entityIndex, "avelocity")
  collision.setEntityVector(server, entityIndex, "angles", math.multiplyAdd(angles, frameTime, angularVelocity))
  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  trace = SV_PushEntity(server, entityIndex, math.scale(velocity, frameTime))
  if trace.fraction == 1.0 or physicsEntityFree(server, entityIndex) then return true end if
  overbounce = 1.0
  if moveType == c.MOVETYPE_BOUNCE then overbounce = 1.5 end if
  velocity = ClipVelocity(velocity, trace.plane.normal, overbounce)[0]
  if trace.plane.normal.z > 0.7 and (velocity.z < 60.0 or moveType != c.MOVETYPE_BOUNCE) then
    flags = flags | c.FL_ONGROUND
    collision.setEntityWord(server, entityIndex, "groundentity", trace.entity)
    velocity = zeroVector()
    collision.setEntityVector(server, entityIndex, "avelocity", zeroVector())
  end if
  collision.setEntityFloat(server, entityIndex, "flags", flags)
  collision.setEntityVector(server, entityIndex, "velocity", velocity)
  SV_CheckWaterTransition(server, entityIndex)
  return true
end function

// Apply the Quake-compatible sv physics step behavior.
function SV_Physics_Step(server, entityIndex, frameTime, gravity, maxVelocity)
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  if (flags & (c.FL_ONGROUND | c.FL_FLY | c.FL_SWIM)) == 0 then
    velocity = collision.entityVectorZero(server, entityIndex, "velocity")
    hitSound = velocity.z < gravity * -0.1
    SV_AddGravity(server, entityIndex, gravity, frameTime)
    SV_CheckVelocity(server, entityIndex, maxVelocity)
    SV_FlyMove(server, entityIndex, frameTime)
    newFlags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
    collision.linkEntity(server, entityIndex, true)
    if (newFlags & c.FL_ONGROUND) != 0 and hitSound then physicsQueueSound(server, entityIndex, "demon/dland2.wav") end if
  end if
  SV_RunThink(server, entityIndex, frameTime)
  SV_CheckWaterTransition(server, entityIndex)
  return not physicsEntityFree(server, entityIndex)
end function

// The alternate QUAKE2 body is retained as a named compatibility entry point;
// MiniQuake 1.09 dispatches the non-QUAKE2 SV_Physics_Step above.
function SV_Physics_Step_Quake2(server, entityIndex, frameTime, gravity, maxVelocity)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  physicsRefreshConveyorVelocity(server, entityIndex)
  SV_CheckVelocity(server, entityIndex, maxVelocity)
  flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
  wasOnGround = (flags & c.FL_ONGROUND) != 0
  inWater = SV_CheckWater(server, entityIndex)
  hitSound = false
  if not wasOnGround and (flags & c.FL_FLY) == 0 and not ((flags & c.FL_SWIM) != 0 and collision.entityFloat(server, entityIndex, "waterlevel", 0.0) > 0.0) then
    velocity = collision.entityVectorZero(server, entityIndex, "velocity")
    if velocity.z < gravity * -0.1 then hitSound = true end if
    if not inWater then SV_AddGravity(server, entityIndex, gravity, frameTime) end if
  end if

  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  baseVelocity = collision.entityVectorZero(server, entityIndex, "basevelocity")
  if not physicsVectorIsZero(velocity) or not physicsVectorIsZero(baseVelocity) then
    collision.setEntityFloat(server, entityIndex, "flags", flags & ~c.FL_ONGROUND)
    health = collision.entityFloat(server, entityIndex, "health", 0.0)
    applyFriction = wasOnGround
    if health <= 0.0 and not collision.checkBottom(server, entityIndex) then applyFriction = false end if
    if applyFriction then
      speed = native.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
      if speed != 0.0 then
        friction = 4.0
        stopSpeed = 100.0
        if server.machine.context.cvars is not void then
          configuredFriction = cvar.variableValue(server.machine.context.cvars, "sv_friction")
          configuredStopSpeed = cvar.variableValue(server.machine.context.cvars, "sv_stopspeed")
          if configuredFriction != 0.0 then friction = configuredFriction end if
          if configuredStopSpeed != 0.0 then stopSpeed = configuredStopSpeed end if
        end if
        control = speed
        if control < stopSpeed then control = stopSpeed end if
        newSpeed = speed - frameTime * control * friction
        if newSpeed < 0.0 then newSpeed = 0.0 end if
        newSpeed = newSpeed / speed
        velocity.x = velocity.x * newSpeed
        velocity.y = velocity.y * newSpeed
      end if
    end if

    collision.setEntityVector(server, entityIndex, "velocity", math.add(velocity, baseVelocity))
    SV_FlyMove(server, entityIndex, frameTime)
    velocity = collision.entityVectorZero(server, entityIndex, "velocity")
    baseVelocity = collision.entityVectorZero(server, entityIndex, "basevelocity")
    collision.setEntityVector(server, entityIndex, "velocity", math.subtract(velocity, baseVelocity))

    origin = collision.entityVectorZero(server, entityIndex, "origin")
    mins = math.add(origin, collision.entityVectorZero(server, entityIndex, "mins"))
    maxs = math.add(origin, collision.entityVectorZero(server, entityIndex, "maxs"))
    grounded = false
    xIndex = 0
    while xIndex < 2
      yIndex = 0
      while yIndex < 2
        x = mins.x
        y = mins.y
        if xIndex == 1 then x = maxs.x end if
        if yIndex == 1 then y = maxs.y end if
        if world.pointContentsWorld(server.worldModel, t.Vec3(x, y, mins.z - 1.0)) == c.CONTENTS_SOLID then grounded = true end if
        yIndex = yIndex + 1
      end while
      xIndex = xIndex + 1
    end while
    if grounded then
      flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
      collision.setEntityFloat(server, entityIndex, "flags", flags | c.FL_ONGROUND)
    end if
    collision.touchTriggers(server, entityIndex)
    flags = native.trunc(collision.entityFloat(server, entityIndex, "flags", 0.0))
    if (flags & c.FL_ONGROUND) != 0 and not wasOnGround and hitSound then physicsQueueSound(server, entityIndex, "demon/dland2.wav") end if
  end if
  SV_RunThink(server, entityIndex, frameTime)
  SV_CheckWaterTransition(server, entityIndex)
  return not physicsEntityFree(server, entityIndex)
end function

// Apply the Quake-compatible sv force retouch value behavior.
function SV_ForceRetouchValue(server)
  if server is void or server.machine is void or server.machine.context is void then return 0.0 end if
  forceOffset = vm.globalOffset(server.machine, "force_retouch")
  if forceOffset < 0 then return 0.0 end if
  return vm.globalFloat(server.machine, forceOffset)
end function

// Apply the Quake-compatible sv force retouch entity behavior.
function SV_ForceRetouchEntity(server, entityIndex, forceRetouch)
  if forceRetouch == 0.0 then return false end if
  if physicsEntityFree(server, entityIndex) then return false end if
  collision.linkEntity(server, entityIndex, true)
  return true
end function

// Apply the Quake-compatible sv finish force retouch behavior.
function SV_FinishForceRetouch(server, forceRetouch)
  if forceRetouch == 0.0 or server is void or server.machine is void then return false end if
  forceOffset = vm.globalOffset(server.machine, "force_retouch")
  if forceOffset < 0 then return false end if
  vm.setGlobalFloat(server.machine, forceOffset, forceRetouch - 1.0)
  return true
end function

// Dispatch one non-client edict through the exact unconditioned WinQuake 1.09
// SV_Physics switch.  The integrated server frame uses this entry point after
// it has run client movement, so the production path and the direct sv_main
// pendant share the same pusher, toss, step, noclip and think semantics.
function SV_Physics_NonClientEntity(server, entityIndex, frameTime, gravity, maxVelocity)
  if physicsEntityFree(server, entityIndex) then return false end if
  moveType = native.trunc(collision.entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  if moveType == c.MOVETYPE_PUSH then
    SV_Physics_Pusher(server, entityIndex, frameTime)
  else if moveType == c.MOVETYPE_NONE then
    SV_Physics_None(server, entityIndex, frameTime)
  else if moveType == c.MOVETYPE_NOCLIP then
    SV_Physics_Noclip(server, entityIndex, frameTime)
  else if moveType == c.MOVETYPE_STEP then
    SV_Physics_Step(server, entityIndex, frameTime, gravity, maxVelocity)
  else if moveType == c.MOVETYPE_TOSS or moveType == c.MOVETYPE_BOUNCE or moveType == c.MOVETYPE_FLY or moveType == c.MOVETYPE_FLYMISSILE then
    SV_Physics_Toss(server, entityIndex, frameTime, gravity, maxVelocity)
  else
    return error(3411, "SV_Physics: bad movetype " + moveType)
  end if
  return true
end function

// Apply the Quake-compatible sv physics behavior.
function SV_Physics(server, frameTime, gravity, maxVelocity)
  if server is void or server.machine is void or server.machine.context is void then return 0 end if
  machine = server.machine
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_FRAMETIME, frameTime)
  startFrame = vm.functionIndex(machine, "StartFrame")
  if startFrame != 0 then
    vm.setWord(machine, c.QC_GLOBAL_SELF, 0)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, 0)
    vm.execute(machine, startFrame)
  end if
  processed = 0
  forceRetouch = SV_ForceRetouchValue(server)
  index = 0
  while index < physicsEntityCount(server)
    if not physicsEntityFree(server, index) then
      if forceRetouch != 0.0 then collision.linkEntity(server, index, true) end if
      if index > 0 and index <= server.maxClients then
        clientActive = index - 1 < len(server.clients) and server.clients[index - 1].active
        if clientActive then SV_Physics_Client(server, index, frameTime, gravity, maxVelocity); processed = processed + 1 end if
      else
        if SV_Physics_NonClientEntity(server, index, frameTime, gravity, maxVelocity) then processed = processed + 1 end if
      end if
    end if
    index = index + 1
  end while
  SV_FinishForceRetouch(server, forceRetouch)
  server.time = server.time + frameTime
  machine.context.serverTime = server.time
  return processed
end function

// Apply the Quake-compatible sv trace toss behavior.
function SV_Trace_Toss(server, entityIndex, ignoreEntity, gravity, maxVelocity)
  origin = collision.entityVectorZero(server, entityIndex, "origin")
  velocity = collision.entityVectorZero(server, entityIndex, "velocity")
  angles = collision.entityVectorZero(server, entityIndex, "angles")
  angularVelocity = collision.entityVectorZero(server, entityIndex, "avelocity")
  mins = collision.entityVectorZero(server, entityIndex, "mins")
  maxs = collision.entityVectorZero(server, entityIndex, "maxs")
  entityGravity = collision.entityFloat(server, entityIndex, "gravity", 0.0)
  if entityGravity == 0.0 then entityGravity = 1.0 end if
  trace = void
  iterations = 0
  while iterations < 8192
    velocity.x = math.clamp(velocity.x, -maxVelocity, maxVelocity)
    velocity.y = math.clamp(velocity.y, -maxVelocity, maxVelocity)
    velocity.z = math.clamp(velocity.z, -maxVelocity, maxVelocity)
    velocity.z = velocity.z - entityGravity * gravity * 0.05
    angles = math.multiplyAdd(angles, 0.05, angularVelocity)
    finish = math.multiplyAdd(origin, 0.05, velocity)
    trace = collision.move(server, origin, mins, maxs, finish, c.MOVE_NORMAL, entityIndex)
    origin = math.copy(trace.endPosition)
    if trace.entity >= 0 and trace.entity != ignoreEntity then return trace end if
    iterations = iterations + 1
  end while
  return trace
end function
