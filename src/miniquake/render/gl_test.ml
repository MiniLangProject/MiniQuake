/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang counterpart of the optional GLTEST renderer in gl_test.c.
*/
package miniquake.render.gl_test

import miniquake.types as t
import miniquake.mathlib as math
import miniquake.world_bsp as world
import miniquake.render.gl11 as gl

/// Defines the max puffs value used by `miniquake.render.gl_test`.
const MAX_PUFFS = 64

// Group the fields that describe one test puff.
struct TestPuff
  /// Stores the plane value in `miniquake.render.gl_test.TestPuff`.
  plane
  /// Stores the origin value in `miniquake.render.gl_test.TestPuff`.
  origin
  /// Stores the normal value in `miniquake.render.gl_test.TestPuff`.
  normal
  /// Stores the up value in `miniquake.render.gl_test.TestPuff`.
  up
  /// Stores the right value in `miniquake.render.gl_test.TestPuff`.
  right
  /// Stores the reflect value in `miniquake.render.gl_test.TestPuff`.
  reflect
  /// Stores the length value in `miniquake.render.gl_test.TestPuff`.
  length
end struct

// Track mutable GL test state across subsystem calls.
struct GlTestState
  /// Stores the puffs value in `miniquake.render.gl_test.GlTestState`.
  puffs
  /// Stores the world map value in `miniquake.render.gl_test.GlTestState`.
  worldMap
  /// Stores the view origin value in `miniquake.render.gl_test.GlTestState`.
  viewOrigin
  /// Stores the frame time value in `miniquake.render.gl_test.GlTestState`.
  frameTime
  /// Stores the draw native value in `miniquake.render.gl_test.GlTestState`.
  drawNative
  /// Stores the hit plane override value in `miniquake.render.gl_test.GlTestState`.
  hitPlaneOverride
  /// Stores the command trace value in `miniquake.render.gl_test.GlTestState`.
  commandTrace
end struct

/// Tracks the module-level renderer test state owned by `miniquake.render.gl_test`.
testState = void

/// Implements the `zeroVector` operation for `miniquake.render.gl_test` (zero vector).
function zeroVector()
  return t.Vec3(0.0, 0.0, 0.0)
end function

/// Implements the `emptyPlane` operation for `miniquake.render.gl_test` (empty plane).
function emptyPlane()
  return t.Plane(zeroVector(), 0.0, 0, 0)
end function

/// Implements the `emptyPuff` operation for `miniquake.render.gl_test` (empty puff).
function emptyPuff()
  return TestPuff(emptyPlane(), zeroVector(), zeroVector(), zeroVector(), zeroVector(), zeroVector(), 0.0)
end function

/// Creates state for `miniquake.render.gl_test`.
function createState()
  puffs = []
  index = 0
  while index < MAX_PUFFS
    puffs = puffs + [emptyPuff()]
    index = index + 1
  end while
  return GlTestState(puffs, void, zeroVector(), 0.0, false, void, [])
end function

/// Verify use state against the expected Quake behavior.
/// @param state Mutable `miniquake.render.gl_test` state used by `Test_UseState`.
function Test_UseState(state)
  global testState
  testState = state
  return state
end function

// Verify state against the expected Quake behavior.
function Test_State()
  global testState
  if testState is void then testState = createState() end if
  return testState
end function

/// Verify configure against the expected Quake behavior.
/// @param worldMap The world map input consumed by `Test_Configure`.
/// @param viewOrigin The view origin input consumed by `Test_Configure`.
/// @param frameTime Time value used by the operation.
/// @param drawNative The draw native input consumed by `Test_Configure`.
function Test_Configure(worldMap, viewOrigin, frameTime, drawNative)
  state = Test_State()
  state.worldMap = worldMap
  state.viewOrigin = math.VectorCopy(viewOrigin)
  state.frameTime = frameTime
  state.drawNative = drawNative
  return state
end function

// Verify init against the expected Quake behavior.
function Test_Init()
  state = Test_State()
  index = 0
  while index < MAX_PUFFS
    state.puffs[index] = emptyPuff()
    index = index + 1
  end while
  state.commandTrace = []
  return true
end function

/// Implements the `HitPlane` operation for `miniquake.render.gl_test` (hit plane).
/// @param start The start input consumed by `HitPlane`.
/// @param finish The finish input consumed by `HitPlane`.
function HitPlane(start, finish)
  state = Test_State()
  if state.hitPlaneOverride is not void then return state.hitPlaneOverride end if
  if state.worldMap is void then return emptyPlane() end if
  traced = try(world.traceLine(state.worldMap, start, finish))
  if traced is error then return emptyPlane() end if
  return t.Plane(math.VectorCopy(traced.plane.normal), traced.plane.dist, traced.plane.type, traced.plane.signBits)
end function

/// Verify spawn against the expected Quake behavior.
/// @param origin World-space origin of the operation.
function Test_Spawn(origin)
  state = Test_State()
  index = 0
  while index < MAX_PUFFS and state.puffs[index].length > 0.0
    index = index + 1
  end while
  if index == MAX_PUFFS then return false end if

  puff = state.puffs[index]
  incoming = math.VectorSubtract(state.viewOrigin, origin)
  finish = math.VectorSubtract(origin, incoming)
  plane = HitPlane(state.viewOrigin, finish)
  math.VectorNormalize(incoming)
  distance = math.DotProduct(incoming, plane.normal)
  reflected = math.VectorScale(incoming, -1.0)
  reflected = math.VectorMA(reflected, distance * 2.0, plane.normal)

  puff.plane = plane
  puff.origin = math.VectorCopy(origin)
  puff.normal = math.VectorCopy(plane.normal)
  puff.reflect = reflected
  puff.up = math.CrossProduct(incoming, puff.normal)
  puff.right = math.CrossProduct(puff.up, puff.normal)
  puff.length = 8.0
  return index
end function

/// Implements the `puffPoints` operation for `miniquake.render.gl_test` (puff points).
/// @param puff The puff input consumed by `puffPoints`.
function puffPoints(puff)
  points = []
  layer = 0
  while layer < 2
    size = 2.0
    distance = 0.0
    if layer == 1 then size = 6.0; distance = puff.length end if
    upPoint = math.VectorAdd(puff.origin, math.VectorAdd(math.VectorScale(puff.up, size), math.VectorScale(puff.reflect, distance)))
    rightPoint = math.VectorAdd(puff.origin, math.VectorAdd(math.VectorScale(puff.right, size), math.VectorScale(puff.reflect, distance)))
    leftPoint = math.VectorAdd(puff.origin, math.VectorAdd(math.VectorScale(puff.right, -size), math.VectorScale(puff.reflect, distance)))
    points = points + [[upPoint, rightPoint, leftPoint]]
    layer = layer + 1
  end while
  return points
end function

/// Add vertex to the destination state.
/// @param point The point input consumed by `emitVertex`.
/// @param drawNative The draw native input consumed by `emitVertex`.
function emitVertex(point, drawNative)
  if drawNative then gl.vertex3(point.x, point.y, point.z) end if
  return [point.x, point.y, point.z]
end function

/// Render puff.
/// @param puff The puff input consumed by `DrawPuff`.
function DrawPuff(puff)
  state = Test_State()
  points = puffPoints(puff)
  quads = []
  if state.drawNative then gl.color(255, 0, 0, 255); gl.begin(gl.GL_QUADS) end if
  index = 0
  while index < 3
    next = (index + 1) % 3
    quads = quads + [
      emitVertex(points[0][next], state.drawNative),
      emitVertex(points[1][next], state.drawNative),
      emitVertex(points[1][index], state.drawNative),
      emitVertex(points[0][index], state.drawNative),
    ]
    index = index + 1
  end while
  if state.drawNative then gl.finishPrimitive(); gl.begin(gl.GL_TRIANGLES) end if
  triangle = [
    emitVertex(points[1][0], state.drawNative),
    emitVertex(points[1][1], state.drawNative),
    emitVertex(points[1][2], state.drawNative),
  ]
  if state.drawNative then gl.finishPrimitive() end if
  trace = ["puff", quads, triangle, puff.length]
  puff.length = puff.length - state.frameTime * 2.0
  return trace
end function

// Verify draw against the expected Quake behavior.
function Test_Draw()
  state = Test_State()
  commands = []
  index = 0
  while index < MAX_PUFFS
    if state.puffs[index].length > 0.0 then commands = commands + [DrawPuff(state.puffs[index])] end if
    index = index + 1
  end while
  state.commandTrace = commands
  return commands
end function

// Verify command trace against the expected Quake behavior.
function Test_CommandTrace()
  return Test_State().commandTrace
end function
