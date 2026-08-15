/*
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang parity and regression tests for tests/gl_model_differential_fixture.ml.
*/
import miniquake.types as t
import miniquake.constants as c
import miniquake.byteio as bio
import miniquake.native as native
import miniquake.cvar as cvar
import miniquake.format.bsp as bsp
import miniquake.format.mdl as mdl
import miniquake.format.sprite as spriteFormat
import miniquake.model_registry as registryModule
import miniquake.world_bsp as world

// Exercise json float as part of this deterministic regression fixture.
function jsonFloat(value)
  return native.floatText(value)
end function

// Exercise bool int as part of this deterministic regression fixture.
function boolInt(value)
  if value then return 1 end if
  return 0
end function

// Encode and write lump.
function putLump(data, index, offset, length)
  bio.putI32(data, 4 + index * 8, offset)
  bio.putI32(data, 8 + index * 8, length)
end function

// Encode and write fixed.
function putFixed(data, offset, text, count)
  source = bytes(text)
  copied = len(source)
  if copied > count then copied = count end if
  bio.copyInto(data, offset, source, 0, copied)
end function

// Encode and write textures.
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

// Create and initialize bsp.
function makeBsp()
  // Set up deterministic fixtures first, then exercise parity cases and aggregate failures.
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

// Encode and write alias frame.
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

// Create and initialize mdl.
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

// Encode and write sprite frame.
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

// Create and initialize sprite.
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

// Create and initialize filesystem.
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

// Return fatal mode derived from the active module state.
function fatalMode(mode)
  if mode == "bsp-version" then
    data = makeBsp()
    bio.putI32(data, 0, 30)
    result = try(bsp.Mod_LoadBrushModel(data, "bad.bsp"))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "mdl-vertices" then
    data = makeMdl()
    bio.putI32(data, 60, 0)
    result = try(mdl.Mod_LoadAliasModel(data, "bad.mdl"))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "sprite-interval" then
    data = makeSprite()
    bio.putF32(data, 44, 0.0)
    result = try(spriteFormat.Mod_LoadSpriteModel(data, "bad.spr"))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "lump-size" then
    result = try(bsp.Mod_LoadVertexes(bytes(1), t.Lump(0, 1)))
    if result is error then return 86 end if
    return 0
  end if
  return 2
end function

// Parse command-line arguments and run the selected operation.
function main(args)
  if len(args) == 2 and args[0] == "--fatal" then return fatalMode(args[1]) end if

  bspData = makeBsp()
  mdlData = makeMdl()
  spriteData = makeSprite()
  filesystem = makeFilesystem(bspData, mdlData, spriteData)
  registry = registryModule.create()
  cvars = cvar.createRegistry()
  registryModule.Mod_Init(registry, cvars)
  print "{\"function\":\"Mod_Init\",\"scene\":\"init\",\"cvars\":" + len(cvars.variables) + ",\"novis\":[" + registry.noVis[0] + "," + registry.noVis[1023] + "]}"

  brush = registryModule.Mod_ForName(registry, filesystem, "maps/fixture.bsp", true)
  alias = registryModule.Mod_ForName(registry, filesystem, "progs/fixture.mdl", true)
  spriteIndex = registryModule.Mod_FindName(registry, "progs/fixture.spr")
  spriteModel = registryModule.Mod_LoadModel(registry, filesystem, spriteIndex, true)
  missing = registryModule.Mod_ForName(registry, filesystem, "missing.bin", false)
  print "{\"function\":\"Mod_ForName\",\"scene\":\"registry-dispatch\",\"brush\":" + registryModule.MOD_BRUSH + ",\"alias\":" + registryModule.MOD_ALIAS + ",\"missing\":" + boolInt(missing is void) + "}"
  print "{\"function\":\"Mod_LoadModel\",\"scene\":\"registry-dispatch\",\"sprite\":" + registry.types[spriteIndex] + ",\"needload\":" + boolInt(registry.needLoad[spriteIndex]) + "}"

  upper = registryModule.Mod_FindName(registry, "PROGS/PLAYER.MDL")
  lower = registryModule.Mod_FindName(registry, "progs/player.mdl")
  print "{\"function\":\"Mod_FindName\",\"scene\":\"registry-case\",\"different\":" + boolInt(upper != lower) + ",\"count\":" + len(registry.names) + "}"
  registry.touched[registryModule.findIndex(registry, "progs/fixture.mdl")] = false
  registryModule.Mod_TouchModel(registry, "progs/fixture.mdl")
  print "{\"function\":\"Mod_TouchModel\",\"scene\":\"cache-touch\",\"checks\":" + boolInt(registry.touched[registryModule.findIndex(registry, "progs/fixture.mdl")]) + "}"
  aliasIndex = registryModule.findIndex(registry, "progs/fixture.mdl")
  aliasExtra = registryModule.Mod_Extradata(registry, filesystem, aliasIndex)
  print "{\"function\":\"Mod_Extradata\",\"scene\":\"cache-touch\",\"frames\":" + aliasExtra.numFrames + ",\"poses\":" + len(aliasExtra.frames[0].frames) + "}"

  animations = bsp.sequenceTextureAnimations(brush.textures)
  print "{\"function\":\"Mod_LoadTextures\",\"scene\":\"bsp29\",\"count\":" + len(brush.textures) + ",\"anim\":[" + animations[0][0] + "," + boolInt(animations[0][3] == 1) + "," + boolInt(animations[0][4] == 2) + "," + boolInt(len(brush.textures) == 4) + "]}"
  print "{\"function\":\"Mod_LoadLighting\",\"scene\":\"bsp29\",\"bytes\":[" + brush.lighting[0] + "," + brush.lighting[1] + "," + brush.lighting[2] + "]}"
  print "{\"function\":\"Mod_LoadVisibility\",\"scene\":\"bsp29\",\"bytes\":[" + brush.visibility[0] + "," + brush.visibility[1] + "]}"
  print "{\"function\":\"Mod_LoadEntities\",\"scene\":\"bsp29\",\"first\":" + bytes(brush.entityText)[0] + ",\"worldspawn\":" + boolInt(bsp.entityValue(brush.entities[0], "classname") == "worldspawn") + "}"
  vertex = brush.vertices[0].position
  print "{\"function\":\"Mod_LoadVertexes\",\"scene\":\"bsp29\",\"count\":" + len(brush.vertices) + ",\"first\":[" + jsonFloat(vertex.x) + "," + jsonFloat(vertex.y) + "," + jsonFloat(vertex.z) + "]}"
  print "{\"function\":\"Mod_LoadSubmodels\",\"scene\":\"bsp29\",\"count\":" + len(brush.models) + ",\"bounds\":[" + jsonFloat(brush.models[0].mins.x) + "," + jsonFloat(brush.models[0].maxs.z) + "]}"
  print "{\"function\":\"Mod_LoadEdges\",\"scene\":\"bsp29\",\"count\":" + len(brush.edges) + ",\"edge\":[" + brush.edges[0].vertex0 + "," + brush.edges[0].vertex1 + "]}"
  print "{\"function\":\"Mod_LoadTexinfo\",\"scene\":\"bsp29\",\"count\":" + len(brush.texInfo) + ",\"mipadjust\":" + bsp.texInfoMipAdjust(brush.texInfo[0]) + ",\"flags\":" + brush.texInfo[0].flags + "}"
  extents = bsp.CalcSurfaceExtents(brush, 0)
  print "{\"function\":\"CalcSurfaceExtents\",\"scene\":\"bsp29\",\"mins\":[" + extents[0][0] + "," + extents[0][1] + "],\"extents\":[" + extents[1][0] + "," + extents[1][1] + "]}"
  print "{\"function\":\"Mod_LoadFaces\",\"scene\":\"bsp29\",\"count\":" + len(brush.faces) + ",\"style\":" + brush.faces[0].styles[0] + ",\"sample\":" + brush.lighting[brush.faces[0].lightOffset] + ",\"underwater\":" + boolInt(bsp.faceUnderwater(brush, 0)) + "}"
  parents = bsp.Mod_SetParent(brush)
  print "{\"function\":\"Mod_SetParent\",\"scene\":\"bsp29\",\"root\":" + boolInt(parents[0][0] == -1) + ",\"leaf\":" + boolInt(parents[1][0] == 0) + "}"
  print "{\"function\":\"Mod_LoadNodes\",\"scene\":\"bsp29\",\"count\":" + len(brush.nodes) + ",\"faces\":" + brush.nodes[0].numFaces + ",\"childcontent\":" + brush.leafs[-1 - brush.nodes[0].child0].contents + "}"
  leaf = brush.leafs[0]
  print "{\"function\":\"Mod_LoadLeafs\",\"scene\":\"bsp29\",\"count\":" + len(brush.leafs) + ",\"contents\":" + leaf.contents + ",\"ambient\":[" + leaf.ambient[0] + "," + leaf.ambient[1] + "," + leaf.ambient[2] + "," + leaf.ambient[3] + "]}"
  clip = brush.clipNodes[0]
  print "{\"function\":\"Mod_LoadClipnodes\",\"scene\":\"bsp29\",\"count\":" + len(brush.clipNodes) + ",\"children\":[" + clip.child0 + "," + clip.child1 + "],\"last\":" + (len(brush.clipNodes) - 1) + "}"
  hull0 = world.Mod_MakeHull0(brush)
  print "{\"function\":\"Mod_MakeHull0\",\"scene\":\"bsp29\",\"planenum\":" + hull0[0].planeIndex + ",\"children\":[" + hull0[0].child0 + "," + hull0[0].child1 + "]}"
  print "{\"function\":\"Mod_LoadMarksurfaces\",\"scene\":\"bsp29\",\"count\":" + len(brush.markSurfaces) + ",\"first\":" + boolInt(brush.markSurfaces[0] == 0) + "}"
  print "{\"function\":\"Mod_LoadSurfedges\",\"scene\":\"bsp29\",\"count\":" + len(brush.surfEdges) + ",\"first\":" + brush.surfEdges[0] + "}"
  plane = brush.planes[0]
  print "{\"function\":\"Mod_LoadPlanes\",\"scene\":\"bsp29\",\"count\":" + len(brush.planes) + ",\"normalz\":" + jsonFloat(plane.normal.z) + ",\"signbits\":" + bsp.planeSignBits(plane) + "}"
  radius = world.RadiusFromBounds(t.Vec3(-3.0, -4.0, 0.0), t.Vec3(2.0, 1.0, 12.0))
  print "{\"function\":\"RadiusFromBounds\",\"scene\":\"bounds\",\"radius\":" + jsonFloat(radius) + "}"
  brushRadius = world.RadiusFromBounds(brush.models[0].mins, brush.models[0].maxs)
  print "{\"function\":\"Mod_LoadBrushModel\",\"scene\":\"bsp29\",\"type\":0,\"frames\":2,\"radius\":" + jsonFloat(brushRadius) + ",\"leafs\":" + brush.models[0].visibleLeafs + "}"

  visStream = bytes([1, 0, 1])
  decompressed = bsp.Mod_DecompressVis(visStream, 0, 9)
  print "{\"function\":\"Mod_DecompressVis\",\"scene\":\"vis-rle\",\"bytes\":[" + decompressed[0] + "," + decompressed[1] + "]}"
  zero = t.Vec3(0.0, 0.0, 0.0)
  visModel = t.BspModel(zero, zero, zero, [0, 0, 0, 0], 9, 0, 0)
  visLeaf0 = t.BspLeaf(c.CONTENTS_SOLID, -1, zero, zero, 0, 0, bytes(4))
  visLeaf1 = t.BspLeaf(c.CONTENTS_EMPTY, 0, zero, zero, 0, 0, bytes(4))
  visMap = t.BspMap("vis", bytes(), c.BSP_VERSION, [], "", [], [], [], [], visStream, [], [], [], bytes(), [], [visLeaf0, visLeaf1], [], [], [], [visModel])
  noVis = world.Mod_LeafPVS(0, visMap)
  compressed = world.Mod_LeafPVS(1, visMap)
  print "{\"function\":\"Mod_LeafPVS\",\"scene\":\"vis-rle\",\"novis\":" + noVis[0] + ",\"compressed\":[" + compressed[0] + "," + compressed[1] + "]}"
  leafIndex = world.Mod_PointInLeaf(t.Vec3(0.0, 0.0, 4.0), brush)
  print "{\"function\":\"Mod_PointInLeaf\",\"scene\":\"bsp29\",\"contents\":" + brush.leafs[leafIndex].contents + "}"

  directFrame = bytes(28)
  directFrame[0] = 4
  directFrame[4] = 14
  putFixed(directFrame, 8, "single", 16)
  loadedFrame = mdl.Mod_LoadAliasFrame(directFrame, 0, 1)
  print "{\"function\":\"Mod_LoadAliasFrame\",\"scene\":\"mdl6-frame\",\"firstpose\":0,\"poses\":1,\"name\":\"" + loadedFrame[0].name + "\"}"
  directGroup = bytes(76)
  bio.putI32(directGroup, 0, 2)
  bio.putF32(directGroup, 12, 0.125)
  bio.putF32(directGroup, 16, 0.25)
  nextFrame = writeAliasFrame(directGroup, 20, "g0", 1, 1)
  writeAliasFrame(directGroup, nextFrame, "g1", 2, 1)
  loadedGroup = mdl.Mod_LoadAliasGroup(directGroup, 0, 1)
  print "{\"function\":\"Mod_LoadAliasGroup\",\"scene\":\"mdl6-group\",\"firstpose\":0,\"poses\":" + len(loadedGroup[0].frames) + ",\"interval\":" + jsonFloat(loadedGroup[0].intervals[0]) + "}"

  skin = bytes([1, 1, 2, 1])
  mdl.Mod_FloodFillSkin(skin, 2, 2)
  print "{\"function\":\"Mod_FloodFillSkin\",\"scene\":\"mdl6-skin\",\"pixels\":[" + skin[0] + "," + skin[1] + "," + skin[2] + "," + skin[3] + "]}"
  print "{\"function\":\"Mod_LoadAllSkins\",\"scene\":\"mdl6\",\"skins\":" + alias.numSkins + ",\"uploads\":" + boolInt(len(alias.skins[0].images) == 2) + ",\"texels\":1}"
  print "{\"function\":\"Mod_LoadAliasModel\",\"scene\":\"mdl6\",\"type\":2,\"frames\":" + alias.numFrames + ",\"poses\":" + len(alias.frames[0].frames) + ",\"verts\":" + alias.numVertices + ",\"tris\":" + alias.numTriangles + ",\"size\":" + jsonFloat(alias.size) + "}"

  spriteGroup = spriteModel.frames[0]
  spriteFrame = spriteGroup.frames[0]
  print "{\"function\":\"Mod_LoadSpriteFrame\",\"scene\":\"spr1-group\",\"width\":" + spriteFrame.width + ",\"height\":" + spriteFrame.height + ",\"bounds\":[" + spriteFrame.originY + "," + (spriteFrame.originY - spriteFrame.height) + "," + spriteFrame.originX + "," + (spriteFrame.originX + spriteFrame.width) + "]}"
  print "{\"function\":\"Mod_LoadSpriteGroup\",\"scene\":\"spr1-group\",\"count\":" + len(spriteGroup.frames) + ",\"intervals\":[" + jsonFloat(spriteGroup.intervals[0]) + "," + jsonFloat(spriteGroup.intervals[1]) + "]}"
  spriteBounds = spriteFormat.spriteModelBounds(spriteModel)
  print "{\"function\":\"Mod_LoadSpriteModel\",\"scene\":\"spr1\",\"type\":1,\"frames\":" + spriteModel.numFrames + ",\"spriteType\":" + spriteModel.type + ",\"bounds\":[" + jsonFloat(spriteBounds[0].x) + "," + jsonFloat(spriteBounds[1].z) + "]}"

  registryModule.Mod_ClearAll(registry)
  brushIndex = registryModule.findIndex(registry, "maps/fixture.bsp")
  print "{\"function\":\"Mod_ClearAll\",\"scene\":\"registry-cache\",\"brush\":" + boolInt(registry.needLoad[brushIndex]) + ",\"alias\":" + boolInt(registry.needLoad[aliasIndex]) + ",\"sprite\":" + boolInt(registry.needLoad[spriteIndex]) + "}"
  modelCount = registryModule.Mod_Print(registry)
  print "{\"function\":\"Mod_Print\",\"scene\":\"registry-print\",\"lines\":" + (modelCount + 1) + ",\"models\":" + modelCount + "}"
  return 0
end function
