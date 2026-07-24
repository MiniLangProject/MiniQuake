/*
 * Bundled Ogg Vorbis decoder boundary.
 *
 * stb_vorbis is compiled without its CRT allocation/stdio paths. One decoder
 * is active at a time and receives a fixed setup workspace, which matches the
 * single CD music stream owned by the Quake client.
 */

typedef unsigned char mq_u8;
typedef unsigned int mq_u32;
typedef unsigned long long mq_u64;
typedef signed short mq_i16;
typedef signed int mq_i32;

#define MQ_EXPORT __declspec(dllexport)
#define STB_VORBIS_NO_STDIO
#define STB_VORBIS_NO_CRT
#define STB_VORBIS_NO_PUSHDATA_API
#define STB_VORBIS_MAX_CHANNELS 2
#define assert(expression) ((void)0)
#define alloca _alloca

void *_alloca(mq_u64 size);
void *memcpy(void *destination, const void *source, mq_u64 count);
void *memset(void *destination, mq_i32 value, mq_u64 count);
void qsort(void *base, mq_u64 count, mq_u64 width, mq_i32 (__cdecl *compare)(const void *, const void *));
double sin(double value);
double cos(double value);
double exp(double value);
double log(double value);
double pow(double value, double exponent);
double floor(double value);
double ldexp(double value, mq_i32 exponent);

#include "../third_party/stb/stb_vorbis.c"

#define MQ_OGG_WORKSPACE_BYTES (1024u * 1024u)

static mq_u8 mq_ogg_workspace[MQ_OGG_WORKSPACE_BYTES];
static stb_vorbis *mq_ogg_decoder = 0;
static mq_u32 mq_ogg_rate_value = 0;
static mq_u32 mq_ogg_channels_value = 0;
static mq_u32 mq_ogg_frames_value = 0;

MQ_EXPORT void mq_ogg_close(void) {
    if (mq_ogg_decoder != 0) {
        stb_vorbis_close(mq_ogg_decoder);
    }
    mq_ogg_decoder = 0;
    mq_ogg_rate_value = 0;
    mq_ogg_channels_value = 0;
    mq_ogg_frames_value = 0;
}

MQ_EXPORT mq_u32 mq_ogg_open(const void *data, mq_u32 byte_count) {
    stb_vorbis_alloc allocation;
    stb_vorbis_info info;
    mq_i32 error_code = 0;
    if (data == 0 || byte_count == 0 || byte_count > 0x7fffffffu) {
        return 0;
    }
    mq_ogg_close();
    allocation.alloc_buffer = (char *)mq_ogg_workspace;
    allocation.alloc_buffer_length_in_bytes = (mq_i32)MQ_OGG_WORKSPACE_BYTES;
    mq_ogg_decoder = stb_vorbis_open_memory(
        (const unsigned char *)data,
        (mq_i32)byte_count,
        &error_code,
        &allocation
    );
    if (mq_ogg_decoder == 0) {
        return 0;
    }
    info = stb_vorbis_get_info(mq_ogg_decoder);
    if (info.channels < 1 || info.channels > 2 || info.sample_rate == 0) {
        mq_ogg_close();
        return 0;
    }
    mq_ogg_rate_value = info.sample_rate;
    mq_ogg_channels_value = (mq_u32)info.channels;
    mq_ogg_frames_value = stb_vorbis_stream_length_in_samples(mq_ogg_decoder);
    stb_vorbis_seek_start(mq_ogg_decoder);
    return mq_ogg_frames_value != 0;
}

MQ_EXPORT mq_u32 mq_ogg_rate(void) {
    return mq_ogg_rate_value;
}

MQ_EXPORT mq_u32 mq_ogg_channels(void) {
    return mq_ogg_channels_value;
}

MQ_EXPORT mq_u32 mq_ogg_frames(void) {
    return mq_ogg_frames_value;
}

MQ_EXPORT mq_u32 mq_ogg_decode(void *output, mq_u32 frame_capacity) {
    mq_i32 decoded;
    mq_u64 short_capacity;
    if (mq_ogg_decoder == 0 || output == 0 || frame_capacity == 0) {
        return 0;
    }
    short_capacity = (mq_u64)frame_capacity * mq_ogg_channels_value;
    if (short_capacity > 0x7fffffffu) {
        return 0;
    }
    decoded = stb_vorbis_get_samples_short_interleaved(
        mq_ogg_decoder,
        (mq_i32)mq_ogg_channels_value,
        (short *)output,
        (mq_i32)short_capacity
    );
    return decoded > 0 ? (mq_u32)decoded : 0;
}
