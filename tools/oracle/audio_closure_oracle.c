#include <stdint.h>
#include <stdio.h>
static int quake_atoi(const char *s) {
    int sign=1, value=0;
    if (*s=='-') { sign=-1; ++s; }
    while (*s>='0' && *s<='9') { value=value*10+(*s-'0'); ++s; }
    return value*sign;
}
int main(void) {
    printf("status=audio_109_frozen_v1\n");
    printf("fingerprint=%08x\n", 0xdcf7a002u);
    printf("atoi_5x=%d\n", quake_atoi("5x"));
    printf("atoi_2_9=%d\n", quake_atoi("2.9"));
    printf("atoi_negative=%d\n", quake_atoi("-1rest") & 255);
    printf("contract_vector=17\n");
    printf("retail_evidence_sounds=2\n");
    printf("physical_cd=modern_ogg_equivalent\n");
    printf("info_volume=%.6f\n", 1.0);
    return 0;
}
