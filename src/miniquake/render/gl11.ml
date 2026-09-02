/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

Quake-compatible MiniLang implementation of miniquake.render.gl11.
*/
package miniquake.render.gl11

import miniquake.native as native

/// Tracks the module-level diagnostic trace enabled state owned by `miniquake.render.gl11`.
diagnosticTraceEnabled = false
/// Tracks the module-level diagnostic trace state owned by `miniquake.render.gl11`.
diagnosticTrace = []
/// Tracks the module-level next texture name state owned by `miniquake.render.gl11`.
nextTextureName = 1
/// Tracks the module-level bound texture name state owned by `miniquake.render.gl11`.
boundTextureName = -1

// Trace begin through the collision world.
function Trace_Begin()
  global diagnosticTraceEnabled, diagnosticTrace
  diagnosticTraceEnabled = true
  diagnosticTrace = []
  return true
end function

// Trace end through the collision world.
function Trace_End()
  global diagnosticTraceEnabled
  diagnosticTraceEnabled = false
  return diagnosticTrace
end function

// Trace enabled through the collision world.
function inline traceEnabled()
  return diagnosticTraceEnabled
end function

// Report whether native batch available holds for the active state.
function inline nativeBatchAvailable()
  return true
end function

// Return backend name derived from the active module state.
function backendName()
  backend = native.renderBackend()
  if backend == 1 then return "Direct3D 9" end if
  if backend == 2 then return "Vulkan" end if
  return "OpenGL"
end function

/// Trace command through the collision world.
/// @param name Stable name that identifies the requested object or option.
/// @param arguments Command-line arguments to inspect or execute.
function traceCommand(name, arguments)
  global diagnosticTrace
  if not diagnosticTraceEnabled then return false end if
  diagnosticTrace = diagnosticTrace + [[name, arguments]]
  return true
end function

/// MiniQuake 1.09 allocates every renderer texture from the single global
/// texture_extension_number namespace.  Keeping that namespace here prevents
/// independently ported world, entity and 2-D upload paths from reusing and
/// overwriting each other's OpenGL object names.
/// @param count Number of entries or units to process.
function reserveTextureNames(count)
  global nextTextureName
  if count < 1 then return nextTextureName end if
  first = nextTextureName
  nextTextureName = nextTextureName + count
  return first
end function

// Return next texture name value for the active module state.
function inline nextTextureNameValue()
  return nextTextureName
end function

/// Update module state for texture names.
/// @param first The first input consumed by `resetTextureNames`.
function resetTextureNames(first)
  global nextTextureName
  if first < 1 then first = 1 end if
  nextTextureName = first
  return nextTextureName
end function

// Return bound texture.
function currentBoundTexture()
  return boundTextureName
end function

/// Update module state for bound texture for compatibility.
/// @param texture Texture resource processed by the operation.
function setBoundTextureForCompatibility(texture)
  global boundTextureName
  boundTextureName = texture
  return boundTextureName
end function

/// Defines the gl points value used by `miniquake.render.gl11`.
const GL_POINTS = 0x0000
/// Defines the gl lines value used by `miniquake.render.gl11`.
const GL_LINES = 0x0001
/// Defines the gl line loop value used by `miniquake.render.gl11`.
const GL_LINE_LOOP = 0x0002
/// Defines the gl line strip value used by `miniquake.render.gl11`.
const GL_LINE_STRIP = 0x0003
/// Defines the gl triangles value used by `miniquake.render.gl11`.
const GL_TRIANGLES = 0x0004
/// Defines the gl triangle strip value used by `miniquake.render.gl11`.
const GL_TRIANGLE_STRIP = 0x0005
/// Defines the gl triangle fan value used by `miniquake.render.gl11`.
const GL_TRIANGLE_FAN = 0x0006
/// Defines the gl quads value used by `miniquake.render.gl11`.
const GL_QUADS = 0x0007
/// Defines the gl polygon value used by `miniquake.render.gl11`.
const GL_POLYGON = 0x0009
/// Defines the gl depth buffer bit value used by `miniquake.render.gl11`.
const GL_DEPTH_BUFFER_BIT = 0x00000100
/// Defines the gl color buffer bit value used by `miniquake.render.gl11`.
const GL_COLOR_BUFFER_BIT = 0x00004000
/// Defines the gl depth test value used by `miniquake.render.gl11`.
const GL_DEPTH_TEST = 0x0B71
/// Defines the gl blend value used by `miniquake.render.gl11`.
const GL_BLEND = 0x0BE2
/// Defines the gl texture 2 d value used by `miniquake.render.gl11`.
const GL_TEXTURE_2D = 0x0DE1
/// Defines the gl cull face value used by `miniquake.render.gl11`.
const GL_CULL_FACE = 0x0B44
/// Defines the gl projection value used by `miniquake.render.gl11`.
const GL_PROJECTION = 0x1701
/// Defines the gl modelview value used by `miniquake.render.gl11`.
const GL_MODELVIEW = 0x1700
/// Defines the gl lequal value used by `miniquake.render.gl11`.
const GL_LEQUAL = 0x0203
/// Defines the gl gequal value used by `miniquake.render.gl11`.
const GL_GEQUAL = 0x0206
/// Defines the gl smooth value used by `miniquake.render.gl11`.
const GL_SMOOTH = 0x1D01
/// Defines the gl flat value used by `miniquake.render.gl11`.
const GL_FLAT = 0x1D00
/// Defines the gl front value used by `miniquake.render.gl11`.
const GL_FRONT = 0x0404
/// Defines the gl front and back value used by `miniquake.render.gl11`.
const GL_FRONT_AND_BACK = 0x0408
/// Defines the gl line value used by `miniquake.render.gl11`.
const GL_LINE = 0x1B01
/// Defines the gl fill value used by `miniquake.render.gl11`.
const GL_FILL = 0x1B02
/// Defines the gl src alpha value used by `miniquake.render.gl11`.
const GL_SRC_ALPHA = 0x0302
/// Defines the gl one minus src alpha value used by `miniquake.render.gl11`.
const GL_ONE_MINUS_SRC_ALPHA = 0x0303
/// Defines the gl rgba value used by `miniquake.render.gl11`.
const GL_RGBA = 0x1908
/// Defines the gl rgb value used by `miniquake.render.gl11`.
const GL_RGB = 0x1907
/// Defines the gl unsigned byte value used by `miniquake.render.gl11`.
const GL_UNSIGNED_BYTE = 0x1401
/// Defines the gl texture min filter value used by `miniquake.render.gl11`.
const GL_TEXTURE_MIN_FILTER = 0x2801
/// Defines the gl texture mag filter value used by `miniquake.render.gl11`.
const GL_TEXTURE_MAG_FILTER = 0x2800
/// Defines the gl nearest value used by `miniquake.render.gl11`.
const GL_NEAREST = 0x2600
/// Defines the gl linear value used by `miniquake.render.gl11`.
const GL_LINEAR = 0x2601
/// Defines the gl nearest mipmap nearest value used by `miniquake.render.gl11`.
const GL_NEAREST_MIPMAP_NEAREST = 0x2700
/// Defines the gl linear mipmap nearest value used by `miniquake.render.gl11`.
const GL_LINEAR_MIPMAP_NEAREST = 0x2701
/// Defines the gl nearest mipmap linear value used by `miniquake.render.gl11`.
const GL_NEAREST_MIPMAP_LINEAR = 0x2702
/// Defines the gl linear mipmap linear value used by `miniquake.render.gl11`.
const GL_LINEAR_MIPMAP_LINEAR = 0x2703
/// Defines the gl vendor value used by `miniquake.render.gl11`.
const GL_VENDOR = 0x1F00
/// Defines the gl renderer value used by `miniquake.render.gl11`.
const GL_RENDERER = 0x1F01
/// Defines the gl version value used by `miniquake.render.gl11`.
const GL_VERSION = 0x1F02
/// Defines the gl extensions value used by `miniquake.render.gl11`.
const GL_EXTENSIONS = 0x1F03

/// Return bits derived from the active module state.
/// @param value Value consumed by `bits`.
function bits(value)
  return native.floatBits(value)
end function

/// Initialize state for begin.
/// @param mode The mode input consumed by `begin`.
function begin(mode)
  if diagnosticTraceEnabled and traceCommand("begin", [mode]) then return void end if
  native.glBegin(mode)
end function

// Finalize state for finish primitive.
function finishPrimitive()
  if diagnosticTraceEnabled and traceCommand("end", []) then return void end if
  native.glEnd()
end function

/// Implements the `vertex2` operation for `miniquake.render.gl11` (vertex2).
/// @param x The x input consumed by `vertex2`.
/// @param y The y input consumed by `vertex2`.
function vertex2(x, y)
  if diagnosticTraceEnabled and traceCommand("vertex", [x, y]) then return void end if
  native.glVertex2(bits(x), bits(y))
end function

/// Implements the `vertex3` operation for `miniquake.render.gl11` (vertex3).
/// @param x The x input consumed by `vertex3`.
/// @param y The y input consumed by `vertex3`.
/// @param z The z input consumed by `vertex3`.
function vertex3(x, y, z)
  if diagnosticTraceEnabled and traceCommand("vertex", [x, y, z]) then return void end if
  native.glVertex3(bits(x), bits(y), bits(z))
end function

/// Implements the `texcoord2` operation for `miniquake.render.gl11` (texcoord2).
/// @param s The s input consumed by `texcoord2`.
/// @param t The t input consumed by `texcoord2`.
function texcoord2(s, t)
  if diagnosticTraceEnabled and traceCommand("texcoord", [s, t]) then return void end if
  native.glTexcoord2(bits(s), bits(t))
end function

/// Implements the `color` operation for `miniquake.render.gl11` (color).
/// @param red The red input consumed by `color`.
/// @param green The green input consumed by `color`.
/// @param blue The blue input consumed by `color`.
/// @param alpha The alpha input consumed by `color`.
function color(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("color", [red / 255.0, green / 255.0, blue / 255.0, alpha / 255.0]) then return void end if
  native.glColor4ub(red, green, blue, alpha)
end function

/// Implements the `colorFloat` operation for `miniquake.render.gl11` (color float).
/// @param red The red input consumed by `colorFloat`.
/// @param green The green input consumed by `colorFloat`.
/// @param blue The blue input consumed by `colorFloat`.
/// @param alpha The alpha input consumed by `colorFloat`.
function colorFloat(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("color", [red, green, blue, alpha]) then return void end if
  native.glColor4ub(
    native.trunc(red * 255.0),
    native.trunc(green * 255.0),
    native.trunc(blue * 255.0),
    native.trunc(alpha * 255.0),
  )
end function

/// Update module state for color.
/// @param red The red input consumed by `clearColor`.
/// @param green The green input consumed by `clearColor`.
/// @param blue The blue input consumed by `clearColor`.
/// @param alpha The alpha input consumed by `clearColor`.
function clearColor(red, green, blue, alpha)
  if diagnosticTraceEnabled and traceCommand("clear_color", [bits(red), bits(green), bits(blue), bits(alpha)]) then return void end if
  native.glClearColor(bits(red), bits(green), bits(blue), bits(alpha))
end function

/// Implements the `clear` operation for `miniquake.render.gl11` (clear).
/// @param mask The mask input consumed by `clear`.
function clear(mask)
  if diagnosticTraceEnabled and traceCommand("clear", [mask]) then return void end if
  native.glClear(mask)
end function

/// Implements the `enable` operation for `miniquake.render.gl11` (enable).
/// @param capability The capability input consumed by `enable`.
function enable(capability)
  if diagnosticTraceEnabled and traceCommand("enable", [capability]) then return void end if
  native.glEnable(capability)
end function

/// Implements the `disable` operation for `miniquake.render.gl11` (disable).
/// @param capability The capability input consumed by `disable`.
function disable(capability)
  if diagnosticTraceEnabled and traceCommand("disable", [capability]) then return void end if
  native.glDisable(capability)
end function

/// Implements the `blendFunc` operation for `miniquake.render.gl11` (blend func).
/// @param source Source value or collection to read.
/// @param destination Destination value or collection to update.
function blendFunc(source, destination)
  if diagnosticTraceEnabled and traceCommand("blend_function", [source, destination]) then return void end if
  native.glBlendFunc(source, destination)
end function

/// Implements the `depthFunc` operation for `miniquake.render.gl11` (depth func).
/// @param value Value consumed by `depthFunc`.
function depthFunc(value)
  if diagnosticTraceEnabled and traceCommand("depth_func", [value]) then return void end if
  native.glDepthFunc(value)
end function

/// Implements the `depthMask` operation for `miniquake.render.gl11` (depth mask).
/// @param enabled Whether the optional behavior is enabled.
function depthMask(enabled)
  if diagnosticTraceEnabled and enabled and traceCommand("depth_mask", [1]) then return void end if
  if diagnosticTraceEnabled and not enabled and traceCommand("depth_mask", [0]) then return void end if
  if enabled then native.glDepthMask(1) else native.glDepthMask(0) end if
end function

/// Implements the `depthRange` operation for `miniquake.render.gl11` (depth range).
/// @param nearValue The near value input consumed by `depthRange`.
/// @param farValue The far value input consumed by `depthRange`.
function depthRange(nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("depth_range", [bits(nearValue), bits(farValue)]) then return void end if
  native.glDepthRange(bits(nearValue), bits(farValue))
end function

/// Implements the `viewport` operation for `miniquake.render.gl11` (viewport).
/// @param x The x input consumed by `viewport`.
/// @param y The y input consumed by `viewport`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function viewport(x, y, width, height)
  if diagnosticTraceEnabled and traceCommand("viewport", [x, y, width, height]) then return void end if
  native.glViewport(x, y, width, height)
end function

/// Return matrix mode derived from the active module state.
/// @param mode The mode input consumed by `matrixMode`.
function matrixMode(mode)
  if diagnosticTraceEnabled and traceCommand("matrix_mode", [mode]) then return void end if
  native.glMatrixMode(mode)
end function

// Read and validate identity.
function loadIdentity()
  if diagnosticTraceEnabled and traceCommand("load_identity", []) then return void end if
  native.glLoadIdentity()
end function

// Add state for push matrix.
function pushMatrix()
  if diagnosticTraceEnabled and traceCommand("push_matrix", []) then return void end if
  native.glPushMatrix()
end function

// Consume pending state for pop matrix.
function popMatrix()
  if diagnosticTraceEnabled and traceCommand("pop_matrix", []) then return void end if
  native.glPopMatrix()
end function

/// Implements the `translate` operation for `miniquake.render.gl11` (translate).
/// @param x The x input consumed by `translate`.
/// @param y The y input consumed by `translate`.
/// @param z The z input consumed by `translate`.
function translate(x, y, z)
  if diagnosticTraceEnabled and traceCommand("translate", [x, y, z]) then return void end if
  native.glTranslate(bits(x), bits(y), bits(z))
end function

/// Implements the `rotate` operation for `miniquake.render.gl11` (rotate).
/// @param angle The angle input consumed by `rotate`.
/// @param x The x input consumed by `rotate`.
/// @param y The y input consumed by `rotate`.
/// @param z The z input consumed by `rotate`.
function rotate(angle, x, y, z)
  if diagnosticTraceEnabled and traceCommand("rotate", [angle, x, y, z]) then return void end if
  native.glRotate(bits(angle), bits(x), bits(y), bits(z))
end function

/// Implements the `scale` operation for `miniquake.render.gl11` (scale).
/// @param x The x input consumed by `scale`.
/// @param y The y input consumed by `scale`.
/// @param z The z input consumed by `scale`.
function scale(x, y, z)
  native.glScale(bits(x), bits(y), bits(z))
end function

/// Implements the `ortho` operation for `miniquake.render.gl11` (ortho).
/// @param left The left input consumed by `ortho`.
/// @param right The right input consumed by `ortho`.
/// @param bottom The bottom input consumed by `ortho`.
/// @param top The top input consumed by `ortho`.
/// @param nearValue The near value input consumed by `ortho`.
/// @param farValue The far value input consumed by `ortho`.
function ortho(left, right, bottom, top, nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("ortho", [left, right, bottom, top, nearValue, farValue]) then return void end if
  native.glOrtho(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

/// Implements the `frustum` operation for `miniquake.render.gl11` (frustum).
/// @param left The left input consumed by `frustum`.
/// @param right The right input consumed by `frustum`.
/// @param bottom The bottom input consumed by `frustum`.
/// @param top The top input consumed by `frustum`.
/// @param nearValue The near value input consumed by `frustum`.
/// @param farValue The far value input consumed by `frustum`.
function frustum(left, right, bottom, top, nearValue, farValue)
  if diagnosticTraceEnabled and traceCommand("frustum", [left, right, bottom, top, nearValue, farValue]) then return void end if
  native.glFrustum(bits(left), bits(right), bits(bottom), bits(top), bits(nearValue), bits(farValue))
end function

/// Return polygon mode derived from the active module state.
/// @param face The face input consumed by `polygonMode`.
/// @param mode The mode input consumed by `polygonMode`.
function polygonMode(face, mode)
  native.glPolygonMode(face, mode)
end function

/// Implements the `shadeModel` operation for `miniquake.render.gl11` (shade model).
/// @param mode The mode input consumed by `shadeModel`.
function shadeModel(mode)
  if diagnosticTraceEnabled and traceCommand("shade_model", [mode]) then return void end if
  native.glShadeModel(mode)
end function

/// Return string.
/// @param name Stable name that identifies the requested object or option.
function getString(name)
  value = native.glGetString(name)
  if value is void then return "" end if
  return value
end function

// Report code and return the corresponding failure status.
function errorCode()
  return native.glGetError()
end function

/// Implements the `flush` operation for `miniquake.render.gl11` (flush).
function flush()
  native.glFlush()
end function

/// Defines the gl zero value used by `miniquake.render.gl11`.
const GL_ZERO = 0
/// Defines the gl one value used by `miniquake.render.gl11`.
const GL_ONE = 1
/// Defines the gl src color value used by `miniquake.render.gl11`.
const GL_SRC_COLOR = 0x0300
/// Defines the gl one minus src color value used by `miniquake.render.gl11`.
const GL_ONE_MINUS_SRC_COLOR = 0x0301
/// Defines the gl dst color value used by `miniquake.render.gl11`.
const GL_DST_COLOR = 0x0306
/// Defines the gl one minus dst color value used by `miniquake.render.gl11`.
const GL_ONE_MINUS_DST_COLOR = 0x0307
/// Defines the gl alpha test value used by `miniquake.render.gl11`.
const GL_ALPHA_TEST = 0x0BC0
/// Defines the gl greater value used by `miniquake.render.gl11`.
const GL_GREATER = 0x0204
/// Defines the gl back value used by `miniquake.render.gl11`.
const GL_BACK = 0x0405
/// Defines the gl color index value used by `miniquake.render.gl11`.
const GL_COLOR_INDEX = 0x1900
/// Defines the gl color index8 ext value used by `miniquake.render.gl11`.
const GL_COLOR_INDEX8_EXT = 0x80E5
/// Defines the gl texture0 sgis value used by `miniquake.render.gl11`.
const GL_TEXTURE0_SGIS = 0x835E
/// Defines the gl texture1 sgis value used by `miniquake.render.gl11`.
const GL_TEXTURE1_SGIS = 0x835F
/// Defines the gl luminance value used by `miniquake.render.gl11`.
const GL_LUMINANCE = 0x1909
/// Defines the gl texture wrap s value used by `miniquake.render.gl11`.
const GL_TEXTURE_WRAP_S = 0x2802
/// Defines the gl texture wrap t value used by `miniquake.render.gl11`.
const GL_TEXTURE_WRAP_T = 0x2803
/// Defines the gl texture max anisotropy ext value used by `miniquake.render.gl11`.
const GL_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE
/// Defines the gl repeat value used by `miniquake.render.gl11`.
const GL_REPEAT = 0x2901
/// Defines the gl clamp value used by `miniquake.render.gl11`.
const GL_CLAMP = 0x2900
/// Defines the gl texture env value used by `miniquake.render.gl11`.
const GL_TEXTURE_ENV = 0x2300
/// Defines the gl texture env mode value used by `miniquake.render.gl11`.
const GL_TEXTURE_ENV_MODE = 0x2200
/// Defines the gl texture value used by `miniquake.render.gl11`.
const GL_TEXTURE = 0x1702
/// Defines the gl combine value used by `miniquake.render.gl11`.
const GL_COMBINE = 0x8570
/// Defines the gl combine rgb value used by `miniquake.render.gl11`.
const GL_COMBINE_RGB = 0x8571
/// Defines the gl source0 rgb value used by `miniquake.render.gl11`.
const GL_SOURCE0_RGB = 0x8580
/// Defines the gl source1 rgb value used by `miniquake.render.gl11`.
const GL_SOURCE1_RGB = 0x8581
/// Defines the gl operand0 rgb value used by `miniquake.render.gl11`.
const GL_OPERAND0_RGB = 0x8590
/// Defines the gl operand1 rgb value used by `miniquake.render.gl11`.
const GL_OPERAND1_RGB = 0x8591
/// Defines the gl previous value used by `miniquake.render.gl11`.
const GL_PREVIOUS = 0x8578
/// Defines the gl replace value used by `miniquake.render.gl11`.
const GL_REPLACE = 0x1E01
/// Defines the gl modulate value used by `miniquake.render.gl11`.
const GL_MODULATE = 0x2100

// Native enhanced-lighting draw classifications.  The classic path always
// uses NONE; the optional renderer uses OVERLAY only for its additive 3-D
// light pass, so console/HUD/menu rendering cannot inherit a shader.
const ENHANCED_DRAW_NONE = 0
/// Defines the enhanced draw overlay value used by `miniquake.render.gl11`.
const ENHANCED_DRAW_OVERLAY = 1

/// Implements the `alphaFunc` operation for `miniquake.render.gl11` (alpha func).
/// @param functionName Name that identifies the requested value or resource.
/// @param reference The reference input consumed by `alphaFunc`.
function alphaFunc(functionName, reference)
  native.glAlphaFunc(functionName, bits(reference))
end function

/// Implements the `cullFace` operation for `miniquake.render.gl11` (cull face).
/// @param mode The mode input consumed by `cullFace`.
function cullFace(mode)
  if diagnosticTraceEnabled and traceCommand("cull_face", [mode]) then return void end if
  native.glCullFace(mode)
end function

/// Implements the `bindTexture` operation for `miniquake.render.gl11` (bind texture).
/// @param texture Texture resource processed by the operation.
function bindTexture(texture)
  global boundTextureName
  if texture == boundTextureName then return void end if
  boundTextureName = texture
  if diagnosticTraceEnabled and traceCommand("bind_texture", [GL_TEXTURE_2D, texture]) then return void end if
  native.glBindTexture(GL_TEXTURE_2D, texture)
end function

/// Implements the `generateTexture` operation for `miniquake.render.gl11` (generate texture).
function generateTexture()
  return reserveTextureNames(1)
end function

/// Release or remove state for texture.
/// @param texture Texture resource processed by the operation.
function deleteTexture(texture)
  global boundTextureName
  ids = bytes(4)
  ids[0] = texture & 255
  ids[1] = (texture >> 8) & 255
  ids[2] = (texture >> 16) & 255
  ids[3] = (texture >> 24) & 255
  native.glDeleteTextures(1, ids)
  if boundTextureName == texture then boundTextureName = -1 end if
end function

/// Implements the `textureParameter` operation for `miniquake.render.gl11` (texture parameter).
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `textureParameter`.
function textureParameter(name, value)
  if diagnosticTraceEnabled and traceCommand("texture_parameter", [GL_TEXTURE_2D, name, value]) then return void end if
  native.glTexParameterI(GL_TEXTURE_2D, name, value)
end function

/// Implements the `textureEnvironment` operation for `miniquake.render.gl11` (texture environment).
/// @param mode The mode input consumed by `textureEnvironment`.
function textureEnvironment(mode)
  if diagnosticTraceEnabled and traceCommand("texture_environment", [GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode]) then return void end if
  native.glTexEnvI(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode)
end function

/// Implements the `textureEnvironmentParameter` operation for `miniquake.render.gl11` (texture environment parameter).
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `textureEnvironmentParameter`.
function textureEnvironmentParameter(name, value)
  native.glTexEnvI(GL_TEXTURE_ENV, name, value)
end function

/// Upload rgba to the active renderer.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadRgba`.
function uploadRgba(width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_rgba", [0, GL_RGBA, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload rgba level to the active renderer.
/// @param level The level input consumed by `uploadRgbaLevel`.
/// @param internalFormat The internal format input consumed by `uploadRgbaLevel`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadRgbaLevel`.
function uploadRgbaLevel(level, internalFormat, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_rgba", [level, internalFormat, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, level, internalFormat, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload indexed level to the active renderer.
/// @param level The level input consumed by `uploadIndexedLevel`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadIndexedLevel`.
function uploadIndexedLevel(level, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_indexed", [level, width, height, pixels]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, level, GL_COLOR_INDEX8_EXT, width, height, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload rgb to the active renderer.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadRgb`.
function uploadRgb(width, height, pixels)
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload luminance to the active renderer.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadLuminance`.
function uploadLuminance(width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_luminance", [width, height]) then return void end if
  native.glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload luminance sub image to the active renderer.
/// @param x The x input consumed by `uploadLuminanceSubImage`.
/// @param y The y input consumed by `uploadLuminanceSubImage`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadLuminanceSubImage`.
function uploadLuminanceSubImage(x, y, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_luminance_subimage", [x, y, width, height]) then return void end if
  native.glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels)
end function

/// Upload an rgba rectangle into an existing texture. Colored lightmap pages
/// use this path while the original scalar atlas keeps its luminance command.
/// @param x The x input consumed by `uploadRgbaSubImage`.
/// @param y The y input consumed by `uploadRgbaSubImage`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param pixels The pixels input consumed by `uploadRgbaSubImage`.
function uploadRgbaSubImage(x, y, width, height, pixels)
  if diagnosticTraceEnabled and traceCommand("upload_rgba_subimage", [x, y, width, height]) then return void end if
  native.glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
end function

/// Read and validate pixels rgba.
/// @param x The x input consumed by `readPixelsRgba`.
/// @param y The y input consumed by `readPixelsRgba`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
function readPixelsRgba(x, y, width, height)
  if width < 1 or height < 1 then return bytes() end if
  pixels = bytes(width * height * 4)
  native.glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels)
  return pixels
end function

// Finalize state for finish.
function finish()
  if diagnosticTraceEnabled and traceCommand("finish", []) then return void end if
  native.glFinish()
end function

/// Render buffer.
/// @param mode The mode input consumed by `drawBuffer`.
function drawBuffer(mode)
  if diagnosticTraceEnabled and traceCommand("draw_buffer", [mode]) then return void end if
  native.glDrawBuffer(mode)
end function

// Report whether multitexture available holds for the active state.
function multitextureAvailable()
  return native.glMultitextureAvailable() != 0
end function

// Report whether world program available holds for the active state.
function worldProgramAvailable()
  return native.glWorldProgramAvailable() != 0
end function

/// Implements the `worldProgramEnable` operation for `miniquake.render.gl11` (world program enable).
/// @param enabled Whether the optional behavior is enabled.
function worldProgramEnable(enabled)
  value = 0
  if enabled then value = 1 end if
  native.glWorldProgramEnable(value)
end function

// Report whether the active backend can execute the optional per-pixel light
// pass.  Availability is capability based and is deliberately independent of
// the selected Classic/Enhanced user setting.
function enhancedAvailable()
  return native.glEnhancedAvailable() != 0
end function

/// Configure optional enhanced rendering without changing the selected native
/// backend.  Classic remains a zero-cost path when enabled is false.
/// @param enabled Whether the optional behavior is enabled.
/// @param shadows The shadows input consumed by `enhancedConfigure`.
/// @param shadowQuality The shadow quality input consumed by `enhancedConfigure`.
function enhancedConfigure(enabled, shadows, shadowQuality)
  enabledValue = 0
  shadowsValue = 0
  if enabled then enabledValue = 1 end if
  if shadows then shadowsValue = 1 end if
  return native.glEnhancedConfigure(enabledValue, shadowsValue, shadowQuality) != 0
end function

/// Upload the compact world-space dynamic-light packet for the current view.
/// @param lightPacket The light packet input consumed by `enhancedBeginFrame`.
/// @param byteCount Number of entries or units to process.
function enhancedBeginFrame(lightPacket, byteCount)
  return native.glEnhancedBeginFrame(lightPacket, byteCount) != 0
end function

/// Select which following geometry is part of the enhanced additive pass.
/// @param kind The kind input consumed by `enhancedDrawKind`.
function enhancedDrawKind(kind)
  native.glEnhancedDrawKind(kind)
end function

// End enhanced 3-D rendering and force the compatibility program/state back.
function enhancedEndFrame()
  native.glEnhancedEndFrame()
end function

/// Report whether active texture holds for the active state.
/// @param unit The unit input consumed by `activeTexture`.
function activeTexture(unit)
  native.glActiveTexture(unit)
end function

/// Implements the `multiTexCoord2` operation for `miniquake.render.gl11` (multi tex coord2).
/// @param unit The unit input consumed by `multiTexCoord2`.
/// @param s The s input consumed by `multiTexCoord2`.
/// @param t The t input consumed by `multiTexCoord2`.
function multiTexCoord2(unit, s, t)
  native.glMultiTexCoord2(unit, bits(s), bits(t))
end function

/// Implements the `staticGeometryCall` operation for `miniquake.render.gl11` (static geometry call).
/// @param objectValue The object value input consumed by `staticGeometryCall`.
/// @param passId Stable identifier of the requested entry.
function staticGeometryCall(objectValue, passId)
  return native.glStaticGeometryCall(nativeRawValue(objectValue), passId) != 0
end function

/// Implements the `staticGeometryCallBatch` operation for `miniquake.render.gl11` (static geometry call batch).
/// @param keys The keys input consumed by `staticGeometryCallBatch`.
/// @param passId Stable identifier of the requested entry.
function staticGeometryCallBatch(keys, passId)
  return native.glStaticGeometryCallBatch(keys, len(keys), passId) > 0
end function

/// Draw only the populated key prefix of a reusable static-geometry buffer.
/// @param keys The keys input consumed by `staticGeometryCallBatchCount`.
/// @param keyCount Number of entries or units to process.
/// @param passId Stable identifier of the requested entry.
function staticGeometryCallBatchCount(keys, keyCount, passId)
  if keyCount <= 0 then return false end if
  return native.glStaticGeometryCallBatch(keys, keyCount * 8, passId) > 0
end function

/// Implements the `staticGeometryCallMultitextureBatch` operation for `miniquake.render.gl11` (static geometry call multitexture batch).
/// @param records The records input consumed by `staticGeometryCallMultitextureBatch`.
function staticGeometryCallMultitextureBatch(records)
  return native.glStaticGeometryCallMultitextureBatch(records, len(records)) > 0
end function

/// Draw only the populated prefix of a reusable multitexture record buffer.
/// @param records The records input consumed by `staticGeometryCallMultitextureBatchCount`.
/// @param recordCount Number of entries or units to process.
function staticGeometryCallMultitextureBatchCount(records, recordCount)
  if recordCount <= 0 then return false end if
  return native.glStaticGeometryCallMultitextureBatch(records, recordCount * 16) > 0
end function

/// Implements the `staticGeometryPrepare` operation for `miniquake.render.gl11` (static geometry prepare).
/// @param objectValue The object value input consumed by `staticGeometryPrepare`.
/// @param passId Stable identifier of the requested entry.
function staticGeometryPrepare(objectValue, passId)
  return native.glStaticGeometryPrepare(nativeRawValue(objectValue), passId)
end function

// Update module state for static geometry cache.
function clearStaticGeometryCache()
  native.glStaticGeometryClear()
end function
