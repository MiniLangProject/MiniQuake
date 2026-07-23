package miniquake.render.gl11

import miniquake.native as native

const GL_POINTS = 0x0000
const GL_LINES = 0x0001
const GL_LINE_LOOP = 0x0002
const GL_LINE_STRIP = 0x0003
const GL_TRIANGLES = 0x0004
const GL_TRIANGLE_STRIP = 0x0005
const GL_TRIANGLE_FAN = 0x0006
const GL_QUADS = 0x0007
const GL_POLYGON = 0x0009
const GL_DEPTH_BUFFER_BIT = 0x00000100
const GL_COLOR_BUFFER_BIT = 0x00004000
const GL_DEPTH_TEST = 0x0B71
const GL_BLEND = 0x0BE2
const GL_TEXTURE_2D = 0x0DE1
const GL_CULL_FACE = 0x0B44
const GL_PROJECTION = 0x1701
const GL_MODELVIEW = 0x1700
const GL_LEQUAL = 0x0203
const GL_GEQUAL = 0x0206
const GL_SMOOTH = 0x1D01
const GL_FLAT = 0x1D00
const GL_FRONT = 0x0404
const GL_FRONT_AND_BACK = 0x0408
const GL_LINE = 0x1B01
const GL_FILL = 0x1B02
const GL_SRC_ALPHA = 0x0302
const GL_ONE_MINUS_SRC_ALPHA = 0x0303
const GL_RGBA = 0x1908
const GL_RGB = 0x1907
const GL_UNSIGNED_BYTE = 0x1401
const GL_TEXTURE_MIN_FILTER = 0x2801
const GL_TEXTURE_MAG_FILTER = 0x2800
const GL_NEAREST = 0x2600
const GL_LINEAR = 0x2601
const GL_VENDOR = 0x1F00
const GL_RENDERER = 0x1F01
const GL_VERSION = 0x1F02

function bits(value)
  return native.floatBits(value)
end function

function begin(mode)
  native.glBegin(mode)
end function

function finishPrimitive()
  native.glEnd()
end function

function vertex2(x, y)
  native.glVertex2(bits(x), bits(y))
end function

function vertex3(x, y, z)
  native.glVertex3(bits(x), bits(y), bits(z))
end function

function texcoord2(s, t)
  native.glTexcoord2(bits(s), bits(t))
end function

function color(red, green, blue, alpha)
  native.glColor4ub(red, green, blue, alpha)
end function

function clearColor(red, green, blue, alpha)
  native.glClearColor(bits(red), bits(green), bits(blue), bits(alpha))
end function

function clear(mask)
  native.glClear(mask)
end function

function enable(capability)
  native.glEnable(capability)
end function

function disable(capability)
  native.glDisable(capability)
end function

function blendFunc(source, destination)
  native.glBlendFunc(source, destination)
end function

function depthFunc(value)
  native.glDepthFunc(value)
end function

function depthMask(enabled)
  if enabled then native.glDepthMask(1) else native.glDepthMask(0) end if
end function

function depthRange(nearValue, farValue)
  native.glDepthRange(bits(nearValue), bits(farValue))
end function

function viewport(x, y, width, height)
  native.glViewport(x, y, width, height)
end function

function matrixMode(mode)
  native.glMatrixMode(mode)
end function

function loadIdentity()
  native.glLoadIdentity()
end function

function pushMatrix()
  native.glPushMatrix()
end function

function popMatrix()
  native.glPopMatrix()
end function

function translate(x, y, z)
  native.glTranslate(bits(x), bits(y), bits(z))
end function

function rotate(angle, x, y, z)
  native.glRotate(bits(angle), bits(x), bits(y), bits(z))
end function

function scale(x, y, z)
  native.glScale(bits(x), bits(y), bits(z))
end function

function ortho(left, right, bottom, top, nearValue, farValue)
  native.glOrtho(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

function frustum(left, right, bottom, top, nearValue, farValue)
  native.glFrustum(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

function polygonMode(face, mode)
  native.glPolygonMode(face, mode)
end function

function shadeModel(mode)
  native.glShadeModel(mode)
end function

function getString(name)
  value = native.glGetString(name)
  if value is void then return "" end if
  return value
end function

function errorCode()
  return native.glGetError()
end function

function flush()
  native.glFlush()
end function

const GL_ZERO = 0
const GL_ONE = 1
const GL_SRC_COLOR = 0x0300
const GL_ONE_MINUS_SRC_COLOR = 0x0301
const GL_DST_COLOR = 0x0306
const GL_ONE_MINUS_DST_COLOR = 0x0307
const GL_ALPHA_TEST = 0x0BC0
const GL_GREATER = 0x0204
const GL_BACK = 0x0405
const GL_LUMINANCE = 0x1909
const GL_TEXTURE_WRAP_S = 0x2802
const GL_TEXTURE_WRAP_T = 0x2803
const GL_REPEAT = 0x2901
const GL_CLAMP = 0x2900

function alphaFunc(functionName, reference)
  native.glAlphaFunc(functionName, bits(reference))
end function

function cullFace(mode)
  native.glCullFace(mode)
end function

function bindTexture(texture)
  native.glBindTexture(GL_TEXTURE_2D, texture)
end function

function generateTexture()
  ids = bytes(4)
  native.glGenTextures(1, ids)
  return ids[0] | (ids[1] << 8) | (ids[2] << 16) | (ids[3] << 24)
end function

function deleteTexture(texture)
  ids = bytes(4)
  ids[0] = texture & 255
  ids[1] = (texture >> 8) & 255
  ids[2] = (texture >> 16) & 255
  ids[3] = (texture >> 24) & 255
  native.glDeleteTextures(1, ids)
end function

function textureParameter(name, value)
  native.glTexParameterI(GL_TEXTURE_2D, name, value)
end function

function uploadRgba(width, height, pixels)
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

function uploadRgb(width, height, pixels)
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels)
end function

function uploadLuminance(width, height, pixels)
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels)
end function

function readPixelsRgba(x, y, width, height)
  if width < 1 or height < 1 then return bytes() end if
  pixels = bytes(width * height * 4)
  native.glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
  return pixels
end function

function finish()
  native.glFinish()
end function
