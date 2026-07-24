#ifndef MINIQUAKE_SND_MIX_ORACLE_STUBS_H
#define MINIQUAKE_SND_MIX_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec_t;
typedef vec_t vec3_t[3];
#ifndef NULL
#define NULL ((void *)0)
#endif

typedef struct
{
    int left;
    int right;
} portable_samplepair_t;

typedef struct cache_user_s
{
    void *data;
} cache_user_t;

typedef struct sfx_s
{
    char name[64];
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
    sfx_t *sfx;
    int leftvol;
    int rightvol;
    int end;
    int pos;
    int looping;
    int entnum;
    int entchannel;
    vec3_t origin;
    vec_t dist_mult;
    int master_vol;
} channel_t;

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
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    void *next;
} cvar_t;

extern dma_t *shm;
extern cvar_t volume;
extern int paintedtime;
extern channel_t channels[];
extern int total_channels;

void Q_memset(void *destination, int value, int count);
sfxcache_t *S_LoadSound(sfx_t *sfx);

void Snd_WriteLinearBlastStereo16(void);
void S_TransferStereo16(int endtime);
void S_TransferPaintBuffer(int endtime);
void S_PaintChannels(int endtime);
void SND_InitScaletable(void);
void SND_PaintChannelFrom8(channel_t *channel, sfxcache_t *cache, int count);
void SND_PaintChannelFrom16(channel_t *channel, sfxcache_t *cache, int count);

#endif
