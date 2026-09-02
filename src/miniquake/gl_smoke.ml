/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.gl_smoke.
*/
package miniquake.gl_smoke

import miniquake.platform.win32 as win
import miniquake.render.gl11 as gl

/// Implements the `draw` operation for `miniquake.gl_smoke` (draw).
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function draw(width, height)
  gl.viewport(0, 0, width, height)
  gl.clearColor(0.08, 0.08, 0.1, 1.0)
  gl.clear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT)
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  gl.ortho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.begin(gl.GL_TRIANGLES)
  gl.color(255, 80, 60, 255)
  gl.vertex2(0.0, 0.75)
  gl.color(80, 255, 100, 255)
  gl.vertex2(-0.75, -0.65)
  gl.color(80, 130, 255, 255)
  gl.vertex2(0.75, -0.65)
  gl.finishPrimitive()
end function

/// Validate readback and report any incompatibility.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function validateReadback(width, height)
  gl.finish()
  center = gl.readPixelsRgba(width / 2, height / 2, 1, 1)
  corner = gl.readPixelsRgba(4, 4, 1, 1)
  code = gl.errorCode()
  if code != 0 then return error(3600, "OpenGL readback error 0x" + hex(bytes([(code >> 8) & 255, code & 255]))) end if
  if len(center) != 4 or len(corner) != 4 then return error(3601, "OpenGL readback returned an invalid pixel") end if
  difference = 0
  index = 0
  while index < 3
    value = center[index] - corner[index]
    if value < 0 then value = -value end if
    difference = difference + value
    index = index + 1
  end while
  if difference < 24 then return error(3602, "OpenGL triangle readback matches the clear color") end if
  print "OpenGL readback: center=" + hex(center) + " corner=" + hex(corner) + " PASS"
  return true
end function

/// Execute frames.
/// @param maxFrames The max frames input consumed by `runFrames`.
function runFrames(maxFrames)
  if maxFrames < 0 then maxFrames = 0 end if
  win.create("MiniQuake OpenGL smoke test", 960, 540, 0)
  print "OpenGL vendor: " + gl.getString(gl.GL_VENDOR)
  print "OpenGL renderer: " + gl.getString(gl.GL_RENDERER)
  print "OpenGL version: " + gl.getString(gl.GL_VERSION)
  running = true
  frameCount = 0
  readbackValidated = false
  resultCode = 0
  while running
    running = win.poll()
    if win.keyDown(27) then running = false end if
    draw(win.width(), win.height())
    if not readbackValidated then
      validation = try(validateReadback(win.width(), win.height()))
      if validation is error then
        print "OpenGL readback: FAIL " + validation.message
        resultCode = 2
        running = false
      else
        readbackValidated = true
      end if
    end if
    win.swap()
    frameCount = frameCount + 1
    if maxFrames > 0 and frameCount >= maxFrames then running = false end if
    win.sleep(1)
  end while
  win.destroy()
  return resultCode
end function

/// Implements the `run` operation for `miniquake.gl_smoke` (run).
function run()
  return runFrames(0)
end function
