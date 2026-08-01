#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t fbits(float value) { uint32_t bits; memcpy(&bits,&value,4); return bits; }
static void row_i(const char *name, long long value) { printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",name,value); }
static void row_s(const char *name, const char *value) { printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":\"%s\"}\n",name,value); }
int main(void) {
    char text[32];
    float value = 0.100000001f;
    row_i("stored_value_bits", fbits(value));
    snprintf(text,sizeof(text),"%f",1.25f); row_s("setvalue_1_25",text);
    float nz; uint32_t bits=0x80000000u; memcpy(&nz,&bits,4);
    snprintf(text,sizeof(text),"%f",nz); row_s("setvalue_negative_zero",text);
    row_i("command_buffer_size",8192);
    row_i("max_alias_name",32);
    row_i("max_args",80);
    row_i("fixture_count",20);
    return 0;
}
