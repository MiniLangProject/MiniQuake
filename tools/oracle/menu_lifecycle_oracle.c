#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static float clampf_local(float x, float lo, float hi) {
    return x < lo ? lo : (x > hi ? hi : x);
}

static uint32_t float_bits(float value) {
    uint32_t result = 0;
    memcpy(&result, &value, sizeof(result));
    return result;
}

static float cvar_set_value_roundtrip(float value, char text[32]) {
    (void)snprintf(text, 32, "%f", (double)value);
    return (float)strtod(text, NULL);
}

int main(void) {
    char text[32];
    float cd = clampf_local(1.0f - 1.0f, 0.0f, 1.0f);
    printf("cd_down=%.1f\n", (double)cd);
    cd = clampf_local(cd + 1.0f, 0.0f, 1.0f);
    printf("cd_up=%.1f\n", (double)cd);

    float volume = 0.7f;
    volume = clampf_local((float)((double)volume + 0.1), 0.0f, 1.0f);
    volume = cvar_set_value_roundtrip(volume, text);
    printf("sound_up_text=%s\n", text);
    printf("sound_up_bits=%08x\n", (unsigned)float_bits(volume));

    float pitch = 0.022f;
    pitch = cvar_set_value_roundtrip(-pitch, text);
    printf("pitch_down_text=%s\n", text);
    printf("pitch_down_bits=%08x\n", (unsigned)float_bits(pitch));

    printf("submenu_toggle=main\n");
    return 0;
}
