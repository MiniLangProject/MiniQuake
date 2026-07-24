#include "in_win_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

extern int mouse_buttons, mouse_oldbuttonstate;
extern int mouse_x, mouse_y, old_mouse_x, old_mouse_y, mx_accum, my_accum;
extern qboolean restore_spi, mouseactive, mouseinitialized, mouseparmsvalid;
extern qboolean mouseactivatetoggle, mouseshowtoggle, dinput_acquired, dinput;
extern unsigned int uiWheelMessage;
extern qboolean joy_avail, joy_advancedinit, joy_haspov;
extern DWORD joy_oldbuttonstate, joy_oldpovstate;
extern int joy_id;
extern DWORD joy_flags, joy_numbuttons;
extern DWORD dwAxisMap[6], dwControlMap[6];
extern PDWORD pdwRawValue[6];
extern JOYINFOEX ji;
extern HINSTANCE hInstDI;
extern LPDIRECTINPUT g_pdi;
extern LPDIRECTINPUTDEVICE g_pMouse;
extern cvar_t in_joystick, joy_advanced;
extern cvar_t joy_advaxisx, joy_advaxisy;
extern cvar_t joy_forwardthreshold, joy_sidethreshold;
extern cvar_t joy_pitchthreshold, joy_yawthreshold;
extern cvar_t joy_forwardsensitivity, joy_sidesensitivity;
extern cvar_t joy_pitchsensitivity, joy_yawsensitivity;
extern cvar_t joy_wwhack1, joy_wwhack2;

int _fltused = 0;
GUID GUID_XAxis, GUID_YAxis, GUID_ZAxis, GUID_SysMouse;
client_state_t cl;
RECT window_rect = {0, 0, 640, 480};
int window_center_x = 320;
int window_center_y = 240;
HWND mainwindow = (HWND)1;
HINSTANCE global_hInstance = (HINSTANCE)2;
cvar_t sensitivity = {"sensitivity", "3", false, false, 3.0f, NULL};
cvar_t lookstrafe = {"lookstrafe", "0", false, false, 0.0f, NULL};
cvar_t m_side = {"m_side", "0.8", false, false, 0.8f, NULL};
cvar_t m_yaw = {"m_yaw", "0.022", false, false, 0.022f, NULL};
cvar_t m_pitch = {"m_pitch", "0.022", false, false, 0.022f, NULL};
cvar_t m_forward = {"m_forward", "1", false, false, 1.0f, NULL};
cvar_t cl_movespeedkey = {"cl_movespeedkey", "2", false, false, 2.0f, NULL};
cvar_t cl_yawspeed = {"cl_yawspeed", "140", false, false, 140.0f, NULL};
cvar_t cl_pitchspeed = {"cl_pitchspeed", "150", false, false, 150.0f, NULL};
cvar_t cl_forwardspeed = {"cl_forwardspeed", "200", false, false, 200.0f, NULL};
cvar_t cl_sidespeed = {"cl_sidespeed", "350", false, false, 350.0f, NULL};
cvar_t lookspring = {"lookspring", "0", false, false, 0.0f, NULL};
kbutton_t in_strafe, in_mlook, in_speed;
qboolean noclip_anglehack;
qboolean ActiveApp = true;
qboolean Minimized = false;
float host_frametime = 0.1f;

static int clip_calls;
static int cursor_show_calls;
static int cursor_x = 320;
static int cursor_y = 240;
static int set_cursor_calls;
static int capture_calls;
static int release_calls;
static int spi_get_calls;
static int spi_set_calls;
static int cvar_registers;
static int command_registers;
static int key_count_events;
static int key_codes[32];
static int key_down[32];
static int drift_stops;
static int force_nomouse;
static int force_nojoy;
static int force_dinput;
static JOYINFOEX joystick_value;

double mq_fabs(double value) { return value < 0.0 ? -value : value; }
int mq_abs(int value) { return value < 0 ? -value : value; }

static int same(const char *left, const char *right)
{
    while (*left && *right && *left == *right)
    {
        left++;
        right++;
    }
    return *left == *right;
}

static float decimal(char *text)
{
    float sign = 1.0f;
    float value = 0.0f;
    float scale = 0.1f;
    int fraction = 0;
    if (*text == '-') { sign = -1.0f; text++; }
    while (*text)
    {
        if (*text == '.') { fraction = 1; text++; continue; }
        if (*text >= '0' && *text <= '9')
        {
            if (!fraction) value = value * 10.0f + (*text - '0');
            else { value += (*text - '0') * scale; scale *= 0.1f; }
        }
        text++;
    }
    return value * sign;
}

HINSTANCE LoadLibrary(const char *name)
{
    (void)name;
    return NULL;
}

void *GetProcAddress(HINSTANCE instance, const char *name)
{
    (void)instance;
    (void)name;
    return NULL;
}

void Con_SafePrintf(char *format, ...) { (void)format; }
void Con_Printf(char *format, ...) { (void)format; }

int COM_CheckParm(char *parameter)
{
    if (same(parameter, "-nomouse")) return force_nomouse;
    if (same(parameter, "-nojoy")) return force_nojoy;
    if (same(parameter, "-dinput")) return force_dinput;
    return 0;
}

qboolean SystemParametersInfo(UINT action, UINT parameter, void *data, UINT flags)
{
    int *values = (int *)data;
    (void)parameter;
    (void)flags;
    if (action == SPI_GETMOUSE)
    {
        spi_get_calls++;
        values[0] = 6;
        values[1] = 10;
        values[2] = 1;
    }
    else
        spi_set_calls++;
    return true;
}

qboolean SetCursorPos(int x, int y)
{
    cursor_x = x;
    cursor_y = y;
    set_cursor_calls++;
    return true;
}

HWND SetCapture(HWND window)
{
    capture_calls++;
    return window;
}

qboolean ClipCursor(const RECT *rectangle)
{
    (void)rectangle;
    clip_calls++;
    return true;
}

qboolean ReleaseCapture(void)
{
    release_calls++;
    return true;
}

int ShowCursor(qboolean show)
{
    cursor_show_calls += show ? 1 : -1;
    return cursor_show_calls;
}

qboolean GetCursorPos(POINT *point)
{
    point->x = cursor_x;
    point->y = cursor_y;
    return true;
}

void Key_Event(int key, qboolean down)
{
    key_codes[key_count_events] = key;
    key_down[key_count_events] = down;
    key_count_events++;
}

void V_StopPitchDrift(void) { drift_stops++; }

void Cvar_RegisterVariable(cvar_t *variable)
{
    variable->value = decimal(variable->string);
    cvar_registers++;
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    command_registers++;
}

UINT RegisterWindowMessage(const char *name)
{
    (void)name;
    return 77;
}

UINT joyGetNumDevs(void) { return 1; }

MMRESULT joyGetPosEx(UINT identifier, JOYINFOEX *value)
{
    DWORD size = value->dwSize;
    DWORD flags = value->dwFlags;
    (void)identifier;
    *value = joystick_value;
    value->dwSize = size;
    value->dwFlags = flags;
    return JOYERR_NOERROR;
}

MMRESULT joyGetDevCaps(UINT identifier, JOYCAPS *caps, UINT size)
{
    (void)identifier;
    (void)size;
    caps->wNumButtons = 6;
    caps->wCaps = JOYCAPS_HASPOV;
    return JOYERR_NOERROR;
}

int Q_strcmp(char *left, char *right)
{
    while (*left && *right && *left == *right) { left++; right++; }
    return (unsigned char)*left - (unsigned char)*right;
}

HRESULT mq_di_acquire(LPDIRECTINPUTDEVICE device) { (void)device; return 0; }
HRESULT mq_di_unacquire(LPDIRECTINPUTDEVICE device) { (void)device; return 0; }
unsigned long mq_di_device_release(LPDIRECTINPUTDEVICE device) { (void)device; return 0; }
unsigned long mq_di_release(LPDIRECTINPUT input) { (void)input; return 0; }
HRESULT mq_di_create_device(
    LPDIRECTINPUT input, const GUID *guid, LPDIRECTINPUTDEVICE *device,
    LPUNKNOWN unknown)
{
    (void)input; (void)guid; (void)device; (void)unknown; return 0;
}
HRESULT mq_di_set_data_format(LPDIRECTINPUTDEVICE device, DIDATAFORMAT *format)
{ (void)device; (void)format; return 0; }
HRESULT mq_di_set_cooperative(LPDIRECTINPUTDEVICE device, HWND window, DWORD flags)
{ (void)device; (void)window; (void)flags; return 0; }
HRESULT mq_di_set_property(LPDIRECTINPUTDEVICE device, void *property, DIPROPHEADER *header)
{ (void)device; (void)property; (void)header; return 0; }
HRESULT mq_di_get_data(
    LPDIRECTINPUTDEVICE device, DWORD size, DIDEVICEOBJECTDATA *data,
    DWORD *elements, DWORD flags)
{
    (void)device; (void)size; (void)data; (void)flags; *elements = 0; return 0;
}

static void reset_mouse(void)
{
    mouse_buttons = 3;
    mouse_oldbuttonstate = 0;
    mouse_x = mouse_y = old_mouse_x = old_mouse_y = 0;
    mx_accum = my_accum = 0;
    restore_spi = false;
    mouseactive = false;
    mouseinitialized = true;
    mouseparmsvalid = true;
    mouseactivatetoggle = false;
    mouseshowtoggle = true;
    dinput_acquired = false;
    dinput = false;
    clip_calls = cursor_show_calls = set_cursor_calls = 0;
    capture_calls = release_calls = spi_get_calls = spi_set_calls = 0;
}

__declspec(dllexport) int __cdecl in_win_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    usercmd_t command;
    PDWORD raw;
    (void)capacity;
    memset(&cl, 0, sizeof(cl));
    memset(&command, 0, sizeof(command));
    memset(&joystick_value, 0, sizeof(joystick_value));
    joystick_value.dwXpos = 49152;
    joystick_value.dwYpos = 16384;
    joystick_value.dwZpos = 32768;
    joystick_value.dwRpos = 32768;
    joystick_value.dwUpos = 32768;
    joystick_value.dwVpos = 32768;
    joystick_value.dwPOV = JOY_POVFORWARD;

    cl.viewangles[PITCH] = 25.0f;
    Force_CenterView_f();
    cursor += sprintf(cursor,
        "{\"function\":\"Force_CenterView_f\",\"case\":\"pitch\","
        "\"pitch\":%.9g}\n", cl.viewangles[PITCH]);

    reset_mouse();
    mouseactive = true;
    IN_UpdateClipCursor();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_UpdateClipCursor\",\"case\":\"active\","
        "\"clips\":%d}\n", clip_calls);

    mouseshowtoggle = false;
    cursor_show_calls = 0;
    IN_ShowMouse();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_ShowMouse\",\"case\":\"hidden\","
        "\"toggle\":%d,\"shows\":%d}\n", mouseshowtoggle, cursor_show_calls);

    IN_HideMouse();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_HideMouse\",\"case\":\"shown\","
        "\"toggle\":%d,\"shows\":%d}\n", mouseshowtoggle, cursor_show_calls);

    reset_mouse();
    IN_ActivateMouse();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_ActivateMouse\",\"case\":\"win32\","
        "\"active\":%d,\"toggle\":%d,\"spi\":%d,\"capture\":%d,"
        "\"clips\":%d}\n",
        mouseactive, mouseactivatetoggle, spi_set_calls, capture_calls, clip_calls);

    mouseactive = false;
    IN_SetQuakeMouseState();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_SetQuakeMouseState\",\"case\":\"enabled\","
        "\"active\":%d}\n", mouseactive);

    IN_DeactivateMouse();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_DeactivateMouse\",\"case\":\"active\","
        "\"active\":%d,\"toggle\":%d,\"release\":%d}\n",
        mouseactive, mouseactivatetoggle, release_calls);

    mouseactivatetoggle = true;
    cursor_show_calls = 0;
    IN_RestoreOriginalMouseState();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_RestoreOriginalMouseState\",\"case\":\"reactivate\","
        "\"toggle\":%d,\"shows\":%d}\n",
        mouseactivatetoggle, cursor_show_calls);

    hInstDI = NULL;
    cursor += sprintf(cursor,
        "{\"function\":\"IN_InitDInput\",\"case\":\"missing-dll\","
        "\"result\":%d}\n", IN_InitDInput());

    reset_mouse();
    mouseinitialized = false;
    force_nomouse = force_dinput = 0;
    IN_StartupMouse();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_StartupMouse\",\"case\":\"classic\","
        "\"initialized\":%d,\"buttons\":%d,\"parms\":%d}\n",
        mouseinitialized, mouse_buttons, mouseparmsvalid);

    cvar_registers = command_registers = 0;
    force_nojoy = 0;
    IN_Init();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Init\",\"case\":\"register\","
        "\"cvars\":%d,\"commands\":%d,\"wheel\":%u}\n",
        cvar_registers, command_registers, uiWheelMessage);

    IN_Shutdown();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Shutdown\",\"case\":\"release\","
        "\"active\":%d,\"mouse_device\":%d,\"input\":%d}\n",
        mouseactive, g_pMouse != NULL, g_pdi != NULL);

    reset_mouse();
    mouseactive = true;
    key_count_events = 0;
    IN_MouseEvent(3);
    IN_MouseEvent(2);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_MouseEvent\",\"case\":\"edges\","
        "\"events\":%d,\"codes\":[%d,%d,%d],\"downs\":[%d,%d,%d],"
        "\"old\":%d}\n",
        key_count_events, key_codes[0], key_codes[1], key_codes[2],
        key_down[0], key_down[1], key_down[2], mouse_oldbuttonstate);

    memset(&command, 0, sizeof(command));
    cursor_x = window_center_x + 10;
    cursor_y = window_center_y - 5;
    cl.viewangles[YAW] = 0.0f;
    IN_MouseMove(&command);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_MouseMove\",\"case\":\"delta\","
        "\"yaw\":%.9g,\"forward\":%.9g,\"mouse\":[%d,%d]}\n",
        cl.viewangles[YAW], command.forwardmove, mouse_x, mouse_y);

    memset(&command, 0, sizeof(command));
    cursor_x = window_center_x + 4;
    cursor_y = window_center_y + 2;
    joy_avail = false;
    IN_Move(&command);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Move\",\"case\":\"active\","
        "\"yaw\":%.9g,\"forward\":%.9g}\n",
        cl.viewangles[YAW], command.forwardmove);
    memset(&command, 0, sizeof(command));
    cursor_x = window_center_x + 20;
    cursor_y = window_center_y + 20;
    ActiveApp = false;
    IN_Move(&command);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Move\",\"case\":\"inactive\","
        "\"forward\":%.9g,\"side\":%.9g}\n",
        command.forwardmove, command.sidemove);
    ActiveApp = true;

    mx_accum = my_accum = 0;
    cursor_x = window_center_x + 7;
    cursor_y = window_center_y - 3;
    IN_Accumulate();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Accumulate\",\"case\":\"active\","
        "\"accum\":[%d,%d]}\n", mx_accum, my_accum);

    mouse_oldbuttonstate = 7;
    IN_ClearStates();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_ClearStates\",\"case\":\"active\","
        "\"accum\":[%d,%d],\"old\":%d}\n",
        mx_accum, my_accum, mouse_oldbuttonstate);

    joy_avail = false;
    force_nojoy = 0;
    IN_StartupJoystick();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_StartupJoystick\",\"case\":\"detected\","
        "\"available\":%d,\"buttons\":%lu,\"pov\":%d,\"advanced\":%d}\n",
        joy_avail, joy_numbuttons, joy_haspov, joy_advancedinit);
    force_nojoy = 1;
    joy_avail = true;
    IN_StartupJoystick();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_StartupJoystick\",\"case\":\"disabled\","
        "\"available\":%d}\n", joy_avail);
    force_nojoy = 0;
    IN_StartupJoystick();

    ji.dwXpos = 12345;
    raw = RawValuePointer(0);
    cursor += sprintf(cursor,
        "{\"function\":\"RawValuePointer\",\"case\":\"x\","
        "\"value\":%lu}\n", *raw);

    joy_advanced.value = 0.0f;
    Joy_AdvancedUpdate_f();
    cursor += sprintf(cursor,
        "{\"function\":\"Joy_AdvancedUpdate_f\",\"case\":\"default\","
        "\"maps\":[%lu,%lu,%lu],\"controls\":[%lu,%lu],\"flags\":%lu}\n",
        dwAxisMap[0], dwAxisMap[1], dwAxisMap[2],
        dwControlMap[0], dwControlMap[1], joy_flags);
    joy_advanced.value = 1.0f;
    joy_advaxisx.value = 19.0f;
    joy_advaxisy.value = 2.0f;
    Joy_AdvancedUpdate_f();
    cursor += sprintf(cursor,
        "{\"function\":\"Joy_AdvancedUpdate_f\",\"case\":\"advanced\","
        "\"maps\":[%lu,%lu],\"controls\":[%lu,%lu]}\n",
        dwAxisMap[0], dwAxisMap[1], dwControlMap[0], dwControlMap[1]);
    joy_advanced.value = 0.0f;

    ji.dwButtons = 3;
    ji.dwPOV = JOY_POVFORWARD;
    joy_oldbuttonstate = joy_oldpovstate = 0;
    joy_numbuttons = 6;
    joy_haspov = true;
    key_count_events = 0;
    IN_Commands();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Commands\",\"case\":\"buttons-pov\","
        "\"events\":%d,\"first\":[%d,%d],\"last\":[%d,%d]}\n",
        key_count_events, key_codes[0], key_down[0],
        key_codes[key_count_events - 1], key_down[key_count_events - 1]);
    ji.dwButtons = 0;
    ji.dwPOV = JOY_POVRIGHT;
    key_count_events = 0;
    IN_Commands();
    cursor += sprintf(cursor,
        "{\"function\":\"IN_Commands\",\"case\":\"release-pov-change\","
        "\"events\":%d,\"first\":[%d,%d],\"last\":[%d,%d]}\n",
        key_count_events, key_codes[0], key_down[0],
        key_codes[key_count_events - 1], key_down[key_count_events - 1]);

    joy_wwhack1.value = 1.0f;
    joystick_value.dwUpos = 32668;
    cursor += sprintf(cursor,
        "{\"function\":\"IN_ReadJoystick\",\"case\":\"warrior\","
        "\"result\":%d,", IN_ReadJoystick());
    cursor += sprintf(cursor, "\"u\":%lu}\n", ji.dwUpos);

    joy_avail = true;
    joy_advancedinit = false;
    in_joystick.value = 1.0f;
    joy_wwhack1.value = 0.0f;
    joy_wwhack2.value = 0.0f;
    joystick_value.dwXpos = 49152;
    joystick_value.dwYpos = 16384;
    memset(&command, 0, sizeof(command));
    cl.viewangles[PITCH] = cl.viewangles[YAW] = 0.0f;
    IN_JoyMove(&command);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_JoyMove\",\"case\":\"default-axes\","
        "\"forward\":%.9g,\"side\":%.9g,\"pitch\":%.9g,\"yaw\":%.9g}\n",
        command.forwardmove, command.sidemove,
        cl.viewangles[PITCH], cl.viewangles[YAW]);
    joy_advancedinit = true;
    joy_wwhack2.value = 1.0f;
    joystick_value.dwXpos = 33268;
    joystick_value.dwYpos = 32768;
    memset(&command, 0, sizeof(command));
    cl.viewangles[PITCH] = cl.viewangles[YAW] = 0.0f;
    IN_JoyMove(&command);
    cursor += sprintf(cursor,
        "{\"function\":\"IN_JoyMove\",\"case\":\"warrior-curve\","
        "\"yaw\":%.9g}\n", cl.viewangles[YAW]);

    *cursor = 0;
    return (int)(cursor - output);
}
