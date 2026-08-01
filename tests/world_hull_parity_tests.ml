/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

BP-025: exact WinQuake box-hull traversal and trace boundaries.
*/

import miniquake.types as t
import miniquake.constants as c
import miniquake.world_hull as hull

function require(value, text)
  if not value then return error(2500, text) end if
  return true
end function

function equal(actual, expected, text)
  if actual != expected then return error(2501, text + ": expected " + expected + ", got " + actual) end if
  return true
end function

function near(actual, expected, tolerance, text)
  delta = actual - expected
  if delta < 0.0 then delta = -delta end if
  if delta > tolerance then return error(2502, text) end if
  return true
end function

function run(number, name, fn)
  print "[" + number + "/14] " + name
  result = try(fn())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function testInside()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(0.0, 0.0, 0.0)), c.CONTENTS_SOLID, "inside")
  return true
end function

function testMaxXBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(2.0, 0.0, 0.0)), c.CONTENTS_EMPTY, "max x is empty")
  return true
end function

function testMinXBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(-2.0, 0.0, 0.0)), c.CONTENTS_SOLID, "min x is solid")
  return true
end function

function testMaxYBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(0.0, 3.0, 0.0)), c.CONTENTS_EMPTY, "max y is empty")
  return true
end function

function testMinYBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(0.0, -3.0, 0.0)), c.CONTENTS_SOLID, "min y is solid")
  return true
end function

function testMaxZBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(0.0, 0.0, 4.0)), c.CONTENTS_EMPTY, "max z is empty")
  return true
end function

function testMinZBoundary()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, 0, t.Vec3(0.0, 0.0, -4.0)), c.CONTENTS_SOLID, "min z is solid")
  return true
end function

function testStartNodeHonored()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  // Starting at clipnode 1 deliberately bypasses the x maximum plane.
  equal(hull.pointContentsFromNode(box, 1, t.Vec3(100.0, 0.0, 0.0)), c.CONTENTS_SOLID, "start clipnode")
  return true
end function

function testNegativeLeaf()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  equal(hull.pointContentsFromNode(box, c.CONTENTS_WATER, t.Vec3(0.0, 0.0, 0.0)), c.CONTENTS_WATER, "negative leaf passthrough")
  return true
end function

function testBadNode()
  box = hull.createBoxHull(t.Vec3(-2.0, -3.0, -4.0), t.Vec3(2.0, 3.0, 4.0))
  value = try(hull.pointContentsFromNode(box, 6, t.Vec3(0.0, 0.0, 0.0)))
  require(value is error, "bad node must fail")
  return true
end function

function testClearTrace()
  box = hull.createBoxHull(t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0))
  trace = hull.traceLine(box, t.Vec3(4.0, 4.0, 0.0), t.Vec3(4.0, -4.0, 0.0))
  near(trace.fraction, 1.0, 0.000001, "clear trace fraction")
  require(not trace.startSolid and not trace.allSolid, "clear trace flags")
  return true
end function

function testCrossTrace()
  box = hull.createBoxHull(t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0))
  trace = hull.traceLine(box, t.Vec3(4.0, 0.0, 0.0), t.Vec3(-4.0, 0.0, 0.0))
  near(trace.fraction, 0.24609375, 0.000001, "cross fraction")
  near(trace.endPosition.x, 2.03125, 0.000001, "cross endpoint")
  near(trace.plane.normal.x, 1.0, 0.000001, "cross normal")
  near(trace.plane.dist, 2.0, 0.000001, "cross plane")
  return true
end function

function testStartSolidExit()
  box = hull.createBoxHull(t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0))
  trace = hull.traceLine(box, t.Vec3(0.0, 0.0, 0.0), t.Vec3(4.0, 0.0, 0.0))
  require(trace.startSolid and not trace.allSolid, "startsolid exit flags")
  near(trace.fraction, 1.0, 0.000001, "startsolid exit fraction")
  return true
end function

function testAllSolid()
  box = hull.createBoxHull(t.Vec3(-2.0, -2.0, -2.0), t.Vec3(2.0, 2.0, 2.0))
  trace = hull.traceLine(box, t.Vec3(0.0, 0.0, 0.0), t.Vec3(1.0, 0.0, 0.0))
  require(trace.startSolid and trace.allSolid, "allsolid flags")
  return true
end function

function main(args)
  passed = 0
  if run(1, "inside box hull", testInside) then passed = passed + 1 end if
  if run(2, "maximum x boundary", testMaxXBoundary) then passed = passed + 1 end if
  if run(3, "minimum x boundary", testMinXBoundary) then passed = passed + 1 end if
  if run(4, "maximum y boundary", testMaxYBoundary) then passed = passed + 1 end if
  if run(5, "minimum y boundary", testMinYBoundary) then passed = passed + 1 end if
  if run(6, "maximum z boundary", testMaxZBoundary) then passed = passed + 1 end if
  if run(7, "minimum z boundary", testMinZBoundary) then passed = passed + 1 end if
  if run(8, "starting clipnode is honored", testStartNodeHonored) then passed = passed + 1 end if
  if run(9, "negative content passthrough", testNegativeLeaf) then passed = passed + 1 end if
  if run(10, "bad clipnode diagnostic", testBadNode) then passed = passed + 1 end if
  if run(11, "clear trace", testClearTrace) then passed = passed + 1 end if
  if run(12, "crossing trace", testCrossTrace) then passed = passed + 1 end if
  if run(13, "startsolid escape", testStartSolidExit) then passed = passed + 1 end if
  if run(14, "allsolid trace", testAllSolid) then passed = passed + 1 end if
  if passed != 14 then return 1 end if
  print "MiniQuake BP-025 world hull tests passed: 14"
  return 0
end function
