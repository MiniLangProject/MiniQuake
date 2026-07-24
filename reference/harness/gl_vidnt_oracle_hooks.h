#ifndef MINIQUAKE_GL_VIDNT_ORACLE_HOOKS_H
#define MINIQUAKE_GL_VIDNT_ORACLE_HOOKS_H

/*
 * Deterministic Win32/OpenGL boundary used only by the patched, detached
 * GLQuake gl_vidnt.c oracle.  The production source remains untouched.
 */

#undef AdjustWindowRectEx
#undef ChangeDisplaySettings
#undef ChoosePixelFormat
#undef CreateWindowEx
#undef DefWindowProc
#undef DestroyWindow
#undef DispatchMessage
#undef EnumDisplaySettings
#undef GetDC
#undef GetDeviceCaps
#undef GetProcAddress
#undef GetSystemMetrics
#undef InitCommonControls
#undef LoadCursor
#undef LoadIcon
#undef LoadLibrary
#undef MessageBox
#undef PatBlt
#undef PeekMessage
#undef PostQuitMessage
#undef RegisterClass
#undef ReleaseDC
#undef SendMessage
#undef SetForegroundWindow
#undef SetPixelFormat
#undef SetWindowPos
#undef ShowWindow
#undef Sleep
#undef SwapBuffers
#undef TranslateMessage
#undef UpdateWindow
#undef wglCreateContext
#undef wglDeleteContext
#undef wglGetCurrentContext
#undef wglGetCurrentDC
#undef wglGetProcAddress
#undef wglMakeCurrent
#undef glAlphaFunc
#undef glBlendFunc
#undef glClearColor
#undef glCullFace
#undef glEnable
#undef glGetString
#undef glPolygonMode
#undef glShadeModel
#undef glTexEnvf
#undef glTexParameterf

#define strnicmp _strnicmp
#define AdjustWindowRectEx MQ_AdjustWindowRectEx
#define ChangeDisplaySettings MQ_ChangeDisplaySettings
#define ChoosePixelFormat MQ_ChoosePixelFormat
#define CreateWindowEx MQ_CreateWindowEx
#define DefWindowProc MQ_DefWindowProc
#define DestroyWindow MQ_DestroyWindow
#define DispatchMessage MQ_DispatchMessage
#define EnumDisplaySettings MQ_EnumDisplaySettings
#define GetDC MQ_GetDC
#define GetDeviceCaps MQ_GetDeviceCaps
#define GetProcAddress MQ_GetProcAddress
#define GetSystemMetrics MQ_GetSystemMetrics
#define InitCommonControls MQ_InitCommonControls
#define LoadCursor MQ_LoadCursor
#define LoadIcon MQ_LoadIcon
#define LoadLibrary MQ_LoadLibrary
#define MessageBox MQ_MessageBox
#define PatBlt MQ_PatBlt
#define PeekMessage MQ_PeekMessage
#define PostQuitMessage MQ_PostQuitMessage
#define RegisterClass MQ_RegisterClass
#define ReleaseDC MQ_ReleaseDC
#define SendMessage MQ_SendMessage
#define SetForegroundWindow MQ_SetForegroundWindow
#define SetPixelFormat MQ_SetPixelFormat
#define SetWindowPos MQ_SetWindowPos
#define ShowWindow MQ_ShowWindow
#define Sleep MQ_Sleep
#define SwapBuffers MQ_SwapBuffers
#define TranslateMessage MQ_TranslateMessage
#define UpdateWindow MQ_UpdateWindow
#define wglCreateContext MQ_wglCreateContext
#define wglDeleteContext MQ_wglDeleteContext
#define wglGetCurrentContext MQ_wglGetCurrentContext
#define wglGetCurrentDC MQ_wglGetCurrentDC
#define wglGetProcAddress MQ_wglGetProcAddress
#define wglMakeCurrent MQ_wglMakeCurrent
#define glAlphaFunc MQ_glAlphaFunc
#define glBlendFunc MQ_glBlendFunc
#define glClearColor MQ_glClearColor
#define glCullFace MQ_glCullFace
#define glEnable MQ_glEnable
#define glGetString MQ_glGetString
#define glPolygonMode MQ_glPolygonMode
#define glShadeModel MQ_glShadeModel
#define glTexEnvf MQ_glTexEnvf
#define glTexParameterf MQ_glTexParameterf

extern int mq_vid_window_x;
extern int mq_vid_window_y;
extern int mq_vid_window_calls;
extern int mq_vid_swap_calls;
extern int mq_vid_key_events;
extern int mq_vid_mouse_activations;
extern int mq_vid_mouse_deactivations;
extern int mq_vid_clip_updates;
extern int mq_vid_cvar_registers;
extern int mq_vid_command_registers;
extern int mq_vid_menu_prints;
extern int mq_vid_menu_options;
extern int mq_vid_enum_enabled;
extern const char *mq_vid_gl_vendor;
extern const char *mq_vid_gl_renderer;
extern const char *mq_vid_gl_version;
extern const char *mq_vid_gl_extensions;

void mq_vid_console_clear(void);
const char *mq_vid_console_text(void);
int mq_vid_console_lines(void);
void mq_vid_set_arguments(int count, char **values);
char **mq_vid_window_arguments(void);
char **mq_vid_gamma_arguments(void);
char **mq_vid_init_arguments(void);

BOOL MQ_AdjustWindowRectEx(LPRECT, DWORD, BOOL, DWORD);
LONG MQ_ChangeDisplaySettings(DEVMODE *, DWORD);
int MQ_ChoosePixelFormat(HDC, const PIXELFORMATDESCRIPTOR *);
HWND MQ_CreateWindowEx(
    DWORD, LPCSTR, LPCSTR, DWORD, int, int, int, int,
    HWND, HMENU, HINSTANCE, LPVOID);
LRESULT MQ_DefWindowProc(HWND, UINT, WPARAM, LPARAM);
BOOL MQ_DestroyWindow(HWND);
LRESULT MQ_DispatchMessage(const MSG *);
BOOL MQ_EnumDisplaySettings(LPCSTR, DWORD, DEVMODE *);
HDC MQ_GetDC(HWND);
int MQ_GetDeviceCaps(HDC, int);
FARPROC MQ_GetProcAddress(HMODULE, LPCSTR);
int MQ_GetSystemMetrics(int);
void MQ_InitCommonControls(void);
HCURSOR MQ_LoadCursor(HINSTANCE, LPCSTR);
HICON MQ_LoadIcon(HINSTANCE, LPCSTR);
HMODULE MQ_LoadLibrary(LPCSTR);
int MQ_MessageBox(HWND, LPCSTR, LPCSTR, UINT);
BOOL MQ_PatBlt(HDC, int, int, int, int, DWORD);
BOOL MQ_PeekMessage(LPMSG, HWND, UINT, UINT, UINT);
void MQ_PostQuitMessage(int);
ATOM MQ_RegisterClass(const WNDCLASS *);
int MQ_ReleaseDC(HWND, HDC);
LRESULT MQ_SendMessage(HWND, UINT, WPARAM, LPARAM);
BOOL MQ_SetForegroundWindow(HWND);
BOOL MQ_SetPixelFormat(HDC, int, const PIXELFORMATDESCRIPTOR *);
BOOL MQ_SetWindowPos(HWND, HWND, int, int, int, int, UINT);
BOOL MQ_ShowWindow(HWND, int);
void MQ_Sleep(DWORD);
BOOL MQ_SwapBuffers(HDC);
BOOL MQ_TranslateMessage(const MSG *);
BOOL MQ_UpdateWindow(HWND);
HGLRC MQ_wglCreateContext(HDC);
BOOL MQ_wglDeleteContext(HGLRC);
HGLRC MQ_wglGetCurrentContext(void);
HDC MQ_wglGetCurrentDC(void);
PROC MQ_wglGetProcAddress(LPCSTR);
BOOL MQ_wglMakeCurrent(HDC, HGLRC);

void APIENTRY MQ_glAlphaFunc(GLenum, GLclampf);
void APIENTRY MQ_glBlendFunc(GLenum, GLenum);
void APIENTRY MQ_glClearColor(GLclampf, GLclampf, GLclampf, GLclampf);
void APIENTRY MQ_glCullFace(GLenum);
void APIENTRY MQ_glEnable(GLenum);
const GLubyte *APIENTRY MQ_glGetString(GLenum);
void APIENTRY MQ_glPolygonMode(GLenum, GLenum);
void APIENTRY MQ_glShadeModel(GLenum);
void APIENTRY MQ_glTexEnvf(GLenum, GLenum, GLfloat);
void APIENTRY MQ_glTexParameterf(GLenum, GLenum, GLfloat);

#endif
