#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SAVEGAME_VERSION 5
#define SAVEGAME_COMMENT_LENGTH 39

static uint32_t fbits(float value) {
    uint32_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

static uint32_t fnv1a(const unsigned char *data, size_t length) {
    uint32_t hash = 2166136261u;
    size_t index;
    for (index = 0; index < length; ++index) {
        hash ^= data[index];
        hash *= 16777619u;
    }
    return hash;
}

static void save_comment(char *text, const char *level, int killed, int total) {
    char kills[20];
    int index;
    for (index = 0; index < SAVEGAME_COMMENT_LENGTH; ++index) text[index] = ' ';
    {
        size_t count = strlen(level);
        if (count > SAVEGAME_COMMENT_LENGTH) count = SAVEGAME_COMMENT_LENGTH;
        memcpy(text, level, count);
    }
    sprintf(kills, "kills:%3i/%3i", killed, total);
    memcpy(text + 22, kills, strlen(kills));
    for (index = 0; index < SAVEGAME_COMMENT_LENGTH; ++index) if (text[index] == ' ') text[index] = '_';
    text[SAVEGAME_COMMENT_LENGTH] = 0;
}

static void row(const char *name, unsigned long long value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%llu}\n", name, value);
}

int main(void) {
    char comment[SAVEGAME_COMMENT_LENGTH + 1];
    save_comment(comment, "Start", 2, 9);
    row("savegame_version", SAVEGAME_VERSION);
    row("comment_length", SAVEGAME_COMMENT_LENGTH);
    row("comment_fnv1a", fnv1a((const unsigned char *)comment, SAVEGAME_COMMENT_LENGTH));
    row("spawn_0_1_bits", fbits((float)0.100000001));
    row("spawn_negative_zero_bits", fbits((float)strtod("-0.000000", NULL)));
    row("skill_1_9_bits", fbits((float)1.9));
    row("legacy_skill_result", (unsigned int)((float)1.9 + 0.1f));
    row("time_bits", fbits((float)12.3456789));
    row("spawn_parms", 16);
    row("lightstyles", 64);
    row("fixture_count", 24);
    return 0;
}
