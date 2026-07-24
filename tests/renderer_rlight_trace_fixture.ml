/*
Deterministic MiniLang side of the original gl_rlight.c differential oracle.
*/

import miniquake.render.gl_rlight as rlight
import miniquake.types as t
import miniquake.constants as c
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

function outsideLight()
  return t.DynamicLight(t.Vec3(100.0, 0.0, 0.0), 10.0, 1.0, 0.0, 0.0, 0)
end function

function viewOrigin()
  return t.Vec3(0.0, 0.0, 0.0)
end function

function viewForward()
  return t.Vec3(1.0, 0.0, 0.0)
end function

function viewRight()
  return t.Vec3(0.0, 1.0, 0.0)
end function

function viewUp()
  return t.Vec3(0.0, 0.0, 1.0)
end function

function traceDlightFan(scene, functionName, vertices, firstSequence)
  sequence = firstSequence
  emit(scene, functionName, sequence, "begin", "[6]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "color", "[0.2,0.1,0,1]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "vertex", "[" + vecArguments(vertices[0]) + "]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "color", "[0,0,0,1]")
  sequence = sequence + 1
  index = 1
  while index < len(vertices)
    emit(scene, functionName, sequence, "vertex", "[" + vecArguments(vertices[index]) + "]")
    sequence = sequence + 1
    index = index + 1
  end while
  emit(scene, functionName, sequence, "end", "[]")
  return sequence + 1
end function

function traceAnimate()
  values = rlight.R_AnimateLight(["az", "mmn"], 0.1)
  emit("rlight_animate", "R_AnimateLight", 0, "lightstyles", "[" + values[0] + "," + values[1] + "," + values[2] + "," + values[c.MAX_LIGHTSTYLES - 1] + "]")
end function

function traceBlend()
  blend = rlight.AddLightBlend([0.1, 0.2, 0.3, 0.4], 1.0, 0.5, 0.0, 0.25)
  emit("rlight_add_blend", "AddLightBlend", 0, "blend", "[" + jsonNumber(blend[0]) + "," + jsonNumber(blend[1]) + "," + jsonNumber(blend[2]) + "," + jsonNumber(blend[3]) + "]")
end function

function traceRenderDlight()
  result = rlight.R_RenderDlight(
    outsideLight(), 0.0, viewOrigin(), viewForward(), viewRight(), viewUp(),
    [0.0, 0.0, 0.0, 0.0]
  )
  traceDlightFan("rlight_render_dlight", "R_RenderDlight", result[2], 0)
end function

function traceRenderDlightInside()
  light = t.DynamicLight(t.Vec3(1.0, 0.0, 0.0), 20.0, 1.0, 0.0, 0.0, 0)
  result = rlight.R_RenderDlight(
    light, 0.0, viewOrigin(), viewForward(), viewRight(), viewUp(),
    [0.0, 0.0, 0.0, 0.0]
  )
  blend = result[1]
  emit("rlight_render_dlight_inside", "R_RenderDlight", 0, "blend", "[" + jsonNumber(blend[0]) + "," + jsonNumber(blend[1]) + "," + jsonNumber(blend[2]) + "," + jsonNumber(blend[3]) + "]")
end function

function traceRenderDlights()
  expired = t.DynamicLight(t.Vec3(1.0, 0.0, 0.0), 20.0, -1.0, 0.0, 0.0, 0)
  result = rlight.R_RenderDlights(
    [outsideLight(), expired], 0.0, viewOrigin(), viewForward(), viewRight(),
    viewUp(), [0.0, 0.0, 0.0, 0.0]
  )
  scene = "rlight_render_dlights"
  functionName = "R_RenderDlights"
  sequence = 0
  emit(scene, functionName, sequence, "depth_mask", "[0]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "disable", "[3553]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "shade_model", "[7425]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "enable", "[3042]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "blend_function", "[1,1]")
  sequence = sequence + 1
  sequence = traceDlightFan(scene, functionName, result[2][0], sequence)
  emit(scene, functionName, sequence, "color", "[1,1,1,1]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "disable", "[3042]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "enable", "[3553]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "blend_function", "[770,771]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "depth_mask", "[1]")
  sequence = sequence + 1
  emit(scene, functionName, sequence, "dlight_frame", "[13]")
end function

function fixtureWorld(withLightData)
  zero = t.Vec3(0.0, 0.0, 0.0)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -1, -2, zero, zero, 0, 1)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  face = t.BspFace(0, 0, 0, 0, 0, bytes([0, 255, 255, 255]), 0)
  model = t.BspModel(zero, zero, zero, [0, 0, 0, 0], 0, 0, 1)
  lighting = bytes()
  if withLightData then lighting = bytes([100, 0, 0, 0]) end if
  map = t.BspMap(
    "renderer-rlight-fixture.bsp", bytes(), c.BSP_VERSION, [], "", [],
    [plane], [], [], bytes(), [node], [info], [face], lighting, [], [], [],
    [], [], [model]
  )
  surface = t.RenderSurface(
    0, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, 0, 0, [], 0
  )
  return [map, surface]
end function

function traceMarkLights()
  world = fixtureWorld(true)
  bits = [0]
  frames = [0]
  rlight.R_MarkLights(world[0], bits, frames, 7, outsideLight(), 4, 0)
  emit("rlight_mark_lights", "R_MarkLights", 0, "surface_mark", "[" + frames[0] + "," + bits[0] + "]")
end function

function tracePushDlights()
  world = fixtureWorld(true)
  bits = [0]
  frames = [0]
  rlight.R_PushDlights(world[0], bits, frames, 8, [outsideLight()], 0.0, 0)
  emit("rlight_push_dlights", "R_PushDlights", 0, "surface_mark", "[" + frames[0] + "," + bits[0] + ",8]")
end function

function lightStyles()
  return rlight.R_AnimateLight(["az", "mmn"], 0.1)
end function

function traceRecursiveLightPoint()
  world = fixtureWorld(true)
  result = rlight.RecursiveLightPoint(
    world[0], [world[1]], lightStyles(), 0,
    t.Vec3(0.0, 0.0, 10.0), t.Vec3(0.0, 0.0, -10.0)
  )
  emit("rlight_recursive_light_point", "RecursiveLightPoint", 0, "light_point", "[" + result[0] + "," + vecArguments(result[1]) + "," + vecArguments(result[2].normal) + "," + jsonNumber(result[2].dist) + "]")
end function

function traceLightPoint()
  world = fixtureWorld(true)
  result = rlight.R_LightPoint(
    world[0], [world[1]], lightStyles(), 0, t.Vec3(0.0, 0.0, 10.0)
  )
  emit("rlight_light_point", "R_LightPoint", 0, "light_point", "[" + result[0] + "," + vecArguments(result[1]) + "," + vecArguments(result[2].normal) + "," + jsonNumber(result[2].dist) + "]")
end function

function traceLightPointNoData()
  world = fixtureWorld(false)
  result = rlight.R_LightPoint(
    world[0], [world[1]], lightStyles(), 0, t.Vec3(0.0, 0.0, 10.0)
  )
  emit("rlight_light_point_no_data", "R_LightPoint", 0, "light_point", "[" + result[0] + "]")
end function

function main(args)
  traceAnimate()
  traceBlend()
  traceRenderDlight()
  traceRenderDlightInside()
  traceRenderDlights()
  traceMarkLights()
  tracePushDlights()
  traceRecursiveLightPoint()
  traceLightPoint()
  traceLightPointNoData()
  return 0
end function
