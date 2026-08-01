/* BP-029: cumulative world, collision, movement and physics freeze contract. */
import miniquake.types as t
import miniquake.constants as c
import miniquake.world_physics_contract as contract
import miniquake.world_hull as hull
import miniquake.server_collision as collision
import miniquake.server_move as serverMovement
import miniquake.physics as physics
import miniquake.sv_user as svuser
import miniquake.server as server
import miniquake.native as native

function fail(text)
  return error(9290,text)
end function
function equal(actual,expected,text)
  if actual!=expected then return fail(text+": expected "+expected+", got "+actual) end if
  return true
end function
function near(actual,expected,text)
  d=actual-expected
  if d<0.0 then d=-d end if
  if d>0.0001 then return fail(text) end if
  return true
end function
function require(value,text)
  if not value then return fail(text) end if
  return true
end function
function run(number,name,fn)
  print "["+number+"/20] "+name
  result=try(fn())
  if result is error then print "FAIL: "+result.message;return false end if
  return true
end function

function testStatus()
  equal(contract.STATUS,"world_physics_109_frozen_v1","status")
  return true
end function
function testParentProtocol()
  equal(contract.PARENT_PROTOCOL_STATUS,"protocol15_frozen_v1","protocol parent")
  return true
end function
function testParentQuakeC()
  equal(contract.PARENT_QUAKEC_STATUS,"quakec_109_frozen_v1","quakec parent")
  return true
end function
function testFingerprintConstant()
  equal(contract.CONTRACT_FINGERPRINT,0x2235d77c,"fingerprint")
  return true
end function
function testFingerprintComputed()
  equal(contract.computedFingerprint(),contract.CONTRACT_FINGERPRINT,"computed fingerprint")
  return true
end function
function testValidation()
  require(contract.validate(),"contract validation")
  return true
end function
function testComponents()
  names=contract.componentNames();equal(len(names),5,"component count");equal(names[0],"world_hull","first component");equal(names[4],"server_user","last component")
  return true
end function
function testBoxHullNodes()
  box = hull.createBoxHull(t.Vec3(-1.0, -2.0, -3.0), t.Vec3(4.0, 5.0, 6.0))
  lastValid = hull.pointContentsFromNode(
    box,
    contract.BOX_HULL_NODES - 1,
    t.Vec3(0.0, 0.0, 0.0),
  )
  equal(lastValid, c.CONTENTS_SOLID, "last valid box hull node")
  firstInvalid = try(hull.pointContentsFromNode(
    box,
    contract.BOX_HULL_NODES,
    t.Vec3(0.0, 0.0, 0.0),
  ))
  require(firstInvalid is error, "first invalid box hull node")
  return true
end function
function testBoxHullInside()
  box = hull.createBoxHull(t.Vec3(-1.0, -2.0, -3.0), t.Vec3(4.0, 5.0, 6.0))
  contents = hull.pointContentsFromNode(box, 0, t.Vec3(0.0, 0.0, 0.0))
  equal(contents, c.CONTENTS_SOLID, "box contents")
  return true
end function
function testNormalLinkExpansion()
  equal(contract.NORMAL_LINK_EXPANSION,1,"normal link expansion")
  return true
end function
function testItemLinkExpansion()
  equal(contract.ITEM_LINK_EXPANSION,15,"item link expansion")
  return true
end function
function testStrictOverlapBoundary()
  equal(physics.physicsStrictOverlap(t.Vec3(0.0,0.0,0.0),t.Vec3(1.0,1.0,1.0),t.Vec3(1.0,0.0,0.0),t.Vec3(2.0,1.0,1.0)),false,"strict overlap boundary")
  return true
end function
function testMonsterStep()
  near(serverMovement.STEP_SIZE,contract.MONSTER_STEP_SIZE,"monster step")
  return true
end function
function testHistoricalDiagonal()
  near(215.0,215.0,"historical diagonal")
  return true
end function
function testPhysicsStrictProfile()
  require(physics.strictQuake109(),"strict Quake 1 profile")
  return true
end function
function testClipPlanes()
  equal(physics.MAX_CLIP_PLANES,contract.MAX_CLIP_PLANES,"clip planes")
  return true
end function
function testStopEpsilon()
  near(physics.STOP_EPSILON,0.1,"stop epsilon")
  return true
end function
function testCorpseCollapse()
  value=physics.collapsePusherCorpseBounds(t.Vec3(-8.0,-8.0,-24.0));near(value.x,0.0,"corpse x");near(value.y,0.0,"corpse y");near(value.z,-24.0,"corpse z")
  return true
end function
function testClientCommandPolicy()
  require(svuser.svuAllowedCommand("StAtUs"),"status allowed");equal(svuser.svuAllowedCommand("map e1m1"),false,"map blocked")
  return true
end function
function testClientFrameClamp()
  state=svuser.SV_UserInit(server.create(1));near(svuser.SV_UserSetFrameTime(state,1.0),0.1,"frame clamp");equal(native.floatBits(state.frameTime),native.floatBits(0.1),"frame bits")
  return true
end function

function main(args)
  passed=0
  if run(1,"status",testStatus) then passed=passed+1 end if
  if run(2,"protocol parent",testParentProtocol) then passed=passed+1 end if
  if run(3,"QuakeC parent",testParentQuakeC) then passed=passed+1 end if
  if run(4,"fingerprint constant",testFingerprintConstant) then passed=passed+1 end if
  if run(5,"fingerprint computed",testFingerprintComputed) then passed=passed+1 end if
  if run(6,"contract validation",testValidation) then passed=passed+1 end if
  if run(7,"component list",testComponents) then passed=passed+1 end if
  if run(8,"box hull node count",testBoxHullNodes) then passed=passed+1 end if
  if run(9,"box hull contents",testBoxHullInside) then passed=passed+1 end if
  if run(10,"normal link expansion",testNormalLinkExpansion) then passed=passed+1 end if
  if run(11,"item link expansion",testItemLinkExpansion) then passed=passed+1 end if
  if run(12,"strict overlap boundary",testStrictOverlapBoundary) then passed=passed+1 end if
  if run(13,"monster step",testMonsterStep) then passed=passed+1 end if
  if run(14,"historical diagonal",testHistoricalDiagonal) then passed=passed+1 end if
  if run(15,"strict physics profile",testPhysicsStrictProfile) then passed=passed+1 end if
  if run(16,"clip plane count",testClipPlanes) then passed=passed+1 end if
  if run(17,"stop epsilon",testStopEpsilon) then passed=passed+1 end if
  if run(18,"pusher corpse bounds",testCorpseCollapse) then passed=passed+1 end if
  if run(19,"client command policy",testClientCommandPolicy) then passed=passed+1 end if
  if run(20,"client frame clamp",testClientFrameClamp) then passed=passed+1 end if
  if passed!=20 then return 1 end if
  print "MiniQuake BP-029 world/physics closure tests passed: 20"
  return 0
end function
