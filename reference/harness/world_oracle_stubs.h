#ifndef MINIQUAKE_WORLD_ORACLE_STUBS_H
#define MINIQUAKE_WORLD_ORACLE_STUBS_H

typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];
typedef struct edict_s edict_t;

typedef struct link_s {
    struct link_s *prev;
    struct link_s *next;
} link_t;

typedef struct {
    vec3_t normal;
    float dist;
    unsigned char type;
    unsigned char signbits;
    unsigned char pad[2];
} mplane_t;

typedef struct {
    int planenum;
    short children[2];
} dclipnode_t;

typedef struct {
    dclipnode_t *clipnodes;
    mplane_t *planes;
    int firstclipnode;
    int lastclipnode;
    vec3_t clip_mins;
    vec3_t clip_maxs;
} hull_t;

typedef struct mnode_s {
    int contents;
    int visframe;
    vec3_t minmaxs[2];
    struct mnode_s *parent;
    mplane_t *plane;
    struct mnode_s *children[2];
} mnode_t;

typedef struct mleaf_s {
    int contents;
    int visframe;
    vec3_t minmaxs[2];
    mnode_t *parent;
    unsigned char *compressed_vis;
} mleaf_t;

typedef struct {
    int type;
    vec3_t mins;
    vec3_t maxs;
    mnode_t *nodes;
    mleaf_t *leafs;
    hull_t hulls[4];
} model_t;

typedef struct {
    vec3_t origin;
    vec3_t angles;
    vec3_t mins;
    vec3_t maxs;
    vec3_t absmin;
    vec3_t absmax;
    vec3_t size;
    float solid;
    float movetype;
    float modelindex;
    float flags;
    int owner;
    int touch;
} entvars_t;

struct edict_s {
    link_t area;
    qboolean free;
    int num_leafs;
    short leafnums[16];
    entvars_t v;
};

typedef struct {
    model_t *models[256];
    model_t *worldmodel;
    edict_t *edicts;
    float time;
} server_t;

typedef struct {
    float time;
    int self;
    int other;
} globalvars_t;

typedef struct {
    qboolean allsolid;
    qboolean startsolid;
    qboolean inopen;
    qboolean inwater;
    float fraction;
    vec3_t endpos;
    struct {
        vec3_t normal;
        float dist;
    } plane;
    edict_t *ent;
} trace_t;

extern server_t sv;
extern globalvars_t *pr_global_struct;
extern vec3_t vec3_origin;

#define false 0
#define true 1
#define NULL ((void *)0)
#define MAX_ENT_LEAFS 16
#define CONTENTS_EMPTY -1
#define CONTENTS_SOLID -2
#define CONTENTS_WATER -3
#define CONTENTS_CURRENT_0 -9
#define CONTENTS_CURRENT_DOWN -14
#define SOLID_NOT 0
#define SOLID_TRIGGER 1
#define SOLID_BBOX 2
#define SOLID_SLIDEBOX 3
#define SOLID_BSP 4
#define MOVETYPE_PUSH 7
#define MOVE_NORMAL 0
#define MOVE_NOMONSTERS 1
#define MOVE_MISSILE 2
#define FL_FLY 1
#define FL_SWIM 2
#define FL_ITEM 256
#define FL_MONSTER 32
#define mod_brush 0

#define EDICT_FROM_AREA(value) ((edict_t *)(value))
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

static void ClearLink(link_t *link)
{
    link->prev = link;
    link->next = link;
}

static void RemoveLink(link_t *link)
{
    link->next->prev = link->prev;
    link->prev->next = link->next;
}

static void InsertLinkBefore(link_t *link, link_t *before)
{
    link->next = before;
    link->prev = before->prev;
    link->prev->next = link;
    link->next->prev = link;
}

__declspec(dllimport) void * __cdecl memset(
    void *destination, int value, unsigned __int64 size);

int BOX_ON_PLANE_SIDE(vec3_t mins, vec3_t maxs, mplane_t *plane);
void Sys_Error(char *format, ...);
void Con_Printf(char *format, ...);
void Con_DPrintf(char *format, ...);
void PR_ExecuteProgram(int function_index);
trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int type, edict_t *passedict);

#endif
