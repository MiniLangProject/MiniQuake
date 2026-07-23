/*
 * MiniQuake native platform bridge.
 *
 * Copyright (C) 2026 MiniQuake contributors
 * Quake-derived integration work is distributed under GPL-2.0-or-later.
 * See COPYING.
 *
 * The bridge intentionally has a narrow C ABI consisting only of integer,
 * pointer and C/W-string values supported by MiniLang's extern mechanism.
 * IEEE-754 values cross the ABI as their 32-bit bit patterns.
 */
#include "miniquake_native.h"

#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_CDECL __cdecl

/* Minimal Win32 declarations; no Windows SDK is required to build this DLL. */
typedef mq_ptr HANDLE;
typedef mq_ptr HWND;
typedef mq_ptr HDC;
typedef mq_ptr HGLRC;
typedef mq_ptr HINSTANCE;
typedef mq_ptr HICON;
typedef mq_ptr HCURSOR;
typedef mq_ptr HBRUSH;
typedef mq_ptr HMENU;
typedef mq_ptr HMODULE;
typedef mq_ptr HWAVEOUT;
typedef mq_ptr LPVOID;
typedef const void *LPCVOID;
typedef unsigned short WCHAR;
typedef const WCHAR *LPCWSTR;
typedef char CHAR;
typedef const CHAR *LPCSTR;
typedef mq_u32 DWORD;
typedef mq_u16 WORD;
typedef mq_u8 BYTE;
typedef mq_i32 BOOL;
typedef mq_i32 LONG;
typedef mq_u32 UINT;
typedef mq_u64 ULONG_PTR;
typedef mq_i64 LONG_PTR;
typedef mq_u64 WPARAM;
typedef mq_i64 LPARAM;
typedef mq_i64 LRESULT;
typedef mq_u16 ATOM;
typedef mq_u32 MMRESULT;
typedef mq_u64 SOCKET;

typedef struct MQ_SOCKADDR_IN {
    mq_u16 sin_family;
    mq_u16 sin_port;
    mq_u32 sin_addr;
    mq_u8 sin_zero[8];
} MQ_SOCKADDR_IN;

typedef struct MQ_POINT {
    LONG x;
    LONG y;
} MQ_POINT;

typedef struct MQ_RECT {
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
} MQ_RECT;

typedef struct MQ_MSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    MQ_POINT pt;
    DWORD lPrivate;
} MQ_MSG;

typedef LRESULT (MQ_WINAPI *MQ_WNDPROC)(HWND, UINT, WPARAM, LPARAM);

typedef struct MQ_WNDCLASSEXW {
    UINT cbSize;
    UINT style;
    MQ_WNDPROC lpfnWndProc;
    mq_i32 cbClsExtra;
    mq_i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
    HICON hIconSm;
} MQ_WNDCLASSEXW;

typedef struct MQ_PIXELFORMATDESCRIPTOR {
    WORD nSize;
    WORD nVersion;
    DWORD dwFlags;
    BYTE iPixelType;
    BYTE cColorBits;
    BYTE cRedBits;
    BYTE cRedShift;
    BYTE cGreenBits;
    BYTE cGreenShift;
    BYTE cBlueBits;
    BYTE cBlueShift;
    BYTE cAlphaBits;
    BYTE cAlphaShift;
    BYTE cAccumBits;
    BYTE cAccumRedBits;
    BYTE cAccumGreenBits;
    BYTE cAccumBlueBits;
    BYTE cAccumAlphaBits;
    BYTE cDepthBits;
    BYTE cStencilBits;
    BYTE cAuxBuffers;
    BYTE iLayerType;
    BYTE bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
} MQ_PIXELFORMATDESCRIPTOR;

typedef struct MQ_WAVEFORMATEX {
    WORD wFormatTag;
    WORD nChannels;
    DWORD nSamplesPerSec;
    DWORD nAvgBytesPerSec;
    WORD nBlockAlign;
    WORD wBitsPerSample;
    WORD cbSize;
} MQ_WAVEFORMATEX;

typedef struct MQ_WAVEHDR {
    CHAR *lpData;
    DWORD dwBufferLength;
    DWORD dwBytesRecorded;
    ULONG_PTR dwUser;
    DWORD dwFlags;
    DWORD dwLoops;
    struct MQ_WAVEHDR *lpNext;
    ULONG_PTR reserved;
} MQ_WAVEHDR;

/*
 * MiniLang v1 raw-value ABI used by nativeRawValue/nativeValueFromRaw.
 *
 * Single-precision values have an immediate representation:
 *   raw = (ieee754_bits << 3) | 5
 *
 * MiniLang can also carry a boxed double object.  Supporting both forms keeps
 * the bridge correct for literals, arithmetic results, and future compiler
 * normalization choices without converting through locale-sensitive text.
 */
#define MQ_ML_TAG_MASK 7u
#define MQ_ML_TAG_PTR 0u
#define MQ_ML_TAG_INT 1u
#define MQ_ML_TAG_FLOAT 5u
#define MQ_ML_OBJ_FLOAT 4u

typedef struct MQ_ML_FLOAT_OBJECT {
    mq_u32 type;
    mq_u32 padding;
    double value;
} MQ_ML_FLOAT_OBJECT;

/* msvcrt */
MQ_DLLIMPORT double MQ_CDECL strtod(const char *text, char **end_pointer);
MQ_DLLIMPORT int MQ_CDECL sprintf(char *buffer, const char *format, ...);
MQ_DLLIMPORT void *MQ_CDECL memset(void *destination, mq_i32 value, mq_u64 count);
MQ_DLLIMPORT double MQ_CDECL sin(double value);
MQ_DLLIMPORT double MQ_CDECL cos(double value);
MQ_DLLIMPORT double MQ_CDECL sqrt(double value);
MQ_DLLIMPORT float MQ_CDECL sqrtf(float value);
MQ_DLLIMPORT double MQ_CDECL atan2(double y, double x);

/* kernel32 */
MQ_DLLIMPORT HMODULE MQ_WINAPI GetModuleHandleW(LPCWSTR name);
MQ_DLLIMPORT DWORD MQ_WINAPI GetTickCount(void);
MQ_DLLIMPORT void MQ_WINAPI Sleep(DWORD milliseconds);

/* user32 */
MQ_DLLIMPORT ATOM MQ_WINAPI RegisterClassExW(const MQ_WNDCLASSEXW *window_class);
MQ_DLLIMPORT BOOL MQ_WINAPI UnregisterClassW(LPCWSTR class_name, HINSTANCE instance);
MQ_DLLIMPORT HWND MQ_WINAPI CreateWindowExW(DWORD ex_style, LPCWSTR class_name, LPCWSTR title, DWORD style, mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, HWND parent, HMENU menu, HINSTANCE instance, LPVOID parameter);
MQ_DLLIMPORT BOOL MQ_WINAPI DestroyWindow(HWND window);
MQ_DLLIMPORT LRESULT MQ_WINAPI DefWindowProcW(HWND window, UINT message, WPARAM w_param, LPARAM l_param);
MQ_DLLIMPORT void MQ_WINAPI PostQuitMessage(mq_i32 exit_code);
MQ_DLLIMPORT BOOL MQ_WINAPI PeekMessageW(MQ_MSG *message, HWND window, UINT min_message, UINT max_message, UINT remove_message);
MQ_DLLIMPORT BOOL MQ_WINAPI TranslateMessage(const MQ_MSG *message);
MQ_DLLIMPORT LRESULT MQ_WINAPI DispatchMessageW(const MQ_MSG *message);
MQ_DLLIMPORT BOOL MQ_WINAPI ShowWindow(HWND window, mq_i32 command);
MQ_DLLIMPORT BOOL MQ_WINAPI UpdateWindow(HWND window);
MQ_DLLIMPORT BOOL MQ_WINAPI SetWindowTextW(HWND window, LPCWSTR title);
MQ_DLLIMPORT mq_i32 MQ_WINAPI GetSystemMetrics(mq_i32 index);
MQ_DLLIMPORT BOOL MQ_WINAPI AdjustWindowRectEx(MQ_RECT *rect, DWORD style, BOOL has_menu, DWORD ex_style);
MQ_DLLIMPORT BOOL MQ_WINAPI GetClientRect(HWND window, MQ_RECT *rect);
MQ_DLLIMPORT mq_i32 MQ_WINAPI GetAsyncKeyState(mq_i32 virtual_key);
MQ_DLLIMPORT HWND MQ_WINAPI GetForegroundWindow(void);
MQ_DLLIMPORT BOOL MQ_WINAPI GetCursorPos(MQ_POINT *point);
MQ_DLLIMPORT BOOL MQ_WINAPI SetCursorPos(mq_i32 x, mq_i32 y);
MQ_DLLIMPORT BOOL MQ_WINAPI ClientToScreen(HWND window, MQ_POINT *point);
MQ_DLLIMPORT mq_i32 MQ_WINAPI ShowCursor(BOOL show);
MQ_DLLIMPORT HCURSOR MQ_WINAPI LoadCursorW(HINSTANCE instance, LPCWSTR cursor_name);
MQ_DLLIMPORT HICON MQ_WINAPI LoadIconW(HINSTANCE instance, LPCWSTR icon_name);
MQ_DLLIMPORT HDC MQ_WINAPI GetDC(HWND window);
MQ_DLLIMPORT mq_i32 MQ_WINAPI ReleaseDC(HWND window, HDC dc);

/* gdi32 */
MQ_DLLIMPORT mq_i32 MQ_WINAPI ChoosePixelFormat(HDC dc, const MQ_PIXELFORMATDESCRIPTOR *descriptor);
MQ_DLLIMPORT BOOL MQ_WINAPI SetPixelFormat(HDC dc, mq_i32 format, const MQ_PIXELFORMATDESCRIPTOR *descriptor);
MQ_DLLIMPORT BOOL MQ_WINAPI SwapBuffers(HDC dc);

/* opengl32 / WGL */
MQ_DLLIMPORT HGLRC MQ_WINAPI wglCreateContext(HDC dc);
MQ_DLLIMPORT BOOL MQ_WINAPI wglDeleteContext(HGLRC context);
MQ_DLLIMPORT BOOL MQ_WINAPI wglMakeCurrent(HDC dc, HGLRC context);

/* winmm */
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutOpen(HWAVEOUT *output, UINT device_id, const MQ_WAVEFORMATEX *format, ULONG_PTR callback, ULONG_PTR instance, DWORD flags);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutPrepareHeader(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutUnprepareHeader(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutWrite(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutReset(HWAVEOUT output);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutClose(HWAVEOUT output);

/* ws2_32 */
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSAStartup(WORD version, void *data);
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSACleanup(void);
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSAGetLastError(void);
MQ_DLLIMPORT SOCKET MQ_WINAPI socket(mq_i32 family, mq_i32 type, mq_i32 protocol);
MQ_DLLIMPORT mq_i32 MQ_WINAPI closesocket(SOCKET socket_value);
MQ_DLLIMPORT mq_i32 MQ_WINAPI ioctlsocket(SOCKET socket_value, LONG command, mq_u32 *argument);
MQ_DLLIMPORT mq_i32 MQ_WINAPI bind(SOCKET socket_value, const void *address, mq_i32 address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI getsockname(SOCKET socket_value, void *address, mq_i32 *address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI sendto(SOCKET socket_value, const char *data, mq_i32 length, mq_i32 flags, const void *address, mq_i32 address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI recvfrom(SOCKET socket_value, char *data, mq_i32 length, mq_i32 flags, void *address, mq_i32 *address_length);
MQ_DLLIMPORT mq_u16 MQ_WINAPI htons(mq_u16 value);
MQ_DLLIMPORT mq_u16 MQ_WINAPI ntohs(mq_u16 value);
MQ_DLLIMPORT mq_u32 MQ_WINAPI inet_addr(const char *address);

/* OpenGL 1.1 */
MQ_DLLIMPORT void MQ_WINAPI glBegin(mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glEnd(void);
MQ_DLLIMPORT void MQ_WINAPI glVertex2f(float x, float y);
MQ_DLLIMPORT void MQ_WINAPI glVertex3f(float x, float y, float z);
MQ_DLLIMPORT void MQ_WINAPI glTexCoord2f(float s, float t);
MQ_DLLIMPORT void MQ_WINAPI glColor4ub(mq_u8 r, mq_u8 g, mq_u8 b, mq_u8 a);
MQ_DLLIMPORT void MQ_WINAPI glClearColor(float r, float g, float b, float a);
MQ_DLLIMPORT void MQ_WINAPI glClear(mq_u32 mask);
MQ_DLLIMPORT void MQ_WINAPI glEnable(mq_u32 capability);
MQ_DLLIMPORT void MQ_WINAPI glDisable(mq_u32 capability);
MQ_DLLIMPORT void MQ_WINAPI glBlendFunc(mq_u32 source, mq_u32 destination);
MQ_DLLIMPORT void MQ_WINAPI glDepthFunc(mq_u32 function_name);
MQ_DLLIMPORT void MQ_WINAPI glDepthMask(mq_u8 enabled);
MQ_DLLIMPORT void MQ_WINAPI glDepthRange(double near_value, double far_value);
MQ_DLLIMPORT void MQ_WINAPI glAlphaFunc(mq_u32 function_name, float reference);
MQ_DLLIMPORT void MQ_WINAPI glCullFace(mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glShadeModel(mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glPolygonMode(mq_u32 face, mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glViewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height);
MQ_DLLIMPORT void MQ_WINAPI glMatrixMode(mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glLoadIdentity(void);
MQ_DLLIMPORT void MQ_WINAPI glPushMatrix(void);
MQ_DLLIMPORT void MQ_WINAPI glPopMatrix(void);
MQ_DLLIMPORT void MQ_WINAPI glTranslatef(float x, float y, float z);
MQ_DLLIMPORT void MQ_WINAPI glRotatef(float angle, float x, float y, float z);
MQ_DLLIMPORT void MQ_WINAPI glScalef(float x, float y, float z);
MQ_DLLIMPORT void MQ_WINAPI glOrtho(double left, double right, double bottom, double top, double near_value, double far_value);
MQ_DLLIMPORT void MQ_WINAPI glFrustum(double left, double right, double bottom, double top, double near_value, double far_value);
MQ_DLLIMPORT void MQ_WINAPI glBindTexture(mq_u32 target, mq_u32 texture);
MQ_DLLIMPORT void MQ_WINAPI glGenTextures(mq_i32 count, mq_u32 *texture_ids);
MQ_DLLIMPORT void MQ_WINAPI glDeleteTextures(mq_i32 count, const mq_u32 *texture_ids);
MQ_DLLIMPORT void MQ_WINAPI glTexParameteri(mq_u32 target, mq_u32 name, mq_i32 value);
MQ_DLLIMPORT void MQ_WINAPI glTexImage2D(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels);
MQ_DLLIMPORT void MQ_WINAPI glTexSubImage2D(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels);
MQ_DLLIMPORT void MQ_WINAPI glReadPixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels);
MQ_DLLIMPORT const mq_u8 *MQ_WINAPI glGetString(mq_u32 name);
MQ_DLLIMPORT mq_u32 MQ_WINAPI glGetError(void);
MQ_DLLIMPORT void MQ_WINAPI glFinish(void);
MQ_DLLIMPORT void MQ_WINAPI glFlush(void);

#define MQ_FALSE 0
#define MQ_TRUE 1
#define MQ_NULL ((void *)0)
#define MQ_CS_OWNDC 0x0020u
#define MQ_CS_HREDRAW 0x0002u
#define MQ_CS_VREDRAW 0x0001u
#define MQ_WS_OVERLAPPEDWINDOW 0x00CF0000u
#define MQ_WS_POPUP 0x80000000u
#define MQ_WS_VISIBLE 0x10000000u
#define MQ_WS_EX_APPWINDOW 0x00040000u
#define MQ_CW_USEDEFAULT ((mq_i32)0x80000000u)
#define MQ_SW_SHOW 5
#define MQ_PM_REMOVE 0x0001u
#define MQ_WM_DESTROY 0x0002u
#define MQ_WM_CLOSE 0x0010u
#define MQ_WM_QUIT 0x0012u
#define MQ_WM_KEYDOWN 0x0100u
#define MQ_WM_CHAR 0x0102u
#define MQ_WM_SYSKEYDOWN 0x0104u
#define MQ_WM_MOUSEWHEEL 0x020Au
#define MQ_PFD_DOUBLEBUFFER 0x00000001u
#define MQ_PFD_DRAW_TO_WINDOW 0x00000004u
#define MQ_PFD_SUPPORT_OPENGL 0x00000020u
#define MQ_PFD_TYPE_RGBA 0
#define MQ_PFD_MAIN_PLANE 0
#define MQ_WAVE_FORMAT_PCM 1
#define MQ_WAVE_MAPPER 0xFFFFFFFFu
#define MQ_CALLBACK_NULL 0
#define MQ_WHDR_DONE 0x00000001u
#define MQ_WHDR_PREPARED 0x00000002u
#define MQ_VK_LBUTTON 0x01
#define MQ_VK_RBUTTON 0x02
#define MQ_VK_MBUTTON 0x04
#define MQ_SM_CXSCREEN 0
#define MQ_SM_CYSCREEN 1
#define MQ_IDC_ARROW ((LPCWSTR)(ULONG_PTR)32512u)
#define MQ_IDI_APPLICATION ((LPCWSTR)(ULONG_PTR)32512u)
#define MQ_AF_INET 2
#define MQ_SOCK_DGRAM 2
#define MQ_IPPROTO_UDP 17
#define MQ_FIONBIO ((LONG)0x8004667eu)
#define MQ_INVALID_SOCKET ((SOCKET)~(SOCKET)0)
#define MQ_SOCKET_ERROR (-1)
#define MQ_WSAEWOULDBLOCK 10035
#define MQ_INADDR_NONE 0xffffffffu

int _fltused = 0;

static const WCHAR mq_window_class_name[] = {
    'M','i','n','i','Q','u','a','k','e','W','i','n','d','o','w',0
};

static HWND mq_window = MQ_NULL;
static HDC mq_window_dc = MQ_NULL;
static HGLRC mq_gl_context = MQ_NULL;
static HINSTANCE mq_instance = MQ_NULL;
static mq_i32 mq_class_registered = 0;
static mq_i32 mq_running = 0;
static mq_i32 mq_cursor_captured = 0;
static mq_i32 mq_mouse_ready = 0;
static mq_i32 mq_mouse_delta_x = 0;
static mq_i32 mq_mouse_delta_y = 0;
static mq_i32 mq_mouse_wheel_delta = 0;
#define MQ_TEXT_QUEUE_CAPACITY 64
static mq_u16 mq_text_queue[MQ_TEXT_QUEUE_CAPACITY];
static mq_u32 mq_text_head = 0;
static mq_u32 mq_text_tail = 0;
static mq_u8 mq_key_pressed[256];

static HWAVEOUT mq_wave_output = MQ_NULL;
#define MQ_AUDIO_BUFFER_COUNT 8
#define MQ_AUDIO_BUFFER_BYTES 16384
static mq_u8 mq_audio_data[MQ_AUDIO_BUFFER_COUNT][MQ_AUDIO_BUFFER_BYTES];
static MQ_WAVEHDR mq_audio_headers[MQ_AUDIO_BUFFER_COUNT];
static mq_u32 mq_audio_next_buffer = 0;
static mq_u32 mq_audio_buffer_count = 0;

static mq_i32 mq_winsock_started = 0;
static mq_u32 mq_udp_socket_count = 0;
static char mq_udp_last_address_text[32] = "0.0.0.0";
static mq_u32 mq_udp_last_port_value = 0;
static mq_i32 mq_udp_last_error_value = 0;
static mq_u8 mq_wsa_data[512];

static float mq_bits_to_float(mq_u32 bits) {
    union { mq_u32 u; float f; } value;
    value.u = bits;
    return value.f;
}

static mq_u32 mq_float_to_bits(float number) {
    union { mq_u32 u; float f; } value;
    value.f = number;
    return value.u;
}

static mq_i32 mq_abs_i32(mq_i32 value) {
    return value < 0 ? -value : value;
}

/* Center the cursor in client coordinates.  The first captured sample must not
 * be interpreted as movement because the cursor can be anywhere on the desktop
 * when the window gains focus. */
static mq_i32 mq_center_mouse_cursor(void) {
    MQ_RECT rectangle;
    MQ_POINT center;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    center.x = (rectangle.right - rectangle.left) / 2;
    center.y = (rectangle.bottom - rectangle.top) / 2;
    if (!ClientToScreen(mq_window, &center)) {
        return 0;
    }
    return SetCursorPos(center.x, center.y) != 0;
}

static void mq_copy_bytes(mq_u8 *destination, const mq_u8 *source, mq_u32 count) {
    mq_u32 i = 0;
    while (i < count) {
        destination[i] = source[i];
        ++i;
    }
}

static void mq_zero_bytes(mq_u8 *destination, mq_u32 count) {
    mq_u32 i = 0;
    while (i < count) {
        destination[i] = 0;
        ++i;
    }
}

static mq_i32 mq_winsock_start(void) {
    mq_i32 startup_result;
    if (mq_winsock_started) {
        return 1;
    }
    mq_zero_bytes(mq_wsa_data, (mq_u32)sizeof(mq_wsa_data));
    startup_result = WSAStartup((WORD)0x0202u, mq_wsa_data);
    if (startup_result != 0) {
        /* WSAStartup returns its own Winsock error code; WSAGetLastError is not
         * guaranteed to describe this failure. */
        mq_udp_last_error_value = startup_result;
        return 0;
    }
    mq_winsock_started = 1;
    return 1;
}

static void mq_udp_remember_address(const MQ_SOCKADDR_IN *address) {
    const mq_u8 *octets = (const mq_u8 *)&address->sin_addr;
    sprintf(
        mq_udp_last_address_text,
        "%u.%u.%u.%u",
        (unsigned int)octets[0],
        (unsigned int)octets[1],
        (unsigned int)octets[2],
        (unsigned int)octets[3]
    );
    mq_udp_last_port_value = (mq_u32)ntohs(address->sin_port);
}

static void mq_clear_input_events(void) {
    mq_u32 i;
    mq_mouse_delta_x = 0;
    mq_mouse_delta_y = 0;
    mq_mouse_ready = 0;
    mq_text_head = 0;
    mq_text_tail = 0;
    for (i = 0; i < 256u; ++i) {
        mq_key_pressed[i] = 0;
    }
}

static void mq_push_text(mq_u16 character) {
    mq_u32 next = (mq_text_head + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    if (next == mq_text_tail) {
        mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    }
    mq_text_queue[mq_text_head] = character;
    mq_text_head = next;
}

static LRESULT MQ_WINAPI mq_window_proc(HWND window, UINT message, WPARAM w_param, LPARAM l_param) {
    (void)l_param;
    if ((message == MQ_WM_KEYDOWN || message == MQ_WM_SYSKEYDOWN) && w_param < 256u) {
        mq_key_pressed[(mq_u32)w_param] = 1;
    }
    if (message == MQ_WM_CHAR) {
        mq_u16 character = (mq_u16)(w_param & 0xFFFFu);
        if (character != 0) {
            mq_push_text(character);
        }
        return 0;
    }
    if (message == MQ_WM_CLOSE) {
        mq_running = 0;
        DestroyWindow(window);
        return 0;
    }
    if (message == MQ_WM_DESTROY) {
        mq_running = 0;
        PostQuitMessage(0);
        return 0;
    }
    if (message == MQ_WM_MOUSEWHEEL) {
        mq_i32 delta = (mq_i32)((w_param >> 16) & 0xFFFFu);
        if (delta & 0x8000) {
            delta -= 0x10000;
        }
        mq_mouse_wheel_delta += delta / 120;
        return 0;
    }
    return DefWindowProcW(window, message, w_param, l_param);
}

MQ_EXPORT mq_u32 mq_f32_from_text(const char *text) {
    double parsed;
    if (text == MQ_NULL) {
        return 0;
    }
    parsed = strtod(text, (char **)MQ_NULL);
    return mq_float_to_bits((float)parsed);
}

MQ_EXPORT mq_u32 mq_f32_from_ml_raw(mq_u64 raw_value) {
    mq_u32 tag = (mq_u32)(raw_value & MQ_ML_TAG_MASK);

    if (tag == MQ_ML_TAG_FLOAT) {
        return (mq_u32)(raw_value >> 3);
    }

    if (tag == MQ_ML_TAG_INT) {
        mq_i64 integer_value = ((mq_i64)raw_value) >> 3;
        return mq_float_to_bits((float)integer_value);
    }

    if (tag == MQ_ML_TAG_PTR && raw_value != 0) {
        const MQ_ML_FLOAT_OBJECT *object = (const MQ_ML_FLOAT_OBJECT *)(ULONG_PTR)raw_value;
        if (object->type == MQ_ML_OBJ_FLOAT) {
            return mq_float_to_bits((float)object->value);
        }
    }

    return 0;
}

MQ_EXPORT mq_u64 mq_f32_to_ml_raw(mq_u32 bits) {
    return ((mq_u64)bits << 3) | MQ_ML_TAG_FLOAT;
}

MQ_EXPORT const char *mq_f32_to_text(mq_u32 bits) {
    static char buffers[8][48];
    static mq_u32 index = 0;
    char *output;
    index = (index + 1u) & 7u;
    output = buffers[index];
    sprintf(output, "%.9g", (double)mq_bits_to_float(bits));
    return output;
}

MQ_EXPORT mq_u32 mq_f32_sin(mq_u32 bits) {
    return mq_float_to_bits((float)sin((double)mq_bits_to_float(bits)));
}

MQ_EXPORT mq_u32 mq_f32_cos(mq_u32 bits) {
    return mq_float_to_bits((float)cos((double)mq_bits_to_float(bits)));
}

MQ_EXPORT mq_u32 mq_f32_sqrt(mq_u32 bits) {
    return mq_float_to_bits((float)sqrt((double)mq_bits_to_float(bits)));
}

MQ_EXPORT mq_u32 mq_f32_atan2(mq_u32 y_bits, mq_u32 x_bits) {
    return mq_float_to_bits((float)atan2((double)mq_bits_to_float(y_bits), (double)mq_bits_to_float(x_bits)));
}

MQ_EXPORT mq_i32 mq_f32_to_i32_trunc(mq_u32 bits) {
    return (mq_i32)mq_bits_to_float(bits);
}

MQ_EXPORT mq_u32 mq_i32_to_f32(mq_i32 value) {
    return mq_float_to_bits((float)value);
}

MQ_EXPORT mq_i32 mq_ascii_code(const char *text) {
    if (text == MQ_NULL || text[0] == 0) {
        return -1;
    }
    return (mq_i32)(mq_u8)text[0];
}

MQ_EXPORT const char *mq_ascii_char(mq_i32 value) {
    static char output[2];
    output[0] = (char)(value & 255);
    output[1] = 0;
    return output;
}

MQ_EXPORT mq_ptr mq_win_create(const unsigned short *title, mq_i32 width, mq_i32 height, mq_i32 fullscreen) {
    MQ_WNDCLASSEXW window_class;
    MQ_PIXELFORMATDESCRIPTOR pixel_format;
    MQ_RECT rectangle;
    DWORD style;
    DWORD ex_style;
    mq_i32 window_x;
    mq_i32 window_y;
    mq_i32 window_width;
    mq_i32 window_height;
    mq_i32 chosen_format;

    if (mq_window != MQ_NULL) {
        return mq_window;
    }
    if (width < 1 || height < 1) {
        return MQ_NULL;
    }

    mq_instance = GetModuleHandleW(MQ_NULL);
    if (mq_instance == MQ_NULL) {
        return MQ_NULL;
    }

    if (!mq_class_registered) {
        window_class.cbSize = (UINT)sizeof(window_class);
        window_class.style = MQ_CS_OWNDC | MQ_CS_HREDRAW | MQ_CS_VREDRAW;
        window_class.lpfnWndProc = mq_window_proc;
        window_class.cbClsExtra = 0;
        window_class.cbWndExtra = 0;
        window_class.hInstance = mq_instance;
        window_class.hIcon = LoadIconW(MQ_NULL, MQ_IDI_APPLICATION);
        window_class.hCursor = LoadCursorW(MQ_NULL, MQ_IDC_ARROW);
        window_class.hbrBackground = MQ_NULL;
        window_class.lpszMenuName = MQ_NULL;
        window_class.lpszClassName = mq_window_class_name;
        window_class.hIconSm = window_class.hIcon;
        if (RegisterClassExW(&window_class) == 0) {
            return MQ_NULL;
        }
        mq_class_registered = 1;
    }

    ex_style = MQ_WS_EX_APPWINDOW;
    if (fullscreen) {
        style = MQ_WS_POPUP | MQ_WS_VISIBLE;
        window_x = 0;
        window_y = 0;
        window_width = GetSystemMetrics(MQ_SM_CXSCREEN);
        window_height = GetSystemMetrics(MQ_SM_CYSCREEN);
    } else {
        style = MQ_WS_OVERLAPPEDWINDOW | MQ_WS_VISIBLE;
        rectangle.left = 0;
        rectangle.top = 0;
        rectangle.right = width;
        rectangle.bottom = height;
        AdjustWindowRectEx(&rectangle, style, MQ_FALSE, ex_style);
        window_width = rectangle.right - rectangle.left;
        window_height = rectangle.bottom - rectangle.top;
        window_x = MQ_CW_USEDEFAULT;
        window_y = MQ_CW_USEDEFAULT;
    }

    mq_window = CreateWindowExW(
        ex_style,
        mq_window_class_name,
        title,
        style,
        window_x,
        window_y,
        window_width,
        window_height,
        MQ_NULL,
        MQ_NULL,
        mq_instance,
        MQ_NULL
    );
    if (mq_window == MQ_NULL) {
        return MQ_NULL;
    }

    mq_window_dc = GetDC(mq_window);
    if (mq_window_dc == MQ_NULL) {
        mq_win_destroy();
        return MQ_NULL;
    }

    pixel_format.nSize = (WORD)sizeof(pixel_format);
    pixel_format.nVersion = 1;
    pixel_format.dwFlags = MQ_PFD_DRAW_TO_WINDOW | MQ_PFD_SUPPORT_OPENGL | MQ_PFD_DOUBLEBUFFER;
    pixel_format.iPixelType = MQ_PFD_TYPE_RGBA;
    pixel_format.cColorBits = 32;
    pixel_format.cRedBits = 0;
    pixel_format.cRedShift = 0;
    pixel_format.cGreenBits = 0;
    pixel_format.cGreenShift = 0;
    pixel_format.cBlueBits = 0;
    pixel_format.cBlueShift = 0;
    pixel_format.cAlphaBits = 8;
    pixel_format.cAlphaShift = 0;
    pixel_format.cAccumBits = 0;
    pixel_format.cAccumRedBits = 0;
    pixel_format.cAccumGreenBits = 0;
    pixel_format.cAccumBlueBits = 0;
    pixel_format.cAccumAlphaBits = 0;
    pixel_format.cDepthBits = 24;
    pixel_format.cStencilBits = 8;
    pixel_format.cAuxBuffers = 0;
    pixel_format.iLayerType = MQ_PFD_MAIN_PLANE;
    pixel_format.bReserved = 0;
    pixel_format.dwLayerMask = 0;
    pixel_format.dwVisibleMask = 0;
    pixel_format.dwDamageMask = 0;

    chosen_format = ChoosePixelFormat(mq_window_dc, &pixel_format);
    if (chosen_format == 0 || !SetPixelFormat(mq_window_dc, chosen_format, &pixel_format)) {
        mq_win_destroy();
        return MQ_NULL;
    }

    mq_gl_context = wglCreateContext(mq_window_dc);
    if (mq_gl_context == MQ_NULL || !wglMakeCurrent(mq_window_dc, mq_gl_context)) {
        mq_win_destroy();
        return MQ_NULL;
    }

    ShowWindow(mq_window, MQ_SW_SHOW);
    UpdateWindow(mq_window);
    mq_clear_input_events();
    mq_running = 1;
    return mq_window;
}

MQ_EXPORT void mq_win_destroy(void) {
    mq_win_set_cursor_capture(0);
    if (mq_gl_context != MQ_NULL) {
        wglMakeCurrent(MQ_NULL, MQ_NULL);
        wglDeleteContext(mq_gl_context);
        mq_gl_context = MQ_NULL;
    }
    if (mq_window_dc != MQ_NULL && mq_window != MQ_NULL) {
        ReleaseDC(mq_window, mq_window_dc);
        mq_window_dc = MQ_NULL;
    }
    if (mq_window != MQ_NULL) {
        DestroyWindow(mq_window);
        mq_window = MQ_NULL;
    }
    mq_running = 0;
}

MQ_EXPORT mq_i32 mq_win_poll(void) {
    MQ_MSG message;
    MQ_POINT center;
    MQ_POINT current;

    mq_mouse_delta_x = 0;
    mq_mouse_delta_y = 0;
    while (PeekMessageW(&message, MQ_NULL, 0, 0, MQ_PM_REMOVE)) {
        if (message.message == MQ_WM_QUIT) {
            mq_running = 0;
        }
        TranslateMessage(&message);
        DispatchMessageW(&message);
    }

    if (mq_running && mq_cursor_captured && mq_window != MQ_NULL && GetForegroundWindow() == mq_window) {
        MQ_RECT rectangle;
        if (GetClientRect(mq_window, &rectangle)) {
            center.x = (rectangle.right - rectangle.left) / 2;
            center.y = (rectangle.bottom - rectangle.top) / 2;
            ClientToScreen(mq_window, &center);
            if (!mq_mouse_ready) {
                /* Capture/focus transition: recenter and deliberately discard
                 * this sample.  Otherwise it can be hundreds of pixels and
                 * immediately drive pitch to -70/+80 degrees. */
                SetCursorPos(center.x, center.y);
                mq_mouse_ready = 1;
            } else if (GetCursorPos(&current)) {
                mq_mouse_delta_x = current.x - center.x;
                mq_mouse_delta_y = current.y - center.y;
                if (mq_abs_i32(mq_mouse_delta_x) > 0 || mq_abs_i32(mq_mouse_delta_y) > 0) {
                    SetCursorPos(center.x, center.y);
                }
            }
        }
    } else {
        mq_mouse_ready = 0;
    }
    return mq_running;
}

MQ_EXPORT void mq_win_swap(void) {
    if (mq_window_dc != MQ_NULL) {
        SwapBuffers(mq_window_dc);
    }
}

MQ_EXPORT mq_i32 mq_win_key_down(mq_i32 virtual_key) {
    return (GetAsyncKeyState(virtual_key) & 0x8000) != 0;
}

MQ_EXPORT mq_i32 mq_win_key_pressed(mq_i32 virtual_key) {
    mq_i32 result;
    if (virtual_key < 0 || virtual_key >= 256) {
        return 0;
    }
    result = mq_key_pressed[(mq_u32)virtual_key] != 0;
    mq_key_pressed[(mq_u32)virtual_key] = 0;
    return result;
}

MQ_EXPORT mq_i32 mq_win_text_pop(void) {
    mq_u16 character;
    if (mq_text_tail == mq_text_head) {
        return -1;
    }
    character = mq_text_queue[mq_text_tail];
    mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    return (mq_i32)character;
}

MQ_EXPORT mq_i32 mq_win_has_focus(void) {
    return mq_window != MQ_NULL && GetForegroundWindow() == mq_window;
}

MQ_EXPORT mq_i32 mq_win_client_width(void) {
    MQ_RECT rectangle;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    return rectangle.right - rectangle.left;
}

MQ_EXPORT mq_i32 mq_win_client_height(void) {
    MQ_RECT rectangle;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    return rectangle.bottom - rectangle.top;
}

MQ_EXPORT void mq_win_set_title(const unsigned short *title) {
    if (mq_window != MQ_NULL && title != MQ_NULL) {
        SetWindowTextW(mq_window, title);
    }
}

MQ_EXPORT void mq_win_set_cursor_capture(mq_i32 enabled) {
    if (enabled && !mq_cursor_captured) {
        while (ShowCursor(MQ_FALSE) >= 0) { }
        mq_cursor_captured = 1;
        mq_mouse_ready = 0;
        mq_mouse_delta_x = 0;
        mq_mouse_delta_y = 0;
        mq_center_mouse_cursor();
    } else if (!enabled && mq_cursor_captured) {
        while (ShowCursor(MQ_TRUE) < 0) { }
        mq_cursor_captured = 0;
        mq_mouse_ready = 0;
        mq_mouse_delta_x = 0;
        mq_mouse_delta_y = 0;
    }
}

MQ_EXPORT mq_i32 mq_win_mouse_dx(void) {
    mq_i32 value = mq_mouse_delta_x;
    mq_mouse_delta_x = 0;
    return value;
}

MQ_EXPORT mq_i32 mq_win_mouse_dy(void) {
    mq_i32 value = mq_mouse_delta_y;
    mq_mouse_delta_y = 0;
    return value;
}

MQ_EXPORT mq_i32 mq_win_mouse_buttons(void) {
    mq_i32 buttons = 0;
    if (GetAsyncKeyState(MQ_VK_LBUTTON) & 0x8000) buttons |= 1;
    if (GetAsyncKeyState(MQ_VK_RBUTTON) & 0x8000) buttons |= 2;
    if (GetAsyncKeyState(MQ_VK_MBUTTON) & 0x8000) buttons |= 4;
    return buttons;
}

MQ_EXPORT mq_i32 mq_win_mouse_wheel(void) {
    mq_i32 value = mq_mouse_wheel_delta;
    mq_mouse_wheel_delta = 0;
    return value;
}

MQ_EXPORT mq_u32 mq_win_ticks(void) {
    return GetTickCount();
}

MQ_EXPORT void mq_win_sleep(mq_u32 milliseconds) {
    Sleep(milliseconds);
}

MQ_EXPORT mq_i32 mq_audio_open(mq_u32 sample_rate, mq_u32 channels, mq_u32 bits_per_sample) {
    MQ_WAVEFORMATEX format;
    mq_u32 i;
    if (mq_wave_output != MQ_NULL) {
        return 1;
    }
    if (sample_rate < 8000 || channels < 1 || channels > 2 || (bits_per_sample != 8 && bits_per_sample != 16)) {
        return 0;
    }
    format.wFormatTag = MQ_WAVE_FORMAT_PCM;
    format.nChannels = (WORD)channels;
    format.nSamplesPerSec = sample_rate;
    format.wBitsPerSample = (WORD)bits_per_sample;
    format.nBlockAlign = (WORD)((channels * bits_per_sample) / 8u);
    format.nAvgBytesPerSec = sample_rate * (DWORD)format.nBlockAlign;
    format.cbSize = 0;
    if (waveOutOpen(&mq_wave_output, MQ_WAVE_MAPPER, &format, 0, 0, MQ_CALLBACK_NULL) != 0) {
        mq_wave_output = MQ_NULL;
        return 0;
    }
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        mq_audio_headers[i].lpData = (CHAR *)mq_audio_data[i];
        mq_audio_headers[i].dwBufferLength = 0;
        mq_audio_headers[i].dwBytesRecorded = 0;
        mq_audio_headers[i].dwUser = 0;
        mq_audio_headers[i].dwFlags = 0;
        mq_audio_headers[i].dwLoops = 0;
        mq_audio_headers[i].lpNext = MQ_NULL;
        mq_audio_headers[i].reserved = 0;
    }
    mq_audio_next_buffer = 0;
    mq_audio_buffer_count = 0;
    return 1;
}

MQ_EXPORT mq_i32 mq_audio_submit(const void *data, mq_u32 byte_count) {
    MQ_WAVEHDR *header = MQ_NULL;
    mq_u32 attempt;
    mq_u32 selected = 0;
    if (mq_wave_output == MQ_NULL || data == MQ_NULL || byte_count == 0 || byte_count > MQ_AUDIO_BUFFER_BYTES) {
        return 0;
    }

    /* Do not stall merely because the next ring slot is still active.  Windows
     * can complete waveOut headers out of phase with our submit cadence, so
     * scan the complete ring for an unused or completed buffer. */
    for (attempt = 0; attempt < MQ_AUDIO_BUFFER_COUNT; ++attempt) {
        mq_u32 index = (mq_audio_next_buffer + attempt) % MQ_AUDIO_BUFFER_COUNT;
        MQ_WAVEHDR *candidate = &mq_audio_headers[index];
        if ((candidate->dwFlags & MQ_WHDR_PREPARED) == 0 || (candidate->dwFlags & MQ_WHDR_DONE) != 0) {
            header = candidate;
            selected = index;
            break;
        }
    }
    if (header == MQ_NULL) {
        return 0;
    }
    if ((header->dwFlags & MQ_WHDR_PREPARED) != 0) {
        waveOutUnprepareHeader(mq_wave_output, header, (UINT)sizeof(*header));
        if (mq_audio_buffer_count > 0) {
            --mq_audio_buffer_count;
        }
    }
    mq_copy_bytes((mq_u8 *)header->lpData, (const mq_u8 *)data, byte_count);
    header->dwBufferLength = byte_count;
    header->dwBytesRecorded = 0;
    header->dwFlags = 0;
    header->dwLoops = 0;
    if (waveOutPrepareHeader(mq_wave_output, header, (UINT)sizeof(*header)) != 0) {
        return 0;
    }
    if (waveOutWrite(mq_wave_output, header, (UINT)sizeof(*header)) != 0) {
        waveOutUnprepareHeader(mq_wave_output, header, (UINT)sizeof(*header));
        return 0;
    }
    mq_audio_next_buffer = (selected + 1u) % MQ_AUDIO_BUFFER_COUNT;
    if (mq_audio_buffer_count < MQ_AUDIO_BUFFER_COUNT) {
        ++mq_audio_buffer_count;
    }
    return 1;
}

MQ_EXPORT void mq_audio_close(void) {
    mq_u32 i;
    if (mq_wave_output == MQ_NULL) {
        return;
    }
    waveOutReset(mq_wave_output);
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        if (mq_audio_headers[i].dwFlags & MQ_WHDR_PREPARED) {
            waveOutUnprepareHeader(mq_wave_output, &mq_audio_headers[i], (UINT)sizeof(MQ_WAVEHDR));
            mq_audio_headers[i].dwFlags = 0;
        }
    }
    waveOutClose(mq_wave_output);
    mq_wave_output = MQ_NULL;
    mq_audio_buffer_count = 0;
}

MQ_EXPORT mq_u32 mq_audio_queued(void) {
    mq_u32 i;
    mq_u32 queued = 0;
    if (mq_wave_output == MQ_NULL) {
        return 0;
    }
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        if ((mq_audio_headers[i].dwFlags & MQ_WHDR_PREPARED) && !(mq_audio_headers[i].dwFlags & MQ_WHDR_DONE)) {
            ++queued;
        }
    }
    return queued;
}

MQ_EXPORT mq_u64 mq_udp_open(mq_u32 port) {
    SOCKET socket_value;
    MQ_SOCKADDR_IN address;
    mq_u32 nonblocking = 1;
    if (port > 65535u || !mq_winsock_start()) {
        return 0;
    }
    socket_value = socket(MQ_AF_INET, MQ_SOCK_DGRAM, MQ_IPPROTO_UDP);
    if (socket_value == MQ_INVALID_SOCKET) {
        mq_udp_last_error_value = WSAGetLastError();
        return 0;
    }
    if (ioctlsocket(socket_value, MQ_FIONBIO, &nonblocking) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        closesocket(socket_value);
        return 0;
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    address.sin_family = (mq_u16)MQ_AF_INET;
    address.sin_port = htons((mq_u16)port);
    address.sin_addr = 0;
    if (bind(socket_value, &address, (mq_i32)sizeof(address)) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        closesocket(socket_value);
        return 0;
    }
    ++mq_udp_socket_count;
    mq_udp_last_error_value = 0;
    return (mq_u64)socket_value;
}

MQ_EXPORT void mq_udp_close(mq_u64 handle) {
    SOCKET socket_value = (SOCKET)handle;
    if (handle == 0 || socket_value == MQ_INVALID_SOCKET) {
        return;
    }
    closesocket(socket_value);
    if (mq_udp_socket_count > 0) {
        --mq_udp_socket_count;
    }
    if (mq_udp_socket_count == 0 && mq_winsock_started) {
        WSACleanup();
        mq_winsock_started = 0;
    }
}

MQ_EXPORT mq_u32 mq_udp_bound_port(mq_u64 handle) {
    MQ_SOCKADDR_IN address;
    mq_i32 address_length = (mq_i32)sizeof(address);
    if (handle == 0) {
        return 0;
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    if (getsockname((SOCKET)handle, &address, &address_length) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        return 0;
    }
    return (mq_u32)ntohs(address.sin_port);
}

MQ_EXPORT mq_i32 mq_udp_send(mq_u64 handle, const char *address_text, mq_u32 port, const void *data, mq_u32 byte_count) {
    MQ_SOCKADDR_IN address;
    mq_u32 parsed_address;
    mq_i32 result;
    if (handle == 0 || address_text == MQ_NULL || data == MQ_NULL || byte_count > 65507u || port > 65535u) {
        mq_udp_last_error_value = -1;
        return -1;
    }
    parsed_address = inet_addr(address_text);
    if (parsed_address == MQ_INADDR_NONE) {
        mq_udp_last_error_value = -2;
        return -1;
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    address.sin_family = (mq_u16)MQ_AF_INET;
    address.sin_port = htons((mq_u16)port);
    address.sin_addr = parsed_address;
    result = sendto((SOCKET)handle, (const char *)data, (mq_i32)byte_count, 0, &address, (mq_i32)sizeof(address));
    if (result == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        return -1;
    }
    mq_udp_last_error_value = 0;
    return result;
}

MQ_EXPORT mq_i32 mq_udp_receive(mq_u64 handle, void *data, mq_u32 capacity) {
    MQ_SOCKADDR_IN address;
    mq_i32 address_length = (mq_i32)sizeof(address);
    mq_i32 result;
    if (handle == 0 || data == MQ_NULL || capacity == 0 || capacity > 65535u) {
        mq_udp_last_error_value = -1;
        return -1;
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    result = recvfrom((SOCKET)handle, (char *)data, (mq_i32)capacity, 0, &address, &address_length);
    if (result == MQ_SOCKET_ERROR) {
        mq_i32 error_code = WSAGetLastError();
        if (error_code == MQ_WSAEWOULDBLOCK) {
            mq_udp_last_error_value = 0;
            return 0;
        }
        mq_udp_last_error_value = error_code;
        return -1;
    }
    mq_udp_remember_address(&address);
    mq_udp_last_error_value = 0;
    return result;
}

MQ_EXPORT const char *mq_udp_last_address(void) { return mq_udp_last_address_text; }
MQ_EXPORT mq_u32 mq_udp_last_port(void) { return mq_udp_last_port_value; }
MQ_EXPORT mq_i32 mq_udp_last_error(void) { return mq_udp_last_error_value; }

MQ_EXPORT void mq_gl_begin(mq_u32 mode) { glBegin(mode); }
MQ_EXPORT void mq_gl_end(void) { glEnd(); }
MQ_EXPORT void mq_gl_vertex2(mq_u32 x_bits, mq_u32 y_bits) { glVertex2f(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits)); }
MQ_EXPORT void mq_gl_vertex3(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { glVertex3f(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
MQ_EXPORT void mq_gl_texcoord2(mq_u32 s_bits, mq_u32 t_bits) { glTexCoord2f(mq_bits_to_float(s_bits), mq_bits_to_float(t_bits)); }
MQ_EXPORT void mq_gl_color4ub(mq_u32 r, mq_u32 g, mq_u32 b, mq_u32 a) { glColor4ub((mq_u8)r, (mq_u8)g, (mq_u8)b, (mq_u8)a); }
MQ_EXPORT void mq_gl_clear_color(mq_u32 r_bits, mq_u32 g_bits, mq_u32 b_bits, mq_u32 a_bits) { glClearColor(mq_bits_to_float(r_bits), mq_bits_to_float(g_bits), mq_bits_to_float(b_bits), mq_bits_to_float(a_bits)); }
MQ_EXPORT void mq_gl_clear(mq_u32 mask) { glClear(mask); }
MQ_EXPORT void mq_gl_enable(mq_u32 capability) { glEnable(capability); }
MQ_EXPORT void mq_gl_disable(mq_u32 capability) { glDisable(capability); }
MQ_EXPORT void mq_gl_blend_func(mq_u32 source, mq_u32 destination) { glBlendFunc(source, destination); }
MQ_EXPORT void mq_gl_depth_func(mq_u32 function_name) { glDepthFunc(function_name); }
MQ_EXPORT void mq_gl_depth_mask(mq_i32 enabled) { glDepthMask((mq_u8)(enabled != 0)); }
MQ_EXPORT void mq_gl_depth_range(mq_u32 near_bits, mq_u32 far_bits) { glDepthRange((double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
MQ_EXPORT void mq_gl_alpha_func(mq_u32 function_name, mq_u32 reference_bits) { glAlphaFunc(function_name, mq_bits_to_float(reference_bits)); }
MQ_EXPORT void mq_gl_cull_face(mq_u32 mode) { glCullFace(mode); }
MQ_EXPORT void mq_gl_shade_model(mq_u32 mode) { glShadeModel(mode); }
MQ_EXPORT void mq_gl_polygon_mode(mq_u32 face, mq_u32 mode) { glPolygonMode(face, mode); }
MQ_EXPORT void mq_gl_viewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height) { glViewport(x, y, width, height); }
MQ_EXPORT void mq_gl_matrix_mode(mq_u32 mode) { glMatrixMode(mode); }
MQ_EXPORT void mq_gl_load_identity(void) { glLoadIdentity(); }
MQ_EXPORT void mq_gl_push_matrix(void) { glPushMatrix(); }
MQ_EXPORT void mq_gl_pop_matrix(void) { glPopMatrix(); }
MQ_EXPORT void mq_gl_translate(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { glTranslatef(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
MQ_EXPORT void mq_gl_rotate(mq_u32 angle_bits, mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { glRotatef(mq_bits_to_float(angle_bits), mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
MQ_EXPORT void mq_gl_scale(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { glScalef(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
MQ_EXPORT void mq_gl_ortho(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { glOrtho((double)mq_bits_to_float(left_bits), (double)mq_bits_to_float(right_bits), (double)mq_bits_to_float(bottom_bits), (double)mq_bits_to_float(top_bits), (double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
MQ_EXPORT void mq_gl_frustum(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { glFrustum((double)mq_bits_to_float(left_bits), (double)mq_bits_to_float(right_bits), (double)mq_bits_to_float(bottom_bits), (double)mq_bits_to_float(top_bits), (double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
MQ_EXPORT void mq_gl_bind_texture(mq_u32 target, mq_u32 texture) { glBindTexture(target, texture); }
MQ_EXPORT void mq_gl_gen_textures(mq_i32 count, void *texture_ids) { glGenTextures(count, (mq_u32 *)texture_ids); }
MQ_EXPORT void mq_gl_delete_textures(mq_i32 count, const void *texture_ids) { glDeleteTextures(count, (const mq_u32 *)texture_ids); }
MQ_EXPORT void mq_gl_tex_parameter_i(mq_u32 target, mq_u32 name, mq_i32 value) { glTexParameteri(target, name, value); }
MQ_EXPORT void mq_gl_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels) { glTexImage2D(target, level, internal_format, width, height, border, format, type, pixels); }
MQ_EXPORT void mq_gl_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels) { glTexSubImage2D(target, level, x_offset, y_offset, width, height, format, type, pixels); }
MQ_EXPORT void mq_gl_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels) { glReadPixels(x, y, width, height, format, type, pixels); }
MQ_EXPORT const char *mq_gl_get_string(mq_u32 name) { return (const char *)glGetString(name); }
MQ_EXPORT mq_u32 mq_gl_get_error(void) { return glGetError(); }
MQ_EXPORT void mq_gl_finish(void) { glFinish(); }
MQ_EXPORT void mq_gl_flush(void) { glFlush(); }
