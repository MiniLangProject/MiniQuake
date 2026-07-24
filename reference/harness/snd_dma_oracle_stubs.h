#ifndef MINIQUAKE_SND_DMA_ORACLE_STUBS_H
#define MINIQUAKE_SND_DMA_ORACLE_STUBS_H

typedef unsigned char byte;
typedef int qboolean;
typedef float vec_t;
typedef float vec3_t[3];
typedef unsigned long DWORD;
typedef long HRESULT;

#define true 1
#define false 0
#ifndef NULL
#define NULL ((void *)0)
#endif

#define MAX_QPATH 64
#define MAX_CHANNELS 128
#define MAX_DYNAMIC_CHANNELS 8
#define NUM_AMBIENTS 4
#define AMBIENT_WATER 0
#define AMBIENT_SKY 1

typedef struct cache_user_s { void *data; } cache_user_t;
typedef struct sfx_s {
    char name[MAX_QPATH];
    cache_user_t cache;
} sfx_t;
typedef struct {
    int length;
    int loopstart;
    int speed;
    int width;
    int stereo;
    byte data[1];
} sfxcache_t;
typedef struct {
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
typedef struct {
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
typedef struct cvar_s {
    char *name;
    char *string;
    qboolean archive;
    qboolean server;
    float value;
    struct cvar_s *next;
} cvar_t;
typedef struct { int memsize; } quakeparms_t;
typedef struct { byte ambient_sound_level[NUM_AMBIENTS]; } mleaf_t;
typedef struct { int marker; } model_t;
typedef struct {
    int viewentity;
    model_t *worldmodel;
} client_state_t;

typedef struct IDirectSoundBuffer IDirectSoundBuffer;
typedef IDirectSoundBuffer *LPDIRECTSOUNDBUFFER;
typedef struct {
    HRESULT (*GetStatus)(LPDIRECTSOUNDBUFFER, DWORD *);
    HRESULT (*Lock)(LPDIRECTSOUNDBUFFER, DWORD, DWORD, void **, DWORD *,
                    void **, DWORD *, DWORD);
    HRESULT (*Restore)(LPDIRECTSOUNDBUFFER);
    HRESULT (*Play)(LPDIRECTSOUNDBUFFER, DWORD, DWORD, DWORD);
    HRESULT (*Unlock)(LPDIRECTSOUNDBUFFER, void *, DWORD, void *, DWORD);
} IDirectSoundBufferVtbl;
struct IDirectSoundBuffer { IDirectSoundBufferVtbl *lpVtbl; };

#define DS_OK 0
#define DD_OK 0
#define DSERR_BUFFERLOST 1
#define DSBSTATUS_BUFFERLOST 1
#define DSBSTATUS_PLAYING 2
#define DSBPLAY_LOOPING 1

extern quakeparms_t host_parms;
extern client_state_t cl;
extern double host_frametime;
extern vec3_t vec3_origin;
extern LPDIRECTSOUNDBUFFER pDSBuf;
extern DWORD gSndBufSize;

#define VectorCopy(source,destination) do { \
    (destination)[0]=(source)[0]; \
    (destination)[1]=(source)[1]; \
    (destination)[2]=(source)[2]; \
} while (0)
#define VectorSubtract(first,second,result) do { \
    (result)[0]=(first)[0]-(second)[0]; \
    (result)[1]=(first)[1]-(second)[1]; \
    (result)[2]=(first)[2]-(second)[2]; \
} while (0)
#define DotProduct(first,second) \
    ((first)[0]*(second)[0]+(first)[1]*(second)[1]+(first)[2]*(second)[2])

int COM_CheckParm(char *parameter);
void Cmd_AddCommand(char *name, void (*function)(void));
void Cvar_RegisterVariable(cvar_t *variable);
void Cvar_Set(char *name, char *value);
void Con_Printf(char *format, ...);
void Sys_Error(char *format, ...);
void *Hunk_AllocName(int size, char *name);
int SNDDMA_Init(void);
void SNDDMA_Shutdown(void);
int SNDDMA_GetDMAPos(void);
void SNDDMA_Submit(void);
void SND_InitScaletable(void);
void S_PaintChannels(int endtime);
void IN_Accumulate(void);
void *Cache_Check(cache_user_t *cache);
sfxcache_t *S_LoadSound(sfx_t *sfx);
mleaf_t *Mod_PointInLeaf(vec3_t point, model_t *model);
float VectorNormalize(vec3_t vector);
int Q_strlen(char *text);
int Q_strcmp(char *first, char *second);
char *Q_strcpy(char *destination, char *source);
char *Q_strcat(char *destination, char *source);
char *Q_strrchr(char *text, int wanted);
float Q_atof(char *text);
void *Q_memset(void *destination, int value, int count);
char *strcpy(char *destination, const char *source);
void *memset(void *destination, int value, unsigned __int64 count);
int mq_rand(void);
#define rand mq_rand

int Cmd_Argc(void);
char *Cmd_Argv(int index);

void S_AmbientOff(void);
void S_AmbientOn(void);
void S_SoundInfo_f(void);
void S_Startup(void);
void S_Init(void);
void S_Shutdown(void);
sfx_t *S_FindName(char *name);
void S_TouchSound(char *name);
sfx_t *S_PrecacheSound(char *name);
channel_t *SND_PickChannel(int entnum, int entchannel);
void SND_Spatialize(channel_t *channel);
void S_StartSound(int entnum, int entchannel, sfx_t *sfx, vec3_t origin,
                  float volume, float attenuation);
void S_StopSound(int entnum, int entchannel);
void S_StopAllSounds(qboolean clear);
void S_StopAllSoundsC(void);
void S_ClearBuffer(void);
void S_StaticSound(sfx_t *sfx, vec3_t origin, float volume, float attenuation);
void S_UpdateAmbientSounds(void);
void S_Update(vec3_t origin, vec3_t forward, vec3_t right, vec3_t up);
void GetSoundtime(void);
void S_ExtraUpdate(void);
void S_Update_(void);
void S_Play(void);
void S_PlayVol(void);
void S_SoundList(void);
void S_LocalSound(char *sound);
void S_ClearPrecache(void);
void S_BeginPrecaching(void);
void S_EndPrecaching(void);

__declspec(dllimport) int __cdecl sprintf(char *, const char *, ...);

#endif
