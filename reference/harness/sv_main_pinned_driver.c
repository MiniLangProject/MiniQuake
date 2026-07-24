#include "sv_main_oracle_stubs.h"

int _fltused = 0;

client_t *host_client;
static globalvars_t globals;
globalvars_t *pr_global_struct = &globals;
client_static_t cls;
char pr_strings[4096];
int pr_crc = 12345;
int net_activeconnections;
double realtime;
int standard_quake = 1;
int current_skill;
int pr_edict_size = sizeof(edict_t);
static dprograms_t program_header = {64};
dprograms_t *progs = &program_header;
float host_frametime;
float scr_centertime_off;
cvar_t coop = {"coop", "0", 0, 0, 0.0f, 0};
cvar_t deathmatch = {"deathmatch", "0", 0, 0, 0.0f, 0};
cvar_t skill = {"skill", "1", 0, 0, 1.0f, 0};
cvar_t hostname = {"hostname", "oracle", 0, 0, 0.0f, 0};
cvar_t sv_maxvelocity = {"sv_maxvelocity", "2000", 0, 0, 2000.0f, 0};
cvar_t sv_gravity = {"sv_gravity", "800", 0, 0, 800.0f, 0};
cvar_t sv_nostep = {"sv_nostep", "0", 0, 0, 0.0f, 0};
cvar_t sv_friction = {"sv_friction", "4", 0, 0, 4.0f, 0};
cvar_t sv_edgefriction = {"edgefriction", "2", 0, 0, 2.0f, 0};
cvar_t sv_stopspeed = {"sv_stopspeed", "100", 0, 0, 100.0f, 0};
cvar_t sv_maxspeed = {"sv_maxspeed", "320", 0, 0, 320.0f, 0};
cvar_t sv_accelerate = {"sv_accelerate", "10", 0, 0, 10.0f, 0};
cvar_t sv_idealpitchscale = {"sv_idealpitchscale", "0.8", 0, 0, 0.8f, 0};
cvar_t sv_aim = {"sv_aim", "0.93", 0, 0, 0.93f, 0};

extern char localmodels[MAX_MODELS][5];
extern int fatbytes;
extern byte fatpvs[MAX_MAP_LEAFS / 8];

static client_t clients[2];
static edict_t entities[4];
static qsocket_t socket_value;
static model_t world_model;
static mleaf_t world_leaf;
static byte pvs_bytes[8];
static int register_count;
static int execute_count;
static int new_connection_pending;
static int send_result;
static byte sent_bytes[8192];
static int sent_size;
static int drop_count;
static int command_count;

void SV_Init(void);
void SV_StartParticle(vec3_t origin, vec3_t direction, int color, int count);
void SV_StartSound(
    edict_t *entity, int channel, char *sample, int volume,
    float attenuation);
void SV_SendServerinfo(client_t *client);
void SV_ConnectClient(int client_number);
void SV_CheckForNewClients(void);
void SV_ClearDatagram(void);
void SV_AddToFatPVS(vec3_t origin, mnode_t *node);
byte *SV_FatPVS(vec3_t origin);
void SV_WriteEntitiesToClient(edict_t *client_entity, sizebuf_t *message);
void SV_CleanupEnts(void);
void SV_WriteClientdataToMessage(edict_t *entity, sizebuf_t *message);
qboolean SV_SendClientDatagram(client_t *client);
void SV_UpdateToReliableMessages(void);
void SV_SendNop(client_t *client);
void SV_SendClientMessages(void);
int SV_ModelIndex(char *name);
void SV_CreateBaseline(void);
void SV_SendReconnect(void);
void SV_SaveSpawnparms(void);

void Cvar_RegisterVariable(cvar_t *variable)
{
    (void)variable;
    ++register_count;
}

int mq_strcmp(const char *left, const char *right)
{
    while (*left && *left == *right) {
        ++left;
        ++right;
    }
    return (unsigned char)*left - (unsigned char)*right;
}

void Cvar_Set(char *name, char *value) { (void)name; (void)value; }
void Cvar_SetValue(char *name, float value) { (void)name; (void)value; }
void Sys_Error(char *format, ...) { (void)format; }
void Con_Printf(char *format, ...) { (void)format; }
void Con_DPrintf(char *format, ...) { (void)format; }

void SZ_Clear(sizebuf_t *buffer)
{
    buffer->cursize = 0;
    buffer->overflowed = false;
}

void SZ_Write(sizebuf_t *buffer, void *data, int length)
{
    if (length <= 0)
        return;
    if (buffer->cursize + length > buffer->maxsize) {
        if (buffer->allowoverflow) {
            buffer->overflowed = true;
            buffer->cursize = 0;
        } else {
            return;
        }
    }
    memcpy(buffer->data + buffer->cursize, data, (unsigned int)length);
    buffer->cursize += length;
}

void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    byte data = (byte)value;
    SZ_Write(buffer, &data, 1);
}

void MSG_WriteChar(sizebuf_t *buffer, int value)
{
    signed char data = (signed char)value;
    SZ_Write(buffer, &data, 1);
}

void MSG_WriteShort(sizebuf_t *buffer, int value)
{
    byte data[2];
    data[0] = (byte)value;
    data[1] = (byte)(value >> 8);
    SZ_Write(buffer, data, 2);
}

void MSG_WriteLong(sizebuf_t *buffer, int value)
{
    byte data[4];
    data[0] = (byte)value;
    data[1] = (byte)(value >> 8);
    data[2] = (byte)(value >> 16);
    data[3] = (byte)(value >> 24);
    SZ_Write(buffer, data, 4);
}

void MSG_WriteFloat(sizebuf_t *buffer, float value)
{
    union { float value; int bits; } data;
    data.value = value;
    MSG_WriteLong(buffer, data.bits);
}

void MSG_WriteCoord(sizebuf_t *buffer, float value)
{
    MSG_WriteShort(buffer, (int)(value * 8.0f));
}

void MSG_WriteAngle(sizebuf_t *buffer, float value)
{
    MSG_WriteByte(buffer, ((int)(value * 256.0f / 360.0f)) & 255);
}

void MSG_WriteString(sizebuf_t *buffer, char *value)
{
    do {
        MSG_WriteByte(buffer, *value);
    } while (*value++);
}

void PR_ExecuteProgram(int function_index)
{
    int index;
    ++execute_count;
    if (function_index == pr_global_struct->SetNewParms ||
        function_index == pr_global_struct->SetChangeParms) {
        for (index = 0; index < NUM_SPAWN_PARMS; ++index)
            (&pr_global_struct->parm1)[index] = (float)(index + 1);
    }
}

qsocket_t *NET_CheckNewConnections(void)
{
    if (!new_connection_pending)
        return NULL;
    new_connection_pending = 0;
    return &socket_value;
}

static void capture_message(sizebuf_t *message)
{
    sent_size = message->cursize;
    if (sent_size > (int)sizeof(sent_bytes))
        sent_size = sizeof(sent_bytes);
    if (sent_size > 0)
        memcpy(sent_bytes, message->data, (unsigned int)sent_size);
}

int NET_SendUnreliableMessage(qsocket_t *socket, sizebuf_t *message)
{
    (void)socket;
    capture_message(message);
    return send_result;
}

int NET_SendMessage(qsocket_t *socket, sizebuf_t *message)
{
    (void)socket;
    capture_message(message);
    return send_result;
}

qboolean NET_CanSendMessage(qsocket_t *socket)
{
    (void)socket;
    return true;
}

int NET_SendToAll(sizebuf_t *message, double blocktime)
{
    (void)blocktime;
    capture_message(message);
    return 0;
}

byte *Mod_LeafPVS(mleaf_t *leaf, model_t *model)
{
    (void)leaf;
    (void)model;
    return pvs_bytes;
}

void SV_SetIdealPitch(void) {}
eval_t *GetEdictFieldValue(edict_t *entity, char *field_name)
{
    (void)entity;
    (void)field_name;
    return NULL;
}

void SV_DropClient(qboolean crash)
{
    (void)crash;
    ++drop_count;
    if (host_client)
        host_client->active = false;
}

void Cmd_ExecuteString(char *text, int source)
{
    (void)text;
    (void)source;
    ++command_count;
}

void SV_ClearWorld(void) {}
void SV_Physics(void) {}
void ED_LoadFromFile(char *data) { (void)data; }
void PR_LoadProgs(void) {}
void Host_ClearMemory(void) {}
void *Hunk_AllocName(int size, char *name)
{
    (void)size;
    (void)name;
    return entities;
}
model_t *Mod_ForName(char *name, qboolean crash)
{
    (void)name;
    (void)crash;
    return &world_model;
}

static void setup_buffer(sizebuf_t *buffer, byte *data, int capacity)
{
    buffer->allowoverflow = false;
    buffer->overflowed = false;
    buffer->data = data;
    buffer->maxsize = capacity;
    buffer->cursize = 0;
}

static void reset_all(void)
{
    int index;
    memset(&sv, 0, sizeof(sv));
    memset(&svs, 0, sizeof(svs));
    memset(clients, 0, sizeof(clients));
    memset(entities, 0, sizeof(entities));
    memset(&socket_value, 0, sizeof(socket_value));
    memset(&world_model, 0, sizeof(world_model));
    memset(&world_leaf, 0, sizeof(world_leaf));
    memset(&globals, 0, sizeof(globals));
    memset(pr_strings, 0, sizeof(pr_strings));
    memset(pvs_bytes, 0, sizeof(pvs_bytes));
    memset(sent_bytes, 0, sizeof(sent_bytes));
    register_count = 0;
    execute_count = 0;
    new_connection_pending = 0;
    send_result = 0;
    sent_size = 0;
    drop_count = 0;
    command_count = 0;
    net_activeconnections = 0;
    realtime = 0.0;
    standard_quake = 1;
    cls.state = 0;
    coop.value = 0.0f;
    deathmatch.value = 0.0f;
    strcpy(socket_value.address, "oracle");

    svs.maxclients = 1;
    svs.clients = clients;
    sv.edicts = entities;
    sv.num_edicts = 2;
    sv.time = 3.5f;
    setup_buffer(&sv.datagram, sv.datagram_buf, sizeof(sv.datagram_buf));
    setup_buffer(
        &sv.reliable_datagram, sv.reliable_datagram_buf,
        sizeof(sv.reliable_datagram_buf));
    setup_buffer(&sv.signon, sv.signon_buf, sizeof(sv.signon_buf));
    for (index = 0; index < 2; ++index) {
        clients[index].edict = &entities[index + 1];
        clients[index].netconnection = &socket_value;
        setup_buffer(
            &clients[index].message, clients[index].msgbuf,
            sizeof(clients[index].msgbuf));
        clients[index].message.allowoverflow = true;
    }
    world_leaf.contents = -1;
    world_model.numleafs = 1;
    world_model.nodes = (mnode_t *)&world_leaf;
    sv.worldmodel = &world_model;
    pvs_bytes[0] = 5;
    pvs_bytes[1] = 10;
}

static char *emit(
    char *output, const char *function_name, const char *case_name,
    int result, int size, int b0, int b1, int b2, float value, int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"size\":%d,\"b0\":%d,\"b1\":%d,\"b2\":%d,"
        "\"value\":%.9g,\"count\":%d}\n",
        function_name, case_name, result, size, b0, b1, b2, value, count);
    return output;
}

static int byte_at(sizebuf_t *buffer, int index)
{
    if (index < 0 || index >= buffer->cursize)
        return 0;
    return buffer->data[index];
}

__declspec(dllexport) int __cdecl sv_main_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    byte local_buffer[1024];
    sizebuf_t message;
    vec3_t origin;
    vec3_t direction;
    int result;
    (void)capacity;

    reset_all();
    SV_Init();
    cursor = emit(
        cursor, "SV_Init", "local_models",
        strcmp(localmodels[5], "*5") == 0, MAX_MODELS,
        0, 0, 0, 0.0f, register_count);

    reset_all();
    origin[0] = 1.0f; origin[1] = 2.0f; origin[2] = 3.0f;
    direction[0] = 20.0f; direction[1] = -20.0f; direction[2] = 0.5f;
    SV_StartParticle(origin, direction, 17, 9);
    cursor = emit(
        cursor, "SV_StartParticle", "clamped_direction", 1,
        sv.datagram.cursize, byte_at(&sv.datagram, 0),
        byte_at(&sv.datagram, 7), byte_at(&sv.datagram, 8),
        (float)byte_at(&sv.datagram, 9),
        byte_at(&sv.datagram, sv.datagram.cursize - 1));

    reset_all();
    strcpy(pr_strings + 100, "misc/test.wav");
    sv.sound_precache[1] = pr_strings + 100;
    entities[1].v.origin[0] = 10.0f;
    entities[1].v.mins[0] = -2.0f;
    entities[1].v.maxs[0] = 2.0f;
    SV_StartSound(&entities[1], 2, pr_strings + 100, 200, 0.5f);
    cursor = emit(
        cursor, "SV_StartSound", "masked", 1, sv.datagram.cursize,
        byte_at(&sv.datagram, 0), byte_at(&sv.datagram, 1),
        byte_at(&sv.datagram, 2), (float)byte_at(&sv.datagram, 4),
        byte_at(&sv.datagram, 6));

    reset_all();
    strcpy(pr_strings + 100, "Oracle");
    entities[0].v.message = 100;
    entities[0].v.sounds = 3.0f;
    sv.model_precache[1] = NULL;
    sv.sound_precache[1] = NULL;
    SV_SendServerinfo(&clients[0]);
    cursor = emit(
        cursor, "SV_SendServerinfo", "signon", clients[0].sendsignon,
        0, byte_at(&clients[0].message, 0),
        byte_at(&clients[0].message, clients[0].message.cursize - 1),
        clients[0].spawned, 0.0f, 0);

    reset_all();
    strcpy(pr_strings + 100, "Oracle");
    entities[0].v.message = 100;
    clients[0].netconnection = &socket_value;
    pr_global_struct->SetNewParms = 11;
    SV_ConnectClient(0);
    cursor = emit(
        cursor, "SV_ConnectClient", "fresh", clients[0].active,
        NUM_FOR_EDICT(clients[0].edict), clients[0].sendsignon,
        byte_at(&clients[0].message, 0), clients[0].spawned,
        0.0f, execute_count);

    reset_all();
    strcpy(pr_strings + 100, "Oracle");
    entities[0].v.message = 100;
    pr_global_struct->SetNewParms = 11;
    new_connection_pending = 1;
    SV_CheckForNewClients();
    cursor = emit(
        cursor, "SV_CheckForNewClients", "one_pending",
        clients[0].active, net_activeconnections,
        clients[0].sendsignon, byte_at(&clients[0].message, 0),
        0, 0.0f, execute_count);

    reset_all();
    MSG_WriteByte(&sv.datagram, 99);
    SV_ClearDatagram();
    cursor = emit(
        cursor, "SV_ClearDatagram", "nonempty", sv.datagram.cursize == 0,
        sv.datagram.cursize, 0, 0, 0, 0.0f, 0);

    reset_all();
    fatbytes = 1;
    fatpvs[0] = 0;
    origin[0] = origin[1] = origin[2] = 0.0f;
    SV_AddToFatPVS(origin, (mnode_t *)&world_leaf);
    cursor = emit(
        cursor, "SV_AddToFatPVS", "leaf_or", 1,
        fatbytes, fatpvs[0], 0, 0, 0.0f, 0);

    reset_all();
    SV_FatPVS(origin);
    cursor = emit(
        cursor, "SV_FatPVS", "leaf_root", 1,
        fatbytes, 0, 0, 0, 0.0f, 0);

    reset_all();
    entities[1].v.origin[0] = 1.0f;
    entities[1].v.movetype = MOVETYPE_STEP;
    setup_buffer(&message, local_buffer, sizeof(local_buffer));
    SV_WriteEntitiesToClient(&entities[1], &message);
    cursor = emit(
        cursor, "SV_WriteEntitiesToClient", "client_delta", 1,
        message.cursize, byte_at(&message, 0), byte_at(&message, 1),
        byte_at(&message, 2), (float)byte_at(&message, 3), 1);

    reset_all();
    entities[1].v.effects = EF_MUZZLEFLASH | 8;
    SV_CleanupEnts();
    cursor = emit(
        cursor, "SV_CleanupEnts", "muzzle", 1, 0,
        0, 0, 0, entities[1].v.effects, 1);

    reset_all();
    strcpy(pr_strings + 100, "weapon.mdl");
    sv.model_precache[0] = pr_strings;
    sv.model_precache[1] = pr_strings + 100;
    entities[1].v.view_ofs[2] = 30.0f;
    entities[1].v.flags = FL_ONGROUND;
    entities[1].v.waterlevel = 2.0f;
    entities[1].v.punchangle[0] = 1.0f;
    entities[1].v.punchangle[2] = -2.0f;
    entities[1].v.velocity[0] = 16.0f;
    entities[1].v.velocity[1] = -32.0f;
    entities[1].v.weaponframe = 6.0f;
    entities[1].v.armorvalue = 75.0f;
    entities[1].v.weaponmodel = 100;
    entities[1].v.health = 99.0f;
    entities[1].v.currentammo = 10.0f;
    entities[1].v.ammo_shells = 11.0f;
    entities[1].v.ammo_nails = 12.0f;
    entities[1].v.ammo_rockets = 13.0f;
    entities[1].v.ammo_cells = 14.0f;
    entities[1].v.items = 5.0f;
    entities[1].v.weapon = 4.0f;
    pr_global_struct->serverflags = 3.0f;
    setup_buffer(&message, local_buffer, sizeof(local_buffer));
    SV_WriteClientdataToMessage(&entities[1], &message);
    cursor = emit(
        cursor, "SV_WriteClientdataToMessage", "protocol15", 1,
        message.cursize, byte_at(&message, 0), byte_at(&message, 1),
        byte_at(&message, 2), 0.0f,
        byte_at(&message, message.cursize - 1));

    reset_all();
    clients[0].active = true;
    clients[0].spawned = true;
    entities[1].v.view_ofs[2] = DEFAULT_VIEWHEIGHT;
    SV_SendClientDatagram(&clients[0]);
    cursor = emit(
        cursor, "SV_SendClientDatagram", "success", sent_size > 0,
        0, sent_size > 0 ? sent_bytes[0] : 0, 0, 0, 0.0f, drop_count);

    reset_all();
    clients[0].active = true;
    clients[0].old_frags = 0;
    entities[1].v.frags = 7.0f;
    MSG_WriteByte(&sv.reliable_datagram, 99);
    SV_UpdateToReliableMessages();
    cursor = emit(
        cursor, "SV_UpdateToReliableMessages", "frags_broadcast",
        clients[0].old_frags, clients[0].message.cursize,
        byte_at(&clients[0].message, 0), byte_at(&clients[0].message, 1),
        byte_at(&clients[0].message, 2),
        (float)byte_at(&clients[0].message, clients[0].message.cursize - 1),
        sv.reliable_datagram.cursize);

    reset_all();
    realtime = 9.0;
    SV_SendNop(&clients[0]);
    cursor = emit(
        cursor, "SV_SendNop", "keepalive", sent_size == 1,
        sent_size, sent_bytes[0], 0, 0,
        (float)clients[0].last_message, drop_count);

    reset_all();
    entities[1].v.effects = EF_MUZZLEFLASH | 8;
    SV_SendClientMessages();
    cursor = emit(
        cursor, "SV_SendClientMessages", "inactive_cleanup", 1,
        0, 0, 0, 0, entities[1].v.effects, 0);

    reset_all();
    sv.model_precache[0] = pr_strings;
    strcpy(pr_strings + 100, "maps/test.bsp");
    sv.model_precache[1] = pr_strings + 100;
    result = SV_ModelIndex(pr_strings + 100);
    cursor = emit(
        cursor, "SV_ModelIndex", "precache_hit", result,
        0, 0, 0, 0, 0.0f, 0);

    reset_all();
    sv.model_precache[0] = pr_strings;
    strcpy(pr_strings + 100, "maps/test.bsp");
    strcpy(pr_strings + 200, "progs/player.mdl");
    sv.model_precache[1] = pr_strings + 100;
    sv.model_precache[2] = pr_strings + 200;
    entities[0].v.model = 100;
    entities[0].v.modelindex = 1.0f;
    entities[1].v.model = 200;
    SV_CreateBaseline();
    cursor = emit(
        cursor, "SV_CreateBaseline", "world_player", 1,
        sv.signon.cursize, entities[0].baseline.modelindex,
        entities[1].baseline.modelindex, entities[1].baseline.colormap,
        0.0f, 2);

    reset_all();
    SV_SendReconnect();
    cursor = emit(
        cursor, "SV_SendReconnect", "local_command", 1,
        0, sent_size > 0 ? sent_bytes[0] : 0,
        sent_size > 0 ? sent_bytes[sent_size - 1] : 0,
        command_count, 0.0f, 0);

    reset_all();
    svs.serverflags = 5;
    pr_global_struct->serverflags = 5.0f;
    SV_SaveSpawnparms();
    cursor = emit(
        cursor, "SV_SaveSpawnparms", "no_active", 1,
        svs.serverflags, 0, 0, 0, 0.0f, execute_count);

    *cursor = 0;
    return (int)(cursor - output);
}
