/*
Deterministic MiniLang side of the original gl_rsurf.c differential oracle.
*/

import miniquake.render.world as rsurf
import miniquake.render.gl11 as gl
import miniquake.types as t
import miniquake.constants as c
import miniquake.native as native
import miniquake.array_util as arrayutil
import std.string as string

function jsonNumber(value)
  integerValue = native.trunc(value)
  if value == integerValue then return "" + integerValue end if
  return string.replaceAll("" + value, ".e", "e")
end function

function jsonArguments(values)
  result = "["
  index = 0
  while index < len(values)
    if index != 0 then result = result + "," end if
    result = result + jsonNumber(values[index])
    index = index + 1
  end while
  return result + "]"
end function

function emit(scene, functionName, sequence, operation, arguments)
  print "{\"schema\":\"miniquake.renderer.gl.v1\",\"scene\":\"" + scene + "\",\"function\":\"" + functionName + "\",\"seq\":" + sequence + ",\"op\":\"" + operation + "\",\"args\":" + arguments + "}"
end function

function emitCommands(scene, functionName, commands)
  sequence = 0
  for each command in commands
    emit(scene, functionName, sequence, command[0], jsonArguments(command[1]))
    sequence = sequence + 1
  end for
  return sequence
end function

function inline fnvByte(hash, value)
  return ((hash ^ (value & 255)) * 16777619) & 4294967295
end function

function hashBytes(data)
  hash = 2166136261
  index = 0
  while index < len(data)
    hash = fnvByte(hash, data[index])
    index = index + 1
  end while
  return hash
end function

function hashU32(values, count)
  hash = 2166136261
  index = 0
  while index < count
    value = values[index]
    hash = fnvByte(hash, value)
    hash = fnvByte(hash, value >> 8)
    hash = fnvByte(hash, value >> 16)
    hash = fnvByte(hash, value >> 24)
    index = index + 1
  end while
  return hash
end function

function baseVertices()
  return [
    t.RenderVertex(t.Vec3(0.0, 0.0, 0.0), 0.0, 0.0, 0.1, 0.2),
    t.RenderVertex(t.Vec3(16.0, 0.0, 0.0), 1.0, 0.0, 0.3, 0.2),
    t.RenderVertex(t.Vec3(16.0, 16.0, 0.0), 1.0, 1.0, 0.3, 0.4),
    t.RenderVertex(t.Vec3(0.0, 16.0, 0.0), 0.0, 1.0, 0.1, 0.4),
  ]
end function

function makeSetup(flags)
  zero = t.Vec3(0.0, 0.0, 0.0)
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  face = t.BspFace(0, 0, 0, 4, 0, bytes([0, 1, 255, 255]), 0)
  texture = t.BspTexture("fixture", 64, 64, [0, 0, 0, 0], bytes(64 * 64))
  vertices = [
    t.BspVertex(t.Vec3(0.0, 0.0, 0.0)),
    t.BspVertex(t.Vec3(16.0, 0.0, 0.0)),
    t.BspVertex(t.Vec3(16.0, 16.0, 0.0)),
    t.BspVertex(t.Vec3(0.0, 16.0, 0.0)),
  ]
  edges = [
    t.BspEdge(0, 0), t.BspEdge(0, 1), t.BspEdge(1, 2),
    t.BspEdge(2, 3), t.BspEdge(3, 0),
  ]
  model = t.BspModel(zero, zero, zero, [0, 0, 0, 0], 0, 0, 1)
  lighting = bytes([20, 27, 34, 41, 48, 55, 62, 69])
  map = t.BspMap(
    "rsurf-fixture.bsp", bytes(), c.BSP_VERSION, [], "", [], [plane],
    [texture], vertices, bytes(), [], [info], [face], lighting, [], [], [],
    edges, [1, 2, 3, 4], [model]
  )
  surface = t.RenderSurface(
    0, 0, zero, t.Vec3(16.0, 16.0, 0.0), 2, 2, 0, flags,
    baseVertices(), 500
  )
  renderTexture = t.RenderTexture("fixture", 64, 64, 77, bytes(64 * 64), false)
  renderer = t.WorldRenderer(
    map, bytes(768), [renderTexture], [surface], [], true, 0, false, false,
    0, bytes(1, 1), 0, 1.0
  )
  light = t.DynamicLight(t.Vec3(8.0, 8.0, 16.0), 64.0, 1.0, 0.0, 0.0, 0)
  rsurf.R_ConfigureWorldCompatibility(
    renderer, zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [light], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.25, 0.0,
    true, true, false
  )
  rsurf.R_ResetLightmapCompatibility()
  rsurf.R_SetLightmapCompatibility(500, 1)
  rsurf.R_SetFrameCompatibility(7, 3)
  styles = arrayutil.makeFilledArray(c.MAX_LIGHTSTYLES, 0)
  styles[0] = 256
  styles[1] = 128
  rsurf.R_SetLightStyleCompatibility(styles)
  rsurf.R_SetSurfaceCompatibilityState(0, 0, 0, [256, 128, 0, 0], false, 0, 2, 3)
  rsurf.R_SetMultitextureCompatibility(false, false)
  rsurf.R_SetAbstractSurfaceCalls(true)
  rsurf.R_SetSurfaceChainCompatibility(true, [], [])
  return [renderer, surface, plane]
end function

function configureWorldTree(setup, textureSort)
  zero = t.Vec3(0.0, 0.0, 0.0)
  setup[0].map.nodes = [
    t.BspNode(0, -1, -2, zero, zero, 0, 1),
  ]
  setup[0].map.models[0].headNodes = [0, 0, 0, 0]
  viewOrigin = t.Vec3(0.0, 0.0, 10.0)
  rsurf.R_ConfigureWorldCompatibility(
    setup[0], viewOrigin, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.25, 0.0,
    true, true, false
  )
  rsurf.R_SetFrameCompatibility(7, 3)
  rsurf.R_SetSurfaceCompatibilityState(0, 0, 0, [256, 128, 0, 0], false, 0, 2, 3)
  rsurf.R_SetSurfaceChainCompatibility(textureSort, [], [])
  return setup
end function

function traceAddDynamicLights()
  setup = makeSetup(0)
  rsurf.R_SetSurfaceCompatibilityState(0, 1, 0, [256, 128, 0, 0], false, 0, 2, 3)
  rsurf.R_AddDynamicLights(setup[1])
  emit("rsurf_add_dynamic_lights", "R_AddDynamicLights", 0, "blocklights_hash", "[" + hashU32(rsurf.R_GetBlocklights(), 4) + "]")
end function

function traceBuildLightMap()
  setup = makeSetup(0)
  destination = bytes(12, 204)
  result = rsurf.R_BuildLightMap(setup[1], destination, 6)
  state = rsurf.R_GetSurfaceCompatibilityState(0)
  emit("rsurf_build_lightmap", "R_BuildLightMap", 0, "lightmap_hash", "[" + hashBytes(result) + "]")
  emit("rsurf_build_lightmap", "R_BuildLightMap", 1, "cached_styles", "[" + state[0][0] + "," + state[0][1] + ",0]")
end function

function traceTextureAnimation()
  setup = makeSetup(0)
  baseMap = t.BspTexture("+0fixture", 64, 64, [0, 0, 0, 0], bytes())
  nextMap = t.BspTexture("+1fixture", 64, 64, [0, 0, 0, 0], bytes())
  alternateMap = t.BspTexture("+Afixture", 64, 64, [0, 0, 0, 0], bytes())
  base = t.RenderTexture("+0fixture", 64, 64, 10, bytes(), false)
  next = t.RenderTexture("+1fixture", 64, 64, 11, bytes(), false)
  alternate = t.RenderTexture("+Afixture", 64, 64, 20, bytes(), false)
  setup[0].map.textures = [baseMap, nextMap, alternateMap]
  setup[0].textures = [base, next, alternate]
  rsurf.R_ConfigureWorldCompatibility(
    setup[0], t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0), [], [], [0.0, 0.0, 0.0, 0.0],
    0.3, 0.25, 0.0, true, true, false
  )
  rsurf.R_SetTextureAnimationFrame(0)
  selected = rsurf.R_TextureAnimation(base)
  emit("rsurf_texture_animation", "R_TextureAnimation", 0, "selected_texture", "[" + selected.glId + "]")
  rsurf.R_SetTextureAnimationFrame(1)
  selected = rsurf.R_TextureAnimation(base)
  emit("rsurf_texture_animation", "R_TextureAnimation", 1, "selected_texture", "[" + selected.glId + "]")
end function

function traceMultitexture()
  makeSetup(0)
  rsurf.R_SetMultitextureCompatibility(true, true)
  gl.Trace_Begin()
  rsurf.GL_DisableMultitexture()
  commands = gl.Trace_End()
  sequence = emitCommands("rsurf_disable_multitexture", "GL_DisableMultitexture", commands)
  emit("rsurf_disable_multitexture", "GL_DisableMultitexture", sequence, "state", "[0]")
  makeSetup(0)
  rsurf.R_SetMultitextureCompatibility(true, false)
  gl.Trace_Begin()
  rsurf.GL_EnableMultitexture()
  commands = gl.Trace_End()
  sequence = emitCommands("rsurf_enable_multitexture", "GL_EnableMultitexture", commands)
  emit("rsurf_enable_multitexture", "GL_EnableMultitexture", sequence, "state", "[1]")
end function

function traceCall(scene, functionName, setup, callback)
  gl.Trace_Begin()
  if callback == 0 then rsurf.DrawGLWaterPoly(setup[1]) end if
  if callback == 1 then rsurf.DrawGLWaterPolyLightmap(setup[1]) end if
  if callback == 2 then rsurf.DrawGLPoly(setup[1]) end if
  commands = gl.Trace_End()
  emitCommands(scene, functionName, commands)
end function

function traceDrawPolygons()
  traceCall("rsurf_draw_water_poly", "DrawGLWaterPoly", makeSetup(0), 0)
  traceCall("rsurf_draw_water_lightmap", "DrawGLWaterPolyLightmap", makeSetup(0), 1)
  traceCall("rsurf_draw_poly", "DrawGLPoly", makeSetup(0), 2)
end function

function traceSequential(multitexture)
  setup = makeSetup(0)
  rsurf.R_SetMultitextureCompatibility(multitexture, false)
  if multitexture then rsurf.R_SetLightmapDirtyCompatibility(0, [2, 3, 2, 2], true) end if
  gl.Trace_Begin()
  rsurf.R_DrawSequentialPoly(setup[1])
  commands = gl.Trace_End()
  scene = "rsurf_sequential_single"
  if multitexture then scene = "rsurf_sequential_mtex" end if
  emitCommands(scene, "R_DrawSequentialPoly", commands)
end function

function traceBlendLightmaps()
  setup = makeSetup(0)
  underwater = t.RenderSurface(
    0, 0, t.Vec3(0.0, 0.0, 0.0), t.Vec3(16.0, 16.0, 0.0),
    2, 2, 0, 0x80, baseVertices(), 500
  )
  rsurf.R_SetLightmapChainCompatibility(0, [setup[1], underwater])
  rsurf.R_SetLightmapDirtyCompatibility(0, [0, 3, 0, 2], true)
  gl.Trace_Begin()
  rsurf.R_BlendLightmaps()
  commands = gl.Trace_End()
  emitCommands("rsurf_blend_lightmaps", "R_BlendLightmaps", commands)
end function

function traceRenderBrush(flags, scene)
  setup = makeSetup(flags)
  gl.Trace_Begin()
  rsurf.R_RenderBrushPoly(setup[1])
  commands = gl.Trace_End()
  sequence = emitCommands(scene, "R_RenderBrushPoly", commands)
  if flags == 0 then
    state = rsurf.R_GetLightmapCompatibilityState(0)
    emit(scene, "R_RenderBrushPoly", sequence, "chain_state", "[1," + state[2] + "]")
  end if
end function

function traceDynamicLightmaps()
  setup = makeSetup(0)
  rsurf.R_SetSurfaceCompatibilityState(0, 0, 0, [1, 128, 0, 0], false, 0, 2, 3)
  rsurf.R_SetLightmapDirtyCompatibility(0, [0, 0, 0, 0], false)
  rsurf.R_RenderDynamicLightmaps(setup[1])
  state = rsurf.R_GetLightmapCompatibilityState(0)
  rectangle = state[1]
  modified = 0
  if state[0] then modified = 1 end if
  emit("rsurf_dynamic_lightmaps", "R_RenderDynamicLightmaps", 0, "dynamic_state", "[" + modified + "," + rectangle[0] + "," + rectangle[1] + "," + rectangle[2] + "," + rectangle[3] + "," + state[2] + "]")
  emit("rsurf_dynamic_lightmaps", "R_RenderDynamicLightmaps", 1, "atlas_hash", "[" + hashBytes(rsurf.R_GetLightmapBytes()) + "]")
end function

function traceMirror()
  setup = makeSetup(0)
  rsurf.R_MirrorChain(setup[1])
  state = rsurf.R_GetMirrorCompatibilityState()
  samePlane = 0
  if state[0] and state[1] == setup[2] then samePlane = 1 end if
  emit("rsurf_mirror_chain", "R_MirrorChain", 0, "mirror_state", "[1," + samePlane + "]")
end function

function traceAlloc()
  makeSetup(0)
  x = [-1]
  y = [-1]
  page = rsurf.AllocBlock(4, 3, x, y)
  allocation = rsurf.R_GetAllocationCompatibilityState(0)
  emit("rsurf_alloc_block", "AllocBlock", 0, "allocation", "[" + page + "," + x[0] + "," + y[0] + "," + allocation[x[0]] + "," + allocation[x[0] + 3] + "]")
end function

function traceDisplayList()
  setup = makeSetup(0)
  setup[1].vertices = [
    t.RenderVertex(t.Vec3(0.0, 0.0, 0.0), 0.0, 0.0, 0.01953125, 0.02734375),
    t.RenderVertex(t.Vec3(8.0, 0.0, 0.0), 0.125, 0.0, 0.0234375, 0.02734375),
    t.RenderVertex(t.Vec3(16.0, 0.0, 0.0), 0.25, 0.0, 0.02734375, 0.02734375),
    t.RenderVertex(t.Vec3(16.0, 16.0, 0.0), 0.25, 0.25, 0.02734375, 0.03515625),
    t.RenderVertex(t.Vec3(0.0, 16.0, 0.0), 0.0, 0.25, 0.01953125, 0.03515625),
  ]
  result = rsurf.BuildSurfaceDisplayList(setup[1])
  arguments = "[" + len(result.vertices) + ",1"
  for each vertex in result.vertices
    arguments = arguments + "," + jsonNumber(vertex.position.x) + "," + jsonNumber(vertex.position.y) + "," + jsonNumber(vertex.s) + "," + jsonNumber(vertex.lightS) + "," + jsonNumber(vertex.lightT)
  end for
  emit("rsurf_build_display_list", "BuildSurfaceDisplayList", 0, "display_list", arguments + "]")
end function

function traceCreateLightmap()
  setup = makeSetup(0)
  rsurf.GL_CreateSurfaceLightmap(setup[1])
  state = rsurf.R_GetSurfaceCompatibilityState(0)
  emit("rsurf_create_surface_lightmap", "GL_CreateSurfaceLightmap", 0, "surface_lightmap", "[" + state[2] + "," + state[3] + "," + state[4] + "]")
  emit("rsurf_create_surface_lightmap", "GL_CreateSurfaceLightmap", 1, "atlas_hash", "[" + hashBytes(rsurf.R_GetLightmapBytes()) + "]")
end function

function traceBuildLightmaps()
  setup = makeSetup(c.SURF_DRAWSKY)
  gl.Trace_Begin()
  rsurf.GL_BuildLightmaps()
  gl.Trace_End()
  emit("rsurf_build_lightmaps", "GL_BuildLightmaps", 0, "build_state", "[1,500,1000]")
end function

function traceDrawTextureChains()
  setup = makeSetup(c.SURF_DRAWSKY)
  rsurf.R_SetSurfaceChainCompatibility(false, [setup[1]], [])
  gl.Trace_Begin()
  rsurf.DrawTextureChains()
  commands = gl.Trace_End()
  emitCommands("rsurf_draw_texture_chains", "DrawTextureChains", commands)
end function

function traceDrawWaterSurfaces()
  setup = makeSetup(c.SURF_DRAWTURB)
  setup[0].waterAlpha = 0.5
  rsurf.R_SetSurfaceChainCompatibility(false, [], [setup[1]])
  gl.Trace_Begin()
  rsurf.R_DrawWaterSurfaces()
  commands = gl.Trace_End()
  emitCommands("rsurf_draw_water_surfaces", "R_DrawWaterSurfaces", commands)
end function

function traceDrawBrushModel()
  setup = configureWorldTree(makeSetup(0), true)
  baseModel = setup[0].map.models[0]
  submodel = t.BspModel(
    baseModel.mins, baseModel.maxs, baseModel.origin,
    [0, 0, 0, 0], 0, 0, 1
  )
  setup[0].map.models = [baseModel, submodel]
  zero = t.Vec3(0.0, 0.0, 0.0)
  entity = t.ClientEntityState(
    1, 1, 0, 0, 0, 0, zero, zero, 0.0, zero, zero, zero, zero, false, void, 0.0
  )
  gl.Trace_Begin()
  rsurf.R_DrawBrushModel(entity)
  commands = gl.Trace_End()
  emitCommands("rsurf_draw_brush_model", "R_DrawBrushModel", commands)
end function

function traceRecursiveWorldNode()
  setup = configureWorldTree(makeSetup(0), false)
  gl.Trace_Begin()
  rsurf.R_RecursiveWorldNode(0)
  commands = gl.Trace_End()
  emitCommands("rsurf_recursive_world_node", "R_RecursiveWorldNode", commands)
end function

function traceDrawWorld()
  setup = configureWorldTree(makeSetup(0), false)
  gl.Trace_Begin()
  rsurf.R_DrawWorld()
  commands = gl.Trace_End()
  emitCommands("rsurf_draw_world", "R_DrawWorld", commands)
end function

function traceMarkLeaves()
  setup = makeSetup(0)
  zero = t.Vec3(0.0, 0.0, 0.0)
  rsurf.R_ConfigureWorldCompatibility(
    setup[0], zero, zero, t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.25, 0.0,
    true, true, true
  )
  rsurf.R_SetFrameCompatibility(7, 3)
  rsurf.R_MarkLeaves()
  state = rsurf.R_GetFrameCompatibility()
  emit("rsurf_mark_leaves", "R_MarkLeaves", 0, "visframe", "[" + state[1] + "]")
end function

function main(args)
  traceAddDynamicLights()
  traceBuildLightMap()
  traceTextureAnimation()
  traceMultitexture()
  traceDrawPolygons()
  traceSequential(false)
  traceSequential(true)
  traceBlendLightmaps()
  traceRenderBrush(0, "rsurf_render_brush_normal")
  traceRenderBrush(c.SURF_DRAWSKY, "rsurf_render_brush_sky")
  traceRenderBrush(c.SURF_DRAWTURB, "rsurf_render_brush_turb")
  traceDynamicLightmaps()
  traceMirror()
  traceAlloc()
  traceDisplayList()
  traceCreateLightmap()
  traceBuildLightmaps()
  traceDrawWaterSurfaces()
  traceDrawTextureChains()
  traceDrawBrushModel()
  traceRecursiveWorldNode()
  traceDrawWorld()
  traceMarkLeaves()
  return 0
end function
