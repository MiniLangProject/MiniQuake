#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define FNV_OFFSET 2166136261u
#define FNV_PRIME 16777619u

static uint32_t hash_byte(uint32_t hash, uint32_t value) {
    return (hash ^ (value & 255u)) * FNV_PRIME;
}

static uint32_t hash_word(uint32_t hash, uint32_t value) {
    unsigned shift;
    for (shift = 0; shift < 32; shift += 8) hash = hash_byte(hash, value >> shift);
    return hash;
}

static uint32_t hash_text(uint32_t hash, const char *text) {
    while (*text) hash = hash_byte(hash, (unsigned char)*text++);
    return hash_byte(hash, 0u);
}

int main(void) {
    uint32_t hash = FNV_OFFSET;
    const uint32_t values[] = {6u, 5927u, 66u, 79u, 14u, 32u, 2048u, 0xb86a0245u};
    size_t index;
    for (index = 0; index < sizeof(values) / sizeof(values[0]); ++index) hash = hash_word(hash, values[index]);
    hash = hash_text(hash, "quakec_109_frozen_v1");
    printf("{\"kind\":\"case\",\"name\":\"version\",\"value\":6}\n");
    printf("{\"kind\":\"case\",\"name\":\"header_crc\",\"value\":5927}\n");
    printf("{\"kind\":\"case\",\"name\":\"opcode_count\",\"value\":66}\n");
    printf("{\"kind\":\"case\",\"name\":\"builtin_count\",\"value\":79}\n");
    printf("{\"kind\":\"case\",\"name\":\"fixme_count\",\"value\":14}\n");
    printf("{\"kind\":\"case\",\"name\":\"stack_depth\",\"value\":32}\n");
    printf("{\"kind\":\"case\",\"name\":\"localstack_size\",\"value\":2048}\n");
    printf("{\"kind\":\"case\",\"name\":\"builtin_fingerprint\",\"value\":3093955141}\n");
    printf("{\"kind\":\"case\",\"name\":\"contract_fingerprint\",\"value\":%u}\n", hash);
    printf("{\"kind\":\"case\",\"name\":\"required_globals\",\"value\":54}\n");
    printf("{\"kind\":\"case\",\"name\":\"required_fields\",\"value\":77}\n");
    printf("{\"kind\":\"case\",\"name\":\"required_functions\",\"value\":11}\n");
    printf("{\"kind\":\"case\",\"name\":\"highest_stock_builtin\",\"value\":78}\n");
    return hash == 0xbc89cbf1u ? 0 : 1;
}
