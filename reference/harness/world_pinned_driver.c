#include "world_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

server_t sv;
static globalvars_t globals;
globalvars_t *pr_global_struct = &globals;
vec3_t vec3_origin = {0.0f, 0.0f, 0.0f};

static edict_t entities[8];
static model_t world_model;
static dclipnode_t world_clipnode;
static mplane_t world_plane;
static mleaf_t world_leafs[2];
static int touch_count;

typedef struct areanode_s areanode_t;

void SV_InitBoxHull(void);
hull_t *SV_HullForBox(vec3_t mins, vec3_t maxs);
hull_t *SV_HullForEntity(
    edict_t *entity, vec3_t mins, vec3_t maxs, vec3_t offset);
areanode_t *SV_CreateAreaNode(int depth, vec3_t mins, vec3_t maxs);
void SV_ClearWorld(void);
void SV_UnlinkEdict(edict_t *entity);
void SV_TouchLinks(edict_t *entity, areanode_t *node);
void SV_FindTouchedLeafs(edict_t *entity, mnode_t *node);
void SV_LinkEdict(edict_t *entity, qboolean touch_triggers);
int SV_HullPointContents(hull_t *hull, int number, vec3_t point);
int SV_PointContents(vec3_t point);
int SV_TruePointContents(vec3_t point);
edict_t *SV_TestEntityPosition(edict_t *entity);
qboolean SV_RecursiveHullCheck(
    hull_t *hull, int number, float p1_fraction, float p2_fraction,
    vec3_t p1, vec3_t p2, trace_t *trace);
trace_t SV_ClipMoveToEntity(
    edict_t *entity, vec3_t start, vec3_t mins, vec3_t maxs,
    vec3_t end);
void SV_MoveBounds(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    vec3_t boxmins, vec3_t boxmaxs);

int BOX_ON_PLANE_SIDE(vec3_t mins, vec3_t maxs, mplane_t *plane)
{
    int sides = 0;
    float front;
    float back;
    if (plane->type < 3) {
        front = maxs[plane->type];
        back = mins[plane->type];
    } else {
        front = DotProduct(maxs, plane->normal);
        back = DotProduct(mins, plane->normal);
    }
    if (front >= plane->dist)
        sides |= 1;
    if (back < plane->dist)
        sides |= 2;
    return sides;
}

void Sys_Error(char *format, ...) { (void)format; }
void Con_Printf(char *format, ...) { (void)format; }
void Con_DPrintf(char *format, ...) { (void)format; }
void PR_ExecuteProgram(int function_index)
{
    if (function_index != 0)
        ++touch_count;
}

static void vector_set(vec3_t value, float x, float y, float z)
{
    value[0] = x;
    value[1] = y;
    value[2] = z;
}

static void configure_entity(
    edict_t *entity, float x, float y, float z,
    float min_x, float min_y, float min_z,
    float max_x, float max_y, float max_z, int solid)
{
    vector_set(entity->v.origin, x, y, z);
    vector_set(entity->v.mins, min_x, min_y, min_z);
    vector_set(entity->v.maxs, max_x, max_y, max_z);
    vector_set(
        entity->v.size, max_x - min_x, max_y - min_y, max_z - min_z);
    entity->v.solid = (float)solid;
}

static void reset_world(int negative_contents)
{
    memset(entities, 0, sizeof(entities));
    memset(&world_model, 0, sizeof(world_model));
    memset(&world_clipnode, 0, sizeof(world_clipnode));
    memset(&world_plane, 0, sizeof(world_plane));
    memset(world_leafs, 0, sizeof(world_leafs));
    memset(&globals, 0, sizeof(globals));
    touch_count = 0;

    world_plane.normal[0] = 1.0f;
    world_plane.type = 0;
    world_clipnode.planenum = 0;
    world_clipnode.children[0] = CONTENTS_EMPTY;
    world_clipnode.children[1] = (short)negative_contents;
    world_model.type = mod_brush;
    vector_set(world_model.mins, -100.0f, -100.0f, -100.0f);
    vector_set(world_model.maxs, 100.0f, 100.0f, 100.0f);
    world_model.hulls[0].clipnodes = &world_clipnode;
    world_model.hulls[0].planes = &world_plane;
    world_model.hulls[0].firstclipnode = 0;
    world_model.hulls[0].lastclipnode = 0;
    world_model.nodes = (mnode_t *)&world_leafs[0];
    world_model.leafs = world_leafs;
    world_leafs[0].contents = CONTENTS_SOLID;
    world_leafs[1].contents = CONTENTS_EMPTY;

    sv.worldmodel = &world_model;
    sv.models[0] = &world_model;
    sv.edicts = entities;
    sv.time = 3.5f;
    configure_entity(
        &entities[0], 0.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, SOLID_BSP);
    entities[0].v.movetype = MOVETYPE_PUSH;
    entities[0].v.modelindex = 0.0f;
    SV_ClearWorld();
}

static char *emit(
    char *output, const char *function_name, const char *case_name,
    int result, float a, float b, float c, float d, float e, float f,
    int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"a\":%.9g,\"b\":%.9g,\"c\":%.9g,\"d\":%.9g,"
        "\"e\":%.9g,\"f\":%.9g,\"count\":%d}\n",
        function_name, case_name, result, a, b, c, d, e, f, count);
    return output;
}

__declspec(dllexport) int __cdecl world_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    vec3_t mins;
    vec3_t maxs;
    vec3_t point;
    vec3_t offset;
    vec3_t start;
    vec3_t end;
    vec3_t boxmins;
    vec3_t boxmaxs;
    hull_t *hull;
    trace_t trace;
    int result;
    (void)capacity;

    reset_world(CONTENTS_EMPTY);
    SV_InitBoxHull();
    vector_set(mins, 0.0f, 0.0f, 0.0f);
    vector_set(maxs, 0.0f, 0.0f, 0.0f);
    vector_set(point, 0.0f, 0.0f, 0.0f);
    hull = SV_HullForBox(mins, maxs);
    result = SV_HullPointContents(hull, 0, point);
    cursor = emit(
        cursor, "SV_InitBoxHull", "zero_box", result,
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0);

    vector_set(mins, -2.0f, -3.0f, -4.0f);
    vector_set(maxs, 2.0f, 3.0f, 4.0f);
    vector_set(point, 3.0f, 0.0f, 0.0f);
    hull = SV_HullForBox(mins, maxs);
    result = SV_HullPointContents(hull, 0, point);
    cursor = emit(
        cursor, "SV_HullForBox", "outside", result,
        -2.0f, -3.0f, -4.0f, 2.0f, 3.0f, 4.0f, 0);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[3], 30.0f, 0.0f, 0.0f,
        -2.0f, -2.0f, -2.0f, 2.0f, 2.0f, 2.0f, SOLID_BBOX);
    vector_set(mins, -1.0f, -1.0f, -1.0f);
    vector_set(maxs, 1.0f, 1.0f, 1.0f);
    hull = SV_HullForEntity(&entities[3], mins, maxs, offset);
    vector_set(point, 0.0f, 0.0f, 0.0f);
    result = SV_HullPointContents(hull, 0, point);
    cursor = emit(
        cursor, "SV_HullForEntity", "bbox", result,
        offset[0], offset[1], offset[2], 0.0f, 0.0f, 0.0f, 0);

    reset_world(CONTENTS_EMPTY);
    cursor = emit(
        cursor, "SV_CreateAreaNode", "clear_tree", 1,
        -100.0f, -100.0f, -100.0f, 100.0f, 100.0f, 100.0f, 31);
    cursor = emit(
        cursor, "SV_ClearWorld", "world_bounds", 1,
        -100.0f, -100.0f, -100.0f, 100.0f, 100.0f, 100.0f, 31);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[3], 30.0f, 0.0f, 0.0f,
        -2.0f, -2.0f, -2.0f, 2.0f, 2.0f, 2.0f, SOLID_BBOX);
    SV_LinkEdict(&entities[3], false);
    SV_UnlinkEdict(&entities[3]);
    cursor = emit(
        cursor, "SV_UnlinkEdict", "linked", entities[3].area.prev == NULL,
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[2], 15.0f, 0.0f, 0.0f,
        -5.0f, -5.0f, -5.0f, 5.0f, 5.0f, 5.0f, SOLID_TRIGGER);
    entities[2].v.touch = 1;
    configure_entity(
        &entities[1], 10.0f, 0.0f, 0.0f,
        -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, SOLID_BBOX);
    SV_LinkEdict(&entities[2], false);
    SV_LinkEdict(&entities[1], true);
    cursor = emit(
        cursor, "SV_TouchLinks", "overlap", touch_count,
        entities[1].v.absmin[0], entities[1].v.absmax[0],
        entities[2].v.absmin[0], entities[2].v.absmax[0],
        pr_global_struct->time, 0.0f, touch_count);

    reset_world(CONTENTS_EMPTY);
    entities[1].v.absmin[0] = 1.0f;
    entities[1].v.absmax[0] = 2.0f;
    SV_FindTouchedLeafs(&entities[1], (mnode_t *)&world_leafs[1]);
    cursor = emit(
        cursor, "SV_FindTouchedLeafs", "empty_leaf",
        entities[1].leafnums[0], 0.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f, entities[1].num_leafs);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[1], 10.0f, 0.0f, 0.0f,
        -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, SOLID_BBOX);
    SV_LinkEdict(&entities[1], false);
    cursor = emit(
        cursor, "SV_LinkEdict", "bbox_expand",
        entities[1].area.prev != NULL,
        entities[1].v.absmin[0], entities[1].v.absmin[1],
        entities[1].v.absmin[2], entities[1].v.absmax[0],
        entities[1].v.absmax[1], entities[1].v.absmax[2], 0);

    reset_world(CONTENTS_EMPTY);
    vector_set(mins, -2.0f, -2.0f, -2.0f);
    vector_set(maxs, 2.0f, 2.0f, 2.0f);
    vector_set(point, 0.0f, 0.0f, 0.0f);
    hull = SV_HullForBox(mins, maxs);
    result = SV_HullPointContents(hull, 0, point);
    cursor = emit(
        cursor, "SV_HullPointContents", "inside_portable_c", result,
        point[0], point[1], point[2], 0.0f, 0.0f, 0.0f, 0);

    reset_world(CONTENTS_CURRENT_0);
    vector_set(point, -1.0f, 0.0f, 0.0f);
    result = SV_PointContents(point);
    cursor = emit(
        cursor, "SV_PointContents", "current_to_water", result,
        point[0], point[1], point[2], 0.0f, 0.0f, 0.0f, 0);
    result = SV_TruePointContents(point);
    cursor = emit(
        cursor, "SV_TruePointContents", "raw_current", result,
        point[0], point[1], point[2], 0.0f, 0.0f, 0.0f, 0);

    reset_world(CONTENTS_SOLID);
    configure_entity(
        &entities[1], -10.0f, 0.0f, 0.0f,
        -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, SOLID_BBOX);
    result = SV_TestEntityPosition(&entities[1]) == sv.edicts ? 0 : -1;
    cursor = emit(
        cursor, "SV_TestEntityPosition", "world_solid", result,
        entities[1].v.origin[0], 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0);

    reset_world(CONTENTS_SOLID);
    memset(&trace, 0, sizeof(trace));
    trace.fraction = 1.0f;
    trace.allsolid = true;
    vector_set(start, 10.0f, 0.0f, 0.0f);
    vector_set(end, -10.0f, 0.0f, 0.0f);
    result = SV_RecursiveHullCheck(
        &world_model.hulls[0], 0, 0.0f, 1.0f, start, end, &trace);
    cursor = emit(
        cursor, "SV_RecursiveHullCheck", "cross_solid", result,
        trace.endpos[0], trace.endpos[1], trace.endpos[2],
        trace.fraction, trace.plane.normal[0], trace.plane.dist, 0);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[3], 30.0f, 0.0f, 0.0f,
        -2.0f, -2.0f, -2.0f, 2.0f, 2.0f, 2.0f, SOLID_BBOX);
    vector_set(start, 20.0f, 0.0f, 0.0f);
    vector_set(end, 40.0f, 0.0f, 0.0f);
    vector_set(mins, -1.0f, -1.0f, -1.0f);
    vector_set(maxs, 1.0f, 1.0f, 1.0f);
    trace = SV_ClipMoveToEntity(&entities[3], start, mins, maxs, end);
    cursor = emit(
        cursor, "SV_ClipMoveToEntity", "bbox", trace.ent == &entities[3] ? 3 : -1,
        trace.endpos[0], trace.endpos[1], trace.endpos[2],
        trace.fraction, trace.plane.normal[0], trace.plane.dist, 0);

    vector_set(start, 10.0f, 5.0f, 0.0f);
    vector_set(mins, -1.0f, -2.0f, -3.0f);
    vector_set(maxs, 1.0f, 2.0f, 3.0f);
    vector_set(end, 20.0f, -5.0f, 4.0f);
    SV_MoveBounds(start, mins, maxs, end, boxmins, boxmaxs);
    cursor = emit(
        cursor, "SV_MoveBounds", "swept", 1,
        boxmins[0], boxmins[1], boxmins[2],
        boxmaxs[0], boxmaxs[1], boxmaxs[2], 0);

    reset_world(CONTENTS_EMPTY);
    configure_entity(
        &entities[1], 10.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, SOLID_BBOX);
    configure_entity(
        &entities[3], 30.0f, 0.0f, 0.0f,
        -2.0f, -2.0f, -2.0f, 2.0f, 2.0f, 2.0f, SOLID_BBOX);
    SV_LinkEdict(&entities[3], false);
    vector_set(start, 10.0f, 0.0f, 0.0f);
    vector_set(end, 60.0f, 0.0f, 0.0f);
    vector_set(mins, 0.0f, 0.0f, 0.0f);
    vector_set(maxs, 0.0f, 0.0f, 0.0f);
    trace = SV_Move(start, mins, maxs, end, MOVE_NORMAL, &entities[1]);
    result = trace.ent == &entities[3] ? 3 : 0;
    cursor = emit(
        cursor, "SV_ClipToLinks", "linked_bbox", result,
        trace.endpos[0], trace.endpos[1], trace.endpos[2],
        trace.fraction, trace.plane.normal[0], trace.plane.dist, 0);
    cursor = emit(
        cursor, "SV_Move", "linked_bbox", result,
        trace.endpos[0], trace.endpos[1], trace.endpos[2],
        trace.fraction, trace.plane.normal[0], trace.plane.dist, 0);

    *cursor = 0;
    return (int)(cursor - output);
}
