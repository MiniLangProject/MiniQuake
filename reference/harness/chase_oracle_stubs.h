#ifndef MINIQUAKE_CHASE_ORACLE_STUBS_H
#define MINIQUAKE_CHASE_ORACLE_STUBS_H

typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];

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
    int dummy;
} hull_t;

typedef struct
{
    hull_t hulls[1];
} model_t;

typedef struct
{
    model_t *worldmodel;
    vec3_t viewangles;
} client_state_t;

typedef struct
{
    vec3_t vieworg;
    vec3_t viewangles;
} refdef_t;

typedef struct
{
    vec3_t endpos;
} trace_t;

#define PITCH 0
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#define VectorCopy(a,b) \
    {(b)[0]=(a)[0];(b)[1]=(a)[1];(b)[2]=(a)[2];}
#define VectorMA(a,s,b,c) \
    {(c)[0]=(a)[0]+(s)*(b)[0];(c)[1]=(a)[1]+(s)*(b)[1];(c)[2]=(a)[2]+(s)*(b)[2];}
#define VectorSubtract(a,b,c) \
    {(c)[0]=(a)[0]-(b)[0];(c)[1]=(a)[1]-(b)[1];(c)[2]=(a)[2]-(b)[2];}
#define DotProduct(a,b) \
    ((a)[0]*(b)[0]+(a)[1]*(b)[1]+(a)[2]*(b)[2])

extern client_state_t cl;
extern refdef_t r_refdef;

void Cvar_RegisterVariable(cvar_t *variable);
void AngleVectors(vec3_t angles, vec3_t forward, vec3_t right, vec3_t up);
qboolean SV_RecursiveHullCheck(
    hull_t *hulls, int num, float p1f, float p2f,
    vec3_t start, vec3_t end, trace_t *trace);
void *memset(void *destination, int value, unsigned __int64 count);
double mq_atan(double value);
#define atan mq_atan

#endif
