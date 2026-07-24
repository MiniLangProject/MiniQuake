#include "snd_mem_oracle_stubs.h"

typedef struct
{
    int length;
    int loopstart;
    int speed;
    int width;
    int stereo;
    byte data[512];
} large_sfxcache_t;

extern byte *data_p;
extern byte *iff_end;
extern byte *last_chunk;
extern byte *iff_data;
extern int iff_chunk_len;

int _fltused = 0;
static dma_t dma_state;
dma_t *shm = &dma_state;
cvar_t loadas8bit = {"loadas8bit", "0", 0, 0, 0.0f, NULL};
int com_filesize;

static byte wave_data[48];
static large_sfxcache_t cache_data;
static sfx_t fixture_sfx;
static int console_calls;
static int sys_error_calls;

static void put16(int offset, int value)
{
    wave_data[offset] = (byte)(value & 255);
    wave_data[offset + 1] = (byte)((value >> 8) & 255);
}

static void put32(int offset, int value)
{
    wave_data[offset] = (byte)(value & 255);
    wave_data[offset + 1] = (byte)((value >> 8) & 255);
    wave_data[offset + 2] = (byte)((value >> 16) & 255);
    wave_data[offset + 3] = (byte)((value >> 24) & 255);
}

static void put_text(int offset, const char *text, int count)
{
    int index;
    for (index = 0; index < count; index++)
        wave_data[offset + index] = (byte)text[index];
}

int Q_strncmp(const char *first, const char *second, int count)
{
    return mq_strncmp(first, second, count);
}

int mq_strncmp(const char *first, const char *second, int count)
{
    while (count > 0)
    {
        int difference = (unsigned char)*first - (unsigned char)*second;
        if (difference || !*first)
            return difference;
        first++;
        second++;
        count--;
    }
    return 0;
}

void Q_strcpy(char *destination, const char *source)
{
    while ((*destination++ = *source++) != 0)
    {
    }
}

void Q_strcat(char *destination, const char *source)
{
    while (*destination)
        destination++;
    Q_strcpy(destination, source);
}

void *Cache_Check(cache_user_t *cache)
{
    return cache->data;
}

void *Cache_Alloc(cache_user_t *cache, int size, char *name)
{
    int index;
    (void)size;
    (void)name;
    cache->data = &cache_data;
    cache_data.length = 0;
    cache_data.loopstart = -1;
    cache_data.speed = 0;
    cache_data.width = 0;
    cache_data.stereo = 0;
    for (index = 0; index < 512; index++)
        cache_data.data[index] = 0;
    return cache->data;
}

byte *COM_LoadStackFile(char *name, void *buffer, int size)
{
    (void)name;
    (void)buffer;
    (void)size;
    com_filesize = 48;
    return wave_data;
}

void Con_Printf(char *format, ...)
{
    (void)format;
    console_calls++;
}

void Sys_Error(char *format, ...)
{
    (void)format;
    sys_error_calls++;
}

void snd_mem_fixture_reset(void)
{
    int index;
    for (index = 0; index < 48; index++)
        wave_data[index] = 0;
    put_text(0, "RIFF", 4);
    put32(4, 40);
    put_text(8, "WAVE", 4);
    put_text(12, "fmt ", 4);
    put32(16, 16);
    put16(20, 1);
    put16(22, 1);
    put32(24, 11025);
    put32(28, 11025);
    put16(32, 1);
    put16(34, 8);
    put_text(36, "data", 4);
    put32(40, 4);
    wave_data[44] = 128;
    wave_data[45] = 129;
    wave_data[46] = 130;
    wave_data[47] = 131;
    dma_state.speed = 22050;
    loadas8bit.value = 0.0f;
    console_calls = 0;
    sys_error_calls = 0;
    fixture_sfx.cache.data = NULL;
    Q_strcpy(fixture_sfx.name, "test.wav");
}

byte *snd_mem_wave(void) { return wave_data; }
int snd_mem_wave_length(void) { return 48; }

void snd_mem_set_cursor(int offset)
{
    data_p = wave_data + offset;
    iff_end = wave_data + 48;
}

int snd_mem_cursor_offset(void)
{
    return data_p ? (int)(data_p - wave_data) : -1;
}

void snd_mem_set_chunks(int iff_offset, int last_offset)
{
    iff_data = wave_data + iff_offset;
    iff_end = wave_data + 48;
    last_chunk = wave_data + last_offset;
    data_p = last_chunk;
}

int snd_mem_chunk_offset(void)
{
    return data_p ? (int)(data_p - wave_data) : -1;
}

int snd_mem_chunk_length(void)
{
    return iff_chunk_len;
}

int snd_mem_dump_count(void)
{
    console_calls = 0;
    DumpChunks();
    return console_calls;
}

sfxcache_t *snd_mem_resample(void)
{
    cache_data.length = 4;
    cache_data.loopstart = -1;
    cache_data.speed = 11025;
    cache_data.width = 1;
    cache_data.stereo = 1;
    fixture_sfx.cache.data = &cache_data;
    ResampleSfx(&fixture_sfx, 11025, 1, wave_data + 44);
    return (sfxcache_t *)&cache_data;
}

sfxcache_t *snd_mem_load(void)
{
    fixture_sfx.cache.data = NULL;
    return S_LoadSound(&fixture_sfx);
}

sfxcache_t *snd_mem_load_again(void)
{
    return S_LoadSound(&fixture_sfx);
}
