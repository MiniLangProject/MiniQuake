#ifndef MINIQUAKE_PR_CMDS_ORACLE_STUBS_H
#define MINIQUAKE_PR_CMDS_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec3_t[3];
typedef void (*builtin_t)(void);

typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;
typedef struct plane_s {
    vec3_t normal;
    float dist;
} plane_t;
struct edict_s;
typedef struct trace_s {
    qboolean allsolid;
    qboolean startsolid;
    qboolean inopen;
    qboolean inwater;
    float fraction;
    vec3_t endpos;
    plane_t plane;
    struct edict_s *ent;
} trace_t;
typedef struct mleaf_s {
    int marker;
} mleaf_t;
typedef struct model_s {
    vec3_t mins;
    vec3_t maxs;
    int numleafs;
    mleaf_t *leafs;
} model_t;
typedef struct entvars_s {
    vec3_t origin;
    vec3_t angles;
    vec3_t mins;
    vec3_t maxs;
    vec3_t size;
    vec3_t absmin;
    vec3_t absmax;
    vec3_t view_ofs;
    int model;
    float modelindex;
    float frame;
    float colormap;
    float skin;
    float health;
    float flags;
    float solid;
    int chain;
    float takedamage;
    float team;
    float ideal_yaw;
    float yaw_speed;
    int groundentity;
    int classname;
} entvars_t;
typedef struct edict_s {
    qboolean free;
    entvars_t v;
} edict_t;
typedef struct client_s {
    qboolean active;
    qboolean spawned;
    sizebuf_t message;
    byte message_buf[1024];
    float spawn_parms[16];
} client_t;
typedef struct server_s {
    char *model_precache[256];
    model_t *models[256];
    char *sound_precache[256];
    sizebuf_t signon;
    sizebuf_t datagram;
    sizebuf_t reliable_datagram;
    byte signon_buf[4096];
    byte datagram_buf[4096];
    byte reliable_buf[4096];
    edict_t *edicts;
    int num_edicts;
    model_t *worldmodel;
    float time;
    int lastcheck;
    float lastchecktime;
    char *lightstyles[64];
    int state;
} server_t;
typedef struct server_static_s {
    int maxclients;
    client_t *clients;
    qboolean changelevel_issued;
} server_static_t;
typedef struct globalvars_s {
    float pad[28];
    int self;
    int msg_entity;
    vec3_t v_forward;
    vec3_t v_right;
    vec3_t v_up;
    float trace_allsolid;
    float trace_startsolid;
    float trace_fraction;
    float trace_inwater;
    float trace_inopen;
    vec3_t trace_endpos;
    vec3_t trace_plane_normal;
    float trace_plane_dist;
    int trace_ent;
    float parm1;
    float parm2;
    float parm3;
    float parm4;
    float parm5;
    float parm6;
    float parm7;
    float parm8;
    float parm9;
    float parm10;
    float parm11;
    float parm12;
    float parm13;
    float parm14;
    float parm15;
    float parm16;
    float serverflags;
} globalvars_t;
typedef struct dfunction_s {
    int s_name;
} dfunction_t;
typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

#define true 1
#define false 0
#define NULL 0
#define OFS_RETURN 1
#define OFS_PARM0 4
#define OFS_PARM1 7
#define OFS_PARM2 10
#define OFS_PARM3 13
#define OFS_PARM4 16
#define OFS_PARM5 19
#define OFS_PARM6 22
#define OFS_PARM7 25
#define MAX_SOUNDS 256
#define MAX_MODELS 256
#define MAX_MAP_LEAFS 8192
#define NUM_SPAWN_PARMS 16
#define SOLID_NOT 0
#define FL_FLY 1
#define FL_SWIM 2
#define FL_ONGROUND 512
#define FL_NOTARGET 128
#define FL_ITEM 256
#define DAMAGE_AIM 2
#define ss_loading 1
#define ss_active 2
#define svc_print 8
#define svc_centerprint 26
#define svc_spawnstaticsound 29
#define svc_lightstyle 12
#define svc_spawnstatic 20
#define M_PI 3.14159265358979323846

extern float *pr_globals;
extern char *pr_strings;
extern globalvars_t *pr_global_struct;
extern dfunction_t *pr_xfunction;
extern int pr_argc;
extern qboolean pr_trace;
extern server_t sv;
extern server_static_t svs;
extern client_t *host_client;
extern vec3_t vec3_origin;
extern cvar_t teamplay;

#define G_FLOAT(o) (pr_globals[(o)])
#define G_INT(o) (((int *)pr_globals)[(o)])
#define G_VECTOR(o) (&pr_globals[(o)])
#define G_STRING(o) (pr_strings + G_INT(o))
#define EDICT_NUM(n) (&sv.edicts[(n)])
#define NUM_FOR_EDICT(e) ((int)((e) - sv.edicts))
#define EDICT_TO_PROG(e) NUM_FOR_EDICT(e)
#define PROG_TO_EDICT(n) EDICT_NUM(n)
#define G_EDICT(o) PROG_TO_EDICT(G_INT(o))
#define G_EDICTNUM(o) G_INT(o)
#define NEXT_EDICT(e) ((e) + 1)
#define E_STRING(e,f) (pr_strings + ((int *)&(e)->v)[(f)])

#define VectorCopy(a,b) do {(b)[0]=(a)[0];(b)[1]=(a)[1];(b)[2]=(a)[2];} while(0)
#define VectorAdd(a,b,c) do {(c)[0]=(a)[0]+(b)[0];(c)[1]=(a)[1]+(b)[1];(c)[2]=(a)[2]+(b)[2];} while(0)
#define VectorSubtract(a,b,c) do {(c)[0]=(a)[0]-(b)[0];(c)[1]=(a)[1]-(b)[1];(c)[2]=(a)[2]-(b)[2];} while(0)
#define VectorScale(a,s,c) do {(c)[0]=(a)[0]*(s);(c)[1]=(a)[1]*(s);(c)[2]=(a)[2]*(s);} while(0)
#define VectorMA(a,s,b,c) do {(c)[0]=(a)[0]+(s)*(b)[0];(c)[1]=(a)[1]+(s)*(b)[1];(c)[2]=(a)[2]+(s)*(b)[2];} while(0)
#define DotProduct(a,b) ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) double __cdecl sqrt(double);
__declspec(dllimport) double __cdecl atan2(double, double);
__declspec(dllimport) double __cdecl cos(double);
__declspec(dllimport) double __cdecl sin(double);
__declspec(dllimport) double __cdecl floor(double);
__declspec(dllimport) double __cdecl ceil(double);
__declspec(dllimport) double __cdecl fabs(double);

int mq_strlen(const char *);
int mq_strcmp(const char *, const char *);
char *mq_strcat(char *, const char *);
void *mq_memcpy(void *, const void *, int);
int mq_rand(void);
double mq_ceil(double);
#define strlen mq_strlen
#define strcmp mq_strcmp
#define strcat mq_strcat
#define memcpy mq_memcpy
#define rand mq_rand
#define ceil mq_ceil

void AngleVectors(float *, float *, float *, float *);
void SV_LinkEdict(edict_t *, qboolean);
void PR_RunError(char *, ...);
void Con_Printf(char *, ...);
void Con_DPrintf(char *, ...);
void ED_Print(edict_t *);
void ED_Free(edict_t *);
void Host_Error(char *, ...);
void SV_BroadcastPrintf(char *, ...);
void MSG_WriteChar(sizebuf_t *, int);
void MSG_WriteByte(sizebuf_t *, int);
void MSG_WriteShort(sizebuf_t *, int);
void MSG_WriteLong(sizebuf_t *, int);
void MSG_WriteCoord(sizebuf_t *, float);
void MSG_WriteAngle(sizebuf_t *, float);
void MSG_WriteString(sizebuf_t *, char *);
void SV_StartParticle(float *, float *, int, int);
void SV_StartSound(edict_t *, int, char *, int, float);
void Sys_Error(char *, ...);
trace_t SV_Move(float *, float *, float *, float *, int, edict_t *);
mleaf_t *Mod_PointInLeaf(float *, model_t *);
byte *Mod_LeafPVS(mleaf_t *, model_t *);
void Host_ClientCommands(char *, ...);
void Cbuf_AddText(char *);
float Cvar_VariableValue(char *);
void Cvar_Set(char *, char *);
float Length(float *);
void Con_DPrintf(char *, ...);
edict_t *ED_Alloc(void);
void ED_PrintEdicts(void);
void ED_PrintNum(int);
qboolean SV_movestep(edict_t *, float *, qboolean);
qboolean SV_CheckBottom(edict_t *);
int SV_PointContents(float *);
float VectorNormalize(float *);
float anglemod(float);
model_t *Mod_ForName(char *, qboolean);
int SV_ModelIndex(char *);
char *va(char *, ...);
void SV_MoveToGoal(void);

#endif
