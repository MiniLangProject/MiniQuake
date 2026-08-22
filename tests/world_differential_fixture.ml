/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang side of the pinned WinQuake/world.c differential oracle.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.world as worldPort
import miniquake.server as server
import miniquake.edict as edict

// Group the deterministic world differential map fields used by this test fixture.
struct WorldDifferentialMap
  models
  nodes
  clipNodes
  planes
  leafs
end struct

// Exercise differential map as part of this deterministic regression fixture.
function differentialMap(negativeContents)
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(
    0,
    -2,
    -1,
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    0,
    0,
  )
  negativeLeaf = t.BspLeaf(
    negativeContents,
    -1,
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(0.0, 100.0, 100.0),
    0,
    0,
    bytes(4),
  )
  positiveLeaf = t.BspLeaf(
    c.CONTENTS_EMPTY,
    -1,
    t.Vec3(0.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    0,
    0,
    bytes(4),
  )
  model = t.BspModel(
    t.Vec3(-100.0, -100.0, -100.0),
    t.Vec3(100.0, 100.0, 100.0),
    t.Vec3(0.0, 0.0, 0.0),
    [0, 0, 0, 0],
    1,
    0,
    0,
  )
  return WorldDifferentialMap(
    [model],
    [node],
    [t.BspClipNode(0, c.CONTENTS_EMPTY, negativeContents)],
    [plane],
    [negativeLeaf, positiveLeaf],
  )
end function

// Exercise differential entity as part of this deterministic regression fixture.
function differentialEntity(number, origin, mins, maxs, solid)
  item = edict.create(number)
  item.origin = origin
  item.mins = mins
  item.maxs = maxs
  item.solid = solid
  return item
end function

// Exercise differential fixture as part of this deterministic regression fixture.
function differentialFixture(negativeContents)
  map = differentialMap(negativeContents)
  game = server.create(1)
  game.worldModel = map
  game.time = 3.5
  worldEntity = differentialEntity(
    0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    c.SOLID_BSP,
  )
  worldEntity.moveType = c.MOVETYPE_PUSH
  worldEntity.model = "*0"
  worldEntity.modelIndex = 0
  mover = differentialEntity(
    1,
    t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(-1.0, -1.0, -1.0),
    t.Vec3(1.0, 1.0, 1.0),
    c.SOLID_BBOX,
  )
  trigger = differentialEntity(
    2,
    t.Vec3(15.0, 0.0, 0.0),
    t.Vec3(-5.0, -5.0, -5.0),
    t.Vec3(5.0, 5.0, 5.0),
    c.SOLID_TRIGGER,
  )
  blocker = differentialEntity(
    3,
    t.Vec3(30.0, 0.0, 0.0),
    t.Vec3(-2.0, -2.0, -2.0),
    t.Vec3(2.0, 2.0, 2.0),
    c.SOLID_BBOX,
  )
  game.edicts = [worldEntity, mover, trigger, blocker]
  return [game, map, worldPort.SV_ClearWorld(game, map)]
end function

// Return result number derived from the active module state.
function resultNumber(value)
  if value then return 1 end if
  return 0
end function

// Exercise number text as part of this deterministic regression fixture.
function numberText(value)
  return native.floatText(value)
end function

// Add world to the destination state.
function emitWorld(functionName, caseName, result, a, b, cValue, d, e, f, count)
  print "{\"function\":\"" + functionName + "\",\"case\":\"" + caseName +
    "\",\"result\":" + result + ",\"a\":" + numberText(a) +
    ",\"b\":" + numberText(b) + ",\"c\":" + numberText(cValue) +
    ",\"d\":" + numberText(d) + ",\"e\":" + numberText(e) +
    ",\"f\":" + numberText(f) + ",\"count\":" + count + "}"
end function

// Add trace to the destination state.
function emitTrace(functionName, caseName, result, trace)
  emitWorld(
    functionName,
    caseName,
    result,
    trace.endPosition.x,
    trace.endPosition.y,
    trace.endPosition.z,
    trace.fraction,
    trace.plane.normal.x,
    trace.plane.dist,
    0,
  )
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
  fixture = differentialFixture(c.CONTENTS_EMPTY)
  state = fixture[2]
  hull = worldPort.SV_InitBoxHull()
  result = worldPort.SV_HullPointContents(hull, 0, t.Vec3(0.0, 0.0, 0.0))
  emitWorld("SV_InitBoxHull", "zero_box", result, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)

  hull = worldPort.SV_HullForBox(
    t.Vec3(-2.0, -3.0, -4.0),
    t.Vec3(2.0, 3.0, 4.0),
  )
  result = worldPort.SV_HullPointContents(hull, 0, t.Vec3(3.0, 0.0, 0.0))
  emitWorld("SV_HullForBox", "outside", result, -2.0, -3.0, -4.0, 2.0, 3.0, 4.0, 0)

  selected = worldPort.SV_HullForEntity(
    state,
    3,
    t.Vec3(-1.0, -1.0, -1.0),
    t.Vec3(1.0, 1.0, 1.0),
  )
  result = worldPort.SV_HullPointContents(selected[0], 0, t.Vec3(0.0, 0.0, 0.0))
  emitWorld(
    "SV_HullForEntity",
    "bbox",
    result,
    selected[1].x,
    selected[1].y,
    selected[1].z,
    0.0,
    0.0,
    0.0,
    0,
  )

  emitWorld(
    "SV_CreateAreaNode",
    "clear_tree",
    1,
    -100.0,
    -100.0,
    -100.0,
    100.0,
    100.0,
    100.0,
    len(state.nodes),
  )
  emitWorld(
    "SV_ClearWorld",
    "world_bounds",
    1,
    -100.0,
    -100.0,
    -100.0,
    100.0,
    100.0,
    100.0,
    len(state.nodes),
  )

  worldPort.SV_LinkEdict(state, 3, false)
  result = worldPort.SV_UnlinkEdict(state, 3)
  emitWorld("SV_UnlinkEdict", "linked", resultNumber(result), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)

  fixture = differentialFixture(c.CONTENTS_EMPTY)
  game = fixture[0]
  state = fixture[2]
  worldPort.World_SetTouchEnabled(state, 2, true)
  worldPort.SV_LinkEdict(state, 2, false)
  worldPort.SV_LinkEdict(state, 1, true)
  emitWorld(
    "SV_TouchLinks",
    "overlap",
    len(state.touchEvents),
    state.absMins[1].x,
    state.absMaxs[1].x,
    state.absMins[2].x,
    state.absMaxs[2].x,
    game.time,
    0.0,
    len(state.touchEvents),
  )

  fixture = differentialFixture(c.CONTENTS_EMPTY)
  state = fixture[2]
  state.absMins[1] = t.Vec3(1.0, 0.0, 0.0)
  state.absMaxs[1] = t.Vec3(2.0, 0.0, 0.0)
  worldPort.SV_FindTouchedLeafs(state, 1, -2)
  emitWorld(
    "SV_FindTouchedLeafs",
    "empty_leaf",
    state.leafNums[1][0],
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    len(state.leafNums[1]),
  )

  worldPort.SV_LinkEdict(state, 1, false)
  emitWorld(
    "SV_LinkEdict",
    "bbox_expand",
    1,
    state.absMins[1].x,
    state.absMins[1].y,
    state.absMins[1].z,
    state.absMaxs[1].x,
    state.absMaxs[1].y,
    state.absMaxs[1].z,
    0,
  )

  hull = worldPort.SV_HullForBox(
    t.Vec3(-2.0, -2.0, -2.0),
    t.Vec3(2.0, 2.0, 2.0),
  )
  point = t.Vec3(0.0, 0.0, 0.0)
  result = worldPort.SV_HullPointContents(hull, 0, point)
  emitWorld("SV_HullPointContents", "inside_portable_c", result, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0)

  fixture = differentialFixture(-9)
  state = fixture[2]
  point = t.Vec3(-1.0, 0.0, 0.0)
  result = worldPort.SV_PointContents(state, point)
  emitWorld("SV_PointContents", "current_to_water", result, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0)
  result = worldPort.SV_TruePointContents(state, point)
  emitWorld("SV_TruePointContents", "raw_current", result, point.x, point.y, point.z, 0.0, 0.0, 0.0, 0)

  fixture = differentialFixture(c.CONTENTS_SOLID)
  game = fixture[0]
  state = fixture[2]
  game.edicts[1].origin = t.Vec3(-10.0, 0.0, 0.0)
  result = worldPort.SV_TestEntityPosition(state, 1)
  emitWorld("SV_TestEntityPosition", "world_solid", result, -10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)

  selected = worldPort.SV_HullForEntity(
    state,
    0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
  )
  trace = t.Trace(
    true,
    false,
    false,
    false,
    1.0,
    t.Vec3(0.0, 0.0, 0.0),
    t.Plane(t.Vec3(0.0, 0.0, 0.0), 0.0, 0, 0),
    0,
  )
  result = worldPort.SV_RecursiveHullCheck(
    selected[0],
    selected[0].firstClipNode,
    0.0,
    1.0,
    t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(-10.0, 0.0, 0.0),
    trace,
  )
  emitTrace("SV_RecursiveHullCheck", "cross_solid", resultNumber(result), trace)

  fixture = differentialFixture(c.CONTENTS_EMPTY)
  state = fixture[2]
  trace = worldPort.SV_ClipMoveToEntity(
    state,
    3,
    t.Vec3(20.0, 0.0, 0.0),
    t.Vec3(-1.0, -1.0, -1.0),
    t.Vec3(1.0, 1.0, 1.0),
    t.Vec3(40.0, 0.0, 0.0),
  )
  emitTrace("SV_ClipMoveToEntity", "bbox", trace.entity, trace)

  bounds = worldPort.SV_MoveBounds(
    t.Vec3(10.0, 5.0, 0.0),
    t.Vec3(-1.0, -2.0, -3.0),
    t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(20.0, -5.0, 4.0),
  )
  emitWorld(
    "SV_MoveBounds",
    "swept",
    1,
    bounds[0].x,
    bounds[0].y,
    bounds[0].z,
    bounds[1].x,
    bounds[1].y,
    bounds[1].z,
    0,
  )

  fixture = differentialFixture(c.CONTENTS_EMPTY)
  game = fixture[0]
  state = fixture[2]
  game.edicts[1].mins = t.Vec3(0.0, 0.0, 0.0)
  game.edicts[1].maxs = t.Vec3(0.0, 0.0, 0.0)
  worldPort.SV_LinkEdict(state, 3, false)
  trace = worldPort.SV_Move(
    state,
    t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(60.0, 0.0, 0.0),
    c.MOVE_NORMAL,
    1,
  )
  emitTrace("SV_ClipToLinks", "linked_bbox", trace.entity, trace)
  emitTrace("SV_Move", "linked_bbox", trace.entity, trace)
  return 0
end function
