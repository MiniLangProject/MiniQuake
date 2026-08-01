/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Logical MiniLang pendant for WinQuake/world.c and world.h.  BSP traversal stays
in world_bsp, temporary AABB hulls stay in world_hull, and this unit owns the
original server-facing AreaNode/link/clip orchestration.
*/

package miniquake.world

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.array_util as arrayutil
import miniquake.world_bsp as bspworld
import miniquake.world_hull as boxworld
import miniquake.server_collision as collision

const AREA_DEPTH = 4
const AREA_NODES = 32
const MAX_ENT_LEAFS = 16

struct AreaNode
  axis
  dist
  child0
  child1
  triggerEdicts
  solidEdicts
end struct

struct WorldAreaState
  server
  map
  nodes
  root
  linkedNode
  linkedTrigger
  absMins
  absMaxs
  leafNums
  touchEnabled
  touchEvents
end struct

struct MoveClip
  boxMins
  boxMaxs
  mins
  maxs
  mins2
  maxs2
  start
  finish
  trace
  moveType
  passedEntity
end struct

function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

function absolute(value)
  if value < 0.0 then return -value end if
  return value
end function

function fallbackEdict(state, entityIndex)
  if state.server is void or entityIndex < 0 or entityIndex >= len(state.server.edicts) then return void end if
  return state.server.edicts[entityIndex]
end function

function hasRuntime(state)
  return state.server is not void and state.server.machine is not void and state.server.machine.context is not void
end function

function entityValid(state, entityIndex)
  if hasRuntime(state) then return collision.entityValid(state.server, entityIndex) end if
  item = fallbackEdict(state, entityIndex)
  return item is not void and not item.free
end function

function entityVector(state, entityIndex, name)
  if hasRuntime(state) then return collision.entityVector(state.server, entityIndex, name, zeroVector()) end if
  item = fallbackEdict(state, entityIndex)
  if item is void then return zeroVector() end if
  if name == "origin" then return math.VectorCopy(item.origin) end if
  if name == "mins" then return math.VectorCopy(item.mins) end if
  if name == "maxs" then return math.VectorCopy(item.maxs) end if
  if name == "angles" then return math.VectorCopy(item.angles) end if
  return zeroVector()
end function

function entityNumber(state, entityIndex, name, fallback)
  if hasRuntime(state) then
    if name == "owner" or name == "modelindex" or name == "touch" then
      return collision.entityWord(state.server, entityIndex, name, fallback)
    end if
    return native.trunc(collision.entityFloat(state.server, entityIndex, name, fallback))
  end if
  item = fallbackEdict(state, entityIndex)
  if item is void then return fallback end if
  if name == "solid" then return item.solid end if
  if name == "movetype" then return item.moveType end if
  if name == "flags" then return item.flags end if
  if name == "modelindex" then return item.modelIndex end if
  if name == "owner" then
    for each pair in item.keyValues
      if pair.key == "owner" then
        value = toNumber(pair.value)
        if value is int then return value end if
      end if
    end for
  end if
  return fallback
end function

function entityModel(state, entityIndex)
  if hasRuntime(state) then return collision.entityString(state.server, entityIndex, "model", "") end if
  item = fallbackEdict(state, entityIndex)
  if item is void then return "" end if
  return item.model
end function

function makeState(server, map)
  capacity = c.MAX_EDICTS
  if server is not void and server.maxEdicts > capacity then capacity = server.maxEdicts end if
  linkedNode = arrayutil.makeFilledArray(capacity, -1)
  linkedTrigger = arrayutil.makeFilledArray(capacity, false)
  absMins = arrayutil.makeEmptyArray(capacity)
  absMaxs = arrayutil.makeEmptyArray(capacity)
  leafNums = arrayutil.makeEmptyArray(capacity)
  touchEnabled = arrayutil.makeFilledArray(capacity, false)
  index = 0
  while index < capacity
    absMins[index] = zeroVector()
    absMaxs[index] = zeroVector()
    leafNums[index] = []
    index = index + 1
  end while
  return WorldAreaState(server, map, [], -1, linkedNode, linkedTrigger, absMins, absMaxs, leafNums, touchEnabled, [])
end function

function SV_InitBoxHull()
  return boxworld.createBoxHull(zeroVector(), zeroVector())
end function

function SV_HullForBox(mins, maxs)
  return boxworld.createBoxHull(math.VectorCopy(mins), math.VectorCopy(maxs))
end function

function SV_BoxOnPlaneSide(mins, maxs, plane)
  return math.BOX_ON_PLANE_SIDE(mins, maxs, plane)
end function

function SV_CreateAreaNode(state, depth, mins, maxs)
  if len(state.nodes) >= AREA_NODES then return error(3800, "SV_CreateAreaNode: AREA_NODES exhausted") end if
  node = AreaNode(-1, 0.0, -1, -1, [], [])
  nodeIndex = len(state.nodes)
  state.nodes = state.nodes + [node]
  if depth == AREA_DEPTH then return nodeIndex end if

  size = math.VectorSubtract(maxs, mins)
  node.axis = 1
  if size.x > size.y then node.axis = 0 end if
  if node.axis == 0 then node.dist = 0.5 * (maxs.x + mins.x) else node.dist = 0.5 * (maxs.y + mins.y) end if

  highMins = math.VectorCopy(mins)
  highMaxs = math.VectorCopy(maxs)
  lowMins = math.VectorCopy(mins)
  lowMaxs = math.VectorCopy(maxs)
  if node.axis == 0 then
    highMins.x = node.dist
    lowMaxs.x = node.dist
  else
    highMins.y = node.dist
    lowMaxs.y = node.dist
  end if
  node.child0 = SV_CreateAreaNode(state, depth + 1, highMins, highMaxs)
  node.child1 = SV_CreateAreaNode(state, depth + 1, lowMins, lowMaxs)
  return nodeIndex
end function

function SV_ClearWorld(server, map)
  if map is void or len(map.models) == 0 then return error(3801, "SV_ClearWorld: world model is missing") end if
  state = makeState(server, map)
  SV_InitBoxHull()
  state.root = SV_CreateAreaNode(state, 0, map.models[0].mins, map.models[0].maxs)
  return state
end function

function removeEntity(values, entityIndex)
  result = []
  for each value in values
    if value != entityIndex then result = result + [value] end if
  end for
  return result
end function

function SV_UnlinkEdict(state, entityIndex)
  if entityIndex < 0 or entityIndex >= len(state.linkedNode) then return false end if
  nodeIndex = state.linkedNode[entityIndex]
  if nodeIndex < 0 then return false end if
  node = state.nodes[nodeIndex]
  if state.linkedTrigger[entityIndex] then
    node.triggerEdicts = removeEntity(node.triggerEdicts, entityIndex)
  else
    node.solidEdicts = removeEntity(node.solidEdicts, entityIndex)
  end if
  state.linkedNode[entityIndex] = -1
  state.linkedTrigger[entityIndex] = false
  return true
end function

function boxPlane(state, planeIndex)
  source = state.map.planes[planeIndex]
  signBits = 0
  if source.normal.x < 0.0 then signBits = signBits | 1 end if
  if source.normal.y < 0.0 then signBits = signBits | 2 end if
  if source.normal.z < 0.0 then signBits = signBits | 4 end if
  return t.Plane(math.VectorCopy(source.normal), source.dist, source.type, signBits)
end function

function SV_FindTouchedLeafs(state, entityIndex, nodeNumber)
  if len(state.leafNums[entityIndex]) >= MAX_ENT_LEAFS then return false end if
  if nodeNumber < 0 then
    leafIndex = -1 - nodeNumber
    if leafIndex < 0 or leafIndex >= len(state.map.leafs) then return error(3802, "SV_FindTouchedLeafs: bad leaf") end if
    if state.map.leafs[leafIndex].contents == c.CONTENTS_SOLID then return false end if
    state.leafNums[entityIndex] = state.leafNums[entityIndex] + [leafIndex - 1]
    return true
  end if
  if nodeNumber >= len(state.map.nodes) then return error(3803, "SV_FindTouchedLeafs: bad node") end if
  node = state.map.nodes[nodeNumber]
  sides = SV_BoxOnPlaneSide(state.absMins[entityIndex], state.absMaxs[entityIndex], boxPlane(state, node.planeIndex))
  if (sides & 1) != 0 then SV_FindTouchedLeafs(state, entityIndex, node.child0) end if
  if len(state.leafNums[entityIndex]) >= MAX_ENT_LEAFS then return true end if
  if (sides & 2) != 0 then SV_FindTouchedLeafs(state, entityIndex, node.child1) end if
  return true
end function

function World_SetTouchEnabled(state, entityIndex, enabled)
  if entityIndex < 0 or entityIndex >= len(state.touchEnabled) then return false end if
  state.touchEnabled[entityIndex] = enabled
  return true
end function

function entityHasTouch(state, entityIndex)
  if hasRuntime(state) then return entityNumber(state, entityIndex, "touch", 0) != 0 end if
  return state.touchEnabled[entityIndex]
end function

function executeTrigger(state, triggerIndex, entityIndex)
  if hasRuntime(state) then return collision.executeTouch(state.server, triggerIndex, entityIndex) end if
  state.touchEvents = state.touchEvents + [[triggerIndex, entityIndex, state.server.time]]
  return true
end function

function boxesOverlap(minsA, maxsA, minsB, maxsB)
  return collision.boxesOverlap(minsA, maxsA, minsB, maxsB)
end function

function SV_TouchLinks(state, entityIndex, nodeIndex)
  node = state.nodes[nodeIndex]
  // Iterate a snapshot: QuakeC may unlink/free the current trigger during touch.
  triggers = node.triggerEdicts
  for each triggerIndex in triggers
    if triggerIndex != entityIndex and entityValid(state, triggerIndex) then
      if entityNumber(state, triggerIndex, "solid", c.SOLID_NOT) == c.SOLID_TRIGGER and entityHasTouch(state, triggerIndex) then
        if boxesOverlap(state.absMins[entityIndex], state.absMaxs[entityIndex], state.absMins[triggerIndex], state.absMaxs[triggerIndex]) then
          executeTrigger(state, triggerIndex, entityIndex)
        end if
      end if
    end if
  end for
  if node.axis == -1 then return true end if
  entityMin = state.absMins[entityIndex]
  entityMax = state.absMaxs[entityIndex]
  if (node.axis == 0 and entityMax.x > node.dist) or (node.axis == 1 and entityMax.y > node.dist) then
    SV_TouchLinks(state, entityIndex, node.child0)
  end if
  if (node.axis == 0 and entityMin.x < node.dist) or (node.axis == 1 and entityMin.y < node.dist) then
    SV_TouchLinks(state, entityIndex, node.child1)
  end if
  return true
end function

function rotatedBounds(origin, mins, maxs)
  maximum = 0.0
  values = [mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z]
  for each value in values
    magnitude = absolute(value)
    if magnitude > maximum then maximum = magnitude end if
  end for
  return [
    t.Vec3(origin.x - maximum, origin.y - maximum, origin.z - maximum),
    t.Vec3(origin.x + maximum, origin.y + maximum, origin.z + maximum),
  ]
end function

function SV_LinkEdict(state, entityIndex, touchTriggers)
  SV_UnlinkEdict(state, entityIndex)
  if entityIndex == 0 or not entityValid(state, entityIndex) then return false end if

  origin = entityVector(state, entityIndex, "origin")
  mins = entityVector(state, entityIndex, "mins")
  maxs = entityVector(state, entityIndex, "maxs")
  solid = entityNumber(state, entityIndex, "solid", c.SOLID_NOT)
  // WinQuake 1.09 is built without QUAKE2: rotated BSP broad-phase bounds are
  // not part of the compatibility profile.
  absMin = math.VectorAdd(origin, mins)
  absMax = math.VectorAdd(origin, maxs)

  flags = entityNumber(state, entityIndex, "flags", 0)
  if (flags & c.FL_ITEM) != 0 then
    absMin.x = absMin.x - 15.0
    absMin.y = absMin.y - 15.0
    absMax.x = absMax.x + 15.0
    absMax.y = absMax.y + 15.0
  else
    absMin.x = absMin.x - 1.0
    absMin.y = absMin.y - 1.0
    absMin.z = absMin.z - 1.0
    absMax.x = absMax.x + 1.0
    absMax.y = absMax.y + 1.0
    absMax.z = absMax.z + 1.0
  end if
  state.absMins[entityIndex] = absMin
  state.absMaxs[entityIndex] = absMax
  if hasRuntime(state) then
    collision.setEntityVector(state.server, entityIndex, "absmin", absMin)
    collision.setEntityVector(state.server, entityIndex, "absmax", absMax)
  end if

  state.leafNums[entityIndex] = []
  if entityNumber(state, entityIndex, "modelindex", 0) != 0 and len(state.map.models) > 0 then
    SV_FindTouchedLeafs(state, entityIndex, state.map.models[0].headNodes[0])
  end if
  if solid == c.SOLID_NOT then return true end if

  nodeIndex = state.root
  searching = true
  while searching
    node = state.nodes[nodeIndex]
    if node.axis == -1 then break end if
    if node.axis == 0 then
      if absMin.x > node.dist then nodeIndex = node.child0
      else if absMax.x < node.dist then nodeIndex = node.child1
      else searching = false
      end if
    else
      if absMin.y > node.dist then nodeIndex = node.child0
      else if absMax.y < node.dist then nodeIndex = node.child1
      else searching = false
      end if
    end if
  end while

  node = state.nodes[nodeIndex]
  if solid == c.SOLID_TRIGGER then
    node.triggerEdicts = node.triggerEdicts + [entityIndex]
    state.linkedTrigger[entityIndex] = true
  else
    node.solidEdicts = node.solidEdicts + [entityIndex]
    state.linkedTrigger[entityIndex] = false
  end if
  state.linkedNode[entityIndex] = nodeIndex
  if touchTriggers then SV_TouchLinks(state, entityIndex, state.root) end if
  return true
end function

function SV_HullPointContents(hull, number, point)
  return boxworld.pointContentsFromNode(hull, number, point)
end function

function SV_BspHullPointContents(hull, number, point)
  return bspworld.pointContentsFromNode(hull, number, point)
end function

function SV_PointContents(state, point)
  contents = SV_TruePointContents(state, point)
  if contents <= -9 and contents >= -14 then return c.CONTENTS_WATER end if
  return contents
end function

function SV_TruePointContents(state, point)
  return bspworld.truePointContents(state.map, point)
end function

function hullIndex(mins, maxs)
  sizeX = maxs.x - mins.x
  if sizeX < 3.0 then return 0 end if
  if sizeX <= 32.0 then return 1 end if
  return 2
end function

function SV_HullForEntity(state, entityIndex, mins, maxs)
  solid = entityNumber(state, entityIndex, "solid", c.SOLID_NOT)
  origin = entityVector(state, entityIndex, "origin")
  if solid == c.SOLID_BSP then
    if entityNumber(state, entityIndex, "movetype", c.MOVETYPE_NONE) != c.MOVETYPE_PUSH then
      return error(3804, "SOLID_BSP without MOVETYPE_PUSH")
    end if
    submodel = collision.modelSubIndex(entityModel(state, entityIndex))
    if entityIndex == 0 then submodel = 0 end if
    if submodel < 0 then return error(3805, "MOVETYPE_PUSH with a non bsp model") end if
    hull = bspworld.createModelHull(state.map, submodel, hullIndex(mins, maxs))
    offset = math.VectorAdd(math.VectorSubtract(hull.clipMins, mins), origin)
    // WinQuake's QUAKE2-only rotating brush path is deliberately disabled in
    // compat_109.  The angle fields remain available to QuakeC/rendering.
    return [hull, offset, false]
  end if
  hullMins = math.VectorSubtract(entityVector(state, entityIndex, "mins"), maxs)
  hullMaxs = math.VectorSubtract(entityVector(state, entityIndex, "maxs"), mins)
  return [SV_HullForBox(hullMins, hullMaxs), origin, false]
end function

function rotateIntoModel(value, angles)
  vectors = math.AngleVectors(angles)
  return t.Vec3(
    math.DotProduct(value, vectors[0]),
    -math.DotProduct(value, vectors[1]),
    math.DotProduct(value, vectors[2]),
  )
end function

function rotateFromModel(value, angles)
  inverse = t.Vec3(-angles.x, -angles.y, -angles.z)
  return rotateIntoModel(value, inverse)
end function

function SV_RecursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
  return bspworld.recursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
end function

function SV_ClipMoveToEntity(state, entityIndex, start, mins, maxs, finish)
  selected = SV_HullForEntity(state, entityIndex, mins, maxs)
  hull = selected[0]
  offset = selected[1]
  rotated = selected[2]
  localStart = math.VectorSubtract(start, offset)
  localFinish = math.VectorSubtract(finish, offset)
  angles = entityVector(state, entityIndex, "angles")
  if rotated then
    localStart = rotateIntoModel(localStart, angles)
    localFinish = rotateIntoModel(localFinish, angles)
  end if

  trace = t.Trace(true, false, false, false, 1.0, math.VectorCopy(localFinish), t.Plane(zeroVector(), 0.0, 0, 0), 0)
  if entityNumber(state, entityIndex, "solid", c.SOLID_NOT) == c.SOLID_BSP then
    trace = bspworld.traceInHull(hull, localStart, localFinish)
  else
    trace = boxworld.traceLine(hull, localStart, localFinish)
  end if

  if trace.fraction == 1.0 then
    // world.c initializes trace.endpos with the caller's world-space end
    // point.  Local hull coordinates must never leak from a clear trace.
    trace.endPosition = math.VectorCopy(finish)
  else
    if rotated then
      trace.endPosition = rotateFromModel(trace.endPosition, angles)
      trace.plane.normal = rotateFromModel(trace.plane.normal, angles)
    end if
    trace.endPosition = math.VectorAdd(trace.endPosition, offset)
  end if
  if trace.fraction < 1.0 or trace.startSolid then trace.entity = entityIndex end if
  return trace
end function

function SV_MoveBounds(start, mins, maxs, finish)
  return collision.moveBounds(start, mins, maxs, finish)
end function

function chooseTrace(best, candidate)
  return collision.chooseTrace(best, candidate)
end function

function SV_ClipToLinks(state, nodeIndex, clip)
  node = state.nodes[nodeIndex]
  solids = node.solidEdicts
  for each touchIndex in solids
    if entityValid(state, touchIndex) and touchIndex != clip.passedEntity then
      solid = entityNumber(state, touchIndex, "solid", c.SOLID_NOT)
      if solid == c.SOLID_TRIGGER then return error(3806, "Trigger in clipping list") end if
      consider = solid != c.SOLID_NOT
      if clip.moveType == c.MOVE_NOMONSTERS and solid != c.SOLID_BSP then consider = false end if
      if consider and not boxesOverlap(clip.boxMins, clip.boxMaxs, state.absMins[touchIndex], state.absMaxs[touchIndex]) then consider = false end if

      if consider and clip.passedEntity >= 0 then
        passedMins = entityVector(state, clip.passedEntity, "mins")
        passedMaxs = entityVector(state, clip.passedEntity, "maxs")
        touchMins = entityVector(state, touchIndex, "mins")
        touchMaxs = entityVector(state, touchIndex, "maxs")
        if passedMaxs.x - passedMins.x != 0.0 and touchMaxs.x - touchMins.x == 0.0 then consider = false end if
        if entityNumber(state, touchIndex, "owner", -1) == clip.passedEntity then consider = false end if
        if entityNumber(state, clip.passedEntity, "owner", -1) == touchIndex then consider = false end if
      end if

      if consider then
        if clip.trace.allSolid then return true end if
        touchMins = clip.mins
        touchMaxs = clip.maxs
        if (entityNumber(state, touchIndex, "flags", 0) & c.FL_MONSTER) != 0 then
          touchMins = clip.mins2
          touchMaxs = clip.maxs2
        end if
        candidate = SV_ClipMoveToEntity(state, touchIndex, clip.start, touchMins, touchMaxs, clip.finish)
        clip.trace = chooseTrace(clip.trace, candidate)
      end if
    end if
  end for

  if node.axis == -1 then return true end if
  if (node.axis == 0 and clip.boxMaxs.x > node.dist) or (node.axis == 1 and clip.boxMaxs.y > node.dist) then
    SV_ClipToLinks(state, node.child0, clip)
  end if
  if (node.axis == 0 and clip.boxMins.x < node.dist) or (node.axis == 1 and clip.boxMins.y < node.dist) then
    SV_ClipToLinks(state, node.child1, clip)
  end if
  return true
end function

function SV_Move(state, start, mins, maxs, finish, moveType, passedEntity)
  trace = bspworld.trace(state.map, start, mins, maxs, finish)
  if trace.fraction < 1.0 or trace.startSolid then trace.entity = 0 else trace.entity = -1 end if
  mins2 = math.VectorCopy(mins)
  maxs2 = math.VectorCopy(maxs)
  if moveType == c.MOVE_MISSILE then
    mins2 = t.Vec3(-15.0, -15.0, -15.0)
    maxs2 = t.Vec3(15.0, 15.0, 15.0)
  end if
  bounds = SV_MoveBounds(start, mins2, maxs2, finish)
  clip = MoveClip(bounds[0], bounds[1], mins, maxs, mins2, maxs2, start, finish, trace, moveType, passedEntity)
  SV_ClipToLinks(state, state.root, clip)
  return clip.trace
end function

function SV_TestEntityPosition(state, entityIndex)
  if not entityValid(state, entityIndex) then return -1 end if
  origin = entityVector(state, entityIndex, "origin")
  trace = SV_Move(
    state,
    origin,
    entityVector(state, entityIndex, "mins"),
    entityVector(state, entityIndex, "maxs"),
    origin,
    c.MOVE_NORMAL,
    entityIndex,
  )
  if trace.startSolid then return 0 end if
  return -1
end function
