#include <stdio.h>
int main(void) {
    printf("wav_buffers=64\n");
    printf("wav_buffer_size=1024\n");
    printf("secondary_buffer_size=65536\n");
    printf("offsets=0,1024,7168,64512\n");
    printf("pre_roll=8\n");
    printf("dma_position_after_preroll=4096\n");
    printf("distinct_ring_regions=1\n");
    return 0;
}
