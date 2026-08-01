/*
 * Protocol-15 server payload and packet-planning oracle.
 *
 * The isolated serializers reproduce WinQuake/GLQuake 1.09 behavior from:
 *   sv_main.c: SV_SendServerinfo, SV_StartSound,
 *              SV_WriteClientdataToMessage, SV_CreateBaseline,
 *              SV_SendClientDatagram, SV_WriteEntitiesToClient,
 *              SV_SendClientMessages
 *   protocol.h and server.h
 *
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2026 MiniQuake contributors
 * GPL-2.0-or-later; see COPYING.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define svc_setview 5
#define svc_sound 6
#define svc_print 8
#define svc_serverinfo 11
#define svc_clientdata 15
#define svc_spawnbaseline 22
#define svc_signonnum 25
#define svc_cdtrack 32

#define PROTOCOL_VERSION 15
#define GAME_COOP 0
#define GAME_DEATHMATCH 1
#define SIGNON_SERVERINFO 1

#define SND_VOLUME 1
#define SND_ATTENUATION 2

#define SU_VIEWHEIGHT 1
#define SU_IDEALPITCH 2
#define SU_PUNCH1 4
#define SU_VELOCITY1 32
#define SU_ITEMS 512
#define SU_ONGROUND 1024
#define SU_INWATER 2048
#define SU_WEAPONFRAME 4096
#define SU_ARMOR 8192
#define SU_WEAPON 16384

#define U_MOREBITS 1
#define U_ORIGIN1 2
#define U_ORIGIN2 4
#define U_ORIGIN3 8
#define U_ANGLE2 16
#define U_NOLERP 32
#define U_FRAME 64
#define U_ANGLE1 256
#define U_ANGLE3 512
#define U_MODEL 1024
#define U_COLORMAP 2048
#define U_SKIN 4096
#define U_EFFECTS 8192
#define U_LONGENTITY 16384

#define FL_ONGROUND 512

#define PLAN_SEND_UNRELIABLE 1
#define PLAN_SEND_NOP 2
#define PLAN_WAIT_SIGNON 4
#define PLAN_RELIABLE_PHASE 8

#define RELIABLE_NONE 0
#define RELIABLE_DROP_OVERFLOW 1
#define RELIABLE_WAIT 2
#define RELIABLE_DROP_ASAP 3
#define RELIABLE_SEND 4

typedef struct {
    uint8_t data[16384];
    int cursize;
} sizebuf_t;

typedef struct {
    float view_height;
    float ideal_pitch;
    float punch[3];
    float velocity[3];
    int flags;
    int water_level;
    float weapon_frame;
    float armor;
    int weapon_model;
    int health;
    int ammo;
    int shells;
    int nails;
    int rockets;
    int cells;
    uint32_t items;
    uint32_t active_weapon;
    int standard_quake;
} clientdata_t;

static void die(const char *message) {
    fprintf(stderr, "%s\n", message);
    exit(2);
}

static uint8_t *space(sizebuf_t *buffer, int count) {
    if (count < 0 || buffer->cursize + count > (int)sizeof(buffer->data)) {
        die("oracle buffer overflow");
    }
    uint8_t *result = buffer->data + buffer->cursize;
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
    uint16_t bits = (uint16_t)value;
    uint8_t *out = space(buffer, 2);
    out[0] = (uint8_t)(bits & 255u);
    out[1] = (uint8_t)(bits >> 8);
}

static void write_long(sizebuf_t *buffer, uint32_t value) {
    uint8_t *out = space(buffer, 4);
    out[0] = (uint8_t)(value & 255u);
    out[1] = (uint8_t)((value >> 8) & 255u);
    out[2] = (uint8_t)((value >> 16) & 255u);
    out[3] = (uint8_t)((value >> 24) & 255u);
}

static void write_string(sizebuf_t *buffer, const char *value) {
    size_t length = value == NULL ? 0u : strlen(value);
    uint8_t *out = space(buffer, (int)length + 1);
    if (length != 0u) {
        memcpy(out, value, length);
    }
    out[length] = 0;
}

static void write_coord(sizebuf_t *buffer, float value) {
    write_short(buffer, (int)(value * 8.0f));
}

static void write_angle(sizebuf_t *buffer, float value) {
    write_byte(buffer, (((int)value * 256 / 360) & 255));
}

static void print_hex(const uint8_t *data, int length) {
    for (int index = 0; index < length; ++index) {
        printf("%02x", data[index]);
    }
}

static void vector_line(const char *name, const sizebuf_t *buffer, int include_bits, int bits) {
    printf("{\"kind\":\"vector\",\"name\":\"%s\",\"bytes\":\"", name);
    print_hex(buffer->data, buffer->cursize);
    printf("\",\"length\":%d", buffer->cursize);
    if (include_bits) {
        printf(",\"bits\":%d", bits);
    }
    printf("}\n");
}

static void write_precache_list(sizebuf_t *buffer, const char *const *values, int count) {
    for (int index = 1; index < count; ++index) {
        const char *value = values[index];
        if (value == NULL || value[0] == '\0') {
            break;
        }
        write_string(buffer, value);
    }
    write_byte(buffer, 0);
}

static void write_server_info(
    sizebuf_t *buffer,
    int crc,
    int maximum,
    int game_type,
    const char *level,
    const char *const *models,
    int model_count,
    const char *const *sounds,
    int sound_count,
    int cd_track,
    int view_entity
) {
    char version[128];
    int written = snprintf(version, sizeof(version), "\002\nVERSION 1.09 SERVER (%i CRC)", crc);
    if (written < 0 || written >= (int)sizeof(version)) {
        die("version string overflow");
    }
    write_byte(buffer, svc_print);
    write_string(buffer, version);
    write_byte(buffer, svc_serverinfo);
    write_long(buffer, PROTOCOL_VERSION);
    write_byte(buffer, maximum);
    write_byte(buffer, game_type);
    write_string(buffer, level);
    write_precache_list(buffer, models, model_count);
    write_precache_list(buffer, sounds, sound_count);
    write_byte(buffer, svc_cdtrack);
    write_byte(buffer, cd_track);
    write_byte(buffer, cd_track);
    write_byte(buffer, svc_setview);
    write_short(buffer, view_entity);
    write_byte(buffer, svc_signonnum);
    write_byte(buffer, SIGNON_SERVERINFO);
}

static void write_sound(
    sizebuf_t *buffer,
    int entity,
    int channel,
    int sound,
    int volume,
    float attenuation,
    const float center[3]
) {
    int field_mask = 0;
    if (volume != 255) {
        field_mask |= SND_VOLUME;
    }
    if (attenuation != 1.0f) {
        field_mask |= SND_ATTENUATION;
    }
    write_byte(buffer, svc_sound);
    write_byte(buffer, field_mask);
    if ((field_mask & SND_VOLUME) != 0) {
        write_byte(buffer, volume);
    }
    if ((field_mask & SND_ATTENUATION) != 0) {
        write_byte(buffer, (int)(attenuation * 64.0f));
    }
    write_short(buffer, (entity << 3) | channel);
    write_byte(buffer, sound);
    for (int axis = 0; axis < 3; ++axis) {
        write_coord(buffer, center[axis]);
    }
}

static int client_data_bits(const clientdata_t *data) {
    int bits = SU_ITEMS | SU_WEAPON;
    if (data->view_height != 22.0f) {
        bits |= SU_VIEWHEIGHT;
    }
    if (data->ideal_pitch != 0.0f) {
        bits |= SU_IDEALPITCH;
    }
    if ((data->flags & FL_ONGROUND) != 0) {
        bits |= SU_ONGROUND;
    }
    if (data->water_level >= 2) {
        bits |= SU_INWATER;
    }
    for (int axis = 0; axis < 3; ++axis) {
        if (data->punch[axis] != 0.0f) {
            bits |= SU_PUNCH1 << axis;
        }
        if (data->velocity[axis] != 0.0f) {
            bits |= SU_VELOCITY1 << axis;
        }
    }
    if (data->weapon_frame != 0.0f) {
        bits |= SU_WEAPONFRAME;
    }
    if (data->armor != 0.0f) {
        bits |= SU_ARMOR;
    }
    return bits;
}

static int write_client_data(sizebuf_t *buffer, const clientdata_t *data) {
    int bits = client_data_bits(data);
    write_byte(buffer, svc_clientdata);
    write_short(buffer, bits);
    if ((bits & SU_VIEWHEIGHT) != 0) {
        write_char(buffer, (int)data->view_height);
    }
    if ((bits & SU_IDEALPITCH) != 0) {
        write_char(buffer, (int)data->ideal_pitch);
    }
    for (int axis = 0; axis < 3; ++axis) {
        if ((bits & (SU_PUNCH1 << axis)) != 0) {
            write_char(buffer, (int)data->punch[axis]);
        }
        if ((bits & (SU_VELOCITY1 << axis)) != 0) {
            write_char(buffer, (int)(data->velocity[axis] / 16.0f));
        }
    }
    write_long(buffer, data->items);
    if ((bits & SU_WEAPONFRAME) != 0) {
        write_byte(buffer, (int)data->weapon_frame);
    }
    if ((bits & SU_ARMOR) != 0) {
        write_byte(buffer, (int)data->armor);
    }
    write_byte(buffer, data->weapon_model);
    write_short(buffer, data->health);
    write_byte(buffer, data->ammo);
    write_byte(buffer, data->shells);
    write_byte(buffer, data->nails);
    write_byte(buffer, data->rockets);
    write_byte(buffer, data->cells);
    if (data->standard_quake) {
        write_byte(buffer, (int)data->active_weapon);
    } else {
        for (int bit = 0; bit < 32; ++bit) {
            if ((data->active_weapon & ((uint32_t)1u << bit)) != 0u) {
                write_byte(buffer, bit);
                break;
            }
        }
    }
    return bits;
}

static void write_baseline(
    sizebuf_t *buffer,
    int entity,
    int model,
    int frame,
    int colormap,
    int skin,
    const float origin[3],
    const float angles[3]
) {
    write_byte(buffer, svc_spawnbaseline);
    write_short(buffer, entity);
    write_byte(buffer, model);
    write_byte(buffer, frame);
    write_byte(buffer, colormap);
    write_byte(buffer, skin);
    for (int axis = 0; axis < 3; ++axis) {
        write_coord(buffer, origin[axis]);
        write_angle(buffer, angles[axis]);
    }
}

static int encoded_update_size(int bits) {
    int count = 1;
    if ((bits & U_MOREBITS) != 0) {
        count += 1;
    }
    count += (bits & U_LONGENTITY) != 0 ? 2 : 1;
    const int byte_fields[] = {U_MODEL, U_FRAME, U_COLORMAP, U_SKIN, U_EFFECTS};
    const int coord_fields[] = {U_ORIGIN1, U_ORIGIN2, U_ORIGIN3};
    const int angle_fields[] = {U_ANGLE1, U_ANGLE2, U_ANGLE3};
    for (unsigned index = 0; index < sizeof(byte_fields) / sizeof(byte_fields[0]); ++index) {
        if ((bits & byte_fields[index]) != 0) {
            count += 1;
        }
    }
    for (unsigned index = 0; index < sizeof(coord_fields) / sizeof(coord_fields[0]); ++index) {
        if ((bits & coord_fields[index]) != 0) {
            count += 2;
        }
    }
    for (unsigned index = 0; index < sizeof(angle_fields) / sizeof(angle_fields[0]); ++index) {
        if ((bits & angle_fields[index]) != 0) {
            count += 1;
        }
    }
    return count;
}

static int can_write_update(int remaining, int bits) {
    if (remaining < 16) {
        return 0;
    }
    return encoded_update_size(bits) <= remaining;
}

static int initial_delivery_plan(int spawned, int send_signon, float elapsed) {
    if (spawned) {
        return PLAN_SEND_UNRELIABLE | PLAN_RELIABLE_PHASE;
    }
    if (!send_signon) {
        if (elapsed > 5.0f) {
            return PLAN_SEND_NOP;
        }
        return PLAN_WAIT_SIGNON;
    }
    return PLAN_RELIABLE_PHASE;
}

static int reliable_delivery_plan(int overflowed, int message_size, int drop_asap, int can_send) {
    if (overflowed) {
        return RELIABLE_DROP_OVERFLOW;
    }
    if (message_size <= 0 && !drop_asap) {
        return RELIABLE_NONE;
    }
    if (!can_send) {
        return RELIABLE_WAIT;
    }
    if (drop_asap) {
        return RELIABLE_DROP_ASAP;
    }
    return RELIABLE_SEND;
}

static clientdata_t base_client_data(void) {
    clientdata_t data;
    memset(&data, 0, sizeof(data));
    data.view_height = 22.0f;
    data.weapon_model = 3;
    data.health = 100;
    data.ammo = 40;
    data.shells = 25;
    data.nails = 50;
    data.rockets = 5;
    data.cells = 100;
    data.items = 0x12345678u;
    data.active_weapon = 2u;
    data.standard_quake = 1;
    return data;
}

static void print_initial_case(
    const char *name,
    int spawned,
    int send_signon,
    const char *elapsed_text,
    float elapsed
) {
    printf(
        "{\"kind\":\"initial\",\"name\":\"%s\","
        "\"spawned\":%s,\"send_signon\":%s,\"elapsed\":%s,\"plan\":%d}\n",
        name,
        spawned ? "true" : "false",
        send_signon ? "true" : "false",
        elapsed_text,
        initial_delivery_plan(spawned, send_signon, elapsed)
    );
}

static void print_reliable_case(
    const char *name,
    int overflowed,
    int message_size,
    int drop_asap,
    int can_send
) {
    printf(
        "{\"kind\":\"reliable\",\"name\":\"%s\","
        "\"overflowed\":%s,\"message_size\":%d,\"drop_asap\":%s,"
        "\"can_send\":%s,\"plan\":%d}\n",
        name,
        overflowed ? "true" : "false",
        message_size,
        drop_asap ? "true" : "false",
        can_send ? "true" : "false",
        reliable_delivery_plan(overflowed, message_size, drop_asap, can_send)
    );
}

static void print_datagram_case(
    const char *name,
    int destination_size,
    int source_size,
    int max_size
) {
    int append = destination_size + source_size < max_size;
    printf(
        "{\"kind\":\"datagram\",\"name\":\"%s\","
        "\"destination_size\":%d,\"source_size\":%d,\"max_size\":%d,"
        "\"append\":%s}\n",
        name,
        destination_size,
        source_size,
        max_size,
        append ? "true" : "false"
    );
}

static void print_fast_update_case(
    const char *name,
    int remaining,
    int bits
) {
    printf(
        "{\"kind\":\"fast_update\",\"name\":\"%s\","
        "\"remaining\":%d,\"bits\":%d,\"encoded_size\":%d,"
        "\"can_write\":%s}\n",
        name,
        remaining,
        bits,
        encoded_update_size(bits),
        can_write_update(remaining, bits) ? "true" : "false"
    );
}

static void print_contract_cases(void) {
    print_initial_case("spawned", 1, 0, "0.0", 0.0f);
    print_initial_case("spawned_signon_flag", 1, 1, "9.0", 9.0f);
    print_initial_case("signon_requested", 0, 1, "0.0", 0.0f);
    print_initial_case("wait_before_five", 0, 0, "4.999", 4.999f);
    print_initial_case("wait_at_five", 0, 0, "5.0", 5.0f);
    print_initial_case("nop_after_five", 0, 0, "5.001", 5.001f);

    print_reliable_case("overflow", 1, 1, 0, 1);
    print_reliable_case("empty", 0, 0, 0, 0);
    print_reliable_case("blocked_message", 0, 1, 0, 0);
    print_reliable_case("blocked_dropasap", 0, 0, 1, 0);
    print_reliable_case("dropasap_empty", 0, 0, 1, 1);
    print_reliable_case("dropasap_message", 0, 4, 1, 1);
    print_reliable_case("send_one", 0, 1, 0, 1);
    print_reliable_case("send_full", 0, 8192, 0, 1);

    print_datagram_case("empty_source", 8, 0, 16);
    print_datagram_case("strictly_below", 8, 7, 16);
    print_datagram_case("equal_rejected", 8, 8, 16);
    print_datagram_case("above_rejected", 9, 8, 16);
    print_datagram_case("empty_equal_rejected", 16, 0, 16);

    int full_short = U_MOREBITS | U_ORIGIN1 | U_ORIGIN2 | U_ORIGIN3 |
        U_ANGLE2 | U_NOLERP | U_FRAME | U_ANGLE1 | U_ANGLE3 | U_MODEL |
        U_COLORMAP | U_SKIN | U_EFFECTS;
    int full_long = full_short | U_LONGENTITY;
    print_fast_update_case("remaining_15_unchanged", 15, 0);
    print_fast_update_case("remaining_16_unchanged", 16, 0);
    print_fast_update_case("remaining_16_full_short", 16, full_short);
    print_fast_update_case("remaining_17_full_short", 17, full_short);
    print_fast_update_case("remaining_17_full_long", 17, full_long);
    print_fast_update_case("remaining_18_full_long", 18, full_long);
}

int main(void) {
    sizebuf_t buffer;

    const char *models_coop[] = {"", "maps/e1m1.bsp", "progs/player.mdl", "", "ignored.mdl"};
    const char *sounds_coop[] = {"", "misc/menu1.wav", "", "ignored.wav"};
    clear(&buffer);
    write_server_info(&buffer, 5927, 1, GAME_COOP, "The Slipgate Complex",
        models_coop, 5, sounds_coop, 4, 2, 1);
    vector_line("serverinfo_coop", &buffer, 0, 0);

    const char *models_dm[] = {"", "maps/dm1.bsp", ""};
    const char *sounds_dm[] = {"", ""};
    clear(&buffer);
    write_server_info(&buffer, 12345, 4, GAME_DEATHMATCH, "Place of Two Deaths",
        models_dm, 3, sounds_dm, 2, 0, 4);
    vector_line("serverinfo_deathmatch", &buffer, 0, 0);

    const float sound_default_center[3] = {10.0f, -20.0f, 30.0f};
    clear(&buffer);
    write_sound(&buffer, 3, (int)2.9, 5, (int)255.9, 1.0000000298023224, sound_default_center);
    vector_line("sound_default", &buffer, 0, 0);

    const float sound_custom_center[3] = {-12.25f, 0.125f, 4095.875f};
    clear(&buffer);
    write_sound(&buffer, 300, 7, 255, 128, 0.5f, sound_custom_center);
    vector_line("sound_custom", &buffer, 0, 0);

    /* The public C function receives float: this double literal must round to 1.0f. */
    clear(&buffer);
    write_sound(&buffer, 3, 2, 5, 255, 1.00000001, sound_default_center);
    vector_line("sound_float_parameter_rounding", &buffer, 0, 0);

    clientdata_t data = base_client_data();
    clear(&buffer);
    int bits = write_client_data(&buffer, &data);
    vector_line("clientdata_minimal", &buffer, 1, bits);

    data = base_client_data();
    data.view_height = 30.0f;
    data.ideal_pitch = -5.0f;
    data.punch[0] = 1.0f; data.punch[1] = -2.0f; data.punch[2] = 3.0f;
    data.velocity[0] = 16.0f; data.velocity[1] = -32.0f; data.velocity[2] = 48.0f;
    data.flags = FL_ONGROUND;
    data.water_level = 2;
    data.weapon_frame = 300.0f;
    data.armor = -1.0f;
    data.weapon_model = 257;
    data.health = -20;
    data.ammo = 300;
    data.shells = -1;
    data.nails = 256;
    data.rockets = 511;
    data.cells = 128;
    data.items = 0xF1234567u;
    data.active_weapon = 260u;
    clear(&buffer);
    bits = write_client_data(&buffer, &data);
    vector_line("clientdata_full_standard", &buffer, 1, bits);

    data = base_client_data();
    data.weapon_model = 4;
    data.health = 80;
    data.ammo = 12;
    data.shells = 13;
    data.nails = 14;
    data.rockets = 15;
    data.cells = 16;
    data.items = 0x00800001u;
    data.active_weapon = (uint32_t)1u << 7;
    data.standard_quake = 0;
    clear(&buffer);
    bits = write_client_data(&buffer, &data);
    vector_line("clientdata_missionpack", &buffer, 1, bits);

    data.active_weapon = 0u;
    clear(&buffer);
    bits = write_client_data(&buffer, &data);
    vector_line("clientdata_missionpack_zero", &buffer, 1, bits);

    const float world_origin[3] = {-12.25f, 0.125f, 4095.875f};
    const float world_angles[3] = {90.75f, -90.9f, 359.9f};
    clear(&buffer);
    write_baseline(&buffer, 0, 1, 2, 0, 4, world_origin, world_angles);
    vector_line("baseline_world", &buffer, 0, 0);

    const float player_origin[3] = {10.0f, 20.0f, 30.0f};
    const float player_angles[3] = {0.0f, 45.0f, 90.0f};
    clear(&buffer);
    write_baseline(&buffer, 1, 2, 3, 1, 5, player_origin, player_angles);
    vector_line("baseline_player", &buffer, 0, 0);

    print_contract_cases();
    return 0;
}
