/* BP-046: sprite ST_SYNC/ST_RAND and entity syncbase parity. */

import miniquake.types as t
import miniquake.constants as c
import miniquake.client as client
import miniquake.particles as particles
import miniquake.native as native
import miniquake.render.entities as entities

function bp046Yes(value, name)
  if not value then return error(4600, name + ": expected true") end if
  return true
end function
function bp046Equal(actual, expected, name)
  if actual != expected then return error(4601, name + ": expected " + expected + ", got " + actual) end if
  return true
end function
function bp046Run(number, name, fn)
  print "[" + number + "/22] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function
function bp046Entity(modelIndex)
  zero = t.Vec3(0.0, 0.0, 0.0)
  return t.ClientEntityState(1, modelIndex, 0, 0, 0, 0, zero, zero, 0.0, zero, zero, zero, zero, false, void, 0.0)
end function
function bp046Sprite(syncType)
  first = t.SpriteFrame(0.0, 1.0, 1, 1, bytes(1))
  second = t.SpriteFrame(0.0, 1.0, 1, 1, bytes(1))
  set = t.SpriteFrameSet(true, [0.1, 0.2], [first, second])
  source = t.SpriteModel("fixture.spr", bytes(), 1, 0, 1.0, 1, 1, 1, 0.0, syncType, [set])
  return t.ClientRenderModel("fixture.spr", entities.MODEL_SPRITE, void, source, [[101, 102]], true)
end function

function bp046SetTypes()
  bp046Equal(client.CL_SetModelSyncTypes([c.ST_SYNC, c.ST_RAND, c.ST_SYNC]), 3, "sync type count")
  return true
end function
function bp046ReadTypes()
  types = client.CL_ModelSyncTypes()
  bp046Equal(types[1], c.ST_RAND, "sync type value")
  return true
end function
function bp046UnknownType()
  bp046Equal(client.modelSyncTypeForIndex(99), c.ST_SYNC, "unknown model sync")
  return true
end function
function bp046SyncModel()
  client.CL_SetModelSyncTypes([c.ST_SYNC, c.ST_SYNC])
  entity = bp046Entity(1)
  entity.syncBase = 0.5
  client.CL_AssignModelSyncBase(entity, 0)
  bp046Equal(native.floatBits(entity.syncBase), 0, "ST_SYNC base")
  return true
end function
function bp046RandFirst()
  particles.resetRandom(1)
  client.CL_SetModelSyncTypes([c.ST_SYNC, c.ST_RAND])
  entity = bp046Entity(1)
  client.CL_AssignModelSyncBase(entity, 0)
  bp046Equal(native.floatBits(entity.syncBase), 0x3aa40148, "first random syncbase")
  return true
end function
function bp046RandSecond()
  particles.resetRandom(1)
  particles.compatRand()
  client.CL_SetModelSyncTypes([c.ST_SYNC, c.ST_RAND])
  entity = bp046Entity(1)
  client.CL_AssignModelSyncBase(entity, 0)
  bp046Equal(native.floatBits(entity.syncBase), 0x3f104721, "second random syncbase")
  return true
end function
function bp046SameModelPreserves()
  client.CL_SetModelSyncTypes([c.ST_SYNC, c.ST_RAND])
  entity = bp046Entity(1)
  entity.syncBase = 0.25
  client.CL_AssignModelSyncBase(entity, 1)
  bp046Equal(entity.syncBase, 0.25, "same model preserves")
  return true
end function
function bp046NullModelResets()
  entity = bp046Entity(0)
  entity.syncBase = 0.25
  client.CL_AssignModelSyncBase(entity, 1)
  bp046Equal(entity.syncBase, 0.0, "null model resets")
  return true
end function
function bp046CycleFirst()
  bp046Equal(entities.cycleIndex([0.1, 0.2], 0.05, 2), 0, "cycle first")
  return true
end function
function bp046CycleSecond()
  bp046Equal(entities.cycleIndex([0.1, 0.2], 0.15, 2), 1, "cycle second")
  return true
end function
function bp046CycleWrap()
  bp046Equal(entities.cycleIndex([0.1, 0.2], 0.25, 2), 0, "cycle wrap")
  return true
end function
function bp046CycleExactBoundary()
  bp046Equal(entities.cycleIndex([0.1, 0.2], 0.1, 2), 1, "cycle exact boundary")
  return true
end function
function bp046SpriteSyncBaseFirst()
  model = bp046Sprite(c.ST_RAND)
  entity = bp046Entity(1)
  entity.syncBase = 0.0
  selected = entities.spriteFrameAndTexture(model, entity, 0.05)
  bp046Equal(selected[1], 101, "sprite first texture")
  return true
end function
function bp046SpriteSyncBaseSecond()
  model = bp046Sprite(c.ST_RAND)
  entity = bp046Entity(1)
  entity.syncBase = 0.1
  selected = entities.spriteFrameAndTexture(model, entity, 0.05)
  bp046Equal(selected[1], 102, "sprite syncbase texture")
  return true
end function
function bp046SpriteWrap()
  model = bp046Sprite(c.ST_RAND)
  entity = bp046Entity(1)
  entity.syncBase = 0.2
  selected = entities.spriteFrameAndTexture(model, entity, 0.05)
  bp046Equal(selected[1], 101, "sprite wrapped texture")
  return true
end function
function bp046SingleCycle()
  bp046Equal(entities.cycleIndex([], 9.0, 1), 0, "single cycle")
  return true
end function
function bp046EmptyIntervals()
  bp046Equal(entities.cycleIndex([], 9.0, 2), 0, "empty intervals")
  return true
end function
function bp046ZeroInterval()
  bp046Equal(entities.cycleIndex([0.0], 9.0, 2), 0, "zero interval")
  return true
end function
function bp046NegativeTime()
  bp046Equal(entities.cycleIndex([0.1, 0.2], -0.05, 2), 0, "negative time compatibility")
  return true
end function
function bp046SyncTypeConstants()
  bp046Equal(c.ST_SYNC, 0, "ST_SYNC")
  bp046Equal(c.ST_RAND, 1, "ST_RAND")
  return true
end function
function bp046FirstRandWord()
  particles.resetRandom(1)
  bp046Equal(particles.compatRand(), 41, "first MSVCRT rand")
  return true
end function
function bp046SecondRandWord()
  particles.resetRandom(1)
  particles.compatRand()
  bp046Equal(particles.compatRand(), 18467, "second MSVCRT rand")
  return true
end function

passed = 0
if bp046Run(1, "set model sync types", bp046SetTypes) then passed = passed + 1 end if
if bp046Run(2, "read model sync types", bp046ReadTypes) then passed = passed + 1 end if
if bp046Run(3, "unknown model sync type", bp046UnknownType) then passed = passed + 1 end if
if bp046Run(4, "synchronized model base", bp046SyncModel) then passed = passed + 1 end if
if bp046Run(5, "first random syncbase", bp046RandFirst) then passed = passed + 1 end if
if bp046Run(6, "second random syncbase", bp046RandSecond) then passed = passed + 1 end if
if bp046Run(7, "unchanged model preserves syncbase", bp046SameModelPreserves) then passed = passed + 1 end if
if bp046Run(8, "null model resets syncbase", bp046NullModelResets) then passed = passed + 1 end if
if bp046Run(9, "group cycle first", bp046CycleFirst) then passed = passed + 1 end if
if bp046Run(10, "group cycle second", bp046CycleSecond) then passed = passed + 1 end if
if bp046Run(11, "group cycle wrap", bp046CycleWrap) then passed = passed + 1 end if
if bp046Run(12, "group cycle boundary", bp046CycleExactBoundary) then passed = passed + 1 end if
if bp046Run(13, "sprite first frame", bp046SpriteSyncBaseFirst) then passed = passed + 1 end if
if bp046Run(14, "sprite syncbase frame", bp046SpriteSyncBaseSecond) then passed = passed + 1 end if
if bp046Run(15, "sprite syncbase wrap", bp046SpriteWrap) then passed = passed + 1 end if
if bp046Run(16, "single-frame cycle", bp046SingleCycle) then passed = passed + 1 end if
if bp046Run(17, "empty interval cycle", bp046EmptyIntervals) then passed = passed + 1 end if
if bp046Run(18, "zero interval cycle", bp046ZeroInterval) then passed = passed + 1 end if
if bp046Run(19, "negative group time", bp046NegativeTime) then passed = passed + 1 end if
if bp046Run(20, "sync type constants", bp046SyncTypeConstants) then passed = passed + 1 end if
if bp046Run(21, "first random word", bp046FirstRandWord) then passed = passed + 1 end if
if bp046Run(22, "second random word", bp046SecondRandWord) then passed = passed + 1 end if

if passed != 22 then
  print "MiniQuake BP-046 sprite sync tests failed: " + passed + "/22"
  error(4699, "BP-046 sprite sync parity")
end if
print "MiniQuake BP-046 sprite sync tests passed: 22"
