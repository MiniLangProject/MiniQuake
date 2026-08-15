/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Deterministic MiniQuake side of the MiniQuake Draw_TileClear renderer oracle.
Tracing is explicitly enabled here and is inert in release rendering.
*/
import miniquake.render.draw2d as draw2d
import miniquake.render.gl11 as gl
import miniquake.types as t

// Exercise json arguments as part of this deterministic regression fixture.
function jsonArguments(values)
  result = "["
  index = 0
  while index < len(values)
    if index != 0 then result = result + "," end if
    result = result + values[index]
    index = index + 1
  end while
  return result + "]"
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  draw2d.Draw_TraceSetBacktile(t.MenuPicture("trace/backtile", 64, 64, 77))
  gl.Trace_Begin()
  if not draw2d.Draw_TileClear(16, 24, 96, 40) then return 1 end if
  commands = gl.Trace_End()
  sequence = 0
  for each command in commands
    print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"draw_tile_clear\",\"seq\":" + sequence + ",\"op\":\"" + command[0] + "\",\"args\":" + jsonArguments(command[1]) + "}"
    sequence = sequence + 1
  end for
  return 0
end function
