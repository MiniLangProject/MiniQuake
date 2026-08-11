package miniquake.world_bsp

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math
import miniquake.format.bsp as bsp
import miniquake.array_util as arrayutil

function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

function emptyPlane()
  return t.Plane(zeroVector(), 0.0, 0, 0)
end function

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

function createHull(map, hullIndex)
  if len(map.models) == 0 then return error(2500, "BSP has no world model") end if
  if hullIndex < 0 or hullIndex > 2 then return error(2501, "invalid BSP hull index") end if
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

function planeDistance(plane, point)
  if plane.type == 0 then return point.x - plane.dist end if
  if plane.type == 1 then return point.y - plane.dist end if
  if plane.type == 2 then return point.z - plane.dist end if
  return math.dot(plane.normal, point) - plane.dist
end function

function child(node, side)
  if side == 0 then return node.child0 end if
  return node.child1
end function

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

function pointContents(hull, point)
  return pointContentsFromNode(hull, hull.firstClipNode, point)
end function

function recursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
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

function traceInHull(hull, start, finish)
  trace = t.Trace(true, false, false, false, 1.0, math.copy(finish), emptyPlane(), 0)
  recursiveHullCheck(hull, hull.firstClipNode, 0.0, 1.0, start, finish, trace)
  return trace
end function

function hullForBounds(map, mins, maxs)
  sizeX = maxs.x - mins.x
  if sizeX < 3.0 then return createHull(map, 0) end if
  if sizeX <= 32.0 then return createHull(map, 1) end if
  return createHull(map, 2)
end function

function trace(map, start, mins, maxs, finish)
  hull = hullForBounds(map, mins, maxs)
  offset = math.subtract(hull.clipMins, mins)
  localStart = math.subtract(start, offset)
  localFinish = math.subtract(finish, offset)
  result = traceInHull(hull, localStart, localFinish)
  result.endPosition = math.add(result.endPosition, offset)
  return result
end function

function traceLine(map, start, finish)
  origin = zeroVector()
  return trace(map, start, origin, origin, finish)
end function

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

function pointContentsWorld(map, point)
  contents = truePointContents(map, point)
  if contents <= -9 and contents >= -14 then return c.CONTENTS_WATER end if
  return contents
end function

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

function Mod_PointInLeaf(point, map)
  return leafForPoint(map, point)
end function

function leafPvs(map, leafIndex)
  rowBytes = 0
  // Quake's Mod_DecompressVis uses integer ceiling division:
  // (numleafs + 7) >> 3.  MiniLang '/' may produce a float when the
  // division is not exact, which is not a valid bytes() size.
  if len(map.models) > 0 then rowBytes = (map.models[0].visibleLeafs + 7) >> 3 end if
  if rowBytes <= 0 then return bytes() end if
  if leafIndex <= 0 or leafIndex >= len(map.leafs) then return bytes(rowBytes, 255) end if
  leaf = map.leafs[leafIndex]
  if leaf.visibilityOffset < 0 then return bytes(rowBytes, 255) end if
  return bsp.decompressVisibility(map.visibility, leaf.visibilityOffset, rowBytes)
end function

function Mod_LeafPVS(leafIndex, map)
  return leafPvs(map, leafIndex)
end function

function leafVisible(pvs, leafIndex)
  if leafIndex <= 0 then return true end if
  bitIndex = leafIndex - 1
  byteIndex = bitIndex >> 3
  if byteIndex < 0 or byteIndex >= len(pvs) then return false end if
  return (pvs[byteIndex] & (1 << (bitIndex & 7))) != 0
end function

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

// Original WinQuake naming aliases used by the host, QuakeC builtins and GL
// renderer.  Keeping these at the world boundary avoids duplicating hull rules.
function playerHull(map)
  return createHull(map, 1)
end function

function tracePoint(map, start, finish)
  return traceLine(map, start, finish)
end function

function tracePlayer(map, start, finish)
  return trace(
    map,
    start,
    t.Vec3(c.PLAYER_MINS_X, c.PLAYER_MINS_Y, c.PLAYER_MINS_Z),
    t.Vec3(c.PLAYER_MAXS_X, c.PLAYER_MAXS_Y, c.PLAYER_MAXS_Z),
    finish,
  )
end function

function worldPointContents(map, point)
  return pointContentsWorld(map, point)
end function

function pointLeaf(map, point)
  return leafForPoint(map, point)
end function

// -----------------------------------------------------------------------------
// Server brush-model collision. WinQuake selects the hull from the moving
// object's width, then uses the headnode of the addressed BSP submodel.  This
// is what makes func_door, func_plat, func_train and other SOLID_BSP entities
// participate in the same exact collision path as the world.
// -----------------------------------------------------------------------------

function hullIndexForBounds(mins, maxs)
  sizeX = maxs.x - mins.x
  if sizeX < 3.0 then return 0 end if
  if sizeX <= 32.0 then return 1 end if
  return 2
end function

function createModelHull(map, modelIndex, hullIndex)
  if modelIndex < 0 or modelIndex >= len(map.models) then return error(2510, "bad BSP submodel index") end if
  if hullIndex < 0 or hullIndex > 2 then return error(2511, "bad BSP hull index") end if
  model = map.models[modelIndex]
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
  if first < 0 or first >= len(nodes) then return error(2512, "BSP submodel headnode is outside clipnode table") end if
  return t.BspCollisionHull(map, nodes, map.planes, first, len(nodes) - 1, clipMins, clipMaxs)
end function

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

function absoluteValue(value)
  if value < 0.0 then return -value end if
  return value
end function

function RadiusFromBounds(mins, maxs)
  x = absoluteValue(mins.x)
  if absoluteValue(maxs.x) > x then x = absoluteValue(maxs.x) end if
  y = absoluteValue(mins.y)
  if absoluteValue(maxs.y) > y then y = absoluteValue(maxs.y) end if
  z = absoluteValue(mins.z)
  if absoluteValue(maxs.z) > z then z = absoluteValue(maxs.z) end if
  return math.length(t.Vec3(x, y, z))
end function

function Mod_MakeHull0(map)
  return drawingClipNodes(map)
end function
