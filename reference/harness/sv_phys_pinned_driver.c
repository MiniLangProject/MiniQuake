#include "sv_phys_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
int _fltused = 0;

server_t sv;
server_static_t svs;
static globalvars_t globals;
globalvars_t *pr_global_struct = &globals;
edict_t *sv_player;
double host_frametime;
vec3_t vec3_origin = {0.0f, 0.0f, 0.0f};
char pr_strings[256];

static edict_t entities[8];
static client_t clients[2];
static int world_mode;
static int think_count;
static int touch_count;
static int sound_count;
static int blocked_count;
static int test_position_mode;
extern cvar_t sv_gravity;
extern cvar_t sv_maxvelocity;
extern cvar_t sv_friction;
extern cvar_t sv_stopspeed;
extern cvar_t sv_nostep;

void SV_CheckAllEnts(void);
void SV_CheckVelocity(edict_t *entity);
qboolean SV_RunThink(edict_t *entity);
void SV_Impact(edict_t *first, edict_t *second);
int ClipVelocity(
    vec3_t input, vec3_t normal, vec3_t output, float overbounce);
int SV_FlyMove(edict_t *entity, float time, trace_t *steptrace);
void SV_AddGravity(edict_t *entity);
trace_t SV_PushEntity(edict_t *entity, vec3_t push);
void SV_PushMove(edict_t *pusher, float move_time);
void SV_Physics_Pusher(edict_t *entity);
void SV_CheckStuck(edict_t *entity);
qboolean SV_CheckWater(edict_t *entity);
void SV_WallFriction(edict_t *entity, trace_t *trace);
int SV_TryUnstick(edict_t *entity, vec3_t old_velocity);
void SV_WalkMove(edict_t *entity);
void SV_Physics_Client(edict_t *entity, int number);
void SV_Physics_None(edict_t *entity);
void SV_Physics_Noclip(edict_t *entity);
void SV_CheckWaterTransition(edict_t *entity);
void SV_Physics_Toss(edict_t *entity);
void SV_Physics_Step(edict_t *entity);
void SV_Physics(void);

int mq_is_nan(float value)
{
    union { float value; unsigned int bits; } data;
    data.value = value;
    return (data.bits & 0x7fffffffU) > 0x7f800000U;
}

static void update_abs(edict_t *entity)
{
    VectorAdd(entity->v.origin, entity->v.mins, entity->v.absmin);
    VectorAdd(entity->v.origin, entity->v.maxs, entity->v.absmax);
}

edict_t *SV_TestEntityPosition(edict_t *entity)
{
    if (test_position_mode == 1 && entity == &entities[2])
    {
        return &entities[4];
    }
    if (world_mode == CONTENTS_SOLID &&
        entity->v.origin[0] + entity->v.mins[0] < 0.0f)
        return &entities[0];
    return 0;
}

void Con_Printf(char *format, ...) { (void)format; }
void Con_DPrintf(char *format, ...) { (void)format; }
void Sys_Error(char *format, ...) { (void)format; }

void PR_ExecuteProgram(int function_index)
{
    if (function_index == 1)
        ++think_count;
    else if (function_index == 2)
        ++touch_count;
    else if (function_index == 3)
        ++blocked_count;
}

trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict)
{
    trace_t trace;
    float contact;
    (void)maxs;
    (void)move_type;
    memset(&trace, 0, sizeof(trace));
    trace.fraction = 1.0f;
    VectorCopy(end, trace.endpos);
    trace.ent = &entities[0];
    if (world_mode != CONTENTS_SOLID)
        return trace;
    contact = -mins[0] + 0.03125f;
    if (start[0] < contact) {
        trace.startsolid = true;
        trace.allsolid = true;
        trace.fraction = 0.0f;
        VectorCopy(start, trace.endpos);
        trace.plane.normal[0] = 1.0f;
        return trace;
    }
    if (end[0] < contact) {
        trace.fraction = (start[0] - contact) / (start[0] - end[0]);
        trace.endpos[0] = contact;
        trace.endpos[1] =
            start[1] + trace.fraction * (end[1] - start[1]);
        trace.endpos[2] =
            start[2] + trace.fraction * (end[2] - start[2]);
        trace.plane.normal[0] = 1.0f;
    }
    (void)passedict;
    return trace;
}

void SV_LinkEdict(edict_t *entity, qboolean touch_triggers)
{
    (void)touch_triggers;
    update_abs(entity);
}

int SV_PointContents(vec3_t point)
{
    if (world_mode == CONTENTS_WATER && point[0] < 0.0f)
        return CONTENTS_WATER;
    if (world_mode == CONTENTS_SOLID && point[0] < 0.0f)
        return CONTENTS_SOLID;
    return CONTENTS_EMPTY;
}

void SV_StartSound(
    edict_t *entity, int channel, char *sample, int volume,
    float attenuation)
{
    (void)entity; (void)channel; (void)sample;
    (void)volume; (void)attenuation;
    ++sound_count;
}

void AngleVectors(
    vec3_t angles, vec3_t forward, vec3_t right, vec3_t up)
{
    (void)angles;
    forward[0] = -1.0f; forward[1] = 0.0f; forward[2] = 0.0f;
    right[0] = 0.0f; right[1] = -1.0f; right[2] = 0.0f;
    up[0] = 0.0f; up[1] = 0.0f; up[2] = 1.0f;
}

eval_t *GetEdictFieldValue(edict_t *entity, char *field_name)
{
    static eval_t value;
    (void)field_name;
    value._float = entity->v.gravity;
    return &value;
}

qboolean SV_CheckBottom(edict_t *entity)
{
    (void)entity;
    return true;
}

static void reset_all(void)
{
    int i;
    memset(entities, 0, sizeof(entities));
    memset(clients, 0, sizeof(clients));
    memset(&globals, 0, sizeof(globals));
    sv.edicts = entities;
    sv.num_edicts = 5;
    sv.time = 10.0f;
    svs.clients = clients;
    svs.maxclients = 0;
    sv_player = &entities[1];
    host_frametime = 0.1;
    world_mode = CONTENTS_EMPTY;
    think_count = touch_count = sound_count = blocked_count = 0;
    test_position_mode = 0;
    sv_gravity.value = 800.0f;
    sv_maxvelocity.value = 2000.0f;
    sv_friction.value = 4.0f;
    sv_stopspeed.value = 100.0f;
    sv_nostep.value = 0.0f;
    for (i = 0; i < 8; ++i) {
        entities[i].v.mins[0] = -1.0f;
        entities[i].v.mins[1] = -1.0f;
        entities[i].v.mins[2] = -1.0f;
        entities[i].v.maxs[0] = 1.0f;
        entities[i].v.maxs[1] = 1.0f;
        entities[i].v.maxs[2] = 1.0f;
        entities[i].v.watertype = 0.0f;
        update_abs(&entities[i]);
    }
    entities[0].v.solid = SOLID_BSP;
}

static char *emit(
    char *output, const char *function_name, const char *case_name,
    int result, edict_t *entity)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"x\":%.9g,\"y\":%.9g,\"z\":%.9g,"
        "\"vx\":%.9g,\"vy\":%.9g,\"vz\":%.9g,"
        "\"flags\":%d,\"water\":%.9g,\"watertype\":%.9g,"
        "\"ltime\":%.9g,\"think\":%d,\"touch\":%d,"
        "\"sound\":%d,\"blocked\":%d}\n",
        function_name, case_name, result,
        entity->v.origin[0], entity->v.origin[1], entity->v.origin[2],
        entity->v.velocity[0], entity->v.velocity[1],
        entity->v.velocity[2], (int)entity->v.flags,
        entity->v.waterlevel, entity->v.watertype, entity->v.ltime,
        think_count, touch_count, sound_count, blocked_count);
    return output;
}

__declspec(dllexport) int __cdecl sv_phys_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    edict_t *entity;
    trace_t trace;
    vec3_t value;
    vec3_t normal;
    union { unsigned int bits; float value; } nan_value;
    int result;
    (void)capacity;

    reset_all();
    sv.num_edicts = 2;
    entities[1].v.movetype = MOVETYPE_TOSS;
    SV_CheckAllEnts();
    cursor = emit(cursor, "SV_CheckAllEnts", "valid", 1, &entities[1]);

    reset_all();
    entity = &entities[1];
    nan_value.bits = 0x7fc00000U;
    entity->v.origin[0] = nan_value.value;
    entity->v.origin[1] = 2.0f;
    entity->v.origin[2] = 3.0f;
    entity->v.velocity[0] = nan_value.value;
    entity->v.velocity[1] = 5000.0f;
    entity->v.velocity[2] = -5000.0f;
    SV_CheckVelocity(entity);
    cursor = emit(cursor, "SV_CheckVelocity", "nan_clamp", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.nextthink = 10.05f;
    entity->v.think = 1;
    result = SV_RunThink(entity);
    cursor = emit(cursor, "SV_RunThink", "due", result, entity);

    reset_all();
    entities[1].v.touch = 2;
    entities[1].v.solid = SOLID_BBOX;
    entities[2].v.touch = 2;
    entities[2].v.solid = SOLID_BBOX;
    SV_Impact(&entities[1], &entities[2]);
    cursor = emit(cursor, "SV_Impact", "bidirectional", 1, &entities[1]);

    reset_all();
    value[0] = 100.0f; value[1] = -25.0f; value[2] = -50.0f;
    normal[0] = 0.0f; normal[1] = 0.0f; normal[2] = 1.0f;
    result = ClipVelocity(value, normal, entities[1].v.velocity, 1.0f);
    cursor = emit(cursor, "ClipVelocity", "floor", result, &entities[1]);

    reset_all();
    world_mode = CONTENTS_SOLID;
    entity = &entities[1];
    entity->v.origin[0] = 10.0f;
    entity->v.velocity[0] = -20.0f;
    entity->v.velocity[1] = 5.0f;
    result = SV_FlyMove(entity, 1.0f, &trace);
    cursor = emit(cursor, "SV_FlyMove", "wall_plane", result, entity);

    reset_all();
    entity = &entities[1];
    entity->v.velocity[2] = 100.0f;
    entity->v.gravity = 0.5f;
    SV_AddGravity(entity);
    cursor = emit(cursor, "SV_AddGravity", "entity_scale", 1, entity);

    reset_all();
    world_mode = CONTENTS_SOLID;
    entity = &entities[1];
    entity->v.origin[0] = 10.0f;
    value[0] = -20.0f; value[1] = 0.0f; value[2] = 0.0f;
    trace = SV_PushEntity(entity, value);
    cursor = emit(
        cursor, "SV_PushEntity", "wall", trace.fraction < 1.0f, entity);

    reset_all();
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_PUSH;
    entity->v.solid = SOLID_BSP;
    entity->v.origin[0] = 10.0f;
    entity->v.mins[0] = -4.0f; entity->v.mins[1] = -4.0f;
    entity->v.maxs[0] = 4.0f; entity->v.maxs[1] = 4.0f;
    entity->v.maxs[2] = 0.0f;
    entity->v.velocity[0] = 10.0f;
    entity->v.blocked = 3;
    update_abs(entity);
    entities[2].v.origin[0] = 10.0f;
    entities[2].v.origin[2] = 3.0f;
    entities[2].v.movetype = MOVETYPE_TOSS;
    entities[2].v.solid = SOLID_BBOX;
    entities[2].v.flags = FL_ONGROUND;
    entities[2].v.groundentity = 1;
    update_abs(&entities[2]);
    entities[3].v.origin[0] = 15.0f;
    entities[3].v.movetype = MOVETYPE_TOSS;
    entities[3].v.solid = SOLID_BBOX;
    entities[3].v.flags = FL_ONGROUND;
    entities[3].v.groundentity = 1;
    update_abs(&entities[3]);
    entities[4].v.origin[0] = 19.0f;
    entities[4].v.movetype = MOVETYPE_NONE;
    update_abs(&entities[4]);
    test_position_mode = 1;
    SV_PushMove(entity, 0.5f);
    cursor = emit(cursor, "SV_PushMove", "blocked_rollback", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_PUSH;
    entity->v.ltime = 2.0f;
    entity->v.nextthink = 2.1f;
    entity->v.think = 1;
    host_frametime = 0.25;
    SV_Physics_Pusher(entity);
    cursor = emit(cursor, "SV_Physics_Pusher", "think_boundary", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.origin[0] = 4.0f;
    SV_CheckStuck(entity);
    cursor = emit(cursor, "SV_CheckStuck", "valid", 1, entity);

    reset_all();
    world_mode = CONTENTS_WATER;
    entity = &entities[1];
    entity->v.origin[0] = -8.0f;
    entity->v.view_ofs[2] = 22.0f;
    result = SV_CheckWater(entity);
    cursor = emit(cursor, "SV_CheckWater", "submerged", result, entity);

    reset_all();
    entity = &entities[1];
    entity->v.velocity[0] = -100.0f;
    entity->v.velocity[1] = 50.0f;
    memset(&trace, 0, sizeof(trace));
    trace.plane.normal[0] = 1.0f;
    SV_WallFriction(entity, &trace);
    cursor = emit(cursor, "SV_WallFriction", "facing", 1, entity);

    reset_all();
    entity = &entities[1];
    value[0] = 20.0f; value[1] = 0.0f; value[2] = 0.0f;
    result = SV_TryUnstick(entity, value);
    cursor = emit(cursor, "SV_TryUnstick", "axial", result, entity);

    reset_all();
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_WALK;
    entity->v.flags = FL_ONGROUND;
    entity->v.velocity[0] = 10.0f;
    sv_player = entity;
    SV_WalkMove(entity);
    cursor = emit(cursor, "SV_WalkMove", "unblocked", 1, entity);

    reset_all();
    svs.maxclients = 1;
    clients[0].active = true;
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_NOCLIP;
    entity->v.velocity[0] = 10.0f;
    pr_global_struct->PlayerPreThink = 0;
    pr_global_struct->PlayerPostThink = 0;
    SV_Physics_Client(entity, 1);
    cursor = emit(cursor, "SV_Physics_Client", "noclip", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.nextthink = 10.05f;
    entity->v.think = 1;
    SV_Physics_None(entity);
    cursor = emit(cursor, "SV_Physics_None", "think", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.velocity[0] = 10.0f;
    entity->v.avelocity[1] = 20.0f;
    SV_Physics_Noclip(entity);
    cursor = emit(cursor, "SV_Physics_Noclip", "linear_angular", 1, entity);

    reset_all();
    world_mode = CONTENTS_WATER;
    entity = &entities[1];
    entity->v.origin[0] = -8.0f;
    entity->v.watertype = CONTENTS_EMPTY;
    SV_CheckWaterTransition(entity);
    cursor = emit(cursor, "SV_CheckWaterTransition", "enter", 1, entity);

    reset_all();
    world_mode = CONTENTS_SOLID;
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_FLY;
    entity->v.origin[0] = 10.0f;
    entity->v.velocity[0] = -20.0f;
    host_frametime = 1.0;
    SV_Physics_Toss(entity);
    cursor = emit(cursor, "SV_Physics_Toss", "wall", 1, entity);

    reset_all();
    entity = &entities[1];
    entity->v.movetype = MOVETYPE_STEP;
    entity->v.origin[0] = 10.0f;
    entity->v.velocity[2] = -100.0f;
    SV_Physics_Step(entity);
    cursor = emit(cursor, "SV_Physics_Step", "freefall", 1, entity);

    reset_all();
    sv.num_edicts = 1;
    entities[0].v.movetype = MOVETYPE_NONE;
    pr_global_struct->StartFrame = 0;
    SV_Physics();
    cursor = emit(cursor, "SV_Physics", "world_frame", 1, &entities[0]);

    *cursor = 0;
    return (int)(cursor - output);
}
