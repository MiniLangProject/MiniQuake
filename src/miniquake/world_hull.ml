package miniquake.world_hull

import miniquake.types as t
import miniquake.constants as c
import miniquake.mathlib as math

function createBoxHull(mins, maxs)
  return t.Hull(mins, maxs)
end function

function inside(box, point)
  // world.c's six-node box hull sends points exactly on a maximum plane to
  // CONTENTS_EMPTY, while minimum planes remain part of the solid half-space.
  return point.x >= box.mins.x and point.x < box.maxs.x and
    point.y >= box.mins.y and point.y < box.maxs.y and
    point.z >= box.mins.z and point.z < box.maxs.z
end function

function truePointContents(box, point)
  if inside(box, point) then return c.CONTENTS_SOLID end if
  return c.CONTENTS_EMPTY
end function

function emptyPlane()
  return t.Plane(t.Vec3(0.0, 0.0, 0.0), 0.0, 0, 0)
end function

function traceLine(box, start, finish)
  if inside(box, start) then
    // SV_RecursiveHullCheck permits a move that starts solid to escape into
    // open space.  It reports startsolid, but no impact fraction on the exit.
    if not inside(box, finish) then
      return t.Trace(false, true, true, false, 1.0, finish, emptyPlane(), 0)
    end if
    return t.Trace(true, true, false, false, 1.0, finish, emptyPlane(), 0)
  end if

  entry = 0.0
  exit = 1.0
  hitNormal = t.Vec3(0.0, 0.0, 0.0)
  hitDistance = 0.0
  valid = true

  startValues = [start.x, start.y, start.z]
  endValues = [finish.x, finish.y, finish.z]
  mins = [box.mins.x, box.mins.y, box.mins.z]
  maxs = [box.maxs.x, box.maxs.y, box.maxs.z]

  axis = 0
  while axis < 3 and valid
    delta = endValues[axis] - startValues[axis]
    if delta == 0.0 then
      if startValues[axis] < mins[axis] or startValues[axis] > maxs[axis] then valid = false end if
    else
      nearValue = mins[axis]
      farValue = maxs[axis]
      nearNormal = 0.0
      if delta > 0.0 then
        nearValue = mins[axis] - c.DIST_EPSILON
        farValue = maxs[axis] + c.DIST_EPSILON
        nearNormal = -1.0
      else
        nearValue = maxs[axis] + c.DIST_EPSILON
        farValue = mins[axis] - c.DIST_EPSILON
        nearNormal = 1.0
      end if
      nearTime = (nearValue - startValues[axis]) / delta
      farTime = (farValue - startValues[axis]) / delta
      if nearTime > entry then
        entry = nearTime
        if axis == 0 then hitNormal = t.Vec3(nearNormal, 0.0, 0.0) end if
        if axis == 1 then hitNormal = t.Vec3(0.0, nearNormal, 0.0) end if
        if axis == 2 then hitNormal = t.Vec3(0.0, 0.0, nearNormal) end if
        // The recursive hull trace reports the actual box plane, not the
        // epsilon-shifted impact point used to calculate the safe fraction.
        if delta > 0.0 then hitDistance = -mins[axis] else hitDistance = maxs[axis] end if
      end if
      if farTime < exit then exit = farTime end if
      if entry > exit then valid = false end if
    end if
    axis = axis + 1
  end while

  if not valid or entry < 0.0 or entry > 1.0 then
    return t.Trace(false, false, true, false, 1.0, finish, emptyPlane(), 0)
  end if

  impact = math.multiplyAdd(start, entry, math.subtract(finish, start))
  plane = t.Plane(hitNormal, hitDistance, 0, 0)
  return t.Trace(false, false, true, false, entry, impact, plane, 0)
end function
