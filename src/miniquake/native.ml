/*
Copyright (c) 1996-1997 Id Software, Inc.
Copyright (c) 2026 Nils Kopal
SPDX-License-Identifier: GPL-2.0-or-later

MiniLang implementation of miniquake.native.
*/
package miniquake.native

/// Invokes the native `f32FromText` bridge operation used by `miniquake.native`.
/// @param text Text to parse or process.
/// @returns The `u32` result produced by `f32FromText`.
extern function f32FromText(text as cstr) from "miniquake_native.dll" symbol "mq_f32_from_text" returns u32
/// Invokes the native `f32FromRaw` bridge operation used by `miniquake.native`.
/// @param rawValue The raw value input consumed by `f32FromRaw`.
/// @returns The `u32` result produced by `f32FromRaw`.
extern function f32FromRaw(rawValue as u64) from "miniquake_native.dll" symbol "mq_f32_from_ml_raw" returns u32
/// Invokes the native `f32ToRaw` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32ToRaw`.
/// @returns The `u64` result produced by `f32ToRaw`.
extern function f32ToRaw(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_ml_raw" returns u64
/// Invokes the native `f32ToTextRaw` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32ToTextRaw`.
/// @param output Destination buffer that receives the formatted text.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `f32ToTextRaw`.
extern function f32ToTextRaw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_text" returns u32
/// Invokes the native `f32ToFixed6Raw` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32ToFixed6Raw`.
/// @param output Destination buffer that receives the fixed-point text.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `f32ToFixed6Raw`.
extern function f32ToFixed6Raw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_fixed6" returns u32
/// Invokes the native `f32Sin` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32Sin`.
/// @returns The `u32` result produced by `f32Sin`.
extern function f32Sin(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sin" returns u32
/// Invokes the native `f32Cos` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32Cos`.
/// @returns The `u32` result produced by `f32Cos`.
extern function f32Cos(bits as u32) from "miniquake_native.dll" symbol "mq_f32_cos" returns u32
/// Invokes the native `f32Sqrt` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32Sqrt`.
/// @returns The `u32` result produced by `f32Sqrt`.
extern function f32Sqrt(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sqrt" returns u32
/// Invokes the native `f32Atan2` bridge operation used by `miniquake.native`.
/// @param yBits The y bits input consumed by `f32Atan2`.
/// @param xBits The x bits input consumed by `f32Atan2`.
/// @returns The `u32` result produced by `f32Atan2`.
extern function f32Atan2(yBits as u32, xBits as u32) from "miniquake_native.dll" symbol "mq_f32_atan2" returns u32
/// Invokes the native `f32ToI32Trunc` bridge operation used by `miniquake.native`.
/// @param bits The bits input consumed by `f32ToI32Trunc`.
/// @returns The `i32` result produced by `f32ToI32Trunc`.
extern function f32ToI32Trunc(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_i32_trunc" returns i32
/// Invokes the native `i32ToF32` bridge operation used by `miniquake.native`.
/// @param value Value consumed by `i32ToF32`.
/// @returns The `u32` result produced by `i32ToF32`.
extern function i32ToF32(value as i32) from "miniquake_native.dll" symbol "mq_i32_to_f32" returns u32
/// Invokes the native `asciiCode` bridge operation used by `miniquake.native`.
/// @param text Text to parse or process.
/// @returns The `i32` result produced by `asciiCode`.
extern function asciiCode(text as cstr) from "miniquake_native.dll" symbol "mq_ascii_code" returns i32
/// Invokes the native `asciiCharRaw` bridge operation used by `miniquake.native`.
/// @param value Value consumed by `asciiCharRaw`.
/// @param output Destination buffer that receives the encoded character.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `asciiCharRaw`.
extern function asciiCharRaw(value as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_ascii_char" returns u32

/// Invokes the native `renderSelect` bridge operation used by `miniquake.native`.
/// @param backend The backend input consumed by `renderSelect`.
/// @returns The `i32` result produced by `renderSelect`.
extern function renderSelect(backend as i32) from "miniquake_native.dll" symbol "mq_render_select" returns i32
/// Invokes the native `renderBackend` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `renderBackend`.
extern function renderBackend() from "miniquake_native.dll" symbol "mq_render_backend" returns i32
/// Invokes the native `renderAvailable` bridge operation used by `miniquake.native`.
/// @param backend The backend input consumed by `renderAvailable`.
/// @returns The `i32` result produced by `renderAvailable`.
extern function renderAvailable(backend as i32) from "miniquake_native.dll" symbol "mq_render_available" returns i32
/// Invokes the native `shadowWorldClear` bridge operation used by `miniquake.native`.
extern function shadowWorldClear() from "miniquake_native.dll" symbol "mq_shadow_world_clear" returns void
/// Invokes the native `shadowWorldUpload` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `shadowWorldUpload`.
extern function shadowWorldUpload(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_shadow_world_upload" returns i32
/// Invokes the native `shadowWorldUploadSurfaces` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `shadowWorldUploadSurfaces`.
extern function shadowWorldUploadSurfaces(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_shadow_world_upload_surfaces" returns i32
/// Invokes the native `shadowTraceBatch` bridge operation used by `miniquake.native`.
/// @param rays The rays input consumed by `shadowTraceBatch`.
/// @param rayBytes Byte data consumed by the operation.
/// @param results The results input consumed by `shadowTraceBatch`.
/// @param resultBytes Byte data consumed by the operation.
/// @returns The `i32` result produced by `shadowTraceBatch`.
extern function shadowTraceBatch(rays as bytes, rayBytes as u32, results as bytes, resultBytes as u32) from "miniquake_native.dll" symbol "mq_shadow_trace_batch" returns i32

/// Invokes the native `winCreate` bridge operation used by `miniquake.native`.
/// @param title The title input consumed by `winCreate`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param fullscreen The fullscreen input consumed by `winCreate`.
/// @returns The `ptr` result produced by `winCreate`.
extern function winCreate(title as wstr, width as i32, height as i32, fullscreen as i32) from "miniquake_native.dll" symbol "mq_win_create" returns ptr
/// Invokes the native `winDestroy` bridge operation used by `miniquake.native`.
extern function winDestroy() from "miniquake_native.dll" symbol "mq_win_destroy" returns void
/// Invokes the native `winPoll` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winPoll`.
extern function winPoll() from "miniquake_native.dll" symbol "mq_win_poll" returns i32
/// Invokes the native `winSwap` bridge operation used by `miniquake.native`.
extern function winSwap() from "miniquake_native.dll" symbol "mq_win_swap" returns void
/// Invokes the native `winKeyDown` bridge operation used by `miniquake.native`.
/// @param virtualKey The virtual key input consumed by `winKeyDown`.
/// @returns The `i32` result produced by `winKeyDown`.
extern function winKeyDown(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_down" returns i32
/// Invokes the native `winKeyPressed` bridge operation used by `miniquake.native`.
/// @param virtualKey The virtual key input consumed by `winKeyPressed`.
/// @returns The `i32` result produced by `winKeyPressed`.
extern function winKeyPressed(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_pressed" returns i32
/// Invokes the native `winKeySnapshot` bridge operation used by `miniquake.native`.
/// @param downStates The down states input consumed by `winKeySnapshot`.
/// @param pressedStates The pressed states input consumed by `winKeySnapshot`.
/// @param queryMask The query mask input consumed by `winKeySnapshot`.
/// @param stateCount Number of entries or units to process.
/// @returns The `i32` result produced by `winKeySnapshot`.
extern function winKeySnapshot(downStates as bytes, pressedStates as bytes, queryMask as bytes, stateCount as u32) from "miniquake_native.dll" symbol "mq_win_key_snapshot" returns i32
/// Invokes the native `winTextPop` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winTextPop`.
extern function winTextPop() from "miniquake_native.dll" symbol "mq_win_text_pop" returns i32
/// Invokes the native `winHasFocus` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winHasFocus`.
extern function winHasFocus() from "miniquake_native.dll" symbol "mq_win_has_focus" returns i32
/// Invokes the native `winClientWidth` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winClientWidth`.
extern function winClientWidth() from "miniquake_native.dll" symbol "mq_win_client_width" returns i32
/// Invokes the native `winClientHeight` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winClientHeight`.
extern function winClientHeight() from "miniquake_native.dll" symbol "mq_win_client_height" returns i32
/// Invokes the native `winResizeClient` bridge operation used by `miniquake.native`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @returns The `i32` result produced by `winResizeClient`.
extern function winResizeClient(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_win_resize_client" returns i32
/// Invokes the native `winWindowX` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winWindowX`.
extern function winWindowX() from "miniquake_native.dll" symbol "mq_win_window_x" returns i32
/// Invokes the native `winWindowY` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winWindowY`.
extern function winWindowY() from "miniquake_native.dll" symbol "mq_win_window_y" returns i32
/// Invokes the native `winIsMinimized` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winIsMinimized`.
extern function winIsMinimized() from "miniquake_native.dll" symbol "mq_win_is_minimized" returns i32
/// Invokes the native `winDesktopWidth` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winDesktopWidth`.
extern function winDesktopWidth() from "miniquake_native.dll" symbol "mq_win_desktop_width" returns i32
/// Invokes the native `winDesktopHeight` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winDesktopHeight`.
extern function winDesktopHeight() from "miniquake_native.dll" symbol "mq_win_desktop_height" returns i32
/// Invokes the native `winDisplayModeCount` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winDisplayModeCount`.
extern function winDisplayModeCount() from "miniquake_native.dll" symbol "mq_win_display_mode_count" returns u32
/// Invokes the native `winDisplayModeWidth` bridge operation used by `miniquake.native`.
/// @param index Zero-based index of the requested entry.
/// @returns The `i32` result produced by `winDisplayModeWidth`.
extern function winDisplayModeWidth(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_width" returns i32
/// Invokes the native `winDisplayModeHeight` bridge operation used by `miniquake.native`.
/// @param index Zero-based index of the requested entry.
/// @returns The `i32` result produced by `winDisplayModeHeight`.
extern function winDisplayModeHeight(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_height" returns i32
/// Invokes the native `winDisplayModeBpp` bridge operation used by `miniquake.native`.
/// @param index Zero-based index of the requested entry.
/// @returns The `i32` result produced by `winDisplayModeBpp`.
extern function winDisplayModeBpp(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_bpp" returns i32
/// Invokes the native `winDisplayModeFrequency` bridge operation used by `miniquake.native`.
/// @param index Zero-based index of the requested entry.
/// @returns The `i32` result produced by `winDisplayModeFrequency`.
extern function winDisplayModeFrequency(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_frequency" returns i32
/// Invokes the native `winTestDisplayMode` bridge operation used by `miniquake.native`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param bpp The bpp input consumed by `winTestDisplayMode`.
/// @param frequency The frequency input consumed by `winTestDisplayMode`.
/// @returns The `i32` result produced by `winTestDisplayMode`.
extern function winTestDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32) from "miniquake_native.dll" symbol "mq_win_test_display_mode" returns i32
/// Invokes the native `winConfigureDisplayMode` bridge operation used by `miniquake.native`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param bpp The bpp input consumed by `winConfigureDisplayMode`.
/// @param frequency The frequency input consumed by `winConfigureDisplayMode`.
/// @param fullscreen The fullscreen input consumed by `winConfigureDisplayMode`.
/// @param useCurrent The use current input consumed by `winConfigureDisplayMode`.
/// @returns The `i32` result produced by `winConfigureDisplayMode`.
extern function winConfigureDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32, fullscreen as i32, useCurrent as i32) from "miniquake_native.dll" symbol "mq_win_configure_display_mode" returns i32
/// Invokes the native `winRestoreDisplayMode` bridge operation used by `miniquake.native`.
extern function winRestoreDisplayMode() from "miniquake_native.dll" symbol "mq_win_restore_display_mode" returns void
/// Invokes the native `winGetGammaRamp` bridge operation used by `miniquake.native`.
/// @param ramp The ramp input consumed by `winGetGammaRamp`.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `winGetGammaRamp`.
extern function winGetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_get_gamma_ramp" returns i32
/// Invokes the native `winSetGammaRamp` bridge operation used by `miniquake.native`.
/// @param ramp The ramp input consumed by `winSetGammaRamp`.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `winSetGammaRamp`.
extern function winSetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_set_gamma_ramp" returns i32
/// Invokes the native `winContextReady` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winContextReady`.
extern function winContextReady() from "miniquake_native.dll" symbol "mq_win_context_ready" returns i32
/// Invokes the native `winMakeCurrent` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winMakeCurrent`.
extern function winMakeCurrent() from "miniquake_native.dll" symbol "mq_win_make_current" returns i32
/// Invokes the native `winActivate` bridge operation used by `miniquake.native`.
/// @param active The active input consumed by `winActivate`.
/// @param minimized The minimized input consumed by `winActivate`.
extern function winActivate(active as i32, minimized as i32) from "miniquake_native.dll" symbol "mq_win_activate" returns void
/// Invokes the native `winSetTitle` bridge operation used by `miniquake.native`.
/// @param title The title input consumed by `winSetTitle`.
extern function winSetTitle(title as wstr) from "miniquake_native.dll" symbol "mq_win_set_title" returns void
/// Invokes the native `winSetCursorCapture` bridge operation used by `miniquake.native`.
/// @param enabled Whether the optional behavior is enabled.
extern function winSetCursorCapture(enabled as i32) from "miniquake_native.dll" symbol "mq_win_set_cursor_capture" returns void
/// Invokes the native `winMouseDx` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winMouseDx`.
extern function winMouseDx() from "miniquake_native.dll" symbol "mq_win_mouse_dx" returns i32
/// Invokes the native `winMouseDy` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winMouseDy`.
extern function winMouseDy() from "miniquake_native.dll" symbol "mq_win_mouse_dy" returns i32
/// Invokes the native `winMouseButtons` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winMouseButtons`.
extern function winMouseButtons() from "miniquake_native.dll" symbol "mq_win_mouse_buttons" returns i32
/// Invokes the native `winMouseWheel` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winMouseWheel`.
extern function winMouseWheel() from "miniquake_native.dll" symbol "mq_win_mouse_wheel" returns i32
/// Invokes the native `winInputEventPop` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winInputEventPop`.
extern function winInputEventPop() from "miniquake_native.dll" symbol "mq_win_input_event_pop" returns u32
/// Invokes the native `winInputTestPush` bridge operation used by `miniquake.native`.
/// @param eventType The event type input consumed by `winInputTestPush`.
/// @param code The code input consumed by `winInputTestPush`.
/// @param value Value consumed by `winInputTestPush`.
extern function winInputTestPush(eventType as u32, code as u32, value as i32) from "miniquake_native.dll" symbol "mq_win_input_test_push" returns void
/// Invokes the native `winCursorShow` bridge operation used by `miniquake.native`.
/// @param show The show input consumed by `winCursorShow`.
extern function winCursorShow(show as i32) from "miniquake_native.dll" symbol "mq_win_cursor_show" returns void
/// Invokes the native `winCursorCenter` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winCursorCenter`.
extern function winCursorCenter() from "miniquake_native.dll" symbol "mq_win_cursor_center" returns i32
/// Invokes the native `winUpdateClipCursor` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winUpdateClipCursor`.
extern function winUpdateClipCursor() from "miniquake_native.dll" symbol "mq_win_update_clip_cursor" returns i32
/// Invokes the native `winJoyStartup` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winJoyStartup`.
extern function winJoyStartup() from "miniquake_native.dll" symbol "mq_win_joy_startup" returns i32
/// Invokes the native `winJoyRead` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winJoyRead`.
extern function winJoyRead() from "miniquake_native.dll" symbol "mq_win_joy_read" returns i32
/// Invokes the native `winJoyAxis` bridge operation used by `miniquake.native`.
/// @param axis The axis input consumed by `winJoyAxis`.
/// @returns The `u32` result produced by `winJoyAxis`.
extern function winJoyAxis(axis as u32) from "miniquake_native.dll" symbol "mq_win_joy_axis" returns u32
/// Invokes the native `winJoyButtons` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winJoyButtons`.
extern function winJoyButtons() from "miniquake_native.dll" symbol "mq_win_joy_buttons" returns u32
/// Invokes the native `winJoyPov` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winJoyPov`.
extern function winJoyPov() from "miniquake_native.dll" symbol "mq_win_joy_pov" returns u32
/// Invokes the native `winJoyButtonCount` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winJoyButtonCount`.
extern function winJoyButtonCount() from "miniquake_native.dll" symbol "mq_win_joy_button_count" returns u32
/// Invokes the native `winJoyHasPov` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `winJoyHasPov`.
extern function winJoyHasPov() from "miniquake_native.dll" symbol "mq_win_joy_has_pov" returns i32
/// Invokes the native `winJoyWarriorCurve` bridge operation used by `miniquake.native`.
/// @param rawValue The raw value input consumed by `winJoyWarriorCurve`.
/// @returns The `i32` result produced by `winJoyWarriorCurve`.
extern function winJoyWarriorCurve(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve" returns i32
/// Invokes the native `winJoyWarriorCurveF32` bridge operation used by `miniquake.native`.
/// @param rawValue The raw value input consumed by `winJoyWarriorCurveF32`.
/// @returns The `u32` result produced by `winJoyWarriorCurveF32`.
extern function winJoyWarriorCurveF32(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve_f32" returns u32
/// Invokes the native `winTicks` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `winTicks`.
extern function winTicks() from "miniquake_native.dll" symbol "mq_win_ticks" returns u32
/// Invokes the native `winSleep` bridge operation used by `miniquake.native`.
/// @param milliseconds The milliseconds input consumed by `winSleep`.
extern function winSleep(milliseconds as u32) from "miniquake_native.dll" symbol "mq_win_sleep" returns void

/// Invokes the native `sysCounter` bridge operation used by `miniquake.native`.
/// @returns The `u64` result produced by `sysCounter`.
extern function sysCounter() from "miniquake_native.dll" symbol "mq_sys_counter" returns u64
/// Invokes the native `sysFrequency` bridge operation used by `miniquake.native`.
/// @returns The `u64` result produced by `sysFrequency`.
extern function sysFrequency() from "miniquake_native.dll" symbol "mq_sys_frequency" returns u64
/// Invokes the native `processHandleCount` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `processHandleCount`.
extern function processHandleCount() from "miniquake_native.dll" symbol "mq_process_handle_count" returns u32
/// Invokes the native `sysMakeCodeWriteable` bridge operation used by `miniquake.native`.
/// @param address Network address of the peer.
/// @param length Length of the requested data in units appropriate to the operation.
/// @returns The `i32` result produced by `sysMakeCodeWriteable`.
extern function sysMakeCodeWriteable(address as u64, length as u64) from "miniquake_native.dll" symbol "mq_sys_make_code_writeable" returns i32
/// Invokes the native `sysConsoleAlloc` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `sysConsoleAlloc`.
extern function sysConsoleAlloc() from "miniquake_native.dll" symbol "mq_sys_console_alloc" returns i32
/// Invokes the native `sysConsoleFree` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `sysConsoleFree`.
extern function sysConsoleFree() from "miniquake_native.dll" symbol "mq_sys_console_free" returns i32
/// Invokes the native `sysConsoleEventPop` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `sysConsoleEventPop`.
extern function sysConsoleEventPop() from "miniquake_native.dll" symbol "mq_sys_console_event_pop" returns u32
/// Invokes the native `sysConsoleWrite` bridge operation used by `miniquake.native`.
/// @param text Text to parse or process.
/// @returns The `i32` result produced by `sysConsoleWrite`.
extern function sysConsoleWrite(text as cstr) from "miniquake_native.dll" symbol "mq_sys_console_write" returns i32
/// Invokes the native `sysSleepUntilInput` bridge operation used by `miniquake.native`.
/// @param milliseconds The milliseconds input consumed by `sysSleepUntilInput`.
extern function sysSleepUntilInput(milliseconds as u32) from "miniquake_native.dll" symbol "mq_sys_sleep_until_input" returns void

/// Invokes the native `conprocCreateEvent` bridge operation used by `miniquake.native`.
/// @returns The `u64` result produced by `conprocCreateEvent`.
extern function conprocCreateEvent() from "miniquake_native.dll" symbol "mq_conproc_create_event" returns u64
/// Invokes the native `conprocSetEvent` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `conprocSetEvent`.
/// @returns The `i32` result produced by `conprocSetEvent`.
extern function conprocSetEvent(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_set_event" returns i32
/// Invokes the native `conprocCloseHandle` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `conprocCloseHandle`.
extern function conprocCloseHandle(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_close_handle" returns void
/// Invokes the native `conprocWaitAny` bridge operation used by `miniquake.native`.
/// @param first The first input consumed by `conprocWaitAny`.
/// @param second The second input consumed by `conprocWaitAny`.
/// @param milliseconds The milliseconds input consumed by `conprocWaitAny`.
/// @returns The `i32` result produced by `conprocWaitAny`.
extern function conprocWaitAny(first as u64, second as u64, milliseconds as u32) from "miniquake_native.dll" symbol "mq_conproc_wait_any" returns i32
/// Invokes the native `conprocMap` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `conprocMap`.
/// @returns The `ptr` result produced by `conprocMap`.
extern function conprocMap(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_map" returns ptr
/// Invokes the native `conprocUnmap` bridge operation used by `miniquake.native`.
/// @param mapped The mapped input consumed by `conprocUnmap`.
/// @returns The `i32` result produced by `conprocUnmap`.
extern function conprocUnmap(mapped as ptr) from "miniquake_native.dll" symbol "mq_conproc_unmap" returns i32
/// Invokes the native `conprocReadI32` bridge operation used by `miniquake.native`.
/// @param mapped The mapped input consumed by `conprocReadI32`.
/// @param index Zero-based index of the requested entry.
/// @returns The `i32` result produced by `conprocReadI32`.
extern function conprocReadI32(mapped as ptr, index as u32) from "miniquake_native.dll" symbol "mq_conproc_read_i32" returns i32
/// Invokes the native `conprocWriteI32` bridge operation used by `miniquake.native`.
/// @param mapped The mapped input consumed by `conprocWriteI32`.
/// @param index Zero-based index of the requested entry.
/// @param value Value consumed by `conprocWriteI32`.
extern function conprocWriteI32(mapped as ptr, index as u32, value as i32) from "miniquake_native.dll" symbol "mq_conproc_write_i32" returns void
/// Invokes the native `conprocReadTextRaw` bridge operation used by `miniquake.native`.
/// @param mapped The mapped input consumed by `conprocReadTextRaw`.
/// @param byteOffset Zero-based offset of the requested data.
/// @param output Destination buffer that receives process text.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `conprocReadTextRaw`.
extern function conprocReadTextRaw(mapped as ptr, byteOffset as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_text" returns u32
/// Invokes the native `conprocWriteText` bridge operation used by `miniquake.native`.
/// @param mapped The mapped input consumed by `conprocWriteText`.
/// @param byteOffset Zero-based offset of the requested data.
/// @param text Text to parse or process.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `i32` result produced by `conprocWriteText`.
extern function conprocWriteText(mapped as ptr, byteOffset as u32, text as cstr, capacity as u32) from "miniquake_native.dll" symbol "mq_conproc_write_text" returns i32
/// Invokes the native `conprocScreenLines` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `conprocScreenLines`.
extern function conprocScreenLines() from "miniquake_native.dll" symbol "mq_conproc_screen_lines" returns i32
/// Invokes the native `conprocSetScreenSize` bridge operation used by `miniquake.native`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @returns The `i32` result produced by `conprocSetScreenSize`.
extern function conprocSetScreenSize(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_conproc_set_screen_size" returns i32
/// Invokes the native `conprocReadConsoleTextRaw` bridge operation used by `miniquake.native`.
/// @param beginLine The begin line input consumed by `conprocReadConsoleTextRaw`.
/// @param endLine The end line input consumed by `conprocReadConsoleTextRaw`.
/// @param output Destination buffer that receives console text.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `conprocReadConsoleTextRaw`.
extern function conprocReadConsoleTextRaw(beginLine as i32, endLine as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_console_text" returns u32
/// Invokes the native `conprocWriteKey` bridge operation used by `miniquake.native`.
/// @param character The character input consumed by `conprocWriteKey`.
/// @param virtualKey The virtual key input consumed by `conprocWriteKey`.
/// @param scanCode The scan code input consumed by `conprocWriteKey`.
/// @param shift The shift input consumed by `conprocWriteKey`.
/// @param down The down input consumed by `conprocWriteKey`.
/// @returns The `i32` result produced by `conprocWriteKey`.
extern function conprocWriteKey(character as i32, virtualKey as i32, scanCode as i32, shift as i32, down as i32) from "miniquake_native.dll" symbol "mq_conproc_write_key" returns i32

/// Invokes the native `audioOpen` bridge operation used by `miniquake.native`.
/// @param sampleRate The sample rate input consumed by `audioOpen`.
/// @param channels Number of interleaved audio channels.
/// @param bitsPerSample The bits per sample input consumed by `audioOpen`.
/// @returns The `i32` result produced by `audioOpen`.
extern function audioOpen(sampleRate as u32, channels as u32, bitsPerSample as u32) from "miniquake_native.dll" symbol "mq_audio_open" returns i32
/// Invokes the native `audioSubmit` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `audioSubmit`.
extern function audioSubmit(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_audio_submit" returns i32
/// Invokes the native `audioClose` bridge operation used by `miniquake.native`.
extern function audioClose() from "miniquake_native.dll" symbol "mq_audio_close" returns void
/// Invokes the native `audioQueued` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `audioQueued`.
extern function audioQueued() from "miniquake_native.dll" symbol "mq_audio_queued" returns u32
/// Invokes the native `audioReset` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `audioReset`.
extern function audioReset() from "miniquake_native.dll" symbol "mq_audio_reset" returns i32
/// Invokes the native `audioPosition` bridge operation used by `miniquake.native`.
/// @param sampleMask The sample mask input consumed by `audioPosition`.
/// @returns The `u32` result produced by `audioPosition`.
extern function audioPosition(sampleMask as u32) from "miniquake_native.dll" symbol "mq_audio_position" returns u32
/// Invokes the native `audioSubmitted` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `audioSubmitted`.
extern function audioSubmitted() from "miniquake_native.dll" symbol "mq_audio_submitted" returns u32
/// Invokes the native `audioCompleted` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `audioCompleted`.
extern function audioCompleted() from "miniquake_native.dll" symbol "mq_audio_completed" returns u32
/// Invokes the native `audioUnderruns` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `audioUnderruns`.
extern function audioUnderruns() from "miniquake_native.dll" symbol "mq_audio_underruns" returns u32
/// Invokes the native `audioHeaderState` bridge operation used by `miniquake.native`.
/// @param index Zero-based index of the requested entry.
/// @returns The `u32` result produced by `audioHeaderState`.
extern function audioHeaderState(index as u32) from "miniquake_native.dll" symbol "mq_audio_header_state" returns u32
/// Invokes the native `audioCapacity` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `audioCapacity`.
extern function audioCapacity() from "miniquake_native.dll" symbol "mq_audio_capacity" returns u32
/// Invokes the native `audioIsOpen` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `audioIsOpen`.
extern function audioIsOpen() from "miniquake_native.dll" symbol "mq_audio_is_open" returns i32
/// Invokes the native `oggOpen` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `u32` result produced by `oggOpen`.
extern function oggOpen(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_ogg_open" returns u32
/// Invokes the native `oggOpenFile` bridge operation used by `miniquake.native`.
/// @param filename Path of the file to process.
/// @returns The `u32` result produced by `oggOpenFile`.
extern function oggOpenFile(filename as wstr) from "miniquake_native.dll" symbol "mq_ogg_open_file" returns u32
/// Invokes the native `oggRate` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `oggRate`.
extern function oggRate() from "miniquake_native.dll" symbol "mq_ogg_rate" returns u32
/// Invokes the native `oggChannels` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `oggChannels`.
extern function oggChannels() from "miniquake_native.dll" symbol "mq_ogg_channels" returns u32
/// Invokes the native `oggFrames` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `oggFrames`.
extern function oggFrames() from "miniquake_native.dll" symbol "mq_ogg_frames" returns u32
/// Invokes the native `oggDecode` bridge operation used by `miniquake.native`.
/// @param output Destination buffer that receives decoded PCM samples.
/// @param frameCapacity The frame capacity input consumed by `oggDecode`.
/// @returns The `u32` result produced by `oggDecode`.
extern function oggDecode(output as bytes, frameCapacity as u32) from "miniquake_native.dll" symbol "mq_ogg_decode" returns u32
/// Invokes the native `oggSeekStart` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `oggSeekStart`.
extern function oggSeekStart() from "miniquake_native.dll" symbol "mq_ogg_seek_start" returns i32
/// Invokes the native `oggClose` bridge operation used by `miniquake.native`.
/// @returns The `int` result produced by `oggClose`.
extern function oggClose() from "miniquake_native.dll" symbol "mq_ogg_close"

/// Invokes the native `udpOpen` bridge operation used by `miniquake.native`.
/// @param port The port input consumed by `udpOpen`.
/// @returns The `u64` result produced by `udpOpen`.
extern function udpOpen(port as u32) from "miniquake_native.dll" symbol "mq_udp_open" returns u64
/// Invokes the native `udpOpenBound` bridge operation used by `miniquake.native`.
/// @param port The port input consumed by `udpOpenBound`.
/// @param address Network address of the peer.
/// @returns The `u64` result produced by `udpOpenBound`.
extern function udpOpenBound(port as u32, address as cstr) from "miniquake_native.dll" symbol "mq_udp_open_bound" returns u64
/// Invokes the native `udpClose` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpClose`.
extern function udpClose(handle as u64) from "miniquake_native.dll" symbol "mq_udp_close" returns void
/// Invokes the native `udpBoundPort` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpBoundPort`.
/// @returns The `u32` result produced by `udpBoundPort`.
extern function udpBoundPort(handle as u64) from "miniquake_native.dll" symbol "mq_udp_bound_port" returns u32
/// Invokes the native `udpBoundAddressRaw` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpBoundAddressRaw`.
/// @param output Destination buffer that receives the bound address.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpBoundAddressRaw`.
extern function udpBoundAddressRaw(handle as u64, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_bound_address" returns u32
/// Invokes the native `udpEnableBroadcast` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpEnableBroadcast`.
/// @returns The `i32` result produced by `udpEnableBroadcast`.
extern function udpEnableBroadcast(handle as u64) from "miniquake_native.dll" symbol "mq_udp_enable_broadcast" returns i32
/// Invokes the native `udpPeek` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpPeek`.
/// @returns The `i32` result produced by `udpPeek`.
extern function udpPeek(handle as u64) from "miniquake_native.dll" symbol "mq_udp_peek" returns i32
/// Invokes the native `udpSend` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpSend`.
/// @param address Network address of the peer.
/// @param port The port input consumed by `udpSend`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `udpSend`.
extern function udpSend(handle as u64, address as cstr, port as u32, data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_udp_send" returns i32
/// Invokes the native `udpReceive` bridge operation used by `miniquake.native`.
/// @param handle The handle input consumed by `udpReceive`.
/// @param data Input data consumed by the operation.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `i32` result produced by `udpReceive`.
extern function udpReceive(handle as u64, data as bytes, capacity as u32) from "miniquake_native.dll" symbol "mq_udp_receive" returns i32
/// Invokes the native `udpLastAddressRaw` bridge operation used by `miniquake.native`.
/// @param output Destination buffer that receives the most recent peer address.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpLastAddressRaw`.
extern function udpLastAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_last_address" returns u32
/// Invokes the native `udpLastPort` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `udpLastPort`.
extern function udpLastPort() from "miniquake_native.dll" symbol "mq_udp_last_port" returns u32
/// Invokes the native `udpLastError` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `udpLastError`.
extern function udpLastError() from "miniquake_native.dll" symbol "mq_udp_last_error" returns i32
/// Invokes the native `udpLocalAddressRaw` bridge operation used by `miniquake.native`.
/// @param output Destination buffer that receives the local address.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpLocalAddressRaw`.
extern function udpLocalAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_local_address" returns u32
/// Invokes the native `udpHostNameRaw` bridge operation used by `miniquake.native`.
/// @param output Destination buffer that receives the local host name.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpHostNameRaw`.
extern function udpHostNameRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_host_name" returns u32
/// Invokes the native `udpResolveNameRaw` bridge operation used by `miniquake.native`.
/// @param name Stable name that identifies the requested object or option.
/// @param output Destination buffer that receives the resolved address.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpResolveNameRaw`.
extern function udpResolveNameRaw(name as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_resolve_name" returns u32
/// Invokes the native `udpReverseNameRaw` bridge operation used by `miniquake.native`.
/// @param address Network address of the peer.
/// @param output Destination buffer that receives the reverse-resolved name.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `udpReverseNameRaw`.
extern function udpReverseNameRaw(address as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_reverse_name" returns u32

/// Invokes the native `glBegin` bridge operation used by `miniquake.native`.
/// @param mode The mode input consumed by `glBegin`.
extern function glBegin(mode as u32) from "miniquake_native.dll" symbol "mq_gl_begin" returns void
/// Invokes the native `glEnd` bridge operation used by `miniquake.native`.
extern function glEnd() from "miniquake_native.dll" symbol "mq_gl_end" returns void
/// Invokes the native `glVertex2` bridge operation used by `miniquake.native`.
/// @param xBits The x bits input consumed by `glVertex2`.
/// @param yBits The y bits input consumed by `glVertex2`.
extern function glVertex2(xBits as u32, yBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex2" returns void
/// Invokes the native `glVertex3` bridge operation used by `miniquake.native`.
/// @param xBits The x bits input consumed by `glVertex3`.
/// @param yBits The y bits input consumed by `glVertex3`.
/// @param zBits The z bits input consumed by `glVertex3`.
extern function glVertex3(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex3" returns void
/// Invokes the native `glTexcoord2` bridge operation used by `miniquake.native`.
/// @param sBits The s bits input consumed by `glTexcoord2`.
/// @param tBits The t bits input consumed by `glTexcoord2`.
extern function glTexcoord2(sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_texcoord2" returns void
/// Invokes the native `glColor4ub` bridge operation used by `miniquake.native`.
/// @param red The red input consumed by `glColor4ub`.
/// @param green The green input consumed by `glColor4ub`.
/// @param blue The blue input consumed by `glColor4ub`.
/// @param alpha The alpha input consumed by `glColor4ub`.
extern function glColor4ub(red as u32, green as u32, blue as u32, alpha as u32) from "miniquake_native.dll" symbol "mq_gl_color4ub" returns void
/// Invokes the native `glClearColor` bridge operation used by `miniquake.native`.
/// @param redBits The red bits input consumed by `glClearColor`.
/// @param greenBits The green bits input consumed by `glClearColor`.
/// @param blueBits The blue bits input consumed by `glClearColor`.
/// @param alphaBits The alpha bits input consumed by `glClearColor`.
extern function glClearColor(redBits as u32, greenBits as u32, blueBits as u32, alphaBits as u32) from "miniquake_native.dll" symbol "mq_gl_clear_color" returns void
/// Invokes the native `glClear` bridge operation used by `miniquake.native`.
/// @param mask The mask input consumed by `glClear`.
extern function glClear(mask as u32) from "miniquake_native.dll" symbol "mq_gl_clear" returns void
/// Invokes the native `glEnable` bridge operation used by `miniquake.native`.
/// @param capability The capability input consumed by `glEnable`.
extern function glEnable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_enable" returns void
/// Invokes the native `glDisable` bridge operation used by `miniquake.native`.
/// @param capability The capability input consumed by `glDisable`.
extern function glDisable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_disable" returns void
/// Invokes the native `glBlendFunc` bridge operation used by `miniquake.native`.
/// @param source Source value or collection to read.
/// @param destination Destination value or collection to update.
extern function glBlendFunc(source as u32, destination as u32) from "miniquake_native.dll" symbol "mq_gl_blend_func" returns void
/// Invokes the native `glDepthFunc` bridge operation used by `miniquake.native`.
/// @param functionName Name that identifies the requested value or resource.
extern function glDepthFunc(functionName as u32) from "miniquake_native.dll" symbol "mq_gl_depth_func" returns void
/// Invokes the native `glDepthMask` bridge operation used by `miniquake.native`.
/// @param enabled Whether the optional behavior is enabled.
extern function glDepthMask(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_depth_mask" returns void
/// Invokes the native `glDepthRange` bridge operation used by `miniquake.native`.
/// @param nearBits The near bits input consumed by `glDepthRange`.
/// @param farBits The far bits input consumed by `glDepthRange`.
extern function glDepthRange(nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_depth_range" returns void
/// Invokes the native `glAlphaFunc` bridge operation used by `miniquake.native`.
/// @param functionName Name that identifies the requested value or resource.
/// @param referenceBits The reference bits input consumed by `glAlphaFunc`.
extern function glAlphaFunc(functionName as u32, referenceBits as u32) from "miniquake_native.dll" symbol "mq_gl_alpha_func" returns void
/// Invokes the native `glCullFace` bridge operation used by `miniquake.native`.
/// @param mode The mode input consumed by `glCullFace`.
extern function glCullFace(mode as u32) from "miniquake_native.dll" symbol "mq_gl_cull_face" returns void
/// Invokes the native `glShadeModel` bridge operation used by `miniquake.native`.
/// @param mode The mode input consumed by `glShadeModel`.
extern function glShadeModel(mode as u32) from "miniquake_native.dll" symbol "mq_gl_shade_model" returns void
/// Invokes the native `glPolygonMode` bridge operation used by `miniquake.native`.
/// @param face The face input consumed by `glPolygonMode`.
/// @param mode The mode input consumed by `glPolygonMode`.
extern function glPolygonMode(face as u32, mode as u32) from "miniquake_native.dll" symbol "mq_gl_polygon_mode" returns void
/// Invokes the native `glViewport` bridge operation used by `miniquake.native`.
/// @param x The x input consumed by `glViewport`.
/// @param y The y input consumed by `glViewport`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
extern function glViewport(x as i32, y as i32, width as i32, height as i32) from "miniquake_native.dll" symbol "mq_gl_viewport" returns void
/// Invokes the native `glMatrixMode` bridge operation used by `miniquake.native`.
/// @param mode The mode input consumed by `glMatrixMode`.
extern function glMatrixMode(mode as u32) from "miniquake_native.dll" symbol "mq_gl_matrix_mode" returns void
/// Invokes the native `glLoadIdentity` bridge operation used by `miniquake.native`.
extern function glLoadIdentity() from "miniquake_native.dll" symbol "mq_gl_load_identity" returns void
/// Invokes the native `glPushMatrix` bridge operation used by `miniquake.native`.
extern function glPushMatrix() from "miniquake_native.dll" symbol "mq_gl_push_matrix" returns void
/// Invokes the native `glPopMatrix` bridge operation used by `miniquake.native`.
extern function glPopMatrix() from "miniquake_native.dll" symbol "mq_gl_pop_matrix" returns void
/// Invokes the native `glTranslate` bridge operation used by `miniquake.native`.
/// @param xBits The x bits input consumed by `glTranslate`.
/// @param yBits The y bits input consumed by `glTranslate`.
/// @param zBits The z bits input consumed by `glTranslate`.
extern function glTranslate(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_translate" returns void
/// Invokes the native `glRotate` bridge operation used by `miniquake.native`.
/// @param angleBits The angle bits input consumed by `glRotate`.
/// @param xBits The x bits input consumed by `glRotate`.
/// @param yBits The y bits input consumed by `glRotate`.
/// @param zBits The z bits input consumed by `glRotate`.
extern function glRotate(angleBits as u32, xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_rotate" returns void
/// Invokes the native `glScale` bridge operation used by `miniquake.native`.
/// @param xBits The x bits input consumed by `glScale`.
/// @param yBits The y bits input consumed by `glScale`.
/// @param zBits The z bits input consumed by `glScale`.
extern function glScale(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_scale" returns void
/// Invokes the native `glOrtho` bridge operation used by `miniquake.native`.
/// @param leftBits The left bits input consumed by `glOrtho`.
/// @param rightBits The right bits input consumed by `glOrtho`.
/// @param bottomBits The bottom bits input consumed by `glOrtho`.
/// @param topBits The top bits input consumed by `glOrtho`.
/// @param nearBits The near bits input consumed by `glOrtho`.
/// @param farBits The far bits input consumed by `glOrtho`.
extern function glOrtho(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_ortho" returns void
/// Invokes the native `glFrustum` bridge operation used by `miniquake.native`.
/// @param leftBits The left bits input consumed by `glFrustum`.
/// @param rightBits The right bits input consumed by `glFrustum`.
/// @param bottomBits The bottom bits input consumed by `glFrustum`.
/// @param topBits The top bits input consumed by `glFrustum`.
/// @param nearBits The near bits input consumed by `glFrustum`.
/// @param farBits The far bits input consumed by `glFrustum`.
extern function glFrustum(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_frustum" returns void
/// Invokes the native `glBindTexture` bridge operation used by `miniquake.native`.
/// @param target The target input consumed by `glBindTexture`.
/// @param texture Texture resource processed by the operation.
extern function glBindTexture(target as u32, texture as u32) from "miniquake_native.dll" symbol "mq_gl_bind_texture" returns void
/// Invokes the native `glGenTextures` bridge operation used by `miniquake.native`.
/// @param count Number of entries or units to process.
/// @param textureIds The texture ids input consumed by `glGenTextures`.
extern function glGenTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_gen_textures" returns void
/// Invokes the native `glDeleteTextures` bridge operation used by `miniquake.native`.
/// @param count Number of entries or units to process.
/// @param textureIds The texture ids input consumed by `glDeleteTextures`.
extern function glDeleteTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_delete_textures" returns void
/// Invokes the native `glTexParameterI` bridge operation used by `miniquake.native`.
/// @param target The target input consumed by `glTexParameterI`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `glTexParameterI`.
extern function glTexParameterI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_parameter_i" returns void
/// Invokes the native `glTexEnvI` bridge operation used by `miniquake.native`.
/// @param target The target input consumed by `glTexEnvI`.
/// @param name Stable name that identifies the requested object or option.
/// @param value Value consumed by `glTexEnvI`.
extern function glTexEnvI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_env_i" returns void
/// Invokes the native `glTexImage2D` bridge operation used by `miniquake.native`.
/// @param target The target input consumed by `glTexImage2D`.
/// @param level The level input consumed by `glTexImage2D`.
/// @param internalFormat The internal format input consumed by `glTexImage2D`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param border The border input consumed by `glTexImage2D`.
/// @param format The format input consumed by `glTexImage2D`.
/// @param type The type input consumed by `glTexImage2D`.
/// @param pixels The pixels input consumed by `glTexImage2D`.
extern function glTexImage2D(target as u32, level as i32, internalFormat as i32, width as i32, height as i32, border as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_image_2d" returns void
/// Invokes the native `glTexSubImage2D` bridge operation used by `miniquake.native`.
/// @param target The target input consumed by `glTexSubImage2D`.
/// @param level The level input consumed by `glTexSubImage2D`.
/// @param xOffset Zero-based offset of the requested data.
/// @param yOffset Zero-based offset of the requested data.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param format The format input consumed by `glTexSubImage2D`.
/// @param type The type input consumed by `glTexSubImage2D`.
/// @param pixels The pixels input consumed by `glTexSubImage2D`.
extern function glTexSubImage2D(target as u32, level as i32, xOffset as i32, yOffset as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_sub_image_2d" returns void
/// Invokes the native `glReadPixels` bridge operation used by `miniquake.native`.
/// @param x The x input consumed by `glReadPixels`.
/// @param y The y input consumed by `glReadPixels`.
/// @param width Requested width in pixels or data units.
/// @param height Requested height in pixels or data units.
/// @param format The format input consumed by `glReadPixels`.
/// @param type The type input consumed by `glReadPixels`.
/// @param pixels The pixels input consumed by `glReadPixels`.
extern function glReadPixels(x as i32, y as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_read_pixels" returns void
/// Invokes the native `glGetStringRaw` bridge operation used by `miniquake.native`.
/// @param name Stable name that identifies the requested object or option.
/// @param output Destination buffer that receives the OpenGL string.
/// @param capacity Maximum number of entries the destination can hold.
/// @returns The `u32` result produced by `glGetStringRaw`.
extern function glGetStringRaw(name as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_gl_get_string" returns u32
/// Invokes the native `glGetError` bridge operation used by `miniquake.native`.
/// @returns The `u32` result produced by `glGetError`.
extern function glGetError() from "miniquake_native.dll" symbol "mq_gl_get_error" returns u32
/// Invokes the native `glFinish` bridge operation used by `miniquake.native`.
extern function glFinish() from "miniquake_native.dll" symbol "mq_gl_finish" returns void
/// Invokes the native `glFlush` bridge operation used by `miniquake.native`.
extern function glFlush() from "miniquake_native.dll" symbol "mq_gl_flush" returns void
/// Invokes the native `glDrawBuffer` bridge operation used by `miniquake.native`.
/// @param mode The mode input consumed by `glDrawBuffer`.
extern function glDrawBuffer(mode as u32) from "miniquake_native.dll" symbol "mq_gl_draw_buffer" returns void
/// Invokes the native `glDrawAliasBatch` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @param shadeDots The shade dots input consumed by `glDrawAliasBatch`.
/// @param shadeDotCount Number of entries or units to process.
/// @param shadeLightBits The shade light bits input consumed by `glDrawAliasBatch`.
/// @returns The `i32` result produced by `glDrawAliasBatch`.
extern function glDrawAliasBatch(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_batch" returns i32
/// Invokes the native `glDrawShadowBatch` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `glDrawShadowBatch`.
extern function glDrawShadowBatch(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_draw_shadow_batch" returns i32
/// Invokes the native `glDrawAliasRayShadow` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @param originX The origin x input consumed by `glDrawAliasRayShadow`.
/// @param originY The origin y input consumed by `glDrawAliasRayShadow`.
/// @param originZ The origin z input consumed by `glDrawAliasRayShadow`.
/// @param angleX The angle x input consumed by `glDrawAliasRayShadow`.
/// @param angleY The angle y input consumed by `glDrawAliasRayShadow`.
/// @param angleZ The angle z input consumed by `glDrawAliasRayShadow`.
/// @param scaleOriginX The scale origin x input consumed by `glDrawAliasRayShadow`.
/// @param scaleOriginY The scale origin y input consumed by `glDrawAliasRayShadow`.
/// @param scaleOriginZ The scale origin z input consumed by `glDrawAliasRayShadow`.
/// @param scaleX The scale x input consumed by `glDrawAliasRayShadow`.
/// @param scaleY The scale y input consumed by `glDrawAliasRayShadow`.
/// @param scaleZ The scale z input consumed by `glDrawAliasRayShadow`.
/// @param doubleEyes The double eyes input consumed by `glDrawAliasRayShadow`.
/// @param pointLightActive The point light active input consumed by `glDrawAliasRayShadow`.
/// @param lightX The light x input consumed by `glDrawAliasRayShadow`.
/// @param lightY The light y input consumed by `glDrawAliasRayShadow`.
/// @param lightZ The light z input consumed by `glDrawAliasRayShadow`.
/// @param sampleX The sample x input consumed by `glDrawAliasRayShadow`.
/// @param sampleY The sample y input consumed by `glDrawAliasRayShadow`.
/// @returns The `i32` result produced by `glDrawAliasRayShadow`.
extern function glDrawAliasRayShadow(data as bytes, byteCount as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, pointLightActive as i32, lightX as u32, lightY as u32, lightZ as u32, sampleX as u32, sampleY as u32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_ray_shadow" returns i32
/// Invokes the native `glDrawParticleBatch` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @param viewOriginX The view origin x input consumed by `glDrawParticleBatch`.
/// @param viewOriginY The view origin y input consumed by `glDrawParticleBatch`.
/// @param viewOriginZ The view origin z input consumed by `glDrawParticleBatch`.
/// @param viewForwardX The view forward x input consumed by `glDrawParticleBatch`.
/// @param viewForwardY The view forward y input consumed by `glDrawParticleBatch`.
/// @param viewForwardZ The view forward z input consumed by `glDrawParticleBatch`.
/// @param viewUpX The view up x input consumed by `glDrawParticleBatch`.
/// @param viewUpY The view up y input consumed by `glDrawParticleBatch`.
/// @param viewUpZ The view up z input consumed by `glDrawParticleBatch`.
/// @param viewRightX The view right x input consumed by `glDrawParticleBatch`.
/// @param viewRightY The view right y input consumed by `glDrawParticleBatch`.
/// @param viewRightZ The view right z input consumed by `glDrawParticleBatch`.
/// @returns The `i32` result produced by `glDrawParticleBatch`.
extern function glDrawParticleBatch(data as bytes, byteCount as u32, viewOriginX as u32, viewOriginY as u32, viewOriginZ as u32, viewForwardX as u32, viewForwardY as u32, viewForwardZ as u32, viewUpX as u32, viewUpY as u32, viewUpZ as u32, viewRightX as u32, viewRightY as u32, viewRightZ as u32) from "miniquake_native.dll" symbol "mq_gl_draw_particle_batch" returns i32
/// Invokes the native `glDrawParticleBatchStyled` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @param viewOriginX The view origin x input consumed by `glDrawParticleBatchStyled`.
/// @param viewOriginY The view origin y input consumed by `glDrawParticleBatchStyled`.
/// @param viewOriginZ The view origin z input consumed by `glDrawParticleBatchStyled`.
/// @param viewForwardX The view forward x input consumed by `glDrawParticleBatchStyled`.
/// @param viewForwardY The view forward y input consumed by `glDrawParticleBatchStyled`.
/// @param viewForwardZ The view forward z input consumed by `glDrawParticleBatchStyled`.
/// @param viewUpX The view up x input consumed by `glDrawParticleBatchStyled`.
/// @param viewUpY The view up y input consumed by `glDrawParticleBatchStyled`.
/// @param viewUpZ The view up z input consumed by `glDrawParticleBatchStyled`.
/// @param viewRightX The view right x input consumed by `glDrawParticleBatchStyled`.
/// @param viewRightY The view right y input consumed by `glDrawParticleBatchStyled`.
/// @param viewRightZ The view right z input consumed by `glDrawParticleBatchStyled`.
/// @returns The `i32` result produced by `glDrawParticleBatchStyled`.
extern function glDrawParticleBatchStyled(data as bytes, byteCount as u32, viewOriginX as u32, viewOriginY as u32, viewOriginZ as u32, viewForwardX as u32, viewForwardY as u32, viewForwardZ as u32, viewUpX as u32, viewUpY as u32, viewUpZ as u32, viewRightX as u32, viewRightY as u32, viewRightZ as u32) from "miniquake_native.dll" symbol "mq_gl_draw_particle_batch_styled" returns i32
/// Invokes the native `glDrawAliasModel` bridge operation used by `miniquake.native`.
/// @param data Input data consumed by the operation.
/// @param byteCount Number of entries or units to process.
/// @param shadeDots The shade dots input consumed by `glDrawAliasModel`.
/// @param shadeDotCount Number of entries or units to process.
/// @param shadeLightBits The shade light bits input consumed by `glDrawAliasModel`.
/// @param originX The origin x input consumed by `glDrawAliasModel`.
/// @param originY The origin y input consumed by `glDrawAliasModel`.
/// @param originZ The origin z input consumed by `glDrawAliasModel`.
/// @param angleX The angle x input consumed by `glDrawAliasModel`.
/// @param angleY The angle y input consumed by `glDrawAliasModel`.
/// @param angleZ The angle z input consumed by `glDrawAliasModel`.
/// @param scaleOriginX The scale origin x input consumed by `glDrawAliasModel`.
/// @param scaleOriginY The scale origin y input consumed by `glDrawAliasModel`.
/// @param scaleOriginZ The scale origin z input consumed by `glDrawAliasModel`.
/// @param scaleX The scale x input consumed by `glDrawAliasModel`.
/// @param scaleY The scale y input consumed by `glDrawAliasModel`.
/// @param scaleZ The scale z input consumed by `glDrawAliasModel`.
/// @param doubleEyes The double eyes input consumed by `glDrawAliasModel`.
/// @param smooth The smooth input consumed by `glDrawAliasModel`.
/// @returns The `i32` result produced by `glDrawAliasModel`.
extern function glDrawAliasModel(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, smooth as i32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_model" returns i32
/// Invokes the native `glDrawAliasModelLerp` bridge operation used by `miniquake.native`.
/// @param previousData The previous data input consumed by `glDrawAliasModelLerp`.
/// @param previousByteCount Number of entries or units to process.
/// @param currentData The current data input consumed by `glDrawAliasModelLerp`.
/// @param currentByteCount Number of entries or units to process.
/// @param fractionBits The fraction bits input consumed by `glDrawAliasModelLerp`.
/// @param shadeDots The shade dots input consumed by `glDrawAliasModelLerp`.
/// @param shadeDotCount Number of entries or units to process.
/// @param shadeLightBits The shade light bits input consumed by `glDrawAliasModelLerp`.
/// @param originX The origin x input consumed by `glDrawAliasModelLerp`.
/// @param originY The origin y input consumed by `glDrawAliasModelLerp`.
/// @param originZ The origin z input consumed by `glDrawAliasModelLerp`.
/// @param angleX The angle x input consumed by `glDrawAliasModelLerp`.
/// @param angleY The angle y input consumed by `glDrawAliasModelLerp`.
/// @param angleZ The angle z input consumed by `glDrawAliasModelLerp`.
/// @param scaleOriginX The scale origin x input consumed by `glDrawAliasModelLerp`.
/// @param scaleOriginY The scale origin y input consumed by `glDrawAliasModelLerp`.
/// @param scaleOriginZ The scale origin z input consumed by `glDrawAliasModelLerp`.
/// @param scaleX The scale x input consumed by `glDrawAliasModelLerp`.
/// @param scaleY The scale y input consumed by `glDrawAliasModelLerp`.
/// @param scaleZ The scale z input consumed by `glDrawAliasModelLerp`.
/// @param doubleEyes The double eyes input consumed by `glDrawAliasModelLerp`.
/// @param smooth The smooth input consumed by `glDrawAliasModelLerp`.
/// @returns The `i32` result produced by `glDrawAliasModelLerp`.
extern function glDrawAliasModelLerp(previousData as bytes, previousByteCount as u32, currentData as bytes, currentByteCount as u32, fractionBits as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, smooth as i32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_model_lerp" returns i32

/// Win64-safe native text bridge.
///
/// The MiniLang v1.0 runtime can pass caller-owned bytes reliably, while a
/// direct extern `returns cstr` may truncate a high-address DLL pointer. Native
/// string producers therefore return a byte count and write into a MiniLang
/// buffer owned by the caller.
/// @param buffer The buffer input consumed by `nativeTextResult`.
/// @param count Number of entries or units to process.
function nativeTextResult(buffer, count)
  if count <= 0 then return "" end if
  if count > len(buffer) then count = len(buffer) end if
  decoded = decode(slice(buffer, 0, count))
  if decoded is void then return "" end if
  return decoded
end function

/// Implements the `f32ToText` operation for `miniquake.native` (f32 to text).
/// @param bits The bits input consumed by `f32ToText`.
function f32ToText(bits)
  output = bytes(64)
  return nativeTextResult(output, f32ToTextRaw(bits, output, len(output)))
end function

/// C printf("%f") boundary used by Cvar_SetValue, ED_Write and version-5
/// savegames.  The native bridge avoids i32 overflow for values such as the
/// stock Quake item bitmask 4097 and preserves negative zero exactly.
/// @param bits The bits input consumed by `f32ToFixed6`.
function f32ToFixed6(bits)
  output = bytes(96)
  return nativeTextResult(output, f32ToFixed6Raw(bits, output, len(output)))
end function

/// Implements the `asciiChar` operation for `miniquake.native` (ascii char).
/// @param value Value consumed by `asciiChar`.
function asciiChar(value)
  output = bytes(2)
  return nativeTextResult(output, asciiCharRaw(value, output, len(output)))
end function

/// Implements the `conprocReadText` operation for `miniquake.native` (conproc read text).
/// @param mapped The mapped input consumed by `conprocReadText`.
/// @param byteOffset Zero-based offset of the requested data.
function conprocReadText(mapped, byteOffset)
  output = bytes(65532)
  return nativeTextResult(output, conprocReadTextRaw(mapped, byteOffset, output, len(output)))
end function

/// Implements the `conprocReadConsoleText` operation for `miniquake.native` (conproc read console text).
/// @param beginLine The begin line input consumed by `conprocReadConsoleText`.
/// @param endLine The end line input consumed by `conprocReadConsoleText`.
function conprocReadConsoleText(beginLine, endLine)
  if endLine < beginLine then return "" end if
  capacity = 80 * (endLine - beginLine + 1)
  if capacity < 1 then return "" end if
  if capacity > 65535 then capacity = 65535 end if
  output = bytes(capacity)
  return nativeTextResult(output, conprocReadConsoleTextRaw(beginLine, endLine, output, capacity))
end function

/// Implements the `udpBoundAddress` operation for `miniquake.native` (udp bound address).
/// @param handle The handle input consumed by `udpBoundAddress`.
function udpBoundAddress(handle)
  output = bytes(64)
  return nativeTextResult(output, udpBoundAddressRaw(handle, output, len(output)))
end function

/// Implements the `udpLastAddress` operation for `miniquake.native` (udp last address).
function udpLastAddress()
  output = bytes(64)
  return nativeTextResult(output, udpLastAddressRaw(output, len(output)))
end function

/// Implements the `udpLocalAddress` operation for `miniquake.native` (udp local address).
function udpLocalAddress()
  output = bytes(64)
  return nativeTextResult(output, udpLocalAddressRaw(output, len(output)))
end function

// Return udp host name derived from the active module state.
function udpHostName()
  output = bytes(256)
  return nativeTextResult(output, udpHostNameRaw(output, len(output)))
end function

/// Return udp resolve name derived from the active module state.
/// @param name Stable name that identifies the requested object or option.
function udpResolveName(name)
  output = bytes(256)
  return nativeTextResult(output, udpResolveNameRaw(name, output, len(output)))
end function

/// Return udp reverse name derived from the active module state.
/// @param address Network address of the peer.
function udpReverseName(address)
  output = bytes(256)
  return nativeTextResult(output, udpReverseNameRaw(address, output, len(output)))
end function

/// Implements the `glGetString` operation for `miniquake.native` (gl get string).
/// @param name Stable name that identifies the requested object or option.
function glGetString(name)
  output = bytes(4096)
  return nativeTextResult(output, glGetStringRaw(name, output, len(output)))
end function

/// Return float bits derived from the active module state.
/// @param value Value consumed by `floatBits`.
function floatBits(value)
  // Avoid number -> text -> strtod.  MiniLang exposes the exact tagged word via
  // nativeRawValue(), and the bridge understands both immediate f32 and boxed
  // f64 numeric values.
  return f32FromRaw(nativeRawValue(value))
end function

/// Implements the `bitsFloat` operation for `miniquake.native` (bits float).
/// @param bits The bits input consumed by `bitsFloat`.
function bitsFloat(bits)
  // Every IEEE-754 binary32 value has MiniLang's compact immediate-float form.
  // Return that raw word and let nativeValueFromRaw() restore the real value.
  return nativeValueFromRaw(f32ToRaw(bits))
end function

/// Implements the `trunc` operation for `miniquake.native` (trunc).
/// @param value Value consumed by `trunc`.
function trunc(value)
  // MiniLang integers are already exact integral values.  Sending them through
  // IEEE-754 binary32 first would round masks and counters above 2^24 (for
  // example 0x12345678 becomes 0x12345680).  Only floating-point values need
  // the native Quake-style truncation path.
  if value is int then return value end if
  return f32ToI32Trunc(floatBits(value))
end function

/// Implements the `floatText` operation for `miniquake.native` (float text).
/// @param value Value consumed by `floatText`.
function floatText(value)
  return f32ToText(floatBits(value))
end function

/// Implements the `fixedSixText` operation for `miniquake.native` (fixed six text).
/// @param value Value consumed by `fixedSixText`.
function fixedSixText(value)
  return f32ToFixed6(floatBits(value))
end function

/// Implements the `sin` operation for `miniquake.native` (sin).
/// @param value Value consumed by `sin`.
function sin(value)
  return bitsFloat(f32Sin(floatBits(value)))
end function

/// Implements the `cos` operation for `miniquake.native` (cos).
/// @param value Value consumed by `cos`.
function cos(value)
  return bitsFloat(f32Cos(floatBits(value)))
end function

/// Implements the `sqrt` operation for `miniquake.native` (sqrt).
/// @param value Value consumed by `sqrt`.
function sqrt(value)
  return bitsFloat(f32Sqrt(floatBits(value)))
end function

/// Implements the `atan2` operation for `miniquake.native` (atan2).
/// @param y The y input consumed by `atan2`.
/// @param x The x input consumed by `atan2`.
function atan2(y, x)
  return bitsFloat(f32Atan2(floatBits(y), floatBits(x)))
end function
/// Invokes the native `glStaticGeometryCall` bridge operation used by `miniquake.native`.
/// @param keyValue The key value input consumed by `glStaticGeometryCall`.
/// @param passValue The pass value input consumed by `glStaticGeometryCall`.
/// @returns The `i32` result produced by `glStaticGeometryCall`.
extern function glStaticGeometryCall(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call" returns i32
/// Invokes the native `glStaticGeometryCallBatch` bridge operation used by `miniquake.native`.
/// @param keys The keys input consumed by `glStaticGeometryCallBatch`.
/// @param byteCount Number of entries or units to process.
/// @param passValue The pass value input consumed by `glStaticGeometryCallBatch`.
/// @returns The `i32` result produced by `glStaticGeometryCallBatch`.
extern function glStaticGeometryCallBatch(keys as bytes, byteCount as u32, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_batch" returns i32
/// Invokes the native `glStaticGeometryCallMultitextureBatch` bridge operation used by `miniquake.native`.
/// @param records The records input consumed by `glStaticGeometryCallMultitextureBatch`.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `glStaticGeometryCallMultitextureBatch`.
extern function glStaticGeometryCallMultitextureBatch(records as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_multitexture_batch" returns i32
/// Invokes the native `glStaticGeometryPrepare` bridge operation used by `miniquake.native`.
/// @param keyValue The key value input consumed by `glStaticGeometryPrepare`.
/// @param passValue The pass value input consumed by `glStaticGeometryPrepare`.
/// @returns The `i32` result produced by `glStaticGeometryPrepare`.
extern function glStaticGeometryPrepare(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_prepare" returns i32
/// Invokes the native `glStaticGeometryClear` bridge operation used by `miniquake.native`.
extern function glStaticGeometryClear() from "miniquake_native.dll" symbol "mq_gl_static_geometry_clear" returns void
/// Invokes the native `glMultitextureAvailable` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `glMultitextureAvailable`.
extern function glMultitextureAvailable() from "miniquake_native.dll" symbol "mq_gl_multitexture_available" returns i32
/// Invokes the native `glWorldProgramAvailable` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `glWorldProgramAvailable`.
extern function glWorldProgramAvailable() from "miniquake_native.dll" symbol "mq_gl_world_program_available" returns i32
/// Invokes the native `glWorldProgramEnable` bridge operation used by `miniquake.native`.
/// @param enabled Whether the optional behavior is enabled.
extern function glWorldProgramEnable(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_world_program_enable" returns void
/// Invokes the native `glEnhancedAvailable` bridge operation used by `miniquake.native`.
/// @returns The `i32` result produced by `glEnhancedAvailable`.
extern function glEnhancedAvailable() from "miniquake_native.dll" symbol "mq_gl_enhanced_available" returns i32
/// Invokes the native `glEnhancedConfigure` bridge operation used by `miniquake.native`.
/// @param enabled Whether the optional behavior is enabled.
/// @param shadows The shadows input consumed by `glEnhancedConfigure`.
/// @param shadowQuality The shadow quality input consumed by `glEnhancedConfigure`.
/// @returns The `i32` result produced by `glEnhancedConfigure`.
extern function glEnhancedConfigure(enabled as i32, shadows as i32, shadowQuality as i32) from "miniquake_native.dll" symbol "mq_gl_enhanced_configure" returns i32
/// Invokes the native `glEnhancedBeginFrame` bridge operation used by `miniquake.native`.
/// @param lights The lights input consumed by `glEnhancedBeginFrame`.
/// @param byteCount Number of entries or units to process.
/// @returns The `i32` result produced by `glEnhancedBeginFrame`.
extern function glEnhancedBeginFrame(lights as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_enhanced_begin_frame" returns i32
/// Invokes the native `glEnhancedDrawKind` bridge operation used by `miniquake.native`.
/// @param kind The kind input consumed by `glEnhancedDrawKind`.
extern function glEnhancedDrawKind(kind as i32) from "miniquake_native.dll" symbol "mq_gl_enhanced_draw_kind" returns void
/// Invokes the native `glEnhancedEndFrame` bridge operation used by `miniquake.native`.
extern function glEnhancedEndFrame() from "miniquake_native.dll" symbol "mq_gl_enhanced_end_frame" returns void
/// Invokes the native `glActiveTexture` bridge operation used by `miniquake.native`.
/// @param unit The unit input consumed by `glActiveTexture`.
extern function glActiveTexture(unit as i32) from "miniquake_native.dll" symbol "mq_gl_active_texture" returns void
/// Invokes the native `glMultiTexCoord2` bridge operation used by `miniquake.native`.
/// @param unit The unit input consumed by `glMultiTexCoord2`.
/// @param sBits The s bits input consumed by `glMultiTexCoord2`.
/// @param tBits The t bits input consumed by `glMultiTexCoord2`.
extern function glMultiTexCoord2(unit as i32, sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_multi_tex_coord2" returns void
