#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static uint32_t bits(float x){uint32_t u;memcpy(&u,&x,4);return u;}
static void row(const char*n,int64_t v){printf("{\"name\":\"%s\",\"value\":%lld}\n",n,(long long)v);}
int main(void){row("atoi_decimal_prefix",atoi("12.5"));row("atoi_negative_prefix",atoi("-7x"));row("atoi_invalid",atoi("oops"));row("chase_dest_x_fbits",bits(-90.0f));row("chase_dest_z_fbits",bits(46.0f));row("preserved_yaw_fbits",bits(123.0f));row("preserved_roll_fbits",bits(7.0f));row("fixtures",22);return 0;}
