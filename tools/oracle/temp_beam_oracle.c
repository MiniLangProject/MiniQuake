#include <stdint.h>
#include <stdio.h>
static void row(const char*n,int64_t v){printf("{\"name\":\"%s\",\"value\":%lld}\n",n,(long long)v);}
static int seg(float d){int n=0;while(d>0){n++;d-=30.0f;}return n;}
int main(void){row("segments_zero",seg(0));row("segments_one",seg(1));row("segments_thirty",seg(30));row("segments_thirty_one",seg(31));row("segments_sixty_one",seg(61));row("pitch_up",90);row("pitch_down",270);row("yaw_left",90);row("beam_pool",24);row("temp_limit",64);row("fixtures",22);return 0;}
