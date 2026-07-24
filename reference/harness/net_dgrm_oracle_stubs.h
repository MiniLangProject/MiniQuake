#ifndef MINIQUAKE_NET_DGRM_ORACLE_STUBS_H
#define MINIQUAKE_NET_DGRM_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;

#define false 0
#define true 1
#define NULL ((void *)0)
#define MAX_DATAGRAM 1024
#define NET_NAMELEN 64
#define NET_MAXMESSAGE 8192
#define NET_HEADERSIZE 8
#define NET_DATAGRAMSIZE (MAX_DATAGRAM + NET_HEADERSIZE)
#define NETFLAG_LENGTH_MASK 0x0000ffff
#define NETFLAG_DATA 0x00010000
#define NETFLAG_ACK 0x00020000
#define NETFLAG_NAK 0x00040000
#define NETFLAG_EOM 0x00080000
#define NETFLAG_UNRELIABLE 0x00100000
#define NETFLAG_CTL 0x80000000
#define NET_PROTOCOL_VERSION 3
#define CCREQ_CONNECT 0x01
#define CCREQ_SERVER_INFO 0x02
#define CCREQ_PLAYER_INFO 0x03
#define CCREQ_RULE_INFO 0x04
#define CCREP_ACCEPT 0x81
#define CCREP_REJECT 0x82
#define CCREP_SERVER_INFO 0x83
#define CCREP_PLAYER_INFO 0x84
#define CCREP_RULE_INFO 0x85
#define HOSTCACHESIZE 16
#define MAX_SCOREBOARD 16
#define key_menu 3
#define AF_INET 2

struct in_addr {
    unsigned long s_addr;
};

struct sockaddr_in {
    short sin_family;
    unsigned short sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

char *inet_ntoa(struct in_addr);
unsigned long inet_addr(const char *);

typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

struct qsockaddr {
    short sa_family;
    unsigned char sa_data[14];
};

typedef struct qsocket_s {
    struct qsocket_s *next;
    double connecttime;
    double lastMessageTime;
    double lastSendTime;
    qboolean disconnected;
    qboolean canSend;
    qboolean sendNext;
    int driver;
    int landriver;
    int socket;
    void *driverdata;
    unsigned int ackSequence;
    unsigned int sendSequence;
    unsigned int unreliableSendSequence;
    int sendMessageLength;
    byte sendMessage[NET_MAXMESSAGE];
    unsigned int receiveSequence;
    unsigned int unreliableReceiveSequence;
    int receiveMessageLength;
    byte receiveMessage[NET_MAXMESSAGE];
    struct qsockaddr addr;
    char address[NET_NAMELEN];
} qsocket_t;

typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;

typedef struct {
    char *name;
    qboolean initialized;
    int controlSock;
    int (*Init)(void);
    void (*Shutdown)(void);
    void (*Listen)(qboolean);
    int (*OpenSocket)(int);
    int (*CloseSocket)(int);
    int (*Connect)(int, struct qsockaddr *);
    int (*CheckNewConnections)(void);
    int (*Read)(int, byte *, int, struct qsockaddr *);
    int (*Write)(int, byte *, int, struct qsockaddr *);
    int (*Broadcast)(int, byte *, int);
    char *(*AddrToString)(struct qsockaddr *);
    int (*StringToAddr)(char *, struct qsockaddr *);
    int (*GetSocketAddr)(int, struct qsockaddr *);
    int (*GetNameFromAddr)(struct qsockaddr *, char *);
    int (*GetAddrFromName)(char *, struct qsockaddr *);
    int (*AddrCompare)(struct qsockaddr *, struct qsockaddr *);
    int (*GetSocketPort)(struct qsockaddr *);
    int (*SetSocketPort)(struct qsockaddr *, int);
} net_landriver_t;

typedef struct {
    char name[16];
    char map[16];
    char cname[NET_NAMELEN];
    int users;
    int maxusers;
    int driver;
    int ldriver;
    struct qsockaddr addr;
} hostcache_t;

typedef struct {
    struct {
        float frags;
    } v;
} edict_t;

typedef struct client_s {
    qboolean active;
    qboolean privileged;
    qsocket_t *netconnection;
    edict_t *edict;
    char name[32];
    int colors;
} client_t;

typedef struct {
    int maxclients;
    client_t *clients;
} server_static_t;

typedef struct {
    qboolean active;
    char name[64];
} server_t;

typedef struct {
    float deathmatch;
} globalvars_t;

typedef struct PollProcedure_s {
    struct PollProcedure_s *next;
    double nextTime;
    void (*procedure)();
    void *arg;
} PollProcedure;

typedef enum {
    src_client,
    src_command
} cmd_source_t;

extern int net_numlandrivers;
extern net_landriver_t net_landrivers[8];
extern int net_driverlevel;
extern double net_time;
extern sizebuf_t net_message;
extern qsocket_t *net_activeSockets;
extern qsocket_t *net_freeSockets;
extern int net_activeconnections;
extern int messagesSent;
extern int messagesReceived;
extern int unreliableMessagesSent;
extern int unreliableMessagesReceived;
extern int hostCacheCount;
extern hostcache_t hostcache[HOSTCACHESIZE];
extern server_static_t svs;
extern server_t sv;
extern client_t *host_client;
extern globalvars_t *pr_global_struct;
extern cvar_t hostname;
extern cvar_t *cvar_vars;
extern cmd_source_t cmd_source;
extern int key_dest;

__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) void * __cdecl memcpy(void *, const void *, unsigned __int64);
__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

unsigned int BigLong(unsigned int);
void *Q_memcpy(void *, const void *, int);
char *Q_strcpy(char *, const char *);
char *Q_strncpy(char *, const char *, int);
char *Q_strcat(char *, const char *);
int Q_strlen(const char *);
int Q_strcmp(const char *, const char *);
int Q_strcasecmp(const char *, const char *);
void SZ_Clear(sizebuf_t *);
void SZ_Write(sizebuf_t *, const void *, int);
void MSG_BeginReading(void);
int MSG_ReadLong(void);
int MSG_ReadByte(void);
char *MSG_ReadString(void);
void MSG_WriteLong(sizebuf_t *, int);
void MSG_WriteByte(sizebuf_t *, int);
void MSG_WriteString(sizebuf_t *, char *);
void Cmd_ForwardToServer(void);
int Cmd_Argc(void);
char *Cmd_Argv(int);
void Cmd_AddCommand(char *, void (*)(void));
int COM_CheckParm(char *);
void Con_Printf(char *, ...);
void Con_DPrintf(char *, ...);
void SV_ClientPrintf(char *, ...);
void Sys_Error(char *, ...);
void SCR_UpdateScreen(void);
cvar_t *Cvar_FindVar(char *);
qsocket_t *NET_NewQSocket(void);
void NET_FreeQSocket(qsocket_t *);
void NET_Close(qsocket_t *);
double SetNetTime(void);
void SchedulePollProcedure(PollProcedure *, double);

#endif
