#include "net_loop_oracle_stubs.h"

extern qsocket_t *loop_client;
extern qsocket_t *loop_server;
extern qboolean localconnectpending;

int _fltused = 0;
client_static_t cls;
server_t sv;
server_static_t svs;
cvar_t hostname = {"hostname", "UNNAMED", 0, 0, 0.0f, NULL};
int hostCacheCount;
hostcache_t hostcache[HOSTCACHESIZE];
int net_activeconnections;
int net_driverlevel;
static byte net_message_data[NET_MAXMESSAGE];
sizebuf_t net_message = {false, false, net_message_data, NET_MAXMESSAGE, 0};

static qsocket_t sockets[2];
static int socket_count;
static sizebuf_t fixture_message;
static byte fixture_message_data[64];
static int sys_error_calls;

static void clear_socket(qsocket_t *socket)
{
    int index;
    for (index = 0; index < 64; index++)
        socket->address[index] = 0;
    socket->receiveMessageLength = 0;
    socket->sendMessageLength = 0;
    socket->canSend = true;
    socket->driverdata = NULL;
    for (index = 0; index < NET_MAXMESSAGE; index++)
        socket->receiveMessage[index] = 0;
}

qsocket_t *NET_NewQSocket(void)
{
    if (socket_count >= 2)
        return NULL;
    clear_socket(&sockets[socket_count]);
    return &sockets[socket_count++];
}

int Q_strcmp(const char *first, const char *second)
{
    while (*first && *first == *second)
    {
        first++;
        second++;
    }
    return (unsigned char)*first - (unsigned char)*second;
}

void Q_strcpy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
    {
    }
}

void Q_memcpy(void *destination, const void *source, int count)
{
    byte *out = (byte *)destination;
    const byte *in = (const byte *)source;
    int index;
    for (index = 0; index < count; index++)
        out[index] = in[index];
}

void SZ_Clear(sizebuf_t *buffer)
{
    buffer->cursize = 0;
}

void SZ_Write(sizebuf_t *buffer, const void *data, int length)
{
    Q_memcpy(buffer->data + buffer->cursize, data, length);
    buffer->cursize += length;
}

void Con_Printf(char *format, ...)
{
    (void)format;
}

void Sys_Error(char *format, ...)
{
    (void)format;
    sys_error_calls++;
}

void loop_fixture_reset(void)
{
    int index;
    socket_count = 0;
    loop_client = NULL;
    loop_server = NULL;
    localconnectpending = false;
    hostCacheCount = 0;
    net_message.cursize = 0;
    sys_error_calls = 0;
    cls.state = 0;
    sv.active = true;
    Q_strcpy(sv.name, "e1m1");
    hostname.string = "UNNAMED";
    net_activeconnections = 2;
    svs.maxclients = 4;
    net_driverlevel = 7;
    for (index = 0; index < 64; index++)
        fixture_message_data[index] = 0;
    fixture_message.data = fixture_message_data;
    fixture_message.maxsize = 64;
    fixture_message.cursize = 0;
    fixture_message.allowoverflow = false;
    fixture_message.overflowed = false;
}

void loop_set_dedicated(int dedicated)
{
    cls.state = dedicated ? ca_dedicated : 0;
}

void loop_set_hostname(char *value)
{
    hostname.string = value;
}

char *loop_host_name(void) { return hostcache[0].name; }
char *loop_host_map(void) { return hostcache[0].map; }
char *loop_host_cname(void) { return hostcache[0].cname; }
int loop_host_users(void) { return hostcache[0].users; }
int loop_host_maxusers(void) { return hostcache[0].maxusers; }
int loop_host_driver(void) { return hostcache[0].driver; }

sizebuf_t *loop_fixture_message(byte first, byte second, byte third)
{
    fixture_message_data[0] = first;
    fixture_message_data[1] = second;
    fixture_message_data[2] = third;
    fixture_message.cursize = 3;
    return &fixture_message;
}

int loop_socket_can_send(qsocket_t *socket) { return socket->canSend; }
int loop_socket_receive_length(qsocket_t *socket)
{
    return socket->receiveMessageLength;
}
int loop_socket_has_peer(qsocket_t *socket)
{
    return socket->driverdata != NULL;
}
int loop_net_message_size(void) { return net_message.cursize; }
int loop_net_message_byte(int index) { return net_message.data[index]; }
int loop_sys_error_calls(void) { return sys_error_calls; }
