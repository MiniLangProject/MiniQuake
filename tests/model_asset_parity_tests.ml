import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.cvar as cvar
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as spriteFormat
import miniquake.model_registry as modelRegistry
import miniquake.world_bsp as world

function jsonFloat(value)
  return native.floatText(value)
end function

function boolInt(value)
  if value then return 1 end if
  return 0
end function

function putLump(data, index, offset, length)
  bio.putI32(data, 4 + index * 8, offset)
  bio.putI32(data, 8 + index * 8, length)
end function

function putFixed(data, offset, text, count)
  source = bytes(text)
  copied = len(source)
  if copied > count then copied = count end if
  bio.copyInto(data, offset, source, 0, copied)
end function

function writeTextures(data, base)
  bio.putI32(data, base, 4)
  names = ["+0fixture", "+1fixture", "+Afixture", "+Bfixture"]
  cursor = base + 20
  index = 0
  while index < 4
    bio.putI32(data, base + 4 + index * 4, cursor - base)
    putFixed(data, cursor, names[index], 16)
    bio.putI32(data, cursor + 16, 16)
    bio.putI32(data, cursor + 20, 16)
    bio.putI32(data, cursor + 24, 40)
    bio.putI32(data, cursor + 28, 296)
    bio.putI32(data, cursor + 32, 360)
    bio.putI32(data, cursor + 36, 376)
    pixel = 0
    while pixel < 340
      data[cursor + 40 + pixel] = index + 1
      pixel = pixel + 1
    end while
    cursor = cursor + 380
    index = index + 1
  end while
  return cursor - base
end function

function makeBsp()
  data = bytes(4096)
  bio.putI32(data, 0, c.BSP_VERSION)
  cursor = 124

  entityText = bytes("{\n\"classname\" \"worldspawn\"\n}\n")
  entityLength = len(entityText) + 1
  putLump(data, c.LUMP_ENTITIES, cursor, entityLength)
  bio.copyInto(data, cursor, entityText, 0, len(entityText))
  cursor = cursor + entityLength

  putLump(data, c.LUMP_PLANES, cursor, 20)
  bio.putF32(data, cursor + 8, -1.0)
  bio.putF32(data, cursor + 12, 2.0)
  bio.putI32(data, cursor + 16, 2)
  cursor = cursor + 20

  textureLength = writeTextures(data, cursor)
  putLump(data, c.LUMP_TEXTURES, cursor, textureLength)
  cursor = cursor + textureLength

  putLump(data, c.LUMP_VERTEXES, cursor, 24)
  bio.putF32(data, cursor, 17.0)
  bio.putF32(data, cursor + 4, -2.0)
  bio.putF32(data, cursor + 8, 3.0)
  bio.putF32(data, cursor + 12, 33.0)
  bio.putF32(data, cursor + 16, 14.0)
  bio.putF32(data, cursor + 20, 3.0)
  cursor = cursor + 24

  putLump(data, c.LUMP_VISIBILITY, cursor, 2)
  data[cursor] = 1
  data[cursor + 1] = 0
  cursor = cursor + 2

  putLump(data, c.LUMP_NODES, cursor, 24)
  bio.putI32(data, cursor, 0)
  bio.putI16(data, cursor + 4, -1)
  bio.putI16(data, cursor + 6, -1)
  bio.putI16(data, cursor + 8, -8)
  bio.putI16(data, cursor + 10, -9)
  bio.putI16(data, cursor + 12, -10)
  bio.putI16(data, cursor + 14, 8)
  bio.putI16(data, cursor + 16, 9)
  bio.putI16(data, cursor + 18, 10)
  bio.putU16(data, cursor + 20, 0)
  bio.putU16(data, cursor + 22, 1)
  cursor = cursor + 24

  putLump(data, c.LUMP_TEXINFO, cursor, 40)
  bio.putF32(data, cursor, 1.0)
  bio.putF32(data, cursor + 20, 1.0)
  bio.putI32(data, cursor + 32, 0)
  bio.putI32(data, cursor + 36, 5)
  cursor = cursor + 40

  putLump(data, c.LUMP_FACES, cursor, 20)
  bio.putU16(data, cursor, 0)
  bio.putI16(data, cursor + 2, 0)
  bio.putI32(data, cursor + 4, 0)
  bio.putU16(data, cursor + 8, 1)
  bio.putU16(data, cursor + 10, 0)
  data[cursor + 12] = 3
  data[cursor + 13] = 255
  data[cursor + 14] = 255
  data[cursor + 15] = 255
  bio.putI32(data, cursor + 16, 0)
  cursor = cursor + 20

  putLump(data, c.LUMP_LIGHTING, cursor, 3)
  data[cursor] = 9
  data[cursor + 1] = 8
  data[cursor + 2] = 7
  cursor = cursor + 3

  putLump(data, c.LUMP_CLIPNODES, cursor, 8)
  bio.putI32(data, cursor, 0)
  bio.putI16(data, cursor + 4, c.CONTENTS_EMPTY)
  bio.putI16(data, cursor + 6, c.CONTENTS_SOLID)
  cursor = cursor + 8

  putLump(data, c.LUMP_LEAFS, cursor, 28)
  bio.putI32(data, cursor, c.CONTENTS_SOLID)
  bio.putI32(data, cursor + 4, 0)
  bio.putU16(data, cursor + 20, 0)
  bio.putU16(data, cursor + 22, 1)
  data[cursor + 24] = 11
  data[cursor + 25] = 12
  data[cursor + 26] = 13
  data[cursor + 27] = 14
  cursor = cursor + 28

  putLump(data, c.LUMP_MARKSURFACES, cursor, 2)
  bio.putU16(data, cursor, 0)
  cursor = cursor + 2

  putLump(data, c.LUMP_EDGES, cursor, 4)
  bio.putU16(data, cursor, 0)
  bio.putU16(data, cursor + 2, 1)
  cursor = cursor + 4

  putLump(data, c.LUMP_SURFEDGES, cursor, 4)
  bio.putI32(data, cursor, 0)
  cursor = cursor + 4

  putLump(data, c.LUMP_MODELS, cursor, 64)
  bio.putF32(data, cursor, -3.0)
  bio.putF32(data, cursor + 4, -4.0)
  bio.putF32(data, cursor + 8, 0.0)
  bio.putF32(data, cursor + 12, 2.0)
  bio.putF32(data, cursor + 16, 1.0)
  bio.putF32(data, cursor + 20, 12.0)
  bio.putI32(data, cursor + 36, 0)
  bio.putI32(data, cursor + 40, 0)
  bio.putI32(data, cursor + 44, 0)
  bio.putI32(data, cursor + 48, 0)
  bio.putI32(data, cursor + 52, 9)
  bio.putI32(data, cursor + 56, 0)
  bio.putI32(data, cursor + 60, 1)
  cursor = cursor + 64
  return slice(data, 0, cursor)
end function

function writeAliasFrame(data, offset, name, base, numVertices)
  data[offset] = base
  data[offset + 4] = base + 10
  putFixed(data, offset + 8, name, 16)
  vertex = 0
  while vertex < numVertices
    data[offset + 24 + vertex * 4] = base + vertex
    data[offset + 25 + vertex * 4] = base + vertex + 1
    data[offset + 26 + vertex * 4] = base + vertex + 2
    data[offset + 27 + vertex * 4] = vertex
    vertex = vertex + 1
  end while
  return offset + 24 + numVertices * 4
end function

function makeMdl()
  data = bytes(512)
  putFixed(data, 0, "IDPO", 4)
  bio.putI32(data, 4, c.MDL_VERSION)
  bio.putF32(data, 8, 1.0)
  bio.putF32(data, 12, 2.0)
  bio.putF32(data, 16, 3.0)
  bio.putF32(data, 20, 4.0)
  bio.putF32(data, 32, 20.0)
  bio.putF32(data, 44, 7.0)
  bio.putI32(data, 48, 1)
  bio.putI32(data, 52, 2)
  bio.putI32(data, 56, 2)
  bio.putI32(data, 60, 3)
  bio.putI32(data, 64, 1)
  bio.putI32(data, 68, 1)
  bio.putI32(data, 72, 1)
  bio.putI32(data, 76, 9)
  bio.putF32(data, 80, 11.0)
  cursor = 84

  bio.putI32(data, cursor, 1)
  bio.putI32(data, cursor + 4, 2)
  bio.putF32(data, cursor + 8, 0.1)
  bio.putF32(data, cursor + 12, 0.2)
  data[cursor + 16] = 1
  data[cursor + 17] = 1
  data[cursor + 18] = 1
  data[cursor + 19] = 1
  data[cursor + 20] = 2
  data[cursor + 21] = 2
  data[cursor + 22] = 2
  data[cursor + 23] = 2
  cursor = cursor + 24

  bio.putI32(data, cursor + 12 + 4, 8)
  bio.putI32(data, cursor + 24 + 8, 12)
  cursor = cursor + 36
  bio.putI32(data, cursor, 1)
  bio.putI32(data, cursor + 4, 0)
  bio.putI32(data, cursor + 8, 1)
  bio.putI32(data, cursor + 12, 2)
  cursor = cursor + 16

  bio.putI32(data, cursor, 1)
  cursor = cursor + 4
  bio.putI32(data, cursor, 2)
  data[cursor + 4] = 3
  data[cursor + 8] = 33
  bio.putF32(data, cursor + 12, 0.15)
  bio.putF32(data, cursor + 16, 0.30)
  cursor = writeAliasFrame(data, cursor + 20, "pose0", 5, 3)
  cursor = writeAliasFrame(data, cursor, "pose1", 9, 3)
  return slice(data, 0, cursor)
end function

function writeSpriteFrame(data, offset, x, y, base)
  bio.putI32(data, offset, x)
  bio.putI32(data, offset + 4, y)
  bio.putI32(data, offset + 8, 2)
  bio.putI32(data, offset + 12, 2)
  data[offset + 16] = base
  data[offset + 17] = base + 1
  data[offset + 18] = base + 2
  data[offset + 19] = base + 3
  return offset + 20
end function

function makeSprite()
  data = bytes(128)
  putFixed(data, 0, "IDSP", 4)
  bio.putI32(data, 4, c.SPRITE_VERSION)
  bio.putI32(data, 8, 3)
  bio.putF32(data, 12, 8.0)
  bio.putI32(data, 16, 2)
  bio.putI32(data, 20, 2)
  bio.putI32(data, 24, 1)
  bio.putF32(data, 28, 3.5)
  bio.putI32(data, 32, 1)
  bio.putI32(data, 36, 1)
  bio.putI32(data, 40, 2)
  bio.putF32(data, 44, 0.1)
  bio.putF32(data, 48, 0.25)
  cursor = writeSpriteFrame(data, 52, -2, 3, 10)
  cursor = writeSpriteFrame(data, cursor, 4, 5, 20)
  return slice(data, 0, cursor)
end function

function makeFilesystem(bspData, mdlData, spriteData)
  total = bytes(len(bspData) + len(mdlData) + len(spriteData))
  bio.copyInto(total, 0, bspData, 0, len(bspData))
  bio.copyInto(total, len(bspData), mdlData, 0, len(mdlData))
  bio.copyInto(total, len(bspData) + len(mdlData), spriteData, 0, len(spriteData))
  files = [
    t.PackFile("maps/fixture.bsp", 0, len(bspData)),
    t.PackFile("progs/fixture.mdl", len(bspData), len(mdlData)),
    t.PackFile("progs/fixture.spr", len(bspData) + len(mdlData), len(spriteData)),
  ]
  archive = t.PackArchive("synthetic.pak", total, files, 3)
  return t.FileSystem("", "id1", [t.SearchPath("", archive)], "", false, true, true, false)
end function


function bp073Equal(actual, expected, name)
  if actual != expected then return error(10730, name + ": expected " + expected + ", got " + actual) end if
  return true
end function

function bp073True(value, name)
  if value != true then return error(10731, name + ": expected true") end if
  return true
end function

function bp073Fixture()
  bspData = makeBsp()
  mdlData = makeMdl()
  spriteData = makeSprite()
  filesystem = makeFilesystem(bspData, mdlData, spriteData)
  return [bspData, mdlData, spriteData, filesystem]
end function

function bp073LoadAll()
  fixture = bp073Fixture()
  brush = bsp.Mod_LoadBrushModel(fixture[0], "maps/fixture.bsp")
  alias = mdl.Mod_LoadAliasModel(fixture[1], "progs/fixture.mdl")
  spriteModel = spriteFormat.Mod_LoadSpriteModel(fixture[2], "progs/fixture.spr")
  return [brush, alias, spriteModel, fixture[3]]
end function

function bp073Case01()
  values = bp073LoadAll(); brush = values[0]
  bp073Equal(brush.version, c.BSP_VERSION, "BSP version")
  bp073Equal(brush.filename, "maps/fixture.bsp", "BSP filename")
  bp073Equal(len(brush.lumps), c.HEADER_LUMPS, "BSP lump count")
  return true
end function

function bp073Case02()
  brush = bp073LoadAll()[0]
  bp073Equal(len(brush.entities), 1, "entity count")
  bp073Equal(bsp.entityValue(brush.entities[0], "classname"), "worldspawn", "worldspawn")
  bp073Equal(bytes(brush.entityText)[0], 123, "entity text byte")
  return true
end function

function bp073Case03()
  brush = bp073LoadAll()[0]
  animations = bsp.sequenceTextureAnimations(brush.textures)
  bp073Equal(len(brush.textures), 4, "texture count")
  bp073Equal(brush.textures[0].name, "+0fixture", "animation base name")
  bp073Equal(animations[0][0], 4, "animation total")
  bp073Equal(animations[0][3], 1, "animation primary next")
  bp073Equal(animations[0][4], 2, "animation alternate")
  return true
end function

function bp073Case04()
  brush = bp073LoadAll()[0]
  bp073Equal(len(brush.vertices), 2, "vertex count")
  bp073Equal(len(brush.edges), 1, "edge count")
  bp073Equal(len(brush.faces), 1, "face count")
  bp073Equal(brush.edges[0].vertex1, 1, "edge vertex")
  return true
end function

function bp073Case05()
  brush = bp073LoadAll()[0]
  bp073Equal(len(brush.visibility), 2, "visibility length")
  bp073Equal(brush.visibility[0], 1, "visibility byte")
  bp073Equal(len(brush.lighting), 3, "lighting length")
  bp073Equal(brush.lighting[2], 7, "lighting byte")
  return true
end function

function bp073Case06()
  brush = bp073LoadAll()[0]
  model = brush.models[0]
  bp073Equal(model.mins.x, -4.0, "brush mins x")
  bp073Equal(model.mins.y, -5.0, "brush mins y")
  bp073Equal(model.mins.z, -1.0, "brush mins z")
  bp073Equal(model.maxs.x, 3.0, "brush maxs x")
  bp073Equal(model.maxs.y, 2.0, "brush maxs y")
  bp073Equal(model.maxs.z, 13.0, "brush maxs z")
  bp073Equal(model.visibleLeafs, 9, "visible leafs")
  return true
end function

function bp073Case07()
  alias = bp073LoadAll()[1]
  bp073Equal(alias.version, c.MDL_VERSION, "MDL version")
  bp073Equal(alias.numVertices, 3, "MDL vertices")
  bp073Equal(alias.numTriangles, 1, "MDL triangles")
  bp073Equal(alias.numFrames, 1, "MDL frames")
  return true
end function

function bp073Case08()
  alias = bp073LoadAll()[1]
  skin = alias.skins[0]
  bp073True(skin.grouped, "grouped skin")
  bp073Equal(len(skin.intervals), 2, "skin intervals")
  bp073Equal(len(skin.images), 2, "skin images")
  bp073Equal(len(skin.images[0]), 4, "skin bytes")
  return true
end function

function bp073Case09()
  alias = bp073LoadAll()[1]
  frameSet = alias.frames[0]
  bp073True(frameSet.grouped, "grouped frames")
  bp073Equal(len(frameSet.frames), 2, "frame poses")
  bp073Equal(frameSet.frames[0].name, "pose0", "first pose name")
  bp073Equal(frameSet.frames[1].name, "pose1", "second pose name")
  return true
end function

function bp073Case10()
  alias = bp073LoadAll()[1]
  bp073Equal(len(alias.texCoords), 3, "texture coords")
  bp073Equal(alias.texCoords[1].s, 8, "texture coord s")
  bp073Equal(alias.triangles[0].vertex2, 2, "triangle vertex")
  return true
end function

function bp073Case11()
  skin = bytes([1, 1, 2, 1])
  mdl.Mod_FloodFillSkin(skin, 2, 2)
  bp073Equal(skin[0], 2, "flood fill first")
  bp073Equal(skin[3], 2, "flood fill last")
  return true
end function

function bp073Case12()
  spriteModel = bp073LoadAll()[2]
  bp073Equal(spriteModel.version, c.SPRITE_VERSION, "sprite version")
  bp073Equal(spriteModel.type, 3, "sprite type")
  bp073Equal(spriteModel.numFrames, 1, "sprite frames")
  bp073True(spriteModel.frames[0].grouped, "sprite group")
  return true
end function

function bp073Case13()
  spriteModel = bp073LoadAll()[2]
  frame = spriteModel.frames[0].frames[0]
  bounds = spriteFormat.spriteFrameBounds(frame)
  modelBounds = spriteFormat.spriteModelBounds(spriteModel)
  bp073Equal(bounds[0], 3, "frame top")
  bp073Equal(bounds[3], 0, "frame right")
  bp073Equal(modelBounds[0].x, -1.0, "sprite model min")
  bp073Equal(modelBounds[1].z, 1.0, "sprite model max")
  return true
end function

function bp073Case14()
  fixture = bp073Fixture(); filesystem = fixture[3]
  registry = modelRegistry.create()
  brush = modelRegistry.Mod_ForName(registry, filesystem, "maps/fixture.bsp", true)
  alias = modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  spriteModel = modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.spr", true)
  bp073Equal(modelRegistry.modelType(registry, "maps/fixture.bsp"), modelRegistry.MOD_BRUSH, "brush dispatch")
  bp073Equal(modelRegistry.modelType(registry, "progs/fixture.mdl"), modelRegistry.MOD_ALIAS, "alias dispatch")
  bp073Equal(modelRegistry.modelType(registry, "progs/fixture.spr"), modelRegistry.MOD_SPRITE, "sprite dispatch")
  return true
end function

function bp073Case15()
  registry = modelRegistry.create()
  upper = modelRegistry.Mod_FindName(registry, "PROGS/PLAYER.MDL")
  lower = modelRegistry.Mod_FindName(registry, "progs/player.mdl")
  bp073True(upper != lower, "case-sensitive model identity")
  return true
end function

function bp073Case16()
  values = bp073LoadAll(); filesystem = values[3]
  registry = modelRegistry.create()
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  index = modelRegistry.findIndex(registry, "progs/fixture.mdl")
  registry.touched[index] = false
  modelRegistry.Mod_TouchModel(registry, "progs/fixture.mdl")
  bp073True(registry.touched[index], "touch alias")
  return true
end function

function bp073Case17()
  values = bp073LoadAll(); filesystem = values[3]
  registry = modelRegistry.create()
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  index = modelRegistry.findIndex(registry, "progs/fixture.mdl")
  extra = modelRegistry.Mod_Extradata(registry, filesystem, index)
  bp073Equal(extra.numFrames, 1, "extradata frames")
  return true
end function

function bp073Case18()
  fixture = bp073Fixture(); filesystem = fixture[3]
  registry = modelRegistry.create()
  modelRegistry.Mod_ForName(registry, filesystem, "maps/fixture.bsp", true)
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.spr", true)
  modelRegistry.Mod_ClearAll(registry)
  bp073True(registry.needLoad[modelRegistry.findIndex(registry, "maps/fixture.bsp")], "brush reload")
  bp073True(not registry.needLoad[modelRegistry.findIndex(registry, "progs/fixture.mdl")], "alias cache retained")
  bp073True(registry.needLoad[modelRegistry.findIndex(registry, "progs/fixture.spr")], "sprite reload")
  return true
end function

function bp073Case19()
  fixture = bp073Fixture(); filesystem = fixture[3]
  registry = modelRegistry.create()
  bp073Equal(modelRegistry.Mod_ForName(registry, filesystem, "missing.bin", false), void, "nonfatal missing")
  bp073True(try(modelRegistry.Mod_ForName(registry, filesystem, "missing.bin", true)) is error, "fatal missing")
  return true
end function

function bp073Case20()
  brush = bp073LoadAll()[0]
  brush.models = brush.models + [brush.models[0]]
  registry = modelRegistry.create()
  count = modelRegistry.registerBrushSubmodels(registry, brush)
  bp073Equal(count, 1, "submodel count")
  bp073Equal(modelRegistry.modelType(registry, "*1"), modelRegistry.MOD_BRUSH, "submodel type")
  return true
end function

function bp073Case21()
  data = makeBsp(); bio.putI32(data, 0, c.BSP_VERSION + 1)
  bp073True(try(bsp.Mod_LoadBrushModel(data, "bad.bsp")) is error, "BSP version rejection")
  return true
end function

function bp073Case22()
  data = makeMdl(); bio.putI32(data, 4, c.MDL_VERSION + 1)
  bp073True(try(mdl.Mod_LoadAliasModel(data, "bad.mdl")) is error, "MDL version rejection")
  data = makeMdl(); bio.putI32(data, 60, 0)
  bp073True(try(mdl.Mod_LoadAliasModel(data, "empty.mdl")) is error, "MDL vertex rejection")
  return true
end function

function bp073Case23()
  data = makeSprite(); bio.putF32(data, 44, 0.0)
  bp073True(try(spriteFormat.Mod_LoadSpriteModel(data, "bad.spr")) is error, "sprite interval rejection")
  data = makeSprite(); bio.putI32(data, 4, c.SPRITE_VERSION + 1)
  bp073True(try(spriteFormat.Mod_LoadSpriteModel(data, "version.spr")) is error, "sprite version rejection")
  return true
end function

function bp073Case24()
  fixture = bp073Fixture(); filesystem = fixture[3]
  registry = modelRegistry.create()
  modelRegistry.Mod_ForName(registry, filesystem, "maps/fixture.bsp", true)
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  modelRegistry.Mod_ForName(registry, filesystem, "progs/fixture.spr", true)
  brushBounds = modelRegistry.modelBounds(registry, "maps/fixture.bsp")
  aliasBounds = modelRegistry.modelBounds(registry, "progs/fixture.mdl")
  spriteBounds = modelRegistry.modelBounds(registry, "progs/fixture.spr")
  bp073Equal(brushBounds[0].x, -4.0, "registry brush bounds")
  bp073Equal(aliasBounds[1].z, 16.0, "registry alias bounds")
  bp073Equal(spriteBounds[1].x, 1.0, "registry sprite bounds")
  bp073True(modelRegistry.modelRadius(registry, "maps/fixture.bsp") > 12.0, "registry radius")
  return true
end function

function bp073Run(index, name, callback)
  print "[" + index + "/24] " + name
  result = try(callback())
  if result is error then print "FAIL: " + result.message; return false end if
  return true
end function

function main(args)
  callbacks=[bp073Case01,bp073Case02,bp073Case03,bp073Case04,bp073Case05,bp073Case06,bp073Case07,bp073Case08,bp073Case09,bp073Case10,bp073Case11,bp073Case12,bp073Case13,bp073Case14,bp073Case15,bp073Case16,bp073Case17,bp073Case18,bp073Case19,bp073Case20,bp073Case21,bp073Case22,bp073Case23,bp073Case24]
  names=["BSP header","BSP entities","BSP textures","BSP geometry","BSP visibility/light","BSP submodel","MDL header","MDL grouped skin","MDL grouped frames","MDL mesh","MDL flood fill","sprite header","sprite bounds","registry dispatch","registry case","registry touch","registry extradata","registry clear","registry missing","brush submodels","invalid BSP","invalid MDL","invalid sprite","registry bounds"]
  index=0
  while index<len(callbacks)
    if not bp073Run(index+1,names[index],callbacks[index]) then return 1 end if
    index=index+1
  end while
  print "MiniQuake BP-073 model asset tests passed: 24"
  return 0
end function
