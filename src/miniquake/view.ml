package miniquake.view

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.native as native

const PI = 3.141592653589793

function create()
  return t.ViewState(
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    0.0,
    0.0,
    t.Vec3(0.0, 0.0, 0.0),
    [0.0, 0.0, 0.0, 0.0],
    0.0,
    false,
  )
end function

// Reset V_CalcRefdef's oldz accumulator after map changes and teleports.
function reset(state, playerOrigin)
  state.oldZ = playerOrigin.z
  state.oldZValid = true
  state.bob = 0.0
  state.roll = 0.0
  return state
end function

function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

// V_CalcRoll from view.c / sv_user.c.
function calcRoll(angles, velocity, rollAngle, rollSpeed)
  vectors = math.angleVectors(angles)
  side = math.dot(velocity, vectors[1])
  sign = 1.0
  if side < 0.0 then sign = -1.0 end if
  side = absolute(side)
  value = rollAngle
  if rollSpeed <= 0.0 then return value * sign end if
  if side < rollSpeed then side = side * value / rollSpeed else side = value end if
  return side * sign
end function

// V_CalcBob from view.c.  The stock cl_bob value deliberately adds a small
// walking sway; protocol-origin quantization and unsmoothed steps must not add
// any extra vertical movement on top of it.
function calcBob(time, velocity, bobAmount, bobCycle, bobUp)
  if bobCycle <= 0.0 then return 0.0 end if
  if bobUp <= 0.0 then bobUp = 0.01 end if
  if bobUp >= 1.0 then bobUp = 0.99 end if
  cycle = time - native.trunc(time / bobCycle) * bobCycle
  cycle = cycle / bobCycle
  if cycle < bobUp then
    cycle = PI * cycle / bobUp
  else
    cycle = PI + PI * (cycle - bobUp) / (1.0 - bobUp)
  end if
  speed = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
  bob = speed * bobAmount
  bob = bob * 0.3 + bob * 0.7 * math.sin(cycle)
  if bob > 4.0 then bob = 4.0 end if
  if bob < -7.0 then bob = -7.0 end if
  return bob
end function

function addDamage(state, count, fromDirection, viewAngles, kickRoll, kickPitch, kickTime)
  vectors = math.angleVectors(viewAngles)
  direction = math.normalize(fromDirection)
  side = math.dot(direction, vectors[1])
  front = math.dot(direction, vectors[0])
  state.damageKick.z = count * side * kickRoll
  state.damageKick.x = count * front * kickPitch
  state.damageKick.y = kickTime
  alpha = count * 3.0
  if alpha < 0.0 then alpha = 0.0 end if
  if alpha > 150.0 then alpha = 150.0 end if
  state.blend = [1.0, 0.0, 0.0, alpha / 255.0]
  return state
end function

function decayDamage(state, frameTime, kickTime)
  if state.damageKick.y > 0.0 then
    state.damageKick.y = state.damageKick.y - frameTime
    if state.damageKick.y < 0.0 then state.damageKick.y = 0.0 end if
  end if
  if kickTime <= 0.0 or state.damageKick.y == 0.0 then
    state.damageKick.x = 0.0
    state.damageKick.z = 0.0
  end if
  if len(state.blend) >= 4 and state.blend[3] > 0.0 then
    state.blend[3] = state.blend[3] - frameTime * 0.6
    if state.blend[3] < 0.0 then state.blend[3] = 0.0 end if
  end if
  return state
end function

function smoothStairStep(state, player, frameTime)
  if not state.oldZValid then
    state.oldZ = player.origin.z
    state.oldZValid = true
    return 0.0
  end if
  if player.onGround and player.origin.z - state.oldZ > 0.0 then
    stepTime = frameTime
    if stepTime < 0.0 then stepTime = 0.0 end if
    state.oldZ = state.oldZ + stepTime * 80.0
    if state.oldZ > player.origin.z then state.oldZ = player.origin.z end if
    if player.origin.z - state.oldZ > 12.0 then state.oldZ = player.origin.z - 12.0 end if
    return state.oldZ - player.origin.z
  end if
  state.oldZ = player.origin.z
  return 0.0
end function

function calculate(state, player, cameraAngles, clientTime, frameTime, bobAmount, bobCycle, bobUp, rollAngle, rollSpeed, kickTime)
  state.bob = calcBob(clientTime, player.velocity, bobAmount, bobCycle, bobUp)
  state.roll = calcRoll(cameraAngles, player.velocity, rollAngle, rollSpeed)

  // The 1/32-unit nudge is the original V_CalcRefdef guard against landing
  // exactly on a BSP plane.  Stair smoothing follows the original oldz logic.
  state.origin = t.Vec3(
    player.origin.x + 0.03125,
    player.origin.y + 0.03125,
    player.origin.z + player.viewHeight + state.bob + 0.03125,
  )
  state.origin.z = state.origin.z + smoothStairStep(state, player, frameTime)

  // Local play renders from the unquantized client command angles.  The server
  // still receives protocol-15 byte angles for authoritative simulation, but
  // feeding those back into the camera causes visible stepping and shaking.
  state.angles = math.copy(cameraAngles)
  state.angles.z = state.angles.z + state.roll
  if kickTime > 0.0 and state.damageKick.y > 0.0 then
    scale = state.damageKick.y / kickTime
    state.angles.x = state.angles.x + state.damageKick.x * scale
    state.angles.z = state.angles.z + state.damageKick.z * scale
  end if
  vectors = math.angleVectors(state.angles)
  state.forward = vectors[0]
  state.right = vectors[1]
  state.up = vectors[2]
  decayDamage(state, frameTime, kickTime)
  return state
end function
