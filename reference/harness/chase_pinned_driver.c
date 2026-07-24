#include "chase_oracle_stubs.h"

int _fltused = 0;
extern cvar_t chase_back;
extern cvar_t chase_up;
extern cvar_t chase_right;
extern cvar_t chase_active;
extern vec3_t chase_dest;

client_state_t cl;
refdef_t r_refdef;
static model_t world_model;
static int register_calls;

double mq_atan(double value)
{
    (void)value;
    return 0.0;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    register_calls++;
    if (variable == &chase_back)
        variable->value = 100.0f;
    else if (variable == &chase_up)
        variable->value = 16.0f;
    else
        variable->value = 0.0f;
}

void AngleVectors(vec3_t angles, vec3_t forward, vec3_t right, vec3_t up)
{
    (void)angles;
    forward[0] = 1.0f;
    forward[1] = 0.0f;
    forward[2] = 0.0f;
    right[0] = 0.0f;
    right[1] = -1.0f;
    right[2] = 0.0f;
    up[0] = 0.0f;
    up[1] = 0.0f;
    up[2] = 1.0f;
}

qboolean SV_RecursiveHullCheck(
    hull_t *hulls, int num, float p1f, float p2f,
    vec3_t start, vec3_t end, trace_t *trace)
{
    (void)hulls;
    (void)num;
    (void)p1f;
    (void)p2f;
    (void)start;
    VectorCopy(end, trace->endpos);
    return 1;
}

void chase_setup(float x, float y, float z)
{
    cl.worldmodel = &world_model;
    cl.viewangles[0] = 0.0f;
    cl.viewangles[1] = 0.0f;
    cl.viewangles[2] = 0.0f;
    r_refdef.vieworg[0] = x;
    r_refdef.vieworg[1] = y;
    r_refdef.vieworg[2] = z;
    r_refdef.viewangles[0] = 0.0f;
    r_refdef.viewangles[1] = 0.0f;
    r_refdef.viewangles[2] = 0.0f;
    register_calls = 0;
}

int chase_register_calls(void)
{
    return register_calls;
}

void chase_get_cvars(float *values)
{
    values[0] = chase_back.value;
    values[1] = chase_up.value;
    values[2] = chase_right.value;
    values[3] = chase_active.value;
}

void chase_get_view(float *values)
{
    values[0] = r_refdef.vieworg[0];
    values[1] = r_refdef.vieworg[1];
    values[2] = r_refdef.vieworg[2];
    values[3] = r_refdef.viewangles[0];
    values[4] = r_refdef.viewangles[1];
    values[5] = r_refdef.viewangles[2];
    values[6] = chase_dest[0];
    values[7] = chase_dest[1];
    values[8] = chase_dest[2];
}
