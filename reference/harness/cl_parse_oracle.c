/*
 * Stub environment and deterministic Protocol-15 diagnostics for the pinned
 * WinQuake/cl_parse.c. tools/cl_parse_differential.py inserts the source at
 * the marker; no original function body is copied here.
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
typedef struct model_s { int synctype; } model_t;
typedef struct sfx_s { int marker; } sfx_t;
typedef struct baseline_s {
    int modelindex;
    int frame;
    int colormap;
    int skin;
    vec3_t origin;
    vec3_t angles;
    int effects;
} baseline_t;
typedef struct entity_s {
    baseline_t baseline;
    void *colormap;
    model_t *model;
    float msgtime;
    float syncbase;
    int frame;
    int skinnum;
    int effects;
    vec3_t msg_origins[2];
    vec3_t msg_angles[2];
    qboolean forcelink;
    vec3_t origin;
    vec3_t angles;
} entity_t;

#define VID_GRADES 64
#define TOP_RANGE 16
#define BOTTOM_RANGE 96
#define MAX_EDICTS 600
#define MAX_LIGHTSTYLES 64
#define MAX_MODELS 256
#define MAX_SOUNDS 256
#define MAX_CL_STATS 32
#define MAX_SCOREBOARD 16
#define MAX_SCOREBOARDNAME 32
#define MAX_STATIC_ENTITIES 128
#define MAX_QPATH 64
#define SIGNONS 4
#define PROTOCOL_VERSION 15
#define DEFAULT_VIEWHEIGHT 22
#define DEFAULT_SOUND_PACKET_VOLUME 255
#define DEFAULT_SOUND_PACKET_ATTENUATION 1.0
#define ST_RAND 1
#define NULL 0
#define true 1
#define false 0
#define GLQUAKE 1

#define STAT_HEALTH 0
#define STAT_WEAPON 2
#define STAT_AMMO 3
#define STAT_ARMOR 4
#define STAT_WEAPONFRAME 5
#define STAT_SHELLS 6
#define STAT_ACTIVEWEAPON 10
#define STAT_SECRETS 13
#define STAT_MONSTERS 14

#define U_MOREBITS (1<<0)
#define U_ORIGIN1 (1<<1)
#define U_ORIGIN2 (1<<2)
#define U_ORIGIN3 (1<<3)
#define U_ANGLE2 (1<<4)
#define U_NOLERP (1<<5)
#define U_FRAME (1<<6)
#define U_ANGLE1 (1<<8)
#define U_ANGLE3 (1<<9)
#define U_MODEL (1<<10)
#define U_COLORMAP (1<<11)
#define U_SKIN (1<<12)
#define U_EFFECTS (1<<13)
#define U_LONGENTITY (1<<14)

#define SU_VIEWHEIGHT (1<<0)
#define SU_IDEALPITCH (1<<1)
#define SU_PUNCH1 (1<<2)
#define SU_PUNCH2 (1<<3)
#define SU_PUNCH3 (1<<4)
#define SU_VELOCITY1 (1<<5)
#define SU_VELOCITY2 (1<<6)
#define SU_VELOCITY3 (1<<7)
#define SU_ITEMS (1<<9)
#define SU_ONGROUND (1<<10)
#define SU_INWATER (1<<11)
#define SU_WEAPONFRAME (1<<12)
#define SU_ARMOR (1<<13)
#define SU_WEAPON (1<<14)

#define SND_VOLUME (1<<0)
#define SND_ATTENUATION (1<<1)

#define svc_bad 0
#define svc_nop 1
#define svc_disconnect 2
#define svc_updatestat 3
#define svc_version 4
#define svc_setview 5
#define svc_sound 6
#define svc_time 7
#define svc_print 8
#define svc_stufftext 9
#define svc_setangle 10
#define svc_serverinfo 11
#define svc_lightstyle 12
#define svc_updatename 13
#define svc_updatefrags 14
#define svc_clientdata 15
#define svc_stopsound 16
#define svc_updatecolors 17
#define svc_particle 18
#define svc_damage 19
#define svc_spawnstatic 20
#define svc_spawnbaseline 22
#define svc_temp_entity 23
#define svc_setpause 24
#define svc_signonnum 25
#define svc_centerprint 26
#define svc_killedmonster 27
#define svc_foundsecret 28
#define svc_spawnstaticsound 29
#define svc_intermission 30
#define svc_finale 31
#define svc_cdtrack 32
#define svc_sellscreen 33
#define svc_cutscene 34
#define clc_nop 1
#define src_command 1

#define VectorCopy(a,b) do { (b)[0]=(a)[0]; (b)[1]=(a)[1]; (b)[2]=(a)[2]; } while (0)

typedef struct scoreboard_s {
    char name[MAX_SCOREBOARDNAME];
    float entertime;
    int frags;
    int colors;
    byte translations[VID_GRADES * 256];
} scoreboard_t;
typedef struct lightstyle_s {
    int length;
    char map[64];
} lightstyle_t;
typedef struct cvar_s { float value; } cvar_t;
typedef struct viddef_s {
    byte *colormap;
    qboolean recalc_refdef;
} viddef_t;
typedef struct server_s { qboolean active; } server_t;
typedef struct client_static_s {
    int signon;
    qboolean demoplayback;
    qboolean demorecording;
    int forcetrack;
    void *netcon;
    sizebuf_t message;
} client_static_t;
typedef struct client_state_s {
    int stats[MAX_CL_STATS];
    int items;
    float item_gettime[32];
    vec3_t viewangles;
    vec3_t mvelocity[2];
    vec3_t punchangle;
    float idealpitch;
    float viewheight;
    qboolean paused;
    qboolean onground;
    qboolean inwater;
    int intermission;
    int completed_time;
    double mtime[2];
    double time;
    model_t *model_precache[MAX_MODELS];
    sfx_t *sound_precache[MAX_SOUNDS];
    char levelname[40];
    int viewentity;
    int maxclients;
    int gametype;
    model_t *worldmodel;
    int num_entities;
    int num_statics;
    int cdtrack;
    int looptrack;
    scoreboard_t *scores;
} client_state_t;

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

client_static_t cls;
client_state_t cl;
entity_t cl_entities[MAX_EDICTS];
entity_t cl_static_entities[MAX_STATIC_ENTITIES];
lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES];
cvar_t cl_shownet;
viddef_t vid;
server_t sv;
sizebuf_t net_message;
int msg_readcount;
qboolean msg_badread;
qboolean noclip_anglehack;
qboolean standard_quake;

static byte mq_colormap[VID_GRADES * 256];
static byte mq_net_data[8192];
static byte mq_client_message_data[64];
static scoreboard_t mq_scores[MAX_SCOREBOARD];
static model_t mq_models[MAX_MODELS];
static sfx_t mq_sounds[MAX_SOUNDS];
static char mq_string[2048];
static int mq_error;
static int mq_endgame;
static int mq_signon_replies;
static int mq_newmap_calls;
static int mq_model_touches;
static int mq_sound_touches;
static int mq_efrag_calls;
static int mq_translate_calls;
static int mq_sbar_changes;
static int mq_keepalive_sends;
static byte mq_keepalive_opcode;
static float mq_sys_time;
static int mq_get_index;
static int mq_get_count;
static int mq_get_returns[8];
static int mq_get_lengths[8];
static byte mq_get_payloads[8][32];
static int mq_sound_ent;
static int mq_sound_channel;
static int mq_sound_index;
static float mq_sound_position[3];
static float mq_sound_volume;
static float mq_sound_attenuation;
static int mq_static_sound_index;
static int mq_static_sound_volume;
static int mq_static_sound_attenuation;
static float mq_static_sound_position[3];
static char mq_centerprint[128];
static char mq_stufftext[128];
static char mq_command[128];
static int mq_cd_track;
static int mq_cd_loop;

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

void *mq_memcpy(void *destination, const void *source, int length)
{
    byte *output = (byte *)destination;
    const byte *input = (const byte *)source;
    int index;
    for (index = 0; index < length; index++)
        output[index] = input[index];
    return destination;
}

void *mq_memset(void *destination, int value, int length)
{
    byte *output = (byte *)destination;
    int index;
    for (index = 0; index < length; index++)
        output[index] = (byte)value;
    return destination;
}

char *mq_strcpy(char *destination, const char *source)
{
    mq_copy_text(destination, source);
    return destination;
}

char *mq_strncpy(char *destination, const char *source, int length)
{
    int index = 0;
    while (index < length && source[index]) {
        destination[index] = source[index];
        index++;
    }
    while (index < length)
        destination[index++] = 0;
    return destination;
}

int mq_rand(void)
{
    return 0;
}

void Con_Printf(const char *format, ...) { (void)format; }
void Con_DPrintf(const char *format, ...) { (void)format; }
void Host_Error(const char *format, ...) { (void)format; mq_error = 1; }
void Sys_Error(const char *format, ...) { (void)format; mq_error = 1; }
void Host_EndGame(const char *format, ...) { (void)format; mq_endgame = 1; }

void MSG_BeginReading(void)
{
    msg_readcount = 0;
    msg_badread = false;
}

int MSG_ReadByte(void)
{
    if (msg_readcount + 1 > net_message.cursize) {
        msg_badread = true;
        return -1;
    }
    return net_message.data[msg_readcount++];
}

int MSG_ReadChar(void)
{
    int value = MSG_ReadByte();
    if (value < 0)
        return -1;
    return value > 127 ? value - 256 : value;
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

int MSG_ReadLong(void)
{
    unsigned int value;
    if (msg_readcount + 4 > net_message.cursize) {
        msg_badread = true;
        return -1;
    }
    value = (unsigned int)net_message.data[msg_readcount]
        | ((unsigned int)net_message.data[msg_readcount+1] << 8)
        | ((unsigned int)net_message.data[msg_readcount+2] << 16)
        | ((unsigned int)net_message.data[msg_readcount+3] << 24);
    msg_readcount += 4;
    return (int)value;
}

float MSG_ReadFloat(void)
{
    union { unsigned int i; float f; } value;
    value.i = (unsigned int)MSG_ReadLong();
    return value.f;
}

char *MSG_ReadString(void)
{
    int length = 0;
    int value;
    do {
        value = MSG_ReadChar();
        if (value == -1 || value == 0)
            break;
        if (length < (int)sizeof(mq_string) - 1)
            mq_string[length++] = (char)value;
    } while (1);
    mq_string[length] = 0;
    return mq_string;
}

float MSG_ReadCoord(void) { return MSG_ReadShort() * (1.0f / 8.0f); }
float MSG_ReadAngle(void) { return MSG_ReadChar() * (360.0f / 256.0f); }

void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize < buffer->maxsize)
        buffer->data[buffer->cursize++] = (byte)value;
}

void SZ_Clear(sizebuf_t *buffer) { buffer->cursize = 0; }

void CL_ClearState(void)
{
    mq_memset(&cl, 0, sizeof(cl));
    mq_memset(cl_entities, 0, sizeof(cl_entities));
    mq_memset(cl_static_entities, 0, sizeof(cl_static_entities));
}

void CL_SignonReply(void) { mq_signon_replies++; }
void Mod_TouchModel(char *name) { (void)name; mq_model_touches++; }
void S_TouchSound(char *name) { (void)name; mq_sound_touches++; }
model_t *Mod_ForName(char *name, qboolean crash)
{
    static int index = 1;
    (void)name;
    (void)crash;
    return &mq_models[index++ % MAX_MODELS];
}
sfx_t *S_PrecacheSound(char *name)
{
    static int index = 1;
    (void)name;
    return &mq_sounds[index++ % MAX_SOUNDS];
}
void S_BeginPrecaching(void) {}
void S_EndPrecaching(void) {}
void R_NewMap(void) { mq_newmap_calls++; }
void Hunk_Check(void) {}
void *Hunk_AllocName(int size, char *name)
{
    (void)size;
    (void)name;
    return mq_scores;
}
void R_TranslatePlayerSkin(int slot) { (void)slot; mq_translate_calls++; }
void R_AddEfrags(entity_t *entity) { (void)entity; mq_efrag_calls++; }
void Sbar_Changed(void) { mq_sbar_changes++; }

void S_StartSound(int ent, int channel, sfx_t *sound, vec3_t position, float volume, float attenuation)
{
    mq_sound_ent = ent;
    mq_sound_channel = channel;
    mq_sound_index = sound ? sound->marker : 0;
    VectorCopy(position, mq_sound_position);
    mq_sound_volume = volume;
    mq_sound_attenuation = attenuation;
}

void S_StaticSound(sfx_t *sound, vec3_t position, int volume, int attenuation)
{
    mq_static_sound_index = sound ? sound->marker : 0;
    VectorCopy(position, mq_static_sound_position);
    mq_static_sound_volume = volume;
    mq_static_sound_attenuation = attenuation;
}

void S_StopSound(int ent, int channel) { (void)ent; (void)channel; }
void R_ParseParticleEffect(void) {}
void V_ParseDamage(void) {}
void CL_ParseTEnt(void) {}
void SCR_CenterPrint(char *text) { mq_copy_text(mq_centerprint, text); }
void Cbuf_AddText(char *text) { mq_copy_text(mq_stufftext, text); }
void CDAudio_Pause(void) {}
void CDAudio_Resume(void) {}
void VID_HandlePause(qboolean paused) { (void)paused; }
void CDAudio_Play(byte track, qboolean looping)
{
    mq_cd_track = track;
    mq_cd_loop = looping;
}
void Cmd_ExecuteString(char *text, int source)
{
    (void)source;
    mq_copy_text(mq_command, text);
}
void Q_strcpy(char *destination, char *source) { mq_copy_text(destination, source); }
int Q_strlen(char *text) { return mq_strlen(text); }

float Sys_FloatTime(void) { return mq_sys_time; }
int CL_GetMessage(void)
{
    int result;
    int index;
    if (mq_get_index >= mq_get_count)
        return 0;
    result = mq_get_returns[mq_get_index];
    net_message.cursize = mq_get_lengths[mq_get_index];
    for (index = 0; index < net_message.cursize; index++)
        net_message.data[index] = mq_get_payloads[mq_get_index][index];
    mq_get_index++;
    MSG_BeginReading();
    return result;
}
int NET_SendMessage(void *connection, sizebuf_t *message)
{
    (void)connection;
    mq_keepalive_sends++;
    mq_keepalive_opcode = message->cursize ? message->data[0] : 0;
    return 1;
}

#define memcpy mq_memcpy
#define memset mq_memset
#define strcpy mq_strcpy
#define strncpy mq_strncpy
#define rand mq_rand
/*__PINNED_CL_PARSE_SOURCE__*/
#undef memcpy
#undef memset
#undef strcpy
#undef strncpy
#undef rand

static void mq_reset(void)
{
    int index;
    mq_memset(&cls, 0, sizeof(cls));
    mq_memset(&cl, 0, sizeof(cl));
    mq_memset(cl_entities, 0, sizeof(cl_entities));
    mq_memset(cl_static_entities, 0, sizeof(cl_static_entities));
    mq_memset(cl_lightstyle, 0, sizeof(cl_lightstyle));
    mq_memset(bitcounts, 0, sizeof(bitcounts));
    mq_memset(mq_scores, 0, sizeof(mq_scores));
    mq_memset(mq_models, 0, sizeof(mq_models));
    mq_memset(mq_sounds, 0, sizeof(mq_sounds));
    mq_memset(mq_centerprint, 0, sizeof(mq_centerprint));
    mq_memset(mq_stufftext, 0, sizeof(mq_stufftext));
    mq_memset(mq_command, 0, sizeof(mq_command));
    mq_memset(mq_get_returns, 0, sizeof(mq_get_returns));
    mq_memset(mq_get_lengths, 0, sizeof(mq_get_lengths));
    mq_memset(mq_get_payloads, 0, sizeof(mq_get_payloads));
    for (index = 0; index < (int)sizeof(mq_colormap); index++)
        mq_colormap[index] = (byte)(index & 255);
    for (index = 0; index < MAX_SOUNDS; index++)
        mq_sounds[index].marker = index;
    vid.colormap = mq_colormap;
    vid.recalc_refdef = false;
    sv.active = false;
    net_message.data = mq_net_data;
    net_message.maxsize = sizeof(mq_net_data);
    net_message.cursize = 0;
    cls.message.data = mq_client_message_data;
    cls.message.maxsize = sizeof(mq_client_message_data);
    cls.message.cursize = 0;
    cl.scores = mq_scores;
    standard_quake = true;
    mq_error = 0;
    mq_endgame = 0;
    mq_signon_replies = 0;
    mq_newmap_calls = 0;
    mq_model_touches = 0;
    mq_sound_touches = 0;
    mq_efrag_calls = 0;
    mq_translate_calls = 0;
    mq_sbar_changes = 0;
    mq_keepalive_sends = 0;
    mq_keepalive_opcode = 0;
    mq_sys_time = 0;
    mq_get_index = 0;
    mq_get_count = 0;
    mq_sound_ent = 0;
    mq_sound_channel = 0;
    mq_sound_index = 0;
    mq_static_sound_index = 0;
    mq_cd_track = 0;
    mq_cd_loop = 0;
    msg_readcount = 0;
    msg_badread = false;
}

static void mq_message(const byte *data, int length)
{
    int index;
    net_message.cursize = length;
    for (index = 0; index < length; index++)
        net_message.data[index] = data[index];
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

__declspec(dllexport) int cl_parse_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    byte packet[512];
    int length;
    int observed_bits;
    int index;
    entity_t baseline_entity;

    if (!output || capacity < 2)
        return -1;
    output[0] = 0;

    mq_reset();
    cl.num_entities = 1;
    CL_EntityNum(5);
    sprintf(line, "{\"function\":\"CL_EntityNum\",\"case\":\"extend\",\"num_entities\":%i,\"colormap_set\":%s}",
        cl.num_entities, cl_entities[5].colormap == vid.colormap ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cl.sound_precache[1] = &mq_sounds[1];
    {
        byte sound_packet[] = {3,200,32,190,18,1,64,0,224,255,16,0};
        mq_message(sound_packet, sizeof(sound_packet));
    }
    CL_ParseStartSoundPacket();
    sprintf(line, "{\"function\":\"CL_ParseStartSoundPacket\",\"case\":\"all_fields\",\"entity\":%i,\"channel\":%i,\"sound\":%i,\"volume\":%g,\"attenuation\":%g,\"position\":[%g,%g,%g],\"bytes_read\":%i}",
        mq_sound_ent, mq_sound_channel, mq_sound_index, mq_sound_volume,
        mq_sound_attenuation, mq_sound_position[0], mq_sound_position[1],
        mq_sound_position[2], msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    net_message.data[0] = 77;
    net_message.cursize = 1;
    mq_get_count = 2;
    mq_get_returns[0] = 2;
    mq_get_lengths[0] = 1;
    mq_get_payloads[0][0] = svc_nop;
    mq_get_returns[1] = 0;
    mq_sys_time = 6.0f;
    CL_KeepaliveMessage();
    sprintf(line, "{\"function\":\"CL_KeepaliveMessage\",\"case\":\"nop_restore_send\",\"restored\":[%i],\"send_count\":%i,\"opcode\":%i,\"queue_reads\":%i}",
        net_message.data[0], mq_keepalive_sends, mq_keepalive_opcode, mq_get_index);
    mq_emit(output, capacity, line);

    mq_reset();
    length = 0;
    packet[length++] = 15; packet[length++] = 0; packet[length++] = 0; packet[length++] = 0;
    packet[length++] = 2; packet[length++] = 0;
    mq_copy_text((char *)(packet + length), "fixture"); length += 8;
    mq_copy_text((char *)(packet + length), "maps/fixture.bsp"); length += 17;
    mq_copy_text((char *)(packet + length), "progs/player.mdl"); length += 17;
    packet[length++] = 0;
    mq_copy_text((char *)(packet + length), "misc/menu1.wav"); length += 15;
    packet[length++] = 0;
    mq_message(packet, length);
    CL_ParseServerInfo();
    sprintf(line, "{\"function\":\"CL_ParseServerInfo\",\"case\":\"protocol15_precache\",\"maxclients\":%i,\"gametype\":%i,\"level\":\"%s\",\"models\":%i,\"sounds\":%i,\"newmap_calls\":%i,\"bytes_read\":%i}",
        cl.maxclients, cl.gametype, cl.levelname, mq_model_touches,
        mq_sound_touches, mq_newmap_calls, msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.maxclients = 2;
    cl.scores = mq_scores;
    cl.model_precache[5] = &mq_models[5];
    cl.mtime[0] = 2.0;
    cl.mtime[1] = 1.0;
    cls.signon = SIGNONS - 1;
    {
        byte update_packet[] = {127,44,1,5,7,1,2,8,64,0,64,128,0,192,224,255,32};
        mq_message(update_packet, sizeof(update_packet));
    }
    CL_ParseUpdate(127);
    observed_bits = 0;
    for (index = 0; index < 16; index++)
        if (bitcounts[index])
            observed_bits |= 1 << index;
    sprintf(line, "{\"function\":\"CL_ParseUpdate\",\"case\":\"all_protocol15_bits\",\"entity\":%i,\"bits\":%i,\"model\":%i,\"frame\":%i,\"colormap\":%i,\"skin\":%i,\"effects\":%i,\"origin\":[%g,%g,%g],\"angles\":[%g,%g,%g],\"forcelink\":%s,\"signon\":%i,\"bytes_read\":%i}",
        cl.num_entities - 1, observed_bits,
        cl_entities[300].model == &mq_models[5] ? 5 : 0,
        cl_entities[300].frame,
        cl_entities[300].colormap == mq_scores[0].translations ? 1 : 0,
        cl_entities[300].skinnum, cl_entities[300].effects,
        cl_entities[300].msg_origins[0][0], cl_entities[300].msg_origins[0][1],
        cl_entities[300].msg_origins[0][2], cl_entities[300].msg_angles[0][0],
        cl_entities[300].msg_angles[0][1], cl_entities[300].msg_angles[0][2],
        cl_entities[300].forcelink ? "true" : "false", cls.signon, msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_memset(&baseline_entity, 0, sizeof(baseline_entity));
    {
        byte baseline_packet[] = {1,2,0,3,32,0,0,40,0,64,48,0,0};
        mq_message(baseline_packet, sizeof(baseline_packet));
    }
    CL_ParseBaseline(&baseline_entity);
    sprintf(line, "{\"function\":\"CL_ParseBaseline\",\"case\":\"interleaved\",\"model\":%i,\"frame\":%i,\"colormap\":%i,\"skin\":%i,\"origin\":[%g,%g,%g],\"angles\":[%g,%g,%g],\"bytes_read\":%i}",
        baseline_entity.baseline.modelindex, baseline_entity.baseline.frame,
        baseline_entity.baseline.colormap, baseline_entity.baseline.skin,
        baseline_entity.baseline.origin[0], baseline_entity.baseline.origin[1],
        baseline_entity.baseline.origin[2], baseline_entity.baseline.angles[0],
        baseline_entity.baseline.angles[1], baseline_entity.baseline.angles[2],
        msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.time = 12.0;
    standard_quake = false;
    {
        byte clientdata_packet[] = {
            24,254,1,2,3,4,5,6,5,0,0,0,7,80,4,99,0,50,10,20,30,40,3
        };
        mq_message(clientdata_packet, sizeof(clientdata_packet));
    }
    CL_ParseClientdata(0x7eff);
    sprintf(line, "{\"function\":\"CL_ParseClientdata\",\"case\":\"all_fields_missionpack\",\"viewheight\":%g,\"idealpitch\":%g,\"punch\":[%g,%g,%g],\"velocity\":[%g,%g,%g],\"items\":%i,\"onground\":%s,\"inwater\":%s,\"health\":%i,\"ammo\":%i,\"activeweapon\":%i,\"bytes_read\":%i}",
        cl.viewheight, cl.idealpitch, cl.punchangle[0], cl.punchangle[1],
        cl.punchangle[2], cl.mvelocity[0][0], cl.mvelocity[0][1],
        cl.mvelocity[0][2], cl.items, cl.onground ? "true" : "false",
        cl.inwater ? "true" : "false", cl.stats[STAT_HEALTH],
        cl.stats[STAT_AMMO], cl.stats[STAT_ACTIVEWEAPON], msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.maxclients = 1;
    cl.scores = mq_scores;
    cl.scores[0].colors = 0x4f;
    CL_NewTranslation(0);
    sprintf(line, "{\"function\":\"CL_NewTranslation\",\"case\":\"forward_reverse_ranges\",\"top_first\":%i,\"top_last\":%i,\"bottom_first\":%i,\"bottom_last\":%i,\"last_grade_bottom_last\":%i,\"skin_translates\":%i}",
        cl.scores[0].translations[TOP_RANGE],
        cl.scores[0].translations[TOP_RANGE+15],
        cl.scores[0].translations[BOTTOM_RANGE],
        cl.scores[0].translations[BOTTOM_RANGE+15],
        cl.scores[0].translations[(VID_GRADES-1)*256+BOTTOM_RANGE+15],
        mq_translate_calls);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.model_precache[1] = &mq_models[1];
    {
        byte static_packet[] = {1,2,0,3,32,0,0,40,0,64,48,0,0};
        mq_message(static_packet, sizeof(static_packet));
    }
    CL_ParseStatic();
    sprintf(line, "{\"function\":\"CL_ParseStatic\",\"case\":\"baseline_copy\",\"num_statics\":%i,\"model\":%i,\"frame\":%i,\"skin\":%i,\"origin\":[%g,%g,%g],\"angles\":[%g,%g,%g],\"efrags\":%i,\"bytes_read\":%i}",
        cl.num_statics, cl_static_entities[0].baseline.modelindex,
        cl_static_entities[0].frame,
        cl_static_entities[0].skinnum, cl_static_entities[0].origin[0],
        cl_static_entities[0].origin[1], cl_static_entities[0].origin[2],
        cl_static_entities[0].angles[0], cl_static_entities[0].angles[1],
        cl_static_entities[0].angles[2], mq_efrag_calls, msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    cl.sound_precache[1] = &mq_sounds[1];
    {
        byte static_sound_packet[] = {8,0,16,0,24,0,1,128,64};
        mq_message(static_sound_packet, sizeof(static_sound_packet));
    }
    CL_ParseStaticSound();
    sprintf(line, "{\"function\":\"CL_ParseStaticSound\",\"case\":\"protocol15\",\"sound\":%i,\"volume\":%i,\"attenuation\":%i,\"position\":[%g,%g,%g],\"bytes_read\":%i}",
        mq_static_sound_index, mq_static_sound_volume,
        mq_static_sound_attenuation, mq_static_sound_position[0],
        mq_static_sound_position[1], mq_static_sound_position[2], msg_readcount);
    mq_emit(output, capacity, line);

    mq_reset();
    length = 0;
    packet[length++] = svc_time;
    {
        union { float f; byte b[4]; } value;
        value.f = 3.5f;
        packet[length++] = value.b[0]; packet[length++] = value.b[1];
        packet[length++] = value.b[2]; packet[length++] = value.b[3];
    }
    packet[length++] = svc_setview; packet[length++] = 7; packet[length++] = 0;
    packet[length++] = svc_setangle; packet[length++] = 64; packet[length++] = 192; packet[length++] = 32;
    packet[length++] = svc_lightstyle; packet[length++] = 0;
    packet[length++] = 'a'; packet[length++] = 'b'; packet[length++] = 'c'; packet[length++] = 0;
    packet[length++] = svc_killedmonster;
    packet[length++] = svc_foundsecret;
    packet[length++] = svc_cdtrack; packet[length++] = 3; packet[length++] = 4;
    packet[length++] = svc_intermission;
    mq_message(packet, length);
    cl.time = 12.0;
    CL_ParseServerMessage();
    sprintf(line, "{\"function\":\"CL_ParseServerMessage\",\"case\":\"svc_state\",\"time\":%g,\"viewentity\":%i,\"viewangles\":[%g,%g,%g],\"lightstyle\":\"%s\",\"monsters\":%i,\"secrets\":%i,\"cdtrack\":%i,\"looptrack\":%i,\"intermission\":%i,\"completed_time\":%i,\"bytes_read\":%i}",
        cl.mtime[0], cl.viewentity, cl.viewangles[0], cl.viewangles[1],
        cl.viewangles[2], cl_lightstyle[0].map, cl.stats[STAT_MONSTERS],
        cl.stats[STAT_SECRETS], cl.cdtrack, cl.looptrack,
        cl.intermission, cl.completed_time, msg_readcount);
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
