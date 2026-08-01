#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t bits(float value) {
    uint32_t result;
    memcpy(&result, &value, sizeof(result));
    return result;
}

static float from_bits(uint32_t value) {
    float result;
    memcpy(&result, &value, sizeof(result));
    return result;
}

static uint32_t state_frame(uint32_t current, uint32_t requested) {
    float a = from_bits(requested);
    float frame = from_bits(current);
    if (a != frame) {
        frame = a;
    }
    return bits(frame);
}

int main(void) {
    volatile float large = 16777216.0f;
    volatile float one = 1.0f;
    printf("{\"kind\":\"case\",\"name\":\"opcode_count\",\"value\":66}\n");
    printf("{\"kind\":\"case\",\"name\":\"max_stack_depth\",\"value\":32}\n");
    printf("{\"kind\":\"case\",\"name\":\"localstack_size\",\"value\":2048}\n");
    printf("{\"kind\":\"case\",\"name\":\"binary32_add_bits\",\"value\":%u}\n", bits(large + one));
    printf("{\"kind\":\"case\",\"name\":\"byte_strcmp_positive\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"byte_strcmp_negative\",\"value\":-1}\n");
    printf("{\"kind\":\"case\",\"name\":\"negative_zero_truth\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"return_word_count\",\"value\":3}\n");
    printf("{\"kind\":\"case\",\"name\":\"max_call_parameters\",\"value\":8}\n");
    printf("{\"kind\":\"case\",\"name\":\"parameter_stride\",\"value\":3}\n");
    printf("{\"kind\":\"case\",\"name\":\"pointer_last_scalar_valid\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"pointer_vector_crosses\",\"value\":1}\n");
    printf("{\"kind\":\"case\",\"name\":\"state_signed_zero_word\",\"value\":%u}\n", state_frame(0x80000000u, 0x00000000u));
    printf("{\"kind\":\"case\",\"name\":\"state_changed_word\",\"value\":%u}\n", state_frame(bits(2.0f), bits(3.5f)));
    printf("{\"kind\":\"case\",\"name\":\"state_nan_word\",\"value\":%u}\n", state_frame(0x7fc00002u, 0x7fc00001u));
    return 0;
}
