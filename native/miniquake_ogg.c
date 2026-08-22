/*
 * Bundled Ogg Vorbis decoder boundary.
 *
 * Copyright (c) 2026 Nils Kopal
 * SPDX-License-Identifier: Apache-2.0
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
typedef signed long long mq_i64;
typedef void *mq_ptr;

#define MQ_EXPORT __declspec(dllexport)
#define STB_VORBIS_NO_STDIO
#define STB_VORBIS_NO_CRT
#define STB_VORBIS_NO_PUSHDATA_API
#define STB_VORBIS_MAX_CHANNELS 2
#define assert(expression) ((void)0)
#define alloca _alloca

#define MQ_DLLIMPORT __declspec(dllimport)
#define MQ_WINAPI __stdcall
#define MQ_NULL ((void *)0)
#define MQ_INVALID_HANDLE_VALUE ((mq_ptr)(mq_i64)-1)
#define MQ_GENERIC_READ 0x80000000u
#define MQ_FILE_SHARE_READ 0x00000001u
#define MQ_OPEN_EXISTING 3u
#define MQ_FILE_ATTRIBUTE_NORMAL 0x00000080u
#define MQ_MEM_COMMIT 0x00001000u
#define MQ_MEM_RESERVE 0x00002000u
#define MQ_MEM_RELEASE 0x00008000u
#define MQ_PAGE_READWRITE 0x00000004u

typedef mq_ptr HANDLE;
typedef unsigned short WCHAR;
typedef const WCHAR *LPCWSTR;
typedef mq_u32 DWORD;
typedef mq_i32 BOOL;
/* Mirror the Win32 large integer ABI layout without requiring SDK declarations. */
typedef struct MQ_LARGE_INTEGER { mq_i64 QuadPart; } MQ_LARGE_INTEGER;

MQ_DLLIMPORT HANDLE MQ_WINAPI CreateFileW(LPCWSTR filename, DWORD access, DWORD share,
    mq_ptr security, DWORD creation, DWORD attributes, HANDLE template_file);
MQ_DLLIMPORT BOOL MQ_WINAPI GetFileSizeEx(HANDLE file, MQ_LARGE_INTEGER *size);
MQ_DLLIMPORT BOOL MQ_WINAPI ReadFile(HANDLE file, mq_ptr buffer, DWORD count, DWORD *read_count, mq_ptr overlapped);
MQ_DLLIMPORT BOOL MQ_WINAPI CloseHandle(HANDLE handle);
MQ_DLLIMPORT mq_ptr MQ_WINAPI VirtualAlloc(mq_ptr address, mq_u64 size, DWORD allocation_type, DWORD protect);
MQ_DLLIMPORT BOOL MQ_WINAPI VirtualFree(mq_ptr address, mq_u64 size, DWORD free_type);

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
static mq_u8 *mq_ogg_file_data = 0;

/* Close the active resource and release its storage. */
MQ_EXPORT void mq_ogg_close(void) {
    if (mq_ogg_decoder != 0) {
        stb_vorbis_close(mq_ogg_decoder);
    }
    mq_ogg_decoder = 0;
    mq_ogg_rate_value = 0;
    mq_ogg_channels_value = 0;
    mq_ogg_frames_value = 0;
    if (mq_ogg_file_data != 0) {
        VirtualFree(mq_ogg_file_data, 0, MQ_MEM_RELEASE);
        mq_ogg_file_data = 0;
    }
}

/* Open and validate a Vorbis stream from caller-owned encoded bytes. */
static mq_u32 mq_ogg_open_decoder(const void *data, mq_u32 byte_count) {
    stb_vorbis_alloc allocation;
    stb_vorbis_info info;
    mq_i32 error_code = 0;
    if (data == 0 || byte_count == 0 || byte_count > 0x7fffffffu) {
        return 0;
    }
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
        stb_vorbis_close(mq_ogg_decoder);
        mq_ogg_decoder = 0;
        return 0;
    }
    mq_ogg_rate_value = info.sample_rate;
    mq_ogg_channels_value = (mq_u32)info.channels;
    mq_ogg_frames_value = stb_vorbis_stream_length_in_samples(mq_ogg_decoder);
    if (mq_ogg_frames_value == 0) {
        stb_vorbis_close(mq_ogg_decoder);
        mq_ogg_decoder = 0;
        mq_ogg_rate_value = 0;
        mq_ogg_channels_value = 0;
        return 0;
    }
    stb_vorbis_seek_start(mq_ogg_decoder);
    return 1;
}

/* Open and validate the requested resource. */
MQ_EXPORT mq_u32 mq_ogg_open(const void *data, mq_u32 byte_count) {
    mq_ogg_close();
    return mq_ogg_open_decoder(data, byte_count);
}

/* Open and validate file. */
MQ_EXPORT mq_u32 mq_ogg_open_file(const unsigned short *filename) {
    HANDLE file;
    MQ_LARGE_INTEGER size;
    mq_u32 total = 0;
    if (filename == 0 || filename[0] == 0) {
        return 0;
    }
    mq_ogg_close();
    file = CreateFileW(filename, MQ_GENERIC_READ, MQ_FILE_SHARE_READ, MQ_NULL,
        MQ_OPEN_EXISTING, MQ_FILE_ATTRIBUTE_NORMAL, MQ_NULL);
    if (file == MQ_INVALID_HANDLE_VALUE) {
        return 0;
    }
    if (!GetFileSizeEx(file, &size) || size.QuadPart <= 0 || size.QuadPart > 0x7fffffffu) {
        CloseHandle(file);
        return 0;
    }
    mq_ogg_file_data = (mq_u8 *)VirtualAlloc(MQ_NULL, (mq_u64)size.QuadPart,
        MQ_MEM_RESERVE | MQ_MEM_COMMIT, MQ_PAGE_READWRITE);
    if (mq_ogg_file_data == 0) {
        CloseHandle(file);
        return 0;
    }
    while (total < (mq_u32)size.QuadPart) {
        DWORD read_count = 0;
        DWORD wanted = (mq_u32)size.QuadPart - total;
        if (!ReadFile(file, mq_ogg_file_data + total, wanted, &read_count, MQ_NULL) || read_count == 0) {
            CloseHandle(file);
            mq_ogg_close();
            return 0;
        }
        total += read_count;
    }
    CloseHandle(file);
    if (!mq_ogg_open_decoder(mq_ogg_file_data, total)) {
        mq_ogg_close();
        return 0;
    }
    return 1;
}

/* Return the current rate value. */
MQ_EXPORT mq_u32 mq_ogg_rate(void) {
    return mq_ogg_rate_value;
}

/* Return the current channels value. */
MQ_EXPORT mq_u32 mq_ogg_channels(void) {
    return mq_ogg_channels_value;
}

/* Return the current frames value. */
MQ_EXPORT mq_u32 mq_ogg_frames(void) {
    return mq_ogg_frames_value;
}

/* Decode interleaved PCM frames into caller-owned storage. */
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

/* Rewind the active Vorbis stream to its first audio frame. */
MQ_EXPORT mq_i32 mq_ogg_seek_start(void) {
    if (mq_ogg_decoder == 0) {
        return 0;
    }
    return stb_vorbis_seek_start(mq_ogg_decoder) != 0;
}
