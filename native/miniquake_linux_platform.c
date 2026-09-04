/*
 * MiniQuake Linux x64 platform bridge.
 *
 * Copyright (c) 1996-1997 Id Software, Inc.
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * SDL2 owns the desktop-facing services while POSIX supplies networking,
 * timing, memory protection and the dedicated console.  The renderer itself
 * remains in miniquake_native.c so Windows and Linux execute the same OpenGL
 * batching, lighting and projected-shadow code.
 */
#define _POSIX_C_SOURCE 200809L

#if !defined(__linux__)
#error "miniquake_linux_platform.c is only for Linux"
#endif

#include "miniquake_native.h"

#include <arpa/inet.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <poll.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

/* Minimal SDL2 ABI declarations keep the build independent of development
 * headers; Ubuntu's normal desktop/runtime package already provides the ABI. */
typedef struct SDL_Window SDL_Window;
typedef struct SDL_GameController SDL_GameController;
typedef mq_u32 SDL_AudioDeviceID;
/* Minimal binary-compatible SDL display-mode record. */
typedef struct SDL_DisplayMode {
    mq_u32 format;
    mq_i32 w;
    mq_i32 h;
    mq_i32 refresh_rate;
    void *driverdata;
} SDL_DisplayMode;
/* Minimal binary-compatible SDL queued-audio configuration. */
typedef struct SDL_AudioSpec {
    mq_i32 freq;
    mq_u16 format;
    mq_u8 channels;
    mq_u8 silence;
    mq_u16 samples;
    mq_u16 padding;
    mq_u32 size;
    void (*callback)(void *, mq_u8 *, mq_i32);
    void *userdata;
} SDL_AudioSpec;
/* SDL guarantees a 56-byte event union on the supported x86-64 ABI. */
typedef union SDL_Event {
    mq_u32 type;
    mq_u8 padding[56];
} SDL_Event;

extern mq_i32 SDL_Init(mq_u32 flags);
extern void SDL_QuitSubSystem(mq_u32 flags);
extern const char *SDL_GetError(void);
extern mq_i32 SDL_GL_SetAttribute(mq_i32 attribute, mq_i32 value);
extern SDL_Window *SDL_CreateWindow(const char *title, mq_i32 x, mq_i32 y, mq_i32 w, mq_i32 h, mq_u32 flags);
extern void SDL_DestroyWindow(SDL_Window *window);
extern void *SDL_GL_CreateContext(SDL_Window *window);
extern void SDL_GL_DeleteContext(void *context);
extern mq_i32 SDL_GL_MakeCurrent(SDL_Window *window, void *context);
extern void SDL_GL_SwapWindow(SDL_Window *window);
extern mq_i32 SDL_GL_SetSwapInterval(mq_i32 interval);
extern mq_i32 SDL_PollEvent(SDL_Event *event);
extern void SDL_GetWindowSize(SDL_Window *window, mq_i32 *width, mq_i32 *height);
extern void SDL_SetWindowSize(SDL_Window *window, mq_i32 width, mq_i32 height);
extern void SDL_GetWindowPosition(SDL_Window *window, mq_i32 *x, mq_i32 *y);
extern void SDL_SetWindowTitle(SDL_Window *window, const char *title);
extern mq_i32 SDL_SetWindowFullscreen(SDL_Window *window, mq_u32 flags);
extern mq_u32 SDL_GetWindowFlags(SDL_Window *window);
extern mq_i32 SDL_GetWindowDisplayIndex(SDL_Window *window);
extern mq_i32 SDL_GetNumDisplayModes(mq_i32 display_index);
extern mq_i32 SDL_GetDisplayMode(mq_i32 display_index, mq_i32 mode_index, SDL_DisplayMode *mode);
extern mq_i32 SDL_GetCurrentDisplayMode(mq_i32 display_index, SDL_DisplayMode *mode);
extern mq_i32 SDL_SetWindowDisplayMode(SDL_Window *window, const SDL_DisplayMode *mode);
extern mq_i32 SDL_GetWindowGammaRamp(SDL_Window *window, mq_u16 *red, mq_u16 *green, mq_u16 *blue);
extern mq_i32 SDL_SetWindowGammaRamp(SDL_Window *window, const mq_u16 *red, const mq_u16 *green, const mq_u16 *blue);
extern mq_i32 SDL_SetRelativeMouseMode(mq_i32 enabled);
extern mq_i32 SDL_ShowCursor(mq_i32 toggle);
extern void SDL_WarpMouseInWindow(SDL_Window *window, mq_i32 x, mq_i32 y);
extern mq_u32 SDL_GetMouseState(mq_i32 *x, mq_i32 *y);
extern mq_u32 SDL_GetTicks(void);
extern mq_u64 SDL_GetPerformanceCounter(void);
extern mq_u64 SDL_GetPerformanceFrequency(void);
extern void SDL_Delay(mq_u32 milliseconds);
extern SDL_AudioDeviceID SDL_OpenAudioDevice(const char *device, mq_i32 capture, const SDL_AudioSpec *desired, SDL_AudioSpec *obtained, mq_i32 allowed_changes);
extern void SDL_CloseAudioDevice(SDL_AudioDeviceID device);
extern void SDL_PauseAudioDevice(SDL_AudioDeviceID device, mq_i32 pause_on);
extern mq_i32 SDL_QueueAudio(SDL_AudioDeviceID device, const void *data, mq_u32 length);
extern mq_u32 SDL_GetQueuedAudioSize(SDL_AudioDeviceID device);
extern void SDL_ClearQueuedAudio(SDL_AudioDeviceID device);
extern mq_i32 SDL_NumJoysticks(void);
extern mq_i32 SDL_IsGameController(mq_i32 index);
extern SDL_GameController *SDL_GameControllerOpen(mq_i32 index);
extern void SDL_GameControllerClose(SDL_GameController *controller);
extern mq_i16 SDL_GameControllerGetAxis(SDL_GameController *controller, mq_i32 axis);
extern mq_u8 SDL_GameControllerGetButton(SDL_GameController *controller, mq_i32 button);

extern void mq_linux_gl_initialize_extensions(void);
extern void mq_gl_static_geometry_clear(void);

#define SDL_INIT_TIMER          0x00000001u
#define SDL_INIT_AUDIO          0x00000010u
#define SDL_INIT_VIDEO          0x00000020u
#define SDL_INIT_GAMECONTROLLER 0x00002000u
#define SDL_WINDOWPOS_CENTERED  0x2FFF0000u
#define SDL_WINDOW_OPENGL       0x00000002u
#define SDL_WINDOW_SHOWN        0x00000004u
#define SDL_WINDOW_RESIZABLE    0x00000020u
#define SDL_WINDOW_MINIMIZED    0x00000040u
#define SDL_WINDOW_INPUT_FOCUS  0x00000200u
#define SDL_WINDOW_FULLSCREEN   0x00000001u
#define SDL_WINDOW_FULLSCREEN_DESKTOP 0x00001001u
#define SDL_GL_DOUBLEBUFFER     5
#define SDL_GL_DEPTH_SIZE       6
#define SDL_GL_CONTEXT_MAJOR_VERSION 17
#define SDL_GL_CONTEXT_MINOR_VERSION 18
#define SDL_GL_CONTEXT_PROFILE_MASK 21
#define SDL_GL_CONTEXT_PROFILE_COMPATIBILITY 0x0002
#define SDL_QUIT                0x100u
#define SDL_WINDOWEVENT         0x200u
#define SDL_KEYDOWN             0x300u
#define SDL_KEYUP               0x301u
#define SDL_TEXTINPUT           0x303u
#define SDL_MOUSEMOTION         0x400u
#define SDL_MOUSEBUTTONDOWN     0x401u
#define SDL_MOUSEBUTTONUP       0x402u
#define SDL_MOUSEWHEEL          0x403u
#define SDL_WINDOWEVENT_SIZE_CHANGED 6u
#define SDL_WINDOWEVENT_MINIMIZED 7u
#define SDL_WINDOWEVENT_RESTORED 9u
#define SDL_WINDOWEVENT_FOCUS_GAINED 12u
#define SDL_WINDOWEVENT_FOCUS_LOST 13u
#define SDL_WINDOWEVENT_CLOSE 14u
#define SDL_BUTTON_LEFT 1u
#define SDL_BUTTON_MIDDLE 2u
#define SDL_BUTTON_RIGHT 3u
#define SDL_AUDIO_U8 0x0008u
#define SDL_AUDIO_S16LSB 0x8010u
#define MQ_INPUT_EVENT_MOUSE 2u
#define MQ_INPUT_EVENT_WHEEL 3u
#define MQ_INPUT_EVENT_FOCUS 4u
#define MQ_INPUT_EVENT_SCAN_KEY 5u
#define MQ_INPUT_QUEUE_CAPACITY 512u
#define MQ_TEXT_QUEUE_CAPACITY 128u
#define MQ_DISPLAY_MODE_CAPACITY 256u
#define MQ_AUDIO_BLOCK_BYTES 16384u
#define MQ_AUDIO_CAPACITY 8u

static SDL_Window *mq_window;
static void *mq_gl_context;
static mq_i32 mq_running;
static mq_i32 mq_active;
static mq_i32 mq_minimized;
static mq_i32 mq_width;
static mq_i32 mq_height;
static mq_i32 mq_window_x;
static mq_i32 mq_window_y;
static mq_i32 mq_fullscreen;
static mq_i32 mq_mouse_dx;
static mq_i32 mq_mouse_dy;
static mq_i32 mq_mouse_wheel;
static mq_i32 mq_mouse_captured;
static mq_u8 mq_key_down[256];
static mq_u8 mq_key_pressed[256];
static mq_u8 mq_mouse_down[3];
static mq_u32 mq_input_queue[MQ_INPUT_QUEUE_CAPACITY];
static mq_u32 mq_input_head;
static mq_u32 mq_input_tail;
static mq_u16 mq_text_queue[MQ_TEXT_QUEUE_CAPACITY];
static mq_u32 mq_text_head;
static mq_u32 mq_text_tail;
static SDL_DisplayMode mq_display_modes[MQ_DISPLAY_MODE_CAPACITY];
static mq_u32 mq_display_mode_count;
static SDL_GameController *mq_controller;
static SDL_AudioDeviceID mq_audio_device;
static mq_u32 mq_audio_bytes_per_sample;
static mq_u64 mq_audio_submitted_bytes;
static mq_u32 mq_audio_submitted_blocks;
static mq_u32 mq_audio_underrun_count;
static char mq_udp_last_address_text[64] = "0.0.0.0";
static char mq_udp_bound_address_text[64] = "0.0.0.0";
static char mq_udp_local_address_text[64] = "127.0.0.1";
static char mq_udp_host_name_text[256] = "";
static char mq_udp_resolved_address_text[64] = "";
static char mq_udp_reverse_name_text[256] = "";
static mq_u32 mq_udp_last_port_value;
static mq_i32 mq_udp_last_error_value;

/* Read little-endian event fields without depending on SDL header layouts. */
static mq_u32 mq_event_u32(const SDL_Event *event, mq_u32 offset) {
    mq_u32 value;
    memcpy(&value, event->padding + offset, sizeof(value));
    return value;
}

/* Map SDL USB scancodes onto the PC set-1 values consumed by Quake. */
static mq_u32 mq_pc_scancode(mq_u32 code) {
    static const mq_u8 letters[26] = {
        30,48,46,32,18,33,34,35,23,36,37,38,50,49,24,25,16,19,31,20,22,47,17,45,21,44
    };
    static const mq_u8 digits[10] = {2,3,4,5,6,7,8,9,10,11};
    if (code >= 4u && code <= 29u) return letters[code - 4u];
    if (code >= 30u && code <= 39u) return digits[code - 30u];
    if (code >= 58u && code <= 67u) return 59u + code - 58u;
    if (code == 68u) return 87u;
    if (code == 69u) return 88u;
    switch (code) {
        case 40: return 28; case 41: return 1; case 42: return 14; case 43: return 15;
        case 44: return 57; case 45: return 12; case 46: return 13; case 47: return 26;
        case 48: return 27; case 49: return 43; case 51: return 39; case 52: return 40;
        case 53: return 41; case 54: return 51; case 55: return 52; case 56: return 53;
        case 57: return 58; case 70: return 55; case 71: return 70; case 72: return 69;
        case 73: return 82; case 74: return 71; case 75: return 73; case 76: return 83;
        case 77: return 79; case 78: return 81; case 79: return 77; case 80: return 75;
        case 81: return 80; case 82: return 72; case 83: return 69; case 84: return 53;
        case 85: return 55; case 86: return 74; case 87: return 78; case 88: return 28;
        case 89: return 79; case 90: return 80; case 91: return 81; case 92: return 75;
        case 93: return 76; case 94: return 77; case 95: return 71; case 96: return 72;
        case 97: return 73; case 98: return 82; case 99: return 83; case 224: return 29;
        case 225: return 42; case 226: return 56; case 228: return 29; case 229: return 54;
        case 230: return 56; default: return 0;
    }
}

/* Map SDL scancodes to the Win32 virtual-key vocabulary used by snapshots. */
static mq_u32 mq_virtual_key(mq_u32 code) {
    if (code >= 4u && code <= 29u) return (mq_u32)('A' + code - 4u);
    if (code >= 30u && code <= 38u) return (mq_u32)('1' + code - 30u);
    if (code == 39u) return '0';
    if (code >= 58u && code <= 69u) return 0x70u + code - 58u;
    switch (code) {
        case 40: return 0x0D; case 41: return 0x1B; case 42: return 0x08; case 43: return 0x09;
        case 44: return 0x20; case 73: return 0x2D; case 74: return 0x24; case 75: return 0x21;
        case 76: return 0x2E; case 77: return 0x23; case 78: return 0x22; case 79: return 0x27;
        case 80: return 0x25; case 81: return 0x28; case 82: return 0x26;
        case 224: case 228: return 0x11; case 225: case 229: return 0x10;
        case 226: case 230: return 0x12; default: return 0;
    }
}

/* Queue one packed input event while retaining the newest events on overflow. */
static void mq_push_input(mq_u32 type, mq_u32 code, mq_i32 value) {
    mq_u32 next = (mq_input_head + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    if (next == mq_input_tail) mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    mq_input_queue[mq_input_head] = ((type & 255u) << 24) | ((code & 65535u) << 8) | ((mq_u32)value & 255u);
    mq_input_head = next;
}

/* Queue one Unicode text code point for the MiniLang console. */
static void mq_push_text_codepoint(mq_u32 code) {
    mq_u32 next;
    if (code == 0 || code > 0xFFFFu) return;
    next = (mq_text_head + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    if (next == mq_text_tail) mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    mq_text_queue[mq_text_head] = (mq_u16)code;
    mq_text_head = next;
}

/* Release every active key and mouse button after focus loss. */
static void mq_release_input(void) {
    mq_u32 i;
    for (i = 0; i < 256u; ++i) {
        if (mq_key_down[i]) { mq_key_down[i] = 0; mq_push_input(MQ_INPUT_EVENT_SCAN_KEY, i, 0); }
    }
    for (i = 0; i < 3u; ++i) {
        if (mq_mouse_down[i]) { mq_mouse_down[i] = 0; mq_push_input(MQ_INPUT_EVENT_MOUSE, i, 0); }
    }
}

/* Decode the first UTF-8 code point delivered by an SDL text event. */
static mq_u32 mq_decode_utf8_first(const char *text) {
    const mq_u8 *s = (const mq_u8 *)text;
    if (!s || !s[0]) return 0;
    if (s[0] < 0x80u) return s[0];
    if ((s[0] & 0xE0u) == 0xC0u && s[1]) return ((s[0] & 31u) << 6) | (s[1] & 63u);
    if ((s[0] & 0xF0u) == 0xE0u && s[1] && s[2]) return ((s[0] & 15u) << 12) | ((s[1] & 63u) << 6) | (s[2] & 63u);
    return 0;
}

/* Yield for one millisecond while emulating the legacy QHOST event wait. */
static void mq_wait_one_millisecond(void) {
    struct timespec request = { 0, 1000000L };
    nanosleep(&request, 0);
}

/* Dispatch one SDL event into MiniQuake's stable native event queues. */
static void mq_dispatch_event(const SDL_Event *event) {
    mq_u32 type = event->type;
    if (type == SDL_QUIT) { mq_running = 0; return; }
    if (type == SDL_WINDOWEVENT) {
        mq_u8 kind = event->padding[12];
        if (kind == SDL_WINDOWEVENT_CLOSE) mq_running = 0;
        else if (kind == SDL_WINDOWEVENT_SIZE_CHANGED) {
            mq_width = (mq_i32)mq_event_u32(event, 16); mq_height = (mq_i32)mq_event_u32(event, 20);
        } else if (kind == SDL_WINDOWEVENT_MINIMIZED) mq_minimized = 1;
        else if (kind == SDL_WINDOWEVENT_RESTORED) mq_minimized = 0;
        else if (kind == SDL_WINDOWEVENT_FOCUS_GAINED) { mq_active = 1; mq_push_input(MQ_INPUT_EVENT_FOCUS, 0, 1); }
        else if (kind == SDL_WINDOWEVENT_FOCUS_LOST) { mq_active = 0; mq_release_input(); mq_push_input(MQ_INPUT_EVENT_FOCUS, 0, 0); }
        return;
    }
    if (type == SDL_KEYDOWN || type == SDL_KEYUP) {
        mq_u32 sdl_scan = mq_event_u32(event, 16);
        mq_u32 scan = mq_pc_scancode(sdl_scan);
        mq_u32 vk = mq_virtual_key(sdl_scan);
        mq_i32 down = type == SDL_KEYDOWN;
        mq_i32 repeat = event->padding[13] != 0;
        if (scan != 0 && (!repeat || !down)) mq_push_input(MQ_INPUT_EVENT_SCAN_KEY, scan, down);
        if (vk < 256u) {
            if (down && !mq_key_down[vk]) mq_key_pressed[vk] = 1;
            mq_key_down[vk] = (mq_u8)down;
        }
        return;
    }
    if (type == SDL_TEXTINPUT) { mq_push_text_codepoint(mq_decode_utf8_first((const char *)event->padding + 12)); return; }
    if (type == SDL_MOUSEMOTION) {
        if (mq_mouse_captured) { mq_mouse_dx += (mq_i32)mq_event_u32(event, 28); mq_mouse_dy += (mq_i32)mq_event_u32(event, 32); }
        return;
    }
    if (type == SDL_MOUSEBUTTONDOWN || type == SDL_MOUSEBUTTONUP) {
        mq_u8 button = event->padding[16];
        mq_i32 index = button == SDL_BUTTON_LEFT ? 0 : (button == SDL_BUTTON_RIGHT ? 1 : (button == SDL_BUTTON_MIDDLE ? 2 : -1));
        mq_i32 down = type == SDL_MOUSEBUTTONDOWN;
        if (index >= 0) { mq_mouse_down[index] = (mq_u8)down; mq_key_down[index == 0 ? 1 : (index == 1 ? 2 : 4)] = (mq_u8)down; mq_push_input(MQ_INPUT_EVENT_MOUSE, (mq_u32)index, down); }
        return;
    }
    if (type == SDL_MOUSEWHEEL) {
        mq_i32 delta = (mq_i32)mq_event_u32(event, 20);
        if (mq_event_u32(event, 24) != 0u) delta = -delta;
        mq_mouse_wheel += delta;
        while (delta > 0) { mq_push_input(MQ_INPUT_EVENT_WHEEL, 0, 1); --delta; }
        while (delta < 0) { mq_push_input(MQ_INPUT_EVENT_WHEEL, 0, -1); ++delta; }
    }
}

/* Create the SDL window and compatibility-profile OpenGL context. */
MQ_EXPORT mq_ptr mq_win_create(const char *title, mq_i32 width, mq_i32 height, mq_i32 fullscreen) {
    mq_u32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE;
    if (mq_window) return mq_window;
    if (width < 1) width = 640;
    if (height < 1) height = 480;
    if (SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER) != 0) return 0;
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
    if (fullscreen) flags |= SDL_WINDOW_FULLSCREEN;
    mq_window = SDL_CreateWindow(title && title[0] ? title : "MiniQuake", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, flags);
    if (!mq_window) { SDL_QuitSubSystem(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER | SDL_INIT_TIMER); return 0; }
    mq_gl_context = SDL_GL_CreateContext(mq_window);
    if (!mq_gl_context) { SDL_DestroyWindow(mq_window); mq_window = 0; SDL_QuitSubSystem(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER | SDL_INIT_TIMER); return 0; }
    SDL_GL_MakeCurrent(mq_window, mq_gl_context);
    SDL_GL_SetSwapInterval(0);
    mq_linux_gl_initialize_extensions();
    mq_width = width; mq_height = height; mq_fullscreen = fullscreen != 0;
    mq_running = 1; mq_active = 1; mq_minimized = 0;
    SDL_GetWindowPosition(mq_window, &mq_window_x, &mq_window_y);
    memset(mq_key_down, 0, sizeof(mq_key_down)); memset(mq_key_pressed, 0, sizeof(mq_key_pressed));
    mq_input_head = mq_input_tail = mq_text_head = mq_text_tail = 0;
    return mq_window;
}

/* Release every SDL window, graphics, controller and audio resource. */
MQ_EXPORT void mq_win_destroy(void) {
    mq_win_set_cursor_capture(0);
    mq_gl_static_geometry_clear();
    if (mq_controller) { SDL_GameControllerClose(mq_controller); mq_controller = 0; }
    if (mq_audio_device) { SDL_ClearQueuedAudio(mq_audio_device); SDL_CloseAudioDevice(mq_audio_device); mq_audio_device = 0; }
    if (mq_gl_context) { SDL_GL_DeleteContext(mq_gl_context); mq_gl_context = 0; }
    if (mq_window) { SDL_DestroyWindow(mq_window); mq_window = 0; }
    SDL_QuitSubSystem(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER | SDL_INIT_TIMER);
    mq_running = mq_active = 0;
}

/* Drain pending SDL events into MiniQuake's stable input queues. */
MQ_EXPORT mq_i32 mq_win_poll(void) { SDL_Event event; while (SDL_PollEvent(&event)) mq_dispatch_event(&event); return mq_running; }
/* Present the current OpenGL back buffer. */
MQ_EXPORT void mq_win_swap(void) { if (mq_window && mq_gl_context) SDL_GL_SwapWindow(mq_window); }
/* Implement the Linux win set swap interval native bridge operation. */
MQ_EXPORT mq_i32 mq_win_set_swap_interval(mq_i32 interval) { return SDL_GL_SetSwapInterval(interval) == 0; }
/* Implement the Linux win key down native bridge operation. */
MQ_EXPORT mq_i32 mq_win_key_down(mq_i32 key) { return key >= 0 && key < 256 ? mq_key_down[key] != 0 : 0; }
/* Implement the Linux win key pressed native bridge operation. */
MQ_EXPORT mq_i32 mq_win_key_pressed(mq_i32 key) { mq_i32 result = key >= 0 && key < 256 ? mq_key_pressed[key] != 0 : 0; if (key >= 0 && key < 256) mq_key_pressed[key] = 0; return result; }
/* Implement the Linux win key snapshot native bridge operation. */
MQ_EXPORT mq_i32 mq_win_key_snapshot(mq_u8 *down, mq_u8 *pressed, const mq_u8 *mask, mq_u32 count) {
    mq_u32 i; if (!down || !pressed || !mask) return 0; if (count > 256u) count = 256u;
    for (i = 0; i < count; ++i) { down[i] = mask[i] ? mq_key_down[i] : 0; pressed[i] = mq_key_pressed[i]; mq_key_pressed[i] = 0; }
    return (mq_i32)count;
}
/* Implement the Linux win text pop native bridge operation. */
MQ_EXPORT mq_i32 mq_win_text_pop(void) { mq_i32 value; if (mq_text_tail == mq_text_head) return -1; value = mq_text_queue[mq_text_tail]; mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY; return value; }
/* Implement the Linux win has focus native bridge operation. */
MQ_EXPORT mq_i32 mq_win_has_focus(void) { return mq_active; }
/* Implement the Linux win client width native bridge operation. */
MQ_EXPORT mq_i32 mq_win_client_width(void) { if (mq_window) SDL_GetWindowSize(mq_window, &mq_width, &mq_height); return mq_width; }
/* Implement the Linux win client height native bridge operation. */
MQ_EXPORT mq_i32 mq_win_client_height(void) { if (mq_window) SDL_GetWindowSize(mq_window, &mq_width, &mq_height); return mq_height; }
/* Implement the Linux win resize client native bridge operation. */
MQ_EXPORT mq_i32 mq_win_resize_client(mq_i32 width, mq_i32 height) { if (!mq_window || width < 1 || height < 1) return 0; SDL_SetWindowSize(mq_window, width, height); mq_width = width; mq_height = height; return 1; }
/* Implement the Linux win window x native bridge operation. */
MQ_EXPORT mq_i32 mq_win_window_x(void) { if (mq_window) SDL_GetWindowPosition(mq_window, &mq_window_x, &mq_window_y); return mq_window_x; }
/* Implement the Linux win window y native bridge operation. */
MQ_EXPORT mq_i32 mq_win_window_y(void) { if (mq_window) SDL_GetWindowPosition(mq_window, &mq_window_x, &mq_window_y); return mq_window_y; }
/* Implement the Linux win is minimized native bridge operation. */
MQ_EXPORT mq_i32 mq_win_is_minimized(void) { if (mq_window) mq_minimized = (SDL_GetWindowFlags(mq_window) & SDL_WINDOW_MINIMIZED) != 0; return mq_minimized; }
/* Implement the Linux win desktop width native bridge operation. */
MQ_EXPORT mq_i32 mq_win_desktop_width(void) { SDL_DisplayMode mode; return SDL_GetCurrentDisplayMode(0, &mode) == 0 ? mode.w : 0; }
/* Implement the Linux win desktop height native bridge operation. */
MQ_EXPORT mq_i32 mq_win_desktop_height(void) { SDL_DisplayMode mode; return SDL_GetCurrentDisplayMode(0, &mode) == 0 ? mode.h : 0; }

/* Implement the Linux win display mode count native bridge operation. */
MQ_EXPORT mq_u32 mq_win_display_mode_count(void) {
    mq_i32 display = mq_window ? SDL_GetWindowDisplayIndex(mq_window) : 0;
    mq_i32 count = SDL_GetNumDisplayModes(display), i;
    mq_display_mode_count = 0;
    for (i = 0; i < count && mq_display_mode_count < MQ_DISPLAY_MODE_CAPACITY; ++i)
        if (SDL_GetDisplayMode(display, i, &mq_display_modes[mq_display_mode_count]) == 0) ++mq_display_mode_count;
    return mq_display_mode_count;
}
/* Implement the Linux win display mode width native bridge operation. */
MQ_EXPORT mq_i32 mq_win_display_mode_width(mq_u32 index) { return index < mq_display_mode_count ? mq_display_modes[index].w : 0; }
/* Implement the Linux win display mode height native bridge operation. */
MQ_EXPORT mq_i32 mq_win_display_mode_height(mq_u32 index) { return index < mq_display_mode_count ? mq_display_modes[index].h : 0; }
/* Implement the Linux win display mode bpp native bridge operation. */
MQ_EXPORT mq_i32 mq_win_display_mode_bpp(mq_u32 index) { (void)index; return 32; }
/* Implement the Linux win display mode frequency native bridge operation. */
MQ_EXPORT mq_i32 mq_win_display_mode_frequency(mq_u32 index) { return index < mq_display_mode_count ? mq_display_modes[index].refresh_rate : 0; }
/* Implement the Linux win test display mode native bridge operation. */
MQ_EXPORT mq_i32 mq_win_test_display_mode(mq_i32 width, mq_i32 height, mq_i32 bpp, mq_i32 frequency) { (void)bpp; (void)frequency; return width > 0 && height > 0; }
/* Implement the Linux win configure display mode native bridge operation. */
MQ_EXPORT mq_i32 mq_win_configure_display_mode(mq_i32 width, mq_i32 height, mq_i32 bpp, mq_i32 frequency, mq_i32 fullscreen, mq_i32 use_current) {
    SDL_DisplayMode mode; (void)bpp;
    if (width < 1 || height < 1) return 0;
    memset(&mode, 0, sizeof(mode)); mode.w = width; mode.h = height; mode.refresh_rate = frequency;
    if (mq_window && fullscreen && !use_current && SDL_SetWindowDisplayMode(mq_window, &mode) != 0) return 0;
    mq_width = width; mq_height = height; mq_fullscreen = fullscreen != 0;
    return 1;
}
/* Implement the Linux win restore display mode native bridge operation. */
MQ_EXPORT void mq_win_restore_display_mode(void) { if (mq_window && mq_fullscreen) SDL_SetWindowFullscreen(mq_window, 0); mq_fullscreen = 0; }
/* Implement the Linux win get gamma ramp native bridge operation. */
MQ_EXPORT mq_i32 mq_win_get_gamma_ramp(mq_u8 *ramp, mq_u32 bytes) { if (!mq_window || !ramp || bytes < 1536u) return 0; return SDL_GetWindowGammaRamp(mq_window, (mq_u16 *)ramp, (mq_u16 *)(ramp + 512), (mq_u16 *)(ramp + 1024)) == 0; }
/* Implement the Linux win set gamma ramp native bridge operation. */
MQ_EXPORT mq_i32 mq_win_set_gamma_ramp(const mq_u8 *ramp, mq_u32 bytes) { if (!mq_window || !ramp || bytes < 1536u) return 0; return SDL_SetWindowGammaRamp(mq_window, (const mq_u16 *)ramp, (const mq_u16 *)(ramp + 512), (const mq_u16 *)(ramp + 1024)) == 0; }
/* Implement the Linux win context ready native bridge operation. */
MQ_EXPORT mq_i32 mq_win_context_ready(void) { return mq_window && mq_gl_context; }
/* Implement the Linux win make current native bridge operation. */
MQ_EXPORT mq_i32 mq_win_make_current(void) { return mq_window && mq_gl_context && SDL_GL_MakeCurrent(mq_window, mq_gl_context) == 0; }
/* Implement the Linux win activate native bridge operation. */
MQ_EXPORT void mq_win_activate(mq_i32 active, mq_i32 minimized) { mq_active = active != 0; mq_minimized = minimized != 0; }
/* Implement the Linux win set title native bridge operation. */
MQ_EXPORT void mq_win_set_title(const char *title) { if (mq_window) SDL_SetWindowTitle(mq_window, title ? title : ""); }
/* Implement the Linux win set cursor capture native bridge operation. */
MQ_EXPORT void mq_win_set_cursor_capture(mq_i32 enabled) { mq_mouse_captured = enabled != 0; SDL_SetRelativeMouseMode(mq_mouse_captured); mq_mouse_dx = mq_mouse_dy = 0; }
/* Implement the Linux win mouse dx native bridge operation. */
MQ_EXPORT mq_i32 mq_win_mouse_dx(void) { mq_i32 value = mq_mouse_dx; mq_mouse_dx = 0; return value; }
/* Implement the Linux win mouse dy native bridge operation. */
MQ_EXPORT mq_i32 mq_win_mouse_dy(void) { mq_i32 value = mq_mouse_dy; mq_mouse_dy = 0; return value; }
/* Implement the Linux win mouse buttons native bridge operation. */
MQ_EXPORT mq_i32 mq_win_mouse_buttons(void) { return (mq_mouse_down[0] ? 1 : 0) | (mq_mouse_down[1] ? 2 : 0) | (mq_mouse_down[2] ? 4 : 0); }
/* Implement the Linux win mouse wheel native bridge operation. */
MQ_EXPORT mq_i32 mq_win_mouse_wheel(void) { mq_i32 value = mq_mouse_wheel; mq_mouse_wheel = 0; return value; }
/* Implement the Linux win input event pop native bridge operation. */
MQ_EXPORT mq_u32 mq_win_input_event_pop(void) { mq_u32 value; if (mq_input_tail == mq_input_head) return 0; value = mq_input_queue[mq_input_tail]; mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY; return value; }
/* Implement the Linux win input test push native bridge operation. */
MQ_EXPORT void mq_win_input_test_push(mq_u32 type, mq_u32 code, mq_i32 value) { mq_push_input(type, code, value); }
/* Implement the Linux win cursor show native bridge operation. */
MQ_EXPORT void mq_win_cursor_show(mq_i32 show) { SDL_ShowCursor(show ? 1 : 0); }
/* Implement the Linux win cursor center native bridge operation. */
MQ_EXPORT mq_i32 mq_win_cursor_center(void) {
    if (!mq_window) return 0;
    /* Relative mode already reports unbounded deltas. Warping while captured
       creates a second synthetic motion event on some SDL video backends. */
    if (!mq_mouse_captured) SDL_WarpMouseInWindow(mq_window, mq_width / 2, mq_height / 2);
    return 1;
}
/* Implement the Linux win update clip cursor native bridge operation. */
MQ_EXPORT mq_i32 mq_win_update_clip_cursor(void) { return mq_window != 0; }

/* Implement the Linux win joy startup native bridge operation. */
MQ_EXPORT mq_i32 mq_win_joy_startup(void) {
    mq_i32 count = SDL_NumJoysticks(), i; if (mq_controller) return 1;
    for (i = 0; i < count; ++i) if (SDL_IsGameController(i) && (mq_controller = SDL_GameControllerOpen(i)) != 0) return 1;
    return 0;
}
/* Implement the Linux win joy read native bridge operation. */
MQ_EXPORT mq_i32 mq_win_joy_read(void) { return mq_controller != 0; }
/* Implement the Linux win joy axis native bridge operation. */
MQ_EXPORT mq_u32 mq_win_joy_axis(mq_u32 axis) { mq_i32 value; if (!mq_controller || axis >= 6u) return 32768u; value = SDL_GameControllerGetAxis(mq_controller, axis); return (mq_u32)(value + 32768); }
/* Implement the Linux win joy buttons native bridge operation. */
MQ_EXPORT mq_u32 mq_win_joy_buttons(void) { mq_u32 bits = 0, i; if (!mq_controller) return 0; for (i = 0; i < 15u; ++i) if (SDL_GameControllerGetButton(mq_controller, i)) bits |= 1u << i; return bits; }
/* Implement the Linux win joy pov native bridge operation. */
MQ_EXPORT mq_u32 mq_win_joy_pov(void) { if (!mq_controller) return 0xffffu; if (SDL_GameControllerGetButton(mq_controller, 11)) return 0; if (SDL_GameControllerGetButton(mq_controller, 14)) return 9000; if (SDL_GameControllerGetButton(mq_controller, 12)) return 18000; if (SDL_GameControllerGetButton(mq_controller, 13)) return 27000; return 0xffffu; }
/* Implement the Linux win joy button count native bridge operation. */
MQ_EXPORT mq_u32 mq_win_joy_button_count(void) { return mq_controller ? 15u : 0u; }
/* Implement the Linux win joy has pov native bridge operation. */
MQ_EXPORT mq_i32 mq_win_joy_has_pov(void) { return mq_controller != 0; }
/* Implement the Linux win joy warrior curve native bridge operation. */
MQ_EXPORT mq_i32 mq_win_joy_warrior_curve(mq_i32 raw) { mq_i32 centered = raw - 32768; return centered * (centered < 0 ? -centered : centered) / 32768; }
/* Implement the Linux win joy warrior curve f32 native bridge operation. */
MQ_EXPORT mq_u32 mq_win_joy_warrior_curve_f32(mq_i32 raw) { union { float f; mq_u32 u; } value; value.f = (float)mq_win_joy_warrior_curve(raw); return value.u; }

/* Implement the Linux win ticks native bridge operation. */
MQ_EXPORT mq_u32 mq_win_ticks(void) { return SDL_GetTicks(); }
/* Implement the Linux win sleep native bridge operation. */
MQ_EXPORT void mq_win_sleep(mq_u32 milliseconds) { SDL_Delay(milliseconds); }
/* Implement the Linux sys counter native bridge operation. */
MQ_EXPORT mq_u64 mq_sys_counter(void) { return SDL_GetPerformanceCounter(); }
/* Implement the Linux sys frequency native bridge operation. */
MQ_EXPORT mq_u64 mq_sys_frequency(void) { return SDL_GetPerformanceFrequency(); }
/* Implement the Linux process handle count native bridge operation. */
MQ_EXPORT mq_u32 mq_process_handle_count(void) { DIR *directory = opendir("/proc/self/fd"); struct dirent *entry; mq_u32 count = 0; if (!directory) return 0; while ((entry = readdir(directory)) != 0) if (entry->d_name[0] != '.') ++count; closedir(directory); return count; }
/* Implement the Linux sys make code writeable native bridge operation. */
MQ_EXPORT mq_i32 mq_sys_make_code_writeable(mq_u64 address, mq_u64 length) { long page = sysconf(_SC_PAGESIZE); uintptr_t start; uintptr_t end; if (!address || !length || page <= 0) return 0; start = (uintptr_t)address & ~((uintptr_t)page - 1u); end = ((uintptr_t)address + (uintptr_t)length + (uintptr_t)page - 1u) & ~((uintptr_t)page - 1u); return mprotect((void *)start, end - start, PROT_READ | PROT_WRITE | PROT_EXEC) == 0; }
/* Implement the Linux sys console alloc native bridge operation. */
MQ_EXPORT mq_i32 mq_sys_console_alloc(void) { return 1; }
/* Implement the Linux sys console free native bridge operation. */
MQ_EXPORT mq_i32 mq_sys_console_free(void) { return 1; }
/* Implement the Linux sys console event pop native bridge operation. */
MQ_EXPORT mq_u32 mq_sys_console_event_pop(void) { unsigned char value; struct pollfd descriptor = { STDIN_FILENO, POLLIN, 0 }; if (poll(&descriptor, 1, 0) <= 0 || read(STDIN_FILENO, &value, 1) != 1) return 0; return 0x80000000u | ((mq_u32)value & 255u); }
/* Implement the Linux sys console write native bridge operation. */
MQ_EXPORT mq_i32 mq_sys_console_write(const char *text) { if (!text) return 0; fputs(text, stdout); fflush(stdout); return 1; }
/* Implement the Linux sys sleep until input native bridge operation. */
MQ_EXPORT void mq_sys_sleep_until_input(mq_u32 milliseconds) { struct pollfd descriptor = { STDIN_FILENO, POLLIN, 0 }; poll(&descriptor, 1, (mq_i32)milliseconds); }

/* QHOST shared-memory control is a WinQuake launcher feature.  Linux keeps the
 * ABI but intentionally supplies inert operations for normal dedicated use. */
MQ_EXPORT mq_u64 mq_conproc_create_event(void) { mq_i32 *event = (mq_i32 *)calloc(1, sizeof(*event)); return (mq_u64)(uintptr_t)event; }
/* Implement the Linux conproc set event native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_set_event(mq_u64 handle) { mq_i32 *event = (mq_i32 *)(uintptr_t)handle; if (!event) return 0; __atomic_store_n(event, 1, __ATOMIC_RELEASE); return 1; }
/* Implement the Linux conproc close handle native bridge operation. */
MQ_EXPORT void mq_conproc_close_handle(mq_u64 handle) { free((void *)(uintptr_t)handle); }
/* Implement the Linux conproc wait any native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_wait_any(mq_u64 first, mq_u64 second, mq_u32 milliseconds) { mq_u32 elapsed = 0; while (elapsed <= milliseconds) { if (first && __atomic_exchange_n((mq_i32 *)(uintptr_t)first, 0, __ATOMIC_ACQ_REL)) return 0; if (second && __atomic_exchange_n((mq_i32 *)(uintptr_t)second, 0, __ATOMIC_ACQ_REL)) return 1; if (milliseconds == 0xffffffffu) { mq_wait_one_millisecond(); continue; } mq_wait_one_millisecond(); ++elapsed; } return 258; }
/* Implement the Linux conproc map native bridge operation. */
MQ_EXPORT mq_ptr mq_conproc_map(mq_u64 handle) { (void)handle; return 0; }
/* Implement the Linux conproc unmap native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_unmap(mq_ptr mapped) { (void)mapped; return 1; }
/* Implement the Linux conproc read i32 native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_read_i32(mq_ptr mapped, mq_u32 index) { return mapped ? ((mq_i32 *)mapped)[index] : 0; }
/* Implement the Linux conproc write i32 native bridge operation. */
MQ_EXPORT void mq_conproc_write_i32(mq_ptr mapped, mq_u32 index, mq_i32 value) { if (mapped) ((mq_i32 *)mapped)[index] = value; }
MQ_EXPORT const char *mq_conproc_read_text(mq_ptr mapped, mq_u32 offset) { return mapped ? (const char *)mapped + offset : ""; }
/* Implement the Linux conproc write text native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_write_text(mq_ptr mapped, mq_u32 offset, const char *text, mq_u32 capacity) { if (!mapped || !text || capacity == 0) return 0; snprintf((char *)mapped + offset, capacity, "%s", text); return 1; }
/* Implement the Linux conproc screen lines native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_screen_lines(void) { return 25; }
/* Implement the Linux conproc set screen size native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_set_screen_size(mq_i32 width, mq_i32 height) { (void)width; (void)height; return 1; }
MQ_EXPORT const char *mq_conproc_read_console_text(mq_i32 begin, mq_i32 end) { (void)begin; (void)end; return ""; }
/* Implement the Linux conproc write key native bridge operation. */
MQ_EXPORT mq_i32 mq_conproc_write_key(mq_i32 character, mq_i32 virtual_key, mq_i32 scan_code, mq_i32 shift, mq_i32 down) {
    /* The external WinQuake QHOST console protocol has no Linux equivalent.
       Report the compatibility request as consumed without mutating stdin. */
    (void)character; (void)virtual_key; (void)scan_code; (void)shift; (void)down;
    return 1;
}

/* Open a fixed-format SDL queued-audio device. */
MQ_EXPORT mq_i32 mq_audio_open(mq_u32 sample_rate, mq_u32 channels, mq_u32 bits) {
    SDL_AudioSpec wanted, obtained; if (mq_audio_device) return 1;
    if (sample_rate == 0 || (channels != 1 && channels != 2) || (bits != 8 && bits != 16)) return 0;
    memset(&wanted, 0, sizeof(wanted)); memset(&obtained, 0, sizeof(obtained));
    wanted.freq = (mq_i32)sample_rate; wanted.format = bits == 16 ? SDL_AUDIO_S16LSB : SDL_AUDIO_U8; wanted.channels = (mq_u8)channels; wanted.samples = 1024;
    mq_audio_device = SDL_OpenAudioDevice(0, 0, &wanted, &obtained, 0);
    if (!mq_audio_device) return 0;
    mq_audio_bytes_per_sample = channels * (bits / 8u); mq_audio_submitted_bytes = 0; mq_audio_submitted_blocks = 0; mq_audio_underrun_count = 0;
    SDL_PauseAudioDevice(mq_audio_device, 0); return 1;
}
/* Append one mixed PCM block to the SDL audio queue. */
MQ_EXPORT mq_i32 mq_audio_submit(const void *data, mq_u32 bytes) {
    mq_u32 capacity = MQ_AUDIO_CAPACITY * MQ_AUDIO_BLOCK_BYTES;
    mq_u32 queued;
    if (!mq_audio_device || !data || !bytes || bytes > capacity) return 0;
    queued = SDL_GetQueuedAudioSize(mq_audio_device);
    if (queued > capacity - bytes) return 0;
    if (SDL_QueueAudio(mq_audio_device, data, bytes) != 0) return 0;
    mq_audio_submitted_bytes += bytes;
    ++mq_audio_submitted_blocks;
    return 1;
}
/* Implement the Linux audio close native bridge operation. */
MQ_EXPORT void mq_audio_close(void) { if (mq_audio_device) { SDL_ClearQueuedAudio(mq_audio_device); SDL_CloseAudioDevice(mq_audio_device); mq_audio_device = 0; } }
/* Implement the Linux audio queued native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_queued(void) { mq_u32 bytes = mq_audio_device ? SDL_GetQueuedAudioSize(mq_audio_device) : 0; return (bytes + MQ_AUDIO_BLOCK_BYTES - 1u) / MQ_AUDIO_BLOCK_BYTES; }
/* Implement the Linux audio reset native bridge operation. */
MQ_EXPORT mq_i32 mq_audio_reset(void) { if (!mq_audio_device) return 0; SDL_ClearQueuedAudio(mq_audio_device); mq_audio_submitted_bytes = 0; mq_audio_submitted_blocks = 0; return 1; }
/* Implement the Linux audio position native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_position(mq_u32 mask) { mq_u64 played; if (!mq_audio_device || !mq_audio_bytes_per_sample) return 0; played = mq_audio_submitted_bytes - SDL_GetQueuedAudioSize(mq_audio_device); return (mq_u32)(played / mq_audio_bytes_per_sample) & mask; }
/* Implement the Linux audio submitted native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_submitted(void) { return mq_audio_submitted_blocks; }
/* Implement the Linux audio completed native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_completed(void) { mq_u64 played = mq_audio_device ? mq_audio_submitted_bytes - SDL_GetQueuedAudioSize(mq_audio_device) : 0; return (mq_u32)(played / MQ_AUDIO_BLOCK_BYTES); }
/* Implement the Linux audio underruns native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_underruns(void) { return mq_audio_underrun_count; }
/* Implement the Linux audio header state native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_header_state(mq_u32 index) { return index < mq_audio_queued(); }
/* Implement the Linux audio capacity native bridge operation. */
MQ_EXPORT mq_u32 mq_audio_capacity(void) { return MQ_AUDIO_CAPACITY; }
/* Implement the Linux audio is open native bridge operation. */
MQ_EXPORT mq_i32 mq_audio_is_open(void) { return mq_audio_device != 0; }

/* Implement the Linux socket error native bridge operation. */
static mq_i32 mq_socket_error(void) { if (errno == EAGAIN || errno == EWOULDBLOCK) return 10035; if (errno == EMSGSIZE) return 10040; if (errno == ECONNRESET) return 10054; if (errno == ECONNREFUSED) return 10061; return errno; }
/* Implement the Linux format address native bridge operation. */
static void mq_format_address(char *output, mq_u32 capacity, const struct sockaddr_in *address) { if (!inet_ntop(AF_INET, &address->sin_addr, output, capacity)) snprintf(output, capacity, "0.0.0.0"); }
/* Create and bind one nonblocking POSIX UDP socket. */
MQ_EXPORT mq_u64 mq_udp_open_bound(mq_u32 port, const char *bind_address) {
    struct sockaddr_in address; mq_i32 handle, flags;
    if (port > 65535u) return 0;
    handle = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP); if (handle < 0) { mq_udp_last_error_value = mq_socket_error(); return 0; }
    flags = fcntl(handle, F_GETFL, 0); if (flags < 0 || fcntl(handle, F_SETFL, flags | O_NONBLOCK) != 0) { mq_udp_last_error_value = mq_socket_error(); close(handle); return 0; }
    memset(&address, 0, sizeof(address)); address.sin_family = AF_INET; address.sin_port = htons((mq_u16)port); address.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind_address && bind_address[0] && strcmp(bind_address, "0.0.0.0") != 0 && inet_pton(AF_INET, bind_address, &address.sin_addr) != 1) { mq_udp_last_error_value = -3; close(handle); return 0; }
    if (bind(handle, (struct sockaddr *)&address, sizeof(address)) != 0) { mq_udp_last_error_value = mq_socket_error(); close(handle); return 0; }
    mq_udp_last_error_value = 0; return (mq_u64)handle;
}
/* Implement the Linux udp open native bridge operation. */
MQ_EXPORT mq_u64 mq_udp_open(mq_u32 port) { return mq_udp_open_bound(port, "0.0.0.0"); }
/* Implement the Linux udp close native bridge operation. */
MQ_EXPORT void mq_udp_close(mq_u64 handle) { if (handle) close((mq_i32)handle); }
/* Implement the Linux udp bound port native bridge operation. */
MQ_EXPORT mq_u32 mq_udp_bound_port(mq_u64 handle) { struct sockaddr_in address; socklen_t size = sizeof(address); if (!handle || getsockname((mq_i32)handle, (struct sockaddr *)&address, &size) != 0) return 0; return ntohs(address.sin_port); }
MQ_EXPORT const char *mq_udp_bound_address(mq_u64 handle) { struct sockaddr_in address; socklen_t size = sizeof(address); if (!handle || getsockname((mq_i32)handle, (struct sockaddr *)&address, &size) != 0) return ""; mq_format_address(mq_udp_bound_address_text, sizeof(mq_udp_bound_address_text), &address); return mq_udp_bound_address_text; }
/* Implement the Linux udp enable broadcast native bridge operation. */
MQ_EXPORT mq_i32 mq_udp_enable_broadcast(mq_u64 handle) { mq_i32 enabled = 1; if (!handle || setsockopt((mq_i32)handle, SOL_SOCKET, SO_BROADCAST, &enabled, sizeof(enabled)) != 0) { mq_udp_last_error_value = mq_socket_error(); return -1; } return 0; }
/* Implement the Linux udp peek native bridge operation. */
MQ_EXPORT mq_i32 mq_udp_peek(mq_u64 handle) { unsigned char value; mq_i32 result; if (!handle) return -1; result = recvfrom((mq_i32)handle, &value, 1, MSG_PEEK, 0, 0); if (result < 0 && (errno == EAGAIN || errno == EWOULDBLOCK || errno == ECONNRESET || errno == ECONNREFUSED)) return 0; if (result < 0) { mq_udp_last_error_value = mq_socket_error(); return -1; } return result; }
/* Implement the Linux udp send native bridge operation. */
MQ_EXPORT mq_i32 mq_udp_send(mq_u64 handle, const char *host, mq_u32 port, const void *data, mq_u32 bytes) {
    struct sockaddr_in address; struct addrinfo hints, *resolved = 0; mq_i32 result;
    if (!handle || !host || !data || bytes > 65507u || port > 65535u) return -1;
    memset(&address, 0, sizeof(address)); address.sin_family = AF_INET; address.sin_port = htons((mq_u16)port);
    if (inet_pton(AF_INET, host, &address.sin_addr) != 1) { memset(&hints, 0, sizeof(hints)); hints.ai_family = AF_INET; hints.ai_socktype = SOCK_DGRAM; if (getaddrinfo(host, 0, &hints, &resolved) != 0 || !resolved) { mq_udp_last_error_value = -2; return -1; } address.sin_addr = ((struct sockaddr_in *)resolved->ai_addr)->sin_addr; freeaddrinfo(resolved); }
    result = sendto((mq_i32)handle, data, bytes, 0, (struct sockaddr *)&address, sizeof(address)); if (result < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) return 0; if (result < 0) { mq_udp_last_error_value = mq_socket_error(); return -1; } mq_udp_last_error_value = 0; return result;
}
/* Implement the Linux udp receive native bridge operation. */
MQ_EXPORT mq_i32 mq_udp_receive(mq_u64 handle, void *data, mq_u32 capacity) { struct sockaddr_in address; socklen_t size = sizeof(address); mq_i32 result; if (!handle || !data || !capacity) return -1; result = recvfrom((mq_i32)handle, data, capacity, 0, (struct sockaddr *)&address, &size); if (result < 0 && (errno == EAGAIN || errno == EWOULDBLOCK || errno == ECONNRESET || errno == ECONNREFUSED)) return 0; if (result < 0) { mq_udp_last_error_value = mq_socket_error(); return -1; } mq_format_address(mq_udp_last_address_text, sizeof(mq_udp_last_address_text), &address); mq_udp_last_port_value = ntohs(address.sin_port); mq_udp_last_error_value = 0; return result; }
MQ_EXPORT const char *mq_udp_last_address(void) { return mq_udp_last_address_text; }
/* Implement the Linux udp last port native bridge operation. */
MQ_EXPORT mq_u32 mq_udp_last_port(void) { return mq_udp_last_port_value; }
/* Implement the Linux udp last error native bridge operation. */
MQ_EXPORT mq_i32 mq_udp_last_error(void) { return mq_udp_last_error_value; }
MQ_EXPORT const char *mq_udp_host_name(void) { if (gethostname(mq_udp_host_name_text, sizeof(mq_udp_host_name_text)) != 0) return ""; mq_udp_host_name_text[sizeof(mq_udp_host_name_text) - 1u] = 0; return mq_udp_host_name_text; }
MQ_EXPORT const char *mq_udp_resolve_name(const char *name) { struct addrinfo hints, *result = 0; if (!name) return ""; memset(&hints, 0, sizeof(hints)); hints.ai_family = AF_INET; if (getaddrinfo(name, 0, &hints, &result) != 0 || !result) return ""; inet_ntop(AF_INET, &((struct sockaddr_in *)result->ai_addr)->sin_addr, mq_udp_resolved_address_text, sizeof(mq_udp_resolved_address_text)); freeaddrinfo(result); return mq_udp_resolved_address_text; }
MQ_EXPORT const char *mq_udp_reverse_name(const char *text) { struct sockaddr_in address; if (!text || inet_pton(AF_INET, text, &address.sin_addr) != 1) return ""; address.sin_family = AF_INET; if (getnameinfo((struct sockaddr *)&address, sizeof(address), mq_udp_reverse_name_text, sizeof(mq_udp_reverse_name_text), 0, 0, 0) != 0) return ""; return mq_udp_reverse_name_text; }
MQ_EXPORT const char *mq_udp_local_address(void) { const char *host = mq_udp_host_name(); const char *resolved = host[0] ? mq_udp_resolve_name(host) : ""; if (resolved[0]) snprintf(mq_udp_local_address_text, sizeof(mq_udp_local_address_text), "%s", resolved); return mq_udp_local_address_text; }
