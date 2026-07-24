#include "net_main_oracle_stubs.h"

int _fltused = 0;
int com_argc;
char **com_argv;
int net_numdrivers;
net_driver_t net_drivers[4];
server_static_t svs;
server_t sv;
client_static_t cls;
client_t *host_client;
double host_time;

static double fake_time;
static int fatal_mode;
static int sys_errors;
static int print_count;
static int cbuf_count;
static int cvar_set_count;
static int cvar_register_count;
static int command_count;
static int hunk_count;
static int sz_count;
static int close_file_count;
static int config_port_count;
static int config_modem_count;
static int init_calls[4];
static int listen_calls[4];
static int listen_values[4];
static int search_send_calls[4];
static int search_poll_calls[4];
static int connect_calls[4];
static int check_calls[4];
static int close_calls[4];
static int get_calls[4];
static int send_calls[4];
static int unreliable_calls[4];
static int can_send_calls[4];
static int shutdown_calls[4];
static int init_results[4];
static int get_results[4];
static int send_results[4];
static int unreliable_results[4];
static int can_send_results[4];
static qsocket_t *connect_results[4];
static qsocket_t *check_results[4];
static char last_connect_host[NET_NAMELEN];
static char last_cbuf[128];
static char last_cvar_name[32];
static char last_cvar_value[32];
static int poll_order;
static qsocket_t socket_pool[16];
static int socket_pool_used;
static byte message_storage[NET_MAXMESSAGE];
static char *command_args[8];
static int command_argc;
static char arg0[] = "miniquake";
static char arg_listen[] = "-listen";
static char arg_port[] = "-port";
static char arg_27500[] = "27500";
static char arg_listen_cmd[] = "listen";
static char arg_one[] = "1";
static char arg_maxplayers[] = "maxplayers";
static char arg_five[] = "5";
static char arg_port_cmd[] = "port";
static char arg_badport[] = "70000";
static char *init_argv[] = {arg0, arg_port, arg_27500, arg_listen};
static char *missing_port_argv[] = {arg0, arg_port};

extern qsocket_t *net_activeSockets;
extern qsocket_t *net_freeSockets;
extern int net_numsockets;
extern qboolean serialAvailable;
extern qboolean ipxAvailable;
extern qboolean tcpipAvailable;
extern int net_hostport;
extern int DEFAULTnet_hostport;
extern char my_ipx_address[NET_NAMELEN];
extern char my_tcpip_address[NET_NAMELEN];
extern qboolean slistInProgress;
extern qboolean slistSilent;
extern qboolean slistLocal;
extern sizebuf_t net_message;
extern int net_activeconnections;
extern int messagesSent;
extern int messagesReceived;
extern int unreliableMessagesSent;
extern int unreliableMessagesReceived;
extern cvar_t net_messagetimeout;
extern qboolean configRestored;
extern cvar_t config_com_port;
extern cvar_t config_com_irq;
extern cvar_t config_com_baud;
extern cvar_t config_com_modem;
extern cvar_t config_modem_dialtype;
extern cvar_t config_modem_clear;
extern cvar_t config_modem_init;
extern cvar_t config_modem_hangup;
extern int vcrFile;
extern qboolean recording;
extern int net_driverlevel;
extern double net_time;
extern int hostCacheCount;
extern hostcache_t hostcache[HOSTCACHESIZE];
extern void (*SetComPortConfig)(int, int, int, int, qboolean);
extern void (*SetModemConfig)(int, char *, char *, char *, char *);

double SetNetTime(void);
qsocket_t *NET_NewQSocket(void);
void NET_FreeQSocket(qsocket_t *);
void NET_Slist_f(void);
qsocket_t *NET_Connect(char *);
qsocket_t *NET_CheckNewConnections(void);
void NET_Close(qsocket_t *);
int NET_GetMessage(qsocket_t *);
int NET_SendMessage(qsocket_t *, sizebuf_t *);
int NET_SendUnreliableMessage(qsocket_t *, sizebuf_t *);
qboolean NET_CanSendMessage(qsocket_t *);
int NET_SendToAll(sizebuf_t *, int);
void NET_Init(void);
void NET_Shutdown(void);
void NET_Poll(void);
void SchedulePollProcedure(PollProcedure *, double);

void mq_NET_Listen_f(void);
void mq_MaxPlayers_f(void);
void mq_NET_Port_f(void);
void mq_PrintSlistHeader(void);
void mq_PrintSlist(void);
void mq_PrintSlistTrailer(void);
void mq_Slist_Send(void);
void mq_Slist_Poll(void);
int mq_listening(void);
void mq_set_listening(int);
int mq_slist_last_shown(void);
void mq_set_slist_start(double);
void mq_clear_poll_list(void);
int mq_poll_count(void);

static int text_equal(const char *left, const char *right)
{
    while (*left && *left == *right)
    {
        ++left;
        ++right;
    }
    return *left == *right;
}

static void copy_text(char *destination, const char *source, int capacity)
{
    int index = 0;
    if (!source)
    {
        destination[0] = 0;
        return;
    }
    while (index + 1 < capacity && source[index])
    {
        destination[index] = source[index];
        ++index;
    }
    destination[index] = 0;
}

static float parse_float(const char *text)
{
    float result = 0;
    float scale = 0.1f;
    int sign = 1;
    if (*text == '-')
    {
        sign = -1;
        ++text;
    }
    while (*text >= '0' && *text <= '9')
        result = result * 10 + (*text++ - '0');
    if (*text == '.')
    {
        ++text;
        while (*text >= '0' && *text <= '9')
        {
            result += (*text++ - '0') * scale;
            scale *= 0.1f;
        }
    }
    return result * sign;
}

double Sys_FloatTime(void)
{
    return fake_time;
}

void Sys_Error(char *format, ...)
{
    (void)format;
    ++sys_errors;
    if (fatal_mode)
    {
        volatile int *invalid = (int *)0;
        *invalid = 1;
    }
}

void Con_Printf(char *format, ...)
{
    (void)format;
    ++print_count;
}

void Con_DPrintf(char *format, ...)
{
    (void)format;
    ++print_count;
}

void *Hunk_AllocName(int size, char *name)
{
    qsocket_t *result;
    (void)name;
    ++hunk_count;
    if (size != (int)sizeof(qsocket_t) || socket_pool_used >= 16)
        return NULL;
    result = &socket_pool[socket_pool_used++];
    memset(result, 0, sizeof(*result));
    return result;
}

void SZ_Alloc(sizebuf_t *buffer, int size)
{
    ++sz_count;
    buffer->data = message_storage;
    buffer->maxsize = size;
    buffer->cursize = 0;
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    ++cvar_register_count;
    variable->value = parse_float(variable->string);
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    ++command_count;
}

int COM_CheckParm(char *name)
{
    int index;
    for (index = 1; index < com_argc; ++index)
        if (text_equal(com_argv[index], name))
            return index;
    return 0;
}

int Cmd_Argc(void)
{
    return command_argc;
}

char *Cmd_Argv(int index)
{
    if (index < 0 || index >= command_argc)
        return "";
    return command_args[index];
}

int Q_atoi(char *text)
{
    int result = 0;
    int sign = 1;
    if (*text == '-')
    {
        sign = -1;
        ++text;
    }
    while (*text >= '0' && *text <= '9')
        result = result * 10 + (*text++ - '0');
    return result * sign;
}

char *Q_strcpy(char *destination, const char *source)
{
    char *result = destination;
    while ((*destination++ = *source++) != 0)
    {
    }
    return result;
}

int Q_strcasecmp(const char *left, const char *right)
{
    int a;
    int b;
    while (*left || *right)
    {
        a = *left++;
        b = *right++;
        if (a >= 'A' && a <= 'Z')
            a += 'a' - 'A';
        if (b >= 'A' && b <= 'Z')
            b += 'a' - 'A';
        if (a != b)
            return a - b;
    }
    return 0;
}

void Cbuf_AddText(char *text)
{
    ++cbuf_count;
    copy_text(last_cbuf, text, sizeof(last_cbuf));
}

void Cvar_Set(char *name, char *value)
{
    ++cvar_set_count;
    copy_text(last_cvar_name, name, sizeof(last_cvar_name));
    copy_text(last_cvar_value, value, sizeof(last_cvar_value));
}

int Sys_FileWrite(int handle, void *data, int count)
{
    (void)handle;
    (void)data;
    return count;
}

void Sys_FileClose(int handle)
{
    (void)handle;
    ++close_file_count;
}

int VCR_Init(void)
{
    return 0;
}

void PrintStats(qsocket_t *socket)
{
    (void)socket;
}

static int driver_init(void)
{
    ++init_calls[net_driverlevel];
    return init_results[net_driverlevel];
}

static void driver_listen(qboolean enabled)
{
    ++listen_calls[net_driverlevel];
    listen_values[net_driverlevel] = enabled;
}

static void driver_search(qboolean transmit)
{
    if (transmit)
        ++search_send_calls[net_driverlevel];
    else
        ++search_poll_calls[net_driverlevel];
}

static qsocket_t *driver_connect(char *host)
{
    ++connect_calls[net_driverlevel];
    copy_text(last_connect_host, host, sizeof(last_connect_host));
    return connect_results[net_driverlevel];
}

static qsocket_t *driver_check(void)
{
    ++check_calls[net_driverlevel];
    return check_results[net_driverlevel];
}

static void driver_close(qsocket_t *socket)
{
    (void)socket;
    ++close_calls[net_driverlevel];
}

static int driver_get(qsocket_t *socket)
{
    (void)socket;
    ++get_calls[net_driverlevel];
    return get_results[net_driverlevel];
}

static int driver_send(qsocket_t *socket, sizebuf_t *data)
{
    (void)socket;
    (void)data;
    ++send_calls[net_driverlevel];
    return send_results[net_driverlevel];
}

static int driver_unreliable(qsocket_t *socket, sizebuf_t *data)
{
    (void)socket;
    (void)data;
    ++unreliable_calls[net_driverlevel];
    return unreliable_results[net_driverlevel];
}

static qboolean driver_can_send(qsocket_t *socket)
{
    (void)socket;
    ++can_send_calls[net_driverlevel];
    return can_send_results[net_driverlevel];
}

static void driver_shutdown(void)
{
    ++shutdown_calls[net_driverlevel];
}

static void configure_port(int portNumber, int port, int irq, int baud, qboolean modem)
{
    (void)portNumber;
    (void)port;
    (void)irq;
    (void)baud;
    (void)modem;
    ++config_port_count;
}

static void configure_modem(int portNumber, char *dial, char *clear, char *init, char *hangup)
{
    (void)portNumber;
    (void)dial;
    (void)clear;
    (void)init;
    (void)hangup;
    ++config_modem_count;
}

static void poll_callback(void *argument)
{
    poll_order = poll_order * 10 + (int)(long long)argument;
}

static void reset_driver_counters(void)
{
    memset(init_calls, 0, sizeof(init_calls));
    memset(listen_calls, 0, sizeof(listen_calls));
    memset(listen_values, 0, sizeof(listen_values));
    memset(search_send_calls, 0, sizeof(search_send_calls));
    memset(search_poll_calls, 0, sizeof(search_poll_calls));
    memset(connect_calls, 0, sizeof(connect_calls));
    memset(check_calls, 0, sizeof(check_calls));
    memset(close_calls, 0, sizeof(close_calls));
    memset(get_calls, 0, sizeof(get_calls));
    memset(send_calls, 0, sizeof(send_calls));
    memset(unreliable_calls, 0, sizeof(unreliable_calls));
    memset(can_send_calls, 0, sizeof(can_send_calls));
    memset(shutdown_calls, 0, sizeof(shutdown_calls));
    memset(connect_results, 0, sizeof(connect_results));
    memset(check_results, 0, sizeof(check_results));
    for (net_driverlevel = 0; net_driverlevel < 4; ++net_driverlevel)
    {
        init_results[net_driverlevel] = net_driverlevel + 10;
        get_results[net_driverlevel] = 0;
        send_results[net_driverlevel] = 1;
        unreliable_results[net_driverlevel] = 1;
        can_send_results[net_driverlevel] = 1;
    }
}

static void reset_all(void)
{
    int index;
    memset(socket_pool, 0, sizeof(socket_pool));
    memset(message_storage, 0, sizeof(message_storage));
    memset(hostcache, 0, sizeof(hostcache));
    memset(net_drivers, 0, sizeof(net_drivers));
    memset(&net_message, 0, sizeof(net_message));
    socket_pool_used = 0;
    fake_time = 10.0;
    host_time = 10.0;
    fatal_mode = 0;
    sys_errors = 0;
    print_count = 0;
    cbuf_count = 0;
    cvar_set_count = 0;
    cvar_register_count = 0;
    command_count = 0;
    hunk_count = 0;
    sz_count = 0;
    close_file_count = 0;
    config_port_count = 0;
    config_modem_count = 0;
    last_connect_host[0] = 0;
    last_cbuf[0] = 0;
    last_cvar_name[0] = 0;
    last_cvar_value[0] = 0;
    poll_order = 0;
    command_argc = 0;
    com_argc = 1;
    com_argv = init_argv;
    net_activeSockets = NULL;
    net_freeSockets = NULL;
    net_numsockets = 0;
    net_activeconnections = 0;
    net_driverlevel = 0;
    net_time = 0;
    DEFAULTnet_hostport = 26000;
    net_hostport = 26000;
    serialAvailable = false;
    ipxAvailable = false;
    tcpipAvailable = false;
    my_ipx_address[0] = 0;
    my_tcpip_address[0] = 0;
    slistInProgress = false;
    slistSilent = false;
    slistLocal = true;
    hostCacheCount = 0;
    messagesSent = 0;
    messagesReceived = 0;
    unreliableMessagesSent = 0;
    unreliableMessagesReceived = 0;
    net_messagetimeout.value = 300.0f;
    configRestored = false;
    config_com_port.value = 0x3f8;
    config_com_irq.value = 4;
    config_com_baud.value = 57600;
    config_com_modem.value = 1;
    recording = false;
    vcrFile = -1;
    svs.maxclients = 2;
    svs.maxclientslimit = 4;
    svs.clients = NULL;
    sv.active = false;
    cls.state = 0;
    host_client = NULL;
    mq_set_listening(false);
    mq_clear_poll_list();
    reset_driver_counters();
    net_numdrivers = 2;
    for (index = 0; index < net_numdrivers; ++index)
    {
        net_drivers[index].initialized = true;
        net_drivers[index].Init = driver_init;
        net_drivers[index].Listen = driver_listen;
        net_drivers[index].SearchForHosts = driver_search;
        net_drivers[index].Connect = driver_connect;
        net_drivers[index].CheckNewConnections = driver_check;
        net_drivers[index].Close = driver_close;
        net_drivers[index].QGetMessage = driver_get;
        net_drivers[index].QSendMessage = driver_send;
        net_drivers[index].SendUnreliableMessage = driver_unreliable;
        net_drivers[index].CanSendMessage = driver_can_send;
        net_drivers[index].Shutdown = driver_shutdown;
    }
    SetComPortConfig = configure_port;
    SetModemConfig = configure_modem;
}

static void setup_socket_pool(int count)
{
    int index;
    net_activeSockets = NULL;
    net_freeSockets = NULL;
    net_numsockets = count;
    for (index = count - 1; index >= 0; --index)
    {
        memset(&socket_pool[index], 0, sizeof(socket_pool[index]));
        socket_pool[index].disconnected = true;
        socket_pool[index].next = net_freeSockets;
        net_freeSockets = &socket_pool[index];
    }
    socket_pool_used = count;
}

static int socket_count(qsocket_t *head)
{
    int count = 0;
    while (head)
    {
        ++count;
        head = head->next;
        if (count > 64)
            return -1;
    }
    return count;
}

static void set_command(int count, char *a0, char *a1)
{
    command_argc = count;
    command_args[0] = a0;
    command_args[1] = a1;
}

static char *emit(
    char *output,
    const char *function,
    const char *case_name,
    int result,
    int index,
    float value,
    int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"index\":%d,\"value\":%.9g,\"count\":%d}\n",
        function,
        case_name,
        result,
        index,
        value,
        count);
    return output;
}

__declspec(dllexport) int __cdecl net_main_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    qsocket_t *socket;
    qsocket_t *second_socket;
    sizebuf_t data;
    client_t clients[2];
    PollProcedure first;
    PollProcedure second;
    PollProcedure third;
    int result;
    (void)capacity;

    reset_all();
    fake_time = 12.5;
    cursor = emit(cursor, "SetNetTime", "clock", SetNetTime() == 12.5 && net_time == 12.5, 0, 0, 1);

    reset_all();
    setup_socket_pool(2);
    net_driverlevel = 1;
    fake_time = 20;
    socket = NET_NewQSocket();
    cursor = emit(cursor, "NET_NewQSocket", "initialize", socket != NULL && socket->canSend && !socket->disconnected && socket->connecttime == net_time, socket_count(net_activeSockets), 0, socket_count(net_freeSockets));

    NET_FreeQSocket(socket);
    cursor = emit(cursor, "NET_FreeQSocket", "recycle", socket->disconnected, socket_count(net_activeSockets), 0, socket_count(net_freeSockets));

    reset_all();
    set_command(2, arg_listen_cmd, arg_one);
    mq_NET_Listen_f();
    cursor = emit(cursor, "NET_Listen_f", "enable", mq_listening(), listen_calls[0] + listen_calls[1] == 2, 0, listen_values[1] == true);
    set_command(1, arg_listen_cmd, NULL);
    print_count = 0;
    mq_NET_Listen_f();
    cursor = emit(cursor, "NET_Listen_f", "query", mq_listening(), print_count == 1, 0, listen_calls[0] + listen_calls[1] == 2);

    reset_all();
    set_command(2, arg_maxplayers, arg_five);
    mq_MaxPlayers_f();
    cursor = emit(cursor, "MaxPlayers_f", "clamp_enable_listen", svs.maxclients, cbuf_count, cvar_set_count, text_equal(last_cvar_value, "1"));
    sv.active = true;
    print_count = 0;
    mq_MaxPlayers_f();
    cursor = emit(cursor, "MaxPlayers_f", "active_server", svs.maxclients, print_count, 0, cbuf_count);

    reset_all();
    mq_set_listening(true);
    set_command(2, arg_port_cmd, arg_27500);
    mq_NET_Port_f();
    cursor = emit(cursor, "NET_Port_f", "change_while_listening", net_hostport, DEFAULTnet_hostport, 0, cbuf_count);
    set_command(2, arg_port_cmd, arg_badport);
    print_count = 0;
    mq_NET_Port_f();
    cursor = emit(cursor, "NET_Port_f", "reject_range", net_hostport, print_count, 0, cbuf_count);

    reset_all();
    print_count = 0;
    mq_PrintSlistHeader();
    cursor = emit(cursor, "PrintSlistHeader", "header", mq_slist_last_shown() == 0, print_count, 0, 2);

    hostCacheCount = 2;
    Q_strcpy(hostcache[0].name, "Alpha");
    Q_strcpy(hostcache[0].map, "start");
    hostcache[0].users = 1;
    hostcache[0].maxusers = 4;
    Q_strcpy(hostcache[1].name, "Beta");
    Q_strcpy(hostcache[1].map, "e1m1");
    print_count = 0;
    mq_PrintSlist();
    cursor = emit(cursor, "PrintSlist", "new_entries", mq_slist_last_shown(), print_count, 0, hostCacheCount);

    print_count = 0;
    mq_PrintSlistTrailer();
    cursor = emit(cursor, "PrintSlistTrailer", "nonempty", 1, print_count, 0, hostCacheCount);
    hostCacheCount = 0;
    print_count = 0;
    mq_PrintSlistTrailer();
    cursor = emit(cursor, "PrintSlistTrailer", "empty", 1, print_count, 0, hostCacheCount);

    reset_all();
    NET_Slist_f();
    cursor = emit(cursor, "NET_Slist_f", "start", slistInProgress, mq_poll_count(), print_count, hostCacheCount);

    reset_all();
    NET_Slist_f();
    mq_clear_poll_list();
    mq_Slist_Send();
    cursor = emit(cursor, "Slist_Send", "broadcast", search_send_calls[0] + search_send_calls[1] == 2, mq_poll_count() == 1, 0, 1);

    reset_all();
    NET_Slist_f();
    mq_clear_poll_list();
    fake_time = 12.0;
    mq_Slist_Poll();
    cursor = emit(cursor, "Slist_Poll", "finish", !slistInProgress && !slistSilent && slistLocal, search_poll_calls[0] + search_poll_calls[1] == 2, 0, print_count > 0);

    reset_all();
    setup_socket_pool(2);
    hostCacheCount = 1;
    Q_strcpy(hostcache[0].name, "Friendly");
    Q_strcpy(hostcache[0].cname, "10.0.0.1:26000");
    connect_results[1] = &socket_pool[0];
    socket = NET_Connect("friendly");
    result = socket == &socket_pool[0] && text_equal(last_connect_host, "10.0.0.1:26000");
    reset_all();
    setup_socket_pool(2);
    connect_results[0] = &socket_pool[1];
    second_socket = NET_Connect("local");
    cursor = emit(cursor, "NET_Connect", "cache_and_local", result && second_socket == &socket_pool[1], connect_calls[0], 0, connect_calls[1]);

    reset_all();
    setup_socket_pool(2);
    mq_set_listening(true);
    check_results[1] = &socket_pool[0];
    socket = NET_CheckNewConnections();
    cursor = emit(cursor, "NET_CheckNewConnections", "second_driver", socket == &socket_pool[0], check_calls[0] + check_calls[1] == 2, 0, net_driverlevel == 1);

    reset_all();
    setup_socket_pool(2);
    net_driverlevel = 1;
    socket = NET_NewQSocket();
    NET_Close(socket);
    cursor = emit(cursor, "NET_Close", "driver_and_recycle", socket->disconnected, close_calls[1], 0, socket_count(net_freeSockets));

    reset_all();
    setup_socket_pool(2);
    net_driverlevel = 1;
    socket = NET_NewQSocket();
    get_results[1] = 1;
    fake_time = 25;
    result = NET_GetMessage(socket);
    second_socket = socket;
    get_results[1] = 0;
    socket->lastMessageTime = 0;
    fake_time = 301;
    cursor = emit(cursor, "NET_GetMessage", "receive_then_timeout", result, messagesReceived, (float)second_socket->lastMessageTime, NET_GetMessage(socket) == -1 && socket->disconnected);

    reset_all();
    setup_socket_pool(2);
    net_driverlevel = 1;
    socket = NET_NewQSocket();
    memset(&data, 0, sizeof(data));
    send_results[1] = 1;
    result = NET_SendMessage(socket, &data);
    cursor = emit(cursor, "NET_SendMessage", "reliable", result, messagesSent, 0, send_calls[1]);

    unreliable_results[1] = 1;
    result = NET_SendUnreliableMessage(socket, &data);
    cursor = emit(cursor, "NET_SendUnreliableMessage", "unreliable", result, unreliableMessagesSent, 0, unreliable_calls[1]);

    can_send_results[1] = 1;
    result = NET_CanSendMessage(socket);
    cursor = emit(cursor, "NET_CanSendMessage", "driver", result, can_send_calls[1], 0, socket->disconnected);

    reset_all();
    setup_socket_pool(3);
    net_driverlevel = 0;
    socket = NET_NewQSocket();
    net_driverlevel = 1;
    second_socket = NET_NewQSocket();
    clients[0].active = true;
    clients[0].netconnection = socket;
    clients[1].active = true;
    clients[1].netconnection = second_socket;
    svs.maxclients = 2;
    svs.clients = clients;
    send_results[0] = send_results[1] = 1;
    can_send_results[1] = 1;
    result = NET_SendToAll(&data, -1);
    cursor = emit(cursor, "NET_SendToAll", "loop_and_remote", result, send_calls[0] + send_calls[1], 0, can_send_calls[1]);

    reset_all();
    com_argc = 3;
    com_argv = init_argv;
    NET_Init();
    cursor = emit(cursor, "NET_Init", "port_no_listen", net_numsockets, net_hostport, cvar_register_count, command_count + listen_calls[0] + listen_calls[1]);

    net_driverlevel = 1;
    socket = NET_NewQSocket();
    NET_Shutdown();
    cursor = emit(cursor, "NET_Shutdown", "close_all", socket->disconnected && net_activeSockets == NULL, shutdown_calls[0] + shutdown_calls[1] == 2, 0, close_calls[1] == 1);

    reset_all();
    serialAvailable = true;
    first.next = NULL;
    first.nextTime = 0;
    first.procedure = (void (*)())poll_callback;
    first.arg = (void *)(long long)7;
    SchedulePollProcedure(&first, 0);
    NET_Poll();
    cursor = emit(cursor, "NET_Poll", "restore_and_execute", poll_order, mq_poll_count(), 0, 1);

    reset_all();
    first.next = second.next = third.next = NULL;
    first.procedure = second.procedure = third.procedure = (void (*)())poll_callback;
    first.arg = (void *)(long long)3;
    second.arg = (void *)(long long)1;
    third.arg = (void *)(long long)2;
    SchedulePollProcedure(&first, 0.3);
    SchedulePollProcedure(&second, 0.1);
    SchedulePollProcedure(&third, 0.2);
    fake_time = 10.15;
    NET_Poll();
    fake_time = 10.25;
    NET_Poll();
    fake_time = 10.35;
    NET_Poll();
    cursor = emit(cursor, "SchedulePollProcedure", "sorted", poll_order, mq_poll_count(), 0, 3);

    *cursor = 0;
    return (int)(cursor - output);
}

__declspec(dllexport) int __cdecl net_main_error_case(int mode)
{
    qsocket_t inactive;
    reset_all();
    fatal_mode = 1;
    if (mode == 0)
    {
        memset(&inactive, 0, sizeof(inactive));
        inactive.disconnected = false;
        NET_FreeQSocket(&inactive);
    }
    else
    {
        com_argc = 2;
        com_argv = missing_port_argv;
        NET_Init();
    }
    return 0;
}
