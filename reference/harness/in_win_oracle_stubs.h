#ifndef MINIQUAKE_IN_WIN_ORACLE_STUBS_H
#define MINIQUAKE_IN_WIN_ORACLE_STUBS_H

typedef int qboolean;
typedef unsigned char BYTE;
typedef unsigned long DWORD;
typedef DWORD *PDWORD;
typedef long LONG;
typedef long HRESULT;
typedef unsigned int UINT;
typedef void *HINSTANCE;
typedef void *HWND;
typedef void *HDC;
typedef void *LPUNKNOWN;
typedef unsigned int MMRESULT;
#define WINAPI
#define NULL ((void *)0)
#define true 1
#define false 0
#define TRUE 1
#define FALSE 0
#define FAILED(value) ((value) < 0)

typedef struct { LONG x; LONG y; } POINT;
typedef struct { LONG left; LONG top; LONG right; LONG bottom; } RECT;
typedef struct cvar_s
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;
typedef struct { float forwardmove; float sidemove; float upmove; } usercmd_t;
typedef struct { float viewangles[3]; } client_state_t;
typedef struct { int state; } kbutton_t;
typedef struct { DWORD Data1; } GUID;

typedef struct
{
    const GUID *pguid;
    DWORD dwOfs;
    DWORD dwType;
    DWORD dwFlags;
} DIOBJECTDATAFORMAT;
typedef struct
{
    DWORD dwSize;
    DWORD dwObjSize;
    DWORD dwFlags;
    DWORD dwDataSize;
    DWORD dwNumObjs;
    DIOBJECTDATAFORMAT *rgodf;
} DIDATAFORMAT;
typedef struct
{
    DWORD dwSize;
    DWORD dwHeaderSize;
    DWORD dwObj;
    DWORD dwHow;
} DIPROPHEADER;
typedef struct { DIPROPHEADER diph; DWORD dwData; } DIPROPDWORD;
typedef struct
{
    DWORD dwOfs;
    DWORD dwData;
    DWORD dwTimeStamp;
    DWORD dwSequence;
} DIDEVICEOBJECTDATA;

typedef struct IDirectInput *LPDIRECTINPUT;
typedef struct IDirectInputDevice *LPDIRECTINPUTDEVICE;

typedef struct
{
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
} JOYINFOEX;
typedef struct { UINT wNumButtons; UINT wCaps; } JOYCAPS;

#define FIELD_OFFSET(type, field) ((DWORD)(unsigned __int64)&(((type *)0)->field))
#define DIDFT_AXIS 1
#define DIDFT_BUTTON 2
#define DIDFT_ANYINSTANCE 4
#define DIDF_RELAXIS 1
#define DIPH_DEVICE 0
#define DIRECTINPUT_VERSION 0x300
#define DISCL_EXCLUSIVE 1
#define DISCL_FOREGROUND 2
#define DIPROP_BUFFERSIZE ((void *)1)
#define DIERR_INPUTLOST ((HRESULT)-1)
#define DIERR_NOTACQUIRED ((HRESULT)-2)
#define DIMOFS_X 0
#define DIMOFS_Y 4
#define DIMOFS_BUTTON0 12
#define DIMOFS_BUTTON1 13
#define DIMOFS_BUTTON2 14

#define JOY_RETURNX 0x1
#define JOY_RETURNY 0x2
#define JOY_RETURNZ 0x4
#define JOY_RETURNR 0x8
#define JOY_RETURNU 0x10
#define JOY_RETURNV 0x20
#define JOY_RETURNBUTTONS 0x40
#define JOY_RETURNPOV 0x80
#define JOY_RETURNCENTERED 0x100
#define JOYCAPS_HASPOV 1
#define JOYERR_NOERROR 0
#define JOY_POVCENTERED 65535
#define JOY_POVFORWARD 0
#define JOY_POVRIGHT 9000
#define JOY_POVBACKWARD 18000
#define JOY_POVLEFT 27000

#define SPI_GETMOUSE 1
#define SPI_SETMOUSE 2
#define PITCH 0
#define YAW 1
#define K_MOUSE1 200
#define K_JOY1 203
#define K_AUX1 207
#define K_AUX29 235
#define fabs mq_fabs
#define abs mq_abs

extern GUID GUID_XAxis;
extern GUID GUID_YAxis;
extern GUID GUID_ZAxis;
extern GUID GUID_SysMouse;
extern client_state_t cl;
extern RECT window_rect;
extern int window_center_x;
extern int window_center_y;
extern HWND mainwindow;
extern HINSTANCE global_hInstance;
extern cvar_t sensitivity;
extern cvar_t lookstrafe;
extern cvar_t m_side;
extern cvar_t m_yaw;
extern cvar_t m_pitch;
extern cvar_t m_forward;
extern cvar_t cl_movespeedkey;
extern cvar_t cl_yawspeed;
extern cvar_t cl_pitchspeed;
extern cvar_t cl_forwardspeed;
extern cvar_t cl_sidespeed;
extern cvar_t lookspring;
extern kbutton_t in_strafe;
extern kbutton_t in_mlook;
extern kbutton_t in_speed;
extern qboolean noclip_anglehack;
extern qboolean ActiveApp;
extern qboolean Minimized;
extern float host_frametime;

void *memset(void *, int, unsigned __int64);
double mq_fabs(double);
int mq_abs(int);
double pow(double, double);
HINSTANCE LoadLibrary(const char *);
void *GetProcAddress(HINSTANCE, const char *);
void Con_SafePrintf(char *, ...);
void Con_Printf(char *, ...);
int COM_CheckParm(char *);
qboolean SystemParametersInfo(UINT, UINT, void *, UINT);
qboolean SetCursorPos(int, int);
HWND SetCapture(HWND);
qboolean ClipCursor(const RECT *);
qboolean ReleaseCapture(void);
int ShowCursor(qboolean);
qboolean GetCursorPos(POINT *);
void Key_Event(int, qboolean);
void V_StopPitchDrift(void);
void Cvar_RegisterVariable(cvar_t *);
void Cmd_AddCommand(char *, void (*)(void));
UINT RegisterWindowMessage(const char *);
UINT joyGetNumDevs(void);
MMRESULT joyGetPosEx(UINT, JOYINFOEX *);
MMRESULT joyGetDevCaps(UINT, JOYCAPS *, UINT);
int Q_strcmp(char *, char *);

HRESULT mq_di_acquire(LPDIRECTINPUTDEVICE);
HRESULT mq_di_unacquire(LPDIRECTINPUTDEVICE);
unsigned long mq_di_device_release(LPDIRECTINPUTDEVICE);
unsigned long mq_di_release(LPDIRECTINPUT);
HRESULT mq_di_create_device(
    LPDIRECTINPUT, const GUID *, LPDIRECTINPUTDEVICE *, LPUNKNOWN);
HRESULT mq_di_set_data_format(LPDIRECTINPUTDEVICE, DIDATAFORMAT *);
HRESULT mq_di_set_cooperative(LPDIRECTINPUTDEVICE, HWND, DWORD);
HRESULT mq_di_set_property(LPDIRECTINPUTDEVICE, void *, DIPROPHEADER *);
HRESULT mq_di_get_data(
    LPDIRECTINPUTDEVICE, DWORD, DIDEVICEOBJECTDATA *, DWORD *, DWORD);

#define IDirectInputDevice_Acquire mq_di_acquire
#define IDirectInputDevice_Unacquire mq_di_unacquire
#define IDirectInputDevice_Release mq_di_device_release
#define IDirectInput_Release mq_di_release
#define IDirectInput_CreateDevice mq_di_create_device
#define IDirectInputDevice_SetDataFormat mq_di_set_data_format
#define IDirectInputDevice_SetCooperativeLevel mq_di_set_cooperative
#define IDirectInputDevice_SetProperty mq_di_set_property
#define IDirectInputDevice_GetDeviceData mq_di_get_data

void Force_CenterView_f(void);
void IN_UpdateClipCursor(void);
void IN_ShowMouse(void);
void IN_HideMouse(void);
void IN_ActivateMouse(void);
void IN_SetQuakeMouseState(void);
void IN_DeactivateMouse(void);
void IN_RestoreOriginalMouseState(void);
qboolean IN_InitDInput(void);
void IN_StartupMouse(void);
void IN_Init(void);
void IN_Shutdown(void);
void IN_MouseEvent(int);
void IN_MouseMove(usercmd_t *);
void IN_Move(usercmd_t *);
void IN_Accumulate(void);
void IN_ClearStates(void);
void IN_StartupJoystick(void);
PDWORD RawValuePointer(int);
void Joy_AdvancedUpdate_f(void);
void IN_Commands(void);
qboolean IN_ReadJoystick(void);
void IN_JoyMove(usercmd_t *);

#endif
