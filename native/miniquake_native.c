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

typedef struct MQ_HOSTENT {
    char *h_name;
    char **h_aliases;
    mq_i16 h_addrtype;
    mq_i16 h_length;
    char **h_addr_list;
} MQ_HOSTENT;

typedef struct MQ_POINT {
    LONG x;
    LONG y;
} MQ_POINT;

typedef struct MQ_COORD {
    mq_i16 X;
    mq_i16 Y;
} MQ_COORD;

typedef struct MQ_SMALL_RECT {
    mq_i16 Left;
    mq_i16 Top;
    mq_i16 Right;
    mq_i16 Bottom;
} MQ_SMALL_RECT;

typedef struct MQ_CONSOLE_SCREEN_BUFFER_INFO {
    MQ_COORD dwSize;
    MQ_COORD dwCursorPosition;
    WORD wAttributes;
    MQ_SMALL_RECT srWindow;
    MQ_COORD dwMaximumWindowSize;
} MQ_CONSOLE_SCREEN_BUFFER_INFO;

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

typedef struct MQ_INPUT_RECORD {
    WORD EventType;
    union {
        MQ_KEY_EVENT_RECORD KeyEvent;
        mq_u8 padding[16];
    } Event;
} MQ_INPUT_RECORD;

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

typedef struct MQ_POINTL {
    LONG x;
    LONG y;
} MQ_POINTL;

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
MQ_DLLIMPORT HWND MQ_WINAPI SetCapture(HWND window);
MQ_DLLIMPORT BOOL MQ_WINAPI ReleaseCapture(void);
MQ_DLLIMPORT BOOL MQ_WINAPI ClipCursor(const MQ_RECT *rect);
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
typedef void (MQ_WINAPI *mq_gl_uniform_1i_proc)(mq_i32 location, mq_i32 value);
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
static mq_gl_uniform_1i_proc mq_gl_uniform_1i_value = (mq_gl_uniform_1i_proc)0;
static mq_gl_gen_buffers_proc mq_gl_gen_buffers_value = (mq_gl_gen_buffers_proc)0;
static mq_gl_bind_buffer_proc mq_gl_bind_buffer_value = (mq_gl_bind_buffer_proc)0;
static mq_gl_buffer_data_proc mq_gl_buffer_data_value = (mq_gl_buffer_data_proc)0;
static mq_gl_delete_buffers_proc mq_gl_delete_buffers_value = (mq_gl_delete_buffers_proc)0;
static mq_u32 mq_gl_world_program = 0u;
static mq_i32 mq_gl_world_program_attempted = 0;

static mq_i32 mq_valid_wgl_proc(const void *value) {
    return value != (const void *)0 && value != (const void *)1 && value != (const void *)2 &&
        value != (const void *)3 && value != (const void *)-1;
}

static mq_i32 mq_gl_create_world_program(void) {
    static const char *vertex_source =
        "#version 120\n"
        "void main(){gl_Position=ftransform();gl_TexCoord[0]=gl_MultiTexCoord0;gl_TexCoord[1]=gl_MultiTexCoord1;}\n";
    static const char *fragment_source =
        "#version 120\n"
        "uniform sampler2D mq_base;uniform sampler2D mq_light;"
        "void main(){vec4 b=texture2D(mq_base,gl_TexCoord[0].st);"
        "float l=texture2D(mq_light,gl_TexCoord[1].st).r;"
        "gl_FragColor=vec4(b.rgb*(1.0-l),b.a);}\n";
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

MQ_EXPORT mq_i32 mq_gl_static_geometry_call(mq_u64 key_value, mq_i32 pass_value) {
    mq_u64 key = key_value;
    mq_i32 pass = pass_value;
    mq_u32 slot;
    mq_i32 found;
    if (mq_static_geometry_pending || mq_static_geometry_recording) return 0;
    found = mq_static_geometry_find(key, pass, &slot);
    if (found >= 0) {
        glCallList(mq_static_geometry_cache[found].list_id);
        return 1;
    }
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
        glInterleavedArrays(0x2A27u /* GL_T2F_V3F */, 0, mq_static_geometry_batch);
        glDrawArrays(0x0004u /* GL_TRIANGLES */, 0, (mq_i32)batch_vertex_count);
        return (mq_i32)count;
    }
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

#define MQ_ALIAS_VBO_CACHE_MAX 512u
#define MQ_ALIAS_COMMAND_VERTICES 4096u
#define MQ_ALIAS_TRIANGLE_VERTICES 16384u
static mq_alias_vertex_t mq_alias_command_vertices[MQ_ALIAS_COMMAND_VERTICES];
static mq_alias_vertex_t mq_alias_triangle_vertices[MQ_ALIAS_TRIANGLE_VERTICES];
static mq_u64 mq_alias_vbo_hash[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u64 mq_alias_vbo_signature[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_bytes[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_shade_count[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_shade_light[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_id[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_vertices[MQ_ALIAS_VBO_CACHE_MAX];
static mq_i32 mq_alias_vbo_triangles[MQ_ALIAS_VBO_CACHE_MAX];
static mq_u32 mq_alias_vbo_count = 0u;

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

MQ_EXPORT mq_i32 mq_gl_static_geometry_call_multitexture_batch(
    const mq_u8 *records,
    mq_u32 byte_count
) {
    mq_u32 count;
    mq_u32 index;
    mq_u32 group_count = 0u;
    mq_u32 total_vertices = 0u;
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

MQ_EXPORT void mq_gl_static_geometry_clear(void) {
    mq_i32 i;
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
#define MQ_ENUM_CURRENT_SETTINGS 0xFFFFFFFFu
#define MQ_CDS_FULLSCREEN 0x00000004u
#define MQ_CDS_TEST 0x00000002u
#define MQ_DISP_CHANGE_SUCCESSFUL 0
#define MQ_DM_BITSPERPEL 0x00040000u
#define MQ_DM_PELSWIDTH 0x00080000u
#define MQ_DM_PELSHEIGHT 0x00100000u
#define MQ_DM_DISPLAYFREQUENCY 0x00400000u
#define MQ_SIZE_MINIMIZED 1u
#define MQ_IDYES 6
#define MQ_MB_YESNO 0x00000004u
#define MQ_MB_ICONQUESTION 0x00000020u
#define MQ_MB_SETFOREGROUND 0x00010000u
#define MQ_IDC_ARROW ((LPCWSTR)(ULONG_PTR)32512u)
#define MQ_IDI_APPLICATION ((LPCWSTR)(ULONG_PTR)32512u)
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
static mq_i32 mq_active_app = 0;
static mq_i32 mq_minimized = 0;
static mq_i32 mq_window_x_value = 0;
static mq_i32 mq_window_y_value = 0;
static mq_i32 mq_display_fullscreen = 0;
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

static void mq_push_input_event(mq_u32 type, mq_u32 code, mq_i32 value) {
    mq_u32 next = (mq_input_head + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    mq_u32 packed = ((type & 0xFFu) << 24) | ((code & 0xFFFFu) << 8) | ((mq_u32)value & 0xFFu);
    if (next == mq_input_tail) {
        mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    }
    mq_input_queue[mq_input_head] = packed;
    mq_input_head = next;
}

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

static void mq_udp_remember_address(const MQ_SOCKADDR_IN *address) {
    mq_udp_format_address(mq_udp_last_address_text, address->sin_addr);
    mq_udp_last_port_value = (mq_u32)ntohs(address->sin_port);
}

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

static void mq_push_text(mq_u16 character) {
    mq_u32 next = (mq_text_head + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    if (next == mq_text_tail) {
        mq_text_tail = (mq_text_tail + 1u) % MQ_TEXT_QUEUE_CAPACITY;
    }
    mq_text_queue[mq_text_head] = character;
    mq_text_head = next;
}

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

static void mq_restore_requested_display_mode(void) {
    if (mq_display_changed || mq_display_suspended) {
        ChangeDisplaySettingsW(MQ_NULL, 0);
    }
    mq_display_changed = 0;
    mq_display_suspended = 0;
}

static LRESULT MQ_WINAPI mq_window_proc(HWND window, UINT message, WPARAM w_param, LPARAM l_param) {
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

MQ_EXPORT mq_i32 mq_win_display_mode_width(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmPelsWidth : 0;
}

MQ_EXPORT mq_i32 mq_win_display_mode_height(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmPelsHeight : 0;
}

MQ_EXPORT mq_i32 mq_win_display_mode_bpp(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmBitsPerPel : 0;
}

MQ_EXPORT mq_i32 mq_win_display_mode_frequency(mq_u32 index) {
    return index < mq_display_mode_count_value ? (mq_i32)mq_display_modes[index].dmDisplayFrequency : 0;
}

MQ_EXPORT mq_i32 mq_win_test_display_mode(mq_i32 width, mq_i32 height, mq_i32 bpp, mq_i32 frequency) {
    MQ_DEVMODEW mode;
    if (width < 1 || height < 1) {
        return 0;
    }
    mq_prepare_display_mode(&mode, width, height, bpp, frequency);
    return ChangeDisplaySettingsW(&mode, MQ_CDS_TEST | MQ_CDS_FULLSCREEN) == MQ_DISP_CHANGE_SUCCESSFUL;
}

MQ_EXPORT mq_i32 mq_win_configure_display_mode(
    mq_i32 width,
    mq_i32 height,
    mq_i32 bpp,
    mq_i32 frequency,
    mq_i32 fullscreen,
    mq_i32 use_current
) {
    mq_restore_requested_display_mode();
    mq_display_fullscreen = fullscreen != 0;
    mq_display_use_current = use_current != 0;
    mq_prepare_display_mode(&mq_requested_display_mode, width, height, bpp, frequency);
    if (mq_display_fullscreen && !mq_display_use_current) {
        return ChangeDisplaySettingsW(&mq_requested_display_mode, MQ_CDS_TEST | MQ_CDS_FULLSCREEN) == MQ_DISP_CHANGE_SUCCESSFUL;
    }
    return 1;
}

MQ_EXPORT void mq_win_restore_display_mode(void) {
    mq_restore_requested_display_mode();
    mq_display_fullscreen = 0;
    mq_display_use_current = 0;
}

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

MQ_EXPORT mq_i32 mq_win_context_ready(void) {
    return mq_window_dc != MQ_NULL && mq_gl_context != MQ_NULL;
}

MQ_EXPORT mq_i32 mq_win_make_current(void) {
    return mq_window_dc != MQ_NULL && mq_gl_context != MQ_NULL && wglMakeCurrent(mq_window_dc, mq_gl_context);
}

MQ_EXPORT mq_i32 mq_win_window_x(void) { return mq_window_x_value; }
MQ_EXPORT mq_i32 mq_win_window_y(void) { return mq_window_y_value; }
MQ_EXPORT mq_i32 mq_win_is_minimized(void) { return mq_minimized; }
MQ_EXPORT mq_i32 mq_win_desktop_width(void) { return GetSystemMetrics(MQ_SM_CXSCREEN); }
MQ_EXPORT mq_i32 mq_win_desktop_height(void) { return GetSystemMetrics(MQ_SM_CYSCREEN); }

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
    if (fullscreen && !mq_apply_requested_display_mode()) {
        return MQ_NULL;
    }

    mq_instance = GetModuleHandleW(MQ_NULL);
    if (mq_instance == MQ_NULL) {
        mq_restore_requested_display_mode();
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

    mq_window_dc = GetDC(mq_window);
    if (mq_window_dc == MQ_NULL) {
        mq_win_destroy();
        return MQ_NULL;
    }

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
    mq_gl_uniform_1i_value = (mq_gl_uniform_1i_proc)wglGetProcAddress("glUniform1i");
    mq_gl_gen_buffers_value = (mq_gl_gen_buffers_proc)wglGetProcAddress("glGenBuffers");
    mq_gl_bind_buffer_value = (mq_gl_bind_buffer_proc)wglGetProcAddress("glBindBuffer");
    mq_gl_buffer_data_value = (mq_gl_buffer_data_proc)wglGetProcAddress("glBufferData");
    mq_gl_delete_buffers_value = (mq_gl_delete_buffers_proc)wglGetProcAddress("glDeleteBuffers");
    mq_gl_create_world_program();

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

    ShowWindow(mq_window, MQ_SW_SHOW);
    UpdateWindow(mq_window);
    /* Pay the one-time DWM/ICD present cost while the window is still in its
     * startup phase, not on the first playable map frame. */
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
    mq_clear_input_events();
    mq_running = 1;
    mq_active_app = 1;
    mq_minimized = 0;
    return mq_window;
}

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
    if (mq_gl_context != MQ_NULL) {
        if (mq_gl_world_program != 0u && mq_valid_wgl_proc((const void *)mq_gl_delete_program_value)) {
            mq_gl_delete_program_value(mq_gl_world_program);
            mq_gl_world_program = 0u;
        }
        mq_gl_world_program_attempted = 0;
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
    mq_restore_requested_display_mode();
    mq_display_fullscreen = 0;
    mq_display_use_current = 0;
    mq_running = 0;
    mq_active_app = 0;
    mq_minimized = 0;
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

/* Resize the existing window without replacing its HDC/WGL context.  Runtime
 * video changes can therefore preserve every uploaded Quake texture, display
 * list and VBO.  The window style is fixed at startup; this function only
 * changes the resolution within the active windowed/fullscreen mode. */
MQ_EXPORT mq_i32 mq_win_resize_client(mq_i32 width, mq_i32 height) {
    MQ_RECT rectangle;
    DWORD style;
    DWORD ex_style = MQ_WS_EX_APPWINDOW;
    mq_i32 outer_width;
    mq_i32 outer_height;
    UINT flags = MQ_SWP_NOZORDER | MQ_SWP_NOACTIVATE | MQ_SWP_FRAMECHANGED;
    if (mq_window == MQ_NULL || width < 320 || height < 200) {
        return 0;
    }
    if (mq_display_fullscreen) {
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
        rectangle.left = 0;
        rectangle.top = 0;
        rectangle.right = width;
        rectangle.bottom = height;
        if (!AdjustWindowRectEx(&rectangle, style, MQ_FALSE, ex_style)) {
            return 0;
        }
        outer_width = rectangle.right - rectangle.left;
        outer_height = rectangle.bottom - rectangle.top;
        ShowWindow(mq_window, MQ_SW_SHOWNORMAL);
        if (!SetWindowPos(
                mq_window, MQ_NULL, 0, 0, outer_width, outer_height,
                flags | MQ_SWP_NOMOVE)) {
            return 0;
        }
    }
    mq_minimized = 0;
    mq_mouse_ready = 0;
    if (mq_cursor_captured) {
        mq_update_clip_cursor();
    }
    if (!GetClientRect(mq_window, &rectangle)) {
        return 0;
    }
    return rectangle.right - rectangle.left == width &&
        rectangle.bottom - rectangle.top == height;
}

MQ_EXPORT void mq_win_set_title(const unsigned short *title) {
    if (mq_window != MQ_NULL && title != MQ_NULL) {
        SetWindowTextW(mq_window, title);
    }
}

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

MQ_EXPORT mq_u32 mq_win_input_event_pop(void) {
    mq_u32 value;
    if (mq_input_tail == mq_input_head) {
        return 0;
    }
    value = mq_input_queue[mq_input_tail];
    mq_input_tail = (mq_input_tail + 1u) % MQ_INPUT_QUEUE_CAPACITY;
    return value;
}

MQ_EXPORT void mq_win_input_test_push(mq_u32 type, mq_u32 code, mq_i32 value) {
    mq_push_input_event(type, code, value);
}

MQ_EXPORT void mq_win_cursor_show(mq_i32 show) {
    if (show) {
        while (ShowCursor(MQ_TRUE) < 0) { }
    } else {
        while (ShowCursor(MQ_FALSE) >= 0) { }
    }
}

MQ_EXPORT mq_i32 mq_win_cursor_center(void) {
    return mq_center_mouse_cursor();
}

MQ_EXPORT mq_i32 mq_win_update_clip_cursor(void) {
    if (!mq_cursor_captured) {
        return 0;
    }
    return mq_update_clip_cursor();
}

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

MQ_EXPORT mq_i32 mq_win_joy_read(void) {
    if (!mq_joy_available) {
        return 0;
    }
    memset(&mq_joy_info, 0, (mq_u64)sizeof(mq_joy_info));
    mq_joy_info.dwSize = (DWORD)sizeof(mq_joy_info);
    mq_joy_info.dwFlags = MQ_JOY_RETURNALL | MQ_JOY_RETURNCENTERED;
    return joyGetPosEx(mq_joy_id, &mq_joy_info) == MQ_JOYERR_NOERROR;
}

MQ_EXPORT mq_u32 mq_win_joy_axis(mq_u32 axis) {
    if (axis == 0u) return mq_joy_info.dwXpos;
    if (axis == 1u) return mq_joy_info.dwYpos;
    if (axis == 2u) return mq_joy_info.dwZpos;
    if (axis == 3u) return mq_joy_info.dwRpos;
    if (axis == 4u) return mq_joy_info.dwUpos;
    if (axis == 5u) return mq_joy_info.dwVpos;
    return 32768u;
}

MQ_EXPORT mq_u32 mq_win_joy_buttons(void) { return mq_joy_info.dwButtons; }
MQ_EXPORT mq_u32 mq_win_joy_pov(void) { return mq_joy_info.dwPOV; }
MQ_EXPORT mq_u32 mq_win_joy_button_count(void) { return mq_joy_button_count_value; }
MQ_EXPORT mq_i32 mq_win_joy_has_pov(void) { return mq_joy_has_pov_value; }
MQ_EXPORT mq_i32 mq_win_joy_warrior_curve(mq_i32 raw_value) {
    double magnitude = (double)(raw_value < 0 ? -raw_value : raw_value);
    double curved = 300.0 * pow(magnitude / 800.0, 1.3);
    if (curved > 14000.0) curved = 14000.0;
    return raw_value > 0 ? (mq_i32)curved : -(mq_i32)curved;
}

MQ_EXPORT mq_u32 mq_win_joy_warrior_curve_f32(mq_i32 raw_value) {
    float magnitude = (float)(raw_value < 0 ? -raw_value : raw_value);
    float curved = (float)(300.0 * pow((double)magnitude / 800.0, 1.3));
    if (curved > 14000.0f) curved = 14000.0f;
    if (raw_value <= 0) curved = -curved;
    return mq_float_to_bits(curved);
}

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

MQ_EXPORT void mq_win_sleep(mq_u32 milliseconds) {
    Sleep(milliseconds);
}

MQ_EXPORT mq_u64 mq_sys_counter(void) {
    mq_i64 counter = 0;
    if (!QueryPerformanceCounter(&counter)) return 0;
    return (mq_u64)counter;
}

MQ_EXPORT mq_u64 mq_sys_frequency(void) {
    mq_i64 frequency = 0;
    if (!QueryPerformanceFrequency(&frequency)) return 0;
    return (mq_u64)frequency;
}

MQ_EXPORT mq_u32 mq_process_handle_count(void) {
    DWORD handle_count = 0;
    if (!GetProcessHandleCount(GetCurrentProcess(), &handle_count)) return 0;
    return handle_count;
}

MQ_EXPORT mq_i32 mq_sys_make_code_writeable(mq_u64 address, mq_u64 length) {
    DWORD old_protection = 0;
    if (address == 0 || length == 0) return 0;
    return VirtualProtect((LPVOID)(ULONG_PTR)address, length, 0x04u, &old_protection) != 0;
}

static mq_i32 mq_sys_owns_console = 0;

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

MQ_EXPORT mq_i32 mq_sys_console_free(void) {
    if (!mq_sys_owns_console) return 1;
    mq_sys_owns_console = 0;
    return FreeConsole() != 0;
}

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

MQ_EXPORT mq_i32 mq_sys_console_write(const char *text) {
    HANDLE output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    DWORD length = 0;
    DWORD written = 0;
    if (output == MQ_NULL || text == MQ_NULL) return 0;
    while (text[length] != 0) ++length;
    return WriteFile(output, text, length, &written, MQ_NULL) != 0 && written == length;
}

MQ_EXPORT void mq_sys_sleep_until_input(mq_u32 milliseconds) {
    MsgWaitForMultipleObjects(0, MQ_NULL, MQ_FALSE, milliseconds, 0x04FFu);
}

MQ_EXPORT mq_u64 mq_conproc_create_event(void) {
    return (mq_u64)(ULONG_PTR)CreateEventW(MQ_NULL, MQ_FALSE, MQ_FALSE, MQ_NULL);
}

MQ_EXPORT mq_i32 mq_conproc_set_event(mq_u64 handle) {
    if (handle == 0) return 0;
    return SetEvent((HANDLE)(ULONG_PTR)handle) != 0;
}

MQ_EXPORT void mq_conproc_close_handle(mq_u64 handle) {
    if (handle != 0) CloseHandle((HANDLE)(ULONG_PTR)handle);
}

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

MQ_EXPORT mq_ptr mq_conproc_map(mq_u64 handle) {
    if (handle == 0) return MQ_NULL;
    return MapViewOfFile((HANDLE)(ULONG_PTR)handle, MQ_FILE_MAP_READ | MQ_FILE_MAP_WRITE, 0, 0, 0);
}

MQ_EXPORT mq_i32 mq_conproc_unmap(mq_ptr mapped) {
    return mapped != MQ_NULL && UnmapViewOfFile(mapped) != 0;
}

MQ_EXPORT mq_i32 mq_conproc_read_i32(mq_ptr mapped, mq_u32 index) {
    const mq_i32 *values = (const mq_i32 *)mapped;
    return values != MQ_NULL ? values[index] : 0;
}

MQ_EXPORT void mq_conproc_write_i32(mq_ptr mapped, mq_u32 index, mq_i32 value) {
    mq_i32 *values = (mq_i32 *)mapped;
    if (values != MQ_NULL) values[index] = value;
}

MQ_EXPORT const char *mq_conproc_read_text(mq_ptr mapped, mq_u32 byte_offset) {
    if (mapped == MQ_NULL) return "";
    return (const char *)((const mq_u8 *)mapped + byte_offset);
}

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

MQ_EXPORT mq_i32 mq_conproc_screen_lines(void) {
    MQ_CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE output = GetStdHandle(MQ_STD_OUTPUT_HANDLE);
    if (output == MQ_NULL || !GetConsoleScreenBufferInfo(output, &info)) return -1;
    return (mq_i32)info.dwSize.Y;
}

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

static void mq_audio_reap_completed(void) {
    mq_u32 i;
    if (mq_wave_output == MQ_NULL) {
        return;
    }
    for (i = 0; i < MQ_AUDIO_BUFFER_COUNT; ++i) {
        MQ_WAVEHDR *header = &mq_audio_headers[i];
        if ((header->dwFlags & MQ_WHDR_PREPARED) && (header->dwFlags & MQ_WHDR_DONE)) {
            mq_audio_completed_bytes += (mq_u64)header->dwBufferLength;
            ++mq_audio_completed_count;
            waveOutUnprepareHeader(mq_wave_output, header, (UINT)sizeof(*header));
            header->dwBufferLength = 0;
            header->dwBytesRecorded = 0;
            header->dwUser = 0;
            header->dwFlags = 0;
            if (mq_audio_buffer_count > 0) {
                --mq_audio_buffer_count;
            }
        }
    }
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
    mq_audio_bytes_per_sample = bits_per_sample / 8u;
    mq_audio_submitted_count = 0;
    mq_audio_completed_count = 0;
    mq_audio_underrun_count = 0;
    mq_audio_completed_bytes = 0;
    return 1;
}

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
    header->dwUser = byte_count;
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
    ++mq_audio_submitted_count;
    return 1;
}

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
    }
    waveOutClose(mq_wave_output);
    mq_wave_output = MQ_NULL;
    mq_audio_buffer_count = 0;
}

MQ_EXPORT mq_u32 mq_audio_queued(void) {
    if (mq_wave_output == MQ_NULL) {
        return 0;
    }
    mq_audio_reap_completed();
    return mq_audio_buffer_count;
}

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

MQ_EXPORT mq_u32 mq_audio_submitted(void) {
    return mq_audio_submitted_count;
}

MQ_EXPORT mq_u32 mq_audio_completed(void) {
    mq_audio_reap_completed();
    return mq_audio_completed_count;
}

MQ_EXPORT mq_u32 mq_audio_underruns(void) {
    return mq_audio_underrun_count;
}

MQ_EXPORT mq_u32 mq_audio_header_state(mq_u32 index) {
    MQ_WAVEHDR *header;
    if (index >= MQ_AUDIO_BUFFER_COUNT) {
        return 0;
    }
    mq_audio_reap_completed();
    header = &mq_audio_headers[index];
    if ((header->dwFlags & MQ_WHDR_PREPARED) == 0) {
        return 0;
    }
    if (header->dwFlags & MQ_WHDR_DONE) {
        return 2;
    }
    return 1;
}

MQ_EXPORT mq_u32 mq_audio_capacity(void) {
    return MQ_AUDIO_BUFFER_COUNT;
}

MQ_EXPORT mq_i32 mq_audio_is_open(void) {
    return mq_wave_output != MQ_NULL;
}

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

MQ_EXPORT mq_u64 mq_udp_open(mq_u32 port) {
    return mq_udp_open_bound(port, "0.0.0.0");
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
MQ_EXPORT mq_u32 mq_udp_last_port(void) { return mq_udp_last_port_value; }
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

MQ_EXPORT void mq_gl_begin(mq_u32 mode) {
    if (mq_static_geometry_pending && !mq_static_geometry_recording) {
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
 glBegin(mode); }
MQ_EXPORT void mq_gl_end(void) { glEnd(); 
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
MQ_EXPORT void mq_gl_vertex2(mq_u32 x_bits, mq_u32 y_bits) { glVertex2f(mq_bits_to_float(x_bits), mq_bits_to_float(y_bits)); }
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
    glVertex3f(x, y, z);
}
MQ_EXPORT void mq_gl_texcoord2(mq_u32 s_bits, mq_u32 t_bits) {
    mq_static_geometry_s = mq_bits_to_float(s_bits);
    mq_static_geometry_t = mq_bits_to_float(t_bits);
    mq_static_geometry_multi_s[0] = mq_static_geometry_s;
    mq_static_geometry_multi_t[0] = mq_static_geometry_t;
    glTexCoord2f(mq_static_geometry_s, mq_static_geometry_t);
}
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
MQ_EXPORT void mq_gl_tex_env_i(mq_u32 target, mq_u32 name, mq_i32 value) { glTexEnvi(target, name, value); }
MQ_EXPORT void mq_gl_tex_image_2d(mq_u32 target, mq_i32 level, mq_i32 internal_format, mq_i32 width, mq_i32 height, mq_i32 border, mq_u32 format, mq_u32 type, const void *pixels) { glTexImage2D(target, level, internal_format, width, height, border, format, type, pixels); }
MQ_EXPORT void mq_gl_tex_sub_image_2d(mq_u32 target, mq_i32 level, mq_i32 x_offset, mq_i32 y_offset, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, const void *pixels) {
    glTexSubImage2D(target, level, x_offset, y_offset, width, height, format, type, pixels);
}
MQ_EXPORT void mq_gl_read_pixels(mq_i32 x, mq_i32 y, mq_i32 width, mq_i32 height, mq_u32 format, mq_u32 type, void *pixels) { glReadPixels(x, y, width, height, format, type, pixels); }
MQ_EXPORT const char *mq_gl_get_string(mq_u32 name) { return (const char *)glGetString(name); }
MQ_EXPORT mq_u32 mq_gl_get_error(void) { return glGetError(); }
MQ_EXPORT void mq_gl_finish(void) { glFinish(); }
MQ_EXPORT void mq_gl_flush(void) { glFlush(); }
MQ_EXPORT void mq_gl_draw_buffer(mq_u32 mode) { glDrawBuffer(mode); }
MQ_EXPORT mq_i32 mq_gl_multitexture_available(void) {
    return mq_valid_wgl_proc((const void *)mq_gl_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_client_active_texture_value) &&
        mq_valid_wgl_proc((const void *)mq_gl_multi_tex_coord2f_value);
}
MQ_EXPORT mq_i32 mq_gl_world_program_available(void) {
    /* The release renderer intentionally stays on GLQuake's fixed-function
     * texture-combine path. The shader bridge remains private fallback
     * infrastructure, but must not silently replace the compatibility path. */
    return 0;
}
MQ_EXPORT void mq_gl_world_program_enable(mq_i32 enabled) {
    if (!mq_valid_wgl_proc((const void *)mq_gl_use_program_value)) return;
    if (enabled && mq_gl_create_world_program()) mq_gl_use_program_value(mq_gl_world_program);
    else mq_gl_use_program_value(0u);
}
MQ_EXPORT void mq_gl_active_texture(mq_i32 unit) {
    if (!mq_valid_wgl_proc((const void *)mq_gl_active_texture_value)) return;
    mq_gl_active_texture_value(0x84C0u /* GL_TEXTURE0 */ + (mq_u32)(unit > 0 ? 1 : 0));
}
MQ_EXPORT void mq_gl_multi_tex_coord2(mq_i32 unit, mq_u32 s_bits, mq_u32 t_bits) {
    mq_i32 index = unit > 0 ? 1 : 0;
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
        count = signed_count < 0 ? (mq_u32)(-signed_count) : (mq_u32)signed_count;
        if (count > (byte_count - offset) / 12u) return 0;
        offset += count * 12u;
    }
    return 0;
}

static void mq_alias_hash_byte(mq_u8 value, mq_u64 *hash, mq_u64 *signature) {
    *hash = (*hash ^ value) * 1099511628211ull;
    *signature ^= (mq_u64)value + 0x9e3779b97f4a7c15ull + (*signature << 6) + (*signature >> 2);
}

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
