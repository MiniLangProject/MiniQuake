#ifndef MINIQUAKE_SND_MEM_ORACLE_STUBS_H
#define MINIQUAKE_SND_MEM_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
#ifndef NULL
#define NULL ((void *)0)
#endif
#define MAX_QPATH 64
#define LittleShort(value) (value)

typedef struct cache_user_s
{
    void *data;
} cache_user_t;

typedef struct sfx_s
{
    char name[MAX_QPATH];
    cache_user_t cache;
} sfx_t;

typedef struct
{
    int length;
    int loopstart;
    int speed;
    int width;
    int stereo;
    byte data[1];
} sfxcache_t;

typedef struct
{
    qboolean gamealive;
    qboolean soundalive;
    qboolean splitbuffer;
    int channels;
    int samples;
    int submission_chunk;
    int samplepos;
    int samplebits;
    int speed;
    byte *buffer;
} dma_t;

typedef struct
{
    int rate;
    int width;
    int channels;
    int loopstart;
    int samples;
    int dataofs;
} wavinfo_t;

typedef struct
{
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

extern dma_t *shm;
extern cvar_t loadas8bit;
extern int com_filesize;

void *Cache_Check(cache_user_t *cache);
void *Cache_Alloc(cache_user_t *cache, int size, char *name);
byte *COM_LoadStackFile(char *name, void *buffer, int size);
void Q_strcpy(char *destination, const char *source);
void Q_strcat(char *destination, const char *source);
int Q_strncmp(const char *first, const char *second, int count);
int mq_strncmp(const char *first, const char *second, int count);
#define strncmp mq_strncmp
void Con_Printf(char *format, ...);
void Sys_Error(char *format, ...);
void *memcpy(void *destination, const void *source, unsigned __int64 count);
void *memset(void *destination, int value, unsigned __int64 count);

void ResampleSfx(sfx_t *sfx, int inrate, int inwidth, byte *data);
sfxcache_t *S_LoadSound(sfx_t *sfx);
short GetLittleShort(void);
int GetLittleLong(void);
void FindNextChunk(char *name);
void FindChunk(char *name);
void DumpChunks(void);
wavinfo_t GetWavinfo(char *name, byte *wav, int wavlength);

#endif
