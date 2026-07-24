#include "snd_mix_oracle_stubs.h"

typedef struct
{
    int length;
    int loopstart;
    int speed;
    int width;
    int stereo;
    byte data[512];
} large_sfxcache_t;

extern portable_samplepair_t paintbuffer[512];
extern int snd_scaletable[32][256];
extern int *snd_p;
extern int snd_linear_count;
extern int snd_vol;
extern short *snd_out;

int _fltused = 0;
static dma_t dma_state;
static byte dma_buffer[4096];
dma_t *shm = &dma_state;
cvar_t volume = {"volume", "1", 0, 0, 1.0f, NULL};
int paintedtime;
channel_t channels[128];
int total_channels;
static large_sfxcache_t fixture_cache;
static sfx_t fixture_sfx;

void Q_memset(void *destination, int value, int count)
{
    byte *bytes = (byte *)destination;
    int index;
    for (index = 0; index < count; index++)
        bytes[index] = (byte)value;
}

sfxcache_t *S_LoadSound(sfx_t *sfx)
{
    return (sfxcache_t *)sfx->cache.data;
}

void mix_reset(int samplebits, int channel_count, int samples)
{
    int index;
    dma_state.channels = channel_count;
    dma_state.samples = samples;
    dma_state.samplebits = samplebits;
    dma_state.speed = 22050;
    dma_state.buffer = dma_buffer;
    volume.value = 1.0f;
    paintedtime = 0;
    total_channels = 0;
    for (index = 0; index < 4096; index++)
        dma_buffer[index] = 0;
    for (index = 0; index < 512; index++)
    {
        paintbuffer[index].left = 0;
        paintbuffer[index].right = 0;
    }
    for (index = 0; index < 128; index++)
    {
        channels[index].sfx = NULL;
        channels[index].leftvol = 0;
        channels[index].rightvol = 0;
        channels[index].end = 0;
        channels[index].pos = 0;
    }
}

void mix_set_paint(int frame, int left, int right)
{
    paintbuffer[frame].left = left;
    paintbuffer[frame].right = right;
}

int mix_dma_i16(int index)
{
    short *values = (short *)dma_buffer;
    return values[index];
}

int mix_dma_u8(int index)
{
    return dma_buffer[index];
}

void mix_setup_blast(void)
{
    static int source[4];
    source[0] = 40000;
    source[1] = -40000;
    source[2] = 1000;
    source[3] = -1000;
    snd_p = source;
    snd_linear_count = 4;
    snd_vol = 256;
    snd_out = (short *)dma_buffer;
}

int mix_scale_value(int row, int value)
{
    return snd_scaletable[row][value];
}

int mix_paint8(void)
{
    fixture_cache.length = 3;
    fixture_cache.loopstart = -1;
    fixture_cache.width = 1;
    fixture_cache.data[0] = 0;
    fixture_cache.data[1] = 128;
    fixture_cache.data[2] = 255;
    channels[0].leftvol = 255;
    channels[0].rightvol = 128;
    channels[0].pos = 0;
    SND_PaintChannelFrom8(
        &channels[0], (sfxcache_t *)&fixture_cache, 3);
    return channels[0].pos;
}

int mix_paint16(void)
{
    short *samples = (short *)fixture_cache.data;
    fixture_cache.length = 3;
    fixture_cache.loopstart = -1;
    fixture_cache.width = 2;
    samples[0] = 1000;
    samples[1] = -2000;
    samples[2] = 3000;
    channels[0].leftvol = 128;
    channels[0].rightvol = 64;
    channels[0].pos = 0;
    SND_PaintChannelFrom16(
        &channels[0], (sfxcache_t *)&fixture_cache, 3);
    return channels[0].pos;
}

void mix_setup_channels(void)
{
    short *samples = (short *)fixture_cache.data;
    fixture_cache.length = 4;
    fixture_cache.loopstart = -1;
    fixture_cache.speed = 22050;
    fixture_cache.width = 2;
    fixture_cache.stereo = 0;
    samples[0] = 1000;
    samples[1] = -1000;
    samples[2] = 2000;
    samples[3] = -2000;
    fixture_sfx.cache.data = &fixture_cache;
    channels[0].sfx = &fixture_sfx;
    channels[0].leftvol = 255;
    channels[0].rightvol = 255;
    channels[0].end = 4;
    channels[0].pos = 0;
    total_channels = 1;
}

int mix_channel_active(void)
{
    return channels[0].sfx != NULL;
}

int mix_painted_time(void)
{
    return paintedtime;
}

int mix_paint_value(int index)
{
    int *values = (int *)paintbuffer;
    return values[index];
}
