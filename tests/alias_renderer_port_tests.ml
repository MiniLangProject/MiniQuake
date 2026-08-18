/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Production-path branch tests for the alias/viewmodel part of gl_rmain.c.
*/
import miniquake.types as t
import miniquake.render.entities as entities
import miniquake.render.gl11 as gl
import miniquake.render.world as renderWorld
import miniquake.render.alias_mesh as aliasMesh
import miniquake.render.ray_shadow as rayShadow

// Assert that the condition holds and identify a failing test.
function require(value, name)
  if not value then return error(9950, name) end if
  return true
end function

// Assert exact equality and report both values on failure.
function equal(actual, expected, name)
  if actual != expected then return error(9951, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

// Return count command for the active module state.
function countCommand(commands, name)
  count = 0
  for each command in commands
    if command[0] == name then count = count + 1 end if
  end for
  return count
end function

// Return first texture for the active module state.
function firstTexture(commands)
  for each command in commands
    if command[0] == "bind_texture" and len(command[1]) > 1 then return command[1][1] end if
  end for
  return -1
end function

// Return last blend function for the active module state.
function lastBlendFunction(commands)
  result = []
  for each command in commands
    if command[0] == "blend_function" then result = command[1] end if
  end for
  return result
end function

// Return the last depth comparison selected by a traced renderer pass.
function lastDepthFunction(commands)
  result = -1
  for each command in commands
    if command[0] == "depth_func" and len(command[1]) > 0 then result = command[1][0] end if
  end for
  return result
end function

// Report whether translate z.
function hasTranslateZ(commands, expected)
  for each command in commands
    if command[0] == "translate" and len(command[1]) >= 3 and command[1][2] == expected then return true end if
  end for
  return false
end function

// Exercise alias source as part of this deterministic regression fixture.
function aliasSource(name)
  frame0 = t.MdlFrame("idle0", t.MdlVertex(0, 0, 0, 0), t.MdlVertex(2, 2, 1, 0), [
    t.MdlVertex(0, 0, 0, 0),
    t.MdlVertex(2, 0, 0, 1),
    t.MdlVertex(0, 2, 0, 2),
  ])
  frame1 = t.MdlFrame("idle1", t.MdlVertex(0, 0, 0, 0), t.MdlVertex(2, 2, 2, 0), [
    t.MdlVertex(0, 0, 1, 3),
    t.MdlVertex(2, 0, 1, 4),
    t.MdlVertex(0, 2, 1, 5),
  ])
  return t.MdlModel(
    name, bytes(), 6,
    t.Vec3(1.0, 1.0, 1.0), t.Vec3(0.0, 0.0, 30.0),
    4.0, t.Vec3(0.0, 0.0, 0.0),
    1, 4, 4, 3, 1, 2, 0, 0, 1.0,
    [t.MdlSkin(false, [], [bytes(16)])],
    [t.MdlTexCoord(0, 0, 0), t.MdlTexCoord(0, 3, 0), t.MdlTexCoord(0, 0, 3)],
    [t.MdlTriangle(1, 0, 1, 2)],
    [
      t.MdlFrameSet(false, [], [frame0]),
      t.MdlFrameSet(true, [0.1, 0.2], [frame0, frame1]),
    ],
  )
end function

// Exercise alias model as part of this deterministic regression fixture.
function aliasModel(name)
  return t.ClientRenderModel(name, entities.MODEL_ALIAS, aliasSource(name), void, void, [[11, 12, 13, 14]], true)
end function

// Exercise alias entity as part of this deterministic regression fixture.
function aliasEntity(number, modelIndex, frame, colormap)
  return t.ClientEntityState(
    number, modelIndex, frame, colormap, 0, 0,
    t.Vec3(1.0, 2.0, 3.0), t.Vec3(10.0, 20.0, 30.0), 0.0,
    t.Vec3(1.0, 2.0, 3.0), t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(10.0, 20.0, 30.0), t.Vec3(10.0, 20.0, 30.0),
    false, [], 0.0,
  )
end function

// Exercise sprite model as part of this deterministic regression fixture.
function spriteModel()
  frame = t.SpriteFrame(1.0, 1.0, 2, 2, bytes(4))
  source = t.SpriteModel("progs/fixture.spr", bytes(), 1, 0, 2.0, 2, 2, 1, 0.0, 0, [
    t.SpriteFrameSet(false, [], [frame]),
  ])
  return t.ClientRenderModel(source.filename, entities.MODEL_SPRITE, void, source, void, [[22]], true)
end function

// Build a small horizontal lit receiver used to exercise production shadow
// validation without relying on stale global lightspot state.
function shadowReceiverRenderer()
  plane = t.BspPlane(t.Vec3(0.0, 0.0, 1.0), 0.0, 2)
  node = t.BspNode(0, -1, -1, t.Vec3(-64.0, -64.0, -8.0), t.Vec3(64.0, 64.0, 8.0), 0, 1)
  face = t.BspFace(0, 0, 0, 4, 0, bytes([0, 255, 255, 255]), 0)
  info = t.BspTexInfo([1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], 0, 0)
  texture = t.BspTexture("floor", 16, 16, [0, 0, 0, 0], bytes(256, 32))
  vertices = [
    t.BspVertex(t.Vec3(-64.0, -64.0, 0.0)),
    t.BspVertex(t.Vec3(64.0, -64.0, 0.0)),
    t.BspVertex(t.Vec3(64.0, 64.0, 0.0)),
    t.BspVertex(t.Vec3(-64.0, 64.0, 0.0)),
  ]
  edges = [t.BspEdge(0, 1), t.BspEdge(1, 2), t.BspEdge(2, 3), t.BspEdge(3, 0)]
  model = t.BspModel(
    t.Vec3(-64.0, -64.0, -8.0), t.Vec3(64.0, 64.0, 8.0),
    t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 0, 0, 1,
  )
  map = t.BspMap(
    "maps/shadow_receiver.bsp", bytes(), 29, [], "", [], [plane], [texture], vertices,
    bytes(), [node], [info], [face], bytes(81, 64), [], [], [], edges,
    [0, 1, 2, 3], [model],
  )
  return renderWorld.createExternal(map, bytes(768, 64))
end function

// Build a vertical wall receiver for direct light/caster occlusion tests.
function wallReceiverRenderer()
  plane = t.BspPlane(t.Vec3(1.0, 0.0, 0.0), 0.0, 0)
  node = t.BspNode(0, -1, -1, t.Vec3(-1.0, -64.0, -64.0), t.Vec3(1.0, 64.0, 64.0), 0, 1)
  face = t.BspFace(0, 0, 0, 4, 0, bytes([0, 255, 255, 255]), 0)
  info = t.BspTexInfo([0.0, 1.0, 0.0, 64.0], [0.0, 0.0, 1.0, 64.0], 0, 0)
  texture = t.BspTexture("wall", 16, 16, [0, 0, 0, 0], bytes(256, 32))
  vertices = [
    t.BspVertex(t.Vec3(0.0, -64.0, -64.0)),
    t.BspVertex(t.Vec3(0.0, 64.0, -64.0)),
    t.BspVertex(t.Vec3(0.0, 64.0, 64.0)),
    t.BspVertex(t.Vec3(0.0, -64.0, 64.0)),
  ]
  edges = [t.BspEdge(0, 1), t.BspEdge(1, 2), t.BspEdge(2, 3), t.BspEdge(3, 0)]
  model = t.BspModel(
    t.Vec3(-1.0, -64.0, -64.0), t.Vec3(1.0, 64.0, 64.0),
    t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 0, 0, 1,
  )
  map = t.BspMap(
    "maps/shadow_wall.bsp", bytes(), 29, [], "", [], [plane], [texture], vertices,
    bytes(), [node], [info], [face], bytes(81, 64), [], [], [], edges,
    [0, 1, 2, 3], [model],
  )
  return renderWorld.createExternal(map, bytes(768, 64))
end function

// Verify that a receiver beyond the caster is accepted while a wall between
// the light and caster blocks the same ray before it can create a shadow.
function testRayShadowOcclusion()
  wall = wallReceiverRenderer()
  entity = aliasEntity(40, 1, 0, 0)
  entity.origin = t.Vec3(5.0, 0.0, 0.0)
  entity.angles = t.Vec3(0.0, 0.0, 0.0)
  require(rayShadow.configureBrush(wall.map, wall.surfaces, entity, true, 10.0, 0.0, 0.0), "wall ray context")
  rayShadow.beginProjectionSample(0.0, 0.0)
  require(rayShadow.projectVertex(0, 0.0, 0.0, 0.0), "wall beyond caster receives light ray")
  require(rayShadow.projectedPointX(0) > 0.0 and rayShadow.projectedPointX(0) < 1.0, "wall receiver carries outward depth bias")

  entity.origin.x = -5.0
  require(rayShadow.configureBrush(wall.map, wall.surfaces, entity, true, 10.0, 0.0, 0.0), "occluded wall ray context")
  rayShadow.beginProjectionSample(0.0, 0.0)
  require(not rayShadow.projectVertex(0, 0.0, 0.0, 0.0), "wall before caster blocks projected shadow")
  return true
end function

// Verify that neighboring caster vertices cannot bridge a receiver-height
// discontinuity into a long translucent triangle at a crate or pickup edge.
function testRayShadowReceiverContinuity()
  require(rayShadow.receiverEdgeContinuity(16.0, 18.0, 15.0), "continuous floor receiver remains connected")
  require(not rayShadow.receiverEdgeContinuity(16.0, 66.0, 64.0), "ledge discontinuity rejects stretched shadow edge")
  require(not rayShadow.receiverEdgeContinuity(4.0, 80.0, 2.0), "excessive projected stretch rejects thin line")
  return true
end function

// Verify frame selection against the expected Quake behavior.
function testFrameSelection()
  source = aliasSource("progs/fixture.mdl")
  equal(entities.aliasFrame(source, -1, 0.0).name, "idle0", "negative frame falls back")
  equal(entities.aliasFrame(source, 99, 0.0).name, "idle0", "out-of-range frame falls back")
  equal(entities.aliasFrame(source, 1, 0.05).name, "idle0", "group first pose")
  equal(entities.aliasFrame(source, 1, 0.15).name, "idle1", "group timed pose")
  return true
end function

// Verify alias state branches against the expected Quake behavior.
function testAliasStateBranches()
  palette = bytes(768)
  renderer = t.EntityRenderer(void, palette, [void, aliasModel("progs/fixture.mdl")], 0)
  entity = aliasEntity(7, 1, 0, 0)

  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, true, false)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 13, "animated skin selects cl.time slot")
  equal(countCommand(commands, "shade_model"), 2, "smooth then flat shade state")
  require(countCommand(commands, "enable") >= 1, "alias enables culling")
  require(countCommand(commands, "disable") >= 1, "alias restores culling")
  equal(countCommand(commands, "texture_environment"), 2, "modulate then replace")

  entities.ConfigureAliasRendering(false, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false, false)
  commands = gl.Trace_End()
  equal(countCommand(commands, "shade_model"), 1, "flat-model branch skips smooth")

  entities.setTranslatedPlayerTexture(7, 77)
  entity.colormap = 1
  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false, false)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 77, "translated player texture")
  entities.ConfigureAliasRendering(true, false, false, true, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false, false)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 13, "gl_nocolors stock texture")

  eye = aliasModel("progs/eyes.mdl")
  eye.aliasModel.filename = "progs/eyes.mdl"
  renderer.models[1] = eye
  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false, false)
  commands = gl.Trace_End()
  require(hasTranslateZ(commands, 0.0), "double-eyes translates scale origin down by 30")

  entities.ConfigureAliasRendering(true, false, true, false, false)
  equal(entities.ConfigureEnhancedShadowQuality(0), 0, "low shadow quality")
  shadowWorld = shadowReceiverRenderer()
  renderWorld.R_ConfigureWorldCompatibility(
    shadowWorld,
    t.Vec3(10.0, 0.0, 8.0), t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  gl.Trace_Begin()
  renderWorld.R_ConfigureSpecialCompatibility(1.0, false, true, false, false)
  depthPlan = renderWorld.R_ClearProduction()
  if depthPlan[3] != gl.GL_GEQUAL then depthPlan = renderWorld.R_ClearProduction() end if
  entities.drawAlias(renderer, eye, entity, 0.0, false, false)
  commands = gl.Trace_End()
  equal(countCommand(commands, "push_matrix"), 2, "shadow has second entity transform")
  require(countCommand(commands, "begin") >= 2, "hard shadow adds one ray-projected triangle batch")
  require(countCommand(commands, "enable") >= 3, "shadow enables cull, blend and texture")
  require(countCommand(commands, "disable") >= 3, "shadow disables cull, texture and blend")
  equal(countCommand(commands, "texture_environment"), 4, "shadow forces black modulation then restores replace")
  equal(lastDepthFunction(commands), gl.GL_GEQUAL, "shadow preserves reversed z-trick depth comparison")
  // Leave the shared renderer state in its normal non-reversed mode for the
  // remaining production-path cases in this executable.
  renderWorld.R_ConfigureSpecialCompatibility(1.0, false, false, false, false)
  gl.Trace_Begin()
  renderWorld.R_ClearProduction()
  gl.Trace_End()

  lowPrimitiveCount = countCommand(commands, "begin")
  equal(entities.ConfigureEnhancedShadowQuality(1), 1, "medium shadow quality")
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false, false)
  mediumCommands = gl.Trace_End()
  mediumPrimitiveCount = countCommand(mediumCommands, "begin")
  require(mediumPrimitiveCount > lowPrimitiveCount, "medium shadow adds penumbra samples")
  equal(entities.ConfigureEnhancedShadowQuality(2), 2, "high shadow quality")
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false, false)
  highCommands = gl.Trace_End()
  require(countCommand(highCommands, "begin") > mediumPrimitiveCount, "high shadow adds the full cross-filter samples")
  entities.ConfigureEnhancedShadowQuality(0)

  // Move outside the finite receiver polygon. The vertical BSP query misses,
  // so an old lightspot from the preceding valid draw must not be reused.
  entity.origin.x = 200.0
  entity.origin.y = 200.0
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false, false)
  missedReceiverCommands = gl.Trace_End()
  equal(countCommand(missedReceiverCommands, "vertex"), 3, "receiver miss emits no stale projected shadow vertices")
  entity.origin.x = 1.0
  entity.origin.y = 2.0

  // Retail torch flames are alias MDLs, not sprites. They emit light but are
  // not opaque physical casters and must never be replayed onto the floor.
  flame = aliasModel("progs/flame.mdl")
  flame.aliasModel.filename = "progs/flame.mdl"
  renderer.models[1] = flame
  gl.Trace_Begin()
  entities.drawAlias(renderer, flame, entity, 0.0, false, false)
  commands = gl.Trace_End()
  equal(countCommand(commands, "push_matrix"), 1, "emissive flame skips projected shadow")
  require(not entities.aliasModelCastsShadow(flame), "flame classified as emissive")
  require(entities.aliasModelCastsShadow(eye), "opaque alias remains a shadow caster")
  equal(entities.ConfigureEnhancedShadowQuality(99), 2, "shadow quality clamps high")
  entities.ConfigureAliasRendering(true, false, false, false, true)
  return true
end function

// Verify opaque then sprite ordering against the expected Quake behavior.
function testOpaqueThenSpriteOrdering()
  alias = aliasModel("progs/fixture.mdl")
  sprite = spriteModel()
  renderer = t.EntityRenderer(void, bytes(768), [void, alias, sprite], 0)
  spriteEntity = aliasEntity(2, 2, 0, 0)
  aliasValue = aliasEntity(1, 1, 0, 0)
  gl.Trace_Begin()
  rendered = entities.render(
    renderer, void, [spriteEntity, aliasValue], 99,
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0), 0.0,
  )
  commands = gl.Trace_End()
  binds = []
  for each command in commands
    if command[0] == "bind_texture" then binds = binds + [command[1][1]] end if
  end for
  equal(rendered, 2, "both entities rendered")
  require(len(binds) >= 2, "both model textures bound")
  equal(binds[0], 11, "opaque alias pass precedes sprite")
  equal(binds[1], 22, "sprite pass follows opaque models")
  return true
end function

// Verify production projection depth against the expected Quake behavior.
function testProductionProjectionDepth()
  gl.Trace_Begin()
  renderWorld.setupViewRect(
    0, 0, 640, 480, 640, 480, 90.0, 73.739795,
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0),
  )
  commands = gl.Trace_End()
  for each command in commands
    if command[0] == "frustum" then
      equal(command[1][4], 4.0, "MiniQuake projection near plane")
      equal(command[1][5], 4096.0, "MiniQuake projection far plane")
      return true
    end if
  end for
  return error(9952, "production setupViewRect did not emit a frustum")
end function

// Verify mesh termination and cache branches against the expected Quake behavior.
function testMeshTerminationAndCacheBranches()
  model = aliasSource("progs/cache-branch.mdl")
  model.texCoords = [
    t.MdlTexCoord(0, 0, 0), t.MdlTexCoord(0, 3, 0),
    t.MdlTexCoord(0, 0, 3), t.MdlTexCoord(1, 3, 3),
  ]
  model.triangles = [
    t.MdlTriangle(0, 0, 1, 2),
    t.MdlTriangle(1, 2, 1, 3),
  ]
  aliasMesh.configureAliasModel(model)
  equal(aliasMesh.StripLength(0, 0), 1, "faces-front mismatch terminates strip")
  model.triangles[1].facesFront = 0
  aliasMesh.configureAliasModel(model)
  aliasMesh.used[1] = 1
  equal(aliasMesh.StripLength(0, 0), 1, "already-used triangle terminates strip")

  before = aliasMesh.alltris
  first = aliasMesh.GL_MakeAliasModelDisplayLists(model, model)
  afterBuild = aliasMesh.alltris
  second = aliasMesh.GL_MakeAliasModelDisplayLists(model, model)
  require(first == second, "mesh cache returns the existing display list")
  require(afterBuild > before, "first display-list request builds the mesh")
  equal(aliasMesh.alltris, afterBuild, "cache hit skips mesh rebuild")
  return true
end function

// Exercise external brush renderer as part of this deterministic regression fixture.
function externalBrushRenderer()
  normal = t.Vec3(1.0, 0.0, 0.0)
  plane = t.BspPlane(normal, 0.0, 0)
  face = t.BspFace(0, 0, 0, 3, 0, bytes([0, 255, 255, 255]), 0)
  info = t.BspTexInfo([0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], 0, 0)
  texture = t.BspTexture("medkit", 16, 16, [0, 0, 0, 0], bytes(256, 32))
  vertices = [
    t.BspVertex(t.Vec3(0.0, -8.0, -8.0)),
    t.BspVertex(t.Vec3(0.0, 8.0, -8.0)),
    t.BspVertex(t.Vec3(0.0, 0.0, 8.0)),
  ]
  edges = [t.BspEdge(0, 1), t.BspEdge(1, 2), t.BspEdge(2, 0)]
  model = t.BspModel(
    t.Vec3(0.0, -8.0, -8.0), t.Vec3(0.0, 8.0, 8.0),
    t.Vec3(0.0, 0.0, 0.0), [0, 0, 0, 0], 0, 0, 1,
  )
  map = t.BspMap(
    "maps/b_bh25.bsp", bytes(), 29, [], "", [], [plane], [texture], vertices,
    bytes(), [], [info], [face], bytes([64, 64, 64, 64]), [], [], [], edges,
    [0, 1, 2], [model],
  )
  palette = bytes(768, 64)
  return renderWorld.createExternal(map, palette)
end function

// Verify external brush draw path against the expected Quake behavior.
function testExternalBrushDrawPath()
  brush = externalBrushRenderer()
  model = t.ClientRenderModel("maps/b_bh25.bsp", entities.MODEL_BRUSH, void, void, brush, [], false)
  entity = aliasEntity(9, 1, 0, 0)
  entity.origin = t.Vec3(0.0, 0.0, 0.0)
  entity.angles = t.Vec3(0.0, 0.0, 0.0)
  activeWorld = t.WorldRenderer(void, bytes(), [], [], [], true, 0, false, false, 0, bytes(), 0, 1.0)
  renderWorld.R_ConfigureWorldCompatibility(
    activeWorld,
    t.Vec3(10.0, 0.0, 0.0),
    t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0),
    t.Vec3(0.0, -1.0, 0.0),
    t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  gl.Trace_Begin()
  drawn = entities.drawBrush(activeWorld, model, entity, 0.0)
  commands = gl.Trace_End()
  equal(drawn, 1, "external BSP visible face")
  equal(countCommand(commands, "upload_luminance"), 1, "external BSP lightmap upload")
  equal(countCommand(commands, "begin"), 2, "external BSP base and light passes")
  equal(countCommand(commands, "blend_function"), 2, "external BSP light blend and state restore")
  restoredBlend = lastBlendFunction(commands)
  equal(len(restoredBlend), 2, "external BSP restored blend arity")
  equal(restoredBlend[0], gl.GL_SRC_ALPHA, "external BSP restored source blend")
  equal(restoredBlend[1], gl.GL_ONE_MINUS_SRC_ALPHA, "external BSP restored destination blend")
  require(countCommand(commands, "bind_texture") >= 2, "external BSP binds base and lightmap")

  receiverWorld = shadowReceiverRenderer()
  renderWorld.R_ConfigureWorldCompatibility(
    receiverWorld,
    t.Vec3(10.0, 0.0, 8.0), t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  entity.origin.z = 10.0
  entities.ConfigureAliasRendering(true, false, true, false, true)
  equal(entities.ConfigureEnhancedShadowQuality(0), 0, "external BSP hard shadow quality")
  gl.Trace_Begin()
  shadowed = entities.renderSubmitted(
    t.EntityRenderer(void, bytes(768), [void, model], 0),
    activeWorld, [entity], void,
    t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0), 0.0,
  )
  commands = gl.Trace_End()
  equal(shadowed, 1, "external BSP pickup submitted with shadow")
  require(countCommand(commands, "begin") >= 3, "external BSP pickup emits a ray-projected shadow batch")

  renderWorld.R_ConfigureWorldCompatibility(
    receiverWorld,
    t.Vec3(10.0, 0.0, 8.0), t.Vec3(0.0, 0.0, 0.0),
    t.Vec3(1.0, 0.0, 0.0), t.Vec3(0.0, -1.0, 0.0), t.Vec3(0.0, 0.0, 1.0),
    [], [], [0.0, 0.0, 0.0, 0.0], 0.0, 0.0, 0.0,
    true, true, false,
  )
  entity.origin.x = 200.0
  entity.origin.y = 200.0
  gl.Trace_Begin()
  missedShadow = entities.drawBrushShadow(receiverWorld, model, entity, 0.0)
  missedBrushCommands = gl.Trace_End()
  equal(missedShadow, 0, "brush receiver miss emits no stale projected triangles")
  entities.ConfigureAliasRendering(true, false, false, false, true)
  return true
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  testRayShadowReceiverContinuity()
  print "[1/8] ray-shadow receiver-edge continuity"
  testFrameSelection()
  print "[2/8] alias frame selection"
  testAliasStateBranches()
  print "[3/8] alias GL state / lighting branches"
  testOpaqueThenSpriteOrdering()
  print "[4/8] opaque then sprite ordering"
  testProductionProjectionDepth()
  print "[5/8] production projection depth range"
  testMeshTerminationAndCacheBranches()
  print "[6/8] mesh termination and cache branches"
  testExternalBrushDrawPath()
  print "[7/8] external BSP pickup draw path"
  testRayShadowOcclusion()
  print "[8/8] ray-shadow wall receiver and occlusion"
  print "Alias renderer port tests passed."
  return 0
end function
