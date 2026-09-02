/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.map_viewer.
*/
package miniquake.map_viewer

import miniquake.format.bsp as bsp
import miniquake.filesystem as qfs
import miniquake.platform.win32 as win
import miniquake.render.gl11 as gl
import miniquake.native as native
import std.fs as fs

/// Implements the `faceVertex` operation for `miniquake.map_viewer` (face vertex).
/// @param map The map input consumed by `faceVertex`.
/// @param surfEdgeIndex Zero-based index of the requested entry.
function faceVertex(map, surfEdgeIndex)
  if surfEdgeIndex < 0 or surfEdgeIndex >= len(map.surfEdges) then return void end if
  signedEdge = map.surfEdges[surfEdgeIndex]
  edgeIndex = signedEdge
  if edgeIndex < 0 then edgeIndex = -edgeIndex end if
  if edgeIndex < 0 or edgeIndex >= len(map.edges) then return void end if
  edge = map.edges[edgeIndex]
  vertexIndex = edge.vertex0
  if signedEdge < 0 then vertexIndex = edge.vertex1 end if
  if vertexIndex < 0 or vertexIndex >= len(map.vertices) then return void end if
  return map.vertices[vertexIndex].position
end function

/// Render map.
/// @param map The map input consumed by `drawMap`.
function drawMap(map)
  gl.color(220, 220, 220, 255)
  for each face in map.faces
    if face.numEdges >= 2 then
      gl.begin(gl.GL_LINE_LOOP)
      i = 0
      while i < face.numEdges
        position = faceVertex(map, face.firstEdge + i)
        if position is not void then gl.vertex3(position.x, position.y, position.z) end if
        i = i + 1
      end while
      gl.finishPrimitive()
    end if
  end for
end function

/// Implements the `render` operation for `miniquake.map_viewer` (render).
/// @param map The map input consumed by `render`.
/// @param angle The angle input consumed by `render`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function render(map, angle, width, height)
  if height <= 0 then height = 1 end if
  aspect = width / height
  gl.viewport(0, 0, width, height)
  gl.clearColor(0.025, 0.03, 0.04, 1.0)
  gl.clear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT)
  gl.enable(gl.GL_DEPTH_TEST)
  gl.depthFunc(gl.GL_LEQUAL)
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  nearValue = 4.0
  top = 2.0
  gl.frustum(-top * aspect, top * aspect, -top, top, nearValue, 8192.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.translate(0.0, 0.0, -900.0)
  gl.rotate(65.0, 1.0, 0.0, 0.0)
  gl.rotate(angle, 0.0, 0.0, 1.0)
  drawMap(map)
end function

/// Execute map.
/// @param map The map input consumed by `runMap`.
/// @param title The title input consumed by `runMap`.
function runMap(map, title)
  win.create(title, 1280, 720, 0)
  win.captureMouse(false)
  start = win.ticks()
  running = true
  while running
    running = win.poll()
    if win.keyDown(27) then running = false end if
    elapsed = win.ticks() - start
    angle = elapsed * 0.02
    render(map, angle, win.width(), win.height())
    win.swap()
    win.sleep(1)
  end while
  win.destroy()
  return 0
end function

/// Execute direct.
/// @param bspFilename Name that identifies the requested value or resource.
/// @param paletteFilename Name that identifies the requested value or resource.
function runDirect(bspFilename, paletteFilename)
  palette = fs.readAllBytes(paletteFilename)
  if len(palette) < 768 then return error(2350, "palette.lmp must contain 768 bytes") end if
  map = bsp.load(bspFilename)
  return runMap(map, "MiniQuake BSP viewer - " + bspFilename)
end function

/// Execute from game.
/// @param baseDirectory Root directory containing the Quake installation.
/// @param mapName Name of the map to load or inspect.
function runFromGame(baseDirectory, mapName)
  system = qfs.standard(baseDirectory, "id1")
  filename = mapName
  nameBytes = bytes(filename)
  if len(nameBytes) < 4 or decode(slice(nameBytes, len(nameBytes) - 4, 4)) != ".bsp" then filename = filename + ".bsp" end if
  mapData = qfs.readFile(system, "maps/" + filename)
  palette = qfs.readFile(system, "gfx/palette.lmp")
  if len(palette) < 768 then return error(2351, "game palette is invalid") end if
  map = bsp.parse(mapData, "maps/" + filename)
  return runMap(map, "MiniQuake - " + mapName)
end function
