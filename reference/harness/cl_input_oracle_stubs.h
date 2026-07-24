#ifndef MINIQUAKE_CL_INPUT_ORACLE_STUBS_H
#define MINIQUAKE_CL_INPUT_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec3_t[3];

typedef struct kbutton_s {
    int down[2];
    int state;
} kbutton_t;

typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

typedef struct usercmd_s {
    vec3_t viewangles;
    float forwardmove;
    float sidemove;
    float upmove;
} usercmd_t;

typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

typedef struct qsocket_s {
    int marker;
} qsocket_t;

typedef struct client_state_s {
    vec3_t viewangles;
    usercmd_t cmd;
    double mtime[2];
    int movemessages;
} client_state_t;

typedef struct client_static_s {
    int signon;
    qboolean demoplayback;
    qsocket_t *netcon;
} client_static_t;

#define true 1
#define false 0
#define PITCH 0
#define YAW 1
#define ROLL 2
#define SIGNONS 4
#define clc_move 3

extern kbutton_t in_mlook, in_klook;
extern kbutton_t in_left, in_right, in_forward, in_back;
extern kbutton_t in_lookup, in_lookdown, in_moveleft, in_moveright;
extern kbutton_t in_strafe, in_speed, in_use, in_jump, in_attack;
extern kbutton_t in_up, in_down;
extern int in_impulse;

extern cvar_t cl_upspeed, cl_forwardspeed, cl_backspeed, cl_sidespeed;
extern cvar_t cl_movespeedkey, cl_yawspeed, cl_pitchspeed, cl_anglespeedkey;
extern cvar_t lookspring;
extern double host_frametime;
extern client_state_t cl;
extern client_static_t cls;

char *Cmd_Argv(int index);
int Q_atoi(char *text);
int mq_atoi(char *text);
void Con_Printf(char *format, ...);
void V_StartPitchDrift(void);
void V_StopPitchDrift(void);
float anglemod(float angle);
void *Q_memset(void *destination, int value, int count);
void MSG_WriteByte(sizebuf_t *buffer, int value);
void MSG_WriteFloat(sizebuf_t *buffer, float value);
void MSG_WriteAngle(sizebuf_t *buffer, float value);
void MSG_WriteShort(sizebuf_t *buffer, int value);
int NET_SendUnreliableMessage(qsocket_t *socket, sizebuf_t *buffer);
void CL_Disconnect(void);
void Cmd_AddCommand(char *name, void (*function)(void));

void KeyDown(kbutton_t *button);
void KeyUp(kbutton_t *button);
void IN_KLookDown(void); void IN_KLookUp(void);
void IN_MLookDown(void); void IN_MLookUp(void);
void IN_UpDown(void); void IN_UpUp(void);
void IN_DownDown(void); void IN_DownUp(void);
void IN_LeftDown(void); void IN_LeftUp(void);
void IN_RightDown(void); void IN_RightUp(void);
void IN_ForwardDown(void); void IN_ForwardUp(void);
void IN_BackDown(void); void IN_BackUp(void);
void IN_LookupDown(void); void IN_LookupUp(void);
void IN_LookdownDown(void); void IN_LookdownUp(void);
void IN_MoveleftDown(void); void IN_MoveleftUp(void);
void IN_MoverightDown(void); void IN_MoverightUp(void);
void IN_SpeedDown(void); void IN_SpeedUp(void);
void IN_StrafeDown(void); void IN_StrafeUp(void);
void IN_AttackDown(void); void IN_AttackUp(void);
void IN_UseDown(void); void IN_UseUp(void);
void IN_JumpDown(void); void IN_JumpUp(void);
void IN_Impulse(void);
float CL_KeyState(kbutton_t *button);
void CL_AdjustAngles(void);
void CL_BaseMove(usercmd_t *command);
void CL_SendMove(usercmd_t *command);
void CL_InitInput(void);

#define atoi mq_atoi

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

#endif
