/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.draw2d.
*/
package miniquake.render.draw2d

import miniquake.render.gl11 as gl
import miniquake.native as native
import miniquake.byteio as bio
import miniquake.types as t
import miniquake.console as console
import miniquake.filesystem as qfs
import miniquake.wad as wad
import miniquake.cvar as cvar
import miniquake.constants as c
import miniquake.array_util as arrayutil
import miniquake.render.texture_upscale as textureUpscale
import std.string as string

/// Defines the max scraps value used by `miniquake.render.draw2d`.
const MAX_SCRAPS = 2
/// Defines the scrap width value used by `miniquake.render.draw2d`.
const SCRAP_WIDTH = 256
/// Defines the scrap height value used by `miniquake.render.draw2d`.
const SCRAP_HEIGHT = 256
/// Defines the max gltextures value used by `miniquake.render.draw2d`.
const MAX_GLTEXTURES = 1024
/// Defines the max cached pics value used by `miniquake.render.draw2d`.
const MAX_CACHED_PICS = 128

/// Tracks the module-level draw filesystem state owned by `miniquake.render.draw2d`.
drawFilesystem = void
/// Tracks the module-level draw palette state owned by `miniquake.render.draw2d`.
drawPalette = bytes()
/// Tracks the module-level draw wad state owned by `miniquake.render.draw2d`.
drawWad = void
/// Tracks the module-level draw cvars state owned by `miniquake.render.draw2d`.
drawCvars = void
/// Tracks the module-level draw video width state owned by `miniquake.render.draw2d`.
drawVideoWidth = 320
/// Tracks the module-level draw video height state owned by `miniquake.render.draw2d`.
drawVideoHeight = 200
/// Tracks the module-level draw viewport state owned by `miniquake.render.draw2d`.
drawViewport = [0, 0, 320, 200]
/// Tracks the module-level draw chars state owned by `miniquake.render.draw2d`.
draw_chars = bytes()
/// Tracks the module-level draw disc state owned by `miniquake.render.draw2d`.
draw_disc = void
/// Tracks the module-level draw backtile state owned by `miniquake.render.draw2d`.
draw_backtile = void
/// Tracks the module-level conback state owned by `miniquake.render.draw2d`.
conback = void
/// Tracks the module-level menuplyr pixels state owned by `miniquake.render.draw2d`.
menuplyr_pixels = bytes(4096)

/// Tracks the module-level char texture state owned by `miniquake.render.draw2d`.
char_texture = 0
/// Tracks the module-level translate texture state owned by `miniquake.render.draw2d`.
translate_texture = 0
/// Tracks the module-level currenttexture state owned by `miniquake.render.draw2d`.
currenttexture = -1
/// Tracks the module-level gl nobind state owned by `miniquake.render.draw2d`.
gl_nobind = 0.0
/// Tracks the module-level gl max size state owned by `miniquake.render.draw2d`.
gl_max_size = 1024.0
/// Tracks the module-level gl picmip state owned by `miniquake.render.draw2d`.
gl_picmip = 0.0
/// Tracks the module-level gl textureupscale state owned by `miniquake.render.draw2d`.
gl_textureupscale = 0
/// Tracks the module-level gl anisotropy state owned by `miniquake.render.draw2d`.
gl_anisotropy = 1
/// Tracks the module-level gl filter min state owned by `miniquake.render.draw2d`.
gl_filter_min = gl.GL_LINEAR_MIPMAP_NEAREST
/// Tracks the module-level gl filter max state owned by `miniquake.render.draw2d`.
gl_filter_max = gl.GL_LINEAR
/// Tracks the module-level gl lightmap format state owned by `miniquake.render.draw2d`.
gl_lightmap_format = 4
/// Tracks the module-level gl solid format state owned by `miniquake.render.draw2d`.
gl_solid_format = 3
/// Tracks the module-level gl alpha format state owned by `miniquake.render.draw2d`.
gl_alpha_format = 4
/// Tracks the module-level texels state owned by `miniquake.render.draw2d`.
texels = 0

/// Tracks the module-level scrap allocated state owned by `miniquake.render.draw2d`.
scrap_allocated = []
/// Tracks the module-level scrap texels state owned by `miniquake.render.draw2d`.
scrap_texels = []
/// Tracks the module-level scrap textures state owned by `miniquake.render.draw2d`.
scrap_textures = []
/// Tracks the module-level scrap dirty state owned by `miniquake.render.draw2d`.
scrap_dirty = false
/// Tracks the module-level scrap uploads state owned by `miniquake.render.draw2d`.
scrap_uploads = 0
/// Tracks the module-level pic texels state owned by `miniquake.render.draw2d`.
pic_texels = 0
/// Tracks the module-level pic count state owned by `miniquake.render.draw2d`.
pic_count = 0
/// Tracks the module-level draw sbar changes state owned by `miniquake.render.draw2d`.
drawSbarChanges = 0

/// Tracks the module-level menu cachepics state owned by `miniquake.render.draw2d`.
menu_cachepics = []
/// Tracks the module-level wad cachepics state owned by `miniquake.render.draw2d`.
wad_cachepics = []
/// Tracks the module-level draw picture objects state owned by `miniquake.render.draw2d`.
drawPictureObjects = []
/// Tracks the module-level draw picture coordinates state owned by `miniquake.render.draw2d`.
drawPictureCoordinates = []
/// Tracks the module-level draw picture pixels state owned by `miniquake.render.draw2d`.
drawPicturePixels = []

/// Tracks the module-level gl texture names state owned by `miniquake.render.draw2d`.
glTextureNames = []
/// Tracks the module-level gl texture ids state owned by `miniquake.render.draw2d`.
glTextureIds = []
/// Tracks the module-level gl texture widths state owned by `miniquake.render.draw2d`.
glTextureWidths = []
/// Tracks the module-level gl texture heights state owned by `miniquake.render.draw2d`.
glTextureHeights = []
/// Tracks the module-level gl texture mipmaps state owned by `miniquake.render.draw2d`.
glTextureMipmaps = []
/// Tracks the module-level texture extension number state owned by `miniquake.render.draw2d`.
texture_extension_number = 1

/// Tracks the module-level gl multi texture available state owned by `miniquake.render.draw2d`.
glMultiTextureAvailable = false
/// Tracks the module-level old texture target state owned by `miniquake.render.draw2d`.
oldTextureTarget = gl.GL_TEXTURE0_SGIS
/// Tracks the module-level current texture slots state owned by `miniquake.render.draw2d`.
currentTextureSlots = [-1, -1]

/// Implements the `indexedFontRgba` operation for `miniquake.render.draw2d` (indexed font rgba).
/// @param pixels The pixels input consumed by `indexedFontRgba`.
/// @param palette The palette input consumed by `indexedFontRgba`.
function indexedFontRgba(pixels, palette)
  count = len(pixels)
  output = bytes(count * 4)
  index = 0
  while index < count
    color = pixels[index]
    destination = index * 4
    if color == 0 then
      output[destination] = 255
      output[destination + 1] = 255
      output[destination + 2] = 255
      output[destination + 3] = 0
    else
      paletteOffset = color * 3
      output[destination] = palette[paletteOffset]
      output[destination + 1] = palette[paletteOffset + 1]
      output[destination + 2] = palette[paletteOffset + 2]
      output[destination + 3] = 255
    end if
    index = index + 1
  end while
  return output
end function

/// Upload font to the active renderer.
/// @param conchars The conchars input consumed by `uploadFont`.
/// @param palette The palette input consumed by `uploadFont`.
function uploadFont(conchars, palette)
  if len(conchars) < 16384 then return error(3300, "Draw_Init: conchars.lmp is truncated") end if
  if len(palette) < 768 then return error(3301, "Draw_Init: palette.lmp is truncated") end if
  texture = gl.generateTexture()
  gl.bindTexture(texture)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
  gl.uploadRgba(128, 128, indexedFontRgba(slice(conchars, 0, 16384), palette))
  return texture
end function


/// Implements the `indexedPictureRgba` operation for `miniquake.render.draw2d` (indexed picture rgba).
/// @param pixels The pixels input consumed by `indexedPictureRgba`.
/// @param palette The palette input consumed by `indexedPictureRgba`.
/// @param transparent The transparent input consumed by `indexedPictureRgba`.
function indexedPictureRgba(pixels, palette, transparent)
  if len(palette) < 768 then return error(3302, "Draw_Pic: palette.lmp is truncated") end if
  output = bytes(len(pixels) * 4)
  index = 0
  while index < len(pixels)
    color = pixels[index]
    destination = index * 4
    paletteOffset = color * 3
    output[destination] = palette[paletteOffset]
    output[destination + 1] = palette[paletteOffset + 1]
    output[destination + 2] = palette[paletteOffset + 2]
    alpha = 255
    if transparent and color == 255 then alpha = 0 end if
    output[destination + 3] = alpha
    index = index + 1
  end while
  return output
end function

/// Quake qpic_t files store little-endian width/height followed by indexed
/// pixels.  Menu artwork uses palette index 255 as transparent.
/// @param data Input data consumed by the operation.
/// @param palette The palette input consumed by `uploadPicture`.
/// @param name Stable name that identifies the requested object or option.
/// @param transparent The transparent input consumed by `uploadPicture`.
function uploadPicture(data, palette, name, transparent)
  if len(data) < 8 then return error(3303, name + ": qpic header is truncated") end if
  width = bio.i32(data, 0)
  height = bio.i32(data, 4)
  if width <= 0 or height <= 0 or width > 4096 or height > 4096 then
    return error(3304, name + ": invalid qpic dimensions")
  end if
  pixelCount = width * height
  if 8 + pixelCount > len(data) then return error(3305, name + ": qpic pixels are truncated") end if
  indexed = slice(data, 8, pixelCount)
  rgba = indexedPictureRgba(indexed, palette, transparent)
  texture = gl.generateTexture()
  gl.bindTexture(texture)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
  gl.textureParameter(gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
  gl.uploadRgba(width, height, rgba)
  return t.MenuPicture(name, width, height, texture)
end function

/// Initialize state for begin2d.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function begin2d(width, height)
  if width < 1 then width = 1 end if
  if height < 1 then height = 1 end if
  gl.viewport(0, 0, width, height)
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  gl.ortho(0.0, width * 1.0, height * 1.0, 0.0, -1.0, 1.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.disable(gl.GL_DEPTH_TEST)
  gl.depthMask(false)
  gl.enable(gl.GL_BLEND)
  gl.blendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
end function

// Finalize state for end2d.
function end2d()
  gl.color(255, 255, 255, 255)
  gl.disable(gl.GL_BLEND)
  gl.depthMask(true)
end function

/// Implements the `solidQuad` operation for `miniquake.render.draw2d` (solid quad).
/// @param x The x input consumed by `solidQuad`.
/// @param y The y input consumed by `solidQuad`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param red The red input consumed by `solidQuad`.
/// @param green The green input consumed by `solidQuad`.
/// @param blue The blue input consumed by `solidQuad`.
/// @param alpha The alpha input consumed by `solidQuad`.
function solidQuad(x, y, width, height, red, green, blue, alpha)
  gl.disable(gl.GL_TEXTURE_2D)
  gl.color(red, green, blue, alpha)
  gl.begin(gl.GL_QUADS)
  gl.vertex2(x, y)
  gl.vertex2(x + width, y)
  gl.vertex2(x + width, y + height)
  gl.vertex2(x, y + height)
  gl.finishPrimitive()
  gl.enable(gl.GL_TEXTURE_2D)
end function

/// Implements the `texturedQuad` operation for `miniquake.render.draw2d` (textured quad).
/// @param texture Texture resource processed by the operation.
/// @param x The x input consumed by `texturedQuad`.
/// @param y The y input consumed by `texturedQuad`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param s0 The s0 input consumed by `texturedQuad`.
/// @param t0 The t0 input consumed by `texturedQuad`.
/// @param s1 The s1 input consumed by `texturedQuad`.
/// @param t1 The t1 input consumed by `texturedQuad`.
/// @param red The red input consumed by `texturedQuad`.
/// @param green The green input consumed by `texturedQuad`.
/// @param blue The blue input consumed by `texturedQuad`.
/// @param alpha The alpha input consumed by `texturedQuad`.
function texturedQuad(texture, x, y, width, height, s0, t0, s1, t1, red, green, blue, alpha)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.bindTexture(texture)
  gl.color(red, green, blue, alpha)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(s0, t0); gl.vertex2(x, y)
  gl.texcoord2(s1, t0); gl.vertex2(x + width, y)
  gl.texcoord2(s1, t1); gl.vertex2(x + width, y + height)
  gl.texcoord2(s0, t1); gl.vertex2(x, y + height)
  gl.finishPrimitive()
end function

/// Implements the `character` operation for `miniquake.render.draw2d` (character).
/// @param texture Texture resource processed by the operation.
/// @param x The x input consumed by `character`.
/// @param y The y input consumed by `character`.
/// @param code The code input consumed by `character`.
/// @param scale The scale input consumed by `character`.
/// @param alpha The alpha input consumed by `character`.
function character(texture, x, y, code, scale, alpha)
  code = code & 255
  row = code >> 4
  column = code & 15
  s0 = column / 16.0
  t0 = row / 16.0
  s1 = (column + 1) / 16.0
  t1 = (row + 1) / 16.0
  texturedQuad(texture, x, y, 8.0 * scale, 8.0 * scale, s0, t0, s1, t1, 255, 255, 255, alpha)
end function

/// Implements the `string` operation for `miniquake.render.draw2d` (string).
/// @param texture Texture resource processed by the operation.
/// @param x The x input consumed by `string`.
/// @param y The y input consumed by `string`.
/// @param text Text to parse or process.
/// @param scale The scale input consumed by `string`.
/// @param alpha The alpha input consumed by `string`.
function string(texture, x, y, text, scale, alpha)
  data = bytes(text)
  cursorX = x
  cursorY = y
  index = 0
  while index < len(data)
    code = data[index]
    if code == 10 then
      cursorX = x
      cursorY = cursorY + 8.0 * scale
    else if code >= 32 then
      character(texture, cursorX, cursorY, code, scale, alpha)
      cursorX = cursorX + 8.0 * scale
    end if
    index = index + 1
  end while
  return cursorY
end function

/// Render console.
/// @param state Mutable `miniquake.render.draw2d` state used by `drawConsole`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param scale The scale input consumed by `drawConsole`.
function drawConsole(state, width, height, scale)
  if state is void or not state.active or state.textureId == 0 then return false end if
  if scale <= 0.0 then scale = 1.0 end if
  consoleHeight = height * 0.5
  begin2d(width, height)
  solidQuad(0.0, 0.0, width * 1.0, consoleHeight, 0, 0, 0, 210)
  lineHeight = 8.0 * scale
  lineCount = native.trunc(consoleHeight / lineHeight) - 3
  if lineCount < 1 then lineCount = 1 end if
  lines = []
  start = len(state.lines) - lineCount - console.backscroll()
  if start < 0 then start = 0 end if
  finish = start + lineCount
  if finish > len(state.lines) then finish = len(state.lines) end if
  index = start
  while index < finish
    lines = lines + [state.lines[index]]
    index = index + 1
  end while
  y = 8.0
  for each line in lines
    string(state.textureId, 8.0, y, line, scale, 255)
    y = y + lineHeight
  end for
  string(state.textureId, 8.0, consoleHeight - lineHeight - 4.0, "]" + state.inputText, scale, 255)
  end2d()
  return true
end function

/// Render status.
/// @param texture Texture resource processed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param text Text to parse or process.
function drawStatus(texture, width, height, text)
  if texture == 0 then return false end if
  begin2d(width, height)
  solidQuad(0.0, height - 24.0, width * 1.0, 24.0, 0, 0, 0, 160)
  string(texture, 8.0, height - 16.0, text, 1.0, 255)
  end2d()
  return true
end function

/// =============================================================================
/// gl_draw.c compatibility surface
/// =============================================================================
/// @param filesystem The filesystem input consumed by `configureDraw`.
/// @param palette The palette input consumed by `configureDraw`.
/// @param cvars The cvars input consumed by `configureDraw`.

function configureDraw(filesystem, palette, cvars)
  global drawFilesystem, drawPalette, drawCvars
  drawFilesystem = filesystem
  drawPalette = palette
  if cvars is not void then drawCvars = cvars end if
  return true
end function

/// gl_draw.c owns the process-wide indexed-texture upload palette. Model and
/// world loading use the same GL_LoadTexture path after VID_SetPalette.
/// @param palette The palette input consumed by `Draw_SetPalette`.
function Draw_SetPalette(palette)
  global drawPalette
  if palette is void or len(palette) < 768 then return error(3338, "GL_LoadTexture: palette is unavailable") end if
  drawPalette = palette
  return true
end function

// Update module state for draw cvars.
function syncDrawCvars()
  global gl_nobind, gl_max_size, gl_picmip, gl_textureupscale, gl_anisotropy
  if drawCvars is void then return false end if
  variable = cvar.find(drawCvars, "gl_nobind")
  if variable is not void then gl_nobind = variable.value end if
  variable = cvar.find(drawCvars, "gl_max_size")
  if variable is not void then gl_max_size = variable.value end if
  variable = cvar.find(drawCvars, "gl_picmip")
  if variable is not void then gl_picmip = variable.value end if
  variable = cvar.find(drawCvars, "r_textureupscale")
  if variable is not void then gl_textureupscale = textureUpscale.clampMode(variable.value) end if
  variable = cvar.find(drawCvars, "r_anisotropy")
  if variable is not void then
    gl_anisotropy = native.trunc(variable.value)
    if gl_anisotropy < 2 then gl_anisotropy = 1 end if
    if gl_anisotropy > 16 then gl_anisotropy = 16 end if
  end if
  return true
end function

/// Update module state for video size.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function SetVideoSize(width, height)
  global drawVideoWidth, drawVideoHeight, drawViewport
  if width < 1 then width = 1 end if
  if height < 1 then height = 1 end if
  drawVideoWidth = width
  drawVideoHeight = height
  drawViewport = [0, 0, width, height]
  return true
end function

/// Update subsystem configuration for register draw picture.
/// @param picture The picture input consumed by `registerDrawPicture`.
/// @param coordinates The coordinates input consumed by `registerDrawPicture`.
/// @param pixels The pixels input consumed by `registerDrawPicture`.
function registerDrawPicture(picture, coordinates, pixels)
  global drawPictureObjects, drawPictureCoordinates, drawPicturePixels
  index = 0
  while index < len(drawPictureObjects)
    if drawPictureObjects[index] == picture then
      drawPictureCoordinates[index] = coordinates
      drawPicturePixels[index] = pixels
      return picture
    end if
    index = index + 1
  end while
  drawPictureObjects = drawPictureObjects + [picture]
  drawPictureCoordinates = drawPictureCoordinates + [coordinates]
  drawPicturePixels = drawPicturePixels + [pixels]
  return picture
end function

/// Return picture metadata index derived from the active module state.
/// @param picture The picture input consumed by `pictureMetadataIndex`.
function pictureMetadataIndex(picture)
  index = 0
  while index < len(drawPictureObjects)
    if drawPictureObjects[index] == picture then return index end if
    index = index + 1
  end while
  return -1
end function

/// Implements the `pictureCoordinates` operation for `miniquake.render.draw2d` (picture coordinates).
/// @param picture The picture input consumed by `pictureCoordinates`.
function pictureCoordinates(picture)
  index = pictureMetadataIndex(picture)
  if index < 0 then return [0.0, 0.0, 1.0, 1.0] end if
  return drawPictureCoordinates[index]
end function

/// Implements the `picturePixels` operation for `miniquake.render.draw2d` (picture pixels).
/// @param picture The picture input consumed by `picturePixels`.
function picturePixels(picture)
  index = pictureMetadataIndex(picture)
  if index < 0 then return bytes() end if
  return drawPicturePixels[index]
end function

/// Read and validate qpic.
/// @param data Input data consumed by the operation.
/// @param name Stable name that identifies the requested object or option.
function parseQpic(data, name)
  if len(data) < 8 then return error(3310, name + ": qpic header is truncated") end if
  width = bio.i32(data, 0)
  height = bio.i32(data, 4)
  if width <= 0 or height <= 0 or width > 4096 or height > 4096 then return error(3311, name + ": invalid qpic dimensions") end if
  count = width * height
  if count < 0 or 8 + count > len(data) then return error(3312, name + ": qpic pixels are truncated") end if
  return [width, height, slice(data, 8, count)]
end function

/// Mirror Quake's GL_Bind routine and its observable state changes.
/// @param texnum The texnum input consumed by `GL_Bind`.
function GL_Bind(texnum)
  global currenttexture
  syncDrawCvars()
  if gl_nobind != 0.0 then texnum = char_texture end if
  // Other renderer modules share MiniQuake's texture namespace but do not own
  // this legacy cache variable.  Verify the actual wrapper state as well so a
  // world/entity/particle bind between 2-D frames cannot make us skip the
  // charset or HUD bind.
  if currenttexture == texnum and gl.currentBoundTexture() == texnum then return texnum end if
  currenttexture = texnum
  gl.bindTexture(texnum)
  return texnum
end function

/// Mirror Quake's GL_FindTexture routine and its observable state changes.
/// @param identifier The identifier input consumed by `GL_FindTexture`.
function GL_FindTexture(identifier)
  index = 0
  while index < len(glTextureNames)
    if glTextureNames[index] == identifier then return glTextureIds[index] end if
    index = index + 1
  end while
  return -1
end function

/// Mirror Quake's GL_ResampleTexture routine and its observable state changes.
/// @param input The input input consumed by `GL_ResampleTexture`.
/// @param inputWidth The input width input consumed by `GL_ResampleTexture`.
/// @param inputHeight The input height input consumed by `GL_ResampleTexture`.
/// @param outputWidth The output width input consumed by `GL_ResampleTexture`.
/// @param outputHeight The output height input consumed by `GL_ResampleTexture`.
function GL_ResampleTexture(input, inputWidth, inputHeight, outputWidth, outputHeight)
  if inputWidth <= 0 or inputHeight <= 0 or outputWidth <= 0 or outputHeight <= 0 then return error(3313, "GL_ResampleTexture: invalid dimensions") end if
  if len(input) < inputWidth * inputHeight * 4 then return error(3314, "GL_ResampleTexture: source is truncated") end if
  output = bytes(outputWidth * outputHeight * 4)
  fractionStep = native.trunc((inputWidth * 65536) / outputWidth)
  y = 0
  while y < outputHeight
    inputY = native.trunc((y * inputHeight) / outputHeight)
    fraction = fractionStep >> 1
    x = 0
    while x < outputWidth
      inputX = fraction >> 16
      source = (inputY * inputWidth + inputX) * 4
      destination = (y * outputWidth + x) * 4
      output[destination] = input[source]
      output[destination + 1] = input[source + 1]
      output[destination + 2] = input[source + 2]
      output[destination + 3] = input[source + 3]
      fraction = fraction + fractionStep
      x = x + 1
    end while
    y = y + 1
  end while
  return output
end function

/// Mirror Quake's GL_Resample8BitTexture routine and its observable state changes.
/// @param input The input input consumed by `GL_Resample8BitTexture`.
/// @param inputWidth The input width input consumed by `GL_Resample8BitTexture`.
/// @param inputHeight The input height input consumed by `GL_Resample8BitTexture`.
/// @param outputWidth The output width input consumed by `GL_Resample8BitTexture`.
/// @param outputHeight The output height input consumed by `GL_Resample8BitTexture`.
function GL_Resample8BitTexture(input, inputWidth, inputHeight, outputWidth, outputHeight)
  if inputWidth <= 0 or inputHeight <= 0 or outputWidth <= 0 or outputHeight <= 0 then return error(3315, "GL_Resample8BitTexture: invalid dimensions") end if
  if len(input) < inputWidth * inputHeight then return error(3316, "GL_Resample8BitTexture: source is truncated") end if
  output = bytes(outputWidth * outputHeight)
  fractionStep = native.trunc((inputWidth * 65536) / outputWidth)
  y = 0
  while y < outputHeight
    inputY = native.trunc((y * inputHeight) / outputHeight)
    fraction = fractionStep >> 1
    x = 0
    while x < outputWidth
      output[y * outputWidth + x] = input[inputY * inputWidth + (fraction >> 16)]
      fraction = fraction + fractionStep
      x = x + 1
    end while
    y = y + 1
  end while
  return output
end function

/// Mirror Quake's GL_MipMap routine and its observable state changes.
/// @param input The input input consumed by `GL_MipMap`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function GL_MipMap(input, width, height)
  if width <= 1 or height <= 1 then
    keepWidth = width >> 1
    keepHeight = height >> 1
    if keepWidth < 1 then keepWidth = 1 end if
    if keepHeight < 1 then keepHeight = 1 end if
    return slice(input, 0, keepWidth * keepHeight * 4)
  end if
  outputWidth = width >> 1
  outputHeight = height >> 1
  output = bytes(outputWidth * outputHeight * 4)
  y = 0
  while y < outputHeight
    x = 0
    while x < outputWidth
      source = (y * 2 * width + x * 2) * 4
      below = source + width * 4
      destination = (y * outputWidth + x) * 4
      channel = 0
      while channel < 4
        output[destination + channel] = (input[source + channel] + input[source + 4 + channel] + input[below + channel] + input[below + 4 + channel]) >> 2
        channel = channel + 1
      end while
      x = x + 1
    end while
    y = y + 1
  end while
  index = 0
  while index < len(output)
    input[index] = output[index]
    index = index + 1
  end while
  return output
end function

/// Return nearest palette index derived from the active module state.
/// @param red The red input consumed by `nearestPaletteIndex`.
/// @param green The green input consumed by `nearestPaletteIndex`.
/// @param blue The blue input consumed by `nearestPaletteIndex`.
function nearestPaletteIndex(red, green, blue)
  if len(drawPalette) < 768 then return 0 end if
  best = 0
  bestDistance = 100000000
  index = 0
  while index < 256
    paletteOffset = index * 3
    deltaR = red - drawPalette[paletteOffset]
    deltaG = green - drawPalette[paletteOffset + 1]
    deltaB = blue - drawPalette[paletteOffset + 2]
    distance = deltaR * deltaR + deltaG * deltaG + deltaB * deltaB
    if distance < bestDistance then best = index; bestDistance = distance end if
    index = index + 1
  end while
  return best
end function

/// Mirror Quake's GL_MipMap8Bit routine and its observable state changes.
/// @param input The input input consumed by `GL_MipMap8Bit`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function GL_MipMap8Bit(input, width, height)
  if len(drawPalette) < 768 then return error(3326, "GL_MipMap8Bit: palette is unavailable") end if
  if width <= 1 or height <= 1 then
    keepWidth = width >> 1
    keepHeight = height >> 1
    if keepWidth < 1 then keepWidth = 1 end if
    if keepHeight < 1 then keepHeight = 1 end if
    return slice(input, 0, keepWidth * keepHeight)
  end if
  outputWidth = width >> 1
  outputHeight = height >> 1
  output = bytes(outputWidth * outputHeight)
  y = 0
  while y < outputHeight
    x = 0
    while x < outputWidth
      first = input[y * 2 * width + x * 2]
      second = input[y * 2 * width + x * 2 + 1]
      third = input[(y * 2 + 1) * width + x * 2]
      fourth = input[(y * 2 + 1) * width + x * 2 + 1]
      red5 = (drawPalette[first * 3] + drawPalette[second * 3] + drawPalette[third * 3] + drawPalette[fourth * 3]) >> 5
      green5 = (drawPalette[first * 3 + 1] + drawPalette[second * 3 + 1] + drawPalette[third * 3 + 1] + drawPalette[fourth * 3 + 1]) >> 5
      blue5 = (drawPalette[first * 3 + 2] + drawPalette[second * 3 + 2] + drawPalette[third * 3 + 2] + drawPalette[fourth * 3 + 2]) >> 5
      output[y * outputWidth + x] = nearestPaletteIndex(red5 * 8 + 4, green5 * 8 + 4, blue5 * 8 + 4)
      x = x + 1
    end while
    y = y + 1
  end while
  index = 0
  while index < len(output)
    input[index] = output[index]
    index = index + 1
  end while
  return output
end function

/// Return next power of two for the active module state.
/// @param value Value consumed by `nextPowerOfTwo`.
function nextPowerOfTwo(value)
  result = 1
  while result < value
    result = result << 1
  end while
  return result
end function

// Return the active backend-neutral texture-upscale selection.
function GL_TextureUpscaleMode()
  syncDrawCvars()
  return textureUpscale.clampMode(gl_textureupscale)
end function

// Return the effective upload limit. Opt-in high-resolution scaling raises
// the historical 1024 default to 2048 while still respecting a larger
// explicit gl_max_size selected by a mod or advanced configuration.
function effectiveTextureMaximum()
  maximum = native.trunc(gl_max_size)
  if maximum < 1 then maximum = 1 end if
  if GL_TextureUpscaleMode() != textureUpscale.UPSCALE_OFF and maximum < 2048 then maximum = 2048 end if
  if maximum > 4096 then maximum = 4096 end if
  return maximum
end function

/// Upscale one non-UI RGBA texture before the ordinary power-of-two and mip
/// processing. Textures which cannot gain resolution within the configured
/// upload limit remain unchanged instead of allocating a throwaway image.
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function GL_UpscaleTextureRgba(data, width, height)
  mode = GL_TextureUpscaleMode()
  if mode == textureUpscale.UPSCALE_OFF then return [data, width, height] end if
  factor = textureUpscale.scaleFactor(mode)
  maximum = effectiveTextureMaximum()
  if width * factor > maximum or height * factor > maximum then return [data, width, height] end if
  return textureUpscale.apply(data, width, height, mode)
end function

/// Create and initialize upload32 levels.
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param mipmap The mipmap input consumed by `BuildUpload32Levels`.
function BuildUpload32Levels(data, width, height, mipmap)
  syncDrawCvars()
  if width <= 0 or height <= 0 or len(data) < width * height * 4 then return error(3317, "GL_Upload32: invalid source") end if
  scaledWidth = nextPowerOfTwo(width)
  scaledHeight = nextPowerOfTwo(height)
  shift = native.trunc(gl_picmip)
  if shift < 0 then shift = 0 end if
  scaledWidth = scaledWidth >> shift
  scaledHeight = scaledHeight >> shift
  if scaledWidth < 1 then scaledWidth = 1 end if
  if scaledHeight < 1 then scaledHeight = 1 end if
  maximum = effectiveTextureMaximum()
  if scaledWidth > maximum then scaledWidth = maximum end if
  if scaledHeight > maximum then scaledHeight = maximum end if
  maximumPixels = 524288
  if GL_TextureUpscaleMode() != textureUpscale.UPSCALE_OFF then maximumPixels = 16777216 end if
  if scaledWidth * scaledHeight > maximumPixels then return error(3318, "GL_LoadTexture: too big") end if
  pixels = data
  if scaledWidth != width or scaledHeight != height then pixels = GL_ResampleTexture(data, width, height, scaledWidth, scaledHeight) else pixels = slice(data, 0, width * height * 4) end if
  // GL_Upload32 submits every level before GL_MipMap quarters its shared
  // scratch buffer in place.  Our wrapper defers the submissions until the
  // complete level list exists, so mip the copy and retain each original
  // level untouched.
  levels = [[scaledWidth, scaledHeight, pixels]]
  if mipmap then
    currentWidth = scaledWidth
    currentHeight = scaledHeight
    current = pixels
    while currentWidth > 1 or currentHeight > 1
      scratch = slice(current, 0, currentWidth * currentHeight * 4)
      next = GL_MipMap(scratch, currentWidth, currentHeight)
      currentWidth = currentWidth >> 1
      currentHeight = currentHeight >> 1
      if currentWidth < 1 then currentWidth = 1 end if
      if currentHeight < 1 then currentHeight = 1 end if
      levels = levels + [[currentWidth, currentHeight, next]]
      current = next
    end while
  end if
  return levels
end function

/// Mirror Quake's GL_Upload32 routine and its observable state changes.
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param mipmap The mipmap input consumed by `GL_Upload32`.
/// @param alpha The alpha input consumed by `GL_Upload32`.
function GL_Upload32(data, width, height, mipmap, alpha)
  global texels
  levels = BuildUpload32Levels(data, width, height, mipmap)
  if levels is error then return levels end if
  internalFormat = gl.GL_RGB
  if alpha then internalFormat = gl.GL_RGBA end if
  level = 0
  while level < len(levels)
    item = levels[level]
    if not (item is array) or len(item) < 3 or not (item[2] is bytes) then
      return error(3340, "GL_Upload32: invalid mip level " + level + " for " + width + "x" + height)
    end if
    gl.uploadRgbaLevel(level, internalFormat, item[0], item[1], item[2])
    level = level + 1
  end while
  texels = texels + levels[0][0] * levels[0][1]
  if mipmap then
    minimumFilter = gl_filter_min
    if gl_anisotropy > 1 then minimumFilter = gl.GL_LINEAR_MIPMAP_LINEAR end if
    gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, minimumFilter)
    gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl_filter_max)
    gl.textureParameter(gl.GL_TEXTURE_MAX_ANISOTROPY_EXT, gl_anisotropy)
  else
    gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl_filter_max)
    gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl_filter_max)
  end if
  return levels
end function

/// Implements the `indexedToUploadRgba` operation for `miniquake.render.draw2d` (indexed to upload rgba).
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `indexedToUploadRgba`.
function indexedToUploadRgba(data, width, height, alpha)
  count = width * height
  if len(drawPalette) < 768 then return error(3319, "GL_Upload8: palette is unavailable") end if
  if len(data) < count then return error(3320, "GL_Upload8: source is truncated") end if
  rgba = bytes(count * 4)
  hasAlpha = false
  index = 0
  while index < count
    value = data[index]
    paletteOffset = value * 3
    destination = index * 4
    rgba[destination] = drawPalette[paletteOffset]
    rgba[destination + 1] = drawPalette[paletteOffset + 1]
    rgba[destination + 2] = drawPalette[paletteOffset + 2]
    rgba[destination + 3] = 255
    if value == 255 then rgba[destination + 3] = 0; hasAlpha = true end if
    index = index + 1
  end while
  return [rgba, alpha and hasAlpha]
end function

/// Mirror Quake's GL_Upload8_EXT routine and its observable state changes.
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param mipmap The mipmap input consumed by `GL_Upload8_EXT`.
/// @param alpha The alpha input consumed by `GL_Upload8_EXT`.
function GL_Upload8_EXT(data, width, height, mipmap, alpha)
  // GL_COLOR_INDEX8_EXT is not guaranteed by modern Windows drivers.  The
  // indexed mip chain is converted through the same Quake palette before
  // upload, preserving rendered color and transparency.
  converted = indexedToUploadRgba(data, width, height, alpha)
  if converted is error then return converted end if
  prepared = [converted[0], width, height]
  if mipmap then prepared = GL_UpscaleTextureRgba(converted[0], width, height) end if
  if prepared is error then return prepared end if
  return GL_Upload32(prepared[0], prepared[1], prepared[2], mipmap, converted[1])
end function

/// Mirror Quake's GL_Upload8 routine and its observable state changes.
/// @param data Input data consumed by the operation.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param mipmap The mipmap input consumed by `GL_Upload8`.
/// @param alpha The alpha input consumed by `GL_Upload8`.
function GL_Upload8(data, width, height, mipmap, alpha)
  if not alpha and ((width * height) & 3) != 0 then return error(3321, "GL_Upload8: s&3") end if
  converted = indexedToUploadRgba(data, width, height, alpha)
  if converted is error then return converted end if
  prepared = [converted[0], width, height]
  if mipmap then prepared = GL_UpscaleTextureRgba(converted[0], width, height) end if
  if prepared is error then return prepared end if
  return GL_Upload32(prepared[0], prepared[1], prepared[2], mipmap, converted[1])
end function

/// Mirror Quake's GL_LoadTexture routine and its observable state changes.
/// @param identifier The identifier input consumed by `GL_LoadTexture`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param data Input data consumed by the operation.
/// @param mipmap The mipmap input consumed by `GL_LoadTexture`.
/// @param alpha The alpha input consumed by `GL_LoadTexture`.
function GL_LoadTexture(identifier, width, height, data, mipmap, alpha)
  global glTextureNames, glTextureIds, glTextureWidths, glTextureHeights, glTextureMipmaps, texture_extension_number
  if identifier != "" then
    index = 0
    while index < len(glTextureNames)
      if glTextureNames[index] == identifier then
        if glTextureWidths[index] != width or glTextureHeights[index] != height then return error(3322, "GL_LoadTexture: cache mismatch") end if
        return glTextureIds[index]
      end if
      index = index + 1
    end while
  end if
  if len(glTextureNames) >= MAX_GLTEXTURES then return error(3323, "MAX_GLTEXTURES") end if
  texture = gl.generateTexture()
  texture_extension_number = gl.nextTextureNameValue()
  GL_Bind(texture)
  uploaded = GL_Upload8(data, width, height, mipmap, alpha)
  if uploaded is error then return uploaded end if
  // Preserve MiniQuake 1.09's observable registry quirk: only anonymous
  // textures advance numgltextures. Named cache misses are uploaded into the
  // provisional slot but are not made searchable by GL_FindTexture.
  if identifier == "" then
    glTextureNames = glTextureNames + [identifier]
    glTextureIds = glTextureIds + [texture]
    glTextureWidths = glTextureWidths + [width]
    glTextureHeights = glTextureHeights + [height]
    glTextureMipmaps = glTextureMipmaps + [mipmap]
  end if
  return texture
end function

/// Mirror Quake's GL_LoadPicTexture routine and its observable state changes.
/// @param pic The pic input consumed by `GL_LoadPicTexture`.
function GL_LoadPicTexture(pic)
  pixels = picturePixels(pic)
  if len(pixels) < pic.width * pic.height then return error(3324, "GL_LoadPicTexture: picture pixels unavailable") end if
  return GL_LoadTexture("", pic.width, pic.height, pixels, false, true)
end function

/// Mirror Quake's GL_SelectTexture routine and its observable state changes.
/// @param target The target input consumed by `GL_SelectTexture`.
function GL_SelectTexture(target)
  global oldTextureTarget, currenttexture, currentTextureSlots
  if not glMultiTextureAvailable then return false end if
  if target == oldTextureTarget then return true end if
  oldIndex = oldTextureTarget - gl.GL_TEXTURE0_SGIS
  newIndex = target - gl.GL_TEXTURE0_SGIS
  if oldIndex < 0 or oldIndex > 1 or newIndex < 0 or newIndex > 1 then return error(3325, "GL_SelectTexture: bad target") end if
  currentTextureSlots[oldIndex] = currenttexture
  currenttexture = currentTextureSlots[newIndex]
  oldTextureTarget = target
  return true
end function

/// Update module state for scrap.
/// @param textureIds The texture ids input consumed by `ResetScrap`.
function ResetScrap(textureIds)
  global scrap_allocated, scrap_texels, scrap_textures, scrap_dirty, scrap_uploads
  scrap_allocated = []
  scrap_texels = []
  texnum = 0
  while texnum < MAX_SCRAPS
    scrap_allocated = scrap_allocated + [arrayutil.makeFilledArray(SCRAP_WIDTH, 0)]
    scrap_texels = scrap_texels + [bytes(SCRAP_WIDTH * SCRAP_HEIGHT)]
    texnum = texnum + 1
  end while
  scrap_textures = textureIds
  scrap_dirty = false
  scrap_uploads = 0
  return true
end function

// Ensure sufficient storage or state for scrap state.
function ensureScrapState()
  global scrap_textures, texture_extension_number
  if len(scrap_allocated) != MAX_SCRAPS then ResetScrap([]) end if
  while len(scrap_textures) < MAX_SCRAPS
    scrap_textures = scrap_textures + [gl.reserveTextureNames(1)]
    texture_extension_number = gl.nextTextureNameValue()
  end while
  return true
end function

/// C returns the scrap number and writes x/y through pointer arguments.  The
/// MiniLang port returns the three values as [scrap, x, y].
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function Scrap_AllocBlock(width, height)
  if width <= 0 or height <= 0 or width > SCRAP_WIDTH or height > SCRAP_HEIGHT then
    return error(3327, "Scrap_AllocBlock: invalid dimensions")
  end if
  if len(scrap_allocated) != MAX_SCRAPS then ResetScrap([]) end if
  texnum = 0
  while texnum < MAX_SCRAPS
    best = SCRAP_HEIGHT
    bestX = 0
    bestY = 0
    x = 0
    // Preserve MiniQuake's strict '< BLOCK_WIDTH-w' upper bound.
    while x < SCRAP_WIDTH - width
      best2 = 0
      column = 0
      while column < width
        allocated = scrap_allocated[texnum][x + column]
        if allocated >= best then column = width + 1
        else
          if allocated > best2 then best2 = allocated end if
          column = column + 1
        end if
      end while
      if column == width then
        best = best2
        bestX = x
        bestY = best2
      end if
      x = x + 1
    end while
    if best + height <= SCRAP_HEIGHT then
      x = 0
      while x < width
        scrap_allocated[texnum][bestX + x] = best + height
        x = x + 1
      end while
      return [texnum, bestX, bestY]
    end if
    texnum = texnum + 1
  end while
  return error(3328, "Scrap_AllocBlock: full")
end function

// Mirror Quake's Scrap_Upload routine and its observable state changes.
function Scrap_Upload()
  global scrap_dirty, scrap_uploads
  ensureScrapState()
  scrap_uploads = scrap_uploads + 1
  texnum = 0
  while texnum < MAX_SCRAPS
    GL_Bind(scrap_textures[texnum])
    uploaded = GL_Upload8(scrap_texels[texnum], SCRAP_WIDTH, SCRAP_HEIGHT, false, true)
    if uploaded is error then return uploaded end if
    texnum = texnum + 1
  end while
  scrap_dirty = false
  return true
end function

/// Implements the `pictureFromPixels` operation for `miniquake.render.draw2d` (picture from pixels).
/// @param name Stable name that identifies the requested object or option.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `pictureFromPixels`.
/// @param texture Texture resource processed by the operation.
/// @param coordinates The coordinates input consumed by `pictureFromPixels`.
function pictureFromPixels(name, width, height, pixels, texture, coordinates)
  picture = t.MenuPicture(name, width, height, texture)
  registerDrawPicture(picture, coordinates, pixels)
  return picture
end function

/// Render pic from wad.
/// @param name Stable name that identifies the requested object or option.
function Draw_PicFromWad(name)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global scrap_dirty, pic_count, pic_texels, wad_cachepics
  for each cached in wad_cachepics
    if cached.name == "wad:" + name then return cached end if
  end for
  if drawWad is void then return error(3329, "Draw_PicFromWad: gfx.wad is unavailable") end if
  source = try(wad.readLump(drawWad, name))
  if source is error then return source end if
  parsed = try(parseQpic(source, "gfx.wad:" + name))
  if parsed is error then return parsed end if
  width = parsed[0]
  height = parsed[1]
  pixels = parsed[2]
  if width < 64 and height < 64 then
    ensureScrapState()
    allocation = try(Scrap_AllocBlock(width, height))
    if allocation is error then return allocation end if
    scrap = allocation[0]
    scrapX = allocation[1]
    scrapY = allocation[2]
    sourceIndex = 0
    y = 0
    while y < height
      x = 0
      while x < width
        scrap_texels[scrap][(scrapY + y) * SCRAP_WIDTH + scrapX + x] = pixels[sourceIndex]
        sourceIndex = sourceIndex + 1
        x = x + 1
      end while
      y = y + 1
    end while
    scrap_dirty = true
    pic_count = pic_count + 1
    pic_texels = pic_texels + width * height
    coordinates = [
      (scrapX + 0.01) / SCRAP_WIDTH,
      (scrapY + 0.01) / SCRAP_HEIGHT,
      (scrapX + width - 0.01) / SCRAP_WIDTH,
      (scrapY + height - 0.01) / SCRAP_HEIGHT,
    ]
    picture = pictureFromPixels("wad:" + name, width, height, pixels, scrap_textures[scrap], coordinates)
    wad_cachepics = wad_cachepics + [picture]
    return picture
  end if
  temporary = pictureFromPixels("wad:" + name, width, height, pixels, 0, [0.0, 0.0, 1.0, 1.0])
  texture = try(GL_LoadPicTexture(temporary))
  if texture is error then return texture end if
  temporary.textureId = texture
  wad_cachepics = wad_cachepics + [temporary]
  return temporary
end function

/// Render cache pic.
/// @param path Filesystem path to process.
function Draw_CachePic(path)
  global menu_cachepics, menuplyr_pixels
  for each picture in menu_cachepics
    if picture.name == path then return picture end if
  end for
  if len(menu_cachepics) >= MAX_CACHED_PICS then return error(3330, "menu_numcachepics == MAX_CACHED_PICS") end if
  if drawFilesystem is void then return error(3331, "Draw_CachePic: filesystem is unavailable") end if
  source = try(qfs.readFile(drawFilesystem, path))
  if source is error then return error(3332, "Draw_CachePic: failed to load " + path) end if
  parsed = try(parseQpic(source, path))
  if parsed is error then return parsed end if
  width = parsed[0]
  height = parsed[1]
  pixels = parsed[2]
  if path == "gfx/menuplyr.lmp" then
    count = width * height
    if count > 4096 then count = 4096 end if
    menuplyr_pixels = bytes(4096)
    index = 0
    while index < count
      menuplyr_pixels[index] = pixels[index]
      index = index + 1
    end while
  end if
  picture = pictureFromPixels(path, width, height, pixels, 0, [0.0, 0.0, 1.0, 1.0])
  texture = try(GL_LoadPicTexture(picture))
  if texture is error then return texture end if
  picture.textureId = texture
  menu_cachepics = menu_cachepics + [picture]
  return picture
end function

/// C's dest pointer is represented by an explicit destination byte offset.
/// @param num The num input consumed by `Draw_CharToConback`.
/// @param destination Destination value or collection to update.
/// @param destinationOffset Zero-based offset of the requested data.
function Draw_CharToConback(num, destination, destinationOffset)
  if len(draw_chars) < 16384 then return error(3333, "Draw_CharToConback: charset unavailable") end if
  num = num & 255
  row = num >> 4
  column = num & 15
  sourceOffset = (row << 10) + (column << 3)
  line = 0
  while line < 8
    x = 0
    while x < 8
      if draw_chars[sourceOffset + x] != 255 then destination[destinationOffset + x] = 0x60 + draw_chars[sourceOffset + x] end if
      x = x + 1
    end while
    sourceOffset = sourceOffset + 128
    destinationOffset = destinationOffset + 320
    line = line + 1
  end while
  return destination
end function

/// Implements the `filterModes` operation for `miniquake.render.draw2d` (filter modes).
function filterModes()
  return [
    ["GL_NEAREST", gl.GL_NEAREST, gl.GL_NEAREST],
    ["GL_LINEAR", gl.GL_LINEAR, gl.GL_LINEAR],
    ["GL_NEAREST_MIPMAP_NEAREST", gl.GL_NEAREST_MIPMAP_NEAREST, gl.GL_NEAREST],
    ["GL_LINEAR_MIPMAP_NEAREST", gl.GL_LINEAR_MIPMAP_NEAREST, gl.GL_LINEAR],
    ["GL_NEAREST_MIPMAP_LINEAR", gl.GL_NEAREST_MIPMAP_LINEAR, gl.GL_NEAREST],
    ["GL_LINEAR_MIPMAP_LINEAR", gl.GL_LINEAR_MIPMAP_LINEAR, gl.GL_LINEAR],
  ]
end function

/// Render texture mode f.
/// @param arguments Command-line arguments to inspect or execute.
function Draw_TextureMode_f(arguments)
  global gl_filter_min, gl_filter_max
  modes = filterModes()
  if len(arguments) <= 1 then
    for each mode in modes
      if gl_filter_min == mode[1] then return mode[0] end if
    end for
    return "current filter is unknown???"
  end if
  wanted = bio.lower(arguments[1])
  selected = void
  for each mode in modes
    if bio.lower(mode[0]) == wanted then selected = mode end if
  end for
  if selected is void then return "bad filter name" end if
  gl_filter_min = selected[1]
  gl_filter_max = selected[2]
  index = 0
  while index < len(glTextureIds)
    if glTextureMipmaps[index] then
      GL_Bind(glTextureIds[index])
      gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl_filter_min)
      gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl_filter_max)
    end if
    index = index + 1
  end while
  return selected[0]
end function

// Apply the archived anisotropy level to every resident mipmapped texture.
// This makes the Video Mode selection effective immediately without a costly
// renderer or map restart.
function Draw_ApplyAnisotropy()
  syncDrawCvars()
  minimumFilter = gl_filter_min
  if gl_anisotropy > 1 then minimumFilter = gl.GL_LINEAR_MIPMAP_LINEAR end if
  index = 0
  while index < len(glTextureIds)
    if glTextureMipmaps[index] then
      GL_Bind(glTextureIds[index])
      gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, minimumFilter)
      gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl_filter_max)
      gl.textureParameter(gl.GL_TEXTURE_MAX_ANISOTROPY_EXT, gl_anisotropy)
    end if
    index = index + 1
  end while
  return gl_anisotropy
end function

/// Render init.
/// @param filesystem The filesystem input consumed by `Draw_Init`.
/// @param palette The palette input consumed by `Draw_Init`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param cvars The cvars input consumed by `Draw_Init`.
function Draw_Init(filesystem, palette, width, height, cvars)
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global drawWad, draw_chars, char_texture, translate_texture, conback, draw_disc, draw_backtile, wad_cachepics, texture_extension_number, gl_max_size
  configureDraw(filesystem, palette, cvars)
  SetVideoSize(width, height)
  if cvars is not void then
    if cvar.find(cvars, "gl_nobind") is void then cvars.variables = [cvar.create("gl_nobind", "0", false, false)] + cvars.variables end if
    if cvar.find(cvars, "gl_max_size") is void then cvars.variables = [cvar.create("gl_max_size", "1024", false, false)] + cvars.variables end if
    if cvar.find(cvars, "gl_picmip") is void then cvars.variables = [cvar.create("gl_picmip", "0", false, false)] + cvars.variables end if
    if cvar.find(cvars, "r_textureupscale") is void then cvars.variables = [cvar.create("r_textureupscale", "0", true, false)] + cvars.variables end if
    if cvar.find(cvars, "r_anisotropy") is void then cvars.variables = [cvar.create("r_anisotropy", "1", true, false)] + cvars.variables end if
  end if
  syncDrawCvars()
  rendererName = gl.getString(gl.GL_RENDERER)
  rendererLower = bio.lower(rendererName)
  rendererBytes = bytes(rendererLower)
  is3dfx = len(rendererBytes) >= 4 and rendererBytes[0] == 51 and rendererBytes[1] == 100 and rendererBytes[2] == 102 and rendererBytes[3] == 120
  if is3dfx or string.indexOf(rendererName, "Glide", 0) >= 0 then
    gl_max_size = 256.0
    if cvars is not void then
      maximumVariable = cvar.find(cvars, "gl_max_size")
      if maximumVariable is not void then maximumVariable.string = "256"; maximumVariable.value = 256.0 end if
    end if
  end if
  wadData = try(qfs.readFile(filesystem, "gfx.wad"))
  if wadData is error then return wadData end if
  drawWad = try(wad.parse(wadData, "gfx.wad"))
  if drawWad is error then return drawWad end if
  draw_chars = try(wad.readLump(drawWad, "conchars"))
  if draw_chars is error then return draw_chars end if
  if len(draw_chars) < 16384 then return error(3334, "Draw_Init: conchars is truncated") end if
  draw_chars = slice(draw_chars, 0, 16384)
  index = 0
  while index < len(draw_chars)
    if draw_chars[index] == 0 then draw_chars[index] = 255 end if
    index = index + 1
  end while
  char_texture = try(GL_LoadTexture("charset", 128, 128, draw_chars, false, true))
  if char_texture is error then return char_texture end if
  GL_Bind(char_texture)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)

  conbackData = try(qfs.readFile(filesystem, "gfx/conback.lmp"))
  if conbackData is error then return conbackData end if
  parsed = try(parseQpic(conbackData, "gfx/conback.lmp"))
  if parsed is error then return parsed end if
  conWidth = parsed[0]
  conHeight = parsed[1]
  conPixels = parsed[2]
  version = "(gl 1.00) 1.09"
  versionBytes = bytes(version)
  destinationOffset = conWidth * 186 + conWidth - 11 - 8 * len(versionBytes)
  index = 0
  while index < len(versionBytes)
    Draw_CharToConback(versionBytes[index], conPixels, destinationOffset + (index << 3))
    index = index + 1
  end while
  conbackPicture = pictureFromPixels("gfx/conback.lmp", width, height, conPixels, 0, [0.0, 0.0, 1.0, 1.0])
  conbackTexture = try(GL_LoadTexture("conback", conWidth, conHeight, conPixels, false, false))
  if conbackTexture is error then return conbackTexture end if
  conbackPicture.textureId = conbackTexture
  conback = conbackPicture

  translate_texture = gl.reserveTextureNames(1)
  scrapBase = gl.reserveTextureNames(2)
  ResetScrap([scrapBase, scrapBase + 1])
  texture_extension_number = gl.nextTextureNameValue()
  wad_cachepics = []
  draw_disc = try(Draw_PicFromWad("disc"))
  if draw_disc is error then return draw_disc end if
  draw_backtile = try(Draw_PicFromWad("backtile"))
  if draw_backtile is error then return draw_backtile end if
  return true
end function

// Render shutdown.
function Draw_Shutdown()
  // Preserve this routine's phase ordering: validate and prepare state before mutation and output.
  global drawFilesystem, drawPalette, drawWad, drawCvars, draw_chars, draw_disc, draw_backtile, conback, menuplyr_pixels
  global char_texture, translate_texture, currenttexture, menu_cachepics, wad_cachepics
  global drawPictureObjects, drawPictureCoordinates, drawPicturePixels
  global glTextureNames, glTextureIds, glTextureWidths, glTextureHeights, glTextureMipmaps, texture_extension_number
  global glMultiTextureAvailable, oldTextureTarget, currentTextureSlots
  textureIds = []
  if char_texture != 0 then textureIds = textureIds + [char_texture] end if
  if translate_texture != 0 then textureIds = textureIds + [translate_texture] end if
  for each texture in scrap_textures
    if texture != 0 then textureIds = textureIds + [texture] end if
  end for
  for each texture in glTextureIds
    if texture != 0 then textureIds = textureIds + [texture] end if
  end for
  if conback is not void and conback.textureId != 0 then textureIds = textureIds + [conback.textureId] end if
  if draw_disc is not void and draw_disc.textureId != 0 then textureIds = textureIds + [draw_disc.textureId] end if
  if draw_backtile is not void and draw_backtile.textureId != 0 then textureIds = textureIds + [draw_backtile.textureId] end if
  for each picture in menu_cachepics
    if picture is not void and picture.textureId != 0 then textureIds = textureIds + [picture.textureId] end if
  end for
  for each picture in wad_cachepics
    if picture is not void and picture.textureId != 0 then textureIds = textureIds + [picture.textureId] end if
  end for
  deleted = []
  for each texture in textureIds
    seen = false
    for each previous in deleted
      if previous == texture then seen = true end if
    end for
    if not seen then gl.deleteTexture(texture); deleted = deleted + [texture] end if
  end for
  drawFilesystem = void
  drawPalette = bytes()
  drawWad = void
  drawCvars = void
  draw_chars = bytes()
  draw_disc = void
  draw_backtile = void
  conback = void
  menuplyr_pixels = bytes(4096)
  char_texture = 0
  translate_texture = 0
  currenttexture = -1
  menu_cachepics = []
  wad_cachepics = []
  drawPictureObjects = []
  drawPictureCoordinates = []
  drawPicturePixels = []
  glTextureNames = []
  glTextureIds = []
  glTextureWidths = []
  glTextureHeights = []
  glTextureMipmaps = []
  texture_extension_number = 1
  gl.resetTextureNames(1)
  gl.setBoundTextureForCompatibility(-1)
  glMultiTextureAvailable = false
  oldTextureTarget = gl.GL_TEXTURE0_SGIS
  currentTextureSlots = [-1, -1]
  ResetScrap([])
  return true
end function

/// Implements the `CharTexture` operation for `miniquake.render.draw2d` (char texture).
function CharTexture()
  return char_texture
end function

/// Implements the `PictureUsesScrap` operation for `miniquake.render.draw2d` (picture uses scrap).
/// @param picture The picture input consumed by `PictureUsesScrap`.
function PictureUsesScrap(picture)
  if picture is void then return false end if
  for each texture in scrap_textures
    if picture.textureId == texture then return true end if
  end for
  return false
end function

/// Render character.
/// @param x The x input consumed by `Draw_Character`.
/// @param y The y input consumed by `Draw_Character`.
/// @param num The num input consumed by `Draw_Character`.
function Draw_Character(x, y, num)
  if num == 32 or y <= -8 then return false end if
  num = num & 255
  row = num >> 4
  column = num & 15
  s0 = column * 0.0625
  t0 = row * 0.0625
  GL_Bind(char_texture)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(s0, t0); gl.vertex2(x, y)
  gl.texcoord2(s0 + 0.0625, t0); gl.vertex2(x + 8, y)
  gl.texcoord2(s0 + 0.0625, t0 + 0.0625); gl.vertex2(x + 8, y + 8)
  gl.texcoord2(s0, t0 + 0.0625); gl.vertex2(x, y + 8)
  gl.finishPrimitive()
  return true
end function

/// Render string.
/// @param x The x input consumed by `Draw_String`.
/// @param y The y input consumed by `Draw_String`.
/// @param text Text to parse or process.
function Draw_String(x, y, text)
  data = bytes(text)
  index = 0
  while index < len(data)
    Draw_Character(x, y, data[index])
    x = x + 8
    index = index + 1
  end while
  return x
end function

/// Render debug char.
/// @param num The num input consumed by `Draw_DebugChar`.
function Draw_DebugChar(num)
  return false
end function

/// Return alpha byte derived from the active module state.
/// @param alpha The alpha input consumed by `alphaByte`.
function alphaByte(alpha)
  value = native.trunc(alpha * 255.0 + 0.5)
  if value < 0 then value = 0 end if
  if value > 255 then value = 255 end if
  return value
end function

/// Render picture quad.
/// @param picture The picture input consumed by `drawPictureQuad`.
/// @param x The x input consumed by `drawPictureQuad`.
/// @param y The y input consumed by `drawPictureQuad`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `drawPictureQuad`.
function drawPictureQuad(picture, x, y, width, height, alpha)
  coordinates = pictureCoordinates(picture)
  GL_Bind(picture.textureId)
  gl.color(255, 255, 255, alpha)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(coordinates[0], coordinates[1]); gl.vertex2(x, y)
  gl.texcoord2(coordinates[2], coordinates[1]); gl.vertex2(x + width, y)
  gl.texcoord2(coordinates[2], coordinates[3]); gl.vertex2(x + width, y + height)
  gl.texcoord2(coordinates[0], coordinates[3]); gl.vertex2(x, y + height)
  gl.finishPrimitive()
  return true
end function

/// Render pic trace.
/// @param x The x input consumed by `Draw_PicTrace`.
/// @param y The y input consumed by `Draw_PicTrace`.
/// @param picture The picture input consumed by `Draw_PicTrace`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `Draw_PicTrace`.
function Draw_PicTrace(x, y, picture, width, height, alpha)
  coordinates = pictureCoordinates(picture)
  return [
    ["bind", picture.textureId],
    ["color", 255, 255, 255, alpha],
    ["vertex", coordinates[0], coordinates[1], x, y],
    ["vertex", coordinates[2], coordinates[1], x + width, y],
    ["vertex", coordinates[2], coordinates[3], x + width, y + height],
    ["vertex", coordinates[0], coordinates[3], x, y + height],
  ]
end function

/// Render alpha pic.
/// @param x The x input consumed by `Draw_AlphaPic`.
/// @param y The y input consumed by `Draw_AlphaPic`.
/// @param picture The picture input consumed by `Draw_AlphaPic`.
/// @param alpha The alpha input consumed by `Draw_AlphaPic`.
function Draw_AlphaPic(x, y, picture, alpha)
  return Draw_AlphaPicSized(x, y, picture, picture.width, picture.height, alpha)
end function

/// Render alpha pic sized.
/// @param x The x input consumed by `Draw_AlphaPicSized`.
/// @param y The y input consumed by `Draw_AlphaPicSized`.
/// @param picture The picture input consumed by `Draw_AlphaPicSized`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `Draw_AlphaPicSized`.
function Draw_AlphaPicSized(x, y, picture, width, height, alpha)
  if scrap_dirty then
    uploaded = Scrap_Upload()
    if uploaded is error then return uploaded end if
  end if
  gl.disable(gl.GL_ALPHA_TEST)
  gl.enable(gl.GL_BLEND)
  coordinates = pictureCoordinates(picture)
  gl.colorFloat(1.0, 1.0, 1.0, alpha)
  GL_Bind(picture.textureId)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(coordinates[0], coordinates[1]); gl.vertex2(x, y)
  gl.texcoord2(coordinates[2], coordinates[1]); gl.vertex2(x + width, y)
  gl.texcoord2(coordinates[2], coordinates[3]); gl.vertex2(x + width, y + height)
  gl.texcoord2(coordinates[0], coordinates[3]); gl.vertex2(x, y + height)
  gl.finishPrimitive()
  gl.colorFloat(1.0, 1.0, 1.0, 1.0)
  gl.enable(gl.GL_ALPHA_TEST)
  gl.disable(gl.GL_BLEND)
  return true
end function

/// Render pic.
/// @param x The x input consumed by `Draw_Pic`.
/// @param y The y input consumed by `Draw_Pic`.
/// @param picture The picture input consumed by `Draw_Pic`.
function Draw_Pic(x, y, picture)
  if scrap_dirty then
    uploaded = Scrap_Upload()
    if uploaded is error then return uploaded end if
  end if
  return drawPictureQuad(picture, x, y, picture.width, picture.height, 255)
end function

/// Render pic scaled.
/// @param picture The picture input consumed by `Draw_PicScaled`.
/// @param x The x input consumed by `Draw_PicScaled`.
/// @param y The y input consumed by `Draw_PicScaled`.
/// @param scale The scale input consumed by `Draw_PicScaled`.
/// @param alpha The alpha input consumed by `Draw_PicScaled`.
function Draw_PicScaled(picture, x, y, scale, alpha)
  if scrap_dirty then
    uploaded = Scrap_Upload()
    if uploaded is error then return uploaded end if
  end if
  return drawPictureQuad(picture, x, y, picture.width * scale, picture.height * scale, alpha)
end function

/// Render pic sized.
/// @param picture The picture input consumed by `Draw_PicSized`.
/// @param x The x input consumed by `Draw_PicSized`.
/// @param y The y input consumed by `Draw_PicSized`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `Draw_PicSized`.
function Draw_PicSized(picture, x, y, width, height, alpha)
  if scrap_dirty then
    uploaded = Scrap_Upload()
    if uploaded is error then return uploaded end if
  end if
  return drawPictureQuad(picture, x, y, width, height, alpha)
end function

/// Render pic sized nearest.
/// @param picture The picture input consumed by `Draw_PicSizedNearest`.
/// @param x The x input consumed by `Draw_PicSizedNearest`.
/// @param y The y input consumed by `Draw_PicSizedNearest`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param alpha The alpha input consumed by `Draw_PicSizedNearest`.
function Draw_PicSizedNearest(picture, x, y, width, height, alpha)
  if scrap_dirty then
    uploaded = Scrap_Upload()
    if uploaded is error then return uploaded end if
  end if
  // Integer-scaled Quake UI art must not sample across neighboring entries in
  // the shared scrap atlas.  Temporarily use nearest filtering for the draw,
  // then restore the user's ordinary texture mode for native-size pictures.
  GL_Bind(picture.textureId)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
  result = drawPictureQuad(picture, x, y, width, height, alpha)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl_filter_max)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl_filter_max)
  return result
end function

/// Render trans pic.
/// @param x The x input consumed by `Draw_TransPic`.
/// @param y The y input consumed by `Draw_TransPic`.
/// @param picture The picture input consumed by `Draw_TransPic`.
function Draw_TransPic(x, y, picture)
  if x < 0 or x + picture.width > drawVideoWidth or y < 0 or y + picture.height > drawVideoHeight then
    return error(3335, "Draw_TransPic: bad coordinates")
  end if
  return Draw_Pic(x, y, picture)
end function

/// Create and initialize translated pic pixels.
/// @param picture The picture input consumed by `BuildTranslatedPicPixels`.
/// @param translation The translation input consumed by `BuildTranslatedPicPixels`.
function BuildTranslatedPicPixels(picture, translation)
  if len(translation) < 256 then return error(3336, "Draw_TransPicTranslate: translation is truncated") end if
  if len(drawPalette) < 768 then return error(3337, "Draw_TransPicTranslate: palette is unavailable") end if
  sourcePixels = menuplyr_pixels
  if len(sourcePixels) < picture.width * picture.height then sourcePixels = picturePixels(picture) end if
  if len(sourcePixels) < picture.width * picture.height then return error(3338, "Draw_TransPicTranslate: source pixels unavailable") end if
  output = bytes(64 * 64 * 4)
  v = 0
  while v < 64
    sourceY = (v * picture.height) >> 6
    u = 0
    while u < 64
      sourceX = (u * picture.width) >> 6
      value = sourcePixels[sourceY * picture.width + sourceX]
      destination = (v * 64 + u) * 4
      if value == 255 then
        output[destination] = 255
        output[destination + 1] = 0
        output[destination + 2] = 0
        output[destination + 3] = 0
      else
        translated = translation[value]
        output[destination] = drawPalette[translated * 3]
        output[destination + 1] = drawPalette[translated * 3 + 1]
        output[destination + 2] = drawPalette[translated * 3 + 2]
        output[destination + 3] = 255
      end if
      u = u + 1
    end while
    v = v + 1
  end while
  return output
end function

/// Render trans pic translate sized.
/// @param x The x input consumed by `Draw_TransPicTranslateSized`.
/// @param y The y input consumed by `Draw_TransPicTranslateSized`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param picture The picture input consumed by `Draw_TransPicTranslateSized`.
/// @param translation The translation input consumed by `Draw_TransPicTranslateSized`.
function Draw_TransPicTranslateSized(x, y, width, height, picture, translation)
  translatedPixels = try(BuildTranslatedPicPixels(picture, translation))
  if translatedPixels is error then return translatedPixels end if
  GL_Bind(translate_texture)
  gl.uploadRgbaLevel(0, gl_alpha_format, 64, 64, translatedPixels)
  gl.textureParameter(gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.textureParameter(gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.color(255, 255, 255, 255)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(0.0, 0.0); gl.vertex2(x, y)
  gl.texcoord2(1.0, 0.0); gl.vertex2(x + width, y)
  gl.texcoord2(1.0, 1.0); gl.vertex2(x + width, y + height)
  gl.texcoord2(0.0, 1.0); gl.vertex2(x, y + height)
  gl.finishPrimitive()
  return true
end function

/// Render trans pic translate.
/// @param x The x input consumed by `Draw_TransPicTranslate`.
/// @param y The y input consumed by `Draw_TransPicTranslate`.
/// @param picture The picture input consumed by `Draw_TransPicTranslate`.
/// @param translation The translation input consumed by `Draw_TransPicTranslate`.
function Draw_TransPicTranslate(x, y, picture, translation)
  return Draw_TransPicTranslateSized(x, y, picture.width, picture.height, picture, translation)
end function

/// Render console background.
/// @param lines The lines input consumed by `Draw_ConsoleBackground`.
function Draw_ConsoleBackground(lines)
  if conback is void then return false end if
  threshold = (drawVideoHeight * 3) >> 2
  if lines > threshold then return Draw_PicSized(conback, 0, lines - drawVideoHeight, drawVideoWidth, drawVideoHeight, 255) end if
  alpha = 1.2 * lines / threshold
  return Draw_AlphaPicSized(0, lines - drawVideoHeight, conback, drawVideoWidth, drawVideoHeight, alpha)
end function

/// Render tile clear.
/// @param x The x input consumed by `Draw_TileClear`.
/// @param y The y input consumed by `Draw_TileClear`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function Draw_TileClear(x, y, width, height)
  if draw_backtile is void then return false end if
  gl.color(255, 255, 255, 255)
  GL_Bind(draw_backtile.textureId)
  gl.begin(gl.GL_QUADS)
  gl.texcoord2(x / 64.0, y / 64.0); gl.vertex2(x, y)
  gl.texcoord2((x + width) / 64.0, y / 64.0); gl.vertex2(x + width, y)
  gl.texcoord2((x + width) / 64.0, (y + height) / 64.0); gl.vertex2(x + width, y + height)
  gl.texcoord2(x / 64.0, (y + height) / 64.0); gl.vertex2(x, y + height)
  gl.finishPrimitive()
  return true
end function

/// Render trace set backtile.
/// @param picture The picture input consumed by `Draw_TraceSetBacktile`.
function Draw_TraceSetBacktile(picture)
  global draw_backtile, currenttexture
  draw_backtile = picture
  currenttexture = -1
  return picture
end function

/// Deterministic state injection used only by the pinned-source differential.
/// It keeps the actual production functions under test and avoids requiring an
/// OpenGL context merely to arrange their original global inputs.
/// @param palette The palette input consumed by `Draw_DifferentialReset`.
function Draw_DifferentialReset(palette)
  global drawFilesystem, drawPalette, drawWad, drawCvars, drawVideoWidth, drawVideoHeight, drawViewport
  global draw_chars, draw_disc, draw_backtile, conback, menuplyr_pixels
  global char_texture, translate_texture, currenttexture, gl_nobind, gl_max_size, gl_picmip, gl_textureupscale, gl_anisotropy
  global gl_filter_min, gl_filter_max, texels, pic_texels, pic_count, drawSbarChanges
  global menu_cachepics, wad_cachepics, drawPictureObjects, drawPictureCoordinates, drawPicturePixels
  global glTextureNames, glTextureIds, glTextureWidths, glTextureHeights, glTextureMipmaps, texture_extension_number
  global glMultiTextureAvailable, oldTextureTarget, currentTextureSlots
  drawFilesystem = void
  drawPalette = palette
  drawWad = void
  drawCvars = void
  drawVideoWidth = 640
  drawVideoHeight = 480
  drawViewport = [3, 4, 640, 480]
  draw_chars = bytes(16384)
  draw_disc = void
  draw_backtile = void
  conback = void
  menuplyr_pixels = bytes(4096)
  char_texture = 0
  translate_texture = 0
  currenttexture = -1
  gl_nobind = 0.0
  gl_max_size = 1024.0
  gl_picmip = 0.0
  gl_textureupscale = 0
  gl_anisotropy = 1
  gl_filter_min = gl.GL_LINEAR_MIPMAP_NEAREST
  gl_filter_max = gl.GL_LINEAR
  texels = 0
  pic_texels = 0
  pic_count = 0
  drawSbarChanges = 0
  menu_cachepics = []
  wad_cachepics = []
  drawPictureObjects = []
  drawPictureCoordinates = []
  drawPicturePixels = []
  glTextureNames = []
  glTextureIds = []
  glTextureWidths = []
  glTextureHeights = []
  glTextureMipmaps = []
  texture_extension_number = 1
  gl.resetTextureNames(1)
  gl.setBoundTextureForCompatibility(-1)
  glMultiTextureAvailable = false
  oldTextureTarget = gl.GL_TEXTURE0_SGIS
  currentTextureSlots = [-1, -1]
  ResetScrap([])
  return true
end function

/// Render differential set globals.
/// @param characterTexture The character texture input consumed by `Draw_DifferentialSetGlobals`.
/// @param translatedTexture The translated texture input consumed by `Draw_DifferentialSetGlobals`.
/// @param noBind The no bind input consumed by `Draw_DifferentialSetGlobals`.
/// @param characters The characters input consumed by `Draw_DifferentialSetGlobals`.
/// @param menuPixels The menu pixels input consumed by `Draw_DifferentialSetGlobals`.
function Draw_DifferentialSetGlobals(characterTexture, translatedTexture, noBind, characters, menuPixels)
  global char_texture, translate_texture, gl_nobind, draw_chars, menuplyr_pixels, currenttexture
  char_texture = characterTexture
  translate_texture = translatedTexture
  gl_nobind = noBind
  draw_chars = characters
  menuplyr_pixels = menuPixels
  currenttexture = -1
  return true
end function

/// Render differential use assets.
/// @param filesystem The filesystem input consumed by `Draw_DifferentialUseAssets`.
/// @param wadArchive The wad archive input consumed by `Draw_DifferentialUseAssets`.
function Draw_DifferentialUseAssets(filesystem, wadArchive)
  global drawFilesystem, drawWad
  drawFilesystem = filesystem
  drawWad = wadArchive
  return true
end function

// Render differential reset picture caches.
function Draw_DifferentialResetPictureCaches()
  global menu_cachepics, wad_cachepics, pic_count, pic_texels, scrap_dirty
  menu_cachepics = []
  wad_cachepics = []
  pic_count = 0
  pic_texels = 0
  scrap_dirty = false
  return true
end function

/// Render differential set pictures.
/// @param disc The disc input consumed by `Draw_DifferentialSetPictures`.
/// @param backtile The backtile input consumed by `Draw_DifferentialSetPictures`.
/// @param consolePicture The console picture input consumed by `Draw_DifferentialSetPictures`.
function Draw_DifferentialSetPictures(disc, backtile, consolePicture)
  global draw_disc, draw_backtile, conback, currenttexture
  draw_disc = disc
  draw_backtile = backtile
  conback = consolePicture
  currenttexture = -1
  return true
end function

/// Render differential set caches.
/// @param wadPictures The wad pictures input consumed by `Draw_DifferentialSetCaches`.
/// @param menuPictures The menu pictures input consumed by `Draw_DifferentialSetCaches`.
/// @param consolePicture The console picture input consumed by `Draw_DifferentialSetCaches`.
function Draw_DifferentialSetCaches(wadPictures, menuPictures, consolePicture)
  global wad_cachepics, menu_cachepics, conback
  wad_cachepics = wadPictures
  menu_cachepics = menuPictures
  conback = consolePicture
  return true
end function

/// Render differential set texture state.
/// @param nextTexture The next texture input consumed by `Draw_DifferentialSetTextureState`.
/// @param current The current input consumed by `Draw_DifferentialSetTextureState`.
/// @param names The names input consumed by `Draw_DifferentialSetTextureState`.
/// @param ids The ids input consumed by `Draw_DifferentialSetTextureState`.
/// @param widths The widths input consumed by `Draw_DifferentialSetTextureState`.
/// @param heights The heights input consumed by `Draw_DifferentialSetTextureState`.
/// @param mipmaps The mipmaps input consumed by `Draw_DifferentialSetTextureState`.
function Draw_DifferentialSetTextureState(nextTexture, current, names, ids, widths, heights, mipmaps)
  global texture_extension_number, currenttexture
  global glTextureNames, glTextureIds, glTextureWidths, glTextureHeights, glTextureMipmaps
  texture_extension_number = nextTexture
  gl.resetTextureNames(nextTexture)
  gl.setBoundTextureForCompatibility(current)
  currenttexture = current
  glTextureNames = names
  glTextureIds = ids
  glTextureWidths = widths
  glTextureHeights = heights
  glTextureMipmaps = mipmaps
  return true
end function

/// Render differential set multitexture.
/// @param available The available input consumed by `Draw_DifferentialSetMultitexture`.
/// @param current The current input consumed by `Draw_DifferentialSetMultitexture`.
/// @param slot0 The slot0 input consumed by `Draw_DifferentialSetMultitexture`.
/// @param slot1 The slot1 input consumed by `Draw_DifferentialSetMultitexture`.
function Draw_DifferentialSetMultitexture(available, current, slot0, slot1)
  global glMultiTextureAvailable, oldTextureTarget, currenttexture, currentTextureSlots
  glMultiTextureAvailable = available
  oldTextureTarget = gl.GL_TEXTURE0_SGIS
  currenttexture = current
  currentTextureSlots = [slot0, slot1]
  return true
end function

// Render differential state.
function Draw_DifferentialState()
  return [
    currenttexture, gl_filter_min, gl_filter_max, texels,
    scrap_dirty, scrap_uploads, pic_count, pic_texels,
    char_texture, translate_texture, texture_extension_number,
    len(glTextureNames), currentTextureSlots[0], currentTextureSlots[1],
    scrap_textures, draw_disc is not void, draw_backtile is not void,
    drawSbarChanges,
  ]
end function

/// Render fill.
/// @param x The x input consumed by `Draw_Fill`.
/// @param y The y input consumed by `Draw_Fill`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param colorIndex Zero-based index of the requested entry.
function Draw_Fill(x, y, width, height, colorIndex)
  if colorIndex < 0 or colorIndex > 255 or len(drawPalette) < 768 then return error(3339, "Draw_Fill: bad color") end if
  paletteOffset = colorIndex * 3
  solidQuad(x, y, width, height, drawPalette[paletteOffset], drawPalette[paletteOffset + 1], drawPalette[paletteOffset + 2], 255)
  gl.color(255, 255, 255, 255)
  return true
end function

// Render fade screen.
function Draw_FadeScreen()
  global drawSbarChanges
  gl.enable(gl.GL_BLEND)
  gl.disable(gl.GL_TEXTURE_2D)
  gl.color(0, 0, 0, 204)
  gl.begin(gl.GL_QUADS)
  gl.vertex2(0, 0)
  gl.vertex2(drawVideoWidth, 0)
  gl.vertex2(drawVideoWidth, drawVideoHeight)
  gl.vertex2(0, drawVideoHeight)
  gl.finishPrimitive()
  gl.color(255, 255, 255, 255)
  gl.enable(gl.GL_TEXTURE_2D)
  gl.disable(gl.GL_BLEND)
  drawSbarChanges = drawSbarChanges + 1
  return true
end function

// Render begin disc.
function Draw_BeginDisc()
  if draw_disc is void then return false end if
  gl.drawBuffer(gl.GL_FRONT)
  Draw_Pic(drawVideoWidth - 24, 0, draw_disc)
  gl.drawBuffer(gl.GL_BACK)
  return true
end function

// Render end disc.
function Draw_EndDisc()
  return true
end function

// Mirror Quake's GL_Set2D routine and its observable state changes.
function GL_Set2D()
  global currenttexture
  // Native world batches can leave texture unit 1 enabled even after the
  // compatibility renderer has logically ended its multitexture pass.  A 2-D
  // qpic would then be combined with the last world/lightmap texture, turning
  // intermission words and digits into striped blocks.  Establish the same
  // single-texture state that GLQuake's Draw paths assume, and invalidate both
  // binding caches because they do not track native batch binds per unit.
  if gl.multitextureAvailable() then
    gl.activeTexture(1)
    gl.disable(gl.GL_TEXTURE_2D)
    gl.activeTexture(0)
    gl.enable(gl.GL_TEXTURE_2D)
  end if
  gl.setBoundTextureForCompatibility(-1)
  currenttexture = -1
  gl.viewport(drawViewport[0], drawViewport[1], drawViewport[2], drawViewport[3])
  gl.matrixMode(gl.GL_PROJECTION)
  gl.loadIdentity()
  gl.ortho(0.0, drawVideoWidth * 1.0, drawVideoHeight * 1.0, 0.0, -99999.0, 99999.0)
  gl.matrixMode(gl.GL_MODELVIEW)
  gl.loadIdentity()
  gl.disable(gl.GL_DEPTH_TEST)
  gl.disable(gl.GL_CULL_FACE)
  gl.disable(gl.GL_BLEND)
  gl.enable(gl.GL_ALPHA_TEST)
  gl.color(255, 255, 255, 255)
  return true
end function
