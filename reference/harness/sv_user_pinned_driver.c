/*
 * Driver/stubs for functions compiled directly from the pinned
 * WinQuake/sv_user.c.  The original function bodies live in the detached
 * worktree object; this file only supplies deterministic engine services and
 * serializes their observable state.
 */
#include "sv_user_oracle_stubs.h"

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);

int _fltused = 0;

server_t sv;
static client_t client_states[2];
server_static_t svs = {client_states, 2};
client_t *host_client;
double host_frametime;
vec3_t vec3_origin = {0.0f, 0.0f, 0.0f};
int msg_badread;
int key_dest = key_game;
cvar_t sv_friction = {"sv_friction", "4", 0, 1, 4.0f, 0};
cvar_t sv_stopspeed = {"sv_stopspeed", "100", 0, 0, 100.0f, 0};

extern edict_t *sv_player;
extern vec3_t wishdir;
extern float wishspeed;
extern float *origin;
extern float *velocity;
extern usercmd_t cmd;
extern cvar_t sv_edgefriction;
extern cvar_t sv_idealpitchscale;
extern cvar_t sv_maxspeed;
extern cvar_t sv_accelerate;

void SV_SetIdealPitch(void);
void SV_UserFriction(void);
void SV_Accelerate(void);
void SV_AirAccelerate(vec3_t wishveloc);
void DropPunchAngle(void);
void SV_WaterMove(void);
void SV_WaterJump(void);
void SV_AirMove(void);
void SV_ClientThink(void);
void SV_ReadClientMove(usercmd_t *move);
qboolean SV_ReadClientMessage(void);
void SV_RunClients(void);

enum {
    TRACE_FLOOR = 0,
    TRACE_EDGE = 1,
    TRACE_IDEAL_PITCH = 2
};

static int trace_mode;
static unsigned char message_data[512];
static int message_length;
static int message_position;
static int network_mode;
static int network_calls;
static int inserted_count;
static int executed_count;
static int dropped_count;
static char inserted_text[128];
static char executed_text[128];

float VectorNormalize(vec3_t value)
{
    float length = (float)sqrt(
        value[0] * value[0] + value[1] * value[1] +
        value[2] * value[2]);
    if (length != 0.0f) {
        float inverse = 1.0f / length;
        value[0] *= inverse;
        value[1] *= inverse;
        value[2] *= inverse;
    }
    return length;
}

float Length(vec3_t value)
{
    return (float)sqrt(
        value[0] * value[0] + value[1] * value[1] +
        value[2] * value[2]);
}

void AngleVectors(
    vec3_t angles, vec3_t forward_vector, vec3_t right_vector,
    vec3_t up_vector)
{
    float yaw = angles[YAW] * (float)(M_PI * 2.0 / 360.0);
    float pitch = angles[PITCH] * (float)(M_PI * 2.0 / 360.0);
    float roll = angles[ROLL] * (float)(M_PI * 2.0 / 360.0);
    float sy = (float)sin(yaw);
    float cy = (float)cos(yaw);
    float sp = (float)sin(pitch);
    float cp = (float)cos(pitch);
    float sr = (float)sin(roll);
    float cr = (float)cos(roll);
    forward_vector[0] = cp * cy;
    forward_vector[1] = cp * sy;
    forward_vector[2] = -sp;
    right_vector[0] = -sr * sp * cy + -cr * -sy;
    right_vector[1] = -sr * sp * sy + -cr * cy;
    right_vector[2] = -sr * cp;
    up_vector[0] = cr * sp * cy + -sr * -sy;
    up_vector[1] = cr * sp * sy + -sr * cy;
    up_vector[2] = cr * cp;
}

trace_t SV_Move(
    vec3_t start, vec3_t mins, vec3_t maxs, vec3_t end,
    int move_type, edict_t *passedict)
{
    trace_t trace;
    (void)mins;
    (void)maxs;
    (void)move_type;
    (void)passedict;
    memset(&trace, 0, sizeof(trace));
    trace.fraction = trace_mode == TRACE_EDGE ? 1.0f : 0.5f;
    if (trace_mode == TRACE_IDEAL_PITCH) {
        int sample = (int)(start[0] / 12.0f) - 3;
        float height = 3.6f + 1.2f * (float)sample;
        trace.fraction = (start[2] - height) / (start[2] - end[2]);
    }
    trace.endpos[0] = start[0] +
        trace.fraction * (end[0] - start[0]);
    trace.endpos[1] = start[1] +
        trace.fraction * (end[1] - start[1]);
    trace.endpos[2] = start[2] +
        trace.fraction * (end[2] - start[2]);
    return trace;
}

float V_CalcRoll(vec3_t angles_value, vec3_t velocity_value)
{
    (void)angles_value;
    (void)velocity_value;
    return 0.0f;
}

static int read_unsigned_byte(void)
{
    if (message_position >= message_length)
    {
        msg_badread = true;
        return -1;
    }
    return message_data[message_position++];
}

int MSG_ReadByte(void)
{
    return read_unsigned_byte();
}

int MSG_ReadChar(void)
{
    int value = read_unsigned_byte();
    if (value < 0)
        return -1;
    if (value >= 128)
        value -= 256;
    return value;
}

int MSG_ReadShort(void)
{
    int low = read_unsigned_byte();
    int high = read_unsigned_byte();
    int value;
    if (low < 0 || high < 0)
        return -1;
    value = low | (high << 8);
    if (value >= 32768)
        value -= 65536;
    return value;
}

float MSG_ReadFloat(void)
{
    union
    {
        unsigned char bytes[4];
        float value;
    } bits;
    int index;
    for (index = 0; index < 4; index++)
    {
        int value = read_unsigned_byte();
        bits.bytes[index] = value < 0 ? 0 : (unsigned char)value;
    }
    return bits.value;
}

float MSG_ReadAngle(void)
{
    return MSG_ReadChar() * (360.0f / 256.0f);
}

char *MSG_ReadString(void)
{
    static char text[2048];
    int count = 0;
    int value;
    do
    {
        value = MSG_ReadChar();
        if (value == -1 || value == 0)
            break;
        text[count++] = (char)value;
    } while (count < (int)sizeof(text) - 1);
    text[count] = 0;
    return text;
}

void MSG_BeginReading(void)
{
    message_position = 0;
    msg_badread = false;
}

int NET_GetMessage(void *connection)
{
    (void)connection;
    if (network_mode < 0)
        return -1;
    if (network_mode == 1 && network_calls++ == 0)
        return 1;
    return 0;
}

static int lower_ascii(int value)
{
    if (value >= 'A' && value <= 'Z')
        return value + ('a' - 'A');
    return value;
}

int Q_strncasecmp(char *left, char *right_text, int count)
{
    int index;
    for (index = 0; index < count; index++)
    {
        int a = lower_ascii((unsigned char)left[index]);
        int b = lower_ascii((unsigned char)right_text[index]);
        if (a != b)
            return -1;
        if (a == 0)
            return 0;
    }
    return 0;
}

static void copy_text(char *destination, const char *source, int capacity)
{
    int index = 0;
    while (index + 1 < capacity && source[index])
    {
        destination[index] = source[index];
        index++;
    }
    destination[index] = 0;
}

void Cbuf_InsertText(char *text)
{
    inserted_count++;
    copy_text(inserted_text, text, sizeof(inserted_text));
}

void Cmd_ExecuteString(char *text, int source)
{
    (void)source;
    executed_count++;
    copy_text(executed_text, text, sizeof(executed_text));
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
}

void Sys_Printf(char *format, ...)
{
    (void)format;
}

void SV_DropClient(qboolean crash)
{
    (void)crash;
    dropped_count++;
    if (host_client != 0)
        host_client->active = false;
}

static void write_byte(int *position, int value)
{
    message_data[(*position)++] = (unsigned char)value;
}

static void write_short(int *position, int value)
{
    write_byte(position, value);
    write_byte(position, value >> 8);
}

static void write_float(int *position, float value)
{
    union
    {
        unsigned char bytes[4];
        float value;
    } bits;
    int index;
    bits.value = value;
    for (index = 0; index < 4; index++)
        write_byte(position, bits.bytes[index]);
}

static void write_text(int *position, const char *text)
{
    while (*text)
        write_byte(position, *text++);
    write_byte(position, 0);
}

static void write_move_payload(int *position)
{
    write_float(position, 2.5f);
    write_byte(position, 64);
    write_byte(position, 128);
    write_byte(position, 0);
    write_short(position, 100);
    write_short(position, -50);
    write_short(position, 25);
    write_byte(position, 3);
    write_byte(position, 7);
}

static void reset_clients(edict_t *player)
{
    memset(client_states, 0, sizeof(client_states));
    host_client = &client_states[0];
    client_states[0].edict = player;
    client_states[1].edict = player;
    copy_text(client_states[0].name, "client0", sizeof(client_states[0].name));
    copy_text(client_states[1].name, "client1", sizeof(client_states[1].name));
    svs.clients = client_states;
    svs.maxclients = 2;
    network_mode = 0;
    network_calls = 0;
    inserted_count = 0;
    executed_count = 0;
    dropped_count = 0;
    inserted_text[0] = 0;
    executed_text[0] = 0;
}

static char *append_vec(
    char *output, const char *function_name, const char *case_name,
    vec3_t value)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\","
        "\"x\":%.9g,\"y\":%.9g,\"z\":%.9g}\n",
        function_name, case_name, value[0], value[1], value[2]);
    return output;
}

__declspec(dllexport) int __cdecl sv_user_oracle_jsonl(
    char *output, int capacity)
{
    char *cursor = output;
    edict_t player;
    vec3_t value;
    vec3_t air_wish;
    int flags;
    float teleport_time;
    (void)capacity;
    memset(&player, 0, sizeof(player));
    sv_player = &player;
    origin = player.v.origin;
    velocity = player.v.velocity;
    sv_friction.value = 4.0f;
    sv_stopspeed.value = 100.0f;
    sv_edgefriction.value = 2.0f;
    sv_idealpitchscale.value = 0.8f;
    sv_maxspeed.value = 320.0f;
    sv_accelerate.value = 10.0f;

    host_frametime = 0.1;
    player.v.mins[2] = -24.0f;
    value[0] = player.v.velocity[0] = 100.0f;
    value[1] = player.v.velocity[1] = 0.0f;
    value[2] = player.v.velocity[2] = 10.0f;
    trace_mode = TRACE_FLOOR;
    SV_UserFriction();
    cursor = append_vec(cursor, "SV_UserFriction", "floor", player.v.velocity);
    player.v.velocity[0] = 100.0f;
    player.v.velocity[1] = 0.0f;
    player.v.velocity[2] = 10.0f;
    trace_mode = TRACE_EDGE;
    SV_UserFriction();
    cursor = append_vec(cursor, "SV_UserFriction", "edge", player.v.velocity);

    player.v.velocity[0] = 5.0f;
    player.v.velocity[1] = -2.0f;
    player.v.velocity[2] = 0.0f;
    wishdir[0] = 1.0f; wishdir[1] = 0.0f; wishdir[2] = 0.0f;
    wishspeed = 100.0f;
    SV_Accelerate();
    cursor = append_vec(
        cursor, "SV_Accelerate", "ground", player.v.velocity);

    player.v.velocity[0] = 0.0f;
    player.v.velocity[1] = 0.0f;
    player.v.velocity[2] = 0.0f;
    air_wish[0] = 100.0f; air_wish[1] = 0.0f; air_wish[2] = 0.0f;
    SV_AirAccelerate(air_wish);
    cursor = append_vec(
        cursor, "SV_AirAccelerate", "cap30", player.v.velocity);

    host_frametime = 0.05;
    player.v.punchangle[0] = 3.0f;
    player.v.punchangle[1] = 4.0f;
    player.v.punchangle[2] = 0.0f;
    DropPunchAngle();
    cursor = append_vec(
        cursor, "DropPunchAngle", "decay", player.v.punchangle);

    host_frametime = 0.1;
    memset(player.v.v_angle, 0, sizeof(player.v.v_angle));
    player.v.velocity[0] = 100.0f;
    player.v.velocity[1] = 0.0f;
    player.v.velocity[2] = 0.0f;
    cmd.forwardmove = 100.0f;
    cmd.sidemove = 0.0f;
    cmd.upmove = 0.0f;
    SV_WaterMove();
    cursor = append_vec(
        cursor, "SV_WaterMove", "forward", player.v.velocity);
    player.v.velocity[0] = 0.0f;
    player.v.velocity[1] = 0.0f;
    player.v.velocity[2] = 0.0f;
    cmd.forwardmove = cmd.sidemove = cmd.upmove = 0.0f;
    SV_WaterMove();
    cursor = append_vec(
        cursor, "SV_WaterMove", "idle_sink", player.v.velocity);

    player.v.velocity[0] = 0.0f;
    player.v.velocity[1] = 0.0f;
    player.v.velocity[2] = 5.0f;
    player.v.flags = (float)FL_WATERJUMP;
    player.v.teleport_time = 10.0f;
    player.v.waterlevel = 2.0f;
    player.v.movedir[0] = 120.0f;
    player.v.movedir[1] = -30.0f;
    player.v.movedir[2] = 0.0f;
    sv.time = 5.0f;
    SV_WaterJump();
    flags = (int)player.v.flags;
    teleport_time = player.v.teleport_time;
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_WaterJump\",\"case\":\"active\","
        "\"x\":%.9g,\"y\":%.9g,\"z\":%.9g,"
        "\"flags\":%d,\"teleport\":%.9g}\n",
        player.v.velocity[0], player.v.velocity[1], player.v.velocity[2],
        flags, teleport_time);
    sv.time = 11.0f;
    SV_WaterJump();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_WaterJump\",\"case\":\"expired\","
        "\"x\":%.9g,\"y\":%.9g,\"z\":%.9g,"
        "\"flags\":%d,\"teleport\":%.9g}\n",
        player.v.velocity[0], player.v.velocity[1], player.v.velocity[2],
        (int)player.v.flags, player.v.teleport_time);

    memset(player.v.origin, 0, sizeof(player.v.origin));
    memset(player.v.angles, 0, sizeof(player.v.angles));
    player.v.origin[2] = 0.0f;
    player.v.view_ofs[2] = 22.0f;
    player.v.flags = (float)FL_ONGROUND;
    trace_mode = TRACE_IDEAL_PITCH;
    SV_SetIdealPitch();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_SetIdealPitch\","
        "\"case\":\"uniform_slope\",\"pitch\":%.9g}\n",
        player.v.idealpitch);

    memset(&player, 0, sizeof(player));
    sv_player = &player;
    origin = player.v.origin;
    velocity = player.v.velocity;
    player.v.movetype = MOVETYPE_NOCLIP;
    cmd.forwardmove = 100.0f;
    cmd.sidemove = 25.0f;
    cmd.upmove = 30.0f;
    sv.time = 5.0f;
    SV_AirMove();
    cursor = append_vec(cursor, "SV_AirMove", "noclip", player.v.velocity);

    reset_clients(&player);
    memset(&player, 0, sizeof(player));
    sv_player = &player;
    host_client->edict = &player;
    host_client->cmd.forwardmove = 1.0f;
    player.v.movetype = MOVETYPE_WALK;
    player.v.health = 100.0f;
    player.v.flags = (float)FL_WATERJUMP;
    player.v.waterlevel = 2.0f;
    player.v.teleport_time = 10.0f;
    player.v.v_angle[0] = 30.0f;
    player.v.v_angle[1] = 40.0f;
    player.v.movedir[0] = 12.0f;
    player.v.movedir[1] = -4.0f;
    sv.time = 5.0f;
    host_frametime = 0.1;
    SV_ClientThink();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_ClientThink\",\"case\":\"waterjump-angles\","
        "\"angles\":[%.9g,%.9g,%.9g],\"velocity\":[%.9g,%.9g,%.9g],"
        "\"flags\":%d}\n",
        player.v.angles[0], player.v.angles[1], player.v.angles[2],
        player.v.velocity[0], player.v.velocity[1], player.v.velocity[2],
        (int)player.v.flags);

    reset_clients(&player);
    memset(&player, 0, sizeof(player));
    host_client->active = true;
    host_client->edict = &player;
    message_length = 0;
    write_move_payload(&message_length);
    MSG_BeginReading();
    sv.time = 5.0f;
    SV_ReadClientMove(&host_client->cmd);
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_ReadClientMove\",\"case\":\"protocol15\","
        "\"ping\":%.9g,\"pings\":%d,\"angles\":[%.9g,%.9g,%.9g],"
        "\"move\":[%.9g,%.9g,%.9g],\"buttons\":[%d,%d],\"impulse\":%d}\n",
        host_client->ping_times[0], host_client->num_pings,
        player.v.v_angle[0], player.v.v_angle[1], player.v.v_angle[2],
        host_client->cmd.forwardmove, host_client->cmd.sidemove,
        host_client->cmd.upmove, (int)player.v.button0,
        (int)player.v.button2, (int)player.v.impulse);

    reset_clients(&player);
    memset(&player, 0, sizeof(player));
    host_client->active = true;
    host_client->privileged = true;
    host_client->edict = &player;
    message_length = 0;
    write_byte(&message_length, clc_stringcmd);
    write_text(&message_length, "echo fixture");
    write_byte(&message_length, clc_move);
    write_move_payload(&message_length);
    network_mode = 1;
    network_calls = 0;
    sv.time = 5.0f;
    flags = SV_ReadClientMessage();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_ReadClientMessage\",\"case\":\"string-and-move\","
        "\"result\":%d,\"inserted\":%d,\"text\":\"%s\","
        "\"forward\":%.9g,\"pings\":%d}\n",
        flags, inserted_count, inserted_text, host_client->cmd.forwardmove,
        host_client->num_pings);

    reset_clients(&player);
    memset(&player, 0, sizeof(player));
    client_states[0].active = true;
    client_states[0].spawned = false;
    client_states[0].cmd.forwardmove = 55.0f;
    client_states[1].active = true;
    client_states[1].spawned = true;
    client_states[1].cmd.forwardmove = 77.0f;
    sv.paused = true;
    key_dest = key_game;
    network_mode = 0;
    SV_RunClients();
    cursor += sprintf(
        cursor,
        "{\"function\":\"SV_RunClients\",\"case\":\"pause-spawn-gate\","
        "\"processed\":2,\"first_forward\":%.9g,\"second_forward\":%.9g,"
        "\"drops\":%d,\"active\":[%d,%d]}\n",
        client_states[0].cmd.forwardmove, client_states[1].cmd.forwardmove,
        dropped_count, client_states[0].active, client_states[1].active);

    *cursor = 0;
    return (int)(cursor - output);
}
