#ifndef MINIQUAKE_NET_LOOP_ORACLE_STUBS_H
#define MINIQUAKE_NET_LOOP_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
#define false 0
#define true 1
#ifndef NULL
#define NULL ((void *)0)
#endif

#define NET_MAXMESSAGE 8192
#define HOSTCACHESIZE 8
#define ca_dedicated 3

typedef struct
{
    qboolean allowoverflow;
    qboolean overflowed;
    byte *data;
    int maxsize;
    int cursize;
} sizebuf_t;

typedef struct qsocket_s
{
    char address[64];
    int receiveMessageLength;
    int sendMessageLength;
    qboolean canSend;
    void *driverdata;
    byte receiveMessage[NET_MAXMESSAGE];
} qsocket_t;

typedef struct
{
    int state;
} client_static_t;

typedef struct
{
    qboolean active;
    char name[64];
} server_t;

typedef struct
{
    int maxclients;
} server_static_t;

typedef struct
{
    char *name;
    char *string;
    int archive;
    int server;
    float value;
    void *next;
} cvar_t;

typedef struct
{
    char name[16];
    char map[16];
    char cname[32];
    int users;
    int maxusers;
    int driver;
} hostcache_t;

extern client_static_t cls;
extern server_t sv;
extern server_static_t svs;
extern cvar_t hostname;
extern int hostCacheCount;
extern hostcache_t hostcache[HOSTCACHESIZE];
extern int net_activeconnections;
extern int net_driverlevel;
extern sizebuf_t net_message;

qsocket_t *NET_NewQSocket(void);
void Con_Printf(char *format, ...);
void Sys_Error(char *format, ...);
int Q_strcmp(const char *first, const char *second);
void Q_strcpy(char *destination, const char *source);
void Q_memcpy(void *destination, const void *source, int count);
void SZ_Clear(sizebuf_t *buffer);
void SZ_Write(sizebuf_t *buffer, const void *data, int length);

#endif
