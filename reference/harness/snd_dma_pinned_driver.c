#include "snd_dma_oracle_stubs.h"

int _fltused;
quakeparms_t host_parms;
client_state_t cl;
double host_frametime;
vec3_t vec3_origin;
LPDIRECTSOUNDBUFFER pDSBuf;
DWORD gSndBufSize;

extern channel_t channels[MAX_CHANNELS];
extern int total_channels;
extern int snd_blocked;
extern qboolean snd_initialized;
extern volatile dma_t *shm;
extern volatile dma_t sn;
extern vec3_t listener_origin;
extern vec3_t listener_forward;
extern vec3_t listener_right;
extern vec3_t listener_up;
extern int soundtime;
extern int paintedtime;
extern sfx_t *known_sfx;
extern int num_sfx;
extern sfx_t *ambient_sfx[NUM_AMBIENTS];
extern int sound_started;
extern qboolean fakedma;
extern cvar_t nosound;
extern cvar_t precache;
extern cvar_t loadas8bit;
extern cvar_t ambient_level;
extern cvar_t ambient_fade;
extern cvar_t snd_noextraupdate;
extern cvar_t snd_show;
extern cvar_t _snd_mixahead;

typedef struct {
    int length;
    int loopstart;
    int speed;
    int width;
    int stereo;
    byte data[64];
} fixture_cache_t;

static dma_t fixture_dma;
static byte dma_bytes[65544];
static sfx_t fixture_sfx[512];
static fixture_cache_t caches[16];
static int cache_count;
static model_t fixture_world;
static mleaf_t fixture_leaf;
static int point_leaf_enabled;
static int nosound_argument;
static int simsound_argument;
static int dma_init_result;
static int dma_init_calls;
static int dma_shutdown_calls;
static int dma_position;
static int submit_calls;
static int paint_calls;
static int paint_endtime;
static int scale_calls;
static int accumulate_calls;
static int load_calls;
static int touch_calls;
static int print_calls;
static int print_checksum;
static int command_count;
static int command_checksum;
static int cvar_count;
static int cvar_checksum;
static int fatal_calls;
static int random_value;
static int command_argc;
static char *command_argv[8];

static int text_equal(const char *first, const char *second)
{
    int index=0;
    while (first[index] && second[index] && first[index]==second[index]) index++;
    return first[index]==0 && second[index]==0;
}

static int text_checksum(const char *text)
{
    int result=0;
    int index=0;
    while (text[index]) {
        result+=(index+1)*(unsigned char)text[index];
        index++;
    }
    return result;
}

static void zero(void *target, int count)
{
    byte *data=(byte *)target;
    int index;
    for (index=0;index<count;index++) data[index]=0;
}

static void copy_text(char *destination, const char *source)
{
    int index=0;
    while ((destination[index]=source[index])!=0) index++;
}

static float parse_float(const char *text)
{
    float value=0;
    float scale=1;
    int sign=1;
    if (!text) return 0;
    if (*text=='-') { sign=-1;text++; }
    while (*text>='0' && *text<='9') {
        value=value*10+(*text-'0');
        text++;
    }
    if (*text=='.') {
        text++;
        while (*text>='0' && *text<='9') {
            scale*=0.1f;
            value+=(*text-'0')*scale;
            text++;
        }
    }
    return sign*value;
}

int COM_CheckParm(char *parameter)
{
    if (text_equal(parameter,"-nosound")) return nosound_argument;
    if (text_equal(parameter,"-simsound")) return simsound_argument;
    return 0;
}

void Cmd_AddCommand(char *name, void (*function)(void))
{
    (void)function;
    command_count++;
    command_checksum+=command_count*text_checksum(name);
}

void Cvar_RegisterVariable(cvar_t *variable)
{
    cvar_count++;
    cvar_checksum+=cvar_count*text_checksum(variable->name);
    variable->value=parse_float(variable->string);
}

void Cvar_Set(char *name, char *value)
{
    if (text_equal(name,"loadas8bit")) {
        loadas8bit.string=value;
        loadas8bit.value=parse_float(value);
    }
}

void Con_Printf(char *format, ...)
{
    print_calls++;
    print_checksum+=text_checksum(format);
}

void Sys_Error(char *format, ...)
{
    (void)format;
    fatal_calls++;
}

void *Hunk_AllocName(int size, char *name)
{
    (void)name;
    if (size==(int)(512*sizeof(sfx_t))) {
        zero(fixture_sfx,sizeof(fixture_sfx));
        return fixture_sfx;
    }
    if (size==(int)sizeof(dma_t)) {
        zero(&fixture_dma,sizeof(fixture_dma));
        return &fixture_dma;
    }
    if (size==(1<<16)) {
        zero(dma_bytes,sizeof(dma_bytes));
        return dma_bytes;
    }
    return dma_bytes;
}

int SNDDMA_Init(void)
{
    dma_init_calls++;
    if (!dma_init_result) return 0;
    shm=&fixture_dma;
    return 1;
}

void SNDDMA_Shutdown(void) { dma_shutdown_calls++; }
int SNDDMA_GetDMAPos(void) { return dma_position; }
void SNDDMA_Submit(void) { submit_calls++; }
void SND_InitScaletable(void) { scale_calls++; }
void S_PaintChannels(int endtime) { paint_calls++;paint_endtime=endtime;paintedtime=endtime; }
void IN_Accumulate(void) { accumulate_calls++; }

void *Cache_Check(cache_user_t *cache)
{
    touch_calls++;
    return cache->data;
}

sfxcache_t *S_LoadSound(sfx_t *sfx)
{
    fixture_cache_t *cache;
    load_calls++;
    if (sfx->cache.data) return (sfxcache_t *)sfx->cache.data;
    cache=&caches[cache_count++&15];
    zero(cache,sizeof(*cache));
    cache->length=1000;
    cache->loopstart=0;
    cache->speed=22050;
    cache->width=2;
    cache->stereo=0;
    sfx->cache.data=cache;
    return (sfxcache_t *)cache;
}

mleaf_t *Mod_PointInLeaf(vec3_t point, model_t *model)
{
    (void)point;(void)model;
    if (!point_leaf_enabled) return NULL;
    return &fixture_leaf;
}

float VectorNormalize(vec3_t vector)
{
    float length;
    float square=vector[0]*vector[0]+vector[1]*vector[1]+vector[2]*vector[2];
    if (square<=0) return 0;
    /* The fixtures use axis-aligned vectors, so their exact length avoids
       importing a second math implementation into the service boundary. */
    if (vector[0]!=0 && vector[1]==0 && vector[2]==0)
        length=vector[0]<0?-vector[0]:vector[0];
    else if (vector[1]!=0 && vector[0]==0 && vector[2]==0)
        length=vector[1]<0?-vector[1]:vector[1];
    else if (vector[2]!=0 && vector[0]==0 && vector[1]==0)
        length=vector[2]<0?-vector[2]:vector[2];
    else
        length=1;
    vector[0]/=length;vector[1]/=length;vector[2]/=length;
    return length;
}

int Q_strlen(char *text)
{
    int length=0;
    while (text[length]) length++;
    return length;
}

int Q_strcmp(char *first, char *second)
{
    int index=0;
    while (first[index] && first[index]==second[index]) index++;
    return (unsigned char)first[index]-(unsigned char)second[index];
}

char *Q_strcpy(char *destination, char *source) { copy_text(destination,source);return destination; }
char *Q_strcat(char *destination, char *source)
{
    int length=Q_strlen(destination);
    copy_text(destination+length,source);
    return destination;
}
char *Q_strrchr(char *text, int wanted)
{
    char *found=NULL;
    while (*text) { if (*text==wanted) found=text;text++; }
    return found;
}
float Q_atof(char *text) { return parse_float(text); }
void *Q_memset(void *destination, int value, int count)
{
    byte *data=(byte *)destination;
    int index;
    for (index=0;index<count;index++) data[index]=(byte)value;
    return destination;
}
int mq_rand(void) { return random_value; }
int Cmd_Argc(void) { return command_argc; }
char *Cmd_Argv(int index)
{
    static char empty[1]={0};
    if (index<0 || index>=command_argc) return empty;
    return command_argv[index];
}

static void attach_cache(sfx_t *sfx, int length, int loopstart, int width)
{
    fixture_cache_t *cache=&caches[cache_count++&15];
    zero(cache,sizeof(*cache));
    cache->length=length;
    cache->loopstart=loopstart;
    cache->speed=22050;
    cache->width=width;
    cache->stereo=0;
    sfx->cache.data=cache;
}

static void base_reset(void)
{
    int index;
    zero(channels,sizeof(channel_t)*MAX_CHANNELS);
    zero(fixture_sfx,sizeof(fixture_sfx));
    zero(caches,sizeof(caches));
    zero(&fixture_dma,sizeof(fixture_dma));
    zero(dma_bytes,sizeof(dma_bytes));
    zero(&fixture_leaf,sizeof(fixture_leaf));
    fixture_dma.gamealive=true;
    fixture_dma.soundalive=true;
    fixture_dma.channels=2;
    fixture_dma.samples=32768;
    fixture_dma.submission_chunk=1;
    fixture_dma.samplebits=16;
    fixture_dma.speed=22050;
    fixture_dma.buffer=dma_bytes;
    shm=&fixture_dma;
    known_sfx=fixture_sfx;
    num_sfx=0;
    total_channels=NUM_AMBIENTS+MAX_DYNAMIC_CHANNELS;
    snd_blocked=0;
    snd_initialized=true;
    sound_started=1;
    fakedma=false;
    soundtime=0;
    paintedtime=100;
    listener_origin[0]=listener_origin[1]=listener_origin[2]=0;
    listener_forward[0]=1;listener_forward[1]=listener_forward[2]=0;
    listener_right[0]=0;listener_right[1]=-1;listener_right[2]=0;
    listener_up[0]=listener_up[1]=0;listener_up[2]=1;
    cl.viewentity=1;
    cl.worldmodel=&fixture_world;
    host_frametime=0.1;
    host_parms.memsize=16*1024*1024;
    point_leaf_enabled=1;
    for (index=0;index<NUM_AMBIENTS;index++) fixture_leaf.ambient_sound_level[index]=0;
    nosound.value=0;
    precache.value=1;
    loadas8bit.value=0;
    ambient_level.value=0.3f;
    ambient_fade.value=100;
    snd_noextraupdate.value=0;
    snd_show.value=0;
    _snd_mixahead.value=0.1f;
    nosound_argument=simsound_argument=0;
    dma_init_result=1;
    dma_init_calls=dma_shutdown_calls=submit_calls=paint_calls=paint_endtime=0;
    scale_calls=accumulate_calls=load_calls=touch_calls=0;
    print_calls=print_checksum=command_count=command_checksum=0;
    cvar_count=cvar_checksum=fatal_calls=0;
    random_value=17;
    dma_position=0;
    command_argc=0;
    cache_count=0;
    for (index=0;index<NUM_AMBIENTS;index++) ambient_sfx[index]=NULL;
    S_AmbientOn();
}

static char *emit(
    char *cursor, const char *function_name, const char *case_name,
    int i0, int i1, int i2, int i3, float f0, float f1, float f2, float f3)
{
    cursor+=sprintf(
        cursor,
        "{\"function\":\"%s\",\"case\":\"%s\",\"i0\":%d,\"i1\":%d,"
        "\"i2\":%d,\"i3\":%d,\"f0\":%.9g,\"f1\":%.9g,"
        "\"f2\":%.9g,\"f3\":%.9g}\n",
        function_name,case_name,i0,i1,i2,i3,f0,f1,f2,f3);
    return cursor;
}

__declspec(dllexport) int __cdecl snd_dma_oracle_jsonl(char *output, int capacity)
{
    char *cursor=output;
    sfx_t *first;
    sfx_t *second;
    channel_t *picked;
    vec3_t origin={0,0,0};
    vec3_t forward={1,0,0};
    vec3_t right={0,-1,0};
    vec3_t up={0,0,1};
    int before;
    (void)capacity;

    base_reset();fixture_leaf.ambient_sound_level[0]=255;
    channels[0].master_vol=5;S_AmbientOff();S_UpdateAmbientSounds();
    cursor=emit(cursor,"S_AmbientOff","disabled",channels[0].master_vol,channels[0].sfx!=NULL,0,0,0,0,0,0);
    S_AmbientOn();ambient_sfx[0]=S_FindName("ambient.wav");S_UpdateAmbientSounds();
    cursor=emit(cursor,"S_AmbientOn","enabled",channels[0].master_vol,channels[0].sfx==ambient_sfx[0],0,0,0,0,0,0);

    base_reset();S_SoundInfo_f();
    cursor=emit(cursor,"S_SoundInfo_f","started",print_calls,print_checksum,0,0,0,0,0,0);
    base_reset();sound_started=0;S_SoundInfo_f();
    cursor=emit(cursor,"S_SoundInfo_f","stopped",print_calls,print_checksum,0,0,0,0,0,0);

    base_reset();sound_started=0;snd_initialized=0;S_Startup();
    before=dma_init_calls;snd_initialized=1;fakedma=1;S_Startup();
    cursor=emit(cursor,"S_Startup","gates",before,dma_init_calls,sound_started,0,0,0,0,0);

    base_reset();sound_started=0;snd_initialized=0;simsound_argument=1;host_parms.memsize=4*1024*1024;S_Init();
    cursor=emit(cursor,"S_Init","simsound",command_count,cvar_count,shm->speed,shm->samples,
        loadas8bit.value,shm->samplebits,scale_calls,total_channels);
    cursor=emit(cursor,"S_Init","registrations",command_count,cvar_count,
        command_checksum,cvar_checksum,0,0,0,0);
    base_reset();sound_started=0;snd_initialized=0;nosound_argument=1;S_Init();
    cursor=emit(cursor,"S_Init","nosound",snd_initialized,sound_started,
        command_count,cvar_count,0,0,0,0);

    base_reset();S_Shutdown();
    cursor=emit(cursor,"S_Shutdown","hardware",sound_started,shm==NULL,dma_shutdown_calls,fixture_dma.gamealive,0,0,0,0);

    base_reset();first=S_FindName("one.wav");second=S_FindName("one.wav");
    cursor=emit(cursor,"S_FindName","identity",num_sfx,first==second,text_checksum(first->name),0,0,0,0,0);

    base_reset();first=S_FindName("touch.wav");attach_cache(first,10,-1,1);S_TouchSound("touch.wav");
    cursor=emit(cursor,"S_TouchSound","resident",first->cache.data!=NULL,num_sfx,0,0,0,0,0,0);

    base_reset();first=S_FindName("pre.wav");attach_cache(first,1000,0,2);second=S_PrecacheSound("pre.wav");
    cursor=emit(cursor,"S_PrecacheSound","resident",second==first,num_sfx,
        ((sfxcache_t *)first->cache.data)->length,first->cache.data!=NULL,0,0,0,0);

    base_reset();first=S_FindName("pick.wav");attach_cache(first,100,0,2);
    for (before=NUM_AMBIENTS;before<NUM_AMBIENTS+MAX_DYNAMIC_CHANNELS;before++) {
        channels[before].sfx=first;channels[before].entnum=100+before;
        channels[before].entchannel=2;channels[before].end=200+before;
    }
    channels[NUM_AMBIENTS].entnum=1;channels[NUM_AMBIENTS].end=101;
    picked=SND_PickChannel(999,2);
    cursor=emit(cursor,"SND_PickChannel","protect-listener",(int)(picked-channels),
        picked->sfx==NULL,picked->entnum,picked->end,0,0,0,0);
    base_reset();first=S_FindName("override.wav");attach_cache(first,100,0,2);
    channels[6].sfx=first;channels[6].entnum=42;channels[6].entchannel=2;
    picked=SND_PickChannel(42,2);
    cursor=emit(cursor,"SND_PickChannel","entity-override",(int)(picked-channels),
        picked->sfx==NULL,picked->entnum,picked->entchannel,0,0,0,0);

    base_reset();channels[4].origin[1]=-500;channels[4].dist_mult=0.001f;
    channels[4].master_vol=255;channels[4].entnum=2;SND_Spatialize(&channels[4]);
    cursor=emit(cursor,"SND_Spatialize","stereo",channels[4].leftvol,channels[4].rightvol,0,0,0,0,0,0);
    channels[4].master_vol=201;channels[4].entnum=1;SND_Spatialize(&channels[4]);
    cursor=emit(cursor,"SND_Spatialize","listener",channels[4].leftvol,channels[4].rightvol,0,0,0,0,0,0);

    base_reset();first=S_FindName("start.wav");attach_cache(first,1000,-1,2);
    S_StartSound(2,3,first,origin,0.5f,1);
    cursor=emit(cursor,"S_StartSound","dynamic",channels[4].sfx==first,channels[4].master_vol,
        channels[4].end,channels[4].pos,channels[4].dist_mult,0,0,0);
    base_reset();first=S_FindName("duplicate.wav");attach_cache(first,1000,-1,2);
    /* First rand() value for the target Win32 MSVC runtime with seed 1. */
    random_value=41;S_StartSound(2,1,first,origin,1,1);
    S_StartSound(3,1,first,origin,1,1);
    cursor=emit(cursor,"S_StartSound","duplicate-offset",channels[5].pos,
        channels[5].end,channels[4].pos,channels[4].end,0,0,0,0);

    base_reset();first=S_FindName("stop.wav");channels[3].sfx=first;
    channels[3].entnum=7;channels[3].entchannel=9;S_StopSound(7,9);
    cursor=emit(cursor,"S_StopSound","first-eight-quirk",channels[3].sfx==NULL,channels[3].end,0,0,0,0,0,0);

    base_reset();first=S_FindName("all.wav");channels[20].sfx=first;S_StopAllSounds(0);
    cursor=emit(cursor,"S_StopAllSounds","noclear",total_channels,channels[20].sfx==NULL,dma_bytes[0],0,0,0,0,0);

    base_reset();dma_bytes[0]=77;first=S_FindName("allc.wav");channels[4].sfx=first;S_StopAllSoundsC();
    cursor=emit(cursor,"S_StopAllSoundsC","clear",total_channels,channels[4].sfx==NULL,dma_bytes[0],0,0,0,0,0);

    base_reset();fixture_dma.samplebits=8;fixture_dma.samples=8;
    for (before=0;before<20;before++) dma_bytes[before]=17;S_ClearBuffer();
    cursor=emit(cursor,"S_ClearBuffer","eight-bit-size",dma_bytes[0],dma_bytes[7],dma_bytes[8],dma_bytes[19],0,0,0,0);

    base_reset();first=S_FindName("static.wav");attach_cache(first,500,20,2);
    origin[0]=100;S_StaticSound(first,origin,200,64);
    cursor=emit(cursor,"S_StaticSound","looped",total_channels,channels[12].sfx==first,
        channels[12].master_vol,channels[12].end,channels[12].dist_mult,0,0,0);
    origin[0]=0;
    base_reset();first=S_FindName("oneshot.wav");attach_cache(first,500,-1,2);
    S_StaticSound(first,origin,200,64);
    cursor=emit(cursor,"S_StaticSound","not-looped",total_channels,
        channels[12].sfx==NULL,print_calls,0,0,0,0,0);

    base_reset();ambient_sfx[0]=S_FindName("water.wav");fixture_leaf.ambient_sound_level[0]=255;
    channels[0].master_vol=5;S_UpdateAmbientSounds();
    cursor=emit(cursor,"S_UpdateAmbientSounds","fade",channels[0].master_vol,
        channels[0].leftvol,channels[0].rightvol,channels[0].sfx==ambient_sfx[0],0,0,0,0);
    channels[0].master_vol=33;channels[0].sfx=first;cl.worldmodel=NULL;
    S_UpdateAmbientSounds();
    cursor=emit(cursor,"S_UpdateAmbientSounds","no-world",channels[0].master_vol,
        channels[0].sfx==first,0,0,0,0,0,0);

    base_reset();first=S_FindName("torch.wav");attach_cache(first,500,0,2);
    total_channels=14;channels[12].sfx=first;channels[12].origin[0]=100;
    channels[12].master_vol=100;channels[12].dist_mult=0.001f;
    channels[13].sfx=first;channels[13].origin[0]=100;
    channels[13].master_vol=100;channels[13].dist_mult=0.001f;
    _snd_mixahead.value=0;dma_position=200;paintedtime=100;
    S_Update(origin,forward,right,up);
    cursor=emit(cursor,"S_Update","combine",channels[12].leftvol,channels[13].leftvol,
        paint_calls,paint_endtime,listener_forward[0],listener_right[1],0,0);

    base_reset();dma_position=30000;GetSoundtime();before=soundtime;
    dma_position=100;GetSoundtime();
    cursor=emit(cursor,"GetSoundtime","wrap",before,soundtime,0,0,0,0,0,0);

    base_reset();dma_position=400;paintedtime=0;_snd_mixahead.value=0;S_Update_();
    cursor=emit(cursor,"S_Update_","mix",soundtime,paintedtime,paint_calls,submit_calls,0,0,0,0);

    base_reset();dma_position=400;paintedtime=0;_snd_mixahead.value=0;S_ExtraUpdate();
    cursor=emit(cursor,"S_ExtraUpdate","windows",accumulate_calls,paint_calls,submit_calls,paintedtime,0,0,0,0);
    base_reset();snd_noextraupdate.value=1;S_ExtraUpdate();
    cursor=emit(cursor,"S_ExtraUpdate","disabled",accumulate_calls,paint_calls,
        submit_calls,paintedtime,0,0,0,0);

    base_reset();first=S_FindName("beep.wav");attach_cache(first,1000,-1,2);
    second=S_FindName("other.wav");attach_cache(second,1000,-1,2);
    command_argc=3;command_argv[0]="play";command_argv[1]="beep";command_argv[2]="other.wav";S_Play();
    cursor=emit(cursor,"S_Play","extension",num_sfx,
        (channels[4].sfx!=NULL)+(channels[5].sfx!=NULL),
        channels[4].entnum,channels[5].entnum,text_checksum(known_sfx[0].name),text_checksum(known_sfx[1].name),0,0);
    base_reset();nosound.value=1;command_argc=2;command_argv[0]="play";command_argv[1]="missing";S_Play();
    nosound.value=0;first=S_FindName("after.wav");attach_cache(first,1000,-1,2);
    command_argv[1]="after";S_Play();
    cursor=emit(cursor,"S_Play","null-hash",channels[4].entnum,
        channels[4].sfx==first,num_sfx,0,0,0,0,0);

    base_reset();first=S_FindName("beep.wav");attach_cache(first,1000,-1,2);
    command_argc=3;command_argv[0]="playvol";command_argv[1]="beep";command_argv[2]="0.5";S_PlayVol();
    cursor=emit(cursor,"S_PlayVol","volume",num_sfx,channels[4].master_vol,
        channels[4].entnum,channels[4].sfx==first,0,0,0,0);
    base_reset();first=S_FindName("beep.wav");attach_cache(first,1000,-1,2);
    command_argc=2;command_argv[0]="playvol";command_argv[1]="beep";S_PlayVol();
    second=S_FindName("after.wav");attach_cache(second,1000,-1,2);
    command_argc=3;command_argv[1]="after";command_argv[2]="1";S_PlayVol();
    cursor=emit(cursor,"S_PlayVol","dangling-volume",channels[4].sfx==second,
        channels[4].entnum,channels[4].master_vol,num_sfx,0,0,0,0);

    base_reset();first=S_FindName("listed.wav");attach_cache(first,10,0,2);S_SoundList();
    cursor=emit(cursor,"S_SoundList","resident",num_sfx,print_calls,print_checksum,0,0,0,0,0);

    base_reset();first=S_FindName("local.wav");attach_cache(first,10,-1,2);S_LocalSound("local.wav");
    cursor=emit(cursor,"S_LocalSound","listener",channels[4].entnum,channels[4].entchannel,
        channels[4].master_vol,channels[4].sfx==first,0,0,0,0);

    base_reset();before=num_sfx;S_ClearPrecache();
    cursor=emit(cursor,"S_ClearPrecache","noop",num_sfx,before,0,0,0,0,0,0);
    S_BeginPrecaching();
    cursor=emit(cursor,"S_BeginPrecaching","noop",num_sfx,before,0,0,0,0,0,0);
    S_EndPrecaching();
    cursor=emit(cursor,"S_EndPrecaching","noop",num_sfx,before,0,0,0,0,0,0);

    *cursor=0;
    return (int)(cursor-output);
}
