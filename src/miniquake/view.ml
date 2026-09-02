/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.view.
*/
package miniquake.view

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.cvar as cvar
import miniquake.native as native
import miniquake.common as common
import std.math as stdmath

/// Defines the pi value used by `miniquake.view`.
const PI = 3.141592653589793
/// Defines the cshift contents value used by `miniquake.view`.
const CSHIFT_CONTENTS = 0
/// Defines the cshift damage value used by `miniquake.view`.
const CSHIFT_DAMAGE = 1
/// Defines the cshift bonus value used by `miniquake.view`.
const CSHIFT_BONUS = 2
/// Defines the cshift powerup value used by `miniquake.view`.
const CSHIFT_POWERUP = 3

// V_RenderView's compatibility trace contains only fixed stage names. Share
// the immutable variants instead of rebuilding nested arrays every frame.
viewTraceEmpty = []
/// Tracks the module-level view trace paused state owned by `miniquake.view`.
viewTracePaused = [["R_PushDlights"], ["R_RenderView"]]
/// Tracks the module-level view trace paused stereo state owned by `miniquake.view`.
viewTracePausedStereo = [["R_PushDlights"], ["R_RenderView", "left"], ["R_PushDlights"], ["R_RenderView", "right"]]
/// Tracks the module-level view trace refdef state owned by `miniquake.view`.
viewTraceRefdef = [["V_CalcRefdef"], ["R_PushDlights"], ["R_RenderView"]]
/// Tracks the module-level view trace refdef stereo state owned by `miniquake.view`.
viewTraceRefdefStereo = [["V_CalcRefdef"], ["R_PushDlights"], ["R_RenderView", "left"], ["R_PushDlights"], ["R_RenderView", "right"]]
/// Tracks the module-level view trace intermission state owned by `miniquake.view`.
viewTraceIntermission = [["V_CalcIntermissionRefdef"], ["R_PushDlights"], ["R_RenderView"]]
/// Tracks the module-level view trace intermission stereo state owned by `miniquake.view`.
viewTraceIntermissionStereo = [["V_CalcIntermissionRefdef"], ["R_PushDlights"], ["R_RenderView", "left"], ["R_PushDlights"], ["R_RenderView", "right"]]
/// Defines the num cshifts value used by `miniquake.view`.
const NUM_CSHIFTS = 4

/// Implements the `emptyGamma` operation for `miniquake.view` (empty gamma).
function emptyGamma()
  table = []
  index = 0
  while index < 256
    table = table + [index]
    index = index + 1
  end while
  return table
end function

/// Implements the `emptyRamps` operation for `miniquake.view` (empty ramps).
function emptyRamps()
  return [emptyGamma(), emptyGamma(), emptyGamma()]
end function

/// Implements the `create` operation for `miniquake.view` (create).
function create()
  state = t.ViewState(
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
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    0.0,
    true,
    0.0,
    -1.0,
    0.0,
    0.0,
    0.0,
    [
      [130.0, 80.0, 50.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
    ],
    [
      [-1.0, -1.0, -1.0, -1.0],
      [-1.0, -1.0, -1.0, -1.0],
      [-1.0, -1.0, -1.0, -1.0],
      [-1.0, -1.0, -1.0, -1.0],
    ],
    emptyGamma(),
    emptyRamps(),
    -1.0,
    0.0,
    0.0,
    false,
    true,
    [],
    0.0,
    false,
    [130.0, 80.0, 50.0, 0.0],
  )
  return V_Init(state)
end function

/// Implements the `reset` operation for `miniquake.view` (reset).
/// @param state Mutable `miniquake.view` state used by `reset`.
/// @param playerOrigin The player origin input consumed by `reset`.
function reset(state, playerOrigin)
  state.oldZ = playerOrigin.z
  state.oldZValid = true
  state.bob = 0.0
  state.roll = 0.0
  state.damageTime = 0.0
  state.damageKick = t.Vec3(0.0, 0.0, 0.0)
  state.pitchVelocity = 0.0
  state.noDrift = true
  state.driftMove = 0.0
  state.lastStop = -1.0
  state.lastInputPitchValid = false
  state.intermission = false
  state.viewModelVisible = true
  state.commandTrace = []
  return state
end function

/// The cl-owned fields used by view.c are cleared by CL_ClearState's memset.
/// Renderer statics (oldz, old gun angles, damage kick globals, gamma state and
/// the user-configurable cshift_empty) intentionally survive map changes.
/// @param state Mutable `miniquake.view` state used by `V_ClearClientState`.
function V_ClearClientState(state)
  state.pitchVelocity = 0.0
  state.noDrift = false
  state.driftMove = 0.0
  state.lastStop = 0.0
  state.cshifts = [
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
  ]
  state.previousCshifts = [
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0],
  ]
  state.lastInputPitchValid = false
  state.intermission = false
  state.viewModelVisible = true
  state.commandTrace = []
  return state
end function

/// Implements the `absolute` operation for `miniquake.view` (absolute).
/// @param value Value consumed by `absolute`.
function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

/// V_CalcRoll is also consumed by sv_user.c in the original engine.
/// @param angles Orientation angles used by the operation.
/// @param velocity Velocity applied by the operation.
/// @param rollAngle The roll angle input consumed by `V_CalcRoll`.
/// @param rollSpeed The roll speed input consumed by `V_CalcRoll`.
function V_CalcRoll(angles, velocity, rollAngle, rollSpeed)
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

/// Implements the `calcRoll` operation for `miniquake.view` (calc roll).
/// @param angles Orientation angles used by the operation.
/// @param velocity Velocity applied by the operation.
/// @param rollAngle The roll angle input consumed by `calcRoll`.
/// @param rollSpeed The roll speed input consumed by `calcRoll`.
function calcRoll(angles, velocity, rollAngle, rollSpeed)
  return V_CalcRoll(angles, velocity, rollAngle, rollSpeed)
end function

/// Mirror Quake's V_CalcBob routine and its observable state changes.
/// @param time Simulation or presentation time for the operation.
/// @param velocity Velocity applied by the operation.
/// @param bobAmount The bob amount input consumed by `V_CalcBob`.
/// @param bobCycle The bob cycle input consumed by `V_CalcBob`.
/// @param bobUp The bob up input consumed by `V_CalcBob`.
function V_CalcBob(time, velocity, bobAmount, bobCycle, bobUp)
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

/// Implements the `calcBob` operation for `miniquake.view` (calc bob).
/// @param time Simulation or presentation time for the operation.
/// @param velocity Velocity applied by the operation.
/// @param bobAmount The bob amount input consumed by `calcBob`.
/// @param bobCycle The bob cycle input consumed by `calcBob`.
/// @param bobUp The bob up input consumed by `calcBob`.
function calcBob(time, velocity, bobAmount, bobCycle, bobUp)
  return V_CalcBob(time, velocity, bobAmount, bobCycle, bobUp)
end function

/// Mirror Quake's V_StartPitchDrift routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_StartPitchDrift`.
/// @param clientTime Time value used by the operation.
/// @param centerSpeed The center speed input consumed by `V_StartPitchDrift`.
function V_StartPitchDrift(state, clientTime, centerSpeed)
  if state.lastStop == clientTime then return state end if
  if state.noDrift or state.pitchVelocity == 0.0 then
    state.pitchVelocity = centerSpeed
    state.noDrift = false
    state.driftMove = 0.0
  end if
  return state
end function

/// Mirror Quake's V_StopPitchDrift routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_StopPitchDrift`.
/// @param clientTime Time value used by the operation.
function V_StopPitchDrift(state, clientTime)
  state.lastStop = clientTime
  state.noDrift = true
  state.pitchVelocity = 0.0
  return state
end function

/// Mirror Quake's V_DriftPitch routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_DriftPitch`.
/// @param viewAngles The view angles input consumed by `V_DriftPitch`.
/// @param idealPitch The ideal pitch input consumed by `V_DriftPitch`.
/// @param forwardMove The forward move input consumed by `V_DriftPitch`.
/// @param forwardSpeed The forward speed input consumed by `V_DriftPitch`.
/// @param frameTime Time value used by the operation.
/// @param clientTime Time value used by the operation.
/// @param centerMove The center move input consumed by `V_DriftPitch`.
/// @param centerSpeed The center speed input consumed by `V_DriftPitch`.
/// @param noclipAngleHack The noclip angle hack input consumed by `V_DriftPitch`.
/// @param onGround The on ground input consumed by `V_DriftPitch`.
/// @param demoPlayback The demo playback input consumed by `V_DriftPitch`.
function V_DriftPitch(state, viewAngles, idealPitch, forwardMove, forwardSpeed, frameTime, clientTime, centerMove, centerSpeed, noclipAngleHack, onGround, demoPlayback)
  if noclipAngleHack or not onGround or demoPlayback then
    state.driftMove = 0.0
    state.pitchVelocity = 0.0
    return viewAngles
  end if

  if state.noDrift then
    if absolute(forwardMove) < forwardSpeed then state.driftMove = 0.0 else state.driftMove = state.driftMove + frameTime end if
    if state.driftMove > centerMove then V_StartPitchDrift(state, clientTime, centerSpeed) end if
    return viewAngles
  end if

  delta = idealPitch - viewAngles.x
  if delta == 0.0 then
    state.pitchVelocity = 0.0
    return viewAngles
  end if

  move = frameTime * state.pitchVelocity
  state.pitchVelocity = state.pitchVelocity + frameTime * centerSpeed
  if delta > 0.0 then
    if move > delta then state.pitchVelocity = 0.0; move = delta end if
    viewAngles.x = viewAngles.x + move
  else
    if move > -delta then state.pitchVelocity = 0.0; move = -delta end if
    viewAngles.x = viewAngles.x - move
  end if
  return viewAngles
end function

/// Create and initialize gamma table.
/// @param state Mutable `miniquake.view` state used by `BuildGammaTable`.
/// @param gamma The gamma input consumed by `BuildGammaTable`.
function BuildGammaTable(state, gamma)
  index = 0
  if gamma == 1.0 then
    while index < 256
      state.gammaTable[index] = index
      index = index + 1
    end while
    return state.gammaTable
  end if
  while index < 256
    value = native.trunc(255.0 * stdmath.pow((index + 0.5) / 255.5, gamma) + 0.5)
    if value < 0 then value = 0 end if
    if value > 255 then value = 255 end if
    state.gammaTable[index] = value
    index = index + 1
  end while
  return state.gammaTable
end function

/// Mirror Quake's V_CheckGamma routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CheckGamma`.
/// @param gamma The gamma input consumed by `V_CheckGamma`.
function V_CheckGamma(state, gamma)
  if gamma == state.oldGamma then return false end if
  state.oldGamma = gamma
  BuildGammaTable(state, gamma)
  return true
end function

/// Mirror Quake's V_ParseDamage routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_ParseDamage`.
/// @param armor The armor input consumed by `V_ParseDamage`.
/// @param blood The blood input consumed by `V_ParseDamage`.
/// @param source Source value or collection to read.
/// @param entityOrigin The entity origin input consumed by `V_ParseDamage`.
/// @param entityAngles The entity angles input consumed by `V_ParseDamage`.
/// @param kickRoll The kick roll input consumed by `V_ParseDamage`.
/// @param kickPitch The kick pitch input consumed by `V_ParseDamage`.
/// @param kickTime Time value used by the operation.
function V_ParseDamage(state, armor, blood, source, entityOrigin, entityAngles, kickRoll, kickPitch, kickTime)
  count = blood * 0.5 + armor * 0.5
  if count < 10.0 then count = 10.0 end if

  damage = state.cshifts[CSHIFT_DAMAGE]
  // cshift_t.percent is an int in the original.  Compound assignments from
  // the floating damage count truncate toward zero on every write.
  damage[3] = native.trunc(damage[3] + 3.0 * count)
  if damage[3] < 0.0 then damage[3] = 0.0 end if
  if damage[3] > 150.0 then damage[3] = 150.0 end if
  if armor > blood then
    damage[0] = 200.0; damage[1] = 100.0; damage[2] = 100.0
  else if armor != 0 then
    damage[0] = 220.0; damage[1] = 50.0; damage[2] = 50.0
  else
    damage[0] = 255.0; damage[1] = 0.0; damage[2] = 0.0
  end if

  // Keep the subtraction result live across normalization's Vec3 allocation.
  // Multiplayer changelevel can deliver damage while the rebuilt client heap
  // is collecting; a named temporary preserves the original VectorSubtract /
  // VectorNormalize sequence without relying on nested allocation rooting.
  sourceDelta = math.subtract(source, entityOrigin)
  direction = math.normalize(sourceDelta)
  vectors = math.angleVectors(entityAngles)
  state.damageRoll = count * math.dot(direction, vectors[1]) * kickRoll
  state.damagePitch = count * math.dot(direction, vectors[0]) * kickPitch
  state.damageTime = kickTime
  state.damageKick.x = state.damagePitch
  state.damageKick.y = state.damageTime
  state.damageKick.z = state.damageRoll
  return state
end function

/// Mirror Quake's V_cshift_f routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_cshift_f`.
/// @param arguments Command-line arguments to inspect or execute.
function V_cshift_f(state, arguments)
  // view.c uses atoi(Cmd_Argv(...)) for every component.  In particular,
  // decimal suffixes are truncated and malformed/empty values become zero;
  // MiniLang's generic toNumber would otherwise accept a wider syntax.
  values = [0.0, 0.0, 0.0, 0.0]
  index = 0
  while index < 4
    if index + 1 < len(arguments) then
      values[index] = common.cAtoi(arguments[index + 1])
    end if
    index = index + 1
  end while
  state.emptyCshift = values
  state.cshifts[CSHIFT_CONTENTS] = [values[0], values[1], values[2], values[3]]
  return state
end function

/// Mirror Quake's V_BonusFlash_f routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_BonusFlash_f`.
function V_BonusFlash_f(state)
  state.cshifts[CSHIFT_BONUS] = [215.0, 186.0, 69.0, 50.0]
  return state
end function

/// Mirror Quake's V_SetContentsColor routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_SetContentsColor`.
/// @param contents The contents input consumed by `V_SetContentsColor`.
function V_SetContentsColor(state, contents)
  shift = state.cshifts[CSHIFT_CONTENTS]
  if contents == c.CONTENTS_EMPTY or contents == c.CONTENTS_SOLID then
    shift[0] = state.emptyCshift[0]
    shift[1] = state.emptyCshift[1]
    shift[2] = state.emptyCshift[2]
    shift[3] = state.emptyCshift[3]
  else if contents == c.CONTENTS_LAVA then
    shift[0] = 255.0
    shift[1] = 80.0
    shift[2] = 0.0
    shift[3] = 150.0
  else if contents == c.CONTENTS_SLIME then
    shift[0] = 0.0
    shift[1] = 25.0
    shift[2] = 5.0
    shift[3] = 150.0
  else
    shift[0] = 130.0
    shift[1] = 80.0
    shift[2] = 50.0
    shift[3] = 128.0
  end if
  return shift
end function

/// Mirror Quake's V_CalcPowerupCshift routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CalcPowerupCshift`.
/// @param items The items input consumed by `V_CalcPowerupCshift`.
function V_CalcPowerupCshift(state, items)
  shift = state.cshifts[CSHIFT_POWERUP]
  if (items & c.IT_QUAD) != 0 then
    shift[0] = 0.0
    shift[1] = 0.0
    shift[2] = 255.0
    shift[3] = 30.0
  else if (items & c.IT_SUIT) != 0 then
    shift[0] = 0.0
    shift[1] = 255.0
    shift[2] = 0.0
    shift[3] = 20.0
  else if (items & c.IT_INVISIBILITY) != 0 then
    shift[0] = 100.0
    shift[1] = 100.0
    shift[2] = 100.0
    shift[3] = 100.0
  else if (items & c.IT_INVULNERABILITY) != 0 then
    shift[0] = 255.0
    shift[1] = 255.0
    shift[2] = 0.0
    shift[3] = 30.0
  else
    shift[3] = 0.0
  end if
  return shift
end function

/// Mirror Quake's V_CalcBlend routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CalcBlend`.
/// @param cshiftPercent The cshift percent input consumed by `V_CalcBlend`.
function V_CalcBlend(state, cshiftPercent)
  red = 0.0
  green = 0.0
  blue = 0.0
  alpha = 0.0
  index = 0
  while index < NUM_CSHIFTS
    alpha2 = 0.0
    if cshiftPercent != 0.0 then alpha2 = ((state.cshifts[index][3] * cshiftPercent) / 100.0) / 255.0 end if
    if alpha2 != 0.0 then
      alpha = alpha + alpha2 * (1.0 - alpha)
      fraction = alpha2 / alpha
      red = red * (1.0 - fraction) + state.cshifts[index][0] * fraction
      green = green * (1.0 - fraction) + state.cshifts[index][1] * fraction
      blue = blue * (1.0 - fraction) + state.cshifts[index][2] * fraction
    end if
    index = index + 1
  end while
  if alpha > 1.0 then alpha = 1.0 end if
  if alpha < 0.0 then alpha = 0.0 end if
  state.blend[0] = red / 255.0
  state.blend[1] = green / 255.0
  state.blend[2] = blue / 255.0
  state.blend[3] = alpha
  return state.blend
end function

/// This is the GLQUAKE V_UpdatePalette path.  It also constructs the original
/// three gamma ramps so a diagnostic build can compare the software-palette
/// result without asking the platform bridge to own game policy.
/// @param state Mutable `miniquake.view` state used by `V_UpdatePalette`.
/// @param items The items input consumed by `V_UpdatePalette`.
/// @param frameTime Time value used by the operation.
/// @param cshiftPercent The cshift percent input consumed by `V_UpdatePalette`.
/// @param gamma The gamma input consumed by `V_UpdatePalette`.
function V_UpdatePalette(state, items, frameTime, cshiftPercent, gamma)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  V_CalcPowerupCshift(state, items)
  changed = false
  shiftIndex = 0
  while shiftIndex < NUM_CSHIFTS
    component = 0
    while component < 4
      if state.cshifts[shiftIndex][component] != state.previousCshifts[shiftIndex][component] then
        changed = true
        state.previousCshifts[shiftIndex][component] = state.cshifts[shiftIndex][component]
      end if
      component = component + 1
    end while
    shiftIndex = shiftIndex + 1
  end while

  state.cshifts[CSHIFT_DAMAGE][3] = native.trunc(state.cshifts[CSHIFT_DAMAGE][3] - frameTime * 150.0)
  if state.cshifts[CSHIFT_DAMAGE][3] <= 0.0 then state.cshifts[CSHIFT_DAMAGE][3] = 0.0 end if
  state.cshifts[CSHIFT_BONUS][3] = native.trunc(state.cshifts[CSHIFT_BONUS][3] - frameTime * 100.0)
  if state.cshifts[CSHIFT_BONUS][3] <= 0.0 then state.cshifts[CSHIFT_BONUS][3] = 0.0 end if

  forced = V_CheckGamma(state, gamma)
  if not changed and not forced then return false end if
  V_CalcBlend(state, cshiftPercent)

  alpha = state.blend[3]
  red = 255.0 * state.blend[0] * alpha
  green = 255.0 * state.blend[1] * alpha
  blue = 255.0 * state.blend[2] * alpha
  inverse = 1.0 - alpha
  index = 0
  while index < 256
    ir = native.trunc(index * inverse + red)
    ig = native.trunc(index * inverse + green)
    ib = native.trunc(index * inverse + blue)
    if ir > 255 then ir = 255 end if
    if ig > 255 then ig = 255 end if
    if ib > 255 then ib = 255 end if
    state.ramps[0][index] = state.gammaTable[ir]
    state.ramps[1][index] = state.gammaTable[ig]
    state.ramps[2][index] = state.gammaTable[ib]
    index = index + 1
  end while
  return true
end function

/// Implements the `angledelta` operation for `miniquake.view` (angledelta).
/// @param angle The angle input consumed by `angledelta`.
function angledelta(angle)
  angle = math.anglemod(angle)
  if angle > 180.0 then angle = angle - 360.0 end if
  return angle
end function

/// Implements the `CalcGunAngle` operation for `miniquake.view` (calc gun angle).
/// @param state Mutable `miniquake.view` state used by `CalcGunAngle`.
/// @param clientTime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param idleScale The idle scale input consumed by `CalcGunAngle`.
/// @param yawCycle The yaw cycle input consumed by `CalcGunAngle`.
/// @param rollCycle The roll cycle input consumed by `CalcGunAngle`.
/// @param pitchCycle The pitch cycle input consumed by `CalcGunAngle`.
/// @param yawLevel The yaw level input consumed by `CalcGunAngle`.
/// @param rollLevel The roll level input consumed by `CalcGunAngle`.
/// @param pitchLevel The pitch level input consumed by `CalcGunAngle`.
function CalcGunAngle(state, clientTime, frameTime, idleScale, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
  // view.c computes both deltas from the same r_refdef angles; retaining that
  // historical quirk makes the target angles zero and only eases old values.
  yaw = 0.0
  pitch = 0.0
  move = frameTime * 20.0
  if yaw > state.oldGunYaw then
    if state.oldGunYaw + move < yaw then yaw = state.oldGunYaw + move end if
  else
    if state.oldGunYaw - move > yaw then yaw = state.oldGunYaw - move end if
  end if
  if pitch > state.oldGunPitch then
    if state.oldGunPitch + move < pitch then pitch = state.oldGunPitch + move end if
  else
    if state.oldGunPitch - move > pitch then pitch = state.oldGunPitch - move end if
  end if
  state.oldGunYaw = yaw
  state.oldGunPitch = pitch

  state.gunAngles.y = state.angles.y + yaw
  state.gunAngles.x = -(state.angles.x + pitch)
  state.gunAngles.z = state.gunAngles.z - idleScale * math.sin(clientTime * rollCycle) * rollLevel
  state.gunAngles.x = state.gunAngles.x - idleScale * math.sin(clientTime * pitchCycle) * pitchLevel
  state.gunAngles.y = state.gunAngles.y - idleScale * math.sin(clientTime * yawCycle) * yawLevel
  return state.gunAngles
end function

/// Mirror Quake's V_BoundOffsets routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_BoundOffsets`.
/// @param entityOrigin The entity origin input consumed by `V_BoundOffsets`.
function V_BoundOffsets(state, entityOrigin)
  if state.origin.x < entityOrigin.x - 14.0 then state.origin.x = entityOrigin.x - 14.0 end if
  if state.origin.x > entityOrigin.x + 14.0 then state.origin.x = entityOrigin.x + 14.0 end if
  if state.origin.y < entityOrigin.y - 14.0 then state.origin.y = entityOrigin.y - 14.0 end if
  if state.origin.y > entityOrigin.y + 14.0 then state.origin.y = entityOrigin.y + 14.0 end if
  if state.origin.z < entityOrigin.z - 22.0 then state.origin.z = entityOrigin.z - 22.0 end if
  if state.origin.z > entityOrigin.z + 30.0 then state.origin.z = entityOrigin.z + 30.0 end if
  return state.origin
end function

/// Mirror Quake's V_AddIdle routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_AddIdle`.
/// @param clientTime Time value used by the operation.
/// @param idleScale The idle scale input consumed by `V_AddIdle`.
/// @param yawCycle The yaw cycle input consumed by `V_AddIdle`.
/// @param rollCycle The roll cycle input consumed by `V_AddIdle`.
/// @param pitchCycle The pitch cycle input consumed by `V_AddIdle`.
/// @param yawLevel The yaw level input consumed by `V_AddIdle`.
/// @param rollLevel The roll level input consumed by `V_AddIdle`.
/// @param pitchLevel The pitch level input consumed by `V_AddIdle`.
function V_AddIdle(state, clientTime, idleScale, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
  state.angles.z = state.angles.z + idleScale * math.sin(clientTime * rollCycle) * rollLevel
  state.angles.x = state.angles.x + idleScale * math.sin(clientTime * pitchCycle) * pitchLevel
  state.angles.y = state.angles.y + idleScale * math.sin(clientTime * yawCycle) * yawLevel
  return state.angles
end function

/// Mirror Quake's V_CalcViewRoll routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CalcViewRoll`.
/// @param entityAngles The entity angles input consumed by `V_CalcViewRoll`.
/// @param velocity Velocity applied by the operation.
/// @param health The health input consumed by `V_CalcViewRoll`.
/// @param frameTime Time value used by the operation.
/// @param rollAngle The roll angle input consumed by `V_CalcViewRoll`.
/// @param rollSpeed The roll speed input consumed by `V_CalcViewRoll`.
/// @param kickTime Time value used by the operation.
function V_CalcViewRoll(state, entityAngles, velocity, health, frameTime, rollAngle, rollSpeed, kickTime)
  side = V_CalcRoll(entityAngles, velocity, rollAngle, rollSpeed)
  state.roll = side
  state.angles.z = state.angles.z + side
  if state.damageTime > 0.0 then
    if kickTime > 0.0 then
      state.angles.z = state.angles.z + state.damageTime / kickTime * state.damageRoll
      state.angles.x = state.angles.x + state.damageTime / kickTime * state.damagePitch
    end if
    state.damageTime = state.damageTime - frameTime
    state.damageKick.y = state.damageTime
  end if
  if health <= 0.0 then state.angles.z = 80.0 end if
  return state.angles
end function

/// Mirror Quake's V_CalcIntermissionRefdef routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CalcIntermissionRefdef`.
/// @param player The player input consumed by `V_CalcIntermissionRefdef`.
/// @param clientTime Time value used by the operation.
/// @param yawCycle The yaw cycle input consumed by `V_CalcIntermissionRefdef`.
/// @param rollCycle The roll cycle input consumed by `V_CalcIntermissionRefdef`.
/// @param pitchCycle The pitch cycle input consumed by `V_CalcIntermissionRefdef`.
/// @param yawLevel The yaw level input consumed by `V_CalcIntermissionRefdef`.
/// @param rollLevel The roll level input consumed by `V_CalcIntermissionRefdef`.
/// @param pitchLevel The pitch level input consumed by `V_CalcIntermissionRefdef`.
function V_CalcIntermissionRefdef(state, player, clientTime, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
  state.origin = math.copy(player.origin)
  state.angles = math.copy(player.renderAngles)
  state.intermission = true
  state.viewModelVisible = false
  V_AddIdle(state, clientTime, 1.0, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
  vectors = math.angleVectors(state.angles)
  state.forward = vectors[0]
  state.right = vectors[1]
  state.up = vectors[2]
  return state
end function

/// Implements the `smoothStairStep` operation for `miniquake.view` (smooth stair step).
/// @param state Mutable `miniquake.view` state used by `smoothStairStep`.
/// @param player The player input consumed by `smoothStairStep`.
/// @param frameTime Time value used by the operation.
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

/// Mirror Quake's V_CalcRefdef routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CalcRefdef`.
/// @param player The player input consumed by `V_CalcRefdef`.
/// @param viewAngles The view angles input consumed by `V_CalcRefdef`.
/// @param idealPitch The ideal pitch input consumed by `V_CalcRefdef`.
/// @param forwardMove The forward move input consumed by `V_CalcRefdef`.
/// @param forwardSpeed The forward speed input consumed by `V_CalcRefdef`.
/// @param clientTime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param stepFrameTime Time value used by the operation.
/// @param demoPlayback The demo playback input consumed by `V_CalcRefdef`.
/// @param registry The registry input consumed by `V_CalcRefdef`.
function V_CalcRefdef(state, player, viewAngles, idealPitch, forwardMove, forwardSpeed, clientTime, frameTime, stepFrameTime, demoPlayback, registry)
  opt001dCvarVIpitchLevel = cvar.variableValue(registry, "v_ipitch_level")
  opt001dCvarVIrollLevel = cvar.variableValue(registry, "v_iroll_level")
  opt001dCvarVIyawLevel = cvar.variableValue(registry, "v_iyaw_level")
  opt001dCvarVIpitchCycle = cvar.variableValue(registry, "v_ipitch_cycle")
  opt001dCvarVIrollCycle = cvar.variableValue(registry, "v_iroll_cycle")
  opt001dCvarVIyawCycle = cvar.variableValue(registry, "v_iyaw_cycle")
  opt001dCvarVIdlescale = cvar.variableValue(registry, "v_idlescale")
  V_DriftPitch(
    state,
    viewAngles,
    idealPitch,
    forwardMove,
    forwardSpeed,
    frameTime,
    clientTime,
    cvar.variableValue(registry, "v_centermove"),
    cvar.variableValue(registry, "v_centerspeed"),
    player.noclip,
    player.onGround,
    demoPlayback,
  )

  player.renderAngles.y = viewAngles.y
  player.renderAngles.x = -viewAngles.x
  rollEntityAngles = math.copy(player.renderAngles)
  state.bob = V_CalcBob(
    clientTime,
    player.velocity,
    cvar.variableValue(registry, "cl_bob"),
    cvar.variableValue(registry, "cl_bobcycle"),
    cvar.variableValue(registry, "cl_bobup"),
  )
  state.origin = t.Vec3(
    player.origin.x + 0.03125,
    player.origin.y + 0.03125,
    player.origin.z + player.viewHeight + state.bob + 0.03125,
  )
  state.angles = math.copy(viewAngles)
  V_CalcViewRoll(
    state,
    rollEntityAngles,
    player.velocity,
    player.health,
    frameTime,
    cvar.variableValue(registry, "cl_rollangle"),
    cvar.variableValue(registry, "cl_rollspeed"),
    cvar.variableValue(registry, "v_kicktime"),
  )
  V_AddIdle(
    state,
    clientTime,
    opt001dCvarVIdlescale,
    opt001dCvarVIyawCycle,
    opt001dCvarVIrollCycle,
    opt001dCvarVIpitchCycle,
    opt001dCvarVIyawLevel,
    opt001dCvarVIrollLevel,
    opt001dCvarVIpitchLevel,
  )

  offsetAngles = math.copy(player.renderAngles)
  offsetAngles.x = -offsetAngles.x
  offsetVectors = math.angleVectors(offsetAngles)
  offsetForward = offsetVectors[0]
  offsetRight = offsetVectors[1]
  offsetUp = offsetVectors[2]
  offsetX = cvar.variableValue(registry, "scr_ofsx")
  offsetY = cvar.variableValue(registry, "scr_ofsy")
  offsetZ = cvar.variableValue(registry, "scr_ofsz")
  state.origin.x = state.origin.x + offsetX * offsetForward.x + offsetY * offsetRight.x + offsetZ * offsetUp.x
  state.origin.y = state.origin.y + offsetX * offsetForward.y + offsetY * offsetRight.y + offsetZ * offsetUp.y
  state.origin.z = state.origin.z + offsetX * offsetForward.z + offsetY * offsetRight.z + offsetZ * offsetUp.z
  V_BoundOffsets(state, player.origin)

  state.gunAngles = math.copy(viewAngles)
  CalcGunAngle(
    state,
    clientTime,
    frameTime,
    opt001dCvarVIdlescale,
    opt001dCvarVIyawCycle,
    opt001dCvarVIrollCycle,
    opt001dCvarVIpitchCycle,
    opt001dCvarVIyawLevel,
    opt001dCvarVIrollLevel,
    opt001dCvarVIpitchLevel,
  )
  state.gunOrigin = math.copy(player.origin)
  state.gunOrigin.z = state.gunOrigin.z + player.viewHeight
  state.gunOrigin.x = state.gunOrigin.x + offsetForward.x * state.bob * 0.4
  state.gunOrigin.y = state.gunOrigin.y + offsetForward.y * state.bob * 0.4
  state.gunOrigin.z = state.gunOrigin.z + offsetForward.z * state.bob * 0.4 + state.bob
  viewSize = cvar.variableValue(registry, "viewsize")
  if viewSize == 110.0 then state.gunOrigin.z = state.gunOrigin.z + 1.0 end if
  if viewSize == 100.0 then state.gunOrigin.z = state.gunOrigin.z + 2.0 end if
  if viewSize == 90.0 then state.gunOrigin.z = state.gunOrigin.z + 1.0 end if
  if viewSize == 80.0 then state.gunOrigin.z = state.gunOrigin.z + 0.5 end if

  state.angles = math.add(state.angles, player.punchAngle)
  // The stair smoother is the one view calculation driven by
  // cl.time-cl.oldtime rather than host_frametime.
  step = smoothStairStep(state, player, stepFrameTime)
  state.origin.z = state.origin.z + step
  state.gunOrigin.z = state.gunOrigin.z + step
  state.intermission = false
  state.viewModelVisible = player.health > 0.0
  vectors = math.angleVectors(state.angles)
  state.forward = vectors[0]
  state.right = vectors[1]
  state.up = vectors[2]
  return state
end function

/// Mirror Quake's V_RenderView routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_RenderView`.
/// @param player The player input consumed by `V_RenderView`.
/// @param client Client state participating in the operation.
/// @param registry The registry input consumed by `V_RenderView`.
/// @param frameTime Time value used by the operation.
/// @param paused The paused input consumed by `V_RenderView`.
/// @param demoPlayback The demo playback input consumed by `V_RenderView`.
/// @param intermission The intermission input consumed by `V_RenderView`.
/// @param forcedConsole The forced console input consumed by `V_RenderView`.
function V_RenderView(state, player, client, registry, frameTime, paused, demoPlayback, intermission, forcedConsole)
  state.commandTrace = viewTraceEmpty
  if forcedConsole then return state end if
  // view.c drives bob, idle motion, pitch drift and weapon animation from
  // cl.time, not from the newest svc_time sample (cl.mtime[0]).
  clientTime = client.time

  if client.maxClients > 1 then
    cvar.set(registry, "scr_ofsx", "0")
    cvar.set(registry, "scr_ofsy", "0")
    cvar.set(registry, "scr_ofsz", "0")
  end if

  traceKind = 0
  if intermission != 0 then
    V_CalcIntermissionRefdef(
      state,
      player,
      clientTime,
      cvar.variableValue(registry, "v_iyaw_cycle"),
      cvar.variableValue(registry, "v_iroll_cycle"),
      cvar.variableValue(registry, "v_ipitch_cycle"),
      cvar.variableValue(registry, "v_iyaw_level"),
      cvar.variableValue(registry, "v_iroll_level"),
      cvar.variableValue(registry, "v_ipitch_level"),
    )
    traceKind = 2
  else if not paused then
    V_CalcRefdef(
      state,
      player,
      client.command.viewAngles,
      client.idealPitch,
      client.command.forwardMove,
      cvar.variableValue(registry, "cl_forwardspeed"),
      clientTime,
      frameTime,
      client.time - client.oldTime,
      demoPlayback,
      registry,
    )
    traceKind = 1
  end if

  lcdOffset = cvar.variableValue(registry, "lcd_x")
  if lcdOffset != 0.0 then
    if traceKind == 2 then state.commandTrace = viewTraceIntermissionStereo
    else if traceKind == 1 then state.commandTrace = viewTraceRefdefStereo
    else state.commandTrace = viewTracePausedStereo
    end if
    // The original leaves r_refdef at the right-eye position after the second
    // stereo pass.  Its global `right` vector was last written by V_CalcRoll
    // from the player entity angles, not by the later local offset basis.
    stereoRight = math.angleVectors(player.renderAngles)[1]
    state.angles.y = state.angles.y + cvar.variableValue(registry, "lcd_yaw")
    state.origin.x = state.origin.x + stereoRight.x * lcdOffset
    state.origin.y = state.origin.y + stereoRight.y * lcdOffset
    state.origin.z = state.origin.z + stereoRight.z * lcdOffset
  else
    if traceKind == 2 then state.commandTrace = viewTraceIntermission
    else if traceKind == 1 then state.commandTrace = viewTraceRefdef
    else state.commandTrace = viewTracePaused
    end if
  end if
  return state
end function

/// Mirror Quake's V_CommandTrace routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_CommandTrace`.
function V_CommandTrace(state)
  return state.commandTrace
end function

/// Mirror Quake's V_Init routine and its observable state changes.
/// @param state Mutable `miniquake.view` state used by `V_Init`.
function V_Init(state)
  state.commandTrace = [
    ["Cmd_AddCommand", "v_cshift"],
    ["Cmd_AddCommand", "bf"],
    ["Cmd_AddCommand", "centerview"],
    ["Cvar_RegisterVariable", "lcd_x"],
    ["Cvar_RegisterVariable", "lcd_yaw"],
    ["Cvar_RegisterVariable", "v_centermove"],
    ["Cvar_RegisterVariable", "v_centerspeed"],
    ["Cvar_RegisterVariable", "v_iyaw_cycle"],
    ["Cvar_RegisterVariable", "v_iroll_cycle"],
    ["Cvar_RegisterVariable", "v_ipitch_cycle"],
    ["Cvar_RegisterVariable", "v_iyaw_level"],
    ["Cvar_RegisterVariable", "v_iroll_level"],
    ["Cvar_RegisterVariable", "v_ipitch_level"],
    ["Cvar_RegisterVariable", "v_idlescale"],
    ["Cvar_RegisterVariable", "crosshair"],
    ["Cvar_RegisterVariable", "cl_crossx"],
    ["Cvar_RegisterVariable", "cl_crossy"],
    ["Cvar_RegisterVariable", "gl_cshiftpercent"],
    ["Cvar_RegisterVariable", "scr_ofsx"],
    ["Cvar_RegisterVariable", "scr_ofsy"],
    ["Cvar_RegisterVariable", "scr_ofsz"],
    ["Cvar_RegisterVariable", "cl_rollspeed"],
    ["Cvar_RegisterVariable", "cl_rollangle"],
    ["Cvar_RegisterVariable", "cl_bob"],
    ["Cvar_RegisterVariable", "cl_bobcycle"],
    ["Cvar_RegisterVariable", "cl_bobup"],
    ["Cvar_RegisterVariable", "v_kicktime"],
    ["Cvar_RegisterVariable", "v_kickroll"],
    ["Cvar_RegisterVariable", "v_kickpitch"],
    ["Cvar_RegisterVariable", "gamma"],
  ]
  BuildGammaTable(state, 1.0)
  return state
end function

/// Compatibility entry points retained for the existing focused tests.
/// @param state Mutable `miniquake.view` state used by `addDamage`.
/// @param count Number of entries or units to process.
/// @param fromDirection The from direction input consumed by `addDamage`.
/// @param viewAngles The view angles input consumed by `addDamage`.
/// @param kickRoll The kick roll input consumed by `addDamage`.
/// @param kickPitch The kick pitch input consumed by `addDamage`.
/// @param kickTime Time value used by the operation.
function addDamage(state, count, fromDirection, viewAngles, kickRoll, kickPitch, kickTime)
  V_ParseDamage(state, 0.0, count * 2.0, fromDirection, t.Vec3(0.0, 0.0, 0.0), viewAngles, kickRoll, kickPitch, kickTime)
  V_CalcBlend(state, 100.0)
  return state
end function

/// Implements the `decayDamage` operation for `miniquake.view` (decay damage).
/// @param state Mutable `miniquake.view` state used by `decayDamage`.
/// @param frameTime Time value used by the operation.
/// @param kickTime Time value used by the operation.
function decayDamage(state, frameTime, kickTime)
  state.damageTime = state.damageTime - frameTime
  if state.damageTime < 0.0 then state.damageTime = 0.0 end if
  state.damageKick.y = state.damageTime
  if kickTime <= 0.0 or state.damageTime == 0.0 then
    state.damageKick.x = 0.0
    state.damageKick.z = 0.0
  end if
  return state
end function

/// Compute the requested value.
/// @param state Mutable `miniquake.view` state used by `calculate`.
/// @param player The player input consumed by `calculate`.
/// @param cameraAngles The camera angles input consumed by `calculate`.
/// @param clientTime Time value used by the operation.
/// @param frameTime Time value used by the operation.
/// @param bobAmount The bob amount input consumed by `calculate`.
/// @param bobCycle The bob cycle input consumed by `calculate`.
/// @param bobUp The bob up input consumed by `calculate`.
/// @param rollAngle The roll angle input consumed by `calculate`.
/// @param rollSpeed The roll speed input consumed by `calculate`.
/// @param kickTime Time value used by the operation.
function calculate(state, player, cameraAngles, clientTime, frameTime, bobAmount, bobCycle, bobUp, rollAngle, rollSpeed, kickTime)
  state.bob = V_CalcBob(clientTime, player.velocity, bobAmount, bobCycle, bobUp)
  state.roll = V_CalcRoll(cameraAngles, player.velocity, rollAngle, rollSpeed)
  state.origin = t.Vec3(
    player.origin.x + 0.03125,
    player.origin.y + 0.03125,
    player.origin.z + player.viewHeight + state.bob + 0.03125,
  )
  state.origin.z = state.origin.z + smoothStairStep(state, player, frameTime)
  state.angles = math.copy(cameraAngles)
  state.angles.z = state.angles.z + state.roll
  if kickTime > 0.0 and state.damageTime > 0.0 then
    scale = state.damageTime / kickTime
    state.angles.x = state.angles.x + state.damagePitch * scale
    state.angles.z = state.angles.z + state.damageRoll * scale
  end if
  vectors = math.angleVectors(state.angles)
  state.forward = vectors[0]
  state.right = vectors[1]
  state.up = vectors[2]
  decayDamage(state, frameTime, kickTime)
  return state
end function
