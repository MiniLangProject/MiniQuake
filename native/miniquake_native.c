/*
 * MiniQuake native platform bridge.
 *
 * Copyright (c) 1996-1997 Id Software, Inc.
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * The bridge intentionally has a narrow C ABI consisting only of integer,
 * pointer and C/W-string values supported by MiniLang's extern mechanism.
 * IEEE-754 values cross the ABI as their 32-bit bit patterns.
 */
#include "miniquake_native.h"
#include "miniquake_d3d9.h"
#include "miniquake_vulkan.h"
#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_CDECL __cdecl

#define MQ_RENDER_OPENGL 0
#define MQ_RENDER_DIRECT3D9 1
#define MQ_RENDER_VULKAN 2
static mq_i32 mq_render_backend_value = MQ_RENDER_OPENGL;

/* Find one complete token in an OpenGL extension string without CRT helpers. */
static mq_i32 mq_gl_extension_present(const char *extensions, const char *name) {
    const char *start;
    if (extensions == (const char *)0 || name == (const char *)0 || *name == 0) return 0;
    start = extensions;
    while (*start != 0) {
        const char *left;
        const char *right;
        while (*start == ' ') ++start;
        left = start;
        right = name;
        while (*left != 0 && *left != ' ' && *right != 0 && *left == *right) { ++left; ++right; }
        if (*right == 0 && (*left == 0 || *left == ' ')) return 1;
        while (*start != 0 && *start != ' ') ++start;
    }
    return 0;
}

/* Wait for readiness on the requested socket set. */
MQ_EXPORT mq_i32 mq_render_select(mq_i32 backend) {
    if (backend != MQ_RENDER_OPENGL && backend != MQ_RENDER_DIRECT3D9 && backend != MQ_RENDER_VULKAN) return 0;
    if (backend == MQ_RENDER_DIRECT3D9 && !mq_d3d9_available()) return 0;
    if (backend == MQ_RENDER_VULKAN && !mq_vulkan_available()) return 0;
    mq_render_backend_value = backend;
    return 1;
}

/* Return the current backend value. */
MQ_EXPORT mq_i32 mq_render_backend(void) { return mq_render_backend_value; }
/* Report whether available is available. */
MQ_EXPORT mq_i32 mq_render_available(mq_i32 backend) {
    if (backend == MQ_RENDER_OPENGL) return 1;
    if (backend == MQ_RENDER_DIRECT3D9) return mq_d3d9_available();
    if (backend == MQ_RENDER_VULKAN) return mq_vulkan_available();
    return 0;
}

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

/* Mirror the Win32 sockaddr in ABI layout without requiring SDK declarations. */
typedef struct MQ_SOCKADDR_IN {
    mq_u16 sin_family;
    mq_u16 sin_port;
    mq_u32 sin_addr;
    mq_u8 sin_zero[8];
} MQ_SOCKADDR_IN;

/* Mirror the Win32 hostent ABI layout without requiring SDK declarations. */
typedef struct MQ_HOSTENT {
    char *h_name;
    char **h_aliases;
    mq_i16 h_addrtype;
    mq_i16 h_length;
    char **h_addr_list;
} MQ_HOSTENT;

/* Mirror the Win32 point ABI layout without requiring SDK declarations. */
typedef struct MQ_POINT {
    LONG x;
    LONG y;
} MQ_POINT;

/* Mirror the Win32 coord ABI layout without requiring SDK declarations. */
typedef struct MQ_COORD {
    mq_i16 X;
    mq_i16 Y;
} MQ_COORD;

/* Mirror the Win32 small rect ABI layout without requiring SDK declarations. */
typedef struct MQ_SMALL_RECT {
    mq_i16 Left;
    mq_i16 Top;
    mq_i16 Right;
    mq_i16 Bottom;
} MQ_SMALL_RECT;

/* Mirror the Win32 console screen buffer info ABI layout without requiring SDK declarations. */
typedef struct MQ_CONSOLE_SCREEN_BUFFER_INFO {
    MQ_COORD dwSize;
    MQ_COORD dwCursorPosition;
    WORD wAttributes;
    MQ_SMALL_RECT srWindow;
    MQ_COORD dwMaximumWindowSize;
} MQ_CONSOLE_SCREEN_BUFFER_INFO;

/* Mirror the Win32 key event record ABI layout without requiring SDK declarations. */
typedef struct MQ_KEY_EVENT_RECORD {
    BOOL bKeyDown;
    WORD wRepeatCount;
    WORD wVirtualKeyCode;
    WORD wVirtualScanCode;
    union {
        WCHAR UnicodeChar;
        CHAR AsciiChar;
    } uChar;
    DWORD dwControlKeyState;
} MQ_KEY_EVENT_RECORD;

/* Mirror the Win32 input record ABI layout without requiring SDK declarations. */
typedef struct MQ_INPUT_RECORD {
    WORD EventType;
    union {
        MQ_KEY_EVENT_RECORD KeyEvent;
        mq_u8 padding[16];
    } Event;
} MQ_INPUT_RECORD;

/* Mirror the Win32 rect ABI layout without requiring SDK declarations. */
typedef struct MQ_RECT {
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
} MQ_RECT;

/* Mirror the Win32 msg ABI layout without requiring SDK declarations. */
typedef struct MQ_MSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    MQ_POINT pt;
    DWORD lPrivate;
} MQ_MSG;

/* Mirror the Win32 raw-input mouse ABI without requiring SDK declarations. */
typedef struct MQ_RAWINPUTDEVICE {
    WORD usage_page;
    WORD usage;
    DWORD flags;
    HWND target;
} MQ_RAWINPUTDEVICE;

/* Mirror the Win32 raw-input header ABI without requiring SDK declarations. */
typedef struct MQ_RAWINPUTHEADER {
    DWORD type;
    DWORD size;
    HANDLE device;
    WPARAM parameter;
} MQ_RAWINPUTHEADER;

/* Mirror the Win32 raw mouse payload ABI without requiring SDK declarations. */
typedef struct MQ_RAWMOUSE {
    WORD flags;
    WORD padding;
    DWORD buttons;
    DWORD raw_buttons;
    LONG last_x;
    LONG last_y;
    DWORD extra_information;
} MQ_RAWMOUSE;

/* Raw keyboard/HID payloads are intentionally not decoded by this bridge. */
typedef struct MQ_RAWINPUT {
    MQ_RAWINPUTHEADER header;
    MQ_RAWMOUSE mouse;
} MQ_RAWINPUT;

typedef LRESULT (MQ_WINAPI *MQ_WNDPROC)(HWND, UINT, WPARAM, LPARAM);

/* Mirror the Win32 wndclassexw ABI layout without requiring SDK declarations. */
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

/* Mirror the Win32 pixelformatdescriptor ABI layout without requiring SDK declarations. */
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

/* Mirror the Win32 pointl ABI layout without requiring SDK declarations. */
typedef struct MQ_POINTL {
    LONG x;
    LONG y;
} MQ_POINTL;

/* Mirror the Win32 devmodew ABI layout without requiring SDK declarations. */
typedef struct MQ_DEVMODEW {
    WCHAR dmDeviceName[32];
    WORD dmSpecVersion;
    WORD dmDriverVersion;
    WORD dmSize;
    WORD dmDriverExtra;
    DWORD dmFields;
    union {
        struct {
            mq_i16 dmOrientation;
            mq_i16 dmPaperSize;
            mq_i16 dmPaperLength;
            mq_i16 dmPaperWidth;
            mq_i16 dmScale;
            mq_i16 dmCopies;
            mq_i16 dmDefaultSource;
            mq_i16 dmPrintQuality;
        } printer;
        struct {
            MQ_POINTL dmPosition;
            DWORD dmDisplayOrientation;
            DWORD dmDisplayFixedOutput;
        } display;
    } layout;
    mq_i16 dmColor;
    mq_i16 dmDuplex;
    mq_i16 dmYResolution;
    mq_i16 dmTTOption;
    mq_i16 dmCollate;
    WCHAR dmFormName[32];
    WORD dmLogPixels;
    DWORD dmBitsPerPel;
    DWORD dmPelsWidth;
    DWORD dmPelsHeight;
    union {
        DWORD dmDisplayFlags;
        DWORD dmNup;
    } flags;
    DWORD dmDisplayFrequency;
    DWORD dmICMMethod;
    DWORD dmICMIntent;
    DWORD dmMediaType;
    DWORD dmDitherType;
    DWORD dmReserved1;
    DWORD dmReserved2;
    DWORD dmPanningWidth;
    DWORD dmPanningHeight;
} MQ_DEVMODEW;

/* Mirror the Win32 waveformatex ABI layout without requiring SDK declarations. */
typedef struct MQ_WAVEFORMATEX {
    WORD wFormatTag;
    WORD nChannels;
    DWORD nSamplesPerSec;
    DWORD nAvgBytesPerSec;
    WORD nBlockAlign;
    WORD wBitsPerSample;
    WORD cbSize;
} MQ_WAVEFORMATEX;

/* Mirror the Win32 wavehdr ABI layout without requiring SDK declarations. */
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

/* Mirror the Win32 mmtime ABI layout without requiring SDK declarations. */
typedef struct MQ_MMTIME {
    UINT wType;
    union {
        DWORD ms;
        DWORD sample;
        DWORD cb;
        DWORD ticks;
        BYTE smpte[8];
        DWORD midi[2];
    } u;
} MQ_MMTIME;

/* Mirror the Win32 joyinfoex ABI layout without requiring SDK declarations. */
typedef struct MQ_JOYINFOEX {
    DWORD dwSize;
    DWORD dwFlags;
    DWORD dwXpos;
    DWORD dwYpos;
    DWORD dwZpos;
    DWORD dwRpos;
    DWORD dwUpos;
    DWORD dwVpos;
    DWORD dwButtons;
    DWORD dwButtonNumber;
    DWORD dwPOV;
    DWORD dwReserved1;
    DWORD dwReserved2;
} MQ_JOYINFOEX;

/* Mirror the Win32 joycapsw ABI layout without requiring SDK declarations. */
typedef struct MQ_JOYCAPSW {
    WORD wMid;
    WORD wPid;
    WCHAR szPname[32];
    UINT wXmin;
    UINT wXmax;
    UINT wYmin;
    UINT wYmax;
    UINT wZmin;
    UINT wZmax;
    UINT wNumButtons;
    UINT wPeriodMin;
    UINT wPeriodMax;
    UINT wRmin;
    UINT wRmax;
    UINT wUmin;
    UINT wUmax;
    UINT wVmin;
    UINT wVmax;
    UINT wCaps;
    UINT wMaxAxes;
    UINT wNumAxes;
    UINT wMaxButtons;
    WCHAR szRegKey[32];
    WCHAR szOEMVxD[260];
} MQ_JOYCAPSW;

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

/* Group the fields that describe one ml float object. */
typedef struct MQ_ML_FLOAT_OBJECT {
    mq_u32 type;
    mq_u32 padding;
    double value;
} MQ_ML_FLOAT_OBJECT;

/* msvcrt */
MQ_DLLIMPORT double MQ_CDECL strtod(const char *text, char **end_pointer);
MQ_DLLIMPORT int MQ_CDECL sprintf(char *buffer, const char *format, ...);
MQ_DLLIMPORT void *MQ_CDECL memcpy(void *destination, const void *source, mq_u64 count);
MQ_DLLIMPORT void *MQ_CDECL memset(void *destination, mq_i32 value, mq_u64 count);
MQ_DLLIMPORT double MQ_CDECL sin(double value);
MQ_DLLIMPORT double MQ_CDECL cos(double value);
MQ_DLLIMPORT double MQ_CDECL sqrt(double value);
MQ_DLLIMPORT float MQ_CDECL sqrtf(float value);
MQ_DLLIMPORT double MQ_CDECL atan2(double y, double x);
MQ_DLLIMPORT double MQ_CDECL pow(double base, double exponent);

/* kernel32 */
MQ_DLLIMPORT HMODULE MQ_WINAPI GetModuleHandleW(LPCWSTR name);
MQ_DLLIMPORT HANDLE MQ_WINAPI GetCurrentProcess(void);
MQ_DLLIMPORT BOOL MQ_WINAPI GetProcessHandleCount(HANDLE process, DWORD *handle_count);
MQ_DLLIMPORT DWORD MQ_WINAPI GetTickCount(void);
MQ_DLLIMPORT void MQ_WINAPI Sleep(DWORD milliseconds);
MQ_DLLIMPORT HANDLE MQ_WINAPI CreateEventW(void *security, BOOL manual_reset, BOOL initial_state, LPCWSTR name);
MQ_DLLIMPORT BOOL MQ_WINAPI SetEvent(HANDLE event_handle);
MQ_DLLIMPORT BOOL MQ_WINAPI CloseHandle(HANDLE handle);
MQ_DLLIMPORT DWORD MQ_WINAPI WaitForMultipleObjects(DWORD count, const HANDLE *handles, BOOL wait_all, DWORD milliseconds);
MQ_DLLIMPORT LPVOID MQ_WINAPI MapViewOfFile(HANDLE mapping, DWORD access, DWORD offset_high, DWORD offset_low, mq_u64 bytes_to_map);
MQ_DLLIMPORT BOOL MQ_WINAPI UnmapViewOfFile(LPCVOID address);
MQ_DLLIMPORT HANDLE MQ_WINAPI GetStdHandle(DWORD identifier);
MQ_DLLIMPORT BOOL MQ_WINAPI GetConsoleScreenBufferInfo(HANDLE output, MQ_CONSOLE_SCREEN_BUFFER_INFO *info);
MQ_DLLIMPORT MQ_COORD MQ_WINAPI GetLargestConsoleWindowSize(HANDLE output);
MQ_DLLIMPORT BOOL MQ_WINAPI SetConsoleWindowInfo(HANDLE output, BOOL absolute, const MQ_SMALL_RECT *window);
MQ_DLLIMPORT BOOL MQ_WINAPI SetConsoleScreenBufferSize(HANDLE output, MQ_COORD size);
MQ_DLLIMPORT BOOL MQ_WINAPI ReadConsoleOutputCharacterA(HANDLE output, char *text, DWORD length, MQ_COORD position, DWORD *read_count);
MQ_DLLIMPORT BOOL MQ_WINAPI WriteConsoleInputA(HANDLE input, const MQ_INPUT_RECORD *records, DWORD length, DWORD *written);
MQ_DLLIMPORT BOOL MQ_WINAPI QueryPerformanceCounter(mq_i64 *counter);
MQ_DLLIMPORT BOOL MQ_WINAPI QueryPerformanceFrequency(mq_i64 *frequency);
MQ_DLLIMPORT BOOL MQ_WINAPI VirtualProtect(LPVOID address, mq_u64 length, DWORD protection, DWORD *old_protection);
MQ_DLLIMPORT LPVOID MQ_WINAPI VirtualAlloc(LPVOID address, mq_u64 length, DWORD allocation_type, DWORD protection);
MQ_DLLIMPORT BOOL MQ_WINAPI VirtualFree(LPVOID address, mq_u64 length, DWORD free_type);
MQ_DLLIMPORT BOOL MQ_WINAPI GetNumberOfConsoleInputEvents(HANDLE input, DWORD *event_count);
MQ_DLLIMPORT BOOL MQ_WINAPI ReadConsoleInputA(HANDLE input, MQ_INPUT_RECORD *records, DWORD length, DWORD *read_count);
MQ_DLLIMPORT DWORD MQ_WINAPI GetFileType(HANDLE file);
MQ_DLLIMPORT BOOL MQ_WINAPI PeekNamedPipe(HANDLE pipe, LPVOID buffer, DWORD buffer_size, DWORD *bytes_read, DWORD *bytes_available, DWORD *bytes_left);
MQ_DLLIMPORT BOOL MQ_WINAPI ReadFile(HANDLE file, LPVOID buffer, DWORD length, DWORD *read_count, LPVOID overlapped);
MQ_DLLIMPORT BOOL MQ_WINAPI WriteFile(HANDLE file, LPCVOID buffer, DWORD length, DWORD *written, LPVOID overlapped);
MQ_DLLIMPORT BOOL MQ_WINAPI AllocConsole(void);
MQ_DLLIMPORT BOOL MQ_WINAPI FreeConsole(void);

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
MQ_DLLIMPORT BOOL MQ_WINAPI SetWindowPos(HWND window, HWND insert_after, mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, UINT flags);
MQ_DLLIMPORT LONG_PTR MQ_WINAPI SetWindowLongPtrW(HWND window, mq_i32 index, LONG_PTR value);
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
MQ_DLLIMPORT HANDLE MQ_WINAPI LoadImageW(HINSTANCE instance, LPCWSTR name, UINT type, mq_i32 width, mq_i32 height, UINT flags);
MQ_DLLIMPORT HDC MQ_WINAPI GetDC(HWND window);
MQ_DLLIMPORT mq_i32 MQ_WINAPI ReleaseDC(HWND window, HDC dc);
MQ_DLLIMPORT HWND MQ_WINAPI SetCapture(HWND window);
MQ_DLLIMPORT BOOL MQ_WINAPI ReleaseCapture(void);
MQ_DLLIMPORT BOOL MQ_WINAPI ClipCursor(const MQ_RECT *rect);
MQ_DLLIMPORT BOOL MQ_WINAPI RegisterRawInputDevices(const MQ_RAWINPUTDEVICE *devices, UINT count, UINT size);
MQ_DLLIMPORT UINT MQ_WINAPI GetRawInputData(HANDLE input, UINT command, LPVOID data, UINT *size, UINT header_size);
MQ_DLLIMPORT BOOL MQ_WINAPI EnumDisplaySettingsW(LPCWSTR device_name, DWORD mode_number, MQ_DEVMODEW *mode);
MQ_DLLIMPORT LONG MQ_WINAPI ChangeDisplaySettingsW(MQ_DEVMODEW *mode, DWORD flags);
MQ_DLLIMPORT BOOL MQ_WINAPI IsIconic(HWND window);
MQ_DLLIMPORT BOOL MQ_WINAPI SetForegroundWindow(HWND window);
MQ_DLLIMPORT mq_i32 MQ_WINAPI MessageBoxW(HWND window, LPCWSTR text, LPCWSTR caption, UINT flags);
MQ_DLLIMPORT DWORD MQ_WINAPI MsgWaitForMultipleObjects(DWORD count, const HANDLE *handles, BOOL wait_all, DWORD milliseconds, DWORD wake_mask);

/* gdi32 */
MQ_DLLIMPORT mq_i32 MQ_WINAPI ChoosePixelFormat(HDC dc, const MQ_PIXELFORMATDESCRIPTOR *descriptor);
MQ_DLLIMPORT BOOL MQ_WINAPI SetPixelFormat(HDC dc, mq_i32 format, const MQ_PIXELFORMATDESCRIPTOR *descriptor);
MQ_DLLIMPORT BOOL MQ_WINAPI SwapBuffers(HDC dc);
MQ_DLLIMPORT BOOL MQ_WINAPI GetDeviceGammaRamp(HDC dc, void *ramp);
MQ_DLLIMPORT BOOL MQ_WINAPI SetDeviceGammaRamp(HDC dc, const void *ramp);

/* opengl32 / WGL */
MQ_DLLIMPORT HGLRC MQ_WINAPI wglCreateContext(HDC dc);
MQ_DLLIMPORT BOOL MQ_WINAPI wglDeleteContext(HGLRC context);
MQ_DLLIMPORT BOOL MQ_WINAPI wglMakeCurrent(HDC dc, HGLRC context);
MQ_DLLIMPORT void *MQ_WINAPI wglGetProcAddress(const char *name);

/* Compact CPU BVH used by the backend-neutral projected ray-shadow path. */
typedef struct MQ_SHADOW_TRIANGLE {
    float vertex[9];
    float edge_a[3];
    float edge_b[3];
    float normal[3];
    float minimum[3];
    float maximum[3];
    float centroid[3];
    mq_u32 surface_id;
} MQ_SHADOW_TRIANGLE;

/* Store the native shadow-acceleration data for one shadow node. */
typedef struct MQ_SHADOW_NODE {
    float minimum[3];
    float maximum[3];
    mq_i32 left;
    mq_i32 right;
    mq_u32 start;
    mq_u32 count;
} MQ_SHADOW_NODE;

static MQ_SHADOW_TRIANGLE *mq_shadow_triangles = (MQ_SHADOW_TRIANGLE *)0;
static mq_u32 *mq_shadow_indices = (mq_u32 *)0;
static MQ_SHADOW_NODE *mq_shadow_nodes = (MQ_SHADOW_NODE *)0;
static mq_u32 mq_shadow_triangle_count = 0u;
static mq_u32 mq_shadow_node_count = 0u;

/*
 * Projected entity shadows submit the same immutable world-space rays for
 * stationary pickups and for the repeated poses of idle alias models.  Keep
 * exact-bit results from the current BSP so those rays do not walk the BVH on
 * every rendered frame.  Four-way probing keeps lookups bounded; a collision
 * may evict an entry but can never return a result for a different ray.
 */
#define MQ_SHADOW_RAY_CACHE_SIZE 131072u
#define MQ_SHADOW_RAY_CACHE_PROBES 4u
/* Store the native shadow-acceleration data for one shadow ray cache entry. */
typedef struct MQ_SHADOW_RAY_CACHE_ENTRY {
    mq_u32 generation;
    mq_u32 ray_bits[6];
    float result[8];
    mq_u8 hit;
} MQ_SHADOW_RAY_CACHE_ENTRY;
static MQ_SHADOW_RAY_CACHE_ENTRY mq_shadow_ray_cache[MQ_SHADOW_RAY_CACHE_SIZE];
static mq_u32 mq_shadow_ray_cache_generation = 1u;

/* Return the lesser scalar without depending on compiler runtime helpers. */
static float mq_shadow_minimum(float left, float right) { return left < right ? left : right; }
/* Return the greater scalar without depending on compiler runtime helpers. */
static float mq_shadow_maximum(float left, float right) { return left > right ? left : right; }

/* Release every allocation owned by the current world-shadow acceleration structure. */
MQ_EXPORT void mq_shadow_world_clear(void) {
    if (mq_shadow_triangles) VirtualFree(mq_shadow_triangles, 0u, 0x8000u /* MEM_RELEASE */);
    if (mq_shadow_indices) VirtualFree(mq_shadow_indices, 0u, 0x8000u);
    if (mq_shadow_nodes) VirtualFree(mq_shadow_nodes, 0u, 0x8000u);
    mq_shadow_triangles = (MQ_SHADOW_TRIANGLE *)0;
    mq_shadow_indices = (mq_u32 *)0;
    mq_shadow_nodes = (MQ_SHADOW_NODE *)0;
    mq_shadow_triangle_count = 0u;
    mq_shadow_node_count = 0u;
    ++mq_shadow_ray_cache_generation;
    if (mq_shadow_ray_cache_generation == 0u) {
        memset(mq_shadow_ray_cache, 0, sizeof(mq_shadow_ray_cache));
        mq_shadow_ray_cache_generation = 1u;
    }
}

/* Sort one index range in-place by triangle centroid for median BVH splitting. */
static void mq_shadow_sort_indices(mq_i32 left, mq_i32 right, mq_u32 axis) {
    mq_i32 first = left;
    mq_i32 last = right;
    float pivot = mq_shadow_triangles[mq_shadow_indices[(left + right) >> 1]].centroid[axis];
    while (first <= last) {
        while (mq_shadow_triangles[mq_shadow_indices[first]].centroid[axis] < pivot) ++first;
        while (mq_shadow_triangles[mq_shadow_indices[last]].centroid[axis] > pivot) --last;
        if (first <= last) {
            mq_u32 temporary = mq_shadow_indices[first];
            mq_shadow_indices[first] = mq_shadow_indices[last];
            mq_shadow_indices[last] = temporary;
            ++first;
            --last;
        }
    }
    if (left < last) mq_shadow_sort_indices(left, last, axis);
    if (first < right) mq_shadow_sort_indices(first, right, axis);
}

/* Recursively build one median-split BVH node over a contiguous index range. */
static mq_i32 mq_shadow_build_node(mq_u32 start, mq_u32 count) {
    mq_u32 axis;
    mq_u32 index;
    mq_i32 node_index = (mq_i32)mq_shadow_node_count++;
    MQ_SHADOW_NODE *node = &mq_shadow_nodes[node_index];
    float centroid_minimum[3] = {3.402823466e+38f, 3.402823466e+38f, 3.402823466e+38f};
    float centroid_maximum[3] = {-3.402823466e+38f, -3.402823466e+38f, -3.402823466e+38f};
    node->left = -1;
    node->right = -1;
    node->start = start;
    node->count = count;
    for (axis = 0u; axis < 3u; ++axis) {
        node->minimum[axis] = 3.402823466e+38f;
        node->maximum[axis] = -3.402823466e+38f;
    }
    for (index = start; index < start + count; ++index) {
        MQ_SHADOW_TRIANGLE *triangle = &mq_shadow_triangles[mq_shadow_indices[index]];
        for (axis = 0u; axis < 3u; ++axis) {
            node->minimum[axis] = mq_shadow_minimum(node->minimum[axis], triangle->minimum[axis]);
            node->maximum[axis] = mq_shadow_maximum(node->maximum[axis], triangle->maximum[axis]);
            centroid_minimum[axis] = mq_shadow_minimum(centroid_minimum[axis], triangle->centroid[axis]);
            centroid_maximum[axis] = mq_shadow_maximum(centroid_maximum[axis], triangle->centroid[axis]);
        }
    }
    if (count <= 8u) return node_index;
    axis = 0u;
    if (centroid_maximum[1] - centroid_minimum[1] > centroid_maximum[axis] - centroid_minimum[axis]) axis = 1u;
    if (centroid_maximum[2] - centroid_minimum[2] > centroid_maximum[axis] - centroid_minimum[axis]) axis = 2u;
    mq_shadow_sort_indices((mq_i32)start, (mq_i32)(start + count - 1u), axis);
    {
        mq_u32 left_count = count >> 1;
        node->count = 0u;
        node->left = mq_shadow_build_node(start, left_count);
        node->right = mq_shadow_build_node(start + left_count, count - left_count);
    }
    return node_index;
}

/* Upload strided world triangles and rebuild the native shadow-ray BVH. */
static mq_i32 mq_shadow_world_upload_stride(const mq_u8 *data, mq_u32 byte_count, mq_u32 stride, mq_i32 indexed) {
    mq_u32 triangle_count;
    mq_u32 triangle_index;
    mq_shadow_world_clear();
    if (!data || byte_count == 0u || stride < 36u || (byte_count % stride) != 0u) return 0;
    triangle_count = byte_count / stride;
    if (triangle_count == 0u || triangle_count > 1048576u) return 0;
    mq_shadow_triangles = (MQ_SHADOW_TRIANGLE *)VirtualAlloc((LPVOID)0, (mq_u64)triangle_count * sizeof(MQ_SHADOW_TRIANGLE), 0x3000u /* COMMIT|RESERVE */, 0x04u /* READWRITE */);
    mq_shadow_indices = (mq_u32 *)VirtualAlloc((LPVOID)0, (mq_u64)triangle_count * sizeof(mq_u32), 0x3000u, 0x04u);
    mq_shadow_nodes = (MQ_SHADOW_NODE *)VirtualAlloc((LPVOID)0, (mq_u64)(triangle_count * 2u) * sizeof(MQ_SHADOW_NODE), 0x3000u, 0x04u);
    if (!mq_shadow_triangles || !mq_shadow_indices || !mq_shadow_nodes) {
        mq_shadow_world_clear();
        return 0;
    }
    for (triangle_index = 0u; triangle_index < triangle_count; ++triangle_index) {
        MQ_SHADOW_TRIANGLE *triangle = &mq_shadow_triangles[triangle_index];
        mq_u32 component;
        float edge_a[3];
        float edge_b[3];
        float length;
        const mq_u8 *record = data + triangle_index * stride;
        memcpy(triangle->vertex, record, 36u);
        if (indexed) memcpy(&triangle->surface_id, record + 36u, 4u);
        else triangle->surface_id = triangle_index;
        for (component = 0u; component < 3u; ++component) {
            float first = triangle->vertex[component];
            float second = triangle->vertex[3u + component];
            float third = triangle->vertex[6u + component];
            triangle->minimum[component] = mq_shadow_minimum(first, mq_shadow_minimum(second, third));
            triangle->maximum[component] = mq_shadow_maximum(first, mq_shadow_maximum(second, third));
            triangle->centroid[component] = (first + second + third) * (1.0f / 3.0f);
            edge_a[component] = second - first;
            edge_b[component] = third - first;
            triangle->edge_a[component] = edge_a[component];
            triangle->edge_b[component] = edge_b[component];
        }
        triangle->normal[0] = edge_a[1] * edge_b[2] - edge_a[2] * edge_b[1];
        triangle->normal[1] = edge_a[2] * edge_b[0] - edge_a[0] * edge_b[2];
        triangle->normal[2] = edge_a[0] * edge_b[1] - edge_a[1] * edge_b[0];
        length = sqrtf(triangle->normal[0] * triangle->normal[0] + triangle->normal[1] * triangle->normal[1] + triangle->normal[2] * triangle->normal[2]);
        if (length > 0.000001f) {
            triangle->normal[0] /= length;
            triangle->normal[1] /= length;
            triangle->normal[2] /= length;
        }
        mq_shadow_indices[triangle_index] = triangle_index;
    }
    mq_shadow_triangle_count = triangle_count;
    mq_shadow_node_count = 0u;
    mq_shadow_build_node(0u, triangle_count);
    return (mq_i32)triangle_count;
}

/* Upload legacy coordinate-only triangles with one conservative id per triangle. */
MQ_EXPORT mq_i32 mq_shadow_world_upload(const mq_u8 *data, mq_u32 byte_count) {
    return mq_shadow_world_upload_stride(data, byte_count, 36u, 0);
}

/* Upload triangles tagged with their render-BSP receiver surface. */
MQ_EXPORT mq_i32 mq_shadow_world_upload_surfaces(const mq_u8 *data, mq_u32 byte_count) {
    return mq_shadow_world_upload_stride(data, byte_count, 40u, 1);
}

/* Test a finite ray against an AABB using direction state shared by the ray. */
static mq_i32 mq_shadow_ray_box(
    const float *origin,
    const float *inverse_direction,
    const mq_u8 *parallel,
    const MQ_SHADOW_NODE *node,
    float maximum_fraction
) {
    float minimum_fraction = 0.0f;
    mq_u32 axis;
    for (axis = 0u; axis < 3u; ++axis) {
        if (parallel[axis]) {
            if (origin[axis] < node->minimum[axis] || origin[axis] > node->maximum[axis]) return 0;
        } else {
            float first = (node->minimum[axis] - origin[axis]) * inverse_direction[axis];
            float second = (node->maximum[axis] - origin[axis]) * inverse_direction[axis];
            if (first > second) { float temporary = first; first = second; second = temporary; }
            if (first > minimum_fraction) minimum_fraction = first;
            if (second < maximum_fraction) maximum_fraction = second;
            if (minimum_fraction > maximum_fraction) return 0;
        }
    }
    return maximum_fraction >= 0.0f && minimum_fraction <= 1.0f;
}

/* Test a finite ray against one triangle with the two-sided Moller-Trumbore method. */
static mq_i32 mq_shadow_ray_triangle(const float *origin, const float *direction, const MQ_SHADOW_TRIANGLE *triangle, float *fraction) {
    float p[3];
    float translated[3];
    float q[3];
    float determinant;
    float inverse;
    float u;
    float v;
    float candidate;
    translated[0] = origin[0] - triangle->vertex[0];
    translated[1] = origin[1] - triangle->vertex[1];
    translated[2] = origin[2] - triangle->vertex[2];
    p[0] = direction[1] * triangle->edge_b[2] - direction[2] * triangle->edge_b[1];
    p[1] = direction[2] * triangle->edge_b[0] - direction[0] * triangle->edge_b[2];
    p[2] = direction[0] * triangle->edge_b[1] - direction[1] * triangle->edge_b[0];
    determinant = triangle->edge_a[0] * p[0] + triangle->edge_a[1] * p[1] + triangle->edge_a[2] * p[2];
    if (determinant > -0.000001f && determinant < 0.000001f) return 0;
    inverse = 1.0f / determinant;
    u = (translated[0] * p[0] + translated[1] * p[1] + translated[2] * p[2]) * inverse;
    if (u < 0.0f || u > 1.0f) return 0;
    q[0] = translated[1] * triangle->edge_a[2] - translated[2] * triangle->edge_a[1];
    q[1] = translated[2] * triangle->edge_a[0] - translated[0] * triangle->edge_a[2];
    q[2] = translated[0] * triangle->edge_a[1] - translated[1] * triangle->edge_a[0];
    v = (direction[0] * q[0] + direction[1] * q[1] + direction[2] * q[2]) * inverse;
    if (v < 0.0f || u + v > 1.0f) return 0;
    candidate = (triangle->edge_b[0] * q[0] + triangle->edge_b[1] * q[1] + triangle->edge_b[2] * q[2]) * inverse;
    if (candidate <= 0.000001f || candidate >= *fraction || candidate > 1.0f) return 0;
    *fraction = candidate;
    return 1;
}

/* Trace one finite segment through the world BVH and return its closest triangle. */
static mq_i32 mq_shadow_trace_one(const float *ray, float *result) {
    mq_i32 stack[128];
    mq_i32 stack_count = 0;
    float origin[3] = {ray[0], ray[1], ray[2]};
    float direction[3] = {ray[3] - ray[0], ray[4] - ray[1], ray[5] - ray[2]};
    float inverse_direction[3];
    mq_u8 parallel[3];
    float best_fraction = 1.0f;
    mq_i32 best_triangle = -1;
    mq_u32 axis;
    if (!mq_shadow_nodes || mq_shadow_node_count == 0u) return 0;
    /* A ray visits many BVH nodes, so calculate its three reciprocals once. */
    for (axis = 0u; axis < 3u; ++axis) {
        parallel[axis] = (mq_u8)(direction[axis] > -0.0000001f && direction[axis] < 0.0000001f);
        inverse_direction[axis] = parallel[axis] ? 0.0f : 1.0f / direction[axis];
    }
    stack[stack_count++] = 0;
    while (stack_count > 0) {
        mq_i32 node_index = stack[--stack_count];
        MQ_SHADOW_NODE *node = &mq_shadow_nodes[node_index];
        if (!mq_shadow_ray_box(origin, inverse_direction, parallel, node, best_fraction)) continue;
        if (node->count != 0u) {
            mq_u32 item;
            for (item = node->start; item < node->start + node->count; ++item) {
                mq_u32 triangle_index = mq_shadow_indices[item];
                if (mq_shadow_ray_triangle(origin, direction, &mq_shadow_triangles[triangle_index], &best_fraction)) best_triangle = (mq_i32)triangle_index;
            }
        } else if (stack_count + 2 <= 128) {
            if (node->left >= 0) stack[stack_count++] = node->left;
            if (node->right >= 0) stack[stack_count++] = node->right;
        }
    }
    if (best_triangle < 0) return 0;
    {
        MQ_SHADOW_TRIANGLE *triangle = &mq_shadow_triangles[best_triangle];
        float normal_dot = triangle->normal[0] * direction[0] + triangle->normal[1] * direction[1] + triangle->normal[2] * direction[2];
        /* Surface ids are exact in float for Quake's bounded BSP face count.
         * Zero remains the miss sentinel consumed by existing batch callers. */
        result[0] = (float)(triangle->surface_id + 1u);
        result[1] = best_fraction;
        result[2] = origin[0] + direction[0] * best_fraction;
        result[3] = origin[1] + direction[1] * best_fraction;
        result[4] = origin[2] + direction[2] * best_fraction;
        result[5] = triangle->normal[0];
        result[6] = triangle->normal[1];
        result[7] = triangle->normal[2];
        if (normal_dot > 0.0f) { result[5] = -result[5]; result[6] = -result[6]; result[7] = -result[7]; }
    }
    return 1;
}

/* Hash six exact IEEE-754 words without changing any ray arithmetic. */
static mq_u32 mq_shadow_ray_hash(const mq_u32 *ray_bits) {
    mq_u32 hash = 2166136261u;
    mq_u32 index;
    for (index = 0u; index < 6u; ++index) {
        hash ^= ray_bits[index];
        hash *= 16777619u;
        hash ^= hash >> 13u;
    }
    return hash;
}

/* Return a cached immutable-world trace or populate one bounded cache slot. */
static mq_i32 mq_shadow_trace_cached(const float *ray, float *result) {
    mq_u32 ray_bits[6];
    mq_u32 hash;
    mq_u32 probe;
    mq_u32 replacement;
    mq_i32 hit;
    memcpy(ray_bits, ray, sizeof(ray_bits));
    hash = mq_shadow_ray_hash(ray_bits);
    replacement = hash & (MQ_SHADOW_RAY_CACHE_SIZE - 1u);
    for (probe = 0u; probe < MQ_SHADOW_RAY_CACHE_PROBES; ++probe) {
        mq_u32 slot = (replacement + probe) & (MQ_SHADOW_RAY_CACHE_SIZE - 1u);
        MQ_SHADOW_RAY_CACHE_ENTRY *entry = &mq_shadow_ray_cache[slot];
        if (entry->generation != mq_shadow_ray_cache_generation) {
            replacement = slot;
            break;
        }
        if (entry->ray_bits[0] == ray_bits[0] && entry->ray_bits[1] == ray_bits[1] &&
            entry->ray_bits[2] == ray_bits[2] && entry->ray_bits[3] == ray_bits[3] &&
            entry->ray_bits[4] == ray_bits[4] && entry->ray_bits[5] == ray_bits[5]) {
            if (entry->hit) memcpy(result, entry->result, sizeof(entry->result));
            return entry->hit != 0u;
        }
    }
    hit = mq_shadow_trace_one(ray, result);
    {
        MQ_SHADOW_RAY_CACHE_ENTRY *entry = &mq_shadow_ray_cache[replacement];
        entry->generation = mq_shadow_ray_cache_generation;
        memcpy(entry->ray_bits, ray_bits, sizeof(entry->ray_bits));
        entry->hit = (mq_u8)(hit != 0);
        if (hit) memcpy(entry->result, result, sizeof(entry->result));
    }
    return hit;
}

/* Trace a packed array of six-float segments into eight-float hit records. */
MQ_EXPORT mq_i32 mq_shadow_trace_batch(const mq_u8 *rays, mq_u32 ray_bytes, mq_u8 *results, mq_u32 result_bytes) {
    mq_u32 ray_count;
    mq_u32 index;
    if (!rays || !results || (ray_bytes % 24u) != 0u) return 0;
    ray_count = ray_bytes / 24u;
    if (result_bytes < ray_count * 32u) return 0;
    for (index = 0u; index < ray_count; ++index) {
        float ray[6];
        float result[8] = {0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f};
        memcpy(ray, rays + index * 24u, 24u);
        mq_shadow_trace_cached(ray, result);
        memcpy(results + index * 32u, result, 32u);
    }
    return (mq_i32)ray_count;
}

typedef BOOL (MQ_WINAPI *mq_wgl_swap_interval_proc)(mq_i32 interval);
typedef void (MQ_WINAPI *mq_gl_active_texture_proc)(mq_u32 texture);
typedef void (MQ_WINAPI *mq_gl_client_active_texture_proc)(mq_u32 texture);
typedef void (MQ_WINAPI *mq_gl_multi_tex_coord2f_proc)(mq_u32 texture, float s, float t);
typedef mq_u32 (MQ_WINAPI *mq_gl_create_shader_proc)(mq_u32 type);
typedef void (MQ_WINAPI *mq_gl_shader_source_proc)(mq_u32 shader, mq_i32 count, const char *const *source, const mq_i32 *length);
typedef void (MQ_WINAPI *mq_gl_compile_shader_proc)(mq_u32 shader);
typedef void (MQ_WINAPI *mq_gl_get_shader_iv_proc)(mq_u32 shader, mq_u32 name, mq_i32 *value);
typedef void (MQ_WINAPI *mq_gl_delete_shader_proc)(mq_u32 shader);
typedef mq_u32 (MQ_WINAPI *mq_gl_create_program_proc)(void);
typedef void (MQ_WINAPI *mq_gl_attach_shader_proc)(mq_u32 program, mq_u32 shader);
typedef void (MQ_WINAPI *mq_gl_link_program_proc)(mq_u32 program);
typedef void (MQ_WINAPI *mq_gl_get_program_iv_proc)(mq_u32 program, mq_u32 name, mq_i32 *value);
typedef void (MQ_WINAPI *mq_gl_use_program_proc)(mq_u32 program);
typedef void (MQ_WINAPI *mq_gl_delete_program_proc)(mq_u32 program);
typedef mq_i32 (MQ_WINAPI *mq_gl_get_uniform_location_proc)(mq_u32 program, const char *name);
typedef mq_i32 (MQ_WINAPI *mq_gl_get_attrib_location_proc)(mq_u32 program, const char *name);
typedef void (MQ_WINAPI *mq_gl_vertex_attrib_4f_proc)(mq_u32 index, float x, float y, float z, float w);
typedef void (MQ_WINAPI *mq_gl_uniform_1i_proc)(mq_i32 location, mq_i32 value);
typedef void (MQ_WINAPI *mq_gl_uniform_4fv_proc)(mq_i32 location, mq_i32 count, const float *value);
typedef void (MQ_WINAPI *mq_gl_gen_buffers_proc)(mq_i32 count, mq_u32 *buffers);
typedef void (MQ_WINAPI *mq_gl_bind_buffer_proc)(mq_u32 target, mq_u32 buffer);
typedef void (MQ_WINAPI *mq_gl_buffer_data_proc)(mq_u32 target, mq_i64 size, const void *data, mq_u32 usage);
typedef void (MQ_WINAPI *mq_gl_delete_buffers_proc)(mq_i32 count, const mq_u32 *buffers);

static mq_gl_active_texture_proc mq_gl_active_texture_value = (mq_gl_active_texture_proc)0;
static mq_gl_client_active_texture_proc mq_gl_client_active_texture_value = (mq_gl_client_active_texture_proc)0;
static mq_gl_multi_tex_coord2f_proc mq_gl_multi_tex_coord2f_value = (mq_gl_multi_tex_coord2f_proc)0;
static mq_gl_create_shader_proc mq_gl_create_shader_value = (mq_gl_create_shader_proc)0;
static mq_gl_shader_source_proc mq_gl_shader_source_value = (mq_gl_shader_source_proc)0;
static mq_gl_compile_shader_proc mq_gl_compile_shader_value = (mq_gl_compile_shader_proc)0;
static mq_gl_get_shader_iv_proc mq_gl_get_shader_iv_value = (mq_gl_get_shader_iv_proc)0;
static mq_gl_delete_shader_proc mq_gl_delete_shader_value = (mq_gl_delete_shader_proc)0;
static mq_gl_create_program_proc mq_gl_create_program_value = (mq_gl_create_program_proc)0;
static mq_gl_attach_shader_proc mq_gl_attach_shader_value = (mq_gl_attach_shader_proc)0;
static mq_gl_link_program_proc mq_gl_link_program_value = (mq_gl_link_program_proc)0;
static mq_gl_get_program_iv_proc mq_gl_get_program_iv_value = (mq_gl_get_program_iv_proc)0;
static mq_gl_use_program_proc mq_gl_use_program_value = (mq_gl_use_program_proc)0;
static mq_gl_delete_program_proc mq_gl_delete_program_value = (mq_gl_delete_program_proc)0;
static mq_gl_get_uniform_location_proc mq_gl_get_uniform_location_value = (mq_gl_get_uniform_location_proc)0;
static mq_gl_get_attrib_location_proc mq_gl_get_attrib_location_value = (mq_gl_get_attrib_location_proc)0;
static mq_gl_vertex_attrib_4f_proc mq_gl_vertex_attrib_4f_value = (mq_gl_vertex_attrib_4f_proc)0;
static mq_gl_uniform_1i_proc mq_gl_uniform_1i_value = (mq_gl_uniform_1i_proc)0;
static mq_gl_uniform_4fv_proc mq_gl_uniform_4fv_value = (mq_gl_uniform_4fv_proc)0;
static mq_gl_gen_buffers_proc mq_gl_gen_buffers_value = (mq_gl_gen_buffers_proc)0;
static mq_gl_bind_buffer_proc mq_gl_bind_buffer_value = (mq_gl_bind_buffer_proc)0;
static mq_gl_buffer_data_proc mq_gl_buffer_data_value = (mq_gl_buffer_data_proc)0;
static mq_gl_delete_buffers_proc mq_gl_delete_buffers_value = (mq_gl_delete_buffers_proc)0;
static mq_u32 mq_gl_world_program = 0u;
static mq_i32 mq_gl_world_program_attempted = 0;
static mq_u32 mq_gl_alias_program = 0u;
static mq_i32 mq_gl_alias_program_attempted = 0;
static mq_i32 mq_gl_alias_state_location = -1;
static mq_i32 mq_gl_alias_program_active = 0;
static mq_u32 mq_gl_md2_shadow_program = 0u;
static mq_i32 mq_gl_md2_shadow_program_attempted = 0;
static mq_i32 mq_gl_md2_shadow_state_location = -1;
static float mq_gl_md2_shadow_alpha = 0.5f;
static mq_u32 mq_gl_enhanced_program = 0u;
static mq_i32 mq_gl_enhanced_program_attempted = 0;
static mq_i32 mq_gl_enhanced_enabled = 0;
static mq_i32 mq_gl_enhanced_shadows = 0;
static mq_i32 mq_gl_enhanced_shadow_quality = 1;
static mq_i32 mq_gl_enhanced_draw_kind_value = 0;
static mq_i32 mq_gl_enhanced_light_count = 0;
static float mq_gl_enhanced_lights[16];

/* Report whether valid wgl proc is available. */
static mq_i32 mq_valid_wgl_proc(const void *value) {
    return value != (const void *)0 && value != (const void *)1 && value != (const void *)2 &&
        value != (const void *)3 && value != (const void *)-1;
}

/* Create and initialize create world program. */
static mq_i32 mq_gl_create_world_program(void) {
    static const char *vertex_source =
        "#version 120\n"
        "void main(){gl_Position=ftransform();gl_TexCoord[0]=gl_MultiTexCoord0;gl_TexCoord[1]=gl_MultiTexCoord1;}\n";
    static const char *fragment_source =
        "#version 120\n"
        "uniform sampler2D mq_base;uniform sampler2D mq_light;"
        "void main(){vec4 b=texture2D(mq_base,gl_TexCoord[0].st);"
        "vec3 l=texture2D(mq_light,gl_TexCoord[1].st).rgb;"
        "gl_FragColor=vec4(b.rgb*(vec3(1.0)-l),b.a);}\n";
    mq_u32 vertex_shader;
    mq_u32 fragment_shader;
    mq_u32 program;
    mq_i32 compiled = 0;
    mq_i32 linked = 0;
    mq_i32 location;
    if (mq_gl_world_program != 0u) return 1;
    if (mq_gl_world_program_attempted) return 0;
    mq_gl_world_program_attempted = 1;
    if (!mq_valid_wgl_proc((const void *)mq_gl_create_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_shader_source_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_compile_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_shader_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_create_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_attach_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_link_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_program_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_use_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_uniform_location_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_uniform_1i_value)) return 0;
    vertex_shader = mq_gl_create_shader_value(0x8B31u /* GL_VERTEX_SHADER */);
    fragment_shader = mq_gl_create_shader_value(0x8B30u /* GL_FRAGMENT_SHADER */);
    if (vertex_shader == 0u || fragment_shader == 0u) return 0;
    mq_gl_shader_source_value(vertex_shader, 1, &vertex_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(vertex_shader);
    mq_gl_get_shader_iv_value(vertex_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    compiled = 0;
    mq_gl_shader_source_value(fragment_shader, 1, &fragment_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(fragment_shader);
    mq_gl_get_shader_iv_value(fragment_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    program = mq_gl_create_program_value();
    if (program == 0u) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    mq_gl_attach_shader_value(program, vertex_shader);
    mq_gl_attach_shader_value(program, fragment_shader);
    mq_gl_link_program_value(program);
    mq_gl_get_program_iv_value(program, 0x8B82u /* GL_LINK_STATUS */, &linked);
    mq_gl_delete_shader_value(vertex_shader);
    mq_gl_delete_shader_value(fragment_shader);
    if (!linked) {
        mq_gl_delete_program_value(program);
        return 0;
    }
    mq_gl_world_program = program;
    mq_gl_use_program_value(program);
    location = mq_gl_get_uniform_location_value(program, "mq_base");
    if (location >= 0) mq_gl_uniform_1i_value(location, 0);
    location = mq_gl_get_uniform_location_value(program, "mq_light");
    if (location >= 0) mq_gl_uniform_1i_value(location, 1);
    mq_gl_use_program_value(0u);
    return 1;
}

/* Create the Quake II alias program. The second compatibility texture
 * coordinate carries the MD2 normal. The shader applies the original
 * yaw-quantized vector, negative-dot attenuation and hundredth rounding. */
static mq_i32 mq_gl_create_alias_program(void) {
    static const char *vertex_source =
        "#version 120\n"
        "attribute vec4 mq_state;varying vec4 mq_color;"
        "void main(){vec4 p=vec4(mix(gl_MultiTexCoord2.xyz,gl_Vertex.xyz,"
        "1.0-gl_MultiTexCoord3.x),1.0);"
        "gl_Position=gl_ModelViewProjectionMatrix*p;gl_TexCoord[0]=gl_MultiTexCoord0;"
        "float a=mq_state.w*0.3926990817;"
        "vec3 v=vec3(cos(-a),sin(-a),1.0)*0.7071067812;"
        "float d=dot(gl_MultiTexCoord1.xyz,v);if(d<0.0)d*=0.3;"
        "float l=floor((1.0+d)*100.0+0.5)*0.01;"
        "mq_color=vec4(clamp(vec3(l)*mq_state.rgb,0.0,1.0),gl_Color.a);}\n";
    static const char *fragment_source =
        "#version 120\n"
        "uniform sampler2D mq_base;varying vec4 mq_color;"
        "void main(){gl_FragColor=texture2D(mq_base,gl_TexCoord[0].st)*mq_color;}\n";
    mq_u32 vertex_shader;
    mq_u32 fragment_shader;
    mq_u32 program;
    mq_i32 compiled = 0;
    mq_i32 linked = 0;
    mq_i32 location;
    if (mq_gl_alias_program != 0u) return 1;
    if (mq_gl_alias_program_attempted) return 0;
    mq_gl_alias_program_attempted = 1;
    if (!mq_valid_wgl_proc((const void *)mq_gl_create_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_shader_source_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_compile_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_shader_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_create_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_attach_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_link_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_program_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_use_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_uniform_location_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_attrib_location_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_vertex_attrib_4f_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_uniform_1i_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_uniform_4fv_value)) return 0;
    vertex_shader = mq_gl_create_shader_value(0x8B31u /* GL_VERTEX_SHADER */);
    fragment_shader = mq_gl_create_shader_value(0x8B30u /* GL_FRAGMENT_SHADER */);
    if (vertex_shader == 0u || fragment_shader == 0u) return 0;
    mq_gl_shader_source_value(vertex_shader, 1, &vertex_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(vertex_shader);
    mq_gl_get_shader_iv_value(vertex_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    compiled = 0;
    mq_gl_shader_source_value(fragment_shader, 1, &fragment_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(fragment_shader);
    mq_gl_get_shader_iv_value(fragment_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    program = mq_gl_create_program_value();
    if (program == 0u) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    mq_gl_attach_shader_value(program, vertex_shader);
    mq_gl_attach_shader_value(program, fragment_shader);
    mq_gl_link_program_value(program);
    mq_gl_get_program_iv_value(program, 0x8B82u /* GL_LINK_STATUS */, &linked);
    mq_gl_delete_shader_value(vertex_shader);
    mq_gl_delete_shader_value(fragment_shader);
    if (!linked) {
        mq_gl_delete_program_value(program);
        return 0;
    }
    mq_gl_alias_program = program;
    mq_gl_use_program_value(program);
    location = mq_gl_get_uniform_location_value(program, "mq_base");
    if (location >= 0) mq_gl_uniform_1i_value(location, 0);
    mq_gl_alias_state_location =
        mq_gl_get_attrib_location_value(program, "mq_state");
    mq_gl_use_program_value(0u);
    return 1;
}

/* Create the classic Quake II planar MD2 shadow program. Projection happens
 * in entity-local space exactly like GL_DrawAliasShadow, while the already
 * interpolated geometry remains in the bounded alias VBO cache. */
static mq_i32 mq_gl_create_md2_shadow_program(void) {
    static const char *vertex_source =
        "#version 120\n"
        "attribute vec4 mq_shadow;varying float mq_alpha;"
        "void main(){vec4 p=vec4(mix(gl_MultiTexCoord2.xyz,gl_Vertex.xyz,"
        "1.0-gl_MultiTexCoord3.x),1.0);"
        "p.x-=mq_shadow.x*(p.z+mq_shadow.z);"
        "p.y-=mq_shadow.y*(p.z+mq_shadow.z);"
        "p.z=-mq_shadow.z+1.0;"
        "mq_alpha=mq_shadow.w;gl_Position=gl_ModelViewProjectionMatrix*p;}\n";
    static const char *fragment_source =
        "#version 120\n"
        "varying float mq_alpha;void main(){gl_FragColor=vec4(0.0,0.0,0.0,mq_alpha);}\n";
    mq_u32 vertex_shader;
    mq_u32 fragment_shader;
    mq_u32 program;
    mq_i32 compiled = 0;
    mq_i32 linked = 0;
    if (mq_gl_md2_shadow_program != 0u) return 1;
    if (mq_gl_md2_shadow_program_attempted) return 0;
    mq_gl_md2_shadow_program_attempted = 1;
    if (!mq_valid_wgl_proc((const void *)mq_gl_create_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_shader_source_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_compile_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_shader_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_create_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_attach_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_link_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_program_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_use_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_attrib_location_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_vertex_attrib_4f_value)) return 0;
    vertex_shader = mq_gl_create_shader_value(0x8B31u /* GL_VERTEX_SHADER */);
    fragment_shader = mq_gl_create_shader_value(0x8B30u /* GL_FRAGMENT_SHADER */);
    if (vertex_shader == 0u || fragment_shader == 0u) return 0;
    mq_gl_shader_source_value(vertex_shader, 1, &vertex_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(vertex_shader);
    mq_gl_get_shader_iv_value(vertex_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    compiled = 0;
    mq_gl_shader_source_value(fragment_shader, 1, &fragment_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(fragment_shader);
    mq_gl_get_shader_iv_value(fragment_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    program = mq_gl_create_program_value();
    if (program == 0u) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    mq_gl_attach_shader_value(program, vertex_shader);
    mq_gl_attach_shader_value(program, fragment_shader);
    mq_gl_link_program_value(program);
    mq_gl_get_program_iv_value(program, 0x8B82u /* GL_LINK_STATUS */, &linked);
    mq_gl_delete_shader_value(vertex_shader);
    mq_gl_delete_shader_value(fragment_shader);
    if (!linked) {
        mq_gl_delete_program_value(program);
        return 0;
    }
    mq_gl_md2_shadow_program = program;
    mq_gl_md2_shadow_state_location =
        mq_gl_get_attrib_location_value(program, "mq_shadow");
    return 1;
}

/* Create the optional per-pixel additive dynamic-light program. */
static mq_i32 mq_gl_create_enhanced_program(void) {
    static const char *vertex_source =
        "#version 120\n"
        "varying vec3 mq_eye;varying vec2 mq_uv;"
        "void main(){vec4 e=gl_ModelViewMatrix*gl_Vertex;mq_eye=e.xyz;"
        "mq_uv=gl_MultiTexCoord0.st;gl_Position=gl_ProjectionMatrix*e;}\n";
    static const char *fragment_source =
        "#version 120\n"
        "uniform sampler2D mq_base;uniform int mq_light_count;uniform vec4 mq_lights[4];"
        "varying vec3 mq_eye;varying vec2 mq_uv;"
        "float mq_one(vec4 q,vec3 n){vec3 d=q.xyz-mq_eye;float z=length(d);"
        "if(z>=q.w||q.w<=0.0)return 0.0;float a=1.0-z/q.w;a*=a;"
        "float lam=max(dot(n,d/max(z,0.001)),0.0);return a*lam;}"
        "void main(){vec3 n=normalize(cross(dFdx(mq_eye),dFdy(mq_eye)));"
        "if(dot(n,-mq_eye)<0.0)n=-n;float l=0.0;"
        "if(mq_light_count>0)l+=mq_one(mq_lights[0],n);"
        "if(mq_light_count>1)l+=mq_one(mq_lights[1],n);"
        "if(mq_light_count>2)l+=mq_one(mq_lights[2],n);"
        "if(mq_light_count>3)l+=mq_one(mq_lights[3],n);"
        "vec4 b=texture2D(mq_base,mq_uv);"
        "gl_FragColor=vec4(b.rgb*vec3(1.0,0.58,0.30)*min(l,1.5),b.a);}\n";
    mq_u32 vertex_shader;
    mq_u32 fragment_shader;
    mq_u32 program;
    mq_i32 compiled = 0;
    mq_i32 linked = 0;
    mq_i32 location;
    if (mq_gl_enhanced_program != 0u) return 1;
    if (mq_gl_enhanced_program_attempted) return 0;
    mq_gl_enhanced_program_attempted = 1;
    if (!mq_valid_wgl_proc((const void *)mq_gl_create_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_shader_source_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_compile_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_shader_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_create_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_attach_shader_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_link_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_program_iv_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_use_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_delete_program_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_get_uniform_location_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_uniform_1i_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_uniform_4fv_value)) return 0;
    vertex_shader = mq_gl_create_shader_value(0x8B31u /* GL_VERTEX_SHADER */);
    fragment_shader = mq_gl_create_shader_value(0x8B30u /* GL_FRAGMENT_SHADER */);
    if (vertex_shader == 0u || fragment_shader == 0u) return 0;
    mq_gl_shader_source_value(vertex_shader, 1, &vertex_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(vertex_shader);
    mq_gl_get_shader_iv_value(vertex_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    compiled = 0;
    mq_gl_shader_source_value(fragment_shader, 1, &fragment_source, (const mq_i32 *)0);
    mq_gl_compile_shader_value(fragment_shader);
    mq_gl_get_shader_iv_value(fragment_shader, 0x8B81u /* GL_COMPILE_STATUS */, &compiled);
    if (!compiled) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    program = mq_gl_create_program_value();
    if (program == 0u) {
        mq_gl_delete_shader_value(vertex_shader);
        mq_gl_delete_shader_value(fragment_shader);
        return 0;
    }
    mq_gl_attach_shader_value(program, vertex_shader);
    mq_gl_attach_shader_value(program, fragment_shader);
    mq_gl_link_program_value(program);
    mq_gl_get_program_iv_value(program, 0x8B82u /* GL_LINK_STATUS */, &linked);
    mq_gl_delete_shader_value(vertex_shader);
    mq_gl_delete_shader_value(fragment_shader);
    if (!linked) {
        mq_gl_delete_program_value(program);
        return 0;
    }
    mq_gl_enhanced_program = program;
    mq_gl_use_program_value(program);
    location = mq_gl_get_uniform_location_value(program, "mq_base");
    if (location >= 0) mq_gl_uniform_1i_value(location, 0);
    mq_gl_use_program_value(0u);
    return 1;
}

/* winmm */
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutOpen(HWAVEOUT *output, UINT device_id, const MQ_WAVEFORMATEX *format, ULONG_PTR callback, ULONG_PTR instance, DWORD flags);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutPrepareHeader(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutUnprepareHeader(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutWrite(HWAVEOUT output, MQ_WAVEHDR *header, UINT size);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutReset(HWAVEOUT output);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutClose(HWAVEOUT output);
MQ_DLLIMPORT MMRESULT MQ_WINAPI waveOutGetPosition(HWAVEOUT output, MQ_MMTIME *time, UINT size);
MQ_DLLIMPORT UINT MQ_WINAPI joyGetNumDevs(void);
MQ_DLLIMPORT MMRESULT MQ_WINAPI joyGetPosEx(UINT joystick_id, MQ_JOYINFOEX *info);
MQ_DLLIMPORT MMRESULT MQ_WINAPI joyGetDevCapsW(ULONG_PTR joystick_id, MQ_JOYCAPSW *caps, UINT size);

/* ws2_32 */
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSAStartup(WORD version, void *data);
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSACleanup(void);
MQ_DLLIMPORT mq_i32 MQ_WINAPI WSAGetLastError(void);
MQ_DLLIMPORT SOCKET MQ_WINAPI socket(mq_i32 family, mq_i32 type, mq_i32 protocol);
MQ_DLLIMPORT mq_i32 MQ_WINAPI closesocket(SOCKET socket_value);
MQ_DLLIMPORT mq_i32 MQ_WINAPI ioctlsocket(SOCKET socket_value, LONG command, mq_u32 *argument);
MQ_DLLIMPORT mq_i32 MQ_WINAPI bind(SOCKET socket_value, const void *address, mq_i32 address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI getsockname(SOCKET socket_value, void *address, mq_i32 *address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI setsockopt(SOCKET socket_value, mq_i32 level, mq_i32 option_name, const char *option_value, mq_i32 option_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI sendto(SOCKET socket_value, const char *data, mq_i32 length, mq_i32 flags, const void *address, mq_i32 address_length);
MQ_DLLIMPORT mq_i32 MQ_WINAPI recvfrom(SOCKET socket_value, char *data, mq_i32 length, mq_i32 flags, void *address, mq_i32 *address_length);
MQ_DLLIMPORT mq_u16 MQ_WINAPI htons(mq_u16 value);
MQ_DLLIMPORT mq_u16 MQ_WINAPI ntohs(mq_u16 value);
MQ_DLLIMPORT mq_u32 MQ_WINAPI inet_addr(const char *address);
MQ_DLLIMPORT mq_i32 MQ_WINAPI gethostname(char *name, mq_i32 name_length);
MQ_DLLIMPORT MQ_HOSTENT *MQ_WINAPI gethostbyname(const char *name);
MQ_DLLIMPORT MQ_HOSTENT *MQ_WINAPI gethostbyaddr(const char *address, mq_i32 length, mq_i32 type);

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
MQ_DLLIMPORT void MQ_WINAPI glTexEnvi(mq_u32 target, mq_u32 name, mq_i32 value);
MQ_DLLIMPORT void MQ_WINAPI glTexImage2D(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels);
MQ_DLLIMPORT void MQ_WINAPI glTexSubImage2D(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels);
MQ_DLLIMPORT void MQ_WINAPI glDrawBuffer(mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glReadPixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels);
MQ_DLLIMPORT void MQ_WINAPI glGetFloatv(mq_u32 name, float *value);
MQ_DLLIMPORT const mq_u8 *MQ_WINAPI glGetString(mq_u32 name);
MQ_DLLIMPORT mq_u32 MQ_WINAPI glGetError(void);
MQ_DLLIMPORT void MQ_WINAPI glFinish(void);
MQ_DLLIMPORT void MQ_WINAPI glFlush(void);
MQ_DLLIMPORT mq_u32 MQ_WINAPI glGenLists(mq_i32 range);
MQ_DLLIMPORT void MQ_WINAPI glNewList(mq_u32 list_id, mq_u32 mode);
MQ_DLLIMPORT void MQ_WINAPI glEndList(void);
MQ_DLLIMPORT void MQ_WINAPI glCallList(mq_u32 list_id);
MQ_DLLIMPORT void MQ_WINAPI glCallLists(mq_i32 count, mq_u32 type, const void *lists);
MQ_DLLIMPORT void MQ_WINAPI glDeleteLists(mq_u32 list_id, mq_i32 range);
MQ_DLLIMPORT void MQ_WINAPI glInterleavedArrays(mq_u32 format, mq_i32 stride, const void *pointer);
MQ_DLLIMPORT void MQ_WINAPI glDrawArrays(mq_u32 mode, mq_i32 first, mq_i32 count);
MQ_DLLIMPORT void MQ_WINAPI glVertexPointer(mq_i32 size, mq_u32 type, mq_i32 stride, const void *pointer);
MQ_DLLIMPORT void MQ_WINAPI glTexCoordPointer(mq_i32 size, mq_u32 type, mq_i32 stride, const void *pointer);
MQ_DLLIMPORT void MQ_WINAPI glEnableClientState(mq_u32 array);
MQ_DLLIMPORT void MQ_WINAPI glDisableClientState(mq_u32 array);

#ifndef GL_COMPILE_AND_EXECUTE
#define GL_COMPILE_AND_EXECUTE 0x1301
#endif
#define MQ_STATIC_GEOMETRY_CACHE_MAX 32768
#define MQ_STATIC_GEOMETRY_HASH_SIZE 65536

/* Group the fields that describe one static geometry entry. */
typedef struct mq_static_geometry_entry_s {
    mq_u64 key;
    mq_i32 pass;
    mq_u32 list_id;
    mq_u32 vertex_offset;
    mq_u32 vertex_count;
    mq_u32 multi_vertex_offset;
    mq_u32 multi_vertex_count;
} mq_static_geometry_entry_t;

static mq_static_geometry_entry_t mq_static_geometry_cache[MQ_STATIC_GEOMETRY_CACHE_MAX];
/* Open-addressed index (entry index + 1; zero means empty).  The render loop
 * asks for every visible base and lightmap polygon on every frame, so the old
 * linear search made an otherwise cached scene quadratic in surface count. */
static mq_u32 mq_static_geometry_hash[MQ_STATIC_GEOMETRY_HASH_SIZE];
static mq_i32 mq_static_geometry_count = 0;
static mq_i32 mq_static_geometry_pending = 0;
static mq_i32 mq_static_geometry_recording = 0;
static mq_u32 mq_static_geometry_pending_list = 0;
static mq_i32 mq_static_geometry_pending_execute = 1;
static mq_i32 mq_static_geometry_pending_entry = -1;

/* BSP polygons are recorded once while their compatibility display lists are
 * built.  A visible texture/lightmap chain can then be submitted as one
 * OpenGL 1.1 vertex-array draw instead of asking the driver to expand hundreds
 * of nested display lists.  This keeps the exact fixed-function texture and
 * blend state while avoiding large deferred-driver stalls on animated lights. */
#define MQ_STATIC_GEOMETRY_POOL_VERTICES 2097152u
#define MQ_STATIC_GEOMETRY_BATCH_VERTICES 1048576u
#define MQ_STATIC_GEOMETRY_CAPTURE_VERTICES 2048u
#define MQ_STATIC_GEOMETRY_VERTEX_FLOATS 5u
#define MQ_STATIC_GEOMETRY_MULTI_VERTICES 1048576u
#define MQ_STATIC_GEOMETRY_MULTI_FLOATS 7u
static float mq_static_geometry_vertices[MQ_STATIC_GEOMETRY_POOL_VERTICES * MQ_STATIC_GEOMETRY_VERTEX_FLOATS];
static float mq_static_geometry_batch[MQ_STATIC_GEOMETRY_BATCH_VERTICES * MQ_STATIC_GEOMETRY_VERTEX_FLOATS];
static float mq_static_geometry_capture[MQ_STATIC_GEOMETRY_CAPTURE_VERTICES * MQ_STATIC_GEOMETRY_VERTEX_FLOATS];
static float mq_static_geometry_multi_vertices[MQ_STATIC_GEOMETRY_MULTI_VERTICES * MQ_STATIC_GEOMETRY_MULTI_FLOATS];
static float mq_static_geometry_multi_capture[MQ_STATIC_GEOMETRY_CAPTURE_VERTICES * MQ_STATIC_GEOMETRY_MULTI_FLOATS];
static mq_u32 mq_static_geometry_vertex_count = 0;
static mq_u32 mq_static_geometry_multi_vertex_count = 0;
static mq_u32 mq_static_geometry_capture_count = 0;
static mq_u32 mq_static_geometry_capture_mode = 0;
static mq_i32 mq_static_geometry_capture_valid = 0;
static float mq_static_geometry_s = 0.0f;
static float mq_static_geometry_t = 0.0f;
static float mq_static_geometry_multi_s[2] = {0.0f, 0.0f};
static float mq_static_geometry_multi_t[2] = {0.0f, 0.0f};

/* Manage cached native geometry for the renderer fast path. */
static void mq_static_geometry_finish_capture(void) {
    mq_u32 triangle_vertices;
    mq_u32 triangle;
    mq_static_geometry_entry_t *entry;
    if (mq_static_geometry_pending_entry < 0 ||
        mq_static_geometry_pending_entry >= mq_static_geometry_count) return;
    entry = &mq_static_geometry_cache[mq_static_geometry_pending_entry];
    entry->vertex_offset = 0u;
    entry->vertex_count = 0u;
    entry->multi_vertex_offset = 0u;
    entry->multi_vertex_count = 0u;
    if (!mq_static_geometry_capture_valid ||
        mq_static_geometry_capture_mode != 0x0009u /* GL_POLYGON */ ||
        mq_static_geometry_capture_count < 3u) return;
    if (entry->pass == 2) {
        if (mq_static_geometry_capture_count >
            MQ_STATIC_GEOMETRY_MULTI_VERTICES - mq_static_geometry_multi_vertex_count) return;
        entry->multi_vertex_offset = mq_static_geometry_multi_vertex_count;
        entry->multi_vertex_count = mq_static_geometry_capture_count;
        memcpy(
            &mq_static_geometry_multi_vertices[mq_static_geometry_multi_vertex_count * MQ_STATIC_GEOMETRY_MULTI_FLOATS],
            mq_static_geometry_multi_capture,
            mq_static_geometry_capture_count * MQ_STATIC_GEOMETRY_MULTI_FLOATS * (mq_u64)sizeof(float)
        );
        mq_static_geometry_multi_vertex_count += mq_static_geometry_capture_count;
        return;
    }
    triangle_vertices = (mq_static_geometry_capture_count - 2u) * 3u;
    if (triangle_vertices > MQ_STATIC_GEOMETRY_POOL_VERTICES - mq_static_geometry_vertex_count) return;
    entry->vertex_offset = mq_static_geometry_vertex_count;
    entry->vertex_count = triangle_vertices;
    for (triangle = 0u; triangle < mq_static_geometry_capture_count - 2u; ++triangle) {
        const mq_u32 source_indices[3] = {0u, triangle + 1u, triangle + 2u};
        mq_u32 corner;
        for (corner = 0u; corner < 3u; ++corner) {
            mq_u32 source = source_indices[corner] * MQ_STATIC_GEOMETRY_VERTEX_FLOATS;
            mq_u32 destination = mq_static_geometry_vertex_count * MQ_STATIC_GEOMETRY_VERTEX_FLOATS;
            memcpy(
                &mq_static_geometry_vertices[destination],
                &mq_static_geometry_capture[source],
                MQ_STATIC_GEOMETRY_VERTEX_FLOATS * (mq_u64)sizeof(float)
            );
            mq_static_geometry_vertex_count += 1u;
        }
    }
}

/* Manage cached native geometry for the renderer fast path. */
static mq_i32 mq_static_geometry_find(mq_u64 key, mq_i32 pass, mq_u32 *slot_out) {
    mq_u64 mixed = key ^ (key >> 33) ^ ((mq_u64)(mq_u32)pass * 0x9E3779B185EBCA87ull);
    mq_u32 slot;
    mixed ^= mixed >> 29;
    slot = (mq_u32)mixed & (MQ_STATIC_GEOMETRY_HASH_SIZE - 1u);
    while (mq_static_geometry_hash[slot] != 0u) {
        mq_u32 entry_index = mq_static_geometry_hash[slot] - 1u;
        if (mq_static_geometry_cache[entry_index].key == key &&
            mq_static_geometry_cache[entry_index].pass == pass) {
            if (slot_out != (mq_u32 *)0) *slot_out = slot;
            return (mq_i32)entry_index;
        }
        slot = (slot + 1u) & (MQ_STATIC_GEOMETRY_HASH_SIZE - 1u);
    }
    if (slot_out != (mq_u32 *)0) *slot_out = slot;
    return -1;
}

/* Manage cached native geometry for the renderer fast path. */
MQ_EXPORT mq_i32 mq_gl_static_geometry_call(mq_u64 key_value, mq_i32 pass_value) {
    mq_u64 key = key_value;
    mq_i32 pass = pass_value;
    mq_u32 slot;
    mq_i32 found;
    if (mq_static_geometry_pending || mq_static_geometry_recording) return 0;
    found = mq_static_geometry_find(key, pass, &slot);
    if (found >= 0) {
        if (mq_render_backend_value == MQ_RENDER_DIRECT3D9 || mq_render_backend_value == MQ_RENDER_VULKAN) {
            const mq_static_geometry_entry_t *entry = &mq_static_geometry_cache[found];
            if (entry->vertex_count == 0u) return 0;
            if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
                return mq_d3d9_draw_interleaved_t2f_v3f(
                    &mq_static_geometry_vertices[entry->vertex_offset * MQ_STATIC_GEOMETRY_VERTEX_FLOATS],
                    entry->vertex_count) > 0;
            }
            return mq_vulkan_draw_interleaved_t2f_v3f(
                &mq_static_geometry_vertices[entry->vertex_offset * MQ_STATIC_GEOMETRY_VERTEX_FLOATS],
                entry->vertex_count) > 0;
        }
        glCallList(mq_static_geometry_cache[found].list_id);
        return 1;
    }
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return 0;
    if (mq_static_geometry_count >= MQ_STATIC_GEOMETRY_CACHE_MAX) return 0;
    {
        mq_u32 list_id = glGenLists(1);
        if (list_id == 0) return 0;
        mq_static_geometry_cache[mq_static_geometry_count].key = key;
        mq_static_geometry_cache[mq_static_geometry_count].pass = pass;
        mq_static_geometry_cache[mq_static_geometry_count].list_id = list_id;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_count = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_count = 0u;
        mq_static_geometry_hash[slot] = (mq_u32)mq_static_geometry_count + 1u;
        mq_static_geometry_pending_entry = mq_static_geometry_count;
        mq_static_geometry_count += 1;
        mq_static_geometry_pending_list = list_id;
        mq_static_geometry_pending_execute = 1;
        mq_static_geometry_pending = 1;
    }
    return 0;
}

/* Create a list without executing its geometry.  Map loading uses this to
 * move driver display-list compilation out of the first playable frames. */
MQ_EXPORT mq_i32 mq_gl_static_geometry_prepare(mq_u64 key_value, mq_i32 pass_value) {
    mq_u64 key = key_value;
    mq_i32 pass = pass_value;
    mq_u32 slot;
    mq_i32 found;
    if (mq_static_geometry_pending || mq_static_geometry_recording) return -1;
    found = mq_static_geometry_find(key, pass, &slot);
    if (found >= 0) return 1;
    if (mq_static_geometry_count >= MQ_STATIC_GEOMETRY_CACHE_MAX) return -1;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        mq_static_geometry_cache[mq_static_geometry_count].key = key;
        mq_static_geometry_cache[mq_static_geometry_count].pass = pass;
        mq_static_geometry_cache[mq_static_geometry_count].list_id = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_count = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_count = 0u;
        mq_static_geometry_hash[slot] = (mq_u32)mq_static_geometry_count + 1u;
        mq_static_geometry_pending_entry = mq_static_geometry_count;
        mq_static_geometry_count += 1;
        mq_static_geometry_pending_list = 0u;
        mq_static_geometry_pending_execute = 0;
        mq_static_geometry_pending = 1;
        return 0;
    }
    {
        mq_u32 list_id = glGenLists(1);
        if (list_id == 0) return -1;
        mq_static_geometry_cache[mq_static_geometry_count].key = key;
        mq_static_geometry_cache[mq_static_geometry_count].pass = pass;
        mq_static_geometry_cache[mq_static_geometry_count].list_id = list_id;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].vertex_count = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_offset = 0u;
        mq_static_geometry_cache[mq_static_geometry_count].multi_vertex_count = 0u;
        mq_static_geometry_hash[slot] = (mq_u32)mq_static_geometry_count + 1u;
        mq_static_geometry_pending_entry = mq_static_geometry_count;
        mq_static_geometry_count += 1;
        mq_static_geometry_pending_list = list_id;
        mq_static_geometry_pending_execute = 0;
        mq_static_geometry_pending = 1;
    }
    return 0;
}

/* Manage cached native geometry for the renderer fast path. */
MQ_EXPORT mq_i32 mq_gl_static_geometry_call_batch(
    const mq_u8 *keys,
    mq_u32 byte_count,
    mq_i32 pass
) {
    static mq_u32 list_ids[MQ_STATIC_GEOMETRY_CACHE_MAX];
    static mq_u32 entry_indices[MQ_STATIC_GEOMETRY_CACHE_MAX];
    mq_u32 count;
    mq_u32 index;
    mq_u32 batch_vertex_count = 0u;
    if (keys == (const mq_u8 *)0 || (byte_count & 7u) != 0u ||
        mq_static_geometry_pending || mq_static_geometry_recording) return 0;
    count = byte_count >> 3;
    if (count == 0u || count > MQ_STATIC_GEOMETRY_CACHE_MAX) return 0;
    for (index = 0; index < count; ++index) {
        mq_u32 offset = index << 3;
        mq_u64 key =
            (mq_u64)keys[offset] |
            ((mq_u64)keys[offset + 1u] << 8) |
            ((mq_u64)keys[offset + 2u] << 16) |
            ((mq_u64)keys[offset + 3u] << 24) |
            ((mq_u64)keys[offset + 4u] << 32) |
            ((mq_u64)keys[offset + 5u] << 40) |
            ((mq_u64)keys[offset + 6u] << 48) |
            ((mq_u64)keys[offset + 7u] << 56);
        mq_i32 found = mq_static_geometry_find(key, pass, (mq_u32 *)0);
        if (found < 0) return 0;
        list_ids[index] = mq_static_geometry_cache[found].list_id;
        entry_indices[index] = (mq_u32)found;
        if (mq_static_geometry_cache[found].vertex_count == 0u ||
            mq_static_geometry_cache[found].vertex_count > MQ_STATIC_GEOMETRY_BATCH_VERTICES - batch_vertex_count) {
            batch_vertex_count = 0u;
            break;
        }
        batch_vertex_count += mq_static_geometry_cache[found].vertex_count;
    }
    if (batch_vertex_count > 0u) {
        mq_u32 destination_vertex = 0u;
        for (index = 0u; index < count; ++index) {
            const mq_static_geometry_entry_t *entry = &mq_static_geometry_cache[entry_indices[index]];
            memcpy(
                &mq_static_geometry_batch[destination_vertex * MQ_STATIC_GEOMETRY_VERTEX_FLOATS],
                &mq_static_geometry_vertices[entry->vertex_offset * MQ_STATIC_GEOMETRY_VERTEX_FLOATS],
                entry->vertex_count * MQ_STATIC_GEOMETRY_VERTEX_FLOATS * (mq_u64)sizeof(float)
            );
            destination_vertex += entry->vertex_count;
        }
        if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
            if (mq_d3d9_draw_interleaved_t2f_v3f(mq_static_geometry_batch, batch_vertex_count) <= 0) return 0;
        } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
            if (mq_vulkan_draw_interleaved_t2f_v3f(mq_static_geometry_batch, batch_vertex_count) <= 0) return 0;
        } else {
            glInterleavedArrays(0x2A27u /* GL_T2F_V3F */, 0, mq_static_geometry_batch);
            glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)batch_vertex_count);
        }
        return (mq_i32)count;
    }
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return 0;
    glCallLists((mq_i32)count, 0x1405u /* GL_UNSIGNED_INT */, list_ids);
    return (mq_i32)count;
}

#define MQ_STATIC_MULTITEXTURE_GROUPS 2048u
#define MQ_STATIC_MULTITEXTURE_BATCH_VERTICES 1048576u
static float mq_static_multitexture_batch[MQ_STATIC_MULTITEXTURE_BATCH_VERTICES * MQ_STATIC_GEOMETRY_MULTI_FLOATS];
static mq_u32 mq_static_multitexture_entries[MQ_STATIC_GEOMETRY_CACHE_MAX];
static mq_u32 mq_static_multitexture_record_groups[MQ_STATIC_GEOMETRY_CACHE_MAX];
static mq_u32 mq_static_multitexture_group_base[MQ_STATIC_MULTITEXTURE_GROUPS];
static mq_u32 mq_static_multitexture_group_lightmap[MQ_STATIC_MULTITEXTURE_GROUPS];
static mq_u32 mq_static_multitexture_group_offset[MQ_STATIC_MULTITEXTURE_GROUPS];
static mq_u32 mq_static_multitexture_group_count[MQ_STATIC_MULTITEXTURE_GROUPS];
static mq_u32 mq_static_multitexture_group_cursor[MQ_STATIC_MULTITEXTURE_GROUPS];
#define MQ_STATIC_MULTITEXTURE_LISTS 512u
static mq_u64 mq_static_multitexture_list_hash[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u64 mq_static_multitexture_list_signature[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_list_bytes[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_list_id[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_list_count = 0u;
#define MQ_STATIC_MULTITEXTURE_VBO_GROUPS 256u
static mq_u64 mq_static_multitexture_vbo_hash[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u64 mq_static_multitexture_vbo_signature[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_vbo_bytes[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_vbo_id[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_vbo_group_count[MQ_STATIC_MULTITEXTURE_LISTS];
static mq_u32 mq_static_multitexture_vbo_group_base[MQ_STATIC_MULTITEXTURE_LISTS][MQ_STATIC_MULTITEXTURE_VBO_GROUPS];
static mq_u32 mq_static_multitexture_vbo_group_lightmap[MQ_STATIC_MULTITEXTURE_LISTS][MQ_STATIC_MULTITEXTURE_VBO_GROUPS];
static mq_u32 mq_static_multitexture_vbo_group_offset[MQ_STATIC_MULTITEXTURE_LISTS][MQ_STATIC_MULTITEXTURE_VBO_GROUPS];
static mq_u32 mq_static_multitexture_vbo_group_vertices[MQ_STATIC_MULTITEXTURE_LISTS][MQ_STATIC_MULTITEXTURE_VBO_GROUPS];
static mq_u32 mq_static_multitexture_vbo_count = 0u;

/* Alias geometry is already reduced by MiniLang to a compact frame command
 * stream.  The stream, shade row and shade scale are immutable for the many
 * repeated entities in a scene, so preserve the driver's compiled result
 * instead of decoding and resubmitting every vertex on every frame.  Origin,
 * angles, model scale and render state deliberately remain outside the list. */
#define MQ_ALIAS_LIST_CACHE_MAX 2048u
static mq_u64 mq_alias_list_hash[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u64 mq_alias_list_signature[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u32 mq_alias_list_bytes[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u32 mq_alias_list_shade_count[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u32 mq_alias_list_shade_light[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u32 mq_alias_list_id[MQ_ALIAS_LIST_CACHE_MAX];
static mq_i32 mq_alias_list_triangles[MQ_ALIAS_LIST_CACHE_MAX];
static mq_u32 mq_alias_list_count = 0u;

/* Describe one alias vertex consumed by the renderer or asset loader. */
typedef struct mq_alias_vertex_s {
    float s;
    float t;
    mq_u8 r;
    mq_u8 g;
    mq_u8 b;
    mq_u8 a;
    float x;
    float y;
    float z;
} mq_alias_vertex_t;

/* Texture coordinates and both source poses stored in the bounded MD2 VBO
 * cache. OpenGL interpolates the two positions in the vertex shader. */
typedef struct mq_md2_geometry_vertex_s {
    float s;
    float t;
    float x;
    float y;
    float z;
    float old_x;
    float old_y;
    float old_z;
} mq_md2_geometry_vertex_t;

#define MQ_ALIAS_VBO_CACHE_MAX 512u
#define MQ_ALIAS_COMMAND_VERTICES 4096u
#define MQ_ALIAS_TRIANGLE_VERTICES 16384u
static mq_alias_vertex_t mq_alias_command_vertices[MQ_ALIAS_COMMAND_VERTICES];
static mq_alias_vertex_t mq_alias_triangle_vertices[MQ_ALIAS_TRIANGLE_VERTICES];
static mq_md2_geometry_vertex_t mq_md2_geometry_vertices[MQ_ALIAS_TRIANGLE_VERTICES];
static mq_u8 mq_md2_normal_indices[MQ_ALIAS_TRIANGLE_VERTICES];
#define MQ_PARTICLE_BATCH_MAX 8192u
#define MQ_PARTICLE_RECORD_BYTES 16u
#define MQ_CLASSIC_PARTICLE_AXIS_SIZE 1.5f
#define MQ_ENHANCED_PARTICLE_HALF_SIZE 0.75f
static mq_alias_vertex_t mq_particle_vertices[MQ_PARTICLE_BATCH_MAX * 6u];
static mq_u64 mq_alias_vbo_hash[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u64 mq_alias_vbo_signature[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_bytes[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_shade_count[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_shade_light[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_id[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_vertices[MQ_ALIAS_VBO_CACHE_MAX];
static mq_i32 mq_alias_vbo_triangles[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_count = 0u;
/* One orphaned streaming buffer replaces both synchronous client-array
 * uploads and the former unbounded per-lighting-result VBO cache. */
static mq_u32 mq_alias_stream_vbo = 0u;

/* Quake II MD2 frames are expanded from their original compact bytes directly
 * into a bounded, direct-mapped VBO cache. A second VBO supplies the original
 * per-vertex normal vector to the colored alias-lighting shader. */
#define MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX 1024u
static mq_u64 mq_alias_rgb_geometry_key[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static mq_u32 mq_alias_rgb_geometry_state[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static mq_u32 mq_alias_rgb_geometry_bytes[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static mq_u32 mq_alias_rgb_geometry_vbo[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static mq_u32 mq_alias_rgb_lightcoord_vbo[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static mq_u32 mq_alias_rgb_geometry_vertices[MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX];
static float mq_alias_rgb_lightcoords[MQ_ALIAS_TRIANGLE_VERTICES * 3u];

/* Mix model identity and the immutable MD2 frame pair into the direct-map slot. */
static mq_u32 mq_alias_rgb_geometry_slot(mq_u64 geometry_key, mq_u32 geometry_state) {
    mq_u64 mixed = geometry_key ^ (geometry_key >> 32) ^
        ((mq_u64)geometry_state * 0x9e3779b97f4a7c15ull);
    mixed ^= mixed >> 30;
    mixed *= 0xbf58476d1ce4e5b9ull;
    mixed ^= mixed >> 27;
    mixed *= 0x94d049bb133111ebull;
    mixed ^= mixed >> 31;
    return (mq_u32)mixed & (MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX - 1u);
}

/* Draw cached multitextured geometry through the native fast path. */
static void mq_static_multitexture_draw_vbo(mq_u32 scene) {
    mq_u32 group;
    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, mq_static_multitexture_vbo_id[scene]);
    glEnableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
    glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    mq_gl_client_active_texture_value(0x84C1u /* GL_TEXTURE1 */);
    glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    mq_gl_client_active_texture_value(0x84C0u);
    glTexCoordPointer(2, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), (const void *)0);
    mq_gl_client_active_texture_value(0x84C1u);
    glTexCoordPointer(2, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), (const void *)(2u * sizeof(float)));
    glVertexPointer(3, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), (const void *)(4u * sizeof(float)));
    for (group = 0u; group < mq_static_multitexture_vbo_group_count[scene]; ++group) {
        mq_gl_active_texture_value(0x84C0u);
        glBindTexture(0x0DE1u /* GL_TEXTURE_2D */, mq_static_multitexture_vbo_group_base[scene][group]);
        mq_gl_active_texture_value(0x84C1u);
        glBindTexture(0x0DE1u /* GL_TEXTURE_2D */, mq_static_multitexture_vbo_group_lightmap[scene][group]);
        glDrawArrays(
            0x0004u /* GL_TRIANGLES */,
            (mq_i32)mq_static_multitexture_vbo_group_offset[scene][group],
            (mq_i32)mq_static_multitexture_vbo_group_vertices[scene][group]
        );
    }
    mq_gl_client_active_texture_value(0x84C1u);
    glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    mq_gl_client_active_texture_value(0x84C0u);
    glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
}

/* Manage cached native geometry for the renderer fast path. */
MQ_EXPORT mq_i32 mq_gl_static_geometry_call_multitexture_batch(
    const mq_u8 *records,
    mq_u32 byte_count
) {
    mq_u32 count;
    mq_u32 index;
    mq_u32 group_count = 0u;
    mq_u32 total_vertices = 0u;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return 0;
    if (records == (const mq_u8 *)0 || (byte_count & 15u) != 0u ||
        !mq_valid_wgl_proc((const void *)mq_gl_active_texture_value) ||
        !mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value) ||
        mq_static_geometry_recording || mq_static_geometry_pending) {
        return 0;
    }
    count = byte_count >> 4;
    if (count == 0u || count > MQ_STATIC_GEOMETRY_CACHE_MAX) return 0;

    if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
        mq_u64 hash = 1469598103934665603ull;
        mq_u64 signature = 0x9e3779b97f4a7c15ull;
        mq_u32 scene;
        for (index = 0u; index < byte_count; ++index) {
            hash = (hash ^ records[index]) * 1099511628211ull;
            signature ^= ((mq_u64)records[index] + 0x9e3779b97f4a7c15ull + (signature << 6) + (signature >> 2));
        }
        for (scene = 0u; scene < mq_static_multitexture_vbo_count; ++scene) {
            if (mq_static_multitexture_vbo_hash[scene] == hash &&
                mq_static_multitexture_vbo_signature[scene] == signature &&
                mq_static_multitexture_vbo_bytes[scene] == byte_count) {
                mq_static_multitexture_draw_vbo(scene);
                return (mq_i32)count;
            }
        }
    }

    /* The visible BSP set is stable while the camera remains in the same
     * region. Compile the complete fixed-function two-texture stream once;
     * subsequent frames become a single driver call while animated lightmaps
     * continue to update the referenced texture objects independently. */
    {
        mq_u64 hash = 1469598103934665603ull;
        mq_u64 signature = 0x9e3779b97f4a7c15ull;
        mq_u32 cache_index;
        for (index = 0u; index < byte_count; ++index) {
            hash = (hash ^ records[index]) * 1099511628211ull;
            signature ^= ((mq_u64)records[index] + 0x9e3779b97f4a7c15ull + (signature << 6) + (signature >> 2));
        }
        for (cache_index = 0u; cache_index < mq_static_multitexture_list_count; ++cache_index) {
            if (mq_static_multitexture_list_hash[cache_index] == hash &&
                mq_static_multitexture_list_signature[cache_index] == signature &&
                mq_static_multitexture_list_bytes[cache_index] == byte_count) {
                glCallList(mq_static_multitexture_list_id[cache_index]);
                return (mq_i32)count;
            }
        }
        if ((!mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) ||
             !mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) ||
             !mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value)) &&
            mq_static_multitexture_list_count < MQ_STATIC_MULTITEXTURE_LISTS) {
            mq_u32 list_id = glGenLists(1);
            mq_u32 last_base = 0xffffffffu;
            mq_u32 last_lightmap = 0xffffffffu;
            if (list_id != 0u) {
                /* Validate the complete stream before opening a display list;
                 * an invalid entry must fall back without leaving GL compiling. */
                for (index = 0u; index < count; ++index) {
                    mq_u32 offset = index << 4;
                    mq_u64 key =
                        (mq_u64)records[offset] |
                        ((mq_u64)records[offset + 1u] << 8) |
                        ((mq_u64)records[offset + 2u] << 16) |
                        ((mq_u64)records[offset + 3u] << 24) |
                        ((mq_u64)records[offset + 4u] << 32) |
                        ((mq_u64)records[offset + 5u] << 40) |
                        ((mq_u64)records[offset + 6u] << 48) |
                        ((mq_u64)records[offset + 7u] << 56);
                    mq_i32 found = mq_static_geometry_find(key, 2, (mq_u32 *)0);
                    if (found < 0 || mq_static_geometry_cache[found].multi_vertex_count < 3u) {
                        glDeleteLists(list_id, 1);
                        list_id = 0u;
                        break;
                    }
                }
            }
            if (list_id != 0u) {
                glNewList(list_id, GL_COMPILE_AND_EXECUTE);
                for (index = 0u; index < count; ++index) {
                    mq_u32 offset = index << 4;
                    mq_u64 key =
                        (mq_u64)records[offset] |
                        ((mq_u64)records[offset + 1u] << 8) |
                        ((mq_u64)records[offset + 2u] << 16) |
                        ((mq_u64)records[offset + 3u] << 24) |
                        ((mq_u64)records[offset + 4u] << 32) |
                        ((mq_u64)records[offset + 5u] << 40) |
                        ((mq_u64)records[offset + 6u] << 48) |
                        ((mq_u64)records[offset + 7u] << 56);
                    mq_u32 base_texture =
                        (mq_u32)records[offset + 8u] |
                        ((mq_u32)records[offset + 9u] << 8) |
                        ((mq_u32)records[offset + 10u] << 16) |
                        ((mq_u32)records[offset + 11u] << 24);
                    mq_u32 lightmap_texture =
                        (mq_u32)records[offset + 12u] |
                        ((mq_u32)records[offset + 13u] << 8) |
                        ((mq_u32)records[offset + 14u] << 16) |
                        ((mq_u32)records[offset + 15u] << 24);
                    mq_i32 found = mq_static_geometry_find(key, 2, (mq_u32 *)0);
                    const mq_static_geometry_entry_t *entry = &mq_static_geometry_cache[found];
                    mq_u32 vertex;
                    if (base_texture != last_base) {
                        mq_gl_active_texture_value(0x84C0u);
                        glBindTexture(0x0DE1u, base_texture);
                        last_base = base_texture;
                    }
                    if (lightmap_texture != last_lightmap) {
                        mq_gl_active_texture_value(0x84C1u);
                        glBindTexture(0x0DE1u, lightmap_texture);
                        last_lightmap = lightmap_texture;
                    }
                    glBegin(0x0009u /* GL_POLYGON */);
                    for (vertex = 0u; vertex < entry->multi_vertex_count; ++vertex) {
                        const float *item = &mq_static_geometry_multi_vertices[
                            (entry->multi_vertex_offset + vertex) * MQ_STATIC_GEOMETRY_MULTI_FLOATS
                        ];
                        mq_gl_multi_tex_coord2f_value(0x84C0u, item[0], item[1]);
                        mq_gl_multi_tex_coord2f_value(0x84C1u, item[2], item[3]);
                        glVertex3f(item[4], item[5], item[6]);
                    }
                    glEnd();
                }
                glEndList();
                cache_index = mq_static_multitexture_list_count;
                mq_static_multitexture_list_hash[cache_index] = hash;
                mq_static_multitexture_list_signature[cache_index] = signature;
                mq_static_multitexture_list_bytes[cache_index] = byte_count;
                mq_static_multitexture_list_id[cache_index] = list_id;
                mq_static_multitexture_list_count += 1u;
                return (mq_i32)count;
            }
        }
    }

    for (index = 0u; index < count; ++index) {
        mq_u32 offset = index << 4;
        mq_u64 key =
            (mq_u64)records[offset] |
            ((mq_u64)records[offset + 1u] << 8) |
            ((mq_u64)records[offset + 2u] << 16) |
            ((mq_u64)records[offset + 3u] << 24) |
            ((mq_u64)records[offset + 4u] << 32) |
            ((mq_u64)records[offset + 5u] << 40) |
            ((mq_u64)records[offset + 6u] << 48) |
            ((mq_u64)records[offset + 7u] << 56);
        mq_u32 base_texture =
            (mq_u32)records[offset + 8u] |
            ((mq_u32)records[offset + 9u] << 8) |
            ((mq_u32)records[offset + 10u] << 16) |
            ((mq_u32)records[offset + 11u] << 24);
        mq_u32 lightmap_texture =
            (mq_u32)records[offset + 12u] |
            ((mq_u32)records[offset + 13u] << 8) |
            ((mq_u32)records[offset + 14u] << 16) |
            ((mq_u32)records[offset + 15u] << 24);
        mq_i32 found = mq_static_geometry_find(key, 2, (mq_u32 *)0);
        const mq_static_geometry_entry_t *entry;
        mq_u32 group = 0u;
        mq_u32 triangle_vertices;
        if (found < 0) return 0;
        entry = &mq_static_geometry_cache[found];
        if (entry->multi_vertex_count < 3u) return 0;
        triangle_vertices = (entry->multi_vertex_count - 2u) * 3u;
        while (group < group_count &&
            (mq_static_multitexture_group_base[group] != base_texture ||
             mq_static_multitexture_group_lightmap[group] != lightmap_texture)) group += 1u;
        if (group == group_count) {
            if (group_count >= MQ_STATIC_MULTITEXTURE_GROUPS) return 0;
            mq_static_multitexture_group_base[group] = base_texture;
            mq_static_multitexture_group_lightmap[group] = lightmap_texture;
            mq_static_multitexture_group_count[group] = 0u;
            group_count += 1u;
        }
        if (triangle_vertices > MQ_STATIC_MULTITEXTURE_BATCH_VERTICES - total_vertices) return 0;
        mq_static_multitexture_entries[index] = (mq_u32)found;
        mq_static_multitexture_record_groups[index] = group;
        mq_static_multitexture_group_count[group] += triangle_vertices;
        total_vertices += triangle_vertices;
    }

    total_vertices = 0u;
    for (index = 0u; index < group_count; ++index) {
        mq_static_multitexture_group_offset[index] = total_vertices;
        mq_static_multitexture_group_cursor[index] = total_vertices;
        total_vertices += mq_static_multitexture_group_count[index];
    }
    for (index = 0u; index < count; ++index) {
        const mq_static_geometry_entry_t *entry =
            &mq_static_geometry_cache[mq_static_multitexture_entries[index]];
        mq_u32 group = mq_static_multitexture_record_groups[index];
        mq_u32 triangle;
        for (triangle = 0u; triangle < entry->multi_vertex_count - 2u; ++triangle) {
            const mq_u32 source_indices[3] = {0u, triangle + 1u, triangle + 2u};
            mq_u32 corner;
            for (corner = 0u; corner < 3u; ++corner) {
                mq_u32 source = (entry->multi_vertex_offset + source_indices[corner]) * MQ_STATIC_GEOMETRY_MULTI_FLOATS;
                mq_u32 destination = mq_static_multitexture_group_cursor[group] * MQ_STATIC_GEOMETRY_MULTI_FLOATS;
                memcpy(
                    &mq_static_multitexture_batch[destination],
                    &mq_static_geometry_multi_vertices[source],
                    MQ_STATIC_GEOMETRY_MULTI_FLOATS * (mq_u64)sizeof(float)
                );
                mq_static_multitexture_group_cursor[group] += 1u;
            }
        }
    }

    if (group_count <= MQ_STATIC_MULTITEXTURE_VBO_GROUPS &&
        mq_static_multitexture_vbo_count < MQ_STATIC_MULTITEXTURE_LISTS &&
        mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value)) {
        mq_u32 scene = mq_static_multitexture_vbo_count;
        mq_u32 buffer = 0u;
        mq_u64 hash = 1469598103934665603ull;
        mq_u64 signature = 0x9e3779b97f4a7c15ull;
        mq_gl_gen_buffers_value(1, &buffer);
        if (buffer != 0u) {
            for (index = 0u; index < byte_count; ++index) {
                hash = (hash ^ records[index]) * 1099511628211ull;
                signature ^= ((mq_u64)records[index] + 0x9e3779b97f4a7c15ull + (signature << 6) + (signature >> 2));
            }
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, buffer);
            mq_gl_buffer_data_value(
                0x8892u /* GL_ARRAY_BUFFER */,
                (mq_i64)(total_vertices * MQ_STATIC_GEOMETRY_MULTI_FLOATS * sizeof(float)),
                mq_static_multitexture_batch,
                0x88E4u /* GL_STATIC_DRAW */
            );
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
            mq_static_multitexture_vbo_hash[scene] = hash;
            mq_static_multitexture_vbo_signature[scene] = signature;
            mq_static_multitexture_vbo_bytes[scene] = byte_count;
            mq_static_multitexture_vbo_id[scene] = buffer;
            mq_static_multitexture_vbo_group_count[scene] = group_count;
            for (index = 0u; index < group_count; ++index) {
                mq_static_multitexture_vbo_group_base[scene][index] = mq_static_multitexture_group_base[index];
                mq_static_multitexture_vbo_group_lightmap[scene][index] = mq_static_multitexture_group_lightmap[index];
                mq_static_multitexture_vbo_group_offset[scene][index] = mq_static_multitexture_group_offset[index];
                mq_static_multitexture_vbo_group_vertices[scene][index] = mq_static_multitexture_group_count[index];
            }
            mq_static_multitexture_vbo_count += 1u;
            mq_static_multitexture_draw_vbo(scene);
            return (mq_i32)count;
        }
    }

    glEnableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
    glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    mq_gl_client_active_texture_value(0x84C1u /* GL_TEXTURE1 */);
    glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    for (index = 0u; index < group_count; ++index) {
        const float *group = &mq_static_multitexture_batch[
            mq_static_multitexture_group_offset[index] * MQ_STATIC_GEOMETRY_MULTI_FLOATS
        ];
        mq_gl_active_texture_value(0x84C0u);
        glBindTexture(0x0DE1u /* GL_TEXTURE_2D */, mq_static_multitexture_group_base[index]);
        mq_gl_active_texture_value(0x84C1u);
        glBindTexture(0x0DE1u /* GL_TEXTURE_2D */, mq_static_multitexture_group_lightmap[index]);
        mq_gl_client_active_texture_value(0x84C0u);
        glTexCoordPointer(2, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), group);
        mq_gl_client_active_texture_value(0x84C1u);
        glTexCoordPointer(2, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), group + 2);
        glVertexPointer(3, 0x1406u /* GL_FLOAT */, 7 * (mq_i32)sizeof(float), group + 4);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)mq_static_multitexture_group_count[index]);
    }
    mq_gl_client_active_texture_value(0x84C1u);
    glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    mq_gl_client_active_texture_value(0x84C0u);
    glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    return (mq_i32)count;
}

/* Manage cached native geometry for the renderer fast path. */
MQ_EXPORT void mq_gl_static_geometry_clear(void) {
    mq_i32 i;
    if (mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_gl_alias_program_active &&
        mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) {
        mq_gl_use_program_value(0u);
        mq_gl_alias_program_active = 0;
    }
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        for (i = 0; i < MQ_STATIC_GEOMETRY_HASH_SIZE; ++i) mq_static_geometry_hash[i] = 0u;
        mq_static_geometry_count = 0;
        mq_static_geometry_pending = 0;
        mq_static_geometry_pending_list = 0;
        mq_static_geometry_pending_execute = 1;
        mq_static_geometry_pending_entry = -1;
        mq_static_geometry_recording = 0;
        mq_static_geometry_vertex_count = 0u;
        mq_static_geometry_multi_vertex_count = 0u;
        mq_static_multitexture_list_count = 0u;
        mq_static_multitexture_vbo_count = 0u;
        mq_alias_list_count = 0u;
        mq_alias_vbo_count = 0u;
        mq_alias_stream_vbo = 0u;
        for (i = 0; i < (mq_i32)MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX; ++i) {
            mq_alias_rgb_geometry_vbo[i] = 0u;
            mq_alias_rgb_lightcoord_vbo[i] = 0u;
            mq_alias_rgb_geometry_vertices[i] = 0u;
        }
        return;
    }
    if (mq_static_geometry_recording) {
        glEndList();
        mq_static_geometry_recording = 0;
    }
    for (i = 0; i < mq_static_geometry_count; ++i) {
        if (mq_static_geometry_cache[i].list_id != 0) glDeleteLists(mq_static_geometry_cache[i].list_id, 1);
    }
    for (i = 0; i < (mq_i32)mq_static_multitexture_list_count; ++i) {
        if (mq_static_multitexture_list_id[i] != 0u) glDeleteLists(mq_static_multitexture_list_id[i], 1);
    }
    for (i = 0; i < (mq_i32)mq_alias_list_count; ++i) {
        if (mq_alias_list_id[i] != 0u) glDeleteLists(mq_alias_list_id[i], 1);
    }
    if (mq_valid_wgl_proc((const void *)mq_gl_delete_buffers_value)) {
        for (i = 0; i < (mq_i32)mq_static_multitexture_vbo_count; ++i) {
            if (mq_static_multitexture_vbo_id[i] != 0u) mq_gl_delete_buffers_value(1, &mq_static_multitexture_vbo_id[i]);
        }
        for (i = 0; i < (mq_i32)mq_alias_vbo_count; ++i) {
            if (mq_alias_vbo_id[i] != 0u) mq_gl_delete_buffers_value(1, &mq_alias_vbo_id[i]);
        }
        for (i = 0; i < (mq_i32)MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX; ++i) {
            if (mq_alias_rgb_geometry_vbo[i] != 0u) {
                mq_gl_delete_buffers_value(1, &mq_alias_rgb_geometry_vbo[i]);
            }
            if (mq_alias_rgb_lightcoord_vbo[i] != 0u) {
                mq_gl_delete_buffers_value(1, &mq_alias_rgb_lightcoord_vbo[i]);
            }
        }
        if (mq_alias_stream_vbo != 0u) mq_gl_delete_buffers_value(1, &mq_alias_stream_vbo);
    }
    for (i = 0; i < MQ_STATIC_GEOMETRY_HASH_SIZE; ++i) mq_static_geometry_hash[i] = 0u;
    mq_static_geometry_count = 0;
    mq_static_geometry_pending = 0;
    mq_static_geometry_pending_list = 0;
    mq_static_geometry_pending_execute = 1;
    mq_static_geometry_pending_entry = -1;
    mq_static_geometry_vertex_count = 0u;
    mq_static_geometry_multi_vertex_count = 0u;
    mq_static_multitexture_list_count = 0u;
    mq_static_multitexture_vbo_count = 0u;
    mq_alias_list_count = 0u;
    mq_alias_vbo_count = 0u;
    mq_alias_stream_vbo = 0u;
    for (i = 0; i < (mq_i32)MQ_ALIAS_RGB_GEOMETRY_CACHE_MAX; ++i) {
        mq_alias_rgb_geometry_vbo[i] = 0u;
        mq_alias_rgb_lightcoord_vbo[i] = 0u;
        mq_alias_rgb_geometry_vertices[i] = 0u;
    }
}

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
#define MQ_GWL_STYLE (-16)
#define MQ_CW_USEDEFAULT ((mq_i32)0x80000000u)
#define MQ_SW_SHOW 5
#define MQ_SW_SHOWNORMAL 1
#define MQ_SW_SHOWMINNOACTIVE 7
#define MQ_SWP_NOMOVE 0x0002u
#define MQ_SWP_NOZORDER 0x0004u
#define MQ_SWP_NOACTIVATE 0x0010u
#define MQ_SWP_FRAMECHANGED 0x0020u
#define MQ_PM_REMOVE 0x0001u
#define MQ_WM_DESTROY 0x0002u
#define MQ_WM_MOVE 0x0003u
#define MQ_WM_SIZE 0x0005u
#define MQ_WM_KILLFOCUS 0x0008u
#define MQ_WM_CLOSE 0x0010u
#define MQ_WM_QUIT 0x0012u
#define MQ_WM_ACTIVATEAPP 0x001Cu
#define MQ_WM_INPUT 0x00FFu
#define MQ_WM_KEYDOWN 0x0100u
#define MQ_WM_KEYUP 0x0101u
#define MQ_WM_CHAR 0x0102u
#define MQ_WM_SYSKEYDOWN 0x0104u
#define MQ_WM_SYSKEYUP 0x0105u
#define MQ_WM_SYSCHAR 0x0106u
#define MQ_WM_LBUTTONDOWN 0x0201u
#define MQ_WM_LBUTTONUP 0x0202u
#define MQ_WM_RBUTTONDOWN 0x0204u
#define MQ_WM_RBUTTONUP 0x0205u
#define MQ_WM_MBUTTONDOWN 0x0207u
#define MQ_WM_MBUTTONUP 0x0208u
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
#define MQ_TIME_BYTES 4u
#define MQ_VK_LBUTTON 0x01
#define MQ_VK_RBUTTON 0x02
#define MQ_VK_MBUTTON 0x04
#define MQ_JOYERR_NOERROR 0
#define MQ_JOYCAPS_HASPOV 0x0010u
#define MQ_JOY_RETURNALL 0x000000FFu
#define MQ_JOY_RETURNCENTERED 0x00000400u
#define MQ_JOY_POVCENTERED 0x0000FFFFu
#define MQ_INPUT_EVENT_KEY 1u
#define MQ_INPUT_EVENT_MOUSE 2u
#define MQ_INPUT_EVENT_WHEEL 3u
#define MQ_INPUT_EVENT_FOCUS 4u
#define MQ_INPUT_EVENT_SCAN_KEY 5u
#define MQ_FILE_MAP_WRITE 0x0002u
#define MQ_FILE_MAP_READ 0x0004u
#define MQ_WAIT_OBJECT_0 0u
#define MQ_WAIT_TIMEOUT 258u
#define MQ_INFINITE 0xFFFFFFFFu
#define MQ_STD_INPUT_HANDLE 0xFFFFFFF6u
#define MQ_STD_OUTPUT_HANDLE 0xFFFFFFF5u
#define MQ_FILE_TYPE_PIPE 0x0003u
#define MQ_KEY_EVENT 0x0001u
#define MQ_SM_CXSCREEN 0
#define MQ_SM_CYSCREEN 1
#define MQ_SM_CXICON 11
#define MQ_SM_CYICON 12
#define MQ_SM_CXSMICON 49
#define MQ_SM_CYSMICON 50
#define MQ_ENUM_CURRENT_SETTINGS 0xFFFFFFFFu
#define MQ_CDS_FULLSCREEN 0x00000004u
#define MQ_CDS_TEST 0x00000002u
#define MQ_DISP_CHANGE_SUCCESSFUL 0
#define MQ_DM_BITSPERPEL 0x00040000u
#define MQ_DM_PELSWIDTH 0x00080000u
#define MQ_DM_PELSHEIGHT 0x00100000u
#define MQ_DM_DISPLAYFREQUENCY 0x00400000u
#define MQ_SIZE_MINIMIZED 1u
#define MQ_RIM_TYPEMOUSE 0u
#define MQ_RID_INPUT 0x10000003u
#define MQ_HID_USAGE_PAGE_GENERIC 0x01u
#define MQ_HID_USAGE_GENERIC_MOUSE 0x02u
#define MQ_IDYES 6
#define MQ_MB_YESNO 0x00000004u
#define MQ_MB_ICONQUESTION 0x00000020u
#define MQ_MB_SETFOREGROUND 0x00010000u
#define MQ_IDC_ARROW ((LPCWSTR)(ULONG_PTR)32512u)
#define MQ_IDI_APPLICATION ((LPCWSTR)(ULONG_PTR)32512u)
#define MQ_IDI_MINIQUAKE ((LPCWSTR)(ULONG_PTR)1u)
#define MQ_IMAGE_ICON 1u
#define MQ_LR_SHARED 0x00008000u
#define MQ_AF_INET 2
#define MQ_SOCK_DGRAM 2
#define MQ_IPPROTO_UDP 17
#define MQ_SOL_SOCKET 0xffff
#define MQ_SO_BROADCAST 0x0020
#define MQ_MSG_PEEK 0x0002
#define MQ_FIONBIO ((LONG)0x8004667eu)
#define MQ_INVALID_SOCKET ((SOCKET)~(SOCKET)0)
#define MQ_SOCKET_ERROR (-1)
#define MQ_WSAEWOULDBLOCK 10035
#define MQ_WSAEMSGSIZE 10040
#define MQ_WSAECONNRESET 10054
#define MQ_WSAECONNREFUSED 10061
#define MQ_INADDR_NONE 0xffffffffu

int _fltused = 0;

static const WCHAR mq_window_class_name[] = {
    'M','i','n','i','Q','u','a','k','e','W','i','n','d','o','w',0
};
static const WCHAR mq_quit_text[] = {
    'A','r','e',' ','y','o','u',' ','s','u','r','e',' ','y','o','u',' ',
    'w','a','n','t',' ','t','o',' ','q','u','i','t','?',0
};
static const WCHAR mq_quit_caption[] = {
    'C','o','n','f','i','r','m',' ','E','x','i','t',0
};

static HWND mq_window = MQ_NULL;
static HDC mq_window_dc = MQ_NULL;
static HGLRC mq_gl_context = MQ_NULL;
static HINSTANCE mq_instance = MQ_NULL;
static mq_i32 mq_class_registered = 0;
static mq_i32 mq_running = 0;
/*
 * VID_RestartRenderer deliberately destroys the current HWND before creating
 * the replacement for the other rendering API.  WM_DESTROY normally posts a
 * thread-wide WM_QUIT, which survives that replacement and made the next
 * mq_win_poll() terminate the otherwise successful renderer switch.  Suppress
 * the quit notification only around our own synchronous teardown; a real
 * WM_CLOSE still follows the normal WM_DESTROY/PostQuitMessage path.
 */
static mq_i32 mq_programmatic_window_destroy = 0;
static mq_i32 mq_active_app = 0;
static mq_i32 mq_minimized = 0;
static mq_i32 mq_window_x_value = 0;
static mq_i32 mq_window_y_value = 0;
static mq_i32 mq_display_fullscreen = 0;
static mq_i32 mq_window_style_fullscreen = 0;
static mq_i32 mq_display_use_current = 0;
static mq_i32 mq_display_changed = 0;
static mq_i32 mq_display_suspended = 0;
static MQ_DEVMODEW mq_requested_display_mode;
#define MQ_DISPLAY_MODE_CAPACITY 256
static MQ_DEVMODEW mq_display_modes[MQ_DISPLAY_MODE_CAPACITY];
static mq_u32 mq_display_mode_count_value = 0;
static mq_u8 mq_original_gamma_ramp[1536];
static mq_i32 mq_original_gamma_valid = 0;
static mq_i32 mq_cursor_captured = 0;
static mq_i32 mq_mouse_ready = 0;
static mq_i32 mq_mouse_delta_x = 0;
static mq_i32 mq_mouse_delta_y = 0;
static mq_i32 mq_raw_mouse_registered = 0;
static mq_i32 mq_mouse_wheel_delta = 0;
#define MQ_INPUT_QUEUE_CAPACITY 256
static mq_u32 mq_input_queue[MQ_INPUT_QUEUE_CAPACITY];
static mq_u32 mq_input_head = 0;
static mq_u32 mq_input_tail = 0;
static mq_u8 mq_virtual_key_down[256];
static mq_u8 mq_virtual_key_scan[256];
static mq_u8 mq_mouse_button_down[3];
#define MQ_TEXT_QUEUE_CAPACITY 64
static mq_u16 mq_text_queue[MQ_TEXT_QUEUE_CAPACITY];
static mq_u32 mq_text_head = 0;
static mq_u32 mq_text_tail = 0;
static mq_u8 mq_key_pressed[256];
static mq_i32 mq_joy_available = 0;
static UINT mq_joy_id = 0;
static mq_u32 mq_joy_button_count_value = 0;
static mq_i32 mq_joy_has_pov_value = 0;
static MQ_JOYINFOEX mq_joy_info;

static HWAVEOUT mq_wave_output = MQ_NULL;
#define MQ_AUDIO_BUFFER_COUNT 8
#define MQ_AUDIO_BUFFER_BYTES 16384
static mq_u8 mq_audio_data[MQ_AUDIO_BUFFER_COUNT][MQ_AUDIO_BUFFER_BYTES];
static MQ_WAVEHDR mq_audio_headers[MQ_AUDIO_BUFFER_COUNT];
static mq_u8 mq_audio_header_queued[MQ_AUDIO_BUFFER_COUNT];
static mq_u32 mq_audio_next_buffer = 0;
static mq_u32 mq_audio_buffer_count = 0;
static mq_u32 mq_audio_bytes_per_sample = 2;
static mq_u32 mq_audio_submitted_count = 0;
static mq_u32 mq_audio_completed_count = 0;
static mq_u32 mq_audio_underrun_count = 0;
static mq_u64 mq_audio_completed_bytes = 0;

static mq_i32 mq_winsock_started = 0;
static mq_u32 mq_udp_socket_count = 0;
static char mq_udp_last_address_text[32] = "0.0.0.0";
static char mq_udp_local_address_text[32] = "127.0.0.1";
static char mq_udp_bound_address_text[32] = "0.0.0.0";
static char mq_udp_host_name_text[256] = "";
static char mq_udp_resolved_address_text[32] = "";
static char mq_udp_reverse_name_text[256] = "";
static mq_u32 mq_udp_last_port_value = 0;
static mq_i32 mq_udp_last_error_value = 0;
static mq_u8 mq_wsa_data[512];

/* Reinterpret MiniLang's IEEE-754 bit pattern as a native float. */
static float mq_bits_to_float(mq_u32 bits) {
    union { mq_u32 u; float f; } value;
    value.u = bits;
    return value.f;
}

/* Convert the scalar between MiniLang and native representations. */
static mq_u32 mq_float_to_bits(float number) {
    union { mq_u32 u; float f; } value;
    value.f = number;
    return value.u;
}

/* Return the absolute value of a signed integer. */
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

/* Refresh the mouse confinement rectangle for the active window. */
static mq_i32 mq_update_clip_cursor(void) {
    MQ_RECT rectangle;
    MQ_POINT upper_left;
    MQ_POINT lower_right;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    upper_left.x = rectangle.left;
    upper_left.y = rectangle.top;
    lower_right.x = rectangle.right;
    lower_right.y = rectangle.bottom;
    if (!ClientToScreen(mq_window, &upper_left) || !ClientToScreen(mq_window, &lower_right)) {
        return 0;
    }
    rectangle.left = upper_left.x;
    rectangle.top = upper_left.y;
    rectangle.right = lower_right.x;
    rectangle.bottom = lower_right.y;
    return ClipCursor(&rectangle) != 0;
}

/* Submit input event to the native queue. */
static void mq_push_input_event(mq_u32 type, mq_u32 code, mq_i32 value) {
    mq_u32 next = (mq_input_head + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    mq_u32 packed = ((type & 0xFFu) << 24) | ((code & 0xFFFFu) << 8) | ((mq_u32)value & 0xFFu);
    if (next == mq_input_tail) {
        mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    }
    mq_input_queue[mq_input_head] = packed;
    mq_input_head = next;
}

/* Release all input keys. */
static void mq_release_all_input_keys(void) {
    mq_u32 index;
    for (index = 0; index < 256u; ++index) {
        if (mq_virtual_key_down[index]) {
            mq_push_input_event(MQ_INPUT_EVENT_SCAN_KEY, mq_virtual_key_scan[index], 0);
            mq_virtual_key_down[index] = 0;
            mq_virtual_key_scan[index] = 0;
        }
    }
    for (index = 0; index < 3u; ++index) {
        if (mq_mouse_button_down[index]) {
            mq_push_input_event(MQ_INPUT_EVENT_MOUSE, index, 0);
            mq_mouse_button_down[index] = 0;
        }
    }
}

/* Copy bytes into caller-owned storage. */
static void mq_copy_bytes(mq_u8 *destination, const mq_u8 *source, mq_u32 count) {
    mq_u32 i = 0;
    while (i < count) {
        destination[i] = source[i];
        ++i;
    }
}

/* Clear a caller-provided byte range. */
static void mq_zero_bytes(mq_u8 *destination, mq_u32 count) {
    mq_u32 i = 0;
    while (i < count) {
        destination[i] = 0;
        ++i;
    }
}

/* Copy c string into caller-owned storage. */
static void mq_copy_c_string(char *destination, mq_u32 capacity, const char *source) {
    mq_u32 index = 0;
    if (capacity == 0) {
        return;
    }
    if (source != MQ_NULL) {
        while (index + 1u < capacity && source[index] != 0) {
            destination[index] = source[index];
            ++index;
        }
    }
    destination[index] = 0;
}

/* Initialize WinSock once for UDP networking. */
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

/* Format address for MiniLang. */
static void mq_udp_format_address(char *destination, mq_u32 address) {
    const mq_u8 *octets = (const mq_u8 *)&address;
    sprintf(
        destination,
        "%u.%u.%u.%u",
        (unsigned int)octets[0],
        (unsigned int)octets[1],
        (unsigned int)octets[2],
        (unsigned int)octets[3]
    );
}

/* Cache the most recently observed UDP peer address. */
static void mq_udp_remember_address(const MQ_SOCKADDR_IN *address) {
    mq_udp_format_address(mq_udp_last_address_text, address->sin_addr);
    mq_udp_last_port_value = (mq_u32)ntohs(address->sin_port);
}

/* Clear the selected buffers or pending native state. */
static void mq_clear_input_events(void) {
    mq_u32 i;
    mq_mouse_delta_x = 0;
    mq_mouse_delta_y = 0;
    mq_mouse_ready = 0;
    mq_text_head = 0;
    mq_text_tail = 0;
    mq_input_head = 0;
    mq_input_tail = 0;
    for (i = 0; i < 256u; ++i) {
        mq_key_pressed[i] = 0;
        mq_virtual_key_down[i] = 0;
        mq_virtual_key_scan[i] = 0;
    }
    for (i = 0; i < 3u; ++i) {
        mq_mouse_button_down[i] = 0;
    }
}

/* Submit text to the native queue. */
static void mq_push_text(mq_u16 character) {
    mq_u32 next = (mq_text_head + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    if (next == mq_text_tail) {
        mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    }
    mq_text_queue[mq_text_head] = character;
    mq_text_head = next;
}

/* Build a Win32 display-mode request from video settings. */
static void mq_prepare_display_mode(
    MQ_DEVMODEW *mode,
    mq_i32 width,
    mq_i32 height,
    mq_i32 bpp,
    mq_i32 frequency
) {
    memset(mode, 0, sizeof(*mode));
    mode->dmSize = (WORD)sizeof(*mode);
    mode->dmFields = MQ_DM_PELSWIDTH | MQ_DM_PELSHEIGHT;
    mode->dmPelsWidth = (DWORD)width;
    mode->dmPelsHeight = (DWORD)height;
    if (bpp > 0) {
        mode->dmFields |= MQ_DM_BITSPERPEL;
        mode->dmBitsPerPel = (DWORD)bpp;
    }
    if (frequency > 0) {
        mode->dmFields |= MQ_DM_DISPLAYFREQUENCY;
        mode->dmDisplayFrequency = (DWORD)frequency;
    }
}

/* Apply requested display mode to the active backend state. */
static mq_i32 mq_apply_requested_display_mode(void) {
    if (!mq_display_fullscreen || mq_display_use_current) {
        return 1;
    }
    if (ChangeDisplaySettingsW(&mq_requested_display_mode, MQ_CDS_FULLSCREEN) != MQ_DISP_CHANGE_SUCCESSFUL) {
        return 0;
    }
    mq_display_changed = 1;
    mq_display_suspended = 0;
    return 1;
}

/* Restore requested display mode to its default state. */
static void mq_restore_requested_display_mode(void) {
    if (mq_display_changed || mq_display_suspended) {
        ChangeDisplaySettingsW(MQ_NULL, 0);
    }
    mq_display_changed = 0;
    mq_display_suspended = 0;
}

/* Resolve a procedure from the dynamically loaded backend module. */
static LRESULT MQ_WINAPI mq_window_proc(HWND window, UINT message, WPARAM w_param, LPARAM l_param) {
    if (message == MQ_WM_INPUT && mq_raw_mouse_registered &&
        mq_cursor_captured && mq_active_app) {
        MQ_RAWINPUT input;
        UINT input_size = (UINT)sizeof(input);
        if (GetRawInputData((HANDLE)l_param, MQ_RID_INPUT, &input,
                &input_size, (UINT)sizeof(MQ_RAWINPUTHEADER)) == input_size &&
            input.header.type == MQ_RIM_TYPEMOUSE) {
            mq_mouse_delta_x += input.mouse.last_x;
            mq_mouse_delta_y += input.mouse.last_y;
            mq_mouse_ready = 1;
        }
        return 0;
    }
    if (message == MQ_WM_MOVE) {
        mq_window_x_value = (mq_i16)(l_param & 0xFFFF);
        mq_window_y_value = (mq_i16)((l_param >> 16) & 0xFFFF);
        if (mq_cursor_captured) {
            mq_mouse_ready = 0;
            mq_update_clip_cursor();
        }
    }
    if (message == MQ_WM_SIZE) {
        mq_minimized = ((mq_u32)w_param == MQ_SIZE_MINIMIZED);
        if (!mq_minimized && mq_cursor_captured) {
            mq_mouse_ready = 0;
            mq_update_clip_cursor();
        }
    }
    if ((message == MQ_WM_KEYDOWN || message == MQ_WM_SYSKEYDOWN) && w_param < 256u) {
        mq_u32 scan_code = ((mq_u32)l_param >> 16) & 0xFFu;
        mq_key_pressed[(mq_u32)w_param] = 1;
        mq_virtual_key_down[(mq_u32)w_param] = 1;
        mq_virtual_key_scan[(mq_u32)w_param] = (mq_u8)scan_code;
        mq_push_input_event(MQ_INPUT_EVENT_SCAN_KEY, scan_code, 1);
    }
    if ((message == MQ_WM_KEYUP || message == MQ_WM_SYSKEYUP) && w_param < 256u) {
        mq_u32 scan_code = ((mq_u32)l_param >> 16) & 0xFFu;
        mq_virtual_key_down[(mq_u32)w_param] = 0;
        mq_virtual_key_scan[(mq_u32)w_param] = 0;
        mq_push_input_event(MQ_INPUT_EVENT_SCAN_KEY, scan_code, 0);
    }
    if (message == MQ_WM_SYSCHAR) {
        /* Match gl_vidnt.c: suppress the Alt+Space system menu. */
        return 0;
    }
    if (message == MQ_WM_LBUTTONDOWN || message == MQ_WM_RBUTTONDOWN || message == MQ_WM_MBUTTONDOWN) {
        mq_u32 button = message == MQ_WM_LBUTTONDOWN ? 0u : (message == MQ_WM_RBUTTONDOWN ? 1u : 2u);
        mq_mouse_button_down[button] = 1;
        mq_push_input_event(MQ_INPUT_EVENT_MOUSE, button, 1);
    }
    if (message == MQ_WM_LBUTTONUP || message == MQ_WM_RBUTTONUP || message == MQ_WM_MBUTTONUP) {
        mq_u32 button = message == MQ_WM_LBUTTONUP ? 0u : (message == MQ_WM_RBUTTONUP ? 1u : 2u);
        mq_mouse_button_down[button] = 0;
        mq_push_input_event(MQ_INPUT_EVENT_MOUSE, button, 0);
    }
    if (message == MQ_WM_CHAR) {
        mq_u16 character = (mq_u16)(w_param & 0xFFFFu);
        if (character != 0) {
            mq_push_text(character);
        }
        return 0;
    }
    if (message == MQ_WM_CLOSE) {
        if (MessageBoxW(
                window, mq_quit_text, mq_quit_caption,
                MQ_MB_YESNO | MQ_MB_SETFOREGROUND | MQ_MB_ICONQUESTION
            ) == MQ_IDYES) {
            mq_running = 0;
            DestroyWindow(window);
        }
        return 0;
    }
    if (message == MQ_WM_DESTROY) {
        if (!mq_programmatic_window_destroy) {
            mq_running = 0;
            PostQuitMessage(0);
        }
        return 0;
    }
    if (message == MQ_WM_MOUSEWHEEL) {
        mq_i32 delta = (mq_i32)((w_param >> 16) & 0xFFFFu);
        if (delta & 0x8000) {
            delta -= 0x10000;
        }
        mq_mouse_wheel_delta += delta / 120;
        while (delta >= 120) {
            mq_push_input_event(MQ_INPUT_EVENT_WHEEL, 0, 1);
            delta -= 120;
        }
        while (delta <= -120) {
            mq_push_input_event(MQ_INPUT_EVENT_WHEEL, 0, -1);
            delta += 120;
        }
        return 0;
    }
    if (message == MQ_WM_ACTIVATEAPP) {
        mq_active_app = w_param != 0;
        mq_minimized = IsIconic(window) != 0;
        if (w_param == 0) {
            mq_release_all_input_keys();
            mq_push_input_event(MQ_INPUT_EVENT_FOCUS, 0, 0);
            mq_mouse_ready = 0;
            if (mq_display_fullscreen && mq_display_changed) {
                ChangeDisplaySettingsW(MQ_NULL, 0);
                mq_display_changed = 0;
                mq_display_suspended = 1;
                ShowWindow(window, MQ_SW_SHOWMINNOACTIVE);
            }
        } else {
            if (mq_display_fullscreen && mq_display_suspended) {
                mq_apply_requested_display_mode();
                ShowWindow(window, MQ_SW_SHOWNORMAL);
                SetForegroundWindow(window);
            }
            mq_push_input_event(MQ_INPUT_EVENT_FOCUS, 0, 1);
            mq_mouse_ready = 0;
        }
        return 0;
    }
    if (message == MQ_WM_KILLFOCUS && mq_display_fullscreen) {
        ShowWindow(window, MQ_SW_SHOWMINNOACTIVE);
        return 0;
    }
    return DefWindowProcW(window, message, w_param, l_param);
}

/* Convert the scalar between MiniLang and native representations. */
MQ_EXPORT mq_u32 mq_f32_from_text(const char *text) {
    double parsed;
    if (text == MQ_NULL) {
        return 0;
    }
    parsed = strtod(text, (char **)MQ_NULL);
    return mq_float_to_bits((float)parsed);
}

/* Decode MiniLang's raw float representation. */
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

/* Encode a native float in MiniLang's raw representation. */
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

/* Evaluate the requested scalar math operation for MiniLang. */
MQ_EXPORT mq_u32 mq_f32_sin(mq_u32 bits) {
    return mq_float_to_bits((float)sin((double)mq_bits_to_float(bits)));
}

/* Evaluate the requested scalar math operation for MiniLang. */
MQ_EXPORT mq_u32 mq_f32_cos(mq_u32 bits) {
    return mq_float_to_bits((float)cos((double)mq_bits_to_float(bits)));
}

/* Evaluate the requested scalar math operation for MiniLang. */
MQ_EXPORT mq_u32 mq_f32_sqrt(mq_u32 bits) {
    return mq_float_to_bits((float)sqrt((double)mq_bits_to_float(bits)));
}

/* Evaluate the requested scalar math operation for MiniLang. */
MQ_EXPORT mq_u32 mq_f32_atan2(mq_u32 y_bits, mq_u32 x_bits) {
    return mq_float_to_bits((float)atan2((double)mq_bits_to_float(y_bits), (double)mq_bits_to_float(x_bits)));
}

/* Convert the scalar between MiniLang and native representations. */
MQ_EXPORT mq_i32 mq_f32_to_i32_trunc(mq_u32 bits) {
    return (mq_i32)mq_bits_to_float(bits);
}

/* Convert the scalar between MiniLang and native representations. */
MQ_EXPORT mq_u32 mq_i32_to_f32(mq_i32 value) {
    return mq_float_to_bits((float)value);
}

/* Convert or transfer text across the MiniLang native boundary. */
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

/* Return display mode count. */
MQ_EXPORT mq_u32 mq_win_display_mode_count(void) {
    MQ_DEVMODEW mode;
    DWORD index = 0;
    mq_display_mode_count_value = 0;
    while (mq_display_mode_count_value < MQ_DISPLAY_MODE_CAPACITY) {
        memset(&mode, 0, sizeof(mode));
        mode.dmSize = (WORD)sizeof(mode);
        if (!EnumDisplaySettingsW(MQ_NULL, index, &mode)) {
            break;
        }
        if (mode.dmBitsPerPel >= 15u && mode.dmPelsWidth <= 10000u && mode.dmPelsHeight <= 10000u) {
            mq_display_modes[mq_display_mode_count_value++] = mode;
        }
        ++index;
    }
    return mq_display_mode_count_value;
}

/* Return display mode width. */
MQ_EXPORT mq_i32 mq_win_display_mode_width(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmPelsWidth : 0;
}

/* Return display mode height. */
MQ_EXPORT mq_i32 mq_win_display_mode_height(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmPelsHeight : 0;
}

/* Return the current display mode bpp. */
MQ_EXPORT mq_i32 mq_win_display_mode_bpp(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmBitsPerPel : 0;
}

/* Return the current display mode frequency. */
MQ_EXPORT mq_i32 mq_win_display_mode_frequency(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmDisplayFrequency : 0;
}

/* Validate a requested fullscreen display mode with Win32. */
MQ_EXPORT mq_i32 mq_win_test_display_mode(mq_i32 width, mq_i32 height, mq_i32 bpp, mq_i32 frequency) {
    MQ_DEVMODEW mode;
    if (width < 1 || height < 1) {
        return 0;
    }
    mq_prepare_display_mode(&mode, width, height, bpp, frequency);
    return ChangeDisplaySettingsW(&mode, MQ_CDS_TEST | MQ_CDS_FULLSCREEN) == MQ_DISP_CHANGE_SUCCESSFUL;
}

/* Configure display mode from the requested settings. */
MQ_EXPORT mq_i32 mq_win_configure_display_mode(
    mq_i32 width,
    mq_i32 height,
    mq_i32 bpp,
    mq_i32 frequency,
    mq_i32 fullscreen,
    mq_i32 use_current
) {
    MQ_DEVMODEW requested_mode;
    mq_prepare_display_mode(&requested_mode, width, height, bpp, frequency);
    /* Validate first.  Restoring the active mode before a failed test would
     * leave a fullscreen window stranded on the desktop display mode. */
    if (fullscreen && !use_current &&
        ChangeDisplaySettingsW(&requested_mode, MQ_CDS_TEST | MQ_CDS_FULLSCREEN) != MQ_DISP_CHANGE_SUCCESSFUL) {
        return 0;
    }
    mq_restore_requested_display_mode();
    mq_display_fullscreen = fullscreen != 0;
    mq_display_use_current = use_current != 0;
    mq_requested_display_mode = requested_mode;
    return 1;
}

/* Restore display mode to its default state. */
MQ_EXPORT void mq_win_restore_display_mode(void) {
    mq_restore_requested_display_mode();
    mq_display_fullscreen = 0;
    mq_display_use_current = 0;
}

/* Return get gamma ramp. */
MQ_EXPORT mq_i32 mq_win_get_gamma_ramp(mq_u8 *ramp, mq_u32 byte_count) {
    HDC dc;
    BOOL result;
    if (ramp == MQ_NULL || byte_count < 1536u) {
        return 0;
    }
    dc = mq_window_dc != MQ_NULL ? mq_window_dc : GetDC(MQ_NULL);
    if (dc == MQ_NULL) {
        return 0;
    }
    result = GetDeviceGammaRamp(dc, ramp);
    if (mq_window_dc == MQ_NULL) {
        ReleaseDC(MQ_NULL, dc);
    }
    return result != 0;
}

/* Update backend state for gamma ramp. */
MQ_EXPORT mq_i32 mq_win_set_gamma_ramp(const mq_u8 *ramp, mq_u32 byte_count) {
    HDC dc;
    BOOL result;
    if (ramp == MQ_NULL || byte_count < 1536u) {
        return 0;
    }
    dc = mq_window_dc != MQ_NULL ? mq_window_dc : GetDC(MQ_NULL);
    if (dc == MQ_NULL) {
        return 0;
    }
    if (!mq_original_gamma_valid) {
        mq_original_gamma_valid = GetDeviceGammaRamp(dc, mq_original_gamma_ramp) != 0;
    }
    result = SetDeviceGammaRamp(dc, ramp);
    if (mq_window_dc == MQ_NULL) {
        ReleaseDC(MQ_NULL, dc);
    }
    return result != 0;
}

/* Report whether context ready is available. */
MQ_EXPORT mq_i32 mq_win_context_ready(void) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) return mq_d3d9_ready();
    if (mq_render_backend_value == MQ_RENDER_VULKAN) return mq_vulkan_ready();
    return mq_window_dc != MQ_NULL && mq_gl_context != MQ_NULL;
}

/* Make the OpenGL rendering context current on this thread. */
MQ_EXPORT mq_i32 mq_win_make_current(void) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) return mq_d3d9_ready();
    if (mq_render_backend_value == MQ_RENDER_VULKAN) return mq_vulkan_ready();
    return mq_window_dc != MQ_NULL && mq_gl_context != MQ_NULL && wglMakeCurrent(mq_window_dc, mq_gl_context);
}

/* Return the current window x. */
MQ_EXPORT mq_i32 mq_win_window_x(void) { return mq_window_x_value; }
/* Return the current window y. */
MQ_EXPORT mq_i32 mq_win_window_y(void) { return mq_window_y_value; }
/* Report whether the game window is currently minimized. */
MQ_EXPORT mq_i32 mq_win_is_minimized(void) { return mq_minimized; }
/* Return desktop width. */
MQ_EXPORT mq_i32 mq_win_desktop_width(void) { return GetSystemMetrics(MQ_SM_CXSCREEN); }
/* Return desktop height. */
MQ_EXPORT mq_i32 mq_win_desktop_height(void) { return GetSystemMetrics(MQ_SM_CYSCREEN); }

/* Apply focus-dependent input and display state. */
MQ_EXPORT void mq_win_activate(mq_i32 active, mq_i32 minimized) {
    mq_active_app = active != 0;
    mq_minimized = minimized != 0;
    if (!mq_active_app && mq_display_fullscreen && mq_display_changed) {
        ChangeDisplaySettingsW(MQ_NULL, 0);
        mq_display_changed = 0;
        mq_display_suspended = 1;
    } else if (mq_active_app && mq_display_fullscreen && mq_display_suspended) {
        mq_apply_requested_display_mode();
        if (mq_window != MQ_NULL) {
            ShowWindow(mq_window, MQ_SW_SHOWNORMAL);
            SetForegroundWindow(mq_window);
        }
    }
}

/* Create and initialize create. */
MQ_EXPORT mq_ptr mq_win_create(const unsigned short *title, mq_i32 width, mq_i32 height, mq_i32 fullscreen) {
    MQ_WNDCLASSEXW window_class;
    MQ_PIXELFORMATDESCRIPTOR pixel_format;
    MQ_RECT rectangle;
    HICON large_icon;
    HICON small_icon;
    DWORD style;
    DWORD ex_style;
    mq_i32 window_x;
    mq_i32 window_y;
    mq_i32 window_width;
    mq_i32 window_height;
    mq_i32 chosen_format;
    MQ_RAWINPUTDEVICE raw_mouse;

    if (mq_window != MQ_NULL) {
        return mq_window;
    }
    if (width < 1 || height < 1) {
        return MQ_NULL;
    }
    if (fullscreen && !mq_apply_requested_display_mode()) {
        return MQ_NULL;
    }

    mq_instance = GetModuleHandleW(MQ_NULL);
    if (mq_instance == MQ_NULL) {
        mq_restore_requested_display_mode();
        return MQ_NULL;
    }

    if (!mq_class_registered) {
        /* Load both Windows icon roles from the executable's multi-resolution
         * icon group. The generic application icon remains a safe fallback for
         * diagnostic builds produced with build.ps1 -SkipIcon. */
        large_icon = (HICON)LoadImageW(
            mq_instance,
            MQ_IDI_MINIQUAKE,
            MQ_IMAGE_ICON,
            GetSystemMetrics(MQ_SM_CXICON),
            GetSystemMetrics(MQ_SM_CYICON),
            MQ_LR_SHARED);
        if (large_icon == MQ_NULL) {
            large_icon = LoadIconW(MQ_NULL, MQ_IDI_APPLICATION);
        }
        small_icon = (HICON)LoadImageW(
            mq_instance,
            MQ_IDI_MINIQUAKE,
            MQ_IMAGE_ICON,
            GetSystemMetrics(MQ_SM_CXSMICON),
            GetSystemMetrics(MQ_SM_CYSMICON),
            MQ_LR_SHARED);
        if (small_icon == MQ_NULL) {
            small_icon = large_icon;
        }

        window_class.cbSize = (UINT)sizeof(window_class);
        window_class.style = MQ_CS_OWNDC | MQ_CS_HREDRAW | MQ_CS_VREDRAW;
        window_class.lpfnWndProc = mq_window_proc;
        window_class.cbClsExtra = 0;
        window_class.cbWndExtra = 0;
        window_class.hInstance = mq_instance;
        window_class.hIcon = large_icon;
        window_class.hCursor = LoadCursorW(MQ_NULL, MQ_IDC_ARROW);
        window_class.hbrBackground = MQ_NULL;
        window_class.lpszMenuName = MQ_NULL;
        window_class.lpszClassName = mq_window_class_name;
        window_class.hIconSm = small_icon;
        if (RegisterClassExW(&window_class) == 0) {
            mq_restore_requested_display_mode();
            return MQ_NULL;
        }
        mq_class_registered = 1;
    }

    ex_style = MQ_WS_EX_APPWINDOW;
    if (fullscreen) {
        style = MQ_WS_POPUP | MQ_WS_VISIBLE;
        window_x = 0;
        window_y = 0;
        /* The display mode may be a dual-head physical width while GLQuake's
         * logical window is half that width (vmode_t.halfscreen). */
        window_width = width;
        window_height = height;
    } else {
        style = MQ_WS_OVERLAPPEDWINDOW | MQ_WS_VISIBLE;
        rectangle.left = 0;
        rectangle.top = 0;
        rectangle.right = width;
        rectangle.bottom = height;
        AdjustWindowRectEx(&rectangle, style, MQ_FALSE, ex_style);
        window_width = rectangle.right - rectangle.left;
        window_height = rectangle.bottom - rectangle.top;
        window_x = (GetSystemMetrics(MQ_SM_CXSCREEN) - width) / 2;
        window_y = (GetSystemMetrics(MQ_SM_CYSCREEN) - height) / 2;
        if (window_x > window_y * 2) {
            window_x >>= 1;
        }
        if (window_x < 0) window_x = 0;
        if (window_y < 0) window_y = 0;
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
        mq_restore_requested_display_mode();
        return MQ_NULL;
    }

    /* Raw Input reports high-resolution relative motion without quantizing it
     * through the desktop cursor or synthesizing a mouse move for every
     * recenter. Keep the established cursor path as a fallback for old or
     * restricted Windows sessions where registration is unavailable. */
    raw_mouse.usage_page = MQ_HID_USAGE_PAGE_GENERIC;
    raw_mouse.usage = MQ_HID_USAGE_GENERIC_MOUSE;
    raw_mouse.flags = 0u;
    raw_mouse.target = mq_window;
    mq_raw_mouse_registered = RegisterRawInputDevices(
        &raw_mouse, 1u, (UINT)sizeof(raw_mouse)) != 0;

    mq_window_dc = GetDC(mq_window);
    if (mq_window_dc == MQ_NULL) {
        mq_win_destroy();
        return MQ_NULL;
    }

    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (!mq_d3d9_initialize(mq_window, width, height)) {
            mq_win_destroy();
            return MQ_NULL;
        }
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (!mq_vulkan_initialize(mq_window, width, height)) {
            mq_win_destroy();
            return MQ_NULL;
        }
    } else {
    pixel_format.nSize = (WORD)sizeof(pixel_format);
    pixel_format.nVersion = 1;
    pixel_format.dwFlags = MQ_PFD_DRAW_TO_WINDOW | MQ_PFD_SUPPORT_OPENGL | MQ_PFD_DOUBLEBUFFER;
    pixel_format.iPixelType = MQ_PFD_TYPE_RGBA;
    pixel_format.cColorBits = 24;
    pixel_format.cRedBits = 0;
    pixel_format.cRedShift = 0;
    pixel_format.cGreenBits = 0;
    pixel_format.cGreenShift = 0;
    pixel_format.cBlueBits = 0;
    pixel_format.cBlueShift = 0;
    pixel_format.cAlphaBits = 0;
    pixel_format.cAlphaShift = 0;
    pixel_format.cAccumBits = 0;
    pixel_format.cAccumRedBits = 0;
    pixel_format.cAccumGreenBits = 0;
    pixel_format.cAccumBlueBits = 0;
    pixel_format.cAccumAlphaBits = 0;
    pixel_format.cDepthBits = 32;
    pixel_format.cStencilBits = 0;
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
    mq_gl_world_program = 0u;
    mq_gl_world_program_attempted = 0;
    mq_gl_alias_program = 0u;
    mq_gl_alias_program_attempted = 0;
    mq_gl_alias_state_location = -1;
    mq_gl_alias_program_active = 0;
    mq_gl_md2_shadow_program = 0u;
    mq_gl_md2_shadow_program_attempted = 0;
    mq_gl_md2_shadow_state_location = -1;
    mq_gl_enhanced_program = 0u;
    mq_gl_enhanced_program_attempted = 0;
    mq_gl_enhanced_enabled = 0;
    mq_gl_enhanced_draw_kind_value = 0;

    mq_gl_active_texture_value = (mq_gl_active_texture_proc)wglGetProcAddress("glActiveTexture");
    if (!mq_valid_wgl_proc((const void *)mq_gl_active_texture_value)) {
        mq_gl_active_texture_value = (mq_gl_active_texture_proc)wglGetProcAddress("glActiveTextureARB");
    }
    mq_gl_client_active_texture_value = (mq_gl_client_active_texture_proc)wglGetProcAddress("glClientActiveTexture");
    if (!mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
        mq_gl_client_active_texture_value = (mq_gl_client_active_texture_proc)wglGetProcAddress("glClientActiveTextureARB");
    }
    mq_gl_multi_tex_coord2f_value = (mq_gl_multi_tex_coord2f_proc)wglGetProcAddress("glMultiTexCoord2f");
    if (!mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value)) {
        mq_gl_multi_tex_coord2f_value = (mq_gl_multi_tex_coord2f_proc)wglGetProcAddress("glMultiTexCoord2fARB");
    }
    mq_gl_create_shader_value = (mq_gl_create_shader_proc)wglGetProcAddress("glCreateShader");
    mq_gl_shader_source_value = (mq_gl_shader_source_proc)wglGetProcAddress("glShaderSource");
    mq_gl_compile_shader_value = (mq_gl_compile_shader_proc)wglGetProcAddress("glCompileShader");
    mq_gl_get_shader_iv_value = (mq_gl_get_shader_iv_proc)wglGetProcAddress("glGetShaderiv");
    mq_gl_delete_shader_value = (mq_gl_delete_shader_proc)wglGetProcAddress("glDeleteShader");
    mq_gl_create_program_value = (mq_gl_create_program_proc)wglGetProcAddress("glCreateProgram");
    mq_gl_attach_shader_value = (mq_gl_attach_shader_proc)wglGetProcAddress("glAttachShader");
    mq_gl_link_program_value = (mq_gl_link_program_proc)wglGetProcAddress("glLinkProgram");
    mq_gl_get_program_iv_value = (mq_gl_get_program_iv_proc)wglGetProcAddress("glGetProgramiv");
    mq_gl_use_program_value = (mq_gl_use_program_proc)wglGetProcAddress("glUseProgram");
    mq_gl_delete_program_value = (mq_gl_delete_program_proc)wglGetProcAddress("glDeleteProgram");
    mq_gl_get_uniform_location_value = (mq_gl_get_uniform_location_proc)wglGetProcAddress("glGetUniformLocation");
    mq_gl_get_attrib_location_value = (mq_gl_get_attrib_location_proc)wglGetProcAddress("glGetAttribLocation");
    mq_gl_vertex_attrib_4f_value = (mq_gl_vertex_attrib_4f_proc)wglGetProcAddress("glVertexAttrib4f");
    mq_gl_uniform_1i_value = (mq_gl_uniform_1i_proc)wglGetProcAddress("glUniform1i");
    mq_gl_uniform_4fv_value = (mq_gl_uniform_4fv_proc)wglGetProcAddress("glUniform4fv");
    mq_gl_gen_buffers_value = (mq_gl_gen_buffers_proc)wglGetProcAddress("glGenBuffers");
    mq_gl_bind_buffer_value = (mq_gl_bind_buffer_proc)wglGetProcAddress("glBindBuffer");
    mq_gl_buffer_data_value = (mq_gl_buffer_data_proc)wglGetProcAddress("glBufferData");
    mq_gl_delete_buffers_value = (mq_gl_delete_buffers_proc)wglGetProcAddress("glDeleteBuffers");
    mq_gl_create_world_program();
    mq_gl_create_alias_program();
    mq_gl_create_md2_shadow_program();
    mq_gl_create_enhanced_program();

    /* GLQuake predates driver-controlled swap synchronization and never
     * requests it.  Explicitly select interval zero when WGL_EXT_swap_control
     * is available, otherwise modern driver defaults can add a full refresh
     * period after an already complete frame and cap the port below 60 FPS. */
    {
        mq_wgl_swap_interval_proc swap_interval =
            (mq_wgl_swap_interval_proc)wglGetProcAddress("wglSwapIntervalEXT");
        if (swap_interval != MQ_NULL &&
            swap_interval != (mq_wgl_swap_interval_proc)1 &&
            swap_interval != (mq_wgl_swap_interval_proc)2 &&
            swap_interval != (mq_wgl_swap_interval_proc)3 &&
            swap_interval != (mq_wgl_swap_interval_proc)-1) {
            swap_interval(0);
        }
    }
    }

    ShowWindow(mq_window, MQ_SW_SHOW);
    UpdateWindow(mq_window);
    /* Pay the one-time DWM/ICD present cost while the window is still in its
     * startup phase, not on the first playable map frame. */
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        mq_d3d9_clear_color(0u, 0u, 0u, 0x3f800000u);
        mq_d3d9_clear(0x00004000u | 0x00000100u);
        mq_d3d9_present();
        mq_d3d9_clear(0x00004000u | 0x00000100u);
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_vulkan_clear_color(0u, 0u, 0u, 0x3f800000u);
        mq_vulkan_clear(0x00004000u | 0x00000100u);
        mq_vulkan_present();
        mq_vulkan_clear(0x00004000u | 0x00000100u);
    } else {
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(0x00004000u | 0x00000100u); /* GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT */
    SwapBuffers(mq_window_dc);
    glClear(0x00004000u | 0x00000100u);
    /* Some ICDs apply their default interval on the first present.  Assert the
     * GLQuake interval again after that present so gameplay is not recapped. */
    {
        mq_wgl_swap_interval_proc swap_interval =
            (mq_wgl_swap_interval_proc)wglGetProcAddress("wglSwapIntervalEXT");
        if (swap_interval != MQ_NULL &&
            swap_interval != (mq_wgl_swap_interval_proc)1 &&
            swap_interval != (mq_wgl_swap_interval_proc)2 &&
            swap_interval != (mq_wgl_swap_interval_proc)3 &&
            swap_interval != (mq_wgl_swap_interval_proc)-1) {
            swap_interval(0);
        }
    }
    }
    mq_clear_input_events();
    mq_running = 1;
    mq_active_app = 1;
    mq_minimized = 0;
    mq_window_style_fullscreen = fullscreen != 0;
    return mq_window;
}

/* Release resources owned by destroy. */
MQ_EXPORT void mq_win_destroy(void) {
    HDC gamma_dc;
    mq_win_set_cursor_capture(0);
    if (mq_original_gamma_valid) {
        gamma_dc = mq_window_dc != MQ_NULL ? mq_window_dc : GetDC(MQ_NULL);
        if (gamma_dc != MQ_NULL) {
            SetDeviceGammaRamp(gamma_dc, mq_original_gamma_ramp);
            if (mq_window_dc == MQ_NULL) {
                ReleaseDC(MQ_NULL, gamma_dc);
            }
        }
        mq_original_gamma_valid = 0;
    }
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        mq_d3d9_shutdown();
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_vulkan_shutdown();
    }
    if (mq_gl_context != MQ_NULL) {
        if (mq_gl_world_program != 0u && mq_valid_wgl_proc((const void *)mq_gl_delete_program_value)) {
            mq_gl_delete_program_value(mq_gl_world_program);
            mq_gl_world_program = 0u;
        }
        mq_gl_world_program_attempted = 0;
        if (mq_gl_alias_program != 0u && mq_valid_wgl_proc((const void *)mq_gl_delete_program_value)) {
            mq_gl_delete_program_value(mq_gl_alias_program);
            mq_gl_alias_program = 0u;
        }
        mq_gl_alias_program_attempted = 0;
        mq_gl_alias_state_location = -1;
        mq_gl_alias_program_active = 0;
        if (mq_gl_md2_shadow_program != 0u &&
            mq_valid_wgl_proc((const void *)mq_gl_delete_program_value)) {
            mq_gl_delete_program_value(mq_gl_md2_shadow_program);
            mq_gl_md2_shadow_program = 0u;
        }
        mq_gl_md2_shadow_program_attempted = 0;
        mq_gl_md2_shadow_state_location = -1;
        if (mq_gl_enhanced_program != 0u && mq_valid_wgl_proc((const void *)mq_gl_delete_program_value)) {
            mq_gl_delete_program_value(mq_gl_enhanced_program);
            mq_gl_enhanced_program = 0u;
        }
        mq_gl_enhanced_program_attempted = 0;
        mq_gl_enhanced_enabled = 0;
        mq_gl_enhanced_draw_kind_value = 0;
        wglMakeCurrent(MQ_NULL, MQ_NULL);
        wglDeleteContext(mq_gl_context);
        mq_gl_context = MQ_NULL;
    }
    if (mq_window_dc != MQ_NULL && mq_window != MQ_NULL) {
        ReleaseDC(mq_window, mq_window_dc);
        mq_window_dc = MQ_NULL;
    }
    if (mq_window != MQ_NULL) {
        mq_programmatic_window_destroy = 1;
        DestroyWindow(mq_window);
        mq_programmatic_window_destroy = 0;
        mq_window = MQ_NULL;
    }
    mq_restore_requested_display_mode();
    mq_display_fullscreen = 0;
    mq_window_style_fullscreen = 0;
    mq_display_use_current = 0;
    mq_running = 0;
    mq_active_app = 0;
    mq_minimized = 0;
    mq_raw_mouse_registered = 0;
}

/* Poll the native queue without blocking the game loop. */
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

    if (!mq_raw_mouse_registered && mq_running && mq_cursor_captured &&
        mq_window != MQ_NULL && GetForegroundWindow() == mq_window) {
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
    } else if (!mq_raw_mouse_registered) {
        mq_mouse_ready = 0;
    }
    return mq_running;
}

/* Present the OpenGL back buffer to the game window. */
MQ_EXPORT void mq_win_swap(void) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        mq_d3d9_present();
        return;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_vulkan_present();
        return;
    }
    if (mq_window_dc != MQ_NULL) {
        SwapBuffers(mq_window_dc);
    }
}

/* Select presentation synchronization for the current OpenGL context. */
MQ_EXPORT mq_i32 mq_win_set_swap_interval(mq_i32 interval) {
    mq_wgl_swap_interval_proc swap_interval;
    if (mq_render_backend_value != MQ_RENDER_OPENGL ||
        mq_gl_context == MQ_NULL || interval < 0 || interval > 1) return 0;
    swap_interval = (mq_wgl_swap_interval_proc)
        wglGetProcAddress("wglSwapIntervalEXT");
    if (swap_interval == MQ_NULL ||
        swap_interval == (mq_wgl_swap_interval_proc)1 ||
        swap_interval == (mq_wgl_swap_interval_proc)2 ||
        swap_interval == (mq_wgl_swap_interval_proc)3 ||
        swap_interval == (mq_wgl_swap_interval_proc)-1) return 0;
    return swap_interval(interval) ? 1 : 0;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_key_down(mq_i32 virtual_key) {
    return (GetAsyncKeyState(virtual_key) & 0x8000) != 0;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_key_pressed(mq_i32 virtual_key) {
    mq_i32 result;
    if (virtual_key < 0 || virtual_key >= 256) {
        return 0;
    }
    result = mq_key_pressed[(mq_u32)virtual_key] != 0;
    mq_key_pressed[(mq_u32)virtual_key] = 0;
    return result;
}

/* Capture all Win32 key levels and pending press edges in one bridge call.
 *
 * The ordered window-message table remains the source for press edges, while
 * every requested binding samples the physical high bit authoritatively.  A
 * previous optimization only sampled keys after observing a message-level
 * down edge.  A delayed or discarded edge during synchronous level loading
 * could therefore make arrows, Alt and Space invisible for the whole hold.
 * Keeping all requested GetAsyncKeyState calls inside this one ABI crossing
 * retains the allocation and call-overhead improvement of the bulk snapshot. */
MQ_EXPORT mq_i32 mq_win_key_snapshot(
    mq_u8 *down_states,
    mq_u8 *pressed_states,
    const mq_u8 *query_mask,
    mq_u32 state_count
) {
    mq_u32 index;
    if (down_states == MQ_NULL || pressed_states == MQ_NULL || query_mask == MQ_NULL) return 0;
    if (state_count > 256u) state_count = 256u;
    for (index = 0u; index < state_count; ++index) {
        if (query_mask[index] == 0u) {
            down_states[index] = 0u;
        } else if (mq_window != MQ_NULL) {
            /* Do not sample global keyboard state unless this window actually
             * owns focus; WM_ACTIVATEAPP can lag a foreground switch by one
             * message-pump pass. */
            if (!mq_active_app || GetForegroundWindow() != mq_window) {
                down_states[index] = 0u;
            } else {
                down_states[index] =
                    (GetAsyncKeyState((mq_i32)index) & 0x8000) != 0 ? 1u : 0u;
            }
        } else {
            /* Headless bridge tests have no physical target window and use
             * the same synthetic level table the message path maintains. */
            down_states[index] = mq_virtual_key_down[index] != 0 ? 1u : 0u;
        }
        pressed_states[index] = mq_key_pressed[index] != 0 ? 1u : 0u;
        mq_key_pressed[index] = 0;
    }
    return (mq_i32)state_count;
}

/* Convert or transfer text across the MiniLang native boundary. */
MQ_EXPORT mq_i32 mq_win_text_pop(void) {
    mq_u16 character;
    if (mq_text_tail == mq_text_head) {
        return -1;
    }
    character = mq_text_queue[mq_text_tail];
    mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    return (mq_i32)character;
}

/* Report whether the game window owns keyboard focus. */
MQ_EXPORT mq_i32 mq_win_has_focus(void) {
    return mq_window != MQ_NULL && GetForegroundWindow() == mq_window;
}

/* Return client width. */
MQ_EXPORT mq_i32 mq_win_client_width(void) {
    MQ_RECT rectangle;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    return rectangle.right - rectangle.left;
}

/* Return client height. */
MQ_EXPORT mq_i32 mq_win_client_height(void) {
    MQ_RECT rectangle;
    if (mq_window == MQ_NULL || !GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    return rectangle.bottom - rectangle.top;
}

/* Resize or restyle the existing window without replacing its HDC/WGL
 * context.  Runtime video changes therefore preserve every uploaded Quake
 * texture, display list and VBO while switching between windowed and
 * fullscreen presentation. */
MQ_EXPORT mq_i32 mq_win_resize_client(mq_i32 width, mq_i32 height) {
    MQ_RECT rectangle;
    DWORD style;
    DWORD ex_style = MQ_WS_EX_APPWINDOW;
    mq_i32 outer_width;
    mq_i32 outer_height;
    mq_i32 window_x = 0;
    mq_i32 window_y = 0;
    mq_i32 style_changed;
    UINT flags = MQ_SWP_NOZORDER | MQ_SWP_NOACTIVATE | MQ_SWP_FRAMECHANGED;
    if (mq_window == MQ_NULL || width < 320 || height < 200) {
        return 0;
    }
    style_changed = mq_window_style_fullscreen != mq_display_fullscreen;
    if (mq_display_fullscreen) {
        style = MQ_WS_POPUP | MQ_WS_VISIBLE;
        if (style_changed) {
            SetWindowLongPtrW(mq_window, MQ_GWL_STYLE, (LONG_PTR)style);
        }
        if (!mq_apply_requested_display_mode()) {
            return 0;
        }
        outer_width = width;
        outer_height = height;
        if (!SetWindowPos(mq_window, MQ_NULL, 0, 0, outer_width, outer_height, flags)) {
            return 0;
        }
    } else {
        style = MQ_WS_OVERLAPPEDWINDOW | MQ_WS_VISIBLE;
        if (style_changed) {
            SetWindowLongPtrW(mq_window, MQ_GWL_STYLE, (LONG_PTR)style);
        }
        rectangle.left = 0;
        rectangle.top = 0;
        rectangle.right = width;
        rectangle.bottom = height;
        if (!AdjustWindowRectEx(&rectangle, style, MQ_FALSE, ex_style)) {
            return 0;
        }
        outer_width = rectangle.right - rectangle.left;
        outer_height = rectangle.bottom - rectangle.top;
        if (style_changed) {
            window_x = (GetSystemMetrics(MQ_SM_CXSCREEN) - outer_width) / 2;
            window_y = (GetSystemMetrics(MQ_SM_CYSCREEN) - outer_height) / 2;
            if (window_x < 0) window_x = 0;
            if (window_y < 0) window_y = 0;
        } else {
            flags |= MQ_SWP_NOMOVE;
        }
        ShowWindow(mq_window, MQ_SW_SHOWNORMAL);
        if (!SetWindowPos(
                mq_window, MQ_NULL, window_x, window_y, outer_width, outer_height,
                flags)) {
            return 0;
        }
    }
    mq_window_style_fullscreen = mq_display_fullscreen;
    mq_minimized = 0;
    mq_mouse_ready = 0;
    if (mq_cursor_captured) {
        mq_update_clip_cursor();
    }
    if (!GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    if (rectangle.right - rectangle.left != width || rectangle.bottom - rectangle.top != height) return 0;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9 && !mq_d3d9_resize(width, height)) return 0;
    if (mq_render_backend_value == MQ_RENDER_VULKAN && !mq_vulkan_resize(width, height)) return 0;
    return 1;
}

/* Update backend state for title. */
MQ_EXPORT void mq_win_set_title(const unsigned short *title) {
    if (mq_window != MQ_NULL && title != MQ_NULL) {
        SetWindowTextW(mq_window, title);
    }
}

/* Update backend state for cursor capture. */
MQ_EXPORT void mq_win_set_cursor_capture(mq_i32 enabled) {
    if (enabled && !mq_cursor_captured) {
        while (ShowCursor(MQ_FALSE) >= 0) { }
        SetCapture(mq_window);
        mq_cursor_captured = 1;
        mq_mouse_ready = 0;
        mq_mouse_delta_x = 0;
        mq_mouse_delta_y = 0;
        mq_center_mouse_cursor();
        mq_update_clip_cursor();
    } else if (!enabled && mq_cursor_captured) {
        while (ShowCursor(MQ_TRUE) < 0) { }
        ClipCursor(MQ_NULL);
        ReleaseCapture();
        mq_cursor_captured = 0;
        mq_mouse_ready = 0;
        mq_mouse_delta_x = 0;
        mq_mouse_delta_y = 0;
    }
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_mouse_dx(void) {
    mq_i32 value = mq_mouse_delta_x;
    mq_mouse_delta_x = 0;
    return value;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_mouse_dy(void) {
    mq_i32 value = mq_mouse_delta_y;
    mq_mouse_delta_y = 0;
    return value;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_mouse_buttons(void) {
    mq_i32 buttons = 0;
    if (GetAsyncKeyState(MQ_VK_LBUTTON) & 0x8000) buttons |= 1;
    if (GetAsyncKeyState(MQ_VK_RBUTTON) & 0x8000) buttons |= 2;
    if (GetAsyncKeyState(MQ_VK_MBUTTON) & 0x8000) buttons |= 4;
    return buttons;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_mouse_wheel(void) {
    mq_i32 value = mq_mouse_wheel_delta;
    mq_mouse_wheel_delta = 0;
    return value;
}

/* Remove the oldest event from the native input queue. */
MQ_EXPORT mq_u32 mq_win_input_event_pop(void) {
    mq_u32 value;
    if (mq_input_tail == mq_input_head) {
        return 0;
    }
    value = mq_input_queue[mq_input_tail];
    mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    return value;
}

/* Inject one event into the input queue for tests. */
MQ_EXPORT void mq_win_input_test_push(mq_u32 type, mq_u32 code, mq_i32 value) {
    if (type == MQ_INPUT_EVENT_KEY && code < 256u) {
        mq_virtual_key_down[code] = value != 0 ? 1u : 0u;
        if (value != 0) mq_key_pressed[code] = 1u;
    }
    mq_push_input_event(type, code, value);
}

/* Show or hide the Win32 cursor with balanced calls. */
MQ_EXPORT void mq_win_cursor_show(mq_i32 show) {
    if (show) {
        while (ShowCursor(MQ_TRUE) < 0) { }
    } else {
        while (ShowCursor(MQ_FALSE) >= 0) { }
    }
}

/* Move the cursor to the center of the client area. */
MQ_EXPORT mq_i32 mq_win_cursor_center(void) {
    return mq_center_mouse_cursor();
}

/* Refresh the mouse confinement rectangle for the active window. */
MQ_EXPORT mq_i32 mq_win_update_clip_cursor(void) {
    if (!mq_cursor_captured) {
        return 0;
    }
    return mq_update_clip_cursor();
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_joy_startup(void) {
    UINT device_count = joyGetNumDevs();
    UINT index;
    MQ_JOYCAPSW caps;
    mq_joy_available = 0;
    mq_joy_button_count_value = 0;
    mq_joy_has_pov_value = 0;
    if (device_count == 0) {
        return 0;
    }
    for (index = 0; index < device_count; ++index) {
        memset(&mq_joy_info, 0, (mq_u64)sizeof(mq_joy_info));
        mq_joy_info.dwSize = (DWORD)sizeof(mq_joy_info);
        mq_joy_info.dwFlags = MQ_JOY_RETURNCENTERED;
        if (joyGetPosEx(index, &mq_joy_info) == MQ_JOYERR_NOERROR) {
            mq_joy_id = index;
            break;
        }
    }
    if (index == device_count) {
        return 0;
    }
    memset(&caps, 0, (mq_u64)sizeof(caps));
    if (joyGetDevCapsW((ULONG_PTR)mq_joy_id, &caps, (UINT)sizeof(caps)) != MQ_JOYERR_NOERROR) {
        return 0;
    }
    mq_joy_button_count_value = caps.wNumButtons;
    if (mq_joy_button_count_value > 32u) {
        mq_joy_button_count_value = 32u;
    }
    mq_joy_has_pov_value = (caps.wCaps & MQ_JOYCAPS_HASPOV) != 0;
    mq_joy_available = 1;
    return 1;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_joy_read(void) {
    if (!mq_joy_available) {
        return 0;
    }
    memset(&mq_joy_info, 0, (mq_u64)sizeof(mq_joy_info));
    mq_joy_info.dwSize = (DWORD)sizeof(mq_joy_info);
    mq_joy_info.dwFlags = MQ_JOY_RETURNALL | MQ_JOY_RETURNCENTERED;
    return joyGetPosEx(mq_joy_id, &mq_joy_info) == MQ_JOYERR_NOERROR;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_u32 mq_win_joy_axis(mq_u32 axis) {
    if (axis == 0u) return mq_joy_info.dwXpos;
    if (axis == 1u) return mq_joy_info.dwYpos;
    if (axis == 2u) return mq_joy_info.dwZpos;
    if (axis == 3u) return mq_joy_info.dwRpos;
    if (axis == 4u) return mq_joy_info.dwUpos;
    if (axis == 5u) return mq_joy_info.dwVpos;
    return 32768u;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_u32 mq_win_joy_buttons(void) { return mq_joy_info.dwButtons; }
/* Read or update the requested native input state. */
MQ_EXPORT mq_u32 mq_win_joy_pov(void) { return mq_joy_info.dwPOV; }
/* Return joy button count. */
MQ_EXPORT mq_u32 mq_win_joy_button_count(void) { return mq_joy_button_count_value; }
/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_joy_has_pov(void) { return mq_joy_has_pov_value; }
/* Read or update the requested native input state. */
MQ_EXPORT mq_i32 mq_win_joy_warrior_curve(mq_i32 raw_value) {
    double magnitude = (double)(raw_value < 0 ? -raw_value : raw_value);
    double curved = 300.0 * pow(magnitude / 800.0, 1.3);
    if (curved > 14000.0) curved = 14000.0;
    return raw_value > 0 ? (mq_i32)curved : -(mq_i32)curved;
}

/* Read or update the requested native input state. */
MQ_EXPORT mq_u32 mq_win_joy_warrior_curve_f32(mq_i32 raw_value) {
    float magnitude = (float)(raw_value < 0 ? -raw_value : raw_value);
    float curved = (float)(300.0 * pow((double)magnitude / 800.0, 1.3));
    if (curved > 14000.0f) curved = 14000.0f;
    if (raw_value <= 0) curved = -curved;
    return mq_float_to_bits(curved);
}

/* Return the monotonic high-resolution timer value. */
MQ_EXPORT mq_u32 mq_win_ticks(void) {
    static mq_i64 frequency = 0;
    mq_i64 counter = 0;
    if (frequency == 0 && !QueryPerformanceFrequency(&frequency)) {
        frequency = -1;
    }
    if (frequency > 0 && QueryPerformanceCounter(&counter)) {
        /* Preserve the public 32-bit millisecond/wrap ABI while matching the
         * high-resolution timer selected by GLQuake's Sys_DoubleTime. */
        return (mq_u32)(((mq_u64)counter * 1000ull) / (mq_u64)frequency);
    }
    return GetTickCount();
}

/* Yield the current thread for the requested duration. */
MQ_EXPORT void mq_win_sleep(mq_u32 milliseconds) {
    Sleep(milliseconds);
}

/* Read the Win32 performance counter. */
MQ_EXPORT mq_u64 mq_sys_counter(void) {
    mq_i64 counter = 0;
    if (!QueryPerformanceCounter(&counter)) return 0;
    return (mq_u64)counter;
}

/* Return the Win32 performance-counter frequency. */
MQ_EXPORT mq_u64 mq_sys_frequency(void) {
    mq_i64 frequency = 0;
    if (!QueryPerformanceFrequency(&frequency)) return 0;
    return (mq_u64)frequency;
}

/* Return mq process handle count. */
MQ_EXPORT mq_u32 mq_process_handle_count(void) {
    DWORD handle_count = 0;
    if (!GetProcessHandleCount(GetCurrentProcess(), &handle_count)) return 0;
    return handle_count;
}

/* Change protection on a generated-code memory range. */
MQ_EXPORT mq_i32 mq_sys_make_code_writeable(mq_u64 address, mq_u64 length) {
    DWORD old_protection = 0;
    if (address == 0 || length == 0) return 0;
    return VirtualProtect((LPVOID)(ULONG_PTR)address, length, 0x04u, &old_protection) != 0;
}

static mq_i32 mq_sys_owns_console = 0;

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_sys_console_alloc(void) {
    HANDLE output;
    if (AllocConsole() != 0) {
        mq_sys_owns_console = 1;
        return 1;
    }
    /* MiniLang executables use the console subsystem and may already have the
       equivalent of WinQuake's freshly allocated dedicated console. */
    output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    return output != MQ_NULL && (ULONG_PTR)output != ~(mq_u64)0;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_sys_console_free(void) {
    if (!mq_sys_owns_console) return 1;
    mq_sys_owns_console = 0;
    return FreeConsole() != 0;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_u32 mq_sys_console_event_pop(void) {
    HANDLE input = GetStdHandle(MQ_STD_INPUT_HANDLE);
    MQ_INPUT_RECORD record;
    DWORD available = 0;
    DWORD read_count = 0;
    mq_u32 result;
    /*
     * A dedicated server normally receives KEY_EVENT records from a console,
     * like the original sys_win.c.  Test harnesses and service wrappers
     * commonly redirect stdin to a pipe, however.  Preserve the same
     * character-at-a-time contract without ever blocking the host frame.
     */
    if (input == MQ_NULL || (ULONG_PTR)input == ~(mq_u64)0) return 0;
    if (GetFileType(input) == MQ_FILE_TYPE_PIPE) {
        mq_u8 character = 0;
        if (!PeekNamedPipe(input, MQ_NULL, 0, MQ_NULL, &available, MQ_NULL) || available == 0) return 0;
        if (!ReadFile(input, &character, 1, &read_count, MQ_NULL) || read_count != 1u) return 0;
        if (character == 10u) character = 13u;
        /* Sys_ConsoleInput intentionally consumes KEY_EVENT key-up records,
           exactly as the original GLQuake sys_win.c does. */
        return 0x80000000u | character;
    }
    if (!GetNumberOfConsoleInputEvents(input, &available) || available == 0) return 0;
    if (!ReadConsoleInputA(input, &record, 1, &read_count) || read_count != 1u) return 0;
    result = 0x80000000u;
    if (record.EventType != MQ_KEY_EVENT) return result;
    if (record.Event.KeyEvent.bKeyDown) result |= 0x00010000u;
    result |= (mq_u8)record.Event.KeyEvent.uChar.AsciiChar;
    return result;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_sys_console_write(const char *text) {
    HANDLE output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    DWORD length = 0;
    DWORD written = 0;
    if (output == MQ_NULL || text == MQ_NULL) return 0;
    while (text[length] != 0) ++length;
    return WriteFile(output, text, length, &written, MQ_NULL) != 0 && written == length;
}

/* Wait until input arrives or the timeout expires. */
MQ_EXPORT void mq_sys_sleep_until_input(mq_u32 milliseconds) {
    MsgWaitForMultipleObjects(0, MQ_NULL, MQ_FALSE, milliseconds, 0x04FFu);
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_u64 mq_conproc_create_event(void) {
    return (mq_u64)(ULONG_PTR)CreateEventW(MQ_NULL, MQ_FALSE, MQ_FALSE, MQ_NULL);
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_set_event(mq_u64 handle) {
    if (handle == 0) return 0;
    return SetEvent((HANDLE)(ULONG_PTR)handle) != 0;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT void mq_conproc_close_handle(mq_u64 handle) {
    if (handle != 0) CloseHandle((HANDLE)(ULONG_PTR)handle);
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_wait_any(mq_u64 first, mq_u64 second, mq_u32 milliseconds) {
    HANDLE handles[2];
    DWORD result;
    handles[0] = (HANDLE)(ULONG_PTR)first;
    handles[1] = (HANDLE)(ULONG_PTR)second;
    result = WaitForMultipleObjects(2, handles, MQ_FALSE, milliseconds);
    if (result == MQ_WAIT_OBJECT_0) return 0;
    if (result == MQ_WAIT_OBJECT_0 + 1u) return 1;
    if (result == MQ_WAIT_TIMEOUT) return 2;
    return -1;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_ptr mq_conproc_map(mq_u64 handle) {
    if (handle == 0) return MQ_NULL;
    return MapViewOfFile((HANDLE)(ULONG_PTR)handle, MQ_FILE_MAP_READ | MQ_FILE_MAP_WRITE, 0, 0, 0);
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_unmap(mq_ptr mapped) {
    return mapped != MQ_NULL && UnmapViewOfFile(mapped) != 0;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_read_i32(mq_ptr mapped, mq_u32 index) {
    const mq_i32 *values = (const mq_i32 *)mapped;
    return values != MQ_NULL ? values[index] : 0;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT void mq_conproc_write_i32(mq_ptr mapped, mq_u32 index, mq_i32 value) {
    mq_i32 *values = (mq_i32 *)mapped;
    if (values != MQ_NULL) values[index] = value;
}

MQ_EXPORT const char *mq_conproc_read_text(mq_ptr mapped, mq_u32 byte_offset) {
    if (mapped == MQ_NULL) return "";
    return (const char *)((const mq_u8 *)mapped + byte_offset);
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_write_text(mq_ptr mapped, mq_u32 byte_offset, const char *text, mq_u32 capacity) {
    char *destination;
    mq_u32 index = 0;
    if (mapped == MQ_NULL || text == MQ_NULL || capacity == 0) return 0;
    destination = (char *)((mq_u8 *)mapped + byte_offset);
    while (index + 1u < capacity && text[index] != 0) {
        destination[index] = text[index];
        ++index;
    }
    destination[index] = 0;
    return 1;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_screen_lines(void) {
    MQ_CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    if (output == MQ_NULL || !GetConsoleScreenBufferInfo(output, &info)) return -1;
    return (mq_i32)info.dwSize.Y;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_set_screen_size(mq_i32 cx, mq_i32 cy) {
    HANDLE output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    MQ_CONSOLE_SCREEN_BUFFER_INFO info;
    MQ_COORD maximum;
    if (output == MQ_NULL || cx < 1 || cy < 1) return 0;
    maximum = GetLargestConsoleWindowSize(output);
    if (cx > maximum.X) cx = maximum.X;
    if (cy > maximum.Y) cy = maximum.Y;
    if (!GetConsoleScreenBufferInfo(output, &info)) return 0;
    info.srWindow.Left = 0;
    info.srWindow.Right = info.dwSize.X - 1;
    info.srWindow.Top = 0;
    info.srWindow.Bottom = (mq_i16)(cy - 1);
    if (cy < info.dwSize.Y) {
        if (!SetConsoleWindowInfo(output, MQ_TRUE, &info.srWindow)) return 0;
        info.dwSize.Y = (mq_i16)cy;
        if (!SetConsoleScreenBufferSize(output, info.dwSize)) return 0;
    } else if (cy > info.dwSize.Y) {
        info.dwSize.Y = (mq_i16)cy;
        if (!SetConsoleScreenBufferSize(output, info.dwSize)) return 0;
        if (!SetConsoleWindowInfo(output, MQ_TRUE, &info.srWindow)) return 0;
    }
    if (!GetConsoleScreenBufferInfo(output, &info)) return 0;
    info.srWindow.Left = 0;
    info.srWindow.Right = (mq_i16)(cx - 1);
    info.srWindow.Top = 0;
    info.srWindow.Bottom = info.dwSize.Y - 1;
    if (cx < info.dwSize.X) {
        if (!SetConsoleWindowInfo(output, MQ_TRUE, &info.srWindow)) return 0;
        info.dwSize.X = (mq_i16)cx;
        if (!SetConsoleScreenBufferSize(output, info.dwSize)) return 0;
    } else if (cx > info.dwSize.X) {
        info.dwSize.X = (mq_i16)cx;
        if (!SetConsoleScreenBufferSize(output, info.dwSize)) return 0;
        if (!SetConsoleWindowInfo(output, MQ_TRUE, &info.srWindow)) return 0;
    }
    return 1;
}

MQ_EXPORT const char *mq_conproc_read_console_text(mq_i32 begin_line, mq_i32 end_line) {
    static char output[65536];
    HANDLE stdout_handle = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    MQ_COORD position;
    DWORD count;
    DWORD read_count = 0;
    if (stdout_handle == MQ_NULL || begin_line < 0 || end_line < begin_line) return "";
    count = (DWORD)(80 * (end_line - begin_line + 1));
    if (count >= (DWORD)sizeof(output)) count = (DWORD)sizeof(output) - 1u;
    position.X = 0;
    position.Y = (mq_i16)begin_line;
    if (!ReadConsoleOutputCharacterA(stdout_handle, output, count, position, &read_count)) {
        output[0] = 0;
        return output;
    }
    output[read_count] = 0;
    return output;
}

/* Bridge the dedicated-console operation to the Win32 host. */
MQ_EXPORT mq_i32 mq_conproc_write_key(mq_i32 character, mq_i32 virtual_key, mq_i32 scan_code, mq_i32 shift, mq_i32 down) {
    HANDLE stdin_handle = GetStdHandle(MQ_STD_INPUT_HANDLE);
    MQ_INPUT_RECORD record;
    DWORD written = 0;
    if (stdin_handle == MQ_NULL) return 0;
    memset(&record, 0, sizeof(record));
    record.EventType = MQ_KEY_EVENT;
    record.Event.KeyEvent.bKeyDown = down != 0;
    record.Event.KeyEvent.wRepeatCount = 1;
    record.Event.KeyEvent.wVirtualKeyCode = (WORD)virtual_key;
    record.Event.KeyEvent.wVirtualScanCode = (WORD)scan_code;
    record.Event.KeyEvent.uChar.AsciiChar = (CHAR)character;
    record.Event.KeyEvent.dwControlKeyState = shift ? 0x80u : 0u;
    return WriteConsoleInputA(stdin_handle, &record, 1, &written) != 0 && written == 1u;
}

/* Recycle audio buffers completed by the output device. */
static void mq_audio_reap_completed(void) {
    mq_u32 i;
    if (mq_wave_output == MQ_NULL) {
        return;
    }
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        MQ_WAVEHDR *header = &mq_audio_headers[i];
        if (mq_audio_header_queued[i] && (header->dwFlags & MQ_WHDR_DONE)) {
            mq_audio_completed_bytes += (mq_u64)header->dwBufferLength;
            ++mq_audio_completed_count;
            mq_audio_header_queued[i] = 0;
            if (mq_audio_buffer_count > 0) {
                --mq_audio_buffer_count;
            }
        }
    }
}

/* Open and validate the requested resource. */
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
        mq_audio_header_queued[i] = 0;
    }
    mq_audio_next_buffer = 0;
    mq_audio_buffer_count = 0;
    mq_audio_bytes_per_sample = bits_per_sample / 8u;
    mq_audio_submitted_count = 0;
    mq_audio_completed_count = 0;
    mq_audio_underrun_count = 0;
    mq_audio_completed_bytes = 0;
    return 1;
}

/* Submit submit to the native queue. */
MQ_EXPORT mq_i32 mq_audio_submit(const void *data, mq_u32 byte_count) {
    MQ_WAVEHDR *header = MQ_NULL;
    mq_u32 attempt;
    mq_u32 selected = 0;
    if (mq_wave_output == MQ_NULL || data == MQ_NULL || byte_count == 0 || byte_count > MQ_AUDIO_BUFFER_BYTES) {
        return 0;
    }

    mq_audio_reap_completed();
    if (mq_audio_submitted_count > 0 && mq_audio_buffer_count == 0) {
        ++mq_audio_underrun_count;
    }

    /* Do not stall merely because the next ring slot is still active. Windows
     * can complete waveOut headers out of phase with our submit cadence, so
     * scan the complete ring for a slot reaped from the device queue. */
    for (attempt = 0; attempt < MQ_AUDIO_BUFFER_COUNT; ++attempt) {
        mq_u32 index = (mq_audio_next_buffer + attempt) % MQ_AUDIO_BUFFER_COUNT;
        MQ_WAVEHDR *candidate = &mq_audio_headers[index];
        if (!mq_audio_header_queued[index]) {
            header = candidate;
            selected = index;
            break;
        }
    }
    if (header == MQ_NULL) {
        return 0;
    }

    /* A prepared waveOut header can be submitted repeatedly after WHDR_DONE.
     * Keep the normal fixed-size 512-frame blocks registered with the driver;
     * unprepare only if a diagnostic caller changes the block size. */
    if ((header->dwFlags & MQ_WHDR_PREPARED) != 0 && header->dwBufferLength != byte_count) {
        waveOutUnprepareHeader(mq_wave_output, header, (UINT)sizeof(*header));
        header->dwFlags = 0;
    }
    mq_copy_bytes((mq_u8 *)header->lpData, (const mq_u8 *)data, byte_count);
    header->dwBufferLength = byte_count;
    header->dwBytesRecorded = 0;
    header->dwUser = byte_count;
    header->dwLoops = 0;
    if ((header->dwFlags & MQ_WHDR_PREPARED) == 0) {
        header->dwFlags = 0;
        if (waveOutPrepareHeader(mq_wave_output, header, (UINT)sizeof(*header)) != 0) {
            return 0;
        }
    } else {
        header->dwFlags &= MQ_WHDR_PREPARED;
    }
    if (waveOutWrite(mq_wave_output, header, (UINT)sizeof(*header)) != 0) {
        return 0;
    }
    mq_audio_header_queued[selected] = 1;
    mq_audio_next_buffer = (selected + 1u) % MQ_AUDIO_BUFFER_COUNT;
    if (mq_audio_buffer_count < MQ_AUDIO_BUFFER_COUNT) {
        ++mq_audio_buffer_count;
    }
    ++mq_audio_submitted_count;
    return 1;
}

/* Close the active resource and release its storage. */
MQ_EXPORT void mq_audio_close(void) {
    mq_u32 i;
    if (mq_wave_output == MQ_NULL) {
        return;
    }
    waveOutReset(mq_wave_output);
    mq_audio_reap_completed();
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        if (mq_audio_headers[i].dwFlags & MQ_WHDR_PREPARED) {
            waveOutUnprepareHeader(mq_wave_output, &mq_audio_headers[i], (UINT)sizeof(MQ_WAVEHDR));
            mq_audio_headers[i].dwFlags = 0;
        }
        mq_audio_header_queued[i] = 0;
    }
    waveOutClose(mq_wave_output);
    mq_wave_output = MQ_NULL;
    mq_audio_buffer_count = 0;
}

/* Return the number of queued audio frames. */
MQ_EXPORT mq_u32 mq_audio_queued(void) {
    if (mq_wave_output == MQ_NULL) {
        return 0;
    }
    mq_audio_reap_completed();
    return mq_audio_buffer_count;
}

/* Restore reset to its default state. */
MQ_EXPORT mq_i32 mq_audio_reset(void) {
    if (mq_wave_output == MQ_NULL) {
        return 0;
    }
    if (waveOutReset(mq_wave_output) != 0) {
        return 0;
    }
    mq_audio_reap_completed();
    return 1;
}

/* Return the audio device's playback position. */
MQ_EXPORT mq_u32 mq_audio_position(mq_u32 sample_mask) {
    MQ_MMTIME time_value;
    mq_u64 byte_position = mq_audio_completed_bytes;
    if (mq_wave_output != MQ_NULL) {
        memset(&time_value, 0, sizeof(time_value));
        time_value.wType = MQ_TIME_BYTES;
        if (waveOutGetPosition(mq_wave_output, &time_value, (UINT)sizeof(time_value)) == 0 &&
            time_value.wType == MQ_TIME_BYTES) {
            byte_position = (mq_u64)time_value.u.cb;
        }
    }
    if (mq_audio_bytes_per_sample == 0) {
        return 0;
    }
    return (mq_u32)(byte_position / mq_audio_bytes_per_sample) & sample_mask;
}

/* Submit submitted to the native queue. */
MQ_EXPORT mq_u32 mq_audio_submitted(void) {
    return mq_audio_submitted_count;
}

/* Return the number of audio frames completed by the device. */
MQ_EXPORT mq_u32 mq_audio_completed(void) {
    mq_audio_reap_completed();
    return mq_audio_completed_count;
}

/* Return the accumulated audio underrun count. */
MQ_EXPORT mq_u32 mq_audio_underruns(void) {
    return mq_audio_underrun_count;
}

/* Return the state of the selected audio buffer header. */
MQ_EXPORT mq_u32 mq_audio_header_state(mq_u32 index) {
    MQ_WAVEHDR *header;
    if (index >= MQ_AUDIO_BUFFER_COUNT) {
        return 0;
    }
    mq_audio_reap_completed();
    header = &mq_audio_headers[index];
    if (mq_audio_header_queued[index] && (header->dwFlags & MQ_WHDR_PREPARED) != 0) return 1;
    return 0;
}

/* Return the audio queue's frame capacity. */
MQ_EXPORT mq_u32 mq_audio_capacity(void) {
    return MQ_AUDIO_BUFFER_COUNT;
}

/* Report whether the requested native device is open. */
MQ_EXPORT mq_i32 mq_audio_is_open(void) {
    return mq_wave_output != MQ_NULL;
}

/* Open and validate bound. */
MQ_EXPORT mq_u64 mq_udp_open_bound(mq_u32 port, const char *bind_address) {
    SOCKET socket_value;
    MQ_SOCKADDR_IN address;
    mq_u32 nonblocking = 1;
    mq_u32 parsed_address = 0;
    if (port > 65535u || !mq_winsock_start()) {
        return 0;
    }
    if (bind_address != MQ_NULL && bind_address[0] != 0 &&
        !(bind_address[0] == '0' && bind_address[1] == '.' &&
          bind_address[2] == '0' && bind_address[3] == '.' &&
          bind_address[4] == '0' && bind_address[5] == '.' &&
          bind_address[6] == '0' && bind_address[7] == 0)) {
        parsed_address = inet_addr(bind_address);
        if (parsed_address == MQ_INADDR_NONE) {
            mq_udp_last_error_value = -3;
            return 0;
        }
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
    address.sin_addr = parsed_address;
    if (bind(socket_value, &address, (mq_i32)sizeof(address)) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        closesocket(socket_value);
        return 0;
    }
    ++mq_udp_socket_count;
    mq_udp_last_error_value = 0;
    return (mq_u64)socket_value;
}

/* Open and validate the requested resource. */
MQ_EXPORT mq_u64 mq_udp_open(mq_u32 port) {
    return mq_udp_open_bound(port, "0.0.0.0");
}

/* Close the active resource and release its storage. */
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

/* Return the UDP port assigned to a socket. */
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

MQ_EXPORT const char *mq_udp_bound_address(mq_u64 handle) {
    MQ_SOCKADDR_IN address;
    mq_i32 address_length = (mq_i32)sizeof(address);
    if (handle == 0) {
        mq_udp_last_error_value = -1;
        return "";
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    if (getsockname((SOCKET)handle, &address, &address_length) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        return "";
    }
    mq_udp_format_address(mq_udp_bound_address_text, address.sin_addr);
    mq_udp_last_error_value = 0;
    return mq_udp_bound_address_text;
}

/* Update the enabled state of broadcast. */
MQ_EXPORT mq_i32 mq_udp_enable_broadcast(mq_u64 handle) {
    mq_i32 enabled = 1;
    if (handle == 0) {
        mq_udp_last_error_value = -1;
        return -1;
    }
    if (setsockopt((SOCKET)handle, MQ_SOL_SOCKET, MQ_SO_BROADCAST, (const char *)&enabled, (mq_i32)sizeof(enabled)) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        return -1;
    }
    mq_udp_last_error_value = 0;
    return 0;
}

/* Poll the native queue without blocking the game loop. */
MQ_EXPORT mq_i32 mq_udp_peek(mq_u64 handle) {
    char value;
    mq_i32 result;
    if (handle == 0) {
        mq_udp_last_error_value = -1;
        return -1;
    }
    result = recvfrom((SOCKET)handle, &value, 1, MQ_MSG_PEEK, MQ_NULL, MQ_NULL);
    if (result == MQ_SOCKET_ERROR) {
        mq_i32 error_code = WSAGetLastError();
        if (error_code == MQ_WSAEMSGSIZE) {
            mq_udp_last_error_value = 0;
            return 1;
        }
        if (error_code == MQ_WSAEWOULDBLOCK || error_code == MQ_WSAECONNRESET || error_code == MQ_WSAECONNREFUSED) {
            mq_udp_last_error_value = 0;
            return 0;
        }
        mq_udp_last_error_value = error_code;
        return -1;
    }
    mq_udp_last_error_value = 0;
    return result;
}

/* Submit the immediate-mode vertices collected for the draw. */
MQ_EXPORT mq_i32 mq_udp_send(mq_u64 handle, const char *address_text, mq_u32 port, const void *data, mq_u32 byte_count) {
    MQ_SOCKADDR_IN address;
    MQ_HOSTENT *host_entry;
    mq_u32 parsed_address;
    mq_i32 result;
    if (handle == 0 || address_text == MQ_NULL || data == MQ_NULL || byte_count > 65507u || port > 65535u) {
        mq_udp_last_error_value = -1;
        return -1;
    }
    parsed_address = inet_addr(address_text);
    if (parsed_address == MQ_INADDR_NONE &&
        !(address_text[0] == '2' && address_text[1] == '5' && address_text[2] == '5' && address_text[3] == '.' &&
          address_text[4] == '2' && address_text[5] == '5' && address_text[6] == '5' && address_text[7] == '.' &&
          address_text[8] == '2' && address_text[9] == '5' && address_text[10] == '5' && address_text[11] == '.' &&
          address_text[12] == '2' && address_text[13] == '5' && address_text[14] == '5' && address_text[15] == 0)) {
        host_entry = gethostbyname(address_text);
        if (host_entry == MQ_NULL || host_entry->h_addrtype != MQ_AF_INET ||
            host_entry->h_length != 4 || host_entry->h_addr_list == MQ_NULL ||
            host_entry->h_addr_list[0] == MQ_NULL) {
            mq_udp_last_error_value = -2;
            return -1;
        }
        parsed_address = *(const mq_u32 *)host_entry->h_addr_list[0];
    }
    mq_zero_bytes((mq_u8 *)&address, (mq_u32)sizeof(address));
    address.sin_family = (mq_u16)MQ_AF_INET;
    address.sin_port = htons((mq_u16)port);
    address.sin_addr = parsed_address;
    result = sendto((SOCKET)handle, (const char *)data, (mq_i32)byte_count, 0, &address, (mq_i32)sizeof(address));
    if (result == MQ_SOCKET_ERROR) {
        mq_i32 error_code = WSAGetLastError();
        if (error_code == MQ_WSAEWOULDBLOCK) {
            mq_udp_last_error_value = 0;
            return 0;
        }
        mq_udp_last_error_value = error_code;
        return -1;
    }
    mq_udp_last_error_value = 0;
    return result;
}

/* Remove receive from the native queue. */
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
        if (error_code == MQ_WSAEWOULDBLOCK || error_code == MQ_WSAECONNRESET || error_code == MQ_WSAECONNREFUSED) {
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
/* Return the source port of the last UDP packet. */
MQ_EXPORT mq_u32 mq_udp_last_port(void) { return mq_udp_last_port_value; }
/* Return the last native networking error code. */
MQ_EXPORT mq_i32 mq_udp_last_error(void) { return mq_udp_last_error_value; }
MQ_EXPORT const char *mq_udp_local_address(void) {
    char host_name[256];
    MQ_HOSTENT *host_entry;
    mq_u32 address;
    if (!mq_winsock_start()) {
        return mq_udp_local_address_text;
    }
    if (gethostname(host_name, (mq_i32)sizeof(host_name)) == MQ_SOCKET_ERROR) {
        return mq_udp_local_address_text;
    }
    host_name[sizeof(host_name) - 1u] = 0;
    host_entry = gethostbyname(host_name);
    if (host_entry == MQ_NULL || host_entry->h_addrtype != MQ_AF_INET ||
        host_entry->h_length != 4 || host_entry->h_addr_list == MQ_NULL ||
        host_entry->h_addr_list[0] == MQ_NULL) {
        return mq_udp_local_address_text;
    }
    address = *(const mq_u32 *)host_entry->h_addr_list[0];
    mq_udp_format_address(mq_udp_local_address_text, address);
    return mq_udp_local_address_text;
}

MQ_EXPORT const char *mq_udp_host_name(void) {
    if (!mq_winsock_start()) {
        return "";
    }
    if (gethostname(mq_udp_host_name_text, (mq_i32)sizeof(mq_udp_host_name_text)) == MQ_SOCKET_ERROR) {
        mq_udp_last_error_value = WSAGetLastError();
        mq_udp_host_name_text[0] = 0;
        return mq_udp_host_name_text;
    }
    mq_udp_host_name_text[sizeof(mq_udp_host_name_text) - 1u] = 0;
    mq_udp_last_error_value = 0;
    return mq_udp_host_name_text;
}

MQ_EXPORT const char *mq_udp_resolve_name(const char *name) {
    MQ_HOSTENT *host_entry;
    mq_u32 address;
    if (name == MQ_NULL || name[0] == 0 || !mq_winsock_start()) {
        mq_udp_last_error_value = -1;
        return "";
    }
    address = inet_addr(name);
    if (address == MQ_INADDR_NONE) {
        host_entry = gethostbyname(name);
        if (host_entry == MQ_NULL || host_entry->h_addrtype != MQ_AF_INET ||
            host_entry->h_length != 4 || host_entry->h_addr_list == MQ_NULL ||
            host_entry->h_addr_list[0] == MQ_NULL) {
            mq_udp_last_error_value = WSAGetLastError();
            return "";
        }
        address = *(const mq_u32 *)host_entry->h_addr_list[0];
    }
    mq_udp_format_address(mq_udp_resolved_address_text, address);
    mq_udp_last_error_value = 0;
    return mq_udp_resolved_address_text;
}

MQ_EXPORT const char *mq_udp_reverse_name(const char *address_text) {
    MQ_HOSTENT *host_entry;
    mq_u32 address;
    if (address_text == MQ_NULL || !mq_winsock_start()) {
        mq_udp_last_error_value = -1;
        return "";
    }
    address = inet_addr(address_text);
    if (address == MQ_INADDR_NONE) {
        mq_udp_last_error_value = -2;
        return "";
    }
    host_entry = gethostbyaddr((const char *)&address, 4, MQ_AF_INET);
    if (host_entry == MQ_NULL || host_entry->h_name == MQ_NULL) {
        mq_udp_last_error_value = WSAGetLastError();
        return "";
    }
    mq_copy_c_string(mq_udp_reverse_name_text, (mq_u32)sizeof(mq_udp_reverse_name_text), host_entry->h_name);
    mq_udp_last_error_value = 0;
    return mq_udp_reverse_name_text;
}

/* Begin collecting immediate-mode vertices for one draw. */
MQ_EXPORT void mq_gl_begin(mq_u32 mode) {
    if (mq_static_geometry_pending && !mq_static_geometry_recording) {
        if (mq_render_backend_value != MQ_RENDER_OPENGL) {
            mq_static_geometry_pending = 0;
            mq_static_geometry_recording = 1;
            mq_static_geometry_capture_count = 0u;
            mq_static_geometry_capture_mode = mode;
            mq_static_geometry_capture_valid = 1;
            return;
        }
        glNewList(
            mq_static_geometry_pending_list,
            mq_static_geometry_pending_execute ? GL_COMPILE_AND_EXECUTE : 0x1300u /* GL_COMPILE */
        );
        mq_static_geometry_pending = 0;
        mq_static_geometry_recording = 1;
        mq_static_geometry_capture_count = 0u;
        mq_static_geometry_capture_mode = mode;
        mq_static_geometry_capture_valid = 1;
    }
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_begin(mode); return; }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_begin(mode); return; }
 glBegin(mode); }
/* Submit the immediate-mode vertices collected for the draw. */
MQ_EXPORT void mq_gl_end(void) {
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        if (mq_static_geometry_recording) {
            mq_static_geometry_finish_capture();
            mq_static_geometry_recording = 0;
            mq_static_geometry_pending_list = 0;
            mq_static_geometry_pending_execute = 1;
            mq_static_geometry_pending_entry = -1;
            mq_static_geometry_capture_valid = 0;
        } else {
            if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) mq_d3d9_end();
            else mq_vulkan_end();
        }
        return;
    }
    glEnd();
    if (mq_static_geometry_recording) {
        mq_static_geometry_finish_capture();
        glEndList();
        mq_static_geometry_recording = 0;
        mq_static_geometry_pending_list = 0;
        mq_static_geometry_pending_execute = 1;
        mq_static_geometry_pending_entry = -1;
        mq_static_geometry_capture_valid = 0;
    }
}
/* Update the current immediate-mode vertex attributes. */
MQ_EXPORT void mq_gl_vertex2(mq_u32 x_bits, mq_u32 y_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_vertex2(x_bits, y_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_vertex2(x_bits, y_bits); return; } glVertex2f(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits)); }
/* Update the current immediate-mode vertex attributes. */
MQ_EXPORT void mq_gl_vertex3(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) {
    float x = mq_bits_to_float(x_bits);
    float y = mq_bits_to_float(y_bits);
    float z = mq_bits_to_float(z_bits);
    if (mq_static_geometry_recording && mq_static_geometry_capture_valid) {
        if (mq_static_geometry_capture_count < MQ_STATIC_GEOMETRY_CAPTURE_VERTICES) {
            mq_u32 offset = mq_static_geometry_capture_count * MQ_STATIC_GEOMETRY_VERTEX_FLOATS;
            mq_static_geometry_capture[offset] = mq_static_geometry_s;
            mq_static_geometry_capture[offset + 1u] = mq_static_geometry_t;
            mq_static_geometry_capture[offset + 2u] = x;
            mq_static_geometry_capture[offset + 3u] = y;
            mq_static_geometry_capture[offset + 4u] = z;
            offset = mq_static_geometry_capture_count * MQ_STATIC_GEOMETRY_MULTI_FLOATS;
            mq_static_geometry_multi_capture[offset] = mq_static_geometry_multi_s[0];
            mq_static_geometry_multi_capture[offset + 1u] = mq_static_geometry_multi_t[0];
            mq_static_geometry_multi_capture[offset + 2u] = mq_static_geometry_multi_s[1];
            mq_static_geometry_multi_capture[offset + 3u] = mq_static_geometry_multi_t[1];
            mq_static_geometry_multi_capture[offset + 4u] = x;
            mq_static_geometry_multi_capture[offset + 5u] = y;
            mq_static_geometry_multi_capture[offset + 6u] = z;
            mq_static_geometry_capture_count += 1u;
        } else {
            mq_static_geometry_capture_valid = 0;
        }
    }
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (!mq_static_geometry_recording) mq_d3d9_vertex3(x_bits, y_bits, z_bits);
        return;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (!mq_static_geometry_recording) mq_vulkan_vertex3(x_bits, y_bits, z_bits);
        return;
    }
    glVertex3f(x, y, z);
}
#define MQ_SHADOW_DRAW_VERTICES 16383u
static float mq_shadow_draw_vertices[MQ_SHADOW_DRAW_VERTICES * 5u];

/* Submit projected shadow triangles in one backend draw instead of replaying
 * every vertex through the immediate-mode dispatcher. */
static mq_i32 mq_shadow_submit_vertices(mq_u32 vertex_count) {
    if (vertex_count == 0u || vertex_count > MQ_SHADOW_DRAW_VERTICES || (vertex_count % 3u) != 0u) return 0;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        return mq_d3d9_draw_interleaved_t2f_v3f(mq_shadow_draw_vertices, vertex_count) > 0;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        return mq_vulkan_draw_interleaved_t2f_v3f(mq_shadow_draw_vertices, vertex_count) > 0;
    }
    glInterleavedArrays(0x2A27u /* GL_T2F_V3F */, 0, mq_shadow_draw_vertices);
    glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
    return 1;
}

/* Draw packed world-space shadow triangles through one MiniLang/native crossing. */
MQ_EXPORT mq_i32 mq_gl_draw_shadow_batch(const mq_u8 *data, mq_u32 byte_count) {
    mq_u32 offset = 0u;
    mq_u32 vertex_count = 0u;
    mq_i32 drawn = 0;
    if (!data || byte_count == 0u || (byte_count % 36u) != 0u) return 0;
    while (offset < byte_count) {
        mq_u32 x_bits;
        mq_u32 y_bits;
        mq_u32 z_bits;
        mq_u32 output;
        if (vertex_count == MQ_SHADOW_DRAW_VERTICES) {
            if (!mq_shadow_submit_vertices(vertex_count)) return drawn;
            drawn += (mq_i32)(vertex_count / 3u);
            vertex_count = 0u;
        }
        memcpy(&x_bits, data + offset, 4u);
        memcpy(&y_bits, data + offset + 4u, 4u);
        memcpy(&z_bits, data + offset + 8u, 4u);
        output = vertex_count * 5u;
        mq_shadow_draw_vertices[output] = 0.0f;
        mq_shadow_draw_vertices[output + 1u] = 0.0f;
        mq_shadow_draw_vertices[output + 2u] = mq_bits_to_float(x_bits);
        mq_shadow_draw_vertices[output + 3u] = mq_bits_to_float(y_bits);
        mq_shadow_draw_vertices[output + 4u] = mq_bits_to_float(z_bits);
        vertex_count += 1u;
        offset += 12u;
    }
    if (vertex_count > 0u) {
        if (!mq_shadow_submit_vertices(vertex_count)) return drawn;
        drawn += (mq_i32)(vertex_count / 3u);
    }
    return drawn;
}

#define MQ_SHADOW_ALIAS_COMMAND_MAX 1024u
#define MQ_SHADOW_ALIAS_CACHE_SIZE 4096u
static float mq_shadow_alias_projected[MQ_SHADOW_ALIAS_CACHE_SIZE][3];
static float mq_shadow_alias_normal[MQ_SHADOW_ALIAS_CACHE_SIZE][3];
static float mq_shadow_alias_source[MQ_SHADOW_ALIAS_CACHE_SIZE][3];
static float mq_shadow_alias_travel[MQ_SHADOW_ALIAS_CACHE_SIZE];
static mq_u32 mq_shadow_alias_surface[MQ_SHADOW_ALIAS_CACHE_SIZE];
static mq_u8 mq_shadow_alias_valid[MQ_SHADOW_ALIAS_CACHE_SIZE];
static mq_u32 mq_shadow_alias_command_slot[MQ_SHADOW_ALIAS_COMMAND_MAX];
static mq_u32 mq_shadow_alias_cache_key[MQ_SHADOW_ALIAS_CACHE_SIZE];
static mq_u32 mq_shadow_alias_cache_generation[MQ_SHADOW_ALIAS_CACHE_SIZE];
static mq_u32 mq_shadow_alias_generation = 1u;
static mq_u32 mq_shadow_alias_angle_bits[3];
static float mq_shadow_alias_angle_trig[6];
static mq_i32 mq_shadow_alias_angle_valid = 0;

/* Resolve one compressed MDL position in the sample-local projection cache. */
static mq_u32 mq_shadow_alias_cache_slot(mq_u8 x, mq_u8 y, mq_u8 z, mq_i32 *created) {
    mq_u32 key = (mq_u32)x | ((mq_u32)y << 8u) | ((mq_u32)z << 16u);
    mq_u32 slot = (key * 2654435761u) & (MQ_SHADOW_ALIAS_CACHE_SIZE - 1u);
    mq_u32 probes = 0u;
    while (probes < MQ_SHADOW_ALIAS_CACHE_SIZE) {
        if (mq_shadow_alias_cache_generation[slot] != mq_shadow_alias_generation) {
            mq_shadow_alias_cache_generation[slot] = mq_shadow_alias_generation;
            mq_shadow_alias_cache_key[slot] = key;
            *created = 1;
            return slot;
        }
        if (mq_shadow_alias_cache_key[slot] == key) {
            *created = 0;
            return slot;
        }
        slot = (slot + 1u) & (MQ_SHADOW_ALIAS_CACHE_SIZE - 1u);
        ++probes;
    }
    *created = 0;
    return MQ_SHADOW_ALIAS_CACHE_SIZE;
}

/* Validate one projected alias edge against receiver orientation and stretch. */
static mq_i32 mq_shadow_alias_edge_compatible(mq_u32 left, mq_u32 right) {
    float normal_dot =
        mq_shadow_alias_normal[left][0] * mq_shadow_alias_normal[right][0] +
        mq_shadow_alias_normal[left][1] * mq_shadow_alias_normal[right][1] +
        mq_shadow_alias_normal[left][2] * mq_shadow_alias_normal[right][2];
    float source_x = mq_shadow_alias_source[left][0] - mq_shadow_alias_source[right][0];
    float source_y = mq_shadow_alias_source[left][1] - mq_shadow_alias_source[right][1];
    float source_z = mq_shadow_alias_source[left][2] - mq_shadow_alias_source[right][2];
    float projected_x = mq_shadow_alias_projected[left][0] - mq_shadow_alias_projected[right][0];
    float projected_y = mq_shadow_alias_projected[left][1] - mq_shadow_alias_projected[right][1];
    float projected_z = mq_shadow_alias_projected[left][2] - mq_shadow_alias_projected[right][2];
    float source_length;
    float projected_length;
    float travel_difference;
    if (mq_shadow_alias_surface[left] != mq_shadow_alias_surface[right]) return 0;
    if (normal_dot < 0.65f) return 0;
    source_length = sqrtf(source_x * source_x + source_y * source_y + source_z * source_z);
    projected_length = sqrtf(projected_x * projected_x + projected_y * projected_y + projected_z * projected_z);
    travel_difference = mq_shadow_alias_travel[left] - mq_shadow_alias_travel[right];
    if (travel_difference < 0.0f) travel_difference = -travel_difference;
    if (projected_length > source_length * 3.0f + 24.0f) return 0;
    return travel_difference <= source_length * 1.5f + 12.0f;
}

/* Project one transformed alias vertex through the native world BVH. */
static mq_i32 mq_shadow_alias_project_vertex(
    mq_u32 index, float packed_x, float packed_y, float packed_z,
    const float *origin, const float *scale_origin, const float *scale,
    float yaw_cosine, float yaw_sine, float pitch_cosine, float pitch_sine,
    float roll_cosine, float roll_sine, mq_i32 point_light_active,
    const float *point_light, float sample_x, float sample_y,
    const float *fallback_direction
) {
    float local_x = packed_x * scale[0] + scale_origin[0];
    float local_y = packed_y * scale[1] + scale_origin[1];
    float local_z = packed_z * scale[2] + scale_origin[2];
    float rolled_y = roll_cosine * local_y - roll_sine * local_z;
    float rolled_z = roll_sine * local_y + roll_cosine * local_z;
    float pitched_x = pitch_cosine * local_x + pitch_sine * rolled_z;
    float pitched_y = rolled_y;
    float pitched_z = -pitch_sine * local_x + pitch_cosine * rolled_z;
    float world[3];
    float ray[6];
    float result[8] = {0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f};
    float minimum_fraction = 0.0f;
    world[0] = origin[0] + yaw_cosine * pitched_x - yaw_sine * pitched_y;
    world[1] = origin[1] + yaw_sine * pitched_x + yaw_cosine * pitched_y;
    world[2] = origin[2] + pitched_z;
    mq_shadow_alias_source[index][0] = world[0];
    mq_shadow_alias_source[index][1] = world[1];
    mq_shadow_alias_source[index][2] = world[2];
    if (point_light_active) {
        float delta[3];
        float distance;
        float inverse;
        ray[0] = point_light[0] + sample_x;
        ray[1] = point_light[1] + sample_y;
        ray[2] = point_light[2];
        delta[0] = world[0] - ray[0];
        delta[1] = world[1] - ray[1];
        delta[2] = world[2] - ray[2];
        distance = sqrtf(delta[0] * delta[0] + delta[1] * delta[1] + delta[2] * delta[2]);
        if (distance < 0.5f) return 0;
        inverse = 1.0f / distance;
        ray[3] = world[0] + delta[0] * inverse * 768.0f;
        ray[4] = world[1] + delta[1] * inverse * 768.0f;
        ray[5] = world[2] + delta[2] * inverse * 768.0f;
        minimum_fraction = (distance + 0.25f) / (distance + 768.0f);
    } else {
        ray[0] = world[0] + fallback_direction[0] * 0.25f;
        ray[1] = world[1] + fallback_direction[1] * 0.25f;
        ray[2] = world[2] + fallback_direction[2] * 0.25f;
        ray[3] = world[0] + fallback_direction[0] * 768.0f;
        ray[4] = world[1] + fallback_direction[1] * 768.0f;
        ray[5] = world[2] + fallback_direction[2] * 768.0f;
    }
    if (!mq_shadow_trace_cached(ray, result)) return 0;
    if (result[1] <= minimum_fraction) return 0;
    if (point_light_active && minimum_fraction > 0.0f && result[1] > minimum_fraction * 3.0f) return 0;
    mq_shadow_alias_projected[index][0] = result[2] + result[5] * 0.65f;
    mq_shadow_alias_projected[index][1] = result[3] + result[6] * 0.65f;
    mq_shadow_alias_projected[index][2] = result[4] + result[7] * 0.65f;
    mq_shadow_alias_normal[index][0] = result[5];
    mq_shadow_alias_normal[index][1] = result[6];
    mq_shadow_alias_normal[index][2] = result[7];
    mq_shadow_alias_surface[index] = (mq_u32)(result[0] - 1.0f);
    {
        float travel_x = result[2] - world[0];
        float travel_y = result[3] - world[1];
        float travel_z = result[4] - world[2];
        mq_shadow_alias_travel[index] = sqrtf(travel_x * travel_x + travel_y * travel_y + travel_z * travel_z);
    }
    return 1;
}

/* Transform, ray-project and draw one cached alias frame entirely in native code. */
MQ_EXPORT mq_i32 mq_gl_draw_alias_ray_shadow(
    const mq_u8 *data, mq_u32 byte_count,
    mq_u32 origin_x_bits, mq_u32 origin_y_bits, mq_u32 origin_z_bits,
    mq_u32 angle_x_bits, mq_u32 angle_y_bits, mq_u32 angle_z_bits,
    mq_u32 scale_origin_x_bits, mq_u32 scale_origin_y_bits, mq_u32 scale_origin_z_bits,
    mq_u32 scale_x_bits, mq_u32 scale_y_bits, mq_u32 scale_z_bits,
    mq_i32 double_eyes, mq_i32 point_light_active,
    mq_u32 light_x_bits, mq_u32 light_y_bits, mq_u32 light_z_bits,
    mq_u32 sample_x_bits, mq_u32 sample_y_bits
) {
    float origin[3] = {mq_bits_to_float(origin_x_bits), mq_bits_to_float(origin_y_bits), mq_bits_to_float(origin_z_bits)};
    float scale_origin[3] = {mq_bits_to_float(scale_origin_x_bits), mq_bits_to_float(scale_origin_y_bits), mq_bits_to_float(scale_origin_z_bits)};
    float scale[3] = {mq_bits_to_float(scale_x_bits), mq_bits_to_float(scale_y_bits), mq_bits_to_float(scale_z_bits)};
    float point_light[3] = {mq_bits_to_float(light_x_bits), mq_bits_to_float(light_y_bits), mq_bits_to_float(light_z_bits)};
    float sample_x = mq_bits_to_float(sample_x_bits);
    float sample_y = mq_bits_to_float(sample_y_bits);
    float fallback_direction[3] = {0.0f, 0.0f, -1.0f};
    float yaw_cosine;
    float yaw_sine;
    float pitch_cosine;
    float pitch_sine;
    float roll_cosine;
    float roll_sine;
    mq_u32 offset = 0u;
    mq_u32 draw_vertex_count = 0u;
    mq_i32 drawn = 0;
    if (!data || byte_count < 4u || !mq_shadow_nodes) return 0;
    if (!mq_shadow_alias_angle_valid ||
        mq_shadow_alias_angle_bits[0] != angle_x_bits ||
        mq_shadow_alias_angle_bits[1] != angle_y_bits ||
        mq_shadow_alias_angle_bits[2] != angle_z_bits) {
        float yaw = mq_bits_to_float(angle_y_bits) * 0.01745329251994329577f;
        float pitch = -mq_bits_to_float(angle_x_bits) * 0.01745329251994329577f;
        float roll = mq_bits_to_float(angle_z_bits) * 0.01745329251994329577f;
        mq_shadow_alias_angle_bits[0] = angle_x_bits;
        mq_shadow_alias_angle_bits[1] = angle_y_bits;
        mq_shadow_alias_angle_bits[2] = angle_z_bits;
        mq_shadow_alias_angle_trig[0] = (float)cos((double)yaw);
        mq_shadow_alias_angle_trig[1] = (float)sin((double)yaw);
        mq_shadow_alias_angle_trig[2] = (float)cos((double)pitch);
        mq_shadow_alias_angle_trig[3] = (float)sin((double)pitch);
        mq_shadow_alias_angle_trig[4] = (float)cos((double)roll);
        mq_shadow_alias_angle_trig[5] = (float)sin((double)roll);
        mq_shadow_alias_angle_valid = 1;
    }
    yaw_cosine = mq_shadow_alias_angle_trig[0];
    yaw_sine = mq_shadow_alias_angle_trig[1];
    pitch_cosine = mq_shadow_alias_angle_trig[2];
    pitch_sine = mq_shadow_alias_angle_trig[3];
    roll_cosine = mq_shadow_alias_angle_trig[4];
    roll_sine = mq_shadow_alias_angle_trig[5];
    if (!point_light_active) {
        float fallback_inverse;
        fallback_direction[0] = 0.45f + sample_x * 0.018f;
        fallback_direction[1] = 0.35f + sample_y * 0.018f;
        fallback_inverse = 1.0f / sqrtf(
            fallback_direction[0] * fallback_direction[0] +
            fallback_direction[1] * fallback_direction[1] +
            fallback_direction[2] * fallback_direction[2]
        );
        fallback_direction[0] *= fallback_inverse;
        fallback_direction[1] *= fallback_inverse;
        fallback_direction[2] *= fallback_inverse;
    }
    ++mq_shadow_alias_generation;
    if (mq_shadow_alias_generation == 0u) {
        mq_u32 cache_index;
        for (cache_index = 0u; cache_index < MQ_SHADOW_ALIAS_CACHE_SIZE; ++cache_index) mq_shadow_alias_cache_generation[cache_index] = 0u;
        mq_shadow_alias_generation = 1u;
    }
    if (double_eyes) {
        scale[0] *= 2.0f;
        scale[1] *= 2.0f;
        scale[2] *= 2.0f;
        scale_origin[2] -= 30.0f;
    }
    while (offset + 4u <= byte_count) {
        mq_i32 signed_count;
        mq_u32 count;
        mq_u32 index;
        memcpy(&signed_count, data + offset, 4u);
        offset += 4u;
        if (signed_count == 0) break;
        if (signed_count == (-2147483647 - 1)) break;
        count = signed_count < 0 ? (mq_u32)(-signed_count) : (mq_u32)signed_count;
        if (count > MQ_SHADOW_ALIAS_COMMAND_MAX || offset + count * 12u > byte_count) break;
        for (index = 0u; index < count; ++index) {
            const mq_u8 *vertex = data + offset + index * 12u;
            mq_i32 created;
            mq_u32 slot = mq_shadow_alias_cache_slot(vertex[8], vertex[9], vertex[10], &created);
            mq_shadow_alias_command_slot[index] = slot;
            if (slot < MQ_SHADOW_ALIAS_CACHE_SIZE && created) {
                mq_shadow_alias_valid[slot] = (mq_u8)mq_shadow_alias_project_vertex(
                    slot, (float)vertex[8], (float)vertex[9], (float)vertex[10],
                    origin, scale_origin, scale,
                    yaw_cosine, yaw_sine, pitch_cosine, pitch_sine, roll_cosine, roll_sine,
                    point_light_active, point_light, sample_x, sample_y, fallback_direction
                );
            }
        }
        for (index = 2u; index < count; ++index) {
            mq_u32 first = mq_shadow_alias_command_slot[signed_count < 0 ? 0u : index - 2u];
            mq_u32 second = mq_shadow_alias_command_slot[index - 1u];
            mq_u32 third = mq_shadow_alias_command_slot[index];
            if (first >= MQ_SHADOW_ALIAS_CACHE_SIZE || second >= MQ_SHADOW_ALIAS_CACHE_SIZE || third >= MQ_SHADOW_ALIAS_CACHE_SIZE) continue;
            if (mq_shadow_alias_valid[first] && mq_shadow_alias_valid[second] && mq_shadow_alias_valid[third] &&
                mq_shadow_alias_edge_compatible(first, second) &&
                mq_shadow_alias_edge_compatible(second, third) &&
                mq_shadow_alias_edge_compatible(third, first)) {
                mq_u32 slots[3] = {first, second, third};
                mq_u32 corner;
                if (draw_vertex_count == MQ_SHADOW_DRAW_VERTICES) {
                    if (!mq_shadow_submit_vertices(draw_vertex_count)) return drawn;
                    drawn += (mq_i32)(draw_vertex_count / 3u);
                    draw_vertex_count = 0u;
                }
                for (corner = 0u; corner < 3u; ++corner) {
                    mq_u32 output = draw_vertex_count * 5u;
                    mq_u32 slot = slots[corner];
                    mq_shadow_draw_vertices[output] = 0.0f;
                    mq_shadow_draw_vertices[output + 1u] = 0.0f;
                    mq_shadow_draw_vertices[output + 2u] = mq_shadow_alias_projected[slot][0];
                    mq_shadow_draw_vertices[output + 3u] = mq_shadow_alias_projected[slot][1];
                    mq_shadow_draw_vertices[output + 4u] = mq_shadow_alias_projected[slot][2];
                    draw_vertex_count += 1u;
                }
            }
        }
        offset += count * 12u;
    }
    if (draw_vertex_count > 0u && mq_shadow_submit_vertices(draw_vertex_count)) {
        drawn += (mq_i32)(draw_vertex_count / 3u);
    }
    return drawn;
}
/* Update the current immediate-mode texture coordinates. */
MQ_EXPORT void mq_gl_texcoord2(mq_u32 s_bits, mq_u32 t_bits) {
    mq_static_geometry_s = mq_bits_to_float(s_bits);
    mq_static_geometry_t = mq_bits_to_float(t_bits);
    mq_static_geometry_multi_s[0] = mq_static_geometry_s;
    mq_static_geometry_multi_t[0] = mq_static_geometry_t;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (!mq_static_geometry_recording) mq_d3d9_texcoord2(s_bits, t_bits);
        return;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (!mq_static_geometry_recording) mq_vulkan_texcoord2(s_bits, t_bits);
        return;
    }
    glTexCoord2f(mq_static_geometry_s, mq_static_geometry_t);
}
/* Update the current immediate-mode vertex attributes. */
MQ_EXPORT void mq_gl_color4ub(mq_u32 r, mq_u32 g, mq_u32 b, mq_u32 a) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_color4ub(r, g, b, a); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_color4ub(r, g, b, a); return; } glColor4ub((mq_u8)r, (mq_u8)g, (mq_u8)b, (mq_u8)a); }
/* Update the current immediate-mode vertex attributes. */
MQ_EXPORT void mq_gl_clear_color(mq_u32 r_bits, mq_u32 g_bits, mq_u32 b_bits, mq_u32 a_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_clear_color(r_bits, g_bits, b_bits, a_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_clear_color(r_bits, g_bits, b_bits, a_bits); return; } glClearColor(mq_bits_to_float(r_bits), mq_bits_to_float(g_bits), mq_bits_to_float(b_bits), mq_bits_to_float(a_bits)); }
/* Clear the selected buffers or pending native state. */
MQ_EXPORT void mq_gl_clear(mq_u32 mask) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_clear(mask); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_clear(mask); return; } glClear(mask); }
/* Update the enabled state of enable. */
MQ_EXPORT void mq_gl_enable(mq_u32 capability) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_enable(capability); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_enable(capability); return; } glEnable(capability); }
/* Update the enabled state of disable. */
MQ_EXPORT void mq_gl_disable(mq_u32 capability) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_disable(capability); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_disable(capability); return; } glDisable(capability); }
/* Update the source and destination blend factors. */
MQ_EXPORT void mq_gl_blend_func(mq_u32 source, mq_u32 destination) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_blend_func(source, destination); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_blend_func(source, destination); return; } glBlendFunc(source, destination); }
/* Update the depth comparison function. */
MQ_EXPORT void mq_gl_depth_func(mq_u32 function_name) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_depth_func(function_name); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_depth_func(function_name); return; } glDepthFunc(function_name); }
/* Enable or disable depth-buffer writes. */
MQ_EXPORT void mq_gl_depth_mask(mq_i32 enabled) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_depth_mask(enabled); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_depth_mask(enabled); return; } glDepthMask((mq_u8)(enabled != 0)); }
/* Clamp and update the viewport depth range. */
MQ_EXPORT void mq_gl_depth_range(mq_u32 near_bits, mq_u32 far_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_depth_range(near_bits, far_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_depth_range(near_bits, far_bits); return; } glDepthRange((double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
/* Update the alpha-test reference value. */
MQ_EXPORT void mq_gl_alpha_func(mq_u32 function_name, mq_u32 reference_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_alpha_func(function_name, reference_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_alpha_func(function_name, reference_bits); return; } glAlphaFunc(function_name, mq_bits_to_float(reference_bits)); }
/* Select which polygon face is culled. */
MQ_EXPORT void mq_gl_cull_face(mq_u32 mode) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_cull_face(mode); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_cull_face(mode); return; } glCullFace(mode); }
/* Accept the fixed-function shade-model state. */
MQ_EXPORT void mq_gl_shade_model(mq_u32 mode) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_shade_model(mode); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_shade_model(mode); return; } glShadeModel(mode); }
/* Select the polygon rasterization mode. */
MQ_EXPORT void mq_gl_polygon_mode(mq_u32 face, mq_u32 mode) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_polygon_mode(face, mode); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_polygon_mode(face, mode); return; } glPolygonMode(face, mode); }
/* Update the backend viewport rectangle. */
MQ_EXPORT void mq_gl_viewport(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_viewport(x, y, width, height); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_viewport(x, y, width, height); return; } glViewport(x, y, width, height); }
/* Select the active fixed-function matrix stack. */
MQ_EXPORT void mq_gl_matrix_mode(mq_u32 mode) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_matrix_mode(mode); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_matrix_mode(mode); return; } glMatrixMode(mode); }
/* Initialize a column-major identity matrix. */
MQ_EXPORT void mq_gl_load_identity(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_load_identity(); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_load_identity(); return; } glLoadIdentity(); }
/* Submit matrix to the native queue. */
MQ_EXPORT void mq_gl_push_matrix(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_push_matrix(); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_push_matrix(); return; } glPushMatrix(); }
/* Remove matrix from the native queue. */
MQ_EXPORT void mq_gl_pop_matrix(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_pop_matrix(); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_pop_matrix(); return; } glPopMatrix(); }
/* Postmultiply the current matrix with a translate transform. */
MQ_EXPORT void mq_gl_translate(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_translate(x_bits, y_bits, z_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_translate(x_bits, y_bits, z_bits); return; } glTranslatef(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
/* Postmultiply the current matrix with a rotate transform. */
MQ_EXPORT void mq_gl_rotate(mq_u32 angle_bits, mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_rotate(angle_bits, x_bits, y_bits, z_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_rotate(angle_bits, x_bits, y_bits, z_bits); return; } glRotatef(mq_bits_to_float(angle_bits), mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
/* Postmultiply the current matrix with a scale transform. */
MQ_EXPORT void mq_gl_scale(mq_u32 x_bits, mq_u32 y_bits, mq_u32 z_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_scale(x_bits, y_bits, z_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_scale(x_bits, y_bits, z_bits); return; } glScalef(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits), mq_bits_to_float(z_bits)); }
/* Postmultiply the current matrix with the requested ortho projection. */
MQ_EXPORT void mq_gl_ortho(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_ortho(left_bits, right_bits, bottom_bits, top_bits, near_bits, far_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_ortho(left_bits, right_bits, bottom_bits, top_bits, near_bits, far_bits); return; } glOrtho((double)mq_bits_to_float(left_bits), (double)mq_bits_to_float(right_bits), (double)mq_bits_to_float(bottom_bits), (double)mq_bits_to_float(top_bits), (double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
/* Postmultiply the current matrix with the requested frustum projection. */
MQ_EXPORT void mq_gl_frustum(mq_u32 left_bits, mq_u32 right_bits, mq_u32 bottom_bits, mq_u32 top_bits, mq_u32 near_bits, mq_u32 far_bits) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_frustum(left_bits, right_bits, bottom_bits, top_bits, near_bits, far_bits); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_frustum(left_bits, right_bits, bottom_bits, top_bits, near_bits, far_bits); return; } glFrustum((double)mq_bits_to_float(left_bits), (double)mq_bits_to_float(right_bits), (double)mq_bits_to_float(bottom_bits), (double)mq_bits_to_float(top_bits), (double)mq_bits_to_float(near_bits), (double)mq_bits_to_float(far_bits)); }
/* Bind the selected texture for subsequent draws. */
MQ_EXPORT void mq_gl_bind_texture(mq_u32 target, mq_u32 texture) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_bind_texture(target, texture); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_bind_texture(target, texture); return; } glBindTexture(target, texture); }
/* Allocate caller-visible texture identifiers. */
MQ_EXPORT void mq_gl_gen_textures(mq_i32 count, void *texture_ids) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_gen_textures(count, texture_ids); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_gen_textures(count, texture_ids); return; } glGenTextures(count, (mq_u32 *)texture_ids); }
/* Release resources owned by delete textures. */
MQ_EXPORT void mq_gl_delete_textures(mq_i32 count, const void *texture_ids) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_delete_textures(count, texture_ids); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_delete_textures(count, texture_ids); return; } glDeleteTextures(count, (const mq_u32 *)texture_ids); }
/* Update fixed-function texture sampling state. */
MQ_EXPORT void mq_gl_tex_parameter_i(mq_u32 target, mq_u32 name, mq_i32 value) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_tex_parameter_i(target, name, value); return; }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_tex_parameter_i(target, name, value); return; }
    if (name == 0x84FEu /* GL_TEXTURE_MAX_ANISOTROPY_EXT */) {
        const char *extensions = (const char *)glGetString(0x1F03u /* GL_EXTENSIONS */);
        float maximum = 1.0f;
        if (!mq_gl_extension_present(extensions, "GL_EXT_texture_filter_anisotropic")) return;
        glGetFloatv(0x84FFu /* GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT */, &maximum);
        if (value < 1) value = 1;
        if ((float)value > maximum) value = (mq_i32)maximum;
    }
    glTexParameteri(target, name, value);
}
/* Update fixed-function texture sampling state. */
MQ_EXPORT void mq_gl_tex_env_i(mq_u32 target, mq_u32 name, mq_i32 value) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_tex_env_i(target, name, value); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_tex_env_i(target, name, value); return; } glTexEnvi(target, name, value); }
/* Allocate and upload a complete texture image. */
MQ_EXPORT void mq_gl_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_tex_image_2d(target, level, internal_format, width, height, border, format, type, pixels); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_tex_image_2d(target, level, internal_format, width, height, border, format, type, pixels); return; } glTexImage2D(target, level, internal_format, width, height, border, format, type, pixels); }
/* Upload a rectangular update into an existing texture image. */
MQ_EXPORT void mq_gl_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_tex_sub_image_2d(target, level, x_offset, y_offset, width, height, format, type, pixels); return; }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_tex_sub_image_2d(target, level, x_offset, y_offset, width, height, format, type, pixels); return; }
    glTexSubImage2D(target, level, x_offset, y_offset, width, height, format, type, pixels);
}
/* Read pixels into caller-owned storage. */
MQ_EXPORT void mq_gl_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_read_pixels(x, y, width, height, format, type, pixels); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_read_pixels(x, y, width, height, format, type, pixels); return; } glReadPixels(x, y, width, height, format, type, pixels); }
MQ_EXPORT const char *mq_gl_get_string(mq_u32 name) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) return mq_d3d9_get_string(name); if (mq_render_backend_value == MQ_RENDER_VULKAN) return mq_vulkan_get_string(name); return (const char *)glGetString(name); }
/* Return the current get error value. */
MQ_EXPORT mq_u32 mq_gl_get_error(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) return mq_d3d9_get_error(); if (mq_render_backend_value == MQ_RENDER_VULKAN) return mq_vulkan_get_error(); return glGetError(); }
/* Synchronize queued rendering work with the native backend. */
MQ_EXPORT void mq_gl_finish(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_finish(); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_finish(); return; } glFinish(); }
/* Synchronize queued rendering work with the native backend. */
MQ_EXPORT void mq_gl_flush(void) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_flush(); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_flush(); return; } glFlush(); }
/* Submit draw buffer geometry to the active backend command buffer. */
MQ_EXPORT void mq_gl_draw_buffer(mq_u32 mode) { if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) { mq_d3d9_draw_buffer(mode); return; } if (mq_render_backend_value == MQ_RENDER_VULKAN) { mq_vulkan_draw_buffer(mode); return; } glDrawBuffer(mode); }
/* Report whether multitexture available is available. */
MQ_EXPORT mq_i32 mq_gl_multitexture_available(void) {
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return 0;
    return mq_valid_wgl_proc((const void *)mq_gl_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value);
}
/* Report whether world program available is available. */
MQ_EXPORT mq_i32 mq_gl_world_program_available(void) {
    /* The release renderer intentionally stays on GLQuake's fixed-function
     * texture-combine path. The shader bridge remains private fallback
     * infrastructure, but must not silently replace the compatibility path. */
    return 0;
}
/* Enable or disable the OpenGL world shader program. */
MQ_EXPORT void mq_gl_world_program_enable(mq_i32 enabled) {
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return;
    if (!mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) return;
    if (enabled && mq_gl_create_world_program()) mq_gl_use_program_value(mq_gl_world_program);
    else mq_gl_use_program_value(0u);
}

/* Report whether the active backend supports the enhanced GPU light pass. */
MQ_EXPORT mq_i32 mq_gl_enhanced_available(void) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) return mq_d3d9_enhanced_available();
    if (mq_render_backend_value == MQ_RENDER_VULKAN) return mq_vulkan_enhanced_available();
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return 0;
    return mq_gl_create_enhanced_program();
}

/* Configure optional enhanced lighting and its projected-shadow policy. */
MQ_EXPORT mq_i32 mq_gl_enhanced_configure(mq_i32 enabled, mq_i32 shadows, mq_i32 shadow_quality) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        return mq_d3d9_enhanced_configure(enabled, shadows, shadow_quality);
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        return mq_vulkan_enhanced_configure(enabled, shadows, shadow_quality);
    }
    mq_gl_enhanced_shadows = shadows != 0;
    mq_gl_enhanced_shadow_quality = shadow_quality;
    if (mq_gl_enhanced_shadow_quality < 0) mq_gl_enhanced_shadow_quality = 0;
    if (mq_gl_enhanced_shadow_quality > 2) mq_gl_enhanced_shadow_quality = 2;
    mq_gl_enhanced_enabled = enabled != 0 && mq_gl_enhanced_available();
    if (!mq_gl_enhanced_enabled && mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) {
        mq_gl_use_program_value(0u);
    }
    mq_gl_enhanced_draw_kind_value = 0;
    return enabled == 0 || mq_gl_enhanced_enabled;
}

/* Capture the current view and transform compact world lights to eye space. */
MQ_EXPORT mq_i32 mq_gl_enhanced_begin_frame(const void *light_data, mq_u32 byte_count) {
    const float *source = (const float *)light_data;
    float view[16];
    mq_u32 index;
    mq_u32 count;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        return mq_d3d9_enhanced_begin_frame(light_data, byte_count);
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        return mq_vulkan_enhanced_begin_frame(light_data, byte_count);
    }
    if (!mq_gl_enhanced_enabled || mq_render_backend_value != MQ_RENDER_OPENGL ||
        source == (const float *)0 || (byte_count & 15u) != 0u) return 0;
    count = byte_count >> 4;
    if (count > 4u) count = 4u;
    glGetFloatv(0x0BA6u /* GL_MODELVIEW_MATRIX */, view);
    for (index = 0u; index < count; ++index) {
        float x = source[index * 4u];
        float y = source[index * 4u + 1u];
        float z = source[index * 4u + 2u];
        mq_gl_enhanced_lights[index * 4u] = view[0] * x + view[4] * y + view[8] * z + view[12];
        mq_gl_enhanced_lights[index * 4u + 1u] = view[1] * x + view[5] * y + view[9] * z + view[13];
        mq_gl_enhanced_lights[index * 4u + 2u] = view[2] * x + view[6] * y + view[10] * z + view[14];
        mq_gl_enhanced_lights[index * 4u + 3u] = source[index * 4u + 3u];
    }
    mq_gl_enhanced_light_count = (mq_i32)count;
    return 1;
}

/* Select the enhanced shader for additive 3-D geometry only. */
MQ_EXPORT void mq_gl_enhanced_draw_kind(mq_i32 kind) {
    mq_i32 location;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        mq_d3d9_enhanced_draw_kind(kind);
        return;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_vulkan_enhanced_draw_kind(kind);
        return;
    }
    mq_gl_enhanced_draw_kind_value = kind;
    if (mq_render_backend_value != MQ_RENDER_OPENGL ||
        !mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) return;
    if (!mq_gl_enhanced_enabled || kind == 0 || !mq_gl_create_enhanced_program()) {
        mq_gl_use_program_value(0u);
        return;
    }
    mq_gl_use_program_value(mq_gl_enhanced_program);
    location = mq_gl_get_uniform_location_value(mq_gl_enhanced_program, "mq_light_count");
    if (location >= 0) mq_gl_uniform_1i_value(location, mq_gl_enhanced_light_count);
    location = mq_gl_get_uniform_location_value(mq_gl_enhanced_program, "mq_lights");
    if (location >= 0 && mq_gl_enhanced_light_count > 0) {
        mq_gl_uniform_4fv_value(location, mq_gl_enhanced_light_count, mq_gl_enhanced_lights);
    }
}

/* Restore the compatibility program before any 2-D draw begins. */
MQ_EXPORT void mq_gl_enhanced_end_frame(void) {
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        mq_d3d9_enhanced_end_frame();
        return;
    }
    if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_vulkan_enhanced_end_frame();
        return;
    }
    mq_gl_enhanced_draw_kind_value = 0;
    if (mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) mq_gl_use_program_value(0u);
}
/* Select the active OpenGL texture unit. */
MQ_EXPORT void mq_gl_active_texture(mq_i32 unit) {
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return;
    if (!mq_valid_wgl_proc((const void *)mq_gl_active_texture_value)) return;
    mq_gl_active_texture_value(0x84C0u /* GL_TEXTURE0 */ + (mq_u32)(unit > 0 ? 1 : 0));
}
/* Update the current immediate-mode vertex attributes. */
MQ_EXPORT void mq_gl_multi_tex_coord2(mq_i32 unit, mq_u32 s_bits, mq_u32 t_bits) {
    mq_i32 index = unit > 0 ? 1 : 0;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) return;
    if (!mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value)) return;
    mq_static_geometry_multi_s[index] = mq_bits_to_float(s_bits);
    mq_static_geometry_multi_t[index] = mq_bits_to_float(t_bits);
    mq_gl_multi_tex_coord2f_value(
        0x84C0u /* GL_TEXTURE0 */ + (mq_u32)index,
        mq_static_geometry_multi_s[index], mq_static_geometry_multi_t[index]
    );
}

/*
 * Execute one MiniLang-prepared alias-model frame as a single bridge call.
 * MiniLang remains responsible for pose selection, strip/fan construction,
 * lighting and transforms.  The bridge only decodes the compact OpenGL
 * command stream and emits the same fixed-function calls that the scalar ABI
 * would otherwise perform hundreds of times per model.
 *
 * Stream: repeated { i32 signed_count; count *
 *   { u32 s_bits; u32 t_bits; u8 x,y,z,normal } }, terminated by count 0.
 */
static mq_i32 mq_alias_stream_valid(const mq_u8 *data, mq_u32 byte_count) {
    mq_u32 offset = 0u;
    while (offset + 4u <= byte_count) {
        mq_u32 raw_count =
            (mq_u32)data[offset] |
            ((mq_u32)data[offset + 1u] << 8) |
            ((mq_u32)data[offset + 2u] << 16) |
            ((mq_u32)data[offset + 3u] << 24);
        mq_i32 signed_count = (mq_i32)raw_count;
        mq_u32 count;
        offset += 4u;
        if (signed_count == 0) return 1;
        if (signed_count == (-2147483647 - 1)) return 0;
        count = signed_count < 0 ? (mq_u32)(-signed_count) : (mq_u32)signed_count;
        if (count > (byte_count - offset) / 12u) return 0;
        offset += count * 12u;
    }
    return 0;
}

/* Manage cached native geometry for the renderer fast path. */
static void mq_alias_hash_byte(mq_u8 value, mq_u64 *hash, mq_u64 *signature) {
    *hash = (*hash ^ value) * 1099511628211ull;
    *signature ^= (mq_u64)value + 0x9e3779b97f4a7c15ull + (*signature << 6) + (*signature >> 2);
}

/* Manage cached native geometry for the renderer fast path. */
static mq_i32 mq_alias_build_triangles(
    const mq_u8 *data,
    mq_u32 byte_count,
    const mq_u8 *shade_dots,
    mq_u32 shade_dot_count,
    float shade_light,
    mq_u32 *vertex_count_out,
    mq_i32 *triangle_count_out
) {
    mq_u32 offset = 0u;
    mq_u32 output_count = 0u;
    mq_i32 triangle_count = 0;
    while (offset + 4u <= byte_count) {
        mq_u32 raw_count =
            (mq_u32)data[offset] |
            ((mq_u32)data[offset + 1u] << 8) |
            ((mq_u32)data[offset + 2u] << 16) |
            ((mq_u32)data[offset + 3u] << 24);
        mq_i32 signed_count = (mq_i32)raw_count;
        mq_u32 count;
        mq_u32 vertex;
        mq_u32 triangle;
        offset += 4u;
        if (signed_count == 0) {
            *vertex_count_out = output_count;
            *triangle_count_out = triangle_count;
            return output_count > 0u;
        }
        if (signed_count == (-2147483647 - 1)) return 0;
        count = signed_count < 0 ? (mq_u32)(-signed_count) : (mq_u32)signed_count;
        if (count < 3u || count > MQ_ALIAS_COMMAND_VERTICES ||
            count > (byte_count - offset) / 12u ||
            (count - 2u) * 3u > MQ_ALIAS_TRIANGLE_VERTICES - output_count) return 0;
        for (vertex = 0u; vertex < count; ++vertex) {
            mq_u32 s_bits =
                (mq_u32)data[offset] |
                ((mq_u32)data[offset + 1u] << 8) |
                ((mq_u32)data[offset + 2u] << 16) |
                ((mq_u32)data[offset + 3u] << 24);
            mq_u32 t_bits =
                (mq_u32)data[offset + 4u] |
                ((mq_u32)data[offset + 5u] << 8) |
                ((mq_u32)data[offset + 6u] << 16) |
                ((mq_u32)data[offset + 7u] << 24);
            mq_u32 normal = data[offset + 11u];
            float light = shade_light;
            mq_i32 color_value;
            mq_alias_vertex_t *item = &mq_alias_command_vertices[vertex];
            if (normal < shade_dot_count) {
                mq_u32 dot_offset = normal * 4u;
                mq_u32 dot_bits =
                    (mq_u32)shade_dots[dot_offset] |
                    ((mq_u32)shade_dots[dot_offset + 1u] << 8) |
                    ((mq_u32)shade_dots[dot_offset + 2u] << 16) |
                    ((mq_u32)shade_dots[dot_offset + 3u] << 24);
                light = mq_bits_to_float(dot_bits) * shade_light;
            }
            color_value = (mq_i32)(light * 255.0f);
            if (color_value < 0) color_value = 0;
            if (color_value > 255) color_value = 255;
            item->s = mq_bits_to_float(s_bits);
            item->t = mq_bits_to_float(t_bits);
            item->r = (mq_u8)color_value;
            item->g = (mq_u8)color_value;
            item->b = (mq_u8)color_value;
            item->a = 255u;
            item->x = (float)data[offset + 8u];
            item->y = (float)data[offset + 9u];
            item->z = (float)data[offset + 10u];
            offset += 12u;
        }
        for (triangle = 0u; triangle < count - 2u; ++triangle) {
            mq_u32 indices[3];
            mq_u32 corner;
            if (signed_count < 0) {
                indices[0] = 0u;
                indices[1] = triangle + 1u;
                indices[2] = triangle + 2u;
            } else if ((triangle & 1u) == 0u) {
                indices[0] = triangle;
                indices[1] = triangle + 1u;
                indices[2] = triangle + 2u;
            } else {
                indices[0] = triangle + 1u;
                indices[1] = triangle;
                indices[2] = triangle + 2u;
            }
            for (corner = 0u; corner < 3u; ++corner) {
                mq_alias_triangle_vertices[output_count] = mq_alias_command_vertices[indices[corner]];
                output_count += 1u;
            }
            triangle_count += 1;
        }
    }
    return 0;
}

/* Expand two matching MDL command streams while interpolating packed poses. */
static mq_i32 mq_alias_build_triangles_lerp(
    const mq_u8 *previous_data, mq_u32 previous_byte_count,
    const mq_u8 *current_data, mq_u32 current_byte_count,
    float fraction,
    const mq_u8 *shade_dots, mq_u32 shade_dot_count, float shade_light,
    mq_u32 *vertex_count_out, mq_i32 *triangle_count_out
) {
    mq_u32 previous_offset = 0u;
    mq_u32 current_offset = 0u;
    mq_u32 output_count = 0u;
    mq_i32 triangle_count = 0;
    if (fraction < 0.0f) fraction = 0.0f;
    if (fraction > 1.0f) fraction = 1.0f;
    while (previous_offset + 4u <= previous_byte_count && current_offset + 4u <= current_byte_count) {
        mq_i32 previous_count;
        mq_i32 current_count;
        mq_u32 count;
        mq_u32 vertex;
        mq_u32 triangle;
        memcpy(&previous_count, previous_data + previous_offset, 4u);
        memcpy(&current_count, current_data + current_offset, 4u);
        previous_offset += 4u;
        current_offset += 4u;
        if (previous_count != current_count) return 0;
        if (current_count == 0) {
            *vertex_count_out = output_count;
            *triangle_count_out = triangle_count;
            return output_count > 0u;
        }
        if (current_count == (-2147483647 - 1)) return 0;
        count = current_count < 0 ? (mq_u32)(-current_count) : (mq_u32)current_count;
        if (count < 3u || count > MQ_ALIAS_COMMAND_VERTICES ||
            count > (previous_byte_count - previous_offset) / 12u ||
            count > (current_byte_count - current_offset) / 12u ||
            (count - 2u) * 3u > MQ_ALIAS_TRIANGLE_VERTICES - output_count) return 0;
        for (vertex = 0u; vertex < count; ++vertex) {
            const mq_u8 *previous = previous_data + previous_offset;
            const mq_u8 *current = current_data + current_offset;
            mq_u32 s_bits;
            mq_u32 t_bits;
            mq_u32 normal = current[11u];
            float light = shade_light;
            mq_i32 color_value;
            mq_alias_vertex_t *item = &mq_alias_command_vertices[vertex];
            memcpy(&s_bits, current, 4u);
            memcpy(&t_bits, current + 4u, 4u);
            if (normal < shade_dot_count) {
                mq_u32 dot_bits;
                memcpy(&dot_bits, shade_dots + normal * 4u, 4u);
                light = mq_bits_to_float(dot_bits) * shade_light;
            }
            color_value = (mq_i32)(light * 255.0f);
            if (color_value < 0) color_value = 0;
            if (color_value > 255) color_value = 255;
            item->s = mq_bits_to_float(s_bits);
            item->t = mq_bits_to_float(t_bits);
            item->r = item->g = item->b = (mq_u8)color_value;
            item->a = 255u;
            item->x = (float)previous[8u] + ((float)current[8u] - (float)previous[8u]) * fraction;
            item->y = (float)previous[9u] + ((float)current[9u] - (float)previous[9u]) * fraction;
            item->z = (float)previous[10u] + ((float)current[10u] - (float)previous[10u]) * fraction;
            previous_offset += 12u;
            current_offset += 12u;
        }
        for (triangle = 0u; triangle < count - 2u; ++triangle) {
            mq_u32 indices[3];
            mq_u32 corner;
            if (current_count < 0) {
                indices[0] = 0u; indices[1] = triangle + 1u; indices[2] = triangle + 2u;
            } else if ((triangle & 1u) == 0u) {
                indices[0] = triangle; indices[1] = triangle + 1u; indices[2] = triangle + 2u;
            } else {
                indices[0] = triangle + 1u; indices[1] = triangle; indices[2] = triangle + 2u;
            }
            for (corner = 0u; corner < 3u; ++corner) {
                mq_alias_triangle_vertices[output_count++] = mq_alias_command_vertices[indices[corner]];
            }
            triangle_count += 1;
        }
    }
    return 0;
}

/* Submit a transient interpolated alias stream on every supported backend. */
static mq_i32 mq_gl_draw_alias_batch_lerp(
    const mq_u8 *previous_data, mq_u32 previous_byte_count,
    const mq_u8 *current_data, mq_u32 current_byte_count, float fraction,
    const mq_u8 *shade_dots, mq_u32 shade_dot_count, float shade_light
) {
    mq_u32 vertex_count = 0u;
    mq_i32 triangle_count = 0;
    if (previous_data == MQ_NULL || current_data == MQ_NULL || shade_dots == MQ_NULL) return 0;
    if (!mq_alias_build_triangles_lerp(
            previous_data, previous_byte_count, current_data, current_byte_count,
            fraction, shade_dots, shade_dot_count, shade_light,
            &vertex_count, &triangle_count)) return 0;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (mq_d3d9_draw_interleaved_t2f_c4ub_v3f(mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (mq_vulkan_draw_interleaved_t2f_c4ub_v3f(mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else {
        if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) mq_gl_client_active_texture_value(0x84C0u);
        if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) mq_gl_bind_buffer_value(0x8892u, 0u);
        glInterleavedArrays(0x2A29u /* GL_T2F_C4UB_V3F */, (mq_i32)sizeof(mq_alias_vertex_t), mq_alias_triangle_vertices);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u);
        glDisableClientState(0x8076u);
        glDisableClientState(0x8074u);
    }
    return triangle_count;
}

/* Manage cached native geometry for the renderer fast path. */
static void mq_alias_draw_vbo(mq_u32 cache_index) {
    if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
        mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
    }
    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, mq_alias_vbo_id[cache_index]);
    glInterleavedArrays(0x2A29u /* GL_T2F_C4UB_V3F */, (mq_i32)sizeof(mq_alias_vertex_t), (const void *)0);
    glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)mq_alias_vbo_vertices[cache_index]);
    glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
    glDisableClientState(0x8076u /* GL_COLOR_ARRAY */);
    glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
}

/* Decode and draw all GLQuake particles through one MiniLang/native crossing. */
static mq_i32 mq_gl_draw_particle_batch_internal(
    const mq_u8 *data,
    mq_u32 byte_count,
    mq_u32 view_origin_x_bits,
    mq_u32 view_origin_y_bits,
    mq_u32 view_origin_z_bits,
    mq_u32 view_forward_x_bits,
    mq_u32 view_forward_y_bits,
    mq_u32 view_forward_z_bits,
    mq_u32 view_up_x_bits,
    mq_u32 view_up_y_bits,
    mq_u32 view_up_z_bits,
    mq_u32 view_right_x_bits,
    mq_u32 view_right_y_bits,
    mq_u32 view_right_z_bits,
    mq_i32 styled
) {
    mq_u32 particle_count;
    mq_u32 particle;
    mq_u32 vertex_count;
    float view_origin_x = mq_bits_to_float(view_origin_x_bits);
    float view_origin_y = mq_bits_to_float(view_origin_y_bits);
    float view_origin_z = mq_bits_to_float(view_origin_z_bits);
    float view_forward_x = mq_bits_to_float(view_forward_x_bits);
    float view_forward_y = mq_bits_to_float(view_forward_y_bits);
    float view_forward_z = mq_bits_to_float(view_forward_z_bits);
    /* Classic GLQuake draws a right triangle and deliberately grows it with
     * distance. Enhanced particles instead use a compact constant-world-size
     * quad, so perspective projection naturally makes distant effects smaller. */
    float axis_size = styled ? MQ_ENHANCED_PARTICLE_HALF_SIZE : MQ_CLASSIC_PARTICLE_AXIS_SIZE;
    float scaled_up_x = mq_bits_to_float(view_up_x_bits) * axis_size;
    float scaled_up_y = mq_bits_to_float(view_up_y_bits) * axis_size;
    float scaled_up_z = mq_bits_to_float(view_up_z_bits) * axis_size;
    float scaled_right_x = mq_bits_to_float(view_right_x_bits) * axis_size;
    float scaled_right_y = mq_bits_to_float(view_right_y_bits) * axis_size;
    float scaled_right_z = mq_bits_to_float(view_right_z_bits) * axis_size;
    if (data == MQ_NULL || byte_count == 0u || byte_count % MQ_PARTICLE_RECORD_BYTES != 0u) return 0;
    particle_count = byte_count / MQ_PARTICLE_RECORD_BYTES;
    if (particle_count > MQ_PARTICLE_BATCH_MAX) return 0;
    for (particle = 0u; particle < particle_count; ++particle) {
        const mq_u8 *record = data + particle * MQ_PARTICLE_RECORD_BYTES;
        mq_u32 x_bits = (mq_u32)record[4] |
            ((mq_u32)record[5] << 8) |
            ((mq_u32)record[6] << 16) |
            ((mq_u32)record[7] << 24);
        mq_u32 y_bits = (mq_u32)record[8] |
            ((mq_u32)record[9] << 8) |
            ((mq_u32)record[10] << 16) |
            ((mq_u32)record[11] << 24);
        mq_u32 z_bits = (mq_u32)record[12] |
            ((mq_u32)record[13] << 8) |
            ((mq_u32)record[14] << 16) |
            ((mq_u32)record[15] << 24);
        float origin_x = mq_bits_to_float(x_bits);
        float origin_y = mq_bits_to_float(y_bits);
        float origin_z = mq_bits_to_float(z_bits);
        float distance = (origin_x - view_origin_x) * view_forward_x +
            (origin_y - view_origin_y) * view_forward_y +
            (origin_z - view_origin_z) * view_forward_z;
        float scale = 1.0f;
        if (!styled && distance >= 20.0f) scale = 1.0f + distance * 0.004f;
        mq_u32 vertices_per_particle = styled ? 6u : 3u;
        mq_u32 vertex;
        for (vertex = 0u; vertex < vertices_per_particle; ++vertex) {
            mq_alias_vertex_t *output = &mq_particle_vertices[particle * vertices_per_particle + vertex];
            output->r = record[0];
            output->g = record[1];
            output->b = record[2];
            output->a = record[3];
            if (styled) {
                static const mq_u8 corners[6] = {0u, 1u, 2u, 0u, 2u, 3u};
                mq_u32 corner = corners[vertex];
                float right_sign = (corner == 1u || corner == 2u) ? 1.0f : -1.0f;
                float up_sign = corner >= 2u ? 1.0f : -1.0f;
                output->s = right_sign > 0.0f ? 1.0f : 0.0f;
                output->t = up_sign > 0.0f ? 0.0f : 1.0f;
                output->x = origin_x + scale * (scaled_right_x * right_sign + scaled_up_x * up_sign);
                output->y = origin_y + scale * (scaled_right_y * right_sign + scaled_up_y * up_sign);
                output->z = origin_z + scale * (scaled_right_z * right_sign + scaled_up_z * up_sign);
            } else {
                output->s = vertex == 1u ? 1.0f : 0.0f;
                output->t = vertex == 2u ? 1.0f : 0.0f;
                output->x = origin_x;
                output->y = origin_y;
                output->z = origin_z;
                if (vertex == 1u) {
                    output->x += scale * scaled_up_x;
                    output->y += scale * scaled_up_y;
                    output->z += scale * scaled_up_z;
                } else if (vertex == 2u) {
                    output->x += scale * scaled_right_x;
                    output->y += scale * scaled_right_y;
                    output->z += scale * scaled_right_z;
                }
            }
        }
    }
    vertex_count = particle_count * (styled ? 6u : 3u);
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (mq_d3d9_draw_interleaved_t2f_c4ub_v3f(mq_particle_vertices, vertex_count) <= 0) return 0;
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (mq_vulkan_draw_interleaved_t2f_c4ub_v3f(mq_particle_vertices, vertex_count) <= 0) return 0;
    } else {
        if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
            mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        }
        if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
        }
        glInterleavedArrays(0x2A29u /* GL_T2F_C4UB_V3F */, (mq_i32)sizeof(mq_alias_vertex_t), mq_particle_vertices);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        glDisableClientState(0x8076u /* GL_COLOR_ARRAY */);
        glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    }
    return (mq_i32)particle_count;
}

/* Decode and draw original GLQuake triangular particles. */
MQ_EXPORT mq_i32 mq_gl_draw_particle_batch(
    const mq_u8 *data, mq_u32 byte_count,
    mq_u32 view_origin_x_bits, mq_u32 view_origin_y_bits, mq_u32 view_origin_z_bits,
    mq_u32 view_forward_x_bits, mq_u32 view_forward_y_bits, mq_u32 view_forward_z_bits,
    mq_u32 view_up_x_bits, mq_u32 view_up_y_bits, mq_u32 view_up_z_bits,
    mq_u32 view_right_x_bits, mq_u32 view_right_y_bits, mq_u32 view_right_z_bits
) {
    return mq_gl_draw_particle_batch_internal(
        data, byte_count,
        view_origin_x_bits, view_origin_y_bits, view_origin_z_bits,
        view_forward_x_bits, view_forward_y_bits, view_forward_z_bits,
        view_up_x_bits, view_up_y_bits, view_up_z_bits,
        view_right_x_bits, view_right_y_bits, view_right_z_bits, 0);
}

/* Decode and draw centered soft particle quads for the Enhanced profile. */
MQ_EXPORT mq_i32 mq_gl_draw_particle_batch_styled(
    const mq_u8 *data, mq_u32 byte_count,
    mq_u32 view_origin_x_bits, mq_u32 view_origin_y_bits, mq_u32 view_origin_z_bits,
    mq_u32 view_forward_x_bits, mq_u32 view_forward_y_bits, mq_u32 view_forward_z_bits,
    mq_u32 view_up_x_bits, mq_u32 view_up_y_bits, mq_u32 view_up_z_bits,
    mq_u32 view_right_x_bits, mq_u32 view_right_y_bits, mq_u32 view_right_z_bits
) {
    return mq_gl_draw_particle_batch_internal(
        data, byte_count,
        view_origin_x_bits, view_origin_y_bits, view_origin_z_bits,
        view_forward_x_bits, view_forward_y_bits, view_forward_z_bits,
        view_up_x_bits, view_up_y_bits, view_up_z_bits,
        view_right_x_bits, view_right_y_bits, view_right_z_bits, 1);
}

/* Read one little-endian MD2 header word without unaligned pointer casts. */
static mq_u32 mq_md2_u32(const mq_u8 *data, mq_u32 offset) {
    mq_u32 value;
    memcpy(&value, data + offset, 4u);
    return value;
}

/* Read one little-endian MD2 frame float without unaligned pointer casts. */
static float mq_md2_f32(const mq_u8 *data, mq_u32 offset) {
    float value;
    memcpy(&value, data + offset, 4u);
    return value;
}

/* Expand original MD2 frames and indexed triangles directly in native code.
 * MiniLang retains the validated source bytes; animation no longer allocates
 * or bit-packs an expanded triangle buffer in the render loop. */
static mq_i32 mq_md2_expand_geometry(
    const mq_u8 *data,
    mq_u32 skin_width,
    mq_u32 skin_height,
    mq_u32 frame_size,
    mq_u32 num_xyz,
    mq_u32 num_st,
    mq_u32 num_tris,
    mq_u32 ofs_st,
    mq_u32 ofs_tris,
    mq_u32 ofs_frames,
    mq_u32 frame_index,
    mq_u32 old_frame_index,
    float back_lerp,
    const mq_u8 *normal_vectors,
    mq_u32 normal_count
) {
    mq_u32 current_frame = ofs_frames + frame_index * frame_size;
    mq_u32 previous_frame = ofs_frames + old_frame_index * frame_size;
    float current_scale[3];
    float current_translate[3];
    float previous_scale[3];
    float previous_translate[3];
    mq_u32 triangle;
    mq_u32 axis;
    mq_u32 output = 0u;
    (void)back_lerp;
    for (axis = 0u; axis < 3u; ++axis) {
        current_scale[axis] = mq_md2_f32(data, current_frame + axis * 4u);
        current_translate[axis] = mq_md2_f32(data, current_frame + 12u + axis * 4u);
        previous_scale[axis] = mq_md2_f32(data, previous_frame + axis * 4u);
        previous_translate[axis] = mq_md2_f32(data, previous_frame + 12u + axis * 4u);
    }
    for (triangle = 0u; triangle < num_tris; ++triangle) {
        mq_u32 triangle_at = ofs_tris + triangle * 12u;
        mq_u32 corner;
        for (corner = 0u; corner < 3u; ++corner) {
            mq_u16 vertex_index;
            mq_u16 texcoord_index;
            mq_i16 texture_s;
            mq_i16 texture_t;
            mq_u32 current_vertex;
            mq_u32 previous_vertex;
            mq_u32 normal;
            mq_md2_geometry_vertex_t *destination =
                &mq_md2_geometry_vertices[output];
            memcpy(&vertex_index, data + triangle_at + corner * 2u, 2u);
            memcpy(&texcoord_index,
                data + triangle_at + 6u + corner * 2u, 2u);
            if ((mq_u32)vertex_index >= num_xyz ||
                (mq_u32)texcoord_index >= num_st) return 0;
            memcpy(&texture_s, data + ofs_st + (mq_u32)texcoord_index * 4u, 2u);
            memcpy(&texture_t,
                data + ofs_st + (mq_u32)texcoord_index * 4u + 2u, 2u);
            current_vertex = current_frame + 40u + (mq_u32)vertex_index * 4u;
            previous_vertex = previous_frame + 40u + (mq_u32)vertex_index * 4u;
            normal = data[current_vertex + 3u];
            if (normal >= normal_count) return 0;
            destination->s = (float)texture_s / (float)skin_width;
            destination->t = (float)texture_t / (float)skin_height;
            destination->x = (float)data[current_vertex] * current_scale[0] +
                current_translate[0];
            destination->y = (float)data[current_vertex + 1u] *
                current_scale[1] + current_translate[1];
            destination->z = (float)data[current_vertex + 2u] *
                current_scale[2] + current_translate[2];
            destination->old_x = (float)data[previous_vertex] *
                previous_scale[0] + previous_translate[0];
            destination->old_y = (float)data[previous_vertex + 1u] *
                previous_scale[1] + previous_translate[1];
            destination->old_z = (float)data[previous_vertex + 2u] *
                previous_scale[2] + previous_translate[2];
            mq_md2_normal_indices[output] = (mq_u8)normal;
            memcpy(&mq_alias_rgb_lightcoords[output * 3u],
                normal_vectors + normal * 12u, 12u);
            output += 1u;
        }
    }
    return output == num_tris * 3u;
}

/* Draw validated original MD2 bytes with native interpolation, cached static
 * animation geometry and the original per-vertex colored shadelight. */
MQ_EXPORT mq_i32 mq_gl_draw_md2_rgb(
    const mq_u8 *data,
    mq_u32 byte_count,
    mq_u32 frame_index,
    mq_u32 old_frame_index,
    mq_u32 back_lerp_bits,
    const mq_u8 *shade_dots,
    mq_u32 shade_dot_count,
    const mq_u8 *normal_vectors,
    mq_u32 normal_count,
    mq_u64 geometry_key,
    mq_u32 geometry_state,
    mq_u32 shade_state,
    mq_u32 shade_red_bits,
    mq_u32 shade_green_bits,
    mq_u32 shade_blue_bits,
    mq_u32 alpha_value
) {
    const mq_u32 md2_ident = 844121161u;
    const mq_u32 md2_version = 8u;
    mq_u32 skin_width;
    mq_u32 skin_height;
    mq_u32 frame_size;
    mq_u32 num_xyz;
    mq_u32 num_st;
    mq_u32 num_tris;
    mq_u32 num_frames;
    mq_u32 ofs_st;
    mq_u32 ofs_tris;
    mq_u32 ofs_frames;
    mq_u32 ofs_end;
    mq_u32 vertex_count;
    mq_u32 vertex;
    mq_i32 lookup_path;
    float back_lerp = mq_bits_to_float(back_lerp_bits);
    float shade_red = mq_bits_to_float(shade_red_bits);
    float shade_green = mq_bits_to_float(shade_green_bits);
    float shade_blue = mq_bits_to_float(shade_blue_bits);
    if (!data || !shade_dots || !normal_vectors || byte_count < 68u) return 0;
    if (shade_dot_count != 162u || normal_count != 162u) return 0;
    if (mq_md2_u32(data, 0u) != md2_ident ||
        mq_md2_u32(data, 4u) != md2_version) return 0;
    skin_width = mq_md2_u32(data, 8u);
    skin_height = mq_md2_u32(data, 12u);
    frame_size = mq_md2_u32(data, 16u);
    num_xyz = mq_md2_u32(data, 24u);
    num_st = mq_md2_u32(data, 28u);
    num_tris = mq_md2_u32(data, 32u);
    num_frames = mq_md2_u32(data, 40u);
    ofs_st = mq_md2_u32(data, 48u);
    ofs_tris = mq_md2_u32(data, 52u);
    ofs_frames = mq_md2_u32(data, 56u);
    ofs_end = mq_md2_u32(data, 64u);
    if (skin_width == 0u || skin_height == 0u || num_xyz == 0u ||
        num_st == 0u || num_tris == 0u || num_frames == 0u ||
        num_xyz > 2048u || num_tris > 4096u || num_frames > 512u ||
        frame_index >= num_frames || old_frame_index >= num_frames ||
        !(back_lerp >= 0.0f && back_lerp <= 1.0f)) return 0;
    vertex_count = num_tris * 3u;
    if (vertex_count > MQ_ALIAS_TRIANGLE_VERTICES ||
        frame_size < 40u + num_xyz * 4u || ofs_end > byte_count ||
        (mq_u64)ofs_st + (mq_u64)num_st * 4u > (mq_u64)ofs_end ||
        (mq_u64)ofs_tris + (mq_u64)num_tris * 12u > (mq_u64)ofs_end ||
        (mq_u64)ofs_frames + (mq_u64)num_frames * frame_size >
            (mq_u64)ofs_end) return 0;
    lookup_path = mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_delete_buffers_value) &&
        mq_gl_create_alias_program();

    if (lookup_path) {
        mq_u32 slot = mq_alias_rgb_geometry_slot(geometry_key, geometry_state);
        mq_u32 geometry_vbo = mq_alias_rgb_geometry_vbo[slot];
        mq_u32 lightcoord_vbo = mq_alias_rgb_lightcoord_vbo[slot];
        if (geometry_vbo == 0u || lightcoord_vbo == 0u ||
            mq_alias_rgb_geometry_key[slot] != geometry_key ||
            mq_alias_rgb_geometry_state[slot] != geometry_state ||
            mq_alias_rgb_geometry_bytes[slot] != byte_count) {
            if (geometry_vbo != 0u) {
                mq_gl_delete_buffers_value(1, &geometry_vbo);
                geometry_vbo = 0u;
            }
            if (lightcoord_vbo != 0u) {
                mq_gl_delete_buffers_value(1, &lightcoord_vbo);
                lightcoord_vbo = 0u;
            }
            mq_alias_rgb_geometry_vbo[slot] = 0u;
            mq_alias_rgb_lightcoord_vbo[slot] = 0u;
            if (!mq_md2_expand_geometry(
                    data, skin_width, skin_height, frame_size, num_xyz,
                    num_st, num_tris, ofs_st, ofs_tris, ofs_frames,
                    frame_index, old_frame_index, back_lerp,
                    normal_vectors, normal_count)) return 0;
            mq_gl_gen_buffers_value(1, &geometry_vbo);
            mq_gl_gen_buffers_value(1, &lightcoord_vbo);
            if (geometry_vbo == 0u || lightcoord_vbo == 0u) {
                if (geometry_vbo != 0u) {
                    mq_gl_delete_buffers_value(1, &geometry_vbo);
                }
                if (lightcoord_vbo != 0u) {
                    mq_gl_delete_buffers_value(1, &lightcoord_vbo);
                }
                return 0;
            }
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, geometry_vbo);
            mq_gl_buffer_data_value(
                0x8892u /* GL_ARRAY_BUFFER */,
                (mq_i64)(vertex_count * sizeof(mq_md2_geometry_vertex_t)),
                mq_md2_geometry_vertices,
                0x88E4u /* GL_STATIC_DRAW */
            );
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, lightcoord_vbo);
            mq_gl_buffer_data_value(
                0x8892u /* GL_ARRAY_BUFFER */,
                (mq_i64)(vertex_count * 3u * sizeof(float)),
                mq_alias_rgb_lightcoords,
                0x88E4u /* GL_STATIC_DRAW */
            );
            mq_alias_rgb_geometry_key[slot] = geometry_key;
            mq_alias_rgb_geometry_state[slot] = geometry_state;
            mq_alias_rgb_geometry_bytes[slot] = byte_count;
            mq_alias_rgb_geometry_vbo[slot] = geometry_vbo;
            mq_alias_rgb_lightcoord_vbo[slot] = lightcoord_vbo;
            mq_alias_rgb_geometry_vertices[slot] = vertex_count;
        }
        if (!mq_gl_alias_program_active) {
            mq_gl_use_program_value(mq_gl_alias_program);
            mq_gl_alias_program_active = 1;
        }
        if (mq_gl_alias_state_location >= 0) {
            mq_gl_vertex_attrib_4f_value((mq_u32)mq_gl_alias_state_location,
                shade_red, shade_green, shade_blue,
                (float)(shade_state & 15u));
        }

        glEnableClientState(0x8074u /* GL_VERTEX_ARRAY */);
        mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, geometry_vbo);
        glTexCoordPointer(2, 0x1406u /* GL_FLOAT */,
            (mq_i32)sizeof(mq_md2_geometry_vertex_t), (const void *)0);
        glVertexPointer(3, 0x1406u /* GL_FLOAT */,
            (mq_i32)sizeof(mq_md2_geometry_vertex_t), (const void *)8);
        mq_gl_client_active_texture_value(0x84C1u /* GL_TEXTURE1 */);
        glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, lightcoord_vbo);
        glTexCoordPointer(3, 0x1406u /* GL_FLOAT */, 0, (const void *)0);
        mq_gl_client_active_texture_value(0x84C2u /* GL_TEXTURE2 */);
        glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, geometry_vbo);
        glTexCoordPointer(3, 0x1406u /* GL_FLOAT */,
            (mq_i32)sizeof(mq_md2_geometry_vertex_t), (const void *)20);
        mq_gl_multi_tex_coord2f_value(0x84C3u /* GL_TEXTURE3 */,
            back_lerp, 0.0f);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_client_active_texture_value(0x84C1u /* GL_TEXTURE1 */);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
        return (mq_i32)(vertex_count / 3u);
    }

    if (!mq_md2_expand_geometry(
            data, skin_width, skin_height, frame_size, num_xyz, num_st,
            num_tris, ofs_st, ofs_tris, ofs_frames, frame_index,
            old_frame_index, back_lerp, normal_vectors, normal_count)) return 0;
    for (vertex = 0u; vertex < vertex_count; ++vertex) {
        const mq_md2_geometry_vertex_t *source = &mq_md2_geometry_vertices[vertex];
        mq_u32 normal = mq_md2_normal_indices[vertex];
        mq_u32 dot_bits;
        float light;
        mq_i32 red;
        mq_i32 green;
        mq_i32 blue;
        mq_alias_vertex_t *output = &mq_alias_triangle_vertices[vertex];
        if (normal >= shade_dot_count) return 0;
        memcpy(&dot_bits, shade_dots + normal * 4u, 4u);
        light = mq_bits_to_float(dot_bits);
        red = (mq_i32)(light * shade_red * 255.0f + 0.5f);
        green = (mq_i32)(light * shade_green * 255.0f + 0.5f);
        blue = (mq_i32)(light * shade_blue * 255.0f + 0.5f);
        if (red < 0) red = 0; else if (red > 255) red = 255;
        if (green < 0) green = 0; else if (green > 255) green = 255;
        if (blue < 0) blue = 0; else if (blue > 255) blue = 255;
        output->s = source->s;
        output->t = source->t;
        output->x = source->x * (1.0f - back_lerp) +
            source->old_x * back_lerp;
        output->y = source->y * (1.0f - back_lerp) +
            source->old_y * back_lerp;
        output->z = source->z * (1.0f - back_lerp) +
            source->old_z * back_lerp;
        output->r = (mq_u8)red;
        output->g = (mq_u8)green;
        output->b = (mq_u8)blue;
        output->a = (mq_u8)(alpha_value > 255u ? 255u : alpha_value);
    }
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (mq_d3d9_draw_interleaved_t2f_c4ub_v3f(
                mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (mq_vulkan_draw_interleaved_t2f_c4ub_v3f(
                mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else {
        if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
            mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        }
        if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
        }
        glInterleavedArrays(
            0x2A29u /* GL_T2F_C4UB_V3F */,
            (mq_i32)sizeof(mq_alias_vertex_t),
            mq_alias_triangle_vertices
        );
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        glDisableClientState(0x8076u /* GL_COLOR_ARRAY */);
        glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    }
    return (mq_i32)(vertex_count / 3u);
}

/* Draw the Quake II 3.19 planar alias shadow from the same quantized MD2
 * animation state as the colored model. Modern OpenGL reuses its geometry
 * VBO; compatibility backends project one bounded native scratch buffer. */
MQ_EXPORT mq_i32 mq_gl_draw_md2_shadow(
    const mq_u8 *data,
    mq_u32 byte_count,
    mq_u32 frame_index,
    mq_u32 old_frame_index,
    mq_u32 back_lerp_bits,
    const mq_u8 *normal_vectors,
    mq_u32 normal_count,
    mq_u64 geometry_key,
    mq_u32 geometry_state,
    mq_u32 triangle_count,
    mq_u32 shade_x_bits,
    mq_u32 shade_y_bits,
    mq_u32 light_height_bits
) {
    const mq_u32 md2_ident = 844121161u;
    const mq_u32 md2_version = 8u;
    mq_u32 skin_width;
    mq_u32 skin_height;
    mq_u32 frame_size;
    mq_u32 num_xyz;
    mq_u32 num_st;
    mq_u32 num_tris;
    mq_u32 num_frames;
    mq_u32 ofs_st;
    mq_u32 ofs_tris;
    mq_u32 ofs_frames;
    mq_u32 ofs_end;
    mq_u32 vertex_count;
    mq_u32 vertex;
    mq_u32 slot;
    mq_u32 error_guard;
    mq_i32 lookup_path;
    float back_lerp = mq_bits_to_float(back_lerp_bits);
    float shade_x = mq_bits_to_float(shade_x_bits);
    float shade_y = mq_bits_to_float(shade_y_bits);
    float light_height = mq_bits_to_float(light_height_bits);
    if (!data || !normal_vectors || byte_count < 68u || normal_count != 162u) return 0;
    if (mq_md2_u32(data, 0u) != md2_ident ||
        mq_md2_u32(data, 4u) != md2_version) return 0;
    skin_width = mq_md2_u32(data, 8u);
    skin_height = mq_md2_u32(data, 12u);
    frame_size = mq_md2_u32(data, 16u);
    num_xyz = mq_md2_u32(data, 24u);
    num_st = mq_md2_u32(data, 28u);
    num_tris = mq_md2_u32(data, 32u);
    num_frames = mq_md2_u32(data, 40u);
    ofs_st = mq_md2_u32(data, 48u);
    ofs_tris = mq_md2_u32(data, 52u);
    ofs_frames = mq_md2_u32(data, 56u);
    ofs_end = mq_md2_u32(data, 64u);
    if (skin_width == 0u || skin_height == 0u || num_xyz == 0u ||
        num_st == 0u || num_tris == 0u || num_frames == 0u ||
        num_xyz > 2048u || num_tris > 4096u || num_frames > 512u ||
        triangle_count != num_tris || frame_index >= num_frames ||
        old_frame_index >= num_frames ||
        !(back_lerp >= 0.0f && back_lerp <= 1.0f) ||
        !(light_height >= -2048.0f && light_height <= 2048.0f)) return 0;
    vertex_count = num_tris * 3u;
    if (vertex_count > MQ_ALIAS_TRIANGLE_VERTICES ||
        frame_size < 40u + num_xyz * 4u || ofs_end > byte_count ||
        (mq_u64)ofs_st + (mq_u64)num_st * 4u > (mq_u64)ofs_end ||
        (mq_u64)ofs_tris + (mq_u64)num_tris * 12u > (mq_u64)ofs_end ||
        (mq_u64)ofs_frames + (mq_u64)num_frames * frame_size >
            (mq_u64)ofs_end) return 0;

    if (mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_gl_alias_program_active &&
        mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) {
        mq_gl_use_program_value(0u);
        mq_gl_alias_program_active = 0;
    }
    lookup_path = mq_render_backend_value == MQ_RENDER_OPENGL &&
        mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_delete_buffers_value) &&
        mq_gl_create_md2_shadow_program();
    slot = mq_alias_rgb_geometry_slot(geometry_key, geometry_state);
    if (lookup_path) {
        mq_u32 geometry_vbo = mq_alias_rgb_geometry_vbo[slot];
        mq_u32 lightcoord_vbo = mq_alias_rgb_lightcoord_vbo[slot];
        if (geometry_vbo == 0u || lightcoord_vbo == 0u ||
            mq_alias_rgb_geometry_key[slot] != geometry_key ||
            mq_alias_rgb_geometry_state[slot] != geometry_state ||
            mq_alias_rgb_geometry_bytes[slot] != byte_count ||
            mq_alias_rgb_geometry_vertices[slot] != vertex_count) {
            if (geometry_vbo != 0u) mq_gl_delete_buffers_value(1, &geometry_vbo);
            if (lightcoord_vbo != 0u) mq_gl_delete_buffers_value(1, &lightcoord_vbo);
            geometry_vbo = 0u;
            lightcoord_vbo = 0u;
            mq_alias_rgb_geometry_vbo[slot] = 0u;
            mq_alias_rgb_lightcoord_vbo[slot] = 0u;
            if (!mq_md2_expand_geometry(
                    data, skin_width, skin_height, frame_size, num_xyz,
                    num_st, num_tris, ofs_st, ofs_tris, ofs_frames,
                    frame_index, old_frame_index, back_lerp,
                    normal_vectors, normal_count)) return 0;
            mq_gl_gen_buffers_value(1, &geometry_vbo);
            mq_gl_gen_buffers_value(1, &lightcoord_vbo);
            if (geometry_vbo == 0u || lightcoord_vbo == 0u) {
                if (geometry_vbo != 0u) mq_gl_delete_buffers_value(1, &geometry_vbo);
                if (lightcoord_vbo != 0u) mq_gl_delete_buffers_value(1, &lightcoord_vbo);
                return 0;
            }
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, geometry_vbo);
            mq_gl_buffer_data_value(
                0x8892u /* GL_ARRAY_BUFFER */,
                (mq_i64)(vertex_count * sizeof(mq_md2_geometry_vertex_t)),
                mq_md2_geometry_vertices, 0x88E4u /* GL_STATIC_DRAW */);
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, lightcoord_vbo);
            mq_gl_buffer_data_value(
                0x8892u /* GL_ARRAY_BUFFER */,
                (mq_i64)(vertex_count * 3u * sizeof(float)),
                mq_alias_rgb_lightcoords, 0x88E4u /* GL_STATIC_DRAW */);
            mq_alias_rgb_geometry_key[slot] = geometry_key;
            mq_alias_rgb_geometry_state[slot] = geometry_state;
            mq_alias_rgb_geometry_bytes[slot] = byte_count;
            mq_alias_rgb_geometry_vbo[slot] = geometry_vbo;
            mq_alias_rgb_lightcoord_vbo[slot] = lightcoord_vbo;
            mq_alias_rgb_geometry_vertices[slot] = vertex_count;
        }
        for (error_guard = 0u; error_guard < 8u && glGetError() != 0u;
             ++error_guard) {}
        mq_gl_use_program_value(mq_gl_md2_shadow_program);
        if (mq_gl_md2_shadow_state_location >= 0) {
            mq_gl_vertex_attrib_4f_value((mq_u32)mq_gl_md2_shadow_state_location,
                shade_x, shade_y, light_height, mq_gl_md2_shadow_alpha);
        }
        glEnableClientState(0x8074u /* GL_VERTEX_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, geometry_vbo);
        glVertexPointer(3, 0x1406u /* GL_FLOAT */,
            (mq_i32)sizeof(mq_md2_geometry_vertex_t), (const void *)8);
        mq_gl_client_active_texture_value(0x84C2u /* GL_TEXTURE2 */);
        glEnableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        glTexCoordPointer(3, 0x1406u /* GL_FLOAT */,
            (mq_i32)sizeof(mq_md2_geometry_vertex_t), (const void *)20);
        mq_gl_multi_tex_coord2f_value(0x84C3u /* GL_TEXTURE3 */,
            back_lerp, 0.0f);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
        mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
        mq_gl_use_program_value(0u);
        if (glGetError() != 0u) return 0;
        return (mq_i32)num_tris;
    }

    if (!mq_md2_expand_geometry(
            data, skin_width, skin_height, frame_size, num_xyz, num_st,
            num_tris, ofs_st, ofs_tris, ofs_frames, frame_index,
            old_frame_index, back_lerp, normal_vectors, normal_count)) return 0;
    for (vertex = 0u; vertex < vertex_count; ++vertex) {
        const mq_md2_geometry_vertex_t *source = &mq_md2_geometry_vertices[vertex];
        mq_alias_vertex_t *output = &mq_alias_triangle_vertices[vertex];
        float source_x = source->x * (1.0f - back_lerp) +
            source->old_x * back_lerp;
        float source_y = source->y * (1.0f - back_lerp) +
            source->old_y * back_lerp;
        float source_z = source->z * (1.0f - back_lerp) +
            source->old_z * back_lerp;
        output->s = 0.0f;
        output->t = 0.0f;
        output->r = 0u;
        output->g = 0u;
        output->b = 0u;
        output->a = (mq_u8)(mq_gl_md2_shadow_alpha * 255.0f);
        output->x = source_x - shade_x * (source_z + light_height);
        output->y = source_y - shade_y * (source_z + light_height);
        output->z = -light_height + 1.0f;
    }
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
        if (mq_d3d9_draw_interleaved_t2f_c4ub_v3f(
                mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else if (mq_render_backend_value == MQ_RENDER_VULKAN) {
        if (mq_vulkan_draw_interleaved_t2f_c4ub_v3f(
                mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
    } else {
        if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
            mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
        }
        if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
            mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
        }
        glInterleavedArrays(0x2A29u /* GL_T2F_C4UB_V3F */,
            (mq_i32)sizeof(mq_alias_vertex_t), mq_alias_triangle_vertices);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
        glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
        glDisableClientState(0x8076u /* GL_COLOR_ARRAY */);
        glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
    }
    return (mq_i32)num_tris;
}

/* Submit a five-tap planar alias shadow through one native crossing. The
 * small translated projections approximate MiniQuake's soft contact penumbra
 * while retaining Quake II's BSP-derived receiver height and cached MD2 VBO.
 * Backend-neutral compatibility paths keep one classic projection because
 * their matrix ownership lives outside OpenGL. */
MQ_EXPORT mq_i32 mq_gl_draw_md2_shadow_soft(
    const mq_u8 *data,
    mq_u32 byte_count,
    mq_u32 frame_index,
    mq_u32 old_frame_index,
    mq_u32 back_lerp_bits,
    const mq_u8 *normal_vectors,
    mq_u32 normal_count,
    mq_u64 geometry_key,
    mq_u32 geometry_state,
    mq_u32 triangle_count,
    mq_u32 shade_x_bits,
    mq_u32 shade_y_bits,
    mq_u32 light_height_bits
) {
    static const float offsets[5][2] = {
        {0.0f, 0.0f}, {-2.0f, 0.0f}, {2.0f, 0.0f},
        {0.0f, -2.0f}, {0.0f, 2.0f}
    };
    mq_i32 tap;
    mq_i32 result = 0;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        return mq_gl_draw_md2_shadow(data, byte_count, frame_index,
            old_frame_index, back_lerp_bits, normal_vectors, normal_count,
            geometry_key, geometry_state, triangle_count, shade_x_bits,
            shade_y_bits, light_height_bits);
    }
    mq_gl_md2_shadow_alpha = 0.11f;
    for (tap = 0; tap < 5; ++tap) {
        glPushMatrix();
        glTranslatef(offsets[tap][0], offsets[tap][1], 0.0f);
        if (mq_gl_draw_md2_shadow(data, byte_count, frame_index,
                old_frame_index, back_lerp_bits, normal_vectors, normal_count,
                geometry_key, geometry_state, triangle_count, shade_x_bits,
                shade_y_bits, light_height_bits) == (mq_i32)triangle_count) {
            result = (mq_i32)triangle_count;
        }
        glPopMatrix();
    }
    mq_gl_md2_shadow_alpha = 0.5f;
    return result;
}

/* End a run of Quake II alias draws before fixed-function geometry resumes. */
MQ_EXPORT void mq_gl_draw_alias_rgb_end(void) {
    if (mq_render_backend_value != MQ_RENDER_OPENGL ||
        !mq_gl_alias_program_active) return;
    if (mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) {
        mq_gl_use_program_value(0u);
    }
    mq_gl_alias_program_active = 0;
}

/* Submit draw alias batch geometry to the active backend command buffer. */
MQ_EXPORT mq_i32 mq_gl_draw_alias_batch(
    const mq_u8 *data,
    mq_u32 byte_count,
    const mq_u8 *shade_dots,
    mq_u32 shade_dot_count,
    mq_u32 shade_light_bits
) {
    mq_u32 offset = 0;
    mq_i32 triangles = 0;
    float shade_light = mq_bits_to_float(shade_light_bits);
    mq_u32 shade_key_count;
    mq_u64 hash = 1469598103934665603ull;
    mq_u64 signature = 0x9e3779b97f4a7c15ull;
    mq_u32 cache_index;
    mq_u32 list_id = 0u;
    if (data == MQ_NULL || shade_dots == MQ_NULL) return 0;
    if (mq_render_backend_value == MQ_RENDER_DIRECT3D9 || mq_render_backend_value == MQ_RENDER_VULKAN) {
        mq_u32 vertex_count = 0u;
        mq_i32 triangle_count = 0;
        if (!mq_alias_build_triangles(data, byte_count, shade_dots, shade_dot_count, shade_light, &vertex_count, &triangle_count)) return 0;
        if (mq_render_backend_value == MQ_RENDER_DIRECT3D9) {
            if (mq_d3d9_draw_interleaved_t2f_c4ub_v3f(mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
        } else if (mq_vulkan_draw_interleaved_t2f_c4ub_v3f(mq_alias_triangle_vertices, vertex_count) <= 0) return 0;
        return triangle_count;
    }
    /* Lighting varies per entity and frame.  Caching that baked vertex colour
     * in immutable VBOs/display lists created thousands of one-use driver
     * objects and stalled the first frame of newly visible monsters.  Rebuild
     * into the persistent CPU scratch array and submit it in one draw instead;
     * geometry, colour and ordering are identical to the cached path. */
    {
        mq_u32 vertex_count = 0u;
        mq_i32 triangle_count = 0;
        if (mq_alias_build_triangles(
                data, byte_count, shade_dots, shade_dot_count, shade_light,
                &vertex_count, &triangle_count)) {
            if (mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value)) {
                mq_gl_client_active_texture_value(0x84C0u /* GL_TEXTURE0 */);
            }
            if (mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) &&
                mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) &&
                mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value)) {
                if (mq_alias_stream_vbo == 0u) mq_gl_gen_buffers_value(1, &mq_alias_stream_vbo);
                mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, mq_alias_stream_vbo);
                mq_gl_buffer_data_value(
                    0x8892u /* GL_ARRAY_BUFFER */,
                    (mq_i64)(vertex_count * sizeof(mq_alias_vertex_t)),
                    mq_alias_triangle_vertices,
                    0x88E0u /* GL_STREAM_DRAW */
                );
                glInterleavedArrays(
                    0x2A29u /* GL_T2F_C4UB_V3F */,
                    (mq_i32)sizeof(mq_alias_vertex_t),
                    (const void *)0
                );
            } else {
                if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
                    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
                }
                glInterleavedArrays(
                    0x2A29u /* GL_T2F_C4UB_V3F */,
                    (mq_i32)sizeof(mq_alias_vertex_t),
                    mq_alias_triangle_vertices
                );
            }
            glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)vertex_count);
            glDisableClientState(0x8078u /* GL_TEXTURE_COORD_ARRAY */);
            glDisableClientState(0x8076u /* GL_COLOR_ARRAY */);
            glDisableClientState(0x8074u /* GL_VERTEX_ARRAY */);
            if (mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value)) {
                mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
            }
            return triangle_count;
        }
    }
    shade_key_count = shade_dot_count > 256u ? 256u : shade_dot_count;
    for (cache_index = 0u; cache_index < byte_count; ++cache_index) {
        mq_alias_hash_byte(data[cache_index], &hash, &signature);
    }
    for (cache_index = 0u; cache_index < shade_key_count * 4u; ++cache_index) {
        mq_alias_hash_byte(shade_dots[cache_index], &hash, &signature);
    }
    mq_alias_hash_byte((mq_u8)shade_light_bits, &hash, &signature);
    mq_alias_hash_byte((mq_u8)(shade_light_bits >> 8), &hash, &signature);
    mq_alias_hash_byte((mq_u8)(shade_light_bits >> 16), &hash, &signature);
    mq_alias_hash_byte((mq_u8)(shade_light_bits >> 24), &hash, &signature);
    if (mq_valid_wgl_proc((const void *)mq_gl_gen_buffers_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_bind_buffer_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_buffer_data_value)) {
        for (cache_index = 0u; cache_index < mq_alias_vbo_count; ++cache_index) {
            if (mq_alias_vbo_hash[cache_index] == hash &&
                mq_alias_vbo_signature[cache_index] == signature &&
                mq_alias_vbo_bytes[cache_index] == byte_count &&
                mq_alias_vbo_shade_count[cache_index] == shade_key_count &&
                mq_alias_vbo_shade_light[cache_index] == shade_light_bits) {
                mq_alias_draw_vbo(cache_index);
                return mq_alias_vbo_triangles[cache_index];
            }
        }
        if (mq_alias_vbo_count < MQ_ALIAS_VBO_CACHE_MAX) {
            mq_u32 vertex_count = 0u;
            mq_i32 triangle_count = 0;
            if (mq_alias_build_triangles(
                    data, byte_count, shade_dots, shade_dot_count, shade_light,
                    &vertex_count, &triangle_count)) {
                mq_u32 buffer = 0u;
                mq_gl_gen_buffers_value(1, &buffer);
                if (buffer != 0u) {
                    cache_index = mq_alias_vbo_count;
                    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, buffer);
                    mq_gl_buffer_data_value(
                        0x8892u /* GL_ARRAY_BUFFER */,
                        (mq_i64)(vertex_count * sizeof(mq_alias_vertex_t)),
                        mq_alias_triangle_vertices,
                        0x88E4u /* GL_STATIC_DRAW */
                    );
                    mq_gl_bind_buffer_value(0x8892u /* GL_ARRAY_BUFFER */, 0u);
                    mq_alias_vbo_hash[cache_index] = hash;
                    mq_alias_vbo_signature[cache_index] = signature;
                    mq_alias_vbo_bytes[cache_index] = byte_count;
                    mq_alias_vbo_shade_count[cache_index] = shade_key_count;
                    mq_alias_vbo_shade_light[cache_index] = shade_light_bits;
                    mq_alias_vbo_id[cache_index] = buffer;
                    mq_alias_vbo_vertices[cache_index] = vertex_count;
                    mq_alias_vbo_triangles[cache_index] = triangle_count;
                    mq_alias_vbo_count += 1u;
                    mq_alias_draw_vbo(cache_index);
                    return triangle_count;
                }
            }
        }
    }
    for (cache_index = 0u; cache_index < mq_alias_list_count; ++cache_index) {
        if (mq_alias_list_hash[cache_index] == hash &&
            mq_alias_list_signature[cache_index] == signature &&
            mq_alias_list_bytes[cache_index] == byte_count &&
            mq_alias_list_shade_count[cache_index] == shade_key_count &&
            mq_alias_list_shade_light[cache_index] == shade_light_bits) {
            glCallList(mq_alias_list_id[cache_index]);
            return mq_alias_list_triangles[cache_index];
        }
    }
    if (mq_alias_list_count < MQ_ALIAS_LIST_CACHE_MAX &&
        mq_alias_stream_valid(data, byte_count)) {
        list_id = glGenLists(1);
        if (list_id != 0u) glNewList(list_id, GL_COMPILE_AND_EXECUTE);
    }
    while (offset + 4u <= byte_count) {
        mq_u32 raw_count =
            (mq_u32)data[offset] |
            ((mq_u32)data[offset + 1u] << 8) |
            ((mq_u32)data[offset + 2u] << 16) |
            ((mq_u32)data[offset + 3u] << 24);
        mq_i32 signed_count = (mq_i32)raw_count;
        mq_u32 count;
        mq_u32 vertex;
        mq_u32 mode;
        offset += 4u;
        if (signed_count == 0) break;
        if (signed_count == (-2147483647 - 1)) return triangles;
        count = signed_count < 0 ? (mq_u32)(-signed_count) : (mq_u32)signed_count;
        mode = signed_count < 0 ? 0x0006u : 0x0005u; /* GL_TRIANGLE_FAN/STRIP */
        if (count > (byte_count - offset) / 12u) return triangles;
        glBegin(mode);
        for (vertex = 0; vertex < count; ++vertex) {
            mq_u32 s_bits =
                (mq_u32)data[offset] |
                ((mq_u32)data[offset + 1u] << 8) |
                ((mq_u32)data[offset + 2u] << 16) |
                ((mq_u32)data[offset + 3u] << 24);
            mq_u32 t_bits =
                (mq_u32)data[offset + 4u] |
                ((mq_u32)data[offset + 5u] << 8) |
                ((mq_u32)data[offset + 6u] << 16) |
                ((mq_u32)data[offset + 7u] << 24);
            mq_u32 normal = data[offset + 11u];
            float light = shade_light;
            mq_i32 color_value;
            mq_u8 color;
            if (normal < shade_dot_count) {
                mq_u32 dot_offset = normal * 4u;
                mq_u32 dot_bits =
                    (mq_u32)shade_dots[dot_offset] |
                    ((mq_u32)shade_dots[dot_offset + 1u] << 8) |
                    ((mq_u32)shade_dots[dot_offset + 2u] << 16) |
                    ((mq_u32)shade_dots[dot_offset + 3u] << 24);
                light = mq_bits_to_float(dot_bits) * shade_light;
            }
            color_value = (mq_i32)(light * 255.0f);
            if (color_value < 0) color_value = 0;
            if (color_value > 255) color_value = 255;
            color = (mq_u8)color_value;
            glColor4ub(color, color, color, 255u);
            glTexCoord2f(mq_bits_to_float(s_bits), mq_bits_to_float(t_bits));
            glVertex3f((float)data[offset + 8u], (float)data[offset + 9u], (float)data[offset + 10u]);
            offset += 12u;
        }
        glEnd();
        triangles += (mq_i32)count - 2;
    }
    if (list_id != 0u) {
        glEndList();
        cache_index = mq_alias_list_count;
        mq_alias_list_hash[cache_index] = hash;
        mq_alias_list_signature[cache_index] = signature;
        mq_alias_list_bytes[cache_index] = byte_count;
        mq_alias_list_shade_count[cache_index] = shade_key_count;
        mq_alias_list_shade_light[cache_index] = shade_light_bits;
        mq_alias_list_id[cache_index] = list_id;
        mq_alias_list_triangles[cache_index] = triangles;
        mq_alias_list_count += 1u;
    }
    return triangles;
}

/* Submit draw alias model geometry to the active backend command buffer. */
MQ_EXPORT mq_i32 mq_gl_draw_alias_model(
    const mq_u8 *data, mq_u32 byte_count,
    const mq_u8 *shade_dots, mq_u32 shade_dot_count, mq_u32 shade_light_bits,
    mq_u32 origin_x, mq_u32 origin_y, mq_u32 origin_z,
    mq_u32 angle_x, mq_u32 angle_y, mq_u32 angle_z,
    mq_u32 scale_origin_x, mq_u32 scale_origin_y, mq_u32 scale_origin_z,
    mq_u32 scale_x, mq_u32 scale_y, mq_u32 scale_z,
    mq_i32 double_eyes, mq_i32 smooth
) {
    float sox = mq_bits_to_float(scale_origin_x);
    float soy = mq_bits_to_float(scale_origin_y);
    float soz = mq_bits_to_float(scale_origin_z);
    float sx = mq_bits_to_float(scale_x);
    float sy = mq_bits_to_float(scale_y);
    float sz = mq_bits_to_float(scale_z);
    mq_i32 triangles;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        void (*push_matrix)(void) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_push_matrix : mq_vulkan_push_matrix;
        void (*pop_matrix)(void) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_pop_matrix : mq_vulkan_pop_matrix;
        void (*translate)(mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_translate : mq_vulkan_translate;
        void (*rotate)(mq_u32,mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_rotate : mq_vulkan_rotate;
        void (*scale)(mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_scale : mq_vulkan_scale;
        void (*cull_face)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_cull_face : mq_vulkan_cull_face;
        void (*enable)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_enable : mq_vulkan_enable;
        void (*disable)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_disable : mq_vulkan_disable;
        void (*shade_model)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_shade_model : mq_vulkan_shade_model;
        void (*tex_env)(mq_u32,mq_u32,mq_i32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_tex_env_i : mq_vulkan_tex_env_i;
        void (*color)(mq_u32,mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_color4ub : mq_vulkan_color4ub;
        push_matrix();
        translate(origin_x, origin_y, origin_z);
        rotate(angle_y, mq_float_to_bits(0.0f), mq_float_to_bits(0.0f), mq_float_to_bits(1.0f));
        rotate(mq_float_to_bits(-mq_bits_to_float(angle_x)), mq_float_to_bits(0.0f), mq_float_to_bits(1.0f), mq_float_to_bits(0.0f));
        rotate(angle_z, mq_float_to_bits(1.0f), mq_float_to_bits(0.0f), mq_float_to_bits(0.0f));
        if (double_eyes) {
            translate(scale_origin_x, scale_origin_y, mq_float_to_bits(soz - 30.0f));
            scale(mq_float_to_bits(sx * 2.0f), mq_float_to_bits(sy * 2.0f), mq_float_to_bits(sz * 2.0f));
        } else {
            translate(scale_origin_x, scale_origin_y, scale_origin_z);
            scale(scale_x, scale_y, scale_z);
        }
        cull_face(0x0404u);
        enable(0x0B44u);
        if (smooth) shade_model(0x1D01u);
        tex_env(0x2300u, 0x2200u, 0x2100u);
        triangles = mq_gl_draw_alias_batch(data, byte_count, shade_dots, shade_dot_count, shade_light_bits);
        tex_env(0x2300u, 0x2200u, 0x1E01u);
        shade_model(0x1D00u);
        color(255u, 255u, 255u, 255u);
        disable(0x0B44u);
        pop_matrix();
        return triangles;
    }
    glPushMatrix();
    glTranslatef(mq_bits_to_float(origin_x), mq_bits_to_float(origin_y), mq_bits_to_float(origin_z));
    glRotatef(mq_bits_to_float(angle_y), 0.0f, 0.0f, 1.0f);
    glRotatef(-mq_bits_to_float(angle_x), 0.0f, 1.0f, 0.0f);
    glRotatef(mq_bits_to_float(angle_z), 1.0f, 0.0f, 0.0f);
    if (double_eyes) {
        glTranslatef(sox, soy, soz - 30.0f);
        glScalef(sx * 2.0f, sy * 2.0f, sz * 2.0f);
    } else {
        glTranslatef(sox, soy, soz);
        glScalef(sx, sy, sz);
    }
    glCullFace(0x0404u); /* GL_FRONT */
    glEnable(0x0B44u);  /* GL_CULL_FACE */
    if (smooth) glShadeModel(0x1D01u); /* GL_SMOOTH */
    glTexEnvi(0x2300u, 0x2200u, 0x2100u); /* TEXTURE_ENV/MODE/MODULATE */
    triangles = mq_gl_draw_alias_batch(data, byte_count, shade_dots, shade_dot_count, shade_light_bits);
    glTexEnvi(0x2300u, 0x2200u, 0x1E01u); /* GL_REPLACE */
    glShadeModel(0x1D00u); /* GL_FLAT */
    glColor4ub(255u, 255u, 255u, 255u);
    glDisable(0x0B44u);
    glPopMatrix();
    return triangles;
}

/* Transform and draw one MDL model interpolated between two cached poses. */
MQ_EXPORT mq_i32 mq_gl_draw_alias_model_lerp(
    const mq_u8 *previous_data, mq_u32 previous_byte_count,
    const mq_u8 *current_data, mq_u32 current_byte_count, mq_u32 fraction_bits,
    const mq_u8 *shade_dots, mq_u32 shade_dot_count, mq_u32 shade_light_bits,
    mq_u32 origin_x, mq_u32 origin_y, mq_u32 origin_z,
    mq_u32 angle_x, mq_u32 angle_y, mq_u32 angle_z,
    mq_u32 scale_origin_x, mq_u32 scale_origin_y, mq_u32 scale_origin_z,
    mq_u32 scale_x, mq_u32 scale_y, mq_u32 scale_z,
    mq_i32 double_eyes, mq_i32 smooth
) {
    float sox = mq_bits_to_float(scale_origin_x);
    float soy = mq_bits_to_float(scale_origin_y);
    float soz = mq_bits_to_float(scale_origin_z);
    float sx = mq_bits_to_float(scale_x);
    float sy = mq_bits_to_float(scale_y);
    float sz = mq_bits_to_float(scale_z);
    float fraction = mq_bits_to_float(fraction_bits);
    float shade_light = mq_bits_to_float(shade_light_bits);
    mq_i32 triangles;
    if (mq_render_backend_value != MQ_RENDER_OPENGL) {
        void (*push_matrix)(void) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_push_matrix : mq_vulkan_push_matrix;
        void (*pop_matrix)(void) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_pop_matrix : mq_vulkan_pop_matrix;
        void (*translate)(mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_translate : mq_vulkan_translate;
        void (*rotate)(mq_u32,mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_rotate : mq_vulkan_rotate;
        void (*scale)(mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_scale : mq_vulkan_scale;
        void (*cull_face)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_cull_face : mq_vulkan_cull_face;
        void (*enable)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_enable : mq_vulkan_enable;
        void (*disable)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_disable : mq_vulkan_disable;
        void (*shade_model)(mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_shade_model : mq_vulkan_shade_model;
        void (*tex_env)(mq_u32,mq_u32,mq_i32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_tex_env_i : mq_vulkan_tex_env_i;
        void (*color)(mq_u32,mq_u32,mq_u32,mq_u32) = mq_render_backend_value == MQ_RENDER_DIRECT3D9 ? mq_d3d9_color4ub : mq_vulkan_color4ub;
        push_matrix();
        translate(origin_x, origin_y, origin_z);
        rotate(angle_y, mq_float_to_bits(0.0f), mq_float_to_bits(0.0f), mq_float_to_bits(1.0f));
        rotate(mq_float_to_bits(-mq_bits_to_float(angle_x)), mq_float_to_bits(0.0f), mq_float_to_bits(1.0f), mq_float_to_bits(0.0f));
        rotate(angle_z, mq_float_to_bits(1.0f), mq_float_to_bits(0.0f), mq_float_to_bits(0.0f));
        if (double_eyes) {
            translate(scale_origin_x, scale_origin_y, mq_float_to_bits(soz - 30.0f));
            scale(mq_float_to_bits(sx * 2.0f), mq_float_to_bits(sy * 2.0f), mq_float_to_bits(sz * 2.0f));
        } else {
            translate(scale_origin_x, scale_origin_y, scale_origin_z);
            scale(scale_x, scale_y, scale_z);
        }
        cull_face(0x0404u);
        enable(0x0B44u);
        if (smooth) shade_model(0x1D01u);
        tex_env(0x2300u, 0x2200u, 0x2100u);
        triangles = mq_gl_draw_alias_batch_lerp(
            previous_data, previous_byte_count, current_data, current_byte_count,
            fraction, shade_dots, shade_dot_count, shade_light);
        tex_env(0x2300u, 0x2200u, 0x1E01u);
        shade_model(0x1D00u);
        color(255u, 255u, 255u, 255u);
        disable(0x0B44u);
        pop_matrix();
        return triangles;
    }
    glPushMatrix();
    glTranslatef(mq_bits_to_float(origin_x), mq_bits_to_float(origin_y), mq_bits_to_float(origin_z));
    glRotatef(mq_bits_to_float(angle_y), 0.0f, 0.0f, 1.0f);
    glRotatef(-mq_bits_to_float(angle_x), 0.0f, 1.0f, 0.0f);
    glRotatef(mq_bits_to_float(angle_z), 1.0f, 0.0f, 0.0f);
    if (double_eyes) {
        glTranslatef(sox, soy, soz - 30.0f);
        glScalef(sx * 2.0f, sy * 2.0f, sz * 2.0f);
    } else {
        glTranslatef(sox, soy, soz);
        glScalef(sx, sy, sz);
    }
    glCullFace(0x0404u);
    glEnable(0x0B44u);
    if (smooth) glShadeModel(0x1D01u);
    glTexEnvi(0x2300u, 0x2200u, 0x2100u);
    triangles = mq_gl_draw_alias_batch_lerp(
        previous_data, previous_byte_count, current_data, current_byte_count,
        fraction, shade_dots, shade_dot_count, shade_light);
    glTexEnvi(0x2300u, 0x2200u, 0x1E01u);
    glShadeModel(0x1D00u);
    glColor4ub(255u, 255u, 255u, 255u);
    glDisable(0x0B44u);
    glPopMatrix();
    return triangles;
}
