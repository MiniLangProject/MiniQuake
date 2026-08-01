/*
 * Protocol-15 static/event/reliable-update oracle derived from Quake 1.09:
 * sv_main.c, host.c, host_cmd.c, pr_cmds.c, cl_parse.c and r_part.c.
 *
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2026 MiniQuake contributors
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define svc_disconnect 2
#define svc_print 8
#define svc_updatename 13
#define svc_updatefrags 14
#define svc_updatecolors 17
#define svc_particle 18
#define svc_spawnstatic 20
#define svc_spawnstaticsound 29
#define MAX_DATAGRAM 1024

typedef struct {
    uint8_t data[4096];
    int cursize;
} sizebuf_t;

static uint8_t *space(sizebuf_t *buffer, int count) {
    uint8_t *result;
    if (count < 0 || buffer->cursize + count > (int)sizeof(buffer->data)) {
        fputs("oracle buffer overflow\n", stderr);
        exit(2);
    }
    result = buffer->data + buffer->cursize;
    buffer->cursize += count;
    return result;
}

static void clear(sizebuf_t *buffer) {
    memset(buffer, 0, sizeof(*buffer));
}

static void write_byte(sizebuf_t *buffer, int value) {
    space(buffer, 1)[0] = (uint8_t)value;
}

static void write_char(sizebuf_t *buffer, int value) {
    write_byte(buffer, value);
}

static void write_short(sizebuf_t *buffer, int value) {
    const uint16_t encoded = (uint16_t)value;
    uint8_t *output = space(buffer, 2);
    output[0] = (uint8_t)encoded;
    output[1] = (uint8_t)(encoded >> 8);
}

static void write_string(sizebuf_t *buffer, const char *text) {
    const size_t length = text != NULL ? strlen(text) : 0U;
    uint8_t *output = space(buffer, (int)length + 1);
    if (length != 0U) {
        memcpy(output, text, length);
    }
    output[length] = 0;
}

static void write_coord(sizebuf_t *buffer, float value) {
    write_short(buffer, (int)(value * 8.0f));
}

static void write_angle(sizebuf_t *buffer, float value) {
    write_byte(buffer, (((int)value * 256 / 360) & 255));
}

static void print_hex(const uint8_t *data, int count) {
    int index;
    for (index = 0; index < count; ++index) {
        printf("%02x", data[index]);
    }
}

static void emit_vector(const char *name, const sizebuf_t *buffer) {
    printf("{\"kind\":\"vector\",\"name\":\"%s\",\"bytes\":\"", name);
    print_hex(buffer->data, buffer->cursize);
    printf("\",\"length\":%d}\n", buffer->cursize);
}

static void emit_case(const char *group, const char *name, int value) {
    printf("{\"kind\":\"case\",\"group\":\"%s\",\"name\":\"%s\",\"value\":%d}\n",
           group, name, value);
}

static void write_spawn_static(sizebuf_t *buffer, int model, int frame, int colormap,
                               int skin, const float origin[3], const float angles[3]) {
    int index;
    write_byte(buffer, svc_spawnstatic);
    write_byte(buffer, model);
    write_byte(buffer, frame);
    write_byte(buffer, colormap);
    write_byte(buffer, skin);
    for (index = 0; index < 3; ++index) {
        write_coord(buffer, origin[index]);
        write_angle(buffer, angles[index]);
    }
}

static void write_static_sound(sizebuf_t *buffer, const float origin[3], int sound,
                               float volume, float attenuation) {
    int index;
    write_byte(buffer, svc_spawnstaticsound);
    for (index = 0; index < 3; ++index) {
        write_coord(buffer, origin[index]);
    }
    write_byte(buffer, sound);
    write_byte(buffer, (int)(volume * 255.0f));
    write_byte(buffer, (int)(attenuation * 64.0f));
}

static int particle_direction_byte(float value) {
    int encoded = (int)(value * 16.0f);
    if (encoded > 127) {
        encoded = 127;
    } else if (encoded < -128) {
        encoded = -128;
    }
    return encoded;
}

static void write_particle(sizebuf_t *buffer, const float origin[3], const float direction[3],
                           int color, int count) {
    int index;
    write_byte(buffer, svc_particle);
    for (index = 0; index < 3; ++index) {
        write_coord(buffer, origin[index]);
    }
    for (index = 0; index < 3; ++index) {
        write_char(buffer, particle_direction_byte(direction[index]));
    }
    write_byte(buffer, count);
    write_byte(buffer, color);
}

static void write_update_name(sizebuf_t *buffer, int index, const char *name) {
    write_byte(buffer, svc_updatename);
    write_byte(buffer, index);
    write_string(buffer, name);
}

static void write_update_frags(sizebuf_t *buffer, int index, int frags) {
    write_byte(buffer, svc_updatefrags);
    write_byte(buffer, index);
    write_short(buffer, frags);
}

static void write_update_colors(sizebuf_t *buffer, int index, int colors) {
    write_byte(buffer, svc_updatecolors);
    write_byte(buffer, index);
    write_byte(buffer, colors);
}

static void write_score_reset(sizebuf_t *buffer, int index) {
    write_update_name(buffer, index, "");
    write_update_frags(buffer, index, 0);
    write_update_colors(buffer, index, 0);
}

static int parse_particle_count(int wire_value) {
    return wire_value == 255 ? 1024 : wire_value;
}

static int can_write_transient(int cursize) {
    return cursize <= MAX_DATAGRAM - 16;
}

static int frag_changed(int old_frags, float current_frags) {
    return (float)old_frags != current_frags;
}

static int stored_frag(float current_frags) {
    return (int)current_frags;
}

static int color_component(int value) {
    int result = value & 15;
    if (result > 13) {
        result = 13;
    }
    return result;
}

static int player_color(int top, int bottom) {
    return color_component(top) * 16 + color_component(bottom);
}

int main(void) {
    sizebuf_t buffer;
    const float origin_a[3] = {-12.25f, 0.125f, 4095.875f};
    const float angles_a[3] = {90.75f, -90.9f, 359.9f};
    const float origin_b[3] = {10.0f, -20.0f, 30.0f};
    const float angles_b[3] = {0.0f, 45.0f, 90.0f};
    float direction[3];
    char latin_name[] = {'J', 'o', 's', (char)0xe9, 0};
    char long_name[] = {'1','2','3','4','5','6','7','8','9','0','1','2','3','4',(char)0xe9,'X',0};

    clear(&buffer);
    write_spawn_static(&buffer, 1, 2, 3, 4, origin_a, angles_a);
    emit_vector("static_entity_basic", &buffer);

    clear(&buffer);
    write_spawn_static(&buffer, 300, -1, 257, 511, origin_b, angles_b);
    emit_vector("static_entity_wrapped", &buffer);

    clear(&buffer);
    write_static_sound(&buffer, origin_b, 5, 0.5f, 1.25f);
    emit_vector("static_sound_basic", &buffer);

    clear(&buffer);
    write_static_sound(&buffer, origin_a, 300, 1.25f, 4.5f);
    emit_vector("static_sound_wrapped", &buffer);

    direction[0] = 1.0f;
    direction[1] = -2.0f;
    direction[2] = 0.0625f;
    clear(&buffer);
    write_particle(&buffer, origin_b, direction, 7, 20);
    emit_vector("particle_basic", &buffer);

    direction[0] = 100.0f;
    direction[1] = -100.0f;
    direction[2] = -7.999f;
    clear(&buffer);
    write_particle(&buffer, origin_a, direction, 300, 255);
    emit_vector("particle_clamped", &buffer);

    clear(&buffer);
    write_update_name(&buffer, 2, "Ranger");
    emit_vector("update_name_ascii", &buffer);

    clear(&buffer);
    write_update_name(&buffer, 1, latin_name);
    emit_vector("update_name_latin1", &buffer);

    long_name[15] = 0;
    clear(&buffer);
    write_update_name(&buffer, 0, long_name);
    emit_vector("update_name_truncated", &buffer);

    clear(&buffer);
    write_update_frags(&buffer, 3, -123);
    emit_vector("update_frags_negative", &buffer);

    clear(&buffer);
    write_update_frags(&buffer, 255, 40000);
    emit_vector("update_frags_wrapped", &buffer);

    clear(&buffer);
    write_update_colors(&buffer, 4, 0xde);
    emit_vector("update_colors", &buffer);

    clear(&buffer);
    write_score_reset(&buffer, 5);
    emit_vector("score_reset", &buffer);

    clear(&buffer);
    write_update_name(&buffer, 1, "Player");
    write_update_frags(&buffer, 1, 42);
    write_update_colors(&buffer, 1, 0x4d);
    emit_vector("score_triplet", &buffer);

    clear(&buffer);
    write_byte(&buffer, svc_print);
    write_string(&buffer, "bye\n");
    write_byte(&buffer, svc_disconnect);
    emit_vector("graceful_disconnect_pending", &buffer);

    emit_case("particle_count", "zero", parse_particle_count(0));
    emit_case("particle_count", "normal", parse_particle_count(254));
    emit_case("particle_count", "explosion", parse_particle_count(255));
    emit_case("datagram_gate", "exact_margin", can_write_transient(MAX_DATAGRAM - 16));
    emit_case("datagram_gate", "above_margin", can_write_transient(MAX_DATAGRAM - 15));
    emit_case("frag_compare", "equal", frag_changed(42, 42.0f));
    emit_case("frag_compare", "fractional", frag_changed(42, 42.75f));
    emit_case("frag_compare", "int_float_rounding", frag_changed(16777217, 16777216.0f));
    emit_case("stored_frag", "positive_fraction", stored_frag(42.75f));
    emit_case("stored_frag", "negative_fraction", stored_frag(-42.75f));
    emit_case("player_color", "normal", player_color(4, 13));
    emit_case("player_color", "clamped", player_color(14, 15));
    emit_case("player_color", "negative_mask", player_color(-1, -2));
    return 0;
}
