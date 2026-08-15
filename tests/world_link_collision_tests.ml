/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-026: WinQuake entity linking and collision-filter contracts.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.server as server
import miniquake.server_collision as collision
import miniquake.quakec.vm as vm

struct CollisionMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Report the requested value and return the corresponding failure status.
function fail(code, text)
  return error(code, text)
end function
// Assert exact equality and report both values on failure.
function equal(actual, expected, text)
  if actual != expected then return fail(2601, text + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert floating-point equality within the requested tolerance.
function near(actual, expected, text)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > 0.0001 then return fail(2602, text) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function require(value, text)
  if not value then return fail(2603, text) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/16] " + name
  value = try(fn())
  if value is error then print "FAIL: " + value.message; return false end if
  return true
end function

// Create and initialize map.
function makeMap(backContents)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -2, -1, t.Vec3(-1024.0, -1024.0, -1024.0), t.Vec3(1024.0, 1024.0, 1024.0), 0, 0)
  back = t.BspLeaf(backContents, -1, t.Vec3(-1024.0, -1024.0, -1024.0), t.Vec3(0.0, 1024.0, 1024.0), 0, 0, bytes(4))
  front = t.BspLeaf(c.CONTENTS_EMPTY, -1, t.Vec3(0.0, -1024.0, -1024.0), t.Vec3(1024.0, 1024.0, 1024.0), 0, 0, bytes(4))
  model = t.BspModel(t.Vec3(-1024.0, -1024.0, -1024.0), t.Vec3(1024.0, 1024.0, 1024.0), t.Vec3(0.0, 0.0, 0.0), [0,0,0,0], 1, 0, 0)
  return CollisionMap([model], [node], [t.BspClipNode(0, c.CONTENTS_EMPTY, backContents)], [plane], [back, front])
end function

// Exercise definitions as part of this deterministic regression fixture.
function definitions()
  return [
    t.QuakeCDef(c.EV_VOID,0,0,""),
    t.QuakeCDef(c.EV_VECTOR,1,0,"origin"),
    t.QuakeCDef(c.EV_VECTOR,4,0,"mins"),
    t.QuakeCDef(c.EV_VECTOR,7,0,"maxs"),
    t.QuakeCDef(c.EV_VECTOR,10,0,"absmin"),
    t.QuakeCDef(c.EV_VECTOR,13,0,"absmax"),
    t.QuakeCDef(c.EV_FLOAT,16,0,"flags"),
    t.QuakeCDef(c.EV_FLOAT,17,0,"solid"),
    t.QuakeCDef(c.EV_FLOAT,18,0,"movetype"),
    t.QuakeCDef(c.EV_ENTITY,19,0,"owner"),
    t.QuakeCDef(c.EV_FUNCTION,20,0,"touch"),
    t.QuakeCDef(c.EV_STRING,21,0,"model"),
    t.QuakeCDef(c.EV_FLOAT,22,0,"health"),
  ]
end function

// Build deterministic test data for the requested value.
function fixture(count, backContents)
  dummy = t.QuakeCFunction(0,0,0,0,"","",0,[])
  program = t.QuakeCProgram("bp026.dat", bytes(), c.PROG_VERSION, 0, [], [], definitions(), [dummy], bytes(1), vm.zeroArray(32), 24)
  machine = vm.create(program, count)
  game = server.create(1)
  runtime = server.createEdictRuntime(count, count - 1)
  context = server.createQuakeCContext(game, void, void, void, runtime)
  vm.setContext(machine, context)
  machine.edictFree = runtime.freeFlags
  index = 0
  while index < count
    runtime.freeFlags[index] = false
    index = index + 1
  end while
  game.machine = machine
  game.worldModel = makeMap(backContents)
  game.active = true
  return game
end function

// Update module state for box.
function setBox(game, index, origin, mins, maxs, solid)
  collision.setEntityVector(game,index,"origin",origin)
  collision.setEntityVector(game,index,"mins",mins)
  collision.setEntityVector(game,index,"maxs",maxs)
  collision.setEntityFloat(game,index,"solid",solid)
  collision.setEntityFloat(game,index,"movetype",c.MOVETYPE_WALK)
  collision.setEntityFloat(game,index,"flags",0.0)
  collision.setEntityFloat(game,index,"health",100.0)
end function

// Verify normal bounds against the expected Quake behavior.
function testNormalBounds()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(10.0,20.0,30.0),t.Vec3(-1.0,-2.0,-3.0),t.Vec3(4.0,5.0,6.0),c.SOLID_BBOX)
  collision.updateEntityBounds(game,1)
  lo=collision.entityVector(game,1,"absmin",t.Vec3(0.0,0.0,0.0));hi=collision.entityVector(game,1,"absmax",t.Vec3(0.0,0.0,0.0))
  near(lo.x,8.0,"normal absmin x");near(lo.y,17.0,"normal absmin y");near(lo.z,26.0,"normal absmin z")
  near(hi.x,15.0,"normal absmax x");near(hi.y,26.0,"normal absmax y");near(hi.z,37.0,"normal absmax z")
  return true
end function
// Verify item bounds against the expected Quake behavior.
function testItemBounds()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(10.0,20.0,30.0),t.Vec3(-1.0,-2.0,-3.0),t.Vec3(4.0,5.0,6.0),c.SOLID_TRIGGER)
  collision.setEntityFloat(game,1,"flags",c.FL_ITEM);collision.updateEntityBounds(game,1)
  lo=collision.entityVector(game,1,"absmin",t.Vec3(0.0,0.0,0.0));hi=collision.entityVector(game,1,"absmax",t.Vec3(0.0,0.0,0.0))
  near(lo.x,-6.0,"item absmin x");near(lo.y,3.0,"item absmin y");near(lo.z,27.0,"item z unexpanded")
  near(hi.x,29.0,"item absmax x");near(hi.y,40.0,"item absmax y");near(hi.z,36.0,"item max z unexpanded")
  return true
end function
// Verify invalid link against the expected Quake behavior.
function testInvalidLink()
  game=fixture(2,c.CONTENTS_EMPTY);game.machine.context.edicts.freeFlags[1]=true
  equal(collision.updateEntityBounds(game,1),false,"free entity link")
  return true
end function
// Verify inclusive overlap against the expected Quake behavior.
function testInclusiveOverlap()
  require(collision.boxesOverlap(t.Vec3(0.0,0.0,0.0),t.Vec3(1.0,1.0,1.0),t.Vec3(1.0,1.0,1.0),t.Vec3(2.0,2.0,2.0)),"touching boxes overlap")
  return true
end function
// Verify separated boxes against the expected Quake behavior.
function testSeparatedBoxes()
  equal(collision.boxesOverlap(t.Vec3(0.0,0.0,0.0),t.Vec3(1.0,1.0,1.0),t.Vec3(1.01,0.0,0.0),t.Vec3(2.0,1.0,1.0)),false,"separated boxes")
  return true
end function
// Verify forward move bounds against the expected Quake behavior.
function testForwardMoveBounds()
  bounds=collision.moveBounds(t.Vec3(0.0,0.0,0.0),t.Vec3(-1.0,-2.0,-3.0),t.Vec3(1.0,2.0,3.0),t.Vec3(10.0,20.0,30.0))
  near(bounds[0].x,-2.0,"forward min x");near(bounds[1].x,12.0,"forward max x");near(bounds[1].z,34.0,"forward max z")
  return true
end function
// Verify reverse move bounds against the expected Quake behavior.
function testReverseMoveBounds()
  bounds=collision.moveBounds(t.Vec3(10.0,20.0,30.0),t.Vec3(-1.0,-2.0,-3.0),t.Vec3(1.0,2.0,3.0),t.Vec3(0.0,0.0,0.0))
  near(bounds[0].x,-2.0,"reverse min x");near(bounds[1].x,12.0,"reverse max x");near(bounds[0].z,-4.0,"reverse min z")
  return true
end function
// Verify clear trace entity against the expected Quake behavior.
function testClearTraceEntity()
  game=fixture(2,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(50.0,50.0,50.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_NOT)
  trace=collision.move(game,t.Vec3(10.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(20.0,0.0,0.0),c.MOVE_NORMAL,-1)
  equal(trace.entity,-1,"clear trace has no entity")
  return true
end function
// Verify world trace entity against the expected Quake behavior.
function testWorldTraceEntity()
  game=fixture(2,c.CONTENTS_SOLID);trace=collision.move(game,t.Vec3(10.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(-10.0,0.0,0.0),c.MOVE_NORMAL,-1)
  equal(trace.entity,0,"world collision entity");require(trace.fraction<1.0,"world collision fraction")
  return true
end function
// Verify entity position world against the expected Quake behavior.
function testEntityPositionWorld()
  game=fixture(2,c.CONTENTS_SOLID);setBox(game,1,t.Vec3(-10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  equal(collision.testEntityPosition(game,1),0,"stuck position returns world")
  return true
end function
// Verify no monsters filter against the expected Quake behavior.
function testNoMonstersFilter()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(5.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  trace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NOMONSTERS,2)
  near(trace.fraction,1.0,"nomonsters ignores bbox")
  return true
end function
// Verify normal entity collision against the expected Quake behavior.
function testNormalEntityCollision()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(5.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  trace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NORMAL,2)
  equal(trace.entity,1,"normal collision entity");require(trace.fraction<1.0,"normal collision fraction")
  return true
end function
// Verify owner filter against the expected Quake behavior.
function testOwnerFilter()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(5.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX);setBox(game,2,t.Vec3(0.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  collision.setEntityWord(game,1,"owner",2)
  trace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NORMAL,2)
  near(trace.fraction,1.0,"owner excluded")
  return true
end function
// Verify point filter against the expected Quake behavior.
function testPointFilter()
  game=fixture(3,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(5.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),c.SOLID_BBOX);setBox(game,2,t.Vec3(0.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  trace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NORMAL,2)
  near(trace.fraction,1.0,"point helper excluded")
  return true
end function
// Verify push relinks bounds against the expected Quake behavior.
function testPushRelinksBounds()
  game=fixture(2,c.CONTENTS_EMPTY);setBox(game,1,t.Vec3(10.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_BBOX)
  collision.pushEntity(game,1,t.Vec3(2.0,0.0,0.0));lo=collision.entityVector(game,1,"absmin",t.Vec3(0.0,0.0,0.0));near(lo.x,10.0,"push relink absmin")
  return true
end function

// A killed monster must not trap a player in a narrow doorway while its
// QuakeC death animation is waiting to assign SOLID_NOT.
function testDeadMonsterDoesNotBlockPlayer()
  game=fixture(3,c.CONTENTS_EMPTY)
  setBox(game,2,t.Vec3(5.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_SLIDEBOX)
  collision.setEntityFloat(game,2,"flags",c.FL_MONSTER)
  collision.setEntityFloat(game,2,"health",-10.0)
  collision.linkEntity(game,2,false)
  setBox(game,1,t.Vec3(0.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),c.SOLID_SLIDEBOX)
  trace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(-1.0,-1.0,-1.0),t.Vec3(1.0,1.0,1.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NORMAL,1)
  near(trace.fraction,1.0,"dead monster ignored for player movement")
  collision.setEntityFloat(game,1,"solid",c.SOLID_NOT)
  collision.linkEntity(game,1,false)
  projectileTrace=collision.move(game,t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(0.0,0.0,0.0),t.Vec3(10.0,0.0,0.0),c.MOVE_NORMAL,-1)
  equal(projectileTrace.entity,2,"non-player trace still sees dying monster")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed=0
  if run(1,"normal expanded bounds",testNormalBounds) then passed=passed+1 end if
  if run(2,"item expanded bounds",testItemBounds) then passed=passed+1 end if
  if run(3,"free entity cannot link",testInvalidLink) then passed=passed+1 end if
  if run(4,"inclusive overlap",testInclusiveOverlap) then passed=passed+1 end if
  if run(5,"separated boxes",testSeparatedBoxes) then passed=passed+1 end if
  if run(6,"forward move bounds",testForwardMoveBounds) then passed=passed+1 end if
  if run(7,"reverse move bounds",testReverseMoveBounds) then passed=passed+1 end if
  if run(8,"clear trace entity",testClearTraceEntity) then passed=passed+1 end if
  if run(9,"world trace entity",testWorldTraceEntity) then passed=passed+1 end if
  if run(10,"stuck entity returns world",testEntityPositionWorld) then passed=passed+1 end if
  if run(11,"MOVE_NOMONSTERS filtering",testNoMonstersFilter) then passed=passed+1 end if
  if run(12,"normal entity collision",testNormalEntityCollision) then passed=passed+1 end if
  if run(13,"owner filtering",testOwnerFilter) then passed=passed+1 end if
  if run(14,"point entity filtering",testPointFilter) then passed=passed+1 end if
  if run(15,"SV_PushEntity relinks bounds",testPushRelinksBounds) then passed=passed+1 end if
  if run(16,"dead monster does not block player",testDeadMonsterDoesNotBlockPlayer) then passed=passed+1 end if
  if passed!=16 then return 1 end if
  print "MiniQuake BP-026 world link/collision tests passed: 16"
  return 0
end function
