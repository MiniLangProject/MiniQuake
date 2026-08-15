/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-050: MiniQuake mirror selection, reflection and entity handoff.
*/
import miniquake.render.special_paths as bp050Special
import miniquake.client_render_handoff as bp050Handoff
import miniquake.types as bp050Types
import miniquake.constants as bp050Constants

struct Bp050Entity
  number
  modelIndex
end struct

// Assert exact equality and report both values on failure.
function bp050Equal(actual, expected, name)
  if actual != expected then return error(5000, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function bp050Yes(value, name)
  if not value then return error(5001, name + ": expected true") end if
  return true
end function
// Assert floating-point equality within the requested tolerance.
function bp050Near(actual, expected, tolerance, name)
  difference = actual - expected
  if difference < 0.0 then difference = -difference end if
  if difference > tolerance then return error(5002, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function bp050Run(number, name, fn)
  print "[" + number + "/22] " + name
  value = try(fn())
  if value is error then print "FAIL: " + value.message; return false end if
  return true
end function
// Exercise the texture test scenario and verify its expected result.
function bp050Texture(name)
  return bp050Types.RenderTexture(name, 16, 16, 1, bytes(), false)
end function
// Exercise the prefix exact test scenario and verify its expected result.
function bp050PrefixExact()
  bp050Yes(bp050Special.mirrorTextureName("window02_1"), "exact prefix")
  return true
end function
// Exercise the prefix suffix test scenario and verify its expected result.
function bp050PrefixSuffix()
  bp050Yes(bp050Special.mirrorTextureName("window02_1_extra"), "prefix suffix")
  return true
end function
// Exercise the prefix short test scenario and verify its expected result.
function bp050PrefixShort()
  bp050Equal(bp050Special.mirrorTextureName("window02"), false, "short prefix")
  return true
end function
// Exercise the prefix case test scenario and verify its expected result.
function bp050PrefixCase()
  bp050Equal(bp050Special.mirrorTextureName("Window02_1"), false, "case sensitivity")
  return true
end function
// Return texture.
function bp050FindTexture()
  textures = [bp050Texture("stone"), bp050Texture("window02_1"), bp050Texture("window02_1b")]
  bp050Equal(bp050Special.findMirrorTexture(textures), 1, "first mirror texture")
  return true
end function
// Exercise the missing texture test scenario and verify its expected result.
function bp050MissingTexture()
  bp050Equal(bp050Special.findMirrorTexture([bp050Texture("stone")]), -1, "missing mirror texture")
  return true
end function
// Exercise the distance test scenario and verify its expected result.
function bp050Distance()
  value = bp050Special.mirrorDistance(bp050Types.Vec3(1.0, 2.0, 3.0), bp050Types.Vec3(0.0, 0.0, 1.0), 1.0)
  bp050Equal(value, 2.0, "mirror distance")
  return true
end function
// Exercise the reflect point z test scenario and verify its expected result.
function bp050ReflectPointZ()
  value = bp050Special.reflectPoint(bp050Types.Vec3(1.0, 2.0, 3.0), bp050Types.Vec3(0.0, 0.0, 1.0), 1.0)
  bp050Equal(value.x, 1.0, "point z x")
  bp050Equal(value.y, 2.0, "point z y")
  bp050Equal(value.z, -1.0, "point z z")
  return true
end function
// Exercise the reflect point x test scenario and verify its expected result.
function bp050ReflectPointX()
  value = bp050Special.reflectPoint(bp050Types.Vec3(3.0, 2.0, 1.0), bp050Types.Vec3(1.0, 0.0, 0.0), 2.0)
  bp050Equal(value.x, 1.0, "point x")
  return true
end function
// Exercise the reflect vector z test scenario and verify its expected result.
function bp050ReflectVectorZ()
  value = bp050Special.reflectVector(bp050Types.Vec3(0.0, 0.0, -1.0), bp050Types.Vec3(0.0, 0.0, 1.0))
  bp050Equal(value.z, 1.0, "vector z")
  return true
end function
// Exercise the reflect vector x test scenario and verify its expected result.
function bp050ReflectVectorX()
  value = bp050Special.reflectVector(bp050Types.Vec3(1.0, 2.0, 0.0), bp050Types.Vec3(1.0, 0.0, 0.0))
  bp050Equal(value.x, -1.0, "vector x")
  bp050Equal(value.y, 2.0, "vector y")
  return true
end function
// Exercise the direction forward test scenario and verify its expected result.
function bp050DirectionForward()
  value = bp050Special.directionAngles(bp050Types.Vec3(1.0, 0.0, 0.0), 10.0)
  bp050Near(value.x, 0.0, 0.0001, "forward pitch")
  bp050Near(value.y, 0.0, 0.0001, "forward yaw")
  bp050Equal(value.z, -10.0, "forward roll")
  return true
end function
// Exercise the direction left test scenario and verify its expected result.
function bp050DirectionLeft()
  value = bp050Special.directionAngles(bp050Types.Vec3(0.0, 1.0, 0.0), 0.0)
  bp050Near(value.y, 90.0, 0.0001, "left yaw")
  return true
end function
// Exercise the reflect view floor test scenario and verify its expected result.
function bp050ReflectViewFloor()
  plane = bp050Types.Plane(bp050Types.Vec3(0.0, 0.0, 1.0), 0.0, 2, 0)
  value = bp050Special.reflectView(bp050Types.Vec3(1.0, 2.0, 3.0), bp050Types.Vec3(0.0, 0.0, 10.0), plane)
  bp050Equal(value[0].z, -3.0, "floor origin")
  bp050Near(value[1].x, 0.0, 0.0001, "floor pitch")
  bp050Equal(value[1].z, -10.0, "floor roll")
  return true
end function
// Exercise the reflect view wall test scenario and verify its expected result.
function bp050ReflectViewWall()
  plane = bp050Types.Plane(bp050Types.Vec3(1.0, 0.0, 0.0), 0.0, 0, 0)
  value = bp050Special.reflectView(bp050Types.Vec3(3.0, 0.0, 0.0), bp050Types.Vec3(0.0, 0.0, 0.0), plane)
  bp050Equal(value[0].x, -3.0, "wall origin")
  bp050Near(value[1].y, 180.0, 0.0001, "wall yaw")
  return true
end function
// Exercise the scale floor test scenario and verify its expected result.
function bp050ScaleFloor()
  value = bp050Special.mirrorProjectionScale(bp050Types.Plane(bp050Types.Vec3(0.0, 0.0, 1.0), 0.0, 2, 0))
  bp050Equal(value.y, -1.0, "floor projection scale")
  return true
end function
// Exercise the scale wall test scenario and verify its expected result.
function bp050ScaleWall()
  value = bp050Special.mirrorProjectionScale(bp050Types.Plane(bp050Types.Vec3(1.0, 0.0, 0.0), 0.0, 0, 0))
  bp050Equal(value.x, -1.0, "wall projection scale")
  return true
end function
// Exercise the missing plane test scenario and verify its expected result.
function bp050MissingPlane()
  value = try(bp050Special.reflectView(bp050Types.Vec3(0.0, 0.0, 0.0), bp050Types.Vec3(0.0, 0.0, 0.0), void))
  bp050Yes(value is error, "missing plane error")
  return true
end function
// Exercise the mirror entity append test scenario and verify its expected result.
function bp050MirrorEntityAppend()
  visible = [Bp050Entity(1, 2)]
  result = bp050Handoff.submitMirrorEntities(visible, [], Bp050Entity(2, 3))
  bp050Equal(len(result), 2, "mirror entity append")
  bp050Equal(result[1].number, 2, "mirror entity number")
  return true
end function
// Exercise the mirror entity dedup test scenario and verify its expected result.
function bp050MirrorEntityDedup()
  view = Bp050Entity(1, 2)
  result = bp050Handoff.submitMirrorEntities([view], [], view)
  bp050Equal(len(result), 1, "mirror entity dedup")
  return true
end function
// Exercise the mirror entity model zero test scenario and verify its expected result.
function bp050MirrorEntityModelZero()
  result = bp050Handoff.submitMirrorEntities([], [], Bp050Entity(1, 0))
  bp050Equal(len(result), 0, "model zero")
  return true
end function
// Exercise the mirror entity capacity test scenario and verify its expected result.
function bp050MirrorEntityCapacity()
  item = Bp050Entity(1, 2)
  result = bp050Handoff.submitMirrorEntities(array(bp050Constants.MAX_VISEDICTS, item), [], Bp050Entity(999, 2))
  bp050Equal(len(result), bp050Constants.MAX_VISEDICTS, "visible capacity")
  return true
end function

passed = 0
if bp050Run(1, "mirror prefix exact", bp050PrefixExact) then passed = passed + 1 end if
if bp050Run(2, "mirror prefix suffix", bp050PrefixSuffix) then passed = passed + 1 end if
if bp050Run(3, "mirror prefix short", bp050PrefixShort) then passed = passed + 1 end if
if bp050Run(4, "mirror prefix case", bp050PrefixCase) then passed = passed + 1 end if
if bp050Run(5, "find mirror texture", bp050FindTexture) then passed = passed + 1 end if
if bp050Run(6, "missing mirror texture", bp050MissingTexture) then passed = passed + 1 end if
if bp050Run(7, "mirror plane distance", bp050Distance) then passed = passed + 1 end if
if bp050Run(8, "reflect point across floor", bp050ReflectPointZ) then passed = passed + 1 end if
if bp050Run(9, "reflect point across wall", bp050ReflectPointX) then passed = passed + 1 end if
if bp050Run(10, "reflect vector across floor", bp050ReflectVectorZ) then passed = passed + 1 end if
if bp050Run(11, "reflect vector across wall", bp050ReflectVectorX) then passed = passed + 1 end if
if bp050Run(12, "forward direction angles", bp050DirectionForward) then passed = passed + 1 end if
if bp050Run(13, "left direction angles", bp050DirectionLeft) then passed = passed + 1 end if
if bp050Run(14, "reflected floor view", bp050ReflectViewFloor) then passed = passed + 1 end if
if bp050Run(15, "reflected wall view", bp050ReflectViewWall) then passed = passed + 1 end if
if bp050Run(16, "floor projection scale", bp050ScaleFloor) then passed = passed + 1 end if
if bp050Run(17, "wall projection scale", bp050ScaleWall) then passed = passed + 1 end if
if bp050Run(18, "missing mirror plane", bp050MissingPlane) then passed = passed + 1 end if
if bp050Run(19, "mirror view entity append", bp050MirrorEntityAppend) then passed = passed + 1 end if
if bp050Run(20, "mirror view entity dedup", bp050MirrorEntityDedup) then passed = passed + 1 end if
if bp050Run(21, "mirror view entity model zero", bp050MirrorEntityModelZero) then passed = passed + 1 end if
if bp050Run(22, "mirror visible capacity", bp050MirrorEntityCapacity) then passed = passed + 1 end if
if passed != 22 then print "MiniQuake BP-050 mirror special-render tests failed: " + passed + "/22"; error(5099, "BP-050 mirror special-render") end if
print "MiniQuake BP-050 mirror special-render tests passed: 22"
