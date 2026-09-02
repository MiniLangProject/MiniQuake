/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.server_collision.
*/
package miniquake.server_collision

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.native as native
import miniquake.world_bsp as world
import miniquake.world_hull as boxhull
import miniquake.quakec.vm as vm

// The C engine resolves entvars_t members at compile time. MiniLang must look
// them up by name, but collision invokes the same small field set millions of
// times while monsters chase. Keep a module-local direct cache so those hot
// reads do not repeatedly enter the generic VM definition lookup machinery.
const COLLISION_OFFSET_CACHE_SIZE = 64
/// Tracks the module-level collision offset machine state owned by `miniquake.server_collision`.
collisionOffsetMachine = void
/// Tracks the module-level collision offset keys state owned by `miniquake.server_collision`.
collisionOffsetKeys = array(COLLISION_OFFSET_CACHE_SIZE, 0)
/// Tracks the module-level collision offset values state owned by `miniquake.server_collision`.
collisionOffsetValues = array(COLLISION_OFFSET_CACHE_SIZE, -2)

/// Implements the `zeroVector` operation for `miniquake.server_collision` (zero vector).
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `emptyPlane` operation for `miniquake.server_collision` (empty plane).
function emptyPlane()
  return t.Plane(zeroVector(), 0.0, 0, 0)
end function

/// Implements the `fieldOffset` operation for `miniquake.server_collision` (field offset).
/// @param server Server state participating in the operation.
/// @param name Stable name that identifies the requested object or option.
function fieldOffset(server, name)
  global collisionOffsetMachine, collisionOffsetKeys, collisionOffsetValues
  if server is void or server.machine is void then return -1 end if
  machine = server.machine
  if collisionOffsetMachine is void or nativeRawValue(collisionOffsetMachine) != nativeRawValue(machine) then
    collisionOffsetMachine = machine
    collisionOffsetKeys = array(COLLISION_OFFSET_CACHE_SIZE, 0)
    collisionOffsetValues = array(COLLISION_OFFSET_CACHE_SIZE, -2)
  end if
  key = nativeRawValue(name)
  slot = ((key >> 3) ^ (key >> 11)) & (COLLISION_OFFSET_CACHE_SIZE - 1)
  if collisionOffsetKeys[slot] == key and collisionOffsetValues[slot] != -2 then return collisionOffsetValues[slot] end if
  value = vm.fieldOffset(machine, name)
  collisionOffsetKeys[slot] = key
  collisionOffsetValues[slot] = value
  return value
end function

/// Implements the `entityFloat` operation for `miniquake.server_collision` (entity float).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function entityFloat(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityFloat(server.machine, entityIndex, offset)
end function

/// Implements the `entityWord` operation for `miniquake.server_collision` (entity word).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function entityWord(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityField(server.machine, entityIndex, offset)
end function

/// Implements the `entityVector` operation for `miniquake.server_collision` (entity vector).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function entityVector(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  return vm.entityVector(server.machine, entityIndex, offset)
end function

/// Read a generated QuakeC vector and allocate the zero fallback only for a
/// genuinely missing field. Stock progs.dat contains all collision vectors;
/// passing zeroVector() eagerly at every call site formerly created more than
/// one million dead Vec3 values in a 300-frame e1m2 sample.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
function entityVectorZero(server, entityIndex, name)
  offset = fieldOffset(server, name)
  if offset < 0 then return zeroVector() end if
  return vm.entityVector(server.machine, entityIndex, offset)
end function

/// Implements the `entityString` operation for `miniquake.server_collision` (entity string).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param fallback Value to use when the requested input is unavailable or invalid.
function entityString(server, entityIndex, name, fallback)
  offset = fieldOffset(server, name)
  if offset < 0 then return fallback end if
  value = vm.entityString(server.machine, entityIndex, offset)
  if value == "" then return fallback end if
  return value
end function

/// Sets entity float for `miniquake.server_collision`.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityFloat`.
function setEntityFloat(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityFloat(server.machine, entityIndex, offset, value) end if
end function

/// Update module state for entity word.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityWord`.
function setEntityWord(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityField(server.machine, entityIndex, offset, value) end if
end function

/// Sets entity vector for `miniquake.server_collision`.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `setEntityVector`.
function setEntityVector(server, entityIndex, name, value)
  offset = fieldOffset(server, name)
  if offset >= 0 then vm.setEntityVector(server.machine, entityIndex, offset, value) end if
end function

/// Report whether entity valid holds for the active state.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function entityValid(server, entityIndex)
  if server is void or server.machine is void or server.machine.context is void then return false end if
  runtime = server.machine.context.edicts
  if entityIndex < 0 or entityIndex >= runtime.numEdicts then return false end if
  return not runtime.freeFlags[entityIndex]
end function

/// Return model sub index derived from the active module state.
/// @param name Stable name that identifies the requested object or option.
function modelSubIndex(name)
  source = bytes(name)
  if len(source) < 2 or source[0] != 42 then return -1 end if
  value = toNumber(decode(slice(source, 1, len(source) - 1)))
  if value is void or value is not int then return -1 end if
  return value
end function

// WinQuake's AREA_DEPTH=4 tree contains at most 31 nodes. Edicts are linked
// into exactly one solid or trigger list at the deepest node that fully
// contains their expanded bounds.
const AREA_DEPTH = 4
/// Defines the area node capacity value used by `miniquake.server_collision`.
const AREA_NODE_CAPACITY = 31
/// Tracks the module-level area machine state owned by `miniquake.server_collision`.
areaMachine = void
/// Tracks the module-level area node count state owned by `miniquake.server_collision`.
areaNodeCount = 0
/// Tracks the module-level area node axis state owned by `miniquake.server_collision`.
areaNodeAxis = array(AREA_NODE_CAPACITY, -1)
/// Tracks the module-level area node dist state owned by `miniquake.server_collision`.
areaNodeDist = array(AREA_NODE_CAPACITY, 0.0)
/// Tracks the module-level area node child0 state owned by `miniquake.server_collision`.
areaNodeChild0 = array(AREA_NODE_CAPACITY, -1)
/// Tracks the module-level area node child1 state owned by `miniquake.server_collision`.
areaNodeChild1 = array(AREA_NODE_CAPACITY, -1)
/// Tracks the module-level area solid head state owned by `miniquake.server_collision`.
areaSolidHead = array(AREA_NODE_CAPACITY, -1)
/// Tracks the module-level area trigger head state owned by `miniquake.server_collision`.
areaTriggerHead = array(AREA_NODE_CAPACITY, -1)
/// Tracks the module-level area entity next state owned by `miniquake.server_collision`.
areaEntityNext = []
/// Tracks the module-level area entity previous state owned by `miniquake.server_collision`.
areaEntityPrevious = []
/// Tracks the module-level area entity node state owned by `miniquake.server_collision`.
areaEntityNode = []
/// Tracks the module-level area entity trigger state owned by `miniquake.server_collision`.
areaEntityTrigger = []

/// Recursively construct the same horizontal binary partition as
/// SV_CreateAreaNode in world.c.
/// @param depth The depth input consumed by `createAreaNode`.
/// @param minX The min x input consumed by `createAreaNode`.
/// @param minY The min y input consumed by `createAreaNode`.
/// @param maxX The max x input consumed by `createAreaNode`.
/// @param maxY The max y input consumed by `createAreaNode`.
function createAreaNode(depth, minX, minY, maxX, maxY)
  global areaNodeCount, areaNodeAxis, areaNodeDist, areaNodeChild0, areaNodeChild1
  node = areaNodeCount
  if node >= AREA_NODE_CAPACITY then return -1 end if
  areaNodeCount = areaNodeCount + 1
  if depth == AREA_DEPTH then
    areaNodeAxis[node] = -1
    return node
  end if
  sizeX = maxX - minX
  sizeY = maxY - minY
  axis = 1
  if sizeX > sizeY then axis = 0 end if
  dist = (minY + maxY) * 0.5
  if axis == 0 then dist = (minX + maxX) * 0.5 end if
  areaNodeAxis[node] = axis
  areaNodeDist[node] = dist
  if axis == 0 then
    areaNodeChild0[node] = createAreaNode(depth + 1, dist, minY, maxX, maxY)
    areaNodeChild1[node] = createAreaNode(depth + 1, minX, minY, dist, maxY)
  else
    areaNodeChild0[node] = createAreaNode(depth + 1, minX, dist, maxX, maxY)
    areaNodeChild1[node] = createAreaNode(depth + 1, minX, minY, maxX, dist)
  end if
  return node
end function

/// Remove one edict from its current O(1) area-list position.
/// @param entityIndex Zero-based index of the requested entry.
function unlinkAreaEntity(entityIndex)
  global areaSolidHead, areaTriggerHead, areaEntityNext, areaEntityPrevious, areaEntityNode, areaEntityTrigger
  if entityIndex < 0 or entityIndex >= len(areaEntityNode) then return false end if
  node = areaEntityNode[entityIndex]
  if node < 0 then return false end if
  previous = areaEntityPrevious[entityIndex]
  next = areaEntityNext[entityIndex]
  if previous >= 0 then
    areaEntityNext[previous] = next
  else if areaEntityTrigger[entityIndex] then
    areaTriggerHead[node] = next
  else
    areaSolidHead[node] = next
  end if
  if next >= 0 then areaEntityPrevious[next] = previous end if
  areaEntityNext[entityIndex] = -1
  areaEntityPrevious[entityIndex] = -1
  areaEntityNode[entityIndex] = -1
  areaEntityTrigger[entityIndex] = false
  return true
end function

/// Insert one linked edict into its deepest non-splitting area node.
/// @param entityIndex Zero-based index of the requested entry.
/// @param bounds The bounds input consumed by `insertAreaEntity`.
/// @param solid Stable identifier of the requested entry.
function insertAreaEntity(entityIndex, bounds, solid)
  global areaSolidHead, areaTriggerHead, areaEntityNext, areaEntityPrevious, areaEntityNode, areaEntityTrigger
  if entityIndex <= 0 or entityIndex >= len(areaEntityNode) or solid == c.SOLID_NOT then return false end if
  node = 0
  while node >= 0 and areaNodeAxis[node] != -1
    axis = areaNodeAxis[node]
    dist = areaNodeDist[node]
    minimum = bounds[0].y
    maximum = bounds[1].y
    if axis == 0 then minimum = bounds[0].x; maximum = bounds[1].x end if
    if minimum > dist then
      node = areaNodeChild0[node]
    else if maximum < dist then
      node = areaNodeChild1[node]
    else
      break
    end if
  end while
  if node < 0 then return false end if
  trigger = solid == c.SOLID_TRIGGER
  head = areaSolidHead[node]
  if trigger then head = areaTriggerHead[node] end if
  areaEntityNode[entityIndex] = node
  areaEntityTrigger[entityIndex] = trigger
  areaEntityPrevious[entityIndex] = -1
  areaEntityNext[entityIndex] = head
  if head >= 0 then areaEntityPrevious[head] = entityIndex end if
  if trigger then areaTriggerHead[node] = entityIndex else areaSolidHead[node] = entityIndex end if
  return true
end function

/// Initialize the area tree for a new QuakeC edict table and seed it from the
/// currently linked bounds. Subsequent SV_LinkEdict calls maintain it in O(1).
/// @param server Server state participating in the operation.
function ensureAreaTree(server)
  global areaMachine, areaNodeCount, areaNodeAxis, areaNodeDist, areaNodeChild0, areaNodeChild1
  global areaSolidHead, areaTriggerHead, areaEntityNext, areaEntityPrevious, areaEntityNode, areaEntityTrigger
  if server is void or server.machine is void or server.machine.context is void or server.worldModel is void then return false end if
  machine = server.machine
  runtime = machine.context.edicts
  if areaMachine is not void and nativeRawValue(areaMachine) == nativeRawValue(machine) and len(areaEntityNode) == len(runtime.freeFlags) then return true end if
  if len(server.worldModel.models) == 0 then return false end if
  areaMachine = machine
  areaNodeCount = 0
  areaNodeAxis = array(AREA_NODE_CAPACITY, -1)
  areaNodeDist = array(AREA_NODE_CAPACITY, 0.0)
  areaNodeChild0 = array(AREA_NODE_CAPACITY, -1)
  areaNodeChild1 = array(AREA_NODE_CAPACITY, -1)
  areaSolidHead = array(AREA_NODE_CAPACITY, -1)
  areaTriggerHead = array(AREA_NODE_CAPACITY, -1)
  capacity = len(runtime.freeFlags)
  areaEntityNext = array(capacity, -1)
  areaEntityPrevious = array(capacity, -1)
  areaEntityNode = array(capacity, -1)
  areaEntityTrigger = array(capacity, false)
  worldModel = server.worldModel.models[0]
  createAreaNode(0, worldModel.mins.x, worldModel.mins.y, worldModel.maxs.x, worldModel.maxs.y)
  index = 1
  while index < runtime.numEdicts
    if not runtime.freeFlags[index] then
      solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
      if solid != c.SOLID_NOT then insertAreaEntity(index, linkedEntityBounds(server, index), solid) end if
    end if
    index = index + 1
  end while
  return true
end function

/// Refresh an edict's area-list membership after its abs bounds change.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param bounds The bounds input consumed by `relinkAreaEntity`.
/// @param solid Stable identifier of the requested entry.
function relinkAreaEntity(server, entityIndex, bounds, solid)
  if not ensureAreaTree(server) then return false end if
  unlinkAreaEntity(entityIndex)
  if solid == c.SOLID_NOT then return true end if
  return insertAreaEntity(entityIndex, bounds, solid)
end function

/// Computes d entity bounds for `miniquake.server_collision`.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function computedEntityBounds(server, entityIndex)
  origin = entityVectorZero(server, entityIndex, "origin")
  mins = entityVectorZero(server, entityIndex, "mins")
  maxs = entityVectorZero(server, entityIndex, "maxs")
  absMin = t.Vec3(origin.x + mins.x, origin.y + mins.y, origin.z + mins.z)
  absMax = t.Vec3(origin.x + maxs.x, origin.y + maxs.y, origin.z + maxs.z)
  flags = native.trunc(entityFloat(server, entityIndex, "flags", 0.0))
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
  return [absMin, absMax]
end function

/// Return the abs bounds maintained by SV_LinkEdict. Hand-built unit fixtures
/// may omit the link step and leave both generated vectors zeroed, so retain a
/// computed fallback for that non-production case.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function linkedEntityBounds(server, entityIndex)
  absMin = entityVectorZero(server, entityIndex, "absmin")
  absMax = entityVectorZero(server, entityIndex, "absmax")
  if absMin.x == 0.0 and absMin.y == 0.0 and absMin.z == 0.0 and
    absMax.x == 0.0 and absMax.y == 0.0 and absMax.z == 0.0 then
    return computedEntityBounds(server, entityIndex)
  end if
  return [absMin, absMax]
end function

/// Implements the `entityAbsMin` operation for `miniquake.server_collision` (entity abs min).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function entityAbsMin(server, entityIndex)
  return linkedEntityBounds(server, entityIndex)[0]
end function

/// Implements the `entityAbsMax` operation for `miniquake.server_collision` (entity abs max).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function entityAbsMax(server, entityIndex)
  return linkedEntityBounds(server, entityIndex)[1]
end function

/// Update module state for entity bounds.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function updateEntityBounds(server, entityIndex)
  if entityIndex == 0 or not entityValid(server, entityIndex) then return false end if
  bounds = computedEntityBounds(server, entityIndex)
  setEntityVector(server, entityIndex, "absmin", bounds[0])
  setEntityVector(server, entityIndex, "absmax", bounds[1])
  return true
end function

/// Implements the `boxesOverlap` operation for `miniquake.server_collision` (boxes overlap).
/// @param minsA The mins a input consumed by `boxesOverlap`.
/// @param maxsA The maxs a input consumed by `boxesOverlap`.
/// @param minsB The mins b input consumed by `boxesOverlap`.
/// @param maxsB The maxs b input consumed by `boxesOverlap`.
function boxesOverlap(minsA, maxsA, minsB, maxsB)
  if minsA.x > maxsB.x or maxsA.x < minsB.x then return false end if
  if minsA.y > maxsB.y or maxsA.y < minsB.y then return false end if
  if minsA.z > maxsB.z or maxsA.z < minsB.z then return false end if
  return true
end function

/// Transfer data for move bounds.
/// @param start The start input consumed by `moveBounds`.
/// @param mins The mins input consumed by `moveBounds`.
/// @param maxs The maxs input consumed by `moveBounds`.
/// @param finish The finish input consumed by `moveBounds`.
function moveBounds(start, mins, maxs, finish)
  boxMins = zeroVector()
  boxMaxs = zeroVector()
  if finish.x > start.x then
    boxMins.x = start.x + mins.x - 1.0
    boxMaxs.x = finish.x + maxs.x + 1.0
  else
    boxMins.x = finish.x + mins.x - 1.0
    boxMaxs.x = start.x + maxs.x + 1.0
  end if
  if finish.y > start.y then
    boxMins.y = start.y + mins.y - 1.0
    boxMaxs.y = finish.y + maxs.y + 1.0
  else
    boxMins.y = finish.y + mins.y - 1.0
    boxMaxs.y = start.y + maxs.y + 1.0
  end if
  if finish.z > start.z then
    boxMins.z = start.z + mins.z - 1.0
    boxMaxs.z = finish.z + maxs.z + 1.0
  else
    boxMins.z = finish.z + mins.z - 1.0
    boxMaxs.z = start.z + maxs.z + 1.0
  end if
  return [boxMins, boxMaxs]
end function

/// Trace against box through the collision world.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param start The start input consumed by `traceAgainstBox`.
/// @param mins The mins input consumed by `traceAgainstBox`.
/// @param maxs The maxs input consumed by `traceAgainstBox`.
/// @param finish The finish input consumed by `traceAgainstBox`.
function traceAgainstBox(server, entityIndex, start, mins, maxs, finish)
  origin = entityVectorZero(server, entityIndex, "origin")
  entityMins = entityVectorZero(server, entityIndex, "mins")
  entityMaxs = entityVectorZero(server, entityIndex, "maxs")
  expandedMins = t.Vec3(
    origin.x + entityMins.x - maxs.x,
    origin.y + entityMins.y - maxs.y,
    origin.z + entityMins.z - maxs.z,
  )
  expandedMaxs = t.Vec3(
    origin.x + entityMaxs.x - mins.x,
    origin.y + entityMaxs.y - mins.y,
    origin.z + entityMaxs.z - mins.z,
  )
  hull = boxhull.createBoxHull(expandedMins, expandedMaxs)
  result = boxhull.traceLine(hull, start, finish)
  if result.fraction < 1.0 or result.startSolid then result.entity = entityIndex end if
  return result
end function

/// Trace against brush through the collision world.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param start The start input consumed by `traceAgainstBrush`.
/// @param mins The mins input consumed by `traceAgainstBrush`.
/// @param maxs The maxs input consumed by `traceAgainstBrush`.
/// @param finish The finish input consumed by `traceAgainstBrush`.
function traceAgainstBrush(server, entityIndex, start, mins, maxs, finish)
  origin = entityVectorZero(server, entityIndex, "origin")
  name = entityString(server, entityIndex, "model", "")
  submodelIndex = modelSubIndex(name)
  if submodelIndex < 0 then return traceAgainstBox(server, entityIndex, start, mins, maxs, finish) end if
  result = world.traceBrushModel(server.worldModel, submodelIndex, origin, start, mins, maxs, finish)
  if result.fraction < 1.0 or result.startSolid then result.entity = entityIndex end if
  return result
end function

/// Trace to entity through the collision world.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param start The start input consumed by `clipToEntity`.
/// @param mins The mins input consumed by `clipToEntity`.
/// @param maxs The maxs input consumed by `clipToEntity`.
/// @param finish The finish input consumed by `clipToEntity`.
function clipToEntity(server, entityIndex, start, mins, maxs, finish)
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_BSP then return traceAgainstBrush(server, entityIndex, start, mins, maxs, finish) end if
  return traceAgainstBox(server, entityIndex, start, mins, maxs, finish)
end function

/// Implements the `chooseTrace` operation for `miniquake.server_collision` (choose trace).
/// @param best The best input consumed by `chooseTrace`.
/// @param candidate The candidate input consumed by `chooseTrace`.
function chooseTrace(best, candidate)
  if candidate.allSolid or candidate.startSolid or candidate.fraction < best.fraction then
    preservedStartSolid = best.startSolid
    best = candidate
    if preservedStartSolid then best.startSolid = true end if
  else if candidate.startSolid then
    best.startSolid = true
  end if
  return best
end function

/// Apply the stock SV_ClipToLinks filters to one broadphase candidate.
/// @param server Server state participating in the operation.
/// @param index Zero-based index of the requested entry.
/// @param start The start input consumed by `clipAreaEntity`.
/// @param mins The mins input consumed by `clipAreaEntity`.
/// @param maxs The maxs input consumed by `clipAreaEntity`.
/// @param finish The finish input consumed by `clipAreaEntity`.
/// @param moveType The move type input consumed by `clipAreaEntity`.
/// @param passedEntity The passed entity input consumed by `clipAreaEntity`.
/// @param passedOwner The passed owner input consumed by `clipAreaEntity`.
/// @param passedSizeX The passed size x input consumed by `clipAreaEntity`.
/// @param boxMins The box mins input consumed by `clipAreaEntity`.
/// @param boxMaxs The box maxs input consumed by `clipAreaEntity`.
/// @param best The best input consumed by `clipAreaEntity`.
function clipAreaEntity(server, index, start, mins, maxs, finish, moveType, passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best)
  if index == passedEntity or not entityValid(server, index) then return best end if
  solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
  if solid == c.SOLID_NOT or solid == c.SOLID_TRIGGER then return best end if
  if moveType == c.MOVE_NOMONSTERS and solid != c.SOLID_BSP then return best end if
  flags = native.trunc(entityFloat(server, index, "flags", 0.0))
  // Stock monster QuakeC often waits two or three death-animation frames
  // before assigning SOLID_NOT. That briefly traps a player who killed an
  // enemy in a narrow doorway. Suppress only player-versus-dead-monster
  // clipping immediately; projectile and non-client traces still see the
  // dying entity, preserving corpse damage, gibs and normal QuakeC behavior.
  playerMove = passedEntity > 0 and passedEntity <= server.maxClients
  if playerMove and (flags & c.FL_MONSTER) != 0 and entityFloat(server, index, "health", 1.0) <= 0.0 then return best end if
  owner = entityWord(server, index, "owner", -1)
  if owner == passedEntity or passedOwner == index then return best end if

  // Door targets and other point helpers are not collision candidates for a
  // normal-sized mover.
  if passedSizeX != 0.0 then
    touchMinsValue = entityVectorZero(server, index, "mins")
    touchMaxsValue = entityVectorZero(server, index, "maxs")
    if touchMaxsValue.x - touchMinsValue.x == 0.0 then return best end if
  end if
  entityBounds = linkedEntityBounds(server, index)
  if not boxesOverlap(boxMins, boxMaxs, entityBounds[0], entityBounds[1]) then return best end if

  touchMins = mins
  touchMaxs = maxs
  if moveType == c.MOVE_MISSILE then
    if (flags & c.FL_MONSTER) != 0 then
      touchMins = t.Vec3(-15.0, -15.0, -15.0)
      touchMaxs = t.Vec3(15.0, 15.0, 15.0)
    end if
  end if
  candidate = clipToEntity(server, index, start, touchMins, touchMaxs, finish)
  return chooseTrace(best, candidate)
end function

/// Recursively clip only the area nodes intersected by the swept move bounds.
/// @param server Server state participating in the operation.
/// @param node The node input consumed by `clipAreaNode`.
/// @param start The start input consumed by `clipAreaNode`.
/// @param mins The mins input consumed by `clipAreaNode`.
/// @param maxs The maxs input consumed by `clipAreaNode`.
/// @param finish The finish input consumed by `clipAreaNode`.
/// @param moveType The move type input consumed by `clipAreaNode`.
/// @param passedEntity The passed entity input consumed by `clipAreaNode`.
/// @param passedOwner The passed owner input consumed by `clipAreaNode`.
/// @param passedSizeX The passed size x input consumed by `clipAreaNode`.
/// @param boxMins The box mins input consumed by `clipAreaNode`.
/// @param boxMaxs The box maxs input consumed by `clipAreaNode`.
/// @param best The best input consumed by `clipAreaNode`.
function clipAreaNode(server, node, start, mins, maxs, finish, moveType, passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best)
  if node < 0 or best.allSolid then return best end if
  index = areaSolidHead[node]
  while index >= 0
    next = areaEntityNext[index]
    best = clipAreaEntity(
      server, index, start, mins, maxs, finish, moveType, passedEntity,
      passedOwner, passedSizeX, boxMins, boxMaxs, best,
    )
    if best.allSolid then return best end if
    index = next
  end while
  axis = areaNodeAxis[node]
  if axis == -1 then return best end if
  minimum = boxMins.y
  maximum = boxMaxs.y
  if axis == 0 then minimum = boxMins.x; maximum = boxMaxs.x end if
  if maximum > areaNodeDist[node] then
    best = clipAreaNode(
      server, areaNodeChild0[node], start, mins, maxs, finish, moveType,
      passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best,
    )
  end if
  if minimum < areaNodeDist[node] and not best.allSolid then
    best = clipAreaNode(
      server, areaNodeChild1[node], start, mins, maxs, finish, moveType,
      passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best,
    )
  end if
  return best
end function

/// SV_Move: clip first against the world, then every potentially intersecting
/// solid edict.  Area nodes are an optimization only; a linear scan has the same
/// observable Quake semantics and is suitable for the stock MAX_EDICTS limit.
/// @param server Server state participating in the operation.
/// @param start The start input consumed by `move`.
/// @param mins The mins input consumed by `move`.
/// @param maxs The maxs input consumed by `move`.
/// @param finish The finish input consumed by `move`.
/// @param moveType The move type input consumed by `move`.
/// @param passedEntity The passed entity input consumed by `move`.
function move(server, start, mins, maxs, finish, moveType, passedEntity)
  best = world.trace(server.worldModel, start, mins, maxs, finish)
  if best.fraction < 1.0 or best.startSolid then best.entity = 0 else best.entity = -1 end if
  if server.machine is void or server.machine.context is void then return best end if

  clipMins = mins
  clipMaxs = maxs
  if moveType == c.MOVE_MISSILE then
    clipMins = t.Vec3(-15.0, -15.0, -15.0)
    clipMaxs = t.Vec3(15.0, 15.0, 15.0)
  end if
  bounds = moveBounds(start, clipMins, clipMaxs, finish)
  boxMins = bounds[0]
  boxMaxs = bounds[1]
  passedOwner = -1
  passedSizeX = 0.0
  if passedEntity >= 0 and entityValid(server, passedEntity) then
    passedOwner = entityWord(server, passedEntity, "owner", -1)
    passedMins = entityVectorZero(server, passedEntity, "mins")
    passedMaxs = entityVectorZero(server, passedEntity, "maxs")
    passedSizeX = passedMaxs.x - passedMins.x
  end if

  if ensureAreaTree(server) then
    return clipAreaNode(
      server, 0, start, mins, maxs, finish, moveType, passedEntity,
      passedOwner, passedSizeX, boxMins, boxMaxs, best,
    )
  end if

  // Minimal fallback for synthetic servers without a BSP model. Production
  // maps always use the area tree above.
  index = 1
  runtime = server.machine.context.edicts
  while index < runtime.numEdicts
    if not runtime.freeFlags[index] then
      best = clipAreaEntity(
        server, index, start, mins, maxs, finish, moveType, passedEntity,
        passedOwner, passedSizeX, boxMins, boxMaxs, best,
      )
      if best.allSolid then return best end if
    end if
    index = index + 1
  end while
  return best
end function

/// Verify entity position against the expected Quake behavior.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function testEntityPosition(server, entityIndex)
  if not entityValid(server, entityIndex) then return -1 end if
  origin = entityVectorZero(server, entityIndex, "origin")
  mins = entityVectorZero(server, entityIndex, "mins")
  maxs = entityVectorZero(server, entityIndex, "maxs")
  trace = move(server, origin, mins, maxs, origin, c.MOVE_NORMAL, entityIndex)
  if trace.startSolid then return 0 end if
  return -1
end function

/// Execute touch.
/// @param server Server state participating in the operation.
/// @param selfIndex Zero-based index of the requested entry.
/// @param otherIndex Zero-based index of the requested entry.
function executeTouch(server, selfIndex, otherIndex)
  if not entityValid(server, selfIndex) then return false end if
  solid = native.trunc(entityFloat(server, selfIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_NOT then return false end if
  touch = entityWord(server, selfIndex, "touch", 0)
  if touch == 0 then return false end if
  machine = server.machine
  oldSelf = vm.word(machine, c.QC_GLOBAL_SELF)
  oldOther = vm.word(machine, c.QC_GLOBAL_OTHER)
  vm.setWord(machine, c.QC_GLOBAL_SELF, selfIndex)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, otherIndex)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  vm.execute(machine, touch)
  vm.setWord(machine, c.QC_GLOBAL_SELF, oldSelf)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, oldOther)
  return true
end function

/// Implements the `impact` operation for `miniquake.server_collision` (impact).
/// @param server Server state participating in the operation.
/// @param firstEntity The first entity input consumed by `impact`.
/// @param secondEntity The second entity input consumed by `impact`.
function impact(server, firstEntity, secondEntity)
  // SV_Impact deliberately evaluates the second callback after the first one,
  // even if the first callback freed either edict.  The C engine still holds
  // both edict pointers and tests their current touch/solid fields.  Trigger
  // linking uses executeTouch's validity guard; collision impact must not.
  machine = server.machine
  oldSelf = vm.word(machine, c.QC_GLOBAL_SELF)
  oldOther = vm.word(machine, c.QC_GLOBAL_OTHER)
  vm.setGlobalFloat(machine, c.QC_GLOBAL_TIME, server.time)
  touched = 0
  firstSolid = native.trunc(entityFloat(server, firstEntity, "solid", c.SOLID_NOT))
  firstTouch = entityWord(server, firstEntity, "touch", 0)
  if firstTouch != 0 and firstSolid != c.SOLID_NOT then
    vm.setWord(machine, c.QC_GLOBAL_SELF, firstEntity)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, secondEntity)
    vm.execute(machine, firstTouch)
    touched = touched + 1
  end if
  secondSolid = native.trunc(entityFloat(server, secondEntity, "solid", c.SOLID_NOT))
  secondTouch = entityWord(server, secondEntity, "touch", 0)
  if secondTouch != 0 and secondSolid != c.SOLID_NOT then
    vm.setWord(machine, c.QC_GLOBAL_SELF, secondEntity)
    vm.setWord(machine, c.QC_GLOBAL_OTHER, firstEntity)
    vm.execute(machine, secondTouch)
    touched = touched + 1
  end if
  vm.setWord(machine, c.QC_GLOBAL_SELF, oldSelf)
  vm.setWord(machine, c.QC_GLOBAL_OTHER, oldOther)
  return touched
end function

/// Add state for push entity.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param push The push input consumed by `pushEntity`.
function pushEntity(server, entityIndex, push)
  origin = entityVectorZero(server, entityIndex, "origin")
  mins = entityVectorZero(server, entityIndex, "mins")
  maxs = entityVectorZero(server, entityIndex, "maxs")
  target = math.add(origin, push)
  moveType = c.MOVE_NORMAL
  entityMoveType = native.trunc(entityFloat(server, entityIndex, "movetype", c.MOVETYPE_NONE))
  if entityMoveType == c.MOVETYPE_FLYMISSILE then moveType = c.MOVE_MISSILE end if
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_TRIGGER or solid == c.SOLID_NOT then moveType = c.MOVE_NOMONSTERS end if
  // MOVETYPE_FLYMISSILE takes precedence over the entity's solid type.
  if entityMoveType == c.MOVETYPE_FLYMISSILE then moveType = c.MOVE_MISSILE end if
  trace = move(server, origin, mins, maxs, target, moveType, entityIndex)
  setEntityVector(server, entityIndex, "origin", trace.endPosition)
  linkEntity(server, entityIndex, true)
  if trace.entity >= 0 then impact(server, entityIndex, trace.entity) end if
  return trace
end function

/// Visit only trigger-area nodes intersected by one linked edict.
/// @param server Server state participating in the operation.
/// @param node The node input consumed by `touchAreaNode`.
/// @param entityIndex Zero-based index of the requested entry.
/// @param absMin The abs min input consumed by `touchAreaNode`.
/// @param absMax The abs max input consumed by `touchAreaNode`.
function touchAreaNode(server, node, entityIndex, absMin, absMax)
  if node < 0 or not entityValid(server, entityIndex) then return 0 end if
  touched = 0
  index = areaTriggerHead[node]
  while index >= 0
    next = areaEntityNext[index]
    if index != entityIndex and entityValid(server, index) then
      solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
      if solid == c.SOLID_TRIGGER then
        triggerBounds = linkedEntityBounds(server, index)
        if boxesOverlap(absMin, absMax, triggerBounds[0], triggerBounds[1]) then
          if executeTouch(server, index, entityIndex) then touched = touched + 1 end if
          if not entityValid(server, entityIndex) then return touched end if
        end if
      end if
    end if
    index = next
  end while
  axis = areaNodeAxis[node]
  if axis == -1 then return touched end if
  minimum = absMin.y
  maximum = absMax.y
  if axis == 0 then minimum = absMin.x; maximum = absMax.x end if
  if maximum > areaNodeDist[node] then
    touched = touched + touchAreaNode(server, areaNodeChild0[node], entityIndex, absMin, absMax)
  end if
  if minimum < areaNodeDist[node] and entityValid(server, entityIndex) then
    touched = touched + touchAreaNode(server, areaNodeChild1[node], entityIndex, absMin, absMax)
  end if
  return touched
end function

/// Implements the `touchTriggersWithBounds` operation for `miniquake.server_collision` (touch triggers with bounds).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param absMin The abs min input consumed by `touchTriggersWithBounds`.
/// @param absMax The abs max input consumed by `touchTriggersWithBounds`.
function touchTriggersWithBounds(server, entityIndex, absMin, absMax)
  if ensureAreaTree(server) then return touchAreaNode(server, 0, entityIndex, absMin, absMax) end if
  touched = 0
  runtime = server.machine.context.edicts
  index = 1
  while index < runtime.numEdicts
    if index != entityIndex and not runtime.freeFlags[index] then
      solid = native.trunc(entityFloat(server, index, "solid", c.SOLID_NOT))
      if solid == c.SOLID_TRIGGER then
        triggerBounds = linkedEntityBounds(server, index)
        if boxesOverlap(absMin, absMax, triggerBounds[0], triggerBounds[1]) then
          if executeTouch(server, index, entityIndex) then touched = touched + 1 end if
          // QuakeC is allowed to remove the moving entity from a touch callback.
          if not entityValid(server, entityIndex) then return touched end if
        end if
      end if
    end if
    index = index + 1
  end while
  return touched
end function

/// Linear-scan equivalent of world.c SV_LinkEdict. Area nodes only optimize the
/// candidate set; updated abs bounds, SOLID_NOT suppression and touch ordering
/// are observable parts of the engine contract.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
/// @param touchTriggerLinks The touch trigger links input consumed by `linkEntity`.
function linkEntity(server, entityIndex, touchTriggerLinks)
  if not updateEntityBounds(server, entityIndex) then return false end if
  bounds = linkedEntityBounds(server, entityIndex)
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  relinkAreaEntity(server, entityIndex, bounds, solid)
  if entityIndex < len(server.edicts) and server.edicts[entityIndex] is not void then
    linked = server.edicts[entityIndex]
    linked.leafNums = []
    modelIndex = native.trunc(entityFloat(server, entityIndex, "modelindex", 0.0))
    if modelIndex != 0 and server.worldModel is not void then
      linked.leafNums = world.touchedLeaves(server.worldModel, bounds[0], bounds[1], c.MAX_ENT_LEAFS)
    end if
  end if
  if solid == c.SOLID_NOT then return true end if
  if touchTriggerLinks then
    touchTriggersWithBounds(server, entityIndex, bounds[0], bounds[1])
  end if
  return true
end function

/// Implements the `touchTriggers` operation for `miniquake.server_collision` (touch triggers).
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function touchTriggers(server, entityIndex)
  if not entityValid(server, entityIndex) then return 0 end if
  solid = native.trunc(entityFloat(server, entityIndex, "solid", c.SOLID_NOT))
  if solid == c.SOLID_NOT then return 0 end if
  bounds = linkedEntityBounds(server, entityIndex)
  return touchTriggersWithBounds(server, entityIndex, bounds[0], bounds[1])
end function

/// SV_CheckBottom: first accept the common case where all four lower corners are
/// solid, then trace the midpoint and corners down by two step heights.
/// @param server Server state participating in the operation.
/// @param entityIndex Zero-based index of the requested entry.
function checkBottom(server, entityIndex)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  origin = entityVectorZero(server, entityIndex, "origin")
  mins = entityVectorZero(server, entityIndex, "mins")
  maxs = entityVectorZero(server, entityIndex, "maxs")
  z = origin.z + mins.z - 1.0
  cornersSolid = true
  xIndex = 0
  while xIndex < 2
    yIndex = 0
    while yIndex < 2
      x = origin.x + mins.x
      y = origin.y + mins.y
      if xIndex == 1 then x = origin.x + maxs.x end if
      if yIndex == 1 then y = origin.y + maxs.y end if
      if world.pointContentsWorld(server.worldModel, t.Vec3(x, y, z)) != c.CONTENTS_SOLID then cornersSolid = false end if
      yIndex = yIndex + 1
    end while
    xIndex = xIndex + 1
  end while
  if cornersSolid then return true end if

  midpoint = t.Vec3(origin.x + (mins.x + maxs.x) * 0.5, origin.y + (mins.y + maxs.y) * 0.5, origin.z + mins.z)
  stop = math.subtract(midpoint, t.Vec3(0.0, 0.0, 36.0))
  midTrace = move(server, midpoint, zeroVector(), zeroVector(), stop, c.MOVE_NOMONSTERS, entityIndex)
  if midTrace.fraction == 1.0 then return false end if
  mid = midTrace.endPosition.z

  xIndex = 0
  while xIndex < 2
    yIndex = 0
    while yIndex < 2
      x = origin.x + mins.x
      y = origin.y + mins.y
      if xIndex == 1 then x = origin.x + maxs.x end if
      if yIndex == 1 then y = origin.y + maxs.y end if
      start = t.Vec3(x, y, origin.z + mins.z)
      finish = math.subtract(start, t.Vec3(0.0, 0.0, 36.0))
      cornerTrace = move(server, start, zeroVector(), zeroVector(), finish, c.MOVE_NOMONSTERS, entityIndex)
      if cornerTrace.fraction == 1.0 or mid - cornerTrace.endPosition.z > 18.0 then return false end if
      yIndex = yIndex + 1
    end while
    xIndex = xIndex + 1
  end while
  return true
end function
