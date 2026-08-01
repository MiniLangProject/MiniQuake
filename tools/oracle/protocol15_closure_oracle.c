/* Source-guided Protocol 15 closure oracle for MiniQuake BP-019. */
#include <stdint.h>
#include <stdio.h>

#define PROTOCOL_VERSION 15u
#define MAX_MSGLEN 8000u
#define MAX_DATAGRAM 1024u
#define MAX_EDICTS 600u
#define NET_MAXMESSAGE 8192u

static const uint32_t svc[] = {
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
    22,23,24,25,26,27,28,29,30,31,32,33,34
};
static const uint32_t clc[] = {1,2,3,4};
static const uint32_t update_bits[] = {
    1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384
};
static const uint32_t client_bits[] = {
    1,2,4,8,16,32,64,128,512,1024,2048,4096,8192,16384
};
static const uint32_t sound_bits[] = {1,2,4};
static const uint32_t temporary_entities[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};

static uint32_t mask(const uint32_t *values, size_t count) {
    uint32_t result = 0;
    size_t i;
    for (i = 0; i < count; ++i) result |= values[i];
    return result;
}

static uint32_t hash_value(uint32_t current, uint32_t value) {
    return (current ^ value) * UINT32_C(16777619);
}

static uint32_t hash_values(uint32_t current, const uint32_t *values, size_t count) {
    size_t i;
    for (i = 0; i < count; ++i) current = hash_value(current, values[i]);
    return current;
}

static uint32_t fingerprint(void) {
    uint32_t result = UINT32_C(2166136261);
    result = hash_value(result, PROTOCOL_VERSION);
    result = hash_value(result, UINT32_C(0x535643));
    result = hash_values(result, svc, sizeof(svc) / sizeof(svc[0]));
    result = hash_value(result, UINT32_C(0x434c43));
    result = hash_values(result, clc, sizeof(clc) / sizeof(clc[0]));
    result = hash_value(result, UINT32_C(0x55424954));
    result = hash_values(result, update_bits, sizeof(update_bits) / sizeof(update_bits[0]));
    result = hash_value(result, UINT32_C(0x53554249));
    result = hash_values(result, client_bits, sizeof(client_bits) / sizeof(client_bits[0]));
    result = hash_value(result, UINT32_C(0x534e44));
    result = hash_values(result, sound_bits, sizeof(sound_bits) / sizeof(sound_bits[0]));
    result = hash_value(result, UINT32_C(0x5445));
    result = hash_values(result, temporary_entities, sizeof(temporary_entities) / sizeof(temporary_entities[0]));
    return result;
}

static void row(const char *name, uint64_t value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%llu}\n",
           name, (unsigned long long)value);
}

int main(void) {
    row("protocol_version", PROTOCOL_VERSION);
    row("svc_valid_count", sizeof(svc) / sizeof(svc[0]));
    row("svc_reserved_command", 21u);
    row("clc_valid_count", sizeof(clc) / sizeof(clc[0]));
    row("fast_update_mask", mask(update_bits, sizeof(update_bits) / sizeof(update_bits[0])));
    row("client_data_mask", mask(client_bits, sizeof(client_bits) / sizeof(client_bits[0])));
    row("sound_mask", mask(sound_bits, sizeof(sound_bits) / sizeof(sound_bits[0])));
    row("temporary_entity_count", sizeof(temporary_entities) / sizeof(temporary_entities[0]));
    row("protocol_fingerprint", fingerprint());
    row("max_msglen", MAX_MSGLEN);
    row("max_datagram", MAX_DATAGRAM);
    row("max_edicts", MAX_EDICTS);
    row("net_maxmessage", NET_MAXMESSAGE);
    return 0;
}
