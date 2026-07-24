#ifndef MINIQUAKE_CONSOLE_ORACLE_STUBS_H
#define MINIQUAKE_CONSOLE_ORACLE_STUBS_H

#include <stdarg.h>

typedef unsigned char byte;
typedef int qboolean;
typedef void (*xcommand_t)(void);

#ifndef NULL
#define NULL ((void *)0)
#endif

#define false 0
#define true 1
#define SIGNONS 4
#define O_WRONLY 1
#define O_CREAT 2
#define O_APPEND 4

typedef enum
{
    key_game,
    key_console,
    key_message,
    key_menu
} keydest_t;

typedef struct
{
    int state;
    int signon;
} client_static_t;

typedef struct
{
    unsigned width;
    unsigned height;
} viddef_t;

typedef struct cvar_s
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2

extern client_static_t cls;
extern viddef_t vid;
extern keydest_t key_dest;
extern qboolean team_message;
extern int scr_disabled_for_loading;
extern int clearnotify;
extern int scr_copytop;
extern double realtime;
extern cvar_t developer;
extern char com_gamedir[1024];
extern int key_count;
extern char chat_buffer[32];

void M_Menu_Main_f(void);
void SCR_EndLoadingPlaque(void);
void *Q_memset(void *destination, int value, int count);
void *Q_memcpy(void *destination, const void *source, int count);
int COM_CheckParm(char *parameter);
void *Hunk_AllocName(int size, char *name);
void Cvar_RegisterVariable(cvar_t *variable);
void Cmd_AddCommand(char *name, xcommand_t function);
void S_LocalSound(char *name);
void Sys_Printf(char *format, ...);
void SCR_UpdateScreen(void);
char *va(char *format, ...);
void Draw_Character(int x, int y, int character);
void Draw_String(int x, int y, char *text);
void Draw_ConsoleBackground(int lines);
double Sys_FloatTime(void);
void Sys_SendKeyEvents(void);
int unlink(char *path);
int open(char *path, int flags, int mode);
int write(int file, char *data, int count);
int close(int file);
int sprintf(char *destination, const char *format, ...);
int oracle_vsprintf(char *destination, char *format, va_list arguments);
unsigned __int64 oracle_strlen(const char *text);

#ifdef MINIQUAKE_PINNED_ORACLE
#define vsprintf oracle_vsprintf
#define strlen oracle_strlen
#endif

void Con_ToggleConsole_f(void);
void Con_Clear_f(void);
void Con_ClearNotify(void);
void Con_MessageMode_f(void);
void Con_MessageMode2_f(void);
void Con_CheckResize(void);
void Con_Init(void);
void Con_Linefeed(void);
void Con_Print(char *text);
void Con_DebugLog(char *file, char *format, ...);
void Con_Printf(char *format, ...);
void Con_DPrintf(char *format, ...);
void Con_SafePrintf(char *format, ...);
void Con_DrawInput(void);
void Con_DrawNotify(void);
void Con_DrawConsole(int lines, qboolean drawinput);
void Con_NotifyBox(char *text);

#endif
