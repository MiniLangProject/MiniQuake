/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2026 MiniQuake contributors

Production-path branch tests for the alias/viewmodel part of gl_rmain.c.
*/

import miniquake.types as t
import miniquake.render.entities as entities
import miniquake.render.gl11 as gl
import miniquake.render.world as renderWorld
import miniquake.render.alias_mesh as aliasMesh

function require(value, name)
  if not value then return error(9950, name) end if
  return true
end function

function equal(actual, expected, name)
  if actual != expected then return error(9951, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function countCommand(commands, name)
  count = 0
  for each command in commands
    if command[0] == name then count = count + 1 end if
  end for
  return count
end function

function firstTexture(commands)
  for each command in commands
    if command[0] == "bind_texture" and len(command[1]) > 1 then return command[1][1] end if
  end for
  return -1
end function

function hasTranslateZ(commands, expected)
  for each command in commands
    if command[0] == "translate" and len(command[1]) >= 3 and command[1][2] == expected then return true end if
  end for
  return false
end function

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

function aliasModel(name)
  return t.ClientRenderModel(name, entities.MODEL_ALIAS, aliasSource(name), void, [[11, 12, 13, 14]], true)
end function

function aliasEntity(number, modelIndex, frame, colormap)
  return t.ClientEntityState(
    number, modelIndex, frame, colormap, 0, 0,
    t.Vec3(1.0, 2.0, 3.0), t.Vec3(10.0, 20.0, 30.0), 0.0,
    t.Vec3(1.0, 2.0, 3.0), t.Vec3(1.0, 2.0, 3.0),
    t.Vec3(10.0, 20.0, 30.0), t.Vec3(10.0, 20.0, 30.0),
    false, [], 0.0,
  )
end function

function spriteModel()
  frame = t.SpriteFrame(1.0, 1.0, 2, 2, bytes(4))
  source = t.SpriteModel("progs/fixture.spr", bytes(), 1, 0, 2.0, 2, 2, 1, 0.0, 0, [
    t.SpriteFrameSet(false, [], [frame]),
  ])
  return t.ClientRenderModel(source.filename, entities.MODEL_SPRITE, void, source, [[22]], true)
end function

function testFrameSelection()
  source = aliasSource("progs/fixture.mdl")
  equal(entities.aliasFrame(source, -1, 0.0).name, "idle0", "negative frame falls back")
  equal(entities.aliasFrame(source, 99, 0.0).name, "idle0", "out-of-range frame falls back")
  equal(entities.aliasFrame(source, 1, 0.05).name, "idle0", "group first pose")
  equal(entities.aliasFrame(source, 1, 0.15).name, "idle1", "group timed pose")
  return true
end function

function testAliasStateBranches()
  palette = bytes(768)
  renderer = t.EntityRenderer(void, palette, [void, aliasModel("progs/fixture.mdl")], 0)
  entity = aliasEntity(7, 1, 0, 0)

  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, true)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 13, "animated skin selects cl.time slot")
  equal(countCommand(commands, "shade_model"), 2, "smooth then flat shade state")
  require(countCommand(commands, "enable") >= 1, "alias enables culling")
  require(countCommand(commands, "disable") >= 1, "alias restores culling")
  equal(countCommand(commands, "texture_environment"), 2, "modulate then replace")

  entities.ConfigureAliasRendering(false, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false)
  commands = gl.Trace_End()
  equal(countCommand(commands, "shade_model"), 1, "flat-model branch skips smooth")

  entities.setTranslatedPlayerTexture(7, 77)
  entity.colormap = 1
  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 77, "translated player texture")
  entities.ConfigureAliasRendering(true, false, false, true, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, renderer.models[1], entity, 0.25, false)
  commands = gl.Trace_End()
  equal(firstTexture(commands), 13, "gl_nocolors stock texture")

  eye = aliasModel("progs/eyes.mdl")
  eye.aliasModel.filename = "progs/eyes.mdl"
  renderer.models[1] = eye
  entities.ConfigureAliasRendering(true, false, false, false, true)
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false)
  commands = gl.Trace_End()
  require(hasTranslateZ(commands, 0.0), "double-eyes translates scale origin down by 30")

  entities.ConfigureAliasRendering(true, false, true, false, false)
  gl.Trace_Begin()
  entities.drawAlias(renderer, eye, entity, 0.0, false)
  commands = gl.Trace_End()
  equal(countCommand(commands, "push_matrix"), 2, "shadow has second entity transform")
  require(countCommand(commands, "enable") >= 3, "shadow enables cull, blend and texture")
  require(countCommand(commands, "disable") >= 3, "shadow disables cull, texture and blend")
  entities.ConfigureAliasRendering(true, false, false, false, true)
  return true
end function

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

function testProductionProjectionDepth()
  gl.Trace_Begin()
  renderWorld.setupViewRect(
    0, 0, 640, 480, 640, 480, 90.0, 73.739795,
    t.Vec3(0.0, 0.0, 0.0), t.Vec3(0.0, 0.0, 0.0),
  )
  commands = gl.Trace_End()
  for each command in commands
    if command[0] == "frustum" then
      equal(command[1][4], 4.0, "GLQuake projection near plane")
      equal(command[1][5], 4096.0, "GLQuake projection far plane")
      return true
    end if
  end for
  return error(9952, "production setupViewRect did not emit a frustum")
end function

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

function main(args)
  testFrameSelection()
  print "[1/5] alias frame selection"
  testAliasStateBranches()
  print "[2/5] alias GL state / lighting branches"
  testOpaqueThenSpriteOrdering()
  print "[3/5] opaque then sprite ordering"
  testProductionProjectionDepth()
  print "[4/5] production projection depth range"
  testMeshTerminationAndCacheBranches()
  print "[5/5] mesh termination and cache branches"
  print "Alias renderer port tests passed."
  return 0
end function
