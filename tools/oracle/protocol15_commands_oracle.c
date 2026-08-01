/*
 * Protocol-15 signon, command-stream and fast-entity-update oracle.
 *
 * The serializers below are isolated from WinQuake/GLQuake 1.09 source units:
 *   cl_main.c: CL_SignonReply
 *   cl_parse.c: CL_ParseUpdate signon promotion contract
 *   host_cmd.c: Host_PreSpawn_f, Host_Spawn_f, Host_Begin_f
 *   sv_main.c: SV_WriteEntitiesToClient
 *   sv_user.c: SV_ReadClientMessage
 *   protocol.h
 *
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2026 MiniQuake contributors
 * GPL-2.0-or-later; see COPYING.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PROTOCOL_VERSION 15

#define svc_nop 1
#define svc_disconnect 2
#define svc_updatestat 3
#define svc_version 4
#define svc_setview 5
#define svc_sound 6
#define svc_time 7
#define svc_print 8
#define svc_stufftext 9
#define svc_setangle 10
#define svc_serverinfo 11
#define svc_lightstyle 12
#define svc_updatename 13
#define svc_updatefrags 14
#define svc_clientdata 15
#define svc_stopsound 16
#define svc_updatecolors 17
#define svc_particle 18
#define svc_damage 19
#define svc_spawnstatic 20
#define svc_spawnbaseline 22
#define svc_temp_entity 23
#define svc_setpause 24
#define svc_signonnum 25
#define svc_centerprint 26
#define svc_killedmonster 27
#define svc_foundsecret 28
#define svc_spawnstaticsound 29
#define svc_intermission 30
#define svc_finale 31
#define svc_cdtrack 32
#define svc_sellscreen 33
#define svc_cutscene 34

#define clc_nop 1
#define clc_disconnect 2
#define clc_move 3
#define clc_stringcmd 4

#define U_MOREBITS 1
#define U_ORIGIN1 2
#define U_ORIGIN2 4
#define U_ORIGIN3 8
#define U_ANGLE2 16
#define U_NOLERP 32
#define U_FRAME 64
#define U_SIGNAL 128
#define U_ANGLE1 256
#define U_ANGLE3 512
#define U_MODEL 1024
#define U_COLORMAP 2048
#define U_SKIN 4096
#define U_EFFECTS 8192
#define U_LONGENTITY 16384

#define SU_WEAPON 16384
#define MOVETYPE_STEP 4
#define TE_SPIKE 0

#define ARRAY_COUNT(a) ((int)(sizeof(a) / sizeof((a)[0])))

typedef struct {
    uint8_t data[16384];
    int cursize;
} sizebuf_t;

typedef struct {
    int modelindex;
    int frame;
    int colormap;
    int skin;
    int effects;
    float origin[3];
    float angles[3];
} entity_state_t;

static void die(const char *message) {
    fprintf(stderr, "%s\n", message);
    exit(2);
}

static uint8_t *space(sizebuf_t *b, int count) {
    if (count < 0 || b->cursize + count > (int)sizeof(b->data)) die("oracle buffer overflow");
    uint8_t *result = b->data + b->cursize;
    b->cursize += count;
    return result;
}

static void clear(sizebuf_t *b) { memset(b, 0, sizeof(*b)); }
static void write_byte(sizebuf_t *b, int value) { space(b, 1)[0] = (uint8_t)value; }
static void write_char(sizebuf_t *b, int value) { write_byte(b, value); }
static void write_short(sizebuf_t *b, int value) {
    uint8_t *out = space(b, 2);
    out[0] = (uint8_t)(value & 255);
    out[1] = (uint8_t)(((uint32_t)value >> 8) & 255);
}
static void write_long(sizebuf_t *b, int32_t value) {
    uint32_t bits = (uint32_t)value;
    uint8_t *out = space(b, 4);
    out[0] = (uint8_t)(bits & 255);
    out[1] = (uint8_t)((bits >> 8) & 255);
    out[2] = (uint8_t)((bits >> 16) & 255);
    out[3] = (uint8_t)((bits >> 24) & 255);
}
static void write_float(sizebuf_t *b, float value) {
    uint32_t bits = 0;
    memcpy(&bits, &value, sizeof(bits));
    write_long(b, (int32_t)bits);
}
static void write_string(sizebuf_t *b, const char *value) {
    size_t length = value == NULL ? 0u : strlen(value);
    uint8_t *out = space(b, (int)length + 1);
    if (length != 0u) memcpy(out, value, length);
    out[length] = 0;
}
static void write_coord(sizebuf_t *b, float value) { write_short(b, (int)(value * 8.0f)); }
static void write_angle(sizebuf_t *b, float value) { write_byte(b, (((int)value * 256 / 360) & 255)); }
static void write_string_command(sizebuf_t *b, const char *text) {
    write_byte(b, clc_stringcmd);
    write_string(b, text);
}

static void print_hex(const uint8_t *data, int length) {
    for (int i = 0; i < length; ++i) printf("%02x", data[i]);
}
static void vector_line(const char *name, const sizebuf_t *b) {
    printf("{\"name\":\"%s\",\"bytes\":\"", name);
    print_hex(b->data, b->cursize);
    printf("\",\"length\":%d}\n", b->cursize);
}

static void write_client_signon_reply(sizebuf_t *b, int stage, const char *name, int colors, const char *spawn_parms) {
    char text[1024];
    switch (stage) {
        case 1:
            write_string_command(b, "prespawn");
            break;
        case 2:
            snprintf(text, sizeof(text), "name \"%s\"\n", name);
            write_string_command(b, text);
            snprintf(text, sizeof(text), "color %i %i\n", colors >> 4, colors & 15);
            write_string_command(b, text);
            snprintf(text, sizeof(text), "spawn %s", spawn_parms);
            write_string_command(b, text);
            break;
        case 3:
            write_string_command(b, "begin");
            break;
        case 4:
            /* CL_SignonReply only ends the loading plaque. */
            break;
        default:
            die("invalid signon stage");
    }
}

static int update_bits(int entity_number, const entity_state_t *baseline, const entity_state_t *current, int movetype) {
    int bits = 0;
    for (int axis = 0; axis < 3; ++axis) {
        float miss = current->origin[axis] - baseline->origin[axis];
        if (miss < -0.1f || miss > 0.1f) bits |= U_ORIGIN1 << axis;
    }
    if (current->angles[0] != baseline->angles[0]) bits |= U_ANGLE1;
    if (current->angles[1] != baseline->angles[1]) bits |= U_ANGLE2;
    if (current->angles[2] != baseline->angles[2]) bits |= U_ANGLE3;
    if (movetype == MOVETYPE_STEP) bits |= U_NOLERP;
    if (baseline->colormap != current->colormap) bits |= U_COLORMAP;
    if (baseline->skin != current->skin) bits |= U_SKIN;
    if (baseline->frame != current->frame) bits |= U_FRAME;
    if (baseline->effects != current->effects) bits |= U_EFFECTS;
    if (baseline->modelindex != current->modelindex) bits |= U_MODEL;
    if (entity_number >= 256) bits |= U_LONGENTITY;
    if (bits >= 256) bits |= U_MOREBITS;
    return bits;
}

static int write_fast_update(sizebuf_t *b, int entity_number, const entity_state_t *baseline, const entity_state_t *current, int movetype) {
    int bits = update_bits(entity_number, baseline, current, movetype);
    write_byte(b, bits | U_SIGNAL);
    if (bits & U_MOREBITS) write_byte(b, bits >> 8);
    if (bits & U_LONGENTITY) write_short(b, entity_number); else write_byte(b, entity_number);
    if (bits & U_MODEL) write_byte(b, current->modelindex);
    if (bits & U_FRAME) write_byte(b, current->frame);
    if (bits & U_COLORMAP) write_byte(b, current->colormap);
    if (bits & U_SKIN) write_byte(b, current->skin);
    if (bits & U_EFFECTS) write_byte(b, current->effects);
    if (bits & U_ORIGIN1) write_coord(b, current->origin[0]);
    if (bits & U_ANGLE1) write_angle(b, current->angles[0]);
    if (bits & U_ORIGIN2) write_coord(b, current->origin[1]);
    if (bits & U_ANGLE2) write_angle(b, current->angles[1]);
    if (bits & U_ORIGIN3) write_coord(b, current->origin[2]);
    if (bits & U_ANGLE3) write_angle(b, current->angles[2]);
    return bits;
}

static entity_state_t baseline_state(void) {
    entity_state_t state;
    memset(&state, 0, sizeof(state));
    state.modelindex = 1;
    state.frame = 2;
    state.colormap = 3;
    state.skin = 4;
    state.effects = 5;
    state.origin[0] = 10.0f; state.origin[1] = 20.0f; state.origin[2] = 30.0f;
    state.angles[0] = 0.0f; state.angles[1] = 45.0f; state.angles[2] = 90.0f;
    return state;
}

static void write_baseline_payload(sizebuf_t *b) {
    write_byte(b, 1);
    write_byte(b, 2);
    write_byte(b, 0);
    write_byte(b, 0);
    write_coord(b, 1.0f); write_angle(b, 0.0f);
    write_coord(b, 2.0f); write_angle(b, 90.0f);
    write_coord(b, 3.0f); write_angle(b, 180.0f);
}

static void write_svc_catalog(sizebuf_t *b) {
    write_byte(b, svc_nop);
    write_byte(b, svc_disconnect);
    write_byte(b, svc_updatestat); write_byte(b, 2); write_long(b, 123456);
    write_byte(b, svc_version); write_long(b, PROTOCOL_VERSION);
    write_byte(b, svc_setview); write_short(b, 1);
    write_byte(b, svc_sound); write_byte(b, 0); write_short(b, 17); write_byte(b, 1);
    write_coord(b, 1.0f); write_coord(b, 2.0f); write_coord(b, 3.0f);
    write_byte(b, svc_time); write_float(b, 12.5f);
    write_byte(b, svc_print); write_string(b, "print\n");
    write_byte(b, svc_stufftext); write_string(b, "echo fixture\n");
    write_byte(b, svc_setangle); write_angle(b, 10.0f); write_angle(b, 90.0f); write_angle(b, -45.0f);
    write_byte(b, svc_serverinfo); write_long(b, PROTOCOL_VERSION); write_byte(b, 1); write_byte(b, 0);
    write_string(b, "start"); write_string(b, "maps/start.bsp"); write_string(b, "progs/player.mdl"); write_string(b, "");
    write_string(b, "misc/menu1.wav"); write_string(b, "");
    write_byte(b, svc_lightstyle); write_byte(b, 0); write_string(b, "m");
    write_byte(b, svc_updatename); write_byte(b, 0); write_string(b, "Ranger");
    write_byte(b, svc_updatefrags); write_byte(b, 0); write_short(b, 7);
    write_byte(b, svc_clientdata); write_short(b, SU_WEAPON); write_long(b, 0x12345678); write_byte(b, 2);
    write_short(b, 100); write_byte(b, 10); write_byte(b, 11); write_byte(b, 12); write_byte(b, 13); write_byte(b, 14); write_byte(b, 1);
    write_byte(b, svc_stopsound); write_short(b, 17);
    write_byte(b, svc_updatecolors); write_byte(b, 0); write_byte(b, 0x4d);
    write_byte(b, svc_particle); write_coord(b, 1.0f); write_coord(b, 2.0f); write_coord(b, 3.0f);
    write_char(b, 1); write_char(b, -2); write_char(b, 3); write_byte(b, 4); write_byte(b, 5);
    write_byte(b, svc_damage); write_byte(b, 1); write_byte(b, 2); write_coord(b, 4.0f); write_coord(b, 5.0f); write_coord(b, 6.0f);
    write_byte(b, svc_spawnstatic); write_baseline_payload(b);
    write_byte(b, svc_spawnbaseline); write_short(b, 2); write_baseline_payload(b);
    write_byte(b, svc_temp_entity); write_byte(b, TE_SPIKE); write_coord(b, 7.0f); write_coord(b, 8.0f); write_coord(b, 9.0f);
    write_byte(b, svc_setpause); write_byte(b, 1);
    write_byte(b, svc_signonnum); write_byte(b, 1);
    write_byte(b, svc_centerprint); write_string(b, "center");
    write_byte(b, svc_killedmonster);
    write_byte(b, svc_foundsecret);
    write_byte(b, svc_spawnstaticsound); write_coord(b, 1.0f); write_coord(b, 2.0f); write_coord(b, 3.0f);
    write_byte(b, 1); write_byte(b, 255); write_byte(b, 64);
    write_byte(b, svc_intermission);
    write_byte(b, svc_finale); write_string(b, "finale");
    write_byte(b, svc_cdtrack); write_byte(b, 3); write_byte(b, 3);
    write_byte(b, svc_sellscreen);
    write_byte(b, svc_cutscene); write_string(b, "cutscene");

    entity_state_t base = baseline_state();
    write_fast_update(b, 1, &base, &base, 0);
}

int main(void) {
    sizebuf_t b;
    entity_state_t base = baseline_state();
    entity_state_t current;

    for (int stage = 1; stage <= 4; ++stage) {
        char name[64];
        snprintf(name, sizeof(name), "signon_reply_%d", stage);
        clear(&b);
        write_client_signon_reply(&b, stage, "Ranger", 0x4d, "1 2 3");
        vector_line(name, &b);
    }

    clear(&b);
    write_byte(&b, svc_signonnum); write_byte(&b, 1);
    write_byte(&b, svc_signonnum); write_byte(&b, 2);
    write_byte(&b, svc_signonnum); write_byte(&b, 3);
    vector_line("server_signon_markers_1_2_3", &b);

    clear(&b);
    write_byte(&b, clc_nop);
    write_byte(&b, clc_move);
    write_float(&b, 12.5f);
    write_angle(&b, 12.75f); write_angle(&b, 180.0f); write_angle(&b, -90.9f);
    write_short(&b, (int)200.75f); write_short(&b, (int)-123.9f); write_short(&b, (int)32768.9f);
    write_byte(&b, 3); write_byte(&b, 7);
    write_string_command(&b, "name \"Ranger\"\n");
    vector_line("clc_compound_stream", &b);

    clear(&b); write_byte(&b, clc_disconnect); vector_line("clc_disconnect", &b);
    clear(&b); write_byte(&b, 255); vector_line("clc_signed_eom", &b);

    clear(&b); write_fast_update(&b, 1, &base, &base, 0); vector_line("fast_update_unchanged_short", &b);
    current = base; current.effects = 6;
    clear(&b); write_fast_update(&b, 1, &base, &current, 0); vector_line("fast_update_effects_changed", &b);
    clear(&b); write_fast_update(&b, 1, &base, &base, MOVETYPE_STEP); vector_line("fast_update_step_only", &b);

    current = base;
    current.modelindex = 9; current.frame = 8; current.colormap = 6; current.skin = 7; current.effects = 10;
    current.origin[0] = 11.25f; current.origin[1] = 18.75f; current.origin[2] = 31.5f;
    current.angles[0] = 12.0f; current.angles[1] = 90.0f; current.angles[2] = -45.0f;
    clear(&b); write_fast_update(&b, 7, &base, &current, MOVETYPE_STEP); vector_line("fast_update_full_short", &b);
    clear(&b); write_fast_update(&b, 300, &base, &current, MOVETYPE_STEP); vector_line("fast_update_full_long", &b);

    clear(&b); write_svc_catalog(&b); vector_line("svc_catalog_stream", &b);
    return 0;
}
