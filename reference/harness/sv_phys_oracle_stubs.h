#ifndef MINIQUAKE_SV_PHYS_ORACLE_STUBS_H
#define MINIQUAKE_SV_PHYS_ORACLE_STUBS_H

typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];
typedef struct edict_s edict_t;

typedef struct {
    vec3_t normal;
    float dist;
} plane_t;

typedef struct {
    qboolean allsolid;
    qboolean startsolid;
    qboolean inopen;
    qboolean inwater;
    float fraction;
    vec3_t endpos;
    plane_t plane;
    edict_t *ent;
} trace_t;

typedef struct {
    vec3_t origin;
    vec3_t velocity;
    vec3_t angles;
    vec3_t avelocity;
    vec3_t mins;
    vec3_t maxs;
    vec3_t absmin;
    vec3_t absmax;
    vec3_t oldorigin;
    vec3_t view_ofs;
    vec3_t v_angle;
    vec3_t punchangle;
    vec3_t movedir;
    float movetype;
    float solid;
    float flags;
    int groundentity;
    float nextthink;
    int think;
    int touch;
    int blocked;
    float ltime;
    float gravity;
    float waterlevel;
    float watertype;
    float health;
    int classname;
} entvars_t;

struct edict_s {
    qboolean free;
    entvars_t v;
};

typedef struct {
    qboolean active;
} client_t;

typedef struct {
    edict_t *edicts;
    int num_edicts;
    float time;
} server_t;

typedef struct {
    client_t *clients;
    int maxclients;
} server_static_t;

typedef struct {
    float time;
    int self;
    int other;
    float force_retouch;
    int PlayerPreThink;
    int PlayerPostThink;
    int StartFrame;
} globalvars_t;

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

typedef union {
    float _float;
    int _int;
    vec3_t vector;
} eval_t;

extern server_t sv;
extern server_static_t svs;
extern globalvars_t *pr_global_struct;
extern edict_t *sv_player;
extern double host_frametime;
extern vec3_t vec3_origin;
extern char pr_strings[256];

#define false 0
#define true 1
#define NULL ((void *)0)
#define PITCH 0
#define YAW 1
#define ROLL 2
#define FL_FLY 1
#define FL_SWIM 2
#define FL_WATERJUMP 2048
#define FL_ONGROUND 512
#define MOVETYPE_NONE 0
#define MOVETYPE_WALK 3
#define MOVETYPE_STEP 4
#define MOVETYPE_FLY 5
#define MOVETYPE_TOSS 6
#define MOVETYPE_PUSH 7
#define MOVETYPE_NOCLIP 8
#define MOVETYPE_FLYMISSILE 9
#define MOVETYPE_BOUNCE 10
#define SOLID_NOT 0
#define SOLID_TRIGGER 1
#define SOLID_BBOX 2
#define SOLID_SLIDEBOX 3
#define SOLID_BSP 4
#define CONTENTS_EMPTY -1
#define CONTENTS_SOLID -2
#define CONTENTS_WATER -3
#define MOVE_NORMAL 0
#define MOVE_NOMONSTERS 1
#define MOVE_MISSILE 2
#define MAX_EDICTS 600

#define IS_NAN(value) mq_is_nan(value)
#define NEXT_EDICT(value) ((value) + 1)
#define EDICT_TO_PROG(value) ((int)((value) - sv.edicts))
#define PROG_TO_EDICT(value) (&sv.edicts[(int)(value)])
#define DotProduct(a,b) \
    ((a)[0]*(b)[0] + (a)[1]*(b)[1] + (a)[2]*(b)[2])
#define VectorCopy(a,out) \
    ((out)[0]=(a)[0], (out)[1]=(a)[1], (out)[2]=(a)[2])
#define VectorAdd(a,b,out) \
    ((out)[0]=(a)[0]+(b)[0], (out)[1]=(a)[1]+(b)[1], \
     (out)[2]=(a)[2]+(b)[2])
#define VectorSubtract(a,b,out) \
    ((out)[0]=(a)[0]-(b)[0], (out)[1]=(a)[1]-(b)[1], \
     (out)[2]=(a)[2]-(b)[2])
#define VectorScale(a,s,out) \
    ((out)[0]=(a)[0]*(s), (out)[1]=(a)[1]*(s), \
     (out)[2]=(a)[2]*(s))
#define VectorMA(a,s,b,out) \
    ((out)[0]=(a)[0]+(s)*(b)[0], (out)[1]=(a)[1]+(s)*(b)[1], \
     (out)[2]=(a)[2]+(s)*(b)[2])
#define CrossProduct(a,b,out) \
    ((out)[0]=(a)[1]*(b)[2]-(a)[2]*(b)[1], \
     (out)[1]=(a)[2]*(b)[0]-(a)[0]*(b)[2], \
     (out)[2]=(a)[0]*(b)[1]-(a)[1]*(b)[0])

__declspec(dllimport) double __cdecl sqrt(double);
__declspec(dllimport) double __cdecl fabs(double);

int mq_is_nan(float value);
edict_t *SV_TestEntityPosition(edict_t *entity);
void Con_Printf(char *format, ...);
void Con_DPrintf(char *format, ...);
void Sys_Error(char *format, ...);
void PR_ExecuteProgram(int function_index);
trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict);
void SV_LinkEdict(edict_t *entity, qboolean touch_triggers);
int SV_PointContents(vec3_t point);
void SV_StartSound(
    edict_t *entity, int channel, char *sample, int volume,
    float attenuation);
void AngleVectors(
    vec3_t angles, vec3_t forward, vec3_t right, vec3_t up);
eval_t *GetEdictFieldValue(edict_t *entity, char *field_name);
qboolean SV_CheckBottom(edict_t *entity);

#endif
