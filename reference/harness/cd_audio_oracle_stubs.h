#ifndef MINIQUAKE_CD_AUDIO_ORACLE_STUBS_H
#define MINIQUAKE_CD_AUDIO_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef unsigned int UINT;
typedef long LONG;
typedef unsigned __int64 DWORD;
typedef unsigned __int64 WPARAM;
typedef unsigned __int64 LPARAM;
typedef void *HWND;
typedef void *LPVOID;
typedef void (*xcommand_t)(void);

#ifndef NULL
#define NULL ((void *)0)
#endif
#define false 0
#define true 1

typedef struct cvar_s
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

typedef struct
{
    int state;
} client_static_t;

#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2

typedef struct
{
    DWORD dwCallback;
} MCI_GENERIC_PARMS;

typedef struct
{
    DWORD dwCallback;
    UINT wDeviceID;
    const char *lpstrDeviceType;
} MCI_OPEN_PARMS;

typedef struct
{
    DWORD dwCallback;
    DWORD dwTimeFormat;
} MCI_SET_PARMS;

typedef struct
{
    DWORD dwCallback;
    DWORD dwReturn;
    DWORD dwItem;
    DWORD dwTrack;
} MCI_STATUS_PARMS;

typedef struct
{
    DWORD dwCallback;
    DWORD dwFrom;
    DWORD dwTo;
} MCI_PLAY_PARMS;

#define MCI_SET 1
#define MCI_STATUS 2
#define MCI_OPEN 3
#define MCI_CLOSE 4
#define MCI_PLAY 5
#define MCI_STOP 6
#define MCI_PAUSE 7
#define MCI_SET_DOOR_OPEN 11
#define MCI_SET_DOOR_CLOSED 12
#define MCI_STATUS_READY 21
#define MCI_STATUS_NUMBER_OF_TRACKS 22
#define MCI_CDA_STATUS_TYPE_TRACK 23
#define MCI_STATUS_LENGTH 24
#define MCI_CDA_TRACK_AUDIO 25
#define MCI_OPEN_TYPE 0x1
#define MCI_OPEN_SHAREABLE 0x2
#define MCI_SET_TIME_FORMAT 0x4
#define MCI_FORMAT_TMSF 0x8
#define MCI_STATUS_ITEM 0x10
#define MCI_TRACK 0x20
#define MCI_WAIT 0x40
#define MCI_NOTIFY 0x80
#define MCI_FROM 0x100
#define MCI_TO 0x200
#define MCI_NOTIFY_SUCCESSFUL 1
#define MCI_NOTIFY_ABORTED 2
#define MCI_NOTIFY_SUPERSEDED 3
#define MCI_NOTIFY_FAILURE 4
#define MCI_MAKE_TMSF(t,m,s,f) \
    ((DWORD)(t) | ((DWORD)(m) << 8) | ((DWORD)(s) << 16) | ((DWORD)(f) << 24))

extern HWND mainwindow;
extern cvar_t bgmvolume;
extern client_static_t cls;

DWORD mciSendCommand(UINT device, UINT message, DWORD flags, DWORD parameter);
void Con_DPrintf(char *format, ...);
void Con_Printf(char *format, ...);
int Cmd_Argc(void);
char *Cmd_Argv(int index);
int Q_strcasecmp(char *left, char *right);
int Q_atoi(char *text);
void Cvar_SetValue(char *name, float value);
void Cmd_AddCommand(char *name, xcommand_t function);
int COM_CheckParm(char *parameter);

void CDAudio_Play(byte track, qboolean looping);
void CDAudio_Stop(void);
void CDAudio_Pause(void);
void CDAudio_Resume(void);
void CD_f(void);
void CDAudio_Update(void);
int CDAudio_Init(void);
void CDAudio_Shutdown(void);

#endif
