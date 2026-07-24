#ifndef MINIQUAKE_ZONE_ORACLE_STUBS_H
#define MINIQUAKE_ZONE_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef struct cache_user_s {
    void *data;
} cache_user_t;

#define false 0
#define true 1
#define NULL ((void *)0)

extern int com_argc;
extern char **com_argv;

__declspec(dllimport) void * __cdecl memset(void *, int, unsigned __int64);
__declspec(dllimport) void * __cdecl memcpy(void *, const void *, unsigned __int64);
__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);
int mq_strncmp(const char *, const char *, unsigned __int64);
char *mq_strncpy(char *, const char *, unsigned __int64);
#define strncmp mq_strncmp
#define strncpy mq_strncpy

void Sys_Error(char *, ...);
void Con_Printf(char *, ...);
void Con_DPrintf(char *, ...);
void *Q_memset(void *, int, int);
void *Q_memcpy(void *, const void *, int);
char *Q_strncpy(char *, const char *, int);
void Cmd_AddCommand(char *, void (*)(void));
int COM_CheckParm(char *);
int Q_atoi(char *);
void R_FreeTextures(void);

void Z_CheckHeap(void);
void *Z_TagMalloc(int, int);
void Hunk_FreeToHighMark(int);
void Cache_Free(cache_user_t *);

#endif
