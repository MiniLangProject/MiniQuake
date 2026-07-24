/*
Deterministic MiniLang side of the original gl_warp.c differential oracle.
*/

import miniquake.render.gl_warp as warp
import miniquake.types as t
import miniquake.native as native
import std.string as string

function emit(scene, functionName, sequence, operation, arguments)
  print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":" + sequence + ",\"op\":\"" + operation + "\",\"args\":" + arguments + "}"
end function

function jsonNumber(value)
  integerValue = native.trunc(value)
  if value == integerValue then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function vecArguments(vector)
  return jsonNumber(vector.x) + "," + jsonNumber(vector.y) + "," + jsonNumber(vector.z)
end function

function tracePolygons(scene, functionName, polygons)
  polygonIndex = 0
  while polygonIndex < len(polygons)
    polygon = polygons[polygonIndex]
    arguments = "[" + polygonIndex + "," + len(polygon)
    vertexIndex = 0
    while vertexIndex < len(polygon)
      vertex = polygon[vertexIndex]
      arguments = arguments + "," + vecArguments(vertex.position) + "," + jsonNumber(vertex.s) + "," + jsonNumber(vertex.t)
      vertexIndex = vertexIndex + 1
    end while
    emit(scene, functionName, polygonIndex, "polygon", arguments + "]")
    polygonIndex = polygonIndex + 1
  end while
end function

function quad(z)
  return [
    t.RenderVertex(t.Vec3(-64.0, -32.0, z), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, -32.0, z), 64.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, 32.0, z), 64.0, 64.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(-64.0, 32.0, z), 0.0, 64.0, 0.0, 0.0),
  ]
end function

function traceWarpCommands(scene, functionName, polygons)
  sequence = 0
  for each polygon in polygons
    emit(scene, functionName, sequence, "begin", "[9]")
    sequence = sequence + 1
    for each vertex in polygon
      emit(scene, functionName, sequence, "texcoord", "[" + jsonNumber(vertex[0]) + "," + jsonNumber(vertex[1]) + "]")
      sequence = sequence + 1
      emit(scene, functionName, sequence, "vertex", "[" + vecArguments(vertex[2]) + "]")
      sequence = sequence + 1
    end for
    emit(scene, functionName, sequence, "end", "[]")
    sequence = sequence + 1
  end for
  return sequence
end function

function traceBoundPoly()
  vertices = [
    t.RenderVertex(t.Vec3(-7.0, 4.0, 11.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(3.0, -5.0, 2.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(9.0, 1.0, -13.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(0.0, 6.0, 8.0), 0.0, 0.0, 0.0, 0.0),
  ]
  bounds = warp.BoundPoly(vertices)
  emit("warp_bound_poly", "BoundPoly", 0, "bounds", "[" + vecArguments(bounds[0]) + "," + vecArguments(bounds[1]) + "]")
end function

function traceSubdividePolygon()
  vertices = [
    t.RenderVertex(t.Vec3(-64.0, -64.0, 0.0), -64.0, -64.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, -64.0, 0.0), 64.0, -64.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, 64.0, 0.0), 64.0, 64.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(-64.0, 64.0, 0.0), -64.0, 64.0, 0.0, 0.0),
  ]
  tracePolygons("warp_subdivide_polygon", "SubdividePolygon", warp.SubdividePolygon(vertices, 128.0))
end function

function traceSubdivideSurface()
  vertices = [
    t.RenderVertex(t.Vec3(-64.0, -64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, -64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(64.0, 64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
    t.RenderVertex(t.Vec3(-64.0, 64.0, 0.0), 0.0, 0.0, 0.0, 0.0),
  ]
  polygons = warp.GL_SubdivideSurface(vertices, [1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 128.0)
  tracePolygons("warp_gl_subdivide_surface", "GL_SubdivideSurface", polygons)
end function

function traceWater()
  commands = warp.EmitWaterPolys([quad(16.0)], 0.25)
  traceWarpCommands("warp_emit_water", "EmitWaterPolys", commands)
end function

function traceSky()
  commands = warp.EmitSkyPolys([quad(16.0)], t.Vec3(3.0, -2.0, 1.0), 17.0)
  traceWarpCommands("warp_emit_sky", "EmitSkyPolys", commands)
end function

function traceBothSkyLayers()
  scene = "warp_both_sky_layers"
  functionName = "EmitBothSkyLayers"
  layers = warp.EmitBothSkyLayers([quad(16.0)], t.Vec3(3.0, -2.0, 1.0), 20.0)
  sequence = 0
  emit(scene, functionName, sequence, "disable_multitexture", "[]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "bind_texture", "[3553,701]")
  sequence = sequence + 1
  sequence = sequence + traceWarpCommandsOffset(scene, functionName, [layers[1]], sequence)
  emit(scene, functionName, sequence, "enable", "[3042]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "bind_texture", "[3553,702]")
  sequence = sequence + 1
  sequence = sequence + traceWarpCommandsOffset(scene, functionName, [layers[3]], sequence)
  emit(scene, functionName, sequence, "disable", "[3042]")
end function

function traceWarpCommandsOffset(scene, functionName, polygonGroups, firstSequence)
  sequence = firstSequence
  for each polygons in polygonGroups
    for each polygon in polygons
      emit(scene, functionName, sequence, "begin", "[9]")
      sequence = sequence + 1
      for each vertex in polygon
        emit(scene, functionName, sequence, "texcoord", "[" + jsonNumber(vertex[0]) + "," + jsonNumber(vertex[1]) + "]")
        sequence = sequence + 1
        emit(scene, functionName, sequence, "vertex", "[" + vecArguments(vertex[2]) + "]")
        sequence = sequence + 1
      end for
      emit(scene, functionName, sequence, "end", "[]")
      sequence = sequence + 1
    end for
  end for
  return sequence - firstSequence
end function

function traceSkyChain()
  scene = "warp_draw_sky_chain"
  functionName = "R_DrawSkyChain"
  chain = warp.R_DrawSkyChain([[quad(16.0)], [quad(32.0)]], t.Vec3(3.0, -2.0, 1.0), 20.0)
  sequence = 0
  emit(scene, functionName, sequence, "disable_multitexture", "[]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "bind_texture", "[3553,701]")
  sequence = sequence + 1
  sequence = sequence + traceWarpCommandsOffset(scene, functionName, chain[1], sequence)
  emit(scene, functionName, sequence, "enable", "[3042]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "bind_texture", "[3553,702]")
  sequence = sequence + 1
  sequence = sequence + traceWarpCommandsOffset(scene, functionName, chain[3], sequence)
  emit(scene, functionName, sequence, "disable", "[3042]")
end function

function fnv1a(data)
  hash = 2166136261
  index = 0
  while index < len(data)
    hash = ((hash ^ data[index]) * 16777619) & 4294967295
    index = index + 1
  end while
  return hash
end function

function traceInitSky()
  palette = bytes(768)
  index = 0
  while index < 256
    palette[index * 3] = (index * 3) & 255
    palette[index * 3 + 1] = (index * 5) & 255
    palette[index * 3 + 2] = (index * 7) & 255
    index = index + 1
  end while
  pixels = bytes(256 * 128)
  y = 0
  while y < 128
    x = 0
    while x < 256
      value = (x * 3 + y * 5) & 255
      if x >= 128 then value = ((x + y) % 254) + 1 end if
      pixels[y * 256 + x] = value
      x = x + 1
    end while
    y = y + 1
  end while
  texture = t.BspTexture("fixture", 256, 128, [0, 0, 0, 0], pixels)
  result = warp.R_InitSky(texture, palette)
  scene = "warp_init_sky"
  functionName = "R_InitSky"
  emit(scene, functionName, 0, "bind_texture", "[3553,900]")
  emit(scene, functionName, 1, "upload_rgba", "[3553,0,3,128,128,0,6408,5121," + fnv1a(result[0]) + "]")
  emit(scene, functionName, 2, "texture_parameter", "[3553,10241,9729]")
  emit(scene, functionName, 3, "texture_parameter", "[3553,10240,9729]")
  emit(scene, functionName, 4, "bind_texture", "[3553,901]")
  emit(scene, functionName, 5, "upload_rgba", "[3553,0,4,128,128,0,6408,5121," + fnv1a(result[1]) + "]")
  emit(scene, functionName, 6, "texture_parameter", "[3553,10241,9729]")
  emit(scene, functionName, 7, "texture_parameter", "[3553,10240,9729]")
end function

function main(args)
  traceBoundPoly()
  traceSubdividePolygon()
  traceSubdivideSurface()
  traceWater()
  traceSky()
  traceBothSkyLayers()
  traceSkyChain()
  traceInitSky()
  return 0
end function
