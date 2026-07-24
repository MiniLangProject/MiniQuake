import miniquake.render.draw2d as draw
import miniquake.render.gl11 as gl
import miniquake.types as t
import miniquake.native as native
import miniquake.byteio as bio
import miniquake.wad as wad
import miniquake.cvar as cvar

function fnvByte(hash, value)
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

function hashLevels(levels)
  hash = 2166136261
  for each level in levels
    for each value in level[2]
      hash = fnvByte(hash, value)
    end for
  end for
  return hash
end function

function levelHashes(levels)
  result = "["
  index = 0
  while index < len(levels)
    if index > 0 then result = result + "," end if
    result = result + hashBytes(levels[index][2])
    index = index + 1
  end while
  return result + "]"
end function

function emit(functionName, scene, fields)
  print "{\"function\":\"" + functionName + "\",\"scene\":\"" + scene + "\"," + fields + "}"
end function

function boolInt(value)
  if value then return 1 end if
  return 0
end function

function countCommand(commands, name)
  count = 0
  for each command in commands
    if command[0] == name then count = count + 1 end if
  end for
  return count
end function

function lastCommand(commands, name)
  result = void
  for each command in commands
    if command[0] == name then result = command end if
  end for
  return result
end function

function fillPic(width, height, seed)
  data = bytes(8 + width * height)
  bio.putI32(data, 0, width)
  bio.putI32(data, 4, height)
  index = 0
  while index < width * height
    data[8 + index] = (seed + index * 3) & 255
    index = index + 1
  end while
  return data
end function

function putName(data, offset, name)
  source = bytes(name)
  copied = len(source)
  if copied > 16 then copied = 16 end if
  bio.copyInto(data, offset, source, 0, copied)
end function

function putLumpDirectory(data, offset, filePosition, size, type, name)
  bio.putI32(data, offset, filePosition)
  bio.putI32(data, offset + 4, size)
  bio.putI32(data, offset + 8, size)
  data[offset + 12] = type
  data[offset + 13] = 0
  putName(data, offset + 16, name)
end function

function makeAssets()
  characters = bytes(16384)
  index = 0
  while index < len(characters)
    characters[index] = 255
    index = index + 1
  end while
  index = 0
  while index < len(characters)
    characters[index] = index & 95
    index = index + 97
  end while
  disc = fillPic(16, 16, 3)
  backtile = fillPic(64, 64, 7)
  conback = fillPic(320, 200, 13)
  menu = fillPic(64, 64, 11)

  charactersOffset = 12
  discOffset = charactersOffset + len(characters)
  backtileOffset = discOffset + len(disc)
  directoryOffset = backtileOffset + len(backtile)
  wadData = bytes(directoryOffset + 3 * 32)
  putName(wadData, 0, "WAD2")
  bio.putI32(wadData, 4, 3)
  bio.putI32(wadData, 8, directoryOffset)
  bio.copyInto(wadData, charactersOffset, characters, 0, len(characters))
  bio.copyInto(wadData, discOffset, disc, 0, len(disc))
  bio.copyInto(wadData, backtileOffset, backtile, 0, len(backtile))
  putLumpDirectory(wadData, directoryOffset, charactersOffset, len(characters), 64, "conchars")
  putLumpDirectory(wadData, directoryOffset + 32, discOffset, len(disc), 66, "disc")
  putLumpDirectory(wadData, directoryOffset + 64, backtileOffset, len(backtile), 66, "backtile")

  all = bytes(len(wadData) + len(conback) + len(menu))
  bio.copyInto(all, 0, wadData, 0, len(wadData))
  bio.copyInto(all, len(wadData), conback, 0, len(conback))
  bio.copyInto(all, len(wadData) + len(conback), menu, 0, len(menu))
  files = [
    t.PackFile("gfx.wad", 0, len(wadData)),
    t.PackFile("gfx/conback.lmp", len(wadData), len(conback)),
    t.PackFile("gfx/menuplyr.lmp", len(wadData) + len(conback), len(menu)),
    t.PackFile("gfx/menu.lmp", len(wadData) + len(conback), len(menu)),
  ]
  archive = t.PackArchive("synthetic.pak", all, files, len(files))
  filesystem = t.FileSystem("", "id1", [t.SearchPath("", archive)], "", false, true, true, false)
  return [filesystem, wad.parse(wadData, "gfx.wad"), characters, menu]
end function

function palette()
  result = bytes(768)
  index = 0
  while index < 256
    result[index * 3] = index
    result[index * 3 + 1] = (index * 3) & 255
    result[index * 3 + 2] = 255 - index
    index = index + 1
  end while
  return result
end function

function picture(name, width, height, texture, pixels)
  result = t.MenuPicture(name, width, height, texture)
  draw.registerDrawPicture(result, [0.25, 0.125, 0.75, 0.875], pixels)
  return result
end function

function rgbaSource()
  data = bytes(64)
  index = 0
  while index < 16
    value = 0xff000000 | (index * 0x010203)
    bio.putI32(data, index * 4, value)
    index = index + 1
  end while
  return data
end function

function fatalMode(mode)
  pal = palette()
  draw.Draw_DifferentialReset(pal)
  if mode == "transpic-coordinates" then
    pic = picture("fatal", 16, 8, 55, bytes(128))
    result = try(draw.Draw_TransPic(-1, 0, pic))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "scrap-full" then
    draw.ResetScrap([90, 91])
    draw.Scrap_AllocBlock(255, 256)
    draw.Scrap_AllocBlock(255, 256)
    result = try(draw.Scrap_AllocBlock(255, 256))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "upload-too-big" then
    result = try(draw.GL_Upload32(bytes(4), 1024, 1024, false, false))
    if result is error then return 86 end if
    return 0
  end if
  if mode == "upload8-size" then
    result = try(draw.GL_Upload8(bytes([0, 1, 2]), 3, 1, false, false))
    if result is error then return 86 end if
    return 0
  end if
  return 2
end function

function main(args)
  if len(args) == 2 and args[0] == "--fatal" then return fatalMode(args[1]) end if
  pal = palette()
  assets = makeAssets()
  filesystem = assets[0]
  wadArchive = assets[1]
  characters = assets[2]
  menuData = assets[3]
  menuPixels = slice(menuData, 8, 4096)
  draw.Draw_DifferentialReset(pal)

  draw.Draw_DifferentialSetGlobals(77, 0, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.GL_Bind(9)
  draw.GL_Bind(9)
  firstCommands = gl.Trace_End()
  draw.Draw_DifferentialSetGlobals(77, 0, 1.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.GL_Bind(12)
  secondCommands = gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("GL_Bind", "bind-cache-nobind", "\"binds\":" + (countCommand(firstCommands, "bind_texture") + countCommand(secondCommands, "bind_texture")) + ",\"current\":" + state[0] + ",\"last\":77")

  draw.ResetScrap([90, 91])
  first = draw.Scrap_AllocBlock(8, 8)
  second = draw.Scrap_AllocBlock(8, 8)
  emit("Scrap_AllocBlock", "scrap-pack", "\"blocks\":[" + first[0] + "," + second[0] + "," + second[1] + "," + second[2] + "]")

  draw.Draw_DifferentialSetGlobals(77, 0, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Scrap_Upload()
  commands = gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("Scrap_Upload", "scrap-upload", "\"uploads\":" + state[5] + ",\"dirty\":0,\"images\":" + countCommand(commands, "upload_rgba") + ",\"binds\":" + countCommand(commands, "bind_texture"))

  draw.Draw_DifferentialUseAssets(filesystem, wadArchive)
  draw.Draw_DifferentialResetPictureCaches()
  draw.ResetScrap([90, 91])
  loaded = draw.Draw_PicFromWad("disc")
  state = draw.Draw_DifferentialState()
  emit("Draw_PicFromWad", "wad-scrap", "\"size\":[" + loaded.width + "," + loaded.height + "],\"texture\":" + loaded.textureId + ",\"count\":" + state[6] + ",\"texels\":" + state[7])

  draw.Draw_DifferentialSetTextureState(1, -1, [], [], [], [], [])
  draw.Draw_DifferentialResetPictureCaches()
  gl.Trace_Begin()
  cached = draw.Draw_CachePic("gfx/menuplyr.lmp")
  loaded = draw.Draw_CachePic("gfx/menuplyr.lmp")
  commands = gl.Trace_End()
  same = 0
  if cached == loaded then same = 1 end if
  emit("Draw_CachePic", "menu-cache", "\"same\":" + same + ",\"size\":[" + cached.width + "," + cached.height + "],\"player\":62,\"images\":" + countCommand(commands, "upload_rgba"))

  destination = bytes(2560)
  index = 0
  while index < len(destination)
    destination[index] = 7
    index = index + 1
  end while
  draw.Draw_DifferentialSetGlobals(77, 0, 0.0, characters, menuPixels)
  draw.Draw_CharToConback(0, destination, 0)
  emit("Draw_CharToConback", "conback-glyph", "\"hash\":" + hashBytes(destination))

  indexed = bytes(32)
  index = 0
  while index < 16
    indexed[index] = index
    index = index + 1
  end while
  draw.Draw_DifferentialSetTextureState(30, -1, [], [], [], [], [])
  gl.Trace_Begin()
  draw.GL_LoadTexture("", 4, 4, indexed, true, false)
  gl.Trace_End()
  gl.Trace_Begin()
  draw.Draw_TextureMode_f(["gl_texturemode", "GL_NEAREST_MIPMAP_LINEAR"])
  commands = gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("Draw_TextureMode_f", "texture-mode", "\"filters\":[" + state[1] + "," + state[2] + "],\"params\":" + countCommand(commands, "texture_parameter"))

  draw.Draw_DifferentialReset(pal)
  registry = cvar.createRegistry()
  gl.Trace_Begin()
  draw.Draw_Init(filesystem, pal, 640, 480, registry)
  gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("Draw_Init", "draw-init", "\"cvars\":" + len(registry.variables) + ",\"commands\":1,\"textures\":[" + state[8] + "," + state[9] + "," + state[14][0] + "],\"next\":" + state[10] + ",\"pics\":[" + boolInt(state[15]) + "," + boolInt(state[16]) + "]")

  pic = picture("fixture", 16, 8, 55, menuPixels)
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_Character(10, 20, 65)
  commands = gl.Trace_End()
  emit("Draw_Character", "ui-character", "\"gl\":[" + countCommand(commands, "bind_texture") + "," + countCommand(commands, "begin") + "," + countCommand(commands, "texcoord") + "," + countCommand(commands, "vertex") + "," + countCommand(commands, "end") + "]")
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_String(10, 20, "A B")
  commands = gl.Trace_End()
  emit("Draw_String", "ui-string", "\"quads\":" + countCommand(commands, "begin") + ",\"vertices\":" + countCommand(commands, "vertex"))
  gl.Trace_Begin()
  draw.Draw_DebugChar(88)
  commands = gl.Trace_End()
  emit("Draw_DebugChar", "ui-debug", "\"calls\":" + (countCommand(commands, "begin") + countCommand(commands, "vertex")))
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_AlphaPic(2, 3, pic, 0.375)
  commands = gl.Trace_End()
  emit("Draw_AlphaPic", "ui-alpha-pic", "\"gl\":[" + countCommand(commands, "disable") + "," + countCommand(commands, "enable") + "," + countCommand(commands, "color") + "," + countCommand(commands, "begin") + "," + countCommand(commands, "vertex") + "]")
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_Pic(4, 5, pic)
  commands = gl.Trace_End()
  emit("Draw_Pic", "ui-pic", "\"gl\":[" + countCommand(commands, "bind_texture") + "," + countCommand(commands, "color") + "," + countCommand(commands, "begin") + "," + countCommand(commands, "vertex") + "]")
  draw.SetVideoSize(640, 480)
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_TransPic(6, 7, pic)
  commands = gl.Trace_End()
  emit("Draw_TransPic", "ui-trans-pic", "\"gl\":[" + countCommand(commands, "bind_texture") + "," + countCommand(commands, "begin") + "," + countCommand(commands, "vertex") + "]")
  translation = bytes(256)
  index = 0
  while index < 256
    translation[index] = 255 - index
    index = index + 1
  end while
  menuPixels[0] = 255
  draw.Draw_DifferentialSetGlobals(77, 88, 0.0, characters, menuPixels)
  gl.Trace_Begin()
  draw.Draw_TransPicTranslate(8, 9, pic, translation)
  commands = gl.Trace_End()
  upload = lastCommand(commands, "upload_rgba")
  emit("Draw_TransPicTranslate", "ui-translate", "\"upload\":[" + upload[1][2] + "," + upload[1][3] + "," + upload[1][1] + "," + hashBytes(upload[1][4]) + "],\"quad\":" + countCommand(commands, "vertex"))
  draw.SetVideoSize(640, 200)
  draw.Draw_DifferentialSetPictures(pic, pic, pic)
  gl.Trace_Begin()
  draw.Draw_ConsoleBackground(100)
  commands = gl.Trace_End()
  emit("Draw_ConsoleBackground", "ui-console", "\"alphaPath\":[" + countCommand(commands, "disable") + "," + countCommand(commands, "enable") + "," + countCommand(commands, "vertex") + "]")
  draw.Draw_TraceSetBacktile(pic)
  gl.Trace_Begin()
  draw.Draw_TileClear(16, 24, 96, 40)
  commands = gl.Trace_End()
  emit("Draw_TileClear", "ui-tile", "\"gl\":[" + countCommand(commands, "bind_texture") + "," + countCommand(commands, "texcoord") + "," + countCommand(commands, "vertex") + "," + countCommand(commands, "end") + "]")
  gl.Trace_Begin()
  draw.Draw_Fill(1, 2, 30, 40, 5)
  commands = gl.Trace_End()
  emit("Draw_Fill", "ui-fill", "\"gl\":[" + countCommand(commands, "disable") + "," + countCommand(commands, "color") + "," + countCommand(commands, "vertex") + "," + countCommand(commands, "enable") + "]")
  before = draw.Draw_DifferentialState()[17]
  gl.Trace_Begin()
  draw.Draw_FadeScreen()
  commands = gl.Trace_End()
  after = draw.Draw_DifferentialState()[17]
  emit("Draw_FadeScreen", "ui-fade", "\"gl\":[" + countCommand(commands, "enable") + "," + countCommand(commands, "disable") + "," + countCommand(commands, "vertex") + "],\"sbar\":" + (after - before))
  draw.SetVideoSize(640, 480)
  draw.Draw_DifferentialSetPictures(pic, pic, pic)
  gl.Trace_Begin()
  draw.Draw_BeginDisc()
  commands = gl.Trace_End()
  emit("Draw_BeginDisc", "ui-disc", "\"buffers\":" + countCommand(commands, "draw_buffer") + ",\"vertices\":" + countCommand(commands, "vertex"))
  gl.Trace_Begin()
  draw.Draw_EndDisc()
  commands = gl.Trace_End()
  emit("Draw_EndDisc", "ui-disc-end", "\"calls\":" + (countCommand(commands, "begin") + countCommand(commands, "vertex")))
  gl.Trace_Begin()
  draw.GL_Set2D()
  commands = gl.Trace_End()
  emit("GL_Set2D", "set2d", "\"state\":[" + countCommand(commands, "viewport") + "," + countCommand(commands, "matrix_mode") + "," + countCommand(commands, "load_identity") + "," + countCommand(commands, "ortho") + "," + countCommand(commands, "disable") + "," + countCommand(commands, "enable") + "," + countCommand(commands, "color") + "]")

  draw.Draw_DifferentialReset(pal)
  index = 0
  while index < 16
    indexed[index] = index
    index = index + 1
  end while
  gl.Trace_Begin()
  texture = draw.GL_LoadTexture("", 4, 4, indexed, false, false)
  gl.Trace_End()
  emit("GL_FindTexture", "texture-find", "\"found\":" + draw.GL_FindTexture("") + ",\"missing\":" + draw.GL_FindTexture("missing") + ",\"texture\":" + texture)

  rgba = rgbaSource()
  resampled = draw.GL_ResampleTexture(rgba, 4, 4, 8, 4)
  emit("GL_ResampleTexture", "texture-resample", "\"hash\":" + hashBytes(resampled))
  index = 0
  while index < 16
    indexed[index] = index * 7
    index = index + 1
  end while
  resampled8 = draw.GL_Resample8BitTexture(indexed, 4, 4, 8, 4)
  emit("GL_Resample8BitTexture", "texture-resample8", "\"hash\":" + hashBytes(resampled8))
  mip = draw.GL_MipMap(rgba, 4, 4)
  emit("GL_MipMap", "texture-mipmap", "\"hash\":" + hashBytes(mip))
  mip8 = draw.GL_MipMap8Bit(indexed, 4, 4)
  emit("GL_MipMap8Bit", "texture-mipmap8", "\"hash\":" + hashBytes(mip8))

  draw.Draw_DifferentialReset(pal)
  gl.Trace_Begin()
  levels = draw.GL_Upload32(rgbaSource(), 4, 4, true, true)
  commands = gl.Trace_End()
  last = levels[len(levels) - 1]
  state = draw.Draw_DifferentialState()
  emit("GL_Upload32", "texture-upload32", "\"upload\":[" + len(levels) + "," + (len(levels) - 1) + "," + last[0] + "," + last[1] + "],\"params\":" + countCommand(commands, "texture_parameter") + ",\"texels\":" + state[3])
  gl.Trace_Begin()
  levels = draw.GL_Upload8_EXT(resampled8, 8, 4, true, false)
  commands = gl.Trace_End()
  last = levels[len(levels) - 1]
  emit("GL_Upload8_EXT", "texture-upload8ext", "\"upload\":[" + len(levels) + "," + (len(levels) - 1) + "," + last[0] + "," + last[1] + "],\"params\":" + countCommand(commands, "texture_parameter"))
  indexed[0] = 255
  gl.Trace_Begin()
  levels = draw.GL_Upload8(indexed, 4, 4, false, true)
  commands = gl.Trace_End()
  upload = lastCommand(commands, "upload_rgba")
  emit("GL_Upload8", "texture-upload8", "\"upload\":[" + len(levels) + "," + upload[1][2] + "," + upload[1][3] + "," + hashBytes(upload[1][4]) + "],\"params\":" + countCommand(commands, "texture_parameter"))
  aliasIndexed = bytes(200 * 194)
  index = 0
  while index < len(aliasIndexed)
    aliasIndexed[index] = (index * 37 + native.trunc(index / 200) * 11 + 17) & 255
    index = index + 1
  end while
  aliasConverted = draw.indexedToUploadRgba(aliasIndexed, 200, 194, false)[0]
  aliasResampled = draw.GL_ResampleTexture(aliasConverted, 200, 194, 256, 256)
  levels = draw.GL_Upload8(aliasIndexed, 200, 194, true, false)
  last = levels[len(levels) - 1]
  emit("GL_Upload8", "alias-200x194-mip-chain", "\"source_hash\":" + hashBytes(aliasIndexed) + ",\"converted_hash\":" + hashBytes(aliasConverted) + ",\"resampled_hash\":" + hashBytes(aliasResampled) + ",\"upload\":[" + len(levels) + "," + (len(levels) - 1) + "," + last[0] + "," + last[1] + "],\"level_hashes\":" + levelHashes(levels) + ",\"chain_hash\":" + hashLevels(levels))

  draw.Draw_DifferentialReset(pal)
  gl.Trace_Begin()
  firstId = draw.GL_LoadTexture("named", 4, 4, indexed, false, false)
  secondId = draw.GL_LoadTexture("named", 4, 4, indexed, false, false)
  commands = gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("GL_LoadTexture", "texture-load", "\"ids\":[" + firstId + "," + secondId + "],\"count\":" + state[11] + ",\"images\":" + countCommand(commands, "upload_rgba"))
  smallPixels = slice(indexed, 0, 16)
  smallPic = picture("small", 4, 4, 0, smallPixels)
  gl.Trace_Begin()
  texture = draw.GL_LoadPicTexture(smallPic)
  commands = gl.Trace_End()
  state = draw.Draw_DifferentialState()
  emit("GL_LoadPicTexture", "texture-load-pic", "\"texture\":" + texture + ",\"count\":" + state[11] + ",\"images\":" + countCommand(commands, "upload_rgba"))

  draw.Draw_DifferentialSetMultitexture(true, 41, -1, 72)
  draw.GL_SelectTexture(gl.GL_TEXTURE1_SGIS)
  draw.GL_SelectTexture(gl.GL_TEXTURE1_SGIS)
  draw.GL_SelectTexture(gl.GL_TEXTURE0_SGIS)
  state = draw.Draw_DifferentialState()
  emit("GL_SelectTexture", "texture-select", "\"selects\":3,\"current\":" + state[0] + ",\"slots\":[" + state[12] + "," + state[13] + "]")
  return 0
end function
