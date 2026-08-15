/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.native.
*/
package miniquake.native

extern function f32FromText(text as cstr) from "miniquake_native.dll" symbol "mq_f32_from_text" returns u32
extern function f32FromRaw(rawValue as u64) from "miniquake_native.dll" symbol "mq_f32_from_ml_raw" returns u32
extern function f32ToRaw(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_ml_raw" returns u64
extern function f32ToTextRaw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_text" returns u32
extern function f32ToFixed6Raw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_fixed6" returns u32
extern function f32Sin(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sin" returns u32
extern function f32Cos(bits as u32) from "miniquake_native.dll" symbol "mq_f32_cos" returns u32
extern function f32Sqrt(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sqrt" returns u32
extern function f32Atan2(yBits as u32, xBits as u32) from "miniquake_native.dll" symbol "mq_f32_atan2" returns u32
extern function f32ToI32Trunc(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_i32_trunc" returns i32
extern function i32ToF32(value as i32) from "miniquake_native.dll" symbol "mq_i32_to_f32" returns u32
extern function asciiCode(text as cstr) from "miniquake_native.dll" symbol "mq_ascii_code" returns i32
extern function asciiCharRaw(value as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_ascii_char" returns u32

extern function renderSelect(backend as i32) from "miniquake_native.dll" symbol "mq_render_select" returns i32
extern function renderBackend() from "miniquake_native.dll" symbol "mq_render_backend" returns i32
extern function renderAvailable(backend as i32) from "miniquake_native.dll" symbol "mq_render_available" returns i32

extern function winCreate(title as wstr, width as i32, height as i32, fullscreen as i32) from "miniquake_native.dll" symbol "mq_win_create" returns ptr
extern function winDestroy() from "miniquake_native.dll" symbol "mq_win_destroy" returns void
extern function winPoll() from "miniquake_native.dll" symbol "mq_win_poll" returns i32
extern function winSwap() from "miniquake_native.dll" symbol "mq_win_swap" returns void
extern function winKeyDown(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_down" returns i32
extern function winKeyPressed(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_pressed" returns i32
extern function winKeySnapshot(downStates as bytes, pressedStates as bytes, queryMask as bytes, stateCount as u32) from "miniquake_native.dll" symbol "mq_win_key_snapshot" returns i32
extern function winTextPop() from "miniquake_native.dll" symbol "mq_win_text_pop" returns i32
extern function winHasFocus() from "miniquake_native.dll" symbol "mq_win_has_focus" returns i32
extern function winClientWidth() from "miniquake_native.dll" symbol "mq_win_client_width" returns i32
extern function winClientHeight() from "miniquake_native.dll" symbol "mq_win_client_height" returns i32
extern function winResizeClient(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_win_resize_client" returns i32
extern function winWindowX() from "miniquake_native.dll" symbol "mq_win_window_x" returns i32
extern function winWindowY() from "miniquake_native.dll" symbol "mq_win_window_y" returns i32
extern function winIsMinimized() from "miniquake_native.dll" symbol "mq_win_is_minimized" returns i32
extern function winDesktopWidth() from "miniquake_native.dll" symbol "mq_win_desktop_width" returns i32
extern function winDesktopHeight() from "miniquake_native.dll" symbol "mq_win_desktop_height" returns i32
extern function winDisplayModeCount() from "miniquake_native.dll" symbol "mq_win_display_mode_count" returns u32
extern function winDisplayModeWidth(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_width" returns i32
extern function winDisplayModeHeight(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_height" returns i32
extern function winDisplayModeBpp(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_bpp" returns i32
extern function winDisplayModeFrequency(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_frequency" returns i32
extern function winTestDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32) from "miniquake_native.dll" symbol "mq_win_test_display_mode" returns i32
extern function winConfigureDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32, fullscreen as i32, useCurrent as i32) from "miniquake_native.dll" symbol "mq_win_configure_display_mode" returns i32
extern function winRestoreDisplayMode() from "miniquake_native.dll" symbol "mq_win_restore_display_mode" returns void
extern function winGetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_get_gamma_ramp" returns i32
extern function winSetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_set_gamma_ramp" returns i32
extern function winContextReady() from "miniquake_native.dll" symbol "mq_win_context_ready" returns i32
extern function winMakeCurrent() from "miniquake_native.dll" symbol "mq_win_make_current" returns i32
extern function winActivate(active as i32, minimized as i32) from "miniquake_native.dll" symbol "mq_win_activate" returns void
extern function winSetTitle(title as wstr) from "miniquake_native.dll" symbol "mq_win_set_title" returns void
extern function winSetCursorCapture(enabled as i32) from "miniquake_native.dll" symbol "mq_win_set_cursor_capture" returns void
extern function winMouseDx() from "miniquake_native.dll" symbol "mq_win_mouse_dx" returns i32
extern function winMouseDy() from "miniquake_native.dll" symbol "mq_win_mouse_dy" returns i32
extern function winMouseButtons() from "miniquake_native.dll" symbol "mq_win_mouse_buttons" returns i32
extern function winMouseWheel() from "miniquake_native.dll" symbol "mq_win_mouse_wheel" returns i32
extern function winInputEventPop() from "miniquake_native.dll" symbol "mq_win_input_event_pop" returns u32
extern function winInputTestPush(eventType as u32, code as u32, value as i32) from "miniquake_native.dll" symbol "mq_win_input_test_push" returns void
extern function winCursorShow(show as i32) from "miniquake_native.dll" symbol "mq_win_cursor_show" returns void
extern function winCursorCenter() from "miniquake_native.dll" symbol "mq_win_cursor_center" returns i32
extern function winUpdateClipCursor() from "miniquake_native.dll" symbol "mq_win_update_clip_cursor" returns i32
extern function winJoyStartup() from "miniquake_native.dll" symbol "mq_win_joy_startup" returns i32
extern function winJoyRead() from "miniquake_native.dll" symbol "mq_win_joy_read" returns i32
extern function winJoyAxis(axis as u32) from "miniquake_native.dll" symbol "mq_win_joy_axis" returns u32
extern function winJoyButtons() from "miniquake_native.dll" symbol "mq_win_joy_buttons" returns u32
extern function winJoyPov() from "miniquake_native.dll" symbol "mq_win_joy_pov" returns u32
extern function winJoyButtonCount() from "miniquake_native.dll" symbol "mq_win_joy_button_count" returns u32
extern function winJoyHasPov() from "miniquake_native.dll" symbol "mq_win_joy_has_pov" returns i32
extern function winJoyWarriorCurve(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve" returns i32
extern function winJoyWarriorCurveF32(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve_f32" returns u32
extern function winTicks() from "miniquake_native.dll" symbol "mq_win_ticks" returns u32
extern function winSleep(milliseconds as u32) from "miniquake_native.dll" symbol "mq_win_sleep" returns void

extern function sysCounter() from "miniquake_native.dll" symbol "mq_sys_counter" returns u64
extern function sysFrequency() from "miniquake_native.dll" symbol "mq_sys_frequency" returns u64
extern function processHandleCount() from "miniquake_native.dll" symbol "mq_process_handle_count" returns u32
extern function sysMakeCodeWriteable(address as u64, length as u64) from "miniquake_native.dll" symbol "mq_sys_make_code_writeable" returns i32
extern function sysConsoleAlloc() from "miniquake_native.dll" symbol "mq_sys_console_alloc" returns i32
extern function sysConsoleFree() from "miniquake_native.dll" symbol "mq_sys_console_free" returns i32
extern function sysConsoleEventPop() from "miniquake_native.dll" symbol "mq_sys_console_event_pop" returns u32
extern function sysConsoleWrite(text as cstr) from "miniquake_native.dll" symbol "mq_sys_console_write" returns i32
extern function sysSleepUntilInput(milliseconds as u32) from "miniquake_native.dll" symbol "mq_sys_sleep_until_input" returns void

extern function conprocCreateEvent() from "miniquake_native.dll" symbol "mq_conproc_create_event" returns u64
extern function conprocSetEvent(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_set_event" returns i32
extern function conprocCloseHandle(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_close_handle" returns void
extern function conprocWaitAny(first as u64, second as u64, milliseconds as u32) from "miniquake_native.dll" symbol "mq_conproc_wait_any" returns i32
extern function conprocMap(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_map" returns ptr
extern function conprocUnmap(mapped as ptr) from "miniquake_native.dll" symbol "mq_conproc_unmap" returns i32
extern function conprocReadI32(mapped as ptr, index as u32) from "miniquake_native.dll" symbol "mq_conproc_read_i32" returns i32
extern function conprocWriteI32(mapped as ptr, index as u32, value as i32) from "miniquake_native.dll" symbol "mq_conproc_write_i32" returns void
extern function conprocReadTextRaw(mapped as ptr, byteOffset as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_text" returns u32
extern function conprocWriteText(mapped as ptr, byteOffset as u32, text as cstr, capacity as u32) from "miniquake_native.dll" symbol "mq_conproc_write_text" returns i32
extern function conprocScreenLines() from "miniquake_native.dll" symbol "mq_conproc_screen_lines" returns i32
extern function conprocSetScreenSize(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_conproc_set_screen_size" returns i32
extern function conprocReadConsoleTextRaw(beginLine as i32, endLine as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_console_text" returns u32
extern function conprocWriteKey(character as i32, virtualKey as i32, scanCode as i32, shift as i32, down as i32) from "miniquake_native.dll" symbol "mq_conproc_write_key" returns i32

extern function audioOpen(sampleRate as u32, channels as u32, bitsPerSample as u32) from "miniquake_native.dll" symbol "mq_audio_open" returns i32
extern function audioSubmit(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_audio_submit" returns i32
extern function audioClose() from "miniquake_native.dll" symbol "mq_audio_close" returns void
extern function audioQueued() from "miniquake_native.dll" symbol "mq_audio_queued" returns u32
extern function audioReset() from "miniquake_native.dll" symbol "mq_audio_reset" returns i32
extern function audioPosition(sampleMask as u32) from "miniquake_native.dll" symbol "mq_audio_position" returns u32
extern function audioSubmitted() from "miniquake_native.dll" symbol "mq_audio_submitted" returns u32
extern function audioCompleted() from "miniquake_native.dll" symbol "mq_audio_completed" returns u32
extern function audioUnderruns() from "miniquake_native.dll" symbol "mq_audio_underruns" returns u32
extern function audioHeaderState(index as u32) from "miniquake_native.dll" symbol "mq_audio_header_state" returns u32
extern function audioCapacity() from "miniquake_native.dll" symbol "mq_audio_capacity" returns u32
extern function audioIsOpen() from "miniquake_native.dll" symbol "mq_audio_is_open" returns i32
extern function oggOpen(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_ogg_open" returns u32
extern function oggOpenFile(filename as wstr) from "miniquake_native.dll" symbol "mq_ogg_open_file" returns u32
extern function oggRate() from "miniquake_native.dll" symbol "mq_ogg_rate" returns u32
extern function oggChannels() from "miniquake_native.dll" symbol "mq_ogg_channels" returns u32
extern function oggFrames() from "miniquake_native.dll" symbol "mq_ogg_frames" returns u32
extern function oggDecode(output as bytes, frameCapacity as u32) from "miniquake_native.dll" symbol "mq_ogg_decode" returns u32
extern function oggSeekStart() from "miniquake_native.dll" symbol "mq_ogg_seek_start" returns i32
extern function oggClose() from "miniquake_native.dll" symbol "mq_ogg_close"

extern function udpOpen(port as u32) from "miniquake_native.dll" symbol "mq_udp_open" returns u64
extern function udpOpenBound(port as u32, address as cstr) from "miniquake_native.dll" symbol "mq_udp_open_bound" returns u64
extern function udpClose(handle as u64) from "miniquake_native.dll" symbol "mq_udp_close" returns void
extern function udpBoundPort(handle as u64) from "miniquake_native.dll" symbol "mq_udp_bound_port" returns u32
extern function udpBoundAddressRaw(handle as u64, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_bound_address" returns u32
extern function udpEnableBroadcast(handle as u64) from "miniquake_native.dll" symbol "mq_udp_enable_broadcast" returns i32
extern function udpPeek(handle as u64) from "miniquake_native.dll" symbol "mq_udp_peek" returns i32
extern function udpSend(handle as u64, address as cstr, port as u32, data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_udp_send" returns i32
extern function udpReceive(handle as u64, data as bytes, capacity as u32) from "miniquake_native.dll" symbol "mq_udp_receive" returns i32
extern function udpLastAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_last_address" returns u32
extern function udpLastPort() from "miniquake_native.dll" symbol "mq_udp_last_port" returns u32
extern function udpLastError() from "miniquake_native.dll" symbol "mq_udp_last_error" returns i32
extern function udpLocalAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_local_address" returns u32
extern function udpHostNameRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_host_name" returns u32
extern function udpResolveNameRaw(name as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_resolve_name" returns u32
extern function udpReverseNameRaw(address as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_reverse_name" returns u32

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
extern function glTexEnvI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_env_i" returns void
extern function glTexImage2D(target as u32, level as i32, internalFormat as i32, width as i32, height as i32, border as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_image_2d" returns void
extern function glTexSubImage2D(target as u32, level as i32, xOffset as i32, yOffset as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_sub_image_2d" returns void
extern function glReadPixels(x as i32, y as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_read_pixels" returns void
extern function glGetStringRaw(name as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_gl_get_string" returns u32
extern function glGetError() from "miniquake_native.dll" symbol "mq_gl_get_error" returns u32
extern function glFinish() from "miniquake_native.dll" symbol "mq_gl_finish" returns void
extern function glFlush() from "miniquake_native.dll" symbol "mq_gl_flush" returns void
extern function glDrawBuffer(mode as u32) from "miniquake_native.dll" symbol "mq_gl_draw_buffer" returns void
extern function glDrawAliasBatch(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_batch" returns i32
extern function glDrawParticleBatch(data as bytes, byteCount as u32, viewOriginX as u32, viewOriginY as u32, viewOriginZ as u32, viewForwardX as u32, viewForwardY as u32, viewForwardZ as u32, viewUpX as u32, viewUpY as u32, viewUpZ as u32, viewRightX as u32, viewRightY as u32, viewRightZ as u32) from "miniquake_native.dll" symbol "mq_gl_draw_particle_batch" returns i32
extern function glDrawAliasModel(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, smooth as i32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_model" returns i32

// Win64-safe native text bridge.
//
// The MiniLang v1.0 runtime can pass caller-owned bytes reliably, while a
// direct extern `returns cstr` may truncate a high-address DLL pointer. Native
// string producers therefore return a byte count and write into a MiniLang
// buffer owned by the caller.
function nativeTextResult(buffer, count)
  if count <= 0 then return "" end if
  if count > len(buffer) then count = len(buffer) end if
  decoded = decode(slice(buffer, 0, count))
  if decoded is void then return "" end if
  return decoded
end function

// Provide f32 to text behavior for the active subsystem.
function f32ToText(bits)
  output = bytes(64)
  return nativeTextResult(output, f32ToTextRaw(bits, output, len(output)))
end function

// C printf("%f") boundary used by Cvar_SetValue, ED_Write and version-5
// savegames.  The native bridge avoids i32 overflow for values such as the
// stock Quake item bitmask 4097 and preserves negative zero exactly.
function f32ToFixed6(bits)
  output = bytes(96)
  return nativeTextResult(output, f32ToFixed6Raw(bits, output, len(output)))
end function

// Provide ascii char behavior for the active subsystem.
function asciiChar(value)
  output = bytes(2)
  return nativeTextResult(output, asciiCharRaw(value, output, len(output)))
end function

// Provide conproc read text behavior for the active subsystem.
function conprocReadText(mapped, byteOffset)
  output = bytes(65532)
  return nativeTextResult(output, conprocReadTextRaw(mapped, byteOffset, output, len(output)))
end function

// Provide conproc read console text behavior for the active subsystem.
function conprocReadConsoleText(beginLine, endLine)
  if endLine < beginLine then return "" end if
  capacity = 80 * (endLine - beginLine + 1)
  if capacity < 1 then return "" end if
  if capacity > 65535 then capacity = 65535 end if
  output = bytes(capacity)
  return nativeTextResult(output, conprocReadConsoleTextRaw(beginLine, endLine, output, capacity))
end function

// Provide udp bound address behavior for the active subsystem.
function udpBoundAddress(handle)
  output = bytes(64)
  return nativeTextResult(output, udpBoundAddressRaw(handle, output, len(output)))
end function

// Provide udp last address behavior for the active subsystem.
function udpLastAddress()
  output = bytes(64)
  return nativeTextResult(output, udpLastAddressRaw(output, len(output)))
end function

// Provide udp local address behavior for the active subsystem.
function udpLocalAddress()
  output = bytes(64)
  return nativeTextResult(output, udpLocalAddressRaw(output, len(output)))
end function

// Return udp host name derived from the active module state.
function udpHostName()
  output = bytes(256)
  return nativeTextResult(output, udpHostNameRaw(output, len(output)))
end function

// Return udp resolve name derived from the active module state.
function udpResolveName(name)
  output = bytes(256)
  return nativeTextResult(output, udpResolveNameRaw(name, output, len(output)))
end function

// Return udp reverse name derived from the active module state.
function udpReverseName(address)
  output = bytes(256)
  return nativeTextResult(output, udpReverseNameRaw(address, output, len(output)))
end function

// Provide gl get string behavior for the active subsystem.
function glGetString(name)
  output = bytes(4096)
  return nativeTextResult(output, glGetStringRaw(name, output, len(output)))
end function

// Return float bits derived from the active module state.
function floatBits(value)
  // Avoid number -> text -> strtod.  MiniLang exposes the exact tagged word via
  // nativeRawValue(), and the bridge understands both immediate f32 and boxed
  // f64 numeric values.
  return f32FromRaw(nativeRawValue(value))
end function

// Provide bits float behavior for the active subsystem.
function bitsFloat(bits)
  // Every IEEE-754 binary32 value has MiniLang's compact immediate-float form.
  // Return that raw word and let nativeValueFromRaw() restore the real value.
  return nativeValueFromRaw(f32ToRaw(bits))
end function

// Provide trunc behavior for the active subsystem.
function trunc(value)
  // MiniLang integers are already exact integral values.  Sending them through
  // IEEE-754 binary32 first would round masks and counters above 2^24 (for
  // example 0x12345678 becomes 0x12345680).  Only floating-point values need
  // the native Quake-style truncation path.
  if value is int then return value end if
  return f32ToI32Trunc(floatBits(value))
end function

// Provide float text behavior for the active subsystem.
function floatText(value)
  return f32ToText(floatBits(value))
end function

// Provide fixed six text behavior for the active subsystem.
function fixedSixText(value)
  return f32ToFixed6(floatBits(value))
end function

// Provide sin behavior for the active subsystem.
function sin(value)
  return bitsFloat(f32Sin(floatBits(value)))
end function

// Provide cos behavior for the active subsystem.
function cos(value)
  return bitsFloat(f32Cos(floatBits(value)))
end function

// Provide sqrt behavior for the active subsystem.
function sqrt(value)
  return bitsFloat(f32Sqrt(floatBits(value)))
end function

// Provide atan2 behavior for the active subsystem.
function atan2(y, x)
  return bitsFloat(f32Atan2(floatBits(y), floatBits(x)))
end function
extern function glStaticGeometryCall(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call" returns i32
extern function glStaticGeometryCallBatch(keys as bytes, byteCount as u32, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_batch" returns i32
extern function glStaticGeometryCallMultitextureBatch(records as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_multitexture_batch" returns i32
extern function glStaticGeometryPrepare(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_prepare" returns i32
extern function glStaticGeometryClear() from "miniquake_native.dll" symbol "mq_gl_static_geometry_clear" returns void
extern function glMultitextureAvailable() from "miniquake_native.dll" symbol "mq_gl_multitexture_available" returns i32
extern function glWorldProgramAvailable() from "miniquake_native.dll" symbol "mq_gl_world_program_available" returns i32
extern function glWorldProgramEnable(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_world_program_enable" returns void
extern function glActiveTexture(unit as i32) from "miniquake_native.dll" symbol "mq_gl_active_texture" returns void
extern function glMultiTexCoord2(unit as i32, sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_multi_tex_coord2" returns void
