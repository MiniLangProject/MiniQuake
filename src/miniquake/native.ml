package miniquake.native

extern function f32FromText(text as cstr) from "miniquake_native.dll" symbol "mq_f32_from_text" returns u32
extern function f32FromRaw(rawValue as u64) from "miniquake_native.dll" symbol "mq_f32_from_ml_raw" returns u32
extern function f32ToRaw(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_ml_raw" returns u64
extern function f32ToText(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_text" returns cstr
extern function f32Sin(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sin" returns u32
extern function f32Cos(bits as u32) from "miniquake_native.dll" symbol "mq_f32_cos" returns u32
extern function f32Sqrt(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sqrt" returns u32
extern function f32Atan2(yBits as u32, xBits as u32) from "miniquake_native.dll" symbol "mq_f32_atan2" returns u32
extern function f32ToI32Trunc(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_i32_trunc" returns i32
extern function i32ToF32(value as i32) from "miniquake_native.dll" symbol "mq_i32_to_f32" returns u32
extern function asciiCode(text as cstr) from "miniquake_native.dll" symbol "mq_ascii_code" returns i32
extern function asciiChar(value as i32) from "miniquake_native.dll" symbol "mq_ascii_char" returns cstr

extern function winCreate(title as wstr, width as i32, height as i32, fullscreen as i32) from "miniquake_native.dll" symbol "mq_win_create" returns ptr
extern function winDestroy() from "miniquake_native.dll" symbol "mq_win_destroy" returns void
extern function winPoll() from "miniquake_native.dll" symbol "mq_win_poll" returns i32
extern function winSwap() from "miniquake_native.dll" symbol "mq_win_swap" returns void
extern function winKeyDown(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_down" returns i32
extern function winKeyPressed(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_pressed" returns i32
extern function winTextPop() from "miniquake_native.dll" symbol "mq_win_text_pop" returns i32
extern function winHasFocus() from "miniquake_native.dll" symbol "mq_win_has_focus" returns i32
extern function winClientWidth() from "miniquake_native.dll" symbol "mq_win_client_width" returns i32
extern function winClientHeight() from "miniquake_native.dll" symbol "mq_win_client_height" returns i32
extern function winSetTitle(title as wstr) from "miniquake_native.dll" symbol "mq_win_set_title" returns void
extern function winSetCursorCapture(enabled as i32) from "miniquake_native.dll" symbol "mq_win_set_cursor_capture" returns void
extern function winMouseDx() from "miniquake_native.dll" symbol "mq_win_mouse_dx" returns i32
extern function winMouseDy() from "miniquake_native.dll" symbol "mq_win_mouse_dy" returns i32
extern function winMouseButtons() from "miniquake_native.dll" symbol "mq_win_mouse_buttons" returns i32
extern function winMouseWheel() from "miniquake_native.dll" symbol "mq_win_mouse_wheel" returns i32
extern function winTicks() from "miniquake_native.dll" symbol "mq_win_ticks" returns u32
extern function winSleep(milliseconds as u32) from "miniquake_native.dll" symbol "mq_win_sleep" returns void

extern function audioOpen(sampleRate as u32, channels as u32, bitsPerSample as u32) from "miniquake_native.dll" symbol "mq_audio_open" returns i32
extern function audioSubmit(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_audio_submit" returns i32
extern function audioClose() from "miniquake_native.dll" symbol "mq_audio_close" returns void
extern function audioQueued() from "miniquake_native.dll" symbol "mq_audio_queued" returns u32

extern function udpOpen(port as u32) from "miniquake_native.dll" symbol "mq_udp_open" returns u64
extern function udpClose(handle as u64) from "miniquake_native.dll" symbol "mq_udp_close" returns void
extern function udpBoundPort(handle as u64) from "miniquake_native.dll" symbol "mq_udp_bound_port" returns u32
extern function udpSend(handle as u64, address as cstr, port as u32, data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_udp_send" returns i32
extern function udpReceive(handle as u64, data as bytes, capacity as u32) from "miniquake_native.dll" symbol "mq_udp_receive" returns i32
extern function udpLastAddress() from "miniquake_native.dll" symbol "mq_udp_last_address" returns cstr
extern function udpLastPort() from "miniquake_native.dll" symbol "mq_udp_last_port" returns u32
extern function udpLastError() from "miniquake_native.dll" symbol "mq_udp_last_error" returns i32

extern function glBegin(mode as u32) from "miniquake_native.dll" symbol "mq_gl_begin" returns void
extern function glEnd() from "miniquake_native.dll" symbol "mq_gl_end" returns void
extern function glVertex2(xBits as u32, yBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex2" returns void
extern function glVertex3(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex3" returns void
extern function glTexcoord2(sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_texcoord2" returns void
extern function glColor4ub(red as u32, green as u32, blue as u32, alpha as u32) from "miniquake_native.dll" symbol "mq_gl_color4ub" returns void
extern function glClearColor(redBits as u32, greenBits as u32, blueBits as u32, alphaBits as u32) from "miniquake_native.dll" symbol "mq_gl_clear_color" returns void
extern function glClear(mask as u32) from "miniquake_native.dll" symbol "mq_gl_clear" returns void
extern function glEnable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_enable" returns void
extern function glDisable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_disable" returns void
extern function glBlendFunc(source as u32, destination as u32) from "miniquake_native.dll" symbol "mq_gl_blend_func" returns void
extern function glDepthFunc(functionName as u32) from "miniquake_native.dll" symbol "mq_gl_depth_func" returns void
extern function glDepthMask(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_depth_mask" returns void
extern function glDepthRange(nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_depth_range" returns void
extern function glAlphaFunc(functionName as u32, referenceBits as u32) from "miniquake_native.dll" symbol "mq_gl_alpha_func" returns void
extern function glCullFace(mode as u32) from "miniquake_native.dll" symbol "mq_gl_cull_face" returns void
extern function glShadeModel(mode as u32) from "miniquake_native.dll" symbol "mq_gl_shade_model" returns void
extern function glPolygonMode(face as u32, mode as u32) from "miniquake_native.dll" symbol "mq_gl_polygon_mode" returns void
extern function glViewport(x as i32, y as i32, width as i32, height as i32) from "miniquake_native.dll" symbol "mq_gl_viewport" returns void
extern function glMatrixMode(mode as u32) from "miniquake_native.dll" symbol "mq_gl_matrix_mode" returns void
extern function glLoadIdentity() from "miniquake_native.dll" symbol "mq_gl_load_identity" returns void
extern function glPushMatrix() from "miniquake_native.dll" symbol "mq_gl_push_matrix" returns void
extern function glPopMatrix() from "miniquake_native.dll" symbol "mq_gl_pop_matrix" returns void
extern function glTranslate(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_translate" returns void
extern function glRotate(angleBits as u32, xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_rotate" returns void
extern function glScale(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_scale" returns void
extern function glOrtho(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_ortho" returns void
extern function glFrustum(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_frustum" returns void
extern function glBindTexture(target as u32, texture as u32) from "miniquake_native.dll" symbol "mq_gl_bind_texture" returns void
extern function glGenTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_gen_textures" returns void
extern function glDeleteTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_delete_textures" returns void
extern function glTexParameterI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_parameter_i" returns void
extern function glTexImage2D(target as u32, level as i32, internalFormat as i32, width as i32, height as i32, border as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_image_2d" returns void
extern function glTexSubImage2D(target as u32, level as i32, xOffset as i32, yOffset as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_sub_image_2d" returns void
extern function glReadPixels(x as i32, y as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_read_pixels" returns void
extern function glGetString(name as u32) from "miniquake_native.dll" symbol "mq_gl_get_string" returns cstr
extern function glGetError() from "miniquake_native.dll" symbol "mq_gl_get_error" returns u32
extern function glFinish() from "miniquake_native.dll" symbol "mq_gl_finish" returns void
extern function glFlush() from "miniquake_native.dll" symbol "mq_gl_flush" returns void

function floatBits(value)
  // Avoid number -> text -> strtod.  MiniLang exposes the exact tagged word via
  // nativeRawValue(), and the bridge understands both immediate f32 and boxed
  // f64 numeric values.
  return f32FromRaw(nativeRawValue(value))
end function

function bitsFloat(bits)
  // Every IEEE-754 binary32 value has MiniLang's compact immediate-float form.
  // Return that raw word and let nativeValueFromRaw() restore the real value.
  return nativeValueFromRaw(f32ToRaw(bits))
end function

function trunc(value)
  // MiniLang integers are already exact integral values.  Sending them through
  // IEEE-754 binary32 first would round masks and counters above 2^24 (for
  // example 0x12345678 becomes 0x12345680).  Only floating-point values need
  // the native Quake-style truncation path.
  if value is int then return value end if
  return f32ToI32Trunc(floatBits(value))
end function

function sin(value)
  return bitsFloat(f32Sin(floatBits(value)))
end function

function cos(value)
  return bitsFloat(f32Cos(floatBits(value)))
end function

function sqrt(value)
  return bitsFloat(f32Sqrt(floatBits(value)))
end function

function atan2(y, x)
  return bitsFloat(f32Atan2(floatBits(y), floatBits(x)))
end function
