/* Direct deterministic harness for the pinned WinQuake/cl_tent.c. */

typedef unsigned char byte;
typedef int qboolean;
typedef float vec3_t[3];
typedef struct model_s { char name[64]; int marker; } model_t;
typedef struct sfx_s { char name[64]; int marker; } sfx_t;
typedef struct dlight_s {
    vec3_t origin;
    float radius;
    float die;
    float decay;
    float minlight;
    int key;
} dlight_t;
typedef struct entity_s {
    vec3_t origin;
    vec3_t angles;
    model_t *model;
    byte *colormap;
} entity_t;
typedef struct beam_s {
    int entity;
    model_t *model;
    float endtime;
    vec3_t start;
    vec3_t end;
} beam_t;
typedef struct client_state_s {
    double time;
    int viewentity;
} client_state_t;
typedef struct viddef_s { byte *colormap; } viddef_t;
typedef struct sizebuf_s {
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

#define true 1
#define false 0
#define NULL 0
#define MAX_TEMP_ENTITIES 64
#define MAX_BEAMS 24
#define MAX_VISEDICTS 256
#define TE_SPIKE 0
#define TE_SUPERSPIKE 1
#define TE_GUNSHOT 2
#define TE_EXPLOSION 3
#define TE_TAREXPLOSION 4
#define TE_LIGHTNING1 5
#define TE_LIGHTNING2 6
#define TE_WIZSPIKE 7
#define TE_KNIGHTSPIKE 8
#define TE_LIGHTNING3 9
#define TE_LAVASPLASH 10
#define TE_TELEPORT 11
#define TE_EXPLOSION2 12
#define TE_BEAM 13
#define M_PI 3.14159265358979323846
#define VectorCopy(a,b) do { (b)[0]=(a)[0]; (b)[1]=(a)[1]; (b)[2]=(a)[2]; } while (0)
#define VectorSubtract(a,b,c) do { (c)[0]=(a)[0]-(b)[0]; (c)[1]=(a)[1]-(b)[1]; (c)[2]=(a)[2]-(b)[2]; } while (0)

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) double __cdecl sqrt(double);
__declspec(dllimport) double __cdecl atan2(double, double);
int _fltused = 0;

client_state_t cl;
entity_t cl_entities[600];
int cl_numvisedicts;
entity_t *cl_visedicts[MAX_VISEDICTS];
viddef_t vid;
vec3_t vec3_origin = {0,0,0};
sizebuf_t net_message;
int msg_readcount;
qboolean msg_badread;

static byte mq_message_data[512];
static byte mq_colormap[256];
static sfx_t mq_sounds[16];
static model_t mq_models[4];
static dlight_t mq_dlight;
static int mq_precache_count;
static char mq_precache_names[16][64];
static int mq_particle_effect_calls;
static int mq_particle_explosion_calls;
static int mq_particle_explosion2_calls;
static int mq_blob_calls;
static int mq_lava_calls;
static int mq_teleport_calls;
static int mq_particle_color;
static int mq_particle_count;
static int mq_color_start;
static int mq_color_length;
static int mq_sound_calls;
static int mq_sound_marker;
static int mq_error;
static int mq_print_calls;

static int mq_strlen(const char *text)
{
    int result = 0;
    while (text[result])
        result++;
    return result;
}
static void mq_copy_text(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
        ;
}
static int mq_text_equal(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && left[index] == right[index])
        index++;
    return left[index] == right[index];
}
void *mq_memset(void *destination, int value, int length)
{
    byte *output = (byte *)destination;
    int index;
    for (index = 0; index < length; index++)
        output[index] = (byte)value;
    return destination;
}
int mq_rand(void) { return 0; }

void MSG_BeginReading(void) { msg_readcount = 0; msg_badread = false; }
int MSG_ReadByte(void)
{
    if (msg_readcount + 1 > net_message.cursize) {
        msg_badread = true;
        return -1;
    }
    return net_message.data[msg_readcount++];
}
int MSG_ReadShort(void)
{
    int value;
    if (msg_readcount + 2 > net_message.cursize) {
        msg_badread = true;
        return -1;
    }
    value = net_message.data[msg_readcount] | (net_message.data[msg_readcount+1] << 8);
    msg_readcount += 2;
    return value > 32767 ? value - 65536 : value;
}
float MSG_ReadCoord(void) { return MSG_ReadShort() * 0.125f; }

sfx_t *S_PrecacheSound(char *name)
{
    int index = mq_precache_count;
    mq_copy_text(mq_precache_names[index], name);
    mq_copy_text(mq_sounds[index].name, name);
    mq_sounds[index].marker = index + 1;
    mq_precache_count++;
    return &mq_sounds[index];
}
model_t *Mod_ForName(char *name, qboolean crash)
{
    int index = 3;
    (void)crash;
    if (mq_text_equal(name, "progs/bolt.mdl")) index = 0;
    else if (mq_text_equal(name, "progs/bolt2.mdl")) index = 1;
    else if (mq_text_equal(name, "progs/bolt3.mdl")) index = 2;
    mq_copy_text(mq_models[index].name, name);
    mq_models[index].marker = index + 1;
    return &mq_models[index];
}
void R_RunParticleEffect(vec3_t position, vec3_t direction, int color, int count)
{
    (void)position; (void)direction;
    mq_particle_effect_calls++;
    mq_particle_color = color;
    mq_particle_count = count;
}
void R_ParticleExplosion(vec3_t position) { (void)position; mq_particle_explosion_calls++; }
void R_ParticleExplosion2(vec3_t position, int start, int length)
{
    (void)position;
    mq_particle_explosion2_calls++;
    mq_color_start = start;
    mq_color_length = length;
}
void R_BlobExplosion(vec3_t position) { (void)position; mq_blob_calls++; }
void R_LavaSplash(vec3_t position) { (void)position; mq_lava_calls++; }
void R_TeleportSplash(vec3_t position) { (void)position; mq_teleport_calls++; }
void S_StartSound(int entity, int channel, sfx_t *sound, vec3_t position, float volume, float attenuation)
{
    (void)entity; (void)channel; (void)position; (void)volume; (void)attenuation;
    mq_sound_calls++;
    mq_sound_marker = sound ? sound->marker : 0;
}
dlight_t *CL_AllocDlight(int key)
{
    (void)key;
    mq_memset(&mq_dlight, 0, sizeof(mq_dlight));
    return &mq_dlight;
}
void Sys_Error(char *format, ...) { (void)format; mq_error = 1; }
void Con_Printf(char *format, ...) { (void)format; mq_print_calls++; }
float VectorNormalize(vec3_t value)
{
    float length = (float)sqrt(value[0]*value[0] + value[1]*value[1] + value[2]*value[2]);
    if (length != 0) {
        value[0] /= length; value[1] /= length; value[2] /= length;
    }
    return length;
}

#define memset mq_memset
#define rand mq_rand
/*__PINNED_CL_TENT_SOURCE__*/
#undef memset
#undef rand

static void mq_reset(void)
{
    mq_memset(&cl, 0, sizeof(cl));
    mq_memset(cl_entities, 0, sizeof(cl_entities));
    mq_memset(cl_visedicts, 0, sizeof(cl_visedicts));
    mq_memset(cl_temp_entities, 0, sizeof(cl_temp_entities));
    mq_memset(cl_beams, 0, sizeof(cl_beams));
    mq_memset(mq_sounds, 0, sizeof(mq_sounds));
    mq_memset(mq_models, 0, sizeof(mq_models));
    mq_memset(&mq_dlight, 0, sizeof(mq_dlight));
    mq_memset(mq_precache_names, 0, sizeof(mq_precache_names));
    net_message.data = mq_message_data;
    net_message.maxsize = sizeof(mq_message_data);
    net_message.cursize = 0;
    msg_readcount = 0;
    msg_badread = false;
    vid.colormap = mq_colormap;
    cl_numvisedicts = 0;
    num_temp_entities = 0;
    mq_precache_count = 0;
    mq_particle_effect_calls = 0;
    mq_particle_explosion_calls = 0;
    mq_particle_explosion2_calls = 0;
    mq_blob_calls = 0;
    mq_lava_calls = 0;
    mq_teleport_calls = 0;
    mq_particle_color = 0;
    mq_particle_count = 0;
    mq_color_start = 0;
    mq_color_length = 0;
    mq_sound_calls = 0;
    mq_sound_marker = 0;
    mq_error = 0;
    mq_print_calls = 0;
}

static void mq_message(const byte *data, int length)
{
    int index;
    for (index = 0; index < length; index++)
        net_message.data[index] = data[index];
    net_message.cursize = length;
    MSG_BeginReading();
}
static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output);
    int length = mq_strlen(line);
    int index;
    if (used + length + 1 >= capacity)
        return;
    for (index = 0; index < length; index++)
        output[used+index] = line[index];
    output[used+length] = '\n';
    output[used+length+1] = 0;
}
static int mq_active_beams(void)
{
    int index;
    int count = 0;
    for (index = 0; index < MAX_BEAMS; index++)
        if (cl_beams[index].model)
            count++;
    return count;
}

__declspec(dllexport) int cl_tent_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    model_t *bolt;
    model_t *bolt2;
    entity_t *created;
    entity_t *overflow;
    int created_temp_count;
    int created_visible_count;

    if (!output || capacity < 2)
        return -1;
    output[0] = 0;

    mq_reset();
    CL_InitTEnts();
    sprintf(line, "{\"function\":\"CL_InitTEnts\",\"case\":\"stock_precache\",\"sounds\":%i,\"first_ok\":%s,\"last_ok\":%s}",
        mq_precache_count,
        mq_text_equal(mq_precache_names[0], "wizard/hit.wav") ? "true" : "false",
        mq_text_equal(mq_precache_names[6], "weapons/r_exp3.wav") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    bolt = Mod_ForName("progs/bolt.mdl", true);
    bolt2 = Mod_ForName("progs/bolt2.mdl", true);
    cl.time = 10.0;
    {
        byte first[] = {7,0,8,0,16,0,24,0,232,1,16,0,24,0};
        mq_message(first, sizeof(first));
        CL_ParseBeam(bolt);
    }
    cl.time = 10.1;
    {
        byte replacement[] = {7,0,32,0,40,0,48,0,0,2,40,0,48,0};
        mq_message(replacement, sizeof(replacement));
        CL_ParseBeam(bolt2);
    }
    sprintf(line, "{\"function\":\"CL_ParseBeam\",\"case\":\"allocate_override\",\"entity\":%i,\"model\":%i,\"end_time\":%g,\"start\":[%g,%g,%g],\"end\":[%g,%g,%g],\"active\":%i,\"bytes_read\":%i}",
        cl_beams[0].entity, cl_beams[0].model->marker, cl_beams[0].endtime,
        cl_beams[0].start[0], cl_beams[0].start[1], cl_beams[0].start[2],
        cl_beams[0].end[0], cl_beams[0].end[1], cl_beams[0].end[2],
        mq_active_beams(),
        msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    CL_InitTEnts();
    cl.time = 3.0;
    {
        byte explosion2[] = {TE_EXPLOSION2,64,0,128,255,192,0,40,8};
        mq_message(explosion2, sizeof(explosion2));
        CL_ParseTEnt();
    }
    sprintf(line, "{\"function\":\"CL_ParseTEnt\",\"case\":\"explosion2\",\"particles\":%i,\"color_start\":%i,\"color_length\":%i,\"sound\":%i,\"light_radius\":%g,\"light_die\":%g,\"light_decay\":%g,\"origin\":[%g,%g,%g],\"bytes_read\":%i}",
        mq_particle_explosion2_calls, mq_color_start, mq_color_length,
        mq_sound_marker, mq_dlight.radius, mq_dlight.die, mq_dlight.decay,
        mq_dlight.origin[0], mq_dlight.origin[1], mq_dlight.origin[2],
        msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    created = CL_NewTempEntity();
    created_temp_count = num_temp_entities;
    created_visible_count = cl_numvisedicts;
    num_temp_entities = MAX_TEMP_ENTITIES;
    overflow = CL_NewTempEntity();
    sprintf(line, "{\"function\":\"CL_NewTempEntity\",\"case\":\"allocate_and_cap\",\"created\":%s,\"temp_count\":%i,\"visible_count\":%i,\"colormap\":%s,\"cap_returns_null\":%s}",
        created ? "true" : "false",
        created_temp_count,
        created_visible_count,
        created && created->colormap == vid.colormap ? "true" : "false",
        overflow == NULL ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    bolt = Mod_ForName("progs/bolt.mdl", true);
    cl.time = 0.1;
    cl.viewentity = 1;
    cl_entities[1].origin[0] = 5;
    cl_beams[0].entity = 1;
    cl_beams[0].model = bolt;
    cl_beams[0].endtime = 0.2f;
    cl_beams[0].start[0] = 0;
    cl_beams[0].end[0] = 95;
    CL_UpdateTEnts();
    sprintf(line, "{\"function\":\"CL_UpdateTEnts\",\"case\":\"player_beam_segments\",\"segments\":%i,\"origins\":[%g,%g,%g],\"model\":%i,\"pitch\":%g,\"yaw\":%g,\"visible\":%i}",
        num_temp_entities, cl_temp_entities[0].origin[0],
        cl_temp_entities[1].origin[0], cl_temp_entities[2].origin[0],
        cl_temp_entities[0].model->marker, cl_temp_entities[0].angles[0],
        cl_temp_entities[0].angles[1], cl_numvisedicts);
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
