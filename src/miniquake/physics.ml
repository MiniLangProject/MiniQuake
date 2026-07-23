package miniquake.physics

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as world
import miniquake.server_collision as collision
import miniquake.cvar as cvar

const STOP_EPSILON = 0.1
const STEP_SIZE = 18.0
const MAX_CLIP_PLANES = 5

function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

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
    -1,
    c.CONTENTS_EMPTY,
    zeroVector(),
    false,
    0.0,
    zeroVector(),
    math.copy(origin),
    0,
  )
end function

function horizontalLength(value)
  return math.length(t.Vec3(value.x, value.y, 0.0))
end function

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

function traceMove(server, map, entityIndex, start, mins, maxs, finish, moveType)
  if server is void then return world.trace(map, start, mins, maxs, finish) end if
  return collision.move(server, start, mins, maxs, finish, moveType, entityIndex)
end function

function markGround(player, entityIndex)
  player.onGround = true
  player.flags = player.flags | c.FL_ONGROUND
  player.groundEntity = entityIndex
end function

function clearGround(player)
  player.onGround = false
  player.flags = player.flags & ~c.FL_ONGROUND
  player.groundEntity = -1
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

function flyMoveInternal(player, map, server, entityIndex, frameTime)
  return flyMoveDetailed(player, map, server, entityIndex, frameTime)[0]
end function

function nativeSolid(server, entityIndex)
  if entityIndex == 0 then return c.SOLID_BSP end if
  return native.trunc(collision.entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
end function

function flyMove(player, map, frameTime)
  return flyMoveInternal(player, map, void, -1, frameTime)
end function

function positionDistanceSquared(a, b)
  dx = a.x - b.x
  dy = a.y - b.y
  return dx * dx + dy * dy
end function

function pushPlayer(server, map, entityIndex, player, move)
  target = math.add(player.origin, move)
  trace = traceMove(server, map, entityIndex, player.origin, player.mins, player.maxs, target, c.MOVE_NORMAL)
  player.origin = math.copy(trace.endPosition)
  if server is not void and trace.entity >= 0 and trace.fraction < 1.0 then collision.impact(server, entityIndex, trace.entity) end if
  return trace
end function

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

function accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
  currentSpeed = math.dot(player.velocity, wishDirection)
  addSpeed = wishSpeed - currentSpeed
  if addSpeed <= 0.0 then return end if
  accelerationSpeed = acceleration * frameTime * wishSpeed
  if accelerationSpeed > addSpeed then accelerationSpeed = addSpeed end if
  player.velocity = math.multiplyAdd(player.velocity, accelerationSpeed, wishDirection)
end function

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

function dropPunchAngle(player, frameTime)
  magnitude = math.length(player.punchAngle)
  if magnitude == 0.0 then return end if
  direction = math.scale(player.punchAngle, 1.0 / magnitude)
  magnitude = magnitude - 10.0 * frameTime
  if magnitude < 0.0 then magnitude = 0.0 end if
  player.punchAngle = math.scale(direction, magnitude)
end function

function airMove(player, command, frameTime, maxSpeed, acceleration, friction, edgeFriction, stopSpeed, map, server, entityIndex)
  movementAngles = t.Vec3(0.0, player.renderAngles.y, 0.0)
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

function clampVelocity(player, maximum)
  if player.velocity.x > maximum then player.velocity.x = maximum end if
  if player.velocity.x < -maximum then player.velocity.x = -maximum end if
  if player.velocity.y > maximum then player.velocity.y = maximum end if
  if player.velocity.y < -maximum then player.velocity.y = -maximum end if
  if player.velocity.z > maximum then player.velocity.z = maximum end if
  if player.velocity.z < -maximum then player.velocity.z = -maximum end if
end function

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

function moveServer(player, server, entityIndex, command, frameTime, registry)
  if frameTime <= 0.0 then return player end if
  if frameTime > 0.1 then frameTime = 0.1 end if
  player.viewAngles = math.copy(command.viewAngles)
  player.onGround = (player.flags & c.FL_ONGROUND) != 0
  settings = movementSettings(registry)
  updateWaterLevel(player, server.worldModel)
  clientThink(player, command, frameTime, settings, server.worldModel, server, entityIndex)
  clampVelocity(player, settings[6])

  if player.moveType == c.MOVETYPE_NONE then return player end if
  if player.moveType == c.MOVETYPE_NOCLIP or player.noclip then
    player.origin = math.multiplyAdd(player.origin, frameTime, player.velocity)
    clearGround(player)
    return player
  end if
  if player.moveType == c.MOVETYPE_FLY then
    flyMoveInternal(player, server.worldModel, server, entityIndex, frameTime)
    return player
  end if
  if player.moveType != c.MOVETYPE_WALK then return player end if

  if player.waterLevel <= 1 and (player.flags & c.FL_WATERJUMP) == 0 then
    player.velocity.z = player.velocity.z - settings[5] * frameTime
  end if
  checkStuck(player, server.worldModel, server, entityIndex)
  walkMoveInternal(player, server.worldModel, server, entityIndex, frameTime)
  collision.setEntityVector(server, entityIndex, "origin", player.origin)
  collision.touchTriggers(server, entityIndex)
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
