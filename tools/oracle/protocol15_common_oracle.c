/*
 * Protocol-15/sizebuf oracle extracted into a standalone, asset-free fixture.
 * The operations reproduce WinQuake 1.09 common.c MSG_* and SZ_* release
 * semantics on the supported little-endian two's-complement target.
 *
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2026 MiniQuake contributors
 * GPL-2.0-or-later; see COPYING.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    uint8_t data[4096];
    int maxsize;
    int cursize;
    int allowoverflow;
    int overflowed;
} sizebuf_t;

static void init_buf(sizebuf_t *b, int maxsize, int allowoverflow) {
    memset(b, 0, sizeof(*b));
    b->maxsize = maxsize;
    b->allowoverflow = allowoverflow;
}

static uint8_t *sz_get_space(sizebuf_t *b, int length) {
    if (b->cursize + length > b->maxsize) {
        if (!b->allowoverflow || length > b->maxsize) {
            return NULL;
        }
        b->overflowed = 1;
        b->cursize = 0;
    }
    uint8_t *result = b->data + b->cursize;
    b->cursize += length;
    return result;
}

static void sz_write(sizebuf_t *b, const void *data, int length) {
    uint8_t *out = sz_get_space(b, length);
    if (out != NULL) memcpy(out, data, (size_t)length);
}

static void sz_print(sizebuf_t *b, const char *text) {
    int length = (int)strlen(text) + 1;
    /* This is the original defined branch structure. common.c reads
       data[cursize-1], so an empty buffer is undefined and is intentionally
       not passed to this oracle helper. */
    if (b->data[b->cursize - 1] != 0) {
        sz_write(b, text, length);
    } else {
        uint8_t *out = sz_get_space(b, length - 1);
        if (out != NULL) memcpy(out - 1, text, (size_t)length);
    }
}

static void msg_write_char(sizebuf_t *b, int value) {
    uint8_t *out = sz_get_space(b, 1);
    out[0] = (uint8_t)value;
}

static void msg_write_byte(sizebuf_t *b, int value) {
    uint8_t *out = sz_get_space(b, 1);
    out[0] = (uint8_t)value;
}

static void msg_write_short(sizebuf_t *b, int value) {
    uint8_t *out = sz_get_space(b, 2);
    out[0] = (uint8_t)(value & 0xff);
    out[1] = (uint8_t)((uint32_t)value >> 8);
}

static void msg_write_long(sizebuf_t *b, int32_t value) {
    uint8_t *out = sz_get_space(b, 4);
    uint32_t bits = (uint32_t)value;
    out[0] = (uint8_t)(bits & 0xff);
    out[1] = (uint8_t)((bits >> 8) & 0xff);
    out[2] = (uint8_t)((bits >> 16) & 0xff);
    out[3] = (uint8_t)(bits >> 24);
}

static void msg_write_float(sizebuf_t *b, float value) {
    uint32_t bits = 0;
    memcpy(&bits, &value, sizeof(bits));
    msg_write_long(b, (int32_t)bits);
}

static void msg_write_string(sizebuf_t *b, const char *text) {
    if (text == NULL) {
        msg_write_byte(b, 0);
    } else {
        sz_write(b, text, (int)strlen(text) + 1);
    }
}

static void msg_write_coord(sizebuf_t *b, float value) {
    msg_write_short(b, (int)(value * 8.0f));
}

static void msg_write_angle(sizebuf_t *b, float value) {
    msg_write_byte(b, (((int)value * 256 / 360) & 255));
}

static void print_hex(const uint8_t *data, int length) {
    for (int i = 0; i < length; ++i) printf("%02x", data[i]);
}

static void vector_line(const char *name, const sizebuf_t *b) {
    printf("{\"name\":\"%s\",\"bytes\":\"", name);
    print_hex(b->data, b->cursize);
    printf("\",\"length\":%d", b->cursize);
    if (b->overflowed) printf(",\"overflowed\":true");
    printf("}\n");
}

int main(void) {
    sizebuf_t b;

    init_buf(&b, 256, 0);
    msg_write_char(&b, -2);
    msg_write_byte(&b, 254);
    msg_write_short(&b, -1234);
    msg_write_long(&b, 0x12345678);
    msg_write_float(&b, 12.5f);
    msg_write_string(&b, "quake");
    msg_write_coord(&b, -12.25f);
    msg_write_angle(&b, 90.75f);
    vector_line("primitive_stream", &b);

    init_buf(&b, 64, 0);
    msg_write_char(&b, 130);
    msg_write_byte(&b, -1);
    msg_write_short(&b, 0x12345);
    msg_write_long(&b, -2);
    vector_line("release_wrapping", &b);

    init_buf(&b, 128, 0);
    msg_write_coord(&b, -0.124f);
    msg_write_coord(&b, -0.126f);
    msg_write_coord(&b, 4095.875f);
    msg_write_coord(&b, 4096.0f);
    msg_write_angle(&b, -1.9f);
    msg_write_angle(&b, -90.9f);
    msg_write_angle(&b, 359.9f);
    msg_write_angle(&b, 360.0f);
    vector_line("coord_angle_boundaries", &b);

    /* Values deliberately chosen between binary64 and binary32 boundaries.
       The function parameter conversion to float happens before scaling/cast. */
    init_buf(&b, 128, 0);
    msg_write_float(&b, 16777217); /* integer caller first converts to float */
    msg_write_coord(&b, 0.124999999f);
    msg_write_coord(&b, -0.124999999f);
    msg_write_coord(&b, 1.99999999f);
    msg_write_coord(&b, -1.99999999f);
    msg_write_angle(&b, 1.99999999f);
    msg_write_angle(&b, -1.99999999f);
    msg_write_coord(&b, 16777217); /* integer caller first converts to float */
    vector_line("float_parameter_rounding", &b);

    init_buf(&b, 64, 0);
    {
        const char raw[] = {'A', (char)0x80, (char)0xe9, (char)0xfe, 0};
        msg_write_string(&b, raw);
    }
    vector_line("raw_high_bit_string", &b);

    init_buf(&b, 64, 0);
    {
        const char embedded[] = {'A', 0, 'B', 0};
        msg_write_string(&b, embedded);
    }
    vector_line("embedded_nul_string", &b);

    init_buf(&b, 64, 0);
    msg_write_string(&b, NULL);
    vector_line("null_string", &b);

    init_buf(&b, 5, 1);
    {
        const uint8_t prefix[] = {9, 9, 9};
        sz_write(&b, prefix, 3);
        msg_write_string(&b, "xy");
    }
    vector_line("string_overflow_restart", &b);

    init_buf(&b, 64, 0);
    {
        const uint8_t empty_c_string[] = {0};
        sz_write(&b, empty_c_string, 1);
    }
    sz_print(&b, "one");
    sz_print(&b, "two");
    vector_line("sz_print_concat", &b);

    init_buf(&b, 5, 1);
    {
        const uint8_t prefix[] = {7, 7, 7};
        sz_write(&b, prefix, 3);
        sz_print(&b, "ab");
    }
    vector_line("sz_print_overflow_restart", &b);

    init_buf(&b, 4, 1);
    {
        const uint8_t first[] = {1, 2, 3, 4};
        const uint8_t second[] = {9, 8};
        sz_write(&b, first, 4);
        sz_write(&b, second, 2);
    }
    vector_line("sz_overflow_restart", &b);

    init_buf(&b, 128, 0);
    msg_write_byte(&b, 3);              /* clc_move */
    msg_write_float(&b, 12.5f);
    msg_write_angle(&b, 12.75f);
    msg_write_angle(&b, 180.0f);
    msg_write_angle(&b, -90.9f);
    msg_write_short(&b, (int)200.75f);
    msg_write_short(&b, (int)-123.9f);
    msg_write_short(&b, (int)32768.9f);
    msg_write_byte(&b, 3);
    msg_write_byte(&b, 7);
    vector_line("clc_move", &b);

    init_buf(&b, 128, 0);
    msg_write_byte(&b, 1);
    msg_write_byte(&b, 2);
    msg_write_byte(&b, 3);
    msg_write_byte(&b, 4);
    msg_write_coord(&b, -12.25f); msg_write_angle(&b, 90.75f);
    msg_write_coord(&b, 0.125f); msg_write_angle(&b, -90.9f);
    msg_write_coord(&b, 4095.875f); msg_write_angle(&b, 359.9f);
    vector_line("baseline_payload", &b);

    return 0;
}
