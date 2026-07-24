/* Direct deterministic harness for the pinned WinQuake/host.c. */

typedef unsigned char byte;
typedef int qboolean;
typedef char *va_list;
typedef struct mq_file_s { int marker; } FILE;
typedef int jmp_buf;
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
typedef struct edict_s { int marker; } edict_t;
typedef struct qsocket_s { int marker; } qsocket_t;
typedef struct client_s {
    qboolean active;
    qboolean spawned;
    qboolean privileged;
    qboolean sendsignon;
    double last_message;
    qsocket_t *netconnection;
    edict_t *edict;
    char name[32];
    int colors;
    float ping_times[16];
    sizebuf_t message;
    byte msgbuf[1024];
    int old_frags;
} client_t;
typedef struct server_s {
    qboolean active;
    qboolean paused;
    double time;
    sizebuf_t datagram;
    byte datagram_buf[1024];
} server_t;
typedef struct server_static_s {
    int maxclients;
    int maxclientslimit;
    client_t *clients;
} server_static_t;
typedef struct client_static_s {
    int state;
    qboolean timedemo;
    int demonum;
    int signon;
} client_static_t;
typedef struct client_state_s { int marker; } client_state_t;
typedef struct globalvars_s {
    int self;
    int ClientDisconnect;
    float frametime;
} globalvars_t;
typedef struct quakeparms_s {
    char *basedir;
    int argc;
    char **argv;
    void *membase;
    int memsize;
} quakeparms_t;

#define true 1
#define false 0
#define NULL 0
#define MAX_SCOREBOARD 16
#define SIGNONS 4
#define MINIMUM_MEMORY 0x550000
#define MINIMUM_MEMORY_LEVELPAK 0x550000
#define ca_dedicated 0
#define ca_disconnected 1
#define ca_connected 2
#define key_game 0
#define svc_print 8
#define svc_stufftext 9
#define svc_disconnect 2
#define svc_updatename 13
#define svc_updatefrags 14
#define svc_updatecolors 17
#define EDICT_TO_PROG(value) ((int)((value) - mq_edicts))

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int _fltused = 0;

server_t sv;
server_static_t svs;
client_static_t cls;
client_state_t cl;
globalvars_t mq_globals;
globalvars_t *pr_global_struct = &mq_globals;
edict_t mq_edicts[32];
int net_activeconnections;
int key_dest;
qboolean isDedicated;
qboolean standard_quake = true;
qboolean scr_disabled_for_loading;
int com_argc;
char **com_argv;
char com_gamedir[64] = "id1";
int vcrFile = -1;
vec3_t r_origin = {1,2,3};
vec3_t vpn = {0,1,0};
vec3_t vright = {1,0,0};
vec3_t vup = {0,0,1};
vec3_t vec3_origin = {0,0,0};

static byte mq_hunk[65536];
static int mq_hunk_used;
static int mq_longjmp_calls;
static int mq_sys_error_calls;
static int mq_nextdemo_calls;
static int mq_disconnect_calls;
static int mq_loading_end_calls;
static int mq_shutdown_server_calls;
static int mq_register_cvars;
static int mq_init_commands;
static int mq_cvar_deathmatch;
static int mq_key_writes;
static int mq_cvar_writes;
static int mq_file_opens;
static int mq_file_closes;
static int mq_net_close_calls;
static int mq_net_send_calls;
static int mq_send_to_all_calls;
static int mq_execute_program_calls;
static int mq_flush_calls;
static int mq_mod_clear_calls;
static int mq_free_mark;
static int mq_console_input_index;
static int mq_cbuf_add_calls;
static int mq_cbuf_added_chars;
static int mq_clear_datagram_calls;
static int mq_check_clients_calls;
static int mq_run_clients_calls;
static int mq_physics_calls;
static int mq_send_clients_calls;
static int mq_key_event_calls;
static int mq_input_commands_calls;
static int mq_cbuf_execute_calls;
static int mq_net_poll_calls;
static int mq_client_send_calls;
static int mq_screen_update_calls;
static int mq_sound_update_calls;
static int mq_decay_calls;
static int mq_cd_update_calls;
static int mq_init_calls;
static int mq_cbuf_insert_calls;
static int mq_shutdown_calls;
static int mq_memory_bytes;
static double mq_sys_time;
static FILE mq_file;
static qsocket_t mq_socket;
static char *mq_console_lines[] = {"status", "map start", NULL};

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
static int mq_vsprintf(char *destination, const char *format, va_list arguments)
{
    (void)arguments;
    mq_copy(destination, format);
    return mq_strlen(destination);
}
static int mq_equal(const char *left, const char *right)
{
    int index = 0;
    while (left[index] && right[index] && left[index] == right[index])
        index++;
    return left[index] == right[index];
}
static void *mq_memset(void *destination, int value, int length)
{
    byte *bytes = (byte *)destination;
    int index;
    for (index = 0; index < length; index++)
        bytes[index] = (byte)value;
    return destination;
}
static void *mq_malloc(int length)
{
    void *result;
    if (mq_hunk_used + length > (int)sizeof(mq_hunk))
        return NULL;
    result = mq_hunk + mq_hunk_used;
    mq_hunk_used += length;
    return result;
}
static int mq_rand(void) { return 4; }
static void mq_longjmp(void *environment, int value)
{
    (void)environment; (void)value;
    mq_longjmp_calls++;
}
static FILE *mq_fopen(const char *name, const char *mode)
{
    (void)name; (void)mode;
    mq_file_opens++;
    return &mq_file;
}
static int mq_fclose(FILE *file)
{
    (void)file;
    mq_file_closes++;
    return 0;
}
static int mq_printf(const char *format, ...)
{
    (void)format;
    return 0;
}

void Con_DPrintf(char *format, ...) { (void)format; }
void Con_Printf(char *format, ...) { (void)format; }
void Sys_Printf(char *format, ...) { (void)format; }
char *va(char *format, ...) { return format; }
void Sys_Error(char *format, ...) { (void)format; mq_sys_error_calls++; }
void SCR_EndLoadingPlaque(void) { mq_loading_end_calls++; }
void CL_NextDemo(void) { mq_nextdemo_calls++; }
void CL_Disconnect(void) { mq_disconnect_calls++; cls.state = ca_disconnected; }
void Host_ShutdownServer(qboolean crash);
void Host_InitCommands(void) { mq_init_commands++; }
int COM_CheckParm(char *name)
{
    int index;
    for (index = 1; index < com_argc; index++)
        if (mq_equal(com_argv[index], name))
            return index;
    return 0;
}
int Q_atoi(char *text)
{
    int sign = 1;
    int value = 0;
    if (*text == '-') { sign = -1; text++; }
    while (*text >= '0' && *text <= '9')
        value = value * 10 + (*text++ - '0');
    return value * sign;
}
void *Hunk_AllocName(int length, char *name)
{
    (void)name;
    return mq_malloc(length);
}
int Hunk_LowMark(void) { return mq_hunk_used; }
void Hunk_FreeToLowMark(int mark) { mq_free_mark = mark; mq_hunk_used = mark; }
void Cvar_RegisterVariable(cvar_t *value)
{
    mq_register_cvars++;
    value->value = (float)Q_atoi(value->string);
}
void Cvar_SetValue(char *name, float value)
{
    if (mq_equal(name, "deathmatch"))
        mq_cvar_deathmatch = value != 0;
}
void Key_WriteBindings(FILE *file) { (void)file; mq_key_writes++; }
void Cvar_WriteVariables(FILE *file) { (void)file; mq_cvar_writes++; }
void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    if (buffer->cursize < buffer->maxsize)
        buffer->data[buffer->cursize++] = (byte)value;
}
void MSG_WriteShort(sizebuf_t *buffer, int value)
{
    MSG_WriteByte(buffer, value & 255);
    MSG_WriteByte(buffer, (value >> 8) & 255);
}
void MSG_WriteString(sizebuf_t *buffer, char *text)
{
    while (*text)
        MSG_WriteByte(buffer, *text++);
    MSG_WriteByte(buffer, 0);
}
qboolean NET_CanSendMessage(qsocket_t *socket) { return socket != NULL; }
int NET_SendMessage(qsocket_t *socket, sizebuf_t *message)
{
    (void)socket; (void)message; mq_net_send_calls++; return 1;
}
int NET_GetMessage(qsocket_t *socket) { (void)socket; return 0; }
void NET_Close(qsocket_t *socket) { (void)socket; mq_net_close_calls++; }
int NET_SendToAll(sizebuf_t *message, double blocktime)
{
    (void)message; (void)blocktime; mq_send_to_all_calls++; return 0;
}
void PR_ExecuteProgram(int program) { (void)program; mq_execute_program_calls++; }
double Sys_FloatTime(void) { mq_sys_time += 0.01; return mq_sys_time; }
void SZ_Clear(sizebuf_t *buffer) { buffer->cursize = 0; buffer->overflowed = false; }
void D_FlushCaches(void) { mq_flush_calls++; }
void Mod_ClearAll(void) { mq_mod_clear_calls++; }
char *Sys_ConsoleInput(void) { return mq_console_lines[mq_console_input_index++]; }
void Cbuf_AddText(char *text) { mq_cbuf_add_calls++; mq_cbuf_added_chars += mq_strlen(text); }
void SV_ClearDatagram(void) { mq_clear_datagram_calls++; sv.datagram.cursize = 0; }
void SV_CheckForNewClients(void) { mq_check_clients_calls++; }
void SV_RunClients(void) { mq_run_clients_calls++; }
void SV_Physics(void) { mq_physics_calls++; sv.time += 0.02; }
void SV_SendClientMessages(void) { mq_send_clients_calls++; }
void Sys_SendKeyEvents(void) { mq_key_event_calls++; }
void IN_Commands(void) { mq_input_commands_calls++; }
void Cbuf_Execute(void) { mq_cbuf_execute_calls++; }
void NET_Poll(void) { mq_net_poll_calls++; }
void CL_SendCmd(void) { mq_client_send_calls++; }
void CL_ReadFromServer(void) { }
void SCR_UpdateScreen(void) { mq_screen_update_calls++; }
void S_Update(vec3_t origin, vec3_t forward, vec3_t right, vec3_t up)
{
    (void)origin; (void)forward; (void)right; (void)up; mq_sound_update_calls++;
}
void CL_DecayLights(void) { mq_decay_calls++; }
void CDAudio_Update(void) { mq_cd_update_calls++; }

void Memory_Init(void *base, int size) { (void)base; mq_memory_bytes = size; mq_init_calls++; }
void Cbuf_Init(void) { mq_init_calls++; }
void Cmd_Init(void) { mq_init_calls++; }
void V_Init(void) { mq_init_calls++; }
void Chase_Init(void) { mq_init_calls++; }
void COM_Init(char *basedir) { (void)basedir; mq_init_calls++; }
void W_LoadWadFile(char *name) { (void)name; mq_init_calls++; }
void Key_Init(void) { mq_init_calls++; }
void Con_Init(void) { mq_init_calls++; }
void M_Init(void) { mq_init_calls++; }
void PR_Init(void) { mq_init_calls++; }
void Mod_Init(void) { mq_init_calls++; }
void NET_Init(void) { mq_init_calls++; }
void SV_Init(void) { mq_init_calls++; }
void R_InitTextures(void) { mq_init_calls++; }
byte *COM_LoadHunkFile(char *name)
{
    (void)name; mq_init_calls++; return (byte *)mq_malloc(16384);
}
void VID_Init(byte *palette) { (void)palette; mq_init_calls++; }
void Draw_Init(void) { mq_init_calls++; }
void SCR_Init(void) { mq_init_calls++; }
void R_Init(void) { mq_init_calls++; }
void S_Init(void) { mq_init_calls++; }
void CDAudio_Init(void) { mq_init_calls++; }
void Sbar_Init(void) { mq_init_calls++; }
void CL_Init(void) { mq_init_calls++; }
void IN_Init(void) { mq_init_calls++; }
void Cbuf_InsertText(char *text) { (void)text; mq_cbuf_insert_calls++; }
int Sys_FileOpenRead(char *path, int *handle) { (void)path; *handle = -1; return -1; }
int Sys_FileOpenWrite(char *path) { (void)path; return 1; }
void Sys_FileRead(int handle, void *destination, int count)
{ (void)handle; mq_memset(destination, 0, count); }
void Sys_FileWrite(int handle, void *source, int count)
{ (void)handle; (void)source; (void)count; }
int Q_strlen(char *text) { return mq_strlen(text); }
void CDAudio_Shutdown(void) { mq_shutdown_calls++; }
void NET_Shutdown(void) { mq_shutdown_calls++; }
void S_Shutdown(void) { mq_shutdown_calls++; }
void IN_Shutdown(void) { mq_shutdown_calls++; }
void VID_Shutdown(void) { mq_shutdown_calls++; }

#define memset mq_memset
#define malloc mq_malloc
#define rand mq_rand
#define fopen mq_fopen
#define fclose mq_fclose
#define printf mq_printf
#define va_start(arguments,last) ((arguments) = NULL)
#define va_end(arguments) ((void)(arguments))
#define vsprintf mq_vsprintf
#define setjmp(environment) 0
#define longjmp(environment,value) mq_longjmp(&(environment),value)
/*__PINNED_HOST_SOURCE__*/
#undef memset
#undef malloc
#undef rand
#undef fopen
#undef fclose
#undef printf
#undef va_start
#undef va_end
#undef vsprintf
#undef setjmp
#undef longjmp

static void mq_reset(void)
{
    static client_t clients[MAX_SCOREBOARD];
    int index;
    mq_memset(&sv, 0, sizeof(sv));
    mq_memset(&cls, 0, sizeof(cls));
    mq_memset(&cl, 0, sizeof(cl));
    mq_memset(&mq_globals, 0, sizeof(mq_globals));
    mq_memset(clients, 0, sizeof(clients));
    mq_memset(mq_hunk, 0, sizeof(mq_hunk));
    mq_hunk_used = 0;
    svs.maxclients = 1;
    svs.maxclientslimit = MAX_SCOREBOARD;
    svs.clients = clients;
    for (index = 0; index < MAX_SCOREBOARD; index++) {
        clients[index].message.data = clients[index].msgbuf;
        clients[index].message.maxsize = sizeof(clients[index].msgbuf);
        clients[index].edict = &mq_edicts[index + 1];
    }
    sv.datagram.data = sv.datagram_buf;
    sv.datagram.maxsize = sizeof(sv.datagram_buf);
    cls.state = ca_disconnected;
    cls.demonum = -1;
    isDedicated = false;
    standard_quake = true;
    scr_disabled_for_loading = false;
    net_activeconnections = 0;
    key_dest = key_game;
    vcrFile = -1;
    mq_longjmp_calls = mq_sys_error_calls = mq_nextdemo_calls = 0;
    mq_disconnect_calls = mq_loading_end_calls = mq_shutdown_server_calls = 0;
    mq_register_cvars = mq_init_commands = mq_cvar_deathmatch = 0;
    mq_key_writes = mq_cvar_writes = mq_file_opens = mq_file_closes = 0;
    mq_net_close_calls = mq_net_send_calls = mq_send_to_all_calls = 0;
    mq_execute_program_calls = mq_flush_calls = mq_mod_clear_calls = mq_free_mark = 0;
    mq_console_input_index = mq_cbuf_add_calls = mq_cbuf_added_chars = 0;
    mq_clear_datagram_calls = mq_check_clients_calls = mq_run_clients_calls = 0;
    mq_physics_calls = mq_send_clients_calls = mq_key_event_calls = 0;
    mq_input_commands_calls = mq_cbuf_execute_calls = mq_net_poll_calls = 0;
    mq_client_send_calls = mq_screen_update_calls = mq_sound_update_calls = 0;
    mq_decay_calls = mq_cd_update_calls = mq_init_calls = mq_cbuf_insert_calls = 0;
    mq_shutdown_calls = mq_memory_bytes = 0;
    mq_sys_time = 0;
    host_initialized = false;
    host_time = 0;
    realtime = oldrealtime = host_frametime = 0;
    host_framecount = 0;
    host_hunklevel = 0;
    host_client = NULL;
    host_framerate.value = 0;
    host_speeds.value = 0;
    serverprofile.value = 0;
}
static void mq_emit(char *output, int capacity, const char *line)
{
    int used = mq_strlen(output);
    int length = mq_strlen(line);
    int index;
    if (used + length + 1 >= capacity)
        return;
    for (index = 0; index < length; index++)
        output[used + index] = line[index];
    output[used + length] = '\n';
    output[used + length + 1] = 0;
}

__declspec(dllexport) int host_oracle_jsonl(char *output, int capacity)
{
    char line[1024];
    char *single_args[] = {"quake"};
    char *listen_args[] = {"quake", "-listen", "99"};
    char *dedicated_args[] = {"quake", "-dedicated", "2"};
    quakeparms_t parms;
    client_t *first;
    client_t *second;
    qboolean filter_first;
    qboolean filter_second;
    int first_shutdown_calls;

    if (!output || capacity < 2)
        return -1;
    output[0] = 0;

    mq_reset();
    Host_EndGame("done");
    sprintf(line, "{\"function\":\"Host_EndGame\",\"case\":\"disconnect_abort\",\"server_active\":%s,\"demonum\":%i,\"abort\":%s}",
        sv.active ? "true" : "false", cls.demonum, mq_longjmp_calls == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = true;
    cls.demonum = 4;
    Host_Error("bad");
    sprintf(line, "{\"function\":\"Host_Error\",\"case\":\"disconnect_stopdemo_abort\",\"server_active\":%s,\"demonum\":%i,\"abort\":%s}",
        sv.active ? "true" : "false", cls.demonum, mq_longjmp_calls == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    com_argc = 3; com_argv = listen_args;
    Host_FindMaxClients();
    sprintf(line, "{\"function\":\"Host_FindMaxClients\",\"case\":\"listen_clamp\",\"maxclients\":%i,\"limit\":%i,\"dedicated\":%s,\"deathmatch\":%i}",
        svs.maxclients, svs.maxclientslimit, cls.state == ca_dedicated ? "true" : "false", mq_cvar_deathmatch);
    mq_emit(output, capacity, line);

    mq_reset();
    com_argc = 1; com_argv = single_args;
    Host_InitLocal();
    sprintf(line, "{\"function\":\"Host_InitLocal\",\"case\":\"registrations\",\"maxclients\":%i,\"deathmatch\":%i,\"host_time\":%g}",
        svs.maxclients, mq_cvar_deathmatch, host_time);
    mq_emit(output, capacity, line);

    mq_reset();
    Host_WriteConfiguration();
    sprintf(line, "{\"function\":\"Host_WriteConfiguration\",\"case\":\"uninitialized_skip\",\"wrote\":%s}",
        mq_file_opens == 0 ? "false" : "true");
    mq_emit(output, capacity, line);

    mq_reset();
    first = &svs.clients[0]; first->active = true; host_client = first;
    SV_ClientPrintf("hello");
    sprintf(line, "{\"function\":\"SV_ClientPrintf\",\"case\":\"print_message\",\"size\":%i,\"opcode\":%i,\"terminated\":%s}",
        first->message.cursize, first->message.data[0],
        first->message.data[first->message.cursize - 1] == 0 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    svs.maxclients = 3;
    svs.clients[0].active = svs.clients[0].spawned = true;
    svs.clients[1].active = true;
    svs.clients[2].active = svs.clients[2].spawned = true;
    SV_BroadcastPrintf("all");
    sprintf(line, "{\"function\":\"SV_BroadcastPrintf\",\"case\":\"active_spawned_only\",\"first\":%i,\"second\":%i,\"third\":%i}",
        svs.clients[0].message.cursize, svs.clients[1].message.cursize, svs.clients[2].message.cursize);
    mq_emit(output, capacity, line);

    mq_reset();
    first = &svs.clients[0]; first->active = true; host_client = first;
    Host_ClientCommands("echo hi");
    sprintf(line, "{\"function\":\"Host_ClientCommands\",\"case\":\"stufftext_message\",\"size\":%i,\"opcode\":%i,\"terminated\":%s}",
        first->message.cursize, first->message.data[0],
        first->message.data[first->message.cursize - 1] == 0 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    svs.maxclients = 2; net_activeconnections = 2;
    first = &svs.clients[0]; second = &svs.clients[1];
    first->active = true; first->spawned = true; first->netconnection = &mq_socket; mq_copy(first->name, "one");
    second->active = true; second->spawned = true; second->netconnection = &mq_socket;
    host_client = first;
    SV_DropClient(true);
    sprintf(line, "{\"function\":\"SV_DropClient\",\"case\":\"crash_drop\",\"active\":%s,\"name_empty\":%s,\"old_frags\":%i,\"peer_notice\":%i}",
        first->active ? "true" : "false", first->name[0] == 0 ? "true" : "false",
        first->old_frags, second->message.cursize);
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = true; svs.maxclients = 1; net_activeconnections = 1;
    first = &svs.clients[0]; first->active = true; first->netconnection = &mq_socket; host_client = first;
    Host_ShutdownServer(true);
    sprintf(line, "{\"function\":\"Host_ShutdownServer\",\"case\":\"active_crash\",\"active\":%s,\"clients_cleared\":%s}",
        sv.active ? "true" : "false",
        svs.clients[0].active ? "false" : "true");
    mq_emit(output, capacity, line);

    mq_reset();
    host_hunklevel = 7; cls.signon = 4; sv.active = true; cl.marker = 9;
    Host_ClearMemory();
    sprintf(line, "{\"function\":\"Host_ClearMemory\",\"case\":\"clear_runtime\",\"signon\":%i,\"server_active\":%s,\"client_cleared\":%s}",
        cls.signon, sv.active ? "true" : "false", cl.marker == 0 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    filter_first = Host_FilterTime(0.005f);
    filter_second = Host_FilterTime(0.020f);
    sprintf(line, "{\"function\":\"Host_FilterTime\",\"case\":\"filter_then_accept\",\"first\":%s,\"second\":%s,\"realtime_ms\":%i,\"old_ms\":%i,\"frametime_ms\":%i}",
        filter_first ? "true" : "false", filter_second ? "true" : "false",
        (int)(realtime * 1000 + 0.5), (int)(oldrealtime * 1000 + 0.5),
        (int)(host_frametime * 1000 + 0.5));
    mq_emit(output, capacity, line);

    mq_reset();
    Host_GetConsoleCommands();
    sprintf(line, "{\"function\":\"Host_GetConsoleCommands\",\"case\":\"two_lines\",\"commands\":%i}",
        mq_cbuf_add_calls);
    mq_emit(output, capacity, line);

    mq_reset();
    sv.active = true; svs.maxclients = 1; sv.paused = false; key_dest = key_game; host_frametime = 0.02;
    Host_ServerFrame();
    sprintf(line, "{\"function\":\"Host_ServerFrame\",\"case\":\"singleplayer_game\",\"datagram_cleared\":%s,\"server_time_ms\":%i,\"simulated\":%i,\"frametime_ms\":%i}",
        sv.datagram.cursize == 0 ? "true" : "false", (int)(sv.time * 1000), mq_physics_calls,
        (int)(pr_global_struct->frametime * 1000));
    mq_emit(output, capacity, line);

    mq_reset();
    realtime = oldrealtime = 0; sv.active = true; svs.maxclients = 1;
    cls.state = ca_connected; cls.signon = SIGNONS;
    _Host_Frame(0.02f);
    sprintf(line, "{\"function\":\"_Host_Frame\",\"case\":\"active_connected\",\"framecount\":%i,\"server_advanced\":%s,\"screen\":%s,\"audio\":%s,\"host_delta_ms\":%i}",
        host_framecount, mq_physics_calls == 1 ? "true" : "false",
        mq_screen_update_calls == 1 ? "true" : "false",
        mq_sound_update_calls == 1 ? "true" : "false", (int)(host_time * 1000 + 0.5));
    mq_emit(output, capacity, line);

    mq_reset();
    realtime = oldrealtime = 0; sv.active = true; svs.maxclients = 1;
    cls.state = ca_connected; cls.signon = SIGNONS;
    Host_Frame(0.02f);
    sprintf(line, "{\"function\":\"Host_Frame\",\"case\":\"unprofiled\",\"framecount\":%i,\"server\":%i,\"screen\":%i}",
        host_framecount, mq_physics_calls, mq_screen_update_calls);
    mq_emit(output, capacity, line);

    mq_reset();
    com_argc = 1; com_argv = single_args;
    parms.basedir = "."; parms.argc = 1; parms.argv = single_args;
    parms.membase = mq_hunk; parms.memsize = sizeof(mq_hunk);
    Host_InitVCR(&parms);
    sprintf(line, "{\"function\":\"Host_InitVCR\",\"case\":\"no_switch\",\"accepted\":%s}",
        vcrFile == -1 && parms.argc == 1 ? "true" : "false");
    mq_emit(output, capacity, line);

    mq_reset();
    com_argc = 3; com_argv = dedicated_args; isDedicated = true;
    parms.basedir = "."; parms.argc = 3; parms.argv = dedicated_args;
    parms.membase = mq_hunk; parms.memsize = MINIMUM_MEMORY;
    Host_Init(&parms);
    sprintf(line, "{\"function\":\"Host_Init\",\"case\":\"dedicated\",\"initialized\":%s,\"maxclients\":%i,\"host_time\":%g}",
        host_initialized ? "true" : "false", svs.maxclients, host_time);
    mq_emit(output, capacity, line);

    mq_reset();
    host_initialized = true; cls.state = ca_disconnected;
    Host_Shutdown();
    first_shutdown_calls = mq_shutdown_calls;
    Host_Shutdown();
    sprintf(line, "{\"function\":\"Host_Shutdown\",\"case\":\"once_only\",\"first_effect\":%s,\"recursive_ignored\":%s}",
        scr_disabled_for_loading ? "true" : "false",
        mq_shutdown_calls == first_shutdown_calls ? "true" : "false");
    mq_emit(output, capacity, line);

    return mq_strlen(output);
}
