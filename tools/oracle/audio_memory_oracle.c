#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint32_t bits(float value) { uint32_t word; memcpy(&word, &value, sizeof(word)); return word; }
int main(void) {
    float step = (float)48000.0f / (float)22050.0f;
    int out_count = (int)((float)100 / step);
    const unsigned char source[4] = {128,129,130,131};
    unsigned char doubled[8];
    int frac_step = (int)(step * 256.0f);
    int sample_frac = 0;
    for (int i=0;i<8;i++) { int src = sample_frac >> 8; if (src > 3) src=3; doubled[i]=(unsigned char)(source[src]-128); sample_frac += frac_step; }
    printf("stepscale_bits=%08x\n", bits(step));
    printf("outcount=%d\n", out_count);
    printf("double=%u,%u,%u,%u,%u,%u,%u,%u\n", doubled[0],doubled[1],doubled[2],doubled[3],doubled[4],doubled[5],doubled[6],doubled[7]);
    printf("supported_widths=1,2\n");
    printf("stereo_rejected=1\n");
    printf("findchunk_iff_data=12\n");
    return 0;
}
