/*
 * Deterministic engine boundary for the pinned WinQuake/cl_main.c.
 * tools/cl_main_differential.py inserts that source at the marker.
 */

typedef unsigned char byte;
typedef int qboolean;
typedef float vec3_t[3];
typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;
typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
} cvar_t;
typedef struct usercmd_s {
    vec3_t viewangles;
    float forwardmove;
    float sidemove;
    float upmove;
    byte buttons;
    byte impulse;
    byte msec;
} usercmd_t;
typedef struct model_s {
    char name[64];
    int flags;
} model_t;
typedef struct entity_state_s { int marker; } entity_state_t;
typedef struct efrag_s {
    void *leaf;
    struct efrag_s *leafnext;
    struct entity_s *entity;
    struct efrag_s *entnext;
} efrag_t;
typedef struct entity_s {
    qboolean forcelink;
    int update_type;
    entity_state_t baseline;
    double msgtime;
    vec3_t msg_origins[2];
    vec3_t origin;
    vec3_t msg_angles[2];
    vec3_t angles;
    model_t *model;
    efrag_t *efrag;
    int frame;
    float syncbase;
    byte *colormap;
    int effects;
    int skinnum;
} entity_t;
typedef struct dlight_s {
    vec3_t origin;
    float radius;
    float die;
    float decay;
    float minlight;
    int key;
} dlight_t;
typedef struct lightstyle_s { int length; char map[64]; } lightstyle_t;
typedef struct beam_s { int marker; } beam_t;
typedef struct qsocket_s { int marker; } qsocket_t;
typedef struct server_s { qboolean active; } server_t;

#define true 1
#define false 0
#define NULL 0
#define MAX_EFRAGS 640
#define MAX_EDICTS 600
#define MAX_STATIC_ENTITIES 128
#define MAX_LIGHTSTYLES 64
#define MAX_DLIGHTS 32
#define MAX_TEMP_ENTITIES 64
#define MAX_BEAMS 24
#define MAX_VISEDICTS 256
#define MAX_DEMOS 8
#define MAX_DEMONAME 16
#define MAX_MAPSTRING 2048
#define SIGNONS 4
#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2
#define clc_disconnect 2
#define clc_stringcmd 4
#define EF_BRIGHTFIELD 1
#define EF_MUZZLEFLASH 2
#define EF_BRIGHTLIGHT 4
#define EF_DIMLIGHT 8
#define EF_ROCKET 1
#define EF_GRENADE 2
#define EF_GIB 4
#define EF_ROTATE 8
#define EF_TRACER 16
#define EF_ZOMGIB 32
#define EF_TRACER2 64
#define EF_TRACER3 128
#define VectorCopy(a,b) do { (b)[0]=(a)[0]; (b)[1]=(a)[1]; (b)[2]=(a)[2]; } while (0)
#define VectorMA(a,s,b,c) do { (c)[0]=(a)[0]+(s)*(b)[0]; (c)[1]=(a)[1]+(s)*(b)[1]; (c)[2]=(a)[2]+(s)*(b)[2]; } while (0)

typedef struct client_static_s {
    int state;
    int demonum;
    char demos[MAX_DEMOS][MAX_DEMONAME];
    qboolean demorecording;
    qboolean demoplayback;
    qboolean timedemo;
    int forcetrack;
    char spawnparms[MAX_MAPSTRING];
    qsocket_t *netcon;
    int signon;
    sizebuf_t message;
} client_static_t;
typedef struct client_state_s {
    vec3_t mviewangles[2];
    vec3_t viewangles;
    vec3_t mvelocity[2];
    vec3_t velocity;
    double mtime[2];
    double time;
    double oldtime;
    float last_received_message;
    int viewentity;
    int num_entities;
    efrag_t *free_efrags;
} client_state_t;

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

entity_t cl_temp_entities[MAX_TEMP_ENTITIES];
beam_t cl_beams[MAX_BEAMS];
server_t sv;
cvar_t chase_active = {"chase_active", "0", false, false, 0};
cvar_t cl_upspeed = {"cl_upspeed", "200", true};
cvar_t cl_forwardspeed = {"cl_forwardspeed", "200", true};
cvar_t cl_backspeed = {"cl_backspeed", "200", true};
cvar_t cl_sidespeed = {"cl_sidespeed", "350", true};
cvar_t cl_movespeedkey = {"cl_movespeedkey", "2.0"};
cvar_t cl_yawspeed = {"cl_yawspeed", "140"};
cvar_t cl_pitchspeed = {"cl_pitchspeed", "150"};
cvar_t cl_anglespeedkey = {"cl_anglespeedkey", "1.5"};
float host_frametime;
float realtime;

extern client_static_t cls;
extern client_state_t cl;
extern efrag_t cl_efrags[MAX_EFRAGS];
extern entity_t cl_entities[MAX_EDICTS];
extern dlight_t cl_dlights[MAX_DLIGHTS];
extern int cl_numvisedicts;
extern entity_t *cl_visedicts[MAX_VISEDICTS];
extern cvar_t cl_name;
extern cvar_t cl_color;

static byte mq_message_data[8192];
static qsocket_t mq_socket;
static int mq_host_clear_calls;
static int mq_stop_sound_calls;
static int mq_stop_playback_calls;
static int mq_stop_record_calls;
static int mq_shutdown_calls;
static int mq_connect_calls;
static char mq_connect_host[128];
static int mq_net_close_calls;
static int mq_unreliable_sends;
static byte mq_unreliable_opcode;
static int mq_reliable_sends;
static int mq_can_send;
static int mq_send_result;
static int mq_loading_begin;
static int mq_loading_end;
static int mq_cache_reports;
static char mq_inserted_text[256];
static int mq_print_calls;
static int mq_written_string_count;
static char mq_written_strings[16][256];
static int mq_signon_bytes;
static int mq_remove_efrags;
static int mq_entity_particles;
static int mq_rocket_trails;
static int mq_last_trail_type;
static int mq_trail_type_counts[7];
static unsigned int mq_random_seed;
static int mq_get_index;
static int mq_get_count;
static int mq_get_returns[8];
static int mq_parse_calls;
static int mq_update_tents;
static int mq_base_move_calls;
static int mq_input_move_calls;
static int mq_send_move_calls;
static int mq_init_input_calls;
static int mq_init_tents_calls;
static int mq_cvar_registers;
static int mq_command_registers;
static int mq_noop_sentinel;

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

int mq_rand(void)
{
    mq_random_seed = mq_random_seed * 214013u + 2531011u;
    return (mq_random_seed >> 16) & 0x7fff;
}

void Host_ClearMemory(void) { mq_host_clear_calls++; }
void S_StopAllSounds(qboolean clear) { (void)clear; mq_stop_sound_calls++; }
void CL_StopPlayback(void) { mq_stop_playback_calls++; }
void CL_Stop_f(void) { mq_stop_record_calls++; }
void CL_Record_f(void) {}
void CL_PlayDemo_f(void) {}
void CL_TimeDemo_f(void) {}
void Host_ShutdownServer(qboolean crash)
{
    (void)crash;
    mq_shutdown_calls++;
    sv.active = false;
}
void Con_DPrintf(const char *format, ...) { (void)format; }
void Con_Printf(const char *format, ...) { (void)format; mq_print_calls++; }
void Host_Error(const char *format, ...) { (void)format; }

void SZ_Clear(sizebuf_t *buffer) { buffer->cursize = 0; }
void SZ_Alloc(sizebuf_t *buffer, int size)
{
    buffer->data = mq_message_data;
    buffer->maxsize = size;
    buffer->cursize = 0;
}
void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize < buffer->maxsize)
        buffer->data[buffer->cursize++] = (byte)value;
    mq_signon_bytes++;
}
void MSG_WriteString(sizebuf_t *buffer, const char *text)
{
    int index = 0;
    if (mq_written_string_count < 16)
        mq_copy_text(mq_written_strings[mq_written_string_count++], text);
    while (text[index]) {
        MSG_WriteByte(buffer, text[index]);
        index++;
    }
    MSG_WriteByte(buffer, 0);
}

int NET_SendUnreliableMessage(qsocket_t *socket, sizebuf_t *message)
{
    (void)socket;
    mq_unreliable_sends++;
    mq_unreliable_opcode = message->cursize ? message->data[0] : 0;
    return 1;
}
void NET_Close(qsocket_t *socket) { (void)socket; mq_net_close_calls++; }
qsocket_t *NET_Connect(char *host)
{
    mq_connect_calls++;
    mq_copy_text(mq_connect_host, host);
    return &mq_socket;
}
qboolean NET_CanSendMessage(qsocket_t *socket) { (void)socket; return mq_can_send; }
int NET_SendMessage(qsocket_t *socket, sizebuf_t *message)
{
    (void)socket;
    (void)message;
    mq_reliable_sends++;
    return mq_send_result;
}

char *va(const char *format, ...)
{
    static char result[256];
    if (format[0] == 'n')
        sprintf(result, "name \"%s\"\n", cl_name.string);
    else
        sprintf(result, "color %i %i\n", ((int)cl_color.value)>>4, ((int)cl_color.value)&15);
    return result;
}

void Cache_Report(void) { mq_cache_reports++; }
void SCR_EndLoadingPlaque(void) { mq_loading_end++; }
void SCR_BeginLoadingPlaque(void) { mq_loading_begin++; }
void Cbuf_InsertText(char *text) { mq_copy_text(mq_inserted_text, text); }
void R_RemoveEfrags(entity_t *entity) { (void)entity; mq_remove_efrags++; }
void R_EntityParticles(entity_t *entity) { (void)entity; mq_entity_particles++; }
void R_RocketTrail(vec3_t start, vec3_t end, int type)
{
    (void)start;
    (void)end;
    mq_rocket_trails++;
    mq_last_trail_type = type;
    if (type >= 0 && type < 7)
        mq_trail_type_counts[type]++;
}

float anglemod(float angle)
{
    return (360.0f / 65536.0f)
        * (((int)(angle * (65536.0f / 360.0f))) & 65535);
}
void AngleVectors(vec3_t angles, vec3_t forward, vec3_t right, vec3_t up)
{
    (void)angles;
    forward[0] = 1; forward[1] = 0; forward[2] = 0;
    right[0] = 0; right[1] = -1; right[2] = 0;
    up[0] = 0; up[1] = 0; up[2] = 1;
}

int CL_GetMessage(void)
{
    if (mq_get_index >= mq_get_count)
        return 0;
    return mq_get_returns[mq_get_index++];
}
void CL_ParseServerMessage(void)
{
    mq_parse_calls++;
    cl.mtime[1] = cl.mtime[0];
    cl.mtime[0] = 3.25;
}
void CL_UpdateTEnts(void) { mq_update_tents++; }
void CL_BaseMove(usercmd_t *command)
{
    mq_base_move_calls++;
    mq_memset(command, 0, sizeof(*command));
    command->forwardmove = 100;
}
void IN_Move(usercmd_t *command) { mq_input_move_calls++; command->sidemove = 20; }
void CL_SendMove(usercmd_t *command) { (void)command; mq_send_move_calls++; }
void CL_InitInput(void) { mq_init_input_calls++; }
void CL_InitTEnts(void) { mq_init_tents_calls++; }
void Cvar_RegisterVariable(cvar_t *variable) { (void)variable; mq_cvar_registers++; }
void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    mq_command_registers++;
}

#define memset mq_memset
#define rand mq_rand
/*__PINNED_CL_MAIN_SOURCE__*/
#undef memset
#undef rand

static void mq_reset_counters(void)
{
    mq_host_clear_calls = 0;
    mq_stop_sound_calls = 0;
    mq_stop_playback_calls = 0;
    mq_stop_record_calls = 0;
    mq_shutdown_calls = 0;
    mq_connect_calls = 0;
    mq_net_close_calls = 0;
    mq_unreliable_sends = 0;
    mq_unreliable_opcode = 0;
    mq_reliable_sends = 0;
    mq_loading_begin = 0;
    mq_loading_end = 0;
    mq_cache_reports = 0;
    mq_print_calls = 0;
    mq_written_string_count = 0;
    mq_signon_bytes = 0;
    mq_remove_efrags = 0;
    mq_entity_particles = 0;
    mq_rocket_trails = 0;
    mq_last_trail_type = -1;
    mq_memset(mq_trail_type_counts, 0, sizeof(mq_trail_type_counts));
    mq_random_seed = 1;
    mq_get_index = 0;
    mq_get_count = 0;
    mq_parse_calls = 0;
    mq_update_tents = 0;
    mq_base_move_calls = 0;
    mq_input_move_calls = 0;
    mq_send_move_calls = 0;
    mq_init_input_calls = 0;
    mq_init_tents_calls = 0;
    mq_cvar_registers = 0;
    mq_command_registers = 0;
    mq_memset(mq_written_strings, 0, sizeof(mq_written_strings));
    mq_memset(mq_inserted_text, 0, sizeof(mq_inserted_text));
    mq_memset(mq_connect_host, 0, sizeof(mq_connect_host));
}

static void mq_reset(void)
{
    mq_memset(&cls, 0, sizeof(cls));
    mq_memset(&cl, 0, sizeof(cl));
    mq_memset(cl_efrags, 0, sizeof(cl_efrags));
    mq_memset(cl_entities, 0, sizeof(cl_entities));
    mq_memset(cl_dlights, 0, sizeof(cl_dlights));
    mq_memset(cl_lightstyle, 0, sizeof(cl_lightstyle));
    mq_memset(cl_temp_entities, 0, sizeof(cl_temp_entities));
    mq_memset(cl_beams, 0, sizeof(cl_beams));
    cls.state = ca_disconnected;
    cls.message.data = mq_message_data;
    cls.message.maxsize = sizeof(mq_message_data);
    mq_can_send = true;
    mq_send_result = 1;
    sv.active = false;
    chase_active.value = 0;
    cl_nolerp.value = 0;
    mq_reset_counters();
}

static int mq_dlight_index(dlight_t *light)
{
    return (int)(light - cl_dlights);
}

static dlight_t *mq_dlight_for_key(int key)
{
    int index;
    for (index = 0; index < MAX_DLIGHTS; index++)
        if (cl_dlights[index].key == key)
            return &cl_dlights[index];
    return NULL;
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

__declspec(dllexport) int cl_main_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    model_t model;
    model_t models[9];
    dlight_t *light;
    dlight_t *fallback;
    float normal;
    float gap;
    float high;
    int index;
    int chain_ok;

    if (!output || capacity < 2)
        return -1;
    output[0] = 0;

    mq_reset();
    cl.num_entities = 9;
    cls.message.cursize = 3;
    cl_entities[1].frame = 7;
    CL_ClearState();
    chain_ok = cl.free_efrags == cl_efrags
        && cl_efrags[0].entnext == &cl_efrags[1]
        && cl_efrags[MAX_EFRAGS-1].entnext == NULL;
    sprintf(line, "{\"function\":\"CL_ClearState\",\"case\":\"wipe_and_efrags\",\"message_size\":%i,\"num_entities\":%i,\"state_wiped\":%s}",
        cls.message.cursize, cl.num_entities,
        chain_ok && mq_host_clear_calls == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demoplayback = true;
    cls.timedemo = true;
    cls.signon = 4;
    CL_Disconnect();
    cls.demoplayback = false;
    cls.state = ca_connected;
    cls.demorecording = true;
    cls.timedemo = true;
    cls.signon = 4;
    sv.active = true;
    CL_Disconnect();
    sprintf(line, "{\"function\":\"CL_Disconnect\",\"case\":\"playback_and_connected\",\"playback\":%s,\"connected\":%s,\"unreliable_opcode\":%i,\"net_closed\":%s,\"signon\":%i,\"timedemo\":%s}",
        cls.demoplayback ? "true" : "false",
        cls.state == ca_connected ? "true" : "false", mq_unreliable_opcode,
        mq_net_close_calls == 1 ? "true" : "false", cls.signon,
        cls.timedemo ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.state = ca_disconnected;
    sv.active = true;
    CL_Disconnect_f();
    sprintf(line, "{\"function\":\"CL_Disconnect_f\",\"case\":\"shutdown_local\",\"connected\":%s,\"signon\":%i,\"shutdown\":%s}",
        cls.state == ca_connected ? "true" : "false", cls.signon,
        mq_shutdown_calls == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demonum = 3;
    CL_EstablishConnection("local");
    sprintf(line, "{\"function\":\"CL_EstablishConnection\",\"case\":\"local\",\"connected\":%s,\"signon\":%i,\"spawned\":false,\"transport_ready\":%s}",
        cls.state == ca_connected ? "true" : "false", cls.signon,
        cls.netcon == &mq_socket ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cl_name.string = "Ranger";
    cl_color.value = 0x4f;
    mq_copy_text(cls.spawnparms, "coop 1");
    cls.signon = 1; CL_SignonReply();
    cls.signon = 2; CL_SignonReply();
    cls.signon = 3; CL_SignonReply();
    cls.signon = 4; CL_SignonReply();
    sprintf(line, "{\"function\":\"CL_SignonReply\",\"case\":\"all_stages\",\"strings\":%i,\"stage1_ok\":%s,\"name_ok\":%s,\"color_ok\":%s,\"spawn_ok\":%s,\"begin_ok\":%s,\"cache_reports\":%i,\"loading_end\":%i}",
        mq_written_string_count,
        mq_text_equal(mq_written_strings[0], "prespawn") ? "true" : "false",
        mq_text_equal(mq_written_strings[1], "name \"Ranger\"\n") ? "true" : "false",
        mq_text_equal(mq_written_strings[2], "color 4 15\n") ? "true" : "false",
        mq_text_equal(mq_written_strings[3], "spawn coop 1") ? "true" : "false",
        mq_text_equal(mq_written_strings[4], "begin") ? "true" : "false",
        mq_cache_reports, mq_loading_end);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demonum = 2;
    mq_copy_text(cls.demos[0], "demo1");
    mq_copy_text(cls.demos[1], "demo2");
    CL_NextDemo();
    sprintf(line, "{\"function\":\"CL_NextDemo\",\"case\":\"wrap\",\"loading_begin\":%i,\"command_ok\":%s,\"demonum\":%i}",
        mq_loading_begin,
        mq_text_equal(mq_inserted_text, "playdemo demo1\n") ? "true" : "false",
        cls.demonum);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_memset(&model, 0, sizeof(model));
    mq_copy_text(model.name, "progs/player.mdl");
    cl.num_entities = 2;
    cl_entities[1].model = &model;
    cl_entities[1].frame = 3;
    CL_PrintEntities_f();
    sprintf(line, "{\"function\":\"CL_PrintEntities_f\",\"case\":\"empty_and_model\",\"records\":%i}",
        mq_print_calls / 2);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_noop_sentinel = 77;
    SetPal(2);
    sprintf(line, "{\"function\":\"SetPal\",\"case\":\"compiled_out\",\"sentinel\":%i}",
        mq_noop_sentinel);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.time = 1.0;
    cl_dlights[3].key = 17;
    cl_dlights[3].radius = 90;
    light = CL_AllocDlight(17);
    for (index = 0; index < MAX_DLIGHTS; index++)
        cl_dlights[index].die = 2.0;
    fallback = CL_AllocDlight(9);
    sprintf(line, "{\"function\":\"CL_AllocDlight\",\"case\":\"key_and_fallback\",\"key_slot\":%i,\"key_radius\":%g,\"fallback_slot\":%i,\"fallback_key\":%i}",
        mq_dlight_index(light), light->radius, mq_dlight_index(fallback),
        fallback->key);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.oldtime = 0.75;
    cl.time = 1.0;
    cl_dlights[2].radius = 90;
    cl_dlights[2].decay = 40;
    cl_dlights[2].die = 2;
    CL_DecayLights();
    sprintf(line, "{\"function\":\"CL_DecayLights\",\"case\":\"active\",\"radius\":%g,\"elapsed\":%g}",
        cl_dlights[2].radius, (float)(cl.time-cl.oldtime));
    mq_emit(output, capacity, line);

    mq_reset();
    cl.mtime[0] = 2.0; cl.mtime[1] = 1.9; cl.time = 1.95;
    normal = CL_LerpPoint();
    cl.mtime[0] = 3.0; cl.mtime[1] = 2.0; cl.time = 2.95;
    gap = CL_LerpPoint();
    cl.mtime[0] = 3.0; cl.mtime[1] = 2.9; cl.time = 4.0;
    high = CL_LerpPoint();
    sprintf(line, "{\"function\":\"CL_LerpPoint\",\"case\":\"normal_gap_high\",\"normal\":%g,\"gap\":%g,\"high\":%g,\"clamped_time\":%g}",
        normal, gap, high, (float)cl.time);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_memset(&model, 0, sizeof(model));
    cl.mtime[0] = 2.0; cl.mtime[1] = 1.9; cl.time = 1.95;
    cl.mvelocity[0][0] = 10;
    cl.num_entities = 2;
    cl_entities[1].model = &model;
    cl_entities[1].msgtime = 2.0;
    cl_entities[1].msg_origins[0][0] = 10;
    cl_entities[1].msg_angles[0][1] = 10;
    cl_entities[1].msg_angles[1][1] = 350;
    CL_RelinkEntities();
    sprintf(line, "{\"function\":\"CL_RelinkEntities\",\"case\":\"interpolate_visible\",\"origin_x\":%g,\"angle_y\":%g,\"velocity_x\":%g,\"visible\":%i,\"force_link\":%s}",
        cl_entities[1].origin[0], cl_entities[1].angles[1], cl.velocity[0],
        cl_numvisedicts, cl_entities[1].forcelink ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_memset(models, 0, sizeof(models));
    models[1].flags = EF_ROTATE;
    models[2].flags = EF_GIB;
    models[3].flags = EF_ZOMGIB;
    models[4].flags = EF_TRACER;
    models[5].flags = EF_TRACER2;
    models[6].flags = EF_ROCKET;
    models[7].flags = EF_GRENADE;
    models[8].flags = EF_TRACER3;
    cl.mtime[0] = 2.0; cl.mtime[1] = 1.9; cl.time = 2.0;
    cl_nolerp.value = 1;
    cl.num_entities = 9;
    cl.viewentity = 1;
    chase_active.value = 1;
    for (index = 1; index < 9; index++) {
        cl_entities[index].model = &models[index];
        cl_entities[index].msgtime = 2.0;
        cl_entities[index].msg_origins[0][0] = 9;
    }
    cl_entities[1].effects =
        EF_BRIGHTFIELD | EF_MUZZLEFLASH | EF_BRIGHTLIGHT | EF_DIMLIGHT;
    CL_RelinkEntities();
    light = mq_dlight_for_key(6);
    fallback = mq_dlight_for_key(1);
    sprintf(line, "{\"function\":\"CL_RelinkEntities\",\"case\":\"model_effect_matrix\",\"rotate_y\":%.9g,\"entity_particles\":%i,\"trail_0\":%i,\"trail_1\":%i,\"trail_2\":%i,\"trail_3\":%i,\"trail_4\":%i,\"trail_5\":%i,\"trail_6\":%i,\"visible\":%i,\"effect_radius\":%g,\"rocket_radius\":%g,\"rocket_die\":%g}",
        cl_entities[1].angles[1], mq_entity_particles,
        mq_trail_type_counts[0], mq_trail_type_counts[1],
        mq_trail_type_counts[2], mq_trail_type_counts[3],
        mq_trail_type_counts[4], mq_trail_type_counts[5],
        mq_trail_type_counts[6], cl_numvisedicts,
        fallback ? fallback->radius : -1.0f,
        light ? light->radius : -1.0f,
        light ? light->die : -1.0f);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_memset(&model, 0, sizeof(model));
    cls.demoplayback = true;
    cl.mtime[0] = 2.0; cl.mtime[1] = 1.9; cl.time = 1.95;
    cl.mviewangles[0][1] = 10; cl.mviewangles[1][1] = 350;
    cl.num_entities = 5;
    cl.viewentity = 4;
    cl_entities[1].model = &model;
    cl_entities[1].msgtime = 2.0;
    cl_entities[1].forcelink = true;
    cl_entities[1].msg_origins[0][0] = 25;
    cl_entities[2].model = &model;
    cl_entities[2].msgtime = 2.0;
    cl_entities[2].msg_origins[0][0] = 200;
    cl_entities[3].model = &model;
    cl_entities[3].msgtime = 1.9;
    cl_entities[4].model = &model;
    cl_entities[4].msgtime = 2.0;
    cl_entities[4].msg_origins[0][0] = 10;
    CL_RelinkEntities();
    sprintf(line, "{\"function\":\"CL_RelinkEntities\",\"case\":\"force_teleport_stale_demo_view\",\"force_x\":%g,\"teleport_x\":%g,\"stale_removed\":%s,\"demo_yaw\":%g,\"view_hidden\":%s,\"visible\":%i}",
        cl_entities[1].origin[0], cl_entities[2].origin[0],
        cl_entities[3].model == NULL ? "true" : "false",
        cl.viewangles[1],
        cl_visedicts[0] != &cl_entities[4] && cl_visedicts[1] != &cl_entities[4]
            ? "true" : "false",
        cl_numvisedicts);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.state = ca_connected;
    cl.time = 1.0;
    host_frametime = 0.02f;
    realtime = 9.5f;
    mq_get_count = 3;
    mq_get_returns[0] = 1;
    mq_get_returns[1] = 2;
    mq_get_returns[2] = 0;
    mq_memset(&model, 0, sizeof(model));
    cl.num_entities = 2;
    cl_entities[1].model = &model;
    cl_entities[1].msgtime = 3.25;
    CL_ReadFromServer();
    sprintf(line, "{\"function\":\"CL_ReadFromServer\",\"case\":\"two_messages\",\"old_time\":%g,\"time\":%g,\"last_received\":%g,\"relinked\":%s,\"visible\":%i}",
        (float)cl.oldtime, (float)cl.time, cl.last_received_message,
        mq_update_tents == 1 && mq_parse_calls == 2 ? "true" : "false",
        cl_numvisedicts);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.state = ca_connected;
    cls.signon = SIGNONS;
    cls.message.data[0] = clc_stringcmd;
    cls.message.cursize = 1;
    CL_SendCmd();
    CL_SendCmd();
    CL_SendCmd();
    sprintf(line, "{\"function\":\"CL_SendCmd\",\"case\":\"move_and_reliable\",\"move_calls\":%i,\"reliable_sends\":%i,\"message_size\":%i}",
        mq_send_move_calls,
        mq_reliable_sends, cls.message.cursize);
    mq_emit(output, capacity, line);

    mq_reset();
    CL_Init();
    sprintf(line, "{\"function\":\"CL_Init\",\"case\":\"registrations\",\"message_capacity\":%i,\"input_init\":%i,\"tent_init\":%i,\"cvars\":%i,\"commands\":%i}",
        cls.message.maxsize, mq_init_input_calls, mq_init_tents_calls,
        mq_cvar_registers, mq_command_registers);
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
