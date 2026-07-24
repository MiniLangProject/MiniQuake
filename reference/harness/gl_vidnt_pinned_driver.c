#include <windows.h>
#include "quakedef.h"
#include "resource.h"
#include <commctrl.h>

int _fltused = 0;

HINSTANCE global_hInstance = (HINSTANCE)1;
int global_nCmdShow;
HWND hwnd_dialog = (HWND)2;
qboolean ActiveApp = true;
qboolean Minimized = false;
qboolean mouseactive = false;
qboolean scr_disabled_for_loading = false;
qboolean block_drawing = false;
int key_dest = key_game;
int msg_suppress_1 = 0;
unsigned int uiWheelMessage = 0x7fff;
byte mq_host_colormap_storage[16384];
byte *host_colormap = mq_host_colormap_storage;
char com_gamedir[MAX_OSPATH] = "id1";
int com_argc;
char **com_argv;
void (*vid_menudrawfn)(void);
void (*vid_menukeyfn)(int);
lpMTexFUNC qglMTexCoord2fSGIS;
lpSelTexFUNC qglSelectTextureSGIS;
cvar_t gl_clear = {"gl_clear", "0"};

int mq_vid_window_x;
int mq_vid_window_y;
int mq_vid_window_calls;
int mq_vid_swap_calls;
int mq_vid_key_events;
int mq_vid_mouse_activations;
int mq_vid_mouse_deactivations;
int mq_vid_clip_updates;
int mq_vid_cvar_registers;
int mq_vid_command_registers;
int mq_vid_menu_prints;
int mq_vid_menu_options;
int mq_vid_enum_enabled;
const char *mq_vid_gl_vendor = "MiniGL";
const char *mq_vid_gl_renderer = "PowerVR Test";
const char *mq_vid_gl_version = "1.1";
const char *mq_vid_gl_extensions =
    "GL_EXT_texture_object GL_EXT_vertex_array GL_SGIS_multitexture ";

static char mq_console[2048];
static int mq_console_line_count;
static char *mq_window_args[] = {
    "glquake", "-width", "800", "-height", "600", NULL
};
static char *mq_gamma_args[] = {"glquake", "-gamma", "1", NULL};
static char *mq_init_args[] = {"glquake", "-window", NULL};
static qpic_t mq_menu_picture = {160, 24};

static float mq_decimal(const char *text)
{
    float value = 0.0f;
    float scale = 0.1f;
    int negative = 0;
    int fraction = 0;
    if (*text == '-')
    {
        negative = 1;
        text++;
    }
    while (*text)
    {
        if (*text == '.')
        {
            fraction = 1;
            text++;
            continue;
        }
        if (*text >= '0' && *text <= '9')
        {
            if (!fraction)
                value = value * 10.0f + (*text - '0');
            else
            {
                value += (*text - '0') * scale;
                scale *= 0.1f;
            }
        }
        text++;
    }
    return negative ? -value : value;
}

void mq_vid_console_clear(void)
{
    mq_console[0] = 0;
    mq_console_line_count = 0;
}

const char *mq_vid_console_text(void)
{
    return mq_console;
}

int mq_vid_console_lines(void)
{
    return mq_console_line_count;
}

void mq_vid_set_arguments(int count, char **values)
{
    com_argc = count;
    com_argv = values;
}

char **mq_vid_window_arguments(void)
{
    return mq_window_args;
}

char **mq_vid_gamma_arguments(void)
{
    return mq_gamma_args;
}

char **mq_vid_init_arguments(void)
{
    return mq_init_args;
}

void Sys_Error(char *format, ...)
{
    (void)format;
}

void Sys_Quit(void)
{
}

void Sys_mkdir(char *path)
{
    (void)path;
}

static void mq_console_append(char *format, va_list arguments)
{
    char temporary[512];
    int length;
    int destination = (int)strlen(mq_console);
    vsprintf(temporary, format, arguments);
    length = (int)strlen(temporary);
    while (length > 0 &&
           (temporary[length - 1] == '\n' || temporary[length - 1] == '\r'))
        temporary[--length] = 0;
    if (destination && destination < (int)sizeof(mq_console) - 1)
        mq_console[destination++] = '|';
    strncpy(
        mq_console + destination, temporary,
        sizeof(mq_console) - destination - 1);
    mq_console[sizeof(mq_console) - 1] = 0;
    mq_console_line_count++;
}

void Con_Printf(char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    mq_console_append(format, arguments);
    va_end(arguments);
}

void Con_SafePrintf(char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    mq_console_append(format, arguments);
    va_end(arguments);
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
}

int COM_CheckParm(char *parameter)
{
    int index;
    for (index = 1; index < com_argc; index++)
        if (!strcmp(com_argv[index], parameter))
            return index;
    return 0;
}

int Q_atoi(char *text)
{
    return (int)mq_decimal(text);
}

float Q_atof(char *text)
{
    return mq_decimal(text);
}

static int mq_little_long(int value)
{
    return value;
}

int (*LittleLong)(int value) = mq_little_long;

char *Cmd_Argv(int argument)
{
    (void)argument;
    return "1";
}

void Cmd_AddCommand(char *name, xcommand_t function)
{
    (void)name;
    (void)function;
    mq_vid_command_registers++;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    variable->value = mq_decimal(variable->string);
    mq_vid_cvar_registers++;
}

void Cvar_SetValue(char *name, float value)
{
    (void)name;
    (void)value;
}

void CDAudio_Pause(void)
{
}

void CDAudio_Resume(void)
{
}

LONG CDAudio_MessageHandler(HWND window, UINT message, WPARAM wparam, LPARAM lparam)
{
    (void)window;
    (void)message;
    (void)wparam;
    (void)lparam;
    return 1;
}

void IN_ActivateMouse(void)
{
    mouseactive = true;
    mq_vid_mouse_activations++;
}

void IN_DeactivateMouse(void)
{
    mouseactive = false;
    mq_vid_mouse_deactivations++;
}

void IN_HideMouse(void)
{
}

void IN_ShowMouse(void)
{
}

void IN_UpdateClipCursor(void)
{
    mq_vid_clip_updates++;
}

void IN_ClearStates(void)
{
}

void IN_MouseEvent(int state)
{
    (void)state;
}

void Key_Event(int key, qboolean down)
{
    (void)key;
    (void)down;
    mq_vid_key_events++;
}

void Key_ClearStates(void)
{
}

void S_BlockSound(void)
{
}

void S_UnblockSound(void)
{
}

void Sbar_Changed(void)
{
}

void S_LocalSound(char *sound)
{
    (void)sound;
}

qpic_t *Draw_CachePic(char *path)
{
    (void)path;
    return &mq_menu_picture;
}

void M_DrawPic(int x, int y, qpic_t *picture)
{
    (void)x;
    (void)y;
    (void)picture;
}

void M_DrawCharacter(int x, int y, int character)
{
    (void)x;
    (void)y;
    (void)character;
}

void M_DrawTransPic(int x, int y, qpic_t *picture)
{
    (void)x;
    (void)y;
    (void)picture;
}

void M_Print(int x, int y, char *text)
{
    (void)x;
    (void)y;
    (void)text;
    mq_vid_menu_prints++;
}

void M_PrintWhite(int x, int y, char *text)
{
    (void)x;
    (void)y;
    (void)text;
    mq_vid_menu_prints++;
}

void M_Menu_Options_f(void)
{
    mq_vid_menu_options++;
}

BOOL MQ_AdjustWindowRectEx(LPRECT rectangle, DWORD style, BOOL menu, DWORD exstyle)
{
    (void)style;
    (void)menu;
    (void)exstyle;
    rectangle->left -= 4;
    rectangle->right += 4;
    rectangle->top -= 20;
    rectangle->bottom += 4;
    return TRUE;
}

LONG MQ_ChangeDisplaySettings(DEVMODE *mode, DWORD flags)
{
    if (!mode)
        return DISP_CHANGE_SUCCESSFUL;
    if (!(flags & CDS_TEST))
        return DISP_CHANGE_SUCCESSFUL;
    if (!mq_vid_enum_enabled)
        return DISP_CHANGE_BADMODE;
    if ((mode->dmPelsWidth == 800 && mode->dmPelsHeight == 600) ||
        (mode->dmPelsWidth == 1024 && mode->dmPelsHeight == 768) ||
        (mode->dmPelsWidth == 5120 && mode->dmPelsHeight == 1440))
        return DISP_CHANGE_SUCCESSFUL;
    return DISP_CHANGE_BADMODE;
}

int MQ_ChoosePixelFormat(HDC dc, const PIXELFORMATDESCRIPTOR *format)
{
    (void)dc;
    (void)format;
    return 1;
}

HWND MQ_CreateWindowEx(
    DWORD exstyle, LPCSTR class_name, LPCSTR title, DWORD style,
    int x, int y, int width, int height, HWND parent, HMENU menu,
    HINSTANCE instance, LPVOID parameter)
{
    (void)exstyle;
    (void)class_name;
    (void)title;
    (void)style;
    (void)x;
    (void)y;
    (void)width;
    (void)height;
    (void)parent;
    (void)menu;
    (void)instance;
    (void)parameter;
    return (HWND)1;
}

LRESULT MQ_DefWindowProc(HWND window, UINT message, WPARAM wparam, LPARAM lparam)
{
    (void)window;
    (void)message;
    (void)wparam;
    (void)lparam;
    return 0;
}

BOOL MQ_DestroyWindow(HWND window)
{
    (void)window;
    return TRUE;
}

LRESULT MQ_DispatchMessage(const MSG *message)
{
    (void)message;
    return 0;
}

BOOL MQ_EnumDisplaySettings(LPCSTR device, DWORD index, DEVMODE *mode)
{
    (void)device;
    if (!mq_vid_enum_enabled || index >= 4)
        return FALSE;
    memset(mode, 0, sizeof(*mode));
    mode->dmSize = sizeof(*mode);
    mode->dmBitsPerPel = index == 1 ? 16 : 32;
    if (index == 0 || index == 2)
    {
        mode->dmPelsWidth = 1024;
        mode->dmPelsHeight = 768;
    }
    else if (index == 1)
    {
        mode->dmPelsWidth = 800;
        mode->dmPelsHeight = 600;
    }
    else
    {
        mode->dmPelsWidth = 5120;
        mode->dmPelsHeight = 1440;
    }
    return TRUE;
}

HDC MQ_GetDC(HWND window)
{
    (void)window;
    return (HDC)1;
}

int MQ_GetDeviceCaps(HDC dc, int index)
{
    (void)dc;
    (void)index;
    return 0;
}

static void APIENTRY MQ_ColorTable(
    int target, int internal_format, int width, int format, int type,
    const void *data)
{
    (void)target;
    (void)internal_format;
    (void)width;
    (void)format;
    (void)type;
    (void)data;
}

static void APIENTRY MQ_GenericGLProc(void)
{
}

FARPROC MQ_GetProcAddress(HMODULE module, LPCSTR name)
{
    (void)module;
    (void)name;
    return (FARPROC)MQ_GenericGLProc;
}

int MQ_GetSystemMetrics(int index)
{
    if (index == SM_CXSCREEN)
        return 1920;
    if (index == SM_CYSCREEN)
        return 1080;
    return 0;
}

void MQ_InitCommonControls(void)
{
}

HCURSOR MQ_LoadCursor(HINSTANCE instance, LPCSTR name)
{
    (void)instance;
    (void)name;
    return (HCURSOR)1;
}

HICON MQ_LoadIcon(HINSTANCE instance, LPCSTR name)
{
    (void)instance;
    (void)name;
    return (HICON)1;
}

HMODULE MQ_LoadLibrary(LPCSTR name)
{
    (void)name;
    return (HMODULE)1;
}

int MQ_MessageBox(HWND window, LPCSTR text, LPCSTR caption, UINT flags)
{
    (void)window;
    (void)text;
    (void)caption;
    (void)flags;
    return IDNO;
}

BOOL MQ_PatBlt(HDC dc, int x, int y, int width, int height, DWORD operation)
{
    (void)dc;
    (void)x;
    (void)y;
    (void)width;
    (void)height;
    (void)operation;
    return TRUE;
}

BOOL MQ_PeekMessage(LPMSG message, HWND window, UINT low, UINT high, UINT remove)
{
    (void)message;
    (void)window;
    (void)low;
    (void)high;
    (void)remove;
    return FALSE;
}

void MQ_PostQuitMessage(int code)
{
    (void)code;
}

ATOM MQ_RegisterClass(const WNDCLASS *window_class)
{
    (void)window_class;
    return 1;
}

int MQ_ReleaseDC(HWND window, HDC dc)
{
    (void)window;
    (void)dc;
    return 1;
}

LRESULT MQ_SendMessage(HWND window, UINT message, WPARAM wparam, LPARAM lparam)
{
    (void)window;
    (void)message;
    (void)wparam;
    (void)lparam;
    return 0;
}

BOOL MQ_SetForegroundWindow(HWND window)
{
    (void)window;
    return TRUE;
}

BOOL MQ_SetPixelFormat(HDC dc, int format, const PIXELFORMATDESCRIPTOR *descriptor)
{
    (void)dc;
    (void)format;
    (void)descriptor;
    return TRUE;
}

BOOL MQ_SetWindowPos(
    HWND window, HWND insert_after, int x, int y, int width, int height,
    UINT flags)
{
    (void)window;
    (void)insert_after;
    (void)width;
    (void)height;
    (void)flags;
    mq_vid_window_x = x;
    mq_vid_window_y = y;
    mq_vid_window_calls++;
    return TRUE;
}

BOOL MQ_ShowWindow(HWND window, int command)
{
    (void)window;
    (void)command;
    return TRUE;
}

void MQ_Sleep(DWORD milliseconds)
{
    (void)milliseconds;
}

BOOL MQ_SwapBuffers(HDC dc)
{
    (void)dc;
    mq_vid_swap_calls++;
    return TRUE;
}

BOOL MQ_TranslateMessage(const MSG *message)
{
    (void)message;
    return TRUE;
}

BOOL MQ_UpdateWindow(HWND window)
{
    (void)window;
    return TRUE;
}

HGLRC MQ_wglCreateContext(HDC dc)
{
    (void)dc;
    return (HGLRC)1;
}

BOOL MQ_wglDeleteContext(HGLRC context)
{
    (void)context;
    return TRUE;
}

HGLRC MQ_wglGetCurrentContext(void)
{
    return (HGLRC)1;
}

HDC MQ_wglGetCurrentDC(void)
{
    return (HDC)1;
}

PROC MQ_wglGetProcAddress(LPCSTR name)
{
    if (!strcmp(name, "glColorTableEXT"))
        return NULL;
    return (PROC)MQ_GenericGLProc;
}

BOOL MQ_wglMakeCurrent(HDC dc, HGLRC context)
{
    (void)dc;
    (void)context;
    return TRUE;
}

void APIENTRY MQ_glAlphaFunc(GLenum function, GLclampf reference)
{
    (void)function;
    (void)reference;
}

void APIENTRY MQ_glBlendFunc(GLenum source, GLenum destination)
{
    (void)source;
    (void)destination;
}

void APIENTRY MQ_glClearColor(
    GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
    (void)red;
    (void)green;
    (void)blue;
    (void)alpha;
}

void APIENTRY MQ_glCullFace(GLenum mode)
{
    (void)mode;
}

void APIENTRY MQ_glEnable(GLenum capability)
{
    (void)capability;
}

const GLubyte *APIENTRY MQ_glGetString(GLenum name)
{
    if (name == GL_VENDOR)
        return (const GLubyte *)mq_vid_gl_vendor;
    if (name == GL_RENDERER)
        return (const GLubyte *)mq_vid_gl_renderer;
    if (name == GL_VERSION)
        return (const GLubyte *)mq_vid_gl_version;
    return (const GLubyte *)mq_vid_gl_extensions;
}

void APIENTRY MQ_glPolygonMode(GLenum face, GLenum mode)
{
    (void)face;
    (void)mode;
}

void APIENTRY MQ_glShadeModel(GLenum mode)
{
    (void)mode;
}

void APIENTRY MQ_glTexEnvf(GLenum target, GLenum name, GLfloat value)
{
    (void)target;
    (void)name;
    (void)value;
}

void APIENTRY MQ_glTexParameterf(GLenum target, GLenum name, GLfloat value)
{
    (void)target;
    (void)name;
    (void)value;
}
