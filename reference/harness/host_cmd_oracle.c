/* Direct deterministic harness for the pinned WinQuake/host_cmd.c. */

typedef unsigned char byte;
typedef int qboolean;
typedef char *va_list;
typedef struct mq_file_s { int marker; } FILE;
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
    struct cvar_s *next;
} cvar_t;
typedef struct qsocket_s {
    double connecttime;
    char address[64];
} qsocket_t;
typedef struct entvars_s {
    float frags;
    float flags;
    float movetype;
    float team;
    float health;
    float items;
    float ammo_shells;
    float ammo_nails;
    float ammo_rockets;
    float ammo_cells;
    float weapon;
    int classname;
    float modelindex;
    float frame;
    float colormap;
    int netname;
    vec3_t angles;
} entvars_t;
typedef struct edict_s {
    qboolean free;
    entvars_t v;
} edict_t;
typedef struct client_s {
    qboolean active;
    qboolean spawned;
    qboolean privileged;
    qboolean sendsignon;
    qsocket_t *netconnection;
    edict_t *edict;
    char name[32];
    int colors;
    float ping_times[16];
    float spawn_parms[16];
    sizebuf_t message;
    byte msgbuf[4096];
    int old_frags;
} client_t;
typedef struct server_s {
    qboolean active;
    qboolean paused;
    qboolean loadgame;
    double time;
    char name[64];
    sizebuf_t reliable_datagram;
    byte reliable_buf[4096];
    sizebuf_t signon;
    byte signon_buf[4096];
    char *lightstyles[64];
    int num_edicts;
} server_t;
typedef struct server_static_s {
    int maxclients;
    client_t *clients;
    int serverflags;
} server_static_t;
typedef struct client_static_s {
    int state;
    int demonum;
    qboolean demoplayback;
    int signon;
    char mapstring[1024];
    char spawnparms[1024];
    char demos[8][16];
} client_static_t;
typedef struct model_s {
    int numframes;
    int marker;
} model_t;
typedef struct client_state_s {
    char levelname[64];
    int stats[32];
    int intermission;
    model_t *model_precache[256];
} client_state_t;
typedef struct globalvars_s {
    float deathmatch;
    float time;
    int self;
    int ClientKill;
    int ClientConnect;
    int PutClientInServer;
    float parm1;
    float parms[15];
    int total_secrets;
    int total_monsters;
    int found_secrets;
    int killed_monsters;
} globalvars_t;
typedef struct progs_s { int entityfields; } progs_t;
typedef union eval_s { float _float; int _int; } eval_t;
typedef struct maliasframedesc_s { char name[16]; } maliasframedesc_t;
typedef struct aliashdr_s { maliasframedesc_t frames[16]; } aliashdr_t;

#define true 1
#define false 0
#define NULL 0
#define MAX_QPATH 64
#define MAX_OSPATH 128
#define MAX_DEMOS 8
#define NUM_PING_TIMES 16
#define NUM_SPAWN_PARMS 16
#define MAX_LIGHTSTYLES 64
#define SAVEGAME_COMMENT_LENGTH 39
#define STAT_MONSTERS 14
#define STAT_TOTALMONSTERS 12
#define STAT_TOTALSECRETS 11
#define STAT_SECRETS 13
#define VERSION 1.09
#define src_command 0
#define src_client 1
#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2
#define key_game 0
#define key_console 1
#define FL_GODMODE 64
#define FL_NOTARGET 128
#define MOVETYPE_WALK 3
#define MOVETYPE_FLY 5
#define MOVETYPE_NOCLIP 8
#define IT_SHOTGUN 1
#define IT_GRENADE_LAUNCHER 16
#define IT_LIGHTNING 64
#define HIT_PROXIMITY_GUN 0x10000
#define HIT_LASER_CANNON 0x20000
#define HIT_MJOLNIR 0x40000
#define svc_updatename 13
#define svc_updatefrags 14
#define svc_updatecolors 17
#define svc_setpause 24
#define svc_signonnum 25
#define svc_time 7
#define svc_lightstyle 12
#define svc_updatestat 3
#define svc_setangle 10
#define EOF (-1)

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

server_t sv;
server_static_t svs;
client_static_t cls;
client_state_t cl;
globalvars_t mq_globals;
globalvars_t *pr_global_struct = &mq_globals;
progs_t mq_progs;
progs_t *progs = &mq_progs;
edict_t mq_edicts[64];
client_t *host_client;
edict_t *sv_player;
int cmd_source;
int key_dest;
int current_skill;
int net_activeconnections;
double net_time;
qboolean tcpipAvailable;
qboolean ipxAvailable;
char my_tcpip_address[64] = "127.0.0.1";
char my_ipx_address[64] = "";
char com_gamedir[64] = "id1";
char com_token[1024];
char pr_string_storage[4096];
char *pr_strings = pr_string_storage;
qboolean hipnotic;
qboolean rogue;
cvar_t pausable = {"pausable", "1", false, false, 1};
cvar_t cl_name = {"_cl_name", "player", true, false, 0};
cvar_t cl_color = {"_cl_color", "0", true, false, 0};
cvar_t hostname = {"hostname", "UNNAMED", true, false, 0};
cvar_t teamplay = {"teamplay", "0", false, true, 0};

static byte mq_hunk[131072];
static int mq_hunk_used;
static client_t mq_clients[16];
static qsocket_t mq_sockets[16];
static byte mq_message_log[8192];
static int mq_message_size;
static int mq_forward_calls;
static int mq_menu_quit_calls;
static int mq_disconnect_calls;
static int mq_shutdown_calls;
static int mq_quit_calls;
static int mq_client_print_calls;
static int mq_broadcast_calls;
static int mq_loading_calls;
static int mq_spawn_calls;
static int mq_save_spawn_calls;
static int mq_execute_calls;
static int mq_establish_calls;
static int mq_stop_playback_calls;
static int mq_drop_calls;
static int mq_next_demo_calls;
static int mq_disconnect_f_calls;
static int mq_command_count;
static int mq_cbuf_add_calls;
static int mq_last_program;
static int mq_model_print_calls;
static int mq_frame_print_calls;
static int mq_console_print_calls;
static int mq_mod_extra_available;
static int mq_cmd_argc;
static char *mq_cmd_argv[16];
static char mq_cmd_args[1024];
static model_t mq_model;
static aliashdr_t mq_alias;
static eval_t mq_eval;
static FILE mq_file;

static int mq_strlen(const char *text)
{
    int length = 0;
    while (text && text[length])
        length++;
    return length;
}
static void mq_copy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
        ;
}
static int mq_compare(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && left[index] == right[index])
        index++;
    return (unsigned char)left[index] - (unsigned char)right[index];
}
static char mq_lower(char value)
{
    if (value >= 'A' && value <= 'Z')
        return value + ('a' - 'A');
    return value;
}
static int mq_compare_insensitive(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && mq_lower(left[index]) == mq_lower(right[index]))
        index++;
    return mq_lower(left[index]) - mq_lower(right[index]);
}
static void *mq_memset(void *destination, int value, int length)
{
    byte *data = (byte *)destination;
    int index;
    for (index = 0; index < length; index++)
        data[index] = (byte)value;
    return destination;
}
static void *mq_memcpy(void *destination, const void *source, int length)
{
    byte *out = (byte *)destination;
    const byte *in = (const byte *)source;
    int index;
    for (index = 0; index < length; index++)
        out[index] = in[index];
    return destination;
}
static char *mq_strcat(char *destination, const char *source)
{
    mq_copy(destination + mq_strlen(destination), source);
    return destination;
}
static char *mq_strncpy(char *destination, const char *source, int count)
{
    int index;
    for (index = 0; index < count && source[index]; index++)
        destination[index] = source[index];
    while (index < count)
        destination[index++] = 0;
    return destination;
}
static char *mq_strstr(const char *text, const char *wanted)
{
    int start;
    int length = mq_strlen(wanted);
    for (start = 0; text[start]; start++)
        if (mq_compare_insensitive(text + start, wanted) == 0 ||
            (length == 2 && text[start] == wanted[0] && text[start+1] == wanted[1]))
            return (char *)text + start;
    return NULL;
}
static int mq_atoi(char *text)
{
    int sign = 1;
    int value = 0;
    if (*text == '-') { sign = -1; text++; }
    while (*text >= '0' && *text <= '9')
        value = value * 10 + (*text++ - '0');
    return value * sign;
}
static float mq_atof(char *text) { return (float)mq_atoi(text); }
static void *mq_malloc(int length)
{
    void *result;
    if (mq_hunk_used + length > (int)sizeof(mq_hunk))
        return NULL;
    result = mq_hunk + mq_hunk_used;
    mq_hunk_used += length;
    return result;
}
static FILE *mq_fopen(char *name, char *mode) { (void)name; (void)mode; return &mq_file; }
static int mq_fclose(FILE *file) { (void)file; return 0; }
static int mq_fprintf(FILE *file, char *format, ...) { (void)file; (void)format; return 1; }
static int mq_fscanf(FILE *file, char *format, ...) { (void)file; (void)format; return 0; }
static int mq_fgetc(FILE *file) { (void)file; return EOF; }
static int mq_feof(FILE *file) { (void)file; return 1; }
static int mq_fflush(FILE *file) { (void)file; return 0; }

int Cmd_Argc(void) { return mq_cmd_argc; }
char *Cmd_Argv(int index)
{
    static char empty[1] = {0};
    if (index < 0 || index >= mq_cmd_argc)
        return empty;
    return mq_cmd_argv[index];
}
char *Cmd_Args(void) { return mq_cmd_args; }
void Cmd_ForwardToServer(void) { mq_forward_calls++; }
void M_Menu_Quit_f(void) { mq_menu_quit_calls++; }
void CL_Disconnect(void) { mq_disconnect_calls++; cls.state = ca_disconnected; }
void Host_ShutdownServer(qboolean crash) { (void)crash; mq_shutdown_calls++; sv.active = false; }
void Sys_Quit(void) { mq_quit_calls++; }
void Con_Printf(char *format, ...) { (void)format; mq_console_print_calls++; }
void Sys_Printf(char *format, ...) { (void)format; }
char *Cvar_VariableString(char *name) { (void)name; return hostname.string; }
void SV_ClientPrintf(char *format, ...) { (void)format; mq_client_print_calls++; }
void SV_BroadcastPrintf(char *format, ...) { (void)format; mq_broadcast_calls++; }
void SCR_BeginLoadingPlaque(void) { mq_loading_calls++; }
void SV_SpawnServer(char *name)
{
    mq_spawn_calls++; mq_copy(sv.name, name); sv.active = name[0] != 0;
}
void SV_SaveSpawnparms(void) { mq_save_spawn_calls++; }
void Cmd_ExecuteString(char *text, int source) { (void)text; (void)source; }
void CL_StopPlayback(void) { mq_stop_playback_calls++; cls.demoplayback = false; }
void CL_EstablishConnection(char *name) { (void)name; mq_establish_calls++; cls.state = ca_connected; }
void COM_DefaultExtension(char *name, char *extension)
{
    int length = mq_strlen(name);
    int index;
    for (index = length - 1; index >= 0 && name[index] != '/' && name[index] != '\\'; index--)
        if (name[index] == '.')
            return;
    mq_strcat(name, extension);
}
void ED_WriteGlobals(FILE *file) { (void)file; }
void ED_Write(FILE *file, edict_t *edict) { (void)file; (void)edict; }
void CL_Disconnect_f(void) { mq_disconnect_f_calls++; CL_Disconnect(); }
void Cvar_SetValue(char *name, float value)
{
    if (mq_compare(name, "skill") == 0) current_skill = (int)value;
    if (mq_compare(name, "_cl_color") == 0) cl_color.value = value;
}
void Cvar_Set(char *name, char *value)
{
    if (mq_compare(name, "_cl_name") == 0) cl_name.string = value;
}
void *Hunk_Alloc(int length) { return mq_malloc(length); }
char *COM_Parse(char *text)
{
    int index = 0;
    while (*text == ' ' || *text == '\t' || *text == '\n') text++;
    while (*text && *text != ' ' && *text != '\t' && *text != '\n' && index < 1023)
        com_token[index++] = *text++;
    com_token[index] = 0;
    return text;
}
void Sys_Error(char *format, ...) { (void)format; }
void ED_ParseGlobals(char *text) { (void)text; }
void ED_ParseEdict(char *text, edict_t *edict) { (void)text; (void)edict; }
void SV_LinkEdict(edict_t *edict, qboolean touch) { (void)edict; (void)touch; }
int Q_strcmp(char *left, char *right) { return mq_compare(left, right); }
int Q_strcasecmp(char *left, char *right) { return mq_compare_insensitive(left, right); }
int Q_strlen(char *text) { return mq_strlen(text); }
void Q_strcpy(char *destination, char *source) { mq_copy(destination, source); }
void Q_strcat(char *destination, char *source) { mq_strcat(destination, source); }
float Q_atof(char *text) { return mq_atof(text); }
void PR_ExecuteProgram(int program) { mq_execute_calls++; mq_last_program = program; }
void SZ_Write(sizebuf_t *buffer, void *data, int length)
{
    mq_memcpy(buffer->data + buffer->cursize, data, length);
    buffer->cursize += length;
}
void SZ_Clear(sizebuf_t *buffer) { buffer->cursize = 0; }
void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize < buffer->maxsize)
        buffer->data[buffer->cursize++] = (byte)value;
}
void MSG_WriteShort(sizebuf_t *buffer, int value)
{
    MSG_WriteByte(buffer, value & 255); MSG_WriteByte(buffer, (value >> 8) & 255);
}
void MSG_WriteLong(sizebuf_t *buffer, int value)
{
    MSG_WriteShort(buffer, value & 65535); MSG_WriteShort(buffer, (value >> 16) & 65535);
}
void MSG_WriteFloat(sizebuf_t *buffer, float value)
{
    union { float value; byte bytes[4]; } raw; int i;
    raw.value = value; for (i = 0; i < 4; i++) MSG_WriteByte(buffer, raw.bytes[i]);
}
void MSG_WriteString(sizebuf_t *buffer, char *text)
{
    while (*text) MSG_WriteByte(buffer, *text++);
    MSG_WriteByte(buffer, 0);
}
void MSG_WriteAngle(sizebuf_t *buffer, float value) { MSG_WriteByte(buffer, (int)(value * 256 / 360) & 255); }
void SV_WriteClientdataToMessage(edict_t *player, sizebuf_t *message) { (void)player; (void)message; }
double Sys_FloatTime(void) { return net_time; }
void SV_DropClient(qboolean crash) { (void)crash; mq_drop_calls++; host_client->active = false; }
eval_t *GetEdictFieldValue(edict_t *edict, char *name) { (void)edict; (void)name; return &mq_eval; }
model_t *Mod_ForName(char *name, qboolean crash) { (void)name; (void)crash; return &mq_model; }
void *Mod_Extradata(model_t *model)
{ (void)model; return mq_mod_extra_available ? (void *)&mq_alias : NULL; }
void CL_NextDemo(void) { mq_next_demo_calls++; }
void Cbuf_AddText(char *text) { (void)text; mq_cbuf_add_calls++; }
void Cmd_AddCommand(char *name, void (*function)(void))
{ (void)name; (void)function; mq_command_count++; }
void Mod_Print(void) { mq_model_print_calls++; }

#define EDICT_NUM(index) (&mq_edicts[(index)])
#define NUM_FOR_EDICT(edict) ((int)((edict) - mq_edicts))
#define EDICT_TO_PROG(edict) NUM_FOR_EDICT(edict)
#define memset mq_memset
#define memcpy mq_memcpy
#define strlen mq_strlen
#define strcpy(destination,source) (mq_copy(destination,source),(destination))
#define strcat mq_strcat
#define strncpy mq_strncpy
#define strcmp mq_compare
#define strstr mq_strstr
#define atoi mq_atoi
#define fopen mq_fopen
#define fclose mq_fclose
#define fprintf mq_fprintf
#define fscanf mq_fscanf
#define fgetc mq_fgetc
#define feof mq_feof
#define fflush mq_fflush
/*__PINNED_HOST_CMD_SOURCE__*/
#undef memset
#undef memcpy
#undef strlen
#undef strcpy
#undef strcat
#undef strncpy
#undef strcmp
#undef strstr
#undef atoi
#undef fopen
#undef fclose
#undef fprintf
#undef fscanf
#undef fgetc
#undef feof
#undef fflush

static int mq_text_equal(const char *left, const char *right) { return mq_compare(left, right) == 0; }
static void mq_reset(void)
{
    int index;
    mq_memset(&sv, 0, sizeof(sv)); mq_memset(&svs, 0, sizeof(svs));
    mq_memset(&cls, 0, sizeof(cls)); mq_memset(&cl, 0, sizeof(cl));
    mq_memset(&mq_globals, 0, sizeof(mq_globals)); mq_memset(mq_edicts, 0, sizeof(mq_edicts));
    mq_memset(mq_clients, 0, sizeof(mq_clients)); mq_memset(mq_sockets, 0, sizeof(mq_sockets));
    mq_memset(mq_message_log, 0, sizeof(mq_message_log)); mq_memset(pr_string_storage, 0, sizeof(pr_string_storage));
    mq_hunk_used = 0; mq_message_size = 0;
    svs.maxclients = 2; svs.clients = mq_clients;
    sv.reliable_datagram.data = sv.reliable_buf; sv.reliable_datagram.maxsize = sizeof(sv.reliable_buf);
    sv.signon.data = sv.signon_buf; sv.signon.maxsize = sizeof(sv.signon_buf);
    for (index = 0; index < 16; index++) {
        mq_clients[index].edict = &mq_edicts[index + 1];
        mq_clients[index].netconnection = &mq_sockets[index];
        mq_clients[index].message.data = mq_clients[index].msgbuf;
        mq_clients[index].message.maxsize = sizeof(mq_clients[index].msgbuf);
        mq_clients[index].old_frags = -999999;
        mq_copy(mq_sockets[index].address, "LOCAL");
    }
    host_client = &mq_clients[0]; sv_player = &mq_edicts[1];
    mq_progs.entityfields = sizeof(entvars_t) / 4;
    cmd_source = src_command; key_dest = key_console; cls.state = ca_disconnected; cls.demonum = -1;
    pausable.value = 1; teamplay.value = 0; cl_color.value = 0;
    cl_name.string = "player"; hostname.string = "UNNAMED";
    mq_forward_calls = mq_menu_quit_calls = mq_disconnect_calls = mq_shutdown_calls = 0;
    mq_quit_calls = mq_client_print_calls = mq_broadcast_calls = mq_loading_calls = 0;
    mq_spawn_calls = mq_save_spawn_calls = mq_execute_calls = mq_establish_calls = 0;
    mq_stop_playback_calls = mq_drop_calls = mq_next_demo_calls = mq_disconnect_f_calls = 0;
    mq_command_count = mq_cbuf_add_calls = mq_last_program = mq_model_print_calls = 0;
    mq_frame_print_calls = mq_console_print_calls = mq_mod_extra_available = 0;
    mq_cmd_argc = 0; mq_cmd_args[0] = 0;
    current_skill = 1; net_activeconnections = 0; net_time = 10;
    tcpipAvailable = ipxAvailable = hipnotic = rogue = false;
    mq_model.numframes = 4; mq_model.marker = 1;
    for (index = 0; index < 16; index++) sprintf(mq_alias.frames[index].name, "frame%i", index);
}
static void mq_set_args(int count, char **values)
{
    int index;
    mq_cmd_argc = count; mq_cmd_args[0] = 0;
    for (index = 0; index < count; index++) {
        mq_cmd_argv[index] = values[index];
        if (index > 0) {
            if (index > 1) mq_strcat(mq_cmd_args, " ");
            mq_strcat(mq_cmd_args, values[index]);
        }
    }
}
static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output), length = mq_strlen(line), index;
    if (used + length + 1 >= capacity) return;
    for (index = 0; index < length; index++) output[used + index] = line[index];
    output[used + length] = '\n'; output[used + length + 1] = 0;
}

__declspec(dllexport) int host_cmd_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    char name_value[] = "Ranger";
    char *no_args[] = {"command"};
    char *color_args[] = {"color", "-1", "14"};
    char *connect_args[] = {"connect", "remote"};
    char *give_args[] = {"give", "h", "125"};
    char *name_args[] = {"name", name_value};
    char *start_args[] = {"startdemos", "demo1", "demo2"};
    char comment[SAVEGAME_COMMENT_LENGTH + 1];
    edict_t *viewthing;

    if (!output || capacity < 2) return -1;
    output[0] = 0;

    mq_reset();
    sv.num_edicts = 1;
    viewthing = FindViewthing();
    sprintf(line, "{\"function\":\"FindViewthing\",\"case\":\"missing\",\"found\":%s}",
        viewthing ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cmd_source = src_client; host_client->spawned = false;
    Host_Begin_f();
    sprintf(line, "{\"function\":\"Host_Begin_f\",\"case\":\"client_begin\",\"spawned\":%s}",
        host_client->spawned ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(1, no_args);
    Host_Changelevel_f();
    sprintf(line, "{\"function\":\"Host_Changelevel_f\",\"case\":\"invalid_arguments\",\"spawned\":%s}",
        mq_spawn_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(3, color_args);
    Host_Color_f();
    sprintf(line, "{\"function\":\"Host_Color_f\",\"case\":\"console_clamp\",\"color\":%i}",
        (int)cl_color.value);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demonum = 3; mq_set_args(2, connect_args);
    Host_Connect_f();
    sprintf(line, "{\"function\":\"Host_Connect_f\",\"case\":\"remote_attempt\",\"demonum\":%i}",
        cls.demonum);
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demonum = -1;
    Host_Demos_f();
    sprintf(line, "{\"function\":\"Host_Demos_f\",\"case\":\"resume_loop\",\"demonum\":%i,\"next\":%i}",
        cls.demonum, mq_next_demo_calls);
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Fly_f();
    sprintf(line, "{\"function\":\"Host_Fly_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Give_f();
    sprintf(line, "{\"function\":\"Host_Give_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_God_f();
    sprintf(line, "{\"function\":\"Host_God_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_InitCommands();
    sprintf(line, "{\"function\":\"Host_InitCommands\",\"case\":\"stock_commands\",\"commands\":%i}",
        mq_command_count);
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = false; mq_set_args(1, no_args);
    Host_Kick_f();
    sprintf(line, "{\"function\":\"Host_Kick_f\",\"case\":\"inactive_console\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cmd_source = src_client; host_client->active = true; sv_player->v.health = 0;
    Host_Kill_f();
    sprintf(line, "{\"function\":\"Host_Kill_f\",\"case\":\"already_dead\",\"rejected\":%s}",
        mq_execute_calls == 0 && mq_client_print_calls == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(1, no_args);
    Host_Loadgame_f();
    sprintf(line, "{\"function\":\"Host_Loadgame_f\",\"case\":\"invalid_arguments\",\"loaded\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(1, no_args);
    Host_Map_f();
    sprintf(line, "{\"function\":\"Host_Map_f\",\"case\":\"empty_map\",\"active\":%s}",
        sv.active ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(2, name_args);
    Host_Name_f();
    sprintf(line, "{\"function\":\"Host_Name_f\",\"case\":\"console_name\",\"name_ok\":%s}",
        mq_text_equal(cl_name.string, "Ranger") ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Noclip_f();
    sprintf(line, "{\"function\":\"Host_Noclip_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Notarget_f();
    sprintf(line, "{\"function\":\"Host_Notarget_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Pause_f();
    sprintf(line, "{\"function\":\"Host_Pause_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Ping_f();
    sprintf(line, "{\"function\":\"Host_Ping_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cmd_source = src_client; host_client->spawned = true;
    Host_PreSpawn_f();
    sprintf(line, "{\"function\":\"Host_PreSpawn_f\",\"case\":\"already_spawned\",\"sendsignon\":%s}",
        host_client->sendsignon ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    key_dest = key_game; cls.state = ca_disconnected;
    Host_Quit_f();
    sprintf(line, "{\"function\":\"Host_Quit_f\",\"case\":\"menu_confirmation\",\"menu\":%s,\"quit\":%s}",
        mq_menu_quit_calls == 1 ? "true" : "false", mq_quit_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.signon = 4;
    Host_Reconnect_f();
    sprintf(line, "{\"function\":\"Host_Reconnect_f\",\"case\":\"wait_for_signon\",\"signon\":%i}",
        cls.signon);
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = false;
    Host_Restart_f();
    sprintf(line, "{\"function\":\"Host_Restart_f\",\"case\":\"inactive\",\"spawned\":%s}",
        mq_spawn_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    mq_copy(cl.levelname, "Entrance");
    cl.stats[STAT_MONSTERS] = 1; cl.stats[STAT_TOTALMONSTERS] = 12;
    Host_SavegameComment(comment);
    sprintf(line, "{\"function\":\"Host_SavegameComment\",\"case\":\"entrance\",\"comment\":\"%s\"}", comment);
    mq_emit(output, capacity, line);

    mq_reset();
    mq_set_args(1, no_args);
    Host_Savegame_f();
    sprintf(line, "{\"function\":\"Host_Savegame_f\",\"case\":\"inactive\",\"saved\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Say(false);
    sprintf(line, "{\"function\":\"Host_Say\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Say_Team_f();
    sprintf(line, "{\"function\":\"Host_Say_Team_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Say_f();
    sprintf(line, "{\"function\":\"Host_Say_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cmd_source = src_client; host_client->spawned = true;
    Host_Spawn_f();
    sprintf(line, "{\"function\":\"Host_Spawn_f\",\"case\":\"already_spawned\",\"sendsignon\":%s}",
        host_client->sendsignon ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demonum = -1; mq_set_args(3, start_args);
    Host_Startdemos_f();
    sprintf(line, "{\"function\":\"Host_Startdemos_f\",\"case\":\"two_demos\",\"first_ok\":%s,\"second_ok\":%s,\"demonum\":%i}",
        mq_text_equal(cls.demos[0], "demo1") ? "true" : "false",
        mq_text_equal(cls.demos[1], "demo2") ? "true" : "false", cls.demonum);
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = false;
    Host_Status_f();
    sprintf(line, "{\"function\":\"Host_Status_f\",\"case\":\"inactive_console\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    cls.demoplayback = false;
    Host_Stopdemo_f();
    sprintf(line, "{\"function\":\"Host_Stopdemo_f\",\"case\":\"not_playing\",\"stopped\":%s}",
        mq_stop_playback_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Tell_f();
    sprintf(line, "{\"function\":\"Host_Tell_f\",\"case\":\"console_disconnected\",\"sent\":%s}",
        cls.state == ca_connected && mq_forward_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    Host_Version_f();
    sprintf(line, "{\"function\":\"Host_Version_f\",\"case\":\"version\",\"printed\":%s}",
        mq_console_print_calls > 0 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    sv.num_edicts = 1; mq_set_args(1, no_args);
    Host_Viewframe_f();
    sprintf(line, "{\"function\":\"Host_Viewframe_f\",\"case\":\"missing_viewthing\",\"changed\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    sv.num_edicts = 1; mq_set_args(1, no_args);
    Host_Viewmodel_f();
    sprintf(line, "{\"function\":\"Host_Viewmodel_f\",\"case\":\"missing_viewthing\",\"changed\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    sv.num_edicts = 1;
    Host_Viewnext_f();
    sprintf(line, "{\"function\":\"Host_Viewnext_f\",\"case\":\"missing_viewthing\",\"changed\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    sv.num_edicts = 1;
    Host_Viewprev_f();
    sprintf(line, "{\"function\":\"Host_Viewprev_f\",\"case\":\"missing_viewthing\",\"changed\":false}");
    mq_emit(output, capacity, line);

    mq_reset();
    PrintFrameName(&mq_model, 1);
    sprintf(line, "{\"function\":\"PrintFrameName\",\"case\":\"missing_extradata\",\"printed\":%s}",
        mq_console_print_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    return mq_strlen(output);
}
