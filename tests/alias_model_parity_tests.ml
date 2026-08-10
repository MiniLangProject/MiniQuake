/* BP-045: MiniQuake alias model, shadow-origin and texture-unit parity. */

import miniquake.render.alias_mesh as aliasMesh
import miniquake.render.world as worldRender

function bp045Yes(value, name)
  if not value then return error(4500, name + ": expected true") end if
  return true
end function

function bp045Equal(actual, expected, name)
  if actual != expected then return error(4501, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function bp045Near(actual, expected, epsilon, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > epsilon then return error(4502, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function bp045Run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function bp045ProjectionA()
  result = aliasMesh.aliasShadowProjection(13.0, 3.0)
  bp045Equal(result[0], 10.0, "positive lheight")
  return true
end function
function bp045ProjectionB()
  result = aliasMesh.aliasShadowProjection(13.0, 3.0)
  bp045Equal(result[1], -9.0, "positive shadow height")
  return true
end function
function bp045ProjectionC()
  result = aliasMesh.aliasShadowProjection(-2.0, 3.0)
  bp045Equal(result[0], -5.0, "negative lheight")
  return true
end function
function bp045ProjectionD()
  result = aliasMesh.aliasShadowProjection(-2.0, 3.0)
  bp045Equal(result[1], 6.0, "negative shadow height")
  return true
end function
function bp045ProjectionEqual()
  result = aliasMesh.aliasShadowProjection(7.0, 7.0)
  bp045Equal(result[1], 1.0, "equal-height shadow")
  return true
end function
function bp045ProjectionFraction()
  result = aliasMesh.aliasShadowProjection(1.25, -0.5)
  bp045Near(result[0], 1.75, 0.000001, "fractional lheight")
  return true
end function
function bp045Row0()
  bp045Equal(aliasMesh.shadeDotRow(0.0), 0, "row zero")
  return true
end function
function bp045Row90()
  bp045Equal(aliasMesh.shadeDotRow(90.0), 4, "row 90")
  return true
end function
function bp045Row180()
  bp045Equal(aliasMesh.shadeDotRow(180.0), 8, "row 180")
  return true
end function
function bp045Row270()
  bp045Equal(aliasMesh.shadeDotRow(270.0), 12, "row 270")
  return true
end function
function bp045Row360()
  bp045Equal(aliasMesh.shadeDotRow(360.0), 0, "row wrap")
  return true
end function
function bp045RowNegative()
  bp045Equal(aliasMesh.shadeDotRow(-90.0), 12, "negative row")
  return true
end function
function bp045ClampLow()
  bp045Equal(aliasMesh.clampByte(-4.0), 0, "clamp low")
  return true
end function
function bp045ClampZero()
  bp045Equal(aliasMesh.clampByte(0.0), 0, "clamp zero")
  return true
end function
function bp045ClampTrunc()
  bp045Equal(aliasMesh.clampByte(12.9), 12, "clamp truncation")
  return true
end function
function bp045ClampHigh()
  bp045Equal(aliasMesh.clampByte(999.0), 255, "clamp high")
  return true
end function
function bp045LightingConfigure()
  bp045Yes(aliasMesh.configureAliasLighting(0.75, 24.0, 90.0, void), "lighting configure")
  return true
end function
function bp045MultitextureDisabledA()
  worldRender.R_SetMultitextureCompatibility(true, true)
  bp045Yes(worldRender.GL_DisableMultitexture(), "disable multitexture")
  return true
end function
function bp045MultitextureDisabledB()
  bp045Yes(worldRender.GL_DisableMultitexture(), "idempotent disable")
  return true
end function
function bp045ProjectionLarge()
  result = aliasMesh.aliasShadowProjection(1024.0, -256.0)
  bp045Equal(result[0], 1280.0, "large lheight")
  return true
end function
function bp045ProjectionLargeHeight()
  result = aliasMesh.aliasShadowProjection(1024.0, -256.0)
  bp045Equal(result[1], -1279.0, "large shadow height")
  return true
end function
function bp045QuantizationCount()
  index = 0
  while index < 16
    bp045Equal(aliasMesh.shadeDotRow(index * 22.5), index, "shade row " + index)
    index = index + 1
  end while
  return true
end function

passed = 0
if bp045Run(1, "shadow lheight", bp045ProjectionA) then passed = passed + 1 end if
if bp045Run(2, "shadow projected height", bp045ProjectionB) then passed = passed + 1 end if
if bp045Run(3, "shadow below lightspot", bp045ProjectionC) then passed = passed + 1 end if
if bp045Run(4, "shadow below projected height", bp045ProjectionD) then passed = passed + 1 end if
if bp045Run(5, "equal-height projection", bp045ProjectionEqual) then passed = passed + 1 end if
if bp045Run(6, "fractional projection", bp045ProjectionFraction) then passed = passed + 1 end if
if bp045Run(7, "shadedot row zero", bp045Row0) then passed = passed + 1 end if
if bp045Run(8, "shadedot row 90", bp045Row90) then passed = passed + 1 end if
if bp045Run(9, "shadedot row 180", bp045Row180) then passed = passed + 1 end if
if bp045Run(10, "shadedot row 270", bp045Row270) then passed = passed + 1 end if
if bp045Run(11, "shadedot wrap", bp045Row360) then passed = passed + 1 end if
if bp045Run(12, "shadedot negative", bp045RowNegative) then passed = passed + 1 end if
if bp045Run(13, "color clamp low", bp045ClampLow) then passed = passed + 1 end if
if bp045Run(14, "color clamp zero", bp045ClampZero) then passed = passed + 1 end if
if bp045Run(15, "color truncation", bp045ClampTrunc) then passed = passed + 1 end if
if bp045Run(16, "color clamp high", bp045ClampHigh) then passed = passed + 1 end if
if bp045Run(17, "alias lighting setup", bp045LightingConfigure) then passed = passed + 1 end if
if bp045Run(18, "multitexture reset", bp045MultitextureDisabledA) then passed = passed + 1 end if
if bp045Run(19, "multitexture reset idempotence", bp045MultitextureDisabledB) then passed = passed + 1 end if
if bp045Run(20, "large shadow lheight", bp045ProjectionLarge) then passed = passed + 1 end if
if bp045Run(21, "large projected height", bp045ProjectionLargeHeight) then passed = passed + 1 end if
if bp045Run(22, "sixteen shadedot rows", bp045QuantizationCount) then passed = passed + 1 end if

if passed != 22 then
  print "MiniQuake BP-045 alias model tests failed: " + passed + "/22"
  error(4599, "BP-045 alias model parity")
end if
print "MiniQuake BP-045 alias model tests passed: 22"
