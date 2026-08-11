package miniquake.render.gl11

import miniquake.native as native

diagnosticTraceEnabled = false
diagnosticTrace = []
nextTextureName = 1
boundTextureName = -1

function Trace_Begin()
  global diagnosticTraceEnabled, diagnosticTrace
  diagnosticTraceEnabled = true
  diagnosticTrace = []
  return true
end function

function Trace_End()
  global diagnosticTraceEnabled
  diagnosticTraceEnabled = false
  return diagnosticTrace
end function

function inline traceEnabled()
  return diagnosticTraceEnabled
end function

function traceCommand(name, arguments)
  global diagnosticTrace
  if not diagnosticTraceEnabled then return false end if
  diagnosticTrace = diagnosticTrace + [[name, arguments]]
  return true
end function

// MiniQuake 1.09 allocates every renderer texture from the single global
// texture_extension_number namespace.  Keeping that namespace here prevents
// independently ported world, entity and 2-D upload paths from reusing and
// overwriting each other's OpenGL object names.
function reserveTextureNames(count)
  global nextTextureName
  if count < 1 then return nextTextureName end if
  first = nextTextureName
  nextTextureName = nextTextureName + count
  return first
end function

function inline nextTextureNameValue()
  return nextTextureName
end function

function resetTextureNames(first)
  global nextTextureName
  if first < 1 then first = 1 end if
  nextTextureName = first
  return nextTextureName
end function

function currentBoundTexture()
  return boundTextureName
end function

function setBoundTextureForCompatibility(texture)
  global boundTextureName
  boundTextureName = texture
  return boundTextureName
end function

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
const GL_NEAREST_MIPMAP_NEAREST = 0x2700
const GL_LINEAR_MIPMAP_NEAREST = 0x2701
const GL_NEAREST_MIPMAP_LINEAR = 0x2702
const GL_LINEAR_MIPMAP_LINEAR = 0x2703
const GL_VENDOR = 0x1F00
const GL_RENDERER = 0x1F01
const GL_VERSION = 0x1F02
const GL_EXTENSIONS = 0x1F03

function bits(value)
  return native.floatBits(value)
end function

function begin(mode)
  if diagnosticTraceEnabled and traceCommand("begin", [mode]) then return void end if
  native.glBegin(mode)
end function

function finishPrimitive()
  if diagnosticTraceEnabled and traceCommand("end", []) then return void end if
  native.glEnd()
end function

function vertex2(x, y)
  if diagnosticTraceEnabled and traceCommand("vertex", [x, y]) then return void end if
  native.glVertex2(bits(x), bits(y))
end function

function vertex3(x, y, z)
  if diagnosticTraceEnabled and traceCommand("vertex", [x, y, z]) then return void end if
  native.glVertex3(bits(x), bits(y), bits(z))
end function

function texcoord2(s, t)
  if diagnosticTraceEnabled and traceCommand("texcoord", [s, t]) then return void end if
  native.glTexcoord2(bits(s), bits(t))
end function

function color(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("color", [red / 255.0, green / 255.0, blue / 255.0, alpha / 255.0]) then return void end if
  native.glColor4ub(red, green, blue, alpha)
end function

function colorFloat(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("color", [red, green, blue, alpha]) then return void end if
  native.glColor4ub(
    native.trunc(red * 255.0),
    native.trunc(green * 255.0),
    native.trunc(blue * 255.0),
    native.trunc(alpha * 255.0),
  )
end function

function clearColor(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("clear_color", [bits(red), bits(green), bits(blue), bits(alpha)]) then return void end if
  native.glClearColor(bits(red), bits(green), bits(blue), bits(alpha))
end function

function clear(mask)
  if diagnosticTraceEnabled and traceCommand("clear", [mask]) then return void end if
  native.glClear(mask)
end function

function enable(capability)
  if diagnosticTraceEnabled and traceCommand("enable", [capability]) then return void end if
  native.glEnable(capability)
end function

function disable(capability)
  if diagnosticTraceEnabled and traceCommand("disable", [capability]) then return void end if
  native.glDisable(capability)
end function

function blendFunc(source, destination)
  if diagnosticTraceEnabled and traceCommand("blend_function", [source, destination]) then return void end if
  native.glBlendFunc(source, destination)
end function

function depthFunc(value)
  if diagnosticTraceEnabled and traceCommand("depth_func", [value]) then return void end if
  native.glDepthFunc(value)
end function

function depthMask(enabled)
  if diagnosticTraceEnabled and enabled and traceCommand("depth_mask", [1]) then return void end if
  if diagnosticTraceEnabled and not enabled and traceCommand("depth_mask", [0]) then return void end if
  if enabled then native.glDepthMask(1) else native.glDepthMask(0) end if
end function

function depthRange(nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("depth_range", [bits(nearValue), bits(farValue)]) then return void end if
  native.glDepthRange(bits(nearValue), bits(farValue))
end function

function viewport(x, y, width, height)
  if diagnosticTraceEnabled and traceCommand("viewport", [x, y, width, height]) then return void end if
  native.glViewport(x, y, width, height)
end function

function matrixMode(mode)
  if diagnosticTraceEnabled and traceCommand("matrix_mode", [mode]) then return void end if
  native.glMatrixMode(mode)
end function

function loadIdentity()
  if diagnosticTraceEnabled and traceCommand("load_identity", []) then return void end if
  native.glLoadIdentity()
end function

function pushMatrix()
  if diagnosticTraceEnabled and traceCommand("push_matrix", []) then return void end if
  native.glPushMatrix()
end function

function popMatrix()
  if diagnosticTraceEnabled and traceCommand("pop_matrix", []) then return void end if
  native.glPopMatrix()
end function

function translate(x, y, z)
  if diagnosticTraceEnabled and traceCommand("translate", [x, y, z]) then return void end if
  native.glTranslate(bits(x), bits(y), bits(z))
end function

function rotate(angle, x, y, z)
  if diagnosticTraceEnabled and traceCommand("rotate", [angle, x, y, z]) then return void end if
  native.glRotate(bits(angle), bits(x), bits(y), bits(z))
end function

function scale(x, y, z)
  native.glScale(bits(x), bits(y), bits(z))
end function

function ortho(left, right, bottom, top, nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("ortho", [left, right, bottom, top, nearValue, farValue]) then return void end if
  native.glOrtho(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

function frustum(left, right, bottom, top, nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("frustum", [left, right, bottom, top, nearValue, farValue]) then return void end if
  native.glFrustum(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

function polygonMode(face, mode)
  native.glPolygonMode(face, mode)
end function

function shadeModel(mode)
  if diagnosticTraceEnabled and traceCommand("shade_model", [mode]) then return void end if
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
const GL_COLOR_INDEX = 0x1900
const GL_COLOR_INDEX8_EXT = 0x80E5
const GL_TEXTURE0_SGIS = 0x835E
const GL_TEXTURE1_SGIS = 0x835F
const GL_LUMINANCE = 0x1909
const GL_TEXTURE_WRAP_S = 0x2802
const GL_TEXTURE_WRAP_T = 0x2803
const GL_REPEAT = 0x2901
const GL_CLAMP = 0x2900
const GL_TEXTURE_ENV = 0x2300
const GL_TEXTURE_ENV_MODE = 0x2200
const GL_REPLACE = 0x1E01
const GL_MODULATE = 0x2100

function alphaFunc(functionName, reference)
  native.glAlphaFunc(functionName, bits(reference))
end function

function cullFace(mode)
  if diagnosticTraceEnabled and traceCommand("cull_face", [mode]) then return void end if
  native.glCullFace(mode)
end function

function bindTexture(texture)
  global boundTextureName
  if texture == boundTextureName then return void end if
  boundTextureName = texture
  if diagnosticTraceEnabled and traceCommand("bind_texture", [GL_TEXTURE_2D, texture]) then return void end if
  native.glBindTexture(GL_TEXTURE_2D, texture)
end function

function generateTexture()
  return reserveTextureNames(1)
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
  if diagnosticTraceEnabled and traceCommand("texture_parameter", [GL_TEXTURE_2D, name, value]) then return void end if
  native.glTexParameterI(GL_TEXTURE_2D, name, value)
end function

function textureEnvironment(mode)
  if diagnosticTraceEnabled and traceCommand("texture_environment", [GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode]) then return void end if
  native.glTexEnvI(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode)
end function

function uploadRgba(width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_rgba", [0, GL_RGBA, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

function uploadRgbaLevel(level, internalFormat, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_rgba", [level, internalFormat, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, level, internalFormat, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

function uploadIndexedLevel(level, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_indexed", [level, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, level, GL_COLOR_INDEX8_EXT, width, height, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, pixels)
end function

function uploadRgb(width, height, pixels)
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels)
end function

function uploadLuminance(width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_luminance", [width, height]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels)
end function

function uploadLuminanceSubImage(x, y, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_luminance_subimage", [x, y, width, height]) then return void end if
  native.glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels)
end function

function readPixelsRgba(x, y, width, height)
  if width < 1 or height < 1 then return bytes() end if
  pixels = bytes(width * height * 4)
  native.glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
  return pixels
end function

function finish()
  if diagnosticTraceEnabled and traceCommand("finish", []) then return void end if
  native.glFinish()
end function

function drawBuffer(mode)
  if diagnosticTraceEnabled and traceCommand("draw_buffer", [mode]) then return void end if
  native.glDrawBuffer(mode)
end function

function staticGeometryCall(objectValue, passId)
  return native.glStaticGeometryCall(nativeRawValue(objectValue), passId) != 0
end function

function staticGeometryCallBatch(keys, passId)
  return native.glStaticGeometryCallBatch(keys, len(keys), passId) > 0
end function

function clearStaticGeometryCache()
  native.glStaticGeometryClear()
end function
