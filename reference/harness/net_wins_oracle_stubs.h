#ifndef MINIQUAKE_NET_WINS_ORACLE_STUBS_H
#define MINIQUAKE_NET_WINS_ORACLE_STUBS_H

#define PASCAL
#define FAR
#define WINAPI
#define NULL ((void *)0)
#define false 0
#define true 1
#define FALSE 0
#define TRUE 1
#define MAX_DATAGRAM 1024
#define NET_NAMELEN 64
#define AF_INET 2
#define PF_INET 2
#define SOCK_DGRAM 2
#define IPPROTO_UDP 17
#define FIONBIO 0x8004667e
#define SOL_SOCKET 0xffff
#define SO_BROADCAST 0x0020
#define MSG_PEEK 2
#define SOCKET_ERROR -1
#define WSAEWOULDBLOCK 10035
#define WSAECONNREFUSED 10061
#define INADDR_ANY 0x00000000UL
#define INADDR_NONE 0xffffffffUL
#define INADDR_BROADCAST 0xffffffffUL
#define PM_REMOVE 1

typedef unsigned char byte;
typedef unsigned short WORD;
typedef unsigned long u_long;
typedef int qboolean;
typedef int BOOL;
typedef int SOCKET;
typedef void *HINSTANCE;

typedef struct {
    int unused;
} WSADATA;
typedef WSADATA *LPWSADATA;

typedef struct {
    int unused;
} MSG;

struct in_addr {
    unsigned long s_addr;
};

struct sockaddr {
    unsigned short sa_family;
    char sa_data[14];
};

struct sockaddr_in {
    short sin_family;
    unsigned short sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

struct qsockaddr {
    short sa_family;
    unsigned char sa_data[14];
};

struct hostent {
    char *h_name;
    char **h_aliases;
    short h_addrtype;
    short h_length;
    char **h_addr_list;
};
#define h_addr h_addr_list[0]

typedef struct {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

extern int com_argc;
extern char **com_argv;
extern int net_hostport;
extern char my_tcpip_address[64];
extern qboolean tcpipAvailable;
extern cvar_t hostname;

#define MAKEWORD(low, high) ((WORD)(((byte)(low)) | ((WORD)((byte)(high))) << 8))

__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) void * __cdecl memcpy(void *, const void *, unsigned __int64);
__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
__declspec(dllimport) int __cdecl sscanf(const char *, const char *, ...);
__declspec(dllimport) char * __cdecl strcpy(char *, const char *);

double Sys_FloatTime(void);
void Con_SafePrintf(char *, ...);
void Con_DPrintf(char *, ...);
void Con_Printf(char *, ...);
void Sys_Error(char *, ...);
int COM_CheckParm(char *);
int Q_strcmp(const char *, const char *);
int Q_atoi(char *);
void Q_memset(void *, int, int);
char *Q_strcpy(char *, const char *);
char *Q_strncpy(char *, const char *, int);
void Cvar_Set(char *, char *);
void *LoadLibrary(char *);
void *GetProcAddress(void *, char *);
int bind(SOCKET, const struct sockaddr *, int);
unsigned short htons(unsigned short);
unsigned short ntohs(unsigned short);
unsigned long htonl(unsigned long);
unsigned long ntohl(unsigned long);
unsigned long inet_addr(const char *);
int WSASetBlockingHook(BOOL (PASCAL FAR *)(void));
int WSAUnhookBlockingHook(void);
int WSACancelBlockingCall(void);
BOOL PeekMessage(MSG *, void *, int, int, int);
BOOL TranslateMessage(const MSG *);
long DispatchMessage(const MSG *);
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

#endif
