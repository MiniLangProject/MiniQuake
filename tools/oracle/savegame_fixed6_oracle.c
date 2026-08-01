#include <stdint.h>
#include <stdio.h>
#include <string.h>

static float from_bits(uint32_t bits) {
    float value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

int main(void) {
    static const uint32_t cases[] = {
        UINT32_C(0x00000000), UINT32_C(0x80000000),
        UINT32_C(0x45800800), UINT32_C(0xc5800800),
        UINT32_C(0x4b7fffff), UINT32_C(0x3f9e064f),
        UINT32_C(0x350637bd), UINT32_C(0x35c9539c)
    };
    size_t index;
    for (index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        printf("0x%08x|%.6f\n", cases[index], (double)from_bits(cases[index]));
    }
    return 0;
}
