#include <stdint.h>
#include <stdio.h>
static int32_t wrap_mul(int32_t a, int32_t b) { return (int32_t)((uint32_t)a * (uint32_t)b); }
static int clamp16(int value) { if (value>32767) return 32767; if (value<-32768) return -32768; return value; }
int main(void) {
    int32_t product=wrap_mul(32767,131072);
    int shifted=product>>8;
    printf("paintbuffer=512\n");
    printf("product=%d\n", product);
    printf("shifted=%d\n", shifted);
    printf("clamp_hi=%d\n", clamp16(50000));
    printf("clamp_lo=%d\n", clamp16(-50000));
    printf("loop_boundary_position=2\n");
    printf("signed_i32=1\n");
    return 0;
}
