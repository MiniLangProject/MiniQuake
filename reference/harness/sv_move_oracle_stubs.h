#ifndef MINIQUAKE_SV_MOVE_ORACLE_STUBS_H
#define MINIQUAKE_SV_MOVE_ORACLE_STUBS_H

typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];

typedef struct edict_s edict_t;
typedef struct {
    qboolean allsolid;
    qboolean startsolid;
    qboolean inopen;
    qboolean inwater;
    float fraction;
    vec3_t endpos;
    struct { vec3_t normal; float dist; } plane;
    edict_t *ent;
} trace_t;

typedef struct {
    vec3_t origin;
    vec3_t mins;
    vec3_t maxs;
    vec3_t absmin;
    vec3_t absmax;
    vec3_t angles;
    vec3_t velocity;
    float flags;
    float enemy;
    float groundentity;
    float goalentity;
    float ideal_yaw;
    float yaw_speed;
} entvars_t;

struct edict_s {
    entvars_t v;
};

typedef struct {
    edict_t *edicts;
} server_t;

typedef struct {
    int self;
} globalvars_t;

extern server_t sv;
extern globalvars_t *pr_global_struct;
extern float pr_globals[128];
extern vec3_t vec3_origin;

#define false 0
#define true 1
#define YAW 1
#define M_PI 3.14159265358979323846
#define CONTENTS_EMPTY -1
#define CONTENTS_SOLID -2
#define FL_FLY 1
#define FL_SWIM 2
#define FL_ONGROUND 512
#define FL_PARTIALGROUND 1024
#define OFS_RETURN 1
#define OFS_PARM0 4
#define G_FLOAT(offset) (pr_globals[(offset)])
#define PROG_TO_EDICT(value) (&sv.edicts[(int)(value)])
#define EDICT_TO_PROG(value) ((int)((value) - sv.edicts))

#define VectorAdd(a,b,out) \
    ((out)[0]=(a)[0]+(b)[0], (out)[1]=(a)[1]+(b)[1], \
     (out)[2]=(a)[2]+(b)[2])
#define VectorCopy(a,out) \
    ((out)[0]=(a)[0], (out)[1]=(a)[1], (out)[2]=(a)[2])

__declspec(dllimport) double __cdecl sin(double);
__declspec(dllimport) double __cdecl cos(double);
int __cdecl rand(void);
#define abs(value) ((value) < 0 ? -(value) : (value))

float anglemod(float angle);
int SV_PointContents(vec3_t point);
trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict);
void SV_LinkEdict(edict_t *entity, qboolean touch_triggers);
void PF_changeyaw(void);

#endif
