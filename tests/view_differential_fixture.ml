/*
MiniLang side of the direct pinned WinQuake/view.c differential oracle.
*/

import miniquake.view as view
import miniquake.types as t
import miniquake.constants as c
import miniquake.common as common
import miniquake.host as host
import miniquake.client as client
import miniquake.player_move as movement
import miniquake.cvar as cvar
import miniquake.native as native
import std.string as string

function jsonNumber(value)
  integerValue = native.trunc(value)
  difference = value - integerValue
  if difference < 0.0 then difference = -difference end if
  if difference < 0.0000001 then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function boolNumber(value)
  if value then return 1 end if
  return 0
end function

function fnvBytes(data)
  hash = 2166136261
  index = 0
  while index < len(data)
    hash = ((hash ^ (data[index] & 255)) * 16777619) & 4294967295
    index = index + 1
  end while
  return hash
end function

function hashValues(values)
  data = bytes(len(values))
  index = 0
  while index < len(values)
    data[index] = values[index]
    index = index + 1
  end while
  return fnvBytes(data)
end function

function emptyState()
  state = view.create()
  state.commandTrace = []
  return state
end function

function emit(scene, functionName, state, counters, extras)
  values = counters + [
    state.origin.x, state.origin.y, state.origin.z,
    state.angles.x, state.angles.y, state.angles.z,
    state.gunOrigin.x, state.gunOrigin.y, state.gunOrigin.z,
    state.gunAngles.x, state.gunAngles.y, state.gunAngles.z,
    state.damageTime, state.damageRoll, state.damagePitch,
    state.blend[0], state.blend[1], state.blend[2], state.blend[3],
  ] + extras
  arguments = "["
  index = 0
  while index < len(values)
    if index > 0 then arguments = arguments + "," end if
    arguments = arguments + jsonNumber(values[index])
    index = index + 1
  end while
  arguments = arguments + "]"
  print "{\"schema\":\"miniquake.view.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":0,\"op\":\"state\",\"args\":" + arguments + "}"
end function

function noCounters()
  return [0, 0, 0, 0, 0, 0, 0]
end function

function traceCalcRoll()
  state = emptyState()
  result = view.V_CalcRoll(
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 100.0, 0.0), 2.0, 200.0
  )
  emit("view_calc_roll", "V_CalcRoll", state, noCounters(), [result, 0, 0, 0, 0, 0])
end function

function traceCalcBob()
  state = emptyState()
  result = view.V_CalcBob(
    0.15, t.Vec3(100.0, 0.0, 999.0), 0.02, 0.6, 0.5
  )
  emit("view_calc_bob", "V_CalcBob", state, noCounters(), [result, 0, 0, 0, 0, 0])
end function

function traceStartDrift()
  state = emptyState()
  state.lastStop = 1.0
  state.noDrift = true
  view.V_StartPitchDrift(state, 2.0, 500.0)
  emit(
    "view_start_drift", "V_StartPitchDrift", state, noCounters(),
    [state.pitchVelocity, boolNumber(state.noDrift), state.driftMove, 0, 0, 0],
  )
end function

function traceStopDrift()
  state = emptyState()
  state.pitchVelocity = 500.0
  view.V_StopPitchDrift(state, 2.0)
  emit(
    "view_stop_drift", "V_StopPitchDrift", state, noCounters(),
    [state.lastStop, boolNumber(state.noDrift), state.pitchVelocity, 0, 0, 0],
  )
end function

function traceDriftPitch()
  state = emptyState()
  state.noDrift = false
  state.pitchVelocity = 100.0
  angles = t.Vec3(0.0, 0.0, 0.0)
  view.V_DriftPitch(
    state, angles, 10.0, 0.0, 200.0, 0.1, 2.0,
    0.15, 500.0, false, true, false,
  )
  emit(
    "view_drift_pitch", "V_DriftPitch", state, noCounters(),
    [angles.x, state.pitchVelocity, state.driftMove, 0, 0, 0],
  )
end function

function traceBuildGamma()
  state = emptyState()
  view.BuildGammaTable(state, 0.5)
  emit(
    "view_build_gamma", "BuildGammaTable", state, noCounters(),
    [
      hashValues(state.gammaTable), state.gammaTable[0],
      state.gammaTable[128], state.gammaTable[255], 0, 0,
    ],
  )
end function

function traceCheckGamma()
  state = emptyState()
  first = view.V_CheckGamma(state, 0.7)
  second = view.V_CheckGamma(state, 0.7)
  emit(
    "view_check_gamma", "V_CheckGamma", state, noCounters(),
    [
      boolNumber(first), boolNumber(second), boolNumber(first),
      hashValues(state.gammaTable), 0, 0,
    ],
  )
end function

function traceParseDamage()
  state = emptyState()
  view.V_ParseDamage(
    state, 20.0, 10.0, t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0),
    0.6, 0.6, 0.5,
  )
  state.damageTime = 0.5
  damage = state.cshifts[view.CSHIFT_DAMAGE]
  emit(
    "view_parse_damage", "V_ParseDamage", state, noCounters(),
    [damage[0], damage[1], damage[2], damage[3], 2.2, 0],
  )
end function

function traceCshift()
  state = emptyState()
  view.V_cshift_f(state, ["v_cshift", "1", "2", "3", "4"])
  emit(
    "view_cshift", "V_cshift_f", state, noCounters(),
    [state.emptyCshift[0], state.emptyCshift[1], state.emptyCshift[2], state.emptyCshift[3], 0, 0],
  )
end function

function traceBonus()
  state = emptyState()
  view.V_BonusFlash_f(state)
  shift = state.cshifts[view.CSHIFT_BONUS]
  emit("view_bonus", "V_BonusFlash_f", state, noCounters(), [shift[0], shift[1], shift[2], shift[3], 0, 0])
end function

function traceContents()
  state = emptyState()
  view.V_cshift_f(state, ["v_cshift", "1", "2", "3", "4"])
  code = 0
  shift = view.V_SetContentsColor(state, c.CONTENTS_LAVA)
  code = code + shift[0]
  shift = view.V_SetContentsColor(state, c.CONTENTS_SLIME)
  code = code + shift[1]
  shift = view.V_SetContentsColor(state, c.CONTENTS_WATER)
  code = code + shift[3]
  shift = view.V_SetContentsColor(state, c.CONTENTS_EMPTY)
  emit("view_contents", "V_SetContentsColor", state, noCounters(), [code, shift[0], shift[1], shift[2], shift[3], 0])
end function

function tracePowerup()
  state = emptyState()
  code = 0
  shift = view.V_CalcPowerupCshift(state, c.IT_QUAD); code = code + shift[2]
  shift = view.V_CalcPowerupCshift(state, c.IT_SUIT); code = code + shift[1]
  shift = view.V_CalcPowerupCshift(state, c.IT_INVISIBILITY); code = code + shift[3]
  shift = view.V_CalcPowerupCshift(state, c.IT_INVULNERABILITY); code = code + shift[0]
  shift = view.V_CalcPowerupCshift(state, 0)
  emit("view_powerup", "V_CalcPowerupCshift", state, noCounters(), [code, shift[3], 0, 0, 0, 0])
end function

function setBlendShifts(state)
  state.cshifts[0] = [130.0, 80.0, 50.0, 128.0]
  state.cshifts[1] = [200.0, 100.0, 100.0, 45.0]
  state.cshifts[2] = [215.0, 186.0, 69.0, 50.0]
  state.cshifts[3] = [0.0, 0.0, 255.0, 30.0]
end function

function traceBlend()
  state = emptyState()
  setBlendShifts(state)
  view.V_CalcBlend(state, 100.0)
  emit("view_blend", "V_CalcBlend", state, noCounters(), [0, 0, 0, 0, 0, 0])
end function

function paletteHash(state)
  palette = bytes(768)
  index = 0
  while index < 256
    palette[index * 3] = state.ramps[0][(index * 3) & 255]
    palette[index * 3 + 1] = state.ramps[1][(index * 3 + 1) & 255]
    palette[index * 3 + 2] = state.ramps[2][(index * 3 + 2) & 255]
    index = index + 1
  end while
  return fnvBytes(palette)
end function

function rampsHash(state)
  data = bytes(768)
  channel = 0
  while channel < 3
    index = 0
    while index < 256
      data[channel * 256 + index] = state.ramps[channel][index]
      index = index + 1
    end while
    channel = channel + 1
  end while
  return fnvBytes(data)
end function

function traceUpdatePalette()
  state = emptyState()
  setBlendShifts(state)
  view.BuildGammaTable(state, 0.7)
  state.oldGamma = 0.7
  updated = view.V_UpdatePalette(state, c.IT_QUAD, 0.1, 100.0, 0.7)
  damage = state.cshifts[view.CSHIFT_DAMAGE]
  bonus = state.cshifts[view.CSHIFT_BONUS]
  counters = [0, 0, 0, 0, 0, boolNumber(updated), paletteHash(state)]
  emit(
    "view_update_palette", "V_UpdatePalette", state, counters,
    [boolNumber(updated), damage[3], bonus[3], rampsHash(state), 0, 0],
  )
end function

function traceAngleDelta()
  state = emptyState()
  result = view.angledelta(270.0)
  emit("view_angle_delta", "angledelta", state, noCounters(), [result, 0, 0, 0, 0, 0])
end function

function traceGunAngle()
  state = emptyState()
  state.angles = t.Vec3(10.0, 20.0, 3.0)
  state.gunAngles = t.Vec3(0.0, 0.0, 4.0)
  view.CalcGunAngle(state, 1.0, 0.1, 1.0, 2.0, 0.5, 1.0, 0.3, 0.1, 0.3)
  emit("view_gun_angle", "CalcGunAngle", state, noCounters(), [0, 0, 0, 0, 0, 0])
end function

function traceBoundOffsets()
  state = emptyState()
  state.origin = t.Vec3(-100.0, 100.0, 100.0)
  view.V_BoundOffsets(state, t.Vec3(10.0, 20.0, 30.0))
  emit("view_bound_offsets", "V_BoundOffsets", state, noCounters(), [0, 0, 0, 0, 0, 0])
end function

function traceAddIdle()
  state = emptyState()
  state.angles = t.Vec3(10.0, 20.0, 3.0)
  view.V_AddIdle(state, 1.0, 1.0, 2.0, 0.5, 1.0, 0.3, 0.1, 0.3)
  emit("view_add_idle", "V_AddIdle", state, noCounters(), [0, 0, 0, 0, 0, 0])
end function

function traceViewRoll()
  state = emptyState()
  state.damageTime = 0.5
  state.damageRoll = 6.0
  state.damagePitch = 3.0
  view.V_CalcViewRoll(
    state, t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 100.0, 0.0),
    100.0, 0.1, 2.0, 200.0, 0.5,
  )
  emit("view_calc_view_roll", "V_CalcViewRoll", state, noCounters(), [0, 0, 0, 0, 0, 0])
end function

function traceIntermission()
  state = emptyState()
  player = movement.create(t.Vec3(10.0, 20.0, 30.0), t.Vec3(5.0, 15.0, 2.0))
  view.V_CalcIntermissionRefdef(state, player, 1.0, 2.0, 0.5, 1.0, 0.3, 0.1, 0.3)
  emit("view_intermission", "V_CalcIntermissionRefdef", state, noCounters(), [boolNumber(not state.viewModelVisible), 0, 0, 0, 0, 0])
end function

function prepareRefdef()
  registry = host.createCvars(common.create([]), false)
  player = movement.create(t.Vec3(10.0, 20.0, 0.0), t.Vec3(0.0, 15.0, 0.0))
  player.onGround = true
  player.velocity = t.Vec3(100.0, 0.0, 0.0)
  player.weapon = 1
  player.weaponFrame = 2
  player.punchAngle = t.Vec3(1.0, 2.0, 3.0)
  localClient = client.create(player)
  localClient.maxClients = 1
  localClient.serverTime = 2.0
  localClient.time = 2.0
  localClient.idealPitch = 0.0
  localClient.command.forwardMove = 0.0
  localClient.command.viewAngles = t.Vec3(5.0, 15.0, 0.0)
  return [registry, player, localClient]
end function

function traceCalcRefdef()
  setup = prepareRefdef()
  registry = setup[0]; player = setup[1]; localClient = setup[2]
  state = emptyState()
  state.oldZ = 0.0
  state.oldZValid = true
  view.V_CalcRefdef(
    state, player, localClient.command.viewAngles, localClient.idealPitch,
    localClient.command.forwardMove, 200.0, 2.0, 0.1, 0.1, false, registry,
  )
  emit(
    "view_calc_refdef", "V_CalcRefdef", state, noCounters(),
    [1, player.weaponFrame, 1, player.renderAngles.x, player.renderAngles.y, 0],
  )
end function

function traceRenderView()
  setup = prepareRefdef()
  registry = setup[0]; player = setup[1]; localClient = setup[2]
  localClient.maxClients = 2
  cvar.set(registry, "scr_ofsx", "5")
  cvar.set(registry, "scr_ofsy", "6")
  cvar.set(registry, "scr_ofsz", "7")
  cvar.set(registry, "lcd_x", "2")
  cvar.set(registry, "lcd_yaw", "1")
  state = emptyState()
  state.oldZ = 0.0
  state.oldZValid = true
  view.V_RenderView(state, player, localClient, registry, 0.1, false, false, 0, false)
  pushCount = 0
  renderCount = 0
  for each command in state.commandTrace
    if command[0] == "R_PushDlights" then pushCount = pushCount + 1 end if
    if command[0] == "R_RenderView" then renderCount = renderCount + 1 end if
  end for
  counters = [pushCount, renderCount, 3, 0, 0, 0, 0]
  emit("view_render_view", "V_RenderView", state, counters, [640, 1, 960, 0, 0, 0])
end function

function traceInit()
  state = emptyState()
  state.gammaTable = []
  index = 0
  while index < 256
    state.gammaTable = state.gammaTable + [0]
    index = index + 1
  end while
  state.commandTrace = []
  view.V_Init(state)
  commands = 0
  cvars = 0
  for each command in state.commandTrace
    if command[0] == "Cmd_AddCommand" then commands = commands + 1 end if
    if command[0] == "Cvar_RegisterVariable" then cvars = cvars + 1 end if
  end for
  counters = [0, 0, 0, commands, cvars, 0, 0]
  emit(
    "view_init", "V_Init", state, counters,
    [hashValues(state.gammaTable), state.gammaTable[0], state.gammaTable[128], state.gammaTable[255], 0, 0],
  )
end function

function main(args)
  traceCalcRoll()
  traceCalcBob()
  traceStartDrift()
  traceStopDrift()
  traceDriftPitch()
  traceBuildGamma()
  traceCheckGamma()
  traceParseDamage()
  traceCshift()
  traceBonus()
  traceContents()
  tracePowerup()
  traceBlend()
  traceUpdatePalette()
  traceAngleDelta()
  traceGunAngle()
  traceBoundOffsets()
  traceAddIdle()
  traceViewRoll()
  traceIntermission()
  traceCalcRefdef()
  traceRenderView()
  traceInit()
  return 0
end function
