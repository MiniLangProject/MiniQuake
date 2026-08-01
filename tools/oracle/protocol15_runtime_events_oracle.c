/*
 * Protocol-15 temporary-entity, dynamic-sound and delivery-boundary oracle
 * derived from Quake 1.09 cl_tent.c, cl_parse.c, sv_main.c, host.c and
 * pr_cmds.c.
 *
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2026 MiniQuake contributors
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define svc_sound 6
#define svc_stufftext 9
#define svc_stopsound 16
#define svc_temp_entity 23
#define TE_SPIKE 0
#define TE_LIGHTNING1 5
#define TE_TELEPORT 11
#define TE_EXPLOSION2 12
#define TE_BEAM 13
#define SND_VOLUME 1
#define SND_ATTENUATION 2
#define MAX_DATAGRAM 1024
#define MAX_BEAMS 24

#define TEMP_KIND_POINT 1
#define TEMP_KIND_BEAM 2
#define TEMP_KIND_EXPLOSION2 3
#define PLAN_SEND_NOP 2
#define PLAN_WAIT_SIGNON 4
#define RELIABLE_DROP_OVERFLOW 1
#define RELIABLE_WAIT 2
#define RELIABLE_DROP_ASAP 3

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
    uint16_t encoded = (uint16_t)value;
    uint8_t *output = space(buffer, 2);
    output[0] = (uint8_t)encoded;
    output[1] = (uint8_t)(encoded >> 8);
}

static void write_string(sizebuf_t *buffer, const char *value) {
    size_t length = strlen(value);
    uint8_t *output = space(buffer, (int)length + 1);
    memcpy(output, value, length + 1);
}

static void write_coord(sizebuf_t *buffer, float value) {
    write_short(buffer, (int)(value * 8.0f));
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

static void emit_case(const char *group, const char *name, uint64_t value) {
    printf("{\"kind\":\"case\",\"group\":\"%s\",\"name\":\"%s\",\"value\":%llu}\n",
           group, name, (unsigned long long)value);
}

static uint32_t float_bits(float value) {
    uint32_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

static void write_position(sizebuf_t *buffer, const float value[3]) {
    int index;
    for (index = 0; index < 3; ++index) {
        write_coord(buffer, value[index]);
    }
}

static void write_temp_point(sizebuf_t *buffer, int type, const float origin[3]) {
    write_byte(buffer, svc_temp_entity);
    write_byte(buffer, type);
    write_position(buffer, origin);
}

static void write_temp_beam(sizebuf_t *buffer, int type, int entity,
                            const float start[3], const float end[3]) {
    write_byte(buffer, svc_temp_entity);
    write_byte(buffer, type);
    write_short(buffer, entity);
    write_position(buffer, start);
    write_position(buffer, end);
}

static void write_temp_explosion2(sizebuf_t *buffer, const float origin[3],
                                  int color_start, int color_length) {
    write_byte(buffer, svc_temp_entity);
    write_byte(buffer, TE_EXPLOSION2);
    write_position(buffer, origin);
    write_byte(buffer, color_start);
    write_byte(buffer, color_length);
}

static int pack_sound_channel(int entity, int channel) {
    return (entity << 3) | (channel & 7);
}

static void write_stop_sound(sizebuf_t *buffer, int entity, int channel) {
    write_byte(buffer, svc_stopsound);
    write_short(buffer, pack_sound_channel(entity, channel));
}

static int sound_field_mask(int volume, float attenuation) {
    int mask = 0;
    if (volume != 255) {
        mask |= SND_VOLUME;
    }
    if (attenuation != 1.0f) {
        mask |= SND_ATTENUATION;
    }
    return mask;
}

static void write_dynamic_sound(sizebuf_t *buffer, int entity, int channel,
                                int sound, int volume, float attenuation,
                                const float origin[3]) {
    int mask = sound_field_mask(volume, attenuation);
    write_byte(buffer, svc_sound);
    write_byte(buffer, mask);
    if ((mask & SND_VOLUME) != 0) {
        write_byte(buffer, volume);
    }
    if ((mask & SND_ATTENUATION) != 0) {
        write_byte(buffer, (int)(attenuation * 64.0f));
    }
    write_short(buffer, pack_sound_channel(entity, channel));
    write_byte(buffer, sound);
    write_position(buffer, origin);
}

static int temp_kind(int type) {
    switch (type) {
        case 0: case 1: case 2: case 3: case 4:
        case 7: case 8: case 10: case 11:
            return TEMP_KIND_POINT;
        case 5: case 6: case 9: case 13:
            return TEMP_KIND_BEAM;
        case 12:
            return TEMP_KIND_EXPLOSION2;
        default:
            return 0;
    }
}

static int temp_wire_size(int type) {
    int kind = temp_kind(type);
    if (kind == TEMP_KIND_POINT) {
        return 8;
    }
    if (kind == TEMP_KIND_BEAM) {
        return 16;
    }
    if (kind == TEMP_KIND_EXPLOSION2) {
        return 10;
    }
    return 0;
}

static int reliable_plan(int overflowed, int message_size, int drop_asap, int can_send) {
    if (overflowed) {
        return RELIABLE_DROP_OVERFLOW;
    }
    if (message_size <= 0 && !drop_asap) {
        return 0;
    }
    if (!can_send) {
        return RELIABLE_WAIT;
    }
    if (drop_asap) {
        return RELIABLE_DROP_ASAP;
    }
    return 4;
}

int main(void) {
    sizebuf_t buffer;
    const float origin_a[3] = {10.0f, -20.0f, 30.0f};
    const float origin_b[3] = {-12.25f, 0.125f, 4095.875f};
    float rounded_default = 1.00000001f;
    double current_time = 1.0;
    float beam_end = (float)(current_time + 0.2);
    float dlight_die = (float)(current_time + 0.5);
    float client_volume = (float)(128 / 255.0);
    float client_attenuation = (float)(32 / 64.0);
    float qc_volume_product = 0.5f * 255.0f;
    float center_sum = -1.5f + 2.25f;
    float center_x = (float)(-12.25f + 0.5 * center_sum);
    int type;

    clear(&buffer);
    write_temp_point(&buffer, TE_SPIKE, origin_a);
    emit_vector("temp_point_spike", &buffer);

    clear(&buffer);
    write_temp_point(&buffer, TE_TELEPORT, origin_b);
    emit_vector("temp_point_wrapped", &buffer);

    clear(&buffer);
    write_temp_beam(&buffer, TE_LIGHTNING1, 300, origin_a, origin_b);
    emit_vector("temp_beam_lightning", &buffer);

    clear(&buffer);
    write_temp_beam(&buffer, TE_BEAM, -1, origin_b, origin_a);
    emit_vector("temp_beam_wrapped", &buffer);

    clear(&buffer);
    write_temp_explosion2(&buffer, origin_a, 0x12, 0x34);
    emit_vector("temp_explosion2", &buffer);

    clear(&buffer);
    write_stop_sound(&buffer, 300, 7);
    emit_vector("stop_sound", &buffer);

    clear(&buffer);
    write_dynamic_sound(&buffer, 300, 2, 5, 255, 1.0f, origin_a);
    emit_vector("dynamic_sound_default", &buffer);

    clear(&buffer);
    write_dynamic_sound(&buffer, 1, 7, 300, 128, 0.5f, origin_b);
    emit_vector("dynamic_sound_options", &buffer);

    clear(&buffer);
    write_dynamic_sound(&buffer, 3, 2, 5, 255, rounded_default, origin_a);
    emit_vector("dynamic_sound_rounded_default", &buffer);

    clear(&buffer);
    write_char(&buffer, svc_stufftext);
    write_string(&buffer, "reconnect\n");
    emit_vector("reconnect", &buffer);

    for (type = 0; type <= 13; ++type) {
        char name[24];
        snprintf(name, sizeof(name), "type_%d", type);
        emit_case("temp_kind", name, (uint64_t)temp_kind(type));
        emit_case("temp_size", name, (uint64_t)temp_wire_size(type));
    }

    emit_case("sound_scalar", "qc_channel_2_9", (uint64_t)(int)2.9f);
    emit_case("sound_scalar", "qc_volume_half", (uint64_t)(int)qc_volume_product);
    emit_case("sound_scalar", "rounded_default_mask", (uint64_t)sound_field_mask(255, rounded_default));
    emit_case("sound_scalar", "client_volume_bits", (uint64_t)float_bits(client_volume));
    emit_case("sound_scalar", "client_attenuation_bits", (uint64_t)float_bits(client_attenuation));
    emit_case("sound_scalar", "static_volume_bits", (uint64_t)float_bits((float)(127 / 255.0)));
    emit_case("sound_scalar", "static_attenuation_bits", (uint64_t)float_bits(80.0f));
    emit_case("sound_scalar", "center_x_bits", (uint64_t)float_bits(center_x));
    emit_case("sound_scalar", "packed_300_7", (uint64_t)pack_sound_channel(300, 7));

    emit_case("timing", "beam_end_bits", (uint64_t)float_bits(beam_end));
    emit_case("timing", "dlight_die_bits", (uint64_t)float_bits(dlight_die));
    emit_case("timing", "beam_alive_equal", (uint64_t)(beam_end >= (double)beam_end));
    emit_case("timing", "beam_expired_after", (uint64_t)(beam_end < (double)beam_end + 0.0001));

    emit_case("delivery", "dynamic_exact_margin", (uint64_t)((MAX_DATAGRAM - 16) <= MAX_DATAGRAM - 16));
    emit_case("delivery", "dynamic_above_margin", (uint64_t)((MAX_DATAGRAM - 15) <= MAX_DATAGRAM - 16));
    emit_case("delivery", "keepalive_equal", (uint64_t)((5.0 > 5.0) ? PLAN_SEND_NOP : PLAN_WAIT_SIGNON));
    emit_case("delivery", "keepalive_above", (uint64_t)((5.0001 > 5.0) ? PLAN_SEND_NOP : PLAN_WAIT_SIGNON));
    emit_case("delivery", "overflow_precedes_drop", (uint64_t)reliable_plan(1, 1, 1, 1));
    emit_case("delivery", "drop_waits_blocked", (uint64_t)reliable_plan(0, 0, 1, 0));
    emit_case("delivery", "drop_when_sendable", (uint64_t)reliable_plan(0, 0, 1, 1));
    emit_case("delivery", "max_beams", MAX_BEAMS);
    return 0;
}
