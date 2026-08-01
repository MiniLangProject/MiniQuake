/* BP-035: cl_main.c state, relink and renderer hand-off parity. */

import miniquake.client as client
import miniquake.types as t
import miniquake.constants as c
import miniquake.player_move as playerMove
import miniquake.native as native

function yes(value, name)
  if not value then return error(3500, name + ": expected true") end if
  return true
end function

function no(value, name)
  if value then return error(3501, name + ": expected false") end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(3502, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, name)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(3503, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/20] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function newClient()
  value = client.create(playerMove.create(t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0)))
  value.localAuthoritative = false
  value.messageTimes = [2.0, 1.9]
  value.time = 2.0
  value.noLerp = true
  return value
end function

function activeEntity(value, number, modelIndex)
  entity = client.ensureEntity(value, number)
  entity.modelIndex = modelIndex
  entity.messageTime = value.messageTimes[0]
  entity.messageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.forceLink = false
  return entity
end function

function testDlightKeyReuse()
  client.CL_ClearDlights()
  first = client.CL_AllocDlightAt(17, 1.0)
  first.radius = 99.0
  first.die = 2.0
  second = client.CL_AllocDlightAt(17, 1.0)
  equal(client.CL_DlightIndexForKey(17), 0, "key slot")
  near(second.radius, 0.0, 0.0, "key reset")
  return true
end function

function testDlightStrictExpiry()
  client.CL_ClearDlights()
  first = client.CL_AllocDlightAt(1, 1.0)
  first.die = 1.0
  second = client.CL_AllocDlightAt(2, 1.0)
  equal(client.CL_DlightIndexForKey(2), 1, "equal die is active")
  second.die = 3.0
  third = client.CL_AllocDlightAt(3, 1.001)
  equal(client.CL_DlightIndexForKey(3), 0, "strictly expired slot")
  return true
end function

function testDlightOverflowFallback()
  client.CL_ClearDlights()
  index = 0
  while index < c.MAX_DLIGHTS
    light = client.CL_AllocDlightAt(index + 1, 1.0)
    light.die = 10.0
    index = index + 1
  end while
  client.CL_AllocDlightAt(999, 1.0)
  equal(client.CL_DlightIndexForKey(999), 0, "slot zero fallback")
  return true
end function

function testDlightDecayEquality()
  client.CL_ClearDlights()
  light = client.CL_AllocDlightAt(5, 1.0)
  light.radius = 100.0
  light.decay = 40.0
  light.die = 1.0
  client.CL_DecayLightsAt(1.0, 0.25)
  near(light.radius, 90.0, 0.000001, "die equality decays")
  return true
end function

function testLerpHalf()
  value = newClient()
  value.noLerp = false
  value.time = 1.95
  near(client.CL_LerpPoint(value), 0.5, 0.000001, "half lerp")
  return true
end function

function testLerpGapClamp()
  value = newClient()
  value.noLerp = false
  value.messageTimes = [3.0, 2.0]
  value.time = 2.95
  near(client.CL_LerpPoint(value), 0.5, 0.000001, "clamped gap fraction")
  near(value.messageTimes[1], 2.9, 0.000001, "clamped old message")
  return true
end function

function testNoLerpPinsTime()
  value = newClient()
  value.time = 1.5
  near(client.CL_LerpPoint(value), 1.0, 0.0, "no lerp result")
  near(value.time, 2.0, 0.0, "no lerp pins latest")
  return true
end function

function testAngleWrap()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  entity.forceLink = false
  entity.previousMessageAngles = t.Vec3(0.0, 350.0, 0.0)
  entity.messageAngles = t.Vec3(0.0, 10.0, 0.0)
  value.noLerp = false
  value.time = 1.95
  client.CL_RelinkEntities(value)
  near(entity.angles.y, 360.0, 0.00001, "short angle path")
  return true
end function

function testViewEntityHidden()
  value = newClient()
  activeEntity(value, 1, 1)
  value.viewEntity = 1
  client.CL_SetChaseActive(false)
  client.CL_RelinkEntities(value)
  equal(len(value.visibleEntities), 0, "view entity hidden")
  return true
end function

function testChaseIncludesViewEntity()
  value = newClient()
  activeEntity(value, 1, 1)
  value.viewEntity = 1
  client.CL_SetChaseActive(true)
  client.CL_RelinkEntities(value)
  equal(len(value.visibleEntities), 1, "chase view entity")
  client.CL_SetChaseActive(false)
  return true
end function

function testStaticEntityVisible()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  entity.messageTime = -1.0
  client.CL_RelinkEntities(value)
  equal(len(value.visibleEntities), 1, "static entity")
  return true
end function

function testStaleEntityClearsModel()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  entity.messageTime = 1.0
  client.CL_RelinkEntities(value)
  equal(entity.modelIndex, 0, "stale model cleared")
  equal(len(value.visibleEntities), 0, "stale entity hidden")
  return true
end function

function testForceLinkSnap()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.messageOrigin = t.Vec3(10.0, 0.0, 0.0)
  entity.forceLink = true
  value.noLerp = false
  value.time = 1.95
  client.CL_RelinkEntities(value)
  near(entity.origin.x, 10.0, 0.0, "force link snap")
  no(entity.forceLink, "force link cleared")
  return true
end function

function testTeleportSnap()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  entity.previousMessageOrigin = t.Vec3(0.0, 0.0, 0.0)
  entity.messageOrigin = t.Vec3(101.0, 0.0, 0.0)
  value.noLerp = false
  value.time = 1.95
  client.CL_RelinkEntities(value)
  near(entity.origin.x, 101.0, 0.0, "teleport snap")
  return true
end function

function testVisibleCap()
  value = newClient()
  index = 1
  while index <= c.MAX_VISEDICTS + 3
    entity = activeEntity(value, index, 1)
    entity.messageTime = -1.0
    index = index + 1
  end while
  client.CL_RelinkEntities(value)
  equal(len(value.visibleEntities), c.MAX_VISEDICTS, "MAX_VISEDICTS cap")
  return true
end function

function testActiveVisibleFilter()
  value = newClient()
  valid = client.createEntity(1)
  valid.modelIndex = 1
  cleared = client.createEntity(2)
  cleared.modelIndex = 0
  value.visibleEntities = [valid, void, cleared, valid]
  active = client.CL_ActiveVisibleEntities(value)
  equal(len(active), 2, "defensive active view")
  equal(active[0].number, 1, "first visible")
  return true
end function

function testEfragRemovalCandidates()
  value = newClient()
  removed = client.ensureEntity(value, 1)
  removed.modelIndex = 0
  removed.forceLink = true
  inactive = client.ensureEntity(value, 2)
  inactive.modelIndex = 0
  inactive.forceLink = false
  live = client.ensureEntity(value, 3)
  live.modelIndex = 1
  live.forceLink = true
  candidates = client.CL_EfragRemovalCandidates(value)
  equal(len(candidates), 1, "removal count")
  equal(candidates[0].number, 1, "removal entity")
  return true
end function

function testRotateFlag()
  value = newClient()
  entity = activeEntity(value, 1, 1)
  client.CL_SetModelFlags([0, c.EF_ROTATE])
  value.time = 1.0
  client.CL_RelinkEntities(value)
  // CL_LerpPoint runs before bobjrotate. With noLerp enabled it snaps
  // client.time to mtime[0] (2.0) before anglemod(100 * cl.time).
  near(value.time, 2.0, 0.0, "no-lerp time snap")
  near(entity.angles.y, 199.9951171875, 0.0001, "binary object rotation")
  return true
end function


function testClientFloatBoundary()
  equal(client.clientFloat(16777217), 16777216.0, "binary32 integer boundary")
  return true
end function

function testViewEntityOrigin()
  value = newClient()
  entity = activeEntity(value, 3, 1)
  entity.origin = t.Vec3(4.0, 5.0, 6.0)
  value.viewEntity = 3
  origin = client.CL_ViewEntityOrigin(value)
  near(origin.x, 4.0, 0.0, "view origin x")
  near(origin.z, 6.0, 0.0, "view origin z")
  return true
end function

function main(args)
  tests = [
    ["dlight key reuse", testDlightKeyReuse],
    ["dlight strict expiry", testDlightStrictExpiry],
    ["dlight overflow fallback", testDlightOverflowFallback],
    ["dlight decay equality", testDlightDecayEquality],
    ["lerp half", testLerpHalf],
    ["lerp gap clamp", testLerpGapClamp],
    ["no lerp pin", testNoLerpPinsTime],
    ["angle wrap", testAngleWrap],
    ["view entity hidden", testViewEntityHidden],
    ["chase view entity", testChaseIncludesViewEntity],
    ["static entity", testStaticEntityVisible],
    ["stale entity", testStaleEntityClearsModel],
    ["force-link snap", testForceLinkSnap],
    ["teleport snap", testTeleportSnap],
    ["visible cap", testVisibleCap],
    ["active visible filter", testActiveVisibleFilter],
    ["efrag removal candidates", testEfragRemovalCandidates],
    ["rotate flag", testRotateFlag],
    ["binary32 boundary", testClientFloatBoundary],
    ["view entity origin", testViewEntityOrigin],
  ]
  passed = 0
  index = 0
  while index < len(tests)
    if run(index + 1, tests[index][0], tests[index][1]) then passed = passed + 1 end if
    index = index + 1
  end while
  if passed != 20 then return 1 end if
  print "MiniQuake BP-035 client state/render tests passed: 20"
  return 0
end function
