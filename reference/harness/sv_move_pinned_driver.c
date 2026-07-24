/*
 * Deterministic services/serializer for the functions compiled directly from
 * the pinned WinQuake/sv_move.c detached worktree.
 */
#include "sv_move_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
int _fltused = 0;

server_t sv;
static globalvars_t globals;
globalvars_t *pr_global_struct = &globals;
float pr_globals[128];
vec3_t vec3_origin = {0.0f, 0.0f, 0.0f};

static edict_t entities[4];
enum world_mode { WORLD_FLOOR, WORLD_EMPTY, WORLD_WATER };
static enum world_mode active_world;
static unsigned int random_seed;

qboolean SV_CheckBottom(edict_t *entity);
qboolean SV_movestep(edict_t *entity, vec3_t move, qboolean relink);
qboolean SV_StepDirection(edict_t *entity, float yaw, float distance);
void SV_FixCheckBottom(edict_t *entity);
void SV_NewChaseDir(edict_t *actor, edict_t *enemy, float distance);
qboolean SV_CloseEnough(edict_t *entity, edict_t *goal, float distance);
void SV_MoveToGoal(void);

void __cdecl srand(unsigned int seed)
{
    random_seed = seed;
}

int __cdecl rand(void)
{
    random_seed = random_seed * 214013u + 2531011u;
    return (int)((random_seed >> 16) & 0x7fffu);
}

float anglemod(float angle)
{
    return (360.0f / 65536.0f) *
        (((int)(angle * (65536.0f / 360.0f))) & 65535);
}

static void update_abs(edict_t *entity)
{
    VectorAdd(entity->v.origin, entity->v.mins, entity->v.absmin);
    VectorAdd(entity->v.origin, entity->v.maxs, entity->v.absmax);
}

int SV_PointContents(vec3_t point)
{
    if (active_world == WORLD_FLOOR)
        return point[2] < 0.0f ? CONTENTS_SOLID : CONTENTS_EMPTY;
    if (active_world == WORLD_WATER)
        return point[2] < 0.0f ? -3 : CONTENTS_EMPTY;
    return CONTENTS_EMPTY;
}

trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict)
{
    trace_t trace;
    float contact;
    int point = mins == vec3_origin && maxs == vec3_origin;
    (void)move_type;
    memset(&trace, 0, sizeof(trace));
    trace.fraction = 1.0f;
    VectorCopy(end, trace.endpos);
    trace.ent = &entities[0];
    if (active_world != WORLD_FLOOR || end[2] >= start[2])
        return trace;
    contact = point ? 0.0f : -passedict->v.mins[2] + 0.03125f;
    if (start[2] < contact) {
        trace.startsolid = true;
        trace.allsolid = end[2] < contact;
        trace.fraction = 0.0f;
        VectorCopy(start, trace.endpos);
        return trace;
    }
    if (end[2] < contact) {
        trace.fraction = (start[2] - contact) / (start[2] - end[2]);
        trace.endpos[0] =
            start[0] + trace.fraction * (end[0] - start[0]);
        trace.endpos[1] =
            start[1] + trace.fraction * (end[1] - start[1]);
        trace.endpos[2] = contact;
    }
    return trace;
}

void SV_LinkEdict(edict_t *entity, qboolean touch_triggers)
{
    (void)touch_triggers;
    update_abs(entity);
}

void PF_changeyaw(void)
{
    edict_t *entity = PROG_TO_EDICT(pr_global_struct->self);
    float current = anglemod(entity->v.angles[YAW]);
    float ideal = anglemod(entity->v.ideal_yaw);
    float move;
    if (current == ideal)
        return;
    move = ideal - current;
    if (ideal > current) {
        if (move >= 180.0f)
            move -= 360.0f;
    } else if (move <= -180.0f) {
        move += 360.0f;
    }
    if (move > entity->v.yaw_speed)
        move = entity->v.yaw_speed;
    if (move < -entity->v.yaw_speed)
        move = -entity->v.yaw_speed;
    entity->v.angles[YAW] = anglemod(current + move);
}

static void init_entity(
    edict_t *entity, float x, float y, float z, int flags)
{
    int index = (int)(entity - entities);
    memset(entity, 0, sizeof(*entity));
    entity->v.origin[0] = x;
    entity->v.origin[1] = y;
    entity->v.origin[2] = z;
    entity->v.mins[0] = -1.0f;
    entity->v.mins[1] = -1.0f;
    entity->v.mins[2] = -2.0f;
    entity->v.maxs[0] = 1.0f;
    entity->v.maxs[1] = 1.0f;
    entity->v.maxs[2] = 2.0f;
    entity->v.flags = (float)flags;
    entity->v.yaw_speed = 360.0f;
    update_abs(entity);
    (void)index;
}

static char *emit(
    char *output, const char *function_name, const char *case_name,
    int result, edict_t *entity)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"x\":%.9g,\"y\":%.9g,\"z\":%.9g,"
        "\"yaw\":%.9g,\"ideal\":%.9g,\"flags\":%d,\"ground\":%d}\n",
        function_name, case_name, result,
        entity->v.origin[0], entity->v.origin[1], entity->v.origin[2],
        entity->v.angles[YAW], entity->v.ideal_yaw,
        (int)entity->v.flags, (int)entity->v.groundentity);
    return output;
}

__declspec(dllexport) int __cdecl sv_move_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    vec3_t move;
    int result;
    (void)capacity;
    sv.edicts = entities;
    memset(pr_globals, 0, sizeof(pr_globals));

    active_world = WORLD_FLOOR;
    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    result = SV_CheckBottom(&entities[1]);
    cursor = emit(cursor, "SV_CheckBottom", "floor", result, &entities[1]);
    active_world = WORLD_EMPTY;
    result = SV_CheckBottom(&entities[1]);
    cursor = emit(cursor, "SV_CheckBottom", "gap", result, &entities[1]);

    active_world = WORLD_FLOOR;
    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    move[0] = 12.0f; move[1] = 0.0f; move[2] = 0.0f;
    result = SV_movestep(&entities[1], move, true);
    cursor = emit(cursor, "SV_movestep", "floor", result, &entities[1]);
    active_world = WORLD_EMPTY;
    init_entity(
        &entities[1], 0.0f, 0.0f, 2.0f,
        FL_ONGROUND | FL_PARTIALGROUND);
    move[0] = 5.0f; move[1] = 0.0f; move[2] = 0.0f;
    result = SV_movestep(&entities[1], move, false);
    cursor = emit(
        cursor, "SV_movestep", "partial_fall", result, &entities[1]);
    active_world = WORLD_FLOOR;
    init_entity(&entities[1], 0.0f, 0.0f, 100.0f, FL_FLY);
    init_entity(&entities[2], 30.0f, 0.0f, 0.0f, FL_ONGROUND);
    entities[1].v.enemy = 2.0f;
    result = SV_movestep(&entities[1], move, false);
    cursor = emit(cursor, "SV_movestep", "fly", result, &entities[1]);
    active_world = WORLD_WATER;
    init_entity(&entities[1], 0.0f, 0.0f, -10.0f, FL_SWIM);
    move[0] = 0.0f; move[1] = 0.0f; move[2] = 20.0f;
    result = SV_movestep(&entities[1], move, false);
    cursor = emit(
        cursor, "SV_movestep", "swim_exit", result, &entities[1]);

    active_world = WORLD_FLOOR;
    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    entities[1].v.angles[YAW] = 180.0f;
    entities[1].v.yaw_speed = 20.0f;
    pr_global_struct->self = 1;
    result = SV_StepDirection(&entities[1], 90.0f, 10.0f);
    cursor = emit(
        cursor, "SV_StepDirection", "yaw_gate", result, &entities[1]);

    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    SV_FixCheckBottom(&entities[1]);
    cursor = emit(
        cursor, "SV_FixCheckBottom", "set_partial", 1, &entities[1]);

    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    init_entity(&entities[2], 40.0f, 40.0f, 2.0f, FL_ONGROUND);
    pr_global_struct->self = 1;
    srand(0);
    SV_NewChaseDir(&entities[1], &entities[2], 10.0f);
    cursor = emit(
        cursor, "SV_NewChaseDir", "diagonal", 1, &entities[1]);

    result = SV_CloseEnough(&entities[1], &entities[2], 1.0f);
    cursor = emit(
        cursor, "SV_CloseEnough", "distant", result, &entities[1]);
    entities[2].v.origin[0] = 12.0f;
    entities[2].v.origin[1] = 12.0f;
    entities[2].v.origin[2] = 2.0f;
    update_abs(&entities[2]);
    result = SV_CloseEnough(&entities[1], &entities[2], 4.0f);
    cursor = emit(
        cursor, "SV_CloseEnough", "near", result, &entities[1]);

    init_entity(&entities[1], 0.0f, 0.0f, 2.0f, FL_ONGROUND);
    init_entity(&entities[2], 60.0f, 0.0f, 2.0f, FL_ONGROUND);
    entities[1].v.goalentity = 2.0f;
    pr_global_struct->self = 1;
    G_FLOAT(OFS_PARM0) = 8.0f;
    G_FLOAT(OFS_RETURN) = 1.0f;
    srand(0);
    SV_MoveToGoal();
    cursor = emit(
        cursor, "SV_MoveToGoal", "direct",
        (int)G_FLOAT(OFS_RETURN), &entities[1]);
    entities[1].v.flags = 0.0f;
    G_FLOAT(OFS_RETURN) = 1.0f;
    SV_MoveToGoal();
    cursor = emit(
        cursor, "SV_MoveToGoal", "airborne",
        (int)G_FLOAT(OFS_RETURN), &entities[1]);

    *cursor = 0;
    return (int)(cursor - output);
}
