#include "net_wins_oracle_stubs.h"

int _fltused = 0;
void __chkstk(void) {}
int com_argc;
char **com_argv;
int net_hostport;
char my_tcpip_address[64];
qboolean tcpipAvailable;
cvar_t hostname = {"hostname", "UNNAMED", false, false, 0, NULL};

extern qboolean winsock_lib_initialized;
extern int winsock_initialized;
extern int (PASCAL FAR *pWSAStartup)(WORD, WSADATA *);
extern int (PASCAL FAR *pWSACleanup)(void);
extern int (PASCAL FAR *pWSAGetLastError)(void);
extern SOCKET (PASCAL FAR *psocket)(int, int, int);
extern int (PASCAL FAR *pioctlsocket)(SOCKET, long, u_long FAR *);
extern int (PASCAL FAR *psetsockopt)(SOCKET, int, int, const char FAR *, int);
extern int (PASCAL FAR *precvfrom)(SOCKET, char FAR *, int, int, struct sockaddr FAR *, int FAR *);
extern int (PASCAL FAR *psendto)(SOCKET, const char FAR *, int, int, const struct sockaddr FAR *, int);
extern int (PASCAL FAR *pclosesocket)(SOCKET);
extern int (PASCAL FAR *pgethostname)(char FAR *, int);
extern struct hostent FAR * (PASCAL FAR *pgethostbyname)(const char FAR *);
extern struct hostent FAR * (PASCAL FAR *pgethostbyaddr)(const char FAR *, int, int);
extern int (PASCAL FAR *pgetsockname)(SOCKET, struct sockaddr FAR *, int FAR *);

BOOL PASCAL FAR BlockingHook(void);
void WINS_GetLocalAddress(void);
int WINS_Init(void);
void WINS_Shutdown(void);
void WINS_Listen(qboolean);
int WINS_OpenSocket(int);
int WINS_CloseSocket(int);
int WINS_Connect(int, struct qsockaddr *);
int WINS_CheckNewConnections(void);
int WINS_Read(int, byte *, int, struct qsockaddr *);
int WINS_MakeSocketBroadcastCapable(int);
int WINS_Broadcast(int, byte *, int);
int WINS_Write(int, byte *, int, struct qsockaddr *);
char *WINS_AddrToString(struct qsockaddr *);
int WINS_StringToAddr(char *, struct qsockaddr *);
int WINS_GetSocketAddr(int, struct qsockaddr *);
int WINS_GetNameFromAddr(struct qsockaddr *, char *);
int WINS_GetAddrFromName(char *, struct qsockaddr *);
int WINS_AddrCompare(struct qsockaddr *, struct qsockaddr *);
int WINS_GetSocketPort(struct qsockaddr *);
int WINS_SetSocketPort(struct qsockaddr *, int);
int mq_PartialIPAddress(char *, struct qsockaddr *);
void mq_set_blocktime(double);
double mq_blocktime(void);
void mq_set_my_addr(unsigned long);
unsigned long mq_my_addr(void);
int mq_accept_socket(void);
void mq_set_accept_socket(int);
int mq_control_socket(void);
int mq_broadcast_socket(void);
void mq_set_broadcast_socket(int);
struct qsockaddr *mq_broadcast_addr(void);

static double fake_time;
static int load_success;
static int missing_symbol;
static int startup_result;
static int startup_count;
static int cleanup_count;
static int last_error;
static int socket_result;
static int socket_count;
static int ioctl_result;
static int ioctl_count;
static int setopt_result;
static int setopt_count;
static int bind_result;
static int bind_count;
static struct sockaddr_in last_bind;
static int close_count;
static int last_closed;
static int recv_result;
static int recv_count;
static byte recv_data[64];
static struct sockaddr_in recv_address;
static int send_result;
static int send_count;
static byte last_send[64];
static int last_send_length;
static struct sockaddr_in last_send_address;
static int hostname_result;
static char fake_hostname[256];
static int hostbyname_success;
static int hostbyaddr_success;
static unsigned long fake_host_address;
static char reverse_name[64];
static struct hostent host_entry;
static char *host_addresses[2];
static int getsockname_result;
static struct sockaddr_in socket_name;
static int peek_result;
static int peek_count;
static int translate_count;
static int dispatch_count;
static int cancel_count;
static int hook_count;
static int unhook_count;
static int safe_print_count;
static int print_count;
static int cvar_set_count;
static char cvar_value[64];
static int sys_errors;
static int fatal_mode;
static char *argv_storage[4];
static char arg0[] = "miniquake";
static char arg_noudp[] = "-noudp";
static char arg_ip[] = "-ip";
static char arg_bad_ip[] = "999.1.1.1";
static char *argv_default[] = {arg0};
static char *argv_noudp[] = {arg0, arg_noudp};
static char *argv_bad_ip[] = {arg0, arg_ip, arg_bad_ip};
static char *argv_missing_ip[] = {arg0, arg_ip};

static int text_equal(const char *left, const char *right)
{
    while (*left || *right)
        if (*left++ != *right++)
            return 0;
    return 1;
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

unsigned short htons(unsigned short value)
{
    return (unsigned short)((value << 8) | (value >> 8));
}
unsigned short ntohs(unsigned short value) { return htons(value); }
unsigned long htonl(unsigned long value)
{
    value &= 0xffffffffUL;
    return ((value & 0xffUL) << 24) |
           ((value & 0xff00UL) << 8) |
           ((value >> 8) & 0xff00UL) |
           ((value >> 24) & 0xffUL);
}
unsigned long ntohl(unsigned long value) { return htonl(value); }

unsigned long inet_addr(const char *text)
{
    unsigned long value = 0;
    int part = 0;
    int count = 0;
    while (1)
    {
        if (*text >= '0' && *text <= '9')
        {
            part = part * 10 + (*text - '0');
            if (part > 255)
                return INADDR_NONE;
        }
        else if (*text == '.' || *text == 0)
        {
            value = (value << 8) | (unsigned long)part;
            part = 0;
            ++count;
            if (*text == 0)
                break;
        }
        else
            return INADDR_NONE;
        ++text;
    }
    if (count != 4)
        return INADDR_NONE;
    return htonl(value);
}

double Sys_FloatTime(void) { return fake_time; }
void Con_SafePrintf(char *format, ...)
{
    (void)format;
    ++safe_print_count;
}
void Con_DPrintf(char *format, ...)
{
    (void)format;
    ++print_count;
}
void Con_Printf(char *format, ...)
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
int COM_CheckParm(char *name)
{
    int index;
    for (index = 1; index < com_argc; ++index)
        if (text_equal(com_argv[index], name))
            return index;
    return 0;
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
int Q_atoi(char *text)
{
    int result = 0;
    while (*text >= '0' && *text <= '9')
        result = result * 10 + (*text++ - '0');
    return result;
}
void Q_memset(void *destination, int value, int count)
{
    memset(destination, value, (unsigned __int64)count);
}
char *Q_strcpy(char *destination, const char *source)
{
    return strcpy(destination, source);
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
void Cvar_Set(char *name, char *value)
{
    (void)name;
    ++cvar_set_count;
    copy_text(cvar_value, value, sizeof(cvar_value));
}

static int fake_WSAStartup(WORD version, WSADATA *data)
{
    (void)version;
    (void)data;
    ++startup_count;
    return startup_result;
}
static int fake_WSACleanup(void)
{
    ++cleanup_count;
    return 0;
}
static int fake_WSAGetLastError(void) { return last_error; }
static SOCKET fake_socket(int af, int type, int protocol)
{
    (void)af;
    (void)type;
    (void)protocol;
    ++socket_count;
    return socket_result;
}
static int fake_ioctlsocket(SOCKET socket, long command, u_long FAR *argument)
{
    (void)socket;
    (void)command;
    (void)argument;
    ++ioctl_count;
    return ioctl_result;
}
static int fake_setsockopt(SOCKET socket, int level, int option, const char FAR *value, int length)
{
    (void)socket;
    (void)level;
    (void)option;
    (void)value;
    (void)length;
    ++setopt_count;
    return setopt_result;
}
static int fake_recvfrom(SOCKET socket, char FAR *buffer, int length, int flags, struct sockaddr FAR *from, int FAR *fromLength)
{
    (void)socket;
    (void)flags;
    ++recv_count;
    if (recv_result > 0 && buffer)
    {
        int count = recv_result;
        if (count > length)
            count = length;
        memcpy(buffer, recv_data, (unsigned __int64)count);
        if (from)
            memcpy(from, &recv_address, sizeof(recv_address));
        if (fromLength)
            *fromLength = sizeof(recv_address);
        return count;
    }
    return recv_result;
}
static int fake_sendto(SOCKET socket, const char FAR *buffer, int length, int flags, const struct sockaddr FAR *to, int toLength)
{
    (void)socket;
    (void)flags;
    (void)toLength;
    ++send_count;
    last_send_length = length;
    if (length > (int)sizeof(last_send))
        length = sizeof(last_send);
    memcpy(last_send, buffer, (unsigned __int64)length);
    memcpy(&last_send_address, to, sizeof(last_send_address));
    return send_result;
}
static int fake_closesocket(SOCKET socket)
{
    ++close_count;
    last_closed = socket;
    return 0;
}
static int fake_gethostname(char FAR *name, int capacity)
{
    if (hostname_result == SOCKET_ERROR)
        return SOCKET_ERROR;
    copy_text(name, fake_hostname, capacity);
    return 0;
}
static struct hostent FAR *fake_gethostbyname(const char FAR *name)
{
    (void)name;
    return hostbyname_success ? &host_entry : NULL;
}
static struct hostent FAR *fake_gethostbyaddr(const char FAR *address, int length, int type)
{
    (void)address;
    (void)length;
    (void)type;
    return hostbyaddr_success ? &host_entry : NULL;
}
static int fake_getsockname(SOCKET socket, struct sockaddr FAR *name, int FAR *length)
{
    (void)socket;
    if (getsockname_result == 0)
    {
        memcpy(name, &socket_name, sizeof(socket_name));
        *length = sizeof(socket_name);
    }
    return getsockname_result;
}

void *LoadLibrary(char *name)
{
    (void)name;
    return load_success ? (void *)1 : NULL;
}
void *GetProcAddress(void *library, char *name)
{
    (void)library;
    if (missing_symbol && text_equal(name, "recvfrom"))
        return NULL;
    if (text_equal(name, "WSAStartup")) return fake_WSAStartup;
    if (text_equal(name, "WSACleanup")) return fake_WSACleanup;
    if (text_equal(name, "WSAGetLastError")) return fake_WSAGetLastError;
    if (text_equal(name, "socket")) return fake_socket;
    if (text_equal(name, "ioctlsocket")) return fake_ioctlsocket;
    if (text_equal(name, "setsockopt")) return fake_setsockopt;
    if (text_equal(name, "recvfrom")) return fake_recvfrom;
    if (text_equal(name, "sendto")) return fake_sendto;
    if (text_equal(name, "closesocket")) return fake_closesocket;
    if (text_equal(name, "gethostname")) return fake_gethostname;
    if (text_equal(name, "gethostbyname")) return fake_gethostbyname;
    if (text_equal(name, "gethostbyaddr")) return fake_gethostbyaddr;
    if (text_equal(name, "getsockname")) return fake_getsockname;
    return NULL;
}
int bind(SOCKET socket, const struct sockaddr *address, int length)
{
    (void)socket;
    (void)length;
    ++bind_count;
    memcpy(&last_bind, address, sizeof(last_bind));
    return bind_result;
}
int WSASetBlockingHook(BOOL (PASCAL FAR *hook)(void))
{
    (void)hook;
    ++hook_count;
    return 0;
}
int WSAUnhookBlockingHook(void)
{
    ++unhook_count;
    return 0;
}
int WSACancelBlockingCall(void)
{
    ++cancel_count;
    return 0;
}
BOOL PeekMessage(MSG *message, void *window, int minimum, int maximum, int remove)
{
    (void)message;
    (void)window;
    (void)minimum;
    (void)maximum;
    (void)remove;
    ++peek_count;
    return peek_result;
}
BOOL TranslateMessage(const MSG *message)
{
    (void)message;
    ++translate_count;
    return true;
}
long DispatchMessage(const MSG *message)
{
    (void)message;
    ++dispatch_count;
    return 0;
}

static void set_address(struct qsockaddr *address, int a, int b, int c, int d, int port)
{
    struct sockaddr_in *ip = (struct sockaddr_in *)address;
    unsigned long host = ((unsigned long)a << 24) | ((unsigned long)b << 16) |
                         ((unsigned long)c << 8) | (unsigned long)d;
    memset(address, 0, sizeof(*address));
    ip->sin_family = AF_INET;
    ip->sin_addr.s_addr = htonl(host);
    ip->sin_port = htons((unsigned short)port);
}

static void reset_all(void)
{
    memset(recv_data, 0, sizeof(recv_data));
    memset(last_send, 0, sizeof(last_send));
    memset(&last_bind, 0, sizeof(last_bind));
    memset(&recv_address, 0, sizeof(recv_address));
    memset(&last_send_address, 0, sizeof(last_send_address));
    memset(&socket_name, 0, sizeof(socket_name));
    fake_time = 10.0;
    load_success = 1;
    missing_symbol = 0;
    startup_result = 0;
    startup_count = cleanup_count = 0;
    last_error = 0;
    socket_result = 40;
    socket_count = 0;
    ioctl_result = ioctl_count = 0;
    setopt_result = setopt_count = 0;
    bind_result = bind_count = 0;
    close_count = 0;
    last_closed = -1;
    recv_result = recv_count = 0;
    send_result = 3;
    send_count = 0;
    last_send_length = 0;
    hostname_result = 0;
    copy_text(fake_hostname, "quakehost.domain", sizeof(fake_hostname));
    hostbyname_success = 1;
    hostbyaddr_success = 1;
    fake_host_address = inet_addr("10.1.2.3");
    copy_text(reverse_name, "resolved.example", sizeof(reverse_name));
    host_addresses[0] = (char *)&fake_host_address;
    host_addresses[1] = NULL;
    host_entry.h_name = reverse_name;
    host_entry.h_addr_list = host_addresses;
    getsockname_result = 0;
    peek_result = peek_count = 0;
    translate_count = dispatch_count = cancel_count = 0;
    hook_count = unhook_count = 0;
    safe_print_count = print_count = cvar_set_count = 0;
    cvar_value[0] = 0;
    sys_errors = fatal_mode = 0;
    com_argc = 1;
    com_argv = argv_default;
    net_hostport = 26000;
    copy_text(my_tcpip_address, "", sizeof(my_tcpip_address));
    tcpipAvailable = false;
    hostname.string = "UNNAMED";
    winsock_lib_initialized = false;
    winsock_initialized = 0;
    mq_set_my_addr(INADDR_ANY);
    mq_set_accept_socket(-1);
    mq_set_broadcast_socket(0);
    pWSAStartup = fake_WSAStartup;
    pWSACleanup = fake_WSACleanup;
    pWSAGetLastError = fake_WSAGetLastError;
    psocket = fake_socket;
    pioctlsocket = fake_ioctlsocket;
    psetsockopt = fake_setsockopt;
    precvfrom = fake_recvfrom;
    psendto = fake_sendto;
    pclosesocket = fake_closesocket;
    pgethostname = fake_gethostname;
    pgethostbyname = fake_gethostbyname;
    pgethostbyaddr = fake_gethostbyaddr;
    pgetsockname = fake_getsockname;
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

__declspec(dllexport) int __cdecl net_wins_oracle_jsonl(char *output, int capacity)
{
    char *cursor = output;
    struct qsockaddr first;
    struct qsockaddr second;
    byte buffer[32];
    char name[NET_NAMELEN];
    int result;
    (void)capacity;

    reset_all();
    mq_set_blocktime(7.0);
    fake_time = 10.0;
    result = BlockingHook();
    fake_time = 7.5;
    peek_result = 1;
    result += BlockingHook() * 2;
    cursor = emit(cursor, "BlockingHook", "timeout_and_message", result,
        cancel_count, translate_count, dispatch_count);

    reset_all();
    WINS_GetLocalAddress();
    cursor = emit(cursor, "WINS_GetLocalAddress", "resolve",
        mq_my_addr() == fake_host_address, hook_count, unhook_count,
        text_equal(my_tcpip_address, "10.1.2.3"));

    reset_all();
    result = WINS_Init();
    cursor = emit(cursor, "WINS_Init", "success",
        result != -1, winsock_initialized, cvar_set_count,
        tcpipAvailable && text_equal(cvar_value, "quakehost"));

    WINS_Shutdown();
    cursor = emit(cursor, "WINS_Shutdown", "cleanup",
        winsock_initialized, close_count, cleanup_count, 1);

    reset_all();
    com_argc = 2;
    com_argv = argv_noudp;
    result = WINS_Init();
    cursor = emit(cursor, "WINS_Init", "noudp", result,
        winsock_lib_initialized, startup_count, 1);

    reset_all();
    WINS_Listen(true);
    result = mq_accept_socket();
    WINS_Listen(true);
    WINS_Listen(false);
    cursor = emit(cursor, "WINS_Listen", "enable_disable",
        result != -1, socket_count, close_count, mq_accept_socket() == -1);

    reset_all();
    result = WINS_OpenSocket(27000);
    cursor = emit(cursor, "WINS_OpenSocket", "nonblocking_bind",
        result != -1, ioctl_count, ntohs(last_bind.sin_port), bind_count);
    ioctl_result = -1;
    result = WINS_OpenSocket(27001);
    cursor = emit(cursor, "WINS_OpenSocket", "ioctl_error",
        result, close_count, ioctl_count, 1);

    reset_all();
    mq_set_broadcast_socket(77);
    result = WINS_CloseSocket(77);
    cursor = emit(cursor, "WINS_CloseSocket", "broadcast_reset",
        result, mq_broadcast_socket(), last_closed, close_count);

    reset_all();
    mq_set_my_addr(inet_addr("192.168.1.10"));
    result = mq_PartialIPAddress(".42:27000", &first);
    cursor = emit(cursor, "PartialIPAddress", "suffix",
        result, WINS_AddrCompare(&first, &first),
        WINS_GetSocketPort(&first), text_equal(WINS_AddrToString(&first), "192.168.1.42:27000"));
    result = mq_PartialIPAddress(".1234", &first);
    cursor = emit(cursor, "PartialIPAddress", "reject_digits",
        result, 0, 0, 1);

    reset_all();
    cursor = emit(cursor, "WINS_Connect", "noop",
        WINS_Connect(10, &first), 0, 0, 1);

    reset_all();
    mq_set_accept_socket(88);
    recv_result = 3;
    result = WINS_CheckNewConnections();
    cursor = emit(cursor, "WINS_CheckNewConnections", "peek",
        result == 88, recv_count, 0, 1);

    reset_all();
    recv_result = 3;
    recv_data[0] = 1;
    recv_data[1] = 2;
    recv_data[2] = 3;
    set_address((struct qsockaddr *)&recv_address, 10, 0, 0, 2, 26000);
    result = WINS_Read(5, buffer, sizeof(buffer), &first);
    cursor = emit(cursor, "WINS_Read", "packet",
        result, buffer[0] * 100 + buffer[2], WINS_GetSocketPort(&first) > 0, 1);
    recv_result = -1;
    last_error = WSAEWOULDBLOCK;
    result = WINS_Read(5, buffer, sizeof(buffer), &first);
    cursor = emit(cursor, "WINS_Read", "wouldblock",
        result, recv_count, 0, 1);

    reset_all();
    result = WINS_MakeSocketBroadcastCapable(9);
    cursor = emit(cursor, "WINS_MakeSocketBroadcastCapable", "enable",
        result, setopt_count, mq_broadcast_socket(), 1);

    reset_all();
    buffer[0] = 4;
    buffer[1] = 5;
    buffer[2] = 6;
    result = WINS_Broadcast(9, buffer, 3);
    cursor = emit(cursor, "WINS_Broadcast", "first_socket",
        result, setopt_count, send_count, mq_broadcast_socket() == 9);

    reset_all();
    set_address(&first, 10, 0, 0, 2, 26000);
    result = WINS_Write(5, buffer, 3, &first);
    cursor = emit(cursor, "WINS_Write", "packet",
        result, send_count, last_send_length, 1);
    send_result = -1;
    last_error = WSAEWOULDBLOCK;
    result = WINS_Write(5, buffer, 3, &first);
    cursor = emit(cursor, "WINS_Write", "wouldblock",
        result, send_count, 0, 1);

    reset_all();
    set_address(&first, 10, 20, 30, 40, 27500);
    cursor = emit(cursor, "WINS_AddrToString", "ipv4_port",
        text_equal(WINS_AddrToString(&first), "10.20.30.40:27500"),
        WINS_GetSocketPort(&first), 0, 1);

    memset(&second, 0, sizeof(second));
    result = WINS_StringToAddr("10.20.30.40:27500", &second);
    cursor = emit(cursor, "WINS_StringToAddr", "parse",
        result, WINS_AddrCompare(&first, &second), WINS_GetSocketPort(&second), 1);

    reset_all();
    mq_set_my_addr(inet_addr("10.1.2.3"));
    set_address((struct qsockaddr *)&socket_name, 0, 0, 0, 0, 28000);
    result = WINS_GetSocketAddr(5, &first);
    cursor = emit(cursor, "WINS_GetSocketAddr", "replace_any",
        result, WINS_GetSocketPort(&first) > 0,
        text_equal(WINS_AddrToString(&first), "10.1.2.3:28000"), 1);

    reset_all();
    set_address(&first, 10, 20, 30, 40, 27500);
    result = WINS_GetNameFromAddr(&first, name);
    cursor = emit(cursor, "WINS_GetNameFromAddr", "reverse",
        result, text_equal(name, "resolved.example"), 0, 1);
    hostbyaddr_success = 0;
    result = WINS_GetNameFromAddr(&first, name);
    cursor = emit(cursor, "WINS_GetNameFromAddr", "numeric_fallback",
        result, text_equal(name, "10.20.30.40:27500"), 0, 1);

    reset_all();
    mq_set_my_addr(inet_addr("192.168.1.10"));
    result = WINS_GetAddrFromName("42:27000", &first);
    cursor = emit(cursor, "WINS_GetAddrFromName", "partial",
        result, text_equal(WINS_AddrToString(&first), "192.168.1.42:27000"),
        WINS_GetSocketPort(&first), 1);
    result = WINS_GetAddrFromName("server", &second);
    cursor = emit(cursor, "WINS_GetAddrFromName", "dns",
        result, WINS_GetSocketPort(&second),
        text_equal(WINS_AddrToString(&second), "10.1.2.3:26000"), 1);

    set_address(&first, 10, 0, 0, 1, 26000);
    second = first;
    result = WINS_AddrCompare(&first, &second);
    WINS_SetSocketPort(&second, 26001);
    cursor = emit(cursor, "WINS_AddrCompare", "equal_port_address",
        result, WINS_AddrCompare(&first, &second), 0, 1);

    cursor = emit(cursor, "WINS_GetSocketPort", "network_order",
        WINS_GetSocketPort(&second), 26001, 0, 1);
    result = WINS_SetSocketPort(&second, 27500);
    cursor = emit(cursor, "WINS_SetSocketPort", "network_order",
        result, WINS_GetSocketPort(&second), 0, 1);

    *cursor = 0;
    return (int)(cursor - output);
}

__declspec(dllexport) int __cdecl net_wins_error_case(int mode)
{
    byte data[1] = {1};
    struct qsockaddr address;
    reset_all();
    fatal_mode = 1;
    if (mode == 0)
    {
        socket_result = -1;
        WINS_Listen(true);
    }
    else if (mode == 1)
    {
        mq_set_broadcast_socket(8);
        WINS_Broadcast(9, data, 1);
    }
    else if (mode == 2)
    {
        com_argc = 3;
        com_argv = argv_bad_ip;
        WINS_Init();
    }
    else
    {
        bind_result = -1;
        WINS_OpenSocket(26000);
    }
    return 0;
}
