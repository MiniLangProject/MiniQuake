#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
static uint32_t bits(float value) { uint32_t word; memcpy(&word, &value, sizeof(word)); return word; }
int main(void) {
    float dx=0.0f, dy=-100.0f, dz=0.0f;
    float dist=sqrtf(dx*dx+dy*dy+dz*dz);
    float inv=1.0f/dist;
    dx*=inv; dy*=inv; dz*=inv;
    float dot=dx*0.0f+dy*-1.0f+dz*0.0f;
    float attenuation=1.0f/1000.0f;
    float scale=1.0f-dist*attenuation;
    int left=(int)(255.0f*scale*(1.0f-dot));
    int right=(int)(255.0f*scale*(1.0f+dot));
    printf("max_sfx=512\nmax_channels=128\nambient=4\ndynamic=8\n");
    printf("distance_bits=%08x\n", bits(dist));
    printf("attenuation_bits=%08x\n", bits(attenuation));
    printf("stereo=%d,%d\n", left<0?0:left, right<0?0:right);
    printf("exact_replacement=1\n");
    printf("channel_zero_override=0\n");
    printf("clear_precache_noop=1\n");
    return 0;
}
