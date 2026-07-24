#ifndef MINIQUAKE_NET_MAIN_ORACLE_STUBS_H
#define MINIQUAKE_NET_MAIN_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;

#define false 0
#define true 1
#define NULL ((void *)0)
#define NET_NAMELEN 64
#define HOSTCACHESIZE 16
#define NET_MAXMESSAGE 8192
#define MAX_SCOREBOARD 16
#define ca_dedicated 2
#define VCR_OP_CONNECT 1
#define VCR_OP_GETMESSAGE 2
#define VCR_OP_SENDMESSAGE 3
#define VCR_OP_CANSENDMESSAGE 4

typedef struct sizebuf_s {
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

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
    char address[NET_NAMELEN];
    unsigned int ackSequence;
    unsigned int sendSequence;
    unsigned int unreliableSendSequence;
    int sendMessageLength;
    unsigned int receiveSequence;
    unsigned int unreliableReceiveSequence;
    int receiveMessageLength;
} qsocket_t;

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

typedef struct PollProcedure_s {
    struct PollProcedure_s *next;
    double nextTime;
    void (*procedure)();
    void *arg;
} PollProcedure;

typedef struct {
    qboolean initialized;
    int controlSock;
    int (*Init)(void);
    void (*Listen)(qboolean);
    void (*SearchForHosts)(qboolean);
    qsocket_t *(*Connect)(char *);
    qsocket_t *(*CheckNewConnections)(void);
    void (*Close)(qsocket_t *);
    int (*QGetMessage)(qsocket_t *);
    int (*QSendMessage)(qsocket_t *, sizebuf_t *);
    int (*SendUnreliableMessage)(qsocket_t *, sizebuf_t *);
    qboolean (*CanSendMessage)(qsocket_t *);
    void (*Shutdown)(void);
} net_driver_t;

typedef struct {
    char name[16];
    char map[16];
    char cname[NET_NAMELEN];
    int users;
    int maxusers;
} hostcache_t;

typedef struct {
    qsocket_t *netconnection;
    qboolean active;
} client_t;

typedef struct {
    int maxclients;
    int maxclientslimit;
    client_t *clients;
} server_static_t;

typedef struct {
    qboolean active;
} server_t;

typedef struct {
    int state;
} client_static_t;

extern int com_argc;
extern char **com_argv;
extern int net_numdrivers;
extern net_driver_t net_drivers[4];
extern server_static_t svs;
extern server_t sv;
extern client_static_t cls;
extern client_t *host_client;
extern double host_time;
extern int hostCacheCount;
extern hostcache_t hostcache[HOSTCACHESIZE];

__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

double Sys_FloatTime(void);
void Sys_Error(char *, ...);
void Con_Printf(char *, ...);
void Con_DPrintf(char *, ...);
void *Hunk_AllocName(int, char *);
void SZ_Alloc(sizebuf_t *, int);
void Cvar_RegisterVariable(cvar_t *);
void Cmd_AddCommand(char *, void (*)(void));
int COM_CheckParm(char *);
int Cmd_Argc(void);
char *Cmd_Argv(int);
int Q_atoi(char *);
char *Q_strcpy(char *, const char *);
int Q_strcasecmp(const char *, const char *);
void Cbuf_AddText(char *);
void Cvar_Set(char *, char *);
int Sys_FileWrite(int, void *, int);
void Sys_FileClose(int);
int VCR_Init(void);
void PrintStats(qsocket_t *);
void NET_Poll(void);
void SchedulePollProcedure(PollProcedure *, double);

#endif
