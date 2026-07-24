#include "net_dgrm_oracle_stubs.h"

int _fltused = 0;
void __chkstk(void) {}
int net_numlandrivers;
net_landriver_t net_landrivers[8];
int net_driverlevel;
double net_time;
sizebuf_t net_message;
qsocket_t *net_activeSockets;
qsocket_t *net_freeSockets;
int net_activeconnections;
int messagesSent;
int messagesReceived;
int unreliableMessagesSent;
int unreliableMessagesReceived;
int hostCacheCount;
hostcache_t hostcache[HOSTCACHESIZE];
server_static_t svs;
server_t sv;
client_t *host_client;
globalvars_t globals_storage;
globalvars_t *pr_global_struct = &globals_storage;
cvar_t hostname = {"hostname", "oracle", false, false, 0, NULL};
cvar_t *cvar_vars;
cmd_source_t cmd_source;
int key_dest;
int m_return_state;
int m_state;
qboolean m_return_onerror;
char m_return_reason[32];

extern unsigned long banAddr;
extern unsigned long banMask;
extern int packetsSent;
extern int packetsReSent;
extern int packetsReceived;
extern int receivedDuplicateCount;
extern int shortPacketCount;
extern int droppedDatagrams;

void NET_Ban_f(void);
int Datagram_SendMessage(qsocket_t *, sizebuf_t *);
int SendMessageNext(qsocket_t *);
int ReSendMessage(qsocket_t *);
qboolean Datagram_CanSendMessage(qsocket_t *);
qboolean Datagram_CanSendUnreliableMessage(qsocket_t *);
int Datagram_SendUnreliableMessage(qsocket_t *, sizebuf_t *);
int Datagram_GetMessage(qsocket_t *);
void PrintStats(qsocket_t *);
void NET_Stats_f(void);
int Datagram_Init(void);
void Datagram_Shutdown(void);
void Datagram_Close(qsocket_t *);
void Datagram_Listen(qboolean);
qsocket_t *Datagram_CheckNewConnections(void);
void Datagram_SearchForHosts(qboolean);
qsocket_t *Datagram_Connect(char *);
void mq_Test_f(void);
void mq_Test_Poll(void);
void mq_Test2_f(void);
void mq_Test2_Poll(void);
qsocket_t *mq__Datagram_CheckNewConnections(void);
void mq__Datagram_SearchForHosts(qboolean);
qsocket_t *mq__Datagram_Connect(char *);
int mq_test_in_progress(void);
int mq_test_poll_count(void);
int mq_test2_in_progress(void);
int mq_net_landriverlevel(void);
void mq_set_net_landriverlevel(int);
int mq_my_driver_level(void);
void mq_set_my_driver_level(int);

typedef struct {
    int socket;
    int length;
    byte data[NET_DATAGRAMSIZE + 256];
    struct qsockaddr address;
} queued_packet_t;

static byte message_storage[NET_MAXMESSAGE];
static byte error_payload[NET_MAXMESSAGE + 1];
static queued_packet_t read_queue[64];
static int read_count;
static int read_index;
static queued_packet_t writes[128];
static int write_count;
static int broadcast_count;
static int init_count[8];
static int init_result[8];
static int shutdown_count[8];
static int listen_count[8];
static int listen_value[8];
static int open_count[8];
static int close_count[8];
static int connect_count[8];
static int connect_result[8];
static int check_count[8];
static int check_result[8];
static int resolve_result[8];
static int command_count;
static int print_count;
static int forward_count;
static int screen_count;
static int schedule_count;
static int sys_errors;
static int fatal_mode;
static int command_argc;
static char *command_argv[4];
static int msg_read_count;
static qsocket_t qsocket_pool[8];
static int qsocket_used;
static int freed_count;
static int net_close_count;
static client_t clients[2];
static edict_t edicts[2];
static cvar_t rule_two = {"sv_gravity", "800", false, true, 800, NULL};
static cvar_t rule_one = {"developer", "0", false, false, 0, &rule_two};

static int text_equal(const char *left, const char *right)
{
    while (*left || *right)
        if (*left++ != *right++)
            return 0;
    return 1;
}

unsigned long inet_addr(const char *text)
{
    unsigned long result = 0;
    int part = 0;
    int shift = 0;
    while (1)
    {
        if (*text >= '0' && *text <= '9')
        {
            part = part * 10 + (*text - '0');
        }
        else if (*text == '.' || *text == 0)
        {
            result |= ((unsigned long)(part & 255)) << shift;
            shift += 8;
            part = 0;
            if (*text == 0)
                break;
        }
        else
        {
            return 0xffffffff;
        }
        ++text;
    }
    return result;
}

char *inet_ntoa(struct in_addr address)
{
    static char text[32];
    unsigned long value = address.s_addr;
    sprintf(
        text,
        "%u.%u.%u.%u",
        value & 255,
        (value >> 8) & 255,
        (value >> 16) & 255,
        (value >> 24) & 255);
    return text;
}

static void copy_text(char *destination, const char *source, int capacity)
{
    int index = 0;
    while (source && source[index] && index + 1 < capacity)
    {
        destination[index] = source[index];
        ++index;
    }
    destination[index] = 0;
}

unsigned int BigLong(unsigned int value)
{
    return ((value & 0x000000ffU) << 24) |
           ((value & 0x0000ff00U) << 8) |
           ((value & 0x00ff0000U) >> 8) |
           ((value & 0xff000000U) >> 24);
}

void *Q_memcpy(void *destination, const void *source, int count)
{
    return memcpy(destination, source, (unsigned __int64)count);
}

char *Q_strcpy(char *destination, const char *source)
{
    char *result = destination;
    while ((*destination++ = *source++) != 0)
    {
    }
    return result;
}

char *Q_strncpy(char *destination, const char *source, int count)
{
    int index = 0;
    while (index < count && source[index])
    {
        destination[index] = source[index];
        ++index;
    }
    while (index < count)
        destination[index++] = 0;
    return destination;
}

char *Q_strcat(char *destination, const char *source)
{
    char *cursor = destination;
    while (*cursor)
        ++cursor;
    Q_strcpy(cursor, source);
    return destination;
}

int Q_strlen(const char *text)
{
    int count = 0;
    while (text[count])
        ++count;
    return count;
}

int Q_strcmp(const char *left, const char *right)
{
    while (*left && *left == *right)
    {
        ++left;
        ++right;
    }
    return (unsigned char)*left - (unsigned char)*right;
}

int Q_strcasecmp(const char *left, const char *right)
{
    int a;
    int b;
    while (*left || *right)
    {
        a = (unsigned char)*left++;
        b = (unsigned char)*right++;
        if (a >= 'A' && a <= 'Z')
            a += 'a' - 'A';
        if (b >= 'A' && b <= 'Z')
            b += 'a' - 'A';
        if (a != b)
            return a - b;
    }
    return 0;
}

void SZ_Clear(sizebuf_t *buffer)
{
    buffer->cursize = 0;
    buffer->overflowed = false;
}

void SZ_Write(sizebuf_t *buffer, const void *source, int count)
{
    if (buffer->cursize + count > buffer->maxsize)
    {
        buffer->overflowed = true;
        return;
    }
    memcpy(buffer->data + buffer->cursize, source, (unsigned __int64)count);
    buffer->cursize += count;
}

void MSG_BeginReading(void)
{
    msg_read_count = 0;
}

int MSG_ReadLong(void)
{
    unsigned int value;
    if (msg_read_count + 4 > net_message.cursize)
        return -1;
    value = (unsigned int)net_message.data[msg_read_count] |
            ((unsigned int)net_message.data[msg_read_count + 1] << 8) |
            ((unsigned int)net_message.data[msg_read_count + 2] << 16) |
            ((unsigned int)net_message.data[msg_read_count + 3] << 24);
    msg_read_count += 4;
    return (int)value;
}

int MSG_ReadByte(void)
{
    if (msg_read_count >= net_message.cursize)
        return -1;
    return net_message.data[msg_read_count++];
}

char *MSG_ReadString(void)
{
    static char strings[8][2048];
    static int slot;
    char *result = strings[slot++ & 7];
    int count = 0;
    int value;
    while (count + 1 < 2048)
    {
        value = MSG_ReadByte();
        if (value <= 0)
            break;
        result[count++] = (char)value;
    }
    result[count] = 0;
    return result;
}

void MSG_WriteLong(sizebuf_t *buffer, int value)
{
    byte data[4];
    data[0] = value & 255;
    data[1] = (value >> 8) & 255;
    data[2] = (value >> 16) & 255;
    data[3] = (value >> 24) & 255;
    SZ_Write(buffer, data, 4);
}

void MSG_WriteByte(sizebuf_t *buffer, int value)
{
    byte data = (byte)value;
    SZ_Write(buffer, &data, 1);
}

void MSG_WriteString(sizebuf_t *buffer, char *text)
{
    SZ_Write(buffer, text, Q_strlen(text) + 1);
}

void Cmd_ForwardToServer(void) { ++forward_count; }
int Cmd_Argc(void) { return command_argc; }
char *Cmd_Argv(int index)
{
    if (index < 0 || index >= command_argc)
        return "";
    return command_argv[index];
}
void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)name;
    (void)function;
    ++command_count;
}
int COM_CheckParm(char *name)
{
    (void)name;
    return 0;
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
void SV_ClientPrintf(char *format, ...)
{
    (void)format;
    ++print_count;
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
void SCR_UpdateScreen(void) { ++screen_count; }
cvar_t *Cvar_FindVar(char *name)
{
    cvar_t *item = cvar_vars;
    while (item)
    {
        if (text_equal(item->name, name))
            return item;
        item = item->next;
    }
    return NULL;
}

qsocket_t *NET_NewQSocket(void)
{
    qsocket_t *socket;
    if (qsocket_used >= 8)
        return NULL;
    socket = &qsocket_pool[qsocket_used++];
    memset(socket, 0, sizeof(*socket));
    socket->canSend = true;
    socket->driver = net_driverlevel;
    socket->connecttime = net_time;
    socket->next = net_activeSockets;
    net_activeSockets = socket;
    return socket;
}

void NET_FreeQSocket(qsocket_t *socket)
{
    socket->disconnected = true;
    ++freed_count;
}

void NET_Close(qsocket_t *socket)
{
    socket->disconnected = true;
    ++net_close_count;
}

double SetNetTime(void)
{
    net_time += 0.01;
    return net_time;
}

void SchedulePollProcedure(PollProcedure *procedure, double offset)
{
    (void)procedure;
    (void)offset;
    ++schedule_count;
}

static void address_set(struct qsockaddr *address, int id, int port)
{
    memset(address, 0, sizeof(*address));
    address->sa_family = 2;
    address->sa_data[0] = (byte)id;
    address->sa_data[1] = (byte)(port & 255);
    address->sa_data[2] = (byte)((port >> 8) & 255);
}

static int address_id(const struct qsockaddr *address) { return address->sa_data[0]; }
static int address_port(const struct qsockaddr *address)
{
    return address->sa_data[1] | (address->sa_data[2] << 8);
}

static int lan_init(void)
{
    ++init_count[mq_net_landriverlevel()];
    return init_result[mq_net_landriverlevel()];
}
static void lan_shutdown(void) { ++shutdown_count[mq_net_landriverlevel()]; }
static void lan_listen(qboolean value)
{
    ++listen_count[mq_net_landriverlevel()];
    listen_value[mq_net_landriverlevel()] = value;
}
static int lan_open(int port)
{
    int level = mq_net_landriverlevel();
    ++open_count[level];
    return 100 + level * 10 + port;
}
static int lan_close(int socket)
{
    (void)socket;
    ++close_count[mq_net_landriverlevel()];
    return 0;
}
static int lan_connect(int socket, struct qsockaddr *address)
{
    (void)socket;
    (void)address;
    ++connect_count[mq_net_landriverlevel()];
    return connect_result[mq_net_landriverlevel()];
}
static int lan_check(void)
{
    int level = mq_net_landriverlevel();
    ++check_count[level];
    return check_result[level];
}
static int lan_read(int socket, byte *buffer, int capacity, struct qsockaddr *address)
{
    queued_packet_t *packet;
    if (read_index >= read_count)
        return 0;
    packet = &read_queue[read_index];
    if (packet->socket != -1 && packet->socket != socket)
        return 0;
    ++read_index;
    if (packet->length > capacity)
        return -1;
    memcpy(buffer, packet->data, (unsigned __int64)packet->length);
    *address = packet->address;
    return packet->length;
}
static int lan_write(int socket, byte *buffer, int length, struct qsockaddr *address)
{
    queued_packet_t *packet = &writes[write_count++];
    packet->socket = socket;
    packet->length = length;
    memcpy(packet->data, buffer, (unsigned __int64)length);
    packet->address = *address;
    return length;
}
static int lan_broadcast(int socket, byte *buffer, int length)
{
    struct qsockaddr address;
    address_set(&address, 255, 26000);
    ++broadcast_count;
    return lan_write(socket, buffer, length, &address);
}
static char *lan_addr_to_string(struct qsockaddr *address)
{
    static char text[64];
    sprintf(text, "10.0.0.%d:%d", address_id(address), address_port(address));
    return text;
}
static int lan_string_to_addr(char *text, struct qsockaddr *address)
{
    (void)text;
    address_set(address, 2, 26000);
    return 0;
}
static int lan_get_socket_addr(int socket, struct qsockaddr *address)
{
    address_set(address, 1 + mq_net_landriverlevel(), 27000 + socket);
    return 0;
}
static int lan_get_name(struct qsockaddr *address, char *name)
{
    copy_text(name, lan_addr_to_string(address), NET_NAMELEN);
    return 0;
}
static int lan_get_addr(char *name, struct qsockaddr *address)
{
    int level = mq_net_landriverlevel();
    if (resolve_result[level] == -1)
        return -1;
    address_set(address, name && name[0] == 'l' ? 1 : 2, 26000);
    return 0;
}
static int lan_compare(struct qsockaddr *left, struct qsockaddr *right)
{
    if (address_id(left) != address_id(right))
        return -1;
    if (address_port(left) != address_port(right))
        return 1;
    return 0;
}
static int lan_get_port(struct qsockaddr *address) { return address_port(address); }
static int lan_set_port(struct qsockaddr *address, int port)
{
    address->sa_data[1] = (byte)(port & 255);
    address->sa_data[2] = (byte)((port >> 8) & 255);
    return 0;
}

static void queue_raw(int socket, const byte *data, int length, int addressId, int port)
{
    queued_packet_t *packet = &read_queue[read_count++];
    packet->socket = socket;
    packet->length = length;
    memcpy(packet->data, data, (unsigned __int64)length);
    address_set(&packet->address, addressId, port);
}

static int append_string(byte *data, int cursor, const char *text)
{
    while (*text)
        data[cursor++] = (byte)*text++;
    data[cursor++] = 0;
    return cursor;
}

static void queue_control(
    int socket,
    int command,
    const char *first,
    const char *second,
    int number,
    int addressId)
{
    byte data[512];
    int cursor = 4;
    unsigned int header;
    data[cursor++] = (byte)command;
    if (first)
        cursor = append_string(data, cursor, first);
    if (second)
        cursor = append_string(data, cursor, second);
    if (number >= 0)
    {
        data[cursor++] = number & 255;
        data[cursor++] = (number >> 8) & 255;
        data[cursor++] = (number >> 16) & 255;
        data[cursor++] = (number >> 24) & 255;
    }
    header = BigLong(NETFLAG_CTL | cursor);
    memcpy(data, &header, 4);
    queue_raw(socket, data, cursor, addressId, 26000);
}

static void queue_sequenced(
    int socket,
    unsigned int flags,
    unsigned int sequence,
    const byte *payload,
    int length,
    int addressId)
{
    byte data[NET_DATAGRAMSIZE];
    unsigned int header = BigLong((unsigned int)(NET_HEADERSIZE + length) | flags);
    unsigned int wireSequence = BigLong(sequence);
    memcpy(data, &header, 4);
    memcpy(data + 4, &wireSequence, 4);
    if (length)
        memcpy(data + 8, payload, (unsigned __int64)length);
    queue_raw(socket, data, NET_HEADERSIZE + length, addressId, 26000);
}

static unsigned int write_flags(int index)
{
    unsigned int value;
    memcpy(&value, writes[index].data, 4);
    return BigLong(value) & ~NETFLAG_LENGTH_MASK;
}
static unsigned int write_sequence(int index)
{
    unsigned int value;
    memcpy(&value, writes[index].data + 4, 4);
    return BigLong(value);
}
static int write_command(int index)
{
    if (writes[index].length < 5)
        return -1;
    return writes[index].data[4];
}

static void set_command(int count, char *first, char *second)
{
    command_argc = count;
    command_argv[0] = first;
    command_argv[1] = second;
}

static void reset_all(void)
{
    int index;
    memset(message_storage, 0, sizeof(message_storage));
    memset(read_queue, 0, sizeof(read_queue));
    memset(writes, 0, sizeof(writes));
    memset(init_count, 0, sizeof(init_count));
    memset(shutdown_count, 0, sizeof(shutdown_count));
    memset(listen_count, 0, sizeof(listen_count));
    memset(open_count, 0, sizeof(open_count));
    memset(close_count, 0, sizeof(close_count));
    memset(connect_count, 0, sizeof(connect_count));
    memset(check_count, 0, sizeof(check_count));
    memset(qsocket_pool, 0, sizeof(qsocket_pool));
    memset(hostcache, 0, sizeof(hostcache));
    memset(clients, 0, sizeof(clients));
    memset(edicts, 0, sizeof(edicts));
    read_count = read_index = write_count = broadcast_count = 0;
    command_count = print_count = forward_count = screen_count = 0;
    schedule_count = sys_errors = fatal_mode = 0;
    command_argc = 0;
    msg_read_count = 0;
    qsocket_used = freed_count = net_close_count = 0;
    net_message.data = message_storage;
    net_message.maxsize = sizeof(message_storage);
    net_message.cursize = 0;
    net_activeSockets = net_freeSockets = NULL;
    net_activeconnections = 0;
    messagesSent = messagesReceived = 0;
    unreliableMessagesSent = unreliableMessagesReceived = 0;
    hostCacheCount = 0;
    sv.active = true;
    copy_text(sv.name, "start", sizeof(sv.name));
    svs.maxclients = 2;
    svs.clients = clients;
    host_client = &clients[0];
    globals_storage.deathmatch = 0;
    cvar_vars = &rule_one;
    cmd_source = src_command;
    key_dest = 0;
    m_return_state = m_state = 0;
    m_return_onerror = false;
    m_return_reason[0] = 0;
    net_driverlevel = 0;
    mq_set_my_driver_level(0);
    net_time = 10.0;
    net_numlandrivers = 2;
    for (index = 0; index < 8; ++index)
    {
        init_result[index] = index == 0 ? 10 : 11;
        connect_result[index] = 0;
        check_result[index] = -1;
        resolve_result[index] = 0;
        net_landrivers[index].name = "fake";
        net_landrivers[index].initialized = index < 2;
        net_landrivers[index].controlSock = 20 + index;
        net_landrivers[index].Init = lan_init;
        net_landrivers[index].Shutdown = lan_shutdown;
        net_landrivers[index].Listen = lan_listen;
        net_landrivers[index].OpenSocket = lan_open;
        net_landrivers[index].CloseSocket = lan_close;
        net_landrivers[index].Connect = lan_connect;
        net_landrivers[index].CheckNewConnections = lan_check;
        net_landrivers[index].Read = lan_read;
        net_landrivers[index].Write = lan_write;
        net_landrivers[index].Broadcast = lan_broadcast;
        net_landrivers[index].AddrToString = lan_addr_to_string;
        net_landrivers[index].StringToAddr = lan_string_to_addr;
        net_landrivers[index].GetSocketAddr = lan_get_socket_addr;
        net_landrivers[index].GetNameFromAddr = lan_get_name;
        net_landrivers[index].GetAddrFromName = lan_get_addr;
        net_landrivers[index].AddrCompare = lan_compare;
        net_landrivers[index].GetSocketPort = lan_get_port;
        net_landrivers[index].SetSocketPort = lan_set_port;
    }
    banAddr = 0;
    banMask = 0xffffffff;
    packetsSent = packetsReSent = packetsReceived = 0;
    receivedDuplicateCount = shortPacketCount = droppedDatagrams = 0;
}

static char *emit(
    char *output,
    const char *function,
    const char *case_name,
    int result,
    int index,
    int value,
    int count)
{
    output += sprintf(
        output,
        "{\"function\":\"%s\",\"case\":\"%s\",\"result\":%d,"
        "\"index\":%d,\"value\":%d,\"count\":%d}\n",
        function,
        case_name,
        result,
        index,
        value,
        count);
    return output;
}

__declspec(dllexport) int __cdecl net_dgrm_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    qsocket_t socket;
    qsocket_t *connected;
    sizebuf_t data;
    byte payload[1600];
    byte two[2] = {'a', 'b'};
    byte tail[2] = {'c', 'd'};
    int result;
    int first;
    (void)capacity;
    memset(payload, 7, sizeof(payload));
    data.data = payload;
    data.maxsize = sizeof(payload);

    reset_all();
    set_command(2, "ban", "192.168.1.0");
    NET_Ban_f();
    cursor = emit(cursor, "NET_Ban_f", "address", banAddr != 0, banMask == 0xffffffff, forward_count, print_count);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = true;
    socket.socket = 3;
    socket.landriver = 0;
    address_set(&socket.addr, 2, 26000);
    data.cursize = 1500;
    result = Datagram_SendMessage(&socket, &data);
    cursor = emit(cursor, "Datagram_SendMessage", "fragment", result,
        writes[0].length, write_flags(0) == NETFLAG_DATA, socket.sendMessageLength);

    write_count = 0;
    socket.sendMessageLength = 476;
    socket.sendNext = true;
    result = SendMessageNext(&socket);
    cursor = emit(cursor, "SendMessageNext", "final_fragment", result,
        writes[0].length, write_flags(0) == (NETFLAG_DATA | NETFLAG_EOM), socket.sendNext);

    write_count = 0;
    result = ReSendMessage(&socket);
    cursor = emit(cursor, "ReSendMessage", "same_sequence", result,
        write_sequence(0) == socket.sendSequence - 1, packetsReSent, write_flags(0) == (NETFLAG_DATA | NETFLAG_EOM));

    write_count = 0;
    socket.sendNext = true;
    socket.canSend = false;
    result = Datagram_CanSendMessage(&socket);
    cursor = emit(cursor, "Datagram_CanSendMessage", "flush_next", result,
        write_count, socket.sendNext, 1);
    cursor = emit(cursor, "Datagram_CanSendUnreliableMessage", "always",
        Datagram_CanSendUnreliableMessage(&socket), 0, 0, 1);

    write_count = 0;
    data.cursize = 3;
    result = Datagram_SendUnreliableMessage(&socket, &data);
    cursor = emit(cursor, "Datagram_SendUnreliableMessage", "wire", result,
        writes[0].length, write_flags(0) == NETFLAG_UNRELIABLE, socket.unreliableSendSequence);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = true;
    socket.socket = 4;
    socket.landriver = 0;
    address_set(&socket.addr, 2, 26000);
    queue_sequenced(4, NETFLAG_DATA, 0, two, 2, 2);
    queue_sequenced(4, NETFLAG_DATA | NETFLAG_EOM, 1, tail, 2, 2);
    result = Datagram_GetMessage(&socket);
    cursor = emit(cursor, "Datagram_GetMessage", "reliable_fragments", result,
        net_message.cursize, net_message.data[0] * 1000 + net_message.data[3], write_count);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = false;
    socket.socket = 4;
    socket.landriver = 0;
    socket.sendSequence = 1;
    socket.ackSequence = 0;
    socket.sendMessageLength = 1200;
    address_set(&socket.addr, 2, 26000);
    queue_sequenced(4, NETFLAG_ACK, 0, NULL, 0, 2);
    result = Datagram_GetMessage(&socket);
    cursor = emit(cursor, "Datagram_GetMessage", "ack_next", result,
        socket.sendMessageLength, socket.sendNext, socket.canSend);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = true;
    socket.socket = 4;
    socket.landriver = 0;
    address_set(&socket.addr, 2, 26000);
    queue_sequenced(4, NETFLAG_UNRELIABLE, 3, two, 2, 2);
    result = Datagram_GetMessage(&socket);
    cursor = emit(cursor, "Datagram_GetMessage", "unreliable_gap", result,
        socket.unreliableReceiveSequence, droppedDatagrams, net_message.cursize);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = false;
    socket.socket = 4;
    socket.landriver = 0;
    socket.sendSequence = 1;
    socket.sendMessageLength = 2;
    socket.lastSendTime = 0;
    address_set(&socket.addr, 2, 26000);
    result = Datagram_GetMessage(&socket);
    cursor = emit(cursor, "Datagram_GetMessage", "timeout_resend", result,
        write_count, packetsReSent, 1);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = true;
    socket.sendSequence = 4;
    socket.receiveSequence = 7;
    PrintStats(&socket);
    cursor = emit(cursor, "PrintStats", "socket", print_count == 4, socket.sendSequence, socket.receiveSequence, 4);

    reset_all();
    set_command(1, "net_stats", NULL);
    NET_Stats_f();
    cursor = emit(cursor, "NET_Stats_f", "global", print_count == 10, packetsSent, packetsReceived, 10);

    reset_all();
    net_driverlevel = 3;
    init_result[0] = -1;
    init_result[1] = 11;
    result = Datagram_Init();
    cursor = emit(cursor, "Datagram_Init", "drivers", result,
        command_count, net_landrivers[1].controlSock, mq_my_driver_level());

    Datagram_Shutdown();
    cursor = emit(cursor, "Datagram_Shutdown", "drivers", !net_landrivers[1].initialized,
        shutdown_count[0] + shutdown_count[1] + shutdown_count[2], 0, 1);

    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.socket = 77;
    socket.landriver = 1;
    Datagram_Close(&socket);
    cursor = emit(cursor, "Datagram_Close", "landriver",
        close_count[0] + close_count[1] + close_count[2], socket.socket, 0, 1);

    reset_all();
    Datagram_Listen(true);
    cursor = emit(cursor, "Datagram_Listen", "all", listen_count[0] + listen_count[1],
        listen_value[0] + listen_value[1], 0, 2);

    reset_all();
    mq_set_net_landriverlevel(0);
    check_result[0] = 20;
    queue_control(20, CCREQ_SERVER_INFO, "QUAKE", NULL, 3, 2);
    connected = mq__Datagram_CheckNewConnections();
    cursor = emit(cursor, "_Datagram_CheckNewConnections", "server_info",
        connected == NULL, write_command(0) == CCREP_SERVER_INFO, write_count, net_message.cursize);

    reset_all();
    check_result[0] = -1;
    check_result[1] = 21;
    queue_control(21, CCREQ_CONNECT, "QUAKE", NULL, NET_PROTOCOL_VERSION, 2);
    connected = Datagram_CheckNewConnections();
    cursor = emit(cursor, "Datagram_CheckNewConnections", "accept_second",
        connected != NULL, mq_net_landriverlevel(), connect_count[1], write_command(0) == CCREP_ACCEPT);

    reset_all();
    mq_set_net_landriverlevel(0);
    queue_control(20, CCREP_SERVER_INFO, "10.0.0.2:26000", "Alpha", -1, 2);
    first = read_queue[0].length;
    read_queue[0].data[first++] = 's';
    read_queue[0].data[first++] = 't';
    read_queue[0].data[first++] = 'a';
    read_queue[0].data[first++] = 'r';
    read_queue[0].data[first++] = 't';
    read_queue[0].data[first++] = 0;
    read_queue[0].data[first++] = 1;
    read_queue[0].data[first++] = 4;
    read_queue[0].data[first++] = NET_PROTOCOL_VERSION;
    {
        unsigned int header = BigLong(NETFLAG_CTL | first);
        memcpy(read_queue[0].data, &header, 4);
        read_queue[0].length = first;
    }
    mq__Datagram_SearchForHosts(true);
    cursor = emit(cursor, "_Datagram_SearchForHosts", "broadcast_reply",
        hostCacheCount, broadcast_count, hostcache[0].users, text_equal(hostcache[0].name, "Alpha"));

    reset_all();
    Datagram_SearchForHosts(true);
    cursor = emit(cursor, "Datagram_SearchForHosts", "all_drivers",
        broadcast_count, write_count, mq_net_landriverlevel(), 2);

    reset_all();
    mq_set_net_landriverlevel(0);
    queue_control(100, CCREP_ACCEPT, NULL, NULL, 27500, 2);
    connected = mq__Datagram_Connect("server");
    cursor = emit(cursor, "_Datagram_Connect", "accept",
        connected != NULL, connect_count[0], address_port(&connected->addr), freed_count);

    reset_all();
    resolve_result[0] = -1;
    queue_control(110, CCREP_ACCEPT, NULL, NULL, 27500, 2);
    connected = Datagram_Connect("server");
    cursor = emit(cursor, "Datagram_Connect", "second_driver",
        connected != NULL, mq_net_landriverlevel(), connect_count[1], freed_count);

    reset_all();
    hostCacheCount = 1;
    copy_text(hostcache[0].name, "Friendly", sizeof(hostcache[0].name));
    hostcache[0].driver = 0;
    hostcache[0].ldriver = 0;
    hostcache[0].maxusers = 2;
    address_set(&hostcache[0].addr, 2, 26000);
    set_command(2, "test", "friendly");
    mq_Test_f();
    cursor = emit(cursor, "Test_f", "cached_host",
        mq_test_in_progress(), write_count, schedule_count, mq_test_poll_count());

    queue_control(100, CCREP_PLAYER_INFO, NULL, NULL, -1, 2);
    first = read_queue[read_count - 1].length;
    read_queue[read_count - 1].data[first++] = 0;
    first = append_string(read_queue[read_count - 1].data, first, "Ranger");
    read_queue[read_count - 1].data[first++] = 0x4f;
    read_queue[read_count - 1].data[first++] = 0;
    read_queue[read_count - 1].data[first++] = 0;
    read_queue[read_count - 1].data[first++] = 0;
    first += 8;
    first = append_string(read_queue[read_count - 1].data, first, "local");
    {
        unsigned int header = BigLong(NETFLAG_CTL | first);
        memcpy(read_queue[read_count - 1].data, &header, 4);
        read_queue[read_count - 1].length = first;
    }
    mq_Test_Poll();
    cursor = emit(cursor, "Test_Poll", "player_reply",
        mq_test_in_progress(), mq_test_poll_count(), schedule_count, print_count > 0);

    reset_all();
    set_command(2, "test2", "server");
    mq_Test2_f();
    cursor = emit(cursor, "Test2_f", "start",
        mq_test2_in_progress(), write_command(0) == CCREQ_RULE_INFO, schedule_count, write_count);

    queue_control(100, CCREP_RULE_INFO, "sv_gravity", "800", -1, 2);
    mq_Test2_Poll();
    cursor = emit(cursor, "Test2_Poll", "next_rule",
        mq_test2_in_progress(), write_count, schedule_count, print_count > 0);

    *cursor = 0;
    return (int)(cursor - output);
}

__declspec(dllexport) int __cdecl net_dgrm_error_case(int mode)
{
    qsocket_t socket;
    sizebuf_t data;
    reset_all();
    memset(&socket, 0, sizeof(socket));
    socket.canSend = true;
    socket.socket = 1;
    socket.landriver = 0;
    address_set(&socket.addr, 2, 26000);
    data.data = error_payload;
    data.maxsize = sizeof(error_payload);
    fatal_mode = 1;
    if (mode == 0)
    {
        data.cursize = 0;
        Datagram_SendMessage(&socket, &data);
    }
    else if (mode == 1)
    {
        data.cursize = NET_MAXMESSAGE + 1;
        Datagram_SendMessage(&socket, &data);
    }
    else if (mode == 2)
    {
        data.cursize = 1;
        socket.canSend = false;
        Datagram_SendMessage(&socket, &data);
    }
    else if (mode == 3)
    {
        data.cursize = 0;
        Datagram_SendUnreliableMessage(&socket, &data);
    }
    else
    {
        data.cursize = MAX_DATAGRAM + 1;
        Datagram_SendUnreliableMessage(&socket, &data);
    }
    return 0;
}
