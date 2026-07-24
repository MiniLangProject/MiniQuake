#ifndef MINIQUAKE_SV_USER_ORACLE_STUBS_H
#define MINIQUAKE_SV_USER_ORACLE_STUBS_H

__declspec(dllimport) double __cdecl sin(double);
__declspec(dllimport) double __cdecl cos(double);
__declspec(dllimport) double __cdecl sqrt(double);

typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

typedef struct {
    vec3_t angles;
    vec3_t origin;
    vec3_t view_ofs;
    vec3_t mins;
    vec3_t velocity;
    vec3_t punchangle;
    vec3_t v_angle;
    vec3_t movedir;
    float flags;
    float idealpitch;
    float teleport_time;
    float waterlevel;
    float movetype;
    float health;
    float fixangle;
    float button0;
    float button2;
    float impulse;
} entvars_t;

typedef struct edict_s {
    entvars_t v;
} edict_t;

typedef struct {
    float forwardmove;
    float sidemove;
    float upmove;
} usercmd_t;

typedef struct {
    qboolean allsolid;
    qboolean startsolid;
    qboolean inopen;
    qboolean inwater;
    float fraction;
    vec3_t endpos;
} trace_t;

typedef struct {
    float time;
    qboolean paused;
} server_t;

typedef struct client_s {
    qboolean active;
    qboolean spawned;
    qboolean dropasap;
    qboolean privileged;
    qboolean sendsignon;
    double last_message;
    void *netconnection;
    usercmd_t cmd;
    vec3_t wishdir;
    edict_t *edict;
    char name[32];
    float ping_times[16];
    int num_pings;
} client_t;

typedef struct {
    client_t *clients;
    int maxclients;
} server_static_t;

extern server_t sv;
extern server_static_t svs;
extern client_t *host_client;
extern double host_frametime;
extern vec3_t vec3_origin;
extern int msg_badread;
extern int key_dest;

#define false 0
#define true 1
#define PITCH 0
#define YAW 1
#define ROLL 2
#define FL_FLY 1
#define FL_SWIM 2
#define FL_ONGROUND 512
#define FL_WATERJUMP 2048
#define MOVETYPE_NONE 0
#define MOVETYPE_WALK 3
#define MOVETYPE_NOCLIP 8
#define NUM_PING_TIMES 16
#define clc_nop 1
#define clc_disconnect 2
#define clc_move 3
#define clc_stringcmd 4
#define src_client 0
#define key_game 0
#define ON_EPSILON 0.1
#define M_PI 3.14159265358979323846

#define DotProduct(x,y) ((x)[0]*(y)[0] + (x)[1]*(y)[1] + (x)[2]*(y)[2])
#define VectorCopy(in,out) \
    ((out)[0]=(in)[0], (out)[1]=(in)[1], (out)[2]=(in)[2])
#define VectorAdd(a,b,out) \
    ((out)[0]=(a)[0]+(b)[0], (out)[1]=(a)[1]+(b)[1], \
     (out)[2]=(a)[2]+(b)[2])
#define VectorScale(in,scale,out) \
    ((out)[0]=(in)[0]*(scale), (out)[1]=(in)[1]*(scale), \
     (out)[2]=(in)[2]*(scale))

float VectorNormalize(vec3_t value);
float Length(vec3_t value);
void AngleVectors(vec3_t angles, vec3_t forward, vec3_t right, vec3_t up);
trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict);
float V_CalcRoll(vec3_t angles, vec3_t velocity);
float MSG_ReadFloat(void);
float MSG_ReadAngle(void);
int MSG_ReadShort(void);
int MSG_ReadByte(void);
int MSG_ReadChar(void);
char *MSG_ReadString(void);
void MSG_BeginReading(void);
int NET_GetMessage(void *connection);
int Q_strncasecmp(char *left, char *right, int count);
void Cbuf_InsertText(char *text);
void Cmd_ExecuteString(char *text, int source);
void Con_DPrintf(char *format, ...);
void Sys_Printf(char *format, ...);
void SV_DropClient(qboolean crash);

#endif
