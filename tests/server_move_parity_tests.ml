/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

BP-027: source-guided sv_move.c movement, chase and relink fixtures.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.server as server
import miniquake.server_move as movePort
import miniquake.server_collision as collision
import miniquake.quakec.vm as vm

// Group the deterministic move parity map fields used by this test fixture.
struct MoveParityMap
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
  if actual != expected then return fail(9271, text + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert floating-point equality within the requested tolerance.
function near(actual, expected, text)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > 0.0001 then return fail(9272, text + ": expected " + expected + ", got " + actual) end if
  return true
end function
// Assert that the condition holds and identify a failing test.
function require(value, text)
  if not value then return fail(9273, text) end if
  return true
end function
// Execute one named test case and record its pass/fail result.
function run(number, name, fn)
  print "[" + number + "/14] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

// Create and initialize map.
function makeMap(backContents, frontContents)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -2, -1, t.Vec3(-512.0, -512.0, -512.0), t.Vec3(512.0, 512.0, 512.0), 0, 0)
  back = t.BspLeaf(backContents, -1, t.Vec3(-512.0, -512.0, -512.0), t.Vec3(512.0, 512.0, 0.0), 0, 0, bytes(4))
  front = t.BspLeaf(frontContents, -1, t.Vec3(-512.0, -512.0, 0.0), t.Vec3(512.0, 512.0, 512.0), 0, 0, bytes(4))
  model = t.BspModel(t.Vec3(-512.0, -512.0, -512.0), t.Vec3(512.0, 512.0, 512.0), t.Vec3(0.0, 0.0, 0.0), [0,0,0,0], 1, 0, 0)
  return MoveParityMap([model], [node], [t.BspClipNode(0, frontContents, backContents)], [plane], [back, front])
end function

// Exercise fields as part of this deterministic regression fixture.
function fields()
  return [
    t.QuakeCDef(c.EV_VOID,0,0,""),
    t.QuakeCDef(c.EV_VECTOR,1,0,"origin"),
    t.QuakeCDef(c.EV_VECTOR,4,0,"angles"),
    t.QuakeCDef(c.EV_VECTOR,7,0,"mins"),
    t.QuakeCDef(c.EV_VECTOR,10,0,"maxs"),
    t.QuakeCDef(c.EV_VECTOR,13,0,"absmin"),
    t.QuakeCDef(c.EV_VECTOR,16,0,"absmax"),
    t.QuakeCDef(c.EV_FLOAT,19,0,"movetype"),
    t.QuakeCDef(c.EV_FLOAT,20,0,"solid"),
    t.QuakeCDef(c.EV_FLOAT,21,0,"flags"),
    t.QuakeCDef(c.EV_ENTITY,22,0,"groundentity"),
    t.QuakeCDef(c.EV_ENTITY,23,0,"enemy"),
    t.QuakeCDef(c.EV_ENTITY,24,0,"goalentity"),
    t.QuakeCDef(c.EV_FLOAT,25,0,"ideal_yaw"),
    t.QuakeCDef(c.EV_FLOAT,26,0,"yaw_speed"),
    t.QuakeCDef(c.EV_STRING,27,0,"model"),
    t.QuakeCDef(c.EV_FUNCTION,28,0,"touch"),
  ]
end function

// Build deterministic test data for the requested value.
function fixture(map)
  dummy=t.QuakeCFunction(0,0,0,0,"","",0,[])
  program=t.QuakeCProgram("bp027.dat",bytes(),c.PROG_VERSION,0,[],[],fields(),[dummy],bytes(1),vm.zeroArray(64),32)
  machine=vm.create(program,5)
  game=server.create(1)
  runtime=server.createEdictRuntime(5,4)
  context=server.createQuakeCContext(game,void,void,void,runtime)
  vm.setContext(machine,context);machine.edictFree=runtime.freeFlags
  index=0
  while index<5
    runtime.freeFlags[index]=false
    index=index+1
  end while
  game.machine=machine;game.worldModel=map;game.active=true;context.randomSeed=0
  return game
end function

// Update module state for entity.
function setEntity(game,index,origin,flags)
  collision.setEntityVector(game,index,"origin",origin)
  collision.setEntityVector(game,index,"angles",t.Vec3(0.0,0.0,0.0))
  collision.setEntityVector(game,index,"mins",t.Vec3(-1.0,-1.0,-2.0))
  collision.setEntityVector(game,index,"maxs",t.Vec3(1.0,1.0,2.0))
  collision.setEntityFloat(game,index,"movetype",c.MOVETYPE_STEP)
  collision.setEntityFloat(game,index,"solid",c.SOLID_SLIDEBOX)
  collision.setEntityFloat(game,index,"flags",flags)
  collision.setEntityWord(game,index,"groundentity",0)
  collision.setEntityWord(game,index,"enemy",0)
  collision.setEntityWord(game,index,"goalentity",0)
  collision.setEntityFloat(game,index,"ideal_yaw",0.0)
  collision.setEntityFloat(game,index,"yaw_speed",360.0)
  collision.linkEntity(game,index,false)
end function

// Verify bottom floor against the expected Quake behavior.
function testBottomFloor()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND)
  require(movePort.SV_CheckBottom(game,1),"floor bottom")
  return true
end function
// Verify bottom gap against the expected Quake behavior.
function testBottomGap()
  game=fixture(makeMap(c.CONTENTS_EMPTY,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND)
  equal(movePort.SV_CheckBottom(game,1),false,"gap bottom")
  return true
end function
// Verify floor move and relink against the expected Quake behavior.
function testFloorMoveAndRelink()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND)
  require(movePort.SV_movestep(game,1,t.Vec3(12.0,0.0,0.0),true),"floor move")
  origin=collision.entityVector(game,1,"origin",t.Vec3(0.0,0.0,0.0));absMin=collision.entityVector(game,1,"absmin",t.Vec3(0.0,0.0,0.0))
  near(origin.x,12.0,"floor origin x");near(absMin.x,10.0,"floor linked absmin x")
  equal(collision.entityWord(game,1,"groundentity",-1),0,"floor ground world")
  return true
end function
// Verify partial ground fall against the expected Quake behavior.
function testPartialGroundFall()
  game=fixture(makeMap(c.CONTENTS_EMPTY,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND|c.FL_PARTIALGROUND)
  require(movePort.SV_movestep(game,1,t.Vec3(5.0,0.0,0.0),true),"partial move")
  origin=collision.entityVector(game,1,"origin",t.Vec3(0.0,0.0,0.0));flags=native.trunc(collision.entityFloat(game,1,"flags",0.0))
  near(origin.x,5.0,"partial origin");equal(flags & c.FL_ONGROUND,0,"partial clears onground")
  return true
end function
// Verify fly height adjustment against the expected Quake behavior.
function testFlyHeightAdjustment()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,100.0),c.FL_FLY);setEntity(game,2,t.Vec3(30.0,0.0,0.0),c.FL_ONGROUND)
  collision.setEntityWord(game,1,"enemy",2)
  require(movePort.SV_movestep(game,1,t.Vec3(5.0,0.0,0.0),false),"fly move")
  origin=collision.entityVector(game,1,"origin",t.Vec3(0.0,0.0,0.0));near(origin.x,5.0,"fly x");near(origin.z,92.0,"fly pursuit z")
  return true
end function
// Verify swim exit rejected against the expected Quake behavior.
function testSwimExitRejected()
  game=fixture(makeMap(c.CONTENTS_WATER,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,-10.0),c.FL_SWIM)
  equal(movePort.SV_movestep(game,1,t.Vec3(0.0,0.0,20.0),false),false,"swim exit")
  return true
end function
// Verify yaw gate relinks restored origin against the expected Quake behavior.
function testYawGateRelinksRestoredOrigin()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND)
  collision.setEntityVector(game,1,"angles",t.Vec3(0.0,180.0,0.0));collision.setEntityFloat(game,1,"yaw_speed",20.0)
  require(movePort.SV_StepDirection(game,1,90.0,10.0),"yaw-gated step returns true")
  origin=collision.entityVector(game,1,"origin",t.Vec3(0.0,0.0,0.0));absMin=collision.entityVector(game,1,"absmin",t.Vec3(0.0,0.0,0.0))
  near(origin.x,0.0,"yaw gate restored x");near(origin.y,0.0,"yaw gate restored y");near(absMin.x,-2.0,"yaw gate relinked absmin")
  return true
end function
// Verify fix bottom against the expected Quake behavior.
function testFixBottom()
  game=fixture(makeMap(c.CONTENTS_EMPTY,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),0)
  movePort.SV_FixCheckBottom(game,1);flags=native.trunc(collision.entityFloat(game,1,"flags",0.0));require((flags & c.FL_PARTIALGROUND)!=0,"partial flag")
  return true
end function
// Verify diagonal chase against the expected Quake behavior.
function testDiagonalChase()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND);setEntity(game,2,t.Vec3(40.0,40.0,2.0),c.FL_ONGROUND)
  game.machine.context.randomSeed=0;require(movePort.SV_NewChaseDir(game,1,2,10.0),"diagonal chase")
  near(collision.entityFloat(game,1,"ideal_yaw",-1.0),45.0,"diagonal ideal")
  return true
end function
// Verify historical southwest diagonal against the expected Quake behavior.
function testHistoricalSouthwestDiagonal()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND);setEntity(game,2,t.Vec3(-40.0,-40.0,2.0),c.FL_ONGROUND)
  game.machine.context.randomSeed=0;movePort.SV_NewChaseDir(game,1,2,10.0)
  near(collision.entityFloat(game,1,"ideal_yaw",-1.0),215.0,"WinQuake 215 diagonal")
  return true
end function
// Verify close enough against the expected Quake behavior.
function testCloseEnough()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND);setEntity(game,2,t.Vec3(5.0,0.0,2.0),c.FL_ONGROUND)
  require(movePort.SV_CloseEnough(game,1,2,2.0),"near goal")
  return true
end function
// Verify not close enough against the expected Quake behavior.
function testNotCloseEnough()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),c.FL_ONGROUND);setEntity(game,2,t.Vec3(50.0,0.0,2.0),c.FL_ONGROUND)
  equal(movePort.SV_CloseEnough(game,1,2,2.0),false,"distant goal")
  return true
end function
// Verify move to goal airborne gate against the expected Quake behavior.
function testMoveToGoalAirborneGate()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));setEntity(game,1,t.Vec3(0.0,0.0,2.0),0);setEntity(game,2,t.Vec3(50.0,0.0,2.0),c.FL_ONGROUND);collision.setEntityWord(game,1,"goalentity",2)
  equal(movePort.SV_MoveToGoal(game,1,8.0),false,"airborne gate")
  return true
end function
// Verify random sequence against the expected Quake behavior.
function testRandomSequence()
  game=fixture(makeMap(c.CONTENTS_SOLID,c.CONTENTS_EMPTY));game.machine.context.randomSeed=0
  equal(movePort.randomWord(game),38,"first MS rand word");equal(movePort.randomWord(game),7719,"second MS rand word")
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  passed=0
  if run(1,"bottom floor",testBottomFloor) then passed=passed+1 else return 1 end if
  if run(2,"bottom gap",testBottomGap) then passed=passed+1 else return 1 end if
  if run(3,"floor move/relink",testFloorMoveAndRelink) then passed=passed+1 else return 1 end if
  if run(4,"partial ground",testPartialGroundFall) then passed=passed+1 else return 1 end if
  if run(5,"fly adjustment",testFlyHeightAdjustment) then passed=passed+1 else return 1 end if
  if run(6,"swim exit",testSwimExitRejected) then passed=passed+1 else return 1 end if
  if run(7,"yaw gate/relink",testYawGateRelinksRestoredOrigin) then passed=passed+1 else return 1 end if
  if run(8,"fix bottom",testFixBottom) then passed=passed+1 else return 1 end if
  if run(9,"diagonal chase",testDiagonalChase) then passed=passed+1 else return 1 end if
  if run(10,"historical 215 diagonal",testHistoricalSouthwestDiagonal) then passed=passed+1 else return 1 end if
  if run(11,"close enough",testCloseEnough) then passed=passed+1 else return 1 end if
  if run(12,"not close enough",testNotCloseEnough) then passed=passed+1 else return 1 end if
  if run(13,"move-to-goal gate",testMoveToGoalAirborneGate) then passed=passed+1 else return 1 end if
  if run(14,"random sequence",testRandomSequence) then passed=passed+1 else return 1 end if
  print "MiniQuake BP-027 server movement tests passed: " + passed
  return 0
end function
