/* Source-guided sv_move.c direction, flags and MS-rand oracle. */
#include <stdint.h>
#include <stdio.h>
static void row(const char*n,long long v){printf("{\"kind\":\"case\",\"name\":\"%s\",\"value\":%lld}\n",n,v);}
static uint32_t seed;
static int random_word(void){seed=seed*214013u+2531011u;return (int)((seed>>16)&0x7fffu);}
int main(void){
 row("step_size",18);row("direct_ne",45);row("direct_nw",135);row("direct_sw",215);row("direct_se",315);
 row("partialground_clears_onground",1);row("yaw_gate_low",45);row("yaw_gate_high",315);
 seed=0;row("random_1",random_word());row("random_2",random_word());row("fixture_count",14);return 0;
}
