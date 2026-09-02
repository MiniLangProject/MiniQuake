/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.world_bsp.
*/
package miniquake.world_bsp

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.format.bsp as bsp
import miniquake.array_util as arrayutil

// The original engine keeps one decompression buffer, but MiniQuake's immutable
// protocol/render consumers otherwise allocate and expand the same leaf row on
// every server frame and whenever the camera enters a new leaf.  Populate this
// map-local table while the loading plaque is visible.
leafPvsCacheMapKey = 0
/// Tracks the module-level leaf pvs cache state owned by `miniquake.world_bsp`.
leafPvsCache = []
/// Tracks the module-level fat pvs scratch map key state owned by `miniquake.world_bsp`.
fatPvsScratchMapKey = 0
/// Tracks the module-level fat pvs scratch state owned by `miniquake.world_bsp`.
fatPvsScratch = bytes()
/// Tracks the module-level collision hull cache map key state owned by `miniquake.world_bsp`.
collisionHullCacheMapKey = 0
/// Tracks the module-level collision hull cache state owned by `miniquake.world_bsp`.
collisionHullCache = []
/// Tracks the module-level model hull cache map key state owned by `miniquake.world_bsp`.
modelHullCacheMapKey = 0
/// Tracks the module-level model hull cache state owned by `miniquake.world_bsp`.
modelHullCache = []

/// Implements the `zeroVector` operation for `miniquake.world_bsp` (zero vector).
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `emptyPlane` operation for `miniquake.world_bsp` (empty plane).
function emptyPlane()
  return t.Plane(zeroVector(), 0.0, 0, 0)
end function

/// Draws ing clip nodes for `miniquake.world_bsp`.
/// @param map The map input consumed by `drawingClipNodes`.
function drawingClipNodes(map)
  result = arrayutil.makeEmptyArray(len(map.nodes))
  index = 0
  while index < len(map.nodes)
    node = map.nodes[index]
    child0 = node.child0
    child1 = node.child1
    // Mod_MakeHull0 converts negative drawing-node children (encoded leaf
    // indexes) into the leaf's CONTENTS_* value.  Treating -1/-2 directly as
    // EMPTY/SOLID happens to compile, but reverses or corrupts arbitrary BSP
    // leaf contents.
    if child0 < 0 then
      leafIndex = -1 - child0
      if leafIndex < 0 or leafIndex >= len(map.leafs) then return error(2507, "Mod_MakeHull0: bad child leaf") end if
      child0 = map.leafs[leafIndex].contents
    end if
    if child1 < 0 then
      leafIndex = -1 - child1
      if leafIndex < 0 or leafIndex >= len(map.leafs) then return error(2507, "Mod_MakeHull0: bad child leaf") end if
      child1 = map.leafs[leafIndex].contents
    end if
    result[index] = t.BspClipNode(node.planeIndex, child0, child1)
    index = index + 1
  end while
  return result
end function

/// Create and initialize hull.
/// @param map The map input consumed by `createHull`.
/// @param hullIndex Zero-based index of the requested entry.
function createHull(map, hullIndex)
  if len(map.models) == 0 then return error(2500, "BSP has no world model") end if
  if hullIndex < 0 or hullIndex > 2 then return error(2501, "invalid BSP hull index") end if
  mapKey = nativeRawValue(map)
  if collisionHullCacheMapKey == mapKey and len(collisionHullCache) == 3 then
    return collisionHullCache[hullIndex]
  end if
  model = map.models[0]
  first = model.headNodes[hullIndex]
  nodes = map.clipNodes
  clipMins = zeroVector()
  clipMaxs = zeroVector()
  if hullIndex == 0 then
    nodes = drawingClipNodes(map)
  else if hullIndex == 1 then
    clipMins = t.Vec3(-16.0, -16.0, -24.0)
    clipMaxs = t.Vec3(16.0, 16.0, 32.0)
  else
    clipMins = t.Vec3(-32.0, -32.0, -24.0)
    clipMaxs = t.Vec3(32.0, 32.0, 64.0)
  end if
  if first < 0 or first >= len(nodes) then return error(2502, "BSP hull headnode is outside clipnode table") end if
  return t.BspCollisionHull(map, nodes, map.planes, first, len(nodes) - 1, clipMins, clipMaxs)
end function

/// Build the three immutable world hull descriptors while the loading plaque
/// is active. Hull zero includes Mod_MakeHull0's expanded drawing nodes and was
/// previously rebuilt for every point trace, producing hundreds of kilobytes
/// of short-lived objects per gameplay frame.
/// @param map The map input consumed by `precacheCollisionHulls`.
function precacheCollisionHulls(map)
  global collisionHullCacheMapKey, collisionHullCache
  global modelHullCacheMapKey, modelHullCache
  if map is void or len(map.models) == 0 then
    collisionHullCacheMapKey = 0
    collisionHullCache = []
    modelHullCacheMapKey = 0
    modelHullCache = []
    return 0
  end if
  collisionHullCacheMapKey = 0
  collisionHullCache = []
  modelHullCacheMapKey = 0
  modelHullCache = []
  hull0 = createHull(map, 0)
  hull1 = createHull(map, 1)
  hull2 = createHull(map, 2)
  collisionHullCacheMapKey = nativeRawValue(map)
  collisionHullCache = [hull0, hull1, hull2]

  // A moving brush trace previously rebuilt its hull descriptor every time.
  // Hull zero was substantially worse: createModelHull also expanded the
  // complete drawing-node table for every door/platform collision. Cache all
  // immutable model/size combinations while the loading plaque is visible.
  modelHullCache = arrayutil.makeEmptyArray(len(map.models) * 3)
  modelIndex = 0
  while modelIndex < len(map.models)
    hullIndex = 0
    while hullIndex < 3
      modelHullCache[modelIndex * 3 + hullIndex] = createModelHull(map, modelIndex, hullIndex)
      hullIndex = hullIndex + 1
    end while
    modelIndex = modelIndex + 1
  end while
  modelHullCacheMapKey = collisionHullCacheMapKey
  return 3
end function

/// Implements the `planeDistance` operation for `miniquake.world_bsp` (plane distance).
/// @param plane The plane input consumed by `planeDistance`.
/// @param point The point input consumed by `planeDistance`.
function planeDistance(plane, point)
  if plane.type == 0 then return point.x - plane.dist end if
  if plane.type == 1 then return point.y - plane.dist end if
  if plane.type == 2 then return point.z - plane.dist end if
  return math.dot(plane.normal, point) - plane.dist
end function

/// Implements the `child` operation for `miniquake.world_bsp` (child).
/// @param node The node input consumed by `child`.
/// @param side The side input consumed by `child`.
function child(node, side)
  if side == 0 then return node.child0 end if
  return node.child1
end function

/// Implements the `pointContentsFromNode` operation for `miniquake.world_bsp` (point contents from node).
/// @param hull The hull input consumed by `pointContentsFromNode`.
/// @param number The number input consumed by `pointContentsFromNode`.
/// @param point The point input consumed by `pointContentsFromNode`.
function pointContentsFromNode(hull, number, point)
  current = number
  while current >= 0
    if current < hull.firstClipNode or current > hull.lastClipNode then return error(2503, "SV_HullPointContents: bad node number") end if
    node = hull.clipNodes[current]
    if node.planeIndex < 0 or node.planeIndex >= len(hull.planes) then return error(2504, "SV_HullPointContents: bad plane number") end if
    plane = hull.planes[node.planeIndex]
    if planeDistance(plane, point) < 0.0 then current = node.child1 else current = node.child0 end if
  end while
  return current
end function

/// Implements the `pointContents` operation for `miniquake.world_bsp` (point contents).
/// @param hull The hull input consumed by `pointContents`.
/// @param point The point input consumed by `pointContents`.
function pointContents(hull, point)
  return pointContentsFromNode(hull, hull.firstClipNode, point)
end function

/// Implements the `recursiveHullCheck` operation for `miniquake.world_bsp` (recursive hull check).
/// @param hull The hull input consumed by `recursiveHullCheck`.
/// @param number The number input consumed by `recursiveHullCheck`.
/// @param p1Fraction The p1 fraction input consumed by `recursiveHullCheck`.
/// @param p2Fraction The p2 fraction input consumed by `recursiveHullCheck`.
/// @param p1 The p1 input consumed by `recursiveHullCheck`.
/// @param p2 The p2 input consumed by `recursiveHullCheck`.
/// @param trace The trace input consumed by `recursiveHullCheck`.
function recursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  if number < 0 then
    if number != c.CONTENTS_SOLID then
      trace.allSolid = false
      if number == c.CONTENTS_EMPTY then trace.inOpen = true else trace.inWater = true end if
    else
      trace.startSolid = true
    end if
    return true
  end if

  if number < hull.firstClipNode or number > hull.lastClipNode then return error(2505, "SV_RecursiveHullCheck: bad node number") end if
  node = hull.clipNodes[number]
  if node.planeIndex < 0 or node.planeIndex >= len(hull.planes) then return error(2506, "SV_RecursiveHullCheck: bad plane number") end if
  plane = hull.planes[node.planeIndex]
  t1 = planeDistance(plane, p1)
  t2 = planeDistance(plane, p2)

  if t1 >= 0.0 and t2 >= 0.0 then
    return recursiveHullCheck(hull, node.child0, p1Fraction, p2Fraction, p1, p2, trace)
  end if
  if t1 < 0.0 and t2 < 0.0 then
    return recursiveHullCheck(hull, node.child1, p1Fraction, p2Fraction, p1, p2, trace)
  end if

  fraction = 0.0
  if t1 < 0.0 then
    fraction = (t1 + c.DIST_EPSILON) / (t1 - t2)
  else
    fraction = (t1 - c.DIST_EPSILON) / (t1 - t2)
  end if
  fraction = math.clamp(fraction, 0.0, 1.0)
  middleFraction = p1Fraction + (p2Fraction - p1Fraction) * fraction
  middle = math.multiplyAdd(p1, fraction, math.subtract(p2, p1))
  side = 0
  if t1 < 0.0 then side = 1 end if

  if not recursiveHullCheck(hull, child(node, side), p1Fraction, middleFraction, p1, middle, trace) then return false end if
  farSide = side ^ 1
  if pointContentsFromNode(hull, child(node, farSide), middle) != c.CONTENTS_SOLID then
    return recursiveHullCheck(hull, child(node, farSide), middleFraction, p2Fraction, middle, p2, trace)
  end if
  if trace.allSolid then return false end if

  if side == 0 then
    trace.plane = t.Plane(math.copy(plane.normal), plane.dist, plane.type, 0)
  else
    trace.plane = t.Plane(math.scale(plane.normal, -1.0), -plane.dist, plane.type, 0)
  end if

  while pointContents(hull, middle) == c.CONTENTS_SOLID
    fraction = fraction - 0.1
    if fraction < 0.0 then
      trace.fraction = middleFraction
      trace.endPosition = middle
      return false
    end if
    middleFraction = p1Fraction + (p2Fraction - p1Fraction) * fraction
    middle = math.multiplyAdd(p1, fraction, math.subtract(p2, p1))
  end while

  trace.fraction = middleFraction
  trace.endPosition = middle
  return false
end function

/// Trace in hull through the collision world.
/// @param hull The hull input consumed by `traceInHull`.
/// @param start The start input consumed by `traceInHull`.
/// @param finish The finish input consumed by `traceInHull`.
function traceInHull(hull, start, finish)
  trace = t.Trace(true, false, false, false, 1.0, math.copy(finish), emptyPlane(), 0)
  recursiveHullCheck(hull, hull.firstClipNode, 0.0, 1.0, start, finish, trace)
  return trace
end function

/// Implements the `hullForBounds` operation for `miniquake.world_bsp` (hull for bounds).
/// @param map The map input consumed by `hullForBounds`.
/// @param mins The mins input consumed by `hullForBounds`.
/// @param maxs The maxs input consumed by `hullForBounds`.
function hullForBounds(map, mins, maxs)
  sizeX = maxs.x - mins.x
  if sizeX < 3.0 then return createHull(map, 0) end if
  if sizeX <= 32.0 then return createHull(map, 1) end if
  return createHull(map, 2)
end function

/// Trace the requested value through the collision world.
/// @param map The map input consumed by `trace`.
/// @param start The start input consumed by `trace`.
/// @param mins The mins input consumed by `trace`.
/// @param maxs The maxs input consumed by `trace`.
/// @param finish The finish input consumed by `trace`.
function trace(map, start, mins, maxs, finish)
  hull = hullForBounds(map, mins, maxs)
  offset = math.subtract(hull.clipMins, mins)
  localStart = math.subtract(start, offset)
  localFinish = math.subtract(finish, offset)
  result = traceInHull(hull, localStart, localFinish)
  result.endPosition = math.add(result.endPosition, offset)
  return result
end function

/// Implements the `traceLine` operation for `miniquake.world_bsp` (trace line).
/// @param map The map input consumed by `traceLine`.
/// @param start The start input consumed by `traceLine`.
/// @param finish The finish input consumed by `traceLine`.
function traceLine(map, start, finish)
  origin = zeroVector()
  return trace(map, start, origin, origin, finish)
end function

/// Implements the `truePointContents` operation for `miniquake.world_bsp` (true point contents).
/// @param map The map input consumed by `truePointContents`.
/// @param point The point input consumed by `truePointContents`.
function truePointContents(map, point)
  if map is void or len(map.models) == 0 or len(map.nodes) == 0 then return error(2513, "Mod_PointInLeaf: bad model") end if
  number = map.models[0].headNodes[0]
  while number >= 0
    if number >= len(map.nodes) then return error(2514, "Mod_PointInLeaf: bad node") end if
    node = map.nodes[number]
    if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return error(2515, "Mod_PointInLeaf: bad plane") end if
    plane = map.planes[node.planeIndex]
    distance = 0.0
    if plane.type == 0 then
      distance = point.x - plane.dist
    else if plane.type == 1 then
      distance = point.y - plane.dist
    else if plane.type == 2 then
      distance = point.z - plane.dist
    else
      distance = point.x * plane.normal.x + point.y * plane.normal.y + point.z * plane.normal.z - plane.dist
    end if
    if distance < 0.0 then number = node.child1 else number = node.child0 end if
  end while
  leafIndex = -1 - number
  if leafIndex < 0 or leafIndex >= len(map.leafs) then return error(2516, "Mod_PointInLeaf: bad leaf") end if
  return map.leafs[leafIndex].contents
end function

/// Implements the `pointContentsWorld` operation for `miniquake.world_bsp` (point contents world).
/// @param map The map input consumed by `pointContentsWorld`.
/// @param point The point input consumed by `pointContentsWorld`.
function pointContentsWorld(map, point)
  contents = truePointContents(map, point)
  if contents <= -9 and contents >= -14 then return c.CONTENTS_WATER end if
  return contents
end function

/// Implements the `leafForPoint` operation for `miniquake.world_bsp` (leaf for point).
/// @param map The map input consumed by `leafForPoint`.
/// @param point The point input consumed by `leafForPoint`.
function leafForPoint(map, point)
  if map is void or len(map.models) == 0 or len(map.nodes) == 0 then return error(2513, "Mod_PointInLeaf: bad model") end if
  number = map.models[0].headNodes[0]
  while number >= 0
    if number >= len(map.nodes) then return error(2514, "Mod_PointInLeaf: bad node") end if
    node = map.nodes[number]
    if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return error(2515, "Mod_PointInLeaf: bad plane") end if
    plane = map.planes[node.planeIndex]
    if planeDistance(plane, point) < 0.0 then number = node.child1 else number = node.child0 end if
  end while
  leafIndex = -1 - number
  if leafIndex < 0 or leafIndex >= len(map.leafs) then return error(2516, "Mod_PointInLeaf: bad leaf") end if
  return leafIndex
end function

/// Mirror Quake's Mod_PointInLeaf routine and its observable state changes.
/// @param point The point input consumed by `Mod_PointInLeaf`.
/// @param map The map input consumed by `Mod_PointInLeaf`.
function Mod_PointInLeaf(point, map)
  return leafForPoint(map, point)
end function

/// Decompress one leaf visibility row without consulting the level cache.
/// @param map The map input consumed by `decompressLeafPvs`.
/// @param leafIndex Zero-based index of the requested entry.
function decompressLeafPvs(map, leafIndex)
  if map is void then return bytes() end if
  rowBytes = 0
  // Quake's Mod_DecompressVis uses integer ceiling division:
  // (numleafs + 7) >> 3.  MiniLang '/' may produce a float when the
  // division is not exact, which is not a valid bytes() size.
  if len(map.models) > 0 then rowBytes = (map.models[0].visibleLeafs + 7) >> 3 end if
  if rowBytes <= 0 then return bytes() end if
  if leafIndex <= 0 or leafIndex >= len(map.leafs) then return bytes(rowBytes, 255) end if
  leaf = map.leafs[leafIndex]
  if leaf.visibilityOffset < 0 then return bytes(rowBytes, 255) end if
  // Small external BSP29 models have an empty visibility lump with visofs 0.
  // They are not normally queried as a world PVS, but retain GLQuake's safe
  // all-visible fallback if a caller does query one.
  if len(map.visibility) == 0 then return bytes(rowBytes, 255) end if
  return bsp.decompressVisibility(map.visibility, leaf.visibilityOffset, rowBytes)
end function

/// Pre-expand all visibility rows before gameplay starts.
/// @param map The map input consumed by `precacheLeafPvs`.
function precacheLeafPvs(map)
  global leafPvsCacheMapKey, leafPvsCache, fatPvsScratchMapKey, fatPvsScratch
  if map is void then leafPvsCacheMapKey = 0; leafPvsCache = []; fatPvsScratchMapKey = 0; fatPvsScratch = bytes(); return 0 end if
  leafPvsCacheMapKey = nativeRawValue(map)
  leafPvsCache = arrayutil.makeEmptyArray(len(map.leafs))
  index = 0
  while index < len(map.leafs)
    leafPvsCache[index] = decompressLeafPvs(map, index)
    index = index + 1
  end while
  fatPvsScratchMapKey = leafPvsCacheMapKey
  fatPvsScratch = bytes((map.models[0].visibleLeafs + 31) >> 3)
  return len(leafPvsCache)
end function

/// Implements the `leafPvs` operation for `miniquake.world_bsp` (leaf pvs).
/// @param map The map input consumed by `leafPvs`.
/// @param leafIndex Zero-based index of the requested entry.
function leafPvs(map, leafIndex)
  if map is not void and nativeRawValue(map) == leafPvsCacheMapKey and
      leafIndex >= 0 and leafIndex < len(leafPvsCache) and
      leafPvsCache[leafIndex] is not void then
    return leafPvsCache[leafIndex]
  end if
  return decompressLeafPvs(map, leafIndex)
end function

/// Mirror Quake's Mod_LeafPVS routine and its observable state changes.
/// @param leafIndex Zero-based index of the requested entry.
/// @param map The map input consumed by `Mod_LeafPVS`.
function Mod_LeafPVS(leafIndex, map)
  return leafPvs(map, leafIndex)
end function

/// Return the pre-expanded world-face visibility mask for one view leaf.
/// Report whether leaf visible holds for the active state.
/// @param pvs The pvs input consumed by `leafVisible`.
/// @param leafIndex Zero-based index of the requested entry.
function leafVisible(pvs, leafIndex)
  if leafIndex <= 0 then return true end if
  bitIndex = leafIndex - 1
  byteIndex = bitIndex >> 3
  if byteIndex < 0 or byteIndex >= len(pvs) then return false end if
  return (pvs[byteIndex] & (1 << (bitIndex & 7))) != 0
end function

/// SV_FindTouchedLeafs stores every non-solid world leaf intersected by an
/// entity's linked abs bounds (up to MAX_ENT_LEAFS).  Large doors and moving
/// walls often have their origin in a different PVS from the face seen by the
/// player, so testing only Mod_PointInLeaf(origin) makes a physically present
/// brush model disappear.
/// @param mins The mins input consumed by `boxOnBspPlaneSide`.
/// @param maxs The maxs input consumed by `boxOnBspPlaneSide`.
/// @param plane The plane input consumed by `boxOnBspPlaneSide`.
function boxOnBspPlaneSide(mins, maxs, plane)
  if plane.type == 0 then
    if plane.dist <= mins.x then return 1 end if
    if plane.dist >= maxs.x then return 2 end if
    return 3
  end if
  if plane.type == 1 then
    if plane.dist <= mins.y then return 1 end if
    if plane.dist >= maxs.y then return 2 end if
    return 3
  end if
  if plane.type == 2 then
    if plane.dist <= mins.z then return 1 end if
    if plane.dist >= maxs.z then return 2 end if
    return 3
  end if
  positive = t.Vec3(mins.x, mins.y, mins.z)
  negative = t.Vec3(maxs.x, maxs.y, maxs.z)
  if plane.normal.x >= 0.0 then positive.x = maxs.x; negative.x = mins.x end if
  if plane.normal.y >= 0.0 then positive.y = maxs.y; negative.y = mins.y end if
  if plane.normal.z >= 0.0 then positive.z = maxs.z; negative.z = mins.z end if
  sides = 0
  if math.dot(plane.normal, positive) >= plane.dist then sides = sides | 1 end if
  if math.dot(plane.normal, negative) < plane.dist then sides = sides | 2 end if
  return sides
end function

/// Add state for append touched leaves.
/// @param map The map input consumed by `appendTouchedLeaves`.
/// @param nodeNumber The node number input consumed by `appendTouchedLeaves`.
/// @param mins The mins input consumed by `appendTouchedLeaves`.
/// @param maxs The maxs input consumed by `appendTouchedLeaves`.
/// @param limit The limit input consumed by `appendTouchedLeaves`.
/// @param result Result value to report or translate into a status code.
function appendTouchedLeaves(map, nodeNumber, mins, maxs, limit, result)
  if len(result) >= limit then return result end if
  if nodeNumber < 0 then
    leafIndex = -1 - nodeNumber
    if leafIndex < 0 or leafIndex >= len(map.leafs) then return result end if
    if map.leafs[leafIndex].contents != c.CONTENTS_SOLID then result = result + [leafIndex] end if
    return result
  end if
  if nodeNumber >= len(map.nodes) then return result end if
  node = map.nodes[nodeNumber]
  if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return result end if
  sides = boxOnBspPlaneSide(mins, maxs, map.planes[node.planeIndex])
  if (sides & 1) != 0 then result = appendTouchedLeaves(map, node.child0, mins, maxs, limit, result) end if
  if (sides & 2) != 0 and len(result) < limit then result = appendTouchedLeaves(map, node.child1, mins, maxs, limit, result) end if
  return result
end function

/// Implements the `touchedLeaves` operation for `miniquake.world_bsp` (touched leaves).
/// @param map The map input consumed by `touchedLeaves`.
/// @param mins The mins input consumed by `touchedLeaves`.
/// @param maxs The maxs input consumed by `touchedLeaves`.
/// @param limit The limit input consumed by `touchedLeaves`.
function touchedLeaves(map, mins, maxs, limit)
  if map is void or len(map.models) == 0 or len(map.nodes) == 0 or limit <= 0 then return [] end if
  return appendTouchedLeaves(map, map.models[0].headNodes[0], mins, maxs, limit, [])
end function

/// Report whether any leaf visible holds for the active state.
/// @param pvs The pvs input consumed by `anyLeafVisible`.
/// @param leaves The leaves input consumed by `anyLeafVisible`.
function anyLeafVisible(pvs, leaves)
  for each leafIndex in leaves
    if leafVisible(pvs, leafIndex) then return true end if
  end for
  return false
end function

/// Implements the `orVisibility` operation for `miniquake.world_bsp` (or visibility).
/// @param destination Destination value or collection to update.
/// @param source Source value or collection to read.
function orVisibility(destination, source)
  limit = len(destination)
  if len(source) < limit then limit = len(source) end if
  index = 0
  while index < limit
    destination[index] = destination[index] | source[index]
    index = index + 1
  end while
  return destination
end function

/// Add state for add to fat pvs.
/// @param map The map input consumed by `addToFatPvs`.
/// @param origin World-space origin of the operation.
/// @param nodeNumber The node number input consumed by `addToFatPvs`.
/// @param destination Destination value or collection to update.
function addToFatPvs(map, origin, nodeNumber, destination)
  current = nodeNumber
  while true
    if current < 0 then
      leafIndex = -1 - current
      if leafIndex > 0 and leafIndex < len(map.leafs) and map.leafs[leafIndex].contents != c.CONTENTS_SOLID then
        orVisibility(destination, leafPvs(map, leafIndex))
      end if
      return destination
    end if
    if current >= len(map.nodes) then return destination end if
    node = map.nodes[current]
    if node.planeIndex < 0 or node.planeIndex >= len(map.planes) then return destination end if
    distance = planeDistance(map.planes[node.planeIndex], origin)
    if distance > 8.0 then
      current = node.child0
    else if distance < -8.0 then
      current = node.child1
    else
      addToFatPvs(map, origin, node.child0, destination)
      current = node.child1
    end if
  end while
end function

/// SV_FatPVS merges the PVS on both sides of planes within eight units of the
/// view point.  This prevents entities on a doorway/portal boundary from
/// blinking out as the camera crosses it.
/// @param map The map input consumed by `fatPvs`.
/// @param origin World-space origin of the operation.
function fatPvs(map, origin)
  global fatPvsScratchMapKey, fatPvsScratch
  if map is void or len(map.models) == 0 then return bytes() end if
  count = (map.models[0].visibleLeafs + 31) >> 3
  if count < 1 then count = 1 end if
  mapKey = nativeRawValue(map)
  if fatPvsScratchMapKey != mapKey or len(fatPvsScratch) != count then
    fatPvsScratchMapKey = mapKey
    fatPvsScratch = bytes(count)
  else
    index = 0
    while index < count
      fatPvsScratch[index] = 0
      index = index + 1
    end while
  end if
  result = fatPvsScratch
  if len(map.nodes) == 0 then
    index = 0
    while index < count
      result[index] = 255
      index = index + 1
    end while
    return result
  end if
  return addToFatPvs(map, origin, map.models[0].headNodes[0], result)
end function

/// Return player start.
/// @param map The map input consumed by `findPlayerStart`.
function findPlayerStart(map)
  for each entity in map.entities
    classname = bsp.entityValue(entity, "classname")
    if classname == "info_player_start" then
      origin = bsp.entityVector(entity, "origin")
      angle = toNumber(bsp.entityValue(entity, "angle"))
      if angle is void then angle = 0.0 end if
      return [origin, t.Vec3(0.0, angle, 0.0)]
    end if
  end for
  for each entity in map.entities
    if bsp.entityValue(entity, "classname") == "info_player_deathmatch" then
      origin = bsp.entityVector(entity, "origin")
      angle = toNumber(bsp.entityValue(entity, "angle"))
      if angle is void then angle = 0.0 end if
      return [origin, t.Vec3(0.0, angle, 0.0)]
    end if
  end for
  return [t.Vec3(0.0, 0.0, 64.0), zeroVector()]
end function

/// Original WinQuake naming aliases used by the host, QuakeC builtins and GL
/// renderer.  Keeping these at the world boundary avoids duplicating hull rules.
/// @param map The map input consumed by `playerHull`.
function playerHull(map)
  return createHull(map, 1)
end function

/// Trace point through the collision world.
/// @param map The map input consumed by `tracePoint`.
/// @param start The start input consumed by `tracePoint`.
/// @param finish The finish input consumed by `tracePoint`.
function tracePoint(map, start, finish)
  return traceLine(map, start, finish)
end function

/// Trace player through the collision world.
/// @param map The map input consumed by `tracePlayer`.
/// @param start The start input consumed by `tracePlayer`.
/// @param finish The finish input consumed by `tracePlayer`.
function tracePlayer(map, start, finish)
  return trace(
    map,
    start,
    t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z),
    t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z),
    finish,
  )
end function

/// Implements the `worldPointContents` operation for `miniquake.world_bsp` (world point contents).
/// @param map The map input consumed by `worldPointContents`.
/// @param point The point input consumed by `worldPointContents`.
function worldPointContents(map, point)
  return pointContentsWorld(map, point)
end function

/// Implements the `pointLeaf` operation for `miniquake.world_bsp` (point leaf).
/// @param map The map input consumed by `pointLeaf`.
/// @param point The point input consumed by `pointLeaf`.
function pointLeaf(map, point)
  return leafForPoint(map, point)
end function

/// -----------------------------------------------------------------------------
/// Server brush-model collision. WinQuake selects the hull from the moving
/// object's width, then uses the headnode of the addressed BSP submodel.  This
/// is what makes func_door, func_plat, func_train and other SOLID_BSP entities
/// participate in the same exact collision path as the world.
/// -----------------------------------------------------------------------------
/// @param mins The mins input consumed by `hullIndexForBounds`.
/// @param maxs The maxs input consumed by `hullIndexForBounds`.

function hullIndexForBounds(mins, maxs)
  sizeX = maxs.x - mins.x
  if sizeX < 3.0 then return 0 end if
  if sizeX <= 32.0 then return 1 end if
  return 2
end function

/// Create and initialize model hull.
/// @param map The map input consumed by `createModelHull`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param hullIndex Zero-based index of the requested entry.
function createModelHull(map, modelIndex, hullIndex)
  if modelIndex < 0 or modelIndex >= len(map.models) then return error(2510, "bad BSP submodel index") end if
  if hullIndex < 0 or hullIndex > 2 then return error(2511, "bad BSP hull index") end if
  mapKey = nativeRawValue(map)
  cacheIndex = modelIndex * 3 + hullIndex
  if modelHullCacheMapKey == mapKey and len(modelHullCache) == len(map.models) * 3 then
    return modelHullCache[cacheIndex]
  end if
  model = map.models[modelIndex]
  first = model.headNodes[hullIndex]
  nodes = map.clipNodes
  clipMins = zeroVector()
  clipMaxs = zeroVector()
  if hullIndex == 0 then
    // The drawing-node conversion is identical for every submodel. Reuse the
    // map's precached hull-zero node table while the per-model cache is built.
    if collisionHullCacheMapKey == mapKey and len(collisionHullCache) == 3 then
      nodes = collisionHullCache[0].clipNodes
    else
      nodes = drawingClipNodes(map)
    end if
  else if hullIndex == 1 then
    clipMins = t.Vec3(-16.0, -16.0, -24.0)
    clipMaxs = t.Vec3(16.0, 16.0, 32.0)
  else
    clipMins = t.Vec3(-32.0, -32.0, -24.0)
    clipMaxs = t.Vec3(32.0, 32.0, 64.0)
  end if
  if first < 0 or first >= len(nodes) then return error(2512, "BSP submodel headnode is outside clipnode table") end if
  return t.BspCollisionHull(map, nodes, map.planes, first, len(nodes) - 1, clipMins, clipMaxs)
end function

/// Trace brush model through the collision world.
/// @param map The map input consumed by `traceBrushModel`.
/// @param modelIndex Zero-based index of the requested entry.
/// @param entityOrigin The entity origin input consumed by `traceBrushModel`.
/// @param start The start input consumed by `traceBrushModel`.
/// @param mins The mins input consumed by `traceBrushModel`.
/// @param maxs The maxs input consumed by `traceBrushModel`.
/// @param finish The finish input consumed by `traceBrushModel`.
function traceBrushModel(map, modelIndex, entityOrigin, start, mins, maxs, finish)
  hullIndex = hullIndexForBounds(mins, maxs)
  hull = createModelHull(map, modelIndex, hullIndex)
  offset = math.add(math.subtract(hull.clipMins, mins), entityOrigin)
  localStart = math.subtract(start, offset)
  localFinish = math.subtract(finish, offset)
  result = traceInHull(hull, localStart, localFinish)
  if result.fraction == 1.0 then
    // A clear brush trace reports the caller's original world-space end.
    result.endPosition = math.copy(finish)
  else
    result.endPosition = math.add(result.endPosition, offset)
  end if
  return result
end function

/// Return absolute value derived from the active module state.
/// @param value Value consumed by `absoluteValue`.
function absoluteValue(value)
  if value < 0.0 then return -value end if
  return value
end function

/// Implements the `RadiusFromBounds` operation for `miniquake.world_bsp` (radius from bounds).
/// @param mins The mins input consumed by `RadiusFromBounds`.
/// @param maxs The maxs input consumed by `RadiusFromBounds`.
function RadiusFromBounds(mins, maxs)
  x = absoluteValue(mins.x)
  if absoluteValue(maxs.x) > x then x = absoluteValue(maxs.x) end if
  y = absoluteValue(mins.y)
  if absoluteValue(maxs.y) > y then y = absoluteValue(maxs.y) end if
  z = absoluteValue(mins.z)
  if absoluteValue(maxs.z) > z then z = absoluteValue(maxs.z) end if
  return math.length(t.Vec3(x, y, z))
end function

/// Mirror Quake's Mod_MakeHull0 routine and its observable state changes.
/// @param map The map input consumed by `Mod_MakeHull0`.
function Mod_MakeHull0(map)
  return drawingClipNodes(map)
end function
