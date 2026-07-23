package miniquake.render.draw2d

import miniquake.render.gl11 as gl
import miniquake.native as native
import miniquake.byteio as bio
import miniquake.types as t

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

// Quake qpic_t files store little-endian width/height followed by indexed
// pixels.  Menu artwork uses palette index 255 as transparent.
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

function end2d()
  gl.color(255, 255, 255, 255)
  gl.disable(gl.GL_BLEND)
  gl.depthMask(true)
end function

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
  start = len(state.lines) - lineCount
  if start < 0 then start = 0 end if
  index = start
  while index < len(state.lines)
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

function drawStatus(texture, width, height, text)
  if texture == 0 then return false end if
  begin2d(width, height)
  solidQuad(0.0, height - 24.0, width * 1.0, 24.0, 0, 0, 0, 160)
  string(texture, 8.0, height - 16.0, text, 1.0, 255)
  end2d()
  return true
end function
