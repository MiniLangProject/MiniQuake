#ifndef MINIQUAKE_GL_SCREEN_ORACLE_STUBS_H
#define MINIQUAKE_GL_SCREEN_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
#define true 1
#define false 0
#define NULL ((void *)0)
#define M_PI 3.14159265358979323846
#define MAX_OSPATH 260
#define SIGNONS 4
#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2
#define key_game 0
#define key_console 1
#define key_message 2
#define K_ESCAPE 27
#define GL_RGB 1
#define GL_UNSIGNED_BYTE 2
#define strncpy mq_strncpy
#define tan mq_tan
#define atan mq_atan

typedef struct cvar_s
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

typedef struct { int width; int height; } qpic_t;
typedef struct { int x; int y; int width; int height; } vrect_t;
typedef struct
{
    int width;
    int height;
    int numpages;
    int recalc_refdef;
} viddef_t;
typedef struct
{
    vrect_t vrect;
    float fov_x;
    float fov_y;
} refdef_t;
typedef struct { int percent; } cshift_t;
typedef struct
{
    float time;
    int intermission;
    float last_received_message;
    qboolean paused;
    void *worldmodel;
    cshift_t cshifts[4];
} client_state_t;
typedef struct
{
    int state;
    int signon;
    qboolean demoplayback;
} client_static_t;

extern client_state_t cl;
extern client_static_t cls;
extern refdef_t r_refdef;
extern float host_frametime;
extern float realtime;
extern int key_dest;
extern int key_count;
extern int key_lastpress;
extern qboolean r_cache_thrash;
extern qboolean con_forcedup;
extern int con_notifylines;
extern qboolean con_initialized;
extern byte *host_basepal;
extern cvar_t crosshair;
extern char com_gamedir[MAX_OSPATH];

char *mq_strncpy(char *, const char *, unsigned __int64);
char *strcpy(char *, const char *);
int sprintf(char *, const char *, ...);
void *malloc(unsigned __int64);
void free(void *);
void *memset(void *, int, unsigned __int64);
double mq_tan(double);
double mq_atan(double);
void Sys_Error(char *, ...);
void Con_Printf(char *, ...);
void Cvar_Set(char *, char *);
void Cvar_SetValue(char *, float);
void Cvar_RegisterVariable(cvar_t *);
void Cmd_AddCommand(char *, void (*)(void));
void Sbar_Changed(void);
qpic_t *Draw_PicFromWad(char *);
void Draw_Pic(int, int, qpic_t *);
qpic_t *Draw_CachePic(char *);
void Draw_Character(int, int, int);
void Con_CheckResize(void);
void Con_DrawConsole(float, qboolean);
void Con_DrawNotify(void);
int Sys_FileTime(char *);
void glReadPixels(int, int, int, int, int, int, void *);
void COM_WriteFile(char *, void *, int);
void S_StopAllSounds(qboolean);
void Con_ClearNotify(void);
void S_ClearBuffer(void);
void Sys_SendKeyEvents(void);
void VID_SetPalette(byte *);
void Draw_TileClear(int, int, int, int);
void GL_BeginRendering(int *, int *, int *, int *);
void V_RenderView(void);
void GL_Set2D(void);
void Sbar_Draw(void);
void Draw_FadeScreen(void);
void Sbar_IntermissionOverlay(void);
void Sbar_FinaleOverlay(void);
void M_Draw(void);
void V_UpdatePalette(void);
void GL_EndRendering(void);

void SCR_CenterPrint(char *);
void SCR_DrawCenterString(void);
void SCR_CheckDrawCenterString(void);
float CalcFov(float, float, float);
void SCR_CalcRefdef(void);
void SCR_SizeUp_f(void);
void SCR_SizeDown_f(void);
void SCR_Init(void);
void SCR_DrawRam(void);
void SCR_DrawTurtle(void);
void SCR_DrawNet(void);
void SCR_DrawPause(void);
void SCR_DrawLoading(void);
void SCR_SetUpToDrawConsole(void);
void SCR_DrawConsole(void);
void SCR_ScreenShot_f(void);
void SCR_BeginLoadingPlaque(void);
void SCR_EndLoadingPlaque(void);
void SCR_DrawNotifyString(void);
int SCR_ModalMessage(char *);
void SCR_BringDownConsole(void);
void SCR_TileClear(void);
void SCR_UpdateScreen(void);

#endif
