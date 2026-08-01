#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t fbits(float value) {
    uint32_t result;
    memcpy(&result, &value, sizeof(result));
    return result;
}

static void emit_text(const char *name, const char *value) {
    printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":\"%s\"}\n", name, value);
}

static void format_one(char *out, size_t capacity, float value) {
    if (value == (int)value) {
        snprintf(out, capacity, "%d", (int)value);
    } else {
        snprintf(out, capacity, "%5.1f", (double)value);
    }
}

int main(void) {
    char text[128];
    char x[32], y[32], z[32];
    uint32_t seed = 1u;
    int random_value;

    printf("{\"kind\":\"case\",\"name\":\"builtin_count\",\"value\":79}\n");
    printf("{\"kind\":\"case\",\"name\":\"fixme_slot_5\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"fixme_slot_66\",\"value\":1}\n");

    format_one(text, sizeof(text), -12.0f); emit_text("ftos_integer", text);
    format_one(text, sizeof(text), 1.25f); emit_text("ftos_positive_tie", text);
    format_one(text, sizeof(text), -1.25f); emit_text("ftos_negative_tie", text);
    format_one(text, sizeof(text), 2.35f); emit_text("ftos_binary32_below_tie", text);
    format_one(text, sizeof(text), -0.04f); emit_text("ftos_negative_zero", text);

    snprintf(x, sizeof(x), "%5.1f", (double)1.25f);
    snprintf(y, sizeof(y), "%5.1f", (double)-1.25f);
    snprintf(z, sizeof(z), "%5.1f", (double)-0.04f);
    snprintf(text, sizeof(text), "'%s %s %s'", x, y, z);
    emit_text("vtos", text);

    seed = seed * 214013u + 2531011u;
    random_value = (int)((seed >> 16) & 0x7fffu);
    printf("{\"kind\":\"case\",\"name\":\"msvc_rand_first\",\"value\":%d}\n", random_value);
    printf("{\"kind\":\"case\",\"name\":\"msvc_rand_float_bits\",\"value\":%u}\n", fbits((float)random_value / 32767.0f));
    printf("{\"kind\":\"case\",\"name\":\"changelevel_one_shot\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"temporary_string_shared\",\"value\":1}\n");
    return 0;
}
